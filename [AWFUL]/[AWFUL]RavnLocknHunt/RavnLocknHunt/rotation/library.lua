local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__StringIncludes = ____lualib.__TS__StringIncludes
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____geometry = ravn["Geometry.geometry"]
local Geometry = ____geometry.Geometry
local ____global = ravn["Global.global"]
local Global = ____global.Global
local ____awfulSpells = ravn["Utilities.Lists.awfulSpells"]
local healthStone = ____awfulSpells.healthStone
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____spellList = ravn["Utilities.Lists.spellList"]
local SpellList = ____spellList.SpellList
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____queue = ravn["Utilities.Queue.queue"]
local Queue = ____queue.Queue
local ____ravnPrint = ravn["Utilities.ravnPrint"]
local ravnInfo = ____ravnPrint.ravnInfo
local ravnPrint = ____ravnPrint.ravnPrint
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____lockspells = ravn["rotation.lock.lockspells"]
local fear = ____lockspells.fear
local soulBurn = ____lockspells.soulBurn
____exports.Library = __TS__Class()
local Library = ____exports.Library
Library.name = "Library"
function Library.prototype.____constructor(self)
end
function Library.isPlayingTop(self, o)
    if o == nil then
        o = awful.player
    end
    local mapID = awful.mapID
    local entry = __TS__ArrayFind(
        self.arenaPositions,
        function(____, o) return o.mapID == mapID end
    )
    if not entry then
        return false
    end
    local topPos = entry.topPosition
    local curPos = {o.position()}
    if not curPos[3] then
        return false
    end
    if o.isJumping then
        curPos[3] = curPos[3] - 1.5
    end
    local distance = math.abs(curPos[3] - topPos)
    if distance > 2 then
        return false
    end
    return true
end
function Library.isPlayingBottom(self, o)
    if o == nil then
        o = awful.player
    end
    local mapID = awful.mapID
    local entry = __TS__ArrayFind(
        self.arenaPositions,
        function(____, o) return o.mapID == mapID end
    )
    if not entry then
        return false
    end
    local bottomPos = entry.bottomPosition
    local curPos = {o.position()}
    if not curPos[3] then
        return false
    end
    if o.isJumping then
        curPos[3] = curPos[3] - 1.5
    end
    local distance = math.abs(curPos[3] - bottomPos)
    if distance > 2 then
        return false
    end
    return true
end
function Library.canBump(self, o)
    if o.rooted then
        return false
    end
    if o.ccRemains > awful.gcd then
        return false
    end
    if o.speed > 12 then
        return false
    end
    if o.buff(51271) then
        return false
    end
    if o.buff(SpellBook.BLADESTORM) then
        return false
    end
    if math.abs(select(
        3,
        o.position()
    ) - select(
        3,
        awful.player.position()
    )) > 2 then
        return false
    end
    return true
end
function Library.determineAoeBumpOrigin(self, o, spell, bump_distance, spell_radius, is_pet_spell)
    if bump_distance == nil then
        bump_distance = 5
    end
    if spell_radius == nil then
        spell_radius = bump_distance
    end
    if is_pet_spell == nil then
        is_pet_spell = false
    end
    if not self:canBump(o) then
        return
    end
    local edgePts = Geometry:NearEdgePoints(o, bump_distance)
    if #edgePts == 0 then
        return
    end
    local referal = is_pet_spell and awful.pet or awful.player
    if not referal or not referal.exists then
        return
    end
    local positionPerPoint
    positionPerPoint = function(pt, distance, loop)
        if distance == nil then
            distance = 3
        end
        if loop == nil then
            loop = false
        end
        if distance + 0.3 > spell_radius then
            return
        end
        local norm = {Geometry:NormalizedPosDistance2D(
            {o.position()},
            pt
        )}
        distance = distance * -1
        local spellPos = {Geometry:NormalizedPosDistance2D(
            {o.position()},
            norm,
            -3
        )}
        local groundedSpellpos = {awful.GroundZ(spellPos[1], spellPos[2], spellPos[3])}
        local delta = math.abs(groundedSpellpos[3] - select(
            3,
            o.position()
        ))
        local function condRet()
            if loop then
                return positionPerPoint(pt, distance + 1, true)
            else
                return
            end
        end
        if delta > 1 then
            return condRet()
        end
        if not referal.losPositionLiteral(groundedSpellpos) then
            return condRet()
        end
        if referal.distanceToLiteralPos(groundedSpellpos) > spell.range then
            return condRet()
        end
        return spellPos
    end
    for ____, pt in ipairs(edgePts) do
        local pos = positionPerPoint(pt)
        if pos then
            return pos
        end
    end
    return
