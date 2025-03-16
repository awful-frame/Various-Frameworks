local Unlocker, awful, project = ...

project.util.spells.racials.shadowmeld:Callback("evade_casting", function(spell)
    if not project.settings.general_evade_casting then
        return
    end

    if awful.time < project.util.evade.casting_cc_time then
        return
    end

    if project.util.evade.casting_prio == 2
            and project.priest.spells.death.queued then
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

    if awful.player.casting or awful.player.channel then
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

    if awful.player.casting or awful.player.channel then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast_sm(spell)
            and project.util.debug.alert.evade("Shadowmeld! evade_projectile", project.util.spells.racials.shadowmeld.id)
end)

project.util.spells.racials.shadowmeld:Callback("evade_touch_of_death", function(spell)
    if not awful.player.debuff("Touch of Death") then
        return
    end

    if awful.player.debuffRemains("Touch of Death") > awful.spellCastBuffer + awful.buffer then
        return
    end

    if awful.player.casting or awful.player.channel then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast_sm(spell)
            and project.util.debug.alert.evade("Shadowmeld! evade_touch_of_death", project.util.spells.racials.shadowmeld.id)
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
end)
