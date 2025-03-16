local Unlocker, blink, sr = ...
local bin, angles, min, max, cos, sin, inverse, sort = blink.bin, blink.AnglesBetween, min, max, math.cos, math.sin, blink.inverseAngle, table.sort
local shaman, ele = sr.shaman, sr.shaman.ele
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local arena1, arena2, arena3 = blink.arena1, blink.arena2, blink.arena3
local NS, events, cmd, colors, colored = blink.Spell, blink.events, sr.cmd, blink.colors, blink.colored
local UnlockerType = Unlocker.type
local onEvent, onUpdate = blink.addEventCallback, blink.addUpdateCallback
local state = sr.arenaState
local saved = sr.saved
local alert = blink.alert
local fhealer = blink.healer
local currentSpec = GetSpecialization()  

if not shaman.ready then return end
if not currentSpec == 1 or not currentSpec == 3 then return end

--reload when spec changed
blink.addEventCallback(function() blink.call("ReloadUI")
end, "ACTIVE_PLAYER_SPECIALIZATION_CHANGED")

shaman.print = function(str)
  print(colors.shaman .. "|cFFf7f25c[SadRotations]:|r " .. str)
end

shaman.print(colors.shaman .. "Core |cFFf7f25cLoaded")


blink.ttd_enabled = true

local burrow = NS(409293, { ignoreFacing = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true })
local grounding = NS(204336, { ignoreLoS = true, ignoreFacing = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true })
local totemicProjection = NS(108287,{ ignoreFacing = true, diameter = 2 })
local staticField = NS(355580, { effect = "magic", ignoreFacing = true, diameter = 6 })
local lasso = NS(305483, { damage = "magic", stun = true })
blink.RegisterMacro('cap test', 5)
--Macros
blink.RegisterMacro('burst', 5)
blink.RegisterMacro('pause', 1)
blink.RegisterMacro('pause 1', 1)
blink.RegisterMacro('pause 2', 2)
blink.RegisterMacro('pause 3', 3)
blink.RegisterMacro('pause 4', 4)
blink.RegisterMacro('pause 5', 5)
blink.RegisterMacro("wolf toggle", 1)

--lasso
blink.RegisterMacro('lasso target', 1.5)
blink.RegisterMacro('lasso focus', 1.5)
blink.RegisterMacro('lasso arena1', 1.5)
blink.RegisterMacro('lasso arena2', 1.5)
blink.RegisterMacro('lasso arena3', 1.5)
blink.RegisterMacro('lasso enemyhealer', 1.5)

--Hex
blink.RegisterMacro("hex target", 1.5)
blink.RegisterMacro("hex focus", 1.5)
blink.RegisterMacro("hex arena1", 1.5)
blink.RegisterMacro("hex arena2", 1.5)
blink.RegisterMacro("hex arena3", 1.5)

shaman.movePetToUnit = function(unit)

  --if Unlocker.type == "daemonic" then return end
  if SpellIsTargeting() then return end
  -- player must be within 60y to move pet to position?
  if player.distanceToLiteral(unit) > 60 then
    -- alert("Unable to move pet, too far")
    return false
  end

  local x,y,z = unit.position()

  PetMoveTo()
  Click(x,y,z)
  --blink.alert("Move pet to position")
end

local ImmuneToLasso = {

	213610, --Holy Ward
	-- 236321, --War Banner
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  203337, --dimoand ice
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  353319, --monk retoral
  408558, --priest phase shift
  377362, --prec
  8178,   --grounding
  212295, --netherwalk
  354610, --dh Glimpse
  
}

local ThingsToGround = {
  [187650] = function(spellID)
    return blink.missiles.find(function(obj) if obj.source.enemy and obj.spellId and obj.spellId == spellID then return true end end)
  end, -- Freezing Trap
}

local grounds = {

  -- eruption
  [395160] = function(source)
    return sr.lowest(blink.fgroup) <= 50 + bin(not healer.exists or not healer.los or healer.cc) * 20
  end,
  -- repentance
  [20066] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,
  -- mindgames
  [375901] = function() 
    return true 
  end,
  -- glacial
  [199786] = function() 
    return sr.lowest(blink.fgroup) <= 85
  end,
  -- clone
  [33786] = function(source)
    return (source.castTarget.isUnit(player) and player.ddr >= 0.5) or (source.castTarget.isUnit(healer) and healer.ddr >= 0.5)
  end,
  -- fear
  [5782] = function(source)
    return (source.castTarget.isUnit(player) and player.ddr >= 0.5) or (source.castTarget.isUnit(healer) and healer.ddr >= 0.5)
  end,
  -- chaos bolt
  [116858] = function(source)
    return source.cds or sr.lowest(blink.fgroup) <= 85
  end,
  -- sleep walk
  [5782] = function(source)
    return (source.castTarget.isUnit(player) and player.disorientDR >= 0.5) or (source.castTarget.isUnit(healer) and healer.disorientDR >= 0.5)
  end,
  -- hex ( start of hexes )
  [277784] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,
  [309328] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [269352] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [289419] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [211004] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [51514] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [210873] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [211015] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [219215] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [277778] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [17172] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [66054] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [11641] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [271930] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [270492] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [18503] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,

  [289419] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end,
  --end of hexes
}

