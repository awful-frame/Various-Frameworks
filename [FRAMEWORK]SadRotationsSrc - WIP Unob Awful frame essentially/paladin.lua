local Unlocker, blink, sr = ...
local bin, angles, min, max, cos, sin, inverse, sort = blink.bin, blink.AnglesBetween, min, max, math.cos, math.sin, blink.inverseAngle, table.sort
local paladin, ret = sr.paladin, sr.paladin.ret
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local NS, events, cmd, colors, colored = blink.Spell, blink.events, sr.cmd, blink.colors, blink.colored
local UnlockerType = Unlocker.type
local onEvent, onUpdate = blink.addEventCallback, blink.addUpdateCallback
local state = sr.arenaState
local saved = sr.saved
local alert = blink.alert

if not paladin.ready then return end

-- print /reload when spec changes 
--blink.addEventCallback(function() blink.print(colors.paladin .. "Your Specialization Changed , you have to |cFFf7f25c/reload") end, "PLAYER_SPECIALIZATION_CHANGED")

paladin.print = function(str)
  print(colors.paladin .. "|cFFf7f25c[SadRotations]: " .. str)
end
paladin.print("|cFFFFFFFF|r|rCore |cFFf7f25cLoaded")


--Macros
blink.RegisterMacro('burst', 15)
blink.RegisterMacro('pause', 1)
blink.RegisterMacro('pause 1', 1)
blink.RegisterMacro('pause 2', 2)
blink.RegisterMacro('pause 3', 3)
blink.RegisterMacro('pause 4', 4)
blink.RegisterMacro('pause 5', 5)
--HOJ
blink.RegisterMacro("hoj target", 2)
blink.RegisterMacro("hoj focus", 2)
blink.RegisterMacro("hoj arena1", 2)
blink.RegisterMacro("hoj arena2", 2)
blink.RegisterMacro("hoj arena2", 2)
blink.RegisterMacro("hoj enemyhealer", 2)
--blindinglight 
blink.RegisterMacro("blind", 2)
blink.RegisterMacro("blind target", 2)
blink.RegisterMacro("blind focus", 2)
blink.RegisterMacro("blind arena1", 2)
blink.RegisterMacro("blind arena2", 2)
blink.RegisterMacro("blind arena3", 2)
blink.RegisterMacro("blind enemyhealer", 2)
--BOP
blink.RegisterMacro("bop dps", 2)
blink.RegisterMacro("bop healer", 2)
--freedom
blink.RegisterMacro('free healer', 2)
blink.RegisterMacro('free dps', 2)
blink.RegisterMacro('free player', 2)
--steed
blink.RegisterMacro('steed', 2)



local attack = NS(6603)
local sanc = NS(210256, { heal = true, beneficial = true, ignoreFacing = true })

function attack:start()
  if player.stealth then return end
  if not target.exists then return end
  return not self.current and blink.call("StartAttack", "Target")
end

function attack:stop()
  return self.current and StopAttack()
end

function paladin:Attack()
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



local dangerDebuffs = {
  [167105]  = { min = 4, weight = 13 },      -- warbreaker
  [386276]  = { min = 6.5, weight = 15 },    -- bonedust brew
  [274838]  = { min = 4, weight = 7 },       -- frenzy
  [274837]  = { min = 4, weight = 7 },       -- frenzy
  [363830]  = { min = 7.5, weight = 14 },    -- sickle
  [323673]  = { min = 3, weight = 7 },       -- games
  [375901]  = { min = 3, weight = 7 },       -- games
  --[385408]  = { min = 7, weight = 8 },       -- sepsis
  -- [324149] = { min = 5 },                 -- flayed shot
  [79140]   = { min = 7, weight = 18 },      -- vendetta FIXME: ID FOR DF
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
  -- chaos bolt / dark soul bolt
  [116858] = { 
    weight = 12, 
    mod = function(obj, dest) 
      return 1 + bin(obj.buff(113858)) * 3 
    end 
  },
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
}

