local Unlocker, awful, project = ...

local casting_spells = {
    ---- cc spells
    --fade/meld only
    ["Cyclone"] = { prio = 1, bcc = false, dr = "fear" },
    ["Mind Control"] = { prio = 1, bcc = false, dr = "fear" },
    ["Ultimate Penitence"] = { prio = 1, bcc = false },

    --death/fade/meld
    ["Polymorph"] = { prio = 2, bcc = true, dr = "poly" },
    ["Hex"] = { prio = 2, bcc = true, dr = "poly" },
    ["Repentance"] = { prio = 2, bcc = true, dr = "poly" },
    ["Sleep Walk"] = { prio = 2, bcc = true, dr = "fear" },
    ["Fear"] = { prio = 2, bcc = true, dr = "fear" },
    ["Seduction"] = { prio = 2, bcc = true, dr = "fear" },

    ---- dmg spells
    --fade/meld only
    ["Chaos Bolt"] = { prio = 3, bcc = false },
    ["Mindgames"] = { prio = 3, bcc = false },
    ["Arcane Surge"] = { prio = 3, bcc = false },

    --fade only
    ["Shadowfury"] = { prio = 4, bcc = false, dr = "stun" },
    ["Searing Glare"] = { prio = 4, bcc = false },
}

project.util.evade.casting_cc_time = math.huge
project.util.evade.casting_prio = 0
project.util.evade.casting_enemy = nil
project.util.evade.holdGCD = false

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_START" then
        if not project.settings.general_evade_casting
                and not project.settings.priest_evade_casting then
            return
        end

        if not project.util.evade.should_evade() then
            return
        end

        if not source.enemy then
            return
        end

        if project.util.evade.casting_cc_time < math.huge
                and project.util.evade.casting_enemy.guid ~= source.guid then
            return
        end

        local _, spellName = select(12, unpack(info))

        local casting_spell = casting_spells[spellName]

        if not casting_spell then
            return
        end

        if source.castTarget.guid == awful.player.guid
                or (casting_spell.prio == 4 and source.playerFacing and source.dist < 40) then
            if casting_spell.prio == 1
                    and project.priest.spells.fade.cd > awful.gcd
                    and project.util.spells.racials.shadowmeld.cd > awful.gcd then
                return
            end

            if casting_spell.prio == 2
                    and project.priest.spells.death.cd > awful.gcd
                    and project.priest.spells.fade.cd > awful.gcd
                    and project.util.spells.racials.shadowmeld.cd > awful.gcd then
                return
            end

            if casting_spell.prio == 3
                    and project.priest.spells.fade.cd > awful.gcd
                    and project.util.spells.racials.shadowmeld.cd > 0 then
                return
            end

            if casting_spell.prio == 4
                    and project.priest.spells.fade.cd > awful.gcd
                    and project.util.spells.racials.shadowmeld.cd > awful.gcd then
                return
            end

            local dr = casting_spell.dr
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

            project.util.evade.casting_cc_time = awful.time + source.castRemains - awful.spellCastBuffer - awful.buffer
            project.util.evade.casting_prio = casting_spell.prio
            project.util.evade.casting_enemy = source
            project.util.evade.holdGCD = true

            C_Timer.After(2, function()
                project.util.evade.casting_cc_time = math.huge
                project.util.evade.casting_prio = 0
                project.util.evade.casting_enemy = nil
                project.util.evade.holdGCD = false
            end)

            if awful.player.casting
                    and awful.time + awful.player.castRemains > project.util.evade.casting_cc_time then
                awful.call("SpellStopCasting")
            end

            awful.call("SpellCancelQueuedSpell")

            project.util.debug.alert.evade("Detected evade casting: " .. spellName)
        end
    end
end)

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" then
        local spellID, spellName = select(12, unpack(info))
        local castingSpell = casting_spells[spellName]

        if not castingSpell then
            return
        end

        if dest.guid == awful.player.guid
                or (source.target.guid == awful.player.guid and castingSpell.prio == 4) then
            project.util.evade.casting_cc_time = math.huge
            project.util.evade.casting_prio = 0
            project.util.evade.holdGCD = false
        end
    end
end)


