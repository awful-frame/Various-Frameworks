local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local hunter, sv = sr.hunter, sr.hunter.sv
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local gcd, buffer, latency, tickRate, gcdRemains = 0, 0, 0, 0, 0
local saved = sr.saved
local colors = blink.colors
local target = blink.target
local arena1 = blink.arena1
local arena2 = blink.arena2
local arena3 = blink.arena3
local pet = blink.pet
local enemy = blink.enemy
local player = blink.player
local focus = blink.focus
local fhealer = blink.healer
local enemyHealer = blink.enemyHealer
local bin = blink.bin
local enemyPets = blink.enemyPets
local NewItem = blink.Item
local delay = blink.delay(0.5, 0.6)
local stompDelay = blink.delay(0.5, 0.6)

local currentSpec = GetSpecialization()

if not hunter.ready then return end

if currentSpec ~= 3 then return end
  
blink.Populate({

  -- units [slight perf increase in actor/callbacks + exposes rest of file to units]
  target = blink.target,
  focus = blink.focus,
  player = blink.player,
  healer = blink.healer,
  pet = blink.pet,
  enemyHealer = blink.enemyHealer,

  -- dmg
  --kill = NS(320976, { ignoreUsable = true, ranged = true }),
  kill = hunter.kill,
  bomb = NS(259495, { damage = "magic", ranged = true, targeted = true }),
  explosiveshot = NS(212431, { damage = "magic", ranged = true, targeted = true }),
  serpent = NS(271788, { damage = "magic", ranged = true, targeted = true }),
  killCommand = NS(259489, { damage = "physical", ranged = true, targeted = true, ignoreFacing = true }),
  crows = NS(131894, { damage = "physical", ranged = true, targeted = true }),
  conc = NS(5116, { effect = "physical", targeted = true, slow = true }),
  SlowBigDam = NS(5116, { effect = "physical", targeted = true, slow = true }),
  -- Chakrams = NS(259391, { effect = "physical", ranged = true, targeted = true }),
  flanking = NS(269751, { effect = "physical", targeted = true, ranged = true }),
  mongoose = NS({259387, 265888, 186270}, { ignoreRange = function() return player.buff(186289) end, damage = "physical", targeted = true }),
  fury = NS(203415, { effect = "physical", ignoreMoving = true, targeted = false  }),
  butchery = NS(212436, { effect = "physical", ignoreMoving = true  }),
  
  -- cc
  tarbomb = NS(407028, { effect = "physical", cc = true, ignoreFacing = true }),
  tar = NS(187698, { effect = "magic", ignoreFacing = true, slow = true }),
  cs = NS(187707, { effect = "physical", ignoreGCD = true, alwaysFace = true }),
  Wingclip = NS(195645, { effect = "physical", targeted = true, slow = true }),
  trap = hunter.trap,
  ChimaeralSting = hunter.ChimaeralSting,
  steeltrap = hunter.steeltrap,
  tartrap = hunter.tartrap,
  bindingshot = hunter.bindingshot,
  Scatter = hunter.Scatter,
  intimidation = hunter.intimidation,
  concu = hunter.concu,

  -- offensive
  deathchakram = NS(375891, { damage = "physical", ranged = true, targeted = true }),
  CoordinatedAssault = NS(360952),
  Eagle = NS(186289),
  tranq = hunter.tranq,
  bassy = NS(205691, { damage = "physical", targeted = true }),
  spearhead = NS(360966),

  -- defensive
  feign = hunter.feign,
  turtle = hunter.turtle,
  exhilaration = hunter.exhilaration,
  Healthstone = NewItem(5512),

  -- misc
  pettaunt = NS(2649, { ignoreFacing = true }),
  SOTF = hunter.SOTF,
  fortitude = hunter.fortitude,
  MendingBandage = NS(212640, { ignoreFacing = true }),
  flare = hunter.flare,
  mendPet = NS(136, { heal = true }),
  camo = NS(199483),
  ros = hunter.ros,
  freedom = hunter.freedom,
  disengage = hunter.disengage,
  dash = hunter.dash,

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
  tierPieces = NewItem({207218, 207216, 207221, 207219, 207217}),


}, sv, getfenv(1))

-- expose
hunter.conc = conc
hunter.interrupt = cs

--event callback
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

-- local bomb_next_gcd = false 
-- local bomb_refresh_time = 0
-- local bombAlert = function()
--   if gcdRemains > 0 then return end
--   blink.alert("Waiting |cFFf7f25c[Bomb]", bomb.id)
-- end

-- filters 
local function bcc(obj) return obj.bcc end

-- buffs
local flayers_mark = 378215
local frenzy = 272790
local tipsBuff = 260286

-- unit we will be trapping
local trapTarget = hunter.trapTarget
sv.trapTarget = trapTarget

