local Unlocker, blink, sr = ...
local player, target, focus, healer, party1, party2 = blink.player, blink.target, blink.focus, blink.healer, blink.party1, blink.party2
local onEvent = blink.addEventCallback
local bin, onUpdate = blink.bin, blink.addUpdateCallback
local BlinkFont, BlinkFontLarge = blink.createFont(8, "OUTLINE"), blink.createFont(16)
local saved = sr.saved
local colors = blink.colors

if player.class2 ~= "HUNTER" 
and player.class2 ~= "DRUID" 
and player.class2 ~= "PRIEST" 
and player.class2 ~= "ROGUE" 
and player.class2 ~= "WARRIOR" 
and player.class2 ~= "SHAMAN" 
and player.class2 ~= "PALADIN" then
  return
end


local BlinkFontLarge = blink.createFont(16)
local BlinkFontNormal = blink.createFont(12)

local unitIDs = {
    --[54569] = {r = 0, g = 0, b = 255, a = 75, radius = 1}, -- Transfer
    [61245] = {r = 255, g = 0, b = 0, a = 75, radius = 8}, -- cap totem
    --[179867] = {r = 69, g = 126, b = 151, a = 75, radius = 8}, -- static field totem
}

--QOL Drawings 
blink.Draw(function(draw)
    if sr.saved.streamingMode then return end

    -- if blink.MacrosQueued['fear']
    -- or blink.MacrosQueued['fear target']
    -- or blink.MacrosQueued['fear focus']
    -- or blink.MacrosQueued['fear arena1']
    -- or blink.MacrosQueued['fear arena2']
    -- or blink.MacrosQueued['fear arena3']
    -- or blink.MacrosQueued['fear enemyhealer'] then
    --     if player.class2 == "PRIEST" then
    --         local x,y,z = player.position()
    --         draw:SetColor(0, 255, 0)
    --         draw:SetWidth(3)
    --         draw:Circle(x,y,z,8.1)
    --         draw:Text(blink.textureEscape(8122, 20) .. "Psychic Scream Range", BlinkFontNormal, x,y,z)
    --     elseif player.class2 == "WARRIOR" then 
    --         local x,y,z = player.position()
    --         draw:SetColor(0, 255, 0)
    --         draw:SetWidth(3)
    --         draw:Circle(x,y,z,10.5)
    --         draw:Text(blink.textureEscape(5246, 20) .. "Intimidating Shout Range", BlinkFontNormal, x,y,z)
    --     end 
    -- end

    if saved.aaDraw 
    and player.role == "melee"
    and not player.mounted then
        draw:SetWidth(1.5)
        if target.enemy then
            local px, py, pz = player.position()
            local d, a = 6, 140
            if target.arc(d, a, player) then
                draw:SetColor(100, 255, 100, 200)
            else
                draw:SetColor(255, 100, 100, 240)
            end
            draw:Arc(px, py, pz, d, a, player.rotation)
        end
    end
    
    if healer.visible 
    and player.distanceTo(healer) <= 80 
    and saved.DrawLineToFHealer then
        local inline = healer.los and healer.distance < 38
        local lining = not healer.los
        local ranging = healer.dist > 38
        if lining then
            draw:SetWidth(3)
            draw:SetColor(255, 0, 0)
        elseif ranging then
            draw:SetWidth(3)
            draw:SetColor(255, 165, 0)
        elseif inline then
            draw:SetWidth(3)
            draw:SetColor(0, 190, 0)
        end
        local px, py, pz = player.position()
        local hx, hy, hz = healer.position()
        local dista = healer.dist
        dista = math.floor(dista)
        draw:Line(px, py, pz, hx, hy, hz)
        draw:Circle(hx, hy, hz, 1)
        draw:Text("" .. dista, BlinkFontNormal, hx, hy, hz)
        
    end

    --Priest Drawings
    --Party1
    if party1.visible 
    and player.distanceTo(party1) <= 80 
    and player.role == "healer" then
        local inline = party1.los and party1.distance < 38
        local lining = not party1.los
        local ranging = party1.dist > 38
        if lining then
            draw:SetWidth(3)
            draw:SetColor(255, 0, 0)
        elseif ranging then
            draw:SetWidth(3)
            draw:SetColor(255, 165, 0)
        elseif inline then
            draw:SetWidth(3)
            draw:SetColor(0, 190, 0)
        end
        local px, py, pz = player.position()
        local hx, hy, hz = party1.position()
        draw:Line(px, py, pz, hx, hy, hz)
    end

    --Party2
    if party2.visible 
    and player.distanceTo(party2) <= 80 
    and player.role == "healer" then
        local inline = party2.los and party2.distance < 38
        local lining = not party2.los
        local ranging = party2.dist > 38
        if lining then
            draw:SetWidth(3)
            draw:SetColor(255, 0, 0)
        elseif ranging then
            draw:SetWidth(3)
            draw:SetColor(255, 165, 0)
        elseif inline then
            draw:SetWidth(3)
            draw:SetColor(0, 190, 0)
        end
        local px, py, pz = player.position()
        local hx, hy, hz = party2.position()
        draw:Line(px, py, pz, hx, hy, hz)
    end

    if not saved.DrawTriggers then return end
    if not blink.arena then return end
        
    --draw friendly stuff
    --units.byId(100943).within(15).loop(...)
    blink.units.loop(function(unit)
    
        --Earthen Wall Totem
        if unit.id == 100943 then

            if not unit.creator.friendly then return end

            local x,y,z = unit.position()
            draw:SetColor(0, 190, 0)
            draw:SetWidth(8)
            draw:Circle(x,y,z,11)
            draw:Text(blink.textureEscape(198838, 20) .. "|cFF22f248Earthen Wall Totem - Stand Here", BlinkFontNormal, x,y,z)
        end

        --cap
        for uid, data in pairs(unitIDs) do
            if uid == unit.id then
                local ux,uy,uz = unit.position()
                if ux and uy and uz then

                    if unit.creator.friendly then return end

                    -- if unit.friend then
                    --     draw:SetColor(255, 0, 0)
                    -- end
                    -- if unit.enemy then
                    --     draw:SetColor(255, 0, 0)
                    -- end

                    draw:SetColor(255, 0, 0)
                    draw:Outline(ux,uy,uz, data.radius)
                    draw:SetColor(data.r, data.g, data.b)
                    draw:FilledCircle(ux,uy,uz, data.radius * (unit.castpct/100))
                    if uid == 61245 then 
                        draw:Text(blink.textureEscape(192058, 20) .. "|cFFFFFFFFCapacitor Totem", BlinkFontNormal, ux,uy,uz)
                    end
                    
                    --Mythic+
                    -- if uid == 179867 then
                    --     draw:FilledCircle(ux,uy,uz, data.radius * (1-(unit.uptime / 6)))
                    -- else
                    --     draw:FilledCircle(ux,uy,uz, data.radius * (unit.castpct/100))
                    -- end

                end
            end
        end

    end)

    --draw enemy stuff
    blink.triggers.loop(function(trigger)

        if trigger.creator.friendly then return end

        --BindingShot
        if trigger.id == 109248 then

            local x,y,z = trigger.position()
            draw:SetColor(255, 204, 255, 100)
            draw:SetWidth(5)
            draw:Circle(x,y,z,5)
            draw:FilledCircle(x,y,z,5)
            draw:Text(blink.textureEscape(109248, 20) .. "|cFFFFFFFF Binding Shot", BlinkFontNormal, x,y,z)
        end

        --Steel Trap
        if trigger.id == 162496 then

            local x,y,z = trigger.position()
            draw:SetColor(255, 10, 10, 70)
            draw:SetWidth(5)
            draw:Circle(x,y,z,3)
            draw:FilledCircle(x,y,z,3)
            draw:Text(blink.textureEscape(162488, 20) .. "|cFFFFFFFF Steel Trap", BlinkFontNormal, x,y,z)
        end

        --Trap
        if trigger.id == 187651 then

            local x,y,z = trigger.position()
            draw:SetColor(155, 155, 155, 155)
            draw:SetWidth(5)
            draw:Circle(x,y,z,3)
            draw:FilledCircle(x,y,z,3)
            draw:Text(blink.textureEscape(187650, 20) .. "|cFFFFFFFF Trap", BlinkFontNormal, x,y,z)
        end

        --Flare
        if trigger.id == 132950 then
                
            local x,y,z = trigger.position()
            draw:SetColor(255,170, 102, 102)
            draw:FilledCircle(x,y,z,10)
            draw:SetWidth(5)
            draw:Circle(x,y,z,10)
            draw:Text(blink.textureEscape(1543, 20) .. "|cFFf74a4a Flare", BlinkFontNormal, x,y,z)
        end
    end)
    
    --if not saved.EnemyNameDraw then return end

    -- blink.friends.loop(function(unit)
        
    --     --
    --     if unit.class2 == "PALADIN" then
    --         --if not unit.creator.friendly then return end
    --         local x,y,z = unit.position() 
    --         draw:SetColor(244,140,186) --red color 255,0,0
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(626003, 20) .. " Paladin", "GameFontNormal", x,y,z)
    --     elseif unit.class2 == "HUNTER" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(170,211,114)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(626000, 20) .. " Hunter", "GameFontNormal", x,y,z)
    --     elseif unit.class2 == "MAGE" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(63,199,235)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(626001, 20) .. " Mage", "GameFontNormal", x,y,z)
    --     elseif unit.class2 == "WARLOCK" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(135,136,238)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(626007, 20) .. " Warlock", "GameFontNormal", x,y,z)
    --     elseif unit.class2 == "WARRIOR" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(198,155,109)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(626008, 20) .. " Warrior", "GameFontNormal", x,y,z)
    --     elseif unit.class2 == "DRUID" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(255,124,10)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(625999, 20) .. " Druid", "GameFontNormal", x,y,z)  
    --     elseif unit.class2 == "DEMONHUNTER" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(163,48,201)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(1260827, 20) .. " Demon Hunter", "GameFontNormal", x,y,z)         
    --     elseif unit.class2 == "DEATHKNIGHT" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(196,30,58)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(135771, 20) .. " Death Knight", "GameFontNormal", x,y,z)       
    --     elseif unit.class2 == "EVOKER" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(51,147,127)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(4574311, 20) .. " Evoker", "GameFontNormal", x,y,z)    
    --     elseif unit.class2 == "MONK" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(0,255,152)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(626002, 20) .. " Monk", "GameFontNormal", x,y,z)    
    --     elseif unit.class2 == "SHAMAN" then
    --         local x,y,z = unit.position()
    --         draw:SetColor(0,112,221)
    --         draw:SetWidth(1)
    --         --draw:Circle(x,y,z,1)
    --         draw:Text(blink.textureEscape(626006, 20) .. " Shaman", "GameFontNormal", x,y,z)   
    --     end
    -- end)


