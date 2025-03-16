local Unlocker, blink, sr = ...
local bin, angles, min, max, cos, sin, inverse, sort = blink.bin, blink.AnglesBetween, min, max, math.cos, math.sin, blink.inverseAngle, table.sort
local priest, disc = sr.priest, sr.priest.disc
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local NS, events, cmd, colors, colored = blink.Spell, blink.events, sr.cmd, blink.colors, blink.colored
local UnlockerType = Unlocker.type
local onEvent, onUpdate = blink.addEventCallback, blink.addUpdateCallback
local state = sr.arenaState
local saved = sr.saved

local currentSpec = GetSpecialization()

if not priest.ready then return end
  
--reload when spec changed
blink.addEventCallback(function() blink.call("ReloadUI")
end, "ACTIVE_PLAYER_SPECIALIZATION_CHANGED")

priest.print = function(str)
  blink.print(colors.priest .. "|cFFf7f25c[SadRotations]: " .. str)
end

priest.print("|cFFFFFFFF|r|rCore |cFFf7f25cLoaded")


--Macros
blink.RegisterMacro('burst', 3)
blink.RegisterMacro('pause', 1)
blink.RegisterMacro('pause 1', 1)
blink.RegisterMacro('pause 2', 2)
blink.RegisterMacro('pause 3', 3)
blink.RegisterMacro('pause 4', 4)
blink.RegisterMacro('pause 5', 5)
--fear 
blink.RegisterMacro("fear", 5)
blink.RegisterMacro("fear target", 5)
blink.RegisterMacro("fear focus", 5)
blink.RegisterMacro("fear arena1", 5)
blink.RegisterMacro("fear arena2", 5)
blink.RegisterMacro("fear arena3", 5)
blink.RegisterMacro("fear enemyhealer", 5)
--chastise
blink.RegisterMacro('stun target', 1.25)
blink.RegisterMacro('stun focus', 1.25)
blink.RegisterMacro('stun arena1', 1.25)
blink.RegisterMacro('stun arena2', 1.25)
blink.RegisterMacro('stun arena3', 1.25)
blink.RegisterMacro('stun enemyhealer', 1.25)


local deaths = NS(32379, { damage = "magic", ranged = true, ignoreFacing = true, ignoreMoving = true })
local death = NS(32379, { damage = "magic", ranged = true, ignoreFacing = true, ignoreMoving = true })
local fade = NS(586, { ignoreFacing = true, ignoreMoving = true, ignoreGCD = true })
local scream = NS(8122, { cc = true, fear = true, ignoreMoving = true, ignoreFacing = true })
local tendrils = NS(108920, { cc = true, ignoreMoving = true, ignoreFacing = true })
local smite = NS(585, { damage = "magic", ranged = true })
local meld = NS(58984)
local fiend = NS(34433)
local fortitude = NS(21562)


local BigDamageBuffs =
{
  --Incarnation Ashame - Feral
  [102543] = function(source)
    return source.role == "melee"
  end,
  --Incarnation Chosen - Boomkin
  [102543] = function(source)
    return source.role == "ranged"
  end,
  --wings
  [31884] = function(source)
    return source.role == "melee"
  end,
  --wings
  [231895] = function(source)
    return source.role == "melee"
  end,
  --doomwinds
  [384352] = function(source)
    return source.class2 == "SHAMAN" and source.role == "melee"
  end,
  --Serenity
  [152173] = function(source)
    return source.role == "melee"
  end,
  --boondust
  [386276] = function(source)
    return source.role == "melee"
  end,
  --trueshot
  [288613] = function(source)
    return true
  end,
  --Coordinated Assault
  [266779] = function(source)
    return true
  end,
  --Coordinated Assault2
  [360952] = function(source)
    return true
  end,
  --Shadow Dance
  [185422] = function(source)
    return true
  end,
  --Shadow Blades
  [121471] = function(source)
    return true
  end,  
  --Adrenaline Rush
  [13750] = function(source)
    return true
  end,  
  --Combustion
  [190319] = function(source)
    return true
  end,  
  --Pillar of Frost
  [51271] = function(source)
    return true
  end,
  --Unholy Assault
  [207289] = function(source)
    return true
  end,
  --Metamorphosis
  [162264] = function(source)
    return true
  end,
  --Recklessness
  [1719] = function(source)
    return true
  end,
  --Avatar
  [107574] = function(source)
    return true
  end,
  --warbreaker
  [167105] = function(source)
    return true
  end,

} 

local SwapOverLap = {

    186265, --turtle
    196555, --netherwalk
--    206803, --rainfromabove
    61336,  --survival ins
    45438,  --iceblock
    342246, --altertime
    116849, --ccon
    1022,   --bop
    642,    --bubble
    228049, --guardian prot pala
    33206,  --PS
    47585,  --disperson
    47788,  --guardian priest
    5277,   --rogue evaison
    108271,  --astral shift
    108416,  --lock shield sac
    118038,  --die by the sowrd
    871,     --shield wall
    81782,   --Big Barrier

}

local DispelRoots = {
    122, -- frost nova
    102359, --massroot
    339, --druid root
    33395, --another proc nova
    64695, --earthgrap
}


