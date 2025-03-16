local Unlocker, awful, vamsrotation = ...
local retribution = vamsrotation.paladin.retribution
local Spell = awful.Spell
local target, healer, enemyHealer, player, group, friend = awful.target, awful.healer, awful.enemyHealer, awful.player, awful.group, awful.friend
local hammerOfLightId = 427453
local onUpdate, onEvent, hookCallbacks, hookCasts, Spell, Item = awful.addUpdateCallback, awful.addEventCallback, awful.hookSpellCallbacks, awful.hookSpellCasts, awful.NewSpell, awful.NewItem

-- Check if the player's spec is Retribution (spec ID 3)
if player.spec ~= "Retribution" or player.class ~= "Paladin" then
    return
end

local settings = vamsrotation.settings
local healthstone = awful.Item(5512)

local bubbleAdjustment = awful.delay(-2.5, 2.5) -- (+/- 2.5%) BUBBLE
local healthstoneAdjustment = awful.delay(-3.5, 3.5) -- Ensure this returns a number
local layOnHandsAdjustment = awful.delay(-5, 5) -- (+/- 5%) LAY ON HANDS
local interruptDelay = awful.delay(0.2, 0.75)
local channelDelay = awful.delay(0.1, 0.3)
local spellDelay = awful.delay(0.15, 0.35)
local tauntDelay = awful.delay(0.4, 0.6)

local badge = awful.Item({218421, 218713})


awful.Populate({
    finalVerdict = Spell(383328, { damage= "physical" }), -- <-- don't forget the comma here when you add more spells, this is a table!
    hammerOfWrath = Spell(24275, { damage= "physical" }),
    judgement = Spell(20271, { damage = "physical" }),
    bladeOfJustice = Spell(184575, { damage= "magic" }),
    blessingOfFreedom = Spell(1044, { beneficial = true }),
    divineSteed = Spell(190784),
    blessingOfProtection = Spell(1022, { beneficial = true }),
    divineToll = Spell(375576, { damage = "physical" }),
    layOnHands = Spell(633, { heal = true, ignoreGCD = true }),
    blessingOfSacrifice = Spell(6940, { beneficial = true }),
    flashOfLight = Spell(19750, { heal = true }),
    rebuke = Spell(96231, { targeted = true, damage = "physical", ignoreMoving = true, ignoreGCD = true}),
    blindingLight = Spell(115750, { cc = "fear", targeted = false, ignoreFacing = true }),
    hammerOfJustice = Spell(853, { cc = "stun", ignoreFacing = true }),
    handOfReckoning = Spell(62124),
    divineShield = Spell(642, { beneficial = true, ignoreControl = true }),
    wordOfGlory = Spell(85673, { heal = true }),
    eternalFlame = Spell(156322, { heal = true }),
    shieldOfVengeance = Spell(184662, { beneficial = true }),
    blessingOfSanctuary = Spell(210256, { beneficial = true, ignoreFacing = true }),
    finalReckoning = Spell(343721, { damage = "physical", targeted = false }),
    wakeOfAshes = Spell(255937, { damage = "physical", targeted = false, radius = 13 }),
    divineProtection = Spell(403876, { beneficial = true, ignoreControl = true }),
    blessingOfSpellwarding = Spell(204018, { beneficial = true }),
    searingGlare = Spell(410126, { cc = true, radius = 25 }),
    devotionAura = Spell(465, { beneficial = true }),
    hammerOfLight = Spell(427453, { targeted = true, damage = "magic" }),  --/dump C_Spell.IsSpellInRange(427453) 429826
    willToSurvive = Spell(59752, { beneficial = true, ignoreStuns = true, ignoreGCD = true, targeted = false }),

    
}, retribution, getfenv(1))
-- ^^^ make sure you replace "arms" here with your specialization's routine actor!


local attack = awful.NewSpell(6603)

function attack:start() return not self.current and attack:Cast() end

function attack:stop() return self.current and awful.call("StopAttack") end

function vamsrotation.Attack()
  -- handle auto attacking
  if not player.combat then return end
  if player.mounted then return end
  if target.exists and target.enemy then
    if target.bcc then
      attack:stop()
    else
      attack:start()
    end
  end
end

vamsrotation.WasCasting = { }
function vamsrotation.WasCastingCheck()
    local time = awful.time
    if player.casting then
        vamsrotation.WasCasting[player.castingid] = time
    end
    for spell, when in pairs(vamsrotation.WasCasting) do
        if time - when > 0.100+awful.latency then
            vamsrotation.WasCasting[spell] = nil
        end
    end
end

local healerLocked = false

local healerLockouts = {
    ["DRUID"] = "nature",
    ["PRIEST"] = "holy",
    ["PALADIN"] = "holy",
    ["SHAMAN"] = "nature",
    ["MONK"] = "nature",
    ["EVOKER"] = "nature"
}

