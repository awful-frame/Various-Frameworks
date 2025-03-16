local Unlocker, awful, project = ...

local function findBestTargetToShift()
    if project.util.friend.total < 2 then
        return
    end

    local thresholdHP = 30

    local bestFriend
    local minAttackers = 10
    local maxHP = 0

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if friend.hp < thresholdHP then
            return
        end

        local total = project.util.friend.attackers.get(friend.guid).t
        if total < minAttackers then
            minAttackers = total
            bestFriend = friend
            maxHP = friend.hp
        elseif total == minAttackers then
            if friend.hp > maxHP then
                bestFriend = friend
                maxHP = friend.hp
            end
        end
    end)

    if bestFriend then
        project.util.debug.alert.beneficial(string.format("Best target to shift: %s | HP: %d | Attackers: %d", bestFriend.name, bestFriend.hp, bestFriend.attackers), project.priest.spells.voidShift.id)
    else
        project.util.debug.alert.beneficial("No suitable target found to shift.", project.priest.spells.voidShift.id)
    end

    return bestFriend
end

project.priest.spells.voidShift:Callback("below20HP_noDRB", function(spell)
    if project.util.friend.bestTarget.hp > 20 then
        return
    end

    if project.util.friend.attackers.def_best > 0 then
        return
    end

    local target = project.util.friend.bestTarget
    if project.util.friend.bestTarget.guid == awful.player.guid then
        target = findBestTargetToShift()
    end

    if project.settings.priest_cds_trinket_void_shift then
        if awful.player.ccRemains > 1 then
            if project.util.spells.items.conquestTrinket:Use()
                    or project.util.spells.items.honorTrinket:Use() then
                awful.alert(awful.colors.red .. "Trinket Void Shift", 336126)
            end
        end
    end

    if awful.player.casting then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.beneficial("Void Shift! below20HP_noDRB", project.priest.spells.voidShift.id)
end)

project.priest.spells.voidShift:Callback("pve", function()
    if not project.settings.priest_cds_void_shift then
        return
    end

    return project.priest.spells.voidShift("below20HP_noDRB")
end)

project.priest.spells.voidShift:Callback("pvp", function()
    if not project.settings.priest_cds_void_shift then
        return
    end

    return project.priest.spells.voidShift("below20HP_noDRB")
end)