local Unlocker, awful, project = ...

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

project.priest.spells.fade:Callback("evade_trigger", function(spell)
    if not project.settings.priest_evade_triggers then
        return
    end

    if project.util.evade.trigger_prio == 1
            and (project.priest.spells.death.queued or awful.player.used(project.priest.spells.death.id, 2)) then
        return
    end

    if awful.time < project.util.evade.trigger_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.evade("Fade! evade_trigger", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("evade_missiles", function(spell)
    if not project.settings.priest_evade_traps then
        return
    end

    if awful.time < project.util.evade.missile_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.evade("Fade! evade_missiles", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("evade_casting", function(spell)
    if not project.settings.priest_evade_casting then
        return
    end

    if awful.time < project.util.evade.casting_cc_time then
        return
    end

    if project.util.evade.casting_prio == 4 then
        return
    end

    if project.util.evade.casting_prio == 2
            and project.priest.spells.death.queued then
        return
    end

    if not project.util.evade.casting_enemy then
        return
    end

    if not project.util.evade.casting_enemy.castID then
        project.util.evade.reset()
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

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.evade("Fade! evade_casting", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("evade_projectile", function(spell)
    if project.util.evade.projectile_prio == 3 then
        return
    end

    if awful.time < project.util.evade.projectile_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.evade("Fade! evade_projectile", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("evade_prediction", function(spell)
    if not project.settings.priest_evade_prediction then
        return
    end

    if project.util.evade.prediction_prio == 1
            and (project.priest.spells.death.queued or awful.player.used(project.priest.spells.death.id, 2)) then
        return
    end

    if awful.time < project.util.evade.prediction_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.evade("Fade! evade_prediction", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("evade_snowdrift", function(spell)
    if awful.player.debuffUptime(project.util.id.spell.SNOWDRIFT_PRE) < 1 then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.evade("Fade! evade_snowdrift", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("evade", function(spell)
    if not project.settings.priest_evade_enabled then
        return
    end

    if not project.settings.priest_evade_fade then
        return
    end

    if not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) then
        return
    end

    return project.priest.spells.fade("evade_casting")
            or project.priest.spells.fade("evade_projectile")
            or project.priest.spells.fade("evade_missiles")
            or project.priest.spells.fade("evade_prediction")
            or project.priest.spells.fade("evade_trigger")
            or project.priest.spells.fade("evade_snowdrift")
end)

