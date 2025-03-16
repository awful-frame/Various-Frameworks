local Unlocker, blink, sr = ...
local bin, min, max = blink.bin, min, max
local hunter, mm = sr.hunter, sr.hunter.mm
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local alert = blink.alert 
local shortalert = function(msg, txid)
  return alert({message = msg, texture = txid, duration = 0.035, fadeOut = 0.1, fadeIn = 0.1 })
end 
local saved = sr.saved
local colors = blink.colors
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local currentSpec = GetSpecialization()

if not hunter.ready then return end

if currentSpec ~= 2 then return end

hunter.print(colors.hunter .. "Marksmanship Hunter |cFFf7f25cLoaded")
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

mm:Init(function()

  if saved.rotationMode == "hekiliMode" then

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
    --hunter.fixKillCommandBug()
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
      if fortitude() then
      --or MMfortitude() then
        return
      end
    end

    if saved.freedomUnit ~= "none"  then
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

    --will check for ultimate sac or Guardian
    if turtle() 
    or turtle("Greedy") then
      return 
    end
    
    --Emblem
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

    -- if blink.MacrosQueued["trap safe"] then 
    --   local status = trap:pursue(trapTarget)
    --   if status and trap.cd < 4 and type(status) == "string" then
    --     shortalert(status, trap.id)
    --   end
    -- end  
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
      if arcaneshot("stomp") then return end
    end

    --root bad postions
    tartrap("badpostion")
    steeltrap("badpostion")

    --pet eat trap
    if blink.arena and saved.peteattrap and healer.stunned then
      hunter:PetEatTrap()
    end 

    --Slow bigdam
    if saved.slowbigdam then
      concu("slowbigdam") 
      --steeltrap("tyrant")
      tartrap("BM Pet")
      tartrap()
      --tartrap("tyrant")
      steeltrap()
    end  

    hunter.mark("enemy detection")
    
    -- flares above pauses only during camo
    if inCamo then

      flare("restealth")
      flare("stealth")

      if saved.rotationMode == "dmgAndUtil" 
      and blink.burst then
        
        --guard it 
        if target.buffFrom({198589, 212800, 45438, 642, 362486, 186265}) then 
          return 
        end
    
        if target.buff(5277) 
        and target.facing(blink.player, 225) then
          return 
        end

        salvo("burst")

        --sniper shot
        if sniper("opener") then return end

        if player.hasTalent(sniper.id) then

          if player.used(sniper.id, 0.1) then

            mm.racial()
            Trinkets.Badge()

            --Chakram
            chakram("burst")
          
            --rapid fire
            rapid("burst")

            --explosive
            explosive("burst")

            --trueshot
            trueshot("burst")
          end
          
        else
            
          if aimed() then return end

          if player.used(aimed.id, 0.1) then 
            mm.racial()
            Trinkets.Badge()

            --Chakram
            chakram("burst")
          
            --rapid fire
            rapid("burst")

            --explosive
            explosive("burst")

            --trueshot
            trueshot("burst")
          end
        end
      end 
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


    local function rotation()
      
      local ready = saved.rotationMode == "dmgAndUtil" and target.exists and target.enemy and not (target.dead or target.debuff(203337) or player.debuff(410201))

      if turtled then return end

      if hunter.importantPause then 
        return shortalert(hunter.importantPause.msg, hunter.importantPause.texture) 
      end

      if ready then
        -- racials
        mm.racial()
        Trinkets.Badge()

        if kill("execute")
        or kill("anyone")
        or kill("proc") then
          return
        end
      end

      -- conc trap target when moving towards them
      if saved.autoslow then
        if conc("trap target") then return end
      end 
      
      --slow enemy tunnel
      --if saved.slowtunnel then
        --if concu("tunnel") then return end
      --end  
      
      if ready then

        --Burst
        if blink.burst 
        or saved.mode == "ON" 
        and (target.stunned 
        or enemyHealer.exists and enemyHealer.ccRemains > 3
        or target.hp < 85) and target.dist < aimed.range then

          if (target.buff(198589) or target.buff(212800) or target.immunePhysicalDamage) then return end
          if player.stealth and player.hasTalent(203155) then return end
            
          salvo("burst")

          --Chakram
          chakram("burst")

          mm.racial()
          Trinkets.Badge()
          
          aimed("proc")

          --lets prio aimed if we are stand still
          if not player.moving then   
            aimed()
          end

          --rapid fire
          rapid("burst")
    
          --explosive
          explosive("burst")

          --trueshot
          trueshot("burst")

        end

        aimed("proc")
        aimed()
        blackArrow()
        rapid("normal") 
        serpent()
        sniper()

        --lowprio
        volley("burst")
        steadyshot()

        -- pause unimportant
        if hunter.unimportantPause then return end
          
        if concu("slow target") 
        or arcaneshot("focus capped")
        or arcaneshot("pve") then 
          return
        end
        
      end
      
    end

    rotation()

    if hunter.temporaryAlert then
      shortalert(hunter.temporaryAlert.msg, hunter.temporaryAlert.texture)
    end
  end
end, 0.03)