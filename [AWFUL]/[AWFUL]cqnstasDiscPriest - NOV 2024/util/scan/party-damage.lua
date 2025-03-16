local Unlocker, awful, project = ...

project.util.party_damage.time = math.huge
project.util.party_damage.early_time = math.huge
project.util.party_damage.enemy = nil
project.util.party_damage.spell = nil

project.util.party_damage.spells = {
    -- PvE
    -- Raid
    -- Ulgrax
    ["Venomous Lash"] = 2,
    ["Digestive Acid"] = 2,
    ["Swallowing Darkness"] = 2,
    ["Hulking Crash"] = 2,

    -- The Bloodbound Horror
    ["Gruesome Disgorge"] = 2,
    ["Goresplatter"] = 2,

    -- Sikran
    ["Shattering Sweep"] = 2,
    ["Decimate"] = 2,

    -- Rasha'nan
    ["Erosive Spray"] = 2,
    ["Spinneret's Strands"] = 2,
    ["Web Reave"] = 2,

    -- Ovi'nax
    ["Volatile Concoction"] = 2, -- delay 8 sec
    ["Poison Burst"] = 2,

    -- Kyveza
    ["Nether Rift"] = 2,

    -- The Silken Court
    ["Unleashed Swarm"] = 2,

    -- Queen Ansurek
    ["Wrest"] = 2,
    ["Gorge"] = 2,
    ["Royal Condemnation"] = 2,

    -- Nerub-ar Palace Trash
    ["Acidic Hail"] = 1,

    ["Psychic Scream"] = 2,
    ["Void Bolt Volley"] = 2,
    ["Enshrouding Pulse"] = 2,
    ["Deafening Roar"] = 2,
    ["Infesting Swarm"] = 2,

    -- Ara-Kara
    ["Alerting Shrill"] = 1,
    ["Gossamer Onslaught"] = 1,

    ["Eye of the Swarm"] = 1,

    ["Call of the Brood"] = 1,
    ["Resonant Barrage"] = 1,

    ["Revolting Volley"] = 2,
    ["Venom Volley"] = 2,
    ["Massive Slam"] = 2,
    ["Cultivated Poison"] = 2,

    -- City of Threads
    ["Fierce Stomping"] = 1,
    ["Vociferous Indoctrination"] = 1,
    ["Duskbringer"] = 1,
    ["Dark Pulse"] = 1,

    ["Splice"] = 2,
    ["Viscous Darkness"] = 2,
    ["Umbral Weave"] = 2,
    ["Rime Dagger"] = 2,
    ["Ice Sickles"] = 2,
    ["Tremor Slam"] = 2,
    ["Ravenous Swarm"] = 2,
    ["Void Rush"] = 2,
    ["Venomous Spray"] = 2,
    ["Void Wave"] = 2,

    -- Dawnbreaker
    ["Dark Floes"] = 0,
    ["Shadowy Decay"] = 0,
    ["Erosive Spray"] = 0,

    ["Tormenting Beam"] = 0,
    ["Spinneret's Strands"] = 0,
    ["Obsidian Beam"] = 0,
    ["Burning Shadows"] = 0,
    ["Dark Orb"] = 4 + 2, -- cast time + orb moving delay
    ["Abyssal Howl"] = 0, -- can be interrupted

    --Stonevault
    ["Void Outburst"] = 0,

    ["Ground Pound"] = 0,
    ["Howling Fear"] = 0, -- can be interrupted
    ["Piercing Wail"] = 0,
    ["Smash Rock"] = 0,
    ["Earthburst"] = 0,
    ["Earth Burst Totem"] = 7, -- delay after 6.5s
    ["Volatile Spike"] = 0,
    ["Earth Shatterer"] = 0,
    ["Molten Metal"] = 0,
    ["Void Discharge"] = 0,
    ["Defiling Outburst"] = 0,


    --Mists of Tirna Scithe
    ["Harvest Essence"] = 0,
    ["Furious Thrashing"] = 0,
    ["Consumption"] = 0,

    ["Bramblethorn Coat"] = 0, -- can be interrupted
    ["Acid Nova"] = 0,
    ["Embrace Darkness"] = 0,
    ["Penalizing Burst"] = 0,
    ["Mind Link"] = 0,
    ["Guessing Game"] = 0,

    --Necrotic Wake
    ["Heaving Retch"] = 0,

    ["Wrath of Zolramus"] = 0,
    ["Dark Shroud"] = 0,
    ["Goresplatter"] = 0, -- can be interrupted
    ["Carrion Eruption"] = 0,
    ["Final Harvest"] = 0,
    ["Frostbolt Volley"] = 0, -- can be interrupted

    --Siege of Boralus
    ["Shattering Bellow"] = 0,
    ["Watertight Shell"] = 0, -- delay 10s if not purged
    ["Iron Hook"] = 0,
    ["Crushing Slam"] = 0,
    ["Gore Crash"] = 0,
    ["Fiery Ricochet"] = 0,
    ["Break Water"] = 0,
    ["Slam"] = 0,


    --Grim Batol
    ["Forge Weapon"] = 0,
    ["Void Surge"] = 0,

    ["Mass Tremor"] = 0, -- can be interrupted
    ["Umbral Wind"] = 0,
    ["Molten Wake"] = 0,
    ["Ascension"] = 0,
    ["Commanding Roar"] = 0,
    ["Rock Spike"] = 0,
    ["Molten Flurry"] = 0,
    ["Fiery Cleave"] = 0, -- dodgeable boss 2nd
    ["Invocation of Shadowflame"] = 0,
    ["Curse of Entropy"] = 0,
    ["Twilight Buffet"] = 0,

    ["Abyssal Corruption"] = 0,

    --Cinderbrew Medery
    ["Explosive Brew"] = 0,
    ["Spouting Shout"] = 0
}

project.util.scan.party_damage = function(type)
    if type == "pvp" then
        return
    end

    if not awful.player.inCombat then
        return
    end

    if project.util.party_damage.time < math.huge then
        return
    end

    awful.enemies.loop(function(enemy)
        if not project.util.check.target.viable(enemy) then
            return
        end

        if not enemy.casting
                and not enemy.channel then
            return
        end

        local delay = project.util.party_damage.spells[enemy.casting]
        if not delay then
            delay = project.util.party_damage.spells[enemy.channel]
            if not delay then
                return
            end
        end

        project.util.party_damage.enemy = enemy
        project.util.party_damage.time = awful.time + delay
        project.util.party_damage.early_time = awful.time + delay
        project.util.party_damage.spell = enemy.channel

        if enemy.casting then
            project.util.party_damage.time = awful.time + enemy.castRemains - awful.spellCastBuffer - awful.buffer - awful.player.castRemains - awful.player.channelRemains
            project.util.party_damage.spell = enemy.casting
        end

        C_Timer.After(enemy.castRemains + 5, function()
            project.util.party_damage.time = math.huge
            project.util.party_damage.early_time = math.huge
            project.util.party_damage.enemy = nil
        end)
    end)
end