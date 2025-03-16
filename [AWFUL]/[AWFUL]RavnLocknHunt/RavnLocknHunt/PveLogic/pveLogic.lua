local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__StringSplit = ____lualib.__TS__StringSplit
local ____exports = {}
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
____exports.UnitType = UnitType or ({})
____exports.UnitType.REAL_UNIT = 0
____exports.UnitType[____exports.UnitType.REAL_UNIT] = "REAL_UNIT"
____exports.UnitType.AOE = 1
____exports.UnitType[____exports.UnitType.AOE] = "AOE"
____exports.UnitType.IGNORE_UNIT = 2
____exports.UnitType[____exports.UnitType.IGNORE_UNIT] = "IGNORE_UNIT"
____exports.pveLogic = __TS__Class()
local pveLogic = ____exports.pveLogic
pveLogic.name = "pveLogic"
function pveLogic.prototype.____constructor(self)
end
function pveLogic.NormalizedPosDistance3D(self, from, to, distance)
    if distance == nil then
        distance = 3
    end
    local dx = to[1] - from[1]
    local dy = to[2] - from[2]
    local dz = to[3] - from[3]
    local magnitude = math.sqrt(dx * dx + dy * dy + dz * dz)
    local nx = dx / magnitude
    local ny = dy / magnitude
    local nz = dz / magnitude
    local newX = from[1] + nx * distance
    local newY = from[2] + ny * distance
    local newZ = from[3] + nz * distance
    return unpack({newX, newY, newZ})
end
function pveLogic.alakirDraw(self, drawer, o)
    local pos = {o.position()}
    local x, y, z = unpack(pos)
    self:WoWColorToRGBA(drawer, Color.HUNTER)
    local referenceUnit = awful.target.exists and awful.target.id == 46753 and awful.target or __TS__ArrayFind(
        awful.enemies,
        function(____, o) return o.id == 46753 end
    )
    if not referenceUnit then
        return
    end
    local distance = awful.target.distanceToLiteral(o)
    local floorDistance = math.floor(distance)
    local text = tostring(floorDistance)
    local Effects = o.effects
    local found = false
    __TS__ArrayForEach(
        Effects,
        function(____, element)
            local spellId = element.spellId
            if spellId and spellId == 87621 then
                found = true
            end
        end
    )
    local circleSize = 2.3
    if not found then
        local positionNormalized = {self:NormalizedPosDistance3D(
            {referenceUnit.position()},
            {awful.player.position()},
            distance
        )}
        local a, b, c = unpack(positionNormalized)
        self:WoWColorToRGBA(drawer, Color.LIME, 0.3)
        drawer:FilledCircle(a, b, c, circleSize)
    else
        local positionNormalized = {self:NormalizedPosDistance3D(
            {referenceUnit.position()},
            {awful.player.position()},
            distance
        )}
        local a, b, c = unpack(positionNormalized)
        self:WoWColorToRGBA(drawer, Color.RED, 0.3)
        drawer:FilledCircle(a, b, c, circleSize)
    end
end
function pveLogic.WoWColorToRGBA(self, drawer, c, customAlpha, returnTable)
    if customAlpha == nil then
        customAlpha = 1
    end
    if returnTable == nil then
        returnTable = false
    end
    local function normalized(one, two)
        local sz = one .. two
        local hex = tonumber(sz, 16)
        local val = 1
        if hex then
            val = hex / 255
        end
        return val
    end
    local sz = c
    local tbl = __TS__StringSplit(sz, "")
    if #tbl ~= 10 then
        return
    end
    local a = normalized(tbl[3], tbl[4])
    local r = normalized(tbl[5], tbl[6])
    local g = normalized(tbl[7], tbl[8])
    local b = normalized(tbl[9], tbl[10])
    if customAlpha ~= 1 then
        a = customAlpha
    end
    if returnTable then
        return {r, g, b, a}
    else
        drawer:SetColorRaw(r, g, b, a)
    end