-- on-damage events!
onEvent(function(info, event, source, dest)

  if not source.enemy then return end
  local time = GetTime()
  local spellID, spellName = select(12, unpack(info))
  local events = blink.events
  local happened = event.time

  if event ~= "SPELL_CAST_SUCCESS" then return end

  if not saved.AutoMeld then return end

  -- ShadowMeld Stormbolt
  if spellID == 107570 
  and dest.isUnit(player)
  and player.sdr > 0.5
  and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
    if player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Stormbolt", colors.warrior) .. ")", meld.id)
      end
    end
  end

  -- ShadowMeld/flesh Coil
  if spellID == 6789 and dest.isUnit(player) 
  and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
    if player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Coil", colors.warlock) .. ")", meld.id)
      end
    end
  end

  -- Meld the hunt
  if spellID == 370965
  and dest.isUnit(player)
  and source.speed > 45 
  and player.race == "Night Elf" then 
    if meld:Cast({stopMoving = true}) then
      return blink.alert("Shadow Meld (" .. colored("The Hunt", colors.dh) .. ")", meld.id)
    end
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

    obj:interact()
    return blink.alert("Grabbing Healthstone", self.spell)

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
  if player.hp > 70 then return end

  local threshold = 25
  threshold = threshold - bin(player.immuneMagicDamage) * 10
  threshold = threshold - bin(player.immunePhysicalDamage) * 10
  --threshold = threshold + bin(not healer.exists or healer.cc) * 25

  if player.hp < threshold and self:Use() then
    blink.alert("Healthstone "..colors.red.."[low hp]", self.spell)
  end
end

priest.healthstones = healthstones


local ThingsToDeath = {
  [187650] = function(spellID)
      return blink.missiles.find(function(obj) if obj.source.enemy and obj.spellId and obj.spellId == spellID then return true end end)
  end, -- Freezing Trap
}

local LetsDeathCC = { 
  --------- Sheeps--------------
  --[167385] = true,
  [118] = function() return player.idr >= 0.5 end,
  [161355] = function() return player.idr >= 0.5 end,
  [161354] = function() return player.idr >= 0.5 end,
  [161353] = function() return player.idr >= 0.5 end,
  [126819] = function() return player.idr >= 0.5 end,
  [61780] = function() return player.idr >= 0.5 end,
  [161372] = function() return player.idr >= 0.5 end,
  [61721] = function() return player.idr >= 0.5 end,
  [61305] = function() return player.idr >= 0.5 end,
  [28272] = function() return player.idr >= 0.5 end,
  [28271] = function() return player.idr >= 0.5 end,
  [277792] = function() return player.idr >= 0.5 end,
  [277787] = function() return player.idr >= 0.5 end,
  [391622] = function() return player.idr >= 0.5 end,
  [360806] = function() return player.idr >= 0.5 end,
  -- repentance
  [20066] = function() return player.idr >= 0.5 end,
  [118] = function() return player.idr >= 0.5 end,
  -- fear
  [5782] = function() return player.ddr >= 0.5 end,
  [65809] = function() return player.ddr >= 0.5 end,
  [342914] = function() return player.ddr >= 0.5 end,
  [251419] = function() return player.ddr >= 0.5 end,
  [118699] = function() return player.ddr >= 0.5 end,
  [30530] = function() return player.ddr >= 0.5 end,
  [221424] = function() return player.ddr >= 0.5 end,
  [41150] = function() return player.ddr >= 0.5 end,
  -- hex
  [51514] = function() return player.idr >= 0.5 end,
  [211015] = function() return player.idr >= 0.5 end,
  [211010] = function() return player.idr >= 0.5 end,
  [211004] = function() return player.idr >= 0.5 end,
  [210873] = function() return player.idr >= 0.5 end,
  [269352] = function() return player.idr >= 0.5 end,
  [277778] = function() return player.idr >= 0.5 end,
  [277784] = function() return player.idr >= 0.5 end,
  [309328] = function() return player.idr >= 0.5 end,
  [118] = function() return player.idr >= 0.5 end,
  [161355] = function() return player.idr >= 0.5 end, 
  [161354] = function() return player.idr >= 0.5 end,
  [161353] = function() return player.idr >= 0.5 end,
  [126819] = function() return player.idr >= 0.5 end,
  [61780] = function() return player.idr >= 0.5 end,
  [161372] = function() return player.idr >= 0.5 end,
  [61721] = function() return player.idr >= 0.5 end,
  [61305] = function() return player.idr >= 0.5 end,
  [28272] = function() return player.idr >= 0.5 end,
  [28271] = function() return player.idr >= 0.5 end,
  [277792] = function() return player.idr >= 0.5 end,
  [277787] = function() return player.idr >= 0.5 end,
  [391622] = function() return player.idr >= 0.5 end,
  -- sleep walk
  [360806] = function() return player.ddr >= 0.5 end,
}

