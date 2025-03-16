local Unlocker, awful, project = ...

local interrupts = {
    [project.util.id.spec.BLOOD] = { range = 15, id = project.util.id.spell.MIND_FREEZE },
    [project.util.id.spec.FROST_DK] = { range = 15, id = project.util.id.spell.MIND_FREEZE },
    [project.util.id.spec.UNHOLY] = { range = 15, id = project.util.id.spell.MIND_FREEZE },

    [project.util.id.spec.HAVOC] = { range = 5, id = project.util.id.spell.DISRUPT },
    [project.util.id.spec.VENGEANCE] = { range = 5, id = project.util.id.spell.DISRUPT },

    [project.util.id.spec.BALANCE] = nil,
    [project.util.id.spec.FERAL] = { range = 13, id = project.util.id.spell.SKULL_BASH },
    [project.util.id.spec.GUARDIAN] = { range = 13, id = project.util.id.spell.SKULL_BASH },
    [project.util.id.spec.RESTORATION_DRUID] = nil,

    [project.util.id.spec.DEVASTATION] = { range = 25, id = project.util.id.spell.QUELL },
    [project.util.id.spec.PRESERVATION] = { range = 25, id = project.util.id.spell.QUELL },
    [project.util.id.spec.AUGMENTATION] = { range = 25, id = project.util.id.spell.QUELL },

    [project.util.id.spec.BEAST_MASTERY] = { range = 40, id = project.util.id.spell.COUNTER_SHOT },
    [project.util.id.spec.MARKSMANSHIP] = { range = 40, id = project.util.id.spell.COUNTER_SHOT },
    [project.util.id.spec.SURVIVAL] = { range = 5, id = project.util.id.spell.MUZZLE },

    [project.util.id.spec.ARCANE] = { range = 40, id = project.util.id.spell.COUNTERSPELL },
    [project.util.id.spec.FIRE] = { range = 40, id = project.util.id.spell.COUNTERSPELL },
    [project.util.id.spec.FROST_MAGE] = { range = 40, id = project.util.id.spell.COUNTERSPELL },

    [project.util.id.spec.BREWMASTER] = { range = 5, id = project.util.id.spell.SPEAR_HAND_STRIKE },
    [project.util.id.spec.MISTWEAVER] = { range = 5, id = project.util.id.spell.SPEAR_HAND_STRIKE },
    [project.util.id.spec.WINDWALKER] = { range = 5, id = project.util.id.spell.SPEAR_HAND_STRIKE },

    [project.util.id.spec.HOLY_PALADIN] = { range = 5, id = project.util.id.spell.REBUKE },
    [project.util.id.spec.PROTECTION_PALADIN] = { range = 5, id = project.util.id.spell.REBUKE },
    [project.util.id.spec.RETRIBUTION] = { range = 5, id = project.util.id.spell.REBUKE },

    [project.util.id.spec.ASSASSINATION] = { range = 5, id = project.util.id.spell.KICK },
    [project.util.id.spec.OUTLAW] = { range = 5, id = project.util.id.spell.KICK },
    [project.util.id.spec.SUBTLETY] = { range = 5, id = project.util.id.spell.KICK },

    [project.util.id.spec.ELEMENTAL] = { range = 30, id = project.util.id.spell.WIND_SHEAR },
    [project.util.id.spec.ENHANCEMENT] = { range = 30, id = project.util.id.spell.WIND_SHEAR },
    [project.util.id.spec.RESTORATION_SHAMAN] = { range = 30, id = project.util.id.spell.WIND_SHEAR },

    [project.util.id.spec.AFFLICTION] = { range = 40, id = project.util.id.spell.SPELL_LOCK },
    [project.util.id.spec.DEMONOLOGY] = { range = 40, id = project.util.id.spell.SPELL_LOCK },
    [project.util.id.spec.DESTRUCTION] = { range = 40, id = project.util.id.spell.SPELL_LOCK },

    [project.util.id.spec.ARMS] = { range = 5, id = project.util.id.spell.PUMMEL },
    [project.util.id.spec.FURY] = { range = 5, id = project.util.id.spell.PUMMEL },
    [project.util.id.spec.PROTECTION_WARRIOR] = { range = 5, id = project.util.id.spell.PUMMEL },
}

local interrupt_result_cache
local last_cache_time = 0
local CACHE_DURATION = 0.2

project.util.check.enemy.interrupt = function()
    if project.util.check.scenario.type() == "pve" then
        return
    end

    if awful.time - last_cache_time < CACHE_DURATION then
        return interrupt_result_cache
    end

    if awful.player.buff(project.util.id.spell.PRECOGNITION) then
        return
    end

    local result = awful.enemies.find(function(enemy)
        if not enemy
                or enemy.dead
                or enemy.dist > project.util.check.player.range()
                or not enemy.player
                or enemy.cc
                or not enemy.los then
            return
        end

        local interrupt = interrupts[enemy.specID]
        if not interrupt then
            return
        end

        if enemy.dist > interrupt.range then
            return
        end

        local interrupt_id = interrupt.id
        if enemy.class3 == project.util.id.class.WARLOCK and enemy.buff(project.util.id.spell.GRIMOIRE_OF_SACRIFICE_BUFF) then
            interrupt_id = project.util.id.spell.SPELL_LOCK_GRIMOIRE
        end

        if enemy.cooldown(interrupt_id) > 0 then
            return
        end

        if enemy.class3 == project.util.id.class.WARLOCK and not enemy.buff(project.util.id.spell.GRIMOIRE_OF_SACRIFICE_BUFF) then
            local count = awful.pets.around(awful.player, 40, function(pet)
                if pet.id ~= project.util.id.npc.FELHUNTER then
                    return
                end

                if not pet.enemy then
                    return
                end

                if pet.dead then
                    return
                end

                if not pet.los then
                    return
                end

                return true
            end)

            if count == 0 then
                return
            end
        end

        return true
    end)

    interrupt_result_cache = result
    last_cache_time = awful.time
    return result
end
