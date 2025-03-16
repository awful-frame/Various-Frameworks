local Unlocker, awful, project = ...

local targeted_casting_spells = {
    ["Ultimate Penitence"] = 1,
    ["Polymorph"] = 1,
    ["Fear"] = 1,
    ["Cyclone"] = 1,
    ["Repentance"] = 1,
    ["Hex"] = 1,
    ["Sleep Walk"] = 1,

    -- channel
    ["Ray of Frost"] = 1,
    ["Void Torrent"] = 1,
    ["Lightning Lasso"] = 1,

    -- danger only
    ["Chaos Bolt"] = 2,
    ["Arcane Surge"] = 2,
}

local aoe_casting_spells = {
    ["Shadowfury"] = { range = 8, melee = false },
    ["Mass Dispel"] = { range = 15, melee = false },
    ["Convoke the Spirits"] = { range = 15, around = true, melee = false },
    ["Fists of Fury"] = { range = 8, around = true, melee = true },
}

local do_not_leap_buffs = {
    "Bladestorm",
    "Divine Shield",
    "Cloak of Shadows",
    "Aspect of the Turtle",
    "Netherwalk",
    "Anti-Magic Shell",
}

local do_not_leap_stuns = {
    "Psychic Horror",
    "Binding Shot",
    "Axe Toss",
    "Hammer of Justice",
    "Holy Word: Chastise",
}

local triggers_to_leap = {
    --radius
    [192058] = 8, -- Capacitor Totem
    [207684] = 8, -- Sigil of Misery
}

local triggers_to_leap_names = {
    --delay
    ["Capacitor Totem"] = 2,
    ["Sigil of Misery"] = 1
}

project.priest.discipline.rotation.util.lof = {}
project.priest.discipline.rotation.util.lof.gripped_friend = nil

project.priest.discipline.rotation.util.lof.abomination_limb_enemy = nil
project.priest.discipline.rotation.util.lof.snowdrift_enemy = nil

project.priest.discipline.rotation.util.lof.targeted_cast_friend = nil
project.priest.discipline.rotation.util.lof.targeted_cast_enemy = nil
project.priest.discipline.rotation.util.lof.targeted_cast_prio = nil
project.priest.discipline.rotation.util.lof.targeted_cast_time = math.huge

project.priest.discipline.rotation.util.lof.aoe_cast_friend = nil
project.priest.discipline.rotation.util.lof.aoe_cast_enemy = nil
project.priest.discipline.rotation.util.lof.aoe_cast_info = nil
project.priest.discipline.rotation.util.lof.aoe_cast_time = math.huge

project.priest.discipline.rotation.util.lof.trigger_time = math.huge

local can_leap = function(friend, buffs, melee)
    if awful.player.debuff("Snowdrift") then
        return
    end

    if not friend then
        return
    end

    if friend.dead then
        return
    end

    if not friend.los then
        return
    end

    if friend.immuneMagicDamage
            or friend.immunePhysicalDamage then
        return
    end

    if friend.rooted then
        return
    end

    if friend.role == "tank" then
        return
    end

    if friend.casting
            or friend.channel then
        return
    end

    if buffs then
        if friend.buffRemains("Power Word: Barrier") > project.util.thresholds.buff() then
            return
        end

        if not friend.stunned then
            if awful.player.used(project.priest.spells.powerWordBarrier.id, 8) then
                return
            end
        end

        if friend.buffRemains("Anti-Magic Zone") > project.util.thresholds.buff() then
            return
        end
    end

    if friend.buffFrom(do_not_leap_buffs) then
        return
    end

    if friend.debuffFrom(do_not_leap_stuns) then
        return
    end

    if melee then
        if project.util.enemy.danger then
            if friend.melee then
                return
            end

            if friend.target.enemy then
                if not friend.target.los then
                    return
                end

                if friend.target.dist > 30 then
                    return
                end
            end
        end

        if friend.melee
                and friend.target
                and friend.target.enemy
                and friend.distanceTo(friend.target) < friend.target.dist then
            return
        end
    end

    return true
