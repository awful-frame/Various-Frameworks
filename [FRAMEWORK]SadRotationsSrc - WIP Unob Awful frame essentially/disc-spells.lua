local Unlocker, blink, sr = ...
local bin, min, max, cos, sin = blink.bin, min, max, math.cos, math.sin
local onUpdate, hookCallbacks, hookCasts, NS, NewItem = blink.addActualUpdateCallback, blink.hookSpellCallbacks, blink.hookSpellCasts, blink.Spell, blink.Item
local buffer, latency, gcd = blink.buffer, blink.latency, blink.gcd
local saved = sr.saved
local priest, disc = sr.priest, sr.priest.disc
local alert = blink.alert
local colors = blink.colors
local enemy = blink.enemy
local player = blink.player
local bin = blink.bin
local Draw = blink.Draw
local gz = blink.GroundZ
local stompDelay = blink.delay(0.4, 0.5)


local currentSpec = GetSpecialization()

if not priest.ready then return end

if currentSpec ~= 1 then return end   

blink.Populate({

    target = blink.target,
    focus = blink.focus,
    player = blink.player,
    healer = blink.healer,
    fhealer = blink.healer,
    pet = blink.pet,
    enemyHealer = blink.enemyHealer,
    arena1 = blink.arena1,
    arena2 = blink.arena2,
    arena3 = blink.arena3,
    enemyPets = blink.enemyPets,

    deaths = priest.deaths,
    
    --healing
    flash = NS(2061, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = player.buff(114255) }),
    renew = NS(139, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),
    penance = NS(47540, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),
    radiance = NS(194509, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = player.hasTalent(236499) }),
    powerlife = NS(373481, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),
    shield = NS(17, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),
    POM = NS(33076, { heal = true, targeted = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),

    --defensives
    PS = NS(33206, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = true, ignoreGCD = true, ignoreStuns = true }),
    rapture = NS(47536, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),
    barrier = NS(62618, { heal = true, ranged = true, ignoreFacing = true, diameter = 12, ignoreMoving = true }),
    desperate = NS(19236, { heal = true, ranged = true, ignoreFacing = true, ignoreGCD = true, ignoreMoving = true }),
    lifeswap = NS(108968, { heal = true, ranged = true, ignoreFacing = true, ignoreMoving = true }),
    fade = priest.fade,
    archangel = NS(197862, { facingNotRequired = true, beneficial = true }),

    --damage
    solace = NS(129250, { damage = "magic", ranged = true, ignoreFacing = true, ignoreMoving = true }),
    schism = NS(214621, { damage = "magic", ranged = true, ignoreFacing = true }),
    mindblast = NS(8092, { damage = "magic", ranged = true, ignoreFacing = true }),
    wicked = NS(204197, { damage = "magic", ranged = true, ignoreFacing = true, ignoreMoving = true }),
    smite = priest.smite,
    mindgames = NS(375901, { damage = "magic", ranged = true, ignoreFacing = true }),
    death = priest.death,
    darkangel = NS(197871, { ignoreMoving = true, facingNotRequired = true }),
    --offensives
    PI = NS(10060, { ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    fiend = priest.fiend,

    --cc
    scream = priest.scream,
    tendrils = priest.tendrils,
    
    --Inners 
    innerlight = NS(355897),
    innershadow = NS(355898),
    fortitude = priest.fortitude,

    --mics
    purify = NS(527, { beneficial = true, ignoreFacing = true }),
    purge = NS(528, { beneficial = true, ignoreFacing = true }),
    MD = NS({327830, 32375}, { ranged = true, diameter = 30 }),
    grip = NS(73325, { ranged = true, ignoreFacing = true }),
    feather = NS(121536, { ignoreFacing = true, }),


    --Trinkets Table
    Trinkets = {
        Badge = blink.Item({216368, 216279, 209343, 209763, 205708, 205778, 201807, 201449, 218421, 218713}),
        Emblem = blink.Item({216371, 216281, 209345, 209766, 201809, 201452, 205781, 205710, 218424, 218715}),
    },
    -- items
    tierPieces = NewItem({188907, 188901, 188905, 188902, 188903}),


}, disc, getfenv(1))

local function bcc(obj) return obj.bcc end

local MAX_UNIT_DISTANCE = 40
local INITIAL_HEALTH_PERCENT = 100
local INITIAL_ACTUAL_HEALTH = 200000
local PLAYER_UNIT = blink.player

-- Bad debuffs and buffs to check against; units with these are not ideal targets.
local badDebuffs = {"Forgeborne Reveries", "Cyclone", "Shadowy Duel", 203337, 221527}
local badBuffs = {"Alter Time", "Spirit of Redemption", "Podtender", "Forgeborne Reveries"}

