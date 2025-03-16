local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local ____exports = {}
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ravnPrint = ____ravnPrint.ravnPrint
--- LONG TERM ROADMAP
-- 
-- AUDIT EVERY SINGLE CAST LET THROUGH WITH KICK UP TO KNOW WHICH KICKS ARE BEING KICKED AND WHICH ONE ARE NOT
____exports.Faking = __TS__Class()
local Faking = ____exports.Faking
Faking.name = "Faking"
function Faking.prototype.____constructor(self)
    self.Folder = "Ravn-Classic"
    self.fileName = "Kickers.json"
    self.fakeData = {}
    local folderLocation = (self:GetExeDirectory() .. self:Separator()) .. self.Folder
    if not self:DirectoryExists(folderLocation) then
        self:CreateDirectory(folderLocation)
    end
    local configFile = (((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. self.fileName
    if not self:FileExists(configFile) then
        local first = {kicks = {}}
        local sz = "[]"
        self:OpenAndWriteFile(configFile, sz, false)
        ravnPrint(Color.YELLOW .. "New auto fake config file created")
        self.fakeData = {}
    else
        ravnPrint(Color.YELLOW .. "Auto fake config file Loaded")
        local buffer = self:OpenAndReadFile(configFile)
        local data = ravnJSON.parse(nil, buffer)
        self.fakeData = data
        if not self.fakeData then
            self.fakeData = {}
        end
    end
end
function Faking.prototype.DirectoryExists(self, path)
    return DirectoryExists(path)
end
function Faking.prototype.OpenAndReadFile(self, path)
    return ReadFile(path)
end
function Faking.prototype.OpenAndWriteFile(self, path, content, append)
    WriteFile(path, content, append)
end
function Faking.prototype.CreateDirectory(self, path)
    return CreateDirectory(path)
end
function Faking.prototype.FileExists(self, path)
    return FileExists(path)
end
function Faking.prototype.Separator(self)
    if Unlocker.type == "tinkr" then
        return "/"
    else
        return "//"
    end
end
function Faking.prototype.GetExeDirectory(self)
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
function Faking.prototype.unitInfo(self, o)
    local guid = o.guid
    local values = {
        "target",
        "focus",
        "party1",
        "party2",
        "arena1",
        "arena2",
        "arena3"
    }
    local valid = __TS__ArrayFind(
        values,
        function(____, e) return awful.call("UnitGUID", e) == guid end
    )
    if not valid then
        return nil, nil
    end
    local name, srv = UnitName(valid)
    if not name then
        return nil, nil
    end
    if not srv then
        srv = GetRealmName()
    end
    return name, srv
end
function Faking.prototype.unitKickPercent(self, o)
    local name, srv = self:unitInfo(o)
    if not name or not srv then
        return {nil, nil}
    end
    local cache = (name .. "-") .. srv
    local entry = __TS__ArrayFind(
        self.fakeData,
        function(____, e) return e.unitName == cache end
    )
    if not entry then
        return {nil, nil}
    end
    local castPct = nil
    local channelTime = nil
    if entry.castAmountData > 0 then
        castPct = entry.castPercent
    end
    if entry.channelAmountData > 0 then
        channelTime = entry.channelTime
    end
    return {castPct, channelTime}
end
function Faking.prototype.onPlayerEnteringWorld(self)
    local szConfig = ravnJSON.stringify(nil, self.fakeData)
    local configFile = (((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. self.fileName
    if self:FileExists(configFile) then
        self:OpenAndWriteFile(configFile, szConfig, false)
        ravnInfo(Color.YELLOW .. "Auto fake config file updated")
    else
        ravnInfo("Faking file not found")
    end
end
function Faking.prototype.addCastKickInfo(self, o, _castPercent)
    local name, srv = self:unitInfo(o)
    ravnInfo("CastKickInfo: ", name, srv, _castPercent)
    if not name or not srv then
        return nil
    end
    local cache = (name .. "-") .. srv
    local entry = __TS__ArrayFind(
        self.fakeData,
        function(____, e) return e.unitName == cache end
    )
    if entry == nil then
        local ____self_fakeData_0 = self.fakeData
        ____self_fakeData_0[#____self_fakeData_0 + 1] = {
            unitName = cache,
            castPercent = _castPercent,
            castAmountData = 1,
            channelTime = 0,
            channelAmountData = 0
        }
    else
        local count = entry.castAmountData
        local newCount = count + 1
        local pct = entry.castPercent
        local total = (pct * count + _castPercent) / newCount
        local buffer = __TS__ArrayFilter(
            self.fakeData,
            function(____, e) return e.unitName ~= cache end
        )
        buffer[#buffer + 1] = {
            unitName = cache,
            castPercent = total,
            castAmountData = newCount,
            channelTime = entry.channelTime,
            channelAmountData = entry.channelAmountData
        }
        self.fakeData = buffer
    end
end
function Faking.prototype.addChannelKickInfo(self, o, _channelTime)
    local name, srv = self:unitInfo(o)
    ravnInfo("ChannelKickInfo: ", name, srv, _channelTime)
    if not name or not srv then
        return nil
    end
    local cache = (name .. "-") .. srv
    local entry = __TS__ArrayFind(
        self.fakeData,
        function(____, e) return e.unitName == cache end
    )
    if entry == nil then
        local ____self_fakeData_1 = self.fakeData
        ____self_fakeData_1[#____self_fakeData_1 + 1] = {
            unitName = cache,
            castPercent = 0,
            castAmountData = 0,
            channelTime = _channelTime,
            channelAmountData = 1
        }
    else
        local count = entry.channelAmountData
        local newCount = count + 1
        local channelTime = entry.channelTime
        local total = (channelTime * count + _channelTime) / newCount
        local buffer = __TS__ArrayFilter(
            self.fakeData,
            function(____, e) return e.unitName ~= cache end
        )
        buffer[#buffer + 1] = {
            unitName = cache,
            castPercent = entry.castPercent,
            castAmountData = entry.castAmountData,
            channelTime = total,
            channelAmountData = newCount
        }
        self.fakeData = buffer
    end
end
awful.Populate(
    {
        ["Interrupts.faking"] = ____exports,
    },
    ravn,
    getfenv(1)
)
