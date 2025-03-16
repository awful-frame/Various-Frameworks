local Unlocker, awful, project = ...

local party_damage_spells = {
    -- PVE
    -- RAID
    -- ULGRAX
    [project.util.id.spell.VENOMOUS_LASH] = { name = "Venomous Lash" },
    [project.util.id.spell.DIGESTIVE_ACID] = { name = "Digestive Acid" },
    [project.util.id.spell.SWALLOWING_DARKNESS_1] = { name = "Swallowing Darkness" },
    [project.util.id.spell.SWALLOWING_DARKNESS_2] = { name = "Swallowing Darkness" },
    [project.util.id.spell.HULKING_CRASH_1] = { name = "Hulking Crash" },
    [project.util.id.spell.HULKING_CRASH_2] = { name = "Hulking Crash" },

    -- THE BLOODBOUND HORROR
    [project.util.id.spell.GRUESOME_DISGORGE] = { name = "Gruesome Disgorge" },
    [project.util.id.spell.GORESPLATTER_BH] = { name = "Goresplatter" },

    -- SIKRAN
    [project.util.id.spell.SHATTERING_SWEEP] = { name = "Shattering Sweep" },
    [project.util.id.spell.DECIMATE] = { name = "Decimate" },

    -- RASHA'NAN
    [project.util.id.spell.EROSIVE_SPRAY_NP] = { name = "Erosive Spray" },
    [project.util.id.spell.SPINNERETS_STRANDS_NP] = { name = "Spinneret's Strands" },
    [project.util.id.spell.WEB_REAVE] = { name = "Web Reave" },

    -- OVI'NAX
    [project.util.id.spell.VOLATILE_CONCOCTION] = { delay = 8, name = "Volatile Concoction" },
    [project.util.id.spell.POISON_BURST] = { name = "Poison Burst" },

    -- KYVEZA
    [project.util.id.spell.NETHER_RIFT] = { name = "Nether Rift" },

    -- THE SILKEN COURT
    [project.util.id.spell.UNLEASHED_SWARM] = { name = "Unleashed Swarm" },

    -- QUEEN ANSUREK
    [project.util.id.spell.WREST_1] = { name = "Wrest" },
    [project.util.id.spell.WREST_2] = { name = "Wrest" },
    [project.util.id.spell.GORGE] = { name = "Gorge" },
    [project.util.id.spell.ROYAL_CONDEMNATION] = { name = "Royal Condemnation" },

    -- NERUB-AR PALACE TRASH
    [project.util.id.spell.ACIDIC_HAIL] = { name = "Acidic Hail" },

    [project.util.id.spell.PSYCHIC_SCREAM_NP_TRASH] = { name = "Psychic Scream" },
    [project.util.id.spell.VOID_BOLT_VOLLEY] = { name = "Void Bolt Volley" },
    [project.util.id.spell.ENSHROUDING_PULSE] = { name = "Enshrouding Pulse" },
    [project.util.id.spell.DEAFENING_ROAR] = { name = "Deafening Roar" },
    [project.util.id.spell.INFESTING_SWARM] = { name = "Infesting Swarm" },

    -- ARA-KARA
    [project.util.id.spell.ALERTING_SHRILL] = { name = "Alerting Shrill" },
    [project.util.id.spell.GOSSAMER_ONSLAUGHT] = { name = "Gossamer Onslaught" },

    [project.util.id.spell.EYE_OF_THE_SWARM_CAST] = { name = "Eye of the Swarm" },
    [project.util.id.spell.EYE_OF_THE_SWARM_CHANNEL] = { name = "Eye of the Swarm" },

    [project.util.id.spell.CALL_OF_THE_BROOD_CAST] = { name = "Call of the Brood" },
    [project.util.id.spell.CALL_OF_THE_BROOD_CHANNEL] = { name = "Call of the Brood" },
    [project.util.id.spell.RESONANT_BARRAGE] = { name = "Resonant Barrage" },

    [project.util.id.spell.REVOLTING_VOLLEY] = { name = "Revolting Volley" },
    [project.util.id.spell.VENOM_VOLLEY_1] = { name = "Venom Volley" },
    [project.util.id.spell.VENOM_VOLLEY_2] = { name = "Venom Volley" },
    [project.util.id.spell.MASSIVE_SLAM] = { name = "Massive Slam" },
    [project.util.id.spell.SLAM_ARAKARA] = { name = "Slam" },
    [project.util.id.spell.CULTIVATED_POISON] = { name = "Cultivated Poison" },

    -- CITY OF THREADS
    [project.util.id.spell.FIERCE_STOMPING] = { name = "Fierce Stomping" },
    [project.util.id.spell.VOCIFEROUS_INDOCTRINATION] = { name = "Vociferous Indoctrination" },
    [project.util.id.spell.DUSKBRINGER] = { name = "Duskbringer" },
    [project.util.id.spell.DARK_PULSE] = { name = "Dark Pulse" },

    [project.util.id.spell.SPLICE] = { name = "Splice" },
    [project.util.id.spell.VISCOUS_DARKNESS_1] = { name = "Viscous Darkness" },
    [project.util.id.spell.VISCOUS_DARKNESS_2] = { name = "Viscous Darkness" },
    [project.util.id.spell.UMBRAL_WEAVE_1] = { name = "Umbral Weave" },
    [project.util.id.spell.UMBRAL_WEAVE_2] = { name = "Umbral Weave" },
    [project.util.id.spell.RIME_DAGGER] = { name = "Rime Dagger" },
    [project.util.id.spell.ICE_SICKLES] = { name = "Ice Sickles" },
    [project.util.id.spell.TREMOR_SLAM] = { name = "Tremor Slam" },
    [project.util.id.spell.TREMOR_SLAM_TRASH] = { name = "Tremor Slam" },
    [project.util.id.spell.RAVENOUS_SWARM] = { name = "Ravenous Swarm" },
    [project.util.id.spell.VOID_RUSH] = { name = "Void Rush" },
    [project.util.id.spell.VENOMOUS_SPRAY] = { name = "Venomous Spray" },
    [project.util.id.spell.VOID_WAVE] = { name = "Void Wave" },

    -- DAWNBREAKER
    [project.util.id.spell.DARK_FLOES] = { name = "Dark Floes" },
    [project.util.id.spell.SHADOWY_DECAY] = { name = "Shadowy Decay" },
    [project.util.id.spell.SHADOWY_DECAY_TRASH] = { name = "Shadowy Decay" },
    [project.util.id.spell.EROSIVE_SPRAY_DB] = { name = "Erosive Spray" },
    [project.util.id.spell.BURNING_SHADOWS] = { name = "Burning Shadows" },
    [project.util.id.spell.DARK_ORB] = { delay = 4 + 2, name = "Dark Orb" }, -- cast time + orb moving delay
    [project.util.id.spell.DARK_ORB_TRASH] = { delay = 4 + 2, name = "Dark Orb" }, -- cast time + orb moving delay

    [project.util.id.spell.TORMENTING_BEAM] = { name = "Tormenting Beam" },
    [project.util.id.spell.TORMENTING_RAY] = { name = "Tormenting Ray" },
    [project.util.id.spell.TORMENTING_ERUPTION_1] = { name = "Tormenting Eruption" },
    [project.util.id.spell.TORMENTING_ERUPTION_2] = { name = "Tormenting Eruption" },
    [project.util.id.spell.TORMENTING_ERUPTION_3] = { name = "Tormenting Eruption" },
    [project.util.id.spell.SPINNERETS_STRANDS_DB] = { name = "Spinneret's Strands" },
    [project.util.id.spell.BURNING_SHADOWS] = { name = "Burning Shadows" },
    [project.util.id.spell.ABYSSAL_HOWL] = { name = "Abyssal Howl", interruptible = true },

    -- STONEVAULT
    [project.util.id.spell.VOID_OUTBURST] = { name = "Void Outburst" },
    [project.util.id.spell.ENTROPIC_RECKONING] = { name = "Entropic Reckoning" },

    [project.util.id.spell.GROUND_POUND] = { name = "Ground Pound" },
    [project.util.id.spell.HOWLING_FEAR] = { name = "Howling Fear", interruptible = true },
    [project.util.id.spell.PIERCING_WAIL] = { name = "Piercing Wail" },
    [project.util.id.spell.SMASH_ROCK] = { name = "Smash Rock" },
    [project.util.id.spell.EARTHBURST] = { name = "Earthburst" },
    [project.util.id.spell.VOLATILE_SPIKE] = { delay = 10, name = "Volatile Spike" },
    [project.util.id.spell.EARTH_SHATTERER] = { name = "Earth Shatterer" },
    [project.util.id.spell.MOLTEN_METAL] = { name = "Molten Metal" },
    [project.util.id.spell.VOID_DISCHARGE] = { name = "Void Discharge" },
    [project.util.id.spell.UNSTABLE_CRASH] = { name = "Unstable Crash" },
    [project.util.id.spell.DEFILING_OUTBURST] = { name = "Defiling Outburst" },

    -- MISTS OF TIRNA SCITHE
    [project.util.id.spell.HARVEST_ESSENCE] = { name = "Harvest Essence" },
    [project.util.id.spell.FURIOUS_THRASHING] = { name = "Furious Thrashing" },
    [project.util.id.spell.CONSUMPTION] = { name = "Consumption" },
    [project.util.id.spell.BRAMBLETHORN_COAT] = { name = "Bramblethorn Coat", interruptible = true },
    [project.util.id.spell.ACID_NOVA] = { name = "Acid Nova" },
    [project.util.id.spell.EMBRACE_DARKNESS] = { name = "Embrace Darkness" },
    [project.util.id.spell.PENALIZING_BURST] = { name = "Penalizing Burst" },
    [project.util.id.spell.MIND_LINK] = { name = "Mind Link" },
    [project.util.id.spell.GUESSING_GAME_1] = { name = "Guessing Game" },
    [project.util.id.spell.GUESSING_GAME_2] = { name = "Guessing Game" },

    -- NECROTIC WAKE
    [project.util.id.spell.HEAVING_RETCH] = { name = "Heaving Retch" },
    [project.util.id.spell.AWAKEN_CREATION] = { delay = 3, name = "Awaken Creation" },
    [project.util.id.spell.WRATH_OF_ZOLRAMUS] = { name = "Wrath of Zolramus" },
    [project.util.id.spell.DARK_SHROUD] = { name = "Dark Shroud" },
    [project.util.id.spell.GORESPLATTER_NW] = { name = "Goresplatter", interruptible = true },
    [project.util.id.spell.CARRION_ERUPTION] = { name = "Carrion Eruption" },
    [project.util.id.spell.FROSTBOLT_VOLLEY] = { name = "Frostbolt Volley" }, -- interruptible but should prepare.

    -- SIEGE OF BORALUS
    [project.util.id.spell.SHATTERING_BELLOW] = { name = "Shattering Bellow" },
    [project.util.id.spell.IRON_HOOK] = { name = "Iron Hook" },
    [project.util.id.spell.CRUSHING_SLAM] = { name = "Crushing Slam" },
    [project.util.id.spell.GORE_CRASH] = { name = "Gore Crash" },
    [project.util.id.spell.FIERY_RICOCHET] = { name = "Fiery Ricochet" },
    [project.util.id.spell.BREAK_WATER] = { delay = 2, name = "Break Water" },
    [project.util.id.spell.SLAM] = { name = "Slam" },

    -- GRIM BATOL
    [project.util.id.spell.FORGE_SWORDS] = { name = "Forge Swords" },
    [project.util.id.spell.FORGE_AXE] = { name = "Forge Axe" },
    [project.util.id.spell.FORGE_MACE] = { name = "Forge Mace" },
    [project.util.id.spell.VOID_SURGE] = { name = "Void Surge" },
    [project.util.id.spell.MASS_TREMOR] = { name = "Mass Tremor", interruptible = true },
    [project.util.id.spell.UMBRAL_WIND] = { name = "Umbral Wind" },
    [project.util.id.spell.MOLTEN_WAKE] = { name = "Molten Wake" },
    [project.util.id.spell.ASCENSION] = { name = "Ascension" },
    [project.util.id.spell.COMMANDING_ROAR] = { name = "Commanding Roar" },
    [project.util.id.spell.ROCK_SPIKE] = { name = "Rock Spike" },
    [project.util.id.spell.MOLTEN_FLURRY] = { name = "Molten Flurry" },
    [project.util.id.spell.INVOCATION_OF_SHADOWFLAME] = { name = "Invocation of Shadowflame" },
    [project.util.id.spell.CURSE_OF_ENTROPY] = { name = "Curse of Entropy" },
    [project.util.id.spell.TWILIGHT_BUFFET] = { name = "Twilight Buffet" },
    [project.util.id.spell.ENVELOPING_SHADOWFLAME] = { name = "Enveloping Shadowflame" },
    [project.util.id.spell.ABYSSAL_CORRUPTION] = { name = "Abyssal Corruption" },

    -- CINDERBREW MEDERY
    [project.util.id.spell.EXPLOSIVE_BREW] = { name = "Explosive Brew" },
    [project.util.id.spell.SPOUTING_STOUT] = { name = "Spouting Shout" },
}

