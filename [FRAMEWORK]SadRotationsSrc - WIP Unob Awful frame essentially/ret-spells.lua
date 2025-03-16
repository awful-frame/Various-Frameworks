local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local state = sr.arenaState
local buffer, latency, gcd = blink.buffer, blink.latency, blink.gcd
local saved = sr.saved
local paladin, ret = sr.paladin, sr.paladin.ret
local alert = blink.alert
local colors = blink.colors
local enemy = blink.enemy
local player = blink.player
local bin = blink.bin
local delay = blink.delay(0.5, 0.6)
local stompDelay = blink.delay(0.5, 0.6)


local currentSpec = GetSpecialization()

if not paladin.ready then return end

if currentSpec ~= 3 then return end
  

blink.Populate({

  target = blink.target,
  focus = blink.focus,
  player = blink.player,
  healer = blink.healer,
  fhealer = blink.healer,
  pet = blink.pet,
  enemyHealer = blink.enemyHealer,
  arena1 = blink.arena1,
  arena2 = blink.arena2,
  arena3 = blink.arena3,
  enemyPets = blink.enemyPets,

  --damage
  judge = NS(20271, { damage = "physical", ranged = true }), 
  justicar = NS(215661, { damage = "physical" }),
  BOJ = NS(184575, { damage = "physical", ranged = true }),
  storm = NS(53385, { damage = "magic", ignoreFacing = true }),
  crusader = NS(6603, { damage = "magic" }), -- not here anymore
  finalreck = NS(343721, { effect = "magic", ranged = true, diameter = 16, ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),
  FV = NS(383328, { ranged = true, damage = "physical" }),
  hammerofwrath = NS(24275, { damage = "physical", ranged = true }),
  excutesent = NS(343527, { damage = "magic", ranged = true }),
  exo = NS(383185, { damage = "magic", ranged = true }),


  --offensives
  wings = NS({231895, 31884, 462048}, { ignoreGCD = true }),
  divintoll = NS(375576, { damage = "magic", ranged = true }),
  wakeofashes = NS(255937, { damage = "magic", ranged = true }),
  HOL = NS(427453, { damage = "magic", ranged = true, ignoreUsable = true, beneficial = true }),
  radiantdecree = NS(384052, { damage = "magic", ranged = true }),
  seraphim = NS(152262), -- not here anymore

  --defensives
  bubble = NS(642, { ignoreGCD = true, ignoreCC = true, ignoreStuns = true, ignoreCasting = true, ignoreChanneling = true }),
  SOV = paladin.SOV,
  divineprotection = NS(403876, { ignoreGCD = true, ignoreStuns = true }),
  layonhand = NS(471195, { heal = true, ranged = true, ignoreGCD = true, ignoreFacing = true, ignoreCasting = true, ignoreChanneling = true }),
  
  --healing
  WOG = NS(85673, { heal = true, ranged = true, ignoreFacing = true }),
  BOP = NS(1022, { ignoreGCD = true, ignoreCC = true, ignoreStuns = true, ignoreCasting = true, ignoreChanneling = true }),
  flashheal = NS(19750, { ranged = true, heal = true, ignoreFacing = true , ignoreMoving = true, }),

  --cc
  HOJ = NS(853, { cc = true, stun = true, ignoreMoving = true, ignoreFacing = true }),
  blind = NS(115750, { cc = true, ignoreMoving = true, ignoreFacing = true }),
  
  --mics
  BOS = paladin.BOS,
  torrent = NS(155145),
  warding = NS(204018, { heal = true, beneficial = true, ignoreFacing = true }),
  sanc = NS(210256, { heal = true, beneficial = true, ignoreFacing = true }),
  freedom = NS(1044, { heal = true, beneficial = true, ignoreFacing = true }),
  rebuke = NS(96231, { ranged = true, effect = "physical", ignoreGCD = true }),
  divinesteed = NS(190784, { beneficial = true, ignoreFacing = true, ignoreMoving = true, ranged = true, ignoreGCD = true }),
  HOH = NS(183218, { effect = "magic", slow = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),

  --Auras 
  DevoAura = NS(465),
  ConsAura = NS(317920),
  CrusaderAura = NS(32223),
  RetAura = NS(183435),


  --Trinkets Table
  Trinkets = {
    Badge = blink.Item({216368, 216279, 209343, 209763, 205708, 205778, 201807, 201449, 218421, 218713}),
    Emblem = blink.Item({216371, 216281, 209345, 209766, 201809, 201452, 205781, 205710, 218424, 218715}),
  },

  -- items
  tierPieces = NewItem({188907, 188901, 188905, 188902, 188903}),


}, ret, getfenv(1))

local function bcc(obj) return obj.bcc end

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
  51514, --"Hex",
  20066, --"Repentance",
  5782, --"Fear",
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
--Immune To Paldin CC Stuff Table
local ImmuneToPaldinCC = {

	213610, --Holy Ward
	236321, --War Banner
	23920, -- reflect
  8178, --grounding
	353319, --restoral 
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  204018, --Spell Warding
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  377360, --Precognition
  203337, --Daimond ice
  212295, --netherward
  408558, --priest phase shift
  377362, --precognition
  421453, --Ultimate Penitence
  354610, --dh Glimpse

}

--Immune To Paldin CC Stuff Table
local ImmuneToPaldinBlind = {

	213610, --Holy Ward
	236321, --War Banner
	23920, -- reflect
	353319, --restoral
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  204018, --Spell Warding
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  377360, --Precognition
  203337, --Daimond ice
  408558, --priest phase shift
  377362, --precognition
  421453, --Ultimate Penitence
  354610, --dh Glimpse

}

local PurgeMePls = {

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
  342242, --Mage Timewrap
  213610, --Holy Word

}

----------------------------------------------------------------------------------------------------------------
--                                     End of Tables                                                          --
----------------------------------------------------------------------------------------------------------------


------------------------------------STOPING START-------------------------------------------
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
    [59764] = function(totem, uptime) return uptime < 8 end,  --Healing Tide
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

-- kc stomp
crusader:Callback("stomp", function(spell)
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if player.distanceTo(totem) < 6 and player.losOf(totem) then
      if spell:Cast(totem, { face = true }) then
          return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
      end
    end
  end)

end)


judge:Callback("stomp", function(spell)
  if player.buff(397191) then return end
  if spell.cd > 0.8 then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if player.distanceTo(totem) > 30 then return end
    if not totem.los then return end
    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)

BOJ:Callback("stomp", function(spell)
  if player.buff(397191) then return end
  if spell.cd > 0.8 then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if player.distanceTo(totem) > 20 then return end
    if not totem.los then return end
    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)
------------------------------------STOPING END-------------------------------------------


DevoAura:Callback(function(spell)
  if DevoAura.used(3) 
  or ConsAura.used(3) 
  or CrusaderAura.used(3) 
  or RetAura.used(3) then 
    return 
  end

  if player.buff(DevoAura.id) 
  or player.buff(ConsAura.id) 
  or player.buff(CrusaderAura.id) 
  or player.buff(RetAura.id) then
    return 
  end

  return spell:Cast()

end)

RetAura:Callback(function(spell)
  if DevoAura.used(3) 
  or ConsAura.used(3) 
  or CrusaderAura.used(3) 
  or RetAura.used(3) then 
    return 
  end

  if player.buff(DevoAura.id) 
  or player.buff(ConsAura.id) 
  or player.buff(CrusaderAura.id) 
  or player.buff(RetAura.id) then
    return 
  end

  return spell:Cast()

end)

judge:Callback(function(spell)
  if not target.exists then return end
  --if player.Holypower == 5 then return end
  --if player.buff(397191) and not blink.burst then return end
  if target.enemy then
    return spell:Cast(target, {face = true})
  end
end)

judge:Callback("maintain",function(spell)
  if not target.exists then return end
  if target.debuffRemains(197277, player) > 2 then return end
  if target.enemy then
    return spell:Cast(target, {face = true})
  end
end)

exo:Callback(function(spell)
  if not target.exists then return end
  if target.enemy then
    return spell:Cast(target, {face = true})
  end
end)

-- judge:Callback("dispel", function(spell)

--     if spell.cd > 1 then return end
--     if not player.hasTalent(383328) then return end

--     blink.group.loop(function(member)    

--         local Mageo = blink.enemies.find(function(obj) return obj.class2 == "MAGE" end)
--         local Paladino = blink.enemies.find(function(obj) return obj.class2 == "PALADIN" end)
--         local Warlockino = blink.enemies.find(function(obj) return obj.class2 == "WARLOCK" end)
--         local Hunterino = blink.enemies.find(function(obj) return obj.class2 == "HUNTER" end)
--         local Priestino = blink.enemies.find(function(obj) return obj.class2 == "PRIEST" end)

--         --Sheep    
--         if Mageo 
--         and Mageo.enemy
--         and Mageo.dist < 30 
--         and healer.debuff(118) 
--         and not Mageo.bcc or Mageo.immuneMagicDamage then
--             return spell:Cast(Mageo, { face = true })
--         end
--         --HOJ
--         if Paladino 
--         and Paladino.enemy
--         and Paladino.dist < 30 
--         and healer.debuff(135963)
--         and not Paladino.bcc or Paladino.immuneMagicDamage then
--             return spell:Cast(Paladino, { face = true })
--         end

--         --Fear
--         if Warlockino 
--         and Warlockino.enemy
--         and Warlockino.dist < 30 
--         and healer.debuff(118699) 
--         and not Warlockino.bcc or Warlockino.immuneMagicDamage then
--             return spell:Cast(Warlockino, { face = true })
--         end

--         --trap
--         if Hunterino 
--         and Hunterino.enemy
--         and Hunterino.dist < 30 
--         and healer.debuff(3355) 
--         and not Hunterino.bcc or Hunterino.immuneMagicDamage then
--             return spell:Cast(Hunterino, { face = true })
--         end

--         --Scream
--         if Priestino 
--         and Priestino.enemy
--         and Priestino.dist < 30 
--         and healer.debuff(8122) 
--         and not Priestino.bcc or Priestino.immuneMagicDamage then
--             return spell:Cast(Priestino, { face = true })
--         end

--     end)

-- end)


hammerofwrath:Callback(function(spell)
  --if player.Holypower == 5 and target.meleeRange then return end
  if target.enemy then
    return spell:Cast(target, {face = true})
  end
end)

justicar:Callback(function(spell)

  -- if player.buffRemains(385127) > 5 then
  --   if target.enemy 
  --   and player.Holypower >= 3 or target.enemy and player.buff(408458) then
  --     return spell:Cast(target, {face = true})
  --   end
  -- else
  --   if player.buffRemains(385127) <= 4 and target.enemy 
  --   and player.Holypower == 5 or target.enemy and player.buff(408458) then
  --     return spell:Cast(target, {face = true})
  --   end
  -- end
  --if player.Holypower < 4 then return end
  if not spell:Castable(target) then return end
  return spell:Cast(target, {face = true})

end)


local isHOLCastable = function()
  local overrideSpellID = C_Spell.GetOverrideSpell(255937)
  if overrideSpellID and overrideSpellID == 427453 then
    --sr.debugPrint("Yes, Hammer of Light is available.")
    return true
  end
  return false
end 

paladin.HOL = function()
  if not isHOLCastable() then return false end
  if blink.enemies.around(target, 5, function(o) 
    return o.bcc and not o.isPet end) > 0 then 
    return 
  end

  if target.dead
  or not target.exists
  or not target.enemy 
  or not player.facing(target) 
  or target.dist > 15
  or target.immuneMagicDamage then
    return 
  end

  return sr.CastSpellByID(255937) and blink.alert("Hammer of Light", 427453)
  
end


FV:Callback(function(spell)
  if not target.exists then return end

  if player.buff(387178) 
  and blink.enemies.around(player, 9, function(o) return o.bcc and not o.isPet end) > 0 then 
    --lets clear it and keep going ?
    sr.cancelSpellByName(387178)
    blink.alert("|cFFfa8ea8Cancel Empyrean Legacy", spell.id)
  end

  if player.hasTalent(justicar.id) then return end
  if isHOLCastable() then return end
  if not spell:Castable(target) then return end

  if target.exists 
  and target.enemy then
    return spell:Cast(target, {face = true})
  end

  -- and player.Holypower >= 3
  -- or player.buff(408458) then
  --   return spell:Cast(target, {face = true})
  -- end
  


  -- if player.hasTalent(385129) then   
  --   if player.buffRemains(385127) > 5 then
  --     if target.enemy 
  --     and player.Holypower >= 3 or target.enemy and player.buff(408458) then
  --       return spell:Cast(target, {face = true})
  --     end
  --   else
  --     if player.buffRemains(385127) <= 4 and target.enemy 
  --     and player.Holypower == 5 or target.enemy and player.buff(408458) then --408458
  --       return spell:Cast(target, {face = true})
  --     end
  --   end
  -- else
  --   if target.enemy 
  --   and player.Holypower >= 4
  --   or player.buff(408458) then
  --     return spell:Cast(target, {face = true})
  --   end
  -- end

end)

BOJ:Callback(function(spell)
  if not target.exists then return end
  --if player.Holypower > 3 and not player.buff(281178) then return end

  if player.Holypower > 3 
  and (player.hasTalent(FV.id) and FV.cd == 0)
  or (player.hasTalent(justicar.id) and justicar.cd == 0) then 
    return 
  end

  if target.enemy then
    return spell:Cast(target, {face = true})
  end
end)


storm:Callback(function(spell)
  if not target.exists then return end
  if blink.enemies.around(player, 7, function(o) return o.bcc and not o.isPet end) > 0 then return end
  if target.dist > 6 then return end

  if target.enemy 
  and player.buff(326733) then
    return spell:Cast()
  end

end)

crusader:Callback(function(spell)
  if not target.exists then return end
  --if player.Holypower == 5 then return end
  if target.enemy then
    return spell:Cast(target, {face = true})
  end
end)

WOG:Callback("emergency", function(spell)
  if flashheal.cd - blink.gcdRemains == 0 then return end
  if not saved.AutoWOG then return end
  if player.Holypower < 3 then return end

  local function checkThreshold(unit)
    local count, _, _, cds = unit.v2attackers()
    local threshold = 17
    threshold = threshold + bin(unit.hp <= saved.WOGSensitivity) * 12
    threshold = threshold + count * 5
    threshold = threshold + cds * 9
    return threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(unit.hp <= saved.WOGSensitivity) * 0.35)
  end

  local selfish = saved.selfishHeal and blink.instanceType2 == "pvp" -- Just heal player, not members

  if selfish then
    local playerThreshold = checkThreshold(player)
    if player.hp < saved.WOGSensitivity or player.hp < playerThreshold then 
      spell:Cast(player)
    end
    return
  end

  blink.fullGroup.sort(function(x, y)
    return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 
      or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp
  end)

  blink.fullGroup.loop(function(member)
    local memberThreshold = checkThreshold(member)
    if member.hp > memberThreshold then return end
    if member.hp > saved.WOGSensitivity then return end
    if not member.combat then return end

    if spell:Cast(member) then
      alert("WOG " .. "[" .. member.classString .. "]" .. colors.red .. " [Danger]", spell.id, true)
    end
  end)
end)

