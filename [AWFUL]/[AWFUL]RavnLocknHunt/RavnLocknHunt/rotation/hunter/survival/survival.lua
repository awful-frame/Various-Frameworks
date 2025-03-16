local Unlocker, awful, ravn = ...
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____hunterLib = ravn["rotation.hunter.hunterLib"]
local HunterLib = ____hunterLib.HunterLib
local ____hunterspells = ravn["rotation.hunter.hunterspells"]
local explosiveShot = ____hunterspells.explosiveShot
local ____survLib = ravn["rotation.hunter.survival.survLib"]
local survLib = ____survLib.survLib
local function survGo()
    local cond = awful.player.class2 == WowClass.HUNTER and GetSpecialization() == 3
    if not cond then
        return
    end
    awful.ttd_enabled = true
    ravnInfo(Color.HUNTER, "Survival Loaded")
    ravn.hunter.survival = awful.Actor:New({spec = 3, class = "hunter"})
    awful.addUpdateCallback(function()
    end)
    HunterLib:initHunterSpells()
    survLib:initSurvSpells()
    ravn.hunter.survival:Init(function()
        HunterLib:disablePetSpells()
        survLib:pvePetBehaviour()
        survLib:damageLoop()
    end)
    local timeCast = 0
    local timeApplied = 0
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == "SPELL_CAST_SUCCESS" then
            if source.isUnit(awful.player) then
                if spellId == explosiveShot.id then
                    survLib.lastExploTime = awful.time
                end
            end
        end
        if spellId == SpellBook.EXPLOSIVE_SHOT and source.isPlayer then
            if event == "SPELL_AURA_REFRESH" then
                ravnInfo("ERROR REFRESH")
            end
        end
    end)
end
survGo()
awful.Populate(
    {
        ["rotation.hunter.survival.survival"] = ____exports,
    },
    ravn,
    getfenv(1)
)
