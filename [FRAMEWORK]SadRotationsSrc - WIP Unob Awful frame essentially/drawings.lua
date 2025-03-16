local Unlocker, blink = ...
local math = math
local abs, sqrt, rad, sin, cos, floor, min, max, pi, pi2, atan = math.abs, math.sqrt, math.rad, math.sin, math.cos,
    math.floor, math.min, math.max, math.pi, math.pi * 2, math.atan
local type, strlen, tonumber, pairs, ipairs = type, string.len, tonumber, pairs, ipairs
local tinsert, tremove, sort = table.insert, table.remove, table.sort
local GetScreenHeight, GetScreenWidth = GetScreenHeight, GetScreenWidth
local IsMacClient = IsMacClient
local unlockerType = Unlocker.type or "tinkr"
local CameraPosition = unlockerType ~= "daemonic" and CameraPosition or GetCameraPosition
local Distance = blink.Distance

local player, target, healer = blink.player, blink.target, blink.healer
local colors = blink.colors

local delaunay = blink.delaunay or {}
local triangulate = delaunay.triangulate
local Point = delaunay.Point

local function hex2rgb(hex)
    local hex = hex:gsub("#", "")
    hex = hex:gsub("|cFF", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

local posFromPos = blink.posFromPos

local getRect = blink.getRect

-- verts
local verts = {{}, {}, {}, {}, {}}

local tri = {
    v1 = {0, 0, 0},
    v2 = {0, 0, 0},
    v3 = {0, 0, 0}
}

blink.PathsToDraw = {}

local Draw = {
    colors = {
        white = {255, 255, 255},
        red = {255, 80, 80},
        orange = {255, 141, 80},
        yellow = {255, 228, 80},
        green = {80, 255, 141},
        teal = {80, 255, 228},
        blue = {80, 141, 255},
        purple = {141, 80, 255},
        pink = {255, 80, 105},
        grey = {141, 141, 141}
    }
}

function Draw:CameraPosition()
    return CameraPosition()
end

function Draw:Map(value, fromLow, fromHigh, toLow, toHigh)
    return toLow + (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow)
end

function Draw:SetColor(r, g, b, a)
    if type(r) == "string" then
        r, g, b, a = self:HexToRGB(r)
    elseif type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], g
    end

    self.color[1] = r / 255
    self.color[2] = g / 255
    self.color[3] = b / 255
    self.color[4] = (a or 255) / 255
end

function Draw:SetColorRaw(r, g, b, a)
    if type(r) == "table" then
        self.color[1] = r[1]
        self.color[2] = r[2]
        self.color[3] = r[3]
        self.color[4] = r[4] or 1
    else
        self.color[1] = r
        self.color[2] = g
        self.color[3] = b
        self.color[4] = a
    end
end

function Draw:SetAlpha(a)
    self.color[4] = (a or 255) / 255
end

function Draw:Distance(ax, ay, az, bx, by, bz)
    return Distance(ax, ay, az, bx, by, bz)
end

function Draw:SetWidth(width)
    self.line_width = width
end

local function rotateVertex(vertex, angleX, angleY, angleZ)
    angleX = angleX or 0
    angleY = angleY or 0
    angleZ = angleZ or 0
    local sinX = math.sin(angleX)
    local cosX = math.cos(angleX)
    local sinY = math.sin(angleY)
    local cosY = math.cos(angleY)
    local sinZ = math.sin(angleZ)
    local cosZ = math.cos(angleZ)
    
    local newX = vertex.x * cosY - vertex.z * sinY
    local newZ = vertex.x * sinY + vertex.z * cosY
    local newY = vertex.y * cosX - newZ * sinX
    newZ = vertex.y * sinX + newZ * cosX
    local tempX = newX
    newX = tempX * cosZ - newY * sinZ
    newY = tempX * sinZ + newY * cosZ
    
    return {x = newX, y = newY, z = newZ}
end

local function rotateWavefrontObject(obj, angleX, angleY, angleZ)
    local rotatedVertices = {}
    for _, vertex in ipairs(obj.v) do
        tinsert(rotatedVertices, rotateVertex(vertex, angleX, angleY, angleZ))
    end
    obj.v = rotatedVertices
end

function Draw:RotateObject(obj, angleX, angleY, angleZ)
    rotateWavefrontObject(obj, angleX, angleY, angleZ)
end

function Draw:Object(obj, x, y, z, scale, replaceWhite)
    scale = scale or 1

    local faces = obj.f
    local vertices = obj.v

    local mats = obj.materials or {}

    local cx, cy, cz = self:CameraPosition()

    local triangles = {}
    
    local a = self.color[4] or 1
    local ir, ig, ib = self.color[1], self.color[2], self.color[3]

    for _, face in ipairs(faces) do
        local faceVertices = {}

        for _, vertexData in ipairs(face) do
            local vertex = vertices[vertexData.v]
            local point = Point(vertex.x * scale, vertex.y * scale)
            point.z = vertex.z * scale
            tinsert(faceVertices, point)
        end

        local tris = triangulate(faceVertices)

        for _, _tri in ipairs(tris) do
            local triangle = {
                p1 = _tri.p1,
                p2 = _tri.p2,
                p3 = _tri.p3,
                mat = face.material
            }

            local p1x, p1y, p1z = _tri.p1.x + x, _tri.p1.y + y, _tri.p1.z + z
            local p2x, p2y, p2z = _tri.p2.x + x, _tri.p2.y + y, _tri.p2.z + z
            local p3x, p3y, p3z = _tri.p3.x + x, _tri.p3.y + y, _tri.p3.z + z

            -- Calculate the average distance of the triangle to the camera
            local dx1, dy1, dz1 = cx - p1x, cy - p1y, cz - p1z
            local dx2, dy2, dz2 = cx - p2x, cy - p2y, cz - p2z
            local dx3, dy3, dz3 = cx - p3x, cy - p3y, cz - p3z
            local dist1 = math.sqrt(dx1 * dx1 + dy1 * dy1 + dz1 * dz1)
            local dist2 = math.sqrt(dx2 * dx2 + dy2 * dy2 + dz2 * dz2)
            local dist3 = math.sqrt(dx3 * dx3 + dy3 * dy3 + dz3 * dz3)
            triangle.distance = (dist1 + dist2 + dist3) / 3
        
            tinsert(triangles, triangle)
        end
    end

    -- sort triangles by their average distance to the camera
    sort(triangles, function(a, b)
        return a.distance < b.distance
    end)

    local ntriangles = #triangles
    local qtrtriangles = ntriangles / 4
    local last_mat
    for i, triangle in ipairs(triangles) do
        local drawLayer = i < qtrtriangles / 2.8 and "OVERLAY"
                        or i < qtrtriangles / 2 and "ARTWORK"
                        or i < qtrtriangles * 2 and "BORDER"
                        or "BACKGROUND"
        
        local mat = triangle.mat
        if mat then
            if last_mat ~= mat then
                last_mat = mat
                local color = mats[mat]
                if color then
                    local Kd = color.Kd
                    if Kd then
                        local r, g, b = Kd.r, Kd.g, Kd.b
                        if replaceWhite and r > 0.7 and g > 0.7 and b > 0.7 then
                            -- ignore?
                            self:SetColor(ir * 255, ig * 255, ib * 255, a * 255)
                        else
                            self:SetColor(r * 255, g * 255, b * 255, a * 255)
                        end
                    end
                end
            end
        end

        tri.v1.x = triangle.p1.x + x
        tri.v1.y = triangle.p1.y + y
        tri.v1.z = triangle.p1.z + z

        tri.v2.x = triangle.p2.x + x
        tri.v2.y = triangle.p2.y + y
        tri.v2.z = triangle.p2.z + z

        tri.v3.x = triangle.p3.x + x
        tri.v3.y = triangle.p3.y + y
        tri.v3.z = triangle.p3.z + z

        self:Triangle(0, 0, 0, tri.v1, tri.v2, tri.v3, true, false, drawLayer)
    end

    self:SetColor(ir, ig, ib)
