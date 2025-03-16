local Unlocker, blink, sr = ...
local bin, angles, min, max, cos, sin, inverse, sort = blink.bin, blink.AnglesBetween, min, max, math.cos, math.sin, blink.inverseAngle, table.sort
local hunter, bm, sv, mm = sr.hunter, sr.hunter.bm, sr.hunter.sv, sr.hunter.mm
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local arena1, arena2, arena3 = blink.arena1, blink.arena2, blink.arena3
local NS, events, cmd, colors, colored = blink.Spell, blink.events, sr.cmd, blink.colors, blink.colored
local UnlockerType = Unlocker.type
local onEvent, onUpdate = blink.addEventCallback, blink.addUpdateCallback
local state = sr.arenaState
local saved = sr.saved
local alert = blink.alert
local fhealer = blink.healer

if not hunter.ready then return end

local currentSpec = GetSpecialization()  

--reload when spec changed
blink.addEventCallback(function() blink.call("ReloadUI")
end, "ACTIVE_PLAYER_SPECIALIZATION_CHANGED")

hunter.print = function(str)
  print(colors.hunter .. "|cFFf7f25c[SadRotations]:|r " .. str)
end

hunter.print(colors.hunter .. "Core |cFFf7f25cLoaded")


blink.ttd_enabled = true



local shortalert = function(msg, txid)
  return alert({msg = msg, texture = txid, duration = 0.1})
end 

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local lastJump = 0
hooksecurefunc("JumpOrAscendStart", function()
  if not IsFalling() then
    lastJump = GetTime()
  end
end)

local function jumpApex(min, max)
  if player.rooted then return true end
  if not IsFalling() then
    blink.call("JumpOrAscendStart")
  elseif GetTime() - lastJump >= (min or 0.25) then
    return true
  end
end

local fireMageVictims = {}
local function recentlyAttackedByFireMage(unit)
  for i=#fireMageVictims,1,-1 do
    local victim = fireMageVictims[i]
    if blink.time - victim.time > 2 then
      tremove(fireMageVictims, i)
    end
  end

  for i=1,#fireMageVictims do
    local victim = fireMageVictims[i]
    if victim.object.isUnit(unit) then
      return true
    end
  end
end

local function insideEnemyMeteor(unit)
  -- 6211
  for _, trigger in ipairs(blink.areaTriggers) do
    if trigger.id == 6211 and trigger.distanceTo(unit) < 5.5 then
      return true
    end
  end
end

--! SPELLZ !--
local Scatter = NS(213691, { effect = "physical", cc = true, alwaysFace = true, ranged = true, ignoreMoving = true })
local fleshcraft = NS(324631)
local meld = NS(58984)
local countershot = NS(147362, { effect = "physical", ranged = true })
local camo = NS(199483)
local tartrap = NS(187698, { effect = "magic", facingNotRequired = true, slow = true, ignoreMoving = true })
local steeltrap = NS(162488, { effect = "physical", facingNotRequired = true, slow = true, ignoreMoving = true })
local bindingshot = NS(109248, { effect = "magic", ignoreFacing = true, ignoreMoving = true, diameter = 10, range = 30, movePredTime = blink.buffer, ignoreFriends = true })
local tranq = NS(19801, {ignoreUsable = true, ranged = true})
local wrath = NS(19574, {ignoreControl = true})
local flare = NS(1543)
local disengage = NS(781)
local harpoon = NS(190925, {ignoreGCD = true})
local intimidation = NS(19577, { damage = "physical", ignoreFacing = true, ignoreLoS = true })
local freedom = NS({ 53271, 272682 }, { ignoreFacing = true, ignoreGCD = true, heal = true, pet = true })
local turtle = NS(186265, { ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true })
local exhilaration = NS(109304, { heal = true })
local ChimaeralSting = NS(356719, { effect = "physical", ranged = true, targeted = true })
local concu = NS(5116, { effect = "physical", ranged = true, targeted = true, slow = true })
local kill = NS({ 320976, 53351, 466930 }, { ignoreChanneling = true, ranged = true, ignoreGCD = true, ignoreUsable = true})
local dash = NS(61684, { ignoreFacing = true, ignoreGCD = true, pet = true })
local spiritMend = NS({90361, 237586}, { ignoreFacing = true, ignoreGCD = true, heal = true, pet = true })
local blackArrow = NS(430703, { effect = "magic", ranged = true, targeted = true })
local trap = NS(187650, { effect = "magic", ignoreFacing = true, diameter = 6, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true })

local flayers_mark = 378770

local function isFreedomKnown()
  if IsSpellKnown(53271, true) then
    return true
  end
  return false
end

local dotDebuffs = {
  --Add other offensive debuffs?
  -- 208086, --clousus smash
  -- 321538, --clousus smash
  -- 191894, --crows
  -- 321538, --bloodshed

  1079,-- rip
  155722,-- rake
  391356, --tear
  34914,  -- VT
  316099, -- UA
  274838, -- frenzy
  274837, -- frenzy
  48181,  -- Haunt
  386997, -- soul rotate

}
local function dontScatter()
  if not saved.dontScatterDots then return false end
  local lowHPThreshold = 30 

  local dotGroupMate = blink.group.find(function(member)
    return (member.class2 == "PRIEST" and member.specId == 258) -- Shadow Priest
      or (member.class2 == "WARLOCK" and member.specId == 265) -- Affliction Warlock
      or (member.class2 == "DRUID" and member.specId == 103) -- Feral Druid
      or (member.class2 == "ROGUE" and member.specId == 259) -- Assassination Rogue
  end)

  if dotGroupMate then 
    local teamMateLow = blink.group.find(function(member)
      return member.hp <= lowHPThreshold
    end)

    local enemyDotted = blink.enemies.find(function(enemy)
      return enemy.debuffFrom(dotDebuffs)
    end)

    -- Avoid Scatter Shot if enemy is dotted or bleed, unless a teammate is critically low
    if enemyDotted and not teamMateLow then
      return true
    end
  end

  return false
end

-- disengage
blink.RegisterMacro("disengage forward", 1.25)
blink.RegisterMacro("disengage target", 1)
blink.RegisterMacro("disengage healer", 1)
blink.RegisterMacro("disengage focus", 1)
blink.RegisterMacro("disengage flow", 1)
blink.RegisterMacro("disengage flow2", 1)
blink.RegisterMacro("disengage trap", 1)
blink.RegisterMacro("disengage enemyhealer", 1)
--Macros
blink.RegisterMacro('burst', 5)
blink.RegisterMacro('pause', 1)
blink.RegisterMacro('pause 1', 1)
blink.RegisterMacro('pause 2', 2)
blink.RegisterMacro('pause 3', 3)
blink.RegisterMacro('pause 4', 4)
blink.RegisterMacro('pause 5', 5)
blink.RegisterMacro('trap focus', 2)
blink.RegisterMacro('trap arena1', 2)
blink.RegisterMacro('trap arena2', 2)
blink.RegisterMacro('trap arena3', 2)
blink.RegisterMacro('trap enemyhealer', 2)
blink.RegisterMacro('trap test', 2)
blink.RegisterMacro('stun target', 1.25)
blink.RegisterMacro('stun focus', 1.25)
blink.RegisterMacro('stun arena1', 1.25)
blink.RegisterMacro('stun arena2', 1.25)
blink.RegisterMacro('stun arena3', 1.25)
blink.RegisterMacro('stun enemyhealer', 1.25)
blink.RegisterMacro('scatter target', 1.25)
blink.RegisterMacro('scatter focus', 1.25)
blink.RegisterMacro('scatter arena1', 1.25)
blink.RegisterMacro('scatter arena2', 1.25)
blink.RegisterMacro('scatter arena3', 1.25)
blink.RegisterMacro('scatter enemyhealer', 1.25)
blink.RegisterMacro('ros healer', 3)
blink.RegisterMacro('ros dps', 3)
blink.RegisterMacro('free healer', 3)
blink.RegisterMacro('free dps', 3)
blink.RegisterMacro('free player', 3)
blink.RegisterMacro('binding target', 1.25)
blink.RegisterMacro('binding focus', 1.25)
blink.RegisterMacro('binding arena1', 1.25)
blink.RegisterMacro('binding arena2', 1.25)
blink.RegisterMacro('binding arena3', 1.25)
blink.RegisterMacro('binding enemyhealer', 1.25)
blink.RegisterMacro('arrow target', 1)
blink.RegisterMacro('pet back', 5)
blink.RegisterMacro('reset', 5)
-- blink.RegisterMacro('trap safe', 10)

function disengage:Maneuver(angle, message, min, max)
  if self:Castable() then
    local alreadyQueued 
    blink.pauseFacing = true
    if jumpApex(min, max) then
      if not self.performingManeuver then
        -- print(angle, inverse(player.movingDir))
        self.performingManeuver = true
        local rotation = tonumber(player.rotation)

        local postFaceCast = math.max(0, disengage.cd)
        local postCastTurn = blink.buffer + 0.15

        local totalDuration = postFaceCast + postCastTurn

        blink.controlFacing(totalDuration + 0.25)
        if not SpellIsTargeting() and not IsMouseButtonDown("LeftButton") and not IsMouseButtonDown("RightButton") then
          --CameraOrSelectOrMoveStart()
          blink.call("CameraOrSelectOrMoveStart")
          C_Timer.After(totalDuration + 0.25, function() 
            if not IsMouseButtonDown("LeftButton") then
              blink.call("CameraOrSelectOrMoveStop") --CameraOrSelectOrMoveStop()
            end
          end)
        end
        --get the history of the sticky target and update it
        C_Timer.After(0.5, function() 
          sr.analyzeStickyTargetHistory()
        end)
        C_Timer.After(0.7, function() 
          sr.updateStickyTarget()
        end)
        if message then
          blink.alert(message, self.id)
        end
        blink.FaceDirection(angle)
        if SetHeading then SetHeading(angle) end
        C_Timer.After(postFaceCast, function()
          sr.drawDisengage = angle
          blink.FaceDirection(angle)
          blink.call("TurnLeftStart")
          blink.call("TurnLeftStop")
          blink.pauseFacing = true
          if not alreadyQueued and self:Cast() then
            blink.FaceDirection(angle)
            blink.pauseFacing = true
            alreadyQueued = true
            C_Timer.After(postCastTurn, function() 
              blink.FaceDirection(rotation)
              blink.pauseFacing = true
              C_Timer.After(0.35, function() alreadyQueued = false self.performingManeuver = nil end)
            end)
          else
            C_Timer.After(0.35, function() self.performingManeuver = nil end)
          end
        end)
      end
    end
  end
end

function disengage:forward(min, max, manual)
  if manual and self.cd > 0.5 and self.cd < 15 then return alert({msg = "Waiting for cooldown", duration = 0.3, texture = self.id}) end
  local angle = inverse(player.rotation)
  return disengage:Maneuver(angle, "Disengage |cFF8be9f7Forward", min, max)
end

function disengage:movingDirection(backward, min, max, manual)
  if manual and self.cd > 0.5 and self.cd < 15 then return alert({msg = "Waiting for cooldown", duration = 0.3, texture = self.id}) end
  local angle = player.moving and inverse(player.movingDir) or backward and player.rotation or inverse(player.rotation)
  return disengage:Maneuver(angle, "Disengage |cFF8be9f7Flow", min, max)
end

function disengage:toUnit(unit, min, max, manual)
  if manual and self.cd > 0.5 and self.cd < 15 then return alert({msg = "Waiting for cooldown", duration = 0.3, texture = self.id}) end
  if not unit.visible then return not alert("Invalid disengage unit...", self.id) end
  local x,y,z = unit.position()
  if not x or not y or not z then return end
  local px,py,pz = player.position()
  local angle = angles(x,y,z,px,py,pz)
  return disengage:Maneuver(angle, "Disengage to " .. unit.classString, min, max)
end


function disengage:handler()
  local queued = blink.MacrosQueued
  if queued["disengage forward"] then 
    disengage:forward(nil, nil, true)
  elseif queued["disengage flow"] then
    disengage:movingDirection(nil, nil, nil, true)
  elseif queued["disengage flow2"] then
    disengage:movingDirection(true, nil, nil, true)
  elseif queued["disengage trap"] then
    disengage:toUnit(hunter.trapTarget, nil, nil, true)
  elseif queued["disengage target"] then
    disengage:toUnit(target, nil, nil, true)
  elseif queued["disengage focus"] then
    disengage:toUnit(focus, nil, nil, true)
  elseif queued["disengage healer"] then
    disengage:toUnit(healer, nil, nil, true)
  elseif queued["disengage enemyhealer"] or queued["disengage enemyHealer"] then
    disengage:toUnit(enemyHealer, nil, nil, true)
  end
end

dash:Callback("rooted", function(spell)
  if player.buff(199483) then return end
  if not target.exists then return end
  if not target.enemy then return end
  if target.dead then return end
  if pet.distanceToLiteral(target) < 39 then return end

  return spell:Cast()

end)

hunter.controllingPet = 0
hunter.petControlImportance = 0

-- lil helper functions

hunter.movePetToUnit = function(unit)

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

  return unit.classString and alert("Moving pet to " .. unit.classString) or alert("Moving Pet")
end

hunter.movePetToPosition = function(x,y,z)

  --if Unlocker.type == "daemonic" then return end
  if SpellIsTargeting() then return end
  -- player must be within 60y to move pet to position?
  if player.distanceToLiteral(x,y,z) > 60 then
    -- alert("Unable to move pet, too far")
    return false
  end

  PetMoveTo()
  Click(x,y,z)

  return true
  
end

--Slow By buff name table
local BigDamageBuffs =
{
  --Incarnation
  [102543] = function(source)
    return source.role == "melee" or source.role == "ranged"
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

-- ros

hunter.currentDangerousCasts = {}
hunter.holdingRoSAlert = false

local dangerDebuffs = {
  [167105]  = { min = 4, weight = 13 },      -- warbreaker
  [208086]  = { min = 4, weight = 13 },      -- smash
  [386276]  = { min = 6.5, weight = 15 },    -- bonedust brew
  [274838]  = { min = 4, weight = 7 },       -- frenzy 
  [274837]  = { min = 4, weight = 7 },       -- frenzy
  [363830]  = { min = 7.5, weight = 14 },    -- sickle
  [323673]  = { min = 3, weight = 7 },       -- games
  [375901]  = { min = 3, weight = 7 },       -- games
  [385408]  = { min = 7, weight = 8 },       -- sepsis
  [375939]  = { min = 7, weight = 8 },       -- sepsis2
  [79140]   = { min = 7, weight = 18 },      -- vendetta FIXME: ID FOR DF 360194
  [360194]   = { min = 7, weight = 16 },      -- Deathmark
  [206491]  = { min = 30, weight = 10 },     -- nemesis..?
  [376079]  = { weight = 11 },               -- spear of bastion 
}

local dangerousCasts = {
  -- mindgames
  [323673] = { weight = 17 }, 
  [375901] = { weight = 17 }, 
  -- Glacial Spike
  [199786] = { 
    weight = 12, 
    mod = function(obj, dest) 
      return 1 + bin(obj.castPct > 75) * 3 
    end 
  },
  -- chaos bolt / dark soul bolt (crits through ros sadge)
  -- [116858] = { 
  --   weight = 12, 
  --   mod = function(obj, dest) 
  --     return 1 + bin(obj.buff(113858)) * 3 
  --   end 
  -- },
  -- convoke (feral and boomert)
  [323764] = {
    weight = 16,
    mod = function(obj)
      return 1 + obj.channelRemains * 0.33
    end,
    dest = function(obj)
      if obj.melee then
        if obj.target.exists and obj.target.distanceTo(obj) < 7 then 
          return obj.target 
        else
          local _, _, around = blink.fullGroup.around(obj, 7.5)
          for _, friend in ipairs(around) do
            if obj.facing(friend) then
              return friend
            end
          end
        end
      else
        return obj.target
      end
    end
  },
  -- deathbolt
  [264106] = {
    weight = 12,
    mod = function(obj)
      -- rapid contagion 33% increase, but they're probably tryna do big dam
      -- dark soul is just haste increase but they probably used phantom/darkglare/all dots for this deathbolt..
      return 1 + bin(obj.buff(344566)) * 0.66 + bin(obj.buff(113860)) * 0.88
    end
  },
  -- rapid fire
  [257044] = {
    weight = 8,
    mod = function(obj)
      -- double tap rapid fire full channel biggg scary
      return (1 + bin(obj.buff(260402)) * 2) / max(0.1, 2 - obj.channelRemains)
    end
  },
  -- aimed shot
  [19434] = {
    weight = 9,
    mod = function(obj)
      -- double tap aimed shot essentially 2x dmg.. buuut trading cds and crits are scary etc etc
      return 1 + bin(obj.buff(260402)) * 2
    end
  },
  -- Evoker Disintegrate
  [356995] = {
    weight = 9,
    mod = function(obj)
      return 1 + obj.channelRemains * 0.33
    end
  },
}

local function dangerousCastsScan()
  hunter.currentDangerousCasts = {}
  for i=1,#blink.enemies do
    local enemy = blink.enemies[i]
    local cast = (enemy.castID or enemy.channelID)
    --if enemy.distance > 90 then return end
    if cast then
      local info = dangerousCasts[cast]
      if info then
        local type = enemy.castID and "cast" or "channel"
        if type ~= "cast" or enemy.castRemains <= blink.buffer then
          local mod = info.mod and info.mod(enemy) or 1
          local dest = info.dest and info.dest(enemy)
          local weight = info.weight * mod
          tinsert(hunter.currentDangerousCasts, {
            source = enemy,
            dest = dest or enemy.castTarget,
            weight = weight
          })
        end
      end
    end
  end
end

local ros = NS(53480, { 
  ignoreFacing = true,
  ignoreGCD = true,
  heal = true,
  pet = true
})

ros:CastCallback(function(spell)
  hunter.holdingRoSAlert = false
end)

function ros:combustTarget(unit)

  if not hunter.holdingRoSAlert then 
    alert({msg = "Holding |cFFfcd86aROS|r for |cFFff8336Combustion", texture = self.id, duration = 5})
    hunter.holdingRoSAlert = true
  end

  -- highly weighted by whether or not the unit is the one combust is being committed on
  local weight = 18
  if state.fireMage.buff(190319) then
    weight = weight + bin(recentlyAttackedByFireMage(unit)) * 32
    weight = weight + bin(insideEnemyMeteor(unit)) * 26
    weight = weight + bin(state.fireMage.target.isUnit(unit)) * 32
    weight = weight + bin(unit.stunned) * 18
  elseif state.fireMage.cooldown(190319) > 95 then
    return self:threshold(unit, true)
  end

  return weight

end

function ros:threshold(unit, bypass)
  
  -- fire mage exists? only ros on combust.
  if not bypass and state.fireMage then return ros:combustTarget(unit) end

  -- modifiers by units on the unit
  local total, _, _, cds = unit.v2attackers()

  -- the hunt flying
  local theHuntWeight = 0
  local huntEvent = events.huntCast
  if huntEvent then
    local event = huntEvent
    local source, dest, happened = event.source, event.dest, event.time
    local time = blink.time
    if time - happened <= 2.25
    and source.exists 
    and source.enemy
    and source.speed > 45
    and dest.isUnit(unit)
    and source.distanceTo(dest) > 8 then
      theHuntWeight = theHuntWeight + 50
    end
  end

  -- debuffs that mean big dam' be comin'
  local debuffWeights = 0
  local hasDebuffs = unit.debuffFrom(dangerDebuffs)
  if hasDebuffs then 
    for _, id in ipairs(hasDebuffs) do 
      debuffWeights = debuffWeights + dangerDebuffs[id].weight 
    end 
  end

  -- dangerous casts or channels currently happening
  local dangerousCastsWeight = 0
  for _, cast in ipairs(hunter.currentDangerousCasts) do 
    if cast.dest.isUnit(unit) then
      dangerousCastsWeight = dangerousCastsWeight + cast.weight
    end
  end

  -- bit 'o weight for them committing a stun to their target
  local stunWeight = unit.stunned and 10 or 0

  local threshold = 28 + debuffWeights / 2 + dangerousCastsWeight

  threshold = threshold + total * (10 + debuffWeights / 2.5 + stunWeight / 2 + dangerousCastsWeight / 2.5)
  threshold = threshold + cds * (17 + debuffWeights + stunWeight + dangerousCastsWeight / 2)

  -- slight multiplicative mod for no heals, mitigation more important
  threshold = threshold * 1 + bin(not healer.exists or not healer.los or healer.ccr > 2) * 0.1

  return threshold

end

ros:Callback(function(spell, info)

  if not player.hasTalent(spell.id) then return end
  --lone wolf
  if player.buff(164273) then return end

  -- scan for any dangerous casts
  dangerousCastsScan()

  local pet_dead = pet.dead
  local pet_in_cc = pet.cc
  local pet_rooted = pet.rooted
  local pet_slowed = pet.slowed

  -- ros any member who meets complex weighted hp threshold
  blink.fullGroup.sort(function(x,y) return x.hp < y.hp end)
  blink.fgroup.loop(function(member)
    if not member.dead and member.dist < 50 and member.hp <= ros:threshold(member) then
      local pet_out_of_range = pet_rooted and not pet.meleeRangeOf(member) or pet.distanceTo(member) > 30
      -- get pet to unit
      if pet_in_cc then
        if pet_in_cc 
        or pet_rooted 
        and player.spec == "Beast Mastery" 
        and sr.hunter.bm.wrath.cd - blink.gcdRemains == 0 then
          if not sr.hunter.bm.wrath.known then return end
          if sr.hunter.bm.wrath:Cast({ignoreControl = true}) then alert("Bestial Wrath to |cFFfcd86aROS|r, |cFFfa9f28( Pet in CC )", actor.wrath.id) end
        else
          shortalert("Can't |cFFfcd86aROS|r, |cFFfa9f28( Pet is in CC )", spell.id)
        end
      elseif pet_out_of_range then
        if pet_slowed then
          dash:Cast()
        elseif pet_rooted then
          if freedom.cd == 0 then 
            local isFightingBoomkin = blink.fighting(102, true)
            if isFreedomKnown() and not isFightingBoomkin then 
              freedom:Cast(member)
            end
          else
            shortalert("|cFFfcd86aROS|r Alert: |cFFfa9f28( Pet Stuck Out of Range )", spell.id)
          end
        end
        if hunter.movePetToUnit(member) then
          hunter.controllingPet = blink.time
          hunter.petControlImportance = 5
        end
      end

      -- get player to unit.. out of LoS or > 40y cannot ros
      if not member.los then
        -- disengage into los!?
        shortalert("Can't |cFFfcd86aROS|r, |cFFfa9f28Out of LoS", spell.id)
      elseif member.distance > 40 then
        shortalert("Can't |cFFfcd86aROS|r " ..member.classString.. " |cFFfa9f28( Out of Range )", spell.id)
      end

      --turtle
      if member.buff(186265) then return end  
      --bear wall
      if member.buff(388035) and member.hpa > 30 then return end
      --pet wall fittest
      if member.buff(264735) then return end
      
      if member.hp > ros:threshold(member) then return end  

      if member.hp <= ros:threshold(member) then
        return spell:Cast(member) and alert("Roar of Sac " .. member.classString, spell.id)
      end

    end
  end)

  -- -- ros any member who meets complex weighted hp threshold
  -- blink.fullGroup.sort(function(x,y) return x.hp < y.hp end)
  -- for _, member in ipairs(blink.fullGroup) do

  --   if member.hp <= ros:threshold(member) then
  --     return spell:Cast(member) and alert("Roar of Sac " .. member.classString, spell.id)
  --   end

  -- end

end)

--ROS Friendly Healer/dps By Command
ros:Callback("command", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  if blink.MacrosQueued["ros healer"] then
    if healer.exists and not healer.debuffFrom({217832, 33786}) then
      if spell:Cast(healer) then
        blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFRoar of Sacrifice! |cFFf7f25c("..healer.classString..")", spell.id)
        return
      end
    else
      blink.alert("|cFFf7f25c[Check]: |cFFf74a4aNo Friendly Healer Exists", spell.id)
    end
  end

  if blink.MacrosQueued["ros dps"] then
    local fdps = blink.group.within(spell.range).find(function(member)
      return (member.role == "melee" or member.role == "ranged") and not member.isHealer
    end)

    if fdps and not fdps.debuffFrom({217832, 33786}) then
      if spell:Cast(fdps) then
        blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFRoar of Sacrifice! |cFFf7f25c("..fdps.classString..")", spell.id)
        return
      end
    elseif not fdps or not fdps.exists then
      blink.alert("|cFFf7f25c[Check]: |cFFf74a4aNo Friendly DPS Exists", spell.id)
    end
  end
end)


local SOTF = NS(264735, { 
  ignoreFacing = true,
  ignoreGCD = true,
  ignoreMoving = true,
  ignoreCasting = true,
  heal = true
})

function SOTF:threshold(player, bypass)

  -- modifiers by players on the player
  local total, _, _, cds = player.v2attackers()

  -- the hunt flying
  local theHuntWeight = 0
  local huntEvent = events.huntCast
  if huntEvent then
    local event = huntEvent
    local source, dest, happened = event.source, event.dest, event.time
    local time = blink.time
    if time - happened <= 2.25
    and source.exists 
    and source.enemy 
    and source.speed > 45
    and dest.isUnit(player)
    and source.distanceTo(dest) > 8 then
      theHuntWeight = theHuntWeight + 50
    end
  end

  -- debuffs that mean big dam' be comin'
  local debuffWeights = 0
  local hasDebuffs = player.debuffFrom(dangerDebuffs)
  if hasDebuffs then 
    for _, id in ipairs(hasDebuffs) do 
      debuffWeights = debuffWeights + dangerDebuffs[id].weight 
    end 
  end

  -- dangerous casts or channels currently happening
  local dangerousCastsWeight = 0
  for _, cast in ipairs(hunter.currentDangerousCasts) do 
    if cast.dest.isUnit(player) then
      dangerousCastsWeight = dangerousCastsWeight + cast.weight
    end
  end

  -- bit 'o weight for them committing a stun to their target
  local stunWeight = player.stunned and 10 or 0

  local threshold = 28 + debuffWeights / 2 + dangerousCastsWeight

  threshold = threshold + total * (10 + debuffWeights / 2.5 + stunWeight / 2 + dangerousCastsWeight / 2.5)
  threshold = threshold + cds * (17 + debuffWeights + stunWeight + dangerousCastsWeight / 2)

  -- slight multiplicative mod for no heals, mitigation more important
  threshold = threshold * 1 + bin(not healer.exists or healer.ccr > 2) * 0.1

  return threshold

end
  
SOTF:Callback(function(spell, info)
  if player.buff(spell.id) then return end
  if not player.hasTalent(264735) then return end
  if not saved.AutoSOTF then return end
  -- scan for any dangerous casts
  dangerousCastsScan()

  --turtle
  if player.buff(186265) then return end  

  if player.hp > SOTF:threshold(player) then return end

  if player.hp <= SOTF:threshold(player) then
    return spell:Cast(player) and alert("Survival of the Fittest ", spell.id)
  end

end)


freedom:Callback("ros", function(spell)
  if not isFreedomKnown() then return end

end)

freedom:Callback("friendly melee", function(spell)
  if not isFreedomKnown() then return end
end)

freedom:Callback(function(spell)
  local count, melee, ranged, cds = player.v2attackers()
  local threshold = 17
  threshold = threshold + bin(player.speed2 <= 4 and player.moving) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  if player.stealthed 
  or saved.freedomUnit == "none" 
  or freedom.cd > 0 
  or not isFreedomKnown() 
  or not pet.exists then
    return
  end

  local isFightingBoomkin = blink.fighting(102, true)

  -- Handle healer under Solar Beam
  if isFightingBoomkin 
  and healer.exists
  and healer.debuff(81261) 
  and healer.rooted 
  and healer.class2 ~= "DRUID" then
    sr.actionDelay(function()
      if healer.rooted then
        return spell:Cast(healer) and alert("Master's Call |cFFf7f25c(Solar Beam) " .. healer.classString, spell.id)
      end
    end)
  end

  if isFightingBoomkin then return end

  -- Selfish mode logic
  if saved.freedomUnit == "selfish" then
    if count > 0 and melee > 0 
    and (player.slowed or player.rooted) 
    and threshold > 25 
    and freedom:Castable(player) then
      sr.actionDelay(function()
        if player.rooted or player.slowed then
          return spell:Cast(player) and alert("Master's Call |cFFf7f25c(Selfish)", spell.id)
        end
      end)
    end
  end

  if pet.rooted and saved.freedomUnit ~= "none" then
    local petTarget = blink.fgroup.find(function(member) 
      return member.losOf(pet) 
    end) or player

    if freedom:Castable(petTarget) then
      sr.actionDelay(function()
        return spell:Cast(petTarget) and alert("Master's Call |cFFf7f25c(Free Pet)", spell.id)
      end)
    end
  end

  if saved.freedomUnit ~= "allTeam" then return end

  blink.fgroup.sort(function(x, y)
    return (x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2)
    or (x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp)
  end)

  -- Loop through friendly group members
  blink.fgroup.loop(function(member)
    if member.stunned 
    or member.debuffFrom({217832, 33786}) -- Imprison, Cyclone
    or member.buffFrom({54216, 1044, 305395}) -- Master's Call, Freedom buffs
    or not freedom:Castable(member) then
      return
    end

    local weight = 0

    if member.rootRemains > 1 
    or (member.speed2 <= 4 and member.moving and member.distanceTo(target) > 15) then
      if member.isMelee then
        weight = weight + 2
      elseif member.isRanged or member.isHealer then
        weight = weight + 1
      end
    end

    local isBeingAttackedByMelee = blink.enemies.find(function(enemy)
      return enemy.isPlayer and enemy.role == "melee" and enemy.distanceTo(member) <= 10
    end)

    if isBeingAttackedByMelee then
      weight = weight + 1
    end

    if weight > 0 and member.losOf(pet) and member.class2 ~= "DRUID" then
      sr.actionDelay(function()
        return spell:Cast(member) and alert("Master's Call |cFFf7f25c" .. member.classString, spell.id)
      end)
    end
  end)
end)


-- freedom:Callback(function(spell)
--   --if not blink.arena then return end
--   if not saved.autofreedom then return end
--   if freedom.cd > 0 then return end
--   if not isFreedomKnown() then return end

--   blink.fgroup.sort(function(x,y) return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp end)
--   blink.fgroup.loop(function(member)

--     if member.stunned then return end
--     if member.debuffFrom({217832, 33786}) then return end
--     if member.buffFrom({54216, 1044, 305395}) then return end

--     if member.slowed 
--     and member.attackers2 > 0 
--     and member.hp <= 70 then

--       if blink.fighting(102, true) then return end
        
--       if spell:Cast(member) then
--         return spell:Cast(member) and alert("Master's Call " .. member.classString, spell.id)
--       end
--     elseif member.isHealer and member.rooted and member.debuff("Solar Beam") then
--       return spell:Cast(member) and alert("Master's Call - [Solar Beam]" .. member.classString, spell.id) 
--     end		
--   end)

-- end)

-- --Freedome Friendly Healer By Command
freedom:Callback("command", function(spell)
  if not isFreedomKnown() then return end

  if blink.MacrosQueued["free player"] then
    if not player.debuffFrom({217832, 33786}) then 
      if not player.buffFrom({54216, 1044}) then
        if spell:Cast(player) then
          blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaster's call |cFFf7f25c("..player.name ..")", spell.id)
        end	
      end
    end
  end

  local fdps = blink.group.find(function(member) return member.role == "melee" or member.role == "ranged" and member.losOf(pet) end)

	if blink.MacrosQueued["free healer"] then
    
    if healer.exists 
    and not healer.debuffFrom({217832, 33786}) then 
      if not healer.buffFrom({54216, 1044}) then
        if spell:Cast(healer) then
          blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaster's call |cFFf7f25c("..healer.name ..")", spell.id)
        end	
      end
    end
    
  elseif blink.MacrosQueued["free dps"] then
    if fdps
    and not fdps.isHealer
    and not fdps.debuffFrom({217832, 33786}) then
      if not (fdps.buff(54216) or fdps.buff(1044)) then
        if spell:Cast(fdps) then
          blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaster's call |cFFf7f25c("..fdps.name ..")", spell.id)
        end	
      end	
    end
	end
end)

-- freedom:Callback("helpfear", function(spell)
--   if not saved.autofreedom then return end
--   if freedom.cd > 0 then return end
--   if not isFreedomKnown() then return end

--   local fhealer = blink.healer

--   if enemyHealer.exists and not enemyHealer.isUnit(target) then
--     local ccHelpByClass = {
--       ["PRIEST"] = { 
--           condition = function(obj) return (enemyHealer.ddr == 1 or enemyHealer.ddrr <= 4.5) and obj.movingToward(enemyHealer, { duration = 0.25 }) end,
--           alert = " [Help Priest Fear]" 
--       },
--     }

--     local shouldHelp
--     for _, member in ipairs(blink.group) do
--       local class = member.class2
--       if class then
--         local found = ccHelpByClass[class]
--         if found then
--           local condition = found.condition
--           if condition(member) then
--               shouldHelp = found.alert
--               break
--           end
--         end
--       end
--     end

--     if shouldHelp
--     and fhealer.slowed
--     and not fhealer.cc then
--       if spell:Cast(fhealer) then
--         blink.alert("Freedom " .. fhealer.class .. " |cFF6eff61" .. shouldHelp)
--         return true
--       end
--     end

--   end
-- end)


--fortitude of the bear tank pet
local fortitude = NS(388035, { 
  ignoreFacing = true,
  ignoreGCD = true,
  heal = true, 
  pet = true
})

fortitude:Callback(function(spell)
  
  if not player.buff(264662) then return end
  if not saved.AutoFortitude then return end

  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.stunned) * 5
  threshold = threshold + count * 9
  threshold = threshold + cds * 12

  threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.stunned) * 0.35)
  threshold = threshold * saved.FortitudeSensitivity

  if player.hpa > threshold then return end

  --turtle
  if player.buff(186265) and player.hpa > 12 then return end  
  --pet wall fittest
  if player.buff(264735) and player.hpa > 30 then return end

  if player.hpa <= threshold then
    return spell:Cast() and alert("Fortitude of the Bear "..colors.red.."[Danger]", spell.id)
  end

