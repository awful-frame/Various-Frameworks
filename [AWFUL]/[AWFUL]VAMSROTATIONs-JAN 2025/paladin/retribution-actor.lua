local Unlocker, awful, vamsrotation = ...
local retribution = vamsrotation.paladin.retribution
local target, healer, enemyHealer, player, group, friend = awful.target, awful.healer, awful.enemyHealer, awful.player, awful.group, awful.friend

-- Check if the player's spec is Retribution (spec ID 3)
if player.spec ~= "Retribution" or player.class ~= "Paladin" then
    return
end

local settings = vamsrotation.settings
local trinket = awful.Item({218716, 218422, 219931})

-- stuff out here only runs once, when the file is first loaded.
print("Vams retri load success!")
print("Type /retri to toggle UI")

-- enable routine
awful.enabled = true
awful.AntiAFK.enabled = true

-- this is the routine actor.
retribution:Init(function()


    -- Functions
    vamsrotation:SetLowestEnemy()
    vamsrotation.WasCastingCheck()
    vamsrotation.CheckEnemyHealerLockout()
    vamsrotation.CheckFriendlyHealerLockout()
    vamsrotation.soulwell()
    vamsrotation.healthstone()
    if vamsrotation.settings.autoFocus then
        awful.AutoFocus()
    end


    -- Auras
    devotionAura()

    --auto attack
    vamsrotation.Attack()
    handOfReckoning("cc")
    
    -- trinket lay stuff 
    willToSurvive("trinket")
    layOnHands("trinket")

-- emergency defensives
    layOnHands("emergency")
    divineShield("emergency")

    -- Personal Defensives
    divineProtection()
    blessingOfProtection()
    blessingOfSpellwarding()
    shieldOfVengeance()
    divineShield()

    -- Friend Defensives
    blessingOfProtection("cc")
    blessingOfProtection("feral")
    blessingOfSacrifice()

    layOnHands()
     
    -- freehorse
    if awful.MacrosQueued["freehorse"] then
        vamsrotation.blessDivineSteed()
    end
    --top priority (utility)
    rebuke("channels")
    rebuke("cc")
    rebuke("heals")
    rebuke("damage")
    blessingOfSanctuary("scared")
    blessingOfSanctuary()
    blessingOfSanctuary("intim")
    blessingOfSanctuary("binding")
    blessingOfSanctuary("sanc_friends_if_no_healer")
    blessingOfSanctuary("healer_debuff")

    -- heals
    eternalFlame("emergency")
    wordOfGlory("emergency")
    eternalFlame("offheal")
    wordOfGlory("offheal")

    -- cc
    hammerOfJustice("crossCC")
    hammerOfJustice("healer")
    hammerOfJustice("trap")
    blindingLight()

    --stomps
    vamsrotation.StompTotems()

    
    if target.player or target.id == 219250 or target.id == 153292 then
        if target.enemy then
            if vamsrotation.settings.autoBurst or awful.burst then
                finalReckoning("burst")
                vamsrotation.hammerOfLightWorkaround()
                wakeOfAshes("burst")
                divineToll("burst")
                finalVerdict("burst")
            end
        end
    end

    -- -- utility
    blessingOfFreedom("player")
    blessingOfFreedom("friend")


    -- damage
    finalVerdict("dump")
    hammerOfWrath("proc")
    judgement()
    hammerOfWrath()
    bladeOfJustice()
    finalVerdict()
end, 0.15)
