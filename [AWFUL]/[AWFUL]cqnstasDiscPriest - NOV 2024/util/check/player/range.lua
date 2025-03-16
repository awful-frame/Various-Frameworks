 local Unlocker, awful, project = ...

project.util.check.player.range = function()
    if awful.player.hasTalent("Phantom Reach") then
        return 46
    end
    return 40
end

