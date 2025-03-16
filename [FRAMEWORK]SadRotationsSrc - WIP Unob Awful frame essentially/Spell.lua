local Tinkr, blink = ...
local CastByID, GetSpellDescription = blink.CastByID, GetSpellDescription
local random, type, debug, ceil, select, min, max, abs, cos, sin, pi2 = math.random, type, blink.debug, math.ceil, select, min, max, math.abs, math.cos, math.sin, math.pi * 2
local player, pet, target = blink.player, blink.pet, blink.target
local gsub, tinsert, tonumber, sort = string.gsub, tinsert, tonumber, table.sort
local IsPlayerSpell, IsSpellKnown, IsUsableSpell, GetActionInfo = IsPlayerSpell, IsSpellKnown, C_Spell.IsSpellUsable, GetActionInfo
local GetSpellCharges, GetSpellInfo, GetSpellBaseCooldown, IsCurrentSpell = GetSpellCharges, GetSpellInfo, GetSpellBaseCooldown, C_Spell.IsCurrentSpell
local env, setmetatable = getfenv(1), setmetatable
local FastDistance, TraceLine = FastDistance, TraceLine
local losFlags, collisionFlags = blink.losFlags, blink.collisionFlags
local tremove, GetTime = tremove, GetTime
local Click = Click or ClickPosition
local unlockerType = Tinkr.type or "tinkr"
--[[ 
local covenantSpells = {
  [391888] = "Adaptive Swarm",
  [375982] = "Primordial Wave",
  [389815] = "Elysian Decree",
  [370965] = "The Hunt",
  [386276] = "Bonedust Brew",
  [375576] = "Divine Toll",
  [386997] = "Soul Rot",
  [375901] = "Mindgames",
  [385408] = "Sepsis",
  [376079] = "Spear of Bastion",
  [388193] = "Faeline Stomp",
  [391528] = "Convoke the Spirits", -- feral
  [385616] = "Echoing Reprimand",
  [385424] = "Serrated Bone Spike"
} ]]

local spellsByID = {}
blink.spellsByID = spellsByID

blink.SpellObjects = {}

local kicks = {2139, 19647, 106839, 6552, 147362, 187707, 1766, 96231, 78675, 57994, 116705, 183752, 47528, 351338}

local empowered = {
  [357208] = "Fire Breath",
  [355936] = "Dream Breath",
  [367226] = "Spirit Bloom"
}

local actions = {}
local actionBars = {'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft'}

local function getActionSlotBySpellName(spellName)
  for _, barName in pairs(actionBars) do
    for i = 1, 12 do
      local button = _G[barName .. 'Button' .. i]
      if button then
        local slot = button.GetPagedID and button:GetPagedID() or button.CalculateAction and button:CalculateAction() or button.GetAttribute and button:GetAttribute('action')
        if HasAction(slot) then

          local actionType, id = GetActionInfo(slot)
          if actionType == 'macro' then
            _, _, id = GetMacroSpell(id)
          end

          local actionName
          if actionType == 'item' then
            actionName = GetItemInfo(id)
          elseif actionType == 'spell' or (actionType == 'macro' and id) then
            actionName = C_Spell.GetSpellInfo(id).spellID
          end

          if actionName == spellName then
            return slot
          end
        end
      end
    end
  end
end

local stances = {}

for i = 1, 10 do
  local spellID = select(4, GetShapeshiftFormInfo(i))
  if spellID then
    stances[spellID] = true
  end
end

if WOW_PROJECT_ID == 1 then
  blink.addEventCallback(function()
    for i = 1, 10 do
      local spellID = select(4, GetShapeshiftFormInfo(i))
      if spellID then
        stances[spellID] = true
      end
    end
  end, "PLAYER_SPECIALIZATION_CHANGED")
end

blink.fired_this_frame = {}

local spellCallbacks = {}
local specificSpellCallbacks = {}
blink.hookSpellCallbacks = function(callback, aliases)
  if aliases then
    for i = 1, #aliases do
      specificSpellCallbacks[aliases[i]] = callback
    end
  else
    tinsert(spellCallbacks, callback)
  end
end
blink.hookCallbacks = blink.hookSpellCallbacks

local castCallbacks = {}
blink.hookSpellCasts = function(callback)
  tinsert(castCallbacks, callback)
end

local spellFunctionCallbacks = {}
function blink.addSpellFunction(key, callback)
  spellFunctionCallbacks[key:lower()] = callback
end
blink.spellFunctionCallbacks = spellFunctionCallbacks

local customSpellTraits = {}
function blink.addSpellTrait(key, callback)
  customSpellTraits[key:lower()] = callback
end
blink.customSpellTraits = customSpellTraits

local attemptedCasts = {}

local function executeCastCallbacks(...)
  for i = 1, #castCallbacks do
    castCallbacks[i](...)
  end
end

local function executeCallbacks(t, ...)
  for i = 1, #t do
    t[i](...)
  end
end

local facingNotRequired = blink.spells.facingNotRequired
local critSpells = {
  [108853] = "Fire Blast",
  [257541] = "Phoenix Flames"
}
local stupidChannels = {}
local castableWhileMovingSpells = blink.spells.castableWhileMoving
local castWhileMovingBuffs = {79206, 12042, 108839, 329543}

local basicSort = function(x, y)
  return x > y
end
local function GetSpellEffect(spellID)
  if not spellID then
    return
  end
  local desc = C_Spell.GetSpellDescription(spellID)
  local blocks = {}
  for n in desc:gmatch("%S+") do
    tinsert(blocks, n)
  end
  local good = {}
  for i = 1, #blocks do
    local s = gsub(blocks[i], ",", "")
    tinsert(good, s)
  end
  local reallygood = {}
  for i = 1, #good do
    if tonumber(good[i]) then
      tinsert(reallygood, tonumber(good[i]))
    end
  end
  sort(reallygood, basicSort)
  return reallygood[1] or 0
end

-- local function cacheReturnTemplate(key, keyLower, selection, obj, func, returnType, ...)
--   local cache = obj.cache
--   if WOW_PROJECT_ID == 11 and SetTargetObject then
--     SetTargetObject("target")
--   end
--   if type(returnType) == "function" then
--     local rt, ri = returnType(keyLower)
--     local cached = cache[rt]
--     local funct = type(func) == "string" and env[func] or func
--     local val = cached or {funct(...)}
--     if cached == nil then
--       cache[rt] = val
--     end
--     local ret = val and val[ri or selection] or false
--     obj[key] = ret
--     obj.cacheLiteral[key] = ret
--     return ret
--   elseif type(returnType) == "number" then
--     local cached = cache[keyLower]
--     local funct = type(func) == "string" and env[func] or func
--     local val = cached or {funct(...)}
--     if cached == nil then
--       cache[keyLower] = val
--     end
--     local ret = val and val[returnType] or false
--     obj[key] = ret
--     obj.cacheLiteral[key] = ret
--     return ret
--   elseif returnType == "single" then
--     local cached = cache[keyLower]
--     local funct = type(func) == "string" and env[func] or func
--     local val = cached or funct(...)
--     if cached == nil then
--       cache[keyLower] = val
--     end
--     local ret = val or false
--     obj[key] = ret
--     obj.cacheLiteral[key] = ret
--     return ret
--   else
--     local cached = cache[keyLower]
--     local funct = type(func) == "string" and env[func] or func
--     local val = cached or {funct(...)}
--     if cached == nil then
--       cache[keyLower] = val
--     end
--     local ret = val and val[selection] or false
--     if selection == 1 then
--       obj[key] = ret
--       obj.cacheLiteral[key] = ret
--     else
--       obj[key .. selection] = ret
--       obj.cacheLiteral[key .. selection] = ret
--     end
--     return ret
--   end
-- end

local function cacheReturnTemplate(key, keyLower, selection, obj, func, returnType, ...)
  local cache = obj.cache
  if WOW_PROJECT_ID == 11 and SetTargetObject then
      SetTargetObject("target")
  end

  -- Ensure that func is a valid function
  local funct = type(func) == "string" and env[func] or func
  if type(funct) ~= "function" then
    -- Log or handle an error if func is not a valid function
    print("Error: 'func' is not a valid function for key:", key, " keyLower:", keyLower, " func:", tostring(func))
    return false -- Return a default value or handle the error as needed
  end

  -- Handle different return types
  if type(returnType) == "function" then
    local rt, ri = returnType(keyLower)
    local cached = cache[rt]
    local val = cached or {funct(...)}
    if cached == nil then
        cache[rt] = val
    end
    local ret = val and val[ri or selection] or false
    obj[key] = ret
    obj.cacheLiteral[key] = ret
    return ret
  elseif type(returnType) == "number" then
    local cached = cache[keyLower]
    local val = cached or {funct(...)}
    if cached == nil then
        cache[keyLower] = val
    end
    local ret = val and val[returnType] or false
    obj[key] = ret
    obj.cacheLiteral[key] = ret
    return ret
  elseif returnType == "single" then
    local cached = cache[keyLower]
    local val = cached or funct(...)
    if cached == nil then
        cache[keyLower] = val
    end
    local ret = val or false
    obj[key] = ret
    obj.cacheLiteral[key] = ret
    return ret
  else
    local cached = cache[keyLower]
    local val = cached or {funct(...)}
    if cached == nil then
      cache[keyLower] = val
    end
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


