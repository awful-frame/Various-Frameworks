local Unlocker, awful, project = ...

project.util.dbm_bars = {
    active = {},
    spells = {
        -- Raid
        -- Ulgrax
        ["435136"] = { name = "Venomous Lash", prio = 0, delay = 2 },
        ["434803"] = { name = "Carnivorous Contest", prio = 0 },
        ["445123"] = { name = "Hulking Crash", prio = 0 },
        ["443842"] = { name = "Swallowing Darkness", prio = 0, delay = 4 },

        ["434697"] = { name = "Brutal Crush", prio = 1, delay = 1 },

        -- The Bloodbound Horror
        ["443203"] = { name = "Crimson Rain", prio = 0 },
        ["444363"] = { name = "Gruesome Disgorge", prio = 0, delay = 5 },
        ["442530"] = { name = "Goresplatter", prio = 0, delay = 8 },

        -- Sikran
        ["459273"] = { name = "Cosmic Shards", prio = 0 },
        ["433517"] = { name = "Phase Blades", prio = 0 },
        ["456420"] = { name = "Shattering Sweep", prio = 0, delay = 5 },
        ["442428"] = { name = "Decimate", prio = 0, delay = 2 },

        ["435410"] = { name = "Phase Lunge", prio = 1 },

        -- Rasha'nan
        ["439811"] = { name = "Erosive Spray", prio = 0, delay = 1.5 },
        ["439784"] = { name = "Spinneret's Strands", prio = 0, delay = 2 },
        ["439795"] = { name = "Web Reave", prio = 0, delay = 4 },

        -- Broodtwister Ovi'nax
        ["441362"] = { name = "Volatile Concoction", prio = 0, delay = 1.5 },
        ["446700"] = { name = "Poison Burst", prio = 0, delay = 4 },

        -- Nexus-Princess Ky'veza
        ["435405"] = { name = "Starless Night", prio = 0 },
        ["437620"] = { name = "Nether Rift", prio = 0, delay = 4 },
        ["435486"] = { name = "Regicide", prio = 0 },
        ["448364"] = { name = "Death Masks", prio = 0 },

        -- The Silken Court
        ["441791"] = { name = "Burrowed Eruption", prio = 0 },
        ["438656"] = { name = "Venomous Rain", prio = 0 },
        ["442994"] = { name = "Unleashed Swarm", prio = 0, delay = 3 },

        -- Queen Ansurek
        ["443336"] = { name = "Gorge", prio = 0, delay = 1 },
        ["441556"] = { name = "Reaction Vapor", prio = 0 },

        ["440899"] = { name = "Liquefy", prio = 1, delay = 1.5 },

        -- Nerub-ar Palace Trash
        ["439873"] = { name = "Psychic Scream", prio = 0, delay = 0, trash = true },
        ["463104"] = { name = "Void Bolt Volley", prio = 0, delay = 0, trash = true },
        ["443138"] = { name = "Enshrouding Pulse", prio = 0, delay = 0, trash = true },
        ["436679"] = { name = "Deafening Roar", prio = 0, delay = 0, trash = true },
        ["436784"] = { name = "Infesting Swarm", prio = 0, delay = 0, trash = true },


        -- Dungeons
        -- Ara-Kara
        ["438476"] = { name = "Alerting Shrill", prio = 0, delay = 1.5 },
        ["438473"] = { name = "Gossamer Onslaught", prio = 0, delay = 4 },

        ["433766"] = { name = "Eye of the Swarm", prio = 0, delay = 7 },

        ["432227"] = { name = "Venom Volley", prio = 0, delay = 2 },
        ["461487"] = { name = "Cultivated Poisons", prio = 0, delay = 0 },

        --trash
        ["434793"] = { name = "Resonant Barrage", prio = 0, delay = 0, trash = true },
        ["438877"] = { name = "Call of the Brood", prio = 0, delay = 0, trash = true },
        ["448248"] = { name = "Revolting Volley", prio = 0, delay = 3, trash = true }, -- interruptable, leave for now check?
        ["434252"] = { name = "Massive Slam", prio = 0, delay = -2, trash = true }, -- stun

        -- City of Threads
        ["434829"] = { name = "Vociferous Indoctrination", prio = 0, delay = 1 },
        ["440468"] = { name = "Rime Dagger", prio = 0, delay = 2 },
        ["441395"] = { name = "Dark Pulse", prio = 0, delay = -2 },
        ["439341"] = { name = "Splice", prio = 0, delay = 1.5 },
        ["438860"] = { name = "Umbral Weave", prio = 0, delay = 4.5 },

        --trash
        ["446086"] = { name = "Void Wave", prio = 0, delay = 4.5, trash = true },
        ["446717"] = { name = "Umbral Weave", prio = 0, delay = 3, trash = true },
        ["443507"] = { name = "Ravenous Swarm", prio = 0, delay = 0, trash = true },
        ["434137"] = { name = "Venomous Spray", prio = 0, delay = 3, trash = true },


        -- Dawnbreaker
        ["426734"] = { name = "Burning Shadows", prio = 0, delay = 2 },

        ["426787"] = { name = "Shadowy Decay", prio = 0, delay = 2 },

        ["434089"] = { name = "Spinneret's Strands", prio = 0, delay = 2.5 },
        ["448888"] = { name = "Erosive Spray", prio = 0, delay = 1.5 },

        --trash
        ["431304"] = { name = "Dark Floes", prio = 0, delay = 2, trash = true },
        ["450756"] = { name = "Abyssal Howl", prio = 0, delay = 2, trash = true },
        ["451102"] = { name = "Shadowy Decay", prio = 0, delay = 2, trash = true },


        -- Stonevault
        ["424879"] = { name = "Earth Shatterer", prio = 0, delay = 4 },

        ["422233"] = { name = "Crystalline Smash", prio = 0, delay = 2 + 4 },
        ["443494"] = { name = "Crystalline Eruption", prio = 0, delay = 0 },

        ["445541"] = { name = "Exhaust Vents", prio = 0, delay = 6 - 1 },
        ["428508"] = { name = "Blazing Crescendo", prio = 0, delay = 0 },
        ["439577"] = { name = "Silenced Speaker", prio = 0, delay = 0 },

        ["427852"] = { name = "Entropic Reckoning", prio = 0, delay = 3 },

        --trash
        ["428879"] = { name = "Smash Rock", prio = 0, delay = 3, trash = true },
        ["426771"] = { name = "Void Outburst", prio = 0, delay = 1, trash = true },


        -- Mists of Tirna Scithe
        ["323149"] = { name = "Embrace Darkness", prio = 0, delay = 0 },

        ["336499"] = { name = "Guessing Game", prio = 0, delay = 3 },

        ["322450"] = { name = "Consumption", prio = 0, delay = 0 },

        --trash
        ["324909"] = { name = "Furious Thrashing", prio = 0, delay = 0 },
        ["322938"] = { name = "Harvest Essence", prio = 0, delay = 0 },
        ["460092"] = { name = "Acid Nova", prio = 0, delay = 0 },

        -- Necrotic Wake
        ["320596"] = { name = "Heaving Retch", prio = 0, delay = 2.5 },

        ["320012"] = { name = "Unholy Frenzy", prio = 1, delay = 3 },
        ["321226"] = { name = "Land of the Dead", prio = 0, delay = 4 },

        ["320358"] = { name = "Awaken Creation", prio = 0, delay = 2 + 2 },

        ["321754"] = { name = "Icebound Aegis", prio = 0, delay = 0 },

        --trash
        ["322756"] = { name = "Wrath of Zolramus", prio = 0, delay = 1.5 },
        ["328667"] = { name = "Frostbolt Volley", prio = 0, delay = 2.5 }, -- interruptable, leave for now chekc?

        -- Siege of Boralus
        ["272662"] = { name = "Iron Hook", prio = 0, delay = -2, trash = true }, -- knock 1seccast trash + boss
        ["257326"] = { name = "Gore Crash", prio = 0, delay = 2.5 - 2 }, -- knock

        ["463182"] = { name = "Fiery Ricochet", prio = 0, delay = 2 },

        ["257882"] = { name = "Break Water", prio = 0, delay = 2 },

        ["269227"] = { name = "Slam", prio = 0, delay = 3 },

        --trash
        ["257732"] = { name = "Shattering Bellow", prio = 0, delay = 2.75 },
        ["272711"] = { name = "Crushing Slam", prio = 0, delay = 2.5 },

        -- Grim Batol
        ["448847"] = { name = "Commanding Roar", prio = 0, delay = 3 },
        ["448877"] = { name = "Rock Spike", prio = 0, delay = 0 },

        ["449444"] = { name = "Molten Flurry", prio = 0, delay = 2.5 },
        ["451996"] = { name = "Forge Axe", prio = 0, delay = 0 },
        ["456902"] = { name = "Forge Swords", prio = 0, delay = 0 },
        ["456900"] = { name = "Forge Mace", prio = 0, delay = 0 },

        ["456751"] = { name = "Twilight Buffet", prio = 0, delay = 5 - 2 }, -- knock

        ["450077"] = { name = "Void Surge", prio = 0, delay = 0 }, -- knock
        ["75861"] = { name = "Binding Shadows", prio = 0, delay = 1.5 },

        --trash
        ["451965"] = { name = "Molten Wake", prio = 0, delay = 2 },
        ["451871"] = { name = "Mass Tremor", prio = 0, delay = 3 },
        ["451939"] = { name = "Umbral Wind", prio = 0, delay = 4 - 2 }, -- knock
        ["451224"] = { name = "Enveloping Shadowflame", prio = 0, delay = 1.5 },
    }
}

