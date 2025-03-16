local Unlocker, awful, project = ...

local function get_shield_threshold(target)
    if not target.buff(project.util.id.spell.POWER_WORD_SHIELD) then
        return 100
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE) then
        return 15
    end

    if project.util.check.target.attackers(target).total == 0 then
        return 0
    end

    if project.util.enemy.totalViable <= 2 then
        return 0
    end

    if target.hp > 80 then
        return 0
    end

    if target.hp < 30 then
        return 15
    end

    return 10
end

local function should_shield(target)
    if not target then
        return
    end

    if not awful.player.buff(project.util.id.spell.RAPTURE) then
        if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3
                and not project.util.friend.danger
                and awful.player.buffStacks(project.util.id.spell.WEAL_AND_WOE) < 6 then
            return
        end
    end

    if not project.util.friend.danger
            and awful.player.buff(project.util.id.spell.SHADOW_COVENANT)
            and awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3
            and not awful.player.lockouts.shadow then
        return
    end

    if target.buff(project.util.id.spell.ATONEMENT)
            and target.buff(project.util.id.spell.POWER_WORD_SHIELD)
            and target.hpa - target.hp > get_shield_threshold(target) then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
            and project.util.check.target.attackers(target).total == 0 then
        return
    end

    return true
end

project.priest.spells.shield:Callback("pve", function(spell)
    if not should_shield(project.util.friend.best_target.unit) then
        return
    end

    if not awful.player.combat
            and not awful.player.moving then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.combat
            and project.util.enemy.best_target.unit
            and not project.util.check.player.moving_for(0.2) then

        if awful.player.buff(project.util.id.spell.VOIDHEART)
                or project.priest.spells.mindBlast.cd < awful.gcd
                or awful.player.used(project.priest.spells.voidwraith.id, 3)
                or awful.player.used(project.util.id.spell.MINDBENDER, 3)
                or awful.player.used(project.priest.spells.shadowfiend.id, 3) then
            if project.util.friend.best_target.unit.buff(project.util.id.spell.ATONEMENT) then
                return
            end

            if project.util.friend.best_target.unit.hp > 90 then
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
    end

    return spell:Cast(project.util.friend.best_target.unit)
            and project.util.debug.alert.heal("Power Word: Shield! pve", project.priest.spells.shield.id)
end)

project.priest.spells.shield:Callback("pvp", function(spell)
    if not should_shield(project.util.friend.best_target.unit) then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and not project.util.check.player.moving_for(0.2)
            and awful.player.buff(project.util.id.spell.VOIDHEART)
            and project.util.friend.best_target.unit.buff(project.util.id.spell.ATONEMENT) then
        return
    end

    return spell:Cast(project.util.friend.best_target.unit)
            and project.util.debug.alert.heal("Power Word: Shield! pvp", project.priest.spells.shield.id)
end)

project.priest.spells.shield:Callback("best_atonement", function(spell, target, type)
    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE) then
        return
    end

    if type == "pvp" then
        if awful.player.buffStacks(project.util.id.spell.WEAL_AND_WOE) >= 4 then
            return
        end

        if awful.player.buffRemains(project.util.id.spell.RAPTURE) > 10 then
            return
        end

        if awful.player.buff(project.util.id.spell.DARKNESS_FROM_LIGHT) then
            return
        end
    end

    if target.guid ~= project.util.friend.best_target.unit.guid
            and project.util.friend.danger then
        return
    end

    if not project.util.check.player.moving_for(0.2) then

        if not project.priest.discipline.rotation.util.is_premonition()
                and awful.player.buff(project.util.id.spell.VOIDHEART)
                and target.hp > 80 then
            return
        end

        if awful.instanceType2 == project.util.id.instance.PARTY
                or awful.instanceType2 == project.util.id.instance.RAID then

            if project.priest.spells.radiance.charges == 1
                    and project.priest.spells.radiance.nextChargeCD < 3 then
                return
            end

            if project.priest.spells.radiance.charges == 2 then
                return
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