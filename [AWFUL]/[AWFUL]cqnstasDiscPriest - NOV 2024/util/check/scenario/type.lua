local Unlocker, awful, project = ...

project.util.check.scenario.type = function()
    if awful.instanceType2 == "pvp"
            or awful.instanceType2 == "arena" then
        return "pvp"
    end

    if project.util.enemy.totalPlayers == 0 then
        return "pve"
    end

    return "pvp"
end