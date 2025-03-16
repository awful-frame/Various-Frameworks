local Unlocker, awful, project = ...

local defensive_cooldowns = {
    ['Death Knight'] = {
        ["Anti-Magic Shell"] = { best = true },

        ["Icebound Fortitude"] = { best = false },
        ["Vampiric Blood"] = { best = false },
        ["Bloodforged Armor"] = { best = false },
        ["Tombstone"] = { best = false },
    },

    ['Demon Hunter'] = {
        ["Netherwalk"] = { best = true },

        ["Blur"] = { best = false },
        ["Demon Spikes"] = { best = false },
    },

    ['Druid'] = {
        ["Survival Instincts"] = { best = true },

        ["Barkskin"] = { best = false },
        ["Rage of the Sleeper"] = { best = false },
    },

    ['Evoker'] = {
        ["Renewing Blaze"] = { best = true },
        ["Rewind"] = { best = true },

        ["Obsidian Scales"] = { best = false },
    },

    ['Hunter'] = {
        ["Aspect of the Turtle"] = { best = true },

        ["Survival Tactics"] = { best = false },
        ["Survival of the Fittest"] = { best = false },
    },

    ['Mage'] = {
        ["Ice Block"] = { best = true },
        ["Alter Time"] = { best = true },
        ["Temporal Shield"] = { best = true },
    },

    ['Monk'] = {
        ["Touch of Karma"] = { best = true },

        ["Diffuse Magic"] = { best = false },
        ["Fortifying Brew"] = { best = false },
        ["Zen Meditation"] = { best = false },
        ["Invoke Niuzao, the Black Ox"] = { best = false },
        ["Dampen Harm"] = { best = false },
    },

    ['Paladin'] = {
        ["Divine Shield"] = { best = true },
        ["Ardent Defender"] = { best = true },
        ["Guardian of Ancient Kings"] = { best = true },

        ["Shield of Vengeance"] = { best = false },
        ["Divine Protection"] = { best = false },
    },

    ['Priest'] = {
        ["Dispersion"] = { best = true },
    },

    ['Rogue'] = {
        ["Cloak of Shadows"] = { best = true },
        ["Evasion"] = { best = false },
    },

    ['Shaman'] = {
        ["Burrow"] = { best = true },

        ["Astral Shift"] = { best = false },
    },

    ['Warlock'] = {
        ["Unending Resolve"] = { best = false },
    },

    ['Warrior'] = {
        ["Shield Wall"] = { best = false },
        ["Enraged Regeneration"] = { best = false },
        ["Die by the Sword"] = { best = false },
        ["Spell Block"] = { best = false },
        ["Bladestorm"] = { best = false },
    },

    ['Universal'] = {
        ["Life Cocoon"] = { best = true },
        ["Pain Suppression"] = { best = true },
        ["Darkness"] = { best = true },
        ["Guardian of the Forgotten Queen"] = { best = true },
        ["Ray of Hope"] = { best = true },
        ["Ancestral Protection Totem"] = { best = true },

        ["Power Word: Barrier"] = { best = false },
        ["Blessing of Sacrifice"] = { best = false },
        ["Blessing of Protection"] = { best = false },
        ["Lesser Anti-Magic Shell"] = { best = false },
        ["Anti-Magic Zone"] = { best = false },
        ["Ironbark"] = { best = false },
        ["Grove Protection"] = { best = false },
        ["Cenarion Ward"] = { best = false },
        ["Roar of Sacrifice"] = { best = false },
        ["Earthen Wall Totem"] = { best = false },
        ["Intervene"] = { best = false },
        ["Bodyguard"] = { best = false },
    },
}

project.util.check.target.defensives = function(target)
    if not target then
        return 0, 0, 0
    end

    local def = 0
    local def_dr = 0
    local def_best = 0

    local class = target.class

    if defensive_cooldowns[class] then
        for spell_name, buff_info in pairs(defensive_cooldowns[class]) do
            if target.buff(spell_name) and target.buffRemains(spell_name) > project.util.thresholds.buff() then
                project.util.debug.alert.cd("DEF: defensive buff on: " .. target.name .. " - " .. spell_name .. " - Best: " .. tostring(buff_info.best))
                def = def + 1
                if buff_info.best then
                    def_best = def_best + 1
                end
            end
        end
    end

    for spell_name, buff_info in pairs(defensive_cooldowns['Universal']) do
        if target.buff(spell_name) and target.buffRemains(spell_name) > project.util.thresholds.buff() then
            project.util.debug.alert.cd("DEF: universal defensive buff on: " .. target.name .. " - " .. spell_name .. " - Best: " .. tostring(buff_info.best))
            def = def + 1
            if buff_info.best then
                def_best = def_best + 1
            end
        end
    end

    return def, def_dr, def_best
end
