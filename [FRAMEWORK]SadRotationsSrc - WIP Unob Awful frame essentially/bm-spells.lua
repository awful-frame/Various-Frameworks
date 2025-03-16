local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local hunter, bm = sr.hunter, sr.hunter.bm
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local gcd, buffer, latency, tickRate, gcdRemains = 0, 0, 0, 0, 0
local saved = sr.saved
local colors = blink.colors
local enemy = blink.enemy
local bin = blink.bin
local enemyPets = blink.enemyPets
local NewItem = blink.Item
local delay = blink.delay(0.5, 0.6)
local stompDelay = blink.delay(0.5, 0.6)

local currentSpec = GetSpecialization()

if not hunter.ready then return end

if currentSpec ~= 1 then return end

blink.Populate({
  -- units [slight perf increase in actor/callbacks + exposes rest of file to units]
  target = blink.target,
  focus = blink.focus,
  player = blink.player,
  healer = blink.healer,
  fhealer = blink.healer,
  enemyHealer = blink.enemyHealer,
  pet = blink.pet,
  enemyPets = blink.enemyPets,
  arena1 = blink.arena1,
  arena2 = blink.arena2,
  arena3 = blink.arena3,

  -- dmg
  kill = hunter.kill,
  barbed = NS(217200, { damage = "physical", ranged = true, targeted = true }),
  cobra = NS(193455, { ignoreUsable = true, ranged = true, targeted = true }),
  flayed = NS(324149, { damage = "physical", ranged = true, targeted = true, bleed = true }),
  killCommand = NS(34026, { damage = "physical", ranged = true, targeted = true, facingNotRequired = true }),
  crows = NS(131894, { damage = "physical", ranged = true, targeted = true }),
  conc = NS(5116, { effect = "physical", ranged = true, targeted = true, slow = true }),
  SlowBigDam = NS(5116, { effect = "physical", ranged = true, targeted = true, slow = true }),
  bloodshed = NS(321530, { damage = "physical", ranged = true, targeted = true }),
  direbeast = NS(120679, { damage = "physical", ranged = true, targeted = true }),
  multiShot = NS(2643, { damage = "physical", ranged = true, targeted = true }),
  blackArrow = hunter.blackArrow,

  -- cc
  trap = hunter.trap,
  tar = NS(187698, { effect = "magic", ignoreFacing = true, slow = true }),
  tartrap = hunter.tartrap,
  cs = NS(147362, { effect = "physical", ranged = true, ignoreGCD = true }),
  ChimaeralSting = hunter.ChimaeralSting,
  bindingshot = hunter.bindingshot,
  ExplosiveTrap = NS(236776, {effect = "magic", ignoreFacing = true, diameter = 8 }),
  steeltrap = hunter.steeltrap,
  Scatter = hunter.Scatter,
  intimidation = hunter.intimidation,
  concu = hunter.concu,

  -- offensive
  deathchakram = NS(375891, { damage = "physical", ranged = true, targeted = true }),
  wrath = NS(19574),
  wild = NS(193530),
  COTW = NS(359844),
  burstwild = NS(193530),
  tranq = hunter.tranq,
  primalrage = NS (264667),
  bassy = NS(205691, { damage = "physical", ranged = true, targeted = true }),

  -- defensive
  feign = hunter.feign,
  turtle = hunter.turtle,
  exhilaration = hunter.exhilaration,
  spiritMend = hunter.spiritMend,
  Healthstone = NewItem(5512),

  -- misc
  hunterMark = NS(257284, { ignoreFacing = true }),
  pettaunt = NS(2649, { ignoreFacing = true }),
  flare = hunter.flare,
  mendPet = NS(136, { heal = true }),
  camo = hunter.camo,
  ros = hunter.ros,
  SOTF = hunter.SOTF,
  fortitude = hunter.fortitude,
  freedom = hunter.freedom,
  disengage = hunter.disengage,
  dash = hunter.dash,
  ultimatePostion = hunter.ultimatePostion,

  racials = {
    -- Blood fury
    Orc = NS({20572, 33697}, { ignoreGCD = true }),
    -- berserking
    Troll = NS(26297),
    --Fireblood
    IronDwarf = NS(265221),
  },

  --Trinkets Table
  Trinkets = {
    PVE = blink.Item({109999, 137312, 209343, 209763, 205708, 205778, 201807, 201449}),
    Badge = blink.Item({216368, 216279, 209343, 209763, 205708, 205778, 201807, 201449, 218421, 218713}),
    Emblem = blink.Item({216371, 216281, 209345, 209766, 201809, 201452, 205781, 205710, 218424, 218715}),
  },
  
  -- items
  tierPieces = NewItem({207218, 207216, 207221, 207219, 207217}),


}, bm, getfenv(1))

-- expose
hunter.conc = conc
hunter.interrupt = cs

-- event callback
local tierEquipped
local function tierAlert()
  if tierPieces.numEquipped >= 4 then
    if tierEquipped ~= 4 then
      blink.alert({ message = "|cffFF45004 Piece Tier Set Detected", duration = 2 })
      tierEquipped = 4
    end
  elseif tierPieces.numEquipped >= 2 then
    if tierEquipped ~= 2 then
      blink.alert({ message = "|cffFF45002 Piece Tier Set Detected", duration = 2 })
      tierEquipped = 2
    end
  else
    tierEquipped = 0
  end
end
-- tierAlert()
-- blink.addEventCallback(tierAlert, "PLAYER_EQUIPMENT_CHANGED")

-- constants
local isNearFriendOrPet = function(totem)

  local isFriendNear = blink.fullGroup.around(totem, 6, function(friend)
    return true
  end) > 0

  local isPetNear = false
  if pet.exists 
  and pet.distanceTo(totem) <= 6 then
    isPetNear = true
  end

  return isFriendNear or isPetNear
end


local fearClasses = {"WARLOCK", "PRIEST", "WARRIOR"}
local importantTotems = {
  [5913] = fearClassOnTeam, -- Tremor
  [2630] = function(totem) return isNearFriendOrPet(totem) end, -- Earthbind
  [60561] = function(totem) return isNearFriendOrPet(totem) end, -- Earthgrab
  [61245] = function(totem) return isNearFriendOrPet(totem) end, --Capacitor 
  [179867] = function(totem) return isNearFriendOrPet(totem) end, --Static Field Totem 
  [59764] = function(totem, uptime) return uptime < 8 end,  --Healing Tide
}

local badKicks = sr.BadKicks

local barbed_next_gcd = false 
local barbed_refresh_time = 0
local barbedAlert = function()
  if gcdRemains > 0 then return end
  blink.alert("Waiting |cFFf7f25c[Barbed Shot]", barbed.id)
end

-- filters 
local function bcc(obj) return obj.bcc end

-- buffs
local flayers_mark = 378215
local frenzy = 272790
local thrill = 257946
local beastCleave = 268877

-- unit we will be trapping
local trapTarget = hunter.trapTarget
bm.trapTarget = trapTarget

-- unit who is currently trapped
local trappedTarget = {}
local function findTrappedTarget()
  trappedTarget = {}
  for _, enemy in ipairs(blink.enemies) do
    if enemy.debuff(3355, "player") then
      trappedTarget = enemy
      break
    end
  end
end

-- procs could be cumming!
local flayedShotTicking = false

local consecutiveKillCommands = 0

-- hook :Cast calls that return true
hookCasts(function(spell)
  if spell.id == killCommand.id then 
    consecutiveKillCommands = consecutiveKillCommands + 1
  else
    consecutiveKillCommands = 0
  end
end)