local function dangerousCastsScan()
  paladin.currentDangerousCasts = {}
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
          tinsert(paladin.currentDangerousCasts, {
            source = enemy,
            dest = dest or enemy.castTarget,
            weight = weight
          })
        end
      end
    end
  end
end

local BOS = NS(6940, { 
  ignoreFacing = true,
  ignoreGCD = true,
  ignoreMoving = true,
  heal = true
})

function BOS:threshold(unit, bypass)

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
  for _, cast in ipairs(paladin.currentDangerousCasts) do 
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
  threshold = threshold * 1 + bin(not healer.exists or healer.ccr > 2) * 0.1

  return threshold

end
  
BOS:Callback(function(spell, info)

  if not blink.arena then return end

  -- if not player.hasTalent(264735) then return end

  if player.used(1022, 2) then return end

  if not saved.AutoSacFriendly then return end

  -- scan for any dangerous casts
  dangerousCastsScan()

  blink.Group.sort(function(x,y) return x.hp < y.hp end)

  blink.group.loop(function(member)

    local count, _, _, cds = member.v2attackers()

    if count == 0 then return end

    if member.buff(1022) then return end

    if member.hp <= BOS:threshold(member) then
      return spell:Cast(member) and alert("Blessing of Sacrifice " .. member.classString, spell.id)
    end
  end)

end)

local StuffCanBeSaced = 
{
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

BOS:Callback("cc", function(spell)
  if not saved.AutoSacCC then return end
  blink.enemies.loop(function(enemy)
    local cast = enemy.casting or enemy.channeling
    if tContains(StuffCanBeSaced, (enemy.casting or enemy.channeling)) 
    and enemy.castTarget.isUnit(player) then
      blink.group.loop(function(member)
        if enemy.castTimeLeft < blink.buffer + blink.latency + 0.15 then
          if member.visible 
          and member.los 
          and member.attackers2 > 0 then
            return spell:Cast(member) and alert("|cFFfa8ea8Blessing of Sacrifice|r |cFF9ed0ff[" .. enemy.casting or enemy.channeling .. "]", spell.id)
          end
        end
      end)
    end
  end)

end)

-- BOS:Callback("dmg", function(spell)
--   blink.group.loop(function(member)
--     local count, _, _, cds = member.v2attackers()
    
--     local threshold = 17
--     threshold = threshold + bin(member.stunned) * 5
--     threshold = threshold + count * 9
--     threshold = threshold + cds * 12

--     threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(member.stunned) * 0.35)
--     --threshold = threshold * saved.FortitudeSensitivity

--     if member.hpa > threshold then return end

--     --turtle
--     if member.buff(186265) then return end  
--     --pet wall fittest
--     if member.buff(264735) and member.hpa > 30 then return end

--     if member.hpa <= threshold then
--       return spell:Cast() and alert("Blessing of Sacrifice "..colors.red.."[Danger]", spell.id)
--     end
--   end)

-- end)

paladin.BOS = BOS


local SOV = NS(184662, { 
  ignoreFacing = true,
  ignoreMoving = true
})

SOV:Callback("emergency", function(spell)
  
  if not saved.AutoSOV then return end

  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.hp <= saved.SOVSensitivity) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.SOVSensitivity) * 0.35)
  --threshold = threshold * player.hp <= saved.SOVSensitivity

  if player.hpa > threshold then return end

  if player.buff(199448) 
  or player.buff(47788) 
  or player.buff(116849) then 
    return 
  end

  if player.hp > saved.SOVSensitivity then return end
  if not player.combat then return end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  end
  
  if spell:Cast() then
    blink.alert("Shield of Vengeance" ..colors.red .. " [Danger]", spell.id)
  end

end)

paladin.SOV = SOV


local BlinkFontLarge = blink.createFont(16)
local BlinkFontNormal = blink.createFont(12)

local function normalize(a)
  return min(255, max(0, a))
