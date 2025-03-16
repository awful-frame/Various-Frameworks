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

local priest_drawings = project.gui.priest_group:Tab("Drawings")

-- project.settings.draw.enabled
priest_drawings:Checkbox({
    text = "Priest Drawings",
    var = "draw_priest_enabled",
    default = true
})

priest_drawings:Text({
    text = awful.colors.red .. "_________________________________",
})

-- project.settings.draw_priest_fearable_enemies
local psychicScreamTxt = awful.textureEscape(project.priest.spells.psychicScream.id, 20, "0:15")
priest_drawings:Checkbox({
    text = psychicScreamTxt .. "Psychic Scream",
    var = "draw_priest_fearable_enemies",
    default = true,
    tooltip = "Displays a fear icon on enemies within range that the rotation recommends as valid fear targets."
})