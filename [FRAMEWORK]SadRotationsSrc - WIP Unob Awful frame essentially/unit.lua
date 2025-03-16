local Tinkr, blink = ...
local Routine

if Tinkr.Util.Draw then
  Routine = Tinkr:require('Routine.Modules.Exports')
end

local ipairs, pairs = ipairs, pairs
local GetSpellInfo, GetSpellBaseCooldown, type, GetTime, CastSpellByName = GetSpellInfo, GetSpellBaseCooldown, type,
  GetTime, CastSpellByName
local TraceLine = TraceLine
local pi, band, atan2, atan, sqrt, pow, sin, cos, bor = math.pi, bit.band, math.atan2, math.atan, math.sqrt, math.pow,
  math.sin, math.cos, bit.bor
local losFlags = blink.losFlags
local tinsert, tremove, tsort = tinsert, tremove, table.sort
local ObjectField, ReadMemory = ObjectField, ReadMemory
local GetUnitAura = GetUnitAura
local GetSpecializationInfoByID, select = GetSpecializationInfoByID, select
local tContains = tContains
local idLists = blink.ObjectIDs or {}
local GetUnitAttachmentPosition = GetUnitAttachmentPosition

-- loads before objects, these are shell funcs for objects
local player = blink.player
C_Timer.NewTicker(0, function(self)
  if not player then
    player = blink.player
  else
    self:Cancel()
  end
end)

local UnlockerType = Tinkr.type

-- blink.IsSpellOnGCD = function(spell)
--   local spellName = C_Spell.GetSpellInfo(spell).name
--   if spellName then
--     local baseCD, gcd = GetSpellBaseCooldown(spellName)
--     return gcd and gcd > 0
--   end
-- end
blink.IsSpellOnGCD = function(spell)
  local spellCooldownInfo = C_Spell.GetSpellCooldown(spell)

  if spellCooldownInfo then
    local duration = spellCooldownInfo.duration
    local isEnabled = spellCooldownInfo.isEnabled

    return isEnabled and duration > 0
  end

  return false
end

local IsSpellOnGCD = blink.IsSpellOnGCD

local function BlinkTraceLine(...)
  if UnlockerType == "daemonic" then
    local hit, x, y, z = TraceLine(...)
    return x, y, z
  elseif UnlockerType == "noname" then
    local hit, x, y, z = TraceLine(...)
    return x, y, z
  else
    return TraceLine(...)
  end
end

blink.TraceLine = BlinkTraceLine

local swapSpellID = {
  [132411] = 119898,
}
local SecureCode = SecureCode
local Unlock = Unlock
local attemptedCasts = {}
blink.CastByID = function(spellID, unit, byName)
  unit = type(unit) == "table" and unit.pointer or unit
  if swapSpellID[spellID] then
    spellID = swapSpellID[spellID]
  end
  if IsSpellOnGCD(spellID) or not attemptedCasts[spellID] or GetTime() - attemptedCasts[spellID] > blink.buffer + 0.225 then
    if UnlockerType == "daemonic" then
      if byName then
        SecureCode("CastSpellByName", C_Spell.GetSpellInfo(spellID).name, unit)
      else
        SecureCode("CastSpellByID", spellID, unit)
      end
    elseif UnlockerType == "blade" then
      if byName then
        CastSpellByName(C_Spell.GetSpellInfo(spellID).name, unit)
      else
        CastSpellByID(spellID, unit)
      end
    elseif UnlockerType == "noname" then
      if byName then
        local spellName = C_Spell.GetSpellInfo(spellID).name
        --CastSpellByName(spellName, unit or "")
        Unlock('CastSpellByName', spellName, unit or "")
      else
        --CastSpellByID(spellID, unit or "")
        Unlock("CastSpellByID", spellID, unit or "")
      end
    else
      if byName then
        CastSpellByName(C_Spell.GetSpellInfo(spellID).name, unit or "")
      else
        CastSpellByID(spellID, unit or "")
      end
    end
    attemptedCasts[spellID] = GetTime()
  end
end

blink.UnitIsUnit = function(unit, otherUnit)
  if type(unit) == "table" then
    if type(otherUnit) == "table" then
      return otherUnit.pointer == unit.pointer
    end
    unit = unit.pointer
  elseif type(unit) == "string" then
    unit = Object(unit)
  end
  if type(otherUnit) == "table" then
    otherUnit = otherUnit.pointer
  elseif type(otherUnit) == "string" then
    otherUnit = Object(otherUnit)
  end
  if not unit or not otherUnit or not UnitExists(unit) or not UnitExists(otherUnit) then
    return false
  end
  return UnitIsUnit(unit, otherUnit)
end

blink.losCoords = function(unit, a, b, c, literal)
  if type(unit) ~= "table" then
    blink.debug.print("Invalid object passed to LoSCoords", "debug")
    return
  end
  if not unit.exists then
    return false
  end
  if not a or not b or not c then
    blink.debug.print("Invalid coords passed to to LoSCoords", "debug")
    return
  end
  local tx, ty, tz = unit.position()
  if not tz then
    blink.debug.print("primary unit not visible in losCoords check, returning false", "debug")
    return false
  end
  -- smoke bomb
  if not literal then
    local bomb, _, _, _, _, _, source = unit.debuff(212183)
    if bomb and not unit.friendOf(source) then
      return bomb
    end
  end

  if blink.encounterID == 2684 then
    losFlags = 0x111
  else
    losFlags = blink.losFlags
  end

  local x, y, z = BlinkTraceLine(tx, ty, tz + 1.8, a, b, c + 1.8, losFlags)
  return x == 0 and y == 0 and z == 0

end

local LosExceptions = idLists.LosExceptions
function blink.los(unit, otherUnit, literal)
  if not unit.exists then
    return false
  end

  otherUnit = otherUnit or player
  if otherUnit and otherUnit.exists then
    
    if unit.id and LosExceptions[unit.id] then
      return true
    end
    if otherUnit.id and LosExceptions[otherUnit.id] then
      return true
    end

    local x1, y1, z1 = unit.position()
    local x2, y2, z2 = otherUnit.position()

    if not z1 then
      blink.debug.print("primary unit not visible in los check, returning false", "debug")
      return false
    elseif not z2 then
      blink.debug.print("secondary unit not visible in los check, returning false", "debug")
      return false
    end

    --if unit.enemy and unit.buff(409293) then return false end -- enemy burrow is considered out of LoS
    --if otherUnit.enemy and otherUnit.buff(409293) then return false end -- enemy burrow is considered out of LoS

    if not literal then
      -- smoke bomb
      local bombOne, _, _, _, _, _, bombOneSource = unit.debuff(212183)
      local bombTwo, _, _, _, _, _, bombTwoSource = otherUnit.debuff(212183)

      -- check if units are within smoke bomb, unless source is friendly to the opposing unit
      if bombOneSource and not otherUnit.friendOf(bombOneSource) then
        return bombTwo
      end
      if bombTwoSource and not unit.friendOf(bombTwoSource) then
        return bombOne
      end

      -- sentinel
      if otherUnit.class2 == "HUNTER" then
        local sentinelDebuff = unit.debuff(393480, otherUnit)
        if sentinelDebuff then
          return true
        end
      end
    end

    local x, y, z = 0, 0, 0

    if blink.encounterID == 2684 then
      losFlags = 0x111
    else
      losFlags = blink.losFlags
    end

    x, y, z = BlinkTraceLine(x1, y1, z1 + 1.68, x2, y2, z2 + 1.68, losFlags)

    -- Tinkr fallback to Attachment Position when normal LoS fails
    if not UnlockerType and x ~= 0 then
      x1, y1, z1 = GetUnitAttachmentPosition(unit.pointer, 18)
      x2, y2, z2 = GetUnitAttachmentPosition(otherUnit.pointer, 18)

      z1 = z1 - 0.125
      z2 = z2 - 0.125
      x, y, z = BlinkTraceLine(x1, y1, z1, x2, y2, z2, losFlags)
    end

    return x == 0 and y == 0 and z == 0
  end
  return false
