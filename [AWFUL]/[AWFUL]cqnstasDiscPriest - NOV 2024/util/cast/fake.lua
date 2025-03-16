local Unlocker, awful, project = ...

local fake_cast_spells = {
    {
        spell = project.priest.spells.mindBlast,
        priority = 1,
        enabled = function()
            return project.settings.priest_fake_cast_mind_blast
        end,
        condition = function()
            if project.priest.discipline.rotation.util.is_premonition() then
                return
            end
            return true
        end
    },
    {
        spell = project.priest.spells.ultimatePenitence,
        priority = 1,
        enabled = function()
            return project.settings.priest_fake_cast_ultimate_penitence
        end,
        condition = function()
            return true
        end
    },
    {
        spell = project.priest.spells.flashHeal,
        priority = 1,
        enabled = function()
            return project.settings.priest_fake_cast_flash_heal
        end,
        condition = function()
            if awful.player.buff("Surge of Light") then
                return
            end
            return true
        end
    },
}

local fake_cast_on_cd = false

project.util.cast.fake = function(type)
    if not project.settings.general_fake_cast_enabled then
        return
    end

    if type == "pve" then
        return
    end

    if fake_cast_on_cd then
        return
    end

    if project.util.friend.bestTarget.hp < 30 then
        return
    end

    if not project.util.check.enemy.interrupt() then
        return
    end

    if not project.util.friend.bestTarget.los then
        return
    end

    if project.util.friend.bestTarget.dist > project.util.check.player.range() then
        return
    end

    if not awful.player.inCombat then
        return
    end

    if project.util.friend.bestTarget.hp > 90 then
        return
    end

    if awful.player.manaPct > 90 then
        return
    end

    local castable_spells = {}
    local highest_priority = math.huge

    for _, entry in ipairs(fake_cast_spells) do
        if entry.enabled() and entry.condition() then
            local spell = entry.spell
            local priority = entry.priority
            if spell:Castable() and spell.cd < awful.gcd then
                if priority < highest_priority then
                    highest_priority = priority
                    castable_spells = { spell }
                elseif priority == highest_priority then
                    table.insert(castable_spells, spell)
                end
            end
        end
    end

    if #castable_spells == 0 then
        return
    end

    local spell_to_cast = castable_spells[math.random(#castable_spells)]
    if project.util.cast.stop_moving(spell_to_cast, awful.player, false, true) then
        local fake_cast_pct = project.util.cast.interrupt_pct_avg - 10
        if fake_cast_pct > 50 and project.util.friend.danger then
            fake_cast_pct = 50.69
        end

        if fake_cast_pct < 45 then
            fake_cast_pct = 45.69
        end

        project.util.debug.alert.evade("Fake Cast! " .. project.util.cast.interrupt_pct_avg .. " - " .. awful.time, spell_to_cast.id)
        awful.alert(awful.colors.dh .. "Fake Cast!", spell_to_cast.id)

        C_Timer.After(spell_to_cast.castTime * (project.util.cast.interrupt_pct_avg / 100) + awful.spellCastBuffer, function()
            if awful.player.casting ~= spell_to_cast.name then
                return
            end

            awful.call("SpellStopCasting")
        end)

        fake_cast_on_cd = true
        C_Timer.After(project.settings.priest_fake_cast_cooldown, function()
            fake_cast_on_cd = false
        end)

        project.util.pause.time = awful.time + awful.spellCastBuffer
        return true
    end
end

