local Unlocker, awful, project = ...

local targeted_casting_spells = {
    [project.util.id.spell.POLYMORPH_1] = 1,
    [project.util.id.spell.POLYMORPH_2] = 1,
    [project.util.id.spell.POLYMORPH_3] = 1,
    [project.util.id.spell.POLYMORPH_4] = 1,
    [project.util.id.spell.POLYMORPH_5] = 1,
    [project.util.id.spell.POLYMORPH_6] = 1,
    [project.util.id.spell.POLYMORPH_7] = 1,
    [project.util.id.spell.POLYMORPH_8] = 1,
    [project.util.id.spell.POLYMORPH_9] = 1,
    [project.util.id.spell.POLYMORPH_10] = 1,
    [project.util.id.spell.POLYMORPH_11] = 1,
    [project.util.id.spell.POLYMORPH_12] = 1,
    [project.util.id.spell.POLYMORPH_13] = 1,
    [project.util.id.spell.POLYMORPH_14] = 1,
    [project.util.id.spell.POLYMORPH_15] = 1,
    [project.util.id.spell.POLYMORPH_16] = 1,

    [project.util.id.spell.ULTIMATE_PENITENCE] = 1,
    [project.util.id.spell.FEAR] = 1,
    [project.util.id.spell.CYCLONE] = 1,
    [project.util.id.spell.REPENTANCE] = 1,
    [project.util.id.spell.HEX_1] = 1,
    [project.util.id.spell.HEX_2] = 1,
    [project.util.id.spell.HEX_3] = 1,
    [project.util.id.spell.HEX_4] = 1,
    [project.util.id.spell.HEX_5] = 1,
    [project.util.id.spell.HEX_6] = 1,
    [project.util.id.spell.HEX_7] = 1,
    [project.util.id.spell.HEX_8] = 1,
    [project.util.id.spell.HEX_9] = 1,
    [project.util.id.spell.SLEEP_WALK] = 1,

    -- channel
    [project.util.id.spell.RAY_OF_FROST] = 1,
    [project.util.id.spell.LIGHTNING_LASSO] = 1,

    -- danger only
    [project.util.id.spell.CHAOS_BOLT] = 2,
    [project.util.id.spell.ARCANE_SURGE] = 2,
}

local aoe_casting_spells = {
    [project.util.id.spell.SHADOWFURY] = { range = 8, melee = false },
    [project.util.id.spell.MASS_DISPEL] = { range = 15, melee = false },
    [project.util.id.spell.CONVOKE_THE_SPIRITS] = { range = 15, around = true, melee = false },
    [project.util.id.spell.FISTS_OF_FURY] = { range = 8, around = true, melee = true },
}

local do_not_leap_buffs = {
    project.util.id.spell.POWER_WORD_BARRIER_BUFF,
    project.util.id.spell.ANTI_MAGIC_ZONE,
    project.util.id.spell.BLADESTORM_1,
    project.util.id.spell.BLADESTORM_2,
    project.util.id.spell.BLADESTORM_3,
    project.util.id.spell.BLADESTORM_4,
}

local mass_dispel_leap_buffs = {
    project.util.id.spell.DIVINE_SHIELD,
    project.util.id.spell.ICE_BLOCK,
    project.util.id.spell.TIME_STOP,
    project.util.id.spell.BLESSING_OF_SPELLWARDING,
}

local triggers_to_radius = {
    --radius
    [project.util.id.trigger.CAPACITOR_TOTEM] = 8,
    [project.util.id.trigger.SIGIL_OF_MISERY] = 8,
}

