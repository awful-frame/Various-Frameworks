local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
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
local ____affLib = ravn["rotation.lock.affli.affLib"]
local affLib = ____affLib.affLib
local ____demonoLib = ravn["rotation.lock.demono.demonoLib"]
local demonoLib = ____demonoLib.demonoLib
local ____lockLib = ravn["rotation.lock.lockLib"]
local lockLib = ____lockLib.lockLib
local ____lockspells = ravn["rotation.lock.lockspells"]
local deathlCoil = ____lockspells.deathlCoil
local fear = ____lockspells.fear
local spellLock = ____lockspells.spellLock
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local SOUND = ____alerts.SOUND
local ____slashEvents = ravn["Interface.SlashCommand.SlashFramework.slashEvents"]
local SlashEvent = ____slashEvents.SlashEvent
local ____slashHandler = ravn["Interface.SlashCommand.SlashFramework.slashHandler"]
local SlashHandler = ____slashHandler.SlashHandler
local ____script = ravn["Interface.SlashCommand.script"]
local Script = ____script.Script
____exports.LockSlash = __TS__Class()
local LockSlash = ____exports.LockSlash
LockSlash.name = "LockSlash"
__TS__ClassExtends(LockSlash, SlashHandler)
function LockSlash.slashCmd(self, msg)
    local args = __TS__StringSplit(msg, " ")
    local main = args[1]
    local second = args[2]
    local trigger = __TS__ArrayFind(
        self.classEvents,
        function(____, o) return o.mainArg == main end
    )
    if trigger then
        trigger:callback(second)
    end
    trigger = __TS__ArrayFind(
        self.specEvents,
        function(____, o) return o.mainArg == main end
    )
    if trigger then
        trigger:callback(second)
    end
