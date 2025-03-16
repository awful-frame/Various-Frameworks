local Unlocker, awful, project = ...

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

    if awful.player.casting or awful.player.channel then
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

    if awful.player.casting or awful.player.channel then
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

    if project.util.evade.casting_prio == 2
            and (project.priest.spells.death.queued or awful.player.used(project.priest.spells.death.id, 2)) then
        return
    end

    if not project.util.evade.casting_enemy then
        return
    end

    if not project.util.evade.casting_enemy.casting then
        project.util.evade.reset()
        return
    end

    if project.util.evade.casting_enemy.casting ~= "Polymorph" then
        if not project.util.evade.casting_enemy.los then
            return
        end

        if project.util.evade.casting_enemy.dist > 41 then
            return
        end
    end

    if project.util.evade.casting_enemy.casting == "Searing Glare" then
        if project.util.evade.casting_enemy.dist > 16 then
            return
        end
    end

    if project.util.evade.casting_enemy.casting == "Cyclone" then
        if project.util.evade.casting_enemy.dist > 30 then
            return
        end
    end

    if awful.player.casting or awful.player.channel then
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

    if awful.player.casting or awful.player.channel then
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

    if awful.player.casting or awful.player.channel then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.evade("Fade! evade_prediction", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("evade_snowdrift", function(spell)
    if not awful.player.debuff("Snowdrift") then
        return
    end

    if awful.player.casting
            or awful.player.channel then
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

    if not awful.player.hasTalent("Phase Shift") then
        return
    end

    return project.priest.spells.fade("evade_casting")
            or project.priest.spells.fade("evade_projectile")
            or project.priest.spells.fade("evade_missiles")
            or project.priest.spells.fade("evade_prediction")
            or project.priest.spells.fade("evade_trigger")
            or project.priest.spells.fade("evade_snowdrift")
end)

