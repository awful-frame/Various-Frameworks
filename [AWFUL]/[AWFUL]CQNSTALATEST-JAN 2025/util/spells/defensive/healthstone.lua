local Unlocker, awful, project = ...

local function healthstone_below30HPA(item)
    if awful.player.hpa > 30 then
        return
    end

    return item:Use() and
            project.util.debug.alert.defensive("Healthstone! below30HPA", project.util.spells.items.healthstone.id)
end

local function healthstone_pvp_below50HPA_atleast3ATT(item)
    if awful.player.hpa > 50 then
        return
    end

    if project.util.friend.best_target.attackers.total < 3 then
        return
    end

    return item:Use() and
            project.util.debug.alert.defensive("Healthstone! pvp_below50HPA_atleast3ATT", 6262)
end

local function healthstone_pvp_below50HPA_atleast1CD(item)
    if awful.player.hpa > 50 then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    return item:Use() and
            project.util.debug.alert.defensive("Healthstone! pvp_below50HPA_atleast1CD", 6262)
end

local function healthstone_pvp(item)
    if project.util.friend.best_target.unit.guid ~= awful.player.guid then
        return
    end

    if project.util.friend.best_target.attackers.total == 0 then
        return
    end

    return healthstone_below30HPA(item)
            or healthstone_pvp_below50HPA_atleast1CD(item)
            or healthstone_pvp_below50HPA_atleast3ATT(item)
end

local function healthstone_pve(item)
    return healthstone_below30HPA(item)
end

project.util.spells.defensive.healthstone = function(type)
    if not project.settings.defensives_healthstone then
        return
    end

    if not project.util.spells.items.healthstone:Usable() then
        return
    end

    if not awful.player.inCombat then
        return
    end

    if not project.util.enemy.best_target.unit then
        return
    end

    if type == "pvp" then
        return healthstone_pvp(project.util.spells.items.healthstone)
    end

    return healthstone_pve(project.util.spells.items.healthstone)
end