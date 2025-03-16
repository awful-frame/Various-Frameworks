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

local priest_ramp = project.gui.priest_discipline_group:Tab("Ramp Mode")

priest_ramp:Text({
    text = "Small Ramp:  " .. awful.colors.red .. "/cqnsta ramp",
})

priest_ramp:Text({
    text = "Rapture Ramp: " .. awful.colors.red .. "/cqnsta rampture",
})

priest_ramp:Text({
    text = awful.colors.red .. "_________________________________",
})

local summonInfernal = awful.textureEscape(1122, 20, "0:15")
priest_ramp:Checkbox({
    text = summonInfernal .. "Auto Ramp based on DBM timers",
    var = "priest_auto_ramp",
    default = true,
    tooltip = "Auto ramps based on DBM timers of important boss abilities."
})

local raptureTxt = awful.textureEscape(project.priest.spells.rapture.id, 20, "0:15")
priest_ramp:Checkbox({
    text = raptureTxt .. "Auto Ramp only with Rapture",
    var = "priest_auto_ramp_only_rapture",
    default = true,
    tooltip = "I recommend disabling this only for heroic/mythic raids."
})

local alterTimeTxt = awful.textureEscape(108978, 20, "0:15")
priest_ramp:Checkbox({
    text = alterTimeTxt .. "Show estimated time",
    var = "priest_ramp_time",
    default = false,
    tooltip = "The estimated time is calculated on the actual GCD (takes haste into consideration). It shows how long it will take to ramp everyone up and cast the first damage spell."
})



