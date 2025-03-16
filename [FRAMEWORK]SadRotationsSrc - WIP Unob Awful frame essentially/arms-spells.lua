local unlocker, blink, sr = ...
local warrior, arms = sr.warrior, sr.warrior.arms
local min, max, bin, cos, sin = min, max, blink.bin, math.cos, math.sin
local onUpdate, onEvent, hookCallbacks, hookCasts, Spell, Item = blink.addUpdateCallback, blink.addEventCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local angles, acb, gdist, between = blink.AnglesBetween, blink.AddSlashBlinkCallback, blink.Distance, blink.PositionBetween
local events, colors, colored, escape = blink.events, blink.colors, blink.colored, blink.textureEscape
local unlockerType = unlocker.type
local saved = sr.saved
local face = {face=true}
local delay = blink.delay(0.5, 0.6)
local stompDelay = blink.delay(0.5, 0.6)

local currentSpec = GetSpecialization()

if not warrior.ready then return end

if currentSpec ~= 1 then return end

local player = blink.player

blink.Populate({
  --
  target = blink.target,
  pet = blink.pet,
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

  --dmg
  slam = Spell(1464, { damage = "physical", targeted = true}),
  raging = Spell(85288, { damage = "physical", targeted = true}),
  crushing = Spell(335097, { damage = "physical", targeted = true}),
  bloodbath = Spell(335096, { damage = "physical", targeted = true}),
  bloodthirst = Spell(23881, { damage = "physical", targeted = true}),
  mortal = Spell(12294, { damage = "physical", targeted = true}),
  --execute = Spell({ 281000, 163201, 231830, 5308 }, { damage = "physical", targeted = true, ignoreRange = function() return player.hasTalent(198500) end }),
  execute = Spell({ 281000, 231830, 5308 }, { damage = "physical", ignoreRange = function() return player.hasTalent(198500) end }),
  whirlwind = Spell(190411, { damage = "physical", targeted = true}),
  overpower = Spell(7384, { ignoreUsable = true }),
  rend = Spell(772, { damage = "physical", targeted = true}),
  wreckingthrow = Spell(384110, { damage = "physical", targeted = true}),
  sweeping = Spell(260708),
  skull = Spell(260643, { damage = "physical", targeted = true}),
  roar = Spell(384318, { damage = "physical", targeted = true}),

  --defs
  DBTS = Spell(118038, { ignoreGCD = true }),
  victoryRush = Spell(34428, { damage = "physical", targeted = true}),
  impendingVictory = Spell(202168),
  bitter = Spell(383762, { ignoreGCD = true }),
  ignorePain = Spell(190456, { ignoreGCD = true }),
  regen = Spell(184364, { ignoreStuns = true }),
  rally = Spell(97462),
  zerk = Spell(18499, { ignoreGCD = true, ignoreCC = true }),
  intervene = warrior.intervene,
  reflect = Spell(23920, { ignoreGCD = true }),
  disarm = Spell(236077, { effect = "physical", cc = true }),
  warBanner = Spell(236320, { ignoreLoS = true }),

  --offensives
  avatar = Spell(107574, { ignoreGCD = true }),
  smash = Spell(167105),
  warbreaker = Spell(262161),
  sharpen = Spell(198817, { ignoreGCD = true }),
  bladestorm = Spell(389774),
  deathWish = Spell(199261),
  bloodrage = Spell(329038),
  spear = Spell(376079),
  


  steward = Spell(324739),
  fleshcraft = Spell(324631),
  conqBanner = Spell(324143),

  --util
  charge = warrior.charge,
  leap = warrior.leap,
  shatter = Spell(64382, { ignoreMoving = true }),
  escapeArt = Spell(20589, { ignoreGCD = true }),
  
  --cc
  stormBolt = Spell(107570, { effect = "physical", cc = "stun" }),
  shockWave = Spell(46968, { effect = "physical", cc = "stun" }),
  pummel = Spell(6552, { ignoreGCD = true, effect = "physical" }),
  intim = Spell(5246, { effect = "physical", cc = "fear", ignoreFacing = true }),
  piercing = Spell(12323),
  hamstring = Spell(1715, { effect = "physical", slow = true }),

  battleShout = Spell(6673),

  badge = Item({205708, 205778, 201807}),
  signet = Item({"Signet of Tormented Kings"}),
  phial = Item(177278),
  aegis = Item({188775, 192304}),
  
  --Trinkets Table
  Trinkets = {
    Badge = blink.Item({216368, 216279, 209343, 209763, 205708, 205778, 201807, 201449, 218421, 218713}),
    Emblem = blink.Item({216371, 216281, 209345, 209766, 201809, 201452, 205781, 205710, 218424, 218715}),
  },

  heroicThrow = Spell(57755, { damage = "physical", targeted = true,  }),
  bloodFury = Spell({20572, 33697}),

}, arms, getfenv(1))

local og_alert = blink.alert
local alert = function(...)
  if saved.streamingMode then return true end
  return og_alert(...)
end
blink.alert = alert

-- function aegis:danger()

--   if not saved.autoAegis then return end
--   if self.cd > 0 then return end
  
--   local count, melee, ranged, cds = player.v2attackers()

--   local threshold = 38
--   threshold = threshold + cds * 15
--   threshold = threshold + ranged * 11
--   blink.enemies.loop(function(enemy)
--     if enemy.class2 == "DEATHKNIGHT" 
--     and enemy.buff(315443)
--     and enemy.dist < 16 then
--       threshold = threshold + 60
--     end
--   end)
--   threshold = threshold * (1 + bin(not healer.exists or healer.cc) * 0.35)

--   return player.hp < threshold and self:Use()

-- end

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

