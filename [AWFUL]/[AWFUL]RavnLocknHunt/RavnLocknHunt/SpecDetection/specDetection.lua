local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local listSpells = {
    {spellId = 48982, specId = 250},
    {spellId = 49016, specId = 252},
    {spellId = 49028, specId = 250},
    {spellId = 51052, specId = 252},
    {spellId = 49206, specId = 252},
    {spellId = 48438, specId = 105},
    {spellId = 50334, specId = 103},
    {spellId = 48505, specId = 102},
    {spellId = 19503, specId = 254},
    {spellId = 19574, specId = 253},
    {spellId = 19577, specId = 253},
    {spellId = 19386, specId = 255},
    {spellId = 23989, specId = 254},
    {spellId = 34490, specId = 254},
    {spellId = 53209, specId = 254},
    {spellId = 3674, specId = 255},
    {spellId = 53301, specId = 255},
    {spellId = 12042, specId = 62},
    {spellId = 12043, specId = 62},
    {spellId = 11958, specId = 64},
    {spellId = 31661, specId = 63},
    {spellId = 11129, specId = 63},
    {spellId = 12472, specId = 64},
    {spellId = 11113, specId = 63},
    {spellId = 11426, specId = 64},
    {spellId = 31687, specId = 64},
    {spellId = 44572, specId = 64},
    {spellId = 31842, specId = 65},
    {spellId = 20925, specId = 66},
    {spellId = 31935, specId = 66},
    {spellId = 20066, specId = 70},
    {spellId = 20473, specId = 65},
    {spellId = 53385, specId = 66},
    {spellId = 53595, specId = 65},
    {spellId = 54428, specId = 65},
    {spellId = 13877, specId = 260},
    {spellId = 14177, specId = 259},
    {spellId = 36554, specId = 261},
    {spellId = 14251, specId = 260},
    {spellId = 14185, specId = 261},
    {spellId = 51713, specId = 261},
    {spellId = 51690, specId = 260},
    {spellId = 16188, specId = 264},
    {spellId = 16190, specId = 264},
    {spellId = 2894, specId = 262},
    {spellId = 30823, specId = 263},
    {spellId = 17364, specId = 263},
    {spellId = 421, specId = 262},
    {spellId = 61295, specId = 264},
    {spellId = 51490, specId = 262},
    {spellId = 51533, specId = 263},
    {spellId = 30283, specId = 267},
    {spellId = 17962, specId = 267},
    {spellId = 18288, specId = 265},
    {spellId = 17877, specId = 267},
    {spellId = 50796, specId = 267},
    {spellId = 48141, specId = 265},
    {spellId = 59672, specId = 266},
    {spellId = 12292, specId = 72},
    {spellId = 12294, specId = 71},
    {spellId = 23881, specId = 72},
    {spellId = 12809, specId = 73},
    {spellId = 6572, specId = 73},
    {spellId = 12975, specId = 73},
    {spellId = 85388, specId = 71},
    {spellId = 46968, specId = 73},
    {spellId = 46924, specId = 71}
}
____exports.SpecDetection = __TS__Class()
local SpecDetection = ____exports.SpecDetection
SpecDetection.name = "SpecDetection"
function SpecDetection.prototype.____constructor(self)
end
function SpecDetection.onSpecDetected(self, unit, info)
    if not unit.isPlayer then
        return
    end
    local specId = info.specId
    if not unit or not unit.visible or not unit.exists or not unit.guid then
        return
    end
    local cacheName = unit.guid .. "-specId"
    self.specCache[cacheName] = specId
    local sz = ((unit.color .. unit.name) .. " detected as ") .. tostring(specId)
    print("[SpecDetection] " .. sz)
end
function SpecDetection.init(self)
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:SetScript(
        "OnEvent",
        function(frame, event)
            if event == "PLAYER_ENTERING_WORLD" then
                wipe(self.specCache)
            end
        end
    )
    local relevantEvents = {"UNIT_AURA", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_SUCCEEDED"}
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == relevantEvents and spellId and not source.specIdEx then
            if source and source.isPlayer then
                local entry = __TS__ArrayFind(
                    listSpells,
                    function(____, o) return o.spellId == spellId end
                )
                if entry then
                    self:onSpecDetected(source, entry)
                end
            end
        end
    end)
end
SpecDetection.frame = CreateFrame("Frame")
SpecDetection.specCache = {}
awful.Populate(
    {
        ["SpecDetection.specDetection"] = ____exports,
    },
    ravn,
    getfenv(1)
)