-- sheeps
for _, sheep in ipairs(blink.spells.sheeps) do 
  grounds[sheep] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5)
  end
end



shaman.timeHoldingGCD = 0
shaman.timeHoldingGCDStart = 0

local lastTimeCounted = 0
local currentTime = GetTime()

-- function shaman:HoldGCDForBurrow()

--   -- burrow not ready :P
--   if not blink.actor.burrow or not blink.actor.burrow.known or blink.actor.burrow.cd - blink.gcdRemains > 0 then return false end
--   -- -- already held max gcds
--   if currentTime > (lastTimeCounted + 2) then lastTimeCounted = GetTime() return end
--   --print(self.timeHoldingGCD > blink.time + 10)
--   --we are higher that the set HP
--   if player.hp > saved.burrowSlider + 15 then return end

--   if player.hp <= saved.burrowSlider + 15 then 
--     return true
--   end

-- end

function shaman:HoldGCDForBurrow()
  local currentTime = GetTime()

  -- Check if the burrow spell is ready
  if not blink.actor.burrow or not blink.actor.burrow.known or blink.actor.burrow.cd - blink.gcdRemains > 0 then 
    self.timeHoldingGCDStart = nil -- Ensure timer is reset if spell isn't ready
    return false
  end

  -- Check if we've been holding the GCD for 2 seconds or more
  if self.timeHoldingGCDStart and (currentTime - self.timeHoldingGCDStart >= 2) then 
    self.timeHoldingGCDStart = nil -- Reset the timer
    return false
  end

  -- Check player's HP against the slider setting
  if player.hp > saved.burrowSlider + 10 then 
    self.timeHoldingGCDStart = nil -- Reset the timer if HP is above the threshold
    return false
  end

  -- Start or continue holding the GCD
  if not self.timeHoldingGCDStart then
    self.timeHoldingGCDStart = currentTime -- Start the timer if not already started
  end
  return true -- Continue holding GCD and triggering the alert
end


-- add holding GCD for that shit 
burrow:Callback("Slider", function(spell)
  if not player.hasTalent(spell.id) then return end

  if player.buff(199448) 
  or player.buff(47788) 
  or player.buff(116849)
  and saved.dontDefOvelap then 
    return 
  end

  if player.hp > saved.burrowSlider then return end
  if not player.combat then return end
  
  if not C_Spell.IsCurrentSpell(409293) then   
    blink.call("SpellCancelQueuedSpell")
  end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  end
  
  if spell:Cast() then
    alert("Burrow", spell.id, true)
  end

end)

-- Constants
local MAX_GCD_HOLD_TIME = 3
local MAX_STUN_REMAINS = 3.5
local MAX_DISTANCE = 34
local MAX_COOLDOWN = 1
local FREEZING_TRAP_SPELL_ID = 187650
local MIN_CAST_PCT = 10
local groundTimeHoldingGCD = 0
local groundTimeHoldingGCDStart = 0

local function couldKnowSpell(obj, id, reasonableTime)
  reasonableTime = reasonableTime or 30
  local elapsed = state.elapsedCombat

  if obj.used(id, elapsed + 69) then return true end
  if elapsed > reasonableTime then return false end
  return true
end

local heHasTheSpell = function(obj)
  local has = function(id)
    sr.debugPrint("Checking if obj has spell with ID: " .. id)
    local isAvailable = obj.exists and obj.cooldown(id) <= 0
    sr.debugPrint("Is spell available: " .. tostring(isAvailable))
    return isAvailable
  end
  local knows = function(id, t)
    sr.debugPrint("Checking if obj knows spell with ID: " .. id)
    return couldKnowSpell(obj, id, t)
  end

  if obj.class2 == "HUNTER" then
    sr.debugPrint("Obj is a HUNTER")
    local knowsSpell = knows(187650)
    local hasSpell = has(187650)
    sr.debugPrint("Knows spell: " .. tostring(knowsSpell))
    sr.debugPrint("Has spell: " .. tostring(hasSpell))
    return knowsSpell and hasSpell
  end
  sr.debugPrint("Obj is not a HUNTER")
  return false
