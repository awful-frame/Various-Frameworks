local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArraySort = ____lualib.__TS__ArraySort
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin
local ____exports = {}
local ____geometry = ravn["Geometry.geometry"]
local Geometry = ____geometry.Geometry
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local SOUND = ____alerts.SOUND
local ____interrupts = ravn["Interrupts.interrupts"]
local Interrupt = ____interrupts.Interrupt
local ____pveLogic = ravn["PveLogic.pveLogic"]
local UnitType = ____pveLogic.UnitType
local pveLogic = ____pveLogic.pveLogic
local ____InternalCooldowns = ravn["Utilities.InternalCooldowns.InternalCooldowns"]
local InternalCooldowns = ____InternalCooldowns.InternalCooldowns
local ____awfulSpells = ravn["Utilities.Lists.awfulSpells"]
local soulCasket = ____awfulSpells.soulCasket
local volcanicPot = ____awfulSpells.volcanicPot
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ravnPrint = ____ravnPrint.ravnPrint
local ____spell = ravn["Utilities.spell"]
local Spell = ____spell.Spell
local ____structures = ravn["Utilities.structures"]
local IInteruptState = ____structures.IInteruptState
local ____lockLib = ravn["rotation.lock.lockLib"]
local lockLib = ____lockLib.lockLib
local ____lockspells = ravn["rotation.lock.lockspells"]
local baneOfAgony = ____lockspells.baneOfAgony
local baneOfDoom = ____lockspells.baneOfDoom
local corruption = ____lockspells.corruption
local curseOfTheElements = ____lockspells.curseOfTheElements
local darkIntent = ____lockspells.darkIntent
local demonSoul = ____lockspells.demonSoul
local devourMagic = ____lockspells.devourMagic
local drainSoul = ____lockspells.drainSoul
local felArmor = ____lockspells.felArmor
local felFlame = ____lockspells.felFlame
local felStorm = ____lockspells.felStorm
local handOfGuldan = ____lockspells.handOfGuldan
local hellFire = ____lockspells.hellFire
local immolate = ____lockspells.immolate
local immolationAura = ____lockspells.immolationAura
local incinerate = ____lockspells.incinerate
local lifeTap = ____lockspells.lifeTap
local metamorphosis = ____lockspells.metamorphosis
local shadowBolt = ____lockspells.shadowBolt
local shadowflame = ____lockspells.shadowflame
local soulBurn = ____lockspells.soulBurn
local soulFire = ____lockspells.soulFire
local soulHarvest = ____lockspells.soulHarvest
local spellLock = ____lockspells.spellLock
local sprintPet = ____lockspells.sprintPet
local summonDoomguard = ____lockspells.summonDoomguard
local summonFelguard = ____lockspells.summonFelguard
local summonFelhunter = ____lockspells.summonFelhunter
____exports.PET_ACTION = PET_ACTION or ({})
____exports.PET_ACTION.NORMAL = 0
____exports.PET_ACTION[____exports.PET_ACTION.NORMAL] = "NORMAL"
____exports.PET_ACTION.PASSIVE_MODE = 1
____exports.PET_ACTION[____exports.PET_ACTION.PASSIVE_MODE] = "PASSIVE_MODE"
____exports.PET_ACTION.HOLD_POSITION = 2
____exports.PET_ACTION[____exports.PET_ACTION.HOLD_POSITION] = "HOLD_POSITION"
____exports.PET_ACTION.ON_HEALER = 3
____exports.PET_ACTION[____exports.PET_ACTION.ON_HEALER] = "ON_HEALER"
____exports.PET_ACTION.NEEDS_ROS = 4
____exports.PET_ACTION[____exports.PET_ACTION.NEEDS_ROS] = "NEEDS_ROS"
____exports.PET_ACTION.NEEDS_LIB = 5
____exports.PET_ACTION[____exports.PET_ACTION.NEEDS_LIB] = "NEEDS_LIB"
____exports.PET_ACTION.RUN_TO_ALLY = 6
____exports.PET_ACTION[____exports.PET_ACTION.RUN_TO_ALLY] = "RUN_TO_ALLY"
____exports.PET_ACTION.MOVE_TO = 7
____exports.PET_ACTION[____exports.PET_ACTION.MOVE_TO] = "MOVE_TO"
____exports.PET_ACTION.PET_FLEE = 8
____exports.PET_ACTION[____exports.PET_ACTION.PET_FLEE] = "PET_FLEE"
____exports.PET_ACTION.COMEBACK = 9
____exports.PET_ACTION[____exports.PET_ACTION.COMEBACK] = "COMEBACK"
____exports.PET_ACTION.NEED_MANNER = 10
____exports.PET_ACTION[____exports.PET_ACTION.NEED_MANNER] = "NEED_MANNER"
____exports.demonoLib = __TS__Class()
local demonoLib = ____exports.demonoLib
demonoLib.name = "demonoLib"
__TS__ClassExtends(demonoLib, lockLib)
function demonoLib.holdBurst(self)
    return not ravn.config.demonoBurst
end
function demonoLib.onUseTrinkets(self)
    if soulCasket.equipped and soulCasket.cooldown <= 0.3 then
        local cond = awful.player.buffRemains(metamorphosis.id) > 15 or awful.player.buff(self.DEMON_SOUL_FELGUARD_BUFF) and awful.player.buffUptime(self.DEMON_SOUL_FELGUARD_BUFF) <= 3
        if cond then
            soulCasket:Use()
        end
    end
end
function demonoLib.setOpenerStart(self)
    if self.lastFinishedDbmPull ~= 0 and awful.time - self.lastFinishedDbmPull > 3 and not awful.player.combat then
        self.lastFinishedDbmPull = 0
    end
    local dbm = self:getDBMTimer()
    if dbm <= 0 then
        return
    end
    if dbm <= 0.5 then
        if self.lastFinishedDbmPull == 0 then
            self.lastFinishedDbmPull = awful.time + dbm
            C_Timer.After(
                3,
                function()
                    self.ignoreDbmPull = false
                    ravnPrint("DBM Pull Finished: Resetting ignore status", Color.WARLOCK)
                end
            )
        end
    end
end
function demonoLib.timeSinceOpener(self)
    if self.lastFinishedDbmPull == 0 then
        return 0
    end
    return awful.time - self.lastFinishedDbmPull
