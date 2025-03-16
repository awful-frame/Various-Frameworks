local Tinkr, blink = ...
local bin = blink.bin
local cos, sin = math.cos, math.sin
local focus, target, enemyHealer = blink.focus, blink.target, blink.enemyHealer
local unlockerType = Tinkr.Util.Draw and "tinkr" or Tinkr.type
local Evaluator, Eval = Tinkr.Util.Evaluator, Eval
local SecureCode = SecureCode
local Unlock, UnlockObject = Unlock, UnlockObject
local _G, unpack, type = _G, unpack, type
local floor = math.floor

-- blink.cooldown = function(spell)
--   local start, duration
--   if spellid == 2061 then
--     start, duration = GetSpellCooldown(605)
--   elseif spellid == 1784 then
--     start, duration = GetSpellCooldown(IsPlayerSpell(108208) and 115191 or 1784)
--   else
--     start, duration = GetSpellCooldown(spell)
--   end
--   local time = GetTime()
--   if not start then
--     return 0
--   end
--   if duration + (start - time) > 0 then
--     return duration + (start - time)
--   else
--     return 0
--   end
-- end
blink.cooldown = function(spell)
  local start, duration, isEnabled
  local spellId

  -- Determine the spell ID based on conditions
  if spell == 2061 then
    spellId = 605
  elseif spell == 1784 then
    spellId = IsPlayerSpell(108208) and 115191 or 1784
  else
    spellId = spell
  end

  -- Get cooldown info using C_Spell.GetSpellCooldown
  local spellCooldownInfo = C_Spell.GetSpellCooldown(spellId)
  if spellCooldownInfo then
    start = spellCooldownInfo.startTime
    duration = spellCooldownInfo.duration
    isEnabled = spellCooldownInfo.isEnabled
  else
    return 0 -- No cooldown info available
  end

  -- Check if the cooldown is enabled and active
  if isEnabled and start and duration and duration > 0 then
    local time = GetTime()
    local remaining = duration + (start - time)
    return remaining > 0 and remaining or 0
  else
    return 0 -- No active cooldown or cooldown on hold
  end
end


local checked = 0
local focused = {}
blink.focused = focused

local readyToFocusHealer = true

blink.AutoFocus = function()

  local enemyHealer = blink.enemyHealer

  -- never out of arena
  if not blink.arena then
    return
  end

  -- ready to focus healer if healer is ever NOT visible
  if not enemyHealer.visible then
    readyToFocusHealer = true
  end

  -- if focus is changed manually to our target, don't force it to change back?

  local readyToFocus = not focus.exists or readyToFocusHealer and enemyHealer.visible or focus.isUnit(target)
  if not readyToFocus then
    return
  end

  if enemyHealer.exists and enemyHealer.guid and not enemyHealer.isUnit(blink.target) then
    enemyHealer.setFocus()
    blink.alert("Focusing Healer")
    focused[enemyHealer.guid] = true
    readyToFocusHealer = false
  else
    for _, enemy in ipairs(blink.enemies) do
      if not enemy.isUnit(blink.target) then
        enemy.setFocus()
        blink.alert("Focusing Off-DPS")
        break
      end
    end
  end

end

local C_Container = C_Container

local function containerFreeSlots(i)
  return C_Container.GetContainerNumFreeSlots(i)
end

local function itemCooldown(id)
  return C_Container.GetItemCooldown(id)
end

blink.GetNumFreeBagSlots = function()
  local count = 0
  for i = 0, 5 do
    local numFreeSlots, bagFamily = containerFreeSlots(i)
    if numFreeSlots and bagFamily == 0 then
      count = count + numFreeSlots
    end
  end
  return count
end

blink.GetItemCD = function(itemID)
  if IsEquippedItem(itemID) then
    local start, duration = itemCooldown(itemID)
    if start and duration then
      if start == 0 and duration == 0 then
        return 0
      end
      return duration - (GetTime() - start)
    end
  end
  return math.huge
end

