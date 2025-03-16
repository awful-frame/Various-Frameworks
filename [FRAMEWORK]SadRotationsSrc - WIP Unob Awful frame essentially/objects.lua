local Tinkr, blink = ...
local _ENV = getfenv(1)
local UnitBuff, UnitDebuff, UnitIsVisible, UnitCastingInfo, UnitChannelInfo = UnitBuff, UnitDebuff, UnitIsVisible,
    UnitCastingInfo, UnitChannelInfo
local UnitIsPlayer, UnitCanAttack, UnitIsFriend = UnitIsPlayer, UnitCanAttack, UnitIsFriend
local UnitIsDeadOrGhost, UnitRace, GetSpecializationInfoByID = UnitIsDeadOrGhost, UnitRace, GetSpecializationInfoByID
local UnitGUID, ObjectCastingTarget, GetUnitSpeed, UnitHealth, UnitHealthMax, ObjectTarget = UnitGUID,
    ObjectCastingTarget, GetUnitSpeed, UnitHealth, UnitHealthMax, ObjectTarget
local tonumber, type, tinsert, tremove, tsort, unpack, rawget, select = tonumber, type, tinsert, tremove, table.sort,
    unpack, rawget, select
local target, player, bin, blink_UnitIsUnit, unlockerType = blink.target, blink.player, blink.bin, blink.UnitIsUnit,
    Tinkr.type
local band, bor, pi, huge, tContains, tostring = bit.band, bit.bor, math.pi, math.huge, tContains, tostring
local setmetatable = setmetatable
local ObjectType, FastAuras = ObjectType, blink.FastAuras
local min, max, pairs, ipairs = math.min, math.max, pairs, ipairs

if Tinkr.type == "noname" then
  if blink.DevMode == true then
    print("Noname is the unlocker from objects")
  end
  -- local _env = getfenv(1)
  local UnitHealth = _G.UnitHealth
  local UnitHealthMax = _G.UnitHealthMax
  local UnitIsVisible = _G.UnitIsVisible
  local UnitClass = _G.UnitClass
  local UnitLevel = _G.UnitLevel
  local UnitRace = _G.UnitRace
  local UnitCanAttack = _G.UnitCanAttack
  local UnitGUID = _G.UnitGUID
end

local unpack16 = function(t)
  return t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[14], t[15], t[16]
end

blink.formHeights = {
  DRUID = { 1.8731694030762, -- bear
    1.7891782156326, -- cat
    1.359416 -- travel
  }
  -- SHAMAN={
  -- 	1.65, -- ghost wolf
  -- }
}

local objectFirstDetected = {}
local objectExistenceLastChecked = {}

local lastMovement = GetTime()
local function playerTimeStandingStill()
  if not player then
    player = blink.player
  end
  if player.moving then
    lastMovement = blink.time
    return 0
  else
    return blink.time - lastMovement
  end
end

local function GetSpecializationString(unit)
  if WOW_PROJECT_ID ~= 1 then return false end
  local spec = "Unknown"
  local unlocker = not unlockerType and "tinkr" or unlockerType
  if not unit then return spec end
  if unlocker == "tinkr" then
    local id = ObjectSpecializationID(unit)
    if id then
      spec = blink.specIdToString[id]
    end
  elseif unlocker == "daemonic" then
    local id = UnitSpecializationID(unit)
    if id then
      spec = blink.specIdToString[id]
    end
  else
    local id = ObjectField(unit, blink.offsets[1].GetSpecializationID, 6)
    if id then
      spec = blink.specIdToString[id]
    end
  end

  return spec
end

local function GetSpecializationID(unit)
  if WOW_PROJECT_ID ~= 1 then return false end
  local spec = 0
  local unlocker = not unlockerType and "tinkr" or unlockerType
  if not unit then return spec end
  if unlocker == "tinkr" then
    local id = ObjectSpecializationID(unit)
    if id then
      spec = id
    end
  else
    local id = UnitSpecializationID(unit)
    if id then
      spec = id
    end
  end

  return spec
end