end

local ddraw = 0


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

paladin.healthstones = healthstones


-- -- lil helper functions

-- local alert = blink.alert
-- local shortalert = function(msg, txid)
--   return alert({msg = msg, texture = txid, duration = 0.1})
-- end 

-- local function round(num, numDecimalPlaces)
--   local mult = 10^(numDecimalPlaces or 0)
--   return math.floor(num * mult + 0.5) / mult
-- end

-- local lastJump = 0
-- hooksecurefunc("JumpOrAscendStart", function()
--   if not IsFalling() then
--     lastJump = GetTime()
--   end
-- end)

-- local function jumpApex(min, max)
--   if player.rooted then return true end
--   if not IsFalling() then
--     JumpOrAscendStart()
--   elseif GetTime() - lastJump >= (min or 0.25) then
--     return true
--   end
-- end

-- local fireMageVictims = {}
-- local function recentlyAttackedByFireMage(unit)
--   for i=#fireMageVictims,1,-1 do
--     local victim = fireMageVictims[i]
--     if blink.time - victim.time > 2 then
--       tremove(fireMageVictims, i)
--     end
--   end

--   for i=1,#fireMageVictims do
--     local victim = fireMageVictims[i]
--     if victim.object.isUnit(unit) then
--       return true
--     end
--   end
-- end

-- local function insideEnemyMeteor(unit)
--   -- 6211
--   for _, trigger in ipairs(blink.areaTriggers) do
--     if trigger.id == 6211 and trigger.distanceTo(unit) < 5.5 then
--       return true
--     end
--   end
-- end

-- --! Aegis !--
-- local aegis = blink.Item(188775)
-- function aegis:danger()
--   if healer.exists and not healer.cc and player.hp > 78 then return end
--   if player.hp > 90 then return end
--   return self:Use()
-- end

-- --flesh/meld stuff
-- local fleshcraft = NS(324631)
-- local meld = NS(58984)
-- local step = NS(36554, { ignoreFacing = true })

-- -- only tracking direct meaningful damage, 
-- -- it's an indicator they're committed to attking the unit
-- local fireMageSpell = {
--   [108853] = true,  -- fire blast
--   [11366] = true,   -- pyroblast
--   [257541] = true,  -- phoenix flames (maybe remove this)
-- }

-- on-damage events!
-- onUpdate(function()

--   local spellID, spellName = select(12, unpack(info))
--   local time = blink.time

--   if sanc.cd - blink.gcdRemains > 0 then return end
--   if healer.dist > 40 then return end
    
--   if healer.stunned 
--   or healer.debuffFrom(SancFears)
--   and healer.ccRemains >= 3.5 then
--     return sanc:Cast(healer) and alert("Blessing of Sanctuary "..colors.cyan..healer.classString, sanc.id)
--   end

-- end)

-- local blind = NS(187650, { effect = "physical" })
-- function blind:immunityRemains(unit)

--   local immunities = {
--     {
--       name = "Magic Immunity",
--       remains = unit.magicEffectImmunityRemains
--     },
--     {
--       name = "CC Immunity",
--       remains = unit.ccImmunityRemains
--     }
--   }
  
--   -- fleshy c
--   if unit.channelID == 324631 then
--     immunities[#immunities+1] = {
--       name = "Fleshcraft",
--       remains = 6
--     }
--   end

--   -- Ultimate Fleshcraft
--   if unit.buff(323524) then
--     immunities[#immunities+1] = {
--       name = "Ultimate Form",
--       remains = 3
--     }
--   end

--   -- grounding
--   if unit.buff(8178) then
--     immunities[#immunities+1] = {
--       name = "Grounding",
--       remains = 69
--     }
--   end

--   --Warrior Reflect
--   if unit.buff(23920) then
--     immunities[#immunities+1] = {
--       name = "Spell Reflect",
--       remains = 7
--     }
--   end