end)

sr.DefensiveAreaTriggers = {}
local aoeDefensiveCasts = {}
local friendlyRoF
sr.StealthTracker = {}

local stealthClass = {
    ["ROGUE"] = true,
    ["DRUID"] = true,
    ["MAGE"] = true,
    ["HUNTER"] = true
}

local stealthSpells = {
    [115191] = 115191,  -- subterfuge stealth
    [1784] = 1784,      -- non-subterfuge stealth
    [1856] = 11327,     -- vanish
    [5215] = 5215,      -- prowl
    [66] = 32612,       -- invis
    [58984] = 58984,    -- meld
    [199483] = 199483,  -- camo
}

local aoeDefensives = {
    -- [43265] = { name = "dnd", trigger = 9225, duration = 10, radius = 3.75 }, -- death and decay test
    [51052] = { name = "AMZ", trigger = 51052, duration = 8, radius = 3.35 }, -- AMZ (big/small same ids)
    [62618] = { name = "Dome", trigger = 62618, duration = 10, radius = 4 }, -- Dome (big/small same ids)
    [196718] = { name = "Darkness", trigger = 196718, duration = 8, radius = 4 }, -- Darkness (nothing to diff cover of darkness from normal)
    [198839] = { name = "Earthen", trigger = 198839, duration = 15, radius = 5 }, -- Earthen
}

