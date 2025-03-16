local Unlocker, awful, project = ...

local prio_enemy_ids = {
    [project.util.id.npc.VOID_EMISSARY] = true,
}

project.util.best_target.enemy = function(type)
    if project.util.enemy.totalViable == 0 then
        return
    end

    local most_attacked
    local highest_ttd_attacked

    local lowest_hp
    local lowest_hpa
    local second_lowest_hpa
    local prio_enemy

    awful.enemies.loop(function(enemy)
        if not project.util.check.target.viable(enemy) then
            return
        end

        local attackers = project.util.check.target.attackers(enemy)
        local defensives = project.util.check.target.defensives(enemy)

        local attackers_ths = (project.util.friend.total == 2) and 1 or 2
        if attackers.total >= attackers_ths then
            local def_check = (project.util.friend.total == 2) and (defensives.def_best == 0) or (defensives.def == 0)
            if def_check then
                if not most_attacked or attackers.total > project.util.check.target.attackers(most_attacked).total then
                    most_attacked = enemy
                end
            end
        end

        if prio_enemy_ids[enemy.id] then
            prio_enemy = enemy
        end

        if not highest_ttd_attacked then
            highest_ttd_attacked = enemy
        end

        if not lowest_hp then
            lowest_hp = enemy
        end

        if not lowest_hpa then
            lowest_hpa = enemy
        end

        if not second_lowest_hpa
                and enemy.guid ~= lowest_hpa.guid then
            second_lowest_hpa = enemy
        end

        if enemy.hp < lowest_hp.hp then
            lowest_hp = enemy
        end

        if enemy.hpa < lowest_hpa.hpa then
            second_lowest_hpa = lowest_hpa
            lowest_hpa = enemy
        end

        if enemy.ttd > highest_ttd_attacked.ttd and attackers.total > 0 then
            highest_ttd_attacked = enemy
        end
    end)

    if type == "pve" then
        if prio_enemy then
            project.settings.enemy_target_method = "prio_enemy"
            return prio_enemy
        end

        if not awful.target.enemy
                or awful.target.dead then
            return highest_ttd_attacked
        end

        if awful.target
                and awful.target.enemy
                and awful.target.ttd < 8
                and highest_ttd_attacked
                and highest_ttd_attacked.ttd > 8 then
            return highest_ttd_attacked
        end

        return awful.target
    end

    if type == "pvp" then
        if lowest_hp and lowest_hp.hp <= 20 and lowest_hp.hpa <= 40 then
            project.settings.enemy_target_method = "lowest_hp"
            return lowest_hp
        end

        if most_attacked then
            project.settings.enemy_target_method = "most_attacked"
            return most_attacked
        end

        if second_lowest_hpa
                and project.util.check.target.defensives(lowest_hpa).def > 0
                and project.util.check.target.defensives(second_lowest_hpa).def == 0
                and second_lowest_hpa.hpa - lowest_hpa.hpa < 30 then
            project.settings.enemy_target_method = "second_lowest_hpa"
            return second_lowest_hpa
        end

        project.settings.enemy_target_method = "lowest_hpa"
        return lowest_hpa
    end
end