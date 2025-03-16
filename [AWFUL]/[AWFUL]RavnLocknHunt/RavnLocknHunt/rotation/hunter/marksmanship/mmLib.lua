local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____arena = ravn["arena.arena"]
local arena = ____arena.arena
local ____hunterLib = ravn["rotation.hunter.hunterLib"]
local HunterLib = ____hunterLib.HunterLib
local ____hunterspells = ravn["rotation.hunter.hunterspells"]
local aimedShot = ____hunterspells.aimedShot
local callOfTheWild = ____hunterspells.callOfTheWild
local chimeraShot = ____hunterspells.chimeraShot
local concussiveShot = ____hunterspells.concussiveShot
local dismissPet = ____hunterspells.dismissPet
local roarOfCourage = ____hunterspells.roarOfCourage
local steadyShot = ____hunterspells.steadyShot
local widowVenom = ____hunterspells.widowVenom
local wingClip = ____hunterspells.wingClip
____exports.mmLib = __TS__Class()
local mmLib = ____exports.mmLib
mmLib.name = "mmLib"
__TS__ClassExtends(mmLib, HunterLib)
function mmLib.slowUnit(self, t)
    local spell = t.distanceLiteral < 5 and concussiveShot or wingClip
    if not spell:Castable(t) then
        return
    end
    spell:Cast(t)
end
function mmLib.shouldMortalStrike(self, t)
    if t.isdummy then
        return true
    end
    if not t.isPlayer then
        return false
    end
    if awful.arena then
        return false
    end
    if arena:healerExists() then
        return true
    end
    local hybrid = __TS__ArrayFind(
        awful.enemies,
        function(____, o) return o.isHybrid end
    )
    return hybrid ~= nil
end
function mmLib.spellCastableIn(self, spell, malusFocus)
    local cd = spell.cd
    local cost = spell.cost.focus
    local timeToReachFocusNeeded = self:timeToReachFocus(cost, malusFocus)
    return math.max(cd, timeToReachFocusNeeded)
end
function mmLib.instantAimshotReadyIn(self)
    local stack = awful.player.buffStacks(self.READY_SET_AIM)
    return 5 - stack
end
function mmLib.shouldDelayAimedshot(self, t)
    local cacheName = "shouldDelayAimedshot" .. t.guid
    return Memory.caching(
        self.libCache,
        cacheName,
        function()
            return false
        end
    )
end
function mmLib.catSpellsDismissPrep(self)
    local cond = awful.DevMode or awful.arena
    if not cond then
        return
    end
    callOfTheWild("in-prep")
    roarOfCourage("in-prep")
end
function mmLib.initMMSpells(self)
    callOfTheWild:Callback(
        "in-prep",
        function(spell)
            if awful.player.castID ~= dismissPet.id then
                return
            end
            local ctl = awful.player.castTimeLeft
            if ctl > 0.5 then
                return
            end
            spell:Cast()
        end
    )
    roarOfCourage:Callback(
        "in-prep",
        function(spell)
            if awful.player.castID ~= dismissPet.id then
                return
            end
            local ctl = awful.player.castTimeLeft
            if ctl > 0.5 then
                return
            end
            spell:Cast()
        end
    )
    steadyShot:Callback(
        "normal",
        function(spell, t)
            if awful.player.moving then
                return
            end
            if awful.player.buff(self.INSTANT_AIMSHOT) then
                return
            end
            spell:Cast(t)
        end
    )
    aimedShot:Callback(
        "normal",
        function(spell, t)
            if awful.player.moving then
                return
            end
            if awful.player.buff(self.INSTANT_AIMSHOT) then
                return
            end
            spell:Cast(t)
        end
    )
    aimedShot:Callback(
        "instant-expiration",
        function(spell, t)
            if t.distanceLiteral <= 5 then
                return
            end
            local buffRemains = awful.player.buffRemains(self.INSTANT_AIMSHOT)
            if buffRemains <= 0 then
                return
            end
            if buffRemains <= awful.gcd + awful.buffer * 3 then
                spell:Cast(t)
            end
        end
    )
    aimedShot:Callback(
        "instant-lowhp",
        function(spell, t)
            if t.distanceLiteral <= 5 then
                return
            end
            local buffRemains = awful.player.buffRemains(self.INSTANT_AIMSHOT)
            if buffRemains <= 0 then
                return
            end
            local conditionLowHP = t.hp <= 37
            if conditionLowHP then
                if self:shouldDelayAimedshot(t) then
                    return
                end
                spell:Cast(t)
            end
        end
    )
    aimedShot:Callback(
        "instant-chimaera-chain",
        function(spell, t)
            if t.distanceLiteral <= 5 then
                return
            end
            local buffRemains = awful.player.buffRemains(self.INSTANT_AIMSHOT)
            if buffRemains <= 0 then
                return
            end
            if self:shouldDelayAimedshot(t) then
                return
            end
            local cdChimaeral = self:spellCastableIn(chimeraShot)
            if cdChimaeral > buffRemains and awful.time - self.lastChimaeralTime > awful.gcd * 2 then
                return
            end
            spell:Cast(t)
        end
    )
    widowVenom:Callback(
        "urgent",
        function(spell, t)
            if not self:shouldMortalStrike(t) then
                return
            end
            if t.msRemains < awful.gcd * 2 then
                spell:Cast(t)
            end
        end
    )
end
function mmLib.damageLoop(self)
end
mmLib.INSTANT_AIMSHOT = 82926
mmLib.READY_SET_AIM = 82935
mmLib.lastChimaeralTime = 0
awful.Populate(
    {
        ["rotation.hunter.marksmanship.mmLib"] = ____exports,
    },
    ravn,
    getfenv(1)
)
