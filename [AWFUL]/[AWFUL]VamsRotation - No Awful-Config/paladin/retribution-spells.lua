local Unlocker, awful, vamsrotation = ...
local retribution = vamsrotation.paladin.retribution
local Spell = awful.Spell
local target, healer, enemyHealer, player, group, friend = awful.target, awful.healer, awful.enemyHealer, awful.player, awful.group, awful.friend
local hammerOfLightId = 427453

-- Check if the player's spec is Retribution (spec ID 3)
if player.spec ~= "Retribution" or player.class ~= "Paladin" then
    return
end

local settings = vamsrotation.settings
local healthstone = awful.Item(5512)

local bubbleAdjustment = awful.delay(-2.5, 2.5) -- (+/- 2.5%) BUBBLE
local healthstoneAdjustment = awful.delay(-3.5, 3.5) -- Ensure this returns a number
local layOnHandsAdjustment = awful.delay(-5, 5) -- (+/- 5%) LAY ON HANDS
local interruptDelay = awful.delay(0.2, 0.8)
local channelDelay = awful.delay(0.1, 0.3)
local spellDelay = awful.delay(0.15, 0.35)
local tauntDelay = awful.delay(0.2, 0.5)

badge = awful.Item({218421, 218713})


awful.Populate({
    finalVerdict = Spell(383328, { damage= "physical" }), -- <-- don't forget the comma here when you add more spells, this is a table!
    hammerOfWrath = Spell(24275, { damage= "physical" }),
    judgement = Spell(20271, { damage = "physical" }),
    bladeOfJustice = Spell(184575, { damage= "magic" }),
    blessingOfFreedom = Spell(1044, { beneficial = true }),
    divineSteed = Spell(190784),
    blessingOfProtection = Spell(1022, { beneficial = true }),
    divineToll = Spell(375576, { damage = "physical" }),
    layOnHands = Spell(633, { heal = true }),
    blessingOfSacrifice = Spell(6940, { beneficial = true }),
    flashOfLight = Spell(19750, { heal = true }),
    rebuke = Spell(96231, { targeted = true, damage = "physical", ignoreMoving = true, }),
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
    if C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and finalVerdict.cd > 0 then return end
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
    if C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and finalVerdict.cd > 0 then return end
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
    if C_Spell.IsSpellUsable(FindBaseSpellByID(hammerOfLightId)) and finalVerdict.cd > 0 then return end
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
    enemies.loop(function(enemy)
        if not enemy.exists then return end
        if enemy.role ~= "healer" then return end  -- Ensure the enemy is a healer
        if not enemy.los then return end
        if enemy.castPct < (interruptDelay.now * 100) then return end
        if enemy.buff(421453) or enemy.buff(215769) then return end
        if not spell:Castable(enemy) then return end
        for _, spellId in ipairs(vamsrotation.interruptHeal) do
            if enemy.castingId == spellId then
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
        if not enemy.los then return end
        if not enemy.exists then return end
        if player.casting and enemy.castRemains > player.castRemains then return end
        if enemy.castPct < (interruptDelay.now * 100) then return end
        if enemy.castTarget.friend and (enemy.castTarget.buff(8178) or enemy.castTarget.buff(212295) or enemy.castTarget.buff(23920)) then return end -- ground totem, nether ward, spell reflection
        for _, spellId in ipairs(vamsrotation.interruptCC) do
            if enemy.castingId == spellId then
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
    enemies.loop(function(enemy)
        -- if not enemy.class == "Priest" or enemy.class == "Paladin" then 
        --     if enemy.role == "healer" then return end
        -- end
        if not enemy.los then return end
        if not enemy.exists then return end
        if player.casting and enemy.castRemains > player.castRemains then return end
        if enemy.castPct < (interruptDelay.now * 100) then return end
        if enemy.castTarget.friend and (enemy.castTarget.buff(8178) or enemy.castTarget.buff(212295) or enemy.castTarget.buff(23920)) then return end -- ground totem, nether ward, spell reflection
        if not spell:Castable(enemy) then return end
        for _, spellId in ipairs(vamsrotation.interruptDamage) do
            if enemy.castingId == spellId then
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
    if spell.cd > 0 then return end

    enemies.loop(function(enemy)
        if enemy.channeling then -- Check if the enemy is channeling

            local channelTime = enemy.channeling4 / 1000
            if (channelTime + 0.2 + channelDelay.now) > awful.time then return end
            if vamsrotation.interruptChannel[enemy.channelID] then
                return spell:Cast(enemy)
            end
        end
    end)
end)


hammerOfJustice:Callback("healer",function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if settings.stunMode == "off" then return end
    if settings.stunMode == "trap" then return end
    if not (settings.stunMode == "healer" or settings.stunMode == "auto") then return end
    if player.debuff(410201) then return end -- searing glare
    if not enemyHealer.exists and not enemyHealer.los then return end
    if enemyHealer.buff(8178) or enemyHealer.buff(408558) then return end -- check grounding totem + phase shift
    if target.immune or target.immuneMagic then return end
    if not spell:Castable(enemyHealer) then return end
    if enemyHealer.ccRemains <= 0.5 and enemyHealer.stunDR == 1 then
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

    -- Ensure the target is a valid player
    if not target.exists or not target.enemy or not target.player or not target.los then return end
    if not target.stunDR == 1 then return end

    -- Condition 1: No healer exists
    local condition1 = not enemyHealer.exists

    -- Condition 2: Enemy healer is on stun DR for more than 10 seconds and in CC for 3 seconds or more
    local condition2 = enemyHealer.exists and enemyHealer.stunDR < 1 and enemyHealer.sdrr >= 8 and enemyHealer.ccr >= 1.5

    -- Condition 3: Enemy healer is more than 20 yards away and in CC for 3 seconds or more
    local condition3 = enemyHealer.exists and enemyHealer.distance > 20 and enemyHealer.ccRemains >= 1.5

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
    if player.debuff(410201) then return end -- searing glare
    if target.buff(8178) or target.buff(408558) then return end -- check grounding totem + phase shift
    if target.immune or target.immuneMagic then return end
    if not player.combat then return end
    if player.mounted then return end
    if not target.enemy and not target.player then return end
    if not target.exists then return end
    if not enemyHealer.debuff(203337) or enemyHealer.debuff() then return end
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

blessingOfFreedom:Callback("friend", function(spell)
    if not player.combat then return end
    if player.mounted then return end
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

divineShield:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.lastCast == 471195 then return end -- check lay last cast
    if player.recentlyCast(471195, 1) then return end -- check lay recency
    if player.cooldown(471195) < 1 then return end -- check if Lay on Hands is on cooldown
    if vamsrotation.WasCasting[471195] then return end -- check lay wascasting

    local adjustedBubbleHP = settings.bubbleHP + bubbleAdjustment.now
    local total, melee, ranged, cooldowns = player.v2attackers()

    if player.hp <= adjustedBubbleHP and total >= 1 then
        spell:Cast()
    end
    if player.hp <= 30 and total >= 1 and healer.ccRemains >= 1 then
        spell:Cast()
    end
    -- if player.hp <= 40 and total >= 2 and cooldowns >= 1 and healer.ccRemains >= 2.5 then
    --     spell:Cast()
    -- end
end)

divineProtection:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end

    local total, melee, ranged, cooldowns = player.v2attackers()

    if player.hp <= 60 and total >= 2 then
        spell:Cast()
    elseif player.hp <= 90 and total >= 1 and cooldowns >= 1 then
        spell:Cast()
    end
end)

shieldOfVengeance:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end

    local total, melee, ranged, cooldowns = player.v2attackers()

    if healer.exists then
        if player.hp <= 70 and total >= 1 then
            spell:Cast()
        elseif player.hp <= 90 and cooldowns >= 1 and healer.ccRemains >= 1 and total >= 1 then
            spell:Cast()
        end
    else
        if player.hp <= 90 and cooldowns >= 1 and total >= 1 then
            spell:Cast()
        elseif player.hp <= 70 and total >= 1 then
            spell:Cast()
        end
    end
end)

blessingOfSacrifice:Callback("friend", function(spell)
    if not player.combat then return end
    if player.mounted then return end

    group.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end

        local total, melee, ranged, cooldowns = friend.v2attackers()

        -- Prioritize lower HP threshold to prevent multiple casts
        if total >= 1 and friend.hp <= 50 then
            spell:Cast(friend)
        elseif total >= 1 and cooldowns >= 1 and friend.hp <= 70 then
            spell:Cast(friend)
        elseif total >= 2 and cooldowns >= 1 and healer.ccRemains >= 2 and friend.hp <= 90 then
            spell:Cast(friend)
        end
    end)
end)

blessingOfSpellwarding:Callback("personal", function(spell)
    local total, melee, ranged, cooldowns = player.v2attackers()
    if not player.combat then return end
    if player.mounted then return end
    if not player.hasTalent(204018) then return end
    if player.debuff(25771) then return end -- check forbearance
    if not player.hasTalent(146956) and player.cooldown(642) < 1 then return end -- check bubble

    if player.hp <= 25 and ranged >= 1 then
        spell:Cast(player)
    end
    if player.hp <= 40 and ranged >= 1 and healer.ccRemains >= 2 then
        spell:Cast(player)
    end
end)

blessingOfSpellwarding:Callback("teammate", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    group.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        -- if friend.class == "Paladin" and friend.cooldown(642) == 0 and friend.hasTalent(146956) then return end -- check bubble for paladins
        local total, melee, ranged, cooldowns = friend.v2attackers()
        if friend.debuff(25771) then return end -- check forbearance
        if friend.hp <= 25 and ranged >= 1 then
            spell:Cast(friend)
        end
        if friend.hp <= 40 and ranged >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        end
    end)
end)

