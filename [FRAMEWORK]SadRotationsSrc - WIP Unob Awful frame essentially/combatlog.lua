local Tinkr, blink = ...
local CastByID = blink.CastByID
local tinsert, sort = tinsert, table.sort

blink.CooldownTracker = {}
blink.GCDTracker = {}
blink.SpellUseTracker = {}
blink.CastStartedTracker = {}
blink.spellCastSuccessCallbacks = {}


blink.events = {}
local events = blink.events
local bin = blink.bin
events.dequeue = {}
events.awaitingdq = {}

blink.encounterID = 0

events.root = {}
events.ursol = {}

blink.drReset = 18.45
local dummyExtraReset = 3.55

local function drReset(isDummy)
  return blink.drReset + bin(isDummy) * dummyExtraReset
end

blink.drs = {}
blink.drCats = {"stun", "silence", "disorient", "incapacitate", "root"}

-- local resetOnCast = {
-- 	[133] = true,
-- 	[257541] = function(event) return end
-- }

local resetSpells = {
  [133] = true,
  [11366] = true,
  [108853] = true,
  [257541] = true
}

local resetEvents = {
  -- shifting power .. -4.5s each tick safe bet?
  [325130] = function(pointer, source)
    local tracker = blink.CooldownTracker[pointer] or {}
    for spellID, tracked in pairs(tracker) do
      tracker[spellID] = tracked - 4.5
    end
  end,
  -- fireball -2s on combust
  [203283] = function(pointer, source)
    local tracker = blink.CooldownTracker[pointer] or {}
    if tracker[190319] then
      tracker[190319] = tracker[190319] - 2
    end
  end
  -- -- combustion
  -- [190319] = {
  -- 	-- pyrokinesis
  -- 	[203283] = {
  -- 		-- on damage...
  -- 		onDamage = true,
  -- 		-- fireball, 3s
  -- 		[133] = 3
  -- 	},
  -- 	-- kindling
  -- 	[155148] = {
  -- 		-- on damage...
  -- 		onDamage = true,
  -- 		-- only if it's a crit...
  -- 		mustCrit = true,
  -- 		-- fireball, 1s
  -- 		[133] = 1,
  -- 		-- pyro, 1s
  -- 		[11366] = 1,
  -- 		-- fireblast, 1s
  -- 		[108853] = 1,
  -- 		-- phoenix flames, 1s
  -- 		[257541] = 1,
  -- 	},
  -- }
}

local RealBaseCD = {
  -- psychic voice reduces psychic scream cd by 30s
  [8122] = function(obj)
    return (blink.gameVersion == 11 or obj.hasTalent(196704)) and 30 or 60
  end,
  [642] = function(obj)
    return obj.hasTalent(114154) and 210 or 300
  end,
  [32379] = 17, -- SW: Death, idk, rank 2 or something
  [119910] = 24 -- Spell Lock, Command Demon Ability
}

blink.RealBaseCD = RealBaseCD

local MaxCharges = {
  [115008] = 2, -- chi torp
  [109132] = 2 -- roll assume low
}

----A9ly
-- local function GetRealBaseCD(spellID, obj)
--   local baseCD, incursGCD = GetSpellBaseCooldown(spellID)
--   local recharge = select(4, GetSpellCharges(spellID))
--   if recharge then
--     recharge = recharge * 1000
--     baseCD = max(baseCD, recharge)
--   end
--   local rbcd = RealBaseCD[spellID]
--   if type(rbcd) == "function" then
--     baseCD = rbcd
--   end
--   if type(rbcd) == "number" then
--     baseCD = rbcd * 1000
--   end
--   if type(baseCD) == "function" then
--     return baseCD(obj) * 1000, incursGCD
--   else
--     return baseCD, incursGCD
--   end
-- end

--fix 
local function GetRealBaseCD(spellID, obj)
  local baseCD, incursGCD = GetSpellBaseCooldown(spellID)

  local chargeInfo = C_Spell.GetSpellCharges(spellID)

  if chargeInfo and chargeInfo.maxCharges > 0 then
    local recharge = chargeInfo.cooldownDuration
    if recharge then
      recharge = recharge * 1000
      baseCD = max(baseCD, recharge)
    end
  end

  local rbcd = RealBaseCD[spellID]
  if type(rbcd) == "function" then
    baseCD = rbcd(obj) * 1000
  elseif type(rbcd) == "number" then
      baseCD = rbcd * 1000
  end

  return baseCD, incursGCD
