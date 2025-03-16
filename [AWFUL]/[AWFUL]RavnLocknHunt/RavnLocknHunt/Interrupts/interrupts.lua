local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____spellList = ravn["Utilities.Lists.spellList"]
local SpellList = ____spellList.SpellList
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____structures = ravn["Utilities.structures"]
local IInterruptState = ____structures.IInteruptState
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
____exports.Interrupt = __TS__Class()
local Interrupt = ____exports.Interrupt
Interrupt.name = "Interrupt"
function Interrupt.prototype.____constructor(self)
end
function Interrupt.physicalInterruptOnly(self)
    if not self.unit then
        return false
    end
    if self.unit.channel and self.unit.channel7 then
        return true
    end
    if self.unit.casting and self.unit.casting6 then
        return true
    end
    return false
end
function Interrupt.magicInterruptOnly(self)
    return false
end
function Interrupt.castIdIsHeal(self, id)
    return ravn.modernConfig.Interrupts.Heals:includes(id)
end
function Interrupt.castIsHeal(self, u)
    return u.castingFrom(ravn.modernConfig.Interrupts.Heals)
end
function Interrupt.castIsCC(self, u)
    return u.castingFrom(ravn.modernConfig.Interrupts.CCs)
end
function Interrupt.castIsDamage(self, u)
    return u.castingFrom(ravn.modernConfig.Interrupts.Damage)
end
function Interrupt.castIsChannel(self, u)
    return u.castingFrom(ravn.modernConfig.Interrupts.Channel)
end
function Interrupt.castIsPvE(self, u)
    if awful.arena then
        return false
    end
    return u.castingFrom(SpellList.kickPve)
end
function Interrupt.castIsAlways(self, u)
    if u.name == "Vlphv" then
        local list = ravn.modernConfig.Interrupts.Always
        print(u.castingFrom(ravn.modernConfig.Interrupts.Always))
    end
    return u.castingFrom(ravn.modernConfig.Interrupts.Always)
end
function Interrupt.castWillBeKicked(self, id)
    if id == 0 then
        return false
    end
    local base = ravn.modernConfig.Interrupts
    local list = {}
    list = __TS__ArrayConcat(list, ravn.modernConfig.Interrupts.Heals)
    list = __TS__ArrayConcat(list, ravn.modernConfig.Interrupts.CCs)
    list = __TS__ArrayConcat(list, ravn.modernConfig.Interrupts.Damage)
    list = __TS__ArrayConcat(list, ravn.modernConfig.Interrupts.Channel)
    list = __TS__ArrayConcat(list, ravn.modernConfig.Interrupts.Always)
    return __TS__ArrayIncludes(list, id)
end
function Interrupt.castIsSpecMonitored(self, t)
    local specid = t.specId
    if specid == "?" then
        return false
    end
    return __TS__ArraySome(
        SpellList.importantSchoolsDPS,
        function(____, s) return s.specid == specid end
    )
end
function Interrupt.castIsMonitored(self, u)
    return self:castIsHeal(u) or self:castIsCC(u) or self:castIsDamage(u) or self:castIsChannel(u) or self:castIsAlways(u) or self:castIsPvE(u) or self:castIsSpecMonitored(u)
end
function Interrupt.destNotInLoS(self)
    if not self.unit then
        return true
    end
    if not self.dest or not self.dest.exists then
        return false
    end
    return not self.unit.losOf(self.dest)
end
function Interrupt.ignoreHunter(self, u)
    if u.class2 ~= WowClass.HUNTER then
        return false
    end
    if self.castID == SpellBook.REVIVE_PET then
        return false
    end
    if self.castID == SpellBook.SCARE_BEAST then
        local tar = u.castTarget
        if tar and tar.exists then
            if tar.isPlayer and not tar.beast then
                return true
            end
            if not u.losOf(tar) or tar.distanceToLiteral(u) > 40 or u.fearDR ~= 1 then
                return true
            end
            return false
        end
    end
    return true
end
function Interrupt.determinePercent(self, pct)
    return pct
end
function Interrupt.getPercent(self, u, forced)
    if forced == nil then
        forced = nil
    end
    if forced then
        return forced
    end
    local pct = math.random(90, 95)
    if u.class2 == WowClass.MAGE and awful.player.isMelee then
        pct = math.random(45, 60)
    end
    if pct < 50 then
        pct = math.random(50, 70)
    end
    pct = self:determinePercent(pct)
    if awful.player.class2 == WowClass.WARLOCK then
        if pct > 90 then
            pct = 86
        end
    end
    if awful.buffer > 0.2 and pct > 70 then
        pct = math.random(60, 70)
    end
    return pct