-- hook first spell callback per frame
hookCallbacks(function(spell)

  gcd, buffer, latency, tickRate, gcdRemains = blink.gcd, blink.buffer, blink.latency, blink.tickRate, blink.gcdRemains

  trapTarget = hunter.trapTarget

  -- flayedShotTicking = false

  -- if flayed.cd > 12 then
  --   for _, enemy in ipairs(blink.enemies) do
  --     if enemy.debuff(flayed.id, "player") then
  --       flayedShotTicking = enemy
  --       break
  --     end
  --   end
  --   if not flayedShotTicking then
  --     for _, enemyPet in ipairs(blink.enemyPets) do
  --       if enemyPet.isPet and enemyPet.debuff(flayed.id, "player") then
  --         flayedShotTicking = enemyPet
  --         break
  --       end
  --     end
  --   end
  -- end

  -- get fresh trapped target for...
  -- bestial wrath
  findTrappedTarget()
  
  barbed_refresh_time = gcd + buffer + latency + tickRate + 0.215

  barbed_next_gcd = target.enemy 
  and pet.exists
  and pet.buff(frenzy) 
  and pet.buffRemains(frenzy) <= barbed_refresh_time
  and (barbed.charges > 0 or barbed.nextChargeCD < pet.buffRemains(frenzy))

  -- barbed_next_gcd = target.enemy 
  -- and pet.exists
  -- and player.buff(thrill) 
  -- and player.buffRemains(thrill) <= barbed_refresh_time
  -- and (barbed.charges > 0 or barbed.nextChargeCD < player.buffRemains(thrill))

end)

-- hook stomp
hookCallbacks(function()
  for _, member in ipairs(blink.group) do 
    fearClassOnTeam = fearClassOnTeam or tContains(fearClasses, member.class2)
  end
  importantTotems[5913] = fearClassOnTeam
end, {"stomp"})

-- cancel queued shit spell if possible on ks proc
onUpdate(function()
  if saved.rotationMode == "hekiliMode" then return end
  local isQueued = 
  cobra.current and "Cobra Shot" or
  killCommand.current and "Kill Command"
  if isQueued then
    if player.buff(flayers_mark) then
      blink.call("SpellCancelQueuedSpell")
      blink.alert("Cancelling " .. isQueued .. " |cFFf7f25cfor KS Proc")
    end
  end
end)

----------------------------------------------------------------------------------------------------------------
--                                     Start of Tables                                                        --
----------------------------------------------------------------------------------------------------------------

local listOfHexAndPolys = {
  -- start of hex
  277784,
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
  289419, 
  -- end of hex

  --poly
  118,
  161355,
  161354,
  161353,
  126819,
  61780,
  161372,
  61721,
  61305,
  28272,
  28271,
  277792,
  277787,
  --end of poly

}

--friend is fine don't kick
local noNeedToKick = {

  642, --"Divine Shield",
	213610, --Holy Ward
	--236321, --War Banner *maybe no
	23920, -- reflect
  8178, --grounding
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  204018, --Spell Warding
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  353319, --monk retoral
  408558, --priest phase shift
  377362, --prec

}

--Kick By spell name table
local kickImportantStuff =
{

  375901, --Mindgames
  32375, --Mass Dispel
  341167, --Improved Mass Dispel
  33786, --Cyclone

} 

--Kick By spell name table
local KickHealing =
{

  2061, --"Flash Heal",
  2060, --"Heal",
  19750, --"Flash of Light",
  82326, --"Holy Light",
  8936, --"Regrowth",
  77472, --"Healing Wave",
  8004, --"Healing Surge",
  115175, --"Soothing Mist",
  116670, --"Vivify",
  47757, --"Penance",

}

-- Immune Hunter Kicks 
local ImmuneKick =
{

	1022, --"Blessing of Protection",
	642, --"Divine Shield",
	--"Aura Mastery",
	--210294, --"Divine Favor",
  147833, --"Intervene",
  362486, --Keeper of the Grove

}

local DontKickAvoidableCCTable = 
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
  51514, --"Start of Hex"
  51514,
  332605,
  210873,
  211015,
  219215,
  11641,
  277778,
  17172,
  66054,
  11641,
  271930,
  270492,
  18503,
  289419, -- end of Hexes
  20066, --"Repentance"
  5782, --"Fear"
}

--Slow By buff name table
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
  354610, --dh Glimpse

}

----------------------------------------------------------------------------------------------------------------
--                                     End of Tables                                                          --
----------------------------------------------------------------------------------------------------------------

-- racials
bm.racial = function()
  local racial = racials[player.race]
  if racial and racial() then
    blink.alert(racial.name, racial.id)
  end
end

-- orc
racials.Orc:Callback(function(spell)
  if player.buff(bm.wrath.id) and player.buffRemains(bm.wrath.id) < 5 
  or player.buff(bm.COTW.id) and player.buffRemains(bm.COTW.id) < 5 then 
    return 
  end
  
  if player.buffFrom({bm.wrath.id, bm.wild.id, bm.COTW.id}) then
    return spell:Cast()
  end
end)

-- Troll
racials.Troll:Callback(function(spell)
  if player.buff(bm.wrath.id) and player.buffRemains(bm.wrath.id) < 5 
  or player.buff(bm.COTW.id) and player.buffRemains(bm.COTW.id) < 5 then 
    return 
  end
  
  if player.buffFrom({bm.wrath.id, bm.wild.id, bm.COTW.id}) then
    return spell:Cast()
  end

end)

deathchakram:Callback(function(spell)
  if not player.hasTalent(375891) then return end
  if (target.buff(198589) or target.buff(212800) or target.immunePhysicalDamage) then return end
  --if not player.facing(target) then return end
  if player.cc then return end
  if target.dist > 39 or not target.los then return end
  --if player.buffRemains(bm.wrath.id) < 5 then return end
  if player.buffFrom({bm.wrath.id, bm.wild.id, bm.COTW.id}) or wrath.cd > 10 then
    return spell:Cast(target, {face = true})
  end
end)

direbeast:Callback(function(spell)
  if player.buffRemains(281036) > blink.gcd then return end
  if not player.hasTalent(120679) then return end
  if (target.buff(198589) or target.buff(212800) or target.immunePhysicalDamage or target.immuneMagicDamage) then return end
  if not player.facing(target) then return end
  if player.cc then return end
  if target.dist > 39 or not target.los then return end
  -- if player.buffFrom({bm.wrath.id, bm.wild.id, bm.COTW.id}) 
  -- or wrath.cd > 20 then
    return spell:Cast(target, {face = true})
  --end
end)

-- barbed shot
local earlyBarbedBad = function()
  if killCommand.cd <= gcdRemains and player.focus >= 29 then return true end
  --if flayedShotTicking or player.buff(flayers_mark) then return true end
  if player.focus >= 80 then return true end
end
local getStompPos = function(unit)
  if not pet.exists then return unit.position() end
  local x,y,z = unit.position()
  local px,py,pz = pet.position()
  local angle = blink.AnglesBetween(x,y,z,px,py,pz)
  local reach = unit.combatReach
  return x + reach * cos(angle), y + reach * sin(angle), z
end

barbed:Callback("maintain frenzy", function(spell, obj)
  if blink.MacrosQueued['pet back'] then return end
  if target.immunePhysicalDamage then return end
  if not target.los then return end
  if blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) > 0 
  or blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0 then
    return
  end

  local t = obj or target
  if (not pet.exists and spell.charges >= spell.chargesMax)
  or pet.buff(frenzy) 
  and pet.buffRemains(frenzy) <= barbed_refresh_time - bin(spell.chargesFrac <= 1.15 and wrath.cd > 8 + barbed_refresh_time) * gcd + bin(obj) * 1.5
  or spell.chargesFrac >= 1 + bin(pet.buff(frenzy)) * 0.9 + bin(not obj and pet.buffRemains(frenzy) >= barbed_refresh_time * 2 and earlyBarbedBad()) * 1.1 - bin(pet.buffStacks(frenzy) <= 3) * 1.1
  or wrath.cd <= 14 then
    return spell:Cast(t, {face = true})
  end
