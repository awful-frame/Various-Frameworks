local Unlocker, blink = ...
local random, select, max, ipairs, pairs, GetTime, UnitGUID = math.random, select, max, ipairs, pairs, GetTime, UnitGUID
local CombatLog_String_SchoolString = CombatLog_String_SchoolString
local player, target, focus, healer, enemyHealer = blink.player, blink.target, blink.focus, blink.healer, blink.enemyHealer
local bin, tinsert = blink.bin, tinsert

local jukes, lockouts = {}, {}
blink.jukes, blink.lockouts = jukes, lockouts

local MAX_JUKE_ATTEMPTS = 6
local MIN_JUKE_ATTEMPTS = 3
local MIN_JUKE_RESET_EXTENSION = 0.5
local MAX_JUKE_RESET_EXTENSION = 2.75

-- list of other random stops / micro cc (grip, stuns, blabla) 
-- spell school importance per spec (holy very important for holy! nature important for druid!)
-- drawings for fake casting / blink from interrupt intent!!!!
-- actual interrupt logic ;p
local interrupts = {
  {
    id = 183752,
    name = "Disrupt",
    duration = 3,
    school = "Magic",
    range = 10,
    has = function(self, unit)
      return unit.class2 == "DEMONHUNTER"
    end,
    -- estimate how long until they can interrupt the unit
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 351338,
    name = "Quell",
    duration = 4,
    school = "Physical",
    range = 25,
    has = function(self, unit)
      return unit.class2 == "EVOKER"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 6552,
    name = "Pummel",
    duration = 4,
    school = "Physical",
    range = 5,
    has = function(self, unit)
      return unit.class2 == "WARRIOR"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 147362,
    name = "Counter Shot",
    duration = 3,
    school = "Physical",
    range = 40,
    has = function(self, unit)
      return unit.class2 == "HUNTER" and unit.spec ~= "Survival"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr, unit.buffRemains(186265))
      return eta
    end
  },
  {
    id = 356727,
    name = "Spider Venom",
    duration = 3,
    school = "Magic",
    range = 40,
    has = function(self, unit)
      return unit.class2 == "HUNTER"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 119910,
    name = "Spell Lock",
    duration = 6,
    school = "Magic",
    range = 40,
    has = function(self, unit)
      return unit.class2 == "WARLOCK" and not unit.buff(196099)
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 2139,
    name = "Counterspell",
    duration = 6,
    school = "Magic",
    range = 40,
    has = function(self, unit)
      return unit.class2 == "MAGE"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr, unit.silenceRemains, unit.lockouts.arcane and unit.lockouts.arcane.remains or 0)
      return eta
    end
  },
  {
    id = 1766,
    name = "Kick",
    duration = 5,
    school = "Physical",
    range = 5,
    has = function(self, unit)
      return unit.class2 == "ROGUE"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    -- spell lock with pet, without grimoire
    id = 119910,
    name = "Spell Lock",
    duration = 6,
    school = "Magic",
    range = 40,
    has = function(self, unit)
      return unit.class2 == "WARLOCK" and not unit.buff(196099)
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    -- spell lock with grimoire
    id = 132409,
    name = "Spell Lock",
    duration = 6,
    school = "Magic",
    range = 40,
    has = function(self, unit)
      return unit.class2 == "WARLOCK" and unit.buff(196099)
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 96231,
    name = "Rebuke",
    duration = 4,
    school = "Physical",
    range = 5,
    has = function(self, unit)
      return unit.class2 == "PALADIN"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 106839,
    name = "Skull Bash",
    duration = 4,
    school = "Physical",
    range = 13,
    has = function(self, unit)
      return unit.class2 == "DRUID"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 57994,
    name = "Wind Shear",
    duration = 3,
    school = "Magic",
    range = 30,
    has = function(self, unit)
      return unit.class2 == "SHAMAN"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 116705,
    name = "Spear Hand Strike",
    duration = 4,
    school = "Physical",
    range = 5,
    has = function(self, unit)
      return unit.class2 == "MONK"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 47528,
    name = "Mind Freeze",
    duration = 3,
    school = "Magic",
    range = 15,
    has = function(self, unit)
      return unit.class2 == "DEATHKNIGHT"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  },
  {
    id = 78675,
    name = "Solar Beam",
    duration = 5,
    school = "Magic",
    range = 40,
    has = function(self, unit)
      return unit.class2 == "DRUID" and unit.spec == "Balance"
    end,
    when = function(self, unit, otherUnit)
      local eta = max(unit.cooldown(self.id), otherUnit[self.school .. "EffectImmunityRemains"], unit.ccr)
      return eta
    end
  }
}

