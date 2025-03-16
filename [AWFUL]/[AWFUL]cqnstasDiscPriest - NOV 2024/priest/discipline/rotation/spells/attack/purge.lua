local Unlocker, awful, project = ...

project.priest.spells.purgeTheWicked:Callback("pvp_spread", function(spell, target)
    if not target then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Purge the Wicked! pvp_spread " .. target.name, project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("pve_spread", function(spell, target)
    if not target then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Purge the Wicked! pve_spread", project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("spread", function(spell, type, target)
    if not awful.player.lockouts.holy
            and project.util.friend.danger then
        return
    end

    if awful.player.buff("Voidheart") then
        return
    end

    if awful.player.manaPct < 30 then
        if project.priest.spells.penance.cd < awful.gcd then
            return
        end
    end

    if type == "pvp" then
        return project.priest.spells.purgeTheWicked("pvp_spread", target)
    end

    return project.priest.spells.purgeTheWicked("pve_spread", target)
end)

project.priest.spells.purgeTheWicked:Callback("default", function(spell, target)
    if target.debuffRemains("Purge the Wicked") > project.util.thresholds.buff() then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Purge the Wicked! default", project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("totem_stomp", function(spell, totem)
    return spell:Cast(totem)
            and project.util.debug.alert.attack("Purge the Wicked! totem_stomp " .. totem.name, project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("pvp_stealth", function(spell, type)
    if type == "pve" then
        return
    end

    if not project.util.enemy.target.stealth then
        return
    end

    return spell:Cast(project.util.enemy.target.stealth)
            and project.util.debug.alert.attack("Purge the Wicked! pvp_stealth -> " .. project.util.enemy.target.stealth.name, project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("pvp_interrupt", function(spell, type)
    if type == "pve" then
        return
    end

    if not project.util.enemy.target.interrupt then
        return
    end

    return spell:Cast(project.util.enemy.target.interrupt)
            and project.util.debug.alert.attack("Purge the Wicked! pvp_interrupt -> " .. project.util.enemy.target.interrupt.casting, project.priest.spells.purgeTheWicked.id)
end)

project.priest.spells.purgeTheWicked:Callback("pvp_arena_combat", function(spell)
    if not awful.arena then
        return
    end

    awful.enemies.loop(function(enemy)
        if not enemy.player then
            return
        end

        if enemy.inCombat then
            return
        end

        if not project.util.check.target.viable(enemy, true) then
            return
        end

        return spell:Cast(enemy)
                and project.util.debug.alert.attack("Purge the Wicked! pvp_arena_combat", project.priest.spells.purgeTheWicked.id)
    end)
end)
