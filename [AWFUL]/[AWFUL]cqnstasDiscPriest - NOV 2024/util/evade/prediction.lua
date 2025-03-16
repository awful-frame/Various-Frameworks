local Unlocker, awful, project = ...

local predictionEvade = {
    ['Paladin'] = {
        {
            name = "Hammer of Justice",
            range = 10,
            facing = 1,
            targeted = true,
            prio = 2,
            dr = "stun"
        },
        {
            name = "Blinding Light",
            range = 10,
            facing = 0,
            bcc = true,
            prio = 1,
            used = true,
            dr = "fear"
        }
    },
    ['Warrior'] = {
        {
            name = "Intimidating Shout",
            range = 8,
            facing = 1,
            bcc = true,
            targeted = true,
            prio = 1,
            dr = "fear"
        }
    },
    ['Mage'] = {
        {
            id = 31661,
            name = "Dragon's Breath",
            range = 8,
            facing = 1,
            bcc = true,
            prio = 1,
            dr = "fear"
        }
    },
    ['Monk'] = {
        {
            name = "Leg Sweep",
            range = 8,
            facing = 0,
            prio = 2,
            dr = "stun"
        },
        {
            name = "Fists of Fury",
            range = 8,
            facing = 1,
            prio = 2,
            channel = true
        },
    },
    ['Priest'] = {
        {
            name = "Psychic Scream",
            range = 8,
            facing = 0,
            bcc = true,
            prio = 1,
            dr = "fear"
        },
    },
    ['Evoker'] = {
        {
            name = "Deep Breath",
            range = 10,
            facing = 0,
            prio = 2,
            buff = true,
            delay = 0.2,
            dr = "fear"
        },
        {
            name = "Breath of Eons",
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

        local spells = predictionEvade[enemy.class]
        if not spells then
            return
        end

        for _, spell in ipairs(spells) do
            local dr = spell.dr
            if dr then
                if dr == "fear" then
                    if awful.player.disorientDR <= 0.25 then
                        return
                    end
                end

                if dr == "poly" then
                    if awful.player.incapacitateDR <= 0.25 then
                        return
                    end
                end

                if dr == "stun" then
                    if awful.player.stunDR <= 0.25 then
                        return
                    end
                end
            end

            if spell.used then
                if not enemy.used(spell.name, 120) then
                    return
                end
            end

            if not spell.buff
                    and not spell.channel then
                if spell.name == "Hammer of Justice" then
                    if enemy.cooldown(spell.name) > 30 then
                        return
                    end
                else
                    if enemy.cooldown(spell.name) > enemy.gcdRemains then
                        return
                    end
                end
            end

            if enemy.dist > spell.range + 3 then
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
                    and not enemy.buff(spell.name) then
                return
            end

            if spell.buff
                    and spell.delay
                    and enemy.buffUptime(spell.name) < spell.delay then
                return
            end

            if spell.channel
                    and enemy.channel ~= spell.name then
                return
            end

            if not awful.arena then
                if spell.targeted and enemy.target.guid ~= awful.player.guid then
                    return
                end
            end

            if spell.bcc then
                local attackers = project.util.friend.attackers.get(awful.player.guid)

                if awful.arena then
                    if attackers.t > 1 then
                        return
                    end

                    if attackers.m > 0 then
                        return
                    end
                end

                if not awful.arena then
                    if attackers.t > 0 then
                        return
                    end
                end
            end

            if not spell.bcc
                    and project.priest.spells.fade.cd > awful.gcd then
                return
            end

            if spell.bcc
                    and project.priest.spells.fade.cd > awful.gcd
                    and project.priest.spells.death.cd > awful.gcd then
                return
            end

            project.util.evade.prediction_cc_time = awful.time
            project.util.evade.prediction_prio = spell.prio
            if project.util.friend.bestTarget.hp > 20 then
                project.util.evade.holdGCD = true
            end

            C_Timer.After(2, function()
                project.util.evade.prediction_cc_time = math.huge
                project.util.evade.prediction_prio = 0
                project.util.evade.holdGCD = false
            end)

            project.util.debug.alert.evade("Detected evade prediction: " .. spell.name)
        end
    end)
end

