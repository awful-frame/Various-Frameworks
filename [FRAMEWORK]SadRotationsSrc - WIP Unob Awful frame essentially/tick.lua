local Unlocker, blink = ...

local UnlockerType = Unlocker.type

blink.availableTalents = {}
blink.availableGlyphs = {}

-- blink.losFlags = bit.bor(0x10, 0x20, 0x100, 0x100000)
-- blink.collisionFlags = bit.bor(0x100000, 0x100, 0x20, 0x10, 0x2, 0x1)

local Target, Focus, MouseOver = blink.target, blink.focus, blink.mouseover
local GetTime = GetTime
local mathmax = math.max
local mathmin = math.min
local pairs = pairs
local select = select
local tableinsert = table.insert
local type = type
local unpack = unpack
local wipe = table.wipe
local GetInstanceInfo = GetInstanceInfo
local IsCurrentSpell = IsCurrentSpell

-- cache per-unit ttd stuff here?
local Cache = {
  UnitInfo = {}
}

--- ============================ CONTENT ============================
local TTD = {
  Settings = {
    -- Refresh time (seconds) : min=0.1,  max=2,    default = 0.1
    Refresh = 0.1,
    -- History time (seconds) : min=5,    max=120,  default = 10+0.4
    HistoryTime = 10 + 0.4,
    -- Max history count :      min=20,   max=500,  default = 100
    HistoryCount = 100
  },
  Cache = {}, -- A cache of unused { time, value } tables to reduce garbage due to table creation
  IterableUnits = {
    Target,
    Focus,
    blink.pet,
    blink.player
    -- MouseOver,
    -- unpack(blink.enemies)
  }, -- It's not possible to unpack multiple tables during the creation process, so we merge them before unpacking it (not efficient but done only 1 time)
  -- TODO: Improve IterableUnits creation
  Units = {}, -- Used to track units
  ExistingUnits = {}, -- Used to track GUIDs of currently existing units (to be compared with tracked units)
  Throttle = 0
}
blink.TTD = TTD