end

function sr.shouldGroundTrap()

  if not saved.groundTraps then return false end

  if blink.fighting("HUNTER") then
    local aboutToTrap = false
    blink.enemies.loop(function(enemy)
      if enemy.class2 == "HUNTER" 
      and heHasTheSpell(enemy)
      and healer.stunned 
      and healer.stunRemains < MAX_STUN_REMAINS
      and player.distanceToLiteral(healer) <= MAX_DISTANCE
      and enemy.cooldown(FREEZING_TRAP_SPELL_ID) <= MAX_COOLDOWN then
        aboutToTrap = true
        alert("Holding GCD To Groudning [" .. colored("Freezing Trap", colors.hunter) .. "]", grounding.id)
      end
    end)
    
  end
  
  if aboutToTrap then return true end
end

function sr.shouldGroundCast()
  if not player.hasTalent(204336) then return false end
  if not saved.autoGrounding then return false end
  local getThatCast = false  
  blink.enemies.loop(function(enemy)
    if enemy.casting
    and tContains(grounds, enemy.castID) 
    and enemy.castPct >= MIN_CAST_PCT
    and not actor.windShear:Castable(enemy)
    and not sr.NoNeedToKickThis(enemy) then
      getThatCast = true
      alert("Holding GCD To " .. "|cFFf7f25c[Ground Enemy Cast]", grounding.id)
    end
  end)

  if getThatCast then return true end
end

function sr.holdGCDForGround()
  if not player.hasTalent(204336) then return false end
  if not saved.autoGrounding then return false end
  if not blink.actor.grounding.known or blink.actor.grounding.cd - blink.gcdRemains > 0 then return false end

  if currentTime > (groundTimeHoldingGCDStart + MAX_GCD_HOLD_TIME) then 
    groundTimeHoldingGCDStart = GetTime() 
    return 
  end

  if sr.shouldGroundTrap() or sr.shouldGroundCast() then 
    return true 
  end
end

grounding:Callback("trap", function(spell)

  if not saved.autoGrounding then return end
  if not saved.groundTraps then return end
  if not blink.arena then return end

  for _, missile in ipairs(blink.missiles) do

    if not missile then return end
    if not missile.spellId then return end

    if missile.spellId == 187650 then

      local missilecreator = blink.GetObjectWithGUID(missile.source)
      if missilecreator.friend then return end

      local hitDistanceToHealer = healer.distanceTo(missile.hx, missile.hy, missile.hz)
      local hitDistanceToPlayer = player.distanceTo(missile.hx, missile.hy, missile.hz)
      local currentDistanceToHealer = healer.distanceTo(missile.cx, missile.cy, missile.cz)
      local currentDistanceToPlayer = player.distanceTo(missile.cx, missile.cy, missile.cz)
      
      sr.debugPrint("Hit Distance to Healer: ", hitDistanceToHealer)
      sr.debugPrint("Current Distance to Healer: ", currentDistanceToHealer)
      --sr.debugPrint("Hit Distance to Player: ", hitDistanceToPlayer)
      --sr.debugPrint("Current Distance to Player: ", currentDistanceToPlayer)

      if (hitDistanceToHealer < 34) 
      and (currentDistanceToHealer < 34) then

        sr.debugPrint("Condition met! Performing action...")

        if player.casting or player.channeling then 
          blink.call("SpellStopCasting")
          blink.call("SpellStopCasting")
        end
  
        if spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) then
          alert("Grounding [" .. colored("Freezing Trap ", colors.hunter) .. "]", spell.id)
        end

      else
        sr.debugPrint("Condition not met.")
      end
    end
  end
end)


grounding:Callback("grip", function(spell)
  if not saved.autoGrounding then return end
  if not saved.groundTraps then return end
  if not blink.arena then return end
  if healer.exists
  and healer.debuffFrom({190925, 212331, 212353})
  and player.distanceToLiteral(healer) <= 34 then

    if player.casting or player.channeling then 
      blink.call("SpellStopCasting")
      blink.call("SpellStopCasting")
    end

    if spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) then
      alert("Groudning [" .. colored("Freezing Trap", colors.hunter) .. "]", spell.id, true)
    end
  end
end)

