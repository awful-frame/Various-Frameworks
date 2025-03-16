local Unlocker, awful, project = ...

local casting_spells = {
    -- PvP
    ---- cc spells
    -- fade/meld only
    [project.util.id.spell.CYCLONE] = { prio = 1, bcc = false, dr = project.util.id.dr.FEAR },
    [project.util.id.spell.MIND_CONTROL] = { prio = 1, bcc = false, dr = project.util.id.dr.FEAR },
    [project.util.id.spell.ULTIMATE_PENITENCE] = { prio = 1, bcc = false },
    [project.util.id.spell.SHADOWFURY] = { prio = 1, bcc = false, dr = project.util.id.dr.STUN },
    [project.util.id.spell.SEARING_GLARE] = { prio = 1, bcc = false, range = 25 },

    -- death/fade/meld
    [project.util.id.spell.POLYMORPH_1] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_2] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_3] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_4] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_5] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_6] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_7] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_8] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_9] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_10] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_11] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_12] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_13] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_14] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_15] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.POLYMORPH_16] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_1] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_2] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_3] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_4] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_5] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_6] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_7] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_8] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.HEX_9] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.REPENTANCE] = { prio = 2, bcc = true, dr = project.util.id.dr.POLY },
    [project.util.id.spell.SLEEP_WALK] = { prio = 2, bcc = true, dr = project.util.id.dr.FEAR },
    [project.util.id.spell.FEAR] = { prio = 2, bcc = true, dr = project.util.id.dr.FEAR },
    [project.util.id.spell.SEDUCTION] = { prio = 2, bcc = true, dr = project.util.id.dr.FEAR },

    ---- dmg spells
    -- fade/meld only
    [project.util.id.spell.CHAOS_BOLT] = { prio = 3, bcc = false },
    [project.util.id.spell.MINDGAMES] = { prio = 3, bcc = false },
    [project.util.id.spell.ARCANE_SURGE] = { prio = 3, bcc = false },

    -- PvE
    -- meld only
    -- NERUBAR PALACE
    [project.util.id.spell.BURROWING_CHARGE_NP] = { prio = 4, bcc = false },

    -- ARA KARA
    [project.util.id.spell.BURROWING_CHARGE_AK] = { prio = 4, bcc = false },

    -- DAWNBREAKER
    [project.util.id.spell.TORMENTING_RAY] = { prio = 4, bcc = false },
    [project.util.id.spell.TORMENTING_ERUPTION_1] = { prio = 4, bcc = false },
    [project.util.id.spell.TORMENTING_ERUPTION_2] = { prio = 4, bcc = false },
    [project.util.id.spell.TORMENTING_ERUPTION_3] = { prio = 4, bcc = false },
    [project.util.id.spell.TORMENTING_BEAM] = { prio = 4, bcc = false },
    [project.util.id.spell.ANIMATE_SHADOWS] = { prio = 4, bcc = false },
    [project.util.id.spell.BURSTING_COCOON] = { prio = 4, bcc = false },
    [project.util.id.spell.ABYSSAL_BLAST] = { prio = 4, bcc = false },

    -- SIEGE OF BORALUS
    [project.util.id.spell.AZERITE_CHARGE] = { prio = 4, bcc = false },

    -- GRIM BATOL
    [project.util.id.spell.ROCK_SPIKE] = { prio = 4, bcc = false },
    [project.util.id.spell.CORRUPT] = { prio = 4, bcc = false },
}