local listMethods = {
  -- FilterListOfUnits
  filter = function(list, callback)
    local newList = {}
    for i = 1, #list do
      if callback(list[i]) then
        newList[#newList + 1] = list[i]
      end
    end
    blink.immerseOL(newList)
    return newList
  end,
  -- UnitsWithinListRect
  rect = function(self, x, y, z, w, l, a, criteria)
    local objects = {}
    for i = 1, #self do
      if not criteria or criteria(self[i]) then
        local ox, oy, oz = self[i].position()
        if ox and oy and oz and blink.inRect(x, y, z, ox, oy, oz, w, l, a) then
          objects[#objects + 1] = self[i]
        end
      end
    end
    blink.immerseOL(objects)
    return objects
  end,
  -- UnitsWithinListArc
  arc = function(self, x, y, z, size, arc, rotation, criteria)
    local objects = {}
    for i = 1, #self do
      if not criteria or criteria(self[i]) then
        local ox, oy, oz = self[i].position()
        if ox and oy and oz and blink.inArc(x, y, z, ox, oy, oz, size, arc, rotation) then
          objects[#objects + 1] = self[i]
        end
      end
    end
    blink.immerseOL(objects)
    return objects
  end,
  -- MostHitArcAngle
  arcAngle = function(self, r, a, steps, criteria, object)
    if not player then
      player = blink.player
    end
    local bestAngle, bestCount = 0, 0
    local px, py, pz = player.position()
    local units = {}
    for i = 1, #self do
      if not criteria or criteria(self[i]) then
        local x, y, z = self[i].position()
        local dist = blink.Distance(px, py, pz, x, y, z)
        local angleTo = blink.AnglesBetween(px, py, pz, x, y, z)
        local combatreach = not self[i].player and self[i].combatReach or 0
        tinsert(units, {
          dist = dist,
          angleTo = angleTo,
          mainObject = object and self[i].isUnit(object) or false,
          combatreach = combatreach or 0
        })
      end
    end
    for i = 0, pi * 2, (pi * 2) / steps do
      local count = 0
      local mainObjectHit = false
      for j = 1, #units do
        if units[j].dist - units[j].combatreach <= r then
          local angleToUnit = units[j].angleTo
          local angleDifference = i > angleToUnit and i - angleToUnit or angleToUnit - i
          local shortestAngle = angleDifference < pi and angleDifference or pi * 2 - angleDifference
          local finalAngle = shortestAngle / (pi / 180)
          if finalAngle < a / 2 then
            if object and units[j].mainObject then
              mainObjectHit = true
            end
            count = count + 1
          end
        end
      end
      if count > bestCount and (not object or mainObjectHit) then
        bestCount = count
        bestAngle = i
      end
    end
    return bestAngle, bestCount
  end,
  -- ListOfUnitsWithinListAroundPlayer
  within = function(list, dist)
    local objects = {}

    if not player then
      player = blink.player
    end

    -- nah probably better to just give back big ol list
    -- if unlockerType then return list end

    for i = 1, #list do
      local obj = list[i]
      if obj then
        local distance = obj.distance
        if distance and distance <= dist or dist == 0 and obj.meleeRange then
          objects[#objects + 1] = obj
        end
      end
    end

    blink.immerseOL(objects)

    return objects
  end,
  -- UnitsWithinListAroundUnit
  around = function(list, unit, dist, criteria)
    local objects = {}
    local criteriaGiven = criteria and type(criteria) == "function"
    local count, secondaryCount = 0, 0
    dist = dist or 5
    if not player then
      player = blink.player
    end
    local isMe = unit.pointer == player.pointer
    if isMe or unit.exists or #unit == 3 then
      -- table of coords passed
      if #unit == 3 then
        local x, y, z = unpack(unit)
        for i = 1, #list do
          local obj = list[i]
          local cr = list[i].combatReach
          if obj.distanceToLiteral(x, y, z) - cr <= dist then
            if criteriaGiven then
              if criteria(obj) then
                count = count + 1
                objects[#objects + 1] = obj
              end
              secondaryCount = secondaryCount + 1
            else
              count = count + 1
              objects[#objects + 1] = obj
            end
          else
          end
        end
      else
        -- object passed
        for i = 1, #list do
          local obj = list[i]
          if obj and unit.pointer ~= obj.pointer then
            local inRange
            if isMe and obj.initDist then
              inRange = obj.initDist - 4 <= dist
            elseif unit.distanceTo(obj) <= dist then
              inRange = true
            end
            if inRange then
              if criteriaGiven then
                if criteria(obj) then
                  count = count + 1
                  objects[#objects + 1] = obj
                end
                secondaryCount = secondaryCount + 1
              else
                count = count + 1
                objects[#objects + 1] = obj
              end
            end
          end
        end
      end
    end
    blink.immerseOL(objects)
    return count, secondaryCount, objects
  end,
  near = function(list, x, y, z, range)
    if type(x) == "table" then
      range = y
      x, y, z = x.position()
    end
    local objects = {}
    for i = 1, #list do
      local obj = list[i]
      local ox, oy, oz = obj.position()
      if blink.Distance(ox, oy, oz, x, y, z) <= range then
        objects[#objects + 1] = obj
      end
    end
    blink.immerseOL(objects)
    return objects
  end,
  -- IterateListOfUnits
  iterate = function(list, callback, options)
    local time = GetTime()
    options = options or {}

    if type(callback) ~= "function" then
      blink.print("error: invalid callback function in .loop method", true)
      return false
    end

    for i = 1, #list do
      local obj = list[i]
      local p2s = tostring(obj.truePointer)
      if not objectFirstDetected[p2s] then
        objectFirstDetected[p2s] = time
        if callback(obj, i, 0) then
          return true
        end
      else
        if not options.delay or time - objectFirstDetected[p2s] > options.delay then
          objectExistenceLastChecked[p2s] = time
          if callback(obj, i, time - objectFirstDetected[p2s]) then
            return true
          end
        end
      end
    end
  end,
  -- UnitsWithinListTargetingUnit
  targeting = function(list, unit, criteria)
    local criteriaGiven = true
    if not criteria then
      criteriaGiven = false
    elseif type(criteria) == "string" then
      local given = criteria
      criteria = function(obj)
        return obj.role == given or given == "cds" and obj.cds
      end
    elseif type(criteria) == "table" then
      local given = criteria
      criteria = function(obj)
        for _, check in ipairs(given) do
          if obj.role == check or check == "cds" and obj.cds then
            return true
          end
        end
      end
    end
    local count = 0
    local secondaryCount = 0
    for _, obj in ipairs(list) do
      if unit.exists and obj.target.isUnit(unit) then
        if criteriaGiven then
          if criteria(obj) then
            count = count + 1
          end
          secondaryCount = secondaryCount + 1
        else
          count = count + 1
        end
      end
    end
    return count, secondaryCount
  end,
  -- StompTotemsInList
  stomp = function(list, callback, options)
    local time = blink.time
    options = options or {}

    if not callback then
      blink.print("No callback function was passed to .stomp()!", true)
      return false
    end

    for _, totem in ipairs(list) do
      local hp = totem.hpLiteral
      local hpMax = totem.hpMax
      local p2s = tostring(totem.pointer)
      if hp > 1 then
        if not objectFirstDetected[p2s] then
          objectFirstDetected[p2s] = time
        else
          if not options.delay or time - objectFirstDetected[p2s] > options.delay then
            objectExistenceLastChecked[p2s] = time
            if callback(totem, time - objectFirstDetected[p2s]) then
              return true
            end
          end
        end
      end
    end
  end,
  -- TrackObjectsInList
  track = function(list, callback, options)
    local time = blink.time
    options = options or {}

    if not callback then
      blink.print("No callback function passed to .track()!", true)
      return false
    end

    for i = 1, #list do
      local obj = list[i]
      local p2s = tostring(obj.pointer)
      if not objectFirstDetected[p2s] then
        objectFirstDetected[p2s] = time
        if callback(obj, 0) then
          return true
        end
      else
        if not options.delay or time - objectFirstDetected[p2s] > options.delay then
          objectExistenceLastChecked[p2s] = time
          if callback(obj, time - objectFirstDetected[p2s]) then
            return true
          end
        end
      end
    end
  end,
  -- plus (add the two lists together)
  plus = function(list, list2)
    local newList = {}
    for i = 1, #list do
      newList[#newList + 1] = list[i]
    end
    for i = 1, #list2 do
      newList[#newList + 1] = list2[i]
    end
    blink.immerseOL(newList)
    return newList
  end
}

local objectLists = { "All", "objects", "dynamicObjects", "group", "fullGroup", "friends", "enemies", "allEnemies",
  "missiles", "enemyPets", "friendlyPets", "areaTriggers", "imps", "totems", "friendlyTotems",
  "wildseeds", "units", "players", "pets", "explosives", "incorporeals", "afflicteds", "shades", "rocks", "wwClones", "tyrants",
  "critters", "dead" }

local static = {
  player = true,
  target = true,
  focus = true,
  mouseover = true,
  pet = true
  -- arena1 = true,
  -- arena2 = true,
  -- arena3 = true,
  -- healer = true,
  -- enemyHealer = true,
}

local GetStaticObject = function(ref)
  if static[ref] then
    return Object(ref)
  elseif ref == "healer" then
    if blink.internal.group then
      for _, member in ipairs(blink.group) do
        if member.role == "healer" then
          return member.pointer
        end
      end
    end
  elseif ref == "tank" then
    if blink.internal.group then
      for _, member in ipairs(blink.group) do
        if member.role == "tank" then
          return member.pointer
        end
      end
    end
  elseif ref == "enemyHealer" then
    if blink.instanceType2 ~= "none" then
      if blink.internal.enemies then
        for _, enemy in ipairs(blink.enemies) do
          if enemy.role == "healer" and not enemy.dead then
            return enemy.pointer
          end
        end
      end
    end
  end
  return false
end

local objectFunctionCallbacks = {}
function blink.addObjectFunction(key, callback)
  objectFunctionCallbacks[key:lower()] = callback
end

blink.objectFunctionCallbacks = objectFunctionCallbacks

local objectAttributeCallbacks = {}
function blink.addObjectAttribute(key, callback)
  objectAttributeCallbacks[key:lower()] = callback
end

blink.objectAttributeCallbacks = objectAttributeCallbacks

local auraControlFrame = CreateFrame("Frame")
local Profiler = blink.Profiler
local profilerEnabled = Profiler.started

-- blink.pointers = {}

local lowers = {}
local keySelections = {}
local selectionFuncs = {
  casting = function(keyLower)
    if keyLower == "castint" or keyLower == "castinterruptible" or keyLower == "castinterruptable" then
      return "casting", 8
    elseif keyLower == "castid" or keyLower == "castingid" then
      return "casting", 9
    elseif keyLower == "cast" or keyLower == "casting" or keyLower == "castinginfo" then
      return "casting"
    end
  end,
  stundr = function(keyLower)
    if keyLower == "stundrr" or keyLower == "sdrr" or keyLower == "stundrremains" or keyLower == "stundrleft" then
      return "stundr", 2
    elseif keyLower == "stundr" or keyLower == "sdr" then
      return "stundr", 1
    end
  end,
  idr = function(keyLower)
    if keyLower == "incapdrr" or keyLower == "incapacitatedrr" or keyLower == "idrr" or keyLower == "incapdrremains" or
        keyLower == "incapacitatedrremains" or keyLower == "idrremains" then
      return "incapdr", 2
    elseif keyLower == "incapdr" or keyLower == "incapacitatedr" or keyLower == "idr" then
      return "incapdr", 1
    end
  end,
  ddr = function(keyLower)
    if keyLower == "disorientdrr" or keyLower == "disorientdrremains" or keyLower == "ddrr" or keyLower == "ddrremains" then
      return "disorientdr", 2
    elseif keyLower == "disorientdr" or keyLower == "ddr" then
      return "disorientdr", 1
    end
  end,
  rootdr = function(keyLower)
    if keyLower == "rootdrr" or keyLower == "rootdrremains" or keyLower == "rdrr" or keyLower == "rdrremains" then
      return "rootdr", 2
    elseif keyLower == "rootdr" or keyLower == "rdr" then
      return "rootdr", 1
    end
  end,
  silencedr = function(keyLower)
    if keyLower == "silencedrr" or keyLower == "silencedrremains" then
      return "silencedr", 2
    elseif keyLower == "silencedr" then
      return "silencedr", 1
    end
  end,
  stun = function(keyLower)
    if keyLower == "stunr" or keyLower == "stunremains" then
      return "stun", 2
    elseif keyLower == "stuninfo" then
      return "stun", 3
    elseif keyLower == "stun" or keyLower == "stunned" or keyLower == "isstunned" then
      return "stun", 1
    end
  end,
  incap = function(keyLower)
    if keyLower == "incapr" or keyLower == "incapremains" or keyLower == "incapacitateremains" or keyLower ==
        "incapacitater" then
      return "incap", 2
    elseif keyLower == "incapinfo" or keyLower == "incapacitateinfo" then
      return "incap", 3
    elseif keyLower == "incap" or keyLower == "incapped" or keyLower == "incapacitated" then
      return "incap", 1
    end
  end,
  disorient = function(keyLower)
    if keyLower == "disorientremains" or keyLower == "disorientr" then
      return "disorient", 2
    elseif keyLower == "disorientinfo" then
      return "disorient", 3
    elseif keyLower == "disorient" or keyLower == "disoriented" or keyLower == "isdisoriented" then
      return "disorient", 1
    end
  end,
  rooted = function(keyLower)
    if keyLower == "rootremains" or keyLower == "rootr" then
      return "root", 2
    elseif keyLower == "rootinfo" then
      return "root", 3
    elseif keyLower == "root" or keyLower == "rooted" or keyLower == "isrooted" then
      return "root", 1
    end
  end,
  silenced = function(keyLower)
    if keyLower == "silenceremains" or keyLower == "silencer" then
      return "silence", 2
    elseif keyLower == "silenceinfo" then
      return "silence", 3
    elseif keyLower == "silence" or keyLower == "silenced" or keyLower == "issilenced" then
      return "silence", 1
    end
  end
}

local directionTracker = {}
local LoSTracker = {}

local cache = {
  get = function(obj, key)
    if obj[key] ~= nil then
      return obj[key]
    end
  end,
  set = function(obj, key, value)
    obj.cacheLiteral[key] = true
    obj[key] = value
  end,
  memo = {}
}

local unitPrototype = {
  isUnit = function()
    return false
  end,
  hp = 100
}
blink.unitPrototype = unitPrototype

local function cacheReturnTemplate(key, keyLower, selection, obj, func, returnType, ...)
  if type(returnType) == "function" then
    local rt, ri = returnType(keyLower)
    local funct = type(func) == "string" and _ENV[func] or func
    local val = { funct(...) }
    local ret = val and val[ri or selection] or false
    obj[key] = ret
    obj.cacheLiteral[key] = ret
    return ret
  elseif type(returnType) == "number" then
    local funct = type(func) == "string" and _ENV[func] or func
    local val = { funct(...) }
    local ret = val and val[returnType] or false
    obj[key] = ret
    obj.cacheLiteral[key] = ret
    return ret
  elseif returnType == "single" then
    local funct = type(func) == "string" and _ENV[func] or func
    local val = funct(...)
    local ret = val or false
    obj[key] = ret
    obj.cacheLiteral[key] = ret
    return ret
  else
    local funct = type(func) == "string" and _ENV[func] or func
    local val = { funct(...) }
    local ret = val and val[selection] or false
    if selection == 1 then
      obj[key] = ret
      obj.cacheLiteral[key] = ret
    else
      obj[key .. selection] = ret
      obj.cacheLiteral[key .. selection] = ret
    end
    return ret
  end
end
blink.objectCacheReturnTemplate = cacheReturnTemplate

local objectsByGUID = {}
blink.objectsByGUID = objectsByGUID

blink.total = 0
function blink.createObject(object, ref, options)
  --if type(object) == "nil" or type(object) == "string" and (object == "" or not object) then return unitPrototype end
  if not object and type(ref) ~= "string" then
    return unitPrototype
  end

  -- wtf?
  if object == true then
    return
  end

  options = options or {}
  local objectType = type(object)
  local IsWoWGameObject = objectType == "userdata"
  options.IsWoWGameObject = IsWoWGameObject

  local guid =
  options.guid or IsWoWGameObject and tostring(object) or objectType ~= "nil" and objectType ~= "boolean" and
  UnitGUID(object) or "????"

  if type(ref) ~= "string" then
    local cachedObj = objectsByGUID[guid]
    if cachedObj then
      cachedObj.initOptions = options
      cachedObj.cache = {}
      for k, v in pairs(cachedObj.cacheLiteral) do
        cachedObj[k] = nil
      end
      cachedObj.cacheLiteral = {}
      if ref then
        if not blink.inserted[ref][cachedObj] then
          ref[#ref + 1] = cachedObj
          blink.inserted[ref][cachedObj] = true
        end
      end
      return cachedObj
    end
  end

  local objFunctions = {
    __index = function(self, key)
      -- blink.debuglog(key .. debugstack(3))

      local cacheReturn = self.cacheReturn
      local ogKey = key

      -- hypercached keys lolz
      local pointer = rawget(self, "truePointer")

      if key == "distance" or key == "dist" then
        if not player then
          player = blink.player
        end
        return cacheReturn(key, key, 1, self.distanceTo, "single", player)
      end

      IsWoWGameObject = type(pointer) == "userdata"


      -- key = key:gsub("_", "")
      local selection = keySelections[key] ~= nil and keySelections[key] or key and key:match("%d+")
      local selectionGiven
      if selection then
        keySelections[key] = selection
        key = key:gsub(selection, "")
        selection = tonumber(selection)
        selectionGiven = true
      else
        keySelections[key] = false
        selection = 1
        selectionGiven = false
      end

      -- even permacaching lowercase representations of keys in memory
      local keyLower = lowers[key]
      if not keyLower then
        lowers[key] = key:lower()
        keyLower = lowers[key]
      end

      -- if ref and not pointer then return false end

      -- FIXME rate limit this Object call to once per tick
      if ref == "mouseover" then
        local o = Object("mouseover")
        if pointer ~= o then
          self.truePointer = o
          pointer = o
        end
      end

      local ofcb = objectFunctionCallbacks[keyLower]
      if ofcb then
        return function(...)
          return ofcb(self, ...)
        end
      end

      local oacb = objectAttributeCallbacks[keyLower]
      if oacb then
        return oacb(self)
      end

      local func
      if keyLower == "pointer" or keyLower == "unit" then
        func = function()
          return pointer
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "x" or keyLower == "y" or keyLower == "z" then
        if self.cachedPosition then
          return keyLower == "x" and self.cachedPosition[1] 
              or keyLower == "y" and self.cachedPosition[2] 
              or self.cachedPosition[3]
        end
        local x, y, z = self.position()
        return keyLower == "x" and x or keyLower == "y" and y or z
      elseif keyLower == "cast" or keyLower == "casting" or keyLower == "castinginfo" or keyLower == "castid" or
          keyLower == "castingid" or keyLower == "castint" or keyLower == "castinterruptible" or keyLower ==
          "castinterruptable" then
        if not pointer then
          return false
        end
        func = selectionFuncs.casting
        return cacheReturn(ogKey, keyLower, selection, UnitCastingInfo, func, pointer)
      elseif keyLower == "position" then
        return self.position
      elseif keyLower == "ttd" then
        return self.TimeToDie()
      elseif keyLower == "charmed" then
        if not pointer then
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, UnitIsCharmed, "single", pointer)
      elseif keyLower == "cds" or keyLower == "bursting" or keyLower == "isbursting" or keyLower == "cdsup" or keyLower ==
          "bigmode" then
        return cacheReturn(ogKey, keyLower, selection, self.buffFrom, "single", blink.cooldowns.offensive)
      elseif keyLower == "debuffs" then
        return self["debuffcache"] or self:CacheAuras("debuff")
      elseif keyLower == "visible" or keyLower == "exists" then
        if not pointer then
          return false
        end
        local otype = self.type
        if otype and otype ~= 5 and otype ~= 6 then
          return true
        end
        return cacheReturn(ogKey, keyLower, selection, UnitIsVisible, "single", pointer)
      elseif keyLower == "carryingflag" or keyLower == "hasflag" then
        func = function()
          return self.buffFrom(blink.pvpFlags)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "hiddenauras" then
        return blink.HiddenAuras(pointer)
      elseif keyLower == "buffs" then
        return self["buffcache"] or self:CacheAuras("buff")
      elseif keyLower == "movingtoward" or keyLower == "movingtowards" then
        return self.movingToward
      elseif keyLower == "classliteral" then
        return self.class2
      elseif keyLower == "mindgamesremains" or keyLower == "mgr" then
        local remains = 0
        for _, debuff in ipairs(self.debuffs) do
          if debuff[10] == 375901 then
            remains = remains + debuff[20]
          end
        end
        return remains
      elseif keyLower == "dead" then
        if not pointer then
          return false
        end
        if not self.exists then
          return false
        end
        return UnitIsDeadOrGhost(pointer) and not self.buff(5384)
      elseif keyLower == "falling" or keyLower == "isfalling" then
        if pointer == blink.player.pointer then
          return IsFalling()
        end
        return IsFalling(pointer)
      elseif keyLower == "race" then
        return UnitRace(self.pointer)
      elseif keyLower == "raceid" then
        return select(3, UnitRace(self.pointer))
      elseif keyLower == "name" then
        return IsWoWGameObject and pointer:name() or
            cacheReturn(ogKey, keyLower, selection, ObjectName, "single", pointer)
      elseif keyLower == "dragonspeed" or keyLower == "dspeed" then
        local horizontal, vertical 
        if GetDragonridingSpeed then
          horizontal, vertical = GetDragonridingSpeed(pointer)
        else
          horizontal = select(3, C_PlayerInfo.GetGlidersInfo())
          vertical = 0
        end
        return {
          horizontal = horizontal,
          vertical = vertical
        }
      elseif keyLower == "classification" then
        return cacheReturn(ogKey, keyLower, selection, UnitClassification, "single", pointer)
      elseif keyLower == "effects" then
        if not self.exists then
          return {}
        end
        if UnitEffects then
          local effects = UnitEffects(pointer)
          for _, effect in ipairs(effects) do
            effect.position = function()
              return effect.x, effect.y, effect.z
            end
          end
          blink.immerseOL(effects)
          return effects
        end
        return {}
      elseif keyLower == "spec" or keyLower == "specialization" then
        local unlockedSpec = GetSpecializationString(self.pointer)
        if type(unlockedSpec) == "string" then
          return unlockedSpec
        end
        if GetArenaOpponentSpec then
          for i = 1, GetNumArenaOpponents() do
            if self.isUnit(blink["arena" .. i]) then
              local spec = GetArenaOpponentSpec(i)
              if spec then
                return select(2, GetSpecializationInfoByID(spec))
              end
            end
          end
        end
        local LibInspect = blink.LibInspect
        if not LibInspect then
          return false
        end
        local guid = self.guid
        if not guid then
          return false
        end
        LibInspect:Rescan(guid)
        local cache = LibInspect:GetCachedInfo(guid)
        if cache and cache.spec_name_localized then
          return cache.spec_name_localized
        end
        return "Unknown"
      elseif keyLower == "specid" then
        return GetSpecializationID(self.pointer)
      elseif keyLower == "inspect" or keyLower == "inspectinfo" then
        local LibInspect = blink.LibInspect
        if not LibInspect then
          return false
        end
        local guid = self.guid
        if not guid then
          return false
        end
        LibInspect:Rescan(guid)
        return LibInspect:GetCachedInfo(guid)
      elseif keyLower == "distanceto" or keyLower == "distancefrom" or keyLower == "distancetounit" or keyLower ==
          "distancefromunit" then
        return self.distanceTo
      elseif keyLower == "timesincedirectionchange" then
        local check = function()
          local time = blink.time
          local since = 999
          local guid = self.guid
          if not guid then
            return since
          end
          local rotation = self.rotation
          if not rotation then
            return since
          end
          if not directionTracker[guid] then
            directionTracker[guid] = {}
          end
          tinsert(directionTracker[guid], {
            dir = rotation,
            time = time
          })
          for i = 1, #directionTracker[guid] do
            if abs(directionTracker[guid][i].dir - rotation) > 0.03 then
              return time - directionTracker[guid][i].time
            end
          end
          return since
        end
        return cacheReturn(ogKey, keyLower, selection, check, "single")
      elseif keyLower == "immunestuns" or keyLower == "immunestun" then
        return blink.ImmuneCC(self, "stun")
      elseif keyLower == "buffcount" then
        local func = function()
          local count = 0
          for i = 1, #self.buffs do
            count = count + 1
          end
          return count
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "debuffcount" then
        func = function()
          local count = 0
          for i = 1, #self.debuffs do
            count = count + 1
          end
          return count
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "mainhandenchant" then
        func = function()
          local isEnchanted = select(4, GetWeaponEnchantInfo())
          return isEnchanted
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "mainhandenchantremains" then
        func = function()
          local expires = select(2, GetWeaponEnchantInfo())
          if expires then
            return expires / 1000
          else
            return 0
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "offhandenchant" then
        func = function()
          return select(8, GetWeaponEnchantInfo())
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "offhandenchantremains" then
        func = function()
          local expires = select(6, GetWeaponEnchantInfo())
          if expires then
            return expires / 1000
          else
            return 0
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "shouldspellsteal" then
        local steal = { 190319, -- combust
          210294, -- divine favor
          29166, -- innervate
          114108, -- soul of the forest
          204361, -- shamanism bloodlust
          204362, -- shamanism heroism
          132158, -- NS
          10060, -- power infusion
          213610, -- holy wardje
          212295, -- nether wardje
          339784 -- tyrant's soul
        }
        func = function()
          local buffs = self.buffs
          for index, buff in ipairs(buffs) do
            if buff[4] ~= "Magic" then
              tremove(buffs, index)
            end
          end
          if #buffs == 0 then
            return
          end
          local player = blink.player
          -- only do a coin toss if we're gonna be completely oom...
          if player.manapct < 38 and self.purgeCount > 2 then
            return
          end

          local combusting = player.buff(190319)
          -- not even worth trying when they have 7+ buffs...
          if #buffs > 7 - bin(combusting) * 4 then
            return
          end
          local function enoughMana(spellID)
            if spellID == 339784 and player.manapct < 45 and #buffs > 2 then
              return false
            end
            if spellID == 114108 and player.manapct < 60 and #buffs > 1 then
              return false
            end
            if spellID == 190319 and combusting and #buffs > 1 then
              return false
            end
            -- hward
            if spellID == 213610 and player.manapct < 68 and #buffs > 2 then
              return false
            end
            return true
          end
          -- bop (at least one melee on our team, or at least one melee targeting player)
          if self.buff(1022) and (not combusting or self.hp > 40 or self.purgeCount <= 2 and self.hp > 25) then
            local meleeOnTeam = false
            blink.group.loop(function(member)
              if not member.melee then
                return
              end
              meleeOnTeam = true
              return true
            end)
            if meleeOnTeam or select(2, player.v2attackers()) > 0 then
              return "Blessing of Protection"
            end
          end
          -- important buffs
          for _, buff in ipairs(buffs) do
            if tContains(steal, buff[10]) then
              if enoughMana(buff[10]) then
                return buff[1]
              end
            end
          end
          -- mark of the wild on kill target
          if blink.target.exists and self.isUnit(blink.target) and player.manapct > 70 then
            if self.buff(289318) then
              return "Mark of the Wild"
            end
          end
          -- steal freedoms when fighting ret melee teams
          if self.purgeCount <= 3 - bin(combusting) * 1 - bin(player.manapct < 80) * 1 - bin(player.manapct < 55) * 1 and
              select(4, self.buff(1044)) == "Magic" then
            return "Freedom"
          end
          -- pred swiftness feral when free
          if self.purgeCount <= 2 - bin(combusting) * 2 and player.manapct > 60 and self.buff("predatory swiftness") then
            return "Predatory Swiftness"
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "shouldtranq" then
        local steal = { 190319, -- combust
          210294, -- divine favor
          29166, -- innervate
          114108, -- soul of the forest
          204361, -- shamanism bloodlust
          204362, -- shamanism heroism
          132158, -- nature's swiftness
          110909, -- alter time
          305497, -- thorns
          213610, -- holy ward
          1022, -- bop
          212295 -- nether wardz
        }
        func = function()
          local buffs = self.buffs
          for index, buff in ipairs(buffs) do
            if buff[4] ~= "Magic" then
              tremove(buffs, index)
            end
          end
          if #buffs == 0 then
            return
          end
          -- important buffs
          for _, buff in ipairs(buffs) do
            if tContains(steal, buff[10]) then
              return buff[1]
            end
          end
          -- steal freedoms when fighting ret melee teams
          if select(4, self.buff(1044)) == "Magic" then
            return "Freedom"
          end
          -- pred swiftness feral when free
          if self.purgeCount <= 3 and self.buff("predatory swiftness") then
            return "Predatory Swiftness"
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "magicbuffcount" or keyLower == "purgecount" then
        local buffs = self.buffs
        local count = 0
        for i = 1, #buffs do
          if buffs[i] and buffs[i][4] == "Magic" then
            count = count + 1
          end
        end
        return count
      elseif keyLower == "enragebuffcount" or keyLower == "enragecount" then
        local buffs = self.buffs
        local count = 0
        for i = 1, #buffs do
          if buffs[i] and buffs[i][4] == "" then -- Enrage is an empty string cuz small indie dev company
            count = count + 1
          end
        end
        return count
      elseif keyLower == "channeltimeleft" or keyLower == "channelremains" then
        func = function()
          local remains = self.channel and ((self.channel5 - blink.time * 1000) / 1000) - blink.latency
          return remains and remains > 0 and remains or 0
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "type" then
        return ObjectType(pointer)
      elseif keyLower == "attackspeed" then
        return cacheReturn(ogKey, keyLower, selection, UnitAttackSpeed, "single", pointer)
      elseif keyLower == "swingtimer" then
        func = function()
          local speed = self.attackspeed
          if not speed then
            return 0, 0
          end
          local guid = self.guid
          if not guid then
            return 0, 0
          end

          local time, history = blink.time, blink.swingTracker
          local mainTimer, offTimer = 0, 0
          local parryHasted = false

          local isPaladin = self.class2 == "PALADIN"
          local hasCrusader = isPaladin and self.buff("Seal of the Crusader")
          local cmod = 100 / 60

          for i = 1, #history do
            local tracker = blink.swingTracker[i]
            if tracker.guid == guid then
              local elapsed = blink.time - tracker.time
              local adjusted = speed
              -- explicit bool
              local hadCrusader = tracker.crusader or false

              if isPaladin then
                if hadCrusader and not hasCrusader then
                  adjusted = adjusted * 0.6
                  blink.debug.print("|cFFaeff45Adjusted for Seal of Crusader", "swing")
                end
                if hadCrusader == false and hasCrusader then
                  adjusted = adjusted * cmod
                end
              end

              if tracker.miss == "PARRY" then
                adjusted = adjusted * 0.2
                if elapsed <= adjusted + 0.2 then
                  blink.debug.print("|cFFaeff45Adjusted for Parry Hasting", "swing")
                  parryHasted = true
                  mainTimer = adjusted - elapsed
                  break
                end
              else
                if elapsed <= adjusted and (not parryHasted or elapsed > adjusted * 0.2) then
                  if tracker.isOffhand then
                    if offTimer == 0 then
                      offTimer = adjusted - elapsed
                    end
                  elseif mainTimer == 0 then
                    mainTimer = adjusted - elapsed
                  end
                end
              end
            end
          end
          return mainTimer, offTimer
        end
        return cacheReturn(ogKey, keyLower, selection, func, "multi", pointer)
      elseif keyLower == "beast" or keyLower == "isbeast" or keyLower == "beastcheck" or keyLower == "immunepoly" or keyLower == "polyimmune" or keyLower == "immunesheep" or keyLower == "sheepimmune" or keyLower == "immunetosheep" or keyLower == "immunetopoly" then
        func = function()
          local buffs = self.buffs
          if not buffs then
            return false
          end

          local memo = cache.memo
          if not memo.beast_buffs then
            memo.beast_buffs = {
              refresh_after = 30,
              [768] = true,   -- Cat
              [783] = true,   -- Travel
              [33891] = true, -- Tree
              [117679] = true, -- Tree (Talent Proc)
              [24858] = true, -- Moonkin
              [197625] = true -- Balance Affinity Moonkin
            }
          end
          local beastIds = memo.beast_buffs

          local nbuffs = #buffs
          local confirmed = true

          for i=1,nbuffs do
            local buff = buffs[i]
            if buff then
              local id = buff[10]
              local state = beastIds[id]
              if state then
                return id
              elseif state == nil then
                confirmed = false
              end
            end
          end

          if confirmed then return end

          local desc = self.buffDescriptions
          for i=1,#desc do
            local str = desc[i]
            local buff = buffs[i]
            if not buff then
              break
            end
            local lower = str:lower()
            -- print(lower)
            local buffId = buff[10]
            if lower:match("immune to polymorph") then
              beastIds[buffId] = true
              return buffId
            else
              beastIds[buffId] = false
            end
          end
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "id" or keyLower == "objectid" then
        if not pointer then
          return 0
        end
        if not self.exists then
          return 0
        end
        local getId = function()
          local ok, id = pcall(ObjectID, pointer)
          return ok and id or 0
        end
        return IsWoWGameObject and pointer:id() or cacheReturn(ogKey, keyLower, selection, getId, "single")
      elseif keyLower == "immunehealing" or keyLower == "immunetohealing" then
        return cacheReturn(ogKey, keyLower, selection, blink.ImmuneHealing, "single", self)
      elseif keyLower == "healingimmunityremains" then
        return cacheReturn(ogKey, keyLower, selection, blink.ImmuneHealing, "single", self, true)
      elseif keyLower == "immunemagicinfo" then
        local func = function(options)
          return blink.ImmuneMagic(self, options)
        end
        return func
      elseif keyLower == "immunephysicalinfo" then
        return function(options)
          return blink.ImmunePhysical(self, options)
        end
      elseif keyLower == "immunephysicaleffects" then
        if options.totem then
          return false
        end
        local func = function(options)
          local dmg, effects = blink.ImmunePhysical(self, options)
          if effects.spell then
            return true
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "immunemagiceffects" then
        if options.totem then
          return false
        end
        local func = function()
          local dmg, effects = blink.ImmuneMagic(self)
          if effects.spell then
            return true
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "ccimmunityremains" then
        if options.totem then
          return 0
        end
        local func = function()
          local immune, remains = blink.ImmuneCC(self)
          return remains
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "immunecc" then
        if options.totem then
          return false
        end
        local func = function()
          local immune, remains = blink.ImmuneCC(self)
          return immune
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "magicdamageimmunityremains" or keyLower == "mdir" then
        if options.totem then
          return 0
        end
        local func = function()
          local dmg, effects = blink.ImmuneMagic(self)
          return max(dmg.remains, dmg.targeted.remains)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "physicaldamageimmunityremains" then
        if options.totem then
          return 0
        end
        local func = function()
          local dmg, effects = blink.ImmunePhysical(self)
          return max(dmg.remains, dmg.targeted.remains)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "magiceffectimmunityremains" then
        if options.totem then
          return 0
        end
        local func = function()
          local dmg, effects = blink.ImmuneMagic(self)
          return max(effects.remains, effects.targeted.remains)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "physicaleffectimmunityremains" then
        if options.totem then
          return 0
        end
        local func = function()
          local dmg, effects = blink.ImmunePhysical(self)
          return max(effects.remains, effects.targeted.remains)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "immunemagicdamage" then
        if options.totem then
          return false
        end
        local func = function()
          local dmg, effects = blink.ImmuneMagic(self)
          if dmg.spell then
            return true
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "immunephysicaldamage" then
        if options.totem then
          return false
        end
        local func = function()
          local dmg, effects = blink.ImmunePhysical(self)
          if dmg.spell then
            return true
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "immunemagic" then
        if options.totem then
          return false
        end
        local func = function()
          local dmg, effects = blink.ImmuneMagic(self)
          if dmg.spell or effects.spell then
            return true
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "immunephysical" then
        if options.totem then
          return false
        end
        local func = function()
          local dmg, effects = blink.ImmunePhysical(self)
          if dmg.spell or effects.spell then
            return true
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "cd" or keyLower == "cooldown" or keyLower == "spellcd" or keyLower == "spellcooldown" or keyLower == "getcooldown" or
          keyLower == "getspellcooldown" then
        local func = function(spellID)
          if type(spellID) == "string" then
            spellID = spellID:lower()
            local cd = 0
            local tracker = blink.CooldownTracker[tostring(self.pointer)]
            if tracker then
              for k, v in pairs(tracker) do
                local name = GetSpellInfo(k)
                if name and name:lower() == spellID then
                  -- if tracker[k.."chargeInfo"] then
                  -- 	local cinfo = tracker[k.."chargeInfo"]
                  -- 	local maxCharges, usage, baseCD = cinfo.maxCharges, cinfo.usage, cinfo.baseCD
                  -- 	local chargesFrac = maxCharges
                  -- 	local tracked = false

                  -- 	for i=#usage, 0, -1 do
                  -- 		local t = usage[i]
                  -- 		local dd = t - blink.time
                  -- 		if dd > 0 then
                  -- 			-- print(maxCharges, chargesFrac, chargesFrac - (1 - dd/baseCD), dd, baseCD, dd/baseCD)
                  -- 			if not tracked then
                  -- 				chargesFrac = chargesFrac - 1
                  -- 				chargesFrac = chargesFrac + (1 - dd/baseCD)
                  -- 			end
                  -- 			-- print(chargesFrac)
                  -- 		end
                  -- 	end
                  -- 	print(chargesFrac)
                  -- 	if chargesFrac >= 1 then
                  -- 		return 0
                  -- 	else
                  -- 		return baseCD * (1 - chargesFrac)
                  -- 	end
                  -- else
                  -- 	print("defret")
                  return v - blink.time
                  -- end
                end
              end
            end
            return cd
          else
            local cd = 0
            local tracker = blink.CooldownTracker[tostring(self.pointer)]
            if tracker and tracker[spellID] then
              cd = tracker[spellID] - blink.time
            end
            return cd
          end
        end
        return func
      elseif ref == "player" and keyLower == "timestandingstill" then
        return playerTimeStandingStill()
      elseif keyLower == "gcdremains" or keyLower == "gcdduration" then
        local func = function()
          local cd = 0
          local tracker = blink.GCDTracker[tostring(self.pointer)]
          if tracker then
            cd = tracker - blink.time
          end
          return cd
        end
        return func()
      elseif ref == "player" and keyLower == "resting" then
        return IsResting()
      elseif keyLower == "facing" or keyLower == "facingunit" or keyLower == "isfacing" or keyLower == "facingtowards" then
        return self.facingUnit
      elseif keyLower == "faction" then
        return cacheReturn(ogKey, keyLower, selection, UnitFactionGroup, "single", pointer)
      elseif keyLower == "amifacing" or keyLower == "iamfacing" or keyLower == "imfacing" or keyLower == "playerfacing" or
          keyLower == "playerisfacing" then
        return blink.player.facingUnit(self, selectionGiven and selection or 180)
      elseif keyLower == "facingunit" or keyLower == "facingobject" then
        return self.facingUnit
      elseif keyLower == "meleerangeof" or keyLower == "meleerangeto" or keyLower == "meleerangefrom" then
        return self.meleeRangeOf
      elseif keyLower == "guid" then
        if IsWoWGameObject then
          return pointer:guid()
        else
          if ref == "player" then
            return UnitGUID("player")
          end
          if not pointer then
            return nil
          end
          return cacheReturn(ogKey, keyLower, selection, UnitGUID, "single", pointer)
        end
      elseif keyLower == "prevgcd" or keyLower == "previousgcd" or keyLower == "lastcast" then
        local p2s = tostring(pointer)
        local sut = blink.SpellUseTracker[p2s]
        if sut then
          for _, spell in ipairs(sut) do
            return spell.id
          end
        end
        -- elseif keyLower == "position" then
        -- 	return self.getPosition
      elseif keyLower == "channel" or keyLower == "channeling" or keyLower == "channelid" or keyLower == "channelingid" or
          keyLower == "channelint" then
        if not pointer then
          return false
        end
        local selectionFunc = function()
          if keyLower == "channelint" then
            return "channeling", 7
          elseif keyLower == "channelid" or keyLower == "channelingid" then
            return "channeling", 8
          elseif keyLower == "channel" or keyLower == "channeling" then
            return "channeling"
          end
        end
        return cacheReturn(ogKey, keyLower, selection, UnitChannelInfo, selectionFunc, pointer)
      elseif keyLower == "speed" or keyLower == "movespeed" or keyLower == "movementspeed" or keyLower == "getspeed" then
        local speedFunc = function()
          if self.exists then
            return GetUnitSpeed(pointer)
          else
            return 0, 0, 0, 0, 0, 0, 0, 0 -- idk lol
          end
        end
        return cacheReturn(ogKey, keyLower, selection, speedFunc, "multi")
      elseif keyLower == "tapped" then
        return cacheReturn(ogKey, keyLower, selection, UnitIsTapDenied, "single")
      elseif keyLower == "los" or keyLower == "islos" or keyLower == "loscheck" then
        if ref == "player" then
          return true
        end
        local res = cacheReturn(ogKey, keyLower, selection, self.losOf, "single")
        if pointer then
          if not LoSTracker[pointer] then
            LoSTracker[pointer] = { {
              time = GetTime(),
              los = res
            } }
          else
            local tracker = LoSTracker[pointer]
            if #tracker == 0 or tracker[#tracker].los ~= res then
              tinsert(tracker, {
                time = GetTime(),
                los = res
              })
            end
          end
        end
        return res
      elseif keyLower == "casttarget" or keyLower == "spelltarget" or keyLower == "castingtarget" then
        local func = function(...)
          local ct = ObjectCastingTarget(...)
          if ct then
            return blink.createObject(ct)
          else
            return {
              isUnit = function()
                return false
              end
            }
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single", pointer)
      elseif keyLower == "losliteral" then
        return cacheReturn(ogKey, keyLower, selection, self.losOfLiteral, "single")
      elseif keyLower == "started" then
        local function did(spellID, elapsed)
          elapsed = elapsed or 1
          local p2s = tostring(pointer)
          local sut = blink.CastStartedTracker[p2s]
          if sut then
            local time = blink.time
            if type(spellID) == "string" then
              local spellName = GetSpellInfo(spellID)
              if spellName then
                spellName = spellName:lower()
                for i = 1, #sut do
                  local id = sut[i].id
                  if time - sut[i].time <= elapsed and id then
                    local name = GetSpellInfo(id)
                    if name and name:lower() == spellName then
                      return id
                    end
                  end
                end
              end
            elseif type(spellID) == "table" then
              for _, id in ipairs(spellID) do
                for i = 1, #sut do
                  local spell = sut[i]
                  if spell.id == id and time - spell.time <= elapsed then
                    return id
                  end
                end
              end
            else
              for i = 1, #sut do
                local spell = sut[i]
                if spell.id == spellID and time - spell.time <= elapsed then
                  return spell.id
                end
              end
            end
          end
        end
        return did
      elseif keyLower == "recentlyused" or keyLower == "usedrecently" or keyLower == "recentlycast" or keyLower ==
          "recentcast" or keyLower == "recent" or keyLower == "used" then
        local function did(spellID, elapsed)
          elapsed = elapsed or 1
          local p2s = tostring(pointer)
          local sut = blink.SpellUseTracker[p2s]
          if sut then
            local time = blink.time
            if type(spellID) == "string" then
              local spellName = GetSpellInfo(spellID)
              if spellName then
                spellName = spellName:lower()
                for i = 1, #sut do
                  local id = sut[i].id
                  if time - sut[i].time <= elapsed and id then
                    local name = GetSpellInfo(id)
                    if name and name:lower() == spellName then
                      return id
                    end
                  end
                end
              end
            elseif type(spellID) == "table" then
              for _, id in ipairs(spellID) do
                for i = 1, #sut do
                  local spell = sut[i]
                  if spell.id == id and time - spell.time <= elapsed then
                    return id
                  end
                end
              end
            else
              for i = 1, #sut do
                local spell = sut[i]
                if spell.id == spellID and time - spell.time <= elapsed then
                  return spell.id
                end
              end
            end
          end
        end
        return did
      elseif keyLower == "attackers" or keyLower == "enemiesattacking" or keyLower == "enemiestargeting" or keyLower ==
          "enemieson" or keyLower == "enemiesfocusing" then
        local enemiesAttacking = function()
          local count, melee, ranged, cds = 0, 0, 0, 0
          local unitEnemies = {}
          if self.enemy then
            for i = 1, #blink.friends do
              unitEnemies[#unitEnemies + 1] = blink.friends[i]
            end
            tinsert(unitEnemies, blink.player)
          else
            unitEnemies = blink.enemies
          end
          local arena = blink.arena
          for _, enemy in ipairs(unitEnemies) do
            if (not arena or enemy.isPlayer) and not enemy.isHealer then
              if enemy.target and enemy.target.isUnit(self) then
                if enemy.ccRemains < 0.5 and
                    (keyLower == "enemiestargeting" or enemy.role == 'melee' and enemy.distanceTo(self) < 9 or enemy.role ==
                    'ranged' and enemy.distanceTo(self) < 40) then
                  count = count + 1
                  melee = melee + bin(enemy.role == 'melee')
                  ranged = ranged + bin(enemy.role == 'ranged')
                  cds = cds + bin(enemy.cds)
                end
              end
            end
          end
          return count, melee, ranged, cds
        end
        return cacheReturn(ogKey, keyLower, selection, enemiesAttacking, "multi")
      elseif keyLower == "role" or keyLower == "getrole" then
        return cacheReturn(ogKey, keyLower, selection, blink.GetUnitRole, "single", self)
      elseif keyLower == "debuff" and selectionGiven then
        return self.debuffcache and self.debuffcache[selection] or self:CacheAuras("debuff")[selection]
      elseif keyLower == "buff" and selectionGiven then
        return self.buffcache and self.buffcache[selection] or self:CacheAuras("buff")[selection]
      elseif keyLower == "stealth" or keyLower == "isstealth" or keyLower == "isstealthed" or keyLower == "stealthed" or keyLower == "stealthcheck" then
        func = function()
          local buffs = self.buffs
          if not buffs then
            return false
          end

          local memo = cache.memo
          if not memo.stealth_buffs then
            memo.stealth_buffs = {
              refresh_after = 30,
              [5215] = true,    --Prowl
              [1784] = true,    --Stealth
              [1856] = true,    --Vanish
              [115191] = true,  --New Rogue Stealth
              [114018] = true,  --Mass Stealth
              [110960] = true,  --Greater Invis
              [115193] = true,  --Old Vanish
              [119032] = true,  --Spectral Guise
              [66] = true,      --Mage going Invis
              [198158] = true,  --Mass Invis
              [32612] = true,   --New Mage Invis
              [11327] = true,   --New Vanish
              [199483] = true,  --Camo
            }
          end
          local stealthIds = memo.stealth_buffs

          local nbuffs = #buffs
          local confirmed = true

          for i=1,nbuffs do
            local buff = buffs[i]
            if buff then
              local id = buff[10]
              local state = stealthIds[id]
              if state then
                return id
              elseif state == nil then
                confirmed = false
              end
            end
          end

          if confirmed then return end

          local desc = self.buffDescriptions
          for i=1,#desc do
            local str = desc[i]
            local buff = buffs[i]
            if not buff then
              break
            end
            local lower = str:lower()
            -- print(lower)
            local buffId = buff[10]
            if lower:match("stealthed.") or lower:match("stealth.") or lower:match("invisible") or str:match("Fading.") then
              if not lower:match("as though you were") and buffId ~= 185422 and buffId ~= 386270 and buffId ~= 121153 then
                stealthIds[buffId] = true
                return buffId
              else
                stealthIds[buffId] = false
              end
            else
              stealthIds[buffId] = false
            end
          end
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "creator" then
        func = function()
          local creator = ObjectCreator(pointer)
          if not creator then
            return unitPrototype
          end
          return blink.createObject(creator)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "creaturetype" or keyLower == "ctype" then
        local func = function()
          local creatureTypes = blink.creatureTypes
          local ObjectCreatureType = ObjectCreatureType
          local ctype = IsWoWGameObject and creatureTypes[pointer:creatureType() or #creatureTypes] or
              ObjectCreatureType and creatureTypes[ObjectCreatureType(pointer) or #creatureTypes] or
              UnitCreatureType(pointer)
          return ctype or "None"
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "immuneslow" or keyLower == "immuneslows" or keyLower == "slowimmune" or keyLower == "immunetoslow" or keyLower == "slowimmunecheck" then
        func = function()
          local buffs = self.buffs
          if not buffs then
            return false
          end

          local memo = cache.memo
          if not memo.slow_immune_buffs then
            memo.slow_immune_buffs = {
              refresh_after = 30
            }
          end
          local slowImmuneIds = memo.slow_immune_buffs

          local nbuffs = #buffs
          local confirmed = true

          for i=1,nbuffs do
            local buff = buffs[i]
            if buff then
              local id = buff[10]
              local state = slowImmuneIds[id]
              if state then
                return id
              elseif state == nil then
                confirmed = false
              end
            end
          end

          if confirmed then return end

          local desc = self.buffDescriptions
          for i=1,#desc do
            local str = desc[i]
            local buff = buffs[i]
            if not buff then
              break
            end
            local lower = str:lower()
            -- print(lower)
            local buffId = buff[10]
            if (lower:match("movement impairing effects") and lower:match("immune to")) or lower:match("immune to crowd control") then 
              slowImmuneIds[buffId] = true
              return buffId
            else
              slowImmuneIds[buffId] = false
            end
          end
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "slowremains" then
        func = function()
          local debuffs = self.debuffs
          if not debuffs then
            return false
          end

          local memo = cache.memo
          if not memo.slow_debuffs then
            memo.slow_debuffs = {
              refresh_after = 30
            }
          end
          local slowIds = memo.slow_debuffs

          local ndebuffs = #debuffs
          
          local confirmed, remains = true, 0
          for i=1,ndebuffs do
            local debuff = debuffs[i]
            if debuff then
              local id = debuff[10]
              local state = slowIds[id]
              if state then
                local r = debuff[6] - blink.time
                if r > remains then 
                  remains = r
                end
              elseif state == nil then
                confirmed = false
              end
            end
          end

          if confirmed then 
            return remains
          end

          local desc = self.debuffDescriptions
          for i=1,#desc do
            local str = desc[i]
            local debuff = debuffs[i]
            if not debuff then
              break
            end
            local lower = str:lower()
            local debuffId = debuff[10]
            if str:match("ovement slowed by") or str:match("ovement speed slowed by") or str:match("peed reduced") then
              slowIds[debuffId] = true
              local r = debuff[6] - blink.time
              if r > remains then 
                remains = r
              end
            else
              slowIds[debuffId] = false
            end
          end
          return remains
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "slowed" or keyLower == "isslowed" or keyLower == "slow" or keyLower == "slowcheck" then
        func = function()
          local debuffs = self.debuffs
          if not debuffs then
            return false
          end

          local memo = cache.memo
          if not memo.slow_debuffs then
            memo.slow_debuffs = {
              refresh_after = 30
            }
          end
          local slowIds = memo.slow_debuffs

          local ndebuffs = #debuffs
          
          local confirmed = true
          for i=1,ndebuffs do
            local debuff = debuffs[i]
            if debuff then
              local id = debuff[10]
              local state = slowIds[id]
              if state then
                return id
              elseif state == nil then
                confirmed = false
              end
            end
          end

          if confirmed then 
            return false
          end

          local desc = self.debuffDescriptions
          for i=1,#desc do
            local str = desc[i]
            local debuff = debuffs[i]
            if not debuff then
              break
            end
            local lower = str:lower()
            local debuffId = debuff[10]
            if str:match("ovement slowed by") or str:match("ovement speed slowed by") or str:match("peed reduced") then
              slowIds[debuffId] = true
              return debuffId
            else
              slowIds[debuffId] = false
            end
          end
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "disarmremains" then
        func = function()
          local debuffs = self.debuffs
          if not debuffs then
            return false
          end

          local memo = cache.memo
          if not memo.disarm_debuffs then
            memo.disarm_debuffs = {
              refresh_after = 30
            }
          end
          local disarmIds = memo.disarm_debuffs

          local ndebuffs = #debuffs
          
          local confirmed, remains = true, 0
          for i=1,ndebuffs do
            local debuff = debuffs[i]
            if debuff then
              local id = debuff[10]
              local state = disarmIds[id]
              if state then
                local r = debuff[6] - blink.time
                if r > remains then 
                  remains = r
                end
              elseif state == nil then
                confirmed = false
              end
            end
          end

          if confirmed then 
            return remains
          end

          local desc = self.debuffDescriptions
          for i=1,#desc do
            local str = desc[i]
            local debuff = debuffs[i]
            if not debuff then
              break
            end
            local lower = str:lower()
            local debuffId = debuff[10]
            if str:match("Disarmed.") then
              disarmIds[debuffId] = true
              local r = debuff[6] - blink.time
              if r > remains then 
                remains = r
              end
            else
              disarmIds[debuffId] = false
            end
          end
          return remains
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "disarm" or keyLower == "disarmed" or keyLower == "isdisarmed" or keyLower == "disarmcheck" then
        func = function()
          local debuffs = self.debuffs
          if not debuffs then
            return false
          end

          local memo = cache.memo
          if not memo.disarm_debuffs then
            memo.disarm_debuffs = {
              refresh_after = 30
            }
          end
          local disarmIds = memo.disarm_debuffs

          local ndebuffs = #debuffs
          
          local confirmed = true
          for i=1,ndebuffs do
            local debuff = debuffs[i]
            if debuff then
              local id = debuff[10]
              local state = disarmIds[id]
              if state then
                return id
              elseif state == nil then
                confirmed = false
              end
            end
          end

          if confirmed then 
            return false
          end

          local desc = self.debuffDescriptions
          for i=1,#desc do
            local str = desc[i]
            local debuff = debuffs[i]
            if not debuff then
              break
            end
            local lower = str:lower()
            local debuffId = debuff[10]
            if str:match("Disarmed.") then
              disarmIds[debuffId] = true
              return debuffId
            else
              disarmIds[debuffId] = false
            end
          end
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "hasdot" or keyLower == "dotted" or keyLower == "isdotted" then
        func = function()
          local desc = self.debuffDescriptions
          for _, str in ipairs(desc) do
            if str:match("sec.") or str:match("seconds.") then
              return true
            end
          end
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "buffdescriptions" or keyLower == "getbuffdescriptions" or keyLower == "buffdesc" then
        return self.getBuffDescriptions(ogKey)
      elseif keyLower == "debuffdescriptions" or keyLower == "getdebuffdescriptions" or keyLower == "debuffdesc" then
        return self.getDebuffDescriptions(ogKey)
      elseif keyLower == "predictlos" then
        return self.predictLoS
      elseif keyLower == "lockoutdetails" then
        -- fix me
        return function()
          return false
        end
      elseif keyLower == "loot" or keyLower == "canloot" or keyLower == "lootable" then
        return IsWoWGameObject and pointer:lootable() or ObjectLootable(pointer)
      elseif keyLower == "skinnable" then
        if Tinkr.type == "daemonic" then
          return UnitIsSkinnable(pointer)
        else
          return ObjectSkinnable(pointer)
        end
      elseif keyLower == "castpct" or keyLower == "castpctcomplete" or keyLower == "castpctcompeted" or keyLower ==
          "castpctdone" then
        if self.casting then
          local spellName, _, _, castStartTime, castEndTime, _, _, notInterruptible = UnitCastingInfo(pointer)
          if castStartTime then
            local castPercentDone =
                (((GetTime() - castStartTime / 1000)) / (castEndTime / 1000 - castStartTime / 1000)) * 100
            return castPercentDone
          else
            blink.debug.print("obj.casting was true but UnitCastingInfo(pointer) was not in castpct check?", "debug")
          end
        end
        -- if self.channel then
        -- 	local spellName, _, _, channelStartTime, channelEndTime, _, _, notInterruptible = UnitChannelInfo(pointer)
        -- 	if channelStartTime then
        -- 		local channelPercentDone = (((GetTime() - channelStartTime/1000)) / (channelEndTime/1000 - channelStartTime/1000) ) * 100
        -- 		return channelPercentDone
        -- 	else
        -- 		blink.debug.print("obj.channeling was true but UnitChannelInfo(pointer) was not in channelpct check?", "debug")
        -- 	end
        -- end
        return 0
      elseif keyLower == "channelpct" or keyLower == "channelpctcomplete" or keyLower == "channelpctdone" then
        if self.channel then
          local spellName, _, _, channelStartTime, channelEndTime, _, _, notInterruptible = UnitChannelInfo(pointer)
          if channelStartTime then
            local channelPercentDone = (((GetTime() - channelStartTime / 1000)) /
                (channelEndTime / 1000 - channelStartTime / 1000)) * 100
            return channelPercentDone
          else
            blink.debug.print("obj.channeling was true but UnitChannelInfo(pointer) was not in channelpct check?",
              "debug")
          end
        end
        return 0
      elseif keyLower == "quaking_remains" or keyLower == "quakingremains" then
        func = function()
          return self.debuffRemains(240447)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "buffremains" or keyLower == "br" then
        return self.buffRemains
      elseif keyLower == "level" or keyLower == "lvl" then
        return cacheReturn(ogKey, keyLower, selection, UnitLevel, "single", pointer)
      elseif keyLower == "bcc" or keyLower == "bcccheck" or keyLower == "bccinfo" or keyLower == "breakablecc" or
          keyLower == "breakablecccheck" or keyLower == "isinbcc" or keyLower == "isbcc" or keyLower == "bccr" or keyLower ==
          "bccremains" then
        local selectionFunc = function()
          if keyLower == "bcc" or keyLower == "breakablecc" or keyLower == "isinbcc" or keyLower == "isbcc" or keyLower ==
              "bcccheck" then
            return "bcc", 1
          elseif keyLower == "bccr" or keyLower == "bccremains" then
            return "bcc", 2
          elseif keyLower == "bccinfo" then
            return "bcc", 3
          end
        end
        return cacheReturn(ogKey, keyLower, selection, blink.IsInBreakableCC, selectionFunc, self)
      elseif keyLower == "buffsfrom" or keyLower == "buffsfromtable" then
        return self.buffsFrom
      elseif keyLower == "debuffsfrom" or keyLower == "debuffsfromtable" then
        return self.debuffsFrom
      elseif keyLower == "bufffrom" or keyLower == "bufffromtable" then
        return self.buffFrom
      elseif keyLower == "debufffrom" or keyLower == "debufffromtable" then
        return self.debuffFrom
      elseif keyLower == "combat" then
        if not self.exists then
          return false
        end
        return cacheReturn(ogKey, keyLower, selection, UnitAffectingCombat, "single", pointer)
      elseif keyLower == "cc" or keyLower == "cccheck" or keyLower == "isincc" or keyLower == "iscc" or keyLower ==
          "ccinfo" or keyLower == "ccr" or keyLower == "ccremains" or keyLower == "ccrem" or keyLower == "ccdur" or
          keyLower == "ccduration" then
        local selectionFunc = function()
          if keyLower == "cc" or keyLower == "cccheck" or keyLower == "isincc" or keyLower == "iscc" then
            return "cc", 1
          elseif keyLower == "ccr" or keyLower == "ccremains" or keyLower == "ccrem" or keyLower == "ccdur" or keyLower ==
              "ccduration" then
            return "cc", 2
          elseif keyLower == "ccinfo" then
            return "cc", 3
          end
        end
        return cacheReturn(ogKey, keyLower, selection, blink.IsInCC, selectionFunc, self)
      elseif ref == "player" and (keyLower == "stance" or keyLower == "form") then
        return cacheReturn(ogKey, keyLower, selection, GetShapeshiftForm, "single")
      elseif keyLower == "casttimeleft" or keyLower == "casttimeremains" or keyLower == "casttimerem" or keyLower ==
          "castrem" or keyLower == "castremains" or keyLower == "casttimecomplete" or keyLower == "channeltimeleft" or
          keyLower == "channeltimecomplete" or keyLower == "channelremains" or keyLower == "channeltimeremains" then
        local ctlFunc = function()
          if keyLower == "channeltimecomplete" or keyLower == "casttimecomplete" then
            if self.casting then
              local spellName, _, _, castStartTime, castEndTime, _, _, notInterruptible = UnitCastingInfo(pointer)
              if castStartTime then
                local realCastEndTime = castEndTime / 1000
                local realCastStartTime = castStartTime / 1000
                local castTimeCompleted = GetTime() - realCastStartTime
                return castTimeCompleted
              else
                blink.debug.print(
                  "no 4th return from UnitCastingInfo in castTimeComplete even though obj.casting = true", "debug")
              end
            elseif self.channeling then
              local spellName, _, _, channelStartTime, channelEndTime, _, _, notInterruptible = UnitChannelInfo(pointer)
              if channelStartTime then
                local realChannelEndTime = channelEndTime / 1000
                local realChannelStartTime = channelStartTime / 1000
                local channelTimeCompleted = GetTime() - realChannelStartTime
                return channelTimeCompleted
              else
                blink.debug.print(
                  "no 4th return from UnitChannelInfo in channelTimeComplete even though obj.channeling = true", "debug")
              end
            end
            return 0
          else
            local remains = self.casting5 and ((self.casting5 - blink.time * 1000) / 1000) - blink.latency
            return remains and remains > 0 and remains or 0
          end
        end
        return cacheReturn(ogKey, keyLower, selection, ctlFunc, "single")
      elseif keyLower == "stundr" or keyLower == "sdr" or keyLower == "stundrr" or keyLower == "sdrr" or keyLower ==
          "stundrremains" or keyLower == "stundrleft" then
        local func = selectionFuncs.stundr
        return cacheReturn(ogKey, keyLower, selection, blink.dr, func, self, "stun")
      elseif keyLower == "falling" then
        return cacheReturn(ogKey, keyLower, selection, IsFalling, "single", pointer)
      elseif keyLower == "incapdr" or keyLower == "incapacitatedr" or keyLower == "idr" or keyLower == "incapdrr" or
          keyLower == "incapacitatedrr" or keyLower == "idrr" or keyLower == "incapdrremains" or keyLower ==
          "incapacitatedrremains" or keyLower == "idrremains" then
        local selectionFunc = selectionFuncs.idr
        return cacheReturn(ogKey, keyLower, selection, blink.dr, selectionFunc, self, "incapacitate")
      elseif keyLower == "disorientdrr" or keyLower == "disorientdrremains" or keyLower == "ddrr" or keyLower ==
          "ddrremains" or keyLower == "disorientdr" or keyLower == "ddr" then
        local selectionFunc = selectionFuncs.ddr
        return cacheReturn(ogKey, keyLower, selection, blink.dr, selectionFunc, self, "disorient")
      elseif keyLower == "rootdrr" or keyLower == "rootdrremains" or keyLower == "rdrr" or keyLower == "rdrremains" or
          keyLower == "rootdr" or keyLower == "rdr" then
        local selectionFunc = selectionFuncs.rootdr
        return cacheReturn(ogKey, keyLower, selection, blink.dr, selectionFunc, self, "root")
      elseif keyLower == "druidrootremains" or keyLower == "drootr" then
        local f = function()
          return self.class2 ~= "DRUID" and self.rootr or 0
        end
        return cacheReturn(ogKey, keyLower, selection, f, "single")
      elseif keyLower == "silencedrr" or keyLower == "silencedrremains" or keyLower == "silencedr" then
        local selectionFunc = selectionFuncs.silencedr
        return cacheReturn(ogKey, keyLower, selection, blink.dr, selectionFunc, self, "silence")
      elseif keyLower == "stun" or keyLower == "stunned" or keyLower == "isstunned" or keyLower == "stuninfo" or
          keyLower == "stunr" or keyLower == "stunremains" then
        local selectionFunc = selectionFuncs.stun
        return cacheReturn(ogKey, keyLower, selection, blink.IsInCC, selectionFunc, self, {
          ["stun"] = true
        })
      elseif keyLower == "incap" or keyLower == "incapped" or keyLower == "incapacitated" or keyLower == "incapr" or
          keyLower == "incapremains" or keyLower == "incapacitateremains" or keyLower == "incapacitater" or keyLower ==
          "incapinfo" or keyLower == "incapacitateinfo" then
        local selectionFunc = selectionFuncs.incap
        return cacheReturn(ogKey, keyLower, selection, blink.IsInCC, selectionFunc, self, {
          ["incapacitate"] = true
        })
      elseif keyLower == "disorient" or keyLower == "disoriented" or keyLower == "isdisoriented" or keyLower ==
          "disorientinfo" or keyLower == "disorientremains" or keyLower == "disorientr" then
        local selectionFunc = selectionFuncs.disorient
        return cacheReturn(ogKey, keyLower, selection, blink.IsInCC, selectionFunc, self, {
          ["disorient"] = true
        })
      elseif keyLower == "root" or keyLower == "rooted" or keyLower == "isrooted" or keyLower == "rootremains" or
          keyLower == "rootr" or keyLower == "rootinfo" then
        local selectionFunc = selectionFuncs.rooted
        return cacheReturn(ogKey, keyLower, selection, blink.IsInCC, selectionFunc, self, {
          ["root"] = true
        })
      elseif keyLower == "silence" or keyLower == "silenced" or keyLower == "issilenced" or keyLower == "silenceremains" or
          keyLower == "silencer" or keyLower == "silenceinfo" then
        local selectionFunc = selectionFuncs.silenced
        return cacheReturn(ogKey, keyLower, selection, blink.IsInCC, selectionFunc, self, {
          ["silence"] = true
        })
      elseif keyLower == "sheepremains" or keyLower == "sheepr" or keyLower == "polyr" or keyLower == "polyremains" or
          keyLower == "polyduration" then
        local sheepRemains = function()
          local longest = 0
          local src = blink.player.class2 == "MAGE" and blink.player
          for _, sheep in ipairs(blink.spells.sheeps) do
            local remains = self.debuffRemains(sheep, src)
            if remains > longest then
              longest = remains
            end
          end
          return longest
        end
        return cacheReturn(ogKey, keyLower, selection, sheepRemains, "single", self)
      elseif keyLower == "facingdir" or keyLower == "facingdirection" or keyLower == "rotation" then
        return IsWoWGameObject and pointer:rotation() or
            cacheReturn(ogKey, keyLower, selection, ObjectRotation, "single", self.pointer)
      elseif keyLower == "predicthp" or keyLower == "hppredict" or keyLower == "php" then
        local hpfunc = function(o)
          if not o then
            return 100
          end
          local incomingHeals = (UnitGetIncomingHeals(o) or 0)
          return min(100, (100 * (UnitHealth(o) + incomingHeals) / UnitHealthMax(o)))
        end
        return cacheReturn(ogKey, keyLower, selection, hpfunc, "single", pointer)
      elseif keyLower == "hp" or keyLower == "hpliteral" then
        local hpfunc = function(p)
          if not p then
            blink.debug.print("no object in hp check", "debug")
            return 100
          end
          local hp = UnitHealth(p)
          if not hp then
            blink.debug.print("object health returned nil in hp check", "debug")
            return 100
          end
          local hpmax = UnitHealthMax(p)
          if not hpmax then
            blink.debug.print("object healthMax returned nil in hp check", "debug")
            return 100
          end
          return keyLower == "hp" and 100 * hp / hpmax or hp
        end
        return cacheReturn(ogKey, keyLower, selection, hpfunc, "single", pointer)
      elseif keyLower == "aggro" then
        func = function()
          return self.threat >= 2
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single", pointer)
      elseif keyLower == "threat" then
        func = function()
          return UnitThreatSituation("player", pointer) or -1
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "reaction" then
        return cacheReturn(ogKey, keyLower, selection, UnitReaction, "single", "player", pointer)
      elseif keyLower == "threatwith" then
        func = function(otherObj)
          if not otherObj then
            return -1
          end
          if not otherObj.exists then
            return -1
          end
          if not otherObj.pointer then
            return -1
          end
          return select(3, UnitDetailedThreatSituation(pointer, otherObj.pointer)) or otherObj.target.isUnit(pointer) and 255 or -1
        end
        return func -- cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "hpplusabsorbs" or keyLower == "hpwithabsorbs" or keyLower == "hpa" then
        local hpfunc = function(p)
          if not p then
            blink.debug.print("no object in hp check", "debug")
            return 100
          end
          local hp = UnitHealth(p)
          if not hp then
            blink.debug.print("object health returned nil in hp check", "debug")
            return 100
          end
          local hpmax = UnitHealthMax(p)
          if not hpmax then
            blink.debug.print("object healthMax returned nil in hp check", "debug")
            return 100
          end
          local absorbs = (UnitGetTotalAbsorbs(p) or 0)
          return 100 * (hp + absorbs) / hpmax
        end
        return cacheReturn(ogKey, keyLower, selection, hpfunc, "single", pointer)
      elseif keyLower == "hpdeficit" or keyLower == "missinghealth" then
        if not self.exists then
          return 100
        end
        local hpfunc = function(p)
          if not p then
            blink.debug.print("no object in hp check", "debug")
            return 100
          end
          local hp = UnitHealth(p)
          if not hp then
            blink.debug.print("object health returned nil in hp check", "debug")
            return 100
          end
          local hpmax = UnitHealthMax(p)
          if not hpmax then
            blink.debug.print("object healthMax returned nil in hp check", "debug")
            return 100
          end
          return hpmax - hp
        end
        return cacheReturn(ogKey, keyLower, selection, hpfunc, "single", pointer)
      elseif keyLower == "hpmax" or keyLower == "maxhp" or keyLower == "healthmax" or keyLower == "maxhealth" then
        if not self.exists then
          return 100
        end
        local hpfunc = function(...)
          return UnitHealthMax(...) or
              blink.debug.print("healthmax returned 0 to fail gracefully, unit did not exist!", "debug") or 0
        end
        return cacheReturn(ogKey, keyLower, selection, hpfunc, "single", pointer)
      elseif keyLower == "health" then
        return cacheReturn(ogKey, keyLower, selection, UnitHealth, "single", pointer)
      elseif keyLower == "uptime" then
        func = function()
          local p2s = tostring(pointer)
          local ofd = objectFirstDetected[p2s]
          if not ofd then
            return 0
          end
          return GetTime() - objectFirstDetected[p2s]
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "absorb" or keyLower == "absorbs" or keyLower == "absorbsremain" then
        return cacheReturn(ogKey, keyLower, selection, UnitGetTotalAbsorbs, "single", pointer)
      elseif keyLower == "class" or keyLower == "unitclass" or keyLower == "getclass" then
        if not pointer or not self.exists then
          return "UNKNOWN"
        end
        local selectionFunc = function()
          if keyLower == "classliteral" then
            return "class", 2
          elseif keyLower:match("class") then
            return "class"
          end
        end
        return cacheReturn(ogKey, keyLower, selection, UnitClass, selectionFunc, pointer)
      elseif keyLower == "classstring" then
        local getString = function()
          local class = self.class2
          if not class then
            return ""
          end
          class = class:lower()
          local formatted = class
          if formatted == "demonhunter" then
            formatted = "demon hunter"
          end
          if formatted == "deathknight" then
            formatted = "death knight"
          end
          formatted = " " .. formatted
          formatted = formatted:gsub("%W%l", string.upper):sub(2)
          return blink.colors[class] .. formatted .. "|r"
        end
        return cacheReturn(ogKey, keyLower, selection, getString, selectionFunc)
      elseif keyLower == "covenant" then
        local covenantFunc = function()
          if ref == "player" then
            local covenantInfo = blink.CovenantInfo
            if not covenantInfo or blink.time - blink.LastCovenantUpdate > 60 then
              blink.CovenantInfo = { blink.GetSoulbindInfo() }
              blink.LastCovenantUpdate = blink.time
              covenantInfo = blink.CovenantInfo
            end
            return covenantInfo[1] and covenantInfo[1].covenantName or blink.GetUnitCovenant(self)
          else
            return blink.GetUnitCovenant(self)
          end
        end
        return cacheReturn(ogKey, keyLower, selection, covenantFunc, "single")
      elseif keyLower == "hasconduit" then
        if ref ~= "player" then
          return false
        end
        local function func(conduit)
          local data = blink.GetCovenantData()
          if type(data) ~= "table" then
            return false
          end
          if not data.conduits then
            return false
          end
          if type(conduit) == "string" then
            for _, thisConduit in ipairs(data.conduits) do
              if thisConduit.spellName:lower() == conduit:lower() then
                return true
              end
            end
          elseif type(conduit) == "number" then
            for _, thisConduit in ipairs(data.conduits) do
              if thisConduit.spellID == conduit then
                return true
              end
            end
          else
            blink.print("Please only pass string or number to *hasConduit* ...")
            return false
          end
        end
        return func
      elseif keyLower == "boundingradius" then
        return IsWoWGameObject and pointer:boundingRadius() or
            cacheReturn(ogKey, keyLower, selection, ObjectBoundingRadius, "single", pointer)
      elseif keyLower == "interruptable" then
        func = function()
          return self.canBeInterrupted(1.5)
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single", pointer)
      elseif keyLower == "lockouts" then
        func = function()
          local lockouts = {}
          local guid = self.guid
          if not guid then
            return lockouts
          end
          local objLockouts = blink.lockouts[guid]
          if objLockouts then
            for _, lockout in ipairs(objLockouts) do
              lockouts[lockout.school:lower()] = {
                remains = lockout.expires - GetTime(),
                interrupt = lockout.interrupt
              }
            end
          end
          return lockouts
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "reach" or keyLower == "combatreach" then
        return IsWoWGameObject and pointer:combatReach() or
            cacheReturn(ogKey, keyLower, selection, blink.CombatReach, "single", pointer) or 0
      elseif keyLower == "unitpower" or keyLower == "power" then
        return cacheReturn(ogKey, keyLower, selection, UnitPower, "single", pointer)
      elseif keyLower == "unitpowermax" or keyLower == "powermax" then
        return cacheReturn(ogKey, keyLower, selection, UnitPowerMax, "single", pointer)
      elseif keyLower == "timetorunes" or keyLower == "timetorune" then
        return self.timeToRunes
      elseif blink.powerTypes[keyLower] then
        if keyLower == "runes" then
          local f = function()
            local total = 0
            for i = 1, 6 do
              if select(3, GetRuneCooldown(i)) == true then
                total = total + 1
              end
            end
            return total
          end
          return cacheReturn(ogKey, keyLower, selection, f, "single")
        end

        if (keyLower == "cp" or keyLower == "combopoints") and blink.gameVersion ~= 1 then
          return function(obj)
            if not obj then
              if blink.target.enemy then
                return GetComboPoints(blink.player.pointer, blink.target.pointer)
              end
              return 0
            end
            if not obj.exists then
              return 0
            end
            return GetComboPoints(blink.player.pointer, obj.pointer)
          end
        end
        return cacheReturn(ogKey, keyLower, selection, UnitPower, "single", pointer, blink.powerTypes[keyLower])
      elseif blink.powerTypes[keyLower:gsub("max", "")] then
        return cacheReturn(ogKey, keyLower, selection, UnitPowerMax, "single", pointer,
          blink.powerTypes[string.gsub(keyLower, "max", "")])
      elseif blink.powerTypes[keyLower:gsub("pct", "")] then
        local pctFunc = function()
          local current = self[keyLower:gsub("pct", "")]
          local max = self[keyLower:gsub("pct", "") .. "max"]
          return current / max * 100
        end
        return cacheReturn(ogKey, keyLower, selection, pctFunc, "single")
      elseif blink.powerTypes[keyLower:gsub("deficit", "")] then
        local deficitFunc = function()
          local current = self[keyLower:gsub("deficit", "")]
          local max = self[keyLower:gsub("deficit", "") .. "max"]
          return max - current
        end
        return cacheReturn(ogKey, keyLower, selection, deficitFunc, "single")
      elseif keyLower == "movementflag" or keyLower == "movementflags" then
        return IsWoWGameObject and pointer:movementFlag() or ObjectMovementFlag(pointer) or 1
      elseif (keyLower == "mounted" or keyLower == "ismounted") and ref == "player" then
        return cacheReturn(ogKey, keyLower, selection, IsMounted, "single")
      elseif (keyLower == "flying" or keyLower == "isflying") and ref == "player" then
        return cacheReturn(ogKey, keyLower, selection, IsFlying, "single")
      elseif keyLower == "canattack" or keyLower == "enemyof" then
        local canattack = function(otherobj)
          if type(otherobj) == "string" or type(otherobj) == "userdata" then
            return ref and UnitCanAttack(ref, otherobj) or pointer and UnitCanAttack(pointer, otherobj)
          elseif type(otherobj) == "table" then
            return pointer and otherobj.pointer and UnitCanAttack(pointer, otherobj.pointer)
          end
        end
        return canattack
      elseif keyLower == "direction" or keyLower == "movingdirection" or keyLower == "movingdir" or keyLower == "dir" then
        local movingDirectionFunc = function()
          local dir = self.rotation
          if not dir then
            blink.debug.print("invalid rotation from movingdirection check. returned a default value.", "debug")
            return 0
          end
          local movementFlag = self.movementFlags
          if not movementFlag then
            blink.debug.print("invalid movement flags from movingdirection check. returned a default value.", "debug")
            return 0
          end
          local flags = band(movementFlag, 0xF)
          local mod = 0
          if flags == 0x2 then
            mod = pi
          elseif flags == 0x4 then
            mod = pi * 0.5
          elseif flags == 0x8 then
            mod = pi * 1.5
          elseif flags == 0x5 then
            mod = pi * (1 / 8) * 2
          elseif flags == 0x9 then
            mod = pi * (7 / 8) * 2
          elseif flags == 0x6 then -- was bor(0x2, 0x4)
            mod = pi * (3 / 8) * 2
          elseif flags == 0xA then
            mod = pi * (5 / 8) * 2
          end
          return (dir + mod) % (pi * 2)
        end
        return cacheReturn(ogKey, keyLower, selection, movingDirectionFunc, "single")
      elseif keyLower == "moving" or keyLower == "ismoving" then
        local movingFunc = function(...)
          return self.speed and self.speed > 0
        end
        return cacheReturn(ogKey, keyLower, selection, movingFunc, "single", pointer)
      elseif keyLower == "hostile" or keyLower == "enemy" then
        if options.enemy then
          return options.enemy
        else
          local func = function(unit)
            return unit and UnitCanAttack("player", unit)
          end
          return cacheReturn(ogKey, keyLower, selection, func, "single", pointer)
        end
      elseif keyLower == "friend" or keyLower == "friendly" or keyLower == "isfriend" or keyLower == "isfriendly" then
        if options.friend then
          return options.friend
        else
          func = function(unit)
            return unit and UnitIsFriend("player", unit)
          end
          return cacheReturn(ogKey, keyLower, selection, func, "single", pointer)
        end
      elseif keyLower == "isranged" or keyLower == "ranged" or keyLower == "israngeddps" then
        func = function()
          return self.role == "ranged"
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "ismelee" or keyLower == "melee" or keyLower == "ismeleedps" then
        func = function()
          return self.role == "melee"
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "ishealer" or keyLower == "healer" then
        local isHealer = function()
          return self.role == "healer"
        end
        return cacheReturn(ogKey, keyLower, selection, isHealer, "single")
      elseif keyLower == "istank" or keyLower == "tank" then
        local isTank = function()
          return self.role == "tank"
        end
        return cacheReturn(ogKey, keyLower, selection, isTank, "single")
      elseif keyLower == "distancetoliteral" or keyLower == "distancefromliteral" then
        return self.distanceToLiteral
      elseif keyLower == "meleerange" then
        return cacheReturn(ogKey, keyLower, selection, self.meleeRangeOf, "single")
      elseif keyLower == "distliteral" or keyLower == "distanceliteral" then
        return cacheReturn(ogKey, keyLower, selection, self.distanceToLiteral, "single", blink.player)
      elseif keyLower == "dist" or keyLower == "distance" then
        return cacheReturn(ogKey, keyLower, selection, self.distanceTo, "single", blink.player)
      elseif keyLower == "target" or keyLower == "tar" then
        func = function()
          local t = ObjectTarget(pointer)
          if t then
            return blink.createObject(t)
          else
            return unitPrototype
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single", pointer)
      elseif keyLower == "pet" or keyLower == "ispet" or keyLower == "isotherplayerspet" then
        if self.exists then
          return cacheReturn(ogKey, keyLower, selection, UnitIsOtherPlayersPet, "single", pointer)
        else
          return false
        end
      elseif keyLower == "player" or keyLower == "isplayer" or keyLower == "playercheck" then
        if IsWoWGameObject then
          local thisType = self.pointer:type()
          return thisType == 6 or thisType == 7
        elseif pointer then
          return cacheReturn(ogKey, keyLower, selection, UnitIsPlayer, "single", pointer)
        else
          return false
        end
      elseif keyLower == "combat" or keyLower == "affectingcombat" or keyLower == "incombat" or keyLower == "isincombat" then
        return pointer and cacheReturn(ogKey, keyLower, selection, UnitAffectingCombat, "single", pointer)
      elseif keyLower == "timeinlos" then
        func = function()
          if not pointer then
            return 0
          end
          local los = self.los
          if not LoSTracker[pointer] then
            LoSTracker[pointer] = { {
              time = GetTime(),
              los = los
            } }
          else
            local tracker = LoSTracker[pointer]
            if #tracker == 0 or tracker[#tracker].los ~= los then
              tinsert(tracker, {
                time = GetTime(),
                los = los
              })
            end
          end
          local tracker = LoSTracker[pointer]
          if los then
            local oldestSameResult
            for i = #tracker, 1, -1 do
              if tracker[i].los == los then
                oldestSameResult = tracker[i]
              else
                break
              end
            end
            if oldestSameResult then
              return GetTime() - oldestSameResult.time
            else
              return 0
            end
          else
            return 0
          end
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "settarget" then
        return self.setTarget()
      elseif keyLower == "haste" then
        func = function()
          if not pointer then
            return 0
          end
          local haste = UnitSpellHaste(pointer)
          if haste then
            return haste / 100
          end
          return 0
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single")
      elseif keyLower == "setfocus" then
        return self.setFocus()
      elseif keyLower == "hastalent" or keyLower == "istalent" then
        return self.hasTalent
      elseif keyLower == "hasglyph" then
        return self.hasGlyph
      elseif keyLower == "buffuptime" then
        return self.buffUptime
      elseif keyLower == "debuffuptime" then
        return self.debuffUptime
      elseif keyLower == "buffduration" then
        return self.buffDuration
      elseif keyLower == "debuffduration" then
        return self.debuffDuration
      elseif keyLower == "buffstacks" or keyLower == "buffcharges" then
        return self.buffStacks
      elseif keyLower == "debuffstacks" or keyLower == "debuffcharges" then
        return self.debuffStacks
      elseif keyLower == "debuffremains" or keyLower == "debuffr" or keyLower == "debuffrem" or keyLower == "dbr" then
        return self.debuffRemains
      elseif keyLower == "debuff" or keyLower == "debuffcheck" then
        return self.debuff
      elseif keyLower == "buff" or keyLower == "buffcheck" then
        return self.buff
      elseif keyLower == "height" then
        func = function()
          local class = self.class2
          if not class then
            return 2.1
          end
          local formHeights = blink.formHeights
          if class == "DRUID" then
            local form = GetShapeshiftForm(nil)
            if form == 0 then
              -- yep
            elseif formHeights.DRUID[form] then
              return formHeights.DRUID[form]
            end
          end
          local height = ObjectHeight(self.pointer)
          local realHeight = blink.realHeight(height)
          return realHeight or height
        end
        return cacheReturn(ogKey, keyLower, selection, func, "single", pointer)
      elseif keyLower == "dummy" or keyLower == "isdummy" then
        func = function()
          local id = self.id
          if not id then
            return false
          end
          if blink.ObjectIDs.Dummies[id] then
            return true
          end
        end
        return options.dummy or cacheReturn(ogKey, keyLower, selection, func, "single")
      end
      return rawget(self, key) -- or blink.debug.print(key .. " is not a valid object attribute. \n\nNOTE: |cFFFFFFFFthis may be harmless, especially if you know the attribute is correct but a value for it just isn't defined yet.", "debug")
    end
  }
  local obj = {
    isBlinkObject = true,
    truePointer = object,
    cache = {
      position = {}
    },
    cacheLiteral = {},
    scripts = {},
    ref = ref,
    initDist = options.dist or (ref == "player" and 0)
  }
  setmetatable(obj, objFunctions)

  -- obj.indexFunc = profiler
  obj.initOptions = options

  obj.castingInfo = function()
    if not obj.pointer then
      return nil
    end
    return UnitCastingInfo(obj.pointer)
  end
  obj.CastingInfo = obj.castingInfo
  obj.channelInfo = function()
    if not obj.pointer then
      return nil
    end
    return UnitChannelInfo(obj.pointer)
  end
  obj.ChannelInfo = obj.channelInfo

  obj.cacheReturn = function(key, keyLower, selection, ...)
    return cacheReturnTemplate(key, keyLower, selection, obj, ...)
  end

  obj.setFocus = function()
    if not obj.pointer then
      return
    end
    FocusUnit(obj.pointer)
    return true
  end

  obj.setTarget = function()
    if not obj.pointer then
      return
    end
    TargetUnit(obj.pointer)
    return true
  end

  function obj:interact()
    local InteractUnit = ObjectInteract or Interact or InteractUnit
    InteractUnit(self.pointer)
  end

  obj.rect = function(w, l, ...)
    local args = { ... }
    -- other object, use facing direction by default
    if #args == 1 then
      local otherObj = args[1]
      local rotation = otherObj.rotation
      if not rotation then
        return false
      end
      local x, y, z = otherObj.position()
      local px, py, pz = obj.position()
      if not x then
        return false
      end
      return blink.inRect(x, y, z, px, py, pz, w, l, rotation)
      -- other object, given angle
    elseif #args == 2 then
      local otherObj = args[1]
      local rotation = args[2]
      local x, y, z = otherObj.position()
      local px, py, pz = obj.position()
      if not x then
        return false
      end
      return blink.inRect(x, y, z, px, py, pz, w, l, rotation)
      -- given x, y, z, and angle
    elseif #args >= 4 then
      local x, y, z = args[1], args[2], args[3]
      local rotation = args[4]
      local px, py, pz = obj.position()
      if not x then
        return false
      end
      return blink.inRect(x, y, z, px, py, pz, w, l, rotation)
    end
    return "invalid arguments"
  end

  obj.arc = function(size, arc, ...)
    local args = { ... }
    -- other object, use facing direction by default
    if #args == 1 then
      local otherObj = args[1]
      local rotation = otherObj.rotation
      if not rotation then
        return false
      end
      local x, y, z = otherObj.position()
      local px, py, pz = obj.position()
      if not x then
        return false
      end
      return blink.inArc(x, y, z, px, py, pz, size, arc, rotation)
      -- other object, given angle
    elseif #args == 2 then
      local otherObj = args[1]
      local rotation = args[2]
      local x, y, z = otherObj.position()
      local px, py, pz = obj.position()
      if not x then
        return false
      end
      return blink.inArc(x, y, z, px, py, pz, size, arc, rotation)
      -- given x, y, z, and angle
    elseif #args >= 4 then
      local x, y, z = args[1], args[2], args[3]
      local rotation = args[4]
      local px, py, pz = obj.position()
      if not x then
        return false
      end
      return blink.inArc(x, y, z, px, py, pz, size, arc, rotation)
    end
  end

  obj.canBeInterrupted = function(elapsed)
    local unitEnemies
    if obj.enemy then
      unitEnemies = blink.tjoin(blink.friends, { player })
    else
      unitEnemies = blink.enemies
    end
    local interruptable = false
    for _, enemy in ipairs(unitEnemies) do
      local eta, interrupt = blink.interruptETA(enemy, obj)
      if eta and interrupt and eta <= elapsed then
        -- thoughts on how to improve this a bit later
        -- add a boolean check for extra auras that prevent interrupts
        -- make list of physical and magical interrupts for each class
        -- check for auras that prevent these type of interrupts, such as intervene for physical, nether shield for magical etc
        if enemy.predictLoSOf(obj, elapsed) and enemy.predictDistanceTo(obj, elapsed) < interrupt.range then
          interruptable = true
          break
        end
      end
    end
    return interruptable
  end

  obj.v2attackers = function(ignoreRange)
    if obj.v2aCount then
      return obj.v2aCount, obj.v2aMelee, obj.v2aRanged, obj.v2aCDs
    end
    local count, melee, ranged, cds = 0, 0, 0, 0
    local unitEnemies
    if obj.enemy then
      unitEnemies = blink.tjoin(blink.friends, { player })
      -- for i=1,#blink.friends do
      -- 	unitEnemies[#unitEnemies + 1] = blink.friends[i]
      -- end
      -- unitEnemies[#unitEnemies + 1] = blink.player
    else
      unitEnemies = blink.enemies
    end
    local arena = blink.arena
    for _, enemy in ipairs(unitEnemies) do
      if (not arena or enemy.isPlayer) and not enemy.isHealer then
        if enemy.target and enemy.target.isUnit(obj) then
          if enemy.ccRemains < 0.5 and
              (ignoreRange or enemy.role == 'melee' and enemy.distanceTo(obj) < 9 or enemy.role == 'ranged' and
              enemy.distanceTo(obj) < 40) then
            count = count + 1
            melee = melee + bin(enemy.role == 'melee')
            ranged = ranged + bin(enemy.role == 'ranged')
            cds = cds + bin(enemy.cds)
          end
        end
      end
    end
    obj.cacheLiteral.v2aCount = count
    obj.cacheLiteral.v2aMelee = melee
    obj.cacheLiteral.v2aRanged = ranged
    obj.cacheLiteral.v2aCDs = cds
    obj.v2aCount = count
    obj.v2aMelee = melee
    obj.v2aRanged = ranged
    obj.v2aCDs = cds
    return count, melee, ranged, cds
  end

  obj.movingAwayFrom = function(otherUnit, options)
    local unit = obj

    if not otherUnit then
      otherUnit = obj
      unit = blink.player
    end

    if type(otherUnit) ~= "table" then
      blink.print("Non blink object passed to .movingAwayFrom")
      return false
    end

    options = options or {}

    local angle = options.angle or 220

    local unitFlags = unit.movementFlags
    local x, y, z = unit.position()
    local tx, ty, tz = otherUnit.position()
    local dir = unit.movingDirection
    local dist = blink.Distance(x, y, z, tx, ty, tz)

    local pointer = unit.pointer
    local otherPointer = otherUnit.pointer

    -- false if the unit isn't moving
    if unit.speed == 0 then
      blink.TimeMovingAwayFrom(pointer, otherPointer, {
        isMovingAway = false
      })
      return false
    end

    -- predicted position
    local px, py, pz = x + dist * math.cos(dir), y + dist * math.sin(dir), z

    -- angles between unit and their predicted pos (this angle being more acute than given angle is a hit)
    local betweenPred = blink.AnglesBetween(x, y, z, px, py, pz)

    -- angle between unit and the object
    local betweenObj = blink.AnglesBetween(x, y, z, tx, ty, tz)

    local radDiff = betweenPred > betweenObj and betweenPred - betweenObj or betweenObj - betweenPred
    local shortest = radDiff < math.pi and radDiff or math.pi * 2 - radDiff
    local angleDiff = shortest / (math.pi / 180)

    local isMovingAway = angleDiff > angle / 2

    if blink.debug['movingAwayFrom'] then
      blink.DrawPredPos = { px, py, pz }
      blink.DrawUnitPos = { tx, ty, tz }
    end

    local flags = { 1, 5, 9, 4, 8, 2057, 2053, 2049, 2056, 2052 } -- 8, 4 = right / left

    local status = {
      flags = unitFlags,
      isMovingAway = isMovingAway,
      angleDiff = angleDiff
    }

    if not options.duration then
      blink.TimeMovingAwayFrom(pointer, otherPointer, status)
      return isMovingAway and
          (not options.flags and tContains(flags, unitFlags) or options.flags and
          tContains(options.flags, unitFlags))
    else
      local timeMovingAway = blink.TimeMovingAwayFrom(pointer, otherPointer, status, options)
      if blink.debug['movingAwayFrom'] then
        print(timeMovingAway)
      end
      return timeMovingAway > options.duration
    end
  end

  obj.movingToward = function(otherUnit, options)
    local unit = obj
    if not otherUnit then
      otherUnit = obj
      unit = blink.player
    end

    if type(otherUnit) ~= "table" then
      blink.print("Non blink object passed to .movingToward")
      return false
    end

    options = options or {}

    local angle = options.angle or 30

    local unitFlags = unit.movementFlags
    local x, y, z = unit.position()
    local tx, ty, tz = otherUnit.position()
    local dir = unit.movingDirection
    local dist = blink.Distance(x, y, z, tx, ty, tz)

    local pointer = unit.pointer
    local otherPointer = otherUnit.pointer

    -- false if the unit isn't moving
    if unit.speed == 0 then
      blink.TimeMovingToward(pointer, otherPointer, {
        isMovingToward = false
      })
      return false
    end

    -- position predicted at same distance from the object
    -- difference in angle (degrees) between predicted position and angle between object position < half the given angle

    -- predicted position
    local px, py, pz = x + dist * math.cos(dir), y + dist * math.sin(dir), z

    -- angles between unit and their predicted pos (this angle being more acute than given angle is a hit)
    local betweenPred = blink.AnglesBetween(x, y, z, px, py, pz)

    -- angle between unit and the object
    local betweenObj = blink.AnglesBetween(x, y, z, tx, ty, tz)

    local radDiff = betweenPred > betweenObj and betweenPred - betweenObj or betweenObj - betweenPred
    local shortest = radDiff < pi and radDiff or pi * 2 - radDiff
    local angleDiff = shortest / (pi / 180)

    local isMovingToward = angleDiff < angle / 2

    -- print(isMovingToward, angleDiff)

    if blink.debug['movingToward'] then
      blink.DrawPredPos = { px, py, pz }
      blink.DrawUnitPos = { tx, ty, tz }
    end

    local flags = { 1, 5, 9, 2057, 2053, 2049 } -- 8, 4 = right / left

    local status = {
      flags = unitFlags,
      isMovingToward = isMovingToward,
      angleDiff = angleDiff
    }

    if not options.duration then
      blink.TimeMovingToward(pointer, otherPointer, status)
      return isMovingToward and
          (not options.flags and tContains(flags, unitFlags) or options.flags and
          tContains(options.flags, unitFlags))
    else
      local timeMovingToward = blink.TimeMovingToward(pointer, otherPointer, status, options)
      if blink.debug['movingToward'] then
        print(timeMovingToward)
      end
      return timeMovingToward > options.duration
    end
  end

  obj.friendOf = function(otherObj)
    local ptr = obj.pointer
    if type(otherObj) == "string" then
      return ptr and UnitIsFriend(ptr, Object(otherObj))
    elseif type(otherObj) == "table" then
      return ptr and otherObj.pointer and UnitIsFriend(ptr, otherObj.pointer)
    elseif type(otherObj) == "userdata" then
      return ptr and otherObj and UnitIsFriend(ptr, otherObj)
    end
  end

  function obj:CacheAuras(auraType, returnHash)
    local k = auraType == "buff" and "buffcache" or auraType == "debuff" and "debuffcache"
    if not k then
      blink.print('Invalid AuraType Given. Expected "buff" or "debuff".', "debug")
    end
    local pointer = self.pointer
    if not pointer then
      blink.debug.print('Invalid pointer in aura check..', 'debug')
      return {}
    end

    -- aura array
    local auras, auraHash = FastAuras(obj, auraType)
    self.cacheLiteral[k] = auras
    self[k] = auras

    self.cacheLiteral[auraType .. "hash"] = auraHash
    self[auraType .. "hash"] = auraHash

    return returnHash and auraHash or auras
  end

  function obj:auraInfo(spellID, auraType, source)
    local nameGiven = type(spellID) == "string" and spellID:lower()
    if source then
      local auras = auraType == "buff" and self.cacheLiteral["buffcache"] and self["buffcache"] 
                 or auraType == "debuff" and self.cacheLiteral["debuffcache"] and self["debuffcache"]
      if not auras then
        auras = self:CacheAuras(auraType)
      end
      for i = 1, #auras do 
        local aura = auras[i]
        if nameGiven and nameGiven == aura[1]:lower() or not nameGiven and aura[10] == spellID then
          if not source or blink_UnitIsUnit(aura[7], source) then
            -- print(spellID, aura[1], aura[10])
            return unpack16(aura)
          end
        end
      end
    else
      local auras = auraType == "buff" and self.cacheLiteral["buffhash"] and self["buffhash"] 
                 or auraType == "debuff" and self.cacheLiteral["debuffhash"] and self["debuffhash"]
      if not auras then
        auras = self:CacheAuras(auraType, true)
      end
      -- _G.ahash = auras
      local aura = auras[nameGiven or spellID]
      if aura then
        return unpack16(aura)
      end
    end
    
  end

  obj.getDebuffDescriptions = function(key)
    local desc = not obj.exists and {} or blink.scrapeDesc(obj.pointer, "debuff")
    obj.cacheLiteral[key] = desc
    obj[key] = desc
    return desc
  end

  obj.getBuffDescriptions = function(key)
    local desc = not obj.exists and {} or blink.scrapeDesc(obj.pointer, "buff")
    obj.cacheLiteral[key] = desc
    obj[key] = desc
    return desc
  end

  obj.auraRemains = function(spellID, auraType, source)
    local buff, _, _, _, _, expires = obj:auraInfo(spellID, auraType, source)
    if buff then
      if expires == 0 then
        return huge
      end
      -- grounding
      if spellID == 8178 then
        return 5
      end
      local remains = expires - blink.time
      if remains > 0 then
        return remains
      end
    end
    return 0
  end

  obj.auraUptime = function(spellID, auraType, source)
    local duration, expiration = select(5, obj:auraInfo(spellID, auraType, source))
    if duration and expiration then
      return duration - (expiration - GetTime())
    end
    return 0
  end

  obj.auraDuration = function(spellID, auraType, source)
    local duration = select(5, obj:auraInfo(spellID, auraType, source))
    if duration then
      return duration
    end
    return 0
  end

  obj.isUnit = function(otherUnit)
    local objToString = tostring(otherUnit)
    if objToString then
      local cached = obj.cache["UnitIsUnit" .. objToString]
      if cached == nil then
        obj.cache["UnitIsUnit" .. objToString] = blink_UnitIsUnit(obj, otherUnit)
      end
      return cached or obj.cache["UnitIsUnit" .. objToString]
    end
  end

  function obj.buff(spellID, source)
    return obj:auraInfo(spellID, "buff", source)
  end

  function obj.buffRemains(spellID, source)
    return obj.auraRemains(spellID, "buff", source)
  end

  function obj.buffStacks(spellID, source)
    local _, _, stacks = obj.buff(spellID, source)
    return stacks or 0
  end

  function obj.buffUptime(spellID, source)
    return obj.auraUptime(spellID, "buff", source)
  end

  function obj.buffDuration(spellID, source)
    return obj.auraDuration(spellID, "buff", source)
  end

  function obj.debuff(spellID, source)
    return obj:auraInfo(spellID, "debuff", source)
  end

  function obj.debuffRemains(spellID, source)
    return obj.auraRemains(spellID, "debuff", source)
  end

  function obj.debuffStacks(spellID, source)
    return select(3, obj.debuff(spellID, source)) or 0
  end

  function obj.debuffUptime(spellID, source)
    return obj.auraUptime(spellID, "debuff", source)
  end

  function obj.debuffDuration(spellID, source)
    return obj.auraDuration(spellID, "debuff", source)
  end

  function obj.buffFrom(table, source)
    local has = {}
    if #table == 0 then
      for id, buff in pairs(table) do
        if type(buff) == "table" then
          local min, max, uptime = buff.min, buff.max, buff.uptime
          if obj.buff(id) then
            if (not min or obj.buffRemains(id, source) >= min) and (not max or obj.buffRemains(id, source) <= max) and
                (not uptime or obj.buffUptime(id, source) >= uptime) then
              has[#has + 1] = id
            end
          end
        elseif type(buff) == "function" then
          if obj.buff(id) and buff(obj) then
            has[#has + 1] = id
          end
        elseif buff and obj.buff(id) then
          has[#has + 1] = id
        end
      end
    else
      for i = 1, #table do
        local buff = table[i]
        if obj.buff(buff, source) then
          has[#has + 1] = buff
        end
      end
    end
    return #has > 0 and has or false
  end

  function obj.debuffFrom(table, source)
    local has = {}
    if #table == 0 then
      for id, debuff in pairs(table) do
        if type(debuff) == "table" then
          local min, max, uptime = debuff.min, debuff.max, debuff.uptime
          if obj.debuff(id) then
            if (not min or obj.debuffRemains(id, source) >= min) and (not max or obj.debuffRemains(id, source) <= max) and
                (not uptime or obj.debuffUptime(id, source) >= uptime) then
              has[#has + 1] = id
            end
          end
        elseif type(debuff) == "function" then
          if obj.debuff(id) and debuff(obj) then
            has[#has + 1] = id
          end
        elseif debuff and obj.debuff(id) then
          has[#has + 1] = id
        end
      end
    else
      for i = 1, #table do
        local debuff = table[i]
        if obj.debuff(debuff, source) then
          has[#has + 1] = debuff
        end
      end
    end
    return #has > 0 and has or false
  end

  function obj.buffOrDebuffFrom(table, source)
    local has = {}
    if #table == 0 then
      for id, buffOrDebuff in pairs(table) do
        if type(buffOrDebuff) == "table" then
          local min, max, uptime = buffOrDebuff.min, buffOrDebuff.max, buffOrDebuff.uptime
          if obj.buff(id) or obj.debuff(id) then
            if (not min or max(obj.buffRemains(id, source), obj.debuffRemains(id, source)) >= min) and
                (not max or max(obj.buffRemains(id, source), obj.debuffRemains(id, source)) <= max) and
                (not uptime or max(obj.buffUptime(id, source), obj.debuffUptime(id, source)) >= uptime) then
              has[#has + 1] = buffOrDebuff
            end
          end
        elseif type(buffOrDebuff) == "function" then
          if (obj.buff(id) or obj.debuff(id)) and buffOrDebuff(obj) then
            has[#has + 1] = id
          end
        elseif buffOrDebuff and (obj.buff(id) or obj.debuff(id)) then
          has[#has + 1] = id
        end
      end
    else
      for i = 1, #table do
        local buffOrDebuff = table[i]
        if obj.buff(buffOrDebuff, source) or obj.debuff(buffOrDebuff, source) then
          has[#has + 1] = buffOrDebuff
        end
      end
    end
  end

  function obj.buffsFrom(table, source)
    local has = {}
    for _, buff in ipairs(table) do
      if obj.buff(buff, source) then
        has[#has + 1] = buff
      end
    end
    return #has
  end

  function obj.debuffsFrom(table, source)
    local has = {}
    for _, debuff in ipairs(table) do
      if obj.debuff(debuff, source) then
        has[#has + 1] = debuff
      end
    end
    return #has
  end

  function obj.losCoords(x, y, z)
    return blink.losCoords(obj, x, y, z)
  end

  function obj.losCoordsLiteral(x, y, z)
    return blink.losCoords(obj, x, y, z, true)
  end

  function obj.losOf(otherObj)
    return blink.los(obj, otherObj)
  end

  obj.losUnit = obj.losOf
  obj.LoSUnit = obj.losOf
  obj.LoSOf = obj.losOf

  obj.losOfLiteral = function(otherObj)
    return blink.los(obj, otherObj, true)
  end
  obj.losUnitLiteral = obj.losOfLiteral
  obj.LoSUnitLiteral = obj.losOfLiteral
  obj.LoSOfLiteral = obj.losOfLiteral

  function obj.hasGlyph(id)
    local id2s = tostring(id)
    local cached = obj['cachedHasGlyph' .. id2s]
    if cached ~= nil then
      return cached
    end
    if ref == "player" then
      if type(id) == "string" then
        local nameLower = id:lower()
        local exists = blink.availableGlyphs[nameLower]
        if exists then
          local ret = exists
          cache.set(obj, 'cachedHasGlyph' .. id2s, ret)
          return true
        else
          cache.set(obj, 'cachedHasGlyph' .. id2s, false)
          return false
        end
      else
        for k, v in pairs(blink.availableGlyphs) do
          if v.id == id then
            cache.set(obj, 'cachedHasGlyph' .. id2s, true)
            return true
          end
        end
        cache.set(obj, 'cachedHasGlyph' .. id2s, false)
        return false
      end
    end
  end

  function obj.hasTalent(id)
    local id2s = tostring(id)
    local cached = obj['cachedHasTalent' .. id2s]
    if cached ~= nil then
      return cached
    end
    if ref == "player" then
      if blink.DF_ActiveTalents then
        local selectedPvPTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
        if type(id) == "string" then
          local idLower = id:lower()
          for i = 1, #blink.DF_ActiveTalents do
            local talent = blink.DF_ActiveTalents[i]
            if talent.name == idLower then
              cache.set(obj, 'cachedHasTalent' .. id2s, talent.rank)
              return talent.rank
            end
          end
          if selectedPvPTalents then
            for i = 1, #selectedPvPTalents do
              local talentID, name, _, _, _, spellID, _, _, _, known = GetPvpTalentInfoByID(selectedPvPTalents[i])
              if name:lower() == idLower then
                cache.set(obj, 'cachedHasTalent' .. id2s, true)
                break
              end
            end
          end
        else
          for i = 1, #blink.DF_ActiveTalents do
            local talent = blink.DF_ActiveTalents[i]
            if talent.id == id or talent.nodeID == id then
              cache.set(obj, 'cachedHasTalent' .. id2s, talent.rank)
              return talent.rank
            end
          end
          if selectedPvPTalents then
            for i = 1, #selectedPvPTalents do
              local talentID, name, _, _, _, spellID, _, _, _, known = GetPvpTalentInfoByID(selectedPvPTalents[i])
              if talentID == id or spellID == id then
                cache.set(obj, 'cachedHasTalent' .. id2s, true)
                return true
              end
            end
          end
        end
      end
      -- WotLK attempt for player.hasTalent supporting name and {row, column}
      if blink.gameVersion ~= 1 then
        if type(id) == "string" then
          local nameLower = id:lower()
          local exists = blink.availableTalents[nameLower]
          if exists then
            local ret = exists.rank
            if ret > 0 then
              cache.set(obj, 'cachedHasTalent' .. id2s, ret)
              return ret
            else
              cache.set(obj, 'cachedHasTalent' .. id2s, false)
              return false
            end
          else
            cache.set(obj, 'cachedHasTalent' .. id2s, false)
            return false
          end
        elseif type(id) == "table" then
          local tabIndex, talentIndex = id[1], id[2]
          for k, v in pairs(blink.availableTalents) do
            if v.tabIndex == tabIndex and v.talentIndex == talentIndex then
              local ret = v.rank
              if ret > 0 then
                cache.set(obj, 'cachedHasTalent' .. id2s, ret)
                return ret
              else
                cache.set(obj, 'cachedHasTalent' .. id2s, false)
                return false
              end
            end
          end
        end
      end

      if type(id) == "string" then
        local nameLower = id:lower()
        local exists = blink.availableTalents[nameLower]
        if exists then
          local ret = IsPlayerSpell(exists.id)
          cache.set(obj, 'cachedHasTalent' .. id2s, ret)
          return ret
        end
        local has = false
        cache.set(obj, 'cachedHasTalent' .. id2s, false)
        return false
      end
      cache.set(obj, 'cachedHasTalent' .. id2s, false)
      return false
    elseif blink.gameVersion ~= 1 then
      -- if obj.enemy then
      -- return blink.UnitHasTalent(obj, id)
      -- else
      local LibInspect = blink.LibInspect
      if not LibInspect then
        return false
      end
      local guid = obj.guid
      if not guid then
        return false
      end
      LibInspect:Rescan(guid)
      local LI_CACHE = LibInspect:GetCachedInfo(guid)
      if not LI_CACHE then
        return false
      end
      if type(id) == "string" then
        id = id:lower()
      end
      if LI_CACHE.talents[id] then
        cache.set(obj, 'cachedHasTalent' .. id2s, true)
        return true -- cache.talents[id]
      else
        for k, v in pairs(LI_CACHE.talents) do
          if v.spell_id == id or v.name_localized:lower() == id then
            cache.set(obj, 'cachedHasTalent' .. id2s, true)
            return true
          end
        end
      end
      if LI_CACHE.pvp_talents[id] then
        cache.set(obj, 'cachedHasTalent' .. id2s, true)
        return true
      else
        for k, v in pairs(LI_CACHE.pvp_talents) do
          if v.spell_id == id or v.name_localized:lower() == id then
            cache.set(obj, 'cachedHasTalent' .. id2s, true)
            return true
          end
        end
      end
      cache.set(obj, 'cachedHasTalent' .. id2s, false)
      return false
    end
    -- end
  end

  local posProto = {}
  function obj.position()
    if obj.cachedPosition then
      return obj.cachedPosition[1], obj.cachedPosition[2], obj.cachedPosition[3]
    else
      if IsWoWGameObject then
        if not obj.pointer then
          return
        end
        local x, y, z = obj.pointer:position()
        -- local pcache = { x, y, z }
        posProto[1] = x
        posProto[2] = y
        posProto[3] = z
        cache.set(obj, 'cachedPosition', posProto)
        return x, y, z
      else
        if not obj.pointer then
          return
        end
        local x, y, z = ObjectPosition(obj.pointer)
        -- local pcache = { x, y, z}
        posProto[1] = x
        posProto[2] = y
        posProto[3] = z
        cache.set(obj, 'cachedPosition', posProto)
        return x, y, z
      end
    end
  end

  -- function obj.position()
  -- 	if IsWoWGameObject then
  -- 		if not obj.pointer then
  -- 			return false
  -- 		end
  -- 		local x,y,z = obj.pointer:position()
  -- 		if not x then
  -- 			x,y,z = ObjectPosition(obj.pointer)
  -- 		end
  -- 		return x,y,z
  -- 	elseif not obj.cache.position or #obj.cache.position < 3 then
  -- 		obj.cache.position = {ObjectPosition(obj.pointer)}
  -- 		return unpack(obj.cache.position)
  -- 	else
  -- 		return unpack(obj.cache.position)
  -- 	end
  -- end

  function obj.predictPosition(elapsed)
    elapsed = elapsed or 1
    local x, y, z = obj.position()

    local direction = obj.movingDirection

    if not direction then
      blink.debug.print("invalid object direction in predictposition.", "debug")
      if not x then
        blink.debug.print("object must not exist in predictposition check? no coords found.", "debug")
      end
      return x, y, z
    end

    local distance = (obj.speed or 0) * elapsed

    if obj.speed == 0 then
      return x, y, z
    end

    if not x then
      blink.debug.print("no position for object in predictposition. object probably not visible.", "debug")
      return x, y, z
    end

    if not distance or not direction then
      blink.debug.print("no distance or direction for predictposition. object probably not visible.", "debug")
      return x, y, z
    end

    local px = x + distance * math.cos(direction)
    local py = y + distance * math.sin(direction)
    local pz = z

    -- local zdif1
    -- local zdif2

    local tx, ty, tz = blink.TraceLine(x, y, z + 2, px, py, pz + 2, blink.collisionFlags)

    if tx == 0 then
      local fx, fy, fz = px, py, pz
      local gx, gy, gz = blink.TraceLine(fx, fy, fz + 4, fx, fy, -10000, blink.collisionFlags)
      return gx, gy, gz ~= 0 and gz or fz
    else
      local fx, fy, fz = blink.PositionBetween(tx, ty, tz, x, y, z, 0.25)
      local gx, gy, gz = blink.TraceLine(fx, fy, fz + 4, fx, fy, -10000, blink.collisionFlags)
      return gx, gy, gz ~= 0 and gz or fz
    end
  end

  function obj.predictDistanceTo(given, elapsed)
    local o = given and given or blink.player
    local px, py, pz = o.predictPosition(elapsed)
    local x, y, z = obj.predictPosition(elapsed)
    return blink.Distance(px, py, pz, x, y, z) - obj.combatReach - o.combatReach
  end

  function obj.predictDistanceToPosition(x, y, z, elapsed)
    elapsed = elapsed or 0
    local px, py, pz = obj.predictPosition(elapsed)
    return blink.Distance(px, py, pz, x, y, z)
  end

  function obj.predictDistance(elapsed, given)
    local o = given and given or blink.player
    local px, py, pz = o.predictPosition(elapsed)
    local x, y, z = obj.predictPosition(elapsed)
    return blink.Distance(px, py, pz, x, y, z) - obj.combatReach - o.combatReach
  end

  function obj.predictDistanceLiteral(elapsed, given)
    local o = given and given or blink.player
    local px, py, pz = o.predictPosition(elapsed)
    local x, y, z = obj.predictPosition(elapsed)
    return blink.Distance(px, py, pz, x, y, z)
  end

  function obj.predictLoS(elapsed)
    local px, py, pz = blink.player.predictPosition(elapsed)
    local x, y, z = obj.predictPosition(elapsed)
    if not x or not y or not z then
      blink.debug.print('no obj coords in LoS prediction, obj probably not visible', 'debug')
      return false
    end
    return blink.TraceLine(px, py, pz + 1.7, x, y, z + 1.7, blink.losFlags) == 0
  end

  function obj.predictLoSOf(otherObj, elapsed)
    local tx, ty, tz = otherObj.predictPosition(elapsed)
    local x, y, z = obj.predictPosition(elapsed)
    return blink.TraceLine(x, y, z + 1.7, tx, ty, tz + 1.7, blink.losFlags) == 0
  end

  function obj.predictLoSOfCoords(tx, ty, tz, elapsed)
    local x, y, z = obj.predictPosition(elapsed)
    return blink.TraceLine(x, y, z + 1.7, tx, ty, tz + 1.7, blink.losFlags) == 0
  end

  obj.predictDist = obj.predictDistance

  function obj.distanceTo(otherObj, y, z)
    if not player then
      player = blink.player
    end
    if not otherObj then
      return blink.Distance(player, obj) - obj.combatReach - player.combatReach
    elseif y then
      return blink.Distance(obj, otherObj, y, z) - obj.combatReach
    elseif otherObj.visible then
      return blink.Distance(obj, otherObj) - obj.combatReach - otherObj.combatReach
    end
    blink.debug.print("object didn't exist in distance check? returned a bunch of 9's.", "debug")
    return 999999
  end

  function obj.distanceToLiteral(otherObj, y, z)
    if not player then
      player = blink.player
    end
    if not otherObj then
      return blink.Distance(player, obj)
    elseif y then
      return blink.Distance(obj, otherObj, y, z)
    elseif otherObj.visible then
      return blink.Distance(obj, otherObj)
    end
    blink.debug.print("object didn't exist in distanceLiteral check? returned a bunch of 9's.", "debug")
    return 999999
  end

  function obj.meleeRangeOf(otherObj)
    otherObj = otherObj or blink.player
    local x, y, z = obj.position()
    local px, py, pz = otherObj.position()
    if not x or not px then
      return false
    end

    local maxMeleeRange = 5

    local acrobatic = blink.player.hasTalent(196924)
    if acrobatic then
      maxMeleeRange = maxMeleeRange + 3
    end

    local deftManeuvers = blink.player.hasTalent(381878)
    if deftManeuvers then
      if blink.player.buff(13877) then
        maxMeleeRange = maxMeleeRange + 2
      end
    end

    local astralInfluence = blink.player.hasTalent(197524)
    if astralInfluence then
      local value = astralInfluence == 1 and 1 or 3
      maxMeleeRange = maxMeleeRange + value
    end

    
    --no more in TWW
    -- local lunge = blink.player.hasTalent(378934)
    -- if lunge then
    --   maxMeleeRange = maxMeleeRange + 3
    -- end

    local meleeRange = 5
    if otherObj.player and obj.player then
      meleeRange = (max(otherObj.combatReach + obj.combatReach + 4 / 3 +
          (otherObj.moving and obj.moving and 8 / 3 or .5), maxMeleeRange))
    else
      meleeRange = max(otherObj.combatReach + obj.combatReach + 1.3333, maxMeleeRange)
    end

    if blink.gameVersion == 1 then
      meleeRange = meleeRange + 1
    end

    local d = blink.Distance(x, y, z, px, py, pz)
    if not d then
      blink.debug.print(
        "couldn't get distance in meleerange check? returned false to avoid math on bool values and fail gracefully.",
        "debug")
      return false
    end
    return d <= meleeRange
  end

  function obj.face(dir, update)
    if type(dir) == "table" then
      local px, py, pz = blink.player.position()
      local tx, ty, tz = dir.position()
      if tx and px then
        local angle = blink.AnglesBetween(px, py, pz, tx, ty, tz)
        -- blink.Draw(function(draw) draw:Line(px,py,pz, px+5*math.cos(angle), py+5*math.sin(angle), pz, 5) end)
        local random_rotation = blink.delays.short.now * 0.1
        if math.random(1, 2) == 2 then
          random_rotation = -random_rotation
        end
        angle = blink.rotate(angle, random_rotation)
        blink.FaceDirection(angle, update)
      end
    elseif type(dir) == "number" then
      blink.FaceDirection(dir, update)
    else
      local px, py, pz = blink.player.position()
      local tx, ty, tz = obj.position()
      if tx and px then
        local angle = blink.AnglesBetween(px, py, pz, tx, ty, tz)
        -- blink.Draw(function(draw) draw:Line(px,py,pz, px+5*math.cos(angle), py+5*math.sin(angle), pz, 5) end)
        blink.FaceDirection(angle, update)
      end
    end
  end

  obj.Face = obj.face

  function obj.facingUnit(otherUnit, angle)
    if type(otherUnit) == "number" then
      local x, y, z = obj.position()
      x = x + math.cos(otherUnit) * 7
      y = y + math.sin(otherUnit) * 7
      return blink.UnitIsFacingPosition(obj, x, y, z, angle)
    end
    if not otherUnit.position then
      return false
    end
    local x, y, z = otherUnit.position()
    return x and blink.UnitIsFacingPosition(obj, x, y, z, angle)
    -- return blink.UnitIsFacingUnit(obj, otherUnit, angle)
  end

  function obj.facingPosition(x, y, z, angle)
    return blink.UnitIsFacingPosition(obj, x, y, z, angle)
  end

  function obj:ClearCache()
    self.cache = {}
    for k, v in pairs(self.cacheLiteral) do
      obj[k] = nil
    end
    self.cacheLiteral = {}
  end

  -- static object updates
  if type(ref) == "string" then
    blink.onUpdate(function()
      obj:ClearCache()
    end)

    -- update the object OnEvent
    local function update()
      if (ref == "arena1" or ref == "arena2" or ref == "arena3" or ref == "arena4" or ref == "arena5") and
          not blink.arena and blink.instanceType2 ~= "pvp" then
        return
      end
      obj:ClearCache()
      if ref ~= "player" and not UnitIsVisible(ref) then
        obj.truePointer = nil
        return
      end

      local ptr = Object(ref) or ref == "player" and obj.truePointer
      obj.truePointer = ptr
      -- if not ptr then return end
      -- local guid = tostring(ptr)
      -- if not guid then return end
      -- objectsByGUID[guid] = obj
    end

    update()

    if ref == "target" then
      blink.onEvent(update, "PLAYER_TARGET_CHANGED")
    elseif ref == "focus" then
      blink.onEvent(update, "PLAYER_FOCUS_CHANGED")
    elseif ref == "pet" then
      blink.onEvent(update, "UNIT_PET")
    elseif ref == "mouseover" then
      blink.onEvent(update, "UPDATE_MOUSEOVER_UNIT")
    elseif ref == "healer" or ref == "tank" or ref == "enemyHealer" then
      C_Timer.NewTicker(0.2, function()
        local ptr = GetStaticObject(ref)
        obj.truePointer = ptr
        obj:ClearCache()
        -- local guid = tostring(ptr)
        -- if not guid then return end
        -- objectsByGUID[guid] = obj
      end)
    elseif ref ~= "player" then
      C_Timer.NewTicker(0.1, update)
    else
      C_Timer.NewTicker(0.2, update)
    end
  end

  function obj:Delete()
    self = nil
  end

  if type(ref) == "string" then
    blink.internal[ref] = obj
  elseif ref and blink.inserted[ref] then
    blink.inserted[ref][obj] = true
    ref[#ref + 1] = obj
    objectsByGUID[guid] = obj
  else
    if guid then
      objectsByGUID[guid] = obj
    end
  end

  return obj
end

local createObject = blink.createObject

createObject(Object("player"), "player")

createObject(Object("target"), "target")

createObject(Object("focus"), "focus")

createObject(Object("mouseover"), "mouseover")

createObject(Object("pet"), "pet")

createObject(Object("arena1"), "arena1")
createObject(Object("arena2"), "arena2")
createObject(Object("arena3"), "arena3")
createObject(Object("arena4"), "arena4")
createObject(Object("arena5"), "arena5")

createObject(Object("party1"), "party1")
createObject(Object("party2"), "party2")
createObject(Object("party3"), "party3")
createObject(Object("party4"), "party4")

createObject(GetStaticObject("healer"), "healer")

createObject(GetStaticObject("tank"), "tank")

createObject(GetStaticObject("enemyHealer"), "enemyHealer")

local listIndex = {
  __index = function(self, key)
    if type(key) == "number" then
      return rawget(self, key)
    end

    -- values
    if key == "lowest" then
      local lowest = 101
      local member
      for i = 1, #self do
        local hp = self[i].hp
        if hp and hp > 0 and hp < lowest then
          member = self[i]
          lowest = hp
        end
      end
      lowest = member or unitPrototype
      self.lowest = lowest
      return lowest
    end

    -- functions
    if key == "around" then
      return function(unit, dist, criteria)
        return listMethods.around(self, unit, dist, criteria)
      end
    elseif key == "plus" then
      return function(other)
        return listMethods.plus(self, other)
      end
    elseif key == "near" then
      return function(unit, dist, criteria)
        return listMethods.near(self, unit, dist, criteria)
      end
    elseif key == "targeting" then
      return function(unit, criteria)
        return listMethods.targeting(self, unit, criteria)
      end
    elseif key == "rect" then
      return function(x, y, z, w, l, a, criteria)
        return listMethods.rect(self, x, y, z, w, l, a, criteria)
      end
    elseif key == "arcAngle" then
      return function(r, a, steps, criteria, object)
        return listMethods.arcAngle(self, r, a, steps, criteria, object)
      end
    elseif key == "arc" then
      return function(x, y, z, r, a, criteria)
        return listMethods.arc(self, x, y, z, r, a, criteria)
      end
    elseif key == "sort" then
      return function(sortingFunction)
        tsort(self, sortingFunction)
        return self
      end
    elseif key == "stomp" then
      return function(callback, options)
        return listMethods.stomp(self, callback, options)
      end
    elseif key == "loop" or key == "iterate" or key == "forEach" or key == "foreach" then
      return function(callback)
        return listMethods.iterate(self, callback)
      end
    elseif key == "track" then
      return function(callback, options)
        return listMethods.track(self, callback, options)
      end
    elseif key == "within" then
      return function(dist)
        return listMethods.within(self, dist)
      end
    elseif key == "filter" then
      return function(callback)
        return listMethods.filter(self, callback)
      end
    elseif key == "find" then
      return function(callback)
        for i = 1, #self do
          local unit = self[i]
          if callback(unit) then
            return unit
          end
        end
      end
    elseif key == "byid" or key == "byID" or key == "byId" then
      return function(id)
        local isTable = type(id) == "table"
        local list = {}
        for i = 1, #self do
          local unit = self[i]
          if isTable then
            if tContains(id, unit.id or "") or tContains(id, unit.spellId or "") then
              list[#list + 1] = unit
            end
          elseif unit.id == id or unit.spellId == id then
            list[#list + 1] = unit
          end
        end
        blink.immerseOL(list)
        return list
      end
    elseif key == "simplify" then
      return function(tolerance, highestQuality)
        local newPath = blink.simplifyPath(self, tolerance, highestQuality)
        -- wipe(self)
        -- for i=1,#newPath do
        -- 	self[i] = newPath[i]
        -- end
        return newPath
      end
    elseif key == "follow" then
      return function()
        if #self < 1 then
          return
        end
        local complete
        local lrx, lry, lrz
        self.loop(function(p, i)
          local x, y, z = p.x, p.y, p.z
          if x and y and z then
            player = player or blink.player
            local dist = player.distanceToLiteral(x, y, z)
            if dist > 0.5 then
              if not blink.lastMoveToCall then
                blink.lastMoveToCall = GetTime()
              elseif GetTime() - blink.lastMoveToCall < 0.055 then
                return true
              else
                blink.lastMoveToCall = GetTime()
              end
              local offset = (0.35 + player.speed2/7)
              if dist < 1 + offset and i < #self then
                local px, py, pz = player.position()
                local nx, ny, nz
                local nextPt = self[i + 1]
                if nextPt then
                  nx, ny, nz = nextPt.x, nextPt.y, nextPt.z
                else
                  nx, ny, nz = x, y, z
                end
                local a = blink.anglesBetween(px, py, pz, nx, ny, nz)
                x, y, z = x + math.cos(a) * offset, y + math.sin(a) * offset, z
                lrx, lry, lrz = x, y, z
              else
                MoveTo(x, y, z)
                complete = true
                return true
              end
            end
          end
        end)
        if not complete and lrx and lry and lrz then
          MoveTo(lrx, lry, lrz)
        end
      end
    elseif key == "reasonableAngleChange" then
      return function(node1, node2)
        local px, py, pz = player.position()
        local angleBetweenPlayerAndNode1 = blink.anglesBetween(px, py, pz, node1.x, node1.y, node1.z)
        local angleBetweenNode1AndNode2 = blink.anglesBetween(node1.x, node1.y, node1.z, node2.x, node2.y, node2.z)
        local angleDiff = blink.angleDist(angleBetweenPlayerAndNode1, angleBetweenNode1AndNode2, true)
        return angleDiff < 1.5
      end
    elseif key == "draw" then
      return function()
        blink:DrawPath(self)
      end
    end
  end
}

blink.immerseOL = function(list)
  return setmetatable(list, listIndex)
end

local sortPointer
blink.clearInternalCaches = function()
  sortPointer = sortPointer or blink.sortPointer
  blink.internal.loaded = {}

  -- clear caches, wipe non existent units
  for i = 1, #objectLists do
    local list = blink.internal[objectLists[i]]
    if list then
      for i = #list, 1, -1 do
        local object = list[i]
        if object then
          -- thisList[k] = nil
          local cl = object.cacheLiteral
          if cl then
            for k, v in pairs(cl) do
              object[k] = nil
            end
          end
          object.cacheLiteral = {}
          object.cache = {}
          if not object.exists then
            tremove(list, i)
            if object.guid then
              objectsByGUID[object.guid] = nil
            end
          end
        else
          tremove(list, i)
        end
      end
    end
  end

  if Tinkr.type == "daemonic" then
    local all = {}
    -- sort objects by type
    for i = 1, 17 do
      all[i] = {}
    end
    for i = 1, GetObjectCount() do
      local pointer = GetObjectWithIndex(i)
      local type = ObjectType(pointer)
      if type and UnitCreatureType(pointer) ~= "Critter" then
        all[type][#all[type] + 1] = pointer
      end
    end
    blink.internal.all = all
  elseif Tinkr.type == "noname" then
    blink.populateAll_noname()
  end
end

for _, listType in ipairs(objectLists) do
  if not blink.internal[listType] then
    blink.internal[listType] = setmetatable({}, listIndex)
  else
    local thisList = blink.internal[listType]
    for k, v in pairs(thisList) do
      thisList[k] = nil
    end
  end
end

blink.internal.afflicteds = setmetatable({}, listIndex)

blink.Lists = {}
blink.inserted = {}
blink.updateObjectLists = function()
  local debug = blink.debug

  local time = blink.time or GetTime()

  profilerEnabled = blink.Profiler.started

  -- clear memo
  for cat, t in pairs(cache.memo) do
    local last_cleared = t.last_cleared
    if not last_cleared or time - last_cleared > t.refresh_after then
      t.last_cleared = time
      for key, value in pairs(t) do
        if key ~= 'last_cleared' and key ~= 'refresh_after' then
          t[key] = nil
        end 
      end
    end
  end

  -- clear obj init detections if no successful existence check in last 600ms
  for pointerString, timeDetected in pairs(objectExistenceLastChecked) do
    if time - timeDetected > 0.6 then
      objectFirstDetected[pointerString] = nil
      objectExistenceLastChecked[pointerString] = nil
    end
  end

  -- clear obj init detections after 600s
  for pointerString, timeDetected in pairs(objectFirstDetected) do
    if time - timeDetected > 600 then
      objectFirstDetected[pointerString] = nil
      objectExistenceLastChecked[pointerString] = nil
    end
  end

  -- clear los tracker entries after 10s
  for k, v in pairs(LoSTracker) do
    for i = #v, 1, -1 do
      if v[i] and time - v[i].time > 10 then
        tremove(v, i)
      end
    end
  end

  -- refresh object lists
  for _, listType in ipairs(objectLists) do
    if not blink.internal[listType] then
      blink.internal[listType] = setmetatable({}, listIndex)
    else
      local thisList = blink.internal[listType]
      wipe(thisList)
    end
    blink.inserted[blink.internal[listType]] = {}
  end

  for _, list in ipairs(blink.Lists) do
    list:Clear()
  end

  -- group
  for i = 1, GetNumGroupMembers() do
    local ref = blink.groupType .. i
    if UnitIsVisible(ref) and not UnitIsUnit(ref, "player") then
      local member = createObject(Object(ref), blink.internal.group)
      member.tag = ref
    end
  end

  -- fullGroup
  for i = 1, GetNumGroupMembers() do
    local ref = blink.groupType .. i
    if UnitIsVisible(ref) then
      local member = createObject(Object(ref), blink.internal.fullGroup)
      member.tag = ref
    end
  end

  if blink.groupType ~= "raid" then
    tinsert(blink.internal.fullGroup, blink.player)
  end

  for i, member in ipairs(blink.internal.group) do
    if member.dead then
      tremove(blink.internal.group, i)
    end
  end

  for i, member in ipairs(blink.internal.fullGroup) do
    if member.dead then
      tremove(blink.internal.fullGroup, i)
    end
  end
end

blink.player.tag = 'player'

function blink.player.timeToRunes(x)
  if x == 0 then
    return 0
  end
  if x > 6 then
    return huge
  end
  if blink.player.runes >= x then
    return 0
  end
  local runes = {}
  for i = 1, 6 do
    local rune = {}
    local start, cd, ready = GetRuneCooldown(i)
    if not ready then
      rune.cd = start + cd - GetTime()
      tinsert(runes, rune)
    end
  end
  table.sort(runes, function(x, y)
    return x.cd < y.cd
  end)
  local unsatisfied = x - blink.player.runes
  if unsatisfied <= #runes then
    return runes[unsatisfied].cd
  end
  local nth = unsatisfied - #runes
  return runes[nth].cd
end

blink.updateObjectLists()
