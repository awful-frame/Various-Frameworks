local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____awfulSpells = ravn["Utilities.Lists.awfulSpells"]
local awfulSpellInterrupts = ____awfulSpells.awfulSpellInterrupts
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____spellList = ravn["Utilities.Lists.spellList"]
local SpellList = ____spellList.SpellList
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnPrint = ____ravnPrint.ravnPrint
local ____structures = ravn["Utilities.structures"]
local MACRO_TYPE = ____structures.MACRO_TYPE
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local SOUND = ____alerts.SOUND
local ____script = ravn["Interface.SlashCommand.script"]
local Script = ____script.Script
local ____slashEvents = ravn["Interface.SlashCommand.SlashFramework.slashEvents"]
local SlashEvent = ____slashEvents.SlashEvent
local ____slashHandler = ravn["Interface.SlashCommand.SlashFramework.slashHandler"]
local SlashHandler = ____slashHandler.SlashHandler
____exports.GeneralSlash = __TS__Class()
local GeneralSlash = ____exports.GeneralSlash
GeneralSlash.name = "GeneralSlash"
__TS__ClassExtends(GeneralSlash, SlashHandler)
function GeneralSlash.slashCmd(self, msg)
    local args = __TS__StringSplit(msg, " ")
    local main = args[1]
    local second = args[2]
    local trigger = __TS__ArrayFind(
        self.generalEvents,
        function(____, o) return o.mainArg == main end
    )
    if trigger and trigger.callback then
        trigger:callback(second)
    end
