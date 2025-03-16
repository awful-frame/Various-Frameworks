local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____spellList = ravn["Utilities.Lists.spellList"]
local SpellList = ____spellList.SpellList
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____stompList = ravn["Utilities.Stomp.stompList"]
local IStomps = ____stompList.IStomps
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ____structures = ravn["Utilities.structures"]
local MACRO_TYPE = ____structures.MACRO_TYPE
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____slashHandler = ravn["Interface.SlashCommand.SlashFramework.slashHandler"]
local SlashHandler = ____slashHandler.SlashHandler
local ____configValues = ravn["Interface.config.configValues"]
local ConfigValue = ____configValues.ConfigValue
local uniqueId = (function()
    local counter = 0
    return function()
        local ____counter_0 = counter
        counter = ____counter_0 + 1
        return ____counter_0
    end
end)()
local uniqueConstructor = (function()
    local cc = 0
    return function()
        local ____cc_1 = cc
        cc = ____cc_1 + 1
        return ____cc_1
    end
end)()
____exports.IBaseSetting = __TS__Class()
local IBaseSetting = ____exports.IBaseSetting
IBaseSetting.name = "IBaseSetting"
function IBaseSetting.prototype.____constructor(self, listLink, name, ____type, tooltip)
    self.name = name
    self.type = ____type
    self.tooltip = tooltip
    self.id = uniqueId()
    local ____listLink_settings_2 = listLink.settings
    ____listLink_settings_2[#____listLink_settings_2 + 1] = self
end
____exports.ICheckBox = __TS__Class()
local ICheckBox = ____exports.ICheckBox
ICheckBox.name = "ICheckBox"
__TS__ClassExtends(ICheckBox, ____exports.IBaseSetting)
function ICheckBox.prototype.____constructor(self, listLink, name, value, tooltip)
    ICheckBox.____super.prototype.____constructor(
        self,
        listLink,
        name,
        "checkbox",
        tooltip
    )
    self.value = value
end
____exports.ICheckBoxedSlider = __TS__Class()
local ICheckBoxedSlider = ____exports.ICheckBoxedSlider
ICheckBoxedSlider.name = "ICheckBoxedSlider"
__TS__ClassExtends(ICheckBoxedSlider, ____exports.IBaseSetting)
function ICheckBoxedSlider.prototype.____constructor(self, listLink, name, enabled, value, tooltip, minValues, maxValues, step, isAutoToggle)
    if minValues == nil then
        minValues = 0
    end
    if maxValues == nil then
        maxValues = 100
    end
    if step == nil then
        step = 0.01
    end
    if isAutoToggle == nil then
        isAutoToggle = false
    end
    ICheckBoxedSlider.____super.prototype.____constructor(
        self,
        listLink,
        name,
        "checkbox-slider",
        tooltip
    )
    self.isAutoToggle = false
    self.enabled = enabled
    self.value = value
    self.minValues = minValues
    self.maxValues = maxValues
    self.step = step
    self.isAutoToggle = isAutoToggle
end
____exports.ISlider = __TS__Class()
local ISlider = ____exports.ISlider
ISlider.name = "ISlider"
__TS__ClassExtends(ISlider, ____exports.IBaseSetting)
function ISlider.prototype.____constructor(self, listLink, name, value, tooltip, minValues, maxValues, step)
    if minValues == nil then
        minValues = 0
    end
    if maxValues == nil then
        maxValues = 100
    end
    if step == nil then
        step = 0.01
    end
    ISlider.____super.prototype.____constructor(
        self,
        listLink,
        name,
        "slider",
        tooltip
    )
    self.value = value
    self.minValues = minValues
    self.maxValues = maxValues
    self.step = step
end
____exports.IDropDown = __TS__Class()
local IDropDown = ____exports.IDropDown
IDropDown.name = "IDropDown"
__TS__ClassExtends(IDropDown, ____exports.IBaseSetting)
function IDropDown.prototype.____constructor(self, listLink, name, value, choices, tooltip)
    IDropDown.____super.prototype.____constructor(
        self,
        listLink,
        name,
        "dropdown",
        tooltip
    )
    self.value = value
    self.choices = choices
end
____exports.IMacro = __TS__Class()
local IMacro = ____exports.IMacro
IMacro.name = "IMacro"
__TS__ClassExtends(IMacro, ____exports.IBaseSetting)
function IMacro.prototype.____constructor(self, listLink, name, spellId, macroText, choices, tooltip, extra)
    if choices == nil then
        choices = MACRO_TYPE.NONE
    end
    IMacro.____super.prototype.____constructor(
        self,
        listLink,
        name,
        "macro",
        tooltip
    )
    self.spellId = spellId
    self.macroText = macroText
    if choices == MACRO_TYPE.ALL then
        self.choices = {
            "target",
            "party1",
            "party2",
            "player",
            "pet",
            "focus",
            "arenapet1",
            "arenapet2",
            "arenapet3",
            "arena1",
            "arena2",
            "arena3",
            "ehealer",
            "fhealer",
            "fdps",
            "eofftarget"
        }
    elseif choices == MACRO_TYPE.NONE then
        self.choices = {}
    elseif choices == MACRO_TYPE.ENEMIES then
        self.choices = {
            "target",
            "focus",
            "arenapet1",
            "arenapet2",
            "arenapet3",
            "arena1",
            "arena2",
            "arena3",
            "ehealer",
            "eofftarget"
        }
    elseif choices == MACRO_TYPE.FRIENDS then
        self.choices = {
            "party1",
            "party2",
            "player",
            "pet",
            "fhealer",
            "fdps",
            "target",
            "focus"
        }
    elseif choices == MACRO_TYPE.SPECIAL and extra then
        self.choices = extra
    else
        self.choices = {}
    end
end
____exports.ISpellList = __TS__Class()
local ISpellList = ____exports.ISpellList
ISpellList.name = "ISpellList"
__TS__ClassExtends(ISpellList, ____exports.IBaseSetting)
function ISpellList.prototype.____constructor(self, listLink, name, baseList, currentItems, tooltip)
    ISpellList.____super.prototype.____constructor(
        self,
        listLink,
        name,
        "spell-list",
        tooltip
    )
    self.baseList = baseList
    self.currentSettings = currentItems
end
____exports.IStompList = __TS__Class()
local IStompList = ____exports.IStompList
IStompList.name = "IStompList"
__TS__ClassExtends(IStompList, ____exports.IBaseSetting)
function IStompList.prototype.____constructor(self, listLink, name, baseList, data, tooltip)
    IStompList.____super.prototype.____constructor(
        self,
        listLink,
        name,
        "stomp-list",
        tooltip
    )
    self.data = {}
    self.baselist = {}
    self.data = data
    self.baselist = baseList
end
____exports.IList = __TS__Class()
local IList = ____exports.IList
IList.name = "IList"
function IList.prototype.____constructor(self, name, isHeader, allowedToLaunch)
    if allowedToLaunch == nil then
        allowedToLaunch = true
    end
    self.settings = {}
    self.name = name
    self.isHeader = isHeader
    self.allowedToLaunch = allowedToLaunch
end
____exports.ISettings = __TS__Class()
local ISettings = ____exports.ISettings
ISettings.name = "ISettings"
function ISettings.prototype.____constructor(self, name)
    self._count = 0
    self.lists = {}
    self.name = name
end
____exports.ModernConfig = __TS__Class()
local ModernConfig = ____exports.ModernConfig
ModernConfig.name = "ModernConfig"
function ModernConfig.prototype.____constructor(self)
    self.Folder = "Ravn-Classic"
    self.InterruptFolder = "RavnInterrupts"
    self.lastClean = 0
    self.shouldClean = false
    self.cache = {}
    self.RavnSetting = __TS__New(____exports.ISettings, "RavnClassic")
    if not self:DirectoryExists((((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. "\\") .. self.InterruptFolder) then
        self:CreateDirectory((((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. self.InterruptFolder)
    end
    self.Interrupts = {
        Heals = {},
        CCs = {},
        Damage = {},
        Always = {},
        Channel = {}
    }
    self.Stomps = {}
    self:LoadClassInterruptFile()
    self:LoadStompFile()
    self:populate()
    self:FolderCreation()
    self:LoadConfig()
end
function ModernConfig.prototype.DirectoryExists(self, path)
    return DirectoryExists(path)
end
function ModernConfig.prototype.CreateDirectory(self, path)
    return CreateDirectory(path)
end
function ModernConfig.prototype.FileExists(self, path)
    return FileExists(path)
end
function ModernConfig.prototype.GetExeDirectory(self)
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
function ModernConfig.prototype.Separator(self)
    if Unlocker.type == "tinkr" then
        return "/"
    else
        return "//"
    end
end
function ModernConfig.prototype.OpenAndReadFile(self, path)
    return ReadFile(path)
end
function ModernConfig.prototype.OpenAndWriteFile(self, path, content, append)
    WriteFile(path, content, append)
end
function ModernConfig.prototype.updateStompList(self, id, behavior)
    local index = __TS__ArrayFindIndex(
        self.Stomps,
        function(____, x) return x.id == id end
    )
    if index > -1 then
        self.Stomps[index + 1].stompBehavior = behavior
    end
    self:SaveStomps()
end
function ModernConfig.prototype.updateKickList(self, listName, id, add)
    if listName == ConfigValue.INTER_HEALS then
        if add and not __TS__ArrayIncludes(self.Interrupts.Heals, id) then
            local ____self_Interrupts_Heals_3 = self.Interrupts.Heals
            ____self_Interrupts_Heals_3[#____self_Interrupts_Heals_3 + 1] = id
        else
            if not add and __TS__ArrayIncludes(self.Interrupts.Heals, id) then
                local index = __TS__ArrayIndexOf(self.Interrupts.Heals, id)
                if index > -1 then
                    __TS__ArraySplice(self.Interrupts.Heals, index, 1)
                end
            end
        end
    elseif listName == ConfigValue.INTER_CC then
        if add and not __TS__ArrayIncludes(self.Interrupts.CCs, id) then
            local ____self_Interrupts_CCs_4 = self.Interrupts.CCs
            ____self_Interrupts_CCs_4[#____self_Interrupts_CCs_4 + 1] = id
        else
            if not add and __TS__ArrayIncludes(self.Interrupts.CCs, id) then
                local index = __TS__ArrayIndexOf(self.Interrupts.CCs, id)
                if index > -1 then
                    __TS__ArraySplice(self.Interrupts.CCs, index, 1)
                end
            end
        end
    elseif listName == ConfigValue.INTER_DAMAGE then
        if add and not __TS__ArrayIncludes(self.Interrupts.Damage, id) then
            local ____self_Interrupts_Damage_5 = self.Interrupts.Damage
            ____self_Interrupts_Damage_5[#____self_Interrupts_Damage_5 + 1] = id
        else
            if not add and __TS__ArrayIncludes(self.Interrupts.Damage, id) then
                local index = __TS__ArrayIndexOf(self.Interrupts.Damage, id)
                if index > -1 then
                    __TS__ArraySplice(self.Interrupts.Damage, index, 1)
                end
            end
        end
    elseif listName == ConfigValue.INTER_ALWAYS then
        if add and not __TS__ArrayIncludes(self.Interrupts.Always, id) then
            local ____self_Interrupts_Always_6 = self.Interrupts.Always
            ____self_Interrupts_Always_6[#____self_Interrupts_Always_6 + 1] = id
        else
            if not add and __TS__ArrayIncludes(self.Interrupts.Always, id) then
                local index = __TS__ArrayIndexOf(self.Interrupts.Always, id)
                if index > -1 then
                    __TS__ArraySplice(self.Interrupts.Always, index, 1)
                end
            end
        end
    elseif listName == ConfigValue.INTER_CHANNEL then
        if add and not __TS__ArrayIncludes(self.Interrupts.Channel, id) then
            local ____self_Interrupts_Channel_7 = self.Interrupts.Channel
            ____self_Interrupts_Channel_7[#____self_Interrupts_Channel_7 + 1] = id
        else
            if not add and __TS__ArrayIncludes(self.Interrupts.Channel, id) then
                local index = __TS__ArrayIndexOf(self.Interrupts.Channel, id)
                if index > -1 then
                    __TS__ArraySplice(self.Interrupts.Channel, index, 1)
                end
            end
        end
    end
    self:SaveKicks()
end
function ModernConfig.prototype.FolderCreation(self)
    local folderLocation = (self:GetExeDirectory() .. self:Separator()) .. self.Folder
    if not self:DirectoryExists(folderLocation) then
        self:CreateDirectory(folderLocation)
    end
    if not self:FileExists((((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. "Settings.json") then
        self:SaveConfig()
    end
end
function ModernConfig.prototype.LoadClassInterruptFile(self)
    local szPath = self:GetClassInterruptFile()
    if not self:FileExists(szPath) then
        self:NewKickFile(szPath)
    else
        self:LoadKicks(szPath)
    end
end
function ModernConfig.prototype.LoadStompFile(self)
    local szPath = (((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. "stomps.json"
    if not self:FileExists(szPath) then
        self:NewStompFile(szPath)
    else
        self.Stomps = ravnJSON.parse(
            nil,
            self:OpenAndReadFile(szPath)
        )
    end
end
function ModernConfig.prototype.NewStompFile(self, path_to_save)
    local baseList = __TS__ArrayMap(
        IStomps.totemList,
        function(____, o) return o.objectId end
    )
    __TS__ArrayForEach(
        baseList,
        function(____, o)
            local ____self_Stomps_8 = self.Stomps
            ____self_Stomps_8[#____self_Stomps_8 + 1] = {id = o, stompBehavior = "AUTO"}
        end
    )
    local str = ""
    str = ravnJSON.stringify(nil, self.Stomps)
    self:OpenAndWriteFile(path_to_save, str, false)
    print(("|cFFeb6e85RAVN: " .. Color.YELLOW) .. "New Stomps Created")
end
function ModernConfig.prototype.NewKickFile(self, path_to_save)
    self.Interrupts = {
        Heals = SpellList.csHeal,
        CCs = SpellList.csCC,
        Damage = SpellList.csDamage,
        Always = SpellList.csAlways,
        Channel = SpellList.csChannel
    }
    local ____string = ""
    ____string = ravnJSON.stringify(nil, self.Interrupts)
    self:OpenAndWriteFile(path_to_save, ____string, false)
    print(("|cFFeb6e85RAVN: " .. Color.YELLOW) .. "New Interrupts Created")
end
function ModernConfig.prototype.SaveKicks(self, sz)
    sz = sz or ravnJSON.stringify(nil, self.Interrupts)
    print(#self.Interrupts.Heals)
    local loc = self:GetClassInterruptFile()
    self:OpenAndWriteFile(loc, sz, false)
end
function ModernConfig.prototype.SaveStomps(self, sz)
    sz = sz or ravnJSON.stringify(nil, self.Stomps)
    local loc = (((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. "stomps.json"
    self:OpenAndWriteFile(loc, sz, false)
end
function ModernConfig.prototype.GetClassInterruptFile(self)
    local pC = select(
        2,
        awful.call("UnitClass", "player")
    )
    local sz = pC .. "_Interrupts.json"
    local szPath = (((((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. self.InterruptFolder) .. self:Separator()) .. sz
    return szPath
end
function ModernConfig.prototype.LoadKicks(self, path_to_load)
    ravnInfo("Loading Interrupt Tables")
    local list = ravnJSON.parse(
        nil,
        self:OpenAndReadFile(path_to_load)
    )
    self.Interrupts.Always = __TS__ArrayFilter(
        SpellList.csAlways,
        function(____, o) return __TS__ArrayIncludes(list.Always, o) end
    )
    self.Interrupts.CCs = __TS__ArrayFilter(
        SpellList.csCC,
        function(____, o) return __TS__ArrayIncludes(list.CCs, o) end
    )
    self.Interrupts.Damage = __TS__ArrayFilter(
        SpellList.csDamage,
        function(____, o) return __TS__ArrayIncludes(list.Damage, o) end
    )
    self.Interrupts.Channel = __TS__ArrayFilter(
        SpellList.csChannel,
        function(____, o) return __TS__ArrayIncludes(list.Channel, o) end
    )
    self.Interrupts.Heals = __TS__ArrayFilter(
        SpellList.csHeal,
        function(____, o) return __TS__ArrayIncludes(list.Heals, o) end
    )
end
function ModernConfig.prototype.SaveConfig(self)
    local szConfig = ""
    __TS__ArrayForEach(
        self.RavnSetting.lists,
        function(____, list)
            __TS__ArrayForEach(
                list.settings,
                function(____, setting)
                    if setting.type == "spell-list" or setting.type == "stomp-list" then
                        setting = nil
                    end
                end
            )
        end
    )
    szConfig = ravnJSON.stringify(nil, self.RavnSetting)
    self:OpenAndWriteFile(
        (((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. "Settings.json",
        szConfig,
        false
    )
    self.shouldClean = true
end
function ModernConfig.prototype.cleaning(self)
    if self.shouldClean then
        wipe(self.cache)
        self.shouldClean = false
    end
end
function ModernConfig.prototype.LoadConfig(self)
    local val = self:OpenAndReadFile((((self:GetExeDirectory() .. self:Separator()) .. self.Folder) .. self:Separator()) .. "Settings.json")
    local loaded = ravnJSON.parse(nil, val)
    __TS__ArrayForEach(
        self.RavnSetting.lists,
        function(____, list)
            local loadedList = __TS__ArrayFind(
                loaded.lists,
                function(____, x) return x.name == list.name end
            )
            if loadedList then
                __TS__ArrayForEach(
                    list.settings,
                    function(____, setting)
                        local loadedSetting = __TS__ArrayFind(
                            loadedList.settings,
                            function(____, x) return x.name == setting.name and x.type == setting.type end
                        )
                        if loadedSetting then
                            local ignore = loadedSetting.type == "spell-list" or loadedSetting.type == "stomp-list"
                            if not ignore then
                                list.settings[__TS__ArrayIndexOf(list.settings, setting) + 1] = loadedSetting
                            end
                        end
                    end
                )
            end
        end
    )
end
function ModernConfig.prototype.getSettingValue(self, ListName, settingName, settingType)
    return Memory.caching(
        self.cache,
        (ListName .. settingName) .. settingType,
        function()
            local list = __TS__ArrayFind(
                self.RavnSetting.lists,
                function(____, x) return x.name == ListName end
            )
            if list then
                local setting = __TS__ArrayFind(
                    list.settings,
                    function(____, x) return x.name == settingName and x.type == settingType end
                )
                if setting then
                    if settingType == "checkbox" then
                        local value = setting.value
                        if value == nil then
                            print((((((Color.ORANGE .. "[Ravn] ") .. Color.RED) .. "< never checkbox >") .. ListName) .. " ") .. settingName)
                        end
                        return setting.value
                    elseif settingType == "slider" then
                        local value = setting.value
                        if value == nil then
                            print((((((Color.ORANGE .. "[Ravn] ") .. Color.RED) .. "< never slider >") .. ListName) .. " ") .. settingName)
                        end
                        return setting.value
                    elseif settingType == "dropdown" then
                        local value = setting.value
                        if value == nil then
                            print((((((Color.ORANGE .. "[Ravn] ") .. Color.RED) .. "< never dropdown >") .. ListName) .. " ") .. settingName)
                        end
                        return setting.value
                    elseif settingType == "checkbox-slider" then
                        local base = setting
                        if base.enabled then
                            local value = base.value
                            if value == nil then
                                print((((((Color.ORANGE .. "[Ravn] ") .. Color.RED) .. "< never checkbox-slider float >") .. ListName) .. " ") .. settingName)
                            end
                            return base.value
                        else
                            local value = base.enabled
                            if value == nil then
                                print((((((Color.ORANGE .. "[Ravn] ") .. Color.RED) .. "< never checkbox-slider boolean >") .. ListName) .. " ") .. settingName)
                            end
                            return base.enabled
                        end
                    elseif settingType == "macro" then
                        return setting.macroText
                    end
                end
            end
            return nil
        end
    )
end
function ModernConfig.prototype.getStompStatus(self)
    return self:getSettingValue(ConfigValue.STOMP_SETTINGS, ConfigValue.ENABLE_STOMP, "checkbox")
end
function ModernConfig.prototype.getStompDelay(self)
    return self:getSettingValue(ConfigValue.STOMP_SETTINGS, ConfigValue.STOMP_SPEED, "slider")
end
function ModernConfig.prototype.getMiscDisabledSound(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.DISABLE_SOUNDS, "checkbox")
end
function ModernConfig.prototype.getMiscLegitMode(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.LEGIT_MODE, "checkbox")
end
function ModernConfig.prototype.getMiscCatchTrap(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.CATCH_TRAP, "checkbox")
end
function ModernConfig.prototype.getMiscHealthstone(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.HEALTHSTONE, "checkbox-slider")
end
function ModernConfig.prototype.getMiscAutoFake(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.AUTO_FAKE, "checkbox")
end
function ModernConfig.prototype.getFakeCastStatus(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.FAKE_CAST_INFO, "checkbox")
end
function ModernConfig.prototype.getMiscAutoFocus(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.AUTO_FOCUS, "checkbox")
end
function ModernConfig.prototype.getInterruptNoKickHybrids(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.NO_KICK_HYBRIDS, "checkbox")
end
function ModernConfig.prototype.getInterruptHpThreshold(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.HEALS_KICKS_THRESHOLD, "slider")
end
function ModernConfig.prototype.getInterruptMinimumChannelKick(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.MINIMUM_CHANNEL_KICK, "slider")
end
function ModernConfig.prototype.getInterruptKickfakes(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.FAST_KICK_FAKES, "checkbox")
end
function ModernConfig.prototype.getInterruptKickRandomized(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.RANDOMIZE_KICK_TYPES, "checkbox")
end
function ModernConfig.prototype.getInterruptImportantSchools(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.IMPORTANT_SCHOOLS, "checkbox")
end
function ModernConfig.prototype.getInterruptStatus(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.ENABLE_KICKS, "checkbox")
end
function ModernConfig.prototype.getInterruptTrustPriest(self)
    return self:getSettingValue(ConfigValue.INTERRUPTS_SETTINGS, ConfigValue.TRUST_PRIEST, "checkbox")
end
function ModernConfig.prototype.getMiscDangerIndicators(self)
    return self:getSettingValue(ConfigValue.MISC_SETTINGS, ConfigValue.DANGER_INDICATORS, "checkbox")
end
function ModernConfig.prototype.getGraphicsDisableDrawings(self)
    return self:getSettingValue(ConfigValue.GRAPHICS_SETTINGS, ConfigValue.DISABLE_DRAWINGS, "checkbox")
end
function ModernConfig.prototype.getGraphicLineToHealer(self)
    return self:getSettingValue(ConfigValue.GRAPHICS_SETTINGS, ConfigValue.LINE_TO_HEALER, "checkbox")
end
function ModernConfig.prototype.getGraphicTrackStealthed(self)
    return self:getSettingValue(ConfigValue.GRAPHICS_SETTINGS, ConfigValue.TRACK_STEALTHED, "checkbox")
end
function ModernConfig.prototype.getDemonoCurseOfTheElements(self)
    return self:getSettingValue(ConfigValue.WARLOCK_DEMONOLOGY, ConfigValue.WL_CURSE_OF_THE_ELEMENTS, "checkbox")
end
function ModernConfig.prototype.getDemonoMetaMeleeRangeOnly(self)
    return self:getSettingValue(ConfigValue.WARLOCK_DEMONOLOGY, ConfigValue.WL_FORM_MELEE_ONLY, "checkbox")
end
function ModernConfig.prototype.getDemonoSyncCD(self)
    return self:getSettingValue(ConfigValue.WARLOCK_DEMONOLOGY, ConfigValue.WL_DEMONO_SYNC_CD, "checkbox")
end
function ModernConfig.prototype.getAffliAutoTarget(self)
    return self:getSettingValue(ConfigValue.WARLOCK_AFFLICTION, ConfigValue.AFF_AUTO_TARGET, "checkbox")
end
function ModernConfig.prototype.getAffliOptiHaunt(self)
    return self:getSettingValue(ConfigValue.WARLOCK_AFFLICTION, ConfigValue.AFF_OPTI_HAUNT, "checkbox")
end
function ModernConfig.prototype.getAffliUAIgnoreKick(self)
    return self:getSettingValue(ConfigValue.WARLOCK_AFFLICTION, ConfigValue.AFF_IGNORE_INTERRUPT, "checkbox")
end
function ModernConfig.prototype.getAffliPetFollowHealer(self)
    return self:getSettingValue(ConfigValue.WARLOCK_AFFLICTION, ConfigValue.AFF_PET_ON_HEALER, "checkbox")
end
function ModernConfig.prototype.getAffliMaxPrioUA(self)
    return self:getSettingValue(ConfigValue.WARLOCK_AFFLICTION, ConfigValue.AFF_MAX_PRIORITY_UA, "checkbox")
end
function ModernConfig.prototype.getLockAutoFear(self)
    return self:getSettingValue(ConfigValue.WARLOCK_CC_SETTINGS, ConfigValue.WARLOCK_AUTO_FEAR, "checkbox")
end
function ModernConfig.prototype.getLockFearHealerOnly(self)
    return self:getSettingValue(ConfigValue.WARLOCK_CC_SETTINGS, ConfigValue.WARLOCK_FEAR_HEAL, "checkbox")
end
function ModernConfig.prototype.getLockFearUACover(self)
    return self:getSettingValue(ConfigValue.WARLOCK_CC_SETTINGS, ConfigValue.WARLOCK_COVER_FEAR, "checkbox")
end
function ModernConfig.prototype.setMiscLegitMode(self, value)
    local id = nil
    local list = __TS__ArrayFind(
        self.RavnSetting.lists,
        function(____, x) return x.name == ConfigValue.MISC_SETTINGS end
    )
    if list then
        local setting = __TS__ArrayFind(
            list.settings,
            function(____, x) return x.name == ConfigValue.LEGIT_MODE and x.type == "checkbox" end
        )
        if setting then
            id = setting.id
        end
    end
    if id ~= nil then
        __TS__ArrayForEach(
            self.RavnSetting.lists,
            function(____, list)
                local setting = __TS__ArrayFind(
                    list.settings,
                    function(____, x) return x.id == id end
                )
                if setting then
                    setting.value = value
                end
            end
        )
    end
    self:SaveConfig()
end
function ModernConfig.prototype.dropDownSelection(self, base, value, defaultValue, tooltip)
    __TS__New(
        ____exports.IDropDown,
        base,
        value,
        defaultValue,
        {
            ConfigValue.DROPDOWN_SELECTION_ALL_UNITS,
            ConfigValue.DROPDOWN_SELECTION_OTHER,
            ConfigValue.DROPDOWN_SELECTION_HEALER,
            ConfigValue.DROPDOWN_SELECTION_TARGET,
            ConfigValue.DROPDOWN_SELECTION_OFFTARGET,
            ConfigValue.DROPDOWN_OFF
        },
        tooltip
    )
end
function ModernConfig.prototype.populate(self)
    local ____self_RavnSetting_lists_9 = self.RavnSetting.lists
    ____self_RavnSetting_lists_9[#____self_RavnSetting_lists_9 + 1] = __TS__New(____exports.IList, ConfigValue.LIST_GENERAL, true)
    local misc = __TS__New(____exports.IList, ConfigValue.MISC_SETTINGS, false, true)
    __TS__New(
        ____exports.ICheckBox,
        misc,
        ConfigValue.DISABLE_SOUNDS,
        false,
        "Disable alerts sounds"
    )
    __TS__New(
        ____exports.ICheckBox,
        misc,
        ConfigValue.AUTO_FOCUS,
        true,
        "Will automatically swap focus in arena"
    )
    __TS__New(
        ____exports.ICheckBoxedSlider,
        misc,
        ConfigValue.HEALTHSTONE,
        true,
        30,
        "Auto healthstone when your hp drop below this value",
        1,
        100,
        1
    )
    __TS__New(
        ____exports.ICheckBoxedSlider,
        misc,
        ConfigValue.BATTLEMASTER,
        true,
        45,
        "Auto battlemaster trinket when your hp drop below this value",
        1,
        100,
        1
    )
    __TS__New(
        ____exports.ICheckBox,
        misc,
        ConfigValue.AUTO_FAKE,
        true,
        "Will automatically fake cast"
    )
    __TS__New(
        ____exports.ICheckBox,
        misc,
        ConfigValue.FAKE_CAST_INFO,
        true,
        "Will let you know when routine fk"
    )
    local ____self_RavnSetting_lists_10 = self.RavnSetting.lists
    ____self_RavnSetting_lists_10[#____self_RavnSetting_lists_10 + 1] = misc
    local interrupts = __TS__New(____exports.IList, ConfigValue.INTERRUPTS_SETTINGS, false, true)
    __TS__New(
        ____exports.ICheckBox,
        interrupts,
        ConfigValue.ENABLE_KICKS,
        true,
        "Enable interrupts"
    )
    __TS__New(
        ____exports.ICheckBox,
        interrupts,
        ConfigValue.TRUST_PRIEST,
        true,
        "Trust your priest to SW:D incomming CCs"
    )
    __TS__New(
        ____exports.ISlider,
        interrupts,
        ConfigValue.HEALS_KICKS_THRESHOLD,
        80,
        "Will not kick heals if the target is above this threshold",
        1,
        100,
        1
    )
    __TS__New(
        ____exports.ISlider,
        interrupts,
        ConfigValue.MINIMUM_CHANNEL_KICK,
        0.7,
        "Minimum amount of time before kicking a channeled spell",
        0.3,
        1.5,
        0.1
    )
    __TS__New(
        ____exports.ICheckBox,
        interrupts,
        ConfigValue.NO_KICK_HYBRIDS,
        true,
        "Will not kick hybrids when they cast heals (ret, feral, elem, ..."
    )
    __TS__New(
        ____exports.ICheckBox,
        interrupts,
        ConfigValue.FAST_KICK_FAKES,
        true,
        "Will kick quickly if the enemy is fake casting"
    )
    __TS__New(
        ____exports.ICheckBox,
        interrupts,
        ConfigValue.RANDOMIZE_KICK_TYPES,
        false,
        "Randomize the kick to be quick, normal, or late. The next kick will always differ from the current one"
    )
    __TS__New(
        ____exports.ICheckBox,
        interrupts,
        ConfigValue.IMPORTANT_SCHOOLS,
        true,
        "Will always kick SP on shadow, FrostMages on frost and paladins on holy"
    )
    local ____self_RavnSetting_lists_11 = self.RavnSetting.lists
    ____self_RavnSetting_lists_11[#____self_RavnSetting_lists_11 + 1] = interrupts
    local stomps = __TS__New(____exports.IList, ConfigValue.STOMP_SETTINGS, false, true)
    __TS__New(
        ____exports.ICheckBox,
        stomps,
        ConfigValue.ENABLE_STOMP,
        true,
        "Enable killing totems and small items"
    )
    __TS__New(
        ____exports.ISlider,
        stomps,
        ConfigValue.STOMP_SPEED,
        0.7,
        "How fast will you kill a totem/other",
        0.5,
        2,
        0.1
    )
    __TS__New(
        ____exports.ICheckBox,
        stomps,
        ConfigValue.STOMP_ALERTS,
        true,
        "Will alert you when an important stomp appears"
    )
    __TS__New(
        ____exports.ISlider,
        stomps,
        ConfigValue.STOMP_IGNORE_BELOW,
        10,
        "Will ignore totems when lowest enemy is below this percentage",
        0,
        100,
        1
    )
    __TS__New(
        ____exports.IStompList,
        stomps,
        "Stomps",
        __TS__ArrayMap(
            IStomps.totemList,
            function(____, o) return o.objectId end
        ),
        self.Stomps,
        "Select what to stomp"
    )
    local ____self_RavnSetting_lists_12 = self.RavnSetting.lists
    ____self_RavnSetting_lists_12[#____self_RavnSetting_lists_12 + 1] = stomps
    local ____self_RavnSetting_lists_13 = self.RavnSetting.lists
    ____self_RavnSetting_lists_13[#____self_RavnSetting_lists_13 + 1] = __TS__New(____exports.IList, ConfigValue.LIST_GRAPHICS, true)
    local graphics = __TS__New(____exports.IList, ConfigValue.GRAPHICS_SETTINGS, false, true)
    __TS__New(
        ____exports.ICheckBox,
        graphics,
        ConfigValue.DISABLE_DRAWINGS,
        false,
        "Disable all drawings"
    )
    __TS__New(
        ____exports.ICheckBox,
        graphics,
        ConfigValue.LINE_TO_HEALER,
        true,
        "Draw line to healer"
    )
    __TS__New(
        ____exports.ICheckBox,
        graphics,
        ConfigValue.TRACK_STEALTHED,
        true,
        "Track stealthed players with position being guessed"
    )
    local ____self_RavnSetting_lists_14 = self.RavnSetting.lists
    ____self_RavnSetting_lists_14[#____self_RavnSetting_lists_14 + 1] = graphics
    local ____self_RavnSetting_lists_15 = self.RavnSetting.lists
    ____self_RavnSetting_lists_15[#____self_RavnSetting_lists_15 + 1] = __TS__New(____exports.IList, ConfigValue.LIST_CLASS, true)
    local hunterSpecifics = __TS__New(____exports.IList, ConfigValue.HUNTER_SETTINGS, false, awful.player.class2 == WowClass.HUNTER)
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_AUTO_BURST,
        true,
        "Enable auto burst"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_OWL_AUTO,
        true,
        " Will automatically use Sentinel Owl"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_OWL_PREDICT,
        true,
        " Will try to predict when target will be out of LoS."
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_OWL_REACH,
        true,
        "Allow use of Harpoon | Flanking strike to connect on Owl"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_OWL_ALLOW,
        true,
        "Allow use of Coordinated Assault | SpearHead to connect on Owl"
    )
    __TS__New(
        ____exports.ISlider,
        hunterSpecifics,
        ConfigValue.HUNTER_OWL_HP,
        70,
        "Will not use owl if target is above this threshold",
        1,
        100,
        1
    )
    __TS__New(
        ____exports.IDropDown,
        hunterSpecifics,
        ConfigValue.HUNTER_EXPLOSIVE_TRAP,
        ConfigValue.DROPDOWN_COMPLEX,
        {ConfigValue.DROPDOWN_COMPLEX, ConfigValue.DROPDOWN_SIMPLE, ConfigValue.DROPDOWN_OFF},
        "Will automatically use RoS in dangerous situations"
    )
    __TS__New(
        ____exports.IDropDown,
        hunterSpecifics,
        ConfigValue.HUNTER_SLOW_MODE,
        ConfigValue.SLOW_MODE_SMART,
        {ConfigValue.SLOW_MODE_SMART, ConfigValue.SLOW_MODE_HEALER_ONLY, ConfigValue.SLOW_MODE_OFF},
        "How should the routine handle slows"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_HUNTERSMARK,
        true,
        "Will automatically use Hunter's Mark"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_POST_DISENGAGE_ACTION,
        false,
        "Will hold GCD on disengage if you're focused by a melee to cc it."
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterSpecifics,
        ConfigValue.HUNTER_AUTO_CALL_PET,
        true,
        "Auto summon pet. Will also disable auto rez pet"
    )
    local ____self_RavnSetting_lists_16 = self.RavnSetting.lists
    ____self_RavnSetting_lists_16[#____self_RavnSetting_lists_16 + 1] = hunterSpecifics
    local hunterFeign = __TS__New(____exports.IList, ConfigValue.HUNTER_FEIGN_SETTINGS, false, awful.player.class2 == WowClass.HUNTER)
    __TS__New(
        ____exports.ICheckBox,
        hunterFeign,
        ConfigValue.HUNTER_FEIGN_DEATH_HOLD,
        true,
        "Feign death will be holded until you press it manually"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterFeign,
        ConfigValue.HUNTER_FEIGN_DEATH_DAMAGE,
        true,
        "Feign death on incoming damage"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterFeign,
        ConfigValue.HUNTER_FEIGN_DEATH_CC,
        true,
        "Feign death on incoming CC"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterFeign,
        ConfigValue.HUNTER_FEIGN_DEATH_GP,
        true,
        "Feign death on gapclosers"
    )
    local ____self_RavnSetting_lists_17 = self.RavnSetting.lists
    ____self_RavnSetting_lists_17[#____self_RavnSetting_lists_17 + 1] = hunterFeign
    local hunterTraps = __TS__New(____exports.IList, ConfigValue.HUNTER_TRAP_SETTINGS, false, awful.player.class2 == WowClass.HUNTER)
    __TS__New(
        ____exports.ICheckBox,
        hunterTraps,
        ConfigValue.HUNTER_TRAP_AUTO,
        true,
        "Traps automatically"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterTraps,
        ConfigValue.HUNTER_TRAP_INFOS,
        true,
        "Display informations on trap"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterTraps,
        ConfigValue.HUNTER_TRAP_JUMP,
        true,
        "Will not trap if the unit is jumping"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterTraps,
        ConfigValue.HUNTER_TRAP_STACKS,
        true,
        "Will not trap if the unit is stacked"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterTraps,
        ConfigValue.HUNTER_TRAP_ASAP,
        false,
        "Will try to trap as soon as possible."
    )
    local ____self_RavnSetting_lists_18 = self.RavnSetting.lists
    ____self_RavnSetting_lists_18[#____self_RavnSetting_lists_18 + 1] = hunterTraps
    local hunterCC = __TS__New(____exports.IList, ConfigValue.HUNTER_CC_SETTINGS, false, awful.player.class2 == WowClass.HUNTER)
    __TS__New(
        ____exports.ICheckBox,
        hunterCC,
        ConfigValue.HUNTER_CHIMAERA_STING,
        true,
        "Will use Chimaera Sting on CC extension"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterCC,
        ConfigValue.HUNTER_SCATTER,
        false,
        "Will auto use scater shot"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterCC,
        ConfigValue.HUNTER_SCATTER_GP,
        false,
        "Will try to scatter on gapclosers"
    )
    local ____self_RavnSetting_lists_19 = self.RavnSetting.lists
    ____self_RavnSetting_lists_19[#____self_RavnSetting_lists_19 + 1] = hunterCC
    local hunterDefensives = __TS__New(____exports.IList, ConfigValue.HUNTER_DEFENSIVE_SETTINGS, false, awful.player.class2 == WowClass.HUNTER)
    __TS__New(
        ____exports.IDropDown,
        hunterDefensives,
        ConfigValue.HUNTER_ROS,
        ConfigValue.DROPDOWN_COMPLEX,
        {ConfigValue.DROPDOWN_COMPLEX, ConfigValue.DROPDOWN_SIMPLE, ConfigValue.DROPDOWN_OFF},
        "Will automatically use RoS in dangerous situations"
    )
    __TS__New(
        ____exports.IDropDown,
        hunterDefensives,
        ConfigValue.HUNTER_FREEDOM,
        ConfigValue.DROPDOWN_COMPLEX,
        {ConfigValue.DROPDOWN_COMPLEX, ConfigValue.DROPDOWN_SIMPLE, ConfigValue.DROPDOWN_OFF},
        "Will automatically use RoS in dangerous situations"
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterDefensives,
        ConfigValue.HUNTER_BANDAGE,
        true,
        "Will automatically stop movement to apply bandage"
    )
    __TS__New(
        ____exports.ICheckBoxedSlider,
        hunterDefensives,
        ConfigValue.HUNTER_TURTLE,
        true,
        0,
        "If disabled, will not use turtle. If set at 0, will use it automatically. If set at a value, will use it when your hp is below this value",
        0,
        100,
        1,
        true
    )
    __TS__New(
        ____exports.ICheckBoxedSlider,
        hunterDefensives,
        ConfigValue.HUNTER_EXHILARATION,
        true,
        0,
        "If disabled, will not use exhilaration. If set at 0, will use it automatically. If set at a value, will use it when your hp is below this value",
        0,
        100,
        1,
        true
    )
    __TS__New(
        ____exports.ICheckBoxedSlider,
        hunterDefensives,
        ConfigValue.HUNTER_FITTEST,
        true,
        0,
        "If disabled, will not use survival of the fittest. If set at 0, will use it automatically. If set at a value, will use it when your hp is below this value",
        0,
        100,
        1,
        true
    )
    __TS__New(
        ____exports.ICheckBoxedSlider,
        hunterDefensives,
        ConfigValue.HUNTER_FORTITUDE_OF_THE_BEAR,
        true,
        0,
        "If disabled, will not use fortitude of the bear. If set at 0, will use it automatically. If set at a value, will use it when your hp is below this value",
        0,
        100,
        1,
        true
    )
    local ____self_RavnSetting_lists_20 = self.RavnSetting.lists
    ____self_RavnSetting_lists_20[#____self_RavnSetting_lists_20 + 1] = hunterDefensives
    local hunterPetBehaviour = __TS__New(____exports.IList, ConfigValue.HUNTER_PET_BEHAVIOUR, false, awful.player.class2 == WowClass.HUNTER)
    __TS__New(
        ____exports.ISlider,
        hunterPetBehaviour,
        ConfigValue.HUNTER_PET_SLOT,
        1,
        "Define the pet slot you want to use",
        1,
        5,
        1
    )
    __TS__New(
        ____exports.ISlider,
        hunterPetBehaviour,
        ConfigValue.HUNTER_PET_RET_SLOT,
        1,
        "Define the pet slot you want to use agianst ret",
        1,
        5,
        1
    )
    __TS__New(
        ____exports.ICheckBox,
        hunterPetBehaviour,
        ConfigValue.HUNTER_PET_CATCH_TRAP,
        true,
        "Your pet will try to catch enemy trap"
    )
    local ____self_RavnSetting_lists_21 = self.RavnSetting.lists
    ____self_RavnSetting_lists_21[#____self_RavnSetting_lists_21 + 1] = hunterPetBehaviour
    local demonology = __TS__New(
        ____exports.IList,
        ConfigValue.WARLOCK_DEMONOLOGY,
        false,
        awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 2
    )
    __TS__New(
        ____exports.ICheckBox,
        demonology,
        ConfigValue.WL_CURSE_OF_THE_ELEMENTS,
        true,
        "Will use Curse of the Elements"
    )
    __TS__New(
        ____exports.ICheckBox,
        demonology,
        ConfigValue.WL_FORM_MELEE_ONLY,
        true,
        "Will only use metamorphosis if in range of immolation aura"
    )
    __TS__New(
        ____exports.ICheckBox,
        demonology,
        ConfigValue.WL_DEMONO_SYNC_CD,
        false,
        "Will sync your cooldowns"
    )
    local ____self_RavnSetting_lists_22 = self.RavnSetting.lists
    ____self_RavnSetting_lists_22[#____self_RavnSetting_lists_22 + 1] = demonology
    local affli = __TS__New(
        ____exports.IList,
        ConfigValue.WARLOCK_AFFLICTION,
        false,
        awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 1
    )
    __TS__New(
        ____exports.ICheckBox,
        affli,
        ConfigValue.AFF_AUTO_TARGET,
        true,
        "Automatically set your main target to your friend in arena"
    )
    __TS__New(
        ____exports.ICheckBox,
        affli,
        ConfigValue.AFF_OPTI_HAUNT,
        true,
        "Will always try to use haunt on the most valuable target - may not be your main target"
    )
    __TS__New(
        ____exports.ICheckBox,
        affli,
        ConfigValue.AFF_IGNORE_INTERRUPT,
        false,
        "Will be more daring to cast UA even if you can get kicked"
    )
    __TS__New(
        ____exports.ICheckBox,
        affli,
        ConfigValue.AFF_PET_ON_HEALER,
        true,
        "Pet will follow healer if set to next heal (from custom kick)"
    )
    __TS__New(
        ____exports.ICheckBox,
        affli,
        ConfigValue.AFF_MAX_PRIORITY_UA,
        false,
        "Will prioritize UA over other spells"
    )
    local ____self_RavnSetting_lists_23 = self.RavnSetting.lists
    ____self_RavnSetting_lists_23[#____self_RavnSetting_lists_23 + 1] = affli
    local fearSettings = __TS__New(
        ____exports.IList,
        ConfigValue.WARLOCK_CC_SETTINGS,
        false,
        awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 1
    )
    __TS__New(
        ____exports.ICheckBox,
        fearSettings,
        ConfigValue.WARLOCK_AUTO_FEAR,
        true,
        "Will automatically fear"
    )
    __TS__New(
        ____exports.ICheckBox,
        fearSettings,
        ConfigValue.WARLOCK_FEAR_HEAL,
        true,
        "Will only fear healer"
    )
    __TS__New(
        ____exports.ICheckBox,
        fearSettings,
        ConfigValue.WARLOCK_COVER_FEAR,
        true,
        "Will require UA to be up on targets to be feared (arena + on dps only"
    )
    local ____self_RavnSetting_lists_24 = self.RavnSetting.lists
    ____self_RavnSetting_lists_24[#____self_RavnSetting_lists_24 + 1] = fearSettings
    local macroSubCategory = __TS__New(____exports.IList, "General Macros", false)
    __TS__ArrayForEach(
        SlashHandler.generalEvents,
        function(____, evt)
            __TS__New(
                ____exports.IMacro,
                macroSubCategory,
                evt.title,
                evt.icon,
                evt.macroText,
                evt.type,
                evt.tooltip,
                evt.extra
            )
        end
    )
    local ____self_RavnSetting_lists_25 = self.RavnSetting.lists
    ____self_RavnSetting_lists_25[#____self_RavnSetting_lists_25 + 1] = macroSubCategory
    local classMacro = __TS__New(____exports.IList, "Class Macro", false)
    __TS__ArrayForEach(
        SlashHandler.classEvents,
        function(____, evt)
            __TS__New(
                ____exports.IMacro,
                classMacro,
                evt.title,
                evt.icon,
                evt.macroText,
                evt.type,
                evt.tooltip,
                evt.extra
            )
        end
    )
    local ____self_RavnSetting_lists_26 = self.RavnSetting.lists
    ____self_RavnSetting_lists_26[#____self_RavnSetting_lists_26 + 1] = classMacro
    local specMacro = __TS__New(____exports.IList, "Spec Macro", false)
    __TS__ArrayForEach(
        SlashHandler.specEvents,
        function(____, evt)
            __TS__New(
                ____exports.IMacro,
                specMacro,
                evt.title,
                evt.icon,
                evt.macroText,
                evt.type,
                evt.tooltip,
                evt.extra
            )
        end
    )
    local ____self_RavnSetting_lists_27 = self.RavnSetting.lists
    ____self_RavnSetting_lists_27[#____self_RavnSetting_lists_27 + 1] = specMacro
    local ____self_RavnSetting_lists_28 = self.RavnSetting.lists
    ____self_RavnSetting_lists_28[#____self_RavnSetting_lists_28 + 1] = __TS__New(____exports.IList, ConfigValue.LIST_INTERRUPT, true)
    local ccs = __TS__New(____exports.IList, ConfigValue.INTER_CC, false)
    __TS__New(
        ____exports.ISpellList,
        ccs,
        "CCs",
        SpellList.csCC,
        self.Interrupts.CCs
    )
    local ____self_RavnSetting_lists_29 = self.RavnSetting.lists
    ____self_RavnSetting_lists_29[#____self_RavnSetting_lists_29 + 1] = ccs
    local heals = __TS__New(____exports.IList, ConfigValue.INTER_HEALS, false)
    __TS__New(
        ____exports.ISpellList,
        heals,
        "Heals",
        SpellList.csHeal,
        self.Interrupts.Heals
    )
    local ____self_RavnSetting_lists_30 = self.RavnSetting.lists
    ____self_RavnSetting_lists_30[#____self_RavnSetting_lists_30 + 1] = heals
    local damage = __TS__New(____exports.IList, ConfigValue.INTER_DAMAGE, false)
    __TS__New(
        ____exports.ISpellList,
        damage,
        "Damage",
        SpellList.csDamage,
        self.Interrupts.Damage
    )
    local ____self_RavnSetting_lists_31 = self.RavnSetting.lists
    ____self_RavnSetting_lists_31[#____self_RavnSetting_lists_31 + 1] = damage
    local always = __TS__New(____exports.IList, ConfigValue.INTER_ALWAYS, false)
    __TS__New(
        ____exports.ISpellList,
        always,
        "Always",
        SpellList.csAlways,
        self.Interrupts.Always
    )
    local ____self_RavnSetting_lists_32 = self.RavnSetting.lists
    ____self_RavnSetting_lists_32[#____self_RavnSetting_lists_32 + 1] = always
    local channel = __TS__New(____exports.IList, ConfigValue.INTER_CHANNEL, false)
    __TS__New(
        ____exports.ISpellList,
        channel,
        "Channel",
        SpellList.csChannel,
        self.Interrupts.Channel
    )
    local ____self_RavnSetting_lists_33 = self.RavnSetting.lists
    ____self_RavnSetting_lists_33[#____self_RavnSetting_lists_33 + 1] = channel
end
awful.Populate(
    {
        ["Interface.config.modernConfig"] = ____exports,
    },
    ravn,
    getfenv(1)
)
