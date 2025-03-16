local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local ____exports = {}
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local SOUND = ____alerts.SOUND
local ____awfulSpells = ravn["Utilities.Lists.awfulSpells"]
local aspecOfTheCheetah = ____awfulSpells.aspecOfTheCheetah
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____spell = ravn["Utilities.spell"]
local Spell = ____spell.Spell
local ____arena = ravn["arena.arena"]
local arena = ____arena.arena
local ____library = ravn["rotation.library"]
local Library = ____library.Library
local ____hunterspells = ravn["rotation.hunter.hunterspells"]
local aspectOfTheFox = ____hunterspells.aspectOfTheFox
local aspectOfTheHawk = ____hunterspells.aspectOfTheHawk
local badManner = ____hunterspells.badManner
local bullHeaded = ____hunterspells.bullHeaded
local callPet1 = ____hunterspells.callPet1
local callPet2 = ____hunterspells.callPet2
local callPet3 = ____hunterspells.callPet3
local callPet4 = ____hunterspells.callPet4
local callPet5 = ____hunterspells.callPet5
local camouflage = ____hunterspells.camouflage
local cobraShot = ____hunterspells.cobraShot
local dash = ____hunterspells.dash
local disengage = ____hunterspells.disengage
local dismissPet = ____hunterspells.dismissPet
local freezingTrap = ____hunterspells.freezingTrap
local howl = ____hunterspells.howl
local scatterShot = ____hunterspells.scatterShot
local steadyShot = ____hunterspells.steadyShot
____exports.PET_ACTION = PET_ACTION or ({})
____exports.PET_ACTION.NORMAL = 0
____exports.PET_ACTION[____exports.PET_ACTION.NORMAL] = "NORMAL"
____exports.PET_ACTION.PASSIVE_MODE = 1
____exports.PET_ACTION[____exports.PET_ACTION.PASSIVE_MODE] = "PASSIVE_MODE"
____exports.PET_ACTION.HOLD_POSITION = 2
____exports.PET_ACTION[____exports.PET_ACTION.HOLD_POSITION] = "HOLD_POSITION"
____exports.PET_ACTION.ON_HEALER = 3
____exports.PET_ACTION[____exports.PET_ACTION.ON_HEALER] = "ON_HEALER"
____exports.PET_ACTION.NEEDS_ROS = 4
____exports.PET_ACTION[____exports.PET_ACTION.NEEDS_ROS] = "NEEDS_ROS"
____exports.PET_ACTION.NEEDS_LIB = 5
____exports.PET_ACTION[____exports.PET_ACTION.NEEDS_LIB] = "NEEDS_LIB"
____exports.PET_ACTION.RUN_TO_ALLY = 6
____exports.PET_ACTION[____exports.PET_ACTION.RUN_TO_ALLY] = "RUN_TO_ALLY"
____exports.PET_ACTION.MOVE_TO = 7
____exports.PET_ACTION[____exports.PET_ACTION.MOVE_TO] = "MOVE_TO"
____exports.PET_ACTION.PET_FLEE = 8
____exports.PET_ACTION[____exports.PET_ACTION.PET_FLEE] = "PET_FLEE"
____exports.PET_ACTION.COMEBACK = 9
____exports.PET_ACTION[____exports.PET_ACTION.COMEBACK] = "COMEBACK"
____exports.PET_ACTION.NEED_MANNER = 10
____exports.PET_ACTION[____exports.PET_ACTION.NEED_MANNER] = "NEED_MANNER"
____exports.HunterLib = __TS__Class()
local HunterLib = ____exports.HunterLib
HunterLib.name = "HunterLib"
__TS__ClassExtends(HunterLib, Library)
function HunterLib.petAttack(self)
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    if awful.player.buff(camouflage.id) then
        return
    end
    if not awful.target.exists then
        return
    end
    if awful.target.isUnit(p.target) then
        return
    end
    if awful.time - self.lastPetCommandTimer < 0.2 then
        return
    end
    awful.call("PetAttack")
    self.lastPetCommandTimer = awful.time