-- Finds the lowest and second lowest health units within the group.
local function updateLowestHealthUnits()
    -- Resetting lowest and second lowest health tracking.
    sr.LowestHealth = INITIAL_HEALTH_PERCENT
    sr.LowestUnit = PLAYER_UNIT
    sr.LowestPetHealth = INITIAL_HEALTH_PERCENT
    sr.LowestPetUnit = PLAYER_UNIT
    sr.SecondLowestHealth = INITIAL_HEALTH_PERCENT
    sr.SecondLowestUnit = PLAYER_UNIT
    sr.LowestActualHealth = INITIAL_ACTUAL_HEALTH
    sr.LowestActualUnit = nil

    -- Loop through all group members.
    blink.fgroup.loop(function(unit)
        if not unit.dead 
        and not unit.charmed 
        and not unit.immuneHealing
        and not unit.debuffFrom(badDebuffs) 
        and not unit.buffFrom(badBuffs)
        and unit.distance <= MAX_UNIT_DISTANCE 
        and unit.los then
            -- Checking for lowest health based on percentage.
            if unit.hp < sr.LowestHealth then
                sr.SecondLowestHealth = sr.LowestHealth
                sr.SecondLowestUnit = sr.LowestUnit
                sr.LowestHealth = unit.hp
                sr.LowestUnit = unit
            elseif unit.hp > sr.LowestHealth and unit.hp < sr.SecondLowestHealth then
                sr.SecondLowestHealth = unit.hp
                sr.SecondLowestUnit = unit
            end
            -- Checking for lowest actual health ignoring the player.
            if not unit.isUnit(PLAYER_UNIT) and unit.health < sr.LowestActualHealth then
                sr.LowestActualHealth = unit.health
                sr.LowestActualUnit = unit
            end
        end
    end)
end
blink.addUpdateCallback(updateLowestHealthUnits)
    

local SwapOverLap = {

    186265, --turtle
    196555, --netherwalk
--    206803, --rainfromabove
    61336,  --survival ins
    45438,  --iceblock
    342246, --altertime
    116849, --ccon
    1022,   --bop
    642,    --bubble
    228049, --guardian prot pala
    33206,  --PS
    47585,  --disperson
    47788,  --guardian priest
    5277,   --rogue evaison
    108271,  --astral shift
    108416,  --lock shield sac
    118038,  --die by the sowrd
    871,     --shield wall
    81782,   --Big Barrier

}

local DispelRoots = {
    122, -- frost nova
    102359, --massroot
    339, --druid root
    33395, --another proc nova
    64695, --earthgrap
}


-- innerlight:Callback(function(spell)
--     if innerlight.used(3) 
--     or innershadow.used(3) then 
--         return 
--     end

--     if player.buff(355897) 
--     or player.buff(355898) then
--         return 
--     end
 
--     return spell:Cast()

-- end)

function disc.updateInnerBuff()
    if not player.hasTalent(356085) then
        return
    end

    local hasInnerLight = player.buff(355897) -- Inner Light
    local hasInnerShadow = player.buff(355898) -- Inner Shadow
    local manaPct = player.manaPct

    -- If neither Inner Light nor Inner Shadow is active, default to applying Inner Light.
    if not hasInnerLight and not hasInnerShadow then
        innerlight:Cast()
        return
    end

    if manaPct > 70 
    and hasInnerLight then
        innershadow:Cast()
    else
        if manaPct <= 70 
        and hasInnerShadow then
            innerlight:Cast()
        end
    end
end
blink.addUpdateCallback(disc.updateInnerBuff)

innerlight:Callback("pvp", function(spell)
    
    if player.buff(355898) and player.manaPct > 70 then return end

    if player.buff(355898) 
    and player.manaPct <= 70 then
        sr.cancelSpellByName(innershadow.id)
    end

    if not player.buffFrom({ 355897, 355898 }) then
        spell:Cast(player)
    end
end)

innershadow:Callback("pvp", function(spell)
    if player.manaPct > 70 
    and player.buff(355897) then
        spell:Cast(player)
    end
end)

solace:Callback(function(spell)

    if not player.hasTalent(spell.id) then return end

    blink.enemies.loop(function(enemy)

        if enemy.immuneMagicDamage then return end
        --if not enemy.isPlayer then return end
        if enemy.dist > 40 then return end
        if not enemy.los then return end
        if enemy.bcc then return end

        return spell:Cast(target)

    end)
end)

wicked:Callback(function(spell)

    -- if not target.enemy then return end
    -- if target.immuneMagicDamage then return end
    -- --if not target.isPlayer then return end
    -- if target.dist > 40 then return end
    -- if not target.los then return end
    -- if target.bcc then return end
    -- if target.debuffRemains(204213, 'player') > 1.5 then return end

    -- if target.buffFrom({23920, 212295, 8178}) then
    --     spell:Cast(target, {face = true})
    -- end

    -- return spell:Cast(target, {face = true})

    blink.enemies.loop(function(enemy)

        if enemy.immuneMagicDamage then return end
        if not enemy.isPlayer then return end
        if enemy.dist > 40 then return end
        if not enemy.los then return end
        if enemy.bcc then return end
        if enemy.debuffRemains(204213, 'player') > 1.5 then return end

        if enemy.buffFrom({23920, 212295, 8178}) then
            spell:Cast(enemy, {face = true})
        end

        return spell:Cast(enemy, {face = true})

    end)
end)

schism:Callback(function(spell)

    if spell.cd > 0.5 then return end

    if not target.enemy then return end
    if target.immuneMagicDamage then return end
    if target.dist > 40 then return end
    if not target.los then return end
    if target.bcc then return end
    if target.buffFrom({23920, 212295, 8178}) then return end

    if player.castID == spell.id 
    and player.castTarget.isUnit(target) 
    and target.buffFrom({23920, 212295, 8178}) then
        blink.call("SpellStopCasting")
    end

    return spell:Cast(target)

end)    

smite:Callback(function(spell)

    if spell.cd - blink.gcdRemains > 0 then return end

    if not target.enemy then return end
    if target.immuneMagicDamage then return end
    if target.dist > 40 then return end
    if not target.los then return end
    if target.bcc then return end

    return spell:Cast(target)

end)    