end)

hunter.fortitude = fortitude

--fortitude of the Marksmanship hunt
local MMfortitude = NS(392956, { 
  castById = true,
  ignoreFacing = true,
  ignoreGCD = true,
  heal = true
})

MMfortitude:Callback(function(spell)

  --lonewolf
  if not player.buff(164273) then return end
  if not saved.AutoFortitude then return end

  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.stunned) * 5
  threshold = threshold + count * 9
  threshold = threshold + cds * 12

  threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.stunned) * 0.35)
  threshold = threshold * saved.FortitudeSensitivity

  if player.hpa > threshold then return end

  --turtle
  if player.buff(186265) and player.hpa > 12 then return end  
  --pet wall fittest
  if player.buff(264735) and player.hpa > 30 then return end

  if player.hpa <= threshold then
    return spell:Cast() and alert("Fortitude of the Bear "..colors.red.."[Danger]-lone", spell.id)
  end

end)



-- cheetah
local cheetah = NS(186257)

cheetah:Callback("pursue trap", function(spell)
  return spell:Cast() and alert("Cheetah [Catch Trap]", spell.id)
end)

-- auto attack / pet attack
local attack = NS(6603)
local callpet = {

  --raptors
  NS(883), -- call pet by stable index
  NS(83242), 
  NS(83243),
  NS(83244),
  NS(83245),
}

function attack:start()
  if player.stealth then return end
  if not target.exists then return end
  return not self.current and blink.call("StartAttack", "Target")
end

function attack:stop()
  return self.current and StopAttack()
end

local modes = {
  PET_MODE_PASSIVE = "passive",
  PET_MODE_ASSIST = "assist",
  PET_MODE_DEFENSIVEASSIST = "defensive"
}
local function updatePetModes()
  local passiveIndex, growlIndex, dashIndex, spiritMendIndex
  local growlActive, dashActive, spiritMendActive
  local mode
  for i=1,10 do
    local name, id, _, token, _, active  = GetPetActionInfo(i)
    if id == 132270 then  -- Growl ID
      growlIndex = i
      growlActive = active
    elseif id == 132120 then  -- Dash ID
      dashIndex = i
      dashActive = active
    elseif id == 237586 then  -- Spirit Mend ID
      spiritMendIndex = i
      spiritMendActive = active
    else
      local alias = modes[name]
      if alias then
        if alias == "passive" then
          passiveIndex = i
        end
        if token then
          mode = alias
        end
      end
    end
  end

  if passiveIndex and mode ~= "passive" then
    -- Switch to Passive Mode
    PetPassiveMode()
    alert("Swapping pet to Passive mode", PET_PASSIVE_TEXTURE)
  end
  -- if saved.loadPve then
  --   if passiveIndex and mode == "passive" then
  --     -- Switch to Assist Mode
  --     --PetAssistMode()
  --     blink.call("PetAssistMode")
  --     alert("Swapping pet to Assist mode", PET_ASSIST_TEXTURE)
  --   end
  -- else

  --   if passiveIndex and mode ~= "passive" then
  --     -- Switch to Passive Mode
  --     PetPassiveMode()
  --     alert("Swapping pet to Passive mode", PET_PASSIVE_TEXTURE)
  --   end
  -- end

  if growlIndex and growlActive then
    -- Toggle Growl Autocast
    TogglePetAutocast(growlIndex)
    alert("Disabled Auto Growl", 2649)
  end

  -- Disable Dash Autocast if it's currently active
  if dashIndex and dashActive then
    TogglePetAutocast(dashIndex)
    alert("Disabled Auto Dash", 61684)
  end

  if spiritMendIndex and spiritMendActive then
    TogglePetAutocast(spiritMendIndex)
    alert("Disabled Auto Spirit Mend", 90361)
  end
end

C_Timer.After(2, updatePetModes)

hunter.petState = {
  mode = "passive",
}

function hunter:Attack()
  if target.dead then return end
  -- handle auto attacking
  if target.enemy and target.exists then
    if target.bcc then
      if currentSpec ~= 2 then 
        blink.call("SpellStopCasting")
        return
      end
      attack:stop()
    else
      attack:start()
    end
  end
  
end

local mark = NS(257284, {effect = "magic", ignoreFacing = true, ranged = true})

local stealthClasses = {
  ["ROGUE"] = true,
  ["HUNTER"] = true,
  ["DRUID"] = true,
}