end
function demonoLib.onTick(self)
    local cid = awful.player.castIdEx
    if __TS__ArrayIncludes({summonFelguard.id, summonFelhunter.id}, cid) then
        local ctl = awful.player.castTimeLeft
        if ctl <= 0.5 then
            self.lastPetCast = awful.time + awful.buffer * 2 + 0.2
        end
    end
end
function demonoLib.burstLogic(self, t)
    if not t.exists or t.dead or t.friend then
        return
    end
    if self:timeSinceOpener() ~= 0 then
        return
    end
    local sync = ravn.modernConfig:getDemonoSyncCD()
    local bri = self:burstReadyIn()
    local retValue = ""
    if not sync then
        local alreadyMeta = awful.player.buff(metamorphosis.id)
        if bri <= summonFelguard.castTime and demonSoul.cd <= bri and not alreadyMeta then
            if awful.player.moving and self:getPetId() ~= self.FELGUARD_ID and awful.player.soulShards > 0 then
                Alert.sendAlert(
                    true,
                    0,
                    "Summon Felguard",
                    "Hard Cast for Burst",
                    nil,
                    2,
                    Color.WARLOCK
                )
            end
            summonFelguard("hard-cast", t)
        end
        if self:getPetId() == self.FELGUARD_ID and demonSoul.cd <= bri then
            if demonSoul:Cast() then
                retValue = "wait"
            end
        end
        if not alreadyMeta and self:metamorphosisCD() <= bri and bri <= 10 then
            local meleeOnly = ravn.modernConfig:getDemonoMetaMeleeRangeOnly()
            if meleeOnly and awful.target and awful.target.distance > 12 then
                Alert.sendAlert(
                    true,
                    0,
                    "Meta",
                    "Get in Range",
                    nil,
                    2,
                    Color.WARLOCK
                )
                return retValue
            end
            local noGO = demonSoul.cd <= bri and awful.player.soulShards > 0 and self:getPetId() ~= self.FELGUARD_ID
            if not noGO then
                if metamorphosis:Cast() then
                    retValue = "wait"
                end
            end
        end
    else
        local alreadyMeta = awful.player.buff(metamorphosis.id) or awful.player.buff(self.DEMON_SOUL_FELGUARD_BUFF) or awful.player.buff(79460)
        local targetBoss = UnitClassification("target") == "boss" or UnitClassification("target") == "worldboss"
        if not targetBoss and t.ttd <= 4 and not alreadyMeta and not t.isDummyOrPlayer then
            return retValue
        end
        if bri <= summonFelguard.castTime + awful.gcd and not alreadyMeta then
            if awful.player.moving and self:getPetId() ~= self.FELGUARD_ID and awful.player.soulShards > 0 then
                Alert.sendAlert(
                    true,
                    0,
                    "Summon Felguard",
                    "Hard Cast for Burst",
                    nil,
                    2,
                    Color.WARLOCK
                )
            end
            summonFelguard("hard-cast", t)
        end
        if bri > awful.gcd and not alreadyMeta then
            return retValue
        end
        if t.ttd > 20 and self:getPetId() ~= self.FELGUARD_ID and not alreadyMeta and awful.player.soulShards > 0 then
            return retValue
        end
        if not awful.player.buff(metamorphosis.id) and bri <= 3 then
            local meleeOnly = ravn.modernConfig:getDemonoMetaMeleeRangeOnly()
            if meleeOnly and awful.target and awful.target.distance > 12 then
                Alert.sendAlert(
                    true,
                    0,
                    "Meta",
                    "Get in Range",
                    nil,
                    2,
                    Color.WARLOCK
                )
                return retValue
            end
        end
        if bri <= 0 or awful.player.buffRemains(metamorphosis.id) > 10 then
            metamorphosis:Cast()
            if awful.player.buff(metamorphosis.id) then
                if demonSoul:Cast() then
                    retValue = "wait"
                end
            end
        end
    end
    return retValue
end
function demonoLib.demoFelStorm(self, t)
    local function shouldDelay()
    end
    if self:getPetId() ~= self.FELGUARD_ID then
        return
    end
    local bri = self:burstReadyIn()
    local cond = awful.player.buff(metamorphosis.id) or bri >= felStorm.baseCD
    if not cond then
        return
    end
    felStorm("base", t)
end
function demonoLib.metamorphosisCD(self)
    return metamorphosis.cd
end
function demonoLib.burstReadyIn(self)
    if self:holdBurst() then
        return math.huge
    end
    local inGroupOrRaid = select(
        2,
        IsInInstance()
    ) == "party" or select(
        2,
        IsInInstance()
    ) == "raid"
    if inGroupOrRaid then
        local encounter = awful.encounter
        if not encounter then
            return math.huge
        end
    end
    local sync = ravn.modernConfig:getDemonoSyncCD()
    if sync then
        local waitTime = awful.player.buffRemains(metamorphosis.id) > 10 and 0 or self:metamorphosisCD()
        local dsWait = awful.player.buffRemains(self.DEMON_SOUL_FELGUARD_BUFF) > 3 and 0 or demonSoul.cd
        waitTime = math.max(waitTime, dsWait)
        return waitTime
    else
        local shortDelta = math.abs(demonSoul.cd - metamorphosis.cd) <= 30
        local metaWait = awful.player.buffRemains(metamorphosis.id) > 3 and 0 or self:metamorphosisCD()
        local dsWait = awful.player.buffRemains(self.DEMON_SOUL_FELGUARD_BUFF) > 3 and 0 or demonSoul.cd
        if shortDelta then
            return math.max(metaWait, dsWait)
        end
        if metaWait == 0 or dsWait == 0 then
            return 0
        end
        if shortDelta then
            return math.max(metaWait, dsWait)
        else
            return math.min(metaWait, dsWait)
        end
    end
end
function demonoLib.debugProcs(self)
    local remains = awful.player.buffRemains(metamorphosis.id)
    remains = 6
    local expireProc = InternalCooldowns:currentProcsRemains()
    local min = expireProc > 0 and math.min(expireProc, remains) or remains
    min = math.max(0, min - (awful.gcd + awful.buffer))
    local calc = InternalCooldowns:nextProcReadyIn(true)
