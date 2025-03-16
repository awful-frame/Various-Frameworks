local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local ____exports = {}
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local SOUND = ____alerts.SOUND
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____stompList = ravn["Utilities.Stomp.stompList"]
local IStomps = ____stompList.IStomps
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____arena = ravn["arena.arena"]
local arena = ____arena.arena
local ____library = ravn["rotation.library"]
local Library = ____library.Library
local ____lockspells = ravn["rotation.lock.lockspells"]
local baneOfDoom = ____lockspells.baneOfDoom
local deathCoil = ____lockspells.deathlCoil
local demonicCircleSummon = ____lockspells.demonicCircleSummon
local demonicCircleTeleport = ____lockspells.demonicCircleTeleport
local fear = ____lockspells.fear
local felArmor = ____lockspells.felArmor
local howlOfTerror = ____lockspells.howlOfTerror
local metamorphosis = ____lockspells.metamorphosis
local soulBurn = ____lockspells.soulBurn
local unstableAffliction = ____lockspells.unstableAffliction
____exports.lockLib = __TS__Class()
local lockLib = ____exports.lockLib
lockLib.name = "lockLib"
__TS__ClassExtends(lockLib, Library)
function lockLib.onPortDrop(self)
    self.portInfo = {
        pos = {awful.player.position()},
        lastPortDrop = GetTime()
    }
end
function lockLib.petAttack(self, u)
    if u == nil then
        u = awful.target
    end
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    if not u.exists or not u.enemy then
        return
    end
    if u.isUnit(p.target) then
        return
    end
    if awful.time - self.lastPetCommandTimer < 0.2 then
        return
    end
    if u.bccLock then
        return
    end
    if u.debuff(SpellBook.GOUGE) then
        return
    end
    awful.call("PetAttack", u.pointer)
    self.lastPetCommandTimer = awful.time
end
function lockLib.canPort(self)
    if not awful.player.buff(demonicCircleSummon.id) then
        return false
    end
    if not self.portInfo then
        return false
    end
    return awful.player.distanceToLiteralPos(self.portInfo.pos) <= 40
