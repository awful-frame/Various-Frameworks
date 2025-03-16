local Unlocker, awful, project = ...

if not project.subscription.is_active() then
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
