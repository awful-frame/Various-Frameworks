local Unlocker, awful, project = ...

local spellsUsedToEvade = {
    [project.priest.spells.fade.id] = true,
    [project.priest.spells.death.id] = true,
    [project.util.spells.racials.shadowmeld.id] = true,
}

project.util.evade.reset = function()
    if project.util.evade.casting_cc_time < math.huge then
        project.util.evade.casting_cc_time = math.huge
        project.util.evade.casting_enemy = nil
        project.util.evade.casting_prio = 0
    end

    if project.util.evade.missile_cc_time < math.huge then
        project.util.evade.missile_cc_time = math.huge
        project.util.evade.missile_prio = 0
        project.util.evade.missile_detected = false
    end

    if project.util.evade.projectile_cc_time < math.huge then
        project.util.evade.projectile_cc_time = math.huge
        project.util.evade.projectile_prio = 0
    end

    if project.util.evade.trigger_cc_time < math.huge then
        project.util.evade.trigger_cc_time = math.huge
        project.util.evade.trigger_prio = 0
        project.util.evade.trigger_detected = false
        project.util.evade.trigger_object = nil
    end

    if project.util.evade.prediction_cc_time < math.huge then
        project.util.evade.prediction_cc_time = math.huge
        project.util.evade.prediction_prio = 0
    end

    project.util.evade.holdGCD = false
end

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_START" then
        local spellID, spellName = select(12, unpack(info))
        if source.guid == awful.player.guid then
            if spellsUsedToEvade[spellID] then
                project.util.evade.reset()
            end
        end
    end
end)