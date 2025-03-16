local Unlocker, awful, project = ...

local function no_allies_within(friend, range)
    local count = awful.fgroup.around(friend, range, function(f)
        if f.dead then
            return
        end
        return true
    end)
    return count == 0
end

-- PvE Debuffs
local instance_pve_debuffs = {
    [project.util.id.instance.PARTY] = {
        { id = project.util.id.spell.VOID_RIFT, priority = -1 },
    }
}

local pve_debuffs = {
    -- RAID
    [project.util.id.map.NERUBAR_PALACE] = {
        { id = project.util.id.spell.TERRORIZING_HOWL, priority = -1 },
        { id = project.util.id.spell.STICKY_WEB, priority = 0, condition = function(friend)
            return no_allies_within(friend, 8)
        end },
        { id = project.util.id.spell.STINGING_SWARM, priority = 0, condition = function(friend)
            local count = awful.enemies.around(friend, 4, function(e)
                if e.dead then
                    return
                end
                if e.name ~= project.util.id.npc.TAKAZJ then
                    return
                end
                return true
            end)
            return count > 0
        end },
    },
    -- DUNGEONS
    [project.util.id.map.CITY_OF_THREADS] = {
        { id = project.util.id.spell.ICE_SICKLES_BUFF, priority = -1 },
        { id = project.util.id.spell.SHADOWS_OF_DOUBT_TRASH_BUFF, priority = 0, condition = function(friend)
            return no_allies_within(friend, 5)
        end },
        { id = project.util.id.spell.SHADOWS_OF_DOUBT_BOSS_BUFF, priority = 0, condition = function(friend)
            return no_allies_within(friend, 5)
        end },
    },
    [project.util.id.map.ARA_KARA] = {
        { id = project.util.id.spell.GOSSAMER_ONSLAUGHT_DEBUFF, priority = 0 },
    },
    [project.util.id.map.CINDERBREW_MEADERY] = {
        { id = project.util.id.spell.BEE_VENOM, priority = 0 },
        { id = project.util.id.spell.BURNING_RICOCHET, priority = 0 },
    },
    [project.util.id.map.STONEVAULT] = {
        { id = project.util.id.spell.GROUND_POUND, priority = -1 },
        { id = project.util.id.spell.HOWLING_FEAR, priority = -1 },
        { id = project.util.id.spell.SEISMIC_REVERBERATION, priority = 0, condition = function(friend)
            return project.util.enemy.best_target.unit
                    and project.util.enemy.best_target.unit.castID == project.util.id.spell.SEISMIC_SMASH
        end },
        { id = project.util.id.spell.CENSORING_GEAR, priority = 0 },
    },
    [project.util.id.map.SIEGE_OF_BORALUS] = {
        { id = project.util.id.spell.PUTRID_WATERS, priority = 0, condition = function(friend)
            return no_allies_within(friend, 5)
        end },
        { id = project.util.id.spell.CHOKING_WATERS, priority = 0 },
    },
    [project.util.id.map.DAWNBREAKER] = {
        { id = project.util.id.spell.BURNING_SHADOWS_DEBUFF, priority = 0 },
        { id = project.util.id.spell.STYGIAN_SEED, priority = 0, condition = function(friend)
            return no_allies_within(friend, 8)
        end },
    },
    [project.util.id.map.MISTS_OF_THIRNA_SCITHE] = {
        { id = project.util.id.spell.ANIMA_INJECTION, priority = 0 },
        { id = project.util.id.spell.SOUL_SPLIT, priority = 0 },
        { id = project.util.id.spell.BEWILDERING_POLLEN, priority = 0 },
    },
    [project.util.id.map.NECROTIC_WAKE] = {
        { id = project.util.id.spell.RASPING_SCREAM, priority = -1 },
        { id = project.util.id.spell.CLINGING_DARKNESS, priority = 0 },
        { id = project.util.id.spell.FROZEN_BINDS_1, priority = 0, condition = function(friend)
            return no_allies_within(friend, 16)
        end },
        { id = project.util.id.spell.FROZEN_BINDS_2, priority = -1 },
    },
}

