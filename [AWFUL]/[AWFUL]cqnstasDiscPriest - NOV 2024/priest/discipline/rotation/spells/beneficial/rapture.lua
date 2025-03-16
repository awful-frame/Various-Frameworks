local Unlocker, awful, project = ...

project.priest.spells.rapture:Callback("pvp_below95HP_atleast1CD", function(spell)
    if project.util.enemy.withOffensiveCds == 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 95 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Rapture! pvp_below95HP_atleast1CD", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("pvp_below50HP_noDRB", function(spell)
    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 50 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Rapture! pvp_below50HP_noDRB", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("pvp_2below70HP", function(spell)
    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if project.util.friend.under70Hp < 2 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Rapture! pvp_2below70HP", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Rapture! danger", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("rampture", function(spell, target)
    return spell:Cast(target)
            and project.util.debug.alert.beneficial("Rapture! rampture", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("party_damage_below40HP", function(spell)
    if awful.time < project.util.party_damage.early_time then
        return
    end

    if project.util.party_damage.enemy.level == awful.player.level then
        return
    end

    if project.util.friend.bestTarget.hp > 40 then
        return
    end

    if not project.util.party_damage.enemy.casting
            and not project.util.party_damage.enemy.channel then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Rapture! party_damage_below40HP " .. project.util.party_damage.spell, project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("tank_buster", function(spell)
    if not project.util.tank_buster.enemies then
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

        return project.util.cast.overlap.cast(spell, project.util.friend.tank)
                and project.util.debug.alert.beneficial("Rapture! tank_buster " .. tank_buster_spell, project.priest.spells.rapture.id)
    end)
end)

project.priest.spells.rapture:Callback("pve", function()
    if not project.settings.priest_cds_rapture then
        return
    end

    if awful.player.buff("Voidheart") then
        return
    end

    if awful.instanceType2 == "party" or awful.instanceType2 == "raid" then
        return project.priest.spells.rapture("tank_buster")
                or project.priest.spells.rapture("party_damage_below40HP")
    end

    return project.priest.spells.rapture("3below70HP")
            or project.priest.spells.rapture("below50HP_noDRB")
            or project.priest.spells.rapture("tank_buster")
            or project.priest.spells.rapture("danger")
end)

project.priest.spells.rapture:Callback("pvp", function()
    if not project.settings.priest_cds_rapture then
        return
    end

    if awful.player.buff("Voidheart") then
        return
    end

    if (awful.player.buffRemains("Premonition of Insight") > 3 or awful.player.buffRemains("Premonition of Piety") > 3)
            and project.util.friend.bestTarget.hp > 80 then
        return
    end

    if project.util.friend.bestTarget.buff("Power Word: Shield")
            and project.util.friend.bestTarget.hpa - project.util.friend.bestTarget.hp > 15 then
        return
    end

    return project.priest.spells.rapture("pvp_below95HP_atleast1CD")
            or project.priest.spells.rapture("pvp_below50HP_noDRB")
            or project.priest.spells.rapture("pvp_2below70HP")
            or project.priest.spells.rapture("danger")
end)