mark:Callback("enemy detection", function(spell)
  if not saved.autoHunterMark then return end
  if not blink.arena then return end
  
  -- Warlock condition
  local LockMustCover = blink.fighting({265, 267}, true) and #blink.imps > 0 and not player.hasTalent(203340)
  
  -- Stealth detection
  local marked_unit
  local stealthies = {}
  
  blink.enemies.loop(function(enemy)
    if not enemy.isPlayer 
    or enemy.dist > spell.range 
    or not enemy.los 
    or enemy.immuneMagicEffects then
      return
    end

    -- Stealth unit handling
    local class = enemy.class2
    if stealthClasses[class] then
      stealthies[#stealthies + 1] = enemy
      if enemy.debuffRemains(spell.id) >= 6 then
        marked_unit = enemy
      end
    end
    
    -- Warlock cover
    if LockMustCover and enemyHealer.exists and enemyHealer.debuffRemains(spell.id) < 4 and enemyHealer.los then
      return spell:Cast(enemyHealer) and alert("Hunter's Mark ".. (enemyHealer.classString) .." |cFFf7f25c[Cover Trap]", spell.id)
    end
  end)
  
  -- If a stealth unit is already marked, no need to proceed further
  if marked_unit then return end
  
  -- Mark first unmarked stealth unit found
  for _, enemy in ipairs(stealthies) do
    if enemy.debuffRemains(spell.id) < 6 then
      return spell:Cast(enemy) and alert("Hunter's Mark " .. (enemy.classString or ""), spell.id)
    end
  end
end)


-- mark:Callback("cover trap", function(spell)
--   --undispellable
--   if player.hasTalent(203340) then return end
--   if not blink.arena then return end
--   blink.enemies.loop(function(enemy)

--     if not enemy.isPlayer then return end
--     if enemy.dist > 59 then return end
--     if not enemy.los then return end
--     if (enemyHealer.immuneMagicEffects or enemyHealer.immuneMagicDamage) then return end

--     local RetMustCover = blink.fighting(70, true)
--     local LockMustCover = blink.fighting({265, 267}, true)
      
--     --if not (RetMustCover or LockMustCover) then return end

--     --Ret Cover
--     -- if RetMustCover then
--     --   if enemyHealer.debuffRemains(spell.id) < 4 
--     --   and enemyHealer.los then

--     --     if saved.DebugMode then
--     --       blink.print("Casting: " .. spell.name .. " AT :" .. enemyHealer.name)
--     --     end

--     --     return spell:Cast(enemyHealer) and alert("Hunter's Mark ".. (enemyHealer.classString) .." |cFFf7f25c[Cover Trap]", spell.id)
--     --   end
--     -- end

--     --Warlock cover
--     if LockMustCover 
--     and #blink.imps then
--       if enemyHealer.debuffRemains(spell.id) < 4 
--       and enemyHealer.los then
--         return spell:Cast(enemyHealer) and alert("Hunter's Mark ".. (enemyHealer.classString) .." |cFFf7f25c[Cover Trap]", spell.id)
--       end
--     end
--   end)

-- end)

-- mark:Callback("stealth units", function(spell)

--   if enemyHealer.exists and enemyHealer.debuffRemains(spell.id) >= 6 then return end

--   local marked_unit
--   local stealthies = {}
--   blink.enemies.loop(function(enemy)
--     if not enemy.isPlayer then return end
--     if enemy.dist > 59 then return end
--     if (enemy.immuneMagicEffects or enemy.immuneMagicDamage) then return end

--     local class = enemy.class2
--     if class and stealthClasses[class] then
--       stealthies[#stealthies + 1] = enemy
--       if enemy.debuffRemains(spell.id) >= 6 then
--         marked_unit = enemy
--       end
--     end
--   end)

--   for _, enemy in ipairs(stealthies) do

--     if not marked_unit then
      
--       if enemy.dist > 59 then return end
--       if not enemy.isPlayer then return end
--       if (enemy.immuneMagicEffects or enemy.immuneMagicDamage) then return end

--       return spell:Cast(enemy) and alert("Hunter's Mark " .. (enemy.classString or ""), spell.id)
--     end

--   end

-- end)

-- mark:Callback("stealth units", function(spell)

--   if blink.arena and enemyHealer.debuffRemains(spell.id, "player") >= 6 then return end

--   local marked_unit
--   local stealthies = {}
--   for _, enemy in ipairs(enemies) do
--     local class = enemy.class2
--     if class and stealthClasses[class] then
--       stealthies[#stealthies + 1] = enemy
--       if enemy.debuffRemains(spell.id, "player") >= 6 then
--         marked_unit = enemy
--       end
--     end
--   end

--   for _, enemy in ipairs(stealthies) do
--     if not marked_unit then
--       if enemy.distanceLiteral > 40 then return end
--       if not enemy.los then return end
--       if not enemy.isPlayer then return end
--       if (enemy.immuneMagicEffects or enemy.immuneMagicDamage) then return end

--       if saved.DebugMode then
--         blink.print("stealth units/Casting: " .. spell.name .. " AT : " .. enemy.name)
--       end  
--       return spell:Cast(enemy) and alert("Hunter's Mark " .. (enemy.classString or ""), spell.id)

--     end
--   end

-- end)
local mendMePls = {
  [198909] = { uptime = 0.25, min = 2 },         -- monk khobaar
  [8122] = { uptime = 0.25, min = 2 },         -- Psychic Scream
  [112] = { uptime = 0.25, min = 2 }, -- Frost Nova
  [187650] = { uptime = 0.25, min = 2 }, -- Freezing Trap
  [3355] = { uptime = 0.25, min = 2 }, -- Freezing Trap
  [853] = { uptime = 0.25, min = 2 }, -- Hammer of Justice
  [179057] = { uptime = 0.25, min = 2 }, -- dh choas nova
  [20066] = { uptime = 0.15, min = 2 }, -- Repentance
  [77787] = { uptime = 0.15, min = 2 }, -- Hammer of Justice
  ------------- Sheeeps
  [118] = { uptime = 0.25, min = 2 },
  [161355] = { uptime = 0.25, min = 2 },
  [161354] = { uptime = 0.25, min = 2 },
  [161353] = { uptime = 0.25, min = 2 },
  [126819] = { uptime = 0.25, min = 2 },
  [61780] = { uptime = 0.25, min = 2 },
  [161372] = { uptime = 0.25, min = 2 },
  [61721] = { uptime = 0.25, min = 2 },
  [61305] = { uptime = 0.25, min = 2 },
  [28272] = { uptime = 0.25, min = 2 },
  [28271] = { uptime = 0.25, min = 2 },
  [277792] = { uptime = 0.25, min = 2 },
  [277787] = { uptime = 0.25, min = 2 },
  [391622] = { uptime = 0.25, min = 2 },
  ---------------------
  [360806] = { uptime = 0.25, min = 2 }, --- sleep walk
  ------------Fears 
  [5782] = { uptime = 0.25, min = 2 },
  [65809] = { uptime = 0.25, min = 2 },
  [342914] = { uptime = 0.25, min = 2 },
  [251419] = { uptime = 0.25, min = 2 },
  [118699] = { uptime = 0.25, min = 2 },
  [30530] = { uptime = 0.25, min = 2 },
  [221424] = { uptime = 0.25, min = 2 },
  [41150] = { uptime = 0.25, min = 2 },
  ------------------------
  [82691] = { uptime = 0.25, min = 2 },        --- ring of frost
  [64044] = { uptime = 0.25, min = 2 },         -- Psychic Horror (Stun)
  [105421] = { uptime = 0.25, min = 2 },         -- Blinding Light
  [6358] = { uptime = 0.25, min = 2 },         -- Seduction (Succubus)
  --------------- rooots 
  [339] = { uptime = 0.25, min = 2 },         ----entangling roots
  [339] = { uptime = 0.25, min = 2 }, -- Entangling Roots
  [235963] = { uptime = 0.25, min = 2 }, -- Entangling Roots
  [102359] = { uptime = 0.25, min = 2 }, -- Mass Entanglement
  [117526] = { uptime = 0.25, min = 2 }, -- Binding Shot
  [122] = { uptime = 0.25, min = 2 }, -- Frost Nova 
  [33395] = { uptime = 0.25, min = 2 }, -- Freeze
  [64695] = { uptime = 0.25, min = 2 }, -- Earthgrab
}

local res, mend = NS(982), NS(136, { heal = true, ignoreFacing = true })
res:Callback(function(spell)
  -- do some cool res logicz
  return spell:Cast() and alert("Revive Pet", spell.id)
end)

mend:Callback(function(spell)
  if pet.buff(spell.id) then return end
  if player.hasTalent(343242) and pet.debuffFrom({30108, 316099}) then return end
  if not pet.los then return end
  if not pet.exists then return end

  if not hunter.importantPause 
  and pet.hp <= 85 - bin(hunter.unimportantPause) * 25 - bin(healer.exists and not healer.cc) * 25 then

    if spell:Cast(pet) then
      alert("Mend Pet", spell.id)
      return
    end

  else

    if isFreedomKnown() and freedom.cd == 0 then return end
    if wrath.cd - blink.gcdRemains == 0 then return end

    if player.hasTalent(343242) 
    and pet.debuffFrom(mendMePls) then
      if spell:Cast(pet) then
        alert("Mend Pet - (Dispel)", spell.id)
        return
      end
    end

  end
end)
-- mend:Callback(function(spell)
--   --dont mend dispel talents -- on UA
--   if player.hasTalent(343242) and pet.debuff(316099) then return end
--   if pet.exists 
--   and not hunter.importantPause 
--   and pet.hp <= 85 - bin(hunter.unimportantPause) * 25 - bin(healer.exists and not healer.cc) * 25 then
--     return spell:Cast(pet) and alert("Mend Pet", spell.id)
--   end
-- end)

function hunter:PetFollow()
  if not self.followCommand then self.followCommand = blink.time end
  if blink.time - self.followCommand < 0.1 then return end

  blink.call("PetFollow")
  self.followCommand = blink.time
end

function hunter:PetAttack()
  if not target.enemy then return end
  if blink.MacrosQueued['stun focus'] then return end
  if player.buff(199483) then return end
  if not self.attackCommand then self.attackCommand = blink.time end
  if blink.time - self.attackCommand < 0.1 then return end
    
  if Unlocker.type == "daemonic" then 
    blink.call("PetAttack")
  else
    blink.call("PetAttack", "target") --PetAttack()
  end
  self.attackCommand = blink.time
end

function hunter:PetControl()
  if player.used(2641, 5) then return end
  local petIndex = tonumber(saved.CallPetMode:match("%d+"))
  -- call / res pet
  if saved.autocallpet and not pet.exists and not pet.dead then
    if not hunter.call_pet_attempted then
      if petIndex
      and player.castID ~= res.id 
      and callpet[petIndex]:Cast() then
        alert("Calling pet ", callpet[petIndex].id)
        hunter.call_pet_attempted = true
      end
    elseif player.castID ~= res.id then
      hunter.res_pet_attempted = true
      -- try to res pet
      res()
    end
  else
    hunter.call_pet_attempted = false
    if not hunter.res_pet_attempted and pet.dead then
      hunter.res_pet_attempted = true
      res()
    else 
      -- mend pet
      mend()
    end

    if not hunter.petState.externalControl 
    or blink.time - hunter.petState.externalControl > blink.tickRate * 3 then
      --! PROTECC !--
      --if target.exists then
        -- camo
        if player.buff(199483)
        -- bcc
        or target.bcc
        --pet back macro 
        or blink.MacrosQueued['pet back'] 
        or blink.MacrosQueued['reset']
        or pet.distance > 25 and spiritMend:Castable(player) and spiritMend.current
        -- thorns
        or target.exists and target.buffRemains(305497) > 2 and pet.hp < 50 then
          hunter:PetFollow()
          alert("Moving Pets back ..", callpet[petIndex].id) 
        else
          --! ATTACC !--
          if not saved.loadPve then
            hunter:PetAttack()
          elseif saved.loadPve and target.combat or target.isDummy then
            hunter:PetAttack()
          end
        end
      --end
    end

  end

end

hunter.reset = function()

  local feign = NS(5384, { mustBeGrounded = true })
  local Camouflage = NS(199483)
  --if feign.cd == 0 then
    attack:stop() 
    attack:stop()
    if pet.exists then
      hunter:PetFollow()
      hunter:PetFollow()
    end
    if feign:Cast({stopMoving = true}) then
      alert("Reset ..", feign.id)
    end

    if not player.combat then 
      Camouflage:Cast()
    end

    if player.buff(Camouflage.id) and pet.dead then
      if res() then
        blink.alert(colors.hunter .. "Stop moving trying to ress pet..", res.id, true)
      end
    end
  --end

end

--move Pet eat trap 
hunter.movePetToPosition = function(x,y,z)
  --if Unlocker.type == "daemonic" then return end

  -- player must be within 60y to move pet to position?
  if player.distanceToLiteral(x,y,z) > 60 then
    -- alert("Unable to move pet, too far")
    return false
  end

  PetMoveTo()
  Click(x,y,z)
  return true

end


function hunter:PetEatTrap()
  
  --if Unlocker.type == "daemonic" then return end
  if not healer.exists then return end  

  local enemyhunter = blink.enemies.find(function(obj) return obj.class2 == "HUNTER" end)
  --if enemyhunter.cooldown(187650) > 6 then return end

  if blink.arena 
  and enemyhunter 
  and enemyhunter.cooldown(187650) < 5 then

    local WillFollowTrap = healer.stunned or healer.debuff(213691)
    if not WillFollowTrap then return end

    local x,y,z = healer.position()
    local petDistance = pet.distanceToLiteral(x,y,z)

    --if pet.distanceToLiteral(x,y,z) > 10 then

    if dash:Cast() then blink.alert(colors.cyan .. "Pet Dash to Eat Trap [" .. healer.classString .. "]", dash.id) end
    --end

    if hunter.movePetToPosition(x,y,z) then
      return blink.alert(colors.cyan .. "Moving Pet to Eat Trap [" .. healer.classString .. "]")
    end

  end
end

function hunter:AntiPetTaunt()
  local tx,ty,tz = target.position()
  local px,py,pz = player.position()

  --Taunts
  if player.hasTalent(203340) then return end
  if not pet.debuffFrom({62124, 116189, 6795}) then return end
  if trap.cd - blink.gcdRemains > 1 then return end

  if target.exists 
  and target.enemy
  and target.los
  and pet.distanceToLiteral(tx,ty,tz) < 53 then 
    return hunter.movePetToPosition(tx,ty,tz) and blink.alert(colors.orange .. "Moving pets out [Taunted]")
  else
    return hunter.movePetToPosition(px,py,pz) and blink.alert(colors.orange .. "Moving pets out [Taunted]")
  end
end

-- local AoEDefensive = {
--   [196718] = {
--     name = "|cFFf74a4aDarkness",
--     diameter = 8,
--     id = 196718
--   }
-- }

-- -- knocktrap spell object
-- local knocktrap = NS(236776, {
--   effect = "magic",
--   diameter = 8
-- })

-- local function bcc(obj) return obj.bcc end

-- function hunter:KnockDefs()
--   blink.triggers.loop(function(trigger)

--     for _, enemy in ipairs(blink.enemies) do

--       local id = trigger.id

--       local AoEDefensive = AoEDefensive[id]

--       if not AoEDefensive then return end
--       if not id then return end
--       if enemy.distance > 35 then return end

--       if blink.enemies.around(enemy, 10, bcc) == 0 then 
--         if knocktrap:SmartAoE(enemy, { movePredTime = blink.buffer }) then 
--           blink.alert("Knock " .. AoEDefensive.name, AoEDefensive.id)
--         end
--       end

--     end

--   end)
-- end


-- constants 

-- acceptable overlap (adjust this based on other conditions bruh!)
local acceptable_overlap = 1
local necessary_overlap = 2

-- telegraph delay (time after telegraphing movement toward the healer to delay bait attempt)
local tDelay = {
  min = 600,
  max = 2400
}

-- commit delay (time after attempting bait to commit to the trap regardless of risk)
local cDelay = {
  min = 4850,
  max = 9200
}

local function couldKnowSpell(obj, id, reasonableTime)
  -- Default to 30 seconds if no reasonable time is specified
  reasonableTime = reasonableTime or 30
  local elapsed = state.elapsedCombat

  -- Check if the ability has been used within a specific timeframe
  if obj.used(id, elapsed + 69) then
    return true
  elseif elapsed > reasonableTime then
    return false
  else
    return true
  end
end 

-- local function canCuckTrap(obj, travel, ttu, actualObj)
--   local has = function(id) return obj.cooldown(id) <= travel and id or false end
--   local knows = function(id, t) return couldKnowSpell(obj, id, t) and id or false end

--   local SafeDist = player.distanceTo(obj) < 5
--   local KickedPriest = obj.lockouts.shadow and obj.lockouts.shadow.remains >= 1 and SafeDist
--   local KickedShammy = obj.lockouts.nature and obj.lockouts.nature.remains >= 1 and SafeDist
--   local inCamo = player.buff(199483) and SafeDist
--   local Silenced = obj.debuff(356727) and SafeDist

--   local class = obj.class2

--   if class == "SHAMAN" 
--   and not (KickedShammy or Silenced or inCamo) then
--     return (ttu or obj.distanceTo(actualObj) < 32) and knows(204336) and has(204336) or false

--   elseif class == "PRIEST" and ttu then
--     if not (KickedPriest or Silenced or inCamo) then
--       if has(586) then  -- Fade + Phase Shift
--         return 586
--       elseif obj.spec == "Holy" and knows(213610, 20) then  -- Holy Ward
--         return has(213610)
--       elseif not player.hasTalent(203340) then  -- Shadow Word: Death
--         return has(32379)
--       end
--     end

--   elseif class == "MONK" and ttu and not (KickedShammy or Silenced or inCamo) then
--     return has(119996) or knows(109132, 5) or knows(115008, 0) or false  -- Roll / Chi Torpedo

--   elseif class == "DRUID" and ttu and not (Silenced or inCamo) then
--     if SafeDist and not has(102417) then return false end
--     return has(102417) or knows(102417, 15) or false  -- Wild Charge

--   elseif class == "EVOKER" and ttu and not (KickedShammy or Silenced or inCamo) then
--     if SafeDist and not has(358267) then return false end
--     return has(358267) or knows(358267, 35) or false  -- Hover
--   end

--   return false  -- Default to not trapping if no conditions are met
-- end

--the old one
-- local function canCuckTrap(obj, travel, ttu, actualObj)
--   local has = function(id) return obj.cooldown(id) <= travel and id end
--   local knows = function(id, t) return couldKnowSpell(obj, id, t) end

--   local SafeDist = player.distanceTo(obj) < 5
--   local KickedPriest = obj.lockouts.shadow and obj.lockouts.shadow.remains >= 1 and SafeDist
--   local KickedShammy = obj.lockouts.nature and obj.lockouts.nature.remains >= 1 and SafeDist
--   local inCamo = player.buff(199483) and SafeDist
--   local Silenced = obj.debuff(356727) and SafeDist

--   local class = obj.class2

--   if class == "SHAMAN" 
--   and not (KickedShammy or Silenced or inCamo) then

--     return (ttu or obj.distanceTo(actualObj) < 32) and knows(204336) and has(204336)

--   elseif class == "PRIEST" and ttu then

--     if not (KickedPriest or Silenced or inCamo) then
--       if has(586) then  -- Fade + Phase Shift
--         return true
--       elseif obj.spec == "Holy" and knows(213610, 20) then  -- Holy Ward
--         return has(213610)
--       elseif not player.hasTalent(203340) then  -- Shadow Word: Death
--         return has(32379)
--       end
--     end

--   elseif class == "MONK" and ttu and not (KickedShammy or Silenced or inCamo) then
    
--     return has(119996) or  -- Transcendence: Transfer
--     knows(109132, 5) and has(109132) or  -- Roll
--     knows(115008, 0) and has(115008)  -- Chi Torpedo

--   elseif class == "DRUID" and ttu and not (Silenced or inCamo) then

--     if SafeDist and not has(102417) then return end
--     return has(102417) or knows(102417, 15) and has(102417)  -- Wild Charge

--   elseif class == "EVOKER" and ttu and not (KickedShammy or Silenced or inCamo) then

--     if SafeDist and not has(358267) then return end
--     return has(358267) or knows(358267, 35) and has(358267)  -- Hover
--   end

--   return false  -- Default to not trapping if no conditions are met
-- end

-- local function couldKnowSpell(obj, id, reasonableTime)
--   -- reasonable amount of time after first combat that they may not have used the ability for
--   reasonableTime = reasonableTime or 30
--   local elapsed = state.elapsedCombat

--   -- we know they've used it..
--   if obj.used(id, elapsed + 69) then return true end
--   -- they haven't used it within reasonable time, assume they don't 
--   if elapsed > reasonableTime then return false end
--   -- otherwise, always assume they have it.
--   return true

-- end 

-- ttu: trapping this unit
local canCuckTrap = function(obj, travel, ttu, actualObj)
  -- return id if off cd
  local has = function(id) return obj.cooldown(id) <= travel and id end
  local knows = function(id, t) return couldKnowSpell(obj, id, t) end

  local SafeDist = player.distanceTo(obj) < 5
  local KickedPriest = obj.lockouts.shadow and obj.lockouts.shadow.remains >= 1 and SafeDist
  local KickedShammy = obj.lockouts.nature and obj.lockouts.nature.remains >= 1 and SafeDist
  local inCamo = player.buff(199483) and player.distanceTo(obj) < 5
  local Silenced = obj.debuff(356727) and SafeDist
  local TravelForm = obj.buff(783)

  local class = obj.class2

  if class == "SHAMAN" then 
    -- grounding
    if KickedShammy or Silenced or inCamo then return end
    return (ttu or obj.distanceTo(actualObj) < 32) and knows(204336) and has(204336)
  end

  if class == "PRIEST" and ttu then 
      
    if not KickedPriest 
    or not Silenced
     or not inCamo then

      -- Fade + Phase Shift
      return has(586)
    end

    if not player.hasTalent(203340) then

      if KickedPriest or Silenced or inCamo then return end
      -- death
      return has(32379)

      -- holy club only
    else
      if obj.spec == "Holy" and knows(213610, 20) then
        -- holy ward
        return has(213610)
      end
    end
  end

  if class == "MONK" then
    if ttu then
      -- port
      if KickedShammy or Silenced or inCamo then return end
      return has(119996)
      -- roll
      or knows(109132, 5) and has(109132)
      -- chi torp
      or knows(115008, 0) and has(115008)
      -- 
    end
  end

  if class == "DRUID" then
    if ttu then
      -- WILD CHARGE
      if SafeDist and not has(102417) then return end
      if Silenced or inCamo then return end
      return has(102417) 
      or knows(102417, 15) and has(102417)
    end
  end

  if class == "EVOKER" then
    if ttu then
      -- Hover
      if KickedShammy or Silenced or inCamo then return end
      if SafeDist and not has(358267) then return end
      return has(358267) 
      or knows(358267, 35) and has(358267)
    end
  end

end

--! Aegis !--
local aegis = blink.Item(188775)
function aegis:danger()
  if healer.exists and not healer.cc and player.hp > 78 then return end
  if player.hp > 90 then return end
  return self:Use()
end

--! FEIGN / Aegis !--

local feign = NS(5384, { ignoreGCD = true, mustBeGrounded = true })

hunter.waitingForSpear = false
hunter.spearAlert = false

feign:HookCallback(function(spell)
  local exists = state.kyrianWarrior
  local waiting = exists and exists.cooldown(307865) <= spell.baseCD
  hunter.waitingForSpear = waiting
  if waiting and not hunter.spearAlert then 
    alert({msg = "Holding |cFF52fff6Feign|r for |cFFffce2eSpear of Bastion", texture = feign.id, duration = 5})
    hunter.spearAlert = true
  end
end)

feign:CastCallback(function(spell)
  hunter.spearAlert = false
end)

function feign:CastWhenPossible(callback)
  -- never when carrying flag
  if player.hasFlag then return end

  local attempts = 0
  if self.cd <= 0.5 then
    C_Timer.NewTicker(0.05, function(self)
      if feign:Cast({stopMoving = true}) then
        self:Cancel()
        return callback and callback()
      elseif attempts >= 15 then
        self:Cancel()
      else
        attempts = attempts + 1
      end
    end)
  end
end

feign:Callback("spear", function(spell)
  -- never when carrying flag
  if player.hasFlag then return end
    
  if player.debuff(376079) then
    return spell:Cast({stopMoving = true}) and alert("Feign Death (" .. colored("Spear", colors.cyan) .. ")", spell.id)
  end
end)

feign:Callback("the hunt", function(spell)

  -- never when carrying flag
  if player.hasFlag then return end

  local event = events.huntCast
  if not event then return end
  local source, dest, happened = event.source, event.dest, event.time
  local time = blink.time
  if time - happened > 2 then return end
  if not source.exists then return end
  if source.speed > 45 and dest.isUnit(player) and source.dist < 30 then 
    return spell:Cast({stopMoving = true}) and alert("Feign Death (" .. colored("The Hunt", colors.dh) .. ")", spell.id)
  end 

end)

local FDBigDam = {
  --Incarnation Ashame - Feral
  [102543] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player)
  end,
  --Incarnation Chosen - Boomkin
  [102560] = function(source)
    return source.role == "ranged" and source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,
  --wings
  [31884] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --wings
  [231895] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --doomwinds
  [384352] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Serenity
  [152173] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --boondust
  [386276] = function(source)
    return source.role == "melee" and source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --trueshot
  [288613] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Coordinated Assault
  [266779] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Coordinated Assault2
  [360952] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Shadow Dance
  [185422] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Shadow Blades
  [121471] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,  
  --Adrenaline Rush
  [13750] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,  
  --Combustion
  [190319] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end, 
  --Arcane Surge
  [365362] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,  
  --ele Primordial Wave
  [375986] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,  
  --Boomie
  [202425] = function(source)
    return source.target.isUnit(player) and player.hp <= 85 and source.losOf(player)
  end,  
  --Pillar of Frost
  [51271] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Unholy Assault
  [207289] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Metamorphosis
  [162264] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player)
  end,
  --Recklessness
  [1719] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --Avatar
  [107574] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
  --warbreaker
  [167105] = function(source)
    return source.target.isUnit(player) and source.meleeRangeOf(player) and player.hp <= 85 and source.losOf(player) and not source.disarmed
  end,
}

feign:Callback("CDs", function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end
  -- never when carrying flag
  if player.hasFlag then return end

  blink.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.los then return end
    if not enemy.target.isUnit(player) then return end
    if enemy.ccr and enemy.ccr > 1 then return end
    if not enemy.isPlayer then return end  

    local has = enemy.buffFrom(FDBigDam)

    if not has then return end
    local str = ""
    for i, id in ipairs(has) do
      if i == #has then
        str = str .. C_Spell.GetSpellInfo(id).name
      else
        str = str .. C_Spell.GetSpellInfo(id).name .. ","
      end
    end

    if has then
      return spell:Cast({stopMoving = true}) and blink.alert("Feign Death (" .. colors.red .. (str) .. "|r)", spell.id)
    end
    
  end)
end)

local recentDoubleTapAimed = 0
local recentDoubleTap = 0
-- on-damage feigns
feign:Callback("damage", function(spell)
  -- never when carrying flag
  if player.hasFlag then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(202746) then return end --survival tactics

  local time = blink.time

  -- pause for deadly casts
  blink.enemies.loop(function(enemy)
    local class = enemy.class2

    --Disc Ultimate Penitance
    if blink.fighting(256)
    and enemy.channelID == 421434
    and enemy.castTarget.isUnit(player) then
      if spell:Cast({stopMoving = true}) then
        alert("Feign Death (" .. colored("Ultimate Penitance", colors.priest) .. ")", spell.id)
      end
    end

    if class == "HUNTER" then
      local hasDoubleTap = enemy.buff(260402)
      
      -- aimed shot
      if enemy.castID == 19434 
      and enemy.buff(260402) 
      and enemy.castTarget.isUnit(player) 
      and enemy.los and enemy.castRemains <= (blink.gcd + blink.buffer) * 2 then
        recentDoubleTapAimed = time
        hunter.temporaryAlert = { msg = "Ready to Feign " .. colored("Double Tap Aimed Shot", colors.hunter), texture = spell.id }
      end

      -- rapid fire
      if enemy.channelID == 257044 
      and enemy.buff(260402) 
      and enemy.castTarget.isUnit(player) 
      and enemy.channelRemains >= 0.3 then
        if spell:Cast({stopMoving = true}) then
          alert("Feign Death (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", spell.id)
        end
      end

      --Sniper Shot
      if enemy.castID == 203155 
      and enemy.castTarget.isUnit(player) 
      and enemy.los and enemy.castRemains <= (blink.gcd + blink.buffer) * 2 then
        if spell:Cast({stopMoving = true}) then
          alert("Feign Death (" .. colored("Sniper Shot", colors.hunter) .. ")", spell.id)
        end
      end
    end

    -- Calculate the threshold for using Feign Death
    local threshold = 25

    -- Adjust threshold based on player's health percentage
    threshold = threshold - (player.hp * 0.5)

    -- Adjust threshold based on enemy's dangerous cooldowns
    threshold = threshold + (bin(enemy.cds) * 20)

    -- Adjust threshold based on healer's condition
    threshold = threshold + bin(not healer.exists or not healer.los or healer.cc) * 25

    if player.hp > threshold then return end

    if player.class == "EVOKER" 
    and enemy.role == "ranged"
    and enemy.castTarget.isUnit(player) then
      -- Handle Evoker Eruption
      if enemy.castID == 395160
      and enemy.los
      and enemy.castRemains <= (blink.gcd + blink.buffer) * 2 then

        if spell:Cast({stopMoving = true}) then
          alert("Feign Death (" .. colored("Eruption", colors.evoker) .. ")", spell.id)
        end

      elseif enemy.channelID == 356995 and enemy.castRemains <= (blink.gcd + blink.buffer) * 2 then

        if spell:Cast({stopMoving = true}) then
          alert("Feign Death (" .. colored("Disintegrate", colors.evoker) .. ")", spell.id)
        end

      end
    end

    --Evoker shit
    -- if class == "EVOKER" 
    -- and enemy.role == "ranged" then

    --   local threshold = 25
    --   threshold = threshold - bin(player.immuneMagicDamage) * 10
    --   threshold = threshold - bin(player.hp) * 10
    --   threshold = threshold + bin(not healer.exists or not healer.los or healer.cc) * 25

    --   if player.hp > threshold then return end
        
    --   --Evoker eruption
    --   if enemy.castID == 395160 
    --   and enemy.castTarget.isUnit(player) 
    --   and enemy.los and enemy.castRemains <= (blink.gcd + blink.buffer) * 2 then
    --     if spell:Cast({stopMoving = true}) then
    --       alert("Feign Death (" .. colored("Eruption", colors.evoker) .. ")", spell.id)
    --     end
    --   end

    --   --Disintegrate
    --   if enemy.channelID == 356995 
    --   and enemy.castTarget.isUnit(player) 
    --   and enemy.castRemains <= (blink.gcd + blink.buffer) * 2 then
    --     if spell:Cast({stopMoving = true}) then
    --       alert("Feign Death (" .. colored("Disintegrate", colors.evoker) .. ")", spell.id)
    --     end
    --   end
    -- end

  end)

end)



-- only tracking direct meaningful damage, 
-- it's an indicator they're committed to attking the unit
local fireMageSpell = {
  [108853] = true,  -- fire blast
  [11366] = true,   -- pyroblast
  [257541] = true,  -- phoenix flames (maybe remove this)
}


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
  if player.buff(186265) then return end
  if player.mounted then return end

  --Rogues .....
  if spellID == 36554
  and dest.isUnit(player)
  or source.buffFrom({121471,185422})
  and source.target.isUnit(player)
  and source.dist <= 10
  and saved.autofeign then 
    feign:CastWhenPossible(function()
      blink.alert("Feign Death (" .. colored("Incoming Damage!", colors.rogue) .. ")", feign.id)
    end)
  end

  -- Meld the hunt
  if spellID == 370965
  and dest.isUnit(player)
  and source.speed > 45 
  and player.race == "Night Elf"
  and feign.cd > 0
  and saved.AutoMeld then 
    if meld:Cast({stopMoving = true}) then
      return blink.alert("Shadow Meld (" .. colored("The Hunt", colors.dh) .. ")", meld.id)
    end
  end

  -- FD the hunt
  if spellID == 370965
  and dest.isUnit(player)
  and source.speed > 45 
  and saved.autofeign then 
    feign:CastWhenPossible(function()
      blink.alert("Feign Death (" .. colored("The Hunt", colors.dh) .. ")", feign.id)
    end)
  end

  -- don't mind me, just tracking fire mage victims
  if spellID and fireMageSpell[spellID] then
    tinsert(fireMageVictims, {
      time = time,
      object = dest
    })
  end

  -- double tapped aimed shot? feign it.
  if spellID == 19434 and time - recentDoubleTapAimed <= 0.15 and dest.isUnit(player) then 
    feign:CastWhenPossible(function()
      blink.alert("Feign Death (" .. colored("Double Tap Aimed Shot", colors.hunter) .. ")", feign.id)
    end)
  end

  -- deathbolt? feign it.
  if spellID == 264106 and dest.isUnit(player) then
    if feign.cd <= 0.25 then
      feign:CastWhenPossible(function()
        blink.alert("Feign Death (" .. colored("Deathbolt", colors.warlock) .. ")", feign.id)
      end)
    end
  end

  -- Drain life feign it.
  if spellID == 234153 and dest.isUnit(player) then
    if feign.cd <= 0.25 and countershot.cd > 0 then
      feign:CastWhenPossible(function()
        blink.alert("Feign Death (" .. colored("Drain Life", colors.warlock) .. ")", feign.id)
      end)
    end
  end

  -- dark soul bolt
  if spellID == 116858 and source.buff(113858) and dest.isUnit(player) then
    if feign.cd <= 0.25 then
      feign:CastWhenPossible(function()
        blink.alert("Feign Death (" .. colored("Dark Soul Chaos Bolt", colors.warlock) .. ")", feign.id)
      end)
    end
  end

  -- ShadowMeld/flesh/scatter Stormbolt
  if spellID == 107570 
  and dest.isUnit(player) 
  and source.disorientDR == 1
  and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
    if Scatter.cd <= 0.25 and not source.immuneCC then
      if player.casting or player.channeling then
        blink.call("SpellStopCasting")
      end
      if saved.autoScatter and saved.autoscatterCDs then
        if dontScatter() then return end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Stormbolt", colors.warrior) .. ")", Scatter.id)
        end
      end
    elseif (Scatter.cd > 0.25 or saved.autoScatter == false) and player.race == "Night Elf" and saved.AutoMeld then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Stormbolt", colors.warrior) .. ")", meld.id)
      end
    end
  end

  -- ShadowMeld/flesh Coil
  if spellID == 6789 and dest.isUnit(player) 
  and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
    if player.race == "Night Elf" and saved.AutoMeld then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Coil", colors.warlock) .. ")", meld.id)
      end
    end
  end

  -- Scatter things on events 
  if saved.autoScatter 
  and player.hasTalent(213691) then
    if dontScatter() then return end
    if source.debuff(360194) then return end

    --camo
    if player.buff(199483) then return end  
    if source.disorientDR ~= 1 then return end
    if source.buffFrom({198589, 212800}) then return end

    -- Scatter the hunt on player
    if spellID == 370965
    and dest.isUnit(player)
    and saved.autoscatterCDs
    and feign.cd > 0 then 
      if Scatter.cd <= 0.25 and not source.immuneCC then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("The Hunt", colors.dh) .. ")", feign.id)
        end
      end
    end

    --scatter the hunt 
    if spellID == 370965
    and source.enemy 
    and saved.autoscatterCDs
    and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
      if Scatter.cd <= 0.25 and not source.immuneCC then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("The Hunt", colors.dh) .. ")", Scatter.id)
        end
      end
    end

    -- Scatter Mark for death 
    if spellID == 137619 
    and saved.autoscatterCDs
    and dest.isUnit(player) 
    and source.enemy 
    and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
      if Scatter.cd <= 0.25 and not source.immuneCC then
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Mark for Death", colors.rogue) .. ")", Scatter.id)
        end
      end
    end

    -- Metamorphosis on player
    if source.buff(162264) 
    and saved.autoscatterCDs
    and source.target.isUnit(player) 
    and not player.target.isUnit(source) then
      if Scatter.cd - blink.gcdRemains == 0 
      and not source.immuneCC then
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Metamorphosis", colors.dh) .. ")", Scatter.id)
        end
      end
    end            

    -- Flagellation Rush on player
    if spellID == 323654 
    and saved.autoscatterCDs
    and dest.isUnit(player) then
      if Scatter.cd <= 0.25 and not source.immuneCC then
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Flagellation", colors.rogue) .. ")", Scatter.id)
        end
      end
    end 

    -- Vendetta/deathmark on player
    if spellID == 360194 
    or spellID == 79140 
    and saved.autoscatterCDs then
      if Scatter.cd <= 0.25 and not source.immuneCC then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Deathmark", colors.rogue) .. ")", Scatter.id)
        end
      end
    end         

    -- Shadow Blades on player
    if source.buff(121471)
    and saved.autoscatterCDs then
      if Scatter.cd <= 0.25 and not source.immuneCC then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Shadow Blades", colors.rogue) .. ")", Scatter.id)
        end
      end
    end   
    
    -- Adrenaline Rush on player
    if source.buff(13750) 
    and saved.autoscatterCDs
    --and source.target.isUnit(player) 
    --and not player.target.isUnit(source)
    and source.dist > blink.latency / (5 - bin(player.moving) * 1) 
    and player.hp < 90 
    and healer.cc then
      if Scatter.cd <= 0.25 and not source.immuneCC then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Adrenaline Rush", colors.rogue) .. ")", Scatter.id)
        end
      end
    end    
    

    -----------Scatter Gap Closers-----------------

    -- Warrior Charge Scatter it.
    if spellID == 100 
    and saved.autoscatterGapCloser
    --and source.cds
    and not player.target.isUnit(source) then
      if Scatter.cd - blink.gcdRemains == 0 
      and not source.immuneCC then
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Charge", colors.warrior) .. ")", Scatter.id)
        end
      end
    end
    --warrior leap Scatter it
    if spellID == 6544 
    and saved.autoscatterGapCloser
    and source.enemy 
    and not player.target.isUnit(source)
    and not source.isHealer
    and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
      if Scatter.cd - blink.gcdRemains == 0 
      and not source.immuneCC then
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Heroic Leap", colors.warrior) .. ")", Scatter.id)
        end
      end
    end
    -- DH Fel rush Scatter it.
    if spellID == 195072 
    and saved.autoscatterGapCloser
    --and source.cds
    and not player.target.isUnit(source) then
      if Scatter.cd - blink.gcdRemains == 0 
      and not source.immuneCC then
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Fel Rush", colors.dh) .. ")", Scatter.id)
        end
      end
    end
    --rogue Shadowstep Scatter it
    if spellID == 36554 
    and saved.autoscatterGapCloser
    and source.enemy 
    and not player.target.isUnit(source)
    and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
      if Scatter.cd - blink.gcdRemains == 0 
      and not source.immuneCC then
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Shadow Step", colors.rogue) .. ")", Scatter.id)
        end
      end
    end
    --feral charge Scatter it
    if spellID == 49376 
    and saved.autoscatterGapCloser
    and source.enemy 
    and not player.target.isUnit(source)
    and not source.isHealer
    and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
      if Scatter.cd - blink.gcdRemains == 0 
      and not source.immuneCC then
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Wild Charge", colors.druid) .. ")", Scatter.id)
        end
      end
    end
    --monk roll Scatter it
    if spellID == 49376 
    and saved.autoscatterGapCloser
    and source.enemy 
    and not player.target.isUnit(source)
    and not source.isHealer
    and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
      if Scatter.cd - blink.gcdRemains == 0 
      and not source.immuneCC then
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Roll", colors.monk) .. ")", Scatter.id)
        end
      end
    end

    ----------------------End of scatter Gap Closers-----


    -- double tapped aimed shot? Scatter it.
    if spellID == 19434 
    and time - recentDoubleTapAimed <= 0.15 
    --and dest.isUnit(player) 
    and saved.autoscatterCDs
    and feign.cd > 0 then
      if Scatter.cd <= 0.25 and not source.immuneCC then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Double Tap Aimed Shot", colors.hunter) .. ")", Scatter.id)
        end
      end 
    end

    -- double tapped rapidfire? feign/Meld it.
    if spellID == 257044 and source.buff(260402) and dest.isUnit(player) then 
      if feign.cd <= 0.25 then
        feign:CastWhenPossible(function()
          blink.alert("Feign Death (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", feign.id)
        end)
      elseif feign.cd > 0.5 and player.race == "Night Elf" and saved.AutoMeld then
        if meld:Cast({stopMoving = true}) then
          return blink.alert("Shadow Meld (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", meld.id)
        end
      end
    end

    -- Glacial Spike feign/Meld it.
    if spellID == 199786 and dest.isUnit(player) then 
      if feign.cd <= 0.25 then
        feign:CastWhenPossible(function()
          blink.alert("Feign Death (" .. colored("Glacial Spike", colors.mage) .. ")", feign.id)
        end)
      elseif feign.cd > 0.5 and player.race == "Night Elf" and saved.AutoMeld then
        if meld:Cast({stopMoving = true}) then
          return blink.alert("Shadow Meld (" .. colored("Glacial Spike", colors.mage) .. ")", meld.id)
        end
      end
    end

    -- Arcane Surge feign/Meld it.
    if spellID == 365350 or spellID == 365362 and dest.isUnit(player) then 
      if feign.cd <= 0.25 then
        feign:CastWhenPossible(function()
          blink.alert("Feign Death (" .. colored("Arcane Surge", colors.mage) .. ")", feign.id)
        end)
      elseif feign.cd > 0.5 and player.race == "Night Elf" and saved.AutoMeld then
        if meld:Cast({stopMoving = true}) then
          return blink.alert("Shadow Meld (" .. colored("Arcane Surge", colors.mage) .. ")", meld.id)
        end
      end
    end

    -- chaos bolt? Scatter it.
    if spellID == 116858 and dest.isUnit(player) and saved.autoscatterCDs then
      if Scatter.cd <= 0.5 and feign.cd > 0 then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if Scatter:Cast(source, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Chaos Bolt", colors.warlock) .. ")", Scatter.id)
        end
      end
    end 

  end

  -- big surge
  if spellID == 78674 and dest.isUnit(player) then
    if source.channelID == 323764 then
      if feign.cd <= 0.2 then
        feign:CastWhenPossible(function()
          blink.alert("Feign Death (" .. colored("Big Starsurge", colors.druid) .. ")", feign.id)
        end)
      end
    elseif source.buffFrom({194223, 102560}) then
      if feign.cd <= 0.2 then
        feign:CastWhenPossible(function()
          blink.alert("Feign Death (" .. colored("Big Starsurge", colors.druid) .. ")", feign.id)
        end)
      end
    end
  end

  -- chaos bolt? feign it.
  if spellID == 116858 and dest.isUnit(player) then
    if feign.cd <= 0.5 then
      feign:CastWhenPossible(function()
        blink.alert("Feign Death (" .. colored("Chaos Bolt", colors.warlock) .. ")", feign.id)
      end)
    end 
  end

