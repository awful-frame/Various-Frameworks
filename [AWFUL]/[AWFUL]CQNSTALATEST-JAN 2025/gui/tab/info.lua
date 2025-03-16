local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end

if not project.gui then
    return
end

local info = project.gui:Tab("Info")

local infoMessages = {
    awful.colors.red .. "WELCOME!",
    awful.colors.red .. "---------------------------------------------",

    awful.colors.yellow .. "To open the UI: " .. awful.colors.red .. "/cqnsta",
    awful.colors.yellow .. "Toggle rotation: " .. awful.colors.red .. "/username toggle",

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
