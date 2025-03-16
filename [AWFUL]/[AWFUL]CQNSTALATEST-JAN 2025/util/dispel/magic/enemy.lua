local Unlocker, awful, project = ...

-- PvE Buffs to Purge
local pve_buffs = {
    -- The Dawnbreaker
    { id = project.util.id.spell.ABYSSAL_HOWL, priority = -1, mapID = project.util.id.map.DAWNBREAKER }, -- AoE
    { id = project.util.id.spell.SILKEN_SHELL, priority = -1, mapID = project.util.id.map.DAWNBREAKER }, -- AoE
    { id = project.util.id.spell.UMBRAL_BARRIER, priority = 0, mapID = project.util.id.map.DAWNBREAKER },

    -- Mists of Tirna Scithe
    { id = project.util.id.spell.NOURISH_THE_FOREST, priority = -1, mapID = project.util.id.map.MISTS_OF_THIRNA_SCITHE }, -- AoE
    { id = project.util.id.spell.STIMULATE_RESISTANCE, priority = -1, mapID = project.util.id.map.MISTS_OF_THIRNA_SCITHE }, -- AoE
    { id = project.util.id.spell.BRAMBLETHORN_COAT, priority = 0, mapID = project.util.id.map.MISTS_OF_THIRNA_SCITHE },

    -- Necrotic Wake
    { id = project.util.id.spell.DARK_SHROUD_BUFF, priority = 0, mapID = project.util.id.map.NECROTIC_WAKE },

    -- Siege of Boralus
    { id = project.util.id.spell.BOLSTERING_SHOUT, priority = -1, mapID = project.util.id.map.SIEGE_OF_BORALUS }, -- AoE
    { id = project.util.id.spell.WATERTIGHT_SHELL, priority = 0, mapID = project.util.id.map.SIEGE_OF_BORALUS },
}

-- PvP Buffs to Purge
local pvp_buffs = {
    { id = project.util.id.spell.POWER_WORD_SHIELD, priority = 1 },
    { id = project.util.id.spell.ICE_BARRIER, priority = 1, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.PRISMATIC_BARRIER, priority = 1, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.BLAZING_BARRIER, priority = 1, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.LIFEBLOOM, priority = 1 },
    { id = project.util.id.spell.ENVELOPING_MIST, priority = 1 },
    { id = project.util.id.spell.SPHERE_OF_HOPE, priority = 1 },
    { id = project.util.id.spell.ADAPTIVE_SWARM_BUFF, priority = 1 },

    { id = project.util.id.spell.BLESSING_OF_PROTECTION, priority = 2 },
    { id = project.util.id.spell.ALTER_TIME, priority = 2, class = project.util.id.class.MAGE },

    { id = project.util.id.spell.SOUL_OF_THE_FOREST_RESTO, priority = 3, class = project.util.id.class.DRUID },
    { id = project.util.id.spell.POWER_INFUSION, priority = 3 },
    { id = project.util.id.spell.ICE_FORM, priority = 3, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.BLOODLUST, priority = 3 },
    { id = project.util.id.spell.PRIMAL_RAGE, priority = 3 },
    { id = project.util.id.spell.HEROISM, priority = 3 },

    { id = project.util.id.spell.HOLY_WARD, priority = 4, class = project.util.id.class.PRIEST },
    { id = project.util.id.spell.NULLIFYING_SHROUD, priority = 4, class = project.util.id.class.EVOKER },

    { id = project.util.id.spell.THORNS, priority = 5 },
    { id = project.util.id.spell.BLISTERING_SCALES, priority = 5, class = project.util.id.class.EVOKER },
    { id = project.util.id.spell.BLESSING_OF_FREEDOM, priority = 5 },

    { id = project.util.id.spell.DIVINE_FAVOR, priority = 6, class = project.util.id.class.PALADIN },
    { id = project.util.id.spell.SPIRITWALKERS_GRACE, priority = 6, class = project.util.id.class.SHAMAN },
    { id = project.util.id.spell.INNERVATE, priority = 6, class = project.util.id.class.DRUID },

    { id = project.util.id.spell.ARCANE_INTELLECT, priority = 7 },
    { id = project.util.id.spell.POWER_WORD_FORTITUDE, priority = 7 },
    { id = project.util.id.spell.MARK_OF_THE_WILD, priority = 7 },
    { id = project.util.id.spell.SKYFURY, priority = 7 },

    { id = project.util.id.spell.DIVINE_SHIELD, priority = -8, class = project.util.id.class.PALADIN },
    { id = project.util.id.spell.ICE_BLOCK, priority = -8, class = project.util.id.class.MAGE },
    { id = project.util.id.spell.TIME_STOP, priority = -8 },
    { id = project.util.id.spell.BLESSING_OF_SPELLWARDING, priority = -8 },
}