-- helpy funcs
local function randms(min, max)
  return random(min * 100, max * 100) / 100
end

local function intByID(id)
  for i, v in ipairs(interrupts) do
    if id == 93985 and v.id == 106839 or v.id == id then
      return v
    end
  end
end

-- effect immunity prob not work as intended w/ gfade
local function interruptETA(unit, otherUnit)
  local eta, interrupt = 0, nil
  for i, v in ipairs(interrupts) do
    if v:has(unit) then
      local when = v:when(unit, otherUnit)
      if eta == 0 or when > eta then
        if when <= blink.buffer + blink.tickRate and v.range <= 15 and not unit.facing(otherUnit, 230) then
          eta = blink.buffer + blink.tickRate + 0.01
          interrupt = v
        else
          eta = when
          interrupt = v
        end
      end
    end
  end
  return eta, interrupt
end

blink.interruptETA = interruptETA

-- simulate whether or not unit can be interrupted at given position
local function canBeInterruptedAtPosition(obj, x, y, z, elapsed)
  local unitEnemies
  if obj.enemy then
    unitEnemies = blink.tjoin(blink.friends, {
      blink.player
    })
  else
    unitEnemies = blink.enemies
  end
  local interruptable = false
  for _, enemy in ipairs(unitEnemies) do
    local eta, interrupt = interruptETA(enemy, obj)
    if eta and interrupt and eta <= elapsed then
      local maxDistTraveled = enemy.speed2 * elapsed
      local dist = enemy.distanceTo(x, y, z)
      -- if enemy.predictLoSOfCoords(x, y, z, elapsed) -- not gonna try to predict LoS .. pointless ? assume they can always get back in los
      if dist - maxDistTraveled < interrupt.range + 0.5 + bin(interrupt.range > 30) * 10 then
        interruptable = true
        break
      end
    end
  end
  return interruptable
end

blink.canBeInterruptedAtPosition = canBeInterruptedAtPosition

-- ! always wipe, front to back
blink.addUpdateCallback(function()
  local time = GetTime()

  -- jukes
  for guid, info in pairs(jukes) do
    if info.reset - time <= 0 then
      jukes[guid] = nil
    end
  end

  -- lockouts
  for guid, locks in pairs(lockouts) do
    for i = #locks, 1, -1 do
      if locks[i].expires - time <= 0 then
        tremove(locks, i)
      end
    end
  end

end)

-- ! track attempted fake casts (self-interrupted spells) !--
blink.addEventCallback(function(self, event, ...)

  --[[
    works on units with a valid unitID, including nameplate units!
  ]]

  local unit = select(1, ...)
  if not unit then
    return
  end
  local pointer = UnitGUID(unit)
  if not pointer then
    return
  end

  local time = GetTime()

  if not jukes[pointer] then
    jukes[pointer] = {
      attempts = 0,
      -- max juke attempts before committing a fast interrupt
      threshold = random(MIN_JUKE_ATTEMPTS, MAX_JUKE_ATTEMPTS),
      reset = time + randms(MIN_JUKE_RESET_EXTENSION, MAX_JUKE_RESET_EXTENSION)
    }
  elseif time - jukes[pointer].fired < 0.15 then
    -- namplate[i] / target can be the same unit fire simultaneously, keeps it from double-counting
    return
  end
  jukes[pointer].attempts = jukes[pointer].attempts + 1
  jukes[pointer].reset = jukes[pointer].reset + randms(MIN_JUKE_RESET_EXTENSION, MAX_JUKE_RESET_EXTENSION)
  jukes[pointer].fired = time

end, "UNIT_SPELLCAST_STOP")

