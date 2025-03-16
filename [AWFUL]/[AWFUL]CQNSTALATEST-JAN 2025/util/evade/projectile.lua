local Unlocker, awful, project = ...

local projectilesToEvade = {
    -- fade/meld
    [project.util.id.spell.CONVOKE_THE_SPIRITS] = 1,
    [project.util.id.spell.RAY_OF_FROST] = 1,
    [project.util.id.spell.KILLING_SPREE] = 1,

    -- only fade
    [project.util.id.spell.DEATH_GRIP] = 2,
    [project.util.id.spell.SHADOWSTEP] = 2,

    --only meld
    [project.util.id.spell.MORTAL_COIL] = 3,
    [project.util.id.spell.THE_HUNT] = 3,
    [project.util.id.spell.STORM_BOLT] = 3,
}

project.util.evade.projectile_cc_time = math.huge
project.util.evade.projectile_prio = 0
project.util.evade.holdGCD = false
project.util.evade.block_cast = false

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_START" then
        if not project.util.evade.should_evade() then
            return
        end

        if not source.enemy then
            return
        end

        if awful.player.buff(project.util.id.spell.PRECOGNITION) then
            -- precog
            return
        end

        if awful.player.ccImmunityRemains > 1 then
            return
        end

        local spell_id, spell_name = select(12, unpack(info))
        if dest.guid == awful.player.guid or (source.target and source.target.guid == awful.player.guid) then
            local prio = projectilesToEvade[spell_id]

            local no_phase_shift = not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) or project.priest.spells.fade.cd > 0
            local no_meld = not IsPlayerSpell(project.util.id.spell.SHADOWMELD) or project.util.spells.racials.shadowmeld.cd > 0

            if prio then
                if prio == 3
                        and not project.settings.general_evade_projectiles
                        and spell_id ~= project.util.id.spell.THE_HUNT then
                    return
                end

                if prio == 3
                        and no_meld then
                    return
                end

                if prio == 2
                        and no_phase_shift then
                    return
                end

                if prio == 1
                        and no_phase_shift
                        and no_meld then
                    return
                end

                if spell_id == project.util.id.spell.STORM_BOLT then
                    if awful.player.stunDR <= 0.25 then
                        return
                    end

                    if awful.player.buffRemains(project.util.id.spell.BLESSING_OF_SANCTUARY) > 1 then
                        return
                    end
                end

                if spell_id == project.util.id.spell.DEATH_GRIP or spell_id == project.util.id.spell.SHADOWSTEP then
                    C_Timer.After(0.5, function()
                        project.util.evade.projectile_cc_time = awful.time
                        project.util.evade.projectile_prio = prio
                        project.util.evade.block_cast = true
                    end)
                else
                    local threshold = (0.3 + (math.random() * 0.6))
                    project.util.evade.projectile_cc_time = awful.time + threshold
                    project.util.evade.projectile_prio = prio
                    project.util.evade.block_cast = true
                end

                awful.call("SpellCancelQueuedSpell")
                awful.call("SpellStopCasting")

                C_Timer.After(1, function()
                    project.util.evade.projectile_cc_time = math.huge
                    project.util.evade.projectile_prio = 0
                    project.util.evade.block_cast = false
                    project.util.evade.holdGCD = false
                end)

                project.util.debug.alert.evade("Detected evade projectile: " .. spell_name)
            end
        end
    end
end)