end)

local feignCCPls = {

  33786, -- Clone
  5782, -- Fear
  360806, -- Sleep Walk
  20066, -- Repentes
  605, -- Mind Control
  198898, --Song of Chi
  118, --Polymorph
  161355, --Polymorph
  161354, --Polymorph
  161353, --Polymorph
  126819, --Polymorph
  61780, --Polymorph
  161372, --Polymorph
  61721, --Polymorph
  61305, --Polymorph
  28272, --Polymorph
  28271, --Polymorph
  277792, --Polymorph
  277787, --Polymorph
  277784, --START OF HEX
  309328,
  269352,
  211004,
  51514,
  332605,
  210873,
  211015,
  219215,
  277778,
  17172,
  66054,
  11641,
  271930,
  270492,
  18503,
  289419, --END OF HEX

}

local feignMePls = {
  --[212431] = { uptime = 0.2 },              -- explosive shot
  --[162480] = { uptime = 0.3, min = 3.5 },   -- steel trap
  -- [131894] = { uptime = 0.6, min = 12 },    -- crows
  -- [274838] = { uptime = 0.25, min = 1.67 }, -- frenzy
  -- [274837] = { uptime = 0.25, min = 1.67 }, -- frenzy
  [363830] = { uptime = 0.25, min = 4.5 },  -- sickle
  [375901] = { uptime = 0.05, min = 1.5 },  -- games
  [323673] = { uptime = 0.05, min = 1.5 },  -- games
  -- [328305] = { uptime = 0.5, min = 5 },     -- sepsis
  -- [324149] = { uptime = 0.1, min = 5 },     -- flayed
  [325216] = { min = 2.5},    -- bonedust brew
}

feign:Callback("cc", function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end

  blink.enemies.loop(function(enemy)

    if player.spec == "Marksmanship" then
      if sr.hunter.mm.cs:Castable(enemy) then return end
    elseif player.spec == "BeastMastery" then
      if sr.hunter.bm.cs:Castable(enemy) then return end
    elseif player.spec == "Survival" then
      if sr.hunter.sv.cs:Castable(enemy) then return end
    end

    if enemy.casting then 
      local cast = C_Spell.GetSpellInfo(enemy.castID).name --GetSpellInfo(enemy.castID)

      if tContains(feignCCPls, enemy.castID)
      and enemy.castTarget.isUnit(player)  
      and (enemy.castRemains < (math.random(50,70)/100) + blink.buffer)
      and enemy.losOf(player) then
        return spell:Cast({stopMoving = true}) and blink.alert("Feign Death [ " .. colors.red .. cast .. " ]")
      end
    end
  end)

end)


--FIXME:
feign:Callback("debuffs", function(spell)
  --if hunter.waitingForSpear then return end
  local has = player.debuffFrom(feignMePls)
  if not has then return end
  local str = ""
  for i, id in ipairs(has) do
    if i == #has then
      str = str .. C_Spell.GetSpellInfo(id).name
    else
      str = str .. C_Spell.GetSpellInfo(id).name .. ","
    end
  end
  return spell:Cast({stopMoving = true}) and alert("Feign Death (" .. colored(str, colors.cyan) .. ")", spell.id)
end)

--! TRAPS !--

-- tar 
local tar = NS(187698, { effect = "magic", slow = true })

tar:Callback("predict", function(spell, obj, elapsed, msg)
  local x, y, z = obj.predictPosition(elapsed)
  if spell:AoECast(x,y,z) then
    return msg and alert("Tar " .. obj.classString .. " (" .. msg .. ")", spell.id) or alert("Tar " .. obj.classString, spell.id)
  end
end)


trap.velocity = 20.5
trap.radius = 1.5

local gapOpeners = {
  109132, -- roll
  119996, -- port
  310143, -- soulshape
  324701, -- flicker
  115008, -- chi torpedo
  1953,   -- blink
  100,    -- charge
  102417, -- wild charge
}

hunter.trapKeyPresses = 0
hunter.lastTrapKey = 0

--new genration of tuning
cmd:New(function(msg)
  if msg == "trap safe" then
    hunter.lastTrapKey = blink.time
    if hunter.listen then
      hunter.trapKeyPresses = hunter.trapKeyPresses + 1
    end
    return true
  end
end)

--new genration of tuning
local margins = {
  safe = 50,
  fair = 125,
  unsafe = 195
}

local predDivisor = 3.2

--*OLD
-- function trap:travelInfo(unit)

--   local buffer, latency = blink.buffer, blink.latency
  
--   -- science
--   local dist = unit.distanceLiteral
--   local velocity = self.velocity -- in yd/s
--   local radius = self.radius -- 1.5yd trigger radius
--   local speed, maxSpeed = unit.speed, unit.speed2
--   local travel = buffer + latency + dist / velocity
--   local maxReach = maxSpeed * travel
--   local riskFactor = max(maxReach - self.radius, 0)

--   local info = {
--     dist = dist,
--     radius = radius,
--     velocity = velocity,
--     travel = travel,
--     unit = {
--       maxReach = maxReach,
--       speed = speed,
--       maxSpeed = maxSpeed
--     } 
--   }

--   return info

-- end

--*NEW test to fix the travel boolean shit
function trap:travelInfo(unit)

  local buffer, latency = blink.buffer, blink.latency
  
  -- science
  local dist = unit.distanceLiteral
  local velocity = self.velocity -- in yd/s
  local radius = self.radius -- 1.5yd trigger radius
  local speed, maxSpeed = unit.speed, unit.speed2

  -- Check if maxSpeed is a boolean and set a default value if needed
  if type(maxSpeed) == "boolean" or player.dead then
    maxSpeed = 7 -- Assign a default value or choose an appropriate value
  end

  local travel = buffer + latency + dist / velocity
  local maxReach = maxSpeed * travel
  local riskFactor = max(maxReach - self.radius, 0)

  local info = {
    dist = dist,
    radius = radius,
    velocity = velocity,
    travel = travel,
    unit = {
      maxReach = maxReach,
      speed = speed,
      maxSpeed = maxSpeed
    } 
  }

  return info
end

--*OLD
-- function trap:maxDist(unit, errorMargin)
  
--   local speed, maxSpeed = unit.speed, unit.speed2
--   local buffer, tickRate, latency = blink.buffer, blink.tickRate, blink.latency
--   local radius, velocity = self.radius, self.velocity

--   local acceptableRadius = radius + (radius * (errorMargin / 100))

--   -- 0.65 surplus..
--   -- 43% error margin...

--   for simDist = 30, 0, -0.5 do
--     local simTravelTime = buffer - tickRate + latency + simDist / velocity, 2
--     if maxSpeed * simTravelTime <= acceptableRadius then
--       return simDist
--     end
--   end

--   return 0

-- end

--NEW TEST
function trap:maxDist(unit, errorMargin)
  local speed, maxSpeed = unit.speed, unit.speed2
  local buffer, tickRate, latency = blink.buffer, blink.tickRate, blink.latency
  local radius, velocity = self.radius, self.velocity

  local acceptableRadius = radius + (radius * (errorMargin / 100))

  -- Ensure maxSpeed is numeric, and set a default value if it's a boolean
  if type(maxSpeed) == "boolean" then
    maxSpeed = 7 -- Assign a default value or choose an appropriate value
  end

  -- Perform arithmetic operations with 'maxSpeed'
  for simDist = 30, 0, -0.5 do
    local simTravelTime = buffer - tickRate + latency + simDist / velocity, 2
    if maxSpeed * simTravelTime <= acceptableRadius then
      return simDist
    end
  end

  return 0
end

-- local gz = blink.GroundZ
-- trap:Callback("normal", function(spell, obj, msg)
--   --new genration of tuning
--   -- don't auto trap in camo
--   if blink.time - hunter.lastTrapKey > 1.75 and player.buff(camo.id) then alert("Press trap key to trap " .. obj.classString, spell.id) return end
--   local x, y, z = gz(obj.position())
--   if not x then return end
--   if not obj.los then return end
--   if spell:AoECast(x,y,z) then
--     return msg and alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or alert("Trap " .. obj.classString, spell.id)
--   end
-- end)

local gz = blink.GroundZ
local freezingTrapRadius = 1.3  -- 3 yards trigger radius for Freezing Trap
local searchStep = 0.15  -- Increase the step size for faster processing

-- Function to calculate the distance between two points
local function distance(x1, y1, x2, y2)
  return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

-- Define a function to get nearby units within a certain range
local function GetNearbyUnits(obj, maxRange)
  local nearbyUnits = {}
  for _, unit in ipairs(blink.enemies) do
    if unit.distanceLiteral <= maxRange and unit ~= obj then
      table.insert(nearbyUnits, unit)
    end
  end
  return nearbyUnits
end


-- Function to check if a position is suitable for the trap
local function isSuitablePosition(x, y, z, nearbyUnits, targetSize, trapVelocity, targetX, targetY, targetZ)
  local time = distance(x, y, targetX, targetY) / trapVelocity
  local predictedX, predictedY, predictedZ = predictTrapPosition(x, y, z, 0, 0, 0, trapVelocity, time)
  
  for _, unit in pairs(nearbyUnits) do
    local unitX, unitY, unitZ = gz(unit.position())
    local unitSize = 1.5
    local minDistance = (targetSize + unitSize) / 2 + freezingTrapRadius
    if distance(predictedX, predictedY, unitX, unitY) <= minDistance then
      return false
    end
  end
  return true
end

-- Function to predict the position of the trap after it has been thrown
function predictTrapPosition(x, y, z, dx, dy, dz, velocity, time)
  local newX = x + dx * velocity * time
  local newY = y + dy * velocity * time
  local newZ = z + dz * velocity * time
  return newX, newY, newZ
end

trap:Callback("normal", function(spell, obj, msg)

  local x, y, z = gz(obj.position())
  if not x then return end

  local targetSize = 0.2
  local trapVelocity = 20.5
  local nearbyUnits = GetNearbyUnits(obj, freezingTrapRadius)

  if #nearbyUnits == 0 then
    if obj.los then
      if spell:AoECast(x, y, z) then
        return msg and alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or alert("Trap " .. obj.classString, spell.id)
      end
    else

      sr.debugPrint("" .. obj.classString .. " Not LOS, Using Smart.")

      if spell:SmartAoE(obj, { distanceSteps = 6,
        circleSteps = 12,
        ignoreFriends = true,
        ignorePets = true,
        movePredTime = 0 }) then
        return msg and alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or alert("Trap " .. obj.classString, spell.id)
      end
    end
  else
    local bestX, bestY, bestZ
    local bestDistance = math.huge

    local stepLimit = 40 -- Limit the number of steps

    for radius = 0.0, freezingTrapRadius + 2.0, searchStep do
      if radius > stepLimit * searchStep then break end -- Stop after the specified number of steps
      for dx = -radius, radius, searchStep do
        for dy = -radius, radius, searchStep do
          if (dx * dx + dy * dy) <= radius * radius then
            local newX = x + dx
            local newY = y + dy
            if isSuitablePosition(newX, newY, z, nearbyUnits, targetSize, trapVelocity, x, y, z) then
              bestX = newX
              bestY = newY
              bestZ = z
              bestDistance = radius
              break
            end
          end
        end
        if bestX and bestY then break end
      end
      if bestX and bestY then break end
    end

    if bestX and bestY then
      if spell:AoECast(bestX, bestY, bestZ) then
        return msg and alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or alert("Trap " .. obj.classString, spell.id)
      end
    else

      sr.debugPrint("No suitable position found")

    end
  end
end)


-- Define a function to get nearby units within a certain range
-- function GetNearbyUnits(target, maxRange)
--   local nearbyUnits = {}
--   for _, unit in ipairs(blink.enemies) do
--     if unit.distanceLiteral <= maxRange and unit ~= target then
--       table.insert(nearbyUnits, unit)
--     end
--   end
--   return nearbyUnits
-- end

-- local gz = blink.GroundZ

-- -- Function to calculate the distance between two points
-- local function distance(x1, y1, x2, y2)
--   return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
-- end

-- local freezingTrapRadius = 1.5  -- 1.5 yards trigger radius for Freezing Trap

-- trap:Callback("normal", function(spell, obj, msg)
--   -- New generation of tuning
--   -- Don't auto trap in camo
--   if blink.time - hunter.lastTrapKey > 1.75 and player.buff(camo.id) then
--     alert("Press trap key to trap " .. obj.classString, spell.id)
--     return
--   end

--   local x, y, z = gz(obj.position())
--   if not x then return end

--   -- Check if there is a line of sight to the target
--   --if not obj.los then return end

--   -- Get a list of nearby units within the freezing trap radius
--   local nearbyUnits = GetNearbyUnits(obj, freezingTrapRadius)

--   -- Calculate the optimal position to place the trap
--   local bestX, bestY
--   local bestDistance = math.huge

--   for dx = -freezingTrapRadius, freezingTrapRadius, 0.1 do
--     for dy = -freezingTrapRadius, freezingTrapRadius, 0.1 do
--       local newX = x + dx
--       local newY = y + dy

--       -- Check if the new position is within the trigger radius
--       local d = distance(x, y, newX, newY)

--       if d <= freezingTrapRadius then
--         -- Check if any nearby unit is too close to the new position
--         local tooClose = false
--         for _, unit in pairs(nearbyUnits) do
--           local unitX, unitY, unitZ = gz(unit.position())
--           if distance(newX, newY, unitX, unitY) <= freezingTrapRadius then
--             tooClose = true
--             break
--           end
--         end

--         if not tooClose and d < bestDistance then
--           bestX = newX
--           bestY = newY
--           bestDistance = d
--         end
--       end
--     end
--   end

--   if bestX and bestY then
--     if spell:AoECast(bestX, bestY, z) then
--       return msg and alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or alert("Trap " .. obj.classString, spell.id)
--     end
--   end
-- end)




trap:Callback("predict", function(spell, obj, elapsed, msg)
  --new genration of tuning
  -- don't auto trap in camo
  if blink.time - hunter.lastTrapKey > 1.75 and player.buff(camo.id) then alert("Press trap key to trap " .. obj.classString, spell.id) return end
  local x, y, z = gz(obj.predictPosition(elapsed))
  if not x then return end
  if not obj.los then return end
  if spell:AoECast(x,y,z) then
    return msg and alert("Trap " .. obj.classString .. " (" .. msg .. ")", spell.id) or alert("Trap " .. obj.classString, spell.id)
  end
end)


function trap:immunityRemains(unit)

  local ccImmunityDuration = unit.ccImmunityRemains

  -- Exclude Blessing of Protection/Aura Mastery if present
  if unit.buffFrom({1022, 211210, 317929}) then
    ccImmunityDuration = nil
  end

  local immunities = {
    {
      name = "Magic Immunity",
      remains = unit.magicEffectImmunityRemains
    },
    {
      name = "CC Immunity",
      remains = ccImmunityDuration
    }
  }

  if unit.buff(48707) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Anti-Magic Shell]",
      remains = 5
    }
  end

  if unit.buff(410358) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Anti-Magic Shell]",
      remains = 5
    }
  end
  
  -- fleshy c
  if unit.channelID == 324631 then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Fleshcraft]",
      remains = 6
    }
  end

  -- Ultimate Fleshcraft
  if unit.buff(323524) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Ultimate Form]",
      remains = 3
    }
  end

  -- grounding
  if unit.buff(8178) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Grounding]",
      remains = 69
    }
  end

  --Evoker Nullifying Shit
  if unit.buff(378464) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Nullifying Shroud]",
      remains = 30
    }
  end

  --Warrior Reflect
  if unit.buff(23920) then
    immunities[#immunities+1] = {
      name = "Spell Reflect",
      remains = 7
    }
  end

  --Warrior Reflect Legendary
  if unit.buff("Spell Reflection") then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Spell Reflection]",
      remains = 7
    }
  end
  
  --Warrior Reflect Legendary Misshapen Mirror
  if unit.buff("Misshapen Mirror") then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Spell Reflect]",
      remains = 7
    }
  end

  --PROT PALA Immune Spell Warding
  if unit.buff(204018) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Spell Warding]",
      remains = 10
    }
  end

  --PROT PALA Immune Forgotten Queen
  if unit.buff(228050) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Forgotten Queen]",
      remains = 10
    }
  end

  --if not undispellable
  if not player.hasTalent(203340) then 
    --more Sac to make sure we not throw traps into sacs please?
    if unit.buff(6940) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Blessing of Sacrifice]",
        remains = 12
      }
    end

    --Sac more !!
    if unit.buff(199448) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Blessing of Sacrifice]",
        remains = 12
      }
    end

    --Ultimate Sac another one #justin
    if unit.buff(199452) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Blessing of Sacrifice]",
        remains = 6
      }
    end

    --NEW DF Ultimate Sac
    if unit.buff(199448) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Ultimate Sacrifice]",
        remains = 6
      }
    end

    --NEW DF Ultimate Sac2
    if unit.buff(199450) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Ultimate Sacrifice]",
        remains = 6
      }
    end

    --Ultimate Sac another one with name 
    if unit.buff("Ultimate Sacrifice") then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Ultimate Sacrifice]",
        remains = 6
      }
    end

    --meteor
    if unit.debuff(155158) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Meteor]",
        remains = 4
      }
    end

    --orb
    if unit.debuff(289308) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Frozen Orb]",
        remains = 4
      }
    end

    --blizzard
    if unit.debuff(12486) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Blizzard]",
        remains = 4
      }
    end

    --deathmark
    if unit.debuff(360194) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Deathmark]",
        remains = 16
      }
    end

    --Feral Frenzy
    if unit.debuff(274837) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Feral Frenzy]",
        remains = 4
      }
    end
    
    --Feral Frenzy
    if unit.debuff(274838) then
      immunities[#immunities+1] = {
        name = "|cFFff4f42[Feral Frenzy]",
        remains = 4
      }
    end  

    -- blessing of sac
    if unit.class2 == "PALADIN" then
      local sac_remains = 0
      local sac_source = nil

      blink.enemies.loop(function(enemy)
        local buff, _, _, _, _, _, source = enemy.buff(6940)
        if not buff then
          buff, _, _, _, _, _, source = enemy.buff(199452)
          if buff then
            sac_remains = enemy.buffRemains(199452) or 0
            sac_source = source
          end
        else
          sac_remains = enemy.buffRemains(6940) or 0
          sac_source = source
        end
      end)

      if sac_source and unit.isUnit(sac_source) then
        immunities[#immunities+1] = {
          name = "Sac",
          remains = sac_remains
        }
      end
    end
  end

  --NEW Paladin Searing Glare
  if player.debuff(410201) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Searing Glare]",
      remains = 4
    }
  end

  --war banner
  if unit.buff(236321) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[War Banner]",
      remains = 5
    }
  end

  --Monk immune Restoal
  if unit.buff(353319) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Peaceweaver]",
      remains = 2
    }
  end

  --immune Precognition
  if unit.buff(377360) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Precognition]",
      remains = 5
    }
  end
  
  --immune Precognition
  if unit.buff(377362) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Precognition]",
      remains = 5
    }
  end

  --priest Phase Shift
  if unit.buff(408558) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Phase Shift]",
      remains = 1
    }
  end

  --priest Ultimate Penitence
  if unit.buff(421453) then
    immunities[#immunities+1] = {
      name = "|cFFff4f42[Ultimate Penitence]",
      remains = 5
    }
  end
  
  --Add ring of fire ?
  
  --ensure all remains values are numbers
  for i, immunity in ipairs(immunities) do
    if immunity.remains == nil then
      immunities[i].remains = 0 -- Default nil remains to 0
    end
  end

  sort(immunities, function(x,y) return x.remains > y.remains end)

  return immunities[1]

end

function trap:reset()
  hunter.listen = false
  hunter.trapKeyPresses = 0
  self.telegraphDelay = nil
  self.commitDelay = nil
  self.startTime = nil
  self.elapsed = nil
end

local ignorePred = {
  331866,   -- Door of Shadows
  105421,   -- Blinding Light
  118,		  -- Sheep
  28272,		-- Pig
  277792,		-- Bee
  161354,		-- Monkey
  277787,		-- Direhorn
  161355,		-- Penguin
  161353,		-- Polar Bear
  120140,		-- Porcupine
  61305,		-- Cat
  61721,		-- Rabbit
  61780,		-- Turkey
  28271,		-- Turtle
  2094,     -- Blind
  196942,   -- Hex?
  51514,    -- Hex
	211015, -- Hex (Cockroach)
	210873, -- Hex (Compy)
	211010,	-- Hex (Snake)
	211004,	-- Hex (Spider)
	277784,	-- Hex (Wicker Mongrel)
	277778,	-- Hex (Zandalari Tendonripper)
	309328,	-- Hex (Living Honey)
	269352,	-- Hex (Skeletal Raptor)
  207167, -- Blinding Sleet
  99,     -- Incap Roar
  213691, -- Scatter Shot
}

local predictionCC = {
  1513,     -- scare beast
  5246,     -- intim shout
  5782,     -- Fear
  10326,    -- Turn evil
  8122,     -- Psychic Scream
  6789,     -- Coil
  360806,   -- sleep walk
}


local msg = {
  cd = "|cFFf7f25cTrap|r ready soon...",
  dr = "Waiting for |cFFf74a4a[DR]",
  cc = "Waiting to follow up",
  immune = "Waiting for immunity",
  range = "Move into range for |cFFf7f25c[trap]",
  outplay = "Waiting to |cFF8be9f7[outplay]|r xD",
  cdt = "Waiting for CD"
}