-- blink cl events
blink.addEventCallback(function(eventInfo, eventType, sourceObject, destObject)

    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, auraType, extraSpellName, auraType2 = unpack(eventInfo)

    local time = GetTime()

    -- Track Death Chakram proc (example from your code)
    if subEvent == "SPELL_AURA_APPLIED" and spellID == 327371 and sourceObject.isUnit(player) then
        sr.dcProc = time
    end

    -- Handle successful spell casts from enemies
    if subEvent == "SPELL_CAST_SUCCESS" and sourceObject then
        -- Enemy cast source
        if not blink.prep and sourceObject.enemy then
            local class = sourceObject.class or ""

            -- Stealth tracker logic
            if stealthSpells[spellID] then
                -- Get spell info using C_Spell.GetSpellInfo and safely handle the return value
                local spellInfo = C_Spell.GetSpellInfo(stealthSpells[spellID])
                local stealthSpellName = (spellInfo and spellInfo.name) or "Unknown Spell"

                -- Alert with the spell name
                blink.alert("|cFFa1eeffTracking " .. class .. blink.colors.orange .." (" .. stealthSpellName .. ")", stealthSpells[spellID])
                
                -- Capture enemy position and movement data for stealth tracking
                local source = sourceObject
                local x, y, z = source.position()
                local dir = source.movingDirection
                local velocity = source.speed
                table.insert(sr.StealthTracker, {
                    time = time,
                    pointer = source.pointer,
                    obj = source,
                    class = class,
                    pos = { x, y, z },
                    dir = dir,
                    velocity = velocity,
                    maxVelocity = source.speed2,
                    spellID = stealthSpells[spellID],
                    immuneMagic = max(source.magicDamageImmunityRemains, source.magicEffectImmunityRemains),
                    immunePhysical = max(source.physicalDamageImmunityRemains, source.physicalEffectImmunityRemains)
                })
            end

            -- Track AOE defensive spells
            local aoeDef = aoeDefensives[spellID]
            if aoeDef then
                aoeDefensiveCasts[aoeDef.trigger] = {
                    radius = aoeDef.radius,
                    expires = time + aoeDef.duration,
                    name = aoeDef.name
                }
            end
        end
    end

end)