mindblast:Callback(function(spell)

    if spell.cd - blink.gcdRemains > 0 then return end

    if not target.enemy then return end
    if target.immuneMagicDamage then return end
    if target.dist > 40 then return end
    if not target.los then return end
    if target.bcc then return end
    if target.buffFrom({23920, 212295, 8178}) then return end

    if player.castID == spell.id 
    and player.castTarget.isUnit(target) 
    and target.buffFrom({23920, 212295, 8178}) then
        blink.call("SpellStopCasting")
    end

    return spell:Cast(target)

end)   

penance:Callback("dmg", function(spell)
    if player.hasTalent(373180) then return end
    local lowest = sr.lowest(fgroup)

    blink.enemies.loop(function(enemy)

        if lowest <= 50 then return end
        if enemy.immuneMagicDamage then return end
        if not enemy.combat then return end
        if enemy.dist > 40 then return end
        if not enemy.los then return end
        if enemy.bcc then return end
        if not enemy.isPlayer then return end

        local arenaBracket = GetNumGroupMembers()
        if arenaBracket == 2 then
            if player.buff(373183) 
            or lowest > 50 
            and enemy.v2attackers(true) >= 1 then

                if player.channelID == spell.id 
                and player.castTarget.isUnit(enemy) 
                and enemy.bcc then
                    return
                end

                return spell:Cast(enemy, {face = true})
            end
        elseif arenaBracket == 3 then
            if player.buff(373183) 
            or lowest > 50 
            and enemy.v2attackers(true) > 1 then

                if player.channelID == spell.id 
                and player.castTarget.isUnit(enemy) 
                and enemy.bcc then
                    return
                end

                return spell:Cast(enemy, {face = true})
            end
        end
            

    end)

end)

penance:Callback("harsh", function(spell)
    if target.bcc then return end 
    if not player.hasTalent(373180) then return end

    if target.enemy 
    and player.buff(373183) 
    and player.buff(390706)
    or player.buff(198069) then
        spell:Cast(target)
    end

end)

mindgames:Callback(function(spell)

    if spell.cd - blink.gcdRemains > 0 then return end

    if not target.enemy then return end
    if target.immuneMagicDamage then return end
    if target.dist > 40 then return end
    if not target.los then return end
    if target.bcc then return end
    if target.buffFrom({23920, 212295, 8178}) then return end

    if player.castID == spell.id 
    and player.castTarget.isUnit(target) 
    and target.buffFrom({23920, 212295, 8178}) then
        blink.call("SpellStopCasting")
    end

    if enemyHealer.ccRemains > 3.5 
    or not enemyHealer.exists and target.hp < 85 then
        return spell:Cast(target, {face = true})
    end

end)   

mindgames:Callback("dmg", function(spell)

    local lowest = sr.lowest(fgroup)

    blink.enemies.loop(function(enemy)
        if player.moving then return end
        if lowest <= 50 and not enemyHealer.cc then return end
        if enemy.immuneMagicDamage then return end
        if not enemy.combat then return end
        if enemy.dist > 40 then return end
        if not enemy.los then return end
        if enemy.bcc then return end
        if not enemy.isPlayer then return end
        if enemy.buffFrom({23920, 212295, 8178}) then return end

        if player.castID == spell.id 
        and player.castTarget.isUnit(enemy) 
        and enemy.buffFrom({23920, 212295, 8178}) then
            blink.call("SpellStopCasting")
        end

        local arenaBracket = GetNumGroupMembers()
        if arenaBracket == 2 then
            if blink.burst 
            or target.hp < 85
            or enemyHealer.ccRemains > 3.5 
            or not enemyHealer.exists and target.hp < 90 
            and enemy.v2attackers(true) >= 1 then 
                return spell:CastAlert(enemy, {face = true})
            end
        elseif arenaBracket == 3 then
            if blink.burst 
            or target.hp < 85
            or enemyHealer.ccRemains > 3.5 
            or not enemyHealer.exists and target.hp < 85 
            and enemy.v2attackers(true) > 1 then 
                return spell:CastAlert(enemy, {face = true})
            end
        end

    end)

end)

-- death:Callback("trap", function(spell, unit)

--     blink.enemies.loop(function(enemy)

--         blink.triggers.loop(function(trigger)

--             if trigger.id ~= 187651 then return end

--             return spell:Cast(enemy)

--         end)
--     end)

-- end)

--============================================================Healing Starts--===================================================================================

renew:Callback(function(spell)

    if sr.LowestUnit.buffRemains(spell.id, player) > 2 then return end

    if sr.LowestHealth < 80 then
        if spell:Castable(sr.LowestUnit) then
            if spell:Cast(sr.LowestUnit) then
                return
            end
        end
    end

end)

POM:Callback(function(spell)
    if not player.hasTalent(spell.id) then return end

    if sr.LowestHealth < 75 then
        if spell:Castable(sr.LowestUnit) then
            if spell:Cast(sr.LowestUnit) then
                return
            end
        end
    end

end)

flash:Callback(function(spell)

    if sr.LowestHealth <= saved.FlashHeal then
        if spell:Castable(sr.LowestUnit) then
            if spell:Cast(sr.LowestUnit) then
                return
            end
        end
    end
end)

flash:Callback("instant", function(spell)

    if not player.buff(114255) then return end

    if sr.LowestHealth <= 80 then
        if spell:Castable(sr.LowestUnit) then
            return spell:Cast(sr.LowestUnit, {ignoreMoving = true})
        end
    end
end)


