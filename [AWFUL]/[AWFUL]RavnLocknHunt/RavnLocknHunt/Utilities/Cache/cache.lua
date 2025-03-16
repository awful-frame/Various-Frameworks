local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____spellList = ravn["Utilities.Lists.spellList"]
local SpellList = ____spellList.SpellList
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnPrint = ____ravnPrint.ravnPrint
local ____spell = ravn["Utilities.spell"]
local Spell = ____spell.Spell
____exports.Cache = __TS__Class()
local Cache = ____exports.Cache
Cache.name = "Cache"
function Cache.prototype.____constructor(self)
end
function Cache.cleanAllCaches(self)
    wipe(self.combatTrackerCache)
    wipe(self.trinketTrackerCache)
    wipe(self.justTrinketedCache)
    wipe(self.gapcloseCache)
    wipe(self.swdCache)
    wipe(self.interruptCache)
end
function Cache.setNextKickType(self, pct)
    if not ravn.modernConfig:getInterruptKickRandomized() then
        return
    end
    local kType = "none"
    if pct <= 45 then
        kType = "early"
    elseif pct <= 77 then
        kType = "mid"
    else
        kType = "late"
    end
    local possibilities = {"early", "mid", "late", "none"}
    local removekType = __TS__ArrayFilter(
        possibilities,
        function(____, e) return e ~= kType end
    )
    local random13 = math.random(1, 3)
    local next = removekType[random13]
    self.nextKickType = next
    print(("|cFFeb6e85[RAVN] " .. "Next Kick will be: ") .. self.nextKickType)
end
function Cache.setCombatTracker(self, u)
    self.combatTrackerCache[u.guid] = GetTime()
end
function Cache.setTrinketTracker(self, u, id)
    local expiration = GetTime() + 120
    self.trinketTrackerCache[u.guid] = expiration
    local ____self_justTrinketedCache_0 = self.justTrinketedCache
    ____self_justTrinketedCache_0[#____self_justTrinketedCache_0 + 1] = u.guid
    C_Timer.After(
        awful.gcd + 0.5,
        function()
            self.justTrinketedCache = __TS__ArrayFilter(
                self.justTrinketedCache,
                function(____, o) return o ~= u.guid end
            )
        end
    )
end
function Cache.setGapcloseTracker(self, u)
    if not u or not u.guid then
        return
    end
    self.gapcloseCache[u.guid] = GetTime()
    C_Timer.After(
        awful.gcd + 0.2,
        function()
            self.gapcloseCache[u.guid] = nil
        end
    )
end
function Cache.setSwdTracker(self, u)
    self.swdCache[u.guid] = GetTime()
    C_Timer.After(
        1.7,
        function()
            self.swdCache[u.guid] = nil
        end
    )
end
function Cache.setStealthTracker(self, source, spellId)
    local n = Spell.getName(spellId)
    Alert.sendAlert(
        false,
        spellId,
        "Tracking " .. source.class2,
        ("( " .. source.name) .. " )",
        nil,
        nil,
        source.color,
        source.color
    )
    local tracker = {
        speed = source.speed,
        direction = source.direction,
        pos = {source.position()},
        time = GetTime(),
        guidPtr = source.guid,
        spellId = spellId,
        spellName = n,
        update = false
    }
    local ____self_stealthTracker_1 = self.stealthTracker
    ____self_stealthTracker_1[#____self_stealthTracker_1 + 1] = tracker
end
function Cache.updateStealthTracker(self)
    if #self.stealthTracker == 0 then
        return
    end
    local time = GetTime()
    self.stealthTracker = __TS__ArrayFilter(
        self.stealthTracker,
        function(____, o) return time - o.time < 6 end
    )
end
function Cache.init(self)
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        local combatTrackerEvents = {"SPELL_DAMAGE", "SPELL_MISSED", "SWING_MISSED", "SWING_DAMAGE"}
        if awful.arena and source.exists and dest.exists and __TS__ArrayIncludes(combatTrackerEvents, event) then
            ____exports.Cache:setCombatTracker(source)
            ____exports.Cache:setCombatTracker(dest)
        end
        if event == "SPELL_CAST_SUCCESS" then
            if __TS__ArrayIncludes(
                __TS__ArrayMap(
                    SpellList.interrupts,
                    function(____, o) return o.id end
                ),
                spellId
            ) then
                if source and source.exists and dest and dest.exists and source.isPlayer then
                    if source.isUnit(awful.player) or source.isUnit(awful.pet) then
                        local castID = dest.castIdEx
                        local sz = (((((("Interrupted" .. " ") .. dest.name) .. " on ") .. Spell.getName(castID)) .. " at ") .. tostring(math.floor(dest.castPct))) .. "%"
                        ____exports.Cache:setNextKickType(dest.castPct)
                        ravnPrint(sz)
                    end
                    local pct = dest.castPct
                    if pct > 0 and not dest.channelID then
                        ravn.fakeTracker:addCastKickInfo(source, pct)
                    end
                    local channel = dest.channelID
                    if not channel then
                        return
                    end
                    local channelTime = dest.castingSince
                    if channel ~= 0 and channelTime > 0 then
                        ravn.fakeTracker:addChannelKickInfo(source, channelTime)
                    end
                end
            end
            local condition = (source.isUnit(awful.player) or source.isUnit(awful.pet)) and __TS__ArrayIncludes(
                __TS__ArrayMap(
                    SpellList.interrupts,
                    function(____, o) return o.id end
                ),
                spellId
            )
            if condition then
                if ravn.next ~= 1 then
                    ravn.next = 1
                    ravnPrint("Interrupt Sent: Reset Kicks", Color.LIGHT_GREEN)
                end
            end
            if source.exists and source.isPlayer then
                if spellId == SpellBook.SHADOW_WORD_DEATH then
                    ____exports.Cache:setSwdTracker(source)
                end
                if __TS__ArrayIncludes(SpellList.gapCloseIDs, spellId) then
                    ____exports.Cache:setGapcloseTracker(source)
                end
                if __TS__ArrayIncludes(SpellList.trinketIds, spellId) then
                    ____exports.Cache:setTrinketTracker(source, spellId)
                end
                if not source.friend then
                    if __TS__ArrayIncludes(SpellList.stealthIDs, spellId) then
                        ____exports.Cache:setStealthTracker(source, spellId)
                    end
                end
            end
            if source.exists and source.isUnit(awful.player) and event == "SPELL_CAST_SUCCESS" then
                Queue:purgeQueuePostCast(spellId)
            end
        end
        if event == "SPELL_INTERRUPT" then
            if dest.exists and source.exists then
                local tCast = extraSpellName
                local tSchool = CombatLog_String_SchoolString(auraType2)
            end
        end
    end)
end
Cache.combatTrackerCache = {}
Cache.trinketTrackerCache = {}
Cache.justTrinketedCache = {}
Cache.gapcloseCache = {}
Cache.swdCache = {}
Cache.interruptCache = {}
Cache.stealthTracker = {}
Cache.lastKickType = "none"
Cache.nextKickType = "none"
awful.Populate(
    {
        ["Utilities.Cache.cache"] = ____exports,
    },
    ravn,
    getfenv(1)
)
