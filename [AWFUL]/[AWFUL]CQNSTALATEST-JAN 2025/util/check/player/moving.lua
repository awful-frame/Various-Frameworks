local Unlocker, awful, project = ...

project.util.last_moving_event_time = awful.time

project.util.check.player.moving_for = function(seconds)
    if not awful.player.moving then
        return
    end
    return awful.time - project.util.last_moving_event_time >= seconds
end

awful.onEvent(function()
    project.util.last_moving_event_time = awful.time
end, "PLAYER_STARTED_MOVING")
