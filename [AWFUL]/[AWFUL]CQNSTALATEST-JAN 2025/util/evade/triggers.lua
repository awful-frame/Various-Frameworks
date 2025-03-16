local Unlocker, awful, project = ...

local triggers_to_evade_spell_ids = {
    [project.util.id.spell.SIGIL_OF_MISERY] = true,
    [project.util.id.spell.RING_OF_FROST] = true,
    [project.util.id.spell.FREEZING_TRAP] = true,
    [project.util.id.spell.BINDING_SHOT] = true,
    [project.util.id.spell.CAPACITOR_TOTEM] = true,
}

local triggers_to_evade = {
    -- swd/fade
    [project.util.id.trigger.SIGIL_OF_MISERY] = {
        name = "Sigil of Misery",
        radius = 8,
        avoid = true,
        prio = 1,
        delay = 1,
        dr = project.util.id.dr.FEAR
    },
    [project.util.id.trigger.RING_OF_FROST] = {
        name = "Ring of Frost",
        radius = 6.5,
        avoid = true,
        prio = 1,
        delay = 0,
        dr = project.util.id.dr.POLY
    },

    -- fade
    [project.util.id.trigger.FREEZING_TRAP] = {
        name = "Freezing Trap",
        radius = 3,
        avoid = true,
        prio = 2,
        delay = 0,
        dr = project.util.id.dr.POLY
    },
    [project.util.id.trigger.BINDING_SHOT] = {
        name = "Binding Shot",
        radius = 5,
        avoid = false,
        prio = 2,
        delay = 0,
        dr = project.util.id.dr.STUN
    },
    [project.util.id.trigger.CAPACITOR_TOTEM] = {
        name = "Capacitor Totem",
        radius = 8,
        avoid = true,
        prio = 2,
        delay = 2,
        dr = project.util.id.dr.STUN
    },
}

local stopped = false

project.util.evade.trigger_cc_time = math.huge
project.util.evade.trigger_prio = 0
project.util.evade.trigger_object = nil
project.util.evade.trigger_detected = false
project.util.evade.holdGCD = false
project.util.evade.block_cast = false

local function evade(list)
    if not list then
        return
    end

    list.loop(function(trigger)
        local trigger_to_evade = triggers_to_evade[trigger.id]

        if not trigger_to_evade then
            return
        end

        if awful.player.buffRemains(project.util.id.spell.PRECOGNITION) > trigger_to_evade.delay then
            return
        end

        if awful.player.ccImmunityRemains > trigger_to_evade.delay then
            return
        end

        local dr = trigger_to_evade.dr
        if dr then
            if dr == project.util.id.dr.FEAR then
                if awful.player.disorientDR <= 0.25 then
                    return
                end

                if awful.player.buffRemains(project.util.id.spell.BLESSING_OF_SANCTUARY) > trigger_to_evade.delay then
                    return
                end
            end

            if dr == project.util.id.dr.POLY then
                if awful.player.incapacitateDR <= 0.25 then
                    return
                end
            end

            if dr == project.util.id.dr.STUN then
                if awful.player.stunDR <= 0.25 then
                    return
                end

                if awful.player.buffRemains(project.util.id.spell.BLESSING_OF_SANCTUARY) > trigger_to_evade.delay then
                    return
                end
            end
        end

        if trigger.dist > project.util.check.player.range() then
            return
        end

        if trigger.creator.friend then
            return
        end

        if not trigger_to_evade.avoid then
            if trigger.predictDistance(awful.spellCastBuffer) < trigger_to_evade.radius * 0.5 then
                if not stopped then
                    stopped = true
                    awful.controlMovement(1.5)
                    C_Timer.After(10, function()
                        stopped = false
                    end)
                end
                return
            end

            if trigger.dist > trigger_to_evade.radius + 1 then
                return
            end
        end

        if trigger_to_evade.avoid then
            if trigger.predictDistance(awful.spellCastBuffer) > trigger_to_evade.radius + 1 then
                return
            end
        end

        local no_phase_shift = not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) or project.priest.spells.fade.cd > trigger_to_evade.delay

        if trigger_to_evade.prio == 1
                and no_phase_shift
                and project.priest.spells.death.cd > trigger_to_evade.delay then
            return
        end

        if trigger_to_evade.prio == 2
                and no_phase_shift then
            return
        end

        trigger_to_evade.trigger = trigger
        project.util.evade.trigger_object = trigger_to_evade

        project.util.evade.trigger_cc_time = awful.time
        if trigger_to_evade.delay > 0 then
            project.util.evade.trigger_cc_time = project.util.evade.trigger_cc_time + trigger_to_evade.delay - trigger.uptime - awful.buffer - awful.spellCastBuffer
        end
        project.util.evade.trigger_prio = trigger_to_evade.prio
        project.util.evade.trigger_detected = true

        if trigger_to_evade.prio == 1 and project.priest.spells.death.cd < awful.gcd then
            project.util.evade.holdGCD = true
        end
        project.util.evade.block_cast = true

        if trigger_to_evade.delay > 0 then
            C_Timer.After(trigger_to_evade.delay + 2, function()
                project.util.evade.trigger_cc_time = math.huge
                project.util.evade.trigger_prio = 0
                project.util.evade.trigger_detected = false
                project.util.evade.trigger_object = nil
                project.util.evade.holdGCD = false
                project.util.evade.block_cast = false
            end)
        end

        project.util.debug.alert.evade("Detected evade trigger: " .. trigger_to_evade.name)
    end)
end

local function should_reset()
    local obj = project.util.evade.trigger_object
    if obj.avoid
            and obj.trigger
            and obj.radius + 0.5 < obj.trigger.dist
            and obj.radius + 2 < obj.trigger.predictDistance(0.5) then
        project.util.evade.trigger_cc_time = math.huge
        project.util.evade.trigger_prio = 0
        project.util.evade.trigger_detected = false
        project.util.evade.trigger_object = nil
        project.util.evade.holdGCD = false
        project.util.evade.block_cast = false
        project.util.debug.alert.evade("[TRIGGER] Moved out of the trigger radius.")
    end
end

project.util.evade.triggers = function()
    if not project.settings.priest_evade_triggers then
        return
    end

    if not project.util.evade.trigger_detected then
        return
    end

    if not project.util.evade.should_evade() then
        return
    end

    if project.util.evade.trigger_cc_time < math.huge then
        should_reset()
        return
    end

    evade(awful.triggers)
    evade(awful.units)
end

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" then
        local spell_id = select(12, unpack(info))
        if source.enemy then
            if triggers_to_evade_spell_ids[spell_id] then
                project.util.evade.trigger_detected = true
                C_Timer.After(10, function()
                    project.util.evade.trigger_cc_time = math.huge
                    project.util.evade.trigger_prio = 0
                    project.util.evade.trigger_detected = false
                    project.util.evade.trigger_object = nil
                end)
            end
        end
    end
end)