-- ! track interrupt lockouts
blink.onEvent(function(info, event, source, dest)

  if event ~= "SPELL_INTERRUPT" then
    return
  end
  if not dest or not dest.visible then
    return
  end

  local interruptID, interruptName, _, _, spellName, spellSchoolID = select(12, unpack(info))

  local interrupt = intByID(interruptID)
  if not interrupt then
    return
  end

  local school = CombatLog_String_SchoolString(spellSchoolID)
  local guid = dest.guid

  if not lockouts[guid] then
    lockouts[guid] = {}
  end

  tinsert(lockouts[guid], {
    expires = GetTime() + interrupt.duration,
    interrupt = interrupt.id,
    school = school,
    spell = spellName
  })

end)

local castingSchoolsByGUID = {}
blink.addObjectAttribute("castingSchool", function(self)

  if not self.casting then
    return
  end
  local guid = self.guid
  if not guid then
    return
  end

  return castingSchoolsByGUID[guid]

end)

-- ! track cast start schools
blink.addEventCallback(function(info, event, source, dest)

  if event ~= "SPELL_CAST_START" then
    return
  end
  local spellSchoolID = select(14, unpack(info))

  local school = CombatLog_String_SchoolString(spellSchoolID)
  if not school then
    return
  end

  local sourceGUID = source.guid
  if not sourceGUID then
    return
  end

  castingSchoolsByGUID[sourceGUID] = school

end)

local channelingSchoolsByGUID = {}
blink.addObjectAttribute("channelingSchool", function(self)

  if not self.channeling then
    return
  end
  local guid = self.guid
  if not guid then
    return
  end

  return channelingSchoolsByGUID[guid]

end)

-- ! track channeling cast schools
blink.addEventCallback(function(info, event, source, dest)

  if event ~= "SPELL_CAST_SUCCESS" then
    return
  end
  local spellSchoolID = select(14, unpack(info))

  local school = CombatLog_String_SchoolString(spellSchoolID)
  if not school then
    return
  end

  local sourceGUID = source.guid
  if not sourceGUID then
    return
  end

  channelingSchoolsByGUID[sourceGUID] = school

end)

-- ! fake casting {faker module lol}

-- interrupts data (improve efficacy of fake cast attempts by storing data about interrupts history)
-- store the remaining and completed time of cast when each interrupt or fake cast happens
-- store by unit name in blink config .. persistent across sessions / arenas per-player
-- store any fake cast attempts, if they were successful or if enemies specifically held their kick
-- use a pre-defined range of completed/remains cast, weight by any existing interrupts data
-- default to a faster first fake cast attempt (300-500ms?)
-- heavily exploit history of no attempts to interrupt after successful cast or unsuccessful fake cast attempt (no interrupts baited)
-- use a weighted average of all interrupts data for all tracked units to determine the best fake cast attempt 
-- (maybe bad and should use some other algorithm to find patterns in interrupt times)
-- always attempt multiple jukes vs other mages with cs available when going for freesheep 
-- (fast juke > slower juke > fast juke > commit)
-- track when melee are facing us? could be relatively important factor to whether or not they are going to kick us
-- when not facing us at start, and starts turning to face us, immediately fake?
--

local faker = {

  -- time into cast to attempt a juke
  min_completion = 0.3,
  max_completion = 0.95,

  completion = nil, -- set this per-cast

  -- delay after the fake cast attempt before we start casting again
  min_delay = 0.365,
  max_delay = 0.675,

  delay = nil, -- set this per-cast

  -- num fake cast attempts before stopping
  max_attempts = 1,

  -- recent fake cast attempts
  attempts = 0,
  last_attempt = 0,
  reset_time = 3.5,

  -- time we should start casting again (delay_ends)
  delay_ends = 0,

  -- spells to fake cast
  spells = {
    -- this is retarded temporary thing, fix this
    [118] = blink.NewSpell(118)
  }
}

local function updateMaxAttempts()

  faker.max_attempts = random(0, 1)

  -- good chunk of time, just never even fake .. 
  -- then when you do attempt a fake, it's prob more likely to be successful, since you muched other kicks
  if random(1, 2) == 1 then
    faker.max_attempts = 0
  end

  C_Timer.After(3, updateMaxAttempts)