end
function lockLib.onBuffExpired(self, id)
    local found = false
    if id == self.POWER_TORRENT_BUFF then
        for ____, tracker in ipairs(self.icdTrackers) do
            if tracker.spellid == self.POWER_TORRENT_BUFF then
                tracker.lastCast = awful.time
                found = true
            end
        end
        if not found then
            local ____self_icdTrackers_0 = self.icdTrackers
            ____self_icdTrackers_0[#____self_icdTrackers_0 + 1] = {spellid = self.POWER_TORRENT_BUFF, cd = 45, lastCast = awful.time}
        end
    end
    if id == self.LIGHTWEAVE_BUFF then
        for ____, tracker in ipairs(self.icdTrackers) do
            if tracker.spellid == self.LIGHTWEAVE_BUFF then
                tracker.lastCast = awful.time
                found = true
            end
        end
        if not found then
            local ____self_icdTrackers_1 = self.icdTrackers
            ____self_icdTrackers_1[#____self_icdTrackers_1 + 1] = {spellid = self.LIGHTWEAVE_BUFF, cd = 45, lastCast = awful.time}
        end
    end
    local t1, t2 = self:GetTrinketIds()
    local entry = __TS__ArrayFind(
        self.trinketProcs,
        function(____, o) return o.trinketId == t1 or o.trinketId == t2 end
    )
    if entry then
        for ____, tracker in ipairs(self.icdTrackers) do
            if tracker.spellid == entry.buffid then
                tracker.lastCast = awful.time
                found = true
            end
        end
        if not found then
            local ____self_icdTrackers_2 = self.icdTrackers
            ____self_icdTrackers_2[#____self_icdTrackers_2 + 1] = {spellid = entry.buffid, cd = entry.icd, lastCast = awful.time}
        end
    end
end
function lockLib.addSnapShot(self, u, guid, spellId)
    local cacheName = guid .. tostring(spellId)
    local cache = self.lockCacheBug[cacheName]
    if cache ~= nil then
        return
    end
    self.lockCacheBug[cacheName] = true
    local hasMeta = awful.player.buffRemains(metamorphosis.id) > 0
    local haste = GetCombatRating(CR_HASTE_SPELL)
    if spellId == baneOfDoom.id then
        ravnInfo("Bane of Doom", hasMeta)
    end
    local value = self:consolidatedStats()
    if not u.debuff(spellId) then
        do
            local i = 0
            while i < #self.snapShot do
                if self.snapShot[i + 1].guid == guid and self.snapShot[i + 1].spellId == spellId then
                    __TS__ArraySplice(self.snapShot, i, 1)
                    i = i - 1
                end
                i = i + 1
            end
        end
        local ____self_snapShot_3 = self.snapShot
        ____self_snapShot_3[#____self_snapShot_3 + 1] = {
            guid = guid,
            spellId = spellId,
            time = GetTime(),
            value = value,
            metamorphosis = hasMeta,
            haste = haste
        }
    else
        local i = 0
        local exist = false
        for ____, snap in ipairs(self.snapShot) do
            if snap.guid == guid and snap.spellId == spellId then
                self.snapShot[i + 1].value = value
                self.snapShot[i + 1].time = GetTime()
                self.snapShot[i + 1].metamorphosis = hasMeta
                self.snapShot[i + 1].haste = haste
                exist = true
                return
            end
            i = i + 1
        end
        if not exist then
            local ____self_snapShot_4 = self.snapShot
            ____self_snapShot_4[#____self_snapShot_4 + 1] = {
                guid = guid,
                spellId = spellId,
                time = GetTime(),
                value = value,
                metamorphosis = hasMeta,
                haste = haste
            }
        end
    end
end
function lockLib.getSnapshotValue(self, u, spellId)
    local guid = u.guid
    if u.debuffRemainsFromMe(spellId) <= 0 then
        return 0
    end
    local snap = __TS__ArrayFind(
        self.snapShot,
        function(____, o) return o.guid == guid and o.spellId == spellId end
    )
    if not snap then
        return 0
    end
    return snap.value
end
function lockLib.refreshDotValue(self, unit, spellId)
    local currentValue = self:consolidatedStats()
    local guid = unit.guid
    local timeLeft = awful.gcd
    for ____, snap in ipairs(self.snapShot) do
        if snap.guid == guid and snap.spellId == spellId then
            if currentValue < snap.value then
                timeLeft = 0
            else
                timeLeft = 2
            end
        end
    end
    return timeLeft
end
function lockLib.MovePetTo(self, position)
    if awful.time < self.petMoveTimer then
        return
    end
    if not awful.pet or not awful.pet.exists or awful.pet.dead then
        return
    end
    local posLosCheck = position
    posLosCheck[3] = posLosCheck[3] + 1.5
    if not awful.player.losPositionLiteral(posLosCheck) then
        return
    end
    if awful.pet.rooted or awful.pet.movementFlags == 1024 or awful.pet.cc then
        return
    end
    local distanceFromPos = awful.pet.distanceToLiteralPos(position)
    if distanceFromPos <= 1.2 then
        return
    end
    awful.call("PetMoveTo")
    local x, y, z = unpack(position)
    Click(x, y, z)
    self.petMoveTimer = awful.time + self.PET_REFRESH
end
function lockLib.bestTargetDarkIntent(self)
    local one, ____type = IsInInstance()
    local buffType = "dps"
    local healerWeight = {{wowclass = WowClass.DRUID, value = 1}, {wowclass = WowClass.PRIEST, value = 2}, {wowclass = WowClass.SHAMAN, value = 3}, {wowclass = WowClass.PALADIN, value = 4}}
    local dpsWeight = {{wowclass = WowClass.PRIEST, value = 1}, {wowclass = WowClass.MAGE, value = 2}, {wowclass = WowClass.DRUID, value = 3}, {wowclass = WowClass.SHAMAN, value = 4}}
    if ____type == "none" then
        if awful.pet.exists then
            return awful.pet
        end
    end
    if ____type == "party" or ____type == "raid" or ____type == "arena" then
        local sorted = awful.fullGroup
        sorted = sorted.sort(function(a, b)
            if buffType == "healer" then
                local bEntry = __TS__ArrayFind(
                    healerWeight,
                    function(____, o) return o.wowclass == b.class2 end
                )
                local bValue = bEntry and bEntry.value or 100
                local aEntry = __TS__ArrayFind(
                    healerWeight,
                    function(____, o) return o.wowclass == a.class2 end
                )
                local aValue = aEntry and aEntry.value or 100
                return aValue < bValue
            else
                local bEntry = __TS__ArrayFind(
                    dpsWeight,
                    function(____, o) return o.wowclass == b.class2 end
                )
                local bValue = bEntry and bEntry.value or 100
                local aEntry = __TS__ArrayFind(
                    dpsWeight,
                    function(____, o) return o.wowclass == a.class2 end
                )
                local aValue = aEntry and aEntry.value or 100
                return aValue < bValue
            end
        end)
        return sorted[1]
    end
    return nil
end
function lockLib.getSnapShotHaste(self, u, spellId)
    local guid = u.guid
    local snap = __TS__ArrayFind(
        self.snapShot,
        function(____, o) return o.guid == guid and o.spellId == spellId end
    )
    if not snap then
        return 0
    end
    return snap.haste
end
function lockLib.getSnapShotMeta(self, u, spellId)
    local guid = u.guid
    local snap = __TS__ArrayFind(
        self.snapShot,
        function(____, o) return o.guid == guid and o.spellId == spellId end
    )
    if not snap then
        return false
    end
    return snap.metamorphosis
end
function lockLib.checkGear(self)
    if awful.time - self.lastCheckGearTime < 10 then
        return
    end
    self.lastCheckGearTime = awful.time
    if self:HasPowerTorrent() then
        self.ptEnchant = true
    end
    if self:HasSynapseSpring() then
        self.synapseEnchant = true
    end
    if self:HasLightweaveEmbroidery() then
        self.lightweaveEnchant = true
    end
end
function lockLib.totalFishingProcs(self)
    local count = 0
    if self.lightweaveEnchant then
        count = count + 1
    end
    if self.ptEnchant then
        count = count + 1
    end
    if self.synapseEnchant then
        count = count + 1
    end
    local t1, t2 = self:GetTrinketIds()
    local entry = __TS__ArrayFind(
        self.trinketProcs,
        function(____, o) return o.trinketId == t1 or o.trinketId == t2 end
    )
    if entry then
        count = count + 1
    end
    return count
end
function lockLib.buffFishingProcExpireNext(self)
    local remains = 99
    if self.lightweaveEnchant and awful.player.buff(self.LIGHTWEAVE_BUFF) then
        remains = math.min(
            remains,
            awful.player.buffRemains(self.LIGHTWEAVE_BUFF)
        )
    end
    if self.ptEnchant and awful.player.buff(self.POWER_TORRENT_BUFF) then
        remains = math.min(
            remains,
            awful.player.buffRemains(self.POWER_TORRENT_BUFF)
        )
    end
    if self.synapseEnchant and awful.player.buff(self.SYNAPSE_SPRINGS_BUFF) then
        remains = math.min(
            remains,
            awful.player.buffRemains(self.SYNAPSE_SPRINGS_BUFF)
        )
    end
    local t1, t2 = self:GetTrinketIds()
    local entry = __TS__ArrayFind(
        self.trinketProcs,
        function(____, o) return o.trinketId == t1 or o.trinketId == t2 end
    )
    if entry then
        remains = math.min(
            remains,
            awful.player.buffRemains(entry.buffid)
        )
    end
    return remains
end
function lockLib.fishingRemains(self, maxWaitTime)
    local countWaitProc = 0
    if self.lightweaveEnchant and not awful.player.buff(self.LIGHTWEAVE_BUFF) then
        local internalCD = self:buffProcTimer(self.LIGHTWEAVE_BUFF)
        if internalCD <= maxWaitTime then
            countWaitProc = countWaitProc + 1
        end
    end
    if self.ptEnchant and not awful.player.buff(self.POWER_TORRENT_BUFF) then
        local internalCD = self:buffProcTimer(self.POWER_TORRENT_BUFF)
        if internalCD <= maxWaitTime then
            countWaitProc = countWaitProc + 1
        end
    end
    if self.synapseEnchant and not awful.player.buff(self.SYNAPSE_SPRINGS_BUFF) then
        local cd = self:synapseSpringCD()
        if cd <= maxWaitTime then
            countWaitProc = countWaitProc + 1
        end
    end
    local t1, t2 = self:GetTrinketIds()
    local entry = __TS__ArrayFind(
        self.trinketProcs,
        function(____, o) return o.trinketId == t1 or o.trinketId == t2 end
    )
    if entry then
        local internalCD = self:buffProcTimer(entry.buffid)
        if internalCD <= maxWaitTime then
            countWaitProc = countWaitProc + 1
        end
    end
    return countWaitProc
end
function lockLib.buffProcTimer(self, id)
    for ____, tracker in ipairs(self.icdTrackers) do
        if tracker.spellid == id then
            return math.max(0, tracker.lastCast + tracker.cd - awful.time)
        end
    end
    return 0
end
function lockLib.stats(self)
    local base, current = UnitStat("player", 4)
    local haste = GetCombatRating(CR_HASTE_SPELL)
    local mastery = GetMastery()
    return current, haste, mastery
end
function lockLib.getSpellPower(self)
    return GetSpellBonusDamage(6)
end
function lockLib.consolidatedStats(self)
    local intel, haste, mastery = self:stats()
    local value = haste + mastery + self:getSpellPower()
    if awful.player.buff(79460) then
        value = value * 1.2
    end
    if awful.player.buff(79462) then
        value = value * 1.1
    end
    if awful.player.buff(metamorphosis.id) then
        value = value * 1.6
    end
    if awful.player.buff(80627) then
        local stacks = awful.player.buffStacks(80627) * 0.03
        value = value * (1 + stacks)
    end
    if awful.player.buff(57933) then
        value = value * 1.1
    end
    return value
end
function lockLib.improveSpell(self, spell, dest, shouldStop, onlyImproved)
    if shouldStop == nil then
        shouldStop = false
    end
    if onlyImproved == nil then
        onlyImproved = false
    end
    if spell.id == demonicCircleTeleport.id and awful.arena and awful.player.soulShards > 1 then
        if soulBurn.known and (soulBurn.cd < awful.gcd or awful.player.buff(soulBurn.id)) then
            local melee = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return o.isMelee end
            )
            if melee then
                local shards = awful.player.soulShards
                soulBurn:Cast()
                if shards >= 1 and not awful.player.buff(soulBurn.id) then
                    return
                end
                if awful.player.buff(soulBurn.id) then
                    spell:Cast()
                end
                return
            end
        end
    end
    local function cast(dest)
        if dest then
            if shouldStop then
                spell:Cast(dest, {stopMoving = true})
            else
                spell:Cast(dest)
            end
        else
            if shouldStop then
                spell:Cast({stopMoving = true})
            else
                spell:Cast()
            end
        end
    end
    local cond = IsPlayerSpell(SpellBook.SOULBURN) and soulBurn.cd == 0 and awful.player.soulShards >= 1 or awful.player.buffRemains(soulBurn.id) > 0
    if cond then
        if awful.player.buffRemains(387626) > 0 then
            cast(dest)
        else
            soulBurn:Cast()
        end
    else
        cast(dest)
    end
end
function lockLib.safeToFear(self, t)
    local ct = fear.castTime
    if t.magicEffectImmunityRemains > ct then
        return false
    end
    if t.isDeathing then
        return false
    end
    if t.buffRemains(SpellBook.SPELL_REFLECTION) >= ct then
        return false
    end
    if t.buff(20711) then
        return false
    end
    if t.class2 == WowClass.PALADIN then
        if t.buffRemains(6940) >= ct then
            return false
        end
        if awful.arena then
            if __TS__ArrayFind(
                awful.enemies,
                function(____, o) return o.isPlayer and o.buffRemains(199448) >= ct end
            ) ~= nil then
                return false
            end
        end
    end
    return true
end
function lockLib.willFearLand(self, t)
    local ct = fear.castTime
    if t.cc or t.rooted then
        return true
    end
    if not t.predictLoS(ct) then
        return false
    end
    return true
end
function lockLib.initLockSpells(self)
    felArmor:Callback(
        "base",
        function(spell)
            if self.disableArmor then
                return
            end
            local condition = not awful.player.combat and awful.player.buffRemains(spell.id) <= 10 or not awful.player.buff(spell.id)
            if not condition then
                return
            end
            spell:Cast()
        end
    )
    demonicCircleTeleport:Callback(
        "queue",
        function(spell)
            if not spell:Castable() then
                return
            end
            if spell.cd > awful.gcd then
                return
            end
            local q = Queue.queues[Queue.WARLOCK_PORT]
            if not q then
                return
            end
            if not self.portInfo then
                return
            end
            if not self:canPort() then
                return
            end
            spell:Cast()
        end
    )
    deathCoil:Callback(
        "queue",
        function(spell)
            local q = Queue.queues[Queue.WARLOCK_COIL]
            if not q then
                return
            end
            local t = awful.GetObjectWithGUID(q.unit)
            if not t or not t.exists then
                return
            end
            if not deathCoil:Castable(t) then
                return
            end
            if t.horrorDR == 0 then
                return
            end
            if t.horrorDR ~= 1 and t.horrorDrRemains < 4 then
                return
            end
            if t.debuff(SpellBook.BLIND) then
                return
            end
            local ccRemains = t.ccRemains
            local tth = t.distance / 23
            tth = tth + awful.buffer
            if ccRemains <= tth then
                spell:Cast(t)
            end
            if ccRemains > tth and ccRemains < tth + awful.gcd then
                return "wait"
            end
        end
    )
    howlOfTerror:Callback(
        "auto",
        function(spell)
            if spell.castTime > 0 then
                return
            end
            if awful.arena then
                local tremor = __TS__ArrayFind(
                    awful.totems,
                    function(____, o) return o.id == IStomps.TREMOR.objectId and o.distance < 32 end
                )
                if tremor then
                    return
                end
                local function condFear(t)
                    local condDR = t.fearDR == 1 or t.fearDR == 0.5 and t.fearDrRemains > 6
                    if not condDR then
                        return false
                    end
                    local ccRemains = t.ccRemains <= awful.gcd + awful.buffer
                    if not ccRemains then
                        return false
                    end
                    if not t.los or t.timeInLoS <= 0.5 then
                        return false
                    end
                    if t.distanceLiteral > 9.5 then
                        return false
                    end
                    if t.immuneMagicEffects then
                        return false
                    end
                    if not t.isDummyOrPlayer then
                        return false
                    end
                    if t.friend or t.dead or not t.exists then
                        return false
                    end
                    return true
                end
                local baseList = awful.enemies.filter(function(o) return condFear(o) end)
                if #baseList == GetNumGroupMembers() then
                    local ____ = spell:Cast() and Alert.sendAlert(
                        true,
                        spell.id,
                        "Howl of Terror",
                        "Everyone",
                        SOUND.POSITIVE,
                        3,
                        Color.WARLOCK,
                        Color.WARLOCK
                    )
                end
                if #baseList.filter(function(o) return o.debuffRemainsFromMe(unstableAffliction.id) > 3 and condFear(o) end) >= 2 then
                    local ____ = spell:Cast() and Alert.sendAlert(
                        true,
                        spell.id,
                        "Howl of Terror",
                        "Full DR covered by UA",
                        SOUND.POSITIVE,
                        3,
                        Color.WARLOCK,
                        Color.WARLOCK
                    )
                end
            end
        end
    )
    fear:Callback(
        "auto",
        function(spell)
            if not ravn.modernConfig:getLockAutoFear() then
                return
            end
            if __TS__ArrayIncludes(self.fakeSpellsId, fear.id) then
                if self:delayFake() then
                    return
                end
            end
            local tremor = __TS__ArrayFind(
                awful.totems,
                function(____, o) return o.id == IStomps.TREMOR.objectId and o.distance < 32 end
            )
            if tremor then
                Alert.sendAlert(
                    false,
                    fear.id,
                    "Tremor Totem",
                    "( Fear Cancelled )",
                    nil,
                    3,
                    Color.WARLOCK,
                    Color.SHAMAN
                )
                return
            end
            if self:isOverlapping(awful.player, fear.id, true) then
                return
            end
            local fearBuffer = __TS__ArrayIncludes(self.fakeSpellsId, fear.id) and self:fakeCasting(true) and spell.castTime + awful.gcd + awful.buffer + (spell.castTime + 1) or spell.castTime + awful.gcd + awful.buffer
            local already = __TS__ArrayFind(
                self:getSmartEnemyList(true),
                function(____, o) return o.debuffRemainsFromMe(SpellBook.FEAR) > math.max(0, spell.castTime - awful.gcd) end
            )
            if already then
                return
            end
            if not awful.arena then
                local outOfArena = __TS__ArrayFind(
                    self:getSmartEnemyList(),
                    function(____, o) return o.advancedBurstSince > awful.buffer and o.disorientDR == 1 end
                )
                if outOfArena then
                    spell:Cast(outOfArena)
                end
                return
            end
            local fdps = arena:getFriendDPS()
            local function conditionDR(t)
                local condDR = t.fearDR == 1 or t.fearDR == 0.5 and t.fearDrRemains > 6 or t.fearDR == 0.25 and t.debuffRemains(118699) > 0 or t.fearDrRemains < fear.castTime
                return condDR
            end
            local function conditionUACover(o)
                local requiredCover = ravn.modernConfig:getLockFearUACover()
                if not requiredCover then
                    return true
                end
                if awful.arena and awful.enemyHealer.exists and not o.isHealer then
                    local ccMaxTime = math.max(awful.enemyHealer.ccRemains, awful.enemyHealer.importantLockoutRemains, awful.enemyHealer.silenceRemains)
                    if ccMaxTime < awful.gcd * 2 then
                        return false
                    end
                end
                return o.debuffRemains(unstableAffliction.id) > spell.castTime + awful.gcd * 2.5
            end
            local function conditionHeal(o)
                if not o.exists then
                    return false
                end
                if not spell:Castable(o) then
                    return false
                end
                if o.isUnit(awful.target) then
                    return false
                end
                if fdps and fdps.exists and fdps.target.isUnit(o) and not fdps.isHealer and not fdps.cc then
                    return false
                end
                if not conditionDR(o) then
                    return false
                end
                if not awful.arena then
                    return false
                end
                if not self:willFearLand(o) then
                    return false
                end
                if o.ccRemains > fearBuffer then
                    return false
                end
                if not self:safeToFear(o) then
                    return false
                end
                local maxSilenceTime = math.max(o.silenceRemains, o.importantLockoutRemains)
                if maxSilenceTime > fearBuffer then
                    return false
                end
                return true
            end
            if awful.enemyHealer.exists and spell:Castable(awful.enemyHealer) and conditionHeal(awful.enemyHealer) then
                local ____ = spell:Cast(awful.enemyHealer) and Alert.sendAlert(
                    false,
                    spell.id,
                    "Fear",
                    "On Healer",
                    nil,
                    3,
                    Color.WARLOCK,
                    awful.enemyHealer.color
                )
                return
            end
            if ravn.modernConfig:getLockFearHealerOnly() then
                return
            end
            local dpsReason = ""
            local priority = false
            local function conditionDPS(o)
                if not o.exists then
                    return false
                end
                if not spell:Castable(o) then
                    return false
                end
                local t = o.target
                local oCast = o.castTarget
                if not t.exists and (not oCast or not oCast.exists) and not o.isdummy and o.class2 ~= WowClass.WARLOCK and o.specId ~= 63 then
                    return false
                end
                if not o.isMelee and not self:willFearLand(o) then
                    return false
                end
                if not conditionDR(o) then
                    return false
                end
                if not self:safeToFear(o) then
                    return false
                end
                if not conditionUACover(o) then
                    return false
                end
                if o.ccRemains > fearBuffer then
                    return false
                end
                if o.class2 == WowClass.ROGUE then
                    if o.buffUptime(SpellBook.SHADOW_DANCE) > 0.8 then
                        priority = true
                        dpsReason = "Shadow Dance"
                        return true
                    end
                end
                if o.advancedBurstSince > 0.7 then
                    priority = true
                    dpsReason = "Burst"
                    return true
                end
                if o.isMelee and awful.player.target.isUnit(t) and not o.isUnit(awful.target) then
                    if fdps and not fdps.isHealer and not o.isUnit(fdps.target) then
                        dpsReason = "Melee on me"
                    end
                    return true
                end
            end
            local dps = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return conditionDPS(o) end
            )
            if dps and spell:Castable(dps) then
                if not priority then
                    if self:freeToCastFor() <= spell.castTime then
                        return
                    end
                    local lowest = awful.enemies.lowest
                    if lowest and lowest.exists and lowest.hp <= 60 then
                        return
                    end
                end
                return spell:Cast(dps) and Alert.sendAlert(
                    false,
                    spell.id,
                    "Fear",
                    dpsReason,
                    nil,
                    2,
                    Color.WARLOCK,
                    dps.color
                )
            end
        end
    )
    fear:Callback(
        "queue",
        function(spell)
            if self:isOverlapping(awful.player, fear.id, true) then
                return
            end
            if __TS__ArrayIncludes(self.fakeSpellsId, fear.id) then
                if self:delayFake() then
                    return
                end
            end
            local tremor = __TS__ArrayFind(
                awful.totems,
                function(____, o) return o.id == IStomps.TREMOR.objectId and o.distance < 32 end
            )
            if tremor then
                Alert.sendAlert(
                    false,
                    fear.id,
                    "Tremor Totem",
                    "( Fear Cancelled )",
                    nil,
                    3,
                    Color.WARLOCK,
                    Color.SHAMAN
                )
                return
            end
            local q = Queue.queues[Queue.WARLOCK_FEAR]
            if not q then
                return
            end
            local t = awful.GetObjectWithGUID(q.unit)
            if not t or not t.exists then
                return
            end
            if not self:safeToFear(t) then
                return
            end
            if t.fearDR == 0 then
                return
            end
            local condDR = t.fearDR == 1 or t.fearDR == 0.5 and t.fearDrRemains > 6 or t.fearDR == 0.25 and t.debuffRemains(118699) > 0 or t.fearDrRemains < fear.castTime
            if not condDR then
                return
            end
            local ccRemains = t.ccRemains
            if ccRemains <= fear.castTime + 0.5 + awful.buffer then
                spell:Cast(t)
            end
            if ccRemains <= math.max(awful.gcd + awful.buffer, fear.castTime + awful.buffer) and ccRemains > 0 then
                return "wait"
            end
        end
    )
end
lockLib.PORTAL_ID = 191083
lockLib.DEMONIC_REBIRTH = 88448
lockLib.portInfo = nil
lockLib.petsBack = 0
lockLib.disableArmor = false
lockLib.lastPetCommandTimer = 0
lockLib.LIGHT_WEAVE = 55637
lockLib.POWER_TORRENT = 74241
lockLib.SYNAPSE_SPRINGS = 96230
lockLib.WITCHING_HOUR_BUFF_NORMAL = 90887
lockLib.WITCHING_HOUR_BUFF_HERO = 90885
lockLib.trinketProcs = {{trinketId = 55787, buffid = 90887, icd = 60}, {trinketId = 56320, buffid = 90885, icd = 60}}
lockLib.synapseEnchant = false
lockLib.ptEnchant = false
lockLib.lightweaveEnchant = false
lockLib.LIGHTWEAVE_BUFF = 71572
lockLib.POWER_TORRENT_BUFF = 74241
lockLib.SYNAPSE_SPRINGS_BUFF = 82174
lockLib.icdTrackers = {}
lockLib.snapShot = {}
lockLib.lockCacheBug = {}
lockLib.petMoveTimer = 0
lockLib.PET_REFRESH = 0.07
lockLib.lastCheckGearTime = 0
awful.Populate(
    {
        ["rotation.lock.lockLib"] = ____exports,
    },
    ravn,
    getfenv(1)
)