-- unit who is currently trapped
local trappedTarget = {}
local function findTrappedTarget()
  trappedTarget = {}
  for _, enemy in ipairs(blink.enemies) do
    if enemy.debuff(3355, "player") or enemy.debuff(203337, "player") then
      trappedTarget = enemy
      break
    end
  end
end

-- procs could be cumming!
local flayedShotTicking = false

local consecutiveKillCommands = 0

-- hook :Cast calls that return true
-- hookCasts(function(spell)
--   if spell.id == killCommand.id then 
--     consecutiveKillCommands = consecutiveKillCommands + 1
--   else
--     consecutiveKillCommands = 0
--   end
-- end)

-- hook first spell callback per frame
hookCallbacks(function(spell)

  gcd, buffer, latency, tickRate, gcdRemains = blink.gcd, blink.buffer, blink.latency, blink.tickRate, blink.gcdRemains

  trapTarget = hunter.trapTarget

  --  flayedShotTicking = false

  --   if flayed.cd > 12 then
  --    for _, enemy in ipairs(blink.enemies) do
  --      if enemy.debuff(flayed.id, "player") then
  --        flayedShotTicking = enemy
  --        break
  --      end
  --    end
  --    if not flayedShotTicking then
  --      for _, enemyPet in ipairs(blink.enemyPets) do
  --        if enemyPet.isPet and enemyPet.debuff(flayed.id, "player") then
  --          flayedShotTicking = enemyPet
  --          break
  --        end
  --      end
  --    end
  --   end

  --get fresh trapped target for...
  --bestial wrath
  findTrappedTarget()
  
  -- bomb_refresh_time = gcd + buffer + latency + tickRate + 0.215

  -- bomb_next_gcd = target.enemy 
  -- and bomb.charges > 0

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
  local isQueued = 
  serpent.current and "Serpent Sting" or
  killCommand.current and "Kill Command" or 
  mongoose.current and "Mongoose Bite" or 
  bomb.current and "Bomb"
  if isQueued then
    if player.buff(flayers_mark) then
      blink.call("SpellCancelQueuedSpell")
      blink.alert("Cancelling " .. isQueued .. " |cFFf7f25cfor KS")
    end
  end

  -- local GoodBomb = 
  -- killCommand.current and "Kill Command"
  -- if GoodBomb then
  --   if PherBomb.cd <= 0.1 then
  --     blink.call("SpellCancelQueuedSpell")
  --     blink.alert("Cancelling " .. GoodBomb .. " |cFFf7f25cfor Red Bombastic")
  --   end
  -- end
  --PherBomb
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
sv.racial = function()
  local racial = racials[player.race]
  if racial and racial() then
    blink.alert(racial.name, racial.id)
  end
end

-- orc
racials.Orc:Callback(function(spell)
  if not player.race == "Orc" then return end
  if player.buffFrom({sv.CoordinatedAssault.id}) then
    return spell:Cast()
  end
end)

-- Troll
racials.Troll:Callback(function(spell)
  if not player.race == "Troll" then return end
  if player.buffFrom({sv.CoordinatedAssault.id}) then
    return spell:Cast()
  end
end)


-- bomb shot
-- function SpellChargeFractional(id)
-- 	if GetTime() - select(3, C_Spell.GetSpellCharges(id)) > 0 then
-- 	  return C_Spell.GetSpellCharges(id) + ((GetTime() - select(3, C_Spell.GetSpellCharges(id))) / select(4, C_Spell.GetSpellCharges(id)))
-- 	else
-- 	  return C_Spell.GetSpellCharges(id)
-- 	end
-- end

--Bombs 

-- bomb:Callback(function(spell)
--   if target.enemy then
--     PherBomb:Cast(target)
--   end
--   if target.enemy then
--     VolBomb:Cast(target)
--   end
--   if target.enemy then
--     ShraBomb:Cast(target)
--   end
-- 	-- --if bomb.recentlyUsed(3) then return end
--   -- if target.debuff(162480) then return end
--   -- -- dont check for tier sets ppl are retarded
--   -- --if bomb.cd == 0 then
--   --   if target.enemy 
--   --   and (bomb.charges == 2 or player.buff(363805)) 
--   --   and enemies.around(target, 5, bcc) == 0 and not (target.debuff(162480) or target.bcc or target.immunePhysicalDamage or target.buff("Blur")) then
--   --     spell:Cast(target, {face = true})
--   --   elseif target.enemy
--   --   and enemies.around(target, 5, bcc) == 0 and not (target.debuff(162480) or target.bcc or target.immunePhysicalDamage or target.buff("Blur")) then
--   --     spell:Cast(target, {face = true})
--   --   elseif enemies.around(target, 5, bcc) > 0 then
--   --     alert(colors.cyan .. "Holding Bomb|r ..|cFFf7f25c [Breakable CC around]", spell.id)
--   --   end  
--   -- --end 
-- end)

-- PherBomb:Callback(function(spell)
--   if enemies.around(target, 5, bcc) > 0 then return alert(colors.cyan .. "Holding Bomb|r ..|cFFf7f25c [Breakable CC around]", spell.id) end
--   if (target.debuff(162480) or target.buff(212800) or target.bcc or target.immunePhysicalDamage or target.buff("Blur")) then return end
--   if target.enemy and (PherBomb.charges == 2 or player.buff(363805)) and not target.debuff(270332) then --270332
--     PherBomb:Cast(target)
--   elseif target.buff(270332) then
--     killCommand:Cast(target)
--   elseif player.buff(363805) then
--     PherBomb:Cast(target)
--   end
--   if target.buff(270332) then
--     killCommand:Cast(target)
--   end
-- end)
-- VolBomb:Callback(function(spell)
--   if enemies.around(target, 5, bcc) > 0 then return alert(colors.cyan .. "Holding Bomb|r ..|cFFf7f25c [Breakable CC around]", spell.id) end
--   if (target.debuff(162480) or target.buff(212800) or target.bcc or target.immunePhysicalDamage or target.buff("Blur")) then return end
--   if target.enemy and (VolBomb.charges == 2 or player.buff(363805)) then --271049
--     VolBomb:Cast(target)
--   end
-- end)
-- ShraBomb:Callback(function(spell)
--   if enemies.around(target, 5, bcc) > 0 then return alert(colors.cyan .. "Holding Bomb|r ..|cFFf7f25c [Breakable CC around]", spell.id) end
--   if (target.debuff(162480) or target.buff(212800) or target.bcc or target.immunePhysicalDamage or target.buff("Blur")) then return end
--   if target.enemy and (ShraBomb.charges == 2 or player.buff(363805)) then  --270339
--     ShraBomb:Cast(target)
--   end
-- end)

bomb:Callback(function(spell)
  -- Function to check if it's safe to cast Wild Fire Bomb
  local function isSafeToCastBomb(unit)
    -- Use blink.enemies.find to locate any enemy with bcc in AoE
    local unsafeEnemy = blink.enemies.find(function(enemy)
      return player.facing(enemy, 140) -- Only consider enemies in front of the player
      and enemy.bcc                 -- Check if the enemy has CC
      and not enemy.isPet           -- Exclude pets
    end)

    -- If an unsafe enemy is found, return false (not safe to cast)
    return unsafeEnemy == nil
  end

  -- Avoid casting if it’s unsafe for either player or target
  if not isSafeToCastBomb(player) 
  or not isSafeToCastBomb(target) then
    return
  end

  -- Check for specific target conditions
  if target.buffFrom({198589, 212800}) or target.debuff(162480) or target.bcc or target.immunePhysicalDamage then
    return
  end

  -- Cast conditions
  if target.enemy then -- and (target.debuffRemains(269747) < 1 or player.buff(360952) or target.hp < 30)
    spell:Cast(target, {face = true})
  end
end)


-- bomb:Callback(function(spell)
--   if blink.enemies.around(player, 5, function(o) return o.bcc and not o.isPet end) > 0 then return end
--   if blink.enemies.around(target, 5, function(o) return o.bcc and not o.isPet end) > 0 then return end
--   if spell.used(1) then return end  

--   if target.buffFrom({198589, 212800}) 
--   or target.debuff(162480) 
--   or target.bcc 
--   or target.immunePhysicalDamage then 
--     return 
--   end

--   if target.enemy 
--   and (target.debuffRemains(269747) < 1
--   or player.buff(360952)
--   or target.hp < 30) then
--     spell:Cast(target, {face = true})
--   end

-- end)

explosiveshot:Callback(function(spell)
  local hasBCCEnemies = blink.enemies.find(function(enemy)
    return target.distanceTo(enemy) <= 10 and enemy.bcc and not enemy.isPet
  end)

  if hasBCCEnemies 
  or target.immuneMagicDamage 
  or target.dbr(spell.id, player) > 0 then
    return
  end

  if not player.buff(tipsBuff) then
    if not spell:Castable(target) then return end
    killCommand("pre")
    return spell:CastAlert(target)
  else
    return spell:CastAlert(target)
  end

  -- if target.enemy then
  --   spell:Cast(target)
  -- end
end)

-- explosiveshot:Callback(function(spell)

--   if blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0 then return end

--   if target.immuneMagicDamage then return end
--   if target.enemy then
--     spell:Cast(target)
--   end

-- end)


deathchakram:Callback(function(spell)

  if not player.hasTalent(375891) then return end

  if (target.buffFrom({198589, 212800}) 
  or target.immunePhysicalDamage 
  or target.immuneMagicDamage) then 
    return 
  end

  if target.dist > 39 or not target.los then return end

  if target.enemy then
    return spell:CastAlert(target, {face = true})
  end

end)

-- kill command
killCommand:Callback("gapclose", function(spell)
  if blink.MacrosQueued['pet back'] then return end
  if not pet.exists or pet.dead or pet.cc or pet.rooted then return end
  -- don't spam it, pet probably can't move
  --if consecutiveKillCommands >= 3 then blink.debug.print("pet unable to kill command, prob in CC, saved debuffs to global table 'petDebuffs'", "debug") _G.petDebuffs = pet.debuffs return end
  if not pet.losOf(target) then return end
  if pet.distanceTo(target) > 8 and pet.distanceTo(target) < 40 then
    return spell:Cast(target) and alert("Kill Command |cFFf7f25c[Gapclose]", spell.id)
  end
end)

killCommand:Callback("tip", function(spell)
  if blink.MacrosQueued['pet back'] then return end
  if not pet.exists or pet.dead or pet.cc or pet.rooted then return end
  if not pet.losOf(target) then return end
  --if consecutiveKillCommands >= 3 then blink.debug.print("pet unable to kill command, prob in CC, saved debuffs to global table 'petDebuffs'", "debug") _G.petDebuffs = pet.debuffs return end
  local everyThingOnCd = explosiveshot.cd - blink.gcdRemains > 0 
  and bomb.cd - blink.gcdRemains > 0 
  and not flanking:Castable(target)
  and not butchery:Castable(target)

  if target.enemy 
  and everyThingOnCd 
  or not player.buff(tipsBuff) then
    return spell:Cast(target)
  end

  -- if pet.buffStacks(frenzy) >= 2 then
  --   if not pet.losOf(target) then return end
  --   -- don't spam it, pet probably can't move
  --   if consecutiveKillCommands >= 3 then blink.debug.print("pet unable to kill command, prob in CC, saved debuffs to global table 'petDebuffs'", "debug") _G.petDebuffs = pet.debuffs return end
  --   return spell:Cast(target)
  -- end
end)

-- serpent
serpent:Callback(function(spell)
  if target.distanceLiteral < 8 and target.dbr(serpent.id, "player") > 1 and not target.immunePhysicalDamage then return end
  if serpent.recentlyUsed(3) then return end
  if target.enemy
  and target.dbr(serpent.id, "player") < 10 
  or target.debuffStacks(378015, "player") < 10
  and not (target.bcc or target.immuneMagicDamage) then
    spell:Cast(target, {face = true})
  end
end)

--spread serpent
serpent:Callback("spread", function(spell)
  if not blink.arena then return end
  blink.enemies.loop(function(enemy)
    if target.hp < 40 then return end
    if not enemy.isPlayer then return end
    if enemy.distanceLiteral < 8 and not enemy.immunePhysicalDamage then return end
    if serpent.recentlyUsed(3) then return end
    if enemy.dbr(serpent.id, "player") < 3 
    and not (enemy.bcc or enemy.immuneMagicDamage) then
      spell:Cast(enemy, {face = true})
    end
  end)
end)

-- fury:Callback(function(spell)
--   if not player.hasTalent(spell.id) then return end
--   --if CoordinatedAssault.cd - blink.gcdRemains < 50 and not player.buff(360952) then return end 
--   blink.enemies.loop(function(enemy)

--     --don't cast it if enemy is cc'd
--     if player.facing(enemy, 180) 
--     and enemy.bcc 
--     and enemy.dist < 7 
--     and player.channelid == 203415 then 
--       return
--     end

--     --cancel fury if enemy is cc'd
--     if player.facing(enemy, 180) 
--     and enemy.bcc 
--     and enemy.dist < 7 
--     and player.channelid == 203415 then 
--       blink.call("SpellStopCasting")
--       blink.alert(colors.cyan .. "Cancel Fury of the Eagle|r ..|cFFf7f25c [Breakable CC around]")
--     end

--     if target.enemy 
--     and player.facing(target, 180)
--     and target.dist < 7 then
--       spell:Cast(target, {face = true})
--     end

--   end)
-- end)

fury:Callback(function(spell)
  if not player.hasTalent(spell.id) then return end
  -- Uncomment if needed: if CoordinatedAssault.cd - blink.gcdRemains < 50 and not player.buff(360952) then return end 

  local isChannelingFury = player.channelid == 203415  -- Check if Fury of the Eagle is being channeled

  -- Function to check for breakable CC in a frontal cone
  local function isFrontalAreaSafeForFury()
    local bccCount = 0
    for _, enemy in ipairs(blink.enemies) do
      if player.facing(enemy, 180) and enemy.dist < 7 and enemy.bcc and not enemy.isPet then
        bccCount = bccCount + 1
      end
    end
    return bccCount == 0
  end

  if isChannelingFury and not isFrontalAreaSafeForFury() then
    -- Cancel Fury of the Eagle if channeling and breakable CC is detected in front
    blink.call("SpellStopCasting")
    blink.alert(colors.cyan .. "Cancel Fury of the Eagle|r ..|cFFf7f25c [Breakable CC around]")
  elseif target and target.enemy and player.facing(target, 180) and target.dist < 7 then
    -- Cast Fury of the Eagle if the target is valid and the frontal area is safe
    if not isChannelingFury and isFrontalAreaSafeForFury() then
      spell:Cast(target, {face = true})
    end
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
    if unit.buffFrom({377362, 215769, 421453}) or not unit.los or not unit.meleeRange then return false end
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

        if unit.los and unit.meleeRange and saved.autoFaceToKick and not player.facing(unit, 180) then
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

      local kickHybrid = saved.HybridsKick and enemy.hp <= 80 and enemy.buffsFrom(ImmuneKick) == 0 and not enemy.isHealer 
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
          performInterrupt(enemy, "Muzzle ")
        else
          performInterrupt(enemy, "Muzzle ", saved.kickCClist)
        end
      end

      if kickPVE then
        performInterrupt(enemy, "Muzzle ")
      elseif kickFastMD then
        performInterrupt(enemy, "Muzzle ", saved.kickHealinglist)
      elseif kickHealer then
        performInterrupt(enemy, "Muzzle ", saved.kickHealinglist)
      elseif kickDangerous then
        performInterrupt(enemy, "Muzzle ", saved.kickDangerouslist)
      elseif kickCC then
        performInterrupt(enemy, "Muzzle ", saved.kickCClist)
      elseif kickHybrid then
        performInterrupt(enemy, "Muzzle ")
      elseif dontKickAvoidableCC then
        performInterrupt(enemy, "Muzzle ", saved.kickCClist)
      end
    end
  end)
end)