--immune to hunter Stun Stuff Table
local ImmuneToWarriorStun = {

  213610, --Holy Ward
  -- 236321, --War Banner
  362486, --Keeper of the Grove
  228050, --Forgotten Queen
  203337, --dimoand ice
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  353319, --monk retoral
  408558, --priest phase shift
  377362, --precognition
  421453, --Ultimate Penitence
  354610, --dh Glimpse
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



local reflecting = {}
DBTS:Callback("emergency", function(spell)

  if player.hp > saved.DBTSSensitivity then return end

  if player.hp <= saved.DBTSSensitivity then
    return spell:CastAlert()
  end

end)

steward:Callback("prep", function(spell)
  -- if not blink.prep then return end
  if phial.count > 1 then return end
  return spell:CastAlert()
end)

local lastFuckOff = 0
function steward:FuckOff()
  if self.cd < 200 then return end
  if self.cd > 296 then return end
  if blink.time - lastFuckOff < 1 then return end
  lastFuckOff = blink.time
  if not GossipFrame:IsShown() then
    blink.units.loop(function(unit)
      if unit.id ~= 166663 or not unit.creator.isUnit(player) then return end
      if unit.distLiteral > 5 then return end
      InteractUnit(unit.pointer)
      lastFuckOff = lastFuckOff - 0.5
    end)
  else
    local opt_num = #C_GossipInfo.GetOptions()
    if opt_num > 0 and C_GossipInfo.GetOptions()[opt_num] ~= nil then
      GossipFrame_GetTitleButton(opt_num):Click()
    end
  end 
end

hamstring:Callback("slow target", function(spell)
  if not target.player then return end
  --if max(target.debuffRemains(spell.id), target.debuffRemains(piercing.id)) > target.distLiteral / 2 + target.speed / 2 then return end
  if target.bcc then return end
  if target.hp < 30 then return end
  if target.stunRemains > spell.gcd * 2 then return end
  if target.immuneSlows then return end
  if target.immunePhysicalEffects then return end
  --if target.slowRemains > 1.5 then return end
  if target.speed2 < 4 then return end
  if target.debuffRemains(spell.id) - blink.gcd > 1 then return end
  return spell:Cast(target)
end)

piercing:Callback("slow target", function(spell)
  if target.distLiteral > 11.5 then return end
  if not target.player then return end
  if target.cc then return end
  if target.timeInLoS < 0.65 or not target.predictLoS(blink.buffer + 0.03) then return end
  if target.physicalEffectImmunityRemains > 0 then return end
  if target.immuneSlows then return end
  if target.stunRemains > spell.gcd * 2 then return end
  if target.debuffRemains(hamstring.id) > 3.5 then return end
  if target.hp < 30 then return end
  return spell:CastAlert()
end)

bloodrage:Callback(function(spell)
  if player.rooted 
  or player.slowed and target.dist > 5 
  or (player.cds or saved.bloodrageOnCD and player.combat) and player.rage < 25 then
    return spell:Cast() and alert("Bloodrage"..(player.rooted and " " .. "|cFFf7f25c[Rooted]" or ""), spell.id, true)
  end
end)

local function warriorsAreEpic(spell)
  return spell:Cast(target, face)
end

mortal:Callback(function(spell)

  if target.immunePhysicalDamage then return end 

  if player.buffStacks(7384) < 2 
  and overpower.cd - blink.gcdRemains == 0 then 
    return 
  end

  return spell:Cast(target, face)
end)

local dodgeFromFront = {37683, 5277, 118038, 199754, 198589, 212800}

overpower:Callback(function(spell)

  if target.buffFrom(FullyImmuneBuffs) or target.debuffFrom(FullyImmuneDeBuffs) then return end
  if player.buffStacks(7384) >= 2 and not target.buffFrom(dodgeFromFront) then return end

  return spell:Cast(target, face)

end)

rend:Callback(function(spell)
  
  if target.immunePhysicalDamage then return end
  if target.hp < 20 then return end
  if target.debuffRemains(388539) > 3 then return end --rend debuff

  return spell:Cast(target, face)

end)

sweeping:Callback(function(spell)
  if target.dist > 6 then return end
  if not target.enemy then return end
  if player.buff(spell.id) then return end

  return spell:Cast()

end)

execute:Callback(function(spell)
  if not target.los then return end  
  if not target.exists then return end
  if not target.enemy then return end
  if target.immunePhysicalDamage then return end

  if player.hasTalent(198500) 
  and target.dist <= 15 then
    spell:Cast(target, {face = true})
  else
    if not player.hasTalent(198500) and target.meleeRange then
      spell:Cast(target, {face = true})
    end
  end

end)

execute:Callback("finish", function(spell)
  if not target.los then return end  
  if not target.exists then return end
  if not target.enemy then return end
  if target.immunePhysicalDamage then return end

  if target.hp <= 20 then
    if player.hasTalent(198500)
    and target.dist <= 15 then
      return spell:Cast(target, {face = true}) and alert("Execute ", spell.id)
    else
      if not player.hasTalent(198500) 
      and target.meleeRange then
        return spell:Cast(target, {face = true}) and alert("Execute ", spell.id)
      end
    end
  end

end)

execute:Callback("anyone", function(spell, unit)

  blink.enemies.loop(function(enemy)

    if not enemy.los then return end
    if enemy.hp > 20 then return end
    if enemy.immunePhysicalDamage then return end

    if enemy.hp <= 20 then
      if player.hasTalent(198500)
      and enemy.dist <= 15 then
        return spell:Cast(enemy, {face = true}) and alert("Execute ", spell.id)
      else
        if not player.hasTalent(198500) 
        and enemy.meleeRange then
          return spell:Cast(enemy, {face = true}) and alert("Execute ", spell.id)
        end
      end
    end

  end)

end)

execute:Callback("proc", function(spell, unit)
  if not target.los then return end
  if not player.buff(52437) then return end  
  if target.immunePhysicalDamage then return end
    
  if player.hasTalent(198500)
  and target.dist <= 15 then
    return spell:Cast(target, {face = true}) and alert("Execute ", spell.id)
  else
    if not player.hasTalent(198500) 
    and target.meleeRange then
      return spell:Cast(target, {face = true}) and alert("Execute ", spell.id)
    end
  end
  --return spell:Cast(target, {face = true}) and alert("Execute ", spell.id)

end)


avatar:Callback(function(spell)

  if not target.enemy then return end
  if target.dist > 8 then return end
  if target.physicalDamageImmunityRemains > 0 then return end
  if player.hasTalent(390138) and enemies.around(player, 10, function(o) return o.bcc and not o.isPet end) > 0 then return end

  return spell:Cast() and alert("Avatar", spell.id, true)

  -- group.loop(function(member)

  --   if member.class2 == "PALADIN"
  --   and member.role == "melee"
  --   and member.dist < 18
  --   and member.buffRemains(31884) >= 5.5 then
  --     return spell:Cast() and alert("Avatar " .. "|cFFf7f25c[Friend CD's]", spell.id, true)
  --   end

  -- end)


end)

smash:Callback(function(spell)
  if player.hasTalent(262161) then return end
  if not target.enemy then return end
  if target.dist > 5 then return end
  if target.physicalDamageImmunityRemains > 0 then return end
  return spell:CastAlert(target)
end)

warbreaker:Callback(function(spell)
  if not player.hasTalent(262161) then return end
  if enemies.around(player, 9, function(o) return o.bcc and not o.isPet end) > 0 then return end
  if not target.enemy then return end
  if target.dist > 5 then return end
  if target.physicalDamageImmunityRemains > 0 then return end
  return spell:CastAlert(target)
end)

rend:Callback("skull", function(spell)

  if not player.hasTalent(skull.id) then return end

  if skull.cd - blink.gcdRemains > 0 then return end 
  if target.debuffRemains(388539, player) > 15 then return end
  if spell.used(1.5) then return end

  return spell:Cast(target, {face = true})
  

end)
mortal:Callback("skull", function(spell)

  if not player.hasTalent(skull.id) then return end

  if skull.cd - blink.gcdRemains > 0 then return end 
  if target.debuffRemains(262115, player) > 15 then return end

  return spell:Cast(target, {face = true})

end)

local function shouldSkull(unit)
  if unit.exists 
  and unit.dist < 5
  and unit.enemy
  and unit.debuffRemains(262115, player) > 15 
  and unit.debuffRemains(388539, player) > 15 
  and not unit.immunePhysicalDamage then
    return true
  end
end

skull:Callback(function(spell)
  if not player.hasTalent(spell.id) then return end
  if not shouldSkull(target) then return end
  return spell:Cast(target)
end)

roar:Callback(function(spell)
  if blink.enemies.around(player, 13, function(o) return o.bcc and not o.isPet end) > 0 then return end
  if not player.hasTalent(spell.id) then return end
  if not target.enemy then return end
  if target.dist > 5 then return end
  if target.physicalDamageImmunityRemains > 0 then return end
  return spell:Cast(target)
end)


wreckingthrow:Callback(function(spell)

  if not player.hasTalent(384110) then return end

  if not target.enemy then return end
  if target.dist > 30 then return end
  if target.physicalDamageImmunityRemains > 0 then return end

  -- if blink.burst 
  -- or saved.mode == "ON" 
  -- and (target.stunned 
  -- or enemyHealer.cc 
  -- or not enemyHealer.exists and target.hpa < 69) and target.dist < 6 then
    return spell:Cast(target)
  -- end  

end)

sharpen:Callback(function(spell)
  if not target.enemy then return end
  if target.dist > 5 then return end
  if target.physicalDamageImmunityRemains > 0 then return end
  if (mortal.cd - blink.gcdRemains > 0.5 + bin(saved.bladestormUnhinged and bladestorm.cd - blink.gcdRemains > 0.5)) then return end

  if player.buff(107574)
  or blink.burst
  or saved.mode == "ON" then 
    return spell:CastAlert()
  end

end)

sharpen:Callback("pre-ms", function(spell)
  -- fires an alert about the pre-ms sharpen
  return spell:Cast() and alert("Sharpen Blade (MS)", spell.id)
end)

mortal:Callback("prio", function(spell)
  if not spell:Castable(target) then return end
  -- pre-sharpen when MS is castable
  sharpen("pre-ms")
  return spell:Cast(target)
end)

sharpen:Callback("heal", function(spell)
  if target.dist > 5 then return end
  if target.physicalDamageImmunityRemains > 0 then return end
  if (mortal.cd - blink.gcdRemains > 0.5 + bin(saved.bladestormUnhinged and bladestorm.cd - blink.gcdRemains > 0.5)) then return end
    
  if enemyHealer.exists
  and not enemyHealer.cc 
  and target.enemy 
  and target.hp < 70 then
    return spell:Cast() and alert("Sharpen Blade  " .. "|cFFf7f25c[Inc Heal]", spell.id)
  end 

end)
-- crushing:Callback(warriorsAreEpic)

-- raging:Callback(warriorsAreEpic)

-- bloodbath:Callback(warriorsAreEpic)

-- bloodthirst:Callback(warriorsAreEpic)

-- whirlwind:Callback("fallthru", function(spell)
--   if enemies.around(player, 10, function(o) return o.bcc and not o.isPet end) > 0 then return end
--   if target.distLiteral > 8 then return end
--   if saved.neverWhirlwind and raging.frac > 0.8 then return end
--   return spell:Cast()
-- end)

local function fls(spell)
  -- if spell.id == raging.id and player.buff(avatar.id) then return end
  if player.rage > 95 then return end
  enemies.loop(function(enemy)
    if enemy.bcc then return end
    return spell:Cast(enemy)
  end)
end

raging:Callback("fls", fls)
bloodthirst:Callback("fls", fls)
bloodbath:Callback("fls", fls)

whirlwind:Callback("spread hot cum", function(spell)
  if player.buffStacks(85739) > 0 + bin(player.rage > 68 and player.rage < 80) then return end
  local bcc, around = enemies.around(player, 8.5, function(o) return o.bcc and not o.isPet end)
  if bcc > 0 or around < saved.cleaveCount then return end
  return spell:Cast()
end)

local function shouldKick(enemy, maxRem, minRem, caca)

  maxRem = maxRem or 5
  minRem = minRem or blink.buffer

  -- enemy must be casting or channeling
  local cast, channel = enemy.casting, enemy.channeling
  if not cast and not channel then return end
  
  -- must not be immune to interrupts
  if cast and enemy.castint or channel and enemy.channelint then return end

  -- must not be a shit kick
  local name = cast or channel
  local id = enemy.castID or enemy.channelID
  if sr.ShitKick[name] then
    if sr.ShitKick[name](enemy) then return end
  else
    if not sr.IsUnknownKickGood(enemy, id) then return end
  end

  if cast and enemy.castRemains < maxRem and enemy.castRemains > minRem and (caca or enemy.castTimeComplete > 0.275) then
    return cast
  end

  if channel and enemy.channelTimeComplete > 0.55 - blink.buffer then
    return channel
  end
end

local succs = {127797, 307871}

charge:Callback("gapclose", function(spell)
  if not saved.autoCharge then return end 

  local ROP = blink.triggers.find(function(trigger) return trigger.id == 116844 and trigger.enemy and player.facing(trigger , 60) end)
  if ROP then return end

  if player.hasTalent(198500) 
  and execute.cd - blink.gcdRemains == 0 
  and execute:Castable(target)
  and player.rage >= 20
  and target.dist <= 16 then 
    return 
  end

  if target.buffFrom({642, 45438, 1022, 186265, 362486}) then return end
  if player.mounted then return end
  if player.debuffFrom(succs) then return end
  if target.dist <= 12 then return end
  if target.speed > 8 and target.immuneSlows then return end
  if leap.cd >= leap.baseCD - 3 then return end
  if leap.current then return end
  if player.used(leap.id, 1) then return end
  
  local thresh = 100
  thresh = thresh + bin(not enemyHealer.exists or enemyHealer.cc) * 26
  thresh = thresh + bin(target.cc) * 18
  thresh = thresh + bin(player.cds) * 46
  thresh = thresh + target.distLiteral
  -- FIXME, reduce threshold when target has defensives up and such

  thresh = thresh * saved.chargeGapcloseMod

  if target.hp <= thresh and player.movingToward(target, { duration = 0.25, angle = 55 }) then
    return spell:Cast(target) and alert("Charge  " .. "|cFFf7f25c[Gapclose]", spell.id)
  end
end)

local allStatic = { enemyHealer, target, focus }
charge:Callback("interrupts", function(spell)
  if fleshcraft.current then return end
  if player.channeling then return end
  if player.mounted then return end
  if player.debuffFrom(succs) then return end
  if leap.current then return end
  if leap.cd > leap.baseCD - 4 then return end
  if pummel.cd > 0.15 then return end
  local tar = saved.chargeIntTarget
  if tar == "none" then return end
  if tar == "everyone" then 
    for _, unit in ipairs(allStatic) do
      if unit.dist and unit.dist > 8 and shouldKick(unit, 5, blink.buffer + unit.distLiteral * 0.033, true) then
        if spell:Cast(unit, {face=true}) and alert("Charge " .. "|cFFf7f25c[Interrupt]", spell.id) then
          return
        end
      end
    end
  else
    local unit = blink[tar]
    if unit and unit.dist and unit.dist > 8 then
      if shouldKick(unit, 5, blink.buffer + unit.distLiteral * 0.033, true) then
        if spell:Cast(unit, {face=true}) and alert("Charge " .. "|cFFf7f25c[Interrupt]", spell.id) then
          return
        end
      end
    end
  end  
end)

leap:Callback("interrupts", function(spell)
  
  if charge.current then return end
  if player.mounted then return end
  if player.debuffFrom(succs) then return end
  if player.used(charge.id, 1.5) then return end
  if player.used(intervene.id, 1.5) then return end
  
  if pummel.cd > 0.15 then return end
  local tar = saved.leapIntTarget
  if tar == "none" then return end
  if tar == "everyone" then 
    for _, unit in ipairs(allStatic) do
      if unit.dist and unit.dist > 8 and shouldKick(unit, 5, blink.buffer + unit.distLiteral * 0.033, true) then
        if spell:AoECast(unit) and alert("Leap " .. "|cFFf7f25c[Interrupt]", spell.id) then
          return
        end
      end
    end
  else
    local unit = blink[tar]
    if unit and unit.dist and unit.dist > 8 then
      if shouldKick(unit, 5, blink.buffer + unit.distLiteral * 0.033, true) then
        if spell:AoECast(unit) and alert("Leap " .. "|cFFf7f25c[Interrupt]", spell.id) then
          return
        end
      end
    end
  end  

end)

leap:Callback("gapclose", function(spell)
  if not saved.autoLeap then return end

  local ROP = blink.triggers.find(function(trigger) return trigger.id == 116844 and trigger.enemy and player.facing(trigger, 60) end)
  if ROP then return end  

  if target.los 
  and charge.cd == 0 
  and target.dist <= 25 then
    return
  end

  if player.hasTalent(198500) 
  and execute.cd - blink.gcdRemains == 0 
  and execute:Castable(target)
  and player.rage >= 20
  and target.dist <= 16 then 
    return 
  end

  if target.buffFrom({642, 45438, 1022, 186265, 362486}) then return end
  if charge.current then return end
  if player.mounted then return end
  if player.debuffFrom(succs) then return end
  if target.dist <= 12 - bin(player.cds and player.slowed) * 2 then return end
  if target.speed > 8 then return end
  if player.used(charge.id, 2.5) then return end
  if player.used(intervene.id, 2) then return end

  local thresh = 51
  thresh = thresh + bin(not enemyHealer.exists or enemyHealer.cc) * 26
  thresh = thresh + bin(target.cc) * 18
  thresh = thresh + bin(player.cds) * 42
  thresh = thresh + target.distLiteral * (2 + bin(player.cds) * 3)
  -- FIXME, reduce threshold when target has defensives up and such

  thresh = thresh * saved.leapGapcloseMod

  if target.hp <= thresh and player.movingToward(target, { duration = 0.25, angle = 55 }) then
    local x, y, z = target.predictPosition(blink.buffer + target.distanceLiteral / 40)
    if not player.losCoords(x, y, z) then return end
    return spell:AoECast(x, y, z) and alert("Heroic Leap " .. "|cFFf7f25c[Gapclose]", spell.id)
  end
end)

-- regen:Callback(function(spell)
  
--   if not saved.autoRegen then return end
--   local count, _, _, cds = player.v2attackers()
  
--   local threshold = 17
--   threshold = threshold + bin(player.stunned) * 5
--   threshold = threshold + count * 9
--   threshold = threshold + cds * 12

--   threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.stunned) * 0.35)
--   threshold = threshold * saved.regenSensitivity

