local Unlocker, awful, project = ...

local grounding_result_cache
local grounding_last_cache_time = 0
local GROUNDING_CACHE_DURATION = 0.2

project.util.check.enemy.grounding = function()
    if grounding_result_cache ~= nil
            and (awful.time - grounding_last_cache_time) < GROUNDING_CACHE_DURATION then
        return grounding_result_cache
    end

    if not project.util.enemy.existing_classes[project.util.id.class.SHAMAN] then
        grounding_result_cache = nil
        return nil
    end

    local result = awful.totems.find(function(totem)
        return totem.id == 5925
                and totem.creator.enemy
                and totem.distanceTo(awful.player) < 30
    end)

    grounding_result_cache = result
    grounding_last_cache_time = awful.time

    return result
end
