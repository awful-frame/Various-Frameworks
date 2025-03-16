local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local buffer, latency, gcd = blink.buffer, blink.latency, blink.gcd
local eventCallback, autoFocus = blink.addEventCallback, blink.AutoFocus
local priest, disc = sr.priest, sr.priest.disc
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

if currentSpec ~= 1 then return end

priest.print(colors.priest .. "Discipline Priest |cFFf7f25cLoaded!")
priest.print("|cFFFFFFFFType |cff00ccff/sr|r to open the GUI.")
priest.print("|cFFFFFFFFType |cff00ccff/sr toggle|r to enable/disable the rotation.")

--tickrate
local srtickRate = saved.tickrate

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

disc:Init(function()

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

    --death stuff
    if death("cc") then return end

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
        
        if barrier("smart")
        or barrier("slider")
        or purify("importants")
        or desperate("emergency")
        or fade("emergency")
        or radiance()
        or rapture()
        or PS("smart")
        or PS("slider")
        or flash("instant")
        or shield()
        or penance()
        or penance("harsh")
        or penance("dmg")
        or renew() then
            return 
        end

        --offensive
        darkangel("burst")
        fiend()
        PI()

        shield("harsh")
        schism()
        --solace()
        mindgames("dmg")
        wicked()
        mindgames()
        mindblast()
        smite()

        --healing
        if archangel()
        or powerlife()
        or flash()
        or POM() then
            return
        end

        purge()
        --offensive
        -- darkangel("burst")
        -- fiend()
        -- purge()
        -- PI()

        --dmg
        if saved.autoStomp then 
            wicked("stomp") --stomp
        end
        
        -- shield("harsh")
        -- penance("harsh")
        -- schism()
        -- solace()
        -- mindgames("dmg")
        -- wicked()
        -- mindgames()
        -- mindblast()
        -- smite()

        feather()

    end

    rotation()

    fortitude()
    --innerlight()
    -- innerlight("pvp")
    -- innershadow("pvp")
    --disc.updateInnerBuff()
    
end, 0.01)
  
