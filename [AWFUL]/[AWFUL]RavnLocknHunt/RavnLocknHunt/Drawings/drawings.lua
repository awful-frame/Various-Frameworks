local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____geometry = ravn["Geometry.geometry"]
local Geometry = ____geometry.Geometry
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local ____pveLogic = ravn["PveLogic.pveLogic"]
local UnitType = ____pveLogic.UnitType
local pveLogic = ____pveLogic.pveLogic
local ____cache = ravn["Utilities.Cache.cache"]
local Cache = ____cache.Cache
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____affLib = ravn["rotation.lock.affli.affLib"]
local affLib = ____affLib.affLib
local ____demonoLib = ravn["rotation.lock.demono.demonoLib"]
local demonoLib = ____demonoLib.demonoLib
local ____lockLib = ravn["rotation.lock.lockLib"]
local lockLib = ____lockLib.lockLib
local ____lockspells = ravn["rotation.lock.lockspells"]
local demonicCircleSummon = ____lockspells.demonicCircleSummon
local shadowflame = ____lockspells.shadowflame
local soulSwap = ____lockspells.soulSwap
____exports.ravnDraw = __TS__Class()
local ravnDraw = ____exports.ravnDraw
ravnDraw.name = "ravnDraw"
function ravnDraw.prototype.____constructor(self)
end
function ravnDraw.cleanFilledArc(self, draw, pos, insideRadius, outsideRadius, arc, rotation, colorInside, colorBorder)
    local x, y, z = unpack(pos)
    draw:SetColorRaw(colorBorder[1], colorBorder[2], colorBorder[3], colorBorder[4])
    draw:Arc(
        x,
        y,
        z,
        outsideRadius,
        arc,
        rotation
    )
    draw:SetColorRaw(colorInside[1], colorInside[2], colorInside[3], colorInside[4])
    draw:FilledArc(
        x,
        y,
        z,
        insideRadius,
        arc,
        rotation
    )
end
function ravnDraw.WoWColorToRGBA(self, c, customAlpha, returnTable)
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
        self.drawer:SetColorRaw(r, g, b, a)
    end
