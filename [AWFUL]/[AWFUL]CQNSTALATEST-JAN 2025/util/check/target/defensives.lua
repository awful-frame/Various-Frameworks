local Unlocker, awful, project = ...

local defensive_cooldowns = {
    [project.util.id.class.DEATH_KNIGHT] = {
        [project.util.id.spell.ANTI_MAGIC_SHELL] = { name = "Anti-Magic Shell", best = true, danger = true },
        [project.util.id.spell.ICEBOUND_FORTITUDE] = { name = "Icebound Fortitude", best = false },
        [project.util.id.spell.VAMPIRIC_BLOOD] = { name = "Vampiric Blood", best = false },
        [project.util.id.spell.BLOODFORGED_ARMOR] = { name = "Bloodforged Armor", best = false },
        [project.util.id.spell.TOMBSTONE] = { name = "Tombstone", best = false },
    },

    [project.util.id.class.DEMON_HUNTER] = {
        [project.util.id.spell.NETHERWALK] = { name = "Netherwalk", best = true },
        [project.util.id.spell.BLUR] = { name = "Blur", best = false },
        [project.util.id.spell.DEMON_SPIKES_BUFF] = { name = "Demon Spikes", best = false },
    },

    [project.util.id.class.DRUID] = {
        [project.util.id.spell.SURVIVAL_INSTINCTS] = { name = "Survival Instincts", best = true, danger = true },
        [project.util.id.spell.BARKSKIN] = { name = "Barkskin", best = false },
        [project.util.id.spell.RAGE_OF_THE_SLEEPER] = { name = "Rage of the Sleeper", best = false },
    },

    [project.util.id.class.EVOKER] = {
        [project.util.id.spell.RENEWING_BLAZE] = { name = "Renewing Blaze", best = true },
        [project.util.id.spell.REWIND] = { name = "Rewind", best = true },
        [project.util.id.spell.OBSIDIAN_SCALES] = { name = "Obsidian Scales", best = false },
    },

    [project.util.id.class.HUNTER] = {
        [project.util.id.spell.ASPECT_OF_THE_TURTLE] = { name = "Aspect of the Turtle", best = true },
        [project.util.id.spell.SURVIVAL_TACTICS_BUFF] = { name = "Survival Tactics", best = true, danger = true },
        [project.util.id.spell.SURVIVAL_OF_THE_FITTEST] = { name = "Survival of the Fittest", best = false },
    },

    [project.util.id.class.MAGE] = {
        [project.util.id.spell.ICE_BLOCK] = { name = "Ice Block", best = true },
        [project.util.id.spell.ALTER_TIME] = { name = "Alter Time", best = true },
        [project.util.id.spell.TEMPORAL_SHIELD] = { name = "Temporal Shield", best = true, danger = true },
    },

    [project.util.id.class.MONK] = {
        [project.util.id.spell.TOUCH_OF_KARMA] = { name = "Touch of Karma", best = true },
        [project.util.id.spell.ZEN_MEDITATION] = { name = "Zen Meditation", best = true },
        [project.util.id.spell.DIFFUSE_MAGIC] = { name = "Diffuse Magic", best = true, danger = true },
        [project.util.id.spell.FORTIFYING_BREW_BUFF_1] = { name = "Fortifying Brew", best = false },
        [project.util.id.spell.FORTIFYING_BREW_BUFF_2] = { name = "Fortifying Brew", best = false },
        [project.util.id.spell.INVOKE_NIUZAO_THE_BLACK_OX] = { name = "Invoke Niuzao, the Black Ox", best = false },
        [project.util.id.spell.DAMPEN_HARM] = { name = "Dampen Harm", best = false },
    },

    [project.util.id.class.PALADIN] = {
        [project.util.id.spell.DIVINE_SHIELD] = { name = "Divine Shield", best = true },
        [project.util.id.spell.ARDENT_DEFENDER] = { name = "Ardent Defender", best = true },
        [project.util.id.spell.GUARDIAN_OF_ANCIENT_KINGS] = { name = "Guardian of Ancient Kings", best = true },
        [project.util.id.spell.SHIELD_OF_VENGEANCE] = { name = "Shield of Vengeance", best = false },
        [project.util.id.spell.DIVINE_PROTECTION] = { name = "Divine Protection", best = false },
        [project.util.id.spell.DIVINE_PROTECTION_STUNNED] = { name = "Divine Protection (Stunned)", best = false },
    },

    [project.util.id.class.PRIEST] = {
        [project.util.id.spell.DISPERSION] = { name = "Dispersion", best = true },
    },

    [project.util.id.class.ROGUE] = {
        [project.util.id.spell.CLOAK_OF_SHADOWS] = { name = "Cloak of Shadows", best = true },
        [project.util.id.spell.EVASION] = { name = "Evasion", best = true, danger = true },
    },

    [project.util.id.class.SHAMAN] = {
        [project.util.id.spell.BURROW] = { name = "Burrow", best = true },
        [project.util.id.spell.ASTRAL_SHIFT] = { name = "Astral Shift", best = true, danger = true },
    },

    [project.util.id.class.WARLOCK] = {
        [project.util.id.spell.UNENDING_RESOLVE] = { name = "Unending Resolve", best = true, danger = true },
        [project.util.id.spell.DARK_PACT] = { name = "Dark Pact", best = false },
    },

    [project.util.id.class.WARRIOR] = {
        [project.util.id.spell.SHIELD_WALL] = { name = "Shield Wall", best = false },
        [project.util.id.spell.ENRAGED_REGENERATION] = { name = "Enraged Regeneration", best = false },
        [project.util.id.spell.DIE_BY_THE_SWORD] = { name = "Die by the Sword", best = false },
        [project.util.id.spell.SPELL_BLOCK] = { name = "Spell Block", best = false },
        [project.util.id.spell.BLADESTORM_1] = { name = "Bladestorm", best = false },
        [project.util.id.spell.BLADESTORM_2] = { name = "Bladestorm", best = false },
        [project.util.id.spell.BLADESTORM_3] = { name = "Bladestorm", best = false },
        [project.util.id.spell.BLADESTORM_4] = { name = "Bladestorm", best = false },
    },

    [0] = {
        [project.util.id.spell.LIFE_COCOON] = { name = "Life Cocoon", best = true },
        [project.util.id.spell.PAIN_SUPPRESSION] = { name = "Pain Suppression", best = true, danger = true },
        [project.util.id.spell.DARKNESS_BUFF] = { name = "Darkness", best = true },
        [project.util.id.spell.GUARDIAN_OF_THE_FORGOTTEN_QUEEN_DIVINE_SHIELD] = { name = "Guardian of the Forgotten Queen", best = true },
        [project.util.id.spell.RAY_OF_HOPE] = { name = "Ray of Hope", best = true },
        [project.util.id.spell.BLESSING_OF_SPELLWARDING] = { name = "Blessing of Spellwarding", best = true },
        [project.util.id.spell.POWER_WORD_BARRIER_BUFF] = { name = "Power Word: Barrier", best = false },
        [project.util.id.spell.BLESSING_OF_SACRIFICE] = { name = "Blessing of Sacrifice", best = false },
        [project.util.id.spell.BLESSING_OF_PROTECTION] = { name = "Blessing of Protection", best = false },
        [project.util.id.spell.LESSER_ANTI_MAGIC_SHELL] = { name = "Lesser Anti-Magic Shell", best = false },
        [project.util.id.spell.ANTI_MAGIC_ZONE] = { name = "Anti-Magic Zone", best = false },
        [project.util.id.spell.IRONBARK] = { name = "Ironbark", best = false },
        [project.util.id.spell.GROVE_PROTECTION_BUFF] = { name = "Grove Protection", best = false },
        [project.util.id.spell.CENARION_WARD] = { name = "Cenarion Ward", best = false },
        [project.util.id.spell.ROAR_OF_SACRIFICE] = { name = "Roar of Sacrifice", best = false },
        [project.util.id.spell.EARTHEN_WALL_TOTEM_BUFF] = { name = "Earthen Wall Totem", best = false },
        [project.util.id.spell.INTERVENE_BUFF] = { name = "Intervene", best = false },
        [project.util.id.spell.BODYGUARD] = { name = "Bodyguard", best = false },
    },
}