local function rmbFix()
  local controlling
  if IsMouseButtonDown("RightButton") then

    local currentTarget = target.pointer

    controlling = true
    TurnOrActionStop()
    TurnOrActionStart()

    if currentTarget ~= target.pointer and UnitIsVisible(currentTarget) then
      TargetUnit(currentTarget)
    end

  end
  if controlling then
    C_Timer.NewTicker(0, function(self)
      if not IsMouseButtonDown("RightButton") then
        TurnOrActionStop()
        self:Cancel()
      end
    end)
  end
end

local function aoeFix()
  if SpellIsTargeting() then
    SpellStopTargeting()
  end
end

local function checkDiam(diam)
  if type(diam) == "function" then
    return diam()
  end
  return diam or 0
end

local function checkRad(rad)
  if type(rad) == "function" then
    return rad() * 2
  end
  return rad and rad * 2 or 0
end

local join = blink.tjoin

blink.onTick(function()
  local _time = GetTime()
  for spellID, time in pairs(attemptedCasts) do
    if _time - time >= blink.tickRate * 2 and (not C_Spell.IsCurrentSpell(spellID) or _time - time > blink.tickRate * 4) then
      attemptedCasts[spellID] = nil
    end
  end
end)

function blink.NewSpell(spellID, options)

  
  local time = GetTime()
  options = options or {}
  
  if options.cache and spellsByID[spellID] then return spellsByID[spellID] end

  if options.stupidChannel then
    stupidChannels[spellID] = true
  end

  local isInterrupt = tContains(kicks, spellID)
  local isTable = type(spellID) == "table"

  local custom_methods, custom_traits = {}, {}

  local spellFunctions = function(self, key)

    if custom_traits[key] then
      return custom_traits[key](self)
    end

    if custom_methods[key] then
      return custom_methods[key]
    end

    local ogKey = key
    local cacheReturn = self.cacheReturn

    local selection = key:match("%d+")
    if selection then
      key = gsub(key, selection, "")
    end
    selection = selection and tonumber(selection) or 1
    local keyLower = key:lower()
    local time = blink.time

    local ofcb = spellFunctionCallbacks[keyLower]
    if ofcb then
      return function(...)
        return ofcb(self, ...)
      end
    end

    local oacb = customSpellTraits[keyLower]
    if oacb then
      return oacb(self)
    end

    if keyLower == "flying" or keyLower == "isflying" then
      return cacheReturn(ogKey, keyLower, selection, blink.spellFlying, "single", self.id)
      -- elseif keyLower == "casttimeraw"  then
      --     return cacheReturn(ogKey, keyLower, selection, blink.castTime, "single", self.id, true)
    elseif keyLower == "known" then
      local check = function()
        return IsSpellKnown(self.id) or IsPlayerSpell(self.id) or self.name and C_Spell.GetSpellInfo(self.name)--C_Spell.GetSpellInfo(self.name).spellID
      end
      return cacheReturn(ogKey, keyLower, selection, check, "single")
    elseif keyLower == "playerspell" or keyLower == "isplayerspell" then
      return cacheReturn(ogKey, keyLower, selection, IsPlayerSpell, "single", self.id)
    elseif keyLower == "usable" then
      local id = self.id -- don't question this.
      local res = cacheReturn(ogKey, keyLower, selection, C_Spell.IsSpellUsable, "single", self.id)
      -- print(id, res)
      return res
    elseif keyLower == "casttime" or keyLower == "casttimeraw" then
      return cacheReturn(ogKey, keyLower, selection, blink.castTime, "single", self.id, true)
    elseif keyLower == "charges" or keyLower == "stacks" then
      local chargesFunc = function()
        local chargeInfo = C_Spell.GetSpellCharges(self.id)
        return chargeInfo and chargeInfo.currentCharges or 0
      end
      return cacheReturn(ogKey, keyLower, selection, chargesFunc, "single")
    elseif keyLower == "nextchargecd" then
      return (ceil(self.chargesFrac) - self.chargesFrac) * self.baseCD
    elseif keyLower == "name" or keyLower == "info" then
      local GetSpellInfoIn = function()
        return C_Spell.GetSpellInfo(self.id).name
      end
      return cacheReturn(ogKey, keyLower, selection, GetSpellInfoIn, "multi", self.id)
    elseif keyLower == "count" then
      return cacheReturn(ogKey, keyLower, selection, GetSpellCount, "single", self.id)
    elseif keyLower == "gcd" then
      local f = function()
        local gcd = select(2, GetSpellBaseCooldown(self.id))
        if gcd then
          gcd = gcd / 1000
          return gcd / (1 + player.haste)
        end
        return 0
      end
      return cacheReturn(ogKey, keyLower, selection, f, "single")
    elseif keyLower == "cd" or keyLower == "cooldown" then
      return cacheReturn(ogKey, keyLower, selection, blink.cooldown, "single", self.id)
    elseif keyLower == "id" or keyLower == "spellid" then
      return self.pointer
    elseif keyLower == "damage" or keyLower == "effect" then
      local dmgFunc = function()
        local effect = GetSpellEffect(self.id)
        local cpCost = self.cost.cp
        if cpCost ~= 0 then
          local effectPerCP = (effect / player.cpmax)
          local cpDeficit = player.cpMax - player.cp
          effect = effect - (effectPerCP * cpDeficit)
          return effect
        else
          return effect
        end
        return 0
      end
      return cacheReturn(ogKey, keyLower, selection, dmgFunc, "single")
    elseif keyLower == "frac" or keyLower == "chargesfrac" or keyLower == "chargesfractional" or keyLower == "fractional" or keyLower == "fractionalcharges" or keyLower == "fraccharges" or keyLower ==
      "cdstart" or keyLower == "maxcharges" or keyLower == "maxcharge" or keyLower == "max" or keyLower == "chargesmax" or keyLower == "cap" or keyLower == "cdduration" or keyLower == "range" then
      local chargesFrac = function()
        if keyLower == "frac" or keyLower == "chargesfrac" or keyLower == "chargesfractional" or keyLower == "fractional" or keyLower == "fractionalcharges" or keyLower == "fraccharges" then
          return time - self.cdStart > 0 and self.charges + ((time - self.cdStart) / self.cdDuration) or self.charges
        elseif keyLower == "cdstart" then
          return self.charges3
        elseif keyLower == "maxcharges" or keyLower == "maxcharge" or keyLower == "chargesmax" or keyLower == "cap" or keyLower == "max" then
          return self.charges2
        elseif keyLower == "cdduration" then
          return self.charges4
        elseif keyLower == "range" then
          return C_Spell.GetSpellInfo(self.id).maxRange --self.info6
        end
      end
      return cacheReturn(ogKey, keyLower, selection, chargesFrac, "single")
    elseif keyLower == "queued" or keyLower == "isqueued" or keyLower == "current" or keyLower == "iscurrent" then
      local isCurrent = function()
        local current = C_Spell.IsCurrentSpell(self.id)
        if current then
          if self.castTime > 0 and player.castRemains <= blink.spellCastBuffer + blink.tickRate then
            return false
          end
          return true
        elseif attemptedCasts[self.id] then
          if GetTime() - attemptedCasts[self.id] < blink.tickRate * 4 then
            return true
          end
        end
        return false
      end
      return cacheReturn(ogKey, keyLower, selection, isCurrent, "single")
    elseif keyLower == "recentlyused" or keyLower == "usedrecently" or keyLower == "recentlycast" or keyLower == "recentcast" or keyLower == "recent" or keyLower == "used" then
      local yep = function(elapsed)
        if self.queued then
          return true
        end
        return player.recentlyUsed(self.pointer, elapsed)
      end
      return yep
    elseif keyLower == "whilecasting" or keyLower == "castablewhilecasting" or keyLower == "usablewhilecasting" then
      return options.castableWhileCasting
    elseif keyLower == "whilechanneling" or keyLower == "castablewhilechanneling" or keyLower == "usablewhilechanneling" then
      return options.castableWhileChanneling
    elseif keyLower == "fullrechargetime" or keyLower == "fullchargecd" or keyLower == "fullchargescd" or keyLower == "maxchargecd" or keyLower == "timetofull" or keyLower == "timetomax" or keyLower ==
      "timetomaxcharges" or keyLower == "maxrecharge" or keyLower == "maxrechargetime" or keyLower == "maxchargecd" or keyLower == "maxcd" or keyLower == "maxtime" or keyLower == "capcd" or keyLower ==
      "captime" or keyLower == "capcooldown" or keyLower == "timetocap" then
      local check = function()
        return self.totalCD - self.frac * self.baseCD
      end
      return cacheReturn(ogKey, keyLower, selection, check, "single")
    elseif keyLower == "channeling" then
      local check = function()
        return player.channelID == self.id
      end
      return cacheReturn(ogKey, keyLower, selection, check, "single")
    elseif keyLower == "casting" then
      local check = function()
        return player.castID == self.id
      end
      return cacheReturn(ogKey, keyLower, selection, check, "single")
    elseif keyLower == "totalcd" then
      local check = function()
        return self.baseCD * self.maxCharges
      end
      return cacheReturn(ogKey, keyLower, selection, check, "single")
    elseif keyLower == "basecd" or keyLower == "basecooldown" then
      local check = function()
        local basecd, recharge = GetSpellBaseCooldown(self.id), C_Spell.GetSpellCharges(self.id).cooldownDuration--select(4, GetSpellCharges(self.id)) 
        if recharge then
          return max(basecd / 1000, recharge)
        else
          return basecd / 1000
        end
      end
      return cacheReturn(ogKey, keyLower, selection, check, "single")
    else
      return rawget(self, key)
    end

  end

  local spellAttributes = {
    __index = spellFunctions,
    __call = function(self)
      blink.print("No __call method for Spell ['Name: " .. (self.name or "No spell name, likely incorrect SpellID.") .. " ID: " .. (self.id or "No spell ID?") ..
                    "'], please use the :Update or :Callback method to assign a function to be invoked upon calling this spell object.", true)
    end
  }

  local spell = setmetatable({
    -- pointer = spellID, 
    cache = {},
    cacheLiteral = {},
    smartAoECache = {},
    options = options,
    isInterrupt = isInterrupt
  }, spellAttributes)

  if not isTable then
    spell.pointer = spellID
  else
    local applied = false
    for _, id in ipairs(spellID) do
      if IsSpellKnown(id) or IsPlayerSpell(id) or IsSpellKnown(id, true) then
        spell.pointer = id
        applied = true
        break
      end
    end
    if not applied then
      spell.pointer = spellID[1]
    end
  end

  spell.cacheReturn = function(key, keyLower, selection, ...)
    return cacheReturnTemplate(key, keyLower, selection, spell, ...)
  end
  ----a9ly
  -- local costFunc = function(self, key)
  --   local costs = GetSpellPowerCost(spell.id) or {}
  --   for _, cost in ipairs(costs) do
  --     local name = cost.name:lower():gsub("_", "")
  --     if name and type(cost.cost) == "number" then
  --       if (name:match(key:lower()) or key:lower() == "cp" and name:match("combo")) then
  --         return cost.cost
  --       end
  --       spell.cost[name] = cost.cost
  --     end
  --   end
  --   return 0
  -- end

  -- local costAttributes = {
  --   __index = costFunc
  -- }
  -- local cost = setmetatable({}, costAttributes)

  -- spell.cost = cost

  -- local costs = GetSpellPowerCost(spell.id)
  -- if type(costs) == "table" then
  --   for _, cost in ipairs(costs) do
  --     local name = cost.name
  --     if name and type(cost.cost) == "number" then
  --       spell.cost[name] = cost.cost
  --     end
  --   end
  -- end
    local costFunc = function(self, key)
      -- Use the new API to get power cost info
      local costs = C_Spell.GetSpellPowerCost(spell.id) or {}
      
      -- Loop through each power cost info
      for _, cost in ipairs(costs) do
          -- Normalize the name (e.g., "MANA" becomes "mana")
          local name = cost.name:lower():gsub("_", "")
          
          if name and type(cost.cost) == "number" then
              -- Match the key (e.g., if key is "cp", check for "combo points")
              if (name:match(key:lower()) or key:lower() == "cp" and name:match("combo")) then
                  return cost.cost -- Return the relevant cost if matched
              end
              -- Store the cost in the spell.cost table for reference
              spell.cost[name] = cost.cost
          end
      end
      
      -- Default return if no cost is found
      return 0
    end

    -- Set cost attributes to use costFunc when accessed
    local costAttributes = {
        __index = costFunc
    }

    -- Initialize spell.cost with a metatable to use costFunc
    local cost = setmetatable({}, costAttributes)

    -- Assign the cost table to the spell object
    spell.cost = cost

    -- Use the new API to get power costs and store them in spell.cost
    local costs = C_Spell.GetSpellPowerCost(spell.id)
    if type(costs) == "table" then
        for _, cost in ipairs(costs) do
            local name = cost.name
            if name and type(cost.cost) == "number" then
                spell.cost[name] = cost.cost -- Store the power cost in the table
            end
        end
    end

  spell.IsInRange = function(obj)
    return blink.spellInRange(spell.id, obj)
  end
  spell.inRange = spell.IsInRange
  spell.InRange = spell.IsInRange
  spell.isInRange = spell.IsInRange

  spell.callbackHooks = {}
  function spell:HookCallback(callback)
    tinsert(self.callbackHooks, callback)
  end

  spell.castCallbacks = {}
  function spell:CastCallback(callback)
    tinsert(spell.castCallbacks, callback)
  end

  spell.castHooks = {}
  function spell:HookCast(callback)
    tinsert(self.castHooks, callback)
  end
  
  function spell:Trait(key, callback)
    custom_traits[key] = callback
  end

  function spell:Method(key, callback)
    custom_methods[key] = function(...)
      return callback(self, ...)
    end
  end

  function spell:OnCastSuccess(callback)
    tinsert(blink.spellCastSuccessCallbacks, function(...)
      callback(spell, ...)
    end)
    self.onCastSuccessHooked = true
  end

  function spell:ClearCache()
    if isTable then
      self.pointer = nil
      local applied = false
      for _, id in ipairs(spellID) do
        if IsSpellKnown(id) or IsPlayerSpell(id) or IsSpellKnown(id, true) then
          rawset(self, 'pointer', id)
          applied = true
          break
        end
      end
      if not applied then
        rawset(self, 'pointer', spellID[1])
      end
    end
    self.cache = {}
    for k, v in pairs(self.cacheLiteral) do
      self[k] = nil
    end
    self.cacheLiteral = {}
    for i = #self.smartAoECache, 1, -1 do
      local cache = self.smartAoECache[i]
      if GetTime() - cache.time > 0.5 then
        tremove(self.smartAoECache, i)
      end
    end
  end

  function spell:Callbacks(callbacks)
    for k, v in pairs(callbacks) do
      self:Callback(k, v)
    end
  end

  function spell:Callback(key, callback)

    self:ClearCache()
    self.callbacks = self.callbacks or {}
    local parent = spell.parent or {}

    if type(key) == "function" and not callback then
      local spell_env = setmetatable({}, {
        __index = function(self, k)
          return env[k] or parent[k] or blink[k]
        end
      })
      setfenv(key, spell_env)
      self.callbacks["DEFAULT_CALLBACK"] = key
    else
      if not key then
        blink.debug.print("no key given to spell callback", "debug")
        return false
      end
      if type(callback) ~= "function" then
        blink.debug.print("invalid callback passed to spell:Callback", "debug")
        return false
      end

      local spell_env = setmetatable({}, {
        __index = function(self, k)
          return env[k] or parent[k] or blink[k]
        end
      })
      setfenv(callback, spell_env)

      self.callbacks[key] = callback
    end

    if not self.__call then
      setmetatable(self, {
        __index = spellFunctions,
        __call = function(self, k, ...)
          if not self.refreshingCache then
            blink.addUpdateCallback(function()
              self:ClearCache()
            end)
            self.refreshingCache = true
          end
          if not self.known then
            blink.debug.print("IsSpellKnown and IsPlayerSpell false for spellID:", self.id, "in Callback function", "harmless")
            return false
          end
          local DEFAULT_CALLBACK
          if type(k) ~= "string" then
            DEFAULT_CALLBACK = self.callbacks["DEFAULT_CALLBACK"]
            if type(DEFAULT_CALLBACK) ~= "function" then
              blink.debug.print("empty key passed to spell callback label...", "debug")
              return false
            end
          end
          if not DEFAULT_CALLBACK and not self.callbacks[k] then
            blink.debug.print("invalid key '" .. k .. "' passed to spell callback label...", "debug")
            return false
          end

          -- ! not running callback when spell not castable
          local incursGCD = self.gcd and self.gcd > 0
          if blink.SpellQueued and incursGCD and random(1, 60) ~= 1 then
            return false
          end
          if self.current and incursGCD and not stances[self.id] and not empowered[self.id] then
            blink.SpellQueued = self.id
          end
          local options = self.options
          if not self:ShouldCast(nil, options) then
            return false
          end

          -- ! begin firing pre-callbacks then invoked callback
          local fired_this_frame = blink.fired_this_frame
          -- this spell's callback hooks
          for i = 1, #self.callbackHooks do
            if not fired_this_frame[self.id .. i] then
              spell.callbackHooks[i](self)
              fired_this_frame[self.id .. i] = true
            end
          end
          -- general spell callback hooks
          for i = 1, #spellCallbacks do
            if not fired_this_frame[i] then
              spellCallbacks[i](self, k)
              fired_this_frame[i] = true
            end
          end
          -- speciic key callback hooks
          if k then
            for hk, cb in pairs(specificSpellCallbacks) do
              if k == hk and not fired_this_frame[hk] then
                cb(self)
                fired_this_frame[hk] = true
              end
            end
          end
          if DEFAULT_CALLBACK then
            if k then
              return DEFAULT_CALLBACK(self, k, ...)
            else
              return DEFAULT_CALLBACK(self, ...)
            end
          else
            local should_hook = #castCallbacks > 0
            -- replace cast with version of itself that always returns this callback key..
            if should_hook then
              self:restoreCast(k)
              self:restoreAoECast(k)
            end
            local res = self.callbacks[k](self, ...)
            -- restore original version then return result from spell :Callback
            if should_hook then
              self:restoreCast()
              self:restoreAoECast()
            end
            return res
          end

        end
      })
    end
  end

  function spell:Update(nested)
    self:ClearCache()
    if nested then
      setmetatable(self, {
        __index = spellFunctions,
        __call = function(self, ...)
          if not self.refreshingCache then
            -- if IsPlayerSpell(self.id) or IsSpellKnown(self.id) or GetSpellInfo(self.name) then
            blink.onTick(function()
              spell:ClearCache()
            end)
            self.refreshingCache = true
            -- end
          end
          local options = self.options
          if self.spam or options.spam or options.ignoreGCD or self.cd < blink.spellCastBuffer then
            local incursGCD = self.gcd and self.gcd > 0
            if blink.SpellQueued and incursGCD then
              return false
            end
            if self.current and incursGCD and not stances[self.id] then
              blink.SpellQueued = self.id
            end
            if not incursGCD and self.cd > 0 then
              return false
            end
            -- spell callback hook
            for i = 1, #spellCallbacks do
              spellCallbacks[i]()
            end
            return nested(self, ...)
          end
        end
      })
    end
  end

  function spell:ShouldCast(unit, options)

    if options.mustBeGrounded and player.falling then
      return false
    end

    if options.validate and not options.validate(self, unit, options) then
      return false
    end

    if options.requiresBuff then
      for _, buff in ipairs(options.requiresBuff) do
        if not player.buff(buff) then
          return false
        end
      end
    end

    if options.requiresStance and player.stance ~= options.requiresStance then
      return false
    end

    if unit then
      if not unit.exists then
        return
      end
      if unit.dead then
        return
      end

      local ctms = max(0, self.castTime + blink.latency - 0.03)

      -- immunity remains callback
      if options.immunityCheck and options.immunityCheck(unit) > ctms then
        return false
      end

      -- no cast critty spells into RoS
      if (critSpells[spell.id] or spell.id == 2948 and player.buff(190319)) and unit.buff(53480) then
        return false
      end

      -- is a bleed
      if options.bleed then
        -- ascendant phial bleed immunity
        if unit.buff(330752) then
          return false
        end
      end

      -- is a slow
      if options.slow then
        if unit.immuneSlow then
          return false
        end
      end

      -- is a heal / beneficial
      if options.heal or options.beneficial then
        if unit.healingImmunityRemains > ctms then
          return false
        end
      end
      -- unit is of blacklisted creature type
      if options.creatureTypeBlacklist and unit.creatureType then
        if tContains(options.creatureTypeBlacklist, unit.creatureType) then
          return false
        end
      end

      if (options.damage or options.effect) and unit.id ~= 5925 and (not unit.friend or unit.enemy) then
        options.interrupt = self.isInterrupt
        local mDmg, mEffect = unit.immuneMagicInfo(options)
        local pDmg, pEffect = unit.immunePhysicalInfo(options)
        if options.damage == "magic" then
          if mDmg.spell and mDmg.remains > ctms then
            return false
          end
          if options.targeted then
            -- print(mDmg.targeted.remains)
            if type(options.targeted) ~= "function" or options.targeted(unit, self) then
              if mDmg.targeted.spell and mDmg.targeted.remains > ctms then
                return false
              end
            end
          end
        elseif options.damage == "physical" then
          if pDmg.spell and pDmg.remains > ctms then
            return false
          end
          if options.targeted then
            if pDmg.targeted.spell and pDmg.targeted.remains > ctms then
              return false
            end
          end
        end
        if options.effect == "magic" then
          if mEffect.spell and mEffect.remains > ctms then
            return false
          end
          if options.targeted then
            if mEffect.targeted.spell and mEffect.targeted.remains > ctms then
              return false
            end
          end
        elseif options.effect == "physical" then
          if pEffect.spell and pEffect.remains > ctms then
            return false
          end
          if options.targeted then
            if pEffect.targeted.spell and pEffect.targeted.remains > ctms then
              return false
            end
          end
        end
      end
      local ccType = options.cc
      if ccType then
        if type(ccType) == "string" then
          ccType = ccType:lower()
        end
        local immune = blink.ImmuneCC(unit, ccType)
        if immune then
          return false
        end
      end
    end

    if self.cd > blink.spellCastBuffer and not options.spam and (not options.ignoreGCD or spell.cd > blink.gcdRemains) then
      return false
    end

    if not options.pet and
      (player.casting and player.castRemains > blink.spellCastBuffer and not options.castableWhileCasting and not options.ignoreCasting or player.channelID and not options.castableWhileChanneling and
        not options.ignoreChanneling and not stupidChannels[player.channelID]) then
      return false
    end

    if options.pet then
      if pet.cc then
        return false
      end
    else
      -- added blink.mapID ~= 616 cuz blink.hasControl is false when in on a Hover Disk in Eye of Eternity (WotLK). Also can check with blink.pet.id == 30234, but I reckon this is more expensive and won't work for e.g. Hunters.
      if not blink.hasControl and (UnitInVehicle and not UnitInVehicle("player") or not UnitInVehicle) and not options.castableInCC and not options.usableInCC and not options.whileInCC and not options.ignoreControl and not options.ignoreCC then
        if not options.ignoreStuns or not player.stunned or player.incap or player.disorient then
          return false
        end
      end
    end

    -- debug, spell wasn't usable..?
    local usable = self.usable
    if not options.ignoreUsable and not spell.usable and not (self.id == 205448 and player.buff(194249)) then
      return debug.print("ShouldCast IsUsableSpell False - " .. (self.id or "UNKNOWN SPELLID") .. " - " .. (self.name or "UNKNOWN SPELLNAME"), "cast")
    end

    -- debug, spell not known
    if not self.known then
      return debug.print("Trying to cast " .. (self.name or self.id or "UNKNOWN SPELL") .. " while not learned.", "cast")
    end

    local ignoreMovingAttribute = options.ignoreMoving or options.whileMoving or options.castableWhileMoving
    local ignoreMoving = ignoreMovingAttribute and (type(ignoreMovingAttribute) ~= "function" or ignoreMovingAttribute(self))

    -- moving when spell has a cast time                    
    if self.castTimeRaw > 0 then
      if (player.moving or player.falling) and not ignoreMoving and not castableWhileMovingSpells[self.id] and not player.buffFrom(castWhileMovingBuffs) then
        return false
      end
    end

    return true

  end

  function spell:Castable(unit, options)

    options = setmetatable((options or {}), {
      __index = self.options
    })

    -- quaking will interrupt
    local quaking_remains = player.quaking_remains -- buffRemains(240447)
    if not options.ignoreQuaking and quaking_remains > 0 and (self.castTime > 0 and self.castTime > quaking_remains - 0.5 or blink.channelSpells[self.id]) then
      return false
    end

    if not self:ShouldCast(unit, options) then
      return false
    end

    if unit then
      -- range
      local ignoreRangeAttribute = options.ignoreRange
      local ignoreRange = ignoreRangeAttribute and (type(ignoreRangeAttribute) ~= "function" or ignoreRangeAttribute(self))
      if (ignoreRange or options.pet and blink.pet.exists and (self.range == 0 and pet.meleeRangeOf(unit) or blink.pet.distanceTo(unit) <= self.range) or self.range == 0 and unit.meleeRange or
        self.range ~= 0 and unit.distance < self.range + checkDiam(options.diameter) + checkRad(options.radius)) -- los
      and (options.losNotRequired or options.ignoreLoS or (unit.id and blink.ignoreLoS[unit.id]) or unit.los) then
        local face = options.face or options.alwaysFace or options.autoFace
        -- facing
        if options.heal or options.beneficial or options.facingNotRequired or options.ignoreFacing or facingNotRequired[self.name] or options.pet or player.facing(unit) then
          return true
        elseif face then
          if face == "oneWay" then
            return "oneWay"
          elseif face == "force" then
            return "face"
          elseif not blink.saved.securityStuff then
            return "face"
          end
        end
      end
    else
      if (options.ignoreUsable or self.usable or debug.print("IsUsableSpell False - " .. (self.id or "UNKNOWN SPELLID") .. " - " .. (self.name or "UNKNOWN SPELLNAME"), "cast")) and
        (self.known or blink.debug.print("Trying to cast " .. (self.name or "UNKNOWN SPELLNAME") .. " while not learned.", "cast")) then
        return true
      end
    end

  end

  function spell:Queue(props)
    props = props or {}
    local unit, options, duration = props.unit, props.options, props.duration
    local id = self.id

    duration = duration or 3

    if id == 2645 and player.buff(id) then
      blink.protected.RunMacroText("/cancelaura " .. C_Spell.GetSpellInfo(2645).name)
      return
    end

    blink.ManualSpellQueues[id] = {
      time = blink.time,
      expires = blink.time + duration,
      obj = self,
      options = setmetatable(options or {}, {
        __index = self.options
      }),
      target = unit
    }
  end

  function spell:Release()
    local slot = getActionSlotBySpellName(self.name)
    if slot then
      ReleaseAction(slot)
      return true
    end
  end

  function spell:restoreCast(key)
    function spell:Cast(unit, options)
      if not options and unit and type(unit) == "table" and not unit.isBlinkObject then
        options = unit
        unit = nil
      end
      local castable = self:Castable(unit, options)
      if castable then
        if options and options.stopMoving then
          if player.moving then
            blink.StopMoving()
            blink.controlMovement(0.05)
            options.stopMoving = nil
            executeCastCallbacks(self, key)
            C_Timer.After(0.05, function()
              executeCallbacks(self.castCallbacks, self)
              self:Cast(unit, options)
            end)
            return true
          end
        end
        local fd
        if (castable == "face" or castable == "oneWay") and not blink.pauseFacing then
          fd = player.rotation
          unit.face()
        end
        executeCallbacks(self.castHooks, self, unit)
        executeCallbacks(self.castCallbacks, self)
        executeCastCallbacks(self, key)
        attemptedCasts[self.id] = GetTime()
        if empowered[self.id] then
          local slot = getActionSlotBySpellName(self.name)
          if slot then
            UseAction(slot)
          else
            CastByID(self.id, unit or "", not options or not options.castByID)
          end
        else
          local isStep
          if self.id == 36554 then
            isStep = true
            ClearTarget()
          end
          CastByID(self.id, unit or "", not options or not options.castByID)
          if isStep then
            TargetLastTarget()
          end
        end
        if castable == "face" and not player.casting and not blink.pauseFacing then
          player.face(fd)
        end
        if self.gcd > 0 then
          blink.SpellQueued = self.id
        end
        return true
      end
    end
  end
  spell:restoreCast()

  function spell:CastAlert(...)
    local res = self:Cast(...)
    if res then
      blink.alert(self.name, self.id)
    end
    return res
  end

  -- the way i did this is giga-retarded, fixme later
  function spell:restoreAoECast(key)
    function spell:AoECast(options, gY, gZ)

      local px, py, pz = player.position()
      local x, y, z
      local unitGiven
      if gY and gZ then
        local actualOptions = setmetatable({}, {
          __index = self.options
        })
        if not self:ShouldCast(nil, actualOptions) then
          return false
        end
        x, y, z = options, gY, gZ
      elseif options.hp then
        unitGiven = true
        local actualOptions = setmetatable({}, {
          __index = self.options
        })
        if not self:ShouldCast(options, actualOptions) then
          return false
        end
        x, y, z = options.position()

        if options.id == 166608 then -- Mueh'zala 
          z = pz + 3.5
        elseif options.id == 190496 then -- Terros
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 25
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        elseif options.id == 187967 then -- Sennarth 
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 35
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        elseif options.id == 75452 or options.id == 76057 or options.id == 200035 then -- Bonemaw & Carrion Worm
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 9
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        elseif options.id == 208478 then -- Volcoross
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 58
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        end
      elseif options.unit then
        unitGiven = true
        local actualOptions = setmetatable(options, {
          __index = self.options
        })
        if not self:ShouldCast(options.unit, actualOptions) then
          return false
        end
        x, y, z = options.unit.position()

        if options.unit.id == 166608 then -- Mueh'zala 
          z = pz + 3.5
        elseif options.unit.id == 190496 then -- Terros
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 25
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        elseif options.unit.id == 187967 then -- Sennarth 
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 35
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        elseif options.unit.id == 75452 or options.unit.id == 76057 or options.unit.id == 200035 then -- Bonemaw & Carrion Worm
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 9
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        elseif options.unit.id == 208478 then -- Volcoross
          local angle = blink.AnglesBetween(x, y, z, px, py, pz)
          local dist = 58
          local tx, ty = x + dist * math.cos(angle), y + dist * math.sin(angle)
          x, y, z = blink.GroundZ(tx, ty, pz)
        end
      elseif options.position then
        unitGiven = true
        local actualOptions = setmetatable({}, {
          __index = self.options
        })
        if not self:ShouldCast(nil, actualOptions) then
          return false
        end
        x, y, z = unpack(options.position)
      end
      if x and y and z then
        if unitGiven then
          -- should be fine..probably?
          x = x + 0.2
          y = y + 0.2
        end
        local d = blink.Distance(px, py, pz, x, y, z)
        if not d then
          blink.debug.print("invalid distance check in aoecast, spell or object likely doesn't exist", "debug")
          return false
        end
        local range = self.range
        if not range then
          blink.debug.print("invalid range check in aoecast, spell likely doesn't exist", "debug")
          return false
        end
        if d < range then

          executeCallbacks(spell.castHooks, spell, unit)
          executeCallbacks(spell.castCallbacks, spell)
          executeCastCallbacks(spell, key)
          attemptedCasts[spell.id] = GetTime()

          CastByID(self.id, "", not self.options or not self.options.castByID)

          if SpellIsTargeting() then
            local currentTarget = target.pointer
            attemptedCasts[spell.id] = GetTime()
            Click(x, y, z)
            if currentTarget ~= target.pointer and UnitIsVisible(currentTarget) then
              TargetUnit(currentTarget)
            end
            aoeFix()
            C_Timer.After(blink.buffer, aoeFix)
            C_Timer.After(3 / GetFramerate(), rmbFix)
          end
          return true
        end
      end
    end
  end
  spell:restoreAoECast()

  function spell:SmartAoEPosition(unit, options)

    options = setmetatable((options or {}), {
      __index = self.options
    })

    if not options.radius and not options.diameter then
      return blink.debug.print("You need to define either diameter or radius for SmartAoE", "debug")
    end
    -- if not options.useCase then
    --     return blink.debug.print("You need to define a use case for CastEdge")
    -- end

    local ux, uy, uz

    if unit.truePointer then
      if not unit.exists then
        return blink.debug.print((self.name or "unknown") .. " unit didn't exist in SmartAoE call", "debug")
      end
      ux, uy, uz = unit.predictPosition(options.movePredTime or 0)
    elseif #unit == 3 then
      ux, uy, uz = unpack(unit)
    elseif unit.x then
      ux, uy, uz = unit.x, unit.y, unit.z
    end

    if not ux then
      return
    end

    local px, py, pz = player.position()

    -- return cached smartaoe pos from previous call
    for i = 1, #self.smartAoECache do
      local cache = self.smartAoECache[i]
      if FastDistance(cache.ux, cache.uy, cache.uz, ux, uy, uz) < 0.3 and TraceLine(px, py, pz + 1.7, cache.x, cache.y, cache.z + 1.7, collisionFlags) == 0 then
        return cache.x, cache.y, cache.z, cache.hitList
      end
    end

    local points = {}

    local baseSpeed, currentSpeed = unit.speed, unit.speed2
    local isMoving = unit.moving

    local cc = unit.ccRemains

    local radius
    local diameter = options.diameter
    if not diameter then
      diameter = options.radius
      radius = true
    end
    if type(diameter) == "function" then
      diameter = diameter(self)
    end
    if radius then
      diameter = diameter * 2
    end

    if type(diameter) ~= "number" then
      return blink.debug.print((self.name or "unknown") .. " received invalid diameter / radius in SmartAoE", "debug")
    end

    -- add distance from the edge in options
    local reduceDiameter = options.reduceDiameter or 0
    reduceDiameter = reduceDiameter - (options.increaseDiameter or 0)

    local dist = diameter - reduceDiameter

    dist = min(diameter, max(dist, 0)) / 2

    -- dynamic increase of spell range
    local rangeIncrease = options.rangeIncrease or 0
    local maxRange = (options.range or self.range) + rangeIncrease

    local circ = pi2 / (options.circleSteps or 48)
    local minDist = options.minDist or options.offsetMin or math.random() * (0.75 - 0.25) + 0.25
    local maxDist = options.maxDist or options.offsetMax or dist
    local distChecks = options.distChecks or options.distanceSteps or 24

    local objects = {}

    if options.filter then
      if options.units then
        objects = options.units
      else
        objects = join(not options.ignoreFriends and blink.friends or {}, not options.ignoreEnemies and blink.enemies or {})
        objects = join(objects, not options.ignoreEnemies and blink.wwClones or {})
      end
    end

    if options.useCase == "Towards Target" and unit.target and unit.target.exists and unit.target.enemy and unit.target.losOf(unit) and unit.target.distanceTo(unit) > diameter / 2 and unit.movingTowards(unit.target) then
      -- The idea behind this is to find the position between the friend and the enemy and cast the spell as close to the enemy as possible while still hitting the friend (unit)
      local ex, ey, ez = unit.target.position()

      if unit.speed >= 14 then
        -- If the friend is moving fast, we put it on the enemy instead
        return blink.GroundZ(ex, ey, ez)
      end

      -- Calculate the angle between the friend and the enemy
      local friendToEnemyAngle = blink.anglesBetween(ux, uy, uz, ex, ey, ez)
      
      -- Calculate the position towards the enemy, within the desired diameter
      local x = ux + math.cos(friendToEnemyAngle) * diameter / 2
      local y = uy + math.sin(friendToEnemyAngle) * diameter / 2
      local z = uz

      return blink.GroundZ(x, y, z)
    end

    local deficit = maxDist - minDist
    local distStep = deficit / distChecks
    -- smallest allowable distance step
    while distStep < 0.5 and distStep * 2 <= deficit do
      distStep = distStep * 2
    end
    -- largest allowable distance step ?
    -- while distStep > 2 and distStep / 2 >= minDist do
    --     distStep = distStep / 2
    -- end
    for d = minDist, maxDist, distStep do
      for i = 0, pi2, circ do
        local x, y, z = blink.GroundZ(ux + d * cos(i), uy + d * sin(i), uz + 1)
        if x and y and z
        and FastDistance(x, y, z, px, py, pz) < maxRange 
        and TraceLine(x, y, z + 1.7, px, py, pz + 1.7, collisionFlags) == 0 
        and TraceLine(x, y, z + 1.5, ux, uy, uz + 1.5, collisionFlags) == 0 then
          if options.useCase == "Hit Only One" then
            local hit, bCC, avg = blink.EnemiesAroundPoint(x, y, z, diameter, unit)
            if bCC == 0 then
              local zdif = z - uz
              zdif = abs(zdif)
              if d + zdif <= dist and zdif < 3.5 then
                tinsert(points, {
                  x = x,
                  y = y,
                  z = z,
                  hit = hit,
                  avg = avg
                })
              end
            end
          elseif options.filter then
            local hit = 0
            local hitList = {unit}
            local unitCount = 0.000001
            local totalDist = 0.000001
            local pointNulled = false
            for i = 1, #objects do
              local o = objects[i]
              if o.visible and not o.isUnit(unit) then
                local d = o.predictDistanceToPosition(x, y, z, options.movePredTime)
                local filterReturn = options.filter(o, d, {x, y, z})
                if filterReturn == true then
                  hit = hit + 1
                  hitList[#hitList + 1] = o
                elseif filterReturn then
                  if d < dist * 2 then
                    unitCount = unitCount + 1
                    totalDist = totalDist + d
                  end
                elseif filterReturn == false then
                  pointNulled = true
                  break
                end
              end
            end
            local avgDist = totalDist / unitCount
            if not pointNulled then
              local zdif = z - uz
              zdif = abs(zdif)
              if d + zdif <= maxDist and zdif < 3.5 then
                tinsert(points, {
                  x = x,
                  y = y,
                  z = z,
                  hit = hit,
                  avg = avgDist,
                  hitList = hitList
                })
              end
            end
          else
            local zdif = z - uz
            zdif = abs(zdif)
            tinsert(points, {
              x = x,
              y = y,
              z = z,
              dist = d + zdif,
              zdif = zdif
            })
          end
        end
      end
    end

    if options.useCase == "Hit Only One" or options.filter then
      if #points == 0 then
        return false
      end
      if options.presort then
        options.presort()
      end
      if options.sort then
        sort(points, options.sort)
      else
        if options.minHit then
          sort(points, function(x, y)
            return x.hit > y.hit or (x.hit == y.hit and x.avg < y.avg)
          end)
        else
          sort(points, function(x, y)
            return x.hit < y.hit or (x.hit == y.hit and x.avg > y.avg)
          end)
        end
      end
      local x, y, z = points[1].x, points[1].y, points[1].z
      if options.sort and not options.maxHit and not options.minHit or (options.maxHit or not options.minHit) and points[1].hit == 0 or options.maxHit and points[1].hit < options.maxHit or
        options.minHit and points[1].hit >= options.minHit - 1 then
        if options.minHit and options.maxHit then
          if points[1].hit < options.minHit or points[1].hit > options.maxHit then
            return false
          end
        end
        blink.pointsDraw = points
        tinsert(self.smartAoECache, {
          x = x,
          y = y,
          z = z,
          ux = ux,
          uy = uy,
          uz = uz,
          time = GetTime(),
          hitList = points[1].hitList
        })
        return x, y, z, points[1].hitList
      end
      -- if options.sort 
      -- or points[1].hit == 0 
      -- or options.maxHit 
      -- and points[1].hit < options.maxHit then
      --   blink.pointsDraw = points
      --   tinsert(self.smartAoECache, { x = x, y = y, z = z, ux = ux, uy = uy, uz = uz, time = GetTime(), hitList = points[1].hitList })
      --   return x, y, z, points[1].hitList
      -- end
    elseif options.sort then
      if #points == 0 then
        return false
      end
      if options.presort then
        options.presort()
      end
      options.sort(points)
      local x, y, z = points[1].x, points[1].y, points[1].z
      tinsert(self.smartAoECache, {
        x = x,
        y = y,
        z = z,
        ux = ux,
        uy = uy,
        uz = uz,
        time = GetTime()
      })
      return x, y, z
    else
      if #points == 0 then
        return false
      end
      sort(points, function(x, y)
        return x.dist <= maxDist and x.dist >= minDist and x.dist < y.dist
      end)
      if points[1].dist > maxDist or points[1].dist < minDist then
        return false
      end
      local x, y, z = points[1].x, points[1].y, points[1].z
      tinsert(self.smartAoECache, {
        x = x,
        y = y,
        z = z,
        ux = ux,
        uy = uy,
        uz = uz,
        time = GetTime()
      })
      return x, y, z
    end

  end
  spell.CastEdgePosition = spell.SmartAoEPosition

  function spell:SmartAoE(unit, options)
    options = setmetatable((options or {}), {
      __index = self.options
    })
    -- check for immunities amongst other various dummie thick stuff
    if not self:ShouldCast(unit, options) then
      return false
    end
    local x, y, z, hitList = self:SmartAoEPosition(unit, options)
    if x and y and z then
      return self:AoECast(x, y, z), hitList
    end
  end
  spell.CastEdge = spell.SmartAoE

  local function refreshCache()
    spell:ClearCache()
  end

  if not spell.refreshingCache then
    if IsPlayerSpell(spell.id) or IsSpellKnown(spell.id) or C_Spell.GetSpellInfo(spell.id) then
      blink.addUpdateCallback(refreshCache)
      spell.refreshingCache = true
    else
      -- wowie, no spell
    end
  end

  tinsert(blink.SpellObjects, spell)
  spellsByID[spell.id] = spell

  return spell

end

function blink.NewItem(items, options)

  local itemsAsTable

  local itemID
  local function updateItems()
    if type(items) == "number" or type(items) == "string" then
      itemID = items
      itemsAsTable = {items}
    elseif type(items) == "table" then
      itemsAsTable = items
      -- any item the player has equipped in the list
      for _, item in ipairs(items) do
        if IsEquippedItem(item) then
          itemID = item
          break
        end
      end
      -- any item the player has in their bags in the list
      if not itemID then
        for _, item in ipairs(items) do
          if GetItemCount(item) > 0 then
            itemID = item
            break
          end
        end
      end
      -- if none equipped still use something from list to populate stuff with
      if not itemID then
        itemID = items[1]
      end
    else
      blink.print("Invalid item(s) info passed to NewItem")
      return false
    end
  end
  updateItems()

  local C_Container = C_Container
  local function itemCooldown(id)
    return C_Container.GetItemCooldown(id)
  end

  local time = GetTime()
  options = options or {}
  local itemFunctions = function(self, key)
    key = string.gsub(key, "_", "")
    local selection = string.match(key, "%d+")
    if selection then
      key = string.gsub(key, selection, "")
    end
    selection = selection and tonumber(selection) or 1
    -- only pass packed functions with multiple return functions
    local function cacheReturn(func, returnType, ...)
      -- return func(...)
      -- return 0
      if type(returnType) == "function" then
        local cached = self.cache[returnType()]
        local funct = type(func) == "string" and _G[func] or func
        local val = cached or {funct(...)}
        if cached == nil then
          self.cache[returnType()] = val
        end
        return val and val[select(2, returnType()) or selection]
      elseif type(returnType) == "number" then
        local cached = self.cache[key]
        local funct = type(func) == "string" and _G[func] or func
        local val = cached or {funct(...)}
        if cached == nil then
          self.cache[key] = val
        end
        return val and val[returnType]
      elseif strmatch(returnType, "single") then
        local cached = self.cache[key]
        local funct = type(func) == "string" and _G[func] or func
        local val = cached or funct(...)
        if cached == nil then
          self.cache[key] = val
        end
        return val
      else
        local cached = self.cache[key]
        local funct = type(func) == "string" and _G[func] or func
        local val = cached or {funct(...)}
        if cached == nil then
          self.cache[key] = val
        end
        -- if type(val) == "number" then
        --   print(val)
        -- end
        return val and val[selection]
      end
    end
    local keyLower = strlower(key)
    local time = blink.time

    if keyLower == "casttimeraw" then
      local spellID = self.spell
      if not spellID then
        return 0
      end
      return cacheReturn(blink.castTime, "singleReturn", spellID, true)
    elseif keyLower == "casttime" then
      local spellID = self.spell
      if not spellID then
        return 0
      end
      return cacheReturn(blink.castTime, "singleReturn", spellID)
    elseif keyLower == "name" or keyLower == "info" then
      return cacheReturn(GetItemInfo, "multiReturn", self.id)
    elseif keyLower == "spell" then
      return select(2, GetItemSpell(self.id))
    elseif keyLower == "usable" then
      return cacheReturn(IsUsableItem, "singleReturn", self.id)
    elseif keyLower == "count" then
      local getCount = function()
        local count = 0
        for i = 1, #itemsAsTable do
          local c = GetItemCount(itemsAsTable[i])
          if c > count then
            count = c
          end
        end
        return count
      end
      return cacheReturn(getCount, "singleReturn")
    elseif keyLower == "charges" then
      local getCount = function()
        local count = 0
        for i = 1, #itemsAsTable do
          local c = GetItemCount(itemsAsTable[i], nil, true)
          if c > count then
            count = c
          end
        end
        return count
      end
      return cacheReturn(getCount, "singleReturn")
    elseif keyLower == "numequipped" then
      local countFunc = function()
        local count = 0
        if type(itemsAsTable) == "table" then
          -- any item the player has equipped in the list
          for _, item in ipairs(itemsAsTable) do
            local name = GetItemInfo(item)
            if IsEquippedItem(name) then
              count = count + 1
            end
          end
        end
        return count
      end
      return cacheReturn(countFunc, "singleReturn")
    elseif keyLower == "equipped" then
      return cacheReturn(IsEquippedItem, "singleReturn", self.id)
    elseif keyLower == "range" then
      local spellID = self.spell
      if not spellID then
        return 40
      end
      return C_Spell.GetSpellInfo(spellID).maxRange
    elseif keyLower == "cd" or keyLower == "cooldown" then
      local start, total = itemCooldown(self.id)
      -- start sometimes nil here (?)
      -- apparently total too
      return max(0, (total or 0) - (GetTime() - (start or 0)))
    elseif keyLower == "id" or keyLower == "itemid" then
      return self.pointer
    elseif keyLower == "allids" then
      local idFunc = function()
        local ids = {}
        if type(itemsAsTable) == "table" then
          for _, item in ipairs(itemsAsTable) do
            if IsEquippedItem(item) then
              ids[item] = true
            end
          end
        end
        return ids
      end
      return cacheReturn(idFunc, "singleReturn")
    end

  end

  local itemAttributes = {
    __index = itemFunctions,
    __call = function(self)
      blink.print("No __call method for Item ['Name: " .. (self.name or "No item name, likely incorrect ItemID.") .. " ID: " .. (self.id or "No item ID?") ..
                    "'], please use the :Update method to assign a function to be invoked upon calling this item object.", true)
    end
  }
  local item = setmetatable({
    pointer = itemID,
    cache = {},
    options = options
  }, itemAttributes)

  -- fixme
  item.inRange = function(obj)
    return player.distanceTo(obj) < item.range
  end

  function item:forceUpdate()
    if itemsAsTable then
      local items = itemsAsTable
      -- sort based on CD
      local function lowestCd(item1, item2)
        local trinket1 = item1
        local start1, total1 = itemCooldown(trinket1)
        local trinket2 = item2
        local start2, total2 = itemCooldown(trinket2)

        if not start1 or not start2 then
          return false
        end
        local cd1 = max(0, total1 - (GetTime() - start1))
        local cd2 = max(0, total2 - (GetTime() - start2))
        return cd1 < cd2
      end
      sort(items, lowestCd)
      -- any item the player has equipped in the list
      for _, item in ipairs(items) do
        if IsEquippedItem(item) then
          itemID = item
          self.pointer = item
          break
        end
      end
      -- if none equipped still use something from list to populate stuff with
      if not itemID then
        itemID = items[1]
        self.pointer = itemID
      end
      self.cache = {}
    end
  end

  function item:Update(nested)
    self.cache = {}
    if nested then
      setmetatable(self, {
        __index = itemFunctions,
        __call = function(self, ...)
          if not self.refreshingCache then
            if self.equipped or self.count > 0 then
              blink.onTick(function()
                self.cache = {}
              end)
              self.refreshingCache = true
            end
          end
          if self.spam or self.options.spam or self.cd < blink.spellCastBuffer then
            return nested(self, ...)
          end
        end
      })
    end
  end

  function item:Usable(unit, options)

    options = options or {}

    if unit then
      if not unit.exists then
        return
      end
      if unit.dead then
        return
      end
      -- 213602
      local itemOptions = item.options
      if (itemOptions.damage or itemOptions.effect) and not unit.initOptions.totem and not unit.friend then
        local mDmg, mEffect = unit.immuneMagicInfo(options)
        local pDmg, pEffect = unit.immunePhysicalInfo(options)
        if itemOptions.damage == "magic" then
          if mDmg.spell and mDmg.remains > spell.castTimeRaw then
            return false
          end
          if itemOptions.targeted then
            -- print(mDmg.targeted.remains)
            if mDmg.targeted.spell and mDmg.targeted.remains > spell.castTimeRaw then
              return false
            end
          end
        elseif itemOptions.damage == "physical" then
          if pDmg.spell and pDmg.remains > spell.castTimeRaw then
            return false
          end
          if itemOptions.targeted then
            if pDmg.targeted.spell and pDmg.targeted.remains > spell.castTimeRaw then
              return false
            end
          end
        end
        if itemOptions.effect == "magic" then
          if mEffect.spell and mEffect.remains > spell.castTimeRaw then
            return false
          end
          if itemOptions.targeted then
            if mEffect.targeted.spell and mEffect.targeted.remains > spell.castTimeRaw then
              return false
            end
          end
        elseif itemOptions.effect == "physical" then
          if pEffect.spell and pEffect.remains > spell.castTimeRaw then
            return false
          end
          if itemOptions.targeted then
            if pEffect.targeted.spell and pEffect.targeted.remains > spell.castTimeRaw then
              return false
            end
          end
        end
      end
      local ccType = itemOptions.cc
      if ccType then
        if type(ccType) == "string" then
          ccType = ccType:lower()
        end
        local immune = blink.ImmuneCC(unit, ccType)
        if immune then
          return false
        end
      end
    end

    if self.cd > blink.spellCastBuffer then
      return false
    end

    if (player.casting and player.castRemains > blink.spellCastBuffer and not self.castableWhileCasting or player.channelID and not self.castableWhileChanneling and
      not stupidChannels[player.channelID]) then
      return false
    end

    -- quaking will interrupt
    local quaking_remains = player.buffRemains(240447)
    if quaking_remains > 0 and self.castTimeRaw > 0 and self.castTimeRaw > quaking_remains - 0.5 then
      return false
    end

    -- spell casts during bladestorm
    if player.class2 == "WARRIOR" and player.buff(227847) then
      if self.id ~= 97462 then
        return false
      end
    end

    if not blink.hasControl and not self.options.castableInCC and not self.options.usableInCC then
      return false
    end

    if unit then
      if (self.id == 205448 and player.buff(194249) or self.equipped or self.usable or
        debug.print("IsEquippedItem and IsUsableItem False - " .. (self.id or "UNKNOWN ITEM ID") .. " - " .. (self.name or "UNKNOWN ITEM NAME"), "item")) then
        if self.castTimeRaw <= 0 or blink.spells.castableWhileMoving[self.id] or not player.moving or player.buffFrom({79206, 12042, 108839}) then
          if (self.options.ignoreRange or self.inRange(unit)) and (self.options.losNotRequired or unit.los) then
            local face = options.face or options.alwaysFace or options.autoFace
            if self.options.facingNotRequired or facingNotRequired[self.name] or player.facing(unit) then
              return true
            elseif face then
              if face == "oneWay" then
                return "oneWay"
              elseif face == "force" then
                return "face"
              elseif not blink.saved.securityStuff then
                return "face"
              end
            end
          end
        end
      end
    else
      if (self.equipped or self.usable or debug.print(":Usable called when item not equipped or in bags - " .. self.id .. " - " .. (self.name or "UNKNOWN ITEM"), "item")) then
        return true
      end
    end

  end

  function item:Use(unit, options)
    local castable = self:Usable(unit, options)
    if castable then
      local fd
      if castable == "face" or castable == "oneWay" then
        fd = player.rotation
        unit.face()
      end
      UseItemByName(self.name, type(unit) == "table" and unit.pointer or unit or "")
      if castable == "face" then
        player.face(fd)
      end
      return true
    end
  end

  function item:UseAoE(options, gY, gZ)
    local px, py, pz = player.position()
    local x, y, z
    if gY and gZ then
      x, y, z = options, gY, gZ
    elseif options.hp then
      x, y, z = options.position()
    elseif options.unit then
      x, y, z = options.unit.position()
    elseif options.position then
      x, y, z = unpack(options.position)
    end
    if x and y and z then
      local d = blink.Distance(px, py, pz, x, y, z)
      if not d then
        blink.debug.print("invalid distance check in UseAoE, item or object likely doesn't exist", "debug")
        return false
      end
      local range = self.range
      if not range then
        blink.debug.print("invalid range check in UseAoE, item likely doesn't exist", "debug")
        return false
      end
      if d < range then
        UseItemByName(self.name, unit or "")
        if SpellIsTargeting() then
          Click(x, y, z)
          return true
        end
      end
    end
  end

  function item:UseEdgePosition(unit, options)

    if not options then
      return blink.debug.print("You need to define options (param 2) for CastEdge", "debug")
    end
    -- if not options.useCase then
    --     return blink.debug.print("You need to define a use case for CastEdge")
    -- end

    local ux, uy, uz = unit.predictPosition(options.movePredTime or 0)
    local px, py, pz = player.position()

    local points = {}

    local baseSpeed, currentSpeed = unit.speed, unit.speed2
    local isMoving = unit.moving

    local cc = unit.ccRemains

    local diameter = options.diameter
    if not diameter then
      blink.debug.print("no diameter provided to CastEdge", "debug")
      return false
    end

    -- add distance from the edge in options
    local reduceDiameter = options.reduceDiameter or 0
    reduceDiameter = reduceDiameter - (options.increaseDiameter or 0)

    local dist = diameter - reduceDiameter

    dist = min(diameter, max(dist, 0))

    dist = dist / 2

    -- buffs that increase max range of the spell 
    local rangeIncrease = options.rangeIncrease or 0
    local maxRange = options.range + rangeIncrease

    local circ = pi2 / 16
    local minDist = options.minDist or 0
    local distChecks = options.distChecks or 8

    local objects = {}
    local enemies = blink.enemyPets
    local friends = blink.friends
    if options.filter then
      for i = 1, #enemies do
        objects[#objects + 1] = enemies[i]
      end
      for i = 1, #friends do
        objects[#objects + 1] = friends[i]
      end
    end

    for d = minDist, dist, (dist - minDist) / distChecks do
      for i = 0, pi2, circ do
        local x, y, z = blink.GroundZ(ux + d * math.cos(i), uy + d * math.sin(i), uz + 2)
        if x and y and z and TraceLine(x, y, z + 1.6, px, py, pz + 1.6, collisionFlags) == 0 and TraceLine(x, y, z + 1.15, ux, uy, uz + 1.15, collisionFlags) == 0 and FastDistance(x, y, z, px, py, pz) <
          maxRange then
          if options.useCase == "Hit Only One" then
            local hit, bCC, avg = blink.EnemiesAroundPoint(x, y, z, diameter, unit)
            if bCC == 0 then
              local zdif = z - uz
              zdif = math.abs(zdif)
              if d + zdif <= dist then
                -- blink.meteorDrawings = blink.meteorDrawings or {}
                -- table.insert(blink.meteorDrawings, {x,y,z})
                tinsert(points, {
                  x = x,
                  y = y,
                  z = z,
                  hit = hit,
                  avg = avg
                })
              end
            end
          elseif options.filter then
            local hit = 0
            local unitCount = 0.000001
            local totalDist = 0.000001
            for i = 1, #objects do
              local o = objects[i]
              if o.visible then
                local d = o.predictDistanceToPosition(x, y, z, options.movePredTime)
                local filterReturn = options.filter(o, d, {x, y, z})
                if filterReturn == true then
                  hit = hit + 1
                elseif filterReturn then
                  if d < dist * 2 then
                    unitCount = unitCount + 1
                    totalDist = totalDist + d
                  end
                end
              end
            end
            local avgDist = totalDist / unitCount
            tinsert(points, {
              x = x,
              y = y,
              z = z,
              hit = hit,
              avg = avgDist
            })
          else
            tinsert(points, {
              x = x,
              y = y,
              z = z,
              dist = d
            })
          end
        end
      end
    end

    if options.useCase == "Hit Only One" or options.filter then
      if #points == 0 then
        return false
      end
      if options.sort then
        options.sort(points)
      else
        if options.minHit then
          sort(points, function(x, y)
            return x.hit > y.hit or (x.hit == y.hit and x.avg < y.avg)
          end)
        else
          sort(points, function(x, y)
            return x.hit < y.hit or (x.hit == y.hit and x.avg > y.avg)
          end)
        end
      end
      local x, y, z = points[1].x, points[1].y, points[1].z
      if options.sort and not options.maxHit and not options.minHit or (options.maxHit or not options.minHit) and points[1].hit == 0 or options.maxHit and points[1].hit < options.maxHit or
        options.minHit and points[1].hit >= options.minHit - 1 then
        if options.minHit and options.maxHit then
          if points[1].hit < options.minHit or points[1].hit > options.maxHit then
            return false
          end
        end
        return x, y, z
      end
    elseif options.sort then
      if #points == 0 then
        return false
      end
      options.sort(points)
      local x, y, z = points[1].x, points[1].y, points[1].z
      return x, y, z
    else
      if #points == 0 then
        return false
      end
      sort(points, function(x, y)
        return x.dist < y.dist
      end)
      local x, y, z = points[1].x, points[1].y, points[1].z
      return x, y, z
    end

  end

  function item:UseEdge(unit, options)
    local x, y, z = item:UseEdgePosition(unit, options)
    if x and y and z then
      return self:UseAoE({
        position = {x, y, z},
        force = true
      })
    end
  end

  local function refreshCache()
    item.cache = {}
  end

  function item:ClearCache()
    refreshCache()
  end

  if not item.refreshingCache then
    blink.addUpdateCallback(refreshCache)
    blink.addEventCallback(updateItems, "PLAYER_EQUIPMENT_CHANGED")
    item.refreshingCache = true
  end

  return item

end

blink.Spell = blink.NewSpell
blink.Item = blink.NewItem