function vamsrotation.CheckEnemyHealerLockout()
    if not player.combat then return end
    if not awful.arena then return end
    if not enemyHealer.exists then return end

    local lockoutSchool = healerLockouts[enemyHealer.class2]
    if lockoutSchool then
        local lockoutInfo = enemyHealer.lockouts[lockoutSchool]
        if lockoutInfo then
            enemyHealer.locked = lockoutInfo.remains
        else
            enemyHealer.locked = 0
        end
    else
        enemyHealer.locked = 0
    end
end

function vamsrotation.CheckFriendlyHealerLockout()
    if not player.combat then return end
    if not awful.arena then return end
    if not healer.exists then return end

    local primarySchool = healerLockouts[healer.class2]
    if primarySchool then
        local lockoutInfo = healer.lockouts[primarySchool]
        if lockoutInfo then
            healer.locked = lockoutInfo.remains
        else
            healer.locked = 0
        end
    else
        healer.locked = 0
    end
end

local friendlyPriestUsed = 0
onEvent(function(info, event, source, dest)
    if not player.combat then return end
    if event ~= "SPELL_CAST_SUCCESS" then return end
    if not source.friendly then return end
    if not source.isUnit(healer) then return end

    local spellID, spellName = select(12, unpack(info))
    if (spellID == 32379 or spellName == "Shadow Word: Death") then
        friendlyPriestUsed = awful.time
        return
    end
end)

-- interact with soulwell
function vamsrotation.soulwell()
    if not awful.prep then return end
    if player.mounted then return end
    if player.combat then return end
    if GetItemCount(5512) ~= 0 then return end

    if not player.combat then
        awful.objects.loop(function(obj)
            if obj.name == "Soulwell" and player.distanceTo(obj) < 3 then
            return obj:interact() and awful.alert("Picked up Healthstone!", 5512)
            end
        end)
    end
end

function vamsrotation.healthstone()
    local adjustedHealthstoneHP = settings.healthstoneHP + healthstoneAdjustment.now
    if not awful.hasControl then return end
    if not player.combat then return end
    if healthstone.count == 0 then return end
    if healthstone.cd > 0 then return end
    if not healthstone.usable then return end
    if player.hp <= adjustedHealthstoneHP then
        return healthstone:Use() and awful.alert("Used Healthstone!", healthstone.id)
    end
end

devotionAura:Callback(function(spell)
    if not awful.prep then return end
    if not player.buff(465) and not player.buff(317920) then
        spell:Cast()
    end
end)
-- C_Spell.IsCurrentSpell(427453)
function vamsrotation.hammerOfLightWorkaround()
    if not player.combat then return end
    if player.mounted then return end

    if player.debuff(410201) then return end -- searing glare
    if not target.enemy then return end
    if not target.exists then return end

    if C_Spell.IsCurrentSpell(hammerOfLightId) then return end
    if not C_Spell.IsSpellUsable(hammerOfLightId) then return end
    if not C_Spell.IsSpellInRange(hammerOfLightId, "target") then return end
    CastSpellByID(FindBaseSpellByID(hammerOfLightId), "target")
end

finalVerdict:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if IsSpellOverlayed(427453) then return end -- hold for hammer of light
    -- if C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and finalVerdict.cd > 0 then return end
    if not target.enemy then return end
    if not target.exists then return end
    if player.buff(454373) and C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and player.holypower < 5 then return end
    if player.holypower >=3 and player.holypower <5 then
        spell:Cast(target)
    end
end)

finalVerdict:Callback("dump", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if IsSpellOverlayed(427453) then return end -- hold for hammer of light
    -- if C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and finalVerdict.cd > 0 then return end
    if not target.enemy then return end
    if not target.exists then return end
    if player.buff(454373) and C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and player.holypower < 5 then return end
    if player.holypower == 5 or player.buff(408458) then
        spell:Cast(target)
    end
end)

finalVerdict:Callback("burst", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if IsSpellOverlayed(427453) then return end -- hold for hammer of light
    -- if C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and finalVerdict.cd > 0 then return end
    if not target.enemy then return end
    if not target.exists then return end
    if player.buff(454373) and C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and player.holypower < 5 then return end
    if player.buff(454373) and player.holypower >= 3 then
        spell:Cast(target)
    end
end)

hammerOfWrath:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if not target.enemy then return end
    if not target.exists then return end

    if target.hp < 20 then
        if player.holypower <= 3 then
            spell:Cast(target)
        end
    else
        if player.holypower <= 4 then
            spell:Cast(target)
        end
    end
end)

hammerOfWrath:Callback("proc", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if not player.buff(445206) or target.hp <= 35 then return end -- proc
    if not target.enemy then return end
    if not target.exists then return end

    if target.hp < 20 then
        if player.holypower <= 3 then
            spell:Cast(target)
        end
    else
        if player.holypower <= 4 then
            spell:Cast(target)
        end
    end
end)

judgement:Callback(function(spell)
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if not target.enemy then return end
    if not target.exists then return end
    if player.holypower <= 3 then
        spell:Cast(target)
    end
end)

bladeOfJustice:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if not target.enemy then return end
    if not target.exists then return end
    if player.holypower <= 4 then
        spell:Cast(target)
    end
end)