local defensives_cache = {}
local DEFENSIVES_CACHE_DURATION = 0.2
local CACHE_CLEANUP_INTERVAL = 5
local last_cleanup_time = 0

local function cleanup_cache()
    if (awful.time - last_cleanup_time) < CACHE_CLEANUP_INTERVAL then
        return
    end

    defensives_cache = {}
    last_cleanup_time = awful.time
end

project.util.check.target.defensives = function(target)
    if not target
            or not target.player then
        return { def = 0, def_dr = 0, def_best = 0 }
    end

    cleanup_cache()

    local cache_key = target.guid

    local cache_entry = defensives_cache[cache_key]
    if cache_entry and (awful.time - cache_entry.time) < DEFENSIVES_CACHE_DURATION then
        return cache_entry.result
    end

    local result = { def = 0, def_dr = 0, def_best = 0 }

    if defensive_cooldowns[target.class3] then
        for spell_id, buff_info in pairs(defensive_cooldowns[target.class3]) do
            if target.buffRemains(spell_id) > project.util.thresholds.buff() then
                project.util.debug.alert.cd("[DEFENSIVE] Defensive buff on: " .. target.name .. " - " .. buff_info.name .. " - Best: " .. tostring(buff_info.best))
                result.def = result.def + 1
                if buff_info.best then
                    if target.hp < 30 and buff_info.danger then
                    else
                        result.def_best = result.def_best + 1
                    end
                end
            end
        end
    end

    for spell_id, buff_info in pairs(defensive_cooldowns[0]) do
        if target.buffRemains(spell_id) > project.util.thresholds.buff() then
            project.util.debug.alert.cd("[DEFENSIVE] Universal defensive buff on: " .. target.name .. " - " .. buff_info.name .. " - Best: " .. tostring(buff_info.best))
            result.def = result.def + 1
            if buff_info.best then
                if target.hp < 30 and buff_info.danger then
                else
                    result.def_best = result.def_best + 1
                end
            end
        end
    end

    defensives_cache[cache_key] = {
        result = result,
        time = awful.time,
    }

    return result
end