table.sort(pve_buffs, function(a, b)
    return a.priority < b.priority
end)

table.sort(pvp_buffs, function(a, b)
    return a.priority < b.priority
end)

local purge_result_cache
local last_purge_cache_time = 0
local PURGE_CACHE_DURATION = 0.2

local function get_class_relevant_buffs(relevant_buffs, class_id, immune_magic_effects)
    local class_relevant_buffs = {}

    for _, buff in ipairs(relevant_buffs) do
        if immune_magic_effects then
            if buff.priority == -8
                    and (not buff.class or buff.class == class_id) then
                table.insert(class_relevant_buffs, buff)
            end
        else
            if not buff.class or buff.class == class_id then
                table.insert(class_relevant_buffs, buff)
            end
        end
    end

    return class_relevant_buffs
end

project.util.dispel.magic.enemy = function(type)
    if awful.time - last_purge_cache_time < PURGE_CACHE_DURATION then
        return purge_result_cache.enemy_to_purge, purge_result_cache.buff_to_purge, purge_result_cache.highest_priority
    end

    local uptime_threshold
    local enemy_to_purge, buff_to_purge, highest_priority = nil, nil, 100

    local relevant_buffs = {}

    if type == "pve" then
        uptime_threshold = 0.1

        for _, buff in ipairs(pve_buffs) do
            if IsPlayerSpell(project.util.id.spell.MASS_DISPEL)
                    and (not buff.mapID or buff.mapID == awful.mapID) then
                table.insert(relevant_buffs, buff)
            end
        end
    end

    if type == "pvp" then
        uptime_threshold = (0.2 + (math.random() * 0.4))

        for _, buff in ipairs(pvp_buffs) do
            if (buff.priority == -8 and IsPlayerSpell(project.util.id.spell.MASS_DISPEL) and project.priest.spells.massDispel.cd < awful.gcd)
                    or (IsPlayerSpell(project.util.id.spell.DISPEL_MAGIC) and ((buff.priority == 1 and project.util.enemy.danger) or buff.priority > 1)) then
                table.insert(relevant_buffs, buff)
            end
        end
    end

    if not relevant_buffs or next(relevant_buffs) == nil then
        return
    end

    awful.enemies.loop(function(enemy)
        if enemy.dead
                or enemy.dist > project.util.check.player.range()
                or not enemy.los then
            return
        end

        local filtered_buffs = relevant_buffs
        if type == "pvp" then
            if enemy.buff(project.util.id.spell.GROUNDING_TOTEM_BUFF) then
                return
            end

            if enemy.class3 == project.util.id.class.WARRIOR
                    and enemy.buff(project.util.id.spell.SPELL_REFLECTION) then
                return
            end

            if enemy.class3 == project.util.id.class.WARLOCK
                    and enemy.buff(project.util.id.spell.NETHER_WARD) then
                return
            end

            filtered_buffs = get_class_relevant_buffs(relevant_buffs, enemy.class3, enemy.immuneMagicEffects)
        end

        for _, buff in ipairs(filtered_buffs) do
            if buff.priority > highest_priority then
                return
            end

            if buff.priority == highest_priority
                    and enemy.hp > enemy_to_purge.hp then
                return
            end

            local buff_name = enemy.buff(buff.id)
            if buff_name and enemy.buffUptime(buff.id) >= uptime_threshold then
                local valid = true

                if buff.condition and not buff.condition(enemy) then
                    valid = false
                end

                local remains_threshold = 2 + awful.buffer
                if awful.player.castID == project.util.id.spell.MASS_DISPEL then
                    remains_threshold = remains_threshold + project.priest.spells.massDispel.castTime
                end

                if enemy.buffRemains(buff.id) < remains_threshold then
                    valid = false
                end

                if valid then
                    if not enemy_to_purge or enemy.hp < enemy_to_purge.hp then
                        enemy_to_purge = enemy
                        buff_to_purge = buff_name
                        highest_priority = buff.priority
                    end

                    return
                end
            end
        end
    end)

    if enemy_to_purge and highest_priority < 7 then
        local info = "Enemy: " .. enemy_to_purge.name .. ". Buff: " .. buff_to_purge .. ". Prio: " .. highest_priority
        project.util.debug.alert.dispel("[PURGE] Detected purge buff: " .. info, project.util.id.spell.DISPEL_MAGIC)
    end

    purge_result_cache = {
        enemy_to_purge = enemy_to_purge,
        buff_to_purge = buff_to_purge,
        highest_priority = highest_priority,
    }
    last_purge_cache_time = awful.time

    return enemy_to_purge, buff_to_purge, highest_priority
end