shield:Callback(function(spell)


    if sr.LowestUnit.buff(spell.id) then return end

    if sr.LowestHealth <= 95 then
        if spell:Castable(sr.LowestUnit) then
            return spell:Cast(sr.LowestUnit)
        end
    end

end)

shield:Callback("harsh", function(spell)
    if not player.hasTalent(373180) then return end

    if target.enemy 
    and player.buff(373183) 
    and player.buff(390706) then
        spell:Cast()
    end

end)

penance:Callback(function(spell)
    local nearestEnemy = blink.enemies.find(function(enemy) return enemy.distanceTo(sr.LowestUnit) <= 15 
    and not enemy.immuneMagicDamage 
    and not enemy.isHealer and not enemy.bcc end)


    if nearestEnemy then     
        if sr.LowestHealth <= saved.PenanceHeal then
            if spell:Castable(nearestEnemy) then
                return spell:Cast(nearestEnemy, {face = true})
            end
        end
    else
        if sr.LowestHealth <= saved.PenanceHeal then
            if spell:Castable(sr.LowestUnit) then
                return spell:Cast(sr.LowestUnit, {face = true})
            end
        end
    end
end)

powerlife:Callback(function(spell)

    if sr.LowestHealth <= 35 then
        if spell:Castable(sr.LowestUnit) then
            return spell:Cast(sr.LowestUnit, {face = true})
        end
    end

end)


radiance:Callback(function(spell)

    if sr.LowestUnit.distanceLiteral > 30 then return end

    if sr.LowestHealth <= saved.RadianceHeal then
        if spell:Castable(sr.LowestUnit) then
            return spell:Cast(sr.LowestUnit, {face = true})
        end
    end

end)

rapture:Callback(function(spell)

    if sr.LowestHealth <= saved.RaptureHeal then
        if spell:Castable(sr.LowestUnit) then
            return spell:Cast(sr.LowestUnit, {face = true})
        end
    end

end)


barrier:Callback("slider", function(spell)

    if spell.cd - blink.gcdRemains > 0 then return end
    if player.lastcast == 108968 then return end
    if PS.current then return end
    if player.used(PS.id, 2) then return end
    if player.used(lifeswap.id, 2) then return end
    
    if sr.LowestUnit 
    and not sr.LowestUnit.buffFrom(SwapOverLap) then
        if sr.LowestHealth <= saved.BarrierHeal then

            if sr.LowestUnit.hp > saved.BarrierHeal then return end

            local x,y,z = gz(sr.LowestUnit.position())
            if not x then return end

            if player.casting or player.channeling then
                blink.call("SpellStopCasting")
                blink.call("SpellStopCasting")
            end

            if spell:AoECast(x,y,z) then 
                alert("Power Word: Barrier " .. (sr.LowestUnit.name or "") .. "|cFFf74a4a [Low hp]", spell.id)
            end
        end
    end
end)

local DispelMePls = {
    -- 8122, --priest fear
    -- 15487, --priest SC
    -- 198909, --monk khobaar
    -- 323673, --MG
    -- 375901, --MG
    -- 118,
    -- 161355,
    -- 161354,
    -- 161353,
    -- 126819,
    -- 61780,
    -- 161372,
    -- 61721,
    -- 61305,
    -- 28272,
    -- 28271,
    -- 277792,
    -- 277787, --end of polys
    -- 113724, --ring
    -- 82691,  --ring
    -- 118699,  --fear
    -- 6358, --suddection
    -- 360806, --sleep walk
    -- 6789, --coil
    -- 179057, --dh choas nova
    -- 853, -- hoj
    -- 3355, --trap
    -- 1513, --scarebeast
    -- 2637, -- hiprenate
    -- 5484, --lock Horrror
    [15487] = { uptime = 0.25, min = 2 },		 -- priest SC
    [198909] = { uptime = 0.25, min = 2 },		 -- monk khobaar
    [6789] = { uptime = 0.25, min = 2 },		 -- coil
    [8122] = { uptime = 0.25, min = 2 },		 -- Psychic Scream
    [112] = { uptime = 0.25, min = 2 }, -- Frost Nova
    [mindgames.id] = { uptime = 0.1, min = 2 }, -- Mindgames
    [375901] = { uptime = 0.1, min = 2 }, -- Mindgames
    [323705] = { uptime = 0.1, min = 2 }, -- Mindgames
    [323701] = { uptime = 0.1, min = 2 }, -- Mindgames
    [323707] = { uptime = 0.1, min = 2 }, -- Mindgames
    [375903] = { uptime = 0.1, min = 2 }, -- Mindgames
    [323706] = { uptime = 0.1, min = 2 }, -- Mindgames
    [375904] = { uptime = 0.1, min = 2 }, -- Mindgames
    [391112] = { uptime = 0.1, min = 2 }, -- Mindgames
    [323673] = { uptime = 0.1, min = 2 }, -- MindgamesOLD
    [187650] = { uptime = 0.25, min = 2 }, -- Freezing Trap
    [3355] = { uptime = 0.25, min = 2 }, -- Freezing Trap
    [853] = { uptime = 0.25, min = 2 }, -- Hammer of Justice
    [179057] = { uptime = 0.25, min = 2 }, -- dh choas nova
    [20066] = { uptime = 0.15, min = 2 }, -- Repentance
    [77787] = { uptime = 0.15, min = 2 }, -- Hammer of Justice
    ------------- Sheeeps
    [118] = { uptime = 0.25, min = 2 },
    [161355] = { uptime = 0.25, min = 2 },
    [161354] = { uptime = 0.25, min = 2 },
    [161353] = { uptime = 0.25, min = 2 },
    [126819] = { uptime = 0.25, min = 2 },
    [61780] = { uptime = 0.25, min = 2 },
    [161372] = { uptime = 0.25, min = 2 },
    [61721] = { uptime = 0.25, min = 2 },
    [61305] = { uptime = 0.25, min = 2 },
    [28272] = { uptime = 0.25, min = 2 },
    [28271] = { uptime = 0.25, min = 2 },
    [277792] = { uptime = 0.25, min = 2 },
    [277787] = { uptime = 0.25, min = 2 },
    [391622] = { uptime = 0.25, min = 2 },
    ---------------------
    [360806] = { uptime = 0.25, min = 2 }, --- sleep walk
    ------------Fears 
    [5782] = { uptime = 0.25, min = 2 },
    [65809] = { uptime = 0.25, min = 2 },
    [342914] = { uptime = 0.25, min = 2 },
    [251419] = { uptime = 0.25, min = 2 },
    [118699] = { uptime = 0.25, min = 2 },
    [30530] = { uptime = 0.25, min = 2 },
    [221424] = { uptime = 0.25, min = 2 },
    [41150] = { uptime = 0.25, min = 2 },
    ------------------------
    [82691] = { uptime = 0.25, min = 2 },        --- ring of frost
    [64044] = { uptime = 0.25, min = 2 },		 -- Psychic Horror (Stun)
    [105421] = { uptime = 0.25, min = 2 },		 -- Blinding Light
    [6358] = { uptime = 0.25, min = 2 },		 -- Seduction (Succubus)
    --------------- rooots 
    [339] = { uptime = 0.25, min = 2 },		 ----entangling roots
    [339] = { uptime = 0.25, min = 2 }, -- Entangling Roots
    [235963] = { uptime = 0.25, min = 2 }, -- Entangling Roots
    [102359] = { uptime = 0.25, min = 2 }, -- Mass Entanglement
    [117526] = { uptime = 0.25, min = 2 }, -- Binding Shot
    [122] = { uptime = 0.25, min = 2 }, -- Frost Nova 
    [33395] = { uptime = 0.25, min = 2 }, -- Freeze
    [64695] = { uptime = 0.25, min = 2 }, -- Earthgrab
}


