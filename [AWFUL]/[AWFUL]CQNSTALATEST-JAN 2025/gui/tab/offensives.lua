local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end


if not project.gui then
    return
end

local offensives = project.gui:Tab("Offensives")

local tempered_potion_txt = awful.textureEscape(awful.Spell(431932).id, 20, "0:15")
offensives:Checkbox({
    text = tempered_potion_txt .. "Tempered Potion - Bloodlust",
    var = "offensives_tempered_potion_bloodlust",
    default = false,
    tooltip = "Rotation will use Tempered Potion when Bloodlust is active."
})

