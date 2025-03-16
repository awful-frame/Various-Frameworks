local Unlocker, awful, project = ...

local magic_debuffs = {
    -- PVE

    -- Raid
    -- Ovi'nax
    ["Terrorizing Howl"] = -1,
    ["Sticky Web"] = 0,

    -- The Silken Court
    ["Stinging Swarm"] = 0,

    -- Affix
    ["Void Rift"] = -1, -- mass AoE

    -- City of Threads
    ["Ice Sickles"] = 0,
    ["Shadows of Doubt"] = 0,

    -- Ara'Kara
    ["Gossamer Onslaught"] = 0,
    ["Web Wrap"] = 0,

    --Cinderbrew Medery
    ["Bee Venom"] = 0,
    ["Burning Ricochet"] = 0,

    -- The Stonevault
    ["Ground Pound"] = -1, -- mass AoE
    ["Howling Fear"] = -1, -- mass AoE
    ["Seismic Reverberation"] = 0,
    ["Censoring Gear"] = 0,

    -- Siege of Boralus
    ["Putrid Waters"] = 0,
    ["Choking Waters"] = 0,

    -- The Dawnbreaker
    ["Burning Shadows"] = 0, -- applies absorb to entire party
    ["Stygian Seed"] = 0, -- no players should be within 8 yards

    -- Mists of Tirna Scithe
    ["Anima Injection"] = 0,
    ["Soul Split"] = 0,
    ["Bewildering Pollen"] = 0,

    --Necrotic Wake
    ["Rasping Scream"] = -1, -- mass AoE
    ["Frozen Binds"] = 0, -- no players should be within 16 yards

    --stuns
    ["Hammer of Justice"] = 1,
    ["Holy Word: Chastise"] = 1,
    ["Psychic Horror"] = 1,
    ["Shadowfury"] = 1,
    ["Chaos Nova"] = 1,
    ["Snowdrift"] = 1,
    ["Terror of the Skies"] = 1,
    --

    --bcc
    ["Blinding Light"] = 2,
    ["Ring of Frost"] = 2,
    ["Howl of Terror"] = 2,
    ["Seduction"] = 2,
    ["Psychic Scream"] = 2,
    ["Freezing Trap"] = 2,
    ["Sleep Walk"] = 2,
    ["Repentance"] = 2,
    ["Polymorph"] = 2,
    ["Fear"] = 2,
    ["Sigil of Misery"] = 2,
    ["Mortal Coil"] = 2,
    ["Scare Beast"] = 2,
    --

    --silence
    ["Silence"] = 3,
    ["Strangulate"] = 3,
    ["Sphere of Despair"] = 3,
    ["Faerie Swarm"] = 3,

    ["Searing Glare"] = 3,
    ["Oppressing Roar"] = 3,
    ["Mindgames"] = 3,
    --

    --roots
    ["Freeze"] = 4,
    ["Frost Nova"] = 4,
    ["Entangling Roots"] = 4,
    ["Mass Entanglement"] = 4,
    ["Earthgrab"] = 4,
    ["Entrapment"] = 4,
    ["Ice Nova"] = 4,
    ["Landslide"] = 4,
    ["Frostbite"] = 4,
    --

    --damage
    ["Frost Bomb"] = 5,
    ["Explosive Shot"] = 5,
    ["Living Bomb"] = 5,
    ["Ring of Fire"] = 5,
    ["Wake of Ashes"] = 5,
    ["Flame Shock"] = 5,
    ["Denounce"] = 5,

    -- big dots
    --["Vampiric Touch"] = 6,
    --["Unstable Affliction"] = 6,
    ["Haunt"] = 6,
    ["Soul Rot"] = 6,
    --

    -- soft dots
    --["Purge the Wicked"] = 7,
    --["Moonfire"] = 7,
    --

    -- MD only
    ["Cyclone"] = -8,
    ["Freezing Trap"] = -8,

    -- PURGE only
    ["Mind Control"] = -9,
    ["Seduction"] = -9,
}