end
function ravnDraw.registerCallback(self, callback)
    local ____self_callbacks_0 = self.callbacks
    ____self_callbacks_0[#____self_callbacks_0 + 1] = callback
end
function ravnDraw.queues(self, draw)
    for key, value in pairs(Queue.queues) do
        local unit = awful.GetObjectWithGUID(value.unit)
        if unit ~= nil and not unit.isUnit(awful.player) and unit.exists then
            unit:ClearCache()
            self:WoWColorToRGBA(awful.player.color)
            local x, y, z = awful.player.position()
            local x2, y2, z2 = unit.position()
            draw:Line(
                x,
                y,
                z,
                x2,
                y2,
                z2
            )
        end
    end
end
function ravnDraw.drawArcheology(self, draw)
    if not ravn.archeo then
        return
    end
    if ravn.archeo.lastBeacon then
        local x, y, z = unpack(ravn.archeo.lastBeacon.position)
        local color = ravn.archeo.lastBeacon.color
        local rotation = ravn.archeo.lastBeacon.rotation
        local r = 0
        local g = 0
        local b = 0
        local a = 0
        if color == "RED" then
            r = 1
            a = 0.5
        elseif color == "GREEN" then
            g = 1
            a = 0.5
        elseif color == "YELLOW" then
            r = 1
            g = 1
            a = 0.5
        end
        draw:SetColorRaw(r, g, b, a)
        draw:FilledArc(
            x,
            y,
            z,
            5,
            25,
            rotation
        )
        draw:FilledCircle(x, y, z, 2)
    end
    if ravn.archeo.archeologySpot then
        local x, y, z = unpack(ravn.archeo.archeologySpot)
        self:WoWColorToRGBA(Color.WHITE)
        draw:FilledCircle(x, y, z, 1)
        local los = awful.player.losCoords(x, y, z)
        if not los then
            self:WoWColorToRGBA(Color.RED)
            draw:Outline(x, y, z, 1)
        end
        if ravn.archeo.lastBeacon then
            draw:Line(
                x,
                y,
                z,
                ravn.archeo.lastBeacon.position[0],
                ravn.archeo.lastBeacon.position[1],
                ravn.archeo.lastBeacon.position[2]
            )
        end
    end
    local beacons = ravn.archeo.beacons
    if #beacons > 0 then
        do
            local i = 0
            while i < #beacons do
                local ds = beacons[i + 1]
                local pos = ds.position
                local a, b, c = unpack(pos)
                self:WoWColorToRGBA(Color.LIME)
                draw:Outline(a, b, c, 1)
                local txt = "Site #" .. tostring(i)
                draw:Text(
                    txt,
                    "GameFontNormalLarge",
                    a,
                    b,
                    c
                )
                i = i + 1
            end
        end
    end
end
function ravnDraw.debug(self, draw)
    if not awful.DevMode then
        return
    end
    if 1 == 1 then
        return
    end
    local x, y, z = unpack(self.positionCircle)
    self:WoWColorToRGBA(Color.WHITE, 0.2)
    draw:FilledCircle(x, y, z, 2)
    local cursorPosX = 0
    local cursorPosY = 0
    local function getNearestCursorFromAxis()
        local mx, my = GetCursorPosition()
        local maxX = WorldFrame:GetRight()
        local maxY = WorldFrame:GetTop()
        local x = 2 * (mx / maxX) - 1
        local y = 2 * (my / maxY) - 1
        local normalizedX = (x + 1) / 2
        local normalizedY = (y + 1) / 2
        x = normalizedX
        y = 1 - normalizedY
        cursorPosX = x
        cursorPosY = y
        local x1, y1 = unpack(self.posXLine)
        local x2, y2 = unpack(self.posYLine)
        local x3, y3 = unpack(self.posZLine)
        local distanceX = math.sqrt((x - x1) ^ 2 + (y - y1) ^ 2)
        local distanceY = math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2)
        local distanceZ = math.sqrt((x - x3) ^ 2 + (y - y3) ^ 2)
        if distanceX < distanceY and distanceX < distanceZ then
            return "X"
        elseif distanceY < distanceX and distanceY < distanceZ then
            return "Y"
        else
            return "Z"
        end
    end
    local LENGTH = 5
    local x1, y1, z1 = x + LENGTH, y, z
    local x2, y2, z2 = x, y + LENGTH, z
    local x3, y3, z3 = x, y, z + LENGTH
    local nearestLine = getNearestCursorFromAxis()
    if self.lockCurrentSelection then
        nearestLine = self.lockCurrentSelection
    end
    if nearestLine == "X" then
        self:WoWColorToRGBA(Color.YELLOW)
    else
        self:WoWColorToRGBA(Color.RED)
    end
    draw:Line(
        x,
        y,
        z,
        x1,
        y1,
        z1
    )
    draw:Text(
        "X",
        "GameFontNormalLarge",
        x1,
        y1,
        z1 + 1
    )
    if nearestLine == "Y" then
        self:WoWColorToRGBA(Color.YELLOW)
    else
        self:WoWColorToRGBA(Color.LIME)
    end
    draw:Line(
        x,
        y,
        z,
        x2,
        y2,
        z2
    )
    draw:Text(
        "Y",
        "GameFontNormalLarge",
        x2,
        y2,
        z2 + 1
    )
    if nearestLine == "Z" then
        self:WoWColorToRGBA(Color.YELLOW)
    else
        self:WoWColorToRGBA(Color.BLUE)
    end
    draw:Line(
        x,
        y,
        z,
        x3,
        y3,
        z3
    )
    draw:Text(
        "Z",
        "GameFontNormalLarge",
        x3,
        y3,
        z3 + 1
    )
    self.posXLine = {WorldToScreen(x1, y1, z1)}
    self.posYLine = {WorldToScreen(x2, y2, z2)}
    self.posZLine = {WorldToScreen(x3, y3, z3)}
    if not GetKeyState(12) then
        self.originCursorPos = {0, 0}
        self.lockCurrentSelection = nil
    else
        if self.originCursorPos[1] == 0 and self.originCursorPos[2] == 0 then
            self.originCursorPos = {cursorPosX, cursorPosY}
            self.lockCurrentSelection = nearestLine
        end
        local deltaX = cursorPosX - self.originCursorPos[1]
        local deltaY = cursorPosY - self.originCursorPos[2]
        if self.lockCurrentSelection == "X" then
            local ____self_positionCircle_1, ____1_2 = self.positionCircle, 1
            ____self_positionCircle_1[____1_2] = ____self_positionCircle_1[____1_2] + deltaX
        end
        if self.lockCurrentSelection == "Y" then
            local ____self_positionCircle_3, ____2_4 = self.positionCircle, 2
            ____self_positionCircle_3[____2_4] = ____self_positionCircle_3[____2_4] - deltaY
        end
        if self.lockCurrentSelection == "Z" then
            local ____self_positionCircle_5, ____3_6 = self.positionCircle, 3
            ____self_positionCircle_5[____3_6] = ____self_positionCircle_5[____3_6] + deltaY
        end
    end
