local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end

project.settings.priest_burst = false

project.cmd:New(function(msg)
    if msg == "blocksm" then
        if project.util.cast.stop_moving_block then
            awful.alert(awful.colors.green .. "STOP MOVING - UNBLOCKED", 322712)
            project.util.cast.stop_moving_block = false
            return
        end

        project.util.cast.stop_moving_block = true
        C_Timer.After(10, function()
            if project.util.cast.stop_moving_block then
                awful.alert(awful.colors.green .. "STOP MOVING - UNBLOCKED", 322712)
            end
            project.util.cast.stop_moving_block = false
        end)

        awful.alert(awful.colors.red .. "STOP MOVING - BLOCKED FOR 10S", 322712)
    end
end)
