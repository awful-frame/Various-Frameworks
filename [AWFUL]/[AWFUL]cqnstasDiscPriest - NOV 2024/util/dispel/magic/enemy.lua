local Unlocker, awful, project = ...

local magicBuffsToPurge = {
    -- PvE
    -- The Dawnbreaker
    ["Abyssal Howl"] = -1, -- AoE
    ["Silken Shell"] = -1, -- AoE
    ["Umbral Barrier"] = 0,

    -- Mists of Tirna Scithe
    ["Nourish the Forest"] = -1, -- AoE
    ["Stimulate Resistance"] = -1, -- AoE
    ["Bramblethorn Coat"] = 0,

    -- Necrotic Wake
    ["Dark Shroud"] = 0,

    -- Siege of Boralus
    ["Bolstering Shout"] = -1, -- AoE
    ["Watertight Shell"] = 0,

    -- enemy danger only
    ["Power Word: Shield"] = 1,
    ["Ice Barrier"] = 1,
    ["Prismatic Barrier"] = 1,
    ["Blazing Barrier"] = 1,
    ["Lifebloom"] = 1,
    ["Earth Shield"] = 1,
    ["Enveloping Mist"] = 1,
    ["Sphere of Hope"] = 1,
    ["Adaptive Swarm"] = 1,

    ["Blessing of Protection"] = 2,
    ["Alter Time"] = 2,

    ["Soul of the Forest"] = 3,
    ["Power Infusion"] = 3,
    ["Ice Form"] = 3,
    ["Bloodlust"] = 3,
    ["Primal Rage"] = 3,
    ["Heroism"] = 3,

    ["Holy Ward"] = 4,
    ["Nether Ward"] = 4,
    ["Blessing of Sanctuary"] = 4,

    ["Nullifying Shroud"] = 5,
    ["Thorns"] = 5,
    ["Blistering Scales"] = 5,
    ["Blessing of Freedom"] = 5,

    ["Divine Favor"] = 6,
    ["Spiritwalker's Grace"] = 6,
    ["Innervate"] = 6,
    ["Nature's Swiftness"] = 6,
    ["Adaptive Swarm"] = 6,

    ["Arcane Intellect"] = 7,
    ["Power Word: Fortitude"] = 7,
    ["Mark of the Wild"] = 7,
    ["Skyfury"] = 7,
    ["Blessing of the Bronze"] = 7,

    -- MD only
    ["Divine Shield"] = -8,
    ["Ice Block"] = -8,
    ["Time Stop"] = -8,
    ["Blessing of Spellwarding"] = -8,
}

project.util.dispel.magic.enemy = function()
    local uptime_threshold = (0.3 + (math.random() * 0.6))

    local enemyToPurge
    local buffToPurge
    local highestPriority = 100

    awful.enemies.loop(function(enemy)
        if enemy.dead then
            return
        end

        if enemy.dist > project.util.check.player.range() then
            return
        end

        for buff, priority in pairs(magicBuffsToPurge) do
            local valid = true

            if priority == 1 and not project.util.enemy.danger then
                valid = false
            end

            if not enemy.buff(buff) then
                valid = false
            end

            if enemy.buffUptime(buff) < uptime_threshold then
                valid = false
            end

            local remains_threshold = 2 + awful.spellCastBuffer + awful.buffer
            if awful.player.casting == "Mass Dispel" then
                remains_threshold = remains_threshold + project.priest.spells.massDispel.castTime
            end

            if enemy.buffRemains(buff) < remains_threshold then
                valid = false
            end

            if priority > highestPriority then
                valid = false
            end

            if enemyToPurge then
                if priority == highestPriority then
                    if enemy.hp > enemyToPurge.hp then
                        valid = false
                    end
                end
            end

            if valid then
                enemyToPurge = enemy
                buffToPurge = buff
                highestPriority = priority
            end
        end
    end)

    return enemyToPurge, buffToPurge, highestPriority
end