function trap:pursue(obj)

  -- reset always
  trap.cuckable = false

  if not obj.enemy or not obj.exists then self:reset() return end
  if self.cd > 6 then self:reset() return msg.cd end

  local buffer, tickRate, latency, gcd, gcdRemains = blink.buffer, blink.tickRate, blink.latency, blink.gcd, blink.gcdRemains
  local info = obj.exists and obj.enemy and trap:travelInfo(obj)
  local travel, maxReach = info.travel, info.unit.maxReach
  
  local Fleshcrafting = obj.channelID == (324631) and obj.channelTimeComplete > 0.3
  local inCamo = player.buff(199483)
  local time = blink.time

  -- Mced unit
  if obj.charmed then return "Waiting for Mind Control" end

  local immunity = trap:immunityRemains(obj)
  local mir = immunity.remains
  
  if mir > travel - 0.125 then return "Waiting for " .. immunity.name end

  local dr, drr = obj.incapdr, obj.incapdrr
  if (dr ~= 1 and not obj.incapped or dr <= 0.25) and drr > travel - 0.125 then return msg.dr end
  
  local ccr = obj.ccr

  if obj.isUnit(target) then
    hunter.listen = true
    if hunter.trapKeyPresses == 0 then return false end
  end

  local manuallyQueued = blink.time - hunter.lastTrapKey < 1.25
  local followupReady = blink.time - hunter.lastTrapKey < 2.5 or saved.autoFollowup

  if ccr > travel + buffer - bin(manuallyQueued)*(buffer+0.085) then
    if obj.distance > 90 then return end
    hunter.drawFollowupTrap = {
      obj = obj,
      cc = obj.cc,
      remains = ccr,
      after = ccr - travel + acceptable_overlap + buffer,
      travel = travel,
    }
    -- handle followup trap prediction logic here
    if obj.moving and not obj.stunned then
      if obj.speed < 7.5 then
        local fullPred = obj.debuffFrom(predictionCC)
        local partialPred = obj.debuffFrom(ignorePred)

        if fullPred then
          local dChange = obj.timeSinceDirectionChange

          hunter.drawFollowupTrap.predict = true
          hunter.drawFollowupTrap.dirChange = dChange

          local goodChange = dChange < 0.95 and dChange > 0.09 or obj.speed < 4.65
          if obj.los then
            if ccr > travel + bin(goodChange) * necessary_overlap + (buffer + gcd) * 2 then
              if hunter.conc then hunter.conc:Cast(obj, {face=true}) end
              hunter.importantPause = { msg = "Pausing for |cFF8be9f7[Trap Prediction]", texture = self.id }
              return msg.cc
            elseif followupReady and ccr < 1 + travel + buffer and obj.distanceLiteral <= 10 then
              return trap("predict", obj, travel + buffer + tickRate, "|cFF8be9f7Predict Pathing")
            elseif ccr > travel + buffer then
              hunter.importantPause = { msg = "Pausing for |cFF8be9f7[Trap Prediction]", texture = self.id }
            end
          end
        elseif partialPred then
          if ccr <= travel + acceptable_overlap + bin(blink.time - hunter.lastTrapKey < 1.25)*3 + buffer + 0.025 and (cc ~= 1513 or obj.rooted) then
            if followupReady then
              return trap("predict", obj, (travel + buffer + tickRate) / 6, "|cFF8be9f7Slight Prediction")
            end
          end
        elseif obj.classString then
          alert("|cFFff5e5eCan't Trap " .. obj.classString .. " [Moving]", self.id)
        end
      end
    else
      if ccr <= travel + acceptable_overlap + (buffer + gcd) * 2 + bin(manuallyQueued) * 5 then
        if obj.class2 == "MONK" and obj.isHealer and obj.cooldown(119996) <= travel and not (obj.stunned or obj.rooted) then 
          tar("predict", obj, travel / predDivisor, "Bait |cFFff4f42Transcendence")
        end
        if ccr <= travel + acceptable_overlap + buffer + bin(manuallyQueued) * 5 and (cc ~= 1513 or obj.rooted) then
          if followupReady then
            if player.casting or player.channeling then 
              if player.castID == 982 then return end
              sr.debugPrint("Stop Casting to throw trap")
              blink.call("SpellStopCasting") 
              blink.call("SpellStopCasting")
            end
            return trap("normal", obj, manuallyQueued and "|cFFf7f25c[Manual - Early]")
          end
        end
      end
    end
  else
    local dist = obj.distanceLiteral
    local safe = self:maxDist(obj, margins.safe)
    local unsafe = self:maxDist(obj, margins.unsafe)

    if dist > unsafe then
      self:reset() 
      if player.combat then
        if saved.cheetahToTrap then
          if dist >= unsafe * 1.015 and dist <= 32.5 and not player.slowed and not player.mounted and not player.buff(199483) and player.movingToward(obj, { angle = 55 + bin(manuallyQueued) * 20, duration = 1.5 - bin(manuallyQueued) * 1 }) then
            cheetah("pursue trap")
          end
        end
        if saved.disengageToTrap then
          if dist <= 32.5 and dist >= unsafe * 1.1 and not player.mounted and player.movingToward(obj, { angle = 35 + bin(manuallyQueued) * 65, duration = 1.2 - bin(manuallyQueued) * 1 }) then
            disengage:toUnit(obj, 0.1, 0.85)
          end
        end
        if saved.autoharpoon and currentSpec == 3 then
          if disengage.recentlyUsed(2) then return end
          if dist <= 30 and dist > 15 and dist >= unsafe * 1.1 and harpoon.cd == 0 and trap.cd - blink.gcdRemains == 0 and not obj.bcc and not player.mounted and not player.buff(199483) and not obj.immuneMagicEffects or obj.immuneCC and player.movingToward(obj, { angle = 35 + bin(manuallyQueued) * 65, duration = 1.2 - bin(manuallyQueued) * 1 }) then
            if harpoon:Cast(obj) then
              alert("|cFFf7f25c[Trap Mode]: |cFF8be9f7Harpoon to trap " .. obj.classString, harpoon.id)
            end   
          end
        end   
      end
      -- if dist <= unsafe * (1.25 + bin(obj.slowRemains < travel + buffer + 0.1) * 1) then
      --   if hunter.conc then
      --     hunter.conc("yolo trap", obj)
      --   end
      -- end
      -- return blink.time - hunter.lastTrapKey < 2 and msg.range or nil
      -- keep conc'd while near-ish .. ?
      if dist <= unsafe * (1.25 + bin(obj.slowRemains < travel + buffer + 0.1) * 1) and dist > safe then
        if hunter.conc then
          hunter.conc("yolo trap", obj)
        end
      end
      return time - hunter.lastTrapKey < 2 and msg.range or nil
    end

    local elapsed = 0
    self.telegraphDelay = self.telegraphDelay or random(tDelay.min, tDelay.max) / 1000
    self.commitDelay = self.commitDelay or random(cDelay.min, cDelay.max) / 1000
    if dist <= self:maxDist(obj, margins.fair) then
      self.startTime = self.startTime or blink.time
      elapsed = blink.time - self.startTime
    else
      self.startTime = blink.time
      elapsed = 0
    end
    self.elapsed = elapsed

    -- if obj.slowRemains <= travel + 0.025 and (not obj.debuff(135299) or obj.moving) then 
    --   if hunter.conc then
    --     hunter.conc("yolo trap", obj)
    --   end
    -- end

    -- reapply conc to keep unit slowed
    if obj.slowRemains <= travel + 0.025 and (not obj.debuff(135299) or obj.moving) and dist > safe * 1.1 then 
      if hunter.conc then
        hunter.conc("yolo trap", obj)
      end
    end

    if self.cd <= blink.gcdRemains then
      if dist <= safe then
        hunter.importantPause = { msg = "Pausing damage to |cFF8be9f7Secure trap", texture = self.id }
      elseif dist <= self:maxDist(obj, margins.fair) then
        hunter.unimportantPause = true
      end
    end
    
    local onGCD = obj.gcdRemains >= travel - 0.001 and not obj.immuneCC

    if obj.used(gapOpeners, 0.75) then return "Waiting - |cFFff4f42Recent Gap-opener" end
    if obj.used(32379, 1.5 - travel) then return "Waiting - |cFFff4f42SW: Death" end

    local cuckable = canCuckTrap(obj, travel, true)
    trap.cuckable = cuckable
    if cuckable and elapsed >= self.telegraphDelay and self.commitDelay - elapsed >= gcd then
      local cuckName = C_Spell.GetSpellInfo(cuckable).name
      tar("predict", obj, travel / predDivisor, cuckName and "Bait |cFFff4f42" .. cuckName)
    end

    local class = obj.class2

    if class == "PALADIN" and obj.slowed and dist > unsafe / 1.65 then
      cuckable = 1044
    end

    if dist <= safe
    or onGCD
    or dist <= unsafe and not cuckable -- was checking for fair dist before, but tbh doesn't matter
    or hunter.trapKeyPresses >= 1 then
      if cuckable then
        if elapsed >= self.commitDelay
        or onGCD
        or hunter.trapKeyPresses >= 2 then
          return trap("predict", obj, travel / predDivisor, onGCD and "|cFF6bffc4Gotcha Baby|r ~ GCD")
        end
        local cuckName = C_Spell.GetSpellInfo(cuckable).name
        if cuckName then
          return "Provoking |cFFff4f42" .. cuckName
        end
      else
        return trap("predict", obj, travel / predDivisor, onGCD and "|cFF6bffc4Gotcha Baby|r ~ GCD")
      end
    else
      if cuckable then
        local cuckName = C_Spell.GetSpellInfo(cuckable).name
        if cuckName then
          return "Provoking |cFFff4f42" .. cuckName
        end
      elseif dist <= unsafe then
        local root = obj.rooted
        if root then
          hunter.drawFollowupTrap = {
            obj = obj,
            cc = obj.rooted,
            remains = obj.rootRemains
          }
          return trap("normal", obj, "Rooted")
        end
      end
      return msg.outplay
    end
  end
end

-- function trap:pursuebycommand(obj)

--   -- reset always
--   trap.cuckable = false

--   if not obj.enemy then self:reset() return end
--   if self.cd > 6 then self:reset() return msg.cd end

--   local buffer, tickRate, latency, gcd, gcdRemains = blink.buffer, blink.tickRate, blink.latency, blink.gcd, blink.gcdRemains
--   local info = self:travelInfo(obj)
--   local travel, maxReach = info.travel, info.unit.maxReach

--   local resolveRemains = obj.buffRemains(363121)
--   if resolveRemains > travel - 0.125 then
--     -- if hunter.interrupt and hunter.interrupt:Cast(obj) then
--     --   alert("Interrupt |cFF6ee7ffGladiator's Resolve Stack", hunter.interrupt.id)
--     -- end
--     return "Waiting for |cFF6ee7ffGladiator's Resolve"
--   end
  
--   local Fleshcrafting = obj.channelID == (324631) and obj.channelTimeComplete > 0.3
--   if Fleshcrafting then
--     if hunter.interrupt and hunter.interrupt:Cast(obj) then
--       alert("Interrupt: |cFF6ee7ffFleshcraft", hunter.interrupt.id)
--     end
--     return "Waiting for |cFF6ee7ffFleshcraft"
--   end

--   local immunity = trap:immunityRemains(obj)
--   local mir = immunity.remains
  
--   if mir > travel - 0.125 then return "Waiting for " .. immunity.name end

--   local dr, drr = obj.incapdr, obj.incapdrr
--   if (dr ~= 1 and not obj.incapped or dr <= 0.25) and drr > travel - 0.125 then return msg.dr end
  
--   local ccr = obj.ccr

--   if obj.isUnit(target) then
--     hunter.listen = true
--     if hunter.trapKeyPresses == 0 then return false end
--   end
  
--   local manuallyQueued = blink.time - hunter.lastTrapKey < 1.25

--   -- followup traps
--   if ccr > travel + buffer - bin(manuallyQueued)*(buffer+0.085) then
--     hunter.drawFollowupTrap = {
--       obj = obj,
--       cc = obj.cc,
--       remains = ccr,
--       after = ccr - travel + acceptable_overlap + buffer,
--       travel = travel,
--     }
--     -- moving in cc
--     if obj.moving and not obj.stunned then
    
--       if obj.speed < 7.5 then

--         local fullPred = obj.debuffFrom(predictionCC)
--         local partialPred = obj.debuffFrom(ignorePred)

--         if fullPred then
--           local dChange = obj.timeSinceDirectionChange

--           hunter.drawFollowupTrap.predict = true
--           hunter.drawFollowupTrap.dirChange = dChange

--           local goodChange = dChange < 0.95 and dChange > 0.09 or obj.speed < 4.65
          
--           if obj.los then
--             if ccr > travel + bin(goodChange) * necessary_overlap + (buffer + gcd) * 2 then
--               if hunter.conc then hunter.conc:Cast(obj, {face=true}) end
--               hunter.importantPause = { msg = "Pausing for |cFF8be9f7[Trap Prediction]", texture = self.id }
--               return msg.cc
--             -- else fucking up with followup traps too early
--             elseif ccr < 1 + travel + buffer and obj.distanceLiteral <= 10 then
--               return trap("predict", obj, travel + buffer + tickRate, "|cFF8be9f7Predict Pathing")
--             elseif ccr > travel + buffer then
--               hunter.importantPause = { msg = "Pausing for |cFF8be9f7[Trap Prediction]", texture = self.id }
--             end
--           end
--         elseif partialPred then
--           -- trap on stuff that do bloo boo boo and blinds and shit
--           if ccr <= travel + acceptable_overlap + bin(blink.time - hunter.lastTrapKey < 1.25)*3 + buffer + 0.025 and (cc ~= 1513 or obj.rooted) then
--             return trap("predict", obj, (travel + buffer + tickRate) / 6, "|cFF8be9f7Slight Prediction")
--           end
--         elseif obj.classString then
--           alert("|cFFff5e5eCan't Trap " .. obj.classString .. "[Moving]", self.id)
--         end

--       end
--     else
--       if ccr <= travel + acceptable_overlap + (buffer + gcd) * 2 + bin(manuallyQueued) * 5 then
--         if obj.class2 == "MONK" and obj.isHealer and obj.cooldown(119996) <= travel and not (obj.stunned or obj.rooted) then 
--           tar("predict", obj, travel / predDivisor, cuckName and "Bait |cFFff4f42Transcendence")
--          --Druid Jump
--         elseif obj.class2 == "DRUID" and obj.isHealer and obj.cooldown(102417) <= travel and not (obj.stunned or obj.rooted) then 
--           tar("predict", obj, travel / predDivisor, cuckName and "Bait |cFFff4f42Wild Charge")
--         end
--         if ccr <= travel + acceptable_overlap + buffer + bin(manuallyQueued) * 5 and (cc ~= 1513 or obj.rooted) then
--           return trap("normal", obj, manuallyQueued and "Manual - Early")
--         end
--       end
--     end
--   -- yolo traps
--   else

--     local dist = obj.distanceLiteral
--     local safe = self:maxDist(obj, margins.safe)
--     local fair = self:maxDist(obj, margins.fair)
--     local unsafe = self:maxDist(obj, margins.unsafe)

--     -- only within *reasonable* range
--     if dist > unsafe then
--       self:reset() 
--       if player.combat then
--         alert("|cFFf7f25c[Safe Mode]: |cffffffffMove into ".. (obj.classString) .." range for |cFFf7f25ctrap ", trap.id)
--         --alert("Move into range for |cFFf7f25ctrap")
--         -- go fast
--         if dist >= unsafe * 1.015
--         and dist <= 32.5
--         and not player.slowed
--         and not player.mounted
--         and not player.buff(199483)
--         and player.movingToward(obj, { angle = 55 + bin(manuallyQueued) * 20, duration = 0.2 - bin(manuallyQueued) * 0.7 }) then
--           cheetah("pursue trap")
--         end
--         -- disengage to them
--         if dist <= 32.5
--         and dist >= unsafe * 1.1
--         and not player.mounted
--         and player.movingToward(obj, { angle = 35 + bin(manuallyQueued) * 65, duration = 0.5 - bin(manuallyQueued) * 1 }) then
--           disengage:toUnit(obj, 0.1, 0.85)
--         end
--       end
--       -- keep conc'd while near-ish .. ?
--       if dist <= unsafe * (1.25 + bin(obj.slowRemains < travel + buffer + 0.1) * 1) then
--         if hunter.conc then
--           hunter.conc("yolo trap", obj)
--         end
--       end
--       return blink.time - hunter.lastTrapKey < 2 and msg.range or nil
--     end

--     local safe = self:maxDist(obj, margins.safe)
--     local fair = self:maxDist(obj, margins.fair)

--     -- listen for consecutive trap macro presses, 
--     -- loosen restrictions for each press made while in range
--     hunter.listen = true

--     -- wait for cd before starting delays
--     if self.cd - gcdRemains > 0 then return msg.cdt end

--     local elapsed = 0
--     self.telegraphDelay = self.telegraphDelay or random(tDelay.min, tDelay.max) / 1000
--     self.commitDelay = self.commitDelay or random(cDelay.min, cDelay.max) / 1000
--     if dist <= fair then
--       self.startTime = self.startTime or blink.time
--       elapsed = blink.time - self.startTime
--     else
--       self.startTime = blink.time
--       elapsed = 0
--     end
--     self.elapsed = elapsed

--     -- reapply conc to keep unit slowed
--     if obj.slowRemains <= travel + 0.025 and (not obj.debuff(135299) or obj.moving) then 
--       if hunter.conc then
--         hunter.conc("yolo trap", obj)
--       end
--     end

--     -- pause unimportant dmg gcds for potential gotcha
--     if self.cd <= blink.gcdRemains then
--       if dist <= safe then
--         hunter.importantPause = { msg = "Pausing damage to |cFF8be9f7Secure trap |cFFf7f25c[Trap Mode]", texture = self.id }
--       elseif dist <= fair then
--         hunter.unimportantPause = true
--       end
--     end
    
--     local onGCD = obj.gcdRemains >= travel - 0.001 -- teeny tiny acceptable error rate

--     -- ehh, flashy but unnecessary
--     -- if onGCD and dist >= fair then
--     --   -- disengage to them
--     --   if not player.mounted then
--     --     disengage:toUnit(obj, 0, 1)
--     --   end
--     -- end
    
--     -- no recent gapclosers, not mid-death
--     if obj.used(gapOpeners, 1) then return "Waiting - |cFFff4f42Recent Gap-opener" end
--     if obj.used(32379, 1.5 - travel) then return "Waiting - |cFFff4f42SW: Death" end

--     local cuckable = canCuckTrap(obj, travel, true)
--     trap.cuckable = cuckable
--     if cuckable and elapsed >= self.telegraphDelay and self.commitDelay - elapsed >= gcd then
--       local cuckName = GetSpellInfo(cuckable)
--       tar("predict", obj, travel / predDivisor, cuckName and "Baiting |cFFff4f42" .. cuckName)
--     end

--     if dist <= safe
--     or onGCD
--     or dist <= unsafe and not cuckable -- was checking for fair dist before, but tbh doesn't matter
--     or hunter.trapKeyPresses >= 1 then
--       if cuckable then
--         if elapsed >= self.commitDelay
--         or onGCD
--         or hunter.trapKeyPresses >= 2 then
--           return trap("predict", obj, travel / predDivisor, onGCD and "|cFF6bffc4Gotcha Baby|r ~ GCD") 
--         end
--         local cuckName = GetSpellInfo(cuckable)
--         if cuckName then
--           return "Provoking |cFFff4f42" .. cuckName
--         end
--       else
--         return trap("predict", obj, travel / predDivisor, onGCD and "|cFF6bffc4Gotcha Baby|r ~ GCD") 
--       end
--     else
--       if cuckable then
--         local cuckName = GetSpellInfo(cuckable)
--         if cuckName then
--           return "Provoking |cFFff4f42" .. cuckName
--         end
--       elseif dist <= unsafe then
--         local root = obj.rooted
--         local harpoon = obj.debuff(190925)
--         if root or harpoon then
--           hunter.drawFollowupTrap = {
--             obj = obj,
--             cc = obj.rooted,
--             remains = obj.rootRemains
--           }
--           return trap("normal", obj, "Rooted")
--         end
--       end
--       return msg.outplay
--     end
--   end
-- end


--! END TRAPS !--

hunter.trapTarget = {}
onUpdate(function()
  if saved.trapUnit == "enemyHealer" then
    hunter.trapTarget = (enemyHealer.exists and not enemyHealer.isUnit(target) and enemyHealer or {})
  end
  if saved.trapUnit == "focus" then
    hunter.trapTarget = (focus.exists and not focus.isUnit(target) and focus or {})
  end
  if saved.trapUnit == "smart" then
    hunter.trapTarget = (focus.exists and not focus.isUnit(target) and focus or enemyHealer.exists and not enemyHealer.isUnit(target) and enemyHealer or {}) --BKP
    -- if hunter.trapTarget.isUnit and hunter.trapTarget.isUnit(target) then hunter.trapTarget = {} end
  end
  hunter.bm.trapTarget = hunter.trapTarget
  hunter.sv.trapTarget = hunter.trapTarget
  hunter.mm.trapTarget = hunter.trapTarget
end)

local BlinkFontLarge = blink.createFont(16)
local BlinkFontNormal = blink.createFont(12)

local function normalize(a)
  return min(255, max(0, a))
end

local ddraw = 0
blink.Draw(function(draw)
 if saved.streamingMode then return end
  -- local px,py,pz = player.position()
  
  -- local dir = player.movingDirection
  -- draw:SetColor(255,255,255,65)
  -- draw:Line(px,py,pz,px+3*cos(dir),py+3*sin(dir),pz)

  -- if sr.drawDisengage and ddraw < 333 then  
  --   draw:SetColor(255,180,135,150)
  --   local dir = sr.drawDisengage
  --   draw:Line(px,py,pz,px-3*cos(dir),py-3*sin(dir),pz)
  --   ddraw = ddraw + 1
  -- else
  --   sr.drawDisengage = nil
  --   ddraw = 0
  -- end

  -- if true then return end
  if UnlockerType == "daemonic" then
    draw:SetWidth(4)
  end

  local tt = hunter.trapTarget

  -- if hunter.drawstomp then
  --   local x,y,z = unpack(hunter.drawstomp)
  --   draw:SetColor(255,255,255,12)
  --   draw:FilledCircle(x,y,z,10)
  -- end

  if tt.enemy and trap.cd < 10 then

    local followup = hunter.drawFollowupTrap
    if followup then
      local cc, remains, travel = followup.cc, followup.remains, followup.travel
      if cc then
        local x,y,z = tt.position()
        draw:SetColor(255,255,255,255)
        if followup.predict then
          local px, py, pz = tt.predictPosition(travel + blink.buffer)
          local angle = angles(x,y,z,px,py,pz)
          local diam = trap.radius * 2
          draw:FilledCircle(px, py, pz, diam)
          draw:Line(x, y, z, px + diam * cos(angle), py + diam * sin(angle), pz)
        end
        if blink.textureEscape(cc) then
          local str = blink.textureEscape(cc) .. " >> " .. blink.textureEscape(trap.id)
          draw:Text(str, BlinkFontNormal, x, y, z - 0.5)
          if followup.after then
            draw:Text(round(math.floor(followup.after - travel),1), BlinkFontLarge, x, y, z - 2.5)
          end
        end
      end
    else

      local d1 = trap:maxDist(tt, margins.safe)
      local d2 = trap:maxDist(tt, margins.fair)
      local d3 = trap:maxDist(tt, margins.unsafe)
      local x,y,z = blink.GroundZ(tt.position())
      if not x then return end

      local trMod = max(0, (trap.cd - blink.gcdRemains) * 20)

      local d = tt.distanceLiteral

      local tengage = hunter.trapKeyPresses >= 1

      if UnlockerType == "daemonic" then 
        draw:SetColor(15, 225 + bin(tengage) * 20, 35, (d < d1 and 235 or 25) - trMod)
        draw:Circle(x, y, z, d1)
        draw:SetColor(244 - bin(tengage) * 85, 195 + bin(tengage) * 60, 45, normalize((d < d1 and 25 or d < d2 and d > d1 and 235 or 125) - trMod))
        if d < d3 then
          draw:FilledCircle(x, y, z, d2)
        else
          draw:Outline(x, y, z, d2)
        end
        draw:SetColor(235 - bin(tengage) * 80, 90 + bin(tengage) * 90, 35, normalize((d < d3 and d > d2 and 185 or 125) - trMod))
        if d < d3 and d > d2 then
          draw:FilledCircle(x, y, z, d3)
        elseif d > d2 then
          draw:Outline(x, y, z, d3)
        end
      else  
        -- if not tengage or d < d1 then
          draw:SetColor(15, 225 + bin(tengage) * 20, 35, normalize((d < d1 and 85 or 60) - trMod))
          -- if d < d1 then
            draw:FilledCircle(x, y, z, d1)
          -- else
          --   draw:Outline(x, y, z, d1)
          -- end
        -- end

        -- if not tengage or d < d2 then
          --draw:SetColor(244 - bin(tengage) * 85, 195 + bin(tengage) * 60, 45, (d < d1 and 20 or d < d2 and d > d1 and 65 or 55) - trMod)
          draw:SetColor(244 - bin(tengage) * 85, 195 + bin(tengage) * 60, 45, normalize((d < d1 and 20 or d < d2 and d > d1 and 65 or 55) - trMod))


          if d < d3 then
            draw:FilledCircle(x, y, z, d2)
          else
            draw:Outline(x, y, z, d2)
          end
        -- end

        --draw:SetColor(235 - bin(tengage) * 80, 90 + bin(tengage) * 90, 35, (d < d3 and d > d2 and 25 or 15) - trMod)
        draw:SetColor(235 - bin(tengage) * 80, 90 + bin(tengage) * 90, 35, normalize((d < d3 and d > d2 and 25 or 15) - trMod))
        if d < d3 and d > d2 then
          draw:FilledCircle(x, y, z, d3)
        elseif d > d2 then
          draw:Outline(x, y, z, d3)
        end
      end

      if tt.moving then
        local info = trap:travelInfo(tt)
        local travel, maxReach = info.travel, info.unit.maxReach
        local px, py, pz = tt.predictPosition(travel / predDivisor)
        draw:SetColor(155, 165, 255, 255)
        -- draw:Line(x, y, z, px, py, pz)
        draw:Circle(px, py, pz, 0.5)
      end

      if hunter.trapKeyPresses >= 2 or not trap.cuckable and hunter.trapKeyPresses >= 1 then
        trap.commitDelay = 0
      end
      if hunter.trapKeyPresses >= 1 then
        draw:SetColor(205, 255,210, 215)
        draw:Text("Press Trap Key Again to Force", BlinkFontNormal, x, y, z - 2)
      end

      if trap.elapsed and trap.cuckable and hunter.trapKeyPresses <= 1 then
        draw:SetColor(235 - bin(trap.elapsed > trap.commitDelay) * 130, 214, 255 - bin(trap.elapsed > trap.commitDelay) * 160, 255)
        local txt = trap.elapsed > trap.commitDelay and "Ready to commit" or round(trap.elapsed, 1) .. "/" .. round(trap.commitDelay - blink.buffer, 1)
        draw:Text(txt, BlinkFontLarge, x, y, z + 0.5)
      end
    end
  else
    hunter.drawFollowupTrap = nil
  end
  
end)