end)

-- barbed:Callback("maintain frenzy", function(spell, obj)
--   if target.immunePhysicalDamage or not target.los then return end

--   local frenzyBuffId = 257946
--   local frenzyStacks = player.buffStacks(frenzyBuffId)
--   local frenzyBuffRemains = player.buffRemains(frenzyBuffId)
--   local barbedCharges = spell.charges
--   local barbedNextChargeCD = spell.nextChargeCD
--   local wrathCooldown = wrath.cd

--   -- Avoid using Barbed Shot if breakable CC is around
--   local breakableCCAround = blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) > 0
--   or blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0

--   if breakableCCAround then
--     alert("Holding Barbed Shot |cFFf74a4a[Breakable CC around]", spell.id)
--     return
--   end

--   -- Determine if casting Barbed Shot is appropriate
--   local shouldCast = false

--   if target.enemy then
--     if frenzyStacks <= 3 or frenzyBuffRemains <= 1.9 then
--       shouldCast = true
--     elseif wrathCooldown <= 14 and barbedCharges >= 1 then
--       shouldCast = true
--     elseif barbedCharges == 2 or barbedNextChargeCD <= blink.gcd then
--       -- Ensure we don't waste Barbed Shot charges
--       shouldCast = barbedCharges < 2 or frenzyBuffRemains <= 3.5
--     end
--   end

--   if shouldCast then
--     spell:Cast(target, {face = true})
--   end
-- end)

-- barbed:Callback("maintain frenzy", function(spell, obj)
--   -- blink.print("Calling Barbed", math.random(1.500))
--   local bccAroundPet = blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) > 0 
--   local bccAroundTarget = blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0

--   local t = obj or target

--   -- if (not pet.exists and spell.charges >= spell.chargesMax)
--   -- or pet.buff(frenzy) and pet.buffRemains(frenzy) <= barbed_refresh_time - bin(spell.chargesFrac <= 1.15 and wrath.cd > 8 + barbed_refresh_time) * gcd + bin(obj) * 1.5
--   -- or spell.chargesFrac >= 1 + bin(pet.buff(frenzy)) * 0.9 + bin(not obj and pet.buffRemains(frenzy) >= barbed_refresh_time * 2 and earlyBarbedBad()) * 1.1 - bin(pet.buffStacks(frenzy) <= 4) * 1.1 
--   -- or wrath.cd <= 14 and spell.chargesFrac >= 1 then

--   --   if not bccAroundPet 
--   --   and not bccAroundTarget then
      
--   --     return spell:Cast(target, {face = true})
--   --   end
--   -- end

--   --#TODO: do it later
    
--   -- Determine the time remaining on Frenzy buff and the cooldown until the next Barbed Shot charge
--   local frenzyRemaining = pet.buffRemains(frenzy)
--   local nextChargeCD = spell.nextChargeCD
--   local maxCharges = spell.chargesMax
--   local chargeFraction = spell.chargesFrac

--   -- If Frenzy buff is about to expire or we're at max charges or next charge is coming soon, cast Barbed Shot
--   if target.enemy 
--   and frenzyRemaining <= 1.2 
--   or chargeFraction >= maxCharges 
--   or nextChargeCD < 2 then
--     if bccAroundPet or bccAroundTarget then return end
--     return spell:Cast(target, {face = true})
--   end
-- end)

-- barbed:Callback("maintain frenzy", function(spell, obj)
--   if target.immunePhysicalDamage then return end
--   if not target.los then return end

--   -- if killCommand.cd <= 0.5 
--   -- and spell.charges >= spell.chargesMax
--   -- and pet.losOf(target)
--   -- and not pet.cc then
--   --   return 
--   -- end

--   if blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) > 0 
--   or blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0 then
--     return
--   end

--   if target.enemy 
--   and (player.buffRemains(257946) <= 1.9
--   or wrath.cd <= 14 
--   or spell.charges == 2 and player.buffStacks(257946) <= 3) 
--   and blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) == 0 
--   and blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) == 0 then
--     spell:Cast(target, {face = true})
--   elseif (blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) > 0 or blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0) then
--     alert("|cff71C671Holding Barbed Shot|r |cFFf7f25c[Breakable CC around]", spell.id)
--   end

-- end)

bloodshed:Callback("wrath", function(spell)
  if saved.mode == "OFF" and not blink.burst then return end 
  if not pet.losOf(target) then return end
  if pet.distanceTo(target) > 50 then return end
  if not pet.exists or pet.dead or pet.cc or pet.rooted then return end
  if (target.buff(198589) or target.buff(212800) or target.immunePhysicalDamage) then return end
  --if not player.facing(target) then return end
  if player.cc then return end
  if barbed_next_gcd then barbedAlert() return end
  if target.dist > 50 or not target.los then return end
  if pet.exists 
  and pet.losOf(target)
  and player.buffRemains(wrath.id) > 5 
  or saved.mode == "OFF" and blink.burst
  or target.debuff(375893) 
  or wrath.cd >= 10
  and not target.immunePhysicalDamage or pet.dead then
    return spell:Cast()
  end
end)

bassy:Callback("CD", function(spell)
  if not player.hasTalent(spell.id) then return end
  if saved.mode == "OFF" and not blink.burst then return end 
  if target.immunePhysicalDamage then return end
  if player.cc then return end
  if barbed_next_gcd then barbedAlert() return end
  if target.dist > 50 or not target.los then return end

  if player.buffRemains(wrath.id) > 5 
  or saved.mode == "OFF" and blink.burst
  or target.debuff(375893) 
  or wrath.cd >= 10 then
    return spell:Cast()
  end
end)

-- bestial wrath
wrath:Callback("go", function(spell)
  if pet.dead then return end
  if target.buffFrom({198589, 212800}) then return end
  if target.immunePhysicalDamage then return end
  if not player.facing(target) then return end
  if player.cc then return end
  if barbed_next_gcd then barbedAlert() return end
  if target.dist > 39 or not target.los then return end
  if barbed.charges > 0 then return end
  if saved.NoAutoBurst then  
    if blink.burst
    or enemyHealer.cc 
    and enemyHealer.ccr > 3
    or not enemyHealer.exists
    or trappedTarget.exists
    and trappedTarget.ccr > 3 then
      if pet.exists and not target.immunePhysicalDamage or pet.dead then
        return spell:Cast() and alert("Bestial Wrath", spell.id)
      end
    end
  else
    --noburst
    if saved.mode == "OFF" and not blink.burst then return end  
    if pet.exists and not target.immunePhysicalDamage or pet.dead then
      return spell:Cast() and alert("Bestial Wrath", spell.id)
    end
  end
  --return spell:Cast() and alert("Bestial Wrath", spell.id)
end)
wrath:Callback("refresh barbed", function(spell)
  if pet.dead then return end
  if saved.NoAutoBurst then return end
  if saved.mode == "OFF" then return end 
  if target.buffFrom({198589, 212800}) then return end
  if target.immunePhysicalDamage then return end
  if player.cc then return end
  if barbed_next_gcd then barbedAlert() return end
  if target.dist > 39 or not target.los then return end

  if barbed.chargesFrac <= 0.9
  and not target.immunePhysicalDamage
  and pet.buff(frenzy)
  and pet.buffRemains(frenzy) < barbed_refresh_time * 2
  and barbed.nextChargeCD > pet.buffRemains(frenzy) - barbed_refresh_time * 2 then
    return spell:Cast() and alert("Bestial Wrath (Frenzy)", spell.id)
  end

end)

