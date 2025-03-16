local Unlocker, awful, project = ...

local function healthstone_below20HPA(item)
    if awful.player.hpa > 20 then
        return
    end

    return item:Use() and
            project.util.debug.alert.defensive("Healthstone! below20HPA", project.util.spells.items.healthstone.id)
end

local function healthstone_pvp_below50HPA_atleast3ATT(item)
    if awful.player.hpa > 50 then
        return
    end

    if project.util.friend.attackers.total < 3 then
        return
    end

    return item:Use() and
            project.util.debug.alert.defensive("Healthstone! pvp_below50HPA_atleast3ATT", project.util.spells.items.healthstone.id)
end

local function healthstone_pvp_below50HPA_atleast1CD(item)
    if awful.player.hpa > 50 then
        return
    end

    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    return item:Use() and
            project.util.debug.alert.defensive("Healthstone! pvp_below50HPA_atleast1CD", project.util.spells.items.healthstone.id)
end

local function healthstone_pvp(item)
    if project.util.friend.bestTarget.guid ~= awful.player.guid then
        return
    end

    if project.util.friend.attackers.total == 0 then
        return
    end

    return healthstone_below20HPA(item)
            or healthstone_pvp_below50HPA_atleast1CD(item)
            or healthstone_pvp_below50HPA_atleast3ATT(item)
end

local function healthstone_pve(item)
    if project.util.friend.bestTarget.guid ~= awful.player.guid then
        return
    end

    return healthstone_below20HPA(item)
end

project.util.spells.defensive.healthstone = function(type)
    if not project.settings.general_auto_hs then
        return
    end

    if not project.util.spells.items.healthstone:Usable() then
        return
    end

    if type == "pvp" then
        return healthstone_pvp(project.util.spells.items.healthstone)
    end
    return healthstone_pve(project.util.spells.items.healthstone)
end