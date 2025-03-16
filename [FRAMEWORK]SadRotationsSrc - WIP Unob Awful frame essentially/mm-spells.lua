local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local hunter, mm = sr.hunter, sr.hunter.mm
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local gcd, buffer, latency, tickRate, gcdRemains = 0, 0, 0, 0, 0
local saved = sr.saved
local alert = blink.alert
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
local gz = blink.GroundZ
local delay = blink.delay(0.5, 0.6)
local stompDelay = blink.delay(0.5, 0.6)

local currentSpec = GetSpecialization()

if not hunter.ready then return end

if currentSpec ~= 2 then return end


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
  aimed = NS({19434, 392060}, { ignoreUsable = true, ranged = true, targeted = true, ignoreMoving = function() return player.buff(194594) end }),
  explosive = NS(212431, { ignoreUsable = true, ranged = true, targeted = true, ignoreMoving = true }),
  arcaneshot = NS(185358, { ignoreUsable = true, ranged = true, targeted = true }),
  rapid = NS(257044, { ignoreUsable = true, ranged = true, targeted = true, ignoreMoving = true }),
  steadyshot = NS(56641, { ignoreUsable = true, ranged = true, targeted = true, ignoreMoving = true }),
  serpent = NS(271788, { damage = "magic", targeted = true, ignoreMoving = true }),
  crows = NS(131894, { effect = "physical", ranged = true, targeted = true, ignoreMoving = true }),
  conc = NS(5116, { effect = "physical", targeted = true, slow = true, ignoreMoving = true }),
  sniper = NS(203155, { ignoreUsable = true, ranged = true, targeted = true }),
  blackArrow = hunter.blackArrow,

  
  -- cc
  testTrap = blink.Spell(187650, { effect = "magic", ignoreFacing = true, diameter = 6, ignoreCasting = true, ignoreChanneling = true }),
  --scatter = NS(213691, { effect = "physical", targeted = true, ignoreMoving = true }),
  trap = hunter.trap,
  tar = NS(187698, { effect = "magic", ignoreFacing = true, facingNotRequired = true, slow = true }),
  tartrap = hunter.tartrap,
  cs = NS(147362, { effect = "physical", ranged = true, ignoreCasting = true, ignoreChanneling = true, ignoreGCD = true }),
  ChimaeralSting = hunter.ChimaeralSting,
  bindingshot = hunter.bindingshot,
  SlowBigDam = NS(5116, { effect = "physical", targeted = true, slow = true }),
  steeltrap = hunter.steeltrap,
  Scatter = hunter.Scatter,
  intimidation = hunter.intimidation,
  concu = hunter.concu,

  -- offensive
  trueshot = NS(288613),
  salvo = NS(400456),
  volley = NS(260243, { ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true, diameter = 20, radius = 10 }),
  chakram = NS(375891, { damage = "magic", targeted = true }),
  tranq = hunter.tranq,
  bassy = NS(205691, { damage = "physical", ranged = true, targeted = true }),

  -- defensive
  fleshcraft = NS(324631),
  feign = hunter.feign,
  turtle = hunter.turtle,
  exhilaration = hunter.exhilaration,
  Healthstone = NewItem(5512),
  PhialofSerenity = NewItem(177278),

  -- misc
  pettaunt = NS(2649, { ignoreFacing = true }),
  flare = hunter.flare,
  mendPet = NS(136, { heal = true }),
  camo = hunter.camo,
  ros = hunter.ros,
  SOTF = hunter.SOTF,
  fortitude = hunter.fortitude,
  MMfortitude = hunter.MMfortitude,
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


}, mm, getfenv(1))

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

-- local barbed_next_gcd = false 
-- local barbed_refresh_time = 0
-- local barbedAlert = function()
--   if gcdRemains > 0 then return end
--   blink.alert("Waiting |cFFf7f25c[Barbed Shot]", barbed.id)
-- end

