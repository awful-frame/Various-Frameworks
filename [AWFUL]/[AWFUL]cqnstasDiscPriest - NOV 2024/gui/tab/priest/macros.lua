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

local priest_macros = project.gui.priest_group:Tab("Macros")

priest_macros:Text({
    text = "I don’t provide specific macros, but I highly recommend to create manual cast macros using:",
})

priest_macros:Text({
    text = ""
})

priest_macros:Text({
    text = awful.colors.red .. "/username cast Void Shift",
})

priest_macros:Text({
    text = ""
})

priest_macros:Text({
    text = "For example, set up macros for all key defensive spells, Psychic Scream, Mind Control, Shadow Word: Death, Purify, and other important abilities."
})

priest_macros:Text({
    text = ""
})

priest_macros:Text({
    text = ""
})

priest_macros:Text({
    text = "The rotation will handle most abilities in optimal scenarios, but there might be niche situations where you’ll need to manually use them!"
})

priest_macros:Text({
    text = ""
})