finalReckoning:Callback("burst", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if not target.enemy then return end
    if not target.exists then return end
    if not player.recentlyCast(255937, 8) then return end
    if player.holypower >= 3 then
        badge:Use()
        spell:AoECast(target)
    end
end)

wakeOfAshes:Callback("burst", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if not target.exists then return end
    if not target.enemy and not target.player then return end
    if finalReckoning.cd <= 15 and not finalReckoning.cd == 0 then return end
    if player.holypower <= 2 then
        spell:Cast(target)
    end
end)

divineToll:Callback("burst", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if not target.exists then return end
    if not target.enemy and not target.player then return end
    if not player.recentlyCast(343721, 15) then return end
    if player.holypower <= 3 then
        spell:Cast(target)
    end
end)

rebuke:Callback("heals", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not settings.autoInterrupt then return end
    if not target.enemy then return end
    if vamsrotation.lowestCunt >= 65 then return end
    if settings.onlyInterruptCC then return end
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if not spell:Castable(enemy) then return end
        if enemy.role ~= "healer" then return end  -- Ensure the enemy is a healer
        if not enemy.los then return end
        if enemy.castPct < ((interruptDelay.now - awful.buffer) * 100) then return end
        if enemy.buff(421453) or enemy.buff(215769) then return end
        for _, spellId in ipairs(vamsrotation.interruptHeal) do
            if enemy.castingId == spellId and enemy.castRemains <= (awful.buffer + 0.08)then
                spell:Cast(enemy)
                break
            end
        end
    end)
end)

rebuke:Callback("cc", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not settings.autoInterrupt then return end
    if not target.enemy then return end

    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if not spell:Castable(enemy) then return end
        if player.casting and enemy.castRemains > player.castRemains then return end
        if enemy.castPct < ((interruptDelay.now - awful.buffer) * 100) then return end
        if enemy.castTarget.friend and (enemy.castTarget.buff(8178) or enemy.castTarget.buff(212295) or enemy.castTarget.buff(23920)) then return end -- ground totem, nether ward, spell reflection

        for _, spellId in ipairs(vamsrotation.interruptCC) do
            if enemy.castingId == spellId and enemy.castRemains <= (awful.buffer + 0.08)then
                spell:Cast(enemy)
                break
            end
        end
    end)
end)

rebuke:Callback("damage", function(spell)
    if player.mounted then return end
    if not player.combat then return end
    if not settings.autoInterrupt then return end
    if not target.enemy then return end
    if settings.onlyInterruptCC then return end
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if not spell:Castable(enemy) then return end
        if player.casting and enemy.castRemains > player.castRemains then return end
        if enemy.castPct < ((interruptDelay.now - awful.buffer) * 100) then return end
        if enemy.castTarget.friend and (enemy.castTarget.buff(8178) or enemy.castTarget.buff(212295) or enemy.castTarget.buff(23920)) then return end -- ground totem, nether ward, spell reflection
        for _, spellId in ipairs(vamsrotation.interruptDamage) do
            if enemy.castingId == spellId and enemy.castRemains <= (awful.buffer + 0.08)then
                spell:Cast(enemy)
                break
            end
        end
    end)
end)

rebuke:Callback("channels", function(spell)
    if player.mounted then return end
    if not player.combat then return end
    if not settings.autoInterrupt then return end
    if not target.enemy then return end
    if settings.onlyInterruptCC then return end
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if not spell:Castable(enemy) then return end
        if enemy.channeling then -- Check if the enemy is channeling

            local channelTime = enemy.channeling4 / 1000
            if (channelTime + 0.2 + channelDelay.now) > awful.time then return end
            if vamsrotation.interruptChannel[enemy.channelID] then
                return spell:Cast(enemy)
            end
        end
    end)
end)


hammerOfJustice:Callback("healer", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if settings.stunMode == "off" then return end
    if settings.stunMode == "trap" then return end
    if not (settings.stunMode == "healer" or settings.stunMode == "auto") then return end
    if player.debuff(410201) then return end -- searing glare
    if not enemyHealer.exists and not enemyHealer.los then return end
    if enemyHealer.buff(8178) or enemyHealer.buff(408558) then return end -- check grounding totem + phase shift
    if enemyHealer.immune or enemyHealer.immuneMagic then return end
    if enemyHealer.buff(212295) then return end -- check nether ward
    if enemyHealer.buff(23920) then return end -- check spell reflection
    if enemyHealer.buff(378464) then return end -- check shroud
    if not spell:Castable(enemyHealer) then return end
    if settings.holdCCOnHealerLock and enemyHealer.locked > 1 then return end -- check settings for locked
    if enemyHealer.ccRemains <= 0.6 and enemyHealer.stunDR == 1 then
        spell:Cast(enemyHealer)
    end
end)

