local unlocker, blink, sr = ...
local warrior = sr.warrior
local player, target, healer = blink.player, blink.target, blink.healer
local bin, colors = blink.bin, blink.colors
local saved = sr.saved

if not warrior.ready then return end

  
blink.addEventCallback(function() blink.call("ReloadUI")
end, "ACTIVE_PLAYER_SPECIALIZATION_CHANGED")  

warrior.print = function(str)
  blink.print(colors.warrior .. "|cFFf7f25c[SadRotations]:|r " .. str)
end

warrior.print(colors.warrior .. "Core |cFFf7f25cLoaded")

--macros
blink.RegisterMacro('pause', 1)
blink.RegisterMacro('pause 1', 1)
blink.RegisterMacro('pause 2', 2)
blink.RegisterMacro('pause 3', 3)
blink.RegisterMacro('pause 4', 4)
blink.RegisterMacro('pause 5', 5)
blink.RegisterMacro('bolt target', 1.25)
blink.RegisterMacro('bolt focus', 1.25)
blink.RegisterMacro('bolt arena1', 1.25)
blink.RegisterMacro('bolt arena2', 1.25)
blink.RegisterMacro('bolt arena3', 1.25)
blink.RegisterMacro('bolt enemyhealer', 1.25)
blink.RegisterMacro('fear target', 1.25)
blink.RegisterMacro('fear focus', 1.25)
blink.RegisterMacro('fear arena1', 1.25)
blink.RegisterMacro('fear arena2', 1.25)
blink.RegisterMacro('fear arena3', 1.25)
blink.RegisterMacro('fear enemyhealer', 1.25)

local Spell = blink.Spell
blink.Populate({
  charge = Spell(100,  { ignoreGCD = true }),
  leap = Spell(6544,  { ignoreGCD = true }),
  intervene = Spell(3411, { ignoreGCD = true, beneficial = true }),
  dstance = Spell(386208,  { ignoreGCD = true }),
  bstance = Spell(386164,  { ignoreGCD = true }),
}, warrior, getfenv(1))

local attack = blink.Spell(6603)

function attack:start() return not self.current and blink.call("StartAttack", "Target") end

function attack:stop() return self.current and StopAttack() end

function warrior:Attack()
  -- handle auto attacking
  if target.exists and target.enemy then
    if target.bcc then
      blink.call("SpellStopCasting")
      attack:stop()
    else
      attack:start()
    end
  end
end

-- function warrior:StanceManagment()
--   -- local count, _, _, cds = player.v2attackers()
--   -- local threshold = 15.5
--   -- threshold = threshold + bin(player.hp <= saved.DSensitivity) * 15
--   -- threshold = threshold + count * 9.5
--   -- threshold = threshold + cds * 11.5
--   -- threshold = threshold * (0.8 + bin(not healer.exists or healer.cc and healer.ccr > 1) * 1.25)
--   -- --threshold = threshold * saved.DSensitivity

--   -- if player.hp <= threshold then
--   --   if player.buff(386208) then return end
--   --   return dstance:CastAlert()
--   -- else
--   --   if count > 1 then return end
--   --   if player.buff(386164) then return end
--   --   if player.hp <= threshold then return end  
      
--   --   if player.hp > threshold then
--   --     C_Timer.After(5, function() 
--   --       if player.buff(386164) then return end
--   --       return bstance:CastAlert()
--   --     end)
--   --   end
--   -- end

--   if player.hp <= saved.DSensitivity
--   or not player.combat then 
--     if player.buff(386208) then return end
--     return dstance:CastAlert()
--   else 
--     if player.hp > saved.DSensitivity then 
--       if player.buff(386164) then return end
--       return bstance:CastAlert()
--     end
--   end
    
-- end

function warrior:StanceManagment()

  -- Check for the presence of a rogue
  local roguePresent = blink.enemies.find(function(e) return e.class2 == "ROGUE" and e.exists end)
  local totalUnits, meleeUnits, rangedUnits, cooldowns = player.v2attackers()
  local hpThreshold = saved.DSensitivity
  local threatLevel = totalUnits + blink.bin(cooldowns > 0) * (meleeUnits + rangedUnits * 0.5) * 1.5 + blink.bin(hpThreshold)
  local shouldSwitchToDefensive = player.hp <= hpThreshold or not player.combat or threatLevel > 2 or (roguePresent and healer.cc)
  local healerIsCCd = healer.exists and shouldSwitchToDefensive and (healer.cc or healer.ccr > 1 or not healer.los)

  if shouldSwitchToDefensive or healerIsCCd then
    if not player.buff(386208) then -- Defensive stance buff check
      return dstance:CastAlert()
    end
  else
    -- Delay before switching back to battle stance to ensure it's safe
    if not player.buff(386164) and player.hp > hpThreshold then -- Battle stance buff check
      C_Timer.After(5, function()
        if player.hp > hpThreshold and player.combat then
          return bstance:CastAlert()
        end
      end)
    end
  end