blessingOfProtection:Callback("personal", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    local total, melee, ranged, cooldowns = player.v2attackers()
    if player.debuff(25771) then return end -- check forbearance
    if not player.hasTalent(146956) and player.cooldown(642) < 1 then return end -- check bubble
    if player.hp <= 35 and melee >= 1 then
        spell:Cast(player)
    end
    if player.hp <= 50 and melee >= 1 and cooldowns >=1 and healer.ccRemains >= 1 then
        spell:Cast(player)
    end
end)

blessingOfProtection:Callback("friend", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    group.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        -- if friend.class == "Paladin" and friend.cooldown(642) == 0 and friend.hasTalent(146956) then return end -- check bubble for paladins
        local total, melee, ranged, cooldowns = friend.v2attackers()
        if friend.debuff(25771) then return end -- check forbearance

        -- Prioritize lower HP threshold to prevent multiple casts
        if friend.hp <= 30 and melee >= 1 then
            spell:Cast(friend)
        elseif friend.hp <= 40 and melee >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        elseif friend.hp <= 55 and melee >= 1 and cooldowns >= 1 and healer.ccRemains >= 2 then
            spell:Cast(friend)
        end
    end)
end)

blessingOfProtection:Callback("hunter", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    fgroup.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        -- if friend.class == "Paladin" and friend.cooldown(642) == 0 and friend.hasTalent(146956) then return end -- check bubble for paladins
        enemies.loop(function(enemy)
            local total, melee, ranged, cooldowns = friend.v2attackers()
            if friend.debuff(25771) then return end -- check forbearance
            if enemy.class ~= "Hunter" then return end -- Corrected condition
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
end)

layOnHands:Callback("personal", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    local total, melee, ranged, cooldowns = player.v2attackers()
    if player.debuff(25771) then return end -- check forbearance
    -- Adjusted health threshold for 30%
    local adjustedHP30 = 20 + layOnHandsAdjustment.now

    if player.hp <= adjustedHP30 and total >= 1 then
        spell:Cast(player)
    elseif player.hp <= 35 and total >= 1 and healer.ccRemains >= 2 then
        spell:Cast(player)
    end
end)

layOnHands:Callback("friend", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    group.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        if friend.debuff(25771) then return end -- check forbearance
        -- if friend.class == "Paladin" and friend.cooldown(642) == 0 and friend.hasTalent(146956) then return end -- check bubble for paladins
        local total, melee, ranged, cooldowns = friend.v2attackers()
        -- Adjusted health threshold for 30%
        local adjustedHP30 = 20 + layOnHandsAdjustment.now

        if friend.hp <= adjustedHP30 and total >= 1 then
            spell:Cast(friend)
        elseif friend.hp <= 35 and total >= 1 and healer.ccRemains >= 2 then
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
    if player.hasTalent(156322) then return end -- check for eternal flame
    fgroup.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        if friend.hp <= 25 then
            spell:Cast(friend)
        end
    end)
end)

