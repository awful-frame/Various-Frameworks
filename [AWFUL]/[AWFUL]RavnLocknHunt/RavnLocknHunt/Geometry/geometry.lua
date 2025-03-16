local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
____exports.Geometry = __TS__Class()
local Geometry = ____exports.Geometry
Geometry.name = "Geometry"
function Geometry.prototype.____constructor(self)
end
function Geometry.angleBetweenUnits(self, source, target)
    local x, y, z = source.position()
    local x2, y2, z2 = target.position()
    local dx, dy = x - x2, y - y2
    local radian = math.atan2(-dy, -dx)
    local ____temp_0
    if radian < 0 then
        radian = radian + math.pi * 2
        ____temp_0 = radian
    else
        ____temp_0 = radian
    end
    return radian
end
function Geometry.angleBetweenPos(self, source, target)
    local x, y, z = unpack(source)
    local x2, y2, z2 = unpack(target)
    local dx, dy = x - x2, y - y2
    local radian = math.atan2(-dy, -dx)
    local ____temp_1
    if radian < 0 then
        radian = radian + math.pi * 2
        ____temp_1 = radian
    else
        ____temp_1 = radian
    end
    return radian
end
function Geometry.pointInMyFront(self, distance)
    if distance == nil then
        distance = 3
    end
    local face = awful.player.rotation
    local x, y, z = awful.player.position()
    local a, b, c = x + math.cos(face) * distance, y + math.sin(face) * distance, z
    local f, g, h = awful.GroundZ(a, b, c)
    return {f, g, h}
end
function Geometry.heightToGround(self, source)
    local a, b, c = source.position()
    local gx, gy, gz = awful.GroundZ(a, b, c)
    return math.max(0, c - gz)
end
function Geometry.distanceBetweenPos(self, p1, p2, ignoreZ)
    if ignoreZ == nil then
        ignoreZ = false
    end
    if ignoreZ then
        local x1, y1, z1 = unpack(p1)
        local x2, y2, z2 = unpack(p2)
        return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    else
        local x1, y1, z1 = unpack(p1)
        local x2, y2, z2 = unpack(p2)
        return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
    end
end
function Geometry.projectedPos(self, p1, rotation, distance, customHeight)
    local x, y, z = unpack(p1)
    if customHeight then
        z = customHeight
    end
    local x2 = x + distance * math.cos(rotation)
    local y2 = y + distance * math.sin(rotation)
    return {x2, y2, z}
end
function Geometry.landingPos(self, u)
    if u == nil then
        u = awful.player
    end
    local g = 11
    local speed = awful.player.speed
    local pitch = GetPitch("player")
    local rotation = awful.player.rotation
    local height = self:heightToGround(u)
    local vx = speed * math.cos(rotation)
    local vy = speed * math.sin(rotation)
    local currentPosition = {u.position()}
    local curX, curY, curZ = unpack(currentPosition)
    local timeToLand = math.sqrt(2 * height / g)
    local landingX = curX + vx * timeToLand
    local landingY = curY + vy * timeToLand
    local aaaaa, bx, cx = awful.GroundZ(
        landingX,
        landingY,
        select(
            3,
            u.position()
        )
    )
    return {aaaaa, bx, cx}
end
function Geometry.NormalizedPosDistance3D(self, from, to, distance)
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
function Geometry.NormalizedPosDistance2D(self, from, to, distance)
    if distance == nil then
        distance = 3
    end
    local dx = to[1] - from[1]
    local dy = to[2] - from[2]
    local magnitude = math.sqrt(dx * dx + dy * dy)
    if magnitude == 0 then
        return unpack({from[1], from[2], from[3]})
    end
    local nx = dx / magnitude
    local ny = dy / magnitude
    local newX = from[1] + nx * distance
    local newY = from[2] + ny * distance
    local newZ = from[3]
    return unpack({newX, newY, newZ})
