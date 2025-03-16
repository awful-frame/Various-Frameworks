local Unlocker, awful, project = ...

local dispel_on_cd = false
local dispel_cd = 2

project.priest.spells.dispelMagic:Callback("-1PRIO_pve", function(spell, target, buff, priority)
    if IsPlayerSpell(project.util.id.spell.MASS_DISPEL)
            and project.util.enemy.totalCombat > 1
            and project.priest.spells.massDispel.cd <= awful.gcd * 2 then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! -1PRIO_pve " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("0PRIO_pve", function(spell, target, buff, priority)
    if priority ~= 0 then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! 0PRIO_pve " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("1PRIO_enemyDanger", function(spell, target, buff, priority)
    if priority ~= 1 then
        return
    end

    if target ~= project.util.enemy.best_target.unit then
        return
    end

    if not project.util.enemy.danger then
        return
    end

    if buff == "Power Word: Shield" and target.hpa - target.hp < 5 then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! 1PRIO_enemyDanger " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("23PRIO", function(spell, target, buff, priority)
    if priority ~= 2 and priority ~= 3 then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! 23PRIO " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("4PRIO_above20MP_below3ENEMY", function(spell, target, buff, priority)
    if priority ~= 4 then
        return
    end

    if awful.player.manaPct < 20 then
        return
    end

    if not awful.arena then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! 4PRIO_above20MP_below3ENEMY " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("56PRIO_above70HP_above50MP_below3ENEMY", function(spell, target, buff, priority)
    if priority ~= 5 and priority ~= 6 then
        return
    end

    if project.util.friend.best_target.unit.hp < 70 then
        return
    end

    if target.purgeCount > 1 then
        if awful.player.manaPct < 50 then
            return
        end
    end

    if not awful.arena then
        return
    end

    if project.util.enemy.total_cds > 0 then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT) then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! 56PRIO_above70HP_above50MP_below3ENEMY " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("7PRIO_above90HP_above90MP_below3ENEMY", function(spell, target, buff, priority)
    if priority ~= 7 then
        return
    end

    if project.util.friend.best_target.unit.hp < 90 then
        return
    end

    if awful.player.manaPct < 90 then
        return
    end

    if not awful.arena then
        return
    end

    if project.util.enemy.total_cds > 0 then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT) then
        return
    end

    local info = "Enemy: " .. target.name .. ". Buff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! 7PRIO_above90HP_above90MP_below3ENEMY " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("-9PRIO_FRIEND", function(spell, target, buff, priority)
    local info = "Friend: " .. target.name .. ". Debuff: " .. buff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Dispel Magic! -9PRIO_FRIEND " .. info, project.priest.spells.dispelMagic.id)
end)

project.priest.spells.dispelMagic:Callback("pvp", function(spell, target, buff, priority)
    if not target then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
            and project.util.friend.danger then
        return
    end

    if priority == -7 then
        return project.priest.spells.dispelMagic("-7PRIO_FRIEND", target, buff, priority)
    end

    if not project.util.friend.existing_classes[project.util.id.class.ROGUE]
            and project.util.enemy.withPurge == 0
            and awful.player.manaPct > 90 then
        return
    end

    local purge_count = target.purgeCount
    if buff == "Nullifying Shroud" then
        purge_count = purge_count + target.buffStacks("Nullifying Shroud") - 1
    end

    if target.purgeCount > 3
            or (project.util.enemy.total_cds > 0 and project.util.friend.best_target.unit.hp < 70)
            or priority == 7 then
        if dispel_on_cd then
            return
        end

        if project.util.friend.danger then
            return
        end

        dispel_on_cd = true
        C_Timer.After(dispel_cd, function()
            dispel_on_cd = false
        end)

        return project.priest.spells.dispelMagic("1PRIO_enemyDanger", target, buff, priority)
                or project.priest.spells.dispelMagic("23PRIO", target, buff, priority)
                or project.priest.spells.dispelMagic("4PRIO_above20MP_below3ENEMY", target, buff, priority)
                or project.priest.spells.dispelMagic("56PRIO_above70HP_above50MP_below3ENEMY", target, buff, priority)
                or project.priest.spells.dispelMagic("7PRIO_above90HP_above90MP_below3ENEMY", target, buff, priority)
    end

    if target.purgeCount <= 3 then
        if project.util.friend.danger then

            if target.purgeCount == 1 then
                return project.priest.spells.dispelMagic("1PRIO_enemyDanger", target, buff, priority)
                        or project.priest.spells.dispelMagic("23PRIO", target, buff, priority)
            end

            return
        end

        if not project.priest.discipline.rotation.util.is_premonition()
                and awful.player.buff(project.util.id.spell.VOIDHEART) then
            return project.priest.spells.dispelMagic("1PRIO_enemyDanger", target, buff, priority)
                    or project.priest.spells.dispelMagic("23PRIO", target, buff, priority)
        end

        if project.util.enemy.total_cds > 0 then
            return project.priest.spells.dispelMagic("1PRIO_enemyDanger", target, buff, priority)
                    or project.priest.spells.dispelMagic("23PRIO", target, buff, priority)
        end

        return project.priest.spells.dispelMagic("1PRIO_enemyDanger", target, buff, priority)
                or project.priest.spells.dispelMagic("23PRIO", target, buff, priority)
                or project.priest.spells.dispelMagic("4PRIO_above20MP_below3ENEMY", target, buff, priority)
                or project.priest.spells.dispelMagic("56PRIO_above70HP_above50MP_below3ENEMY", target, buff, priority)
                or project.priest.spells.dispelMagic("7PRIO_above90HP_above90MP_below3ENEMY", target, buff, priority)
    end
end)

project.priest.spells.dispelMagic:Callback("pve", function(spell, target, buff, priority)
    if not target then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then
        return project.priest.spells.dispelMagic("0PRIO_pve", target, buff, priority)
    end

    return project.priest.spells.dispelMagic("0PRIO_pve", target, buff, priority)
            or project.priest.spells.dispelMagic("-1PRIO_pve", target, buff, priority)
end)