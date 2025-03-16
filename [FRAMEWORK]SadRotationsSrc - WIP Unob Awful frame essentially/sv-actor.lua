local Unlocker, blink, sr = ...
local bin, min, max = blink.bin, min, max
local hunter, sv = sr.hunter, sr.hunter.sv
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local alert = blink.alert
local player = blink.player
local shortalert = function(msg, txid)
  return alert({message = msg, texture = txid, duration = 0.035, fadeOut = 0.1, fadeIn = 0.1 })
end 
local saved = sr.saved
local NS = blink.Spell
local colors = blink.colors

local currentSpec = GetSpecialization()

if not hunter.ready then return end

if currentSpec ~= 3 then return end

hunter.print(colors.hunter .. "Survival Hunter |cFFf7f25cLoaded")
hunter.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
hunter.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--tickrate
local srtickRate = saved.tickrate

--enable on load
C_Timer.After(0.5, function()
  blink.enabled = true
  hunter.print(blink.colors.green .."Enabled")
end)
blink.addEventCallback(function()
  if UnitIsAFK("player") then
    if not blink.enabled then return end
    blink.enabled = false
    hunter.print(blink.colors.red .."Disabled " .. blink.colors.cyan .."[Player is AFK]")
  else
    if blink.enabled then return end
    blink.enabled = true
    hunter.print(blink.colors.green .."Enabled " .. blink.colors.cyan .."[Player no longer AFK]")
  end
end, "PLAYER_FLAGS_CHANGED")