-- stealth tracker draw & update
blink.Draw(function(draw)

    if saved.streamingMode then return end

    -- defensive area trigger draws
    for _, trigger in ipairs(sr.DefensiveAreaTriggers) do

        if trigger.creator.friendly then return end

        local x,y,z = trigger.position()
        if x then
            draw:SetColor(245,95,95,65)
            draw:SetWidth(5)
            draw:Circle(x,y,z,trigger.radius*2)
            draw:FilledCircle(x,y,z,trigger.radius*2)
            draw:Text(blink.textureEscape(trigger.id, 22) .. "|cFFFFFFFF", BlinkFontNormal, x,y,z)
        end
        
    end

    --TESTING
    -- blink.triggers.loop(function(trigger)
            
    --     --if trigger.creator.friendly then return end
        
    --     local x, y, z = trigger.position()
    --     if x then
    --         draw:SetColor(245, 95, 95, 65)
    --         draw:SetWidth(5)
    --         draw:Circle(x, y, z, 3)
    --         draw:FilledCircle(x, y, z, 2.9)
    --         draw:Text(blink.textureEscape(trigger.id, 22) .. "|cFFFFFFFF", BlinkFontNormal, x,y,z)
    --     end
    
    -- end)
    
    -- blink.triggers.loop(function(trigger)
        
    --     if trigger.creator.friendly then return end

    --     --BindingShot
    --     if trigger.id == 109248 then

    --         local x,y,z = trigger.position()
    --         draw:SetColor(255, 204, 255, 100)
    --         draw:SetWidth(5)
    --         draw:Circle(x,y,z,5)
    --         draw:FilledCircle(x,y,z,5)
    --         draw:Text(blink.textureEscape(109248, 20) .. "|cFFFFFFFF Binding Shot", BlinkFontNormal, x,y,z)
    --     end
    -- end)

    if not sr.StealthTracker then return end
    local time = blink.time
    for key, tracker in ipairs(sr.StealthTracker) do
        local elapsed = time - tracker.time
        if elapsed > 2.25 then
            sr.StealthTracker[key] = nil
        else
            local x,y,z = unpack(tracker.pos)
            if not UnitIsVisible(tracker.pointer) then
                tracker.init = tracker.init or time
                local timeInvis = time - tracker.init
                if x and y and z then
                    local dist = timeInvis * tracker.velocity
                    local px, py, pz = x + dist * math.cos(tracker.dir), y + dist * math.sin(tracker.dir), z
                    local texture = {
                        texture = C_Spell.GetSpellTexture(tracker.spellID),
                        width = 36, height = 36,
                        alpha = 0.8,
                    }
                    draw:SetColor(40,255,5,175)
                    draw:Texture(texture, px, py, pz + 0.75)
                    draw:Circle(px, py, pz, 1.25)
                    draw:SetColor(225,200,30,100)
                    local maxDistTraveled = ((timeInvis + blink.buffer) * tracker.maxVelocity) + 1.3
                    draw:Circle(x, y, z, maxDistTraveled)
                    draw:Line(px, py, pz, x, y, z)
                end
            elseif tracker.obj.visible and not tracker.obj.buff(tracker.spellID) and not tracker.obj.stealthed then
                sr.StealthTracker[key] = nil
            else
                tracker.init = nil
                local obj = tracker.obj
                local pointer = tracker.pointer
                local pos = { ObjectPosition(tracker.pointer) }
                local velocity = GetUnitSpeed(pointer) or sr.StealthTracker[key].velocity
                local dir = pointer.movingDirection or sr.StealthTracker[key].dir --blink.UnitMovingDirection(pointer) <= throwing an error
                sr.StealthTracker[key].pos = pos
                sr.StealthTracker[key].velocity = velocity
                sr.StealthTracker[key].maxVelocity = select(2,GetUnitSpeed(pointer)) or sr.StealthTracker[key].maxVelocity
                sr.StealthTracker[key].dir = dir
                if #pos == 3 then
                    local px, py, pz = unpack(pos)
                    local texture = {
                        texture = C_Spell.GetSpellTexture(tracker.spellID),
                        width = 36, height = 36,
                        alpha = 0.8,
                    }
                    draw:SetColor(40,255,5,150)
                    draw:Texture(texture, px, py, pz + 0.75)
                    draw:Circle(px, py, pz, 1.25)
                end
            end
        end
    end
end)

