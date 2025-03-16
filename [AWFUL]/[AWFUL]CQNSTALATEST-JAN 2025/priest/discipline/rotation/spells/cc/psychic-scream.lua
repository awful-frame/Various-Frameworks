local Unlocker, awful, project = ...

local function has_attackers(enemy)
    local attackers = project.util.check.target.attackers(enemy)

    if (project.util.enemy.totalPlayers or 0) > 2 then

        if awful.player.hasTalent(project.util.id.spell.SHEER_TERROR_TALENT) or enemy.healer then
            if attackers.total > 1 then
                return true
            end

            if attackers.melee > 0 then
                return true
            end
        end
    end

    if attackers.total > 0 then
        return true
    end

    return false
end

project.priest.spells.psychicScream:Callback("pvp_enemy_healer", function(spell, enemies)
    if not project.settings.priest_cc_psychic_scream_healer then
        return
    end

    if not awful.enemyHealer.name then
        return
    end

    enemies.loop(function(enemy)
        if not enemy.healer and enemy.role ~= "tank" then
            return
        end

        if has_attackers(enemy) then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.cc("Psychic Scream! pvp_enemy_healer", project.priest.spells.psychicScream.id)
    end)
end)

project.priest.spells.psychicScream:Callback("pvp_enemy_los_of_healer", function(spell, enemies)
    if not project.settings.priest_cc_psychic_scream_los then
        return
    end

    if not awful.arena then
        return
    end

    enemies.loop(function(enemy)
        if enemy.losOf(awful.enemyHealer)
                and enemy.distanceTo(awful.enemyHealer) < 40 then
            return
        end

        if has_attackers(enemy) then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.cc("Psychic Scream! pvp_enemy_los_of_healer", project.priest.spells.psychicScream.id)
    end)
end)

project.priest.spells.psychicScream:Callback("pvp_2enemy", function(spell, count)
    if not project.settings.priest_cc_psychic_scream_2ormore then
        return
    end

    if count < 2 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.cc("Psychic Scream! pvp_2enemy", project.priest.spells.psychicScream.id)
end)

project.priest.spells.psychicScream:Callback("pvp_enemy_bursting", function(spell, count, enemies)
    if not project.settings.priest_cc_psychic_scream_bursting then
        return
    end

    enemies.loop(function(enemy)
        if has_attackers(enemy) then
            return
        end

        local total = project.util.check.target.cooldowns(enemy.target, enemy).total
        if total == 0 then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.cc("Psychic Scream! pvp_enemy_bursting", project.priest.spells.psychicScream.id)
    end)
end)

project.priest.spells.psychicScream:Callback("interrupt", function(spell)
    if not project.settings.priest_cc_psychic_scream_interrupt then
        return
    end

    if awful.time < project.util.interrupt.time then
        return
    end

    if project.util.interrupt.enemy.dist > 7 then
        return
    end

    if not project.util.cc.check_fear(project.util.interrupt.enemy) then
        return
    end

    if project.util.interrupt.prio == 2
            and not project.util.friend.danger then
        return
    end

    if project.util.interrupt.prio == 3 then
        if project.util.evade.holdGCD then
            return
        end

        local phase_shift = awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) and project.priest.spells.fade.cd < awful.gcd
        local meld = IsPlayerSpell(project.util.id.spell.SHADOWMELD) and project.util.spells.racials.shadowmeld.cd < awful.gcd

        if phase_shift or meld then
            return
        end
    end

    local spell_name = project.util.interrupt.enemy.casting or project.util.interrupt.enemy.channel
    if not spell_name then
        project.util.interrupt.reset()
        return
    end

    local cast_pct = project.util.interrupt.enemy.castPct
    if cast_pct == 0 then
        cast_pct = project.util.interrupt.enemy.channelPct
    end

    return spell:Cast()
            and project.util.debug.alert.cc("Psychic Scream! interrupt " .. spell_name .. project.util.interrupt.enemy.castPct, project.priest.spells.psychicScream.id)
end)

project.priest.spells.psychicScream:Callback("pvp_stealth", function(spell)
    if not project.util.enemy.target.stealth then
        return
    end

    if project.util.enemy.target.stealth.dist > 6 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.cc("Psychic Scream! pvp_stealth", project.priest.spells.psychicScream.id)
end)

project.priest.spells.psychicScream:Callback("pvp", function(spell, count, enemies)
    if not project.settings.priest_cc_psychic_scream then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return project.priest.spells.psychicScream("pvp_enemy_healer", enemies)
    end

    if count == 0 then
        return
    end

    if project.util.check.enemy.tremor() then
        return project.priest.spells.psychicScream("interrupt")
    end

    return project.priest.spells.psychicScream("pvp_enemy_healer", enemies)
            or project.priest.spells.psychicScream("pvp_enemy_bursting", count, enemies)
            or project.priest.spells.psychicScream("pvp_enemy_los_of_healer", enemies)
            or project.priest.spells.psychicScream("pvp_2enemy", count)
            or project.priest.spells.psychicScream("pvp_stealth", enemies)
            or project.priest.spells.psychicScream("interrupt")
end)

project.priest.spells.psychicScream:Callback("pve", function(spell)
    if not project.settings.priest_cc_psychic_scream then
        return
    end

    return project.priest.spells.psychicScream("interrupt")
end)

local font = awful.createFont(8, "OUTLINE")
awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_priest_enabled then
        return
    end

    if not project.settings.draw_priest_fear_icon then
        return
    end

    if project.priest.spells.psychicScream.cd > 2 then
        return
    end

    local txt = awful.textureEscape(project.priest.spells.psychicScream.id, 20, "0:20")
    local count, _, enemies = awful.enemies.around(awful.player, project.util.check.player.range(), function(enemy)
        return project.util.cc.check_fear(enemy, false, true)
    end)

    if count == 0 then
        return
    end

    local min_dist = math.huge

    enemies.loop(function(enemy)
        if project.util.check.scenario.type() == "pvp"
                and not enemy.player then
            return
        end

        local should_draw = false
        if project.util.interrupt.enemy
                and enemy.guid == project.util.interrupt.enemy.guid then
            should_draw = true
        end

        if not has_attackers(enemy) then
            if enemy.healer then
                should_draw = true
            end

            if enemy.target.enemy then
                local total = project.util.check.target.cooldowns(enemy.target, enemy).total
                if total > 0 then
                    should_draw = true
                end
            end

            if not enemy.losOf(awful.enemyHealer)
                    and awful.arena then
                should_draw = true
            end
        end

        if should_draw then
            if enemy.dist < min_dist then
                min_dist = enemy.dist
            end

            local x, y, z = enemy.position()
            draw:Text(txt, font, x, y, z)
        end
    end)

    if not project.settings.draw_priest_fear_range then
        return
    end

    if min_dist < 20 then
        local x, y, z = awful.player.position()
        draw:SetColor(0, 0, 255, 255)
        draw:Circle(x, y, z, 5.5)
    end
end)


