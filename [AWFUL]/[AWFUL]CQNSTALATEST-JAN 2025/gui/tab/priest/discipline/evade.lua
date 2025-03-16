local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end


if not project.gui then
    return
end

if not project.gui.priest_discipline_group then
    return
end

local priest_evade = project.gui.priest_discipline_group:Tab("Evade")

priest_evade:Checkbox({
    text = "Enable Evade",
    var = "priest_evade_enabled",
    default = true
})

priest_evade:Text({
    text = awful.colors.red .. "_________________________________",
})

priest_evade:Checkbox({
    text = "Evade casting",
    var = "priest_evade_casting",
    default = true,
    tooltip = "Polymorph, Fear, Chaos Bolt, etc."
})

priest_evade:Checkbox({
    text = "Evade prediction",
    var = "priest_evade_prediction",
    default = true,
    tooltip = "Hammer of Justice, Psychic Scream, etc. This might not work everytime, disable it if you find it annoying."
})

priest_evade:Checkbox({
    text = "Evade traps",
    var = "priest_evade_traps",
    default = true,
    tooltip = "Freezing Trap, Diamond Ice. This enables evading the trap while it's still airborne."
})

priest_evade:Checkbox({
    text = "Evade stuff on the ground",
    var = "priest_evade_triggers",
    default = true,
    tooltip = "Freezing Trap, Binding Shot, Sigil of Misery, Capacitor Totem, etc."
})

priest_evade:Text({
    text = awful.colors.red .. "_________________________________",
})

local fadeTxt = awful.textureEscape(project.priest.spells.fade.id, 20, "0:15")
priest_evade:Checkbox({
    text = fadeTxt .. "Fade",
    var = "priest_evade_fade",
    default = true,
})

local deathTxt = awful.textureEscape(project.priest.spells.death.id, 20, "0:15")
priest_evade:Checkbox({
    text = deathTxt .. "Shadow Word: Death",
    var = "priest_evade_death",
    default = true,
})