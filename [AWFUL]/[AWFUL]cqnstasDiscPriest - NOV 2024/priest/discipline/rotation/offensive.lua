local Unlocker, awful, project = ...

local burst_priority = {
    ["Warlock"] = { default = 1 },
    ["Evoker"] = { default = 1, ["Augmentation"] = 7 },
    ["Shaman"] = { default = 1, ["Enhancement"] = 3 },
    ["Hunter"] = { default = 2 },
    ["Mage"] = { default = 2 },
    ["Druid"] = { default = 4 },
    ["Rogue"] = { default = 5 },
    ["Warrior"] = { default = 5 },
    ["Monk"] = { default = 5 },
    ["Paladin"] = { default = 5 },
    ["Demon Hunter"] = { default = 5 },
    ["Death Knight"] = { default = 5 },
    ["Priest"] = { default = 6 },
}

local function get_priority(friend)
    local class = friend.class
    local spec = friend.spec
    if burst_priority[class] and burst_priority[class][spec] then
        return burst_priority[class][spec]
    end
    return burst_priority[class] and burst_priority[class].default or nil
end

local function find_best_bursting_friend_prio()
    local best_bursting_friend

    awful.group.loop(function(friend)
        if friend.dead
                or (project.util.friend.total > 2 and friend.role == "tank") then
            return
        end

        if not awful.arena
                and (not project.util.check.target.viable(friend) or not friend.inCombat) then
            return
        end

        local prio = get_priority(friend)
        if not prio then
            return
        end

        if not best_bursting_friend then
            best_bursting_friend = friend
            return
        end

        local bbf_prio = get_priority(best_bursting_friend)

        if prio < bbf_prio then
            best_bursting_friend = friend
            return
        end

        local total_bbf = project.util.check.target.cooldowns(best_bursting_friend.target, best_bursting_friend)
        local total = project.util.check.target.cooldowns(friend.target, friend)

        if prio == bbf_prio and total > total_bbf then
            best_bursting_friend = friend
        end
    end)

    return best_bursting_friend
end

local function find_first_bursting_friend()
    local first_bursting_friend

    awful.group.loop(function(friend)
        if not project.util.check.target.viable(friend)
                or not friend.inCombat
                or friend.cc
                or (project.util.friend.total > 2 and friend.role == "tank") then
            return
        end

        if friend.class == "Evoker"
                and friend.spec == "Augmentation"
                and project.util.friend.total > 2 then
            return
        end

        local _, big = project.util.check.target.cooldowns(friend.target, friend)
        if big == 0 then
            return
        end

        local prio = get_priority(friend)
        if not prio then
            return
        end

        if not first_bursting_friend then
            first_bursting_friend = friend
            return
        end

        local fbr_prio = get_priority(first_bursting_friend)

        if prio < fbr_prio then
            first_bursting_friend = friend
        end
    end)

    return first_bursting_friend
end

local function power_up_friend()
    if project.util.friend.withOffensiveCds == 0 then
        return
    end

    local best_bursting_friend

    if project.settings.priest_burst
            or project.settings.priest_offensives_bt then
        best_bursting_friend = find_best_bursting_friend_prio()
    else
        best_bursting_friend = find_first_bursting_friend()
    end

    if project.util.friend.totalViable == 1 then
        best_bursting_friend = awful.player
    end

    if not best_bursting_friend then
        return
    end

    if not best_bursting_friend.inCombat then
        return
    end

    if best_bursting_friend.cc then
        return
    end

    if not project.util.check.target.viable(best_bursting_friend) then
        return
    end

    local total = project.util.check.target.cooldowns(best_bursting_friend.target, best_bursting_friend)
    if not project.settings.priest_burst then
        if total == 0 then
            return
        end
    end

    project.priest.spells.powerInfusion(best_bursting_friend)
    project.priest.spells.darkArchangel(best_bursting_friend)
end

project.priest.discipline.rotation.offensive = function(type)
    if not project.settings.priest_offensives_enabled then
        return
    end

    if not project.util.enemy.bestTarget then
        return
    end

    if type == "pve" then
        if project.util.enemy.bestTarget
                and project.util.enemy.bestTarget.ttd < 8 then
            return
        end
    end

    power_up_friend()

    if IsPlayerSpell(451234) then
        project.priest.spells.voidwraith(type, project.util.enemy.bestTarget)
    else
        project.priest.spells.shadowfiend(type, project.util.enemy.bestTarget)
    end

    project.priest.spells.voidTendrils(type)
    project.priest.spells.mindgames(type)
end
