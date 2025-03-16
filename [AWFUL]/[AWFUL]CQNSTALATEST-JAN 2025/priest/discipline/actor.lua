local Unlocker, awful, project = ...

local function should_routine()
    if not awful.enabled then
        return
    end

    if not awful.player then
        return
    end

    if awful.player.dead then
        return
    end

    if awful.player.mounted then
        return
    end

    if not awful.player.inCombat then

        if awful.player.castID == project.util.id.spell.MASS_RESURRECTION
                or awful.player.castID == project.util.id.spell.RESURRECTION
                or awful.player.castID == project.util.id.spell.CAPTURING then
            return
        end

        if awful.player.manaPct < 95
                and awful.player.buffFrom({ project.util.id.spell.REFRESHMENT, project.util.id.spell.ARENA_DRINK }) then
            return
        end
    end

    return true
end

local function util_routine(scenario_type)
    if awful.instanceType2 == project.util.id.instance.PARTY then
        awful.ttd_enabled = true
    else
        awful.ttd_enabled = false
    end

    project.util.cast.block.check()
    project.util.cast.bcc()
    project.util.cast.overlap.reset()

    project.util.scan.friends()
    project.util.scan.enemies(scenario_type)

    project.util.scan.pve_debuffs(scenario_type)
    project.util.scan.dbm_bars(scenario_type)

    project.util.best_target.select()

    project.util.evade.predict()
    project.util.evade.missiles()
    project.util.evade.triggers()

    if awful.player.ccRemains > 2 then
        project.util.evade.reset()
    end
end

local function routine()
    if not should_routine() then
        return
    end
    local scenario_type = project.util.check.scenario.type()
    util_routine(scenario_type)

    project.priest.discipline.rotation.util.own_cds()

    if awful.player.channelID == project.util.id.spell.MIND_CONTROL then
        if project.util.friend.best_target.unit.hp < 20 then
            awful.call("SpellStopCasting")
        end

        return
    end

    if project.util.cast.block.spell == project.util.id.spell.MIND_CONTROL
            or project.util.cast.block.spell == project.util.id.spell.ULTIMATE_PENITENCE then
        project.priest.discipline.rotation.evade(scenario_type)
        return
    end

    if IsPlayerSpell(project.util.id.spell.ULTIMATE_PENITENCE)
            and awful.player.buff(project.util.id.spell.ULTIMATE_PENITENCE)
            and awful.player.buffUptime(project.util.id.spell.ULTIMATE_PENITENCE) < 1 then
        return
    end

    if project.settings.priest_evade_enabled then
        if project.util.evade.block_cast then
            project.util.debug.alert.evade("Evade! hold_gcd block_cast " .. tostring(project.util.evade.holdGCD))
        end

        if project.util.evade.holdGCD then
            if project.util.evade.casting_enemy and not project.util.evade.casting_enemy.castID then
                project.util.evade.reset()
                return
            end

            project.util.debug.alert.evade("Evade! hold_gcd block_cast " .. tostring(project.util.evade.holdGCD))
            project.priest.discipline.rotation.evade(scenario_type)
            project.priest.discipline.rotation.cc(scenario_type)
            return
        end
    end

    if project.util.cc.holdGCD then
        project.util.debug.alert.evade("CC! hold_gcd")
        project.priest.discipline.rotation.evade(scenario_type)
        project.priest.discipline.rotation.cc(scenario_type)
        return
    end

    if scenario_type == "pvp"
            and project.util.enemy.existing_classes[project.util.id.class.PALADIN]
            and awful.player.debuff(project.util.id.spell.SEARING_GLARE_DEBUFF) then
        awful.call("SpellStopCasting")
        project.priest.discipline.rotation.evade(scenario_type)
        project.priest.discipline.rotation.dispel(scenario_type)
        return
    end

    project.priest.discipline.rotation.ramp()
    if project.settings.priest_ramp then
        project.priest.discipline.rotation.dispel(scenario_type)
        project.priest.discipline.rotation.defensive(scenario_type)
        project.priest.discipline.rotation.beneficial(scenario_type)
        return
    end

    -- misc
    project.priest.discipline.rotation.evade(scenario_type)
    project.priest.discipline.rotation.dispel(scenario_type)
    project.priest.discipline.rotation.cc(scenario_type)

    -- heal
    project.priest.discipline.rotation.defensive(scenario_type)
    project.priest.discipline.rotation.beneficial(scenario_type)

    project.priest.discipline.rotation.stomp(scenario_type, false)

    project.priest.discipline.rotation.offensive(scenario_type)

    project.priest.discipline.rotation.premonition(scenario_type)

    -- fake
    if project.util.cast.fake(scenario_type) then
        return
    end

    project.priest.discipline.rotation.heal(scenario_type)

    -- attack
    project.priest.discipline.rotation.stomp(scenario_type, true)
    project.priest.discipline.rotation.attack(scenario_type)
end

if not project.subscription.check() then
    return
end

project.priest.discipline:Init(function()
    if project.util.pause.time > awful.time then
        project.util.debug.alert.evade("ROTATION TAKING A BREAK")
        return
    end

    routine()
end)

-- TODO:
-- STATUS BAR DISABLE DEFENSIVES/OFFENSIVES
-- INFO ALERTS

-- radiance when locked on holy
-- shackle undead abomination dk unholy
-- leaping friend when mage casting ice wall if mage closer than me to the best healing target
-- protection warriors as seen as not melee? check for other tanks? // blood dk same
-- i dont think leap capacitor works
-- fake casting, block pain supp if we have rapture???
-- implement fake casting based on the enemies interrupt thresholds? like track all of your locked spells and your casting pcts!
-- AVOID ROGUE BLIND-> MOVING TOWARD ANGLE 45, DUR 0.5, FACING, NOT NECESSARILY TARGET ME? OR ONLY IF NOT TARGET ME? SO FOCUS ME? distance check? 15 yards but more than 5
-- FADE WHEN ROGUE USED SHADOWSTEP ON US?
-- CHECK SHADOWSTEP
-- WE SHOULD ATTACK FEARS...
-- AUTO ENABLE ROTATION
-- FIX POWER INFUSION WITH SHADOWPRIEST IN TEAM DELAYED
-- FIX FAKE CASTING IS DOG RN
-- ATTACKING INTO BCC
-- VOID SHIFT 30 HP IF WE DONT HAVE TRINKET
-- check soul rot dispel/anthenema fstuff like that
-- check ttd does lag?
-- RING OF FIRE
-- EARTH GRAB
-- FLASH HEAL PRIO TO PENANCE WHEN NOT SURGE CHECK?? LINE 18
-- CHECK CONVOKE THE SPIRITS ID
-- DOES NOT DISPEL DIVINE SHIELD ???? CHECK DANGER ON ENEMIES??? OR DANGER IN GENERAL
-- CHECK DISPEL PRIO 1 MAGE BARRIERS?
-- WAIT FOR POWER INFUSION ONLY IF MANA ABOVE 90?

