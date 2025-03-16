local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local druid, feral = sr.druid, sr.druid.feral
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local gcd, gcdRemains = blink.gcd, blink.gcdRemains
local gcd, buffer, latency, tickRate, gcdRemains = 0, 0, 0, 0, 0
local saved = sr.saved
local colors = blink.colors
local pet = blink.pet
local enemy = blink.enemy
local player = blink.player
local focus = blink.focus
local fhealer = blink.healer
local enemyHealer = blink.enemyHealer
local bin = blink.bin
local enemyPets = blink.enemyPets
local NewItem = blink.Item
local alert = blink.alert
local delay = blink.delay(0.5, 0.6)
local stompDelay = blink.delay(0.2, 0.4)

local currentSpec = GetSpecialization()

if not feral.ready then return end

if currentSpec ~= 2 then return end

blink.Populate({
  -- units [slight perf increase in actor/callbacks + exposes rest of file to units]
  target = blink.target,
  focus = blink.focus,
  player = blink.player,
  healer = blink.healer,
  pet = blink.pet,
  enemyHealer = blink.enemyHealer,
  arena1 = blink.arena1,
  arena2 = blink.arena2,
  arena3 = blink.arena3,

  -- dmg
  rake = NS(1822, { damage = "physical", bleed = true, targeted = true }),
  rip = NS(1079, { damage = "physical", targeted = true, bleed = true}),
  slash = NS(202028, { damage = "physical"}),
  swarm = NS(391888, { damage = "magic", targeted = true, ranged = true }),
  moonfire = NS(155625, { damage = "magic", ranged = true, targeted = true, facingNotRequired = true, requiresBuff = { 768 } }),
  shred = NS(5221, { effect = "physical", targeted = true }),
  bite = NS(22568, { effect = "physical", targeted = true }),
  primal = NS(285381, { damage = "physical", targeted = true, bleed = true }),
  thrash = NS(106830, { damage = "physical", bleed = true }),

  -- cc
  bash = NS(5211, { effect = "physical", stun = true, cc = "stun", targeted = true }),
  root = NS(339, { facingNotRequired = true, slow = true, targeted = true }),
  skullbash = NS(106839, { effect = "physical", ranged = true, ignoreGCD = true, targeted = true }),
  maim = NS(22570, { effect = "physical", ranged = true, targeted = true, cc = "stun" }),
  clone = NS(33786, { effect = "magic", facingNotRequired = true, targeted = true }),
  ursol = NS(102793),

  -- offensive
  berserk = NS(106951, { ignoreGCD = true }),
  incarnation = NS(102543, { ignoreGCD = true }),
  charge = NS(49376, { ignoreGCD = true, targeted = true }),
  tigersfury = NS(5217, { ignoreGCD = true }),
  frenzy = NS(274837, { damage = "physical", targeted = true, bleed = true }),
  wildcharge = NS(49376, { ignoreGCD = true, targeted = true, requiresBuff = { 768 } }),

  -- defensive
  renewal = NS(108238, { heal = true, ignoreGCD = true }),
  regrowth = NS(8936, { heal = true, ignoreFacing = true, targeted = true }),
  reju = NS(774, { heal = true, ignoreFacing = true, targeted = true }),
  thorns = NS(305497, { ignoreMoving = true, ignoreChanneling = true, targeted = true }),
  swiftmend = NS(18562, { heal = true, targeted = true }),
  barkskin = druid.barkskin,
  Instincts = NS(61336, { ignoreGCD = true }),
  regeneration = NS(22842, { ignoreUsable = true }),
  Bearthrash = NS(77758),
  ironfur = NS(192081),

  -- misc
  decurse = NS(2782),
  MOTW = NS(1126),
  cat = NS(768),
  bear = NS(5487),
  travel = NS(783),
  prowl = NS(5215, { ignoreGCD = true }),
  dash = NS(1850, { ignoreGCD = true }),
  soothe = NS(2908),
  stampedingroar = NS(77764),
  meld = NS(58984, { ignoreFacing = true, ignoreGCD = true }),

  charge = {
    cat = NS(49376),
    human = NS(102401, { facingNotRequired = true }),
    bear = NS(16979),
    travel = NS(102417)
  },

  racials = {
    -- berserking
    Troll = NS(26297),
  },

  --Trinkets Table
  Trinkets = {
    Badge = blink.Item({216368, 216279, 209343, 209763, 205708, 205778, 201807, 201449, 218421, 218713}),
    Emblem = blink.Item({216371, 216281, 209345, 209766, 201809, 201452, 205781, 205710, 218424, 218715}),
  },

}, feral, getfenv(1))

blink.addUpdateCallback(function()
  validTarget = target.enemy and not target.dead
  validPhysical = validTarget and not target.bcc and not target.immunePhysicalDamage and not target.immunePhysicalEffects
  validPhysicalInRange = validPhysical and target.predictDist(buffer) < 3 and player.isFacing(target)
  validMagic = validTarget and not target.immuneMagicDamage and not target.bcc
  targetRipRemains = validTarget and target.debuffRemains(1079, "player") or 0
  targetRakeRemains = validTarget and target.debuffRemains(155722, "player") or 0
  targetMoonfireRemains = validTarget and target.debuffRemains(155625, "player") or 0
  bs_inc_remains = max(player.buffRemains("Berserk"), player.buffRemains("Incarnation: Avatar of Ashamane"))
  bs_inc = bs_inc_remains > 0
  tf_remains = player.buffRemains(5217)
  tf_up = tf_remains > 0
  lunarInspiration = player.hasTalent(155580)
  mgr = player.mgr
  gcd, gcdRemains = blink.gcd, blink.gcdRemains
  player = blink.player
  time, buffer, latency, tickRate, events = blink.time, blink.buffer, blink.latency, blink.tickRate, blink.events
  cp = frenzy.cd >= 45 - gcd and 5 or player.comboPoints
  form = player.buff(768) and "cat" 
    or player.buff(5487) and "bear"
    or player.buff(783) and "travel"
  --
end)


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


-- filters 
local function bcc(obj) return obj.bcc end

-- hook stomp
hookCallbacks(function()
  for _, member in ipairs(blink.group) do 
    fearClassOnTeam = fearClassOnTeam or tContains(fearClasses, member.class2)
  end
  importantTotems[5913] = fearClassOnTeam
end, {"stomp"})


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
local ImmuneToDruidCC = {

	213610, --Holy Ward
	236321, --War Banner
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  353319, --monk retoral
  408558, --priest phase shift
  377362, --precognition
  421453, --Ultimate Penitence

}

local TranqMePls = {

  79206,  --Spiritwalker's Grace
  10060,  --Power Infusion
  80240,  --Havoc
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  305395, --Blessing of Freedom
  1044,   --Blessing of Freedom2
  1022,   --Blessing of Protection
  210294, --divine-favor
  305497, --Thorns
  132158, --Druid Nature's Swiftness
  342246, --Mage Alter time

}


--Decurse
local DecurseThem = {
  [51514] = { uptime = 0.15 },  --hex
	[199954] = { uptime = 0.15 }, --curse of frag
  [199890] = { uptime = 0.15 }, --curse of tongues
	[80240] = { uptime = 0.15 },  --havoc
  [211015] = { uptime = 0.15 }, --hex cockroach
	[210873] = { uptime = 0.15 }, --hex compy
  [211010] = { uptime = 0.15 }, --hex snake
	[211004] = { uptime = 0.15 }, --hex spider
  [277784] = { uptime = 0.15 }, --hex wicker mongrel
	[277778] = { uptime = 0.15 }, --hex zandalari tendonripper
  [309328] = { uptime = 0.15 }, --hex living honey
	[269352] = { uptime = 0.15 }, --hex skeletal raptor
  [356727] = { uptime = 0.15 }, --chimaeral sting silence
  --  [356730] = { uptime = 0.15 }, --chimaeral healing reduce
}

local ShapeshiftIT = {
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
  277787, --end of polys
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
  289419, --end of hex
  1513, --scare beast
}

----------------------------------------------------------------------------------------------------------------
--                                     End of Tables                                                          --
----------------------------------------------------------------------------------------------------------------