hammerOfJustice:Callback("crossCC", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if settings.stunMode == "off" then return end
    if settings.stunMode == "trap" then return end
    if not (settings.stunMode == "damage" or settings.stunMode == "auto") then return end

    -- Ensure target is not immune.
    if player.debuff(410201) then return end -- Searing Glare
    if target.buff(8178) or target.buff(408558) then return end -- Grounding Totem + Phase Shift
    if target.immune or target.immuneMagic then return end
    if target.buff(212295) then return end -- check nether ward
    if target.buff(23920) then return end -- check spell reflection
    if target.buff(378464) then return end -- check shroud

    -- Ensure the target is a valid player
    if not target.exists or not target.enemy or not target.player or not target.los then return end
    if not target.stunDR == 1 then return end

    -- Condition 1: No healer exists
    local condition1 = not enemyHealer.exists

    -- Condition 2: Enemy healer is on stun DR for more than 10 seconds and in CC for 3 seconds or more
    local condition2 = enemyHealer.exists and enemyHealer.stunDR < 1 and enemyHealer.sdrr >= 8 and enemyHealer.ccr >= 1.5

    -- Condition 3: Enemy healer is more than 20 yards away and in CC for 3 seconds or more
    local condition3 = enemyHealer.exists and (enemyHealer.ccRemains >= 2 or enemyHealer.locked >= 3)

    if condition1 or condition2 or condition3 then
        if target.stunDR == 1 and target.ccRemains <= 0.5 then
            if spell:Castable(target) then
                if spell:Cast(target) then  
                    return awful.alert("Cross-CC Hammer of Justice on " .. target.name, spell.id)
                end
            end
        end
    end
end)

hammerOfJustice:Callback("trap", function(spell)
    if settings.stunMode == "off" then return end
    if not (settings.stunMode == "auto" or settings.stunMode == "trap") then return end
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    if target.buff(8178) or target.buff(408558) then return end -- check grounding totem + phase shift
    if target.immune or target.immuneMagic then return end
    if not target.stunDR == 1 then return end
    if target.buff(212295) then return end -- check nether ward
    if target.buff(23920) then return end -- check spell reflection
    if target.buff(378464) then return end -- check shroud
    if not target.enemy and not target.player then return end
    if not target.exists then return end
    if not enemyHealer.debuff(203337) then return end -- need to add normal trap debuff id
    spell:Cast(target)
end)

-- Function: blessingOfFreedom:Callback("root")
blessingOfFreedom:Callback("player", function(spell)
    -- Preliminary Checks
    if not player.combat then return end
    if player.mounted then return end
    if not player.rooted then return end
    if player.rootRemains < 2 then return end
    if target.distance < 8 then return end
    if player.debuffUptime(player.rooted) < spellDelay.now then return end

    -- hold for root beams
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.class2 == "DRUID" and enemy.spec == "Balance" and enemy.cooldown(78675) <= 25 then return end
    end)

    local validTarget = nil

    -- Iterate through group members to find the first valid target
    group.loop(function(friend)
        if vamsrotation.evaluateFreedomTarget(friend) then
            validTarget = friend
            return true -- Exit the loop early since a valid target has been found
        end
    end)

    -- Cast the spell on the valid target if found; otherwise, cast on the player
    if validTarget then
        if spell:Cast(validTarget) then
            awful.alert("Casting Blessing of Freedom on " .. validTarget.name .. " for ourselves!", spell.id)
        end
    else
        if spell:Cast(player) then
            awful.alert("Nobody in LoS, casting Blessing of Freedom on Self", spell.id)
        end
    end
end)

blessingOfFreedom:Callback("healer_debuff", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not healer.exists then return end
    if not spell:Castable(healer) then return end

    -- Check if the healer has the Solar Beam debuff
    if healer.debuff(81261) and healer.rooted then
        if spell:Cast(healer) then
            awful.alert("Casting Blessing of Freedom on Healer due to Solar Beam", 81261)
        end
    end
end)


blessingOfFreedom:Callback("friend", function(spell)
    if not player.combat then return end
    if player.mounted then return end

    -- hold for root beams
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.class2 == "DRUID" and enemy.spec == "Balance" and enemy.cooldown(78675) <= 25 then return end
    end)

    group.loop(function(friend)
        if not friend.exists then return end
        if not friend.los then return end
        if friend.rootRemains <= 2 then return end
        if friend.debuff(friend.rooted) and friend.debuffUptime(friend.rooted) >= spellDelay.now then
            -- Ensure the friend isn't crowd-controlled by something other than a root
            if not friend.cc then
                spell:Cast(friend)
            end
        end
    end)
end)

local trinket = awful.Item({218716, 218422, 219931})

