local Unlocker, awful, project = ...

local function should_penance()
    if awful.player.buff(project.util.id.spell.RAPTURE)
            and project.util.check.enemy.interrupt()
            and project.util.friend.best_target.unit.hp < 50
            and not awful.player.buff(project.util.id.spell.SHADOW_COVENANT) then
        return
    end

    if project.util.enemy.existing_classes[project.util.id.class.HUNTER]
            and awful.player.debuff(project.util.id.spell.SCORPID_VENOM)
            and awful.player.debuffRemains(project.util.id.spell.SCORPID_VENOM) < 2 then
        return
    end

    if project.util.evade.block_cast then
        return
    end

    if awful.player.buffStacks(project.util.id.spell.WEAL_AND_WOE) >= 6 then

        if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then

            if not project.util.friend.danger
                    and project.util.enemy.best_target.unit
                    and project.util.cast.stop_moving(project.priest.spells.smite, project.util.enemy.best_target.unit, true) then
                project.util.debug.alert.offensive("Insight 8 WAW Penance -> Smite!", project.priest.spells.darkArchangel.id)
            end

        else
            return
        end
    end

    return true
end

local function get_heal_threshold()
    if not awful.player.inCombat then
        return 90
    end

    if not project.util.enemy.best_target.unit then
        if project.util.check.scenario.type() == "pvp" then
            return 60
        end

        if project.util.check.scenario.type() == "pve" then
            return 90
        end
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART)
            and project.util.friend.best_target.unit.buff(project.util.id.spell.ATONEMENT) then
        return 20
    end

    if project.util.check.scenario.type() == "pve" then
        if awful.instanceType2 == project.util.id.instance.RAID then
            return 5
        end

        return 20
    end

    local threshold = 60

    if awful.player.buff(project.util.id.spell.INNER_SHADOW) then
        threshold = threshold - 5
    end

    if project.util.friend.danger then
        threshold = threshold + 10
    end

    if project.util.enemy.danger then
        threshold = threshold - 10
    end

    if project.util.enemy.total_cds > 0 then
        threshold = threshold + 10
    end

    if project.priest.discipline.rotation.util.full_aton() then
        threshold = threshold - 10
    end

    if awful.player.buff(project.util.id.spell.SHADOW_COVENANT) then
        threshold = threshold - 10
    end

    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        threshold = threshold - 10
        if awful.player.buff(project.util.id.spell.PREMONITION_OF_PIETY) then
            threshold = threshold - 10
        end
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE) then
        threshold = threshold + 20
        if project.util.friend.danger then
            threshold = threshold + 10
        end
    end

    if project.util.friend.best_target.defensives.def > 0 then
        threshold = threshold - 5
    end

    if project.util.friend.best_target.defensives.def_best > 0 then
        threshold = threshold - 5
    end

    if awful.player.buff(project.util.id.spell.HARSH_DISCIPLINE) then
        threshold = threshold - 5 * awful.player.buffStacks(project.util.id.spell.HARSH_DISCIPLINE)
    end

    if project.util.check.target.attackers(project.util.friend.best_target.unit).total == 0 then
        threshold = threshold - 20
    end

    if threshold > 60 then
        return 60
    end

    if threshold < 20 then
        return 20
    end

    return threshold
end

project.priest.spells.penance:Callback("heal", function(spell, key)
    if not should_penance() then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
            and project.util.check.target.attackers(project.util.friend.best_target.unit).total == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > get_heal_threshold() then
        return
    end

    if not project.util.friend.best_target.unit.playerFacing then
        awful.player.face(project.util.friend.best_target.unit)
    end

    return spell:Cast(project.util.friend.best_target.unit)
            and project.util.debug.alert.heal("Penance! heal " .. key .. get_heal_threshold(), project.priest.spells.penance.id)
end)

project.priest.spells.penance:Callback("attack", function(spell, target, key)
    if not should_penance() then
        return
    end

    local target_info = "off_target"
    if awful.target.guid == target.guid then
        target_info = "main_target"
    end

    target_info = target_info .. get_heal_threshold()

    if not target.debuff(project.util.id.spell.PURGE_THE_WICKED_DEBUFF) then
        return
    end

    if project.util.friend.best_target.unit.hp < 90
            and not project.util.friend.best_target.unit.buff(project.util.id.spell.ATONEMENT) then
        return
    end

    if not target.playerFacing then
        awful.player.face(target)
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Penance! attack " .. target_info .. " " .. key, project.priest.spells.penance.id)
end)

project.priest.spells.penance:Callback("from_attack", function(spell, target)
    if not target then
        return project.priest.spells.penance("heal", "attack_noTARGET")
    end

    if not target.enemy then
        return project.priest.spells.penance("heal", "attack_noENTARGET")
    end

    if target.ttd < 2
            and not awful.arena then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and not project.util.check.player.moving_for(0.2)
            and awful.player.buff(project.util.id.spell.VOIDHEART)
            and project.util.enemy.withPurge == project.util.enemy.totalCombat
            and not awful.player.buff(project.util.id.spell.SHADOW_COVENANT)
            and project.util.friend.best_target.unit.hpa < 40 then
        return
    end

    return project.priest.spells.penance("attack", target, "spam")
end)

project.priest.spells.penance:Callback("from_heal", function(spell)
    return project.priest.spells.penance("heal", "spam")
            or project.priest.spells.penance("arena_start")
end)

project.priest.spells.penance:Callback("arena_start", function(spell)
    if not awful.arena then
        return
    end

    if awful.player.combat then
        return
    end

    if awful.player.manaPct < 95 then
        return
    end

    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    return spell:Cast(awful.player)
            and project.util.debug.alert.heal("Penance! arena_start", project.priest.spells.penance.id)
end)

project.priest.spells.penance:Callback("totem_stomp", function(spell, totem)
    if not should_penance() then
        return
    end

    if awful.player.buffStacks(project.util.id.spell.WEAL_AND_WOE) >= 6 then
        return
    end

    if awful.player.buff(project.util.id.spell.POWER_OF_THE_DARK_SIDE) then
        return
    end

    if project.util.friend.best_target.unit.hp < 60 then
        return
    end

    if project.util.friend.best_target.unit.hp < 90
            and not project.util.friend.best_target.unit.buff(project.util.id.spell.ATONEMENT) then
        return
    end

    if not totem.playerFacing then
        awful.player.face(totem)
    end

    return spell:Cast(totem)
            and project.util.debug.alert.attack("Penance! totem_stomp " .. totem.name, project.priest.spells.penance.id)
end)