--   if player.hpa > threshold then return end
--   return spell:Cast() and alert("Enraged Regen "..colors.pink.."Danger", spell.id, true)
-- end)

spear:Callback(function(spell, manual)
  if not manual and not saved.autoSpear then return end
  if not target.enemy then return end
  if not target.isPlayer then return end
  if target.dist > 9 then return end
  if target.magicEffectImmunityRemains > blink.latency then return end
  if target.physicalEffectImmunityRemains > blink.latency then return end
  if target.physicalDamageImmunityRemains > blink.latency then return end
  if target.buffRemains(116849) > 0.5 and target.absorbs > 2500 then return alert("Holding spear " .. "|cFFf7f25c[Life Cocoon]", spell.id) end
  if target.buffRemains(147833) > blink.latency then return alert("Holding spear " .. "|cFFf7f25c[Intervene]", spell.id) end
  if not target.cc and target.speed > 12 - target.distLiteral / 2.5 then return alert("Holding spear " .. "|cFFf7f25c[Unreliable]", spell.id) end
  local x, y, z = target.predictPosition(blink.buffer + 0.1 + target.distLiteral / 150)
  return player.losCoords(x, y, z) 
    and spell:AoECast(x, y, z) 
    and alert("Spear of Bastion", spell.id)
    and badge:Use()
    and alert("Badge", badge.spell)
    and avatar:Cast()
    and alert("Avatar", avatar.spell)

end)

spear:Callback('multi-target', function(spell)
  if not target.enemy then return end
  if target.dist > 9 then return end
  if target.magicEffectImmunityRemains > blink.latency then return end
  if target.physicalEffectImmunityRemains > blink.latency then return end
  if target.physicalDamageImmunityRemains > blink.latency then return end
  if target.buffRemains(116849) > 0.5 and target.absorbs > 2500 then return end
  if target.buffRemains(147833) > blink.latency then return end
  if not target.cc and target.speed > 12 - target.distLiteral / 2.5 then return end
  local x, y, z = target.predictPosition(blink.buffer + 0.1 + target.distLiteral / 150)
  if x and y and z
  and player.losCoords(x, y, z)
  and enemies.around({x, y, z}, 6.25, function(obj)
                                  return not obj.isUnit(target)
                                  and obj.magicEffectImmunityRemains < blink.latency
                                  and obj.physicalEffectImmunityRemains < blink.latency
                                  and obj.physicalDamageImmunityRemains < blink.latency
                                  and obj.predictDistanceToPosition(x, y, z, blink.buffer) < 4.5
                                end) >= saved.autoSpearCount - 1 then
    return spell:AoECast(x, y, z) 
      and alert("Spear of Bastion", spell.id)
      and badge:Use()
      and alert("Badge", badge.spell)
  end
end)