end

function warrior:StanceManagement()

  local roguePresent = blink.enemies.find(function(e) return e.class2 == "ROGUE" and e.exists end) ~= nil
  local totalUnits, meleeUnits, rangedUnits, cooldowns = player.v2attackers()
  local hpThreshold = saved.DSensitivity
  local criticalThreatLevel = totalUnits + blink.bin(cooldowns > 0) * (meleeUnits + rangedUnits * 0.5) * 1.5
  local underHeavyAttack = player.hp <= hpThreshold or criticalThreatLevel > 3
  local healerCompromised = underHeavyAttack and healer.exists and (healer.cc or healer.ccr > 1 or not healer.los)

  if (underHeavyAttack or healerCompromised) and roguePresent then
    if not player.buff(386208) then -- Check if not already in defensive stance
      return dstance:Cast() -- Switch to defensive stance
    end
  else
    C_Timer.After(2, function()
      if not underHeavyAttack 
      or player.hp > hpThreshold 
      and player.combat 
      and not player.buff(386164) then
        return bstance:Cast()
      end
    end)
  end
end


warrior.timeHoldingGCD = 0
warrior.timeHoldingGCDStart = 0

local lastTimeCounted = 0
local currentTime = GetTime()

function warrior:HoldGCDForBladestorm()
  
  -- bstorm not ready :P
  if not blink.actor.bladestorm or not blink.actor.bladestorm.known or blink.actor.bladestorm.cd > (blink.gcdRemains or 0) then return false end
  -- on gcd
  if blink.gcdRemains > blink.spellCastBuffer + blink.tickRate * 2 then return end
  -- already held max gcds
  if currentTime > (lastTimeCounted + 2) then lastTimeCounted = GetTime() return end
  --if self.timeHoldingGCD > 2 then return end

  -- somebody is about to stun us! 

  -- we are on full stun dr 
  if player.sdr == 1 or (player.sdrr or 0) < (blink.gcd or 0) then
    
    -- vs a rogue team ...
    if blink.fighting("ROGUE") then
      
      -- rogue is obviously on us, or could conveniently stun us..
      local object, nearUs, playerTargeted = nil, false, false
      blink.enemies.loop(function(enemy)
        if enemy.class2 == "ROGUE" then
          object = enemy
          if enemy.predictDistance(0.65) <= 6 then
            nearUs = true
          end
          if enemy.target.isUnit(player) then
            playerTargeted = true
          end
        end
      end)
      if nearUs and (blink.fighting(261) or max(object.cooldown(408), object.cooldown(195457)) <= 1) then return true end

      -- one of our teammates gets cc'd
      if not object or blink.fighting(261) or object.cooldown(408) <= 1 and object.distance <= 30 - bin((object.cooldown(36554) > 1 or sr.lowest(blink.group) < 99) and not playerTargeted) * 20 then
        local teammateCC = false
        blink.fgroup.loop(function(obj) if obj.cc and obj.hp > 96 then teammateCC = true return true end end)
        if teammateCC then return true end
      end

    end

    -- vs a ferale ... 
    if blink.fighting("Feral") then
      
      -- feral is obviously on us
      local bouttaMaim = false
      blink.enemies.loop(function(enemy)
        if enemy.class2 == "DRUID" 
        and enemy.role == "melee" 
        and enemy.target.isUnit(player) 
        and enemy.meleeRangeOf(player)
        and enemy.cooldown(22570) <= 1 then
          bouttaMaim = true
        end
      end)
      if bouttaMaim and (not healer.exists or healer.cc) then return true end

    end

    -- vs windwalka .. 
    if blink.fighting("Windwalker") then

      -- obviously about to sweep us ..
      local bouttaSweep = false
      blink.enemies.loop(function(enemy)
        if enemy.class2 == "MONK" 
        and enemy.role == "melee" 
        and enemy.distanceToLiteral(player) < 7
        and enemy.cooldown(119381) <= 1
        and not enemy.channeling
        and (enemy.gcdRemains <= 0.8 or enemy.cds) then
          bouttaSweep = true
        end
      end)

      if bouttaSweep then return true end

    end

    -- vs 

  end

end