end
function ravnDraw.navigationDebug(self, draw)
end
function ravnDraw.Texture(self, draw, textureId, height, width, tab, alpha)
    if height == nil then
        height = 20
    end
    if width == nil then
        width = 20
    end
    local x, y, z = unpack(tab)
    local config = {}
    config.texture = textureId
    config.scale = 1
    config.height = height
    config.width = width
    draw:Texture(
        config,
        x,
        y,
        z,
        alpha
    )
end
function ravnDraw.filledCircle(self, draw, pos, sizeCircle, colorCircle, sizeOutline, colorOutline)
    if sizeCircle == nil then
        sizeCircle = 2
    end
    local x, y, z = unpack(pos)
    local r, g, b, a = unpack(colorCircle)
    local rOut, gOut, bOut, aOut = unpack(colorOutline and colorOutline or colorCircle)
    draw:SetColorRaw(r, g, b, a)
    draw:FilledCircle(x, y, z, sizeCircle)
    sizeOutline = sizeOutline and sizeOutline or sizeCircle
    draw:SetColorRaw(rOut, gOut, bOut, aOut)
    draw:Outline(x, y, z, sizeOutline)
end
function ravnDraw.drawDebugPoints(self, draw)
    local c = 1
    local p = {awful.player.position()}
    __TS__ArrayForEach(
        Global.debugPoints,
        function(____, o)
            local x, y, z = unpack(o.center)
            local distance = Geometry:distanceBetweenPos(p, {x, y, z}, true)
            if distance <= 200 then
                local size = o.size
                local ____temp_7
                if o.isLosDebugPoint == true then
                    ____temp_7 = self:WoWColorToRGBA(Color.LIME, 1, true)
                else
                    ____temp_7 = self:WoWColorToRGBA(Color.MAGE, 1, true)
                end
                local color = ____temp_7
                if color then
                    local r, g, b, a = unpack(color)
                    self:filledCircle(
                        draw,
                        {x, y, z},
                        size,
                        {r, g, b, 0.3},
                        size,
                        {r, g, b, 0.7}
                    )
                end
            end
        end
    )
