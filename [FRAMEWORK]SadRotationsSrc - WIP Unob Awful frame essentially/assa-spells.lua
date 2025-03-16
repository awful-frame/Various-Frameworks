local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local rogue, assa = sr.rogue, sr.rogue.assa
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local gcd, gcdRemains = blink.gcd, blink.gcdRemains
local gcd, buffer, latency, tickRate, gcdRemains = 0, 0, 0, 0, 0
local saved = sr.saved
local colors = blink.colors
local target, arena1, arena2, arena3 = blink.target, blink.arena1, blink.arena2, blink.arena3
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
local stompDelay = blink.delay(0.2, 0.5)

local currentSpec = GetSpecialization()
if not assa.ready then return end
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
  garrote = NS(703, { damage = "physical", bleed = true}),
  bane = NS(385627, { damage = "physical", bleed = true}),
  rupture = NS(1943, { damage = "physical", targeted = true, bleed = true }),
  shiv = NS(5938, { damage = "physical"}),
  swarm = NS(391888),
  bonespike = NS(385424, { damage = "physical", ranged = true, targeted = true }),
  mutilate = NS(1329, { effect = "physical" }),
  envenom = NS(32645, { effect = "physical" }),
  echoing = NS(385616, { effect = "physical", damage = "physical" }), 


  -- cc
  dismantle = NS(207777, { effect = "physical", cc = true }),
  blind = NS(2094, { effect = "physical", cc = true }),
  cheapShot = NS(1833, { effect = "physical", stun = true }),
  kidney = NS(408, { effect = "physical", stun = true }),
  kick = NS(1766),
  sap = rogue.sap,
  bomb = NS(212182),

  -- offensive
  mfd = NS(137619, { ignoreFacing = true }),
  deathmark = NS(360194, { ignoreFacing = true }),
  berserk = NS(106951, { ignoreGCD = true }),
  shadowDance = NS(185313, { ignoreGCD = true }),
  shadowBlades = NS(121471, { ignoreGCD = true }),
  step = NS(36554, { ignoreGCD = true }),
  sepsis = NS(385408, { damage = "physical", targeted = true, bleed = true }),
  secret = NS(280719, { damage = "physical" }),
  tea = NS(381623, { ignoreGCD = true }),
  symbols = NS(212283, { ignoreGCD = true }),

  -- defensive
  crimsonVial = NS(185311, { heal = true}),
  fient = NS(1966),
  evasion = NS(5277, { ignoreGCD = true }),

  -- misc
  slice = NS(315496),
  deadlyPoison = NS(2823),
  cripplingPoison = NS(3408),
  woundPoison = NS(8679),
  numbingPoison = NS(5761),
  stealth = NS(1784, { ignoreGCD = true }),
  sprint = NS(2983, { ignoreGCD = true }),
  meld = NS(58984, { ignoreGCD = true }),

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


}, assa, getfenv(1))

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
  [59764] = function(totem, uptime) return uptime < 8 or totem.hp < 55 end, --Healing Tide
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



----------------------------------------------------------------------------------------------------------------
--                                     End of Tables                                                          --
----------------------------------------------------------------------------------------------------------------
garrote:Callback("maintain", function(spell)
  if target.enemy 
  and player.stealth
  and target.stunDR == 1 or target.sdrr > 17 
  and target.stunRemains < 0.8 then
    return 
  end

  if target.debuffRemains(703) > 4 then return end
  if player.cp >= 5 then return end

  return spell:Cast(target, { face = true })  

end)

garrote:Callback("opener", function(spell)

  if target.debuffRemains(1330) <= 0.5
  or player.buffRemains(392403) <= 0.5 then 
    return spell:Cast(target, { face = true })  
  end

end)

rupture:Callback("maintain", function(spell)
  -- local cdsUp = player.buffFrom({185422, 121471})
  -- if cdsUp then return end
  if player.buff(1784) then return end

  if (blink.MacrosQueued["kidney target"]
  or blink.MacrosQueued["kidney focus"]
  or blink.MacrosQueued["kidney arena1"]
  or blink.MacrosQueued["kidney arena2"]
  or blink.MacrosQueued["kidney arena3"]
  or blink.MacrosQueued["kidney enemyhealer"]) then return end 

  if target.hp < 30 and target.isPlayer then return end
  if target.debuffRemains(spell.id) > 5 then return end
  if target.debuffRemains(spell.id) <= 3
  and player.cp > 2 then 
    return spell:Cast(target, { face = true })
  end
end)

