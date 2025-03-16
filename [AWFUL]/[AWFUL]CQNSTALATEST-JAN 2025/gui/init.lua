local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end

local red = { 246, 74, 74, 1 }
local yellow = { 247, 242, 92, 1 }

local tertiary = { 246, 74, 74, 0 }
local bg = { 21, 21, 21, 0.45 }

project.gui, project.settings, project.cmd = awful.UI:New("cqnsta", {
    title = "[CQNSTA'S ROTATIONS]",
    show = true,
    defaultTab = "Info",
    colors = {
        title = red,
        primary = yellow,
        accent = red,

        tertiary = tertiary,
        background = bg,
    }
})
