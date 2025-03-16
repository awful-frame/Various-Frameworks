local Unlocker, awful, project = ...

local function save_md()
    if not awful.arena then
        return
    end

    awful.enemies.loop(function(enemy)
        if enemy.class == 'Mage' then
            if enemy.cooldown("Ice Block") < project.priest.spells.massDispel.cd + 15 then
                return true
            end
        end

        if enemy.class == 'Paladin' and not enemy.healer then
            if enemy.cooldown("Divine Shield") < project.priest.spells.massDispel.cd + 15 then
                return true
            end
        end

        if enemy.class == 'Paladin' and project.util.enemy.totalPlayers == 2 then
            if enemy.cooldown("Divine Shield") < project.priest.spells.massDispel.cd + 15 then
                return true
            end
        end
    end)

    return false
end

project.priest.spells.massDispel:Callback("friend_below3PRIO", function(spell, target, debuff, priority)
    if not awful.arena then
        return
    end

    if target.los then
        if project.priest.spells.purify.cd < project.priest.spells.massDispel.castTime + awful.spellCastBuffer then
            return
        end
    end

    if priority > 3
            or priority == -8 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:SmartAoE(target, { stopMoving = true })
            and project.util.debug.alert.dispel("Mass Dispel! friend_below3PRIO " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_8PRIO", function(spell, target, debuff, priority)
    if priority ~= -8 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:SmartAoE(target, { stopMoving = true })
            and project.util.debug.alert.dispel("Mass Dispel! friend_8PRIO " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_0PRIO_pve", function(spell, target, debuff, priority)
    if priority ~= 0 then
        return
    end

    if target.los then
        if project.priest.spells.purify.cd < project.priest.spells.massDispel.castTime + awful.spellCastBuffer then
            return
        end
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority

    if awful.mapID == 2662 then
        return spell:Cast(awful.player, { stopMoving = true })
                and project.util.debug.alert.dispel("Mass Dispel! friend_0PRIO_pve" .. info, project.priest.spells.massDispel.id)
    end

    return spell:AoECast(target, { stopMoving = true })
            and project.util.debug.alert.dispel("Mass Dispel! friend_0PRIO_pve " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_-1PRIO_pve", function(spell, target, debuff, priority)
    if priority ~= -1 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority

    if awful.mapID == 2662 then
        return spell:Cast(awful.player, { stopMoving = true })
                and project.util.debug.alert.dispel("Mass Dispel! friend_-1PRIO_pve " .. info, project.priest.spells.massDispel.id)
    end

    return spell:AoECast(target, { stopMoving = true })
            and project.util.debug.alert.dispel("Mass Dispel! friend_-1PRIO_pve " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_pvp", function(spell, target, debuff, priority)
    if not target then
        return
    end

    if awful.player.casting == "Mass Dispel" then
        return
    end

    if project.util.friend.danger then
        return
    end

    if save_md() then
        return
    end

    local around_with_aff = awful.fgroup.around(target, 15, function(friend)
        return friend.debuff("Unstable Affliction")
    end)

    if around_with_aff > 0 then
        return
    end

    local around_with_vamp_touch = awful.fgroup.around(target, 15, function(friend)
        return friend.debuff("Vampiric Touch")
    end)

    if around_with_vamp_touch > 0
            and project.util.friend.danger then
        return
    end

    if target.debuffRemains(debuff) < project.util.thresholds.buff() + spell.castTime then
        return
    end

    return project.priest.spells.massDispel("friend_8PRIO", target, debuff, priority)
            or project.priest.spells.massDispel("friend_below3PRIO", target, debuff, priority)
end)

project.priest.spells.massDispel:Callback("friend_pve", function(spell, target, debuff, priority)
    if not target then
        return
    end

    if awful.player.casting == "Mass Dispel" then
        return
    end

    return project.priest.spells.massDispel("friend_-1PRIO_pve", target, debuff, priority)
            or project.priest.spells.massDispel("friend_0PRIO_pve", target, debuff, priority)
end)