end

blink.GetUnitCooldown = function(pointer, spellID)
  return blink.CooldownTracker[pointer] and blink.CooldownTracker[pointer][spellID] or 0
end

blink.Distance = function(sx, sy, sz, tx, ty, tz)
  local tsx, tsy = type(sx), type(sy)
  if tsx == "table" and tsy == "number" then
    local x, y, z = sx.position()
    if not x or not sy then
      blink.debug.print(
        "object didn't exist for distance check against set coords, coords were given but no object exists", "debug")
      return 9999
    end
    -- return FastDistance(x, y, z, sy, sz, tx)
    return sqrt(((x - sy) ^ 2) + ((y - sz) ^ 2) + ((z - tx) ^ 2))
  elseif tsx == "number" and tsy == "number" then
    if sz and tx and ty and tz then
      return sqrt(((tx - sx) ^ 2) + ((ty - sy) ^ 2) + ((tz - sz) ^ 2))
    else
      return 9999
    end
  else
    if not sx then
      blink.debug.print("'false' received by distance check (sx)", "debug")
      return 9999
    end
    if not sy then
      sy = player
    end
    local x, y, z = sx.position()
    tx, ty, tz = sy.position()
    if not x then
      blink.debug.print("object1 not visible in distance check", "debug")
      return 9999
    end
    if sy and not tx then
      blink.debug.print("object2 not visible in distance check", "debug")
      return 9999
    end
    if not x or not y or not z or not tx or not ty or not tz then
      return 9999
    end
    return sqrt(((tx - x) ^ 2) + ((ty - y) ^ 2) + ((tz - z) ^ 2))
  end
end
blink.distance = blink.Distance

local cursorFlags = bor(0x1, 0x10, 0x100, 0x10000, 0x20000)
local waterFlags = bor(0x10000, 0x20000)

blink.cursorFlags = cursorFlags

if not UnlockerType then
  local WorldFrame, GetCursorPosition, ScreenToWorld = WorldFrame, GetCursorPosition, ScreenToWorld
  blink.CursorPosition = function(water)
    local maxX, maxY = WorldFrame:GetRight(), WorldFrame:GetTop()
    local x, y = GetCursorPosition()
    x = 2 * (x / maxX) - 1
    y = 2 * (y / maxY) - 1
    local x, y, z = ScreenToWorld(x, y, water and cursorFlags or blink.losFlags)
    return x, y, z, TraceLine(x, y, z + 4, x, y, z - 6, waterFlags) == 0 and true or false
  end

  blink.WorldToScreen = function(x, y, z)
    local maxX, maxY = WorldFrame:GetRight(), WorldFrame:GetTop()
    local x, y = WorldToScreen(x, y, z)
    x = x * maxX
    y = y * maxX
    return x, y
  end
else
  blink.CursorPosition = function(water)
    local maxX, maxY = WorldFrame:GetRight(), WorldFrame:GetTop()
    local x, y = GetCursorPosition()
    -- x = 2*(x/maxX)-1
    -- y = 2*(y/maxY)-1
    local x, y, z = ScreenToWorld(x, y, water and cursorFlags or blink.collisionFlags)
    return x, y, z, TraceLine(x, y, z + 4, x, y, z - 6, waterFlags) == 0 and true or false
  end

end
blink.GetCursorPosition = blink.CursorPosition

blink.PositionFromPosition = function(X, Y, Z, dist, angle)
  return cos(angle) * dist + X, sin(angle) * dist + Y, sin(0) * dist + Z
end

blink.AnglesBetween = function(X1, Y1, Z1, X2, Y2, Z2)
  return atan2(Y2 - Y1, X2 - X1) % (pi * 2), atan((Z1 - Z2) / sqrt(pow(X1 - X2, 2) + pow(Y1 - Y2, 2))) % pi;
end
blink.anglesBetween = blink.AnglesBetween

local rolesCachedByPointer = {}
C_Timer.NewTicker(8, function()
  wipe(rolesCachedByPointer)
end)
blink.rolesCachedByPointer = rolesCachedByPointer

local specRoles = {}
local function GetPlayerRole()
  local MeleeSpecs = {"Frost", "Unholy", "Havoc", "Feral", "Survival", "Windwalker", "Retribution", "Assassination",
                      "Outlaw", "Subtlety", "Enhancement", "Arms", "Fury"};
  local RangedSpecs = {"Frost", "Fire", "Arcane", "Beast Mastery", "Marskmanship", "Shadow", "Elemental", "Affliction",
                       "Destruction", "Demonology", "Balance", "Devastation"}
  local HealerSpecs = {"Holy", "Restoration", "Mistweaver", "Discipline", "Preservation"}
  local TankSpecs = {"Guardian", "Blood", "Protection", "Vengeance", "Brewmaster"}
  local LowLevelMelee = {"WARRIOR", "ROGUE", "DEATHKNIGHT", "MONK", "DEMONHUNTER", "PALADIN"}
  local LowLevelRanged = {"MAGE", "WARLOCK", "HUNTER", "SHAMAN", "DRUID", "PRIEST"}
  local spec = player.spec
  local class = player.class2
  if not spec or spec == "Unknown" then
    if player.level < 10 then
      if tContains(LowLevelMelee, class) then
        return "melee"
      end
      if tContains(LowLevelRanged, class) then
        return "ranged"
      end
    end
    return "unknown"
  end
  if tContains(TankSpecs, spec) then
    return "tank"
  end
  if tContains(MeleeSpecs, spec) and class ~= "MAGE" then
    return "melee"
  end
  if tContains(RangedSpecs, spec) then
    return "ranged"
  end
  if tContains(HealerSpecs, spec) then
    return "healer"
  end
  return "unknown"
end

local covByGUID = {}
C_Timer.NewTicker(120, function()
  covByGUID = {}
end)

blink.GetUnitCovenant = function(unit)
  if type(unit) ~= "table" or not unit.guid then
    return
  end
  if covByGUID[unit.guid] then
    return covByGUID[unit.guid]
  end
  local hiddenAuras = blink.HiddenAuras(unit.pointer)
  for i = 1, #hiddenAuras do
    local aura = hiddenAuras[i]
    -- venthyr
    if aura.id == 321079 -- kyrian
    or aura.id == 321076 -- necro
    or aura.id == 321078 -- fae
    or aura.id == 321077 then
      covByGUID[unit.guid] = aura.name
      return aura.name
    end
  end
end

-- local talentsByGUID = {}
-- C_Timer.NewTicker(60, function() talentsByGUID = {} end)

