local Unlocker, awful, project = ...

-- best_enemy_target
awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_circle_best_enemy_target then
        return
    end

    if not project.util.enemy.bestTarget then
        return
    end

    local x, y, z = project.util.enemy.bestTarget.position()
    draw:SetColor(255, 0, 0, 255)
    draw:Outline(x, y, z, 2)
end)

-- best_friend_target
awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_circle_best_friend_target then
        return
    end

    if not project.util.friend.bestTarget then
        return
    end

    local x, y, z = project.util.friend.bestTarget.position()

    if not project.util.friend.bestTarget.los then
        draw:SetColor(128, 0, 128, 255)
    else
        draw:SetColor(0, 255, 0, 255)
    end
    draw:Outline(x, y, z, 2)
end)