grounding:Callback("playerTrap", function(spell)

  if not saved.autoGrounding then return end
  if not saved.groundTraps then return end
  if not blink.arena then return end

  for _, missile in ipairs(blink.missiles) do

    if not missile then return end
    if not missile.spellId then return end

    if missile.spellId == 187650 then

      local missilecreator = blink.GetObjectWithGUID(missile.source)
      if missilecreator.friend then return end

      local hitDistanceToHealer = healer.distanceTo(missile.hx, missile.hy, missile.hz)
      local hitDistanceToPlayer = player.distanceTo(missile.hx, missile.hy, missile.hz)
      local currentDistanceToHealer = healer.distanceTo(missile.cx, missile.cy, missile.cz)
      local currentDistanceToPlayer = player.distanceTo(missile.cx, missile.cy, missile.cz)
      
      sr.debugPrint("Hit Distance to Healer: ", hitDistanceToHealer)
      sr.debugPrint("Current Distance to Healer: ", currentDistanceToHealer)
      --sr.debugPrint("Hit Distance to Player: ", hitDistanceToPlayer)
      --sr.debugPrint("Current Distance to Player: ", currentDistanceToPlayer)

      if hitDistanceToPlayer < 34 then

        sr.debugPrint("Condition met! Performing action...")

        if player.casting or player.channeling then 
          blink.call("SpellStopCasting")
          blink.call("SpellStopCasting")
        end
  
        if spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) then
          alert("Grounding [" .. colored("Freezing Trap ", colors.hunter) .. "]", spell.id)
        end

      else
        sr.debugPrint("Condition not met.")
      end
    end
  end
end)

grounding:Callback("playerGrip", function(spell)
  if not saved.autoGrounding then return end
  if not saved.groundTraps then return end
  if not blink.arena then return end
  if player.debuffFrom({190925, 212331, 212353}) then

    if player.casting or player.channeling then 
      blink.call("SpellStopCasting")
      blink.call("SpellStopCasting")
    end

    if spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) then
      alert("Groudning [" .. colored("Freezing Trap", colors.hunter) .. "]", spell.id, true)
    end
  end
end)
-- grounds: 
--[[
  some pre-hoj grounds?
]]
local function shouldGround(castRemains)
  local buffer = math.random(50, 70) / 100 + blink.buffer
  return castRemains and castRemains <= buffer + 0.2
end

grounding:Callback(function(spell)
  if not saved.autoGrounding or not player.hasTalent(204336) then return end

  local function shouldCastGrounding(enemy, buffId, buffDuration)
    local buffRemains = enemy.buffRemains(buffId)
    return enemy.buff(buffId) and enemy.distanceLiteral <= 34 and buffRemains >= buffDuration
  end

  local enemyToCast = blink.enemies.within(spell.range).find(function(enemy)
    if not enemy.exists or enemy.distanceLiteral > 34 then return false end

    -- Check specific buffs
    if (blink.fighting(256) and shouldCastGrounding(enemy, 421453, 3)) or
      (blink.fighting(63) and shouldCastGrounding(enemy, 190319, 5)) or
      (blink.fighting(62) and shouldCastGrounding(enemy, 365362, 3)) or
      (blink.fighting(262) and (shouldCastGrounding(enemy, 375986, 3) or shouldCastGrounding(enemy, 114050, 3))) or
      (blink.fighting(102) and enemy.buff(202425)) then
      return true
    end

    -- Check if wind shear is castable
    if sr.shaman.ele.windShear:Castable(enemy) then return false end

    -- Check for cast
    local cast = enemy.castID
    if cast and grounds[cast] and grounds[cast](enemy) and shouldGround(enemy.castRemains) then
      return true
    end

    return false
  end)

  if enemyToCast then
    if not C_Spell.IsCurrentSpell(204336) then
      blink.call("SpellCancelQueuedSpell")
    end

    if player.casting or player.channeling then
      blink.call("SpellStopCasting")
      blink.call("SpellStopCasting")
    end

    return spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) and alert("Grounding Totem " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(enemyToCast.castID).name .. "|cFFf7f25c]", spell.id, true)
  end
end)


-- grounding:Callback(function(spell)
--   if not saved.autoGrounding then return end
--   if not player.hasTalent(204336) then return end

--   enemies.loop(function(enemy)

--     --mage combust
--     if blink.fighting(63) then
--       if enemy.buff(190319) 
--       and enemy.distanceLiteral <= 34
--       and enemy.buffRemains(190319) >= 5 then

--         return spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) and alert("Grounding Totem |cFFff8336[Combustion]", spell.id,true)

--       end
--     end

--     --ele Primordial Wave
--     if blink.fighting(262) then
--       if enemy.buff(375986) 
--       and enemy.distanceLiteral <= 34
--       and enemy.buffRemains(375986) >= 3 then

--         return spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) and alert("Grounding Totem |cFFff8336[Primordial Wave]", spell.id,true)