end
function Interrupt.getKickDelay(self)
    local frameBuffer = 2 / GetFramerate()
    local backgroundDelay = frameBuffer or 0
    local function kickTravelTime(u)
        local travelTime = 0
        if IsPlayerSpell(SpellBook.CONCUSSIVE_SHOT) then
            travelTime = 0.05 + u.distance * 0.005
        end
        if IsPlayerSpell(SpellBook.KICK) and not u.meleeRange then
            travelTime = 0.375
        end
        return travelTime
    end
    local interruptNetDelay = frameBuffer + backgroundDelay + kickTravelTime(awful.player) + 0.15
    return interruptNetDelay
end
function Interrupt.lockOnSchools(self, u)
    local current = u.currentSchool
    if not current then
        return
    end
    local entry = __TS__ArrayFind(
        SpellList.importantSchoolsDPS,
        function(____, s) return s.specid == u.specId and s.school == current end
    )
    return entry ~= nil
end
function Interrupt.kickTooEarly(self, u)
    if u.channel ~= nil and u.casting == nil then
        local value = math.max(
            ravn.modernConfig:getInterruptMinimumChannelKick(),
            0.3
        )
        value = value + math.random(1, 3) / 10
        if u.castingSince < value then
            return true
        else
            return false
        end
    end
    if not u.casting then
        return true
    end
    local pct = u.castPct
    local tl = u.castTimeLeft
    local ct = u.totalCastTime
    local delay = self:getKickDelay()
    local csince = u.castingSince
    if tl <= delay and ct < 0.7 then
        return true
    end
    if csince >= 0.35 and pct > self.pctInterrupt then
        return false
    end
    return true
end
function Interrupt.defineCastDestination(self, u)
    if u.castTarget and u.castTarget.exists then
        self.dest = u.castTarget
    end
end
function Interrupt.conditionKickHeals(self, u)
    if not self.dest or not self.dest.exists then
        return IInterruptState.NoKick
    end
    if ravn.modernConfig:getInterruptNoKickHybrids() and not u.isHealer and u.specId ~= "?" then
        return IInterruptState.NoKick
    end
    local hpThresh = ravn.modernConfig:getInterruptHpThreshold()
    if self.dest.hp > hpThresh then
        return IInterruptState.NoKick
    end
    if self.dest.hp < hpThresh * 0.5 and not self.dest.immuneMagicDamage and not self.dest.immunePhysicalDamage then
        return IInterruptState.Important
    end
    return IInterruptState.Kick
end
function Interrupt.mdLogic(self, u)
    if self.castID ~= SpellBook.MASS_DISPEL then
        return IInterruptState.NoKick
    end
    if not awful.arena then
        return IInterruptState.Kick
    end
    return IInterruptState.Kick
end
function Interrupt.conditionAlways(self, u)
    if self.castID == SpellBook.MANA_BURN then
        if self.dest and self.dest.isUnit(awful.player) then
            return IInterruptState.NoKick
        end
    end
    return IInterruptState.Kick
end
function Interrupt.ccLogic(self, c)
    if not self.castID then
        return IInterruptState.NoKick
    end
    local drType = awful.drCat(self.castID)
    if not drType then
        return IInterruptState.NoKick
    end
    if not self.dest or not self.dest.exists or not self.dest.friend or self.dest.dead then
        return IInterruptState.NoKick
    end
    if awful.arena and self.dest.class2 == WowClass.PRIEST and ravn.modernConfig:getInterruptTrustPriest() then
        if self.dest.ccRemains <= c.castTimeLeft - 0.3 and self.dest.cooldown(SpellBook.SHADOW_WORD_DEATH) <= 0 then
            if c.castingFrom(SpellList.ccSWD) then
                return IInterruptState.NoKick
            end
        end
    end
    local status = IInterruptState.NoKick
    if drType == "disorient" then
        local dr = self.dest.disorientDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "incapacitate" then
        local dr = self.dest.incapacitateDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "stun" then
        local dr = self.dest.stunDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "fear" then
        local dr = self.dest.fearDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "silence" then
        local dr = self.dest.silenceDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "cyclone" then
        local dr = self.dest.cycloneDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "mc" then
        local dr = self.dest.mcDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "root" and self.dest.isMelee then
        local dr = self.dest.rootDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    if drType == "banish" then
        local dr = self.dest.banishDR
        if dr == 1 then
            status = IInterruptState.Important
        elseif dr == 0.5 then
            status = IInterruptState.Kick
        else
            return IInterruptState.NoKick
        end
    end
    return status
