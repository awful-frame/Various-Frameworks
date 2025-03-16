local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local buffer, latency, gcd = blink.buffer, blink.latency, blink.gcd
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local paladin, ret = sr.paladin, sr.paladin.ret
local alert = blink.alert
local colors = blink.colors
local target = blink.target
local enemy = blink.enemy
local player = blink.player
local fhealer = blink.healer
local enemyHealer = blink.enemyHealer
local bin = blink.bin
local enemyPets = blink.enemyPets
local NewItem = blink.Item
local saved = sr.saved

local currentSpec = GetSpecialization()

if not paladin.ready then return end

if currentSpec ~= 3 then return end

paladin.print(colors.paladin .. "Retribution Paladin |cFFf7f25cLoaded!")
paladin.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
paladin.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--tickrate
local srtickRate = saved.tickrate

--enable on load
C_Timer.After(0.5, function()
  blink.enabled = true
  print("|cFFf7f25c[SadRotations]: |cFF22f248Enabled")
end)
blink.addEventCallback(function()
  if UnitIsAFK("player") then
    if not blink.enabled then return end
    blink.enabled = false
    print("|cFFf7f25c[SadRotations]: |cFFf74a4aDisabled " .. blink.colors.cyan .."[Player is AFK]")
  else
    if blink.enabled then return end
    blink.enabled = true
    print("|cFFf7f25c[SadRotations]: |cFF22f248Enabled " .. blink.colors.cyan .."[Player no longer AFK]")
  end
end, "PLAYER_FLAGS_CHANGED")

sancMePls = {
  --Howl
  [5484] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  --warr fear
  [5246] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  --scream
  [8122] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  --Fear
  [5782] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  --Fear2
  [118699] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  -- priest sc
  [15487] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  --dh sigil fear
  [207684] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  --dh sigil fear2
  [207685] = function(obj)
    return obj.ccRemains >= 2.9
  end,

  --HOJ
  [853] = function(obj)
    return obj.stunRemains >= 2.9
  end,
}


--Immune To Paldin CC Stuff Table
local ImmuneToPaldinCC = {

	213610, --Holy Ward
	236321, --War Banner
	23920, -- reflect
  8178, --grounding
	353319, --restoral
	362486, --Keeper of the Grove
  228050, --Forgotten Queen
  204018, --Spell Warding
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  377362, --Precognition
  377360, --Precognition
  203337, --Daimond ice
  212295, --netherward
  408558, --priest phase shift
  421453, --Ultimate Penitence
  354610, --dh Glimpse

}

ret:Init(function()
  --Auto Focus 
  sr.autoFocus()

  if player.mounted then return end

  --auto targeting 
  sr.autoTarget()
  --eatTraps  
  sr.eatTrap()
  --flags
  sr.FlagPick()

  -- gate
  if blink.prep then
    paladin.healthstones:grab()
  else
    paladin.healthstones:auto()
  end

  --Sacrifice
  BOS()
  BOS("cc")

  SOV("emergency")
  divineprotection("emergency")

  --trinkets    
  if player.hp <= saved.emblemtrinket then
    Trinkets.Emblem()
  end
  
  layonhand("percent")
  warding("percent")

  divinesteed("command")
  HOJ("command")
  blind("command")

  BOP("command")
  BOP("karma")
  BOP("blind")
  BOP("percent")
  --BOP("player")

  --bubble
  if player.hp <= saved.BubbleSensitivity then 
    if bubble("emergency") then return end
  end

  --bubble  
  if blink.time - paladin.timeHoldingGCDStart > 14 then
    paladin.timeHoldingGCD = 0
  end

  if paladin:HoldGCDForBubble() then
    paladin.timeHoldingGCDStart = blink.time
    paladin.timeHoldingGCD = paladin.timeHoldingGCD + blink.tickRate
    return alert("Holding GCD To " .. "|cFFf7f25c[Divine Shield]", bubble.id) 
  end

  --sancs
  if sanc("healer") then return end
  if sanc("friends") then return end

  --kick
  rebuke("interrupt")
  rebuke("seduction")
  rebuke("tyrants")
  
  --Pause
  if sr.Pause() then return end

  --stomping
  if saved.autoStomp then 
    judge("stomp")
    BOJ("stomp")
    crusader("stomp")
  end
  
  HOH("slow target")

  --HOJ check faster pls
  if enemyHealer.exists and enemyHealer.sdr == 1 
  and not enemyHealer.stunned
  and not enemyHealer.immuneMagicEffects
  and not enemyHealer.immuneStuns
  and not enemyHealer.buffFrom(ImmuneToPaldinCC) then     
    HOJ("cc healer")
  end

  --target stun
  if target.exists
  and target.sdr == 1 
  and not target.stunned
  and not target.immuneMagicEffects
  and not target.immuneStuns
  and not target.buffFrom(ImmuneToPaldinCC) then     
    HOJ("target")
  end

  --freedom
  freedom("command")
  freedom("prio")
  divinesteed("gapclose")

  --Aura    
  DevoAura()

  --auto
  paladin:Attack()

  local function rotation()

    --burst
    if saved.rotationMode == "dmgAndUtil" 
    and blink.burst 
    or player.buffFrom({31884, 231895})
    or saved.mode == "ON" 
    and (target.exists 
    and target.stunned 
    or enemyHealer.exists and enemyHealer.ccRemains > 3
    or not enemyHealer.exists and target.hp < 85) 
    and target.dist < 30 
    and not blink.prep then
        
      --Trap/Daimond ice
      if target.debuff(203337) or target.debuff(3355) or player.debuff(410201) then return end

      freedom("prio")
      divinesteed("gapclose")

      -- racials
      Trinkets.Badge()
      wakeofashes("burst")
      if paladin.HOL() then return end
      judge("maintain")
      FV()
      excutesent()
      wings("burst")
      finalreck("burst")
      divintoll("burst")
      justicar()
      radiantdecree("burst")

      --FV
      if FV.cd - blink.gcdRemains == 0 
      and blink.enemies.around(player, 10, function(o) return o.bcc and o.isPlayer end) == 0 then
        FV()
      elseif player.buff(387178) and blink.enemies.around(player, 10, function(o) return o.bcc and o.isPlayer end) > 0 then
        --cancel 
        sr.cancelSpellByName(387178)
        blink.alert("|cFFfa8ea8Cancel Empyrean Legacy |r(CC Around)", FV.id)
      end

      hammerofwrath()
      judge()
      BOJ()

      --normal
      wakeofashes()
      if paladin.HOL() then return end
      FV()
      justicar() 
      excutesent()
      hammerofwrath()
      judge()
      BOJ()
      storm()
      exo()

    end

      --high prio
      flashheal("emergency") 
      WOG("emergency")

      local ready = saved.rotationMode == "dmgAndUtil" and target.exists and target.enemy and not (target.bcc or target.dead or target.debuff(203337) or player.debuff(410201))

      if ready then

        -- racials
        Trinkets.Badge()
        wakeofashes()
        if paladin.HOL() then return end
        judge("maintain")
        FV()
        justicar() 
        excutesent()
        hammerofwrath()
        judge()
        BOJ()
        hammerofwrath()
        storm()
        exo()

      end
  end

  rotation()
 
end, 0.02)