end
function Geometry.PointInsidePolygon(self, point, polygon)
    local xIntersections = 0
    local x, y, z = unpack(point)
    local n = #polygon
    do
        local i = 0
        while i < n do
            local p1_x, p1_y = unpack(polygon[i + 1])
            local p2_x, p2_y = unpack(polygon[(i + 1) % n + 1])
            if math.min(p1_y, p2_y) < y and y <= math.max(p1_y, p2_y) then
                local x_intersect = (y - p1_y) * (p2_x - p1_x) / (p2_y - p1_y) + p1_x
                if x < x_intersect then
                    xIntersections = xIntersections + 1
                end
            end
            i = i + 1
        end
    end
    return xIntersections % 2 == 1
end
function Geometry.projectPointOutsidePolygon(self, base, point, polygon)
    if not self:PointInsidePolygon(point, polygon) then
        return unpack(point)
    end
    local currentDistance = ____exports.Geometry:distanceBetweenPos(base, point)
    local newDistance = currentDistance
    local c = 1
    repeat
        do
            newDistance = newDistance + 3
            point = {self:NormalizedPosDistance2D(base, point, newDistance)}
            ravnInfo("Recalcul - point inside polygon", c)
            c = c + 1
        end
    until not (self:PointInsidePolygon(point, polygon) or c > 20)
    if c > 20 then
        ravnInfo(Color.RED, "Failed to project point outside polygon")
    end
    ravnInfo(Color.LIME, "Projected point outside polygon: SUCCESS")
    return unpack(point)
end
function Geometry.pointCircleAroundUnit(self, t, distance, steps)
    if steps == nil then
        steps = 12
    end
    local x, y, z = t.position()
    local points = {}
    do
        local i = 0
        while i < 360 do
            local x2 = x + distance * math.cos(math.rad(i))
            local y2 = y + distance * math.sin(math.rad(i))
            points[#points + 1] = {x2, y2, z}
            i = i + steps
        end
    end
    return points
end
function Geometry.walkablePointsAroundUnit(self, reference, t, distance, step)
    local x, y, z = t.position()
    local points = {}
    do
        local i = 0
        while i < 360 do
            local x2 = x + distance * math.cos(math.rad(i))
            local y2 = y + distance * math.sin(math.rad(i))
            local newPt = {x2, y2, z}
            if reference.losCoordsLiteral(x2, y2, z) and awful.player.losCoordsLiteral(x2, y2, z) then
                local path = awful.path(awful.pet, x2, y2, z)
                if path then
                    points[#points + 1] = newPt
                end
            end
            i = i + step
        end
    end
    return points
end
function Geometry.mostAroundPointsWalkable(self, reference, t, distance, step, list, maxDistance)
    local points = self:walkablePointsAroundUnit(reference, t, distance, step)
    local bestHit = 0
    local bestPosition = {0, 0, 0}
    __TS__ArrayForEach(
        points,
        function(____, pt)
            local subList = __TS__ArrayFilter(
                list,
                function(____, o) return self:distanceBetweenPos(
                    {o.position()},
                    pt
                ) < maxDistance and o.losCoordsLiteral(pt[1], pt[2], pt[3]) end
            )
            if #subList > bestHit then
                bestHit = #subList
                bestPosition = pt
            end
        end
    )
    return unpack(bestPosition)
end
function Geometry.NearEdgePoints(self, unit, distance, steps)
    if steps == nil then
        steps = 12
    end
    local x, y, z = unit.position()
    local pointsAround = self:pointCircleAroundUnit(unit, distance, steps)
    local edgePts = {}
    __TS__ArrayForEach(
        pointsAround,
        function(____, pt)
            local grounded = {awful.GroundZ(pt[1], pt[2], pt[3])}
            local delta = z - grounded[3]
            if delta >= 3 and unit.losPositionLiteral(pt) then
                edgePts[#edgePts + 1] = pt
            end
        end
    )
    return edgePts
end
awful.Populate(
    {
        ["Geometry.geometry"] = ____exports,
    },
    ravn,
    getfenv(1)
)