-- blink.UnitHasTalent = function(unit, id)
-- 	if type(unit) ~= "table" then return end
-- 	local guid = unit.guid
-- 	if not guid then return end
-- 	if not talentsByGUID[guid] then talentsByGUID[guid] = {} end
-- 	if talentsByGUID[guid][id] ~= nil then
-- 		return talentsByGUID[guid][id]
-- 	end
-- 	local hiddenAuras = blink.HiddenAuras(unit.pointer)
-- 	if type(id) == "string" then
-- 		for i=1,#hiddenAuras do
-- 			local aura = hiddenAuras[i]
-- 			if aura.name:lower() == id:lower() then
-- 				talentsByGUID[guid][id] = true
-- 				return true
-- 			end
-- 		end
-- 		talentsByGUID[guid][id] = false
-- 		return false
-- 	elseif type(id) == "number" then
-- 		for i=1,#hiddenAuras do
-- 			local aura = hiddenAuras[i]
-- 			if aura.id == id then
-- 				talentsByGUID[guid][id] = true
-- 				return true
-- 			end
-- 		end
-- 		talentsByGUID[guid][id] = false
-- 		return false
-- 	end
-- end

blink.HiddenAuras = function(unit)
  if not UnlockerType then
    local auras = {}
    for i = 1, 200 do
      local name, _, _, _, _, _, _, _, _, spellID = GetUnitAura(unit, i)
      if name or spellID then
        tinsert(auras, {
          name = name,
          id = spellID
        })
      end
    end
    return auras
  elseif UnlockerType == "daemonic" then
    local cnt = ObjectField(unit, 4712, 6)
    local tbl = ObjectField(unit, 1768, 14)
    if cnt == -1 then
      cnt = ObjectField(unit, 1768, 6)
      tbl = ObjectField(unit, 1768 + 8, 14)
    end
    local auras = {}
    if cnt == nil or cnt == 0 then
      return auras
    end
    for i = 0, cnt - 1 do
      local spellID = ReadMemory(tbl, (i * 184) + 144, 7)
      auras[#auras + 1] = {
        id = spellID,
        name = C_Spell.GetSpellInfo(spellID).name
      }
    end
    return auras

  end
end

blink.GetUnitRole = function(unit)
  if type(unit) ~= "table" or not unit.exists then
    return
  end
  if unit.initOptions.dummy then
    return "dummy"
  end
  if not unit.isPlayer then
    return "pet"
  end
  if unit.isUnit(player) then
    return GetPlayerRole()
  end

  local pointer = unit.guid
  if not pointer then
    return "unknown"
  end

  local role
  if WOW_PROJECT_ID == 11 then
    role = blink.wotlkRoleCache[pointer]
    if not role then
      role = blink.GetUnitRoleAndCache(unit, unit.pointer)
      blink.wotlkRoleCache[pointer] = {
        role = role,
        time = GetTime()
      }
    else
      role = role.role
    end
  else
    role = rolesCachedByPointer[pointer]
    if not role then
      role = blink.GetUnitRoleAndCache(unit, unit.pointer)
      rolesCachedByPointer[pointer] = role
    end
  end

  return role
end

blink.GetUnitRoleAndCache = function(unit, pointer)

  local rolesAssigned = UnitGroupRolesAssigned(pointer)
  if rolesAssigned == "HEALER" then
    return "healer"
  end
  if rolesAssigned == "TANK" then
    return "tank"
  end

  if GetArenaOpponentSpec then
    for i = 1, GetNumArenaOpponents() do
      if blink.UnitIsUnit("arena" .. i, unit) then
        local specid = GetArenaOpponentSpec(i)
        if specid then
          if select(5, GetSpecializationInfoByID(specid)) == "HEALER" then
            return "healer"
          end
          if select(5, GetSpecializationInfoByID(specid)) == "DAMAGER" or select(5, GetSpecializationInfoByID(specid)) ==
            "TANK" then
            local class = select(6, GetSpecializationInfoByID(specid))
            local spec = select(2, GetSpecializationInfoByID(specid))
            local TankSpecs = {"Guardian", "Vengeance", "Blood", "Protection", "Brewmaster"}
            local MeleeSpecs = {"Frost", "Unholy", "Havoc", "Feral", "Guardian", "Vengeance", "Survival", "Brewmaster",
                                "Windwalker", "Protection", "Retribution", "Assassination", "Outlaw", "Subtlety",
                                "Enhancement", "Arms", "Fury"};
            local RangedSpecs = {"Frost", "Fire", "Arcane", "Beast Mastery", "Marskmanship", "Shadow", "Elemental",
                                 "Affliction", "Destruction", "Demonology", "Balance", "Devastation", "Augmentation"}
            local HealerSpecs = {"Holy", "Restoration", "Mistweaver", "Discipline", "Preservation"}
            if tContains(TankSpecs, spec) then
              return "tank"
            end
            if tContains(MeleeSpecs, spec) then
              if spec ~= "Frost" or class ~= "MAGE" then
                return "melee"
              end
            end
            if tContains(RangedSpecs, spec) then
              if spec ~= "Frost" or class ~= "DEATHKNIGHT" then
                return "ranged"
              end
            end
            if tContains(HealerSpecs, spec) then
              return "healer"
            end
          end
        end
      end
    end
  end

  local specID = unit.specID
  local class = unit.class2
  if class == "DEATHKNIGHT" then
    if specID == 250 then
      return "tank"
    else -- 251, 252
      return "melee"
    end
  end
  if class == "DEMONHUNTER" then
    if specID == 581 then
      return "tank"
    else
      return "melee"
    end
  end
  if class == "DRUID" then
    if specID == 104 then
      return "tank"
    end
    if specID == 103 then
      return "melee"
    end
    if specID == 102 then
      return "ranged"
    end
    if specID == 105 then
      return "healer"
    end
  end
  if class == "EVOKER" then
    if specID == 1473 then
      return "ranged"
    end
    if specID == 1467 then
      return "ranged"
    end
    if specID == 1468 then
      return "healer"
    end
  end
  if class == "HUNTER" then
    if specID == 255 then
      return "melee"
    else
      return "ranged"
    end
  end
  if class == "MAGE" then
    return "ranged"
  end
  if class == "MONK" then
    if specID == 268 then
      return "tank"
    end
    if specID == 269 then
      return "melee"
    end
    if specID == 270 then
      return "healer"
    end
  end
  if class == "PALADIN" then
    if specID == 66 then
      return "tank"
    end
    if specID == 70 then
      return "melee"
    end
    if specID == 65 then
      return "healer"
    end
  end
  if class == "PRIEST" then
    if specID == 258 then
      return "ranged"
    else 
      return "healer"
    end
  end
  if class == "ROGUE" then
    return "melee"
  end
  if class == "SHAMAN" then
    if specID == 263 then
      return "melee"
    end
    if specID == 262 then
      return "ranged"
    end
    if specID == 264 then
      return "healer"
    end
  end
  if class == "WARLOCK" then
    return "ranged"
  end
  if class == "WARRIOR" then
    if specID == 73 then
      return "tank"
    else
      return "melee"
    end
  end
end

