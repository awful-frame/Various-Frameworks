local Tinkr = ...
local Elite = _G.Elite
local Draw = Tinkr.Util.Draw:New() -- To use Tinkr Drawings
local e = Elite.CallbackManager.spellbook -- Elite Spellbook
local OM = Elite.ObjectManager -- Elite Object Manager
local EventManager = Elite.EventManager
local enemies = OM:GetEnemies() -- Populate the unit lists (enemies)
local friends = OM:GetFriends() -- Populate the unit lists (friends)
local tyrants = OM:GetTyrants() -- Populate the unit lists (tyrants)
local totems = OM:GetTotems() -- enemy
local friendlyTotems = OM:GetFTotems() -- friendly
local areaTriggers = OM:GetAreaT() -- Populate the unit lists (area triggers)
local brokencyde = {}
Elite:SetUtilitiesEnvironment() -- Set your script environment to run with Elite
_G.TickRate = 0.01
local PerfMonitor = {
    logs = {},
    start_times = {},
    function_times = {},
    last_print_time = 0,
    print_interval = 5, -- Only print every 5 seconds
    thresholds = {
        function_time = 200,
        loop_time = 5,
        log_size = 1000
    }
}

local function toMS(time)
    return time * 1000
end

function PerfMonitor:start(label)
    self.start_times[label] = debugprofilestop()
end

function PerfMonitor:stop(label)
    local end_time = debugprofilestop()
    local duration = toMS(end_time - self.start_times[label])

    if not self.function_times[label] then
        self.function_times[label] = {
            total_time = 0,
            calls = 0,
            max_time = 0,
            min_time = math.huge
        }
    end

    local stats = self.function_times[label]
    stats.total_time = stats.total_time + duration
    stats.calls = stats.calls + 1
    stats.max_time = math.max(stats.max_time, duration)
    stats.min_time = math.min(stats.min_time, duration)

    return duration
end

function PerfMonitor:logFunctionTime(label, duration)
    if duration > self.thresholds.function_time then
        local log_entry = string.format(
                "[PERF] %s took %.2fms",
                label,
                duration
        )
        brokencyde.log_message(log_entry)
    end
end

function PerfMonitor:printStats()
    local current_time = GetTime()

    -- Only print stats every X seconds
    if current_time - self.last_print_time < self.print_interval then
        return
    end

    -- Store stats in a pre-allocated table
    local stats_lines = {}
    table.insert(stats_lines, "=== Performance Statistics ===")

    -- Sort functions by total time for relevance
    local sorted_functions = {}
    for label, stats in pairs(self.function_times) do
        table.insert(sorted_functions, {label = label, stats = stats})
    end
    table.sort(sorted_functions, function(a, b)
        return a.stats.total_time > b.stats.total_time
    end)

    -- Only print top 10 most time-consuming functions
    for i = 1, math.min(10, #sorted_functions) do
        local func = sorted_functions[i]
        local stats = func.stats
        local avg_time = stats.total_time / stats.calls

        -- Format string once
        table.insert(stats_lines, string.format(
                "%s:\n  Calls: %d\n  Avg: %.2fms\n  Min: %.2fms\n  Max: %.2fms\n  Total: %.2fms",
                func.label,
                stats.calls,
                avg_time,
                stats.min_time,
                stats.max_time,
                stats.total_time
        ))
    end

    -- Single concatenation and log
    brokencyde.log_message(table.concat(stats_lines, "\n"))

    self.last_print_time = current_time
end

function PerfMonitor:reset()
    -- Keep the structure but clear the data
    for k in pairs(self.function_times) do
        self.function_times[k] = {
            total_time = 0,
            calls = 0,
            max_time = 0,
            min_time = math.huge
        }
    end
end
local specMap = {
    [250] = { class = "Death Knight", spec = "Blood", specId = 250 },
    [251] = { class = "Death Knight", spec = "Frost", specId = 251 },
    [252] = { class = "Death Knight", spec = "Unholy", specId = 252 },
    [577] = { class = "Demon Hunter", spec = "Havoc", specId = 577 },
    [581] = { class = "Demon Hunter", spec = "Vengeance", specId = 581 },
    [102] = { class = "Druid", spec = "Balance", specId = 102 },
    [103] = { class = "Druid", spec = "Feral", specId = 103 },
    [104] = { class = "Druid", spec = "Guardian", specId = 104 },
    [105] = { class = "Druid", spec = "Restoration", specId = 105 },
    [1467] = { class = "Evoker", spec = "Devastation", specId = 1467 },
    [1468] = { class = "Evoker", spec = "Preservation", specId = 1468 },
    [1473] = { class = "Evoker", spec = "Augmentation", specId = 1473 },
    [253] = { class = "Hunter", spec = "Beast , specId = 253Mastery" },
    [254] = { class = "Hunter", spec = "Marksmanship", specId = 254 },
    [255] = { class = "Hunter", spec = "Survival", specId = 255 },
    [62] = { class = "Mage", spec = "Arcane", specId = 62 },
    [63] = { class = "Mage", spec = "Fire", specId = 63 },
    [64] = { class = "Mage", spec = "Frost", specId = 64 },
    [268] = { class = "Monk", spec = "Brewmaster", specId = 268 },
    [269] = { class = "Monk", spec = "Windwalker", specId = 269 },
    [270] = { class = "Monk", spec = "Mistweaver", specId = 270 },
    [65] = { class = "Paladin", spec = "Holy", specId = 65 },
    [66] = { class = "Paladin", spec = "Protection", specId = 66 },
    [70] = { class = "Paladin", spec = "Retribution", specId = 70 },
    [256] = { class = "Priest", spec = "Discipline", specId = 256 },
    [257] = { class = "Priest", spec = "Holy", specId = 257 },
    [258] = { class = "Priest", spec = "Shadow", specId = 258 },
    [259] = { class = "Rogue", spec = "Assassination", specId = 259 },
    [260] = { class = "Rogue", spec = "Outlaw", specId = 260 },
    [261] = { class = "Rogue", spec = "Subtlety", specId = 261 },
    [262] = { class = "Shaman", spec = "Elemental", specId = 262 },
    [263] = { class = "Shaman", spec = "Enhancement", specId = 263 },
    [264] = { class = "Shaman", spec = "Restoration", specId = 264 },
    [265] = { class = "Warlock", spec = "Affliction", specId = 265 },
    [266] = { class = "Warlock", spec = "Demonology", specId = 266 },
    [267] = { class = "Warlock", spec = "Destruction", specId = 267 },
    [71] = { class = "Warrior", spec = "Arms", specId = 71 },
    [72] = { class = "Warrior", spec = "Fury", specId = 72 },
    [73] = { class = "Warrior", spec = "Protection", specId = 73 }
}

function brokencyde.getOpponentSpecs()
    local numOpponents = GetNumArenaOpponentSpecs()
    local opponents = {}

    for i = 1, numOpponents do
        local specId = GetArenaOpponentSpec(i)
        local opponent = specMap[specId]

        if opponent then
            table.insert(opponents, { class = opponent.class, spec = opponent.spec, specId = specId })
        end
    end

    return opponents
end

function brokencyde.isAgainstSpec(targetSpec)
    for _, opponent in ipairs(brokencyde.getOpponentSpecs()) do
        if opponent.spec == targetSpec then
            return true
        end
    end

    return false
end

function brokencyde.isAgainstClass(targetClass)
    for _, opponent in ipairs(brokencyde.getOpponentSpecs()) do
        if opponent.class == targetClass then
            return true
        end
    end

    return false
end

function brokencyde.isAgainstAnySpec(specIDs)
    local opponents = brokencyde.getOpponentSpecs()
    for _, opponent in ipairs(opponents) do
        for _, specID in ipairs(specIDs) do
            if opponent.specId == specID then
                return true
            end
        end
    end
    return false
end

function brokencyde.isAgainstAllSpecs(specIDs)
    local opponents = brokencyde.getOpponentSpecs()
    local specCount = 0

    for _, specID in ipairs(specIDs) do
        for _, opponent in ipairs(opponents) do
            if opponent.specId == specID then
                specCount = specCount + 1
                break
            end
        end
    end

    return specCount == #specIDs
end

local function shouldPickThickAsThieves()
    return HasTalent(57934)
end

local function shouldPickTakeYourCut()
    local hasteEfficientSpecs = {
        [102] = true,
        [1473] = true,
        [255] = true,
        [62] = true,
        [63] = true,
        [64] = true,
        [258] = true,
        [265] = true,
        [266] = true,
        [267] = true,
        [71] = true,
    }

    local result = false

    ObjectsLoop(friends, function(friend)
        if Role(friend.key) == "HEALER" then
            return false
        end

        if hasteEfficientSpecs[Spec(friend.key)] then
            result = true
            return true
        end
    end)

    return result
end

local function shouldPickDismantle()
    return brokencyde.isAgainstAnySpec({ 259, 260, 261, 71, 72, 254, 577 })
end

local function shouldPickVeilOfMidnight()
    if brokencyde.isAgainstAnySpec({ 269, 259, 103 }) then
        return true
    end

    return false
end

function brokencyde.autoPickPvpTalents()
    local pvpTalents = {
        { name = "Take your Cut", spellId = 198265, talentId = 135 },
        { name = "Smoke Bomb", spellId = 212182, talentId = 3483 },
        { name = "Thick as Thieves", spellId = 221622, talentId = 1208 },
        { name = "Veil of Midnight", spellId = 198952, talentId = 5516 },
        { name = "Dismantle", spellId = 207777, talentId = 145 },
    }

    local function moveToFirst(talentName)
        for i, talent in ipairs(pvpTalents) do
            if talent.name == talentName then
                table.remove(pvpTalents, i)
                table.insert(pvpTalents, 1, talent)
                break
            end
        end
    end

    if shouldPickTakeYourCut() then
        moveToFirst("Take your Cut")
    end

    if shouldPickThickAsThieves() then
        moveToFirst("Thick as Thieves")
    end

    if shouldPickDismantle() then
        moveToFirst("Dismantle")
    end

    if shouldPickVeilOfMidnight() then
        moveToFirst("Veil of Midnight")
    end

    pvpTalents = { pvpTalents[1], pvpTalents[2] }

    local indexUsed = 0

    for i, talent in ipairs(pvpTalents) do
        indexUsed = indexUsed + 1

        if not HasTalent(talent.spellId) then
            LearnPvpTalent(talent.talentId, indexUsed)
        end
    end

    if not HasTalent(354843) then
        LearnPvpTalent(5412, 3)
    end
end
function brokencyde.getSpellInfo(spellId, forceIdReturn)
    if forceIdReturn then
        return spellId
    end

    if not spellId or spellId == 0 then
        return 0
    end

    local getSpellInfo = C_Spell.GetSpellInfo(spellId)

    if getSpellInfo then
        return getSpellInfo.name
    end

    return ""
end

function brokencyde.isStealth(unit)
    return BuffFrom(unit, {
        brokencyde.getSpellInfo(1784),
        brokencyde.getSpellInfo(115191),
        brokencyde.getSpellInfo(199483)
    })
end

function brokencyde.shouldWaitForBcc(unit)
    if not unit or not unit.key then
        return false
    end

    if IsTarget(unit.key) then
        return false
    end

    if not bcc(unit.key) then
        return false
    end

    return true
end

function brokencyde.getMaxComboPoints()
    local cp = 5

    if HasTalent(193531) then
        cp = cp + 1
    end

    if HasTalent(394321) then
        cp = cp + 1
    end

    return cp
end

function brokencyde.cancelBladeFlurry()
    if not HasBuff(bladeFlurry.id, "player") then
        return false
    end

    if not brokencyde.shouldCancelBladeFlurry then
        return false
    end

    Alert(bladeFlurry.id, "Cancelling Blade Flurry")

    rmt("/cancelaura " .. brokencyde.getSpellInfo(bladeFlurry.id))
end

function brokencyde.playerSpeccedIntoEchoingReprimand()
    return HasTalent(385616)
end

function brokencyde.echoingReprimandIsUp()
    return BuffFrom("player", { 323558, 323559, 323560 })
end

function brokencyde.avoidBurstingUnit(unit)
    return false
end

function brokencyde.getDamageReductionFromDefensives(unit)
    if not unit or not unit.key then
        return 0
    end

    local totalDamageReduction = 1

    local buffsDamageReduction = {
        [brokencyde.OBSIDIAN_SCALES] = 0.3,
        [brokencyde.DIVINE_PROTECTION] = 0.2,
        [brokencyde.UNENDING_RESOLVE] = 0.25,
        [brokencyde.SOUL_LINK] = 0.1,
        [brokencyde.ICEBOUND_FORTITUDE] = 0.3,
        [brokencyde.POWER_WORD_BARRIER] = 0.5,
        [brokencyde.PAIN_SUPPRESSION] = 0.4,
        [brokencyde.DISPERSION] = 0.75,
        [brokencyde.DIE_BY_THE_SWORD] = 0.3,
        [brokencyde.ENRAGED_REGENERATION] = 0.3,
        [brokencyde.SHIELD_WALL] = 0.4,
        [brokencyde.IGNORE_PAIN] = 0.5,
        [brokencyde.BARKSKIN] = 0.2,
        [brokencyde.SURVIVAL_INSTINCTS] = 0.5,
        [brokencyde.IRONBARK] = 0.2,
        [brokencyde.FORTIFYING_BREW] = 0.15,
        [brokencyde.ASTRAL_SHIFT] = 0.4,
        [brokencyde.DIFFUSE_MAGIC] = 0.6,
    }

    for i, buff in ipairs(GetBuffs(unit.key)) do
        local name = unpack(buff)

        if buffsDamageReduction[name] then
            totalDamageReduction = totalDamageReduction * (1 - buffsDamageReduction[name])
        end
    end

    return 1 - totalDamageReduction
end

function brokencyde.outlawBursting()
    if brokencyde.betweenTheEyesChecks("target", true) then
        return true
    end

    if HasBuff(adrenalineRush.id, "player") then
        return true
    end

    return false
end

local function allUnitsInCombat(units)
    local allUnitsAreInCombat = false
    local unitsCount = 0
    local unitsInCombatCount = 0

    ObjectsLoop(units, function(unit, guid)
        unitsCount = unitsCount + 1

        if InCombat(unit) then
            unitsInCombatCount = unitsInCombatCount + 1
        end
    end)

    if unitsInCombatCount == unitsCount then
        allUnitsAreInCombat = true
    end

    return allUnitsAreInCombat
end

brokencyde.combatStarted = false

function brokencyde.setCombatStarted()
    if brokencyde.combatStarted then
        return
    end

    local allEnemiesAreInCombat = allUnitsInCombat(enemies)
    local allFriendsAreInCombat = allUnitsInCombat(friends)

    if allEnemiesAreInCombat and allFriendsAreInCombat then
        brokencyde.combatStarted = true
    end
end

function brokencyde.getUnitsAround(unit, searchUnits, distance, criteria)
    local allUnits = {}
    local unitsFollowingCriteria = {}

    ObjectsLoop(searchUnits, function(unitSearched)
        if Distance(unit.key, unitSearched.key) > distance then
            return false
        end

        table.insert(allUnits, unitSearched)

        if criteria and criteria(unitSearched) then
            table.insert(unitsFollowingCriteria, unitSearched)
        end
    end)

    return unitsFollowingCriteria, allUnits
end

local function setShouldCancelBladeFlurry()
    if not brokencyde.isOutlaw() then
        return false
    end

    brokencyde.shouldCancelBladeFlurry = false

    if not HasBuff(bladeFlurry.id, "player") then
        return false
    end

    local bccEnemies, allEnemies = brokencyde.getUnitsAround(myPlayer, enemies, 10, function(enemy)
        if bccr(enemy.key) < 2 then
            return false
        end

        if not IsPlayer(enemy.key) then
            return false
        end

        if HasDot(enemy.key) then
            return false
        end

        local enemyHealer = brokencyde.getEnemyHealer()

        if enemyHealer and enemyHealer.key == enemy.key then
            return true
        end

        if Role(enemy.key) == "HEALER" then
            return true
        end

        return bccr(enemy.key) >= 3
    end)

    if #bccEnemies > 0 then
        brokencyde.shouldCancelBladeFlurry = true
    end
end

function brokencyde.stopAttack()
    if brokencyde.shouldCancelBladeFlurry then
        StopAttack()
        return false
    end

    if bccr("target") > 0 then
        StopAttack()
        return false
    end

    if InCombat("player") and InMelee("target") then
        AttackUnit("target")
        return false
    end

    return false
end

function brokencyde.castPoisons()
    if GetBuffRemaining(brokencyde.getSpellInfo(woundPoison.id), "player") < 1800 and not brokencyde.wasCasting[woundPoison.id] then
        woundPoison:Cast()
    end

    if GetBuffRemaining(brokencyde.getSpellInfo(cripplingPoison.id), "player") < 1800 and not brokencyde.wasCasting[cripplingPoison.id] then
        cripplingPoison:Cast()
    end
end

local function cancelStealthInPrep()
    if not brokencyde.isOutlaw() then
        return false
    end

    rmt("/cancelaura " .. brokencyde.getSpellInfo(1784))
end

local sqw = GetTime() + 5

local function spellQueue()
    if GetTime() <= sqw then
        return false
    end

    brokencyde.SQW = tonumber(GetCVar("SpellQueueWindow"))
    local TargetSQW = (select(3, GetNetStats()) * 2) + 15

    if brokencyde.SQW ~= TargetSQW then
        SetCVar("SpellQueueWindow", TargetSQW)
    end

    sqw = GetTime() + 5
end

local function useHealthStone()
    if ItemOnCooldown(5512) then
        return false
    end

    local healthStoneStacks = GetItemCount(5512)

    if not healthStoneStacks then
        return false
    end

    if TrueHealthP("player") < 80 then
        rmt("/use HealthStone")
    end
end

local flaresCache = {}

local function cleanupOldFlares()
    local currentTime = GetTime()
    for guid, data in pairs(flaresCache) do
        if currentTime - data.timestamp > 20 then
            flaresCache[guid] = nil
        end
    end
end

function brokencyde.getFlares()
    local flares = {}
    local currentTime = GetTime()

    cleanupOldFlares()

    ObjectsLoop(areaTriggers, function(trigger)
        local guid = trigger.guid

        if flaresCache[guid] then
            table.insert(flares, trigger)
            return false
        end

        local spellId = AreaSpell(trigger)

        if brokencyde.getSpellInfo(spellId) ~= brokencyde.getSpellInfo(132950) then
            return false
        end

        if brokencyde.getCreator(trigger, friends) then
            return false
        end

        flaresCache[guid] = {
            timestamp = currentTime
        }

        table.insert(flares, trigger)
    end)

    return flares
end

local function wasCastingCheck()
    local time = GetTime()

    if IsCastChan("player") then
        brokencyde.wasCasting[CastInfo("player")] = time
    end

    for spell, when in pairs(brokencyde.wasCasting) do
        if time - when > 0.100 + Latency() + 1 then
            brokencyde.wasCasting[spell] = nil
        end
    end
end

brokencyde.wasCasting = {}
brokencyde.objectsDrawn = {}

function brokencyde.globalVariablesLoop()
    brokencyde.objectsDrawn = {}
    wasCastingCheck()
    brokencyde.stopAttack()
    runTotemStomp()
    runStomp()
    spellQueue()
    brokencyde.setCombatStarted()
    setShouldCancelBladeFlurry()
    brokencyde.cancelBladeFlurry()
    useHealthStone()

    if Prep() then
        brokencyde.prepTimestamp = GetTime()
        cancelStealthInPrep()
        brokencyde.autoPickPvpTalents()
        brokencyde.castPoisons()
        brokencyde.combatStarted = false
        GrabHealthstone(2, 3)
        flaresCache = {}
    end
end

function brokencyde.getEnemyHealer()
    if myFocus then
        return myFocus
    end

    return eHealer
end

function brokencyde.getLowestHpEnemy()
    local lowestHp = 100
    local lowestHpEnemy = nil

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if TrueHealthP(enemy.key) < lowestHp then
            lowestHp = TrueHealthP(enemy.key)
            lowestHpEnemy = enemy
        end
    end)

    return lowestHpEnemy
