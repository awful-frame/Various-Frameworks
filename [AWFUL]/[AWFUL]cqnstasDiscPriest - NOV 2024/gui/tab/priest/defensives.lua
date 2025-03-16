local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~=2 then
    return
end

if not project.gui then
    return
end

if not project.gui.priest_group then
    return
end

local priest_defensives = project.gui.priest_group:Tab("Defensives")

priest_defensives:Checkbox({
    text = "Defensives CDs",
    var = "priest_defensives_enabled",
    default = true
})

priest_defensives:Text({
    text = awful.colors.red .. "_________________________________",
})

local desperatePrayerTxt = awful.textureEscape(project.priest.spells.desperatePrayer.id, 20, "0:15")
priest_defensives:Checkbox({
    text = desperatePrayerTxt .. "Desperate Prayer",
    var = "priest_defensives_desperate_prayer",
    default = true,
})

local fadeTxt = awful.textureEscape(project.priest.spells.fade.id, 20, "0:15")
priest_defensives:Checkbox({
    text = fadeTxt .. "Fade",
    var = "priest_defensives_fade",
    default = true,
})
