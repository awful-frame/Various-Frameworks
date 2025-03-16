local Unlocker, awful, project = ...

local cooldowns = {
    [project.util.id.class.DEATH_KNIGHT] = {
        -- BIG
        [project.util.id.spell.PILLAR_OF_FROST] = { name = "Pillar of Frost", duration = 12, importance = "big", type = "buff" },
        [project.util.id.spell.UNHOLY_ASSAULT] = { name = "Unholy Assault", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.ABOMINATION_LIMB_1] = { name = "Abomination Limb", duration = 12, importance = "big", type = "buff" },
        [project.util.id.spell.ABOMINATION_LIMB_2] = { name = "Abomination Limb", duration = 12, importance = "big", type = "buff" },
        [project.util.id.spell.BREATH_OF_SINDRAGOSA] = { name = "Breath of Sindragosa", duration = 8, importance = "big", type = "buff" },

        [project.util.id.spell.SUMMON_GARGOYLE] = { name = "Summon Gargoyle", duration = 25, baseCD = 180, importance = "big", type = "cast" },

        -- SMALL
        [project.util.id.spell.INFLICTION_OF_SORROW] = { name = "Infliction of Sorrow", duration = 15, importance = "small", type = "buff" },
        [project.util.id.spell.A_FEAST_OF_SOULS] = { name = "A Feast Of Souls", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.BONESTORM] = { name = "Bonestorm", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.DANCING_RUNE_WEAPON] = { name = "Dancing Rune Weapon", duration = 8, importance = "small", type = "buff" },
        [project.util.id.spell.DARK_TRANSFORMATION] = { name = "Dark Transformation", duration = 15, importance = "small", type = "buff" },
        [project.util.id.spell.GIFT_OF_THE_SANLAYN_BUFF] = { name = "Gift of the San'layn", duration = 15, importance = "small", type = "buff" },
        [project.util.id.spell.REMORSELESS_WINTER] = { name = "Remorseless Winter", duration = 8, importance = "small", type = "buff" },

        [project.util.id.spell.REAPERS_MARK_DEBUFF] = { name = "Reaper's Mark", duration = 12, importance = "small", type = "debuff" },
    },

    [project.util.id.class.DEMON_HUNTER] = {
        -- BIG
        [project.util.id.spell.METAMORPHOSIS_BUFF] = { name = "Metamorphosis", duration = 20, importance = "big", type = "buff" },

        [project.util.id.spell.THE_HUNT_BUFF] = { name = "The Hunt", duration = 20, importance = "big", type = "debuff" },

        -- SMALL
        [project.util.id.spell.FEL_BARRAGE] = { name = "Fel Barrage", duration = 8, importance = "small", type = "buff" },

        [project.util.id.spell.ESSENCE_BREAK_DEBUFF] = { name = "Essence Break", duration = 4, importance = "small", type = "debuff" },
    },

    [project.util.id.class.DRUID] = {
        -- BIG
        [project.util.id.spell.BERSERK_1] = { name = "Berserk", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.BERSERK_2] = { name = "Berserk", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.CELESTIAL_ALIGNMENT] = { name = "Celestial Alignment", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.INCARNATION_GUARDIAN_OF_URSOC] = { name = "Incarnation: Guardian of Ursoc", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.INCARNATION_CHOSEN_OF_ELUNE] = { name = "Incarnation: Chosen of Elune", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.INCARNATION_AVATAR_OF_ASHAMANE] = { name = "Incarnation: Avatar of Ashamane", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.CONVOKE_THE_SPIRITS] = { name = "Convoke the Spirits", duration = true, importance = "big", type = "channel" },

        -- SMALL
        [project.util.id.spell.TIGERS_FURY] = { name = "Tiger's Fury", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.RAGE_OF_THE_SLEEPER] = { name = "Rage of the Sleeper", duration = 8, importance = "small", type = "buff" },

        [project.util.id.spell.FERAL_FRENZY] = { name = "Feral Frenzy", duration = 6, baseCD = 45, importance = "small", type = "cast" },
    },

    [project.util.id.class.EVOKER] = {
        -- BIG
        [project.util.id.spell.DRAGONRAGE] = { name = "Dragonrage", duration = 18, importance = "big", type = "buff" },

        -- SMALL
        [project.util.id.spell.FURY_OF_THE_ASPECTS] = { name = "Fury of the Aspects", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.EBON_MIGHT] = { name = "Ebon Might", duration = 15, importance = "small", type = "buff" },
        [project.util.id.spell.DEEP_BREATH_BUFF] = { name = "Deep Breath", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.BREATH_OF_EONS] = { name = "Breath of Eons", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.MASS_DISINTEGRATE] = { name = "Mass Disintegrate", duration = 15, importance = "small", type = "buff" },
        [project.util.id.spell.TIP_THE_SCALES] = { name = "Tip the Scales", duration = 10, importance = "small", type = "buff" },
    },

    [project.util.id.class.HUNTER] = {
        -- BIG
        [project.util.id.spell.COORDINATED_ASSAULT] = { name = "Coordinated Assault", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.BESTIAL_WRATH] = { name = "Bestial Wrath", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.CALL_OF_THE_WILD] = { name = "Call of the Wild", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.TRUESHOT] = { name = "Trueshot", duration = 15, importance = "big", type = "buff" },

        -- SMALL
        [project.util.id.spell.BLOODSHED_DEBUFF] = { name = "Bloodshed", duration = 18, importance = "small", type = "debuff" },
        [project.util.id.spell.INTIMIDATION] = { name = "Intimidation", duration = 5, baseCD = 60, importance = "small", type = "cast" },
    },

    [project.util.id.class.MAGE] = {
        -- BIG
        [project.util.id.spell.COMBUSTION] = { name = "Combustion", duration = 10, importance = "big", type = "buff" },
        [project.util.id.spell.WILDFIRE_COMBUSTION] = { name = "Wildfire Combustion", duration = 10, importance = "big", type = "buff" },
        [project.util.id.spell.IMPROVED_COMBUSTION] = { name = "Improved Combustion", duration = 10, importance = "big", type = "buff" },
        [project.util.id.spell.ICY_VEINS] = { name = "Icy Veins", duration = 25, importance = "big", type = "buff" },
        [project.util.id.spell.ICE_FORM] = { name = "Ice Form", duration = 12, importance = "big", type = "buff" },
        [project.util.id.spell.ARCANE_SURGE_BUFF] = { name = "Arcane Surge", duration = 15, importance = "big", type = "buff" },

        -- SMALL
        [project.util.id.spell.ARCANE_BATTERY] = { name = "Arcane Battery", duration = 10, until_consumed = true, importance = "small", type = "buff" },
        [project.util.id.spell.PRESENCE_OF_MIND] = { name = "Presence of Mind", duration = 10, until_consumed = true, importance = "small", type = "buff" },
        [project.util.id.spell.ICY_VEINS_PROC] = { name = "Icy Veins PROC", duration = 12, importance = "small", type = "buff" },

        [project.util.id.spell.TOUCH_OF_THE_MAGI_DEBUFF] = { name = "Touch of the Magi", duration = 12, importance = "small", type = "debuff" },

        [project.util.id.spell.RAY_OF_FROST] = { name = "Ray of Frost", duration = true, importance = "small", type = "channel" },
    },

    [project.util.id.class.MONK] = {
        -- BIG
        [project.util.id.spell.STORM_EARTH_AND_FIRE] = { name = "Storm, Earth, and Fire", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.WEAPONS_OF_ORDER] = { name = "Weapons of Order", duration = 30, importance = "big", type = "buff" },

        [project.util.id.spell.INVOKE_XUEN_THE_WHITE_TIGER] = { name = "Invoke Xuen, the White Tiger", duration = 20, baseCD = 120, importance = "big", type = "cast" },

        [project.util.id.spell.CELESTIAL_CONDUIT] = { name = "Celestial Conduit", duration = true, importance = "big", type = "channel" },
    },

    [project.util.id.class.PALADIN] = {
        -- BIG
        [project.util.id.spell.AVENGING_WRATH] = { name = "Avenging Wrath", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.CRUSADE] = { name = "Crusade", duration = 27, importance = "big", type = "buff" },

        -- SMALL
        [project.util.id.spell.CRUSADE_PROC] = { name = "Crusade PROC", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.AVENGING_WRATH_PROC] = { name = "Avenging Wrath PROC", duration = 8, importance = "small", type = "buff" },

        [project.util.id.spell.EXECUTION_SENTENCE] = { name = "Execution Sentence", duration = 8, importance = "small", type = "debuff" },
        [project.util.id.spell.TRUTHS_WAKE] = { name = "Truth's Wake", duration = 9, importance = "small", type = "debuff" },
        [project.util.id.spell.FINAL_RECKONING] = { name = "Final Reckoning", duration = 12, importance = "small", type = "debuff" },

        [project.util.id.spell.DIVINE_TOLL] = { name = "Divine Toll", duration = 6, baseCD = 60, importance = "small", type = "cast" },
        [project.util.id.spell.DIVINE_TOLL_1] = { name = "Divine Toll 1", duration = 6, baseCD = 60, importance = "small", type = "cast" },
        [project.util.id.spell.DIVINE_TOLL_2] = { name = "Divine Toll 2", duration = 6, baseCD = 60, importance = "small", type = "cast" },
        [project.util.id.spell.DIVINE_TOLL_3] = { name = "Divine Toll 3", duration = 6, baseCD = 60, importance = "small", type = "cast" },
    },

    [project.util.id.class.PRIEST] = {
        -- BIG
        [project.util.id.spell.POWER_INFUSION] = { name = "Power Infusion", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.VOIDFORM_BUFF] = { name = "Voidform", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.DARK_ASCENSION] = { name = "Dark Ascension", duration = 20, importance = "big", type = "buff" },

        -- SMALL
        [project.util.id.spell.DARK_ARCHANGEL] = { name = "Dark Archangel", duration = 8, importance = "small", type = "buff" }
    ,
        [project.util.id.spell.MINDGAMES] = { name = "Mindgames", duration = 7, importance = "small", type = "debuff" },

        [project.util.id.spell.PSYFIEND] = { name = "Psyfiend", duration = 12, baseCD = 45, importance = "small", type = "cast" },
        [project.util.id.spell.VOIDWRAITH_TALENT] = { name = "Voidwraith Talent", duration = 15, baseCD = 60, importance = "small", type = "cast" },
        [project.util.id.spell.VOIDWRAITH] = { name = "Voidwraith", duration = 15, baseCD = 60, importance = "small", type = "cast" },

        [project.util.id.spell.VOID_TORRENT] = { name = "Void Torrent", duration = true, importance = "small", type = "channel" },
    },

    [project.util.id.class.ROGUE] = {
        -- BIG
        [project.util.id.spell.SHADOW_BLADES] = { name = "Shadow Blades", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.FLAGELLATION] = { name = "Flagellation", duration = 12, importance = "big", type = "buff" },
        [project.util.id.spell.ROLL_THE_BONES] = { name = "Roll the Bones", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.DREADBLADES] = { name = "Dreadblades", duration = 10, importance = "big", type = "buff" },
        [project.util.id.spell.DEATHMARK] = { name = "Deathmark", duration = 16, importance = "big", type = "debuff" },
        [project.util.id.spell.GHOSTLY_STRIKE] = { name = "Ghostly Strike", duration = 12, importance = "big", type = "debuff" },
        [project.util.id.spell.KINGSBANE] = { name = "Kingsbane", duration = 14, importance = "big", type = "debuff" },
        [project.util.id.spell.SHADOW_DANCE_BUFF] = { name = "Shadow Dance", duration = 6, importance = "big", type = "buff" },

        -- SMALL
        [project.util.id.spell.SYMBOLS_OF_DEATH] = { name = "Symbols of Death", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.THISTLE_TEA] = { name = "Thistle Tea", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.SMOKE_BOMB] = { name = "Smoke Bomb BUFF", duration = 5, importance = "small", type = "buff" },
        [project.util.id.spell.SMOKE_BOMB_2] = { name = "Smoke Bomb BUFF 2", duration = 5, importance = "small", type = "buff" },
        [project.util.id.spell.GOREMAWS_BITE_BUFF] = { name = "Goremaw's Bite", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.COLD_BLOOD] = { name = "Cold Blood", duration = 10, importance = "small", type = "buff" },

        [project.util.id.spell.SHADOWY_DUEL] = { name = "Shadowy Duel", duration = 6, importance = "small", type = "debuff" },
        [project.util.id.spell.SMOKE_BOMB_DEBUFF] = { name = "Smoke Bomb DEBUFF DEBUFF", duration = 5, importance = "small", type = "debuff" },

        [project.util.id.spell.KIDNEY_SHOT] = { name = "Kidney Shot", duration = 6, baseCD = 30, importance = "small", type = "cast" },
    },

    [project.util.id.class.SHAMAN] = {
        -- BIG
        [project.util.id.spell.ASCENDANCE_ELE] = { name = "Ascendance", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.ASCENDANCE_ENH] = { name = "Ascendance", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.FERAL_SPIRIT_BUFF] = { name = "Feral Spirit BUFF", duration = 15, importance = "big", type = "buff" },
        [project.util.id.spell.FERAL_SPIRIT] = { name = "Feral Spirit USED", duration = 15, baseCD = 90, importance = "big", type = "cast" },

        -- SMALL
        [project.util.id.spell.PRIMORDIAL_WAVE] = { name = "Primordial Wave", duration = 15, importance = "small", type = "buff" },
        [project.util.id.spell.DOOM_WINDS_1] = { name = "Doom Winds", duration = 8, importance = "small", type = "buff" },
        [project.util.id.spell.DOOM_WINDS_2] = { name = "Doom Winds", duration = 8, importance = "small", type = "buff" },
        [project.util.id.spell.HEROISM] = { name = "Heroism", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.HEROISM_PVP] = { name = "Heroism PvP", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.BLOODLUST] = { name = "Bloodlust", duration = 10, importance = "small", type = "buff" },
        [project.util.id.spell.BLOODLUST_PVP] = { name = "Bloodlust PvP", duration = 10, importance = "small", type = "buff" },
    },

    [project.util.id.class.WARLOCK] = {
        -- BIG
        [project.util.id.spell.DARK_SOUL_MISERY] = { name = "Dark Soul: Misery", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.DARK_SOUL_INSTABILITY] = { name = "Dark Soul: Instability", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.SUMMON_INFERNAL] = { name = "Summon Infernal", duration = 30, baseCD = 120, importance = "big", type = "cast" },
        [project.util.id.spell.SUMMON_DEMONIC_TYRANT] = { name = "Summon Demonic Tyrant", duration = 15, baseCD = 60, importance = "big", type = "cast" },
        [project.util.id.spell.SUMMON_DARKGLARE] = { name = "Summon Darkglare", duration = 20, baseCD = 120, importance = "big", type = "cast" },

        -- SMALL
        [project.util.id.spell.AMPLIFY_CURSE] = { name = "Amplify Curse", duration = 15, until_consumed = true, importance = "small", type = "buff" },
        [project.util.id.spell.TOUCH_OF_RANCORA_1] = { name = "Touch of Rancora", duration = 15, until_consumed = true, importance = "small", type = "buff" },
        [project.util.id.spell.TOUCH_OF_RANCORA_2] = { name = "Touch of Rancora", duration = 15, until_consumed = true, importance = "small", type = "buff" },
        [project.util.id.spell.MALEVOLENCE] = { name = "Malevolence", duration = 20, importance = "small", type = "buff" },

        [project.util.id.spell.SOUL_RIP] = { name = "Soul Rip", duration = 8, importance = "small", type = "debuff" },
        [project.util.id.spell.SOUL_ROT] = { name = "Soul Rot", duration = 8, importance = "small", type = "debuff" },

        [project.util.id.spell.CALL_OBSERVER] = { name = "Call Observer", duration = 20, baseCD = 60, importance = "small", type = "cast" },
        [project.util.id.spell.FEL_OBELISK] = { name = "Fel Obelisk", duration = 15, baseCD = 45, importance = "small", type = "cast" },
    },

    [project.util.id.class.WARRIOR] = {
        -- BIG
        [project.util.id.spell.AVATAR] = { name = "Avatar", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.AVATAR_TANK] = { name = "Avatar (Tank)", duration = 20, importance = "big", type = "buff" },
        [project.util.id.spell.RECKLESSNESS] = { name = "Recklessness", duration = 12, importance = "big", type = "buff" },

        -- SMALL
        [project.util.id.spell.BLADESTORM_1] = { name = "Bladestorm 1", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.BLADESTORM_2] = { name = "Bladestorm 2", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.BLADESTORM_3] = { name = "Bladestorm 3", duration = 6, importance = "small", type = "buff" },
        [project.util.id.spell.BLADESTORM_4] = { name = "Bladestorm 4", duration = 6, importance = "small", type = "buff" },

        [project.util.id.spell.THUNDEROUS_ROAR_DEBUFF] = { name = "Thunderous Roar", duration = 8, importance = "small", type = "debuff" },
        [project.util.id.spell.COLOSSUS_SMASH_DEBUFF] = { name = "Colossus Smash", duration = 10, importance = "small", type = "debuff" },

        [project.util.id.spell.WARBREAKER] = { name = "Warbreaker", duration = 10, baseCD = 45, importance = "small", type = "cast" },
        [project.util.id.spell.DEMOLISH] = { name = "Demolish", duration = 5, baseCD = 45, importance = "small", type = "cast" },
    },
}

