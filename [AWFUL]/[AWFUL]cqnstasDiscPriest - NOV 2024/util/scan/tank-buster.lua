local Unlocker, awful, project = ...

project.util.tank_buster.spells = {
    -- Raid
    -- The Bloodbound Horror
    ["Spectral Slam"] = 1,

    -- Sikran
    ["Phase Lunge"] = 1,

    -- Rasha'nan
    ["Savage Assault"] = 1,

    --Ovi'nax
    ["Volatile Concoction"] = 1,
    ["Vicious Bite"] = 1,

    -- Ky'veza
    ["Void Shredders"] = 1,

    -- The Silken Court
    ["Piercing Strike"] = 1,

    -- Queen Ansurek
    ["Feast"] = 1,
    ["Infest"] = 1,

    -- Ara-Kara
    ["Bleeding Jab"] = 1, -- debuff / instant cast
    ["Poison Bolt"] = 1,
    ["Extraction Strike"] = 1,
    ["Grasping Slash"] = 1,
    ["Voracious Bite"] = 1,


    -- City of Threads
    ["Venom Strike"] = 1,
    ["Rigorous Jab"] = 1, -- debuff / instant cast
    ["Brutal Jab"] = 1, -- debuff / instant cast
    ["Subjugate"] = 1,
    ["Rime Dagger"] = 1,
    ["Freezing Blood"] = 1,
    ["Oozing Smash"] = 1,
    ["Gutburst"] = 1, -- debuff
    ["Process of Elimination"] = 1,

    -- Dawnbreaker
    ["Tainted Slash"] = 1,
    ["Umbral Rush"] = 1,
    ["Terrifying Slam"] = 1,
    ["Obsidian Beam	"] = 1,

    --Stonevault
    ["Concussive Smash"] = 1,
    ["Shadow Claw"] = 1,
    ["Stonebreaker Strike"] = 1,
    ["Seismic Smash"] = 1,
    ["Igneous Hammer"] = 1,
    ["Crystalline Smash"] = 1,


    --Mists of Tirna Scithe
    ["Hand of Thros"] = 1, -- buff on enemy
    ["Anima Slash"] = 1,
    ["Shred Armor"] = 1,
    ["Triple Bite"] = 1,


    --Necrotic Wake
    ["Bone Claw"] = 1,
    ["Boneflay"] = 1,
    ["Gruesome Cleave"] = 1,
    ["Shatter"] = 1,
    ["Tenderize"] = 1,
    ["Mutilate"] = 1,
    ["Separate Flesh"] = 1,
    ["Crunch"] = 1,
    ["Icy Shard"] = 1,
    ["Sever Flesh"] = 1,

    --Siege of Boralus
    ["Tooth Breaker"] = 1,
    ["Singing Steel"] = 1,
    ["Cursed Slash"] = 1, -- debuff
    ["Crimson Swipe"] = 1,
    ["Rotting Wounds"] = 1, -- debuff
    ["Stinging Venom"] = 1,
    ["Shoot"] = 1,

    --Grim Batol
    ["Brutal Strike"] = 1,
    ["Rive"] = 1,
    ["Lava Fist"] = 1,
    ["Shadowflame Slash"] = 1,
    ["Skullsplitter"] = 1,
    ["Molten Flurry"] = 1,
    ["Molten Mace"] = 1,
    ["Crush"] = 1,
}

project.util.scan.tank_buster = function(type)
    if type == "pvp" then
        return
    end

    if not awful.player.inCombat then
        return
    end

    project.util.tank_buster.enemies = awful.enemies.filter(function(enemy)
        if not project.util.check.target.viable(enemy) then
            return
        end

        if not enemy.casting
                and not enemy.channel then
            return
        end

        local spell = project.util.tank_buster.spells[enemy.casting]
        if not spell then
            spell = project.util.tank_buster.spells[enemy.channel]
            if not spell then
                return
            end
        end

        if enemy.casting then
            if enemy.castRemains > awful.player.castRemains + awful.player.channelRemains + awful.spellCastBuffer + awful.buffer then
                return
            end
        end

        return true
    end)
end