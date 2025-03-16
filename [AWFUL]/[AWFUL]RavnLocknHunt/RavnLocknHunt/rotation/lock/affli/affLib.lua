local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArraySort = ____lualib.__TS__ArraySort
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
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
local ____InternalCooldowns = ravn["Utilities.InternalCooldowns.InternalCooldowns"]
local InternalCooldowns = ____InternalCooldowns.InternalCooldowns
local ____awfulSpells = ravn["Utilities.Lists.awfulSpells"]
local healthStone = ____awfulSpells.healthStone
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____stompList = ravn["Utilities.Stomp.stompList"]
local IStomps = ____stompList.IStomps
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ____structures = ravn["Utilities.structures"]
local CREATURE_ID = ____structures.CREATURE_ID
local IInteruptState = ____structures.IInteruptState
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____arena = ravn["arena.arena"]
local arena = ____arena.arena
local ____lockLib = ravn["rotation.lock.lockLib"]
local lockLib = ____lockLib.lockLib
local ____lockspells = ravn["rotation.lock.lockspells"]
local baneOfAgony = ____lockspells.baneOfAgony
local corruption = ____lockspells.corruption
local curseOfTheElements = ____lockspells.curseOfTheElements
local curseOfTongues = ____lockspells.curseOfTongues
local curseOfWeakness = ____lockspells.curseOfWeakness
local curseofExhaustion = ____lockspells.curseofExhaustion
local darkIntent = ____lockspells.darkIntent
local demonArmor = ____lockspells.demonArmor
local demonSoul = ____lockspells.demonSoul
local devourMagic = ____lockspells.devourMagic
local drainSoul = ____lockspells.drainSoul
local fear = ____lockspells.fear
local felArmor = ____lockspells.felArmor
local felFlame = ____lockspells.felFlame
local haunt = ____lockspells.haunt
local healthFunnel = ____lockspells.healthFunnel
local createHS = ____lockspells.createHS
local shadowBite = ____lockspells.shadowBite
local shadowBolt = ____lockspells.shadowBolt
local shadowWard = ____lockspells.shadowWard
local shadowflame = ____lockspells.shadowflame
local soulBurn = ____lockspells.soulBurn
local soulLink = ____lockspells.soulLink
local soulSwap = ____lockspells.soulSwap
local spellLock = ____lockspells.spellLock
local summonFelhunter = ____lockspells.summonFelhunter
local unstableAffliction = ____lockspells.unstableAffliction
local ritualOfSouls = ____lockspells.ritualOfSouls
local lifeTap = ____lockspells.lifeTap
local howlOfTerror = ____lockspells.howlOfTerror
local banish = ____lockspells.banish
local drainSoulWeak = ____lockspells.drainSoulWeak
local drainLifeWeak = ____lockspells.drainLifeWeak
local deathCoil = ____lockspells.deathlCoil
local fleeImp = ____lockspells.fleeImp
local singeMagic = ____lockspells.singeMagic
local whiplash = ____lockspells.whiplash
--- SKILL CAPPED INFOS
-- 
-- 
-- UA First -> Cast if free cast or if nothin else to do
-- Corruption -> 100% uptime -> pets included
-- Bane of Agony -> Mages druid and shaman can dispel
-- Haunt on Kill Target -> Need dots
-- Nightfall (instant) proc
-- Shadowflame
-- Fel Flame -> Not as good -> only if kicked on shadow
-- Drain Soul -> Need 3 sec to tick, only if below 25%
-- Drain Life => Affect pet shadow bite
-- Pet Always attack unit with dots on it
-- 
-- 
-- Corruption => + 20% haste + nightfall proc => Siphon life 
-- 
-- bane of agony => detect dispel so we dont rage reapply it
-- to be used on snakes fro mhunter trap
-- 
-- Jinx makes curse of elements be 40 yard aoe range
-- -> To be used on pet if facing class with pets
-- -> Weakness on melee AFTER THE DOTS (but before UA ?)
-- -> Curse of tongues
-- -> Curse of exhaustion   -> used when melee are looking to get to unit but not connecting -> or their unit is not slowed
-- 
-- -> Soul Swap -> you need to have dot to proc ON EXHALE
-- Almost always soul swap to healer    
-- 
-- Demon SOUL
-- Try to only use it on inhaling full dots
-- Try to have at least a few buffs on ourselves first -> CaN BE DISPELLED
-- -> Try to use it with on proc trinket 
-- 
-- HAUNT: 
-- Only when 3 dots are on target
-- Or can be used on another target - far enough - during exhale on target
-- Only one per unit
-- 
-- FEL FLAME
-- Locked on shadow school
-- Refresh ua
-- Kill totems
-- Execute if NOTHING ELSE
-- 
-- CCs
-- Howl of terror
-- On cd vs shaman => THey can tremor during the fear
-- 
-- Death Coil: 
-- bref
-- 
-- 
-- BURST
-- UA
-- pet attack
-- Corruption
-- Agony
-- Soul Swap Inhale
-- wait for procs
-- curse of elements swap targe if not jinxed
-- Haunt swap target
-- Send pet on new kill target
-- Demon Soul
-- Soul Swap
-- Shadowflame
-- Fel flame spam or nightfall
-- 
-- 
-- OPENER
-- BOX
-- FEL HUNTER
-- Soul Link
-- Fel armor
-- Dark Intent
-- Soul Well
-- 
-- 1. Place TP
-- 2. Ramping dots => Howl of terror
-- Exhale
-- Aplpy on 3rd unit
-- Haunt
-- 
-- Slow down enemy team
-- 
-- 
-- Win Conditions
-- Apply Dots to kt 
-- DOt secondary targzet => Add option not to dot healer when playing with rogue as anexample
-- Enter phase with haunt
-- DC to initiate
-- 
-- 
-- 
-- FEL HUNTER
-- Devour disable auto cast => use it on important dispel
-- riptide, shield, ....
-- 
-- Shadowbite :
____exports.PET_ACTION = PET_ACTION or ({})
____exports.PET_ACTION.NORMAL = 0
____exports.PET_ACTION[____exports.PET_ACTION.NORMAL] = "NORMAL"
____exports.PET_ACTION.MOVE_TO = 1
____exports.PET_ACTION[____exports.PET_ACTION.MOVE_TO] = "MOVE_TO"
____exports.PET_ACTION.RUN_TO_ALLY = 2
____exports.PET_ACTION[____exports.PET_ACTION.RUN_TO_ALLY] = "RUN_TO_ALLY"
____exports.PET_ACTION.PET_FLEE = 3
____exports.PET_ACTION[____exports.PET_ACTION.PET_FLEE] = "PET_FLEE"
____exports.PET_ACTION.COMEBACK = 4
____exports.PET_ACTION[____exports.PET_ACTION.COMEBACK] = "COMEBACK"
____exports.PET_ACTION.ANNOY = 5
____exports.PET_ACTION[____exports.PET_ACTION.ANNOY] = "ANNOY"
____exports.PET_ACTION.ON_HEALER = 6
____exports.PET_ACTION[____exports.PET_ACTION.ON_HEALER] = "ON_HEALER"
____exports.PET_ACTION.TOTEM = 7
____exports.PET_ACTION[____exports.PET_ACTION.TOTEM] = "TOTEM"
____exports.PET_ACTION.BREAK_CC = 8
____exports.PET_ACTION[____exports.PET_ACTION.BREAK_CC] = "BREAK_CC"
____exports.affLib = __TS__Class()
local affLib = ____exports.affLib
affLib.name = "affLib"
__TS__ClassExtends(affLib, lockLib)
function affLib.onRogueRedirectedUnit(self, u)
    if not awful.arena then
        return
    end
    self.rogueRedirectedUnit = u
    C_Timer.After(
        6,
        function()
            self.rogueRedirectedUnit = nil
        end
    )
end
function affLib.onCurseCount(self)
    self.curseCount.timer = awful.time
    local ____self_curseCount_0, ____count_1 = self.curseCount, "count"
    ____self_curseCount_0[____count_1] = ____self_curseCount_0[____count_1] + 1
end
function affLib.onTickCurseCount(self)
    if awful.arena then
        local n = GetNumGroupMembers()
        local enemies = #awful.enemies.filter(function(o) return o.isPlayer end)
        n = math.max(n, enemies)
        self.curseCount.maxCount = n + 1
        self.curseCount.maxTimer = (n + 1) * 2
    else
        self.curseCount.maxCount = 6
        self.curseCount.maxTimer = 10
    end
    if self.curseCount.timer == 0 then
        return
    end
    if awful.time - self.curseCount.timer < self.curseCount.maxTimer then
        return
    end
    self.curseCount.timer = 0
    self.curseCount.count = 0
end
function affLib.holdOnHaunt(self)
    if not awful.player.buff(self.SOUL_SWAP_BUFF) then
        return
    end
    if awful.player.castIdEx ~= haunt.id then
        return
    end
    if awful.player.castTimeLeft <= 0.3 then
        return "wait"
    end
