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

local priest_leap_of_faith = project.gui.priest_group:Tab("Leap of Faith")

local leap_of_faith_txt = awful.textureEscape(project.priest.spells.leapOfFaith.id, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = leap_of_faith_txt .. "Leap of Faith",
    var = "priest_leap_of_faith",
    default = true,
})

priest_leap_of_faith:Text({
    text = awful.colors.red .. "_________________________________",
})

local death_grip_txt = awful.textureEscape(191650, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = death_grip_txt .. "Death Grip",
    var = "priest_leap_of_faith_death_grip",
    default = true,
    tooltip = "Pull allies that have been gripped."
})

local abomination_limb_txt = awful.textureEscape(315443, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = abomination_limb_txt .. "Abomination Limb",
    var = "priest_leap_of_faith_abomination_limb",
    default = true,
    tooltip = "Pull allies out of Abomination Limb."
})

local snowdrift_txt = awful.textureEscape(389214, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = snowdrift_txt .. "Snowdrift",
    var = "priest_leap_of_faith_snowdrift",
    default = true,
    tooltip = "Pull allies out of Snowdrift."
})

local kidney_shot_txt = awful.textureEscape(408, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = kidney_shot_txt .. "Stunned",
    var = "priest_leap_of_faith_stunned",
    default = true,
    tooltip = "Pull stunned allies."
})

local imp_txt = awful.textureEscape(688, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = imp_txt .. "Casters from Melees",
    var = "priest_leap_of_faith_casters",
    default = true,
    tooltip = "Pull casters from melee enemies when in danger."
})

local capacitor_totem_txt = awful.textureEscape(192058, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = capacitor_totem_txt .. "Ground Effects (Capacitor/Sigil)",
    var = "priest_leap_of_faith_ground_effects",
    default = true,
    tooltip = "Pull allies out of ground effects like Capacitor Totem or Sigil of Misery."
})

local shadowfury_txt = awful.textureEscape(30283, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = shadowfury_txt .. "AoE Casting Spells",
    var = "priest_leap_of_faith_aoe_casting_spells",
    default = true,
    tooltip = "Pull allies targeted by AoE spells like Shadowfury, Fists of Fury, Convoke the Spirits, or Mass Dispel."
})

local lightning_lasso_txt = awful.textureEscape(204437, 20, "0:15")
priest_leap_of_faith:Checkbox({
    text = lightning_lasso_txt .. "Targeted Casting Spells",
    var = "priest_leap_of_faith_targeted_casting_spells",
    default = true,
    tooltip = "Pull allies targeted by CC (e.g., Polymorph, Fear) or damage spells (e.g., Chaos Bolt, Lightning Lasso) when we are out of range or LoS of the enemy."
})