flashheal:Callback("emergency", function(spell)
  if not saved.AutoFlash then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local function checkThreshold(unit)
    local count, _, _, cds = unit.v2attackers()
    local threshold = 17
    threshold = threshold + bin(unit.hp <= saved.FlashSensitivity) * 12
    threshold = threshold + count * 5
    threshold = threshold + cds * 9
    return threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(unit.hp <= saved.FlashSensitivity) * 0.35)
  end

  local selfish = saved.selfishHeal and blink.instanceType2 == "pvp" -- Just heal player, not members

  if selfish then
    local playerThreshold = checkThreshold(player)
    if player.hp < saved.FlashSensitivity or player.hp < playerThreshold then 
      spell:Cast(player)
    end
    return
  end

  blink.fullGroup.sort(function(x, y)
    return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 
    or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp
  end)

  blink.fullGroup.loop(function(member)
    local memberThreshold = checkThreshold(member)
    if member.hp > memberThreshold then return end
    if member.hp > saved.FlashSensitivity then return end
    if not member.combat then return end

    return spell:Cast(member)
  end)
end)


excutesent:Callback(function(spell)
  if not target.exists then return end
  if player.Holypower > 2 then return end
  -- if (divintoll.cd > 1.5 or not blink.burst) then return end
  -- if (finalreck.cd > 1.5 or not blink.burst) then return end
  if not player.hasTalent(spell.id) then return end
  if target.buffFrom({8178, 23920}) then return end
  if target.immuneMagicDamage then return end 

  if target.enemy then
    return spell:Cast(target, {face = true})
  end
    
end)

