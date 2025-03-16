local Unlocker, blink, sr = ...
local bin, min, max = blink.bin, min, max
local shaman, ele = sr.shaman, sr.shaman.ele
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

if not shaman.ready then return end

if currentSpec ~= 1 then return end

shaman.print(colors.shaman .. "Elemental Shaman |cFFf7f25cLoaded")
shaman.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
shaman.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--tickrate
local srtickRate = saved.tickrate

--enable on load
C_Timer.After(0.5, function()
  blink.enabled = true
  shaman.print(blink.colors.green .."Enabled")
end)
blink.addEventCallback(function()
  if UnitIsAFK("player") then
    if not blink.enabled then return end
    blink.enabled = false
    shaman.print(blink.colors.red .."Disabled " .. blink.colors.cyan .."[Player is AFK]")
  else
    if blink.enabled then return end
    blink.enabled = true
    shaman.print(blink.colors.green .."Enabled " .. blink.colors.cyan .."[Player no longer AFK]")
  end
end, "PLAYER_FLAGS_CHANGED")

local DontAttackThose = {
  642, --"Divine Shield",
  45438, --"Ice Block",
  186265, --"Aspect of the Turtle",
  362486, --Keeper of the Grove
  408558, --priest phase shift
  212295, --Warlock Netherward
  23920,  --Reflect
  8178, --grounding
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
}

ele:Init(function()
  if saved.rotationMode == "hekiliMode" then 
    sr.HekiliRotation()
  end

  sr.autoFocus()

  --auto targeting 
  sr.autoTarget()

  if blink.arena then   
    if player.buff(77762) 
    and (player.castID == 188196 or player.castID == 210714) then
      blink.call("SpellStopCasting")
    end  
  end

  if player.hp <= saved.emblemtrinket then
    Trinkets.Emblem()
  end
  
  if player.mounted then return end

  -- gatez
  if blink.prep 
  and sr.reactionDelay("healthstones") then

    earthShield("prep")

    shaman.healthstones:grab()

  else

    shaman.healthstones:auto()
  end

  --get grounding or fire elemental
  totemRecall("auto")

  --ground shit optimize it FPS
  if grounding() then return end
  if grounding("trap") then return end
  if grounding("grip") then return end

  --clean poision
  poisionTotem("auto")

  --Fireblood
  racials.IronDwarf()

  --walls
  if burrow("Slider") then return end

  --earth Elemental
  earthElemental("emergency")

  --cleanse
  cleanse()

  --tremor
  if tremor("healer") then return end
  if tremor("friends") then return end
  if tremor("pre") then return end
  
  --eatTraps  
  sr.eatTrap()
  
  sr.FlagPick()

  lasso("command")
  hex("command")

  --knock
  if sr.reactionDelay("thunderstorm") then
    thunderStorm("defensives")
    thunderStorm("stunned")
  end

  bulwarkTotem()

  --wall
  astralShift()
  astralShift("Greedy")

  --shaman.staticFieldTotem()

  --counter it
  counterStrike()

  if ghostWolf("command") then return end

  --burrow  
  if not player.dead 
  and shaman:HoldGCDForBurrow() then
    return alert("Holding GCD To " .. "|cFFf7f25c[Burrow]", burrow.id) 
  end

  --grounds
  if sr.holdGCDForGround() then
    return alert("Holding GCD To " .. "|cFFf7f25c[Ground]", grounding.id) 
  end

  if player.buff(2645) then return end

  --more healing
  ancestralGuidance("emergency")

  healingStream("emergency")

  --petStun
  pulverize("big dam")

  --lasso auto
  lasso("healer")
  lasso("big dam")

  --Auto Hex
  hex("auto")

  --healings
  healingSurge("emergency")
    
  --Purge  
  purge()
  purge("MC")

  --stompa  
  earthShock("stomp")
  lavaBurst("stomp")
  frostShock("stomp")

  if sr.reactionDelay("frostShock") then
    frostShock("reflects")
  end

  --roots
  earthGrab("drinking")
  earthGrab("badpostion")
  capacitor("rooted")
  earthGrab("slowbigdam")
  earthGrab("tunnel")
  earthGrab("stealth")
  earthGrab("restealth") 
  earthGrab("BM Pet")

  if sr.Pause() then return end
  
  --buffup
  flameTongue()
  earthShield()
  lightningShield()
  skyFury("buff")

  --Kicks
  windShear("interrupt")
  windShear("tyrants")
  windShear("seduction")
  
  --Execute
  if saved.rotationMode == "dmgAndUtil" then
    lavaBurst("anyone")
    earthShock("anyone")
  end


  local function rotation()
    
    local ready = saved.rotationMode == "dmgAndUtil" and target.exists and target.enemy 
    and not (target.immuneMagicDamage or target.dead or target.debuffFrom(realBCC) 
    or target.debuff(203337) or target.buffFrom(DontAttackThose) or player.debuff(410201))

    if ready then

      -- if blink.burst 
      -- or (saved.mode == "ON" 
      -- and target.hp < 85)
      -- and not blink.prep then

      --   if blink.burst and player.buff(114050) then
      --     blink.burst = blink.time + 3
      --   end
    
      --   ele.racial()
      --   Trinkets.Badge()
      --   fireElemental("burst")
      --   meteor("burst")
      --   primordialWave("burst")
      --   AS()
      --   ascendance()
      --   bloodlust()
      --   stormKeeper()
      -- end
      -- Determine burst mode
      if (blink.burst or player.buffFrom({204361, 204362})
      or (saved.mode == "ON" 
      and target.hp < 85 
      and target.los 
      and target.dist <= 40)) 
      and not blink.prep then

        if not sr.burstMode then
          --sr.debugPrint("Entering Burst Mode")
        end

        sr.burstMode = true
        
        if blink.burst and player.buff(114050) then
          blink.burst = blink.time + player.buffRemains(114050)
          --sr.debugPrint("Extending burst", blink.burst)
        end

        ele.racial()
        Trinkets.Badge()
        fireElemental("burst")
        meteor("burst")
        if primordialWave("burst") then return end
        AS()
        bloodlust()
        hero()
        if ascendance() then return end
        earthShock("full")
        lavaBurst("proc")
        stormKeeper()
      else
        if sr.burstMode then
          --sr.debugPrint("Exiting Burst Mode")
        end
        sr.burstMode = false
      end


      flameShock("all")
      liquidMagma("all")
      primordialWave()
      primordialWave("burst")
      flameShock("pets")

      earthShock("full")
      lavaBurst("procOthers")
      lavaBurst("proc")
      lightningBolt()
      earthShock()

      --pve 
      lavaBurst("pve")
      lightningBolt("pve")
      --
      --earthShock()
      lavaBurst() 
      frostShock("maintain")

      --low prio
      earthShield("friend")
      purge("lowPrio")
      iceFury()

    end
  end

  rotation()

end, 0.01)