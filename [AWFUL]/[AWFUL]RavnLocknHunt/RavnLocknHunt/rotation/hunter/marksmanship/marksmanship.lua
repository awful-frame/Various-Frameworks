local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local ____exports = {}
local ____spellList = ravn["Utilities.Lists.spellList"]
local SpellList = ____spellList.SpellList
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____hunterLib = ravn["rotation.hunter.hunterLib"]
local HunterLib = ____hunterLib.HunterLib
local ____hunterspells = ravn["rotation.hunter.hunterspells"]
local chimeraShot = ____hunterspells.chimeraShot
local scatterShot = ____hunterspells.scatterShot
local ____mmLib = ravn["rotation.hunter.marksmanship.mmLib"]
local mmLib = ____mmLib.mmLib
local function mmGo()
    local cond = awful.player.class2 == WowClass.HUNTER and GetSpecialization() == 2
    if not cond then
        return
    end
    print((((((((Color.ORANGE .. "[") .. Color.WHITE) .. "Hunter") .. Color.ORANGE) .. "] ") .. Color.HUNTER) .. "Marksmanship Loaded") .. Color.RESET)
    ravn.hunter.marksmanship = awful.Actor:New({spec = 2, class = "hunter"})
    HunterLib:initHunterSpells()
    mmLib:initMMSpells()
    ravn.hunter.marksmanship:Init(function()
        if IsMounted() then
            return
        end
        HunterLib:disablePetSpells()
        HunterLib:pvpPetBehavior()
        mmLib:catSpellsDismissPrep()
        if awful.target.exists then
        end
    end)
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == "SPELL_AURA_REMOVED" then
            if source.isUnit(awful.player) then
                if spellId == scatterShot.id then
                    HunterLib.scatterTrack = nil
                end
            end
        end
        if event == "SPELL_CAST_SUCCESS" then
            if source.isUnit(awful.player) then
                if __TS__ArrayIncludes(SpellList.hunterPetSpells, spellId) then
                    HunterLib:addPetSpellTracker(spellId)
                end
                if __TS__ArrayIncludes(SpellList.hunterPetInvokeSpells, spellId) then
                    HunterLib:updatePetSlot(spellId)
                end
                if spellId == scatterShot.id and dest ~= nil then
                    HunterLib:trackScatter(dest)
                end
                if spellId == chimeraShot.id then
                    mmLib.lastChimaeralTime = awful.time
                end
            end
        end
    end)
end
mmGo()
awful.Populate(
    {
        ["rotation.hunter.marksmanship.marksmanship"] = ____exports,
    },
    ravn,
    getfenv(1)
)