end
function demonoLib.optimalTimeBeforeFishingProc(self)
    local remains = awful.player.buffRemains(metamorphosis.id)
    if remains <= 0 then
        return false
    end
    local metaUptime = awful.player.buffUptime(metamorphosis.id)
    if metaUptime <= 2 then
        return false
    end
    if awful.player.buff(self.DEMON_SOUL_FELGUARD_BUFF) then
        remains = awful.player.buffRemains(self.DEMON_SOUL_FELGUARD_BUFF)
    end
    local expireProc = InternalCooldowns:currentProcsRemains()
    local min = expireProc > 0 and math.min(expireProc, remains) or remains
    min = math.max(0, min - (awful.gcd + awful.buffer))
    if min == 0 then
        return true
    end
    local calc = InternalCooldowns:nextProcReadyIn(true)
    return not calc or calc > min
end
function demonoLib.synapseLogic(self)
    if not self:HasSynapseSpring() then
        return
    end
    local cond = awful.player.buff(metamorphosis.id)
    if cond then
        self:useSynapseSprings()
    end
    if not awful.player.combat then
        return
    end
    local cdDS = demonSoul.cd
    if cdDS > 55 and cdDS <= 65 then
        self:useSynapseSprings()
        if self:synapseSpringCD() <= 2 then
            Alert.sendAlert(
                false,
                self.SYNAPSE_SPRINGS_BUFF,
                "Synapse Springs",
                "Optimized",
                SOUND.POSITIVE,
                2,
                Color.WARLOCK,
                Color.WHITE
            )
            if self:synapseSpringCD() < 0.5 then
                return "wait"
            end
        end
    end
end
function demonoLib.isPlayingSB(self)
    return IsPlayerSpell(17790)
end
function demonoLib.isPlayingIncinerate(self)
    return not self:isPlayingSB()
end
function demonoLib.shadowAndFlameRemains(self, t)
    local lock = t.debuffRemains(self.SHADOW_AND_FLAME)
    local mage = t.debuffRemains(self.CRITICAL_MASS)
    return math.max(lock, mage)
end
function demonoLib.getPetId(self)
    if not awful.pet or not awful.pet.exists or awful.pet.dead then
        return 0
    end
    return awful.pet.id
end
function demonoLib.preventShadowFlame(self)
    return Memory.caching(
        self.libCache,
        "preventShadowFlame",
        function()
            local encounterChecks = {1082, 1083}
            if not awful.encounter or not __TS__ArrayIncludes(encounterChecks, awful.encounter.id) then
                return false
            end
            if awful.target.exists and awful.target.id == 45213 then
                return true
            end
            local hitForbidden = __TS__ArrayFind(
                awful.enemies,
                function(____, o)
                    if o.distance <= 15 then
                        if o.name == "Twillight Whelp" then
                            if self:shadowFlameHit(o) then
                                return true
                            end
                        end
                    end
                end
            )
            return hitForbidden ~= nil
        end
    )
end
function demonoLib.shadowFlameHit(self, t)
    if not t or not t.exists or not t.visible or t.dead or t.friend then
        return false
    end
    local chacheName = "shadowFlameHit-" .. t.guid
    return Memory.caching(
        self.libCache,
        chacheName,
        function()
            if self:preventShadowFlame() then
                return false
            end
            if not t.los then
                return false
            end
            if t.distance >= 11 then
                return false
            end
            return awful.player.facing(t, 160)
        end
    )
end
function demonoLib.petComebackPve(self)
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    if awful.time - self.petCombackTimer > 0 then
        return
    end
    self.petBehaviour = ____exports.PET_ACTION.COMEBACK
    if awful.time - self.lastPetCommandTimer < 0.2 then
        return
    end
    local tar = p.target
    if not tar.exists or tar.friend then
        return
    end
    awful.call("PetFollow")
    self.lastPetCommandTimer = awful.time
end
function demonoLib.pvePetBehaviour(self)
    if not awful.player.combat then
        return
    end
    if awful.pullTimer > 0 then
        return
    end
    if awful.target.exists and awful.target.id == 45213 and Global.debugFunction == 0 then
        local referalPoint = {-958, -751, 438}
        local dist = awful.pet.distanceToLiteralPos(referalPoint)
        if dist > 10 then
            self:MovePetTo(referalPoint)
            return
        end
    end
    if awful.target.exists and not awful.target.friend and not awful.target.dead then
        self:petAttack()
    end
end
function demonoLib.disablePetSpells(self)
    local list = {0}
    if awful.time - self.lastPetCheck < 0.2 then
        return
    end
    self.lastPetCheck = awful.time
    local lastIndex = #list - 1
    do
        local i = 0
        while i < #list do
            local id = list[i + 1]
            self:petAutoCast(id, false)
            if i == lastIndex then
                self.lastPetCheck = awful.time + 1
            end
            i = i + 1
        end
    end
end
function demonoLib.setPetPassive(self)
    if awful.time - self.petLastCheckStatus < 1 then
        return
    end
    self.petLastCheckStatus = awful.time
    for i = 1, NUM_PET_ACTION_SLOTS do
        local name, idk, isToken, isActive = GetPetActionInfo(i)
        if isToken then
            name = _G[name]
        end
        if name == PET_MODE_PASSIVE then
            if not isActive then
                ravnInfo("Set Pet to Passive", Color.WARLOCK)
                awful.call("CastPetAction", i)
            end
            return true
        end
    end
end
function demonoLib.felStormRemains(self)
    return awful.pet.buffRemains(felStorm.id)
end
function demonoLib.optimizeFelStorm(self)
    local t = awful.pet.target
    if self:getPetId() ~= self.FELGUARD_ID then
        return
    end
    if not t.exists or t.dead or t.friend then
        return
    end
    local bestPosition = {Geometry:mostAroundPointsWalkable(
        awful.pet,
        t,
        8,
        15,
        self:getEnemies(),
        7
    )}
    if not bestPosition then
        return
    end
end
function demonoLib.lazyTarget(self)
    if not awful.player.combat then
        return
    end
    local inRaidOrParty = __TS__ArrayIncludes(
        {"raid", "party"},
        select(
            2,
            IsInInstance()
        )
    )
    if not inRaidOrParty then
        return
    end
    if awful.target.exists and not awful.target.dead then
        return
    end
    local findSkull = __TS__ArrayFind(
        self:getEnemies(),
        function(____, o) return o.raidTargetIndex == 8 end
    )
    if findSkull then
        findSkull.setTarget()
        return
    end
    local tank = self:findTank()
    if tank and tank.target and tank.target.exists and awful.target.visible then
        tank.target.setTarget()
    end
    if #self:getEnemies() > 0 then
        local u = self:getEnemies()[1]
        if u.exists then
            u.setTarget()
        end
    end
