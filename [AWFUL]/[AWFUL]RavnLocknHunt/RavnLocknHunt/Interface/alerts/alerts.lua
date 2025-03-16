local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__StringCharAt = ____lualib.__TS__StringCharAt
local __TS__ArraySort = ____lualib.__TS__ArraySort
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
____exports.SOUND = __TS__Class()
local SOUND = ____exports.SOUND
SOUND.name = "SOUND"
function SOUND.prototype.____constructor(self)
end
SOUND.CORK = 0
SOUND.DANGER = 1
SOUND.POSITIVE = 2
SOUND.CORK2 = 3
SOUND.GET_CLOSE = 4
SOUND.BURST_ENABLED = 5
SOUND.COUNTERSPELL = 6
____exports.Alert = {}
local Alert = ____exports.Alert
do
    local checkExistingAlerts, alertUpdate
    function checkExistingAlerts(big, message, fade)
        if big and Global.bigAlertsArray then
            do
                local i = 0
                while i < #Global.bigAlertsArray do
                    if message == Global.bigAlertsArray[i + 1].message then
                        Global.bigAlertsArray[i + 1].opacity = 1
                        Global.bigAlertsArray[i + 1].baseFrame:SetAlpha(1)
                        Global.bigAlertsArray[i + 1].fade = GetTime() + (fade or 1)
                        return true
                    end
                    i = i + 1
                end
            end
        elseif Global.smallAlertsArray ~= nil then
            do
                local i = 0
                while i < #Global.smallAlertsArray do
                    if message == Global.smallAlertsArray[i + 1].message then
                        Global.smallAlertsArray[i + 1].opacity = 1
                        Global.smallAlertsArray[i + 1].baseFrame:SetAlpha(1)
                        Global.smallAlertsArray[i + 1].fade = GetTime() + (fade or 1)
                        return true
                    end
                    i = i + 1
                end
            end
        end
        return false
    end
    function alertUpdate(base, countdown)
        local fading = base.fade or 4
        local expiration = GetTime() + math.max(4, fading)
        local frameText = base.message
        base.baseFrame:SetScript(
            "OnUpdate",
            function()
                if countdown then
                    local remainingTime = expiration - GetTime()
                    if remainingTime >= 0 then
                        local flRemainingTime = math.floor(remainingTime)
                        local message = (((frameText .. Color.WHITE) .. " ( ") .. tostring(flRemainingTime)) .. " )"
                        base.font:SetText(message)
                    end
                end
                local duration = 0.8 * GetFramerate()
                local step = 8 / duration
                local desired_size
                local ____base_isBig_9
                if base.isBig then
                    desired_size = 18
                    ____base_isBig_9 = desired_size
                else
                    desired_size = 12
                    ____base_isBig_9 = desired_size
                end
                local font = Global:GetLanguageFont()
                local size = select(
                    2,
                    base.font:GetFont()
                )
                if size < desired_size + 2 and not base.swap then
                    base.font:SetFont(font, size + step, "OUTLINE")
                elseif size > desired_size then
                    base.font:SetFont(font, size - step, "OUTLINE")
                    base.swap = true
                end
            end
        )
        C_Timer.After(
            math.max(0, fading - 0.5),
            function()
                base.baseFrame:SetScript(
                    "OnUpdate",
                    function()
                        if not base.newUpdate or base.newUpdate < GetTime() then
                            local duration = 0.7 * GetFramerate()
                            local step = 1 / duration
                            base.baseFrame:SetAlpha(math.max(0, base.opacity))
                            base.opacity = base.opacity - step
                        end
                    end
                )
            end
        )
    end
    Alert.lastSoundPlayed = 0
    local function createFontText(mt, alt, mColor, altColor)
        local str = ""
        if alt and #alt > 0 then
            local firstChar = string.sub(alt, 1, 1)
            if firstChar == "(" then
                alt = string.sub(alt, 2, -2)
            end
            local lastChar = __TS__StringCharAt(alt, #alt - 1)
            if lastChar == ")" then
                alt = string.sub(alt, 1, -2)
            end
        end
        alt = alt or ""
        mColor = mColor or awful.player.color
        str = str .. mColor
        str = str .. mt
        str = str .. Color.RESET
        if alt and #alt > 0 then
            str = str .. Color.WHITE
            str = str .. " ( "
            str = str .. alt
            str = str .. Color.WHITE
            str = str .. " )"
        end
        return str
    end
    function Alert.createAlertFrame(height, name, fontSize)
        if height == nil then
            height = 0
        end
        if fontSize == nil then
            fontSize = 12
        end
        local backdrop = {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            tileSize = 256,
            edgeFile = "Interface/FriendsFrame/UI-Toast-Border",
            tile = true,
            edgeSize = 3,
            insets = {top = 0, right = 0, left = 0, bottom = 0}
        }
        local frame = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
        frame:SetPoint("CENTER", 0, height)
        frame:SetHeight(20)
        frame:SetWidth(200)
        frame:SetMovable(true)
        frame:SetBackdrop(backdrop)
        local fontString = frame:CreateFontString(nil, "OVERLAY", nil)
        fontString:SetFont(
            Global:GetLanguageFont(),
            fontSize,
            "OUTLINE"
        )
        local displayText
        if not name then
            displayText = "Frame"
        else
            displayText = name
        end
        displayText = displayText .. " anchor"
        fontString:SetText(displayText)
        fontString:SetPoint("CENTER", 0, 0)
        frame:SetScript(
            "OnMouseUp",
            function()
                frame:StopMovingOrSizing()
                if name == "ravnBig" then
                end
                if name == "ravnSmall" then
                end
            end
        )
        frame:SetScript(
            "OnMouseDown",
            function()
                frame:StartMoving()
            end
        )
        frame:Hide()
        return frame
    end
    function Alert.positionAlertFrame()
        __TS__ArraySort(
            Global.smallAlertsArray,
            function(____, a, b)
                local ret
                if a.startTime == b.startTime and a.index and b.index then
                    ret = a.index - b.index
                else
                    ret = a.startTime - b.startTime
                end
                return ret
            end
        )
        do
            local i = 0
            while i < #Global.smallAlertsArray do
                if Global.smallAlertsArray[i + 1] then
                    Global.smallAlertsArray[i + 1].index = i
                end
                if Global.smallAlertsArray[i + 1].opacity <= 0 then
                    Global.smallAlertsArray[i + 1].baseFrame:Hide()
                    __TS__ArraySplice(Global.smallAlertsArray, i, 1)
                end
                do
                    local i = 0
                    while i < #Global.smallAlertsArray do
                        Global.smallAlertsArray[i + 1].baseFrame:SetPoint(
                            "CENTER",
                            Global.smallAlertFrameAnchor,
                            "CENTER",
                            0,
                            i * 20
                        )
                        i = i + 1
                    end
                end
                i = i + 1
            end
        end
        __TS__ArraySort(
            Global.bigAlertsArray,
            function(____, a, b)
                local ret
                if a.startTime == b.startTime and a.index and b.index then
                    ret = a.index - b.index
                else
                    ret = a.startTime - b.startTime
                end
                return ret
            end
        )
        do
            local i = 0
            while i < #Global.bigAlertsArray do
                if Global.bigAlertsArray[i + 1] then
                    Global.bigAlertsArray[i + 1].index = i
                end
                if Global.bigAlertsArray[i + 1].opacity <= 0 then
                    Global.bigAlertsArray[i + 1].baseFrame:Hide()
                    __TS__ArraySplice(Global.bigAlertsArray, i, 1)
                end
                do
                    local i = 0
                    while i < #Global.bigAlertsArray do
                        Global.bigAlertsArray[i + 1].baseFrame:SetPoint(
                            "CENTER",
                            Global.bigAlertFrameAnchor,
                            "CENTER",
                            0,
                            i * 25
                        )
                        i = i + 1
                    end
                end
                i = i + 1
            end
        end
    end
    function Alert.sendAlert(Big, textureID, mainText, altText, sound, fade, mainColor, altColor, countdown)
        if countdown == nil then
            countdown = false
        end
        if ravn.modernConfig:getMiscLegitMode() then
            return
        end
        if not Global.bigAlertFrameAnchor and Big then
            print("<never>: big alert issue")
            return
        end
        if not Global.smallAlertFrameAnchor and not Big then
            print("<never>: small alert issue")
            return
        end
        altText = altText or ""
        local alertMsg = createFontText(mainText, altText, mainColor, altColor)
        if checkExistingAlerts(Big, alertMsg, fade) == true then
            return
        end
        local rBaseFrame = CreateFrame("Frame")
        local anchor = Big and Global.bigAlertFrameAnchor or Global.smallAlertFrameAnchor
        rBaseFrame:SetPoint(
            "CENTER",
            anchor,
            "CENTER",
            0,
            20
        )
        rBaseFrame:SetHeight(125)
        rBaseFrame:SetWidth(400)
        local font = Global:GetLanguageFont()
        local rFont = rBaseFrame:CreateFontString(nil, "OVERLAY", nil)
        local ____Big_0
        if Big then
            ____Big_0 = rFont:SetFont(font, 18, "OUTLINE")
        else
            ____Big_0 = rFont:SetFont(font, 13, "OUTLINE")
        end
        rFont:SetText(alertMsg)
        rFont:SetPoint(
            "CENTER",
            rBaseFrame,
            "CENTER",
            0,
            0
        )
        local rTexture = rBaseFrame:CreateTexture(nil, "OVERLAY", nil)
        local tPath = GetSpellTexture(textureID)
        rTexture:SetTexture(tPath)
        rTexture:ClearAllPoints()
        local ____Big_1
        if Big then
            ____Big_1 = rTexture:SetHeight(22)
        else
            ____Big_1 = rTexture:SetHeight(19)
        end
        local ____Big_2
        if Big then
            ____Big_2 = rTexture:SetWidth(22)
        else
            ____Big_2 = rTexture:SetWidth(19)
        end
        local ____Big_3
        if Big then
            ____Big_3 = rTexture:SetPoint(
                "LEFT",
                rFont,
                "LEFT",
                -27,
                0
            )
        else
            ____Big_3 = rTexture:SetPoint(
                "LEFT",
                rFont,
                "LEFT",
                -25,
                0
            )
        end
        local rStart = GetTime()
        local rEnd = rStart + 2
        fade = fade or 2.5
        local alrt = {
            isBig = Big,
            font = rFont,
            baseFrame = rBaseFrame,
            startTime = rStart,
            endTime = rEnd,
            texture = rTexture,
            message = alertMsg,
            fade = fade,
            opacity = 1
        }
        if not ravn.modernConfig:getMiscDisabledSound() then
            if sound and (GetTime() - Alert.lastSoundPlayed > 0.3 or Alert.lastSoundPlayed == 0) then
                if sound == ____exports.SOUND.CORK then
                    PlaySound(8959, "Master")
                end
                if sound == ____exports.SOUND.DANGER then
                    PlaySound(34768, "Master")
                end
                if sound == ____exports.SOUND.CORK2 then
                    PlaySound(9378, "Master")
                end
                if sound == ____exports.SOUND.POSITIVE then
                    PlaySound(15273, "Master")
                end
                if sound == ____exports.SOUND.GET_CLOSE then
                    PlaySound(2005, "Master")
                end
                if sound == ____exports.SOUND.BURST_ENABLED then
                    PlaySound(32238, "Master")
                end
                if sound == 6 then
                    PlaySound(3227, "Master")
                elseif sound > 6 then
                    PlaySound(sound, "Master")
                    Alert.lastSoundPlayed = GetTime()
                end
            end
        end
        local ____Big_8
        if Big then
            local ____Global_bigAlertsArray_4 = Global.bigAlertsArray
            local ____temp_5 = #____Global_bigAlertsArray_4 + 1
            ____Global_bigAlertsArray_4[____temp_5] = alrt
            ____Big_8 = ____temp_5
        else
            local ____Global_smallAlertsArray_6 = Global.smallAlertsArray
            local ____temp_7 = #____Global_smallAlertsArray_6 + 1
            ____Global_smallAlertsArray_6[____temp_7] = alrt
            ____Big_8 = ____temp_7
        end
        alertUpdate(alrt, countdown)
    end
end
awful.Populate(
    {
        ["Interface.alerts.alerts"] = ____exports,
    },
    ravn,
    getfenv(1)
)