local maxDist = 0
function warrior:GetOuttaSpear(frame)
  
  frame = frame or 0.05
  if not player.debuff(376080) then return true end
  player:ClearCache()

  local spear = blink.triggers.find(function(t) return t.id == 307954 end)

  local beingSucced = false
  local x, y, z
  local sx, sy, sz
  local pdist
  if spear then
    sx, sy, sz = spear.position()
    local px, py, pz = player.position()
    pdist = blink.Distance(px, py, pz)
    local angleAway = blink.AnglesBetween(sx, sy, sz, px, py, pz)
    local angleTo = blink.AnglesBetween(px, py, pz, sx, sy, sz)
    -- position = directly out of spear at good dist for enough velocity
    -- x, y, z = sx + math.cos(angleAway) * 7, sy + math.sin(angleAway) * 7, sz
    -- if spear.distLiteral > maxDist then
    --   maxDist = spear.distLiteral
    --   print(maxDist)
    -- end
    if spear.distLiteral > 4.8 and spear.distLiteral < 6.1
    and spear.predictDistanceLiteral(frame + blink.latency * 2 + 0.01) > 5.455 then --and blink.angleDist(player.movingDirection, angleTo, true) < 0.3 then
      beingSucced = true
    end
  end
  
  if beingSucced
  and not player.used(charge.id, 1)
  and not player.used(intervene.id, 1) then
    -- charge / intervene out
    if intervene:Castable() or charge:Castable() then
      if spear then

        local intervened, charged = false, false
        local sf = function(a, b) return a.distanceToLiteral(sx, sy, sz) - a.distanceLiteral > b.distanceToLiteral(sx, sy, sz) - b.distanceLiteral end
        
        blink.players.sort(sf)
        blink.units.sort(sf)

        if intervene:Castable() then
          local ifunc = function(f)
            if not f.friend or f.enemy then return end
            if f.distanceLiteral + 2.5 < f.distanceToLiteral(sx, sy, sz) then
              intervened = intervene:Cast(f) and blink.alert("Intervene " .. "|cFFf7f25c[Get Out]", intervene.id)
              return intervened
            end
          end
          blink.players.loop(ifunc)
          blink.units.loop(ifunc)
        end
        if not intervened then
          local cfunc = function(f)
            if not f.enemy then return end
            if f.distanceLiteral + 3 < f.distanceToLiteral(sx, sy, sz) then
              charged = charge:Cast(f, {face=true}) and blink.alert("Charge " .. "|cFFf7f25c[Get Out]", charge.id)
              return charged
            end
          end
          blink.players.loop(cfunc)
          blink.units.loop(cfunc)
          -- if not charged and x and y and z and player.losCoords(x,y,z) and leap:Castable() and leap:AoECast(x, y, z) then
          --   return blink.alert("Leap " .. "|cFFf7f25c[Get Out]", leap.id)
          -- end
        end
      end
    end
  end
end

CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)
  warrior:GetOuttaSpear(elapsed)
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
    if blink.GetNumFreeBagSlots() == 0 then return blink.alert("Can't grab healthstones! Bags are full.") end
      
    if sr.longDelay() then 
      obj:interact()
    end
    return blink.alert("Grabbing Healthstone", self.spell)
  end)

  checked_for_hs = blink.time
end

function healthstones:auto()
  if self.count == 0 then return end
  if self.cd > 0 then return end
  if player.hp > 80 then return end

  local threshold = 25
  threshold = threshold - bin(player.immuneMagicDamage) * 10
  threshold = threshold - bin(player.immunePhysicalDamage) * 10
  threshold = threshold + bin(not healer.exists or healer.cc) * 25

  if player.hp < threshold and self:Use() then
    blink.alert("Healthstone  "..colors.red.."[Danger]", self.spell)
  end
end

warrior.healthstones = healthstones

-- blink.Draw(function(draw)

--   if saved.streamingMode then return end
  
--   if saved.aaDraw then
--     draw:SetWidth(1.5)
--     if target.enemy then
--       local px, py, pz = player.position()
--       local d, a = 5, 140
--       if target.arc(d, a, player) then
--         draw:SetColor(100, 255, 100, 200)
--       else
--         draw:SetColor(255, 100, 100, 240)
--       end
--       draw:Arc(px, py, pz, d, a, player.rotation)
--     end
--   end

--   if saved.healerLine then
--     if healer.visible then
--       local lining = not healer.los
--       local ranging = healer.dist > 38.5
--       draw:SetWidth(1 + bin(lining or ranging) + bin(lining) + bin(ranging))
--       local blv = bin(lining or ranging) * 155
--       draw:SetColor(100 + blv, 100, 255 - blv, 255)
--       local px, py, pz = player.position()
--       local hx, hy, hz = healer.position()
--       draw:Line(px, py, pz, hx, hy, hz)
--     end
--   end
-- end)

blink.ManualSpellObjects[107570] = blink.Spell(107570, { cc = "stun", effect = "physical" })
blink.ManualSpellObjects[236077] = blink.Spell(236077, { cc = true, effect = "physical" })