end


-- blink.drs[UnitGUID][Disorient] = .5
-- blink.drs[UnitGUID]["remains"][Disorient] = 12
blink.EventCallbacks = {}

blink.addEventCallback = function(callback, event)
  if type(callback) ~= "function" then
    blink.print("Must pass callback function to RegisterEvent")
    return
  end
  if event then
    local f = CreateFrame("Frame")
    f:RegisterEvent(event)
    f:SetScript("OnEvent", callback)
  else
    tinsert(blink.EventCallbacks, callback)
  end
end
blink.onEvent = blink.addEventCallback

local ursolEvents = {
  [190925] = {
    dur = 0.55,
    conditions = function(obj)
      return obj.speed < 30
    end
  }, -- harpoon before they yeet themselves at target
  [6544] = {
    dur = 0.3,
    conditions = function(obj)
      return obj.speed > 10
    end
  }, -- heroic leap real early
  [190784] = {
    dur = 1.15,
    conditions = function(obj)
      return obj.speed > 10
    end
  }, -- on divine steed
  [102417] = {
    dur = 0.7,
    conditions = function(obj)
      return blink.player.movingToward(obj) and obj.speed >= 17
    end
  } -- travel form wild charge chasing
}

local rootEvents = {
  -- ursol on leap, roll, wild charge? (if super lucky and off gcd immediately on event), 
  -- skull bash before melee range stops interrupt?
  [768] = {
    dur = 0.65,
    conditions = function(obj)
      return obj.role == "melee"
    end
  }, -- cat immediately after shifts
  [100] = {
    dur = 0.8,
    conditions = function(obj, dest)
      return obj.speed > 11 and obj.distanceTo(dest) > 7
    end
  }, -- charge while charging
  [49376] = {
    dur = 0.5,
    conditions = function(obj, dest)
      return obj.speed > 14 and obj.distanceTo(dest) > 7
    end
  }, -- wild charge mid charge
  [6544] = {
    dur = 0.4
  }, -- heroic leap early
  [198793] = {
    dur = 0.85
  }, -- any time after vengeful retreat basically
  [109132] = {
    dur = 0.6,
    conditions = function(obj)
      return obj.speed > 15
    end
  }, -- roll while rolling
  [115008] = {
    dur = 0.7,
    conditions = function(obj)
      return obj.speed > 15
    end
  }, -- chi torpedo little bit further
  [781] = {
    dur = 0.65
  }, -- on / slightly after disengage
  [101545] = {
    dur = 1.25,
    conditions = function(obj)
      return obj.speed > 17
    end
  }, -- flying serpent kick while flying
  [195072] = {
    dur = 0.45,
    conditions = function(obj)
      return obj.speed > 15
    end
  }, -- fel rush early
  [116841] = {
    dur = 1.15
  }, -- on tiger's lust
  [190784] = {
    dur = 1.15
  }, -- on divine steed
  [2983] = {
    dur = 1.5,
    conditions = function(obj)
      return obj.rootDR >= 0.5
    end
  }, -- at least half root sprint
  [102401] = {
    dur = 0.1,
    conditions = function(obj)
      return obj.speed >= 15
    end
  }, -- human wild charge flying
  [102417] = {
    dur = 0.6,
    conditions = function(obj)
      return obj.speed >= 16
    end
  } -- travel form wild charge
}

local triggerTracker = {}
blink.triggerTracker = triggerTracker
local triggers = {
  [187650] = {
    id = 9170,
    color = {65, 125, 255, 125},
    diameter = 3.05
  }, -- trap
  [1543] = {
    id = 3678,
    color = {255, 145, 80, 95},
    diameter = 10.1
  } -- flare
}

local function findClosestEvent(trigger, uptime)
  local closest, event = 999, false
  local tid = trigger.id
  for _, history in ipairs(triggerTracker) do
    if history.id == tid then
      local eventElapsed = history.time - blink.time
      local diff = abs(uptime - eventElapsed)
      if diff < closest then
        event = history
        closest = diff
      end
    end
  end
  if event and closest <= 30 then
    return event
  end
end

-- blink.updateTriggerStatus = function()

-- 	blink.AreaTriggers.track(function(trigger, uptime)
-- 		local event = findClosestEvent(trigger, uptime)
-- 		if event then
-- 			trigger.triggerInfo = event
-- 			if event.enemy then
-- 				trigger.enemy = true
-- 			end
-- 		end
-- 	end)

