local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end


if not project.gui then
    return
end

local misc = project.gui:Tab("Misc")

misc:Checkbox({
    text = "Auto select best enemy target",
    var = "misc_auto_target",
    default = true,
    tooltip = "Automatically sets the best enemy target. I recommend to keep this on."
})

misc:Checkbox({
    text = "Stomp enemy totems",
    var = "misc_stomp_totems",
    default = true,
})

misc:Text({
    text = awful.colors.red .. "_________________________________",
})

misc:Text({
    text = "",
})

misc:Text({
    text = awful.colors.yellow .. "Use this macro to block the rotation's stop moving functionality for the next 10 seconds or until used again:",
})

misc:Text({
    text = awful.colors.red .. "/cqnsta blocksm",
})

misc:Checkbox({
    text = "Stop moving",
    var = "misc_stop_moving",
    default = true,
    tooltip = "Rotation will stop you from moving to cast spells. I recommend to keep this on as casting spells at the right time provides tons of value to the rotation. If you turn this off, you will only get a notification when to stop moving, but even if you might stop moving manually, the opportunity to cast that spell might be lost already as PvP can be very fast paced."
})

misc:Slider({
    text = "Stop Moving Cooldown",
    var = "misc_stop_moving_cd",
    min = 1,
    max = 20,
    step = 1,
    default = 3,
    valueType = " seconds",
    tooltip = "Set the cooldown duration (in seconds) for stop moving. This ensures the stop moving functionality won't trigger too frequently."
})

misc:Text({
    text = "",
})

misc:Text({
    text = awful.colors.red .. "Stop moving functionality is only available in PVP.",
})

misc:Text({
    text = "",
})

misc:Text({
    text = awful.colors.red .. "Rotation will try its best to not stop in awkward moments (going for a fear, healing target is not in LoS, etc..)",
})

misc:Text({
    text = "",
})


