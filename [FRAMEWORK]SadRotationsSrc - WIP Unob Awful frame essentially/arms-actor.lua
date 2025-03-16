local unlocker, blink, sr = ...
local warrior, arms = sr.warrior, sr.warrior.arms
local shortalert = function(msg, txid)
  return alert({message = msg, texture = txid, duration = 0.035, fadeOut = 0.1, fadeIn = 0.1 })
end 
local colors = blink.colors
local saved = sr.saved
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer

local currentSpec = GetSpecialization()

if not warrior.ready then return end

if currentSpec ~= 1 then return end

warrior.print(colors.warrior .. "Arms Warrior |cFFf7f25cLoaded!")
warrior.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
warrior.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--enable on load
C_Timer.After(0.5, function()
  blink.enabled = true
  blink.print("|cFFf7f25c[SadRotations]: |cFF22f248Enabled")
end)
blink.addEventCallback(function()
  if UnitIsAFK("player") then
    if not blink.enabled then return end
    blink.enabled = false
    blink.print("|cFFf7f25c[SadRotations]: |cFFf74a4aDisabled " .. blink.colors.cyan .."[Player is AFK]")
  else
    if blink.enabled then return end
    blink.enabled = true
    blink.print("|cFFf7f25c[SadRotations]: |cFF22f248Enabled " .. blink.colors.cyan .."[Player no longer AFK]")
  end
end, "PLAYER_FLAGS_CHANGED")

local DontAttackThose = {
  642, --"Divine Shield",
  45438, --"Ice Block",
  186265, --"Aspect of the Turtle",
  362486, --Keeper of the Grove
  196555, --netherwalk
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
  5246, --intim fear
  203337, --undispelableTrap
}


arms:Init(function()
  
  if saved.rotationMode == "hekiliMode" then 
    sr.HekiliRotation()
  end

  --Auto Focus 
  sr.autoFocus()

  --auto targeting 
  sr.autoTarget()  

  if player.mounted then return end

  --eatTraps  
  sr.eatTrap()
  
  sr.FlagPick()


  if player.castID == 64382 then
    if saved.moveLockForShatter then
      blink.controlMovement(0.1)
      alert({msg="Locking Movement | "..colors.cyan.."Shatter", texture=shatter.id, duration=0.3})
      if player.castRemains < blink.buffer then
        blink.releaseMovement()
      end
    end
    local ct = player.castTarget
    if ct.face then
      if player.castRemains <= blink.buffer + blink.latency and not player.facing(ct, 120) then
        ct.face()
      end
    end
  end

  if blink.prep 
  and sr.reactionDelay("healthstones") then
    warrior.healthstones:grab()
  else
    warrior.healthstones:auto()
  end

  warrior:StanceManagment()
  DBTS("emergency")

  reflect()
  warBanner("cc")
  stormBolt("command")

  if saved.rotationMode == "dmgAndUtil" then
    shockWave()
    stormBolt()
  end

  pummel("interrupt")
  pummel("tyrants")
  pummel("seduction")
  disarm()
  phial()
  zerk()
  rally()
  bitter("emergency")
  intervene("emergency")
  intervene()

  ignorePain("emergency")

  intim("command")

  if sr.Pause() then return end

  if saved.rotationMode == "dmgAndUtil" then
    intim("cc healer")
    --intim("fear bomb")
    intim("fear tyrant")
  end

  --stomping
  if saved.autoStomp then 
    --arms:Stomp()
    heroicThrow("stomp")
    overpower("stomp")
  end
  
  local enrage = player.buffRemains(184362)

  if target.enemy and not target.dead then
    warrior:Attack()
  end

  -- if blink.time - warrior.timeHoldingGCDStart > 14 then
  --   warrior.timeHoldingGCD = 0
  -- end

  -- if warrior:HoldGCDForBladestorm() then
  --   warrior.timeHoldingGCDStart = blink.time
  --   warrior.timeHoldingGCD = warrior.timeHoldingGCD + blink.tickRate
  --   return alert("Holding GCD " .. "|cFFf7f25cTo [Pre-Bladestorm]", bladestorm.id) 
  -- end
  escapeArt("gnome")

  shatter()
  charge("interrupts")
  leap("interrupts")

  local ready = saved.rotationMode == "dmgAndUtil" 
  and target.exists 
  and target.enemy 
  and not (target.immunePhysicalDamage
  or target.dead or target.debuffFrom(realBCC) 
  or target.debuff(203337) 
  or player.debuff(410201))

  if ready then

    impendingVictory()
    
    if GetTime() < arms.spearTime then
      spear(nil, true)
    end

    --cancel Bladestorm stop
    if player.buff(227847) 
    and blink.enemies.around(player, 7, function(o) return o.bcc and not o.isPet end) > 0 then
      --cancel 
      sr.cancelSpellByName(227847)
      blink.alert(colors.red .. "Cancel Bladestorm - [Breakable CC]", bladestorm.id)
    
    end

    if player.buff(227847) 
    and execute.cd - blink.gcdRemains == 0 
    and target.meleeRange
    and execute.damage > target.health + target.absorbs
    and target.hp <= 20 then
      --cancel 
      C_Timer.After(1, function()
        sr.cancelSpellByName(227847)
        blink.alert(colors.yellow .. "Cancel Bladestorm - [Execute]", bladestorm.id)
      end)
    
    end 

    execute("finish")
    execute("anyone")
    execute("proc")

    bladestorm("pve")
    bladestorm("roots")

    if player.buff(107574)
    or player.used(376079, 1.5) then
      badge()
    end

    -- extend burst after storm
    if blink.burst and player.buff(227847) then
      blink.burst = blink.time + 3
    end

    --burst
    if blink.burst 
    or saved.mode == "ON" 
    and (target.stunned 
    or enemyHealer.exists and enemyHealer.ccRemains > 2.5 
    or not enemyHealer.exists and target.hp <= 80) 
    and target.meleeRange
    and not target.immunePhysicalDamage then
      
      bloodFury:CastAlert()
      roar()
      avatar()
      spear()
      smash()
      warbreaker()
      overpower() 
      mortal("prio")
      rend("skull")
      mortal("skull")
      skull()
      --or sharpen()
      wreckingthrow() 
      bladestorm("sharpen")
      victoryRush()
      mortal()
      execute()
      rend()
      
    end

    --MiniGO
    if target.enemy 
    and target.hp < 69
    and target.meleeRange
    and saved.mode == "ON" 
    and not target.immunePhysicalDamage then
      smash()
      warbreaker()
      rend("skull")
      rend()
      overpower() 
      mortal("skull")
      skull()
      mortal("prio")
      --or sharpen()
      wreckingthrow() 
      bladestorm("sharpen")

      victoryRush()
      mortal()
      execute()
    end

    --sweeping
    if sweeping.cd - blink.gcdRemains == 0 
    and blink.enemies.around(player, 9, function(o) return o.bcc and not o.isPet end) == 0
    and blink.enemies.around(player, 9) > 1 or blink.enemyPets.around(player, 9) > 1 then
      sweeping()
    elseif player.buff(260708) and blink.enemies.around(player, 9, function(o) return o.bcc and not o.isPet end) > 0 then
      --cancel 
      sr.cancelSpellByName(260708)
      blink.alert("|cFFfa8ea8Cancel Sweeping Strikes", sweeping.id)
    end

    charge("gapclose")
    leap("gapclose")

    piercing("slow target")
    hamstring("slow target")
    
    victoryRush()
    sharpen("heal")
    rend()
    overpower() 
    mortal("prio")
    mortal()
    execute()

  end

  battleShout()

end, 0.01)