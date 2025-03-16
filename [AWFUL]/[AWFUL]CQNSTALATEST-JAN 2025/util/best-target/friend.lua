local Unlocker, awful, project = ...

project.util.best_target.friend = function()
    local most_attacked = awful.player
    local lowest_hp = awful.player
    local lowest_hp_los = awful.player

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        local attackers = project.util.check.target.attackers(friend)
        local most_attacked_attackers = project.util.check.target.attackers(most_attacked)

        if friend.hp < lowest_hp.hp then
            lowest_hp = friend
        end

        if friend.los and friend.hp < lowest_hp_los.hp then
            lowest_hp_los = friend
        end

        if attackers.cdp > most_attacked_attackers.cdp then
            most_attacked = friend
        end

        if attackers.cdp == most_attacked_attackers.cdp then
            if attackers.total > most_attacked_attackers.total then
                most_attacked = friend
            end

            if attackers.total == most_attacked_attackers.total then
                if attackers.melee > most_attacked_attackers.melee then
                    most_attacked = friend
                    return
                end

                if friend.hp < most_attacked.hp then
                    most_attacked = friend
                    return
                end

                if friend.ranged then
                    most_attacked = friend
                    return
                end

                if friend.melee then
                    most_attacked = friend
                end
            end
        end
    end)

    if lowest_hp_los.hp < 30 then
        project.settings.friend_target_method = "lowest_hp_los"
        return lowest_hp_los
    end

    if lowest_hp.hp < 30 then
        project.settings.friend_target_method = "lowest_hp"
        return lowest_hp
    end

    if most_attacked.hp - lowest_hp.hp >= 30 then
        project.settings.friend_target_method = "lowest_hp_ths"
        return lowest_hp
    end

    project.settings.friend_target_method = "most_attacked"
    return most_attacked
end