local function get_duration_threshold(duration, is_friend)
    if duration > 15 then
        return duration / 2
    end
    return duration / 3
end

local cooldowns_cache = {}
local COOLDOWNS_CACHE_DURATION = 0.5
local COOLDOWNS_CACHE_CLEANUP_INTERVAL = 5
local cooldowns_last_cleanup_time = 0

local function cleanup_cooldowns_cache()
    if (awful.time - cooldowns_last_cleanup_time) < COOLDOWNS_CACHE_CLEANUP_INTERVAL then
        return
    end

    cooldowns_cache = {}
    cooldowns_last_cleanup_time = awful.time
end

project.util.check.target.cooldowns = function(target, attacker)
    if not attacker
            or not attacker.class3
            or not attacker.player
            or attacker.healer then
        return { total = 0, big = 0, small = 0 }
    end

    cleanup_cooldowns_cache()

    local cache_key = attacker.guid
    local cache_entry = cooldowns_cache[cache_key]

    if cache_entry and (awful.time - cache_entry.time) < COOLDOWNS_CACHE_DURATION then
        return cache_entry.result
    end

    local result = { total = 0, big = 0, small = 0 }
    local class_spells = cooldowns[attacker.class3]

    if not class_spells then
        return result
    end

    for spell_id, spell_info in pairs(class_spells) do
        local spell_type = spell_info.type
        local importance = spell_info.importance

        if project.util.check.scenario.type() == "pve" and importance == "small" then
            --skip
        else
            if spell_type == "buff" then
                if attacker.buffRemains(spell_id) > get_duration_threshold(spell_info.duration, attacker.friend)
                        and attacker.buffUptime(spell_id) > 0.5 then
                    project.util.debug.alert.cd("CD: " .. importance .. " buff on: " .. tostring(attacker.name) .. " - " .. spell_info.name)
                    result.total = result.total + 1
                    result[importance] = result[importance] + 1
                end
            elseif spell_type == "debuff" then
                if target and target.exists then
                    if target.debuffRemains(spell_id) > get_duration_threshold(spell_info.duration, attacker.friend)
                            and target.debuffUptime(spell_id) > 0.5 then
                        project.util.debug.alert.cd("CD: " .. importance .. " debuff on: " .. tostring(target.name) .. " - " .. spell_info.name)
                        result.total = result.total + 1
                        result[importance] = result[importance] + 1
                    end
                end
            elseif spell_type == "cast" then
                local baseCD = spell_info.baseCD or 0
                if attacker.cooldown(spell_id) > (baseCD - get_duration_threshold(spell_info.duration, target and target.friend or false)) then
                    project.util.debug.alert.cd("CD: " .. importance .. " cast by: " .. tostring(attacker.name) .. " - " .. spell_info.name)
                    result.total = result.total + 1
                    result[importance] = result[importance] + 1
                end
            elseif spell_type == "channel" then
                if attacker.channelID == spell_id then
                    project.util.debug.alert.cd("CD: " .. importance .. " channel by: " .. tostring(attacker.name) .. " - " .. spell_info.name)
                    result.total = result.total + 1
                    result[importance] = result[importance] + 1
                end
            end
        end
    end

    cooldowns_cache[cache_key] = {
        result = result,
        time = awful.time,
    }

    return result
end
