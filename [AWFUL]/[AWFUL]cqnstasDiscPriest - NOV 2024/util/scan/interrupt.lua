local Unlocker, awful, project = ...

project.util.interrupt.spells = {
    -- PvE
    -- Raid
    -- The Bloodbound Horror
    ["Black Bulwark"] = 0,

    --Ovi'nax
    ["Poison Burst"] = 0,

    -- Ara-Kara
    ["Bloodstained Webmage"] = 0,

    ["Resonant Barrage"] = -1,
    ["Horrifying Shrill"] = -1,
    ["Poison Bolt"] = -1,
    ["Web Bolt"] = -1,

    ["Revolting Volley"] = -2,

    -- City of Threads
    ["Web Bolt"] = -1,
    ["Void Bolt"] = -1,
    ["Void Wave"] = -1,
    ["Grimweave Blast"] = -1,
    ["Silk Binding"] = -1,

    ["Twist Thoughts"] = -2,
    ["Mending Web"] = -2,

    -- Dawnbreaker
    ["Shadow Bolt"] = 0,
    ["Animate Shadows"] = 0,
    ["Acidic Eruption"] = 0,

    ["Night Bolt"] = -1,
    ["Ensnaring Shadows"] = -1,
    ["Abyssal Howl"] = -1,
    ["Web Bolt"] = -1,
    ["Umbral Barrier"] = -1,
    ["Congealed Shadow"] = -1,
    ["Silken Shell"] = -1,
    ["Night Bolt"] = -1,

    ["Tormenting Beam"] = -2,

    --Stonevault
    ["Molten Metal"] = 0,

    ["Arcing Void"] = -1,
    ["Howling Fear"] = -1,
    ["Alloy Bolt"] = -1,
    ["Restoring Metals"] = -1,
    ["Piercing Wail"] = -1,
    ["Censoring Gear"] = -1,
    ["Stone Bolt"] = -1,

    --Mists of Tirna Scithe
    ["Spirit Bolt"] = 0,
    ["Patty Cake"] = 0,
    ["Consumption"] = 0,

    ["Spirit Bolt"] = -1,
    ["Bramblethorn Coat"] = -1,
    ["Nourish the Forest"] = -1,
    ["Stimulate Resistance"] = -1,
    ["Stimulate Regeneration"] = -1,

    ["Harvest Essence"] = -2,

    --Necrotic Wake
    ["Necrotic Bolt"] = 0,
    ["Enfeeble"] = 0,

    ["Frostbolt Volley"] = -1,
    ["Necrotic Bolt"] = -1,
    ["Frostbolt"] = -1,
    ["Bonemend"] = -1,
    ["Rasping Scream"] = -1,
    ["Necrotic Bolt"] = -1,
    ["Goresplatter"] = -1,
    ["Repair Flesh"] = -1,

    ["Drain Fluids"] = -2,

    --Siege of Boralus
    ["Watertight Shell"] = -1,
    ["Brackish Bolt"] = -1,
    ["Bolstering Shout"] = -1,
    ["Stinky Vomit"] = -1,
    ["Water Bolt"] = -1,
    ["Choking Waters"] = -1,

    --Grim Batol
    ["Shadowflame Bolt"] = -1,

    ["Earth Bolt"] = -1,
    ["Mass Tremor"] = -1,
    ["Shadowflame Bolt"] = -1,

    ["Sear Mind"] = -2,

    -- PvP
    -- always
    ["Mass Dispel"] = 1,
    ["Ultimate Penitence"] = 1,
    ["Ray of Frost"] = 1,
    ["Void Torrent"] = 1,
    ["Convoke the Spirits"] = 1,
    ["Shadowfury"] = 1,

    -- danger
    ["Searing Glare"] = 2,
    ["Chaos Bolt"] = 2,
    ["Arcane Surge"] = 2,

    ["Polymorph"] = 2,
    ["Fear"] = 2,
    ["Cyclone"] = 2,
    ["Repentance"] = 2,
    ["Hex"] = 2,
    ["Sleep Walk"] = 2,
}

project.util.scan.interrupt = function()
    project.util.interrupt.enemies = awful.enemies.filter(function(enemy)
        if not project.util.check.target.viable(enemy) then
            return
        end

        if not enemy.los then
            return
        end

        if not enemy.casting
                and not enemy.channel then
            return
        end

        local spell = project.util.interrupt.spells[enemy.casting]
        if not spell then
            spell = project.util.interrupt.spells[enemy.channel]
            if not spell then
                return
            end
        end

        if spell == 2
                and not project.util.enemy.danger then
            return
        end

        if enemy.casting then
            if enemy.castRemains > awful.player.castRemains + awful.spellCastBuffer + awful.buffer then
                return
            end
        end

        return true
    end)
end