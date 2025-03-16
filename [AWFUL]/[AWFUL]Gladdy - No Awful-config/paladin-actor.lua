local Unlocker, awful, project = ...

if awful.player.class2 ~= "PALADIN" then return end
if awful.player.spec ~= "Holy" then return end
local holy = project.paladin.holy
local settings = project.settings
local player = awful.player
local target = awful.target

project.greenTrinket = awful.NewItem(218422)
project.epicTrinket = awful.NewItem(218716)
project.medallion = awful.NewItem(218424)
project.medallion2 = awful.NewItem(218715)
project.healthStone = awful.NewItem(5512)

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

local function isPlayerInSafeZone()
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

holy:Init(function()
if player.mounted then return end
  if awful.prep then
  beaconOfLight()
  beaconOfFaith()
  devotionAura()
  concentrationAura()
  blessingOfWinter()
  riteOfAdjuration()
  riteOfSanctification()
  end
  if player.buff ("Drink") then return end
  if player.buff ("Food") then return end
  if awful.prep then return end
  if project.isInValidInstance() and not awful.prep then
  local holdGCD = flashOfLight("infusion")
  local holdGCD2 = hammerOfJustice("healer")
  local holdGCD3 = blindingLight()
  project.stompTotems()
  project.beacon()
  handOfReckoning()
  layOnHands()
  divineShield()
  divineShield("noTrinket")
  hammerOfJustice("healer")
  if holdGCD2 then return end
  blindingLight()
  if holdGCD3 then return end
  divineProtection()
  blessingOfSummer()
  blessingOfAutumn()
  blessingOfSpring()
  blessingOfWinter()
  rebuke("CC")
  rebuke("Dam")
  rebuke("Heal")
  blessingOfFreedom()
  blessingOfSacrifice("cc")
  blessingOfSacrifice("lowHP")
  blessingOfSacrifice("burst")
  avengingWrath("burst")
  divineToll()
  hammerOfJustice("dps")
  repentance()
  blindingLight("rogues")
  blessingOfProtection("dangerous")
  blessingOfProtection("low")
  tyrsDeliverance()
  handOfDivinity()
  holyLight("divinity")
  sacredWeapon()
  auraMastery("burst")
  auraMastery("cc")
  auraMastery("tyrs")
  auraMastery("fburst")
  auraMastery("self")
  auraMastery("lowHP")
  repentance("auraMastery")
  tyrsDeliverance("auraMastery")
  cleanse()
  cleanse("improved")
  crusaderStrike()
  judgement("infusion")
  barrierOfFaith()
  holyShock()
  wordOfGlory()
  judgement()
  divineFavor()
  flashOfLight("infusion")
  if holdGCD then return end
  flashOfLight()
  denounce()
  searingGlare()
  hammerOfWrath()
   project.usehealthStone()
   project.usemedallion()
   project.WasCastingCheck()
  end
end, tickRate)