envenom:Callback("finisher", function(spell)
  if target.immunePhysicalDamage then return end
  if (blink.MacrosQueued["kidney target"]
  or blink.MacrosQueued["kidney focus"]
  or blink.MacrosQueued["kidney arena1"]
  or blink.MacrosQueued["kidney arena2"]
  or blink.MacrosQueued["kidney arena3"]) then return end 

  if player.cp < 3  
  and target.hp <= 30 
  and target.meleeRange then

    if mfd:CastAlert() then 
      spell:Cast(target)
    end

  else

    if target.debuffRemains(rupture.id) <= 2 and target.hp > 30 then return end
      
    if player.cp < 5 then return end

    return spell:Cast(target, { face = true })  

  end

end)

mutilate:Callback("getcp", function(spell)
  local freeAmbush = player.buff(121153)
  if player.stealth then return end
  if player.cp >= 5 then return end

  if player.energy >= 40 or freeAmbush
  and target.meleeRange then 
    spell:Cast(target, { face = true })
  end

end)

bonespike:Callback("maintain", function(spell)
  if player.stealth then return end
  if bonespike.used(2) then return end
  if not player.combat then return end
  if target.distliteral < 11 and player.cp >= 5 then return end

  if target.debuffRemains(155625, "player") < 2
  or target.distliteral > 11 then
    return spell:Cast(target)
  end

end)

tea:Callback(function(spell)

  if spell.charges >= 2 and player.energy < 45 then 

  return spell:Cast()
    
  end

end)

tea:Callback("burst",function(spell)

  if player.energy > 100 then return end

  return spell:Cast()

end)

shadowDance:Callback("burst", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  return spell:CastAlert() 

end)

bane:Callback("burst", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end
  return spell:CastAlert() 

end)

slice:Callback("maintain", function(spell)
  if player.stealth then return end
  if player.buffRemains(spell.id) > 3 then return end
  if player.energy < 25 then return end
  if player.buff(185422) then return end

  return spell:Cast()
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

kick:Callback("interrupt", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local function canInterruptEnemy(unit)
    if not unit.casting and not unit.channeling then return false end
    if unit.castint or unit.channelint then return false end
    if unit.buff(377362) or not unit.los or not unit.meleeRange then return false end
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
          (tContains(listOfHexAndPolys, enemy.casting) and not saved.DontKickAvoidableCC) or
          (enemy.castID == 5782 or enemy.castID == 20066 or enemy.castID == 360806) and not sr.NoNeedToKickThis(enemy)
        )
      
        if shouldInterruptDRSafe then
          performInterrupt(enemy, "Kick ")
        else
          performInterrupt(enemy, "Kick ", saved.kickCClist)
        end
      end

      if kickPVE then
        performInterrupt(enemy, "Kick ")
      elseif kickFastMD then
        performInterrupt(enemy, "Kick ", saved.kickHealinglist)
      elseif kickHealer then
        performInterrupt(enemy, "Kick ", saved.kickHealinglist)
      elseif kickDangerous then
        performInterrupt(enemy, "Kick ", saved.kickDangerouslist)
      elseif kickCC then
        performInterrupt(enemy, "Kick ", saved.kickCClist)
      elseif kickHybrid then
        performInterrupt(enemy, "Kick ")
      elseif dontKickAvoidableCC then
        performInterrupt(enemy, "Kick ", saved.kickCClist)
      end
    end
  end)
end)

kick:Callback("tyrants", function(spell)
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
            alert("Kick " .. "|cFFf7f25c[" .. (tyrant.casting or tyrant.channel) .. "]", spell.id)  
          end
        end
      end) 
      
    end

  end)

end)

kick:Callback("seduction", function(spell)
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
                alert("Kick " .. "|cFFf7f25c[" .. (EnemyPet.casting or EnemyPet.channel) .. "]", spell.id)  
              end
            end
          end)

        end
      end
    end)
  end
