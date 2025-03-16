local Unlocker, awful, project = ...

local dispels = {
    ["Priest"] = "Purify", -- Purify
    ['Druid'] = "Nature's Cure", -- Nature's Cure
    ['Shaman'] = "Purify Spirit", -- Purify Spirit
    ['Paladin'] = "Cleanse", -- Cleanse
    ['Evoker'] = "Naturalize", -- Naturalize
    ['Monk'] = "Detox", -- Detox
}

project.util.check.enemy.magic_dispel = function()
    return awful.enemies.find(function(enemy)
        if not enemy
                or enemy.dead
                or not enemy.player
                or not enemy.healer
                or enemy.cc
        then
            return
        end

        local dispel = dispels[enemy.class]
        if not dispel then
            return
        end

        if enemy.cooldown(dispel) > 2 then
            return
        end

        return true
    end)
end
