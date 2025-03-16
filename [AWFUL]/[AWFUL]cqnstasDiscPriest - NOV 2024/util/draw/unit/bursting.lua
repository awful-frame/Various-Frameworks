local Unlocker, awful, project = ...

local font = awful.createFont(8, "OUTLINE")

awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_bursting then
        return
    end

    awful.enemies.loop(function(enemy)
        if enemy.healer then
            return
        end

        if enemy.dist > project.util.check.player.range() then
            return
        end

        local total = project.util.check.target.cooldowns(enemy.target, enemy)
        if total == 0 then
            return
        end

        local x, y, z = enemy.position()
        local txt = awful.textureEscape(240443, 20, "0:20")

        draw:Text(txt, font, x, y, z)
    end)

    awful.group.loop(function(friend)
        if friend.healer then
            return
        end

        if friend.dist > project.util.check.player.range() then
            return
        end

        local total = project.util.check.target.cooldowns(friend.target, friend)
        if total == 0 then
            return
        end

        local x, y, z = friend.position()
        local txt = awful.textureEscape(291526, 20, "0:20")

        draw:Text(txt, font, x, y, z)
    end)
end)