end
function pveLogic.init(self)
    self.unitCache[1976] = {
        encounterId = 0,
        id = 1976,
        valid = function(____, o) return o.distance <= 20 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 5
    }
    self.unitCache[41483] = {
        encounterId = 1024,
        id = 4183,
        valid = function(____, o) return o.distance <= 20 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 7
    }
    self.unitCache[49447] = {
        encounterId = 1027,
        id = 49447,
        valid = function(____, o) return o.distance <= 80 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 2
    }
    self.unitCache[42180] = {
        encounterId = 1027,
        id = 42180,
        valid = function(____, o) return not o.buff(79835) end,
        unitType = ____exports.UnitType.REAL_UNIT,
        positive = false
    }
    self.unitCache[42166] = {
        encounterId = 1027,
        id = 42166,
        valid = function(____, o) return not o.buff(79735) end,
        unitType = ____exports.UnitType.REAL_UNIT,
        positive = true
    }
    self.unitCache[42178] = {
        encounterId = 1027,
        id = 42178,
        valid = function(____, o) return not o.buff(79582) end,
        unitType = ____exports.UnitType.REAL_UNIT,
        positive = true
    }
    self.unitCache[42179] = {
        encounterId = 1027,
        id = 42179,
        valid = function(____, o) return not o.buff(79582) end,
        unitType = ____exports.UnitType.REAL_UNIT,
        positive = true
    }
    self.unitCache[42897] = {
        encounterId = 1027,
        id = 42897,
        valid = function(____, o) return o.distance <= 40 end,
        unitType = ____exports.UnitType.REAL_UNIT,
        positive = false,
        drawCallback = function(____, drawer, o)
            if not o.target or not o.target.isUnit(awful.player) then
                return
            end
            local x, y, z = o.position()
            local a, b, c = awful.player.position()
            drawer:SetColorRaw(255, 0, 0, 1)
            drawer:Line(
                x,
                y,
                z,
                a,
                b,
                c
            )
            drawer:FilledCircle(x, y, z, 3)
        end
    }
    self.unitCache[42733] = {
        encounterId = 1027,
        id = 42733,
        valid = function(____, o) return o.distance <= 50 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 5,
        drawCallback = function(____, drawer, o)
            local pos = {o.position()}
            local x, y, z = unpack(pos)
            self:WoWColorToRGBA(drawer, Color.BLUE)
            drawer:Circle(x, y, z, 5)
            local text = "DAMAGE BOOST"
            drawer:Text(
                text,
                "GameFontNormalSmall",
                pos[1],
                pos[2],
                pos[3] + 1
            )
        end
    }
    self.unitCache[41807] = {
        encounterId = 1022,
        id = 41807,
        valid = function(____, o) return o.distance <= 20 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 4
    }
    self.unitCache[41546] = {
        encounterId = 1022,
        id = 41546,
        valid = function(____, o) return o.distance <= 30 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 5
    }
    self.unitCache[48854] = {
        encounterId = 1034,
        id = 48854,
        valid = function(____, o) return o.distance <= 70 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 3,
        drawCallback = function(____, drawer, o)
            self:alakirDraw(drawer, o)
        end
    }
    self.unitCache[48855] = {
        encounterId = 1034,
        id = 48854,
        valid = function(____, o) return o.distance <= 70 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 3,
        drawCallback = function(____, drawer, o)
            self:alakirDraw(drawer, o)
        end
    }
    self.unitCache[49518] = {
        encounterId = 1028,
        id = 49518,
        valid = function(____, o) return o.distance <= 40 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        drawCallback = function(____, drawer, o)
            if not o.target or not o.target.isUnit(awful.player) then
                return
            end
            local x, y, z = o.position()
            local a, b, c = awful.player.position()
            self:WoWColorToRGBA(drawer, Color.MAGE)
            drawer:FilledCircle(x, y, z, 1)
        end
    }
    self.unitCache[44824] = {
        encounterId = 1028,
        id = 44824,
        valid = function(____, o) return o.distance <= 40 end,
        unitType = ____exports.UnitType.AOE,
        positive = true,
        drawCallback = function(____, drawer, o)
            if not o.target or not o.target.isUnit(awful.player) then
                return
            end
            local x, y, z = o.position()
            local a, b, c = awful.player.position()
            self:WoWColorToRGBA(drawer, Color.WARRIOR, 0.4)
            drawer:FilledCircle(x, y, z, 3)
            self:WoWColorToRGBA(drawer, Color.WARRIOR, 1)
            drawer:Circle(x, y, z, 3)
        end
    }
    self.unitCache[44747] = {
        encounterId = 1028,
        id = 44747,
        valid = function(____, o) return o.distance <= 40 end,
        unitType = ____exports.UnitType.AOE,
        positive = true,
        drawCallback = function(____, drawer, o)
            if not o.target or not o.target.isUnit(awful.player) then
                return
            end
            local x, y, z = o.position()
            local a, b, c = awful.player.position()
            drawer:SetColor(90, 90, 90, 0.3)
            drawer:FilledCircle(x, y, z, 3)
            drawer:SetColor(90, 90, 90, 1)
            drawer:Circle(x, y, z, 3)
        end
    }
    self.unitCache[44845] = {
        encounterId = 1028,
        id = 44845,
        valid = function(____, o) return o.distance <= 20 end,
        unitType = ____exports.UnitType.AOE,
        positive = false,
        radius = 4
    }
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == "SPELL_AURA_APPLIED" then
        end
    end)
end
function pveLogic.onAuraReceived(self, source, dest, spellId, auraType)
    if source.isPlayer then
    end
end
function pveLogic.getUnitsFromEncounter(self, encounterId)
    return Memory.caching(
        self.memoizedCache,
        "getUnitsFromEncounter_" .. tostring(encounterId),
        function()
            local result = {}
            for key, value in pairs(self.unitCache) do
                if value.encounterId == encounterId then
                    result[#result + 1] = value
                end
            end
            return result
        end
    )
end
function pveLogic.getEncounterId(self)
    local value = awful.encounter and awful.encounter.id or 0
    return value
end
function pveLogic.isUnitValid(self, o)
    local entry = ____exports.pveLogic.unitCache[o.id]
    if not entry then
        return false
    end
    if entry.encounterId ~= ____exports.pveLogic:getEncounterId() then
        return false
    end
    if entry:valid(o) then
        return true
    else
        return false
    end
end
pveLogic.memoizedCache = {}
pveLogic.unitCache = {}
pveLogic.auraCache = {}
pveLogic.auraToDraws = {}
awful.Populate(
    {
        ["PveLogic.pveLogic"] = ____exports,
    },
    ravn,
    getfenv(1)
)