feral.opener = function()

  --listen khaled this is really bad opener trust you have to change this garbage #sorry
  --what should you do is that , move all of this shit to Actor and then call each stuff
  --also you need to do it like open stun then restun the target wether he trinket or not 
  --also you need to do something like if player moving to BCC enemy and currunt spell is that multi dot then return end you breaked shit
  --focus more on multi bleeding talent cus its the hype rn
  --khaled opener is bad bad bad fuck you
  --things to take care of 
  --1 - Convoke Usage 
  --2 - War stomp tauren racial usage  
  if not target.exists then return end
  if not target.enemy and player.stealth then return end
  if target.dead then return end

  if form ~= "cat" then return end

  if target.enemy 
  and player.stealth
  and target.stunDR == 1 or target.sdrr > 17 
  and target.stunRemains < 0.8 then
    if not player.stealth then return end
    if target.distliteral < 8 and player.movingToward(target) then
      -- tf
      if tigersfury:Cast() then
        blink.alert("Tiger's Fury", tigersfury.id)
      end
    end

    --return rake:Cast(target) and alert("Rake Stun", rake.id)

  end 

  -- swarm + frenzy go
  if player.hasTalent(frenzy.id) then
    
    -- tf
    if tigersfury:Cast() then
      blink.alert("Tiger's Fury", tigersfury.id)
    end

    -- frenzy
    if player.cp <= 3 and target.stunned and not player.stealthed then 
      if frenzy:Cast(target, { face = true }) then
        blink.alert("Feral Frenzy", frenzy.id)
        return true
      end
    end

    --swarm
    if frenzy.used(3) 
    and target.enemy then
      return swarm:Cast(target)
    end

    --rip
    if player.cp >= 5 then
      if target.hp < 30 then return end
      return rip:Cast(target, { face = true })
    end

  end
end

feral.leapAway = function()

  if form == "cat" then
      blink.enemyPets.sort(function(x,y) return x.dist and y.dist and x.dist > y.dist end)
      --for _, enemy in ipairs(blink.enemyPets) do
      pet.loop(function(enemyPet)
          if enemyPet.dist > 10 then
              if feral.charge.cat:Cast(enemyPet, {alwaysFace=true}) then
                  return true
              end
          end
      end)
  end
  -- no enemy? find freind .. .
  blink.friends.sort(function(x,y) return x.dist and y.dist and x.dist > y.dist end)
  blink.friends.loop(function(friend)
      if friend.dist > 10 and friend.los and friend.dist < 25 then
          if feral.charge.human.cd == 0 then
              blink.call("CancelShapeshiftForm")
              feral.charge.human:Cast(friend)
              return true
          end
      end
  end)
end

feral.bignut = function()
  if not target.exists then return end
  if (player.stealth or player.buff(58984) or target.distliteral > 11) then return end

  -- tiger's fury spam
  if target.stunned 
  and (player.energyMax - player.energy > 40 or bs_inc) 
  and (not player.hasTalent("Feral Frenzy") or frenzy.cd < 4 or frenzy.cd > 23) then
    if tigersfury:Cast() then
      alert("Tiger's Fury", tigersfury.id)
    end
  end

  -- snyc fury+frenzy
  if cp < 3 
  and (tigersfury.cd <= 15 or tf_up) 
  and target.stunned then
    if player.cp <= 3 and not player.stealthed then 
      if frenzy:Cast(target) then
        if tigersfury:Cast() then
          alert("Tiger's Fury", tigersfury.id)
        end
        alert("Feral Frenzy", frenzy.id)
        return true
      end
    end
  end
end


local succs = {127797, 307871}
wildcharge:Callback("gapclose", function(spell)
  if not target.exists then return end
  if (player.stealth or player.buff(58984)) then return end
  if target.immunePhysicalDamage then return end
  if not saved.autoCharge then return end 
  if player.buff(1850) or player.buff(77764) then return end
  if player.stealthed then return end
  if player.casting then return end
  if player.mounted then return end
  if player.debuffFrom(succs) then return end
  if target.dist < 8 then return end
  if target.speed > 8 and target.immuneSlows then return end
  if dash.current then return end
  if stampedingroar.current then return end
  if not target.enemy then return end
  
  local thresh = 100
  thresh = thresh + bin(not enemyHealer.exists or enemyHealer.cc) * 26
  thresh = thresh + bin(target.cc) * 18
  thresh = thresh + bin(player.cds) * 46
  thresh = thresh + target.distLiteral

  thresh = thresh * saved.chargeGapcloseMod
  
  if target.hp <= thresh and player.movingToward(target, { duration = 0.5, angle = 55 }) then
    return spell:Cast(target) and alert("Leap "..colors.yellow.."(Gapclose)", spell.id)
  end

end)

berserk:Callback(function(spell)
  if not target.exists then return end
  if not saved.mode == "ON" then return end
  if player.hasTalent(102543) then return end
  if berserk.cd > 1 then return end
  if not player.hasTalent(berserk.id) then return end
  if player.stealthed or player.buff(58984) then return end

  if target.enemy 
  and target.distliteral < 11 then
    if spell:Cast() then
      alert("Berserk", spell.id, true)
    end
  end

end)


incarnation:Callback(function(spell)
  if not target.exists then return end
  if not saved.mode == "ON" then return end
  if not player.hasTalent(102543) then return end
  if incarnation.cd > 0 then return end
  if not player.hasTalent(incarnation.id) then return end
  if player.stealthed or player.buff(58984) then return end

  if target.enemy 
  and target.distliteral < 11 then
    if spell:Cast() then
      alert("Incarnation", spell.id, true)
    end
  end

end)

prowl:Callback(function(spell)

  if player.buff(spell.id) then return end 

  local enemyPlayerTargetingMe
  if blink.arena then
    blink.enemies.loop(function(enemy)
      if enemy.isPlayer and enemy.target.isUnit(player) then
        enemyPlayerTargetingMe = true
      end
    end)
  end

  if not player.stealth then
    if target.enemy or enemyPlayerTargetingMe then
      if player.dotted and player.absorbs < 1400 then
        if player.speed > 15 or target.enemy and target.predictDist(0.5) < 5 + bin(player.movingToward(target, {duration = 0.1})) * 4 then
          if prowl:Cast() then
            alert("Prowl (Dotted)", prowl.id)
            return
          end
        end
      else
        if player.buff(102543) then return end 
        return prowl:CastAlert()
      end
    end
  end
end)