end

local function trigger_leap(list)
    list.loop(function(trigger)
        local trigger_to_leap_radius = triggers_to_leap[trigger.id]

        if not trigger_to_leap_radius then
            return
        end

        if trigger.dist > project.util.check.player.range() then
            return
        end

        if trigger.creator.friend then
            return
        end

        local friend_to_leap
        awful.fgroup.loop(function(friend)
            if friend.distanceTo(trigger) > trigger_to_leap_radius then
                return
            end

            if not can_leap(friend, false, true) then
                return
            end

            if not friend_to_leap then
                friend_to_leap = friend
                return
            end

            if friend.ranged and not friend_to_leap.ranged then
                friend_to_leap = friend
                return
            end

            if friend.hp < friend_to_leap.hp then
                friend_to_leap = friend
            end
        end)

        return friend_to_leap
    end)
end

project.priest.spells.leapOfFaith:Callback("snowdrift", function(spell)
    if not project.settings.priest_leap_of_faith_snowdrift then
        return
    end

    local enemy = project.priest.discipline.rotation.util.lof.snowdrift_enemy

    if not enemy then
        return
    end

    if awful.player.debuff("Snowdrift") then
        return
    end

    local count, _, friends = awful.fgroup.around(enemy, 8)
    if count == 0 then
        return
    end

    local friend_to_leap
    friends.loop(function(friend)
        if not can_leap(friend, false, false) then
            return
        end

        if friend.debuffUptime("Snowdrift") < 1 then
            return
        end

        if not friend_to_leap then
            friend_to_leap = friend
            return
        end

        if friend.ranged and not friend_to_leap.ranged then
            friend_to_leap = friend
            return
        end

        if friend.hp < friend_to_leap.hp then
            friend_to_leap = friend
        end
    end)

    return project.util.cast.overlap.cast(spell, friend_to_leap)
            and project.util.debug.alert.beneficial("Leap of Faith! snowdrift", project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("abomination_limb", function(spell)
    if not project.settings.priest_leap_of_faith_abomination_limb then
        return
    end

    local enemy = project.priest.discipline.rotation.util.lof.abomination_limb_enemy

    if not enemy then
        return
    end

    local count, _, friends = awful.fgroup.around(enemy, 8)
    if count == 0 then
        return
    end

    local friend_to_leap
    friends.loop(function(friend)
        if not can_leap(friend, true, true) then
            return
        end

        if friend.dist < 20 then
            return
        end

        if not friend_to_leap then
            friend_to_leap = friend
            return
        end

        if friend.ranged and not friend_to_leap.ranged then
            friend_to_leap = friend
            return
        end

        if friend.hp < friend_to_leap.hp then
            friend_to_leap = friend
        end
    end)

    return project.util.cast.overlap.cast(spell, friend_to_leap)
            and project.util.debug.alert.beneficial("Leap of Faith! abomination_limb", project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("gripped", function(spell)
    if not project.settings.priest_leap_of_faith_death_grip then
        return
    end

    local friend = project.priest.discipline.rotation.util.lof.gripped_friend

    if not friend then
        return
    end

    if not can_leap(friend, true, true) then
        return
    end

    if friend.dist < 20 then
        return
    end

    return project.util.cast.overlap.cast(spell, friend)
            and project.util.debug.alert.beneficial("Leap of Faith! gripped", project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("targeted_cast", function(spell)
    if not project.settings.priest_leap_of_faith_targeted_casting_spells then
        return
    end

    local friend = project.priest.discipline.rotation.util.lof.targeted_cast_friend
    local enemy = project.priest.discipline.rotation.util.lof.targeted_cast_enemy
    local prio = project.priest.discipline.rotation.util.lof.targeted_cast_prio
    local time = project.priest.discipline.rotation.util.lof.targeted_cast_time

    if not friend
            or not enemy then
        return
    end

    if not can_leap(friend, true, true) then
        return
    end

    if not enemy.casting
            and not enemy.channel then
        return
    end

    local spell_name = enemy.casting
    if not spell_name then
        spell_name = enemy.channel
    end

    if not targeted_casting_spells[spell_name] then
        return
    end

    if awful.time < time then
        return
    end

    if prio == 2
            and not project.util.friend.danger then
        return
    end

    if enemy.channel then
        if spell_name == "Lightning Lasso"
                and enemy.dist < 20 then
            return
        else
            if enemy.dist < 46 then
                return
            end
        end
    end

    if enemy.casting
            and enemy.dist < 46
            and not enemy.los then
        return
    end

    return project.util.cast.overlap.cast(spell, friend)
            and project.util.debug.alert.beneficial("Leap of Faith! targeted_cast " .. spell_name, project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("aoe_cast", function(spell)
    if not project.settings.priest_leap_of_faith_aoe_casting_spells then
        return
    end

    local enemy = project.priest.discipline.rotation.util.lof.aoe_cast_enemy
    local info = project.priest.discipline.rotation.util.lof.aoe_cast_info
    local time = project.priest.discipline.rotation.util.lof.aoe_cast_time

    if not enemy then
        return
    end

    if not enemy.casting
            and not enemy.channel then
        return
    end

    if info.around
            and awful.player.dist <= info.range + 5 then
        return
    end

    local spell_name = enemy.casting
    if not spell_name then
        spell_name = enemy.channel
    end

    if awful.time < time then
        return
    end

    if spell_name == "Convoke the Spirits"
            and not enemy.melee then
        info.range = 35
    end

    if spell_name ~= "Mass Dispel"
            and enemy.target
            and enemy.target.friend
            and enemy.target.dist > info.range + 5
            and can_leap(enemy.target, true, true)
    then
        return project.util.cast.overlap.cast(spell, enemy.target)
                and project.util.debug.alert.beneficial("Leap of Faith! los_cast1 " .. spell_name, project.priest.spells.leapOfFaith.id)
    end

    local friend_to_leap
    awful.fgroup.loop(function(friend)
        if not enemy.facing(friend) then
            return
        end

        if not can_leap(friend, true, true) then
            return
        end

        if info.around then
            if friend.distanceTo(enemy) > info.range then
                return
            end
        end

        if not info.around then
            if friend.dist <= info.range + 5 then
                return
            end
        end

        if spell_name == "Mass Dispel"
                and (friend.buff("Divine Shield") or friend.buff("Ice Block")) then
            return project.util.cast.overlap.cast(spell, friend)
                    and project.util.debug.alert.beneficial("Leap of Faith! los_cast2 " .. spell_name, project.priest.spells.leapOfFaith.id)
        end

        if not friend_to_leap then
            friend_to_leap = friend
            return
        end

        if friend.ranged and not friend_to_leap.ranged then
            friend_to_leap = friend
            return
        end

        if friend.hp < friend_to_leap.hp then
            friend_to_leap = friend
        end
    end)

    if not friend_to_leap then
        return
    end

    if spell_name == "Mass Dispel" then
        return
    end

    return project.util.cast.overlap.cast(spell, friend_to_leap)
            and project.util.debug.alert.beneficial("Leap of Faith! los_cast3 " .. spell_name, project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("pvp_stunned_25yards", function(spell)
    if not project.settings.priest_leap_of_faith_stunned then
        return
    end

    if not can_leap(project.util.friend.bestTarget, true, false) then
        return
    end

    if project.util.friend.bestTarget.debuffUptime(project.util.friend.bestTarget.stunned) < 0.5 then
        return
    end

    if project.util.friend.bestTarget.stunRemains < 1.5 then
        return
    end

    if project.util.friend.bestTarget.dist < 25 then
        return
    end

    if project.util.friend.attackers.melee == 0 then
        return
    end

    if project.util.friend.bestTarget.melee then
        local total = project.util.check.target.cooldowns(project.util.friend.bestTarget.target, project.util.friend.bestTarget)
        if total > 0 then
            return
        end
    end

    if project.util.enemy.danger
            and not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Leap of Faith! pvp_stunned_25yards", project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("pvp_danger_caster_25yards", function(spell)
    if not project.settings.priest_leap_of_faith_casters then
        return
    end

    if not project.util.friend.danger then
        return
    end

    if project.util.enemy.danger then
        return
    end

    if project.util.friend.bestTarget.melee then
        return
    end

    if not can_leap(project.util.friend.bestTarget, true, true) then
        return
    end

    if project.util.friend.bestTarget.dist < 25 then
        return
    end

    if project.util.friend.attackers.melee == 0 then
        return
    end

    local total = project.util.check.target.cooldowns(project.util.friend.bestTarget.target, project.util.friend.bestTarget)
    if total > 0 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.bestTarget)
            and project.util.debug.alert.beneficial("Leap of Faith! pvp_below60HP_caster_25yards", project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("trigger", function(spell)
    if not project.settings.priest_leap_of_faith_ground_effects then
        return
    end

    if project.priest.discipline.rotation.util.lof.trigger_time < math.huge then
        return
    end

    local friend = trigger_leap(awful.triggers)
    if not friend then
        friend = trigger_leap(awful.units)
        if not friend then
            return
        end
    end

    return project.util.cast.overlap.cast(spell, friend)
            and project.util.debug.alert.beneficial("Leap of Faith! trigger", project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("pve", function(spell)
    return
end)

project.priest.spells.leapOfFaith:Callback("pvp", function(spell)
    if not project.settings.priest_leap_of_faith then
        return
    end

    if project.priest.spells.powerWordBarrier.queued then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    return project.priest.spells.leapOfFaith("pvp_stunned_25yards")
            or project.priest.spells.leapOfFaith("pvp_below60HP_caster_25yards")
            or project.priest.spells.leapOfFaith("gripped")
            or project.priest.spells.leapOfFaith("abomination_limb")
            or project.priest.spells.leapOfFaith("snowdrift")
            or project.priest.spells.leapOfFaith("aoe_cast")
            or project.priest.spells.leapOfFaith("targeted_cast")
            or project.priest.spells.leapOfFaith("trigger")
end)

awful.onEvent(function(info, event, source, dest)
    if not project.settings.priest_leap_of_faith then
        return
    end

    if project.util.check.scenario.type() == "pve" then
        return
    end

    if not source.player then
        return
    end

    if not source.enemy then
        return
    end

    if source.dist > project.util.check.player.range() then
        return
    end

    if dest.guid == awful.player.guid then
        return
    end

    if source.castTarget.guid == awful.player.guid then
        return
    end

    if event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_START" then
        local _, spell_name = select(12, unpack(info))

        if spell_name == "Death Grip" then
            if not project.settings.priest_leap_of_faith_death_grip then
                return
            end

            C_Timer.After(1, function()
                project.priest.discipline.rotation.util.lof.gripped_friend = dest
            end)
            C_Timer.After(7, function()
                project.priest.discipline.rotation.util.lof.gripped_friend = nil
            end)
        end

        if spell_name == "Abomination Limb" then
            if not project.settings.priest_leap_of_faith_abomination_limb then
                return
            end

            C_Timer.After(1, function()
                project.priest.discipline.rotation.util.lof.abomination_limb_enemy = source
            end)
            C_Timer.After(7, function()
                project.priest.discipline.rotation.util.lof.abomination_limb_enemy = nil
            end)
        end

        if spell_name == "Snowdrift" then
            if not project.settings.priest_leap_of_faith_snowdrift then
                return
            end

            C_Timer.After(0.5, function()
                project.priest.discipline.rotation.util.lof.snowdrift_enemy = source
            end)

            C_Timer.After(7, function()
                project.priest.discipline.rotation.util.lof.snowdrift_enemy = nil
            end)
        end

        local targeted_casting_prio = targeted_casting_spells[spell_name]
        if targeted_casting_prio then
            if not project.settings.priest_leap_of_faith_targeted_casting_spells then
                return
            end

            if project.priest.discipline.rotation.util.lof.targeted_cast_time < math.huge
                    and project.priest.discipline.rotation.util.lof.targeted_cast_enemy.guid ~= source.guid then
                return
            end

            project.util.debug.alert.evade("Detected Leap of Faith targeted cast: " .. spell_name)
            project.priest.discipline.rotation.util.lof.targeted_cast_enemy = source
            project.priest.discipline.rotation.util.lof.targeted_cast_friend = dest
            project.priest.discipline.rotation.util.lof.targeted_cast_prio = targeted_casting_prio
            project.priest.discipline.rotation.util.lof.targeted_cast_time = awful.time + source.castRemains - awful.spellCastBuffer - awful.buffer - 0.5
            C_Timer.After(source.castRemains + awful.spellCastBuffer, function()
                project.priest.discipline.rotation.util.lof.targeted_cast_friend = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_enemy = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_prio = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_time = math.huge
            end)
        end

        local aoe_cast_info = aoe_casting_spells[spell_name]
        if aoe_cast_info then
            if not project.settings.priest_leap_of_faith_aoe_casting_spells then
                return
            end

            if project.priest.discipline.rotation.util.lof.aoe_cast_time < math.huge
                    and project.priest.discipline.rotation.util.lof.aoe_cast_enemy.guid ~= source.guid then
                return
            end

            project.util.debug.alert.evade("Detected Leap of Faith AoE cast: " .. spell_name)
            project.priest.discipline.rotation.util.lof.aoe_cast_enemy = source
            project.priest.discipline.rotation.util.lof.aoe_cast_info = aoe_cast_info

            local threshold = 0
            if source.channel then
                threshold = 1
            end

            project.priest.discipline.rotation.util.lof.aoe_cast_time = awful.time + source.castRemains - awful.spellCastBuffer - awful.buffer - 0.5 + threshold
            C_Timer.After(source.castRemains + source.channelRemains + awful.spellCastBuffer, function()
                project.priest.discipline.rotation.util.lof.aoe_cast_enemy = nil
                project.priest.discipline.rotation.util.lof.aoe_cast_info = nil
                project.priest.discipline.rotation.util.lof.aoe_cast_time = math.huge
            end)
        end

        local trigger_to_leap_delay = triggers_to_leap_names[spell_name]
        if trigger_to_leap_delay then
            if not project.settings.priest_leap_of_faith_ground_effects then
                return
            end

            project.util.debug.alert.evade("Detected Leap of Faith trigger cast: " .. spell_name)
            project.priest.discipline.rotation.util.lof.trigger_time = awful.time + trigger_to_leap_delay - awful.spellCastBuffer - awful.buffer - 0.5
            C_Timer.After(trigger_to_leap_delay + awful.spellCastBuffer, function()
                project.priest.discipline.rotation.util.lof.trigger_time = math.huge
            end)
        end
    end
end)

awful.onEvent(function(info, event, source, dest)
    if not project.settings.priest_leap_of_faith then
        return
    end

    if source.guid ~= awful.player.guid then
        return
    end

    if event == "SPELL_CAST_SUCCESS" then
        local spellID, spellName = select(12, unpack(info))

        if spellName == "Leap of Faith" then
            local timer = 1

            if awful.player.hasTalent("Save the Day") then
                timer = 7
            end

            C_Timer.After(timer, function()
                project.priest.discipline.rotation.util.lof.gripped_friend = nil

                project.priest.discipline.rotation.util.lof.abomination_limb_enemy = nil
                project.priest.discipline.rotation.util.lof.snowdrift_enemy = nil

                project.priest.discipline.rotation.util.lof.targeted_cast_friend = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_enemy = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_prio = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_time = math.huge

                project.priest.discipline.rotation.util.lof.aoe_cast_enemy = nil
                project.priest.discipline.rotation.util.lof.aoe_cast_info = nil
                project.priest.discipline.rotation.util.lof.aoe_cast_time = math.huge
            end)
        end
    end
end)