-- filters 
local function bcc(obj) return obj.bcc end

-- buffs
local flayers_mark = 378770
local frenzy = 272790

-- unit we will be trapping
local trapTarget = hunter.trapTarget
mm.trapTarget = trapTarget

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
--local flayedShotTicking = false

--local consecutiveKillCommands = 0

-- hook :Cast calls that return true
-- hookCasts(function(spell)
--   if spell.id == killCommand.id then 
--     consecutiveKillCommands = consecutiveKillCommands + 1
--   else
--     consecutiveKillCommands = 0
--   end
-- end)

-- mm.burst = function()

--   if (target.buff(198589) or target.buff(212800) or target.immunePhysicalDamage) then return end

--   salvo("burst")

--   mm.racial()
--   Trinkets.Badge()
--   Trinkets.PvPBadge()

--   --Chakram
--   if blink.enemies.around(target, 5, bcc) == 0 then 
--     chakram("burst")
--   else
--     return alert(colors.cyan .. "Holding Chakram|r ..|cFFf7f25c [Breakable CC around]", chakram.id)
--   end

--   --volley
--   if blink.enemies.around(target, 9, bcc) == 0 then 
--     volley("burst")
--   else
--     return alert(colors.cyan .. "Holding Chakram|r ..|cFFf7f25c [Breakable CC around]", volley.id)
--   end

--   --explosive
--   if blink.enemies.around(target, 9, bcc) == 0 then 
--     explosive("burst")
--   else
--     return alert(colors.cyan .. "Holding Chakram|r ..|cFFf7f25c [Breakable CC around]", explosive.id)
--   end

--   --rapid fire
--   rapid("burst")

--   --trueshot
--   trueshot("burst")

--   --BURST ORDER
--   -- mm.racial()
--   -- salvo("go")
--   -- chakram("go")
--   -- Trinkets.Badge()
--   -- rapid("go")
--   -- trueshot("go")

-- end  

-- hook first spell callback per frame
hookCallbacks(function(spell)

  gcd, buffer, latency, tickRate, gcdRemains = blink.gcd, blink.buffer, blink.latency, blink.tickRate, blink.gcdRemains

  trapTarget = hunter.trapTarget

  --flayedShotTicking = false

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
  
  -- barbed_refresh_time = gcd + buffer + latency + tickRate + 0.215

  -- barbed_next_gcd = target.enemy 
  -- and pet.exists
  -- and pet.buff(frenzy) 
  -- and pet.buffRemains(frenzy) <= barbed_refresh_time
  -- and (barbed.charges > 0 or barbed.nextChargeCD < pet.buffRemains(frenzy))

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
  aimed.current and "Aimed Shot" or
  arcaneshot.current and "Arcane Shot" or
  steadyshot.current and "Steady Shot"
  
  if isQueued then
    if target.hp <= 20 and kill.cd == 0 then

      if player.castID == 19434 and player.castpct > 70 then return end

      blink.call("SpellStopCasting")
      blink.call("SpellCancelQueuedSpell")
      blink.alert("Cancelling " .. isQueued .. " |cFFf7f25cfor KS Execute")
    end
  end

  
  if isQueued then
    if player.buff(flayers_mark) then

      
      if blink.enemies.around(target, 6, function(o) return o.bcc end) > 0 then
        return
      end

      if player.castID == 19434 and player.castpct > 70 then return end

      blink.call("SpellCancelQueuedSpell")
      blink.alert("Cancelling " .. isQueued .. " |cFFf7f25cfor KS Proc")
    end
  end

  local SteadyshotQueued = 
  steadyshot.current and "Steady Shot"
  if SteadyshotQueued then
    if player.buff(194594) then
      blink.call("SpellStopCasting")
      blink.alert("Cancelling " .. SteadyshotQueued .. " |cFFf7f25cfor Aimed Shot Proc")
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
}