local firstPrepTimer
MOTW:Callback(function(spell)
  if player.used(prowl.id, 5) then return end
  if player.stealthed then return end
  if player.channeling or player.casting then return end
  --if player.mounted then return end
  if player.combat then firstPrepTimer = nil end
  if blink.arena then
    if blink.prep then
      firstPrepTimer = firstPrepTimer or blink.prepRemains
    end
    if firstPrepTimer and firstPrepTimer - blink.prepRemains > 5 then
      blink.fgroup.loop(function(member)
        if not member.exists then return end
        --if member.faction ~= player.faction then return end
        if player.used(prowl.id, 5) then return end
        if player.used(MOTW.id, 5) then return end
        if player.stealthed then return end
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

rake:Callback("prowled", function(spell)
  if not target.exists then return end
  if form ~= "cat" then return end
  if target.immunePhysicalDamage or target.immuneStuns then return end
  if player.hasTalent(391700) then
    if blink.enemies.around(player, 10, function(o) return o.bcc and not o.isPet end) > 0 then return end
  end
  -- local canRestun = target.stunDR >= 0.25 and maimReady--(maimReady or warstomp.cd == 0)
  -- local MeldReady = player.race == "Night Elf" and meld.cd == 0
  -- local canMeldRestun = target.stunDR >= 0.25 and MeldReady and (target.debuff(163505) or target.debuff(203123)) and target.stunRemains < rake.gcd

  -- if MeldReady and canMeldRestun then
  --   if rake:Castable(target) and target.meleeRange then
  --     if meld:Cast({stopMoving = true}) then
  --       blink.alert(colors.druid.. "Meld Restun", meld.id)
  --       if player.buff(58984) then 
  --         rake:Cast(target, { alwaysFace=true })
  --       end
  --     end
  --   end
  -- end

  if target.enemy 
  and player.buffFrom({prowl.id, meld.id}) 
  and player.stealth then

    return spell:Cast(target, { face = true })

  end

  --meld stun
  -- if not player.race == "Night Elf" and meld.cd == 0 then return end

  -- if target.enemy 
  -- and (player.buff(5215) or player.buff(58984))
  -- and target.stunRemains < 1.2 
  -- and target.stunRemains >= 0.1 then
  --   if player.stealth then 
  --     return rake:Cast(target, {face = true}) and alert(colors.yellow .. "Rake ReStun", rake.id)
  --   else
  --     return meld:CastAlert({stopMoving = true})
  --   end
  -- end

end)

rake:Callback("maintain", function(spell)
  if not target.exists then return end
  if player.hasTalent(391700) then
   if blink.enemies.around(player, 10, function(o) return o.bcc and not o.isPet end) > 0 then return end
  end

  if target.debuffRemains(155722) > 4 then return end
  if player.cp >= 5 then return end

  return spell:Cast(target, { face = true })  

end)

rip:Callback("maintain", function(spell)
  if not target.exists then return end
  if player.hasTalent(primal.id) then return end
  if (blink.MacrosQueued["maim target"]
  or blink.MacrosQueued["maim focus"]
  or blink.MacrosQueued["maim arena1"]
  or blink.MacrosQueued["maim arena2"]
  or blink.MacrosQueued["maim arena3"]) then return end 

  if target.hp < 30 then return end
  if target.debuffRemains(spell.id) > 5 then return end
  if target.debuffRemains(spell.id) <= 4
  and player.cp > 2 then 
    return spell:Cast(target, { face = true })
  end

end)

primal:Callback("maintain", function(spell)
  if not target.exists then return end
  if enemies.around(player, 14, function(o) return o.bcc and not o.isPet end) > 0 then return end
  if not target.enemy then return end
  if not player.hasTalent(primal.id) then return end
  if (blink.MacrosQueued["maim target"]
  or blink.MacrosQueued["maim focus"]
  or blink.MacrosQueued["maim arena1"]
  or blink.MacrosQueued["maim arena2"]
  or blink.MacrosQueued["maim arena3"]) then return end 

  if target.hp < 30 and saved.BiteExecute then return end
  if target.debuffRemains(391356) > 4 then return end
  if player.cp > 2 then 
    return spell:Cast(target, { face = true })
  end

end)

bite:Callback("finisher", function(spell)
  if not target.exists then return end
  if not target.enemy then return end
  if target.immunePhysicalDamage then return end
  if (blink.MacrosQueued["maim target"]
  or blink.MacrosQueued["maim focus"]
  or blink.MacrosQueued["maim arena1"]
  or blink.MacrosQueued["maim arena2"]
  or blink.MacrosQueued["maim arena3"]) then return end 

  if player.hasTalent(primal.id) then

    if player.buff(391882) then 
      spell:Cast(target, { face = true }) 
    end

    if target.debuffRemains(1079) > 5 
    and player.cp >= 5 then 
      spell:Cast(target, { face = true }) 
    end

    if target.hp < 35 
    and player.cp >= 4 
    and target.meleeRange then 

      -- tiger's fury
      if tigersfury:Cast() then
        alert("Tiger's Fury", tigersfury.id)
      end

      if not saved.BiteExecute then return end

      -- bite
      if spell:Cast(enemy, { face = true }) then
        alert("Bite |cFFff7869(Execute)", bite.id)
      end

    else

      if target.debuffRemains(391356) <= 2 and target.hp > 30 then return end
        
      if not player.buff(391882) and player.cp < 5 then return end

      if not saved.BiteExecute then return end  

      return spell:Cast(target, { face = true })  

    end
  end

  if not player.hasTalent(primal.id) then
    if not target.exists then return end
    if target.hp < 35 
    and player.cp >= 4 
    and target.meleeRange then 
      -- tiger's fury
      if tigersfury:Cast() then
        alert("Tiger's Fury", tigersfury.id)
      end
      -- bite
      if spell:Cast(enemy, {alwaysFace = true}) then
        alert("Bite |cFFff7869(Execute)", bite.id)
        return true
      end

    else

      if target.debuffRemains(1079) <= 2 and target.hp > 30 then return end
        
      if not player.buff(391882) and player.cp < 5 then return end

      return spell:Cast(target, { face = true })  

    end
  end

end)

-- bite:Callback("execute", function(spell)
--   if target.immunePhysicalDamage then return end
--   -- bite execute 
--   if form == "cat" and not player.stealth then
--     blink.enemies.loop(function(enemy)
--       if enemy.hpa and enemy.isPlayer then
--         local melee = enemy.distliteral < 9
--         if enemy.hpa < bite.damage + bin(not melee) * 1.03 then
--           if melee then
--             -- tiger's fury
--             if tigersfury:Cast() then
--               alert("Tiger's Fury", tigersfury.id)
--             end
--             -- bite
--             if bite:Cast(enemy, {alwaysFace = true}) then
--               alert("Bite |cFFff7869(Execute)", bite.id)
--               return true
--             end
--           else
--             -- flying
--             if player.speed >= 15 and player.movingToward(enemy) then
--               return true
--             end
--             -- leap if out of rang
--             if not enemy.bcc then
--               if cp > 3 and frenzy.cd < 44 and charge.cat:Cast(enemy, {alwaysFace = true}) then
--                 alert("Leap to " .. enemy.class .. " |cFFff7869(Execute)", charge.cat.id)
--                 return true
--               end
--             end
--           end
--         end
--       end
--     end)
--   end

-- end)


slash:Callback("getcp", function(spell)
  if not target.exists then return end
  if target.immunePhysicalDamage then return end
  if player.cp >= 5 then return end
  if enemies.around(player, 10, function(o) return o.bcc and not o.isPet end) > 0 then return end

  if player.combat 
  and target.distliteral <= 8
  and not player.stealthed then
    return spell:Cast()
  end  

end)

shred:Callback("getcp", function(spell)
  if not target.exists then return end
  if player.cp >= 5 then return end

  if player.energy >= 40 
  and target.meleeRange then 
    spell:Cast(target, { face = true })
  end

end)

moonfire:Callback("maintain", function(spell)
  if not target.exists then return end
  if not player.hasTalent(155580) then return end
  if moonfire.used(2) then return end
  if not player.combat then return end
  if target.distliteral < 11 and player.cp >= 5 then return end

  if target.debuffRemains(155625, "player") < 3 
  or target.distliteral > 11 then
    return spell:Cast(target)
  end

end)

thrash:Callback("maintain", function(spell)
  if blink.enemies.around(player, 12, function(o) return o.bcc and not o.isPet and not o.isPet end) > 0 then return end
  if not player.combat then return end
  if target.distliteral > 10 then return end
  if player.cp >= 5 then return end
  if target.immunePhysicalDamage then return end
  if target.dbr(405233, "player") > 5 then return end

  return spell:Cast()

end)


frenzy:Callback(function(spell)
  if not target.exists then return end
  if (player.stealth or player.buff(58984) or target.distliteral > 11) then return end

  if player.cp <= 3 and target.stunned then 
    if spell:Cast(target) then
      blink.alert("Feral Frenzy", spell.id)
    end
  else
    if blink.MacrosQueued["maim target"] 
    and player.cp < 3 
    and not target.immunePhysicalDamage then
      spell:Cast(target)
    end
  end

end)

swarm:Callback(function(spell)
  if not target.exists then return end
  if not player.hasTalent(391888) then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if target.debuff(391889, "player") then return end
  if (player.stealth or player.buff(58984)) then return end
  if (target.immuneMagicDamage or target.immunePhysicalDamage) then return end

  if target.enemy 
  and frenzy.used(3) 
  or rip.used(3)
  or primal.used(3)
  or target.stunned then 
    return spell:Cast(target)
  end

end)





Instincts:Callback("emergency", function(spell)

  if not saved.autoInstincts then return end

  local count, _, _, cds = player.v2attackers()
  local threshold = 12.5
  threshold = threshold + count * 5.5
  threshold = threshold + cds * 7.5
  threshold = threshold * (0.8 + bin(not healer.exists or healer.cc and healer.ccr > 1) * 1.25)
  threshold = threshold * saved.InstinctsSensitivity

  if player.hp < threshold then
    return spell:Cast() and alert("Instincts " .. colors.red.."[Danger]", spell.id)
  end

end)

renewal:Callback("emergency", function(spell)

  if not saved.autoRenewal then return end

  local count, _, _, cds = player.v2attackers()
  local threshold = 12.5
  threshold = threshold + count * 5.5
  threshold = threshold + cds * 7.5
  threshold = threshold * (0.8 + bin(not healer.exists or healer.cc and healer.ccr > 1) * 1.25)
  threshold = threshold * saved.RenewalSensitivity

  if player.hp < threshold then
    return spell:Cast() and alert("Renewal " .. colors.red.."[Danger]", spell.id)
  end

end)


cat:Callback(function(spell)

  if player.buff(cat.id) then return end

  if swiftmend.used(2) then 
    return spell:CastAlert()
  end

end)


--old stuff



local hots = {774, 8936, 48438}
local function hasHot(obj)
  return obj.buffFrom(hots, player)
end

swiftmend:Callback(function(spell)
  if player.cc then return end
  if form == "bear" then return end
  if spell.cd - blink.gcdRemains > 0 then return end
  if not player.hasTalent(18562) then return end
  local energyDeficit = player.energyMax - player.energy

  local weight = 5
  weight = weight + (player.energy < 40 and energyDeficit / 2 or 0)
  weight = weight + bin(player.rooted and not target.meleeRange) * 60
  weight = weight + bin(not form) * 5
  weight = weight + bin(not healer.exists or healer.cc or not healer.los or healer.dist and healer.dist > 40) * 45
  if not target.enemy or target.predictDist(0.25) > 8 or target.physicalDamageImmunityRemains > blink.gcd then
      weight = weight + 35
      weight = weight + bin(player.slowed) * 30
  end
  if target.exists and target.enemy then
    if player.movingAwayFrom(target, { duration = 0.25, angle = 80 }) then
        weight = weight + 30
    elseif target.stun then
        weight = weight - 35
    end
  end

  --dont use it when target low cmon !
  if player.buff(cat.id) and target.hp < 30 then return end
    
  -- ... baddd to use after just using frenzy/TF
  weight = weight - bin(frenzy.cd > 43 or tigersfury.cd > 27) * 40

  -- no swiftmend w/ games
  local mgr = player.mgr
  if mgr > 2500 then return false end

  -- enemy cds up?
  -- friend immune to damage? -weight
  blink.fullGroup.sort(function(x,y) return x.hp and y.hp and x.hp < y.hp end)
  fgroup.loop(function(member)
    if not member.exists then return end
    if member.distliteral > 40 then return end
    if not member.los then return end
    if not hasHot(member) then return end
    if not member.enemy and hasHot(member) then
      local weight_adjusted = weight
      weight_adjusted = weight_adjusted - bin(member.debuff("Sharpen Blade")) * 60
      weight_adjusted = weight_adjusted + bin(healer.isUnit(member)) * 15
      weight_adjusted = weight_adjusted + bin(member.stunned) * 20
      weight_adjusted = max(25, min(85, 30 + weight_adjusted))
      if member.hp < weight_adjusted and spell:Cast(member) then
        blink.alert("Swiftmend " .. member.class .. " (" .. math.floor(member.hp) .. "% HP)", spell.id)
      end
    end
  end)

end)



thorns:Callback(function(spell)
  if spell.cd > 0 then return end
  if saved.AutoThorns then
    blink.fullGroup.sort(function(x,y) return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp end)
    fgroup.loop(function(member)
      if not member.los then return end
      if member.distliteral > 40 then return end
      if member.visible and member.attackers2 > 0 and member.hp < 88 then
        if spell:Cast(member) then
          blink.alert("Thorns " .. member.class .. " [Danger]", spell.id)
        end
      end
    end)
  end
end)

decurse:Callback(function(spell)
  if spell.cd >= 1 then return end
  if player.buff(5487) then return end
  fgroup.loop(function(member)
    local has = member.debuffFrom(DecurseThem)
    if not has then return end
    if member.distliteral > 40 then return end

    local str = ""
    for i, id in ipairs(has) do
      if i == #has then
        str = str .. GetSpellInfo(id)
      else
        str = str .. GetSpellInfo(id) .. ","
      end
    end  
    --blink.alert("Dispel " .. member.class .. " [" .. GetSpellInfo(has) .. "]", spell.id)
    return spell:Cast(member) and alert("Dispel "..colors.yellow..str, spell.id)
  end)

end)

stampedingroar:Callback("gapclose", function(spell)

  if player.buff(dash.id) then return end
  if dash.used(2) then return end
  if dash.cd == 0 then return end

  if saved.AutoStampedingRoar then
    if form 
    and validPhysical 
    and player.movingToward(target, { duration = 0.2 }) then
      if target.predictDist(0.35) > 5 then
        return spell:Cast() and alert("Stampeding Roar (Gapclose)", spell.id)
      end
    end
  end

end)



regrowth:Callback(function(spell, key)

  local psr = player.buffRemains(69369)
  if psr == 0 then return end

  blink.fullGroup.sort(function(x,y) return x.hp and y.hp and x.hp < y.hp end)

  -- high prio
  if key == 1 then
    local highPrioHP = 60 + bin(psr < gcd) * 20 + ((12 - psr) * 2.5) + bin(swiftmend.cd < gcd) * 20
    fgroup.loop(function(member)
      if member.distliteral > 40 then return end
      if not member.los then return end
      if member.hp and member.hp <= highPrioHP + (member.attackers * 7) and not member.enemy then
          if spell:Cast(member) then return true end
      end
    end)
  -- low prio
  elseif key == 2 then
    local lowPrioHP = min(90, 65 + bin(psr < gcd) * 13 + ((12 - psr) * 2) + bin(swiftmend.cd < gcd) * 10)
    fgroup.loop(function(member)
      if member.distliteral > 40 then return end
      if not member.los then return end
      if member.hp and member.hp <= lowPrioHP + (member.attackers * 7) and not member.enemy then
        if spell:Cast(member) then return true end
      end
    end)
  end

end)

local function SettingsCheck(settingsVar, castId, channelId)
  for k, v in pairs(settingsVar) do
    if k == castId and v == true then return true end
    if k == channelId and v == true then return true end
    if type(v) == "table" then
      for _, id in ipairs(v) do
        if castId == id then return true end
        if channelId == id then return true end
      end
    end
  end
end

skullbash:Callback("interrupt", function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end
  if player.stealthed then return end

  blink.enemies.within(30).loop(function(enemy)
    -- enemy must be casting or channeling
    local cast, channel = enemy.casting, enemy.channeling
    if not cast and not channel then return end

    -- shift hibernate / scare beast if we can't kick it
    if form then
      if enemy.casting 
      and tContains(ShapeshiftIT, (enemy.casting))then
        if enemy.castTarget.isUnit(player) then
          if enemy.dist > 12 or enemy.castTimeLeft < blink.buffer + blink.latency + 0.1 then
            if enemy.castTimeLeft < blink.buffer + blink.latency + 0.15 then
              alert("|cFFfa8ea8Cancel Form|r |cFF9ed0ff[" .. enemy.casting or enemy.channeling .. "]", feral[form].id)
              blink.call("CancelShapeshiftForm")
            end
          end
        end
      end
    end

    -- shift hex/sheep cast
    if not form then
      if enemy.casting 
      and tContains(ShapeshiftIT, (enemy.casting)) 
      and enemy.castRemains < blink.buffer + blink.latency then
        if player.casting and player.castRemains > enemy.castRemains then
          blink.call("SpellStopCasting")
        end
        if cat:Cast() then
          alert("Cat Form [Shift " .. enemy.casting or enemy.channeling .. "]", cat.id)
        end
      end
    end


    -- must not be immune to interrupts
    if cast and enemy.castint or channel and enemy.channelint then return end
    if enemy.buff(377362) then return end
    if not enemy.los then return end
    if enemy.dist > 30 then return end

    --kick anything in PVE 
    if saved.KickPVE 
    and blink.instancetype ~= "pvp"
    and (enemy.casting or enemy.channel)
    and not enemy.isPlayer 
    and not blink.arena then  

      sr.kickDelay(function()
        if not enemy.casting or enemy.channeling then return end

        if spell:Cast(enemy, {face = true}) then 
          if not saved.streamingMode then
            alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
          end
        end
      end)

    end

    if not enemy.isPlayer then return end

    -- fast MD kick pls
    if saved.KickFastMD then
      if enemy.casting 
      and enemy.castint == false 
      and enemy.castRemains < blink.buffer + blink.latency + enemy.distance * 0.0155 + 0.09 
      and (enemy.castID == 341167 
      or enemy.castID == 32375) then

        if spell:Cast(enemy, {face = true}) then 
          if not saved.streamingMode then
            alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
          end
        end
      end
    end

    --Kicking Heals from GUI list "ONLY IF HE IS ENEMY HEALER"
    if enemy.hp <= saved.kickhealsunder 
    or target.hp <= saved.kickhealsunder
    and enemy.isHealer then
      if SettingsCheck(saved.kickHealinglist, enemy.castingid) 
      or SettingsCheck(saved.kickHealinglist, enemy.channelId) then

        sr.kickDelay(function()
          if not enemy.casting or enemy.channeling then return end

          if spell:Cast(enemy, {face = true}) then 
            if not saved.streamingMode then
              alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
            end
          end
        end)

      end       
    end   
    
    --Kicking Dangerous Casts
    if SettingsCheck(saved.kickDangerouslist, enemy.castingid) 
    or SettingsCheck(saved.kickDangerouslist, enemy.channelId) then

      sr.kickDelay(function()
        if not enemy.casting or enemy.channeling then return end

        if spell:Cast(enemy, {face = true}) then 
          if not saved.streamingMode then
            alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
          end
        end
      end)

    end 

    --Kicking CC from GUI List
    if not saved.TripleDR 
    and not saved.DontKickAvoidableCC then
      if SettingsCheck(saved.kickCClist, enemy.castingid) 
      or SettingsCheck(saved.kickCClist, enemy.channelId) then

        if sr.NoNeedToKickThis(enemy) then return end

        sr.kickDelay(function()
          if not enemy.casting or enemy.channeling then return end

          if spell:Cast(enemy, {face = true}) then 
            if not saved.streamingMode then
              alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
            end
          end
        end)
      end
    end

    --Kick DPS Under
    if enemy.hp <= saved.kickdpsunder
    and not enemy.isHealer then

      sr.kickDelay(function()
        if not enemy.casting or enemy.channeling then return end

        if spell:Cast(enemy, {face = true}) then 
          if not saved.streamingMode then
            alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
          end
        end
      end)   

    end   

    --DONT KICK CC IF HEALER CAN DEATH IT
    if saved.DontKickAvoidableCC 
    and enemy.castTarget.isUnit(healer)
    and healer.incapDR >= 0.5
    and healer.class2 == "PRIEST"
    and (healer.cc or healer.cooldown(32379) >= 1) then
      if SettingsCheck(saved.kickCClist, enemy.castingid) 
      or SettingsCheck(saved.kickCClist, enemy.channelId)
      and tContains(DontKickAvoidableCCTable, (enemy.casting or enemy.channeling)) then

        if sr.NoNeedToKickThis(enemy) then return end

        sr.kickDelay(function()
          if not enemy.casting or enemy.channeling then return end
  
          if spell:Cast(enemy, {face = true}) then 
            if not saved.streamingMode then
              alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
            end
          end
        end) 

      end 
    end 

    --Dont Kick Triple DR
    if saved.TripleDR then

      if tContains(listOfHexAndPolys, enemy.casting)
      and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) 
      and (healer.incapDR >= 0.5 or player.incapDR >= 0.5) and not saved.DontKickAvoidableCC then
        if SettingsCheck(saved.kickCClist, enemy.castingid) 
        or SettingsCheck(saved.kickCClist, enemy.channelId) then

          if sr.NoNeedToKickThis(enemy) then return end

          sr.kickDelay(function()
            if not enemy.casting or enemy.channeling then return end
    
            if spell:Cast(enemy, {face = true}) then 
              if not saved.streamingMode then
                alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
              end
            end
          end) 

        end
      elseif enemy.castID == 5782 --Fear
      and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) 
      and (healer.disorientDR >= 0.5 or player.disorientDR >= 0.5)  then
        if SettingsCheck(saved.kickCClist, enemy.castingid) 
        or SettingsCheck(saved.kickCClist, enemy.channelId) then

          if sr.NoNeedToKickThis(enemy) then return end

          sr.kickDelay(function()
            if not enemy.casting or enemy.channeling then return end
    
            if spell:Cast(enemy, {face = true}) then 
              if not saved.streamingMode then
                alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
              end
            end
          end) 

        end
      elseif enemy.castID == 20066 --repentance 
      and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) 
      and (healer.incapDR >= 0.5 or player.incapDR >= 0.5)  then
        if SettingsCheck(saved.kickCClist, enemy.castingid) 
        or SettingsCheck(saved.kickCClist, enemy.channelId) then

          if sr.NoNeedToKickThis(enemy) then return end

          sr.kickDelay(function()
            if not enemy.casting or enemy.channeling then return end
    
            if spell:Cast(enemy, {face = true}) then 
              if not saved.streamingMode then
                alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
              end
            end
          end) 
        end
      elseif enemy.castID == 360806 --Sleepwalk
      and (enemy.castTarget.isUnit(healer) or enemy.castTarget.isUnit(player)) then
        if SettingsCheck(saved.kickCClist, enemy.castingid) 
        or SettingsCheck(saved.kickCClist, enemy.channelId) then

          if sr.NoNeedToKickThis(enemy) then return end

          sr.kickDelay(function()
            if not enemy.casting or enemy.channeling then return end
    
            if spell:Cast(enemy, {face = true}) then 
              if not saved.streamingMode then
                alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
              end
            end
          end) 

        end
      elseif SettingsCheck(saved.kickCClist, enemy.castingid) or SettingsCheck(saved.kickCClist, enemy.channelId) then

        if sr.NoNeedToKickThis(enemy) then return end

        sr.kickDelay(function()
          if not enemy.casting or enemy.channeling then return end
  
          if spell:Cast(enemy, {face = true}) then 
            if not saved.streamingMode then
              alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
            end
          end
        end) 
      end     
    end    


    -- HybridsKicks
    if saved.HybridsKick
    and enemy.hp <= 80 
    and enemy.buffsFrom(ImmuneKick) == 0
    and not enemy.isHealer then
      if tContains(KickHealing, (enemy.casting)) then
        sr.kickDelay(function()
          if not enemy.casting or enemy.channeling then return end

          if spell:Cast(enemy, {face = true}) then 
            if not saved.streamingMode then
              alert("Skull Bash " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
            end
          end
        end) 
      end   
    end
  end)
end)

