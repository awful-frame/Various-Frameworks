local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end

if not project.gui then
    return
end

local defensives = project.gui:Tab("Defensives")

local healthstone_txt = awful.textureEscape(awful.Spell(6262).id, 20, "0:15")
defensives:Checkbox({
    text = healthstone_txt .. "Healthstone",
    var = "defensives_healthstone",
    default = true,
})

local healing_potion_txt = awful.textureEscape(awful.Spell(431416).id, 20, "0:15")
defensives:Checkbox({
    text = healing_potion_txt .. "Healing Potion",
    var = "defensives_healing_potion",
    default = true,
})