blink.round = function(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return floor(num * mult + 0.5) / mult
end

local spellHaste = _G.UnitSpellHaste

blink.GetGCD = function()
  return 1.5 / (1 + (spellHaste("player") / 100)), blink.cooldown(61304)
end

-- local PathTypes = blink.PathTypes

-- local fwFunc = function() return 0 end
-- function blink:Nav(x1, y1, z1, x2, y2, z2, weights, mapID)
-- 	mapID = mapID or self.mapID
-- 	if Tinkr.type == "daemonic" then
-- 			local path = {}
-- 			local count = FindPath(mapID, x1, y1, z1, x2, y2, z2, IsSwimming())
-- 			if count == 0 then
-- 					return false
-- 			end
-- 			for i=1,count do
-- 					local x, y, z = GetPathNode(i)
-- 					path[#path+1] = { x=x, y=y, z=z }
-- 			end
-- 			return path, PathTypes.PATHFIND_NORMAL
-- 	elseif Tinkr.Util.Draw then
-- 			local path, pathType = GeneratePathWeighted(x1, y1, z1, x2, y2, z2, mapID, weights or fwFunc)
-- 			if pathType == PathTypes.PATHFIND_NOPATH and (not path or #path < 3) then
-- 					return false
-- 			end
-- 			return path, pathType
-- 	end
-- end

-- local Detour = Tinkr.Util.Detour

blink.castTime = function(spell, raw)
  local castTime = C_Spell.GetSpellInfo(spell).castTime / 1000
  if castTime == 0 and not raw then
    local baseCD, incursGCD = GetSpellBaseCooldown(spell)
    if incursGCD and incursGCD > 0 then
      incursGCD = incursGCD / 1000
      incursGCD = incursGCD / (1 + (spellHaste("player") / 100))
      return incursGCD
    end
  end
  return castTime
end

blink.spellInRange = function(spellID, unit, otherUnit)
  local player = blink.player
  otherUnit = otherUnit or player
  if unit.visible and (type(spellID) == "number" or IsUsableSpell(spellID)) then
    local spellRange = select(6, GetSpellInfo(spellID));

    -- these talents, spells or conditions don't affect GetSpellInfo spell range return
    -- or affect it weirdly

    -- balance affinity
    spellRange = spellRange + (IsPlayerSpell(197488) and (spellRange == 0 and 8 or 4) or 0)
    -- death sentence
    spellRange = spellRange + (spellid == 163201 and IsPlayerSpell(198500) and 10 or 0)
    -- shadowstrike in stealth - tooltip says 25y but it's more like 22.5
    spellRange = spellRange + bin(spellID == 185438) * ((player.buff(1784) or player.buff(115191)) and 22.5 or 0)
    -- kill command ?
    if spellID == 34026 then
      return true
    end

    return spellRange > 0 and unit.distanceTo(otherUnit) <= spellRange or spellRange == 0 and
             unit.meleeRangeOf(otherUnit)
  end
end

-- if path is directly to the point, it creates multiple duplicate points - need to remove those from the path
-- if the path is directly to the point, need to get points inbetween current pos and end point like already doing + generate more based on size
-- if it's not direct, then need to get the path points instead of points between

blink.verifyPath = function(path)
  local x, y, z
  for i = 1, #path do
    local p = path[i]
    if x and y and z then
      if blink.Distance(p.x, p.y, p.z, x, y, z) > 2 then
        return false
      end
      x, y, z = p.x, p.y, p.z
    else
      x, y, z = p.x, p.y, p.z
    end
  end
  return true
end

blink.cleanDuplicatePoints = function(path)

  local shouldRemove = {}

  local newPath = {}

  local x, y, z
  for k, v in pairs(path) do
    if v.x == x and v.y == y and v.z == z then
      x, y, z = v.x, v.y, v.z
      shouldRemove[k] = true
    else
      local px, py, pz = blink.player.position()
      local ex, ey, ez = path[#path].x, path[#path].y, path[#path].z

      local cl = abs((v.y - py / v.x - px) - (ey - py / ex - px)) <= 0.5

      if cl and k ~= 1 and k ~= #path then
        x, y, z = v.x, v.y, v.z
        shouldRemove[k] = true
      else
        x, y, z = v.x, v.y, v.z
      end
    end
  end

  for k, v in pairs(shouldRemove) do
    path[k] = nil
  end

  for k, v in pairs(path) do
    table.insert(newPath, v)
  end

  return newPath

end

blink.cleanPath = function(path, checksBetween)

  if not path[1] then
    print("no points on path")
    return {}
  end

  local shouldRemove = {}

  local x, y, z
  local markEnd
  for k, v in pairs(path) do
    if v.x == x and v.y == y and v.z == z or markEnd then
      shouldRemove[k] = true
    elseif x and y and z and k < 3 and (TraceLine(x, y, z + 1.8, v.x, v.y, v.z + 1.8, blink.collisionFlags) ~= 0 or
      TraceLine(v.x + 0.05, v.y, v.z + 1, v.x - 0.05, v.y, v.z, blink.collisionFlags) ~= 0) then
      markEnd = true
      shouldRemove[k] = true
      for kill = #path, 0, -1 do
        shouldRemove[kill] = true
      end
    else
      x, y, z = v.x, v.y, v.z
    end
  end

  for k, v in pairs(shouldRemove) do
    path[k] = nil
  end

  if markEnd then
    return path
  end

  local size = #path

  local finalPath = {unpack(path)}

  if size < checksBetween then
    local setSize = checksBetween / size
    for i = 1, #path do
      if path[i + 1] then
        local cx, cy, cz = path[i].x, path[i].y, path[i].z
        local nx, ny, nz = path[i + 1].x, path[i + 1].y, path[i + 1].z
        local d = blink.Distance(cx, cy, cz, nx, ny, nz)
        for p = 0, d, d / setSize do
          local bx, by, bz = blink.PositionBetween(cx, cy, cz, nx, ny, nz, p)
          if bx and by and bz then
            table.insert(finalPath, {
              x = bx,
              y = by,
              z = bz
            })
          end
        end
      end
    end
  end

  return finalPath

end

blink.fastestLoS = function(unit, x, y, z, elapsed, numChecks, manual)

  if not unit or not unit.visible then
    return
  end

  local circ = math.pi * 2
  numChecks = numChecks or 12

  local dist = unit.speed2 * elapsed
  local ux, uy, uz = unit.predictPosition(elapsed / 1.2)
  blink.drawMovePred = {ux, uy, uz}

  if TraceLine(ux, uy, uz + 2, x, y, z + 2, blink.losFlags) ~= 0 then
    return -1, 0, {}
  end

  local checksBetween = blink.round(9 * elapsed)

  local paths = {}
  for dir = 0, circ, circ / numChecks do
    local dx, dy, dz = blink.GroundZ(ux + dist * cos(dir), uy + dist * sin(dir), uz)
    if dx and dy and dz then
      local weighted = function(ax, ay, az, bx, by, bz)
        local extraWeight = 0
        return extraWeight
      end
      local path, pathType = GeneratePathWeighted(ux, uy, uz, dx, dy, dz, blink.mapID, weighted)
      if pathType == blink.PathTypes.PATHFIND_NORMAL then
        path = blink.cleanPath(path, checksBetween)
        paths[#paths + 1] = path
      end
    end
  end

  local losPoints = {}
  for i = 1, #paths do
    local p = paths[i]
    for k, path in pairs(p) do
      local d = blink.Distance(path.x, path.y, path.z, ux, uy, uz)
      if TraceLine(path.x, path.y, path.z + 2, x, y, z + 2, blink.losFlags) ~= 0 then
        losPoints[#losPoints + 1] = {path.x, path.y, path.z, d / unit.speed2}
      end
    end
  end

  table.sort(losPoints, function(x, y)
    return x[4] < y[4]
  end)

  local timeToLoS = 999
  local avgTimeToLoS = 999
  if #losPoints > 0 then
    timeToLoS = losPoints[1][4]
    local points = #losPoints
    local totalTime = 0
    for i = 1, #losPoints do
      totalTime = totalTime + losPoints[i][4]
    end
    avgTimeToLoS = totalTime / points
  end

  return timeToLoS, avgTimeToLoS, losPoints

end

if Tinkr.type == "daemonic" then
  blink.blinkLoSPoint = function(unit, maxDist, maxMovement, minTimeToLoS, alwaysClosest)

    if not unit or not unit.visible then
      return
    end
    local player = blink.player

    local x, y, z = unit.predictPosition(blink.buffer)
    local px, py, pz = player.predictPosition(blink.buffer)

    maxDist = maxDist or 100
    minTimeToLoS = minTimeToLoS or 0

    local checked = {}
    local valid = {}
    local circ = math.pi * 2
    local numChecks = 60

    -- actual # of connected fails is WRONG, but 0 seems always good to blink to
    for i = 0, circ, circ / numChecks do
      local ftx, fty, ftz = blink.GroundZ(px + 20 * cos(i), py + 20 * sin(i), pz)
      local bx, by, bz
      if ftx and fty and ftz then
        local zdif = abs(ftz - pz) / 2
        bx, by, bz = blink.GroundZ(px + (20 - zdif) * cos(i), py + (20 - zdif) * sin(i), pz)
      end
      checked[i] = {}
      checked[i].coords = {bx, by, bz}
      checked[i].surroundingFails = 0
      if bx and by and bz then
        local zdif = abs(bz - pz)
        -- TODO: with any significant zdif (player can blink on top of / over short objects like 1.5 yds)
        -- check climbing angle between each 1yd to (blink position - total combined zDif of all these checks towards the player)
        -- return 1-2 points before the climbing angle fails ( blinks into objects / pillars / unclimbable hills seem to end about 1-2 yd before the object )
        if zdif >= 3 then
          checked[i].valid = TraceLine(px, py, pz + 1.8, bx, by, bz + 1.8, blink.collisionFlags) == 0
        elseif TraceLine(px, py, pz + 1.8, bx, by, bz + 1.8, blink.collisionFlags) == 0 then
          checked[i].valid = true
        end
      end
    end

    for i = 0, circ, circ / numChecks do
      local outlierNeighbor = not checked[i + circ / numChecks] and checked[0] or not checked[i - circ / numChecks] and
                                checked[circ]
      local isValid = checked[i].valid
      if isValid then
        -- if valid, loop from current to end and current to start looking for neighboring fails
        for n = i + (circ / numChecks), circ, circ / numChecks do
          if checked[n] then
            if not checked[n].valid then
              checked[i].surroundingFails = checked[i].surroundingFails + 1
            else
              break
            end
          end
        end
        for n = i - (circ / numChecks), 0, -(circ / numChecks) do
          if checked[n] then
            if not checked[n].valid then
              checked[i].surroundingFails = checked[i].surroundingFails + 1
            else
              break
            end
          end
        end
        if outlierNeighbor and not outlierNeighbor.vlid then
          checked[i].surroundingFails = checked[i].surroundingFails + 1
        end
      else
        checked[i].surroundingFails = 69
      end
    end

    for i = 0, circ, circ / numChecks do
      local bx, by, bz
      if checked[i].coords then
        bx, by, bz = unpack(checked[i].coords)
      end
      if bx and by and bz and checked[i].surroundingFails <= 1 then
        local zdif = pz - bz
        if zdif < 3.5 and zdif > -3.5 then
          zdif = blink.round(math.abs(zdif))
          if TraceLine(bx, by, bz + 1.7, x, y, z + 1.7, blink.losFlags) == 0 then
            local dist = blink.Distance(x, y, z, bx, by, bz) - player.combatReach - unit.combatReach
            if dist < maxDist then
              table.insert(valid, {
                x = bx,
                y = by,
                z = bz,
                dist = dist,
                zdif = math.floor(zdif)
              })
            end
          end
        end
      end
    end

    table.sort(valid, function(x, y)
      return x.zdif < y.zdif or x.zdif == y.zdif and x.dist < y.dist
    end)

    -- _G.valid = valid
    -- _G.checked = checked

    if #valid > 0 then
      for _, point in ipairs(valid) do
        if point.x then
          return point.x, point.y, point.z
        end
      end
    end

  end
elseif Tinkr.Util.Draw then
  blink.blinkLoSPoint = function(unit, maxDist, maxMovement, minTimeToLoS, alwaysClosest)

    if not unit or not unit.visible then
      return
    end
    local player = blink.player

    local x, y, z = unit.predictPosition(blink.buffer)
    local px, py, pz = player.predictPosition(blink.buffer)

    maxDist = maxDist or 100
    minTimeToLoS = minTimeToLoS or 0

    local checked = {}
    local valid = {}
    local circ = math.pi * 2
    local numChecks = 24

    -- actual # of connected fails is WRONG, but 0 seems always good to blink to
    for i = 0, circ, circ / numChecks do
      local ftx, fty, ftz = blink.GroundZ(px + 20 * cos(i), py + 20 * sin(i), pz)
      local bx, by, bz
      if ftx and fty and ftz then
        local zdif = abs(ftz - pz) / 2
        bx, by, bz = blink.GroundZ(px + (20 - zdif) * cos(i), py + (20 - zdif) * sin(i), pz)
      end
      checked[i] = {}
      checked[i].coords = {bx, by, bz}
      checked[i].surroundingFails = 0
      if bx and by and bz then
        local zdif = abs(bz - pz)
        -- TODO: with any significant zdif (player can blink on top of / over short objects like 1.5 yds)
        -- check climbing angle between each 1yd to (blink position - total combined zDif of all these checks towards the player)
        -- return 1-2 points before the climbing angle fails ( blinks into objects / pillars / unclimbable hills seem to end about 1-2 yd before the object )
        if zdif >= 2.5 then
          checked[i].valid = TraceLine(px, py, pz + 1.8, bx, by, bz + 1.8, blink.collisionFlags) == 0
        elseif TraceLine(px, py, pz + 1.8, bx, by, bz + 1.8, blink.collisionFlags) == 0 then
          checked[i].valid = true
        end
      end
    end

    for i = 0, circ, circ / numChecks do
      local outlierNeighbor = not checked[i + circ / numChecks] and checked[0] or not checked[i - circ / numChecks] and
                                checked[circ]
      local isValid = checked[i].valid
      if isValid then
        -- if valid, loop from current to end and current to start looking for neighboring fails
        for n = i + (circ / numChecks), circ, circ / numChecks do
          if checked[n] then
            if not checked[n].valid then
              checked[i].surroundingFails = checked[i].surroundingFails + 1
            else
              break
            end
          end
        end
        for n = i - (circ / numChecks), 0, -(circ / numChecks) do
          if checked[n] then
            if not checked[n].valid then
              checked[i].surroundingFails = checked[i].surroundingFails + 1
            else
              break
            end
          end
        end
        if outlierNeighbor and not outlierNeighbor.vlid then
          checked[i].surroundingFails = checked[i].surroundingFails + 1
        end
      else
        checked[i].surroundingFails = 69
      end
    end

    blink.drawSheepComplex = {}

    for i = 0, circ, circ / numChecks do
      local bx, by, bz
      if checked[i].coords then
        bx, by, bz = unpack(checked[i].coords)
      end
      table.insert(blink.drawSheepComplex, {bx, by, bz, checked[i].surroundingFails})
      if bx and by and bz and checked[i].surroundingFails == 0 and checked[i].valid then
        local zdif = pz - bz

        if zdif < 1.75 and zdif > -1.75 or select(2, GeneratePath(px, py, pz, bx, by, bz, blink.mapID)) ==
          blink.PathTypes.PATHFIND_NORMAL then
          zdif = blink.round(math.abs(zdif))
          if TraceLine(bx, by, bz + 1.95, x, y, z + 1.95, blink.losFlags) == 0 then
            local dist = blink.Distance(x, y, z, bx, by, bz) - player.combatReach - unit.combatReach
            if dist < maxDist then
              local ttlos, avgttlos, losPoints = blink.fastestLoS(unit, bx, by, bz, maxMovement or 0.8)
              table.insert(valid, {
                x = bx,
                y = by,
                z = bz,
                dist = dist,
                zdif = math.floor(zdif),
                ttlos = ttlos,
                losPoints = losPoints
              })
            end
          end
        end
      end
    end

    if alwaysClosest then
      table.sort(valid, function(x, y)
        return x.dist < y.dist
      end)
    else
      table.sort(valid, function(x, y)
        return x.ttlos > y.ttlos or (x.ttlos == y.ttlos and x.zdif < y.zdif) or
                 (x.ttlos == y.ttlos and x.zdif == y.zdif and x.dist < y.dist)
      end)
    end

    if #valid > 0 then
      for _, point in ipairs(valid) do
        if point.ttlos >= minTimeToLoS then
          blink.losPoints = point.losPoints
          return point.x, point.y, point.z
        end
      end
    end

  end
end

blink.inverse = function(angle)
  return (angle + math.pi) % (2 * math.pi)
end
blink.inverseAngle = blink.inverse

blink.spellFlying = function(spellID, sourceUnit)
  sourceUnit = sourceUnit or blink.player
  local info = {
    count = 0
  }
  local isTable = type(spellID) == "table"
  for _, missile in ipairs(blink.missiles) do
    if unlockerType == "tinkr" and missile.source:guid() or missile.source then
      if isTable then
        for n = 1, #spellID do
          local spell = spellID[n]
          if missile.spellId == spell then
            if sourceUnit == "any" or UnitIsUnit(sourceUnit.pointer, missile.source) then
              info.count = info.count + 1
              if not tContains(info, missile.spellId) then
                table.insert(info, missile.spellId)
              end
            end
          end
        end
      elseif missile.spellId == spellID and (sourceUnit == "any" or UnitIsUnit(sourceUnit.pointer, missile.source)) then
        return true
      end
    end
  end
  return isTable and info or false
end

blink.GetSoulbindInfo = function()
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
  -- BA_Data["function LogTextLine"](string.format("covenant:[%s] - soulbind ID:[%d] - id:[%d] - covenantID:[%d] - name:[%s]",covenantName,soulbindID,id,covenantID,name));
  -- BA_Data["function LogTextLine"](string.format("nodes:-"));
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
      --[====[
	      BA_Data["function LogTextLine"](string.format("nodeid:[%s] - row:[%s] - col:[%s] - spellID:[%s] - conduitID:[%s] - conduitRank:[%s] - state:[%s][%s] - conduitType:[%s][%s]",
	          tostring(node_id),
	          tostring(node_row),
	          tostring(node_column),
	          tostring(node_spellID),
	          tostring(node_conduitID),
	          tostring(node_conduitRank),
	          tostring(node_state),
	          tostring(( node_state == 1 and "blank" or node_state == 3 and "used" or "unknown" )),
	          tostring(node_conduitType),
	          tostring(( node_conduitType == 1 and "Potency" or node_conduitType == 2 and "Endurance" or node_conduitType == 0 and "Finesse" or "Unknown"  ))
	        ));
	      --]====]

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
          spellName = node_spellName,
          rank = node_conduitRank
        }
      end
    end
  end
  for _, ve in pairs(activeConduitsSpells.conduits) do
    -- BA_Data["function LogTextLine"](string.format("spellID:[%d] - spellName:[%s]",ve.spellID,tostring(ve.spellName)));
  end
  -- BA_Data["function LogTextLine"](string.format("-- end nodes"));
  return activeConduitsSpells
end

blink.targetLastTarget = function()
  if not blink.target.exists then
    TargetLastTarget()
  end
end

local textureFrame = CreateFrame("frame")
local textureFrameTexture = textureFrame:CreateTexture("BlinkTextureFrame")

blink.GetSpellTexturePath = function(spellID)
  local textureID = GetSpellTexture(spellID)
  if textureID then
    textureFrameTexture:SetTexture(textureID)
    return textureFrameTexture:GetTexture()
  end
end

function blink.lr(input, current)

  local n = #input
  local a, b = 0, 0
  local Ex2, Ex, Exy, Ey = 0, 0, 0, 0

  for i = 1, n do
    local value = input[i]
    local x, y = value[1], value[2]

    Ex2 = Ex2 + x * x
    Ex = Ex + x
    Exy = Exy + x * y
    Ey = Ey + y
  end

  -- invariant to find matrix inverse
  local invariant = 1 / (Ex2 * n - Ex * Ex)

  -- solve for a and b
  a = (-Ex * Exy * invariant) + (Ex2 * Ey * invariant)
  b = (n * Exy * invariant) - (Ex * Ey * invariant)

  -- use best fit line to estimate b based on current a
  return (current - a) / b

end

blink.DistanceBetweenAngles = function(a1, a2, absReturn)
  local phi = abs(a1 - a2) % (math.pi * 2)
  local sign = 1
  if not ((a1 - a2 >= 0 and a1 - a2 <= math.pi) or (a1 - a2 <= math.pi and a1 - a2 >= math.pi * 2)) then
    sign = -1
  end
  local result = phi > math.pi and math.pi * 2 - phi or phi
  return absReturn and abs(result * sign) or result * sign
end
blink.angleDist = blink.DistanceBetweenAngles
blink.angleDiff = blink.DistanceBetweenAngles

local tremove = tremove
blink.tremoveValue = function(table, value)
  if #table > 0 then
    for i = #table, 1, -1 do
      if table[i] == value then
        tremove(table, i)
      end
    end
  else
    for k, v in pairs(table) do
      if v == value then
        table[k] = nil
      end
    end
  end
end

local abs, pi, rad, sqrt = math.abs, math.pi, rad, math.sqrt

blink.rotate = function(deg, deg2, isDeg)
  local max = isDeg and 360 or pi * 2
  local orientation = (deg + deg2) % max
  if orientation < 0 then
    orientation = orientation + max
  end
  return orientation
end

local posFromPos = function(x, y, z, dist, angle)
  return cos(angle) * dist + x, sin(angle) * dist + y, z
end
blink.posFromPos = posFromPos

blink.getRect = function(width, length, x, y, z, offset, angle, rot)
  rot = rot or 0
  rot = rot * pi / 180
  offset = offset or 0
  width = width or 3
  length = length or 30
  angle = angle + offset

  x = x + offset * cos(angle)
  y = y + offset * sin(angle)

  local halfWidth = width / 2

  -- Near Left, Near Right
  local nlX, nlY, nlZ = posFromPos(x, y, z, halfWidth, angle + rad(90))
  local nrX, nrY, nrZ = posFromPos(x, y, z, halfWidth, angle + rad(270))
  -- Far Left, Far Right
  local flX, flY, flZ = posFromPos(nlX, nlY, nlZ, length, angle)
  local frX, frY, frZ = posFromPos(nrX, nrY, nrZ, length, angle)

  return nlX, nlY, nrX, nrY, frX, frY, flX, flY, flZ, nlZ, nrZ, frZ
end

local function isInside(x, y, ax, ay, bx, by, dx, dy)
  local bax = bx - ax
  local bay = by - ay
  local dax = dx - ax
  local day = dy - ay
  if ((x - ax) * bax + (y - ay) * bay <= 0.0) then
    return false
  end
  if ((x - bx) * bax + (y - by) * bay >= 0.0) then
    return false
  end
  if ((x - ax) * dax + (y - ay) * day <= 0.0) then
    return false
  end
  if ((x - dx) * dax + (y - dy) * day >= 0.0) then
    return false
  end
  return true
end

blink.insideRect = function(x1, y1, z1, x2, y2, z2, w, l, a)
  local nlX, nlY, nrX, nrY, frX, frY, flX, flY, flZ, nlZ, nrZ, frZ = blink.getRect(w, l, x1, y1, z1, 0, a)
  -- return x2 >= nlX and x2 <= nrX and y2 >= nlY and y2 <= nrY and abs(z2 - nlZ) < 8 and abs(z2 - nrZ) < 8
  return isInside(x2, y2, nlX, nlY, nrX, nrY, frX, frY) and abs(z2 - nlZ) < 8 and abs(z2 - nrZ) < 8
end
blink.inRect = blink.insideRect

-- function Draw:Arc(x, y, z, size, arc, rotation)
-- 	local lx, ly, nx, ny, fx, fy = false, false, false, false, false, false
-- 	local half_arc = arc * 0.5
-- 	local ss = (arc/half_arc)
-- 	local as, ae = -half_arc, half_arc
-- 	for v = as, ae, ss do
-- 			nx, ny = WorldToScreen( (x+cos(rotation+rad(v))*size), (y+sin(rotation+rad(v))*size), z )
-- 			if lx and ly then
-- 					self:Draw2DLine(lx, ly, nx, ny)
-- 			else
-- 					fx, fy = nx, ny
-- 			end
-- 			lx, ly = nx, ny
-- 	end
-- 	local px, py = WorldToScreen(x, y, z)
-- 	self:Draw2DLine(px, py, lx, ly)
-- 	self:Draw2DLine(px, py, fx, fy)
-- end

local function insideEdge(x, y, x1, y1, x2, y2)
  return (x2 - x1) * (y - y1) - (x - x1) * (y2 - y1) > 0
end
blink.insideEdge = insideEdge

blink.insideArc = function(x1, y1, z1, x2, y2, z2, size, arc, rotation)

  -- excess zdiff
  if abs(z1 - z2) > 8 then
    return false
  end

  -- out of circ range
  local dist = sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
  if dist > size then
    return false
  end

  local angleToUnit = blink.AnglesBetween(x1, y1, z1, x2, y2, z2)
  local angleDifference = rotation > angleToUnit and rotation - angleToUnit or angleToUnit - rotation
  local shortestAngle = angleDifference < pi and angleDifference or pi * 2 - angleDifference
  local finalAngle = shortestAngle / (pi / 180)

  return finalAngle < arc / 2

end
blink.inArc = blink.insideArc

blink.realHeight = function(height)
  if not height then
    return 2.1
  end
  -- female nelf
  if abs(height - 2.3418750762939) < 0.001 then
    return 2.1
  end
  -- female human
  if abs(height - 1.9705199) < 0.001 then
    return 1.76
  end
  -- male orc
  if abs(height - 2.6868102) < 0.001 then
    return 2.16
  end
  -- ? female belf i think.,
  if abs(height - 2.0803637) < 0.001 then
    return 1.78
  end
  -- female orc
  if abs(height - 2.29155874) < 0.001 then
    return 1.89
  end
  -- male belf
  if abs(height - 2.2013103) < 0.001 then
    return 1.93
  end
  -- female panda
  if abs(height - 2.4887793) < 0.001 then
    return 1.99
  end
  -- male pan
  if abs(height - 2.7480869) < 0.001 then
    return 2.14
  end
end

blink.round = function(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

blink.fighting = function(classOrSpec, all)
  if blink.arena and WOW_PROJECT_ID == 1 then
    if type(classOrSpec) == "table" then
      local fightingAll = true
      for _, given in pairs(classOrSpec) do
        local found = false
        for i = 1, GetNumArenaOpponents() do
          local spec = GetArenaOpponentSpec(i)
          if spec then
            local specName, _, _, classNameLiteral, className = select(2, GetSpecializationInfoByID(spec))
            if given == className or given == specName or given == classNameLiteral or given == spec then
              return true
            end
          end
        end
        if not found then
          fightingAll = false
        elseif not all then
          return true
        end
      end
      return fightingAll
    else
      for i = 1, GetNumArenaOpponents() do
        local spec = GetArenaOpponentSpec(i)
        if spec then
          local specName, _, _, classNameLiteral, className = select(2, GetSpecializationInfoByID(spec))
          if classOrSpec == className or classOrSpec == specName or classOrSpec == classNameLiteral or classOrSpec ==
            spec then
            return true
          end
        end
      end
    end
  else
    if type(classOrSpec) == "table" then
      blink.enemies.loop(function(enemy)
        local class = enemy.class2
        for _, given in pairs(classOrSpec) do
          if given == class then
            return true
          end
        end
      end)
    else
      local yup = false
      blink.enemies.loop(function(enemy)
        if enemy.class2 == classOrSpec then
          yup = true
          return true
        end
      end)
      return yup
    end
  end
end

function blink.extend(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
end

function blink.call(func, ...)

  if type(func) ~= "string" then
    return blink.print("blink.call: func must be a string")
  end

  local args = {...}
  local objectPassed

  local oldNPC, didNPC
  if unlockerType == "tinkr" then
    for i = 1, #args do
      if type(args[i]) == "userdata" then
        didNPC = true
        oldNPC = Object("npc")
        SetNPCObject(args[i])
        args[i] = "npc"
        break
      end
    end
  elseif unlockerType == "noname" then
    for i = 1, #args do
      if type(args[i]) == "number" then
        if args[i] > 10000000 or args[i] < -10000000 then
          objectPassed = true
          break
        end
      end
    end
  end

  local res

  if unlockerType == "tinkr" then
    res = {Evaluator:CallProtectedFunction(func, unpack(args))}
  elseif unlockerType == "daemonic" then
    res = {SecureCode(func, unpack(args))}
  elseif unlockerType == "noname" then
    res = {Unlock(func, unpack(args))}--objectPassed and {UnlockObject(func, unpack(args))} or {Unlock(func, unpack(args))}
  end

  if oldNPC then
    SetNPCObject(oldNPC)
  elseif didNPC then
    ClearNPCObject()
  end

  if not res then
    return blink.print("blink.call: failed to call " .. func)
  end

  return unpack(res)

end
blink.callProtectedFunction = blink.unlock
blink.callProtectedApi = blink.unlock
blink.callProtected = blink.unlock

blink.unlock = function(func)
  if type(func) ~= "string" then
    return blink.print("blink.unlock: func must be a string")
  end

  local f = function(...)
    return blink.call(func, ...)
  end

  return f
end

blink.AntiAFK = setmetatable({
  enabled = false
}, {
  __call = function(self, enabled)
    if enabled == nil then
      self.enabled = not self.enabled
    else
      self.enabled = enabled
    end
    blink.print("Anti-AFK " .. (self.enabled and "Enabled" or "Disabled"))
  end
})

function blink.AntiAFK:Toggle()
  self()
end

function blink.AntiAFK:Enable()
  self(true)
end

function blink.AntiAFK:Disable()
  self(false)
end

local ticker = {
  min = 29.55, -- min time (sec) to reset hardware action
  max = 84.62 -- max time (sec) to reset hardware action
}

local function perpetalHardwareActionReset()
  C_Timer.After(math.random(ticker.min * 1000, ticker.max * 1000) / 1000, function()
    -- reset hardware action (if enabled)
    if blink.AntiAFK.enabled then
      if unlockerType == "tinkr" then
        SetLastHardwareActionTime(GetGameTick())
      elseif unlockerType == "noname" then
        LastHardwareAction(GetTime() * 1000)
      elseif unlockerType == "daemonic" then
        ResetAfk()
      end
    end
    -- reset ticker
    perpetalHardwareActionReset()
  end)
end
perpetalHardwareActionReset()

function blink.dispelType(id)
  if unlockerType == "tinkr" then
    local dispelName, dispelID = GetSpellDispelType(id)
    return dispelName, dispelID
  elseif unlockerType == "daemonic" then
    local dispelName, dispelID = GetSpellDispelType(id)
    return dispelName, dispelID
  end
end

blink.WriteFile = WriteFile
blink.ReadFile = ReadFile

local seed = blink.__seed or math.random(1, 2000)
local seed_mod = seed / 2000
blink.__seed__mod = seed_mod

local function seed_range(min, max)
  return min + (max - min) * seed_mod
end

function blink.delay(min, max, frequency)

  local mod = seed_range(0.9, 1.25)
  min = min * mod
  max = max * mod

  -- typical expected args = 0.1, 0.5
  -- we want a random value between those decimals
  local delay = {
    now = math.random() * (max - min) + min,
  }

  frequency = frequency or 1.5
  C_Timer.NewTicker(frequency, function()
    delay.now = math.random() * (max - min) + min
  end)

  return delay
end

blink.delays = {
  short = blink.delay(0.1, 0.5),
  srDelay = blink.delay(0.5, 0.8),
  medium = blink.delay(0.5, 1.5),
  long = blink.delay(1.5, 3),
  xl = blink.delay(3, 5),
  xxl = blink.delay(5, 10),
  xxxl = blink.delay(10, 15),
}

function blink.animationFlags(obj)
  if not obj then return end

  if Unlocker.type == "daemonic" then
    local animationFlags = UnitAnimationFlags(obj.pointer)
    if animationFlags then
      return animationFlags
    end
  elseif Unlocker.type == "noname" then
    local animationFlags = ObjectFlags(obj.pointer)
    if animationFlags then
      return animationFlags
    end
  else
      local _, animationFlags = ObjectFlags(obj.pointer)
      if animationFlags then
        return animationFlags
      end
  end
end

function blink.listen(key, callback, duration)

  local optionalOnTick = {
    OnTick = function(self, cb)
      self.callback = cb
    end,
  }

  local ticker = C_Timer.NewTicker(0.1, function(self)
    if IsKeyDown(key) then
      callback(self)
    elseif optionalOnTick.callback then
      optionalOnTick.callback(self)
    end
  end)

  if duration then
    C_Timer.After(duration, function()
      ticker:Cancel()
    end)
  end

  return optionalOnTick
end