priest.timeHoldingGCD = 0
priest.timeHoldingGCDStart = 0
function priest:HoldGCDForDeath()
  --arena only
  if not blink.arena then return end
  -- death not ready
  --if not blink.actor.death or not blink.actor.death.known or blink.actor.death.cd > (blink.gcdRemains or 0) then return false end
  -- on gcd
  --if blink.gcdRemains > blink.spellCastBuffer + blink.tickRate * 2 then return end
  -- already held max gcds
  if self.timeHoldingGCD > 2 then return end
  --stun we can't death shit
  if player.stunned then return end

  -- we are on full incap dr 
  if player.idr >= 0.5 or (player.idrRemains or 0) < (blink.gcd or 0) then
    
    -- vs a Hunter team ...
    if blink.fighting({253, 254, 255}, true) then
      
      --Ground traps
      local Trapz = blink.triggers.find(function(trigger) return trigger.id == 187651 end)

      if Trapz then
        if Trapz.dist < 3 then
          return true
        end
        return false
      end
  
      --flying traps
      for _, missile in ipairs(blink.missiles) do
        local id = missile.spellId
        if not id then return end
        local LetsDeath = ThingsToDeath[id]
        if not LetsDeath then return end
        local hx, hy, hz = missile.hx,missile.hy,missile.hz
        if player.distanceTo(hx, hy, hz) < 6 then
          return true
        end
        return false
      end
      
      -- HUNTER is obviously on us, or could conveniently trap us..
      -- local object, nearUs, playerTargeted = nil, false, false

      -- blink.enemies.loop(function(enemy)

      --   if enemy.class2 == "HUNTER" then
      --     object = enemy
      --     if enemy.predictDistance(0.65) <= 8 then
      --       nearUs = true
      --     end
      --     -- if enemy.target.isUnit(player) then
      --     --   playerTargeted = true
      --     -- end
      --   end

      -- end)

      --if nearUs and (blink.fighting({253, 254, 255}, true) or max(object.cooldown(187650)) <= 1) then return true end

    end
  end

  -- vs a casters ... 
  if blink.fighting("WARLOCK", "MAGE", "EVOKER", "PALADIN", "SHAMAN", true) then
    blink.enemies.loop(function(enemy)
      if not enemy.losOf(player) then return end

      local time = blink.time
      local cast = enemy.casting
      if cast then
  
        if not LetsDeathCC[cast] then return end

        if enemy.castTarget.isUnit(player) then 
          local timeleft = enemy.castTimeLeft
          --incapacitates
              
          if player.idrRemains <= enemy.castTimeLeft then
            if timeleft <= blink.gcd + blink.buffer 
            and enemy.los then
              if enemy.castTimeLeft <= blink.buffer then
                return true
              end
              return false
            end
          end
          --disorients
          if player.disorientDR >= 0.5 then
            if enemy.castTimeLeft <= blink.gcd + blink.buffer 
            and enemy.los then  
              if enemy.castTimeLeft <= blink.buffer then
                return true
              end
              return false
            end
          end
        end
      end
    end)
  end
end

deaths:Callback("trap", function(spell)
  if not blink.arena then return end
  -- traps
  blink.enemies.within(45).loop(function(enemy)

    local DeathIt = priest:HoldGCDForDeath()

    if DeathIt == true then

      if player.casting or player.channeling then 
        blink.call("SpellStopCasting")
        blink.call("SpellStopCasting")
      end

      if spell:Cast(enemy, { face = true, castableWhileChanneling = true, castableWhileCasting = true, }) then
        alert("SW : Death [" .. colored("Freezing Trap ", colors.hunter) .. "]", spell.id)
      end
    end

  end)
end)

