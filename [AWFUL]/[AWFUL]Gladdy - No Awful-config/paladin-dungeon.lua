local Unlocker, awful, project = ...
if awful.player.class2 ~= "PALADIN" then return end
if awful.player.spec ~= "Holy" then return end
local leader = awful.Spell(426756)
local slowFall = awful.Spell(434439)
local stormSpell = awful.Spell(460194)
local timeNow = awful.time
local player = awful.player
local delay = awful.delay(3, 5)
local delay2 = awful.delay(12, 23)

-- Error handling and logging
local function log(level, message)
    awful.print(string.format("[%s] %s", level, message))
end

-- State management
local DungeonState = {
    phase = 0,
    fragmentClickTime = 0,
    phase1State = "INITIAL",
    fragmentClickAttempts = 0,
    stormrookClickAttempts = 0,
    lastCaptainCombatTime = 0,
    dontFollow = true,
    hasReachedWaypoint1 = false,
    hasReachedWaypoint2 = false,
    p3wp1 = false,
    p3wp2 = false,
    currentZone = "",
    isLeavingParty = false,
    stuckTime = 0,
    lastSignificantPosition = { x = 0, y = 0, z = 0 },
    lastCheckTime = 0,
    lastDungeonID = nil  -- New field to track the last dungeon ID
}

-- Constants
local DEBUG = false
local STUCK_CHECK_INTERVAL = 5
local STUCK_THRESHOLD = 60
local MOVEMENT_THRESHOLD = 5

-- Input validation
local function validateCoordinates(x, y, z)
    return type(x) == "number" and type(y) == "number" and type(z) == "number"
end

-- Safe path finding
local function safePathFind(targetX, targetY, targetZ)
    if not validateCoordinates(targetX, targetY, targetZ) then
        log("ERROR", "Invalid coordinates for path finding")
        return false
    end

    local path = awful.path(player, targetX, targetY, targetZ)
    if not path then
        log("WARNING", "Failed to find path")
        return false
    end

    path.draw()
    path.follow()
    return true
end

local function debugPrint(message)
    if DEBUG then log("DEBUG", message) end
end

local function getDistance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

local function FindCaptainGarrick()
    return awful.units.find(function(unit)
        return unit.name == "Captain Garrick"
    end)
end

local CaptainGarrick = FindCaptainGarrick()

local function getCaptainPosition()
    local CaptainGarrick = FindCaptainGarrick()
    if CaptainGarrick then
        local x, y, z = CaptainGarrick.position()
        if x and y and z then
            return x, y, z
        end
    end
    return nil, nil, nil
end

local function resetDungeonState()
    DungeonState.phase1State = "INITIAL"
    DungeonState.lastCaptainCombatTime = 0
    DungeonState.fragmentClickTime = 0
    DungeonState.stuckTime = 0
    DungeonState.lastSignificantPosition = { x = 0, y = 0, z = 0 }
    DungeonState.lastCheckTime = 0
    DungeonState.isLeavingParty = false
    DungeonState.dontFollow = true  -- Ensure this is set to true on reset
    log("INFO", "Dungeon state reset, dontFollow set to true")
end

local function followCap()
    if DungeonState.dontFollow then return end
    local capX, capY, capZ = getCaptainPosition()
    if not capX or not capY or not capZ then return end
    if player.distanceTo(capX, capY, capZ) > 3 then
        safePathFind(capX, capY, capZ)
    end
end

local function getCurrentZone()
    return GetMinimapZoneText()
end

local function getCurrentPhase()
    local currentZone = DungeonState.currentZone
    if currentZone == "The Rookery Landing" then
        return 1
    elseif currentZone == "Storm's Roost" or currentZone == "Storm Rookery" or currentZone == "Stormrider Barracks" or currentZone == "Crashing Storm Hall" then
        return 2
    elseif currentZone == "Crashing Storm Hall" or currentZone == "Dock Lifts" or currentZone == "Abandoned Mines" then
        return 3
    else
        return 0
    end
end

