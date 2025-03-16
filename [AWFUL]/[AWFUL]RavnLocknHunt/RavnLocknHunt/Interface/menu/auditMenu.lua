local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____auditEngine = ravn["AuditEngine.auditEngine"]
local AuditEngine = ____auditEngine.AuditEngine
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
____exports.auditMenu = __TS__Class()
local auditMenu = ____exports.auditMenu
auditMenu.name = "auditMenu"
function auditMenu.prototype.____constructor(self)
    self._stdUi = RavnStub("StdUi"):NewInstance()
    self._width = 900
    self._height = 560
    self.tabs = {}
    self.PLUS_ICON = 62251
    self.MINUS_ICON = 62252
    self.encounterId = 0
    self.Folder = "Ravn-Classic"
    local rCfg = {
        font = {
            family = Global:GetLanguageFont(),
            size = 12,
            titleSize = 16,
            effect = "NONE",
            strata = "OVERLAY",
            color = {normal = {r = 1, g = 1, b = 1, a = 1}, disabled = {r = 0.55, g = 0.55, b = 0.55, a = 1}, header = {r = 1, g = 0.9, b = 0, a = 1}}
        },
        backdrop = {
            texture = "Interface/Buttons/WHITE8X8",
            panel = {r = 0.15, g = 0.15, b = 0.15, a = 0.8},
            slider = {r = 0.15, g = 0.15, b = 0.15, a = 1},
            highlight = {r = 0.4, g = 0.4, b = 0, a = 0.5},
            button = {r = 0.2, g = 0.2, b = 0.2, a = 1},
            buttonDisabled = {r = 0.15, g = 0.15, b = 0.15, a = 1},
            border = {r = 0, g = 0, b = 0, a = 1},
            borderDisabled = {r = 0.4, g = 0.4, b = 0.4, a = 1}
        },
        progressBar = {color = {r = 1, g = 0.9, b = 0, a = 0.5}},
        highlight = {color = {r = 1, g = 0.9, b = 0, a = 0.4}, blank = {r = 0, g = 0, b = 0, a = 0}},
        dialog = {width = 400, height = 100, button = {width = 100, height = 20, margin = 5}},
        tooltip = {padding = 10},
        resizeHandle = {width = 10, height = 10, texture = {normal = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up", highlight = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up", pushed = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down"}}
    }
    self._stdUi.config = rCfg
    self.frame = self._stdUi:Window(UIParent, self._width - 28, self._height - 100, "Audit Engine")
    self.frame:SetPoint("CENTER", 0, 0)
    self.frame:Hide()
    self.tabs = {}
    local ____self_tabs_0 = self.tabs
    ____self_tabs_0[#____self_tabs_0 + 1] = {name = "settings", title = "Settings"}
    local ____self_tabs_1 = self.tabs
    ____self_tabs_1[#____self_tabs_1 + 1] = {name = "units", title = "Units"}
    local ____self_tabs_2 = self.tabs
    ____self_tabs_2[#____self_tabs_2 + 1] = {name = "casts", title = "Casts"}
    local ____self_tabs_3 = self.tabs
    ____self_tabs_3[#____self_tabs_3 + 1] = {name = "buffs", title = "Buffs"}
    local ____self_tabs_4 = self.tabs
    ____self_tabs_4[#____self_tabs_4 + 1] = {name = "debuffs", title = "Debuffs"}
    local ____self_tabs_5 = self.tabs
    ____self_tabs_5[#____self_tabs_5 + 1] = {name = "objects", title = "Objects"}
    local ____self_tabs_6 = self.tabs
    ____self_tabs_6[#____self_tabs_6 + 1] = {name = "dynamic", title = "Dynamic"}
    self:buildBase(self.tabs)
end
function auditMenu.prototype.showMenu(self)
    if self.frame:IsVisible() then
        self.frame:Hide()
        return
    else
        self.frame:Show()
    end
end
function auditMenu.prototype.GetExeDirectory(self)
    return "scripts"
end
function auditMenu.prototype.Separator(self)
    return "/"
end
function auditMenu.prototype.DirectoryExists(self, path)
    return DirectoryExists(path)
end
function auditMenu.prototype.getBasePath(self)
    return (self:GetExeDirectory() .. self:Separator()) .. self.Folder
end
function auditMenu.prototype.listFiles(self)
    local folderLocation = (self:GetExeDirectory() .. self:Separator()) .. self.Folder
    if not self:DirectoryExists(folderLocation) then
        ravnInfo(("Folder " .. folderLocation) .. " does not exist")
        return {}
    end
    return ListFiles(folderLocation)
end
function auditMenu.prototype.onProfileLoad(self, profilePath)
    if not Global.auditEngineStarted then
        Global.auditEngine = __TS__New(AuditEngine)
        Global.auditEngineStarted = true
    end
    if profilePath == "local" then
        ravnInfo("Loading local profile")
        print(self.encounterId)
        self.loadedProfile = Global.auditEngine.Config
    else
        if not FileExists(profilePath) then
            ravnInfo(("Profile " .. profilePath) .. " does not exist")
            return
        end
        local loadProfile = ReadFile(profilePath)
        local profile = ravnJSON.parse(nil, loadProfile)
        if not profile then
            ravnInfo("Error loading profile " .. profilePath)
            return
        end
        self.loadedProfile = profile
    end
    local profile = self.loadedProfile
    if self.encounterId ~= 0 then
        local newProfile = {
            casts = {},
            buffs = {},
            debuffs = {},
            objects = {},
            dynamicObjects = {},
            units = {}
        }
        if profile.units ~= nil then
            newProfile.units = __TS__ArrayFilter(
                profile.units,
                function(____, o) return o.encounterId == self.encounterId end
            )
        end
        if profile.casts ~= nil then
            newProfile.casts = __TS__ArrayFilter(
                profile.casts,
                function(____, o) return o.encounterId == self.encounterId end
            )
        end
        if profile.buffs ~= nil then
            newProfile.buffs = __TS__ArrayFilter(
                profile.buffs,
                function(____, o) return o.encounterId == self.encounterId end
            )
        end
        if profile.debuffs ~= nil then
            newProfile.debuffs = __TS__ArrayFilter(
                profile.debuffs,
                function(____, o) return o.encounterId == self.encounterId end
            )
        end
        if profile.objects ~= nil then
            newProfile.objects = __TS__ArrayFilter(
                profile.objects,
                function(____, o) return o.encounterId == self.encounterId end
            )
        end
        if profile.dynamicObjects ~= nil then
            newProfile.dynamicObjects = __TS__ArrayFilter(
                profile.dynamicObjects,
                function(____, o) return o.encounterId == self.encounterId end
            )
        end
        profile = newProfile
    end
    self.loadedProfile = profile
    ravnInfo(("Profile " .. profilePath) .. " loaded")
    local unitLength = self.loadedProfile.units ~= nil and #self.loadedProfile.units or 0
    ravnInfo("Units: " .. tostring(unitLength))
    local castLength = self.loadedProfile.casts ~= nil and #self.loadedProfile.casts or 0
    ravnInfo("Casts: " .. tostring(castLength))
    local buffLength = self.loadedProfile.buffs ~= nil and #self.loadedProfile.buffs or 0
    ravnInfo("Buffs: " .. tostring(buffLength))
    local debuffLength = self.loadedProfile.debuffs ~= nil and #self.loadedProfile.debuffs or 0
    ravnInfo("Debuffs: " .. tostring(debuffLength))
    local objectLength = self.loadedProfile.objects ~= nil and #self.loadedProfile.objects or 0
    ravnInfo("Objects: " .. tostring(objectLength))
    local dynamicLength = self.loadedProfile.dynamicObjects ~= nil and #self.loadedProfile.dynamicObjects or 0
    ravnInfo("Dynamic: " .. tostring(dynamicLength))
    self:onUnitUpdate()
    self:onCastUpdate()
    self:onBuffUpdate()
    self:onDebuffUpdate()
    self:onObjectUpdate()
    self:onDynamicUpdate()
end
function auditMenu.prototype.buildBase(self, tab)
    local tabFrameH = self._stdUi:TabPanel(
        self.frame,
        nil,
        nil,
        tab,
        false
    )
    self._stdUi:GlueAcross(
        tabFrameH,
        self.frame,
        10,
        -40,
        -10,
        10
    )
    tabFrameH:EnumerateTabs(function(tab)
        if tab.name == "settings" then
            self:settingTab(tab)
        end
        if tab.name == "units" then
            self:unitsTab(tab)
        end
        if tab.name == "casts" then
            self:castsTab(tab)
        end
        if tab.name == "buffs" then
            self:buffsTab(tab)
        end
        if tab.name == "debuffs" then
            self:debuffsTab(tab)
        end
        if tab.name == "objects" then
            self:objectsTab(tab)
        end
        if tab.name == "dynamic" then
            self:dynamicTab(tab)
        end
    end)
end
function auditMenu.prototype.settingTab(self, tab)
    local profiles = self:listFiles()
    local profileInfo = {}
    __TS__ArrayForEach(
        profiles,
        function(____, o)
            profileInfo[#profileInfo + 1] = {
                text = o,
                value = (self:getBasePath() .. self:Separator()) .. o
            }
        end
    )
    local dd = self._stdUi:Dropdown(tab.frame, 200, 20, profileInfo)
    dd:SetPlaceholder("--Select Profile--")
    self._stdUi:GlueLeft(dd, tab.frame, 210, 160)
    dd.OnValueChanged = function(state, v)
        self:onProfileLoad(v)
    end
    local encounterEB = self._stdUi:SearchEditBox(tab.frame, 200, 20, "Encounter ID")
    self._stdUi:GlueRight(encounterEB, dd, 10, 0)
    encounterEB.OnValueChanged = function(state, v)
        v = __TS__StringTrim(v)
        local n = tonumber(v)
        if v == "" then
            n = 0
        end
        if n and type(n) == "number" then
            self.encounterId = n
        end
    end
    local loadLocal = self._stdUi:Button(tab.frame, 100, 20, "Load Local")
    self._stdUi:GlueBottom(loadLocal, dd, -50, -30)
    loadLocal:SetScript(
        "OnClick",
        function()
            self:onProfileLoad("local")
        end
    )
    local refresh = self._stdUi:Button(tab.frame, 100, 20, "Refresh")
    self._stdUi:GlueBottom(refresh, dd, 50, -30)
    refresh:SetScript(
        "OnClick",
        function()
            local profiles = self:listFiles()
            local profileInfo = {}
            __TS__ArrayForEach(
                profiles,
                function(____, o)
                    profileInfo[#profileInfo + 1] = {
                        text = o,
                        value = (self:getBasePath() .. self:Separator()) .. o
                    }
                end
            )
            dd.options = profileInfo
        end
    )
end
function auditMenu.prototype.onUnitUpdate(self)
    if not self.loadedProfile then
        return
    end
    local goodFrame = __TS__ArrayFind(
        self.tabs,
        function(____, o) return o.name == "units" end
    )
    if not goodFrame then
        return
    end
    if not goodFrame.frame then
        return
    end
    if not goodFrame.frame.scrolls then
        return
    end
    if not self.loadedProfile.units or #self.loadedProfile.units == 0 then
        return
    end
    local data = {}
    if self.loadedProfile.units and #self.loadedProfile.units > 0 then
        local texturePath = GetSpellTexture(self.PLUS_ICON)
        __TS__ArrayForEach(
            self.loadedProfile.units,
            function(____, o)
                data[#data + 1] = {name = o.name, id = o.id, track = texturePath}
            end
        )
    end
    goodFrame.frame.scrolls:SetData(data)
end
function auditMenu.prototype.unitsTab(self, tab)
    if not tab.frame then
        return
    end
    tab.frame.scrolls = {}
    local function onUnitClickbehaviour(id, rowIndex)
        if not self.loadedProfile then
            return
        end
        local unit = __TS__ArrayFind(
            self.loadedProfile.units,
            function(____, o) return o.id == id end
        )
        if not unit then
            ravnInfo(("<NEVER> Unit " .. tostring(id)) .. " not found")
            return
        end
        local value = Global.auditEngine:onTrackUnit(unit)
        local ____tab_frame_scrolls_data_7 = tab.frame
        if ____tab_frame_scrolls_data_7 ~= nil then
            ____tab_frame_scrolls_data_7 = ____tab_frame_scrolls_data_7.scrolls.data
        end
        local backUp = ____tab_frame_scrolls_data_7
        if not backUp then
            print("No backup")
        end
        local texture = value == "added" and self.MINUS_ICON or self.PLUS_ICON
        backUp[rowIndex].track = GetSpellTexture(texture)
        if value == "added" then
            ravnInfo(("Unit " .. unit.name) .. " added to tracking")
        else
            ravnInfo(("Unit " .. unit.name) .. " removed from tracking")
        end
    end
    local colonName = {
        name = "Name",
        width = 200,
        align = "LEFT",
        index = "name",
        format = "string",
        events = {}
    }
    local colonId = {
        name = "ID",
        width = 200,
        align = "LEFT",
        index = "id",
        format = "string",
        events = {}
    }
    local colonTrack = {
        name = "Track",
        width = 200,
        align = "LEFT",
        index = "track",
        format = "icon",
        events = {OnClick = function(smth, cellFrame, rowFrame, rowData, columnData, rowIndex, button, arg2)
            local id = rowData.id
            onUnitClickbehaviour(id, rowIndex)
        end}
    }
    local cols = {colonName, colonId, colonTrack}
    tab.frame.scrolls = self._stdUi:ScrollTable(tab.frame, cols, 9, 32)
    self._stdUi:GlueTop(tab.frame.scrolls, tab.frame, 10, -50)
    tab.frame.scrolls:EnableSelection(false)
end
function auditMenu.prototype.onCastUpdate(self)
    if not self.loadedProfile then
        return
    end
    local goodFrame = __TS__ArrayFind(
        self.tabs,
        function(____, o) return o.name == "casts" end
    )
    if not goodFrame then
        return
    end
    if not goodFrame.frame then
        return
    end
    if not goodFrame.frame.scrolls then
        return
    end
    if not self.loadedProfile.casts or #self.loadedProfile.casts == 0 then
        return
    end
    local data = {}
    if self.loadedProfile.casts and #self.loadedProfile.casts > 0 then
        local texturePath = GetSpellTexture(self.PLUS_ICON)
        __TS__ArrayForEach(
            self.loadedProfile.casts,
            function(____, o)
                data[#data + 1] = {
                    name = o.spellName,
                    id = o.id,
                    source = o.sourceName,
                    target = o.hasTarget and "TRUE" or "FALSE",
                    castTime = o.castTime,
                    track = texturePath
                }
            end
        )
        goodFrame.frame.scrolls:SetData(data)
    end
end
function auditMenu.prototype.castsTab(self, tab)
    if not tab.frame then
        return
    end
    tab.frame.scrolls = {}
    local function onCastClickbehaviour(id, rowIndex)
        if not self.loadedProfile then
            return
        end
        local cast = __TS__ArrayFind(
            self.loadedProfile.casts,
            function(____, o) return o.id == id end
        )
        if not cast then
            ravnInfo(("<NEVER> Cast " .. tostring(id)) .. " not found")
            return
        end
        local value = Global.auditEngine:onTrackCast(cast)
        local ____tab_frame_scrolls_data_9 = tab.frame
        if ____tab_frame_scrolls_data_9 ~= nil then
            ____tab_frame_scrolls_data_9 = ____tab_frame_scrolls_data_9.scrolls.data
        end
        local backUp = ____tab_frame_scrolls_data_9
        if not backUp then
            print("No backup")
        end
        local texture = value == "added" and self.MINUS_ICON or self.PLUS_ICON
        backUp[rowIndex].track = GetSpellTexture(texture)
        if value == "added" then
            ravnInfo(("Cast " .. cast.spellName) .. " added to tracking")
        else
            ravnInfo(("Cast " .. cast.spellName) .. " removed from tracking")
        end
    end
    local colonId = {
        name = "ID",
        align = "LEFT",
        index = "id",
        format = "string",
        width = 50,
        events = {}
    }
    local colonName = {
        name = "Name",
        width = 150,
        align = "LEFT",
        index = "name",
        format = "string"
    }
    local colonSource = {
        name = "Source",
        align = "LEFT",
        index = "source",
        format = "string",
        width = 150
    }
    local colonTarget = {
        name = "Target",
        align = "LEFT",
        index = "target",
        format = "string",
        width = 150
    }
    local colonCastTime = {
        name = "Cast Time",
        align = "LEFT",
        index = "castTime",
        format = "number",
        width = 150
    }
    local colonTrack = {
        name = "Track",
        width = 60,
        align = "LEFT",
        index = "track",
        format = "icon",
        events = {OnClick = function(smth, cellFrame, rowFrame, rowData, columnData, rowIndex, button, arg2)
            local id = rowData.id
            onCastClickbehaviour(id, rowIndex)
        end}
    }
    local colds = {
        colonId,
        colonName,
        colonSource,
        colonTarget,
        colonCastTime,
        colonTrack
    }
    tab.frame.scrolls = self._stdUi:ScrollTable(tab.frame, colds, 9, 32)
    self._stdUi:GlueTop(tab.frame.scrolls, tab.frame, 10, -50)
    tab.frame.scrolls:EnableSelection(false)
end
function auditMenu.prototype.onBuffUpdate(self)
    if not self.loadedProfile then
        return
    end
    local goodFrame = __TS__ArrayFind(
        self.tabs,
        function(____, o) return o.name == "buffs" end
    )
    if not goodFrame then
        return
    end
    if not goodFrame.frame then
        return
    end
    if not goodFrame.frame.scrolls then
        return
    end
    if not self.loadedProfile.buffs or #self.loadedProfile.buffs == 0 then
        return
    end
    local data = {}
    if self.loadedProfile.buffs and #self.loadedProfile.buffs > 0 then
        local texturePath = GetSpellTexture(self.PLUS_ICON)
        __TS__ArrayForEach(
            self.loadedProfile.buffs,
            function(____, o)
                data[#data + 1] = {
                    buffName = o.buffName,
                    id = o.id,
                    sourceName = o.sourceName,
                    destName = o.destName,
                    duration = o.duration,
                    track = texturePath
                }
            end
        )
        goodFrame.frame.scrolls:SetData(data)
    end
end
function auditMenu.prototype.buffsTab(self, tab)
    if not tab.frame then
        return
    end
    tab.frame.scrolls = {}
    local function onBuffClickbehaviour(id, rowIndex)
        if not self.loadedProfile then
            return
        end
        local buff = __TS__ArrayFind(
            self.loadedProfile.buffs,
            function(____, o) return o.id == id end
        )
        if not buff then
            ravnInfo(("<NEVER> Buff " .. tostring(id)) .. " not found")
            return
        end
        local value = Global.auditEngine:onTrackBuff(buff)
        local ____tab_frame_scrolls_data_11 = tab.frame
        if ____tab_frame_scrolls_data_11 ~= nil then
            ____tab_frame_scrolls_data_11 = ____tab_frame_scrolls_data_11.scrolls.data
        end
        local backUp = ____tab_frame_scrolls_data_11
        if not backUp then
            print("No backup")
        end
        local texture = value == "added" and self.MINUS_ICON or self.PLUS_ICON
        backUp[rowIndex].track = GetSpellTexture(texture)
        if value == "added" then
            ravnInfo(("Buff " .. buff.buffName) .. " added to tracking")
        else
            ravnInfo(("Buff " .. buff.buffName) .. " removed from tracking")
        end
    end
    local colonId = {
        name = "ID",
        align = "LEFT",
        index = "id",
        format = "string",
        width = 50,
        events = {}
    }
    local colonBuffName = {
        name = "Buff Name",
        width = 150,
        align = "LEFT",
        index = "buffName",
        format = "string"
    }
    local colonSource = {
        name = "Source",
        align = "LEFT",
        index = "sourceName",
        format = "string",
        width = 150
    }
    local colonDest = {
        name = "Destination",
        align = "LEFT",
        index = "destName",
        format = "string",
        width = 150
    }
    local colonDuration = {
        name = "Duration",
        align = "LEFT",
        index = "duration",
        format = "number",
        width = 150
    }
    local colonTrack = {
        name = "Track",
        width = 60,
        align = "LEFT",
        index = "track",
        format = "icon",
        events = {OnClick = function(smth, cellFrame, rowFrame, rowData, columnData, rowIndex, button, arg2)
            local id = rowData.id
            onBuffClickbehaviour(id, rowIndex)
        end}
    }
    local colds = {
        colonId,
        colonBuffName,
        colonSource,
        colonDest,
        colonDuration,
        colonTrack
    }
    tab.frame.scrolls = self._stdUi:ScrollTable(tab.frame, colds, 9, 32)
    self._stdUi:GlueTop(tab.frame.scrolls, tab.frame, 10, -50)
    tab.frame.scrolls:EnableSelection(false)
end
function auditMenu.prototype.onDebuffUpdate(self)
    if not self.loadedProfile then
        return
    end
    local goodFrame = __TS__ArrayFind(
        self.tabs,
        function(____, o) return o.name == "debuffs" end
    )
    if not goodFrame then
        return
    end
    if not goodFrame.frame then
        return
    end
    if not goodFrame.frame.scrolls then
        return
    end
    if not self.loadedProfile.debuffs or #self.loadedProfile.debuffs == 0 then
        return
    end
    local data = {}
    if self.loadedProfile.debuffs and #self.loadedProfile.debuffs > 0 then
        local texturePath = GetSpellTexture(self.PLUS_ICON)
        __TS__ArrayForEach(
            self.loadedProfile.debuffs,
            function(____, o)
                data[#data + 1] = {
                    debuffName = o.debuffName,
                    id = o.id,
                    sourceName = o.sourceName,
                    destName = o.destName,
                    duration = o.duration,
                    track = texturePath
                }
            end
        )
        goodFrame.frame.scrolls:SetData(data)
    end
end
function auditMenu.prototype.debuffsTab(self, tab)
    if not tab.frame then
        return
    end
    tab.frame.scrolls = {}
    local function onDebuffClickbehaviour(id, rowIndex)
        if not self.loadedProfile then
            return
        end
        local debuff = __TS__ArrayFind(
            self.loadedProfile.debuffs,
            function(____, o) return o.id == id end
        )
        if not debuff then
            ravnInfo(("<NEVER> Debuff " .. tostring(id)) .. " not found")
            return
        end
        local value = Global.auditEngine:onTrackDebuff(debuff)
        local ____tab_frame_scrolls_data_13 = tab.frame
        if ____tab_frame_scrolls_data_13 ~= nil then
            ____tab_frame_scrolls_data_13 = ____tab_frame_scrolls_data_13.scrolls.data
        end
        local backUp = ____tab_frame_scrolls_data_13
        if not backUp then
            print("No backup")
        end
        local texture = value == "added" and self.MINUS_ICON or self.PLUS_ICON
        backUp[rowIndex].track = GetSpellTexture(texture)
        if value == "added" then
            ravnInfo(("Debuff " .. debuff.debuffName) .. " added to tracking")
        else
            ravnInfo(("Debuff " .. debuff.debuffName) .. " removed from tracking")
        end
    end
    local colonId = {
        name = "ID",
        align = "LEFT",
        index = "id",
        format = "string",
        width = 50,
        events = {}
    }
    local colonDebuffName = {
        name = "Buff Name",
        width = 150,
        align = "LEFT",
        index = "debuffName",
        format = "string"
    }
    local colonSource = {
        name = "Source",
        align = "LEFT",
        index = "sourceName",
        format = "string",
        width = 150
    }
    local colonDest = {
        name = "Destination",
        align = "LEFT",
        index = "destName",
        format = "string",
        width = 150
    }
    local colonDuration = {
        name = "Duration",
        align = "LEFT",
        index = "duration",
        format = "number",
        width = 150
    }
    local colonTrack = {
        name = "Track",
        width = 60,
        align = "LEFT",
        index = "track",
        format = "icon",
        events = {OnClick = function(smth, cellFrame, rowFrame, rowData, columnData, rowIndex, button, arg2)
            local id = rowData.id
            onDebuffClickbehaviour(id, rowIndex)
        end}
    }
    local colds = {
        colonId,
        colonDebuffName,
        colonSource,
        colonDest,
        colonDuration,
        colonTrack
    }
    tab.frame.scrolls = self._stdUi:ScrollTable(tab.frame, colds, 9, 32)
    self._stdUi:GlueTop(tab.frame.scrolls, tab.frame, 10, -50)
    tab.frame.scrolls:EnableSelection(false)
end
function auditMenu.prototype.onObjectUpdate(self)
    if not self.loadedProfile then
        return
    end
    local goodFrame = __TS__ArrayFind(
        self.tabs,
        function(____, o) return o.name == "objects" end
    )
    if not goodFrame then
        return
    end
    if not goodFrame.frame then
        return
    end
    if not goodFrame.frame.scrolls then
        return
    end
    if not self.loadedProfile.objects or #self.loadedProfile.objects == 0 then
        return
    end
    local data = {}
    if self.loadedProfile.objects and #self.loadedProfile.objects > 0 then
        local texturePath = GetSpellTexture(self.PLUS_ICON)
        __TS__ArrayForEach(
            self.loadedProfile.objects,
            function(____, o)
                data[#data + 1] = {name = o.name, id = o.id, track = texturePath}
            end
        )
        goodFrame.frame.scrolls:SetData(data)
    end
end
function auditMenu.prototype.objectsTab(self, tab)
    if not tab.frame then
        return
    end
    tab.frame.scrolls = {}
    local function onObjectClickbehaviour(id, rowIndex)
        if not self.loadedProfile then
            return
        end
        local object = __TS__ArrayFind(
            self.loadedProfile.objects,
            function(____, o) return o.id == id end
        )
        if not object then
            ravnInfo(("<NEVER> Object " .. tostring(id)) .. " not found")
            return
        end
        local value = Global.auditEngine:onTrackObject(object)
        local ____tab_frame_scrolls_data_15 = tab.frame
        if ____tab_frame_scrolls_data_15 ~= nil then
            ____tab_frame_scrolls_data_15 = ____tab_frame_scrolls_data_15.scrolls.data
        end
        local backUp = ____tab_frame_scrolls_data_15
        if not backUp then
            print("No backup")
        end
        local texture = value == "added" and self.MINUS_ICON or self.PLUS_ICON
        backUp[rowIndex].track = GetSpellTexture(texture)
        if value == "added" then
            ravnInfo(("Object " .. object.name) .. " added to tracking")
        else
            ravnInfo(("Object " .. object.name) .. " removed from tracking")
        end
    end
    local colonId = {
        name = "ID",
        align = "LEFT",
        index = "id",
        format = "string",
        width = 50,
        events = {}
    }
    local colonName = {
        name = "Name",
        width = 150,
        align = "LEFT",
        index = "name",
        format = "string"
    }
    local colonTrack = {
        name = "Track",
        width = 60,
        align = "LEFT",
        index = "track",
        format = "icon",
        events = {OnClick = function(smth, cellFrame, rowFrame, rowData, columnData, rowIndex, button, arg2)
            local id = rowData.id
            onObjectClickbehaviour(id, rowIndex)
        end}
    }
    local colds = {colonId, colonName, colonTrack}
    tab.frame.scrolls = self._stdUi:ScrollTable(tab.frame, colds, 9, 32)
    self._stdUi:GlueTop(tab.frame.scrolls, tab.frame, 10, -50)
    tab.frame.scrolls:EnableSelection(false)
end
function auditMenu.prototype.onDynamicUpdate(self)
    if not self.loadedProfile then
        return
    end
    local goodFrame = __TS__ArrayFind(
        self.tabs,
        function(____, o) return o.name == "dynamic" end
    )
    if not goodFrame then
        return
    end
    if not goodFrame.frame then
        return
    end
    if not goodFrame.frame.scrolls then
        return
    end
    if not self.loadedProfile.dynamicObjects or #self.loadedProfile.dynamicObjects == 0 then
        return
    end
    local data = {}
    if self.loadedProfile.dynamicObjects and #self.loadedProfile.dynamicObjects > 0 then
        local texturePath = GetSpellTexture(self.PLUS_ICON)
        __TS__ArrayForEach(
            self.loadedProfile.dynamicObjects,
            function(____, o)
                data[#data + 1] = {id = o.id, track = texturePath}
            end
        )
        goodFrame.frame.scrolls:SetData(data)
    end
end
function auditMenu.prototype.dynamicTab(self, tab)
    if not tab.frame then
        return
    end
    tab.frame.scrolls = {}
    local function onDynamicClickbehaviour(id, rowIndex)
        if not self.loadedProfile then
            return
        end
        local dynamic = __TS__ArrayFind(
            self.loadedProfile.dynamicObjects,
            function(____, o) return o.id == id end
        )
        if not dynamic then
            ravnInfo(("<NEVER> Dynamic " .. tostring(id)) .. " not found")
            return
        end
        local value = Global.auditEngine:onTrackDynamic(dynamic)
        local ____tab_frame_scrolls_data_17 = tab.frame
        if ____tab_frame_scrolls_data_17 ~= nil then
            ____tab_frame_scrolls_data_17 = ____tab_frame_scrolls_data_17.scrolls.data
        end
        local backUp = ____tab_frame_scrolls_data_17
        if not backUp then
            print("No backup")
        end
        local texture = value == "added" and self.MINUS_ICON or self.PLUS_ICON
        backUp[rowIndex].track = GetSpellTexture(texture)
        if value == "added" then
            ravnInfo(("Dynamic " .. tostring(dynamic.id)) .. " added to tracking")
        else
            ravnInfo(("Dynamic " .. tostring(dynamic.id)) .. " removed from tracking")
        end
    end
    local colonId = {
        name = "ID",
        align = "LEFT",
        index = "id",
        format = "string",
        width = 50,
        events = {}
    }
    local colonTrack = {
        name = "Track",
        width = 60,
        align = "LEFT",
        index = "track",
        format = "icon",
        events = {OnClick = function(smth, cellFrame, rowFrame, rowData, columnData, rowIndex, button, arg2)
            local id = rowData.id
            onDynamicClickbehaviour(id, rowIndex)
        end}
    }
    local colds = {colonId, colonTrack}
    tab.frame.scrolls = self._stdUi:ScrollTable(tab.frame, colds, 9, 32)
    self._stdUi:GlueTop(tab.frame.scrolls, tab.frame, 10, -50)
    tab.frame.scrolls:EnableSelection(false)
end
awful.Populate(
    {
        ["Interface.menu.auditMenu"] = ____exports,
    },
    ravn,
    getfenv(1)
)
