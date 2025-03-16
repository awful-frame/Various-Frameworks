local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local buffer, latency, gcd = blink.buffer, blink.latency, blink.gcd
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local priest, holy = sr.priest, sr.priest.holy
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

if not priest.ready then return end

if currentSpec ~= 2 then return end

priest.print(colors.priest .. "Holy Priest |cFFf7f25cLoaded!")
priest.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
priest.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--tickrate
local srtickRate = saved.tickrate

--enable on load
--blink.protected.RunMacroText("/sr toggle")
C_Timer.After(0.5, function()
    blink.enabled = true
    blink.print("|cFFf7f25c[SadRotations]: |cFF22f248Enabled")
end)

holy:Init(function()

    local drinking = player.buff(369162) or player.buff("Drink")

    --Auto Focus 
    sr.autoFocus()

    if player.mounted then return end

    sr.FlagPick()

    -- gatez
    if blink.prep then
        priest.healthstones:grab()
    else
        priest.healthstones:auto()
    end
    
    if lifeswap("slider") then return end
    if fade("prediction") then return end
    if fade("trap") then return end
    if fade("grip") then return end
    --if deaths("cc") then return end
    if deaths("trap") then return end
    -- if death("cc") then return end
    -- if death("trap") then return end
    if death("grip") then return end
    feather("cc")
    --auto fear enemyhealer
    if scream("command") then return end
    if scream("cc healer") then return end

    --death stuff
    if fade("cc") then return end
    if death("cc") then return end

    --stuns    
    if chastise("command") then return end

    --drinking
    if drinking then return end

    --execute
    if death("anyone") then return end

    --MD Stuff
    if MD("immunes") then 
        return 
    end

    tendrils("CDs")
    tendrils("BM Pet")
    tendrils("badpostion")

    --if members.hp < 60 then startheal end
    --if enemyHealer.ccr > 3.5 and members.hp > 60 then dps end
    local function rotation()

        --let me MC    
        if player.castID == 605 
        or player.channelID == 605 then 
            return 
        end 
        
        --healing
        apo()
        serenity()
        flash("instant")
        purify("importants")
        desperate("emergency")
        fade("emergency")
        guardian("slider")

        archangel()
        powerlife()
        shield()
        flash()
        heal()
        sanctify()
        POM()
        renew()

        --offensive
        darkangel("burst")
        fiend()
        purge() 
        PI()

        --dmg
        if saved.autoStomp then 
            pain("stomp") --stomp
        end
        
        schism()
        solace()
        mindgames("dmg")
        pain()
        mindgames()
        holyFire()
        smite()

        feather()

    end

    rotation()

    fortitude()
    --innerlight()
    innerlight("pvp")
    innershadow("pvp")
    
end, 0.01)
  
