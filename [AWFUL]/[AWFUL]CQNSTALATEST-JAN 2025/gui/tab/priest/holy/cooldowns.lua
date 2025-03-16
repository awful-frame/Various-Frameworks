local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end

if not project.gui then
    return
end

if not project.gui.priest_holy_group then
    return
end

local priest_cooldowns = project.gui.priest_holy_group:Tab("Cooldowns")

priest_cooldowns:Checkbox({
    text = "Beneficial CDs",
    var = "priest_cds_enabled",
    default = true
})

priest_cooldowns:Text({
    text = awful.colors.red .. "_________________________________",
})

local angelicFeatherTxt = awful.textureEscape(project.priest.spells.angelicFeather.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = angelicFeatherTxt .. "Self Angelic Feather",
    var = "priest_cds_angelic_feather_self",
    default = true,
})

priest_cooldowns:Checkbox({
    text = angelicFeatherTxt .. "Party Angelic Feather",
    var = "priest_cds_angelic_feather_party",
    default = true,
    tooltip = "Best to be used with Divine Feathers talent. Will automatically place feathers under party members, prioritizing melees struggling to reach the target."
})

local premonitionTxt = awful.textureEscape(project.priest.spells.premonitionOfInsight.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = premonitionTxt .. "Premonition",
    var = "priest_cds_premonition",
    default = true,
})

local archangelTxt = awful.textureEscape(project.priest.spells.archangel.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = archangelTxt .. "Archangel",
    var = "priest_cds_archangel",
    default = true,
})

local painSuppressionTxt = awful.textureEscape(project.priest.spells.painSuppression.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = painSuppressionTxt .. "Pain Suppression",
    var = "priest_cds_pain_suppression",
    default = true,
})

local barrierTxt = awful.textureEscape(project.priest.spells.powerWordBarrier.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = barrierTxt .. "Power Word: Barrier",
    var = "priest_cds_power_word_barrier",
    default = true,
})

local raptureTxt = awful.textureEscape(project.util.id.spell.RAPTURE, 20, "0:15")
priest_cooldowns:Checkbox({
    text = raptureTxt .. "Rapture",
    var = "priest_cds_rapture",
    default = true,
})

local ultimatePenitenceTxt = awful.textureEscape(project.priest.spells.ultimatePenitence.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = ultimatePenitenceTxt .. "Ultimate Penitence",
    var = "priest_cds_ultimate_penitence",
    default = true,
})

local voidShiftTxt = awful.textureEscape(project.priest.spells.voidShift.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = voidShiftTxt .. "Void Shift",
    var = "priest_cds_void_shift",
    default = true,
})

priest_cooldowns:Checkbox({
    text = voidShiftTxt .. "Trinket Void Shift",
    var = "priest_cds_trinket_void_shift",
    default = true,
})

priest_cooldowns:Text({
    text = awful.colors.red .. "_________________________________",
})

local massDispelTxt = awful.textureEscape(project.priest.spells.massDispel.id, 20, "0:15")
priest_cooldowns:Checkbox({
    text = massDispelTxt .. "Mass Dispel - Immunities",
    var = "priest_cds_mass_dispel_block",
    default = true,
})

priest_cooldowns:Checkbox({
    text = massDispelTxt .. "Mass Dispel - Ice Wall",
    var = "priest_cds_mass_dispel_ice_wall",
    default = true,
})

priest_cooldowns:Checkbox({
    text = massDispelTxt .. "Mass Dispel - Friends",
    var = "priest_cds_mass_dispel_friends",
    default = true,
    tooltip = "Will use Mass Dispel against Cyclones or other important debuffs that can be dispelled if Purify on cd. Rotation will still save Mass Dispel for Ice Block/Divine Shield even with this enabled."
})

priest_cooldowns:Text({
    text = awful.colors.red .. "_________________________________",
})

local innerLightAndShadowTxt = awful.textureEscape(project.priest.spells.inner_light_and_shadow.id, 20)
priest_cooldowns:Slider({
    text = innerLightAndShadowTxt .. "Inner Light Threshold",
    var = "priest_cds_inner_light_and_shadow_mana_threshold",
    min = 0,
    max = 100,
    step = 1,
    default = 50,
    valueType = "%",
    tooltip = "Mana threshold to switch between Inner Light and Inner Shadow."
})

