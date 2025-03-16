local Unlocker, awful, project = ...

project.priest.spells.powerWordBarrier:Callback("dbm_bars_party_below90HPA", function(spell)
    if project.util.friend.best_target.unit.hpa > 90 then
        return
    end

    if project.util.friend.tank.speed > 10 then
        return
    end

    local dbm_spell_name = project.util.dbm_bars.check(0, 4)
    if not dbm_spell_name then
        return
    end

    if project.util.friend.tank.moving then
        return
    end

    if awful.mapID == project.util.id.map.DAWNBREAKER then
        local viable_friends_count, _ = awful.fgroup.around(awful.player, 15, function(friend)
            if friend.dead then
                return
            end

            if not friend.inCombat then
                return
            end

            return true
        end)

        if viable_friends_count < 1 then
            return
        end

        return project.util.cast.overlap.cast(spell, awful.player)
                and project.util.debug.alert.beneficial("Power Word: Barrier! dbm_bars_party_below90HPA " .. dbm_spell_name, project.priest.spells.powerWordBarrier.id)
    end

    local viable_friends_count, _ = awful.fgroup.around(project.util.friend.tank, 15, function(friend)
        if friend.dead then
            return
        end

        return true
    end)

    if viable_friends_count < 1 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.tank)
            and project.util.debug.alert.beneficial("Power Word: Barrier! dbm_bars_party_below90HPA " .. dbm_spell_name, project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("tank_party_damage_below90HPA", function(spell)
    if awful.time < project.util.party_damage.early_time then
        return
    end

    if project.util.friend.best_target.unit.hpa > 90 then
        return
    end

    if project.util.friend.tank.speed > 10 then
        return
    end

    if awful.mapID == project.util.id.map.DAWNBREAKER then
        if awful.player.moving then
            return
        end

        local viable_friends_count, _ = awful.fgroup.around(awful.player, 15, function(friend)
            if friend.dead then
                return
            end

            return true
        end)

        if viable_friends_count < 1 then
            return
        end

        return project.util.cast.overlap.cast(spell, awful.player)
                and project.util.debug.alert.beneficial("Power Word: Barrier! tank_party_damage_below90HPA " .. project.util.party_damage.spell, project.priest.spells.powerWordBarrier.id)
    end

    if project.util.friend.tank.moving then
        return
    end

    local viable_friends_count, _ = awful.fgroup.around(project.util.friend.tank, 15, function(friend)
        if friend.dead then
            return
        end

        return true
    end)

    if viable_friends_count < 1 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.tank)
            and project.util.debug.alert.beneficial("Power Word: Barrier! tank_party_damage_below90HPA " .. project.util.party_damage.spell, project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("tank_buster", function(spell)
    if awful.time < project.util.tank_buster.time then
        return
    end

    if project.priest.spells.painSuppression.charges > 0 then
        return
    end

    local spell_name = project.util.tank_buster.enemy.casting or project.util.tank_buster.enemy.channel
    if not spell_name then
        return
    end

    local target = project.util.tank_buster.dest or project.util.friend.tank
    if awful.mapID == project.util.id.map.DAWNBREAKER then
        if target.dist > 10 then
            return
        end

        target = awful.player
    end

    if target.moving then
        return
    end

    local defensives = project.util.check.target.defensives(target)
    if defensives.def_best > 0 then
        return
    end

    if defensives.def > 0 and target.hpa > 50 then
        return
    end

    if target.hpa > 80 then
        return
    end

    if target.speed > 10 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, target)
            and project.util.debug.alert.beneficial("Power Word: Barrier! tank_buster " .. spell_name, project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_around2FR_atleast1CD", function(spell)
    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    local viableFriendsCount, _ = awful.fgroup.around(project.util.friend.best_target.unit, 15, function(friend)
        if friend.inCombat then
            return true
        end
        return false
    end)
    if viableFriendsCount < 1 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_around2FR_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_around2ATT_atleast1CD", function(spell)
    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    local viableEnemiesCount, _ = awful.enemies.around(project.util.friend.best_target.unit, 15, function(enemy)
        if enemy.inCombat then
            return true
        end
        return false
    end)

    if viableEnemiesCount < 2 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_around2ATT_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_caster_atleast1CD", function(spell)
    if project.util.friend.best_target.unit.melee then
        return
    end

    if project.util.friend.best_target.unit.class3 ~= project.util.id.class.HUNTER
            and project.util.friend.best_target.unit.moving then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_caster_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_melee_atleast1CD", function(spell)
    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    if not project.util.friend.best_target.unit.melee then
        return
    end

    if not project.util.friend.best_target.unit.target.enemy then
        return
    end

    if project.util.friend.best_target.unit.target.moving then
        return
    end

    if not project.util.friend.best_target.unit.meleeRangeOf(project.util.friend.best_target.unit.target) then
        return
    end

    if project.util.friend.best_target.unit.target.speed > 10 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.best_target.unit.target)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_melee_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_smokebomb", function(spell)
    if not project.util.enemy.existing_classes[project.util.id.class.ROGUE] then
        return
    end

    if not project.util.friend.best_target.unit.debuff(project.util.id.spell.SMOKE_BOMB_DEBUFF) then
        return
    end

    if not project.util.friend.best_target.unit.cc
            and not project.util.friend.best_target.unit.slowed then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_smokebomb", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pvp_stunned_atleast1CD", function(spell)
    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    if not project.util.friend.best_target.unit.stunned then
        return
    end

    if project.util.friend.best_target.unit.stunRemains < 2 then
        return
    end

    return project.util.cast.overlap.smart_aoe(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Power Word: Barrier! pvp_stunned_atleast1CD", project.priest.spells.powerWordBarrier.id)
end)

project.priest.spells.powerWordBarrier:Callback("pve", function()
    if not project.settings.priest_cds_power_word_barrier then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if project.priest.spells.leapOfFaith.queued then
        return
    end

    if awful.player.buff(project.util.id.spell.RAPTURE) then
        return
    end

    if project.util.friend.best_target.unit.speed > 10 then
        return
    end

    return project.priest.spells.powerWordBarrier("tank_party_damage_below90HPA")
            or project.priest.spells.powerWordBarrier("dbm_bars_party_below90HPA")
            or project.priest.spells.powerWordBarrier("tank_buster")
end)

project.priest.spells.powerWordBarrier:Callback("pvp", function()
    if not project.settings.priest_cds_power_word_barrier then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if project.util.friend.best_target.unit.speed > 10 then
        return
    end

    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 95 then
        return project.priest.spells.powerWordBarrier("pvp_smokebomb")
    end

    if project.util.friend.best_target.unit.hp < 30 then
        return
    end

    if not project.util.friend.best_target.unit.los
            and not project.util.friend.best_target.unit.stunned then
        return
    end

    if awful.player.used(project.priest.spells.painSuppression.id, 8) then
        return
    end

    if awful.player.used(project.priest.spells.leapOfFaith.id, 3) then
        return
    end

    if project.priest.spells.leapOfFaith.queued then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
            and project.util.friend.danger then
        return
    end

    if project.util.friend.best_target.defensives.def > 0 or awful.player.buff(project.util.id.spell.RAPTURE) then
        return project.priest.spells.powerWordBarrier("pvp_around2FR_atleast1CD")
                or project.priest.spells.powerWordBarrier("pvp_around2ATT_atleast1CD")
                or project.priest.spells.powerWordBarrier("pvp_stunned_atleast1CD")
                or project.priest.spells.powerWordBarrier("pvp_smokebomb")
    end

    return project.priest.spells.powerWordBarrier("pvp_caster_atleast1CD")
            or project.priest.spells.powerWordBarrier("pvp_melee_atleast1CD")

            or project.priest.spells.powerWordBarrier("pvp_stunned_atleast1CD")
            or project.priest.spells.powerWordBarrier("pvp_smokebomb")

            or project.priest.spells.powerWordBarrier("pvp_around2FR_atleast1CD")
            or project.priest.spells.powerWordBarrier("pvp_around2ATT_atleast1CD")
end)
