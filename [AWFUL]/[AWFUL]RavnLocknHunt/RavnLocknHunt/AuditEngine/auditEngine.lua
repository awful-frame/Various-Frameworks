local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
____exports.AuditEngine = __TS__Class()
local AuditEngine = ____exports.AuditEngine
AuditEngine.name = "AuditEngine"
function AuditEngine.prototype.____constructor(self)
    self.recording = false
    self.distance = 50
    self.lastTick = 0
    self.previousEncounterID = 0
    self.Folder = "Ravn-Classic"
    self.cache = {}
    self.Config = {
        units = {},
        casts = {},
        debuffs = {},
        objects = {},
        dynamicObjects = {},
        buffs = {}
    }
    self.Track = {
        units = {},
        casts = {},
        debuffs = {},
        objects = {},
        dynamicObjects = {},
        buffs = {}
    }
    awful.addUpdateCallback(function()
        self:onTick()
    end)
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == "SPELL_CAST_SUCCESS" then
            if not source.isPlayer then
                self:onSpellDetected(source, dest, spellId, spellName)
            end
        end
        if event == "SPELL_AURA_APPLIED" then
            if auraType == "DEBUFF" then
                if dest.isPlayer then
                    self:onDebuffDetected(source, dest, spellId, spellName)
                end
            end
            if auraType == "BUFF" then
                if not source.isPlayer and not source.friend then
                    self:onDebuffDetected(source, dest, spellId, spellName)
                end
            end
        end
    end)
end
function AuditEngine.prototype.resetRecord(self)
    print("Record resetted")
    self.Config = {
        units = {},
        casts = {},
        debuffs = {},
        objects = {},
        dynamicObjects = {},
        buffs = {}
    }
