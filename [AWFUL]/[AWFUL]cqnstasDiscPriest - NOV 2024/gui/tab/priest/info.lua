local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~= 2 then
    return
end

if not project.gui then
    return
end

if not project.gui.priest_group then
    return
end

local priest_info = project.gui.priest_group:Tab("Info")

priest_info:Text({
    text = "I highly recommend keeping the default settings and leaving all cooldowns enabled."
})

priest_info:Text({
    text = awful.colors.red .. "_________________________________",
})

priest_info:Text({
    text = ""
})

priest_info:Text({
    text = "The cooldowns are used smartly. It’s not just about some HP thresholds, but it also takes into consideration what's happening around you to decide when to use specific spells."
})

priest_info:Text({
    text = ""
})

priest_info:Text({
    text = awful.colors.red .. "_________________________________",
})

priest_info:Text({
    text = ""
})

priest_info:Text({
    text = "Ultimate Penitence doesn’t get much use right now, except in a few specific situations. From my experience, it’s better to use it manually when it feels right since it’s pretty situational."
})

priest_info:Text({
    text = ""
})