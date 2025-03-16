local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____geometry = ravn["Geometry.geometry"]
local Geometry = ____geometry.Geometry
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ravnPrint = ____ravnPrint.ravnPrint
local ____spell = ravn["Utilities.spell"]
local Spell = ____spell.Spell
local ____structures = ravn["Utilities.structures"]
local MACRO_TYPE = ____structures.MACRO_TYPE
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____hunterLib = ravn["rotation.hunter.hunterLib"]
local HunterLib = ____hunterLib.HunterLib
local ____hunterspells = ravn["rotation.hunter.hunterspells"]
local disengage = ____hunterspells.disengage
local ____survLib = ravn["rotation.hunter.survival.survLib"]
local survLib = ____survLib.survLib
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local SOUND = ____alerts.SOUND
local ____slashEvents = ravn["Interface.SlashCommand.SlashFramework.slashEvents"]
local SlashEvent = ____slashEvents.SlashEvent
local ____slashHandler = ravn["Interface.SlashCommand.SlashFramework.slashHandler"]
local SlashHandler = ____slashHandler.SlashHandler
local ____script = ravn["Interface.SlashCommand.script"]
local Script = ____script.Script
____exports.HunterSlash = __TS__Class()
local HunterSlash = ____exports.HunterSlash
HunterSlash.name = "HunterSlash"
__TS__ClassExtends(HunterSlash, SlashHandler)
function HunterSlash.slashCmd(self, msg)
    local args = __TS__StringSplit(msg, " ")
    local main = args[1]
    local second = args[2]
    local trigger = __TS__ArrayFind(
        self.classEvents,
        function(____, o) return o.mainArg == main end
    )
    if trigger and trigger.callback then
        trigger:callback(second)
    end
    trigger = __TS__ArrayFind(
        self.specEvents,
        function(____, o) return o.mainArg == main end
    )
    if trigger and trigger.callback then
        trigger:callback(second)
    end
