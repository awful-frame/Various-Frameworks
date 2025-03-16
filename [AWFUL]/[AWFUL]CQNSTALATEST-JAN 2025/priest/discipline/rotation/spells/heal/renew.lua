local Unlocker, awful, project = ...

project.priest.spells.renew:Callback("best_atonement", function(spell, target)
    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE) then
        return
    end

    if awful.instanceType2 == project.util.id.instance.RAID
            and project.priest.spells.mindBlast.cd < awful.gcd then
        return
    end

    if not project.util.check.player.moving_for(0.2) and
            (awful.instanceType2 == project.util.id.instance.PARTY or awful.instanceType2 == project.util.id.instance.RAID) then

        if not project.priest.discipline.rotation.util.is_premonition()
                and awful.player.buff(project.util.id.spell.VOIDHEART)
                and target.hp > 80 then
            return
        end

        if project.priest.spells.radiance.charges == 1
                and project.priest.spells.radiance.nextChargeCD < 3 then
            return
        end

        if project.priest.spells.radiance.charges == 2 then
            return
        end
    end

    if awful.arena
            and awful.player.hasTalent(project.util.id.spell.ULTIMATE_RADIANCE_TALENT)
            and awful.player.manaPct < 90
            and target.dist < 30 then
        if awful.player.manaPct < 90
                and target.hp > 90 then
            return
        end

        if project.priest.spells.radiance.charges == 1
                and project.priest.spells.radiance.nextChargeCD < 3 then
            return
        end

        if project.priest.spells.radiance.charges == 2 then
            return
        end
    end

    if target.guid == project.util.friend.best_target.unit.guid then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.heal("Renew! best_atonement", project.priest.spells.renew.id)
end)

project.priest.spells.renew:Callback("ramp", function(spell, target)
    return spell:Cast(target)
            and project.util.debug.alert.heal("Renew! ramp", project.priest.spells.renew.id)
end)