divineShield:Callback(function(spell)
    local threshold = 20 -- Adjusted base threshold for slider value of 1 to match current 0.7
    if not player.combat then return end
    if player.mounted then return end

    if blessingOfSpellwarding:Castable(player) then return end
    if blessingOfProtection:Castable(player) then return end

    if vamsrotation.isLayOnHandsCooldownAvailable() and not player.cc then return end

    if settings.autoTrinketLayOnHands then
        if vamsrotation.isLayOnHandsCooldownAvailable() and (willToSurvive.cd <= 0.5 and player.stun) then return end
    end

    if player.recentlyCast(471195, 0.5) then return end -- check for recent cast Lay on Hands
    if player.lastCast == 471195 then return end -- check for last cast Lay on Hands
    
    if player.recentlyCast(633, 0.8) then return end -- lay recently cast
    if player.lastCast == 633 then return end -- lay last cast

    if healer.exists and (player.cooldown(210256) < 0.1) and (healer.debuffFrom(vamsrotation.scaredsancme) or healer.debuffFrom(vamsrotation.sancme)) and blessingOfSanctuary:Castable(healer) then return end

    if player.buffFrom(vamsrotation.dontdefensive) then return end

    if vamsrotation.isHealerInBigHealBuff() then return end -- check for big heal buffs

    -- Increment the threshold based on certain conditions
    threshold = threshold + bin(player.stun) * 3  -- Adds 5 to the threshold if the player is stunned (bin() likely converts boolean to integer)
    local count, _, _, cds = player.v2attackers()  -- Extracts certain values from the player's attack information
    threshold = threshold + count * 1.5  -- Adds 1.5 times the 'count' value to the threshold
    threshold = threshold + cds * 1.5   -- Adds 1.5 times the 'cds' value to the threshold

    -- Modifies the threshold further based on additional conditions using a binary function 'bin()'
    local healerModifier = bin(not healer.exists or (healer.cc and healer.ccr > 2.5)) * 0.15
    local stunModifier = bin(player.stun and player.stunRemains >= 2) * 0.15
    threshold = threshold * (1 + healerModifier + stunModifier)  -- Ensure the total multiplier does not exceed 1.3
    threshold = threshold * settings.bubbleSens  -- Multiplies the threshold by setting

    if player.hpa <= threshold then
        spell:Cast()
        print(threshold, "HPA(health+absorbs) bubble %, use this to change bubble sens.")
    end
end)

layOnHands:Callback("trinket", function(spell)
if not settings.autoTrinketLayOnHands then return end
if not player.combat then return end
if player.mounted then return end
if not vamsrotation.isLayOnHandsCooldownAvailable() then return end

if not willToSurvive.recentlyUsed(1) then return end

if player.hp <= 30 then
    spell:Cast()
    end    
end)

willToSurvive:Callback("trinket", function(spell)
    if not settings.autoTrinketLayOnHands then return end
    if not player.combat then return end
    if player.mounted then return end

    if not spell:Castable() then return end

    if not vamsrotation.isLayOnHandsCooldownAvailable() then return end

    if settings.trustPriestSwap then
        if healer.exists and healer.class2 == "PRIEST" and not healer.cc and healer.cooldown(108968) < 0.5 and 
           not healer.lockouts.shadow then
            -- Healer can cast Void Shift
            return
        end
    end

    if player.hp <= 25 and player.stun then
        spell:Cast()
    end
end)
  
divineShield:Callback("emergency", function(spell)
    if not player.combat then return end
    if player.recentlyCast(471195, 0.5) then return end -- check for recent cast Lay on Hands
    if player.lastCast == 471195 then return end -- check for last cast Lay on Hands

    if player.recentlyCast(633, 0.5) then return end -- check for recent cast Lay on Hands
    if player.lastCast == 633 then return end -- check for last cast Lay on Hands

    if vamsrotation.isLayOnHandsCooldownAvailable() and not player.cc then return end

    if settings.autoTrinketLayOnHands then
        if vamsrotation.isLayOnHandsCooldownAvailable() and (willToSurvive.cd <= 0.5 and player.stun) then return end
    end

    if not spell:Castable() then return end

    local total, melee, ranged, cooldowns = player.v2attackers()
    
    if healer.exists and (healer.cc or healer.locked > 0) then
        if player.hpa <= 20 and total >= 1 then
            spell:Cast()
        end
    elseif player.hpa <= 15 and total >= 1 then
        spell:Cast()
    end
end)

divineProtection:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.buff(184662) then return end -- check for shield of vengeance

    local total, melee, ranged, cooldowns = player.v2attackers()

    if player.hpa <= 65 and total >= 1 then
        spell:Cast()
    elseif player.hpa <= 80 and total >= 1 and cooldowns >= 1 then
        spell:Cast()
    elseif player.hpa <= 95 and total >= 1 and cooldowns >= 1 and (healer.exists and healer.ccRemains >= 2) then
        spell:Cast()
    end
end)

shieldOfVengeance:Callback(function(spell)

    if not player.combat then return end
    if player.mounted then return end

    local total, melee, ranged, cooldowns = player.v2attackers()

    if player.hpa <= 50 and total >= 1 then
        spell:Cast()
    elseif player.hpa <= 70 and total >= 1 and cooldowns >= 1 and not player.buff(403876) then -- check for divine protection
        spell:Cast()
    elseif player.hpa <= 90 and total >= 1 and cooldowns >= 1 and (healer.exists and healer.ccRemains >= 2) and not player.buff(403876) then -- check for divine protection
        spell:Cast()
    end

end)