-- aspect of the wild
wild:Callback("proc", function(spell)
  if barbed_next_gcd then barbedAlert() return end
  if not target.immunePhysical and target.los and target.dist < 40 then
    if gcdRemains <= blink.spellCastBuffer + 0.05
    and player.buff(flayers_mark) 
    and not (target.buff(198589) or target.buff(212800)) then
      return spell:Cast() and alert("Aspect of the Wild", spell.id)
    end
  end
end)

COTW:Callback("proc", function(spell)
  if not player.hasTalent(spell.id) then return end
  if not pet.exists then return end 
  if spell.cd - blink.gcdRemains > 0 then return end
  if barbed_next_gcd then barbedAlert() return end
  if pet.rooted or pet.cc then return end
  if target.immunePhysical or target.dist > 40 then return end
  if not target.los then return end

  if player.buff(wrath.id) or wrath.cd - blink.gcdRemains > 30 then
    return spell:Cast() and alert("Call of the Wild", spell.id)
  end

end)

primalrage:Callback("proc", function(spell)
  if saved.mode == "OFF" then return end 
  if not player.hasTalent(356962) then return end
  if not player.buff(264663) then return end
  if pet.dead then return end
  if barbed_next_gcd then barbedAlert() return end
  if not target.immunePhysical and target.los and target.dist < 40 then
    if gcdRemains <= blink.spellCastBuffer + 0.05
    and player.buff(flayers_mark) 
    and not (target.buff(198589) or target.buff(212800)) then
      return spell:Cast() and alert("Primal Rage", spell.id)
    end
  end
end)

-- flayed:Callback("best target", function(spell)
--   if barbed_next_gcd then barbedAlert() return end
--   if target.class2 ~= "HUNTER" then
--     -- no blur
--     if (target.buff(198589) or target.buff(212800)) then return end
--     if (target.immuneMagicEffects or target.immuneMagicDamage) then return end
--     if (target.immunePhysicalDamage or target.immunePhysicalEffects) then return end
--     return spell:Cast(target, {face = true}) and alert("Flayer's Mark", spell.id)
--   else
--     pets.loop(function(pet)
--       if not pet.enemy then return end
--       return spell:Cast(pet, {face = true}) and alert("Flayer's Mark (Pet - " .. pet.name .. ")", spell.id)
--     end)
--     enemies.loop(function(enemy)
--       if enemy.bcc or enemy.isUnit(target) or enemy.isUnit(trapTarget) then return end
--       -- no blur
--       if enemy.buff(198589) then return end
--       return spell:Cast(enemy, {face = true}) and alert("Flayer's Mark (" .. enemy.class .. ")", spell.id)
--     end)
--   end
-- end)

-- kill command
killCommand:Callback("gapclose", function(spell)
  if blink.MacrosQueued['pet back'] then return end
  --if barbed_next_gcd then barbedAlert() return end
  if not pet.exists then return end 
  if pet.dead or pet.cc or pet.rooted then return end
  -- don't spam it, pet probably can't move
  --if consecutiveKillCommands >= 3 then blink.debug.print("pet unable to kill command, prob in CC, saved debuffs to global table 'petDebuffs'", "debug") _G.petDebuffs = pet.debuffs return end
  if not target.los then return end
  if not pet.losOf(target) then return end

  if target.enemy 
  and pet.distanceTo(target) > 5 
  and pet.distanceTo(target) < spell.range then
    return spell:Cast(target) and alert("Kill Command |cFFf7f25c[Gapclose]", spell.id)
  end

end)

killCommand:Callback("2pc equipped", function(spell)
  if blink.MacrosQueued['pet back'] then return end
  --if barbed_next_gcd then barbedAlert() return end
  if pet.dead or not pet.exists then return end 
  if not target.los then return end
  if not pet.losOf(target) then return end
  if target.immunePhysicalDamage then return end
  if target.bcc then return end
  if not target.enemy then return end
  if not target.exists then return end

  if pet.cc or pet.rooted then 
    return wrath:Cast()
  end

  return spell:Cast(target)
  --if consecutiveKillCommands >= 3 then blink.debug.print("pet unable to kill command, prob in CC, saved debuffs to global table 'petDebuffs'", "debug") _G.petDebuffs = pet.debuffs return end
  -- if pet.buffStacks(frenzy) >= 2 then
  --   if not pet.losOf(target) then return end
  --   -- don't spam it, pet probably can't move
  --   if consecutiveKillCommands >= 3 then blink.debug.print("pet unable to kill command, prob in CC, saved debuffs to global table 'petDebuffs'", "debug") _G.petDebuffs = pet.debuffs return end
  --   return spell:Cast(target)
  -- end
end)

killCommand:Callback("CDs", function(spell)
  if blink.MacrosQueued['pet back'] then return end
  if barbed_next_gcd then barbedAlert() return end
  if target.immunePhysicalDamage or target.bcc then return end
  if not target.enemy then return end
  if pet.dead or not pet.exists then return end  
  if not target.los then return end
  if not pet.losOf(target) then return end

  if pet.cc or pet.rooted then 
    return wrath:Cast()
  end

  --tier  
  if player.buffFrom({COTW.id, wrath.id})
  and killCommand.cd < 0.5 then

    return spell:Cast(target)

  end

end)

killCommand:Callback("execute", function(spell)
  if blink.MacrosQueued['pet back'] then return end
  if target.immunePhysicalDamage or target.bcc then return end
  if not target.enemy then return end
  if pet.dead or not pet.exists then return end 
  if not target.los then return end
  if not pet.losOf(target) then return end
  if wrath.cd - blink.gcdRemains == 0 then return end

  if pet.cc or pet.rooted then 
    return wrath:Cast()
  end

  if target.hp <= 20 then

    return spell:Cast(target) --and alert("Kill Command |cFFf7f25c[Execute]", spell.id)

  end

end)

-- cobra
cobra:Callback("focus capped", function(spell)
  if saved.DisableCobra then return end
  if barbed_next_gcd then barbedAlert() return end

  -- if player.focus >= 35 + bin(pet.exists and pet.buffStacks(frenzy) >= 2) * 5 then
  --   return spell:Cast(target)
  -- end

  if not target.los then return end

  if target.buffFrom({45438, 642, 362486, 186265}) then 
    return 
  end
  
  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end  
  

  if player.focus >= 35 
  and killCommand.cd - blink.gcdRemains > 0 
  or target.buff(118038)
  or player.focus >= 35 
  and not (pet.losOf(target) or pet.cc) then
    return spell:Cast(target)
  end

end)

cobra:Callback("pve", function(spell)
  if saved.DisableCobra then return end
  if not target.los then return end
  if target.buffFrom({45438, 642, 362486, 186265}) then 
    return 
  end
  
  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end  

  if barbed_next_gcd then barbedAlert() return end

  if killCommand.cd < blink.gcd
  and not pet.rooted or pet.cc 
  and not target.buff(118038) then 
    return 
  end
  
  if player.focus <= 45 
  and killCommand.cd < blink.gcd 
  and not pet.rooted 
  or pet.cc then 
    return 
  end

  if killCommand.cd > 1 
  and player.focus > 45 or pet.rooted 
  or pet.cc then

    return spell:Cast(target)
  end
  
end)

local function SettingsCheck(settingsVar, castId, channelId)
  if settingsVar[castId] or settingsVar[channelId] then
    return true
  end

  for _, ids in pairs(settingsVar) do
    if type(ids) == "table" then
      for _, id in ipairs(ids) do
        if id == castId or id == channelId then
          return true
        end
      end
    end
  end

  return false
end