badge:Update(function(item)
  if item:Use() then
    blink.alert("Badge", item.spell)
  end 
end)

arms.spearTime = 0
sr.cmd:New(function(msg)
  if msg == "spear" then
    arms.spearTime = GetTime() + 2
  end
end)

local firstPrepTimer
battleShout:Callback(function(spell)
  if player.channeling or player.casting then return end
  -- Reset the first preparation timer if the player enters combat
  if player.combat then
    firstPrepTimer = nil
    return
  end

  if blink.arena then
    if blink.prep then
      firstPrepTimer = firstPrepTimer or blink.prepRemains
    end

    if firstPrepTimer and blink.prepRemains and firstPrepTimer - blink.prepRemains > 5 then
      blink.fgroup.loop(function(member)

        if not player.used(spell.id, 5)
        and member.dist and member.dist <= 40 
        and (not member.buffRemains(spell.id) 
        or member.buffRemains(spell.id) <= 5) then -- Buff is missing or about to expire
          return spell:CastAlert()
        end
      end)
    end
  else
    -- Non-arena logic for casting Battle Shout on self
    firstPrepTimer = nil
    if player.buffRemains(spell.id) and player.buffRemains(spell.id) < 5 then
      return spell:CastAlert()
    end
  end
end)


local phial_used = 0
phial:Update(function(item)
  if player.hp > 55 then return end
  if blink.time - phial_used >= 180 and item:Use() then
    alert("Phial of Serenity", item.spell)
    phial_used = blink.time
  end
end)

local zerkme = {
  -- incap roar 
  -- (FIXME) check for druid cloning and possibility of kick / reflect
  [99] = { uptime = 0.1, min = 0.5 },
  -- intim shout
  [5246] = { uptime = 0.1 },
  -- fear
  [118699] = { uptime = 0.1, min = 1 },
  [5782] = { uptime = 0.1, min = 1 },
  -- psychic scream
  [8122] = { uptime = 0.1 },
  -- howl of terror
  [5484] = { uptime = 0.15 },
  -- sap/gouge
  [1776] = { uptime = 0.15 }, -- Gouge
	[6770] = { uptime = 0.15 }, -- Sap
  -- repentance
  [20066] = { uptime = 0.05 },
  -- para
  [115078] = { uptime = 0.15 },
  -- Song of Chi?
  [198909] = { uptime = 0.15 },
  -- sigil fear
  [207685] = { uptime = 0.15 },
}

zerk:Callback(function(spell)
  local has = player.debuffFrom(zerkme)
  if not has then return end
  if has[1] == 6770 then
    if not enemies.find(function(e) return e.class2 == "ROGUE" end) then return end
  end
  local str = ""
  for i, id in ipairs(has) do
    if i == #has then
      str = str .. C_Spell.GetSpellInfo(id).name
    else
      str = str .. C_Spell.GetSpellInfo(id).name .. ","
    end
  end
  return spell:Cast() and alert("Berserk " .. "|cFFf7f25c" .. str, spell.id)
end)

impendingVictory:Callback(function(spell)
  local playerStunnedSoon = false -- FIXME:
  if player.hp > 62 + bin(playerStunnedSoon) * 20 or player.debuff(198817) then return end
  return spell:CastAlert(target)
end)

victoryRush:Callback(function(spell)
  if player.hasTalent(202168) then return end
  if not spell:Castable() then return end
  local rem = player.buffRemains(32216)
  if player.hp < 70 
  or rem < 3 and player.hp < 88
  or rem < 4 and player.hp < 85
  or rem < 6 and player.hp < 80
  or rem < 8 and player.hp < 75 then 
    return spell:CastAlert(target)
  end
end)

local disarmClasses = {
  ["PALADIN"] = true,
  ["WARRIOR"] = true,
  ["ROGUE"] = true,
  ["DEATHKNIGHT"] = true,
  -- ["MONK"] = true, -- they can still kick you according to the lore
  ["HUNTER"] = true,
  -- ["DEMONHUNTER"] = true, -- ??
}

-- disarm:Callback(function(spell)
--   local lowest = sr.lowest(fgroup)
--   enemies.loop(function(enemy)

--     if not enemy.meleeRange then return end
--     if enemy.ccr and enemy.ccr > blink.buffer then return end

--     -- not into storm
--     if enemy.class2 == "WARRIOR" and (enemy.buff(46924) or enemy.buff(227847)) then return end

--     -- dance 
--     if enemy.class2 == "ROGUE"
--     and enemy.buffRemains(185422) > 2.75 - bin(lowest < 60) * 1.5
--     and spell:Cast(enemy, face) then
--       return alert("Disarm " ..  "|cFFf7f25c[Shadow Dance]", spell.id)
--     end

--     -- wings
--     if enemy.class2 == "PALADIN"
--     and enemy.role == "melee"
--     and enemy.buff(31884)
--     and spell:Cast(enemy, face) then
--       return alert("Disarm " ..  "|cFFf7f25c[Wings]", spell.id)
--     end

--     -- hunter shit
--     if enemy.class2 == "HUNTER"
--     and (not healer.exists or healer.cc)
--     and (lowest < 65 
--           + bin(not healer.exists or healer.cc) * 20
--           + bin(enemy.cds) * 25)
--     and spell:Cast(enemy, face) then
--       return alert("Disarm " .. enemy.classString, spell.id)         
--     end

--     -- dk offense
--     if enemy.class2 == "DEATHKNIGHT"
--     and enemy.hp < (30 + bin(not enemyHealer.exists or enemyHealer.cc) * 18)
--     and spell:Cast(enemy, face) then
--       return alert("Offensive Disarm " .. enemy.classString, spell.id)
--     end

--     -- dk defense
--     if enemy.class2 == "DEATHKNIGHT"
--     and lowest < 25 + bin(enemy.cds) * 15 
--     and spell:Cast(enemy, face) then
--       return alert("Disarm " .. enemy.classString, spell.id)
--     end

--     -- we just needa peel
--     if enemy.class2
--     and disarmClasses[enemy.class2]
--     and enemy.role == "melee" then
--       if lowest < 35 + bin(enemy.cds) * 57 + bin(not healer.exists or healer.cc) * 30 - bin(enemy.class2 == "DEATHKNIGHT") * 65 then
--         return spell:Cast(enemy, face) and alert("Disarm " .. enemy.classString, spell.id)
--       end
--     end
--   end)
-- end)

local disarmMePls = {
  -- --Incarnation Ashame - Feral
  -- [102543] = function(source)
  --   return source.role == "melee"
  -- end,
  -- --Incarnation Chosen - Boomkin
  -- [102560] = function(source)
  --   return source.role == "ranged"
  -- end,
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

disarm:Callback(function(spell)

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
        str = str .. C_Spell.GetSpellInfo(id).name
      else
        str = str .. C_Spell.GetSpellInfo(id).name .. ","
      end
    end

    if has then
      return spell:Cast(enemy, {face = true}) and blink.alert("Disarm (" .. colors.red .. (str) .. "|r)", spell.id)
    end

    if enemy.class2
    and disarmClasses[enemy.class2]
    and enemy.role == "melee"
    and enemy.isPlayer 
    and not enemy.immunePhysicalEffects
    and not enemy.isHealer then
      if lowest < 60 + bin(enemy.buffFrom(disarmMePls)) * 57 + bin(not healer.exists or not healer.los or healer.cc) * 30 then
        return spell:Cast(enemy, {face = true}) and blink.alert("Disarm " .. colors.orange.. "(Peeling)", spell.id)
      end
    end
    
  end)
end)

local shatterme = {
  -- divine shield
  [642] = { min = 3.5 },
  -- ice block
  [45438] = { min = 3.5 },
  -- hand of protection
  [1022] = { min = 3.5 },
}

shatter:Callback(function(spell)
  
  if not target.enemy then return end

  local has = target.buffFrom(shatterme)
  if not has then return end

  local str = ""
  for i, id in ipairs(has) do
    if i == #has then
      str = str .. C_Spell.GetSpellInfo(id).name
    else
      str = str .. C_Spell.GetSpellInfo(id).name .. ","
    end
  end

  -- lock movement
  if target.br(has[1]) > blink.buffer + spell.castTime + 0.5
  and target.dist < 29.5
  and target.los then
    if player.moving then
      if saved.moveLockForShatter then
        blink.controlMovement(0.1)
        alert({msg="Lock Movement " .. "|cFFf7f25c[Shatter]", texture=spell.id, duration=0.3})
      else
        alert({msg="Stop Moving to " .. "|cFFf7f25c[Shatter]", texture=spell.id, duration=0.3})
      end
    end
  end

  return spell:Cast(target, face) and alert("Shatter " .. "|cFFf7f25c" .. str, spell.id)

end)

