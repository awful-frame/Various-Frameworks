local Unlocker, awful, project = ...

local function is_enemy_fearable(enemy)
    if not enemy then
        return
    end

    if project.util.check.scenario.type() == "pvp" then
        if not enemy.player then
            return
        end
    end

    if enemy.speed > 15 then
        return
    end

    if enemy.dead then
        return
    end

    if not enemy.inCombat then
        return
    end

    if enemy.immuneCC then
        return
    end

    if enemy.immuneMagicEffects then
        return
    end

    if enemy.buff("Nullifying Shroud") then
        return
    end

    if not enemy.los then
        return
    end

    if project.util.enemy.danger and enemy.disorientDR < 0.25 then
        return
    end

    if not project.util.enemy.danger and enemy.disorientDR < 0.5 then
        return
    end

    if not enemy.cc then
        if enemy.disorientDR ~= 1 and enemy.disorientDRRemains < 8 then
            return
        end
    end

    if awful.gcd then
        if enemy.ccRemains > awful.gcd + awful.spellCastBuffer + awful.buffer then
            return
        end

        if enemy.debuffRemains("Solar Beam") > awful.gcd + awful.spellCastBuffer + awful.buffer then
            return
        end
    end

    if enemy.class == "Warrior" then
        if enemy.cooldown("Berserker Shout") < 1 then
            return
        end
    end

    if enemy.class == "Priest" then
        if enemy.used("Shadow Word: Death", 1) then
            return
        end

        if enemy.buff("Phase Shift") then
            return
        end
    end

    if enemy.debuff("Scatter Shot") then
        return
    end

    if enemy.debuff("Intimidating Shot") then
        return
    end

    if enemy.debuff("Binding Shot") then
        return
    end

    local attackers = project.util.friend.attackers.get(enemy.guid)

    if project.util.enemy.totalPlayers > 2 then
        if awful.player.hasTalent("Sheer Terror") then
            if attackers.t > 1 then
                return
            end

            if attackers.m > 0 then
                return
            end
        end

        if not awful.player.hasTalent("Sheer Terror") then
            if attackers.t > 0 then
                return
            end
        end
    end

    if project.util.enemy.totalPlayers <= 2 then
        if attackers.t > 0 then
            return
        end
    end

    if project.util.check.enemy.tremor() then
        return
    end

    return true
end

project.priest.discipline.rotation.util.fearable_enemies = function()
    local dist = 6
    if awful.player.slowed then
        dist = dist - 2
    end
    local count, _, enemies = awful.enemies.around(awful.player, dist, is_enemy_fearable)

    return count, enemies
end

awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_priest_enabled then
        return
    end

    if not project.settings.draw_priest_fearable_enemies then
        return
    end

    if project.util.check.scenario.type() == "pve" then
        return
    end

    if project.priest.spells.psychicScream.cd > 2 then
        return
    end

    local txt = awful.textureEscape(project.priest.spells.psychicScream.id, 20, "0:20")
    local _, _, enemies = awful.enemies.around(awful.player, project.util.check.player.range(), is_enemy_fearable)

    enemies.loop(function(enemy)
        if not enemy.player then
            return
        end

        local should_draw = false
        if project.util.interrupt.spells[enemy.casting] then
            should_draw = true
        end

        if enemy.healer then
            should_draw = true
        end

        if enemy.target.enemy then
            local cds = project.util.check.target.cooldowns(enemy.target, enemy)
            if cds > 0 then
                should_draw = true
            end
        end

        if not enemy.losOf(awful.enemyHealer)
                and awful.arena then
            should_draw = true
        end

        if should_draw then
            local x, y, z = enemy.position()
            draw:Text(txt, font, x, y, z)
        end
    end)
end)