skullbash:Callback("tyrants", function(spell)
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
    if tyrant.dist > 30 then return end

    if tyrant.casting then

      sr.kickDelay(function()
        if not tyrant.casting or tyrant.channeling then return end

        if spell:Cast(tyrant, {face = true}) then 
          if not saved.streamingMode then
            alert("Skull Bash " .. "|cFFf7f25c[" .. (tyrant.casting or tyrant.channel) .. "]", spell.id)  
          end
        end
      end) 
      
    end

  end)

end)

skullbash:Callback("seduction", function(spell)
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
      if EnemyPet.dist > 30 then return end
      if not EnemyPet.channelID == 6358 then return end
        
      if (EnemyPet.casting and EnemyPet.castTimeComplete > delay.now 
      or EnemyPet.channel and EnemyPet.channelTimeComplete > delay.now) then
        if SettingsCheck(saved.kickCClist, EnemyPet.castingid) 
        or SettingsCheck(saved.kickCClist, EnemyPet.channelId) then

          sr.kickDelay(function()
            if not EnemyPet.casting or EnemyPet.channeling then return end
    
            if spell:Cast(EnemyPet, {face = true}) then 
              if not saved.streamingMode then
                alert("Skull Bash " .. "|cFFf7f25c[" .. (EnemyPet.casting or EnemyPet.channel) .. "]", spell.id)  
              end
            end
          end)

        end
      end
    end)
  end
