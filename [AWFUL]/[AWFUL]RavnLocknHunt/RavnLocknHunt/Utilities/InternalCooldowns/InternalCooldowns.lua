local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__StringIncludes = ____lualib.__TS__StringIncludes
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArraySort = ____lualib.__TS__ArraySort
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____structures = ravn["Utilities.structures"]
local INTERNAL_CD = ____structures.INTERNAL_CD
____exports.InternalCooldowns = __TS__Class()
local InternalCooldowns = ____exports.InternalCooldowns
InternalCooldowns.name = "InternalCooldowns"
function InternalCooldowns.prototype.____constructor(self)
end
function InternalCooldowns.LookTextInItem(self, slotID, looking)
    local link = awful.call("GetInventoryItemLink", "player", slotID)
    if not link then
        return false
    end
    Global.scanTooltip:ClearLines()
    Global.scanTooltip:SetInventoryItem("player", slotID)
    for i = 1, Global.scanTooltip:NumLines() do
        local line = _G["RCTooltipTextLeft" .. tostring(i)]
        if line and line.GetText then
            local text = line:GetText()
            text = string.lower(text)
            looking = string.lower(looking)
            if text and __TS__StringIncludes(text, looking) then
                return true
            end
        end
    end
    return false
end
function InternalCooldowns.isEligibleEntry(self, e)
    local name = "eligible_" .. e.name
    return Memory.caching(
        ____exports.InternalCooldowns.icdCache,
        name,
        function()
            if e.condition and not e:condition() then
                return false
            end
            if e.trinketId then
                local trinket1 = GetInventoryItemID("player", 13) == e.trinketId
                local trinket2 = GetInventoryItemID("player", 14) == e.trinketId
                if not trinket1 and not trinket2 then
                    return false
                end
            end
            return true
        end
    )
end
function InternalCooldowns.procReadyIn(self, name)
    local entry = __TS__ArrayFind(
        ____exports.InternalCooldowns.internalCDs,
        function(____, e) return e.name == name end
    )
    if not entry then
        return nil
    end
    if not ____exports.InternalCooldowns:isEligibleEntry(entry) then
        return nil
    end
    if entry.condition and not entry:condition() then
        return nil
    end
    local buffRemains = awful.player.buffRemains(entry.buffId)
    if buffRemains > 0 then
        return buffRemains + entry.cd
    end
    if entry.lastCast == 0 then
        return 0
    end
    local cd = math.max(0, entry.lastCast + entry.cd - awful.time)
    return cd
end
function InternalCooldowns.procInformations(self, excludeCurrentproc)
    if excludeCurrentproc == nil then
        excludeCurrentproc = false
    end
    local cacheName = "procInformations_" .. tostring(excludeCurrentproc)
    return Memory.caching(
        ____exports.InternalCooldowns.icdCache,
        cacheName,
        function()
            local retValues = {}
            for ____, entry in ipairs(____exports.InternalCooldowns.internalCDs) do
                if ____exports.InternalCooldowns:isEligibleEntry(entry) then
                    local cd = ____exports.InternalCooldowns:procReadyIn(entry.name)
                    local removeCurrentProc = excludeCurrentproc and awful.player.buffRemains(entry.buffId) > 0
                    if not removeCurrentProc then
                        if cd ~= nil then
                            retValues[#retValues + 1] = {name = entry.name, cdReadyIn = cd}
                        end
                    end
                end
            end
            return retValues
        end
    )
end
function InternalCooldowns.eligibleProcCount(self)
    return Memory.caching(
        ____exports.InternalCooldowns.icdCache,
        "eligibleProcCount",
        function()
            return #____exports.InternalCooldowns:procInformations()
        end
    )
end
function InternalCooldowns.getProcReadyIn(self, proc)
    return Memory.caching(
        ____exports.InternalCooldowns.icdCache,
        "getProcReadyIn_" .. proc,
        function()
            local infos = __TS__ArrayFind(
                ____exports.InternalCooldowns:procInformations(),
                function(____, e) return e.name == proc end
            )
            if not infos then
                return nil
            end
            return infos.cdReadyIn
        end
    )
end
function InternalCooldowns.nextProcReadyIn(self, excludeCurrentproc)
    if excludeCurrentproc == nil then
        excludeCurrentproc = false
    end
    local infos = ____exports.InternalCooldowns:procInformations(excludeCurrentproc)
    if #infos == 0 then
        return nil
    end
    local min = __TS__ArraySort(
        __TS__ArrayMap(
            infos,
            function(____, e) return e.cdReadyIn end
        ),
        function(____, a, b) return a - b end
    )[1]
    return min
end
function InternalCooldowns.currentProcsRemains(self)
    local lowest = math.huge
    for ____, entry in ipairs(____exports.InternalCooldowns.internalCDs) do
        if ____exports.InternalCooldowns:isEligibleEntry(entry) then
            local remains = awful.player.buffRemains(entry.buffId)
            if remains > 0 then
                lowest = math.min(lowest, remains)
            end
        end
    end
    if lowest == math.huge then
        return 0
    end
    return lowest
end
function InternalCooldowns.onBuffExpired(self, id)
    for ____, internal in ipairs(____exports.InternalCooldowns.internalCDs) do
        if internal.buffId == id then
            internal.lastCast = awful.time
        end
    end
end
function InternalCooldowns.init(self)
    ____exports.InternalCooldowns:populate()
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == "SPELL_AURA_REMOVED" and auraType == "BUFF" then
            if dest.isUnit(awful.player) and spellId then
                ____exports.InternalCooldowns:onBuffExpired(spellId)
            end
        end
    end)
