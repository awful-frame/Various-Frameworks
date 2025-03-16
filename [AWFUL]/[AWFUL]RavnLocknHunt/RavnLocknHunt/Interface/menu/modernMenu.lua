local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____stompList = ravn["Utilities.Stomp.stompList"]
local IStomps = ____stompList.IStomps
local ____spell = ravn["Utilities.spell"]
local Spell = ____spell.Spell
local ____script = ravn["Interface.SlashCommand.script"]
local Script = ____script.Script
local listPositionX = 0
local listPositionY = 0
local baseMenu = __TS__Class()
baseMenu.name = "baseMenu"
function baseMenu.prototype.____constructor(self, frameName)
    self.isMoving = false
    self.frame = CreateFrame("Frame", frameName, UIParent, "SettingsFrameTemplate")
    self.frame:SetPoint("TOP", 0, -116)
    self.frame:SetSize(920, 724)
    self.frame:SetFrameLevel(2)
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:SetScript(
        "OnMouseDown",
        function()
            self.frame:StartMoving()
            self.isMoving = true
        end
    )
    self.frame:SetScript(
        "OnMouseUp",
        function()
            self.frame:StopMovingOrSizing()
            self.isMoving = false
        end
    )
    self.frame:SetScript(
        "OnHide",
        function()
            if self.isMoving then
                self.frame:StopMovingOrSizing()
                self.isMoving = false
            end
        end
    )
    self.frame:Hide()
    self.InnerFrame = self.frame:CreateTexture("Options_InnerFrame", "ARTWORK")
    self.InnerFrame:SetAtlas("Options_InnerFrame", true)
    self.InnerFrame:SetPoint("TOPLEFT", 17, -64)
    self.CategoryList = CreateFrame(
        "Frame",
        tostring(frameName) .. "_CategoryList",
        self.frame
    )
    self.CategoryList:SetSize(199, 569)
    self.CategoryList:SetPoint("TOPLEFT", 18, -76)
    self.CategoryList:SetPoint("BOTTOMLEFT", 178, 46)
    self.CategoryList.SelectedFrame = ""
    self.CategoryList.Entries = {}
    if awful.DevMode then
        local debugMenuBtn = CreateFrame("Button", nil, self.frame)
        debugMenuBtn:SetSize(170, 38)
        debugMenuBtn:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            350,
            -25
        )
        debugMenuBtn.Texture = debugMenuBtn:CreateTexture(nil, "BACKGROUND")
        debugMenuBtn.Texture:SetPoint(
            "CENTER",
            debugMenuBtn,
            "CENTER",
            0,
            0
        )
        debugMenuBtn.Texture:SetSize(170, 38)
        debugMenuBtn.Texture:SetAtlas("charactercreate-customize-dropdownbox")
        debugMenuBtn.Text = debugMenuBtn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        debugMenuBtn.Text:SetText("Debug Menu")
        debugMenuBtn.Text:SetPoint(
            "CENTER",
            debugMenuBtn,
            "CENTER",
            0,
            0
        )
        debugMenuBtn:SetScript(
            "OnClick",
            function()
            end
        )
        debugMenuBtn:SetScript(
            "OnEnter",
            function()
                debugMenuBtn.Texture:SetAtlas("charactercreate-customize-dropdownbox-open")
            end
        )
        debugMenuBtn:SetScript(
            "OnLeave",
            function()
                debugMenuBtn.Texture:SetAtlas("charactercreate-customize-dropdownbox")
            end
        )
        debugMenuBtn:SetScript(
            "OnMouseDown",
            function()
                debugMenuBtn.Text:SetPoint(
                    "CENTER",
                    debugMenuBtn,
                    "CENTER",
                    2,
                    -2
                )
            end
        )
        debugMenuBtn:SetScript(
            "OnMouseUp",
            function()
                debugMenuBtn.Text:SetPoint(
                    "CENTER",
                    debugMenuBtn,
                    "CENTER",
                    0,
                    0
                )
            end
        )
    end
    self.frame.NineSlice.Text:SetText(frameName)
