local Unlocker, awful, project = ...
if awful.player.class2 ~= "PRIEST" then return end
if GetSpecialization() ~= 1 then return end
local discipline = project.priest.discipline
local player = awful.player
local target = awful.target
awful.unlock("SpellStopCasting")

awful.print("Gladdy Discipline Priest Loaded")

project.medallion = awful.NewItem(218424)
project.medallion2 = awful.NewItem(216281)
project.healthStone = awful.NewItem(5512)


awful.SpellQueueWindow_Update = 6969696969696969
project.SQW = tonumber(GetCVar("SpellQueueWindow"))
--local TargetSQW = (select(3, GetNetStats())*2)
local TargetSQW = awful.latency
if project.SQW ~= TargetSQW then
SetCVar("SpellQueueWindow", TargetSQW)
end

local TICK_RATES = {
  arm = {
      rate = 0.001,
      description = "Arena mode - lowest tick rate for maximum performance"
  },
  bgm = {
      rate = 0.2,
      description = "Battleground mode - higher tick rate for better FPS"
  },
  bm = {
      rate = 0.1,
      description = "Balanced mode - medium tick rate for balance"
  }
}

-- Get tick rate with fallback to default
local tickRate = TICK_RATES[project.settings.mode] and TICK_RATES[project.settings.mode].rate or 0.01

local SAFE_ZONES = {
  "Stormwind City",
  "Ironforge",
  "Darnassus",
  "Exodar",
  "Shrine of Seven Stars",
  "Stormshield",
  "Dalaran",
  "Boralus",
  "Orgrimmar",
  "Thunder Bluff",
  "Undercity",
  "Silvermoon City",
  "Shrine of Two Moons",
  "Warspear",
  "Valdrakken",
  "Dornogal",
  "Dazar'alor",
}

-- First, create a table that holds all our spell definitions with comments
local deathTableDefinitions = {
  [51514] = true,     -- Hex
  [210873] = true,    -- Hex (Compy)
  [211004] = true,    -- Hex (Spider)
  [211010] = true,    -- Hex (Snake)
  [211015] = true,    -- Hex (Cockroach)
  [269352] = true,    -- Hex (Skeletal Hatchling)
  [277778] = true,    -- Hex (Zandalari Tendonripper)
  [277784] = true,    -- Hex (Wicker Mongrel)
  [309328] = true,    -- Hex (Living Honey)
  [118] = true,       -- Polymorph
  [61780] = true,     -- Polymorph (Turkey)
  [126819] = true,    -- Polymorph (Pig)
  [161353] = true,    -- Polymorph (Bear Cub)
  [161354] = true,    -- Polymorph (Monkey)
  [161355] = true,    -- Polymorph (Penguin)
  [28271] = true,     -- Polymorph (Turtle)
  [28272] = true,     -- Polymorph (Pig)
  [61305] = true,     -- Polymorph (Black Cat)
  [61721] = true,     -- Polymorph (Rabbit)
  [161372] = true,    -- Polymorph (Peacock)
  [277787] = true,    -- Polymorph (Baby Direhorn)
  [277792] = true,    -- Polymorph (Bumblebee)
  [321395] = true,    -- Polymorph (Mawrat)
  [391622] = true,    -- Polymorph (Duck)
  [5782] = true,      -- Fear
  [20066] = true,     -- Repentance
  [360806] = true,    -- Sleep Walk
  [356727] = true     -- Silence Venom
}