end
function LockSlash.init(self)
    if awful.player.class2 ~= WowClass.WARLOCK then
        return
    end
    local coilEvent = __TS__New(
        SlashEvent,
        "Mortal Coil",
        "coil <unit>",
        SpellBook.DEATH_COIL,
        MACRO_TYPE.ENEMIES,
        "coil",
        self.coil,
        "Coil the unit"
    )
    local ____SlashHandler_classEvents_0 = SlashHandler.classEvents
    ____SlashHandler_classEvents_0[#____SlashHandler_classEvents_0 + 1] = coilEvent
    local fearEvent = __TS__New(
        SlashEvent,
        "Fear",
        "fear <unit>",
        SpellBook.FEAR,
        MACRO_TYPE.ENEMIES,
        "fear",
        self.sFear,
        "Fear the unit"
    )
    local ____SlashHandler_classEvents_1 = SlashHandler.classEvents
    ____SlashHandler_classEvents_1[#____SlashHandler_classEvents_1 + 1] = fearEvent
    local portEvent = __TS__New(
        SlashEvent,
        "Port",
        "port",
        SpellBook.DEMONIC_CIRCLE_TELEPORT,
        MACRO_TYPE.NONE,
        "port",
        self.port,
        "Port to your circle"
    )
    local ____SlashHandler_classEvents_2 = SlashHandler.classEvents
    ____SlashHandler_classEvents_2[#____SlashHandler_classEvents_2 + 1] = portEvent
    local petsbacks = __TS__New(
        SlashEvent,
        "Callback pet(s)",
        "petsback 4",
        SpellBook.SUMMON_FELGUARD,
        MACRO_TYPE.NONE,
        "petsback",
        self.petsback,
        "Callback pet for the number of seconds you want"
    )
    local ____SlashHandler_classEvents_3 = SlashHandler.classEvents
    ____SlashHandler_classEvents_3[#____SlashHandler_classEvents_3 + 1] = petsbacks
    local interrupt = __TS__New(
        SlashEvent,
        "Lock Kick",
        "lockkick <unit>",
        SpellBook.PET_SPELL_LOCK,
        MACRO_TYPE.ENEMIES,
        "lockkick",
        self.lockKick,
        "Interrupt the target. Press twice fast to blanket"
    )
    local ____SlashHandler_classEvents_4 = SlashHandler.classEvents
    ____SlashHandler_classEvents_4[#____SlashHandler_classEvents_4 + 1] = interrupt
    local howl = __TS__New(
        SlashEvent,
        "Howl of Terror",
        "howl <unit>",
        SpellBook.HOWL_OF_TERROR,
        MACRO_TYPE.ENEMIES,
        "howl",
        self.howl,
        "Howl of Terror - if set to no one or \"player\", it will try to hit anyone in range"
    )
    local ____SlashHandler_classEvents_5 = SlashHandler.classEvents
    ____SlashHandler_classEvents_5[#____SlashHandler_classEvents_5 + 1] = howl
    local stick = __TS__New(
        SlashEvent,
        "Stick to Unit",
        "stick <unit>",
        SpellBook.SUMMON_FELHUNTER,
        MACRO_TYPE.ENEMIES,
        "stick",
        self.stick,
        "Pet will stick to target. Do not specify a unit and call /ravn stick to cancel this feature"
    )
    local ____SlashHandler_classEvents_6 = SlashHandler.classEvents
    ____SlashHandler_classEvents_6[#____SlashHandler_classEvents_6 + 1] = stick
    local disableArmor = __TS__New(
        SlashEvent,
        "Disable Armor",
        "disablearmor",
        SpellBook.CURSE_OF_THE_ELEMENTS,
        MACRO_TYPE.NONE,
        "disablearmor",
        self.disableArmor,
        "Disable Armor"
    )
    local ____SlashHandler_classEvents_7 = SlashHandler.classEvents
    ____SlashHandler_classEvents_7[#____SlashHandler_classEvents_7 + 1] = disableArmor
    self:initDemono()
end
function LockSlash.disableArmor(self)
    lockLib.disableArmor = not lockLib.disableArmor
    if lockLib.disableArmor then
        Alert.sendAlert(
            true,
            0,
            "Armor automatism disabled",
            nil,
            SOUND.POSITIVE,
            2,
            Color.RED
        )
    else
        Alert.sendAlert(
            true,
            0,
            "Auto Armor",
            nil,
            SOUND.POSITIVE,
            2,
            Color.LIME
        )
    end
end
function LockSlash.stick(self, sz)
    if sz == "" or sz == " " then
        affLib.stickUnit = nil
        ravnPrint("Unsticking pet")
        return
    end
    local t = Script:determineTarget(sz)
    if not t or t.friend then
        ravnPrint("Lock Pet Stick Error. Unit is not recognized")
        return
    end
    if not awful.pet or not awful.pet.exists or awful.pet.dead then
        ravnPrint("Lock Pet Does not exists")
        return
    end
    if not affLib.stickUnit or affLib.stickUnit ~= t.guid then
        affLib.stickUnit = t.guid
        ravnPrint("Sticking now to unit ", t.name)
    end
end
function LockSlash.lockKick(self, sz)
    local t = Script:determineTarget(sz)
    if not t then
        ravnPrint("Lock Kick Error. Unit is not recognized")
        return
    end
    if t.class2 == WowClass.WARRIOR and t.isPlayer and awful.arena then
        ravnPrint("Lock Kick Error. Cannot kick warriors ??")
        Alert.sendAlert(
            true,
            0,
            "WHY THE FUCK DO YOU KICK WARRIORS",
            nil,
            SOUND.DANGER,
            2,
            Color.RED
        )
        return
    end
    local pet = awful.pet
    if not pet or pet.dead or not pet.exists then
        ravnPrint("Lock Kick Error. Pet is not recognized")
        return
    end
    if pet.id ~= 417 then
        ravnPrint("Lock Kick Error. Pet is not felhunter")
        return
    end
    local currentBlanket = affLib.pseudoBlanketUnit and affLib.pseudoBlanketUnit == t.guid
    if t.castIdEx == 0 and not currentBlanket and t.isDummyOrPlayer then
        ravnPrint("Lock Kick Error. unit is not casting")
        affLib.pseudoBlanketUnit = t.guid
        affLib.pseudoBlanketUnitTimer = awful.time + 0.2
        C_Timer.After(
            0.3,
            function()
                if t and awful.time > affLib.pseudoBlanketUnitTimer and affLib.pseudoBlanketUnit and t.guid == affLib.pseudoBlanketUnit then
                    affLib.pseudoBlanketUnit = nil
                end
            end
        )
        return
    end
    if t.cannotBeInterrupted and not currentBlanket then
        ravnPrint("Lock Kick Error. unit cannot be interrupted")
        return
    end
    if not spellLock:Castable(t) then
        ravnPrint("Lock Kick Error. Spell is not castable")
        return
    end
    spellLock:Cast(t)
end
function LockSlash.initDemono(self)
    local cond = awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 2
    if not cond then
        return
    end
    local ignorePull = __TS__New(
        SlashEvent,
        "Ignore Pull",
        "ignore",
        SpellBook.BANE_OF_AGONY,
        MACRO_TYPE.NONE,
        "ignore",
        self.ignorePull,
        "Ignore This Pull"
    )
    local ____SlashHandler_specEvents_8 = SlashHandler.specEvents
    ____SlashHandler_specEvents_8[#____SlashHandler_specEvents_8 + 1] = ignorePull
    local delayBurst = __TS__New(
        SlashEvent,
        "Delayed Burst",
        "delayburst",
        SpellBook.METAMORPHOSIS,
        MACRO_TYPE.NONE,
        "delayburst",
        self.delayBurst,
        "Toggle Burst"
    )
    local ____SlashHandler_specEvents_9 = SlashHandler.specEvents
    ____SlashHandler_specEvents_9[#____SlashHandler_specEvents_9 + 1] = delayBurst
    local doomGuard = __TS__New(
        SlashEvent,
        "Doom Guard",
        "doomguard",
        SpellBook.SUMMON_DOOMGUARD,
        MACRO_TYPE.NONE,
        "doomguard",
        self.doomGuard,
        "Toggle Doom Guard"
    )
    local ____SlashHandler_specEvents_10 = SlashHandler.specEvents
    ____SlashHandler_specEvents_10[#____SlashHandler_specEvents_10 + 1] = doomGuard
    local demonoAoe = __TS__New(
        SlashEvent,
        "Demono AOE/Single Toggle",
        "demonoaoe",
        SpellBook.IMMOLATE,
        MACRO_TYPE.NONE,
        "demonoaoe",
        self.demonoAoe,
        "Toggle AOE"
    )
    local ____SlashHandler_specEvents_11 = SlashHandler.specEvents
    ____SlashHandler_specEvents_11[#____SlashHandler_specEvents_11 + 1] = demonoAoe
    local demonoFelStorm = __TS__New(
        SlashEvent,
        "Felstorm",
        "felstorm",
        SpellBook.PET_FELSTORM,
        MACRO_TYPE.NONE,
        "felstorm",
        self.demonoFelStorm,
        "Toggle Felstorm"
    )
    local ____SlashHandler_specEvents_12 = SlashHandler.specEvents
    ____SlashHandler_specEvents_12[#____SlashHandler_specEvents_12 + 1] = demonoFelStorm
end
function LockSlash.demonoFelStorm(self)
    ravn.settings.demonoFelStorm = not ravn.settings.demonoFelStorm
    ravn.config.demonoFelStorm = not ravn.config.demonoFelStorm
    if ravn.config.demonoFelStorm then
        Alert.sendAlert(
            false,
            0,
            "Felstorm",
            nil,
            SOUND.POSITIVE,
            2,
            Color.LIME
        )
    else
        Alert.sendAlert(
            false,
            0,
            "Felstorm Disabled",
            nil,
            nil,
            2,
            Color.RED
        )
    end
end
function LockSlash.demonoAoe(self)
    ravn.settings.demonoAoe = not ravn.settings.demonoAoe
    ravn.config.demonoAoe = not ravn.config.demonoAoe
    if ravn.config.demonoAoe then
        Alert.sendAlert(
            false,
            0,
            "AOE",
            nil,
            SOUND.POSITIVE,
            2,
            Color.LIME
        )
    else
        Alert.sendAlert(
            false,
            0,
            "Single Target",
            nil,
            nil,
            2,
            Color.RED
        )
    end
end
function LockSlash.doomGuard(self)
    ravn.settings.useDoomGuard = not ravn.settings.useDoomGuard
    ravn.config.useDoomGuard = not ravn.config.useDoomGuard
    if ravn.config.useDoomGuard then
        Alert.sendAlert(
            false,
            0,
            "Doom Guard",
            nil,
            SOUND.POSITIVE,
            2,
            Color.LIME
        )
    else
        Alert.sendAlert(
            false,
            0,
            "No Doom Guard",
            nil,
            nil,
            2,
            Color.RED
        )
    end
end
function LockSlash.delayBurst(self)
    ravn.settings.demonoBurst = not ravn.settings.demonoBurst
    ravn.config.demonoBurst = not ravn.config.demonoBurst
    if ravn.config.demonoBurst then
        Alert.sendAlert(
            false,
            0,
            "Burst",
            nil,
            SOUND.POSITIVE,
            2,
            Color.LIME
        )
    else
        Alert.sendAlert(
            false,
            0,
            "Delayed Burst",
            nil,
            nil,
            2,
            Color.RED
        )
    end
end
function LockSlash.ignorePull(self)
    demonoLib.ignoreDbmPull = not demonoLib.ignoreDbmPull
    if demonoLib.ignoreDbmPull then
        Alert.sendAlert(
            true,
            0,
            "PULL IGNORED",
            nil,
            SOUND.CORK,
            2,
            Color.RED
        )
    else
        Alert.sendAlert(
            true,
            0,
            "PULL NOT IGNORED ANYMORE",
            nil,
            SOUND.POSITIVE,
            2,
            Color.GREEN
        )
    end
end
function LockSlash.coil(self, sz)
    if not IsPlayerSpell(SpellBook.DEATH_COIL) or deathlCoil.cd > 4 then
        return
    end
    local t = Script:determineTarget(sz)
    if not t then
        ravnPrint("Lock Coil Error. Unit is not recognized")
        return
    end
    if t.incapacitateDR == 1 or t.incapacitateDRRemains <= 4 then
        Queue:addToQueue(t, Queue.WARLOCK_COIL, 5, deathlCoil.id)
    end
end
function LockSlash.howl(self, sz)
    local special = false
    if not sz or sz == "" or string.lower(sz) == "player" then
        sz = "player"
        special = true
        print("sz", sz, "special")
    end
    local t = Script:determineTarget(sz)
    if not t then
        ravnPrint("Lock Howl Error. Unit is not recognized")
        return
    end
    Queue:addToQueue(t, Queue.WARLOCK_SCREAM, 5, SpellBook.HOWL_OF_TERROR)
    local infos = special and t.class2 or "Anyone"
    local name = special and "" or t.name
    Alert.sendAlert(
        true,
        SpellBook.HOWL_OF_TERROR,
        "Howl " .. name,
        infos,
        SOUND.GET_CLOSE,
        3,
        Color.WARLOCK,
        t.color
    )
end
function LockSlash.sFear(self, sz)
    local t = Script:determineTarget(sz)
    if not t then
        ravnPrint("Lock Fear Error. Unit is not recognized")
        return
    end
    if t.disorientDR ~= 0 or t.disorientDRRemains <= 3 then
        Queue:addToQueue(t, Queue.WARLOCK_FEAR, 5, fear.id)
        Alert.sendAlert(
            true,
            SpellBook.FEAR,
            "Fear " .. t.name,
            ("(" .. t.class2) .. ")",
            SOUND.GET_CLOSE,
            3,
            Color.WARLOCK,
            t.color
        )
    end
end
function LockSlash.port(self)
    Queue:addToQueue(awful.player, Queue.WARLOCK_PORT, 5, SpellBook.DEMONIC_CIRCLE_TELEPORT)
end
function LockSlash.petsback(self, sz)
    if not awful.pet or not awful.pet.exists then
        return
    end
    local timer = tonumber(sz)
    if not timer then
        timer = 4
    end
    Alert.sendAlert(
        true,
        0,
        "Calling pet back",
        nil,
        SOUND.POSITIVE,
        timer,
        Color.WARLOCK,
        nil,
        true
    )
    lockLib.petsBack = awful.time + timer
end
awful.Populate(
    {
        ["Interface.SlashCommand.ClassSlash.lockSlash"] = ____exports,
    },
    ravn,
    getfenv(1)
)
