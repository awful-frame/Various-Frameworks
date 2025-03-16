local Unlocker, awful, project = ...
if awful.player.class2 ~= "SHAMAN" then return end
if GetSpecialization() ~= 3 then return end
local restoration = project.shaman.restoration
local settings = project.settings
local player = awful.player
local target = awful.target

project.badge = awful.NewItem(218421)
project.badge2 = awful.NewItem(218713)
project.medallion = awful.NewItem(218424)
project.medallion2 = awful.NewItem(218715)
project.healthStones = awful.NewItem(5512)

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
  "Dazar'alor",
  "Dornogal"

}

function isPlayerInSafeZone()
  local zoneText = GetZoneText()
  for _, safeZone in ipairs(SAFE_ZONES) do
      if zoneText == safeZone then
          return true
      end
  end
  return false
end

function project.combatCheck()
  local inCombat = false
  awful.fgroup.loop(function(unit)
    if unit.combat then
      inCombat = true
      return true
    end
  end)
  return inCombat
end

function project.isInValidInstance()
  local instanceType = select(2, GetInstanceInfo())
  return instanceType == "arena" or instanceType == "pvp"
      or (instanceType == "raid" and project.combatCheck()) or (instanceType == "scenario" and project.combatCheck()) or (instanceType == "party" and project.combatCheck())  or 
      (instanceType == "none" and (project.combatCheck() and not isPlayerInSafeZone() or target.dummy))
end

awful.onEvent(function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    instanceType = select(2, GetInstanceInfo())
  end
end)


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

restoration:Init(function()
  if player.mounted then return end
    if awful.prep then
    project.resetFlags()
    preHot()
    skyFury()
    earthLiving()
    tideCallersGuard()
    end
    if awful.prep then return end
    if player.buff ("Refreshment") or player.buff ("Food") then return end
    if player.buff("Drink") then return end
    if project.isInValidInstance() then
      project.hexCancel()
      spiritWalkersGrace()
      astralShift()
      windShear("CC")
      windShear("Heal")
      windShear("Dam")
      windShear("pets")
      bloodLust()
      if groundingTotem("preHoj") then return end
      if tremorTotem("preTremor") then return end
      if primordialWave() then return end
      if unleashLife("ns") then return end
      if healingWaveNS("ns") then return end
      if healingTide("burst") then return end
      if healingTide() then return end
      if earthWall("burst") then return end
      earthWall("lowHP")
      if totemicRecall() then return end
      if stoneSkin() then return end
      if counterStrikeTotem() then return end
      ascendance()
      if spiritLink() then return end
      if hex("chainHealer") then return end
      totemicProjectionSL("spiritLink")
      totemicProjectionEW("earthen")
      totemicProjectionHT("tide")
      ancestralGuidance("multi")
      staticFieldTotem("peel")
      --staticFieldTotem("enemyHealer")
      staticFieldTotem("interrupt")
      totemicProjectionSFT("peel")
      totemicProjectionSFT("interrupt")
      --totemicProjectionSFT("enemyHealer")
      if groundingTotem("CC") then return end
      if groundingTotem("Dam") then return end
      if tremorTotem("casts") then return end
      if tremorTotem("pets") then return end
      tremorTotem("friends")
      purifySpirit()
      if greaterPurge() then return end
      purge()
      surgingTotem()
      healingStream()
      earthShield()
      ripTide()
      unleashLife()
      unleashLife("cast")
      ripTide("unleash")
      earthWall("totemic")
      healingRain()
      groundingTotem("interrupt")
      healingSurge("ground")
      healingSurge()
      hex("enemyHealer")
      hex("tyrant")
      hex("dps")
      purge("lowHP")
      greaterPurge("lowHP")
      burrow()
      if unleashShield() then return end
      ghostWolf("rep")
      ghostWolf("move")
      ghostWolf("cancel")
      spiritWalk()
      earthElemental()
      if thunderStorm("CC") then return end
      if thunderStorm() then return end
      earthGrab("losManagement")
      earthGrab("burstMelee")
      earthGrab("enemyHealer")
      earthGrab("leaps")
      earthGrab("peel")
      if earthGrab("pets") then return end
      if poisonTotem() then return end
      if capacitorTotem() then return end
      lightningLasso("healer")
      lightningLasso("dps")
      flameShock()
      frostShock("melee")
      frostShock("root")
      frostShock("lowHP")
      lavaBurst()
      manaTide()
      preHot2()
      waterShield()
      project.useMedallion()
      project.stompTotems()
      project.frostStomp()
      project.WasCastingCheck()
      end
  end, tickRate)