-- patch 9.x.x Shadowlands SL
blink.GetCovenantData = function()
  if not C_Covenants then
    return
  end
  local covenantID = C_Covenants.GetActiveCovenantID()
  if (not covenantID or covenantID == 0) then
    return nil
  end
  local covenantData = C_Covenants.GetCovenantData(covenantID)
  if (not covenantData) then
    return nil
  end
  local covenantName = covenantData.name
  local soulbindID = C_Soulbinds.GetActiveSoulbindID()
  if (not soulbindID or soulbindID == 0) then
    return nil
  end
  local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID)
  if (not soulbindData) then
    return nil
  end
  local id = soulbindData["ID"]
  -- local covenantID = soulbindData["covenantID"];
  local soulbindName = soulbindData["name"]
  local description = soulbindData["description"]
  local tree = soulbindData["tree"]
  local nodes = tree["nodes"]
  local activeConduitsSpells = {}
  activeConduitsSpells.covenantName = covenantName
  activeConduitsSpells.soulbindName = soulbindName
  activeConduitsSpells.conduits = {}
  for _, ve in pairs(nodes) do
    local node_id = ve["ID"]
    local node_row = ve.row
    local node_column = ve.column
    local node_spellID = ve.spellID -- this will be 0 for uninit spell, not nil
    local node_conduitID = ve.conduitID -- this will be 0 for uninit conduit, not nil
    local node_conduitRank = ve.conduitRank
    local node_state = ve.state
    local node_conduitType = ve.conduitType -- this can be nil
    if (node_state == 3) then
      local node_spellName
      if (node_spellID ~= 0) then
        node_spellName = GetSpellInfo(node_spellID)
      elseif (node_conduitID ~= 0) then
        local conduitSpellID = C_Soulbinds.GetConduitSpellID(node_conduitID, node_conduitRank)
        node_spellID = conduitSpellID
        node_spellName = GetSpellInfo(conduitSpellID)
      else
        node_spellID = nil
        node_spellName = nil
      end
      if (node_spellID) then
        activeConduitsSpells.conduits[#activeConduitsSpells.conduits + 1] = {
          spellID = node_spellID,
          spellName = node_spellName
        }
      end
    end
  end
  return activeConduitsSpells
end

blink.UnitMovingDirection = function(pointer)
  local dir = not UnlockerType and pointer:rotation() or ObjectRotation(pointer)
  local mod = 0
  local movementFlag = not UnlockerType and pointer:movementFlag() or ObjectMovementFlag(pointer)
  local flags = band(movementFlag, 0xF)
  if flags == 0x2 then
    mod = pi
  elseif flags == 0x4 then
    mod = pi * 0.5
  elseif flags == 0x8 then
    mod = pi * 1.5
  elseif flags == bor(0x1, 0x4) then
    mod = pi * (1 / 8) * 2
  elseif flags == bor(0x1, 0x8) then
    mod = pi * (7 / 8) * 2
  elseif flags == bor(0x2, 0x4) then
    mod = pi * (3 / 8) * 2
  elseif flags == bor(0x2, 0x8) then
    mod = pi * (5 / 8) * 2
  end
  return (dir + mod) % (pi * 2)
end

blink.PositionBetween = function(X1, Y1, Z1, X2, Y2, Z2, DistanceFromPosition1)
  local AngleXY, AngleXYZ = blink.AnglesBetween(X1, Y1, Z1, X2, Y2, Z2)
  -- local dist = blink.Distance(X1, Y1, Z1, X2, Y2, Z2)
  -- local zmod = DistanceFromPosition1/dist
  -- local FinalZ = Z1 + (Z2 - Z1) * zmod
  return blink.PositionFromPosition(X1, Y1, Z1, DistanceFromPosition1, AngleXY, AngleXYZ)
end
blink.positionBetween = blink.PositionBetween

blink.CombatReach = function(objectPointer)
  if Tinkr.type == "noname" then
    local _env = blink.env
    return _G.ObjectCombatReach(objectPointer) or 0
  else
    return ObjectCombatReach(objectPointer) or 0
  end
end

blink.GroundZ = function(x, y, z)
  if not y then
    x, y, z = x.position()
  end
  if UnlockerType == "daemonic" then
    local hit, tx, ty, tz = TraceLine(x, y, z + 4, x, y, -1000, blink.collisionFlags)
    if hit == 0 then
      return x, y, z
    end
    return tx, ty, tz
  else
    local tx, ty, tz = blink.TraceLine(x, y, z + 4, x, y, -1000, blink.collisionFlags)
    if tx == 0 then
      return x, y, z
    end
    return tx, ty, tz
  end
end

blink.enemiesAroundPoint = function(x, y, z, dist, unit)
  local avgDist, totalCount = 0, 0
  local totalDist = 0.00001 -- could divide by zero if this starts at zero
  local count = 0
  local bCC = 0
  local enemies = blink.enemies
  local adist = blink.Distance
  enemies.loop(function(enemy)
    if enemy.isUnit(unit) then
      return
    end
    local ex, ey, ez = enemy.position()
    local distFromPos = adist(x, y, z, ex, ey, ez)
    if distFromPos < dist then
      count = count + 1
      totalDist = totalDist + dist
      totalCount = totalCount + 1
      avgDist = totalDist / totalCount
    end
    if distFromPos < dist * 1.5 then
      totalCount = totalCount + 1
      totalDist = totalDist + distFromPos
    end
  end)
  avgDist = totalDist / totalCount
  return count, bCC, avgDist
end

blink.EnemiesAroundPoint = blink.enemiesAroundPoint
blink.EnemiesAroundPosition = blink.enemiesAroundPoint
blink.enemiesAroundPosition = blink.enemiesAroundPoint

local defaultExcludes = {
  ["silence"] = true,
  ["root"] = true,
  ["random_root"] = true,
  ["counterattack"] = true
}

