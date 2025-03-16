local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~=2 then
    return
end

if not project.gui then
    return
end

if not project.gui.admin_group then
    return
end

local alerts = project.gui.admin_group:Tab("Alerts")
alerts:Checkbox({
    text = "Enable debug alerts",
    var = "debug_alerts_enabled",
    default = false
})

alerts:Checkbox({
    text = "Enable print",
    var = "debug_alerts_print",
    default = true
})

alerts:Dropdown({
    var = "debug_alerts",
    multi = true,
    tooltip = "Choose the alerts you want to enable.",
    options = {
        { label = "INFO", value = "INFO" },
        { label = "ATTACK", value = "ATTACK" },
        { label = "HEAL", value = "HEAL" },
        { label = "BENEFICIAL", value = "BENEFICIAL" },
        { label = "DEFENSIVE", value = "DEFENSIVE" },
        { label = "OFFENSIVE", value = "OFFENSIVE" },
        { label = "EVADE", value = "EVADE" },
        { label = "DISPEL", value = "DISPEL" },
        { label = "CC", value = "CC" },
        { label = "CD", value = "CD" },
    },
    default = {
        "INFO",
        "ATTACK",
        "HEAL",
        "BENEFICIAL",
        "DEFENSIVE",
        "OFFENSIVE",
        "EVADE",
        "DISPEL",
        "CC",
        "CD"
    },
    placeholder = "Select alerts to enable",
    header = "Enabled alerts",
})

