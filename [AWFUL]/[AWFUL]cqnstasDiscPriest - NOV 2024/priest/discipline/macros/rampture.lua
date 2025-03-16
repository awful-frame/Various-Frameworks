local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~= 2 then
    return
end

project.settings.priest_ramp = false
project.settings.priest_rampture = false

project.cmd:New(function(msg)
    if msg == "rampture" then
        if project.settings.priest_ramp then
            project.settings.priest_ramp = false
            project.settings.priest_rampture = false
        else
            if project.priest.spells.rapture.cd > awful.gcd then
                project.settings.priest_ramp = true
                return
            end
            project.settings.priest_ramp = true
            project.settings.priest_rampture = true
        end
        return true
    end
end)