end
local SettingFrame = __TS__Class()
SettingFrame.name = "SettingFrame"
function SettingFrame.prototype.____constructor(self, base, list)
    self.selectedTab = ""
    self.isSelected = false
    self.containerPositionX = 20
    self.containerPositionY = -7
    local r = math.random(0, 100000)
    local fName = (list.name .. "_a_container_") .. tostring(r)
    local function allSpellsName()
        local number = GetNumSpellTabs()
        local ret = {}
        do
            local tabIndex = 1
            while tabIndex <= number do
                local name, texture, offset, numSlots, isGuild, a, b, specid = GetSpellTabInfo(tabIndex)
                if specid == nil or specid == awful.player.specId then
                    do
                        local i = offset
                        while i < offset + numSlots do
                            local ____type, spellId = GetSpellBookItemInfo(i, "spell")
                            if ____type == "SPELL" then
                                if spellId ~= nil and IsPassiveSpell(spellId, "spell") == nil then
                                    local name = Spell.getName(spellId)
                                    ret[#ret + 1] = name
                                end
                            end
                            i = i + 1
                        end
                    end
                end
                tabIndex = tabIndex + 1
            end
        end
        return ret
    end
    if list.isHeader == false then
        self.container = CreateFrame("Frame", fName, base.baseMenu.frame, "SettingsListTemplate")
        self.container:SetPoint(
            "TOPLEFT",
            base.baseMenu.CategoryList,
            "TOPRIGHT",
            16,
            0
        )
        self.container:SetPoint(
            "BOTTOMLEFT",
            base.baseMenu.CategoryList,
            "BOTTOMRIGHT",
            16,
            3
        )
        self.container:SetPoint("RIGHT", -22, 0)
        self.container:Hide()
        self.container.Header.Title:SetText(list.name)
        self.container.Header.DefaultsButton:Hide()
        self.container.ScrollBar:Show()
        self.container.ScrollBar:SetPoint(
            "TOPLEFT",
            self.container.ScrollBox,
            "TOPRIGHT",
            -5,
            -4
        )
        self.container.ScrollBar:SetPoint(
            "BOTTOMLEFT",
            self.container.ScrollBox,
            "BOTTOMRIGHT",
            5,
            5
        )
        self.container.baseSettings = {}
        local ArrowTop = CreateFrame("Button", nil, self.container)
        ArrowTop:SetSize(30, 30)
        ArrowTop:SetPoint(
            "TOPLEFT",
            self.container,
            "TOPRIGHT",
            -50,
            -50
        )
        ArrowTop:Hide()
        ArrowTop.Texture = ArrowTop:CreateTexture(nil, "BACKGROUND")
        ArrowTop.Texture:SetPoint(
            "CENTER",
            ArrowTop,
            "CENTER",
            0,
            0
        )
        ArrowTop.Texture:SetSize(17, 11)
        ArrowTop.Texture:SetAtlas("minimal-scrollbar-arrow-top")
        ArrowTop.Texture2 = ArrowTop:CreateTexture(nil, "BACKGROUND")
        ArrowTop.Texture2:SetPoint(
            "CENTER",
            ArrowTop,
            "CENTER",
            0,
            -10
        )
        ArrowTop.Texture2:SetSize(17, 11)
        ArrowTop.Texture2:SetAtlas("minimal-scrollbar-arrow-top")
        ArrowTop.Texture3 = ArrowTop:CreateTexture(nil, "BACKGROUND")
        ArrowTop.Texture3:SetPoint(
            "CENTER",
            ArrowTop,
            "CENTER",
            0,
            -20
        )
        ArrowTop.Texture3:SetSize(17, 11)
        ArrowTop.Texture3:SetAtlas("minimal-scrollbar-arrow-top")
        do
            local i = 0
            while i < #list.settings do
                if list.settings[i + 1].type == "checkbox" then
                    local item = self:createCheckBox(self.container, list.settings[i + 1])
                    local ____self_container_baseSettings_0 = self.container.baseSettings
                    ____self_container_baseSettings_0[#____self_container_baseSettings_0 + 1] = item
                elseif list.settings[i + 1].type == "slider" then
                    local item = self:createSlider(self.container, list.settings[i + 1])
                    local ____self_container_baseSettings_1 = self.container.baseSettings
                    ____self_container_baseSettings_1[#____self_container_baseSettings_1 + 1] = item
                elseif list.settings[i + 1].type == "checkbox-slider" then
                    local item = self:createCheckboxedSlider(self.container, list.settings[i + 1])
                    local ____self_container_baseSettings_2 = self.container.baseSettings
                    ____self_container_baseSettings_2[#____self_container_baseSettings_2 + 1] = item
                elseif list.settings[i + 1].type == "dropdown" then
                    local item = self:createDropDown(self.container, list.settings[i + 1])
                    local ____self_container_baseSettings_3 = self.container.baseSettings
                    ____self_container_baseSettings_3[#____self_container_baseSettings_3 + 1] = item
                elseif list.settings[i + 1].type == "macro" then
                    local item = self:createMacro(self.container, list.settings[i + 1])
                    local ____self_container_baseSettings_4 = self.container.baseSettings
                    ____self_container_baseSettings_4[#____self_container_baseSettings_4 + 1] = item
                elseif list.settings[i + 1].type == "spell-list" then
                    local items = self:createSpellList(self.container, list.settings[i + 1])
                    self.container.baseSettings = __TS__ArrayConcat(self.container.baseSettings, items)
                elseif list.settings[i + 1].type == "stomp-list" then
                    local items = self:createStompList(self.container, list.settings[i + 1])
                    self.container.baseSettings = __TS__ArrayConcat(self.container.baseSettings, items)
                end
                i = i + 1
            end
        end
        self.container.scrollCount = 0
        self.container.itemAmount = #self.container.baseSettings
        local maxItemPerPage = 15
        local maxScrollCount = math.max(0, #self.container.baseSettings - maxItemPerPage)
        self.container.ScrollBox:SetScript(
            "OnMouseWheel",
            function(a, delta)
                local previousScrollCount = self.container.scrollCount
                if maxScrollCount == 0 then
                    return
                end
                local currentPoint, relativeTo, relativePoint, xOffset, yOffset = self.container.ScrollBox:GetPoint()
                if delta > 0 then
                    if self.container.scrollCount == 0 then
                        return
                    end
                    yOffset = yOffset - 35
                    local ____self_container_5, ____scrollCount_6 = self.container, "scrollCount"
                    ____self_container_5[____scrollCount_6] = ____self_container_5[____scrollCount_6] - 1
                else
                    if self.container.scrollCount == maxScrollCount then
                        return
                    end
                    local ____self_container_7, ____scrollCount_8 = self.container, "scrollCount"
                    ____self_container_7[____scrollCount_8] = ____self_container_7[____scrollCount_8] + 1
                    yOffset = yOffset + 35
                end
                if self.container.scrollCount > previousScrollCount then
                    local frame = self.container.baseSettings[self.container.scrollCount]
                    if frame ~= nil then
                        frame:Hide()
                    end
                end
                if self.container.scrollCount < previousScrollCount then
                    local frame = self.container.baseSettings[self.container.scrollCount + 1]
                    if frame ~= nil then
                        frame:Show()
                    end
                end
                if self.container.scrollCount == 0 then
                    local frame = self.container.baseSettings[1]
                    if frame ~= nil then
                        frame:Show()
                    end
                    ArrowTop:Hide()
                end
                if self.container.scrollCount > 0 then
                    ArrowTop:Show()
                end
                self.container.ScrollBox:SetPoint(
                    currentPoint,
                    relativeTo,
                    relativePoint,
                    xOffset,
                    yOffset
                )
            end
        )
        self.container:SetScript(
            "OnLoad",
            function()
            end
        )
        self.container:SetScript(
            "OnUpdate",
            function()
            end
        )
        self.container:SetScript(
            "OnSizeChanged",
            function()
            end
        )
    end
    local ____list_isHeader_9
    if list.isHeader then
        ____list_isHeader_9 = self:createHeader(list.name, base.baseMenu.CategoryList)
    else
        ____list_isHeader_9 = self:createList(list.name, base.baseMenu.CategoryList)
    end
end
function SettingFrame.prototype.simpleRound(self, number, precision)
    local factor = math.pow(10, precision)
    return math.floor(number * factor + 0.5) / factor
end
function SettingFrame.prototype.createHeader(self, name, parent)
    self.settingSide = CreateFrame("Frame", name .. "_CategoryHeader", parent)
    self.settingSide:SetSize(199, 30)
    if listPositionY ~= 0 then
        listPositionY = listPositionY - 40
    end
    self.settingSide:SetPoint("TOPLEFT", listPositionX, listPositionY)
    self.settingSide:Show()
    local labl = self.settingSide:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    labl:SetText(name)
    labl:SetJustifyH("LEFT")
    labl:SetPoint(
        "LEFT",
        self.settingSide,
        "TOPLEFT",
        15,
        -15
    )
    local background = self.settingSide:CreateTexture(nil, "OVERLAY")
    background:SetAtlas("Options_CategoryHeader_1", true)
    background:SetPoint("TOPLEFT", 0, 0)
    listPositionY = listPositionY - 32
end
function SettingFrame.prototype.createList(self, name, parent)
    local random = math.random(0, 100000)
    local nameR = (("listEntry_" .. parent:GetName()) .. "_") .. tostring(random)
    self.settingSide = CreateFrame("Button", nameR, parent)
    local ____parent_Entries_10 = parent.Entries
    ____parent_Entries_10[#____parent_Entries_10 + 1] = self
    self.settingSide:SetSize(199, 20)
    self.settingSide:SetPoint("TOPLEFT", listPositionX, listPositionY)
    self.settingSide:Show()
    self.settingSide:RegisterForClicks("LeftButtonUp")
    self.settingSide.label = self.settingSide:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.settingSide.label:SetText(name)
    self.settingSide.label:SetJustifyH("LEFT")
    self.settingSide.label:SetPoint(
        "LEFT",
        self.settingSide,
        "TOPLEFT",
        22,
        -10
    )
    self.settingSide.texture = self.settingSide:CreateTexture(nil, "OVERLAY")
    self.settingSide.texture:SetSize(199, 20)
    self.settingSide.texture:SetPoint("CENTER")
    self.settingSide:SetScript(
        "OnClick",
        function()
            __TS__ArrayForEach(
                parent.Entries,
                function(____, element)
                    element.settingSide.texture:Hide()
                    element.settingSide.label:SetFontObject("GameFontNormal")
                    element.container:Hide()
                end
            )
            parent.SelectedFrame = self.settingSide:GetName()
            self.settingSide.label:SetFontObject("GameFontHighlight")
            self.settingSide.texture:SetAtlas("Options_List_Active", true)
            self.settingSide.texture:Show()
            self.container:Show()
        end
    )
    self.settingSide:SetScript(
        "OnEnter",
        function()
            if parent.SelectedFrame == self.settingSide:GetName() then
                return
            end
            self.settingSide.texture:SetAtlas("Options_List_Hover", true)
            self.settingSide.texture:Show()
        end
    )
    self.settingSide:SetScript(
        "OnLeave",
        function()
            if parent.SelectedFrame == self.settingSide:GetName() then
                return
            end
            self.settingSide.texture:Hide()
        end
    )
    if parent.SelectedFrame == "" or not parent.SelectedFrame then
        parent.SelectedFrame = self.settingSide:GetName()
        self.settingSide.label:SetFontObject("GameFontHighlight")
        self.settingSide.texture:SetAtlas("Options_List_Active", true)
        self.settingSide.texture:Show()
        self.container:Show()
    end
    listPositionY = listPositionY - 22
end
function SettingFrame.prototype.createCheckBox(self, container, data)
    local r = math.random(0, 100000)
    local name = ((("CheckBox_" .. container:GetName()) .. "_") .. data.name) .. tostring(r)
    local baseFrame = CreateFrame("Frame", "Base_" .. name, container.ScrollBox.ScrollTarget)
    baseFrame:SetSize(635, 26)
    baseFrame:SetPoint(
        "TOPLEFT",
        container.ScrollBox.ScrollTarget,
        "TOPLEFT",
        self.containerPositionX,
        self.containerPositionY
    )
    baseFrame.title = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    baseFrame.title:SetText(data.name)
    baseFrame.title:SetJustifyH("LEFT")
    baseFrame.title:SetPoint("TOPLEFT", 7, -7)
    baseFrame.checkBox = CreateFrame("CheckButton", name, baseFrame, "SettingsCheckBoxTemplate")
    baseFrame.checkBox:SetSize(30, 29)
    baseFrame.checkBox:Show()
    baseFrame.checkBox:SetPoint(
        "TOPLEFT",
        baseFrame,
        "TOPLEFT",
        210,
        2
    )
    baseFrame.checkBox:SetChecked(data.value)
    if data.tooltip then
        baseFrame.Tooltip = CreateFrame("Frame", "Tooltip_" .. name, UIParent)
        baseFrame.Tooltip:SetSize(900, 80)
        baseFrame.Tooltip:SetFrameLevel(10000)
        baseFrame.Tooltip:SetPoint(
            "BOTTOMLEFT",
            container,
            "BOTTOMLEFT",
            -215,
            -85
        )
        baseFrame.Tooltip.Text = baseFrame.Tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        baseFrame.Tooltip.Text:SetText(data.tooltip)
        baseFrame.Tooltip.Text:SetJustifyH("LEFT")
        baseFrame.Tooltip.Text:SetWidth(900)
        baseFrame.Tooltip.Text:SetWordWrap(true)
        baseFrame.Tooltip.Text:SetPoint(
            "TOPLEFT",
            baseFrame.Tooltip,
            "TOPLEFT",
            10,
            -10
        )
        baseFrame.Tooltip:Hide()
        baseFrame:SetScript(
            "OnEnter",
            function()
                baseFrame.Tooltip:Show()
            end
        )
        baseFrame:SetScript(
            "OnLeave",
            function()
                baseFrame.Tooltip:Hide()
            end
        )
    end
    baseFrame.checkBox:SetScript(
        "OnClick",
        function()
            data.value = baseFrame.checkBox:GetChecked()
            __TS__ArrayForEach(
                ravn.modernConfig.RavnSetting.lists,
                function(____, list)
                    local setting = __TS__ArrayFind(
                        list.settings,
                        function(____, x) return x.id == data.id end
                    )
                    if setting then
                        setting.value = data.value
                    end
                end
            )
            ravn.modernConfig:SaveConfig()
        end
    )
    self.containerPositionY = self.containerPositionY + -35
    return baseFrame
end
function SettingFrame.prototype.createMacro(self, container, data)
    local r = math.random(0, 100000)
    local choices = data.choices
    local name = ((("Macro" .. container:GetName()) .. "_") .. data.name) .. tostring(r)
    local baseFrame = CreateFrame("Frame", "Base_" .. name, container.ScrollBox.ScrollTarget)
    baseFrame:SetSize(635, 26)
    baseFrame:SetPoint(
        "TOPLEFT",
        container.ScrollBox.ScrollTarget,
        "TOPLEFT",
        self.containerPositionX,
        self.containerPositionY
    )
    baseFrame.title = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    baseFrame.title:SetText(data.name)
    baseFrame.title:SetJustifyH("LEFT")
    baseFrame.title:SetPoint("TOPLEFT", 7, -7)
    baseFrame.icon = baseFrame:CreateTexture(nil, "OVERLAY")
    baseFrame.icon:SetSize(25, 25)
    baseFrame.icon:SetTexture(GetSpellTexture(data.spellId))
    baseFrame.icon:SetPoint(
        "RIGHT",
        baseFrame.title,
        "LEFT",
        -10,
        0
    )
    if #data.choices > 0 then
        local function modernCreateMacro(general)
            local name = Spell.getName(data.spellId) or "Spell not found"
            local body = data.macroText
            local source = baseFrame.Macro.Button.Text:GetText()
            if source == "< unit >" or source == "<unit>" then
                source = "target"
            end
            body = __TS__StringReplace(body, "<unit>", source)
            body = __TS__StringReplace(body, "<types>", source)
            local ____general_11
            if general then
                ____general_11 = nil
            else
                ____general_11 = 1
            end
            local mType = ____general_11
            local macroBody = (("#showtooltip " .. name) .. "\n") .. body
            CreateMacro(source, "INV_MISC_QUESTIONMARK", macroBody, mType)
            if MacroFrame:IsVisible() then
                MacroFrame:Hide()
                C_Timer.After(
                    0.1,
                    function()
                        MacroFrame:Show()
                    end
                )
            end
        end
        baseFrame.Macro = CreateFrame("Frame", nil, baseFrame)
        baseFrame.Macro:SetSize(100, 38)
        baseFrame.Macro:SetPoint(
            "LEFT",
            baseFrame,
            "LEFT",
            240,
            0
        )
        baseFrame.Macro.Button = CreateFrame("Button", nil, baseFrame.Macro)
        baseFrame.Macro.Button:SetSize(100, 38)
        baseFrame.Macro.Button:SetPoint(
            "CENTER",
            baseFrame.Macro,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.Button.Texture = baseFrame.Macro.Button:CreateTexture(nil, "BACKGROUND")
        baseFrame.Macro.Button.Texture:SetPoint(
            "CENTER",
            baseFrame.Macro,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.Button.Texture:SetSize(100, 38)
        baseFrame.Macro.Button.Texture:SetAtlas("charactercreate-customize-dropdownbox")
        baseFrame.Macro.Button.Text = baseFrame.Macro.Button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        baseFrame.Macro.Button.Text:SetText("< unit >")
        baseFrame.Macro.Button.Text:SetPoint(
            "CENTER",
            baseFrame.Macro.Button,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.IncrementButton = CreateFrame("Button", nil, baseFrame.Macro)
        baseFrame.Macro.IncrementButton:SetSize(32, 32)
        baseFrame.Macro.IncrementButton:SetPoint(
            "RIGHT",
            baseFrame.Macro,
            "RIGHT",
            30,
            0
        )
        baseFrame.Macro.IncrementButton.Texture = baseFrame.Macro.IncrementButton:CreateTexture(nil, "BACKGROUND")
        baseFrame.Macro.IncrementButton.Texture:SetPoint(
            "CENTER",
            baseFrame.Macro.IncrementButton,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.IncrementButton.Texture:SetSize(32, 32)
        baseFrame.Macro.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton")
        baseFrame.Macro.DecrementButton = CreateFrame("Button", nil, baseFrame.Macro)
        baseFrame.Macro.DecrementButton:SetSize(32, 32)
        baseFrame.Macro.DecrementButton:SetPoint(
            "LEFT",
            baseFrame.Macro,
            "LEFT",
            -30,
            0
        )
        baseFrame.Macro.DecrementButton.Texture = baseFrame.Macro.DecrementButton:CreateTexture(nil, "BACKGROUND")
        baseFrame.Macro.DecrementButton.Texture:SetPoint(
            "CENTER",
            baseFrame.Macro.DecrementButton,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.DecrementButton.Texture:SetSize(32, 32)
        baseFrame.Macro.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton")
        baseFrame.Macro.DecrementButton:SetScript(
            "OnMouseDown",
            function()
                baseFrame.Macro.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton-down")
            end
        )
        baseFrame.Macro.DecrementButton:SetScript(
            "OnMouseUp",
            function()
                baseFrame.Macro.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton")
            end
        )
        baseFrame.Macro.IncrementButton:SetScript(
            "OnMouseDown",
            function()
                baseFrame.Macro.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton-down")
            end
        )
        baseFrame.Macro.IncrementButton:SetScript(
            "OnMouseUp",
            function()
                baseFrame.Macro.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton")
            end
        )
        baseFrame.Macro.DecrementButton:SetScript(
            "OnClick",
            function()
                local index = __TS__ArrayIndexOf(
                    choices,
                    baseFrame.Macro.Button.Text:GetText()
                )
                if index == 0 then
                    index = #choices - 1
                else
                    index = index - 1
                end
                baseFrame.Macro.Button.Text:SetText(choices[index + 1])
            end
        )
        baseFrame.Macro.IncrementButton:SetScript(
            "OnClick",
            function()
                local index = __TS__ArrayIndexOf(
                    choices,
                    baseFrame.Macro.Button.Text:GetText()
                )
                if index == #choices - 1 then
                    index = 0
                else
                    index = index + 1
                end
                baseFrame.Macro.Button.Text:SetText(choices[index + 1])
            end
        )
        baseFrame.Macro.BtnGeneral = CreateFrame("Button", nil, baseFrame.Macro)
        baseFrame.Macro.BtnGeneral:SetSize(105, 38)
        baseFrame.Macro.BtnGeneral:SetPoint(
            "CENTER",
            baseFrame.Macro,
            "CENTER",
            150,
            0
        )
        baseFrame.Macro.BtnGeneral.Texture = baseFrame.Macro.BtnGeneral:CreateTexture(nil, "BACKGROUND")
        baseFrame.Macro.BtnGeneral.Texture:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnGeneral,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnGeneral.Texture:SetSize(105, 38)
        baseFrame.Macro.BtnGeneral.Texture:SetAtlas("charactercreate-customize-dropdownbox")
        baseFrame.Macro.BtnGeneral.Text = baseFrame.Macro.BtnGeneral:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        baseFrame.Macro.BtnGeneral.Text:SetText("General Macro")
        baseFrame.Macro.BtnGeneral.Text:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnGeneral,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnClass = CreateFrame("Button", nil, baseFrame.Macro)
        baseFrame.Macro.BtnClass:SetSize(105, 38)
        baseFrame.Macro.BtnClass:SetPoint(
            "CENTER",
            baseFrame.Macro,
            "CENTER",
            260,
            0
        )
        baseFrame.Macro.BtnClass.Texture = baseFrame.Macro.BtnClass:CreateTexture(nil, "BACKGROUND")
        baseFrame.Macro.BtnClass.Texture:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnClass,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnClass.Texture:SetSize(105, 38)
        baseFrame.Macro.BtnClass.Texture:SetAtlas("charactercreate-customize-dropdownbox")
        baseFrame.Macro.BtnClass.Text = baseFrame.Macro.BtnClass:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        baseFrame.Macro.BtnClass.Text:SetText("Class Macro")
        baseFrame.Macro.BtnClass.Text:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnClass,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnEnter",
            function()
                baseFrame.Macro.BtnClass.Texture:SetAtlas("charactercreate-customize-dropdownbox-open")
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnLeave",
            function()
                baseFrame.Macro.BtnClass.Texture:SetAtlas("charactercreate-customize-dropdownbox")
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnMouseDown",
            function()
                baseFrame.Macro.BtnClass.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnClass,
                    "CENTER",
                    2,
                    -2
                )
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnMouseUp",
            function()
                baseFrame.Macro.BtnClass.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnClass,
                    "CENTER",
                    0,
                    0
                )
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnEnter",
            function()
                baseFrame.Macro.BtnGeneral.Texture:SetAtlas("charactercreate-customize-dropdownbox-open")
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnLeave",
            function()
                baseFrame.Macro.BtnGeneral.Texture:SetAtlas("charactercreate-customize-dropdownbox")
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnMouseDown",
            function()
                baseFrame.Macro.BtnGeneral.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnGeneral,
                    "CENTER",
                    2,
                    -2
                )
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnMouseUp",
            function()
                baseFrame.Macro.BtnGeneral.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnGeneral,
                    "CENTER",
                    0,
                    0
                )
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnClick",
            function()
                modernCreateMacro(false)
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnClick",
            function()
                modernCreateMacro(true)
            end
        )
    else
        local function modernCreateMacro(general)
            local name = Spell.getName(data.spellId) or "Spell not found"
            local body = data.macroText
            local ____general_12
            if general then
                ____general_12 = nil
            else
                ____general_12 = 1
            end
            local mType = ____general_12
            local macroBody = (("#showtooltip " .. name) .. "\n") .. body
            CreateMacro(name, "INV_MISC_QUESTIONMARK", macroBody, mType)
            if MacroFrame:IsVisible() then
                MacroFrame:Hide()
                C_Timer.After(
                    0.1,
                    function()
                        MacroFrame:Show()
                    end
                )
            end
        end
        baseFrame.Macro = CreateFrame("Frame", nil, baseFrame)
        baseFrame.Macro:SetSize(100, 38)
        baseFrame.Macro:SetPoint(
            "LEFT",
            baseFrame,
            "LEFT",
            240,
            0
        )
        baseFrame.Macro.BtnGeneral = CreateFrame("Button", nil, baseFrame.Macro)
        baseFrame.Macro.BtnGeneral:SetSize(200, 38)
        baseFrame.Macro.BtnGeneral:SetPoint(
            "CENTER",
            baseFrame.Macro,
            "CENTER",
            15,
            0
        )
        baseFrame.Macro.BtnGeneral.Texture = baseFrame.Macro.BtnGeneral:CreateTexture(nil, "BACKGROUND")
        baseFrame.Macro.BtnGeneral.Texture:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnGeneral,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnGeneral.Texture:SetSize(200, 38)
        baseFrame.Macro.BtnGeneral.Texture:SetAtlas("charactercreate-customize-dropdownbox")
        baseFrame.Macro.BtnGeneral.Text = baseFrame.Macro.BtnGeneral:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        baseFrame.Macro.BtnGeneral.Text:SetText("General Macro")
        baseFrame.Macro.BtnGeneral.Text:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnGeneral,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnClass = CreateFrame("Button", nil, baseFrame.Macro)
        baseFrame.Macro.BtnClass:SetSize(200, 38)
        baseFrame.Macro.BtnClass:SetPoint(
            "CENTER",
            baseFrame.Macro,
            "CENTER",
            220,
            0
        )
        baseFrame.Macro.BtnClass.Texture = baseFrame.Macro.BtnClass:CreateTexture(nil, "BACKGROUND")
        baseFrame.Macro.BtnClass.Texture:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnClass,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnClass.Texture:SetSize(200, 38)
        baseFrame.Macro.BtnClass.Texture:SetAtlas("charactercreate-customize-dropdownbox")
        baseFrame.Macro.BtnClass.Text = baseFrame.Macro.BtnClass:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        baseFrame.Macro.BtnClass.Text:SetText("Class Macro")
        baseFrame.Macro.BtnClass.Text:SetPoint(
            "CENTER",
            baseFrame.Macro.BtnClass,
            "CENTER",
            0,
            0
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnEnter",
            function()
                baseFrame.Macro.BtnClass.Texture:SetAtlas("charactercreate-customize-dropdownbox-open")
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnLeave",
            function()
                baseFrame.Macro.BtnClass.Texture:SetAtlas("charactercreate-customize-dropdownbox")
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnMouseDown",
            function()
                baseFrame.Macro.BtnClass.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnClass,
                    "CENTER",
                    2,
                    -2
                )
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnMouseUp",
            function()
                baseFrame.Macro.BtnClass.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnClass,
                    "CENTER",
                    0,
                    0
                )
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnEnter",
            function()
                baseFrame.Macro.BtnGeneral.Texture:SetAtlas("charactercreate-customize-dropdownbox-open")
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnLeave",
            function()
                baseFrame.Macro.BtnGeneral.Texture:SetAtlas("charactercreate-customize-dropdownbox")
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnMouseDown",
            function()
                baseFrame.Macro.BtnGeneral.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnGeneral,
                    "CENTER",
                    2,
                    -2
                )
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnMouseUp",
            function()
                baseFrame.Macro.BtnGeneral.Text:SetPoint(
                    "CENTER",
                    baseFrame.Macro.BtnGeneral,
                    "CENTER",
                    0,
                    0
                )
            end
        )
        baseFrame.Macro.BtnClass:SetScript(
            "OnClick",
            function()
                modernCreateMacro(false)
            end
        )
        baseFrame.Macro.BtnGeneral:SetScript(
            "OnClick",
            function()
                modernCreateMacro(true)
            end
        )
    end
    if data.tooltip then
        baseFrame.Tooltip = CreateFrame("Frame", "Tooltip_" .. name, UIParent)
        baseFrame.Tooltip:SetSize(900, 80)
        baseFrame.Tooltip:SetFrameLevel(10000)
        baseFrame.Tooltip:SetPoint(
            "BOTTOMLEFT",
            container,
            "BOTTOMLEFT",
            -215,
            -85
        )
        baseFrame.Tooltip.Text = baseFrame.Tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        baseFrame.Tooltip.Text:SetText(data.tooltip)
        baseFrame.Tooltip.Text:SetJustifyH("LEFT")
        baseFrame.Tooltip.Text:SetWidth(900)
        baseFrame.Tooltip.Text:SetWordWrap(true)
        baseFrame.Tooltip.Text:SetPoint(
            "TOPLEFT",
            baseFrame.Tooltip,
            "TOPLEFT",
            10,
            -10
        )
        baseFrame.Tooltip:Hide()
        baseFrame:SetScript(
            "OnEnter",
            function()
                baseFrame.Tooltip:Show()
            end
        )
        baseFrame:SetScript(
            "OnLeave",
            function()
                baseFrame.Tooltip:Hide()
            end
        )
    end
    self.containerPositionY = self.containerPositionY + -35
    return baseFrame
end
function SettingFrame.prototype.createSlider(self, container, data)
    local r = math.random(0, 100000)
    local name = ((("Slider_" .. container:GetName()) .. "_") .. data.name) .. tostring(r)
    local baseFrame = CreateFrame("Frame", "Base_" .. name, container.ScrollBox.ScrollTarget)
    baseFrame:SetSize(635, 26)
    baseFrame:SetPoint(
        "TOPLEFT",
        container.ScrollBox.ScrollTarget,
        "TOPLEFT",
        self.containerPositionX,
        self.containerPositionY
    )
    baseFrame.title = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    baseFrame.title:SetText(data.name)
    baseFrame.title:SetJustifyH("LEFT")
    baseFrame.title:SetPoint("TOPLEFT", 7, -7)
    baseFrame.SliderWithSteppers = CreateFrame("Frame", name, baseFrame, "MinimalSliderWithSteppersTemplate")
    baseFrame.SliderWithSteppers:SetSize(280, 26)
    baseFrame.SliderWithSteppers:SetPoint(
        "TOPLEFT",
        baseFrame,
        "TOPLEFT",
        210,
        2
    )
    baseFrame.SliderWithSteppers.tooltip = data.tooltip
    baseFrame.SliderWithSteppers.Slider:SetMinMaxValues(data.minValues, data.maxValues)
    baseFrame.SliderWithSteppers.Slider:SetValue(data.value)
    baseFrame.SliderWithSteppers.Slider:SetValueStep(data.step)
    baseFrame.SliderWithSteppers.RightText:SetText(data.value)
    baseFrame.SliderWithSteppers.RightText:Show()
    baseFrame.SliderWithSteppers.Slider:SetScript(
        "OnValueChanged",
        function()
            local rounded = self:simpleRound(
                baseFrame.SliderWithSteppers.Slider:GetValue(),
                2
            )
            data.value = rounded
            baseFrame.SliderWithSteppers.RightText:SetText(data.value)
            __TS__ArrayForEach(
                ravn.modernConfig.RavnSetting.lists,
                function(____, list)
                    local setting = __TS__ArrayFind(
                        list.settings,
                        function(____, x) return x.id == data.id end
                    )
                    if setting then
                        setting.value = data.value
                    end
                end
            )
            ravn.modernConfig:SaveConfig()
        end
    )
    if data.tooltip then
        baseFrame.Tooltip = CreateFrame("Frame", "Tooltip_" .. name, UIParent)
        baseFrame.Tooltip:SetSize(900, 80)
        baseFrame.Tooltip:SetFrameLevel(10000)
        baseFrame.Tooltip:SetPoint(
            "BOTTOMLEFT",
            container,
            "BOTTOMLEFT",
            -215,
            -85
        )
        baseFrame.Tooltip.Text = baseFrame.Tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        baseFrame.Tooltip.Text:SetText(data.tooltip)
        baseFrame.Tooltip.Text:SetJustifyH("LEFT")
        baseFrame.Tooltip.Text:SetWidth(900)
        baseFrame.Tooltip.Text:SetWordWrap(true)
        baseFrame.Tooltip.Text:SetPoint(
            "TOPLEFT",
            baseFrame.Tooltip,
            "TOPLEFT",
            10,
            -10
        )
        baseFrame.Tooltip:Hide()
        baseFrame:SetScript(
            "OnEnter",
            function()
                baseFrame.Tooltip:Show()
            end
        )
        baseFrame:SetScript(
            "OnLeave",
            function()
                baseFrame.Tooltip:Hide()
            end
        )
    end
    self.containerPositionY = self.containerPositionY + -35
    return baseFrame
end
function SettingFrame.prototype.createCheckboxedSlider(self, container, data)
    local r = math.random(0, 100000)
    local name = ((("CheckboxSlider_" .. container:GetName()) .. "_") .. data.name) .. tostring(r)
    local baseFrame = CreateFrame("Frame", "Base_" .. name, container.ScrollBox.ScrollTarget)
    baseFrame:SetSize(635, 26)
    baseFrame:SetPoint(
        "TOPLEFT",
        container.ScrollBox.ScrollTarget,
        "TOPLEFT",
        self.containerPositionX,
        self.containerPositionY
    )
    baseFrame.title = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    baseFrame.title:SetText(data.name)
    baseFrame.title:SetJustifyH("LEFT")
    baseFrame.title:SetPoint("TOPLEFT", 7, -7)
    baseFrame.checkBox = CreateFrame("CheckButton", name, baseFrame, "SettingsCheckBoxTemplate")
    baseFrame.checkBox:SetSize(30, 29)
    baseFrame.checkBox:Show()
    baseFrame.checkBox:SetPoint(
        "TOPLEFT",
        baseFrame,
        "TOPLEFT",
        210,
        2
    )
    baseFrame.checkBox.tooltip = data.tooltip
    baseFrame.checkBox:SetChecked(data.enabled)
    baseFrame.SliderWithSteppers = CreateFrame("Frame", name, baseFrame, "MinimalSliderWithSteppersTemplate")
    baseFrame.SliderWithSteppers:SetSize(214, 26)
    baseFrame.SliderWithSteppers:SetPoint(
        "TOPLEFT",
        baseFrame.checkBox,
        "TOPLEFT",
        34,
        -1
    )
    baseFrame.SliderWithSteppers.tooltip = data.tooltip
    baseFrame.SliderWithSteppers.Slider:SetMinMaxValues(data.minValues, data.maxValues)
    baseFrame.SliderWithSteppers.Slider:SetValue(data.value)
    baseFrame.SliderWithSteppers.Slider:SetValueStep(data.step)
    if data.isAutoToggle and data.value == 0 then
        baseFrame.SliderWithSteppers.RightText:SetText("Auto")
    else
        baseFrame.SliderWithSteppers.RightText:SetText(data.value)
    end
    baseFrame.SliderWithSteppers.RightText:Show()
    baseFrame.SliderWithSteppers.RightText:SetTextColor(1, 0.82, 0, 1)
    baseFrame.checkBox:SetScript(
        "OnClick",
        function()
            data.enabled = baseFrame.checkBox:GetChecked()
            if data.enabled then
                baseFrame.SliderWithSteppers.Slider:Enable()
                baseFrame.SliderWithSteppers.RightText:SetTextColor(1, 0.82, 0, 1)
            else
                baseFrame.SliderWithSteppers.Slider:Disable()
                baseFrame.SliderWithSteppers.RightText:SetTextColor(0.5, 0.5, 0.5, 1)
            end
            __TS__ArrayForEach(
                ravn.modernConfig.RavnSetting.lists,
                function(____, list)
                    local setting = __TS__ArrayFind(
                        list.settings,
                        function(____, x) return x.id == data.id end
                    )
                    if setting then
                        setting.enabled = data.enabled
                    end
                end
            )
            ravn.modernConfig:SaveConfig()
        end
    )
    baseFrame.SliderWithSteppers.Slider:SetScript(
        "OnValueChanged",
        function()
            local rounded = self:simpleRound(
                baseFrame.SliderWithSteppers.Slider:GetValue(),
                1
            )
            data.value = rounded
            __TS__ArrayForEach(
                ravn.modernConfig.RavnSetting.lists,
                function(____, list)
                    local setting = __TS__ArrayFind(
                        list.settings,
                        function(____, x) return x.id == data.id end
                    )
                    if setting then
                        setting.value = data.value
                    end
                end
            )
            ravn.modernConfig:SaveConfig()
            if data.isAutoToggle and data.value == 0 then
                baseFrame.SliderWithSteppers.RightText:SetText("Auto")
            else
                baseFrame.SliderWithSteppers.RightText:SetText(data.value)
            end
        end
    )
    if not baseFrame.checkBox:GetChecked() then
        baseFrame.SliderWithSteppers.Slider:Disable()
        baseFrame.SliderWithSteppers.RightText:SetTextColor(0.5, 0.5, 0.5, 1)
    end
    if data.tooltip then
        baseFrame.Tooltip = CreateFrame("Frame", "Tooltip_" .. name, UIParent)
        baseFrame.Tooltip:SetSize(900, 80)
        baseFrame.Tooltip:SetFrameLevel(10000)
        baseFrame.Tooltip:SetPoint(
            "BOTTOMLEFT",
            container,
            "BOTTOMLEFT",
            -215,
            -85
        )
        baseFrame.Tooltip.Text = baseFrame.Tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        baseFrame.Tooltip.Text:SetText(data.tooltip)
        baseFrame.Tooltip.Text:SetJustifyH("LEFT")
        baseFrame.Tooltip.Text:SetWidth(900)
        baseFrame.Tooltip.Text:SetWordWrap(true)
        baseFrame.Tooltip.Text:SetPoint(
            "TOPLEFT",
            baseFrame.Tooltip,
            "TOPLEFT",
            10,
            -10
        )
        baseFrame.Tooltip:Hide()
        baseFrame:SetScript(
            "OnEnter",
            function()
                baseFrame.Tooltip:Show()
            end
        )
        baseFrame:SetScript(
            "OnLeave",
            function()
                baseFrame.Tooltip:Hide()
            end
        )
    end
    self.containerPositionY = self.containerPositionY + -35
    return baseFrame
end
function SettingFrame.prototype.createDropDown(self, container, data)
    local r = math.random(0, 100000)
    local name = ((("Dropdown_" .. container:GetName()) .. "_") .. data.name) .. tostring(r)
    local baseFrame = CreateFrame("Frame", "Base_" .. name, container.ScrollBox.ScrollTarget)
    baseFrame:SetSize(635, 26)
    local dropDownPosX = self.containerPositionX
    baseFrame:SetPoint(
        "TOPLEFT",
        container.ScrollBox.ScrollTarget,
        "TOPLEFT",
        dropDownPosX,
        self.containerPositionY
    )
    baseFrame.title = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    baseFrame.title:SetText(data.name)
    baseFrame.title:SetJustifyH("LEFT")
    baseFrame.title:SetPoint("TOPLEFT", 7, -7)
    baseFrame.DropDown = CreateFrame("Frame", nil, baseFrame)
    baseFrame.DropDown:SetSize(223, 38)
    baseFrame.DropDown:SetPoint(
        "LEFT",
        baseFrame,
        "LEFT",
        250,
        0
    )
    baseFrame.DropDown.Button = CreateFrame("Button", nil, baseFrame.DropDown)
    baseFrame.DropDown.Button:SetSize(250, 38)
    baseFrame.DropDown.Button:SetPoint(
        "CENTER",
        baseFrame.DropDown,
        "CENTER",
        0,
        0
    )
    baseFrame.DropDown.Button.Texture = baseFrame.DropDown.Button:CreateTexture(nil, "BACKGROUND")
    baseFrame.DropDown.Button.Texture:SetPoint(
        "CENTER",
        baseFrame.DropDown,
        "CENTER",
        0,
        0
    )
    baseFrame.DropDown.Button.Texture:SetSize(250, 38)
    baseFrame.DropDown.Button.Texture:SetAtlas("charactercreate-customize-dropdownbox")
    baseFrame.DropDown.Button.Text = baseFrame.DropDown.Button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    baseFrame.DropDown.Button.Text:SetText(data.value)
    baseFrame.DropDown.Button.Text:SetPoint(
        "CENTER",
        baseFrame.DropDown.Button,
        "CENTER",
        0,
        0
    )
    baseFrame.DropDown.IncrementButton = CreateFrame("Button", nil, baseFrame.DropDown)
    baseFrame.DropDown.IncrementButton:SetSize(32, 32)
    baseFrame.DropDown.IncrementButton:SetPoint(
        "RIGHT",
        baseFrame.DropDown,
        "RIGHT",
        40,
        0
    )
    baseFrame.DropDown.IncrementButton.Texture = baseFrame.DropDown.IncrementButton:CreateTexture(nil, "BACKGROUND")
    baseFrame.DropDown.IncrementButton.Texture:SetPoint(
        "CENTER",
        baseFrame.DropDown.IncrementButton,
        "CENTER",
        0,
        0
    )
    baseFrame.DropDown.IncrementButton.Texture:SetSize(32, 32)
    baseFrame.DropDown.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton")
    baseFrame.DropDown.DecrementButton = CreateFrame("Button", nil, baseFrame.DropDown)
    baseFrame.DropDown.DecrementButton:SetSize(32, 32)
    baseFrame.DropDown.DecrementButton:SetPoint(
        "LEFT",
        baseFrame.DropDown,
        "LEFT",
        -40,
        0
    )
    baseFrame.DropDown.DecrementButton.Texture = baseFrame.DropDown.DecrementButton:CreateTexture(nil, "BACKGROUND")
    baseFrame.DropDown.DecrementButton.Texture:SetPoint(
        "CENTER",
        baseFrame.DropDown.DecrementButton,
        "CENTER",
        0,
        0
    )
    baseFrame.DropDown.DecrementButton.Texture:SetSize(32, 32)
    baseFrame.DropDown.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton")
    baseFrame.DropDown.DecrementButton:SetScript(
        "OnMouseDown",
        function()
            baseFrame.DropDown.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton-down")
        end
    )
    baseFrame.DropDown.DecrementButton:SetScript(
        "OnMouseUp",
        function()
            baseFrame.DropDown.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton")
        end
    )
    baseFrame.DropDown.IncrementButton:SetScript(
        "OnMouseDown",
        function()
            baseFrame.DropDown.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton-down")
        end
    )
    baseFrame.DropDown.IncrementButton:SetScript(
        "OnMouseUp",
        function()
            baseFrame.DropDown.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton")
        end
    )
    baseFrame.DropDown.DecrementButton:SetScript(
        "OnClick",
        function()
            local index = __TS__ArrayIndexOf(data.choices, data.value)
            if index == 0 then
                index = #data.choices - 1
            else
                index = index - 1
            end
            data.value = data.choices[index + 1]
            __TS__ArrayForEach(
                ravn.modernConfig.RavnSetting.lists,
                function(____, list)
                    local setting = __TS__ArrayFind(
                        list.settings,
                        function(____, x) return x.id == data.id end
                    )
                    if setting then
                        setting.value = data.value
                    end
                end
            )
            ravn.modernConfig:SaveConfig()
            baseFrame.DropDown.Button.Text:SetText(data.value)
        end
    )
    baseFrame.DropDown.IncrementButton:SetScript(
        "OnClick",
        function()
            local index = __TS__ArrayIndexOf(data.choices, data.value)
            if index == #data.choices - 1 then
                index = 0
            else
                index = index + 1
            end
            data.value = data.choices[index + 1]
            baseFrame.DropDown.Button.Text:SetText(data.value)
        end
    )
    if data.tooltip then
        baseFrame.Tooltip = CreateFrame("Frame", "Tooltip_" .. name, UIParent)
        baseFrame.Tooltip:SetSize(900, 80)
        baseFrame.Tooltip:SetFrameLevel(10000)
        baseFrame.Tooltip:SetPoint(
            "BOTTOMLEFT",
            container,
            "BOTTOMLEFT",
            -215,
            -85
        )
        baseFrame.Tooltip.Text = baseFrame.Tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        baseFrame.Tooltip.Text:SetText(data.tooltip)
        baseFrame.Tooltip.Text:SetJustifyH("LEFT")
        baseFrame.Tooltip.Text:SetWidth(900)
        baseFrame.Tooltip.Text:SetWordWrap(true)
        baseFrame.Tooltip.Text:SetPoint(
            "TOPLEFT",
            baseFrame.Tooltip,
            "TOPLEFT",
            10,
            -10
        )
        baseFrame.Tooltip:Hide()
        baseFrame:SetScript(
            "OnEnter",
            function()
                baseFrame.Tooltip:Show()
            end
        )
        baseFrame:SetScript(
            "OnLeave",
            function()
                baseFrame.Tooltip:Hide()
            end
        )
    end
    self.containerPositionY = self.containerPositionY + -35
    return baseFrame
end
function SettingFrame.prototype.createSpellList(self, container, data)
    local r = math.random(0, 100000)
    local currentItems = data.currentSettings
    local baseList = data.baseList
    local IList = {}
    __TS__ArrayForEach(
        baseList,
        function(____, item)
            local ticked = __TS__ArrayIncludes(currentItems, item)
            IList[#IList + 1] = {id = item, ticked = ticked}
        end
    )
    local retFrames = {}
    __TS__ArrayForEach(
        IList,
        function(____, o)
            local name = (((("SpellList_" .. container:GetName()) .. "_") .. tostring(o.id)) .. "_") .. tostring(r)
            local listReference = data.name
            local baseFrame = CreateFrame("Frame", "Base_" .. name, container.ScrollBox.ScrollTarget)
            baseFrame:SetSize(635, 26)
            baseFrame:SetPoint(
                "TOPLEFT",
                container.ScrollBox.ScrollTarget,
                "TOPLEFT",
                self.containerPositionX,
                self.containerPositionY
            )
            baseFrame.title = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            local spellName = GetSpellInfo(o.id) or "UNK: " .. tostring(o.id)
            baseFrame.title:SetText(spellName)
            baseFrame.title:SetJustifyH("LEFT")
            baseFrame.title:SetPoint("TOPLEFT", 7, -7)
            baseFrame.icon = baseFrame:CreateTexture(nil, "OVERLAY")
            baseFrame.icon:SetSize(25, 25)
            local texture = GetSpellTexture(o.id)
            baseFrame.icon:SetTexture(texture)
            baseFrame.icon:SetPoint(
                "RIGHT",
                baseFrame.title,
                "LEFT",
                -10,
                0
            )
            baseFrame.checkBox = CreateFrame("CheckButton", name, baseFrame, "SettingsCheckBoxTemplate")
            baseFrame.checkBox:SetSize(30, 29)
            baseFrame.checkBox:Show()
            baseFrame.checkBox:SetPoint(
                "TOPLEFT",
                baseFrame,
                "TOPLEFT",
                210,
                2
            )
            baseFrame.checkBox:SetChecked(o.ticked)
            baseFrame.checkBox:SetScript(
                "OnClick",
                function()
                    local value = baseFrame.checkBox:GetChecked()
                    ravn.modernConfig:updateKickList(listReference, o.id, value)
                end
            )
            self.containerPositionY = self.containerPositionY + -35
            retFrames[#retFrames + 1] = baseFrame
        end
    )
    return retFrames
end
function SettingFrame.prototype.createStompList(self, container, data)
    self.containerPositionY = self.containerPositionY + -25
    local r = math.random(0, 100000)
    local allItems = data.baselist
    local currentItems = data.data
    __TS__ArrayForEach(
        allItems,
        function(____, element)
            if not __TS__ArrayIncludes(
                __TS__ArrayMap(
                    currentItems,
                    function(____, o) return o.id end
                ),
                element
            ) then
                currentItems[#currentItems + 1] = {id = element, stompBehavior = "AUTO"}
            end
        end
    )
    local retFrames = {}
    local function customDropDown(o)
        local currentValue = o.stompBehavior
        local r = math.random(0, 100000)
        local spellID = __TS__ArrayFind(
            IStomps.totemList,
            function(____, x) return x.objectId == o.id end
        )
        local spellName = spellID and GetSpellInfo(spellID.spellId) or "UNK"
        local name = ((("Dropdown_Stomp" .. container:GetName()) .. "_") .. spellName) .. tostring(r)
        local baseFrame = CreateFrame("Frame", "Base_" .. name, container.ScrollBox.ScrollTarget)
        baseFrame:SetSize(635, 26)
        local dropDownPosX = self.containerPositionX
        baseFrame:SetPoint(
            "TOPLEFT",
            container.ScrollBox.ScrollTarget,
            "TOPLEFT",
            dropDownPosX,
            self.containerPositionY
        )
        baseFrame.title = baseFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        baseFrame.title:SetText(spellName)
        baseFrame.title:SetJustifyH("LEFT")
        baseFrame.title:SetPoint("TOPLEFT", 7, -7)
        baseFrame.DropDown = CreateFrame("Frame", nil, baseFrame)
        baseFrame.DropDown:SetSize(223, 38)
        baseFrame.DropDown:SetPoint(
            "LEFT",
            baseFrame,
            "LEFT",
            250,
            0
        )
        if spellID then
            baseFrame.icon = baseFrame:CreateTexture(nil, "OVERLAY")
            baseFrame.icon:SetSize(25, 25)
            local texture = GetSpellTexture(spellID.spellId)
            baseFrame.icon:SetTexture(texture)
            baseFrame.icon:SetPoint(
                "RIGHT",
                baseFrame.title,
                "LEFT",
                -10,
                0
            )
        end
        baseFrame.DropDown.Button = CreateFrame("Button", nil, baseFrame.DropDown)
        baseFrame.DropDown.Button:SetSize(250, 38)
        baseFrame.DropDown.Button:SetPoint(
            "CENTER",
            baseFrame.DropDown,
            "CENTER",
            0,
            0
        )
        baseFrame.DropDown.Button.Texture = baseFrame.DropDown.Button:CreateTexture(nil, "BACKGROUND")
        baseFrame.DropDown.Button.Texture:SetPoint(
            "CENTER",
            baseFrame.DropDown,
            "CENTER",
            0,
            0
        )
        baseFrame.DropDown.Button.Texture:SetSize(250, 38)
        baseFrame.DropDown.Button.Texture:SetAtlas("charactercreate-customize-dropdownbox")
        baseFrame.DropDown.Button.Text = baseFrame.DropDown.Button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        baseFrame.DropDown.Button.Text:SetText(o.stompBehavior)
        baseFrame.DropDown.Button.Text:SetPoint(
            "CENTER",
            baseFrame.DropDown.Button,
            "CENTER",
            0,
            0
        )
        baseFrame.DropDown.IncrementButton = CreateFrame("Button", nil, baseFrame.DropDown)
        baseFrame.DropDown.IncrementButton:SetSize(32, 32)
        baseFrame.DropDown.IncrementButton:SetPoint(
            "RIGHT",
            baseFrame.DropDown,
            "RIGHT",
            40,
            0
        )
        baseFrame.DropDown.IncrementButton.Texture = baseFrame.DropDown.IncrementButton:CreateTexture(nil, "BACKGROUND")
        baseFrame.DropDown.IncrementButton.Texture:SetPoint(
            "CENTER",
            baseFrame.DropDown.IncrementButton,
            "CENTER",
            0,
            0
        )
        baseFrame.DropDown.IncrementButton.Texture:SetSize(32, 32)
        baseFrame.DropDown.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton")
        baseFrame.DropDown.DecrementButton = CreateFrame("Button", nil, baseFrame.DropDown)
        baseFrame.DropDown.DecrementButton:SetSize(32, 32)
        baseFrame.DropDown.DecrementButton:SetPoint(
            "LEFT",
            baseFrame.DropDown,
            "LEFT",
            -40,
            0
        )
        baseFrame.DropDown.DecrementButton.Texture = baseFrame.DropDown.DecrementButton:CreateTexture(nil, "BACKGROUND")
        baseFrame.DropDown.DecrementButton.Texture:SetPoint(
            "CENTER",
            baseFrame.DropDown.DecrementButton,
            "CENTER",
            0,
            0
        )
        baseFrame.DropDown.DecrementButton.Texture:SetSize(32, 32)
        baseFrame.DropDown.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton")
        baseFrame.DropDown.DecrementButton:SetScript(
            "OnMouseDown",
            function()
                baseFrame.DropDown.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton-down")
            end
        )
        baseFrame.DropDown.DecrementButton:SetScript(
            "OnMouseUp",
            function()
                baseFrame.DropDown.DecrementButton.Texture:SetAtlas("charactercreate-customize-backbutton")
            end
        )
        baseFrame.DropDown.IncrementButton:SetScript(
            "OnMouseDown",
            function()
                baseFrame.DropDown.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton-down")
            end
        )
        baseFrame.DropDown.IncrementButton:SetScript(
            "OnMouseUp",
            function()
                baseFrame.DropDown.IncrementButton.Texture:SetAtlas("charactercreate-customize-nextbutton")
            end
        )
        local choices = {
            "AUTO",
            "BOTH",
            "MELEE ONLY",
            "RANGE ONLY",
            "OFF"
        }
        baseFrame.DropDown.DecrementButton:SetScript(
            "OnClick",
            function()
                local index = __TS__ArrayIndexOf(choices, currentValue)
                if index == 0 then
                    index = #choices - 1
                else
                    index = index - 1
                end
                currentValue = choices[index + 1]
                ravn.modernConfig:updateStompList(o.id, currentValue)
                baseFrame.DropDown.Button.Text:SetText(currentValue)
            end
        )
        baseFrame.DropDown.IncrementButton:SetScript(
            "OnClick",
            function()
                local index = __TS__ArrayIndexOf(choices, currentValue)
                if index == #choices - 1 then
                    index = 0
                else
                    index = index + 1
                end
                currentValue = choices[index + 1]
                ravn.modernConfig:updateStompList(o.id, currentValue)
                baseFrame.DropDown.Button.Text:SetText(currentValue)
            end
        )
        local tooltipText = "Different modes to stomp a totem. AUTO = customized to the routine. BOTH = will always stomp the totem, MELEE ONLY = only in melee range, RANGE ONLY = only if in range, OFF : disabled"
        baseFrame.Tooltip = CreateFrame("Frame", "Tooltip_" .. name, UIParent)
        baseFrame.Tooltip:SetSize(900, 80)
        baseFrame.Tooltip:SetFrameLevel(10000)
        baseFrame.Tooltip:SetPoint(
            "BOTTOMLEFT",
            container,
            "BOTTOMLEFT",
            -215,
            -85
        )
        baseFrame.Tooltip.Text = baseFrame.Tooltip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        baseFrame.Tooltip.Text:SetText(tooltipText)
        baseFrame.Tooltip.Text:SetJustifyH("LEFT")
        baseFrame.Tooltip.Text:SetWidth(900)
        baseFrame.Tooltip.Text:SetWordWrap(true)
        baseFrame.Tooltip.Text:SetPoint(
            "TOPLEFT",
            baseFrame.Tooltip,
            "TOPLEFT",
            10,
            -10
        )
        baseFrame.Tooltip:Hide()
        baseFrame:SetScript(
            "OnEnter",
            function()
                baseFrame.Tooltip:Show()
            end
        )
        baseFrame:SetScript(
            "OnLeave",
            function()
                baseFrame.Tooltip:Hide()
            end
        )
        self.containerPositionY = self.containerPositionY + -35
        return baseFrame
    end
    __TS__ArrayForEach(
        currentItems,
        function(____, o)
            local frame = customDropDown(o)
            retFrames[#retFrames + 1] = frame
        end
    )
    return retFrames
end
function SettingFrame.prototype.SanitizeAlignment(self, baseFrame, alignment, extent)
    if not baseFrame.alignmentOverlapped and extent > baseFrame:GetVisibleExtent() then
        return 0
    end
    local centered = 0.5
    return alignment and Saturate(alignment) or centered
end
function SettingFrame.prototype.ScrollToOffset(self, baseFrame, offset, frameExtent, alignment, noInterpolation)
    alignment = self:SanitizeAlignment(baseFrame, alignment, frameExtent)
    local alignedOffset = offset + frameExtent * alignment - baseFrame:GetVisibleExtent() * alignment
    local scrollRange = baseFrame:GetDerivedScrollRange()
    if scrollRange > 0 then
        local scrollPercentage = alignedOffset / scrollRange
        baseFrame:SetScrollPercentage(scrollPercentage, noInterpolation)
    end
end
function SettingFrame.prototype.ScrollToFrame(self, baseFrame, frame, alignment, noInterpolation)
    local offset = baseFrame:SelectPointComponent(frame)
    local frameExtent = baseFrame:GetFrameExtent(frame)
    self:ScrollToOffset(
        baseFrame,
        offset,
        frameExtent,
        alignment,
        noInterpolation
    )
end
____exports.ModernMenu = __TS__Class()
local ModernMenu = ____exports.ModernMenu
ModernMenu.name = "ModernMenu"
function ModernMenu.prototype.____constructor(self, name)
    self.baseMenu = __TS__New(baseMenu, name)
    self:populateSettings()
    self:createMinimap()
end
function ModernMenu.prototype.populateSettings(self)
    __TS__ArrayForEach(
        ravn.modernConfig.RavnSetting.lists,
        function(____, list)
            if list.allowedToLaunch then
                __TS__New(SettingFrame, self, list)
            end
        end
    )
end
function ModernMenu.prototype.mmUpdatePos(self, position)
    local angle = position and math.rad(position) or math.rad(180)
    local x, y, q = math.cos(angle), math.sin(angle), 1
    if x < 0 then
        q = q + 1
    end
    if y > 0 then
        q = q + 2
    end
    local miniShape
    local quadTable = {true, true, true, true}
    local function fMiniShape(shape)
        if shape == "ROUND" then
            return {true, true, true, true}
        end
        if shape == "SQUARE" then
            return {false, false, false, false}
        end
        if shape == "CORNER-TOPLEFT" then
            return {false, false, false, true}
        end
        if shape == "CORNER-TOPRIGHT" then
            return {false, false, true, false}
        end
        if shape == "CORNER-BOTTOMLEFT" then
            return {false, true, false, false}
        end
        if shape == "CORNER-BOTTOMRIGHT" then
            return {true, false, false, false}
        end
        if shape == "SIDE-LEFT" then
            return {false, true, false, true}
        end
        if shape == "SIDE-RIGHT" then
            return {true, false, true, false}
        end
        if shape == "SIDE-TOP" then
            return {false, false, true, true}
        end
        if shape == "SIDE-BOTTOM" then
            return {true, true, false, false}
        end
        if shape == "TRICORNER-TOPLEFT" then
            return {false, true, true, true}
        end
        if shape == "TRICORNER-TOPRIGHT" then
            return {true, false, true, true}
        end
        if shape == "TRICORNER-BOTTOMLEFT" then
            return {true, true, false, true}
        end
        if shape == "TRICORNER-BOTTOMRIGHT" then
            return {true, true, true, false}
        end
        return {true, true, true, true}
    end
    if _G.GetMinimapShape then
        miniShape = _G:GetMinimapShape()
        quadTable = fMiniShape(miniShape)
    end
    local radius = 5
    local w = Minimap:GetWidth() / 2 + radius
    local h = Minimap:GetHeight() / 2 + radius
    if quadTable[q] then
        x = x * w
        y = y * h
    else
        local diagRadiusW = math.sqrt(2 * (w * w)) - 10
        local diagRadiusH = math.sqrt(2 * (h * h)) - 10
        x = math.max(
            -w,
            math.min(x * diagRadiusW, w)
        )
        y = math.max(
            -h,
            math.min(y * diagRadiusH, h)
        )
    end
    self.mm:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        x,
        y
    )
end
function ModernMenu.prototype.createMinimap(self)
    self.mm = CreateFrame("Button", nil, Minimap)
    self.mm:SetPoint("CENTER", -72.98, -17.25)
    self.mm:SetSize(45, 45)
    self.mm:Show()
    self.mm:SetFrameLevel(100)
    self.mm:SetFrameStrata("TOOLTIP")
    self.mm.texture = self.mm:CreateTexture(nil, "ARTWORK")
    self.mm.texture:SetSize(58, 57)
    self.mm.texture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    self.mm.texture:SetPoint("CENTER", self.mm)
    self.mm.texture:SetVertexColor(1, 0.5, 0.5, 1)
    self.mm.icon = self.mm:CreateTexture(nil, "BORDER")
    self.mm.icon:SetTexture("Interface\\Icons\\Inv_misc_bearcubbrown")
    self.mm.icon:SetSize(20, 20)
    self.mm.icon:SetPoint(
        "TOPLEFT",
        self.mm.texture,
        "TOPLEFT",
        6,
        -6
    )
    self.mm:SetScript(
        "OnEnter",
        function()
            self.mm.texture:SetVertexColor(1, 0.5, 0.3, 0.8)
        end
    )
    self.mm:SetScript(
        "OnLeave",
        function()
            if awful.enabled then
                self.mm.texture:SetVertexColor(0.6, 1, 0.4, 1)
            else
                self.mm.texture:SetVertexColor(1, 0.313, 0.313, 1)
            end
        end
    )
    self.mm:RegisterForClicks("AnyUp")
    self.mm:RegisterForDrag("RightButton")
    self.mm:RegisterForDrag("LeftButton")
    self.mm.isDraggingButton = false
    _G.rav1 = self.mm.icon
    _G.rav2 = self.mm.texture
    self.mm:SetScript(
        "OnClick",
        function(x, button, down)
            if button == "RightButton" then
                Script:toggleRotation()
            else
                Script:toggleMenu()
            end
        end
    )
    self.mm:SetScript(
        "OnDragStart",
        function(btn)
            self.mm:LockHighlight()
            self.mm.isMouseDown = true
            self.mm.isDraggingButton = true
            self.mm:SetScript(
                "OnUpdate",
                function()
                    local mx, my = Minimap:GetCenter()
                    local px, py = GetCursorPosition()
                    local scale = Minimap:GetEffectiveScale()
                    px, py = px / scale, py / scale
                    local pos = 225
                    pos = math.deg(math.atan2(py - my, px - mx)) % 360
                    self.mm.position = pos
                    self:mmUpdatePos(pos)
                end
            )
        end
    )
    self.mm:SetScript(
        "OnDragStop",
        function(btn)
            self.mm:SetScript("OnUpdate", nil)
            self.mm.isMouseDown = false
            self.mm.isDraggingButton = true
        end
    )
end
awful.Populate(
    {
        ["Interface.menu.modernMenu"] = ____exports,
    },
    ravn,
    getfenv(1)
)