-- Create the metatable that will define lookup behavior
local deathTableMeta = {
  __index = function(_, spellID)
      -- If this spell isn't in our definitions, return nil
      if not deathTableDefinitions[spellID] then
          return nil
      end

      -- For Incapacitate DR spells (Polymorph, Hex variants, Repentance)
      if spellID == 118 or        -- Polymorph
         spellID == 61780 or      -- Polymorph (Turkey)
         spellID == 126819 or     -- Polymorph (Pig)
         spellID == 161353 or     -- Polymorph (Bear Cub)
         spellID == 161354 or     -- Polymorph (Monkey)
         spellID == 161355 or     -- Polymorph (Penguin)
         spellID == 28271 or      -- Polymorph (Turtle)
         spellID == 28272 or      -- Polymorph (Pig)
         spellID == 61305 or      -- Polymorph (Black Cat)
         spellID == 61721 or      -- Polymorph (Rabbit)
         spellID == 161372 or     -- Polymorph (Peacock)
         spellID == 277787 or     -- Polymorph (Baby Direhorn)
         spellID == 277792 or     -- Polymorph (Bumblebee)
         spellID == 321395 or     -- Polymorph (Mawrat)
         spellID == 391622 or     -- Polymorph (Duck)
         spellID == 51514 or      -- Hex
         spellID == 210873 or     -- Hex (Compy)
         spellID == 211004 or     -- Hex (Spider)
         spellID == 211010 or     -- Hex (Snake)
         spellID == 211015 or     -- Hex (Cockroach)
         spellID == 269352 or     -- Hex (Skeletal Hatchling)
         spellID == 277778 or     -- Hex (Zandalari Tendonripper)
         spellID == 277784 or     -- Hex (Wicker Mongrel)
         spellID == 309328 or     -- Hex (Living Honey)
         spellID == 20066 then    -- Repentance
          return awful.player.idr >= 0.5
      end

      -- For Disorient DR spells
      if spellID == 5782 or       -- Fear
         spellID == 360806 then   -- Sleep Walk
          return awful.player.ddr >= 0.5
      end

      -- Special case for Silence Venom
      if spellID == 356727 then   -- Silence Venom
          return awful.player.debuff(356727) and awful.player.debuffRemains(356727) <= 0.5
      end
  end
}

-- Create our main table and set its metatable
local deathTable = {}
setmetatable(deathTable, deathTableMeta)

function isPlayerInSafeZone()
  local zoneText = GetZoneText()
  for _, safeZone in ipairs(SAFE_ZONES) do
      if zoneText == safeZone then
          return true
      end
  end
  return false
end


local function combatCheck()
  local inCombat = false
  awful.fgroup.loop(function(friend)
    if friend.combat then
      inCombat = true
      return true
    end
  end)
  return inCombat
end


function project.isInValidInstance()
  local instanceType = select(2, GetInstanceInfo())
  return instanceType == "arena" or instanceType == "pvp"
      or (instanceType == "raid" and combatCheck()) or (instanceType == "scenario" and combatCheck()) or (instanceType == "party" and combatCheck())  or 
      (instanceType == "none" and (combatCheck() and not isPlayerInSafeZone() or target.dummy))
end


awful.onEvent(function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
  instanceType = select(2, GetInstanceInfo())
  end
end)

local function HoldingGCD()
  awful.enemies.within(swd.range).loop(function(enemy)
    if player.channel and player.channelID == ultimateChannel.id then return end
          if enemy and enemy.los and enemy.casting and deathTable[enemy.castID] and enemy.castTarget ~= nil and enemy.castTarget.isUnit(player) and enemy.casttimecomplete >= 0.1 then
          return true
      end
  end)
  return false
end

local function StopCastingLogic()
  if player.channel and player.channelID == ultimateChannel.id then return end
  awful.enemies.within(swd.range).loop(function(enemy)
    if swd.cd > awful.gcd then return end
      if enemy and enemy.los and enemy.casting and deathTable[enemy.castID] and enemy.castTarget ~= nil and enemy.castTarget.isUnit(player) and enemy.casttimecomplete >= 0.1 then
          if (player.casting or player.channel) then
              awful.call("SpellStopCasting")
          end
      end
  end)
end


