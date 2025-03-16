local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local shaman, ele = sr.shaman, sr.shaman.ele
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local gcd, buffer, latency, tickRate, gcdRemains = 0, 0, 0, 0, 0
local saved, cmd = sr.saved, sr.cmd
local colors = blink.colors
local enemy = blink.enemy
local bin = blink.bin
local enemyPets = blink.enemyPets
local NewItem = blink.Item
local delay = blink.delay(0.5, 0.7)
local stompDelay = blink.delay(0.5, 0.6)
local lastTimeCounted = 0
local alert = blink.alert

local currentSpec = GetSpecialization()

if not shaman.ready then return end

if currentSpec ~= 1 then return end

blink.Populate({

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
  flameShock = NS(188389, { damage = "magic", ranged = true, alwaysFace = true }),
  lightningBolt = NS(188196, { damage = "magic", ranged = true, alwaysFace = true }),
  lavaBurst = NS(51505, { damage = "magic", ranged = true, ignoreGCD = true, alwaysFace = true}),
  earthShock = NS(8042, { damage = "magic", ranged = true, alwaysFace = true }),
  primordialWave = NS(375982, { damage = "magic", ranged = true, alwaysFace = true }),
  iceFury = NS(210714, { damage = "magic", ranged = true }),

  -- cc
  lasso = shaman.lasso,
  frostShock = NS(196840, { damage = "magic", slow = true }),
  windShear = NS(57994, { effect = "magic", ignoreGCD = true, ignoreCasting = true, alwaysFace = true }),
  hex = NS(51514, { effect = "magic", ignoreFacing = true, cc = "polymorph" }),
  pulverize = NS(118345, { effect = "magic", stun = true, ignoreGCD = true, ignoreFacing = true, ignoreStuns = true, beneficial = true, ignoreUsable = true}),

  -- offensive
  AS = NS(443454, { ignoreGCD = true }),
  bloodlust = NS(204361, { ignoreGCD = true, ignoreFacing = true }),
  hero = NS(204362, { ignoreGCD = true, ignoreFacing = true }),
  ascendance = NS(114050),
  stormKeeper = NS(191634, { damage = "magic", ranged = true, ignoreMoving = true }),
  meteor = NS(117588, { damage = "magic", ranged = true }),


  -- defensive
  astralShift = NS(108271, { ignoreFacing = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true }),
  burrow = shaman.burrow,
  Healthstone = NewItem(5512),
  thunderStorm = NS(51490, { ignoreStuns = true }),
  healingSurge = NS(8004, { ignoreFacing = true, heal = true }),
  healingStream = NS(5394, { ignoreFacing = true, heal = true }),
  ancestralGuidance = NS(108281, { ignoreGCD = true, ignoreFacing = true, heal = true }),

  --pets
  fireElemental = NS(198067),
  earthElemental = NS(198103),

  --totems
  totemRecall = NS(108285),
  totemicProjection = NS(108287,{ ignoreFacing = true, diameter = 2 }),
  earthGrab = NS(51485, { effect = "magic", slow = true, ignoreFacing = true, diameter = 16 }),
  staticFieldTotem = NS(355580, { effect = "magic", ignoreFacing = true, diameter = 6 }),
  tremor = NS(8143),
  grounding = shaman.grounding,
  skyFury = NS(462854), --old id 204330
  capacitor = NS(192058, { effect = "magic", stun = true, ignoreFacing = true, diameter = 16 }),
  counterStrike = NS(204331),
  liquidMagma = NS(192222, { effect = "magic", ignoreFacing = true, diameter = 16 }),
  bulwarkTotem = NS(108270),

  --buffs
  lightningShield = NS(192106),
  flameTongue = NS(318038),
  earthShield = NS(974, { ignoreFacing = true, ranged = true }),
  waterWalking = NS(546),

  --Misc
  poisionTotem = NS(383013),
  spiritWalker = NS(79206, { ignoreGCD = true, ignoreMoving = true}),
  cleanse = NS(51886, { ignoreFacing = true, ranged = true }),
  ghostWolf = NS(2645, {ignoreMoving = true, ignoreFacing = true, ignoreGCD = true, ignoreCasting = true, ignoreChanneling = true}),
  purge = NS({ 378773, 370 }, { ignoreFacing = true, ranged = true }), --ignoreUsable = true


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
    Badge = blink.Item({216368, 216279, 209343, 209763, 205708, 205778, 201807, 201449, 218421, 218713}),
    Emblem = blink.Item({216371, 216281, 209345, 209766, 201809, 201452, 205781, 205710, 218424, 218715}),
  },
  
  -- items
  tierPieces = NewItem({200390, 200392, 200387, 200389, 200391}),


}, ele, getfenv(1))


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

--immunes to hex
local immuneToHex = {
  24858, --boomkin form
  33891,
  5487,
  768,
  783,
  6940,
  199448,
  199452,
  199450,
  377362, --precognition
  421453, --Ultimate Penitence
  354610, --dh Glimpse

}

--Cleanse
local cleanseThem = {
  [332605] = { uptime = 0.15 },  --hex
  [219215] = { uptime = 0.15 },  --hex
  [277778] = { uptime = 0.15 },  --hex
  [17172] = { uptime = 0.15 },  --hex
  [66054] = { uptime = 0.15 },  --hex
  [11641] = { uptime = 0.15 },  --hex
  [271930] = { uptime = 0.15 },  --hex
  [270492] = { uptime = 0.15 },  --hex
  [18503] = { uptime = 0.15 },  --hex
  [289419] = { uptime = 0.15 },  --hex
  [51514] = { uptime = 0.15 },  --hex
	[199954] = { uptime = 0.15 }, --curse of frag
  [199890] = { uptime = 0.15 }, --curse of tongues
  [211015] = { uptime = 0.15 }, --hex cockroach
	[210873] = { uptime = 0.15 }, --hex compy
  [211010] = { uptime = 0.15 }, --hex snake
	[211004] = { uptime = 0.15 }, --hex spider
  [277784] = { uptime = 0.15 }, --hex wicker mongrel
	[277778] = { uptime = 0.15 }, --hex zandalari tendonripper
  [309328] = { uptime = 0.15 }, --hex living honey
	[269352] = { uptime = 0.15 }, --hex skeletal raptor
  	--[80240] = { uptime = 0.15 },  --havoc
--  [356727] = { uptime = 0.15 }, --chimaeral sting silence
  --  [356730] = { uptime = 0.15 }, --chimaeral healing reduce
}

--Slow By buff name table
local BigDamageBuffs =
{
  102543, --Incarnation
  --  152262, --Seraphim
  31884, --Avenging Wrath
  51271, --Pillar of Frost
  187827, --Metamorphosis
  266779, --Coordinated Assault1
  360952, --Coordinated Assault2
  386276, --Bonedust Brew
  185422, --Shadow Dance1
  185313, --Shadow Dance2
  121471, --Shadow Blades
  360194, --Vendetta/Deathmark
  384352, --Doom Winds
  167105, --Colossus Smash
  107574, --Avatar
  1719,   --Recklessness
  231895, --Crusade
  324143, --Conqueror's Banner
  384631, --Flagellation
  13750, --Adrenaline Rush

} 

local FullyImmuneBuffs = 
{
  642, --"Divine Shield",
  45438, --"Ice Block",
  186265, --"Aspect of the Turtle",
  -- 198589, --"Blur",
  -- 212800, --"Blur",
  362486, --Keeper of the Grove
  408558, --priest phase shift
  1022, --"Blessing of Protection",
  196555, --netherwalk
}

local FullyImmuneDeBuffs = 
{
  33786, --Cyclone
  217832, --Imprison
  203337, --Diamond Ice
}

local PurgeMePls = {
  --Power Infusion
  [10060] = function(source)
    return not source.role == "healer"
  end,
  --Blessing of Protection
  [1022] = function(source)
    return sr.friendlyPhysical()
  end,
  --Druid Nature's Swiftness
  [132158] = function() 
    return true 
  end,
  --Shaman Nature's Swiftness
  [378081] = function() 
    return true 
  end,
  --Mage Alter time
  [342246] = function() 
    return true 
  end,
  --Mage Alter time2
  [198111] = function() 
    return true 
  end,  
  --Holy Word
  [213610] = function() 
    return true 
  end, 
  --Warlock Netherward
  [212295] = function() 
    return true 
  end,      
}

local LowPrioPurgeMePls = {
  360827, --Blistering Scales
  79206,  --Spiritwalker's Grace
  10060,  --Power Infusion
  80240,  --Havoc
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  1044,   --Blessing of Freedom2
  1022,   --Blessing of Protection
  210294, --divine-favor
  305497, --Thorns
  132158, --Druid Nature's Swiftness
  378081, --Shaman Nature's Swiftness
  342246, --Mage Alter time
  198111, --Mage Alter time
  11426,  --Mage barrier
  198094, --Mage barrier
  414661, --Mage barrier
  342242, --Mage Timewrap
  213610, --Holy Word
  212295, --Warlock Netherward
}

local realBCC = {

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
  
  2094, --blind
  105421, --blinding light
  3355, --freezing trap
  2637, --Hibernate
  82691, --ring
  20066, --repentance
  6770, --Sap
  213691, --scatter
  6358, --seduction
  198909, --song of chi
}

--add deathmark 360194

local flameShockDebuff = 188389

local flameShock_next_gcd = false 
local flameShock_refresh_time = 0
local flameShockAlert = function()
  if gcdRemains > 0 then return end
  sr.debugAlert("Waiting |cFFf7f25c[Flame Shock]", flameShock.id)
end

-- hook first spell callback per frame
hookCallbacks(function(spell)

  gcd, buffer, latency, tickRate, gcdRemains = blink.gcd, blink.buffer, blink.latency, blink.tickRate, blink.gcdRemains
  
  flameShock_refresh_time = blink.gcd + blink.buffer + blink.latency + blink.tickRate + 0.215

  flameShock_next_gcd = target.exists 
  and target.enemy
  and target.debuffRemains(flameShockDebuff, player) <= flameShock_refresh_time

end)