project.util.party_damage.time = math.huge
project.util.party_damage.early_time = math.huge
project.util.party_damage.enemy = nil
project.util.party_damage.spell = nil

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        if not source.enemy then
            return
        end

        if source.dist > project.util.check.player.range() then
            return
        end

        if project.util.party_damage.time < math.huge
                and project.util.party_damage.enemy.guid ~= source.guid then
            return
        end

        local spell_id, spell_name = select(12, unpack(info))
        local spell_info = party_damage_spells[spell_id]
        if not spell_info then
            return
        end

        local time = source.castRemains + (spell_info.delay or 0)

        project.util.party_damage.time = awful.time + time - awful.buffer
        project.util.party_damage.enemy = source
        project.util.party_damage.spell = spell_info.name

        if not spell_info.interruptible and project.util.party_damage.enemy.level ~= awful.player.level then
            project.util.party_damage.early_time = awful.time + (spell_info.delay or 0)
            if source.channelID then
                project.util.party_damage.early_time = project.util.party_damage.early_time + source.channelRemains / 4
            end
        end

        C_Timer.After(time, function()
            if project.util.party_damage.early_time ~= math.huge then
                project.util.debug.alert.pve("[PARTY DAMAGE] Cancelled early party damage: " .. spell_name)
                project.util.party_damage.early_time = math.huge
            end
        end)

        C_Timer.After(time + source.channelRemains + 3, function()
            if project.util.party_damage.time ~= math.huge then
                project.util.debug.alert.pve("[PARTY DAMAGE] Cancelled party damage, 3 seconds passed: " .. spell_name)

                project.util.party_damage.time = math.huge
                project.util.party_damage.early_time = math.huge
                project.util.party_damage.enemy = nil
                project.util.party_damage.spell = nil
            end
        end)

        local time_check_interupted = time - awful.spellCastBuffer - awful.buffer - (spell_info.delay or 0)
        if time_check_interupted > 0 then
            C_Timer.After(time_check_interupted, function()
                if not source.castID and not source.channelID then
                    project.util.debug.alert.pve("[PARTY DAMAGE] Cancelled party damage, interrupted or dead?: " .. spell_name)

                    project.util.party_damage.time = math.huge
                    project.util.party_damage.early_time = math.huge
                    project.util.party_damage.enemy = nil
                    project.util.party_damage.spell = nil
                end
            end)
        end

        project.util.debug.alert.pve("[PARTY DAMAGE] Detected party damage: " .. spell_name)
    end
end)