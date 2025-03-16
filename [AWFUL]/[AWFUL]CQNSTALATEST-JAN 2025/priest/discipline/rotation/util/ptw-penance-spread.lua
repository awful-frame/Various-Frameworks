local Unlocker, awful, project = ...

project.priest.discipline.rotation.util.find_best_target_to_ptw_penance_spread = function(type)
    local main_target = awful.target

    if main_target.hp < 30 then
        return main_target
    end

    local enemy_with_most_enemies_around
    local most_enemies_around = 0

    local mt_en = 0

    awful.enemies.loop(function(enemy)
        if not project.util.check.target.viable(enemy, true) then
            return
        end

        if project.util.enemy.withPurge > 0 then
            if not enemy.debuff(project.util.id.spell.PURGE_THE_WICKED_DEBUFF) then
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

        local count_enemies = awful.enemies.around(enemy, 9, function(e)
            if type == "pvp" then
                if not e.player then
                    return
                end
            end

            return project.util.check.target.viable(enemy, true, true)
        end)

        if count_enemies > most_enemies_around then
            enemy_with_most_enemies_around = enemy
            most_enemies_around = count_enemies
        end

        if count_enemies == most_enemies_around
                and enemy.guid == main_target.guid
                and main_target.debuff(project.util.id.spell.PURGE_THE_WICKED_DEBUFF) then
            enemy_with_most_enemies_around = enemy
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