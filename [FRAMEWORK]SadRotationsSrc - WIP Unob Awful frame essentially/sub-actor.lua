local Unlocker, blink, sr = ...
local bin, min, max = blink.bin, min, max
local rogue, sub = sr.rogue, sr.rogue.sub
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local NS = blink.Spell
local alert = blink.alert 
local shortalert = function(msg, txid)
  return alert({message = msg, texture = txid, duration = 0.035, fadeOut = 0.1, fadeIn = 0.1 })
end 
local colors = blink.colors
local saved, cmd = sr.saved, sr.cmd
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer

local currentSpec = GetSpecialization()
if not sub.ready then return end
if currentSpec ~= 3 then return end

rogue.print(colors.rogue .. "Subtlety Rogue |cFFf7f25cLoaded!")
rogue.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
rogue.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--tickrate
local srtickRate = saved.tickrate

C_Timer.After(0.5, function()
  blink.enabled = true
  blink.print("|cFFf7f25c[SadRotations]: |cFF22f248Enabled")
end)

local DontAttackThose = {
  642, --"Divine Shield",
  45438, --"Ice Block",
  186265, --"Aspect of the Turtle",
  362486, --Keeper of the Grove
  408558, --priest phase shift
  212295, --Warlock Netherward
  23920,  --Reflect
  8178, --grounding
}

local realBCC = {

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

  2094, --blind
  105421, --blinding light
  3355, --freezing trap
  2637, --Hibernate
  82691, --ring
  20066, --repentance
  6770, --Sap
  213691, --scatter
  6358, --seduction
  198909, --song of chi
}

sub:Init(function()
  local validTarget = target.exists and target.enemy and not target.dead
  local validPhysical = validTarget and not target.bcc and not target.immunePhysicalDamage and not target.immunePhysicalEffects
  local validPhysicalInRange = validPhysical and target.meleeRange and player.isFacing(target)

  local ready = target.exists 
  and target.enemy 
  and not (target.immunePhysicalDamage 
  or target.dead or target.debuffFrom(realBCC) 
  or target.debuff(203337) 
  or target.buffFrom(DontAttackThose) 
  or player.debuff(410201))

  if player.hp <= saved.emblemtrinket then
    Trinkets.Emblem()
  end
  
  --Auto Focus 
  sr.autoFocus()

  --auto targeting 
  sr.autoTarget()

  if player.mounted then return end

  bomb("auto")

  --eatTraps  
  sr.eatTrap()

  sr.FlagPick()

  -- gatez
  if blink.prep then
    rogue.healthstones:grab()
  else
    rogue.healthstones:auto()
  end

  blind("command")
  kidney("command")
  
  rogue.Poisions()

  sap("stealth")
  sap("focus")

  kick("interrupt")

  --if rogue.DanceGo(target) then return end

  rogue.DanceGo(target)

  dismantle("CDs")

  crimsonVial("heal")

  fient("emergency")

  stealth()

  -- ready to open
  local readyToOpen
  if validPhysicalInRange and player.stealth then
    readyToOpen = true
  end

  -- opener stuff
  if readyToOpen then
    if cheapShot("opener") then return end
  end

  cheapShot("others")

  local function rotation()

    --Auto attack
    rogue:Attack()

    if ready then

      --burst
      if blink.burst 
      or (saved.mode == "ON" 
      and target.meleeRange
      and target.debuffFrom({408, 1833})
      and target.stunRemains > 1.5) then
        sub.racial()
        Trinkets.Badge()
        tea("burst")
        symbols()
        shadowDance("burst")
        shadowBlades("burst")
        if sepsis("burst") then return end
        if secret("burst") then return end
      end

      tea()
      rupture("maintain")
      evis("finisher")
      shadowStrike()
      backStab()

    end
      
  end

  rotation()

end, 0.01)