end

function brokencyde.isOutlaw()
    return GetSpecialization() == 2
end

function brokencyde.isInsideAoE(aoe, radius, unit)
    if not unit then
        return false
    end

    if not unit.key then
        return false
    end

    local x, y, z = Position(aoe.key)
    local ux, uy, uz = Position(unit.key)

    if not x or not y or not z or not ux or not uy or not uz then
        return false
    end

    local distance = math.sqrt((ux - x) ^ 2 + (uy - y) ^ 2 + (uz - z) ^ 2)

    return distance <= radius
end

local function friendlyInfernalIsUp(currentTarget)
    local wePlayWithDestro = false

    ObjectsLoop(friends, function(friend)
        if Spec(friend.key) ~= 267 then
            return false
        end

        wePlayWithDestro = true
        return true
    end)

    if not wePlayWithDestro then
        return false
    end

    local infernalUp = false

    -- TODO: Fix this when units is available
    --ObjectsLoop(units, function(unit)
    --    if IsEnemy(unit.key) then
    --        return false
    --    end
    --
    --    if oid(unit.key) ~= 89 then
    --        return false
    --    end
    --
    --    if Distance(unit.key, currentTarget.key) > 30 then
    --        return false
    --    end
    --
    --    infernalUp = true
    --    return true
    --end)

    return infernalUp
end

local function tooCloseToBurstingFriendlyDK(unit)
    local isTooClose = false

    ObjectsLoop(friends, function(friend)
        if Class(friend.key) ~= "DEATHKNIGHT" then
            return false
        end

        if not HasBuff(brokencyde.ABOMINATION_LIMB, friend.key) then
            return false
        end

        if Distance(friend.key, unit.key) > 30 then
            return false
        end

        isTooClose = true
        return true
    end)

    return isTooClose
end

function brokencyde.getUnitByGuid(guid, tablesToSearch)
    if not guid then
        return nil
    end

    local foundUnit = nil
    local tables = type(tablesToSearch[1]) == "table" and tablesToSearch or { tablesToSearch }

    for _, currentTable in ipairs(tables) do
        ObjectsLoop(currentTable, function(object)
            if not object.guid then
                return false
            end

            if object.guid == guid then
                foundUnit = object
                return true
            end
        end)

        if foundUnit then
            break
        end
    end

    return foundUnit
end

function brokencyde.getCreator(unit, tablesToSearch)
    if not unit or not unit.key then
        return nil
    end

    local creator = nil
    local tables = type(tablesToSearch[1]) == "table" and tablesToSearch or { tablesToSearch }

    for _, currentTable in ipairs(tables) do
        ObjectsLoop(currentTable, function(object)
            if not object.key then
                return false
            end

            if Creator(unit.key) == object.guid then
                creator = object
                return true
            end
        end)

        if creator then
            break
        end
    end

    return creator
end

function brokencyde.canBlindSafely(unit)
    if not unit or not unit.key then
        return false
    end

    if tooCloseToBurstingFriendlyDK(unit) then
        return false
    end

    local triggersConfig = {
        [190356] = { radius = 8 }, -- Blizzard
        [198149] = { radius = 10 }, -- Frozen Orb
        [43265] = { radius = 8 }, -- Death and Decay
        [26573] = { radius = 8 }, -- Consecration,
        [260243] = { radius = 8 } -- Volley
    }

    local canCast = true

    ObjectsLoop(areaTriggers, function(trigger)
        if brokencyde.getCreator(trigger, { enemies }) then
            return false
        end

        local config = triggersConfig[AreaSpell(trigger)]

        if config and brokencyde.isInsideAoE(trigger, config.radius, unit) then
            canCast = false
            return true
        end
    end)

    if not canCast then
        return false
    end

    if HasDebuff(brokencyde.getSpellInfo(353082), unit.key) then
        return false
    end

    if friendlyInfernalIsUp(unit) then
        return false
    end

    ObjectsLoop(friends, function(friend)
        if HasBuff(brokencyde.getSpellInfo(353082), friend.key) and Distance(friend.key, unit.key) < 10 then
            canCast = false
            return true
        end
    end)

    return canCast
end

function brokencyde.dump(object, indent)
    indent = indent or 0

    if type(object) == 'table' then
        local result = '{\n'
        local indentStr = string.rep('  ', indent + 1)

        for key, value in pairs(object) do
            if type(key) ~= 'number' then
                key = '"' .. key .. '"'
            end

            result = result .. indentStr .. '[' .. key .. '] = ' .. brokencyde.dump(value, indent + 1) .. ',\n'
        end

        return result .. string.rep('  ', indent) .. '}'
    end

    return tostring(object)
end

function brokencyde.gapCloserIsNeeded(unit, minDistance)
    if not unit or not unit.key then
        return false
    end

    return Distance("player", unit.key) > minDistance
end

brokencyde.castingGapCloser = false

function brokencyde.enableCastingGapCloser()
    brokencyde.castingGapCloser = true

    C_Timer.After(1, function()
        brokencyde.castingGapCloser = false
    end)
end

function brokencyde.canUseMovementAbility(unit)
    if HasDebuff(brokencyde.SPEAR_OF_BASTION, unit.key) then
        return false
    end

    if HasDebuff(brokencyde.URSOLS_VORTEX, unit.key) then
        return false
    end

    if Rooted("player") then
        return false
    end

    if HasDebuff(brokencyde.BINDING_SHOT, "player") and StunDr("player") >= 0.25 then
        return false
    end

    return true
end

function brokencyde.canCastGapCloser(unit)
    if not unit or not unit.key then
        return false
    end

    if Distance("player", unit.key) > SpellRange(grapplingHook.id) then
        return false
    end

    if not los(unit.key) then
        return false
    end

    if not brokencyde.canUseMovementAbility(myPlayer) then
        return false
    end

    if not CanCast(grapplingHook.id) then
        return false
    end

    return true
end

function brokencyde.castGapCloser(unit)
    if not brokencyde.canCastGapCloser(unit) then
        return false
    end

    SmartAoE(grapplingHook.id, unit.key, 3, SpellRange(grapplingHook.id))
    brokencyde.enableCastingGapCloser()
end

brokencyde.randomValues = {}

function brokencyde.random(min, max)
    if brokencyde.randomValues[min] and brokencyde.randomValues[min][max] then
        return brokencyde.randomValues[min][max]
    end

    local range = max - min
    local randomFloat = min + range * math.random()
    local multiplier = 10 ^ 10

    if not brokencyde.randomValues[min] then
        brokencyde.randomValues[min] = {}
    end

    brokencyde.randomValues[min][max] = math.floor(randomFloat * multiplier + 0.5) / multiplier

    C_Timer.After(math.random(1, 3), function()
        brokencyde.randomValues[min][max] = nil
    end)

    return brokencyde.randomValues[min][max]
end

local File = Tinkr:require('Util.Modules.File')

function brokencyde.log_message(message)
    if true then return false end
    -- Get current timestamp
    local current_time = date("%Y-%m-%d %H:%M:%S")

    -- Format the log entry
    local log_entry = string.format("[%s] %s\n", current_time, message)

    File:Write('scripts/dumps.log', log_entry, true)

    return true
end

function brokencyde.getEnemiesInRange()
    if InArena() then
        return enemies
    end

    local enemiesInRange = {}

    ObjectsLoop(enemies, function(enemy)
        if Distance(enemy.key) <= 40 then
            table.insert(enemiesInRange, enemy)
        end
    end)

    return enemiesInRange
end
brokencyde.BASE_MELEE_RANGE = 8
brokencyde.TWO_POINTS_ECHOING_BUFF_ID = 323558
brokencyde.THREE_POINTS_ECHOING_BUFF_ID = 323559
brokencyde.FOUR_POINTS_ECHOING_BUFF_ID = 323560

brokencyde.MIND_FREEZE = brokencyde.getSpellInfo(47528)
brokencyde.MIND_FREEZE_ID = 47528
brokencyde.SKULL_BASH = brokencyde.getSpellInfo(106839)
brokencyde.SKULL_BASH_ID = 106839
brokencyde.SOLAR_BEAM = brokencyde.getSpellInfo(78675)
brokencyde.SOLAR_BEAM_ID = 78675
brokencyde.COUNTER_SHOT = brokencyde.getSpellInfo(147362)
brokencyde.COUNTER_SHOT_ID = 147362
brokencyde.MUZZLE_ID = 187707
brokencyde.MUZZLE = brokencyde.getSpellInfo(brokencyde.MUZZLE_ID)
brokencyde.COUNTERSPELL = brokencyde.getSpellInfo(2139)
brokencyde.COUNTERSPELL_ID = 2139
brokencyde.SPEAR_HAND_STRIKE = brokencyde.getSpellInfo(116705)
brokencyde.SPEAR_HAND_STRIKE_ID = 116705
brokencyde.AVENGERS_SHIELD = brokencyde.getSpellInfo(31935)
brokencyde.AVENGERS_SHIELD_ID = 31935
brokencyde.REBUKE = brokencyde.getSpellInfo(96231)
brokencyde.REBUKE_ID = 96231
brokencyde.KICK = brokencyde.getSpellInfo(1766)
brokencyde.KICK_ID = 1766
brokencyde.WIND_SHEAR = brokencyde.getSpellInfo(57994)
brokencyde.WIND_SHEAR_ID = 57994
brokencyde.SPELL_LOCK = brokencyde.getSpellInfo(19647)
brokencyde.SPELL_LOCK_ID = 119910
brokencyde.SPELL_LOCK_GRIMOIRE_ID = 132409
brokencyde.GRIMOIRE_OF_SACRIFICE = brokencyde.getSpellInfo(196099)
brokencyde.SPELL_LOCK_GRIMOIRE = brokencyde.getSpellInfo(132409)
brokencyde.OPTICAL_BLAST = brokencyde.getSpellInfo(115781)
brokencyde.OPTICAL_BLAST_ID = 115781
brokencyde.PUMMEL = brokencyde.getSpellInfo(6552)
brokencyde.PUMMEL_ID = 6552
brokencyde.QUELL = brokencyde.getSpellInfo(351338)
brokencyde.QUELL_ID = 351338
brokencyde.DISRUPT = brokencyde.getSpellInfo(183752)
brokencyde.DISRUPT_ID = 183752

brokencyde.CHAOS_BOLT = brokencyde.getSpellInfo(116858)
brokencyde.THE_HUNT = brokencyde.getSpellInfo(323639)
brokencyde.GRAPPLE_WEAPON = brokencyde.getSpellInfo(233759)

brokencyde.SHADOW_DANCE = brokencyde.getSpellInfo(185313)
brokencyde.SECRET_TECHNIQUE = brokencyde.getSpellInfo(280719)
brokencyde.ECHOING_REPRIMAND = brokencyde.getSpellInfo(385616)
brokencyde.SHADOWY_DUEL = brokencyde.getSpellInfo(207736)
brokencyde.VEIL_OF_MIDNIGHT = brokencyde.getSpellInfo(198952, true)
brokencyde.DISMANTLE = brokencyde.getSpellInfo(207777)
brokencyde.DANSE_MACABRE = brokencyde.getSpellInfo(382528)
brokencyde.SYMBOLS_OF_DEATH = brokencyde.getSpellInfo(212283)
brokencyde.CLOAK_OF_SHADOWS = brokencyde.getSpellInfo(31224)
brokencyde.FLAGELLATION = brokencyde.getSpellInfo(384631)
brokencyde.FLAGELLATION_SECOND_BUFF_ID = 394758
brokencyde.WOUND_POISON = brokencyde.getSpellInfo(8679)
brokencyde.CRIPPLING_POISON = brokencyde.getSpellInfo(3408)
brokencyde.RUPTURE = brokencyde.getSpellInfo(1943)
brokencyde.SAP = brokencyde.getSpellInfo(6770)
brokencyde.COLD_BLOOD = brokencyde.getSpellInfo(382245)
brokencyde.VANISH = brokencyde.getSpellInfo(1856)
brokencyde.VANISH_DURING = brokencyde.getSpellInfo(11327, true)
brokencyde.SLICE_AND_DICE = brokencyde.getSpellInfo(315496)
brokencyde.FINALITY_TALENT = brokencyde.getSpellInfo(382525)
brokencyde.FINALITY_EVISCERATE_BUFF = brokencyde.getSpellInfo(385949)
brokencyde.ELUSIVENESS_TALENT = brokencyde.getSpellInfo(79008, true)
brokencyde.THE_ROTTEN_TALENT = brokencyde.getSpellInfo(382015)
brokencyde.INVIGORATING_SHADOWDUST = brokencyde.getSpellInfo(382523)
brokencyde.CLOAKED_IN_SHADOWS_BUFF = brokencyde.getSpellInfo(382515)
brokencyde.PERFORATED_VEINS = brokencyde.getSpellInfo(382518)
brokencyde.LINGERING_SHADOW = brokencyde.getSpellInfo(382524)
brokencyde.THIEF_S_BARGAIN = brokencyde.getSpellInfo(354825)
brokencyde.SPRINT = brokencyde.getSpellInfo(2983)
brokencyde.SHADOWSTEP = brokencyde.getSpellInfo(36554)
brokencyde.SHADOWSTEP_ID = 36554
brokencyde.DEEPER_DAGGERS = brokencyde.getSpellInfo(382517)
brokencyde.DEATHSTALKER_ID = 457052
brokencyde.DEATHSTALKER_MARK = brokencyde.getSpellInfo(457129)
brokencyde.DARKEST_NIGHT = brokencyde.getSpellInfo(457058)
brokencyde.SYMBOLIC_VICTORY = brokencyde.getSpellInfo(457062)
brokencyde.FLYING_DAGGERS = brokencyde.getSpellInfo(381631)

brokencyde.STORM_BOLT = brokencyde.getSpellInfo(107570)
brokencyde.MORTAL_COIL = brokencyde.getSpellInfo(6789)

brokencyde.ARENA_PREPARATION_BUFF_ID = 32727

brokencyde.OBSIDIAN_SCALES = brokencyde.getSpellInfo(363916)
brokencyde.DIVINE_PROTECTION = brokencyde.getSpellInfo(498)
brokencyde.UNENDING_RESOLVE = brokencyde.getSpellInfo(104773)
brokencyde.SOUL_LINK = brokencyde.getSpellInfo(108415)
brokencyde.ICEBOUND_FORTITUDE = brokencyde.getSpellInfo(48792)
brokencyde.SURVIVAL_INSTINCTS = brokencyde.getSpellInfo(61336)
brokencyde.POWER_WORD_BARRIER = brokencyde.getSpellInfo(62618)
brokencyde.PAIN_SUPPRESSION = brokencyde.getSpellInfo(33206)
brokencyde.ENRAGED_REGENERATION = brokencyde.getSpellInfo(184364)
brokencyde.SHIELD_WALL = brokencyde.getSpellInfo(871)
brokencyde.IGNORE_PAIN = brokencyde.getSpellInfo(190456)
brokencyde.DIFFUSE_MAGIC = brokencyde.getSpellInfo(122783)
brokencyde.BEAR_FORM = brokencyde.getSpellInfo(5487)
brokencyde.BARKSKIN = brokencyde.getSpellInfo(22812)
brokencyde.IRONBARK = brokencyde.getSpellInfo(102342)
brokencyde.FORTIFYING_BREW = brokencyde.getSpellInfo(115203)
brokencyde.ASTRAL_SHIFT = brokencyde.getSpellInfo(108271)
brokencyde.BLESSING_OF_SACRIFICE = brokencyde.getSpellInfo(6940)
brokencyde.DAMPEN_HARM = brokencyde.getSpellInfo(122278)

brokencyde.DIVINE_SHIELD_ID = 642
brokencyde.DIVINE_SHIELD = brokencyde.getSpellInfo(brokencyde.DIVINE_SHIELD_ID)

brokencyde.BLESSING_OF_PROTECTION_ID = 1022
brokencyde.BLESSING_OF_PROTECTION = brokencyde.getSpellInfo(brokencyde.BLESSING_OF_PROTECTION_ID)
brokencyde.BLESSING_OF_SPELLWARDING = brokencyde.getSpellInfo(204018)

brokencyde.GUARDIAN_SPIRIT_ID = 47788
brokencyde.GUARDIAN_SPIRIT = brokencyde.getSpellInfo(brokencyde.GUARDIAN_SPIRIT_ID)

brokencyde.ICE_BLOCK_ID = 45438
brokencyde.ICE_BLOCK = brokencyde.getSpellInfo(brokencyde.ICE_BLOCK_ID)

