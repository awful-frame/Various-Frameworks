local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end

if not project.gui then
    return
end

if awful.player.race == "Night Elf" then
    local general_evade = project.gui:Tab("Evade")

    local meldTxt = awful.textureEscape(project.util.spells.racials.shadowmeld.id, 20, "0:15")

    general_evade:Checkbox({
        text = meldTxt .. "Evade using Shadowmeld",
        var = "general_evade_enabled",
        default = true,
        tooltip = "Enables/disables auto evade using Shadowmeld"
    })

    general_evade:Text({
        text = awful.colors.red .. "_________________________________",
    })

    general_evade:Checkbox({
        text = "Evade casting",
        var = "general_evade_casting",
        default = true,
        tooltip = "Polymorph, Fear, Chaos Bolt, etc."
    })

    general_evade:Checkbox({
        text = "Evade projectiles",
        var = "general_evade_projectiles",
        default = false,
        tooltip = "Mortal Coil, Storm Bolt, etc. Only evading if max range like a normal player, but this can still be a bit too obvious"
    })
end