-- cancel queued shit spell if possible on ks proc
onUpdate(function()
  cancelHealing = target.exists and target.enemy and target.hp <= 20 or player.buff(375986) and target.los and not target.immuneMagicDamage
  local isQueued = C_Spell.IsCurrentSpell(188389) or C_Spell.IsCurrentSpell(8042) or C_Spell.IsCurrentSpell(196840)
  if player.buff(77762) then
    if isQueued
    and target.exists
    and target.debuffRemains(flameShockDebuff, player) > 2
    and not C_Spell.IsCurrentSpell(51505) then
      blink.call("SpellCancelQueuedSpell")
      --blink.alert("Lava Proc",lavaBurst.id)
    end
  end
end)


local waveDebugCount = 0

-- hook :Cast calls that return true
hookCasts(function(spell)
  if spell.id == primordialWave.id then 
    waveDebugCount = waveDebugCount + 1
  else
    waveDebugCount = 0
  end
end)


--! TOTEM STOMPAGE !--
local isNearFriend = function(totem)
  return blink.fullGroup.around(totem, 6, function(friend) 
    return true --totem.id == 61245 or friend.role == "melee" or friend.role == "healer"
  end) > 0
end

local fearClasses = {"WARLOCK", "PRIEST", "WARRIOR"}
local importantTotems = {
  [5913] = fearClassOnTeam, -- Tremor
  [2630] = function(totem) return isNearFriend(totem) end, -- Earthbind
  [60561] = function(totem) return isNearFriend(totem) end, -- Earthgrab
  [61245] = function(totem) return isNearFriend(totem) end, --Capacitor 
  [179867] = function(totem) return isNearFriend(totem) end, --Static Field Totem 
  --[59764] = function(totem, uptime) return uptime < 8 end,  --Healing Tide
  [59764] = function(totem, uptime) return uptime < 8 or totem.hp < 55 end,  --Healing Tide
}

-- hook stomp
hookCallbacks(function()
  for _, member in ipairs(blink.group) do 
    fearClassOnTeam = fearClassOnTeam or tContains(fearClasses, member.class2)
  end
  importantTotems[5913] = fearClassOnTeam
end, {"stomp"})