end)


--sit bear abit then back cat
function bear:Hold(callback)
  if bear:Cast() then
    blink.alert("Holding Bear", bear.id)
    C_Timer.After(7.1, function()
      cat:Cast()
    end)
  end
end

-- regeneration:Callback(function(spell)
--   if player.combat then
--     blink.enemies.loop(function(enemy)
--       if (player.hp <= saved.FrenziedRegeneration) 
--       and (enemy.cds and enemy.target.isUnit(player) and player.hp < 70
--       or enemy.target.isUnit(player) and player.hp <= saved.FrenziedRegeneration) then
--         if regeneration.cd == 0 and not player.debuff(375901) then 
--           if player.buff(5487) then
--             if spell:Cast() then
--                 blink.alert("Frenzied Regeneration", spell.id)
--             end
--           elseif enemy.cds 
--           and enemy.target.isUnit(player) 
--           and player.hp < 70 or enemy.target.isUnit(player) 
--           and player.hp < 70 
--           and regeneration.cd == 0 and not player.buff(5487) then
--             bear:Hold()
--           end	
--         end
--       end
--     end)
--   end
-- end)
regeneration:Callback("emergency", function(spell)
  if not saved.FrenziedRegeneration then return end
  --if regeneration.cd > 0 then return blink.print("regen on cd") end
  local count, _, _, cds = player.v2attackers()
  local threshold = 12.5
  threshold = threshold + count * 5.5
  threshold = threshold + cds * 7.5
  threshold = threshold * (0.8 + bin(not healer.exists or healer.cc and healer.ccr > 1) * 1.25)
  threshold = threshold * saved.FrenziedRegenerationSensitivity

  if player.hp < threshold and player.combat then
    if not player.buff(5487) then 
      bear:Hold()
    else
      return spell:Cast() and alert("Frenzied Regeneration " .. colors.red.."[Danger]", spell.id)
    end
  end

end)