purify:Callback("importants", function(spell)
    if spell.cd - blink.gcdRemains > 0 then return end

    blink.fullGroup.sort(function(x,y) return x.hp < y.hp end)

    blink.fullGroup.loop(function(member)
        
        if not member.isPlayer then return end
        if not member.los then return end
        if member.dist > 42 then return end
        if member.debuffFrom({45438, 642, 362486, 186265}) then return end

        local has = member.debuffFrom(DispelMePls)
        if not has then return end
      
        local str = ""
        for i, id in ipairs(has) do
          if i == #has then
            str = str .. C_Spell.GetSpellInfo(id).name 
          else
            str = str .. C_Spell.GetSpellInfo(id).name .. ","
          end
        end

        --UA CARE    
        if member.debuffFrom({30108,316099}) and player.hpa <= 75 then return end

        -- purify
        if blink.hasControl
        and member.debuffFrom(DispelMePls) 
        and member.los
        and spell:Cast(member, { face = true }) then
            --return alert("Purify (" .. member.classString .. ")", spell.id)
            return alert("Purify [" .. member.classString .. "] [" .. colors.red .. str .. "]", spell.id)
        end
    end)

end)


MD:Callback("immunes", function(spell)

    if spell.cd - blink.gcdRemains > 0 then return end
        
    blink.enemies.loop(function(enemy)

        local has = enemy.buffFrom({45438, 642})
        if not has then return end
    
        local str = ""
        for i, id in ipairs(has) do
            if i == #has then
                str = str .. C_Spell.GetSpellInfo(id).name
            else
                str = str .. C_Spell.GetSpellInfo(id).name .. ","
            end
        end

        --if not enemy.buffFrom({45438, 642}) then return end
        if has then
            if blink.hasControl then
                spell:SmartAoE(enemy, {
                    filter = UAfilter,
                    movePredTime = spell.castTime,-- / 2,
                    minDist = 0.3,
                    distanceSteps = 12, circleSteps = 24,
                    stopMoving = true,
                }) 
                alert("Mass Dispel [ " .. enemy.classString .. " ] [ " .. colors.red .. str .. " ]", spell.id)
            end
        end
    end)

end)

lifeswap:Callback("slider", function(spell)

    if player.lastcast == 33206 then return end

    if sr.LowestUnit 
    and not sr.LowestUnit.buffFrom(SwapOverLap) then

        if sr.LowestHealth > saved.VoidShift then return end

        if sr.LowestHealth <= saved.VoidShift then

            if player.casting or player.channeling then
                blink.call("SpellStopCasting")
                blink.call("SpellStopCasting")
            end

            if spell:Castable(sr.LowestUnit) then
                if spell:Cast(sr.LowestUnit) then 
                    alert("Void Shift " .. (sr.LowestUnit.name or "") .. "|cFFf74a4a [Low hp]", spell.id, true)
                end
            end
        end
    end

end)

PS:Callback(function(spell)

    if player.lastcast == 33206 then return end
    if barrier.current then return end
    if player.used(barrier.id, 2) then return end
    if player.used(lifeswap.id, 2) then return end

    if sr.LowestUnit 
    and not sr.LowestUnit.buffFrom(SwapOverLap) then

        if sr.LowestHealth > saved.PSHeal then return end

        if sr.LowestHealth <= saved.PSHeal then
            if spell:Cast(sr.LowestUnit,{ignoreStuns = true}) then 
                alert("Pain Suppression " .. (sr.LowestUnit.name or "") .. "|cFFf74a4a [Low hp]", spell.id)
            end
        end
    end
end)