wordOfGlory:Callback("offheal", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.hasTalent(156322) then return end -- check for eternal flame
    if player.buff(454373) then return end -- check for wings
    fgroup.loop(function(friend)
        if not friend.exists or not spell:Castable(friend) then return end
        if friend.hp <= 40 and healer.ccRemains ~= 0 then
            spell:Cast(friend)
        end
    end)
end)

blessingOfSanctuary:Callback("intim", function(spell)
    if not player.hasTalent(210256) then return end
    if not healer.exists then return end
    if not spell:Castable(healer) then return end
    if healer.debuff(24394) then
        if spell:Cast(healer) then return awful.alert(spell.name.." | "..healer.name, spell.id) end
    end
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

    -- Check if the healer has any debuff from the list
    local debuffs = healer.debuffFrom(vamsrotation.sancme)
    if not debuffs then return end

    -- Cast the spell and alert
    if spell:Cast(healer) then
        return awful.alert("Blessing of Sanctuary | " .. healer.name, spell.id)
    end
end)

blessingOfSanctuary:Callback("stun", function(spell)
    if not player.hasTalent(210256) then return end
    if not healer.exists then return end
    if not healer.los then return end
    if healer.stunRemains >= 2.5 then
        if healer.debuffUptime(healer.stun) >= spellDelay.now then
            if spell:Cast(healer) then return awful.alert(spell.name.." | "..healer.name, spell.id) end
        end
    end
end)

