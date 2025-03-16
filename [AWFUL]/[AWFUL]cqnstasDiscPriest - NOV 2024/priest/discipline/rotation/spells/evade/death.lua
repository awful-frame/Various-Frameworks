local Unlocker, awful, project = ...

local getTarget = function()
    if project.util.enemy.bestTarget then
        return project.util.enemy.bestTarget
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

    if awful.player.casting or awful.player.channel then
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

    if awful.player.casting or awful.player.channel then
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

    if project.util.evade.casting_enemy then
        if not project.util.evade.casting_enemy.casting then
            project.util.evade.reset()
            return
        end

        if project.util.evade.casting_enemy.casting ~= "Polymorph" then
            if not project.util.evade.casting_enemy.los then
                return
            end
        end
    end

    if awful.player.casting
            or awful.player.channel then
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

    if awful.player.buff("Phase Shift") then
        return
    end

    if awful.time < project.util.evade.prediction_cc_time then
        return
    end

    if awful.player.casting
            or awful.player.channel then
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