end
function demonoLib.nefarianDominionLogic(self)
    if awful.time - self.tickerNefarian < 0 then
        return
    end
    self.tickerNefarian = awful.time + 0.1
    if not awful.encounter or awful.encounter.id ~= 1026 then
        return
    end
    if not awful.player.buff(79318) and not awful.player.debuff(79318) then
        return
    end
    Alert.sendAlert(
        false,
        79318,
        "Dominion",
        "MC Logic",
        nil,
        5,
        Color.WARLOCK
    )
    local SIPHON_POWER = 79319
    local szSiphon = Spell.getName(SIPHON_POWER)
    local ID_FREE_YOUR_MIND = 79323
    local szFYM = Spell.getName(ID_FREE_YOUR_MIND)
    szSiphon = "/cast " .. szSiphon
    szFYM = "/cast " .. szFYM
    local stacks = awful.player.buffStacks(80627)
    if stacks >= 150 then
        awful.call("RunMacroText", szFYM)
    else
        awful.call("RunMacroText", szSiphon)
    end
end
function demonoLib.farmShards(self)
    local cid = awful.player.castIdEx
    if cid == drainSoul.id then
        return
    end
    if awful.pullTimer > 0 then
        return
    end
    if awful.player.combat then
        return
    end
    if soulHarvest.cd > 0.1 then
        return
    end
    local raidOrDungeon = __TS__ArrayIncludes(
        {"raid", "party"},
        select(
            2,
            IsInInstance()
        )
    )
    if not raidOrDungeon and not awful.DevMode then
        return
    end
    if awful.player.soulShards >= 3 then
        return
    end
    if awful.player.immobileSince < 3 then
        Alert.sendAlert(
            false,
            soulHarvest.id,
            "Soul Harvest",
            "Stay Immobile for at least 3 seconds",
            nil,
            2,
            Color.WARLOCK
        )
    else
        Alert.sendAlert(
            true,
            soulHarvest.id,
            "Soul Harvest",
            "DO NOT MOVE",
            nil,
            2,
            Color.RED
        )
        soulHarvest:Cast()
    end
end
function demonoLib.personalTips(self)
    if not awful.DevMode then
        return
    end
    if awful.player.combat then
        return
    end
    if not __TS__StringStartsWith(awful.player.name, "Ts") then
        return
    end
    local u = __TS__ArrayFind(
        awful.group,
        function(____, o) return o.name == "Pyrró" end
    )
end
function demonoLib.demonoKicks(self)
    if not ravn.modernConfig:getInterruptStatus() then
        return
    end
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    if p.id ~= 417 then
        return
    end
    if spellLock.cd > 0.5 then
        return
    end
    if awful.focus.exists then
        if spellLock:Castable(awful.focus) then
            if Interrupt:mainInterrupt(awful.focus) ~= IInteruptState.NoKick then
                spellLock:Cast(awful.focus)
            end
        end
        return
    end
    __TS__ArrayForEach(
        awful.enemies,
        function(____, o)
            local condBase = spellLock:Castable(o)
            if condBase and Interrupt:mainInterrupt(o) ~= IInteruptState.NoKick then
                spellLock:Cast(o)
            end
        end
    )
