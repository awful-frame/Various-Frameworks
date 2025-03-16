local Unlocker, blink, sr = ...
local bin, min, max = blink.bin, min, max
local druid, feral = sr.druid, sr.druid.feral
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

local currentSpec = GetSpecialization()

if not feral.ready then return end

if currentSpec ~= 2 then return end


druid.print(colors.druid .. "Feral Druid |cFFf7f25cLoaded!")
druid.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
druid.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--tickrate
local srtickRate = saved.tickrate

--enable on load
--blink.protected.RunMacroText("/sr toggle")
C_Timer.After(0.5, function()
    blink.enabled = true
    blink.print("|cFFf7f25c[SadRotations]: |cFF22f248Enabled")
end)

local framesNotCat = 0

feral:Init(function()

    local form = player.buff(768) and "cat" 
    or player.buff(5487) and "bear"
    or player.buff(783) and "travel"

    --    
    local validTarget = target.exists and target.enemy and not target.dead
    local validPhysical = validTarget and not target.bcc and not target.immunePhysicalDamage and not target.immunePhysicalEffects
    local validPhysicalInRange = validPhysical and target.predictDist(blink.buffer) < 3 and player.isFacing(target)
    local validMagic = validTarget and not target.immuneMagicDamage and not target.bcc


    --local ready = target.exists and target.enemy and not target.dead or target.bcc
    local ready = target.exists and target.enemy and not (target.bcc or target.debuff(203337))

    if player.mounted then return end
        
    sr.FlagPick()

    if player.buff(783) and not player.combat then return end 

    --Auto Focus 
    sr.autoFocus() 
    
    --auto targeting 
    sr.autoTarget() 

    --Restun
    -- if (target.debuffRemains(163505, "player") < 0.5
    -- and target.debuffRemains(163505, "player") >= 0.1) 
    -- or (target.debuffRemains(203123, "player") < 0.5
    -- and target.debuffRemains(203123, "player") >= 0.1) 
    -- and target.meleeRange
    -- and player.buff(768)
    -- and player.race == "Night Elf"
    -- and target.isPlayer
    -- and meld.cd == 0 
    -- and not target.immuneStuns then 

    --     if meld:Cast({stopMoving = true}) then

    --         blink.alert("Meld + Restun", meld.id)

    --         blink.controlMovement(blink.gcdRemains)

    --         if player.buff(58984) then
    --             rake:Cast(target, { face = true })
    --         end
    --     end

    -- end

    if player.buffFrom({58984, 5215}) then
        if rake("prowled") then return end
    end

    -- ready to open
    local readyToOpen
    if validPhysicalInRange and player.stealth then
        readyToOpen = true
    end

    -- opener stuff
    if readyToOpen then

        if not player.stealth then return end

        if target.exists
        and target.enemy 
        and player.stealth
        and target.stunDR == 1 or target.sdrr > 17 
        and target.stunRemains < 0.8 then
            
            if target.distliteral < 8 
            and player.movingToward(target) then
                -- tf
                if tigersfury:Cast() then
                    blink.alert("Tiger's Fury", tigersfury.id)
                end
            end
        
            -- if rake:Cast(target) then
            --     alert("Rake Stun", rake.id)
            -- end
        
        end 

        -- swarm + frenzy go
        if player.hasTalent(frenzy.id) then
            
            -- tf
            if tigersfury:Cast() then
                blink.alert("Tiger's Fury", tigersfury.id)
            end

            -- frenzy
            if player.cp <= 3 
            and target.exists
            and target.enemy
            and target.stunned 
            and not player.stealth then 
                if frenzy:Cast(target, { face = true }) then
                    blink.alert("Feral Frenzy", frenzy.id)
                end
            end

            --swarm
            if target.exists
            and frenzy.used(3) 
            and target.enemy then
                return swarm:Cast(target)
            end

            --rip
            if player.cp >= 5 then
                
                if target.exists and target.hp < 30 then return end

                if player.buffFrom({58984, 5215}) then
                    if rake("prowled") then return end
                end
            
                if player.buff(58984) then return end

                return rip:Cast(target, { face = true })
            end

        end
        
    end

    -- do opener prio logic
    -- local status
    -- if target.enemy and target.debuff(163505, "player") then
    --     status = feral.opener()
    -- end
    
    --nothing stealth down here
    if player.stealth then return end 

    -- leap out of spear
    -- local spear = events.spearCast
    -- if spear and time - spear.time < 0.15 then
    --     if spear.source.target.isUnit(player) or spear.source.dist < 6 then
    --         if feral.leapAway() then
    --             feral.leapAway()
    --             feral.leapAway()
    --             feral.leapAway()
    --             alert("Wild Charge (Spear)", feral.charge.cat.id)
    --             return true
    --         end
    --     end
    -- end

    wildcharge("gapclose")

    --Stuff By Macros    
    if clone()
    or bash() then
        return
    end

    --trinkets    
    if player.hp <= saved.emblemtrinket then
        Trinkets.Emblem()
    end

    --Cat form or just dash  
    if not form and validPhysical and player.moving then
        if player.buff(768) then return end

        if saved.AutoDash then
            if player.movingToward(target, { duration = 0.2 }) then
                if target.predictDist(0.35) > 5 then
                    if dash:Cast() then
                        alert("Dash (Gapclose)", dash.id)
                        return true
                    end
                end
            end
        end
        framesNotCat = framesNotCat + 1
        if player.casting then framesNotCat = 0 end
        if framesNotCat > 8 - bin(player.movingToward(target, {duration = 0.125})) * 4 then
            if cat:Cast() then
                alert("Cat Form", cat.id)
                return true
            end
        end
    else
        framesNotCat = 0
    end    

    if stampedingroar("gapclose") then return end

    --shift roots
    if saved.AutoShift
    and player.rooted 
    and (not target.enemy or target.predictDist(blink.gcdRemains) > 3.25) 
    and frenzy.cd < 44.5 and blink.hasControl then
        if form and (form ~= "bear" or player.hp > 90) then
            alert("|cFFfa8ea8Cancel Form|r |cFF9ed0ff(Rooted)", feral[form].id)
            blink.call("CancelShapeshiftForm")
        elseif form ~= "cat" and cat:Cast() then
            alert("|cFFfa8ea8Cat Form|r |cFF9ed0ff(Rooted)", cat.id)
        end
    end

    -- gate
    if blink.prep then
        druid.healthstones:grab()
    else
        druid.healthstones:auto()
    end

    --stompin
    if saved.autoStomp then
        if moonfire("stomp")
        or shred("stomp") then
            return
        end
    end

    --local function rotation()

        --local ready = target.exists and target.enemy and not target.dead or target.bcc
        local ready = target.exists and target.enemy and not (target.bcc or target.dead or target.debuff(203337) or player.debuff(410201))

        if ready 
        and not blink.prep then
            -- racials
            feral.racial()
            Trinkets.Badge()
        end

        --zerk
        if blink.burst 
        or saved.mode == "ON" 
        and (target.exists and target.stunned 
        or enemyHealer.exists and enemyHealer.ccRemains > 3.5 
        or not enemyHealer.exists and target.exists and target.hp < 80) and target.meleeRange then

            if player.stealth or player.buff(58984) then return end
                    
            berserk()
            incarnation()

        end

        --build CP to maim
        if (blink.MacrosQueued["maim target"]
        or blink.MacrosQueued["maim focus"]
        or blink.MacrosQueued["maim arena1"]
        or blink.MacrosQueued["maim arena2"]
        or blink.MacrosQueued["maim arena3"]) then

            if (blink.MacrosQueued["maim target"]
            or blink.MacrosQueued["maim focus"]
            or blink.MacrosQueued["maim arena1"]
            or blink.MacrosQueued["maim arena2"]
            or blink.MacrosQueued["maim arena3"])
            and not player.buff(768) then
              if (player.stealth or player.buff(58984)) then return end
              if tigersfury.cd < 0.5 and player.cp == 5 and not player.buff(768) then
                return tigersfury:Cast()
              elseif tigersfury.cd > 0.5 and player.cp == 5 then
                cat:Cast()
              end
            end 

            if player.cp < 5
            and feral.maim.cd < 3 
            and not blink.prep then 
                blink.alert(colors.yellow .. "Building CP", feral.maim.id)
                frenzy()
                feral.racial()
                Trinkets.Badge()
                bite("finisher")
                rake("maintain")
                thrash("maintain")
                moonfire("maintain")
                slash("getcp")
                shred("getcp")
                rip("maintain")
                primal("maintain")
                swarm()
            elseif player.cp == 5 and feral.maim.cd < 0.5 then
                maim()
            elseif feral.maim.cd > 3 
            or target.debuff(203123, "player")
            or focus.debuff(203123, "player")
            or arena1.debuff(203123, "player")
            or arena2.debuff(203123, "player")
            or arena3.debuff(203123, "player") then
                blink.MacrosQueued["maim target"] = nil 
                blink.MacrosQueued["maim focus"] = nil 
                blink.MacrosQueued["maim arena1"] = nil 
                blink.MacrosQueued["maim arena2"] = nil 
                blink.MacrosQueued["maim arena3"] = nil 
            end
        end

        --buff up
        MOTW()

        if prowl()
        or frenzy()
        or swarm()
        or bash("cc healer")
        or maim("auto maim") then
            return
        end

        --Kicking
        skullbash("interrupt")
        skullbash("seduction")
        skullbash("tyrants")

        --Bear Defs
        if not (blink.MacrosQueued["maim target"]
        or blink.MacrosQueued["maim focus"]
        or blink.MacrosQueued["maim arena1"]
        or blink.MacrosQueued["maim arena2"]
        or blink.MacrosQueued["maim arena3"]) then
            regeneration("emergency")
            ironfur()
            Bearthrash()
        end

        --Auto Defs
        if renewal("emergency")
        or barkskin("emergency")
        or barkskin("slider")
        or Instincts("emergency") then
            return
        end

        if sr.Pause() then return end

        if feral.bignut() then return end

        -- root healer behind pillar
        if root(1)
        -- root on gapclose/open event
        or root(2)
        -- root off-target out of LoS of healer
        or root(4)
        -- root melee while kiting / on cds
        or root(5)
        -- root warrior with intervene on go
        or root(8)
        -- root healer to help hunter get trap or mage get sheep 
        or root(9) then
            return
        end

        local ring = sr.friendlyRoF
        if ring then
            -- root inside friendly ring
            if feral.root(11) then return end
            -- ursol inside friendly ring
            if feral.ursol(3) then return end
        end
    
        -- root / ursol out of areatrigger defensives
        if feral.root(10) then return end

        -- look for link
        feral.link = nil
        blink.totems.stomp(function(totem, uptime)
            local id = totem.id
            if id == 53006 then
                feral.link = totem
            end
        end)

        -- root out of link
        if feral.root(3) then return end

        -- big swifty p
        if swiftmend() 
        or cat() then 
            return 
        end 

        -- thorns/decurse
        if thorns()
        or decurse() then
            return
        end

        -- high prio regrowth
        if regrowth(1) then return end

        -- root gapclose (target kiting me)
        if root(6) then return end

        --bite("execute")

        --Auto attack
        druid:Attack()

        if ready then    
            if bite("finisher")
            or rake("maintain")
            or thrash("maintain")
            or moonfire("maintain")
            or slash("getcp")
            or shred("getcp")
            or rip("maintain")
            or primal("maintain") then
                return 
            end
        end

        -- root melee / others moving towards your healer on CD
        if feral.root(7) then return end

        -- rejuv
        -- if feral.rejuv() then return end

        -- low prio regrowth
        if feral.regrowth(2) then return end
    --end

    --rotation()

end, 0.5)