end
function affLib.onFelFlame(self, u)
    local guid = u.guid
    local time = awful.time
    local found = false
    do
        local i = 0
        while i < #self.lastFelFlame do
            if self.lastFelFlame[i + 1].guid == guid then
                self.lastFelFlame[i + 1].time = time
                found = true
                return
            end
            i = i + 1
        end
    end
    if not found then
        local ____self_lastFelFlame_2 = self.lastFelFlame
        ____self_lastFelFlame_2[#____self_lastFelFlame_2 + 1] = {guid = guid, time = time}
    end
end
function affLib.timeSinceLastFF(self, u)
    local guid = u.guid
    local entry = __TS__ArrayFind(
        self.lastFelFlame,
        function(____, o) return o.guid == guid end
    )
    if not entry then
        return 1000
    end
    return awful.time - entry.time
end
function affLib.debugHS(self)
    if awful.time > Global.debugFunction or Global.debugFunction == 0 then
        return
    end
    local f = awful.focus
    if not f or not f.exists then
        return
    end
    if self.tickerTrade > awful.time then
        return
    end
    self.tickerTrade = awful.time + 0.8
    local hsCount = healthStone.count
    if TradeFrame:IsVisible() and hsCount > 0 then
        self:shareItem(healthStone.id)
        return
    end
    if hsCount == 0 then
        if awful.player.castIdEx == 0 then
            if createHS:Castable() then
                createHS:Cast()
            end
        end
    else
        local focus = awful.focus
        if focus and focus.exists and focus.los and focus.distance < 5 and focus.friend and not __TS__ArrayIncludes(self.initiatedTradeList, focus.guid) then
            InitiateTrade(awful.focus.pointer)
            local ____self_initiatedTradeList_3 = self.initiatedTradeList
            ____self_initiatedTradeList_3[#____self_initiatedTradeList_3 + 1] = focus.guid
        end
    end
end
function affLib.tips(self)
    if awful.player.buff(48018) then
        local buffLeft = awful.player.buffRemains(48018)
        if buffLeft <= 30 then
            local timeLeft = math.floor(buffLeft)
            if timeLeft % 2 == 0 then
                Alert.sendAlert(
                    false,
                    SpellBook.DEMONIC_CIRCLE_SUMMON,
                    "TP fades soon",
                    tostring(timeLeft) .. "s",
                    nil,
                    1,
                    Color.WARLOCK,
                    Color.WHITE
                )
            end
        end
    end
end
function affLib.healthStoneLogicArena(self)
    if select(
        2,
        IsInInstance()
    ) ~= "arena" then
        return
    end
    if awful.player.combat then
        return
    end
    if self.tickerTrade > awful.time then
        return
    end
    self.tickerTrade = awful.time + 0.7
    local hsCount = healthStone.count
    if TradeFrame:IsVisible() and hsCount > 0 then
        self:shareItem(healthStone.id)
        return
    end
    if not arena:inPrep() then
        return
    end
    local group = GetNumGroupMembers()
    if group == 2 then
        if hsCount == 0 then
            if awful.player.castIdEx == 0 then
                if createHS:Castable() then
                    createHS:Cast()
                end
            end
        else
            local u = __TS__ArrayFind(
                awful.fullGroup,
                function(____, o) return o.los and not o.isUnit(awful.player) and o.distance <= 5 and not __TS__ArrayIncludes(self.initiatedTradeList, o.guid) end
            )
            if u then
                InitiateTrade(u.pointer)
                local ____self_initiatedTradeList_4 = self.initiatedTradeList
                ____self_initiatedTradeList_4[#____self_initiatedTradeList_4 + 1] = u.guid
            end
        end
    end
    if group >= 3 and ritualOfSouls:Castable() then
        if awful.player.immobileSince < 3 then
            Alert.sendAlert(
                true,
                ritualOfSouls.id,
                "HEALTHSTONE",
                "DO NOT MOVE",
                nil,
                3,
                Color.WARLOCK,
                Color.WHITE
            )
            return
        else
            ritualOfSouls:Cast()
        end
    end
end
function affLib.updateUnitToSF(self, u)
    if not self.IShadowFlameInfo then
        self.IShadowFlameInfo = {
            unit = u,
            time = GetTime()
        }
        return
    end
    if self.IShadowFlameInfo.unit.guid ~= u.guid then
        if awful.time - self.IShadowFlameInfo.time < 1 then
            return
        end
        self.IShadowFlameInfo = {
            unit = u,
            time = GetTime()
        }
        return
    end
    if self.IShadowFlameInfo.unit.guid == u.guid then
        self.IShadowFlameInfo.time = GetTime()
        return
    end
end
function affLib.onDispelledAgony(self, u)
    local found = false
    do
        local i = 0
        while i < #self.dispelledAgony do
            if self.dispelledAgony[i + 1].unitGuid == u.guid then
                self.dispelledAgony[i + 1].time = awful.time
                found = true
            end
            i = i + 1
        end
    end
    if not found then
        local ____self_dispelledAgony_5 = self.dispelledAgony
        ____self_dispelledAgony_5[#____self_dispelledAgony_5 + 1] = {unitGuid = u.guid, time = awful.time}
    end
end
function affLib.soulSwapLostTime(self)
    local value = self.soulSwapJustGotAvailable
    if value == 0 then
        return 0
    end
    return awful.time - value
end
function affLib.update(self)
    local cdSS = soulSwap.cd
    if cdSS <= awful.gcd then
        if self.soulSwapJustGotAvailable == 0 then
            self.soulSwapJustGotAvailable = awful.time
        end
    else
        self.soulSwapJustGotAvailable = 0
    end
    self.uaRefresh = unstableAffliction.castTime + awful.buffer + 2
    if self.IShadowFlameInfo then
        local u = awful.GetObjectWithGUID(self.IShadowFlameInfo.unit.guid)
        if u then
            local facingU = awful.player.facing(u, 150)
            if facingU then
                self.IShadowFlameInfo.startFace = self.IShadowFlameInfo.startFace or awful.time
            else
                self.IShadowFlameInfo.startFace = nil
            end
        else
            self.IShadowFlameInfo = nil
        end
    end
    if shadowflame.cd > 3 or self.IShadowFlameInfo and awful.time - self.IShadowFlameInfo.time > 2 then
        self.IShadowFlameInfo = nil
    end
end
function affLib.secret(self)
    if not awful.DevMode then
        return
    end
    if GetZoneText() ~= "Icecrown" then
        return
    end
    local otherplayers = __TS__ArrayFind(
        awful.units,
        function(____, o) return o.isPlayer and not o.isUnit(awful.player) end
    )
    if otherplayers then
        Alert.sendAlert(
            true,
            0,
            "OTHER PLAYER",
            "OTHER PLAYER",
            nil,
            2,
            Color.WARLOCK,
            Color.WHITE
        )
        return
    end
    local center = {8421.630859375, 3116.1745605469, 588.14282226562}
    local cx, cy, cz = unpack(center)
    local distanceToCenter = awful.player.distanceTo(cx, cy, cz)
    if distanceToCenter > 100 then
        return
    end
    local movementblocked = false
    if awful.player.distanceTo(cx, cy, cz) > 40 then
        local centerPath = awful.path(awful.player, cx, cy, cz)
        if centerPath then
            centerPath.follow()
            movementblocked = true
        end
    end
    local u = __TS__ArrayFind(
        awful.units,
        function(____, o)
            if o.id ~= 30037 then
                return
            end
            if not o.enemy then
                return
            end
            if not o.los then
                return
            end
            if o.distance > 40 then
                return
            end
            if o.dead and o.los and o.lootable and o.distance <= 5 then
                o.setTarget()
                awful.player.interact(o)
            end
            if o.debuff(corruption.id) then
                return
            end
            return true
        end
    )
    if u then
        corruption:Cast(u)
    end
    local body = __TS__ArrayFind(
        awful.dead,
        function(____, o) return o.lootable and o.los and o.distance <= 3 end
    )
    local interacting = false
    if body then
        awful.player.interact(body)
        interacting = true
    end
    local far = __TS__ArrayFind(
        awful.units,
        function(____, o)
            if o.id ~= 30037 then
                return
            end
            if o.distance <= corruption.range then
                return
            end
            if not o.los then
                return
            end
            if o.distance > 60 then
                return
            end
            if o.debuffRemains(corruption.id) > 0 then
                return
            end
            return true
        end
    )
    if far then
        local delta = far.distance - corruption.range + 5
        local x, y, z = awful.player.position()
        local fx, fy, fz = far.position()
        local angle = awful.AnglesBetween(
            x,
            y,
            z,
            fx,
            fy,
            fz
        )
        local a, b, c = unpack(Geometry:projectedPos(
            {awful.player.position()},
            angle,
            delta
        ))
        local path = awful.path(awful.player, a, b, c)
        if path and not movementblocked then
            movementblocked = true
            path.follow()
        end
    end
    if not movementblocked and not interacting then
        local nearestLoot = awful.dead.filter(function(o) return o.lootable and o.los and o.distance > 3 and select(
            3,
            o.position()
        ) < 592 end)
        nearestLoot = nearestLoot.sort(function(a, b)
            return a.distance < b.distance
        end)
        if nearestLoot[1] then
            local mx, my, mz = nearestLoot[1].position()
            local path = awful.path(awful.player, mx, my, mz)
            if path and not movementblocked then
                path.follow()
            end
        end
    end
    return true
end
function affLib.populateTargets(self)
    self.curseOfElementsUnit = nil
    self.targets = {}
    local base = awful.enemies
    local idk, instanceType = IsInInstance()
    if instanceType == "none" then
        base = awful.enemies.filter(function(o) return o.isUnit(awful.target) or o.isUnit(awful.focus) end)
    end
    if instanceType == "pvp" then
        if #awful.enemies > 15 then
            base = awful.enemies.filter(function(o) return o.isUnit(awful.target) or o.isUnit(awful.focus) end)
        end
    end
    __TS__ArrayForEach(
        base,
        function(____, o)
            local baseWeight = 100
            if o.immuneMagicDamage or o.bccLock then
                return
            end
            if o.distance > 50 then
                return
            end
            if o.debuff(curseOfTheElements.id, awful.player) then
                self.curseOfElementsUnit = o
            end
            if awful.arena then
                local friend = arena:getFriendDps()
                if friend and friend.exists and friend.target and friend.target.exists and friend.target.isUnit(o) then
                    baseWeight = baseWeight + 10
                end
            end
            if o.isUnit(awful.target) then
                baseWeight = baseWeight + 1
            end
            local ____self_targets_6 = self.targets
            ____self_targets_6[#____self_targets_6 + 1] = {unit = o, weight = baseWeight, isPlayer = o.isPlayer and 1 or 0, hp = o.hp}
            if awful.arena then
                __TS__ArrayForEach(
                    awful.pets,
                    function(____, o)
                        local weight = 0
                        if o.guid == awful.call("UnitGUID", "arenapet1") or o.guid == awful.call("UnitGUID", "arenapet2") or o.guid == awful.call("UnitGUID", "arenapet3") then
                            weight = weight + 100
                        end
                        if o.isUnit(awful.target) then
                            weight = weight + 1
                        end
                        if weight > 0 then
                            local ____self_targets_7 = self.targets
                            ____self_targets_7[#____self_targets_7 + 1] = {unit = o, weight = weight, isPlayer = o.isPlayer and 1 or 0, hp = o.hp}
                        end
                    end
                )
            end
            if #self.blackList > 0 then
                self.targets = __TS__ArrayFilter(
                    self.targets,
                    function(____, o) return not __TS__ArrayIncludes(self.blackList, o.unit.guid) end
                )
            end
            if #self.targets > 1 then
                table.sort(
                    self.targets,
                    function(a, b)
                        return a.weight > b.weight or a.weight == b.weight and a.isPlayer > b.isPlayer or a.weight == b.weight and b.isPlayer == a.isPlayer and a.hp < b.hp
                    end
                )
            end
        end
    )
end
function affLib.getMainTarget(self, los, onlyPlayer)
    if los == nil then
        los = true
    end
    if onlyPlayer == nil then
        onlyPlayer = false
    end
    if #self.targets == 0 then
        return nil
    end
    local name = ("mainTarget" .. tostring(los)) .. tostring(onlyPlayer)
    return Memory.caching(
        self.libCache,
        name,
        function()
            local auto = ravn.modernConfig:getAffliAutoTarget()
            if not auto and awful.target.exists and awful.target.visible and not awful.target.friend then
                return awful.target
            end
            if #self.targets >= 1 then
                local base = self.targets
                if onlyPlayer then
                    if awful.arena then
                        base = __TS__ArrayFilter(
                            base,
                            function(____, o) return o.isPlayer == 1 end
                        )
                    elseif select(
                        2,
                        IsInInstance()
                    ) == "pvp" then
                        base = __TS__ArrayFilter(
                            self.targets,
                            function(____, o) return o.unit.isDummyOrPlayer end
                        )
                    end
                end
                if los then
                    base = __TS__ArrayFilter(
                        base,
                        function(____, o) return o.unit.los and o.unit.distance <= 40 end
                    )
                end
                if base[1] then
                    local ret = base[1].unit
                    if ret.exists and ret.visible then
                        return ret
                    end
                else
                    return nil
                end
            end
            return nil
        end
    )
end
function affLib.antiReflect(self)
    if not awful.player.combat then
        return
    end
    local reflect = __TS__ArrayFind(
        awful.enemies,
        function(____, o) return curseOfWeakness:Castable(o) and o.buffUptime(SpellBook.SPELL_REFLECTION) >= 0.8 end
    )
    if reflect then
        local ____ = curseOfWeakness:Cast(reflect) and Alert.sendAlert(
            true,
            SpellBook.SPELL_REFLECTION,
            "Remove Reflect",
            nil,
            SOUND.POSITIVE,
            2,
            Color.WHITE
        )
    end
end
function affLib.safeCast(self)
    local cai = awful.player.castIdEx
    local t = awful.player.castTarget
    if cai == healthFunnel.id then
        local p = awful.pet
        if p and p.exists and p.hp > 77 then
            self:stopCasting("STOPCASTING-HP-FUNNEL")
        end
    end
    if cai == 0 or not t or not t.exists then
        return
    end
    local spellIdsCheck = {unstableAffliction.id, fear.id, haunt.id}
    local ctl = awful.player.castTimeLeft
    if cai == unstableAffliction.id or cai == haunt.id or cai == drainSoul.id then
        if t.bccRemainsLock > 0 and t.bccRemainsLock > ctl then
            local bccID = t.bccLock
            local spellname = bccID and GetSpellInfo(bccID) or "UNK"
            local condSapOpener = bccID == SpellBook.SAP and t.isUnit(awful.target)
            if not condSapOpener then
                self:stopCasting("STOPCASTING-BCC " .. spellname)
                return
            end
        end
    end
    if not __TS__ArrayIncludes(spellIdsCheck, cai) then
        return
    end
    if t.magicEffectImmunityRemains > ctl or t.magicDamageImmunityRemains > ctl then
        self:stopCasting("STOPCASTING-immunity - safecast")
        return
    end
    if cai == fear.id then
        if t.ccRemains > 2 + ctl then
            local shouldStop = true
            if shouldStop then
                self:stopCasting("STOPCASTING-cc already")
                return
            end
        end
        if t.buff(210256) and t.buffRemains(210256) >= awful.player.castTimeLeft then
            self:stopCasting("STOPCASTING-sanc")
            return
        end
        local tremor = __TS__ArrayFind(
            awful.totems,
            function(____, o) return o.id == IStomps.TREMOR.objectId and o.distance < 32 end
        )
        if tremor then
            self:stopCasting("STOPCASTING-tremor")
            return
        end
        if t.isDeathing and cai == fear.id then
            self:stopCasting("STOPCASTING-death")
            return
        end
    end
end
function affLib.petIsFree(self)
    return awful.pet and awful.pet.exists and not awful.pet.dead and not awful.pet.cc
end
function affLib.petComeback(self)
    if not self:petIsFree() then
        return false
    end
    local p = awful.pet
    local petTar = awful.pet.target
    if not petTar or not petTar.exists then
        if self.petsBack > awful.time then
            return true
        else
            return false
        end
    end
    local cond1 = p.hp <= 70 and not p.los
    local cond2 = p.hp <= 70 and (p.distance > 10 or not p.los) and __TS__ArrayFind(
        awful.enemies,
        function(____, o) return o.isMelee and p.isUnit(o.target) end
    )
    local cond3 = p.hp <= 60 and awful.player.soulShards < 1
    if awful.time - self.demonicRebirthTimer <= 120 or self.demonicRebirthTimer == 0 or awful.player.soulShards > 1 then
        cond1 = false
        cond2 = false
        cond3 = false
    end
    local cond5 = petTar.bccLock and petTar.isPlayer
    local cond4 = self.petsBack > awful.time
    if cond1 or cond2 or cond3 or cond4 or cond5 then
        if self._petCastTimer == 0 or GetTime() - self._petCastTimer > 0.3 then
            awful.call("RunMacroText", "/petfollow")
            local ____ = self._petCastTimer == GetTime()
        end
        return true
    end
    return false
end
function affLib.petFollowHealer(self)
    if not ravn.modernConfig:getAffliPetFollowHealer() then
        return
    end
    if ravn.next ~= 2 then
        return
    end
    if self:petIsFree() then
        return
    end
    if not awful.arena then
        return
    end
    local h = awful.enemyHealer
    if not h or not h.exists then
        return
    end
    local shouldSendPet = false
    local shouldHoldPet = false
    if h.isDrinking then
        shouldSendPet = true
    elseif h.buff(SpellBook.WATER_SHIELD) then
        if h.isUnit(awful.target) or h.isDrinking or not h.losOf(awful.pet) then
            shouldSendPet = true
        else
            shouldHoldPet = true
        end
    else
        shouldSendPet = true
    end
    if h.bcc or h.debuff(SpellBook.BLIND) or h.debuff(SpellBook.GOUGE) then
        shouldHoldPet = true
    end
    if shouldHoldPet then
        local condStop = awful.pet.distanceTo(h) <= 10 and h.losOf(awful.pet)
        if condStop then
            if awful.pet.speed ~= 0 then
                awful.call("RunMacroText", "/petstay")
            end
        else
            if h.los and h.distance <= 40 then
                self:MovePetTo({h.position()})
            end
        end
        return true
    end
    if shouldSendPet then
        self:petAttack(h)
        return true
    end
end
function affLib.petBreakCC(self)
    local p = awful.pet
    if not awful.arena and not awful.DevMode then
        return
    end
    if not p or not p.exists or p.dead then
        return
    end
    if p.cc then
        return
    end
    if not p.debuff(SpellBook.LIVING_BOMB) then
        return
    end
    local remainFireBomb = p.debuffRemains(SpellBook.LIVING_BOMB)
    local function threshold(o)
        if not o.los then
            return false
        end
        local remain = o.bccRemainsLock
        if remain <= awful.gcd then
            return false
        end
        if remainFireBomb - remain > awful.gcd then
            return false
        end
        local distance = p.distanceTo(o)
        local speed = 12
        local timeToReachUnit = distance / speed
        if timeToReachUnit > remain then
            return false
        end
        return true
    end
    local subList = awful.fullGroup.filter(function(o) return o.isPlayer and threshold(o) end).sort(function(a, b)
        return p.distanceTo(a) <= p.distanceTo(b)
    end)
    if #subList <= 0 then
        return
    end
    local u = subList[1]
    if not u then
        return
    end
    if u.distanceToLiteral(p) > 5 or not p.losOf(u) then
        self:MovePetTo({u.position()})
    end
    return u
end
function affLib.petEatTrap(self)
    if not self:petIsFree() then
        return
    end
    if awful.pet.debuff(SpellBook.BANISH) then
        return
    end
    if not awful.arena and not awful.DevMode then
        return
    end
    local function condition(o)
        if awful.pet.distanceTo(o) > 15 then
            return false
        end
        if o.disorientDR < 0.5 then
            return false
        end
        if not o.isPlayer then
            return false
        end
        return o.debuff(SpellBook.PET_BAD_MANNER) or o.debuff(SpellBook.SCATTER_SHOT)
    end
    local u = __TS__ArrayFind(
        awful.fullGroup,
        function(____, o) return condition(o) end
    )
    if u then
        self:MovePetTo({u.position()})
        return true
    end
    return false
end
function affLib.pvpPetBehavior(self)
    if not awful.player.combat then
        self:setPetPassive()
    end
    self.petStatus = ____exports.PET_ACTION.NORMAL
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    if self:petFollowHealer() then
        self.petStatus = ____exports.PET_ACTION.ON_HEALER
    end
    local explodeUnit = self:petBreakCC()
    if explodeUnit then
        self.petStatus = ____exports.PET_ACTION.BREAK_CC
        Alert.sendAlert(
            false,
            SpellBook.LIVING_BOMB,
            "Breaking CC",
            explodeUnit.name,
            nil,
            2,
            Color.WARLOCK,
            Color.WHITE
        )
        return
    end
    if self.petStompUnit ~= nil then
        if self.petStatus == ____exports.PET_ACTION.ON_HEALER then
            local h = awful.enemyHealer
            if h and h.exists then
                local condStomp = self.petStompUnit.distanceTo(h) <= 10 or self.petStompUnit.distanceTo(h) <= 30 and h.losOf(self.petStompUnit)
                if condStomp then
                    self:petAttack(self.petStompUnit)
                end
            end
        else
            self:petAttack(self.petStompUnit)
        end
    end
    if self:petEatTrap() then
        self.petStatus = ____exports.PET_ACTION.MOVE_TO
        return
    end
    if self:petComeback() then
        self.petStatus = ____exports.PET_ACTION.COMEBACK
    end
    if self.petStatus == ____exports.PET_ACTION.NORMAL then
        local ____table_stickUnit_8
        if self.stickUnit then
            ____table_stickUnit_8 = awful.GetObjectWithGUID(self.stickUnit)
        else
            ____table_stickUnit_8 = nil
        end
        local unitToStick = ____table_stickUnit_8
        if not unitToStick or not unitToStick.exists or not unitToStick.visible or unitToStick.dead or unitToStick.friend then
            unitToStick = nil
        end
        local unit = unitToStick and unitToStick or self:getMainTarget(true, true)
        if unit then
            self:petAttack(unit)
            self:petDamageLoop()
        end
    end
end
function affLib.petDamageLoop(self)
    local t = awful.pet.target
    if not t or not t.exists or t.dead or t.friend then
        return
    end
    shadowBite("base", t)
end
function affLib.LockKicks(self)
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
    __TS__ArrayForEach(
        awful.enemies,
        function(____, o)
            if o.losOf(p) and o.distanceTo(p) <= 32 then
                local condBase = spellLock:Castable(o)
                if condBase and o.isPlayer and Interrupt:mainInterrupt(o) ~= IInteruptState.NoKick then
                    spellLock:Cast(o)
                end
            end
        end
    )
end
function affLib.canDotBreakable(self, spell, t)
    if not t.bccLock then
        return true
    end
    if t.debuff(SpellBook.BLIND) or t.debuff(SpellBook.SAP) then
        return false
    end
    if not t.combat and t.class2 ~= WowClass.ROGUE then
        return false
    end
    local threshold = 3
    if spell.id == baneOfAgony.id then
        threshold = 2
    end
    if spell.id == unstableAffliction.id then
        threshold = threshold + spell.castTime
    end
    if not t.combat then
        threshold = 0
    end
    return t.bccRemainsLock < threshold
end
function affLib.dotUpdate(self)
    self.uaOut = 0
    self.agonyOut = 0
    self.corruptionOut = 0
    self.lowAgony = {}
    self.lowCorruption = {}
    self.lowUa = {}
    local function orderDot(tbl)
        if #tbl <= 1 then
            return
        end
        table.sort(
            tbl,
            function(a, b)
                return a[2] < b[2]
            end
        )
    end
    __TS__ArrayForEach(
        self.targets,
        function(____, e)
            if not e.unit.los then
                return
            end
            local o = e.unit
            local UARemains = o.debuffRemains(unstableAffliction.id, awful.player)
            if UARemains > 0 and UARemains >= self.uaRefresh then
                self.uaOut = self.uaOut + 1
            end
            local ____self_lowUa_9 = self.lowUa
            ____self_lowUa_9[#____self_lowUa_9 + 1] = {o, UARemains}
            local agonyRemains = o.debuffRemains(baneOfAgony.id, awful.player)
            if agonyRemains > 0 and agonyRemains < self.agonyRefresh then
                self.agonyOut = self.agonyOut + 1
                local ____self_lowAgony_10 = self.lowAgony
                ____self_lowAgony_10[#____self_lowAgony_10 + 1] = {o, agonyRemains}
            end
            local corruptionRemains = o.debuffRemains(corruption.id, awful.player)
            if corruptionRemains > 0 and corruptionRemains < self.corruptionRefresh then
                self.corruptionOut = self.corruptionOut + 1
                local ____self_lowCorruption_11 = self.lowCorruption
                ____self_lowCorruption_11[#____self_lowCorruption_11 + 1] = {o, corruptionRemains}
            end
        end
    )
    orderDot(self.lowUa)
    orderDot(self.lowAgony)
    orderDot(self.lowCorruption)
end
function affLib.onTricks(self)
    self.debugValue = {}
    local remains = awful.player.buffRemains(57933)
    if awful.DevMode and remains <= 0 and Global.debugFunction ~= 0 then
        remains = awful.time + 6 - Global.debugFunction
    end
    if remains <= 0 then
        return
    end
    if soulSwap.cd > awful.gcd and not awful.player.buff(self.SOUL_SWAP_BUFF) then
        return
    end
    Alert.sendAlert(
        false,
        57933,
        "Tricks",
        "Tricks",
        nil,
        remains,
        Color.WARLOCK,
        Color.WHITE,
        true
    )
    local gcdAvailable = remains / awful.gcd
    local ftc = self:freeToCastFor() > unstableAffliction.castTime + awful.player.gcdRemains
    local tarRogue = arena:getFriendTarFromClass(WowClass.ROGUE)
    if not tarRogue and awful.target.isdummy then
        tarRogue = awful.target
    end
    if not tarRogue then
        return
    end
    if awful.player.buff(self.SOUL_SWAP_BUFF) then
        local ____table_ISoulSwap_12
        if self.ISoulSwap then
            ____table_ISoulSwap_12 = awful.GetObjectWithGUID(self.ISoulSwap.from.guid)
        else
            ____table_ISoulSwap_12 = nil
        end
        local from = ____table_ISoulSwap_12
        if not from or from.isUnit(tarRogue) then
            return
        end
        if ravn.config.affliBurst and not awful.player.buff(self.DEMONSOUL_BUFF) then
            if awful.player.gcdRemains <= 0.3 and demonSoul:Castable() then
                demonSoul:Cast()
            end
        end
        if soulSwap:Castable(tarRogue, {ignoreGCD = true}) and tarRogue.bccRemainsLock < awful.gcd + awful.buffer then
            soulSwap:Cast(tarRogue)
            return "wait"
        end
        return
    end
    local findMostDottedUnits = __TS__ArraySort(
        __TS__ArrayFilter(
            self.targets,
            function(____, o) return not o.unit.isUnit(tarRogue) and unstableAffliction:Castable(o.unit, {ignoreCasting = true}) end
        ),
        function(____, a, b)
            local uaRemains = a.unit.debuffRemainsFromMe(unstableAffliction.id) >= remains
            local ubRemains = b.unit.debuffRemainsFromMe(unstableAffliction.id) >= remains
            local agonyRemains = a.unit.debuffRemainsFromMe(baneOfAgony.id) >= remains
            local bngonyRemains = b.unit.debuffRemainsFromMe(baneOfAgony.id) >= remains
            local corruptionRemains = a.unit.debuffRemainsFromMe(corruption.id) >= remains
            local bcorruptionRemains = b.unit.debuffRemainsFromMe(corruption.id) >= remains
            local scoreA = (uaRemains and 1 or 0) + (agonyRemains and 1 or 0) + (corruptionRemains and 1 or 0)
            local scoreB = (ubRemains and 1 or 0) + (bngonyRemains and 1 or 0) + (bcorruptionRemains and 1 or 0)
            if not ftc then
                if uaRemains and not ubRemains then
                    return -1
                end
                if not uaRemains and ubRemains then
                    return 1
                end
            end
            return scoreB - scoreA
        end
    )
    local u = findMostDottedUnits[1] and findMostDottedUnits[1].unit or nil
    if not u or not u.exists then
        return
    end
    local statU = self:getDotsValue(u, false)
    local statKT = self:getDotsValue(tarRogue, false)
    if not statU or not statKT or statKT > statU then
        return
    end
    local uaStatus = u.debuffRemainsFromMe(unstableAffliction.id) > 0
    local corStatus = u.debuffRemainsFromMe(corruption.id) > 0
    local agStatus = u.debuffRemainsFromMe(baneOfAgony.id) > 0
    local gcdNeeded = 0
    if not uaStatus then
        gcdNeeded = gcdNeeded + 1
    end
    if not corStatus then
        gcdNeeded = gcdNeeded + 1
    end
    if not agStatus then
        gcdNeeded = gcdNeeded + 1
    end
    gcdNeeded = gcdNeeded + 2
    if gcdNeeded > gcdAvailable then
        return
    end
    if not corStatus and corruption:Castable(u, {ignoreGCD = true}) then
        corruption:Cast(u)
        return "wait"
    end
    if not agStatus and baneOfAgony:Castable(u, {ignoreGCD = true}) then
        baneOfAgony:Cast(u)
        return "wait"
    end
    if not uaStatus and unstableAffliction:Castable(u, {ignoreGCD = true}) then
        if awful.player.castIdEx ~= unstableAffliction.id and (not self.lastCastId or self.lastCastId.id ~= unstableAffliction.id) then
            unstableAffliction:Cast(u)
        end
        return "wait"
    end
    if self:getDotsValue(u, true) ~= nil and soulSwap:Castable(u, {ignoreGCD = true}) then
        local ____ = soulSwap:Cast(u) and Alert.sendAlert(
            true,
            soulSwap.id,
            "SoulSwap on Tricks",
            u.name,
            nil,
            2,
            Color.WARLOCK,
            Color.WHITE
        )
        return "wait"
    end
end
function affLib.shouldUA(self)
    return true
end
function affLib.isPlayingRLS(self)
    return Memory.caching(
        self.libCache,
        "isPlayingRLS",
        function()
            return awful.arena and __TS__ArrayFind(
                awful.friends,
                function(____, o) return o.class2 == WowClass.ROGUE and o.isPlayer end
            )
        end
    )
end
function affLib.rogueTimeToEnergy(self, unit, amountWanted)
    local energy = unit.energy
    if energy >= amountWanted then
        return 0
    end
    local haste = awful.call("UnitSpellHaste", unit.pointer)
    local energyPerSec = 10 + haste * 0.1
    local timeToEnergy = (amountWanted - energy) / energyPerSec
    return timeToEnergy
end
function affLib.soulSwapRLS(self)
    return Memory.caching(
        self.libCache,
        "soulSwapRLS",
        function()
            if not self:isPlayingRLS() then
                return
            end
            local tar = arena:getFriendTarFromClass(WowClass.ROGUE)
            local rogue = __TS__ArrayFind(
                awful.friends,
                function(____, o) return o.class2 == WowClass.ROGUE and o.isPlayer end
            )
            if not rogue then
                return
            end
            if not tar then
                return
            end
            if tar.immuneMagic then
                return
            end
            if self.rogueRedirectedUnit and tar.isUnit(self.rogueRedirectedUnit) then
                local cond1 = rogue.buff(SpellBook.SHADOW_DANCE)
                local cond2 = rogue.cd(SpellBook.SHADOW_DANCE) <= awful.gcd
                if cond1 or cond2 then
                    return tar
                end
            end
            if tar.stunned then
                local cond1 = rogue.buff(SpellBook.SHADOW_DANCE)
                if cond1 then
                    return tar
                end
            end
        end
    )
end
function affLib.getHauntTarget(self)
    local opti = ravn.modernConfig:getAffliOptiHaunt()
    if self:isPlayingRLS() then
        local rogueTar = arena:getFriendTarFromClass(WowClass.ROGUE)
        if rogueTar then
            local cond1 = rogueTar.debuff(SpellBook.KIDNEY_SHOT)
            local cond2 = rogueTar.debuff(SpellBook.CHEAP_SHOT)
            local cond3 = rogueTar.hp <= 50
            local cond4 = not rogueTar.isMelee and rogueTar.debuff(SpellBook.GARROTE)
            if cond1 or cond2 or cond3 or cond4 then
                local canSend = self:getDotsValue(rogueTar, true)
                if canSend then
                    return rogueTar
                end
            end
        end
    end
    if not opti then
        return self:getMainTarget(true, true)
    else
        local bestU = nil
        local bestScore = 0
        __TS__ArrayForEach(
            self.targets,
            function(____, o)
                if o.isPlayer and haunt:Castable(o.unit) then
                    local score = self:getDotsValue(o.unit, true)
                    if score and score > bestScore then
                        bestScore = score
                        bestU = o.unit
                    end
                end
            end
        )
        return bestU
    end
end
function affLib.canShadowFlame(self)
    local bcc = __TS__ArrayFind(
        awful.enemies,
        function(____, o) return o.isPlayer and o.bccLock and o.distanceLiteral <= 12 and awful.player.facing(o, 170) and o.los end
    )
    return bcc == nil
end
function affLib.alreadyHaunt(self)
    return __TS__ArrayFind(
        self.targets,
        function(____, o) return o.unit.debuffRemainsFromMe(haunt.id) > haunt.castTime end
    )
end
function affLib.singeMagicBuggedBtw(self)
    if awful.time - self.lastSingeCall < 0.1 then
        return
    end
    self.lastSingeCall = awful.time
    local p = awful.pet
    if not p or not p.exists or p.dead or p.cc or p.id ~= self.IMP_ID then
        return
    end
    if not singeMagic.known then
        return
    end
    if singeMagic.cd > 0 then
        return
    end
    local buffsToDispel = {
        118,
        228,
        28272,
        28271,
        61305,
        61025,
        61721,
        61780,
        3355,
        SpellBook.HAMMER_OF_JUSTICE
    }
    local buffId = 0
    local u = __TS__ArrayFind(
        awful.fullGroup,
        function(____, o)
            if not o.isPlayer then
                return false
            end
            if not o.losOf(p) then
                return false
            end
            if o.distance > singeMagic.range then
                return false
            end
            local id = o.debuffUptimeFromTableEx(buffsToDispel, 0.8)
            if id ~= 0 then
                buffId = id
                return true
            end
        end
    )
    if u and buffId ~= 0 then
        local spellname = GetSpellInfo(buffId) or "UNKNOWN SPELL"
        awful.call("CastSpellByID", singeMagic.id, u.pointer)
        Alert.sendAlert(
            true,
            singeMagic.id,
            "Trying to dispel " .. spellname,
            " on " .. u.name,
            SOUND.POSITIVE,
            2,
            Color.WARLOCK,
            u.name
        )
    end
end
function affLib.initAffliSpells(self)
    curseOfTongues:Callback(
        "gargoyle",
        function(spell)
            if not awful.arena then
                return
            end
            awful.gargoyles.loop(function(o)
                if not o.friend and spell:Castable(o) and not o.buff(spell.id) and o.ccRemains <= 3 then
                    local ____ = spell:Cast(o) and Alert.sendAlert(
                        false,
                        49206,
                        "Curse of Tongues",
                        " on gargoyle ",
                        SOUND.POSITIVE,
                        2,
                        Color.WARLOCK,
                        o.name
                    )
                end
            end)
        end
    )
    whiplash:Callback(
        "base",
        function(spell)
            local p = awful.pet
            if not self:petIsFree() then
                return
            end
            if not awful.DevMode and not awful.arena then
                return
            end
            if p.id ~= self.SUCCUBUS_ID then
                return
            end
            __TS__ArrayForEach(
                awful.enemies,
                function(____, o)
                    if o.isMelee then
                        local tar = o.target
                        if tar and tar.exists and tar.friend and (tar.stunned or tar.hp <= 60 or tar.importantLockoutRemains > 0) then
                            if o.distanceTo(tar) <= 7 and not o.isGapclosing then
                                local p = self:determineAoeBumpOrigin(
                                    o,
                                    spell,
                                    5,
                                    5,
                                    true
                                )
                                if p ~= nil then
                                    local x, y, z = unpack(p)
                                    local ____ = spell:AoECast(x, y, z) and Alert.sendAlert(
                                        true,
                                        spell.id,
                                        "Whiplash",
                                        " on " .. tar.name,
                                        SOUND.POSITIVE,
                                        2,
                                        Color.WARLOCK,
                                        tar.name
                                    )
                                end
                            end
                        end
                    end
                end
            )
        end
    )
    fleeImp:Callback(
        "base",
        function(spell)
            local p = awful.pet
            if not p or not p.exists or p.dead then
                return
            end
            if p.id ~= self.IMP_ID then
                return
            end
            if not p.stunned then
                return
            end
            return spell:Cast() and Alert.sendAlert(
                false,
                spell.id,
                "Flee Imp",
                "Stunned",
                SOUND.POSITIVE,
                2,
                Color.WARLOCK,
                Color.WHITE
            )
        end
    )
    singeMagic:Callback(
        "auto",
        function(spell)
            local buffsToDispel = {
                118,
                228,
                28272,
                28271,
                61305,
                61025,
                61721,
                61780,
                3355
            }
            local p = awful.pet
            if not p or not p.exists or p.dead or p.cc then
                return
            end
            if p.id ~= self.IMP_ID then
                return
            end
            local buffId = 0
            local u = __TS__ArrayFind(
                awful.fullGroup,
                function(____, o)
                    if not o.isPlayer then
                        return false
                    end
                    local id = o.debuffUptimeFromTableEx(buffsToDispel, 0.8)
                    if id ~= 0 then
                        buffId = id
                        return true
                    end
                end
            )
            if u and buffId ~= 0 then
                local spellname = GetSpellInfo(buffId) or "UNKNOWN SPELL"
                return spell:Cast(u) and Alert.sendAlert(
                    true,
                    spell.id,
                    "Trying to dispel " .. spellname,
                    " on " .. u.name,
                    SOUND.POSITIVE,
                    2,
                    Color.WARLOCK,
                    u.name
                )
            end
        end
    )
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
            local theID = 0
            local unit = __TS__ArrayFind(
                awful.enemies,
                function(____, o)
                    if o.isPlayer and spell:Castable(o) then
                        local id = self:hasImportantPurge(o, 0.9)
                        if id ~= 0 then
                            theID = id
                            return true
                        end
                    end
                    return false
                end
            )
            if theID ~= 0 and unit then
                local spellname = GetSpellInfo(theID) or "UNKNOWN SPELL"
                return spell:Cast(unit) and Alert.sendAlert(
                    true,
                    spell.id,
                    "Trying to dispel " .. spellname,
                    " on " .. unit.name,
                    SOUND.POSITIVE,
                    2,
                    Color.WARLOCK,
                    unit.name
                )
            end
            local inBG = select(
                2,
                IsInInstance()
            ) == "pvp"
            if inBG or GetNumGroupMembers() == 2 and awful.arena then
                local importantClassesToPurge = {WowClass.MAGE, WowClass.PALADIN, WowClass.PRIEST}
                local u = __TS__ArrayFind(
                    awful.enemies,
                    function(____, o) return spell:Castable(o) and o.purgeCount > 0 and (__TS__ArrayIncludes(importantClassesToPurge, o.class2) or inBG) end
                )
                if u then
                    return spell:Cast(u)
                end
            end
        end
    )
    devourMagic:Callback(
        "mc",
        function(spell)
            local p = awful.pet
            if not p or not p.exists or p.dead then
                return
            end
            if p.id ~= 417 then
                return
            end
            local mc = __TS__ArrayFind(
                awful.group,
                function(____, o) return spell:Castable(o) and o.debuff(SpellBook.MIND_CONTROL) end
            )
            if not mc then
                return
            end
            return spell:Cast(mc) and Alert.sendAlert(
                true,
                spell.id,
                "Trying to dispel Mind Control",
                " on " .. mc.name,
                SOUND.POSITIVE,
                2,
                Color.WARLOCK,
                mc.name
            )
        end
    )
    lifeTap:Callback(
        "base",
        function(spell)
            local cond1 = awful.player.hp > 90 and awful.player.manaPct < 70
            local cond2 = awful.player.hp >= 50 and awful.player.manaPct <= 35
            if not cond1 and not cond2 then
                return
            end
            spell:Cast()
        end
    )
    deathCoil:Callback(
        "auto-rls",
        function(spell)
            if not self:isPlayingRLS() then
                return
            end
            local t = arena:getFriendTarFromClass(WowClass.ROGUE)
            local rogue = __TS__ArrayFind(
                awful.friends,
                function(____, o) return o.class2 == WowClass.ROGUE and o.isPlayer end
            )
            if not rogue or not t then
                return
            end
            if t.hp > 60 then
                return
            end
            if t.immuneMagic then
                return
            end
            if not spell:Castable(t) then
                return
            end
            if t.bccLock then
                return
            end
            if t.debuff(SpellBook.BLIND) then
                return
            end
            local energy = rogue.energy
            local tth = t.distance / 23 + awful.buffer
            local rogueCanGarrote = (t.isHealer or t.isCaster) and rogue.buffRemains(SpellBook.SHADOW_DANCE) >= t.stunRemains and energy > 40 and not rogue.disarmed and not rogue.cc and rogue.losOf(t) and rogue.meleeRangeOf(t)
            local debuffReferal = rogueCanGarrote and SpellBook.GARROTE or SpellBook.KIDNEY_SHOT
            local ccRemains = t.debuffRemains(debuffReferal)
            if ccRemains > awful.gcd + awful.buffer * 4 or math.max(t.silenceDRRemains, ccRemains) <= 0 then
                return
            end
            if ccRemains <= tth then
                return spell:Cast(t) and Alert.sendAlert(
                    true,
                    spell.id,
                    "Death Coil Finisher",
                    "On " .. t.name,
                    SOUND.POSITIVE,
                    2,
                    Color.WARLOCK,
                    t.color
                )
            end
            Alert.sendAlert(
                false,
                spell.id,
                "Death Coil Inc",
                "On " .. t.name,
                SOUND.POSITIVE,
                2,
                Color.WARLOCK,
                t.color
            )
            return "wait"
        end
    )
    deathCoil:Callback(
        "auto",
        function(spell)
            if not awful.arena then
                return
            end
            local t = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return o.class2 == WowClass.PRIEST end
            )
            if t and t.buff(SpellBook.INNER_FOCUS) and spell:Castable(t, {ignoreFacing = true}) then
                local lowest = awful.enemies.lowest
                local condHP = lowest and lowest.exists and lowest.hp < 50
                if condHP then
                    local tth = t.distance / 23 + awful.buffer
                    local ccRemains = math.max(t.ccRemains, t.silenceRemains, t.importantLockoutRemains)
                    if ccRemains < awful.gcd + awful.buffer * 4 then
                        if ccRemains <= tth then
                            if not awful.player.facing(t) then
                                t.face()
                            end
                            local ____ = spell:Cast(t) and Alert.sendAlert(
                                true,
                                spell.id,
                                "Death Coil on Inner Focus",
                                "On " .. t.name,
                                SOUND.POSITIVE,
                                2,
                                Color.WARLOCK,
                                t.color
                            )
                        else
                            Alert.sendAlert(
                                false,
                                spell.id,
                                "Death Coil Inc",
                                "Inner Focus",
                                SOUND.POSITIVE,
                                2,
                                Color.WARLOCK,
                                t.color
                            )
                        end
                        return "wait"
                    end
                end
            end
        end
    )
    curseOfTheElements:Callback(
        "pets",
        function(spell)
            if not awful.arena then
                return
            end
            local already = false
            local o = __TS__ArrayFind(
                awful.pets,
                function(____, o)
                    if o.friend then
                        return false
                    end
                    if not spell:Castable(o) then
                        return false
                    end
                    if o.debuffRemainsFromMe(spell.id) > 0 then
                        already = true
                        return false
                    end
                    return true
                end
            )
            if not o then
                return
            end
            local u = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return o.distanceTo(o) <= 40 and not o.debuff(self.JINX_DEBUFF) end
            )
            if not u then
                return
            end
            local ____ = spell:Cast(o) and Alert.sendAlert(
                false,
                spell.id,
                "Curse of Elements",
                " Jinx Enablement ",
                SOUND.POSITIVE,
                2,
                Color.WARLOCK,
                u.class2
            )
        end
    )
    shadowWard:Callback(
        "base",
        function(spell, hp)
            if hp == nil then
                hp = 100
            end
            if awful.player.hp > hp then
                return
            end
            local ids = {
                SpellBook.VAMPIRIC_TOUCH,
                SpellBook.BLACK_ARROW,
                SpellBook.CORRUPTION,
                SpellBook.BANE_OF_AGONY,
                SpellBook.UNSTABLE_AFFLICTION,
                59879,
                SpellBook.DEVOURING_PLAGUE
            }
            local found = false
            for ____, debuff in ipairs(ids) do
                if not found and awful.player.debuffUptime(debuff) > 0.5 and awful.player.debuffRemains(7) then
                    found = true
                end
            end
            if not found then
                return
            end
            spell:Cast()
        end
    )
    felArmor:Callback(
        "base",
        function(spell)
            if not awful.player.buff(spell.id) and not awful.player.buff(demonArmor.id) then
                spell:Cast()
            end
        end
    )
    soulLink:Callback(
        "base",
        function(spell)
            local p = awful.pet
            if not p or not p.exists or p.dead then
                return
            end
            if p.cc or p.debuff(banish.id) then
                return
            end
            if not awful.player.buff(25228) then
                spell:Cast()
            end
        end
    )
    darkIntent:Callback(
        "base",
        function(spell)
            local p = awful.pet
            if awful.player.buff(85768) then
                return
            end
            if not self:petIsFree() then
                return
            end
            if awful.pet.debuff(banish.id) then
                return
            end
            if not awful.arena then
                if not p or not p.exists or p.dead then
                    return
                end
                spell:Cast(p)
            else
                if GetNumGroupMembers() == 2 then
                    local x = __TS__ArrayFind(
                        awful.friends,
                        function(____, o) return o.isPlayer and spell:Castable(o) end
                    )
                    if x then
                        spell:Cast(x)
                    end
                else
                    local x = self:bestTargetDarkIntent()
                    if x then
                        spell:Cast(x)
                    end
                end
            end
        end
    )
    demonArmor:Callback(
        "base",
        function(spell)
            if awful.player.buff(spell.id) then
                return
            end
            if self.disableArmor then
                return
            end
            local u = __TS__ArrayFind(
                self.targets,
                function(____, o) return o.isPlayer and o.unit.target.isUnit(awful.player) and (o.unit.isMelee and o.unit.distance <= 15 or o.unit.class2 == WowClass.HUNTER) end
            )
            if u ~= nil then
                spell:Cast()
            end
        end
    )
    banish:Callback(
        "base",
        function(spell)
            if self:isOverlapping(awful.target, spell.id, true) then
                return
            end
            local instanceType = select(
                2,
                IsInInstance()
            )
            if instanceType ~= "pvp" and instanceType ~= "arena" then
                return
            end
            local felHunter = nil
            local already = false
            awful.felHunters.loop(function(o)
                if spell:Castable(o) and not o.friend then
                    local id = o.guid == awful.call("UnitGUID", "arenapet1") and 1 or (o.guid == awful.call("UnitGUID", "arenapet2") and 2 or (o.guid == awful.call("UnitGUID", "arenapet3") and 3 or 0))
                    local cd = 0
                    local creator = o.creator
                    if creator and creator.visible and creator.exists then
                        cd = creator.cd(19647)
                    end
                    if cd > 0 and cd < spell.castTime + awful.gcd * 2 then
                        if o.banishDR == 1 then
                            felHunter = o
                        end
                    end
                    local ccRemains = o.ccRemains
                    if cd < ccRemains and ccRemains > 0 and ccRemains < spell.castTime + awful.gcd then
                        if o.banishDR == 1 then
                            felHunter = o
                        end
                    end
                end
                if o.debuffRemainsFromMe(spell.id) > spell.castTime then
                    already = true
                end
            end)
            if already then
                return
            end
            if not felHunter then
                return
            end
            local ____ = spell:Cast(felHunter) and Alert.sendAlert(true, spell.id, "Banish Pet")
        end
    )
    healthFunnel:Callback(
        "base",
        function(spell, hpThreshold)
            if hpThreshold == nil then
                hpThreshold = 70
            end
            local p = awful.pet
            if not p or not p.exists or p.dead then
                return
            end
            if hpThreshold > 50 and awful.player.soulShards > 0 then
                return
            end
            if p.distanceLiteral > 45 or not p.los then
                return
            end
            if p.hp > hpThreshold then
                return
            end
            if awful.player.soulShards >= 2 then
                return
            end
            if self.demonicRebirthTimer == 0 or awful.time - self.demonicRebirthTimer > 120 then
                return
            end
            spell:Cast(p)
        end
    )
    shadowBolt:Callback(
        "nightfall",
        function(spell)
            if awful.player.buffUptime(self.SHADOW_TRANCE) < 0.88 or not awful.player.buff(self.SHADOW_TRANCE) then
                return
            end
            local ____awful_arena_13
            if awful.arena then
                ____awful_arena_13 = true
            else
                ____awful_arena_13 = false
            end
            local onlyplayer = ____awful_arena_13
            local t = self:getMainTarget(true, onlyplayer)
            if not t or not t.exists then
                return
            end
            spell:Cast(t)
        end
    )
    unstableAffliction:Callback(
        "HIGHEST_PRIO",
        function(spell)
            if awful.player.buff(self.SOUL_SWAP_BUFF) then
                return
            end
            if not ravn.modernConfig:getAffliMaxPrioUA() then
                return
            end
            if __TS__ArrayIncludes(self.fakeSpellsId, spell.id) then
                if self:delayFake() then
                    return
                end
            end
            local tars = __TS__ArrayFilter(
                self.targets,
                function(____, e)
                    local o = e.unit
                    if not o or not o.exists then
                        return false
                    end
                    if not o.isDummyOrPlayer then
                        return false
                    end
                    if o.debuffRemainsFromMe(spell.id) > self.uaRefresh then
                        return false
                    end
                    if not spell:Castable(o) then
                        return false
                    end
                    if not self:canDotBreakable(spell, o) then
                        return false
                    end
                    if self:isOverlapping(o, spell.id) then
                        return
                    end
                    if not self:willSpellLand(spell, o) then
                        return false
                    end
                    return true
                end
            )
            if #tars == 0 then
                return
            end
            local t = tars[1].unit
            if not t or not t.exists or not t.visible then
                return
            end
            spell:Cast(t)
        end
    )
    unstableAffliction:Callback(
        "base",
        function(spell, playerOnly, bypassSoulSwap)
            if playerOnly == nil then
                playerOnly = false
            end
            if bypassSoulSwap == nil then
                bypassSoulSwap = false
            end
            if awful.player.buff(self.SOUL_SWAP_BUFF) then
                return
            end
            if __TS__ArrayIncludes(self.fakeSpellsId, spell.id) then
                if self:delayFake() then
                    return
                end
            end
            if self:canLaunchSoulSwap() and not bypassSoulSwap then
                local otherT = self:getMainTarget(true, true)
                if otherT and otherT.exists then
                    local cid = awful.player.castIdEx
                    if cid == spell.id then
                        return
                    end
                    local missingDots = self:getDotsValue(otherT, true)
                    if not missingDots then
                        return
                    end
                end
            end
            local should = self:shouldUA()
            if not should then
                return
            end
            local tars = __TS__ArrayFilter(
                self.targets,
                function(____, e)
                    local o = e.unit
                    if not o or not o.exists then
                        return false
                    end
                    if playerOnly and not o.isDummyOrPlayer then
                        return false
                    end
                    if o.debuffRemainsFromMe(spell.id) > self.uaRefresh then
                        return false
                    end
                    if not spell:Castable(o) then
                        return false
                    end
                    if not self:canDotBreakable(spell, o) then
                        return false
                    end
                    if self:isOverlapping(o, spell.id) then
                        return
                    end
                    return true
                end
            )
            if #tars == 0 then
                return
            end
            local t = tars[1].unit
            if not t or not t.exists or not t.visible then
                return
            end
            if awful.player.moving then
                Alert.sendAlert(
                    true,
                    spell.id,
                    "DO NOT MOVE",
                    "( CAN UA SAFELY )",
                    SOUND.POSITIVE,
                    2,
                    Color.WARLOCK,
                    Color.WHITE
                )
            end
            spell:Cast(t)
        end
    )
    drainSoulWeak:Callback(
        "weak",
        function(spell)
            local t = self:getMainTarget(true, true)
            if not t or not t.exists or t.bccLock then
                return
            end
            spell:Cast(t)
        end
    )
    drainLifeWeak:Callback(
        "weak",
        function(spell)
            local t = self:getMainTarget(true, true)
            if not t or not t.exists or t.bccLock then
                return
            end
            if awful.player.castIdEx == spell.id then
                return
            end
            spell:Cast(t)
        end
    )
    corruption:Callback(
        "mt-only",
        function(spell)
            local t = self:getMainTarget(true, true)
            if not t or not t.exists or not self:canDotBreakable(spell, t) then
                return
            end
            if t.debuffRemainsFromMe(spell.id) > self:refreshDotValue(t, spell.id) then
                return
            end
            spell:Cast(t)
        end
    )
    baneOfAgony:Callback(
        "mt-only",
        function(spell)
            local t = self:getMainTarget(true, true)
            if not t or not t.exists or not self:canDotBreakable(spell, t) then
                return
            end
            if t.debuffRemainsFromMe(spell.id) > self:refreshDotValue(t, spell.id) then
                return
            end
            spell:Cast(t)
        end
    )
    unstableAffliction:Callback(
        "mt-only",
        function(spell)
            if awful.player.buff(self.SOUL_SWAP_BUFF) then
                return
            end
            if __TS__ArrayIncludes(self.fakeSpellsId, spell.id) then
                if self:delayFake() then
                    return
                end
            end
            local t = self:getMainTarget(true, true)
            if not t or not t.exists or not self:canDotBreakable(spell, t) then
                return
            end
            if self:isOverlapping(t, spell.id) then
                return
            end
            if t.debuffRemainsFromMe(spell.id) > self:refreshDotValue(t, spell.id) then
                return
            end
            spell:Cast(t)
        end
    )
    unstableAffliction:Callback(
        "free",
        function(spell)
            if awful.player.buff(self.SOUL_SWAP_BUFF) then
                return
            end
            if __TS__ArrayIncludes(self.fakeSpellsId, spell.id) then
                if self:delayFake() then
                    return
                end
            end
            local tars = __TS__ArrayFilter(
                self.targets,
                function(____, e)
                    local o = e.unit
                    if not o or not o.exists then
                        return false
                    end
                    if not o.isDummyOrPlayer then
                        return false
                    end
                    if o.debuffRemainsFromMe(spell.id) > self.uaRefresh then
                        return false
                    end
                    if not spell:Castable(o) then
                        return false
                    end
                    if o.bccLock then
                        return false
                    end
                    if self:isOverlapping(o, spell.id) then
                        return false
                    end
                    if not self:canDotBreakable(spell, o) then
                        return false
                    end
                    return true
                end
            )
            if #tars == 0 then
                return
            end
            local t = tars[1].unit
            if not t or not t.exists or not t.visible then
                return
            end
            spell:Cast(t)
        end
    )
    corruption:Callback(
        "priority",
        function(spell)
            if #self.lowCorruption == 0 then
                return
            end
            local t = __TS__ArrayFind(
                self.lowCorruption,
                function(____, o) return o[1].isPlayer and spell:Castable(o[1]) and self:canDotBreakable(spell, o[1]) and o[1].debuffRemainsFromMe(spell.id) <= self:refreshDotValue(o[1], spell.id) end
            )
            if t then
                spell:Cast(t[1])
            end
        end
    )
    corruption:Callback(
        "players",
        function(spell)
            local t = __TS__ArrayFind(
                self.targets,
                function(____, o) return spell:Castable(o.unit) and o.unit.debuffRemains(spell.id, awful.player) <= self:refreshDotValue(o.unit, spell.id) and o.unit.isDummyOrPlayer and self:canDotBreakable(spell, o.unit) end
            )
            if t then
                spell:Cast(t.unit)
            end
        end
    )
    corruption:Callback(
        "units",
        function(spell)
            local t = __TS__ArrayFind(
                self.targets,
                function(____, o) return spell:Castable(o.unit) and self:canDotBreakable(spell, o.unit) and o.unit.debuffRemains(spell.id, awful.player) <= self:refreshDotValue(o.unit, spell.id) end
            )
            if t then
                spell:Cast(t.unit)
            end
        end
    )
    baneOfAgony:Callback(
        "priority",
        function(spell)
            if #self.lowAgony == 0 then
                return
            end
            local t = __TS__ArrayFind(
                self.lowAgony,
                function(____, o) return o[1].isPlayer and spell:Castable(o[1]) and self:canDotBreakable(spell, o[1]) and o[1].debuffRemainsFromMe(corruption.id) <= self:refreshDotValue(o[1], spell.id) end
            )
            if t then
                spell:Cast(t[1])
            end
        end
    )
    baneOfAgony:Callback(
        "players",
        function(spell)
            local t = __TS__ArrayFind(
                self.targets,
                function(____, o) return spell:Castable(o.unit) and self:canDotBreakable(spell, o.unit) and o.unit.debuffRemains(spell.id, awful.player) <= self:refreshDotValue(o.unit, spell.id) and o.unit.isDummyOrPlayer end
            )
            if t then
                spell:Cast(t.unit)
            end
        end
    )
    baneOfAgony:Callback(
        "units",
        function(spell)
            local t = __TS__ArrayFind(
                self.targets,
                function(____, o) return spell:Castable(o.unit) and self:canDotBreakable(spell, o.unit) and o.unit.debuffRemains(spell.id, awful.player) <= self:refreshDotValue(o.unit, spell.id) end
            )
            if t then
                spell:Cast(t.unit)
            end
        end
    )
    shadowflame:Callback(
        "los",
        function(spell)
            if not self:canShadowFlame() then
                return
            end
            local t = self:getMainTarget(true, true)
            if not t or not t.exists then
                return
            end
            if t.distanceLiteral > 12 or not t.los then
                return
            end
            if t.rooted or t.ccRemains > 0 then
                return
            end
            if t.immuneMagic then
                return
            end
            local losPred = t.predictLoS(1.5)
            if losPred then
                return
            end
            if awful.arena then
                local melees = awful.enemies.filter(function(o) return o.isPlayer and o.isMelee and o.distanceLiteral <= 15 and o.target.isUnit(awful.player) and o.los end)
                if #melees ~= 0 then
                    return
                end
            end
            return self:castShadowFlame(t, "Unit will leave LoS")
        end
    )
    shadowflame:Callback(
        "snare",
        function(spell)
            if not self:canShadowFlame() then
                return
            end
            if awful.player.rooted then
                return
            end
            local tempFace = nil
            local melee = __TS__ArrayFind(
                awful.enemies,
                function(____, o)
                    local cond = not o.immuneSlows and not o.immuneMagic and o.ccRemains <= 0 and not o.rooted and o.isPlayer and (o.isMelee or o.class2 == WowClass.HUNTER) and o.distanceLiteral <= 7 and o.target.isUnit(awful.player) and o.los
                    if not cond and not awful.arena and o.isdummy and awful.DevMode and awful.target.isUnit(o) and o.distanceLiteral <= 11 then
                        cond = true
                    end
                    if not cond then
                        return false
                    end
                    if not awful.player.facing(o, 150) then
                        if not tempFace then
                            tempFace = o
                        end
                        return false
                    else
                        return true
                    end
                end
            )
            if melee then
                return self:castShadowFlame(melee, "Melee on me")
            elseif tempFace then
                self:updateUnitToSF(tempFace)
            end
        end
    )
    shadowflame:Callback(
        "snakes",
        function(spell)
            if not self:canShadowFlame() then
                return
            end
            if not awful.arena then
                return
            end
            local u = awful.enemies.filter(function(o) return o.enemy and (o.id == CREATURE_ID.VENOMOUS_SNAKE or o.id == CREATURE_ID.VIPER) and (o.distanceLiteral <= 2 or awful.player.facing(o, 160)) and o.los and o.distanceLiteral <= 12 end)
            if #u <= 2 then
                return
            end
            spell:Cast()
        end
    )
    shadowBite:Callback(
        "base",
        function(spell, t)
            if not t.isPlayer then
                return
            end
            if t.hp <= 30 then
                return spell:Cast(t)
            end
            if not t.debuff(baneOfAgony.id, awful.player) or not t.debuff(corruption.id, awful.player) then
                return
            end
        end
    )
    drainSoul:Callback(
        "base",
        function(spell)
            local t = self:getMainTarget()
            if not t or not t.exists then
                return
            end
            if not t.debuff(corruption.id, awful.player) or not t.debuff(baneOfAgony.id, awful.player) then
                return
            end
            if t.hp <= 26 then
                return spell:Cast(t)
            end
        end
    )
    felFlame:Callback(
        "no-choice",
        function(spell, timeOut)
            if timeOut == nil then
                timeOut = 6
            end
            local ftcF = self:freeToCastFor()
            __TS__ArrayForEach(
                self.targets,
                function(____, o)
                    local u = o.unit
                    local tth = u.distanceLiteral / 40
                    if self:timeSinceLastFF(u) > tth + awful.gcd + o.isPlayer and u.debuffRemainsFromMe(unstableAffliction.id) > tth and u.debuffRemainsFromMe(unstableAffliction.id) <= timeOut then
                        local condSend = ftcF < unstableAffliction.castTime or u.predictLoS(unstableAffliction.castTime) or timeOut <= 2
                        if condSend then
                            local value = self:getSnapshotValue(u, unstableAffliction.id)
                            local myValue = self:consolidatedStats()
                            if value <= myValue then
                                spell:Cast(u)
                            end
                        end
                    end
                end
            )
        end
    )
    felFlame:Callback(
        "mt-only-rls",
        function(spell)
            local t = self:getMainTarget(true, true)
            if not t or not t.exists then
                return
            end
            if t.bccLock then
                return
            end
            if not arena:RLSPressure() then
                return
            end
            if t.debuffRemainsFromMe(unstableAffliction.id) <= 0 then
                return
            end
            if t.debuffRemainsFromMe(corruption.id) <= 0 then
                return
            end
            if t.debuffRemainsFromMe(baneOfAgony.id) <= 0 then
                return
            end
            if t.debuffRemainsFromMe(haunt.id) <= haunt.castTime then
                local ftc = self:freeToCastFor()
                if ftc > haunt.castTime + awful.buffer then
                    haunt:Cast(t)
                end
            end
            local ____ = spell:Cast(t) and Alert.sendAlert(false, spell.id, "Pressure RLS target")
        end
    )
    felFlame:Callback(
        "stomp",
        function(spell)
            local u = self.playerStompUnit
            if not u or not u.exists or u.friend or not spell:Castable(u) then
                return
            end
            if not u.los or not spell:Castable(u) then
                return
            end
            spell:Cast(u)
        end
    )
    haunt:Callback(
        "base",
        function(spell)
            if __TS__ArrayIncludes(self.fakeSpellsId, spell.id) then
                if self:delayFake() then
                    return
                end
            end
            if self:alreadyHaunt() then
                return
            end
            local t = self:getHauntTarget()
            if not t or not t.exists or t.bccLock then
                return
            end
            if t.debuffRemains(baneOfAgony.id, awful.player) < 6 or t.debuffRemains(corruption.id, awful.player) < 6 or t.debuffRemains(unstableAffliction.id, awful.player) < 6 then
                return
            end
            spell:Cast(t)
        end
    )
    summonFelhunter:Callback(
        "rez",
        function(spell)
            if not awful.player.combat then
                return
            end
            local p = awful.pet
            if p.exists and not p.dead then
                return
            end
            if awful.player.buff(soulBurn.id) or awful.player.buff(self.DEMONIC_REBIRTH) then
                spell:Cast()
            else
                if awful.player.soulShards > 0 and not awful.player.buff(self.DEMONIC_REBIRTH) then
                    soulBurn:Cast()
                end
            end
        end
    )
    summonFelhunter:Callback(
        "outsideCombat",
        function(spell)
            if awful.player.castID == spell.id then
                return
            end
            if self:isOverlapping(awful.player, spell.id, true) then
                return
            end
            local p = awful.pet
            if p.exists and not p.dead then
                return
            end
            if awful.arena and not arena:inPrep() then
                return
            end
            spell:Cast()
        end
    )
    howlOfTerror:Callback(
        "queue",
        function(spell)
            local q = Queue.queues[Queue.WARLOCK_SCREAM]
            if not q then
                return
            end
            local t = awful.GetObjectWithGUID(q.unit)
            if not t or not t.exists then
                return
            end
            local tremor = __TS__ArrayFind(
                awful.totems,
                function(____, o) return o.id == IStomps.TREMOR.objectId and o.distance < 32 end
            )
            if tremor then
                Alert.sendAlert(
                    false,
                    howlOfTerror.id,
                    "Tremor Totem",
                    "( Howl Cancelled )",
                    nil,
                    3,
                    Color.WARLOCK,
                    Color.SHAMAN
                )
                return
            end
            local anyone = t.isUnit(awful.player)
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
                if not t.isDummyOrPlayer and t.id ~= 417 then
                    return false
                end
                if t.friend or t.dead or not t.exists then
                    return false
                end
                return true
            end
            if anyone then
                local u = __TS__ArrayFind(
                    awful.enemies,
                    function(____, o) return condFear(o) end
                )
                if u then
                    local ccRemains = u.ccRemains
                    if ccRemains <= 0.3 + awful.buffer then
                        spell:Cast()
                    end
                    if ccRemains <= awful.gcd + awful.buffer and ccRemains > 0 then
                        return "wait"
                    end
                end
                local felHunter = nil
                awful.felHunters.loop(function(o)
                    if condFear(o) then
                        felHunter = o
                    end
                end)
                if felHunter ~= nil then
                    local ccRemains = felHunter.ccRemains
                    if ccRemains <= 0.3 + awful.buffer then
                        spell:Cast()
                    end
                    if ccRemains <= awful.gcd + awful.buffer and ccRemains > 0 then
                        return "wait"
                    end
                end
            elseif condFear(t) then
                local condDR = t.fearDR == 1 or t.fearDR == 0.5 and t.fearDrRemains > 6 or t.fearDrRemains > 0 and t.fearDrRemains < fear.castTime
                if not condDR then
                    return
                end
                local ccRemains = t.ccRemains
                if ccRemains <= 0.3 + awful.buffer then
                    spell:Cast()
                end
                if ccRemains <= awful.gcd + awful.buffer and ccRemains > 0 then
                    return "wait"
                end
            end
        end
    )
    soulSwap:Callback(
        "suck",
        function(spell)
            if awful.player.buff(self.SOUL_SWAP_BUFF) then
                return
            end
            if not self:canLaunchSoulSwap() then
                return
            end
            local rlsTarget = self:soulSwapRLS()
            local t = self:perfectSuckUnit(rlsTarget)
            if not t or not t.exists then
                return
            end
            ravnInfo("SoulSwap Identified:", t.color, t.name)
            if not self.ISoulSwap then
                self.ISoulSwap = {from = t, dots = {}, time = awful.time}
            end
            local vomit = rlsTarget or self:perfectBarfUnit(t)
            if not vomit then
                return
            else
                self.ISoulSwap.to = vomit
            end
            spell:Cast(t)
        end
    )
    soulSwap:Callback(
        "vomit",
        function(spell)
            local buffRemains = awful.player.buffRemains(self.SOUL_SWAP_BUFF)
            if buffRemains <= 0 then
                return
            end
            local function vomitIsValid()
                if not self.ISoulSwap then
                    return false
                end
                if not self.ISoulSwap.to then
                    return false
                end
                local t = self.ISoulSwap.to
                if not t or not t.exists or not t.visible or t.bccLock or t.immuneMagicDamage or t.immuneMagicEffects then
                    return false
                end
                if not spell:Castable(t, {ignoreFacing = true}) then
                    return false
                end
                local stats = self:consolidatedStats()
                if demonSoul.cd <= awful.gcd and ravn.config.affliBurst then
                    stats = stats * 1.2
                end
                local value = self:getSnapshotValue(t, unstableAffliction.id)
                if value > stats then
                    return false
                end
                return true
            end
            local vomitPreIdentified = vomitIsValid()
            if not vomitPreIdentified then
                if self.ISoulSwap then
                    local t = self:perfectBarfUnit(self.ISoulSwap.from)
                    if not t then
                        return
                    end
                    self.ISoulSwap.to = t
                    return self:vomit(t)
                end
            end
            if self.ISoulSwap and self.ISoulSwap.to and vomitIsValid() then
                return self:vomit(self.ISoulSwap.to)
            end
        end
    )
end
function affLib.vomit(self, t)
    if not awful.player.buff(self.DEMONSOUL_BUFF) and awful.player.buffRemains(self.SOUL_SWAP_BUFF) >= haunt.castTime + awful.gcd + awful.buffer then
        if not self:alreadyHaunt() and haunt.cd <= awful.player.gcdRemains + awful.buffer then
            local ftc = self:freeToCastFor()
            if ftc >= haunt.castTime then
                haunt:Cast(t)
                if awful.player.movingSince <= 1 then
                    if awful.player.buffUptime(self.DEMONSOUL_BUFF) <= 2 then
                        if awful.player.moving then
                            Alert.sendAlert(
                                true,
                                haunt.id,
                                "DO NOT MOVE",
                                "( CAN HAUNT SAFELY )",
                                SOUND.POSITIVE,
                                2,
                                Color.WARLOCK,
                                Color.WHITE
                            )
                        end
                        return "wait"
                    end
                end
            end
        end
    end
    local dsCD = demonSoul.cd
    if self:HasSynapseSpring() and not awful.player.buff(self.SYNAPSE_SPRINGS_BUFF) then
        if self:synapseSpringCD() <= 0 then
            if demonSoul.cd <= awful.gcd or awful.player.buff(self.DEMONSOUL_BUFF) then
                self:useSynapseSprings()
            end
            return
        end
    end
    if dsCD <= awful.gcd and ravn.config.affliBurst then
        if not awful.player.buff(self.DEMONSOUL_BUFF) then
            if awful.player.gcdRemains <= 0.3 then
                demonSoul:Cast()
            end
            return "wait"
        end
        return
    end
    soulSwap:Cast(t)
    if awful.player.buff(self.DEMONSOUL_BUFF) and awful.player.buffUptime(self.DEMONSOUL_BUFF) <= 2 then
        return "wait"
    end
end
function affLib.castShadowFlame(self, t, reason)
    if shadowflame.cd > awful.gcd then
        return
    end
    self:updateUnitToSF(t)
    local ____table_IShadowFlameInfo_startFace_14 = self.IShadowFlameInfo
    if ____table_IShadowFlameInfo_startFace_14 ~= nil then
        ____table_IShadowFlameInfo_startFace_14 = ____table_IShadowFlameInfo_startFace_14.startFace
    end
    local timer = ____table_IShadowFlameInfo_startFace_14 or 0
    local facingSince = awful.time - timer
    if facingSince > 0.2 or t.distanceLiteral <= 3 then
        if shadowflame:Cast() and reason then
            Alert.sendAlert(
                true,
                shadowflame.id,
                "Shadowflame",
                reason,
                SOUND.POSITIVE,
                2,
                Color.WARLOCK,
                Color.WHITE
            )
        end
    else
        return "wait"
    end
end
function affLib.canJinxPet(self)
    return Memory.caching(
        self.libCache,
        "canJinxPet",
        function()
            if not awful.arena then
                return false
            end
            local enemies = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return o.class2 == WowClass.HUNTER or o.class2 == WowClass.WARLOCK end
            )
            if enemies then
                return true
            end
            return
        end
    )
end
function affLib.missingJinxUnit(self, t)
    if not t then
        t = self.curseOfElementsUnit
    end
    if not t then
        return
    end
    local guid = t.guid or "UNK"
    local cacheName = "missingJinxUnit" .. guid
    return Memory.caching(
        self.libCache,
        cacheName,
        function()
            local missing = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return not o.isUnit(t) and o.isPlayer and o.distanceLiteral <= 40 and not o.debuff(self.JINX_DEBUFF) end
            )
            return missing
        end
    )
end
function affLib.determineCurse(self, t)
    if arena:RLSPressure() then
        return
    end
    if not t.isDummyOrPlayer then
        return
    end
    if not t.combat then
        return
    end
    if t.debuff(SpellBook.BLIND) then
        return
    end
    if self.recentlyCursed[t.guid] ~= nil then
        return
    end
    local CoE = self.curseOfElementsUnit
    if not self:canJinxPet() and CoE and CoE.isUnit(t) then
        local missing = self:missingJinxUnit()
        if missing then
            return curseOfTheElements
        end
    end
    local isTheCoE = CoE and CoE.isUnit(t)
    local shouldNotBeTheCOE = CoE and not isTheCoE or self:canJinxPet()
    if t.isCaster == true then
        return curseOfTongues
    end
    if t.isHealer then
        if shouldNotBeTheCOE then
            return curseOfTongues
        end
        local lowest = awful.enemies.lowest
        local CondLowHp = lowest and lowest.hp <= 60
        if CondLowHp then
            if t.castIdEx ~= 0 or lowest and lowest.hp <= 30 then
                return curseOfTongues
            else
                return curseOfTongues
            end
        else
            return curseOfTongues
        end
    end
    if t.isMelee or t.isdummy or t.class2 == WowClass.HUNTER then
        local tar = t.target
        if t.immuneSlows then
            if not CoE then
                local distanceToTarget = not tar or not tar.exists or t.distanceTo(tar) > 20
                if distanceToTarget then
                    if t.slowed then
                        return curseOfTheElements
                    end
                end
            end
            return curseOfWeakness
        end
        if not t.slowed or t.slowed == curseofExhaustion.id and t.debuffRemains(curseofExhaustion.id) < awful.gcd then
            local cond1 = t.target.isUnit(awful.player) and t.distance <= 10 and not awful.player.rooted and not awful.player.slowed
            local cond2 = t.movingToward(awful.player, {angle = 150, duration = 0.35}) and t.distance <= curseofExhaustion.range
            local cond3 = t.speed >= 12
            if t.distanceLiteral <= 12 and t.los and self:canShadowFlame() and shadowflame.cd <= awful.gcd + awful.buffer then
                return curseOfWeakness
            end
            if cond1 or cond2 or cond3 then
                return curseofExhaustion
            end
        end
        if not shouldNotBeTheCOE then
            return curseOfTheElements
        end
        if not t.slowed and not t.debuff(3409) then
            return curseOfWeakness
        end
    end
end
function affLib.autoSynapseSpring(self)
    if IsMounted() then
        return
    end
    if not self:HasSynapseSpring() then
        return
    end
    if self:synapseSpringCD() > awful.gcd then
        return
    end
    if not awful.player.combat then
        return
    end
    local cdDS = demonSoul.cd
    if cdDS > 55 and cdDS <= 65 then
        self:useSynapseSprings()
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
    end
    if awful.player.buffRemains(self.DEMONSOUL_BUFF) >= 7 then
        self:useSynapseSprings()
        Alert.sendAlert(
            false,
            self.SYNAPSE_SPRINGS_BUFF,
            "Synapse Springs",
            "On DS",
            SOUND.POSITIVE,
            2,
            Color.WARLOCK,
            Color.WHITE
        )
    end
end
function affLib.burstCdsReadyIn(self)
    local returnWaitValue = 0
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return 1000
    end
    if p.id ~= 417 then
        return 1000
    end
    local cdDS = demonSoul.cd
    if cdDS > 0 and cdDS <= 25 then
        returnWaitValue = cdDS
    end
    if self:HasSynapseSpring() then
        local synapseCD = self:synapseSpringCD()
        if synapseCD > 0 and synapseCD <= 25 then
            returnWaitValue = math.max(returnWaitValue, synapseCD)
        end
    end
    return returnWaitValue
end
function affLib.canLaunchSoulSwap(self)
    if awful.player.buff(self.SOUL_SWAP_BUFF) then
        return true
    end
    return Memory.caching(
        self.libCache,
        "canLaunchSoulSwap",
        function()
            if not ravn.modernConfig.affliBurst then
                return true
            end
            local dsCD = demonSoul.cd
            local bri = self:burstCdsReadyIn()
            if bri <= awful.gcd and dsCD <= awful.gcd then
                local procRemains = InternalCooldowns:currentProcsRemains()
                if procRemains >= awful.gcd * 2 + awful.buffer then
                    return true
                end
                local lastCast = self:soulSwapLostTime()
                if lastCast > 0 and lastCast <= 5 then
                    local nextProc = InternalCooldowns:nextProcReadyIn()
                    if nextProc and nextProc <= 5 and not self:isPlayingRLS() then
                        return false
                    else
                        return true
                    end
                end
                return false
            end
            if bri <= awful.gcd then
                return true
            end
            return false
        end
    )
end
function affLib.identifySoulSwapVomit(self)
    return Memory.caching(
        self.libCache,
        "soulSwapVomit",
        function()
            if not awful.player.buff(soulSwap.id) then
                return
            end
            if not self.ISoulSwap then
                return
            end
            local sucked = self.ISoulSwap.from
        end
    )
end
function affLib.perfectSuckUnit(self, excludeUnit)
    local highestScore = 0
    local sucky = nil
    __TS__ArrayForEach(
        self.targets,
        function(____, o)
            if not excludeUnit or not o.unit.isUnit(excludeUnit) then
                if soulSwap:Castable(o.unit, {ignoreFacing = true}) then
                    local u = o.unit
                    local curScore = self:getDotsValue(u, true)
                    if curScore and curScore > highestScore then
                        highestScore = curScore
                        sucky = u
                    end
                end
            end
        end
    )
    return sucky
end
function affLib.getDotsValue(self, u, threeRequired)
    if threeRequired == nil then
        threeRequired = false
    end
    if not u.guid then
        return nil
    end
    local cacheName = ("dotsValue" .. u.guid) .. tostring(threeRequired)
    return Memory.caching(
        self.libCache,
        cacheName,
        function()
            local value = 0
            if u.debuffRemainsFromMe(corruption.id) > 0 then
                value = self:getSnapshotValue(u, corruption.id)
            else
                if threeRequired then
                    return nil
                end
            end
            if u.debuffRemainsFromMe(baneOfAgony.id) > 0 then
                value = value + self:getSnapshotValue(u, baneOfAgony.id)
            else
                if threeRequired then
                    return nil
                end
            end
            if u.debuffRemainsFromMe(unstableAffliction.id) > 0 then
                value = value + self:getSnapshotValue(u, unstableAffliction.id)
            else
                if threeRequired then
                    return nil
                end
            end
            return value
        end
    )
end
function affLib.getDotCount(self, u, minTime)
    if minTime == nil then
        minTime = 0
    end
    local count = 0
    if u.debuffRemainsFromMe(corruption.id) > minTime then
        count = count + 1
    end
    if u.debuffRemainsFromMe(baneOfAgony.id) > minTime then
        count = count + 1
    end
    if u.debuffRemainsFromMe(unstableAffliction.id) > minTime then
        count = count + 1
    end
    return count
end
function affLib.perfectBarfUnit(self, sucky)
    local function additionalFilter(o)
        if ravn.config.affliNextSwap == "HEALER" then
            if sucky.isHealer then
                return true
            else
                return o.isHealer
            end
        end
        if not awful.arena then
            return true
        end
        if GetNumGroupMembers() == 2 and sucky.isPlayer then
            return o.isPlayer
        end
        return o.isPlayer
    end
    local eligibles = __TS__ArrayMap(
        __TS__ArrayFilter(
            self.targets,
            function(____, o) return o.unit.isDummyOrPlayer and additionalFilter(o.unit) and not o.unit.isUnit(sucky) and soulSwap:Castable(o.unit, {ignoreFacing = true, ignoreGCD = true}) end
        ),
        function(____, o) return o.unit end
    )
    if not awful.arena then
        local missing = 0
        local missingUnit = nil
        __TS__ArrayForEach(
            eligibles,
            function(____, o)
                local missingDots = 3 - self:getDotCount(o, 2)
                if missingDots > missing then
                    missing = missingDots
                    missingUnit = o
                end
                if missingDots >= 3 then
                    missingUnit = o
                    return
                end
            end
        )
        if missingUnit then
            return missingUnit
        end
    else
        if GetNumGroupMembers() == 2 then
            if sucky.isPlayer then
                return __TS__ArrayFind(
                    eligibles,
                    function(____, o) return not o.isUnit(sucky) and o.isPlayer end
                )
            else
                local lowestScore = math.huge
                local lowestUnit = nil
                local currentState = self:consolidatedStats()
                local threeState = currentState * 3
                for ____, o in ipairs(eligibles) do
                    local score = self:getDotsValue(o, false)
                    if o.isPlayer and score and score < lowestScore and score < threeState then
                        lowestScore = score
                        lowestUnit = o
                    end
                end
                if not lowestUnit then
                    return
                end
                return lowestUnit
            end
        end
        if GetNumGroupMembers() == 3 then
            local t = self:getMainTarget(true, true)
            if not t or not t.exists then
                return
            end
            if t and not t.isHealer then
                local barf = awful.enemyHealer
                if barf.exists and not barf.isUnit(sucky) and soulSwap:Castable(barf, {ignoreFacing = true}) then
                    return barf
                end
            end
            local missing = 0
            local missingUnit = nil
            local lowestScore = math.huge
            local lowestScoreUnit = nil
            __TS__ArrayForEach(
                eligibles,
                function(____, o)
                    local missingDots = 3 - self:getDotCount(o, 2)
                    if missingDots > missing then
                        missing = missingDots
                        missingUnit = o
                    end
                    if missingDots >= 3 then
                        missingUnit = o
                        return
                    end
                    local score = self:getDotsValue(o, false)
                    if score and score < lowestScore then
                        lowestScore = score
                        lowestScoreUnit = o
                    end
                end
            )
            if missingUnit then
                return missingUnit
            end
            if lowestScoreUnit then
                return lowestScoreUnit
            end
        end
    end
end
function affLib.onSoulSwap(self, dest)
    if awful.player.buff(soulSwap.id) then
        self.ISoulSwap = nil
    end
    if not dest or not dest.exists then
        return
    end
    local listSuckedSpells = {}
    if dest.debuffRemainsFromMe(corruption.id) > 0 then
        listSuckedSpells[#listSuckedSpells + 1] = corruption.id
    end
    if dest.debuffRemainsFromMe(baneOfAgony.id) > 0 then
        listSuckedSpells[#listSuckedSpells + 1] = baneOfAgony.id
    end
    if dest.debuffRemainsFromMe(unstableAffliction.id) > 0 then
        listSuckedSpells[#listSuckedSpells + 1] = unstableAffliction.id
    end
    self.ISoulSwap = {from = dest, dots = listSuckedSpells, time = awful.time}
end
function affLib.curseLogic(self, meleeOnly, lowPrioElement)
    if meleeOnly == nil then
        meleeOnly = false
    end
    if lowPrioElement == nil then
        lowPrioElement = true
    end
    local condSend = select(
        2,
        IsInInstance()
    ) == "arena" or select(
        2,
        IsInInstance()
    ) == "pvp" or awful.target.isdummy or awful.DevMode
    if not condSend then
        return
    end
    local function canCurseDespiteDispel(id)
        if self.curseCount.count <= self.curseCount.maxCount then
            return true
        end
        if id == curseOfTheElements.id then
            return true
        end
        return false
    end
    local base = self:getSmartEnemyList(true)
    if meleeOnly then
        base = base.filter(function(o) return o.isMelee end)
    end
    __TS__ArrayForEach(
        base,
        function(____, t)
            local curse = self:determineCurse(t)
            local shouldIgnore = curse and curse.id == curseOfTheElements.id and self:canJinxPet() and awful.arena and lowPrioElement and self.curseOfElementsUnit ~= nil
            if not shouldIgnore and curse and (not t.debuff(curse.id) or t.debuffRemainsFromMe(curse.id) < awful.gcd) then
                local conditionDispelSpam = canCurseDespiteDispel(curse.id)
                if conditionDispelSpam then
                    curse:Cast(t)
                end
            end
        end
    )
end
function affLib.damageLoop(self)
    if awful.arena then
        self:curseLogic(true)
    end
    local ftc = self:freeToCastFor()
    local clSS = self:canLaunchSoulSwap()
    felFlame("no-choice", 2)
    soulSwap("suck")
    haunt("base")
    unstableAffliction("HIGHEST_PRIO")
    if ftc > unstableAffliction.castTime then
        if clSS then
            unstableAffliction("mt-only")
            corruption("mt-only")
            baneOfAgony("mt-only")
            felFlame("mt-only-rls")
        end
    end
    self:curseLogic(false)
    curseOfTongues("gargoyle")
    curseOfTheElements("pets")
    healthFunnel("base", 30)
    corruption("priority")
    baneOfAgony("priority")
    corruption("players")
    baneOfAgony("players")
    if ravn.modernConfig:getAffliUAIgnoreKick() then
        unstableAffliction("base", true, true)
    end
    felFlame("no-choice")
    shadowBolt("nightfall")
    lifeTap("base")
    haunt("base")
    unstableAffliction("base", true)
    self:curseLogic(false, false)
    corruption("units")
    baneOfAgony("units")
    drainSoul("base")
    unstableAffliction("free")
    if self:freeToCastFor() > awful.gcd then
        drainLifeWeak("weak")
    end
end
function affLib.stompSetup(self)
    if not ravn.modernConfig:getStompStatus() then
        return
    end
    self.petStompUnit = nil
    self.playerStompUnit = nil
    local validIds = ravn.modernConfig.Stomps
    local validStomps = __TS__ArrayMap(
        __TS__ArrayFilter(
            validIds,
            function(____, o) return o.stompBehavior ~= "OFF" end
        ),
        function(____, o) return o.id end
    )
    local function filterTotem(o)
        if IStomps.HEALING_STREAM.objectId == o.id then
            local mt = self:getMainTarget(false, true)
            if mt and mt.exists and mt.distanceTo(o) <= 39 then
                return true
            end
            if not awful.arena and not mt then
                return true
            else
                return false
            end
        end
        if IStomps.TREMOR.objectId == o.id then
            local cond = Queue.queues[Queue.WARLOCK_SCREAM] ~= nil or Queue.queues[Queue.WARLOCK_FEAR] ~= nil
            if cond then
                return true
            end
            return false
        end
        if not __TS__ArrayIncludes(validStomps, o.id) then
            return false
        end
        return true
    end
    local function shouldSendPet(o)
        local p = awful.pet
        if not p or p.dead or not p.exists then
            return false
        end
        local distance = o.distanceTo(p)
        if distance > 5 and p.rooted then
            return false
        end
        if p.cc then
            return false
        end
        local petZ = select(
            3,
            p.position()
        )
        local oZ = select(
            3,
            o.position()
        )
        local delta = math.abs(petZ - oZ)
        if delta > 2.7 then
            return false
        end
        if distance <= 10 then
            return true
        end
        if not o.los then
            return true
        end
        local entry = __TS__ArrayFind(
            IStomps.totemList,
            function(____, u) return u.objectId == o.id end
        )
        if not entry then
            return false
        end
        local fragile = entry.fragile
        if not fragile then
            return false
        end
        local important = entry.important
        if not important and distance <= 15 then
            local tar = self:getMainTarget(true, true)
            if tar and tar.hp <= 30 then
                return true
            end
        end
        return false
    end
    local minDistamce = math.huge
    local petStomp = nil
    awful.totems.stomp(function(o, delay)
        if delay > ravn.modernConfig:getStompDelay() and filterTotem(o) then
            local sendPet = shouldSendPet(o)
            if sendPet then
                local distance = o.distanceTo(awful.pet)
                if distance < minDistamce then
                    minDistamce = distance
                    petStomp = o
                end
            else
                local castable = felFlame:Castable(o)
                if castable and o.los then
                    local ids = {IStomps.GROUND.objectId, IStomps.SLT.objectId, IStomps.HEALING_STREAM.objectId}
                    if __TS__ArrayIncludes(ids, o.id) then
                        self.playerStompUnit = o
                    end
                end
            end
            if delay > ravn.modernConfig:getStompDelay() + awful.gcd * 2 then
                if felFlame:Castable(o) and o.los then
                    self.playerStompUnit = o
                end
            end
        end
    end)
    if petStomp ~= nil then
        self.petStompUnit = petStomp
    end
end
affLib.DEMONSOUL_BUFF = 79460
affLib.SOUL_SWAP_BUFF = 86211
affLib.targets = {}
affLib.blackList = {}
affLib.uaOut = 0
affLib.agonyOut = 0
affLib.corruptionOut = 0
affLib.lowAgony = {}
affLib.lowCorruption = {}
affLib.lowUa = {}
affLib.ISoulSwap = nil
affLib.lastFelFlame = {}
affLib.soulSwapJustGotAvailable = 0
affLib.recentlyCursed = {}
affLib.petStompUnit = nil
affLib.playerStompUnit = nil
affLib.pseudoBlanketUnitTimer = 0
affLib.pseudoBlanketUnit = nil
affLib.demonicRebirthTimer = 0
affLib.stickUnit = nil
affLib.curseCount = {timer = 0, count = 0, maxTimer = 10, maxCount = 6}
affLib.FEL_HUNTER_ID = 417
affLib.IMP_ID = 416
affLib.SUCCUBUS_ID = 1863
affLib.rogueRedirectedUnit = nil
affLib.initiatedTradeList = {}
affLib.tickerTrade = 0
affLib.JINX_DEBUFF = 85547
affLib.SHADOW_TRANCE = 17941
affLib.uaRefresh = 2
affLib.IShadowFlameInfo = nil
affLib.dispelledAgony = {}
affLib.agonyRefresh = 2
affLib.corruptionRefresh = 2
affLib.petStatus = ____exports.PET_ACTION.NORMAL
affLib.debugValue = {}
affLib.lastSingeCall = 0
affLib.startFacingUnit = 0
awful.Populate(
    {
        ["rotation.lock.affli.affLib"] = ____exports,
    },
    ravn,
    getfenv(1)
)