blessingOfSacrifice:Callback(function(spell)

    if not player.combat then return end
    if player.mounted then return end

    group.loop(function(friend)

        if not friend.exists or not spell:Castable(friend) then return end

        local total, melee, ranged, cooldowns = friend.v2attackers()

        -- Prioritize lower HP threshold to prevent multiple casts
        if total >= 1 and friend.hp <= 35 then
            spell:Cast(friend)
        elseif total >= 1 and cooldowns >= 1 and friend.hp <= 80 then
            spell:Cast(friend)
        elseif total >= 2 and cooldowns >= 1 and healer.ccRemains >= 2 and friend.hp <= 95 then
            spell:Cast(friend)
        end

    end)
end)

blessingOfSpellwarding:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    fgroup.loop(function(friend)
        if not friend.exists then return end
        --check for forbearance
        if vamsrotation.isLayOnHandsCooldownAvailable() and not player.cc then return end
        -- if layOnHands:Castable(friend) then return end
        -- Ensure the friend exists and is castable
        if not spell:Castable(friend) then return end
        -- Check if the friend has a defensive buff
        if friend.buffFrom(vamsrotation.dontdefensive) then return end
        -- Check if the healer is in a big heal 
        if vamsrotation.isHealerInBigHealBuff() then return end -- check for big heal buffs
        -- check friend attackers
        local total, melee, ranged, cooldowns = friend.v2attackers()

        if friend.hp <= 30 and total >= 1 then
            spell:Cast(friend)
        elseif friend.hp <= 40 and total >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        elseif friend.hp <= 55 and total >= 1 and cooldowns >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        end
    end)
end)

blessingOfProtection:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.hasTalent(204018) then return end -- check for spellwarding and don't use BOP if we do
    fgroup.loop(function(friend)
        if not friend.exists then return end
        --check for forbearance
        if vamsrotation.isLayOnHandsCooldownAvailable() and not player.cc then return end
        -- Ensure the friend exists and is castable
        if not spell:Castable(friend) then return end
        -- Check if the friend has a defensive buff
        if friend.buffFrom(vamsrotation.dontdefensive) then return end
        -- Check if the healer is in a big heal 
        if vamsrotation.isHealerInBigHealBuff() then return end -- check for big heal buffs
        -- check friend attackers
        local total, melee, ranged, cooldowns = friend.v2attackers()

        -- Prioritize lower HP threshold to prevent multiple casts
        if friend.hp <= 30 and total >= 1 then
            spell:Cast(friend)
        elseif friend.hp <= 40 and total >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        elseif friend.hp <= 55 and total >= 1 and cooldowns >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        end
    end)
end)

blessingOfProtection:Callback("feral", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.hasTalent(204018) then return end -- check for spellwarding and don't use BOP if we do
    fgroup.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        if friend.debuff(25771) then return end -- check forbearance
        if friend.buffFrom(vamsrotation.dontdefensive) then return end
        if vamsrotation.isHealerInBigHealBuff() then return end
        if friend.hp > 80 then return end
        if friend.debuff(274838) and friend.debuffRemains(274838) >= 3 then -- check if friend has Feral Frenzy debuff
            enemies.loop(function(enemy)
                if enemy.class == "Druid" and enemy.buff(102543) then -- check if enemy is a feral druid with Incarnation
                    spell:Cast(friend)
                    awful.alert("Casting Blessing of Protection to remove Feral Frenzy during Incarnation!", spell.id)
                end
            end)
        end
    end)
end)

blessingOfProtection:Callback("cc", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not healer.exists then return end
    if player.hasTalent(204018) then return end -- check for spellwarding and don't use BOP if we do
    if not spell:Castable(healer) then return end
    if healer.debuff(25771) then return end -- check forbearance
    fgroup.loop(function(friend)
        if not friend.exists then return end
        local total, melee, ranged, cooldowns = friend.v2attackers()
        if cooldowns < 1 then return end
        if friend.hp >= 65 then return end
        if healer.debuff(2094) and healer.debuffRemains(2094) >= 3 then -- blind
            spell:Cast(healer)
        elseif ((healer.debuff(5246) and healer.debuffRemains(5246) >= 4) or (healer.debuff(408) and healer.debuffRemains(408) >= 3)) and blessingOfSanctuary.cd > 0 then -- intimidation shout or kidney shot
            spell:Cast(healer)
        end
    end)
end)

layOnHands:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end

    fgroup.loop(function(friend)
        if not friend.exists then return end
        if not spell:Castable(friend) then return end
        if friend.buff(202748) then return end -- check survival tactics
        if friend.buffFrom(vamsrotation.dontdefensive) then return end
        if vamsrotation.isHealerInBigHealBuff() then return end
        if friend.debuff(25771) then return end -- check forbearance
        if friend.immune or friend.immuneMagic or friend.immunePhysical then return end
        
        if settings.trustPriestSwap then
            if healer.exists and healer.class2 == "PRIEST" and not healer.cc and healer.cooldown(108968) < 0.5 and 
               not healer.lockouts.shadow then
                -- Healer can cast Void Shift
                return
            end
        end
        -- if friend.class == "Paladin" and friend.cooldown(642) == 0 and friend.hasTalent(146956) then return end -- check bubble for paladins
        local total, melee, ranged, cooldowns = friend.v2attackers()
        -- Adjusted health threshold for 30%
        local adjustedHP30 = 20 + layOnHandsAdjustment.now

        if friend.hp <= adjustedHP30 and total >= 1 then
            spell:Cast(friend)
        elseif friend.hp <= 30 and total >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        end
    end)
