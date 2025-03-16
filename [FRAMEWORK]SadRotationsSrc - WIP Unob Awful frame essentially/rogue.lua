local Unlocker, blink, sr = ...
local bin, angles, min, max, cos, sin, inverse, sort = blink.bin, blink.AnglesBetween, min, max, math.cos, math.sin, blink.inverseAngle, table.sort
local rogue, assa = sr.rogue, sr.rogue.assa
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local NewSpell, NS, events, cmd, colors, colored, alert = blink.Spell, blink.Spell, blink.events, sr.cmd, blink.colors, blink.colored, blink.alert
local UnlockerType = Unlocker.type
local onEvent, onUpdate = blink.addEventCallback, blink.addUpdateCallback
local state = sr.arenaState
local saved = sr.saved
local arena1 = blink.arena1
local arena2 = blink.arena2
local arena3 = blink.arena3
local time = blink.time

if not rogue.ready then return end

local sap = NS(6770, {cc = true})

--reload when spec changed
blink.addEventCallback(function() blink.call("ReloadUI")
end, "ACTIVE_PLAYER_SPECIALIZATION_CHANGED")

rogue.print = function(str)
  blink.print(colors.rogue .. "|cFFf7f25c[SadRotations]: " .. str)
end

rogue.print("|cFFFFFFFF|r|rCore |cFFf7f25cLoaded")

--Maim
blink.RegisterMacro("kidney target", 7)
blink.RegisterMacro("kidney focus", 7)
blink.RegisterMacro("kidney arena1", 7)
blink.RegisterMacro("kidney arena2", 7)
blink.RegisterMacro("kidney arena3", 7)

--Bash
blink.RegisterMacro("cheap target", 3)
blink.RegisterMacro("cheap focus", 3)
blink.RegisterMacro("cheap arena1", 3)
blink.RegisterMacro("cheap arena2", 3)
blink.RegisterMacro("cheap arena3", 3)

--Clones
blink.RegisterMacro("blind target", 1)
blink.RegisterMacro("blind focus", 1)
blink.RegisterMacro("blind arena1", 1)
blink.RegisterMacro("blind arena2", 1)
blink.RegisterMacro("blind arena3", 1)
blink.RegisterMacro("blind enemyhealer", 1)

--etc
blink.RegisterMacro('burst', 2)
blink.RegisterMacro('pause', 1)
blink.RegisterMacro('pause 1', 1)
blink.RegisterMacro('pause 2', 2)
blink.RegisterMacro('pause 3', 3)
blink.RegisterMacro('pause 4', 4)
blink.RegisterMacro('pause 5', 5)


-- auto attack
local attack = NS(6603)

function attack:start()
  return not self.current and blink.call("StartAttack")
end

function attack:stop()
  return self.current and StopAttack()
end

function rogue:Attack()
  if player.stealth then return end
  if target.dead then return end
  -- handle auto attacking
  if target.enemy and target.exists then
    if target.bcc then
      attack:stop()
    else
      attack:start()
    end
  end
  
end

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

    sr.randomDelay(function()
      obj:interact()
    end)
    return blink.alert("Grabbing Healthstone", self.spell)
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

rogue.healthstones = healthstones

local wasCasting = {}
rogue.Poisions = function()
  if not player.combat then
    -- if player.buffRemains(2823) < 200 
    -- and not wasCasting[2823] then
    --   actor.deadlyPoison:Cast()
    -- end
    if player.buffRemains(3408) < 200 
    and not wasCasting[3408] then
      actor.cripplingPoison:Cast()
    end
    if player.buffRemains(8679) < 200 
    and not wasCasting[8679] then
      actor.woundPoison:Cast()
    end
    -- if player.buffRemains(5761) < 200 
    -- and not wasCasting[5761] then
    --   actor.numbingPoison:Cast()
    -- end

    if (target.enemy or blink.arena) 
    and not player.stealth then
      if actor.stealth.cd < 1 then
        if actor.stealth:Cast() then 
          blink.alert("Stealth", actor.stealth.id)
          return
        end
      end
    end
  end
end


-- rogue.cheapShotCount = 0 -- Initialize the counter outside of the function

