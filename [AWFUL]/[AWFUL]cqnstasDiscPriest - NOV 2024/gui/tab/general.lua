local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~=2 then
    return
end

if not project.gui then
    return
end

local general = project.gui:Tab("General")

general:Checkbox({
    text = "Auto select best enemy target",
    var = "general_auto_target",
    default = true,
    tooltip = "Automatically sets the best enemy target. I recommend to keep this on."
})

general:Checkbox({
    text = "Stomp enemy totems",
    var = "general_auto_stomp",
    default = true,
})

local healthstoneTxt = awful.textureEscape(awful.Spell(6262).id, 20, "0:15")
general:Checkbox({
    text = healthstoneTxt .. "Healthstone",
    var = "general_auto_hs",
    default = true,
})