end

function Draw:LaplacianSmoothing(obj, iterations)
    if obj.smoothed then return end
    obj.smoothed = true
    iterations = iterations or 1

    for _ = 1, iterations do
        local newVertices = {}
        for i, vertex in ipairs(obj.v) do
            local neighborVertices = {}
            for _, face in ipairs(obj.f) do
                for _, vertexData in ipairs(face) do
                    if vertexData.v == i then
                        for _, neighborVertexData in ipairs(face) do
                            if neighborVertexData.v ~= i then
                                tinsert(neighborVertices, obj.v[neighborVertexData.v])
                            end
                        end
                    end
                end
            end

            if #neighborVertices > 0 then
                local xSum, ySum, zSum = 0, 0, 0
                for _, neighbor in ipairs(neighborVertices) do
                    xSum = xSum + neighbor.x
                    ySum = ySum + neighbor.y
                    zSum = zSum + neighbor.z
                end

                newVertices[i] = {
                    x = xSum / #neighborVertices,
                    y = ySum / #neighborVertices,
                    z = zSum / #neighborVertices
                }
            else
                newVertices[i] = vertex
            end
        end
        obj.v = newVertices
    end
end

-- Geometry functions

function Draw:RotateX(cx, cy, cz, px, py, pz, r)
    if not r then
        return px, py, pz
    end
    local s = sin(r)
    local c = cos(r)
    -- center of rotation
    px, py, pz = px - cx, py - cy, pz - cz
    local x = px + cx
    local y = ((py * c - pz * s) + cy)
    local z = ((py * s + pz * c) + cz)
    return x, y, z
end

function Draw:RotateY(cx, cy, cz, px, py, pz, r)
    if not r then
        return px, py, pz
    end
    local s = sin(r)
    local c = cos(r)
    -- center of rotation
    px, py, pz = px - cx, py - cy, pz - cz
    local x = ((pz * s + px * c) + cx)
    local y = py + cy
    local z = ((pz * c - px * s) + cz)
    return x, y, z
end

function Draw:RotateZ(cx, cy, cz, px, py, pz, r)
    if not r then
        return px, py, pz
    end
    local s = sin(r)
    local c = cos(r)
    -- center of rotation
    px, py, pz = px - cx, py - cy, pz - cz
    local x = ((px * c - py * s) + cx)
    local y = ((px * s + py * c) + cy)
    local z = pz + cz
    return x, y, z
end