-- end

local swingTracker = {}
blink.swingTracker = swingTracker
local swing_reset_spells = {"Raptor Strike", "Maul", "Cleave", "Heroic Strike", "Slam"}

local function removeLastSwing(guid, isOffhand)
  for i = 1, #swingTracker do
    if swingTracker[i].guid == guid and (not isOffhand or not swingTracker[i].isOffhand) then
      tremove(swingTracker, i)
      break
    end
  end
end

local dmgHistory = {}

local function isUnitPrototype()
  return false
end

local unitPrototype = {
  isUnit = isUnitPrototype
}

local function SetMouseoverWrapper(obj, callback)
  local isTinkr = Tinkr.Util.Draw and ObjectUnit
  
  local oldUnit, newUnit
  local setter, clearer
  
  if isTinkr then
    setter = SetNPCObject
    oldUnit = Object("npc")
    newUnit = "npc"
    clearer = ClearNPCObject
  elseif unlockerType == "noname" then
    setter = SetFocus
    oldUnit = GetFocus()
    newUnit = "focus"
  elseif SetMouseover then
    setter = SetMouseover
    oldUnit = Object("mouseover")
    newUnit = "mouseover"
  else
    return callback(obj)
  end

  setter(obj)

  local res = { callback(newUnit) }

  if oldUnit then
    setter(oldUnit)
  elseif clearer then
    clearer()
  end

  return unpack(res)
end
blink.SetMouseoverWrapper = SetMouseoverWrapper

