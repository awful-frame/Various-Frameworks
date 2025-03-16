local Unlocker, blink, sr = ...
local bin, min, max = blink.bin, min, max
local rogue, assa = sr.rogue, sr.rogue.assa
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local NS = blink.Spell
local alert = blink.alert 
local shortalert = function(msg, txid)
  return alert({message = msg, texture = txid, duration = 0.035, fadeOut = 0.1, fadeIn = 0.1 })
end 
local colors = blink.colors
local saved = sr.saved
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local gcd, gcdRemains = blink.gcd, blink.gcdRemains
local time = blink.time

local currentSpec = GetSpecialization()
if not assa.ready then return end
if currentSpec ~= 1 then return end

rogue.print(colors.rogue .. "Assa Rogue |cFFf7f25cLoaded!")
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

assa:Init(function()

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

  -- ready to open
  local readyToOpen
  if validPhysicalInRange and player.stealth then
    readyToOpen = true
  end


  if player.hp <= saved.emblemtrinket then
    Trinkets.Emblem()
  end
  
  --Auto Focus 
  sr.autoFocus()

  --auto targeting 
  sr.autoTarget()

  stealth()

  rogue.Poisions()

  -- opener stuff
  if readyToOpen then
    garrote("opener")
  end
  
  if player.mounted or player.buff(1784) then return end

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
  
  sap("stealth")
  sap("focus")

  kick("interrupt")

  stealth()

  kidney("healer")
  cheapShot("cc healer")

  rogue.DanceGo(target)
  --assa.Opener(target)

  dismantle("CDs")

  crimsonVial("heal")

  fient("emergency")


  --stompin
  bonespike("stomp")
  mutilate("stomp")

  --Auto attack
  rogue:Attack()

  local function rotation()

    if ready then

      --burst
      if blink.burst 
      or (saved.mode == "ON" 
      and target.dist <= 9
      and target.debuffFrom({408, 1833})
      and target.stunRemains > 1.5) then
        assa.racial()
        Trinkets.Badge()
        tea("burst")
        shadowDance("burst")
        bane("burst")
      end
  
    end

    --build CP to kidney
    if (blink.MacrosQueued["kidney target"]
    or blink.MacrosQueued["kidney focus"]
    or blink.MacrosQueued["kidney arena1"]
    or blink.MacrosQueued["kidney arena2"]
    or blink.MacrosQueued["kidney arena3"]
    or blink.MacrosQueued["kidney enemyhealer"]) then

      --MFD
      -- if player.cp < 3 
      -- and target.enemy
      -- and target.sdr >= 1 
      -- and target.meleeRange
      -- and mfd:Castable() then
      --     if mfd:CastAlert() then
      --         kidney:CastAlert(target, { face = true })
      --     end
      -- end

      --Build then
      if player.cp < 5
      and kidney.cd < 3 then 

        blink.alert(colors.yellow .. "Building CP", kidney.id)

        --frenzy()
        assa.racial()
        Trinkets.Badge()
        tea()
        envenom("finisher")
        garrote("maintain")
        bonespike("maintain")
        mutilate("getcp")
        rupture("maintain")

      elseif player.cp == 5 and assa.kidney.cd < 0.5 then
        kidney()
      elseif assa.kidney.cd > 3 
        or target.debuff(203123, "player")
        or focus.debuff(203123, "player")
        or arena1.debuff(203123, "player")
        or arena2.debuff(203123, "player")
        or arena3.debuff(203123, "player") then
        blink.MacrosQueued["kidney target"] = nil 
        blink.MacrosQueued["kidney focus"] = nil 
        blink.MacrosQueued["kidney arena1"] = nil 
        blink.MacrosQueued["kidney arena2"] = nil 
        blink.MacrosQueued["kidney arena3"] = nil 
        blink.MacrosQueued["kidney enemyhealer"] = nil
      end
    end

    kidney("auto kidney")
    shiv()
    slice("maintain")

    if sr.Pause() then return end

    if ready then   
      tea() 
      echoing()
      deathmark()
      envenom("finisher")
      garrote("maintain")
      bonespike("maintain")
      mutilate("getcp")
      rupture("maintain")
    end

  end

  rotation()

end, 0.01)