--       end
--     end

--     --if actor.windShear.cd == 0 and enemy.dist <= actor.windShear.range and enemy.los and enemy.castint == false or windShear:Castable(enemy) then return end
--     if actor.windShear:Castable(enemy) then return end
--     if actor.windShear.current then return end

--     local cast = enemy.castID
--     if not cast then return end
--     if not grounds[cast] or not grounds[cast](enemy) then return end
--     if enemy.distanceLiteral > 34 then return end

--     if (enemy.castRemains < (math.random(50,80)/100) + blink.buffer) then

--       if not C_Spell.IsCurrentSpell(204336) then   
--         blink.call("SpellCancelQueuedSpell")
--       end

--       if player.casting or player.channeling then 
--         blink.call("SpellStopCasting")
--         blink.call("SpellStopCasting")
--       end

--       return spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) and alert("Grounding Totem " .. "|cFFf7f25c[" .. GetSpellInfo(cast) .. "|cFFf7f25c]", spell.id, true)

--     end
--   end)
-- end)


local function WeCanStun(unit)

  if unit.exists 
  and unit.buffsFrom(ImmuneToLasso) == 0 
  and unit.stunDR >= 0.5 
  and unit.ccRemains < 1
  and unit.los
  and unit.enemy
  and not unit.immuneMagicDamage 
  and not unit.immuneStuns then 

    return true

  else

    local errorMessage = "|cFFf7f25c[Check]: |cFFf74a4a"

    if not unit.exists then
      blink.alert(errorMessage .. "Unit doesn't exist!", lasso.id) 
    elseif (unit.immuneStuns or unit.immuneMagicDamage or unit.distance > 20 or unit.buffsFrom(ImmuneToLasso) > 0) then
      blink.alert(errorMessage .. "Can't Lightning Lasso! [" .. (unit.classString or "") .. "]", lasso.id)    
    elseif unit.stunDR < 0.5 then
      blink.alert(errorMessage .. "Waiting DR To use Lightning Lasso on [" .. (unit.classString or "") .. "]", lasso.id)	  
    end

  end		
end


-- on-damage events!
onEvent(function(info, event, source, dest)

  local time = GetTime()
  if event ~= "SPELL_CAST_SUCCESS" then return end
  if not source.enemy then return end

  local spellID, spellName = select(12, unpack(info))
  local events = blink.events
  local happened = event.time

  --some checks tho 
  if not blink.enabled then return end
  if player.stealth then return end
  if player.mounted then return end
  if (source.stunDR < 0.5 or source.stunned or source.immuneMagicDamage or source.immuneStuns) then return end
  if source.dist > 20 then return end
  if lasso.cd - blink.gcdRemains > 0 then return end

  -- FD the hunt
  if spellID == 370965
  and dest.isUnit(player)
  and source.speed > 45 
  and saved.autoLassoCDs then 
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("The Hunt", colors.dh) .. ")", lasso.id)
    end
  end
  
  -- Lightning Lasso Mark for death 
  if spellID == 137619 
  and saved.autoLassoCDs
  and dest.isUnit(player) 
  and source.enemy then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Mark for Death", colors.rogue) .. ")", lasso.id)
    end
  end        

  -- Flagellation Rush on player
  if spellID == 323654 
  and saved.autoLassoCDs
  and dest.isUnit(player) then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Flagellation", colors.rogue) .. ")", lasso.id)
    end
  end 

  -- Vendetta/deathmark on player
  if spellID == 360194 
  or spellID == 79140 
  and saved.autoLassoCDs then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Deathmark", colors.rogue) .. ")", lasso.id)
    end
  end         
  
  -----------Lasso Gap Closers-----------------

  -- Warrior Charge.
  if spellID == 100 
  and saved.autoLassoGapCloser
  and player.target.isUnit(source) then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Charge", colors.warrior) .. ")", lasso.id)
    end
  end

  --warrior leap
  if spellID == 6544 
  and saved.autoLassoGapCloser
  and source.enemy 
  and player.target.isUnit(source) then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Heroic Leap", colors.warrior) .. ")", lasso.id)
    end
  end

  -- DH Fel rush.
  if spellID == 195072 
  and saved.autoLassoGapCloser
  and player.target.isUnit(source) then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Fel Rush", colors.dh) .. ")", lasso.id)
    end
  end

  --rogue Shadowstep
  if spellID == 36554 
  and saved.autoLassoGapCloser
  and source.enemy 
  and player.target.isUnit(source) then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Shadow Step", colors.rogue) .. ")", lasso.id)
    end
  end

  --feral charge
  if spellID == 49376 
  and saved.autoLassoGapCloser
  and source.enemy 
  and player.target.isUnit(source)
  and not source.isHealer then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Wild Charge", colors.druid) .. ")", lasso.id)
    end
  end

  --monk roll
  if spellID == 49376 
  and saved.autoLassoGapCloser
  and source.enemy 
  and player.target.isUnit(source)
  and not source.isHealer then
    if lasso:Cast(source, {face = true}) then
      return blink.alert("Lightning Lasso (" .. colored("Roll", colors.monk) .. ")", lasso.id)
    end
  end

  -----------end of Lasso Gap Closers-----------------