end)

-- emergency with no cc/defensive checks at estimated (12% hp // 840k health) 
layOnHands:Callback("emergency", function(spell)
    if not player.combat then return end
    if player.mounted then return end

    fgroup.loop(function(friend)
        if not friend.exists then return end
        if not spell:Castable(friend) then return end
        if friend.buff(202748) then return end -- check survival tactics
        if friend.immune then return end
        if friend.debuff(25771) then return end -- check forbearance
        if settings.trustPriestSwap then
            if healer.exists and healer.class2 == "PRIEST" and not healer.cc and healer.cooldown(108968) < 0.5 and
               not healer.lockouts.shadow then
                -- Healer can cast Void Shift
                return
            end
        end
        local total, melee, ranged, cooldowns = friend.v2attackers()

        if friend.hpa <= 15 then
            spell:Cast(friend)
        end
    end)
end)

eternalFlame:Callback("emergency",function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not player.hasTalent(156322) then return end -- check for eternal flame
    fgroup.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        if friend.hp <= 25 then
            spell:Cast(friend)
        end
    end)
end)

eternalFlame:Callback("offheal", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not player.hasTalent(156322) then return end -- check for eternal flame
    if player.buff(454373) then return end -- check for wings
    fgroup.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        if friend.hp <= 40 and healer.ccRemains ~= 0 then
            spell:Cast(friend)
        end
    end)
end)

wordOfGlory:Callback("emergency",function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if IsSpellOverlayed(427453) then return end -- hold for hammer of light
    fgroup.loop(function(friend)
        if not friend.exists then return end
        if not spell:Castable(friend) then return end
        if friend.hp <= 25 then
            spell:Cast(friend)
        end
    end)
end)

wordOfGlory:Callback("offheal", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if IsSpellOverlayed(427453) then return end -- hold for hammer of light
    fgroup.loop(function(friend)
        if not friend.exists then return end
        if not spell:Castable(friend) then return end
        if friend.hp <= 40 then
            spell:Cast(friend)
        end
    end)
end)

blessingOfSanctuary:Callback("intim", function(spell)
    if not player.hasTalent(210256) then return end
    if not healer.exists then return end
    if not spell:Castable(healer) then return end
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.class2 == "HUNTER" and enemy.cooldown(187650) <= 2 then
            if healer.debuff(24394) then
                if spell:Cast(healer) then return awful.alert(spell.name.." | "..healer.name, spell.id) end
            end
        end
    end)

end)

blessingOfSanctuary:Callback("binding", function(spell)
    if not player.hasTalent(210256) then return end
    if not healer.exists then return end
    if not spell:Castable(healer) then return end
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.class2 == "HUNTER" and enemy.cooldown(187650) <= 2 then
            if healer.debuff(117526) then
                if spell:Cast(healer) then return awful.alert(spell.name.." | "..healer.name, spell.id) end
            end
        end
    end)
end)


blessingOfSanctuary:Callback("sanc_friends_if_no_healer", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if healer.exists then return end
    if not player.hasTalent(210256) then return end

    group.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        local debuffs = friend.debuffFrom(vamsrotation.sancme)
        if not debuffs then return end
        if spell:Cast(friend) then
            awful.alert("Casting Blessing of Sanctuary on " .. friend.name, spell.id)
        end
    end)
end)


blessingOfSanctuary:Callback(function(spell)
    if not player.hasTalent(210256) then return end
    if not healer.exists then return end
    if not spell:Castable(healer) then return end
    if awful.time - friendlyPriestUsed < 1.5 then return end

    -- Check if the healer has any debuff from the list
    local debuffs = healer.debuffFrom(vamsrotation.sancme)
    if not debuffs then return end

    -- Cast the spell and alert
    if spell:Cast(healer) then
        return awful.alert("Blessing of Sanctuary | " .. healer.name, spell.id)
    end
end)

blessingOfSanctuary:Callback("scared", function(spell)
    if not player.hasTalent(210256) then return end
    if not healer.exists then return end
    if not spell:Castable(healer) then return end
    if awful.time - friendlyPriestUsed < 1.5 then return end

    fgroup.loop(function(friend)
        if not friend.exists then return end
        if friend.hpa >= 55 then return end
    end)
        -- Check if the friend has any debuff from the list
    local debuffs = healer.debuffFrom(vamsrotation.scaredsancme)
    if not debuffs then return end

    -- Cast the spell and alert
    if spell:Cast(healer) then
        return awful.alert("Blessing of Sanctuary | " .. healer.name, spell.id)
    end
end)