local function stomp(callback)
  return blink.totems.stomp(function(totem, uptime)
    local id = totem.id
    local app = importantTotems[id]

    -- Check if the target exists and has less than 20% HP
    local cancelStomping = target.exists and target.enemy and target.hp <= 20 and not target.immuneMagicDamage

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


frostShock:Callback("stomp", function(spell)
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los then return end
    if totem.dist > 40 then return end
    if player.used(spell.id, 2) then return end
    if frostShock.damage < totem.health then return end
    if totem.id == 59764 and totem.hp > 50 then return end

    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)

lavaBurst:Callback("stomp", function(spell)
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los or totem.dist > 40 then return end

    -- Bypass low hp totems based on the table
    if sr.lowHpTotems[totem.id] then 
      sr.debugPrint("Bypass " ..spell.name .. " on low hp totem", totem.name) 
      return 
    end

    if not player.buff(77762) then return end

    if spell:Cast(totem, { face = true }) then
      alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)

earthShock:Callback("stomp", function(spell)
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los or totem.dist > 40 then return end

    -- Bypass low hp totems based on the table
    if sr.lowHpTotems[totem.id] then 
      sr.debugPrint("Bypass " ..spell.name .. " on low hp totem", totem.name) 
      return 
    end

    if player.power >= 50 and target.hp < 30 then return end
    if player.power < 50 then return end

    if spell:Cast(totem, { face = true }) then
      alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)

lightningShield:Callback(function(spell)

  if player.buff(spell.id) and player.buffRemains(spell.id) > 2 then return end

  if sr.longDelay() then
    return spell:Cast()
  end
end)

flameTongue:Callback(function(spell)

  if player.mainHandEnchantRemains > 60 then return end

  if sr.longDelay() then
    return spell:Cast()
  end
end)

earthShield:Callback(function(spell)
  if cancelHealing then return end
  if player.buffRemains(383648, player) > 2 then return end

  if sr.longDelay() then
    return spell:Cast(player)
  end
end)

spiritWalker:Callback("pre",function(spell)
  return spell:Cast()
end)

ascendance:Callback(function(spell)
  if not saved.autoAscendance and not blink.MacrosQueued["burst"] then return end
  if player.buff(spell.id) 
  or target.immuneMagicDamage
  or not target.debuff(flameShockDebuff, player) then 
    return 
  end

  return spell:CastAlert()
end)

bloodlust:Callback(function(spell)
  if not saved.autoLust and not blink.MacrosQueued["burst"] then return end
  if not player.faction == "Horde" then return end

  if player.buff(spell.id) 
  or target.immuneMagicDamage
  or not target.debuff(flameShockDebuff, player) then 
    return 
  end

  local fdps = blink.group.within(spell.range).find(function(member)
    return member.los and member.isRanged or member.isMelee and not member.isHealer and not member.buff(spell.id)
  end)

  if fdps 
  and (blink.arena 
  or blink.instantType2 == "pvp") then
    return spell:CastAlert(fdps)
  else
    return spell:CastAlert()
  end
end)

hero:Callback(function(spell)
  if not player.faction == "Alliance" then return end
  if player.buff(spell.id) 
  or target.immuneMagicDamage
  or not target.debuff(flameShockDebuff, player) then 
    return 
  end

  local fdps = blink.group.within(spell.range).find(function(member)
    return member.los and member.isRanged or member.isMelee and not member.isHealer and not member.buff(spell.id)
  end)

  if fdps 
  and (blink.arena 
  or blink.instantType2 == "pvp") then
    return spell:CastAlert(fdps)
  else
    return spell:CastAlert()
  end

end)

stormKeeper:Callback(function(spell)

  if not player.hasTalent(191634)
  or target.immuneMagicDamage then 
    return 
  end

  if player.moving 
  and spiritWalker.cd - blink.gcdRemains == 0 then
    spiritWalker("pre")
  else
    return spell:Cast()
  end

end)

AS:Callback(function(spell)
  --maybe add a check if unit.id == 221177 exists we can't cast it so don't spamm it 9505
  if not player.hasTalent(spell.id) then return end
  return spell:Cast()
end)

earthShield:Callback("prep", function(spell)

  if player.buff(77762) then return end

  if blink.arena then
    if blink.prep 
    and blink.prepRemains < 30
    and blink.prepRemains > 1 then

      blink.group.loop(function(member)

        sr.randomDelay(function()
          if member.isHealer then return end
          if member.isHealer and member.buffRemains(974, player) > 2 then return end
          if player.used(spell.id, 5) then return end
          if not member.dist or member.dist > 40 then return end
          if member.buffRemains(974, player) > 1 then return end
            
          return spell:Cast(member) and blink.alert("Earth Shield - " .. "[" .. member.classString .. "]", spell.id)
        end)
        
      end)

    end
  end
end)

earthShield:Callback("friend", function(spell)
  if cancelHealing then return end
  if player.buff(77762) and target.hp < 50 then return end
  if blink.prep or not blink.arena then return end

  local earthShieldBuffId = 974
  local minTimeToSwap = 8  -- Minimum time to keep Earth Shield on a target before swapping
  local significantThreatIncrease = 0.2  -- 20% more threat needed to swap targets
  local additionalWeightForMultipleAttackers = 10  -- Additional weight for being attacked by more than one enemy
  local healthThreshold = 80  -- Health percentage threshold for casting Earth Shield

  local currentTarget = blink.group.find(function(member)
    return member.buff(earthShieldBuffId, player)
  end)

  local function threatLevel(member)
    local total, melee, ranged, cooldowns = member.v2attackers()
    local attackerWeight = total > 1 and additionalWeightForMultipleAttackers or 0
    return member.hp - (total * 5 + cooldowns * 10 + attackerWeight)
  end

  local currentThreatLevel = currentTarget and threatLevel(currentTarget) or math.huge

  blink.group.sort(function(x, y)
    return threatLevel(x) < threatLevel(y)
  end)

  local function shouldCast(member)
    local memberThreatLevel = threatLevel(member)
    local isSignificantlyMoreThreatened = not currentTarget or (memberThreatLevel < currentThreatLevel * (1 - significantThreatIncrease))

    return member.hp <= healthThreshold and member.los and member.dist <= spell.range and
      (not currentTarget or member == currentTarget or isSignificantlyMoreThreatened) and
      (not currentTarget or member.buffRemains(earthShieldBuffId, player) <= minTimeToSwap)
  end

  blink.group.loop(function(member)
    if shouldCast(member) and not player.used(spell.id, 5) then
      return spell:Cast(member) and blink.alert("Earth Shield - [" .. member.classString .. "]", spell.id)
    end
  end)

end)


primordialWave:Callback("burst", function(spell)
  if not saved.autoPWave and not blink.MacrosQueued["burst"] then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local function isValidTarget(unit)
    return unit.exists and unit.los and not unit.immuneMagicDamage 
    and unit.dist <= spell.range and not unit.buffFrom(FullyImmuneBuffs)
    and (unit.debuffRemains(flameShockDebuff, player) <= 13 or blink.burst)
    and not unit.debuffFrom(FullyImmuneDeBuffs) 
    and not unit.buff(48707)
    and not unit.debuffFrom(realBCC)
    --and not (blink.arena and not unit.isPlayer) 
    and not (unit.name == "PvP Training Dummy") --"PvP Training Dummy"
  end

  -- Check if the current target is valid
  if target.enemy and isValidTarget(target) then
    return spell:Cast(target, {face = true})
  else
    -- Find the enemy with the lowest Flame Shock duration using find
    local lowestDurationEnemy = blink.enemies.within(spell.range).find(function(enemy)
      return isValidTarget(enemy) and enemy.debuffRemains(flameShockDebuff, player) < math.huge
    end)

    if lowestDurationEnemy then
      return spell:Cast(lowestDurationEnemy, {face = true})
    end
  end
end)



-- primordialWave:Callback("burst", function(spell)
--   if spell.cd - blink.gcdRemains > 0 then return end

--   if target.enemy 
--   and target.los
--   and target.exists 
--   and target.dist <= spell.range
--   and target.debuffRemains(flameShockDebuff, player) <= 12
--   and not target.buffFrom(FullyImmuneBuffs)
--   and not target.debuffFrom(FullyImmuneDeBuffs)
--   and not target.immuneMagicDamage 
--   and not target.buff(48707)
--   and not target.name == "PvP Training Dummy" then

--     return spell:Cast(target, {face = true})

--   else
    
--     blink.enemies.within(40).loop(function(enemy)

--       if enemy.debuffRemains(flameShockDebuff, player) > 12 then return end

--       if enemy.dist > spell.range then return end
--       if not enemy.exists then return end
--       if not enemy.los then return end
--       if enemy.immuneMagicDamage then return end
--       if enemy.class2 == "DEATHKNIGHT" and enemy.buff(48707) then return end
--       if enemy.buffFrom(FullyImmuneBuffs) then return end
--       if enemy.debuffFrom(FullyImmuneDeBuffs) then return end
        
--       if blink.arena then
--         if enemy.debuffFrom(realBCC) then return end 
--         if not enemy.isPlayer then return end

--         return spell:Cast(enemy, {face = true})

--       else
--         if enemy.name == "PvP Training Dummy" then return end
--         if enemy.debuffFrom(realBCC) then return end 

--         return spell:Cast(enemy, {face = true})

--       end
--     end)
--   end

-- end)


frostShock:Callback("maintain", function(spell)
  if target.dist > 40 then return end
  if target.immuneMagicEffect then return end
  if not target.enemy then return end
  if not target.los then return end
  if lavaBurst.cd - blink.gcdRemains == 0 then return end
  if player.buff(381777) then return end

  if player.buff(210714) 
  and not player.buff(381777) then 

    return spell:Cast(target)

  elseif target.debuffRemains(spell.id) < blink.gcdRemains + 1.5 then
    
    return spell:Cast(target)
  end

end)

frostShock:Callback("reflects", function(spell)

  if target.exists 
  and target.hp <= 30 
  and not target.class2 == "WARRIOR" then 
    return 
  end

  if target.exists 
  and player.buff(77762)
  and not target.class2 == "WARRIOR" then 
    return 
  end

  if not target.los then return end
  if target.dist > 40 then return end

  if target.buff(23920) then 

    return spell:Cast(target, {face = true})

  end

  -- blink.enemies.within(40).loop(function(enemy)

  --   if target.exists 
  --   and target.hp <= 30 
  --   and not target.class2 == "WARRIOR" then 
  --     return 
  --   end

  --   if target.exists 
  --   and player.buff(77762)
  --   and not target.class2 == "WARRIOR" then 
  --     return 
  --   end

  --   if not enemy.los then return end
  --   if enemy.dist > 40 then return end

  --   if player.target.isUnit(enemy)
  --   and enemy.buff(23920) then 

  --     return spell:Cast(enemy, {face = true})

  --   end
  -- end)
end)

flameShock:Callback("all", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  if target.enemy 
  and target.los
  and target.dist <= 40
  and target.exists 
  and target.debuffRemains(flameShockDebuff, player) < 8 then
    return spell:Cast(target, {face = true})
  else
    local flameShockCount = blink.enemies.around(player, 40, function(obj) 
      return obj.debuff(flameShockDebuff) and obj.debuffRemains(flameShockDebuff, player) > 5 
    end)

    if flameShockCount < 5 then
      local enemyToCast = blink.enemies.within(40).find(function(enemy)
        return enemy.exists and enemy.los and enemy.dist <= spell.range
          and enemy.debuffRemains(flameShockDebuff, player) <= 8
          and not enemy.debuffFrom(realBCC)
          and (not blink.arena or (enemy.isPlayer and target.hp >= 50))
      end)

      if enemyToCast then
        return spell:Cast(enemyToCast, {face = true})
      end
    end
  end
end)

flameShock:Callback("pets", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local flameShockCount = blink.pets.around(player, 40, function(obj) 
    return obj.debuff(flameShockDebuff) and obj.debuffRemains(flameShockDebuff, player) > 5 
  end)

  if flameShockCount < 5 then
    local petToCast = blink.pets.within(40).find(function(pet)
      return pet.exists and pet.los and pet.dist <= spell.range and pet.enemy
        and pet.debuffRemains(flameShockDebuff, player) <= 8
        and not pet.debuffFrom(realBCC)
    end)

    if petToCast then
      return spell:Cast(petToCast, {face = true})
    end
  end
end)

primordialWave:Callback(function(spell)
  if not saved.autoPWave and not blink.MacrosQueued["burst"] then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  if target.enemy 
  and target.los
  and target.exists 
  and target.dist <= spell.range
  and target.debuffRemains(flameShockDebuff, player) < 6
  and not target.buffFrom(FullyImmuneBuffs)
  and not target.debuffFrom(FullyImmuneDeBuffs)
  and not target.immuneMagicDamage 
  and not target.buff(48707)
  and not target.name == "PvP Training Dummy" then
    return spell:Cast(target, {face = true})
  else
    local flameShockCount = enemies.around(player, 40, function(obj) 
      return obj.debuff(flameShockDebuff) and obj.debuffRemains(flameShockDebuff, player) > 1 
    end)

    if flameShockCount < 5 then
      local enemyToCast = blink.enemies.within(40).find(function(enemy)
        return enemy.exists and enemy.los and enemy.dist <= spell.range
          and enemy.debuffRemains(flameShockDebuff, player) <= 8
          and not enemy.debuffFrom(realBCC)
          and not enemy.immuneMagicDamage
          and not (enemy.class2 == "DEATHKNIGHT" and enemy.buff(48707))
          and not enemy.buffFrom(FullyImmuneBuffs)
          and not enemy.debuffFrom(FullyImmuneDeBuffs)
          and enemy.name ~= "PvP Training Dummy"
      end)

      if enemyToCast then
        return spell:Cast(enemyToCast, {face = true})
      end
    end
  end
end)

liquidMagma:Callback("all", function(spell)
  -- Early exits: check cooldown and global cooldown
  if spell.cd - blink.gcdRemains > 0 then return end

  -- Find the best position to cast Liquid Magma Totem
  local bestPosition = blink.allEnemies.within(spell.range).find(function(enemy)
    if not enemy.exists or not enemy.los or enemy.dist > spell.range then return false end

    -- Count nearby valid enemies for Flame Shock
    local nearbyCount = blink.enemies.around(enemy, 8, function(e)
      return e.exists and e.los and not e.debuff(flameShockDebuff, player) and not e.bcc
    end)

    -- Return true if this enemy's location hits more targets than the current max
    return nearbyCount > 0
  end)

  -- Cast Liquid Magma Totem if we find a good position
  if bestPosition then
    return spell:AoECast(bestPosition, {
      movePredTime = blink.buffer,
    })
  end
end)

lightningBolt:Callback(function(spell)

  if blink.instancetype ~= "pvp" then 
    if target.dist > spell.range then return end
    if not target.exists then return end
    if not target.los then return end
    if not target.enemy then return end
    if not player.buff(191634) then return end
    if player.buff(77762) then return end

    return spell:Cast(target)

  else   
    if target.dist > spell.range then return end
    if not target.exists then return end
    if not target.los then return end
    if not target.enemy then return end
    if player.buff(77762) then return end

    return spell:Cast(target)

  end

end)

lightningBolt:Callback("pve",function(spell)
  if target.dist > spell.range then return end
  if not target.exists then return end
  if not target.los then return end
  if not target.enemy then return end
  if player.buff(77762) then return end
  if target.isDummy then return end
  if blink.instancetype == "pvp" then return end
  if target.isPlayer then return end 

  return spell:Cast(target) 

end)

iceFury:Callback(function(spell)

  if target.dist > spell.range then return end
  if not target.exists then return end
  if not target.los then return end
  if not target.enemy then return end
  if target.name == "PvP Training Dummy" then return end

  if blink.instancetype ~= "pvp" then 
    if lavaBurst.cd - blink.gcdRemains == 0 then return end
    if earthShock.cd - blink.gcdRemains == 0 and player.power >= 50 then return end
    if player.buff(77762) or lavaBurst.cd - blink.gcdRemains == 0 then return end
    if player.buff(191634) then return end

    return spell:Cast(target)

  else

    return spell:Cast(target)
  end
end)


lavaBurst:Callback(function(spell)
  --if flameShock_next_gcd then flameShockAlert() return end
  if not target.debuff(flameShockDebuff) then return end
  if target.dist > spell.range then return end
  if not target.exists then return end
  if not target.los then return end
  if not target.enemy then return end

  if (flameShock.cd - blink.gcdRemains == 0 
  or primordialWave.cd - blink.gcdRemains == 0) 
  and not target.debuff(flameShockDebuff) then 
    return 
  end

  return spell:Cast(target, {face = true})

end)

lavaBurst:Callback("proc", function(spell)
  --if flameShock_next_gcd then flameShockAlert() return end
  if not target.debuff(flameShockDebuff) then return end
  if target.dist > spell.range then return end
  if not player.buff(77762) then return end
  if not target.exists then return end
  if not target.enemy then return end
  if not target.los then return end

  if (flameShock.cd - blink.gcdRemains == 0 
  or primordialWave.cd - blink.gcdRemains == 0) 
  and not target.debuff(flameShockDebuff) then 
    return 
  end

  return spell:Cast(target, {face = true})

end)

lavaBurst:Callback("procOthers", function(spell)
  local bestEnemy = blink.enemies.within(40).find(function(enemy)
    if target.los and target.debuff(flameShockDebuff) then return false end
    if enemy.dist > spell.range then return false end
    if not player.buff(77762) then return false end
    if not enemy.exists then return false end
    if not enemy.los then return false end

    local toDps = enemy.debuff(flameShockDebuff) and enemy.los and not enemy.isHealer and not enemy.debuffFrom(realBCC)
    local toHealer = enemy.debuff(flameShockDebuff) and enemy.los and enemy.isHealer and not enemy.debuffFrom(realBCC)

    if toDps or toHealer then
      return true
    end

    return false
  end)

  if bestEnemy then
    if (flameShock.cd - blink.gcdRemains == 0 or primordialWave.cd - blink.gcdRemains == 0) 
    and not target.debuff(flameShockDebuff) then 
      return 
    end

    if blink.arena and not bestEnemy.isPlayer then return end

    spell:Cast(bestEnemy, { face = true })
  end
end)

lavaBurst:Callback("anyone", function(spell)
  local enemyToCast = blink.enemies.within(spell.range).find(function(enemy)
    if enemy.dist > spell.range then return false end
    if not enemy.isPlayer then return false end
    if not enemy.los then return false end
    if enemy.hp > 20 then return false end
    if not player.buff(77762) then return false end
    if not enemy.debuff(flameShockDebuff) then return false end
    if enemy.immuneMagicDamage then return false end

    return enemy.hp <= 20
  end)

  if enemyToCast then
    spell:Cast(enemyToCast, {face = true})
  end
end)

lavaBurst:Callback("pve",function(spell)
  if flameShock_next_gcd then flameShockAlert() return end
  if target.dist > 40 then return end
  if not target.exists then return end
  if not target.enemy then return end
  if not target.los then return end
  if target.isDummy then return end
  if blink.instancetype == "pvp" then return end
  if target.isPlayer then return end 

  return spell:Cast(target) 

end)

earthShock:Callback(function(spell)
  if target.dist > spell.range then return end
  if not target.exists then return end
  if not target.los then return end
  if not target.enemy then return end
  if player.buff(77762) then return end
  if player.power < 50 then return end
  if player.used(spell.id, blink.gcd) then return end

  return spell:Cast(target)

end)

earthShock:Callback("full",function(spell)
  if target.dist > spell.range then return end
  if not target.exists then return end
  if not target.los then return end
  if not target.enemy then return end
  if player.buff(77762) and player.power < 150 then return end
  if player.power < 150 then return end
  if player.used(spell.id, blink.gcd) then return end

  return spell:Cast(target)

end)

earthShock:Callback("anyone", function(spell)

  blink.enemies.loop(function(enemy)
    if enemy.dist > spell.range then return end
    if not enemy.isPlayer then return end
    if not enemy.los then return end
    if enemy.hp > 20 then return end
    if player.power < 50 then return end

    if enemy.immuneMagicDamage then return end

    if enemy.hp <= 20 then
      return spell:Cast(enemy, {face = true})
    end

  end)

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

windShear:Callback("interrupt", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local function canInterruptEnemy(unit)
    if not unit.casting and not unit.channeling then return false end
    if unit.castint or unit.channelint then return false end
    if unit.buffFrom({377362, 215769, 421453}) or not unit.los or unit.dist > spell.range then return false end
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
                    and not sr.NoNeedToKickThis(enemy)

      local kickHybrid = saved.HybridsKick and enemy.hp <= 80 and not enemy.immuneMagicEffect and not enemy.isHealer 
                         and tContains(KickHealing, (enemy.casting))

      local dontKickAvoidableCC = saved.DontKickAvoidableCC and enemy.castTarget.isUnit(healer)
                                  and healer.incapDR >= 0.5 and healer.class2 == "PRIEST"
                                  and (healer.cc or healer.cooldown(32379) >= 1)
                                  and tContains(DontKickAvoidableCCTable, (enemy.casting or enemy.channeling))
                                  and not sr.NoNeedToKickThis(enemy)                        

      --Triple DR check                            
      if saved.TripleDR then
        local isTargeted = (enemy.castTarget.isUnit(healer) and healer.incapDR >= 0.5) or 
                          (enemy.castTarget.isUnit(player) and player.incapDR >= 0.5)
      
        local shouldInterruptDRSafe = isTargeted and (
          (tContains(listOfHexAndPolys, enemy.casting) and not saved.DontKickAvoidableCC) 
          --or (enemy.castID == 5782 or enemy.castID == 20066 or enemy.castID == 360806) and not sr.NoNeedToKickThis(enemy)
        )
      
        if shouldInterruptDRSafe then
          performInterrupt(enemy, "Wind Shear ")
        else
          performInterrupt(enemy, "Wind Shear ", saved.kickCClist)
        end
      end

      if kickPVE then
        performInterrupt(enemy, "Wind Shear ")
      elseif kickFastMD then
        performInterrupt(enemy, "Wind Shear ", saved.kickHealinglist)
      elseif kickHealer then
        performInterrupt(enemy, "Wind Shear ", saved.kickHealinglist)
      elseif kickDangerous then
        performInterrupt(enemy, "Wind Shear ", saved.kickDangerouslist)
      elseif kickCC then
        performInterrupt(enemy, "Wind Shear ", saved.kickCClist)
      elseif kickHybrid then
        performInterrupt(enemy, "Wind Shear ")
      elseif dontKickAvoidableCC then
        performInterrupt(enemy, "Wind Shear ", saved.kickCClist)
      end
    end
  end)
end)


-- windShear:Callback("interrupt", function(spell)

--   if spell.cd - blink.gcdRemains > 0 then return end

--   blink.enemies.within(spell.range).loop(function(enemy)
--     -- enemy must be casting or channeling
--     local cast, channel = enemy.casting, enemy.channeling
--     if not cast and not channel then return end

--     -- must not be immune to interrupts
--     if cast and enemy.castint or channel and enemy.channelint then return end
--     if enemy.buff(377362) then return end
--     if not enemy.los then return end
--     if enemy.dist > spell.range then return end

--     --kick anything in PVE 
--     if saved.KickPVE 
--     and blink.instancetype ~= "pvp"
--     and (enemy.casting or enemy.channel)
--     and not enemy.isPlayer 
--     and not blink.arena then  

--       sr.kickDelay(function()
--         if not enemy.casting or enemy.channeling then return end

--         if spell:Cast(enemy, {face = true}) then 
--           if not saved.streamingMode then
--             alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--           end
--         end
--       end)

--     end

--     if not enemy.isPlayer then return end

--     -- fast MD kick pls
--     if saved.KickFastMD then
--       if enemy.casting 
--       and enemy.castint == false 
--       and enemy.castRemains < blink.buffer + blink.latency + enemy.distance * 0.0155 + 0.09 
--       and (enemy.castID == 341167 
--       or enemy.castID == 32375) then

--         if spell:Cast(enemy, {face = true}) then 
--           if not saved.streamingMode then
--             alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--           end
--         end
--       end
--     end

--     --Kicking Heals from GUI list "ONLY IF HE IS ENEMY HEALER"
--     if enemy.hp <= saved.kickhealsunder 
--     or target.hp <= saved.kickhealsunder
--     and enemy.isHealer then
--       if SettingsCheck(saved.kickHealinglist, enemy.castingid) 
--       or SettingsCheck(saved.kickHealinglist, enemy.channelId) then

--         sr.kickDelay(function()
--           if not enemy.casting or enemy.channeling then return end

--           if spell:Cast(enemy, {face = true}) then 
--             if not saved.streamingMode then
--               alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end)

--       end       
--     end   
    
--     --Kicking Dangerous Casts
--     if SettingsCheck(saved.kickDangerouslist, enemy.castingid) 
--     or SettingsCheck(saved.kickDangerouslist, enemy.channelId) then

--       sr.kickDelay(function()
--         if not enemy.casting or enemy.channeling then return end

--         if spell:Cast(enemy, {face = true}) then 
--           if not saved.streamingMode then
--             alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--           end
--         end
--       end)

--     end 

--     --Kicking CC from GUI List
--     if not saved.TripleDR 
--     and not saved.DontKickAvoidableCC then
--       if SettingsCheck(saved.kickCClist, enemy.castingid) 
--       or SettingsCheck(saved.kickCClist, enemy.channelId) then

--         if sr.NoNeedToKickThis(enemy) then return end

--         sr.kickDelay(function()
--           if not enemy.casting or enemy.channeling then return end

--           if spell:Cast(enemy, {face = true}) then 
--             if not saved.streamingMode then
--               alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end)
--       end
--     end

--     --Kick DPS Under
--     if enemy.hp <= saved.kickdpsunder
--     and not enemy.isHealer then

--       sr.kickDelay(function()
--         if not enemy.casting or enemy.channeling then return end

--         if spell:Cast(enemy, {face = true}) then 
--           if not saved.streamingMode then
--             alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--           end
--         end
--       end)   

--     end   

--     --DONT KICK CC IF HEALER CAN DEATH IT
--     if saved.DontKickAvoidableCC 
--     and enemy.castTarget.isUnit(healer)
--     and healer.incapDR >= 0.5
--     and healer.class2 == "PRIEST"
--     and (healer.cc or healer.cooldown(32379) >= 1) then
--       if SettingsCheck(saved.kickCClist, enemy.castingid) 
--       or SettingsCheck(saved.kickCClist, enemy.channelId)
--       and tContains(DontKickAvoidableCCTable, (enemy.casting or enemy.channeling)) then

--         if sr.NoNeedToKickThis(enemy) then return end

--         sr.kickDelay(function()
--           if not enemy.casting or enemy.channeling then return end
  
--           if spell:Cast(enemy, {face = true}) then 
--             if not saved.streamingMode then
--               alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end) 

--       end 
--     end 

--     --Dont Kick Triple DR
--     if saved.TripleDR then

--       if tContains(listOfHexAndPolys, enemy.casting)
--       and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) 
--       and (healer.incapDR >= 0.5 or player.incapDR >= 0.5) and not saved.DontKickAvoidableCC then
--         if SettingsCheck(saved.kickCClist, enemy.castingid) 
--         or SettingsCheck(saved.kickCClist, enemy.channelId) then

--           if sr.NoNeedToKickThis(enemy) then return end

--           sr.kickDelay(function()
--             if not enemy.casting or enemy.channeling then return end
    
--             if spell:Cast(enemy, {face = true}) then 
--               if not saved.streamingMode then
--                 alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--               end
--             end
--           end) 

--         end
--       elseif enemy.castID == 5782 --Fear
--       and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) 
--       and (healer.disorientDR >= 0.5 or player.disorientDR >= 0.5)  then
--         if SettingsCheck(saved.kickCClist, enemy.castingid) 
--         or SettingsCheck(saved.kickCClist, enemy.channelId) then

--           if sr.NoNeedToKickThis(enemy) then return end

--           sr.kickDelay(function()
--             if not enemy.casting or enemy.channeling then return end
    
--             if spell:Cast(enemy, {face = true}) then 
--               if not saved.streamingMode then
--                 alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--               end
--             end
--           end) 

--         end
--       elseif enemy.castID == 20066 --repentance 
--       and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) 
--       and (healer.incapDR >= 0.5 or player.incapDR >= 0.5)  then
--         if SettingsCheck(saved.kickCClist, enemy.castingid) 
--         or SettingsCheck(saved.kickCClist, enemy.channelId) then