-- some hunter drawings
blink.Draw(function(draw)
    if saved.streamingMode then return end
    local time = blink.time
    if sr.flareDraw then
        local flare = sr.flareDraw
        local tracker = flare.tracker
        if time - flare.time < 3 then
            local x,y,z = unpack(flare.pos)
            local tx,ty,tz = unpack(tracker.pos)
            local dir = blink.AnglesBetween(x,y,z,tx,ty,tz)
            local circ = 2.5
            draw:SetColor(255,155,5,255)
            draw:Line(tx,ty,tz,x+circ*math.cos(dir),y+circ*math.sin(dir),z)
            local texture = {
                texture = C_Spell.GetSpellTexture(tracker.spellID),
                width = 32, height = 32,
                alpha = 0.6,
            }
            draw:Texture(texture, tx, ty, tz + 0.75)

            draw:Circle(x,y,z,circ)
        end
    end
end)

local BlinkFontLarge = blink.createFont(16)
local BlinkFontNormal = blink.createFont(12)

-- arena state
local colors = blink.colors
local state = { 
    deaths = {}, 
    --covenants = {}, -- Crash Problem
    startTime = 0,
    elapsed = 0,
    elapsedCombat = 0,
    kyrianWarrior = false,
    fireMage = false,
}
sr.arenaState = state
--Getunitaura BUG down