-- cs:Callback("interrupt", function(spell)

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
--             alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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

--         --guard it more 
--         if not trappedTarget.exists then return end

--         if spell:Cast(enemy, {face = true}) then 
--           if not saved.streamingMode then
--             alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--           end
--         end
--       end
--     end

--     --Kicking Heals from GUI list "ONLY IF HE IS ENEMY HEALER"
--     if (enemy.hp <= saved.kickhealsunder 
--     or target.hp <= saved.kickhealsunder) 
--     and enemy.isHealer then
--       sr.kickDelay(function()
--         -- Check if the enemy is still casting or channeling
--         if enemy.casting or enemy.channeling then
--           -- Check if the cast/channel is in the kickHealinglist
--           if SettingsCheck(saved.kickHealinglist, enemy.castingid) 
--           or SettingsCheck(saved.kickHealinglist, enemy.channelId) then
--             if spell:Cast(enemy, {face = true}) then 
--               if not saved.streamingMode then
--                 alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--               end
--             end
--           end
--         end
--       end)
--     end    
    
--     --Kicking Dangerous Casts
--     if SettingsCheck(saved.kickDangerouslist, enemy.castingid) 
--     or SettingsCheck(saved.kickDangerouslist, enemy.channelId) then

--       sr.kickDelay(function()
--         if not enemy.casting or enemy.channeling then return end

--         if spell:Cast(enemy, {face = true}) then 
--           if not saved.streamingMode then
--             alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--           end
--         end
--       end)

--     end 

--     --Kicking CC from GUI List
--     if not saved.TripleDR 
--     and not saved.DontKickAvoidableCC then

--       sr.kickDelay(function()

--         if sr.NoNeedToKickThis(enemy) then return end

--         if enemy.casting or enemy.channeling then
--           -- Check if the cast/channel is in the kickCClist
--           if SettingsCheck(saved.kickCClist, enemy.castingid) 
--           or SettingsCheck(saved.kickCClist, enemy.channelId) then
--             if spell:Cast(enemy, {face = true}) then 
--               if not saved.streamingMode then
--                 alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--               end
--             end
--           end
--         end
--       end)
--     end

--     --Kick DPS Under
--     if enemy.hp <= saved.kickdpsunder
--     and not enemy.isHealer then

--       sr.kickDelay(function()
--         if not enemy.casting or enemy.channeling then return end

--         if spell:Cast(enemy, {face = true}) then 
--           if not saved.streamingMode then
--             alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Muzzle " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end) 
--       end   
--     end
--   end)
-- end)

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
    if tyrant.dist > 10 then return end

    if tyrant.casting then

      sr.kickDelay(function()
        if not tyrant.casting or tyrant.channeling then return end

        if spell:Cast(tyrant, {face = true}) then 
          if not saved.streamingMode then
            alert("Muzzle " .. "|cFFf7f25c[" .. (tyrant.casting or tyrant.channel) .. "]", spell.id)  
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
      if EnemyPet.dist > 10 then return end
      if not EnemyPet.channelID == 6358 then return end
        
      if (EnemyPet.casting and EnemyPet.castTimeComplete > delay.now 
      or EnemyPet.channel and EnemyPet.channelTimeComplete > delay.now) then
        if SettingsCheck(saved.kickCClist, EnemyPet.castingid) 
        or SettingsCheck(saved.kickCClist, EnemyPet.channelId) then

          sr.kickDelay(function()
            if not EnemyPet.casting or EnemyPet.channeling then return end
    
            if spell:Cast(EnemyPet, {face = true}) then 
              if not saved.streamingMode then
                alert("Muzzle " .. "|cFFf7f25c[" .. (EnemyPet.casting or EnemyPet.channel) .. "]", spell.id)  
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
  if player.movingToward(trapTarget, { angle = 55, flags = {1, 5, 9, 4, 8, 2057, 2053, 2049, 2056, 2052}, duration = 0 + bin(trap.cd > 8) * (trap.cd / 23) }) then
    return spell:Cast(trapTarget) and alert("|cFFf7f25c[Slow]: " .. (trapTarget.classString or "") .. "  [Trap Mode]", spell.id)
  end 
end)

conc:Callback("yolo trap", function(spell, unit)
  if dontConc(unit) then return end
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

-- bomb stomp
-- bomb:Callback("stomp", function(spell)
--   return stomp(function(totem)
--     if totem.health < 900 and pet.exists and pet.distanceTo(totem) < 15 and pet.losOf(totem) then
--       return bomb("maintain frenzy", totem) and alert("Stomp " .. totem.name, spell.id)
--     end
--   end)
-- end)

-- kc stomp
killCommand:Callback("stomp", function(spell)

  if pet.exists and not (pet.cc or pet.rooted) then
    return stomp(function(totem)
      if not saved.autoStomp then return end
      if not totem.id or not saved.totems[totem.id] then return end
      if player.buff(camo.id) or player.stealth then return end
      if not totem.los then return end
      if pet.distanceTo(totem) < 21 and pet.losOf(totem) then
        if totem.id == 101398 and totem.buff(135940) and tranq.cd <= 0.5 then 
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

serpent:Callback("stomp", function(spell)
  return stomp(function(totem)
    if not saved.autoStomp then return end
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los then return end
    if totem.distanceLiteral > 41 then return end
    if player.buff(camo.id) or player.stealth then return end

    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)

mongoose:Callback("stomp", function(spell)
  return stomp(function(totem)
    if not saved.autoStomp then return end
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los then return end
    if totem.dist > 8 and not player.buff(Eagle.id) then return end
    if player.focus < 30 then return end
    if player.buff(camo.id) or player.stealth then return end

    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)

--! END TOTEM STOMPAGE !--


--BANDAGE
MendingBandage:Callback(function(spell)

  fgroup.loop(function(friend)

    if friend.dist > 15 then return end
    if not friend.los then return end

    if friend.debuff(274837) 
    and friend.debuffUptime(274837) > 0.4 
    or friend.debuff(274838) 
    and friend.debuffUptime(274838) > 0.4 
    or friend.debuff(360194) 
    and friend.debuffUptime(360194) > 0.1 then
			if spell:Cast(friend, {stopMoving = true, ignoreFacing = true}) then
				blink.alert("Mending Bandage |cFFf7f25c("..friend.classString ..")", spell.id)
			end	
    end

	end)

end)


killCommand:Callback("pre", function(spell)
  if blink.MacrosQueued['pet back'] then return end
  if not pet.exists or pet.dead or pet.cc or pet.rooted then return end
  if not pet.losOf(target) then return end
  return spell:Cast(target)
end)

flanking:Callback(function(spell)
  if flanking.cd - blink.gcdRemains > 0 then return end
  if not pet.exists then return end  
  if not pet.losOf(target) then return end  
  if not target.enemy then return end
  if target.dist > 15 then return end

  --give it sometime before jump to target if we used Assult ?
  --if player.used(360952, 1.5) then return end

  if not player.buff(tipsBuff) then
    if not spell:Castable(target) then return end
    killCommand("pre")
    return spell:CastAlert(target)
  else
    return spell:CastAlert(target)
  end
end)

spearhead:Callback(function(spell)
  if target.immunePhysicalDamage then return end
  if player.buffFrom({sv.CoordinatedAssault.id}) then
    return spell:Cast()
  end

end)

-- Aspect of the Eagle
Eagle:Callback(function(spell)
  if player.hasTalent(260285) and player.buffStacks(tipsBuff) < 3 then return end
  if not target.los then return end
  if player.used(CoordinatedAssault.id, 2.5) then return end
  if target.debuff(162480) then return end
  if (target.buff(198589) or target.buff(212800)) then return end
  if target.immunePhysicalDamage then return end

  if target.enemy
  and target.los
  and player.buffStacks(tipsBuff) >= 3
  and blink.burst 
  or saved.mode == "ON" 
  and (target.hp < 80 
  or enemyHealer.ccRemains > 3.5 
  or not enemyHealer.exists and target.hp < 80) 
  and player.focus >= 30
  and target.dist > 20 then
    if spell:Cast() then 
      alert("Aspect of the Eagle", spell.id)
    end
  end

  if target.enemy 
  and player.losOf(target) 
  and player.buff(360952) 
  and target.distanceliteral >= 20 
  and target.distanceliteral < 39 then
    if spell:Cast() then 
      alert("Aspect of the Eagle", spell.id)
    end	
  elseif target.enemy and player.losOf(target) and (target.distanceliteral >= 20 or target.movingAwayFrom(player, { duration = 0.5 })) and player.buff(360952) and target.distanceliteral < 39 then
    if spell:Cast() then 
      alert("Aspect of the Eagle", spell.id)
    end
	end	
end)

butchery:Callback(function(spell)
  if not player.hasTalent(spell.id) then return end
  local hasBCCEnemies = blink.enemies.find(function(enemy)
    return player.distanceTo(enemy) <= 8 and enemy.bcc and not enemy.isPet
  end)

  if hasBCCEnemies then
    return
  end

  if target.meleeRange then
    spell:Cast()
  end
end)

mongoose:Callback(function(spell)
  local everyThingOnCd = explosiveshot.cd - blink.gcdRemains > 0 
  and bomb.cd - blink.gcdRemains > 0 
  and not flanking:Castable(target)
  and not butchery:Castable(target)

  if target.dbr(259491) > 2 then 
    return 
  end

  if target.dbr(259491) < 2 
  or everyThingOnCd 
  and player.buff(186289)then

    return spell:Cast(target)
  end
  
  -- print("Mogoose Fired",math.random(100))
  -- if spell:Castable(target) then
  --   blink.print("accordin' to my calcurlationz, we can cast it!")
  -- end
  -- if (target.dist <= 7.3
  -- or player.buff(186289) and 43 or 0) then
  --   spell:Cast(target, {ranged = true})
  -- end

end)

mongoose:Callback("tip", function(spell)
  if target.dist > 43 then return end
  if target.dist > 7.3 and (not player.buff(186289)) then return end
  if target.debuff(162480) then return end
  if target.buffFrom({198589, 212800}) then return end
  if not player.hasTalent(260285) then return end

  if target.enemy 
  and player.buffStacks(tipsBuff) == 3
  and player.power >= 30 
  and player.losOf(target) 
  and not (target.bcc or target.immunePhysicalDamage or player.IsInCC) then
    spell:Cast(target, {face = true})
  end

end)

-- TRINKETS

--Badge
Trinkets.Badge:Update(function(item, key)

	if Trinkets.Badge.equipped then

    if player.buffFrom({sv.CoordinatedAssault.id}) then
      if item:Use() then
        blink.alert("Badge Trinket", item.spell)
      end
    end

    if target.enemy
    and target.exists
    and CoordinatedAssault.cd - blink.gcdRemains > 60
    and trapTarget.exists
    and trapTarget.cc
    and trapTarget.ccr > 3 then
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

--Bursting by macro 
--Crows if /burst
crows:Callback("burst", function(spell)
	if blink.MacrosQueued['burst'] and player.hasTalent(131894) and target.los and not target.immunePhysicalDamage then 
		if spell:Cast(target) then
			alert("|cFFf7f25c[Bursting]: " .. (target.classString or "") .. " ", spell.id)
		end		
	end			
end)
--Crows if the setting is on
crows:Callback("proc", function(spell)
	if saved.mode == "ON" 
  and player.hasTalent(131894) 
  and target.los 
  and not target.immunePhysicalDamage then 
    if gcdRemains <= blink.spellCastBuffer + 0.05
    and player.buff(flayers_mark) then
      if spell:Cast(target) then
        alert("|cFFf7f25c[Bursting]: " .. (target.classString or "") .. " ", spell.id)
      end	
    end   	
	end			
end)
--CoordinatedAssault if the setting is on
CoordinatedAssault:Callback("proc", function(spell)
  
  if player.hasTalent(271014) 
  and player.hasTalent(389880) 
  and bomb.charges > 0 then 
    return 
  end

  if target.buffFrom({198589, 212800}) then return end
  if saved.mode == "ON" 
  and pet.exists 
  and not target.immunePhysicalDamage then 
    if not target.immunePhysical and target.los and target.distLiteral < 40 then
      if blink.burst 
      or saved.mode == "ON" 
      and (target.stunned 
      or enemyHealer.exists and enemyHealer.ccRemains > 3.5 
      or not enemyHealer.exists and target.hp < 80) then
        return spell:Cast() and alert("|cFFf7f25c[Auto Bursting]: " .. (target.classString or "") .. " ", spell.id)
      end
    end
  end  
end)
--CoordinatedAssault if /burst
CoordinatedAssault:Callback("burst", function(spell)
  if blink.MacrosQueued['burst'] 
  and pet.exists 
  and not target.immunePhysicalDamage then 
    if not target.immunePhysical 
    and target.los 
    and target.distLiteral < 40 then
      return spell:Cast() and alert("|cFFf7f25c[Maunal Bursting]: " .. (target.classString or "") .. " ", spell.id)
    end
  end  
end)


local disarmClasses = {
  --["PALADIN"] = true,
  ["WARRIOR"] = true,
  ["ROGUE"] = true,
  ["DEATHKNIGHT"] = true,
  -- ["MONK"] = true, -- they can still kick you according to the lore
  ["HUNTER"] = true,
  -- ["DEMONHUNTER"] = true, -- ??
}


tarbomb:Callback(function(spell)

  if not player.hasTalent(407028) then return end

  local lowest = sr.lowest(blink.fgroup)

  blink.enemies.loop(function(enemy)

    if enemy.ccr and enemy.ccr > blink.buffer then return end
    -- not into storm
    if enemy.class2 == "WARRIOR" and (enemy.buff(46924) or enemy.buff(227847)) then return end


    -- dance 
    if enemy.class2 == "ROGUE"
    and enemy.buffRemains(185422) > 2.75 - bin(lowest < 60) * 1.5
    and spell:Cast(enemy, { face = true }) then
      return alert("Disarm " ..  "|cFFf7f25c[Shadow Dance]", spell.id)
    end

    -- wings
    if enemy.class2 == "PALADIN"
    and enemy.role == "melee"
    and enemy.buff(31884)
    and spell:Cast(enemy, { face = true }) then
      return alert("Disarm " ..  "|cFFf7f25c[Wings]", spell.id)
    end

    -- enhancment shit
    if enemy.class2 == "SHAMAN"
    and enemy.role == "melee"
    and enemy.buffFrom({204361, 114049})
    and spell:Cast(enemy, { face = true }) then
      return alert("Disarm " ..  "|cFFf7f25c[Wings]", spell.id)
    end

    -- hunter shit
    if enemy.class2 == "HUNTER"
    and (not healer.exists or healer.cc)
    and (lowest < 65 
      + bin(not healer.exists or healer.cc) * 20
      + bin(enemy.cds) * 25)
    and spell:Cast(enemy, { face = true }) then
      return alert("Disarm " .. enemy.classString, spell.id)         
    end

    -- dk offense
    if enemy.class2 == "DEATHKNIGHT"
    and enemy.hp < (30 + bin(not enemyHealer.exists or enemyHealer.cc) * 18)
    and spell:Cast(enemy, { face = true }) then
      return alert("Offensive Disarm " .. enemy.classString, spell.id)
    end

    -- dk defense
    if enemy.class2 == "DEATHKNIGHT"
    and lowest < 25 + bin(enemy.cds) * 15 
    and spell:Cast(enemy, { face = true }) then
      return alert("Disarm " .. enemy.classString, spell.id)
    end

    -- we just need a peel
    if enemy.class2
    and disarmClasses[enemy.class2]
    and enemy.role == "melee" then
      if lowest < 60 + bin(enemy.cds) * 57 + bin(not healer.exists or healer.cc) * 30 - bin(enemy.class2 == "DEATHKNIGHT") * 65 then
        return spell:Cast(enemy, { face = true }) and alert("Disarm " .. enemy.classString, spell.id)
      end
    end
  end)
end)


local disarmMePls = {
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
  --Pillar of Frost
  [51271] = function(source)
    return true
  end,
  --Unholy Assault
  [207289] = function(source)
    return true
  end,
  --Metamorphosis
  -- [162264] = function(source)
  --   return true
  -- end,
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

tarbomb:Callback("CDs", function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end

  blink.enemies.loop(function(enemy)
    if not player.hasTalent(407028) then return end
    if not enemy.exists then return end
    if not enemy.los then return end
    if enemy.dist > spell.range then return end
    if enemy.immunePhysicalEffects then return end
    if enemy.ccr and enemy.ccr > 1 then return end
    -- not into bladestorm
    if enemy.class2 == "WARRIOR" and enemy.buffFrom({46924, 227847, 23920}) then return end
    if not enemy.isPlayer then return end  

    local lowest = sr.lowest(blink.fgroup)

    local has = enemy.buffFrom(disarmMePls)

    if not has then return end
    local str = ""
    for i, id in ipairs(has) do
      if i == #has then
        str = str .. C_Spell.GetSpellInfo(id).spellID
      else
        str = str .. C_Spell.GetSpellInfo(id).spellID .. ","
      end
    end

    if has then
      return spell:Cast(enemy, {face = true}) and blink.alert("Disarm (" .. colors.red .. (str) .. "|r)", spell.id)
    end

    if enemy.isPlayer 
    and not enemy.immunePhysicalEffects 
    and not enemy.isHealer then
      if lowest < 60 + bin(enemy.buffFrom(lassoMePls)) * 57 + bin(not healer.exists or not healer.los or healer.cc) * 30 then
        return spell:Cast(enemy, {face = true}) and blink.alert("Disarm " .. colors.orange.. "(Peeling)", spell.id)
      end
    end
    
  end)
end)