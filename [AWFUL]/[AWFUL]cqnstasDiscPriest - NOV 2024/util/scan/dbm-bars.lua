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
        ["439873"] = { name = "Psychic Scream", prio = 0 },
        ["463104"] = { name = "Void Bolt Volley", prio = 0 },
        ["443138"] = { name = "Enshrouding Pulse", prio = 0 },
        ["436679"] = { name = "Deafening Roar", prio = 0 },
        ["436784"] = { name = "Infesting Swarm", prio = 0 },


        -- Dungeons
        -- Ara-Kara
        ["438476"] = { name = "Alerting Shrill", prio = 0, delay = 1.5 },
        ["438473"] = { name = "Gossamer Onslaught", prio = 0, delay = 4 },

        ["433766"] = { name = "Eye of the Swarm", prio = 0, delay = 7 },

        ["432227"] = { name = "Venom Volley", prio = 0, delay = 2 },
        ["432227"] = { name = "Cosmic Singularity", prio = 0, delay = 7 - 4 },

        --trash
        ["434793"] = { name = "Resonant Barrage", prio = 0 },
        ["438877"] = { name = "Call of the Brood", prio = 0 },
        ["438877"] = { name = "Revolting Volley", prio = 0, delay = 3 }, -- interruptable


        -- City of Threads
        ["434829"] = { name = "Vociferous Indoctrination", prio = 0, delay = 1 },
        ["440468"] = { name = "Rime Dagger", prio = 0, delay = 2 },
        ["441395"] = { name = "Dark Pulse", prio = 0 },
        ["439341"] = { name = "Splice", prio = 0, delay = 1.5 },
        ["438860"] = { name = "Umbral Weave", prio = 0, delay = 4.5 },

        --trash
        ["446086"] = { name = "Void Wave", prio = 0, delay = 4.5 },


        -- Dawnbreaker
        ["426734"] = { name = "Burning Shadows", prio = 0, delay = 2 },
        ["453212"] = { name = "Obsidian Beam", prio = 0, delay = 3 },

        --["426860"] = { name = "Dark Orb", prio = 0, delay = 4 + 4 },
        ["426787"] = { name = "Shadowy Decay", prio = 0, delay = 2 },

        ["434089"] = { name = "Spinneret's Strands", prio = 0, delay = 2.5 },
        ["448888"] = { name = "Erosive Spray", prio = 0, delay = 1.5 },

        --trash
        ["431304"] = { name = "Dark Floes", prio = 0, delay = 2 },
        ["450756"] = { name = "Abyssal Howl", prio = 0, delay = 2 },


        -- Stonevault
        ["424879"] = { name = "Earth Shatterer", prio = 0, delay = 4 },

        ["424879"] = { name = "Void Discharge", prio = 0, delay = 2 },
        ["424879"] = { name = "Crystalline Eruption", prio = 0 },

        ["445541"] = { name = "Exhaust Vents", prio = 0 },
        ["428508"] = { name = "Blazing Crescendo", prio = 0 },
        ["439577"] = { name = "Silenced Speaker", prio = 0 },

        ["427329"] = { name = "Void Corruption", prio = 0 },
        ["427852"] = { name = "Entropic Reckoning", prio = 0 },

        --trash
        ["429427"] = { name = "Earth Burst Totem", prio = 0, delay = 7 },
        ["429427"] = { name = "Void Outburst", prio = 0, delay = 1 },
        ["429427"] = { name = "Defiling Outburst", prio = 0, delay = 4 },


        -- Mists of Tirna Scithe
        ["323149"] = { name = "Embrace Darkness", prio = 0 },

        ["336499"] = { name = "Guessing Game", prio = 0, delay = 3 },

        ["322450"] = { name = "Consumption", prio = 0 },

        --trash
        ["324909"] = { name = "Furious Thrashing", prio = 0, delay = 1 },
        ["460092"] = { name = "Acid Nova", prio = 0, delay = 3 },

        -- Necrotic Wake
        ["320596"] = { name = "Heaving Retch", prio = 0, delay = 2.5 },

        ["320012"] = { name = "Unholy Frenzy", prio = 0, delay = 3 },
        ["321247"] = { name = "Final Harvest", prio = 0, delay = 4 },

        ["321754"] = { name = "Icebound Aegis", prio = 0 },

        --trash
        ["322756"] = { name = "Wrath of Zolramus", prio = 0, delay = 1.5 },

        -- Siege of Boralus
        ["275107"] = { name = "Iron Hook", prio = 0, delay = -1 }, -- knock 1seccast
        ["257326"] = { name = "Gore Crash", prio = 0, delay = 2.5 - 1 }, -- knock

        ["463182"] = { name = "Fiery Ricochet", prio = 0, delay = 2 },

        ["257882"] = { name = "Break Water", prio = 0, delay = 0.6 },

        ["269227"] = { name = "Slam", prio = 0, delay = 3 },

        --trash
        ["272546"] = { name = "Banana Rampage", prio = 0 },
        ["257170"] = { name = "Savage Tempest", prio = 0, delay = 3 },

        -- Grim Batol
        ["448847"] = { name = "Commanding Roar", prio = 0, delay = 3 },
        ["448877"] = { name = "Rock Spike", prio = 0 },

        ["449444"] = { name = "Molten Flurry", prio = 0, delay = 2.5 },

        ["456751"] = { name = "Twilight Buffet", prio = 0, delay = 5 - 1 }, -- knock

        ["450077"] = { name = "Void Surge", prio = 0 }, -- knock
        ["75861"] = { name = "Binding Shadows", prio = 0, delay = 1.5 },

        --trash
        ["451965"] = { name = "Molten Wake", prio = 0, delay = 2 },
        ["451965"] = { name = "Umbral Wind", prio = 0, delay = 4 - 1 }, -- knock
    }
}

local function get_spell_by_bar_id(bar_id)
    local spell_id = bar_id:match("^Timer(%d+)")
    if spell_id then
        return project.util.dbm_bars.spells[spell_id]
    end
    return nil
end

project.util.scan.dbm_bars = function(type)
    if type == "pvp" then
        return
    end

    if not awful.player.inCombat then
        for barID, _ in pairs(project.util.dbm_bars.active) do
            project.util.dbm_bars.active[barID] = nil
        end
        return
    end

    if not DBT then
        return
    end

    for bar in pairs(DBT.bars) do
        local found_spell = get_spell_by_bar_id(bar.id)

        if found_spell then
            if not project.util.dbm_bars.active[found_spell.name] then
                if bar.timer >= 1 then
                    local timer = bar.timer + (found_spell.delay or 0)

                    project.util.dbm_bars.active[found_spell.name] = {
                        prio = found_spell.prio,
                        timer = awful.time + timer
                    }

                    if found_spell.prio == 0 then
                        timer = timer + 3
                    end

                    C_Timer.After(timer, function()
                        project.util.dbm_bars.active[found_spell.name] = nil
                    end)
                end
            end
        end
    end
end