local function checkIfStuck()
    if DungeonState.isLeavingParty then return end

    -- Check if player is dead
    if player.dead then
        log("INFO", "Player is dead. Preparing to leave party.")
        DungeonState.isLeavingParty = true
        
        local leaveDelay = delay2.now
        log("INFO", "Will attempt to leave party in " .. leaveDelay .. " seconds")

        C_Timer.After(leaveDelay, function()
            if not player.dead then
                log("INFO", "Player is no longer dead. Cancelling leave party.")
                DungeonState.isLeavingParty = false
                return
            end

            if IsInGroup() then
                log("INFO", "Leaving party due to player death.")
                C_PartyInfo.LeaveParty()
            else
                log("INFO", "Not in a party. No action taken.")
            end
            resetDungeonState()
        end)
        return
    end

    local currentTime = awful.time
    local currentX, currentY, currentZ = player.position()

    if not validateCoordinates(currentX, currentY, currentZ) then
        log("DEBUG", "Invalid position data. Skipping stuck check.")
        return
    end

    if currentTime - DungeonState.lastCheckTime < STUCK_CHECK_INTERVAL then return end
    DungeonState.lastCheckTime = currentTime

    if DungeonState.lastSignificantPosition.x == 0 and DungeonState.lastSignificantPosition.y == 0 and DungeonState.lastSignificantPosition.z == 0 then
        DungeonState.lastSignificantPosition = { x = currentX, y = currentY, z = currentZ }
        log("DEBUG", "First valid position recorded.")
        return
    end

    local distanceMoved = getDistance(currentX, currentY, currentZ,
        DungeonState.lastSignificantPosition.x,
        DungeonState.lastSignificantPosition.y,
        DungeonState.lastSignificantPosition.z)

    log("DEBUG", string.format("Distance moved: %.2f yards", distanceMoved))

    if distanceMoved > MOVEMENT_THRESHOLD then
        log("DEBUG", "Significant movement detected. Resetting stuck timer.")
        DungeonState.stuckTime = 0
        DungeonState.lastSignificantPosition = { x = currentX, y = currentY, z = currentZ }
    else
        DungeonState.stuckTime = DungeonState.stuckTime + STUCK_CHECK_INTERVAL
        log("DEBUG", string.format("Potential stuck time: %d seconds", DungeonState.stuckTime))

        if DungeonState.stuckTime >= STUCK_THRESHOLD then
            log("INFO", "Player might be stuck. Preparing to leave party.")
            DungeonState.isLeavingParty = true

            local leaveDelay = delay2.now
            log("INFO", string.format("Will attempt to leave party in %d seconds", leaveDelay))

            C_Timer.After(leaveDelay, function()
                if not DungeonState.isLeavingParty then
                    log("INFO", "Leave party cancelled - significant movement detected during delay.")
                    return
                end

                local newX, newY, newZ = player.position()
                if not validateCoordinates(newX, newY, newZ) then
                    log("WARNING", "Invalid position data during leave check. Cancelling leave.")
                    DungeonState.isLeavingParty = false
                    return
                end

                local finalDistance = getDistance(newX, newY, newZ,
                    DungeonState.lastSignificantPosition.x,
                    DungeonState.lastSignificantPosition.y,
                    DungeonState.lastSignificantPosition.z)

                if finalDistance > MOVEMENT_THRESHOLD then
                    log("INFO", "Player has moved significantly during delay. Cancelling leave party.")
                    DungeonState.isLeavingParty = false
                    DungeonState.stuckTime = 0
                    DungeonState.lastSignificantPosition = { x = newX, y = newY, z = newZ }
                    return
                end

                if IsInGroup() then
                    log("INFO", "Leaving party due to being stuck.")
                    C_PartyInfo.LeaveParty()
                else
                    log("INFO", "Not in a party. No action taken.")
                end
                resetDungeonState()
            end)
        end
    end
end


awful.addEventCallback(function(eventinfo, event)
    if event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        local currentDungeonID = select(8, GetInstanceInfo())
        
        if inInstance and instanceType == "party" and currentDungeonID ~= DungeonState.lastDungeonID then
            resetDungeonState()
            DungeonState.lastDungeonID = currentDungeonID
            log("INFO", "Entered new dungeon. State reset, dontFollow set to true.")
        end
        
        DungeonState.currentZone = getCurrentZone()
    end
end)