end
function demonoLib.initDemonoSpells(self)
    devourMagic:Callback(
        "base",
        function(spell)
            local p = awful.pet
            if not p or not p.exists or p.dead then
                return
            end
            if p.id ~= 417 then
                return
            end
            local buffToPurge = {77912}
            local u = __TS__ArrayFind(
                awful.enemies,
                function(____, o)
                    return spell:Castable(o) and o.buffUptimeFromTable(buffToPurge) > 0.8
                end
            )
            if not u then
                return
            end
            return spell:Cast(u) and Alert.sendAlert(
                false,
                spell.id,
                "Devour Magic",
                "Purging " .. u.name,
                nil,
                2,
                Color.WARLOCK,
                Color.WHITE
            )
        end
    )
    summonDoomguard:Callback(
        "base",
        function(spell)
            if not ravn.config.useDoomGuard then
                return
            end
            if not awful.player.combat then
                return
            end
            if not awful.target or not awful.target.exists or awful.target.dead or awful.target.friend then
                return
            end
            if not awful.target.isdummy and not awful.encounter then
                return
            end
            local isOptimal = self:optimalTimeBeforeFishingProc()
            if not isOptimal then
                return
            end
            spell:Cast()
            return "wait"
        end
    )
    felArmor:Callback(
        "buff",
        function(spell)
            if awful.player.buff(spell.id) then
                return
            end
            spell:Cast()
        end
    )
    lifeTap:Callback(
        "pre-burst",
        function(spell)
            if awful.player.castIdEx ~= 0 then
                return
            end
            if awful.player.buff(metamorphosis.id) then
                return
            end
            if self:burstReadyIn() > 10 then
                return
            end
            if awful.player.manaPct > 50 then
                return
            end
            if awful.player.hp <= 30 then
                return
            end
            if awful.player.mana >= 80 then
                return
            end
            spell:Cast()
        end
    )
    lifeTap:Callback(
        "nomana",
        function(spell)
            if awful.player.castIdEx ~= 0 then
                return
            end
            if awful.player.manaPct > 25 then
                return
            end
            if awful.player.hp <= 20 then
                return
            end
            spell:Cast()
        end
    )
    lifeTap:Callback(
        "moving",
        function(spell)
            if awful.player.castIdEx ~= 0 then
                return
            end
            if awful.player.hp <= 60 then
                return
            end
            local cid = awful.player.castIdEx
            if cid ~= 0 then
                return
            end
            if awful.player.manaPct > 80 then
                return
            end
            if awful.player.buff(metamorphosis.id) and awful.player.manaPct > 60 then
                return
            end
            local t = awful.target
            if t and t.exists and t.hp < awful.player.manaPct and awful.player.manaPct > 30 then
                return
            end
            if awful.player.movingSince < 1 then
                return
            end
            spell:Cast()
        end
    )
    lifeTap:Callback(
        "unbuffed",
        function(spell)
            if awful.player.castIdEx ~= 0 then
                return
            end
            if awful.player.hp <= 40 then
                return
            end
            if awful.player.mana >= 80 then
                return
            end
            if awful.player.buff(metamorphosis.id) then
                return
            end
            if awful.player.buff(self.DEMON_SOUL_FELGUARD_BUFF) then
                return
            end
            if awful.player.buff(SpellBook.BLOOD_FURY_SPELL_POWER) then
                return
            end
            spell:Cast()
        end
    )
    felFlame:Callback(
        "moving",
        function(spell, t)
            if awful.player.castIdEx ~= 0 then
                return
            end
            if awful.player.movingSince <= 1 then
                return
            end
            spell:Cast(t)
        end
    )
    felFlame:Callback(
        "4p",
        function(spell, t)
            if not awful.player.buff(89937) then
                return
            end
            spell:Cast(t)
        end
    )
    darkIntent:Callback(
        "base",
        function(spell)
            if awful.player.buffRemains(85768, awful.player) > 0 then
                return
            end
            local u = self:bestTargetDarkIntent()
            if not u then
                return
            end
            local ____ = spell:Cast(u) and Alert.sendAlert(
                false,
                spell.id,
                "Dark Intent",
                "Buffing " .. u.name,
                nil,
                2,
                Color.WARLOCK,
                u.color
            )
        end
    )
    summonFelguard:Callback(
        "hard-cast",
        function(spell, t)
            if self:getPetId() == self.FELGUARD_ID then
                return
            end
            if awful.time - self.lastPetCast < 0 then
                return
            end
            if awful.player.castIdEx == spell.id then
                return
            end
            if t.ttd <= 20 then
                return
            end
            if awful.player.soulShards <= 0 then
                return
            end
            if ravn.modernConfig:getDemonoSyncCD() then
                if self:metamorphosisCD() > spell.castTime + awful.gcd * 2 then
                    return
                end
            end
            local ____ = spell:Cast() and Alert.sendAlert(
                false,
                spell.id,
                "Summon Felguard",
                "Hard Cast for Incoming Meta",
                nil,
                2,
                Color.WARLOCK
            )
        end
    )
    incinerate:Callback(
        "proc",
        function(spell, t)
            if not awful.player.buff(self.MOLTEN_CORE) then
                return
            end
            spell:Cast(t)
        end
    )
    soulFire:Callback(
        "proc",
        function(spell, t)
            if not awful.player.buff(self.DECIMATION) then
                return
            end
            spell:Cast(t)
        end
    )
    summonFelguard:Callback(
        "out-of-combat",
        function(spell)
            if awful.time - self.lastPetCast < 0 then
                return
            end
            if awful.player.combat then
                return
            end
            if self:getPetId() == self.FELGUARD_ID then
                return
            end
            spell:Cast()
        end
    )
    baneOfDoom:Callback(
        "base",
        function(spell, t)
            if t.ttd <= 15 then
                return
            end
            local myCond = not t.debuff(spell.id)
            local debugValue = ""
            local debugSeparator = ((Color.LIME .. " | ") .. Color.WHITE) .. " "
            local function reApplyDot(t)
                if not awful.player.buff(metamorphosis.id) then
                    return false
                end
                local cond1 = false
                local isMeta = self:getSnapShotMeta(t, spell.id)
                if not isMeta then
                    cond1 = true
                end
                if t.debuffRemainsFromMe(spell.id) < 45 and t.ttd > 30 then
                    local metaRemains = awful.player.buffRemains(metamorphosis.id)
                    local nextproc = InternalCooldowns:nextProcReadyIn(true)
                    local worse = self:refreshDotValue(t, spell.id) == 0
                    local currentProc = InternalCooldowns:currentProcsRemains()
                    if currentProc > 0 then
                        cond1 = true
                        debugValue = debugValue .. "Refresh because current proc" .. debugSeparator
                    end
                    if metaRemains > 4 and nextproc and nextproc > metaRemains - 3 then
                        if not worse then
                            cond1 = true
                            debugValue = debugValue .. "Refresh because no need to fish in meta and it's better" .. debugSeparator
                        end
                    end
                    if worse then
                        cond1 = false
                    end
                    if worse and t.ttd > 60 and awful.target.isUnit(t) then
                        if metaRemains < awful.gcd * 2 + awful.buffer and metaRemains > 0 then
                            cond1 = true
                            debugValue = "Refresh because meta expires and it's worse but we will get more value" .. debugSeparator
                        end
                    end
                end
                return cond1
            end
            if not myCond then
                myCond = reApplyDot(t)
            end
            if not myCond then
                return
            end
            local already = __TS__ArrayFind(
                awful.enemies,
                function(____, e) return not e.isUnit(t) and e.debuffRemainsFromMe(spell.id) > 0 end
            )
            if already then
                local shouldRefresh = reApplyDot(already)
                if not shouldRefresh then
                    return
                end
            end
            if spell:Cast(t) then
                if debugValue ~= "" then
                    ravnInfo(debugValue, Color.WARLOCK)
                end
            end
        end
    )
    immolationAura:Callback(
        "default",
        function(spell)
            if not awful.player.buff(metamorphosis.id) then
                return
            end
            if not awful.player.combat then
                return
            end
            local t = awful.target
            if not t.exists or t.friend or t.dead then
                return
            end
            if t.distance > 10 then
                return
            end
            if awful.player.buffRemains(metamorphosis.id) <= 10 then
                return
            end
            spell:Cast()
        end
    )
    curseOfTheElements:Callback(
        "base",
        function(spell, t)
            local status = ravn.modernConfig:getDemonoCurseOfTheElements()
            if not status then
                return
            end
            local already = __TS__ArraySome(
                self.SIMILAR_DEBUFF,
                function(____, id) return t.debuff(id) end
            )
            if already then
                return
            end
            spell:Cast(t)
        end
    )
    immolate:Callback(
        "base",
        function(spell, t)
            if self:isOverlapping(t, spell.id) then
                return
            end
            if t.ttd <= 4 then
                return
            end
            if t.debuffRemainsFromMe(spell.id) > 0 then
                if self:isOverlapping(t, handOfGuldan.id) then
                    return
                end
            end
            local refresh = self:refreshDotValue(t, spell.id)
            refresh = refresh + (spell.castTime - 0.1)
            if t.debuffRemainsFromMe(spell.id) > refresh then
                return
            end
            spell:Cast(t)
            return "dotNeeded"
        end
    )
    corruption:Callback(
        "base",
        function(spell, t)
            if self:isOverlapping(t, spell.id) then
                return
            end
            if t.ttd < 6 then
                return
            end
            if t.debuffRemainsFromMe(spell.id) > self:refreshDotValue(t, spell.id) then
                return
            end
            spell:Cast(t)
            return "dotNeeded"
        end
    )
    shadowflame:Callback(
        "base",
        function(spell, t)
            if not self:shadowFlameHit(t) then
                return
            end
            spell:Cast()
        end
    )
    baneOfAgony:Callback(
        "aoe",
        function(spell, t, list)
            if self:isOverlapping(t, spell.id) then
                return
            end
            local already = __TS__ArrayFind(
                list,
                function(____, o) return o.debuffRemainsFromMe(spell.id) > awful.gcd end
            )
            if already then
                return
            end
            local notDoom = __TS__ArrayFilter(
                list,
                function(____, o) return o.ttd > 15 and o.debuffRemainsFromMe(baneOfDoom.id) <= 0 and o.debuffRemainsFromMe(baneOfAgony.id) <= self:refreshDotValue(o, baneOfAgony.id) end
            )
            if #notDoom <= 0 then
                return
            end
            local unit = notDoom[1]
            spell:Cast(notDoom[1])
        end
    )
    shadowBolt:Callback(
        "2-3-spread",
        function(spell, t, list)
            if not self:isPlayingSB() then
                return
            end
            if t.debuffRemainsFromMe(corruption.id) > 0 and t.debuffRemainsFromMe(immolate.id) > 0 then
                if self:shadowAndFlameRemains(t) <= spell.castTime then
                    spell:Cast(t)
                end
            end
            local u = __TS__ArrayFind(
                list,
                function(____, o) return o.debuffRemainsFromMe(corruption.id) > 0 and o.debuffRemainsFromMe(immolate.id) > 0 and self:shadowAndFlameRemains(o) <= spell.castTime end
            )
            if not u then
                return
            end
            spell:Cast(t)
        end
    )
    hellFire:Callback(
        "base",
        function(spell)
            local cid = awful.player.castIdEx
            if cid == spell.id then
                return
            end
            local around = awful.enemies.filter(function(o) return o.distance <= 10 and o.los end)
            if #around < 4 then
                return
            end
            spell:Cast()
        end
    )
    shadowflame:Callback(
        "aoe",
        function(spell, t, list, minCount)
            if minCount == nil then
                minCount = 4
            end
            local count = #__TS__ArrayFilter(
                list,
                function(____, o) return self:shadowFlameHit(o) end
            )
            if count < minCount then
                return
            end
            spell:Cast()
        end
    )
    felStorm:Callback(
        "base",
        function(spell, t)
            if not awful.pet.exists then
                return
            end
            if not ravn.config.demonoFelStorm then
                return
            end
            if awful.pet.dead then
                return
            end
            if self:getPetId() ~= self.FELGUARD_ID then
                return
            end
            if not awful.pet.losOf(t) or not awful.pet.meleeRangeOf(awful.target) then
                return
            end
            spell:Cast()
        end
    )
    summonFelhunter:Callback(
        "post-meta",
        function(spell)
            if awful.time - self.lastPetCast < 0 then
                return
            end
            if spell.id == awful.player.castIdEx then
                return
            end
            if self:getPetId() == self.FELHUNTER_ID then
                return
            end
            if select(
                2,
                IsInInstance()
            ) == "party" then
                return
            end
            if self:felStormRemains() > 0 then
                return
            end
            if felStorm.cd < 5 then
                return
            end
            if not awful.player.buff(soulBurn.id) then
                if awful.player.buff(metamorphosis.id) and awful.player.soulShards > 0 then
                    Alert.sendAlert(
                        false,
                        spell.id,
                        "Summon Felhunter",
                        "Soulburn for Instant Cast",
                        nil,
                        2,
                        Color.WARLOCK
                    )
                    soulBurn:Cast()
                end
            else
                spell:Cast()
                if awful.player.buff(soulBurn.id) then
                    return "wait"
                end
            end
        end
    )
    drainSoul:Callback(
        "snipe",
        function(spell, t, list)
            local shards = awful.player.soulShards
            if shards > 1 then
                return
            end
            local targetBos = UnitClassification("target") == "boss" or UnitClassification("target") == "worldboss"
            if targetBos and t.ttd <= 60 then
                return
            end
            local u = __TS__ArrayFind(
                list,
                function(____, o) return o.ttd <= 2 and spell:Castable(o) end
            )
            if not u then
                return
            end
            local ____ = spell:Cast(u) and Alert.sendAlert(
                false,
                spell.id,
                "Drain Soul",
                "Snipping Shard",
                nil,
                2,
                Color.WARLOCK
            )
        end
    )
    sprintPet:Callback(
        "base",
        function(spell, t)
            if awful.pet.distanceTo(t) < 12 then
                return
            end
            spell:Cast(t)
        end
    )