local TauntCC = {
    -- Polymorph (Mage)
    118, 28271, 28272, 61305, 61721, 61025, 61780, 161372, 161355, 161353, 161354, 126819, 277787, 277792, 391631, 391622, 383121,
    -- Hex (Shaman)
    51514, 210873, 211004, 211015, 211010, 269352, 277778, 277784, 309328,
    -- Others
    5782, 118699, 20066, 605, 360806
}

handOfReckoning:Callback("cc", function(spell)
    if not player.combat then return end

    awful.enemies.loop(function(enemy)
        if enemy.casting then
            for _, spellID in ipairs(TauntCC) do
                if enemy.castingid == spellID and enemy.castTarget.isUnit(player) and enemy.castRemains <= tauntDelay.now then
                    awful.enemyPets.loop(function(pet)
                        if pet.exists and not pet.dead and not pet.cc and 
                           handOfReckoning:Castable(pet) and pet.creatureType ~= "Totem" then
                            if handOfReckoning:Cast(pet) then
                                awful.alert({
                                    message = "Taunt On " .. pet.name .. " (CASTED BCC) ",
                                    texture = spell.id,
                                    duration = 3,
                                    color = {r = 244/255, g = 140/255, b = 186/255, a = 0.9} -- Paladin class color
                                })
                                return true
                            end
                        end
                    end)
                end
            end
        end
    end)
end)

local tauntID = {
    [187650] = function(spellID)
        return awful.missiles.find(function(obj) 
            return obj.source and obj.source.enemy and obj.spellId and obj.spellId == spellID
        end)
    end, 
   
}

onEvent(function(info, event, source, dest)
    if event ~= "SPELL_CAST_SUCCESS" then return end
    local spellID = select(12, unpack(info))
    local aoe = tauntID[spellID]
    if not aoe then return end
    local missile = aoe(spellID)
    if not missile then return end
    local hx, hy, hz = missile.hx, missile.hy, missile.hz
    if player.distanceTo(hx, hy, hz) <= 10 then
        if player.magicEffectImmunityRemains > 1 + awful.buffer then return end
        awful.enemyPets.loop(function(pet)
            if pet.exists and not pet.dead and not pet.cc and 
               handOfReckoning:Castable(pet) and pet.creatureType ~= "Totem" then
                if handOfReckoning:Cast(pet) then
                    awful.alert({
                        message = "Taunt On " .. pet.name .. " (TRAP) ",
                        texture = spellID,
                        duration = 3,
                        color = {r = 244/255, g = 140/255, b = 186/255, a = 0.9} -- Paladin class color
                    })
                    return true
                end
            end
        end)
    end
end)

blindingLight:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not settings.autoBlind then return end
    if player.debuff(410201) then return end -- searing glare
    if vamsrotation.lowestCunt >= 80 then return end
    if not enemyHealer.exists then return end
    if enemyHealer.disorientDR ~= 1 then return end
    if enemyHealer.immuneMagic or enemyHealer.immune then return end
    if enemyHealer.buff(378464) then return end -- check shroud
    if enemyHealer.debuff(6940) then return end -- check pally sac 
    if settings.holdCCOnHealerLock and enemyHealer.locked > 1 then return end -- wait for lockout <= 1
    if enemyHealer.los and enemyHealer.distance < 8 then
        if target.distance > 10 or not target.los then
            if enemyHealer.ccr <= .4 then
                spell:Cast(player)
            end
        end
    end
end)


awful.RegisterMacro("freehorse", 4)

local lastCastTime = 0 -- Tracks the last cast time to handle debounce
local debounceTime = 0.1 -- Approximate Global Cooldown (GCD) duration in seconds

-- Function to cast Divine Steed with necessary checks
local function castDivineSteed()
    if not player.combat then return end
    if player.mounted then return end

    -- Check if Divine Steed is on cooldown
    if divineSteed.cd > 0 then
        return
    end
    -- Check the number of available charges for Divine Steed
    if divineSteed.charges and divineSteed.charges <= 0 then
        return
    end
    -- Attempt to cast Divine Steed on self
    if player.recentlyCast(190784, 4) then return end
    if divineSteed:Cast(player) then
        lastCastTime = GetTime() -- Update the last cast time after successful cast
        awful.alert("Freehorse macro used!", divineSteed.id) -- Alert with Divine Steed's icon
    end
end

function vamsrotation.blessDivineSteed()
    if not player.combat then return end
    if player.mounted then return end
    local currentTime = GetTime()

    -- Prevent the function from executing if it was called too soon
    if currentTime - lastCastTime < debounceTime then
        return -- Exit early to avoid overlapping casts
    end

    -- Check if Blessing of Freedom is already active
    if player.buffRemains(1044) <= 5 then -- Replace 1044 with the actual buff ID if different
        -- Attempt to cast Blessing of Freedom on self
        if blessingOfFreedom:Cast(player) then
            lastCastTime = currentTime -- Update the last cast time after casting BoF
            if player.buff(1044) then
                castDivineSteed() -- Directly cast Divine Steed without scheduling
            end
        end
    else
        -- Proceed to cast Divine Steed immediately since BoF is active
        castDivineSteed()
    end
end