finalreck:Callback("burst", function(spell)
  if target.exists and not target.enemy then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not finalreck.known then return end

  local targetX, targetY, targetZ = target.position()

  if target.enemy 
  and not target.dead then
    -- Determine the optimal position for "Final Reckoning"
    local optimalX, optimalY = targetX, targetY
    local minDistanceToCCedEnemy = math.huge

    -- Consider all positions within the radius of Final Reckoning from the target enemy
    for x = targetX - 8, targetX + 8, 1 do
      for y = targetY - 8, targetY + 8, 1 do
        local distanceToCCedEnemy = math.huge

        -- Check the distance to the nearest CCed enemy at this position
        blink.enemies.within(8, x, y, targetZ).loop(function(enemy)
          if enemy.bcc and not enemy.isPet then
            local enemyX, enemyY, enemyZ = enemy.position()
            local distance = ((x - enemyX)^2 + (y - enemyY)^2)^0.5
            distanceToCCedEnemy = math.min(distanceToCCedEnemy, distance)
          end
        end)

        -- Update the optimal position if this position is better
        if distanceToCCedEnemy > minDistanceToCCedEnemy then
          optimalX, optimalY = x, y
          minDistanceToCCedEnemy = distanceToCCedEnemy
        end
      end
    end

    -- Cast "Final Reckoning" at the optimal position
    if spell:AoECast(optimalX, optimalY, targetZ) then
      return
    end
  end
end)