--           if sr.NoNeedToKickThis(enemy) then return end

--           sr.kickDelay(function()
--             if not enemy.casting or enemy.channeling then return end
    
--             if spell:Cast(enemy, {face = true}) then 
--               if not saved.streamingMode then
--                 alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--               end
--             end
--           end) 
--         end
--       elseif enemy.castID == 360806 --Sleepwalk
--       and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) then
--         if SettingsCheck(saved.kickCClist, enemy.castingid) 
--         or SettingsCheck(saved.kickCClist, enemy.channelId) then

--           if sr.NoNeedToKickThis(enemy) then return end

--           sr.kickDelay(function()
--             if not enemy.casting or enemy.channeling then return end
    
--             if spell:Cast(enemy, {face = true}) then 
--               if not saved.streamingMode then
--                 alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--               end
--             end
--           end) 

--         end
--       elseif SettingsCheck(saved.kickCClist, enemy.castingid) or SettingsCheck(saved.kickCClist, enemy.channelId) then

--         if sr.NoNeedToKickThis(enemy) then return end

--         sr.kickDelay(function()
--           if not enemy.casting or enemy.channeling then return end
  
--           if spell:Cast(enemy, {face = true}) then 
--             if not saved.streamingMode then
--               alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end) 
--       end     
--     end    