cs:Callback("interrupt", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local function canInterruptEnemy(unit)
    if not unit.casting and not unit.channeling then return false end
    if unit.castint or unit.channelint then return false end
    if sr.NoNeedToKickThis(unit) or unit.buffFrom({377362, 215769, 421453}) or not unit.los or unit.dist > spell.range then return false end
    return true
  end

  local function castSpellAndAlert(unit, message, originalRotation)
    if spell:Cast(unit, {face = true}) then
      if not saved.streamingMode then
        alert(message, spell.id)
      end
      
      sr.debugPrint("Kicked (" .. unit.name .. ") at: (" .. unit.castTimeComplete .. ")") 
      
      if originalRotation then
        blink.FaceDirection(originalRotation)  -- Return to original facing direction
      end
    end
  end

  local function performInterrupt(unit, baseMessage, spellList)
    local castingIdAtStart = unit.castingid or unit.channelId
    local originalRotation = player.rotation
    local isLassoSpell = unit.channeling and (unit.channelId == 305483 or unit.channelId == 204437 or unit.channelId == 305485)

    local function castInterrupt()
      if (unit.casting or unit.channeling)
      and unit.castTimeComplete > blink.delays.srDelay.now and unit.castPct >= 70
      and castingIdAtStart == (unit.castingid or unit.channelId) 
      and (not spellList or SettingsCheck(spellList, unit.castingid, unit.channelId)) then

        local spellName = unit.casting or unit.channeling
        local message = baseMessage .. " |cFFf7f25c[" .. spellName .. "]"

        if unit.los and unit.dist <= spell.range and saved.autoFaceToKick and not player.facing(unit, 180) then
          blink.controlFacing(blink.buffer + 0.1)
          player.face(unit)
          C_Timer.After(blink.buffer + 0.1, function()
            castSpellAndAlert(unit, message, originalRotation)
          end)
        else
          castSpellAndAlert(unit, message, originalRotation)
        end
      end
    end

    -- force a delay for lasso...
    if isLassoSpell then
      sr.kickDelay(castInterrupt)
    else
      castInterrupt()
    end
  end

  
  blink.enemies.within(spell.range).loop(function(enemy)
    
    if canInterruptEnemy(enemy) then

      local kickPVE = saved.KickPVE and blink.instancetype ~= "pvp" and not enemy.isPlayer and not blink.arena

      local kickFastMD = saved.KickFastMD and enemy.castRemains < blink.buffer + blink.latency + enemy.distance * 0.0155 + 0.09 
                        and (enemy.castID == 341167 or enemy.castID == 32375) and enemy.isPlayer and enemyHealer.ccRemains > 1

      local kickHealer = enemy.isHealer and (enemy.hp <= saved.kickhealsunder or target.hp <= saved.kickhealsunder) and 
                        (SettingsCheck(saved.kickHealinglist, enemy.castingid) or SettingsCheck(saved.kickHealinglist, enemy.channelId))

      local kickDangerous = SettingsCheck(saved.kickDangerouslist, enemy.castingid) or SettingsCheck(saved.kickDangerouslist, enemy.channelId)

      local kickCC = not saved.TripleDR and not saved.DontKickAvoidableCC and 
                    (SettingsCheck(saved.kickCClist, enemy.castingid) or SettingsCheck(saved.kickCClist, enemy.channelId)) 

      local kickHybrid = saved.HybridsKick and enemy.hp <= 80 and enemy.buffsFrom(ImmuneKick) == 0 and not enemy.isHealer 
                         and tContains(KickHealing, (enemy.casting))

      local dontKickAvoidableCC = saved.DontKickAvoidableCC and enemy.castTarget.isUnit(healer)
                                  and healer.incapDR >= 0.5 and healer.class2 == "PRIEST"
                                  and (healer.cc or healer.cooldown(32379) >= 1)
                                  and tContains(DontKickAvoidableCCTable, (enemy.casting or enemy.channeling))                       

      --Triple DR check                            
      if saved.TripleDR then
        local isTargeted = (enemy.castTarget.isUnit(healer) and healer.incapDR >= 0.5) or 
                          (enemy.castTarget.isUnit(player) and player.incapDR >= 0.5)
      
        local shouldInterruptDRSafe = isTargeted and (
          (tContains(listOfHexAndPolys, enemy.casting) and not saved.DontKickAvoidableCC) 
          --or (enemy.castID == 5782 or enemy.castID == 20066 or enemy.castID == 360806)
        )
      
        if shouldInterruptDRSafe then
          performInterrupt(enemy, "Counter Shot ")
        else
          performInterrupt(enemy, "Counter Shot ", saved.kickCClist)
        end
      end

      if kickPVE then
        performInterrupt(enemy, "Counter Shot ")
      elseif kickFastMD then
        performInterrupt(enemy, "Counter Shot ", saved.kickHealinglist)
      elseif kickHealer then
        performInterrupt(enemy, "Counter Shot ", saved.kickHealinglist)
      elseif kickDangerous then
        performInterrupt(enemy, "Counter Shot ", saved.kickDangerouslist)
      elseif kickCC then
        performInterrupt(enemy, "Counter Shot ", saved.kickCClist)
      elseif kickHybrid then
        performInterrupt(enemy, "Counter Shot ")
      elseif dontKickAvoidableCC then
        performInterrupt(enemy, "Counter Shot ", saved.kickCClist)
      end
    end
  end)
end)

cs:Callback("tyrants", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not saved.KickTyrant then return end
  if not blink.arena then return end

  blink.tyrants.loop(function(tyrant)

    -- tyrant must be casting or channeling
    local cast, channel = tyrant.casting, tyrant.channeling
    if not cast and not channel then return end

    -- must not be immune to interrupts
    if cast and tyrant.castint or channel and tyrant.channelint then return end
    if not tyrant.los then return end
    if not tyrant.enemy then return end
    if tyrant.dist > spell.range then return end

    if tyrant.casting then

      sr.kickDelay(function()
        if not tyrant.casting or tyrant.channeling then return end

        if spell:Cast(tyrant, {face = true}) then 
          if not saved.streamingMode then
            alert("Counter Shot " .. "|cFFf7f25c[" .. (tyrant.casting or tyrant.channel) .. "]", spell.id)  
          end
        end
      end) 
      
    end

  end)

end)

cs:Callback("seduction", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not blink.arena then return end

  --Seduction
  if blink.fighting(265, 266, 267, true) then 
    blink.enemyPets.loop(function(EnemyPet)
      -- EnemyPet must be casting or channeling
      local cast, channel = EnemyPet.casting, EnemyPet.channeling
      if not cast and not channel then return end

      -- must not be immune to interrupts
      if cast and EnemyPet.castint or channel and EnemyPet.channelint then return end
      if not EnemyPet.los then return end
      if EnemyPet.dist > spell.range then return end
      if not EnemyPet.channelID == 6358 then return end
        
      if (EnemyPet.casting and EnemyPet.castTimeComplete > delay.now 
      or EnemyPet.channel and EnemyPet.channelTimeComplete > delay.now) then
        if SettingsCheck(saved.kickCClist, EnemyPet.castingid) 
        or SettingsCheck(saved.kickCClist, EnemyPet.channelId) then

          sr.kickDelay(function()
            if not EnemyPet.casting or EnemyPet.channeling then return end
    
            if spell:Cast(EnemyPet, {face = true}) then 
              if not saved.streamingMode then
                alert("Counter Shot " .. "|cFFf7f25c[" .. (EnemyPet.casting or EnemyPet.channel) .. "]", spell.id)  
              end
            end
          end)
        end
      end
    end)
  end
end)


-- concussive shot
local function dontConc(unit, overlap)
  overlap = overlap or 0

  if not unit or not unit.exists then
    return true
  end

  return player.buff(camo.id)
  or not unit.enemy
  or not unit.los
  or unit.immuneSlow
  -- unit already in cc
  or unit.ccr > overlap
  -- standing still in tar trap
  or unit.debuff(135299) or unit.rooted and not unit.moving
end