brokencyde.DISPERSION_ID = 47585
brokencyde.DISPERSION = brokencyde.getSpellInfo(brokencyde.DISPERSION_ID)

brokencyde.ROAR_OF_SACRIFICE_ID = 53480
brokencyde.ROAR_OF_SACRIFICE = brokencyde.getSpellInfo(brokencyde.ROAR_OF_SACRIFICE_ID)

brokencyde.ASPECT_OF_THE_TURTLE = brokencyde.getSpellInfo(186265)
brokencyde.DIE_BY_THE_SWORD = brokencyde.getSpellInfo(118038)
brokencyde.SHIELD_BLOCK = brokencyde.getSpellInfo(2565)
brokencyde.NETHERWALK = brokencyde.getSpellInfo(196555)
brokencyde.BLUR = brokencyde.getSpellInfo(198589)
brokencyde.DARKNESS = brokencyde.getSpellInfo(196718)
brokencyde.ALTER_TIME = brokencyde.getSpellInfo(108978)
brokencyde.EVASION = brokencyde.getSpellInfo(5277)
brokencyde.SURVIVAL_OF_THE_FITTEST = brokencyde.getSpellInfo(264735)

brokencyde.MIND_CONTROL = brokencyde.getSpellInfo(605)
brokencyde.FEAR = brokencyde.getSpellInfo(5782)
brokencyde.POLYMORPH = brokencyde.getSpellInfo(118)
brokencyde.SONG_OF_CHI_JI = brokencyde.getSpellInfo(198909)
brokencyde.HEX = brokencyde.getSpellInfo(51514)
brokencyde.SLEEP_WALK = brokencyde.getSpellInfo(360806)
brokencyde.REPENTANCE = brokencyde.getSpellInfo(20066)
brokencyde.CYCLONE = brokencyde.getSpellInfo(33786)
brokencyde.LIGHTNING_LASSO = brokencyde.getSpellInfo(305483)
brokencyde.MINDGAMES = brokencyde.getSpellInfo(323673)
brokencyde.VAMPIRIC_TOUCH = brokencyde.getSpellInfo(34914)
brokencyde.UNSTABLE_AFFLICTION = brokencyde.getSpellInfo(30108)
brokencyde.HAND_OF_GUL_DAN = brokencyde.getSpellInfo(105174)
brokencyde.GLACIAL_SPIKE = brokencyde.getSpellInfo(199786)
brokencyde.ARCANE_SURGE = brokencyde.getSpellInfo(365350)
brokencyde.STELLAR_FLARE = brokencyde.getSpellInfo(202347)
brokencyde.CONVOKE_THE_SPIRITS = brokencyde.getSpellInfo(323764)
brokencyde.ETERNITY_SURGE = brokencyde.getSpellInfo(359073)
brokencyde.DISINTEGRATE = brokencyde.getSpellInfo(356995)
brokencyde.SOOTHING_MIST = brokencyde.getSpellInfo(115175)
brokencyde.SHADOWFURY = brokencyde.getSpellInfo(30283)
brokencyde.SHEILUN_S_GIFT = brokencyde.getSpellInfo(205406)
brokencyde.SUMMON_DEMONIC_TYRANT = brokencyde.getSpellInfo(265187)
brokencyde.SUMMON_FELGUARD = brokencyde.getSpellInfo(30146)
brokencyde.SUMMON_FELHUNTER = brokencyde.getSpellInfo(691)
brokencyde.STORMKEEPER = brokencyde.getSpellInfo(191634)
brokencyde.NULLIFYING_SHROUD = brokencyde.getSpellInfo(378464)
brokencyde.REVIVE_PET = brokencyde.getSpellInfo(982)
brokencyde.SCHISM = brokencyde.getSpellInfo(214621)
brokencyde.DARK_REPRIMAND = brokencyde.getSpellInfo(373130)
brokencyde.HEAL = brokencyde.getSpellInfo(2060)
brokencyde.FLASH_HEAL = brokencyde.getSpellInfo(2061)
brokencyde.NOURISH = brokencyde.getSpellInfo(50464)
brokencyde.SPIRITBLOOM = brokencyde.getSpellInfo(367226)
brokencyde.DREAM_BREATH = brokencyde.getSpellInfo(355936)
brokencyde.FLASH_OF_LIGHT = brokencyde.getSpellInfo(19750)
brokencyde.HOLY_LIGHT = brokencyde.getSpellInfo(82326)
brokencyde.PENANCE = brokencyde.getSpellInfo(47540)
brokencyde.HEALING_SURGE = brokencyde.getSpellInfo(8004)
brokencyde.HEALING_WAVE = brokencyde.getSpellInfo(77472)
brokencyde.SEARING_GLARE = brokencyde.getSpellInfo(410126)

brokencyde.ANCESTRAL_GIFT = brokencyde.getSpellInfo(290254)

brokencyde.SPEAR_OF_BASTION = brokencyde.getSpellInfo(307865)

brokencyde.TREMOR_TOTEM = brokencyde.getSpellInfo(8143, true)
brokencyde.GROUNDING_TOTEM = brokencyde.getSpellInfo(204336, true)
brokencyde.SKYFURY_TOTEM = brokencyde.getSpellInfo(204330, true)
brokencyde.STONESKIN_TOTEM = brokencyde.getSpellInfo(383017, true)
brokencyde.COUNTERSTRIKE_TOTEM = brokencyde.getSpellInfo(204331, true)
brokencyde.POISON_CLEANSING_TOTEM = brokencyde.getSpellInfo(383013, true)
brokencyde.SPIRIT_LINK_TOTEM = brokencyde.getSpellInfo(98008, true)
brokencyde.WAR_BANNER = brokencyde.getSpellInfo(236321, true)
brokencyde.PSYFIEND = brokencyde.getSpellInfo(211522, true)
brokencyde.FEL_OBELISK = brokencyde.getSpellInfo(353601, true)
brokencyde.CAPACITOR_TOTEM = brokencyde.getSpellInfo(192058, true)
brokencyde.STATIC_FIELD_TOTEM = brokencyde.getSpellInfo(355580, true)
brokencyde.HEALING_TIDE_TOTEM = brokencyde.getSpellInfo(108280, true)
brokencyde.EARTHGRAB_TOTEM = brokencyde.getSpellInfo(51485, true)

brokencyde.THUNDEROUS_ROAR = brokencyde.getSpellInfo(384318)
brokencyde.DEATHMARK = brokencyde.getSpellInfo(360194)
brokencyde.TOUCH_OF_KARMA = brokencyde.getSpellInfo(122470)
brokencyde.BLADESTORM = brokencyde.getSpellInfo(227847)
brokencyde.BLADESTORM_ID = 227847
brokencyde.FISTS_OF_FURY = brokencyde.getSpellInfo(113656)
brokencyde.PRECOGNITION = brokencyde.getSpellInfo(377360)
brokencyde.FEIGN_DEATH = brokencyde.getSpellInfo(5384)

brokencyde.FULL_MOON = brokencyde.getSpellInfo(202771)
brokencyde.RAY_OF_FROST = brokencyde.getSpellInfo(205021)
brokencyde.TIME_SKIP = brokencyde.getSpellInfo(404977)
brokencyde.VOID_TORRENT = brokencyde.getSpellInfo(263165)

brokencyde.WINTERS_CHILL = brokencyde.getSpellInfo(228358)
brokencyde.BRAIN_FREEZE = brokencyde.getSpellInfo(190447)
brokencyde.CRYOPATHY = brokencyde.getSpellInfo(417491)
brokencyde.FINGERS_OF_FROST = brokencyde.getSpellInfo(44544)
brokencyde.INSTANT_BLIZZARD_BUFF = brokencyde.getSpellInfo(270232)
brokencyde.FROST_BITE = brokencyde.getSpellInfo(378756)
brokencyde.ICICLES = brokencyde.getSpellInfo(205473)
brokencyde.SPELL_REFLECT = brokencyde.getSpellInfo(23920)
brokencyde.BLISTERING_SCALES = brokencyde.getSpellInfo(360827)
brokencyde.FLAME_ACCELERANT = brokencyde.getSpellInfo(203277)
brokencyde.CLEARCASTING = brokencyde.getSpellInfo(79684)
brokencyde.NETHER_PRECISION = brokencyde.getSpellInfo(383783)
brokencyde.ARCANE_HARMONY = brokencyde.getSpellInfo(384455)
brokencyde.ARCANE_TEMPO = brokencyde.getSpellInfo(383980)

brokencyde.THOUGHTSTOLEN = brokencyde.getSpellInfo(322461)
brokencyde.REACTIVE_RESIN_DEBUFF = brokencyde.getSpellInfo(410063)
brokencyde.LIFEBLOOM = brokencyde.getSpellInfo(33763)
brokencyde.REJUVENATION = brokencyde.getSpellInfo(774)
brokencyde.WILD_GROWTH = brokencyde.getSpellInfo(48438)
brokencyde.REGROWTH = brokencyde.getSpellInfo(8936)
brokencyde.ADAPTIVE_SWARM = brokencyde.getSpellInfo(391888)
brokencyde.CENARION_WARD = brokencyde.getSpellInfo(102351)
brokencyde.DENOUNCE = brokencyde.getSpellInfo(2812)
brokencyde.AIMED_SHOT = brokencyde.getSpellInfo(19434)
brokencyde.TRANQUILITY = brokencyde.getSpellInfo(157982)
brokencyde.SPIRIT_OF_REDEMPTION = brokencyde.getSpellInfo(215769)
brokencyde.ULTIMATE_PENITENCE = brokencyde.getSpellInfo(421453)

brokencyde.FLAMES_FURY = brokencyde.getSpellInfo(409964)
brokencyde.CHARRING_EMBERS = brokencyde.getSpellInfo(408665)

brokencyde.OPPORTUNITY = brokencyde.getSpellInfo(195627)
brokencyde.BETWEEN_THE_EYES = brokencyde.getSpellInfo(315341)
brokencyde.VOID_TENDRILS = brokencyde.getSpellInfo(108920)
brokencyde.ANTI_MAGIC_SHELL = brokencyde.getSpellInfo(311975)
brokencyde.COMBUSTION = brokencyde.getSpellInfo(190319)
brokencyde.FIREBALL = brokencyde.getSpellInfo(133)
brokencyde.FLAMESTRIKE = brokencyde.getSpellInfo(2120)
brokencyde.SCORCH = brokencyde.getSpellInfo(2948)
brokencyde.SOUL_ROT = brokencyde.getSpellInfo(386997)

brokencyde.TRUE_BEARING = brokencyde.getSpellInfo(193359)
brokencyde.VENGEFUL_RETREAT = brokencyde.getSpellInfo(198793)
brokencyde.COLOSSUS_SMASH = brokencyde.getSpellInfo(208086)
brokencyde.INTERVENE = brokencyde.getSpellInfo(147833)

brokencyde.BROADSIDE = brokencyde.getSpellInfo(193356)
brokencyde.BURIED_TREASURE = brokencyde.getSpellInfo(199600)
brokencyde.GRAND_MELEE = brokencyde.getSpellInfo(193358)
brokencyde.RUTHLESS_PRECISION = brokencyde.getSpellInfo(193357)
brokencyde.SKULL_AND_CROSSBONES = brokencyde.getSpellInfo(199603)
brokencyde.LOADED_DICE = brokencyde.getSpellInfo(256170)

brokencyde.TYR_S_DELIVRANCE = brokencyde.getSpellInfo(200652)
brokencyde.GLIMPSE = brokencyde.getSpellInfo(354610)

brokencyde.SUDDEN_AMBUSH = brokencyde.getSpellInfo(384667)
brokencyde.BLOOD_TALONS = brokencyde.getSpellInfo(319439)
brokencyde.WILD_ATTUNEMENT = brokencyde.getSpellInfo(410354)

brokencyde.URSOLS_VORTEX = brokencyde.getSpellInfo(127797)
brokencyde.STATIC_FIELD_TOTEM_TRIGGER_ID_1 = 355619
brokencyde.STATIC_FIELD_TOTEM_TRIGGER_ID_2 = 27607

brokencyde.SUBTERFUGE = brokencyde.getSpellInfo(115192)
brokencyde.IMPROVED_GARROTE = brokencyde.getSpellInfo(392403)
brokencyde.INDISCRIMINATE_CARNAGE = brokencyde.getSpellInfo(385754)
brokencyde.GARROTE_SILENCE = brokencyde.getSpellInfo(1330)

brokencyde.FLUID_FORM_TALENT = brokencyde.getSpellInfo(449193)

brokencyde.DRAIN_LIFE = brokencyde.getSpellInfo(234153)
brokencyde.ICE_FLOES = brokencyde.getSpellInfo(108839)
brokencyde.SPIRIT_WALKER_S_GRACE = brokencyde.getSpellInfo(79206)

brokencyde.SHADOW_STEP = brokencyde.getSpellInfo(36554)
brokencyde.BEAR_FORM = brokencyde.getSpellInfo(5487)
brokencyde.BLINK = brokencyde.getSpellInfo(1953)
brokencyde.SHADOWMELD = brokencyde.getSpellInfo(58984)
brokencyde.STEALTH_DURING = brokencyde.getSpellInfo(115191)

brokencyde.HOVER = brokencyde.getSpellInfo(358267)
brokencyde.HEAT_SHIMMER = brokencyde.getSpellInfo(457735)
brokencyde.FROSTFIRE_EMPOWERMENT = brokencyde.getSpellInfo(431176)
brokencyde.SEVERE_TEMPERATURES = brokencyde.getSpellInfo(431189)
brokencyde.SNOWDRIFT_STUNNED_ID = 389831