end
updateMaxAttempts()

if not blink.saved.idata then
  blink.saved.idata = {}
end

function faker:LogInterrupt()

end

function faker:LogFake()

end

local shouldFake = blink.shouldFake or {
  [57820] = true,
  [342938] = true
}

function faker:Fake()

  local time = GetTime()
  local castID = player.castID

  if not castID then
    self.delay = nil
    self.completion = nil
    if time - self.last_attempt > self.reset_time then
      self.attempts = 0
    end
    return
  end

  if self.attempts >= self.max_attempts then
    return
  end

  local spell = self.spells[castID]
  if not spell then
    return
  end

  local castTarget = player.castTarget
  local castingCC = shouldFake[castID] or castID == 113724 or tContains(blink.spells.sheeps, castID)

  if not self.delay then
    self.delay = randms(self.min_delay, self.max_delay)
    self.completion = randms(self.min_completion, self.max_completion)

    -- attempt more instant fakes
    if random(1, 5) == 3 then
      self.completion = 0.05
    end
  end

  local mustFinish = castingCC and castTarget.cc and castTarget.ccr < self.delay + spell.castTime + blink.buffer * 2 + blink.tickRate * 2
  if mustFinish then
    return false
  end

  -- not immediately after or while shimmer is queued
  if C_Spell.IsCurrentSpell(212653) or player.used(212653, 1) then
    return false
  end

  -- not while shimmer avail and cast target lining us / not visible :P
  if player.hasTalent(212653) and (not castTarget.predictLoS or not castTarget.predictLoS(0.5)) then
    return false
  end

  if not player.canBeInterrupted(blink.buffer + blink.tickRate) then
    return false
  end

  if player.castTimeComplete >= self.completion then

    self.delay_ends = time + self.delay
    self.attempts = self.attempts + 1
    self.last_attempt = time

    self.delay = nil
    self.completion = nil

    blink.alert("Attempting Fake Cast", castID)
    SpellStopCasting()

    return true

  end

end

blink.faker = faker

-- ! interrupt logic

-- don't interrupt heals while heal target is .. cloned? or super safe (big defensives up)?
-- ring of frost... as a mage, big maybe if it 100% gives healer a gap in cc chain
-- fleshcraft
-- UA, fear, seduction?, chaos bolt (esp 9 stack), drain life when low hp, big demonbolt?

-- Warlock, Paladin, Frost/Arcane Magus, Druid, Sham

local interrupt = {
  -- my interrupt
  mine = nil,

  -- delays
  min_delay = 0.2,
  max_delay = 0.7,
  max_channel_delay = 0.55,

  delay = 0.35,
  cdelay = 0.35,

  -- lowest units
  lowestEnemy = 100,
  lowestFriend = 100,

  -- offensive info
  friends_bursting = {},

  -- defensive info 
  enemies_bursting = {},

  -- constants
  burst_mod = 0.3,
  low_hp_threshold = 65,
  critical_hp_threshold = 35

}

-- ! resurrections
interrupt.res = {
  -- reawaken
  [212051] = function(self, unit)
    return 3
  end,
  -- mass res
  [212036] = function(self, unit)
    return 3
  end,
  -- resurrection
  [2006] = function(self, unit)
    return 3
  end

}

-- ! heals
interrupt.heals = {

  -- !## MONK ##!--

  -- soothing mist
  [115175] = function(self, unit)
    return self:ShouldKickHeal(unit)
  end,
  -- vivify
  [116670] = function(self, unit)
    return self:ShouldKickHeal(unit)
  end,
  -- essence font
  [191837] = function(self, unit)
    return self:ShouldKickHeal(unit, true)
  end,

  -- !## PRIEST ##!--

  -- penance
  [47540] = function(self, unit)
    -- more weight for double kick or rapture up
    return self:ShouldKickHeal(unit, unit.lockouts.shadow or unit.buff(47536))
  end,
  -- shadow mend
  [186263] = function(self, unit)
    -- more weight for double kick
    return self:ShouldKickHeal(unit, unit.lockouts.holy or self.lowestEnemy < 30)
  end,
  -- radiance.. lol?
  [194509] = function(self, unit)
    return self:ShouldKickHeal(unit, true)
  end,
  -- heal
  [2060] = function(self, unit)
    return self:ShouldKickHeal(unit, true)
  end,
  -- divine hymn
  [64843] = function(self, unit)
    return self.lowestEnemy < 68 and 3 or 0
  end,
  -- prayer of healing
  [596] = function(self, unit)
    return self:ShouldKickHeal(unit)
  end,
  -- flash heal
  [2061] = function(self, unit)
    return self:ShouldKickHeal(unit)
  end

}

