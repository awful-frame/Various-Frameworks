local Unlocker, awful, project = ...

local function should_mind_blast()
    if project.util.enemy.withPurge == 0 then
        return
    end

    if project.priest.discipline.rotation.util.is_premonition() then
        if project.util.friend.danger then
            return
        end

        if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
            return
        end
    end

    if project.util.evade.block_cast then
        return
    end

    if project.util.enemy.existing_classes[project.util.id.class.HUNTER]
            and awful.player.debuff(project.util.id.spell.SCORPID_VENOM)
            and awful.player.debuffRemains(project.util.id.spell.SCORPID_VENOM) < project.priest.spells.mindBlast.castTime then
        return
    end

    return true
end

project.priest.spells.mindBlast:Callback("totem_stomp", function(spell, totem)
    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        return
    end

    if not should_mind_blast() then
        return
    end

    return project.util.cast.stop_moving(spell, totem, true)
            and project.util.debug.alert.attack("Mind Blast! totem_stomp " .. totem.name, project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("pvp", function(spell, target)
    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        return
    end

    if not should_mind_blast() then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! spam_notCB", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("fullaton", function(spell, target)
    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        return
    end

    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! fullaton", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("radiance", function(spell, target)
    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        return
    end

    if not should_mind_blast() then
        return
    end

    if not awful.player.used(project.priest.spells.radiance.id, 5) then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! radiance", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("shadow_covenant", function(spell, target)
    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        return
    end

    if not awful.player.buff(project.util.id.spell.SHADOW_COVENANT) then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! shadow_covenant", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("dbm_bars", function(spell, target)
    local dbm_spell_name = project.util.dbm_bars.check(0, spell.castTime / 2)
    if not dbm_spell_name then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.offensive("Mind Blast! dbm_bars " .. dbm_spell_name, project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("party_damage", function(spell, target)
    if awful.time < project.util.party_damage.time - spell.castTime then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! party_damage " .. project.util.party_damage.spell, project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("pve", function(spell, target)
    if not should_mind_blast() then
        return
    end

    if project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.ttd < 5 then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and IsPlayerSpell(project.util.id.spell.VOIDWRAITH_TALENT)
            and project.priest.spells.voidwraith.cd <= awful.gcd * 2 then
        return
    end

    if project.util.friend.total == 1 then
        return project.util.cast.stop_moving(spell, target, true)
                and project.util.debug.alert.attack("Mind Blast! spam_solo", project.priest.spells.mindBlast.id)
    end

    return project.priest.spells.mindBlast("fullaton", target)
            or project.priest.spells.mindBlast("shadow_covenant", target)
            or project.priest.spells.mindBlast("dbm_bars", target)
            or project.priest.spells.mindBlast("party_damage", target)
            or project.priest.spells.mindBlast("radiance", target)
end)