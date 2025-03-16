local Unlocker, awful, project = ...

project.util.check.scenario.type = function()
    if awful.instanceType2 == project.util.id.instance.PVP
            or awful.instanceType2 == project.util.id.instance.ARENA then
        return "pvp"
    end

    if project.util.enemy.totalPlayers == 0 then
        return "pve"
    end

    return "pvp"
end