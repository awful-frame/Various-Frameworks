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

    if awful.player.manaPct < 95
            and (awful.player.buff("Drink") or awful.player.buff("Refreshment")) then
        return
    end

    if awful.player.casting == "Capturing" then
        return
    end

    if awful.player.casting == "Resurrection" then
        return
    end

    if awful.player.casting == "Mass Resurrection" then
        return
    end

    if awful.player.channel == "Mind Control" then
        if project.util.friend.bestTarget.hp < 20 then
            awful.call("SpellStopCasting")
        end
        return
    end

    if awful.player.channel == "Ultimate Penitence" then
        return
    end

    return true
end

local function routine()
    if not should_routine() then
        return
    end

    local scenario_type = project.util.check.scenario.type()

    project.util.cast.block.check()
    project.util.cast.bcc()
    project.util.cast.overlap.reset()
    project.util.cast.interrupt_pct()

    project.util.scan.friends()
    project.util.scan.enemies(scenario_type)

    project.util.scan.interrupt()

    project.util.scan.party_damage(scenario_type)
    project.util.scan.tank_buster(scenario_type)
    project.util.scan.pve_debuffs(scenario_type)
    project.util.scan.dbm_bars(scenario_type)

    project.util.best_target.select()

    project.util.evade.predict()
    project.util.evade.missiles()
    project.util.evade.triggers()

    if awful.player.ccRemains > 2 then
        project.util.evade.reset()
    end

    project.priest.discipline.rotation.util.own_cds()

    if project.util.cast.block.spell_name == "Mind Control"
            or project.util.cast.block.spell_name == "Ultimate Penitence" then
        project.priest.discipline.rotation.evade(scenario_type)
        return
    end

    if project.util.evade.holdGCD
            or (awful.player.debuff("Harpoon") and project.util.friend.bestTarget.hp > 30) then
        project.util.debug.alert.evade("Holding evade GCD")
        project.priest.discipline.rotation.evade(scenario_type)
        project.priest.discipline.rotation.cc(scenario_type)
        return
    end

    if awful.player.debuff("Searing Glare") then
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

    if project.util.enemy.withOffensiveCds > 0 then
        project.priest.discipline.rotation.beneficial(scenario_type)
    end

    -- misc
    project.priest.discipline.rotation.evade(scenario_type)
    project.priest.discipline.rotation.dispel(scenario_type)
    project.priest.discipline.rotation.cc(scenario_type)

    -- fake
    if project.util.cast.fake(scenario_type) then
        return
    end

    -- heal
    project.priest.discipline.rotation.defensive(scenario_type)
    project.priest.discipline.rotation.beneficial(scenario_type)
    project.priest.discipline.rotation.offensive(scenario_type)

    project.priest.discipline.rotation.premonition(scenario_type)
    project.priest.discipline.rotation.heal(scenario_type)

    -- attack
    project.priest.discipline.rotation.stomp(scenario_type)
    project.priest.discipline.rotation.attack(scenario_type)
end

if not project.subscription.check(awful.player.name, awful.player.class, awful.player.spec) then
    return
end

project.priest.discipline:Init(function()
    if project.util.pause.time > awful.time then
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

