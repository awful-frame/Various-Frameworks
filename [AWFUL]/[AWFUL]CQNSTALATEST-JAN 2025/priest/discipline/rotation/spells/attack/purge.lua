local Unlocker, awful, project = ...

project.priest.spells.purgeTheWicked:Callback("pvp_spread", function(spell, target)
    if not target then
        return
    end

    if project.util.friend.best_target.unit.hp < 20 then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Purge the Wicked! pvp_spread " .. target.name, project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("pve_spread", function(spell, target)
    if not target then
        return
    end

    if not awful.player.moving then
        return
    end

    if project.priest.spells.penance.cd < awful.gcd then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Purge the Wicked! pve_spread", project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("spread", function(spell, type)
    if not awful.player.lockouts.holy and project.util.friend.danger then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then
        return
    end

    local target_to_spread_purge = project.util.check.enemy.spread(
            project.util.id.spell.PURGE_THE_WICKED_DEBUFF,
            type == "pvp",
            false,
            type == "pve"
    )

    if type == "pvp" then
        return project.priest.spells.purgeTheWicked("pvp_spread", target_to_spread_purge)
    end

    return project.priest.spells.purgeTheWicked("pve_spread", target_to_spread_purge)
end)

project.priest.spells.purgeTheWicked:Callback("default", function(spell, target)
    if project.util.friend.best_target.unit.hp < 20 then
        return
    end

    if target.debuffRemains(project.util.id.spell.PURGE_THE_WICKED_DEBUFF) > project.util.thresholds.buff() then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Purge the Wicked! default", project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("totem_stomp", function(spell, totem)
    return spell:Cast(totem)
            and project.util.debug.alert.attack("Purge the Wicked! totem_stomp " .. totem.name, project.priest.spells.purgeTheWicked.id)
end)