local function autoLoot()
    if player.casting or player.channeling then return end
    if GetCVarBool("AutoLootDefault") ~= true then
        SetCVar("AutoLootDefault", "1")
    end

    if GetNumLootItems() > 0 then
        local freeBagSlots = 0
        for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
            freeBagSlots = freeBagSlots + C_Container.GetContainerNumFreeSlots(bag)
        end

        for i = 1, GetNumLootItems() do
            local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questId, isActive =
            GetLootSlotInfo(i)
            if lootName then
                if currencyID then
                    log("INFO", "Looting currency: " .. lootName .. " x" .. lootQuantity)
                    LootSlot(i)
                elseif freeBagSlots > 0 or isQuestItem then
                    log("INFO", "Looting: " .. lootName .. " x" .. lootQuantity)
                    LootSlot(i)
                    if not isQuestItem then
                        freeBagSlots = freeBagSlots - 1
                    end
                else
                    log("WARNING", "Skipping: " .. lootName .. " (bags full)")
                end
            end
        end
    else
        awful.dead.loop(function(unit)
            if unit.distance <= 40 and unit.los and CanLootUnit(unit.guid) then
                LeftClickObject(unit.pointer)
                return true
            end
        end)
    end

    if GetNumLootItems() == 0 and LootFrame:IsVisible() then
        CloseLoot()
    end
end

local function firstPhase()
    if player.mounted then awful.call("Dismount") end
    if getCurrentPhase() ~= 1 then return end

    local fragment = awful.units.within(40).find(function(unit)
        return unit.id == 218839
    end)

    local stormrook = awful.units.within(40).find(function(unit)
        return unit.id == 209538
    end)

    local CaptainGarrick = FindCaptainGarrick()

    -- State machine for Phase 1
    if DungeonState.phase1State == "INITIAL" then
        if player.losCoords(2800, -2140, 266) and player.distanceTo(2800, -2140, 266) > 1 then
            DungeonState.dontFollow = true
            safePathFind(2800, -2140, 266)
            log("INFO", "Moving to initial waypoint")
        elseif player.distanceTo(2800, -2140, 266) <= 1 then
            DungeonState.phase1State = "WAYPOINT_1_REACHED"
            log("INFO", "Reached initial waypoint")
        end
        return
    end

    if DungeonState.phase1State == "WAYPOINT_1_REACHED" then
        if player.losCoords(2800, -2122, 258) and player.distanceTo(2800, -2122, 258) > 1 then
            DungeonState.dontFollow = true
            safePathFind(2800, -2122, 258)
            log("INFO", "Moving to second waypoint")
        elseif player.distanceTo(2800, -2122, 258) <= 1 then
            if not player.buff(leader.id) then leader:Cast() end
            DungeonState.phase1State = "FOLLOW_CAPTAIN"
            log("INFO", "Reached Phase 1 - waypoint 2, now following Captain")
        end
        return
    end

    if DungeonState.phase1State == "FOLLOW_CAPTAIN" then
        if CaptainGarrick and CaptainGarrick.combat then
            DungeonState.lastCaptainCombatTime = awful.time
            DungeonState.dontFollow = false
            log("INFO", "Captain in combat, following")
            return
        end

        if awful.time - DungeonState.lastCaptainCombatTime < 5 then
            DungeonState.dontFollow = false
            log("INFO", "Recently out of combat, still following")
            return
        end

        if fragment and fragment.distance <= 100 and fragment.los and not player.combat then
            DungeonState.phase1State = "INTERACT_FRAGMENT"
            log("INFO", "Captain out of combat, moving to interact with fragment")
        else
            DungeonState.dontFollow = false
            if CaptainGarrick then
                safePathFind(CaptainGarrick.position())
            end
        end
        return
    end

    if DungeonState.phase1State == "INTERACT_FRAGMENT" then
        if fragment and fragment.distance <= 100 and fragment.los and not player.combat then
            DungeonState.dontFollow = true
            safePathFind(fragment.position())
            if player.distanceTo(fragment) <= 1.5 then
                LeftClickObject(fragment.pointer)
                DungeonState.fragmentClickTime = awful.time
                log("INFO", "Clicked fragment")
                DungeonState.phase1State = "CHECK_FRAGMENT"
            end
        else
            DungeonState.phase1State = "FOLLOW_CAPTAIN"
            log("INFO", "Cannot interact with fragment, resuming following Captain")
        end
        return
    end

    if DungeonState.phase1State == "CHECK_FRAGMENT" then
        if awful.time - DungeonState.fragmentClickTime < 5 then
            log("INFO", "Waiting for fragment to disappear")
            return
        end
        
        if not fragment then
            log("INFO", "Fragment has disappeared, moving to Stormrook")
            DungeonState.phase1State = "MOVE_TO_STORMROOK"
        else
            log("WARNING", "Fragment still present after 5 seconds, retrying")
            DungeonState.phase1State = "INTERACT_FRAGMENT"
        end
        return
    end

    if DungeonState.phase1State == "MOVE_TO_STORMROOK" then
        if stormrook and stormrook.los then
            DungeonState.dontFollow = true
            safePathFind(stormrook.position())
            if player.distanceTo(stormrook) <= 1.5 then
                DungeonState.phase1State = "INTERACT_STORMROOK"
                log("INFO", "In range of Stormrook")
            end
        else
            log("WARNING", "Cannot find or reach Stormrook, resuming following Captain")
            DungeonState.phase1State = "FOLLOW_CAPTAIN"
        end
        return
    end

    if DungeonState.phase1State == "INTERACT_STORMROOK" then
        if stormrook and stormrook.distance <= 1.5 and stormrook.los then
            LeftClickObject(stormrook.pointer)
            log("INFO", "Clicked Stormrook")
            DungeonState.phase1State = "WAIT_STORMROOK_DISAPPEAR"
        else
            log("WARNING", "Stormrook not in range or LOS, moving back to it")
            DungeonState.phase1State = "MOVE_TO_STORMROOK"
        end
        return
    end

    if DungeonState.phase1State == "WAIT_STORMROOK_DISAPPEAR" then
        local stormrookGone = not awful.units.within(100).find(function(unit)
            return unit.id == 209538 and unit.los
        end)
        
        if stormrookGone then
            log("INFO", "Stormrook out of LoS")
            DungeonState.phase1State = "FOLLOW_CAPTAIN"
            DungeonState.dontFollow = false
        else
            DungeonState.dontFollow = true
            log("INFO", "Waiting for Stormrook to be out of LoS")
        end
        return
    end

    -- Default behavior if no state matches
    DungeonState.dontFollow = false
    if CaptainGarrick then
        safePathFind(CaptainGarrick.position())
    end