end
InternalCooldowns.icdCache = {}
InternalCooldowns.populate = function()
    ____exports.InternalCooldowns.internalCDs = {}
    local ____exports_InternalCooldowns_internalCDs_0 = ____exports.InternalCooldowns.internalCDs
    ____exports_InternalCooldowns_internalCDs_0[#____exports_InternalCooldowns_internalCDs_0 + 1] = {
        name = INTERNAL_CD.LIGHTWEAVE,
        buffId = 75170,
        cd = 45,
        lastCast = 0,
        condition = function()
            return ____exports.InternalCooldowns:LookTextInItem(15, "Lightweave Embroidery")
        end
    }
    local ____exports_InternalCooldowns_internalCDs_1 = ____exports.InternalCooldowns.internalCDs
    ____exports_InternalCooldowns_internalCDs_1[#____exports_InternalCooldowns_internalCDs_1 + 1] = {
        name = INTERNAL_CD.ON_USE_S9_HONOR,
        buffId = 92218,
        cd = 40,
        lastCast = 0,
        trinketId = 64762
    }
    local ____exports_InternalCooldowns_internalCDs_2 = ____exports.InternalCooldowns.internalCDs
    ____exports_InternalCooldowns_internalCDs_2[#____exports_InternalCooldowns_internalCDs_2 + 1] = {
        name = INTERNAL_CD.VOLCANO,
        buffId = 89091,
        cd = 45,
        lastCast = 0,
        trinketId = 62047
    }
    local ____exports_InternalCooldowns_internalCDs_3 = ____exports.InternalCooldowns.internalCDs
    ____exports_InternalCooldowns_internalCDs_3[#____exports_InternalCooldowns_internalCDs_3 + 1] = {
        name = INTERNAL_CD.THERALION_MIRROR_NM,
        buffId = 91024,
        cd = 70,
        lastCast = 0,
        trinketId = 59519
    }
    local ____exports_InternalCooldowns_internalCDs_4 = ____exports.InternalCooldowns.internalCDs
    ____exports_InternalCooldowns_internalCDs_4[#____exports_InternalCooldowns_internalCDs_4 + 1] = {
        name = INTERNAL_CD.POWER_TORRENT,
        buffId = 74241,
        cd = 45,
        lastCast = 0,
        condition = function()
            return ____exports.InternalCooldowns:LookTextInItem(16, "Power Torrent")
        end
    }
    local ____exports_InternalCooldowns_internalCDs_5 = ____exports.InternalCooldowns.internalCDs
    ____exports_InternalCooldowns_internalCDs_5[#____exports_InternalCooldowns_internalCDs_5 + 1] = {
        name = INTERNAL_CD.BELL_OF_ENRAGING_RESONANCE,
        buffId = 92318,
        cd = 100,
        lastCast = 0,
        trinketId = 65053
    }
end
awful.Populate(
    {
        ["Utilities.InternalCooldowns.InternalCooldowns"] = ____exports,
    },
    ravn,
    getfenv(1)
)
