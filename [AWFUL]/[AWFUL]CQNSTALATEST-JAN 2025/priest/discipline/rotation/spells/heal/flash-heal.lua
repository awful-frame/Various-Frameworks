local Unlocker, awful, project = ...

local function should_cast_fh()
    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
            and project.util.check.target.attackers(project.util.friend.best_target.unit).total == 0 then
        return
    end

    if not awful.player.buff(project.util.id.spell.SURGE_OF_LIGHT) then
        if project.util.evade.block_cast then
            return
        end

        if awful.player.used(project.util.id.spell.VOID_SHIFT, 5)
                and project.util.friend.best_target.unit.guid == awful.player.guid then
            return
        end

        if project.priest.discipline.rotation.util.is_premonition()
                and awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT) then
            return
        end

        if project.priest.discipline.rotation.util.is_premonition()
                and awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
                and project.util.friend.danger then
            return
        end

        if not project.priest.discipline.rotation.util.is_premonition()
                and awful.player.buff(project.util.id.spell.VOIDHEART) then
            return
        end

        if project.util.friend.total == 2
                and awful.player.buffStacks(project.util.id.spell.WEAL_AND_WOE) < 6
                and project.priest.spells.penance.cd < awful.gcd then
            return
        end

        if project.util.enemy.existing_classes[project.util.id.class.HUNTER]
                and awful.player.debuff(project.util.id.spell.SCORPID_VENOM)
                and awful.player.debuffRemains(project.util.id.spell.SCORPID_VENOM) < project.priest.spells.flashHeal.castTime then
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
    if project.util.friend.best_target.unit.hp > 70 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.best_target.unit, false)
            and project.util.debug.alert.heal("Flash Heal! below70HP", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("below90HP_OOC", function(spell)
    if awful.player.inCombat then
        if project.util.check.scenario.type() == "pve" then
            if project.util.enemy.best_target.unit then
                return
            end
        end

        if project.util.check.scenario.type() == "pvp" then
            return
        end
    end

    if project.util.friend.best_target.unit.hp > 90 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.best_target.unit, false)
            and project.util.debug.alert.heal("Flash Heal! below90HP_OOC", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("below80HP_maxStacks_noDANGER", function(spell)
    if project.util.check.enemy.interrupt()
            and not awful.player.buff(project.util.id.spell.SURGE_OF_LIGHT)
            and project.util.friend.best_target.unit.hp < 30 then
        return
    end

    local stacks = 10
    if project.util.friend.total == 2 then
        stacks = 20
    end

    if awful.player.buffStacks("From Darkness Comes Light") < stacks then
        return
    end

    if project.util.friend.best_target.unit.hp > 80 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.best_target.unit, false)
            and project.util.debug.alert.heal("Flash Heal! below80HP_maxStacks_noDANGER", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("below60HP_emergency", function(spell)
    if project.util.friend.best_target.unit.hp > 60 then
        return
    end

    if project.util.check.enemy.interrupt()
            and project.util.friend.danger
            and project.priest.spells.voidShift.cd > awful.gcd * 2 then
        return
    end

    if project.priest.spells.radiance.charges > 0 then
        return
    end

    if project.priest.spells.radiance.cd < awful.gcd then
        return
    end

    if project.priest.spells.penance.cd < awful.gcd then
        return
    end

    if project.priest.spells.shield.cd < awful.gcd then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.best_target.unit, false)
            and project.util.debug.alert.heal("Flash Heal! below60HP_emergency", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("pve", function(spell)
    if not project.priest.discipline.rotation.util.is_premonition()
            and project.util.enemy.best_target.unit
            and awful.player.combat
            and not project.util.check.player.moving_for(0.2) then

        if awful.player.buff(project.util.id.spell.VOIDHEART)
                or project.priest.spells.mindBlast.cd < awful.gcd
                or awful.player.used(project.util.id.spell.VOIDWRAITH, 3)
                or awful.player.used(project.util.id.spell.MINDBENDER, 3)
                or awful.player.used(project.util.id.spell.SHADOWFIEND, 3) then

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

    if not awful.player.buff(project.util.id.spell.SURGE_OF_LIGHT) then
        return project.priest.spells.flashHeal("below90HP_OOC")
                or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
    end

    return project.priest.spells.flashHeal("below70HP")
            or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
            or project.priest.spells.flashHeal("below90HP_OOC")
            or project.priest.spells.flashHeal("protective_light")
end)

project.priest.spells.flashHeal:Callback("pvp", function(spell)
    if not should_cast_fh() then
        return
    end

    if not awful.player.buff(project.util.id.spell.SURGE_OF_LIGHT) then
        return project.priest.spells.flashHeal("below60HP_emergency")
                or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
    end

    return project.priest.spells.flashHeal("below70HP")
            or project.priest.spells.flashHeal("below80HP_maxStacks_noDANGER")
            or project.priest.spells.flashHeal("below90HP_OOC")
end)

project.priest.spells.flashHeal:Callback("ramp", function(spell, target)
    if not awful.player.buff(project.util.id.spell.SURGE_OF_LIGHT) then
        return
    end

    if target.hp > 95 then
        return
    end

    return project.util.cast.stop_moving(spell, project.util.friend.best_target.unit, false)
            and project.util.debug.alert.heal("Flash Heal! ramp", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("best_atonement", function(spell, target, type)
    if not awful.player.buff(project.util.id.spell.SURGE_OF_LIGHT) then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.SURGE_OF_LIGHT) > 3 + project.util.thresholds.buff() then
        if type == "pvp" then
            return
        end

        if project.util.friend.danger then
            return
        end

        if not project.util.check.player.moving_for(0.2) and
                (awful.instanceType2 == project.util.id.instance.PARTY or awful.instanceType2 == project.util.id.instance.RAID) then
            if not project.priest.discipline.rotation.util.is_premonition()
                    and awful.player.buff(project.util.id.spell.VOIDHEART) then
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

    return project.util.cast.stop_moving(spell, target, false)
            and project.util.debug.alert.heal("Flash Heal! best_atonement", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("protective_light", function(spell)
    if not awful.player.hasTalent(project.util.id.spell.PROTECTIVE_LIGHT_TALENT) then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PROTECTIVE_LIGHT) > 3 then
        return
    end

    return spell("pl_pve_debuffs")
            or spell("pl_party_damage")
            or spell("pl_dbm_bars")
end)

project.priest.spells.flashHeal:Callback("pl_pve_debuffs", function(spell)
    if not project.util.pve_debuffs.target then
        return
    end

    if project.util.pve_debuffs.target.guid ~= awful.player.guid then
        return
    end

    return project.util.cast.stop_moving(spell, awful.player, false)
            and project.util.debug.alert.heal("Flash Heal! pl_pve_debuffs", project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("pl_party_damage", function(spell)
    if awful.time < project.util.party_damage.early_time - spell.castTime then
        return
    end

    return project.util.cast.stop_moving(spell, awful.player, false)
            and project.util.debug.alert.heal("Flash Heal! pl_party_damage " .. project.util.party_damage.spell, project.priest.spells.flashHeal.id)
end)

project.priest.spells.flashHeal:Callback("pl_dbm_bars", function(spell)
    local dbm_spell_name = project.util.dbm_bars.check(0, 5)
    if not dbm_spell_name then
        return
    end

    return project.util.cast.stop_moving(spell, awful.player, false)
            and project.util.debug.alert.heal("Flash Heal! pl_dbm_bars " .. dbm_spell_name, project.priest.spells.flashHeal.id)
end)