------------------------------------STOPING START-------------------------------------------
local isNearFriend = function(totem)
    return blink.fullGroup.around(totem, 6, function(friend) 
      return true --totem.id == 61245 or friend.role == "melee" or friend.role == "healer"
    end) > 0
  end
  
local fearClasses = {"WARLOCK", "PRIEST", "WARRIOR"}
local importantTotems = {
    [5913] = fearClassOnTeam, -- Tremor
    [2630] = function(totem) return isNearFriend(totem) end, -- Earthbind
    [60561] = function(totem) return isNearFriend(totem) end, -- Earthgrab
    [61245] = function(totem) return isNearFriend(totem) end, --Capacitor 
    [179867] = function(totem) return isNearFriend(totem) end, --Static Field Totem 
    [59764] = function(totem, uptime) return uptime < 8 end,  --Healing Tide
}

-- hook stomp
hookCallbacks(function()
    for _, member in ipairs(blink.fgroup) do 
      fearClassOnTeam = fearClassOnTeam or tContains(fearClasses, member.class2)
    end
    importantTotems[5913] = fearClassOnTeam
end, {"stomp"})


local function stomp(callback)
    return blink.totems.stomp(function(totem, uptime)
        local id = totem.id
        local app = importantTotems[id]
        if not saved.autoStomp then return end
        if not totem.id or not saved.totems[totem.id] then return end
        if app == false then return false end
        if type(app) == "function" and not app(totem, uptime) then return false end
        if type(app) == "number" then 
        if uptime < app then return false end
            return callback(totem, uptime)
        else
        if uptime < stompDelay.now and not totem.casting then return false end
            return callback(totem, uptime)
        end
    end)
end

wicked:Callback("stomp", function(spell)
    if not saved.autoStomp then return end
    return stomp(function(totem)
        if not totem.id or not saved.totems[totem.id] then return end
        if player.distanceTo(totem) > 40 then return end
        if not totem.los then return end

        if spell:Cast(totem, { face = true }) then
            return alert("Stomp |cFF96f8ff" .. totem.name, spell.id)
        end
    end)
end)

local PurgeMePls = {
  360827, --Blistering Scales
  79206,  --Spiritwalker's Grace
  10060,  --Power Infusion
  80240,  --Havoc
  378464, --Nullifying Shroud
  383618, --Nullifying Shroud2
  1044,   --Blessing of Freedom2
  1022,   --Blessing of Protection
  210294, --divine-favor
  305497, --Thorns
  132158, --Druid Nature's Swiftness
  378081, --Shaman Nature's Swiftness
  342246, --Mage Alter time
  198111, --Mage Alter time
  11426,  --Mage barrier
  198094, --Mage barrier
  342242, --Mage Timewrap
  213610, --Holy Word

}

-- purges
purge:Callback(function(spell, unit)
    if spell.cd > 0.5 then return end

    blink.enemies.sort(function(x,y) return x.hp < y.hp end)

    blink.enemies.loop(function(enemy)

        if not enemy.isPlayer then return end
        if not enemy.los then return end
        if enemy.dist > 42 then return end
        if enemy.buffFrom({45438, 642, 362486, 186265}) then return end
        if not enemy.buffFrom(PurgeMePls) then return end

        -- purges
        if enemy.buffFrom(PurgeMePls) 
        and enemy.los
        and spell:Cast(enemy, { face = true }) then
            return alert("Dispel Magic (" .. enemy.classString .. ")", spell.id)
        end

        -- --Purge friend Healer
        -- if fhealer.exists 
        -- and fhealer.disorient
        -- and fhealer.los 
        -- and fhealer.debuff(605) then
        --     if spell:Cast(fhealer, { face = true }) then
        --         alert(colors.cyan .. "Purging MC from Friendly Healer (" .. fhealer.name .. ")", spell.id)
        --     end
        -- end

        --tranq dart
        -- if player.hasTalent(356015) then
        -- if target.buffFrom({45438, 642, 362486, 186265}) then return end
        -- if target.purgeCount > 1 then
        --     if spell:Cast(target, { alwaysFace = true }) then
        --     blink.alert("Tranq Darts (" .. target.class .. ")", spell.id)
        --     return true
        --     end
        -- end

        -- local bestUnit, bestCount = false, 0
        -- if enemy.buffFrom({45438, 642, 362486, 186265}) then return end
        -- local purgeCount = enemy.purgeCount
        -- if purgeCount > bestCount then
        --     bestUnit = enemy
        --     bestCount = purgeCount
        -- end
        -- if bestUnit then
        --     return spell:Cast(bestUnit, {face = true}) and alert("Tranq Darts (" .. bestUnit.class .. ")", spell.id)
        -- end
        
        -- end

    end)

end)

PI:Callback(function(spell, unit)
    blink.group.loop(function(member)
        if member.cds then 
            spell:CastAlert(member)
        end
    end)
end)


desperate:Callback("emergency", function(spell)

    local count, _, _, cds = player.v2attackers()
  
    local threshold = 17
    threshold = threshold + bin(player.hpa) * 6
    threshold = threshold + count * 9
    threshold = threshold + cds * 12

    if player.hpa > threshold then return end

    if player.hpa < threshold then
        return spell:Cast(player) and alert("Desperate Prayer " .. colors.red.."[Danger]", spell.id)
    end

end)



