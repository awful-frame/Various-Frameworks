local Unlocker, awful, project = ...

project.util.thresholds.buff = function()
    local cast_remains = awful.player.castRemains or 0
    local channel_remains = awful.player.channelRemains or 0
    return 2 + awful.buffer + cast_remains + channel_remains
end
