local Unlocker, awful, project = ...

local function should_cast_fh()
    if awful.player.buff("Premonition of Solace")
            and project.util.friend.attackers.get(project.util.friend.bestTarget.guid).t == 0 then
        return
    end

    if not awful.player.buff("Surge of Light") then
        if awful.player.buff("Voidheart") then
            return
        end

        if awful.player.buffStacks("Weal and Woe") < 6 then
            if project.priest.spells.penance.cd < awful.gcd then
                return
            end
        end

        if awful.player.debuff("Scorpid Venom")
                and awful.player.debuffRemains("Scorpid Venom") < project.priest.spells.flashHeal.castTime then
            return
        end

        if not project.priest.discipline.rotation.util.is_premonition() then
            if project.priest.spells.mindBlast.cd < awful.gcd then
                return
            end
        end
    end

    return true
end

project.priest.spells.flashHeal:Callback("below70HP", function(spell)
    if project.util.friend.bestTarget.hp > 70 then
        return
    end

    return spell:Cast(project.util.friend.bestTarget)
            and project.util.debug.alert.heal("Flash Heal! below70HP", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("below90HP_OOC", function(spell)
    if awful.player.inCombat then
        return
    end

    if project.util.friend.bestTarget.hp > 90 then
        return
    end

    return spell:Cast(project.util.friend.bestTarget)
            and project.util.debug.alert.heal("Flash Heal! below90HP_OOC", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("below90HP_precog", function(spell)
    if project.util.friend.bestTarget.hp > 90 then
        return
    end

    if awful.player.buffRemains(377362) <= project.util.thresholds.buff() + spell.castTime - 1 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.bestTarget, false)
            and project.util.debug.alert.heal("Flash Heal! below90HP_precog", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("below80HP_maxStacks_noDANGER", function(spell)
    if project.util.check.enemy.interrupt() then
        if not awful.player.buff("Surge of Light") and project.util.friend.danger then
            return
        end
    end

    if awful.player.buffStacks("From Darkness Comes Light") < 18 then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.bestTarget, false)
            and project.util.debug.alert.heal("Flash Heal! below80HP_maxStacks_noDANGER", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("below80HP_noINTERRUPT", function(spell)
    if project.util.friend.danger then
        return
    end

    if project.util.check.enemy.interrupt() then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.bestTarget, false)
            and project.util.debug.alert.heal("Flash Heal! below80HP_noINTERRUPT", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("pve", function(spell)
    if project.util.friend.inCombat
            and not project.util.check.player.moving_for(1) then
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

    if not awful.player.buff("Surge of Light") then
        return project.priest.spells.flashHeal("below90HP_OOC")
                or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
    end

    return project.priest.spells.flashHeal("below70HP")
            or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
            or project.priest.spells.flashHeal("below90HP_OOC")
end)

project.priest.spells.flashHeal:Callback("pvp", function(spell)
    if not should_cast_fh() then
        return
    end

    if not awful.player.buff("Surge of Light") then
        return project.priest.spells.flashHeal("below90HP_precog")
                or project.priest.spells.flashHeal("below80HP_noINTERRUPT")
                or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
    end

    return project.priest.spells.flashHeal("below70HP")
            or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
            or project.priest.spells.flashHeal("below90HP_OOC")
end)

project.priest.spells.flashHeal:Callback("ramp", function(spell, target)
    if not awful.player.buff("Surge of Light") then
        return
    end

    if target.hp > 95 then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.heal("Flash Heal! ramp", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("best_atonement", function(spell, target, type)
    if not awful.player.buff("Surge of Light") then
        return
    end

    if awful.player.buffRemains("Surge of Light") > 3 + project.util.thresholds.buff() then
        if type == "pvp" then
            return
        end

        if project.util.friend.danger then
            return
        end

        if not project.util.check.player.moving_for(1) then
            if awful.instanceType2 == "party" or awful.instanceType2 == "raid" then
                if awful.player.buff("Voidheart") then
                    return
                end

                if project.priest.spells.radiance.charges < 2 then
                    if project.priest.spells.radiance.nextChargeCD > 6 then
                        return
                    end
                end
            end
        end
    end

    return spell:Cast(target)
            and project.util.debug.alert.heal("Flash Heal! best_atonement", project.priest.spells.flashHeal.id)
end)