seraphim:Callback("burst", function(spell)
  if not target.exists then return end
  if not target.los then return end
  if player.Holypower < 3 then return end
  if not player.hasTalent(spell.id) then return end

  if target.enemy then
    return spell:CastAlert()
  end

end)

wings:Callback("burst", function(spell)
  if player.hasTalent(458359) then return end
  if target.dist > 18 then return end
  if not target.exists then return end
  if not target.los then return end
  if not player.hasTalent(spell.id) then return end
	if target.enemy then
		return spell:CastAlert()
	end

end)

divintoll:Callback("burst", function(spell)
  if not target.exists then return end
	if target.enemy then
		return spell:CastAlert(target, {face = true})
	end

end)

wakeofashes:Callback("burst", function(spell)
  if not target.exists then return end
  if not saved.autoAshes then return end
  if player.Holypower > 4 
  and (player.hasTalent(FV.id) and FV.cd == 0)
  or (player.hasTalent(justicar.id) and justicar.cd == 0) then 
    return 
  end

  if player.hasTalent(radiantdecree.id) then return end
  if target.dist > 10 then return end
  if blink.enemies.arcAngle(13, 150, 5, function(o) return o.bcc and not o.isPet end, enemy) > 0 then 
    blink.alert(colors.cyan .. "Holding Wake Of Ashes|r ..|cFFf7f25c [Breakable CC around]")
  end

  if target.enemy
  and player.facing(target, 150)
  and target.distanceLiteral < 9 then
    spell:CastAlert()
  end

end)

wakeofashes:Callback(function(spell)
  if not target.exists then return end
  if not saved.autoAshes then return end
  if player.Holypower > 4 then 
    return 
  end

  if player.hasTalent(radiantdecree.id) then return end
  if target.dist > 10 then return end
  if blink.enemies.arcAngle(13, 150, 5, function(o) return o.bcc and not o.isPet end, enemy) > 0 then 
    blink.alert(colors.cyan .. "Holding Wake Of Ashes|r ..|cFFf7f25c [Breakable CC around]")
  end

  if target.enemy
  and player.facing(target, 150)
  and target.distanceLiteral < 9 then
    spell:CastAlert()
  end

end)

radiantdecree:Callback("burst", function(spell)
  if not target.exists then return end
  if not player.hasTalent(radiantdecree.id) then return end
  if player.Holypower < 3 then return end
  if target.distanceLiteral > 10 then return end
  if blink.enemies.arcAngle(13, 150, 5, function(o) return o.bcc and not o.isPet end, enemy) > 0 then 
    return blink.alert(colors.cyan .. "Holding Wake Of Ashes|r ..|cFFf7f25c [Breakable CC around]")
  end

  if player.facing(target, 150)
  and target.distanceLiteral < 9 then
    spell:CastAlert()
  end

end)

-- freedom:Callback(function(spell)
--   if not blink.arena then return end
--   if not saved.AutoFreedom then return end
--   if spell.cd - blink.gcdRemains > 0 then return end

--   local fhealer = blink.healer

--   blink.group.sort(function(x,y) return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp end)
--   blink.group.loop(function(member)
--     if not member.exists then return end
--     if member.stunned then return end
--     if (member.debuff("Imprison") or member.debuff("Cyclone")) then return end
--     if (member.buff(54216) or member.buff(1044)) then return end

--     if member.slowed and member.attackers2 > 0 and member.hp <= 80 then
--       if spell:Cast(member) then
--         return spell:Cast(member) and alert("Blessing of Freedom " .. member.classString, spell.id)
--       end
--     elseif member.isHealer and member.rooted and member.debuff("Solar Beam") then
--       return spell:Cast(member) and alert("Blessing of Freedom " .. member.classString, spell.id) 
--     end		
--   end)

-- end)
freedom:Callback("prio",function(spell)

  if not saved.AutoFreedom then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.group.loop(function(member)

    local weight = 0
    
    -- Highest priority: Healer with Solar Beam debuff and rooted, but not Druid
    if member.role == "healer" 
    and member.debuff(78675) 
    and member.rooted 
    and member.class2 ~= "DRUID" then
      weight = weight + 4
    end

    -- Second priority: Player rooted
    if player.rooted or player.slowed and target.dist > 10 then
      if member.role == "melee" then
        weight = weight + 3
      elseif member.role == "healer" then
        weight = weight + 2
      else
        weight = weight + 1
      end
    end

    -- Third priority: Being attacked by melee enemy
    local isBeingAttackedByMelee = blink.enemies.find(function(e) 
      return e.isPlayer and e.role == "melee" and e.distanceTo(member) <= 10
    end)
    if isBeingAttackedByMelee then
      weight = weight + 1
    end

    -- Cast Freedom on the member with the highest weight
    if weight > 0 
    and member.slowed 
    or player.slowed 
    and member.los
    and not member.stunned then
      return spell:Cast(member) and alert("Blessing of Freedom " ..member.classString, spell.id)
    end

    -- Additional case: Player is not rooted but member is melee or being attacked by melee
    if not player.rooted 
    and (member.role == "melee" 
    or isBeingAttackedByMelee) 
    and member.slowed 
    and member.los
    and not member.stunned then
      return spell:Cast(member) and alert("Blessing of Freedom "..colors.yellow.."(Gapclose)", spell.id)
    end
  end)
end)