end)


stealth:Callback(function(spell)
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
          if stealth:Cast() then
            alert("Stealth (Dotted)", stealth.id)
            return
          end
        end
      else
        if player.buff(102543) then return end 
        return stealth:CastAlert()
      end
    end
  end
end)

local function shouldKidney(unit)
  local dodgeFromFront = {37683, 5277, 118038, 199754, 198589, 212800}
  if unit.exists 
  and unit.enemy
  and unit.buffsFrom(dodgeFromFront) == 0
  and unit.stunDR == 1
  and not unit.immuneStuns or unit.immunePhysicalEffects then
    return true
  end
end

kidney:Callback("healer", function(spell)
  
  if spell.cd - blink.gcdRemains > 0 then return end

  local lowest = sr.lowest(blink.enemies)

  if not enemyHealer.exists then return end
  if not enemyHealer.los then return end
  if enemyHealer.dist > 8 then return end
  if enemyHealer.immunePhysicalDamage then return end
  if enemyHealer.ccr and enemyHealer.ccr > 1 then return end
  if enemyHealer.immuneCC then return end
  if enemyHealer.stunDR < 0.5 then return end
  if player.buff(1784) then return end
  if player.cp < 5 then return end
--  if not saved.autoLassoHealer then return end

  if lowest <= 30 then 
    return spell:Cast(enemyHealer, {face = true}) and alert("Kidney [" .. enemyHealer.classString .. "]", spell.id)
  end


end)

kidney:Callback("command",function(spell)
  if spell.cd - blink.gcdRemains > 2 then return end

  if (blink.MacrosQueued["kidney target"]
  or blink.MacrosQueued["kidney focus"]
  or blink.MacrosQueued["kidney arena1"]
  or blink.MacrosQueued["kidney arena2"]
  or blink.MacrosQueued["kidney arena3"]
  or blink.MacrosQueued["kidney enemyhealer"])
  and player.cp >= 5 then
    if blink.MacrosQueued["kidney target"] then
      if shouldKidney(target) then
        if spell:Cast(target, { face = true }) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFKidney [" .. target.classString .. "]", spell.id)
        end
      end
    elseif blink.MacrosQueued["kidney focus"] then
      if shouldKidney(focus) then
        if spell:Cast(focus, { face = true }) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFKidney [" .. focus.classString .. "]", spell.id)
        end
      end  
    elseif blink.MacrosQueued["kidney arena1"] then
      if shouldKidney(arena1) then
        if spell:Cast(arena1, { face = true }) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFKidney [" .. arena1.classString .. "]", spell.id)
        end
      end  
    elseif blink.MacrosQueued["kidney arena2"] then
      if shouldKidney(arena2) then
        if spell:Cast(arena2, { face = true }) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFKidney [" .. arena2.classString .. "]", spell.id)
        end
      end  
    elseif blink.MacrosQueued["kidney arena3"] then
      if shouldKidney(arena3) then
        if spell:Cast(arena3, { face = true }) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFKidney [" .. arena3.classString .. "]", spell.id)
        end
      end  
    elseif blink.MacrosQueued["kidney enemyhealer"] then
      if shouldKidney(enemyHealer) then
        if spell:Cast(enemyHealer, { face = true }) then
          alert("|cFFf7f25c[Manual]: |cFFFFFFFFKidney [" .. enemyHealer.classString .. "]", spell.id)
        end
      end  
    end
  end

end)

sap:Callback("stealth", function(spell)
  --if not saved.AutoFlare then return end
  if blink.prep then return end
  return enemies.stomp(function(enemy, uptime)
    if enemy.distLiteral > spell.range then return end
    if not enemy.isPlayer then return end
    if enemy.buffFrom({185422, 185313}) then return end --121471 blades check if it solve or cause issues
    if enemy.stealth then
      if spell:Cast(enemy, {face = true}) then
        if not saved.streamingMode then
          alert("Sap " .. (enemy.class or "") .. "|cFFf74a4a[Stealth]", spell.id)
        end
      end
    end
  end)
end)