end
function HunterLib.disablePetSpells(self)
    local list = {
        SpellBook.PET_BAD_MANNER,
        SpellBook.PET_TRINKET,
        SpellBook.PET_COWER,
        SpellBook.PET_DASH,
        SpellBook.ROAR_OF_SACRIFICE,
        SpellBook.PET_GROWL,
        SpellBook.PET_CALL_OF_THE_WILD,
        SpellBook.PET_ROAR_OF_COURAGE
    }
    if awful.time - self.lastPetCheck < 0.2 then
        return
    end
    self.lastPetCheck = awful.time
    local lastIndex = #list - 1
    do
        local i = 0
        while i < #list do
            local id = list[i + 1]
            self:petAutoCast(id, false)
            if i == lastIndex then
                self.lastPetCheck = awful.time + 1
            end
            i = i + 1
        end
    end
end
function HunterLib.timeToReachFocus(self, focus, malusFocus)
    local currentFocus = awful.player.focus
    if malusFocus then
        currentFocus = math.max(0, currentFocus - malusFocus)
    end
    if focus <= currentFocus then
        return 0
    end
    local regen, regenInCombat = awful.call("GetPowerRegen")
    local time = (focus - currentFocus) / regenInCombat
    return time
end
function HunterLib.detectPetTypes(self)
    local arraySpells = {
        callPet1,
        callPet2,
        callPet3,
        callPet4,
        callPet5
    }
    local idsCats = {132185}
    local idsMonkeys = {132159}
    self.petSlots = {}
    do
        local i = 0
        while i < #arraySpells do
            local spell = arraySpells[i + 1]
            local spellIcon = select(
                3,
                GetSpellInfo(spell.id)
            )
            if __TS__ArrayIncludes(idsMonkeys, spellIcon) then
                local ____self_petSlots_0 = self.petSlots
                ____self_petSlots_0[#____self_petSlots_0 + 1] = {slot = i, type = "MONKEY", id = spell.id, spell = spell}
            elseif __TS__ArrayIncludes(idsCats, spellIcon) then
                local ____self_petSlots_1 = self.petSlots
                ____self_petSlots_1[#____self_petSlots_1 + 1] = {slot = i, type = "CAT", id = spell.id, spell = spell}
            else
                local ____self_petSlots_2 = self.petSlots
                ____self_petSlots_2[#____self_petSlots_2 + 1] = {slot = i, type = "OTHER", id = spell.id, spell = spell}
            end
            i = i + 1
        end
    end
end
function HunterLib.playerFocus(self)
    local focus = awful.player.focus
    local id = awful.player.castIdEx
    if id == cobraShot.id or id == steadyShot.id then
        if awful.player.castTimeLeft <= awful.buffer + 0.25 then
            focus = focus + 9
        end
    end
    return focus
end
function HunterLib.spellAspect(self, id)
    local fox = {SpellBook.COBRA_SHOT, SpellBook.STEADY_SHOT}
    if not awful.player.buff(aspectOfTheFox.id) and __TS__ArrayIncludes(fox, id) and awful.player.level >= 81 then
        if awful.player.moving then
            return aspectOfTheFox
        end
    end
    local AOTH = {
        SpellBook.COBRA_SHOT,
        SpellBook.STEADY_SHOT,
        SpellBook.AIMED_SHOT,
        SpellBook.BLACK_ARROW,
        SpellBook.CHIMERA_SHOT,
        SpellBook.EXPLOSIVE_SHOT,
        SpellBook.MULTISHOT,
        SpellBook.SERPENT_STING,
        SpellBook.KILL_SHOT
    }
    if __TS__ArrayIncludes(AOTH, id) and not awful.player.buff(aspectOfTheHawk.id) then
        return aspectOfTheHawk
    end
    return nil
end
function HunterLib.initHunterSpells(self)
    awful.hookSpellCasts(function(spell)
        if not spell then
            return
        end
        if not awful.arena and awful.player.buff(aspecOfTheCheetah.id) then
            return
        end
        local aspect = self:spellAspect(spell.id)
        if aspect and not awful.player.buff(aspect.id) then
            aspect:Cast()
        end
    end)
    disengage:Callback(
        "reverse",
        function(spell)
            if not awful.player.combat then
                return
            end
            local q = Queue.queues[Queue.HUNTER_REVERSE]
            if not q then
                return
            end
            local angle = self.disengageBaseAngle
            if not angle then
                return
            end
            if not awful.player.isJumping then
                return
            end
            local delta = math.abs(awful.player.rotation - angle)
            awful.controlMovement(awful.tickRate * 3)
            if delta > 0.22 then
                awful.player.face(angle)
            else
                spell:Cast()
            end
        end
    )
    howl:Callback(
        "dispel",
        function(spell)
        end
    )
end
function HunterLib.summonPet(self)
end
function HunterLib.currentPetType(self)
    return
end
function HunterLib.petArenaSummonLogic(self)
end
function HunterLib.petLobbyDismissCatLogic(self)
    if not arena:inPrep() then
        return
    end
    if self:currentPetType() ~= "CAT" then
        return
    end
    local timer = awful.prepremains
    if timer <= 0 then
        return
    end
    if timer <= dismissPet.castTime then
        local cid = awful.player.castIdEx
        if cid ~= dismissPet.id then
            dismissPet:Cast()
        else
        end
    end
end
function HunterLib.petInitialSummonLogic(self)
    if awful.player.combat then
        return
    end
    local currentType = self:currentPetType()
    local pve = awful.player.specId == 255
    local function isSpecial(o)
        return o == "CAT" or o == "SPIDER"
    end
    if pve then
        if currentType == nil then
            local entry = __TS__ArrayFind(
                self.petSlots,
                function(____, o) return isSpecial(o.type) end
            )
            if entry then
            end
        end
        if currentType == "MONKEY" then
            dismissPet:Cast()
        end
        return
    end
    if not awful.arena then
        if currentType == nil then
            local entry = __TS__ArrayFind(
                self.petSlots,
                function(____, o) return o.type == "MONKEY" end
            )
            if entry then
                entry.spell:Cast()
            end
        end
        if currentType and isSpecial(currentType) then
            dismissPet:Cast()
        end
        return
    end
end
function HunterLib.trackScatter(self, dest)
    print("Tracking scatter")
    ____exports.HunterLib.scatterTrack = {
        time = awful.time,
        target = dest,
        position = {dest.position()}
    }
end
function HunterLib.addPetSpellTracker(self, id)
    local entry = __TS__ArrayFind(
        self.spellTracker,
        function(____, e) return e.id == id and e.slot == self.currentSlot end
    )
    if not entry then
        local ____self_spellTracker_3 = self.spellTracker
        ____self_spellTracker_3[#____self_spellTracker_3 + 1] = {
            id = id,
            slot = self.currentSlot,
            usedTimestamp = GetTime(),
            cooldown = Spell.baseCD(id)
        }
    else
        self.spellTracker[__TS__ArrayIndexOf(self.spellTracker, entry) + 1].usedTimestamp = GetTime()
    end
end
function HunterLib.updatePetSlot(self, spellId)
    local index = 0
    if spellId == SpellBook.SUMMON_PET_1 then
        index = 1
    elseif spellId == SpellBook.SUMMON_PET_2 then
        index = 2
    elseif spellId == SpellBook.SUMMON_PET_3 then
        index = 3
    elseif spellId == SpellBook.SUMMON_PET_4 then
        index = 4
    elseif spellId == SpellBook.SUMMON_PET_5 then
        index = 5
    end
    ____exports.HunterLib.currentSlot = index
end
function HunterLib.askAutoAttack(self)
    if self.sendAttackOrder then
        self.sendAttackOrder = false
        local rdm = math.random(700, 1000) / 1000
        C_Timer.After(
            rdm,
            function()
                self.sendAttackOrder = true
            end
        )
    end
end
function HunterLib.startAttack(self)
    local t = awful.target
    if not t or not t.exists or t.dead or t.friend then
        return
    end
    if t.meleeRange then
        if not IsCurrentSpell(6603) then
            awful.call("StartAttack", "target")
        end
    else
        if not awful.player.combat then
            return
        end
        if self.sendAttackOrder == false then
            return
        end
        awful.call("StartAttack", "target")
        self:askAutoAttack()
    end
end
function HunterLib.MovePetTo(self, position)
    if awful.time < self.petMoveTimer then
        return
    end
    if not awful.pet or not awful.pet.exists or awful.pet.dead then
        return
    end
    local posLosCheck = position
    posLosCheck[3] = posLosCheck[3] + 1.5
    if not awful.player.losPositionLiteral(posLosCheck) then
        return
    end
    if awful.pet.rooted or awful.pet.movementFlags == 1024 or awful.pet.cc then
        return
    end
    local distanceFromPos = awful.pet.distanceToLiteralPos(position)
    if distanceFromPos <= 1.2 then
        return
    end
    awful.call("PetMoveTo")
    local x, y, z = unpack(position)
    Click(x, y, z)
    self.petMoveTimer = awful.time + self.PET_REFRESH
end
function HunterLib.displacePetTo(self, spell, position, unit, shouldTrinket, shouldSprint)
    position = unit and ({unit.position()}) or position
    if not position then
        return
    end
    local posLosCheck = position
    posLosCheck[3] = posLosCheck[3] + 1.5
    if not awful.player.losPositionLiteral(posLosCheck) then
        return
    end
    local x, y, z = unpack(position)
    local function requirements(spell)
        if spell.id == SpellBook.PET_BAD_MANNER then
            return {range = 20, los = true, shouldSprint = true, shouldTrinket = true}
        end
        if spell.id == SpellBook.ROAR_OF_SACRIFICE then
            return {range = 40, los = true, shouldSprint = true, shouldTrinket = true}
        end
        return
    end
    if shouldTrinket and awful.pet.cc then
        bullHeaded:Cast()
    end
    local rq = requirements(spell)
    if rq and rq.shouldTrinket then
        shouldTrinket = true
    end
    local petDistance = awful.pet.distanceTo(x, y, z)
    local condMove = rq and (rq.los and not awful.pet.losPositionLiteral(position) or rq.range and petDistance > rq.range)
    local condTrinket = shouldTrinket and awful.pet.cc or condMove and awful.pet.rooted
    if condTrinket then
        local ____ = bullHeaded:Cast() and Alert.sendAlert(false, bullHeaded.id, "Pet Trinket")
    end
    local distanceNeeded = rq and math.max(0, petDistance - rq.range) or petDistance
    shouldSprint = shouldSprint or rq and rq.shouldSprint
    local condSprint = distanceNeeded > 10 and shouldSprint
    if condMove then
        self:MovePetTo(position)
        if condSprint then
            local ____ = dash:Cast() and Alert.sendAlert(false, dash.id, "Pet Sprint")
        end
    end
end
function HunterLib.queuedBadManner(self)
    local q = Queue.queues[Queue.HUNTER_BADMANNER]
    if q == nil then
        return
    end
    if awful.pet.exists == false or awful.pet.dead then
        return
    end
    local t = awful.GetObjectWithGUID(q.unit)
    if not t or not t.exists or t.friend then
        return
    end
    local conditionUrgent = arena:getLowestEnemy() and arena:getLowestEnemy().hp <= 40
    local function fnCondSendDR(t)
        local dr = t.stunDR
        if dr == 1 then
            return true
        end
        if dr == 0 then
            return false
        end
        if dr == 0.25 then
            if t.castIdEx == 0 then
                return false
            end
            return true
        end
        local drRemains = t.stunDRRemains
        if drRemains <= 0 then
            return true
        end
        if drRemains <= 2 then
            return false
        end
        if drRemains > 15 then
            return true
        else
            return conditionUrgent
        end
    end
    local condDR = fnCondSendDR(t)
    if not condDR then
        return
    end
    local function fnCondSendCC(t)
        local ccr = t.ccRemains
        if ccr >= 4 then
            return false
        end
        if ccr <= 0 then
            return true
        end
        local calculateDistance = t.distanceTo(awful.pet)
        local buffer = awful.gcd + calculateDistance / 14
        if awful.pet.cc then
            buffer = buffer + awful.buffer
        end
        if ccr <= 0.9 then
            return true
        end
        if ccr <= awful.gcd + buffer then
            return "wait"
        end
        return false
    end
    local condCC = fnCondSendCC(t)
    if not condCC then
        return
    end
    if condCC == true then
        local ____ = badManner:Cast(t) and Alert.sendAlert(
            false,
            badManner.id,
            "Pet Bad Manner",
            t.name,
            SOUND.GET_CLOSE,
            1,
            Color.HUNTER,
            t.color,
            true
        )
    end
    return t
end
function HunterLib.badMannerLogic(self)
    if not IsSpellKnown(badManner.id, true) then
        return
    end
    if badManner.cd > awful.gcd then
        return
    end
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    local queuedUnit = self:queuedBadManner()
    if queuedUnit then
        return queuedUnit
    end
    local h = arena:getHealerOrSecondUnit()
    if not h or not h.exists or h.friend then
        return
    end
    if not h.los or h.distance >= 35 then
        return
    end
    local trapDR = h.disorientDRRemains
    if trapDR > 2 then
        return
    end
    if freezingTrap.cd > 2 then
        return
    end
    local scatterCD = scatterShot.cd
    local condSend = h.debuff(scatterShot.id) or scatterShot.cd >= 4
    if not condSend then
        return
    end
    Queue:addToQueue(h, Queue.HUNTER_BADMANNER, 5, badManner.id)
    return
end
function HunterLib.queuedRos(self)
    return
end
function HunterLib.ros(self)
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    local queuedUnit = self:queuedRos()
    if queuedUnit then
        return queuedUnit
    end
    return
end
function HunterLib.petByMySide(self)
    if awful.time - self.lastPetFollow < 0.5 then
        return
    end
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    local cond1 = p.distanceToLiteral(awful.player) > 8
    local cond2 = p.target.exists and not p.target.friend
    if not cond1 and not cond2 then
        return
    end
    awful.call("PetFollow")
    self.lastPetFollow = awful.time
end
function HunterLib.pvpPetBehavior(self)
    if not awful.player.combat then
        self:setPetPassive()
    end
    self.petStatus = ____exports.PET_ACTION.NORMAL
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    local petToHealer = self:petToHealer()
    if petToHealer ~= false then
        self.petStatus = ____exports.PET_ACTION.ON_HEALER
        self:MovePetTo({petToHealer.position()})
        return
    end
    local badMannerUnit = self:badMannerLogic()
    if badMannerUnit then
        self.petStatus = ____exports.PET_ACTION.NEED_MANNER
        self:displacePetTo(badManner, nil, badMannerUnit)
        return
    end
    if self.petStatus == ____exports.PET_ACTION.NORMAL then
        self:petByMySide()
    end
end
function HunterLib.petToHealer(self)
    if not awful.arena then
        return false
    end
    local h = awful.healer
    if not h.exists then
        return false
    end
    local condition = (h.disorientDR == 1 or h.disorientDRRemains <= 2) and (h.debuff(badManner.id) or h.debuff(scatterShot.id))
    if not condition then
        return false
    end
    return h
end
HunterLib.spellTracker = {}
HunterLib.currentSlot = 0
HunterLib.isVeryDead = false
HunterLib.petSlots = {}
HunterLib.disengageBaseAngle = nil
HunterLib.petCombackTimer = 0
HunterLib.lastPetCommandTimer = 0
HunterLib.petAction = ____exports.PET_ACTION.NORMAL
HunterLib.petBehaviour = ____exports.PET_ACTION.NORMAL
HunterLib.scatterTrack = nil
HunterLib.lastPetCheck = 0
HunterLib.petMoveTimer = 0
HunterLib.PET_REFRESH = 0.07
HunterLib.lastPetFollow = 0
HunterLib.petStatus = ____exports.PET_ACTION.NORMAL
awful.Populate(
    {
        ["rotation.hunter.hunterLib"] = ____exports,
    },
    ravn,
    getfenv(1)
)
