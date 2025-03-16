local Unlocker, blink = ...

local SetNPCObject = SetNPCObject
local ClearNPCObject = ClearNPCObject
local Object = Object

local SetMouseover = SetMouseover
local SetFocus, GetFocus = SetFocus, GetFocus

local G_UnitAura = _G.UnitAura
local G_UnitBuff = _G.UnitBuff
local G_UnitDebuff = _G.UnitDebuff

local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

local SecureCode = SecureCode

local UIParent = UIParent
local NamePlateTooltipTextLeft2 = NamePlateTooltipTextLeft2
local NamePlateTooltip = _G.NamePlateTooltip
local gameVersion = blink.gameVersion

local setmetatable, wipe, tremove, pairs, ipairs = setmetatable, wipe, tremove, pairs, ipairs

local AuraCache = {}
local cache_to_guid = {}
local clear_timers = {}

AuraCache.__index = function(self, key)

  if key == "guid" then
    return cache_to_guid[self]
  end

  return AuraCache[key]
end

function AuraCache:New(guid, auraType, auras)

  local o = self[guid]
  if not o then
    o = {}
    setmetatable(o, AuraCache)
    cache_to_guid[o] = guid
  end

  o[auraType] = auras or {}

  self[guid] = o

  return o
end

function AuraCache:ToMap()

end

-- GUID, "BUFF" or "DEBUFF", spellId

function AuraCache:Clear(auraType)
  if auraType then
    self[auraType] = nil
  else
    wipe(self)
    AuraCache[self.guid] = nil
  end
end

function AuraCache:Applied(auraType)
  self[auraType] = nil
end

function AuraCache:Removed(auraType)
  self[auraType] = nil
end

function AuraCache:Refresh(auraType, spellId)
  self[auraType] = nil
end

blink.AuraCache = AuraCache

local unlockerType = Unlocker.Util.Draw and "tinkr" or Unlocker.type

function blink.FastAuras(object, filter, refreshCache)

  -- local clFilterString = filter == "buff" and "BUFF" or "DEBUFF"
  -- local guid = object.guid

  -- if not guid then return {} end

  -- if refreshCache then
  --   AuraCache[guid] = nil
  -- else
  --   local cached = AuraCache[guid]
  --   if cached and cached[clFilterString] then
  --     if clear_timers[guid] then
  --       clear_timers[guid]:Cancel()
  --     end
  --     clear_timers[guid] = C_Timer.NewTimer(0.5, function()
  --       if cached then
  --         cached:Clear()
  --       end
  --     end)
  --     return cached[clFilterString]
  --   end
  -- end

  local pointer = object.pointer

  if not pointer then return {} end

  local auras, auraHash = {}, {}
  local filterString = filter == "buff" and "HELPFUL" or "HARMFUL"

  -- RETAIL
  if gameVersion == 1 then
    -- TINKR (Retail)
    if unlockerType == "tinkr" then
      local oldNPC = Object("npc")
      SetNPCObject(pointer)
      for i = 1, 40 do
        local aura = {G_UnitAura("npc", i, filterString)}
        if #aura > 0 then
          auras[#auras + 1] = aura
          auraHash[aura[10]] = aura
          local name = aura[1]:lower()
          if name then
            auraHash[name] = aura
          end
        else
          break
        end
      end
      if oldNPC then
        SetNPCObject(oldNPC)
      else
        ClearNPCObject()
      end
      -- NONAME (Retail)
    elseif unlockerType == "noname" then
      local oldFocus = GetFocus()
      SetFocus(pointer)
      for i = 1, 40 do
        local aura = {G_UnitAura("focus", i, filterString)}
        if #aura > 0 then
          auras[#auras + 1] = aura
          auraHash[aura[10]] = aura
          local name = aura[1]:lower()
          if name then
            auraHash[name] = aura
          end
        else
          break
        end
      end
      if oldFocus then
        SetFocus(oldFocus)
      end
      -- Anything else (Retail, Standard method)
    else
      local func = filter == "buff" and UnitBuff or UnitDebuff
      for i = 1, 40 do
        local aura = {func(pointer, i)}
        if #aura > 0 then
          auras[#auras + 1] = aura
          auraHash[aura[10]] = aura
          local name = aura[1]:lower()
          if name then
            auraHash[name] = aura
          end
        else
          break
        end
      end
    end
    -- Wrath / Classic
  else
    local func = filter == "buff" and G_UnitBuff or G_UnitDebuff
    if unlockerType == "tinkr" then
      local oldNPC = Object("npc")
      SetNPCObject(pointer)
      for i = 1, 40 do
        local aura = {func("npc", i)}
        if #aura > 0 then
          auras[#auras + 1] = aura
          auraHash[aura[10]] = aura
          local name = aura[1]:lower()
          if name then
            auraHash[name] = aura
          end
        else
          break
        end
      end
      if oldNPC then
        SetNPCObject(oldNPC)
      else
        ClearNPCObject()
      end
    elseif unlockerType == "noname" then
      SetMouseover(pointer)
      for i = 1, 40 do
        local aura = {func("mouseover", i)}
        if #aura > 0 then
          auras[#auras + 1] = aura
          auraHash[aura[10]] = aura
          local name = aura[1]:lower()
          if name then
            auraHash[name] = aura
          end
        else
          break
        end
      end
    else
      local func = filter == "buff" and UnitBuff or UnitDebuff
      for i = 1, 40 do
        local aura = {func(pointer, i)}
        if #aura > 0 then
          auras[#auras + 1] = aura
          auraHash[aura[10]] = aura
          local name = aura[1]:lower()
          if name then
            auraHash[name] = aura
          end
        else
          break
        end
      end
    end
  end

  -- AuraCache:New(guid, clFilterString, auras)

  return auras, auraHash
end

local scraperFrame = CreateFrame("GameTooltip", "ScraperTooltip", WorldFrame, "GameTooltipTemplate")
scraperFrame:ClearAllPoints()
scraperFrame:ClearLines()
-- scraperFrame:Hide()
scraperFrame:SetOwner(UIParent, "ANCHOR_NONE")

local textLeft = scraperFrame.TextLeft2 or ScraperTooltipTextLeft2

local np_setBuff = scraperFrame.SetUnitBuff
local np_setDebuff = scraperFrame.SetUnitDebuff

local owner_set = false
function blink.scrapeDesc(unit, filter, existingBuffs)
  local descriptions = {}
  if not unit then return descriptions end

  local oldNPC
  if unlockerType == "tinkr" then
    oldNPC = Object("npc")
    SetNPCObject(unit)
  end

  local set = filter == "buff" and np_setBuff or filter == "debuff" and np_setDebuff
  local prevText, lastIndex = nil, 0
  -- reset scraperFrame so we can SetUnitBuff/Debuff again
  scraperFrame:SetOwner(UIParent, "ANCHOR_NONE")
  for i = 1, 40 do
    if unlockerType == "tinkr" then
      set(scraperFrame, "npc", i)
    elseif unlockerType == "daemonic" then
      SecureCode(set, scraperFrame, unit, i)
    end
    local text = textLeft:GetText()
    if text == nil or text == prevText then
      break
    end
    descriptions[i] = text
    prevText = text
    lastIndex = i
  end

  if oldNPC then
    SetNPCObject(oldNPC)
  elseif unlockerType == "tinkr" then
    ClearNPCObject()
  end

  return descriptions
end