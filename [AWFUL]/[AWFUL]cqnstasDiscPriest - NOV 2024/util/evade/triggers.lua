local Unlocker, awful, project = ...

local triggers_to_evade = {
    -- swd/fade
    [187651] = {
        name = "Freezing Trap",
        radius = 3,
        spellId = 187650,
        avoid = true,
        prio = 2,
        delay = 0,
        dr = "poly"
    },
    [207684] = {
        name = "Sigil of Misery",
        radius = 8,
        spellId = 207684,
        avoid = true,
        prio = 1,
        delay = 1,
        dr = "fear"
    },
    [44199] = {
        name = "Ring of Frost",
        radius = 6.5,
        spellId = 113724,
        avoid = true,
        prio = 1,
        delay = 0,
        dr = "poly"
    },

    -- fade
    [109248] = {
        name = "Binding Shot",
        radius = 5,
        spellId = 109248,
        avoid = false,
        prio = 2,
        delay = 0,
        dr = "stun"
    },
    [61245] = {
        name = "Capacitor Totem",
        radius = 8,
        spellId = 192058,
        avoid = true,
        prio = 2,
        delay = 2,
        dr = "stun"
    },
}

local stopped = false

project.util.evade.trigger_cc_time = math.huge
project.util.evade.trigger_prio = 0
project.util.evade.trigger_object = nil
project.util.evade.trigger_detected = false
project.util.evade.holdGCD = false

local function evade(list)
    if not list then
        return
    end

    list.loop(function(trigger)
        local trigger_to_evade = triggers_to_evade[trigger.id]

        if not trigger_to_evade then
            return
        end

        local dr = trigger_to_evade.dr
        if dr then
            if dr == "fear" then
                if awful.player.disorientDR <= 0.25 then
                    return
                end
            end

            if dr == "poly" then
                if awful.player.incapacitateDR <= 0.25 then
                    return
                end
            end

            if dr == "stun" then
                if awful.player.stunDR <= 0.25 then
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
                    awful.controlMovement(2)
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

        if trigger_to_evade.prio == 1
                and project.priest.spells.fade.cd > 0
                and project.priest.spells.death.cd > 2 then
            return
        end

        if trigger_to_evade.prio == 2
                and project.priest.spells.fade.cd > 0 then
            return
        end

        trigger_to_evade.trigger = trigger
        project.util.evade.trigger_object = trigger_to_evade

        project.util.evade.trigger_cc_time = awful.time
        if trigger_to_evade.delay > 0 then
            project.util.evade.trigger_cc_time = project.util.evade.trigger_cc_time + trigger_to_evade.delay - trigger.uptime - awful.spellCastBuffer - awful.buffer
        end
        project.util.evade.trigger_prio = trigger_to_evade.prio
        project.util.evade.trigger_detected = true
        project.util.evade.holdGCD = true

        if trigger_to_evade.delay > 0 then
            C_Timer.After(trigger_to_evade.delay + 2, function()
                project.util.evade.trigger_cc_time = math.huge
                project.util.evade.trigger_prio = 0
                project.util.evade.trigger_detected = false
                project.util.evade.trigger_object = nil
                project.util.evade.holdGCD = false
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
        project.util.debug.alert.evade("Moved out of the trigger radius.")
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
        local spellID, spellName = select(12, unpack(info))
        if source.enemy then
            for _, trigger_to_evade in pairs(triggers_to_evade) do
                if trigger_to_evade.spellId == spellID then
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
    end
end)
