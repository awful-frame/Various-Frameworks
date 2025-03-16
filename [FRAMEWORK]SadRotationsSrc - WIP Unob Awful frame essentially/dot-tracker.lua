local Unlocker, blink, sr = ...
local bin = blink.bin
local dotTracker = {}
local player, target, focus = blink.player, blink.target, blink.focus

if player.class2 ~= "DRUID" then return end

local dots = {
    [1822] = true,
    [1079] = true,
    [274837] = true,
    [106830] = true,
    [155625] = true,
}

local function toDebuff(spellID)
    local diffs = {
        [1822] = 155722
    }
    return diffs[spellID] or spellID
end

local function toSpell(spellID)
    local diffs = {
        [155722] = 1822
    }
    return diffs[spellID] or spellID
end

blink.addObjectFunction("snapshotPower", function(obj, spellName)
    spellName = spellName:lower()
    for pointer, tracked in pairs(dotTracker) do
        if tostring(obj.pointer) == pointer then
            return tracked.power[spellName] or 0
        end
    end
    return 0
end)

local function GetCurrentSnapshot(spell)
	
	local power = 1
    local feral = sr.druid.feral
    local wasStealth = feral.wasStealth or feral.bs_inc

	--tiger's fury
	power = power + bin(player.buff(5217)) * 0.15
	--bloodtalons
	power = power + bin(player.buff(145152)) * 0.3
	--prowl rake
	power = power + bin((spell == 1822 or type(spell) == "string" and spell:lower() == "rake") and (wasStealth or player.buff(102543))) * 0.36

	return power

end
sr.GetCurrentSnapshot = GetCurrentSnapshot
sr.snapshot = GetCurrentSnapshot

local function updatePower(spellID, spellName, destObject)
    if not dots[spellID] then return false end

    local time = blink.time
    spellName = spellName:lower()
    local destKey = tostring(destObject.pointer)
    if dotTracker[destKey] then
        table.insert(dotTracker[destKey].tracked, spellID)
        dotTracker[destKey].power[spellName] = GetCurrentSnapshot(spellID)
        dotTracker[destKey].time = time
        return
    end
    dotTracker[destKey] = {object=destObject,power={[spellName]=GetCurrentSnapshot(spellID)},tracked={spellID},time=time}
end

local function setPower(spellID, spellName, destObject)
    if not dots[spellID] then return false end
    spellName = spellName:lower()
    local destKey = tostring(destObject.pointer)
    local time = blink.time
    -- Already tracked
    if dotTracker[destKey] then
        table.insert(dotTracker[destKey].tracked, spellID)
        dotTracker[destKey].power[spellName] = GetCurrentSnapshot(spellID)
        dotTracker[destKey].time = time
        return true
    end
    dotTracker[destKey] = {object=destObject,power={[spellName]=GetCurrentSnapshot(spellID)},tracked={spellID},time=time}
    return true
end

local function cleanup(tracked)
    if not dots[spellID] then return false end
    local time = blink.time
    if time - tracked.time > 0.3 then
        for k, spellID in ipairs(tracked.tracked) do
            if not tracked.object.debuff(toDebuff(spellID), player) then
                table.remove(tracked.tracked, k)
                tracked.power[strlower(GetSpellInfo(spellID))] = nil
            end
        end
    end
end

local function removePower(spellID, spellName, destObject)
    if not dots[spellID] then return false end
    spellName = spellName:lower()
    local destKey = tostring(destObject.pointer)
    for pointer, tracked in pairs(dotTracker) do
        if pointer == destKey then 
            tracked.power[spellName] = nil
            return true 
        end
    end
end

-- local btTriggerSpells = { 1822, 5221, 155625, 202028, 106830, 106785 }
-- blink.addEventCallback(function(eventInfo, eventType, sourceObject, destObject)

--     local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, auraType, extraSpellName, auraType2 = unpack(eventInfo)
    
--     local time = blink.time

--     local sourceIsPlayer = sourceObject.pointer == player.pointer

--     if subEvent == "SPELL_AURA_REFRESH" then
--         updatePower(spellID, spellName, destObject)
--     end

--     if sourceIsPlayer and (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_CAST_SUCCESS") then
        
--         -- player spell cast success
--         if subEvent == "SPELL_CAST_SUCCESS" then
--             -- bloodtalons triggers
--             if tContains(btTriggerSpells, spellID) then 
--                 sr.druid.feral.btTriggers[spellID] = { time = time }
--             end
--         end

--         -- player applied new power
--         setPower(spellID, spellName, destObject)
        
--     end

--     -- player got bloodtalons
--     if subEvent == "SPELL_AURA_APPLIED" and spellID == 145152 and destObject.pointer == player.pointer then
--         sr.druid.feral.btTriggers = {}
--     end

--     if subEvent == "SPELL_AURA_REMOVED" then
--         removePower(toSpell(spellID), spellName, destObject)
--     end
    
-- end)

C_Timer.NewTicker(0.1, function()
    for pointer, tracked in pairs(dotTracker) do
        cleanup(tracked)
    end
end)