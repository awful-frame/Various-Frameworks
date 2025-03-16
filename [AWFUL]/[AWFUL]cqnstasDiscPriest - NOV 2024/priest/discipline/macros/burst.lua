local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~= 2 then
    return
end

project.settings.priest_burst = false

project.cmd:New(function(msg)
    if msg == "burst" then
        if project.settings.priest_burst then
            project.settings.priest_burst = false
        else
            project.settings.priest_burst = true
        end
        return true
    end
end)
