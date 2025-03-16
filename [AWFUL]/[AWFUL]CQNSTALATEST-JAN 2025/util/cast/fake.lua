local Unlocker, awful, project = ...

local fake_cast_spells = {
    -- PRIEST
    -- DISCIPLINE
    {
        spell = project.priest.spells.mindBlast,
        priority = 1,
        damage = true,
        enabled = function()
            return project.settings.priest_fake_cast_mind_blast
        end,
        condition = function()
            if awful.player.spec ~= project.util.id.spec.DISCIPLINE then
                return
            end

            if project.priest.discipline.rotation.util.is_premonition() then
                return
            end

            return true
        end
    },
    {
        spell = project.priest.spells.mindControl,
        priority = 1,
        damage = true,
        enabled = function()
            return project.settings.priest_fake_cast_mind_control
        end,
        condition = function()
            if awful.player.spec ~= project.util.id.spec.DISCIPLINE then
                return
            end

            if not IsPlayerSpell(project.util.id.spell.MIND_CONTROL) then
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
            if awful.player.spec ~= project.util.id.spec.DISCIPLINE then
                return
            end

            if not IsPlayerSpell(project.util.id.spell.ULTIMATE_PENITENCE) then
                return
            end

            if awful.player.buff(project.util.id.spell.RAPTURE) then
                return
            end

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
            if awful.player.spec ~= project.util.id.spec.DISCIPLINE then
                return
            end

            if not project.priest.discipline.rotation.util.is_premonition() then
                return
            end

            if awful.player.buff(project.util.id.spell.SURGE_OF_LIGHT) then
                return
            end

            if awful.player.buff(project.util.id.spell.RAPTURE) then
                return
            end

            return true
        end
    },
}

local fake_cast_on_cd = false
local fake_cast_failed_ths = 0

local function fake_cast_failed_ths_reset()
    fake_cast_failed_ths = 0
end

project.util.cast.fake_spell = nil

project.util.cast.fake = function(type)
    if not project.settings.general_fake_cast_enabled then
        return
    end

    if fake_cast_on_cd then
        return
    end

    if project.util.evade.block_cast then
        return
    end

    if type == "pve" then
        return
    end

    if project.util.friend.danger then
        return
    end

    if not project.util.check.enemy.interrupt() then
        return
    end

    if not project.util.friend.best_target.unit.los then
        return
    end

    if project.util.friend.best_target.unit.dist > project.util.check.player.range() then
        return
    end

    if not awful.player.inCombat then
        return
    end

    if project.util.friend.best_target.unit.hp < 30 then
        return
    end

    if awful.player.manaPct > 90 then
        return
    end

    if awful.player.lockouts.holy
            or awful.player.lockouts.shadow then
        fake_cast_failed_ths = 0
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

    local target = project.util.friend.best_target.unit
    if spell_to_cast.damage then
        target = project.util.enemy.best_target.unit
    end

    if project.util.cast.stop_moving(spell_to_cast, target, false, true) then
        project.util.cast.fake_spell = spell_to_cast

        local fake_cast_pct = 50 + fake_cast_failed_ths
        if fake_cast_pct > 50 then
            if project.util.friend.best_target.unit.hp < 50 then
                fake_cast_pct = 50.69
            end

            local melees = project.util.check.target.attackers(awful.player).melee
            if melees > 0 then
                fake_cast_pct = 50.6699
            end

            if awful.player.guid == project.util.friend.best_target.unit.guid then
                fake_cast_pct = 50.666999
            end
        end

        if fake_cast_pct > 75 then
            fake_cast_pct = 75.69
        end

        project.util.debug.alert.evade("Fake Cast! " .. fake_cast_pct .. " - " .. awful.time, spell_to_cast.id)
        C_Timer.After(spell_to_cast.castTime * (fake_cast_pct / 100) + awful.spellCastBuffer, function()
            if awful.player.castID ~= spell_to_cast.id then
                return
            end

            project.util.debug.alert.evade("Stopped Fake Cast! " .. awful.player.castPct, spell_to_cast.id)

            awful.call("SpellStopCasting")
            project.util.evade.block_cast = true
            C_Timer.After(1, function()
                project.util.evade.block_cast = false
            end)

            fake_cast_failed_ths = fake_cast_failed_ths + 5
        end)

        fake_cast_on_cd = true

        C_Timer.After(project.settings.priest_fake_cast_cooldown, function()
            fake_cast_on_cd = false
        end)

        project.util.pause.time = awful.time + awful.spellCastBuffer + awful.buffer
        return true
    end
end

awful.onEvent(fake_cast_failed_ths_reset, "ARENA_PREP_OPPONENT_SPECIALIZATIONS")
awful.onEvent(fake_cast_failed_ths_reset, "PLAYER_ENTERING_WORLD")
awful.onEvent(fake_cast_failed_ths_reset, "PLAYER_LEAVING_WORLD")