--   --Warrior Reflect Legendary
--   if unit.buff(23920) then
--     immunities[#immunities+1] = {
--       name = "Spell Reflection",
--       remains = 7
--     }
--   end
  
--   --Warrior Reflect Legendary Misshapen Mirror
--   if unit.buff("Misshapen Mirror") then
--     immunities[#immunities+1] = {
--       name = "Spell Reflect",
--       remains = 7
--     }
--   end

--   --PROT PALA Immune Spell Warding
--   if unit.buff(204018) then
--     immunities[#immunities+1] = {
--       name = "Spell Warding",
--       remains = 10
--     }
--   end

--   --PROT PALA Immune Forgotten Queen
--   if unit.buff(228050) then
--     immunities[#immunities+1] = {
--       name = "Forgotten Queen",
--       remains = 10
--     }
--   end

--   --more Sac to make sure we not throw blind into sacs please?
--   if unit.buff(6940) then
--     immunities[#immunities+1] = {
--       name = "Blessing of Sacrifice",
--       remains = 12
--     }
--   end
--   --Sac more !!
--   if unit.buff(199448) then
--     immunities[#immunities+1] = {
--       name = "Blessing of Sacrifice",
--       remains = 12
--     }
--   end
--   --Ultimate Sac another one #justin
--   if unit.buff(199452) then
--     immunities[#immunities+1] = {
--       name = "Blessing of Sacrifice",
--       remains = 6
--     }
--   end
--   --Ultimate Sac another one with name 
--   if unit.buff("Ultimate Sacrifice") then
--     immunities[#immunities+1] = {
--       name = "Ultimate Sacrifice",
--       remains = 6
--     }
--   end
  
--   -- blessing of sac
--   if unit.class2 == "PALADIN" then
--     local sac_remains = 0
--     local sac_source
--     for _, enemy in ipairs(blink.enemies) do
--       local buff,_,_,_,_,_,source = enemy.buff(6940)
--       if not buff then
--         buff,_,_,_,_,_,source = enemy.buff(199452)
--         if buff then
--           sac_remains = enemy.buffRemains(199452)
--         end
--       else
--         sac_remains = enemy.buffRemains(6940)
--       end
--     end
--     if sac_source and unit.isUnit(sac_source) then
--       immunities[#immunities+1] = {
--         name = "Sac",
--         remains = sac_remains
--       }
--     end
--   end

--   --meteor
--   if unit.debuff(155158) then
--     immunities[#immunities+1] = {
--       name = "Meteor",
--       remains = 4
--     }
--   end

--   --orb
--   if unit.debuff(289308) then
--     immunities[#immunities+1] = {
--       name = "Frozen Orb",
--       remains = 4
--     }
--   end

--   --war banner
--   if unit.buff(236321) then
--     immunities[#immunities+1] = {
--       name = "War Banner",
--       remains = 5
--     }
--   end

--    sort(immunities, function(x,y) return x.remains > y.remains end)

--   return immunities[1]

-- end


-- local immunity = blind:immunityRemains(obj)
-- local mir = immunity.remains
-- local travel, maxReach = info.travel, info.unit.maxReach

-- if mir > travel - 0.125 then return "Waiting for " .. immunity.name end

-- local Fleshcrafting = obj.channelID == (324631) and obj.channelTimeComplete > 0.3
-- local resolveRemains = obj.buffRemains(363121)

-- if resolveRemains > travel - 0.125 then
--   -- if paladin.interrupt and paladin.interrupt:Cast(obj) then
--   --   alert("Interrupt |cFF6ee7ffGladiator's Resolve Stack", paladin.interrupt.id)
--   -- end
--   return "Waiting for |cFF6ee7ffGladiator's Resolve"
-- end

-- if Fleshcrafting then
--   if paladin.kick and paladin.kick:Cast(obj) then
--     alert("Interrupt: |cFF6ee7ffFleshcraft", paladin.interrupt.id)
--   end
--   return "Waiting for |cFF6ee7ffFleshcraft"
-- end