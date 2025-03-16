local Unlocker, awful, project = ...

local function get_shield_threshold(target)
    if project.util.friend.attackers.get(target.guid).t == 0 then
        return 5
    end

    if target.hp > 70 then
        return 10
    end

    if target.hp < 30 then
        return 20
    end

    return 15
end

local function should_shield(target)
    if not target then
        return
    end

    if not target.inCombat then
        return
    end

    if not awful.player.buff("Rapture") then
        if awful.player.buffRemains("Premonition of Insight") > 3
                and awful.player.buffStacks("Weal and Woe") < 6 then
            return
        end
    end

    if not project.util.friend.danger
            and awful.player.buff("Shadow Covenant")
            and awful.player.buffRemains("Premonition of Insight") > 3
            and not awful.player.lockouts.shadow then
        return
    end

    if target.buff("Atonement")
            and target.buff("Power Word: Shield")
            and target.hpa - target.hp > get_shield_threshold(target) then
        return
    end

    if awful.player.buff("Premonition of Solace")
            and project.util.friend.attackers.get(target.guid).t == 0 then
        return
    end

    return true
end

project.priest.spells.shield:Callback("pve", function(spell)
    if not should_shield(project.util.friend.bestTarget) then
        return
    end

    if not project.util.check.player.moving_for(1) then
        if awful.player.buff("Voidheart")
                or awful.player.used(project.priest.spells.voidwraith.id, 3)
                or awful.player.used(123040, 3)
                or awful.player.used(project.priest.spells.shadowfiend.id, 3) then
            if project.util.friend.bestTarget.buff("Atonement") then
                return
            end

            if project.util.friend.bestTarget.hp > 90 then
                return
            end

            if project.priest.spells.radiance.charges < 2 then
                if project.priest.spells.radiance.nextChargeCD > 6 then
                    return
                end
            end
        end
    end

    return spell:Cast(project.util.friend.bestTarget)
            and project.util.debug.alert.heal("Power Word: Shield! pve", project.priest.spells.shield.id)
end)

project.priest.spells.shield:Callback("pvp", function(spell)
    if not should_shield(project.util.friend.bestTarget) then
        return
    end

    if not project.util.check.player.moving_for(1) then
        if awful.player.buff("Voidheart") then
            if project.util.friend.bestTarget.buff("Atonement") then
                return
            end
        end
    end

    return spell:Cast(project.util.friend.bestTarget)
            and project.util.debug.alert.heal("Power Word: Shield! pvp", project.priest.spells.shield.id)
end)

project.priest.spells.shield:Callback("best_atonement", function(spell, target, type)
    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if awful.player.buff("Premonition of Solace") then
        return
    end

    if awful.player.buffStacks("Weal and Woe") >= 4 then
        return
    end

    if awful.player.buff("Darkness from Light") then
        return
    end

    if target.guid ~= project.util.friend.bestTarget.guid
            and project.util.friend.danger then
        return
    end

    if not project.util.check.player.moving_for(1) then
        if awful.player.buff("Voidheart") and target.hp > 80 then
            return
        end

        if awful.instanceType2 == "party" or awful.instanceType2 == "raid" then
            if project.priest.spells.radiance.charges < 2 then
                if project.priest.spells.radiance.nextChargeCD > 6 then
                    return
                end
            end
        end
    end

    return spell:Cast(target)
            and project.util.debug.alert.heal("Power Word: Shield! best_atonement", project.priest.spells.shield.id)
end)

project.priest.spells.shield:Callback("ramp", function(spell, target)
    return spell:Cast(target)
            and project.util.debug.alert.heal("Power Word: Shield! ramp", project.priest.spells.shield.id)
end)