local triggers_spell_to_delay = {
    --delay
    [project.util.id.spell.CAPACITOR_TOTEM] = 2,
    [project.util.id.spell.SIGIL_OF_MISERY] = 1
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

local can_leap = function(friend, melee)
    if not friend.player then
        return
    end

    if friend.melee
            and not project.settings.priest_leap_of_faith_melees then
        return
    end

    if project.util.enemy.existing_classes[project.util.id.class.HUNTER]
            and awful.player.debuff(project.util.id.spell.BINDING_SHOT_MOVE) then
        return
    end

    if project.util.enemy.existing_classes[project.util.id.class.MAGE]
            and awful.player.debuff(project.util.id.spell.SNOWDRIFT_PRE) then
        return
    end

    if project.priest.spells.powerWordBarrier.queued then
        return
    end

    if awful.player.used(project.util.id.spell.POWER_WORD_BARRIER, 8) then
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

    if friend.immuneMagic
            or friend.immunePhysical then
        return
    end

    if friend.rooted then
        return
    end

    if friend.role == "tank" then
        return
    end

    if friend.buffFrom(do_not_leap_buffs) then
        return
    end

    if melee then
        if friend.melee
                and project.util.enemy.danger then
            return
        end

        if friend.melee
                and friend.target
                and friend.target.enemy
                and friend.distanceTo(friend.target) < friend.target.dist then
            return
        end
    end

    if awful.enemyHealer
            and awful.enemyHealer.name
            and awful.enemyHealer.distanceTo(friend) < 10
            and friend.class3 == project.util.id.class.HUNTER then
        return
    end

    return true
end

local function trigger_leap(list)
    list.loop(function(trigger)
        local trigger_to_leap_radius = triggers_to_radius[trigger.id]

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

            if not can_leap(friend, true) then
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

    if awful.player.debuff(project.util.id.spell.SNOWDRIFT_PRE) then
        return
    end

    local count, _, friends = awful.fgroup.around(enemy, 8)
    if count == 0 then
        return
    end

    local friend_to_leap
    friends.loop(function(friend)
        if not can_leap(friend, true) then
            return
        end

        if friend.debuffUptime(project.util.id.spell.SNOWDRIFT_PRE) < 1 then
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
        if not can_leap(friend, true) then
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

    local friend_to_leap = project.priest.discipline.rotation.util.lof.gripped_friend

    if not friend_to_leap then
        return
    end

    if not can_leap(friend_to_leap, true) then
        return
    end

    if friend_to_leap.dist < 20 then
        return
    end

    return project.util.cast.overlap.cast(spell, friend_to_leap)
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

    if not friend or not enemy then
        return
    end

    if not can_leap(friend, true) then
        return
    end

    if not enemy.castID
            and not enemy.channelID then
        return
    end

    local spell_id = enemy.castID
    if not spell_id then
        spell_id = enemy.channelID
    end

    if not targeted_casting_spells[spell_id] then
        return
    end

    if awful.time < time then
        return
    end

    if prio == 2
            and not project.util.friend.danger then
        return
    end

    local enemy_range = enemy.class3 == project.util.id.class.PRIEST and 46 or 40

    if enemy.channelID then
        local range = spell_id == project.util.id.spell.LIGHTNING_LASSO and 20 or enemy_range
        if enemy.dist < range then
            return
        end
    end

    if enemy.castID
            and enemy.dist < enemy_range
            and enemy.los then
        return
    end

    return project.util.cast.overlap.cast(spell, friend)
            and project.util.debug.alert.beneficial("Leap of Faith! targeted_cast " .. tostring(enemy.channel or enemy.casting), project.priest.spells.leapOfFaith.id)
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

    if not enemy.castID
            and not enemy.channelID then
        return
    end
    local spell_id = enemy.castID or enemy.channelID

    if awful.time < time then
        return
    end

    if spell_id == project.util.id.spell.CONVOKE_THE_SPIRITS
            and not enemy.melee then
        info.range = 35
    end

    if spell_id ~= project.util.id.spell.MASS_DISPEL
            and enemy.target
            and enemy.target.friend
            and enemy.target.dist > info.range + 5
            and can_leap(enemy.target, true)
    then
        return project.util.cast.overlap.cast(spell, enemy.target)
                and project.util.debug.alert.beneficial("Leap of Faith! aoe_cast1 " .. tostring(enemy.channel or enemy.casting), project.priest.spells.leapOfFaith.id)
    end

    local friend_to_leap
    awful.fgroup.loop(function(friend)
        if not enemy.facing(friend) then
            return
        end

        if not can_leap(friend, true) then
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

        if spell_id == project.util.id.spell.MASS_DISPEL and friend.buffFrom(mass_dispel_leap_buffs) then
            return project.util.cast.overlap.cast(spell, friend)
                    and project.util.debug.alert.beneficial("Leap of Faith! aoe_cast2 " .. tostring(enemy.channel or enemy.casting), project.priest.spells.leapOfFaith.id)
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

    if spell_id == project.util.id.spell.MASS_DISPEL then
        return
    end

    return project.util.cast.overlap.cast(spell, friend_to_leap)
            and project.util.debug.alert.beneficial("Leap of Faith! aoe_cast3 " .. tostring(enemy.channel or enemy.casting), project.priest.spells.leapOfFaith.id)
end)

project.priest.spells.leapOfFaith:Callback("pvp_stunned_25yards", function(spell)
    if not project.settings.priest_leap_of_faith_stunned then
        return
    end

    if project.util.friend.best_target.unit.dist < 25 then
        return
    end

    if project.util.friend.best_target.attackers.melee == 0 then
        return
    end

    if project.util.friend.best_target.unit.stunRemains < 1.5 then
        return
    end

    if not can_leap(project.util.friend.best_target.unit, true) then
        return
    end

    if project.util.friend.best_target.unit.debuffUptime(project.util.friend.best_target.unit.stunned) < 0.5 then
        return
    end

    if project.util.friend.best_target.unit.melee then
        local total = project.util.check.target.cooldowns(project.util.friend.best_target.unit.target, project.util.friend.best_target.unit).total
        if total > 0 then
            return
        end
    end

    if project.util.enemy.danger
            and not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
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

    if project.util.friend.best_target.unit.melee then
        return
    end

    if project.util.friend.best_target.unit.dist < 25 then
        return
    end

    if project.util.friend.best_target.attackers.melee == 0 then
        return
    end

    if not can_leap(project.util.friend.best_target.unit, true, true) then
        return
    end

    local total = project.util.check.target.cooldowns(project.util.friend.best_target.unit.target, project.util.friend.best_target.unit).total
    if total > 0 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Leap of Faith! pvp_danger_caster_25yards", project.priest.spells.leapOfFaith.id)
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

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    return project.priest.spells.leapOfFaith("pvp_stunned_25yards")
            or project.priest.spells.leapOfFaith("pvp_danger_caster_25yards")
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

    if project.priest.spells.leapOfFaith.cd > 1 then
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

    if dest.guid == awful.player.guid
            or source.castTarget.guid == awful.player.guid then
        return
    end

    if event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_START" then
        local spell_id, spell_name = select(12, unpack(info))

        if spell_id == project.util.id.spell.DEATH_GRIP then
            if not project.settings.priest_leap_of_faith_death_grip then
                return
            end

            C_Timer.After(1, function()
                project.priest.discipline.rotation.util.lof.gripped_friend = dest
            end)

            C_Timer.After(7, function()
                project.priest.discipline.rotation.util.lof.gripped_friend = nil
            end)

            project.util.debug.alert.evade("[Leap of Faith] Detected Death Grip")
            return
        end

        if spell_id == project.util.id.spell.ABOMINATION_LIMB_1 or spell_id == project.util.id.spell.ABOMINATION_LIMB_2 then
            if not project.settings.priest_leap_of_faith_abomination_limb then
                return
            end

            C_Timer.After(1, function()
                project.priest.discipline.rotation.util.lof.abomination_limb_enemy = source
            end)

            C_Timer.After(7, function()
                project.priest.discipline.rotation.util.lof.abomination_limb_enemy = nil
            end)

            project.util.debug.alert.evade("[Leap of Faith] Detected Abomination Limb")
            return
        end

        if spell_id == project.util.id.spell.SNOWDRIFT then
            if not project.settings.priest_leap_of_faith_snowdrift then
                return
            end

            C_Timer.After(0.5, function()
                project.priest.discipline.rotation.util.lof.snowdrift_enemy = source
            end)

            C_Timer.After(7, function()
                project.priest.discipline.rotation.util.lof.snowdrift_enemy = nil
            end)

            project.util.debug.alert.evade("[Leap of Faith] Detected Snowdrift")
            return
        end

        local targeted_casting_prio = targeted_casting_spells[spell_id]
        if targeted_casting_prio then
            if not project.settings.priest_leap_of_faith_targeted_casting_spells then
                return
            end

            if project.priest.discipline.rotation.util.lof.targeted_cast_time < math.huge
                    and project.priest.discipline.rotation.util.lof.targeted_cast_enemy.guid ~= source.guid then
                return
            end

            project.util.debug.alert.evade("[Leap of Faith] Detected targeted cast: " .. spell_name)
            project.priest.discipline.rotation.util.lof.targeted_cast_enemy = source
            project.priest.discipline.rotation.util.lof.targeted_cast_friend = dest
            project.priest.discipline.rotation.util.lof.targeted_cast_prio = targeted_casting_prio
            project.priest.discipline.rotation.util.lof.targeted_cast_time = awful.time + source.castRemains - awful.buffer - 0.5
            C_Timer.After(source.castRemains + awful.buffer, function()
                project.priest.discipline.rotation.util.lof.targeted_cast_friend = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_enemy = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_prio = nil
                project.priest.discipline.rotation.util.lof.targeted_cast_time = math.huge
            end)

            return
        end

        local aoe_cast_info = aoe_casting_spells[spell_id]
        if aoe_cast_info then
            if not project.settings.priest_leap_of_faith_aoe_casting_spells then
                return
            end

            if project.priest.discipline.rotation.util.lof.aoe_cast_time < math.huge
                    and project.priest.discipline.rotation.util.lof.aoe_cast_enemy.guid ~= source.guid then
                return
            end

            project.util.debug.alert.evade("[Leap of Faith] Detected AoE cast: " .. spell_name)
            project.priest.discipline.rotation.util.lof.aoe_cast_enemy = source
            project.priest.discipline.rotation.util.lof.aoe_cast_info = aoe_cast_info

            local threshold = 0
            if source.channel then
                threshold = 0.5
            end

            project.priest.discipline.rotation.util.lof.aoe_cast_time = awful.time + source.castRemains - awful.buffer - 0.5 + threshold
            C_Timer.After(source.castRemains + source.channelRemains + awful.buffer, function()
                project.priest.discipline.rotation.util.lof.aoe_cast_enemy = nil
                project.priest.discipline.rotation.util.lof.aoe_cast_info = nil
                project.priest.discipline.rotation.util.lof.aoe_cast_time = math.huge
            end)

            return
        end

        local trigger_to_leap_delay = triggers_spell_to_delay[spell_id]
        if trigger_to_leap_delay then
            if not project.settings.priest_leap_of_faith_ground_effects then
                return
            end

            project.util.debug.alert.evade("[Leap of Faith] Detected trigger cast: " .. spell_name)
            project.priest.discipline.rotation.util.lof.trigger_time = awful.time + trigger_to_leap_delay - awful.buffer - 0.5
            C_Timer.After(trigger_to_leap_delay + awful.buffer, function()
                project.priest.discipline.rotation.util.lof.trigger_time = math.huge
            end)

            return
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
        local spell_id = select(12, unpack(info))

        if spell_id == project.util.id.spell.LEAP_OF_FAITH then
            local timer = 1

            if awful.player.hasTalent(project.util.id.spell.SAVE_THE_DAY_TALENT) then
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