local requiresDest = {
  -- kidney
  [408] = function() return player.sdr >= 0.5 end,
  [2094] = function() return true end,                -- blind
  [107570] = function() return player.sdr >= 0.5 end, -- storm bolt
  [236077] = function() return true end,              -- disarm
  [1833] = function() return player.sdr == 1 end,     -- cheap shot
  [207777] = function() return true end,              -- dismantle
  [22570] = function() return player.sdr >= 0.5 end,  -- maim
  [5211] = function() return player.sdr >= 0.5 end,   -- mighty bash
  [6789] = function() return player.idr == 1 end,     -- mortal coil
  [89766] = function() return player.sdr == 1 end,    -- axe toss
  [853] = function() return player.sdr >= 0.5 end,    -- hammer of justice
  [211881] = function() return player.sdr >= 0.5 end, -- fel eruption
  [221562] = function() return player.sdr >= 0.5 end, -- asphyxiate 
  [64044] = function() return player.sdr == 1 end,    -- psychic horror
  [19577] = function() return player.sdr >= 0.5 end,  -- intimidation 
  -- chastise stun..
}

local noDest = {
  -- dragon's breath
  [31661] = function(src)                           
    return src and src.rotation and player.arc(8, 45, src) 
  end,
  -- blinding light
  [115750] = function(src)
    return src and src.distanceLiteral < 10 and player.ddr >= 0.5
  end,
  -- leg sweep
  [119381] = function(src)
    return src and src.distanceLiteral < 7 and player.sdr >= 0.5
  end,
  -- chaos nova
  [179057] = function(src)
    return src and src.distanceLiteral < 10 and player.sdr >= 0.5
  end,
}

-- prestorm events
onEvent(function(info, event, source, dest)
  local time = GetTime()
  if event ~= "SPELL_CAST_SUCCESS" then return end
  
  local spellID, spellName = select(12, unpack(info))
  -- if spellID == 324631 and source.isUnit(player) then
  --   blink.controlMovement(0.25)
  -- end
  
  --! only enemy stuff below
  if not source.enemy then return end
  local events = blink.events

  if spellID then
    if requiresDest[spellID] and dest.isUnit(player) and requiresDest[spellID]()
    or noDest[spellID] and noDest[spellID](source, dest) then
      local ticks = 0
      local function yolo(self)
        ticks = ticks + 1
        if (blink.SpellQueued or blink.QueuedSpell) == bladestorm.id or bladestorm.current then self:Cancel() return end
        blink.call("SpellCancelQueuedSpell")
        blink.SpellQueued = nil
        blink.QueuedSpell = nil
        if bladestorm:Cast({ ignoreCC = true }) then
          blink.alert("Bladestorm " .. "|cFFf7f25c" .. spellName, bladestorm.id)
        end
        if ticks >= 10 then
          self:Cancel()
        end
      end
      C_Timer.NewTicker(0, yolo)      
    end
  end

end)

bladestorm:Callback("pve", function(spell)
  if not target.exists or target.dist > 5 then return end
  if overpower.cd - blink.gcdRemains == 0 
  or mortal.cd - blink.gcdRemains == 0 then
    return
  end
  if blink.enemies.around(player, 7, function(o) return o.bcc and not o.isPet end) > 0 then return end
  return spell:Cast() and alert("Bladestorm ", spell.id)
end)

bladestorm:Callback("roots", function(spell)
  if blink.enemies.around(player, 7, function(o) return o.bcc and not o.isPet end) > 0 then return end
  if player.rootRemains < 2 then return end
  if not target.enemy or target.predictDist(0.5) > 4.5 then return end
  if not saved.bladestormRoots then return end
  return spell:Cast() and alert("Bladestorm " .. "|cFFf7f25c[Rooted]", spell.id)
end)

bladestorm:Callback("sharpen", function(spell)
  if not saved.bladestormUnhinged then return end
  if target.dist > 6 then return end  
  if target.immunePhysicalDamage then return end 

  if blink.enemies.around(player, 7, function(o) return o.bcc and not o.isPet end) > 0 then return end
  if not target.enemy or target.predictDist(0.5) > 8 then return end
  if not player.hasTalent(227847) then return end
  local BladeStormIT = player.buff(sharpen.id)
  if BladeStormIT or blink.burst then
    return spell:Cast() and alert("Bladestorm " .. "|cFFf7f25c[Unhinged]", spell.id)
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

pummel:Callback("interrupt", function(spell)
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
          performInterrupt(enemy, "Pummel ")
        else
          performInterrupt(enemy, "Pummel ", saved.kickCClist)
        end
      end

      if kickPVE then
        performInterrupt(enemy, "Pummel ")
      elseif kickFastMD then
        performInterrupt(enemy, "Pummel ", saved.kickHealinglist)
      elseif kickHealer then
        performInterrupt(enemy, "Pummel ", saved.kickHealinglist)
      elseif kickDangerous then
        performInterrupt(enemy, "Pummel ", saved.kickDangerouslist)
      elseif kickCC then
        performInterrupt(enemy, "Pummel ", saved.kickCClist)
      elseif kickHybrid then
        performInterrupt(enemy, "Pummel ")
      elseif dontKickAvoidableCC then
        performInterrupt(enemy, "Pummel ", saved.kickCClist)
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

-- pummel:Callback("interrupt", function(spell)

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
--             alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--             alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--             alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--             alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--                 alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
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
--               alert("Pummel " .. "|cFFf7f25c[" .. (enemy.casting or enemy.channel) .. "]", spell.id)  
--             end
--           end
--         end) 
--       end   
--     end
--   end)
-- end)

pummel:Callback("tyrants", function(spell)
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
            alert("Pummel " .. "|cFFf7f25c[" .. (tyrant.casting or tyrant.channel) .. "]", spell.id)  
          end
        end
      end) 
      
    end

  end)

end)

pummel:Callback("seduction", function(spell)
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
                alert("Pummel " .. "|cFFf7f25c[" .. (EnemyPet.casting or EnemyPet.channel) .. "]", spell.id)  
              end
            end
          end)

        end
      end
    end)
  end
end)

--Storm Bolts
local function WeCanStun(unit)

  if unit.exists 
  and unit.stunDR >= 0.5 
  and unit.ccRemains < 2
  and unit.los
  and not unit.immunePhysicalEffects 
  and not unit.immuneStuns 
  and not unit.buffFrom(ImmuneToWarriorStun) then 

    return true

  else

    local errorMessage = "|cFFf7f25c[Check]: |cFFf74a4a"

    if not unit.exists then
      blink.alert(errorMessage .. "Unit doesn't exist!", stormBolt.id) 
    elseif (unit.immuneStuns or unit.immunePhysicalEffects or unit.distance > 20 or unit.buffsFrom(ImmuneToWarriorStun) > 0) then
      blink.alert(errorMessage .. "Can't Storm Bolt! [" .. (unit.classString or "") .. "]", stormBolt.id)    
    elseif unit.stunDR < 0.5 then
      blink.alert(errorMessage .. "Waiting DR To use Storm Bolt on [" .. (unit.classString or "") .. "]", stormBolt.id)	  
    end

  end		
end