-- rogue.Opener = function()
--   if target.exists
--     and target.enemy 
--     and (player.stealth or player.buff(185422)) -- Check if the player is stealthed or has the Shadow Dance buff.
--     and target.stunDR == 1 -- Ensure the target is not under stun diminishing returns.
--   then
--     -- Cast Cheap Shot if the stun is about to wear off, or if it's the opener and target is not stunned.
--     if (target.stunRemains < 0.8) and rogue.cheapShotCount < 3 then
--       actor.cheapShot:Cast(target)
--       rogue.cheapShotCount = rogue.cheapShotCount + 1 -- Increment the counter
--     end
--   else
--     rogue.cheapShotCount = 0 -- Reset the counter if the target is not valid
--   end
-- end
local danceUp = player.buffRemains(185422) > 0
local subterfugeUp = player.buffRemains(115192) > 0

local function smooth_step(unit, ml_or)
	if actor.step.cd - blink.gcdRemains > 0 then return false end
	if already_stepped and GetTime() - already_stepped < 0.2 then return false end
	local px,py,pz = player.position()
	local fdir = player.facing(unit)
	local x,y,z = px + 2 * math.cos(fdir), py + 2 * math.sin(fdir), pz
	if actor.step:Cast(unit) then
		blink.controlMovement(0.15)
		C_Timer.After((ml or 0.245),function() SetMovementLocked(false) end)
		C_Timer.After(.15, function() if player_step and GetTime() - player_step <= .15 then blink.FaceDirection(x,y,z) end end)
		already_stepped = GetTime()
		return true
	end
end

-- rogue.DanceGo = function(unit)
--   if not target.exists then return end
--   if not player.buff(185422) then return end --or max_cast_time < blink.gcd then return end

--   local relent_mod = 0 -- need to find out if the unit is playing relentless
--   local ogre_mod = unit.race == "Orc" and 0.2 or 0
--   local cc_mod = 1 - ogre_mod - relent_mod
--   local stun_dr = unit.stunDR
--   local stun_remains = unit.stunRemains
--   if stun_dr < 0.25 then stun_dr = 0 end
--   local sdr_remains = unit.sdrr
--   local immune_cheap = unit.immuneStuns
--   local cs_duration = (4 * stun_dr) * cc_mod
--   local melee_range = unit.meleeRange
--   local acceptable_gap = 0.41 * (1 + (max(ogre_mod*4,relent_mod*4)))
--   local gcds_before_stun = math.floor( (stun_remains + acceptable_gap + 0.01 - blink.gcdRemains) / blink.gcd )

--   if cs_duration > 0 and (sdr_remains == 0 or sdr_remains >= 17.5) and not immune_cheap then
--     -- cheap again if stun on target remains < gcd - acceptable gap
--     if stun_remains < blink.gcd - acceptable_gap then
--       if melee_range then
--         if stun_remains > blink.buffer and gcds_before_stun <= 0 then
--           --SquidFrame = 2
--           return "wait"
--         else
--           if player.energy < 35 then
--             actor.tea:Cast()
--           end
--           actor.cheapShot:Cast(target) 
--           -- cold blood
--           -- if gcd_remains <= .4 and dance_remains > gcd_remains + .1 and _Cast(213981) then
--           --   Squid_Alert("Cold Blood",nil,nil,nil,213981)
--           -- end
--           -- -- cheap
--           -- if _Cast(1833,unit,nil,true) then
--           --   SquidFrame = 2 -- run script again on next frame
--           --   return true
--           -- end
--         end
--       -- elseif unit.dist > 6 + bin(player.movingToward(unit, { duration = 0.11 }))*2 and stun_dr == 1 then--and not fleeing_from_unit(unit,.9) then
--       --   if smooth_step(unit) then
--       --     --alert("Shadowstep", "(Going)",36554)
--       --     --SquidFrame = 2 -- run script again on next frame
--       --     --return true
--       --   end
--       end
--     end
--   end
-- end

