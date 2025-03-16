local Unlocker, awful, project = ...

local burst_priority = {
    [project.util.id.class.WARLOCK] = { default = 1 },
    [project.util.id.class.EVOKER] = { default = 1, [project.util.id.spec.AUGMENTATION] = 7 },
    [project.util.id.class.SHAMAN] = { default = 1, [project.util.id.spec.ENHANCEMENT] = 3 },
    [project.util.id.class.HUNTER] = { default = 3 },
    [project.util.id.class.MAGE] = { default = 4 },
    [project.util.id.class.DRUID] = { default = 4, [project.util.id.spec.BALANCE] = 2 },
    [project.util.id.class.DEATH_KNIGHT] = { default = 4 },
    [project.util.id.class.ROGUE] = { default = 5 },
    [project.util.id.class.WARRIOR] = { default = 5 },
    [project.util.id.class.MONK] = { default = 5 },
    [project.util.id.class.PALADIN] = { default = 5 },
    [project.util.id.class.DEMON_HUNTER] = { default = 5 },
    [project.util.id.class.PRIEST] = { default = 6 },
}

local function get_priority(friend)
    local class = friend.class3
    local spec = friend.specID
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

        local total_bbf = project.util.check.target.cooldowns(best_bursting_friend.target, best_bursting_friend).total
        local total = project.util.check.target.cooldowns(friend.target, friend).total

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

        if friend.specID == project.util.id.spec.AUGMENTATION
                and project.util.friend.total > 2 then
            return
        end

        local big = project.util.check.target.cooldowns(friend.target, friend).big
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
    if project.util.friend.total_cds == 0 then
        return
    end

    local best_bursting_friend

    if project.settings.priest_burst or project.settings.priest_offensives_bt then
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

    local total = project.util.check.target.cooldowns(best_bursting_friend.target, best_bursting_friend).total
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

    if not project.util.enemy.best_target.unit then
        return
    end

    if type == "pve"
            and project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.ttd < 8 then
        return
    end

    power_up_friend()
    project.util.spells.offensive.tempered_potion(type)

    if IsPlayerSpell(project.util.id.spell.VOIDWRAITH_TALENT) then
        project.priest.spells.voidwraith(type, project.util.enemy.best_target.unit)
    else
        project.priest.spells.shadowfiend(type, project.util.enemy.best_target.unit)
    end

    if IsPlayerSpell(project.util.id.spell.MINDGAMES) then
        project.priest.spells.mindgames(type)
    end
end
