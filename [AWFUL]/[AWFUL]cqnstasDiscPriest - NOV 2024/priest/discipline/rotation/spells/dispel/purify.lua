local Unlocker, awful, project = ...

project.priest.spells.purify:Callback("7PRIO_above50MP_above70HP_below3ENEMY", function(spell, target, debuff, priority)
    if priority ~= 7 then
        return
    end

    if awful.player.manaPct < 50 then
        return
    end

    if project.util.friend.bestTarget.hp < 70 then
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
    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! 6PRIO " .. info, project.priest.spells.purify.id)
end)

project.priest.spells.purify:Callback("below5PRIO", function(spell, target, debuff, priority)
    if priority == 0 or priority == -1 then
        return
    end

    if priority > 5 then
        return
    end

    if debuff == "Flame Shock" then
        if not awful.player.hasTalent("Mental Agility")
                and not awful.player.hasTalent("Purification") then
            return
        end

        if awful.player.manaPct < 50 then
            return
        end

        if project.util.friend.danger or project.util.enemy.danger then
            return
        end

        if not awful.arena then
            return
        end
    end

    local info = "Friend: " .. target.name .. ". Debuff: " .. debuff .. ". Prio: " .. priority
    return spell:Cast(target)
            and project.util.debug.alert.dispel("Purify! below5PRIO " .. info, project.priest.spells.purify.id)
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

    if IsPlayerSpell(32375) and project.priest.spells.massDispel.cd <= awful.gcd * 2 then
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

    if awful.player.buff("Premonition of Insight")
            and priority > 3 then
        return
    end

    if has_touch_or_aff then
        if awful.player.buff("Voidheart") then
            return
        end

        if project.util.enemy.withOffensiveCds > 0 then
            return
        end

        if awful.player.hpa < 95 then
            return
        end

        if project.util.friend.bestTarget.hp < 80 then
            return
        end

        return project.priest.spells.purify("below5PRIO", target, debuff, priority)
                or project.priest.spells.purify("6PRIO", target, debuff, priority)
    end

    return project.priest.spells.purify("below5PRIO", target, debuff, priority)
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