-- PvP Debuffs
local pvp_debuffs = {
    -- STUNS
    { id = project.util.id.spell.HAMMER_OF_JUSTICE, priority = 1, class = project.util.id.class.PALADIN },
    { id = project.util.id.spell.BINDING_SHOT_DEBUFF, priority = 1, class = project.util.id.class.HUNTER },
    { id = project.util.id.spell.HOLY_WORD_CHASTISE, priority = 1, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.PSYCHIC_HORROR, priority = 1, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.SHADOWFURY, priority = 1, class = project.util.id.class.WARLOCK },
    { id = project.util.id.spell.CHAOS_NOVA, priority = 1, class = project.util.id.class.DEMON_HUNTER },
    { id = project.util.id.spell.SNOWDRIFT_STUN, priority = 1, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.TERROR_OF_THE_SKIES, priority = 1, class = project.util.id.class.EVOKER },
    { id = project.util.id.spell.ABSOLUTE_ZERO, priority = 1, class = project.util.id.class.DEATH_KNIGHT },
    { id = project.util.id.spell.DEATH_OF_WINTER_STUN, priority = 1, class = project.util.id.class.DEATH_KNIGHT },

    -- CC
    { id = project.util.id.spell.BLINDING_LIGHT_DEBUFF, priority = 2, class = project.util.id.class.PALADIN },
    { id = project.util.id.spell.RING_OF_FROST_DEBUFF, priority = 2, class = project.util.id.class.MAGE, condition = function(friend)
        return friend.bcc == project.util.id.spell.RING_OF_FROST_DEBUFF
    end },
    { id = project.util.id.spell.HOWL_OF_TERROR, priority = 2, class = project.util.id.class.WARLOCK },
    { id = project.util.id.spell.SEDUCTION, priority = 2, class = project.util.id.class.WARLOCK },
    { id = project.util.id.spell.PSYCHIC_SCREAM, priority = 2, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.FREEZING_TRAP_DEBUFF, priority = 2, class = project.util.id.class.HUNTER },
    { id = project.util.id.spell.SLEEP_WALK, priority = 2, class = project.util.id.class.EVOKER },
    { id = project.util.id.spell.REPENTANCE, priority = 2, class = project.util.id.class.PALADIN },
    { id = project.util.id.spell.POLYMORPH_1, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_2, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_3, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_4, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_5, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_6, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_7, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_8, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_9, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_10, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_11, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_12, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_13, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_14, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_15, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.POLYMORPH_16, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.DRAGONS_BREATH, priority = 2, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.FEAR, priority = 2, class = project.util.id.class.WARLOCK },
    { id = project.util.id.spell.SIGIL_OF_MISERY, priority = 2, class = project.util.id.class.DEMON_HUNTER },
    { id = project.util.id.spell.MORTAL_COIL, priority = 2, class = project.util.id.class.WARLOCK },
    { id = project.util.id.spell.SCARE_BEAST, priority = 2, class = project.util.id.class.HUNTER },
    { id = project.util.id.spell.SONG_OF_CHI_JI, priority = 2, class = project.util.id.class.MONK },

    -- SILENCE
    { id = project.util.id.spell.SILENCE, priority = 3, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.STRANGULATE, priority = 3, class = project.util.id.class.DEATH_KNIGHT },
    { id = project.util.id.spell.SPHERE_OF_DESPAIR, priority = 3, class = project.util.id.class.MONK },
    { id = project.util.id.spell.FAERIE_SWARM, priority = 3, class = project.util.id.class.DRUID },
    { id = project.util.id.spell.SEARING_GLARE_DEBUFF, priority = 3, class = project.util.id.class.PALADIN },
    { id = project.util.id.spell.MINDGAMES, priority = 3, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.OPPRESSING_ROAR, priority = 3, class = project.util.id.class.HUNTER },
    { id = project.util.id.spell.DENOUNCE, priority = 3, class = project.util.id.class.PALADIN },
    { id = project.util.id.spell.ADAPTIVE_SWARM_DEBUFF, priority = 3, class = project.util.id.class.DRUID },

    -- ROOT
    { id = project.util.id.spell.FREEZE, priority = 4, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.DEATHCHILL_1, priority = 4, class = project.util.id.class.DEATH_KNIGHT },
    { id = project.util.id.spell.DEATHCHILL_2, priority = 4, class = project.util.id.class.DEATH_KNIGHT },
    { id = project.util.id.spell.FROST_NOVA, priority = 4, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.ENTANGLING_ROOTS, priority = 4, class = project.util.id.class.DRUID },
    { id = project.util.id.spell.MASS_ENTANGLEMENT, priority = 4, class = project.util.id.class.DRUID },
    { id = project.util.id.spell.EARTHGRAB, priority = 4, class = project.util.id.class.SHAMAN },
    { id = project.util.id.spell.ENTRAPMENT, priority = 4, class = project.util.id.class.HUNTER },
    { id = project.util.id.spell.ICE_NOVA, priority = 4, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.LANDSLIDE, priority = 4, class = project.util.id.class.EVOKER },
    { id = project.util.id.spell.FROSTBITE, priority = 4, class = project.util.id.class.MAGE },

    -- DMG
    { id = project.util.id.spell.FROST_BOMB, priority = 5, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.EXPLOSIVE_SHOT, priority = 5, class = project.util.id.class.HUNTER },
    { id = project.util.id.spell.LIVING_BOMB, priority = 5, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.RING_OF_FIRE_1, priority = 5, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.RING_OF_FIRE_2, priority = 5, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.TRUTHS_WAKE, priority = 5, class = project.util.id.class.PALADIN },

    -- BIG DOTS
    { id = project.util.id.spell.VAMPIRIC_TOUCH, priority = 6, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.HAUNT, priority = 6, class = project.util.id.class.WARLOCK },
    { id = project.util.id.spell.SOUL_ROT, priority = 6, class = project.util.id.class.SOUL_ROT },

    -- MD
    { id = project.util.id.spell.CYCLONE, priority = -8, class = project.util.id.class.DRUID },

    -- PURGE
    { id = project.util.id.spell.MIND_CONTROL, priority = -9, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.SEDUCTION, priority = -9, class = project.util.id.class.WARLOCK },
}

