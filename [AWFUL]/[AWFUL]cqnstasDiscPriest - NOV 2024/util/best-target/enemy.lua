local Unlocker, awful, project = ...

project.util.best_target.enemy = function(type)
    if project.util.enemy.totalViable == 0 then
        return
    end

    local most_attacked
    local highest_ttd_attacked

    local lowest_hp
    local lowest_hpa
    local second_lowest_hpa

    awful.enemies.loop(function(enemy)
        if not project.util.check.target.viable(enemy) then
            return
        end

        local attackers = project.util.enemy.attackers.get(enemy.guid)

        local attackers_ths = 2
        if project.util.friend.total == 2 then
            attackers_ths = 1
        end
        if attackers.t >= attackers_ths and attackers.def == 0 then
            if not most_attacked or attackers.t > project.util.enemy.attackers.get(most_attacked.guid).t then
                most_attacked = enemy
            end
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

        if enemy.ttd > highest_ttd_attacked.ttd and attackers.t > 0 then
            highest_ttd_attacked = enemy
        end
    end)

    if type == "pve" then
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
                and project.util.enemy.attackers.get(lowest_hpa.guid).def > 0
                and project.util.enemy.attackers.get(second_lowest_hpa.guid).def == 0
                and second_lowest_hpa.hpa - lowest_hpa.hpa < 30 then
            project.settings.enemy_target_method = "second_lowest_hpa"
            return second_lowest_hpa
        end

        project.settings.enemy_target_method = "lowest_hpa"
        return lowest_hpa
    end
end