end
function demonoLib.felGuardInFrontOfBoss(self)
    summonFelguard("out-of-combat")
end
function demonoLib.singleTargetRotation(self, t, fishingLogic)
    if fishingLogic == nil then
        fishingLogic = false
    end
    handOfGuldan:Cast(t)
    immolate("base", t)
    if not fishingLogic then
        baneOfDoom("base", t)
    end
    corruption("base", t)
    if not fishingLogic then
        shadowflame("base", t)
    end
    soulFire("proc", t)
    incinerate("proc", t)
    lifeTap("unbuffed")
    self:filler(t)
end
function demonoLib.twoThreeRotation(self, t, list, fishingLogic)
    if fishingLogic == nil then
        fishingLogic = false
    end
    corruption("base", t)
    if t.debuffRemainsFromMe(immolate.id) > handOfGuldan.castTime then
        handOfGuldan:Cast(t)
    else
        immolate("base", t)
    end
    shadowflame("aoe", t, list, 2)
    if not fishingLogic then
        baneOfDoom("base", t)
    end
    local secondUnit = __TS__ArrayFind(
        list,
        function(____, o) return o.guid ~= t.guid end
    )
    if secondUnit and (secondUnit.ttd > 10 or secondUnit.isdummy) then
        corruption("base", secondUnit)
        immolate("base", secondUnit)
        if not fishingLogic then
            baneOfAgony("aoe", secondUnit, list)
        end
        local thirdUnit = __TS__ArrayFind(
            list,
            function(____, o) return o.guid ~= t.guid and secondUnit and o.guid ~= secondUnit.guid end
        )
        if thirdUnit and (thirdUnit.ttd > 10 or thirdUnit.isdummy) then
            corruption("base", thirdUnit)
            immolate("base", thirdUnit)
        end
    end
    if not fishingLogic then
        shadowflame("aoe", t, list, 2)
    end
    shadowBolt("2-3-spread", t, list)
    self:filler(t)