ironfur:Callback(function(spell)
  if player.combat 
  and player.buffRemains(192081) < 0.5 then
    if player.buff(5487) 
    and player.rage >= 40 
    and regeneration.cd > 0 
    and regeneration.cooldown > ironfur.gcd then
      spell:Cast()
    end 
  end	
end)

Bearthrash:Callback(function(spell)
  if not blink.arena then return end
  if not target.enemy then return end
  if blink.enemies.around(player, 12, function(o) return o.bcc and not o.isPet end) > 0 then return end
  if player.combat then
    if player.buff(5487) 
    and player.rage < 40 
    and regeneration.cooldown > Bearthrash.gcd then
      spell:Cast()
    end
  end
end)


local function shouldClone(unit)
  local cloneCompletionTime = clone.castTime + buffer + latency - tickRate - 0.08
  if unit.exists 
  and unit.enemy
  and unit.debuffRemains(33786) < cloneCompletionTime
  and (unit.disorientDR >= 0.5 or unit.disorientDRR > 5 or unit.disorientDRR < cloneCompletionTime) then
    return true
  end
end

clone:Callback(function(spell, key)

  if not player.hasTalent(clone.id) then return end

  if blink.MacrosQueued["clone target"] then
    if shouldClone(target) then
      if spell:Cast(target) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFCyclone [" .. target.classString .. "]", spell.id)
      end
    end
  elseif player.castID == clone.id and player.castTarget.isUnit(target) and target.buffFrom({23920, 212295, 8178, 408558}) then
    blink.call("SpellStopCasting")
  end

  if blink.MacrosQueued["clone focus"] then
    if shouldClone(focus) then
      if spell:Cast(focus) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFCyclone [" .. focus.classString .. "]", spell.id)
      end
    end
  elseif player.castID == clone.id and player.castTarget.isUnit(focus) and focus.buffFrom({23920, 212295, 8178, 408558}) then
    blink.call("SpellStopCasting")
  end

  if blink.MacrosQueued["clone arena1"] then
    if shouldClone(arena1) then
      if spell:Cast(arena1) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFCyclone [" .. arena1.classString .. "]", spell.id)
      end
    end
  elseif player.castID == clone.id and player.castTarget.isUnit(arena1) and arena1.buffFrom({23920, 212295, 8178, 408558}) then
    blink.call("SpellStopCasting")
  end

  if blink.MacrosQueued["clone arena2"] then
    if shouldClone(arena2) then
      if spell:Cast(arena2) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFCyclone [" .. arena2.classString .. "]", spell.id)
      end
    end
  elseif player.castID == clone.id and player.castTarget.isUnit(arena2) and arena2.buffFrom({23920, 212295, 8178, 408558}) then
    blink.call("SpellStopCasting")
  end
    
  if blink.MacrosQueued["clone arena3"] then
    if shouldClone(arena3) then
      if spell:Cast(arena3) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFCyclone [" .. arena3.classString .. "]", spell.id)
      end
    end
  elseif player.castID == clone.id and player.castTarget.isUnit(arena3) and arena3.buffFrom({23920, 212295, 8178, 408558}) then
    blink.call("SpellStopCasting")
  end

  if blink.MacrosQueued["clone enemyhealer"] then
    if shouldClone(enemyHealer) then
      if spell:Cast(enemyHealer) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFCyclone [" .. enemyHealer.classString .. "]", spell.id)
      end
    end
  elseif player.castID == clone.id and player.castTarget.isUnit(enemyHealer) and enemyHealer.buffFrom({23920, 212295, 8178, 408558}) then
    blink.call("SpellStopCasting")
  end

end)

-- Maiming :P 
local function shouldMaim(unit)
  local dodgeFromFront = {37683, 5277, 118038, 199754, 198589, 212800}
  if unit.exists 
  and unit.enemy
  and unit.buffsFrom(dodgeFromFront) == 0
  and unit.buffsFrom(ImmuneToDruidCC) == 0
  and unit.stunDR >= 0.5
  and not unit.immuneStuns or unit.immunePhysicalEffects then
    return true
  end
end

maim:Callback(function(spell)
  if spell.cd > 3 then return end

  if (blink.MacrosQueued["maim target"]
  or blink.MacrosQueued["maim focus"]
  or blink.MacrosQueued["maim arena1"]
  or blink.MacrosQueued["maim arena2"]
  or blink.MacrosQueued["maim arena3"]) 
  and player.cp == 5 then
      if blink.MacrosQueued["maim target"] then
        if shouldMaim(target) then
          if target.stunRemains > 1 then return end
          if spell:Cast(target, { face = true }) then
            alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaim [" .. target.classString .. "]", spell.id)
          end
        end
      elseif blink.MacrosQueued["maim focus"] then
        if shouldMaim(focus) then
          if focus.stunRemains > 1 then return end
          if spell:Cast(focus, { face = true }) then
            alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaim [" .. focus.classString .. "]", spell.id)
          end
        end  
      elseif blink.MacrosQueued["maim arena1"] then
        if shouldMaim(arena1) then
          if arena1.stunRemains > 1 then return end
          if spell:Cast(arena1, { face = true }) then
            alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaim [" .. arena1.classString .. "]", spell.id)
          end
        end  
      elseif blink.MacrosQueued["maim arena2"] then
        if shouldMaim(arena2) then
          if arena2.stunRemains > 1 then return end
          if spell:Cast(arena2, { face = true }) then
            alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaim [" .. arena2.classString .. "]", spell.id)
          end
        end  
      elseif blink.MacrosQueued["maim arena3"] then
        if shouldMaim(arena3) then
          if arena3.stunRemains > 1 then return end
          if spell:Cast(arena3, { face = true }) then
            alert("|cFFf7f25c[Manual]: |cFFFFFFFFMaim [" .. arena3.classString .. "]", spell.id)
          end
        end  
      end
  elseif (blink.MacrosQueued["maim target"]
  or blink.MacrosQueued["maim focus"]
  or blink.MacrosQueued["maim arena1"]
  or blink.MacrosQueued["maim arena2"]
  or blink.MacrosQueued["maim arena3"])
  and player.cp < 3 then
    if frenzy:Castable(target) then
      frenzy:Cast(target)
    end
  end

end)

--Bash ing :P
local function shouldBash(unit)
  local dodgeFromFront = {37683, 5277, 118038, 199754, 198589, 212800}
  if unit.exists 
  and unit.enemy
  and unit.buffsFrom(dodgeFromFront) == 0
  and unit.buffsFrom(ImmuneToDruidCC) == 0
  and unit.stunDR >= 0.5
  and not unit.immuneStuns or unit.immunePhysicalEffects then
    return true
  end
end

