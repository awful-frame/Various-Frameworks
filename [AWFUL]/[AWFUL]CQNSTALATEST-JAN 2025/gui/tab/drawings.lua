local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end


if not project.gui then
    return
end

local drawings = project.gui:Tab("Drawings")

-- project.settings.draw_enabled
drawings:Checkbox({
    text = "Drawings",
    var = "draw_enabled",
    default = true
})

drawings:Text({
    text = awful.colors.red .. "_________________________________",
})
-- project.settings.draw_circle_best_friend_target
drawings:Checkbox({
    text = "Circle - Best Healing Target",
    var = "draw_circle_best_friend_target",
    default = true,
    tooltip = "Displays the best healing target the rotation recommends by drawing a green outlined circle around them."
})

-- project.settings.draw_circle_best_enemy_target
drawings:Checkbox({
    text = "Circle - Best Enemy Target",
    var = "draw_circle_best_enemy_target",
    default = true,
    tooltip = "Displays the best enemy target the rotation recommends by drawing a red outlined circle around them."
})

drawings:Text({
    text = awful.colors.red .. "_________________________________",
})

-- project.settings.draw_path_best_friend_target
drawings:Checkbox({
    text = "Path - Allies / Best Healing Target",
    var = "draw_path_best_friend_target",
    default = true,
    tooltip = "Displays a path from the player to allies if in arena or to best healing target if outside. Green in LoS, purple out of LoS"
})

-- project.settings.draw_path_best_enemy_target
drawings:Checkbox({
    text = "Path - Best Enemy Target",
    var = "draw_path_best_enemy_target",
    default = true,
    tooltip = "Displays a path from the player to the best enemy target the rotation recommends."
})

drawings:Text({
    text = awful.colors.red .. "_________________________________",
})

-- project.settings.draw_triggers
drawings:Checkbox({
    text = "Area-based effects",
    var = "draw_triggers",
    default = true,
    tooltip = "Displays area-based effects like Flare, Traps, Binding Shots when within range."
})

-- project.settings.draw_objects
drawings:Checkbox({
    text = "Relevant objects",
    var = "draw_objects",
    default = true,
    tooltip = "Displays interactable objects such as Soulwell, Refreshment Table, and Demonic Gateway when within range."
})

-- project.settings.draw_units
drawings:Checkbox({
    text = "Relevant totems",
    var = "draw_units",
    default = true,
    tooltip = "Displays specific totems along with their effect ranges when they are within range."
})

-- project.settings.draw_bursting
drawings:Checkbox({
    text = "Bursting players",
    var = "draw_bursting",
    default = true,
    tooltip = "Displays icons on friendly and enemy bursting players when they are within range."
})