freedom:Callback("command", function(spell)

  if blink.MacrosQueued["free player"] then
    if not player.debuffFrom({217832, 33786}) then 
      if not player.buffFrom({54216, 1044}) then
        if spell:Cast(player) then
          blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlessing of Freedom |cFFf7f25c("..player.name ..")", spell.id)
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
          blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlessing of Freedom |cFFf7f25c("..healer.name ..")", spell.id)
        end	
      end
    end
    
  elseif blink.MacrosQueued["free dps"] then
    if fdps
    and not fdps.isHealer
    and not fdps.debuffFrom({217832, 33786}) then
      if not (fdps.buff(54216) or fdps.buff(1044)) then
        if spell:Cast(fdps) then
          blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlessing of Freedom |cFFf7f25c("..fdps.name ..")", spell.id)
        end	
      end	
    end
	end
end)

local divinSteedBuffs = {
  221883,221885,221886,221887,254471,254472,254473,254474,276111,276112
}
divinesteed:Callback("command", function(spell)
  if player.buffFrom(divinSteedBuffs) then return end
  if not blink.MacrosQueued["steed"] then return end

  return spell:Cast() and blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFDivine Steed", spell.id)
end)

divinesteed:Callback("gapclose", function(spell)
  if not target.exists then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if player.buffFrom(divinSteedBuffs) then return end
  if target.immunePhysicalDamage then return end
  if not saved.AutoSteed then return end 
  if player.mounted then return end
  if not target.enemy then return end
  if target.dist < 15 then return end
  if player.used(190784, 5) then return end  

  local thresh = 100
  thresh = thresh + bin(not enemyHealer.exists or enemyHealer.cc) * 26
  -- thresh = thresh + bin(target.cc) * 18
  thresh = thresh + bin(player.cds) * 46
  thresh = thresh + target.distLiteral

  thresh = thresh * saved.steedSensitivity

  if target.hp <= thresh and player.movingToward(target, { duration = 1, angle = 55 }) then
    return spell:Cast() and alert("Divine Steed "..colors.yellow.."(Gapclose)", spell.id)
  end

end)

local BOPOverLap = {

  186265, --turtle
  196555, --netherwalk
  206803, --rainfromabove
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
  357170, --Evoker time dilation

}


local hasTheSpell = function(obj)
  local has = function(id)
    sr.debugPrint("Checking if obj has spell with ID: " .. id)
    local isAvailable = obj.exists and obj.cooldown(id) <= 0
    sr.debugPrint("Is spell available: " .. tostring(isAvailable))
    return isAvailable
  end

  if obj.class2 == "PALADIN" then
    sr.debugPrint("Obj is a PALADIN")
    local hasSpell = has(642)
    sr.debugPrint("Has spell: " .. tostring(hasSpell))
    return hasSpell
  end

  return false
end

-- BOP:Callback("player", function(spell)

--   if bubble.cd - blink.gcdRemains == 0 then return end
--   if player.hp > saved.BOPSensitivity then return end

--   if player.hp <= saved.BOPSensitivity then
    
--     --care overlaps
--     if player.buffFrom(BOPOverLap) then return end
--     if player.debuff(25771) then return end

--     local enemyHunterThere = blink.enemies.find(function(e) 
--       return e.isPlayer and e.class2 == "HUNTER"
--     end)

--     local isBeingAttackedByMeleeNearby = blink.enemies.find(function(e) 
--       return e.isPlayer and e.role == "melee" and e.distance <= 20
--     end)

--     if not isBeingAttackedByMeleeNearby or not enemyHunterThere then return end

--     if spell:Cast(player) then 
--       alert("Blessing of Protection " .. (player.name or "") .. "|cFFf74a4a [Low hp]", spell.id)
--     end
--   end
-- end)

BOP:Callback("command", function(spell)

	if (blink.MacrosQueued["bop healer"] 
  or blink.MacrosQueued["bop dps"]) then

    --healer
    if blink.MacrosQueued["bop healer"] 
    and healer.exists 
    and not (healer.debuff(217832) or healer.debuff(33786)) then 
      if spell:Cast(healer) then
        blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlessing of Protection! |cFFf7f25c("..healer.classString ..")", spell.id)
      end		
    end

    if blink.MacrosQueued["bop healer"] 
    and not healer.exists then
      blink.alert("|cFFf7f25c[Check]: |cFFf74a4aNo Friendly Healer Exists", spell.id)
    end

    --lets filter our group and get the dps only shallwe?
		blink.group.loop(function(fdps)

      if not blink.MacrosQueued["bop dps"] then return end

      if fdps.exists 
      and not fdps.isHealer 
      and not (fdps.debuff(217832) or fdps.debuff(33786)) then
        if spell:Cast(fdps) then
          blink.alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlessing of Protection! |cFFf7f25c("..fdps.classString ..")", spell.id)
        end	
      end

      if blink.MacrosQueued['bop dps'] 
      and not fdps.exists then
        blink.alert("|cFFf7f25c[Check]: |cFFf74a4aNo Friendly DPS Exists", spell.id)
      end   

    end) 
    
  end           		
end)


