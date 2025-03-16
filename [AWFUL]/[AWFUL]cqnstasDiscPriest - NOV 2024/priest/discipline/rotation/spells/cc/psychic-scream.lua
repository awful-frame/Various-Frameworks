local Unlocker, awful, project = ...

project.priest.spells.psychicScream:Callback("pvp_enemy_healer", function(spell, enemies)
    if not project.settings.priest_cc_psychic_scream_healer then
        return
    end

    enemies.loop(function(enemy)
        if awful.enemyHealer and awful.enemyHealer.name
                and not enemy.healer
                and enemy.role ~= "tank" then
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

project.priest.spells.psychicScream:Callback("pvp_enemy_nodispel", function(spell)
    if not project.settings.priest_cc_psychic_scream_dispel then
        return
    end

    if not awful.arena then
        return
    end

    if project.util.check.enemy.magic_dispel() then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.cc("Psychic Scream! pvp_enemy_nodispel", project.priest.spells.psychicScream.id)
end)

project.priest.spells.psychicScream:Callback("pvp_enemy_bursting", function(spell, count, enemies)
    if not project.settings.priest_cc_psychic_scream_bursting then
        return
    end

    enemies.loop(function(enemy)
        local cds = project.util.check.target.cooldowns(enemy.target, enemy)
        if cds == 0 then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.cc("Psychic Scream! pvp_enemy_bursting", project.priest.spells.psychicScream.id)
    end)
end)

project.priest.spells.psychicScream:Callback("interrupt", function(spell)
    if not project.util.interrupt.enemies then
        return
    end

    project.util.interrupt.enemies.loop(function(enemy)
        if enemy.immuneCC then
            return
        end

        if enemy.disorientDR == 0 then
            return
        end

        if enemy.dist > 7 then
            return
        end

        local prio = project.util.interrupt.spells[enemy.casting]
        if not prio then
            prio = project.util.interrupt.spells[enemy.channel]
            if not prio then
                return
            end
        end

        if enemy.level > awful.player.level or enemy.level == -1 then
            return
        end

        if prio == 2
                and (project.priest.spells.death.cd  <= awful.gcd * 2
                or project.priest.spells.fade.cd  <= awful.gcd * 2
                or project.util.spells.racials.shadowmeld.cd <= awful.gcd * 2) then
            return
        end

        local spell_to_interrupt

        if enemy.casting then
            spell_to_interrupt = enemy.casting
        end

        if enemy.channel then
            spell_to_interrupt = enemy.channel
        end

        if not spell_to_interrupt then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.cc("Psychic Scream! interrupt " .. spell_to_interrupt .. " -> " .. enemy.castPct, project.priest.spells.psychicScream.id)
    end)
end)

project.priest.spells.psychicScream:Callback("pvp_stealth", function(spell)
    if not project.util.enemy.target.stealth then
        return
    end

    if project.util.enemy.target.stealth.dist > 7 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.cc("Psychic Scream! pvp_stealth", project.priest.spells.psychicScream.id)
end)

project.priest.spells.psychicScream:Callback("pvp", function(spell, count, enemies)
    if not project.settings.priest_cc_psychic_scream then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if count == 0 then
        return
    end

    return project.priest.spells.psychicScream("pvp_enemy_healer", enemies)
            or project.priest.spells.psychicScream("interrupt", enemies)
            or project.priest.spells.psychicScream("pvp_enemy_bursting", count, enemies)
            or project.priest.spells.psychicScream("pvp_enemy_los_of_healer", enemies)
            or project.priest.spells.psychicScream("pvp_enemy_nodispel")
            or project.priest.spells.psychicScream("pvp_2enemy", count)
            or project.priest.spells.psychicScream("pvp_stealth", enemies)
end)

project.priest.spells.psychicScream:Callback("pve", function(spell)
    if not project.settings.priest_cc_psychic_scream then
        return
    end

    return project.priest.spells.psychicScream("interrupt", enemies)
end)


