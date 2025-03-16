local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local ____exports = {}
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____library = ravn["rotation.library"]
local Library = ____library.Library
local ____lockLib = ravn["rotation.lock.lockLib"]
local lockLib = ____lockLib.lockLib
local ____lockspells = ravn["rotation.lock.lockspells"]
local baneOfAgony = ____lockspells.baneOfAgony
local baneOfDoom = ____lockspells.baneOfDoom
local corruption = ____lockspells.corruption
local darkIntent = ____lockspells.darkIntent
local devourMagic = ____lockspells.devourMagic
local felArmor = ____lockspells.felArmor
local felFlame = ____lockspells.felFlame
local immolate = ____lockspells.immolate
local lifeTap = ____lockspells.lifeTap
local metamorphosis = ____lockspells.metamorphosis
local summonFelhunter = ____lockspells.summonFelhunter
local ____demonoLib = ravn["rotation.lock.demono.demonoLib"]
local demonoLib = ____demonoLib.demonoLib
local function demonoGo()
    local cond = awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 2
    if not cond then
        return
    end
    awful.ttd_enabled = true
    ravnInfo(Color.WARLOCK, "Demono (PVE) Loaded")
    ravn.warlock.demono = awful.Actor:New({spec = 2, class = "warlock"})
    lockLib:initLockSpells()
    demonoLib:initDemonoSpells()
    awful.addUpdateCallback(function()
        wipe(lockLib.lockCacheBug)
        demonoLib:setOpenerStart()
        demonoLib:checkGear()
        demonoLib:onTick()
        Library:lastCast()
        demonoLib:postPullCountdown()
    end)
    ravn.warlock.demono:Init(function()
        if Library:pauseHandler() then
            return
        end
        if IsMounted() then
            return
        end
        demonoLib:nefarianDominionLogic()
        demonoLib:onUseTrinkets()
        demonoLib:tips()
        if demonoLib:synapseLogic() == "wait" then
            return
        end
        demonoLib:demonoKicks()
        demonoLib:lazyTarget()
        devourMagic("base")
        lifeTap("nomana")
        darkIntent("base")
        if summonFelhunter("post-meta") == "wait" then
            return
        end
        demonoLib:pvePetBehaviour()
        demonoLib:felGuardInFrontOfBoss()
        demonoLib:setPetPassive()
        demonoLib:damageLoop()
        felArmor("base")
        demonoLib:farmShards()
    end)
    local idsSnap = {corruption.id, immolate.id, baneOfAgony.id, baneOfDoom.id}
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == "SPELL_AURA_REMOVED" and auraType == "BUFF" then
            if dest.isUnit(awful.player) and spellId then
                demonoLib:onBuffExpired(spellId)
            end
        end
        if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") and auraType == "DEBUFF" and source.isUnit(awful.player) and dest then
            local meta = awful.player.buffRemains(metamorphosis.id) > 0
            if __TS__ArrayIncludes(idsSnap, spellId) then
                lockLib:addSnapShot(dest, dest.guid, spellId)
            end
        end
        if event == "SPELL_CAST_SUCCESS" then
            if source.isUnit(awful.player) then
                if spellId == felFlame.id then
                    lockLib:addSnapShot(dest, dest.guid, immolate.id)
                end
            end
        end
    end)
end
demonoGo()
awful.Populate(
    {
        ["rotation.lock.demono.demono"] = ____exports,
    },
    ravn,
    getfenv(1)
)