local checks = 0
hunter.fixKillCommandBug = function()
  -- fix kc stuck queued bug
  if checks > 20 then
    blink.debug.print("cancelling bugged kill command", "debug")
    blink.call("SpellCancelQueuedSpell")
    checks = 0
  else
    if C_Spell.IsCurrentSpell(34026) then
      checks = checks + 1
    else 
      checks = 0 
    end
  end
end 

Scatter:Callback("big dam", function(spell)

  if not player.hasTalent(213691) then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if dontScatter() then return end

  --FIXME 
  -- if player.class2 == "HUNTER" 
  -- and player.spec == "Marksmanship" then
  --   blink.print(blink.textureEscape(213691, 16, "0:2") .. " Auto Scatter Disabled (" .. colors.warlock .. "Afflication Warlock in team|r)")
  -- end

  local lowest = sr.lowest(blink.fgroup)

  blink.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.los then return end
    if enemy.dist > spell.range then return end
    if enemy.immuneCC then return end
    if player.target.isUnit(enemy) then return end
    if enemy.ccr and enemy.ccr > 1 then return end
    -- not into bladestorm
    if enemy.class2 == "WARRIOR" and enemy.buffFrom({389774, 46924, 227847}) then return end
    if player.casting or player.channeling then return end
    if not enemy.isPlayer then return end  
    if player.buff(186265) then return end
    if enemy.disorientDR ~= 1 then return end
    if player.buff(199483) then return end
    if enemy.buffFrom({198589, 212800}) then return end
    if enemy.disarmed then return end
    if not saved.autoScatter then return end

    -- Cross CC
    if saved.autoscatterCrossCC
    and enemyHealer.debuff(3355, "player")
    and not player.target.isUnit(enemy)
    and not enemy.isHealer
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.cyan .. "[Cross CC]", spell.id) 
      end
    end
    
    -- Cover our trap from DH
    if enemy.class2 == "DEMONHUNTER"
    and saved.autoscattercover
    and enemyHealer.ccr > 1
    and trap.cd <= 0.5
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.dh .. "[Reverse Magic]", spell.id) 
      end
    end

    -- Cover our trap from grounding
    if enemy.class2 == "SHAMAN"
    and saved.autoscattercover
    and enemyHealer.ccr > 1
    and trap.cd <= 1
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.shaman .. "[Grounding]", spell.id) 
      end
    end

    -- Cover our trap from MD
    if enemy.class2 == "PRIEST"
    and saved.autoscattercover
    and enemy.castID == 341167 
    or  enemy.castID == 32375
    and enemy.debuff(3355, "player")
    and countershot.cd > 0.8
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.cyan .. "[Mass Dispel]", spell.id) 
      end
    end
    
    -- dance 
    if enemy.class2 == "ROGUE"
    and saved.autoscatterCDs
    and enemy.buffRemains(185422) > 2.75 - bin(lowest < 85) * 1.5
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.rogue .. "[Shadow Dance]", spell.id)
      end
    end

    -- Combustion 
    if enemy.class2 == "MAGE"
    and saved.autoscatterCDs
    and enemy.buffRemains(190319) > 2.75 - bin(lowest < 85) * 1.5
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.mage .. "[Combustion]", spell.id)
      end
    end

    -- Glacial spike 
    if enemy.class2 == "MAGE"
    and saved.autoscatterCDs
    and enemy.castID == 199786
    and countershot.cd - blink.gcdRemains > 0
    and enemy.castPct > 70
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.mage .. "[Glacial Spike]", spell.id)
      end
    end

    -- wings
    if enemy.class2 == "PALADIN"
    and saved.autoscatterCDs
    and enemy.role == "melee"
    and enemy.buff(31884)
    and spell:Cast(enemy, {face = true}) then
      if not saved.streamingMode then 
        alert("Scatter " .. colors.paladin .. "[Wings]", spell.id)
      end
    end

    -- hunter shit
    if enemy.class2 == "HUNTER"
    and saved.autoscatterCDs
    and (not healer.exists or healer.cc)
    and (lowest < 75 
      + bin(not healer.exists or healer.cc) * 20
      + bin(enemy.cds) * 25)
    and spell:Cast(enemy, {face = true}) then
      return alert("Scatter " .. enemy.classString, spell.id)         
    end

    -- warrior shit
    if enemy.class2 == "WARRIOR"
    and saved.autoscatterCDs
    and (not healer.exists or healer.cc)
    and (lowest < 75 
      + bin(not healer.exists or healer.cc) * 20
      + bin(enemy.cds) * 25)
    and spell:Cast(enemy, {face = true}) then
      return alert("Scatter " .. enemy.classString, spell.id)         
    end

    --DK Pillar of Frost
    if enemy.buff(51271) 
    and saved.autoscatterCDs
    and enemy.dist > blink.latency / (5 - bin(player.moving) * 1)
    and not player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Pillar of Frost", colors.dk) .. ")", spell.id)
        end
      end
    end   

    -- DK Unholy Assult
    if enemy.buff(207289) 
    and saved.autoscatterCDs
    and player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Unholy Assault", colors.dk) .. ")", spell.id)
        end
      end
    end       

    -- Mage Combustion on player
    if enemy.buff(190319)
    and saved.autoscatterCDs then
    --and not player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Combustion", colors.mage) .. ")", spell.id)
        end
      end
    end
  
    -- Recklessness on player
    if enemy.buff(1719) 
    and saved.autoscatterCDs
    and not player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Recklessness", colors.warrior) .. ")", spell.id)
        end
      end
    end              

    -- Avatar on player
    if enemy.buff(107574) 
    and saved.autoscatterCDs
    and not player.target.isUnit(enemy) then
      if spell.cd <= 0.25 then
        blink.call("SpellCancelQueuedSpell")
        if player.casting or player.channeling then
          blink.call("SpellStopCasting")
        end
        if spell:Cast(enemy, {face = true}) then
          return blink.alert("Scatter Shot (" .. colored("Avatar", colors.warrior) .. ")", spell.id)
        end
      end
    end 

    -- we just need a peel
    if enemy.isPlayer 
    and saved.autoscatterpeel
    and not enemy.immuneCC
    and not enemy.isHealer then
      if lowest < 60 + bin(enemy.cds) * 57 + bin(not healer.exists or healer.cc) * 30 then
        return spell:Cast(enemy, {face = true}) and alert("Scatter " .. enemy.classString, spell.id)
      end
    end

  end)
  
end)

Scatter:Callback("seduction", function(spell)
  if dontScatter() then return end
  if not player.hasTalent(213691) then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  --Seduction
  if blink.fighting(265, 266, 267, true) then 

    blink.enemyPets.loop(function(EnemyPet)

      if not EnemyPet.channelID == 6358 then return end
      if not EnemyPet.exists then return end
      if not EnemyPet.los then return end
      if EnemyPet.dist > 21 then return end
      if EnemyPet.immuneCC then return end
      if player.target.isUnit(EnemyPet) then return end
      if EnemyPet.ccr and EnemyPet.ccr > 1 then return end
      if player.casting or player.channeling then return end
      if player.buff(186265) then return end
      if EnemyPet.disorientDR < 0.5 then return end
      if player.buff(199483) then return end

      if EnemyPet.channelID == 6358
      and countershot.cd - blink.gcdRemains > 0 then
        if spell:Cast(EnemyPet, {face = true}) then
          if not saved.streamingMode then
            alert("Scatter " .. colors.cyan .. "[Seduction]", spell.id) 
          end
        end
      end
    end)
  end
end)

Scatter:Callback("tyrants", function(spell)
  if dontScatter() then return end
  if not player.hasTalent(213691) then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  --tyrant  
  if blink.fighting(266, true) 
  and saved.autoscatterCDs then
    blink.tyrants.loop(function(tyrant)

      if not tyrant.channelID == 6358 then return end
      if not tyrant.exists then return end
      if not tyrant.los then return end
      if tyrant.dist > 21 then return end
      if tyrant.immuneCC then return end
      if player.target.isUnit(tyrant) then return end
      if tyrant.ccr and tyrant.ccr > 1 then return end
      if player.casting or player.channeling then return end
      if player.buff(186265) then return end
      if tyrant.disorientDR < 0.5 then return end
      if player.buff(199483) then return end

      if tyrant.casting 
      and tyrant.castPct > 50 
      and spell:Cast(tyrant, {face = true}) then 
        if not saved.streamingMode then
          alert("Scatter " .. colors.cyan .. "[Tyrant]", spell.id)  
        end
      end
    end)
  end
end)

local FullyImmuneBuffs = 
{
  642, --"Divine Shield",
  45438, --"Ice Block",
  186265, --"Aspect of the Turtle",
  198589, --"Blur",
  212800, --"Blur",
  362486, --Keeper of the Grove
  408558, --priest phase shift
  1022, --"Blessing of Protection",
  196555, --netherwalk
  409293, --Burrow
}

local FullyImmuneDeBuffs = 
{
  33786, --Cyclone
  217832, --Imprison
  203337, --Diamond Ice
}

--immune to hunter CC Stuff Table
local ImmuneToHunterCC = {

	6940, --Blessing of Sacrifice1
  199448, --Blessing of Sacrifice2
  199452, --Blessing of Sacrifice3
  199450, --Blessing of Sacrifice3
	213610, --Holy Ward
	236321, --War Banner
	23920, -- reflect
  8178, --grounding
	-- "Mass Spell Reflection",
	-- "Misshapen Mirror",
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  204018, --Spell Warding
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  353319, --monk retoral
  408558, --priest phase shift
  377362, --precognition
  421453, --Ultimate Penitence

}

--immune to hunter Stun Stuff Table
local ImmuneToHunterStun = {

	213610, --Holy Ward
	-- 236321, --War Banner
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  203337, --dimoand ice
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  353319, --monk retoral
  408558, --priest phase shift
  37683,
  5277,
  118038,
  199754,
  198589,
  212800,
  377362, --precognition
  421453, --Ultimate Penitence
  354610, --dh Glimpse

}

-- Scatter:Callback("command", function(spell)
--   if spell.cd > 0.5 then return end
--   --target
--   if blink.MacrosQueued['scatter target']
--   and target.exists 
--   and player.distanceTo(target) < 25 
--   and target.incapDR >= 0.5 
--   and target.buffsFrom(ImmuneToHunterCC) == 0 then
--     if spell:Cast(target, { face = true }) then
--       return alert("|cFFf7f25c[Manual]: |cFFFFFFFFScatter Shot [" .. target.classString .. "]", spell.id)
--     end
--   elseif blink.MacrosQueued['scatter target'] and not target.exists then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4atarget doesn't exists!", spell.id) 
--   elseif blink.MacrosQueued['scatter target'] 
--   and (target.incapDR < 0.5 or player.distanceTo(target) > 25 or target.immunePhysicalEffects or target.buffsFrom(ImmuneToHunterCC) > 0) then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Scatter Shot! [" .. target.classString .. "]", spell.id)    
--   elseif blink.MacrosQueued['scatter target'] and target.incapDR < 0.5 then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Scatter Shot! [" .. target.classString .. "]", spell.id)	  
--   end		

--   --focus
--   if blink.MacrosQueued['scatter focus']
--   and focus.exists 
--   and player.distanceTo(focus) < 25 
--   and focus.incapDR >= 0.5 
--   and focus.buffsFrom(ImmuneToHunterCC) == 0 then
--     if spell:Cast(focus, { face = true }) then
--       return alert("|cFFf7f25c[Manual]: |cFFFFFFFFScatter Shot [" .. focus.classString .. "]", spell.id)
--     end
--   elseif blink.MacrosQueued['scatter focus'] and not focus.exists then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aFocus doesn't exists!", spell.id) 
--   elseif blink.MacrosQueued['scatter focus'] 
--   and (focus.incapDR < 0.5 or player.distanceTo(focus) > 25 or focus.immunePhysicalEffects or focus.buffsFrom(ImmuneToHunterCC) > 0) then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Scatter Shot! [" .. focus.classString .. "]", spell.id)    
--   elseif blink.MacrosQueued['scatter focus'] and focus.incapDR < 0.5 then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Scatter Shot! [" .. focus.classString .. "]", spell.id)	  
--   end	

--   --arena1
--   if blink.MacrosQueued['scatter arena1']
--   and arena1.exists 
--   and player.distanceTo(arena1) < 25 
--   and arena1.incapDR >= 0.5 
--   and arena1.buffsFrom(ImmuneToHunterCC) == 0 then
--     if spell:Cast(arena1, { face = true }) then
--       return alert("|cFFf7f25c[Manual]: |cFFFFFFFFScatter Shot [" .. arena1.classString .. "]", spell.id)
--     end
--   elseif blink.MacrosQueued['scatter arena1'] and not arena1.exists then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aarena1 doesn't exists!", spell.id) 
--   elseif blink.MacrosQueued['scatter arena1'] 
--   and (arena1.incapDR < 0.5 or player.distanceTo(arena1) > 25 or arena1.immunePhysicalEffects or arena1.buffsFrom(ImmuneToHunterCC) > 0) then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Scatter Shot! [" .. arena1.classString .. "]", spell.id)    
--   elseif blink.MacrosQueued['scatter arena1'] and arena1.incapDR < 0.5 then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Scatter Shot! [" .. arena1.classString .. "]", spell.id)	  
--   end		

--   --arena2
--   if blink.MacrosQueued['scatter arena2']
--   and arena2.exists 
--   and player.distanceTo(arena2) < 25 
--   and arena2.incapDR >= 0.5 
--   and arena2.buffsFrom(ImmuneToHunterCC) == 0 then
--     if spell:Cast(arena2, { face = true }) then
--       return alert("|cFFf7f25c[Manual]: |cFFFFFFFFScatter Shot [" .. arena2.classString .. "]", spell.id)
--     end
--   elseif blink.MacrosQueued['scatter arena2'] and not arena2.exists then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aarena2 doesn't exists!", spell.id) 
--   elseif blink.MacrosQueued['scatter arena2'] 
--   and (arena2.incapDR < 0.5 or player.distanceTo(arena2) > 25 or arena2.immunePhysicalEffects or arena2.buffsFrom(ImmuneToHunterCC) > 0) then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Scatter Shot! [" .. arena2.classString .. "]", spell.id)    
--   elseif blink.MacrosQueued['scatter arena2'] and arena2.incapDR < 0.5 then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Scatter Shot! [" .. arena2.classString .. "]", spell.id)	  
--   end		

--   --arena3
--   if blink.MacrosQueued['scatter arena3']
--   and arena3.exists 
--   and player.distanceTo(arena3) < 25 
--   and arena3.incapDR >= 0.5 
--   and arena3.buffsFrom(ImmuneToHunterCC) == 0 then
--     if spell:Cast(arena3, { face = true }) then
--       return alert("|cFFf7f25c[Manual]: |cFFFFFFFFScatter Shot [" .. arena3.classString .. "]", spell.id)
--     end
--   elseif blink.MacrosQueued['scatter arena3'] and not arena3.exists then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aarena3 doesn't exists!", spell.id) 
--   elseif blink.MacrosQueued['scatter arena3'] 
--   and (arena3.incapDR < 0.5 or player.distanceTo(arena3) > 25 or arena3.immunePhysicalEffects or arena3.buffsFrom(ImmuneToHunterCC) > 0) then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Scatter Shot! [" .. arena3.classString .. "]", spell.id)    
--   elseif blink.MacrosQueued['scatter arena3'] and arena3.incapDR < 0.5 then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Scatter Shot! [" .. arena3.classString .. "]", spell.id)	  
--   end		

--   --enemyhealer
--   if blink.MacrosQueued['scatter enemyhealer']
--   and enemyHealer.exists 
--   and player.distanceTo(enemyHealer) < 25 
--   and enemyHealer.incapDR >= 0.5 
--   and enemyHealer.buffsFrom(ImmuneToHunterCC) == 0 then
--     if spell:Cast(enemyHealer, { face = true }) then
--       return alert("|cFFf7f25c[Manual]: |cFFFFFFFFScatter Shot [" .. enemyHealer.classString .. "]", spell.id)
--     end
--   elseif blink.MacrosQueued['scatter enemyHealer'] and not enemyHealer.exists then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aenemyHealer doesn't exists!", spell.id) 
--   elseif blink.MacrosQueued['scatter enemyHealer'] 
--   and (enemyHealer.incapDR < 0.5 or player.distanceTo(enemyHealer) > 25 or enemyHealer.immunePhysicalEffects or enemyHealer.buffsFrom(ImmuneToHunterCC) > 0) then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Scatter Shot! [" .. enemyHealer.classString .. "]", spell.id)    
--   elseif blink.MacrosQueued['scatter enemyHealer'] and enemyHealer.incapDR < 0.5 then
--     return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Scatter Shot! [" .. enemyHealer.classString .. "]", spell.id)	  
--   end		

-- end)

Scatter:Callback("command", function(spell)

  if not player.hasTalent(spell.id) then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local function tryCastSpellOnTarget(unit)
    if unit.exists
    and unit.enemy
    and player.distanceTo(unit) <= spell.range 
    and unit.incapDR >= 0.5 
    and not unit.buffFrom(ImmuneToHunterCC) then
      if spell:Cast(unit, { face = true }) then
        return alert("|cFFf7f25c[Manual]: |cFFFFFFFFScatter Shot [" .. unit.classString .. "]", spell.id)
      end
    elseif not unit.exists then
      return alert("|cFFf7f25c[Check]: |cFFf74a4aUnit doesn't exists!", spell.id) 
    elseif (player.distanceTo(unit) > spell.range or unit.immuneCC or unit.buffsFrom(ImmuneToHunterCC) > 0) then
      return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Scatter Shot! [" .. unit.classString .. "]", spell.id)    
    elseif unit.incapDR < 0.5 then
      return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Scatter Shot! [" .. unit.classString .. "]", spell.id)      
    end        
  end

  -- Table of possible targets
  local targets = {
    ['scatter target'] = blink.target,
    ['scatter focus'] = blink.focus,
    ['scatter arena1'] = blink.arena1,
    ['scatter arena2'] = blink.arena2,
    ['scatter arena3'] = blink.arena3,
    ['scatter enemyhealer'] = blink.enemyHealer,
  }

  for macro, unit in pairs(targets) do
    if blink.MacrosQueued[macro] and unit then
      tryCastSpellOnTarget(unit)
      break
    end
  end

end)


-- TAR Trap
tartrap:Callback(function(spell)
  if blink.prep then return end
  if target.exists and target.hp <= 20 then return end
  if steeltrap.current then return end
  if player.used(steeltrap.id, 1.5) then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local lowest = sr.lowest(blink.fgroup)

  blink.enemies.loop(function(enemy)

    if not enemy.exists 
    or not enemy.los 
    or not enemy.isPlayer then 
      return 
    end
      
    if enemy.immuneSlows 
    or enemy.distanceLiteral > 12
    or enemy.ccRemains > 1.5 
    or enemy.rootRemains > 1
    or enemy.role ~= "melee"
    or enemy.class2 == "DRUID" then 
      return 
    end

    if lowest <= 80 + bin(enemy.buffsFrom(BigDamageBuffs)) * 57 + bin(not healer.exists or not healer.los or healer.cc) * 30 then
      local gz = blink.GroundZ
      local x, y, z = gz(enemy.predictPosition(0.35))
      if not x then return end
      if spell:AoECast(x,y,z) then
        return alert("|cFFf7f25c[Peel]: |rTar Trap! |r [" .. enemy.classString .. "]", spell.id)
      end
    end

  end)	

end)	

tartrap:Callback("tyrant", function(spell)
  if blink.prep then return end
  if target.exists and target.hp <= 20 then return end
  if steeltrap.current then return end
  if player.used(steeltrap.id, 1.5) then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  -- local TotalPets = blink.enemyPets.around(player, 25)
  -- if TotalPets > 3 then print(">3") end

  blink.tyrants.loop(function(tyrant)

    if tyrant.ccRemains > 1.5
    or tyrant.distanceLiteral > 12 then 
      return 
    end

    local gz = blink.GroundZ
    local x, y, z = gz(tyrant.predictPosition(0.35))
    if not x then return end
    if spell:AoECast(x,y,z) then
      return alert("Tar Trap |cFFf7f25c[Tyrant]", spell.id)
    end

  end)

end)

tartrap:Callback("BM Pet", function(spell, unit)
  if blink.prep then return end
  if target.exists and target.hp <= 30 then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.pets.loop(function(pet)
    if not pet.enemy then return end
    if pet.distance > spell.range then return end
    if not pet.los then return end

    local dontUseIt = pet.immuneSlow or pet.slowed or pet.rooted or pet.ccRemains > 1.5 or pet.distanceLiteral > 10
    if dontUseIt then return end

    local gz = blink.GroundZ
    local x, y, z = gz(pet.predictPosition(0.35))
    if not x then return end

    if pet.buff(186254)
    and pet.buffRemains(186254) > 4
    and player.combat then
      if spell:AoECast(x,y,z) then 
        alert("|cFFf7f25cTar Trap " ..  colors.pink ..(pet.name or "") .. "", spell.id)
      end
    end   
  end) 

end)

tartrap:Callback("tyrant", function(spell)
  if blink.prep then return end
  if target.exists and target.hp <= 20 then return end
  if steeltrap.current then return end
  if player.used(steeltrap.id, 1.5) then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  -- local TotalPets = blink.enemyPets.around(player, 25)
  -- if TotalPets > 3 then print(">3") end

  -- blink.enemyPets.loop(function(enemyPets)

  --   if enemyPets.ccRemains > 1.5
  --   or enemyPets.distanceLiteral > 15 then 
  --     return 
  --   end

  --   local gz = blink.GroundZ
  --   local x, y, z = gz(enemyPets.predictPosition(0.5))
  --   if not x then return end
  --   if spell:AoECast(x,y,z) then
  --     return alert("Tar Trap |cFFf7f25c[enemyPets]", spell.id)
  --   end

  -- end)

end)

-- tartrap:Callback("enemyPets", function(spell)

--   if target.exists and target.hp <= 20 then return end
--   if steeltrap.current then return end
--   if player.used(steeltrap.id, 1.5) then return end
--   if spell.cd - blink.gcdRemains > 0 then return end

--   local TotalPets = blink.enemyPets.around(player, 25)
--   if TotalPets > 3 then print(">3") end

--   blink.enemyPets.loop(function(enemyPets)

--     if enemyPets.ccRemains > 1.5
--     or enemyPets.distanceLiteral > 15 then 
--       return 
--     end

--     local gz = blink.GroundZ
--     local x, y, z = gz(enemyPets.predictPosition(0.5))
--     if not x then return end
--     if spell:AoECast(x,y,z) then
--       return alert("Tar Trap |cFFf7f25c[enemyPets]", spell.id)
--     end

--   end)

-- end)

tartrap:Callback("badpostion", function(spell)
  if blink.prep then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if enemyHealer.class2 == "DRUID" then return end
  if not enemyHealer.los then return end
  if enemyHealer.rootRemains > 1 then return end

  if target.enemy 
  and enemyHealer.exists 
  and not enemyHealer.isUnit(target)
  and (not enemyHealer.losOf(target) or enemyHealer.distanceTo(target) > 40)
  and not enemyHealer.cc then
    if enemyHealer.bcc then return end

    local gz = blink.GroundZ
    local x, y, z = gz(enemyHealer.predictPosition(0.5))
    if not x then return end
    if spell:AoECast(x,y,z) then
      alert("|cFFf7f25c Tar Trap " .. (enemyHealer.classString or "") .. " [Bad Position] ", spell.id)
    end

  end
end)



--Steel Trap
steeltrap:Callback(function(spell)
  if blink.prep then return end
  if target.exists and target.hp <= 20 then return end
  if tartrap.cd == 0 then return end
  if tartrap.current then return end
  if player.used(tartrap.id, 1.5) then return end
  if not player.hasTalent(162488) then return end

	if steeltrap.cd <= 0.25 then

		blink.enemies.loop(function(enemy)
      
      if not enemy.exists then return end

      if enemy.immuneSlow 
      or enemy.distanceLiteral > 12
      or enemy.immunePhysicalDamage 
      or enemy.ccRemains > 1.5 
      or enemy.rootRemains > 1
      or enemy.buff(198589) 
      or enemy.buff(212800) then 
        return 
      end

      if not enemy.los then return end
      if enemy.class2 == "DRUID" then return end

      if (player.hp <= 75 
      or healer.exists and healer.hp <= 75 
      or enemy.buffsFrom(BigDamageBuffs) > 0) 
      and enemy.role == "melee" then
        local gz = blink.GroundZ
        local x, y, z = gz(enemy.predictPosition(0.35))
        if not x then return end
        if spell:AoECast(x,y,z) then
          return alert("|cFFf7f25c[Peel]:|cFFFFFFFF Steel Trap! [" .. enemy.classString .. "]", spell.id)
        end
      end	
		end)
    
	end							
end)	

