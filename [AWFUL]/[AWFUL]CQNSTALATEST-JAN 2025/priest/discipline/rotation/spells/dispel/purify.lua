local Unlocker, awful, project = ...

project.priest.spells.purify:Callback("7PRIO_above50MP_above70HP_below3ENEMY", function(spell, target, debuff, priority)
    if priority ~= 7 then
        return
    end

    if awful.player.manaPct < 50 then
        return
    end

    if project.util.friend.best_target.unit.hp < 70 then
        return
    end

    if project.util.enemy.totalPlayers > 3 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! 7PRIO_above50MP_above70HP_below3ENEMY " .. info, project.priest.spells.purify.id)
end)

project.priest.spells.purify:Callback("6PRIO", function(spell, target, debuff, priority)
    if priority ~= 6 then
        return
    end

    if project.util.friend.best_target.unit.hp < 30 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! 6PRIO " .. info, project.priest.spells.purify.id)
end)

project.priest.spells.purify:Callback("below3PRIO", function(spell, target, debuff, priority)
    if priority == 0 or priority == -1 then
        return
    end

    if project.util.friend.best_target.unit.hp < 15 then
        return
    end

    if priority > 3 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! below3PRIO " .. info, project.priest.spells.purify.id)
end)

project.priest.spells.purify:Callback("45PRIO", function(spell, target, debuff, priority)
    if priority ~= 4 and priority ~= 5 then
        return
    end

    if project.util.friend.best_target.unit.hp < 30 then
        return
    end

    if priority == 5
            and project.util.friend.danger then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! 45PRIO " .. info, project.priest.spells.purify.id)
end)

project.priest.spells.purify:Callback("0PRIO_pve", function(spell, target, debuff, priority)
    if priority ~= 0 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! 0PRIO_pve " .. info, project.priest.spells.purify.id)
end)

project.priest.spells.purify:Callback("-1PRIO_pve", function(spell, target, debuff, priority)
    if priority ~= -1 then
        return
    end

    if IsPlayerSpell(project.util.id.spell.MASS_DISPEL)
            and project.priest.spells.massDispel.cd <= awful.gcd * 2 then
        return
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! -1PRIO_pve " .. info, project.priest.spells.purify.id)
end)

project.priest.spells.purify:Callback("pvp", function(spell, target, debuff, priority, has_touch_or_aff)
    if not target then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT)
            and priority > 3 then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
            and project.util.friend.danger then
        return
    end

    if has_touch_or_aff then
        if awful.player.hpa < 70 then
            return
        end

        if not awful.player.buff(project.util.id.spell.PRECOGNITION) then
            if not project.priest.discipline.rotation.util.is_premonition()
                    and awful.player.buff(project.util.id.spell.VOIDHEART) then
                return
            end

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

        return project.priest.spells.purify("below3PRIO", target, debuff, priority)
                or project.priest.spells.purify("6PRIO", target, debuff, priority)
    end

    return project.priest.spells.purify("below3PRIO", target, debuff, priority)
            or project.priest.spells.purify("45PRIO", target, debuff, priority)
            or project.priest.spells.purify("6PRIO", target, debuff, priority)
            or project.priest.spells.purify("7PRIO_above50MP_above70HP_below3ENEMY", target, debuff, priority)
end)

project.priest.spells.purify:Callback("pve", function(spell, target, debuff, priority)
    if not target then
        return
    end

    return project.priest.spells.purify("0PRIO_pve", target, debuff, priority)
            or project.priest.spells.purify("-1PRIO_pve", target, debuff, priority)
end)
