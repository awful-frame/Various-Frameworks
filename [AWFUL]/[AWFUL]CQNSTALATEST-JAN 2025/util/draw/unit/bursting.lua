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

    if not awful.arena then
        return
    end

    if project.util.enemy.total_cds and project.util.enemy.total_cds > 0 then
        awful.enemies.loop(function(enemy)
            if enemy.healer then
                return
            end

            if enemy.dist > project.util.check.player.range() then
                return
            end

            local total = project.util.check.target.cooldowns(enemy.target, enemy).total
            if total == 0 then
                return
            end

            local x, y, z = enemy.position()
            local txt = awful.textureEscape(240443, 20, "0:20")

            draw:Text(txt, font, x, y, z)
        end)
    end

    if project.util.friend.total_cds and project.util.friend.total_cds > 0 then
        awful.group.loop(function(friend)
            if friend.healer then
                return
            end

            local total = project.util.check.target.cooldowns(friend.target, friend).total
            if total == 0 then
                return
            end

            local x, y, z = friend.position()
            local txt = awful.textureEscape(240443, 20, "0:20")

            draw:Text(txt, font, x, y, z)
        end)
    end
end)