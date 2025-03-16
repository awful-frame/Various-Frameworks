local Unlocker, awful, project = ...

local cooldowns = {
    ['Death Knight'] = {
        big = {
            buffs = {
                ["Pillar of Frost"] = { duration = 12 },
                ["Unholy Assault"] = { duration = 20 },
                ["Abomination Limb"] = { duration = 12 },
            },
            debuffs = {},
            cast = {
                ["Breath of Sindragosa"] = { duration = 8, baseCD = 120 },
                ["Summon Gargoyle"] = { duration = 20, baseCD = 180 },
            },
            channel = {},
        },
        small = {
            buffs = {
                ["Bonestorm"] = { duration = 10 },
                ["Dancing Rune Weapon"] = { duration = 8 },
                ["Dark Transformation"] = { duration = 15 },
                ["Gift of the San'layn"] = { duration = 15 },
            },
            debuffs = {
                ["Reaper's Mark"] = { duration = 20 },
            },
            cast = {
                ["Summon Gargoyle"] = { duration = 20, baseCD = 180 },
            },
            channel = {},
        },
    },

    ['Demon Hunter'] = {
        big = {
            buffs = {
                ["Metamorphosis"] = { duration = 20 },
            },
            debuffs = {
                ["The Hunt"] = { duration = 20 },
            },
            cast = {},
            channel = {},
        },
        small = {
            buffs = {
                ["Fel Barrage"] = { duration = 4 * 2, until_consumed = true },
            },
            debuffs = {
                ["Essence Break"] = { duration = 4 },
            },
            cast = {},
            channel = {},
        },
    },

    ['Druid'] = {
        big = {
            buffs = {
                ["Berserk"] = { duration = 15 },
                ["Celestial Alignment"] = { duration = 15 },
                ["Incarnation: Chosen of Elune"] = { duration = 15 },
                ["Incarnation: Avatar of Ashamane"] = { duration = 20 },
            },
            debuffs = {},
            cast = {},
            channel = {
                ["Convoke the Spirits"] = true,
            },
        },
        small = {
            buffs = {
                ["Tiger's Fury"] = { duration = 10 },
                ["Rage of the Sleeper"] = { duration = 8 },
                ["Eclipse (Solar)"] = { duration = 15 },
                ["Eclipse (Lunar)"] = { duration = 15 },
                ["Eclipse"] = { duration = 15 },
            },
            debuffs = {},
            cast = {
                ["Feral Frenzy"] = { duration = 6, baseCD = 45 },
            },
            channel = {},
        },
    },

    ['Evoker'] = {
        big = {
            buffs = {
                ["Dragonrage"] = { duration = 18 },
            },
            debuffs = {},
            cast = {},
            channel = {},
        },
        small = {
            buffs = {
                ["Fury of the Aspects"] = { duration = 6 },
                ["Ebon Might"] = { duration = 15 },
                ["Deep Breath"] = { duration = 6 },
                ["Breath of Eons"] = { duration = 6 },
                ["Mass Disintegrate"] = { duration = 5 },
                ["Temporal Burst"] = { duration = 10 },
                ["Tip the Scales"] = { duration = 10 }, -- until consumed
            },
            debuffs = {},
            cast = {},
            channel = {},
        },
    },

    ['Hunter'] = {
        big = {
            buffs = {
                ["Coordinated Assault"] = { duration = 20 },
                ["Bestial Wrath"] = { duration = 15 },
                ["Call of the Wild"] = { duration = 20 },
                ["Trueshot"] = { duration = 15 },
            },
            debuffs = {
                ["Bloodshed"] = { duration = 18 },
            },
            cast = {},
            channel = {},
        },
        small = {
            buffs = {},
            debuffs = {},
            cast = {},
            channel = {},
        },
    },

    ['Mage'] = {
        big = {
            buffs = {
                ["Combustion"] = { duration = 10 },
                ["Wildfire Combustion"] = { duration = 10 },
                ["Improved Combustion"] = { duration = 10 },
                ["Icy Veins"] = { duration = 25 },
                ["Ice Form"] = { duration = 12 },
                ["Arcane Surge"] = { duration = 15 },
            },
            debuffs = {},
            cast = {},
            channel = {},
        },
        small = {
            buffs = {
                ["Arcane Battery"] = { duration = 30 * 2, until_consumed = true },
            },
            debuffs = {
                ["Touch of the Magi"] = { duration = 12 },
            },
            cast = {},
            channel = {
                ["Ray of Frost"] = true,
            },
        },
    },

    ['Monk'] = {
        big = {
            buffs = {
                ["Storm, Earth, and Fire"] = { duration = 15 },
                ["Weapons of Order"] = { duration = 30 },
                ["Celestial Conduit"] = { duration = 4 },
            },
            debuffs = {},
            cast = {
                ["Invoke Xuen, the White Tiger"] = { duration = 20, baseCD = 120 },
            },
            channel = {},
        },
        small = {
            buffs = {},
            debuffs = {},
            cast = {},
            channel = {},
        },
    },

    ['Paladin'] = {
        big = {
            buffs = {
                ["Avenging Wrath"] = { duration = 20 },
                ["Avenging Wrath: Might"] = { duration = 20 },
                ["Crusade"] = { duration = 27 },
            },
            debuffs = {},
            cast = {},
            channel = {},
        },
        small = {
            buffs = {},
            debuffs = {
                ["Execution Sentence"] = { duration = 8 },
                ["Truth's Wake"] = { duration = 9 },
                ["Final Reckoning"] = { duration = 12 },
            },
            cast = {
                ["Divine Toll"] = { duration = 6, baseCD = 60 },
            },
            channel = {},
        },
    },

    ['Priest'] = {
        big = {
            buffs = {
                ["Power Infusion"] = { duration = 15 },
                ["Voidform"] = { duration = 20 },
                ["Dark Ascension"] = { duration = 20 },
            },
            debuffs = {},
            cast = {},
            channel = {},
        },
        small = {
            buffs = {
                ["Dark Archangel"] = { duration = 8 },
            },
            debuffs = {
                ["Mindgames"] = { duration = 7 },
            },
            cast = {
                ["Psyfiend"] = { duration = 12, baseCD = 45 },
                ["Voidwraith"] = { duration = 15, baseCD = 60 },
            },
            channel = {},
        },
    },

    ['Rogue'] = {
        big = {
            buffs = {
                ["Shadow Blades"] = { duration = 20 },
                ["Flagellation"] = { duration = 12 },
                ["Roll the Bones"] = { duration = 30 / 2 },
                ["Dreadblades"] = { duration = 10 },
            },
            debuffs = {
                ["Deathmark"] = { duration = 16 },
                ["Ghostly Strike"] = { duration = 12 },
                ["Sepsis"] = { duration = 10 },
                ["Kingsbane"] = { duration = 14 },
            },
            cast = {},
            channel = {},
        },
        small = {
            buffs = {
                ["Shadow Dance"] = { duration = 6 },
                ["Symbols of Death"] = { duration = 6 },
                ["Thistle Tea"] = { duration = 6 },
            },
            debuffs = {
                ["Shadowy Duel"] = { duration = 6 },
                ["Smoke Bomb"] = { duration = 5 },
            },
            cast = {
                ["Goremaw's Bite"] = { duration = 6, baseCD = 60 },
                ["Secret Technique"] = { duration = 4, baseCD = 60 },
                ["Cold Blood"] = { duration = 6, baseCD = 60 },
                ["Kidney Shot"] = { duration = 6, baseCD = 30 },
            },
            channel = {},
        },
    },

    ['Shaman'] = {
        big = {
            buffs = {
                ["Ascendance"] = { duration = 15 },
            },
            debuffs = {},
            cast = {
                ["Feral Spirit"] = { duration = 15, baseCD = 180 },
            },
            channel = {},
        },
        small = {
            buffs = {
                ["Doom Winds"] = { duration = 8 },
                ["Heroism"] = { duration = 10 },
                ["Bloodlust"] = { duration = 10 },
            },
            debuffs = {},
            cast = {},
            channel = {},
        },
    },

    ['Warlock'] = {
        big = {
            buffs = {
                ["Dark Soul: Instability"] = { duration = 20 },
                ["Dark Soul: Misery"] = { duration = 20 },
            },
            debuffs = {},
            cast = {
                ["Summon Infernal"] = { duration = 30, baseCD = 120 },
                ["Summon Demonic Tyrant"] = { duration = 15, baseCD = 60 },
                ["Summon Darkglare"] = { duration = 20, baseCD = 120 },
            },
            channel = {},
        },
        small = {
            buffs = {
                ["Amplify Curse"] = { duration = 15 * 2, until_consumed = true },
                ["Malevolence"] = { duration = 20 },
            },
            debuffs = {
                ["Fel Fissure"] = { duration = 6 },
                ["Soul Rip"] = { duration = 8 },
            },
            cast = {
                ["Call Observer"] = { duration = 20, baseCD = 60 },
                ["Fel Obelisk"] = { duration = 15, baseCD = 45 },
            },
            channel = {},
        },
    },

    ['Warrior'] = {
        big = {
            buffs = {
                ["Avatar"] = { duration = 20 },
                ["Recklessness"] = { duration = 12 },
            },
            debuffs = {},
            cast = {},
            channel = {},
        },
        small = {
            buffs = {
                ["Bladestorm"] = { duration = 6 },
            },
            debuffs = {
                ["Warbreaker"] = { duration = 10 },
                ["Thunderous Roar"] = { duration = 8 },
                ["Colossus Smash"] = { duration = 10 },
            },
            cast = {
                ["Demolish"] = { duration = 5, baseCD = 45 },
            },
            channel = {},
        },
    },
}

