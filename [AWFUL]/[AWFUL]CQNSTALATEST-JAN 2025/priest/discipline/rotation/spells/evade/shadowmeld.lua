local Unlocker, awful, project = ...

local pve_debuffs = {
    project.util.id.spell.DRAIN_FLUIDS,

    project.util.id.spell.MORBID_FIXATION_DEBUFF_1,
    project.util.id.spell.MORBID_FIXATION_DEBUFF_2,

    project.util.id.spell.HARVEST_ESSENCE_DEBUFF,
    project.util.id.spell.OVERGROWTH_DEBUFF,

    project.util.id.spell.AZERITE_CHARGE_TARGETED_DEBUFF,

    project.util.id.spell.ROCK_SPIKE_TARGETED_DEBUFF
}

local polymorph_spell_ids = {
    [project.util.id.spell.POLYMORPH_1] = true,
    [project.util.id.spell.POLYMORPH_2] = true,
    [project.util.id.spell.POLYMORPH_3] = true,
    [project.util.id.spell.POLYMORPH_4] = true,
    [project.util.id.spell.POLYMORPH_5] = true,
    [project.util.id.spell.POLYMORPH_6] = true,
    [project.util.id.spell.POLYMORPH_7] = true,
    [project.util.id.spell.POLYMORPH_8] = true,
    [project.util.id.spell.POLYMORPH_9] = true,
    [project.util.id.spell.POLYMORPH_10] = true,
    [project.util.id.spell.POLYMORPH_11] = true,
    [project.util.id.spell.POLYMORPH_12] = true,
    [project.util.id.spell.POLYMORPH_13] = true,
    [project.util.id.spell.POLYMORPH_14] = true,
    [project.util.id.spell.POLYMORPH_15] = true,
    [project.util.id.spell.POLYMORPH_16] = true,
}

project.util.spells.racials.shadowmeld:Callback("evade_casting", function(spell)
    if not project.settings.general_evade_casting then
        return
    end

    if awful.time < project.util.evade.casting_cc_time then
        return
    end

    if not project.util.evade.casting_enemy then
        return
    end

    if not project.util.evade.casting_enemy.castID then
        project.util.evade.reset()
        return
    end

    if project.util.evade.casting_prio == 2
            and project.priest.spells.death.queued then
        return
    end

    if not polymorph_spell_ids[project.util.evade.casting_enemy.castID] then
        if not project.util.evade.casting_enemy.los then
            project.util.debug.alert.evade("Not evading, target out of LOS", spell.id)
            return
        end

        if project.util.evade.casting_enemy.dist > 41 then
            project.util.debug.alert.evade("Not evading, target out of RANGE", spell.id)
            return
        end

        if project.util.evade.casting_enemy.castID == project.util.id.spell.SEARING_GLARE then
            if project.util.evade.casting_enemy.dist > 26 then
                project.util.debug.alert.evade("Not evading, target out of RANGE for SEARING GLARE", spell.id)
                return
            end
        end
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast_sm(spell)
            and project.util.debug.alert.evade("Shadowmeld! evade_casting", project.util.spells.racials.shadowmeld.id)
end)

project.util.spells.racials.shadowmeld:Callback("evade_projectile", function(spell)
    if not project.settings.general_evade_projectiles then
        return
    end

    if project.util.evade.projectile_prio ~= 3 then
        return
    end

    if awful.time < project.util.evade.projectile_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast_sm(spell)
            and project.util.debug.alert.evade("Shadowmeld! evade_projectile", project.util.spells.racials.shadowmeld.id)
end)

project.util.spells.racials.shadowmeld:Callback("evade_touch_of_death", function(spell)
    if not project.util.enemy.existing_classes[project.util.id.class.MONK] then
        return
    end

    if not awful.player.debuff(project.util.id.spell.TOUCH_OF_DEATH_DEBUFF) then
        return
    end

    if awful.player.debuffRemains(project.util.id.spell.TOUCH_OF_DEATH_DEBUFF) > awful.buffer then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast_sm(spell)
            and project.util.debug.alert.evade("Shadowmeld! evade_touch_of_death", project.util.spells.racials.shadowmeld.id)
end)

project.util.spells.racials.shadowmeld:Callback("evade_pve_debuffs", function(spell)
    if not awful.player.debuffFrom(pve_debuffs) then
        return
    end

    return project.util.cast.overlap.cast_sm(spell)
            and project.util.debug.alert.evade("Shadowmeld! evade_pve_debuffs", project.util.spells.racials.shadowmeld.id)
end)

project.util.spells.racials.shadowmeld:Callback("evade", function(spell)
    if not project.settings.general_evade_enabled then
        return
    end

    if awful.player.stealth then
        return
    end

    return project.util.spells.racials.shadowmeld("evade_casting")
            or project.util.spells.racials.shadowmeld("evade_projectile")
            or project.util.spells.racials.shadowmeld("evade_touch_of_death")
            or project.util.spells.racials.shadowmeld("evade_pve_debuffs")
end)