local function blinkCombat(self, mainEvent, ...)

  -- if mainEvent == "PLAYER_LEAVING_WORLD" then
  -- 	blink.loading = true
  -- 	blink.debuglog("loading screen started")
  -- end

  -- if mainEvent == "PLAYER_ENTERING_WORLD" then
  -- 	C_Timer.After(1.5, function() blink.loading = false end)
  -- 	blink.debuglog("loading screen ended")
  -- end

  if mainEvent == "ENCOUNTER_START" then
    local id = ...
    blink.encounterID = id
  elseif mainEvent == "ENCOUNTER_END" then
    blink.encounterID = 0
  end

  if mainEvent == "COMBAT_LOG_EVENT_UNFILTERED" then
    local combatInfo = {CombatLogGetCurrentEventInfo()}
    local _, event, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, destRaidFlags, spellID, spellName,
      _, auraType, extraSpellName, auraType2, _, _, _, critical = unpack(combatInfo)

    -- print(event, sourceGUID, destGUID)
    local player = blink.player
    local time = GetTime()

    if not player then
      return
    end

    -- cpu rapists
    local sourceObject = sourceGUID == player.guid and player or blink.GetObjectWithGUID(sourceGUID) or unitPrototype
    local destObject = destGUID == player.guid and player or blink.GetObjectWithGUID(destGUID) or unitPrototype

    local sourceIsPlayer = sourceObject.pointer == player.pointer
    local destIsPlayer = destObject.pointer == player.pointer

    -- onEvent Callbacks
    for _, callback in ipairs(blink.EventCallbacks) do
      callback({CombatLogGetCurrentEventInfo()}, event, sourceObject, destObject)
    end

    -- wep swing
    if blink.gameVersion ~= 1 then
      if event == "SWING_DAMAGE" then
        local _, _, _, _, _, _, _, _, _, isOffhand = select(12, unpack(combatInfo))
        local crusader = sourceObject.exists and sourceObject.buff("Seal of the Crusader")
        removeLastSwing(sourceGUID, isOffhand)
        tinsert(swingTracker, {
          time = time,
          guid = sourceGUID,
          isOffhand = isOffhand,
          crusader = crusader
        })
      elseif event == "SWING_MISSED" then
        local missType, isOffhand = select(12, unpack(combatInfo))
        local crusader = sourceObject.exists and sourceObject.buff("Seal of the Crusader")
        if missType == "PARRY" then
          local destSpeed = destObject.attackSpeed
          if destSpeed then
            removeLastSwing(destGUID)
            tinsert(swingTracker, {
              time = time,
              guid = destGUID,
              miss = missType,
              crusader = crusader
            })
          end
        else
          removeLastSwing(sourceGUID, isOffhand)
          tinsert(swingTracker, {
            time = time,
            guid = sourceGUID,
            isOffhand = isOffhand,
            miss = missType,
            crusader = crusader
          })
        end
      elseif event == "SPELL_DAMAGE" or event == "SPELL_MISSED" then
        local crusader = sourceObject.exists and sourceObject.buff("Seal of the Crusader")
        for _, thisSpell in ipairs(swing_reset_spells) do
          if spellName == thisSpell then
            removeLastSwing(sourceGUID, isOffhand)
            tinsert(swingTracker, {
              time = time,
              guid = sourceGUID,
              spell = spellName,
              crusader = crusader
            })
          end
        end
      end
    end

    if event == "SPELL_DAMAGE" or event == "SPELL_MISSED" then
      if sourceGUID == player.guid then
        if spellID == 133 or spellID == 257542 or spellID == 11366 or spellID == 108853 or spellID == 2948 then

          local spellID = spellID == 257542 and 257541 or spellID

          -- set awaiting dq
          -- fire dq immediately if non-crit, otherwise after hot streak is added
          if not critical or player.buff(48108) then
            events.dequeue[spellID] = time
          else
            -- avoid adding duplicate entries (phoenix flames... cough)
            if #events.awaitingdq == 0 or events.awaitingdq[#events.awaitingdq].time ~= time then
              -- phoenix flames always fires non crit and crit (?) so remove the existing dq
              if events.dequeue[spellID] and events.dequeue[spellID] == time then
                events.dequeue[spellID] = nil
              end
              tinsert(events.awaitingdq, {
                time = time,
                id = spellID
              })
            end
          end

          -- C_Timer.After(
          -- 	blink.buffer * 2 + bin(spellID == 257542) * 0.145 - bin(spellID == 133) * blink.latency, 
          -- 	function()
          -- 	events.dequeue[spellID == 257542 and 257541 or spellID] = GetTime()
          -- end)
        end
      end
    end

    -- aura cache shit
    -- local AuraCache = blink.AuraCache or {}
    -- if destGUID then
    --   if event == "SPELL_AURA_REFRESH" then
    --     local cache = AuraCache[destGUID]
    --     if cache then
    --       cache:Refresh(auraType)
    --     end
    --   end

    --   if event == "SPELL_AURA_APPLIED" then
    --     local cache = AuraCache[destGUID]
    --     if cache then
    --       cache:Applied(auraType)
    --     end
    --   end

    --   if event == "SPELL_AURA_REMOVED" then
    --     local cache = AuraCache[destGUID]
    --     if cache then
    --       cache:Removed(auraType)
    --     end
    --   end
    -- end

    if event == "SPELL_CAST_START" then
      if spellID and sourceObject.pointer then
        local pointer = tostring(sourceObject.pointer)
        local tracker = blink.CastStartedTracker[pointer] or {}
        -- spell cast started, track it
        tinsert(tracker, {
          id = spellID,
          time = time
        })
        blink.CastStartedTracker[pointer] = tracker
      end
    end

    if event == "SPELL_CAST_SUCCESS" then

      local isEnemy = sourceObject.enemy

      local trigger = triggers[spellID]
      if trigger then
        tinsert(triggerTracker, {
          spell = spellID,
          id = trigger.id,
          diameter = trigger.diameter,
          color = trigger.color,
          time = time,
          enemy = isEnemy
        })
      end

      if isEnemy and spellID == 49376 then
        events.fwc = {
          time = blink.time + 0.3,
          obj = sourceObject,
          dest = destObject
        }
      end

      if isEnemy then
        if rootEvents[spellID] then
          local e = rootEvents[spellID]
          local condition = e.condition
          local func = function()
            if not condition then
              return true
            end
            return condition(sourceObject, destObject)
          end
          table.insert(events.root, {
            expires = blink.time + e.dur,
            should = func,
            obj = sourceObject,
            reason = spellID
          })
        end
        if ursolEvents[spellID] then
          local e = ursolEvents[spellID]
          local condition = e.condition
          local func = function()
            if not condition then
              return true
            end
            return condition(sourceObject, destObject)
          end
          table.insert(events.ursol, {
            expires = blink.time + e.dur,
            should = func,
            obj = sourceObject,
            reason = spellID
          })
        end
      end

      if spellID == 376079 and isEnemy then
        events.spearCast = {
          source = sourceObject,
          time = time
        }
      end

      if spellID == 370965 then
        if isEnemy then
          events.huntCast = {
            source = sourceObject,
            dest = destObject,
            time = time
          }
        end
      end

      -- cd / gcd tracker
      if spellID and sourceObject.pointer then
        local pointer = tostring(sourceObject.pointer)
        local tracker = blink.CooldownTracker[pointer] or {}
        local gcdTracker = blink.GCDTracker[pointer] or 0
        local spellTracker = blink.SpellUseTracker[pointer] or {}

        local baseCD, incursGCD = GetRealBaseCD(spellID, sourceObject)

        -- spell has base cd, track it
        if baseCD and baseCD > 0 then
          local adjustedBaseCD = baseCD / 1000

          -- increment charge usage for spells with charges
          local charges = MaxCharges[spellID]
          if charges then
            tracker[spellID .. "chargeInfo"] = tracker[spellID .. "chargeInfo"] or {
              baseCD = adjustedBaseCD,
              maxCharges = charges,
              usage = {}
            }
            tinsert(tracker[spellID .. "chargeInfo"].usage, time + adjustedBaseCD)
          end
          -- stash refresh time
          tracker[spellID] = time + adjustedBaseCD
        end

        -- spell incurs gcd, track it
        if incursGCD and incursGCD > 0 and blink.castTime and blink.castTime(spellID, true) == 0 then
          local adjustedGCD = incursGCD / 1000
          SetMouseoverWrapper(sourceObject.pointer, function(obj)
            adjustedGCD = adjustedGCD / (1 + ((UnitSpellHaste(obj) or 16) / 100))
            if adjustedGCD and time + adjustedGCD > gcdTracker then
              gcdTracker = time + adjustedGCD
            end
          end)
        end

        -- spell was used, track it
        tinsert(spellTracker, {
          id = spellID,
          time = time
        })

        sort(spellTracker, function(x, y)
          return x.time > y.time
        end)

        -- spell resets another cd, update it
        local resets = resetEvents[spellID]
        if resets then
          resets(pointer, sourceObject)
        end

        blink.CooldownTracker[pointer] = tracker
        blink.GCDTracker[pointer] = gcdTracker
        blink.SpellUseTracker[pointer] = spellTracker
      end

      -- from player
      if sourceGUID == player.guid then
        blink.lastCast = spellID

        -- fire any spell cast success callbacks
        for i = 1, #blink.spellCastSuccessCallbacks do
          blink.spellCastSuccessCallbacks[i](spellID)
        end

        -- player blinked
        if spellID == 212653 then
          events.playerBlink = blink.time
        end
      end

      if spellID == 328530 and sourceObject.enemy then
        events.divineAscension = {
          time = time,
          source = sourceObject
        }
      end

      -- stop casting on death
      if spellID == 32379 then
        if player.castID -- sheep
        and (tContains(blink.spells.sheeps, player.castID) and player.castTarget.guid == sourceGUID -- ring
        or player.castID == 113724 and type(blink.actor) == "table" and blink.actor.ringIntent and
          blink.actor.ringIntent.target and blink.actor.ringIntent.target.guid == sourceGUID) then
          if player.castRemains <= blink.buffer then
            blink.alert({
              message = "Stop Casting | " .. blink.colors.pink .. "SW: Death",
              texture = 32379,
              bgColor = "yellow"
            })
            SpellStopCasting()
            if type(blink.actor) == "table" then
              blink.actor.paused = time + 0.3
            end
          else
            local after = max(0, min(player.castRemains - blink.buffer * 2, math.random(225, 700) / 1000))
            C_Timer.After(after, function()
              blink.alert({
                message = "Stop Casting | " .. blink.colors.pink .. "SW: Death",
                texture = 32379,
                bgColor = "yellow"
              })
              SpellStopCasting()
            end)
          end
          -- blink.alert("Stopped casting", "(Death)")
        end
      end

    end

    -- heating up / hot streak added to player.. dequeue crit events fifo
    if event == "SPELL_AURA_APPLIED" and auraType == "BUFF" and (spellID == 48107 or spellID == 48108) and
      destObject.isUnit(player) then

      -- remove old old
      for i = #events.awaitingdq, 1, -1 do
        if events.awaitingdq[i] and time - events.awaitingdq[i].time > 3.25 then
          tremove(events.awaitingdq, i)
        end
      end

      local spell = tremove(events.awaitingdq, #events.awaitingdq)
      if spell then
        events.dequeue[spell.id] = time
      end

    end

    -- dr tracker events
    if event == "SPELL_AURA_APPLIED" and auraType == "DEBUFF" and blink.drCat(spellID) then
      blink.debuffGained(spellID, destGUID)
    end
    if event == "SPELL_AURA_REFRESH" and auraType == "DEBUFF" and blink.drCat(spellID) then
      blink.debuffRefresh(spellID, destGUID)
    end
    if event == "SPELL_AURA_REMOVED" and auraType == "DEBUFF" and blink.drCat(spellID) then
      blink.debuffFaded(spellID, destGUID)
    end

  end
end

blink.resetDrs = function()
  local time = GetTime()
  for GUID, v in pairs(blink.drs) do
    for i = 1, #blink.drCats do
      local cat = blink.drCats[i]
      if v[cat] then
        local tracked = v[cat]
        if tracked.reset < time and tracked.diminished ~= 1 and not tracked.refresh then
          local currentlyInCCFromCat
          local objectFromGUID = blink.GetObjectWithGUID(GUID)
          for spellID, debuffCat in pairs(blink.ccDebuffs) do
            if cat == debuffCat then
              if objectFromGUID and objectFromGUID.exists and objectFromGUID.debuff(spellID) then
                currentlyInCCFromCat = true
              end
            end
          end
          if not currentlyInCCFromCat then
            blink.drs[GUID][cat].diminished = 1
            blink.drs[GUID][cat].reset = 0
          else
            blink.debug.print(cat .. " dr not resetting, since object is already in " .. cat, "cc")
            -- print("Not resetting, cause currently in cc from category!")
          end
        end
      end
    end
  end
end

blink.drCat = function(spellID)
  return spellID and blink.ccDebuffs[spellID] or nil
end

blink.nextDR = function(diminished)
  if diminished > 0.25 then
    return diminished / 2
  end
  return 0
end

blink.debuffGained = function(spellID, GUID)
  local drCat = blink.drCat(spellID)

  if not blink.drs[GUID] then
    blink.drs[GUID] = {}
    blink.drs[GUID][drCat] = {
      reset = 0,
      diminished = 1.0
    }
    return
  end

  local tracked = blink.drs[GUID][drCat]

  if tracked and tracked.reset <= GetTime() then
    tracked.diminished = 1.0
    tracked.refresh = nil
  end
end

blink.debuffFaded = function(spellID, GUID)
  local drCat = blink.drCat(spellID)

  if not blink.drs[GUID] then
    blink.drs[GUID] = {}
  end

  if not blink.drs[GUID][drCat] then
    blink.drs[GUID][drCat] = {
      reset = 0,
      diminished = 1
    }
  end

  local time = GetTime()
  local tracked = blink.drs[GUID][drCat]

  tracked.reset = time + drReset(tracked.isDummy)
  tracked.diminished = blink.nextDR(tracked.diminished)
  tracked.refresh = nil

end

blink.debuffRefresh = function(spellID, GUID)
  local drCat = blink.drCat(spellID)

  if not blink.drs[GUID] then
    blink.drs[GUID] = {}
    blink.drs[GUID][drCat] = {
      reset = 0,
      diminished = 1
    }
    return
  end

  local tracked = blink.drs[GUID][drCat]

  if tracked then
    tracked.diminished = blink.nextDR(tracked.diminished)
    tracked.refresh = true
  end
end

blink.ccCheck = function(unit, drCat)
  if type(unit) ~= "table" or not unit.visible then
    print("Invalid object passed to blink.ccCheck")
    return
  end
  for k, v in pairs(blink.ccDebuffs) do
    if v == drCat or not drCat then
      return unit.debuff(k)
    end
  end
end

blink.dr = function(object, drCat)

  if type(object) ~= "table" or not object.exists then
    blink.debug.print("object not found in dr check. returned false / 0 to fail gracefully.", "debug")
    return 0
  end
  local GUID = object.guid

  -- current dr
  local dr = 1
  if blink.drs[GUID] and blink.drs[GUID][drCat] and blink.drs[GUID][drCat]["diminished"] then
    dr = blink.drs[GUID][drCat]["diminished"]
  end

  for k, v in pairs(blink.ccDebuffs) do
    if v == drCat and object.debuff(k) then
      dr = dr / 2
    end
  end

  -- time before dr reset
  local remaining = 0
  if blink.drs[GUID] and blink.drs[GUID][drCat] and blink.drs[GUID][drCat].reset then
    if blink.drs[GUID][drCat].reset >= GetTime() then
      remaining = blink.drs[GUID][drCat].reset - GetTime();
    end
  end
  if remaining == 0 or remaining > 12 then
    if drCat == "incapacitate" and blink.IsInCC(object, { ["incapacitate"] = true }) then
      remaining = drReset(object.dummy)
    end
    if drCat == "disorient" and blink.IsInCC(object, { ["disorient"] = true }) then
      remaining = drReset(object.dummy)
    end
    if drCat == "stun" and blink.IsInCC(object, { ["stun"] = true }) then
      remaining = drReset(object.dummy)
    end
    if drCat == "silence" and blink.IsInCC(object, { ["silence"] = true }) then
      remaining = drReset(object.dummy)
    end
  end

  if dr < 0.25 then
    dr = 0
  end

  return dr, remaining

end

-- blink.onEvent(function()
--   local guid = blink.player.guid
--   if not guid then return end

--   local AuraCache = blink.AuraCache or {}
--   local cache = AuraCache[guid]
--   if cache then
--     cache:Clear("BUFF")
--   end
--   C_Timer.After(blink.buffer, function()
--     local guid = blink.player.guid
--     if not guid then return end
  
--     local AuraCache = blink.AuraCache or {}
--     local cache = AuraCache[guid]
--     if cache then
--       cache:Clear("BUFF")
--     end
--   end)
-- end, "PLAYER_MOUNT_DISPLAY_CHANGED")

blink.drDebug = function(unit, drCat)
  blink.print("DR: " .. blink.dr(unit, drCat) .. ", Remains: " .. blink.dr(unit, drCat, true))
end

local blinkCombatFrame = CreateFrame("Frame")
blinkCombatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
blinkCombatFrame:SetScript("OnEvent", blinkCombat)

-- dragonflight talent shit
if WOW_PROJECT_ID == 1 then
  
  blink.DF_ActiveTalents = {}
  blink.DF_InactiveTalents = {}
  
  local function updateDFTalents()
      blink.DF_ActiveTalents = {}
      blink.DF_InactiveTalents = {}
      local active, inactive = blink.DF_ActiveTalents, blink.DF_InactiveTalents
      local lConfigID = C_ClassTalents.GetActiveConfigID()
  
      if not lConfigID then
          return
      end
  
      local lConfigInfo = C_Traits.GetConfigInfo(lConfigID)
      if not lConfigInfo then
          return
      end
  
      local lTreeIDs = lConfigInfo["treeIDs"]
      for i = 1, #lTreeIDs do
          for _, lNodeID in pairs(C_Traits.GetTreeNodes(lTreeIDs[i])) do
              local lNodeInfo = C_Traits.GetNodeInfo(lConfigID, lNodeID)
              if lNodeInfo then
                  local activeEntry = lNodeInfo.activeEntry
                  local activeRank = lNodeInfo.activeRank
                  local ID = lNodeInfo.ID
                  if (activeEntry and activeRank > 0) then
                      local activeEntryID = activeEntry.entryID
                      local lEntryInfo = C_Traits.GetEntryInfo(lConfigID, activeEntryID)
                      if lEntryInfo then
                          local lDefinitionID = lEntryInfo["definitionID"]
                          if lDefinitionID then
                              local lDefinitionInfo = C_Traits.GetDefinitionInfo(lDefinitionID)
                              if lDefinitionInfo then
                                  local spellID = lDefinitionInfo["spellID"]
                                  local spellName = strlower((C_Spell.GetSpellInfo(spellID).name or ""))
                                  active[#active + 1] = {
                                      name = spellName,
                                      id = spellID,
                                      rank = activeRank,
                                      nodeID = lNodeID
                                  }
                              end
                          end
                      end
                  else
                      if (activeEntry) then
                          local activeEntryID = activeEntry.entryID
                          local lEntryInfo = C_Traits.GetEntryInfo(lConfigID, activeEntryID)
                          if lEntryInfo then
                              local lDefinitionID = lEntryInfo["definitionID"]
                              if lDefinitionID then
                                  local lDefinitionInfo = C_Traits.GetDefinitionInfo(lDefinitionID)
                                  if lDefinitionInfo then
                                      local spellID = lDefinitionInfo["spellID"]
                                      local spellName = strlower((C_Spell.GetSpellInfo(spellID).name or ""))
                                      inactive[#inactive + 1] = {
                                          name = spellName,
                                          id = spellID,
                                          rank = activeRank,
                                          nodeID = lNodeID
                                      }
                                  end
                              end
                          end
                      end
                  end
              end
          end
      end
  end
  
  -- blink.DF_ActiveTalents = {}
  -- blink.DF_InactiveTalents = {}

  -- local function updateDFTalents()
  --   blink.DF_ActiveTalents = {}
  --   blink.DF_InactiveTalents = {}
  --   local active, inactive = blink.DF_ActiveTalents, blink.DF_InactiveTalents
  --   local lConfigID = C_ClassTalents.GetActiveConfigID()

  --   if not lConfigID then
  --     return
  --   end

  --   local lConfigInfo = C_Traits.GetConfigInfo(lConfigID)
  --   local lTreeIDs = lConfigInfo["treeIDs"]

  --   for i = 1, #lTreeIDs do
  --     for _, lNodeID in pairs(C_Traits.GetTreeNodes(lTreeIDs[i])) do
  --       local lNodeInfo = C_Traits.GetNodeInfo(lConfigID, lNodeID)
  --       local activeEntry = lNodeInfo.activeEntry
  --       local activeRank = lNodeInfo.activeRank
  --       local ID = lNodeInfo.ID
  --       if (activeEntry and activeRank > 0) then
  --         local activeEntryID = activeEntry.entryID
  --         local lEntryInfo = C_Traits.GetEntryInfo(lConfigID, activeEntryID)
  --         local lDefinitionID = lEntryInfo["definitionID"]
  --         local lDefinitionInfo = C_Traits.GetDefinitionInfo(lDefinitionID)
  --         local spellID = lDefinitionInfo["spellID"]
  --         local spellName = strlower((GetSpellInfo(spellID) or ""))
  --         active[#active + 1] = {
  --           name = spellName,
  --           id = spellID,
  --           rank = activeRank,
  --           nodeID = lNodeID
  --         }
  --       else
  --         if (activeEntry) then
  --           local activeEntryID = activeEntry.entryID
  --           local ID = lNodeInfo.ID
  --           local lEntryInfo = C_Traits.GetEntryInfo(lConfigID, activeEntryID)
  --           local lDefinitionID = lEntryInfo["definitionID"]
  --           local lDefinitionInfo = C_Traits.GetDefinitionInfo(lDefinitionID)
  --           local spellID = lDefinitionInfo["spellID"]
  --           local spellName = strlower((GetSpellInfo(spellID) or ""))
  --           inactive[#inactive + 1] = {
  --             name = spellName,
  --             id = spellID,
  --             rank = activeRank,
  --             nodeID = lNodeID
  --           }
  --         end
  --       end
  --     end
  --   end
  -- end

  -- listen for talent changes
  blink.addEventCallback(updateDFTalents, "PLAYER_TALENT_UPDATE")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_COND_INFO_CHANGED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_CONFIG_CREATED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_CONFIG_DELETED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_CONFIG_LIST_UPDATED")
  blink.addEventCallback(updateDFTalents, "TRAIT_CONFIG_UPDATED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_NODE_CHANGED_PARTIAL")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_NODE_CHANGED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_NODE_ENTRY_UPDATED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_SYSTEM_INTERACTION_STARTED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_SYSTEM_NPC_CLOSED")
  blink.addEventCallback(updateDFTalents, "TRAIT_TREE_CHANGED")
  -- blink.addEventCallback(updateDFTalents, "TRAIT_TREE_CURRENCY_INFO_UPDATED")

  updateDFTalents()

end

-- wotlk healer tracka
if WOW_PROJECT_ID == 11 then
  local giveaway_spells = {
    healer = {
      ["Riptide"] = true,
      ["Earth Shield"] = true,
      ["Sacred Shield"] = true,
      ["Beacon of Light"] = true,
      ["Wild Growth"] = true,
      ["Swiftmend"] = true
    }
  }
  blink.wotlkRoleCache = {}
  blink.onEvent(function(info, event, source, dest)
    if event ~= "SPELL_CAST_SUCCESS" and event ~= "SPELL_CAST_START" then
      return
    end
    local ptr = source.guid
    if not ptr then
      return
    end
    local spellId, spellName = select(12, unpack(info))
    if giveaway_spells.healer[spellName] or giveaway_spells.healer[spellId] then
      blink.wotlkRoleCache[ptr] = {
        time = GetTime(),
        role = "healer"
      }
    end
  end)
end