blink.IsInCC = function(unit, types)

  if not unit.exists then
    blink.debug.print("object didn't exist in cc check. returned false / 0 / {} to fail gracefully", "debug")
    return false, 0, {}
  end

  local ccCheck, ccDuration = false, 0
  local detailedInfo = {}

  local ccDebuffs = blink.ccDebuffs

  local time = GetTime()
  for spellID, ccType in pairs(ccDebuffs) do
    if types and types[ccType] or not types and not defaultExcludes[ccType] then
      local thisDebuff, _, _, _, _, expires, thisSource = unit.debuff(spellID)
      local thisRemains = expires and expires - time or 0
      if expires == 0 or thisRemains > 0 then
        local thisCC = {spellID, thisDebuff, thisRemains, ccType, thisSource}
        detailedInfo[#detailedInfo + 1] = thisCC
        if thisRemains > ccDuration then
          ccDuration = thisRemains
          ccCheck = spellID
        end
      end
    end
  end

  return ccCheck, ccDuration, detailedInfo

end

blink.IsInBreakableCC = function(unit)

  if not unit.visible then
    blink.debug.print("object didn't exist in breakable cc check. returned false / 0 / {} to fail gracefully", "debug")
    return false, 0, {}
  end

  local ccCheck, ccDuration = false, 0
  local detailedInfo = {}

  local ccDebuffs = blink.bccDebuffs

  for spellID, ccType in pairs(ccDebuffs) do
    local thisRemains = unit.debuffRemains(spellID)
    if thisRemains > 0 then
      local thisSource = select(7, unit.debuff(spellID))
      local thisCC = {spellID, C_Spell.GetSpellInfo(spellID).name, thisRemains, ccType, thisSource}
      detailedInfo[#detailedInfo + 1] = thisCC
      if thisRemains > ccDuration then
        ccDuration = thisRemains
        ccCheck = spellID
      end
    end
  end

  return ccCheck, ccDuration, detailedInfo

end

blink.ObjectsFromGUID = {}
local ObjectsFromGUID = blink.ObjectsFromGUID
C_Timer.NewTicker(120, function()
  ObjectsFromGUID = {}
end)

local isTinkr = Tinkr.Util.Draw
local UnitGUID_Raw = UnitGUID_Raw
local ObjectManager = ObjectManager
local ObjectType = ObjectType
local Objects = Objects

function blink.populateAll_noname()
  local all = {}
  for i = 1, 17 do
    all[i] = {}
  end
  for i, pointer in ipairs(ObjectManagerRaw()) do
    local type = ObjectType(pointer)
    if pointer and type and all[type] then
      all[type][#all[type] + 1] = pointer
    end
  end
  blink.internal.all = all
end

blink.GetObjectWithGUID = function(GUID)
  if isTinkr then
    if not GUID or GUID == "" then
      return blink.unitPrototype
    end
    if blink.objectsByGUID[GUID] and blink.objectsByGUID[GUID].pointer then
      return blink.createObject(blink.objectsByGUID[GUID].pointer)
    end
    if blink.player and GUID == blink.player.guid then
      return blink.player
    end
    local object = Object(GUID)
    if object then
      return blink.createObject(object)
    end
    return blink.unitPrototype
  elseif UnlockerType == "noname" then
    if blink.objectsByGUID[GUID] then
      blink.objectsByGUID[GUID]:ClearCache()
      return blink.objectsByGUID[GUID]
    end
    if not blink.internal.all then
      blink.populateAll_noname()
    end
    local all = blink.internal.all
    for i = 6, 5, -1 do
      for j = 1, #all[i] do
        local object = all[i][j]
        if object and ObjectGUID(object) == GUID then
          return blink.createObject(object)
        end
      end
    end
    return false
  elseif UnlockerType == "daemonic" then
    -- if not GUID or GUID == "" then return end
    -- if ObjectsFromGUID[GUID] then return ObjectsFromGUID[GUID] end
    -- local thisObj = blink.createObject(GUID)
    -- ObjectsFromGUID[GUID] = thisObj
    -- return thisObj
    return blink.createObject(GUID)
  end
end

local totems = blink.totemIDs
local aTotems = {}
for _, v in ipairs(totems) do
  aTotems[v] = true
end

-- local hasBuff = function(unit, buff)
--   for i = 1, 25 do
--     local thingo = select(10, UnitBuff(unit, i))
--     if thingo == buff then
--       return true
--     elseif not thingo then
--       break
--     end
--   end
-- end

local hasBuff = function(unit, buff)
  -- Check if the unit exists
  if not UnitExists(unit) then
    blink.debug.print("Error: Unit does not exist -", tostring(unit))
    return false
  end

  -- Check if UnitBuff is a valid function
  if not UnitBuff then
    blink.debug.print("Error: UnitBuff function is missing.")
    return false
  end

  for i = 1, 25 do
    -- Use pcall to safely call UnitBuff and avoid breaking if an error occurs
    local success, thingo = pcall(function() return select(10, UnitBuff(unit, i)) end)
    
    if not success then
      blink.debug.print("Error: UnitBuff encountered an issue at index", i)
      return false
    end

    -- Check if the 10th return value matches the desired buff
    if thingo == buff then
      return true
    elseif not thingo then
      break
    end
  end
  
  -- Return false if the buff is not found
  return false
end


local tostring = tostring
local UnitIsPlayer = UnitIsPlayer
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsDeadOrGhost_OG = UnitIsDeadOrGhost
local UnitIsDeadOrGhost = function(unit)
  if hasBuff(unit, 5384) then
    return false
  end
  return UnitIsDeadOrGhost_OG(unit)
end
local Objects = Objects
local createObject
local _ENV = getfenv(1)
local ffromenv = {}
local wipe = table.wipe

local ubi_cache = {}
C_Timer.NewTicker(0.33, function()
  wipe(ubi_cache)
end)

local tconcat = table.concat
local cacheReturn = function(guid, func, ...)

  if not guid then
    return
  end

  local cache = ubi_cache

  local args = {...}
  local argsToString = func
  for i = 1, #args do
    local arg = args[i]
    local a2s = tostring(arg)
    if a2s then
      argsToString = argsToString .. a2s
    end
  end

  if cache then
    local cached = cache[argsToString]
    if cached ~= nil then
      return cached
    end
  end

  local findfunc = _ENV[func]

  local val = findfunc(...)

  if cache then
    cache[argsToString] = val
  end

  return val

end

local bad = {
  [8] = true, -- critter
  [14] = true -- wild pet??
}
local tup = {3, 4}

local function iterate(objects, callback)
  for i = 1, #objects do
    callback(objects[i])
  end
end

-- problem: need to avoid re-iterating unlocker OM over and over checking same things redundantly

-- need specific lists to populate when referenced
-- if first list reference for the frame, loop OM and add any new objects to objectsByGUID
-- loop objectsByGUID, find all existing objects

-- should loop OM once per frame and add any new objects to blink's objectsByGUID list

-- on Tinkr, the pointers for all of these objects should be updated from the OM each frame (not necessary on Daemonic, they can just remain static GUID)

local UnitIsUnit, UnitAffectingCombat, ObjectName = UnitIsUnit, UnitAffectingCombat, ObjectName
local UnitIsCharmed, UnitIsOtherPlayersPet = UnitIsCharmed, UnitIsOtherPlayersPet
local tContains = tContains
local ObjectTarget = ObjectTarget

local UnitIsFriend = UnitIsFriend
if Tinkr.Util.Draw then
  local Eval = Tinkr.Util.Evaluator
  UnitIsFriend = Eval:HookDouble("UnitIsFriend")
end

local rawset, rawget = rawset, rawget
local setmetatable = setmetatable

local OLConstructors = {}
blink.OLConstructors = OLConstructors
function blink:ListConstructor(func, types)
  local list = {}
  OLConstructors[#OLConstructors + 1] = {
    func = func,
    list = list
  }
  blink.immerseOL(list)

  return list
end

local cfc
blink.loadUnits = function(unitType)

  player = player or blink.player

  local arena = blink.arena
  local instanceType = blink.instanceType2
  local bg = instanceType == "pvp"

  local loaded = blink.internal.loaded
  local pPointer = player.pointer
  local internal = blink.internal
  local all = internal.all

  createObject = createObject or blink.createObject

  local inserted = blink.inserted

  local GetObjectCount = GetObjectCount
  local GetObjectWithIndex = GetObjectWithIndex or ObjectByIndex
  local ObjectType = ObjectType
  local UnitCreatureType = UnitCreatureType

  local OM = Tinkr.Util.ObjectManager
  if UnlockerType == "daemonic" and not all then
    all = {}
    -- sort objects by type
    for i = 1, 17 do
      all[i] = {}
    end
    for i = 1, GetObjectCount() do
      local pointer = GetObjectWithIndex(i)
      local type = ObjectType(pointer)
      if type then
        all[type][#all[type] + 1] = pointer
      end
    end
    blink.internal.all = all
  elseif UnlockerType == "noname" and not all then
    blink.populateAll_noname()
  end

  local function iterate(types, callback)
    local all = blink.internal.all
    if UnlockerType == "daemonic" then
      for _, type in ipairs(types) do
        for _, pointer in ipairs(all[type]) do
          callback(pointer, type, pointer)
        end
      end
    elseif UnlockerType == "noname" then
      for _, type in ipairs(types) do
        for _, pointer in ipairs(all[type]) do
          local guid = ObjectGUID(pointer)
          callback(pointer, type, guid)
        end
      end
    else
      local objects = {}
      for _, type in ipairs(types) do
        local list = Objects(type)
        for i = 1, #list do
          local obj = list[i]
          callback(obj, type, obj:guid())
        end
      end
    end
  end

  if not cfc then
    cfc = function(knownObject, object, list, options)
      if knownObject then
        local inserted = blink.inserted
        -- knownObject.options = knownObject.options -- ???
        if inserted and inserted[list] and not inserted[list][knownObject] then
          list[#list + 1] = knownObject
          inserted[list][knownObject] = true
        end
        return knownObject
      end
      return createObject(object, list, options)
    end
  end

  local knownObjects = blink.objectsByGUID
  if not loaded then
    loaded = {}
  end

  if type(unitType) == "table" then
    local listIndex, list
    for index, ol in ipairs(blink.Lists) do
      if ol._List == unitType then
        listIndex = index
        list = ol._List
        break
      end
    end
    if list and listIndex then
      iterate(unitType.types, function(object, type, guid)
        if not guid then
          return
        end
        if not object then
          return
        end
        local blinkObject = cfc(knownObjects[guid], object, unitType)
        if unitType.constructor(blinkObject, type, guid) then
          tinsert(list, blinkObject)
        end
      end)
    end
  elseif unitType == "objects" then
    if not loaded.objects then
      iterate({8}, function(object, objectType, guid)
        cfc(knownObjects[guid], object, blink.internal.objects, {
          guid = guid
        })
      end)
      loaded.objects = true
    end
  elseif unitType == "dynamicObjects" then
    if not loaded.dynamicObjects then
      iterate({9}, function(object, objectType, guid)
        cfc(knownObjects[guid], object, blink.internal.dynamicObjects)
      end)
      loaded.dynamicObjects = true
    end
  elseif unitType == "areaTriggers" then
    if not loaded.areaTriggers then
      iterate({11}, function(object, objectType, guid)
        cfc(guid and knownObjects[guid], object, blink.internal.areaTriggers)
      end)
      loaded.areaTriggers = true
    end
  elseif not loaded[unitType] then

    local objectTypes = {}

    if unitType ~= "friends" and unitType ~= "players" then
      objectTypes[#objectTypes + 1] = 5
      loaded["units"] = true
      loaded["friendlyTotems"] = true
    end

    if unitType ~= "units" and unitType ~= "totems" and unitType ~= "friendlyTotems" and unitType ~= "wildseeds" and
       unitType ~= "pets" and unitType ~= "enemyPets" and unitType ~= "critters" and unitType ~= "friendlyPets" and
       unitType ~= "imps" and unitType ~= "shades" and unitType ~= "clones" and unitType ~= "rocks" and unitType ~= "tyrants" and
       unitType ~= "explosives" and unitType ~= "incorporeals" and unitType ~= "afflicteds" then
      objectTypes[#objectTypes + 1] = 6
      loaded["players"] = true
    end

    if unitType == "pets" then
      loaded["pets"] = true
    elseif unitType == "friends" then
      loaded["friends"] = true
    elseif unitType ~= "friendlyPets" then

      loaded["imps"] = true
      loaded["totems"] = true
      loaded["wildseeds"] = true
      loaded["shades"] = true
      loaded["clones"] = true
      loaded["rocks"] = true
      loaded["tyrants"] = true
      loaded["explosives"] = true
      loaded["incorporeals"] = true
      loaded["afflicteds"] = true

      if (loaded.units or tContains(objectTypes, 5)) and (loaded.players or tContains(objectTypes, 6)) then
        loaded["enemies"] = true
        loaded["allEnemies"] = true
      end

    end

    iterate(objectTypes, function(obj, objectType, guid)
      if not obj then
        return
      end
      if not guid then
        return
      end

      for i = 1, #OLConstructors do
        local olc = OLConstructors[i]
        local list = olc.list
        local func = olc.func
        if func(obj) then
          local knownObject = knownObjects[guid]
          cfc(knownObject, obj, list)
        end
      end

      -- ...re-insert cached blink objects by guid into appropriate tables?
      local knownObject = knownObjects[guid]

      local creatureType = UnlockerType and UnitCreatureType(obj) or not UnlockerType and obj:creatureType()
      -- critterz go in critterz 
      if creatureType and
        (creatureType == 8 or creatureType == 14 or creatureType == "Critter" or creatureType == "Wild Pet") then
        cfc(knownObject, obj, blink.internal.critters)
        return
      end

      local isPlayer = (UnlockerType == "daemonic" or UnlockerType == "noname") and UnitIsPlayer(obj) or
                         not UnlockerType and not creatureType
      local dead = cacheReturn(guid, "UnitIsDeadOrGhost", obj)
      if dead then
        cfc(knownObject, obj, internal.dead)
        if isPlayer then
          if not hasBuff(obj, 5384) then
            return
          end
        else
          return
        end
      end

      local canAttack = unitType ~= "friends" and unitType ~= "friendlyPets" and
                          cacheReturn(guid, "UnitCanAttack", "player", obj)

      local id = (UnlockerType == "daemonic" or UnlockerType == "noname") and ObjectID(obj) or not UnlockerType and
                   obj:id()

      if objectType == 6 then
        cfc(knownObject, obj, internal.players, { type = 6 })
      elseif objectType == 5 and (not arena or not id or id and not blink.ObjectIDs.ArenaUnitBlacklist[id]) then
        cfc(knownObject, obj, internal.units)
      end

      if id == 59271 or id == 59262 then
        cfc(knownObject, obj, blink.internal.objects)
        return
      end

      -- pets
      if (unitType == "pets" or unitType == "friendlyPets" or unitType == "enemyPets") and not isPlayer then
        if cacheReturn(guid, "UnitIsOtherPlayersPet", obj) then
          cfc(knownObject, obj, internal.pets)
          if canAttack then
            cfc(knownObject, obj, internal.enemyPets)
          elseif cacheReturn(guid, "UnitIsFriend", "player", obj) then
            cfc(knownObject, obj, internal.friendlyPets)
          end
        end
      end

      -- friendly totems
      if id and aTotems[id] and cacheReturn(guid, "UnitIsFriend", "player", obj) then
        cfc(knownObject, obj, internal.friendlyTotems)
      end

      -- seeds
      if id == 164589 then
        cfc(knownObject, obj, internal.wildseeds)
      end

      -- afflicteds
      if id == 204773 then
        return cfc(knownObject, obj, internal.afflicteds)
      end

      -- enemies
      if canAttack then
        -- all enemies
        if not cacheReturn(guid, "UnitIsCharmed", obj) then
          cfc(knownObject, obj, internal.allEnemies)
        end
        -- tyrants
        if id == 135002 then
          cfc(knownObject, obj, internal.tyrants)
        end
        -- windwalker images
        if id == 69791 or id == 69792 then
          cfc(knownObject, obj, internal.wwClones)
        end
        -- spiteful shade
        if id == 174773 then
          cfc(knownObject, obj, internal.shades)
        end
        -- 'splosives
        if id == 120651 then
          return cfc(knownObject, obj, internal.explosives)
        end
        -- incorporeals
        if id == 204560 then
          return cfc(knownObject, obj, internal.incorporeals)
        end
        -- imps
        if id == 416 or id == 58959 then
          cfc(knownObject, obj, internal.imps)
        end
        -- dwaynes (rocks)
        if id == 95072 then
          cfc(knownObject, obj, internal.rocks)
        end
        -- totems
        if id and id ~= 100943 and aTotems[id] then
          cfc(knownObject, obj, internal.totems)
        end
        -- bg/arena enemies
        if arena or bg then
          if isPlayer or blink.mapID == 2177 then -- Comp Stomp as all the enemies are NPCs
            if not cacheReturn(guid, "UnitIsCharmed", obj) and not aTotems[id] then
              cfc(knownObject, obj, internal.enemies)
            end
          else
            cfc(knownObject, obj, internal.enemyPets)
          end
        else
          cfc(knownObject, obj, internal.enemyPets)
          if id and idLists.Dummies[id] then
            cfc(knownObject, obj, internal.enemies, {
              dummy = true
            })
          elseif isPlayer then
            if UnitIsUnit(obj, "target") or UnitIsUnit(obj, "focus") then
              cfc(knownObject, obj, internal.enemies)
            else
              local objTarget = ObjectTarget(obj)
              if objTarget and UnitIsUnit("player", objTarget) then
                cfc(knownObject, obj, internal.enemies)
              end
            end
          elseif id and idLists.CombatExceptions[id] or UnitAffectingCombat(obj) and id and not idLists.UnitBlacklist[id] then
            cfc(knownObject, obj, internal.enemies)
          else
            local objTarget = ObjectTarget(obj)
            if objTarget then
              local objTargetType = ObjectType(objTarget)
              if objTargetType == 6 or objTargetType == 7 then
                cfc(knownObject, obj, internal.enemies)
              end
            end
          end
        end
      end

      -- friends
      if unitType == "friends" then
        if isPlayer and UnitIsFriend("player", obj) then
          cfc(knownObject, obj, internal.friends)
        end
      end
    end)

  end

end

blink.UnitIsFacingPosition = function(unit, tX, tY, tZ, angle, ignoreDist)

  if not unit.exists then
    blink.debug.print("invalid object passed to UnitIsFacingPosition", "debug")
    return false
  end

  if not tX or not tY or not tZ then
    blink.debug.print("invalid position passed to UnitIsFacingPosition", "debug")
    return false
  end

  angle = angle or 180

  local x, y, z = unit.position()
  local rotation = unit.rotation

  local angleToUnit = blink.AnglesBetween(x, y, z, tX, tY, tZ)
  local angleDifference = rotation > angleToUnit and rotation - angleToUnit or angleToUnit - rotation
  local shortestAngle = angleDifference < pi and angleDifference or pi * 2 - angleDifference
  local finalAngle = shortestAngle / (pi / 180)

  -- blink.drawCone = {
  -- 	{x, y, z},
  -- 	{tX, tY, tZ},
  -- 	angle,
  -- 	unit.distanceTo(otherUnit)
  -- }

  if finalAngle < angle / 2 then
    return true
  end

  local distance = unit.distanceToLiteral(tX, tY, tZ)
  if not ignoreDist and distance < 1.5 then
    return true
  end

end

blink.UnitIsFacingUnit = function(unit, otherUnit, angle)

  if not unit.exists or not otherUnit.exists then
    return false
  end

  angle = angle or 180

  local x, y, z = unit.position()
  local tX, tY, tZ = otherUnit.position()
  local rotation = unit.rotation

  local angleToUnit = blink.AnglesBetween(x, y, z, tX, tY, tZ)
  local angleDifference = rotation > angleToUnit and rotation - angleToUnit or angleToUnit - rotation
  local shortestAngle = angleDifference < pi and angleDifference or pi * 2 - angleDifference
  local finalAngle = shortestAngle / (pi / 180)

  -- blink.drawCone = {
  -- 	{x, y, z},
  -- 	{tX, tY, tZ},
  -- 	angle,
  -- 	unit.distanceTo(otherUnit)
  -- }

  if finalAngle < angle / 2 then
    return true
  end

  local distance = unit.distanceToLiteral(otherUnit)
  if distance < 1.5 then
    return true
  end

end

blink.MovingAwayHistory = {}
blink.TimeMovingAwayFrom = function(pointer, otherPointer, status, options)
  local time = blink.time
  local longest = 0

  blink.MovingAwayHistory[#blink.MovingAwayHistory + 1] = {
    status = status,
    pointer = pointer,
    otherPointer = otherPointer,
    time = time
  }

  local directFlags = {1, 5, 9, 4, 8, 2057, 2053, 2049, 2056, 2052}

  for i, history in ipairs(blink.MovingAwayHistory) do
    if history and time - history.time > 10 then
      tremove(blink.MovingAwayHistory, i)
    end
  end

  options = options or {}
  for i, history in ipairs(blink.MovingAwayHistory) do
    if history.pointer == pointer and history.otherPointer == otherPointer then
      if history.status.isMovingAway then
        if options.flags and tContains(options.flags, history.status.flags) or not options.flags and
          tContains(directFlags, history.status.flags) then
          local timeSince = time - history.time
          if timeSince > longest then
            longest = timeSince
          end
        end
      else
        longest = 0
      end
    end
  end

  return longest
end

blink.MovingTowardHistory = {}
blink.TimeMovingToward = function(pointer, otherPointer, status, options)

  local time = blink.time
  local longest = 0

  blink.MovingTowardHistory[#blink.MovingTowardHistory + 1] = {
    status = status,
    pointer = pointer,
    otherPointer = otherPointer,
    time = time
  }

  local directFlags = {1, 5, 9, 2057, 2053, 2049}

  for i, history in ipairs(blink.MovingTowardHistory) do
    if history and time - history.time > 10 then
      tremove(blink.MovingTowardHistory, i)
    end
  end

  options = options or {}
  for i, history in ipairs(blink.MovingTowardHistory) do
    if history.pointer == pointer and history.otherPointer == otherPointer then
      if history.status.isMovingToward then
        if options.flags and tContains(options.flags, history.status.flags) or not options.flags and
          tContains(directFlags, history.status.flags) then
          local timeSince = time - history.time
          if timeSince > longest then
            longest = timeSince
          end
        end
      else
        longest = 0
      end
    end
  end

  return longest

end

blink.ImmuneHealing = function(obj, checkRemains)

  local rem = 0

  local function checkImmune(id, info, type)
    local field = type == "buff" and "buffRemains" or "debuffRemains"
    -- healing effects
    if info.healing then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player)) then
        if r > rem then
          rem = r
        end
        return true
      end
    end
  end

  if not checkRemains then
    for buffID, info in pairs(blink.immunityBuffs) do
      if checkImmune(buffID, info, "buff") then
        return true
      end
    end
    for debuffID, info in pairs(blink.immunityDebuffs) do
      if checkImmune(debuffID, info, "debuff") then
        return true
      end
    end
    return false
  else
    for buffID, info in pairs(blink.immunityBuffs) do
      checkImmune(buffID, info, "buff")
    end
    for debuffID, info in pairs(blink.immunityDebuffs) do
      checkImmune(debuffID, info, "debuff")
    end
    return rem
  end

end

local tempOptions = {}

blink.ImmuneMagic = function(obj, options)

  options = options or tempOptions
  local immuneDamage = {
    spell = nil,
    remains = 0,
    targeted = {
      spell = nil,
      remains = 0
    }
  }
  local immuneEffects = {
    spell = nil,
    remains = 0,
    targeted = {
      spell = nil,
      remains = 0
    }
  }

  local function checkImmune(id, info, type)
    local field = type == "buff" and "buffRemains" or "debuffRemains"
    -- effects
    if info.effects and info.effects.magic then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player, options)) and
        (id ~= 213602 or not options.interrupt) and (id ~= 212295 or not options.purge) then
        if r > immuneEffects.remains then
          immuneEffects.remains = r
          immuneEffects.spell = id
        end
      end
    end
    -- damage
    if info.damage and info.damage.magic then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player, options)) then
        if r > immuneDamage.remains then
          immuneDamage.remains = r
          immuneDamage.spell = id
        end
      end
    end
    -- targeted effects
    if info.effects and info.effects.magicTargeted then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player)) and (id ~= 213602 or not options.interrupt) and
        (id ~= 212295 or not options.purge) then
        if r > immuneEffects.targeted.remains then
          immuneEffects.targeted.remains = r
          immuneEffects.targeted.spell = id
        end
      end
    end
    -- targeted damage
    if info.damage and info.damage.magicTargeted then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player)) then
        if r > immuneDamage.targeted.remains then
          immuneDamage.targeted.remains = r
          immuneDamage.targeted.spell = id
        end
      end
    end
  end

  for buffID, info in pairs(blink.immunityBuffs) do
    checkImmune(buffID, info, "buff")
  end

  for debuffID, info in pairs(blink.immunityDebuffs) do
    checkImmune(debuffID, info, "debuff")
  end

  return immuneDamage, immuneEffects