conc:Callback("trap target", function(spell)
  if dontConc(trapTarget) then return end
  if barbed_next_gcd then barbedAlert() return end
  if player.movingToward(trapTarget, { angle = 55, flags = {1, 5, 9, 4, 8, 2057, 2053, 2049, 2056, 2052}, duration = 0 + bin(trap.cd > 8) * (trap.cd / 23) }) then
    return spell:Cast(trapTarget) and alert("|cFFf7f25c[Slow]: " .. (trapTarget.classString or "") .. "  [Trap Mode]", spell.id)
  end 
end)

conc:Callback("yolo trap", function(spell, unit)
  if dontConc(unit) then return end
  if barbed_next_gcd then barbedAlert() return end
  return spell:Cast(unit) and alert("|cFFf7f25c[Slow]: " .. (unit.classString or "") .. "  [Trap Mode]", spell.id)
end)


--! TOTEM STOMPAGE !--

local function stomp(callback)
  return blink.totems.stomp(function(totem, uptime)
    local id = totem.id
    local app = importantTotems[id]

    -- Check if the target exists and has less than 20% HP
    local cancelStomping = target.exists and target.enemy and target.hp <= 20 and not target.immunePhysicalDamage

    -- Return early if autoStomp is not enabled
    if not saved.autoStomp then return end

    -- Return if the totem does not have an ID or is not in the saved totems list
    if not totem.id or not saved.totems[totem.id] then return end

    -- If the target's HP is low, only stomp Grounding Totem
    if cancelStomping and totem.id ~= 5925 then return false end

    -- Return false if the totem is not important
    if app == false then return false end

    -- Check for custom conditions if 'app' is a function
    if type(app) == "function" and not app(totem, uptime) then return false end

    -- If 'app' is a number, check uptime against it
    if type(app) == "number" then 
      if uptime < app then return false end
      return callback(totem, uptime)
    else
      -- For other cases, check uptime against stompDelay
      if uptime < stompDelay.now and not totem.casting then return false end
      return callback(totem, uptime)
    end
  end)
end

-- barbed stomp
-- barbed:Callback("stomp", function(spell)
--   return stomp(function(totem)
--     if totem.health < 900 and pet.exists and pet.distanceTo(totem) < 15 and pet.losOf(totem) then
--       return barbed("maintain frenzy", totem) and alert("Stomp " .. totem.name, spell.id)
--     end
--   end)
-- end)

-- kc stomp
killCommand:Callback("stomp", function(spell)
  if barbed_next_gcd then barbedAlert() return end
  if pet.exists and not (pet.cc or pet.rooted) then
    return stomp(function(totem)
      if not saved.autoStomp then return end
      if not totem.id or not saved.totems[totem.id] then return end
      if player.buff(camo.id) or player.stealth then return end
      if not totem.los then return end
      -- Bypass low hp totems based on the table
      if sr.lowHpTotems[totem.id] then 
        sr.debugPrint("Bypass " ..spell.name .. " on low hp totem", totem.name) 
        return 
      end
      if pet.distanceTo(totem) < 21 and pet.losOf(totem) then
        if totem.id == 101398 
        and totem.buff(135940) 
        and tranq.cd - blink.gcdRemains == 0 then 
          return tranq:Cast(totem, { face = true })
        end
        if spell:Cast(totem, { face = true }) then
          hunter.petState.externalControl = blink.time
          return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
        end
      end
    end)
  end
end)


cobra:Callback("stomp", function(spell)
  if barbed_next_gcd then barbedAlert() return end
  return stomp(function(totem)
    if not saved.autoStomp then return end
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los then return end
    if totem.distanceLiteral > 41 then return end
    if player.buff(camo.id) or player.stealth then return end

    if totem.id == 101398 
    and totem.buff(135940) 
    and tranq.cd - blink.gcdRemains == 0 then 

      return tranq:Cast(totem, { face = true })

    end

    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)

--! END TOTEM STOMPAGE !--

-- Healthstone
-- Healthstone:Update(function(item, key)
--   if IsUsableItem(5512) and select(2,GetItemCooldown(5512)) == 0 and player.combat and not player.cc then
-- 		UseItemByName(tostring(GetItemInfo(5512)));
-- 		blink.alert("Healthstone", 6262)
-- 	end
-- end)


-- TRINKETS

--PVE Stuff
Trinkets.PVE:Update(function(item, key)
	if Trinkets.PVE.equipped then
    if player.buffFrom({bm.wild.id, bm.COTW.id}) then
      if item:Use() then
        blink.alert(item.name, item.spell)
      end
    end
  end
end)

--Badge
Trinkets.Badge:Update(function(item, key)
	if Trinkets.Badge.equipped then
    if player.buffFrom({bm.wrath.id, bm.wild.id, bm.COTW.id}) then
      if item:Use() then
        blink.alert("Badge Trinket", item.spell)
      end
    end
  end
end)

-- Ebmlem trinket
Trinkets.Emblem:Update(function(item, key)
	if Trinkets.Emblem.equipped and not player.cc then
		if item:Use() then
			blink.alert("Gladiator's Emblem", item.spell)
		end	
	end
end)


-- traptest:Callback("test", function(spell, unit)
--   --if blink.MacrosQueued['trap test'] then
--     alert("YAH")
--     local radius = 6
--     --if spell:SmartAoE(focus, {
--       { 
--         filter = function(obj, estDist, castPosition)
--         -- filter out enemy who is in bcc
--         if enemies.around(focus, 5) then
--           blink.Draw(function(draw)
--             local castPositioncc = radius
--             draw:SetColor(255, 0, 0)
--             draw:FilledCircle(castPositioncc,3)
--           end)
--           -- if estDist <= radius then return true end

--           -- if estDist <= radius * 2 then return "avoid" end
--         end
--       }

--   --   }) then
--   --     alert("trap", spell.id)
--   --   end
--   -- --end
-- end)


--Bursting by macro 

--Crows
crows:Callback("bursty", function(spell)
	if blink.MacrosQueued['burst'] and player.hasTalent(131894) and target.los and not target.immunePhysicalDamage then 
		if spell:Cast(target) then
			alert("|cFFf7f25c[Bursting]: " .. (target.classString or "") .. " ", spell.id)
		end		
	end			
end)

--primal rage BL
primalrage:Callback("bursty", function(spell)
  if not player.hasTalent(356962) then return end
  if not player.buff(264663) then return end
  if pet.dead then return end
  if not target.immunePhysical and target.los and target.dist < 40 then
    if blink.MacrosQueued['burst']
    and not (target.buff(198589) or target.buff(212800)) then
      return spell:Cast() and alert("Primal Rage", spell.id)
    end
  end
end)

--wild
burstwild:Callback("bursty", function(spell)
	if blink.MacrosQueued['burst'] and not target.immunePhysicalDamage then 
		if spell:Cast(target) then
			alert("|cFFf7f25c[Bursting]: " .. (target.classString or "") .. " ", spell.id)
		end		
	end			
end)

COTW:Callback("bursty", function(spell)
	if blink.MacrosQueued['burst'] and not target.immunePhysicalDamage then 
		if spell:Cast(target) then
			alert("|cFFf7f25c[Bursting]: " .. (target.classString or "") .. " ", spell.id)
		end		
	end			
end)

--Taunt pets Shaman/small necro covenant
-- pettaunt:Callback("tauntpets", function(spell)
--   pets.loop(function(enemyPet)
--     if (enemyPet.name == ("Greater Earth Elemental") or enemyPet.name == ("Kevin's Oozeling")) 
--     and enemyPet.distanceTo(pet) < 30
--     and enemyPet.losOf(pet) then
--       return spell:Cast(enemyPet) and alert("Taunt (Pet - " .. enemyPet.name .. ")", spell.id)
--     end
--   end)
-- end)  

hunter.importantPause = false

-- local aoeDefensives = {
--   -- [43265] = { name = "dnd", trigger = 9225, duration = 10, radius = 3.75 }, -- death and decay test
--   [51052] = { name = "AMZ", trigger = 5070, duration = 8, radius = 3.35 }, -- AMZ (big/small same ids)
--   [62618] = { name = "Dome", trigger = 5802, duration = 10, radius = 4 }, -- Dome (big/small same ids)
--   [196718] = { name = "Darkness", trigger = 11203, duration = 8, radius = 4 }, -- Darkness (nothing to diff cover of darkness from normal)
--   [198838] = { name = "Earthen", trigger = 10471, duration = 15, radius = 5 }, -- Earthen
-- }
-- ExplosiveTrap:Callback("knockdefs", function(spell)
--   local dist = blink.Distance
--   -- e.g, darkness, AMZ, earthen wall, barrier, link ..
--   -- (AoEDefensive is from my routine, finding the right area trigger)
--   if player.hasTalent(236776) then
--     local x, y, z = aoeDefensives
--     if ExplosiveTrap:SmartAoE(target, {
--       movePredTime = blink.buffer,
--       sort = function(t, b)
--         -- sort valid positions by furthest away from the defensive
--         return dist(t.x, t.y, t.z, x, y, z) > dist(b.x, b.y, b.z, x, y, z)
--       end
--     }) then blink.alert("knockknockknockknock") end
--   end
-- end)





-------------------------PVE-------------
local pveEarlyBarbedBad = function()
  if killCommand.cd <= gcdRemains and player.focus >= 29 then return true end
  --if flayedShotTicking or player.buff(flayers_mark) then return true end
  if player.focus >= 80 then return true end
end

barbed:Callback("maintainPVE", function(spell, obj)
  local bccAroundPet = blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) > 0 
  local bccAroundTarget = blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0

  if bccAroundPet or bccAroundTarget or target.immunePhysicalDamage or not target.los or not target.enemy then return end
  if pet.buffRemains(frenzy) < 1.5 then
    return spell:Cast(target, {face = true})
  end
end)