blessingOfSanctuary:Callback("silence", function(spell)
    if not player.hasTalent(210256) then return end
    if not healer.exists then return end
    if not healer.los then return end
    if healer.silenceRemains >= 2.5 then
        if healer.debuffUptime(healer.silence) >= spellDelay.now then
            if spell:Cast(healer) then return awful.alert(spell.name.." | "..healer.name, spell.id) end
        end
    end
end)

blessingOfSanctuary:Callback("disorient", function(spell)
    if not player.hasTalent(210256) then return end
    if healer.debuff(360806) then return end -- sleep walk check
    if not healer.exists then return end
    if not healer.los then return end
    if healer.disorientRemains >= 2.5 then
        if healer.debuffUptime(healer.disorient) >= spellDelay.now then
            if spell:Cast(healer) then return awful.alert(spell.name.." | "..healer.name, spell.id) end
        end
    end
end)

handOfReckoning:Callback("anti-cc", function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if player.debuff(410201) then return end -- searing glare
    enemies.loop(function(enemy)
        if enemy.casting then
            if enemy.castPct < (tauntDelay.now * 100) then return end
            for _, spellId in ipairs(vamsrotation.instaBreakCC) do
                if enemy.castingid == spellId and enemy.castTarget.isUnit(player) then
                    enemyPets.loop(function(pet)
                        if pet.exists and not pet.cc and handOfReckoning:Castable(pet) and pet.creatureType ~= "Totem" then
                            if handOfReckoning:Cast(pet) then return awful.alert("Taunting".. pet.name .." to break CC", handOfReckoning.id) end
                        end
                    end)
                end
            end
        end
    end)
end)

blindingLight:Callback(function(spell)
    if not player.combat then return end
    if player.mounted then return end
    if not settings.autoBlind then return end
    if player.debuff(410201) then return end -- searing glare
    if vamsrotation.lowestCunt >= 80 then return end
    if not enemyHealer.exists then return end
    if enemyHealer.disorientDR ~= 1 then return end
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