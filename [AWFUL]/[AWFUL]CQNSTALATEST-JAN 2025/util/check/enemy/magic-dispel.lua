local Unlocker, awful, project = ...

local dispels = {
    [project.util.id.class.PRIEST] = project.util.id.spell.PURIFY,
    [project.util.id.class.DRUID] = project.util.id.spell.NATURES_CURE,
    [project.util.id.class.SHAMAN] = project.util.id.spell.PURIFY_SPIRIT,
    [project.util.id.class.PALADIN] = project.util.id.spell.CLEANSE,
    [project.util.id.class.EVOKER] = project.util.id.spell.NATURALIZE,
    [project.util.id.class.MONK] = project.util.id.spell.DETOX,
}

local magic_dispel_result_cache
local last_cache_time = 0
local CACHE_DURATION = 0.2

project.util.check.enemy.magic_dispel = function()
    if awful.time - last_cache_time < CACHE_DURATION then
        return magic_dispel_result_cache
    end

    local result = awful.enemies.find(function(enemy)
        if not enemy
                or enemy.dead
                or not enemy.player
                or not enemy.healer
                or enemy.cc
        then
            return
        end

        local dispel = dispels[enemy.class3]
        if not dispel then
            return
        end

        if enemy.cooldown(dispel) > 2 then
            return
        end

        return true
    end)

    magic_dispel_result_cache = result
    last_cache_time = awful.time
    return result
end