table.sort(pve_debuffs, function(a, b)
    return a.priority < b.priority
end)

table.sort(pvp_debuffs, function(a, b)
    return a.priority < b.priority
end)

local function filter_relevant_debuffs(type)
    local debuffs = (type == "pvp") and pvp_debuffs or pve_debuffs

    if type == "pve" then
        local relevant_pve_debuffs = pve_debuffs[awful.mapID] or {}
        local relevant_instance_pve_debuffs = instance_pve_debuffs[awful.instanceType2] or {}

        for _, instance_pve_debuff in ipairs(relevant_instance_pve_debuffs) do
            table.insert(relevant_pve_debuffs, instance_pve_debuff)
        end

        if #relevant_pve_debuffs == 0 then
            return
        end

        return relevant_pve_debuffs
    end

    if type == "pvp" then
        local relevant_debuffs = {}

        for _, debuff in ipairs(debuffs) do
            if not debuff.class or project.util.enemy.existing_classes[debuff.class] then
                if debuff.priority == -8 then
                    if IsPlayerSpell(project.util.id.spell.MASS_DISPEL) and project.priest.spells.massDispel.cd < awful.gcd then
                        table.insert(relevant_debuffs, debuff)
                    end
                elseif debuff.priority == -9 then
                    if debuff.priority == -9 and IsPlayerSpell(project.util.id.spell.DISPEL_MAGIC) then
                        table.insert(relevant_debuffs, debuff)
                    end
                else
                    table.insert(relevant_debuffs, debuff)
                end
            end
        end
        return relevant_debuffs
    end
end

local dispel_result_cache
local last_dispel_cache_time = 0
local DISPEL_CACHE_DURATION = 0.2