local function get_duration_threshold(duration, is_friend)
    return duration / 3
end

project.util.check.target.cooldowns = function(target, attacker)
    local total, big, small = 0, 0, 0

    if not attacker or not attacker.class then
        return total, big, small
    end

    local class = attacker.class
    local class_cooldowns = cooldowns[class]

    if not class_cooldowns then
        return total, big, small
    end

    for size, types in pairs(class_cooldowns) do
        for ctype, spells in pairs(types) do
            for spell_name, spell_info in pairs(spells) do
                if ctype == "buffs" then
                    if attacker.buffRemains(spell_name) > get_duration_threshold(spell_info.duration, attacker.friend) and attacker.buffUptime(spell_name) > 0.5 then
                        project.util.debug.alert.cd("CD: " .. size .. " cooldown buff on: " .. tostring(attacker.name) .. " - " .. spell_name)
                        total = total + 1
                        if size == "big" then
                            big = big + 1
                        else
                            small = small + 1
                        end
                    end
                elseif ctype == "debuffs" then
                    if target and target.exists then
                        if target.debuffRemains(spell_name) > get_duration_threshold(spell_info.duration, attacker.friend) and target.debuffUptime(spell_name) > 0.5 then
                            project.util.debug.alert.cd("CD: " .. size .. " cooldown debuff on: " .. tostring(target.name) .. " - " .. spell_name)
                            total = total + 1
                            if size == "big" then
                                big = big + 1
                            else
                                small = small + 1
                            end
                        end
                    end
                elseif ctype == "cast" then
                    if attacker.cooldown(spell_name) > (spell_info.baseCD - get_duration_threshold(spell_info.duration, target.friend)) then
                        project.util.debug.alert.cd("CD: " .. size .. " cooldown cast by: " .. tostring(attacker.name) .. " - " .. spell_name)
                        total = total + 1
                        if size == "big" then
                            big = big + 1
                        else
                            small = small + 1
                        end
                    end
                elseif ctype == "channel" then
                    if attacker.channel == spell_name then
                        project.util.debug.alert.cd("CD: " .. size .. " cooldown channel by: " .. tostring(attacker.name) .. " - " .. spell_name)
                        total = total + 1
                        if size == "big" then
                            big = big + 1
                        else
                            small = small + 1
                        end
                    end
                end
            end
        end
    end

    return total, big, small
end