local FullyImmuneDeBuffs = 
{
  33786, --Cyclone
  217832, --Imprison
  203337, --Diamond Ice
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
mm.racial = function()
  local racial = racials[player.race]
  if racial and racial() then
    blink.alert(racial.name, racial.id)
  end
end

-- orc
racials.Orc:Callback(function(spell)
  if not player.race == "Orc" then return end
  if player.buffFrom({mm.trueshot.id}) then
    return spell:Cast()
  end
end)

-- Troll
racials.Troll:Callback(function(spell)
  if not player.race == "Troll" then return end
  if player.buffFrom({mm.trueshot.id}) then
    return spell:Cast()
  end
end)


-- arcaneshot
arcaneshot:Callbacks({
  ["focus capped"] = function(spell)

    if target.buffFrom(FullyImmuneBuffs) 
    or target.debuffFrom(FullyImmuneDeBuffs) then 
      return 
    end

    if target.exists and target.enemy and target.bcc then return end
    if not player.moving and aimed.charges > 0 then return end
    if player.buff(260242) or player.focus > 55 then
      return spell:Cast(target, { face = true }) 
    end
  end,
  pve = function(spell)

    if target.buffFrom(FullyImmuneBuffs) 
    or target.debuffFrom(FullyImmuneDeBuffs) then 
      return 
    end

    if target.exists and target.enemy and target.bcc then return end
    if not player.moving and aimed.charges > 0 then return end
    if target.hp < 30 and aimed.charges == 0 then
      return spell:Cast(target, { face = true }) 
    end
  end
})

aimed:Callback("proc",function(spell)
  if not player.buff(194594) then return end
  if not spell:Castable(target) then return end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end
  
  --eva
  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if target.exists
  and target.enemy then
    return spell:Cast(target, { face = true }) 
  end
end)

aimed:Callback(function(spell)
  if player.moving and not player.buff(194594) then return end
  if not player.buff(342076) and rapid.cd - blink.gcdRemains == 0 and not player.stealth then return end
  if not player.buff(288613) and rapid.cd - blink.gcdRemains == 0 and not player.stealth then return end
  if target.predictLoS(0.5, player) and rapid.cd - blink.gcd == 0 then return end
  if not spell:Castable(target) or (player.focus < 35 and not player.buff(194594)) then return end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if player.buff(257622) 
  and blink.enemies.around(target, 6, bcc) > 0 then
    alert(colors.hunter .. "Holding Aimed Shot|r ..|cFFf7f25c [Breakable CC around]", spell.id)
  else
    if target.enemy then
     return spell:Cast(target, { ignoreMoving = player.buff(194594), face = true }) 
    end
  end
end)

sniper:Callback(function(spell)
  
  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if aimed.cd <= 0.5 or aimed.charges >= 1 and player.buff(288613) then return end
  if not player.hasTalent(spell.id) then return end
  if not target.enemy then return end

  return spell:Cast(target) 

end)

sniper:Callback("opener",function(spell)
  
  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end
  
  if not player.hasTalent(spell.id) then return end
  if not target.enemy then return end

  return spell:Cast(target) 

end)

steadyshot:Callback(function(spell)
  if target.exists and target.enemy and target.bcc then return end
  if target.enemy and player.power <= 25 then
    return spell:Cast(target, { face = true }) 
  end
end)


rapid:Callback("normal", function(spell)
  if target.exists and target.enemy and target.bcc then return end
  if player.disarmed then return end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end


  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if player.buff(257622) and blink.enemies.around(target, 6, bcc) > 0 then
    alert(colors.hunter .. "Holding Rapid Fire|r ..|cFFf7f25c [Breakable CC around]", spell.id)
  else
    if target.exists 
    and target.enemy then 
      return spell:CastAlert(target, { face = true }) 
    end
    -- if target.enemy 
    -- and player.buff(260402) 
    -- or player.buff(288613)
    -- or target.debuff(375893) 
    -- and salvo.cd >= 19 then
    --   return spell:CastAlert(target, { face = true }) 
    -- end
  end 

end)

trueshot:Callbacks({
  -- burst or go w/ trap
  go = function(spell)

    if player.disarmed then return end
    if target.buffFrom(FullyImmuneBuffs) 
    or target.debuffFrom(FullyImmuneDeBuffs) then 
      return 
    end
  
  
    if target.buff(5277) 
    and target.facing(blink.player, 225) then
      return 
    end
    
    if blink.MacrosQueued['burst'] and player.used(257044, 5) then
      return spell:Cast() and alert("True Shot", spell.id)
    end
  end,
  ["normal"] = function(spell)

    if player.disarmed then return end

    if target.buffFrom(FullyImmuneBuffs) 
    or target.debuffFrom(FullyImmuneDeBuffs) then 
      return 
    end
  
  
    if target.buff(5277) 
    and target.facing(blink.player, 225) then
      return 
    end

    if blink.burst 
    or saved.mode == "ON" 
    and target.enemy 
    and player.used(257044, 5) then

      return spell:CastAlert()
    end
  end   
})

serpent:Callback(function(spell)
  if target.exists and target.enemy and target.bcc then return end
  if not player.hasTalent(spell.id) then return end
  if serpent.recentlyUsed(1) then return end
  if target.enemy 
  and target.debuffRemains(271788) <= 3 then
    return spell:Cast(target, { face = true }) 
  end
end)

explosive:Callback("burst", function(spell)
  if target.exists and target.enemy and target.bcc then return end
  if volley.used(2) then return end
  if target.buff(spell.id) then return end
  --if chakram.cd < 5 then return end
  if not player.hasTalent(spell.id) then return end
  if blink.enemies.around(target, 9, bcc) > 0 then alert(colors.cyan .. "Holding Explosive|r ..|cFFf7f25c [Breakable CC around]", spell.id) end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end
  

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end
  
  if target.enemy 
  and blink.enemies.around(target, 9, bcc) == 0 then
    return spell:Cast(target)
  end

end)

explosive:Callback("normal", function(spell)
  if target.exists and target.enemy and target.bcc then return end
  if volley.used(2) then return end
  if target.buff(spell.id) then return end
  --if chakram.cd < 5 then return end
  if not player.hasTalent(spell.id) then return end
  if blink.enemies.around(target, 9, bcc) > 0 then alert(colors.cyan .. "Holding Explosive|r ..|cFFf7f25c [Breakable CC around]", spell.id) end
  
  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end
  

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end
  
  if target.enemy 
  and blink.enemies.around(target, 9, bcc) == 0 then
    return spell:Cast(target)
  end

end)

rapid:Callback("burst", function(spell)
  if target.exists and target.enemy and target.bcc then return end
      if player.disarmed then return end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end
  

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if target.enemy 
  and player.buff(260402) 
  or target.debuff(375893) 
  or salvo.cd >= 19 
  or target.hp <= 35
  or blink.burst
  or blink.MacrosQueued['burst'] then
    if rapid:Cast(target) then
      alert("Rapid Fire", rapid.id)
    end
  end
end)

trueshot:Callback("burst", function(spell)

  if player.disarmed then return end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end


  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if target.enemy 
  and player.used(257044, 5) 
  or rapid.cd > 1 
  or blink.MacrosQueued['burst'] then
    return spell:CastAlert()
  end
end)

chakram:Callback("normal", function(spell)

  if target.exists and target.enemy and target.bcc then return end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end
  

  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if not target.exists then return end
  if not target.enemy then return end

  if player.buff(260402)
  or rapid.cd < 1 then
    return spell:CastAlert(target)
  end

end)


chakram:Callback("burst", function(spell)

  if target.exists and target.enemy and target.bcc then return end

  if target.buffFrom(FullyImmuneBuffs) 
  or target.debuffFrom(FullyImmuneDeBuffs) then 
    return 
  end


  if target.buff(5277) 
  and target.facing(blink.player, 225) then
    return 
  end

  if not target.exists then return end
  if not target.enemy then return end

  if blink.burst or saved.mode == "ON" then

    return spell:CastAlert(target)
  end

end)

salvo:Callback("burst", function(spell)
  if not target.exists then return end
  if not target.enemy then return end
  if rapid.cd > 1 then return end
  if not target.los then return end
  if target.enemy then
    return spell:CastAlert()
  end
end)

volley:Callback("burst", function(spell)
  if target.exists and target.enemy and target.bcc then return end
  if player.hasTalent(salvo.id) and salvo.cd < 4 then return end
  if not spell:SmartAoE(target) then return end
  if not target.exists then return end
  if not target.enemy then return end
  if spell.cd - blink.gcdRemains > 0 then return end 
  if explosive.used(2) then return end
  if target.buff(explosive.id) then return end
  if not player.hasTalent(spell.id) then return end
  if blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) > 0 then return end
 
  if blink.enemies.around(target, 10, function(o) return o.bcc and not o.isPet end) == 0 then
    if spell:AoECast(target) then
      alert("Volley", spell.id)
    end
  end
end)