function Draw:Line(x1, y1, z1, x2, y2, z2, maxD, isPartial)
    if not x1 or not y1 or not z1 or not x2 or not y2 or not z2 then
        return
    end
    if not maxD then
        maxD = 50
    end

    if self:Distance(x1, y1, z1, x2, y2, z2) > maxD then
        if isPartial then
            return false
        else
            local mx, my, mz = (x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2
            self:Line(x1, y1, z1, mx, my, mz, nil, true)
            self:Line(mx, my, mz, x2, y2, z2, nil, true)
        end
    else
        local sx, sy = self:WorldToScreen(x1, y1, z1)
        local ex, ey = self:WorldToScreen(x2, y2, z2)

        if not sx or not sy or not ex or not ey then
            return
        end

        self:Line2D(sx, sy, ex, ey)
    end
end

function Draw:LineRaw(x1, y1, z1, x2, y2, z2)
    if not x1 or not y1 or not z1 or not x2 or not y2 or not z2 then
        return
    end

    local sx, sy = self:WorldToScreen(x1, y1, z1)
    local ex, ey = self:WorldToScreen(x2, y2, z2)

    if sx == false or sy == false or ex == false or ey == false then
        return
    end

    self:Line2D(sx, sy, ex, ey)
end

function Draw:Line2D(sx, sy, ex, ey)
    if not sx or not sy or not ex or not ey then
        return
    end

    sx, sy, ex, ey = floor(sx), floor(sy), floor(ex), floor(ey)

    if sx == 0 or sy == 0 or ex == 0 or ey == 0 then
        return
    end

    local line = tremove(self.lines) or false

    if line == false then
        line = self.canvas:CreateLine()
    end

    line:SetColorTexture(self.color[1], self.color[2], self.color[3], min(1, max(0, self.color[4])))
    line:SetThickness(self.line_width)
    --    print (sx,sy,ex,ey)
    line:SetStartPoint("TOPLEFT", self.relative, sx, sy)
    line:SetEndPoint("TOPLEFT", self.relative, ex, ey)

    line:Show()
    tinsert(self.lines_used, line)
end

local full_circle = rad(360)
local small_circle_step = rad(9)
local big_circle_step = rad(24)

function Draw:Circle(x, y, z, radius, steps)
    if not x then
        return
    end
    steps = steps and steps or small_circle_step
    local lastX, lastY, nextX, nextY = false, false, false, false
    for theta = 0, full_circle, steps do
        nextX, nextY = (x + cos(theta) * radius), (y + sin(theta) * radius)
        self:Line(lastX, lastY, z, nextX, nextY, z)
        lastX, lastY = nextX, nextY
    end
end

-- original
function Draw:Arc(x, y, z, size, arc, rotation)
    local lx, ly, nx, ny, fx, fy = false, false, false, false, false, false
    local half_arc = arc * 0.5
    local ss = (arc / half_arc)
    local as, ae = -half_arc, half_arc
    local p
    for v = as, ae, ss do
        if v then
            nx, ny = self:WorldToScreen((x + cos(rotation + rad(v)) * size), (y + sin(rotation + rad(v)) * size), z)
            if lx and ly and nx and ny then
                self:Line2D(lx, ly, nx, ny)
            else
                fx, fy = nx, ny
            end
            lx, ly = nx, ny
        end
    end
    local px, py = self:WorldToScreen(x, y, z)
    if lx and ly and fx and fy then
        self:Line2D(px, py, lx, ly)

        self:Line2D(px, py, fx, fy)
    end
end

-- function Draw:Arc(x, y, z, size, arc, rotation)
--   local lx, ly, nx, ny, fx, fy = false, false, false, false, false, false
--   local half_arc = arc * 0.5
--   local ss = (arc / half_arc)
--   local as, ae = -half_arc, half_arc
--   for v = as, ae, ss do
--     nx, ny = self:WorldToScreen((x + cos(rotation + rad(v)) * size), (y + sin(rotation + rad(v)) * size), z)
--     if lx and ly then
--       self:Line2D(lx, ly, nx, ny)
--     else
--       fx, fy = nx, ny
--     end
--     lx, ly = nx, ny
--   end
--   local px, py = WorldToScreen(x, y, z)
--   self:Line2D(px, py, lx, ly)
--   self:Line2D(px, py, fx, fy)
-- end

function Draw:FilledArc(x, y, z, size, arc, rotation)

    local vertices = {}

    tinsert(vertices, Point(0, 0))

    local lx, ly, nx, ny, fx, fy = false, false, false, false, false, false
    local half_arc = arc * 0.5
    local ss = half_arc / 4
    local as, ae = -half_arc, half_arc
    for v = as, ae, ss do
        nx, ny = (x + cos(rotation + rad(v)) * size), (y + sin(rotation + rad(v)) * size)
        tinsert(vertices, Point(nx - x, ny - y))
    end

    local tris = triangulate(vertices)

    for _, _tri in ipairs(tris) do
        tri.v1.x = _tri.p1.x
        tri.v1.y = _tri.p1.y
        tri.v1.z = 0

        tri.v2.x = _tri.p2.x
        tri.v2.y = _tri.p2.y
        tri.v2.z = 0

        tri.v3.x = _tri.p3.x
        tri.v3.y = _tri.p3.y
        tri.v3.z = 0

        self:Triangle(x, y, z, tri.v1, tri.v2, tri.v3, false, false)
    end

end

function Draw:Rectangle(x, y, z, w, l, rot)
    local tLeft = {
        x = x - w,
        y = y + l
    }

    local tRight = {
        x = x + w,
        y = y + l
    }

    local bLeft = {
        x = x - w,
        y = y - l
    }

    local bRight = {
        x = x + w,
        y = y - l
    }

    local tlx, tly, tlz = math.cos(rot) * (tLeft.x - x) - math.sin(rot) * (tLeft.y - y) + x,
        math.sin(rot) * (tLeft.x - x) + math.cos(rot) * (tLeft.y - y) + y, z
    local blx, bly, blz = math.cos(rot) * (bLeft.x - x) - math.sin(rot) * (bLeft.y - y) + x,
        math.sin(rot) * (bLeft.x - x) + math.cos(rot) * (bLeft.y - y) + y, z
    local trx, try, trz = math.cos(rot) * (tRight.x - x) - math.sin(rot) * (tRight.y - y) + x,
        math.sin(rot) * (tRight.x - x) + math.cos(rot) * (tRight.y - y) + y, z
    local brx, bry, brz = math.cos(rot) * (bRight.x - x) - math.sin(rot) * (bRight.y - y) + x,
        math.sin(rot) * (bRight.x - x) + math.cos(rot) * (bRight.y - y) + y, z

    self:Line(tlx, tly, z, trx, try, z)
    self:Line(trx, try, z, brx, bry, z)
    self:Line(brx, bry, z, blx, bly, z)
    self:Line(blx, bly, z, tlx, tly, z)
end

function Draw:Cylinder(x, y, z, radius, height)
    local lastX, lastY, nextX, nextY = false, false, false, false
    for theta = 0, full_circle, big_circle_step do
        nextX, nextY = (x + cos(theta) * radius), (y + sin(theta) * radius)

        self:Line(lastX, lastY, z, nextX, nextY, z)
        self:Line(lastX, lastY, z, lastX, lastY, z + height)
        self:Line(lastX, lastY, z + height, nextX, nextY, z + height)
        lastX, lastY = nextX, nextY
    end
end

function Draw:Array(vectors, x, y, z, rotationX, rotationY, rotationZ)
    for _, vector in ipairs(vectors) do
        local sx, sy, sz = x + vector[1], y + vector[2], z + vector[3]
        local ex, ey, ez = x + vector[4], y + vector[5], z + vector[6]
        if rotationX then
            sx, sy, sz = self:RotateX(x, y, z, sx, sy, sz, rotationX)
            ex, ey, ez = self:RotateX(x, y, z, ex, ey, ez, rotationX)
        end
        if rotationY then
            sx, sy, sz = self:RotateY(x, y, z, sx, sy, sz, rotationY)
            ex, ey, ez = self:RotateY(x, y, z, ex, ey, ez, rotationY)
        end
        if rotationZ then
            sx, sy, sz = self:RotateZ(x, y, z, sx, sy, sz, rotationZ)
            ex, ey, ez = self:RotateZ(x, y, z, ex, ey, ez, rotationZ)
        end
        self:Line(sx, sy, sz, ex, ey, ez)
    end
end

function Draw:Text(text, font, x, y, z)
    local sx, sy = self:WorldToScreen(x, y, z)
    if sx and sy then
        if sx == 0 or sy == 0 then
            return
        end
        local string = tremove(self.strings) or self.canvas:CreateFontString(nil, "BACKGROUND")
        string:SetFontObject(font)
        string:SetText(text)
        string:SetTextColor(self.color[1], self.color[2], self.color[3], self.color[4])
        string:SetPoint("TOPLEFT", self.relative, "TOPLEFT", sx - (string:GetStringWidth() * 0.5), sy)
        string:Show()
        tinsert(self.strings_used, string)
    end
end

function Draw:Triangle(x, y, z, v1, v2, v3, cull, wireframe, drawLayer)
    if not v1 or not v2 or not v3 then
        return
    end
    if cull == nil then
        cull = true
    end
    if wireframe == nil then
        wireframe = false
    end

    local x1, y1 = self:WorldToScreen(x + v1.x, y + v1.y, z + v1.z)
    local x2, y2 = self:WorldToScreen(x + v2.x, y + v2.y, z + v2.z)
    local x3, y3 = self:WorldToScreen(x + v3.x, y + v3.y, z + v3.z)
    if not x1 or not y1 or not x2 or not y2 or not x3 or not y3 then
        return
    end
    if cull then
        local d1x = x3 - x1
        local d1y = y3 - y1
        local d2x = x3 - x2
        local d2y = y3 - y2
        local vZ = (d1x * d2y) - (d1y * d2x)
        if vZ > 0 then
            self:Triangle2D(x1, y1, x2, y2, x3, y3, drawLayer)

            if wireframe then
                local old = self.color
                self:SetColor(self.colors.green)
                self:Line2D(x1, y1, x2, y2)
                self:Line2D(x2, y2, x3, y3)
                self:Line2D(x3, y3, x1, y1)
                self:SetColor(old)
            end
        end
    else
        self:Triangle2D(x1, y1, x2, y2, x3, y3, drawLayer)
        if wireframe then
            local old = self.color
            self:SetColor(self.colors.green)
            self:Line2D(x1, y1, x2, y2)
            self:Line2D(x2, y2, x3, y3)
            self:Line2D(x3, y3, x1, y1)
            self:SetColor(old)
        end
    end
end
function Draw:TriangleAbsolut(v1, v2, v3)
    local x1, y1 = self:WorldToScreen(v1.x, v1.y, v1.z)
    local x2, y2 = self:WorldToScreen(v2.x, v2.y, v2.z)
    local x3, y3 = self:WorldToScreen(v3.x, v3.y, v3.z)
    self:Triangle2D(x1, y1, x2, y2, x3, y3)
end
local tri_scale = 510 / 512
local tri_scale2 = 1 / 512

function Draw:Triangle2D(x1, y1, x2, y2, x3, y3, drawLayer)
    if not x1 or not y1 or not x2 or not y2 or not x3 or not y3 then
        return
    end
    local minx = min(x1, x2, x3)
    local miny = min(y1, y2, y3)
    local maxx = max(x1, x2, x3)
    local maxy = max(y1, y2, y3)

    local dx = maxx - minx
    local dy = maxy - miny

    if dx == 0 or dy == 0 then
        return
    end

    local tx3, ty1, ty2, ty3

    if x1 == minx then
        if x2 == maxx then
            tx3, ty1, ty2, ty3 = (x3 - minx) / dx, (maxy - y1), (maxy - y2), (maxy - y3)
        else
            tx3, ty1, ty2, ty3 = (x2 - minx) / dx, (maxy - y1), (maxy - y3), (maxy - y2)
        end
    elseif x2 == minx then
        if x1 == maxx then
            tx3, ty1, ty2, ty3 = (x3 - minx) / dx, (maxy - y2), (maxy - y1), (maxy - y3)
        else
            tx3, ty1, ty2, ty3 = (x1 - minx) / dx, (maxy - y2), (maxy - y3), (maxy - y1)
        end
    else
        if x2 == maxx then
            tx3, ty1, ty2, ty3 = (x1 - minx) / dx, (maxy - y3), (maxy - y2), (maxy - y1)
        else
            tx3, ty1, ty2, ty3 = (x2 - minx) / dx, (maxy - y3), (maxy - y1), (maxy - y2)
        end
    end

    local t1 = -tri_scale / (ty3 - tx3 * ty2 + (tx3 - 1) * ty1)
    local t2 = dy * t1
    x1 = tri_scale2 - t1 * tx3 * ty1
    x2 = tri_scale2 + t1 * ty1
    x3 = t2 * tx3 + x1
    y1 = t1 * (ty2 - ty1)
    y2 = t1 * (ty1 - ty3)
    y3 = -t2 + x2

    if abs(t2) >= 9000 then
        return
    end

    local texture = tremove(self.triangles) or false
    if not texture then
        texture = self.canvas:CreateTexture("Tri" .. #self.triangles + 1, drawLayer or "BACKGROUND")
        texture:SetTexture("Textures\\triangle")
    else
        texture:SetDrawLayer(drawLayer or "BACKGROUND")
    end

    texture:SetPoint("BOTTOMLEFT", self.relative, "TOPLEFT", minx, miny)
    texture:SetPoint("TOPRIGHT", self.relative, "TOPLEFT", maxx, maxy)
    texture:SetTexCoord(x1, x2, x3, y3, x1 + y2, x2 + y1, y2 + x3, y1 + y3)
    texture:SetVertexColor(self.color[1], self.color[2], self.color[3], self.color[4])
    texture:Show()
    tinsert(self.triangles_used, texture)
end

local cps = {}
for i = 1, 5 do
    cps[i * 2 - 1] = -cos(2 * pi / 5 * (i - 1))
    cps[i * 2] = sin(2 * pi / 5 * (i - 1))
end

function Draw:FilledCircle(x, y, z, r)
    if x and y and z and r then
        local x1, y1, z1 = x - (cps[1] * r), y - (cps[2] * r), z
        local x2, y2, z2 = x - (cps[3] * r), y - (cps[4] * r), z
        local x3, y3, z3 = x - (cps[5] * r), y - (cps[6] * r), z
        local x4, y4, z4 = x - (cps[7] * r), y - (cps[8] * r), z
        local x5, y5, z5 = x - (cps[9] * r), y - (cps[10] * r), z
        local v1 = {}
        v1.x, v1.y = self:WorldToScreen(x1, y1, z1)
        local v2 = {}
        v2.x, v2.y = self:WorldToScreen(x2, y2, z2)
        local v3 = {}
        v3.x, v3.y = self:WorldToScreen(x3, y3, z3)
        local v4 = {}
        v4.x, v4.y = self:WorldToScreen(x4, y4, z4)
        local v5 = {}
        v5.x, v5.y = self:WorldToScreen(x5, y5, z5)
        if v1.x and v1.y and v2.x and v2.y and v3.x and v3.y and v4.x and v4.y and v5.x and v5.y then
            self:Draw3DTexture(v1, v2, v3, v4, v5, false, "Textures\\filledcircle")
        end
    end
end

function Draw:FilledRectangle(x, y, z, w, l, rot, offset)
    local nlX, nlY, nrX, nrY, frX, frY, flX, flY, flZ, nlZ, nrZ, frZ = getRect(w, l, x, y, z, offset or 0, rot)

    local vertices = {Point(0, 0), Point(nlX - x, nlY - y), Point(nrX - x, nrY - y), Point(frX - x, frY - y),
                      Point(flX - x, flY - y)}

    local tris = triangulate(vertices)

    for _, _tri in ipairs(tris) do
        tri.v1.x = _tri.p1.x
        tri.v1.y = _tri.p1.y
        tri.v1.z = 0

        tri.v2.x = _tri.p2.x
        tri.v2.y = _tri.p2.y
        tri.v2.z = 0

        tri.v3.x = _tri.p3.x
        tri.v3.y = _tri.p3.y
        tri.v3.z = 0

        self:Triangle(x, y, z, tri.v1, tri.v2, tri.v3, false, false)
    end

end

function Draw:Outline(x, y, z, r)
    if x and y and z and r then
        local x1, y1, z1 = x - (cps[1] * r), y - (cps[2] * r), z
        local x2, y2, z2 = x - (cps[3] * r), y - (cps[4] * r), z
        local x3, y3, z3 = x - (cps[5] * r), y - (cps[6] * r), z
        local x4, y4, z4 = x - (cps[7] * r), y - (cps[8] * r), z
        local x5, y5, z5 = x - (cps[9] * r), y - (cps[10] * r), z

        local v1 = {}
        v1.x, v1.y = self:WorldToScreen(x1, y1, z1)
        local v2 = {}
        v2.x, v2.y = self:WorldToScreen(x2, y2, z2)
        local v3 = {}
        v3.x, v3.y = self:WorldToScreen(x3, y3, z3)
        local v4 = {}
        v4.x, v4.y = self:WorldToScreen(x4, y4, z4)
        local v5 = {}
        v5.x, v5.y = self:WorldToScreen(x5, y5, z5)
        if v1.x and v1.y and v2.x and v2.y and v3.x and v3.y and v4.x and v4.y and v5.x and v5.y then
            self:Draw3DTexture(v1, v2, v3, v4, v5, false, "Textures\\outline")
        end
    end
end

local not_printed = {}
function Draw:Draw3DTexture(v1, v2, v3, v4, v5, rotate, tex)
    local p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y = v1.x, v1.y, v2.x, v2.y, v3.x, v3.y, v4.x, v4.y, v5.x, v5.y

    local l0x, l0y, l0z = p0y - p1y, p1x - p0x, p0x * p1y - p0y * p1x
    local l1x, l1y, l1z = p1y - p2y, p2x - p1x, p1x * p2y - p1y * p2x
    local l2x, l2y, l2z = p2y - p3y, p3x - p2x, p2x * p3y - p2y * p3x
    local l3x, l3y, l3z = p3y - p4y, p4x - p3x, p3x * p4y - p3y * p4x
    local qx, qy, qz = l0y * l3z - l0z * l3y, l0z * l3x - l0x * l3z, l0x * l3y - l0y * l3x
    local A, B, C = qx, qy, qz
    local a1, b1, c1 = l1x, l1y, l1z
    local a2, b2, c2 = l2x, l2y, l2z
    local x0, y0, w0 = p0x, p0y, 1
    local x4, y4, w4 = p4x, p4y, 1
    local y4w0 = y4 * w0
    local w4y0 = w4 * y0
    local w4w0 = w4 * w0
    local y4y0 = y4 * y0
    local x4w0 = x4 * w0
    local w4x0 = w4 * x0
    local x4x0 = x4 * x0
    local y4x0 = y4 * x0
    local x4y0 = x4 * y0
    local a1a2 = a1 * a2
    local a1b2 = a1 * b2
    local a1c2 = a1 * c2
    local b1a2 = b1 * a2
    local b1b2 = b1 * b2
    local b1c2 = b1 * c2
    local c1a2 = c1 * a2
    local c1b2 = c1 * b2
    local c1c2 = c1 * c2
    local t1, t2, t3, t4

    local a =
        -A * a1a2 * y4w0 + A * a1a2 * w4y0 - B * b1a2 * y4w0 - B * c1a2 * w4w0 + B * a1b2 * w4y0 + B * a1c2 * w4w0 + C *
            b1a2 * y4y0 + C * c1a2 * w4y0 - C * a1b2 * y4y0 - C * a1c2 * y4w0

    local c =
        A * c1b2 * w4w0 + A * a1b2 * x4w0 - A * b1c2 * w4w0 - A * b1a2 * w4x0 + B * b1b2 * x4w0 - B * b1b2 * w4x0 + C *
            b1c2 * x4w0 + C * b1a2 * x4x0 - C * c1b2 * w4x0 - C * a1b2 * x4x0

    local f =
        A * c1a2 * y4x0 + A * c1b2 * y4y0 - A * a1c2 * x4y0 - A * b1c2 * y4y0 - B * c1a2 * x4x0 - B * c1b2 * x4y0 + B *
            a1c2 * x4x0 + B * b1c2 * y4x0 - C * c1c2 * x4y0 + C * c1c2 * y4x0

    local b =
        A * c1a2 * w4w0 + A * a1a2 * x4w0 - A * a1b2 * y4w0 - A * a1c2 * w4w0 - A * a1a2 * w4x0 + A * b1a2 * w4y0 + B *
            b1a2 * x4w0 - B * b1b2 * y4w0 - B * c1b2 * w4w0 - B * a1b2 * w4x0 + B * b1b2 * w4y0 + B * b1c2 * w4w0 - C *
            b1c2 * y4w0 - C * b1a2 * x4y0 - C * b1a2 * y4x0 - C * c1a2 * w4x0 + C * c1b2 * w4y0 + C * a1b2 * x4y0 + C *
            a1b2 * y4x0 + C * a1c2 * x4w0

    local d =
        -A * c1a2 * y4w0 + A * a1a2 * y4x0 + A * a1b2 * y4y0 + A * a1c2 * w4y0 - A * a1a2 * x4y0 - A * b1a2 * y4y0 + B *
            b1a2 * y4x0 + B * c1a2 * w4x0 + B * c1a2 * x4w0 + B * c1b2 * w4y0 - B * a1b2 * x4y0 - B * a1c2 * w4x0 - B *
            a1c2 * x4w0 - B * b1c2 * y4w0 + C * b1c2 * y4y0 + C * c1c2 * w4y0 - C * c1a2 * x4y0 - C * c1b2 * y4y0 - C *
            c1c2 * y4w0 + C * a1c2 * y4x0

    local e =
        -A * c1a2 * w4x0 - A * c1b2 * y4w0 - A * c1b2 * w4y0 - A * a1b2 * x4y0 + A * a1c2 * x4w0 + A * b1c2 * y4w0 + A *
            b1c2 * w4y0 + A * b1a2 * y4x0 - B * b1a2 * x4x0 - B * b1b2 * x4y0 + B * c1b2 * x4w0 + B * a1b2 * x4x0 + B *
            b1b2 * y4x0 - B * b1c2 * w4x0 - C * b1c2 * x4y0 + C * c1c2 * x4w0 + C * c1a2 * x4x0 + C * c1b2 * y4x0 - C *
            c1c2 * w4x0 - C * a1c2 * x4x0

    if a ~= 0.0 then
        b = b / a
        c = c / a
        d = d / a
        e = e / a
        f = f / a
        a = 1.0
    elseif b ~= 0.0 then
        c = c / b
        d = d / b
        e = e / b
        f = f / b
        b = 1.0
    elseif c ~= 0.0 then
        d = d / c
        e = e / c
        f = f / c
        c = 1.0
    elseif d ~= 0.0 then
        e = e / d
        f = f / d
        d = 1.0
    elseif e ~= 0.0 then
        f = f / e
        e = 1.0
    else
        return
    end
    b = b / 2
    d = d / 2
    e = e / 2
    t1 = (b * b - a * c)
    local x0 = (c * d - b * e) / t1
    local y0 = (a * e - b * d) / t1
    t2 = 2 * (a * e * e + c * d * d + f * b * b - 2 * b * d * e - a * c * f)
    t3 = sqrt((a - c) * (a - c) + 4 * b * b)
    local w1 = sqrt(t2 / (t1 * (t3 - (a + c))))
    local w2 = sqrt(t2 / (t1 * (-t3 - (a + c))))
    local p
    if b == 0 then
        if a < c then
            p = 0
        else
            p = 0.5 * pi
        end
    else
        if a < c then
            if b < 0 then
                p = 0.5 * (0.5 * pi - atan((a - c) / (2 * b)))
            else
                p = 0.5 * (-0.5 * pi - atan((a - c) / (2 * b)))
            end
        else
            if b < 0 then
                p = 0.5 * (pi - 0.5 * pi - atan((a - c) / (2 * b)))
            else
                p = 0.5 * (pi + 0.5 * pi - atan((a - c) / (2 * b)))
            end
        end
    end
    local texture = tremove(self.textures) or false
    if not texture then
        texture = self.canvas:CreateTexture(nil, "BACKGROUND")
        texture:SetDrawLayer("BACKGROUND")
    end
    texture:Hide()
    local w = max(w1, w2)
    w1 = w1 * 2
    w2 = w2 * 2
    texture:SetPoint("TOPLEFT", self.canvas, "TOPLEFT", x0 - w, y0 + w)
    texture:SetPoint("BOTTOMRIGHT", self.canvas, "TOPLEFT", x0 + w, y0 - w)
    texture:SetTexture(tex)
    texture:SetBlendMode("ADD")

    local cp = cos(-p)
    local sp = sin(-p)
    w = w * 2

    w1 = w1 / w
    w2 = w2 / w

    if rotate then
        local tx = (p0x - x0) / w
        local ty = (p0y - y0) / w
        t1 = sqrt(cp * cp * w1 * w1 + sp * sp * w2 * w2 - 4 * tx * tx)
        t2 = sqrt(cp * cp * w2 * w2 + sp * sp * w1 * w1 - 4 * ty * ty)
        local q = (2 * atan((cp * w1 - t1) / (sp * w2 + 2 * tx))) % pi2
        local q3 = (2 * atan((-sp * w1 - t2) / (cp * w2 - 2 * ty)) + pi) % pi2
        local q4 = (2 * atan((-sp * w1 + t2) / (cp * w2 - 2 * ty)) + pi) % pi2
        if abs(q - q3) < 0.0000001 then
        elseif abs(q - q4) < 0.0000001 then
        else
            q = (2 * atan((cp * w1 + t1) / (sp * w2 + 2 * tx))) % pi2
        end
        local cq = cos(q)
        local sq = sin(q)

        t1 = cp * cq * w1 - sp * sq * w2
        t2 = -cq * sp * w2 - cp * sq * w1
        t3 = cp * sq * w2 + cq * sp * w1
        t4 = cp * cq * w2 - sp * sq * w1
    else
        t1 = cp * w1
        t2 = -sp * w2
        t3 = sp * w1
        t4 = cp * w2
    end

    local det = w1 * w2 * 2
    if det < 0.0003 or det ~= det then
        texture:Hide()
        tinsert(self.textures_used, texture)
        return
    end

    texture:SetTexCoord(0.5 + (t2 - t4) / det, 0.5 + (-t1 + t3) / det, 0.5 + (-t2 - t4) / det, 0.5 + (t1 + t3) / det,
        0.5 + (t4 + t2) / det, 0.5 + (-t3 - t1) / det, 0.5 + (t4 - t2) / det, 0.5 + (-t3 + t1) / det)

    local a = self.color[4]
    if a < 0 then
        a = 0
    elseif a > 1 then
        a = 1
    end

    texture:SetVertexColor(self.color[1], self.color[2], self.color[3], a)

    texture:Show()

    tinsert(self.textures_used, texture)

    return texture
end

function Draw:Texture(config, x, y, z, alphaA)
    local texture_file, width, height = config.texture, config.width, config.height
    local left, right, top, bottom, scale = config.left, config.right, config.top, config.bottom, config.scale
    local alpha = config.alpha or (alphaA or 1)

    if not texture_file or not width or not height or not x or not y or not z then
        return
    end
    if not left or not right or not top or not bottom then
        left = 0
        right = 1
        top = 0
        bottom = 1
    end

    if not scale then
        local cx, cy, cz = self:CameraPosition()
        scale = width / self:Distance(x, y, z, cx, cy, cz)
    end

    local sx, sy = self:WorldToScreen(x, y, z)

    if not sx or not sy then
        return
    end
    local w = width * scale
    local h = height * scale
    sx = sx - w * 0.5
    sy = sy + h * 0.5
    local ex, ey = sx + w, sy - h

    local texture = tremove(self.textures) or false
    if not texture then
        texture = self.canvas:CreateTexture(nil, "BACKGROUND")
        texture:SetDrawLayer("BACKGROUND")
    end

    texture:ClearAllPoints()
    texture:SetTexture(texture_file)
    texture:SetTexCoord(left, right, top, bottom)
    texture:SetWidth(width)
    texture:SetHeight(height)

    if sx == ex and sy == ey then
        texture:SetPoint("TOPLEFT", self.relative, "TOPLEFT", sx, sy)
        texture:SetPoint("BOTTOMRIGHT", self.relative, "TOPLEFT", ex + 1, ey - 1)
    end

    texture:SetPoint("TOPLEFT", self.relative, "TOPLEFT", sx, sy)
    texture:SetPoint("BOTTOMRIGHT", self.relative, "TOPLEFT", ex, ey)
    texture:SetVertexColor(1, 1, 1, 1)
    texture:SetAlpha(alpha)
    texture:Show()

    tinsert(self.textures_used, texture)
end

function Draw:ClearCanvas()
    for i = #self.lines_used, 1, -1 do
        self.lines_used[i]:Hide()
        tinsert(self.lines, tremove(self.lines_used))
    end
    for i = #self.strings_used, 1, -1 do
        self.strings_used[i]:Hide()
        tinsert(self.strings, tremove(self.strings_used))
    end
    for i = #self.textures_used, 1, -1 do
        self.textures_used[i]:Hide()
        self.textures_used[i]:SetTexture("")
        self.textures_used[i]:SetTexCoord(0, 1, 0, 1)
        tinsert(self.textures, tremove(self.textures_used))
    end
    for i = #self.triangles_used, 1, -1 do
        self.triangles_used[i]:Hide()
        tinsert(self.triangles, tremove(self.triangles_used))
    end
end

function Draw:Update()
    self:ClearCanvas()
    for _, callback in ipairs(self.callbacks) do
        callback(self)
    end
end

local deg45 = rad(45)
local arrowX = {{0, 0, 0, 1.5, 0, 0}, {1.5, 0, 0, 1.2, 0.2, -0.2}, {1.5, 0, 0, 1.2, -0.2, 0.2}}
local arrowY = {{0, 0, 0, 0, 1.5, 0}, {0, 1.5, 0, 0.2, 1.2, -0.2}, {0, 1.5, 0, -0.2, 1.2, 0.2}}
local arrowZ = {{0, 0, 0, 0, 0, 1.5}, {0, 0, 1.5, 0.2, -0.2, 1.2}, {0, 0, 1.5, -0.2, 0.2, 1.2}}
function Draw:HexToRGB(hex)
    hex = hex:gsub("#", "")
    if strlen(hex) == 3 then
        return tonumber("0x" .. hex:sub(1, 1) .. hex:sub(1, 1)), tonumber("0x" .. hex:sub(2, 2) .. hex:sub(2, 2)),
            tonumber("0x" .. hex:sub(3, 3) .. hex:sub(3, 3)), 255
    elseif strlen(hex) == 6 then
        return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)), 255
    elseif strlen(hex) == 8 then
        return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)),
            tonumber("0x" .. hex:sub(7, 8))
    end