BOP:Callback("blind", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not saved.BopHealerBlind then return end

  if not blink.arena then return end

  if healer.exists
  and healer.los 
  and player.distanceTo(healer) < 40 
  and healer.debuffRemains(2094) > 5 then

    --if healer.cooldown(201450) == 0 then return end

    if healer.debuff(25771) then return end

    if spell:Cast(healer) then 
        alert("Blessing of Protection " .. (healer.name or "") .. "|cFFf74a4a [Full Blind]", spell.id)
    end

  end

end)

sancMePls = {
  --Howl
  [5484] = function(obj)
    return obj.ccRemains >= 2
  end,

  --warr fear
  [5246] = function(obj)
    return obj.ccRemains >= 2
  end,

  --scream
  [8122] = function(obj)
    return obj.ccRemains >= 2
  end,

  --Fear
  [5782] = function(obj)
    return obj.ccRemains >= 2
  end,

  --Fear2
  [118699] = function(obj)
    return obj.ccRemains >= 2
  end,

  -- priest sc
  [15487] = function(obj)
    return obj.ccRemains >= 2
  end,

  --dh sigil fear
  [207684] = function(obj)
    return obj.ccRemains >= 2
  end,

  --dh sigil fear2
  [207685] = function(obj)
    return obj.ccRemains >= 2
  end,

  --HOJ
  [853] = function(obj)
    return obj.stunRemains >= 2
  end,
}


sanc:Callback("healer", function(spell)
  if not healer.exists then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if healer.dist > 40 then return end
  if healer.ccRemains < blink.delays.srDelay.now then return end

  if healer.debuffFrom(sancMePls)
  or healer.stunned 
  and healer.stunRemains >= 2 then

    return spell:Cast(healer) and alert("Blessing of Sanctuary "..colors.cyan..healer.classString, spell.id)

  end

end)

sanc:Callback("friends", function(spell)
  if saved.SancHealeronly then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  
  blink.group.loop(function(member)
    if not member.exists then return end
    if member.dist > 40 then return end
    if member.ccRemains < blink.delays.srDelay.now then return end

    if member.debuffFrom(sancMePls) 
    or member.stunned and member.stunRemains >= 2 then

      return spell:Cast(member) and alert("Blessing of Sanctuary "..colors.cyan..member.classString, spell.id)

    end
  end)
end)

local function shouldBlind(unit)
  return unit.exists and unit.enemy and unit.disorientDR >= 0.5
  and unit.distanceLiteral <= 10
  and not (unit.immuneMagicEffects or unit.ccRemains > 1)
  and not unit.buffFrom(ImmuneToPaldinBlind)
end

blind:Callback("command", function(spell)
  local targets = {
    { key = "blind focus", unit = focus },
    { key = "blind target", unit = target },
    { key = "blind arena1", unit = arena1 },
    { key = "blind arena2", unit = arena2 },
    { key = "blind arena3", unit = arena3 },
    { key = "blind enemyhealer", unit = enemyHealer },
  }

  for _, t in ipairs(targets) do
    if blink.MacrosQueued[t.key] 
    and shouldBlind(t.unit) then

      if spell:Cast() then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlinding Light [" .. t.unit.classString .. "]", spell.id)
      end

      break
      
    end
  end

  if blink.MacrosQueued["blind"] then
    if spell:Cast() then
      alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlinding Light", spell.id)
    end
  end

end)

local function shouldHoj(unit)
  return unit.exists and unit.enemy and unit.stunDR >= 0.5
  and not (unit.immuneStuns or unit.immuneMagicDamage or unit.stunned or unit.ccRemains > 1)
  and not unit.buffFrom(ImmuneToPaldinCC)
end

HOJ:Callback("command", function(spell)
  if player.debuff(410201) then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local targets = {
    { key = "hoj target", unit = target },
    { key = "hoj focus", unit = focus },
    { key = "hoj arena1", unit = arena1 },
    { key = "hoj arena2", unit = arena2 },
    { key = "hoj arena3", unit = arena3 },
    { key = "hoj enemyhealer", unit = enemyHealer },
  }

  for _, t in ipairs(targets) do
    if blink.MacrosQueued[t.key] 
    and shouldHoj(t.unit) then

      if spell:Cast(t.unit, { face = true }) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFHammer of Justice! [" .. t.unit.classString .. "]", spell.id)
      end

      break

    end
  end
end)


HOJ:Callback("cc healer", function(spell)

  if not saved.hojHealer then return end
  if not enemyHealer.exists then return end
  if not shouldHoj(enemyHealer) then return end
  if player.debuff(410201) then return end

  if enemyHealer.sdr == 1
  and sr.lowest(enemies) < 70
  and enemyHealer.ccr <= 1
  and not enemyHealer.isUnit(target)
  and enemyHealer.v2attackers(true) == 0 then

    return spell:Cast(enemyHealer, {face = true}) and alert("Hammer of Justice "..colors.yellow.."[Enemy Healer]", spell.id)

  end

end)