end
function Library.movementRecordInfo(self)
    if awful.player.moving then
        if self._movingSince == 0 then
            self._movingSince = awful.time
        end
        self._immobileSince = 0
    else
        if self._immobileSince == 0 then
            self._immobileSince = awful.time
        end
        self._movingSince = 0
    end
end
function Library.lastCast(self)
    local id = awful.player.castID
    if id == 0 or not id then
        return
    end
    if awful.player.castTimeLeft <= 0.4 + awful.buffer then
        local t = awful.player.castTarget
        local guid = t and t.guid or "none"
        local current = self.lastCastId
        if current and current.id == id and current.guid == guid then
            return
        end
        self.lastCastId = {id = id, guid = guid}
        C_Timer.After(
            0.6,
            function()
                if self.lastCastId and self.lastCastId.id == id and self.lastCastId.guid == guid then
                    self.lastCastId = nil
                end
            end
        )
    end
end
function Library.pauseHandler(self)
    return Global.pauseTimer > awful.time
end
function Library.getSmartEnemyList(self, includingBreakable)
    if includingBreakable == nil then
        includingBreakable = false
    end
    return Memory.caching(
        ____exports.Library.libCache,
        "enemyList" .. tostring(includingBreakable),
        function()
            if includingBreakable then
                if awful.arena then
                    return awful.enemies
                else
                    return awful.enemies.filter(function(o) return o.isUnit(awful.target) or o.isUnit(awful.focus) end)
                end
            else
                if awful.arena then
                    return awful.enemies.filter(function(o) return o.bccRemains <= 0.5 and o.exists end)
                else
                    return awful.enemies.filter(function(o) return o.exists and (o.isUnit(awful.target) or o.isUnit(awful.focus) and o.bccRemains <= 0.5) end)
                end
            end
        end
    )
end
function Library.setPetPassive(self)
    if awful.time - self.petLastCheckStatus < 1 then
        return
    end
    self.petLastCheckStatus = awful.time
    for i = 1, NUM_PET_ACTION_SLOTS do
        local name, idk, isToken, isActive = GetPetActionInfo(i)
        if isToken then
            name = _G[name]
        end
        if name == PET_MODE_PASSIVE then
            if not isActive then
                ravnInfo("Set Pet to Passive", awful.player.color)
                awful.call("CastPetAction", i)
            end
            return true
        end
    end
end
function Library.isOverlapping(self, u, id, osefUnit)
    if osefUnit == nil then
        osefUnit = false
    end
    if not awful.player then
        return false
    end
    if not self.lastCastId then
        return false
    end
    if osefUnit then
        if self.lastCastId.id == id then
            return true
        end
        return false
    end
    if self.lastCastId.id == id and self.lastCastId.guid == u.guid then
        return true
    end
    return false
end
function Library.GetSetFromName(self, name)
    local sets = C_EquipmentSet.GetNumEquipmentSets()
    for i = 0, sets do
        local nameSet, icond, id = C_EquipmentSet.GetEquipmentSetInfo(i)
        if nameSet == name then
            return id
        end
    end
    return -1