function blink.TTDRefresh()
  -- This may not be needed if we don't have any units but caching them in case
  -- We do speeds it all up a little bit
  local CurrentTime = GetTime()
  local HistoryCount = TTD.Settings.HistoryCount
  local HistoryTime = TTD.Settings.HistoryTime
  local TTDCache = TTD.Cache
  local IterableUnits = TTD.IterableUnits
  local Units = TTD.Units
  local ExistingUnits = TTD.ExistingUnits

  wipe(ExistingUnits)

  local ThisUnit
  for i = 1, #IterableUnits do
    ThisUnit = IterableUnits[i]
    if ThisUnit and ThisUnit.visible then
      local GUID = ThisUnit.guid
      -- Check if we didn't already scanned this unit.
      if GUID and not ExistingUnits[GUID] then
        ExistingUnits[GUID] = true
        local HealthPercentage = ThisUnit.hp
        -- Check if it's a valid unit
        if ThisUnit.enemy and HealthPercentage < 100 then
          local UnitTable = Units[GUID]
          -- Check if we have seen one time this unit, if we don't then initialize it.
          if not UnitTable or HealthPercentage > UnitTable[1][1][2] then
            UnitTable = {
              {},
              CurrentTime
            }
            Units[GUID] = UnitTable
          end
          local Values = UnitTable[1]
          local Time = CurrentTime - UnitTable[2]
          -- Check if the % HP changed since the last check (or if there were none)
          if not Values or HealthPercentage ~= Values[2] then
            local Value
            local LastIndex = #TTDCache
            -- Check if we can re-use a table from the cache
            if LastIndex == 0 then
              Value = {
                Time,
                HealthPercentage
              }
            else
              Value = TTDCache[LastIndex]
              TTDCache[LastIndex] = nil
              Value[1] = Time
              Value[2] = HealthPercentage
            end
            tableinsert(Values, 1, Value)
            local n = #Values
            -- Delete values that are no longer valid
            while (n > HistoryCount) or (Time - Values[n][1] > HistoryTime) do
              TTDCache[#Cache + 1] = Values[n]
              Values[n] = nil
              n = n - 1
            end
          end
        end
      end
    end
  end
  -- Not sure if it's even worth it to do this here
  -- Ideally this should be event driven or done at least once a second if not less
  for Key in pairs(Units) do
    if not ExistingUnits[Key] then
      Units[Key] = nil
    end
  end
end

-- Get the estimated time to reach a Percentage
-- TODO : Cache the result, not done yet since we mostly use TimeToDie that cache for TimeToX 0%.
-- Returns Codes :
-- 11111 : No GUID
--  9999 : Negative TTD
--  8888 : Not Enough Samples or No Health Change
--  7777 : No DPS

blink.addObjectFunction("TimeToX", function(self, Percentage, MinSamples)
  -- if self.isPlayer and self.enemy then return 25 end
  local guid = self.guid
  if not guid then
    return 6969
  end

  if self.dummy then return 6666 end

  local Seconds = 8888
  local UnitTable = TTD.Units[guid]

  if not tContains(TTD.IterableUnits, self) then
    tinsert(TTD.IterableUnits, self)
  end
  -- Simple linear regression
  -- ( E(x^2)  E(x) )  ( a )  ( E(xy) )
  -- ( E(x)     n  )  ( b ) = ( E(y)  )
  -- Format of the above: ( 2x2 Matrix ) * ( 2x1 Vector ) = ( 2x1 Vector )
  -- Solve to find a and b, satisfying y = a + bx
  -- Matrix arithmetic has been expanded and solved to make the following operation as fast as possible
  if UnitTable then
    local MinSamples = MinSamples or 3
    local Values = UnitTable[1]
    local n = #Values
    if n > MinSamples then
      local a, b = 0, 0
      local Ex2, Ex, Exy, Ey = 0, 0, 0, 0

      for i = 1, n do
        local Value = Values[i]
        local x, y = Value[1], Value[2]

        Ex2 = Ex2 + x * x
        Ex = Ex + x
        Exy = Exy + x * y
        Ey = Ey + y
      end
      -- Invariant to find matrix inverse
      local Invariant = 1 / (Ex2 * n - Ex * Ex)
      -- Solve for a and b
      a = (-Ex * Exy * Invariant) + (Ex2 * Ey * Invariant)
      b = (n * Exy * Invariant) - (Ex * Ey * Invariant)
      if b ~= 0 then
        -- Use best fit line to calculate estimated time to reach target health
        Seconds = (Percentage - a) / b
        -- Subtract current time to obtain "time remaining"
        Seconds = mathmin(7777, Seconds - (GetTime() - UnitTable[2]))
        if Seconds < 0 then
          Seconds = 0
        end
      end
    end
  end
  return Seconds
end)

local instanceDifficulty = function()
  local _, _, Difficulty = self:InstanceInfo()
  return Difficulty
end

-- Get the unit TTD Percentage
local SpecialTTDPercentageData = {
  --- Shadowlands
  ----- Dungeons -----
  --- De Other Side
  -- Mueh'zala leaves the fight at 10%.
  [166608] = 10,
  --- Mists of Tirna Scithe
  -- Tirnenns leaves the fight at 20%.
  [164929] = 20, -- Tirnenn Villager
  [164804] = 20, -- Droman Oulfarran
  --- Sanguine Depths
  -- General Kaal leaves the fight at 50%.
  [162099] = 50,
  ----- Castle Nathria -----
  --- Stone Legion Generals
  -- General Kaal leaves the fight at 50% if General Grashaal has not fight yet. We take 49% as check value since it get -95% dmg reduction at 50% until intermission is over.
  [168112] = function(self)
    return self.hp or 49
  end,
  --- Sun King's Salvation
  -- Shade of Kael'thas fight is 60% -> 45% and then 10% -> 0%.
  [165805] = function(self)
    return (self.hp > 20 and 45) or 0
  end,
  ----- Sanctum of Domination -----
  --- Eye of the Jailer leaves at 66% and 33%
  [180018] = function(self)
    return (self.hp > 66 and 66) or (self.hp <= 66 and self.hp > 33 and 33) or 0
  end,
  --- Painsmith Raznal leaves at 70% and 40%
  [176523] = function(self)
    return (self.hp > 70 and 70) or (self.hp <= 70 and self.hp > 40 and 40) or 0
  end,
  --- Fatescribe Roh-Kalo phases at 70% and 40%
  [179390] = function(self)
    return (self.hp > 70 and 70) or (self.hp <= 70 and self.hp > 40 and 40) or 0
  end,
  --- Sylvanas Windrunner intermission at 83% and "dies" at 50% (45% in MM)
  [180828] = function(self)
    return (self.hp > 83 and 83) or ((instanceDifficulty() == 16 and 45) or 50)
  end,

  --- Legion
  ----- Open World  -----
  --- Stormheim Invasion
  -- Lord Commander Alexius
  [118566] = 85,
  ----- Dungeons -----
  --- Halls of Valor
  -- Hymdall leaves the fight at 10%.
  [94960] = 10,
  -- Fenryr leaves the fight at 60%. We take 50% as check value since it doesn't get immune at 60%.
  [95674] = function(self)
    return (self.hp > 50 and 60) or 0
  end,
  -- Odyn leaves the fight at 80%.
  [95676] = 80,
  --- Maw of Souls
  -- Helya leaves the fight at 70%.
  [96759] = 70,
  ----- Trial of Valor -----
  --- Odyn
  -- Hyrja & Hymdall leaves the fight at 25% during first stage and 85%/90% during second stage (HM/MM).
  [114360] = function(self)
    return (not self.hp and 25) or (instanceDifficulty() == 16 and 85) or 90
  end,
  [114361] = function(self)
    return (not self.hp and 25) or (instanceDifficulty() == 16 and 85) or 90
  end,
  -- Odyn leaves the fight at 10%.
  [114263] = 10,
  ----- Nighthold -----
  --- Elisande leaves the fight two times at 10% then normally dies. She looses 50% power per stage (100 -> 50 -> 0).
  -- [106643] = function(self) return (self:Power() > 0 and 10) or 0 end, -- cba

  --- Warlord of Draenor (WoD)
  ----- Dungeons -----
  --- Shadowmoon Burial Grounds
  -- Carrion Worm doesn't die but leave the area at 10%.
  [88769] = 10,
  [76057] = 10,
  ----- HellFire Citadel -----
  --- Hellfire Assault
  -- Mar'Tak doesn't die and leave fight at 50% (blocked at 1hp anyway).
  [93023] = 50
}

blink.addObjectFunction("SpecialTTDPercentage", function(self, NPCID)
  if not NPCID then
    return 0
  end
  local SpecialTTDPercentage = SpecialTTDPercentageData[NPCID]
  if not SpecialTTDPercentage then
    return 0
  end

  if type(SpecialTTDPercentage) == "number" then
    return SpecialTTDPercentage
  end

  return 0
end)

blink.addObjectFunction("TimeToDie", function(self, MinSamples)
  local GUID = self.guid
  if not GUID then
    return 11111
  end

  local MinSamples = MinSamples or 3

  return self.TimeToX(self.SpecialTTDPercentage(self.id), MinSamples)

  -- local UnitInfo = Cache.UnitInfo[GUID]
  -- if not UnitInfo then
  --   UnitInfo = {}
  --   Cache.UnitInfo[GUID] = UnitInfo
  -- end

  -- local TTD = UnitInfo.TTD
  -- if not TTD then
  --   TTD = {}
  --   UnitInfo.TTD = TTD
  -- end
  -- if not TTD[MinSamples] then
  --   TTD[MinSamples] = self.TimeToX(self.SpecialTTDPercentage(self.id), MinSamples)
  -- end

  -- return TTD[MinSamples]
end)

-- Compare two values
local CompareThisTable = {
  [">"] = function(A, B)
    return A > B
  end,
  ["<"] = function(A, B)
    return A < B
  end,
  [">="] = function(A, B)
    return A >= B
  end,
  ["<="] = function(A, B)
    return A <= B
  end,
  ["=="] = function(A, B)
    return A == B
  end,
  ["min"] = function(A, B)
    return A < B
  end,
  ["max"] = function(A, B)
    return A > B
  end
}

local function CompareThis(Operator, A, B)
  return CompareThisTable[Operator](A, B)
end

blink.addObjectFunction("FilteredTimeToDie", function(self, Operator, Value, Offset, ValueThreshold, MinSamples)
  local TTD = self.TimeToDie(MinSamples)
  return TTD < (ValueThreshold or 7777) and CompareThis(Operator, TTD + (Offset or 0), Value) or false
end)

-- Get if the Time To Die is Valid for an Unit (i.e. not returning a warning code).
blink.addObjectFunction("TimeToDieIsNotValid", function(self, MinSamples)
  return self.TimeToDie(MinSamples) >= 7777
end)

-- Returns the max fight length of boss units, or the current selected target if no boss units
function blink.FightRemains()

  local MaxTimeToDie
  for _, CycleUnit in ipairs(blink.enemies) do
    if CycleUnit.combat and not CycleUnit.TimeToDieIsNotValid() then
      MaxTimeToDie = mathmax(MaxTimeToDie or 0, CycleUnit.TimeToDie())
    end
  end

  if MaxTimeToDie then
    return MaxTimeToDie
  end

  return Target.TimeToDie()
end

local player = blink.player

-- Returns the max fight length of boss units, 11111 if not a boss fight
-- function HL.BossFightRemains()
--   return HL.FightRemains(nil, true)
-- end

-- -- Get if the Time To Die is Valid for a boss fight remains
-- function HL.BossFightRemainsIsNotValid()
--   return HL.BossFightRemains() >= 7777
-- end

-- -- Returns if the current fight length meets the requirements.
-- function HL.FilteredFightRemains(Enemies, Operator, Value, CheckIfValid, BossOnly)
--   local FightRemains = HL.FightRemains(Enemies, BossOnly)
--   if CheckIfValid and FightRemains >= 7777 then
--     return false
--   end

--   return CompareThis(Operator, FightRemains, Value) or false
-- end

-- Returns if the current boss fight length meets the requirements, 11111 if not a boss fight.
-- function HL.BossFilteredFightRemains(Operator, Value, CheckIfValid)
--   return HL.FilteredFightRemains(nil, Operator, Value, CheckIfValid, true)
-- end

local actualMapID = {
  ["Black Rook Hold Arena"] = 1504,
  ["Nagrand Arena"] = 1505,
  ["Ashamane's Fall"] = 1552,
  ["Blade's Edge Arena"] = 1672,
  ["Empyrean Domain"] = 2373,
  ["Ruins of Lordaeron"] = 572,
  ["Dalaran Arena"] = 617,
  ["The Robodrome"] = 2167,
  ["Tol'Viron Arena"] = 980,
  ["Tiger's Peak"] = 1134,
  ["Maldraxxus Coliseum"] = 2509
}

blink.protected.Object = Object
blink.protected.ObjectName = ObjectName

local lists_updated = 0
local lastTarget

local Actors = blink.Actors
-- check for new actor on first frame

-- check for new actors all the time
C_Timer.NewTicker(0.1, function()
  Actors = blink.Actors
end)

local function selectActor(class, spec)
  Actors = blink.Actors
  local actors = Actors[class]
  -- prompt user with choice of actor, if multiple are present for their class/spec
  if actors then
    for i = 1, #actors do
      local actor = actors[i]
      if actor.spec == spec then
        return actor
      end
    end
  else
    blink.debug.print("no actors found", "framework")
  end
end

local currentRoutine

-- check next frame for routine, just to make it visible to blink which actor is loaded
C_Timer.After(0.1, function()
  local class, spec = select(2, UnitClass("player")), GetSpecialization()

  currentRoutine = selectActor(class, spec) or blink.currentRoutine or blink.classRoutines[spec]
  if currentRoutine then
    blink.routine = currentRoutine
    if blink.DevMode then
      _G.actor = currentRoutine
    end
  end

end)

blink.time = GetTime()

local nextTick = 0.15
blink.update = function()

  if blink.svshx ~= true then
    return
  end

  -- if blink.saved.helloxen and blink.arena then
  --   blink.enabled = true
  -- end

  player = player or blink.player

  local time = GetTime()

  local currentTickRate = (player.resting and not player.combat and 0.1 or currentRoutine and currentRoutine.ACTOR_TICKRATE or 0.05)

  if time - blink.time < currentTickRate then
    return
  end

  -- wipe paths drawn
  if blink.PathsToDraw then
    wipe(blink.PathsToDraw)
  end

  -- cache wipey
  for k, v in pairs(blink.cacheLiteral) do
    blink[k] = nil
  end
  blink.cacheLiteral = {}

  blink.pauseFacing = nil

  blink.SpellQueued = nil
  blink.cache = {}
  blink.fired_this_frame = {}
  blink.drawSheepComplex = {}
  wipe(blink.focused)

  blink.time = time
  blink.jitter = 0.03
  blink.latency = select(4, GetNetStats()) / 1000

  blink.tickRate = currentTickRate
  if blink.tickRate == 0 then
    blink.tickRate = 1/GetFramerate()
  end
  
  -- variable tickrate
  -- nextTick = math.random(10, 75) / 1000

  -- if math.random(1, 10) == 1 then
  --   nextTick = nextTick + math.random(5, 50) / 1000
  -- elseif math.random(1, 100) == 69 then
  --   nextTick = nextTick + math.random(20, 75) / 1000
  -- end

  -- if player.resting and not player.combat then
  --   nextTick = nextTick + 0.05
  -- end

  -- blink.tickRate = nextTick

  blink.lastTick = blink.time

  if blink.burst and time > blink.burst then
    blink.burst = nil
  end

  if blink.burst then
    blink.alert({
      message = "|cFFf7f25cBurst Mode Enabled",
      duration = 0.05,
      fadeOut = 0.2
    })
  end

  if blink.releaseFacingTime and time > blink.releaseFacingTime then
    blink.releaseFacing()
    blink.releaseFacingTime = nil
  end

  if blink.releaseMovementTime and time > blink.releaseMovementTime then
    blink.releaseMovement()
    blink.releaseMovementTime = nil
  end

  for k, v in pairs(blink.MacrosQueued) do
    if time - v > 0 then
      blink.MacrosQueued[k] = nil
    end
  end

  for k, cache in pairs(blink.timeCache) do
    for key, expires in ipairs(cache) do
      if time > expires then
        cache[key] = nil
      end
    end
  end

  for k, v in pairs(blink.CooldownTracker) do
    local count = 0
    for key, value in pairs(v) do
      count = count + 1
      if type(value) == "number" and value - blink.time <= 0 then
        v[key] = nil
      end
    end
    if count == 0 then
      blink.CooldownTracker[k] = nil
    end
  end

  for k, v in pairs(blink.GCDTracker) do
    if v - time <= 0 then
      blink.GCDTracker[k] = nil
    end
  end

  blink.buffer = blink.latency + blink.tickRate + blink.jitter
  blink.spellCastBuffer = blink.buffer + blink.latency - blink.jitter + (math.random(50, 100) / 1000)
  blink.gcd, blink.gcdRemains = blink.GetGCD()

  blink.zone = GetMinimapZoneText()
  blink.mapID = select(8, GetInstanceInfo()) -- actualMapID[blink.zone] or GetMapID() or 0

  if time - lists_updated > 1.25 or blink.arena and time - lists_updated > 0.5 then
    blink.updateObjectLists()
    lists_updated = time
  end

  blink.clearInternalCaches()
  blink.resetDrs()

  -- auto SpellQueueWindow
  if not blink.SpellQueueWindow_Update or time - blink.SpellQueueWindow_Update > 3 then
    SetCVar("SpellQueueWindow", (blink.buffer + blink.latency) * 1000)
    blink.SpellQueueWindow_Update = time
  end

  if not blink.hcUpdate or time - blink.hcUpdate > 0.1 then
    blink.hasControl = not (not HasFullControl() or player.cc or player.buff(45438) or player.dead or player.buff(320224))
    blink.hcUpdate = time
    -- limit ttd refresh
    if blink.ttd_enabled then
      blink.TTDRefresh()
    end
  end

  if #blink.OLConstructors > 0 then
    blink.loadUnits('custom_constructor')
  end

  for _, callback in ipairs(blink.updateCallbacks) do
    callback()
  end

  wipe(blink.calls)

  -- blink.protected.AcceptQueue()

  local class, spec = select(2, UnitClass("player")), GetSpecialization()

  currentRoutine = blink.currentRoutine or selectActor(class, spec) or blink.classRoutines[spec]

  if currentRoutine then
    blink.routineLoaded = true
  end

  if blink.enabled then

    for _, callback in ipairs(blink.enabledCallbacks) do
      callback()
    end

    -- if blink[class] and blink[class][spec] then
    -- 	blink[class][spec]()
    -- end

    if currentRoutine then
      blink.routine = currentRoutine
      blink.actor = currentRoutine
      currentRoutine()
    else
      if not blink.noSpecPrint then
        blink.print("No routine for current spec!")
        blink.noSpecPrint = true
      end
    end

    -- if type(blink.currentRoutine) == "function" then
    -- 	blink.currentRoutine()
    -- elseif blink.currentRoutine[spec] then 
    -- 	blink.currentRoutine[spec]()
    -- else
    -- 	if not blink.printedAboutSpec or blink.time - blink.printedAboutSpec > 2 then
    -- 		blink.print("No routine for current spec!")
    -- 		blink.printedAboutSpec = blink.time
    -- 	end
    -- end 
  end

  -- update available talents for .hasTalent function
  if blink.gameVersion == 1 then
    if not blink.availableTalentsUpdated or blink.time - blink.availableTalentsUpdated > 1 then
      for t = 1, MAX_TALENT_TIERS do
        for c = 1, NUM_TALENT_COLUMNS do
          local _, name, _, selected, _, id = GetTalentInfo(t, c, GetActiveSpecGroup());
          if name then
            name = strlower(name)
            blink.availableTalents[name] = {
              id = id
            }
          end
        end
      end
      local availableTalents = C_SpecializationInfo.GetPvpTalentSlotInfo(1)
      if availableTalents then
        availableTalents = availableTalents.availableTalentIDs
        for _, talent in ipairs(availableTalents) do
          local _, name, _, _, _, id = GetPvpTalentInfoByID(talent)
          if name then
            name = strlower(name)
            blink.availableTalents[name] = {
              id = id
            }
          end
        end
      end
      -- local selectedPvPTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
      -- for _, talent in ipairs(selectedPvPTalents) do
      -- 	local _, name, _, _, _, id = GetPvpTalentInfoByID(talent)
      -- 	if name then
      -- 		name = strlower(name)
      -- 		blink.availableTalents[name] = {
      -- 			id = id
      -- 		}
      -- 	end
      -- end
      blink.availableTalentsUpdated = blink.time
    end
  else
    if not blink.availableTalentsUpdated or blink.time - blink.availableTalentsUpdated > 1 then
      for i = 1, GetNumTalentTabs() do
        for j = 1, GetNumTalents(i) do
          local name, _, _, _, rank = GetTalentInfo(i, j)
          if name then
            name = strlower(name)
            blink.availableTalents[name] = {
              rank = rank,
              tabIndex = i,
              talentIndex = j
            }
          end
        end
      end
      blink.availableTalentsUpdated = blink.time
    end
  end

  -- update available glyphs for .hasGlyph function (wotlk)
  if blink.gameVersion == 11 then
    if not blink.availableGlyphsUpdated or blink.time - blink.availableGlyphsUpdated > 1 then
      for i=1,6,1 do
        local enabled, _, id = GetGlyphSocketInfo(i)
        if enabled then
          local name = C_Spell.GetSpellInfo(id).name
          if name then
            name = strlower(name)
            blink.availableGlyphs[name] = {
              id = id
            }
          end
        end
      end
    end

    blink.availableGlyphsUpdated = blink.time
  end

  -- blink.DevMode = false
  -- Devs must give a value to blink.DevMode to globalize the api

  -- if true then return end
  if blink.DevMode then
    _G.blink = blink
    _G.player = blink.player
    _G.target = blink.target
    _G.focus = blink.focus
    _G.healer = blink.healer
    _G.tank = blink.tank
    _G.enemyHealer = blink.enemyHealer
    _G.pet = blink.pet
    _G.party1 = blink.party1
    _G.party2 = blink.party2
    _G.party3 = blink.party3
    _G.party4 = blink.party4
    _G.Unlocker = Unlocker
    _G.Tinkr = Unlocker
    _G.actor = currentRoutine
  end

  local target = blink.target
  if target and target.exists then
    lastTarget = target.pointer
  else
    if UnitIsVisible(lastTarget) 
    and UnitCanAttack("player", lastTarget) then
      
      local LT = blink.createObject(lastTarget)
      if LT.buff(5384) then
        TargetUnit(LT.pointer)
        blink.alert("Re-target | Feign Death", 5384)
      elseif LT.buff(58984) then
        TargetUnit(LT.pointer)
        blink.alert("Re-target | Shadowmeld", 58984)
      elseif LT.used(55342, 1) then
        TargetUnit(LT.pointer)
        blink.alert("Re-target | Mirror Image", 55342)
      else
        lastTarget = nil
      end
    end
  end

end

CreateFrame("Frame"):SetScript("OnUpdate", function()

  -- local ecb = actualEnabledUpdateCallbacks
  local ucb = blink.actualUpdateCallbacks
  for i = 1, #ucb do
    ucb[i]()
  end

  local actor = currentRoutine
  if Actors and type(actor) == "table" then
    for class, actors in pairs(Actors) do
      for i = 1, #actors do
        if actor == actors[i] then
          actors[i].active = true
        else
          actors[i].active = false
        end
      end
    end
  end
end)

-- local function updateRandom()
--   blink.update()
--   C_Timer.After(nextTick, updateRandom)
-- end

if UnlockerType == "daemonic" or UnlockerType == "blade" then
  -- updateRandom()
  C_Timer.NewTicker(0.075, blink.update)
else
  -- updateRandom()
  CreateFrame("Frame"):SetScript("OnUpdate", blink.update)
end


-- force reload invalid sessions every ~30s
-- C_Timer.NewTicker(30, function()
--   if blink.svshx ~= true then
--     blink.call("ReloadUI")
--   end
-- end)