end)


local lassoMePls = {
  --Incarnation Ashame - Feral
  [102543] = function(source)
    return source.role == "melee"
  end,
  --Incarnation Chosen - Boomkin
  [102560] = function(source)
    return source.role == "ranged"
  end,
  --wings
  [31884] = function(source)
    return source.role == "melee" and not source.disarmed
  end,
  --wings
  [231895] = function(source)
    return source.role == "melee" and not source.disarmed
  end,
  --doomwinds
  [384352] = function(source)
    return source.class2 == "SHAMAN" and source.role == "melee" and not source.disarmed
  end,
  --bloodlust
  [204361] = function(source)
    return not source.isHealer
  end,
  --hero
  [204362] = function(source)
    return not source.isHealer
  end,
  --Serenity
  [152173] = function(source)
    return source.role == "melee" and not source.disarmed
  end,
  --boondust
  [386276] = function(source)
    return source.role == "melee" and not source.disarmed
  end,
  --trueshot
  [288613] = function(source)
    return not source.disarmed
  end,
  --Coordinated Assault
  [266779] = function(source)
    return not source.disarmed
  end,
  --Coordinated Assault2
  [360952] = function(source)
    return not source.disarmed
  end,
  --Shadow Dance
  [185422] = function(source)
    return not source.disarmed
  end,
  --Shadow Blades
  [121471] = function(source)
    return not source.disarmed
  end,  
  --Adrenaline Rush
  [13750] = function(source)
    return not source.disarmed
  end,  
  --Combustion
  [190319] = function(source)
    return true
  end,  
  --Pillar of Frost
  [51271] = function(source)
    return not source.disarmed
  end,
  --Unholy Assault
  [207289] = function(source)
    return not source.disarmed
  end,
  --Metamorphosis FIXME: must lasso but not mid meta its immune
  [162264] = function(source)
    return true
  end,
  --Recklessness
  [1719] = function(source)
    return not source.disarmed
  end,
  --Avatar
  [107574] = function(source)
    return not source.disarmed
  end,
  --warbreaker
  [167105] = function(source)
    return not source.disarmed
  end,
}

-- lasso:Callback("big dam", function(spell)

--   if spell.cd - blink.gcdRemains > 0 then return end

--   blink.enemies.loop(function(enemy)
--     if not enemy.exists then return end
--     if not enemy.los then return end
--     if enemy.dist > spell.range then return end
--     if enemy.immuneMagicDamage then return end
--     if not player.target.isUnit(enemy) then return end
--     if enemy.ccr and enemy.ccr > 1 then return end
--     -- not into bladestorm
--     if enemy.class2 == "WARRIOR" and enemy.buffFrom({46924, 227847, 23920}) then return end
--     if not enemy.isPlayer then return end  
--     if enemy.immuneCC or enemy.immuneStuns then return end
--     if enemy.stunDR < 0.5 then return end
--     if not saved.autoLassoCDs then return end
--     if enemy.buff(354610) then return end --Glimpse

--     local lowest = sr.lowest(blink.fgroup)

--     local has = enemy.buffFrom(lassoMePls)

--     if not has then return end
--     local str = ""
--     for i, id in ipairs(has) do
--       if i == #has then
--         str = str .. C_Spell.GetSpellInfo(id).name
--       else
--         str = str .. C_Spell.GetSpellInfo(id).name .. ","
--       end
--     end

--     if has then
--       return spell:Cast(enemy, {face = true}) and blink.alert("Lightning Lasso (" .. colors.red .. (str) .. "|r)", spell.id)
--     end

--     if enemy.isPlayer 
--     and not enemy.immuneMagicDamage 
--     and not enemy.isHealer then
--       if lowest < 60 + bin(enemy.buffFrom(lassoMePls)) * 57 + bin(not healer.exists or not healer.los or healer.cc) * 30 then
--         return spell:Cast(enemy, {face = true}) and blink.alert("Lightning Lasso " .. colors.orange.. "(Peeling)", spell.id)
--       end
--     end
    
--   end)
-- end)

