local Unlocker, awful, project = ...

local function should_penitence()
    if project.util.evade.block_cast then
        return
    end

    if awful.player.used(project.util.id.spell.PAIN_SUPPRESSION, 5) then
        return
    end

    if project.util.friend.best_target.unit.hp < 30 then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE) then
        return
    end

    if awful.player.buff(project.util.id.spell.SHADOW_COVENANT) then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then
        return
    end

    if project.util.friend.best_target.unit.buffRemains(project.util.id.spell.ATONEMENT) < project.util.thresholds.buff() + project.priest.spells.ultimatePenitence.castTime * 2 then
        return
    end

    if project.util.friend.total > 1
            and project.util.friend.withAtonement < 2 then
        return
    end

    if project.util.check.enemy.interrupt()
            and project.util.friend.danger
            and project.priest.spells.voidShift.cd > awful.gcd * 3 then
        return
    end

    if not project.util.enemy.best_target.unit then
        return
    end

    if not project.util.enemy.best_target.unit.los then
        return
    end

    if project.util.enemy.best_target.unit.dist > project.util.check.player.range() - 10 then
        return
    end

    if project.util.friend.best_target.unit.dist > project.util.check.player.range() - 10 then
        return
    end

    if awful.player.buff(project.util.id.spell.RAPTURE) then
        return
    end

    if awful.player.buffStacks(project.util.id.spell.WEAL_AND_WOE) >= 6 then
        return
    end

    if project.util.enemy.existing_classes[project.util.id.class.HUNTER]
            and awful.player.debuff(project.util.id.spell.SCORPID_VENOM) then
        return
    end

    return true
end

project.priest.spells.ultimatePenitence:Callback("defensive_3below70HP", function(spell)
    if project.util.friend.under70HpAton < 3 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.best_target.unit, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! defensive_2below70HP_atleast1CD", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp_defensive_2below70HP", function(spell)
    if project.util.enemy.total_cds == 0 then
        return
    end

    if project.util.friend.under70HpAton < 2 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.best_target.unit, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! pvp_defensive_2below70HP", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp_defensive_below90HP_atleast1CD", function(spell)
    if project.util.enemy.total_cds == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 90 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.best_target.unit, true, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! pvp_defensive_below90HP_atleast1CD", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.best_target.unit, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! danger", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("defensive_2below50HP", function(spell)
    if project.util.friend.best_target.unit.hp > 50 then
        return
    end

    if project.util.friend.under50HpAton < 2 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.best_target.unit, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! defensive_2below50HP", project.priest.spells.ultimatePenitence.id)
end)

project.priest.spells.ultimatePenitence:Callback("party_damage", function(spell)
    if awful.time < project.util.party_damage.time - spell.castTime then
        return
    end

    if project.util.friend.best_target.unit.hp > 80 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.best_target.unit, true)
            and project.util.debug.alert.beneficial("Ultimate Penitence! party_damage " .. project.util.party_damage.spell, project.priest.spells.radiance.id)
end)

project.priest.spells.ultimatePenitence:Callback("pvp", function(spell)
    if not project.settings.priest_cds_ultimate_penitence then
        return
    end

    if not should_penitence() then
        return
    end

    return project.priest.spells.ultimatePenitence("pvp_defensive_2below70HP")
            or project.priest.spells.ultimatePenitence("pvp_defensive_below90HP_atleast1CD")
            or project.priest.spells.ultimatePenitence("defensive_2below50HP")
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