local disarmMePls = {
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
  -- --Serenity
  -- [152173] = function(source)
  --   return source.role == "melee" and not source.disarmed
  -- end,
  -- --boondust
  -- [386276] = function(source)
  --   return source.role == "melee" and not source.disarmed
  -- end,
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
  --Pillar of Frost
  [51271] = function(source)
    return not source.disarmed
  end,
  --Unholy Assault
  [207289] = function(source)
    return not source.disarmed
  end,
  --Metamorphosis
  -- [162264] = function(source)
  --   return true
  -- end,
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

dismantle:Callback("CDs",function(spell)

  if spell.cd - blink.gcdRemains > 0 then return end

  blink.enemies.loop(function(enemy)
    if not enemy.exists then return end
    if not enemy.los then return end
    if not enemy.meleeRange then return end
    if enemy.ccr and enemy.ccr > blink.buffer then return end
    -- not into bladestorm
    if enemy.class2 == "WARRIOR" and enemy.buffFrom({46924, 227847, 23920}) then return end
    if not enemy.isPlayer then return end  
    if enemy.immuneCC then return end
    if enemy.disarmed then return end

    local lowest = sr.lowest(blink.fgroup)

    local has = enemy.buffFrom(disarmMePls)

    if not has then return end
    local str = ""
    for i, id in ipairs(has) do
      if i == #has then
        str = str .. GetSpellInfo(id)
      else
        str = str .. GetSpellInfo(id) .. ","
      end
    end

    if has then
      return spell:Cast(enemy, {face = true}) and blink.alert("Dismantle (" .. colors.red .. (str) .. "|r)", spell.id)
    end

    if enemy.class2
    and disarmClasses[enemy.class2]
    and enemy.role == "melee"
    and enemy.isPlayer 
    and not enemy.immunePhysicalEffects
    and not enemy.isHealer then
      if lowest < 60 + bin(enemy.buffFrom(disarmMePls)) * 57 + bin(not healer.exists or not healer.los or healer.cc) * 30 then
        return spell:Cast(enemy, {face = true}) and blink.alert("Dismantle " .. colors.orange.. "(Peeling)", spell.id)
      end
    end
    
  end)
end)


crimsonVial:Callback("heal",function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local count, _, _, cds = player.v2attackers()

  local threshold = 17
  threshold = threshold + bin(player.hp <= 85) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= 85) * 0.35)

  if player.hpa > threshold then return end
  
  return spell:Cast()
end)

fient:Callback("emergency",function(spell)
  if player.buff(spell.id) then return end
  if not player.combat then return end
  if spell.cd - blink.gcdRemains > 0 then return end

  local count, _, _, cds = player.v2attackers()

  local threshold = 17
  threshold = threshold + bin(player.hp <= 80) * 12
  threshold = threshold + count * 5
  threshold = threshold + cds * 9

  threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= 80) * 0.35)

  if player.hpa > threshold then return end
  
  return spell:Cast()
end)



local function WeCanBlind(unit)

  if unit.exists 
  and unit.ddr == 1 
  and unit.ccRemains < 1
  and not unit.immuneCC
  and not unit.buffFrom({377362, 203337, 408558}) then 

    return true

  else

    local errorMessage = "|cFFf7f25c[Check]: |cFFf74a4a"

    if not unit.exists then
      blink.alert(errorMessage .. "Unit doesn't exist!", blind.id) 
    elseif (unit.immuneCC or unit.immunePhysicalEffects) then
      blink.alert(errorMessage .. "Can't Blind! [" .. (unit.classString or "") .. "]", blind.id)    
    elseif unit.stunDR < 1 then
      blink.alert(errorMessage .. "Waiting DR To use Blind on [" .. (unit.classString or "") .. "]", blind.id)	  
    end

  end		
end

bomb:Callback("auto", function(spell)
  local validTarget = target.exists and target.enemy and not target.dead
  local validPhysical = validTarget and not target.bcc and not target.immunePhysicalDamage and not target.immunePhysicalEffects
  local validPhysicalInRange = validPhysical and target.meleeRange and player.isFacing(target)

  if enemyHealer.exists and enemyHealer.distanceTo(target) < 15 then return end

  if validPhysicalInRange 
  and target.stunRemains > 2.8 then
    return spell:Cast() and alert("Smoke Bomb ",spell.id)
  end
end)