steeltrap:Callback("tyrant", function(spell)
  if blink.prep then return end
  if target.exists and target.hp <= 20 then return end
  if tartrap.cd == 0 then return end
  if tartrap.current then return end
  if player.used(tartrap.id, 1.5) then return end
  if not player.hasTalent(162488) then return end

  if steeltrap.cd <= 0.25 then

    blink.tyrants.loop(function(tyrant)

      if not tyrant.los then return end

      if tyrant.ccRemains > 1.5
      or tyrant.distanceLiteral > 12 then 
        return 
      end

      local gz = blink.GroundZ
      local x, y, z = gz(tyrant.predictPosition(0.35))
      if not x then return end
      if spell:AoECast(x,y,z) then
        return alert("Steel Trap |cFFf7f25c[Tyrant]", spell.id)
      end

    end)

  end

end)

steeltrap:Callback("badpostion", function(spell)
  if blink.prep then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if enemyHealer.class2 == "DRUID" then return end
  if not enemyHealer.los then return end
  if enemyHealer.rootRemains > 1 then return end

  if target.enemy 
  and enemyHealer.exists 
  and not enemyHealer.isUnit(target)
  and (not enemyHealer.losOf(target) or enemyHealer.distanceTo(target) > 40)
  and not enemyHealer.cc then

    if enemyHealer.bcc then return end

    local gz = blink.GroundZ
    local x, y, z = gz(enemyHealer.predictPosition(0.35))
    if not x then return end
    if spell:AoECast(x,y,z) then
      alert("|cFFf7f25c Steel Trap " .. (enemyHealer.classString or "") .. " [Bad Position] ", spell.id)
    end

  end
end)

--Binding Shot By Command
-- bindingshot:Callback("command", function(spell)

--   if not player.hasTalent(spell.id) then return end

-- 	if blink.MacrosQueued['binding target'] then
-- 		if player.distanceTo(target) <= 30 then 
-- 			if spell:SmartAoE(target, { diameter = 15, range = 30, movePredTime = blink.buffer, ignoreFriends = true}) then
-- 				alert("|cFFf7f25c[Manual]: |cFFFFFFFFBinding Shot! [" .. target.classString .. "]", spell.id)
-- 			end 
-- 		end	
-- 	elseif blink.MacrosQueued['binding focus'] then
-- 		if player.distanceTo(focus) <= 30 then 
-- 			if spell:SmartAoE(focus, { diameter = 15, range = 30, movePredTime = blink.buffer, ignoreFriends = true}) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFBinding Shot! [" .. focus.classString .. "]", spell.id)
-- 			end 
-- 		end
--   elseif blink.MacrosQueued['binding arena1'] then
-- 		if player.distanceTo(arena1) <= 30 then 
-- 			if spell:SmartAoE(arena1, { diameter = 15, range = 30, movePredTime = blink.buffer, ignoreFriends = true}) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFBinding Shot! [" .. arena1.classString .. "]", spell.id)
-- 			end 
-- 		end
--   elseif blink.MacrosQueued['binding arena2'] then
-- 		if player.distanceTo(arena2) <= 30 then 
-- 			if spell:SmartAoE(arena2, { diameter = 15, range = 30, movePredTime = blink.buffer, ignoreFriends = true}) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFBinding Shot! [" .. arena2.classString .. "]", spell.id)
-- 			end 
-- 		end
--   elseif blink.MacrosQueued['binding arena3'] then
-- 		if player.distanceTo(arena3) <= 30 then 
-- 			if spell:SmartAoE(arena3, { diameter = 15, range = 30, movePredTime = blink.buffer, ignoreFriends = true}) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFBinding Shot! [" .. arena3.classString .. "]", spell.id)
-- 			end 
-- 		end
--   elseif blink.MacrosQueued['binding enemyhealer'] then
-- 		if player.distanceTo(enemyHealer) <= 30 then 
-- 			if spell:SmartAoE(enemyHealer, { diameter = 15, range = 30, movePredTime = blink.buffer, ignoreFriends = true}) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFBinding Shot! [" .. enemyHealer.classString .. "]", spell.id)
-- 			end 
-- 		end
-- 	end			
-- end)	

bindingshot:Callback("command", function(spell)

  if not player.hasTalent(spell.id) then return end

  local function tryCastSpellOnTarget(unit)
    if player.distanceTo(unit) <= 30 then 
      if spell:SmartAoE(unit) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBinding Shot! [" .. unit.classString .. "]", spell.id)
      end 
    end
  end

  -- Table of possible targets
  local targets = {
    ['binding target'] = blink.target,
    ['binding focus'] = blink.focus,
    ['binding arena1'] = blink.arena1,
    ['binding arena2'] = blink.arena2,
    ['binding arena3'] = blink.arena3,
    ['binding enemyhealer'] = blink.enemyHealer,
  }

  for macro, unit in pairs(targets) do
    if blink.MacrosQueued[macro] and unit then
      tryCastSpellOnTarget(unit)
      break -- Exit after the first successful cast attempt
    end
  end


end)

--cover trap from DH 
bindingshot:Callback("cover stuff", function(spell)

  if not player.hasTalent(spell.id) then return end
  if player.hasTalent(203340) then return end --Diamond Ice

  if saved.autocoverdh and player.hasTalent(109248) then
    local DH = blink.enemies.find(function(obj) return obj.class2 == "DEMONHUNTER" and obj.enemy end)
    if not DH then return end
      
    if DH and (enemyHealer.debuff(3355)
    and enemyHealer.debuffRemains(3355) >= 2
    or enemyHealer.stunned and enemyHealer.disorientDR == 1 and trap.cd - blink.gcdRemains <= 1)
    and DH.enemy
    and player.distanceTo(DH) <= 30
    and DH.cooldown(205604) <= 3 
    and not (DH.immuneSlow or DH.immuneMagicEffects) then
      if spell:SmartAoE(DH) then
        alert("|cFFf7f25c[Cover Trap]: |cFFFFFFFFBinding Shot[" .. DH.classString .. "]", spell.id)
      end
    end
  end

  --Monk Clones
  -- local MonkClones = blink.units.find(function(obj) return obj.id == 69791 and obj.enemy end) or blink.units.find(function(obj) return obj.id == 69792 and obj.enemy end)
  -- local DH = blink.enemies.find(function(obj) return obj.class2 == "DEMONHUNTER" end)
  -- if saved.autobindingClones and MonkClones then 
  --   if DH and DH.enemy then return end
  --   if MonkClones and MonkClones.enemy then
  --     if spell:SmartAoE(MonkClones, { diameter = 15, range = 30, movePredTime = blink.buffer}) then
  --       alert("Binding Shot [" .. MonkClones.classString .. "]", spell.id)
  --     end
  --   end
  -- end

end)

local TranqMePls = {
  360827, --Blistering Scales
  213610, --Holy Word
  10060,  --Power Infusion
  342242, --Mage Timewrap
  80240,  --Havoc
  1022,   --Blessing of Protection
  132158, --Druid Nature's Swiftness
  378081, --Shaman Nature's Swiftness
  342246, --Mage Alter time
  198111, --Mage Alter time
  1044,   --Blessing of Freedom2
  305497, --Thorns
  11426,  --Mage barrier
  198094, --Mage barrier
  414661, --Mage barrier
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  210294, --divine-favor
  79206,  --Spiritwalker's Grace
}

-- local function SettingsCheck(settingsVar, buff)
--   for k, v in pairs(settingsVar) do
--     if k == buff and v == true then return true end
--     if type(v) == "table" then
--       for _, id in ipairs(v) do
--         if buff == id then return true end
--       end
--     end
--   end
-- end

-- tranqz
-- Priority list of buff IDs
local TranqPrio = {
  167385, --test
  360827, -- Blistering Scales
  213610, -- Holy Word
  10060,  -- Power Infusion
  342242, -- Mage Timewarp
  80240,  -- Havoc
  1022,   -- Blessing of Protection
  132158, -- Druid Nature's Swiftness
  378081, -- Shaman Nature's Swiftness
  342246, -- Mage Alter Time
  198111, -- Mage Alter Time
  1044,   -- Blessing of Freedom2
  305497, -- Thorns
  11426,  -- Mage Barrier
  198094, -- Mage Barrier
  414661, -- Mage Barrier
  378464, -- Nullifying Shroud
  383618, -- Nullifying Shroud2
  210294, -- Divine Favor
  79206,  -- Spiritwalker's Grace
}

local function SettingsCheck(settingsVar, buffId)
  -- Check if the buffId is included in any of the tables
  for _, v in pairs(settingsVar) do
    if type(v) == "table" and tContains(v, buffId) then
      return true
    end
  end
  return false
end

local function HasPriorityBuffs(enemy)
  for _, prioBuffId in ipairs(TranqPrio) do
    if enemy.buff(prioBuffId) and SettingsCheck(saved.tranqList, buffId) then
      return true, prioBuffId
    end
  end
  return false, nil
end

tranq:Callback(function(spell, unit)
  if not saved.AutoTranq then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  -- camo
  if player.buff(199483) then return end

  -- Create a table to store prioritized enemies
  local prioritizedEnemies = {}

  blink.enemies.loop(function(enemy)
    if not enemy.isPlayer then return end
    if not enemy.los then return end
    if enemy.dist > spell.range then return end
    if enemy.buffFrom({45438, 642, 362486, 186265, 196555, 409293}) then return end
    if enemy.debuff(203337) then return end

    -- Check for priority buffs
    local hasPrioBuff, prioBuffId = HasPriorityBuffs(enemy)
    if hasPrioBuff then
      sr.debugPrint("Casting Tranq on:", enemy.name, "For Priority Buff ID:", prioBuffId)
      return spell:Cast(enemy, {face = true}) and alert("Tranq Shot (" .. enemy.classString .. ")", spell.id)
    end

    for i = 1, #enemy.buffs do
      local buffDetails = enemy['buff'..i]
      if buffDetails then
        local _, _, _, _, _, _, _, _, _, buffId = unpack(buffDetails)
        if SettingsCheck(saved.tranqList, buffId) then
          table.insert(prioritizedEnemies, {enemy = enemy, buffId = buffId})
        end
      end
    end
  end)

  -- If prioritized enemies found, cast on the first one
  if #prioritizedEnemies > 0 then
    local priorityTarget = prioritizedEnemies[1]
    sr.debugPrint("Casting Tranq on:", priorityTarget.enemy.name, "For Buff ID:", priorityTarget.buffId)
    return spell:Cast(priorityTarget.enemy, {face = true}) and alert("Tranq Shot (" .. priorityTarget.enemy.classString .. ")", spell.id)
  end

  -- If no prioritized enemies found, proceed with normal logic
  blink.enemies.loop(function(enemy)
    if not enemy.isPlayer then return end
    if not enemy.los then return end
    if enemy.dist > spell.range then return end
    if enemy.buffFrom({45438, 642, 362486, 186265, 196555, 409293}) then return end
    if enemy.debuff(203337) then return end

    for i = 1, #enemy.buffs do
      local buffDetails = enemy['buff'..i]
      if buffDetails then
        local _, _, _, _, _, _, _, _, _, buffId = unpack(buffDetails)
        if SettingsCheck(saved.tranqList, buffId) then 
          sr.debugPrint("Casting Tranq on:", enemy.name, "For Buff ID:", buffId)
          return spell:Cast(enemy, {face = true}) and alert("Tranq Shot (" .. enemy.classString .. ")", spell.id)
        end
      end
    end

    -- tranq dart
    if player.hasTalent(356015) then
      if target.buffFrom({45438, 642, 362486, 186265}) then return end
      if enemy.debuff(203337) then return end

      if target.purgeCount > 1 then
        if spell:Cast(target, { face = true }) then
          blink.alert("Tranq Darts (" .. target.class .. ")", spell.id)
          return true
        end
      end

      local bestUnit, bestCount = false, 0
      if enemy.buffFrom({45438, 642, 362486, 186265}) then return end
      local purgeCount = enemy.purgeCount
      if purgeCount > bestCount then
        bestUnit = enemy
        bestCount = purgeCount
      end
      
      if bestUnit then
        return spell:Cast(bestUnit, {face = true}) and alert("Tranq Darts (" .. bestUnit.class .. ")", spell.id)
      end
    end
  end)
end)

-- local function SettingsCheck(settingsVar, buffId)

--   -- Check if the buffId is included in any of the tables
--   for _, v in pairs(settingsVar) do
--     if type(v) == "table" and tContains(v, buffId) then
--       return true
--     end
--   end

--   return false
-- end

-- tranq:Callback(function(spell, unit)
--   if not saved.AutoTranq then return end
--   if spell.cd - blink.gcdRemains > 0 then return end
--   --camo
--   if player.buff(199483) then return end

--   blink.enemies.loop(function(enemy)

--     if not enemy.isPlayer then return end
--     if not enemy.los then return end
--     if enemy.dist > spell.range then return end
--     if enemy.buffFrom({45438, 642, 362486, 186265, 196555, 409293}) then return end
--     if enemy.debuff(203337) then return end

--     for i = 1, #enemy.buffs do
--       local buffDetails = enemy['buff'..i]
--       if buffDetails then
--         local _, _, _, _, _, _, _, _, _, buffId = unpack(buffDetails)
--         if SettingsCheck(saved.tranqList, buffId) then 
--           sr.debugPrint("Casting Tranq on:", enemy.name, "For Buff ID:", buffId)
--           return spell:Cast(enemy, {face = true}) and alert("Tranq Shot (" .. enemy.classString .. ")", spell.id)
--         end
--       end
--     end
  
--     --tranq dart
--     if player.hasTalent(356015) then

--       if target.buffFrom({45438, 642, 362486, 186265}) then return end
--       if enemy.debuff(203337) then return end

--       if target.purgeCount > 1 then
--         if spell:Cast(target, { face = true }) then
--           blink.alert("Tranq Darts (" .. target.class .. ")", spell.id)
--           return true
--         end
--       end

--       local bestUnit, bestCount = false, 0
--       if enemy.buffFrom({45438, 642, 362486, 186265}) then return end
--       local purgeCount = enemy.purgeCount
--       if purgeCount > bestCount then
--         bestUnit = enemy
--         bestCount = purgeCount
--       end
      
--       if bestUnit then
--         return spell:Cast(bestUnit, {face = true}) and alert("Tranq Darts (" .. bestUnit.class .. ")", spell.id)
--       end
    
--     end

--   end)
-- end)
-- tranqz
-- tranq:Callback(function(spell, unit)
--   if spell.cd - blink.gcdRemains > 0 then return end
--   if player.buff(camo.id) then return end

--   blink.enemies.loop(function(enemy)
--     if not enemy.isPlayer then return end
--     if not enemy.los then return end
--     if enemy.distLiteral > spell.range then return end
--     if enemy.buffFrom({45438, 642, 362486, 186265}) then return end
--     --if not enemy.buffFrom(TranqMePls) then return end

--     -- Tranqs
--     if enemy.buffFrom(TranqMePls) 
--     and enemy.los
--     and spell:Cast(enemy, { face = true }) then
--       return alert("Tranq Shot (" .. enemy.classString .. ")", spell.id)
--     end    

--     --tranq dart
--     if player.hasTalent(356015) then
--       if target.buffFrom({45438, 642, 362486, 186265}) then return end
--       if target.purgeCount > 1 then
--         if spell:Cast(target, { face = true }) then
--           blink.alert("Tranq Darts (" .. target.class .. ")", spell.id)
--           return true
--         end
--       end

--       local bestUnit, bestCount = false, 0
--       if enemy.buffFrom({45438, 642, 362486, 186265}) then return end
--       local purgeCount = enemy.purgeCount
--       if purgeCount > bestCount then
--         bestUnit = enemy
--         bestCount = purgeCount
--       end
--       if bestUnit then
--         return spell:Cast(bestUnit, {face = true}) and alert("Tranq Darts (" .. bestUnit.class .. ")", spell.id)
--       end
      
--     end

--   end)

-- end)


tranq:Callback("MC", function(spell)
  if not saved.AutoTranq then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if player.buff(camo.id) then return end

  local MCed = blink.group.within(spell.range).find(function(member)
    return member.debuff(605)
    and member.disorient
    and member.los
  end)

  if MCed then
    if spell:Cast(MCed, { face = true }) then
      alert(colors.cyan .. "Purging MC from Friendly (" .. MCed.name .. ")", spell.id)
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
  threshold = threshold + bin(not healer.exists or healer.cc) * 25

  if player.hp < threshold and self:Use() then
    blink.alert("Healthstone "..colors.red.."[low hp]", self.spell)
  end
end

-- flare
flare:Callback("restealth", function(spell)
  if not saved.AutoFlare then return end
  if blink.prep then return end
  local time = blink.time

  for key, tracker in ipairs(sr.StealthTracker) do
    local x, y, z = unpack(tracker.pos)
    if x and y and z then
      local elapsed = (tracker.init and time - tracker.init or buffer) + buffer
      local dist = elapsed * tracker.velocity
      local fx, fy, fz = x + dist * cos(tracker.dir), y + dist * sin(tracker.dir), z
      local extraElapsed = (player.distanceToLiteral(fx, fy, fz) / 24)
      local extraDist = extraElapsed * tracker.velocity
      fx, fy, fz = x + extraDist * cos(tracker.dir), y + extraDist * sin(tracker.dir), z
      if player.losCoordsLiteral(fx, fy, fz) and spell:AoECast(fx, fy, fz) then
        if not sr.streamingMode then
          sr.flareDraw = { pos = {fx, fy, fz}, tracker = tracker, time = time }
        end
        if not saved.streamingMode then
          alert("Flare " .. tracker.class .. "|cFFf74a4a[" .. C_Spell.GetSpellInfo(tracker.spellID).name .. "|cFFf74a4a]", spell.id)
        end
      end
    end
  end

end)

flare:Callback("stealth", function(spell)
  if not saved.AutoFlare then return end
  if blink.prep then return end
  return enemies.stomp(function(enemy, uptime)
    if enemy.distLiteral > spell.range then return end
    if not enemy.isPlayer then return end
    if enemy.buffFrom({185422, 185313, 188501}) then return end --121471 blades check if it solve or cause issues

    if enemy.stealth then
      local x,y,z = enemy.predictPosition(0.35)
      if spell:AoECast(x,y,z) then
        if not saved.streamingMode then
          alert("Flare " .. (enemy.class or "") .. "|cFFf74a4a[Stealth]", spell.id)
        end
      end
    end

  end)
end)

flare:Callback("friendly", function(spell)
  if blink.prep then return end
  if not blink.arena then return end
  if not fhealer.debuff(2094) then return end

  if blink.arena 
  and fhealer.exists
  and fhealer.los
  and player.distanceTo(fhealer) < 36 
  and fhealer.debuff(2094) then

    local x,y,z = fhealer.position()

    if spell:AoECast(x,y,z) then 
      if not saved.streamingMode then
        alert("Flare " .. (fhealer.name or "") .. "|cFFf74a4a[Prevent Sap]", spell.id)
      end
    end

  end

end)

--immune to hunter CC Stuff Table
local ImmuneToHunterCC = {

  377362, --new DF kicking immune
	6940, --Blessing of Sacrifice1
  199448, --Blessing of Sacrifice2
  199452, --Blessing of Sacrifice3
	213610, --Holy Ward
	236321, --War Banner
	23920, -- reflect
  8178, --grounding
	-- "Mass Spell Reflection",
	-- "Misshapen Mirror",
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  204018, --Spell Warding
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  377362, --Precognition
  377360, --Precognition

}

--Trapping Queue
local gz = blink.GroundZ

local function WeCanTrap(unit)
  if not unit.exists then
    blink.alert("|cFFf7f25c[Check]: |cFFf74a4aUnit doesn't exist!", trap.id) 
    return false
  end

  local distanceToUnit = player.distanceToLiteral(unit)
  local canTrapFar = distanceToUnit >= 9
    and distanceToUnit <= 38
    and (unit.stunRemains >= 0.2 or unit.rooted or unit.ccRemains >= 0.2)
  local canTrapNear = distanceToUnit < 9
    and (unit.stunRemains >= 0.2 or unit.rooted or unit.ccRemains >= 0.2 or unit.slowed or distanceToUnit <= 5 or unit.debuff(14268) or unit.debuff(5116))

  if (canTrapFar or canTrapNear) 
     and unit.incapDR >= 0.5 
     and unit.buffsFrom(ImmuneToHunterCC) == 0 
     and not (unit.immuneMagicEffects or unit.buff(8178)) then
    return true
  end

  local errorMessage = "|cFFf7f25c[Check]: |cFFf74a4aCan't Freezing Trap! [" .. unit.classString .. "]"
  if unit.incapDR < 0.5 then
    blink.alert(errorMessage .. " Waiting DR To use Freezing Trap!", trap.id)	  
  elseif unit.stunRemains < 0.2 or distanceToUnit > 39 or unit.immuneMagicEffects or unit.buffsFrom(ImmuneToHunterCC) > 0 or unit.buff(8178) then
    blink.alert(errorMessage, trap.id)    
  end

  return false
end



function sr.trapCommand()

  local queued = blink.MacrosQueued

  if blink.time - hunter.lastTrapKey < 2.5 then
    hunter.listen = true
    --if saved.DebugMode then blink.print("Listen = true") end
    local status = trap:pursue(hunter.trapTarget)
    if status and trap.cd < 4 and type(status) == "string" then
      shortalert(status, trap.id)
    end
  else
    hunter.listen = false
    --if saved.DebugMode then blink.print("Listen = false") end
  end

  if queued["trap test"] and WeCanTrap(focus) then 
    return trap("test", focus)
  elseif queued["trap focus"] and WeCanTrap(focus) then 
    return trap("normal", focus)
  elseif queued["trap arena1"] and WeCanTrap(arena1) then
    return trap("normal", arena1)
  elseif queued["trap arena2"] and WeCanTrap(arena2) then
    return trap("normal", arena2)
  elseif queued["trap arena3"] and WeCanTrap(arena3) then
    return trap("normal", arena3)
  elseif queued["trap enemyhealer"] or queued["trap enemyHealer"] and enemyHealer.exists then
    return trap("normal", enemyHealer)
  end
end



-- trap:Callback("command", function(spell)

--   --focus
--   if blink.MacrosQueued['trap focus'] then
--     if WeCanTrap(focus) then 
--       local x, y, z = gz(focus.predictPosition(0.3))
--       if not x then return end
--       if spell:AoECast(x,y,z) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFFreezing Trap [" .. focus.classString .. "]", spell.id)
--       end
--     end
--   end

--   --arena1
--   if blink.MacrosQueued['trap arena1'] then
--     if WeCanTrap(arena1) then 
--       local x, y, z = gz(arena1.predictPosition(0.3))
--       if not x then return end
--       if spell:AoECast(x,y,z) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFFreezing Trap [" .. arena1.classString .. "]", spell.id)
--       end
--     end
--   end

--   --arena2
--   if blink.MacrosQueued['trap arena2'] then
--     if WeCanTrap(arena2) then 
--       local x, y, z = gz(arena2.predictPosition(0.3))
--       if not x then return end
--       if spell:AoECast(x,y,z) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFFreezing Trap [" .. arena2.classString .. "]", spell.id)
--       end
--     end
--   end

--   --arena3
--   if blink.MacrosQueued['trap arena3'] then
--     if WeCanTrap(arena3) then 
--       local x, y, z = gz(arena3.predictPosition(0.3))
--       if not x then return end
--       if spell:AoECast(x,y,z) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFFreezing Trap [" .. arena3.classString .. "]", spell.id)
--       end
--     end
--   end

--   --enemyhealer
--   if blink.MacrosQueued['trap enemyhealer'] then
--     if WeCanTrap(enemyHealer) then 
--       local x, y, z = gz(enemyHealer.predictPosition(0.3))
--       if not x then return end
--       if spell:AoECast(x,y,z) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFFreezing Trap [" .. enemyHealer.classString .. "]", spell.id)
--       end
--     end
--   end 
-- end)

--Intimidation
local function WeCanStun(unit)

  if unit.exists 
  and unit.enemy
  and unit.buffsFrom(ImmuneToHunterStun) == 0 
  and unit.stunDR >= 0.5 
  and unit.ccRemains < 2
  and not unit.immunePhysicalEffects 
  and not unit.immuneStuns 
  and not pet.cc 
  and not pet.rooted
  and not unit.buffFrom({377362, 203337, 408558}) then 

    return true

  else

    local errorMessage = "|cFFf7f25c[Check]: |cFFf74a4a"

    if not unit.exists then
      blink.alert(errorMessage .. "Unit doesn't exist!", intimidation.id) 
    elseif (unit.immuneStuns or unit.immunePhysicalEffects or unit.buffsFrom(ImmuneToHunterStun) > 0) then
      blink.alert(errorMessage .. "Can't Intimidation! [" .. (unit.classString or "") .. "]", intimidation.id)    
    elseif unit.stunDR < 0.5 then
      blink.alert(errorMessage .. "Waiting DR To use Intimidation on [" .. (unit.classString or "") .. "]", intimidation.id)	  
    end

  end		
end

intimidation:Callback("command", function(spell)
  
  if spell.cd - blink.gcdRemains > 0 then return end

  local Queued = (blink.MacrosQueued['stun focus'] 
  or blink.MacrosQueued['stun target'] 
  or blink.MacrosQueued['stun arena1'] 
  or blink.MacrosQueued['stun arena2'] 
  or blink.MacrosQueued['stun arena3']
  or blink.MacrosQueued['stun enemyhealer'])

  local function AttemptStun(unit)
    if not WeCanStun(unit) then return end

    -- Check if pet is too far from the unit and not rooted, then cast Dash
    if Queued then
      if pet.distanceToLiteral(unit) > 39 and dash.cd == 0 and not pet.rooted then
        dash:Cast()
      elseif pet.rooted and isFreedomKnown() and not blink.fighting(102, true) then --we have freedom pet and not fighting booma
        freedom:Cast(player)
      else
        if spell:Cast(unit) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFIntimidation! [" .. (unit.classString or "") .. "]", spell.id)
        end
      end
    end
  end

  if blink.MacrosQueued['stun focus'] then
    AttemptStun(focus)
  elseif blink.MacrosQueued['stun target'] then
    AttemptStun(target)
  elseif blink.MacrosQueued['stun arena1'] then
    AttemptStun(arena1)
  elseif blink.MacrosQueued['stun arena2'] then
    AttemptStun(arena2)
  elseif blink.MacrosQueued['stun arena3'] then
    AttemptStun(arena3)
  elseif blink.MacrosQueued['stun enemyhealer'] then
    AttemptStun(enemyHealer)
  end
end)

intimidation:Callback("auto", function(spell)

  --if saved.autoStun then
  --Automatically use intimidation to secure trap on the trap target.\n\nRoutine will wait for incap DR on trap target and defensives on the kill target before stunning.
  if trap.cd - blink.gcdRemains > 0 then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local tar = saved.autoStunTarget
  if tar == "none" then return end

  --stun trap unit
  if tar == "stunTrapUnit"
  and hunter.trapTarget.exists
  and pet.distanceTo(hunter.trapTarget) < 40
  and hunter.trapTarget.incapDR == 1
  and hunter.trapTarget.stunDR > 0.5
  and hunter.trapTarget.ccRemains < 1 
  and hunter.trapTarget.los
  and target.exists
  and target.los
  and target.hp < 90
  and not target.immunePhysicalDamage
  and not hunter.trapTarget.buffFrom({199450, 199448, 199452, 6940}) 
  and not player.buff(410201) then

    if WeCanStun(hunter.trapTarget) then 

      if not WeCanStun(hunter.trapTarget) then return end

      if spell:Cast(hunter.trapTarget, {face = true}) then
        alert("|cFFf7f25c[Auto]: |cFFFFFFFFIntimidation! [" .. hunter.trapTarget.classString .. "]", spell.id)
      end	 

    end
  end

  --stun target
  if tar == "stunKillTarget"
  and target.exists
  and target.distance <= 40
  and target.incapDR == 1
  and target.stunDR > 0.5
  and target.ccRemains < 1
  and target.los
  and target.hp < 90
  and hunter.trapTarget.exists
  and hunter.trapTarget.ccRemains > 2.5
  and not target.immunePhysicalDamage then

    if WeCanStun(target) then 

      if not WeCanStun(target) then return end

      if spell:Cast(target, {face = true}) then
        alert("|cFFf7f25c[Auto]: |cFFFFFFFFIntimidation! [" .. target.classString .. "]", spell.id)
      end	 

    end
  end
end)

--TURTLE 
turtle:Callback(function(spell)
  if saved.GreedyTurtle then return end
  if player.hp > saved.turtle then return end

  local count, _, _, cds = player.v2attackers()
  if count == 0 then return end

  if player.hp <= saved.turtle and not saved.dontturtleGuardian then
    if player.combat and not (player.cc or player.buff(199448)) then  --or ultimate sac player.buff(199448) ultimate sac -- normal sac = 6940
      if player.casting or player.channeling then
        blink.call("SpellStopCasting")
        blink.call("SpellStopCasting")
      elseif spell:Cast() then
        blink.alert("Aspect of the Turtle", spell.id)
      end	
    end
  elseif player.hp <= saved.turtle and saved.dontturtleGuardian then
    if player.combat 
    and not player.buffFrom({47788, 116849}) then  --dont turtle with Guardian up
      if player.casting or player.channeling then
        blink.call("SpellStopCasting")
        blink.call("SpellStopCasting")
      elseif spell:Cast() then
        blink.alert("Aspect of the Turtle", spell.id)
      end	
    end
  end
end)

turtle:Callback("Greedy", function(spell)
  
  if not blink.hasControl then return end
  if not saved.GreedyTurtle then return end

  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.hp <= saved.turtle) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.turtle) * 0.35)

  if player.hpa > threshold then return end
  if player.hp > saved.turtle then return end
  if not player.combat then return end

  -- Check for Blessing of Protection
  local hasBoP = player.buff(1022)
  
  -- Determine if facing primarily casters
  local facingCasters = blink.enemies.within(40).find(function(enemy)
    return enemy.isPlayer and enemy.los and not enemy.isMelee and not enemy.isHealer
  end) ~= nil  -- Ensure there's at least one matching enemy

  -- Avoid using Turtle if under BoP, unless facing casters
  if hasBoP and not facingCasters then
    if saved.DebugMode then 
      blink.print("Delaying Turtle (BoP is active and no casters detected.)")
    end 
    return 
  end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  end
  
  if player.buffFrom({47788, 116849, 199448}) then return end  
  if player.buff(202748) and player.hp > 20 then return end
  if count == 0 then return end
    
  if spell:Cast() then
    alert("Aspect of the Turtle" ..colors.red .. " [Greedy]", spell.id, true)
  end