--     -- HybridsKicks
--     if saved.HybridsKick
--     and enemy.hp <= 80 
--     and enemy.buffsFrom(ImmuneKick) == 0
--     and not enemy.isHealer then
--       if tContains(KickHealing, (enemy.casting)) then
--         sr.kickDelay(function()
--           if not enemy.casting or enemy.channeling then return end

--           if spell:Cast(enemy, {face = true}) then 
--             if not saved.streamingMode then
--               alert("Wind Shear " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end) 
--       end   
--     end
--   end)
-- end)

windShear:Callback("tyrants", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not saved.KickTyrant then return end
  if not blink.arena then return end
  if not blink.fighting(265, 266, 267, true) then return end

  blink.tyrants.loop(function(tyrant)

    -- tyrant must be casting or channeling
    local cast, channel = tyrant.casting, tyrant.channeling
    if not cast and not channel then return end

    -- must not be immune to interrupts
    if cast and tyrant.castint or channel and tyrant.channelint then return end
    if not tyrant.los then return end
    if not tyrant.enemy then return end
    if tyrant.dist > spell.range then return end

    if tyrant.casting or tyrant.channeling 
    and tyrant.castTimeComplete > sr.delay() then 
      if spell:Cast(tyrant, {face = true}) then 
        if not saved.streamingMode then
          alert("Wind Shear " .. "|cFFf7f25c[" .. (tyrant.casting or tyrant.channel) .. "]", spell.id)  
        end
      end
      
    end

  end)

end)

windShear:Callback("seduction", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not blink.arena then return end
  if not blink.fighting(265, 266, 267, true) then return end

  --Seduction
  if blink.fighting(265, 266, 267, true) then 

    blink.enemyPets.loop(function(pet)
      -- pet must be casting or channeling
      local cast, channel = pet.casting, pet.channeling
      if not cast and not channel then return end

      -- must not be immune to interrupts
      if cast and pet.castint or channel and pet.channelint then return end
      if not pet.los then return end
      if pet.dist > spell.range then return end
        
      if SettingsCheck(saved.kickCClist, pet.castingid) 
      or SettingsCheck(saved.kickCClist, pet.channelId) then

        if pet.casting or pet.channeling 
        and pet.castTimeComplete > sr.delay() then
          if spell:Cast(pet, {face = true}) then 
            if not saved.streamingMode then
              alert("Wind Shear " .. "|cFFf7f25c[" .. (pet.casting or pet.channel) .. "]", spell.id)  
            end
          end
        end

      end
    end)
  end
end)


--Astral Shift
astralShift:Callback(function(spell)
  if saved.greedyAstral then return end
  if player.hp > saved.astralSlider then return end

  if player.hp <= saved.astralSlider and not saved.dontDefOvelap then
    if player.combat and not (player.cc or player.buff(199448)) then  --or ultimate sac player.buff(199448) ultimate sac -- normal sac = 6940
      if player.casting or player.channeling then
        blink.call("SpellStopCasting")
        blink.call("SpellStopCasting")
      elseif spell:Cast() then
        blink.alert("Astral Shift", spell.id)
      end	
    end
  elseif player.hp <= saved.astralSlider and saved.dontDefOvelap then
    if player.combat and not (player.cc or player.buff(47788) or player.buff(116849)) then  --dont turtle with Guardian up
      if player.casting or player.channeling then
        blink.call("SpellStopCasting")
        blink.call("SpellStopCasting")
      elseif spell:Cast() then
        blink.alert("Astral Shift", spell.id)
      end	
    end
  end
end)

astralShift:Callback("Greedy", function(spell)
  
  if not blink.hasControl then return end
  if not saved.greedyAstral then return end

  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.hp <= saved.astralSlider) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.astralSlider) * 0.35)
  --threshold = threshold * player.hp <= saved.astralSlider

  if player.hpa > threshold then return end

  if player.buff(199448) 
  or player.buff(47788) 
  or player.buff(116849)
  and saved.dontDefOvelap then 
    return 
  end

  if player.hp > saved.astralSlider then return end
  if not player.combat then return end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  end
  
  if spell:Cast() then
    alert("Astral Shift" ..colors.red .. " [Greedy]", spell.id, true)
  end

end)

bulwarkTotem:Callback(function(spell)
  if not player.hasTalent(spell.id) then return end
  if not blink.hasControl then return end

  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.hp <= saved.bulwarkSlider) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.bulwarkSlider) * 0.35)

  if player.hpa > threshold then return end

  if player.buff(199448) 
  or player.buff(47788) 
  or player.buff(116849)
  and saved.dontDefOvelap then 
    return 
  end

  if player.hp > saved.bulwarkSlider then return end
  if not player.combat then return end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  end
  
  if spell:Cast() then
    alert("Stone Bulwark Totem", spell.id, true)
  end

end)


local function shouldHex(unit)
  if not unit.exists or not unit.enemy then return false end
  if unit.buffFrom({23920, 212295, 8178, 408558}) then return false end
  local hexCompletionTime = hex.castTime + buffer + latency - tickRate - 0.08
  return unit.incapDR >= 0.5 or unit.incapRemains > 5 or unit.incapRemains < hexCompletionTime
end

local function shouldStopCasting(unit)
  return player.castID == hex.id 
  and player.castTarget.isUnit(unit) 
  and (unit.buffFrom({23920, 212295, 8178, 408558}) or unit.used(32379, 0.25))
end

local function attemptHex(spell, unit, macroName)
  if blink.MacrosQueued[macroName] then
    if shouldHex(unit) then
      if spell:Cast(unit) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFHex [" .. unit.classString .. "]", spell.id)
      end
    end
  elseif shouldStopCasting(unit) then
    blink.call("SpellStopCasting")
  end
end

hex:Callback("command", function(spell)
  -- Validate player state and talent
  if player.debuff(410201) or not player.hasTalent(hex.id) then return end

  -- Define targets to hex and their corresponding macro names
  local targets = {
    { unit = target, macroName = "hex target" },
    { unit = focus, macroName = "hex focus" },
    { unit = arena1, macroName = "hex arena1" },
    { unit = arena2, macroName = "hex arena2" },
    { unit = arena3, macroName = "hex arena3" },
    { unit = enemyHealer, macroName = "hex enemyhealer" }
  }

  -- Iterate over targets and attempt to hex
  for _, data in ipairs(targets) do
    attemptHex(spell, data.unit, data.macroName)
  end
end)


-- local function shouldHex(unit)
--   local hexCompletionTime = hex.castTime + buffer + latency - tickRate - 0.08
--   if unit.exists 
--   and unit.enemy
--   and (unit.incapDR >= 0.5 or unit.incapRemains > 5 or unit.incapRemains < hexCompletionTime) then
--     return true
--   end
-- end

-- hex:Callback("command", function(spell)
--   if player.debuff(410201) then return end
--   if not player.hasTalent(hex.id) then return end

--   if blink.MacrosQueued["hex target"] then
--     if shouldHex(target) then
--       if spell:Cast(target) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFHex [" .. target.classString .. "]", spell.id)
--       end
--     end
--   elseif player.castID == hex.id and player.castTarget.isUnit(target) and target.buffFrom({23920, 212295, 8178, 408558}) then
--     blink.call("SpellStopCasting")
--   elseif player.castID == hex.id and player.castTarget.isUnit(target) and target.used(32379, 1.5) then
--     blink.call("SpellStopCasting")
--   end

--   if blink.MacrosQueued["hex focus"] then
--     if shouldHex(focus) then
--       if spell:Cast(focus) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFHex [" .. focus.classString .. "]", spell.id)
--       end
--     end
--   elseif player.castID == hex.id and player.castTarget.isUnit(focus) and focus.buffFrom({23920, 212295, 8178, 408558}) then
--     blink.call("SpellStopCasting")
--   elseif player.castID == hex.id and player.castTarget.isUnit(focus) and focus.used(32379, 1.5) then
--     blink.call("SpellStopCasting")
--   end

--   if blink.MacrosQueued["hex arena1"] then
--     if shouldHex(arena1) then
--       if spell:Cast(arena1) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFHex [" .. arena1.classString .. "]", spell.id)
--       end
--     end
--   elseif player.castID == hex.id and player.castTarget.isUnit(arena1) and arena1.buffFrom({23920, 212295, 8178, 408558}) then
--     blink.call("SpellStopCasting")
--   elseif player.castID == hex.id and player.castTarget.isUnit(arena1) and arena1.used(32379, 1.5) then
--     blink.call("SpellStopCasting")
--   end

--   if blink.MacrosQueued["hex arena2"] then
--     if shouldHex(arena2) then
--       if spell:Cast(arena2) then
--         alert("|cFFf7f25c[Manual]: |cFFFFFFFFHex [" .. arena2.classString .. "]", spell.id)
--       end
--     end
--   elseif player.castID == hex.id and player.castTarget.isUnit(arena2) and arena2.buffFrom({23920, 212295, 8178, 408558}) then
--     blink.call("SpellStopCasting")
--   elseif player.castID == hex.id and player.castTarget.isUnit(arena2) and arena2.used(32379, 1.5) then
--     blink.call("SpellStopCasting")
--   end
    
--   if blink.MacrosQueued["hex arena3"] then
--     if shouldHex(arena3) then
--       if spell:Cast(arena3) then
--           alert("|cFFf7f25c[Manual]: |cFFFFFFFFHex [" .. arena3.classString .. "]", spell.id)
--       end
--     end
--   elseif player.castID == hex.id and player.castTarget.isUnit(arena3) and arena3.buffFrom({23920, 212295, 8178, 408558}) then
--     blink.call("SpellStopCasting")
--   elseif player.castID == hex.id and player.castTarget.isUnit(arena3) and arena3.used(32379, 1.5) then
--     blink.call("SpellStopCasting")
--   end

--   if blink.MacrosQueued["hex enemyhealer"] then
--     if shouldHex(enemyHealer) then
--       if spell:Cast(enemyHealer) then
--           alert("|cFFf7f25c[Manual]: |cFFFFFFFFHex [" .. enemyHealer.classString .. "]", spell.id)
--       end
--     end
--   elseif player.castID == hex.id and player.castTarget.isUnit(enemyHealer) and enemyHealer.buffFrom({23920, 212295, 8178, 408558}) then
--     blink.call("SpellStopCasting")
--   elseif player.castID == hex.id and player.castTarget.isUnit(enemyhealer) and enemyhealer.used(32379, 1.5) then
--     blink.call("SpellStopCasting")
--   end

-- end)


