local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local ____exports = {}
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____library = ravn["rotation.library"]
local Library = ____library.Library
local ____lockLib = ravn["rotation.lock.lockLib"]
local lockLib = ____lockLib.lockLib
local ____lockspells = ravn["rotation.lock.lockspells"]
local baneOfAgony = ____lockspells.baneOfAgony
local banish = ____lockspells.banish
local corruption = ____lockspells.corruption
local curseOfTheElements = ____lockspells.curseOfTheElements
local curseOfTongues = ____lockspells.curseOfTongues
local curseOfWeakness = ____lockspells.curseOfWeakness
local curseofExhaustion = ____lockspells.curseofExhaustion
local darkIntent = ____lockspells.darkIntent
local deathlCoil = ____lockspells.deathlCoil
local demonArmor = ____lockspells.demonArmor
local demonicCircleSummon = ____lockspells.demonicCircleSummon
local demonicCircleTeleport = ____lockspells.demonicCircleTeleport
local devourMagic = ____lockspells.devourMagic
local fear = ____lockspells.fear
local felArmor = ____lockspells.felArmor
local felFlame = ____lockspells.felFlame
local haunt = ____lockspells.haunt
local healthFunnel = ____lockspells.healthFunnel
local howlOfTerror = ____lockspells.howlOfTerror
local shadowWard = ____lockspells.shadowWard
local shadowflame = ____lockspells.shadowflame
local soulLink = ____lockspells.soulLink
local soulSwap = ____lockspells.soulSwap
local summonFelhunter = ____lockspells.summonFelhunter
local unstableAffliction = ____lockspells.unstableAffliction
local whiplash = ____lockspells.whiplash
local ____affLib = ravn["rotation.lock.affli.affLib"]
local affLib = ____affLib.affLib
local function startAffliRoutine()
    local cond = awful.player.class2 == WowClass.WARLOCK and GetSpecialization() == 1
    if not cond then
        return
    end
    ravn.warlock.affliction = awful.Actor:New({spec = 1, class = "warlock"})
    lockLib:initLockSpells()
    affLib:initAffliSpells()
    awful.addUpdateCallback(function()
        affLib:onTickCurseCount()
        affLib:update()
        affLib:dotUpdate()
        affLib:populateTargets()
        affLib:autoSynapseSpring()
        wipe(lockLib.lockCacheBug)
        if awful.enabled then
            Library:lastCast()
            affLib:safeCast()
        end
        affLib:debugHS()
    end)
    local ____Library_fakeSpellsId_0 = Library.fakeSpellsId
    ____Library_fakeSpellsId_0[#____Library_fakeSpellsId_0 + 1] = fear.id
    local ____Library_fakeSpellsId_1 = Library.fakeSpellsId
    ____Library_fakeSpellsId_1[#____Library_fakeSpellsId_1 + 1] = unstableAffliction.id
    local ____Library_fakeSpellsId_2 = Library.fakeSpellsId
    ____Library_fakeSpellsId_2[#____Library_fakeSpellsId_2 + 1] = haunt.id
    local ____Library_fakeSpellsId_3 = Library.fakeSpellsId
    ____Library_fakeSpellsId_3[#____Library_fakeSpellsId_3 + 1] = banish.id
    ravn.warlock.affliction:Init(function()
        affLib:tips()
        Library:fakeCasting(nil, true, true)
        if Library:pauseHandler() then
            return
        end
        if IsMounted() then
            return
        end
        soulLink("base")
        devourMagic("base")
        devourMagic("mc")
        affLib:singeMagicBuggedBtw()
        affLib:LockKicks()
        affLib:stompSetup()
        affLib:pvpPetBehavior()
        if affLib:onTricks() == "wait" then
            return
        end
        if soulSwap("vomit") == "wait" then
            return
        end
        if affLib:holdOnHaunt() then
            return
        end
        affLib:antiReflect()
        summonFelhunter("rez")
        if demonicCircleTeleport("queue") == "wait" then
            return
        end
        if deathlCoil("queue") == "wait" then
            return
        end
        if howlOfTerror("queue") == "wait" then
            return
        end
        if fear("queue") == "wait" then
            return
        end
        if deathlCoil("auto-rls") == "wait" then
            return
        end
        if deathlCoil("auto") == "wait" then
            return
        end
        howlOfTerror("auto")
        fear("auto")
        banish("base")
        whiplash("base")
        if shadowflame("los") == "wait" then
            return
        end
        if shadowflame("snare") == "wait" then
            return
        end
        shadowflame("snakes")
        felFlame("stomp")
        demonArmor("base")
        shadowWard("base", 70)
        affLib:damageLoop()
        healthFunnel("base", 70)
        shadowWard("base", 100)
        darkIntent("base")
        felArmor("base")
        summonFelhunter("outsideCombat")
        affLib:healthStoneLogicArena()
    end)
    local idsSnap = {corruption.id, unstableAffliction.id, baneOfAgony.id}
    awful.onEvent(function(info, event, source, dest)
        local spellId = info[12]
        local spellName = info[13]
        local auraType = info[15]
        local extraSpellName = info[16]
        local auraType2 = info[17]
        local time = awful.time
        if event == "SPELL_AURA_REMOVED" and auraType == "BUFF" then
            if dest.isUnit(awful.player) and spellId then
                lockLib:onBuffExpired(spellId)
            end
        end
        if event == "SPELL_CAST_SUCCESS" then
            if source.isUnit(awful.player) and dest then
                if spellId == felFlame.id then
                    affLib:onFelFlame(dest)
                    lockLib:addSnapShot(dest, dest.guid, unstableAffliction.id)
                end
                if spellId == demonicCircleSummon.id then
                    lockLib:onPortDrop()
                end
                if spellId == soulSwap.id then
                    affLib:onSoulSwap(dest)
                end
                if __TS__ArrayIncludes({curseofExhaustion.id, curseOfTheElements.id, curseOfTongues.id, curseOfWeakness.id}, spellId) then
                    affLib.recentlyCursed[dest.guid] = time
                    affLib:onCurseCount()
                    C_Timer.After(
                        4,
                        function()
                            local cache = affLib.recentlyCursed[dest.guid]
                            if cache and awful.time - cache > 3.4 then
                                affLib.recentlyCursed[dest.guid] = nil
                            end
                        end
                    )
                end
            end
            if source.friend and awful.arena then
                if spellId == SpellBook.REDIRECT then
                    affLib:onRogueRedirectedUnit(dest)
                end
            end
        end
        if event == "SPELL_AURA_REMOVED" then
            if spellId == baneOfAgony.id and source.isUnit(awful.player) and dest then
                affLib:onDispelledAgony(dest)
            end
            if dest.isUnit(awful.player) then
                if spellId == lockLib.DEMONIC_REBIRTH and IsPlayerSpell(88447) then
                    affLib.demonicRebirthTimer = awful.time
                end
            end
        end
        if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" and auraType == "DEBUFF" and source.isUnit(awful.player) and dest then
            if __TS__ArrayIncludes(idsSnap, spellId) then
                lockLib:addSnapShot(dest, dest.guid, spellId)
            end
        end
    end)
    local function resetStatus()
        lockLib.portInfo = nil
        affLib.IShadowFlameInfo = nil
        Global.burstMode = 0
        affLib.initiatedTradeList = {}
        affLib.demonicRebirthTimer = 0
        affLib.stickUnit = nil
        affLib.curseCount.timer = 0
        affLib.curseCount.count = 0
    end
    awful.addEventCallback(resetStatus, "PLAYER_ENTERING_WORLD")
end
startAffliRoutine()
awful.Populate(
    {
        ["rotation.lock.affli.affliction"] = ____exports,
    },
    ravn,
    getfenv(1)
)
