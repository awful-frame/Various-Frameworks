local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__New = ____lualib.__TS__New
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local ____exports = {}
local ____drawings = ravn["Drawings.drawings"]
local ravnDraw = ____drawings.ravnDraw
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____hunterSlash = ravn["Interface.SlashCommand.ClassSlash.hunterSlash"]
local HunterSlash = ____hunterSlash.HunterSlash
local ____lockSlash = ravn["Interface.SlashCommand.ClassSlash.lockSlash"]
local LockSlash = ____lockSlash.LockSlash
local ____generalSlash = ravn["Interface.SlashCommand.SlashFramework.generalSlash"]
local GeneralSlash = ____generalSlash.GeneralSlash
local ____slash = ravn["Interface.SlashCommand.slash"]
local SlashCommands = ____slash.SlashCommands
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local ____modernConfig = ravn["Interface.config.modernConfig"]
local ModernConfig = ____modernConfig.ModernConfig
local ____auditMenu = ravn["Interface.menu.auditMenu"]
local auditMenu = ____auditMenu.auditMenu
local ____modernMenu = ravn["Interface.menu.modernMenu"]
local ModernMenu = ____modernMenu.ModernMenu
local ____faking = ravn["Interrupts.faking"]
local Faking = ____faking.Faking
local ____pveLogic = ravn["PveLogic.pveLogic"]
local pveLogic = ____pveLogic.pveLogic
local ____specDetection = ravn["SpecDetection.specDetection"]
local SpecDetection = ____specDetection.SpecDetection
local ____cache = ravn["Utilities.Cache.cache"]
local Cache = ____cache.Cache
local ____InternalCooldowns = ravn["Utilities.InternalCooldowns.InternalCooldowns"]
local InternalCooldowns = ____InternalCooldowns.InternalCooldowns
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ____arena = ravn["arena.arena"]
local arena = ____arena.arena
local ____library = ravn["rotation.library"]
local Library = ____library.Library

Global.scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
awful.everyUnits = awful.List:New(
    {5},
    function(o)
        return true
    end
)
__TS__New(SlashCommands)
GeneralSlash:init()
HunterSlash:init()
LockSlash:init()
pveLogic:init()
ravn.fakeTracker = __TS__New(Faking)
awful.pveMechanics = awful.List:New(
    {5},
    function(o)
        return pveLogic:isUnitValid(o)
    end
)
awful.felHunters = awful.List:New(
    {5},
    function(o)
        return o.id == 417
    end
)
awful.gargoyles = awful.List:New(
    {5},
    function(o)
        return o.id == 27829
    end
)
ravn.modernConfig = __TS__New(ModernConfig)
Global.ModernMenu = __TS__New(ModernMenu, "Ravn Classic Menu")
Global.smallAlertFrameAnchor = Alert.createAlertFrame(150, "ravnSmall")
Global.bigAlertFrameAnchor = Alert.createAlertFrame(250, "ravnBig")
Alert.positionAlertFrame()
ravnDraw:initDrawings()
Cache:init()
InternalCooldowns:init()
SpecDetection:init()
local function draw(draw)
    ravnDraw:loop(draw)
end
awful.Draw(draw)
if awful.DevMode then
    Global.auditMenu = __TS__New(auditMenu)
end
local function ClearCaches()
    wipe(Library.libCache)
    wipe(arena.cache)
    wipe(InternalCooldowns.icdCache)
end
awful.addUpdateCallback(function()
    Queue:update()
    ClearCaches()
    Cache:updateStealthTracker()
    ravn.modernConfig:cleaning()
    ravn.modernConfig:cleaning()
    Alert.positionAlertFrame()
    if awful.enabled == false then
        return
    end
    Library:useHealthStone()
    Library:movementRecordInfo()
end)
local canSetCastValue = true
local TIME_OUT_FAKE_VALUE = 10
local function onSpellCastStop(...)
    local args = {...}
    local baseUnitID = args[3] or ""
    local guid = awful.call("UnitGUID", baseUnitID)
    if guid == awful.player.guid and awful.player.castID then
        local castGUID = args[4]
        if not __TS__ArrayIncludes(Library.lastSuccessfulCasts, castGUID) then
            if canSetCastValue then
                Library.fakeAttempt = Library.fakeAttempt + 1
                local tmp = Library.fakeAttempt
                C_Timer.After(
                    TIME_OUT_FAKE_VALUE,
                    function()
                        if Library.fakeAttempt == tmp then
                            ravnInfo("reset fake attempt count")
                            Library.fakeAttempt = 0
                        end
                    end
                )
                canSetCastValue = false
                C_Timer.After(
                    0.2,
                    function()
                        canSetCastValue = true
                    end
                )
            end
        end
    end
    local u = awful.GetObjectWithGUID(guid)
    if u and u.exists and u.isPlayer then
    end
end
local function onSpellCastSuccess(...)
    local args = {...}
    local baseUnitID = args[3] or ""
    local guid = awful.call("UnitGUID", baseUnitID)
    if guid == awful.player.guid and awful.player.castID then
        local castID = args[4]
        if castID ~= nil then
            local ____Library_lastSuccessfulCasts_0 = Library.lastSuccessfulCasts
            ____Library_lastSuccessfulCasts_0[#____Library_lastSuccessfulCasts_0 + 1] = castID
            C_Timer.After(
                1,
                function()
                    local index = __TS__ArrayIndexOf(Library.lastSuccessfulCasts, castID)
                    if index > -1 then
                        __TS__ArraySplice(Library.lastSuccessfulCasts, index, 1)
                    end
                end
            )
        end
    end
end
local function onSpellChannelSuccess(...)
    local args = {...}
    local baseUnitID = args[3] or ""
    local guid = awful.call("UnitGUID", baseUnitID)
    if guid == awful.player.guid then
        Library.lastSuccessfulChannelsStart = awful.time
    end
end
local canSetChannelValue = true
local function onSpellChannelStop(...)
    local args = {...}
    local baseUnitID = args[3] or ""
    local guid = awful.call("UnitGUID", baseUnitID)
    if guid == awful.player.guid then
        local delta = awful.time - Library.lastSuccessfulChannelsStart
        if delta < 0.7 then
            if canSetChannelValue then
                Library.fakeAttempt = Library.fakeAttempt + 1
                local tmp = Library.fakeAttempt
                canSetChannelValue = false
                C_Timer.After(
                    0.3,
                    function()
                        canSetChannelValue = true
                    end
                )
                C_Timer.After(
                    TIME_OUT_FAKE_VALUE,
                    function()
                        if Library.fakeAttempt == tmp then
                            ravnInfo("reset fake attempt count")
                            Library.fakeAttempt = 0
                        end
                    end
                )
            end
        end
    end
end
awful.addEventCallback(onSpellCastStop, "UNIT_SPELLCAST_STOP")
awful.addEventCallback(onSpellCastSuccess, "UNIT_SPELLCAST_SUCCEEDED")
awful.addEventCallback(onSpellChannelSuccess, "UNIT_SPELLCAST_CHANNEL_START")
awful.addEventCallback(onSpellChannelStop, "UNIT_SPELLCAST_CHANNEL_STOP")
awful.Populate(
    {
        ["ravn"] = ____exports,
    },
    ravn,
    getfenv(1)
)