-- ! cc
interrupt.cc = {

  -- !## MONK ##!--

  -- song of chi ji
  [198898] = function(self, unit)
    -- use interrupt, plus mobility if low enemy
    return 1 + bin(self.lowestEnemy < self.low_hp_threshold) * 1
  end,

  -- !## MAGE ##!--

  -- sheep
  SHEEP = function(self, unit)

    local val = 0
    local castTarget = unit.castTarget

    -- combusting, worth kicking
    if player.buff(190319) then
      val = 1
      -- on us, worth ccing
      if castTarget.isUnit(player) and (player.idr >= 0.5 or player.idrr < 1.3) then
        val = 3
      end
    end

    -- max cast time within lockout duration, healer off dr, worth kicking
    local actor = blink.actor
    if type(actor) == "table" and actor.mage and actor.mage.maxCastTime then
      local mct = actor.mage.maxCastTime
      if mct < 2 and unit.cooldown(2139) < 4.5 then
        val = max(val, 1)
      end
    end

    -- worth stopping on our healer
    if healer.exists then
      if castTarget.isUnit(healer) then
        if healer.idr >= 0.5 -- followup cc, or .. 
        -- not immune to it?
        and (healer.cc or healer.magicEffectImmunityRemains < unit.castRemains and healer.ccImmunityRemains < unit.castRemains and not healer.used(32379, 0.75) and not healer.beast) then
          -- worth blink csing? i guess?
          val = max(val, 2)
        end
      end
      -- or if we don't have a healer...?
    else
      if castTarget.idr and castTarget.idr > 0.5 then
        val = max(val, 1)
      end
    end

    return val

  end,

  -- ! PRIEST !--

  -- mind control (only the channel?)
  [605] = function(self, unit)
    return bin(unit.channelRemains > 4) * 1 + bin(unit.channelRemains > 6.35) * 3
  end

}

-- ! dmg

local function bust_dmg(self, unit)
  return bin(unit.buffRemains(190319) > 1) * 2
end

interrupt.damage = {

  -- !## MONK ##!--

  -- crackling jade lightning
  [117952] = function(self, unit)
    return unit.role == "healer" and self:ShouldKickHeal(unit, true) or 0
  end,

  -- !## MAGE ##!--

  -- fire dmg during combust
  [133] = bust_dmg, -- fireball
  [2948] = bust_dmg, -- scorch
  [11366] = bust_dmg, -- pyro
  [353082] = bust_dmg, -- ring of fire

  -- gpy?
  -- [203286] = function(self, unit) end

  -- !## PRIEST ##!--

  -- mindgames
  [323673] = function(self, unit)

    -- big weight for our healer being in cc or not existing
    local val = 0

    if not healer.exists or healer.cc or (unit.castTarget.hp or 100) < 45 then
      val = 1
      if self.lowestFriend < self.low_hp_threshold then
        val = 2
        if self.lowestFriend < self.critical_hp_threshold then
          val = 4
        end
      end
    end

    return val

  end,

  -- smite
  [585] = function(self, unit)
    -- more weight for holy or double kicks?
    return self:ShouldKickHeal(unit, unit.spec == "Holy" or unit.lockouts.shadow)
  end,

  -- holy fire
  [14914] = function(self, unit)
    return self:ShouldKickHeal(unit)
  end

}

-- ! Misc

local massDispelImmunities = {
  642, -- divine shield
  1022, -- hand of protection
  45438 -- ice block
}

local massDispelCC = blink.tjoin(blink.spells.sheeps, {
  113724, -- ring of frost
  187650, -- freezing trap
  118699, -- fear
  8122 -- psychic scream
})

