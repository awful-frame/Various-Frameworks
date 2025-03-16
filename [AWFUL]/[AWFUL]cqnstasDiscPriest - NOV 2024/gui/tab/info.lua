local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~= 2 then
    return
end

if not project.gui then
    return
end

local info = project.gui:Tab("Info")

local infoMessages = {
    awful.colors.red .. "WELCOME!",
    awful.colors.red .. "---------------------------------------------",

    awful.colors.yellow .. "To open the UI: " .. awful.colors.red .. "/cnqsta",
    awful.colors.yellow .. "Toggle rotation: " .. awful.colors.red .. "/username toggle",

    awful.colors.red .. "---------------------------------------------",

    awful.colors.orange .. "Full WASD and should be perfectly fine in any kind of scenario.",
    "",
    awful.colors.orange .. "Works with both Voidweaver and Oracle, any talent build.",

    awful.colors.red .. "---------------------------------------------",

    awful.colors.yellow .. "Have feedback, found a bug, need help with talent builds, or looking for rotation tips?",
    "",
    awful.colors.yellow .. "Feel free to reach out to me through the Discord server or through private message at: " .. awful.colors.red .. "cqnsta",
    "",
}

for _, message in ipairs(infoMessages) do
    info:Text({
        text = message
    })
end
