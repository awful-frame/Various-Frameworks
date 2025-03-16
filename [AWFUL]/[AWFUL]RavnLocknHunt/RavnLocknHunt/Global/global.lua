local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____auditEngine = ravn["AuditEngine.auditEngine"]
local AuditEngine = ____auditEngine.AuditEngine
____exports.Global = __TS__Class()
local Global = ____exports.Global
Global.name = "Global"
function Global.prototype.____constructor(self)
end
function Global.startAuditEngine(self)
    if not ____exports.Global.auditEngineStarted then
        ____exports.Global.auditEngine = __TS__New(AuditEngine)
        ____exports.Global.auditEngineStarted = true
    end
end
function Global.dumpTable(self, u)
    if type(u) ~= "table" then
        return
    end
    local s = "{ "
    for k in pairs(u) do
        local v = u[k]
        if type(v) == "table" then
            s = s .. ((k .. " : ") .. tostring(____exports.Global:dumpTable(v))) .. ", "
        else
            s = s .. ((k .. " : ") .. tostring(v)) .. ", "
        end
    end
    s = s .. " }"
end
function Global.simpleDumpTable(self, u)
    if type(u) ~= "table" then
        return
    end
    local s = "{ "
    for k in pairs(u) do
        local v = u[k]
        if type(v) == "table" then
            s = s .. ((k .. " : ") .. "table") .. ", "
        else
            s = s .. ((k .. " : ") .. tostring(v)) .. ", "
        end
    end
    s = s .. " }"
end
function Global.DirectoryExists(self, path)
    return DirectoryExists(path)
end
function Global.CreateDirectory(self, path)
    return CreateDirectory(path)
end
function Global.FileExists(self, path)
    return FileExists(path)
end
function Global.GetExeDirectory(self)
    if Unlocker.type == "tinkr" then
        return "scripts"
    end
    if Unlocker.type == "noname" then
        return "//scripts"
    end
    if Unlocker.type == "daemonic" then
        return GetExeDirectory()
    end
    return "scripts"
end
function Global.Separator(self)
    if Unlocker.type ~= nil then
        return "//"
    else
        return "/"
    end
end
function Global.OpenAndReadFile(self, path)
    return ReadFile(path)
end
function Global.customCmd(self)
    local file = "custom.txt"
    local path = (self:GetExeDirectory() .. self:Separator()) .. file
    if not self:FileExists(path) then
        return nil
    end
    local content = self:OpenAndReadFile(path)
    local first = __TS__StringSplit(content, " ")[1]
    return first
end
function Global.getCursorWorldPos(self, customFlag)
    if customFlag == nil then
        customFlag = 256
    end
    if not awful.DevMode or Unlocker.type then
        return
    end
    local maxX = WorldFrame:GetRight()
    local maxY = WorldFrame:GetTop()
    local mx, my = GetCursorPosition()
    mx = 2 * (mx / maxX) - 1
    my = 2 * (my / maxY) - 1
    local wx, wy, wz = ScreenToWorld(mx, my, customFlag)
    return {wx, wy, wz}
end
function Global.stringIsWowUnit(self, sz)
    local uid = {
        "raid1",
        "raid2",
        "raid3",
        "raid4",
        "raid5",
        "party1",
        "party2",
        "party3",
        "party4",
        "playerpet",
        "partypet1",
        "partypet2",
        "partypet3",
        "partypet4",
        "player",
        "pet",
        "focus",
        "mouseover",
        "vehicle",
        "target",
        "targettarget",
        "mouseoverpet",
        "targetpet",
        "arena1pet",
        "arena2pet",
        "arena3pet",
        "arena1",
        "arena2",
        "arena3",
        "arena4",
        "arena5"
    }
    return __TS__ArrayFind(
        uid,
        function(____, x) return x == sz end
    )
end
function Global.StopMovingAndLock(self)
    awful.call("MoveForwardStop")
    awful.call("MoveBackwardStop")
    awful.call("StrafeLeftStop")
    awful.call("StrafeRightStop")
    awful.call("TurnLeftStop")
    awful.call("TurnRightStop")
    awful.call("AscendStop")
    awful.call("CameraOrSelectOrMoveStop")
    local x, y, z = awful.player.position()
    MoveTo(x, y, z)
end
function Global.GetLanguageFont(self)
    local locale = GetLocale()
    if locale == "ruRU" then
        return "Fonts\\FRIZQT___CYR.TTF"
    end
    if locale == "zhCN" or locale == "zhTW" then
        return "Fonts\\ARKai_T.ttf"
    end
    if locale == "krKR" then
        return "Fonts\\2002B.TTF"
    end
    return "Fonts\\FRIZQT__.TTF"
end
Global.smallAlertsArray = {}
Global.bigAlertsArray = {}
Global.burstMode = 0
Global.queueTime = 0
Global.queueNumber = 0
Global.pauseTimer = 0
Global.count = 0
Global.baseCmd = "ravn"
Global.debugPoints = {}
Global.circleSize = 1
Global.scanTooltip = CreateFrame("GameTooltip", "RCTooltip", UIParent, "GameTooltipTemplate")
Global.auditEngineStarted = false
Global.debugFunction = 0
awful.Populate(
    {
        ["Global.global"] = ____exports,
    },
    ravn,
    getfenv(1)
)