blink.addUpdateCallback(function() 

    sr.DefensiveAreaTriggers = {}
    local time = blink.time

    -- clear aoe defensive storage after expiration and get #events
    local eventCount = 0
    for key, v in pairs(aoeDefensiveCasts) do
        if v.expires <= time then
            aoeDefensiveCasts[key] = nil
        else
            eventCount = eventCount + 1
        end
    end

    -- friendly ring of fire event
    if friendlyRoF then
        if friendlyRoF < time then
            friendlyRoF = nil
        else
            eventCount = eventCount + 1
        end
    end

    sr.friendlyRoF = nil
    
    -- find corresponding triggers and add attributes needed for doing shit with them
    if eventCount > 0 then
        for _, trigger in ipairs(blink.AreaTriggers) do
            local id = trigger.id
            if id then
                local event = aoeDefensiveCasts[id]
                if event then
                    trigger.exists = true
                    trigger.radius = event.radius
                    trigger.remains = event.expires - time
                    trigger.name = event.name
                    table.insert(sr.DefensiveAreaTriggers, trigger)
                end
                -- friendly ring of fire
                if friendlyRoF then
                    if id == 27384 then
                        sr.friendlyRoF = trigger
                    end
                end
            end
        end
    end
end)

blink.addUpdateCallback(function()

    if not arena then
        state.deaths = {}
        --state.covenants = {} -- Crash Problem
        state.startTime = time
        state.firstCombat = nil
        state.elapsedCombat = 0
        state.elapsed = 0
        state.kyrianWarrior = false
        state.fireMage = false
    else
        if not state.firstCombat then
            if player.combat then
                state.firstCombat = time
            end
        else
            state.elapsedCombat = time - state.firstCombat 
        end
        if prep then state.startTime = time end
        state.elapsed = time - state.startTime
        for i=1,GetNumArenaOpponents() do
            local enemy = blink["arena"..i]
            if enemy and not state.firstCombat and enemy.combat then
                state.firstCombat = time
            end
            if enemy and enemy.exists and enemy.class then
                if enemy.class2 == "MAGE" and enemy.spec == "Fire" then
                    state.fireMage = enemy
                end
                -- if not state.covenants[i] and enemy.covenant then-- Crash Problem
                    
                --     local str = (colors[enemy.covenant] or "|cFFFFFFFF") .. enemy.covenant .. (colors[enemy.class] or "|cFFFFFFFF") .. " " .. enemy.class .. " detected"
                    
                --     if enemy.covenant == "Kyrian" and enemy.class2 == "WARRIOR" then
                --         state.kyrianWarrior = enemy
                --     end

                --     C_Timer.After(math.random(0,4), function()
                --         blink.alert(str)
                --     end)
                    
                --     state.covenants[i] = enemy.covenant

                -- end-- Crash Problem
            end
        end
    end
end)














-- if not saved.DebugMode then return end

-- -- Drawing function to visualize all triggers
-- blink.Draw(function(draw)
--     blink.triggers.loop(function(trigger)
--         local ux, uy, uz = trigger.position()
--         if ux and uy and uz then
--             -- Use the default drawing parameters for every trigger
--             draw:SetColor(255, 0, 0, 100)
--             draw:FilledCircle(ux, uy, uz, 3)
            
--             -- Optionally, draw text or outlines as needed
--             -- Uncomment and adjust the following lines as per your requirements
--             -- draw:Text(trigger.id .. "|cFFFFFFFF", BlinkFontNormal, ux, uy, uz + defaultDrawingParams.radius * 2)
--         end
--     end)
-- end)

