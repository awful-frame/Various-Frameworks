local Unlocker, awful, project = ...

local spells_to_prediction_evade = {
    [project.util.id.class.PALADIN] = {
        {
            name = "Hammer of Justice",
            id = project.util.id.spell.HAMMER_OF_JUSTICE,
            range = 10,
            facing = 1,
            targeted = true,
            prio = 2,
            dr = "stun",
            gcd = true
        },
        {
            name = "Blinding Light",
            id = project.util.id.spell.BLINDING_LIGHT,
            range = 10,
            facing = 0,
            bcc = true,
            prio = 1,
            used = true,
            dr = "fear",
            gcd = true
        }
    },
    [project.util.id.class.WARRIOR] = {
        {
            name = "Intimidating Shout",
            id = project.util.id.spell.INTIMIDATING_SHOUT,
            range = 8,
            facing = 1,
            bcc = true,
            targeted = true,
            prio = 1,
            dr = "fear",
            gcd = true
        }
    },
    [project.util.id.class.ROGUE] = {
        {
            name = "Kidney Shot",
            id = project.util.id.spell.KIDNEY_SHOT,
            range = 3,
            facing = 1,
            bcc = false,
            targeted = true,
            prio = 2,
            dr = "stun",
            gcd = true
        }
    },
    [project.util.id.class.MAGE] = {
        {
            name = "Dragon's Breath",
            id = project.util.id.spell.DRAGONS_BREATH,
            range = 8,
            facing = 1,
            bcc = true,
            prio = 1,
            dr = "fear",
            gcd = true
        }
    },
    [project.util.id.class.MONK] = {
        {
            name = "Leg Sweep",
            id = project.util.id.spell.LEG_SWEEP,
            range = 8,
            facing = 0,
            prio = 2,
            dr = "stun",
            gcd = true
        },
        {
            name = "Fists of Fury",
            id = project.util.id.spell.FISTS_OF_FURY,
            range = 8,
            facing = 1,
            prio = 2,
            channel = true
        },
    },
    [project.util.id.class.PRIEST] = {
        {
            name = "Psychic Scream",
            id = project.util.id.spell.PSYCHIC_SCREAM,
            range = 8,
            facing = 0,
            bcc = true,
            prio = 1,
            dr = "fear",
            gcd = true
        },
    },
    [project.util.id.class.EVOKER] = {
        {
            name = "Deep Breath",
            id = project.util.id.spell.DEEP_BREATH_BUFF,
            range = 10,
            facing = 0,
            prio = 2,
            buff = true,
            delay = 0.2,
            dr = "stun"
        },
        {
            name = "Breath of Eons",
            id = project.util.id.spell.BREATH_OF_EONS,
            range = 10,
            facing = 0,
            prio = 2,
            buff = true,
            delay = 0.2,
            dr = "stun"
        }
    },
}

project.util.evade.prediction_cc_time = math.huge
project.util.evade.prediction_prio = 0
project.util.evade.holdGCD = false
project.util.evade.block_cast = false

local unable_to_attack_buffs = {
    project.util.id.spell.ICE_BLOCK,
    project.util.id.spell.DISPERSION,
    project.util.id.spell.ASPECT_OF_THE_TURTLE,
    project.util.id.spell.NETHERWALK,
    project.util.id.spell.BURROW,
}

