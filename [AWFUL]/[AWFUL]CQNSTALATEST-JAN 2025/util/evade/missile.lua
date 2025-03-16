local Unlocker, awful, project = ...

local missiles_to_evade = {
    [project.util.id.spell.FREEZING_TRAP] = 2,
}

project.util.evade.missile_cc_time = math.huge
project.util.evade.missile_prio = 0
project.util.evade.missile_detected = false
project.util.evade.block_cast = false

project.util.evade.missiles = function()
    if not project.util.evade.missile_detected then
        return
    end

    if not project.util.evade.should_evade() then
        return
    end

    if project.util.evade.missile_cc_time < math.huge then
        return
    end

    awful.missiles.track(function(missile)
        local prio = missiles_to_evade[missile.spellId]
        if not prio then
            return
        end

        local creator = awful.GetObjectWithGUID(missile.source)
        if not creator then
            return
        end

        if creator.friend then
            return
        end

        local no_phase_shift = not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) or project.priest.spells.fade.cd > 0

        if prio == 1
                and no_phase_shift
                and project.priest.spells.death.cd > awful.gcd then
            return
        end

        if prio == 2
                and no_phase_shift then
            return
        end

        if awful.player.incapacitateDR <= 0.25 then
            return
        end

        if awful.player.buffRemains(project.util.id.spell.PRECOGNITION) > 1 then
            return
        end

        if awful.player.ccImmunityRemains > 1 then
            return
        end

        if project.util.evade.missile_prio == 0 then
            if awful.player.distanceTo(missile.hx, missile.hy, missile.hz) <= 12 then
                project.util.evade.missile_cc_time = awful.time - awful.buffer
                project.util.evade.missile_prio = prio
                project.util.evade.block_cast = false

                C_Timer.After(2, function()
                    project.util.evade.missile_cc_time = math.huge
                    project.util.evade.missile_prio = 0
                    project.util.evade.missile_detected = false
                    project.util.evade.block_cast = false
                end)

                awful.call("SpellCancelQueuedSpell")
                awful.call("SpellStopCasting")

                project.util.debug.alert.evade("Detected evade missile.")
            end
        end
    end)
end

awful.onEvent(function(info, event, source, dest)
    if not project.settings.priest_evade_traps then
        return
    end

    if event == "SPELL_CAST_SUCCESS" then
        local spell_id = select(12, unpack(info))
        if source.enemy then
            if missiles_to_evade[spell_id] then
                project.util.evade.missile_detected = true
                C_Timer.After(2, function()
                    project.util.evade.missile_cc_time = math.huge
                    project.util.evade.missile_prio = 0
                    project.util.evade.missile_detected = false
                    project.util.evade.block_cast = false
                end)
            end
        end
    end
end)