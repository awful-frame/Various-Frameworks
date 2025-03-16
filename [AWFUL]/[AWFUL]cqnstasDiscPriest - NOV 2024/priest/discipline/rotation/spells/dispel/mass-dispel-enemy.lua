local Unlocker, awful, project = ...

project.priest.discipline.rotation.util.ice_wall_detected = false

local function should_mass(target)
    local around_with_vamp_touch = awful.fgroup.around(target, 15, function(friend)
        return friend.debuff("Vampiric Touch")
    end)

    local around_with_unstable_aff = awful.fgroup.around(target, 15, function(friend)
        return friend.debuff("Unstable Affliction")
    end)

    if around_with_unstable_aff >= 2 then
        return
    end

    if around_with_unstable_aff == 1 then
        if project.util.enemy.withOffensiveCds > 0 then
            return
        end

        if awful.player.hpa < 95 then
            return
        end

        if project.util.friend.bestTarget.hp < 80 then
            return
        end
    end

    if around_with_vamp_touch > 0 then
        if project.util.enemy.withOffensiveCds > 0 then
            return
        end

        if project.util.friend.bestTarget.hp < 70 then
            return
        end
    end

    return true
end

project.priest.spells.massDispel:Callback("enemy_block", function(spell, target, buff, priority)
    if priority ~= -8 then
        return
    end

    if not should_mass(target) then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return project.util.cast.stop_moving(spell, target, false, true, true)
            and project.util.debug.alert.dispel("Mass Dispel! enemy_block " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("enemy_mage_ice_wall", function(spell)
    if not project.priest.discipline.rotation.util.ice_wall_detected then
        return
    end

    awful.units.loop(function(unit)
        if unit.id ~= 178819 then
            return
        end

        if unit.creator.friend then
            return
        end

        if unit.dist > project.util.friend.bestTarget.dist then
            return
        end

        if not should_mass(unit) then
            return
        end

        if not awful.player.facing(unit, 90) then
            return
        end

        if unit.dist < 15 then
            return project.util.cast.stop_moving(spell, awful.player, false, false, true)
                    and project.util.debug.alert.dispel("Mass Dispel! enemy_mage_ice_wall_player", project.priest.spells.massDispel.id)
        end
    end)
end)

project.priest.spells.massDispel:Callback("enemy_-1PRIO_pve", function(spell, target, buff, priority)
    if priority ~= -1 then
        return
    end

    if project.util.enemy.totalCombat == 1 then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority

    if awful.mapID == 2662 then
        return spell:Cast(awful.player, { stopMoving = true })
                and project.util.debug.alert.dispel("Mass Dispel! enemy_-1PRIO_pve " .. info, project.priest.spells.massDispel.id)
    end

    return spell:AoECast(target)
            and project.util.debug.alert.dispel("Mass Dispel! enemy_-1PRIO_pve " .. info, project.priest.spells.massDispel.id)
end)

project.priest.spells.massDispel:Callback("enemy_pvp", function(spell, target, buff, priority)
    if awful.player.casting == "Mass Dispel" then
        return
    end

    if project.util.friend.danger then
        return project.priest.spells.massDispel("enemy_mage_ice_wall")
    end

    return project.priest.spells.massDispel("enemy_block", target, buff, priority)
            or project.priest.spells.massDispel("enemy_mage_ice_wall")
end)

project.priest.spells.massDispel:Callback("enemy_pve", function(spell, target, buff, priority)
    if not target then
        return
    end

    if awful.player.casting == "Mass Dispel" then
        return
    end

    if project.util.friend.danger then
        return
    end

    return project.priest.spells.massDispel("enemy_-1PRIO_pve", target, buff, priority)
end)

awful.onEvent(function(info, event, source, dest)
    if not source.enemy then
        return
    end

    if not awful.arena then
        if source.dist > project.util.check.player.range() then
            return
        end
    end

    if event == "SPELL_CAST_SUCCESS" then
        local _, spellName = select(12, unpack(info))

        if spellName == "Ice Wall" then
            project.priest.discipline.rotation.util.ice_wall_detected = true

            C_Timer.After(8, function()
                project.priest.discipline.rotation.util.ice_wall_detected = false
            end)
        end
    end
end)

awful.onEvent(function(info, event, source, dest)
    if not source.guid == awful.player.guid then
        return
    end

    if event == "SPELL_CAST_SUCCESS" then
        local spellID, spellName = select(12, unpack(info))

        if spellName == "Mass Dispel" then
            project.priest.discipline.rotation.util.ice_wall_detected = false
        end
    end
end)