sv:Init(function()

  if player.mounted then return end
  
  --eatTraps  
  sr.eatTrap()
  
  sr.FlagPick()

  hunter:AntiPetTaunt()
  dash("rooted")

  local turtled = player.buff(186265)
  local inCamo = player.buff(199483)
  hunter.criticalPause = false
  hunter.temporaryAlert = false
  hunter.importantPause = false
  hunter.unimportantPause = false
  hunter.userPause = false
  hunter.drawFollowupTrap = false

  if blink.MacrosQueued['reset'] then  
    blink.call("SpellCancelQueuedSpell")
    if pet.exists then
      hunter:PetFollow()
    end
   if hunter.reset() then return end
   if inCamo then return end
  end

  -- desp times, desp measures
  disengage:handler()
  hunter.fixKillCommandBug()
  --sr.autoTargetSeed()

  --Auto Focus 
  sr.autoFocus()

  --auto targeting 
  sr.autoTarget()  

  -- interrupts
  if saved.smartkick 
  and not inCamo then
    if not turtled then
      cs("interrupt")
      cs("seduction")
      cs("tyrants")
    end
  end 
  
  if saved.autoros then
    ros()
  end

  if saved.AutoSOTF then
    SOTF()
  end

  if saved.AutoFortitude then
    fortitude()
  end
  
  if saved.freedomUnit ~= "none" then
    --freedom("helpfear")
    freedom()
  end

  --command Stuff
  sr.trapCommand()
  intimidation("command")
  freedom("command")
  ros("command")

  if player.mounted then return end
  
  --Heal Player
  if player.hp <= saved.exhilaration then
    if exhilaration("Healplayer") then return end
  end 
  
  --Heal Pet
  if exhilaration("Healpet") then return end
  
  -- gatez
  if blink.prep 
  and sr.reactionDelay("healthstones") then
    hunter.healthstones:grab()
  else
    hunter.healthstones:auto()
  end

  --will check for ultimate sac or Guardian
  if turtle() 
  or turtle("Greedy") then
    return 
  end
  
  if player.hp <= saved.emblemtrinket then
    Trinkets.Emblem()
  end

  if saved.automending then
    if MendingBandage() then return end
  end  

  
  -- pursue trapz
  if saved.autotrap then 
    local status = trap:pursue(trapTarget)
    if status and trap.cd < 4 and type(status) == "string" then
      shortalert(status, trap.id)
    end
  end  

  intimidation("auto")
  
  --disarm
  tarbomb("CDs")

  -- porge
  tranq() 
  tranq("MC")

  --Cover Trap from DH 
  if bindingshot("command")
  or bindingshot("cover stuff") then 
    return 
  end

  --scatter command
  if Scatter("command") then return end 

  --Scatter stuff 
  if sr.delay(0.3, 0.5) then
   Scatter("big dam")
   Scatter("seduction")
   Scatter("tyrants")
  end
  
  --root bad postions
  tartrap("badpostion")
  steeltrap("badpostion")

  --Slow bigdam FIXME: optimize it more
  concu("tunnel")
  if saved.slowbigdam then
    concu("slowbigdam") 
    --steeltrap("tyrant")
    tartrap("BM Pet")
    tartrap()
    --tartrap("tyrant")
    steeltrap()
  end  

  -- if saved.autosteeltrap then
  --   steeltrap()
  -- end   

  --pet eat trap
  if blink.arena 
  and saved.peteattrap 
  and healer.stunned then
    hunter:PetEatTrap()
  end 

  -- flares above pauses only during camo
  hunter.mark("enemy detection")
  
  if inCamo then
    flare("restealth")
    flare("stealth")
  end

  if inCamo 
  or player.mounted 
  or player.buff(feign.id) then return end

  
  if target.dead then return end
  
  -- auto attack (all logic is handled by shared hunter module)
  hunter:Attack()

  -- pet control (handled by shared hunter module)
  hunter:PetControl()


  -- feigns
  if saved.autofeign then
    --feign("spear")
    feign("the hunt")
    --feign("debuffs")
    feign("cc")
    feign("damage")
    feign("CDs")
  end  

  if sr.Pause() then return end

  if hunter.criticalPause then 
    return shortalert(hunter.criticalPause.msg, hunter.criticalPause.texture)
  end

  --Chimaeral Sting
  ChimaeralSting()
  ChimaeralSting("lockout")
  ChimaeralSting("badpostion")
  
  if sr.reactionDelay("flare") then
    if flare("restealth")
    -- flare visible stealth units
    or flare("stealth")
    -- flarefriendly healer
    or flare("friendly") then 
      return
    end
  end

  -- stompa
  if saved.autoStomp 
  and not turtled then
    killCommand("stomp") 
    mongoose("stomp")
    serpent("stomp")
  end

  local function rotation()
    
    local ready = saved.rotationMode == "dmgAndUtil" and target.exists and target.enemy and not (target.bcc or target.dead or target.debuff(203337) or player.debuff(410201))

    if turtled then return end

    if hunter.importantPause then 
      return shortalert(hunter.importantPause.msg, hunter.importantPause.texture) 
    end

    if ready 
    and not blink.prep then
      -- racials
      sv.racial()
      Trinkets.Badge()

      if kill("execute")
      or kill("anyone")
      or kill("sv-proc") then
        return
      end
    end

    -- conc trap target when moving towards them
    if saved.autoslow then
      conc("trap target")
    end   
    
    if ready then

      if blink.burst then
        CoordinatedAssault("burst")
        crows("burst")
      end

      if saved.mode == "ON" then
        CoordinatedAssault("proc")
        crows("proc")
      end   

      --cds
      spearhead()

      --dmg
      killCommand("tip")
      explosiveshot() 
      kill("sv-proc")
      bomb()
      butchery()
      mongoose()
      flanking()

      -- kill("sv-proc")
      -- spearhead()
      -- flanking()
      -- bomb()

      if blink.burst 
      or saved.mode == "ON" 
      and (target.hp < 80 
      or enemyHealer.exists and enemyHealer.ccRemains > 3.5 
      or not enemyHealer.exists and target.hp < 80) then 

        CoordinatedAssault("proc")
        crows("proc")
        
      end

      -- pause unimportant
      if hunter.unimportantPause then return end
        
      -- concu("slow target")
      -- serpent()
      -- killCommand("gapclose")
      hunter.mark("stealth units")
      -- serpent("spread")

      if saved.autoEagle then
        Eagle()
      end
      
    end
  end

  rotation()


  if hunter.temporaryAlert then
    shortalert(hunter.temporaryAlert.msg, hunter.temporaryAlert.texture)
  end

end, 0.02)