project.util.dispel.magic.friend = function(type)
    if awful.time - last_dispel_cache_time < DISPEL_CACHE_DURATION then
        return dispel_result_cache.friend_to_dispel, dispel_result_cache.debuff_to_dispel, dispel_result_cache.debuff_priority, dispel_result_cache.friend_to_dispel_punished
    end

    local uptime_threshold = (0.2 + (math.random() * 0.4))
    local friend_to_dispel
    local debuff_to_dispel
    local debuff_priority = 101
    local friend_to_dispel_punished = false

    local relevant_debuffs = filter_relevant_debuffs(type)

    if not relevant_debuffs or next(relevant_debuffs) == nil then
        return
    end

    awful.fgroup.loop(function(friend)
        if friend.dead
                or friend.dist > project.util.check.player.range() then
            return
        end

        if not awful.arena
                and not friend.los then
            return
        end

        local temp_relevant_debuffs = relevant_debuffs
        if friend.immuneHealing then
            if type == "pvp" then
                temp_relevant_debuffs = { { id = project.util.id.spell.CYCLONE, priority = -8, class = project.util.id.class.DRUID } }
            else
                return
            end
        end

        local punished = friend.debuffFrom({ project.util.id.spell.UNSTABLE_AFFLICTION, project.util.id.spell.VAMPIRIC_TOUCH })
                and true or false

        for _, debuff in ipairs(temp_relevant_debuffs) do
            local priority = punished and 6 or debuff.priority

            if priority > debuff_priority then
                return
            end

            if priority == debuff_priority then
                if punished and not friend_to_dispel_punished then
                    return
                end

                if not punished and not friend_to_dispel_punished and friend.hp > friend_to_dispel.hp then
                    return
                end

                if punished and friend_to_dispel_punished and friend.hp > friend_to_dispel.hp then
                    return
                end
            end

            local debuff_name = friend.debuff(debuff.id)
            if debuff_name and friend.debuffUptime(debuff.id) >= uptime_threshold then
                local valid = true

                if debuff.condition and not debuff.condition(friend) then
                    valid = false
                end

                if debuff.priority == 2 and project.util.check.target.attackers(friend).total > 1 then
                    valid = false
                end

                if not valid then
                    -- Skip to next debuff
                else
                    if priority == 4 and friend.melee and friend.los then
                        priority = 3
                    end

                    if priority == 3 and friend.healer then
                        priority = 2.5
                    end

                    if priority == 4 and friend.class3 == project.util.id.class.DRUID then
                        priority = 5
                    end

                    local remains_threshold = 1 + awful.buffer
                    if awful.player.castID == project.util.id.spell.MASS_DISPEL then
                        remains_threshold = remains_threshold + project.priest.spells.massDispel.castTime
                    end

                    if priority > 3 then
                        remains_threshold = remains_threshold + 1
                    end

                    if priority == -8 and not awful.player.castID then
                        remains_threshold = remains_threshold + project.priest.spells.massDispel.castTime
                    end

                    if friend.debuffRemains(debuff.id) < remains_threshold then
                        valid = false
                    end

                    if valid then
                        friend_to_dispel = friend
                        debuff_to_dispel = debuff_name
                        debuff_priority = priority
                        friend_to_dispel_punished = punished

                        return
                    end
                end
            end
        end
    end)

    if friend_to_dispel then
        local info = "Friend: " .. friend_to_dispel.name .. ". Debuff: " .. debuff_to_dispel .. ". Prio: " .. debuff_priority .. ". Punished: " .. tostring(friend_to_dispel_punished)
        project.util.debug.alert.dispel("[DISPEL] Detected dispel buff: " .. info, project.util.id.spell.PURIFY)
    end

    dispel_result_cache = {
        friend_to_dispel = friend_to_dispel,
        debuff_to_dispel = debuff_to_dispel,
        debuff_priority = debuff_priority,
        friend_to_dispel_punished = friend_to_dispel_punished,
    }
    last_dispel_cache_time = awful.time

    return friend_to_dispel, debuff_to_dispel, debuff_priority, friend_to_dispel_punished
end