rogue.DanceGo = function(unit)
  if not target.exists or not player.buff(185422) then return end

  local ogre_mod = unit.race == "Orc" and 0.2 or 0
  local cc_mod = 1 - ogre_mod  -- Assuming no relent_mod for now
  local stun_dr = unit.stunDR
  if stun_dr < 0.25 then stun_dr = 0 end

  local cs_duration = 4 * stun_dr * cc_mod
  local stun_remains = unit.stunRemains
  local immune_cheap = unit.immuneStuns
  local melee_range = unit.meleeRange

  -- Adjust the gap based on ogre_mod
  local acceptable_gap = 0.41 * (1 + ogre_mod * 4)
  
  -- Calculate GCDs before the next stun application
  local gcds_before_stun = math.floor((stun_remains + acceptable_gap - blink.gcdRemains) / blink.gcd)

  -- Conditions to cast Cheap Shot
  if not immune_cheap and cs_duration > 0 and (unit.sdrr == 0 or unit.sdrr >= 17.5) then
    if melee_range and stun_remains < blink.gcd - acceptable_gap then
      if player.energy < 35 then
        actor.tea:Cast()  -- Cast energy regen ability if energy is low
      end
      actor.cheapShot:Cast(target)
      return "casted"
    end
  end
  return "waiting"  -- Return a status indicating the script is waiting for the right moment
end

assa.Opener = function(unit)
  if not unit or not unit.enemy then return end

  local isCaster = unit.enemy and not unit.role == "melee" and not unit.class2 == "HUNTER"

  -- Opener for general units
  if not isCaster then
    if player.stealth then
      actor.cheapShot:Cast(unit) -- Cheap Shot
    end
    actor.garrote:Cast(unit) -- Garrote
    actor.shiv:Cast(unit) -- Shiv
    if player.cp >= 5 then
      if unit.debuffRemains(132297) < 1 then 
        actor.rupture:Cast(unit) -- Rupture if CPs are enough
        -- Mutilate and Envenom logic based on CPs
      else
        --return end
      end
    end
  end

  -- Opener for caster units
  if isCaster then
    actor.garrote:Cast(unit) -- Garrote x2
    actor.kidneyShot:Cast(unit) -- Kidney Shot with 5 CPs
    actor.shiv:Cast(unit) -- Shiv
    -- Mutilate and Rupture logic based on CPs
    -- Mutilate and Envenom logic based on CPs
  end

  -- Common logic for building CPs and finishing with Envenom
  -- Mutilate until 4+ CPs, then Rupture or Envenom based on CPs and target's debuffs
end



local function Sappable(unit)
  return unit.exists 
  and unit.isPlayer 
  and unit.incapDR >= 0.25 
  and unit.ccRemains < 1 
  and not unit.combat 
  and not unit.dotted
end


sap:Callback("stealth", function(spell)

  if blink.prep then return end
  return blink.enemies.stomp(function(enemy, uptime)
    if enemy.distLiteral > spell.range then return end
    if not enemy.isPlayer then return end
    if enemy.buffFrom({185422, 185313}) then return end --121471 blades check if it solve or cause issues
    if enemy.stealth 
    and Sappable(enemy) then
      if spell:Cast(enemy, {face = true}) then
        if not saved.streamingMode then
          alert("Sap " .. (enemy.class or "") .. "|cFFf74a4a[Stealth]", spell.id)
        end
      end
    end
  end)
end)

sap:Callback("focus", function(spell)

  if blink.prep then return end
  if not target.exists then return end

  if focus.exists 
  and focus.isPlayer 
  and focus.incapDR >= 0.5
  and focus.ccRemains < 1 
  and not focus.isUnit(target)
  and not focus.combat 
  and not focus.dotted then
    return spell:Cast(focus) and alert("Sap " .. (focus.class or "") .. "|cFFf74a4a[Focus]", spell.id)
  end

end)



local healthstones = blink.Item(5512)

local checked_for_hs = 0
function healthstones:grab()
  -- don't need to be checking super frequently
  if blink.time - checked_for_hs < 1 + bin(not blink.arena) * 6 then return end
  -- must not already have hs
  if self.count > 0 then return end
  -- don't grab while casting / channeling
  if player.casting or player.channeling then return end

  blink.objects.loop(function(obj)
    if obj.name ~= "Soulwell" then return end
    if obj.creator.enemy then return end
    if obj.dist > 5 then return end
    -- must have free bag slots, alert user if we don't
    if blink.GetNumFreeBagSlots() == 0 then return blink.alert("Can't grab healthstone! Bags are full.") end

    sr.randomDelay(function()
      obj:interact()
    end)
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
  threshold = threshold + bin(not healer.exists or healer.cc) * 25

  if player.hp < threshold and self:Use() then
    blink.alert("Healthstone "..colors.red.."[low hp]", self.spell)
  end
end

rogue.healthstones = healthstones
rogue.sap = sap