local dangerDebuffs = {
  [167105]  = { min = 4, weight = 13 },      -- warbreaker
  [386276]  = { min = 6.5, weight = 15 },    -- bonedust brew
  [274838]  = { min = 4, weight = 7 },       -- frenzy
  [274837]  = { min = 4, weight = 7 },       -- frenzy
  [363830]  = { min = 7.5, weight = 14 },    -- sickle
  [323673]  = { min = 3, weight = 7 },       -- games
  [375901]  = { min = 3, weight = 7 },       -- games
  --[385408]  = { min = 7, weight = 8 },       -- sepsis
  -- [324149] = { min = 5 },                 -- flayed shot
  [79140]   = { min = 7, weight = 18 },      -- vendetta FIXME: ID FOR DF
  [206491]  = { min = 30, weight = 10 },     -- nemesis..?
  [376079]  = { weight = 11 },               -- spear of bastion 
}

local dangerousCasts = {
  -- mindgames
  [323673] = { weight = 17 }, 
  [375901] = { weight = 17 }, 
  -- Glacial Spike
  [199786] = { 
    weight = 12, 
    mod = function(obj, dest) 
      return 1 + bin(obj.castPct > 75) * 3 
    end 
  },
  -- chaos bolt / dark soul bolt
  [116858] = { 
    weight = 12, 
    mod = function(obj, dest) 
      return 1 + bin(obj.buff(113858)) * 3 
    end 
  },
  -- convoke (feral and boomert)
  [323764] = {
    weight = 16,
    mod = function(obj)
      return 1 + obj.channelRemains * 0.33
    end,
    dest = function(obj)
      if obj.melee then
        if obj.target.exists and obj.target.distanceTo(obj) < 7 then 
          return obj.target 
        else
          local _, _, around = blink.fullGroup.around(obj, 7.5)
          for _, friend in ipairs(around) do
            if obj.facing(friend) then
              return friend
            end
          end
        end
      else
        return obj.target
      end
    end
  },
  -- deathbolt
  [264106] = {
    weight = 12,
    mod = function(obj)
      -- rapid contagion 33% increase, but they're probably tryna do big dam
      -- dark soul is just haste increase but they probably used phantom/darkglare/all dots for this deathbolt..
      return 1 + bin(obj.buff(344566)) * 0.66 + bin(obj.buff(113860)) * 0.88
    end
  },
  -- rapid fire
  [257044] = {
    weight = 8,
    mod = function(obj)
      -- double tap rapid fire full channel biggg scary
      return (1 + bin(obj.buff(260402)) * 2) / max(0.1, 2 - obj.channelRemains)
    end
  },
  -- aimed shot
  [19434] = {
    weight = 9,
    mod = function(obj)
      -- double tap aimed shot essentially 2x dmg.. buuut trading cds and crits are scary etc etc
      return 1 + bin(obj.buff(260402)) * 2
    end
  },
}

local function dangerousCastsScan()
  priest.currentDangerousCasts = {}
  for i=1,#blink.enemies do
    local enemy = blink.enemies[i]
    local cast = (enemy.castID or enemy.channelID)
    --if enemy.distance > 90 then return end
    if cast then
      local info = dangerousCasts[cast]
      if info then
        local type = enemy.castID and "cast" or "channel"
        if type ~= "cast" or enemy.castRemains <= blink.buffer then
          local mod = info.mod and info.mod(enemy) or 1
          local dest = info.dest and info.dest(enemy)
          local weight = info.weight * mod
          tinsert(priest.currentDangerousCasts, {
            source = enemy,
            dest = dest or enemy.castTarget,
            weight = weight
          })
        end
      end
    end
  end
end

function PS:threshold(unit, bypass)

  -- modifiers by units on the unit
  local total, _, _, cds = unit.v2attackers()

  -- the hunt flying
--   local theHuntWeight = 0
--   local huntEvent = events.huntCast
--   if huntEvent then
--     local event = huntEvent
--     local source, dest, happened = event.source, event.dest, event.time
--     local time = blink.time
--     if time - happened <= 2.25
--     and source.exists 
--     and source.speed > 45
--     and dest.isUnit(unit)
--     and source.distanceTo(dest) > 8 then
--       theHuntWeight = theHuntWeight + 50
--     end
--   end

  -- debuffs that mean big dam' be comin'
  local debuffWeights = 0
  local hasDebuffs = unit.debuffFrom(dangerDebuffs)
  if hasDebuffs then 
    for _, id in ipairs(hasDebuffs) do 
      debuffWeights = debuffWeights + dangerDebuffs[id].weight 
    end 
  end

  -- dangerous casts or channels currently happening
  local dangerousCastsWeight = 0
  for _, cast in ipairs(priest.currentDangerousCasts) do 
    if cast.dest.isUnit(unit) then
      dangerousCastsWeight = dangerousCastsWeight + cast.weight
    end
  end

  -- bit 'o weight for them committing a stun to their target
  local stunWeight = unit.stunned and 10 or 0

  local threshold = 28 + debuffWeights / 2 + dangerousCastsWeight

  threshold = threshold + total * (10 + debuffWeights / 2.5 + stunWeight / 2 + dangerousCastsWeight / 2.5)
  threshold = threshold + cds * (17 + debuffWeights + stunWeight + dangerousCastsWeight / 2)

  -- slight multiplicative mod for no heals, mitigation more important
  threshold = threshold * 1 + bin(not player.exists or player.ccr > 2) * 0.1

  return threshold