local binding_shot_casted = false

local function handle_pve_specific(friend, debuff)
    if debuff == "Frozen Binds" then
        local count = awful.fgroup.around(friend, 16, function(f)
            if f.dead then
                return
            end

            return true
        end)

        if count > 0 then
            return false
        end
    end

    if debuff == "Stygian Seed" or debuff == "Sticky Web" then
        local count = awful.fgroup.around(friend, 8, function(f)
            if f.dead then
                return
            end

            return true
        end)

        if count > 0 then
            return false
        end
    end

    if debuff == "Putrid Waters" then
        local count = awful.fgroup.around(friend, 5, function(f)
            if f.dead then
                return
            end

            return true
        end)

        if count > 0 then
            return false
        end
    end

    if debuff == "Stinging Swarm" then
        local count = awful.enemies.around(friend, 4, function(e)
            if e.dead then
                return
            end

            if e.name ~= "Takazj" then
                return
            end

            return true
        end)

        if count == 0 then
            return false
        end
    end

    return true
end

project.util.dispel.magic.friend = function()
    local uptime_threshold = (0.3 + (math.random() * 0.6))

    local friend_to_dispel
    local debuff_to_dispel
    local has_touch_or_aff = false
    local highest_prio = 100

    awful.fgroup.loop(function(friend)
        if friend.dead then
            return
        end

        if friend.dist > project.util.check.player.range() then
            return
        end

        for debuff, priority in pairs(magic_debuffs) do
            local valid = true

            if priority == 4
                    and friend.melee
                    and friend.los
            then
                priority = 3
            end

            if priority == 3
                    and not friend.healer then
                priority = 4
            end

            if priority == 4 and friend.class == "Druid" then
                priority = 5
            end

            if debuff == "Freezing Trap" and not friend.bcc then
                valid = false
            end

            if debuff == "Ring of Frost" and not friend.bcc then
                valid = false
            end

            if debuff == "Snowdrift" and not friend.stunned then
                valid = false
            end

            if not friend.debuff(debuff) then
                valid = false
            end

            if friend.debuffUptime(debuff) < uptime_threshold then
                valid = false
            end

            if priority == 2 then
                local attackers = project.util.friend.attackers.get(friend.guid)
                if not awful.arena then
                    if attackers.t > 1 then
                        valid = false
                    end
                end
            end

            local remains_threshold = 1 + awful.spellCastBuffer + awful.buffer
            if awful.player.casting == "Mass Dispel" then
                remains_threshold = remains_threshold + project.priest.spells.massDispel.castTime
            end

            if friend.debuffRemains(debuff) < remains_threshold then
                valid = false
            end

            if priority > highest_prio then
                valid = false
            end

            if friend_to_dispel then
                if priority == highest_prio then
                    if friend.hp > friend_to_dispel.hp then
                        valid = false
                    end
                end
            end

            if (priority == 0 or priority == -1)
                    and not handle_pve_specific(friend, debuff) then
                valid = false
            end

            if valid then
                if friend.debuff("Vampiric Touch") or friend.debuff("Unstable Affliction") then
                    has_touch_or_aff = true
                end

                friend_to_dispel = friend
                debuff_to_dispel = debuff
                highest_prio = priority
            end
        end
    end)

    if debuff_to_dispel == "Flame Shock" and binding_shot_casted then
        return
    end

    return friend_to_dispel, debuff_to_dispel, highest_prio, has_touch_or_aff
end

awful.onEvent(function(info, event, source, dest)
    if not project.settings.priest_evade_traps then
        return
    end

    if event == "SPELL_CAST_SUCCESS" then
        local spellID, spellName = select(12, unpack(info))
        if source.enemy and spellName == "Binding Shot" then
            binding_shot_casted = true
            C_Timer.After(11, function()
                binding_shot_casted = false
            end)
        end
    end
end)