end
function Library.IsSetEquipped(self, setName)
    local sets = C_EquipmentSet.GetNumEquipmentSets()
    for i = 0, sets do
        local nameSet, icond, id, equipped = C_EquipmentSet.GetEquipmentSetInfo(i)
        if nameSet == setName and equipped then
            return true
        end
    end
    return false
end
function Library.EquipSetFromName(self, name)
    if self:IsSetEquipped(name) then
        return
    end
    local id = self:GetSetFromName(name)
    if id == -1 then
        return
    end
    C_EquipmentSet.UseEquipmentSet(id)
    ravnPrint("Equipping Set: " .. name)
end
function Library.stopCasting(self, reason)
    if awful.player.casting or awful.player.channel then
        if reason then
            ravnInfo("Stop Casting: " .. reason)
        else
            ravnInfo("Stop Casting: no reason")
        end
        awful.call("SpellStopCasting")
    end
end
function Library.GlyphInfo(self)
    local glyphAmount = GetNumGlyphSockets()
    for i = 1, glyphAmount do
        local enabled, glyphType, glyphTooltipIndex, glyphSpellID = GetGlyphSocketInfo(i)
        if enabled and glyphSpellID then
            local ____self_playerGlyphs_0 = self.playerGlyphs
            ____self_playerGlyphs_0[#____self_playerGlyphs_0 + 1] = glyphSpellID
        end
    end
end
function Library.getDBMTimer(self)
    return awful.pullTimer
end
function Library.findTank(self)
    return Memory.caching(
        self.libCache,
        "fdindTank",
        function()
            return __TS__ArrayFind(
                awful.fullGroup,
                function(____, o) return o.isTank end
            )
        end
    )
end
function Library.petAutoCast(self, id, status)
    if status == nil then
        status = true
    end
    local p = awful.pet
    if not p.exists or p.dead then
        return
    end
    if not IsSpellKnown(id, true) then
        return
    end
    local autoCastable, curStatus = GetSpellAutocast(id)
    if autoCastable and curStatus ~= status then
        if awful.time - self.lastPetAutoCastCall < 0.1 then
            return
        end
        self.lastPetAutoCastCall = awful.time
        if not status then
            awful.call(
                "RunMacroText",
                "/petautocastoff " .. tostring(id)
            )
        end
        if status then
            awful.call(
                "RunMacroText",
                "/petautocaston " .. tostring(id)
            )
        end
    end
end
function Library.GetWeaponEnchant(self)
    return self:GetEnchantId("MainHandSlot")
end
function Library.LookTextInItem(self, slotID, looking)
    local link = awful.call("GetInventoryItemLink", "player", slotID)
    if not link then
        return false
    end
    Global.scanTooltip:ClearLines()
    Global.scanTooltip:SetInventoryItem("player", slotID)
    for i = 1, Global.scanTooltip:NumLines() do
        local line = _G["RCTooltipTextLeft" .. tostring(i)]
        if line and line.GetText then
            local text = line:GetText()
            text = string.lower(text)
            looking = string.lower(looking)
            if text and __TS__StringIncludes(text, looking) then
                return true
            end
        end
    end
    return false
end
function Library.HasSynapseSpring(self)
    return Memory.caching(
        self.gearCache,
        "synapseSpring",
        function()
            local slotID, idk = GetInventorySlotInfo("HandsSlot")
            if not slotID then
                return false
            end
            return self:LookTextInItem(slotID, "480 for 10")
        end
    )
end
function Library.HasLightweaveEmbroidery(self)
    return Memory.caching(
        self.gearCache,
        "lighweaveEmbroidery",
        function()
            local slotID, idk = GetInventorySlotInfo("BackSlot")
            if not slotID then
                return false
            end
            return self:LookTextInItem(slotID, "Lightweave Embroidery")
        end
    )
end
function Library.HasPowerTorrent(self)
    return Memory.caching(
        self.gearCache,
        "powerTorrent",
        function()
            local slotID, idk = GetInventorySlotInfo("MainHandSlot")
            if not slotID then
                return false
            end
            return self:LookTextInItem(slotID, "Power Torrent")
        end
    )
end
function Library.GetEnchantId(self, slot)
    local slotID, idk = GetInventorySlotInfo(slot)
    if not slotID then
        return 0
    end
    local link = awful.call("GetInventoryItemLink", "player", slotID)
    if not link then
        return 0
    end
    local one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve, enchantId = string.find(link, "item:(%d+):(%d+)")
    return enchantId
end
function Library.useSynapseSprings(self)
    local cid = awful.player.castIdEx
    if cid ~= 0 then
        local ctl = awful.player.castTimeLeft
        if ctl > 0.3 then
            return
        end
    end
    if not self:HasSynapseSpring() then
        return
    end
    if self:synapseSpringCD() > 0 then
        return
    end
    awful.call("UseInventoryItem", 10)
end
function Library.synapseSpringCD(self)
    local start, duration, enable = awful.call("GetInventoryItemCooldown", "player", 10)
    if enable == 1 and duration > 0 then
        local timeLeft = start + duration - GetTime()
        if timeLeft > 0 then
            return timeLeft
        else
            return 0
        end
    end
    return 0
end
function Library.GetTrinketIds(self)
    local trinket1 = GetInventoryItemID("player", 13)
    local trinket2 = GetInventoryItemID("player", 14)
    trinket1 = trinket1 and trinket1 or 0
    trinket2 = trinket2 and trinket2 or 0
    return trinket1, trinket2
end
function Library.freeToCastFor(self)
    return Memory.caching(
        self.libCache,
        "freeToCastFor",
        function()
            if not awful.arena then
                return 1000
            end
            local nextkickRdyIn = 1000
            local u = __TS__ArrayFind(
                awful.enemies,
                function(____, o)
                    local eta, interrupt = awful.interruptETA(o, awful.player)
                    if eta and interrupt and eta <= nextkickRdyIn then
                        nextkickRdyIn = eta
                    end
                end
            )
            return nextkickRdyIn
        end
    )
end
function Library.useHealthStone(self)
    if not healthStone.usable then
        return
    end
    if awful.player.castIdEx ~= 0 then
        return
    end
    local threshold = ravn.modernConfig:getMiscHealthstone()
    if not threshold then
        return
    end
    if type(threshold) ~= "number" then
        return
    end
    if awful.player.hp > threshold then
        return
    end
    if awful.player.class2 ~= WowClass.WARLOCK then
        healthStone:Use()
    end
    if not soulBurn:Castable() then
        healthStone:Use()
    else
        local cond = soulBurn.known and soulBurn.cd == 0 and awful.call("UnitPower", "player", 7) >= 1 or awful.player.buffRemains(soulBurn.id) > 0
        if cond and GetSpecialization() == 1 then
            if awful.player.buffRemains(soulBurn.id) > 0 then
                healthStone:Use()
            else
                soulBurn:Cast()
            end
        else
            healthStone:Use()
        end
    end
end
function Library.hasImportantPurge(self, o, miniumUptime)
    if miniumUptime == nil then
        miniumUptime = 0.7
    end
    local list = SpellList.importantDispels
    local spellToTrack = 0
    for ____, spell in ipairs(list) do
        if o.buff(spell) then
            local upTime = o.buffUptime(spell)
            if upTime >= miniumUptime then
                spellToTrack = spell
                break
            end
        end
    end
    return spellToTrack
end
function Library.findItemPosition(self, itemID)
    return Memory.caching(
        self.libCache,
        "findHealthStone",
        function()
            if healthStone.count == 0 then
                return {nil, nil}
            end
            for bag = 0, NUM_BAG_SLOTS do
                local bagSlots = C_Container.GetContainerNumSlots(bag)
                for slot = 1, bagSlots do
                    local intemInfos = C_Container.GetContainerItemInfo(bag, slot)
                    if intemInfos and intemInfos.itemID == itemID then
                        return {bag, slot}
                    end
                end
            end
            return {nil, nil}
        end
    )
end
function Library.isItemInTrade(self, itemId)
    for i = 1, MAX_TRADE_ITEMS - 1 do
        local itemID = GetTradePlayerItemLink(i)
        if itemID ~= nil then
            local szID = string.match(itemID, "item:(%d+):")
            if szID ~= nil then
                local id = tonumber(szID)
                if id and id == itemId then
                    return true
                end
            end
        end
    end
    return false
end
function Library.shareItem(self, itemId)
    if not TradeFrame:IsVisible() then
        return
    end
    if self:isItemInTrade(itemId) then
        AcceptTrade()
        return
    end
    local function freeSlot()
        for i = 1, MAX_TRADE_ITEMS - 1 do
            if not GetTradePlayerItemLink(i) then
                return i
            end
            return nil
        end
    end
    local slot = freeSlot()
    if not slot then
        return
    end
    local bag, slotInBag = unpack(self:findItemPosition(itemId))
    if not bag or not slotInBag then
        return
    end
    C_Container.PickupContainerItem(bag, slotInBag)
    ClickTradeButton(slot)
end
function Library.willSpellLand(self, spell, t)
    local ct = spell.castTime
    if t.cc or t.rooted then
        return true
    end
    if not t.predictLoS(ct) then
        return false
    end
    return true
end
function Library.delayFake(self, castTime)
    if castTime and castTime == 0 then
        return false
    end
    if not ravn.modernConfig:getMiscAutoFake() then
        return false
    end
    if self.fakeAttempt >= 4 then
        return false
    end
    return awful.time - self.fakeAllowedToCast <= 0
end
function Library.fakeCasting(self, faketatus, distanceAndLos, checkFacing)
    if faketatus == nil then
        faketatus = false
    end
    if distanceAndLos == nil then
        distanceAndLos = false
    end
    if checkFacing == nil then
        checkFacing = false
    end
    if not ravn.modernConfig:getMiscAutoFake() then
        return
    end
    if self.fakeAttempt >= 2 then
        return
    end
    if awful.player.cannotBeInterrupted then
        return
    end
    local ctl = awful.player.castTimeLeft
    if awful.player.castID and ctl <= 0.12 then
        return
    end
    local cid = awful.player.castIdEx
    if cid == 0 then
        return
    end
    if not __TS__ArrayIncludes(self.fakeSpellsId, cid) then
        return
    end
    local queuedFear = Queue.queues[Queue.WARLOCK_FEAR]
    if queuedFear and cid == fear.id then
        return
    end
    local list = awful.arena and awful.enemies or awful.enemies.filter(function(o) return o.isPlayer end)
    if awful.DevMode and awful.target.exists and awful.target.isdummy then
        list[#list + 1] = awful.target
    end
    local isChannel = awful.player.channelID
    local returnStatus = false
    list = list.filter(function(o) return o.class2 ~= WowClass.SHAMAN and o.class2 ~= WowClass.HUNTER end)
    __TS__ArrayForEach(
        list,
        function(____, o)
            local value, struct = awful.interruptETA(o, awful.player)
            local targetCondition = select(
                2,
                IsInInstance()
            ) == "arena" or o.target.exists and o.target.isUnit(awful.player)
            if o.isdummy then
                value = 0
                struct.id = SpellBook.PUMMEL
                struct.range = 6
                targetCondition = true
            end
            if struct ~= nil and o.los and o.distance <= struct.range + 1 and targetCondition and (struct.id and struct.id ~= SpellBook.SILENCING_SHOT) then
                if awful.player.immunePhysical and struct.school == "Physical" then
                    value = math.max(awful.player.physicalEffectImmunityRemains, value)
                end
                if awful.player.immuneMagicEffects and struct.school ~= "Physical" then
                    value = math.max(awful.player.magicEffectImmunityRemains, value)
                end
                if awful.DevMode and o.isdummy then
                    if checkFacing and not o.facing(awful.player) then
                        value = 100
                    else
                        value = 0
                    end
                end
                local ____isChannel_1
                if isChannel then
                    ____isChannel_1 = value < awful.player.channelTimeLeft
                else
                    ____isChannel_1 = value < ctl
                end
                local cond = ____isChannel_1
                if cond then
                    local pct, timechan = unpack(ravn.fakeTracker:unitKickPercent(o))
                    if not pct then
                        pct = 60
                    end
                    if not timechan then
                        timechan = 0.45
                    end
                    local icon = struct.id
                    if isChannel then
                        if ravn.modernConfig:getFakeCastStatus() then
                            local value = math.floor(timechan * 100 + 0.5)
                            local sz = ("Fake Casting at : " .. tostring(math.floor(value + 0.5) * 10)) .. "ms"
                            awful.alert(sz, icon)
                        end
                        local curChanTime = awful.player.castingSince
                        if curChanTime > timechan or math.abs(curChanTime - timechan) < 0.1 then
                            if faketatus then
                                returnStatus = true
                            else
                                self:stopCasting("FAKE CAST 1")
                                local offset = math.random(80, 180) / 100
                                self.fakeAllowedToCast = awful.time + offset
                            end
                            return
                        end
                    else
                        if ravn.modernConfig:getFakeCastStatus() then
                            local sz = ("Fake Casting at : " .. tostring(math.floor(pct + 0.5))) .. "%"
                            awful.alert(sz, icon)
                        end
                        local currentPercent = awful.player.castPct
                        if currentPercent > pct or math.abs(currentPercent - pct) < 5 then
                            if faketatus then
                                returnStatus = true
                            else
                                self:stopCasting("FAKE CAST 2")
                                local offset = math.random(90, 130) / 100
                                self.fakeAllowedToCast = awful.time + offset
                            end
                            return
                        end
                    end
                end
            end
        end
    )
    return returnStatus
end
Library._petCastTimer = 0
Library._petCommandTimer = 0
Library._immobileTimer = 0
Library.libCache = {}
Library.libMemoizedCache = {}
Library.sendAttackOrder = true
Library.targetCache = {}
Library.gearCache = {}
Library.bladeEdgePositionHelper = {mapID = 1672, topPosition = 4.6, bottomPosition = -4.2, farRequirements = {
    {{2776.2026367188, 6018.7221679688, 0.51246756315231}, 10},
    {{2800.9033203125, 5989.4985351562, 0.0086933001875877}, 10},
    {{2830.9682617188, 6020.109375, 0.20463071763515}, 10},
    {{2809.5036621094, 6044.634765625, -0.8573340177536}, 10},
    {{2763.4953613281, 5963.4184570312, 0.18228501081467}, 10},
    {{2742.7546386719, 5987.3647460938, 0.21542114019394}, 10}
}}
Library.dalaranPositionHelper = {mapID = 617, topPosition = 7.1, bottomPosition = 3.15, farRequirements = {{{1316.7250976562, 815.72698974609, 6.2410182952881}, 12}, {{1270.8903808594, 815.39904785156, 7.1148195266724}, 12}, {{1268.9825439453, 769.09606933594, 7.1148195266724}, 12}, {{1313.9364013672, 767.96374511719, 7.1148195266724}, 12}}}
Library.arenaPositions = {____exports.Library.bladeEdgePositionHelper, ____exports.Library.dalaranPositionHelper}
Library._immobileSince = 0
Library._movingSince = 0
Library.petLastCheckStatus = 0
Library.playerGlyphs = {}
Library.lastPetAutoCastCall = 0
Library.fakeAllowedToCast = 0
Library.fakeAttempt = 0
Library.fakeSpellsId = {}
Library.lastSuccessfulCasts = {}
Library.lastSuccessfulChannelsStart = 0
awful.Populate(
    {
        ["rotation.library"] = ____exports,
    },
    ravn,
    getfenv(1)
)
