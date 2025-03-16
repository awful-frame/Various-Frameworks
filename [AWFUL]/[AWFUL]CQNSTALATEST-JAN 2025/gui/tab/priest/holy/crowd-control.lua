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

local priest_cc = project.gui.priest_holy_group:Tab("Crowd Control")

priest_cc:Checkbox({
    text = "Crowd Control",
    var = "priest_cc_enabled",
    default = true
})

priest_cc:Text({
    text = awful.colors.red .. "_________________________________",
})

local psychicScreamTxt = awful.textureEscape(project.priest.spells.psychicScream.id, 20, "0:15")
priest_cc:Checkbox({
    text = psychicScreamTxt .. "Psychic Scream",
    var = "priest_cc_psychic_scream",
    default = true,
})

priest_cc:Text({
    text = awful.colors.red .. "_________________________________",
})

priest_cc:Checkbox({
    text = psychicScreamTxt .. ">=2 Enemies",
    var = "priest_cc_psychic_scream_2ormore",
    default = true,
    tooltip = "Uses Psychic Scream when there are 2 or more enemies in range that are not attacked.",
})

priest_cc:Checkbox({
    text = psychicScreamTxt .. "Interrupt",
    var = "priest_cc_psychic_scream_interrupt",
    default = true,
    tooltip = "Uses Psychic Scream to interrupt important abilities when friendly players are in danger or to avoid CC when evading spells are on CD",
})

priest_cc:Checkbox({
    text = psychicScreamTxt .. "Bursting Enemies",
    var = "priest_cc_psychic_scream_bursting",
    default = true,
    tooltip = "Uses Psychic Scream on bursting enemies that are not the main target.",
})

priest_cc:Checkbox({
    text = psychicScreamTxt .. "Out of LoS",
    var = "priest_cc_psychic_scream_los",
    default = true,
    tooltip = "Uses Psychic Scream on enemies that are not attacked and out of los or ranging from enemy healer.",
})

priest_cc:Checkbox({
    text = psychicScreamTxt .. "Enemy Healer",
    var = "priest_cc_psychic_scream_healer",
    default = true,
})

priest_cc:Text({
    text = awful.colors.red .. "_________________________________",
})

local mindControlTxt = awful.textureEscape(project.priest.spells.mindControl.id, 20, "0:15")
priest_cc:Checkbox({
    text = mindControlTxt .. "Mind Control",
    var = "priest_cc_mind_control",
    default = true,
})

priest_cc:Text({
    text = awful.colors.red .. "_________________________________",
})

priest_cc:Checkbox({
    text = mindControlTxt .. "Bursting Enemies",
    var = "priest_cc_mind_control_bursting",
    default = true,
    tooltip = "Uses Mind Control on bursting enemies that are not attacked.",
})

priest_cc:Checkbox({
    text = mindControlTxt .. "Enemy Healer",
    var = "priest_cc_mind_control_healer",
    default = true,
})

