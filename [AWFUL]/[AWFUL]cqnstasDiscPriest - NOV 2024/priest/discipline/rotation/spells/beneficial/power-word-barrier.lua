local Unlocker, awful, project = ...

project.priest.spells.powerWordBarrier:Callback("dbm_bars", function(spell)
    if project.util.friend.bestTarget.hpa > 80 then
        return
    end

    for spell_name, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.timer - 1 < awful.time then
            if project.util.friend.tank.speed > 10 then
                return
            end

            return project.util.cast.overlap.smart_aoe(spell, project.util.friend.tank)
                    and project.util.debug.alert.beneficial("Power Word: Barrier! dbm_bars " .. spell_name, project.priest.spells.painSuppression.id)
        end
    end
end)

project.priest.spells.powerWordBarrier:Callback("tank_party_damage", function(spell)
    if awful.time < project.util.party_damage.early_time then
        return
    end

    if not project.util.party_damage.enemy.casting
            and not project.util.party_damage.enemy.channel then
        return
    end

    if project.util.party_damage.enemy.level == awful.player.level then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    if awful.mapID == 2662 then
        local viableFriendsCount, _ = awful.fgroup.around(awful.player, 15, function(friend)
            if friend.dead then
                return
            end

            if not friend.inCombat then
                return
            end

            return true
        end)

        if viableFriendsCount < 1 then
            return
        end

        return project.util.cast.overlap.cast(spell, awful.player)
                and project.util.debug.alert.beneficial("Power Word: Barrier! tank_party_damage " .. project.util.party_damage.spell, project.priest.spells.powerWordBarrier.id)
    end

    local viableFriendsCount, _ = awful.fgroup.around(project.util.friend.tank, 15, function(friend)
        if friend.dead then
            return
        end

        if not friend.inCombat then
            return
        end

        return true
    end)

    if viableFriendsCount < 1 then
        return
    end

    if project.util.friend.tank.speed > 10 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.tank)
            and project.util.debug.alert.beneficial("Power Word: Barrier! tank_party_damage " .. project.util.party_damage.spell, project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("tank_buster", function(spell)
    if not project.util.tank_buster.enemies then
        return
    end

    if project.util.friend.attackers.def > 0 then
        return
    end

    if awful.mapID == 2662 then
        return
    end

    if project.util.friend.tank.hp > 40 then
        return
    end

    project.util.tank_buster.enemies.loop(function(enemy)
        local tank_buster_spell

        if enemy.casting then
            tank_buster_spell = enemy.casting
        end

        if enemy.channel then
            tank_buster_spell = enemy.channel
        end

        if not tank_buster_spell then
            return
        end

        if project.util.friend.tank.speed > 10 then
            return
        end

        return project.util.cast.overlap.smart_aoe(spell, project.util.friend.tank)
                and project.util.debug.alert.beneficial("Power Word: Barrier! tank_buster " .. tank_buster_spell, project.priest.spells.powerWordBarrier.id)
    end)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_around2FR_atleast1CD", function(spell)
    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    local viableFriendsCount, _ = awful.fgroup.around(project.util.friend.bestTarget, 15, function(friend)
        if friend.inCombat then
            return true
        end
        return false
    end)
    if viableFriendsCount < 1 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_around2FR_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_around2ATT_atleast1CD", function(spell)
    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    local viableEnemiesCount, _ = awful.enemies.around(project.util.friend.bestTarget, 15, function(enemy)
        if enemy.inCombat then
            return true
        end
        return false
    end)

    if viableEnemiesCount < 2 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_around2ATT_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_caster_atleast1CD", function(spell)
    if project.util.friend.bestTarget.melee then
        return
    end

    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_caster_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_melee_atleast1CD", function(spell)
    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    if not project.util.friend.bestTarget.melee then
        return
    end

    if not project.util.friend.bestTarget.target.enemy then
        return
    end

    if project.util.friend.bestTarget.target.moving then
        return
    end

    if not project.util.friend.bestTarget.meleeRangeOf(project.util.friend.bestTarget.target) then
        return
    end

    if project.util.friend.bestTarget.target.speed > 10 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.bestTarget.target)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_melee_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_smokebomb", function(spell)
    if not project.util.enemy.existingClasses["Rogue"] then
        return
    end

    if not project.util.friend.bestTarget.debuff("Smoke Bomb") then
        return
    end

    if not project.util.friend.bestTarget.cc
            and not project.util.friend.bestTarget.slowed then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_smokebomb", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_stunned_atleast1CD", function(spell)
    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    if not project.util.friend.bestTarget.stunned then
        return
    end

    if project.util.friend.bestTarget.stunRemains < 2 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_stunned_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    if project.util.friend.bestTarget.speed > 10 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Power Word: Barrier! danger", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pve", function()
    if not project.settings.priest_cds_power_word_barrier then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if project.priest.spells.leapOfFaith.queued then
        return
    end

    if awful.player.buff("Rapture") then
        return
    end

    if project.util.friend.bestTarget.speed > 10 then
        return
    end

    return project.priest.spells.powerWordBarrier("tank_party_damage")
            or project.priest.spells.powerWordBarrier("tank_buster")
            or project.priest.spells.powerWordBarrier("dbm_bars")
end)

project.priest.spells.powerWordBarrier:Callback("pvp", function()
    if not project.settings.priest_cds_power_word_barrier then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if project.util.friend.bestTarget.speed > 10 then
        return
    end

    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 90 then
        return project.priest.spells.powerWordBarrier("pvp_smokebomb")
    end

    if project.util.friend.bestTarget.hp < 15 then
        return
    end

    if not project.util.friend.bestTarget.los
            and not project.util.friend.bestTarget.stunned then
        return
    end

    if awful.player.used(project.priest.spells.painSuppression.id, 8) then
        return
    end

    if awful.player.buff("Rapture") then
        return project.priest.spells.powerWordBarrier("danger")
                or project.priest.spells.powerWordBarrier("pvp_smokebomb")
    end

    if project.util.friend.attackers.def > 0 then
        return project.priest.spells.powerWordBarrier("pvp_around2FR_atleast1CD")
                or project.priest.spells.powerWordBarrier("pvp_around2ATT_atleast1CD")
                or project.priest.spells.powerWordBarrier("pvp_stunned_atleast1CD")
                or project.priest.spells.powerWordBarrier("pvp_smokebomb")
                or project.priest.spells.powerWordBarrier("danger")
    end

    return project.priest.spells.powerWordBarrier("pvp_caster_atleast1CD")
            or project.priest.spells.powerWordBarrier("pvp_melee_atleast1CD")

            or project.priest.spells.powerWordBarrier("pvp_stunned_atleast1CD")
            or project.priest.spells.powerWordBarrier("pvp_smokebomb")

            or project.priest.spells.powerWordBarrier("pvp_around2FR_atleast1CD")
            or project.priest.spells.powerWordBarrier("pvp_around2ATT_atleast1CD")

            or project.priest.spells.powerWordBarrier("danger")
end)
