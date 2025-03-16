local Unlocker, awful, project = ...

project.priest.spells.rapture:Callback("pvp_below95HP_atleast1CD", function(spell)
    if project.util.enemy.total_cds == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 95 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Rapture! pvp_below95HP_atleast1CD", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("pvp_below50HP_noDRB", function(spell)
    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 50 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Rapture! pvp_below50HP_noDRB", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("pvp_2below70HP", function(spell)
    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    if project.util.friend.under70Hp < 2 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Rapture! pvp_2below70HP", project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
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

    if project.util.friend.best_target.unit.hp > 40 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Rapture! party_damage_below40HP " .. project.util.party_damage.spell, project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("tank_buster", function(spell)
    if awful.time < project.util.tank_buster.time then
        return
    end

    if project.priest.spells.painSuppression.charges > 0 then
        return
    end

    if project.priest.spells.powerWordBarrier.cd < awful.gcd then
        return
    end

    local spell_name = project.util.tank_buster.enemy.casting or project.util.tank_buster.enemy.channel
    if not spell_name then
        return
    end

    local target = project.util.tank_buster.dest or project.util.friend.tank
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

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.beneficial("Rapture! tank_buster " .. spell_name, project.priest.spells.rapture.id)
end)

project.priest.spells.rapture:Callback("pve", function()
    if not project.settings.priest_cds_rapture then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then
        return
    end

    if project.priest.spells.mindBlast.cd < awful.gcd then
        return
    end

    if awful.instanceType2 == project.util.id.instance.PARTY
            or awful.instanceType2 == project.util.id.instance.RAID then
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

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then
        return
    end

    if (awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 or awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_PIETY) > 3)
            and project.util.friend.best_target.unit.hp > 80 then
        return
    end

    if project.util.friend.best_target.unit.buff(project.util.id.spell.POWER_WORD_SHIELD)
            and project.util.friend.best_target.unit.hpa - project.util.friend.best_target.unit.hp > 15 then
        return
    end

    return project.priest.spells.rapture("pvp_below95HP_atleast1CD")
            or project.priest.spells.rapture("pvp_below50HP_noDRB")
            or project.priest.spells.rapture("pvp_2below70HP")
            or project.priest.spells.rapture("danger")
end)