ghostWolf:Callback("command", function(spell)

  if player.used(spell.id, blink.gcd) then return end

  if blink.MacrosQueued["wolf toggle"] then

    if not player.buff(spell.id) then
      if spell:Cast() then
        blink.alert("|cFF22f248 Ghost Wolf Enabled", spell.id)
        blink.MacrosQueued["wolf toggle"] = nil
      end
    elseif player.buff(spell.id) then 
      sr.cancelSpellByName(2645)
      blink.alert("|cFFf74a4a Ghost Wolf Disabled", spell.id)
      blink.MacrosQueued["wolf toggle"] = nil
    end
    
  end

end)



earthGrab:Callback("restealth", function(spell)
  --if not saved.autoRootStealth then return end
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
          alert("Earthgrab Totem " .. tracker.class .. "|cFFf74a4a[" .. C_Spell.GetSpellInfo(tracker.spellID).name .. "|cFFf74a4a]", spell.id)
        end
      end
    end
  end
end)

earthGrab:Callback("stealth", function(spell)
  --if not saved.autoRootStealth then return end
  if blink.prep then return end
  return enemies.stomp(function(enemy, uptime)
    if enemy.buff(58984) then return end
    if enemy.distLiteral > 40 then return end
    if not enemy.isPlayer then return end
    if enemy.buffFrom({185422, 185313}) then return end --121471 blades check if it solve or cause issues
    --if uptime < 2 then
      if enemy.stealth then
        local x,y,z = enemy.predictPosition(0.35)
        if spell:AoECast(x,y,z) then
          if not saved.streamingMode then
            alert("Earthgrab Totem " .. (enemy.class or "") .. "|cFFf74a4a[Stealth]", spell.id)
          end
        end
      end
    --end
  end)
end)

earthGrab:Callback("slowbigdam", function(spell, unit)
  if not player.hasTalent(51485) then return end
  if target.exists and target.hp <= 30 then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not saved.rootCDs then return end
  
  blink.enemies.loop(function(enemy)

    if enemy.distance > 30 then return end
    if not enemy.los then return end
    if not enemy.isPlayer then return end
    if enemy.role ~= "melee" then return end
    if enemy.class2 == "DRUID" then return end
    if enemy.class2 == "WARRIOR" and enemy.buff(227847) then return end

    if enemy.immuneSlow 
    or enemy.buff(227847) 
    or enemy.slowed
    or enemy.rooted
    or enemy.IsInCC then
     return 
    end

    if enemy.buffsFrom(BigDamageBuffs) > 0
    and player.combat
    and not player.target.isUnit(enemy) then
      if spell:SmartAoE(enemy, { 
      ignoreFriends = true, 
      movePredTime = blink.buffer,
      circleSteps = 12,
      ignorePets = true, }) then
        alert("|cFFf7f25cEarthgrab Totem " .. (enemy.classString or "") .. "", spell.id)
      end
    end   
  end) 

end)

earthGrab:Callback("tunnel", function(spell, unit)
  if not player.hasTalent(51485) then return end
  if target.exists and target.hp <= 30 then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not saved.rootTunnel then return end

  blink.enemies.loop(function(enemy)

    if enemy.distance > 30 then return end
    if not enemy.los then return end
    if not enemy.isPlayer then return end
    if enemy.role ~= "melee" then return end
    if enemy.class2 == "DRUID" then return end
    if enemy.class2 == "WARRIOR" and enemy.buff(227847) then return end

    if enemy.immuneSlow 
    or enemy.buff(227847) 
    or enemy.slowed
    or enemy.rooted
    or enemy.IsInCC then
      return 
    end

    if enemy.target.isUnit(player)
    and enemy.cds or player.hp < 85
    and player.combat 
    and not player.target.isUnit(enemy) then
      if spell:SmartAoE(enemy, { 
        ignoreFriends = true, 
        movePredTime = blink.buffer,
        circleSteps = 12,
        ignorePets = true,
       }) then 
        alert("|cFFf7f25cEarthgrab Totem " .. (enemy.classString or "") .. "", spell.id)
      end
    end   
  end) 

end)

earthGrab:Callback("BM Pet", function(spell, unit)
  if not player.hasTalent(51485) then return end
  if target.exists and target.hp <= 30 then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not saved.rootCDs then return end

  blink.pets.loop(function(pet)
    if not pet.enemy then return end
    if pet.distance > spell.range then return end
    if not pet.los then return end

    if pet.immuneSlow 
    or pet.buff(227847) 
    or pet.slowed
    or pet.rooted
    or pet.IsInCC then
      return 
    end

    if pet.buff(186254)
    and pet.buffRemains(186254) > 4
    and player.combat then
      if spell:SmartAoE(pet, { 
        ignoreFriends = true, 
        movePredTime = blink.buffer,
        circleSteps = 12,
        ignorePets = true,
       }) then 
        alert("|cFFf7f25cEarthgrab Totem " ..  colors.pink ..(pet.name or "") .. "", spell.id)
      end
    end   
  end) 

end)


earthGrab:Callback("badpostion", function(spell)
  if not player.hasTalent(spell.id) then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if enemyHealer.class2 == "DRUID" then return end
  if enemyHealer.rootRemains > 1 then return end
  if sr.immuneCC(enemyHealer) then return end

  if target.enemy 
  and enemyHealer.exists 
  and not enemyHealer.isUnit(target)
  and (not enemyHealer.losOf(target) or enemyHealer.distanceTo(target) > 40)
  and not enemyHealer.cc then

    if enemyHealer.bcc then return end

    if spell:SmartAoE(enemyHealer, { 
      ignoreFriends = true, 
      movePredTime = blink.buffer,
      circleSteps = 12,
      ignorePets = true,
     }) then 
      alert("|cFFf7f25cEarthgrab Totem " .. (enemyHealer.classString or "") .. "", spell.id)
    end

  end
end)

earthGrab:Callback("drinking", function(spell)
  if not player.hasTalent(spell.id) then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not enemyHealer.buff("Drink") then return end

  if spell:SmartAoE(enemyHealer, { 
      ignoreFriends = true, 
      movePredTime = blink.buffer,
      circleSteps = 12,
      ignorePets = true, }) then 
    alert("|cFFf7f25cEarthgrab Totem (Drinking)" .. (enemyHealer.classString or "") .. "", spell.id)
  end

end)

capacitor:Callback("rooted", function(spell)
  if not saved.capHealer then return end
  if not player.hasTalent(spell.id) then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not enemyHealer.exists then return end
  if enemyHealer.rootRemains < 2 then return end
  if enemyHealer.stunDR ~= 1 then return end
  if sr.immuneCC(enemyHealer) then return end

  if target.enemy 
  and enemyHealer.rootRemains >= 2 then
    if spell:SmartAoE(enemyHealer, { 
      ignoreFriends = true, 
      movePredTime = blink.buffer,
      circleSteps = 12,
      ignorePets = true,
     }) then 
      alert("|cFFf7f25cCapacitor Totem " .. (enemyHealer.classString or "") .. "", spell.id)
    end
  end
end)

earthGrab:Callback("test", function(spell)
  if not blink.MacrosQueued["cap test"] then return end
  if SpellIsTargeting() then return end
  if not spell:SmartAoE(focus, { distanceSteps = 6,
    circleSteps = 12,
    ignoreFriends = true,
    ignorePets = true,
    movePredTime = blink.buffer }) then return end
  if spell:SmartAoE(focus, { distanceSteps = 6,
    circleSteps = 12,
    ignoreFriends = true,
    ignorePets = true,
    movePredTime = blink.buffer }) then 
    alert("|cFFf7f25cEarth Totem " .. (focus.classString or "") .. "", spell.id)
  end
end)


-- racials
ele.racial = function()
  local racial = racials[player.race]
  if racial and racial() then
    blink.alert(racial.name, racial.id)
  end
end

-- orc
racials.Orc:Callback(function(spell)
  if not player.race == "Orc" then return end

  return spell:Cast()
  -- if player.buffFrom({mm.trueshot.id}) then
  --   return spell:Cast()
  -- end
end)

-- Troll
racials.Troll:Callback(function(spell)
  if not player.race == "Troll" then return end
  
  return spell:Cast()

  -- if player.buffFrom({mm.trueshot.id}) then
  --   return spell:Cast()
  -- end
end)

--Irondwarf
racials.IronDwarf:Callback(function(spell)
  if not player.race == "Dark Iron Dwarf" then return end
  if player.debuffFrom({30108,316099}) and player.hpa <= 75 then return end

  if player.debuffFrom({360194, 323673, 375901, 274838, 274837}) then
    return spell:Cast()
  end

end)


-- TRINKETS

