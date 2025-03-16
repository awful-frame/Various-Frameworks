local Unlocker, awful, project = ...

-- -3 only cc?
-- -2 channel?
-- -1 always
-- 0 only kick?

local casting_spells = {
    -- PvE
    -- RAID
    -- THE BLOODBOUND HORROR
    [project.util.id.spell.BLACK_BULWARK] = { prio = 0 },

    -- OVI'NAX
    [project.util.id.spell.POISON_BURST] = { prio = 0 },

    -- ARA-KARA
    [project.util.id.spell.RESONANT_BARRAGE] = { prio = -1 },
    [project.util.id.spell.HORRIFYING_SHRILL] = { prio = -1 },
    [project.util.id.spell.POISON_BOLT] = { prio = -1 },
    [project.util.id.spell.WEB_BOLT] = { prio = -1 },

    [project.util.id.spell.REVOLTING_VOLLEY] = { prio = -2 },

    -- CITY OF THREADS
    [project.util.id.spell.VOID_WAVE] = { prio = -1 },
    [project.util.id.spell.GRIMWEAVE_BLAST] = { prio = -1 },
    [project.util.id.spell.SILK_BINDING] = { prio = -1 },

    [project.util.id.spell.TWIST_THOUGHTS] = { prio = -2 },
    [project.util.id.spell.MENDING_WEB] = { prio = -2 },

    -- DAWNBREAKER
    [project.util.id.spell.SHADOW_BOLT] = { prio = 0 },
    [project.util.id.spell.ANIMATE_SHADOWS] = { prio = 0 },
    [project.util.id.spell.ACIDIC_ERUPTION_DB] = { prio = 0 },

    [project.util.id.spell.NIGHT_BOLT] = { prio = -1 },
    [project.util.id.spell.ENSNARING_SHADOWS] = { prio = -1 },
    [project.util.id.spell.ABYSSAL_HOWL] = { prio = -1 },
    [project.util.id.spell.UMBRAL_BARRIER] = { prio = -1 },
    [project.util.id.spell.CONGEALED_SHADOW] = { prio = -1 },
    [project.util.id.spell.SILKEN_SHELL] = { prio = -1 },

    [project.util.id.spell.TORMENTING_BEAM] = { prio = -2 },

    -- STONEVAULT
    [project.util.id.spell.MOLTEN_METAL] = { prio = 0 },

    [project.util.id.spell.ARCING_VOID] = { prio = -1 },
    [project.util.id.spell.HOWLING_FEAR] = { prio = -1 },
    [project.util.id.spell.ALLOY_BOLT] = { prio = -1 },
    [project.util.id.spell.RESTORING_METALS] = { prio = -1 },
    [project.util.id.spell.PIERCING_WAIL] = { prio = -1 },
    [project.util.id.spell.CENSORING_GEAR] = { prio = -1 },
    [project.util.id.spell.STONE_BOLT] = { prio = -1 },

    -- MISTS OF TIRNA SCITHE
    [project.util.id.spell.SPIRIT_BOLT] = { prio = 0 },
    [project.util.id.spell.SPIRIT_BOLT_TRASH_1] = { prio = 0 },
    [project.util.id.spell.SPIRIT_BOLT_TRASH_2] = { prio = 0 },
    [project.util.id.spell.CONSUMPTION] = { prio = 0 },

    [project.util.id.spell.BRAMBLETHORN_COAT] = { prio = -1 },
    [project.util.id.spell.NOURISH_THE_FOREST] = { prio = -1 },
    [project.util.id.spell.STIMULATE_RESISTANCE] = { prio = -1 },
    [project.util.id.spell.STIMULATE_REGENERATION] = { prio = -1 },

    [project.util.id.spell.HARVEST_ESSENCE] = { prio = -2 },

    -- NECROTIC WAKE
    [project.util.id.spell.ENFEEBLE] = { prio = 0 },

    [project.util.id.spell.FROSTBOLT_VOLLEY] = { prio = -1 },
    [project.util.id.spell.BONEMEND] = { prio = -1 },
    [project.util.id.spell.RASPING_SCREAM] = { prio = -1 },
    [project.util.id.spell.GORESPLATTER_NW] = { prio = -1 },
    [project.util.id.spell.REPAIR_FLESH] = { prio = -1 },

    [project.util.id.spell.DRAIN_FLUIDS] = { prio = -2 },

    -- SIEGE OF BORALUS
    [project.util.id.spell.WATERTIGHT_SHELL] = { prio = -1 },
    [project.util.id.spell.BRACKISH_BOLT] = { prio = -1 },
    [project.util.id.spell.BOLSTERING_SHOUT] = { prio = -1 },
    [project.util.id.spell.STINKY_VOMIT] = { prio = -1 },
    [project.util.id.spell.CHOKING_WATERS] = { prio = -1 },

    -- GRIM BATOL
    [project.util.id.spell.SHADOWFLAME_BOLT_TRASH] = { prio = -1 },
    [project.util.id.spell.SHADOWFLAME_BOLT] = { prio = -1 },
    [project.util.id.spell.EARTH_BOLT] = { prio = -1 },
    [project.util.id.spell.MASS_TREMOR] = { prio = -1 },
    [project.util.id.spell.CHAINED_MIND] = { prio = -2 },

    -- PVP
    -- ALWAYS
    [project.util.id.spell.MASS_DISPEL] = { prio = 1 },
    [project.util.id.spell.ULTIMATE_PENITENCE] = { prio = 1 },
    [project.util.id.spell.RAY_OF_FROST] = { prio = 1 },
    [project.util.id.spell.VOID_TORRENT] = { prio = 1 },
    [project.util.id.spell.CONVOKE_THE_SPIRITS] = { prio = 1 },

    -- DANGER
    -- DMG
    [project.util.id.spell.SEARING_GLARE] = { prio = 2 },
    [project.util.id.spell.CHAOS_BOLT] = { prio = 2 },
    [project.util.id.spell.ARCANE_SURGE] = { prio = 2 },
    [project.util.id.spell.SHADOWFURY] = { prio = 2 },

    -- CC
    [project.util.id.spell.POLYMORPH_1] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_2] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_3] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_4] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_5] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_6] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_7] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_8] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_9] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_10] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_11] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_12] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_13] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_14] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_15] = { prio = 3 },
    [project.util.id.spell.POLYMORPH_16] = { prio = 3 },
    [project.util.id.spell.FEAR] = { prio = 3 },
    [project.util.id.spell.CYCLONE] = { prio = 3 },
    [project.util.id.spell.REPENTANCE] = { prio = 3 },
    [project.util.id.spell.HEX_1] = { prio = 3 },
    [project.util.id.spell.HEX_2] = { prio = 3 },
    [project.util.id.spell.HEX_3] = { prio = 3 },
    [project.util.id.spell.HEX_4] = { prio = 3 },
    [project.util.id.spell.HEX_5] = { prio = 3 },
    [project.util.id.spell.HEX_6] = { prio = 3 },
    [project.util.id.spell.HEX_7] = { prio = 3 },
    [project.util.id.spell.HEX_8] = { prio = 3 },
    [project.util.id.spell.HEX_9] = { prio = 3 },
    [project.util.id.spell.SLEEP_WALK] = { prio = 3 },
}

project.util.interrupt.time = math.huge
project.util.interrupt.prio = 0
project.util.interrupt.enemy = nil

project.util.interrupt.reset = function()
    project.util.interrupt.time = math.huge
    project.util.interrupt.prio = 0
    project.util.interrupt.enemy = nil
end

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        if not source.enemy then
            return
        end

        if source.dist > project.util.check.player.range() then
            return
        end

        if project.util.interrupt.time < math.huge
                and project.util.interrupt.enemy.guid ~= source.guid then
            return
        end

        local spell_id, spell_name = select(12, unpack(info))
        local spell_info = casting_spells[spell_id]
        if not spell_info then
            return
        end

        project.util.interrupt.time = awful.time + source.castRemains / 2 - awful.spellCastBuffer - awful.buffer
        project.util.interrupt.prio = spell_info.prio
        project.util.interrupt.enemy = source

        C_Timer.After(source.castRemains, function()
            project.util.interrupt.reset()
        end)

        project.util.debug.alert.evade("[INTERRUPT] Detected interrupt casting: " .. spell_name)
    end
end)