lasso:Callback("big dam", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local lowest = sr.lowest(blink.fgroup)

  local isValidUnit = function(unit)
    return unit.exists
    and unit.los
    and unit.dist <= spell.range
    and not unit.immuneMagicDamage
    and not unit.immuneCC
    and not unit.immuneStuns
    and unit.stunDR >= 0.5
    and unit.isPlayer
    and (not unit.ccr or unit.ccr <= 1)
    and (unit.class2 ~= "WARRIOR" or not unit.buffFrom({46924, 227847, 23920})) -- Not in bladestorm
    and not unit.buff(354610) -- Glimpse
    and player.target.isUnit(unit)
    and saved.autoLassoCDs
  end

  local formatBuffNames = function(buffs)
    local names = {}
    for _, id in ipairs(buffs) do
      table.insert(names, C_Spell.GetSpellInfo(id).name)
    end
    return table.concat(names, ", ")
  end

  local enemyToCast = blink.enemies.within(spell.range).find(function(enemy)
    if not isValidUnit(enemy) then return false end

    local lassoBuffs = enemy.buffFrom(lassoMePls)
    if lassoBuffs then
      local buffNames = formatBuffNames(lassoBuffs)
      sr.actionDelay(function()
        if spell:Cast(enemy, { face = true }) then
          blink.alert("Lightning Lasso (" .. colors.red .. buffNames .. "|r)", spell.id)
          return true
        end
      end)
    end

    -- Peeling logic
    if not enemy.isHealer then
      local healerCondition = bin(not healer.exists or not healer.los or healer.cc) * 30
      local peelingThreshold = 60 + bin(enemy.buffFrom(lassoMePls)) * 57 + healerCondition
      if lowest < peelingThreshold then
        sr.actionDelay(function()
          if spell:Cast(enemy, { face = true }) then
            blink.alert("Lightning Lasso " .. colors.orange .. "(Peeling)", spell.id)
            return true
          end
        end)
      end
    end

    return false
  end)
end)