end
function GeneralSlash.init(self)
    local toggle = __TS__New(
        SlashEvent,
        "Toggle rotation",
        "toggle",
        96285,
        MACRO_TYPE.NONE,
        "toggle",
        Script.toggleRotation,
        "Toggles the rotation on and off."
    )
    local ____SlashHandler_generalEvents_0 = SlashHandler.generalEvents
    ____SlashHandler_generalEvents_0[#____SlashHandler_generalEvents_0 + 1] = toggle
    local pause = __TS__New(
        SlashEvent,
        "Pause rotation",
        "pause",
        134400,
        MACRO_TYPE.NONE,
        "pause",
        self.pause,
        "Pauses the rotation for 0.75 seconds or for the amount specified like \"/ravn pause 3\" to pause for 3 secs"
    )
    local ____SlashHandler_generalEvents_1 = SlashHandler.generalEvents
    ____SlashHandler_generalEvents_1[#____SlashHandler_generalEvents_1 + 1] = pause
    local clear = __TS__New(
        SlashEvent,
        "Clear queued actions",
        "clear",
        202359,
        MACRO_TYPE.NONE,
        "clear",
        self.clear,
        "clear all queued actions"
    )
    local ____SlashHandler_generalEvents_2 = SlashHandler.generalEvents
    ____SlashHandler_generalEvents_2[#____SlashHandler_generalEvents_2 + 1] = clear
    local burst = __TS__New(
        SlashEvent,
        "Toggle burst mode",
        "burst",
        329038,
        MACRO_TYPE.NONE,
        "burst",
        self.burst,
        "Toggles burst mode on and off."
    )
    local ____SlashHandler_generalEvents_3 = SlashHandler.generalEvents
    ____SlashHandler_generalEvents_3[#____SlashHandler_generalEvents_3 + 1] = burst
    local kick = __TS__New(
        SlashEvent,
        "Manual Interrupt",
        "kick <unit>",
        __TS__ArrayFind(
            __TS__ArrayMap(
                SpellList.interrupts,
                function(____, o) return o.id end
            ),
            function(____, e) return IsPlayerSpell(e) end
        ) or SpellBook.PET_SPELL_LOCK,
        MACRO_TYPE.ENEMIES,
        "kick",
        self.manualKickUnit,
        "Kick the target and checks if it is interruptable."
    )
    local ____SlashHandler_generalEvents_4 = SlashHandler.generalEvents
    ____SlashHandler_generalEvents_4[#____SlashHandler_generalEvents_4 + 1] = kick
    local NEXT = __TS__New(
        SlashEvent,
        "Next",
        "next <types>",
        __TS__ArrayFind(
            __TS__ArrayMap(
                SpellList.interrupts,
                function(____, o) return o.id end
            ),
            function(____, e) return IsPlayerSpell(e) end
        ) or SpellBook.PET_SPELL_LOCK,
        MACRO_TYPE.SPECIAL,
        "next",
        self.nextKick,
        "determine the next kick status",
        {"HEAL", "CC", "DAMAGE", "RESET"}
    )
    local ____SlashHandler_generalEvents_5 = SlashHandler.generalEvents
    ____SlashHandler_generalEvents_5[#____SlashHandler_generalEvents_5 + 1] = NEXT
end
function GeneralSlash.arch(self)
    if not ravn.archeo then
        ravnPrint("Initialze Archeology first", Color.ORANGE)
    end
    ravn.archeo.toggled = not ravn.archeo.toggled
    if not ravn.archeo.toggled then
        awful.call("AscendStop")
    end
    Alert.sendAlert(
        false,
        0,
        "Archaeology",
        ravn.archeo.toggled and "Enabled" or "Disabled",
        nil,
        2,
        ravn.archeo.toggled and Color.LIME or Color.RED
    )
end
function GeneralSlash.trinket(self)
    local id = {201450, 201810}
    local shouldTrinket = false
    if awful.player.incapacitateRemains > 0 then
        shouldTrinket = true
    end
    if awful.player.incapacitateRemains > 0 then
        shouldTrinket = true
    end
    if awful.player.stunRemains > 0 then
        shouldTrinket = true
    end
    if awful.player.disarmed ~= 0 then
        shouldTrinket = true
    end
    if awful.player.disorientRemains > 0 then
        shouldTrinket = true
    end
    if awful.player.rootRemains > 0 then
        shouldTrinket = true
    end
    if shouldTrinket then
        if IsPlayerSpell(59752) and ({IsUsableSpell(59752)}) then
        else
            __TS__ArrayForEach(
                id,
                function(____, t)
                end
            )
        end
    end
end
function GeneralSlash.clear(self)
    wipe(Queue.queues)
    awful.SpellQueued = nil
end
function GeneralSlash.burst(self, sz)
    if awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 2 then
        if Global.burstMode == 0 then
            Alert.sendAlert(
                false,
                0,
                "Burst Delayed",
                nil,
                SOUND.BURST_ENABLED,
                2,
                Color.RED
            )
            Global.burstMode = GetTime()
        else
            Alert.sendAlert(
                false,
                0,
                "Burst Resumed",
                nil,
                nil,
                2,
                Color.LIME
            )
            Global.burstMode = 0
        end
        return
    end
    if awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 1 then
        ravn.settings.affliBurst = not ravn.settings.affliBurst
        ravn.config.affliBurst = not ravn.config.affliBurst
        if ravn.config.affliBurst then
            Alert.sendAlert(
                false,
                0,
                "Burst Enabled",
                nil,
                SOUND.BURST_ENABLED,
                2,
                Color.LIME
            )
            if Global.burstMode == 0 then
                Global.burstMode = GetTime()
            end
        else
            Alert.sendAlert(
                false,
                0,
                "Burst Disabled",
                nil,
                nil,
                2,
                Color.RED
            )
            Global.burstMode = 0
        end
        return
    end
    if sz == "on" then
        Alert.sendAlert(
            false,
            0,
            "Burst Enabled",
            nil,
            SOUND.BURST_ENABLED,
            2,
            Color.LIME
        )
        if Global.burstMode == 0 then
            Global.burstMode = GetTime()
        end
        return
    end
    if sz == "off" then
        Alert.sendAlert(
            false,
            0,
            "Burst Disabled",
            nil,
            nil,
            2,
            Color.RED
        )
        Global.burstMode = 0
        return
    end
    if Global.burstMode == 0 then
        Alert.sendAlert(
            false,
            0,
            "Burst Enabled",
            nil,
            SOUND.BURST_ENABLED,
            2,
            Color.LIME
        )
        Global.burstMode = GetTime()
    else
        Alert.sendAlert(
            false,
            0,
            "Burst Disabled",
            nil,
            nil,
            2,
            Color.RED
        )
        Global.burstMode = 0
    end
end
function GeneralSlash.nextKick(self, sz)
    local possible = {"heal", "cc", "damage", "reset"}
    if not sz then
        return
    end
    sz = string.lower(sz)
    if not sz or not __TS__ArrayIncludes(possible, sz) then
        ravnPrint(
            ((("next command error: " .. Color.RED) .. tostring(sz)) .. Color.YELLOW) .. " is not a valid argument",
            Color.YELLOW
        )
        return
    end
    if sz == "heal" then
        ravn.next = 2
        ravnPrint(("Next Kick: " .. Color.LIME) .. "HEAL", Color.YELLOW)
    end
    if sz == "cc" then
        ravn.next = 3
        ravnPrint(("Next Kick: " .. Color.LIGHT_BLUE) .. "CC", Color.YELLOW)
    end
    if sz == "damage" then
        ravn.next = 4
        ravnPrint(("Next Kick: " .. Color.RED) .. "DAMAGE", Color.YELLOW)
    elseif sz == "reset" then
        ravn.next = 1
        ravnPrint("Kick logic reset", Color.PINK)
    end
end
function GeneralSlash.pause(self, sz)
    if not sz then
        Global.pauseTimer = GetTime() + 0.75
    else
        local time = tonumber(sz)
        if time then
            Global.pauseTimer = GetTime() + time
        end
    end
end
function GeneralSlash.manualKickUnit(self, sz)
    local spell = __TS__ArrayFind(
        awfulSpellInterrupts,
        function(____, o) return IsPlayerSpell(o.id) end
    )
    if not spell then
        ravnPrint("[Manual Kick Error] No Spell detected - 1", Color.ORANGE)
        return
    end
    if not sz then
        sz = "target"
    end
    local t = Script:determineTarget(sz)
    if not t then
        ravnPrint("Manual Kick Error. Unit is not recognized")
        return
    end
    local function canOnlyBePhysicalKick(unit)
        if unit.buff(8178) then
            return true
        end
        if unit.buff(104773) then
            return true
        end
        if unit.channel and unit.channel7 then
            return true
        end
        if unit.casting and unit.casting6 then
            return true
        end
        return false
    end
    local sid = spell.id
    if not sid then
        ravnPrint("[Manual Kick Error] No Spell detected - 3", Color.ORANGE)
        return
    end
    if spell.cd > awful.buffer then
        ravnPrint("[Manual Kick Error] Spell is in CD", Color.ORANGE)
        return
    end
    if t.distance > spell.range then
        ravnPrint("[Manual Kick Error] Spell not in range", Color.ORANGE)
        return
    end
    if t.castIdEx == 0 then
        ravnPrint("[Manual Kick Error] Not  casting ", Color.ORANGE)
        return
    end
    if t.cannotBeInterrupted then
        ravnPrint("[Manual Kick Error] Kick is not interruptible", Color.ORANGE)
        return
    end
    local physical = true
    if awful.player.isRanged and awful.player.class2 ~= WowClass.HUNTER or awful.player.class2 == WowClass.DEATHKNIGHT or awful.player.class2 == WowClass.SHAMAN then
        physical = false
    end
    if not physical and canOnlyBePhysicalKick(t) then
        ravnPrint("[Manual Kick Error] Immune To Magic Kick", Color.ORANGE)
        return
    end
    if physical and t.immunePhysicalEffects then
        ravnPrint("[Manual Kick Error] Immune To Physical Damage", Color.ORANGE)
        return
    end
    if not physical and t.immuneMagicEffects then
        ravnPrint("[Manual Kick Error] Immune To Magic Damage", Color.ORANGE)
        return
    end
    if not t.los then
        ravnPrint("[Manual Kick Error] Target is not in LoS", Color.ORANGE)
    end
    if awful.player.castIdEx ~= 0 then
        local myCTL = awful.player.castTimeLeft
        local targetCTL = t.castTimeLeft
        if myCTL < targetCTL + awful.buffer then
            awful.call("SpellStopCasting")
        end
    end
    spell:Cast(t)
end
awful.Populate(
    {
        ["Interface.SlashCommand.SlashFramework.generalSlash"] = ____exports,
    },
    ravn,
    getfenv(1)
)
