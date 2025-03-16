local Unlocker, awful, project = ...

project.priest.spells.shadowfiend:Callback("fullaton", function(spell)
    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    return spell:Cast(project.util.enemy.best_target.unit)
            and project.util.debug.alert.offensive("Shadowfiend! fullaton", project.priest.spells.shadowfiend.id)
end)

project.priest.spells.shadowfiend:Callback("radiance", function(spell)
    if not awful.player.used(project.priest.spells.radiance.id, 5) then
        return
    end

    return spell:Cast(project.util.enemy.best_target.unit)
            and project.util.debug.alert.offensive("Shadowfiend! radiance", project.priest.spells.shadowfiend.id)
end)

project.priest.spells.shadowfiend:Callback("party_damage", function(spell)
    if awful.time < project.util.party_damage.early_time
            and awful.time < project.util.party_damage.time then
        return
    end

    return spell:Cast(project.util.enemy.best_target.unit)
            and project.util.debug.alert.offensive("Shadowfiend! party_damage " .. project.util.party_damage.spell, project.priest.spells.shadowfiend.id)
end)

project.priest.spells.shadowfiend:Callback("dbm_bars", function(spell)
    local dbm_spell_name = project.util.dbm_bars.check(0, 3)
    if not dbm_spell_name then
        return
    end

    return spell:Cast(project.util.enemy.best_target.unit)
            and project.util.debug.alert.offensive("Shadowfiend! dbm_bars " .. dbm_spell_name, project.priest.spells.shadowfiend.id)
end)

project.priest.spells.shadowfiend:Callback("atleast1CD", function(spell)
    if project.util.friend.total_cds == 0
            and project.util.enemy.total_cds == 0 then
        return
    end

    return spell:Cast(project.util.enemy.best_target.unit)
            and project.util.debug.alert.offensive("Shadowfiend! atleast1CD", project.priest.spells.shadowfiend.id)
end)

project.priest.spells.shadowfiend:Callback("pvp_below30MP", function(spell)
    if awful.player.manaPct > 30 then
        return
    end

    return spell:Cast(project.util.enemy.best_target.unit)
            and project.util.debug.alert.offensive("Shadowfiend! pvp_below30MP", project.priest.spells.shadowfiend.id)
end)

project.priest.spells.shadowfiend:Callback("pve", function(spell)
    if not project.settings.priest_offensives_shadowfiend then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.ttd < 8 then
        return
    end

    if project.util.enemy.withPurge == 0 then
        return
    end

    if project.priest.spells.mindBlast.cd > awful.gcd * 2 then
        return
    end

    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        return
    end

    if project.util.friend.total == 1 then
        return project.priest.spells.shadowfiend("atleast1CD")
    end

    return project.priest.spells.shadowfiend("dbm_bars")
            or project.priest.spells.shadowfiend("party_damage")
            or project.priest.spells.shadowfiend("fullaton")
            or project.priest.spells.shadowfiend("radiance")
end)

project.priest.spells.shadowfiend:Callback("pvp", function(spell)
    if not project.settings.priest_offensives_shadowfiend then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if (not project.util.friend.existing_classes[project.util.id.class.PRIEST] or awful.player.manaPct > 90)
            and project.priest.spells.powerInfusion.cd <= awful.gcd * 2 then
        return
    end

    return project.priest.spells.shadowfiend("atleast1CD")
            or project.priest.spells.shadowfiend("pvp_below30MP")
end)