--Badge
Trinkets.Badge:Update(function(item, key)
	if Trinkets.Badge.equipped then
    if item:Use() then
      blink.alert("Badge Trinket", item.spell)
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

local TremorFears = {
  5484,  --Howl
  5246,  --warr fear
  8122,  --scream
  5782,  --Fear
  118699, --Fear2
  360806, --sleepwalk
  207684, --dh sigil fear
  207685, --dh sigil fear
}

tremor:Callback("healer", function(spell)
  if saved.tremorUnit == "none" then return end
  if not healer.exists then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if healer.distanceLiteral > 34 then return end
  if healer.ccRemains < blink.delays.srDelay.now then return end

  if healer.debuffFrom(TremorFears) 
  and healer.ccRemains >= 2 then
    return spell:Cast() and alert("Tremor "..healer.classString, spell.id)
  end
end)

tremor:Callback("friends", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if saved.tremorUnit == "friendlyHealer" 
  or saved.tremorUnit == "none" then
    return 
  end

  blink.group.loop(function(member)
    if not member.exists then return end
    if member.distanceLiteral > 34 then return end
    if member.ccRemains < blink.delays.srDelay.now then return end

    if member.debuffFrom(TremorFears)
    and member.ccRemains >= 2 then
      return spell:Cast() and alert("Tremor "..colors.cyan..member.classString, spell.id)
    end
  end)

end)


local preFear = {
  -- fear
  [5782] = function(source)
    return source.castTarget.isUnit(player) and player.ddr >= 0.5
  end,
}

tremor:Callback("pre", function(spell)
  if not saved.preTremor then return end
  blink.enemies.loop(function(enemy)
    local cast = enemy.castID
    if not cast then return end
    if not enemy.castTarget.isUnit(player) then return end
    if not preFear[cast] or not preFear[cast](enemy) then return end
    if player.buffFrom({8178, 377362, 213610}) or player.immuneCC then return end
    if windShear:Castable(enemy) and saved.kickCClist["Fear"] then return end --and Fear is in kicklist

    if (enemy.castRemains < (math.random(50,80)/100) + blink.buffer) then  
      return spell:Cast() and alert("Pre-Tremor Incoming (" .. colored("Fear", colors.warlock) .. ")", spell.id)
    end

  end)
end)


-- Purgez
-- purge:Callback(function(spell, unit)
--   if spell.cd - blink.gcdRemains > 0 then return end

--   blink.enemies.loop(function(enemy)
--     if not enemy.isPlayer then return end
--     if not enemy.los then return end
--     if enemy.dist > 42 then return end
--     if enemy.buffFrom({45438, 642, 362486, 186265}) then return end

--     -- Purges
--     if enemy.buffFrom(PurgeMePls) 
--     and enemy.los
--     and spell:Cast(enemy, { face = true }) then
--       return alert("Purge (" .. enemy.classString .. ")", spell.id)
--     end

--   end)

-- end)
-- purgez
-- Priority list of buff IDs
local PurgePrio = {
  167385, -- test
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
  for _, prioBuffId in ipairs(PurgePrio) do
    if enemy.buff(prioBuffId) then
      local inGuiList = SettingsCheck(saved.purgeList, prioBuffId)
      if inGuiList then
        return true, prioBuffId
      end
    end
  end
  return false, nil
end

purge:Callback(function(spell, unit)
  if not saved.autoPurge then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if player.stealthed then return end

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
      sr.debugPrint("Casting Purge on:", enemy.name, "For Priority Buff ID:", prioBuffId)
      return spell:Cast(enemy, {face = true}) and alert("Purge (" .. enemy.classString .. ")", spell.id)
    end

    for i = 1, #enemy.buffs do
      local buffDetails = enemy['buff'..i]
      if buffDetails then
        local _, _, _, _, _, _, _, _, _, buffId = unpack(buffDetails)
        if SettingsCheck(saved.purgeList, buffId) then
          table.insert(prioritizedEnemies, {enemy = enemy, buffId = buffId})
        end
      end
    end
  end)

  -- If prioritized enemies found, cast on the first one
  if #prioritizedEnemies > 0 then
    local priorityTarget = prioritizedEnemies[1]
    sr.debugPrint("Casting Purge on:", priorityTarget.enemy.name, "For Buff ID:", priorityTarget.buffId)
    return spell:Cast(priorityTarget.enemy, {face = true}) and alert("Purge (" .. priorityTarget.enemy.classString .. ")", spell.id)
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
        if SettingsCheck(saved.purgeList, buffId) then 
          sr.debugPrint("Casting Purge on:", enemy.name, "For Buff ID:", buffId)
          return spell:Cast(enemy, {face = true}) and alert("Purge (" .. enemy.classString .. ")", spell.id)
        end
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

-- purge:Callback(function(spell, unit)
--   if not saved.autoPurge then return end
--   if spell.cd - blink.gcdRemains > 0 then return end
--   if player.stealthed then return end

--   blink.enemies.loop(function(enemy)

--     if not enemy.isPlayer then return end
--     if not enemy.los then return end
--     if enemy.dist > spell.range then return end
--     if enemy.buffFrom({45438, 642, 362486, 186265, 196555, 409293}) then return end

--     for i = 1, #enemy.buffs do
--       local buffDetails = enemy['buff'..i]
--       if buffDetails then
--         local _, _, _, _, _, _, _, _, _, buffId = unpack(buffDetails)
--         if SettingsCheck(saved.purgeList, buffId) then 
--           sr.debugPrint("Casting Purge on:", enemy.name, "For Buff ID:", buffId)
--           return spell:Cast(enemy, {face = true}) and alert("Purge (" .. enemy.classString .. ")", spell.id)
--         end
--       end
--     end

--   end)
-- end)

purge:Callback("lowPrio", function(spell, unit)
  if not saved.autoPurge then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.enemies.loop(function(enemy)
    if not enemy.isPlayer then return end
    if not enemy.los then return end
    if enemy.dist > 42 then return end
    if enemy.buffFrom({45438, 642, 362486, 186265, 409293}) then return end

    -- Purges
    if enemy.buffFrom(LowPrioPurgeMePls) 
    and enemy.los
    and spell:Cast(enemy, { face = true }) then
      return alert("Purge (" .. enemy.classString .. ")", spell.id)
    end

  end)
end)

purge:Callback("MC", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

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


fireElemental:Callback("burst", function(spell)
  if not target.debuff(flameShockDebuff) then return end
  if not target.exists then return end
  local EarthPetUp = blink.units.find(function(unit) return unit.id == 61056 and unit.creator.player end)
  if EarthPetUp and player.hp < 80 then return end
  
  if not target.los then return end
  if target.dist > 40 then return end  

  return spell:Cast()

end)

earthElemental:Callback("emergency", function(spell)

  local PrimalPetUp = blink.units.find(function(unit) return unit.id == 61029 and unit.creator.player end)
  if PrimalPetUp then return end

  if spell.cd - blink.gcdRemains > 0 then return end

  blink.fullGroup.sort(function(x,y) return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp end)

  blink.fullGroup.loop(function(member)    

    local count, _, _, cds = member.v2attackers()

    local threshold = 17
    threshold = threshold + bin(member.hp) * 12
    threshold = threshold + count * 5
    threshold = threshold + cds * 9

    threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(member.hp) * 0.35)

    if member.hp > threshold then return end
    if not member.combat then return end
    if member.distanceLiteral > 40 then return end
    
    return spell:Cast()
    
  end)

end)

local stunMePls = {
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
  --Metamorphosis
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

pulverize:Callback("test", function(spell)
  local EarthPetUp = blink.units.find(function(unit) return unit.id == 61056 and unit.creator.player end)
  if not EarthPetUp then return end

  if not EarthPetUp.meleeRangeOf(focus) 
  and blink.hasControl then
    shaman.movePetToUnit(focus)
  end

  --return RunMacroText("/cast " .."[@"..focus.guid.."] Pulverize") and blink.alert("Pulverize", spell.id)
  return pulverize:Cast(focus) and blink.alert("Pulverize", spell.id)

end)

pulverize:Callback("big dam", function(spell)

  local EarthPetUp = blink.units.find(function(unit) return unit.id == 61056 and unit.creator.player end)
  if not EarthPetUp then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not player.losOf(enemy) then return end
    if enemy.immuneMagicDamage then return end
    if enemy.ccr and enemy.ccr > 1 then return end
    -- not into bladestorm
    if enemy.class2 == "WARRIOR" and enemy.buffFrom({46924, 227847, 23920}) then return end
    if not enemy.isPlayer then return end  
    if enemy.immuneCC then return end
    if enemy.stunDR < 0.5 then return end

    local lowest = sr.lowest(blink.fgroup)

    local has = enemy.buffFrom(stunMePls)

    if not has then return end
    local str = ""
    for i, id in ipairs(has) do
      if i == #has then
        str = str .. C_Spell.GetSpellInfo(id).name
      else
        str = str .. C_Spell.GetSpellInfo(id).name .. ","
      end
    end

    if not EarthPetUp.meleeRangeOf(focus) 
    and blink.hasControl then
      shaman.movePetToUnit(focus)
    end

    --Damage buffs up
    if has then
      return spell:Cast(enemy) and blink.alert("Pulverize (" .. colors.red .. (str) .. "|r)", spell.id)
    end

    --just need peels
    if enemy.isPlayer 
    and not enemy.immuneMagicDamage 
    and not enemy.isHealer then
      if lowest < 70 + bin(enemy.buffFrom(stunMePls)) * 57 + bin(not healer.exists or not healer.los or healer.cc) * 30 then
        return spell:Cast(enemy) and blink.alert("Pulverize " .. colors.orange.. "(Peeling)", spell.id)
      end
    end
    
  end)

end)


-- skyFury:Callback("burst", function(spell)
--   if not target.debuff(flameShockDebuff) then return end
--   if not target.exists then return end
--   if target.hp > 90 then return end
--   --if not player.hasTalent(spell.id) then return end
--   if not target.los then return end
--   if target.dist > 40 then return end  

--   return spell:Cast()

-- end)

skyFury:Callback("buff", function(spell)
  if player.buff(spell.id) or player.buff(462854) then return false end
  return spell:Cast(player)
end)


meteor:Callback("burst", function(spell)
  if not target.exists then return end
  if not target.los then return end
  if target.dist > 40 then return end 
  if blink.enemies.around(target, 10, function(o) return o.debuffFrom(realBCC) and not o.isPet end) > 0 then
    return
  end


  local PrimalPetUp = blink.units.find(function(unit) return unit.id == 61029 and unit.creator.player end)
  if not PrimalPetUp then return end

  return spell:Cast(target)

end)



healingSurge:Callback("emergency", function(spell)
  if sr.burstMode then return end
  if player.moving and not player.buff(79206) then return end
  if not saved.autoSurge then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.fullGroup.sort(function(x,y) return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp end)

  blink.fullGroup.loop(function(member)    

    local count, _, _, cds = member.v2attackers()

    local threshold = 17
    threshold = threshold + bin(member.hp <= saved.surgeSlider) * 12
    threshold = threshold + count * 5
    threshold = threshold + cds * 9

    threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(member.hp <= saved.surgeSlider) * 0.35)

    if member.hpa > threshold then return end
    if member.hp > saved.surgeSlider then return end
    if not member.combat then return end
    if member.dist > 40 then return end
    if not member.los then return end

    local FilterBGs = blink.fgroup.around(player, 40, function(obj) return not obj.dead end) > 2

    if blink.instanceType2 == "pvp" 
    and FilterBGs then
      if player.hp < saved.surgeSlider
      or player.hpa < threshold then 
        spell:Cast(player)
      end
    else
      return spell:Cast(member)
    end
    
  end)

end)

healingStream:Callback("emergency", function(spell)
  if cancelHealing then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.fullGroup.sort(function(x,y) return x.hp and y.hp and x.hp < y.hp end)

  blink.fullGroup.loop(function(member)    

    local threshold = 17 + bin(member.hp < 90) * 12 + (member.v2attackers() * 5) + (member.v2attackers() * 9)
    threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(member.hp < 90) * 0.35)

    if member.hp > threshold then return end
    if not member.combat then return end
    if member.distanceLiteral > 46 then return end
    
    return spell:Cast()
    
  end)

end)