interrupt.misc = {

  -- !## MAGE ##!--

  -- shifting power
  [314791] = function(self, unit)
    return unit.channelRemains > 3 and 2 or 1
  end,

  -- !## HUNTER ##!--

  -- revive pet
  [982] = function(self, unit)
    return 2
  end,

  -- !## PRIEST ##!--

  -- mass dispel
  [32375] = function(self, unit)
    local val = 0
    blink.fullGroup.loop(function(member)
      -- md immunities
      if member.buffFrom(massDispelImmunities) then
        val = max(val, 4)
      end
    end)
    blink.enemies.loop(function(enemy)
      -- md cc?
      if enemy.debuffFrom(massDispelCC) then
        val = max(val, 4)
      end
    end)
    return val
  end

}

function interrupt:ShouldKickHeal(unit, important)
  local mod = 0.8 + #self.friends_bursting * self.burst_mod + bin(important) * 0.2
  mod = mod + bin(unit.castTarget.stunned) * 0.25
  mod = mod - bin(not unit.healer and enemyHealer.exists and enemyHealer.ccr < self.duration - 100 / self.lowestEnemy) * 0.5

  if self.lowestEnemy < self.critical_hp_threshold * mod then
    -- use mobility to stop it, plus cc if important
    return 2 + bin(important) * 2
  end

  if self.lowestEnemy < self.low_hp_threshold * mod then
    -- use interrupt to stop it, plus cc if important
    return 1 + bin(important) * 2
  end

  return 0
end

function interrupt:Find()
  if self.mine then
    return self.mine
  end
  for _, spell in ipairs(blink.SpellObjects) do
    local int = intByID(spell.id)
    if int then
      spell.interrupt = int
      spell.lockoutDuration = int.duration
      self.mine = spell
      return spell
    end
  end
  return false
end

-- ! perpetual int delay randomizer
function interrupt:UpdateDelays()
  self.delay = randms(self.min_delay, self.max_delay)
  self.cdelay = randms(self.min_delay, self.max_channel_delay)
  if not self.mine then
    self:Find()
  end
  C_Timer.After(1, function()
    interrupt:UpdateDelays()
  end)
end
interrupt:UpdateDelays()

function interrupt:Update()

  self.updated = true

  -- lowest hp units
  local lowestEnemy = (blink.enemies.lowest and blink.enemies.lowest.hpa or 100)
  local lowestFriend = (blink.fullGroup.lowest and blink.fullGroup.lowest.hpa or 100)

  self.lowestEnemy, self.lowestFriend = lowestEnemy, lowestFriend

  -- bursting units
  local friends_bursting, enemies_bursting = {}, {}

  blink.fullGroup.loop(function(friend)
    if friend.cds then
      tinsert(friends_bursting, friend)
    end
  end)

  blink.enemies.loop(function(enemy)
    if enemy.cds then
      tinsert(enemies_bursting, enemy)
    end
  end)

  self.friends_bursting, self.enemies_bursting = friends_bursting, enemies_bursting

end

-- returns

-- {number}, interrupt importance for given unit
-- 0: do not kick
-- 1: should use interrupt to stop it
-- 2: use mobility if necessary (step kick, blink cs)
-- 3: use less-important cc if necessary (db, cheap shot, gouge, blabla) but not mobility.
-- 4: use both mobility and cc if necessary
-- 5: any means necessary, use cc, mobility, or cooldowns poorly if necessary to stop the cast (blind a dps, kidney off target)
-- {boolean}, should we use our off-gcd interrupt ability?

-- ...sometimes good to use mobility but not cc, or vice versa
-- ...(e.g, blink>db on soothing mist makes little sense, step kick does make sense.)
function interrupt:Importance(unit)
  local int = self:Find()
  if not int then
    return false
  end
  if not self.updated then
    self:Update()
  end

  local importance, should = 0, false
  local cast, channel = unit.castID, unit.channelID

  -- after jukes surpass threshold (minus sheep * 1), do a kick at minimum delay plus small randomized delay

  return importance, should
end

blink.addUpdateCallback(function()
  interrupt.updated = false
end)

blink.interrupt = interrupt