end
function ravnDraw.netherWindDrake(self, draw)
    local idsToMonitor = {185915}
    if C_QuestLog.IsOnQuest(11076) then
        idsToMonitor[#idsToMonitor + 1] = 185939
    end
    local objs = awful.objects.filter(function(o) return __TS__ArrayIncludes(idsToMonitor, o.id) end)
    if #objs > 0 then
        do
            local i = 0
            while i < #objs do
                local x, y, z = objs[i + 1].position()
                self:WoWColorToRGBA(Color.PINK)
                draw:FilledCircle(x, y, z, 2)
                local name = objs[i + 1].name
                draw:Text(
                    name,
                    "GameFontNormalLarge",
                    x,
                    y,
                    z
                )
                if objs[i + 1].id == 185915 then
                    Alert.sendAlert(true, 0, "Netherwing Drake", "Netherwing Drake found")
                    local px, py, pz = awful.player.position()
                    draw:Line(
                        px,
                        py,
                        pz,
                        x,
                        y,
                        z,
                        400
                    )
                end
                i = i + 1
            end
        end
    end
    if C_QuestLog.IsOnQuest(11055) and Unlocker.type == nil then
        local objs = Objects(5)
        local playerPos = {awful.player.position()}
        __TS__ArrayForEach(
            objs,
            function(____, obj)
                local id = ObjectID(obj)
                if id == 23311 then
                    local x, y, z = ObjectPosition(obj)
                    local name = ObjectName(obj)
                    self:WoWColorToRGBA(Color.PURPLE, 0.5)
                    draw:FilledCircle(x, y, z, 2)
                    draw:Line(
                        playerPos[1],
                        playerPos[2],
                        playerPos[3],
                        x,
                        y,
                        z,
                        400
                    )
                end
            end
        )
    end
end
function ravnDraw.debugLock(self, draw)
    if not awful.DevMode then
        return
    end
    if GetSpecialization() == 2 then
        local units = {}
        if ravn.config.demonoAoe then
            units = demonoLib:getEnemies()
        else
            if awful.target and awful.target.exists then
                units[#units + 1] = awful.target
            end
        end
        __TS__ArrayForEach(
            units,
            function(____, u)
                local x, y, z = u.position()
                local value = demonoLib:getDotsValue(u)
                if value then
                    math.floor(value)
                    value = value * 0.01
                    value = math.floor(value * 100)
                end
                local baseColor = Color.WARLOCK
                local r, g, b, a = unpack(self:WoWColorToRGBA(baseColor, 0.1, true))
                self:filledCircle(
                    draw,
                    {x, y, z},
                    1,
                    {r, g, b, a},
                    1,
                    {r, g, b, 0.6}
                )
            end
        )
    end
    if GetSpecialization() == 1 then
        local units = affLib.targets
        __TS__ArrayForEach(
            units,
            function(____, element)
                local u = element.unit
                local x, y, z = u.position()
                local value = affLib:getDotsValue(u, false)
                if value then
                    math.floor(value)
                    value = value * 0.01
                    value = math.floor(value * 100)
                end
                local hasThreeDots = affLib:getDotsValue(u, true) ~= nil
                local baseColor = hasThreeDots and Color.WARLOCK or Color.ORANGE
                local r, g, b, a = unpack(self:WoWColorToRGBA(baseColor, 0.2, true))
                self:filledCircle(
                    draw,
                    {x, y, z},
                    1,
                    {r, g, b, a},
                    1,
                    {r, g, b, 0.7}
                )
            end
        )
    end
end
function ravnDraw.lockVomit(self, draw)
    local buffRemains = awful.player.buffRemains(affLib.SOUL_SWAP_BUFF)
    if buffRemains <= 0 then
        return
    end
    if not affLib.ISoulSwap then
        return
    end
    if not affLib.ISoulSwap.to then
        return
    end
    local ____affLib_ISoulSwap_to_8 = affLib.ISoulSwap
    if ____affLib_ISoulSwap_to_8 ~= nil then
        ____affLib_ISoulSwap_to_8 = ____affLib_ISoulSwap_to_8.to
    end
    local u = ____affLib_ISoulSwap_to_8
    if not u or not u.exists or not u.visible then
        return
    end
    local texture = awful.textureEscape(SpellBook.SOUL_SWAP, 23, "0:2")
    local x, y, z = u.position()
    local color = awful.player.facing(u) and Color.LIME or Color.ORANGE
    color = u.distance <= soulSwap.range and color or Color.RED
    self:WoWColorToRGBA(color, 1)
    local sz = (color .. " ") .. texture
    draw:Text(
        sz,
        "GameFontNormalLarge",
        x,
        y,
        z + 2.5
    )
end
function ravnDraw.lock(self, draw)
    if awful.player.class2 ~= WowClass.WARLOCK then
        return
    end
    self:wlPort(draw)
    self:lockVomit(draw)
    local info = affLib.IShadowFlameInfo
    if info and shadowflame.cd <= awful.gcd * 2 then
        local t = awful.GetObjectWithGUID(info.unit.guid)
        if t and t.exists and t.visible and not t.immuneSlows and not t.immuneMagicEffects then
            local x, y, z = awful.player.position()
            local a, b, c = t.position()
            local angle = awful.AnglesBetween(
                x,
                y,
                z,
                a,
                b,
                c
            )
            local facing = awful.player.facing(t, 150) and Color.LIME or Color.RED
            self:cleanFilledArc(
                draw,
                {x, y, z},
                10,
                10,
                150,
                angle,
                self:WoWColorToRGBA(Color.WARLOCK, 0.3, true),
                self:WoWColorToRGBA(facing, nil, true)
            )
        end
    end
    local q = Queue.queues[Queue.WARLOCK_SCREAM]
    if q ~= nil then
        local x, y, z = awful.player.position()
        local color = self:WoWColorToRGBA(Color.INDIAN_RED, 0.7)
        draw:Circle(x, y, z, 9.5)
    end
end
function ravnDraw.wlPort(self, draw)
    if not lockLib.portInfo then
        return
    end
    if not awful.player.buff(demonicCircleSummon.id) then
        return false
    end
    local x, y, z = unpack(lockLib.portInfo.pos)
    local distance = awful.player.distanceToLiteralPos(lockLib.portInfo.pos)
    if distance > 40 then
        self:WoWColorToRGBA(Color.RED)
    elseif distance > 30 then
        self:WoWColorToRGBA(Color.ORANGE)
    else
        self:WoWColorToRGBA(Color.LIME)
    end
    draw:Cylinder(
        x,
        y,
        z,
        1,
        3.6
    )
end
function ravnDraw.pveESP(self)
end
function ravnDraw.espDebugUnit(self)
end
function ravnDraw.pveLogic(self)
    local encounter = awful.encounter
    if encounter and encounter.id == 1035 and awful.target.id == 45872 then
        local arc = 90
        local x, y, z = awful.target.position()
        self:WoWColorToRGBA(Color.ROGUE, 0.8)
        self.drawer:FilledArc(
            x,
            y,
            z,
            10,
            arc,
            awful.target.direction
        )
    end
    local function drawCircle(pos, radius, color, text, differentColor)
        if differentColor == nil then
            differentColor = false
        end
        local r, g, b, a = unpack(self:WoWColorToRGBA(color, nil, true))
        self:WoWColorToRGBA(color, 0.2)
        if differentColor then
            self:filledCircle(
                self.drawer,
                pos,
                radius,
                {r, g, b, 0.2},
                radius,
                {r, g, b, 0.5}
            )
        else
            self.drawer:FilledCircle(pos[1], pos[2], pos[3], radius)
        end
        if text then
            self.drawer:Text(
                text,
                "GameFontNormalSmall",
                pos[1],
                pos[2],
                pos[3] + 1
            )
        end
    end
    awful.pveMechanics.loop(function(o)
        local entry = pveLogic.unitCache[o.id]
        if entry and entry.radius and entry.unitType == UnitType.AOE and entry:valid(o) then
            if not entry.drawCallback then
                local distance = o.distance
                local goodPosition = false
                if entry.positive then
                    local text = distance > entry.radius and "Get Inside" or nil
                    drawCircle(
                        {o.position()},
                        entry.radius,
                        Color.LIME,
                        text
                    )
                else
                    if distance > entry.radius then
                        drawCircle(
                            {o.position()},
                            entry.radius,
                            Color.YELLOW
                        )
                    else
                        drawCircle(
                            {o.position()},
                            entry.radius,
                            Color.RED
                        )
                    end
                end
            else
                entry:drawCallback(self.drawer, o)
            end
        end
        if entry and entry:valid(o) and entry.drawCallback then
            entry:drawCallback(self.drawer, o)
        end
    end)
    if not Global.auditEngineStarted then
        return
    end
    local baseStruct = Global.auditEngine.Track
    if not baseStruct then
        return
    end
    local castId = {}
    if baseStruct.casts and #baseStruct.casts > 0 then
        castId = __TS__ArrayMap(
            baseStruct.casts,
            function(____, o) return o.id end
        )
    end
    local debuffs = {}
    if baseStruct.debuffs and #baseStruct.debuffs > 0 then
        debuffs = __TS__ArrayMap(
            baseStruct.debuffs,
            function(____, o) return o.id end
        )
    end
    local buffs = {}
    if baseStruct.buffs and #baseStruct.buffs > 0 then
        buffs = __TS__ArrayMap(
            baseStruct.buffs,
            function(____, o) return o.id end
        )
    end
    local objectIds = {}
    if baseStruct.objects and #baseStruct.objects > 0 then
        objectIds = __TS__ArrayMap(
            baseStruct.objects,
            function(____, o) return o.id end
        )
    end
    if baseStruct.units and #baseStruct.units > 0 then
        local idToMonitor = __TS__ArrayMap(
            baseStruct.units,
            function(____, o) return o.id end
        )
        awful.everyUnits.loop(function(o)
            if __TS__ArrayIncludes(idToMonitor, o.id) then
                local x, y, z = o.position()
                local friend = o.friend
                local color = friend and Color.LIME or Color.RED
                local rOut, gOut, bOut, aOut = unpack(self:WoWColorToRGBA(color, 1, true))
                local r, g, b, a = unpack(self:WoWColorToRGBA(Color.WHITE, 0.1, true))
                local name = o.name
                self:filledCircle(
                    self.drawer,
                    {x, y, z},
                    1,
                    {r, g, b, a},
                    1,
                    {rOut, gOut, bOut, aOut}
                )
                self:WoWColorToRGBA(Color.WHITE)
                self.drawer:Text(
                    name,
                    "GameFontNormalLarge",
                    x,
                    y,
                    z
                )
                local cid = o.castIdEx
                if cid and __TS__ArrayIncludes(castId, cid) then
                    local x, y, z = o.position()
                    local r, g, b, a = unpack(self:WoWColorToRGBA(Color.HOT_PINK, 0.3, true))
                    self:cleanFilledArc(
                        self.drawer,
                        {x, y, z},
                        5,
                        5,
                        100,
                        0,
                        {r, g, b, a},
                        {rOut, gOut, bOut, aOut}
                    )
                end
                if o.buffRemainsFromTable(buffs) > 0 then
                    local x, y, z = o.position()
                    local r, g, b, a = unpack(self:WoWColorToRGBA(Color.ORANGE_RED, 0.3, true))
                    self:filledCircle(
                        self.drawer,
                        {x, y, z},
                        2,
                        {r, g, b, a},
                        2,
                        {rOut, gOut, bOut, aOut}
                    )
                end
            end
        end)
    end
    if #debuffs > 0 then
        awful.fullGroup.loop(function(o)
            if o.debuffRemainsFromTable(debuffs) > 0 then
                local x, y, z = o.position()
                local r, g, b, a = unpack(self:WoWColorToRGBA(Color.MAGE, 0.3, true))
                self.drawer:Cylinder(
                    x,
                    y,
                    z,
                    1,
                    2.6
                )
            end
        end)
    end
    awful.objects.loop(function(o)
        if __TS__ArrayIncludes(objectIds, o.id) then
            local x, y, z = o.position()
            local r, g, b, a = unpack(self:WoWColorToRGBA(Color.WHITE, 0.2, true))
            local rOut, gOut, bOut, aOut = unpack(self:WoWColorToRGBA(Color.YELLOW, 1, true))
            self:filledCircle(
                self.drawer,
                {x, y, z},
                1,
                {r, g, b, a},
                1,
                {rOut, gOut, bOut, aOut}
            )
        end
    end)
end
function ravnDraw.stealthies(self, draw)
    if not ravn.modernConfig:getGraphicTrackStealthed() then
        return
    end
    __TS__ArrayForEach(
        Cache.stealthTracker,
        function(____, o)
            local unit = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return o.guid == o.guid end
            )
            local elapsed = GetTime() - o.time
            if elapsed <= 4 and (not unit or not unit.visible or unit and unit.stealth) and o.direction then
                local x, y, z = unpack(o.pos)
                local sX = x + o.speed * elapsed * math.cos(o.direction)
                local sY = y + o.speed * elapsed * math.sin(o.direction)
                local sZ = z + 0.3
                local Fade = {
                    1,
                    0.5,
                    0.25,
                    math.max(0.5, 1 - elapsed / 3)
                }
                local FadeOutline = {
                    1,
                    0.5,
                    0.25,
                    math.max(1, 1 - elapsed / 3)
                }
                local position = {sX, sY, sZ}
                self:filledCircle(
                    draw,
                    position,
                    2.5,
                    Fade,
                    2.5,
                    FadeOutline
                )
                draw:Text(
                    o.spellName,
                    "GameFontNormalSmall",
                    sX,
                    sY,
                    sZ
                )
            end
        end
    )
end
function ravnDraw.battleGrounds(self, draw)
    if select(
        2,
        IsInInstance()
    ) ~= "pvp" then
        return
    end
    local mapId = awful.mapID
    if mapId == 489 or mapId == 726 then
        local FLAG_HORDE = 301089
        local FLAG_ALLIANCE = 301091
        local function drawFlagCarry(o)
            local x, y, z = o.position()
            local isHorde = o.buff(FLAG_HORDE)
            local color = isHorde and Color.RED or Color.LIGHT_BLUE
            self:WoWColorToRGBA(color, 0.5)
            local a, b, c = awful.player.position()
            local texture = isHorde and GetSpellTexture(FLAG_HORDE) or GetSpellTexture(FLAG_ALLIANCE)
            self:Texture(
                draw,
                texture,
                20,
                20,
                {x, y, z},
                1
            )
            self.drawer:Line(
                a,
                b,
                c,
                x,
                y,
                z
            )
        end
        __TS__ArrayForEach(
            awful.enemies,
            function(____, o)
                if o.buff(FLAG_ALLIANCE) or o.buff(FLAG_HORDE) then
                    drawFlagCarry(o)
                end
            end
        )
    end
end
function ravnDraw.lineToHealer(self)
    if not ravn.modernConfig:getGraphicLineToHealer() then
        return
    end
    local draw = self.drawer
    local h = awful.healer
    if h ~= nil and h.exists then
        local x, y, z = awful.player.position()
        local a, b, c = h.position()
        if not h.los or h.distance > 40 then
            self:WoWColorToRGBA(Color.RED)
        elseif h.distance <= 30 then
            self:WoWColorToRGBA(Color.LIME)
        else
            self:WoWColorToRGBA(Color.ORANGE)
        end
        draw:Line(
            x,
            y,
            z,
            a,
            b,
            c
        )
    end
end
function ravnDraw.initDrawings(self)
    self:registerCallback(function()
        self:queues(self.drawer)
    end)
    self:registerCallback(function()
        self:lineToHealer()
    end)
    self:registerCallback(function()
        self:drawArcheology(self.drawer)
    end)
    if awful.DevMode then
        self:registerCallback(function()
            self:debug(self.drawer)
        end)
    end
    self:registerCallback(function()
        self:navigationDebug(self.drawer)
    end)
    self:registerCallback(function()
        self:drawDebugPoints(self.drawer)
    end)
    self:registerCallback(function()
        self:stealthies(self.drawer)
    end)
    self:registerCallback(function()
        self:battleGrounds(self.drawer)
    end)
    if awful.player.class2 == WowClass.WARLOCK then
        self:registerCallback(function()
            self:debugLock(self.drawer)
        end)
        self:registerCallback(function()
            self:lock(self.drawer)
        end)
    end
    if GetZoneText() == "Shadowmoon Valley" then
        self:registerCallback(function()
            self:netherWindDrake(self.drawer)
        end)
    end
    if awful.DevMode and GetSpecialization() ~= 1 then
        self:registerCallback(function()
            self:pveLogic()
        end)
    end
end
function ravnDraw.loop(self, draw)
    if not self.drawer then
        self.drawer = draw
    end
    if ravn.modernConfig:getGraphicsDisableDrawings() then
        return
    end
    __TS__ArrayForEach(
        self.callbacks,
        function(____, callback)
            callback(draw)
        end
    )
end
ravnDraw.callbacks = {}
ravnDraw.lastCalc = 0
ravnDraw.positionCircle = {-3836, -11344, -126}
ravnDraw.posXLine = {0, 0}
ravnDraw.posYLine = {0, 0}
ravnDraw.posZLine = {0, 0}
ravnDraw.originCursorPos = {0, 0}
ravnDraw.lockCurrentSelection = nil
awful.Populate(
    {
        ["Drawings.drawings"] = ____exports,
    },
    ravn,
    getfenv(1)
)