lasso:Callback("command", function(spell)

  --Focus
  if blink.MacrosQueued['lasso focus'] then
    if WeCanStun(focus) then 

      if not WeCanStun(focus) then return end

      if spell:Cast(focus) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFLightning Lasso! [" .. focus.classString .. "]", spell.id)
      end	 
    end
  end

  --Target
	if blink.MacrosQueued['lasso target'] then
    if WeCanStun(target) then 

      if not WeCanStun(target) then return end

      if spell:Cast(target) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFLightning Lasso! [" .. target.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena1
  if blink.MacrosQueued['lasso arena1'] then
    if WeCanStun(arena1) then 

      if not WeCanStun(arena1) then return end

      if spell:Cast(arena1) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFLightning Lasso! [" .. arena1.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena2
  if blink.MacrosQueued['lasso arena2'] then
    if WeCanStun(arena2) then 

      if not WeCanStun(arena2) then return end

      if spell:Cast(arena2) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFLightning Lasso! [" .. arena2.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena3
  if blink.MacrosQueued['lasso arena3'] then
    if WeCanStun(arena3) then 
      
      if not WeCanStun(arena3) then return end

      if spell:Cast(arena3) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFLightning Lasso! [" .. arena3.classString .. "]", spell.id)
      end	 
    end
  end

  --EnemyHealer
  if blink.MacrosQueued['lasso enemyhealer'] then
    if WeCanStun(enemyHealer) then 

      if not WeCanStun(enemyHealer) then return end

      if spell:Cast(enemyHealer) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFLightning Lasso! [" .. enemyHealer.classString .. "]", spell.id)
      end	 
    end
  end

end)

lasso:Callback("healer", function(spell)
  
  if spell.cd - blink.gcdRemains > 0 then return end

  local lowest = sr.lowest(blink.enemies)

  if not enemyHealer.exists then return end
  if not enemyHealer.los then return end
  if enemyHealer.dist > 20 then return end
  if enemyHealer.immuneMagicDamage then return end
  if enemyHealer.ccr and enemyHealer.ccr > 1 then return end
  if enemyHealer.immuneCC then return end
  if enemyHealer.stunDR < 0.5 then return end
  if not saved.autoLassoHealer then return end

  if lowest <= 30 then 
    return spell:Cast(enemyHealer, {face = true}) and alert("Lightning Lasso [" .. enemyHealer.classString .. "]", spell.id)
  end


end)



-- staticField:Callback("combo", function(spell, unit)
--   if not player.hasTalent(51485) then return end
--   if target.exists and target.hp <= 20 then return end
--   if spell.cd - blink.gcdRemains > 0 then return end

--   blink.enemies.loop(function(enemy)

--     if enemy.distance > 28 then return end
--     if not enemy.los then return end
--     if not enemy.isPlayer then return end

--     if enemy.target.isUnit(player)
--     and enemy.cds or player.hp < 85
--     and player.combat then
--       if spell:SmartAoE(enemy, { movePredTime = blink.buffer }) then 
--         alert("|cFFf7f25cStatic Field " .. (enemy.classString or "") .. "", spell.id)
--       end
--     end   
--   end) 

-- end)

-- totemicProjection:Callback("combo", function(spell, unit)
--   local fieldTotem = blink.triggers.find(function(t) return t.id == 355619 end)

--   local inFieldTotem = blink.enemies.around(fieldTotem, 6, function(obj) return obj.enemy end)

--   -- we use this later
--   local dist = blink.Distance
--   -- ursol kill target *away* from nearby aoe defensive
--   -- e.g, darkness, AMZ, earthen wall, barrier, link ..
--   -- (AoEDefensive is from my routine, finding the right area trigger)
--   local x, y, z = player.position()
--   --local sx, sy, sz = fieldTotem.position()
--   if target.exists then
--     if totemicProjection:SmartAoE(target, {
--       movePredTime = blink.buffer,
--       sort = function(t, b)
--         -- sort valid positions by furthest away from the defensive
--         return dist(t.x, t.y, t.z, x, y, z) > dist(b.x, b.y, b.z, x, y, z)
--       end
--     }),
--   end
-- end)

-- function shaman:MoveThemAway()

--   local fieldTotem = blink.triggers.find(function(t) return t.id == 355619 end)

--   local inFieldTotem = blink.enemies.around(fieldTotem, 6, function(obj) return obj.enemy end)

--   -- we use this later
--   local dist = blink.Distance
--   -- ursol kill target *away* from nearby aoe defensive
--   -- e.g, darkness, AMZ, earthen wall, barrier, link ..
--   -- (AoEDefensive is from my routine, finding the right area trigger)
--   local x, y, z = player.position()
--   --local sx, sy, sz = fieldTotem.position()
--   if totemicProjection:SmartAoE(target, {
--     movePredTime = blink.buffer,
--     sort = function(t, b)
--       -- sort valid positions by furthest away from the defensive
--       return dist(t.x, t.y, t.z, x, y, z) > dist(b.x, b.y, b.z, x, y, z)
--     end
--   })
-- end








local healthstones = blink.Item(5512)

local checked_for_hs = 0
function healthstones:grab()
  -- don't need to be checking super frequently
  if blink.time - checked_for_hs < 1 + bin(not blink.arena) * 6 then return end
  -- must not already have hs
  if self.count > 0 then return end
  -- don't grab while casting / channelingq
  if player.casting or player.channeling then return end

  blink.objects.loop(function(obj)
    if obj.name ~= "Soulwell" then return end
    if obj.creator.enemy then return end
    if obj.dist > 5 then return end
    -- must have free bag slots, alert user if we don't
    if blink.GetNumFreeBagSlots() == 0 then return blink.alert("Can't grab healthstone! Bags are full.") end

    if sr.longDelay() then 
      obj:interact()
    end
    return blink.alert("Grabbing Healthstone", self.spell)

    --was working
    -- if not Unlocker.type then
    --   InteractUnit(obj.pointer)
    --   return blink.alert("Grabbing Healthstone", self.spell)
    -- --FIXME: error on daemonic!
    -- elseif Unlocker.type == "daemonic" then
    --   -- InteractUnit(obj.pointer)
    --   -- blink.alert("Grabbing Healthstone", self.spell)
    --   return
    -- end
  end)

  checked_for_hs = blink.time
end

function healthstones:auto()
  if not IsUsableItem(5512) then return end
  if self.count == 0 then return end
  if self.cd > 0 then return end
  if player.hp > 80 then return end

  local threshold = 25
  threshold = threshold - bin(player.immuneMagicDamage) * 10
  threshold = threshold - bin(player.immunePhysicalDamage) * 10
  threshold = threshold + bin(not healer.exists or not healer.los or healer.cc) * 25

  if player.hp < threshold and self:Use() then
    blink.alert("Healthstone "..colors.red.."[low hp]", self.spell)
  end
end


shaman.lasso = lasso
shaman.totemicProjection = totemicProjection
shaman.burrow = burrow
shaman.grounding = grounding
shaman.healthstones = healthstones
