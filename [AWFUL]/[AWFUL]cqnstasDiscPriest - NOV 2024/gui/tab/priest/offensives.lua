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

local priest_offensives = project.gui.priest_group:Tab("Offensives")

priest_offensives:Checkbox({
    text = "Offensive CDs",
    var = "priest_offensives_enabled",
    default = true
})

priest_offensives:Text({
    text = awful.colors.red .. "_________________________________",
})

local powerInfusionTxt = awful.textureEscape(project.priest.spells.powerInfusion.id, 20, "0:15")
priest_offensives:Checkbox({
    text = powerInfusionTxt .. "Buff based on class priority",
    var = "priest_offensives_bt",
    default = true,
    tooltip = "Turning this off will buff the first player that bursts, but it will still keep the class prio if two or more friends are bursting at the same time. I recommend to turn this off in Solo Shuffle/BGs to get our burst out faster and not rely that much on teammates."
})

priest_offensives:Text({
    text = awful.colors.red .. "_________________________________",
})

local darkArchangelTxt = awful.textureEscape(project.priest.spells.darkArchangel.id, 20, "0:15")
priest_offensives:Checkbox({
    text = darkArchangelTxt .. "Dark Archangel",
    var = "priest_offensives_dark_archangel",
    default = true,
})

priest_offensives:Checkbox({
    text = powerInfusionTxt .. "Power Infusion",
    var = "priest_offensives_power_infusion",
    default = true,
})

priest_offensives:Text({
    text = awful.colors.red .. "_________________________________",
})

local shadowfiendTxt = awful.textureEscape(project.priest.spells.shadowfiend.id, 20, "0:15")
priest_offensives:Checkbox({
    text = shadowfiendTxt .. "Shadowfiend",
    var = "priest_offensives_shadowfiend",
    default = true,
})

local voidTendrilsTxt = awful.textureEscape(project.priest.spells.voidTendrils.id, 20, "0:15")
priest_offensives:Checkbox({
    text = voidTendrilsTxt .. "Void Tendrils",
    var = "priest_offensives_void_tendrils",
    default = true,
})

local mindgamesTxt = awful.textureEscape(project.priest.spells.mindgames.id, 20, "0:15")
priest_offensives:Checkbox({
    text = mindgamesTxt .. "Mindgames",
    var = "priest_offensives_mindgames",
    default = true,
})

