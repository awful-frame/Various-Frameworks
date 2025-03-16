local Unlocker, awful, project = ...

project.util.check.enemy.tremor = function()
    return awful.totems.find(function(totem)
        return totem.id == 5913
                and totem.creator.enemy
                and totem.distanceTo(awful.player) < 30
    end)
end