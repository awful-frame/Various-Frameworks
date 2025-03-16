local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ravnPrint = ____ravnPrint.ravnPrint
local ____arena = ravn["arena.arena"]
local arena = ____arena.arena
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
____exports.Script = __TS__Class()
local Script = ____exports.Script
Script.name = "Script"
function Script.prototype.____constructor(self)
end
function Script.toggleValue(self, valueToChange, sz)
    if sz == nil then
        sz = ""
    end
    valueToChange = not valueToChange
    if valueToChange then
        local v = sz .. " Enabled"
        Alert.sendAlert(
            false,
            0,
            v,
            nil,
            nil,
            1,
            Color.LIME
        )
    else
        local v = sz .. " Disabled"
        Alert.sendAlert(
            false,
            0,
            v,
            nil,
            nil,
            1,
            Color.RED
        )
    end
end
function Script.toggleRotation(self)
    if awful.enabled == nil then
        awful.enabled = true
    else
        awful.enabled = not awful.enabled
    end
    if awful.enabled then
        Global.ModernMenu.mm.texture:SetVertexColor(0.6, 1, 0.4, 1)
        Alert.sendAlert(
            false,
            0,
            "Enabled",
            nil,
            nil,
            1,
            Color.LIME
        )
    else
        Global.ModernMenu.mm.texture:SetVertexColor(1, 0.313, 0.313, 1)
        Alert.sendAlert(
            false,
            0,
            "Disabled",
            nil,
            nil,
            1,
            Color.RED
        )
    end
end
function Script.toggleMenu(self)
    if Global.ModernMenu.baseMenu.frame:IsVisible() then
        Global.ModernMenu.baseMenu.frame:Hide()
    else
        Global.ModernMenu.baseMenu.frame:Show()
    end
end
function Script.determineTarget(self, sz)
    sz = string.lower(sz)
    if sz == "player" then
        if awful.player and awful.player.exists then
            return awful.player
        else
            ravnPrint("[player] not detected", Color.RED)
        end
    end
    if sz == "ehealer" then
        if awful.enemyHealer and awful.enemyHealer.exists then
            return awful.enemyHealer
        else
            ravnPrint("[ehealer] not detected", Color.RED)
        end
    end
    if sz == "fhealer" then
        if awful.healer and awful.healer.exists then
            return awful.healer
        else
            ravnPrint("[fhealer] not detected", Color.RED)
        end
    end
    if sz == "focus" then
        if awful.focus and awful.focus.exists then
            return awful.focus
        else
            ravnPrint("[focus] not detected", Color.RED)
        end
    end
    if sz == "target" then
        if awful.target and awful.target.exists then
            return awful.target
        else
            ravnPrint("[target] not detected", Color.RED)
        end
    end
    if sz == "fdps" then
        local u = arena:getFriendDPS()
        if u and u.exists then
            return u
        else
            ravnPrint("[fdps] not detected", Color.RED)
        end
    end
    if sz == "eofftarget" then
        local t = arena:getOffTarget()
        if t and t.exists then
            return t
        else
            ravnPrint("[eofftarget] not detected", Color.RED)
        end
    end
    if sz == "arena1" then
        local u = awful.arena1
        if u and u.exists then
            return u
        else
            ravnPrint(("[" .. sz) .. "] not detected", Color.RED)
        end
    end
    if sz == "arena2" then
        local u = awful.arena2
        if u and u.exists then
            return u
        else
            ravnPrint(("[" .. sz) .. "] not detected", Color.RED)
        end
    end
    if sz == "arena3" then
        local u = awful.arena3
        if u and u.exists then
            return u
        else
            ravnPrint(("[" .. sz) .. "] not detected", Color.RED)
        end
    end
    if sz == "arena4" then
        local u = awful.arena4
        if u and u.exists then
            return u
        else
            ravnPrint(("[" .. sz) .. "] not detected", Color.RED)
        end
    end
    if sz == "arena5" then
        local u = awful.arena5
        if u and u.exists then
            return u
        else
            ravnPrint(("[" .. sz) .. "] not detected", Color.RED)
        end
    end
    if Global:stringIsWowUnit(sz) then
        local u = __TS__ArrayFind(
            awful.units,
            function(____, o) return o.guid == awful.call("UnitGUID", sz) end
        )
        if u and u.exists then
            return u
        else
            ravnPrint(("[" .. sz) .. "] not detected", Color.RED)
        end
    end
    ravnPrint(("[Object Invalid] Cannot create unit from value entered ( " .. sz) .. " )", Color.RED)
    return
end
function Script.debug(self)
    if Global.debugFunction > 0 then
        Global.debugFunction = 0
    else
        Global.debugFunction = awful.time
    end
    print("Global Dbg", Global.debugFunction)
    ravn.pressureRLSDebug = true
    C_Timer.After(
        5,
        function()
            ravn.pressureRLSDebug = false
            print("end fake debug")
        end
    )
end
function Script.addDebugPoint(self, sz)
    local function addDebugPoint(center, size, losdbg)
        local ____Global_debugPoints_0 = Global.debugPoints
        ____Global_debugPoints_0[#____Global_debugPoints_0 + 1] = {center = center, size = size, isLosDebugPoint = losdbg}
    end
    local pos = Global:getCursorWorldPos()
    if sz == "player" then
        pos = {awful.player.position()}
    end
    if not pos then
        print("No Cursor Pos")
        return
    end
    local a, b, c = unpack(pos)
    ravnInfo("Adding Debug Point: ")
    ravnInfo("X: " .. tostring(a))
    ravnInfo("Y: " .. tostring(b))
    ravnInfo("Z: " .. tostring(c))
    addDebugPoint(pos, Global.circleSize, false)
end
function Script.saveDebugPoints(self)
    local function parentMapID()
        local id = C_Map.GetBestMapForUnit("player")
        if not id then
            return
        end
        local infos = C_Map.GetMapInfo(id)
        if not infos then
            return
        end
        return infos.parentMapID
    end
    local mapid = parentMapID() or 0
    local name = GetZoneText()
    name = string.upper(name)
    name = __TS__StringReplace(name, "'", "_")
    name = __TS__StringReplace(name, " ", "_")
    local hour, min = GetGameTime()
    local time = (tostring(hour) .. "-") .. tostring(min)
    local fullName = (name .. "-AT-") .. time
    local path = ("scripts/" .. fullName) .. ".ts"
    local c = 1
    local sz = ""
    sz = sz .. "     this.PolygonsBlacklisted.push({\n"
    sz = sz .. "            polygonePoints: [\n"
    __TS__ArrayForEach(
        Global.debugPoints,
        function(____, element)
            sz = sz .. ((((("                [" .. tostring(element.center[1])) .. ", ") .. tostring(element.center[2])) .. ", ") .. tostring(element.center[3])) .. "] as AwfulPosition,\n"
        end
    )
    sz = sz .. "            ],\n"
    sz = sz .. ("            parentMapID: " .. tostring(mapid)) .. ",\n"
    sz = sz .. "        });\n"
    WriteFile(path, sz, true)
    c = c + 1
end
awful.Populate(
    {
        ["Interface.SlashCommand.script"] = ____exports,
    },
    ravn,
    getfenv(1)
)