bash:Callback(function(spell)
  
  local dodgeFromFront = {37683, 5277, 118038, 199754, 198589, 212800}

  if blink.MacrosQueued["bash target"] then
      if shouldBash(target) then
          if spell:Cast(target, { alwaysFace=true }) then
              alert("|cFFf7f25c[Manual]: |cFFFFFFFFMighty Bash [" .. target.classString .. "]", spell.id)
          end
      end
  elseif blink.MacrosQueued["bash focus"] then
      if shouldBash(focus) then
          if spell:Cast(focus, { alwaysFace=true }) then
              alert("|cFFf7f25c[Manual]: |cFFFFFFFFMighty Bash [" .. focus.classString .. "]", spell.id)
          end
      end  
  elseif blink.MacrosQueued["bash arena1"] then
      if shouldBash(arena1) then
          if spell:Cast(arena1, { alwaysFace=true }) then
              alert("|cFFf7f25c[Manual]: |cFFFFFFFFMighty Bash [" .. arena1.classString .. "]", spell.id)
          end
      end  
  elseif blink.MacrosQueued["bash arena2"] then
      if shouldBash(arena2) then
          if spell:Cast(arena2, { alwaysFace=true }) then
              alert("|cFFf7f25c[Manual]: |cFFFFFFFFMighty Bash [" .. arena2.classString .. "]", spell.id)
          end
      end  
  elseif blink.MacrosQueued["bash arena3"] then
      if shouldBash(arena3) then
          if spell:Cast(arena3, { alwaysFace=true }) then
              alert("|cFFf7f25c[Manual]: |cFFFFFFFFMighty Bash [" .. arena3.classString .. "]", spell.id)
          end
      end  
  end            
end)

bash:Callback("cc healer", function(spell)

  if not saved.bashHealer then return end
  if not enemyHealer.exists then return end
  if enemyHealer.immuneStuns then return end
  if enemyHealer.buffFrom(ImmuneToDruidCC) then return end


  if enemyHealer.sdr == 1
  and sr.lowest(enemies) < 70
  and enemyHealer.ccr <= 1
  and not enemyHealer.isUnit(target)
  and enemyHealer.v2attackers(true) == 0 then
    if enemyHealer.meleeRange then
      return spell:Cast(enemyHealer) and alert("Bash "..colors.yellow.."[Enemy Healer]", spell.id)
    end
  end
end)

maim:Callback("auto maim", function(spell, unit)

  if not saved.AutoMaim then return end
  if not target.exists then return end
  if target.buffFrom(ImmuneToDruidCC) then return end
  if not player.buff(768) then return end
  if not target.isPlayer then return end

  if enemyHealer.exists
  and enemyHealer.debuff(3355) 
  or enemyHealer.exists and enemyHealer.ccRemains > 3
  and target.sdr == 1 then

    if target.buffFrom(ImmuneToDruidCC) then return end
    if target.immuneStuns then return end

    if player.cp < 3 and frenzy.cd - blink.gcdRemains == 0 then 
      frenzy:Cast(target) 
    else 
      if player.cp >= 5 
      and spell:Cast(target, {face = true}) then
        alert("|cFFf7f25c[Auto]: |cFFFFFFFFMaim [" .. target.classString .. "]", spell.id)
      end
    end

  end

  -- if maim.cd < 0.25 
  -- and frenzy.cd < 0.25
  -- and player.cp == 5 
  -- and target.hp < 80 
  -- and (not enemyHealer.exists or enemyHealer.ccRemains > 3.5)
  -- and target.isPlayer then
  --   if target.sdr == 1 then
  --     if spell:Cast(target, {face = true}) then
  --       alert("|cFFf7f25c[Auto]: |cFFFFFFFFMaim [" .. target.classString .. "]", spell.id)
  --     end
  --   end
  -- end

  -- if skullbash.cd > 0 
  -- and maim.cd == 0 
  -- and player.cp == 5 
  -- and target.hp < 50 
  -- and target.isHealer 
  -- and target.isPlayer then
  --   if target.sdr == 1 then
  --     if spell:Cast(target, {face = true}) then
  --       alert("|cFFf7f25c[Auto]: |cFFFFFFFFMaim [" .. target.classString .. "]", spell.id)
  --     end
  --   end
  -- end

end)