end

local function secondPhase()
    local CaptainGarrick = FindCaptainGarrick()
    timeNow = awful.time
    local kyrioss = awful.dead.within(50).find(function(unit)
        return unit.id == 209230
    end)
    local feather = awful.units.within(50).find(function(unit)
        return unit.id == 217339
    end)
    local gorren = awful.dead.within(50).find(function(unit)
        return unit.id == 207205
    end)
    if getCurrentPhase() ~= 2 then return end
    if not kyrioss then
        DungeonState.dontFollow = false
    end

    if kyrioss then
        DungeonState.dontFollow = true
        if feather and not player.buff(434432) then
            local x, y, z = feather.position()
            safePathFind(x, y, z)
            if x and y and z and player.distanceTo(x, y, z) <= 2 then
                LeftClickObject(feather.pointer)
            end
        end
    end

    if player.buff(434432) then
        DungeonState.dontFollow = true
        local x, y, z = 2793, -1601, 289
        if player.distanceTo(x, y, z) > 1.5 then
            safePathFind(x, y, z)
        end

        if not player.falling then
            C_Timer.After(2, function()
                awful.call("MoveForwardStart")
                awful.call("JumpOrAscendStart")
                C_Timer.After(0.5, function()
                    awful.call("MoveForwardStop")
                    log("INFO", "YEET")
                    if player.falling then slowFall:Cast() end
                end)
            end)
        end
    end

    if DungeonState.currentZone == "Crashing Storm Hall" and not CaptainGarrick.moving and not CaptainGarrick.combat and timeNow - awful.time > 15 then
        safePathFind(CaptainGarrick.position())
        awful.call("MoveForwardStart")
    end
end