blink.onEvent(function(info, event, source, dest)

  local time = GetTime()

  local HoldGCD = false
  local cast = source.castID
  if not cast then return end
  if not dest.isUnit(player) then return end
  if not LetsDeathCC[cast] or not LetsDeathCC[cast](source) then return end
  if source.castRemains < blink.buffer + blink.tickRate then return end

  if event == "SPELL_CAST_FAILED" then return end 
  if not source.enemy then return end

  if event == "SPELL_CAST_START"
  and source.castTarget.isUnit(player)
  and LetsDeathCC[cast](source) then

    HoldGCD = true

    if HoldGCD == true then
      return alert("Holding GCD To Death",deaths.id)
    end
  else

    if source.castTarget.isUnit(player)
    and LetsDeathCC[cast](source) 
    and source.castRemains <= 0.2 then

      if event == "SPELL_CAST_FAILED" then return end 
        
      if player.casting or player.channeling then 
        blink.call("SpellStopCasting")
        blink.call("SpellStopCasting")
      end

      if deaths:Cast(source, { face = true, castableWhileChanneling = true, castableWhileCasting = true, ignoreCasting = true, ignoreChanneling = true }) then
        alert("SW : Death " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", deaths.id, true)
      end
    end

  end

end)

deaths:Callback("cc", function(spell)

  if not blink.arena then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.enemies.within(45).loop(function(enemy)
    local HoldGCD = false
    local cast = enemy.castID
    if not cast then return end
    --if enemy.castRemains > blink.buffer + blink.tickRate then return end
    if not enemy.castTarget.isUnit(player) then return end
    if not LetsDeathCC[cast] or not LetsDeathCC[cast](enemy) then return end
    if enemy.castRemains < blink.buffer + blink.tickRate then return end

    if enemy.castTarget.isUnit(player)
    and LetsDeathCC[cast](enemy) then

      HoldGCD = true

      if HoldGCD == true then
        return alert("Holding GCD To Death",spell.id)
      end

    else

      if enemy.castTarget.isUnit(player)
      and LetsDeathCC[cast](enemy) 
      and enemy.castRemains < blink.tickRate then

        if player.casting or player.channeling then 
          blink.call("SpellStopCasting")
          blink.call("SpellStopCasting")
        end

        if spell:Cast(enemy, { face = true, castableWhileChanneling = true, castableWhileCasting = true, }) then
          alert("SW : Death " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", spell.id, true)
        end

      end
    end

  end)
end)

local BlinkFontLarge = blink.createFont(16)
local BlinkFontNormal = blink.createFont(12)

local function drawFearCircle()

    blink.Draw(function(draw)
        if saved.streamingMode then return end

        if blink.MacrosQueued['fear']
        or blink.MacrosQueued['fear target']
        or blink.MacrosQueued['fear focus']
        or blink.MacrosQueued['fear arena1']
        or blink.MacrosQueued['fear arena2']
        or blink.MacrosQueued['fear arena3']
        or blink.MacrosQueued['fear enemyhealer'] then
            if player.class2 == "PRIEST"
            and scream.cd - blink.gcdRemains < 0.5 then
                local x,y,z = player.position()
                draw:SetColor(0, 255, 0)
                draw:SetWidth(3)
                draw:Circle(x,y,z,8.1)
                draw:Text(blink.textureEscape(8122, 20) .. "Psychic Scream Range", BlinkFontNormal, x,y,z)
            end
        end
    end)
end 

drawFearCircle()

scream:Callback("command", function(spell)
    -- Define utility functions within the scream:Callback function to ensure proper scope.

    -- Local function to check for the presence of Tremor Totem within range.
    local function isTremorTotemUp()
        return blink.units.find(function(unit) 
            return unit.enemy and unit.id == 5913 and unit.dist <= 30 
        end) ~= nil
    end

    -- Local function to check if casting scream on a single unit is applicable.
    local function canCastScreamOnUnit(unit)
        return unit.distance <= 8 and unit.disorientDR >= 0.5 and not (unit.immuneMagicEffects or unit.ccRemains > 1) and not isTremorTotemUp()
    end

    -- Checking AoE fear applicability around the player and excluding Tremor Totem presence.
    local function isAoeFearApplicable()
        return blink.enemies.around(player, 8, function(enemy) 
            return enemy.isPlayer and not enemy.immuneCC and enemy.ccRemains <= 1
        end) > 0 and not isTremorTotemUp()
    end

    -- Define target conditions for Psychic Scream.
    if blink.MacrosQueued['fear'] 
    and isAoeFearApplicable() then
        if spell:Cast() then
            alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear", spell.id)
            return
        end
    end

    -- Additional target checks based on user input (focus, target, arena1-3, enemyhealer).
    local additionalTargets = {
        { key = 'fear focus', unit = focus },
        { key = 'fear target', unit = target },
        { key = 'fear arena1', unit = arena1 },
        { key = 'fear arena2', unit = arena2 },
        { key = 'fear arena3', unit = arena3 },
        { key = 'fear enemyhealer', unit = enemyHealer },
    }

    for _, t in ipairs(additionalTargets) do
        if blink.MacrosQueued[t.key] 
        and t.unit and canCastScreamOnUnit(t.unit) then
            if spell:Cast(t.unit) then
                alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear [" .. t.unit.classString .. "]", spell.id)
                return
            end
        end
    end
end)


-- scream:Callback("command", function(spell)

--     local enemiesAroundPlayer = blink.enemies.around(player, 8, function(enemy) return enemy.isPlayer and not enemy.immuneCC and not enemy.ccRemains > 1 end) > 0
--     local TremorUp = blink.units.find(function(unit) return unit.enemy and unit.id == 5913 and unit.dist <= 30 end)
--     if TremorUp then return end --blink.alert(colors.red .. "Can't Fear Tremor is up", 8143) end

--     if blink.MacrosQueued['fear'] 
--     and enemiesAroundPlayer then
--         if spell:Cast() then
--             alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear ", spell.id)
--         end	
--     end

-- 	if blink.MacrosQueued['fear focus']  
--     and focus.disorientDR >= 0.5 
--     and focus.distanceLiteral <= 8
--     and not (focus.immuneMagicEffects or focus.ccRemains > 1) then 
--         if spell:Cast() then
--             alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear [" .. focus.classString .. "]", spell.id)
--         end	
--         elseif blink.MacrosQueued['fear target'] and target.distanceLiteral <= 8 and target.disorientDR >= 0.5 and not (target.immuneMagicEffects or target.ccRemains > 1) then 
--         if spell:Cast() then
--             alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear [" .. target.classString .. "]", spell.id)
--         end	 
--     elseif blink.MacrosQueued['fear arena1'] and arena1.distanceLiteral <= 8 and arena1.disorientDR >= 0.5 and not (arena1.immuneMagicEffects or arena1.ccRemains > 1) then 
--         if spell:Cast() then
--             alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear [" .. arena1.classString .. "]", spell.id)
--         end	 
--     elseif blink.MacrosQueued['fear arena2'] and arena2.distanceLiteral <= 8 and arena2.disorientDR >= 0.5 and not (arena2.immuneMagicEffects or arena2.ccRemains > 1) then 
--         if spell:Cast() then
--             alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear [" .. arena2.classString .. "]", spell.id)
--         end	 
--     elseif blink.MacrosQueued['fear arena3'] and arena3.distanceLiteral <= 8 and arena3.disorientDR >= 0.5 and not (arena3.immuneMagicEffects or arena3.ccRemains > 1) then 
--         if spell:Cast() then
--             alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear [" .. arena3.classString .. "]", spell.id)
--         end	 
--     elseif blink.MacrosQueued['fear enemyhealer'] and enemyhealer.distanceLiteral <= 8 and enemyhealer.disorientDR >= 0.5 and not (enemyhealer.immuneMagicEffects or enemyhealer.ccRemains > 1) then 
--         if spell:Cast() then
--             alert("|cFFf7f25c[Manual]: |cFFFFFFFFFear [" .. enemyhealer.classString .. "]", spell.id)
--         end	  
--     end
-- end)

local incomingcc = {
  "Sleep Walk",
  "Polymorph",
  "Repentance",
  "Hex",
  "Fear",
  "Uber Strike",
}

function Drinking()
    if player.buff("Refreshment") 
    or player.buff("Drink") then
        return true
    else
        return false
    end
end

function HoldingGCD()
    blink.enemies.loop(function(enemy)
        if enemy.casting 
        and tContains(incomingcc, enemy.casting) 
        and enemy.castTarget.isUnit(player) 
        and death.cd - blink.gcdRemains <= 1 then
            return true
        else
            return false
        end
    end)
end

---Death
local breakableCCSpells = { 
  --------- Sheeps--------------
  --[167385] = true,
  [118] = function() return player.idr >= 0.5 end,
  [161355] = function() return player.idr >= 0.5 end,
  [161354] = function() return player.idr >= 0.5 end,
  [161353] = function() return player.idr >= 0.5 end,
  [126819] = function() return player.idr >= 0.5 end,
  [61780] = function() return player.idr >= 0.5 end,
  [161372] = function() return player.idr >= 0.5 end,
  [61721] = function() return player.idr >= 0.5 end,
  [61305] = function() return player.idr >= 0.5 end,
  [28272] = function() return player.idr >= 0.5 end,
  [28271] = function() return player.idr >= 0.5 end,
  [277792] = function() return player.idr >= 0.5 end,
  [277787] = function() return player.idr >= 0.5 end,
  [391622] = function() return player.idr >= 0.5 end,
  [360806] = function() return player.idr >= 0.5 end,
  -- repentance
  [20066] = function() return player.idr >= 0.5 end,
  [118] = function() return player.idr >= 0.5 end,
  -- fear
  [5782] = function() return player.ddr >= 0.5 end,
  [65809] = function() return player.ddr >= 0.5 end,
  [342914] = function() return player.ddr >= 0.5 end,
  [251419] = function() return player.ddr >= 0.5 end,
  [118699] = function() return player.ddr >= 0.5 end,
  [30530] = function() return player.ddr >= 0.5 end,
  [221424] = function() return player.ddr >= 0.5 end,
  [41150] = function() return player.ddr >= 0.5 end,
  -- hex
  [51514] = function() return player.idr >= 0.5 end,
  [211015] = function() return player.idr >= 0.5 end,
  [211010] = function() return player.idr >= 0.5 end,
  [211004] = function() return player.idr >= 0.5 end,
  [210873] = function() return player.idr >= 0.5 end,
  [269352] = function() return player.idr >= 0.5 end,
  [277778] = function() return player.idr >= 0.5 end,
  [277784] = function() return player.idr >= 0.5 end,
  [309328] = function() return player.idr >= 0.5 end,
  [118] = function() return player.idr >= 0.5 end,
  [161355] = function() return player.idr >= 0.5 end, 
  [161354] = function() return player.idr >= 0.5 end,
  [161353] = function() return player.idr >= 0.5 end,
  [126819] = function() return player.idr >= 0.5 end,
  [61780] = function() return player.idr >= 0.5 end,
  [161372] = function() return player.idr >= 0.5 end,
  [61721] = function() return player.idr >= 0.5 end,
  [61305] = function() return player.idr >= 0.5 end,
  [28272] = function() return player.idr >= 0.5 end,
  [28271] = function() return player.idr >= 0.5 end,
  [277792] = function() return player.idr >= 0.5 end,
  [277787] = function() return player.idr >= 0.5 end,
  [391622] = function() return player.idr >= 0.5 end,
  -- sleep walk
  [360806] = function() return player.ddr >= 0.5 end,
}

local fadeIncomingCC = {
  -- repentance
  [20066] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,
  -- glacial
  [199786] = function() 
    return sr.lowest(blink.fgroup) <= 85
  end,
  -- clone
  [33786] = function(source)
    return (source.castTarget.isUnit(player) and player.ddr >= 0.5)
  end,
  -- fear
  [5782] = function(source)
    return (source.castTarget.isUnit(player) and player.ddr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,
  -- chaos bolt
  [116858] = function(source)
    return source.cds or sr.lowest(blink.fgroup) <= 85
  end,
  -- sleep walk
  [5782] = function(source)
    return (source.castTarget.isUnit(player) and player.disorientDR >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,
  -- hex ( start of hexes )
  [277784] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,
  [309328] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [269352] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [289419] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [211004] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [51514] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [210873] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [211015] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [219215] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [277778] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [17172] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [66054] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [11641] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [271930] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [270492] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [18503] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,

  [289419] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end,
  --end of hexes
}

-- sheeps
for _, sheep in ipairs(blink.spells.sheeps) do 
  fadeIncomingCC[sheep] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) and not death:Castable(source) or blink.gcdRemains > 0
  end
end

fade:Callback("cc", function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(408557) then return end

  blink.enemies.loop(function(enemy)
    local cast = enemy.castID
    if not cast then return end
    if not fadeIncomingCC[cast] or not fadeIncomingCC[cast](enemy) then return end

    -- Correctly get the spell name using the cast ID
    local thing = C_Spell.GetSpellInfo(cast).name

    if enemy.castTarget.isUnit(player)  
    and (enemy.castPct > (math.random(85,90)) + blink.buffer)
    and enemy.losOf(player) then
        return spell:Cast({castableWhileChanneling = true, castableWhileCasting = true}) and blink.alert("Fade [ " .. colors.red .. thing .. " ]", spell.id)
    end

  end)

end)

fade:Callback("emergency", function(spell)

  if not player.hastalent(373446) then return end

  local count, _, _, cds = player.v2attackers()

  local threshold = 17
  threshold = threshold + bin(player.hpa) * 6
  threshold = threshold + count * 9
  threshold = threshold + cds * 12

  if player.hpa > threshold then return end

  if player.hpa < threshold
  and count >= 1 then
    return spell:Cast(player) and alert("Fade " .. colors.red.."[Danger]", spell.id)
  end

end)

fade:Callback("phantasm", function(spell)

    if not player.hastalent(108942) then return end

    if player.hp > 70 
    and player.rooted then
        return spell:Cast(player) and alert("Fade " .. colors.red.."[Root]", spell.id)
    end

end)

fade:Callback("prediction", function(spell)

  local predictIncomingCC = {
    ["PRIEST"] = { 
      condition = function(obj)
        local movingToward = obj.movingToward(player, { duration = 0.25 })
        local predictDistance = obj.predictDistanceTo(player, 0.3) < 9
        local losOf = obj.losOf(player)
        local drCheck = (player.ddr == 1 or player.ddrr <= 4.5)
        sr.debugPrint("Priest movingToward:", movingToward, "predictDistance:", predictDistance, "losOf:", losOf, "DR Check:", drCheck)
        return drCheck and movingToward and predictDistance and losOf
      end,
      alert = blink.colors.priest .. "Priest Fear" 
    },
    ["PALADIN"] = {
      condition = function(obj)
        local movingToward = obj.movingToward(player, { duration = 0.25 })
        local predictDistance = obj.predictDistanceTo(player, 0.3) < 11
        local losOf = obj.losOf(player)
        local drCheck = (player.sdr == 1 or player.sdrr <= 4.5 or player.ddr == 1 or player.ddrr <= 4.5)
        sr.debugPrint("Paladin movingToward:", movingToward, "predictDistance:", predictDistance, "losOf:", losOf, "DR Check:", drCheck)
        return drCheck and movingToward and predictDistance and losOf
      end,
      alert = blink.colors.paladin .. "Paladin Hoj"
    },
    ["ROGUE"] = {
      condition = function(obj)
        local movingToward = obj.movingToward(player, { duration = 0.25 })
        local predictDistance = obj.predictDistanceTo(player, 0.4) <= 40
        local losOf = obj.losOf(player)
        local drCheck = (player.ddr == 1 or player.ddrr <= 4.5)
        sr.debugPrint("Rogue predictDistance:", predictDistance, "losOf:", losOf, "DR Check:", drCheck)
        return drCheck and movingToward and predictDistance and losOf
      end,
      alert = blink.colors.rogue .. "Rogue Blind"
    },
  }

  local shouldPredict
  blink.enemies.loop(function(enemy)
    local class = enemy.class2
    if class and predictIncomingCC[class] then
      local found = predictIncomingCC[class]
      --sr.debugPrint("Checking conditions for class:", class)
      if found.condition(enemy) then
        shouldPredict = found.alert
        sr.debugPrint("Condition met for:", found.alert)
        return true -- Break the loop early if condition is met
      end
    end
  end)

  if shouldPredict and not player.immuneCC then
    if spell:Cast() then
      blink.alert("Fade " .. shouldPredict, spell.id)
      return true
    end
  end
end)



blink.onEvent(function(info, event, source, dest)
    if event ~= "SPELL_CAST_START" or event ~= "SPELL_CAST_SUCCESS" or event ~= "SPELL_CAST_FAILED" then return end
    local spellID, spellName, _, auraType = select(12, unpack(info))
    if event == "SPELL_CAST_START" and source.enemy and breakableCCSpells[spellID] then
        holdgcd = true
        deathtime, caster, deathid = blink.time, source, spellID
    end
    -- print(source.name, spellID, spells[spellID], source.casting)
    if source.enemy and dest.isUnit(player) and breakableCCSpells[spellID] then
        caster, holdgcd = source, source.casting5/2500
    end
end)
death:Callback("cc", function(spell)
    if player.hasTalent(408557) and fade.cd == 0 then return end
    if player.immuneCC then return end

    local holdGCD = false
    blink.enemies.loop(function(enemy)
        local cast = enemy.castID
        if not cast then return end
        local castName = enemy.casting
        if not enemy.castTarget.isUnit(player) then return end
        if not breakableCCSpells[cast] then return end
        if enemy.castTimeLeft < ((blink.buffer + blink.tickRate)*6) then
            if player.casting then
                blink.call("SpellStopCasting")
                blink.call("SpellStopCasting")
            elseif spell:Cast(enemy, { face = true, castableWhileChanneling = true, castableWhileCasting = true, }) then
                blink.alert("SW: Death " .. "|cFFf7f25c[" ..castName .. "]", cast)
            end
        else
            if player.castRemains > 0.1 then
                blink.call("SpellStopCasting")
                blink.call("SpellStopCasting")
            end
            if player.channelRemains > 0.1 then
                blink.call("SpellStopCasting")
                blink.call("SpellStopCasting")
            end
            -- should probs hold gcds if their remaining cast is less than a gcd or so
            if enemy.castTimeLeft <= blink.gcd + blink.buffer then 
              holdGCD = true
            end
        end
    end)
    return holdGCD
end)

death:Callback("anyone", function(spell, unit)

  blink.enemies.loop(function(enemy)

      if not enemy.isPlayer then return end
      if not enemy.los then return end
      if enemy.hp > 20 then return end
      if enemy.immuneMagicDamage then return end
      if enemy.bcc then return end

      if enemy.buffFrom({23920, 212295, 8178, 5384}) then return end

      if enemy.hp <= 20 
      and not enemy.immuneMagicDamage then
          blink.call("SpellStopCasting")
          blink.call("SpellStopCasting")
          return spell:Cast(enemy, {face = true}) and alert("Shadow Word: Death |cFFf7f25c[Execute]", spell.id)
      end

  end)

end)

local ThingsToDeath = {
    [187650] = function(spellID)
        return blink.missiles.find(function(obj) if obj.source.enemy and obj.spellId and obj.spellId == spellID then return true end end)
    end, -- Freezing Trap
}
function shouldDeath(unit)
	local time = blink.time
    local cast = unit.casting
    if cast then

        if not LetsDeathCC[cast] then return end

        if unit.castTarget.isUnit(player) then 
            local timeleft = unit.castTimeLeft
            --incapacitates
                
            if player.idrRemains <= unit.castTimeLeft then
                if timeleft <= blink.gcd + blink.buffer 
                and unit.los then
                    if unit.castTimeLeft <= blink.buffer then
                        return true
                    end
                    return false
                end
            end
            --disorients
            if cast ~= 33786 
            and player.disorientDR == 1 then
                if unit.castTimeLeft <= blink.gcd + blink.buffer 
                and unit.los then  
                    if unit.castTimeLeft <= blink.buffer then
                        return true
                    end
                    return false
                end
            end
        end
    end
    
end

local function shouldDeathTrap()
    --Ground traps
    local Trapz = blink.triggers.find(function(trigger) return trigger.id == 187651 end)

    if Trapz then
        if Trapz.dist < 3 
        and player.incapDR >= 0.5 then
            return true
        end
        return false
    end

    --flying traps
    for _, missile in ipairs(blink.missiles) do
        local id = missile.spellId
        if not id then return end
        local LetsDeath = ThingsToDeath[id]
        if not LetsDeath then return end
        local hx, hy, hz = missile.hx,missile.hy,missile.hz
        if player.distanceTo(hx, hy, hz) < 6
        and player.incapDR >= 0.5 then
            return true
        end
        return false
    end
end
death:Callback("trap", function(spell)
    if player.hasTalent(408557) and fade.cd == 0 then return end
    if player.immuneCC then return end
    -- traps
    blink.enemies.within(40).loop(function(enemy)
        --if not shouldDeath(enemy) then return end
        local DeathIt = shouldDeathTrap()
        if DeathIt == false then

            blink.alert("Holding GCD To Death",spell.id)

        elseif DeathIt == true then

            blink.call("SpellStopCasting")
            blink.call("SpellStopCasting")
            
            if spell:Cast(enemy, { face = true, castableWhileChanneling = true, castableWhileCasting = true, }) then
                alert("SW : Death [" .. colored("Freezing Trap ", colors.hunter) .. "]", spell.id)
            end
        end

    end)
end)

fade:Callback("trap", function(spell)
  if not player.hasTalent(408557) then return end
    
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

      if hitDistanceToPlayer < 10 then

        sr.debugPrint("Condition met! Performing action...")

        if spell:Cast({ castableWhileChanneling = true, castableWhileCasting = true }) then
          alert("Fade [" .. colored("Freezing Trap ", colors.hunter) .. "]", spell.id)
        end

      else
        sr.debugPrint("Condition not met.")
      end
    end
  end
end)

death:Callback("grip", function(spell)
    if player.hasTalent(408557) and fade.cd == 0 then return end
    if player.immuneCC then return end

    blink.enemies.loop(function(enemy)
        if not spell:Castable(enemy) then return end
        if player.debuffFrom({190925, 212331, 212353}) then
            blink.call("SpellStopCasting")
            blink.call("SpellStopCasting")
            if spell:Cast(enemy) then
                alert("SW : Death [" .. colored("Freezing Trap ", colors.hunter) .. "]", spell.id, true)
            end
        end
    end)
end)

fade:Callback("grip", function(spell)
  if player.immuneCC then return end

  blink.enemies.loop(function(enemy)
    if not spell:Castable(enemy) then return end
    if player.debuffFrom({190925, 212331, 212353}) then
      blink.call("SpellStopCasting")
      blink.call("SpellStopCasting")
      if spell:Cast(enemy, {castableWhileChanneling = true, castableWhileCasting = true}) then
        alert("Fade [" .. colored("Freezing Trap ", colors.hunter) .. "]", spell.id, true)
      end
    end
  end)
end)

fiend:Callback(function(spell)

  blink.enemies.loop(function(enemy)

    --if not enemy.isPlayer then return end
    if enemy.dist > 40 then return end
    if not enemy.los then return end
    if enemy.bcc then return end
    if enemy.immuneMagicDamage then return end    

    if blink.burst
    or (enemyHealer.ccRemains > 2.5 
    or not enemyHealer.exists and target.hp < 90) 
    and enemy.dist < 40 
    and enemy.v2attackers(true) >= 1 then
      return spell:Cast(enemy, {face = true})
    end

  end)

end)

local firstPrepTimer
fortitude:Callback(function(spell)
  if player.channeling or player.casting then return end
  --if player.mounted then return end
  if player.combat then firstPrepTimer = nil end
  if blink.arena then
    if blink.prep then
      firstPrepTimer = firstPrepTimer or blink.prepRemains
    end
    if firstPrepTimer and firstPrepTimer - blink.prepRemains > 5 then
      blink.fgroup.loop(function(member)
        --if member.faction ~= player.faction then return end
        if player.used(spell.id, 5) then return end
        if not member.dist or member.dist > 40 then return end
        if member.buffRemains(spell.id) > 5 then return end
        return spell:CastAlert()
      end)
    end
  else
    firstPrepTimer = nil
    if player.buffRemains(spell.id) < 5 then return spell:CastAlert() end
  end
end)

scream:Callback("cc healer", function(spell)

  --if not saved.fearHealer then return end
  local TremorUp = blink.totems.find(function(totem) return totem.enemy and totem.id == 5913 and totem.dist <= 30 end)
  if TremorUp then return end
  if not enemyHealer.exists then return end
  if enemyhealer.immuneMagicEffects then return end
  if enemyhealer.immuneCC then return end
  if enemyhealer.distanceLiteral > 8 then return end

  if enemyHealer.ddr >= 0.5 
  and enemyHealer.distanceLiteral < 8
  and sr.lowest(enemies) < 90
  and enemyHealer.ccRemains < blink.buffer + 0.5
  and not enemyHealer.isUnit(target)
  and not enemyHealer.debuff(203337) then
  --and enemyHealer.v2attackers(true) == 0 then
    local sac_up, sac_rem = false, 0
    for _, enemy in ipairs(blink.enemies) do 
      local buff,_,_,_,_,_,source = enemy.buff(6940)
      if not buff then
          buff,_,_,_,_,_,source = enemy.buff(199448)
      end
      if buff and source then
        local rem = max(enemy.buffRemains(6940), enemy.buffRemains(199448))
        if not sac_up and enemyHealer.isUnit(source) then
          sac_up = true
          sac_rem = rem  
        end
      end
    end

    if sac_rem < 1 
    and enemyHealer.distanceLiteral < 8 - blink.bin(enemyHealer.movingAwayFrom(player)) * 1 
    and enemyHealer.ccRemains < blink.buffer + 0.5 then
      return spell:Cast() and alert("Psychic Scream "..colors.cyan.."[Full]", spell.id)
    end

  end
end)

smite:Callback(function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end

  if not target.enemy then return end
  if target.immuneMagicDamage then return end
  if target.dist > 40 then return end
  if not target.los then return end
  if target.bcc then return end

  return spell:Cast(target)

end)  

smite:Callback("dmg", function(spell)
  --if sr.WasCasting[target.guid] then return end
  if player.lastcast == 585 then return end
  if not target.enemy then return end
  if not player.buffFrom({390706, 390705}) then return end
  if not spell.inRange(target) then return end
  if not target.los then return end
  
  return spell:Cast(target)

end)  


tendrils:Callback("CDs", function(spell, unit)
  if not player.hasTalent(spell.id) then return end
  if blink.prep then return end
  if target.exists and target.hp <= 20 then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local lowest = sr.lowest(blink.fgroup)

  blink.enemies.loop(function(enemy)

    if not enemy.exists 
    or not enemy.los 
    or not enemy.isPlayer then 
      return 
    end
    
    if enemy.immuneSlows 
    or enemy.distanceLiteral > 7
    or enemy.ccRemains > 1.5 
    or enemy.rootRemains > 1
    or enemy.role ~= "melee"
    or enemy.class2 == "DRUID" then 
      return 
    end

    if lowest <= 80 + bin(enemy.buffsFrom(BigDamageBuffs)) then
      if spell:Cast() then
        return alert("|cFFf7f25cVoid Tendrils " .. (enemyHealer.classString or ""), spell.id)
      end
    end

  end)	

end)	

tendrils:Callback("BM Pet", function(spell, unit)
  if not player.hasTalent(spell.id) then return end
  if blink.prep then return end
  if target.exists and target.hp <= 30 then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.pets.loop(function(pet)
    if not pet.enemy then return end
    if pet.distance > spell.range then return end
    if not pet.los then return end

    local dontUseIt = pet.immuneSlow or pet.slowed or pet.rooted or pet.ccRemains > 1.5 or pet.distanceLiteral > 7
    if dontUseIt then return end

    if pet.buff(186254)
    and pet.buffRemains(186254) > 4
    and player.combat then
      if spell:Cast() then 
        alert("|cFFf7f25cVoid Tendrils " ..  colors.pink ..(pet.name or "") .. "", spell.id)
      end
    end   
  end) 

end)

tendrils:Callback("badpostion", function(spell)
  if not player.hasTalent(spell.id) then return end
  if blink.prep then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if enemyHealer.class2 == "DRUID" then return end
  if not enemyHealer.los then return end
  if enemyHealer.rootRemains > 1 then return end
  if enemyHealer.distanceToLiteral(player) > 7 then return end

  if target.enemy 
  and enemyHealer.exists 
  and not enemyHealer.isUnit(target)
  and (not enemyHealer.losOf(target) or enemyHealer.distanceTo(target) > 40)
  and not enemyHealer.cc then

    if enemyHealer.bcc then return end

    if spell:Cast() then
      alert("|cFFf7f25cVoid Tendrils " .. (enemyHealer.classString or "") .. " [Bad Position] ", spell.id)
    end

  end
end)

priest.smite = smite
priest.fortitude = fortitude
priest.tendrils = tendrils
priest.scream = scream
priest.fiend = fiend
priest.death = death
priest.fade = fade
priest.deaths = deaths