root:Callback(function(spell, key)
  if saved.AutoRoot then 
      if not blink.arena then return end
      local psr = player.buffRemains(69369)

      if psr == 0 then return end
        
      local events = blink.events
      local h = enemyHealer
    
      if key == 10 and (psr > 0 or player.hasTalent(ursol.id)) then
          if target.enemy and target.hp < 65 + bin(not h.exists or h.isUnit(target) or h.cc) * 25 then
              for _, trigger in ipairs(sr.DefensiveAreaTriggers) do
                  local radius = trigger.radius
                  local remains = trigger.remains
                  if radius and remains and remains > 1.5 then
                      local x, y, z = trigger.position()
                      local tx, ty, tz = target.position()
                      local dist = blink.Distance(x,y,z,tx,ty,tz)
                      if dist > radius * 2 
                      and (target.movingTowards(trigger) == nil or dist < radius * 2 + 10 and target.movingAwayFrom(trigger) ~= nil)
                      and dist < 35 then
                          if target.rootDR >= 0.25
                          and target.ccr <= 0.3 
                          and target.rootRemains <= 0.2
                          and not target.immuneSlows
                          and psr > 0 then
                              if spell:Cast(target) then
                                  blink.alert({ message = "Root Target " .. " (Outside " .. trigger.name .. ")",
                                              texture = spell.id,
                                              duration = 2 })
                                  return true
                              end
                          else
                              if not target.rooted or target.hp < 55 + bin(not h.exists or h.cc) * 30 then
                                  -- edge cast away from thing
                                  if ursol:CastEdge(target, { 
                                      movePredTime = blink.buffer, 
                                      diameter = 8,
                                      distChecks = 12,
                                      range = 30, 
                                      sort = function(hi, lo)
                                          return aDist(hi.x, hi.y, hi.z, x, y, z) > aDist(lo.x, lo.y, lo.z, x, y, z)
                                      end
                                  }) then
                                      blink.alert({ message = "Ursol Target " .. " (Outside " .. trigger.name .. ")",
                                              texture = ursol.id,
                                              duration = 2 })
                                      return true
                                  end
                              end
                          end
                      end
                  end
              end
          end
      end

      if psr == 0 then return end

      -- root healer behind pillar
      if key == 1 then
          if target.enemy 
          and h.exists 
          and not h.isUnit(target)
          and (not h.losOf(target) or h.distanceTo(target) > 40)
          and h.rootDR >= 0.5 
          and h.ccr <= 2 
          and h.rootRemains < gcd 
          and not h.immuneSlows then
              if spell:Cast(h) then
                  blink.alert("Root Healer (Bad Position)", spell.id)
                  return true
              end
          end
      -- root on event (roll/disengage/felrush/leapshit/gap closers/openers)
      elseif key == 2 then

          local events = blink.events
          local time = blink.time
          -- root events 
          for key, event in ipairs(events.root) do
              if time <= event.expires then
                  if event.should() then
                      local obj = event.obj
                      if obj.rootDR >= 0.25
                      and obj.ccr <= 0.3
                      and obj.rootRemains < gcd
                      and not obj.immuneSlows then
                          if spell:Cast(obj) then
                              blink.alert("Root " .. obj.class .. " (" .. GetSpellInfo(event.reason) .. ")", spell.id)
                              return true
                          end
                      end
                  end
              else
                  events.root[key] = nil
              end
          end

      -- root out of link
      elseif key == 3 then
          local link = link
          if link then
              local x, y, z = link.position()
              blink.enemies.loop(function(enemy)
                  if enemy.distanceToLiteral(link) > 10 then
                      if enemy.rootDR >= 0.25
                      and not enemy.cc
                      and not enemy.rooted
                      and not enemy.immuneSlows then
                          if enemy.predictDistanceTo(link, gcd) <= 12 then
                              if spell:Cast(enemy) then
                                  blink.alert("Root " .. enemy.class .. " (Outside of Link)", spell.id)
                                  return true
                              end
                          end 
                      end
                  end
              end)
          end
      -- root off-targets out of LoS of their healer
      elseif key == 4 then
          if h.exists then
              blink.enemies.loop(function(enemy)
                  if not enemy.isUnit(h)
                  and (not enemy.isUnit(target) or enemy.hp < 50)
                  and (not h.losOf(enemy) or h.distanceTo(enemy) > 40)
                  and enemy.rootDR >= 0.5
                  and enemy.ccr <= 1
                  and enemy.rootRemains < gcd
                  and not enemy.immuneSlows then
                      if spell:Cast(enemy) then
                          blink.alert("Root " .. enemy.class .. " (Bad Position)", spell.id)
                          return true
                      end
                  end
              end)
          end
      -- root melee while kiting / cds
      elseif key == 5 then
          local cds = {
              
              "Seraphim",
              "Avenging Wrath",
              "Pillar of Frost",
              "Metamorphosis",
              "Coordinated Assault",
              "Bonedust Brew",
              "Shadow Dance",
              "Shadow Blades",
              "Vendetta",
              "Doom Winds",
              "Colossus Smash",
              "Avatar",
              "Recklessness",
              "Crusade",
              "Conqueror's Banner",
              "Flagellation",
              "Adrenaline Rush",
              "Divine Steed",
          }
          blink.enemies.loop(function(enemy)
              if blink.hasControl then 
                  fgroup.loop(function(homie)
                  --for _, homie in ipairs(blink.fullGroup) do

                      if (enemy.target.isUnit(player) 
                      or enemy.target.isUnit(homie))
                      --and (enemy.rootDR >= 0.25 or enemy.rootDRRemains > 16 and enemy.rootDR >= 0.25)--bkp
                      and enemy.rootDR >= 0.25
                      and enemy.ccr <= 1
                      and enemy.rootRemains < gcd
                      and not enemy.immuneSlows
                      --and (not enemy.isUnit(target) or enemy.dist > 6) then --bkp
                      and not enemy.isUnit(target) then 
                          local cdsUp = enemy.buffFrom(cds)
                          if cdsUp or player.movingAwayFrom(enemy, {duration = 0.9}) then
                              if spell:Cast(enemy) then
                                  --blink.alert("Rooting " .. enemy.class .. " (CD's Up)", spell.id)
                                  blink.alert("Root " .. enemy.class .. " (".. (cdsUp and GetSpellInfo(cdsUp[1]) or "Kiting") ..")", spell.id)
                                  return true
                              end
                          end
                      end
                  end)
              end
          end)
      -- root somebody kiting you low prio
      elseif key == 6 then
          if target.enemy
          and player.movingToward(target, { duration = 0.5 })
          and target.predictDist(0.5) > 7 then
              if target.rootDR >= 0.5 
              and target.ccr <= 0.5 
              and target.rootRemains < gcd
              and not target.immuneSlows then
                  if spell:Cast(target) then
                      blink.alert("Root " .. target.class .. " (Gapclose)", spell.id)
                      return true
                  end
              end
          end
      -- use on cd on melee or ranged/healer running at your team?
      -- FIXME: Add the ranged/healer stuff
      elseif key == 7 then
          local lowestFriend = 100
          blink.fullGroup.loop(function(member)
              if member.hp and member.hp < lowestFriend then
                  lowestFriend = member.hp
              end
          end)

          -- low friend
          if lowestFriend < 80 then
              -- does half root if ps falling off
              blink.enemies.loop(function(enemy)
                  if not enemy.isUnit(target)
                  and enemy.role == "melee"
                  and enemy.rootDR >= 0.25 - bin(psr < gcd) * 0.5
                  and enemy.ccr <= 0.5
                  and enemy.rootRemains < 0.5
                  and not enemy.immuneSlows then
                      if spell:Cast(enemy) then
                          blink.alert("Root " .. enemy.class .. " (Peel)", spell.id)
                          return true
                      end
                  end
              end)
          end
      -- root warrior with intervene on go
      elseif key == 8 then
          if h.exists and h.ccr > 3 then
              blink.enemies.loop(function(enemy)
                  if enemy.class2 == "WARRIOR" 
                  and not enemy.isUnit(target)
                  and enemy.cooldown(147833) <= gcd
                  and enemy.rootDR >= 0.25
                  and enemy.ccr <= 0.5
                  and enemy.rootRemains < 0.5
                  and not enemy.immuneSlows then
                      if spell:Cast(enemy) then
                          blink.alert("Root Warrior (Intervene Cover)", spell.id)
                          return true
                      end
                  end
              end)
          end
      -- root healer to help team get cc
      elseif key == 9 then
          if h.exists and not h.cc and not h.isUnit(target) then
              local ccHelpByClass = {
                  ["PRIEST"] = { 
                      condition = function(obj) return (h.ddr == 1 or h.ddrr <= 4.5) and obj.movingToward(h, { duration = 0.25 }) end,
                      alert = "(Help Priest Fear)" 
                  },
                  ["HUNTER"] = {
                      condition = function(obj) return (h.incapDR == 1 or h.idrr <= 4.5) and obj.movingToward(h, { duration = 0.1 }) and obj.predictDistanceTo(h, 0.3) < 22 end,
                      alert = "(Help Hunter Trap)"
                  },
                  ["MAGE"] = {
                      condition = function(obj) return (h.incapDR == 1 or h.idrr <= 4.5) and obj.predictDistanceTo(h, 0.4) <= 40 and obj.losOf(h) end,
                      alert = "(Help Mage Sheep)"
                  },
              }

              local shouldHelp
              for _, member in ipairs(blink.group) do
                  local class = member.class2
                  if class then
                      local found = ccHelpByClass[class]
                      if found then
                          local condition = found.condition
                          if condition(member) then
                              shouldHelp = found.alert
                              break
                          end
                      end
                  end
              end
              if shouldHelp
              and h.rootDR >= 0.25
              and h.rootRemains < 0.2
              and not h.immuneSlows then
                  if spell:Cast(h) then
                      blink.alert("Root " .. h.class .. " |cFF6eff61" .. shouldHelp)
                      return true
                  end
              end
          end
      elseif key == 11 then
          local ring = sr.friendlyRoF
          if not ring then return end
          if not target.enemy then return end
          if target.rootDR < 0.25
          or target.rooted
          or target.immuneSlows
          or target.cc then 
              return 
          end
          local x,y,z = ring.position()
          if not x then return end
          local tx,ty,tz = target.position()
          local dist = blink.Distance(x,y,z,tx,ty,tz)
          if dist <= 8 and dist >= 5 then
              if spell:Cast(target) then
                  blink.alert("Root " .. target.class .. " (Ring of Fire)", spell.id)
                  return true
              end
          end
      end
  end
end)



-- TRINKETS

-- racials
feral.racial = function()
  local racial = racials[player.race]
  if racial and racial() then
    blink.alert(racial.name, racial.id)
  end
end

-- Troll
racials.Troll:Callback(function(spell)
  if not saved.mode == "ON" or (not blink.burst) then return end
  if player.buffFrom({feral.tigersfury.id, feral.berserk.id}) then
    return spell:Cast()
  end
end)

--Badge
Trinkets.Badge:Update(function(item, key)
	if Trinkets.Badge.equipped then
    if target.enemy 
    and target.meleeRange
    and player.buffFrom({feral.tigersfury.id, feral.berserk.id, feral.incarnation.id}) then
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



--! TOTEM STOMPAGE !--
local function stomp(callback)
  return blink.totems.stomp(function(totem, uptime)
    local id = totem.id
    local app = importantTotems[id]
    if not saved.autoStomp then return end
    if not totem.id or not saved.totems[totem.id] then return end
    if app == false then return false end
    if type(app) == "function" and not app(totem, uptime) then return false end
    if type(app) == "number" then 
      if uptime < app then return false end
      return callback(totem, uptime)
    else
      if uptime < stompDelay.now and not totem.casting then return false end
      return callback(totem, uptime)
    end
  end)
end
-- moonfire stomp
moonfire:Callback("stomp", function(spell)
  if not player.hasTalent(155580) then return end
  if player.stealth then return end
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if totem.hp > 55 then return end
    if totem.id == 59764 then return end
    if player.distanceTo(totem) < 40 and player.losOf(totem) then
      if spell:Cast(totem) then
        return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
      end
    end
  end)
end)
--shred stomp
shred:Callback("stomp", function(spell)
  if player.stealth then return end
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if totem.distliteral > 8 then return end
    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)
--! END TOTEM STOMPAGE !--