end
function AuditEngine.prototype.onTrackUnit(self, o)
    local findEntry = __TS__ArrayFind(
        self.Track.units,
        function(____, u) return u.id == o.id end
    )
    if not findEntry then
        local ____self_Track_units_0 = self.Track.units
        ____self_Track_units_0[#____self_Track_units_0 + 1] = o
        return "added"
    else
        self.Track.units = __TS__ArrayFilter(
            self.Track.units,
            function(____, u) return u.id ~= o.id end
        )
        return "removed"
    end
end
function AuditEngine.prototype.onTrackBuff(self, o)
    local findEntry = __TS__ArrayFind(
        self.Track.buffs,
        function(____, u) return u.id == o.id end
    )
    if not findEntry then
        local ____self_Track_buffs_1 = self.Track.buffs
        ____self_Track_buffs_1[#____self_Track_buffs_1 + 1] = o
        return "added"
    else
        self.Track.buffs = __TS__ArrayFilter(
            self.Track.buffs,
            function(____, u) return u.id ~= o.id end
        )
        return "removed"
    end
end
function AuditEngine.prototype.onTrackDebuff(self, o)
    local findEntry = __TS__ArrayFind(
        self.Track.debuffs,
        function(____, u) return u.id == o.id end
    )
    if not findEntry then
        local ____self_Track_debuffs_2 = self.Track.debuffs
        ____self_Track_debuffs_2[#____self_Track_debuffs_2 + 1] = o
        return "added"
    else
        self.Track.debuffs = __TS__ArrayFilter(
            self.Track.debuffs,
            function(____, u) return u.id ~= o.id end
        )
        return "removed"
    end
end
function AuditEngine.prototype.onTrackDynamic(self, o)
    local findEntry = __TS__ArrayFind(
        self.Track.dynamicObjects,
        function(____, u) return u.id == o.id end
    )
    if not findEntry then
        local ____self_Track_dynamicObjects_3 = self.Track.dynamicObjects
        ____self_Track_dynamicObjects_3[#____self_Track_dynamicObjects_3 + 1] = o
        return "added"
    else
        self.Track.dynamicObjects = __TS__ArrayFilter(
            self.Track.dynamicObjects,
            function(____, u) return u.id ~= o.id end
        )
        return "removed"
    end
end
function AuditEngine.prototype.onTrackObject(self, o)
    local findEntry = __TS__ArrayFind(
        self.Track.objects,
        function(____, u) return u.id == o.id end
    )
    if not findEntry then
        local ____self_Track_objects_4 = self.Track.objects
        ____self_Track_objects_4[#____self_Track_objects_4 + 1] = o
        return "added"
    else
        self.Track.objects = __TS__ArrayFilter(
            self.Track.objects,
            function(____, u) return u.id ~= o.id end
        )
        return "removed"
    end
end
function AuditEngine.prototype.onTrackCast(self, o)
    local findEntry = __TS__ArrayFind(
        self.Track.casts,
        function(____, u) return u.id == o.id end
    )
    if not findEntry then
        local ____self_Track_casts_5 = self.Track.casts
        ____self_Track_casts_5[#____self_Track_casts_5 + 1] = o
        return "added"
    else
        self.Track.casts = __TS__ArrayFilter(
            self.Track.casts,
            function(____, u) return u.id ~= o.id end
        )
        return "removed"
    end
end
function AuditEngine.prototype.toggleRecord(self)
    self.recording = not self.recording
    if not self.recording then
        self:SaveRecord()
    end
end
function AuditEngine.prototype.onSpellDetected(self, source, dest, spellId, spellName)
    if not self.recording then
        return
    end
    local cacheName = "Spell_" .. tostring(spellId)
    local cache = self.cache[cacheName]
    local encounterID = awful.encounter and awful.encounter.id or -999
    if not encounterID then
        encounterID = -999
    end
    if type(encounterID) ~= "number" then
        encounterID = -999
    end
    if cache == nil then
        self.cache[cacheName] = true
        local ____self_Config_casts_6 = self.Config.casts
        ____self_Config_casts_6[#____self_Config_casts_6 + 1] = {
            id = spellId,
            sourceName = source.name,
            spellName = spellName,
            hasTarget = dest ~= nil,
            castTime = source.totalCastTime,
            encounterId = encounterID
        }
        local sz = (((((((("[" .. Color.YELLOW) .. "Spell Detected") .. Color.WHITE) .. "] ") .. spellName) .. " by ") .. source.name) .. " with id ") .. tostring(spellId)
        print(sz)
    end
end
function AuditEngine.prototype.onDebuffDetected(self, source, dest, spellId, spellName)
    if not self.recording then
        return
    end
    local cacheName = "Debuff_" .. tostring(spellId)
    local cache = self.cache[cacheName]
    local debuffRemains = dest.debuffRemains(spellId)
    if cache == nil then
        self.cache[cacheName] = true
        local encounterID = awful.encounter and awful.encounter.id or -999
        if not encounterID then
            encounterID = -999
        end
        if type(encounterID) ~= "number" then
            encounterID = -999
        end
        local sourceName = source ~= nil and source.name or "Unknown"
        local ____self_Config_debuffs_7 = self.Config.debuffs
        ____self_Config_debuffs_7[#____self_Config_debuffs_7 + 1] = {
            id = spellId,
            debuffName = spellName,
            sourceName = sourceName,
            destName = dest.name,
            duration = debuffRemains,
            encounterId = encounterID
        }
        local sz = ((((((((((((("[" .. Color.ORANGE) .. "Debuff Detected") .. Color.WHITE) .. "] ") .. spellName) .. " on ") .. dest.name) .. " with id ") .. tostring(spellId)) .. " from ") .. sourceName) .. " for ") .. tostring(debuffRemains)) .. " seconds"
        print(sz)
    end
end
function AuditEngine.prototype.onBuffDetected(self, source, dest, spellId, spellName)
    if not self.recording then
        return
    end
    local cacheName = "Debuff_" .. tostring(spellId)
    local cache = self.cache[cacheName]
    local debuffRemains = dest.debuffRemains(spellId)
    if cache == nil then
        self.cache[cacheName] = true
        local encounterID = awful.encounter and awful.encounter.id or -999
        if not encounterID then
            encounterID = -999
        end
        if type(encounterID) ~= "number" then
            encounterID = -999
        end
        local sourceName = source ~= nil and source.name or "Unknown"
        local ____self_Config_buffs_8 = self.Config.buffs
        ____self_Config_buffs_8[#____self_Config_buffs_8 + 1] = {
            id = spellId,
            buffName = spellName,
            sourceName = sourceName,
            destName = dest.name,
            duration = debuffRemains,
            encounterId = encounterID
        }
        local sz = ((((((((((((("[" .. Color.HOT_PINK) .. "BUFF Detected") .. Color.WHITE) .. "] ") .. spellName) .. " on ") .. dest.name) .. " with id ") .. tostring(spellId)) .. " from ") .. sourceName) .. " for ") .. tostring(debuffRemains)) .. " seconds"
        print(sz)
    end
end
function AuditEngine.prototype.onObject(self, o)
    local cacheName = "Object_" .. tostring(o.id)
    local cache = self.cache[cacheName]
    local encounterID = awful.encounter and awful.encounter.id or -999
    if not encounterID then
        encounterID = -999
    end
    if type(encounterID) ~= "number" then
        encounterID = -999
    end
    if cache == nil then
        self.cache[cacheName] = true
        local ____self_Config_objects_9 = self.Config.objects
        ____self_Config_objects_9[#____self_Config_objects_9 + 1] = {id = o.id, name = o.name, encounterId = encounterID}
        local sz = (((((("[" .. Color.MAGE) .. "Object Detected") .. Color.WHITE) .. "] ") .. o.name) .. " with id ") .. tostring(o.id)
        print(sz)
    end
end
function AuditEngine.prototype.onDynamicObject(self, o)
    local cacheName = "DynamicObject_" .. tostring(o.id)
    local cache = self.cache[cacheName]
    local encounterID = awful.encounter and awful.encounter.id or -999
    if not encounterID then
        encounterID = -999
    end
    if type(encounterID) ~= "number" then
        encounterID = -999
    end
    if cache == nil then
        self.cache[cacheName] = true
        local ____self_Config_dynamicObjects_10 = self.Config.dynamicObjects
        ____self_Config_dynamicObjects_10[#____self_Config_dynamicObjects_10 + 1] = {id = o.id, encounterId = encounterID}
        local sz = (((("[" .. Color.MAGE) .. "Dynamic Object Detected") .. Color.WHITE) .. "] with id ") .. tostring(o.id)
        print(sz)
    end
    __TS__ArrayForEach(
        awful.dynamicObjects,
        function(____, o)
            self:onDynamicObject(o)
        end
    )
end
function AuditEngine.prototype.onUnit(self, u)
    local cacheName = "Unit_" .. tostring(u.id)
    local cache = self.cache[cacheName]
    if cache == nil then
        self.cache[cacheName] = true
        local encounterID = awful.encounter and awful.encounter.id or -999
        if not encounterID then
            encounterID = -999
        end
        if type(encounterID) ~= "number" then
            encounterID = -999
        end
        local ____self_Config_units_11 = self.Config.units
        ____self_Config_units_11[#____self_Config_units_11 + 1] = {id = u.id, name = u.name, friendly = u.friend, encounterId = encounterID}
        local color = u.friend and Color.LIME or Color.RED
        local sz = (((((("[" .. color) .. "Unit Detected") .. Color.WHITE) .. "] ") .. u.name) .. " with id ") .. tostring(u.id)
        print(sz)
    end
end
function AuditEngine.prototype.onTick(self)
    if not self.recording then
        return
    end
    if not awful.player.combat then
        return
    end
    if awful.time - self.lastTick < 1 then
        return
    end
    self.lastTick = awful.time
    local encounterID = awful.encounter and awful.encounter.id or -999
    if not encounterID then
        encounterID = -999
    end
    if type(encounterID) ~= "number" then
        encounterID = -999
    end
    if self.previousEncounterID ~= encounterID then
        self:SaveRecord()
        print("New Encounter Detected", Color.MONK, encounterID)
        awful.alert("New Encounter Detected")
        self.previousEncounterID = encounterID
    end
    awful.everyUnits.loop(function(u)
        if not u.isPlayer and u.distance <= self.distance then
            self:onUnit(u)
        end
    end)
    __TS__ArrayForEach(
        awful.objects,
        function(____, o)
            if o.distance < self.distance then
                self:onObject(o)
            end
        end
    )
end
function AuditEngine.prototype.SaveRecord(self)
    local folderLocation = (self:GetExeDirectory() .. self:Separator()) .. self.Folder
    if not self:DirectoryExists(folderLocation) then
        self:CreateDirectory(folderLocation)
    end
    local encounterID = awful.encounter and awful.encounter.id or -999
    if type(encounterID) ~= "number" then
        encounterID = -999
    end
    local theDate = C_DateAndTime.GetCurrentCalendarTime()
    local name = awful.encounter and awful.encounter.name or ""
    if not name then
        name = ""
    end
    local fileName = ((((((((((((("[" .. tostring(theDate.year)) .. "-") .. tostring(theDate.month)) .. "-") .. tostring(theDate.monthDay)) .. "][") .. tostring(theDate.hour)) .. "-") .. tostring(theDate.minute)) .. "]__") .. name) .. "__") .. tostring(encounterID)) .. ".json"
    local szConfig = ravnJSON.stringify(nil, self.Config)
    local filePath = (folderLocation .. self:Separator()) .. fileName
    self:OpenAndWriteFile(filePath, szConfig, false)
    print("Record Saved", Color.MONK, fileName)
    C_Timer.After(
        2,
        function()
            self:resetRecord()
        end
    )
end
function AuditEngine.prototype.DirectoryExists(self, path)
    return DirectoryExists(path)
end
function AuditEngine.prototype.CreateDirectory(self, path)
    return CreateDirectory(path)
end
function AuditEngine.prototype.FileExists(self, path)
    return FileExists(path)
end
function AuditEngine.prototype.GetExeDirectory(self)
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
function AuditEngine.prototype.Separator(self)
    if Unlocker.type == "tinkr" then
        return "/"
    else
        return "//"
    end
end
function AuditEngine.prototype.OpenAndReadFile(self, path)
    return ReadFile(path)
end
function AuditEngine.prototype.OpenAndWriteFile(self, path, content, append)
    WriteFile(path, content, append)
end
awful.Populate(
    {
        ["AuditEngine.auditEngine"] = ____exports,
    },
    ravn,
    getfenv(1)
)
