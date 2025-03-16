local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ravnPrint = ____ravnPrint.ravnPrint
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____hunterSlash = ravn["Interface.SlashCommand.ClassSlash.hunterSlash"]
local HunterSlash = ____hunterSlash.HunterSlash
local ____lockSlash = ravn["Interface.SlashCommand.ClassSlash.lockSlash"]
local LockSlash = ____lockSlash.LockSlash
local ____generalSlash = ravn["Interface.SlashCommand.SlashFramework.generalSlash"]
local GeneralSlash = ____generalSlash.GeneralSlash
local ____script = ravn["Interface.SlashCommand.script"]
local Script = ____script.Script
---
-- @noSelf
____exports.SlashCommands = __TS__Class()
local SlashCommands = ____exports.SlashCommands
SlashCommands.name = "SlashCommands"
function SlashCommands.prototype.____constructor(self)
    local custom = Global:customCmd()
    if custom then
        Global.baseCmd = string.lower(custom)
        ravnPrint(((Color.YELLOW .. "Custom Slash Command: ") .. Color.ORANGE) .. Global.baseCmd)
    else
        ravnPrint(Color.YELLOW .. "If you want a custom cmd line starter, create a file called 'custom.txt' in the script folder and write your command in the first line (no space).")
    end
    _G[("SLASH_" .. Global.baseCmd) .. "1"] = "/" .. Global.baseCmd
    _G.SlashCmdList[Global.baseCmd] = self.cmdList
    ravnInfo("Slash Commands Initialized")
end
function SlashCommands.prototype.cmdList(msg, _)
    msg = string.lower(msg)
    local args = __TS__StringSplit(msg, " ")
    local secondArgument = __TS__StringSplit(msg, " ")[3]
    local slitTillEnd = __TS__StringSplit(msg, " ")
    local rest = ""
    if #slitTillEnd > 2 then
        do
            local i = 2
            while i < #slitTillEnd do
                if i == 2 then
                    rest = secondArgument
                else
                    rest = rest .. " " .. slitTillEnd[i + 1]
                end
                i = i + 1
            end
        end
    else
        if #slitTillEnd == 2 then
            rest = secondArgument
        end
    end
    if msg == "" or not msg then
        Script:toggleMenu()
    end
    GeneralSlash:slashCmd(msg)
    if awful.player.class2 == WowClass.HUNTER then
        HunterSlash:slashCmd(msg)
    end
    if awful.player.class2 == WowClass.WARLOCK then
        LockSlash:slashCmd(msg)
    end
    if not awful.DevMode then
        return
    end
    if args[1] == "dbg" then
        ravnInfo("[ --- ] Debugging [ --- ]")
        Script:debug()
    end
    if args[1] == "size" and awful.DevMode then
        local width = args[2]
        local number = tonumber(width)
        if number then
            Global.circleSize = number
            ravnInfo("Circle Size: " .. tostring(number))
        end
    end
    if args[1] == "drop" and awful.DevMode then
        ravnInfo("Dropping Debug Points")
        if args[2] == "player" then
            Script:addDebugPoint("player")
        else
            Script:addDebugPoint()
        end
    end
    if args[1] == "save" then
        ravnInfo("Saving Debug Points")
        Script:saveDebugPoints()
    end
    if args[1] == "skull" then
        local u = __TS__ArrayFind(
            awful.enemies,
            function(____, o) return o.raidTargetIndex == 8 end
        )
        if u and u.exists and not u.isUnit(awful.player) then
            u.setTarget()
        end
    end
    if args[1] == "record" then
        if args[2] == "menu" then
            Global.auditMenu:showMenu()
        end
        if args[2] == "reset" then
            Global.auditEngine:resetRecord()
        end
        if args[2] == "toggle" then
            if not Global.auditEngineStarted then
                Global:startAuditEngine()
            end
            Global.auditEngine:toggleRecord()
            if Global.auditEngine.recording then
                ravnInfo("Recording", Color.LIME, "Enabled")
            else
                ravnInfo("Recording", Color.RED, "Disabled")
            end
        end
        if args[2] == "save" then
            ravnInfo("Saving Record")
            Global.auditEngine:SaveRecord()
        end
    end
end
awful.Populate(
    {
        ["Interface.SlashCommand.slash"] = ____exports,
    },
    ravn,
    getfenv(1)
)