barbed:Callback("PVE", function(spell, obj)
  local bccAroundPet = blink.enemies.around(pet, 10, function(o) return o.bcc and not o.isPet end) > 0 
  local bccAroundTarget = blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0

  if bccAroundPet or bccAroundTarget or target.immunePhysicalDamage or not target.los or not target.enemy then return end

  local isSingleTarget = blink.enemies.around(pet, 10, function(o) return not o.bcc end) <= 1
  local frenzyBuff = pet.buff(frenzy)
  local frenzyRemains = pet.buffRemains(frenzy)
  local frenzyStacks = pet.buffStacks(frenzy)
  local bestialWrathCooldown = wrath.cd
  local callOfTheWildCooldown = COTW.cd
  local isCooldownSoon = bestialWrathCooldown < 15 or callOfTheWildCooldown < 15
  local shouldMaintainFrenzy = frenzyBuff and (frenzyRemains <= 1.5 or (frenzyStacks < 3 and isCooldownSoon))
  local hasMaxCharges = spell.chargesFrac >= 1

  local shouldCast = (not pet.exists and spell.charges >= spell.chargesMax)
  or pet.buff(frenzy) and pet.buffRemains(frenzy) <= barbed_refresh_time - bin(spell.chargesFrac <= 1.15 and wrath.cd > 8 + barbed_refresh_time) * gcd + bin(obj) * 1.5
  or spell.chargesFrac >= 1 + bin(pet.buff(frenzy)) * 0.9 + bin(not obj and pet.buffRemains(frenzy) >= barbed_refresh_time * 2 and pveEarlyBarbedBad()) * 1.1 - bin(pet.buffStacks(frenzy) <= 4) * 1.1 
  or wrath.cd <= 14 and spell.chargesFrac >= 1  --shouldMaintainFrenzy or hasMaxCharges

  local castTarget = nil

  if shouldCast and (isSingleTarget or not target.debuff(217200)) then
    castTarget = target
  elseif not isSingleTarget then
    blink.enemies.loop(function(enemy)
      if enemy.distanceTo(pet) <= 10 and not enemy.bcc and not enemy.debuff(217200) then
        castTarget = enemy
        return false
      end
    end)
  end

  if shouldCast 
  and castTarget 
  and castTarget.enemy then
    spell:Cast(castTarget, {face = true})
  end
end)

COTW:Callback("PVE", function(spell)
  local isBossFight = target.level == 72 or target.level == -1
  local shouldCastInPvEMode = saved.pveMode ~= "BOSS" or (isBossFight or blink.burst)

  if not shouldCastInPvEMode or not target.enemy or not player.hasTalent(spell.id) or 
     not pet.exists or spell.cd - blink.gcdRemains > 0 or barbed_next_gcd or 
     pet.rooted or pet.cc or target.immunePhysical or target.dist > 40 or not target.los then 
    return 
  end

  return spell:Cast() and alert("Call of the Wild", spell.id)
end)


bloodshed:Callback("PVE", function(spell)
  if not player.hasTalent(spell.id) then return end
  if saved.pveMode == "BOSS" and not blink.burst and not target.level == -1 and not target.level == 72 then return end 
  if not pet.losOf(target) then return end
  if pet.distanceTo(target) > 50 then return end
  if not pet.exists or pet.dead or pet.cc or pet.rooted then return end
  if target.immunePhysicalDamage then return end
  --if not player.facing(target) then return end
  if player.cc then return end
  if barbed_next_gcd then barbedAlert() return end
  if target.dist > 50 or not target.los then return end

  return spell:Cast()
end)

-- bestial wrath
wrath:Callback("PVE", function(spell)
  local isBossFight = target.level == 72 or target.level == -1
  local shouldCastInPvEMode = target.hp > 10 or (isBossFight or blink.burst)

  if not shouldCastInPvEMode or not target.enemy or
     not pet.exists --or spell.cd - blink.gcdRemains > 0 or barbed_next_gcd 
     or pet.rooted or pet.cc or target.immunePhysicalDamage or target.dist > 40
     or not target.los or not player.facing(target) then
     --or barbed.chargesFrac >= 0.9 then 
    return 
  end

  -- if not target.enemy then return end
  -- if pet.dead then return end
  -- if target.buffFrom({198589, 212800}) then return end
  -- if target.immunePhysicalDamage then return end
  -- if not player.facing(target) then return end
  -- if player.cc then return end
  -- if barbed_next_gcd then barbedAlert() return end
  -- if target.dist > 39 or not target.los then return end
  -- if barbed.chargesFrac >= 0.9 then return end

  return spell:Cast() and alert("Bestial Wrath", spell.id)

end)

wrath:Callback("maintainPVE", function(spell)
  local isBossFight = target.level == 72 or target.level == -1
  local shouldCastInPvEMode = target.hp > 10 or (isBossFight or blink.burst)

  if not shouldCastInPvEMode or not target.enemy or
     not pet.exists --or spell.cd - blink.gcdRemains > 0 or barbed_next_gcd 
     or pet.rooted or pet.cc or target.immunePhysicalDamage or target.dist > 40
     or not target.los or not player.facing(target) then
     --or barbed.chargesFrac >= 0.9 then 
    return 
  end

  if pet.buff(frenzy) 
  and pet.buffStacks(frenzy) >= 2 then
    return spell:Cast() and alert("Bestial Wrath", spell.id)
  end

end)

deathchakram:Callback("PVE", function(spell)
  if not target.enemy then return end
  if not player.hasTalent(375891) then return end
  if (target.buff(198589) or target.buff(212800) or target.immunePhysicalDamage) then return end
  --if not player.facing(target) then return end
  if player.cc then return end
  if target.dist > 39 or not target.los then return end
  --if player.buffRemains(bm.wrath.id) < 5 then return end
  if player.buffFrom({bm.wrath.id, bm.wild.id, bm.COTW.id}) or wrath.cd > 10 then
    return spell:Cast(target, {face = true})
  end
end)

