local Unlocker, awful, project = ...

local function is_viable_enemy(enemy)
    if enemy.dead then
        return
    end

    if not enemy.los then
        return
    end

    if enemy.immuneMagicDamage then
        return
    end

    if enemy.dist > project.util.check.player.range() then
        return
    end

    if enemy.bcc then
        return
    end

    if enemy.buff("Spell Reflection")
            or enemy.buff("Nether Ward") then
        return
    end

    return true
end

project.priest.discipline.rotation.util.find_best_target_to_ptw_penance_spread = function(type)
    local main_target = awful.target

    if main_target.hp < 50
            or awful.player.buff("Power of the Dark Side") then
        return main_target
    end

    local enemy_with_most_enemies_around
    local most_enemies_around = 0

    local mt_en = 0

    awful.enemies.loop(function(enemy)
        if not is_viable_enemy(enemy) then
            return
        end

        if project.util.enemy.withPurge > 0 then
            if not enemy.debuff("Purge the Wicked") then
                return
            end
        end

        if type == "pve" then
            if not enemy.inCombat then
                return
            end

            if enemy.ttd < 2 then
                return
            end
        end

        if type == "pvp" then
            if not enemy.player then
                return
            end
        end

        local count_enemies = awful.enemies.around(enemy, 10, function(e)
            if type == "pvp" then
                if not e.player then
                    return
                end
            end

            return is_viable_enemy(e)
        end)

        if count_enemies > most_enemies_around or (count_enemies == most_enemies_around and enemy.guid == main_target.guid) then
            enemy_with_most_enemies_around = enemy
            most_enemies_around = count_enemies
        end

        if enemy.guid == main_target.guid then
            mt_en = count_enemies
        end
    end)

    if most_enemies_around >= 1 then
        return enemy_with_most_enemies_around
    end

    return main_target
end