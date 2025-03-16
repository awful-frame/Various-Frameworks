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

local priest_drawings = project.gui.priest_discipline_group:Tab("Drawings")

-- project.settings.draw.enabled
priest_drawings:Checkbox({
    text = "Priest Drawings",
    var = "draw_priest_enabled",
    default = true
})

priest_drawings:Text({
    text = awful.colors.red .. "_________________________________",
})

-- project.settings.draw_priest_fear_icon
local psychic_scream = awful.textureEscape(project.priest.spells.psychicScream.id, 20, "0:15")
priest_drawings:Checkbox({
    text = psychic_scream .. "Psychic Scream - Target",
    var = "draw_priest_fear_icon",
    default = true,
    tooltip = "Displays Psychic Scream icon on enemies within range that the rotation recommends as valid fear targets."
})

-- project.settings.draw_priest_fear_range
priest_drawings:Checkbox({
    text = psychic_scream .. "Psychic Scream - Range",
    var = "draw_priest_fear_range",
    default = true,
    tooltip = "Displays Psychic Scream range when there is at least one enemy that rotation recommends to fear."
})

-- project.settings.draw_priest_radiance_range
local radiance_txt = awful.textureEscape(project.priest.spells.radiance.id, 20, "0:15")
priest_drawings:Checkbox({
    text = radiance_txt .. "Radiance - Icon",
    var = "draw_priest_radiance_icon",
    default = false,
    tooltip = "Displays Radiance icon above friends in our party that are within Radiance range."
})

priest_drawings:Checkbox({
    text = radiance_txt .. "Radiance - Range",
    var = "draw_priest_radiance_range",
    default = false,
    tooltip = "Displaying Radiance range (30 yards) helps you position yourself for optimal healing output. In PvE, it is crucial to always stay within Radiance range of your party."
})