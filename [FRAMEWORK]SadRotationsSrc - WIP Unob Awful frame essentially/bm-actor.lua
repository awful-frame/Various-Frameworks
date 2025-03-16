local Unlocker, blink, sr = ...
local bin, min, max = blink.bin, min, max
local hunter, bm = sr.hunter, sr.hunter.bm
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local NS = blink.Spell
local alert = blink.alert 
local shortalert = function(msg, txid)
  return alert({message = msg, texture = txid, duration = 0.035, fadeOut = 0.1, fadeIn = 0.1 })
end 
local colors = blink.colors
local saved = sr.saved
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer

local currentSpec = GetSpecialization()

if not hunter.ready then return end

if currentSpec ~= 1 then return end

hunter.print(colors.hunter .. "Beast Mastery Hunter |cFFf7f25cLoaded")
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

bm:Init(function()
  if saved.rotationMode ~= "pveMode" 
  and saved.rotationMode ~= "hekiliMode" then 

    --Auto Focus 
    sr.autoFocus()

    --auto targeting 
    sr.autoTarget()

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
    hunter.drawFollowupTrap = false

    --local res, mend = NS(982), NS(136, { heal = true, ignoreFacing = true })
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

    -- interrupts
    if saved.smartkick and not inCamo then
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

    if saved.freedomUnit ~= "none"  then
      --freedom("helpfear")
      freedom()
    end

    -- --traptest("test")

    --command Stuff
    sr.trapCommand()
    intimidation("command")
    freedom("command")
    ros("command")

    if player.mounted then return end

    --Heal Player
    spiritMend("PVE")
    
    if player.hp <= saved.exhilaration then
      if exhilaration("Healplayer") then return end
    end 
    
    --Heal Pet
    if exhilaration("Healpet") then return end

    --will check for ultimate sac or Guardian
    if turtle()
    or turtle("Greedy") then 
      return 
    end
    
    --lets Make KS Higher
    if saved.rotationMode == "dmgAndUtil"
    and target.enemy 
    and not target.immunePhysicalDamage
    and not target.bcc then
      if kill("execute")
      or kill("anyone") 
      or kill("proc") 
      or killCommand("execute") then 
        return
      end
    end

    if player.hp <= saved.emblemtrinket then
      Trinkets.Emblem()
    end
    
    -- gatez
    if blink.prep 
    and sr.reactionDelay("healthstones") then
      hunter.healthstones:grab()
    else
      hunter.healthstones:auto()
    end

    -- pursue trapz
    if saved.autotrap then 
      local status = trap:pursue(trapTarget)
      if status and trap.cd < 4 and type(status) == "string" then
        shortalert(status, trap.id)
      end
    end  

    intimidation("auto")

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

    -- stompa
    if saved.autoStomp 
    and not turtled then
      if inCamo then return end
      if killCommand("stomp")
      or cobra("stomp") then
        return
      end
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

    --slow enemy tunnel
    --if saved.slowtunnel then
      --if concu("tunnel") then return end
    --end  

    --flares above pauses only during camo
    hunter.mark("enemy detection")

    if inCamo then
      flare("restealth")
      flare("stealth")
    end

    --pet eat trap
    if blink.arena 
    and saved.peteattrap 
    and healer.exists 
    and healer.stunned 
    or healer.exists and healer.debuff(213691) then
      hunter:PetEatTrap()
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

    -- --knock defs 
    -- --ExplosiveTrap("knockdefs")

    if sr.Pause() then return end

    if hunter.criticalPause then 
      return shortalert(hunter.criticalPause.msg, hunter.criticalPause.texture)
    end

    --Chimaeral Sting
    ChimaeralSting()
    ChimaeralSting("lockout")
    ChimaeralSting("badpostion")

    -- flare restealths
    if flare("restealth")
    -- flare visible stealth units
    or flare("stealth")
    -- flarefriendly healer
    or flare("friendly") then 
      return
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
        bm.racial()
        Trinkets.Badge()
        
        if kill("execute")
        or kill("anyone") then 
          return
        end
        --barbed("maintain frenzy")
      end

      -- conc trap target when moving towards them
      if saved.autoslow then
        if conc("trap target") then return end
      end 
      
      if ready then
        
        if blink.burst then
          burstwild("bursty")
          wrath("go")
          crows("bursty")
          primalrage("bursty")
          COTW("bursty")
        end 

        if saved.mode == "ON" then
          wild("proc")
          COTW("proc")
          primalrage("proc")
        end 

        kill("proc")
        wrath("go")
        wrath("refresh barbed")

        -- pause unimportant
        if hunter.unimportantPause then return end
          
        --test to hold stuff to score a better traps this was higher
        direbeast()
        deathchakram()
        blackArrow()
        bassy("CD")
        bloodshed("wrath")
        killCommand("CDs")
        barbed("maintain frenzy")
        killCommand("gapclose")
        killCommand("2pc equipped")

        -- barbed("maintain frenzy")
        concu("slow target") 
        --or cobra("focus capped")
        cobra("pve")

      end
      
    end

    rotation()

    if hunter.temporaryAlert then
      shortalert(hunter.temporaryAlert.msg, hunter.temporaryAlert.texture)
    end

  elseif saved.rotationMode == "hekiliMode" then
    local turtled = player.buff(186265)
    local inCamo = player.buff(199483)

    if player.mounted then return end

    trap("PVE")
    -- disengage
    disengage:handler()
    hunter:PetControl()
    --cs("PVE")
    --command Stuff
    sr.trapCommand()
    intimidation("command")
    freedom("command")
    ros("command")
    bindingshot("command")
    Scatter("command")  
  
    --def/heal
    if saved.AutoSOTF then
      SOTF()
    end
  
    if saved.AutoFortitude then
      fortitude()
    end
  
    spiritMend("PVE")

    if exhilaration("PVE") 
    or turtle("PVE") then 
      return 
    end

    if sr.reactionDelay("healthstones") then
      hunter.healthstones:grab()
      hunter.healthstones:auto()
    end
  
    if sr.Pause() then return end

    if inCamo or turtled then return end

    sr.HekiliRotation()

  else
    
    local turtled = player.buff(186265)
    local inCamo = player.buff(199483)
  
    if player.mounted then return end

    trap("PVE")
    -- disengage
    disengage:handler()
  
    hunter:PetControl()
  
    dash("rooted")
    
    cs("PVE")
  
    --command Stuff
    sr.trapCommand()
    intimidation("command")
    freedom("command")
    ros("command")
    bindingshot("command")
    Scatter("command")  
  
    --Heal Player
    if saved.AutoSOTF then
      SOTF()
    end
  
    if saved.AutoFortitude then
      fortitude()
    end
  
    --def/heal

    spiritMend("PVE")

    if exhilaration("PVE") 
    or turtle("PVE") then 
      return 
    end
    
    --lets Make KS Higher
    if target.enemy 
    and not inCamo
    and not target.immunePhysicalDamage
    and not target.bcc then
      if kill("execute")
      or kill("anyone") 
      or kill("proc") then 
        return
      end
    end
  
    -- gatez
    if sr.reactionDelay("healthstones") then
      hunter.healthstones:grab()
      hunter.healthstones:auto()
    end
  
    if sr.Pause() then return end
  
    hunterMark()

    if inCamo then return end
    --local AOE = check if aoe suti
    
    local function pveRotation()
      
      local pveReady = target.exists 
      and target.enemy and target.combat 
      and not (target.bcc or target.dead 
      or target.debuff(203337) or player.debuff(410201))
      
      if pveReady then
        -- racials
        bm.racial()
        Trinkets.PVE()
        ultimatePostion:use()
        
        if kill("execute")
        or kill("anyone") then 
          return
        end
      end
  
      if pveReady 
      or target.isDummy then
  
        -- auto attack (all logic is handled by shared hunter module)
        hunter:Attack()
  
        --aoe damage
        if wrath("maintainPVE") then return end
        if barbed("maintainPVE") then return end
        if multiShot() then return end


        if killCommand("PVE") then return end
        if barbed("PVE") then return end
        if COTW("PVE") then return end
        if wrath("PVE") then return end
        if bloodshed("PVE") then return end
        if deathchakram("PVE") then return end
  
        kill("execute")
        kill("anyone")
  
        cobra("PVE")
  
        --single damage
        --cobra("pve")
      end
    end
  
    pveRotation()
  end
end, 0.01)