ancestralGuidance:Callback("emergency", function(spell)
  if not saved.autoGuidance then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.fullGroup.sort(function(x,y) return x.hp and y.hp and x.hp < y.hp end)

  blink.fullGroup.loop(function(member)    

    local threshold = 17 + bin(member.hp < 80) * 12 + (member.v2attackers() * 5) + (member.v2attackers() * 9)
    threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(member.hp < 80) * 0.35)

    if member.hp > threshold then return end
    if not member.combat then return end
    
    return spell:Cast()
    
  end)

end)

thunderStorm:Callback("stunned", function(spell)
  if not saved.autoThunderstorm then return end
  local bcc = blink.enemies.within(10).find(function(o)
    return o.distanceTo(player) < 10 and o.debuffFrom(realBCC) and not o.isPet
  end)

  if bcc then return end

  local hitEm = blink.enemies.within(5).find(function(o)
    return o.distanceTo(player) <= 4 and o.isPlayer
  end)

  if hitEm and player.stunned then
    sr.actionDelay(function()
      return spell:Cast()
    end)
  end
end)

function sr.shouldCastThunderstorm()
  if not saved.autoThunderstorm then return end
  local currentTime = blink.time

  for _, defensiveDetails in pairs(sr.DefensiveAreaTriggers) do
    if defensiveDetails.remains > 1 then
      local x, y, z = defensiveDetails.position()

      sr.debugPrint("Player distance to trigger: " .. player.distanceToLiteral(x, y, z))
      sr.debugPrint("Trigger: ID: " .. tostring(defensiveDetails.id) .. ", Name: " .. defensiveDetails.name .. ", Radius: " .. tostring(defensiveDetails.radius) .. ", Remains: " .. tostring(defensiveDetails.remains))
      sr.debugPrint("Position: X: " .. tostring(x) .. ", Y: " .. tostring(y) .. ", Z: " .. tostring(z))

      local playerInTrigger = player.distanceToLiteral(x, y, z) <= defensiveDetails.radius + 1

      local enemiesInDefensive = blink.enemies.within(defensiveDetails.radius).filter(function(enemy)
        return enemy.isPlayer and player.distanceToLiteral(enemy) <= 8 and not enemy.isPet and not enemy.immuneMagicEffect and playerInTrigger
      end)

      if #enemiesInDefensive > 0 then
        return true, defensiveDetails.name
      end
    end
  end

  return false, nil
end

thunderStorm:Callback("defensives", function(spell)
  local shouldCast, defensiveName = sr.shouldCastThunderstorm()
  if not shouldCast then return end
  
  sr.actionDelay(function()
    if spell:Cast() then
      blink.alert("Thunder Storm " .. colors.orange .. "(" .. (defensiveName or "Defensive") .. ")", spell.id)
    end
  end)
end)

hex:Callback("auto",function(spell)
  
  local tar = saved.hexTarget
  if tar == "none" then return end

  local unit = blink[tar]

  if player.moving and not player.buff(79206) then return end
  if player.debuff(410201) then return end
  if not unit.player then return end
  if not unit.enemy then return end
  if not unit.los then return end
  if unit.incapDR ~= 1 then return end
  if unit.ccr > spell.castTime + 0.5 then return end
  if unit.isUnit(target) then return end

  if (tar == "target" 
  or tar == "focus" 
  or tar == "enemyHealer")
  and unit.buffFrom(immuneToHex) then
    return
  end

  local should = saved.hexOffDR

  if not should then
    local cross, pressure = false, false
    
    if enemyHealer.exists and not unit.isUnit(enemyHealer) then
      cross = enemyHealer.cc and enemyHealer.ccr > 1
    else
      blink.enemies.loop(function(enemy)
        if enemy.isUnit(unit) then return end
        if enemy.cc and enemy.ccr > 1 then cross = true return true end
      end)
    end

    if target.hpa < 72 + bin(player.cds) * 15 + bin(cross) * 14 then
      pressure = true
    end

    should = saved.hexBigPressure and pressure
      or saved.hexCrossCC and cross
  end

  --check for sacs
  local sac_up, sac_rem = false, 0

  blink.enemies.within(30).loop(function(enemy)
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
  end)

  if player.castID == hex.id 
  and player.castTarget.isUnit(unit) 
  and unit.used(32379, 0.15)
  or unit.used(408558, 0.15)
  or unit.used(6940, 0.15)
  or unit.used(199448, 0.15) then
    blink.call("SpellStopCasting")
  end

  if sac_rem < spell.castTime then
    return should and spell:Cast(unit) and alert("Hex " .. unit.classString, spell.id)
  end

  --return should and spell:Cast(unit) and alert("Hex " .. unit.classString, spell.id)

end)


cleanse:Callback(function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(spell.id) then return end

  blink.group.loop(function(member)
    local has = member.debuffFrom(cleanseThem)
    if not has then return end
    if member.ccRemains < blink.delays.srDelay.now then return end
    if member.dist > 40 then return end
    if not member.los then return end

    local str = ""
    for i, id in ipairs(has) do
      if i == #has then
        str = str .. C_Spell.GetSpellInfo(id).name
      else
        str = str .. C_Spell.GetSpellInfo(id).name .. ","
      end
    end  

    return spell:Cast(member) and alert("Cleanse "..colors.yellow..str, spell.id)

  end)

end)

counterStrike:Callback(function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(spell.id) then return end

  blink.enemies.loop(function(enemy)

    if enemy.buffsFrom(BigDamageBuffs) > 0 
    or player.hp < 70
    and player.combat 
    and enemy.dist < 22 then
      return spell:CastAlert()
    end

  end)

end)


local poisionsClean = {
  360194,
  274838,
}
poisionTotem:Callback("auto", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(spell.id) then return end
  local poisioned = blink.fgroup.within(34).find(function(member) return member.debuffFrom(poisionsClean) end)
  if not poisioned then return end

  return spell:CastAlert()
end)

totemRecall:Callback("auto", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(spell.id) then return end
  if grounding.cd - blink.gcdRemains == 0 then return end

  return spell:Cast()
end)

-- earthShield:Callback("zg", function(spell)
--   if not target.enemy then
--     return spell:Cast() and alert("EarthShield "..player.classString, spell.id)
--   end
-- end)

-- function shaman.getFurthestPoint(range)
--   local playerPos = { x = player.x, y = player.y, z = player.z }
--   local furthestPoint = nil
--   local maxDistance = 0

--   -- Iterate through a circle around the player to find the furthest point
--   for angle = 0, 360, 1 do
--     local radian = math.rad(angle)
--     local testPoint = {
--       x = playerPos.x + range * math.cos(radian),
--       y = playerPos.y + range * math.sin(radian),
--       z = playerPos.z
--     }

--     -- Adjust Z-coordinate to ground level
--     testPoint.z = blink.GroundZ(testPoint.x, testPoint.y, testPoint.z) or testPoint.z

--     -- Check if the point is in line of sight
--     --if player.lineOfSight(testPoint.x, testPoint.y, testPoint.z) then
--       local distance = blink.Distance(testPoint.x, testPoint.y, testPoint.z, playerPos.x, playerPos.y, playerPos.z)
--       if distance > maxDistance then
--         maxDistance = distance
--         furthestPoint = testPoint
--       end
--     --end
--   end

--   return furthestPoint
-- end


-- function shaman.staticFieldTotem()

--   if not saved.autoStaticField then return end
--   local staticTotemUp = blink.units.find(function(unit) return unit.id == 179867 and unit.creator.player end)

--   if not player.hasTalent(staticFieldTotem.id) 
--   or not player.hasTalent(totemicProjection.id)
--   or not blink.arena then 
--     return 
--   end

--   local function CastStaticFieldTotemAndProject(unit)
--     if staticFieldTotem:SmartAoE(unit, {ignoreFriends = true, movePredTime = blink.buffer}) then
--       if staticTotemUp then
--         local furthestPoint = shaman.getFurthestPoint(30)
--         sr.debugPrint("Projecting to : " .. furthestPoint.x, furthestPoint.y, furthestPoint.z)
--         if furthestPoint then
--           totemicProjection:SmartAoE({furthestPoint.x, furthestPoint.y, furthestPoint.z}, {ignoreFriends = true})
--         end
--       end
--     end
--   end

--   local threshold = 17 + bin(player.hp < 85) * 12 + (player.v2attackers() * 5) + (player.v2attackers() * 9)
--   threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp < 85) * 0.35)

--   if player.hpa > threshold then return end

--   blink.enemies.within(10).loop(function(enemy)
--     if enemy.isMelee and enemy.isPlayer and enemy.los and player.hpa < threshold then
--       CastStaticFieldTotemAndProject(enemy)
--     end
--   end)
-- end