end
function Interrupt.resetKickState(self)
    self.pctInterrupt = 99
    self.dest = nil
    self.unit = nil
    self.hardInterrupt = false
end
function Interrupt.auditPrint(self, ...)
    local args = {...}
    if not self.auditName then
        return
    end
    if not self.unit or self.unit.name ~= self.auditName then
        return
    end
    if not awful.DevMode then
        return
    end
    print(((((Color.REBECCA_PURPLE .. "[audit kick] ") .. Color.WHITE) .. self.auditName) .. " ") .. __TS__ArrayJoin(args, " "))
end
function Interrupt.mainInterrupt(self, u, shouldHardInterrupt, forcedPct, physical)
    if shouldHardInterrupt == nil then
        shouldHardInterrupt = false
    end
    if forcedPct == nil then
        forcedPct = nil
    end
    if physical == nil then
        physical = false
    end
    if not u.exists or not u or not u.visible or u.dead then
        return IInterruptState.NoKick
    end
    self:resetKickState()
    self.hardInterrupt = shouldHardInterrupt
    self.unit = u
    self.castID = u.castIdEx
    if not self.castID or self.castID == 0 then
        self:auditPrint("castId is 0")
        return IInterruptState.NoKick
    end
    if not physical and self:physicalInterruptOnly() then
        self:auditPrint("can only be physicalinterrupt")
        return IInterruptState.NoKick
    end
    if not self:castIsMonitored(self.unit) then
        self:auditPrint(
            "not monitored from id",
            self.castID,
            {GetSpellInfo(self.castID)}
        )
        return IInterruptState.NoKick
    end
    local ns = ravn.next
    if ns == 3 and not self:castIsCC(u) then
        return IInterruptState.NoKick
    end
    if ns == 4 and not self:castIsDamage(u) then
        return IInterruptState.NoKick
    end
    if ns == 2 and not self:castIsHeal(u) then
        return IInterruptState.NoKick
    end
    self.pctInterrupt = self:getPercent(u, forcedPct)
    if self:kickTooEarly(u) then
        self:auditPrint("too early")
        return IInterruptState.NoKick
    end
    self:defineCastDestination(u)
    local status
    if self:castIsHeal(u) then
        if self:destNotInLoS() then
            return IInterruptState.NoKick
        end
        status = self:conditionKickHeals(u)
        if status ~= IInterruptState.NoKick then
            return status
        end
    end
    if self:castIsSpecMonitored(u) and ravn.modernConfig:getInterruptImportantSchools() then
        if self:lockOnSchools(u) then
            return IInterruptState.Kick
        end
    end
    if self:castIsPvE(u) then
        return IInterruptState.Kick
    end
    if self:castIsAlways(u) then
        return self:conditionAlways(u)
    end
    if self:castIsDamage(u) then
        if self:destNotInLoS() then
            return IInterruptState.NoKick
        end
        if self.castID == SpellBook.DRAIN_SOUL then
            if self.unit.castingSince < 2 then
                return IInterruptState.NoKick
            end
            if self.dest and self.dest.hp > 25 then
                return IInterruptState.NoKick
            end
        end
        if self.castID == SpellBook.EXORCISM and self.dest then
            local creatureType = string.lower(self.dest.creatureType)
            if creatureType ~= "undead" and creatureType ~= "demon" then
                return IInterruptState.NoKick
            end
        end
        return self:conditionAlways(u)
    end
    status = self:mdLogic(u)
    if status ~= IInterruptState.NoKick then
        return status
    end
    if self:castIsCC(u) then
        if self:destNotInLoS() then
            return IInterruptState.NoKick
        end
        return self:ccLogic(u)
    end
    return IInterruptState.NoKick
end
Interrupt.pctInterrupt = 99
Interrupt.unit = nil
Interrupt.dest = nil
Interrupt.hardInterrupt = false
Interrupt.castID = nil
Interrupt.auditName = nil
awful.Populate(
    {
        ["Interrupts.interrupts"] = ____exports,
    },
    ravn,
    getfenv(1)
)
