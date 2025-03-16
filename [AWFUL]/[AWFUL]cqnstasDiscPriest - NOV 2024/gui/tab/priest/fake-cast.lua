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

local priest_fake_cast = project.gui.priest_group:Tab("Fake Cast")

priest_fake_cast:Checkbox({
    text = "Fake Cast",
    var = "general_fake_cast_enabled",
    default = true
})

priest_fake_cast:Text({
    text = awful.colors.red .. "_________________________________",
})

local ultimatePenitenceTxt = awful.textureEscape(project.priest.spells.ultimatePenitence.id, 20, "0:15")
priest_fake_cast:Checkbox({
    text = ultimatePenitenceTxt .. "Ultimate Penitence",
    var = "priest_fake_cast_ultimate_penitence",
    default = true,
})

local flashHealTxt = awful.textureEscape(project.priest.spells.flashHeal.id, 20, "0:15")
priest_fake_cast:Checkbox({
    text = flashHealTxt .. "Flash Heal",
    var = "priest_fake_cast_flash_heal",
    default = true,
})

local mind_blast_txt = awful.textureEscape(project.priest.spells.mindBlast.id, 20, "0:15")
priest_fake_cast:Checkbox({
    text = mind_blast_txt .. "Mind Blast",
    var = "priest_fake_cast_mind_blast",
    default = true,
})

priest_fake_cast:Text({
    text = awful.colors.red .. "_________________________________",
})

priest_fake_cast:Slider({
    text = "Fake Cast Cooldown",
    var = "priest_fake_cast_cooldown",
    min = 3,
    max = 15,
    step = 1,
    default = 8,
    valueType = " seconds",
    tooltip = "Set the cooldown duration (in seconds) for fake casting. This ensures the fake cast functionality won't trigger too frequently."
})