end

blink.ImmunePhysical = function(obj, options)

  options = options or tempOptions
  local immuneDamage = {
    spell = nil,
    remains = 0,
    targeted = {
      spell = nil,
      remains = 0
    }
  }
  local immuneEffects = {
    spell = nil,
    remains = 0,
    targeted = {
      spell = nil,
      remains = 0
    }
  }

  local function checkImmune(id, info, type)
    local field = type == "buff" and "buffRemains" or "debuffRemains"
    -- effects
    if info.effects and info.effects.physical then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player, options)) and
        (id ~= 213602 or not options.interrupt) and (id ~= 212295 or not options.purge) then
        if r > immuneEffects.remains then
          immuneEffects.remains = r
          immuneEffects.spell = id
        end
      end
    end
    -- damage
    if info.damage and info.damage.physical then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player, options)) then
        if r > immuneDamage.remains then
          immuneDamage.remains = r
          immuneDamage.spell = id
        end
      end
    end
    -- targeted effects
    if info.effects and info.effects.physicalTargeted then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player, options)) and
        (id ~= 213602 or not options.interrupt) and (id ~= 212295 or not options.purge) then
        if r > immuneEffects.targeted.remains then
          immuneEffects.targeted.remains = r
          immuneEffects.targeted.spell = id
        end
      end
    end
    -- targeted damage
    if info.damage and info.damage.physicalTargeted then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player, options)) then
        if r > immuneDamage.targeted.remains then
          immuneDamage.targeted.remains = r
          immuneDamage.targeted.spell = id
        end
      end
    end
  end

  for buffID, info in pairs(blink.immunityBuffs) do
    checkImmune(buffID, info, "buff")
  end

  for debuffID, info in pairs(blink.immunityDebuffs) do
    checkImmune(debuffID, info, "debuff")
  end

  if obj.channelID == 113656 then
    if obj.channelRemains > immuneDamage.remains then
      immuneDamage.remains = obj.channelRemains
      immuneDamage.spell = obj.channelID
    end
    if obj.channelRemains > immuneEffects.remains then
      immuneEffects.remains = obj.channelRemains
      immuneEffects.spell = obj.channelID
    end
  end

  return immuneDamage, immuneEffects

