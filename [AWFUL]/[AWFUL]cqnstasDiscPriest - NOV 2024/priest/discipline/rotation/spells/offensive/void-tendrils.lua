local Unlocker, awful, project = ...

project.priest.spells.voidTendrils:Callback("pvp_atleast1CD", function(spell, enemies)
    enemies.loop(function(enemy)
        local total = project.util.check.target.cooldowns(enemy.target, enemy)
        if total == 0 then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.offensive("Void Tendrils! pvp_atleast1CD", project.priest.spells.voidTendrils.id)
    end)
end)

project.priest.spells.voidTendrils:Callback("above2", function(spell, count)
    if count < 2 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.offensive("Void Tendrils! above2", project.priest.spells.voidTendrils.id)
end)

project.priest.spells.voidTendrils:Callback("above3", function(spell, count)
    if count < 3 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.offensive("Void Tendrils! above3", project.priest.spells.voidTendrils.id)
end)

project.priest.spells.voidTendrils:Callback("pve", function(spell)
    if not project.settings.priest_offensives_void_tendrils then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if project.util.enemy.bestTarget
            and project.util.enemy.bestTarget.ttd < 3 then
        return
    end

    local count = awful.enemies.around(awful.player, 5, function(enemy)
        if enemy.dead then
            return
        end

        if enemy.level > awful.player.level or enemy.level == -1 then
            return
        end
    end)

    if count == 0 then
        return
    end

    return project.priest.spells.voidTendrils("above3", count)
end)

project.priest.spells.voidTendrils:Callback("pvp", function(spell)
    if not project.settings.priest_offensives_void_tendrils then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    local count, _, enemies = awful.enemies.around(awful.player, 5, function(enemy)
        if enemy.dead then
            return
        end

        if enemy.immuneMagicEffects then
            return
        end

        if enemy.buff("Blessing of Freedom") then
            return
        end

        if enemy.buff("Master's Call") then
            return
        end

        if enemy.rooted then
            return
        end

        if enemy.cc then
            return
        end
    end)

    if count == 0 then
        return
    end

    return project.priest.spells.voidTendrils("pvp_atleast1CD", enemies)
            or project.priest.spells.voidTendrils("above2", count)
end)


