local Unlocker, awful, project = ...

project.util.thresholds.buff = function()
    return 1 + awful.spellCastBuffer + awful.buffer + awful.player.castRemains + awful.player.channelRemains
end