local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~= 2 then
    return
end

project.settings.priest_ramp = false
project.settings.priest_rampture = false

project.cmd:New(function(msg)
    if msg == "ramp" then
        if project.settings.priest_ramp then
            project.settings.priest_ramp = false
            project.settings.priest_rampture = false
        else
            project.settings.priest_ramp = true
        end
        return true
    end
end)
