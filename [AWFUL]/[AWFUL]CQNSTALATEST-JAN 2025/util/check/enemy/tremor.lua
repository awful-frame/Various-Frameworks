local Unlocker, awful, project = ...

project.util.check.enemy.tremor = function()
    if not project.util.enemy.existing_classes[project.util.id.class.SHAMAN] then
        return nil
    end

    local result = awful.totems.find(function(totem)
        return totem.id == 5913
                and totem.creator.enemy
                and totem.distanceTo(awful.player) < 30
    end)

    return result
end
