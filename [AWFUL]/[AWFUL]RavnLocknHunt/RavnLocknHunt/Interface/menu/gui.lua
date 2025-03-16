local Unlocker, awful, ravn = ...
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local orange = {255, 148, 112, 1}
local white = {255, 255, 255, 1}
local dark = {21, 21, 21, 0.8}
local config = awful.NewConfig("RavnClassicConfig2")
ravn.config = config
ravn.config.demonoBurst = true
ravn.config.useDoomGuard = true
ravn.config.demonoAoe = true
ravn.config.demonoFelStorm = true
ravn.config.affliBurst = true
ravn.config.affliNextSwap = "AUTO"
ravn.config.nextKickStatus = 1
local awfulGui, awfulSettings, awfulCmd = awful.UI:New("ravn-gui-classic", {
    title = "RavnClassic is Awful",
    show = false,
    colors = {title = orange, primary = white, accent = orange, background = dark},
    width = 600,
    height = 250
})
ravn.awfulGui = awfulGui
ravn.settings = awfulSettings
ravn.statusFrame = awfulGui:StatusFrame({fontSize = 13, colors = {background = {0, 0, 0, 0.3}, value = {135, 136, 238, 1}}, maxWidth = 700})
ravn.statusFrame:Button({
    spellId = SpellBook.METAMORPHOSIS,
    var = "demonoBurst",
    text = {enabled = "Burst", disabled = "No Burst"},
    size = 24,
    textSize = 10,
    onClick = function(me, event)
        ravn.config.demonoBurst = not ravn.config.demonoBurst
        if ravn.config.demonoBurst then
            print("bursting")
        else
            print("delayed burst")
        end
    end,
    padding = 0,
    shouldShow = function()
        return GetSpecialization() == 2
    end
})
ravn.statusFrame:Button({
    spellId = SpellBook.SUMMON_DOOMGUARD,
    var = "useDoomGuard",
    text = {enabled = "ON", disabled = "OFF"},
    size = 24,
    textSize = 10,
    onClick = function(me, event)
        ravn.config.useDoomGuard = not ravn.config.useDoomGuard
    end,
    padding = 0,
    shouldShow = function()
        return GetSpecialization() == 2
    end
})
ravn.statusFrame:Button({
    spellId = SpellBook.HELLFIRE,
    var = "demonoAoe",
    text = {enabled = "AOE", disabled = "ST"},
    size = 24,
    textSize = 10,
    onClick = function(me, event)
        ravn.config.demonoAoe = not ravn.config.demonoAoe
    end,
    shouldShow = function()
        return GetSpecialization() == 2
    end
})
ravn.statusFrame:Button({
    spellId = SpellBook.PET_FELSTORM,
    var = "demonoFelStorm",
    text = {enabled = "ON", disabled = "OFF"},
    size = 24,
    textSize = 10,
    onClick = function(me, event)
        ravn.config.demonoFelStorm = not ravn.config.demonoFelStorm
    end,
    shouldShow = function()
        return GetSpecialization() == 2
    end
})
ravn.statusFrame:Button({
    spellId = SpellBook.DEMON_SOUL,
    var = "affliBurst",
    text = {enabled = "ON", disabled = "OFF"},
    size = 24,
    textSize = 10,
    onClick = function(me, event)
        ravn.config.affliBurst = not ravn.config.affliBurst
    end,
    shouldShow = function()
        return GetSpecialization() == 1
    end
})
ravn.debug = ravn.statusFrame:Button({
    spellId = function()
        if ravn.next == 1 then
            return 83961
        end
        if ravn.next == 3 then
            return SpellBook.POLYMORPH
        end
        if ravn.next == 4 then
            return SpellBook.PYROBLAST
        end
        if ravn.next == 2 then
            return SpellBook.HEALING_SURGE
        end
        return 83961
    end,
    var = "nextKickStatus",
    text = function()
        if ravn.next == 1 then
            return "AUTO"
        end
        if ravn.next == 3 then
            return " CC "
        end
        if ravn.next == 4 then
            return "DMG "
        end
        if ravn.next == 2 then
            return "HEAL"
        end
        return "AUTO"
    end,
    size = 24,
    textSize = 10,
    onClick = function(me, event)
    end,
    shouldShow = function()
        return GetSpecialization() == 1
    end
})
ravn.statusFrame:Button({
    spellId = SpellBook.SOUL_SWAP,
    var = "affliNextSwap",
    text = function()
        if ravn.config.affliNextSwap == "HEAL" then
            return "HEAL"
        else
            return "AUTO"
        end
    end,
    size = 24,
    textSize = 10,
    onClick = function(me, event)
        if ravn.config.affliNextSwap == "HEAL" then
            ravn.config.affliNextSwap = "AUTO"
        else
            ravn.config.affliNextSwap = "HEAL"
        end
    end,
    shouldShow = function()
        return GetSpecialization() == 1
    end
})
ravn.settings.demonoBurst = true
ravn.settings.useDoomGuard = true
ravn.settings.demonoAoe = true
ravn.settings.demonoFelStorm = true
ravn.settings.affliBurst = true
ravn.settings.affliNextSwap = "AUTO"
ravn.settings.nextKickStatus = 1
awful.Populate(
    {
        ["Interface.menu.gui"] = ____exports,
    },
    ravn,
    getfenv(1)
)