cobra:Callback("PVE", function(spell)
  if saved.DisableCobra then return end
  if not target.los then return end
  if not target.enemy then return end
  if target.buffFrom({45438, 642, 362486, 186265}) then 
    return 
  end
  
  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end  

  if player.buff(268877) and player.buffRemains(268877) < 1 + blink.gcd then return end
  if barbed_next_gcd then return end

  if killCommand.cd < blink.gcd
  and not pet.rooted or pet.cc 
  and not target.buff(118038) then 
    return 
  end
  
  if player.focus <= 45 
  and killCommand.cd < blink.gcd 
  and not pet.rooted 
  or pet.cc then 
    return 
  end

  if killCommand.cd > 1 
  and player.focus > 45 or pet.rooted 
  or pet.cc then

    return spell:Cast(target)
  end
  
end)

killCommand:Callback("PVE", function(spell)
  if not target.enemy then return end
  if blink.MacrosQueued['pet back'] then return end
  --if barbed_next_gcd then barbedAlert() return end
  if not pet.exists then return end 
  if pet.dead or pet.cc or pet.rooted then return end
  if not target.los then return end
  if not pet.losOf(target) then return end
    
  return spell:Cast(target)

end)

killCommand:Callback("PrioPVE", function(spell)
  local frenzyRemains = pet.buffRemains(frenzy)
  local frenzyStacks = pet.buffStacks(frenzy)

  -- if pet.buff(frenzy) 
  -- and pet.buffRemains(frenzy) <= barbed_refresh_time - bin(spell.chargesFrac <= 1.15 
  -- and wrath.cd > 8 + barbed_refresh_time) * gcd + bin(obj) * 1.5
  -- or spell.chargesFrac >= 1 + bin(pet.buff(frenzy)) * 0.9 + bin(not obj and pet.buffRemains(frenzy) >= barbed_refresh_time * 2 
  -- and earlyBarbedBad()) * 1.1 - bin(pet.buffStacks(frenzy) <= 4) * 1.1 then
  --   return 
  -- end 
  -- if pet.buffRemains(frenzy) < barbed_efresh_time * 2 
  -- and earlyBarbedBad() * 1.1 - bin(pet.buffStacks(frenzy) < 2 * 1.1)
  -- or pet.buff(frenzy) and pet.buffRemains(frenzy) >= barbed_refresh_time then
  --   return
  -- end

  if not target.enemy then return end
  if blink.MacrosQueued['pet back'] then return end
  if barbed_next_gcd then return end
  if not pet.exists then return end 
  if pet.dead or pet.cc or pet.rooted then return end
  if not target.los then return end
  if not pet.losOf(target) then return end
  if pet.buffRemains(frenzy) <= barbed_refresh_time then return end
    
  return spell:Cast(target)

end)

multiShot:Callback(function(spell)
  local AOE = blink.enemies.around(target, 8, function(o) return not o.bcc end) > 1
  if player.buff(beastCleave) and player.buffRemains(beastCleave) > blink.gcd then return end
  if not target.enemy then return end

  if AOE then 
    return spell:Cast(target)
  end

end)

hunterMark:Callback(function(spell)
  if target.immuneMagicEffects then return end
  if target.debuff(spell.id) and target.debuffRemains(spell.id) > 1 or target.hp < 80 then return end
  if not target.enemy then return end
  
  return spell:Cast(target)

end)

cs:Callback("PVE", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local function canInterruptEnemy(unit)
    if not saved.KickPVE then return false end
    if not unit.casting and not unit.channeling then return false end
    if unit.castint or unit.channelint then return false end

    if unit.buff(377362) 
    or not unit.los or unit.dist > spell.range 
    or not player.combat
    or unit.isPlayer or blink.arena then 
      return false 
    end

    return true
  end

  local function castSpellAndAlert(unit, message, originalRotation)
    if spell:Cast(unit, {face = true}) then
      if not saved.streamingMode then alert(message, spell.id) end
      sr.debugPrint("Kicked (" .. unit.name .. ") at: (" .. unit.castTimeComplete .. ")")
      if originalRotation then blink.FaceDirection(originalRotation) end
    end
  end

  local function performInterrupt(unit, baseMessage, spellList)
    local castingIdAtStart = unit.castingid or unit.channelId
    local originalRotation = player.rotation
    local randomCastingKickPct = math.random(70, 80)
    local randomChannelingKickPct = math.random(10, 20)
    local isCastingSpell = unit.casting and unit.castPct > randomCastingKickPct
    local isChannelingSpell = unit.channeling and unit.castTimeComplete > randomChannelingKickPct

    local function castInterrupt()
      if isCastingSpell
      or isChannelingSpell
      and castingIdAtStart == (unit.castingid or unit.channelId) 
      and (not spellList or SettingsCheck(spellList, unit.castingid, unit.channelId)) then

        local spellName = unit.casting or unit.channeling
        local message = baseMessage .. " |cFFf7f25c[" .. spellName .. "]"

        if unit.los and unit.dist <= spell.range and saved.autoFaceToKick and not player.facing(unit, 180) then
          blink.controlFacing(blink.buffer + 0.1)
          player.face(unit)
          C_Timer.After(blink.buffer + 0.1, function()
            castSpellAndAlert(unit, message, originalRotation)
          end)
        else
          castSpellAndAlert(unit, message, originalRotation)
        end
      end
    end

    castInterrupt()

  end

  blink.enemies.within(spell.range).loop(function(enemy)
    
    if canInterruptEnemy(enemy) then

      local kickEverBloom = (SettingsCheck(saved.everBloomList, enemy.castingid) 
      or SettingsCheck(saved.everBloomList, enemy.channelId)) 
      
      local kickWayCrest = (SettingsCheck(saved.wayCrestList, enemy.castingid) 
      or SettingsCheck(saved.wayCrestList, enemy.channelId)) 

      local kickAtal = (SettingsCheck(saved.AtalList, enemy.castingid) 
      or SettingsCheck(saved.AtalList, enemy.channelId)) 

      local kickbrh = (SettingsCheck(saved.brhList, enemy.castingid) 
      or SettingsCheck(saved.brhList, enemy.channelId)) 

      local kickdarkHeart = (SettingsCheck(saved.darkHeartList, enemy.castingid) 
      or SettingsCheck(saved.darkHeartList, enemy.channelId)) 

      local kickdawnInfinite = (SettingsCheck(saved.dawnInfiniteList, enemy.castingid) 
      or SettingsCheck(saved.dawnInfiniteList, enemy.channelId)) 

      local kickTOT = (SettingsCheck(saved.TOTList, enemy.castingid) 
      or SettingsCheck(saved.TOTList, enemy.channelId)) 

      local kickAll = blink.instancetype2 == "none"

      if kickEverBloom then
        performInterrupt(enemy, "Counter Shot ", saved.everBloomList)
      elseif kickWayCrest then
        performInterrupt(enemy, "Counter Shot ", saved.wayCrestList)
      elseif kickAtal then
        performInterrupt(enemy, "Counter Shot ", saved.AtalList)
      elseif kickbrh then
        performInterrupt(enemy, "Counter Shot ", saved.brhList)
      elseif kickdarkHeart then
        performInterrupt(enemy, "Counter Shot ", saved.darkHeartList)
      elseif kickdawnInfinite then
        performInterrupt(enemy, "Counter Shot ", saved.dawnInfiniteList)
      elseif kickTOT then
        performInterrupt(enemy, "Counter Shot ", saved.TOTList)
      elseif kickAll then
        performInterrupt(enemy, "Counter Shot ")
      end
    end
  end)

end)