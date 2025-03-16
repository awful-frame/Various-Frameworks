local Unlocker, awful, project = ...

-- best_enemy_target
awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_path_best_enemy_target then
        return
    end

    if not project.util.enemy.bestTarget then
        return
    end

    if not awful.player then
        return
    end

    local x1, y1, z1 = awful.player.position()
    local x2, y2, z2 = project.util.enemy.bestTarget.position()

    draw:SetColor(255, 0, 0, 255)
    draw:Line(x1, y1, z1, x2, y2, z2, project.util.check.player.range())
end)

-- best_friend_target
awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_path_best_friend_target then
        return
    end

    if not awful.player then
        return
    end

    if not project.util.friend.bestTarget then
        return
    end

    awful.fgroup.loop(function(friend)
        if friend.guid == awful.player.guid then
            return
        end

        if not awful.arena and friend.guid ~= project.util.friend.bestTarget.guid then
            return
        end

        local x1, y1, z1 = awful.player.position()
        local x2, y2, z2 = friend.position()

        if not friend.los then
            draw:SetColor(128, 0, 128, 255)
        else
            draw:SetColor(0, 255, 0, 255)
        end

        draw:Line(x1, y1, z1, x2, y2, z2, project.util.check.player.range())
    end)
end)