salvo:Callbacks({
  -- burst or go w/ trap
  go = function(spell)
    if blink.MacrosQueued['burst'] then
      return spell:Cast() and alert("Double Tap", spell.id)
    end
  end,
  ["normal"] = function(spell)
    if target.enemy and saved.mode == "ON" and enemyHealer.ccRemains >= 3.8 then
      return spell:Cast() and alert("Double Tap", spell.id)
    end
  end   
}) 

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

arcaneshot:Callback("stomp", function(spell)
  return stomp(function(totem)
    if not saved.autoStomp then return end
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los then return end
    if totem.distanceLiteral > spell.range then return end
    if player.buff(camo.id) or player.stealth then return end
      
    if totem.id == 101398 and totem.buff(135940) and tranq.cd < 0.5 then 
      return tranq:Cast(totem, { face = true })
    else
      if spell:Cast(totem, { face = true }) then
        return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
      end
    end
  end)
end)

--! END TOTEM STOMPAGE !--


-- TRINKETS

--Badge
Trinkets.Badge:Update(function(item, key)
	if Trinkets.Badge.equipped then
    if player.buffFrom({mm.trueshot.id, mm.salvo.id}) then
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
-- crows:Callback("bursty", function(spell)
-- 	if blink.MacrosQueued['burst'] and player.hasTalent(131894) and target.los and not target.immunePhysicalDamage then 
-- 		if spell:Cast(target) then
-- 			alert("|cFFf7f25c[Bursting]: " .. (target.classString or "") .. " ", spell.id)
-- 		end		
-- 	end			
-- end)
-- --wild
-- burstwild:Callback("bursty", function(spell)
-- 	if blink.MacrosQueued['burst'] and not target.immunePhysicalDamage then 
-- 		if spell:Cast(target) then
-- 			alert("|cFFf7f25c[Bursting]: " .. (target.classString or "") .. " ", spell.id)
-- 		end		
-- 	end			
-- end)

--Taunt pets Shaman/small necro covenant
pettaunt:Callback("tauntpets", function(spell)
  pets.loop(function(enemyPet)
    if (enemyPet.name == ("Greater Earth Elemental") or enemyPet.name == ("Kevin's Oozeling")) 
    and enemyPet.distanceTo(pet) < 30
    and enemyPet.losOf(pet) then
      return spell:Cast(enemyPet) and alert("Taunt (Pet - " .. enemyPet.name .. ")", spell.id)
    end
  end)
end)  


fleshcraft:Callback(function(spell)
  if not fleshcraft.known then return end
  if spell:Cast() then
    alert(colors.hunter .. "Fleshcraft", spell.id)
  end
end)


hunter.importantPause = false