end

local incarns = {50334, 102558}
blink.ImmuneCC = function(obj, ccType)

  local immune = false
  local remains = 0

  local function checkImmune(id, info, type)
    local field = type == "buff" and "buffRemains" or "debuffRemains"
    -- cc
    if info.cc == true or info.cc == ccType then
      local r = obj[field](id)
      if r > 0 and (not info.conditions or info.conditions(obj, player)) then
        if r > remains then
          remains = r
          immune = id
        end
      end
    end
  end

  local incarn = obj.buffFrom(incarns)
  if incarn then
    for i, buffDesc in ipairs(obj.buffDescriptions) do
      local buff = obj.buffs[i]
      if buff and buff[10] == incarn[1] and buffDesc:match("effects that cause loss of control") then
        immune = buff[10]
        remains = obj.buffRemains(buff[10])
      end
    end
  end

  for buffID, info in pairs(blink.immunityBuffs) do
    checkImmune(buffID, info, "buff")
  end

  for debuffID, info in pairs(blink.immunityDebuffs) do
    checkImmune(debuffID, info, "debuff")
  end

  return immune, remains

end

blink.GetBestPositionAwayFromEnemies = function(options, conditions, enemies)

  local units = enemies or blink.enemies

  local validPositions = {}
  local range = options.range or blink.print("Hey dumb dumb put range in options dummy head dumbass.")
  if not range then
    return
  end

  -- prioritize positions with more enemies out of los
  local losPrio = options.losPrio

  -- 2nd param oop method of checking some set of conditions on all enemies against position (like not being a healer or w/e)
  conditions = conditions or function()
    return true
  end

  local circle = pi * 2 -- full circle in radians
  local checks = 20 -- how many positions we will check around the full circle
  local step = circle / checks

  local px, py, pz = blink.player.position()
  local collisionFlags = blink.collisionFlags

  -- looping between each angle of full circle for given number of checks
  for i = 0, circle, step do
    -- ground z position at given range away from player in this check's direction (angle in radians)
    local x, y, z = blink.GroundZ(px + range * cos(i), py + range * sin(i), pz)
    -- check if all coords came back from ground z check
    if x and y and z -- player height is 1.6 yds, check if this position is in LoS of player
    and TraceLine(x, y, z + 1.6, px, py, pz + 1.6, collisionFlags) == 0 then

      -- gonna get avg dist from this pos to all enemies
      local totalDist, distChecks = 0, 0

      -- num enemies out of line
      local losCount = 0

      -- now here we are looping through every enemy checking shit
      for _, enemy in ipairs(units) do
        -- meets given conditions if any
        if conditions(enemy) then
          local ex, ey, ez = enemy.position()
          if ex and ey and ez then
            -- for average dist
            local dist = blink.Distance(x, y, z, ex, ey, ez)
            distChecks = distChecks + 1
            totalDist = totalDist + dist
            -- not in los
            if losPrio and TraceLine(x, y, z + 1.6, ex, ey, ez + 1.6, collisionFlags) ~= 0 then
              losCount = losCount + 1
            end
          end
        end
      end

      -- can't divide by 0
      local avgRange = distChecks > 0 and totalDist / distChecks or 0

      -- put all that shit we collected in list of valid positions
      tinsert(validPositions, {
        avgRange = avgRange,
        losCount = losCount,
        pos = {x, y, z}
      })

    end
  end

  -- return best pos
  if #validPositions > 0 then
    -- sort the list of valid points
    tsort(validPositions, function(x, y)
      return x.losCount > y.losCount or x.losCount == y.losCount and x.avgRange > y.avgRange
    end)
    if not options or not options.table then
      -- return best
      local x, y, z = unpack(validPositions[1].pos)
      return x, y, z
    else
      return validPositions
    end

  end

end