end

function Draw:Helper()
    local playerX, playerY, playerZ = blink.player.position()
    local playerH = blink.player.height
    local old_red, old_green, old_blue, old_alpha, old_width = self.color[1], self.color[2], self.color[3],
        self.color[4], self.line_width

    -- X
    self:SetColor(self.colors.red)
    self:SetWidth(1)
    self:Array(arrowX, playerX, playerY, playerZ, deg45, false, false)
    self:Text("X", "GameFontNormal", playerX + playerH, playerY, playerZ)

    -- Y
    self:SetColor(self.colors.green)
    self:SetWidth(1)
    self:Array(arrowY, playerX, playerY, playerZ, false, -deg45, false)
    self:Text("Y", "GameFontNormal", playerX, playerY + playerH, playerZ)

    -- Z
    self:SetColor(self.colors.blue)
    self:SetWidth(1)
    self:Array(arrowZ, playerX, playerY, playerZ, false, false, false)
    self:Text("Z", "GameFontNormal", playerX, playerY, playerZ + playerH)

    self.color[1], self.color[2], self.color[3], self.color[4], self.line_width = old_red, old_green, old_blue,
        old_alpha, old_width
end

function Draw:Enable()
    self.canvas:SetScript("OnUpdate", function()
        self:Update()
    end)
    self.enabled = true