end
function demonoLib.fourFiveRotation(self, t, list, fishingLogic)
    if fishingLogic == nil then
        fishingLogic = false
    end
    shadowflame("aoe", t, list, 3)
    if t.debuffRemainsFromMe(immolate.id) > handOfGuldan.castTime then
        handOfGuldan:Cast(t)
    else
        immolate("base", t)
    end
    corruption("base", t)
    __TS__ArrayForEach(
        list,
        function(____, o)
            if o.ttd > 10 or o.isdummy then
                immolate("base", o)
                corruption("base", o)
            end
        end
    )
    if not fishingLogic then
        shadowflame("aoe", t, list, 3)
    end
    hellFire("base")
end
function demonoLib.sixPlusRotation(self, t, list)
    shadowflame("aoe", t, list, 4)
    hellFire("base")
end
function demonoLib.filler(self, t)
    local spell = nil
    if awful.player.buff(self.DECIMATION) then
        spell = soulFire
    else
        if self:isPlayingSB() then
            spell = shadowBolt
        else
            spell = incinerate
        end
    end
    if t.ttd <= spell.castTime or awful.player.buff(89937) then
        spell = felFlame
    end
    if not spell then
        return
    end
    if not awful.player.combat then
        if self:isOverlapping(t, spell.id, true) then
            return
        end
    end
    if spell:Castable(t) then
        spell:Cast(t)
    end
end
function demonoLib.getEnemies(self)
    return Memory.caching(
        self.libCache,
        "getEnemies",
        function()
            local units = {}
            __TS__ArrayForEach(
                awful.enemies,
                function(____, o)
                    if o.distance > 45 then
                        return false
                    end
                    if not o.los then
                        return false
                    end
                    if o.health == 1 then
                        return false
                    end
                    if not o.combat and not o.isdummy then
                        return false
                    end
                    if not self:isPveValid(o) then
                        return false
                    end
                    if o.bcc then
                        return false
                    end
                    local status = awful.call("UnitClassification", o.pointer)
                    local isBoss = status == "worldboss" or status == "boss"
                    if not isBoss then
                        if not o.isDummyOrPlayer and (not o.target or not o.target.exists or not o.target.isPlayer) then
                            return false
                        end
                    end
                    units[#units + 1] = {
                        unit = o,
                        ttd = o.ttd,
                        facing = awful.player.facing(o)
                    }
                    return true
                end
            )
            local canCleave = false
            if #units >= 4 then
                local aoeAroundMe = __TS__ArrayFilter(
                    units,
                    function(____, o) return o.unit.distanceLiteral <= 10 end
                )
                if #aoeAroundMe >= 4 then
                    units = aoeAroundMe
                    canCleave = true
                else
                end
            end
            units = __TS__ArraySort(
                units,
                function(____, a, b)
                    return b.ttd - a.ttd
                end
            )
            if not canCleave and #units > 3 then
                units = __TS__ArraySort(
                    units,
                    function(____, a, b)
                        if a.facing == b.facing then
                            if math.abs(a.ttd - b.ttd) < 2 then
                                return a.unit.distance - b.unit.distance
                            end
                            return b.ttd - a.ttd
                        else
                            return a.facing and -1 or 1
                        end
                    end
                )
                local filteredEnemies = __TS__ArrayFilter(
                    units,
                    function(____, o) return o.ttd > 10 end
                )
                if #filteredEnemies >= 3 then
                    units = filteredEnemies
                end
                units = __TS__ArraySlice(units, 0, 3)
            end
            return __TS__ArrayMap(
                units,
                function(____, o) return o.unit end
            )
        end
    )
end
function demonoLib.tips(self)
    if awful.player.buff(metamorphosis.id) then
        local cd = immolationAura.cd
        if not awful.player.buff(immolationAura.id) and cd < 5 then
            local t = awful.target
            if t and t.exists and t.distance > 9 then
                Alert.sendAlert(
                    false,
                    immolationAura.id,
                    "Immolation Aura",
                    "Use it",
                    nil,
                    2,
                    Color.WARLOCK
                )
            end
        end
    end
end
function demonoLib.useVolcanic(self, t)
    if not t or not t.exists or t.isdummy then
        return Alert.sendAlert(true, 0, "DEBUG", "Volcanic Potion")
    end
    if volcanicPot.usable then
        volcanicPot:Use()
    end
end
function demonoLib.prepullSwapGear(self, t, timer)
    local filler = self:isPlayingSB() and shadowBolt or incinerate
    local buffer = filler.castTime + awful.gcd
    buffer = math.floor(buffer * 10) / 10
    if awful.player.buff(metamorphosis.id) then
        self:EquipSetFromName("MAIN")
    end
    if timer <= buffer then
        if metamorphosis.cd <= awful.gcd or awful.player.buff(metamorphosis.id) then
            demonSoul:Cast()
        end
        if self:getPetId() ~= self.FELGUARD_ID then
            soulBurn:Cast()
        end
        if not awful.player.buff(metamorphosis.id) then
            self:EquipSetFromName("MASTERY")
            if self:IsSetEquipped("MASTERY") then
                metamorphosis:Cast()
            end
        end
    end
    if not awful.player.buff(metamorphosis.id) then
        return
    end
    local delay = math.max(0.2, t.distance / 30 - 0.3)
    local timeToStartCastingFiller = filler.castTime + delay
    if timer <= timeToStartCastingFiller + 0.2 then
        self:useVolcanic(t)
    end
    if timer <= filler.castTime + delay then
        if awful.player.castID == filler.id then
            immolate:Cast(t)
        end
        if not self:isOverlapping(t, filler.id) then
            filler:Cast(t)
        end
    end
end
function demonoLib.prepullNoSwap(self, t, timer)
    if timer < 5 then
        if not awful.player.buff(soulBurn.id) then
            soulBurn:Cast()
        end
    end
    if timer <= 1 then
        self:useVolcanic(t)
    end
