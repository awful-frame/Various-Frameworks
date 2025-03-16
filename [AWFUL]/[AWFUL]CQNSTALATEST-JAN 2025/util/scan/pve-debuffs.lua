local Unlocker, awful, project = ...

project.util.pve_debuffs.target = nil
project.util.pve_debuffs.debuff = nil
project.util.pve_debuffs.prio = nil
project.util.pve_debuffs.detected = false

-- prio 2 == always (pre-damage)
local pve_debuffs = {
    -- RAID
    [project.util.id.map.NERUBAR_PALACE] = {
        [project.util.id.spell.QUEENSBANE] = { prio = 0 },
    },
    [project.util.id.map.ARA_KARA] = {
        [project.util.id.spell.REVOLTING_VOLLEY] = { prio = 1 },
        [project.util.id.spell.VENOM_VOLLEY_1] = { prio = 1 },
        [project.util.id.spell.VENOM_VOLLEY_2] = { prio = 1 },
    },
    [project.util.id.map.CITY_OF_THREADS] = {
        [project.util.id.spell.VENOMOUS_SPRAY_BUFF] = { prio = 1 },
        [project.util.id.spell.VENOMOUS_SPRAY] = { prio = 1 },
        [project.util.id.spell.SHADOWS_OF_DOUBT_TRASH_BUFF] = { prio = 0 },
        [project.util.id.spell.SHADOWS_OF_DOUBT_TRASH] = { prio = 0 },
        [project.util.id.spell.SHADOWS_OF_DOUBT_BOSS_BUFF] = { prio = 0 },
        [project.util.id.spell.SHADOWS_OF_DOUBT_BOSS] = { prio = 0 },
    },
    [project.util.id.map.DAWNBREAKER] = {
        [project.util.id.spell.STYGIAN_SEED] = { prio = 0 },
        [project.util.id.spell.BURSTING_COCOON] = { prio = 2 },
        [project.util.id.spell.TORMENTING_RAY] = { prio = 0 },
        [project.util.id.spell.TORMENTING_ERUPTION_1] = { prio = 2 },
        [project.util.id.spell.TORMENTING_ERUPTION_2] = { prio = 2 },
        [project.util.id.spell.TORMENTING_ERUPTION_3] = { prio = 2 },
        [project.util.id.spell.DARK_SCARS] = { prio = 1 },
        [project.util.id.spell.DARK_SCARS_TRASH] = { prio = 0 },
        [project.util.id.spell.ABYSSAL_BLAST] = { prio = 2 },
    },
    [project.util.id.map.STONEVAULT] = {
        [project.util.id.spell.VOID_INFECTION] = { prio = 0 },
    },
    [project.util.id.map.NECROTIC_WAKE] = {
        [project.util.id.spell.GORESPLATTER_NW] = { prio = 1 },
        [project.util.id.spell.HEAVING_RETCH] = { prio = 1 },
        [project.util.id.spell.FROZEN_BINDS_1] = { prio = 1 },
        [project.util.id.spell.FROZEN_BINDS_2] = { prio = 1 },
        [project.util.id.spell.STITCHNEEDLE] = { prio = 1 },
    },
    [project.util.id.map.SIEGE_OF_BORALUS] = {
        [project.util.id.spell.ROTTING_WOUNDS] = { prio = 1 },
        [project.util.id.spell.AZERITE_CHARGE_TARGETED_DEBUFF] = { prio = 2 }, -- pre damage
        [project.util.id.spell.AZERITE_CHARGE_DEBUFF] = { prio = 1 },
        [project.util.id.spell.AZERITE_CHARGE] = { prio = 1 },
    },
    [project.util.id.map.GRIM_BATOL] = {
        [project.util.id.spell.ENVELOPING_SHADOWFLAME] = { prio = 1 },
    },
}

local last_pve_debuffs_cache_time = 0
local PVE_DEBUFFS_CACHE_DURATION = 0.5

project.util.scan.pve_debuffs = function(type)
    if type == "pvp" then
        return
    end

    if awful.time - last_pve_debuffs_cache_time < PVE_DEBUFFS_CACHE_DURATION then
        return
    end

    local threshold = 0.1

    local friend_with_debuff
    local debuff_pve
    local debuff_priority = 101

    local relevant_debuffs = pve_debuffs[awful.mapID]

    if not relevant_debuffs or next(relevant_debuffs) == nil then
        return
    end

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        for debuff_id, debuff_info in pairs(relevant_debuffs) do
            local valid = true

            if debuff_info.prio > debuff_priority then
                valid = false
            end

            local debuff_name
            if valid then
                debuff_name = friend.debuff(debuff_id)

                if not debuff_name then
                    valid = false

                end

                if friend.debuffUptime(debuff_id) < threshold then
                    valid = false
                end

                if friend.debuffRemains(debuff_id) < project.util.thresholds.buff() + 3 then
                    valid = false
                end
            end

            if friend_with_debuff then
                if debuff_info.prio == debuff_priority then
                    if friend.hp > friend_with_debuff.hp then
                        valid = false
                    end
                end
            end

            if valid then
                friend_with_debuff = friend
                debuff_pve = debuff_name
                debuff_priority = debuff_info.prio
            end
        end
    end)

    if not friend_with_debuff then
        project.util.pve_debuffs.target = nil
        project.util.pve_debuffs.debuff = nil
        project.util.pve_debuffs.prio = 101
    else
        project.util.pve_debuffs.target = friend_with_debuff
        project.util.pve_debuffs.debuff = debuff_pve
        project.util.pve_debuffs.prio = debuff_priority
    end

    last_pve_debuffs_cache_time = awful.time

    if friend_with_debuff then
        project.util.debug.alert.pve("[PvE DEBUFF] Detected PvE debuff: " .. project.util.pve_debuffs.debuff .. " on " .. project.util.pve_debuffs.target.name .. " with prio " .. project.util.pve_debuffs.prio)
    end
end