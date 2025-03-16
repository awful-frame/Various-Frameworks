local Unlocker, awful, project = ...

project.priest.spells.renew:Callback("best_atonement", function(spell, target)
    if not project.util.check.player.moving_for(1) then
        if awful.instanceType2 == "party" or awful.instanceType2 == "raid" then
            if awful.player.buff("Voidheart") and target.hp > 80 then
                return
            end

            if project.priest.spells.radiance.charges < 2 then
                if project.priest.spells.radiance.nextChargeCD > 6 then
                    return
                end
            end
        end
    end

    if awful.arena
            and awful.player.hasTalent("Ultimate Radiance")
            and project.priest.spells.radiance.charges > 1
            and awful.player.manaPct < 90
            and target.dist < 30 - 1 then
        return
    end

    if target.guid == project.util.friend.bestTarget.guid
            and project.util.friend.bestTarget.hp < 90 then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.heal("Renew! best_atonement", project.priest.spells.renew.id)
end)

project.priest.spells.renew:Callback("ramp", function(spell, target)
    return spell:Cast(target)
            and project.util.debug.alert.heal("Renew! ramp", project.priest.spells.renew.id)
end)
