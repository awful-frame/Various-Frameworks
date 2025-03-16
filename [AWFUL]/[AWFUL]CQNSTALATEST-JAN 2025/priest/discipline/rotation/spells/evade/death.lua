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

local getTarget = function()
    if project.util.enemy.best_target.unit then
        return project.util.enemy.best_target.unit
    end

    return awful.enemies.find(function(enemy)
        return project.util.check.target.viable(enemy, true)
    end)
end

project.priest.spells.death:Callback("evade_trigger", function(spell)
    if not project.settings.priest_evade_triggers then
        return
    end

    if project.util.evade.trigger_prio ~= 1 then
        return
    end

    if awful.time < project.util.evade.trigger_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, getTarget())
            and project.util.debug.alert.evade("Shadow Word: Death! evade_trigger", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("evade_missiles", function(spell)
    if not project.settings.priest_evade_traps then
        return
    end

    if project.util.evade.missile_prio ~= 1 then
        return
    end

    if awful.time < project.util.evade.missile_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, getTarget())
            and project.util.debug.alert.evade("Shadow Word: Death! evade_missiles", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("evade_casting", function(spell)
    if not project.settings.priest_evade_casting then
        return
    end

    if project.util.evade.casting_prio ~= 2 then
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

    if not polymorph_spell_ids[project.util.evade.casting_enemy.castID] then
        if not project.util.evade.casting_enemy.los then
            project.util.debug.alert.evade("Not evading, target out of LOS", spell.id)
            return
        end

        if project.util.evade.casting_enemy.dist > 41 then
            project.util.debug.alert.evade("Not evading, target out of RANGE", spell.id)
            return
        end
    end

    if awful.player.castID
            or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, getTarget())
            and project.util.debug.alert.evade("Shadow Word: Death! evade_casting", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("evade_prediction", function(spell)
    if project.util.evade.prediction_prio ~= 1 then
        return
    end

    if awful.player.used(project.util.id.spell.FADE, 2) then
        return
    end

    if awful.time < project.util.evade.prediction_cc_time then
        return
    end

    if awful.player.castID or awful.player.channelID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, getTarget())
            and project.util.debug.alert.evade("Shadow Word: Death! evade_prediction", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("evade", function(spell)
    if not project.settings.priest_evade_enabled then
        return
    end

    if not project.settings.priest_evade_death then
        return
    end

    return project.priest.spells.death("evade_casting")
            or project.priest.spells.death("evade_missiles")
            or project.priest.spells.death("evade_trigger")
            or project.priest.spells.death("evade_prediction")
end)