project.util.evade.casting_cc_time = math.huge
project.util.evade.casting_prio = 0
project.util.evade.casting_enemy = nil
project.util.evade.holdGCD = false
project.util.evade.block_cast = false

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_START" then
        if not project.settings.general_evade_casting
                and not project.settings.priest_evade_casting then
            return
        end

        if not project.util.evade.should_evade(true) then
            return
        end

        if not source.enemy then
            return
        end

        if project.util.evade.casting_cc_time < math.huge
                and project.util.evade.casting_enemy.guid ~= source.guid then
            return
        end

        local spell_id, spell_name = select(12, unpack(info))
        local casting_spell = casting_spells[spell_id]
        if not casting_spell then
            return
        end

        if source.castTarget.guid == awful.player.guid
                or dest == awful.player
                or (dest and dest.guid == awful.player.guid)
                or (not source.castTarget.guid and source.playerFacing and source.dist < 40) then

            local no_death = not IsPlayerSpell(project.util.id.spell.SHADOW_WORD_DEATH) or project.priest.spells.death.cd > source.castRemains - awful.spellCastBuffer
            local no_phase_shift = not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) or project.priest.spells.fade.cd > source.castRemains
            local no_meld = not IsPlayerSpell(project.util.id.spell.SHADOWMELD) or project.util.spells.racials.shadowmeld.cd > source.castRemains

            if casting_spell.prio == 1
                    and no_phase_shift
                    and no_meld then
                return
            end

            if casting_spell.prio == 2
                    and no_death
                    and no_phase_shift
                    and no_meld then
                return
            end

            if casting_spell.prio == 3
                    and no_phase_shift
                    and no_meld then
                return
            end

            if casting_spell.prio == 4 then
                if no_meld then
                    return
                end

                if source.castTarget.guid ~= awful.player.guid then
                    return
                end
            end

            if awful.player.buffRemains(project.util.id.spell.PRECOGNITION) > source.castRemains then
                return
            end

            if awful.player.ccImmunityRemains > source.castRemains then
                return
            end

            local dr = casting_spell.dr
            if dr then
                if dr == project.util.id.dr.FEAR then
                    if awful.player.disorientDR <= 0.25 and awful.player.ddrRemains > source.castRemains then
                        return
                    end

                    if awful.player.buffRemains(project.util.id.spell.BLESSING_OF_SANCTUARY) > source.castRemains then
                        return
                    end
                end

                if dr == project.util.id.dr.POLY then
                    if awful.player.incapacitateDR <= 0.25 and awful.player.idrRemains > source.castRemains then
                        return
                    end
                end

                if dr == project.util.id.dr.STUN then
                    if awful.player.stunDR <= 0.25 and awful.player.stunDRRemains > source.castRemains then
                        return
                    end

                    if awful.player.buffRemains(project.util.id.spell.BLESSING_OF_SANCTUARY) > source.castRemains then
                        return
                    end
                end
            end

            local cast_remains = source.castRemains
            if casting_spell.prio == 4 then
                cast_remains = cast_remains / 3
            end

            project.util.evade.casting_cc_time = awful.time + cast_remains - awful.spellCastBuffer - awful.buffer
            project.util.evade.casting_prio = casting_spell.prio
            project.util.evade.casting_enemy = source

            if casting_spell.prio == 2 and project.priest.spells.death.cd < awful.gcd then
                if cast_remains - awful.buffer > awful.player.gcdRemains + awful.gcd then
                    local gcd_remains = awful.player.gcdRemains
                    if not gcd_remains or gcd_remains < 0 then
                        gcd_remains = 0
                    end
                    C_Timer.After(gcd_remains + awful.spellCastBuffer, function()
                        project.util.evade.holdGCD = true
                    end)
                else
                    project.util.evade.holdGCD = true
                end
            end

            project.util.evade.block_cast = true

            C_Timer.After(cast_remains + awful.buffer, function()
                project.util.evade.casting_cc_time = math.huge
                project.util.evade.casting_prio = 0
                project.util.evade.casting_enemy = nil
                project.util.evade.holdGCD = false
                project.util.evade.block_cast = false
            end)

            if awful.player.casting
                    and awful.time + awful.player.castRemains > project.util.evade.casting_cc_time then
                awful.call("SpellStopCasting")
            end

            awful.call("SpellCancelQueuedSpell")

            local cast_target = source.castTarget.name
            if not cast_target then
                cast_target = "no_target"
            end
            project.util.debug.alert.evade("Detected evade casting: " .. spell_name .. "-" .. cast_target)
        end
    end
end)

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" then
        local spell_id, spell_name = select(12, unpack(info))
        local casting_spell = casting_spells[spell_id]

        if not casting_spell then
            return
        end

        if spell_name == "Seduction" then
            return
        end

        if dest.guid == awful.player.guid
                or (source.target.guid == awful.player.guid and casting_spell.prio == 4) then
            project.util.evade.casting_cc_time = math.huge
            project.util.evade.casting_enemy = nil
            project.util.evade.casting_prio = 0
            project.util.evade.holdGCD = false
            project.util.evade.block_cast = false
        end
    end
end)