end
function demonoLib.getDotsValue(self, u)
    local cacheName = "dotsValueDemono" .. u.guid
    return Memory.caching(
        self.libCache,
        cacheName,
        function()
            local value = 0
            if u.debuffRemainsFromMe(corruption.id) > 0 then
                value = self:getSnapshotValue(u, corruption.id)
            end
            if u.debuffRemainsFromMe(baneOfAgony.id) > 0 then
                value = value + self:getSnapshotValue(u, baneOfAgony.id)
            end
            if u.debuffRemainsFromMe(baneOfDoom.id) > 0 then
                value = value + self:getSnapshotValue(u, baneOfDoom.id)
            end
            if u.debuffRemainsFromMe(immolate.id) > 0 then
                value = value + self:getSnapshotValue(u, immolate.id)
            end
            return value
        end
    )
end
function demonoLib.prePullLogic(self, t, timer)
    if awful.player.combat then
        return
    end
    if self.ignoreDbmPull then
        return
    end
    if timer > 9 then
        summonFelguard("out-of-combat")
    end
    if awful.player.channelID == soulHarvest.id and awful.player.soulShards == 3 then
        self:stopCasting("Soul Harvest maxed")
    end
    local condSwapGear = self:GetSetFromName("MASTERY")
    self:prepullSwapGear(t, timer)
end
function demonoLib.postPullCountdown(self)
    local value = awful.pullTimer
    if awful.pullTimer == 1 and self.reached0Pull == 0 then
        self.reached0Pull = awful.time + 1
    end
    if awful.pullTimer == 0 and awful.time - self.reached0Pull > 10 then
        self.reached0Pull = 0
    end
end
function demonoLib.postPullLogic(self, t, list)
    if self.reached0Pull == 0 or awful.time - self.reached0Pull > 10 then
        return
    end
    local timeSincePull = awful.time - self.reached0Pull
    if timeSincePull > 1 then
        sprintPet("base", t)
        felStorm("base", t)
    end
    local soulBurnRemains = awful.player.buffRemains(soulBurn.id)
    if soulBurnRemains > 7 then
        local procRemains = InternalCooldowns:currentProcsRemains()
        local nextProc = InternalCooldowns:nextProcReadyIn()
        if procRemains > awful.gcd and nextProc and nextProc < soulBurnRemains - 7 then
            return "fishing"
        end
    else
        local procRemains = InternalCooldowns:currentProcsRemains()
        if procRemains > 0 then
            return
        end
        local next = InternalCooldowns:nextProcReadyIn(true)
        if next and next <= 5 then
        end
    end
end
function demonoLib.devModeRandomRotation(self)
    if awful.time - self.lastRandom < 10 then
        return
    end
    self.lastRandom = awful.time
    local possibilities = {1, 2, 4, 6}
    local selection = self.lastSelection
    while selection == self.lastSelection do
        selection = possibilities[math.random(1, #possibilities) + 1]
    end
    self.lastSelection = selection
    return selection
end
function demonoLib.printDbg(self, ...)
    local args = {...}
    local cacheName = __TS__ArrayJoin(args, " ")
    local cache = self.dbgValue[cacheName]
    if not cache then
        self.dbgValue[cacheName] = awful.time
        ravnInfo(
            Color.WARLOCK,
            "[DBG]",
            Color.WHITE,
            __TS__ArrayJoin(args, " ")
        )
    end
end
function demonoLib.isPveValid(self, o)
    local encounterID = pveLogic:getEncounterId()
    if encounterID == 0 then
        return true
    end
    local entry = pveLogic.unitCache[o.id]
    if not entry then
        return true
    end
    if entry.encounterId ~= encounterID then
        return true
    end
    if entry.unitType ~= UnitType.REAL_UNIT then
        return false
    end
    if entry:valid(o) == false then
        return false
    end
    return true
end
function demonoLib.damageLoop(self)
    local t = awful.target
    immolationAura("default")
    if summonDoomguard("base") == "wait" then
        return
    end
    if not t.exists or t.friend or not t.los or not self:isPveValid(t) then
        return
    end
    local around = self:getEnemies()
    local length = #around
    if not ravn.config.demonoAoe then
        length = 1
    end
    local timer = self:getDBMTimer()
    if timer > 0 then
        self:prePullLogic(t, timer)
    end
    local one, ____type = IsInInstance()
    if ____type == "raid" or ____type == "party" or ____type == "scenario" then
        if not t.combat then
            return
        end
    end
    if awful.DevMode then
        if t.isdummy and not awful.player.combat then
            return
        end
    end
    self:demoFelStorm(t)
    if self:burstLogic(t) == "wait" then
        return
    end
    if not awful.player.buff(metamorphosis.id) then
        drainSoul("snipe", t, around)
    end
    local isFishing = self:postPullLogic(t, around) == "fishing"
    curseOfTheElements("base", t)
    if length <= 1 then
        self:singleTargetRotation(t, isFishing)
    elseif length <= 3 then
        self:twoThreeRotation(t, around, isFishing)
    elseif length <= 5 then
        self:fourFiveRotation(t, around, isFishing)
    else
        self:sixPlusRotation(t, around)
    end
    lifeTap("moving")
    felFlame("moving", t)
end
demonoLib.petCombackTimer = 0
demonoLib.petAction = ____exports.PET_ACTION.NORMAL
demonoLib.petBehaviour = ____exports.PET_ACTION.NORMAL
demonoLib.MOLTEN_CORE = 71165
demonoLib.DECIMATION = 63167
demonoLib.FELGUARD_ID = 17252
demonoLib.FELHUNTER_ID = 417
demonoLib.SHADOW_AND_FLAME = 17800
demonoLib.CRITICAL_MASS = 22959
demonoLib.DEMON_SOUL_FELGUARD_BUFF = 79462
demonoLib.SIMILAR_DEBUFF = {
    SpellBook.CURSE_OF_THE_ELEMENTS,
    51160,
    48506,
    34889,
    24844,
    58410
}
demonoLib.ignoreDbmPull = false
demonoLib.lastFinishedDbmPull = 0
demonoLib.lastPetCast = 0
demonoLib.lastPetCheck = 0
demonoLib.tickerNefarian = 0
demonoLib.reached0Pull = 0
demonoLib.lastRandom = 0
demonoLib.lastSelection = 0
demonoLib.dbgValue = {}
awful.Populate(
    {
        ["rotation.lock.demono.demonoLib"] = ____exports,
    },
    ravn,
    getfenv(1)
)
