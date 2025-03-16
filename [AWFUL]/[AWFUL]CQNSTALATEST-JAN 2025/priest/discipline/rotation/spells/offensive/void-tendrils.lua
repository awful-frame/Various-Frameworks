local Unlocker, awful, project = ...

project.priest.spells.voidTendrils:Callback("pvp_multiple", function(spell, enemies)
    enemies.loop(function(enemy)
        if project.util.check.target.cooldowns(enemy.target, enemy).total > 0 then
            return spell:Cast()
                    and project.util.debug.alert.offensive("Void Tendrils! pvp_atleast1CD", project.priest.spells.voidTendrils.id)
        end

        if project.util.check.target.attackers(enemy).total > 0 then
            return spell:Cast()
                    and project.util.debug.alert.offensive("Void Tendrils! pvp_attacker", project.priest.spells.voidTendrils.id)
        end

        if enemy.isHealer
                and project.priest.spells.psychicScream.cd > awful.gcd then
            return spell:Cast()
                    and project.util.debug.alert.offensive("Void Tendrils! pvp_healer", project.priest.spells.voidTendrils.id)
        end

        if enemy.class3 == project.util.id.class.HUNTER then
            return spell:Cast()
                    and project.util.debug.alert.offensive("Void Tendrils! pvp_hunter", project.priest.spells.voidTendrils.id)
        end

        if enemy.melee then
            return spell:Cast()
                    and project.util.debug.alert.offensive("Void Tendrils! pvp_melee", project.priest.spells.voidTendrils.id)
        end
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

project.priest.spells.voidTendrils:Callback("pve", function(spell, count, enemies)
    if not project.settings.priest_offensives_void_tendrils then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.ttd < 3 then
        return
    end

    if count == 0 then
        return
    end

    return project.priest.spells.voidTendrils("above3", count)
end)

project.priest.spells.voidTendrils:Callback("pvp", function(spell, count, enemies)
    if not project.settings.priest_offensives_void_tendrils then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if count == 0 then
        return
    end

    return project.priest.spells.voidTendrils("pvp_multiple", enemies)
            or project.priest.spells.voidTendrils("above2", count)
end)