local function thirdPhase()
    if getCurrentPhase() ~= 3 then return end
    DungeonState.dontFollow = false

    if player.distanceTo(2881, -1588, 136) <= 1 then
        DungeonState.dontFollow = false
        awful.call("MoveForwardStart")
        awful.call("JumpOrAscendStart")
        awful.call("MoveForwardStop")
        log("INFO", "YEET")
    end

    if DungeonState.currentZone == "Abandoned Mines" then
        if not DungeonState.p3wp1 and player.distanceTo(2884, -1566, 3) > 3 and player.losCoords(2884, -1566, 3) then
            DungeonState.dontFollow = true
            safePathFind(2884, -1566, 1.6)
            log("INFO", "Moving to phase 3 wp1")
        else
            if player.distanceTo(2884, -1566, 3) < 1.5 then
                DungeonState.p3wp1 = true
                log("INFO", "Reached phase 3 waypoint 1")
            end
        end
        return
    end

    if DungeonState.currentZone == "Abandoned Mines" then
        if DungeonState.p3wp1 and not DungeonState.p3wp2 and player.losCoords(2893, -1566.6, 10.6) and player.distanceTo(2893, -1566, 10) > 3 then
            DungeonState.dontFollow = true
            safePathFind(2893, -1566, 10)
            log("INFO", "Moving to phase 3 wp2")
        else
            if player.distanceTo(2893, -1566, 10) < 1.5 then
                DungeonState.p3wp2 = true
                DungeonState.dontFollow = false
                log("INFO", "Reached phase 3 waypoint 2")
            end
        end
        return
    end

    if DungeonState.currentZone == "Abandoned Mines" and not CaptainGarrick.los then
        if player.losCoords(2887, -1566, 4.7) and player.distanceTo(2887, -1566, 4.7) > 5 then
            safePathFind(2887, -1566, 4.7)
        end
    else
        if CaptainGarrick and CaptainGarrick.los and CaptainGarrick.distance <= 8 and player.losCoords(2887, -1566, 4.7) and player.distanceTo(2887, -1566, 4.7) <= 3 then
            DungeonState.dontFollow = false
        end
    end
end

local function handleDungeon()
    if player.dead then return end
    local voidstone = awful.dead.within(50).find(function(unit)
        return unit.id == 207207
    end)
    log("INFO", "Dont Follow: " .. tostring(DungeonState.dontFollow))
    log("INFO", "Zone Var:" .. tostring(DungeonState.currentZone))
    log("INFO", "Phase: " .. tostring(getCurrentPhase()))
    followCap()
    FindCaptainGarrick()
    checkIfStuck()
    getCurrentPhase()
    autoLoot()
    firstPhase()
    secondPhase()
    thirdPhase()
    if voidstone then
        log("INFO", "VoidStone Dead")
        C_Timer.After(delay.now, function()
            C_PartyInfo.LeaveParty()
            DungeonState.dontFollow = true
        end)
    end
end

local function SelectFollowerDungeons()
    LFDQueueFrame_SetType("follower")
    C_Timer.After(0.5, function()
        for _, dungeonID in ipairs(LFDDungeonList) do
            if LFGEnabledList then
                LFGEnabledList[dungeonID] = project.settings.selectedFollowerDungeons[dungeonID] or false
            end
        end
        if LFDQueueFrame_Update then
            LFDQueueFrame_Update()
        end
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("LFG_PROPOSAL_SHOW")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "LFG_PROPOSAL_SHOW" and project.settings.autoDungeon then
        C_Timer.After(0.5, function()
            AcceptProposal()
        end)
    end
end)

awful.addUpdateCallback(function()
    if not project.settings.autoDungeon then return end
    DungeonState.currentZone = getCurrentZone()
    
    local inInstance, instanceType = IsInInstance()
    local currentDungeonID = select(8, GetInstanceInfo())
    
    if inInstance and instanceType == "party" then
        if currentDungeonID ~= DungeonState.lastDungeonID then
            resetDungeonState()
            DungeonState.lastDungeonID = currentDungeonID
            log("INFO", "Entered new dungeon. State reset, dontFollow set to true.")
        end
        handleDungeon()
    else
        local queueStatus = GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
        if not queueStatus then
            if not PVEFrame:IsShown() then
                ToggleLFDParentFrame()
            end
            C_Timer.After(delay.now, function()
                PVEFrame_ShowFrame("GroupFinderFrame")

                GroupFinderFrame.selectedIndex = 1
                GroupFinderFrame.selection = LFDParentFrame

                PVEFrame_ShowFrame("LFDParentFrame")

                C_Timer.After(delay.now, function()
                    LFDQueueFrame_SetType("follower")

                    SelectFollowerDungeons()

                    C_Timer.After(delay.now, function()
                        LFDQueueFrame_Join()
                    end)
                end)
            end)
        end
    end
end)

awful.addEventCallback(function(eventinfo, event)
    if event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        local currentDungeonID = select(8, GetInstanceInfo())
        
        if inInstance and instanceType == "party" and currentDungeonID ~= DungeonState.lastDungeonID then
            resetDungeonState()
            DungeonState.lastDungeonID = currentDungeonID
            log("INFO", "Entered new dungeon. State reset, dontFollow set to true.")
        end
        
        DungeonState.currentZone = getCurrentZone()
    end
end)