project.util.evade.predict = function()
    if not project.settings.priest_evade_prediction then
        return
    end

    if not project.util.evade.should_evade() then
        return
    end

    if project.util.evade.prediction_cc_time < math.huge then
        return
    end

    if not awful.arena then
        if not awful.player.inCombat then
            return
        end
    end

    if awful.player.buff(project.util.id.spell.PRECOGNITION) then
        return
    end

    if awful.player.ccImmunityRemains > 1 then
        return
    end

    awful.enemies.loop(function(enemy)
        if not enemy.player then
            return
        end

        if enemy.dead then
            return
        end

        if enemy.cc then
            return
        end

        if enemy.dist > project.util.check.player.range() then
            return
        end

        local spells = spells_to_prediction_evade[enemy.class3]
        if not spells then
            return
        end

        if enemy.buffFrom(unable_to_attack_buffs) then
            return
        end

        if enemy.class3 == project.util.id.class.MAGE then
            if enemy.used(project.util.id.spell.BLINK, 0.5) then
                return
            end

            if enemy.used(project.util.id.spell.SHIMMER, 0.5) then
                return
            end
        end

        if enemy.class3 == project.util.id.class.ROGUE then
            if enemy.used(project.util.id.spell.SHADOWSTEP, 0.5) then
                return
            end
        end

        for _, spell in ipairs(spells) do
            local dr = spell.dr
            if dr then
                if dr == project.util.id.dr.FEAR then
                    if awful.player.disorientDR <= 0.25 then
                        return
                    end

                    if awful.player.buff(project.util.id.spell.BLESSING_OF_SANCTUARY) then
                        return
                    end
                end

                if dr == project.util.id.dr.POLY then
                    if awful.player.incapacitateDR <= 0.25 then
                        return
                    end
                end

                if dr == project.util.id.dr.STUN then
                    if awful.player.stunDR <= 0.25 then
                        return
                    end

                    if awful.player.buff(project.util.id.spell.BLESSING_OF_SANCTUARY) then
                        return
                    end
                end
            end

            if spell.used
                    and not enemy.used(spell.id, 120) then
                return
            end

            if not spell.buff and not spell.channel then
                if spell.id == project.util.id.spell.HAMMER_OF_JUSTICE then
                    if enemy.used(spell.id, 30) then
                        return
                    end
                else
                    if enemy.cooldown(spell.id) > 1 then
                        return
                    end
                end
            end

            local range = spell.range + 2
            if spell.bcc then
                range = range + 1
            end

            local gcd_remains = enemy.gcdRemains or 0
            if spell.gcd
                    and gcd_remains > awful.spellCastBuffer then
                return
            end

            if enemy.dist > range then
                return
            end

            if not enemy.los then
                return
            end

            if spell.facing == 1
                    and not enemy.facing(awful.player, 90) then
                return
            end

            if spell.facing == 2
                    and not enemy.facing(awful.player, 90) and not enemy.playerFacing45 then
                return
            end

            if spell.buff
                    and not enemy.buff(spell.id) then
                return
            end

            if spell.buff and spell.delay
                    and enemy.buffUptime(spell.id) < spell.delay then
                return
            end

            if spell.channel
                    and enemy.channelID ~= spell.id then
                return
            end

            if not awful.arena then
                if spell.targeted and enemy.target.guid ~= awful.player.guid then
                    return
                end
            end

            if spell.bcc then
                local attackers = project.util.check.target.attackers(awful.player)

                if awful.arena then
                    if attackers.total > 1 then
                        return
                    end

                    if attackers.melee > 0
                            and project.util.friend.best_target.unit == awful.player.guid then
                        return
                    end
                end

                if not awful.arena then
                    if attackers.total > 0 then
                        return
                    end
                end
            end

            local no_phase_shift = not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) or project.priest.spells.fade.cd > 0

            if not spell.bcc
                    and no_phase_shift then
                return
            end

            if spell.bcc
                    and no_phase_shift
                    and project.priest.spells.death.cd > awful.gcd then
                return
            end

            project.util.evade.prediction_cc_time = awful.time - awful.buffer
            project.util.evade.prediction_prio = spell.prio

            if spell.bcc and project.priest.spells.death.cd < awful.gcd then
                project.util.evade.holdGCD = true
            end
            project.util.evade.block_cast = true

            C_Timer.After(2, function()
                project.util.evade.prediction_cc_time = math.huge
                project.util.evade.prediction_prio = 0
                project.util.evade.holdGCD = false
                project.util.evade.block_cast = false
            end)

            project.util.debug.alert.evade("[PREDICTION] Detected: " .. spell.name)
        end
    end)
end

