local Unlocker, awful, project = ...

local function save_md()
    if not awful.arena then
        return
    end

    if not project.settings.priest_cds_mass_dispel_block then
        return
    end

    if not project.util.enemy.existing_classes[project.util.id.class.PALADIN] and
            not project.util.enemy.existing_classes[project.util.id.class.MAGE] then
        return
    end

    return awful.enemies.find(function(enemy)
        if enemy.class3 == project.util.id.class.MAGE then
            if enemy.specID == project.util.id.spec.FROST_MAGE then
                return true
            end

            if enemy.cooldown(project.util.id.spell.ICE_BLOCK) < project.priest.spells.massDispel.cd + 15 then
                return true
            end
        end

        if enemy.class3 == project.util.id.class.PALADIN
                and (not enemy.healer or project.util.enemy.totalPlayers == 2) then
            if enemy.cooldown(project.util.id.spell.DIVINE_SHIELD) < project.priest.spells.massDispel.cd + 15 then
                return true
            end
        end
    end)
end

local function should_mass(target)
    local around_with_vamp_touch = awful.fgroup.around(target, 15, function(friend)
        return friend.debuff(project.util.id.spell.VAMPIRIC_TOUCH)
    end)

    local around_with_unstable_aff = awful.fgroup.around(target, 15, function(friend)
        return friend.debuff(project.util.id.spell.UNSTABLE_AFFLICTION)
    end)

    if around_with_unstable_aff >= 2 then
        return
    end

    if around_with_unstable_aff == 1 then
        if project.util.enemy.total_cds > 0 then
            return
        end

        if awful.player.hpa < 95 then
            return
        end

        if project.util.friend.best_target.unit.hp < 80 then
            return
        end
    end

    if around_with_vamp_touch > 0 then
        if project.util.enemy.total_cds > 0 then
            return
        end

        if project.util.friend.best_target.unit.hp < 70 then
            return
        end
    end

    return true
end

project.priest.spells.massDispel:Callback("friend_below2PRIO", function(spell, target, debuff, priority)
    if not awful.arena then
        return
    end

    if project.util.enemy.existing_classes[project.util.id.class.DRUID] then
        return
    end

    if target.los then
        if project.priest.spells.purify.cd < project.priest.spells.massDispel.castTime + awful.buffer then
            return
        end
    end

    if priority > 2
            or priority == -8 then
        return
    end

    if save_md() then
        return
    end

    if not should_mass(target) then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return project.util.cast.stop_moving(spell, target, false, false, true)
            and project.util.debug.alert.dispel("Mass Dispel! friend_below2PRIO " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_8PRIO", function(spell, target, debuff, priority)
    if priority ~= -8 then
        return
    end

    if project.util.friend.total_cds == 0 and save_md() then
        return
    end

    if not should_mass(target) then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return project.util.cast.stop_moving(spell, target, false, false, true)
            and project.util.debug.alert.dispel("Mass Dispel! friend_8PRIO " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_0PRIO_pve", function(spell, target, debuff, priority)
    if priority ~= 0 then
        return
    end

    if target.los then
        if project.priest.spells.purify.cd < project.priest.spells.massDispel.castTime + awful.buffer then
            return
        end
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority

    if awful.mapID == project.util.id.map.DAWNBREAKER then
        return project.util.cast.stop_moving(spell, awful.player, false, false, false)
                and project.util.debug.alert.dispel("Mass Dispel! friend_0PRIO_pve_DB" .. info, project.priest.spells.massDispel.id)
    end

    return project.util.cast.stop_moving(spell, target, false, false, true)
            and project.util.debug.alert.dispel("Mass Dispel! friend_0PRIO_pve " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_-1PRIO_pve", function(spell, target, debuff, priority)
    if priority ~= -1 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority

    if awful.mapID == project.util.id.map.DAWNBREAKER then
        return project.util.cast.stop_moving(spell, awful.player, false, false, false)
                and project.util.debug.alert.dispel("Mass Dispel! friend_-1PRIO_pve_DB " .. info, project.priest.spells.massDispel.id)
    end

    return project.util.cast.stop_moving(spell, target, false, false, true)
            and project.util.debug.alert.dispel("Mass Dispel! friend_-1PRIO_pve " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("friend_pvp", function(spell, target, debuff, priority)
    if not project.settings.priest_cds_mass_dispel_friends then
        return
    end

    if not target then
        return
    end

    if project.util.friend.danger then
        return
    end

    return project.priest.spells.massDispel("friend_8PRIO", target, debuff, priority)
            or project.priest.spells.massDispel("friend_below2PRIO", target, debuff, priority)
end)

project.priest.spells.massDispel:Callback("friend_pve", function(spell, target, debuff, priority)
    if not target then
        return
    end

    if project.util.friend.best_target.unit.hp < 20 then
        return
    end

    return project.priest.spells.massDispel("friend_-1PRIO_pve", target, debuff, priority)
            or project.priest.spells.massDispel("friend_0PRIO_pve", target, debuff, priority)
end)