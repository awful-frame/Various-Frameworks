local Unlocker, awful, project = ...

project.util.best_target.friend = function()
    local most_attacked = awful.player
    local lowest_hp = awful.player
    local lowest_hp_los = awful.player

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        local attackers = project.util.friend.attackers.get(friend.guid)
        local most_attacked_attackers = project.util.friend.attackers.get(most_attacked.guid)

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
            if attackers.t > most_attacked_attackers.t then
                most_attacked = friend
            end

            if attackers.t == most_attacked_attackers.t then
                if friend.hp < most_attacked.hp then
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