end

function Draw:Disable()
    self:ClearCanvas()
    self.canvas:SetScript("OnUpdate", function()
        -- nothing
    end)
    self.enabled = false
    self.callbacks = {}
    self.lines = {}
    self.lines_used = {}
    self.strings = {}
    self.strings_used = {}
    self.textures = {}
    self.textures_used = {}
    self.triangles = {}
    self.triangles_used = {}
    self.color = {0.17, 0.72, 0.87}
    self.line_width = 1
end

function Draw:Enabled()
    return self.enabled
end

function Draw:Sync(callback)
    tinsert(self.callbacks, callback)
end

function Draw:New(canvas)
    local ld = {
        canvas = CreateFrame("Frame", "ADFrame", canvas or WorldFrame),
        callbacks = {},
        lines = {},
        lines_used = {},
        strings = {},
        strings_used = {},
        textures = {},
        textures_used = {},
        triangles = {},
        triangles_used = {},
        color = {self:HexToRGB("50c3ff")},
        line_width = 1,
        enabled = false,
        relative = canvas and canvas or WorldFrame
    }

    ld.scale = ld.relative:GetScale()
    ld.width, ld.height = ld.relative:GetSize()
    ld.canvas:SetAllPoints(ld.relative)

    local WorldToScreen_Original = WorldToScreen
    local WorldToScreen = false

    if Unlocker.Util.Draw then
        local Draw = Unlocker.Util.Draw
        local wts = Draw.WorldToScreen
        WorldToScreen = function(ox, oy, oz)
            return wts(ld, ox, oy, oz)
        end
    elseif unlockerType == "noname" then
        WorldToScreen = function(ox, oy, oz)
            local posx, posy, posz, camx, camy, camz, mXX, mXY, mXZ, mYX, mYY, mYZ, mZX, mZY, mZZ, transX, transY,
                transZ, x, y = IsMacClient(33, ox, oy, oz)

            posx = ox - camx
            posy = oy - camy
            posz = oz - camz

            local height = GetScreenHeight()
            local width = GetScreenWidth()
            local fov_x = 2 * (math.atan(0.27 * (width / height)))

            transX = (posx * mYX) + (posy * mYY) + (posz * mYZ)
            transY = (posx * mZX) + (posy * mZY) + (posz * mZZ)
            transZ = (posx * mXX) + (posy * mXY) + (posz * mXZ)

            local sx = transX / fov_x / transZ
            local sy = transY / 0.5 / transZ
            local visible = transZ > 0 -- print (visible)
            sx = (1 - sx) / 2
            sy = (1 - sy) / 2
            return sx, sy, visible
        end
    else
        -- WorldToScreen = function(wX, wY, wZ)
        --     local sX, sY = WorldToScreen_Original(wX, wY, wZ)
        --     return sX, -sY
        -- end

        --ma fix 
        WorldToScreen = function(wX, wY, wZ)
            local sX, sY, Visible = WorldToScreen_Original(wX, wY, wZ)
            if not Visible and (not sX or sX == 0) and (not sY or sY == 0) then
                return false, false, false
            end
            return sX, -sY
        end
    end

    function Draw:WorldToScreen(wx, wy, wz)
        local sx, sy, visible = WorldToScreen(wx, wy, wz)
        if visible == false then
            return false
        end
        if unlockerType == "noname" then
            local overflow = 400
            sx = ((self.width * sx) * self.scale)
            sy = -((self.height * sy) * self.scale)
            if sx > self.width + overflow or sx < -overflow then
                return false
            end
            if sy > overflow or abs(sy) > self.height + overflow then
                return false
            end
        end
        if sx == 0 or sy == 0 then
            return false
        end
        return sx, sy
    end

    return setmetatable(ld, {
        __index = self
    })