blind:Callback("command", function(spell)

  --Focus
  if blink.MacrosQueued['blind focus'] then
    if WeCanBlind(focus) then 

      if not WeCanBlind(focus) then return end

      if spell:Cast(focus) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlind! [" .. focus.classString .. "]", spell.id)
      end	 
    end
  end

  --Target
	if blink.MacrosQueued['blind target'] then
    if WeCanBlind(target) then 

      if not WeCanBlind(target) then return end

      if spell:Cast(target) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlind! [" .. target.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena1
  if blink.MacrosQueued['blind arena1'] then
    if WeCanBlind(arena1) then 

      if not WeCanBlind(arena1) then return end

      if spell:Cast(arena1) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlind! [" .. arena1.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena2
  if blink.MacrosQueued['blind arena2'] then
    if WeCanBlind(arena2) then 

      if not WeCanBlind(arena2) then return end

      if spell:Cast(arena2) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlind! [" .. arena2.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena3
  if blink.MacrosQueued['blind arena3'] then
    if WeCanBlind(arena3) then 
      
      if not WeCanBlind(arena3) then return end

      if spell:Cast(arena3) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlind! [" .. arena3.classString .. "]", spell.id)
      end	 
    end
  end

  --EnemyHealer
  if blink.MacrosQueued['blind enemyhealer'] then
    if WeCanBlind(enemyHealer) then 

      if not WeCanBlind(enemyHealer) then return end

      if spell:Cast(enemyHealer) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFBlind! [" .. enemyHealer.classString .. "]", spell.id)
      end	 
    end
  end

end)

cheapShot:Callback("cc healer", function(spell)
  --if not blink.arena then return end
  -- if not saved.cheapshotHealer then return end
  -- if not enemyHealer.exists then return end
  -- if enemyHealer.sdr == 1
  -- and sr.lowest(enemies) < 70
  -- and enemyHealer.ccr <= 1
  -- and not enemyHealer.isUnit(target)
  -- and enemyHealer.v2attackers(true) == 0 then
  --   if enemyHealer.meleeRange then
  --     return spell:Cast(enemyHealer) and alert("Bash "..colors.yellow.."[Enemy Healer]", spell.id)
  --   end
  -- end
end)

kidney:Callback("auto kidney", function(spell, unit)
  --if not saved.AutoKidney then return end
  if kidney.cd < 0.25 
  and player.cp >= 5 
  and target.hp < 80 
  and (not enemyHealer.exists or enemyHealer.ccRemains > 3.5)
  and target.isPlayer then
    if target.sdr == 1 then
      if shouldKidney(target) then
        if spell:Cast(target, {face = true}) then
          alert("|cFFf7f25c[Auto]: |cFFFFFFFFKidney [" .. target.classString .. "]", spell.id)
        end
      end
    end
  elseif kick.cd > 0 and kidney.cd < 0.25 and player.cp == 5 and target.hp < 50 and target.isHealer and target.isPlayer then
    if target.sdr == 1 then
      if shouldKidney(target) then
        if spell:Cast(target, {face = true}) then
          alert("|cFFf7f25c[Auto]: |cFFFFFFFFKidney [" .. target.classString .. "]", spell.id)
        end
      end
    end
  end
end)

local dismantleClasses = {
  -- ["PALADIN"] = true,
  ["WARRIOR"] = true,
  ["ROGUE"] = true,
  ["DEATHKNIGHT"] = true,
  -- ["MONK"] = true, -- they can still kick you according to the lore
  ["HUNTER"] = true,
  -- ["DEMONHUNTER"] = true, -- ??
}

dismantle:Callback(function(spell)
  if player.stealth then return end
  local lowest = sr.lowest(fgroup)
  enemies.loop(function(enemy)
    if not enemy.meleeRange then return end
    if enemy.ccr and enemy.ccr > blink.buffer then return end
    -- not into dismantle
    if enemy.class2 == "WARRIOR" and (enemy.buff(46924) or enemy.buff(227847)) then return end

    -- dance 
    if enemy.class2 == "ROGUE"
    and enemy.buffRemains(185422) > 2.75 - bin(lowest < 60) * 1.5
    and spell:Cast(enemy, face) then
      return alert("Dismantle " .. colors.cyan .. "Shadow Dance", spell.id)
    end
    -- wings
    -- if enemy.class2 == "PALADIN"
    -- and enemy.role == "melee"
    -- and enemy.buff(31884)
    -- and spell:Cast(enemy, face) then
    --   return alert("Dismantle " .. colors.cyan .. "Wings", spell.id)
    -- end
    -- hunter shit
    if enemy.class2 == "HUNTER"
    and (not healer.exists or healer.cc)
    and (lowest < 65 
        + bin(not healer.exists or healer.cc) * 20
        + bin(enemy.cds) * 25)
    and spell:Cast(enemy, face) then
      return alert("Dismantle " .. enemy.classString, spell.id)         
    end
    -- dk offense
    if enemy.class2 == "DEATHKNIGHT"
    and enemy.hp < (30 + bin(not enemyHealer.exists or enemyHealer.cc) * 18)
    and spell:Cast(enemy, face) then
      return alert("Offensive Dismantle " .. enemy.classString, spell.id)
    end
    -- dk defense
    if enemy.class2 == "DEATHKNIGHT"
    and lowest < 25 + bin(enemy.cds) * 15 
    and spell:Cast(enemy, face) then
      return alert("Dismantle " .. enemy.classString, spell.id)
    end

    -- we just needa peel
    if enemy.class2
    and dismantleClasses[enemy.class2]
    and enemy.role == "melee" then
      if lowest < 35 + bin(enemy.cds) * 57 + bin(not healer.exists or healer.cc) * 30 - bin(enemy.class2 == "DEATHKNIGHT") * 65 then
        return spell:Cast(enemy, face) and alert("Dismantle " .. enemy.classString, spell.id)
      end
    end
  end)
end)

shiv:Callback(function(spell)
  if player.buff(1784) then return end
  if target.debuff(319504) then return end
  --if enemyHealer.exists and enemyHealer.cc then return end
  if not target.stunned then return end

  if target.enemy 
  and player.cp < 5 then
    return spell:CastAlert(target)
  end
end)

deathmark:Callback(function(spell)
  if blink.burst 
  or saved.mode == "ON" 
  and (target.stunRemains > 3.5 
  or enemyHealer.ccRemains > 3.5 
  or not enemyHealer.exists and target.hpa < 80) and target.dist < 9 then
    if spell:Cast(target, {face = true}) then 
      alert("Deathmark " .. "[" .. (target.classString) .. "]", spell.id)  
    end
  end
end)

echoing:Callback(function(spell)
  if player.stealth or player.cp > 3 then return end
  spell:Cast(target)
end)

-- TRINKETS

--Badge
Trinkets.Badge:Update(function(item, key)
  if not player.buffFrom({185422, 121471}) then return end
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

-- racials
assa.racial = function()
  local racial = racials[player.race]
  if racial and racial() then
    blink.alert(racial.name, racial.id)
  end
end

-- orc
racials.Orc:Callback(function(spell)
  if not player.race == "Orc" then return end

  return spell:Cast()

end)

-- Troll
racials.Troll:Callback(function(spell)
  if not player.race == "Troll" then return end
  
  return spell:Cast()

end)

--Irondwarf
racials.IronDwarf:Callback(function(spell)
  if not player.race == "Dark Iron Dwarf" then return end
  if player.debuffFrom({30108,316099}) and player.hpa <= 75 then return end

  if player.debuffFrom({360194, 323673, 375901, 274838, 274837}) then
    return spell:Cast()
  end

end)


-- --! TOTEM STOMPAGE !--
local function stomp(callback)
  return blink.totems.stomp(function(totem, uptime)
    local id = totem.id
    local app = importantTotems[id]
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

-- bonespike stomp
bonespike:Callback("stomp", function(spell)
  if player.stealth then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if player.distanceTo(totem) < 40 and player.losOf(totem) then
      if spell:Cast(totem) then
        return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
      end
    end
  end)
end)

--mutilate stomp
mutilate:Callback("stomp", function(spell)
  if player.stealth then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if totem.distliteral > 8 then return end
    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end
  end)
end)
-- --! END TOTEM STOMPAGE !--