stormBolt:Callback("command", function(spell)

  --Focus
  if blink.MacrosQueued['bolt focus'] then
    if WeCanStun(focus) then 

      if not WeCanStun(focus) then return end

      if spell:Cast(focus) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFStorm Bolt! [" .. focus.classString .. "]", spell.id)
      end	 
    end
  end

  --Target
	if blink.MacrosQueued['bolt target'] then
    if WeCanStun(target) then 

      if not WeCanStun(target) then return end

      if spell:Cast(target) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFStorm Bolt! [" .. target.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena1
  if blink.MacrosQueued['bolt arena1'] then
    if WeCanStun(arena1) then 

      if not WeCanStun(arena1) then return end

      if spell:Cast(arena1) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFStorm Bolt! [" .. arena1.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena2
  if blink.MacrosQueued['bolt arena2'] then
    if WeCanStun(arena2) then 

      if not WeCanStun(arena2) then return end

      if spell:Cast(arena2) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFStorm Bolt! [" .. arena2.classString .. "]", spell.id)
      end	 
    end
  end

  --Arena3
  if blink.MacrosQueued['bolt arena3'] then
    if WeCanStun(arena3) then 
      
      if not WeCanStun(arena3) then return end

      if spell:Cast(arena3) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFStorm Bolt! [" .. arena3.classString .. "]", spell.id)
      end	 
    end
  end

  --EnemyHealer
  if blink.MacrosQueued['bolt enemyhealer'] then
    if WeCanStun(enemyHealer) then 

      if not WeCanStun(enemyHealer) then return end

      if spell:Cast(enemyHealer) then
        alert("|cFFf7f25c[Manual]: |cFFFFFFFFStorm Bolt! [" .. enemyHealer.classString .. "]", spell.id)
      end	 
    end
  end

end)

stormBolt:Callback(function(spell)
  
  local tar = saved.boltTarget
  if tar == "none" then return end

  local unit = blink[tar]

  if not unit.player then return end
  if not unit.enemy then return end
  if unit.sdr ~= 1 then return end
  if unit.ccr > 0.5 then return end

  if tar == "target" and unit.buff(5487) and unit.hp > 30 then
    return
  end

  local should = saved.sbOffDR

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

    if target.hpa < 72 + bin(player.cds or avatar.cd <= 1 and blink.burst) * 15 + bin(cross) * 14 then
      pressure = true
    end

    should = saved.sbBigPressure and pressure
          or saved.sbCrossCC and cross
  end

  return should and spell:Cast(unit, {face=true}) and alert("Storm Bolt " .. unit.classString, spell.id)

end)

shockWave:Callback(function(spell)

  if not player.hasTalent(46968) then return end
  if target.buffFrom(FullyImmuneBuffs) or target.debuffFrom(FullyImmuneDeBuffs) then return end

  local bin = blink.bin
  local shockwaveAngle = 35
  local caught = 0

  blink.enemies.loop(function(enemy)

    caught = caught + bin(enemy.distance <= 7 and player.facing(enemy, shockwaveAngle) and not (enemy.bcc or enemy.stunned or enemy.sdr < 1) )
    targetCaught = target.exists and target.distance <= 7 and player.facing(target, shockwaveAngle) and not (target.bcc or target.stunned or target.sdr < 1)

    --if not enemy.player then return end
    if enemy.sdr ~= 1 then return end
    if enemy.ccr > 0.5 then return end

    if enemy.buff(5487) and enemy.hp > 30 then
      return
    end

    local cross, pressure = false, false
    
    if enemyHealer.exists and not enemy.isUnit(enemyHealer) then
      cross = enemyHealer.cc and enemyHealer.ccr > 1
    else
      if enemy.cc and enemy.ccr > 1 then cross = true return true end
    end

    if target.hp < 72 + bin(player.cds or avatar.cd <= 1 and blink.burst) * 15 then
      pressure = true
    end

    should = saved.swBigPressure and pressure

    if caught >= 1 and targetCaught then

      if not targetCaught then return end

      return should and spell:Cast() and alert("Shockwave " .. enemy.classString, spell.id)
    end

  end)

end)

rally:Callback(function(spell)
  if not saved.autoRally then return end
  local thresh = saved.rallyHP
  local hccm = bin(not healer or healer.exists and healer.cc)
  thresh = thresh + hccm * 5
  thresh = thresh * (1 + hccm * 0.1)
  fgroup.loop(function(member)
    if member.visible and member.distance < 35 and member.hpa <= thresh then
      return spell:Cast() and alert("Rallying Cry " .. (member.isUnit(player) and "|cFFf7f25c[Player]" or member.classString), spell.id)
    end
  end)
end)

deathWish:Callback(function(spell)
  if player.buffStacks(199261) >= 10 then return end
  if player.hp < 40 then return end
  return spell:CastAlert()
end)

deathWish:Callback("prio", function(spell)
  if player.buffStacks(199261) >= 10 then
    if player.buffRemains(199261) > spell.gcd * 2 + (100 - saved.pussyPct) / 100 then return end
  elseif player.buff(199261) or saved.pussyPct <= 10 then
    if saved.pussyPct < 20 then
      -- we aint no pussy
    else 
      if player.buffRemains(199261) > spell.gcd * 2 then return end
    end
  end
  if player.hp < 40 - bin(saved.pussyPct <= 1) * 20 + bin(saved.pussyPct >= 40) * 35 then return end
  return spell:CastAlert()
end)

-- reflect: 
--[[
  repentance when we don't have zerk or pala is >= half idr
  sheep when we are at least half idr or mage is full dr and not our target
  mindgames at all times
  some pre-hoj reflects?
  clones >= half dr, or if druid is on full dr

]]

local reflects = {
  --mage combust
  [190319] = function(source)
    return source.buff(190319) and source.buffRemains(190319) >= 5 and source.distanceLiteral <= 34
  end,
  --Arcane Surge
  [365362] = function(source)
    return source.buff(365362) and source.buffRemains(365362) >= 3 and source.distanceLiteral <= 34
  end,
  --ele Primordial Wave
  [365362] = function(source)
    return source.buff(375986) and source.buffRemains(375986) >= 3 and source.distanceLiteral <= 34
  end,
  --Boomie
  [365362] = function(source)
    return source.buff(202425) and source.buffRemains(202425) >= 3 and source.distanceLiteral <= 34
  end,
  -- repentance
  [20066] = function(source)
    return zerk.cd > 1 or source.idr == 1
  end,
  -- mindgames
  [375901] = function() 
    return true 
  end,
  -- glacial
  [199786] = function() 
    return true 
  end,
  -- clone
  [33786] = function(source)
    return player.ddr >= 0.5 or source.ddr == 1 and not source.isUnit(target)
  end,
  -- fear
  [5782] = function(source)
    return zerk.cd > 1 or source.ddr == 1 and not source.isUnit(target)
  end,
  -- chaos bolt
  [116858] = function(source)
    return source.cds or player.hp < 80 + bin(not healer.exists or healer.cc) * 20
  end,
  -- sleep walk
  [5782] = function(source)
    return source.disorientDR == 1 and not source.isUnit(target)
  end,
  
  -- hex ( start of hexes )
  [277784] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [309328] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [269352] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [289419] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [211004] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [51514] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [210873] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [211015] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [219215] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [277778] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [17172] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [66054] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [11641] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [271930] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [270492] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [18503] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,

  [289419] = function(source)
    return (player.idr >= 0.5 or source.idr == 1)
  end,
  --end of hexes
}

-- sheeps
for _, sheep in ipairs(blink.spells.sheeps) do 
  reflects[sheep] = function(source)
    return player.idr >= 0.5 or source.idr == 1
  end
end

reflect:Callback(function(spell)
  blink.enemies.loop(function(enemy)
    local cast = enemy.castID

    if not cast then return end
    if not enemy.castTarget.isUnit(player) then return end
    if not reflects[cast] or not reflects[cast](enemy) then return end
    --cc reflects check
    if enemy.castRemains > blink.buffer + blink.tickRate then return end

    return spell:Cast() and alert("Reflect " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", spell.id, true)
  end)
end)

reflect:Callback("CDs",function(spell)

  local cast = enemy.castID
  local distance = enemy.distanceLiteral
  local buffRemains
  
  blink.enemies.loop(function(enemy)
    --mage combust
    if blink.fighting(63) then
      if enemy.buff(190319) 
      and distance <= 34 
      and enemy.buffRemains(190319) >= 5 
      and enemy.target.isUnit(player) then
        return spell:Cast() and alert("Reflect " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", spell.id, true)
      end
    end

    --Arcane Surge
    if blink.fighting(62) then
      if enemy.buff(365362) 
      and distance <= 34 
      and enemy.buffRemains(365362) >= 3 
      and enemy.target.isUnit(player) then
        return spell:Cast() and alert("Reflect " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", spell.id, true)
      end
    end

    --ele Primordial Wave
    if blink.fighting(262) then
      if enemy.buff(375986) 
      and distance <= 34 
      and enemy.buffRemains(375986) >= 3 
      and enemy.target.isUnit(player) then
        return spell:Cast() and alert("Reflect " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", spell.id, true)
      end
    end

    --Boomie
    if blink.fighting(102) then
      if enemy.buff(202425) 
      and distance <= 34 
      and enemy.target.isUnit(player) then
        return spell:Cast() and alert("Reflect " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", spell.id, true)
      end
    end
  end)

end)


local warBannerIt = {
  -- repentance
  [20066] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5 and zerk.cd > 1) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  -- clone
  [33786] = function(source)
    return (source.castTarget.isUnit(player) and player.ddr >= 0.5) or (source.castTarget.isUnit(healer) and healer.ddr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  -- fear
  [5782] = function(source)
    return (source.castTarget.isUnit(player) and player.ddr >= 0.5 and zerk.cd > 1) or (source.castTarget.isUnit(healer) and healer.ddr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  -- sleep walk
  [5782] = function(source)
    return (source.castTarget.isUnit(player) and player.ddr >= 0.5 and zerk.cd > 1) or (source.castTarget.isUnit(healer) and healer.ddr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  -- hex ( start of hexes )
  [277784] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [309328] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [269352] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [289419] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [211004] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [51514] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [210873] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [211015] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [219215] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [277778] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [17172] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [66054] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [11641] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [271930] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [270492] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [18503] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,

  [289419] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end,
  --end of hexes
}

-- sheeps
for _, sheep in ipairs(blink.spells.sheeps) do 
  warBannerIt[sheep] = function(source)
    return (source.castTarget.isUnit(player) and player.idr >= 0.5) or (source.castTarget.isUnit(healer) and healer.idr >= 0.5 and player.distanceToLiteral(healer) <= 29)
  end
end

warBanner:Callback("cc",function(spell)
  if not player.hasTalent(spell.id) then return end
  if not saved.autoWarBanner then return end
  blink.enemies.loop(function(enemy)
    local cast = enemy.castID
    if not cast then return end
    if enemy.castRemains > blink.buffer + blink.tickRate then return end
    if enemy.castTarget.isUnit(player) and player.buff(reflect.id) or reflect.current or reflect.cd == 0 then return end
    if not warBannerIt[cast] or not warBannerIt[cast](enemy) then return end
    return spell:Cast() and alert("War Banner " .. "|cFFf7f25c[" .. C_Spell.GetSpellInfo(cast).name .. "|cFFf7f25c]", spell.id)
  end)
end)

-- aio stomperoni
-- function arms:Stomp()
--   if blink.gcdRemains > blink.spellCastBuffer then return end
--   local enrage = player.buffRemains(184362)
--   stomp(function(totem)
--     if overpower.charges > 0 and totem.los then
--       return (crushing:Cast(totem, face) or raging:Cast(totem, face)) and alert("Stomp "..colors.cyan..totem.name, crushing.id)
--     elseif bloodthirst:Cast(totem, face) or bloodbath:Cast(totem, face) then
--       return alert("Stomp "..colors.cyan..totem.name, bloodthirst.id)
--     elseif totem.hpLiteral <= 7000 and heroicThrow:Cast(totem, face) then
--       return alert("Stomp "..colors.cyan..totem.name, heroicThrow.id)
--     else
--       if crushing:Cast(totem, face) then
--         return alert("Stomp "..colors.cyan..totem.name, crushing.id)
--       elseif raging:Cast(totem, face) then
--         return alert("Stomp "..colors.cyan..totem.name, raging.id)
--       elseif bloodbath:Cast(totem, face) then
--         return alert("Stomp "..colors.cyan..totem.name, bloodbath.id)
--       elseif bloodthirst:Cast(totem, face) then
--         return alert("Stomp "..colors.cyan..totem.name, bloodthirst.id)
--       elseif slam:Cast(totem, face) then
--         return alert("Stomp "..colors.cyan..totem.name, slam.id)
--       end
--     end
--   end)
-- end
leap:Callback("fear", function(spell)
  return spell:AoECast(enemyHealer) and alert("Leap To Fear " .. "|cFFf7f25c[Healer]", spell.id)
end)

charge:Callback("fear", function(spell)
  return spell:Cast(enemyHealer) and alert("Charge To Fear " .. "|cFFf7f25c[Healer]", spell.id)
end)

intim:Callback("cc healer", function(spell)
  if not saved.fearHealer then return end
  local TremorUp = blink.units.find(function(unit) return unit.enemy and unit.id == 5913 and unit.dist <= 30 end)
  if TremorUp then return end --blink.alert(colors.red .. "Can't Fear Tremor is up", 8143) end
  if not enemyHealer.exists then return end
  if enemyHealer.ddr == 1
  and sr.lowest(enemies) < 70
  and enemyHealer.ccr <= 1
  and not enemyHealer.isUnit(target)
  and enemyHealer.v2attackers(true) == 0 then
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
    if sac_rem < 1 then

      --leap then
      if enemyHealer.dist > 16 
      and enemyHealer.los 
      and spell:Castable(enemyHealer)
      and saved.leapToFearHealer then
        leap("fear")
      else
        return spell:Cast(enemyHealer) and alert("Fear " .. "|cFFf7f25c[Healer]", spell.id)
      end
      
      --Charge if there is no leap
      if enemyHealer.dist > 16 
      and enemyHealer.los 
      and spell:Castable(enemyHealer)
      and leap.cd - blink.gcdRemains == 0
      and saved.chargeToFearHealer then
        charge("fear")
      else
        return spell:Cast(enemyHealer) and alert("Fear " .. "|cFFf7f25c[Healer]", spell.id)
      end
    end
  end
end)

intim:Callback("fear bomb", function(spell)
  -- if not blink.arena then return end
  -- if saved.fearBombCount >= 5 then return end
  -- if enemies.around(player, 8, function(o) return o.player and o.ddr == 1 and o.los and (not o.cc or o.ccr < 2) end) > saved.fearBombCount then
  --   enemies.loop(function(enemy)
  --     return spell:Cast(enemy) and alert("Intimidating Shout "..colors.cyan.."Fear Bomb", spell.id)
  --   end)
  -- end
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
      if player.class2 == "WARRIOR"
      and intim.cd - blink.gcdRemains < 0.5 then
        local x,y,z = player.position()
        draw:SetColor(0, 255, 0)
        draw:SetWidth(3)
        draw:Circle(x,y,z,10.5)
        draw:Text(blink.textureEscape(5246, 20) .. "Intimidating Shout Range", BlinkFontNormal, x,y,z)
      end
    end
  end)
end 

drawFearCircle()

intim:Callback("command", function(spell)
  if spell.cd - blink.gcdRemains > 0 then return end

  local function tryCastSpellOnTarget(unit)

    if unit.exists
    and unit.enemy
    and player.distanceTo(unit) <= spell.range 
    and unit.ddr >= 0.5 
    and not unit.immunePhysicalEffects
    and not unit.buffFrom(ImmuneToWarriorStun) then 
  
      if spell:Cast(unit, { face = true }) then
        return alert("|cFFf7f25c[Manual]: |cFFFFFFFFIntimidating Shout [" .. unit.classString .. "]", spell.id)
      end
  
    else
  
      local errorMessage = "|cFFf7f25c[Check]: |cFFf74a4a"
  
      if not unit.exists then
        blink.alert(errorMessage .. "Unit doesn't exist!", spell.id) 
      elseif (player.distanceTo(unit) > spell.range or unit.immunePhysicalEffects or unit.buffsFrom(ImmuneToWarriorStun)) > 0 then
        blink.alert(errorMessage .. "Can't Intimidating Shout! [" .. (unit.classString or "") .. "]", spell.id)    
      elseif unit.ddr < 0.5 then
        blink.alert(errorMessage .. "Waiting DR To use Intimidating Shout! [" .. (unit.classString or "") .. "]", spell.id)	  
      end
  
    end
  end
  -- local function tryCastSpellOnTarget(unit)
  --   if unit.exists
  --   and unit.enemy
  --   and player.distanceTo(unit) <= spell.range 
  --   and unit.ddr >= 0.5 
  --   and not unit.immunePhysicalEffects then
  --     if spell:Cast(unit, { face = true }) then
  --       return alert("|cFFf7f25c[Manual]: |cFFFFFFFFIntimidating Shout [" .. unit.classString .. "]", spell.id)
  --     end
  --   elseif not unit.exists then
  --     return alert("|cFFf7f25c[Check]: |cFFf74a4aUnit doesn't exists!", spell.id) 
  --   elseif (player.distanceTo(unit) > spell.range or unit.immunePhysicalEffects or unit.buffsFrom(ImmuneToWarriorStun) > 0) then
  --     return alert("|cFFf7f25c[Check]: |cFFf74a4aCan't Intimidating Shout! [" .. unit.classString .. "]", spell.id)    
  --   elseif unit.ddr < 0.5 then
  --     return alert("|cFFf7f25c[Check]: |cFFf74a4aWaiting DR To use Intimidating Shout! [" .. unit.classString .. "]", spell.id)      
  --   end        
  -- end

  -- Table of possible targets
  local targets = {
    ['fear target'] = blink.target,
    ['fear focus'] = blink.focus,
    ['fear arena1'] = blink.arena1,
    ['fear arena2'] = blink.arena2,
    ['fear arena3'] = blink.arena3,
    ['fear enemyhealer'] = blink.enemyHealer,
  }

  for macro, unit in pairs(targets) do
    if blink.MacrosQueued[macro] and unit then
      tryCastSpellOnTarget(unit)
      break
    end
  end
end)

intim:Callback("fear tyrant", function(spell)
  if not blink.arena then return end
  if not saved.FearTyrant then return end
  if blink.fighting(266, true) then 
    blink.tyrants.loop(function(tyrant)
      if tyrant.dist > 8 then return end
      if spell:Cast(tyrant, {face = true}) then 
        if not saved.streamingMode then
          alert("Fear " .. "|cFFf7f25c[Tyrant]", spell.id)  
        end
      end
    end)
  end
end)

intim:Callback("defensive", function(spell)

  if not saved.fearDefensive then return end

  local lowf = sr.lowest(fgroup)

  -- enemy pressure mod
  local epm = 0
  epm = epm + bin(lowf < 80) * 0.15
  epm = epm + bin(lowf < 60) * 0.15
  epm = epm + bin(lowf < 45) * 0.35
  epm = epm + bin(lowf < 30) * 0.45
  epm = epm + bin(lowf < 22) * 0.3

  epm = epm * (1 + bin(not healer.exists or healer.cc) * 0.4)

  local fearValue = 0
  enemies.loop(function(enemy)
    if enemy.class2 == "WARRIOR" and enemy.cooldown(18499) < 6 then return end
    if not spell:Castable(enemy) then return end
    if enemy.cc and enemy.ccr > 1 then return end
    
    local val = 0
    val = val + bin(enemy.cds) * 30
    val = val + bin(enemy.role ~= "healer") * 30
    
    fearValue = fearValue + val

  end)

  if fearValue * epm > 29 then
    enemies.loop(function(enemy)
      return spell:Cast(enemy) and alert("Intimidating Shout " .. "|cFFf7f25c[Defensive]", spell.id)
    end)
  end

end)

bitter:Callback("emergency", function(spell)

  if not saved.bitter then return end
  if blink.fighting(102, true) 
  and player.debuff(360194) then 

    return spell:Cast() and alert("Bitter Immunity "..colors.rogue.."[Deathmark]", spell.id)

  else

    local count, _, _, cds = player.v2attackers()
  
    local threshold = 17
    threshold = threshold + bin(player.hp <= saved.bitterHP) * 12
    threshold = threshold + count * 5
    threshold = threshold + cds * 9
  
    threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.hp <= saved.bitterHP) * 0.35)
  
    if player.hpa > threshold then return end
    if player.hp > saved.bitterHP then return end
    if not player.combat then return end
  
    if player.casting or player.channeling then
      blink.call("SpellStopCasting")
      blink.call("SpellStopCasting")
    end
    
    if spell:Cast() then
      alert("Bitter Immunity" ..colors.red .. " [Danger]", spell.id, true)
    end
  
  end

end)


local comps = {
  subRM = {261, "MAGE"}
}

intervene:Callback(function(spell)

  if not saved.autoIntervene then return end

  local fightingSubRogue = blink.fighting(261, true)
  local movingTowardTarget = target.enemy and player.movingToward(target, { duration = 0.2, angle = 65 })
  local thpMod = 1
  if target.enemy then
    thpMod = thpMod + bin(player.cds) * 0.25
    thpMod = thpMod + bin(target.hp < 60) * 0.25
    thpMod = thpMod + bin(target.hp < 45) * 0.3
    thpMod = thpMod + bin(target.hp < 30) * 0.3
  end
  -- need to have an explicit gap close intervene
    -- rather than this ghetto ass mixture of defensive / gapclose
    -- have it explicitly get best gap close value
  -- help healer freecast vs melee kicks
  -- gap close, get to target when we got preshah
  -- big mm dmg on teammate in trubski
  -- kidney from assa/outlaw rogs!

  blink.group.loop(function(member)
    
    -- general peely dmg thingo
    local count, melee = member.v2attackers()
    -- if melee > 0 or thpMod > 1 then
    --   local distDiff = not target.enemy and 0
    --         or target.dist - member.distanceTo(target)
    --         -- add a bit to this based on target hp def
    --   if distDiff > 6.5 then
    --     distDiff = distDiff * 2
    --   end
    --   if distDiff < 0 then 
    --     distDiff = distDiff / 3.5 - thpMod
    --   else
    --     distDiff = distDiff * thpMod
    --   end
    --   if member.hp < 5 + melee * 26 + bin(movingTowardTarget) * (distDiff * 8) + distDiff * 6 + bin(member.stunned) * 26.5 then
    --     return spell:Cast(member) and alert("Intervene " .. "|cFFf7f25c[Gapclose]", spell.id)
    --   end
    -- end

    if movingTowardTarget 
    and target.dist > 20
    and player.distanceTo(member) <= 25
    and member.distanceTo(target) < 8 
    and not target.immunePhysicalDamage then 

      --we can charge him save it for smth els
      if target.los 
      and target.dist <= 25 
      and charge.cd == 0 then 
        return 
      end

      if leap.current then return end

      return spell:Cast(member) and alert("Intervene " .. "|cFFf7f25c[Gapclose]", spell.id)
    end

    -- rm gap their stuns
    if fightingSubRogue 
    and member.stunned 
    and member.stunRemains <= 2 
    and member.stunDR >= 0.5 then
      local rog = blink.enemies.find(function(enemy) return enemy.class2 == "ROGUE" end)
      if rog and rog.target.isUnit(member) then
        return spell:Cast(member) 
        and alert("Intervene " .. "|cFFf7f25c[Eating Stun]", spell.id)
      end
    end
    -- eat sap off blind 
    if member.debuff(2094) and member.debuffRemains(2094) <= 2 then
      return spell:Cast(member) and alert("Intervene " .. "|cFFf7f25c[Blind Sap]", spell.id)
    end

  end)

end)

-- intervene
local defensivesOverLap = {

  186265, --turtle
  196555, --netherwalk
  206803, --rainfromabove
  --61336,  --survival ins
  45438,  --iceblock
  --342246, --altertime
  116849, --ccon
  1022,   --bop
  642,    --bubble
  228049, --guardian prot pala
  --33206,  --PS
  47585,  --disperson
  --47788,  --guardian priest
  5277,   --rogue evaison
  --108271,  --astral shift
  --108416,  --lock shield sac
  118038,  --die by the sowrd
  871,     --shield wall
  357170, --Evoker time dilation
}

warrior.currentDangerousCasts = {}

local dangerDebuffs = {
  [167105]  = { min = 4, weight = 13 },      -- warbreaker
  [386276]  = { min = 6.5, weight = 15 },    -- bonedust brew
  [274838]  = { min = 4, weight = 7 },       -- frenzy 
  [274837]  = { min = 4, weight = 7 },       -- frenzy
  [363830]  = { min = 7.5, weight = 14 },    -- sickle
  [323673]  = { min = 3, weight = 7 },       -- games
  [375901]  = { min = 3, weight = 7 },       -- games
  [385408]  = { min = 7, weight = 8 },       -- sepsis
  -- [324149] = { min = 5 },                 -- flayed shot
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
          local _, _, around = blink.Group.around(obj, 7.5)
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
  warrior.currentDangerousCasts = {}
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
          tinsert(warrior.currentDangerousCasts, {
            source = enemy,
            dest = dest or enemy.castTarget,
            weight = weight
          })
        end
      end
    end
  end
end

function intervene:threshold(unit, bypass)

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
  for _, cast in ipairs(warrior.currentDangerousCasts) do 
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

intervene:Callback("emergency", function(spell, info)
  if not saved.autoIntervene then return end
  -- scan for any dangerous casts
  dangerousCastsScan()

  --blink.group.sort(function(x,y) return x.hp < y.hp end)
  blink.group.sort(function(x,y) return x.attackers2 and y.attackers2 and x.attackers2 > y.attackers2 or x.attackers2 == y.attackers2 and x.hp and y.hp and x.hp < y.hp end)

  blink.group.loop(function(member)
    if member.buffFrom(defensivesOverLap) then return end
    if member.hp > intervene:threshold(member) then return end  
    if member.dist > 25 then return end 

    if member.hp <= intervene:threshold(member) then
      return spell:Cast(member) and alert("Intervene " .. member.classString, spell.id)
    end

  end)

end)

ignorePain:Callback("emergency", function(spell)
  
  -- local count, _, _, cds = player.v2attackers()
  -- local threshold = 15.5
  -- threshold = threshold + count * 5.5
  -- threshold = threshold + cds * 7.5
  -- threshold = threshold * (0.8 + bin(not healer.exists or healer.cc and healer.ccr > 1) * 1.25)
  -- threshold = threshold * saved.ipSensitivity

  if player.buff(spell.id) then return end
  if player.rage < 40 then return end

  if player.hp < saved.IgnorePainSensitivity then
    return spell:Cast() and alert("Ignore Pain " .. colors.red.."[Danger]", spell.id)
  end
end)


escapeArt:Callback("gnome", function(spell)
  if player.race ~= "Gnome" then return end
  if target.meleeRange or not player.rooted or not target.exists then return end

  local specificValue = 150 -- Define a specific value threshold for casting, adjust based on testing
  local rootMultiplier = 15 -- Multiplier for the root duration's influence

  local thresh = 100
  thresh = thresh + blink.bin(not enemyHealer.exists or enemyHealer.cc) * 26
  thresh = thresh + blink.bin(player.rooted and target.movingAwayFrom(player, { duration = 0.5 })) * 46
  thresh = thresh + blink.bin(player.rooted and player.cds) * 40
  thresh = thresh + target.distLiteral
  thresh = thresh + (player.rootRemains * rootMultiplier) -- Incorporating root duration into the threshold

  if thresh > specificValue 
  and not target.meleeRange then
    return spell:CastAlert()
  end
end)


--! TOTEM STOMPAGE !--

local fearClasses = {"WARLOCK", "PRIEST", "WARRIOR"}

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

local importantTotems = {
  [5913] = fearClassOnTeam, -- Tremor
  [2630] = function(totem) return isNearFriendOrPet(totem) end, -- Earthbind
  [60561] = function(totem) return isNearFriendOrPet(totem) end, -- Earthgrab
  [61245] = function(totem) return isNearFriendOrPet(totem) end, --Capacitor 
  [179867] = function(totem) return isNearFriendOrPet(totem) end, --Static Field Totem 
  [59764] = function(totem, uptime) return uptime < 8 end,  --Healing Tide
}

-- hook stomp
hookCallbacks(function()
  for _, member in ipairs(blink.fgroup) do 
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
heroicThrow:Callback("stomp", function(spell)
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if totem.hpLiteral > 7000 then return end
    if player.distanceTo(totem) <= 30 and player.distanceTo(totem) > 8 and player.losOf(totem) then
      if spell:Cast(totem, { face = true }) then
        return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
      end
    end
  end)
end)

overpower:Callback("stomp", function(spell)
  if not saved.autoStomp then return end
  return stomp(function(totem)
    if not totem.id or not saved.totems[totem.id] then return end
    if not totem.los then return end
    if totem.dist > 6 then return end

    if spell:Cast(totem, { face = true }) then
      return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
    end

  end)
end)