end
  
PS:Callback("smart", function(spell)

    if not saved.AutoSmartPS then return end

    blink.fgroup.sort(function(x,y) return x.hp < y.hp end)

    blink.fgroup.loop(function(member)

        if barrier.current then return end
        if player.used(barrier.id, 2) then return end
        if player.used(PS.id, 2) then return end
        if player.used(lifeswap.id, 2) then return end
        if member.dist > 40 then return end
        if not member.los then return end
        if member.buffFrom(SwapOverLap) then return end
        if member.immuneHealing then return end
        if member.buff(33206) then return end
        if member.buff(81782) then return end
        if player.lastcast == 108968 then return end

        local count, _, _, cds = member.v2attackers()
        
        local threshold = 17 --increase to be r5ee9
        threshold = threshold + bin(member.stunned) * 5
        threshold = threshold + count * 9
        threshold = threshold + cds * 11
        
        threshold = threshold * (1 + bin(player.stunned and player.stunRemains > 2.5) * 0.8 + bin(member.stunned) * 0.35)
        --threshold = threshold * saved.regenSensitivity
        
        if member.hp > threshold then return end

        if member.hp <= threshold then
            return spell:Cast(member) and alert("Pain Suppression " .. member.classString, spell.id, true)
        end

    end)

end)


barrier:Callback("smart", function(spell)

    if not saved.AutoSmartBarrier then return end

    blink.fgroup.sort(function(x,y) return x.hp < y.hp end)

    blink.fgroup.loop(function(member)

        if player.stunned then return end
        if barrier.current then return end
        if player.used(PS.id, 2) then return end
        if player.used(lifeswap.id, 2) then return end
        if member.dist > 40 then return end
        if not member.los then return end
        if member.buffFrom(SwapOverLap) then return end
        if member.immuneHealing then return end
        if member.buff(33206) then return end
        if member.buff(81782) then return end
        if player.lastcast == 108968 then return end

        local x,y,z = gz(member.position())

        local count, _, _, cds = member.v2attackers()
        
        local threshold = 20 --increase to be r5ee9
        threshold = threshold + bin(member.stunned) * 5
        threshold = threshold + count * 9
        threshold = threshold + cds * 15
        
        --threshold = threshold * (1 + bin(player.stunned and player.stunRemains > 2.5) * 0.8 + bin(member.stunned) * 0.35)
        --threshold = threshold * saved.regenSensitivity
        
        if member.hp > threshold then return end

        if player.casting or player.channeling then
            blink.call("SpellStopCasting")
            blink.call("SpellStopCasting")
        end
        
        if member.hp <= threshold then
            return spell:Cast(member) and alert("Power Word: Barrier " .. member.classString, spell.id, true)
        end


    end)

end)


archangel:Callback(function(spell)
    if player.buff(47536) then
        spell:CastAlert(player)
    end
end)

feather:Callback(function(spell)

    if player.buff(121557) then return end

    if player.moving and player.combat then
        spell:AoECast(player)
    end
end)

feather:Callback("cc", function(spell)
    
    if player.buff(121557) then return end

    if enemyhealer.cc then
        spell:AoECast(player)
    end

end)    

local BigDamageBuffs =
{
  --Incarnation Ashame - Feral
  [102543] = function(source)
    return source.role == "melee"
  end,
  --Incarnation Chosen - Boomkin
  [102543] = function(source)
    return source.role == "ranged"
  end,
  --wings
  [31884] = function(source)
    return source.role == "melee"
  end,
  --wings
  [231895] = function(source)
    return source.role == "melee"
  end,
  --doomwinds
  [384352] = function(source)
    return source.class2 == "SHAMAN" and source.role == "melee"
  end,
  --Serenity
  [152173] = function(source)
    return source.role == "melee"
  end,
  --boondust
  [386276] = function(source)
    return source.role == "melee"
  end,
  --trueshot
  [288613] = function(source)
    return true
  end,
  --Coordinated Assault
  [266779] = function(source)
    return true
  end,
  --Coordinated Assault2
  [360952] = function(source)
    return true
  end,
  --Shadow Dance
  [185422] = function(source)
    return true
  end,
  --Shadow Blades
  [121471] = function(source)
    return true
  end,  
  --Adrenaline Rush
  [13750] = function(source)
    return true
  end,  
  --Combustion
  [190319] = function(source)
    return true
  end,  
  --Pillar of Frost
  [51271] = function(source)
    return true
  end,
  --Unholy Assault
  [207289] = function(source)
    return true
  end,
  --Metamorphosis
  [162264] = function(source)
    return true
  end,
  --Recklessness
  [1719] = function(source)
    return true
  end,
  --Avatar
  [107574] = function(source)
    return true
  end,
  --warbreaker
  [167105] = function(source)
    return true
  end,

} 

darkangel:Callback("burst", function(spell)

    if not spell.known then return end
    if not player.combat then return end

    blink.fullgroup.loop(function(member)

        if member.buffFrom(BigDamageBuffs) 
        and player.combat then
            spell:CastAlert()
        end
    
    end)
end)


smite:Callback("dmg", function(spell)
    --if sr.WasCasting[target.guid] then return end
    if player.lastcast == 585 then return end
    if not target.enemy then return end
    if not player.buffFrom({390706, 390705}) then return end
    if not spell.inRange(target) then return end
    if not target.los then return end
    
    return spell:Cast(target)

end)