HOJ:Callback("target", function(spell)

  if not saved.hojTarget then return end
  if not target.exists then return end
  if not shouldHoj(target) then return end
  if player.debuff(410201) then return end

  -- if target.buffFrom(ImmuneToPaldinCC)
  -- or target.stunned
  -- or target.immuneStuns
  -- or target.immuneMagicEffects
  -- or target.cc then 
  --   return 
  -- end 

  if enemyHealer.exists
  and enemyHealer.debuff(3355) 
  or enemyHealer.exists and enemyHealer.ccRemains > 2.5
  and target.sdr == 1 then

    if target.buffFrom({377362, 23920}) then return end
    if target.immuneStuns then return end
    if not target.isPlayer then return end

    return spell:Cast(target, {face = true}) and alert("Hammer of Justice "..target.classString, spell.id)

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

rebuke:Callback("interrupt", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local function canInterruptEnemy(unit)
    if not unit.casting and not unit.channeling then return false end
    if unit.castint or unit.channelint then return false end
    if unit.buffFrom({377362, 215769, 421453}) or not unit.los or unit.dist > 10 then return false end
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

        if unit.los and unit.dist <= 8 and saved.autoFaceToKick and not player.facing(unit, 180) then
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

  
  blink.enemies.within(10).loop(function(enemy)
    
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

      local kickHybrid = saved.HybridsKick and enemy.hp <= 80 and not enemy.immunePhysicalEffects and not enemy.isHealer 
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
          performInterrupt(enemy, "Rebuke ")
        else
          performInterrupt(enemy, "Rebuke ", saved.kickCClist)
        end
      end

      if kickPVE then
        performInterrupt(enemy, "Rebuke ")
      elseif kickFastMD then
        performInterrupt(enemy, "Rebuke ", saved.kickHealinglist)
      elseif kickHealer then
        performInterrupt(enemy, "Rebuke ", saved.kickHealinglist)
      elseif kickDangerous then
        performInterrupt(enemy, "Rebuke ", saved.kickDangerouslist)
      elseif kickCC then
        performInterrupt(enemy, "Rebuke ", saved.kickCClist)
      elseif kickHybrid then
        performInterrupt(enemy, "Rebuke ")
      elseif dontKickAvoidableCC then
        performInterrupt(enemy, "Rebuke ", saved.kickCClist)
      end
    end
  end)
end)


-- local function SettingsCheck(settingsVar, castId, channelId)
--   for k, v in pairs(settingsVar) do
--     if k == castId and v == true then return true end
--     if k == channelId and v == true then return true end
--     if type(v) == "table" then
--       for _, id in ipairs(v) do
--         if castId == id then return true end
--         if channelId == id then return true end
--       end
--     end
--   end
-- end

-- rebuke:Callback("interrupt", function(spell)

--   if spell.cd - blink.gcdRemains > 0 then return end

--   blink.enemies.within(10).loop(function(enemy)
--     -- enemy must be casting or channeling
--     local cast, channel = enemy.casting, enemy.channeling
--     if not cast and not channel then return end

--     -- must not be immune to interrupts
--     if cast and enemy.castint or channel and enemy.channelint then return end
--     if enemy.buff(377362) then return end
--     if not enemy.los then return end
--     if enemy.dist > 10 then return end

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
--             alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--             alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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

--         
--           if not enemy.casting or enemy.channeling then return end

--           if spell:Cast(enemy, {face = true}) then 
--             if not saved.streamingMode then
--               alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--             alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--             alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Rebuke " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end) 
--       end   
--     end
--   end)
-- end)

rebuke:Callback("tyrants", function(spell)
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
    if tyrant.dist > 10 then return end

    if tyrant.casting then

      if not tyrant.casting or tyrant.channeling then return end

      if spell:Cast(tyrant, {face = true}) then 
        if not saved.streamingMode then
          alert("Rebuke " .. "|cFFf7f25c[" .. (tyrant.casting or tyrant.channel) .. "]", spell.id)  
        end
      end
      
    end

  end)

end)

rebuke:Callback("seduction", function(spell)
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
      if EnemyPet.dist > 10 then return end
      if not EnemyPet.channelID == 6358 then return end
        
      if (EnemyPet.casting and EnemyPet.castTimeComplete > delay.now 
      or EnemyPet.channel and EnemyPet.channelTimeComplete > delay.now) then
        if SettingsCheck(saved.kickCClist, EnemyPet.castingid) 
        or SettingsCheck(saved.kickCClist, EnemyPet.channelId) then

          if not EnemyPet.casting or EnemyPet.channeling then return end
  
          if spell:Cast(EnemyPet, {face = true}) then 
            if not saved.streamingMode then
              alert("Rebuke " .. "|cFFf7f25c[" .. (EnemyPet.casting or EnemyPet.channel) .. "]", spell.id)  
            end
          end

        end
      end
    end)
  end
end)

HOH:Callback("slow target", function(spell)
  if not target.exists then return end
  if not target.enemy then return end
  if target.slowed then return end
  if not target.player then return end
  if target.debuffRemains(183218) > target.distLiteral / 2 + target.speed / 2 then return end
  if target.cc then return end
  if target.hp < 30 and target.dist < 6 then return end
  if target.immuneSlows then return end
  return spell:Cast(target)
end)

divineprotection:Callback("emergency", function(spell)
  
  if not saved.AutoDP then return end

  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.hp <= saved.dPSensitivity) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  threshold = threshold * (1 + bin(not healer.exists or not healer.los or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.dPSensitivity) * 0.35)

  if player.hp > threshold then return end

  if player.buff(199448) 
  or player.buff(47788) 
  or player.buff(116849) then 
    return 
  end

  if player.hp > saved.dPSensitivity then return end
  if not player.combat then return end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  end
  

  return spell:Cast() and alert("Divine Protection" ..colors.red .. " [Danger]", spell.id)

end)


-- TRINKETS

-- racials
-- paladin.racial = function()
--     local racial = racials[player.race]
--     if racial and racial() then
--         blink.alert(racial.name, racial.id)
--     end
-- end

-- Troll
-- racials.Troll:Callback(function(spell)
--   if not saved.mode == "ON" or (not blink.burst) then return end
--   if player.buffFrom({feral.tigersfury.id, feral.berserk.id}) then
--     return spell:Cast()
--   end
-- end)

