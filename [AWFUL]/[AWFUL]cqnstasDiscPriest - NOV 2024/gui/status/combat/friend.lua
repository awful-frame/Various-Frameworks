local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~= 2 then
    return
end

if not project.gui then
    return
end

if not awful.DevMode then
    return
end

local friend_combat_status = project.gui:StatusFrame({
    fontSize = 10,
    colors = {
        background = { 21, 21, 21, 0.45 },
    },
    column = true
})

friend_combat_status:String({
    var = "friend_target",
})

friend_combat_status:String({
    var = "friend_target_method",
})

friend_combat_status:String({
    var = "",
})

friend_combat_status:String({
    var = "friend_combat_danger",
})

friend_combat_status:String({
    var = "friend_combat_tot_all",
})

friend_combat_status:String({
    var = "",
})

friend_combat_status:String({
    var = "friend_combat_total",
})

friend_combat_status:String({
    var = "friend_combat_melee",
})

friend_combat_status:String({
    var = "friend_combat_ranged",
})

friend_combat_status:String({
    var = "friend_combat_cd_total",
})

friend_combat_status:String({
    var = "friend_combat_cd_players",
})

friend_combat_status:String({
    var = "friend_combat_cd_big",
})

friend_combat_status:String({
    var = "friend_combat_cd_sm",
})

friend_combat_status:String({
    var = "friend_combat_def",
})

friend_combat_status:String({
    var = "friend_combat_def_dr",
})

friend_combat_status:String({
    var = "friend_combat_def_best",
})

friend_combat_status:String({
    var = "",
})

friend_combat_status:String({
    var = "",
})