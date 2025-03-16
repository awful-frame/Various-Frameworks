local Unlocker, awful, project = ...

project.util.pause = {}
project.util.pause.time = 0

project.util.pause.xxl = function()
    awful.call("ClearFocus")
    project.util.pause.time = awful.time + awful.delays.xxl.now;
end


awful.onEvent(project.util.pause.xxl, "ARENA_PREP_OPPONENT_SPECIALIZATIONS")
awful.onEvent(project.util.pause.xxl, "PLAYER_ENTERING_WORLD")
awful.onEvent(project.util.pause.xxl, "PLAYER_LEAVING_WORLD")