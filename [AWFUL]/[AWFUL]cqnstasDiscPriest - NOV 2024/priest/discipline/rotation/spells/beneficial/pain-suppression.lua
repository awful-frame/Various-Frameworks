local Unlocker, awful, project = ...

project.priest.spells.painSuppression:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! danger", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_debuff", function(spell)
    if project.util.friend.bestTarget.debuffRemains("Deathmark") < 10
            and project.util.friend.bestTarget.debuffUptime("Touch of Death") < 2 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_debuff", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below95HP_SELFstunned_atleast1CD", function(spell)
    if not awful.player.stunned then
        return
    end

    if awful.player.debuffUptime(awful.player.stunned) < 1 then
        return
    end

    if awful.player.stunRemains < 1 then
        return
    end

    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 95 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below95HP_SELFstunned_atleast1CD", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below60HP_SELFstunned", function(spell)
    if not awful.player.stunned then
        return
    end

    if awful.player.debuffUptime(awful.player.stunned) < 1 then
        return
    end

    if awful.player.stunRemains < 1 then
        return
    end

    if project.util.friend.bestTarget.hp > 60 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below60HP_SELFstunned", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below95HP_charges2_atleast1CD", function(spell)
    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 95 then
        return
    end

    if spell.charges < 2 then
        if spell.nextChargeCD > 25 then
            return
        end
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below95HP_charges2_atleast1CD", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below90HP_atleast2CD", function(spell)
    if project.util.friend.attackers.cd.players < 2 then
        return
    end

    if project.util.friend.bestTarget.hp > 90 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below90HP_atleast2CD", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("below40HP_noTANK_2charges", function(spell)
    if project.util.friend.bestTarget.guid == project.util.friend.tank.guid then
        return
    end

    if spell.charges < 2 then
        if spell.nextChargeCD > 25 then
            return
        end
    end

    if project.util.friend.bestTarget.hp > 40 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! below40HP_noTANK_2charges", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("below20HP_noTANK", function(spell)
    if project.util.friend.bestTarget.guid == project.util.friend.tank.guid then
        return
    end

    if project.util.friend.bestTarget.hp > 20 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Pain Suppression! below20HP_noTANK", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("party_damage_below40HP", function(spell)
    if awful.player.buff("Rapture") then
        return
    end

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
            and project.util.debug.alert.beneficial("Pain Suppression! party_damage_below40HP " .. project.util.party_damage.spell, project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("tank_buster", function(spell)
    if not project.util.tank_buster.enemies then
        return
    end

    project.util.tank_buster.enemies.loop(function(enemy)
        if project.util.friend.tank.hpa > 60 then
            return
        end

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
                and project.util.debug.alert.beneficial("Pain Suppression! tank_buster " .. tank_buster_spell, project.priest.spells.painSuppression.id)
    end)
end)

project.priest.spells.painSuppression:Callback("pve_debuffs", function(spell)
    if not project.util.pve_debuffs.target then
        return
    end

    if project.util.pve_debuffs.target.hp > 70 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.pve_debuffs.target)
            and project.util.debug.alert.beneficial("Pain Suppression! pve_debuffs " .. project.util.pve_debuffs.debuff, project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("dbm_bars", function(spell)
    if project.util.friend.tank.hpa > 60 then
        return
    end

    for spell_name, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.prio ~= 1 then
            return
        end

        if bar_data.timer - 1 < awful.time then
            return project.util.cast.overlap.cast(spell, project.util.friend.tank)
                    and project.util.debug.alert.beneficial("Pain Suppression! dbm_bars " .. spell_name, project.priest.spells.painSuppression.id)
        end
    end
end)

project.priest.spells.painSuppression:Callback("pve", function()
    if not project.settings.priest_cds_pain_suppression then
        return
    end

    if project.util.friend.attackers.def > 0 then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    return project.priest.spells.painSuppression("tank_buster")
            or project.priest.spells.painSuppression("dbm_bars")
            or project.priest.spells.painSuppression("pve_debuffs")
            or project.priest.spells.painSuppression("party_damage_below40HP")
            or project.priest.spells.painSuppression("below20HP_noTANK")
            or project.priest.spells.painSuppression("below40HP_noTANK_2charges")
end)

project.priest.spells.painSuppression:Callback("pvp", function()
    if not project.settings.priest_cds_pain_suppression then
        return
    end

    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if awful.player.used(project.priest.spells.painSuppression.id, 4) then
        return
    end

    if awful.player.used(project.priest.spells.powerWordBarrier.id, 4) then
        return
    end

    if awful.player.used(project.priest.spells.painSuppression.id, 8)
            and project.util.friend.bestTarget.hp > 30 then
        return
    end

    if awful.player.buff("Premonition of Solace") then
        return
    end

    if project.util.friend.attackers.def > 0
            or awful.player.buffRemains("Premonition of Insight") > 3
            or awful.player.buff("Rapture")
            or project.priest.spells.rapture.cd < awful.gcd * 2 then
        return project.priest.spells.painSuppression("pvp_below95HP_SELFstunned_atleast1CD")
                or project.priest.spells.painSuppression("pvp_below60HP_SELFstunned")
                or project.priest.spells.painSuppression("danger")
    end

    return project.priest.spells.painSuppression("danger")
            or project.priest.spells.painSuppression("pvp_below95HP_SELFstunned_atleast1CD")
            or project.priest.spells.painSuppression("pvp_below95HP_charges2_atleast1CD")
            or project.priest.spells.painSuppression("pvp_below90HP_atleast2CD")
            or project.priest.spells.painSuppression("pvp_below60HP_SELFstunned")
            or project.priest.spells.painSuppression("pvp_debuff")
end)
