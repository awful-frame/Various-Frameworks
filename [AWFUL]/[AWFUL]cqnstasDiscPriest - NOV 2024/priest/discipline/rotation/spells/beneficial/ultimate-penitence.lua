local Unlocker, awful, project = ...

local function should_penitence()
    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if awful.player.buff("Premonition of Solace") then
        return
    end

    if awful.player.buff("Shadow Covenant") then
        return
    end

    if awful.player.buff("Voidheart") then
        return
    end

    if project.util.friend.bestTarget.buffRemains("Atonement") < project.util.thresholds.buff() + project.priest.spells.ultimatePenitence.castTime * 2 then
        return
    end

    if project.util.check.enemy.interrupt()
            and project.util.friend.danger then
        return
    end

    if not project.util.enemy.bestTarget then
        return
    end

    if not project.util.enemy.bestTarget.los then
        return
    end

    if project.util.enemy.bestTarget.dist > project.util.check.player.range() - 10 then
        return
    end

    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    if awful.player.buff("Rapture") then
        return
    end

    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if awful.player.buffStacks("Weal and Woe") >= 4 then
        return
    end

    if awful.player.debuff("Scorpid Venom") then
        return
    end

    return true
end

project.priest.spells.ultimatePenitence:Callback("defensive_3below70HP", function(spell)
    if project.util.friend.under70HpAton < 3 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.bestTarget, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! defensive_2below70HP_atleast1CD", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp_defensive_2below70HP_atleast1CD", function(spell)
    if project.util.enemy.withOffensiveCds == 0 then
        return
    end

    if project.util.friend.under70HpAton < 2 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.bestTarget, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! pvp_defensive_2below70HP_atleast1CD", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp_defensive_below90HP_atleast2CD", function(spell)
    if project.util.enemy.withOffensiveCds < 2 then
        return
    end

    if project.util.friend.bestTarget.hp > 90 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.bestTarget, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! pvp_defensive_below90HP_atleast2CD", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp_defensive_below80HP_atleast1CD_noDEF", function(spell)
    if project.util.enemy.withOffensiveCds == 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    if project.util.friend.attackers.def > 0 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.bestTarget, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! pvp_defensive_below80HP_atleast1CD_noDEF", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp_piety_below90HP_atleast1CD_noDEF", function(spell)
    if project.util.enemy.withOffensiveCds == 0 then
        return
    end

    if not awful.player.buff("Premonition of Piety") then
        return
    end

    if project.util.friend.bestTarget.hp > 90 then
        return
    end

    if project.util.friend.attackers.def > 0 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.bestTarget, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! pvp_piety_below90HP_atleast1CD_noDEF", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.bestTarget, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! danger", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("defensive_2below50HP", function(spell)
    if project.util.friend.bestTarget.hp > 50 then
        return
    end

    if project.util.friend.under50HpAton < 2 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.bestTarget, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! defensive_2below50HP", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("party_damage", function(spell)
    if awful.time < project.util.party_damage.time - spell.castTime then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    return spell:Cast(project.util.enemy.bestTarget())
            and project.util.debug.alert.beneficial("Ultimate Penitence! party_damage " .. project.util.party_damage.spell, project.priest.spells.radiance.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp", function(spell)
    if not project.settings.priest_cds_ultimate_penitence then
        return
    end

    if not should_penitence() then
        return
    end

    return project.priest.spells.ultimatePenitence("pvp_defensive_2below70HP_atleast1CD")
            or project.priest.spells.ultimatePenitence("pvp_defensive_below80HP_atleast1CD_noDEF")
            or project.priest.spells.ultimatePenitence("pvp_defensive_below90HP_atleast2CD")
            or project.priest.spells.ultimatePenitence("pvp_piety_below90HP_atleast1CD_noDEF")
            or project.priest.spells.ultimatePenitence("defensive_2below50HP")
            or project.priest.spells.ultimatePenitence("defensive_3below70HP")
            or project.priest.spells.ultimatePenitence("danger")
end)

project.priest.spells.ultimatePenitence:Callback("pve", function(spell)
    if not project.settings.priest_cds_ultimate_penitence then
        return
    end

    if not should_penitence() then
        return
    end

    return project.priest.spells.ultimatePenitence("party_damage")
            or project.priest.spells.ultimatePenitence("defensive_2below50HP")
            or project.priest.spells.ultimatePenitence("defensive_3below70HP")
end)