end

-- Blink Extension
do
    local Draw = Draw:New()

    -- rect fix
    local ogRect = Draw.Rectangle
    local rectOverwrite = function(self, x, y, z, w, l, rot)
        l = l / 2
        w = w / 2
        rot = blink.rotate(rot, -pi * 2)
        x = x + l * cos(rot)
        y = y + l * sin(rot)
        rot = blink.rotate(rot, -pi / 2)
        return ogRect(self, x, y, z, w, l, rot)
    end
    Draw.Rectangle = rectOverwrite

    Draw:Sync(function(draw)

        local time = blink.time
        
        player = player or blink.player
        local px, py, pz = player.position()

        local debug = blink.debug

        if debug.friends then
            for _, obj in ipairs(blink.friends) do
                local x, y, z = obj.position()
                draw:SetColor(100, 225, 100, 55)
                local cr = obj.combatReach or 1.5
                draw:FilledCircle(x, y, z, cr)
                if obj.class2 then
                    local red, green, blue = hex2rgb(colors[obj.class2:lower()])
                    if red and green and blue then
                        draw:SetColor(red, green, blue, 245)
                        -- draw:SetWidth(12)
                        draw:Outline(x, y, z, cr)
                    end
                end
            end
        end

        if debug.enemies then
            for _, obj in ipairs(blink.enemies) do
                local x, y, z = obj.position()
                draw:SetColor(225, 100, 100, 55)
                draw:FilledCircle(x, y, z, 2)
                if obj.class2 then
                    local red, green, blue = hex2rgb(colors[obj.class2:lower()])
                    if red and green and blue then
                        draw:SetColor(red, green, blue, 245)
                        -- draw:SetWidth(12)
                        draw:Outline(x, y, z, cr)
                    end
                end
            end
        end

        if blink.debugSmartAoE and blink.pointsDraw then
            draw:SetColor(255, 1, 1, 255)
            for i, point in ipairs(blink.pointsDraw) do
                local x, y, z = point.x, point.y, point.z
                if i > 1 then
                    draw:SetColor(255, 255, 255, ((#blink.pointsDraw - i) / #blink.pointsDraw) * 78 + 5)
                end
                draw:FilledCircle(x, y, z, 0.15)
            end
        end

        if blink.arena and blink.saved.healerLine then
            if healer.exists and (not healer.los or healer.dist > 39) then
                local x, y, z = healer.position()
                if x then
                    draw:SetColor(draw.colors.red)
                    draw:Line(px, py, pz, x, y, z)
                end
            end
        end

        if not blink.saved.disableDrawings then
            for _, callback in ipairs(blink.DrawCallbacks) do
                callback(draw)
            end
        end

    end)
    Draw:Enable()
end

-- grab textures on daemonic
local function httpAsync(method, url, parameters, headers, callback)
    local id = InetRequest(method, url, parameters, headers)
    local function check()
        local res, status = InetGetRequest(id)
        if res then
            callback(res, status)
        else
            C_Timer.After(0, function()
                check(id)
            end)
        end
    end
    return check(id)
end

local function grabAndInstall(url, dir)
    local function callback(res, status)
        if status == 200 then
            WriteFile(dir, res, false)
            return true
        else
            return false
        end
    end
    return httpAsync("GET", url, "", "", callback)
end

C_Timer.After(0.5, function()
    if Unlocker.type == "daemonic" then
        local function httpAsync(method, url, parameters, headers, callback)
            local id = InetRequest(method, url, parameters, headers)
            local function check()
                local res, status = InetGetRequest(id)
                if res then
                    callback(res, status)
                else
                    C_Timer.After(0, function()
                        check(id)
                    end)
                end
            end
            return check(id)
        end

        local textures = {"LineTemplate.tga", "filledcircle.tga", "outline.tga", "triangle.tga", "OpenSans-Bold.ttf",
                          "OpenSans-Regular.ttf", "logo.blp"}

        local function indexOf(val)
            for i = 1, #textures do
                if textures[i] == val then
                    return i
                end
            end
        end

        local WoWDir = GetWowDirectory()
        if not DirectoryExists(WoWDir .. "\\Textures") then
            CreateDirectory(WoWDir .. "\\Textures")
        end
        if not DirectoryExists(WoWDir .. "\\Fonts") then
            CreateDirectory(WoWDir .. "\\Fonts")
        end

        local printed = false

        local function grabTexture(texture)
            local url = "sadrotations.com/Textures/"
            local function callback(res, status)
                if status == 200 then
                    if texture:match(".ttf") then
                        WriteFile(WoWDir .. "\\Fonts\\" .. texture, res, false)
                    else
                        WriteFile(WoWDir .. "\\Textures\\" .. texture, res, false)
                    end
                else
                    if blink.DevMode then
                        blink.print("Failed to download textures...", true)
                    end
                    return false
                end
            end
            if not printed then
                if blink.DevMode then
                    blink.alert("Downloading important textures and fonts..")
                    blink.print("You may need to restart the game after this!")
                    C_Timer.After(5, function()
                        blink.print(
                            "Textures and fonts should be downloaded! Restart your game if you see green stuff showing up :)")
                    end)
                end
                printed = true
            end
            httpAsync("GET", url .. texture, "", "", callback)
        end

        for _, texture in ipairs(textures) do
            if texture:match(".ttf") then
                if not ReadFile(WoWDir .. "\\Fonts\\" .. texture) then
                    grabTexture(texture)
                end
            else
                if not ReadFile(WoWDir .. "\\Textures\\" .. texture) then
                    grabTexture(texture)
                end
            end
        end
    end
end)

blink.Draw(function(draw)
    draw:SetColor(170, 170, 240, 255)
    draw:SetWidth(1.5)
    for _, path in ipairs(blink.PathsToDraw) do
        for i, node in ipairs(path) do
            local next = path[i + 1]
            if next then
                draw:Line(node.x, node.y, node.z, next.x, next.y, next.z)
            end
        end
    end
end)

blink.DrawLib = Draw