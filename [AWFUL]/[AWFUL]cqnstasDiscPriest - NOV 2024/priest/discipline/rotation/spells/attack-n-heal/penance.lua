local Unlocker, awful, project = ...

local function should_penance()
    if awful.player.buff("Rapture")
            and project.util.check.enemy.interrupt()
            and project.util.friend.bestTarget.hp < 30
            and not awful.player.buff("Shadow Covenant") then
        return
    end

    if awful.player.debuff("Scorpid Venom")
            and awful.player.debuffRemains("Scorpid Venom") < 2 then
        return
    end

    return true
end

local function get_heal_threshold()
    if not awful.player.inCombat then
        return 90
    end

    if not project.util.enemy.bestTarget then
        return 60
    end

    if awful.player.buff("Voidheart")
            and project.util.friend.bestTarget.buff("Atonement") then
        return 20
    end

    if project.util.check.scenario.type() == "pve" then
        return 20
    end

    local threshold = 60

    if awful.player.buff("Inner Shadow") then
        threshold = threshold - 5
    end

    if project.util.friend.danger then
        threshold = threshold + 10
    end

    if project.util.enemy.withOffensiveCds > 0 then
        threshold = threshold + 10
    end

    if project.priest.discipline.rotation.util.full_aton() then
        threshold = threshold - 10
    end

    if awful.player.buff("Shadow Covenant") then
        threshold = threshold - 10
    end

    if awful.player.buff("Power of the Dark Side") then
        threshold = threshold - 10
        if awful.player.buff("Premonition of Piety") then
            threshold = threshold - 10
        end
    end

    if awful.player.buff("Power of the Dark Side")
            and awful.player.buff("Harsh Discipline") then
        threshold = threshold - 5 * awful.player.buffStacks("Harsh Discipline")
    end

    if threshold > 60 then
        return 60
    end

    return threshold
end

project.priest.spells.penance:Callback("heal", function(spell, key)
    if not should_penance() then
        return
    end

    if awful.player.buff("Premonition of Solace")
            and project.util.friend.attackers.get(project.util.friend.bestTarget.guid).t == 0 then
        return
    end

    if project.util.friend.bestTarget.hp > get_heal_threshold() then
        return
    end

    if project.util.enemy.danger
            and project.util.friend.bestTarget.buff("Atonement")
            and project.util.friend.bestTarget.hp > 30 then
        return
    end

    if not project.util.friend.bestTarget.playerFacing then
        awful.player.face(project.util.friend.bestTarget)
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.heal("Penance! heal " .. key, project.priest.spells.penance.id)
end)

project.priest.spells.penance:Callback("attack", function(spell, target, key)
    if not target then
        return
    end

    if not should_penance() then
        return
    end

    if awful.player.buffStacks("Weal and Woe") >= 6 then
        if awful.player.buffRemains("Premonition of Insight") > 3 then
            if project.util.cast.stop_moving(project.priest.spells.smite, project.util.enemy.bestTarget, true, true) then
                project.util.debug.alert.offensive("Insight 8 WAW Penance -> Smite!", project.priest.spells.darkArchangel.id)
            end
        else
            return
        end
    end

    local target_info = "off_target"
    if awful.target.guid == target.guid then
        target_info = "main_target"
    end

    if not target.debuff("Purge the Wicked") then
        return
    end

    if not project.util.friend.bestTarget.buff("Atonement") then
        return
    end

    if not target.playerFacing then
        awful.player.face(target)
    end

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.attack("Penance! attack " .. target_info .. " " .. key, project.priest.spells.penance.id)
end)

project.priest.spells.penance:Callback("expirePOTDS", function(spell, target)
    if not awful.player.buff("Power of the Dark Side") then
        return
    end

    if awful.player.buffRemains("Power of the Dark Side") > project.util.thresholds.buff() then
        return
    end

    local key = "expirePOTDS"
    return project.priest.spells.penance("heal", key)
            or project.priest.spells.penance("attack", target, key)
end)

project.priest.spells.penance:Callback("expireWAW", function(spell, target)
    if not awful.player.buff("Weal and Woe") then
        return
    end

    if awful.player.buffRemains("Weal and Woe") > 2 + project.util.thresholds.buff() then
        return
    end

    local key = "expireWAW"
    return project.priest.spells.penance("heal", key)
            or project.priest.spells.penance("attack", target, key)
end)

project.priest.spells.penance:Callback("expireHD", function(spell, target)
    if not awful.player.buff("Harsh Discipline") then
        return
    end

    if awful.player.buffRemains("Harsh Discipline") > project.util.thresholds.buff() then
        return
    end

    local key = "expireHD"
    return project.priest.spells.penance("heal", key)
            or project.priest.spells.penance("attack", target, key)
end)

project.priest.spells.penance:Callback("from_attack", function(spell, target)
    local expire = project.priest.spells.penance("expireWAW")
            or project.priest.spells.penance("expireHD")
            or project.priest.spells.penance("expirePOTDS")

    if expire then
        return
    end

    if not target then
        return project.priest.spells.penance("heal", "below8WAW")
    end

    if target.enemy
            and target.ttd < 2
            and not awful.arena then
        return
    end

    if not target.enemy then
        return project.priest.spells.penance("heal", "below8WAW")
    end

    if not project.util.check.player.moving_for(1) then
        if awful.player.buff("Voidheart")
                and not awful.player.buff("Shadow Covenant") then
            return
        end
    end

    return project.priest.spells.penance("attack", target, "below8WAW")
end)

project.priest.spells.penance:Callback("from_heal", function(spell)
    local expire = project.priest.spells.penance("expireWAW")
            or project.priest.spells.penance("expireHD")
            or project.priest.spells.penance("expirePOTDS")

    if expire then
        return
    end

    if awful.player.inCombat
            and awful.player.buffStacks("Weal and Woe") >= 6 then
        return
    end

    return project.priest.spells.penance("heal", "below8WAW")
end)

project.priest.spells.penance:Callback("totem_stomp", function(spell, totem)
    if not should_penance() then
        return
    end

    if awful.player.buffStacks("Weal and Woe") >= 6 then
        return
    end

    if awful.player.buff("Power of the Dark Side") then
        return
    end

    if awful.player.buff("Harsh Discipline") then
        return
    end

    if project.util.friend.bestTarget.hp < 60 then
        return
    end

    if not project.util.friend.bestTarget.buff("Atonement") then
        return
    end

    if not totem.playerFacing then
        awful.player.face(totem)
    end

    return project.util.cast.overlap.cast(spell, totem)
            and project.util.debug.alert.attack("Penance! totem_stomp " .. totem.name, project.priest.spells.penance.id)
end)