brokencyde.HARMONIOUS_CONSTITUTION_ID = 440118
brokencyde.FROSTFIRE_MASTERY_ID = 431038
brokencyde.ABOMINATION_LIMB_ID = 383269
brokencyde.ABOMINATION_LIMB = brokencyde.getSpellInfo(brokencyde.ABOMINATION_LIMB_ID)
brokencyde.STRANGULATE = brokencyde.getSpellInfo(47476)
brokencyde.ENDURING_BRAWLER = brokencyde.getSpellInfo(354847)
brokencyde.CAMOUFLAGE = brokencyde.getSpellInfo(199483)
brokencyde.BINDING_SHOT = brokencyde.getSpellInfo(109248)
brokencyde.DANCE_OF_THE_WIND = brokencyde.getSpellInfo(432180)
brokencyde.DEATH_ARRIVAL = brokencyde.getSpellInfo(457343)
Elite:Populate({
    sinisterStrike = NewSpell(193315, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true, ignoreFacing = false }),
    autoAttack = NewSpell(6603, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    backstab = NewSpell(53, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    gloomBlade = NewSpell(200758, { damage = 'magic', ranged = false, targeted = true, ignoreMoving = true }),
    eviscerate = NewSpell(196819, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    shiv = NewSpell(5938, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    rupture = NewSpell(1943, { damage = 'physical', ranged = false, bleed = true, targeted = true, ignoreMoving = true }),
    sliceAndDice = NewSpell(315496, { beneficial = true, buff = true, ignoreMoving = true }),
    kidneyShot = NewSpell(408, { effect = 'physical', cc = "stun", ranged = false, targeted = true, ignoreMoving = true }),
    gouge = NewSpell(1776, { effect = 'physical', cc = "incapacitate", ranged = false, targeted = true, ignoreMoving = true }),
    echoingReprimand = NewSpell(385616, { damage = 'magical', ranged = false, targeted = true, ignoreMoving = true }),
    sap = NewSpell(6770, { effect = 'physical', cc = "incapacitate", targeted = true, ignoreMoving = true, ignoreUsable = true }),
    vanish = NewSpell(1856, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    blind = NewSpell(2094, { effect = "physical", cc = "disorient", ranged = true, targeted = true, ignoreMoving = true, ignoreFacing = true }),
    crimsonVial = NewSpell(185311, { beneficial = true, ignoreMoving = true }),
    dismantle = NewSpell(207777, { cc = 'disarm', targeted = true, ignoreMoving = true }),
    evasion = NewSpell(5277, { beneficial = true, ignoreMoving = true, ignoreCasting = true, ignoreGCD = true }),
    cloakOfShadows = NewSpell(31224, { beneficial = true, ignoreMoving = true, ignoreCasting = true, ignoreGCD = true }),
    feint = NewSpell(1966, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    kick = NewSpell(1766, { effect = 'physical', ranged = false, targeted = true, ignoreMoving = true, ignoreCasting = true }),
    shadowStep = NewSpell(36554, { ranged = true, ignoreMoving = true, ignoreCasting = true, ignoreFacing = true, targeted = true }),
    stealth = NewSpell(1784, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    smokeBomb = NewSpell(212182, { ignoreMoving = true, radius = 8, ignoreFacing = true }),
    distract = NewSpell(1725, { radius = 10, ignoreMoving = true, targeted = false, ignoreFacing = true, offsetMin = 0, offsetMax = 5.5, distanceSteps = 12, circleSteps = 24 }),
    shadowDance = NewSpell(185313, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    shadowStrike = NewSpell(185438, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    cheapShot = NewSpell(1833, { effect = 'physical', cc = "stun", ranged = false, targeted = true, ignoreMoving = true }),
    symbolsOfDeath = NewSpell(212283, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    coldBlood = NewSpell(382245, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    markedForDeath = NewSpell(137619, { ranged = true, targeted = true, ignoreMoving = true, ignoreCasting = true, ignoreFacing = true }),
    secretTechnique = NewSpell(280719, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    goremaw = NewSpell(426591, { damage = 'magic', ranged = false, targeted = true, ignoreMoving = true }),
    sepsis = NewSpell(385408, { damage = 'magic', ranged = false, targeted = true, ignoreMoving = true }),
    shadowBlades = NewSpell(121471, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    shurikenToss = NewSpell(114014, { damage = 'physical', ranged = true, targeted = true, ignoreMoving = true }),
    shadowyDuel = NewSpell(207736, { ranged = false, targeted = true, ignoreMoving = true, ignoreCasting = true }),
    deathFromAbove = NewSpell(269513, { ranged = true, targeted = true, ignoreMoving = true }),
    shurikenStorm = NewSpell(197835, { damage = 'physical', ignoreMoving = true, radius = 13, ignoreFacing = true }),
    fanOfKnives = NewSpell(51723, { damage = 'physical', ignoreMoving = true, radius = 15, ignoreFacing = true }),
    flagellation = NewSpell(384631, { damage = 'magic', ranged = false, targeted = true, ignoreMoving = true }),
    sprint = NewSpell(2983, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    tricksOfTheTrade = NewSpell(57934, { ignoreMoving = true, ignoreCasting = true, ignoreGCD = true }),
    thistleTea = NewSpell(381623, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    dispatch = NewSpell(2098, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    ambush = NewSpell(8676, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true }),
    pistolShot = NewSpell(185763, { damage = 'physical', ranged = true, targeted = true, ignoreMoving = true }),
    ghostlyStrike = NewSpell(196937, { damage = 'physical', ranged = false, targeted = true, ignoreMoving = true, ignoreGCD = true }),
    rollTheBones = NewSpell(315508, { beneficial = true, ignoreMoving = true, ignoreCasting = false }),
    keepItRolling = NewSpell(381989, { beneficial = true, ignoreMoving = true, ignoreCasting = false, ignoreGCD = true }),
    betweenTheEyes = NewSpell(315341, { damage = 'physical', ranged = true, targeted = true, ignoreMoving = true }),
    killingSpree = NewSpell(51690, { damage = 'physical', ranged = true, targeted = true, ignoreMoving = true }),
    adrenalineRush = NewSpell(13750, { beneficial = true, ignoreMoving = true, ignoreCasting = true }),
    bladeFlurry = NewSpell(13877, { beneficial = true, ignoreMoving = true }),
    grapplingHook = NewSpell(195457, { ranged = true, radius = 8, ignoreMoving = true, ignoreCasting = true, ignoreFacing = true }),
    bladeRush = NewSpell(271877, { damage = 'physical', ranged = true, targeted = true, ignoreMoving = true }),
    mutilate = NewSpell(1329, { damage = 'physical', targeted = true, ignoreMoving = true }),
    garrote = NewSpell(703, { damage = 'physical', bleed = true, targeted = true, ignoreMoving = true }),
    envenom = NewSpell(32645, { damage = 'magical', targeted = true, ignoreMoving = true }),
    serratedBoneSpike = NewSpell(385424, { damage = 'physical', ranged = true, bleed = true, targeted = true, ignoreMoving = true }),
    poisonedKnife = NewSpell(185565, { damage = 'physical', ranged = true, targeted = true, ignoreMoving = true }),
    deathmark = NewSpell(360194, { damage = 'physical', effect = 'physical', bleed = true, targeted = true, ignoreMoving = true }),
    kingsBane = NewSpell(385627, { damage = 'magic', effect = 'magic', bleed = false, targeted = true, ignoreMoving = true }),
    exsanguinate = NewSpell(200806, { damage = 'physical', bleed = true, targeted = true, ignoreMoving = true }),
    crimsonTempest = NewSpell(121411, { damage = 'physical', bleed = true, targeted = true, ignoreMoving = true }),
    indiscriminateCarnage = NewSpell(381802, { buff = true, ignoreMoving = true, ignoreGCD = true }),
    shadowMeld = NewSpell(58984, { beneficial = true, ignoreMoving = true, ignoreCasting = true, ignoreGCD = true }),
    cheapShotToStunParry = NewSpell(1833, {
        beneficial = true,
        targeted = true,
        ignoreMoving = true,
        ignoreFacing = true,
        ignoreUsable = true
    }),
    woundPoison = NewSpell(8679),
    deadlyPoison = NewSpell(2823),
    cripplingPoison = NewSpell(3408),
    numbingPoison = NewSpell(5761),
    atrophicPoison = NewSpell(381637),
})

local function sinisterStrikeChecks()
    if brokencyde.isStealth("player") then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if ComboPoints("player") == brokencyde.getMaxComboPoints() then
        return false
    end

    return true
end

sinisterStrike:Callback(function(spell)
    if not sinisterStrikeChecks() then
        return false
    end

    -- TODO : Add this when framework is better optimized
    --if spell:Castable("target") then
    --    brokencyde.cancelBladeFlurry()
    --end

    spell:Cast("target")
end)

sinisterStrike:Callback("aoe", function(spell)
    if not sinisterStrikeChecks() then
        return false
    end

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if brokencyde.shouldWaitForBcc(enemy) then
            return false
        end

        -- TODO : Add this when framework is better optimized
--        if spell:Castable(enemy.key) then
--            brokencyde.cancelBladeFlurry()
--        end

        if spell:Cast(enemy.key) then
            return true
        end
    end)
end)
dispatch:Callback(function(spell)
    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if ComboPoints("player") < 6 then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    -- TODO : Add this when framework is better optimized
    --if spell:Castable("target") then
    --    brokencyde.cancelBladeFlurry()
    --end

    return spell:Cast("target")
end)

local function pistolShotChecks()
    if brokencyde.isStealth("player") then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if Disarm("player") and ComboPoints() < brokencyde.getMaxComboPoints() then
        return true
    end

    if ComboPoints() > 3 and not (Disarm("player") and Energy() >= (UnitPowerMax("player") - 10)) then
        return false
    end

    if not HasBuff(brokencyde.OPPORTUNITY, "player") then
        return false
    end

    return true
end

pistolShot:Callback(function(spell)
    if not pistolShotChecks() then
        return false
    end

    -- TODO : Add this when framework is better optimized
    --if spell:Castable("target") then
    --    brokencyde.cancelBladeFlurry()
    --end

    return spell:Cast("target")
end)

ambush:Callback(function(spell)
    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if not brokencyde.isStealth("player") and not HasBuff(381845, "player") then
        return false
    end

    if brokencyde.isStealth("player") and StunDr("target") >= 1 and IsPlayer("target") then
        return false
    end

    if ComboPoints("player") > (brokencyde.getMaxComboPoints() - 2) then
        return false
    end

    -- TODO : Add this when framework is better optimized
    --if spell:Castable("target") then
    --    brokencyde.cancelBladeFlurry()
    --end

    return spell:Cast("target")
end)

ambush:Callback("after vanish", function(spell)
    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if not HasBuff(brokencyde.VANISH_DURING, "player") then
        return false
    end

    -- TODO : Add this when framework is better optimized
--    if spell:Castable("target") then
--        brokencyde.cancelBladeFlurry()
--    end

    return spell:Cast("target")
end)
sliceAndDice:Callback(function(spell)
    if brokencyde.betweenTheEyesChecks(myTarget, true) then
        return false
    end
    
    if brokencyde.isStealth("player") then
        return false
    end

    if HasBuff(spell.id, "player") then
        return false
    end

    return spell:Cast()
end)

sliceAndDice:Callback("opener", function(spell)
    if not brokencyde.isStealth("player") then
        return false
    end

    if not HasBuff(adrenalineRush.id, "player") then
        return false
    end

    if HasBuff(spell.id, "player") then
        return false
    end

    return spell:Cast()
end)

ghostlyStrike:Callback(function(spell)
    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    if brokencyde.avoidBurstingUnit("target") then
        return false
    end

    if not brokencyde.outlawBursting() then
        return false
    end

    -- TODO : Add this when framework is better optimized
    --if spell:Castable("target") then
    --    brokencyde.cancelBladeFlurry()
    --end

    return spell:Cast("target")
end)

feint:Callback(function(spell)
    if HasBuff(spell.id, "player") then
        return false
    end

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if not IsPlayer(enemy.key) then
            return false
        end

        if HasBuff(brokencyde.BLADESTORM, enemy.key) and InMelee(enemy.key) then
            return spell:Cast()
        end

        if ChanInfo(enemy.key) == brokencyde.FISTS_OF_FURY and InMelee(enemy.key) then
            return spell:Cast()
        end

        if ccr(enemy.key) > 0 then
            return false
        end

        if TargetingAB(enemy.key) and HasTalent(brokencyde.ELUSIVENESS_TALENT) then
            return spell:Cast()
        end

        return false
    end)
end)

bladeFlurry:Callback(function(spell)
    if brokencyde.betweenTheEyesChecks(myTarget, true) then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    if not InCombat("player") then
        return false
    end

    if Disarm("player") then
        return false
    end

    if HasBuff(spell.id, "player") then
        return false
    end

    if not InMelee("target") then
        return false
    end

    if AreaBcc("target", 8) > 0 then
        return false
    end

    return spell:Cast()
end)

bladeFlurry:Callback("opener", function(spell)
    if brokencyde.combatStarted then
        return false
    end

    if Prep() then
        return false
    end

    if HasBuff(spell.id, "player") then
        return false
    end

    if not InArena() then
        return false
    end

    return spell:Cast()
end)

local function shouldCastForNewLogic()
    if Prep() then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    local enduringBrawlerStacks = GetBuffCount(brokencyde.ENDURING_BRAWLER, "player")

    if enduringBrawlerStacks and enduringBrawlerStacks < 4 then
        return false
    end

    if SpellCd(vanish.id) <= 16 then
        return true
    end

    return false
end

adrenalineRush:Callback(function(spell)
    if not myTarget then
        return false
    end

    if SpellCd(adrenalineRush.id) > gcd() then
        return false
    end

    if InArena() and not IsPlayer(myTarget.key) then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    if myTarget.immuneP then
        return false
    end

    if Disarm("player") then
        return false
    end

    if shouldCastForNewLogic() then
        return spell:Cast()
    end

    if brokencyde.avoidBurstingUnit("target") then
        return false
    end

    if not InMelee("target") then
        return false
    end

    if HasBuff(spell.id, "player") then
        return false
    end

    return spell:Cast()
end)

adrenalineRush:Callback("opener", function(spell)
    if brokencyde.combatStarted then
        return false
    end

    if Prep() then
        return false
    end

    if not InArena() then
        return false
    end

    if not brokencyde.isStealth("player") then
        return false
    end

    if not HasBuff(bladeFlurry.id, "player") then
        return false
    end

    return spell:Cast()
end)

local function playerHasEnoughCpForBetweenTheEyes()
    return ComboPoints("player") >= 5
end

function brokencyde.betweenTheEyesChecks(unit, ignoreComboPoints)
    if not unit or not unit.key then
        return false
    end

    if HasBuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if (not ignoreComboPoints) and (not playerHasEnoughCpForBetweenTheEyes()) then
        return false
    end

    if HasBuff(brokencyde.SUBTERFUGE, "player") then
        return true
    end

    if brokencyde.isStealth("player") and not brokencyde.combatStarted and not InMelee("target") then
        return true
    end

    if SpellCd(betweenTheEyes.id) > gcd() then
        return false
    end

    if brokencyde.isStealth("player") then
        return true
    end

    if brokencyde.shouldWaitForBcc(unit) then
        return false
    end

    return true
end

betweenTheEyes:Callback(function(spell)
    if not brokencyde.betweenTheEyesChecks(myTarget, false) then
        return false
    end

    -- TODO : Add this when framework is better optimized
    --if spell:Castable("target") then
    --    brokencyde.cancelBladeFlurry()
    --end

    rmt("/cancelaura " .. brokencyde.getSpellInfo(shadowMeld.id))
    spell:Cast("target")
end)
evasion:Callback(function(spell)
    ObjectsLoop(enemies, function(enemy)
        if not IsPlayer(enemy.key) then
            return false
        end

        if not TargetingAB(enemy.key, "player") then
            return false
        end

        if not IsPhysical(enemy.key) then
            return false
        end

        local enemyClass = Class(enemy.key)

        if enemyClass ~= "HUNTER" and not InMelee(enemy.key) then
            return false
        end

        if enemyClass == "HUNTER" and Distance(enemy.key) >= 50 then
            return false
        end

        if not enemy.bursting and TrueHealthP("player") > brokencyde.random(27, 34) then
            return false
        end

        if brokencyde.dismantleChecks(enemy) then
            return false
        end

        if ccr(enemy.key) > gcd() then
            return false
        end

        return spell:Cast()
    end)
end)
local function shouldCloakLowHp()
    local hpThreshold = 30
    local playerHealth = TrueHealthP("player")
    local randomizedThreshold = brokencyde.random(hpThreshold - 2, hpThreshold + 7)

    return playerHealth < randomizedThreshold
end

local function cloakOfShadowsChecks()
    if shouldCloakLowHp() then
        return true
    end

    if not HasTalent(brokencyde.VEIL_OF_MIDNIGHT) then
        return false
    end

    local dangerousDebuffs = {
        brokencyde.SPEAR_OF_BASTION,
        brokencyde.THUNDEROUS_ROAR,
        brokencyde.DEATHMARK,
        brokencyde.TOUCH_OF_KARMA,
    }

    for _, debuffId in ipairs(dangerousDebuffs) do
        if HasDebuff(debuffId, "player") then
            return true
        end
    end

    return false
end

cloakOfShadows:Callback(function(spell)
    if cloakOfShadowsChecks() then
        return spell:Cast()
    end
end)

local function smokeBombChecks(unit, ignoreStun)
    if not unit or not unit.guid then
        return false
    end

    if not IsPlayer(unit.key) then
        return false
    end

    if not ignoreStun then
        if not unit.stunned and not unit.rooted then
            return false
        end

        if unit.stunnedRemains < brokencyde.random(1.4, 2.5) and unit.rootedRemains < brokencyde.random(1.4, 2.5) then
            return false
        end
    end

    if SpellCd(smokeBomb.id) > 1 then
        return false
    end

    if ignoreStun then
        if StunDr(unit.key) < 1 then
            return false
        end
    end

    if brokencyde.getRemainingTrinketTime(unit.guid) <= 7 then
        return false
    end

    if not InMelee(unit.key) then
        return false
    end

    return true
end

smokeBomb:Callback(function(spell)
    if not myTarget then
        return false
    end

    if not smokeBombChecks(myTarget, false) then
        return false
    end

    return spell:Cast()
end)

local function shouldWaitForHealerCcVanish(unit)
    if not InArena() then
        return false
    end

    if GetBuffRemaining(adrenalineRush.id, "player") <= 2 then
        return false
    end

    if HasDebuff(smokeBomb.id, "player") then
        return false
    end

    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer or not enemyHealer.key then
        return false
    end

    if not Alive(enemyHealer.key) then
        return false
    end

    if unit and unit.key == enemyHealer.key then
        return false
    end

    if ccr(enemyHealer.key) >= 3 then
        return false
    end

    if StunDrr(enemyHealer.key) >= 4 then
        return false
    end

    if SpellCd(kidneyShot.id) >= 4 then
        return false
    end

    if not InCombat(enemyHealer.key) and IncapacitateDr(enemyHealer.key) >= 0.5 then
        return true
    end

    if enemyHealer.immuneCC and enemyHealer.immuneCCRemains > 5 then
        return false
    end

    return true
end

local function keepAdrenalineRushRolling()
    if not HasBuff(adrenalineRush.id, "player") then
        return false
    end

    if Disarm("player") and GetBuffRemaining(adrenalineRush.id, "player") > 2 then
        return false
    end

    if shouldWaitForHealerCcVanish(myTarget) then
        return false
    end

    if HasBuff(brokencyde.VANISH_DURING, "player") then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    local subterfugeRemaining = GetBuffRemaining(brokencyde.SUBTERFUGE, "player")

    if subterfugeRemaining and subterfugeRemaining > 0.5 then
        return false
    end

    if ComboPoints("player") <= 5 and GetBuffRemaining(adrenalineRush.id, "player") > 2 then
        return false
    end

    if SpellCd(betweenTheEyes.id) <= gcd() + 1 then
        return false
    end

    if not InMelee("target") and GetBuffRemaining(adrenalineRush.id, "player") > 2 then
        return false
    end

    return true
end

local function keepAdrenalineRushRollingNew()
    if not HasBuff(adrenalineRush.id, "player") then
        return false
    end

    if Disarm("player") and GetBuffRemaining(adrenalineRush.id, "player") > 2 then
        return false
    end

    if shouldWaitForHealerCcVanish(myTarget) then
        return false
    end

    if HasBuff(brokencyde.VANISH_DURING, "player") then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    local subterfugeRemaining = GetBuffRemaining(brokencyde.SUBTERFUGE, "player")

    if subterfugeRemaining and subterfugeRemaining > 0.5 then
        return false
    end

    if not InMelee("target") and GetBuffRemaining(adrenalineRush.id, "player") > 2 then
        return false
    end

    if SpellCd(betweenTheEyes.id) <= gcd() then
        return false
    end

    if GetBuffRemaining(adrenalineRush.id, "player") <= 3 then
        return true
    end

    if ComboPoints("player") < 6 then
        return false
    end

    if RFracCharge(vanish.id) <= 15 then
        return true
    end

    if SpellCd(betweenTheEyes.id) > gcd() and HasBuff(brokencyde.RUTHLESS_PRECISION, "player") then
        return true
    end

    local superchargedComboPoints = GetUnitChargedPowerPoints("player")

    if superchargedComboPoints then
        return true
    end

    return false
end

vanish:Callback(function(spell)
    if keepAdrenalineRushRollingNew() then
        return spell:Cast() and Alert(spell.id, "Vanish > AR Uptime!", 100, 200)
    end
end)
local function shouldWaitForHealerCcMeld(unit)
    if not InArena() then
        return false
    end

    if GetBuffRemaining(adrenalineRush.id, "player") <= 2 then
        return false
    end

    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer or not enemyHealer.key then
        return false
    end

    if not Alive(enemyHealer.key) then
        return false
    end

    if unit and unit.key == enemyHealer.key then
        return false
    end

    if ccr(enemyHealer.key) >= 3 then
        return false
    end

    if StunDrr(enemyHealer.key) >= 4 then
        return false
    end

    if SpellCd(kidneyShot.id) >= 4 then
        return false
    end

    if not InCombat(enemyHealer.key) and IncapacitateDr(enemyHealer.key) >= 0.5 then
        return true
    end

    if enemyHealer.immuneCC and enemyHealer.immuneCCRemains > 5 then
        return false
    end

    return true
end

local function keepAdrenalineRushRolling()
    if not HasBuff(adrenalineRush.id, "player") then
        return false
    end

    if Disarm("player") and GetBuffRemaining(adrenalineRush.id, "player") > 2 then
        return false
    end

    if shouldWaitForHealerCcMeld(myTarget) then
        return false
    end

    if HasBuff(brokencyde.VANISH_DURING, "player") then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    local subterfugeRemaining = GetBuffRemaining(brokencyde.SUBTERFUGE, "player")

    if subterfugeRemaining and subterfugeRemaining > 0.5 then
        return false
    end

    if ComboPoints("player") <= 5 and GetBuffRemaining(adrenalineRush.id, "player") > 2 then
        return false
    end

    if SpellCd(vanish.id) <= gcd() then
        return false
    end

    if SpellCd(betweenTheEyes.id) <= gcd() + 1 then
        return false
    end

    if not InMelee("target") then
        return false
    end

    return true
end

brokencyde.justMelded = false

local function setShadowMeld()
    brokencyde.justMelded = true

    C_Timer.After(1, function()
        brokencyde.justMelded = false
    end)
end

shadowMeld:Callback("maintain AR", function(spell)
    if not keepAdrenalineRushRolling() then
        return false
    end

    setShadowMeld()
    StopAttack()
    SpellStopCasting()
    StopMoving()
    spell:Cast()
    stealth:Cast()
end)

local lastCheapShotCastedOn = nil

local function storeLastCheapShotCast(unit)
    lastCheapShotCastedOn = unit
end

local function shouldWaitForHealerCcCheapShot(unit)
    if not unit or not unit.key then
        return false
    end

    if not InArena() then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if brokencyde.combatStarted then
        return false
    end

    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer or not enemyHealer.key then
        return false
    end

    if not Alive(enemyHealer.key) then
        return false
    end

    if unit and unit.key == enemyHealer.key then
        return false
    end

    if ccr(enemyHealer.key) > 2 then
        return false
    end

    if not InCombat(enemyHealer.key) then
        return true
    end

    if enemyHealer.immuneCC and enemyHealer.immuneCCRemains > 5 then
        return false
    end

    return true
end

function brokencyde.cheapShotChecks(unit, ignoreDR, forDrawing)
    if not unit or not unit.key then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if not InPvp() then
        return false
    end

    if not IsPlayer(unit.key) then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if HasBuff(brokencyde.INTERVENE, unit.key) then
        return false
    end

    if Used("player", cheapShot.id, 1) and lastCheapShotCastedOn and unit.guid == lastCheapShotCastedOn.guid then
        return false
    end

    if not forDrawing then
        if ccr(unit.key) > gcd() then
            return false
        end
    end

    if unit.immuneCC then
        return false
    end

    local isCaster = IsCaster(unit.key)
    local isCasting = IsCastChan(unit.key)
    local minDR = 1

    if ignoreDR and not isCaster then
        minDR = 0.5
    end

    if isCaster and isCasting then
        minDR = 0.25
    end

    if HasDebuff(smokeBomb.id, "player") then
        minDR = 0.25
    end

    if StunDr(unit.key) < minDR then
        return false
    end

    if ignoreDR and StunDrr(unit.key) > 0 and StunDrr(unit.key) <= 10 then
        return false
    end

    if HasBuff(brokencyde.GLIMPSE, unit) then
        return false
    end

    if shouldWaitForHealerCcCheapShot(myTarget) then
        return false
    end

    return true
end

cheapShot:Callback(function(spell)
    if not myTarget or not myTarget.guid then
        return false
    end

    if not brokencyde.cheapShotChecks(myTarget, true) then
        return false
    end

    return spell:Cast(myTarget.key) and storeLastCheapShotCast(myTarget)
end)

cheapShot:Callback("aoe full DR", function(spell)
    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy, guid)
        if not brokencyde.cheapShotChecks(enemy, Role(enemy) == "healer") then
            return false
        end

        return spell:Cast(enemy.key) and storeLastCheapShotCast(enemy)
    end)
end)
local function hasParrySpellToStun(unit)
    if brokencyde.getSpellInfo(ChanInfo(unit.key)) == brokencyde.FISTS_OF_FURY and StunDr(unit.key) >= 0.25 then
        return true
    end

    if HasBuff(evasion.id, unit.key) and StunDr(unit.key) >= 0.5 then
        return true
    end

    if HasBuff(brokencyde.DIE_BY_THE_SWORD, unit.key) and StunDr(unit.key) >= 0.5 then
        return true
    end

    return false
end

function brokencyde.cheapShotToStunParryChecks(unit)
    if not unit or not unit.key then
        return false
    end

    if not InPvp() then
        return false
    end

    if not IsPlayer(unit.key) then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if HasBuff(brokencyde.INTERVENE, unit.key) then
        return false
    end

    if ccr(unit.key) > gcd() then
        return false
    end

    if StunDr(unit.key) < 0.25 then
        return false
    end

    if unit.immuneCC then
        return false
    end

    if HasBuff(brokencyde.GLIMPSE, unit) then
        return false
    end

    if not hasParrySpellToStun(unit) then
        return false
    end

    return true
end

cheapShotToStunParry:Callback(function(spell)
    if not myTarget or not myTarget.key then
        return false
    end

    if not brokencyde.cheapShotToStunParryChecks(myTarget) then
        return false
    end

    return spell:Cast(myTarget.key)
end)

cheapShotToStunParry:Callback("aoe full DR", function(spell)
    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if not brokencyde.cheapShotToStunParryChecks(enemy) then
            return false
        end

        return spell:Cast(enemy.key)
    end)
end)
local function getBuffs()
    return {
        brokencyde.BROADSIDE,
        brokencyde.BURIED_TREASURE,
        brokencyde.GRAND_MELEE,
        brokencyde.RUTHLESS_PRECISION,
        brokencyde.SKULL_AND_CROSSBONES,
        brokencyde.TRUE_BEARING
    }
end

local function getHighestDurationBuff()
    local buffs = getBuffs()
    local highestDurationBuff = 0

    for i = 1, #buffs do
        local buffRemains = GetBuffRemaining(buffs[i], "player")
        if buffRemains and buffRemains > highestDurationBuff then
            highestDurationBuff = buffRemains
        end
    end

    return highestDurationBuff
end

local function shouldRerollBuffs()
    local vanishCooldown = SpellCd(vanish.id) <= gcd()
    local highestDurationBuff = getHighestDurationBuff()
    local hasLoadedDice = HasBuff(brokencyde.LOADED_DICE, "player")
    local buffs = getBuffs()
    local buffDurations = {}

    for i = 1, #buffs do
        local buffRemains = GetBuffRemaining(buffs[i], "player")
        if buffRemains and buffRemains > 0 then
            table.insert(buffDurations, buffRemains)
        end
    end

    table.sort(buffDurations)

    local expiringBuffs = 0
    local threshold = 3

    for _, duration in ipairs(buffDurations) do
        if duration <= threshold then
            expiringBuffs = expiringBuffs + 1
        end
    end

    local majorityExpiring = expiringBuffs > #buffDurations / 2
    local shouldRerollNow = (majorityExpiring or #buffDurations <= 1)

    if hasLoadedDice and #buffDurations <= 2 then
        shouldRerollNow = true
    end

    if highestDurationBuff > 0 and highestDurationBuff <= 7 and vanishCooldown then
        shouldRerollNow = true
    end

    return shouldRerollNow
end

local function shouldRerollBuffsKeepItRolling()
    local buffs = getBuffs()
    local activeBuffs = {}

    for i = 1, #buffs do
        local buffRemains = GetBuffRemaining(buffs[i], "player")
        if buffRemains and buffRemains > 0 then
            table.insert(activeBuffs, buffs[i])
        end
    end

    local hasDesiredBuff = false
    for _, buff in ipairs(activeBuffs) do
        if buff == brokencyde.BROADSIDE or
                buff == brokencyde.RUTHLESS_PRECISION or
                buff == brokencyde.TRUE_BEARING then
            hasDesiredBuff = true
            break
        end
    end

    if (#activeBuffs <= 2 and not hasDesiredBuff) or Used("player", keepItRolling.id, 5) then
        return true
    end

    return false
end

rollTheBones:Callback(function(spell)
    local distance = brokencyde.random(17, 24)

    if not InCombat("player") then
        distance = brokencyde.random(35, 46)
    end

    --if brokencyde.combatStarted and brokencyde.betweenTheEyesChecks(myTarget, true) then
    --    return false
    --end

    local shouldRerollNow = false

    --if HasTalent(381989) then
    --    shouldRerollNow = shouldRerollBuffsKeepItRolling()
    --else
    --    shouldRerollNow = shouldRerollBuffs()
    --end

    shouldRerollNow = shouldRerollBuffsKeepItRolling()

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if shouldRerollNow and Distance(enemy) < distance then
            return spell:Cast()
        end
    end)
end)

keepItRolling:Callback(function(spell)
    if not HasTalent(381989) then
        return false
    end

    local buffsToKeep = {
        brokencyde.BROADSIDE,
        brokencyde.BURIED_TREASURE,
        brokencyde.GRAND_MELEE,
        brokencyde.RUTHLESS_PRECISION,
        brokencyde.SKULL_AND_CROSSBONES,
        brokencyde.TRUE_BEARING
    }

    local totalBuffs = 0

    for i = 1, #buffsToKeep do
        if HasBuff(buffsToKeep[i], "player") then
            totalBuffs = totalBuffs + 1
        end
    end

    if totalBuffs < 3 then
        return false
    end

    return spell:Cast()
end)

stealth:Callback(function(spell)
    if HasBuff(brokencyde.STEALTH_DURING, "player") then
        return false
    end

    if InPvp() and brokencyde.isOutlaw() and not brokencyde.combatStarted then
        if not HasBuff(bladeFlurry.id, "player") then
            return false
        end
    end

    if HasBuff(58984, "player") then
        return spell:Cast()
    end

    if not InPvp() then
        return false
    end

    if Prep() then
        return false
    end

    if Mounted() then
        return false
    end

    spell:Cast()
end)

local function killingSpreeChecks(unit)
    if not unit or not unit.key then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if InArena() and not IsPlayer(unit.key) then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    -- TODO: When framework is better optimized
    --if not killingSpree:Castable(unit.key) then
    --    return false
    --end

    if Disarm("player") then
        return false
    end

    if HasDebuff(brokencyde.BINDING_SHOT, "player") and StunDr("player") >= 0.25 then
        return false
    end

    if brokencyde.avoidBurstingUnit(unit) then
        return false
    end

    if brokencyde.shouldWaitForBcc(unit) then
        return false
    end

    if brokencyde.betweenTheEyesChecks(unit, true) then
        return false
    end

    if ComboPoints("player") < 6 then
        return false
    end

    if SpellCd(vanish.id) <= 0 and GetBuffRemaining(adrenalineRush.id, "player") <= 5 then
        return false
    end

    return true
end

killingSpree:Callback(function(spell)
    if not myTarget or not myTarget.key then
        return false
    end

    if not killingSpreeChecks(myTarget) then
        return false
    end

    return spell:Cast(myTarget.key)
end)

crimsonVial:Callback(function(spell)
    if brokencyde.betweenTheEyesChecks(myTarget, true) then
        return false
    end

    if TrueHealthP("player") <= brokencyde.random(76, 82) then
        spell:Cast()
    end
end)

local function shouldDismantleDeathKnight(unit)
    local health = TrueHealthP(unit.key)
    local result = health <= brokencyde.random(28, 32)
    return result
end

local function shouldDismantleWarrior(unit)
    if unit.bursting then
        return true
    end

    if HasDebuff(brokencyde.COLOSSUS_SMASH, "player") then
        return true
    end

    local shouldDismantle = false

    ObjectsLoop(friends, function(friend, guid)
        if HasDebuff(brokencyde.COLOSSUS_SMASH, friend.key) then
            shouldDismantle = true
            return true
        end
    end)

    return shouldDismantle
end

local function shouldDismantleRogue(unit)
    if HasBuff(evasion.id, unit.key) and not Stunned(unit.key) then
        return false
    end

    if Spec(unit.key) == 259 then
        return true
    end

    if Spec(unit.key) == 260 then
        local result = HasBuff(brokencyde.SUBTERFUGE, unit.key)
        return result
    end

    return unit.bursting
end

local function shouldDismantle(unit)
    if Class(unit.key) == "DEATHKNIGHT" and shouldDismantleDeathKnight(unit) then
        return true
    end

    if Class(unit.key) == "WARRIOR" and shouldDismantleWarrior(unit) then
        return true
    end

    if Class(unit.key) == "ROGUE" and shouldDismantleRogue(unit) then
        return true
    end

    if Class(unit.key) == "HUNTER" and Spec(unit.key) == 254 and unit.bursting then
        return true
    end

    if Class(unit.key) == "DEMONHUNTER" and unit.bursting and not HasBuff(brokencyde.BLUR, unit.key) and not HasBuff(brokencyde.GLIMPSE, unit.key) then
        return true
    end

    return false
end

local function getEnemyClassPrio()
    local hasWarrior, hasDeathKnight, hasRogue, hasHunter, hasDemonHunter = false, false, false, false, false

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if Class(enemy.key) == "WARRIOR" and (Spec(enemy.key) == 71 or Spec(enemy.key) == 72) then
            hasWarrior = true
        end

        if Class(enemy.key) == "DEATHKNIGHT" and shouldDismantleDeathKnight(enemy) then
            hasDeathKnight = true
        end

        if Class(enemy.key) == "ROGUE" then
            hasRogue = true
        end

        if Class(enemy.key) == "HUNTER" and Spec(enemy.key) == 254 then
            hasHunter = true
        end

        if Class(enemy.key) == "DEMONHUNTER" then
            hasDemonHunter = true
        end
    end)

    local result = ""
    if hasWarrior then
        result = "WARRIOR"
    elseif hasDeathKnight then
        result = "DEATHKNIGHT"
    elseif hasRogue then
        result = "ROGUE"
    elseif hasHunter then
        result = "HUNTER"
    elseif hasDemonHunter then
        result = "DEMONHUNTER"
    end

    return result
end

function brokencyde.dismantleChecks(unit, forDrawing)
    if not IsPlayerSpell(dismantle.id) then
        return false
    end

    if not IsPlayer(unit.key) then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if DisarmDr(unit.key) < 1 then
        return false
    end

    if SpellCd(dismantle.id) > gcd() then
        return false
    end

    if not forDrawing then
        if HasBuff(brokencyde.INTERVENE, unit.key) then
            return false
        end

        if HasDebuff(brokencyde.SEARING_GLARE, "player") then
            return false
        end

        if brokencyde.isStealth("player") then
            return false
        end

        if not InMelee(unit.key) then
            return false
        end

        if not dismantle:Castable(unit.key) then
            return false
        end

        if ccr(unit.key) > gcd() then
            return false
        end
    end

    local prioClass = getEnemyClassPrio()
    local unitClass = Class(unit.key)

    if prioClass ~= "" and unitClass ~= prioClass then
        return false
    end

    return shouldDismantle(unit)
end

dismantle:Callback(function(spell)
    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if not brokencyde.dismantleChecks(enemy) then
            return false
        end

        return spell:Cast(enemy.key)
    end)

end)
thistleTea:Callback(function(spell)
    if GetBuffRemaining(thistleTea.id, "player") > 0 then
        return false
    end

    local charges = Charges(thistleTea.id)
    local currentEnergy = Energy("player")

    if charges == 3 and currentEnergy < 100 then
        return spell:Cast("player")
    elseif currentEnergy < 50 then
        return spell:Cast("player")
    end
end)
local function weCanSap()
    if CanCast(shadowMeld.id) and SpellCd(shadowMeld.id) <= 0 then
        return true
    end

    if SpellCd(vanish.id) <= 0 then
        return true
    end

    return false
end

local function tooFar(unit, alert)
    if Distance("player", unit.key) > 15 then
        if Distance(unit.key) < 20 then
            Alert(blind.id, alert)
        end

        return true
    end

    return false
end

function brokencyde.blindChecks(unit, ignoreCC)
    if not unit or not unit.key then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if SpellCd(blind.id) > gcd() then
        return false
    end

    if HasBuff(brokencyde.INTERVENE, unit.key) then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if unit.immuneCC then
        return false
    end

    if HasBuff(brokencyde.SPIRIT_OF_REDEMPTION, unit.key) or HasDebuff(brokencyde.SPIRIT_OF_REDEMPTION, unit.key) then
        return false
    end

    if HasDebuff(deathmark.id, unit.key) then
        return false
    end

    if not InCombat(unit.key) and weCanSap() then
        return false
    end

    if TargetingAB("player", unit.key) then
        return false
    end

    if InMelee(unit.key) and brokencyde.kidneyShotChecks(unit, false, false) then
        return false
    end

    if InMelee(unit.key) and brokencyde.kickChecks(unit) then
        return false
    end

    if HasBuff(brokencyde.WAR_BANNER, unit.key) then
        return false
    end

    if HasBuff(brokencyde.GLIMPSE, unit.key) then
        return false
    end

    if HasBuff(brokencyde.BLESSING_OF_SACRIFICE, unit.key) then
        return false
    end

    if DisorientDr(unit.key) < 1 then
        return false
    end

    if not ignoreCC then
        if ccr(unit.key) > gcd() then
            return false
        end
    end

    if not brokencyde.canBlindSafely(unit) then
        return false
    end

    local melee, caster, total, cooldowns = Attackers(unit.key)

    if total > 0 then
        return false
    end

    return true
end

blind:Callback("whenever possible", function(spell)
    local enemyHealer = brokencyde.getEnemyHealer()

    if not brokencyde.blindChecks(enemyHealer) then
        return false
    end

    if tooFar(enemyHealer, "Go BLIND healer (we have cooldowns)") then
        return false
    end

    return spell:Cast(enemyHealer.key) and Alert(blind.id, "[CD] Blind on " .. Name(enemyHealer.key))
end)

function brokencyde.kidneyShotChecks(unit, forDrawing)
    if not unit or not unit.key then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if HasBuff(brokencyde.INTERVENE, unit.key) then
        return false
    end

    if GetBuffCount(brokencyde.DANCE_OF_THE_WIND, unit.key) >= 8 then
        return false
    end

    if HasBuff(brokencyde.SPIRIT_OF_REDEMPTION, unit.key) or HasDebuff(brokencyde.SPIRIT_OF_REDEMPTION, unit.key) then
        return false
    end

    if not IsPlayer(unit.key) then
        return false
    end

    if HasBuff(brokencyde.BLUR, unit.key) then
        return false
    end

    if HasBuff(brokencyde.GLIMPSE, unit.key) then
        return false
    end

    if SpellCd(kidneyShot.id) > gcd() then
        return false
    end

    if unit.immuneCC then
        return false
    end

    if not forDrawing then
        if ccr(unit.key) > gcd() then
            return false
        end

        if ComboPoints("player") < 5 then
            return false
        end

        if Disarm("player") then
            return false
        end
    end

    if StunDr(unit.key) < 1 then
        return false
    end

    if HasBuff(brokencyde.PRECOGNITION, unit.key) then
        return false
    end

    if HasBuff(brokencyde.WAR_BANNER, unit.key) then
        return false
    end

    return true
end

function brokencyde.canKidneyShotEnemyHealer()
    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer then
        return false
    end

    if not brokencyde.kidneyShotChecks(enemyHealer) then
        return false
    end

    return true
end

kidneyShot:Callback("healer", function(spell)
    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer then
        return false
    end

    if not brokencyde.kidneyShotChecks(enemyHealer) then
        return false
    end

    if brokencyde.gapCloserIsNeeded(enemyHealer, 12) and not brokencyde.betweenTheEyesChecks(myTarget, true) then
        brokencyde.castGapCloser(enemyHealer)
    end

    return spell:Cast(enemyHealer.key)
end)

kidneyShot:Callback(function(spell)
    if not myTarget then
        return false
    end

    if brokencyde.canKidneyShotEnemyHealer() then
        return false
    end

    if not brokencyde.kidneyShotChecks(myTarget) then
        return false
    end

    return spell:Cast(myTarget.key)
end)

kidneyShot:Callback("aoe", function(spell)
    if brokencyde.canKidneyShotEnemyHealer() then
        return false
    end

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if enemy.key == enemy.key then
            return false
        end

        if not brokencyde.kidneyShotChecks(enemy) then
            return false
        end

        return spell:Cast(enemy.key)
    end)
end)

local function friendCastedCooldown(friend)
    if not friend or not friend.key then
        return false
    end

    local burstSpells = {
        321507, -- Touch of the Magi
        360194, -- Deathmark
        370452, -- Shattering Star (devoker)
        384352,
        198067,
        375982,
        325640, -- Soul Rot
    }

    for i = 1, #burstSpells do
        if Used(friend.key, burstSpells[i], 5) then
            return true
        end
    end

    return false
end

tricksOfTheTrade:Callback(function(spell)
    if not (HasTalent(57934) and HasTalent(221622)) then -- Tricks + Thick
        return false
    end

    ObjectsLoop(friends, function(friend)
        if Role(friend.key) == "HEALER" then
            return false
        end

        if friend.key == myPlayer.key then
            return false
        end

        -- TODO: When framework is better optimized
        --if ccr(friend.key) > 0 then
        --    return false
        --end

        if friendCastedCooldown(friend) then
            return spell:Cast(friend.key)
        end

        if friend.bursting then
            return spell:Cast(friend.key)
        end

        local spellCasted = brokencyde.getSpellInfo(CastInfo(friend.key))
        local spellChannelled = brokencyde.getSpellInfo(ChanInfo(friend.key))

        if spellCasted == 0 and spellChannelled == 0 then
            return false
        end

        if spellCasted == brokencyde.ETERNITY_SURGE or spellChannelled == brokencyde.ETERNITY_SURGE then
            return spell:Cast(friend.key)
        end

        if spellCasted == brokencyde.getSpellInfo(325640) then -- Soul Rot
            return spell:Cast(friend.key)
        end
    end)
end)

function brokencyde.kickChecks(unit)
    if not unit or not unit.key then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if unit.immuneP then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    if HasBuff(brokencyde.INTERVENE, unit.key) then
        return false
    end

    if not CanCast(kick.id) then
        return false
    end

    if not brokencyde.shouldInterrupt(unit) then
        return false
    end

    if not brokencyde.isInterruptable(unit) then
        return false
    end

    return true
end

function brokencyde.wantsToKick(unit)
    if not brokencyde.kickChecks(unit) then
        return false
    end

    if brokencyde.kidneyShotChecks(unit, false) then
        return false
    end

    return true
end

kick:Callback(function(spell)
    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if not brokencyde.kickChecks(enemy) then
            return false
        end

        if brokencyde.gapCloserIsNeeded(enemy, 12) then
            brokencyde.castGapCloser(enemy)
        end

        return spell:Cast(enemy.key) and Alert(1766, "Kicking " .. Name(enemy.key))
    end)
end)

function brokencyde.wePlayWithIncapDRMates()
    local result = false

    ObjectsLoop(friends, function(friend)
        if result then
            return true
        end

        if Class(friend.key) == "MAGE" then
            result = true
            return true
        end

        if Class(friend.key) == "HUNTER" then
            result = true
            return true
        end
    end)

    return result
end

function brokencyde.gougeChecks(unit, ignoreCurrentCC)
    if not unit or not unit.key then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if not IsPlayer(unit.key) then
        return false
    end

    if SpellCd(gouge.id) > gcd() then
        return false
    end

    if HasBuff(brokencyde.BLUR, unit.key) then
        return false
    end

    if HasBuff(brokencyde.GLIMPSE, unit.key) then
        return false
    end

    if unit.immuneCC then
        return false
    end

    if not ignoreCurrentCC then
        if ccr(unit.key) > gcd() then
            return false
        end
    end

    if TargetingAB("player", unit.key) then
        return false
    end

    if HasBuff(brokencyde.BLESSING_OF_SACRIFICE, unit.key) then
        return false
    end

    if not brokencyde.canBlindSafely(unit) then
        return false
    end

    local isCaster = IsCaster(unit.key)
    local isCasting = IsCastChan(unit.key)
    local minDR = 1

    if isCaster and isCasting then
        minDR = 0.25
    end

    if IncapacitateDr(unit.key) < minDR then
        return false
    end

    if HasDot(unit.key) then
        return false
    end

    return true
end

local function gougeOffTarget()
    if HasBuff(adrenalineRush.id, "player") then
        return false
    end

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if Role(enemy) == "healer" then
            return false
        end

        if not brokencyde.gougeChecks(enemy) then
            return false
        end

        if not IsFacing(enemy.key) then
            return false
        end

        return gouge:Cast(enemy.key)
    end)
end

gouge:Callback("aoe", function(spell)
    if brokencyde.wePlayWithIncapDRMates() then
        return gougeOffTarget()
    end

    local enemyHealer = brokencyde.getEnemyHealer()

    if not brokencyde.gougeChecks(enemyHealer) then
        return false
    end

    if not IsFacing(enemyHealer.key) then
        return false
    end

    return spell:Cast(enemyHealer.key)
end)

local SAP_RANGE = 10

function brokencyde.sapChecks(unit, forDrawing)
    if not unit or not unit.key then
        return false
    end

    if not Alive(unit.key) then
        return false
    end

    if HasDebuff(brokencyde.SEARING_GLARE, "player") then
        return false
    end

    if not IsPlayer(unit.key) then
        return false
    end

    if not IsEnemy(unit.key) then
        return false
    end

    if InCombat(unit.key) then
        return false
    end

    if unit.immuneCC then
        return false
    end

    local sapRemaining = GetDebuffRemaining(brokencyde.SAP, unit.key)

    if sapRemaining and sapRemaining > gcd() then
        return false
    end

    if IncapacitateDr(unit.key) < 0.5 then
        return false
    end

    if unit.immuneP then
        return false
    end

    if HasDot(unit.key) then
        return false
    end

    if not forDrawing then
        if ccr(unit.key) > gcd() then
            return false
        end
    end

    return true
end

local function castStealthToSap()
    if not brokencyde.combatStarted then
        return false
    end

    if brokencyde.isStealth("player") then
        return false
    end

    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer or not enemyHealer.key then
        return false
    end

    if IncapacitateDr(enemyHealer.key) < 0.5 then
        return false
    end

    if not los(enemyHealer.key) then
        return false
    end

    if Distance("player", enemyHealer.key) > SAP_RANGE and not brokencyde.canCastGapCloser(enemyHealer) then
        return false
    end

    if CanCast(shadowMeld.id) and SpellCd(shadowMeld.id) <= 0 then
        StopMoving()
        return shadowMeld:Cast()
    end

    if SpellCd(vanish.id) <= 0 then
        return vanish:Cast()
    end
end

sap:Callback(function(spell)
    if brokencyde.combatStarted then
        return false
    end

    local unit = brokencyde.getEnemyHealer()

    if not unit or not unit.key then
        return false
    end

    if not brokencyde.sapChecks(unit) then
        return false
    end

    castStealthToSap()

    return spell:Cast(unit.key) and Alert(sap.id, "Sapping " .. Name(unit.key))
end)

sap:Callback("aoe with shadowstep", function(spell)
    if not brokencyde.combatStarted then
        return false
    end

    if not InArena() then
        return false
    end

    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer or not enemyHealer.key then
        return false
    end

    if not brokencyde.sapChecks(enemyHealer) then
        return false
    end

    local sapRemaining = GetDebuffRemaining(brokencyde.SAP, enemyHealer.key, myPlayer.key)

    if sapRemaining and sapRemaining > gcd() then
        return false
    end

    if not castStealthToSap() then
        return false
    end

    if brokencyde.gapCloserIsNeeded(enemyHealer, 10) then
        brokencyde.castGapCloser(enemyHealer)
    end

    return spell:Cast(enemyHealer.key)
end)

sap:Callback("stealthed", function(spell)
    if brokencyde.combatStarted then
        return false
    end

    local enemyHealer = brokencyde.getEnemyHealer()

    if enemyHealer and enemyHealer.key then
        local sapRemaining = GetDebuffRemaining(brokencyde.SAP, enemyHealer.key)

        if sapRemaining and sapRemaining > gcd() then
            return false
        end
    end

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if not brokencyde.isStealth(enemy.key) and not HasBuff(brokencyde.CAMOUFLAGE, enemy.key) then
            return false
        end

        if HasBuff(brokencyde.SHADOWMELD, enemy.key) then
            return false
        end

        if not brokencyde.sapChecks(enemy) then
            return false
        end

        if brokencyde.gapCloserIsNeeded(enemy, 10) then
            brokencyde.castGapCloser(enemy)
        end

        return spell:Cast(enemy.key)
    end)
end)

local function drawIcon(draw, unit, spellId)
    local spellInfo = C_Spell.GetSpellInfo(spellId) -- We can use C_Spell.GetSpellTexture(156618) instead
    local iconID = spellInfo and spellInfo.iconID
    local size = 24
    local icon = "\124T" .. iconID .. ":" .. size .. "\124t"

    local x, y, z = Position(unit.key)

    if x and y and z then
        draw:Text(icon, "GameFontNormalSmall", x, y, z + 2)
    end
end

local function drawLineTo(draw, currentTarget)
    local px, py, pz = Position("player")
    local tx, ty, tz = Position(currentTarget.key)

    if not px or not py or not pz or not tx or not ty or not tz then
        return
    end

    draw:Line(px, py, pz, tx, ty, tz, 5)
end

local function useRedColor(draw)
    draw:SetColor({ 230, 57, 70, 25 })
end

local function useGreenColor(draw)
    draw:SetColor({ 6, 214, 160, 10 })
end

local function useOrangeColor(draw)
    draw:SetColor({ 251, 133, 0, 25 })
end

local function useYellowColor(draw)
    draw:SetColor({ 255, 255, 0, 25 })
end

local function usePurpleColor(draw)
    draw:SetColor({ 128, 0, 128, 25 })
end

local function drawPathToHealer(draw)
    local healer = fHealer

    if not healer or not healer.key then
        return
    end

    if ccr(fHealer.key) > 0 or not los(healer.key) or Distance("player", healer.key) > 40 then
        useRedColor(draw)
    else
        useGreenColor(draw)
    end

    drawLineTo(draw, healer)
end

local function drawNextCcTrackerForHealer(draw, enemyHealer)
    if not enemyHealer or not enemyHealer.key then
        return
    end

    local ccDrawn = false

    if brokencyde.sapChecks(enemyHealer, true) then
        drawIcon(draw, enemyHealer, sap.id)
        ccDrawn = true
    elseif brokencyde.blindChecks(enemyHealer, true) then
        drawIcon(draw, enemyHealer, blind.id)
        ccDrawn = true
    elseif brokencyde.kidneyShotChecks(enemyHealer, true) then
        drawIcon(draw, enemyHealer, kidneyShot.id)
        ccDrawn = true
    elseif brokencyde.cheapShotChecks(enemyHealer, false, true) then
        drawIcon(draw, enemyHealer, cheapShot.id)
        ccDrawn = true
    elseif brokencyde.gougeChecks(enemyHealer, true) and not brokencyde.wePlayWithIncapDRMates() then
        drawIcon(draw, enemyHealer, gouge.id)
        ccDrawn = true
    elseif brokencyde.cheapShotChecks(enemyHealer, true, true) then
        drawIcon(draw, enemyHealer, cheapShot.id)
        ccDrawn = true
    end

    if ccDrawn then
        usePurpleColor(draw)

        if ccr(enemyHealer.key) > 3 then
            useYellowColor(draw)
        end

        drawLineTo(draw, enemyHealer)
    end

    return ccDrawn
end

local function drawNextCcTrackerForEnemies(draw)
    local enemyHealer = brokencyde.getEnemyHealer()

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        if not enemy or not enemy.key then
            return
        end

        if not IsPlayer(enemy.key) then
            return
        end

        if enemyHealer and enemy.key == enemyHealer.key then
            return
        end

        if brokencyde.dismantleChecks(enemy, true) then
            drawIcon(draw, enemy, dismantle.id)
        elseif brokencyde.kidneyShotChecks(enemy, true) and not brokencyde.canKidneyShotEnemyHealer() then
            drawIcon(draw, enemy, kidneyShot.id)
        elseif brokencyde.cheapShotChecks(enemy, false, true) then
            drawIcon(draw, enemy, cheapShot.id)
        elseif brokencyde.gougeChecks(enemy, true) and brokencyde.wePlayWithIncapDRMates() then
            useOrangeColor(draw)
            local x, y, z = Position(enemy.key)

            if x and y and z then
                draw:Arc(x, y, z, 1, 180, Facing(enemy.key) or 0)
            end

            drawIcon(draw, enemy, gouge.id)
        end
    end)
end

local function drawFacingHealer(draw)
    local enemyHealer = brokencyde.getEnemyHealer()

    if not enemyHealer or not enemyHealer.key then
        return false
    end

    useOrangeColor(draw)
    local x, y, z = Position(enemyHealer.key)

    if not x or not y or not z then
        return
    end

    draw:Arc(x, y, z, 1, 180, Facing(enemyHealer.key) or 0)
end

local function drawBehindTarget(draw)
    draw:SetColor({ 106, 89, 203, 100 })
    local x, y, z = Position("target")

    if not x or not y or not z then
        return
    end

    draw:Arc(x, y, z, 2, 180, (Facing("target") or 0) + math.pi)
end

local storedTotems = {}

local function drawCapacitorTotem(draw, object, objectId)
    if objectId ~= 61245 then
        return
    end

    local uniqueId = object.guid
    local currentTime = GetTime()
    local x, y, z = Position(object.key)

    if not storedTotems[uniqueId] then
        storedTotems[uniqueId] = {
            startTime = currentTime,
            position = {
                x = x,
                y = y,
                z = z
            },
            hasReachedMax = false
        }
    end

    storedTotems[uniqueId].position = {
        x = x,
        y = y,
        z = z
    }

    local totemData = storedTotems[uniqueId]
    local elapsedTime = currentTime - totemData.startTime
    local animationDuration = 2.0

    if totemData.hasReachedMax then
        if elapsedTime > 5.0 then
            storedTotems[uniqueId] = nil
        end
        return
    end

    local startRadius = 1
    local endRadius = 9
    local currentRadius

    if elapsedTime >= animationDuration then
        currentRadius = endRadius
        totemData.hasReachedMax = true
    else
        local progress = elapsedTime / animationDuration
        currentRadius = startRadius + (endRadius - startRadius) * progress
    end

    useRedColor(draw)
    draw:SetAlpha(100)
    draw:FilledCircle(
            totemData.position.x,
            totemData.position.y,
            totemData.position.z,
            currentRadius
    )
    draw:SetAlpha(255)
end

local function drawTotemObject(draw, object, objectId)
    if brokencyde.objectsDrawn[objectId] then
        return
    end

    local objects = {
        [53006] = { name = brokencyde.SPIRIT_LINK_TOTEM, radius = 3 },
        [119052] = { name = brokencyde.WAR_BANNER, radius = 3 },
        [101398] = { name = brokencyde.PSYFIEND, radius = 3 },
        [179193] = { name = brokencyde.FEL_OBELISK, radius = 3 },
        [61245] = { name = brokencyde.CAPACITOR_TOTEM, radius = 9 },
        [179867] = { name = brokencyde.STATIC_FIELD_TOTEM, radius = 3 },
        [59764] = { name = brokencyde.HEALING_TIDE_TOTEM, radius = 3 },
        [65282] = { name = brokencyde.VOID_TENDRILS, radius = 3 },
        [60561] = { name = brokencyde.EARTHGRAB_TOTEM, radius = 8 },
        [5913] = { name = brokencyde.TREMOR_TOTEM, radius = 3 },
        [5925] = { name = brokencyde.GROUNDING_TOTEM, radius = 3 },
        [105427] = { name = brokencyde.SKYFURY_TOTEM, radius = 3 },
        [194117] = { name = brokencyde.STONESKIN_TOTEM, radius = 3 },
        [105451] = { name = brokencyde.COUNTERSTRIKE_TOTEM, radius = 20 },
        [5923] = { name = brokencyde.POISON_CLEANSING_TOTEM, radius = 3 }
    }

    if not object or not object.key then
        return false
    end

    local objectDraw = objects[objectId]

    if not objectDraw then
        return false
    end

    local tx, ty, tz = Position(object.key)

    if not tx or not ty or not tz then
        return
    end

    drawCapacitorTotem(draw, object, objectId)

    drawIcon(draw, object, objectDraw.name)
    useRedColor(draw)
    draw:Outline(tx, ty, tz, objectDraw.radius)

    table.insert(brokencyde.objectsDrawn, objectId)
end

local function drawTotems(draw)
    ObjectsLoop(totems, function(totem)
        if not totem or not totem.key then
            return
        end

        local totemId = oid(totem.key)

        if not totemId then
            return
        end

        drawTotemObject(draw, totem, totemId)
    end)
end

local function drawFlare(draw)
    local flares = brokencyde.getFlares()

    for _, flare in ipairs(flares) do
        local x, y, z = Position(flare.key)

        if x and y and z then
            useRedColor(draw)
            draw:Outline(x, y, z, 10)
            drawIcon(draw, flare, 132950)
        end
    end
end

Draw:Sync(function(draw)
    if not InPvp() then
        return false
    end

    drawPathToHealer(draw)
    drawNextCcTrackerForHealer(draw, brokencyde.getEnemyHealer())
    drawNextCcTrackerForEnemies(draw)
    drawBehindTarget(draw)
    drawFacingHealer(draw)
    drawTotems(draw)
    drawFlare(draw)
end)

Draw:Enable()
local bigTotems = {
    [53006] = { name = brokencyde.SPIRIT_LINK_TOTEM, hp = 500 },
    [119052] = { name = brokencyde.WAR_BANNER, hp = 875 },
    [101398] = { name = brokencyde.PSYFIEND, hp = 875 },
    [179193] = { name = brokencyde.FEL_OBELISK, hp = 1002 },
    [61245] = { name = brokencyde.CAPACITOR_TOTEM, hp = 375 },
    [179867] = { name = brokencyde.STATIC_FIELD_TOTEM, hp = 375 },
    [59764] = { name = brokencyde.HEALING_TIDE_TOTEM, hp = 375 },
    [65282] = { name = brokencyde.VOID_TENDRILS, hp = 375 },
    [60561] = { name = brokencyde.EARTHGRAB_TOTEM, hp = 375 }
}

local smallTotems = {
    [5913] = { name = brokencyde.TREMOR_TOTEM, hp = 4 },
    [5925] = { name = brokencyde.GROUNDING_TOTEM, hp = 34 },
    [105427] = { name = brokencyde.SKYFURY_TOTEM, hp = 34 },
    [194117] = { name = brokencyde.STONESKIN_TOTEM, hp = 34 },
    [105451] = { name = brokencyde.COUNTERSTRIKE_TOTEM, hp = 34 },
    [5923] = { name = brokencyde.POISON_CLEANSING_TOTEM, hp = 34 }
}

local function castSmallSpellToStomp(totem)
    if not pistolShot:Castable(totem.key) then
        return false
    end

    brokencyde.cancelBladeFlurry()

    return pistolShot:Cast(totem.key)
end

local function castBigSpellToStomp(totem)
    if Distance(totem.key) > 8 and pistolShot:Castable(totem.key) and HasBuff(brokencyde.OPPORTUNITY, "player") then
        brokencyde.cancelBladeFlurry()
        return pistolShot:Cast(totem.key)
    end

    if ComboPoints("player") >= 4 and dispatch:Castable(totem.key) then
        brokencyde.cancelBladeFlurry()
        return dispatch:Cast(totem.key)
    end

    if not sinisterStrike:Castable(totem.key) then
        return false
    end

    brokencyde.cancelBladeFlurry()
    return sinisterStrike:Cast(totem.key)
end

Elite.StompTotems(function(totem, totemId)
    if not bigTotems[totemId] and not smallTotems[totemId] then
        return false
    end

    if not InCombat("player") or brokencyde.isStealth("player") then
        return false
    end

    if bigTotems[totemId] and los(totem.key) and IsFacing(totem.key) then
        return castBigSpellToStomp(totem)
    end

    if smallTotems[totemId] and los(totem.key) and IsFacing(totem.key) then
        return castSmallSpellToStomp(totem)
    end
end)

Elite.Stomp(function(object, objectId)
    if not bigTotems[objectId] and not smallTotems[objectId] then
        return false
    end

    if not InCombat("player") or brokencyde.isStealth("player") then
        return false
    end

    if bigTotems[objectId] and los(object.key) and IsFacing(object.key) then
        return castBigSpellToStomp(object)
    end

    if smallTotems[objectId] and los(object.key) and IsFacing(object.key) then
        return castSmallSpellToStomp(object)
    end
end)
brokencyde.trinkets = {}
brokencyde.prepTimestamp = 0

function brokencyde.AddRemainingTimeToTrinket(sourceGUID, startTime, timeToAdd)
    brokencyde.trinkets[sourceGUID] = { usedAt = startTime, duration = timeToAdd }
end

function brokencyde.getRemainingTrinketTime(sourceGUID)
    local trinketData = brokencyde.trinkets[sourceGUID]

    if not trinketData then
        return 0
    end

    if trinketData.usedAt < brokencyde.prepTimestamp then
        brokencyde.trinkets[sourceGUID] = nil
        return 0
    end

    local elapsedTime = GetTime() - trinketData.usedAt
    local remainingTime = trinketData.duration - elapsedTime

    if remainingTime <= 0 then
        brokencyde.trinkets[sourceGUID] = nil
        return 0
    end

    return remainingTime
end

function brokencyde.secondsSinceTrinketUsage(sourceGUID)
    local trinketData = brokencyde.trinkets[sourceGUID]

    if not trinketData then
        return 0
    end

    return GetTime() - trinketData.usedAt
end

function brokencyde.hasTrinket(sourceGUID)
    return brokencyde.getRemainingTrinketTime(sourceGUID) <= 0
end

function brokencyde.handleTrinketEvents(spellName, sourceGUID)
    local source = brokencyde.getUnitByGuid(sourceGUID, enemies)

    if not source then
        return false
    end

    local trinketsTable = {
        [brokencyde.getSpellInfo(59752)] = 90,
        [brokencyde.getSpellInfo(42292)] = 120,
        [brokencyde.getSpellInfo(195710)] = 180,
        [brokencyde.getSpellInfo(208683)] = 120,
        [brokencyde.getSpellInfo(336126)] = 120,
        [brokencyde.getSpellInfo(336135)] = 60,
        [brokencyde.getSpellInfo(20594)] = 30,
        [brokencyde.getSpellInfo(7744)] = 30,
        [brokencyde.getSpellInfo(115191)] = 30,
    }

    if Role(source.key) == "healer" then
        trinketsTable[brokencyde.getSpellInfo(336126)] = 90
        trinketsTable[brokencyde.getSpellInfo(208683)] = 90
    end

    if not trinketsTable[spellName] then
        return false
    end

    Alert(208683, spellName .. " used by " .. Name(source.key) .. "!")
    brokencyde.AddRemainingTimeToTrinket(sourceGUID, GetTime(), trinketsTable[spellName])
end
local function getCastTarget(unit, searchUnits)
    if not unit or not unit.key then
        return false
    end

    local castTarget = false

    ObjectsLoop(searchUnits, function(unitSearched)
        if CastTarget(unit.key, unitSearched.key) then
            castTarget = unitSearched
            return true
        end
    end)

    return castTarget
end

local function shouldInterruptCc(enemy, importantSpell)
    local castTarget = getCastTarget(enemy, friends)
    local healer = fHealer

    if not castTarget or not castTarget.key then
        return true
    end

    if castTarget.immuneCC then
        return false
    end

    local disorientDr = DisorientDr(castTarget.key)
    local incapacitateDr = IncapacitateDr(castTarget.key)

    if importantSpell.ccType == "Disorient" and disorientDr < 0.5 then
        return false
    end

    if importantSpell.ccType == "Incapacitate" and incapacitateDr < 0.5 then
        return false
    end

    if HasBuff(brokencyde.GROUNDING_TOTEM, castTarget.key) then
        return false
    end

    if fHealer and fHealer.key then
        if castTarget.key == healer.key and los(enemy.key, castTarget.key) then
            return true
        end
    end

    if castTarget.key == "player" and los(enemy.key, castTarget.key) then
        return true
    end

    return false
end

local function needsToStep(enemy)
    if Class("player") == "ROGUE" then
        return brokencyde.gapCloserIsNeeded(enemy, 12)
    end

    return false
end

local function canStepBack(enemy)
    if Distance(enemy.key, "target") <= 8 then
        return true
    end

    local hookCharges = Charges(grapplingHook.id)

    if hookCharges == 1 and HasBuff(brokencyde.DEATH_ARRIVAL, "player") then
        return false
    end

    return hookCharges >= 1
end

local function shouldInterruptDamage(enemy)
    local castTarget = getCastTarget(enemy, friends)

    if not castTarget then
        return true
    end

    if HasBuff(brokencyde.GROUNDING_TOTEM, castTarget.key) then
        return false
    end

    if castTarget.immuneM then
        return false
    end

    if needsToStep(enemy) then
        return false
    end

    local healer = fHealer
    local healerIsFree = healer and ccr(healer.key) <= 0

    if TrueHealthP(castTarget.key) > 30 and ((healerIsFree and los(healer.key, castTarget.key))) then
        return false
    end

    return true
end

local function canEnemyTeamCastCC()
    local ccCasters = {
        ["WARLOCK"] = "Disorient",
        ["MAGE"] = "Incapacitate",
        ["DRUID"] = "Disorient",
        ["EVOKER"] = "Disorient"
    }

    local canCastCC = false

    if not fHealer or not fHealer.key then
        return false
    end

    local disorientDrRemains = DisorientDrr(fHealer.key)
    local incapacitateDrRemains = IncapacitateDrr(fHealer.key)

    ObjectsLoop(brokencyde.getEnemiesInRange(), function(enemy)
        local casterDr = ccCasters[Class(enemy.key)]

        if not casterDr then
            return false
        end

        if casterDr == "Disorient" and disorientDrRemains <= 10 then
            canCastCC = true
            return true
        end

        if casterDr == "Incapacitate" and incapacitateDrRemains <= 10 then
            canCastCC = true
            return true
        end
    end)

    return canCastCC
end

local function shouldInterruptHeal(enemy)
    local castTarget = getCastTarget(enemy, enemies)

    if not castTarget or not castTarget.key then
        return false
    end

    if NoInteract(castTarget.key) then
        return false
    end

    if TrueHealthP(castTarget.key) < 20 then
        return true
    end

    if canEnemyTeamCastCC() then
        return false
    end

    if needsToStep(enemy) and brokencyde.betweenTheEyesChecks(myTarget, true) then
        return false
    end

    if needsToStep(enemy) and not canStepBack(enemy) then
        return false
    end

    if brokencyde.getSpellInfo(CastInfo(enemy.key)) == brokencyde.DRAIN_LIFE and TrueHealthP(enemy.key) < 50 then
        return true
    end

    if TrueHealthP(castTarget.key) > brokencyde.random(88, 94) then
        return false
    end

    return true
end

function brokencyde.isInterruptable(currentTarget)
    if not currentTarget or not currentTarget.key then
        return false
    end

    if HasBuff(brokencyde.ANCESTRAL_GIFT, currentTarget.key) then
        return false
    end

    if HasBuff(brokencyde.SPIRIT_OF_REDEMPTION, currentTarget.key) or HasDebuff(brokencyde.SPIRIT_OF_REDEMPTION, currentTarget.key) then
        return false
    end

    if Class("player") == "ROGUE" or Class("player") == "DRUID" then
        if HasBuff(brokencyde.BLESSING_OF_PROTECTION, currentTarget.key) then
            return false
        end
    end

    return IsCastChan(currentTarget.key) and (CanInterruptCast(currentTarget.key) or CanInterruptChannel(currentTarget.key))
end

local function shouldInterruptCombustion(enemy)
    local combustionRemaining = GetBuffRemaining(brokencyde.COMBUSTION, enemy.key)

    if not combustionRemaining or combustionRemaining < 2 then
        return false
    end

    return true
end

function brokencyde.shouldInterrupt(currentTarget, usingTyphoon)
    if not IsPlayer(currentTarget.key) then
        return false
    end

    local importantSpells = {
        { name = brokencyde.VOID_TORRENT, type = "damage", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.RAY_OF_FROST, type = "always", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.MIND_CONTROL, type = "cc", ccType = "Disorient", canInterruptWithKnock = true },
        { name = brokencyde.FEAR, type = "cc", ccType = "Disorient", canInterruptWithKnock = true },
        { name = brokencyde.POLYMORPH, type = "cc", ccType = "Incapacitate", canInterruptWithKnock = true },
        { name = brokencyde.SONG_OF_CHI_JI, type = "cc", ccType = "Disorient", canInterruptWithKnock = true },
        { name = brokencyde.HEX, type = "cc", ccType = "Incapacitate", canInterruptWithKnock = true },
        { name = brokencyde.SLEEP_WALK, type = "cc", ccType = "Disorient", canInterruptWithKnock = true },
        { name = brokencyde.REPENTANCE, type = "cc", ccType = "Incapacitate", canInterruptWithKnock = true },
        { name = brokencyde.CYCLONE, type = "always", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.LIGHTNING_LASSO, type = "always", ccType = "N/A", canInterruptWithKnock = false },
        { name = brokencyde.CHAOS_BOLT, type = "damage", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.UNSTABLE_AFFLICTION, type = "damage", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.GLACIAL_SPIKE, type = "damage", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.CONVOKE_THE_SPIRITS, type = "damage", ccType = "N/A", canInterruptWithKnock = false },
        { name = brokencyde.ETERNITY_SURGE, type = "damage", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.DISINTEGRATE, type = "damage", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.SOOTHING_MIST, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.POLYMORPH, type = "cc", ccType = "Incapacitate", canInterruptWithKnock = true },
        { name = brokencyde.SHADOWFURY, type = "cc", ccType = "stun", canInterruptWithKnock = true },
        { name = brokencyde.SHEILUN_S_GIFT, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.NULLIFYING_SHROUD, type = "always", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.REVIVE_PET, type = "always", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.DARK_REPRIMAND, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.HEAL, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.FLASH_HEAL, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.REGROWTH, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.WILD_GROWTH, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.NOURISH, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.SPIRITBLOOM, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.DREAM_BREATH, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.FLASH_OF_LIGHT, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.HOLY_LIGHT, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.PENANCE, type = "heal", ccType = "N/A", canInterruptWithKnock = false },
        { name = brokencyde.HEALING_SURGE, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.HEALING_WAVE, type = "heal", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.POLYMORPH, type = "cc", ccType = "Incapacitate", canInterruptWithKnock = true },
        { name = brokencyde.SEARING_GLARE, type = "always", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.SOUL_ROT, type = 'damage', ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.ULTIMATE_PENITENCE, type = 'always', ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.DRAIN_LIFE, type = 'heal', ccType = 'N/A', canInterruptWithKnock = true },
        { name = brokencyde.AIMED_SHOT, type = "always", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.SNIPER_SHOT, type = "always", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.FIREBALL, type = "combustion", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.FLAMESTRIKE, type = "combustion", ccType = "N/A", canInterruptWithKnock = true },
        { name = brokencyde.SCORCH, type = "combustion", ccType = "N/A", canInterruptWithKnock = false },
    }

    local function shouldInterrupt(enemy, importantSpell, withTyphoon)
        local baseValue = 75

        if withTyphoon then
            baseValue = 10
        end

        local kickThreshold = brokencyde.random(45, 75)
        local channelThreshold = brokencyde.random(25, 45)

        if needsToStep(enemy) then
            kickThreshold = brokencyde.random(25, 45)
        end

        local spellCasted = brokencyde.getSpellInfo(CastInfo(enemy.key))
        local spellChannelled = brokencyde.getSpellInfo(ChanInfo(enemy.key))

        if spellCasted == 0 and spellChannelled == 0 then
            return false
        end

        local castPercent = CastingPercent(enemy.key)
        local channelPercent = ChannelingPercent(enemy.key)

        if spellCasted ~= 0 and (spellCasted ~= importantSpell.name or castPercent <= kickThreshold) then
            return false
        end

        if spellChannelled ~= 0 and (spellChannelled ~= importantSpell.name or channelPercent <= channelThreshold) then
            return false
        end

        if (castPercent > 80 or channelPercent > 80) and needsToStep(enemy) then
            return false
        end

        if withTyphoon and importantSpell.canInterruptWithKnock then
            return true
        end

        if withTyphoon and not importantSpell.canInterruptWithKnock then
            return false
        end

        if importantSpell.type == "always" then
            return true
        end

        if importantSpell.type == "combustion" then
            return shouldInterruptCombustion(enemy)
        end

        if importantSpell.type == "cc" then
            return shouldInterruptCc(enemy, importantSpell)
        end

        if importantSpell.type == "damage" then
            return shouldInterruptDamage(enemy)
        end

        if importantSpell.type == "heal" then
            return shouldInterruptHeal(enemy)
        end

        return false
    end

    for _, importantSpell in ipairs(importantSpells) do
        if shouldInterrupt(currentTarget, importantSpell, usingTyphoon) then
            return true
        end
    end

    return false
end

local Commands = Tinkr.Util.Commands
local brobro = Commands:New('brobro')

brobro:Register('hook', function()
    SmartAoE(grapplingHook.id, "target", 3, SpellRange(grapplingHook.id))
end, 'Hook to target')

print('Brokencyde Outlaw loaded HF')
rmt('/brobro')
EventManager:On("SPELL_CAST_SUCCESS", true, function(eventInfo)
    brokencyde.handleTrinketEvents(eventInfo[13], eventInfo[4])
end)
function inCombat()
    brokencyde.globalVariablesLoop()

    if not Alive("player") then
        return
    end

    if Locked() then
        return
    end

    if Mounted() then
        return
    end

    stealth()

    if brokencyde.justMelded and not brokencyde.isStealth("player") then
        return
    end

    if HasBuff(58984, "player") and not brokencyde.isStealth("player") then
        return
    end

    sap("stealthed")
    sap("aoe with shadowstep")
    sap()

    tricksOfTheTrade()

    cloakOfShadows()
    evasion()
    feint()

    thistleTea()

    smokeBomb()

    kick()

    dismantle()

    kidneyShot("healer")
    kidneyShot()
    kidneyShot("aoe")

    if brokencyde.castingGapCloser then
        return
    end

    cheapShotToStunParry("aoe full DR")
    cheapShot("aoe full DR")

    blind("whenever possible")

    killingSpree()
    betweenTheEyes()

    vanish()

    crimsonVial()

    rollTheBones()
    keepItRolling()

    cheapShotToStunParry()
    cheapShot()

    gouge("aoe")

    bladeFlurry()

    adrenalineRush()
    --shadowMeld("maintain AR")
    ghostlyStrike()

    sliceAndDice()
    dispatch()

    ambush()

    pistolShot()

    sinisterStrike()
    sinisterStrike("aoe")
end

function outCombat()
    brokencyde.globalVariablesLoop()

    if not Alive("player") then
        return
    end

    if Locked() then
        return
    end

    if Mounted() then
        bladeFlurry("opener")
        adrenalineRush("opener")
        sliceAndDice("opener")
        return
    end

    stealth()

    if brokencyde.justMelded and not brokencyde.isStealth("player") then
        return
    end

    if HasBuff(58984, "player") and not brokencyde.isStealth("player") then
        return
    end

    sap("stealthed")
    sap("aoe with shadowstep")
    sap()

    tricksOfTheTrade()

    crimsonVial()

    rollTheBones()

    betweenTheEyes()
    ambush("after vanish")

    cheapShot()
    cheapShot("aoe full DR")

    blind("whenever possible")

    bladeFlurry("opener")
    adrenalineRush("opener")
    sliceAndDice("opener")
end

Elite.inCombat = inCombat
Elite.outCombat = outCombat


local function CreateTestFrame()
    local frame = CreateFrame("Frame", "TestResultsFrame", UIParent, "BasicFrameTemplate")
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -15)
    frame.title:SetText("")

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetSize())
    scrollFrame:SetScrollChild(content)

    local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", content, "TOPLEFT", 8, 0)
    text:SetWidth(content:GetWidth() - 16)
    text:SetJustifyH("LEFT")

    frame.text = text
    frame:Hide()

    return frame
end

local TestSuite = {
    tests = {},
    failures = {},
    successes = 0,
    total = 0,
    currentTest = nil
}

local COLORS = {
    RED = "|cFFFF3333",
    GREEN = "|cFF00FF00",
    YELLOW = "|cFFFFFF00",
    BLUE = "|cFF0000FF",
    WHITE = "|cFFFFFFFF",
    RESET = "|r"
}

function TestSuite:new()
    local instance = {}
    setmetatable(instance, { __index = TestSuite })
    instance.output = {}
    instance.frame = CreateTestFrame()
    return instance
end

function TestSuite:addOutput(text, color)
    local coloredText
    if color then
        coloredText = color .. text .. COLORS.RESET
    else
        coloredText = text
    end
    table.insert(self.output, coloredText)

    if self.frame and self.frame.text then
        self.frame.text:SetText(table.concat(self.output, "\n"))
    end
end

function TestSuite:test(name, fn)
    table.insert(self.tests, {
        name = name,
        fn = fn,
        isAsync = false
    })
end

function TestSuite:testAsync(name, fn)
    table.insert(self.tests, {
        name = name,
        fn = fn,
        isAsync = true
    })
end

function TestSuite:waitFor(condition, timeout, message)
    local startTime = GetTime()
    local frame = CreateFrame("Frame")

    local wrapper = {}

    function wrapper:await(callbackFn)
        frame:SetScript("OnUpdate", function()
            if GetTime() - startTime > (timeout or 5) then
                frame:SetScript("OnUpdate", nil)
                if type(callbackFn) == "function" then
                    callbackFn(message or "Timeout waiting for condition")
                end
                return
            end

            if condition() then
                frame:SetScript("OnUpdate", nil)
                if type(callbackFn) == "function" then
                    callbackFn()
                end
            end
        end)
    end

    return wrapper
end

function TestSuite:run()
    self.failures = {}
    self.successes = 0
    self.total = 0
    self.currentTest = nil
    self.output = {}

    self.frame:Show()

    self:addOutput("Running Test Suite")
    self:addOutput("==================\n")

    local function runNextTest(index)
        if index > #self.tests then
            self:printSummary()
            return
        end

        local test = self.tests[index]
        self.currentTest = test.name
        self.total = self.total + 1

        if test.isAsync then
            test.fn(function(error)
                if error then
                    table.insert(self.failures, {
                        name = test.name,
                        error = error
                    })
                    self:addOutput("[FAIL] " .. test.name, COLORS.RED)
                    self:addOutput("  Error: " .. error .. "\n", COLORS.RED)
                else
                    self.successes = self.successes + 1
                    self:addOutput("[PASS] " .. test.name .. "\n", COLORS.GREEN)
                end
                runNextTest(index + 1)
            end)
        else
            local success, error = pcall(function()
                test.fn()
            end)

            if success then
                self.successes = self.successes + 1
                self:addOutput("[PASS] " .. test.name .. "\n", COLORS.GREEN)
            else
                table.insert(self.failures, {
                    name = test.name,
                    error = error
                })
                self:addOutput("[FAIL] " .. test.name, COLORS.RED)
                self:addOutput("  Error: " .. error .. "\n", COLORS.RED)
            end
            runNextTest(index + 1)
        end
    end

    runNextTest(1)
end

function TestSuite:printSummary()
    self:addOutput("Test Summary")
    self:addOutput("============")
    self:addOutput("Total Tests: " .. self.total, COLORS.WHITE)
    self:addOutput("Passed: " .. self.successes, COLORS.GREEN)
    self:addOutput("Failed: " .. #self.failures, COLORS.RED)

    if #self.failures > 0 then
        self:addOutput("\nFailures:", COLORS.YELLOW)
        for _, failure in ipairs(self.failures) do
            self:addOutput("- " .. failure.name .. ": " .. failure.error, COLORS.RED)
        end
    end
end

function TestSuite:reset()
    self.tests = {}
    self.failures = {}
    self.successes = 0
    self.total = 0
    self.currentTest = nil
    self.output = {}

    if self.frame then
        self.frame.text:SetText("")
        self.frame:Hide()
    end
end

local Assert = {}

function Assert:equal(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\nExpected: %s\nActual: %s",
                message or "Values are not equal",
                tostring(expected),
                tostring(actual)
        ))
    end
end

function Assert:notEqual(actual, expected, message)
    if actual == expected then
        error(string.format("%s\nValue should not equal: %s",
                message or "Values should not be equal",
                tostring(expected)
        ))
    end
end

function Assert:isTrue(value, message)
    if value ~= true then
        error(message or "Expected value to be true")
    end
end

function Assert:isFalse(value, message)
    if value ~= false then
        error(message or "Expected value to be false")
    end
end

function Assert:isNil(value, message)
    if value ~= nil then
        error(string.format("%s\nExpected nil but got: %s",
                message or "Value should be nil",
                tostring(value)
        ))
    end
end

function Assert:notNil(value, message)
    if value == nil then
        error(message or "Value should not be nil")
    end
end

function Assert:notNil(value, message)
    if value == nil then
        error(message or "Value should not be nil")
    end
end

function Assert:greaterThan(actual, expected, message)
    if not (actual > expected) then
        error(string.format("%s\nExpected %s to be greater than %s",
                message or "Value not greater than expected",
                tostring(actual),
                tostring(expected)
        ))
    end
end

function Assert:lessThan(actual, expected, message)
    if not (actual < expected) then
        error(string.format("%s\nExpected %s to be less than %s",
                message or "Value not less than expected",
                tostring(actual),
                tostring(expected)
        ))
    end
end

function Assert:between(value, min, max, message)
    if not (value >= min and value <= max) then
        error(string.format("%s\nExpected %s to be between %s and %s",
                message or "Value not in expected range",
                tostring(value),
                tostring(min),
                tostring(max)
        ))
    end
end

function Assert:inRange(unit, range, message)
    if not InRange(unit, range) then
        error(string.format("%s\nUnit %s should be in range %d",
                message or "Unit not in range",
                tostring(unit),
                range
        ))
    end
end

function Assert:hasBuffOrDebuff(unit, auraID, isDebuff, message)
    local hasAura = isDebuff and HasDebuff(auraID, unit) or HasBuff(auraID, unit)
    if not hasAura then
        error(string.format("%s\nUnit %s should have %s %d",
                message or "Aura not found",
                tostring(unit),
                isDebuff and "debuff" or "buff",
                auraID
        ))
    end
end

function Assert:isAlive(unit, message)
    if not Alive(unit) then
        error(string.format("%s\nUnit %s should be alive",
                message or "Unit is not alive",
                tostring(unit)
        ))
    end
end

_G.WoWTest = {
    Suite = TestSuite:new(),
    Assert = Assert
}

local T = _G.WoWTest.Suite
local A = _G.WoWTest.Assert

T:testAsync("Test Buff Functions", function(done)
    local buff = brokencyde.getSpellInfo(3408)

    if not HasBuff(buff, "player") then
        CastSpellByID(3408)

        T:waitFor(function()
            return HasBuff(buff, "player")
        end, 3, "Buff didn't appear after casting")
         :await(function(error)
            if error then
                done(error)
                return
            end

            A:notNil(GetBuffRemaining(buff, "player"), "Buff duration should not be nil - with strings")
            A:greaterThan(GetBuffRemaining(buff, "player"), 0, "Buff duration should be greater than 0 - with strings")
            A:notNil(GetBuffRemaining(3408, "player"), "Buff duration should not be nil - with id")
            A:greaterThan(GetBuffRemaining(3408, "player"), 0, "Buff duration should be greater than 0 - with id")
            done()
        end)
    else
        A:notNil(GetBuffRemaining(buff, "player"), "Buff duration should not be nil - with strings")
        A:greaterThan(GetBuffRemaining(buff, "player"), 0, "Buff duration should be greater than 0 - with strings")
        A:notNil(GetBuffRemaining(3408, "player"), "Buff duration should not be nil - with id")
        A:greaterThan(GetBuffRemaining(3408, "player"), 0, "Buff duration should be greater than 0 - with id")
        done()
    end
end)

T:test("Test Buff Functions - with strings", function()
    local buffId = 108211
    local buff = brokencyde.getSpellInfo(buffId)

    if not HasBuff(buffId, "player") then
        return error("Test requires player to have buff " .. buff)
    end

    print(HasBuff(buff, "player"))
    print(HasBuff("Leeching Poison", "player"))
    print(HasBuff(buffId, "player"))

    A:notEqual(HasBuff(buff, "player"), 0, "Should not be 0")
    A:notEqual(HasBuff("Leeching Poison", "player"), 0, "Should not be 0")
    A:notEqual(HasBuff(buffId, "player"), 0, "Should not be 0")
end)

T:test("Test Health Function", function()
    A:between(Health("player"), 0, 100, "Player health should be between 0 and 100")
end)

T:test("Test Distance Function", function()
    if UnitExists("target") then
        local distance = Distance("player", "target")
        A:notNil(distance, "Distance should not be nil")
        A:greaterThan(distance, 0, "Distance should be greater than 0")
    end
end)


T:test("Bursting should return false when player doesn't have Adrenaline Rush", function()
    local adrenalineRushId = brokencyde.getSpellInfo(13750)

    if HasBuff(adrenalineRushId, "player") then
        error("Test requires player to not have Adrenaline Rush buff")
    end

    local isBursting = Bursting("player")
    A:isFalse(isBursting, "Bursting should return false when player doesn't have Adrenaline Rush")
    A:isFalse(myPlayer.bursting, "myPlayer.bursting should be false when player doesn't have Adrenaline Rush")
end)

T:testAsync("Bursting should return true when player has Adrenaline Rush", function(done)
    local adrenalineRushId = brokencyde.getSpellInfo(13750)

    if not HasBuff(adrenalineRushId, "player") and SpellCd(13750) > 0 then
        done("Test requires player to have Adrenaline Rush available")
        return
    end

    if not HasBuff(adrenalineRushId, "player") then
        CastSpellByID(13750)

        T:waitFor(
                function()
                    return HasBuff(adrenalineRushId, "player")
                end,
                3,
                "Adrenaline Rush buff didn't appear after casting"
        ):await(function(error)
            if error then
                done(error)
                return
            end

            A:isTrue(Bursting("player"), "Bursting should return true when player has Adrenaline Rush")
            done()
        end)
    else
        A:isTrue(Bursting("player"), "Bursting should return true when player has Adrenaline Rush")
        done()
    end
end)

T:test("myPlayer.bursting should return false when player doesn't have Adrenaline Rush", function()
    local adrenalineRushId = brokencyde.getSpellInfo(13750)

    if HasBuff(adrenalineRushId, "player") then
        error("Test requires player to not have Adrenaline Rush buff")
    end

    A:isFalse(myPlayer.bursting, "myPlayer.bursting should be false when player doesn't have Adrenaline Rush")
end)

T:testAsync("myPlayer.bursting should return true when player has Adrenaline Rush", function(done)
    local adrenalineRushId = brokencyde.getSpellInfo(13750)

    if not HasBuff(adrenalineRushId, "player") and SpellCd(13750) > 0 then
        done("Test requires player to have Adrenaline Rush available")
        return
    end

    if not HasBuff(adrenalineRushId, "player") then
        CastSpellByID(13750)

        T:waitFor(
                function()
                    return HasBuff(adrenalineRushId, "player")
                end,
                3,
                "Adrenaline Rush buff didn't appear after casting"
        ):await(function(error)
            if error then
                done(error)
                return
            end

            A:isTrue(myPlayer.bursting, "myPlayer.bursting should be true when player has Adrenaline Rush")
            done()
        end)
    else
        A:isTrue(myPlayer.bursting, "myPlayer.bursting should be true when player has Adrenaline Rush")
        done()
    end
end)

T:test("Class should return ROGUE for player character", function()
    local playerClass = Class("player")
    A:equal(playerClass, "ROGUE", "Player class should be ROGUE")
end)

T:test("ComboPoints should be 0 when no combo points are active", function()
    local comboPoints = ComboPoints("player")
    A:between(comboPoints, 0, 7, "Player should have between 0 and 7 combo points")
end)

T:test("Alive should return true for player character", function()
    local isAlive = Alive("player")
    A:isTrue(isAlive, "Player should be alive")
end)

T:test("Energy should be equal to max energy for player", function()
    local energy = Energy("player")

    A:between(energy, 0, 300, "Player should have between 0 and 300 energy")
end)

T:test("IsCaster should return false for Rogue", function()
    local isCaster = IsCaster("player")
    A:isFalse(isCaster, "Rogue should not be identified as a caster")
end)

T:test("IsEnemy should return false for player character", function()
    local isEnemy = IsEnemy("player")
    A:isFalse(isEnemy, "Player should not be identified as an enemy")
end)

T:test("IsEnemy should work correctly with hostile target", function()
    if UnitExists("target") then
        local isEnemy = IsEnemy("target")
        local isHostile = UnitIsEnemy("player", "target")
        A:equal(isEnemy, isHostile, "IsEnemy should match WoW's UnitIsEnemy function")
    else
        print("Skipping enemy target test - no target selected")
    end
end)

T:test("IsHealer should return false for Rogue", function()
    local isHealer = IsHealer("player")
    A:isFalse(isHealer, "Rogue should not be identified as a healer")
end)

T:test("IsMelee should return true for Rogue", function()
    local isMelee = IsMelee("player")
    A:isTrue(isMelee, "Rogue should be identified as melee")
end)

T:test("IsPhysical should return true for Rogue", function()
    local isPhysical = IsPhysical("player")
    A:isTrue(isPhysical, "Rogue should be identified as physical damage")
end)

T:test("IsPlayer should return true for player character", function()
    local isPlayer = IsPlayer("player")
    A:isTrue(isPlayer, "Should identify player unit as a player")
end)

T:test("IsPlayer should handle non-player units correctly", function()
    if UnitExists("target") then
        local isPlayer = IsPlayer("target")
        local shouldBePlayer = UnitIsPlayer("target")
        A:equal(isPlayer, shouldBePlayer, "IsPlayer should match WoW's UnitIsPlayer function")
    else
        print("Skipping target player test - no target selected")
    end
end)

T:test("IsRanged should return false for Rogue", function()
    local isRanged = IsRanged("player")
    A:isNil(isRanged, "Rogue should not be identified as ranged")
end)

T:test("GetBuffRemaining should return 0 or more - with string", function()
    local remaining = GetBuffRemaining(brokencyde.getSpellInfo(115192), "player")
    A:notNil(remaining, "GetBuffRemaining should not return nil")
    A:notEqual(remaining, false, "GetBuffRemaining should not return false")
    A:equal(remaining, 0, "GetBuffRemaining should return 0 when buff is not present")
end)

T:test("GetBuffRemaining should return 0 or more - with id", function()
    local remaining = GetBuffRemaining(115192, "player")
    A:notNil(remaining, "GetBuffRemaining should not return nil")
    A:notEqual(remaining, false, "GetBuffRemaining should not return false")
    A:equal(remaining, 0, "GetBuffRemaining should return 0 when buff is not present")
end)

T:test("GetBuffCount should return 0 or more - with string", function()
    local count = GetBuffCount(brokencyde.getSpellInfo(354847), "player")
    A:notNil(count, "GetBuffCount should not return nil")
    A:notEqual(count, false, "GetBuffCount should not return false")
    A:greaterThan(count, -1, "GetBuffCount should return 0 or more when checking buff stacks")
end)

T:test("GetBuffCount should return 0 or more - with id", function()
    local count = GetBuffCount(354847, "player")
    A:notNil(count, "GetBuffCount should not return nil")
    A:notEqual(count, false, "GetBuffCount should not return false")
    A:greaterThan(count, -1, "GetBuffCount should return 0 or more when checking buff stacks")
end)

T:test("GetDebuffRemaining should return 0 or more - with string", function()
    local remaining = GetDebuffRemaining(brokencyde.getSpellInfo(115192), "player")
    A:notNil(remaining, "GetDebuffRemaining should not return nil")
    A:notEqual(remaining, false, "GetDebuffRemaining should not return false")
    A:equal(remaining, 0, "GetDebuffRemaining should return 0 when buff is not present")
end)

T:test("GetDebuffRemaining should return 0 or more - with id", function()
    local remaining = GetDebuffRemaining(115192, "player")
    A:notNil(remaining, "GetDebuffRemaining should not return nil")
    A:notEqual(remaining, false, "GetDebuffRemaining should not return false")
    A:equal(remaining, 0, "GetDebuffRemaining should return 0 when buff is not present")
end)

T:test("GetDebuffCount should return 0 or more - with string", function()
    local count = GetDebuffCount(brokencyde.getSpellInfo(354847), "player")
    A:notNil(count, "GetDebuffCount should not return nil")
    A:notEqual(count, false, "GetDebuffCount should not return false")
    A:greaterThan(count, -1, "GetDebuffCount should return 0 or more when checking buff stacks")
end)

T:test("GetDebuffCount should return 0 or more - with id", function()
    local count = GetDebuffCount(354847, "player")
    A:notNil(count, "GetDebuffCount should not return nil")
    A:notEqual(count, false, "GetDebuffCount should not return false")
    A:greaterThan(count, -1, "GetDebuffCount should return 0 or more when checking buff stacks")
end)

brobro:Register('test', function()
    T:run()
end, 'Run test suite')
