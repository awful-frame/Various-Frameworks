local Unlocker, awful, project = ...

local spells_used_to_evade = {
    [project.util.id.spell.FADE] = true,
    [project.util.id.spell.SHADOW_WORD_DEATH] = true,
    [project.util.id.spell.SHADOWMELD] = true,
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
    project.util.evade.block_cast = false
end

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_START" then
        local spell_id = select(12, unpack(info))
        if source.guid == awful.player.guid then
            if spells_used_to_evade[spell_id] then
                project.util.evade.reset()
            end
        end
    end
end)