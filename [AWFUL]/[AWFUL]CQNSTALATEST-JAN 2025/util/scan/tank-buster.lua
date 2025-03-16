local Unlocker, awful, project = ...

local tank_buster_spells = {
    -- RAID
    -- THE BLOODBOUND HORROR
    [project.util.id.spell.SPECTRAL_SLAM] = { prio = 1 },

    -- SIKRAN
    [project.util.id.spell.PHASE_LUNGE] = { prio = 1 },

    -- RASHA'NAN
    [project.util.id.spell.SAVAGE_ASSAULT] = { prio = 1 },

    -- OVI'NAX
    [project.util.id.spell.VOLATILE_CONCOCTION] = { prio = 1 },
    [project.util.id.spell.VICIOUS_BITE] = { prio = 1 },

    -- KY'VEZA
    [project.util.id.spell.VOID_SHREDDERS_1] = { prio = 1 },
    [project.util.id.spell.VOID_SHREDDERS_2] = { prio = 1 },

    -- THE SILKEN COURT
    [project.util.id.spell.PIERCING_STRIKE] = { prio = 1 },

    -- QUEEN ANSUREK
    [project.util.id.spell.FEAST] = { prio = 1 },
    [project.util.id.spell.INFEST] = { prio = 1 },

    -- ARA-KARA
    --[project.util.id.spell.BLEEDING_JAB] = { prio = 1 }, -- debuff / instant cast
    [project.util.id.spell.POISON_BOLT] = { prio = 1 },
    [project.util.id.spell.EXTRACTION_STRIKE] = { prio = 1 },
    [project.util.id.spell.GRASPING_SLASH] = { prio = 1 },
    [project.util.id.spell.VORACIOUS_BITE] = { prio = 1 },

    -- CITY OF THREADS
    [project.util.id.spell.VENOM_STRIKE] = { prio = 1 },
    [project.util.id.spell.BRUTAL_JAB] = { prio = 1 },
    [project.util.id.spell.SUBJUGATE] = { prio = 1 },
    [project.util.id.spell.RIME_DAGGER] = { prio = 1 },
    [project.util.id.spell.OOZING_SMASH_1] = { prio = 1 },
    [project.util.id.spell.OOZING_SMASH_2] = { prio = 1 },
    [project.util.id.spell.PROCESS_OF_ELIMINATION] = { prio = 1 }, -- hits very hard

    -- DAWNBREAKER
    [project.util.id.spell.TAINTED_SLASH] = { prio = 1 },
    [project.util.id.spell.UMBRAL_RUSH] = { prio = 1 },
    [project.util.id.spell.TERRIFYING_SLAM] = { prio = 1 },
    [project.util.id.spell.OBSIDIAN_BEAM] = { prio = 1 },

    -- STONEVAULT
    [project.util.id.spell.CONCUSSIVE_SMASH] = { prio = 1 },
    [project.util.id.spell.SHADOW_CLAW] = { prio = 1 },
    [project.util.id.spell.STONEBREAKER_STRIKE] = { prio = 1 },
    [project.util.id.spell.SEISMIC_SMASH] = { prio = 1 },
    [project.util.id.spell.IGNEOUS_HAMMER] = { prio = 1 },
    [project.util.id.spell.CRYSTALLINE_SMASH] = { prio = 1 },

    -- MISTS OF TIRNA SCITHE
    --[project.util.id.spell.HAND_OF_THROS] = { prio = 1 }, -- buff on enemy
    [project.util.id.spell.ANIMA_SLASH] = { prio = 1 },
    [project.util.id.spell.SHRED_ARMOR] = { prio = 1 },
    [project.util.id.spell.TRIPLE_BITE] = { prio = 1 },

    -- NECROTIC WAKE
    [project.util.id.spell.BONE_CLAW] = { prio = 1 },
    [project.util.id.spell.BONEFLAY] = { prio = 1 },
    [project.util.id.spell.GRUESOME_CLEAVE] = { prio = 1 },
    [project.util.id.spell.SHATTER] = { prio = 1 },
    [project.util.id.spell.TENDERIZE] = { prio = 1 },
    [project.util.id.spell.MUTILATE] = { prio = 1 },
    [project.util.id.spell.SEPARATE_FLESH] = { prio = 1 },
    [project.util.id.spell.CRUNCH] = { prio = 1 },
    [project.util.id.spell.ICY_SHARD] = { prio = 1 },
    [project.util.id.spell.SEVER_FLESH] = { prio = 1 },

    -- SIEGE OF BORALUS
    [project.util.id.spell.TOOTH_BREAKER] = { prio = 1 },
    [project.util.id.spell.SINGING_STEEL] = { prio = 1 },
    --[project.util.id.spell.CURSED_SLASH] = { prio = 1 }, -- debuff
    [project.util.id.spell.CRIMSON_SWIPE] = { prio = 1 },
    [project.util.id.spell.ROTTING_WOUNDS] = { prio = 1 },

    -- GRIM BATOL
    [project.util.id.spell.BRUTAL_STRIKE] = { prio = 1 },
    [project.util.id.spell.RIVE] = { prio = 1 },
    [project.util.id.spell.LAVA_FIST] = { prio = 1 },
    [project.util.id.spell.SHADOWFLAME_SLASH] = { prio = 1 },
    [project.util.id.spell.SKULLSPLITTER] = { prio = 1 },
    [project.util.id.spell.MOLTEN_FLURRY] = { prio = 1 },
    [project.util.id.spell.MOLTEN_MACE] = { prio = 1 },
    [project.util.id.spell.CRUSH] = { prio = 1 },
}

project.util.tank_buster.time = math.huge
project.util.tank_buster.enemy = nil
project.util.tank_buster.dest = nil

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        if not source.enemy then
            return
        end

        if source.dist > project.util.check.player.range() then
            return
        end

        if project.util.tank_buster.time < math.huge
                and project.util.tank_buster.enemy.guid ~= source.guid then
            return
        end

        local spell_id, spell_name = select(12, unpack(info))
        local spell_info = tank_buster_spells[spell_id]
        if not spell_info then
            return
        end

        project.util.tank_buster.time = awful.time + source.castRemains - awful.spellCastBuffer - awful.buffer
        project.util.tank_buster.enemy = source
        project.util.tank_buster.dest = source.castTarget

        local cancel_time = source.castRemains
        if source.channelID then
            cancel_time = cancel_time + source.channelRemains / 4
        end
        C_Timer.After(cancel_time, function()
            if project.util.tank_buster.time ~= math.huge then
                project.util.debug.alert.pve("[TANK BUSTER] Cancelled tank damage, spell finished cast: " .. spell_name)

                project.util.tank_buster.time = math.huge
                project.util.tank_buster.enemy = nil
                project.util.tank_buster.dest = nil
            end
        end)

        project.util.debug.alert.pve("[TANK BUSTER] Detected tank buster: " .. spell_name)
    end
end)