end)

turtle:Callback("PVE", function(spell)
  
  if not blink.hasControl then return end
  
  -- local threshold = 17
  -- threshold = threshold + bin(player.hp <= saved.turtle) * 12
  -- threshold = threshold + count * 5
  -- threshold = threshold + cds * 9

  -- threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.turtle) * 0.35)

  -- if player.hpa > threshold then return end
  if player.hp > saved.turtle then return end
  if not player.combat then return end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  end
  
  if player.buffFrom({47788, 116849, 199448}) then return end  
  if player.buff(202748) and player.hp > 20 then return end
    
  if spell:Cast() then
    alert("Aspect of the Turtle" ..colors.orange .. " [PVE]", spell.id, true)
  end

end)


--HEAL 
exhilaration:Callback("Healplayer", function(spell)

  if player.hp > saved.exhilaration then return end

  if not player.debuff(375901) then
	--if pet.exists and player.combat and (pet.hp <= 20 or player.hp <= 30) and not player.debuff(375901) then
		if spell:Cast() then
			blink.alert("Exhilaration", spell.id)
		end	
	end
end)

exhilaration:Callback("Healpet", function(spell)
  if blink.prep then return end
  if pet.hp > saved.Petexhilaration then return end

	if pet.exists 
  and pet.hp <= saved.Petexhilaration 
  and not pet.dead then
		if spell:Cast() then
			blink.alert("Exhilaration Pet - |cFFf7f25c("..pet.name ..")", spell.id)
		end	
	end
end)

exhilaration:Callback("PVE", function(spell)

  if player.hp > saved.exhilaration then return end
  if not player.combat then return end

  return spell:Cast() and blink.alert("Exhilaration", spell.id)
end)

spiritMend:Callback("PVE", function(spell)
  local spiritMendIndex
  local spiritMendAvailable = false
  for i = 1, 10 do
    local name, id = GetPetActionInfo(i)
    if id == 237586 then
      spiritMendIndex = i
      local start, duration = GetPetActionCooldown(i)
      local cooldownRemaining = (start + duration) - GetTime()
      spiritMendAvailable = cooldownRemaining <= 0
      break
    end
  end

  if not spiritMendAvailable then return end

  if not player.buff(264662) then return end
  if player.hp > saved.spiritMendSlider then return end
  if not player.combat then return end
  if not spell:Castable(player) then return end

  -- Attempt to cast Spirit Mend and alert
  if spell:Cast(player) then
    blink.alert("Spirit Mend", spell.id)
  end
end)

--Chimaeral Sting usagle
ChimaeralSting:Callback(function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(356719) then return end
  if trap.used(3) then return end
  if not saved.ChimaeralSting then return end  

  blink.enemies.loop(function(enemy)

    if trap.current then return end
    if enemy.bcc then return end
    if not enemy.stunned then return end
    if enemy.stunRemains < 2.5 then return end
    if not enemy.isHealer then return end
    if not enemy.los then return end

    if trap.cooldown - blink.gcdRemains > ChimaeralSting.gcd then
      if spell:Cast(enemy, { face = true }) then
        alert("|cFFf7f25c Chimaeral Sting " .. (enemy.classString or "") .. " ", spell.id)
      end
    end

  end)
end)

ChimaeralSting:Callback("lockout",function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(356719) then return end
  if not saved.csHealer then return end

  local KickedHoly = enemyHealer.lockouts.holy and enemyHealer.lockouts.holy.remains >= 1
  local KickedNature = enemyHealer.lockouts.nature and enemyHealer.lockouts.nature.remains >= 1

  if trap.current then return end
  if trap.cd - blink.gcdRemains <= 6 and enemyHealer.incapDR == 1 then return end

  if enemyHealer.exists then 
    if enemyHealer.bcc then return end
    if not enemyHealer.los then return end
    if enemyHealer.dist > spell.range then return end
    if enemyHealer.castID == 421453 or enemyHealer.channelID == 421453 then return end

    if KickedHoly or KickedNature then
      if spell:Cast(enemyHealer, { face = true }) then
        alert("|cFFf7f25c Chimaeral Sting " .. (enemyHealer.classString or "") .. " ", spell.id)
      end
    end
  end
end)

ChimaeralSting:Callback("badpostion", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(356719) then return end
  if trap.used(2) then return end
  if not enemyHealer.los then return end
  if enemyHealer.castID == 421453 or enemyHealer.channelID == 421453 then return end

  if target.enemy 
  and enemyHealer.exists 
  and not enemyHealer.isUnit(target)
  and (not enemyHealer.losOf(target) or enemyHealer.distanceTo(target) > spell.range)
  and not enemyHealer.cc then
    if enemyHealer.bcc then return end
    if spell:Cast(enemyHealer, { face = true }) then
      alert("|cFFf7f25c Chimaeral Sting " .. (enemyHealer.classString or "") .. " [Bad Position] ", spell.id)
      return true
    end
  end
end)

-- concu:Callback("tunnel", function(spell, unit)
--   if target.exists and target.hp <= 20 then return end
--   if saved.slowtunnel then
--     if (not enemyHealer.exists or enemyHealer.ccRemains > 3 or enemyhealer.slowed or trap.cd > 3) then
--       if target.moving 
--       and target.enemy
--       --and target.role == "melee"
--       and target.debuffRemains(5116) <= 1.5
--       and player.combat
--       and target.los 
--       and target.distance < 30
--       and not (target.immuneSlow or target.buff(227847) or target.immunePhysicalEffects or target.IsInCC) then --or target.class2 == "HUNTER"
--         if spell:Cast(target, {face = true}) then
--           alert("|cFFf7f25cSlow " .. (target.classString or "") .. "", spell.id)
--         end
--       end   
--     elseif target.buffsFrom(BigDamageBuffs) > 0 then
--       if target.moving 
--       and target.enemy
--       --and target.role == "melee"
--       and target.debuffRemains(5116) <= 1.5
--       and player.combat
--       and target.los 
--       and target.distance < 30
--       and not (target.immuneSlow or target.buff(227847) or target.immunePhysicalEffects or target.IsInCC) then --or target.class2 == "HUNTER"
--         if spell:Cast(target, {face = true}) then
--           alert("|cFFf7f25cSlow " .. (target.classString or "") .. "", spell.id)
--         end
--       end  
--     end
--   end

-- end)

concu:Callback("slowbigdam", function(spell, unit)
  if target.exists and target.hp <= 20 then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if player.buff(camo.id) then return end
  
  if saved.slowbigdam 
  and (not enemyHealer.exists or enemyHealer.ccRemains > 3 or enemyhealer.slowed or trap.cd > 3) then
    blink.enemies.loop(function(enemy)

      if enemy.distance > 30 then return end
      if not enemy.los then return end
      if not enemy.isPlayer then return end
      if enemy.role ~= "melee" then return end
      if enemy.class2 == "DRUID" then return end

      if enemy.immuneSlow 
      or enemy.buff(227847) 
      or enemy.slowed
      or enemy.rooted
      or enemy.immunePhysicalDamage 
      or enemy.IsInCC then
       return 
      end

      if enemy.buffsFrom(BigDamageBuffs) > 0
      and player.combat 
      and enemy.debuffRemains(5116) < 1 then
        if spell:Cast(enemy, {face = true}) then
          alert("|cFFf7f25cSlow " .. (enemy.classString or "") .. "", spell.id)
        end
      end   
    end) 
  end

end)

concu:Callback("tunnel", function(spell, unit)
  if target.exists and target.hp <= 20 then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if player.buff(camo.id) then return end
  if not saved.slowtunnel then return end

  if saved.slowtunnel 
  and (not enemyHealer.exists or enemyHealer.ccRemains > 3 or enemyhealer.slowed or trap.cd > 3) then
    blink.enemies.loop(function(enemy)

      if enemy.distance > 30 then return end
      if not enemy.los then return end
      if not enemy.isPlayer then return end
      if enemy.role ~= "melee" then return end
      if enemy.class2 == "DRUID" then return end

      if enemy.immuneSlow 
      or enemy.buff(227847) 
      or enemy.slowed
      or enemy.rooted
      or enemy.immunePhysicalDamage 
      or enemy.IsInCC then
        return 
      end

      if enemy.target.isUnit(player)
      and enemy.cds or player.hp < 85
      and player.combat 
      and enemy.debuffRemains(5116) < 1
      and not player.target.isUnit(enemy) then
        if spell:Cast(enemy, {face = true}) then
          alert("|cFFf7f25cSlow " .. (enemy.classString or "") .. "", spell.id)
        end
      end   
    end) 
  end

end)

concu:Callback("slow target", function(spell)
  if target.hp <= 30 then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.immunePhysicalEffects then return end
  if target.immuneSlow then return end
  if target.cc then return end
  if player.buff(camo.id) then return end
  if target.slowRemains >= 1 then return end 
  if not target.moving then return end

  if enemyHealer.exists 
  and enemyHealer.ccRemains > 3 
  or enemyhealer.slowed 
  or trap.cd > 3
  or enemyHealer.exists 
  and enemyhealer.idrRemains >= 4 then 
    return spell:Cast(target) and alert("|cFFf7f25cSlow " .. (target.classString or ""), spell.id)
    
  elseif target.slowRemains < 1 
  and not enemyHealer.exists then
    return spell:Cast(target) and alert("|cFFf7f25cSlow " .. (target.classString or ""), spell.id)
  end

end)

-- kill shot
kill:Callback("anyone", function(spell, unit)
  if player.stealth then return end
  blink.enemies.loop(function(enemy)

    if not enemy.isPlayer then return end
    if not enemy.los then return end
    if enemy.hp > 20 then return end

    if enemy.buffFrom(FullyImmuneBuffs) 
    or enemy.debuffFrom(FullyImmuneDeBuffs) then 
      return 
    end

    if enemy.buff(5277) 
    and enemy.facing(blink.player, 225) then
      return 
    end

    if enemy.hp <= 20 then
      return spell:Cast(enemy, {face = true}) and alert(spell.name .." |cFFf7f25c[Execute]", spell.id)
    end

  end)

end)

kill:Callback("execute", function(spell)
  if player.stealth then return end
  if not target.los then return end  

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if target.hp <= 20 then

    -- if saved.DebugMode then 
    --   blink.print("Casting: " .. spell.name .." AT: " .. target.name .. " HP: " .. target.hp)
    -- end

    return spell:Cast(target, {face = true}) and alert(spell.name .." |cFFf7f25c[Execute]", spell.id)
  end

end)

kill:Callback("sv-proc", function(spell)
  if player.stealth then return end
  if not target.los 
    or target.buffFrom(FullyImmuneBuffs) 
    or target.debuffFrom(FullyImmuneDeBuffs) then
    return
  end
  if not player.buffFrom({378770, 378215, 461409}) then
    return 
  end

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return
  end

  return spell:CastAlert(target, {face = true})
end)

kill:Callback("proc", function(spell)
  --sr.debugPrint("Starting Calling Proc")
  if player.stealth then return end
  if not target.los 
    or target.buffFrom(FullyImmuneBuffs) 
    or target.debuffFrom(FullyImmuneDeBuffs) then
    return
  end

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return
  end

  if player.buffFrom({378770, 378215, 461409}) then 
    --sr.debugPrint("Proc after bufffrom")
    return spell:CastAlert(target, {face = true})
  end

  if player.hasTalent(466932) 
  and target.hp <= 20 or target.hp >= 80 then
    --sr.debugPrint("Proc after hastalent")
    return spell:CastAlert(target, {face = true})
  end

  -- if player.specId == 255 then 
  --   if player.buffFrom({378770, 378215, 461409, 360952}) or spell:Castable(target) then 
  --    return spell:CastAlert(target, {face = true})
  --   end
  -- else
  --   if not spell:Castable(target) then return end

  --   return spell:CastAlert(target, {face = true})
  -- end
  -- -- Retrieve player buffs and talent once to avoid redundant checks
  -- local hasBuff378215_461409 = player.buffFrom({378215, 461409})
  -- local hasBuff360952_378215 = player.buffFrom({360952, 378215})
  -- local hasBuff378770 = player.buff(378770)
  -- local hasTalent385739 = player.hasTalent(385739)

  -- -- Handle buff-specific conditions for casting
  -- if hasBuff378215_461409 then
  --   -- Check for nearby enemies with specific condition
  --   if blink.enemies.around(target, 6, function(o) return o.isPlayer and o.bcc end) > 0 then
  --     return
  --   end
  --   return spell:Cast(target, {face = true}) and alert(spell.name .. " |cFFf7f25c[Proc]", spell.id)
  -- end

  -- -- Check other buff/talent combinations for casting
  -- if (hasBuff360952_378215 and hasTalent385739) 
  -- or hasBuff378770 
  -- or spell:Castable(target) then
  --   return spell:Cast(target, {face = true}) and alert(spell.name .. " |cFFf7f25c[Proc]", spell.id)
  -- end

end)

-- kill:Callback("proc", function(spell)

--   if not target.los then return end 

--   if target.buffFrom(FullyImmuneBuffs) 
--   or target.debuffFrom(FullyImmuneDeBuffs) then 
--     return 
--   end

--   if target.buff(5277) 
--   and target.facing(blink.player, 225) then
--     return 
--   end

--   if player.buffFrom({378215, 461409}) then

--     if blink.enemies.around(target, 6, function(o) return o.isPlayer and o.bcc end) > 0 then
--       return
--     end

--     return spell:Cast(target, {face = true}) and alert(spell.name .. " |cFFf7f25c[Proc]", spell.id)
--   else

--     if player.buffFrom({360952, 378215}) 
--       and player.hasTalent(385739) then
--         return spell:Cast(target, {face = true}) and alert(spell.name .. " |cFFf7f25c[Proc]", spell.id)
--       end
--     end

--     if player.buffFrom({378770}) then
--       return spell:Cast(target, {face = true}) and alert(spell.name .. " |cFFf7f25c[Proc]", spell.id)
--     end  
--   end
-- end)

blackArrow:Callback(function(spell)
  if player.hasTalent(466932) then return end
  if target.debuff(spell.id) then return end

  return spell:Cast(target)

end)


-- kill:Callback("proc", function(spell)

--   if not target.los then return end 

--   if target.buffFrom(FullyImmuneBuffs) 
--   or target.debuffFrom(FullyImmuneDeBuffs) then 
--     return 
--   end

--   if target.buff(5277) 
--   and target.facing(blink.player, 225) then
--     return 
--   end

--   if player.buff(461409) then
--     return spell:Cast(target, {face = true}) and alert("Kill Shot |cFFf7f25c[Proc]", spell.id)
--   end

-- end)



--testing

local gz = blink.GroundZ
local testFreezingTrapRadius = 1.3  -- 3 yards trigger radius for Freezing Trap
local testSearchStep = 0.15  -- Increase the step size for faster processing

-- Function to calculate the distance between two points
local function testDistance(x1, y1, x2, y2)
  return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

-- Define a function to get nearby units within a certain range
local function testGetNearbyUnits(obj, maxRange)
  local nearbyUnits = {}
  for _, unit in ipairs(blink.units) do
    if unit.distanceLiteral <= maxRange and unit ~= obj then
      table.insert(nearbyUnits, unit)
    end
  end
  return nearbyUnits
end

-- Function to check if a position is suitable for the trap
local function testIsSuitablePosition(x, y, z, nearbyUnits, targetSize, trapVelocity, targetX, targetY, targetZ)
  local time = testDistance(x, y, targetX, targetY) / trapVelocity
  local predictedX, predictedY, predictedZ = testPredictTrapPosition(x, y, z, 0, 0, 0, trapVelocity, time)
  
  for _, unit in pairs(nearbyUnits) do
    local unitX, unitY, unitZ = gz(unit.position())
    local unitSize = 1.5
    local minDistance = (targetSize + unitSize) / 2 + testFreezingTrapRadius
    if testDistance(predictedX, predictedY, unitX, unitY) <= minDistance then
      return false
    end
  end
  return true
end

-- Function to predict the position of the trap after it has been thrown
function testPredictTrapPosition(x, y, z, dx, dy, dz, velocity, time)
  local newX = x + dx * velocity * time
  local newY = y + dy * velocity * time
  local newZ = z + dz * velocity * time
  return newX, newY, newZ
end

trap:Callback("test", function(spell, obj, msg)
  if not blink.MacrosQueued["trap test"] then return end
  local x, y, z = gz(focus.position())
  if not x then return end

  local targetSize = 0.2
  local trapVelocity = 20.5
  local nearbyUnits = testGetNearbyUnits(focus, testFreezingTrapRadius)

  if #nearbyUnits == 0 then
    if focus.los then
      if spell:AoECast(x, y, z) then
        return msg and alert("Trap " .. focus.classString .. " (" .. msg .. ")", spell.id) or alert("Trap " .. focus.classString, spell.id)
      end
    else
      sr.debugPrint("" .. focus.classString .. " Not LOS, Using Smart.") 
      if spell:SmartAoE(focus, { distanceSteps = 6,
        circleSteps = 12,
        ignoreFriends = true,
        ignorePets = true,
        movePredTime = 0 }) then
        return msg and alert("Test Trap " .. focus.classString .. " (" .. msg .. ")", spell.id) or alert("Test Trap " .. focus.classString, spell.id)
      end
    end
  else
    local bestX, bestY, bestZ
    local bestDistance = math.huge

    local stepLimit = 40 -- Limit the number of steps

    for radius = 0.0, testFreezingTrapRadius + 2.0, testSearchStep do
      if radius > stepLimit * testSearchStep then break end -- Stop after the specified number of steps
      for dx = -radius, radius, testSearchStep do
        for dy = -radius, radius, testSearchStep do
          if (dx * dx + dy * dy) <= radius * radius then
            local newX = x + dx
            local newY = y + dy
            if testIsSuitablePosition(newX, newY, z, nearbyUnits, targetSize, trapVelocity, x, y, z) then
              bestX = newX
              bestY = newY
              bestZ = z
              bestDistance = radius
              break
            end
          end
        end
        if bestX and bestY then break end
      end
      if bestX and bestY then break end
    end

    if bestX and bestY then
      if spell:AoECast(bestX, bestY, bestZ) then
        return msg and alert("Test Trap " .. focus.classString .. " (" .. msg .. ")", spell.id) or alert("Test Trap " .. focus.classString, spell.id)
      end
    else

      sr.debugPrint("No suitable position found")

    end
  end
end)

local ultimatePostion = blink.Item(191383)
function ultimatePostion:use()
  if not IsUsableItem(191383) then return end
  if self.count == 0 then return end
  if self.cd > 0 then return end

  local isBossFight = target.level == 72 or target.level == -1 and player.buff(359844) and player.buffRemains(359844) > 4
  local shouldCastInPvEMode = saved.pveMode ~= "BOSS" or (isBossFight or blink.burst)

  if not shouldCastInPvEMode or not target.enemy 
    or not pet.exists or pet.rooted or pet.cc 
    or target.immunePhysical or target.dist > 40 or not target.los then 
    return 
  end

  --print(self.count)
  
  -- don't use while casting / channeling
  if player.casting or player.channeling then return end

  if self:Use() then
    blink.alert("Ultimate Power Postion", self.spell)
  end
end

trap:Callback("PVE", function(spell)
  --incorporeal id = 204560
  local incorporeal = blink.units.find(function(unit) return unit.id == 204560 and not unit.cc end)
  if not incorporeal then return end

  local x, y, z = gz(incorporeal.position())
  if not x then return end
  if incorporeal.dist > spell.range then return end

  if spell:SmartAoE(incorporeal, { distanceSteps = 6,
    circleSteps = 12,
    ignoreFriends = true,
    ignorePets = true,
    movePredTime = 0 }) then
    return blink.alert("Trap " .. incorporeal.name, spell.id)
  end
end)

hunter.disengage = disengage
hunter.camo = camo
hunter.ros = ros
hunter.SOTF = SOTF
hunter.freedom = freedom
hunter.MMfortitude = MMfortitude
hunter.mark = mark
hunter.feign = feign
hunter.trap = trap
hunter.Scatter = Scatter
hunter.tartrap = tartrap
hunter.steeltrap = steeltrap
hunter.bindingshot = bindingshot
hunter.tranq = tranq
hunter.healthstones = healthstones
hunter.flare = flare
hunter.intimidation = intimidation
hunter.turtle = turtle
hunter.exhilaration = exhilaration
hunter.spiritMend = spiritMend
hunter.ChimaeralSting = ChimaeralSting
hunter.concu = concu
hunter.kill = kill
hunter.dash = dash
hunter.ultimatePostion = ultimatePostion
hunter.blackArrow = blackArrow