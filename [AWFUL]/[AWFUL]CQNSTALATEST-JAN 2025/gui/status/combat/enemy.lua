local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end

if not project.gui then
    return
end

if not awful.DevMode then
    return
end

local enemy_combat_status = project.gui:StatusFrame({
    fontSize = 10,
    colors = {
        background = { 21, 21, 21, 0.45 },
    },
    column = true
})

enemy_combat_status:String({
    var = "enemy_target",
})

enemy_combat_status:String({
    var = "enemy_target_method",
})

enemy_combat_status:String({
    var = "",
})

enemy_combat_status:String({
    var = "enemy_combat_danger",
})

enemy_combat_status:String({
    var = "enemy_combat_tot_all",
})

enemy_combat_status:String({
    var = "",
})

enemy_combat_status:String({
    var = "enemy_combat_total",
})

enemy_combat_status:String({
    var = "enemy_combat_melee",
})

enemy_combat_status:String({
    var = "enemy_combat_ranged",
})

enemy_combat_status:String({
    var = "enemy_combat_cd_total",
})

enemy_combat_status:String({
    var = "enemy_combat_cd_players",
})

enemy_combat_status:String({
    var = "enemy_combat_cd_big",
})

enemy_combat_status:String({
    var = "enemy_combat_cd_sm",
})

enemy_combat_status:String({
    var = "enemy_combat_def",
})

enemy_combat_status:String({
    var = "enemy_combat_def_dr",
})

enemy_combat_status:String({
    var = "enemy_combat_def_best",
})

enemy_combat_status:String({
    var = "",
})

enemy_combat_status:String({
    var = "",
})