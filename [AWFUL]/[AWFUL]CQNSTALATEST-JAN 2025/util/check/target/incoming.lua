local Unlocker, awful, project = ...

local incoming_cc_debuffs = {
    project.util.id.spell.SCATTER_SHOT,
    project.util.id.spell.INTIMIDATION,
    project.util.id.spell.BINDING_SHOT_STUN_DEBUFF,
    project.util.id.spell.PSYCHIC_HORROR,
}

local cc_cast_spells = {
    [project.util.id.spell.POLYMORPH_1] = true,
    [project.util.id.spell.POLYMORPH_2] = true,
    [project.util.id.spell.POLYMORPH_3] = true,
    [project.util.id.spell.POLYMORPH_4] = true,
    [project.util.id.spell.POLYMORPH_5] = true,
    [project.util.id.spell.POLYMORPH_6] = true,
    [project.util.id.spell.POLYMORPH_7] = true,
    [project.util.id.spell.POLYMORPH_8] = true,
    [project.util.id.spell.POLYMORPH_9] = true,
    [project.util.id.spell.POLYMORPH_10] = true,
    [project.util.id.spell.POLYMORPH_11] = true,
    [project.util.id.spell.POLYMORPH_12] = true,
    [project.util.id.spell.POLYMORPH_13] = true,
    [project.util.id.spell.POLYMORPH_14] = true,
    [project.util.id.spell.POLYMORPH_15] = true,
    [project.util.id.spell.POLYMORPH_16] = true,
    [project.util.id.spell.CYCLONE] = true,
    [project.util.id.spell.MIND_CONTROL] = true,
    [project.util.id.spell.HEX_1] = true,
    [project.util.id.spell.HEX_2] = true,
    [project.util.id.spell.HEX_3] = true,
    [project.util.id.spell.HEX_4] = true,
    [project.util.id.spell.HEX_5] = true,
    [project.util.id.spell.HEX_6] = true,
    [project.util.id.spell.HEX_7] = true,
    [project.util.id.spell.HEX_8] = true,
    [project.util.id.spell.HEX_9] = true,
    [project.util.id.spell.REPENTANCE] = true,
    [project.util.id.spell.SLEEP_WALK] = true,
    [project.util.id.spell.FEAR] = true,
    [project.util.id.spell.SEDUCTION] = true,
}

local incoming_cache = {}
local INCOMING_CACHE_DURATION = 0.2
local CACHE_CLEANUP_INTERVAL = 5
local last_cleanup_time = 0

local function cleanup_cache()
    local current_time = awful.time
    if (current_time - last_cleanup_time) < CACHE_CLEANUP_INTERVAL then
        return
    end

    for key, entry in pairs(incoming_cache) do
        if (current_time - entry.time) >= INCOMING_CACHE_DURATION then
            incoming_cache[key] = nil
        end
    end

    last_cleanup_time = current_time
end

project.util.check.target.incoming = function(target)
    if not target then
        return
    end

    cleanup_cache()

    local cache_key = target.guid
    local cache_entry = incoming_cache[cache_key]

    if cache_entry and (awful.time - cache_entry.time) < INCOMING_CACHE_DURATION then
        return cache_entry.incoming_cc, cache_entry.incoming_cast, cache_entry.incoming_remaining
    end

    if target.isHealer and target.debuffFrom(incoming_cc_debuffs) then
        incoming_cache[cache_key] = {
            incoming_cc = true,
            incoming_cast = false,
            incoming_remaining = 0,
            time = awful.time,
        }
        return true, false, 0
    end

    if awful.arena
            and awful.player.cc
            and (project.util.enemy.existing_classes[project.util.id.class.PRIEST]
            or project.util.enemy.existing_classes[project.util.id.class.HUNTER]) then

        local count = awful.enemies.around(awful.player, 10, function(enemy)
            if enemy.class3 == project.util.id.class.PRIEST and enemy.cooldown(project.util.id.spell.PSYCHIC_SCREAM) < awful.gcd then
                return true
            end

            if enemy.class3 == project.util.id.class.HUNTER and enemy.cooldown(project.util.id.spell.FREEZING_TRAP) < awful.gcd then
                return true
            end

            return false
        end)

        if count > 0 then
            incoming_cache[cache_key] = {
                incoming_cc = true,
                incoming_cast = false,
                incoming_remaining = 0,
                time = awful.time,
            }

            return true, false, 0
        end
    end

    local list = awful.fgroup
    if target.friend then
        list = awful.enemies
    end

    local incoming_cc = false
    local incoming_cast = false
    local incoming_remaining = math.huge

    list.loop(function(unit)
        if not unit.player then
            return
        end

        if not unit.castID and not unit.channelID then
            return
        end

        if not unit.castTarget then
            return
        end

        if unit.castTarget.guid ~= target.guid then
            return
        end

        incoming_cast = true

        if cc_cast_spells[unit.castID] then
            incoming_cc = true
            if unit.castRemains < incoming_remaining then
                incoming_remaining = unit.castRemains
            end
        end
    end)

    incoming_cache[cache_key] = {
        incoming_cc = incoming_cc,
        incoming_cast = incoming_cast,
        incoming_remaining = incoming_remaining,
        time = awful.time,
    }

    return incoming_cc, incoming_cast, incoming_remaining
end