end
function HunterSlash.init(self)
    if awful.player.class2 ~= WowClass.HUNTER then
        return
    end
    local trapEvent = __TS__New(
        SlashEvent,
        "Freezing Trap",
        "trap <unit>",
        SpellBook.FREEZING_TRAP,
        MACRO_TYPE.ENEMIES,
        "trap",
        self.trap,
        "Places a trap on the target. If the target is already incapacitated, it will be queued for 7 seconds."
    )
    local ____SlashHandler_classEvents_0 = SlashHandler.classEvents
    ____SlashHandler_classEvents_0[#____SlashHandler_classEvents_0 + 1] = trapEvent
    local reverse = __TS__New(
        SlashEvent,
        "Reverse disengage",
        "reverse",
        SpellBook.DISENGAGE,
        MACRO_TYPE.NONE,
        "reverse",
        self.reverse,
        "Reverse disengage forward. if you specify a unit such as \"reverse target\", it will disengage to that unit"
    )
    local ____SlashHandler_classEvents_1 = SlashHandler.classEvents
    ____SlashHandler_classEvents_1[#____SlashHandler_classEvents_1 + 1] = reverse
    self:initSurvival()
    self:initMM()
end
function HunterSlash.initSurvival(self)
    if GetSpecialization() ~= 3 then
        return
    end
    local forceSingleRota = __TS__New(
        SlashEvent,
        "Force Single Target",
        "single",
        SpellBook.EXPLOSIVE_SHOT,
        MACRO_TYPE.NONE,
        "single",
        self.forceSingle,
        "Force single target rotation"
    )
    local ____SlashHandler_specEvents_2 = SlashHandler.specEvents
    ____SlashHandler_specEvents_2[#____SlashHandler_specEvents_2 + 1] = forceSingleRota
end
function HunterSlash.initMM(self)
    if GetSpecialization() ~= 2 then
        return
    end
    local badManner = __TS__New(
        SlashEvent,
        "Bad Manner",
        "badmanner <unit>",
        SpellBook.PET_BAD_MANNER,
        MACRO_TYPE.ENEMIES,
        "badmanner",
        self.badManner,
        "Queue bad Manner the target"
    )
    local ____SlashHandler_specEvents_3 = SlashHandler.specEvents
    ____SlashHandler_specEvents_3[#____SlashHandler_specEvents_3 + 1] = badManner
end
function HunterSlash.badManner(self, sz)
    local t = Script:determineTarget(sz)
    if not IsSpellKnown(SpellBook.PET_BAD_MANNER, true) then
        return
    end
    if Spell.cd(SpellBook.PET_BAD_MANNER) > awful.gcd * 3 then
        return ravnInfo("cd bad manner")
    end
    if not t or t.friend then
        ravnPrint("Invalid Target for bad manner request", Color.RED)
        return
    else
        Alert.sendAlert(
            true,
            SpellBook.PET_BAD_MANNER,
            "Queue Bad Manner " .. t.name,
            ("(" .. t.class2) .. ")",
            SOUND.GET_CLOSE,
            1,
            Color.HUNTER,
            t.color,
            true
        )
        Queue:addToQueue(t, Queue.HUNTER_BADMANNER, 5, SpellBook.PET_BAD_MANNER)
    end
end
function HunterSlash.forceSingle(self)
    survLib.forceSingle = not survLib.forceSingle
    if survLib.forceSingle then
        ravnPrint(Color.HUNTER, "PVE Rotation set to: ", Color.LIME, "Single Target")
    else
        ravnPrint(Color.HUNTER, "PVE Rotation set to: ", Color.LIME, "Normal Mode")
    end
end
function HunterSlash.reverse(self, sz)
    if not awful.player.combat then
        return
    end
    if disengage.cd > 0 then
        return
    end
    local name = awful.player.name
    if awful.DevMode then
        local original = awful.player.rotation
        local angle = awful.player.movingDirection
        if not angle then
            return
        end
        local inverse = (angle + math.pi) % (2 * math.pi)
        FaceDirection(inverse, false)
        SendMovementHeartbeat()
        disengage:Cast()
        FaceDirection(original, false)
        SendMovementHeartbeat()
        return
    end
    HunterLib.disengageBaseAngle = nil
    local original = awful.player.rotation
    local angle = awful.player.movingDirection
    if sz == "" or not sz then
        if not angle then
            angle = original
        end
    else
        local t = Script:determineTarget(sz)
        if not t or not t.exists then
            ravnPrint("Reverse Error. Unit is not recognized", Color.HUNTER)
            return
        end
        angle = Geometry:angleBetweenUnits(awful.player, t)
    end
    if not angle then
        return
    end
    local inverse = (angle + math.pi) % (2 * math.pi)
    HunterLib.disengageBaseAngle = 0
    HunterLib.disengageBaseAngle = inverse
    Queue:addToQueue(awful.player, Queue.HUNTER_REVERSE, 0.5, SpellBook.DISENGAGE)
end
function HunterSlash.trap(self, unitStr)
    local t = Script:determineTarget(unitStr)
    if not t or t.friend then
        ravnPrint("Invalid Target for trap request", Color.RED)
        return
    else
    end
    if Spell.cd(SpellBook.FREEZING_TRAP) > 2 then
        return
    end
    if t.incapacitateDR < 0.5 then
        return
    end
    if t.immuneMagicEffects then
        return
    end
    if not t.dead and not t.friend then
        if t.ccRemains <= 0 then
            Alert.sendAlert(
                true,
                SpellBook.FREEZING_TRAP,
                "Trap " .. t.name,
                ("(" .. t.class2) .. ")",
                SOUND.GET_CLOSE,
                7,
                Color.HUNTER,
                t.color,
                true
            )
            Queue:addToQueue(t, Queue.HUNTER_TRAP, 7, SpellBook.FREEZING_TRAP)
        else
            local rem = t.ccRemains
            Alert.sendAlert(
                true,
                SpellBook.FREEZING_TRAP,
                "Queue Trap " .. t.name,
                ("(" .. t.class2) .. ")",
                SOUND.GET_CLOSE,
                rem,
                Color.HUNTER,
                t.color,
                true
            )
            Queue:addToQueue(
                t,
                Queue.HUNTER_TRAP,
                GetTime() + rem + 4,
                SpellBook.FREEZING_TRAP
            )
        end
    end
end
awful.Populate(
    {
        ["Interface.SlashCommand.ClassSlash.hunterSlash"] = ____exports,
    },
    ravn,
    getfenv(1)
)