local CombatFlow = {
  criticalDefense = function()
    swd("lowHP")
    shadowMeld()
    shadowMeld("clone")

    if swd("cc") then return end
    if swd("pets") then return end
    if swd("preSWD") then return end
    if psychicScream("enemyHealer") then return end
    if psychicScream("burst") then return end
    if solace() then return end
    if clairvoyance() then return end
  end,

  raptureRotation = function()
      if not player.buff(rapture.id) then return end
      archAngel("rapture")
      archAngel("noRapture")
      penance()
      PwShield()
      PwLife()
      PwRadiance()
      painSuppression()
      PwBarrier()
      voidShift()
      voidShift("self")
      ultimatePenitence("burst")
      ultimatePenitence("lowHP")
      ultimatePenitence("tyrant")
      ultimatePenitence("lowMana")
      ultimatePenitence("cancel")
      fade()
      fade("melee")
      massDispel()
      leapOfFaith()
      desperatePrayer()
      powerInfusion()
      purify()
      purgeTheWicked()
      mindBlast()
      dispelMagic()
      dispelMagic("lowHP")
  end,

  normalRotation = function()
      -- Critical healing
      rapture()
      rapture("lowHP")
      archAngel("rapture")
      archAngel("noRapture")
      PwBarrier()
      PwLife()
      PwRadiance()
      painSuppression()
      voidShift()
      voidShift("self")

      -- Ultimate Penitence checks
      ultimatePenitence("burst")
      ultimatePenitence("lowHP")
      ultimatePenitence("tyrant")
      ultimatePenitence("lowMana")
      ultimatePenitence("cancel")

      -- Defensive abilities
      fade()
      fade("melee")
      massDispel()
      leapOfFaith()
      desperatePrayer()

      -- Offensive and utility
      project.stompTotems()
      shadowFiend()
      powerInfusion()
      purify()
      dispelMagic()
      dispelMagic("lowHP")

      -- Regular healing rotation
      penance()
      PwShield()
      purgeTheWicked()
      purgeTheWicked("pets")
      purgeTheWicked("catharsis")
      mindBlast()
      renew()
      prayerOfMending()
      flashHeal()
      insight()
      piety()
      smite()
      mindGames()

      -- Utility and healing
      darkArchangel()
      voidTendrils("enemyHealer")
      voidTendrils("enemyBurst")
      voidTendrils("multi")
      voidTendrils("pets")
      psychicScream("pets")
      voidTendrils("melee")
      voidTendrils("los")
      voidTendrils("chain")
      angelicFeather("enemyHealer")
      angelicFeather("enemyBurst")
      angelicFeather("melee")
      innerLight("switch")
      preHot()
  end,

  misc = function()
      project.usehealthStone()
      project.usemedallion()
      project.grabFlag()
      project.autoFocus()
      project.WasCastingCheck()
  end
}

discipline:Init(function()
  project.holdGCD = false
  project.QueueAlertAndAccept()
  if player.mounted then return end

  if awful.prep then
    project.overlappingSpells = {}
    project.overlappingDefensives = {}
      project.combatStarted = false
      project.insightCast = false
      project.pietyCast = false
      project.solaceCast = false
      project.clairvoyanceCast = false
      project.shieldingSequence = false
      project.hasAttemptedCollection = false
      PwFortitude()
      innerLight("mana")
      innerLight("atone")
      return
  end

  if not project.isInValidInstance() then return end
  if player.buff("Refreshment") or player.buff("Food") or player.buff("Drink") then return end
  if (target.dummy) then project.combatStarted = true end
  if player.channel and player.channelID == 605 then return end
  if awful.prep then return end
  project.overlappingSpells = {}
  project.WasCastingCheck()
  project.setCombatStarted()
  CombatFlow.criticalDefense()
  if HoldingGCD() then return end
  StopCastingLogic()
  if project.holdGCD then return end
  if project.shieldingSequence then return end

  if player.buff(insight.id) and player.buffStacks(insight.id) >= 1 and not player.buff(solace.id) then
      if penance.cd < awful.gcd then
          penance()
      end
  end
  CombatFlow.raptureRotation()
  if player.buff(rapture.id) then return end
  CombatFlow.normalRotation()
  CombatFlow.misc()
end, tickRate)