--Badge
Trinkets.Badge:Update(function(item, key)
  if Trinkets.Badge.equipped then
    if target.enemy 
    and blink.burst
    or player.buff(wings.id) then
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



torrent:Callback(function(spell, unit)
  if not player.race == "Blood Elf" then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  blink.enemies.sort(function(x,y) return x.hp < y.hp end)

  blink.enemies.within(8).loop(function(enemy)

    if not enemy.isPlayer then return end
    if not enemy.los then return end
    if enemy.dist > 8 then return end
    if enemy.buffFrom({45438, 642, 362486, 186265}) then return end

    -- Tranqs
    if enemy.buffFrom(PurgeMePls)
    and spell:Cast() then
      return alert("Arcane Torrent (" .. enemy.classString .. ")", spell.id)
    end    

  end)

end)

-- SOV:Callback("emergency", function(spell)
--   if divineprotection.current then return end
--   if player.used(divineprotection.id, 1) then return end
--   if player.buff(bubble.id) then return end
--   if not player.hasTalent(spell.id) then return end
--   if spell.cd - blink.gcdRemains > 0 then return end
--   if not saved.AutoSOV then return end

--   local count, _, _, cds = player.v2attackers()

--   local threshold = 17
--   threshold = threshold + bin(player.hp <= saved.SOVSensitivity) * 12
--   threshold = threshold + count * 5
--   threshold = threshold + cds * 9

--   threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.SOVSensitivity) * 0.35)

--   if player.hp > threshold then return end
--   if player.hp > saved.SOVSensitivity then return end
--   if not player.combat then return end

--   if player.casting or player.channeling then
--     blink.call("SpellStopCasting")
--     blink.call("SpellStopCasting")
--   end
  
--   if spell:Cast() then
--     alert("Shield of Vengeance" ..colors.red .. " [Danger]", spell.id, true)
--   end
-- end)





-- Optimized Paladin Defensive Priority Functions

-- Lay on Hands (LoH)
layonhand:Callback("percent", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(633) then return end

  --Cast on player 
  if player.hp <= saved.LayonhandSensitivity 
  and not player.debuff(25771) then
    sr.debugPrint("Lay on Hands: " .. player.hp)
    return spell:CastAlert(player)
  end

  --Cast team members
  blink.group.sort(function(x, y)
    return (x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2) or
    (x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp)
  end)

  blink.group.loop(function(member)
    if member.hp <= saved.LayonhandSensitivity 
    and member.los 
    and member.dist <= 40 
    and not member.debuff(25771) then
      return spell:Cast(member) and alert("Lay on Hands " .. (member.classString or "") .. "|cFFf74a4a [Low HP]", spell.id)
    end
  end)
end)

-- Blessing of Protection (BoP)
BOP:Callback("percent", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(1022) then return end
  local ThereIsMelee = blink.enemies.find(function(e) return e.isPlayer and e.role == "melee" or e.class2 == "HUNTER" end)
  if not ThereIsMelee then return end

  --Cast on player 
  if player.hp <= saved.BOPSensitivity 
  and not player.debuff(25771) 
  and not member.buffFrom(BOPOverLap) then
    return spell:CastAlert(player)
  end

  --Cast team members
  blink.group.sort(function(x, y)
    return (x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2) or
    (x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp)
  end)

  blink.group.loop(function(member)
    if member.hp <= saved.BOPSensitivity 
    and member.los 
    and member.dist <= 40 
    and not member.debuff(25771) 
    and not member.buffFrom(BOPOverLap) then
      return spell:Cast(member) and alert("Blessing of Protection " .. (member.classString or "") .. "|cFFf74a4a [Low HP]", spell.id)
    end
  end)
end)

-- Blessing of Spellwarding (BoS)
warding:Callback("percent", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(204018) then return end
  local isBeingAttackedByMagic = blink.enemies.find(function(e) return e.role == "ranged" and e.class2 ~= "HUNTER" end)
  if not isBeingAttackedByMagic then return end

  --Cast on player 
  if player.hp <= saved.WardingSensitivity 
  and not player.debuff(25771) 
  and not member.buffFrom(BOPOverLap) then
    return spell:CastAlert(player)
  end

  --Cast team members
  blink.group.sort(function(x, y)
    return (x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2) or
    (x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp)
  end)

  blink.group.loop(function(member)
    if member.hp <= saved.WardingSensitivity 
    and member.los 
    and member.dist <= 40 
    and not member.debuff(25771) 
    and not member.buffFrom(BOPOverLap) then
      return spell:Cast(member) and alert("Blessing of Spellwarding " .. (member.classString or "") .. "|cFFf74a4a [Low HP]", spell.id)
    end
  end)
end)

paladin.timeHoldingGCD = 0
paladin.timeHoldingGCDStart = 0

local lastTimeCounted = 0
local currentTime = GetTime()

function paladin:HoldGCDForBubble()

  -- bubble not ready :P
  if not blink.actor.bubble or not blink.actor.bubble.known or blink.actor.bubble.cd - blink.gcdRemains > 0 then return false end
  -- -- already held max gcds
  if currentTime > (lastTimeCounted + 3) then lastTimeCounted = GetTime() return end

  --we are higher that the set HP
  if player.hp > saved.BubbleSensitivity + 10 then return end

  if player.hp <= saved.BubbleSensitivity + 10 then 
    return true
  end

end

-- Divine Shield (Bubble)
bubble:Callback("emergency", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  if player.hp > saved.BubbleSensitivity then return end

  if player.hasTalent(633) 
  and layonhand.current 
  or layonhand.cd - blink.gcdRemains == 0 then 
    return 
  end

  if player.casting or player.channeling then
    blink.call("SpellStopCasting")
    blink.call("SpellStopCasting")
  else
    return spell:CastAlert()
  end
end)