local function extract_guid_from_bar_id(bar_id)
    local guid = bar_id:match("Creature%-%d%-%d+%-%d+%-%d+%-%d+%-%x+")
    return guid
end

local function get_spell_by_bar_id(bar_id)
    local spell_id = bar_id:match("^Timer(%d+)")
    if spell_id then
        local spell_info = project.util.dbm_bars.spells[spell_id]
        if spell_info then
            local enemy_guid = extract_guid_from_bar_id(bar_id)
            local enemy = awful.GetObjectWithGUID(enemy_guid)

            if not enemy then
                project.util.debug.alert.pve("DBM BAR NO ENEMY GUID: " .. spell_info.name .. " GUID:" .. tostring(enemy_guid))
            end

            spell_info.enemy = enemy
            return spell_info
        end
    end
    return nil
end

local grace_period = 3

project.util.scan.dbm_bars = function(type)
    if not DBM or not DBT then
        return
    end

    if awful.instanceType2 == project.util.id.instance.PARTY or awful.instanceType2 == project.util.id.instance.RAID then
        DBM.Options.DebugMode = true
        DBM.Options.DebugLevel = 2
    else
        DBM.Options.DebugMode = false
        return
    end

    if not awful.player.inCombat then
        for bar_id, _ in pairs(project.util.dbm_bars.active) do
            project.util.dbm_bars.active[bar_id] = nil
        end
        return
    end

    local found_bar_ids = {}

    for bar in pairs(DBT.bars) do
        local spell_data = get_spell_by_bar_id(bar.id)

        if spell_data then
            found_bar_ids[bar.id] = true
            local delay = spell_data.delay or 0
            local end_time = awful.time + bar.timer + delay - awful.buffer
            local existing = project.util.dbm_bars.active[bar.id]
            if not existing then
                local enemy_ttd = spell_data.enemy and spell_data.enemy.ttd or 100
                if bar.timer >= 1 and enemy_ttd > bar.timer + 3 then
                    project.util.dbm_bars.active[bar.id] = {
                        prio = spell_data.prio,
                        enemy = spell_data.enemy,
                        spell_name = spell_data.name,
                        timer = end_time,
                        grace_end_time = end_time + grace_period,
                        expired = false
                    }
                    project.util.debug.alert.pve("[DBM BAR] Detected " .. (bar.timer + delay) .. " " .. spell_data.name)
                end
            else
                existing.timer = end_time
                existing.grace_end_time = end_time + grace_period
                existing.expired = false
            end
        end
    end

    for bar_id, bar_data in pairs(project.util.dbm_bars.active) do
        local enemy = bar_data.enemy
        if enemy and enemy.dead then
            project.util.dbm_bars.active[bar_id] = nil
            project.util.debug.alert.pve("[DBM BAR] Cleared dead enemy bar " .. (bar_data.spell_name or bar_id))
        else
            if not found_bar_ids[bar_id] then
                if not bar_data.expired then
                    bar_data.expired = true
                else
                    if awful.time > bar_data.grace_end_time then
                        project.util.dbm_bars.active[bar_id] = nil
                        project.util.debug.alert.pve("[DBM BAR] Grace period ended, removing " .. (bar_data.spell_name or bar_id))
                    end
                end
            end
        end
    end
end

project.util.dbm_bars.check = function(prio, time)
    for bar_id, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.prio == prio and bar_data.timer - time < awful.time then
            return bar_data.spell_name
        end
    end
end