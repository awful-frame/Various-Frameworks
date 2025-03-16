local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____alerts = ravn["Interface.alerts.alerts"]
local Alert = ____alerts.Alert
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____spell = ravn["Utilities.spell"]
local Spell = ____spell.Spell
local ____hunterLib = ravn["rotation.hunter.hunterLib"]
local HunterLib = ____hunterLib.HunterLib
local PET_ACTION = ____hunterLib.PET_ACTION
local ____hunterspells = ravn["rotation.hunter.hunterspells"]
local arcaneShot = ____hunterspells.arcaneShot
local blackArrow = ____hunterspells.blackArrow
local cobraShot = ____hunterspells.cobraShot
local explosiveShot = ____hunterspells.explosiveShot
local explosiveTrapLaunched = ____hunterspells.explosiveTrapLaunched
local explosiveTrapNormal = ____hunterspells.explosiveTrapNormal
local huntersMark = ____hunterspells.huntersMark
local killShot = ____hunterspells.killShot
local misdirection = ____hunterspells.misdirection
local multiShot = ____hunterspells.multiShot
local raptorStrike = ____hunterspells.raptorStrike
local serpentSting = ____hunterspells.serpentSting
local steadyShot = ____hunterspells.steadyShot
local trapLauncher = ____hunterspells.trapLauncher
--- Min maxing
-- 
-- Do not waiste Lock and Load proc
-- Explosive no overlap
-- if low on facus can use cobra shot
____exports.survLib = __TS__Class()
local survLib = ____exports.survLib
survLib.name = "survLib"
__TS__ClassExtends(survLib, HunterLib)
function survLib.validPveUnits(self)
    return Memory.caching(
        self.libCache,
        "validPveUnits",
        function()
            local inInstance, instanceType = IsInInstance()
            if not inInstance or instanceType ~= "party" and instanceType ~= "raid" then
                return awful.enemies.filter(function(o) return o.isUnit(awful.target) or o.isUnit(awful.focus) end)
            end
            if instanceType ~= "party" and instanceType ~= "raid" then
                return
            end
            local units = awful.enemies.filter(function(o) return o.los and o.distance <= 40 and (o.combat and o.target.exists and o.target.isPlayer or o.isdummy) end)
            return units
        end
    )
end
function survLib.initSurvSpells(self)
    huntersMark:Callback(
        "default",
        function(spell, t)
            if t.friend then
                return
            end
            if awful.player.combat then
                local classification = UnitClassification("target")
                if classification == "worldboss" or classification == "rareelite" or classification == "elite" then
                    if t.hp >= 70 and not t.debuff(spell.id) then
                        spell:Cast(t)
                    end
                end
                if t.ttd <= 40 then
                    return
                end
            end
            if t.debuff(spell.id) then
                return
            end
            local timer = self:getDBMTimer()
            if timer > awful.gcd and timer < 6 then
                spell:Cast(t)
            end
        end
    )
    misdirection:Callback(
        "default",
        function(spell)
            if not awful.target.exists then
                return
            end
            local inInstance, instanceType = IsInInstance()
            if not inInstance then
                return
            end
            if instanceType ~= "party" and instanceType ~= "raid" then
                return
            end
            local tank = self:findTank()
            if not tank then
                return
            end
            local classi = UnitClassification("target")
            if classi ~= "worldboss" and classi ~= "elite" then
                return
            end
            local timer = self:getDBMTimer()
            local cond1 = timer > awful.gcd and timer < 6
            local cond2 = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return awful.player.isUnit(o.target) end
            )
            if cond1 or cond2 then
                spell:Cast(tank)
            end
        end
    )
    arcaneShot:Callback(
        "default",
        function(spell, t)
            if t.distanceLiteral <= 5 then
                return
            end
            local focus = awful.player.focus
            local costExplo = Spell.cost(explosiveShot.id)
            local costBlackArrow = Spell.cost(blackArrow.id)
            local costSpell = spell.cost.focus
            local focusAfter2GCD = focus + select(
                2,
                awful.call("GetPowerRegen")
            ) * awful.gcd * 2
            if focusAfter2GCD <= costExplo + costBlackArrow + costSpell then
                return
            end
            local cd = explosiveShot.cd
            local cd2 = blackArrow.cd
            if cd <= awful.player.gcdRemains + awful.buffer * 2 then
                return
            end
            if cd2 <= awful.player.gcdRemains + awful.buffer * 2 then
                return
            end
            spell:Cast(t)
        end
    )
    serpentSting:Callback(
        "default",
        function(spell, t)
            if t.hp <= 20 and not t.isdummy then
                return
            end
            if awful.player.level < 81 then
                if t.debuffRemains(spell.id) > 4.5 then
                    return
                end
            else
                local castTime = cobraShot.castTime
                if t.debuffRemains(spell.id) > castTime then
                    return
                end
            end
            spell:Cast(t)
        end
    )
    killShot:Callback(
        "default",
        function(spell, t)
            if t.hp <= 20 then
                spell:Cast(t)
            end
            local inInstance, instanceType = IsInInstance()
            if not inInstance then
                return
            end
            if instanceType ~= "party" and instanceType ~= "raid" then
                return
            end
            local another = __TS__ArrayFind(
                awful.enemies,
                function(____, o) return spell:Castable(o) and o.hp <= 20 end
            )
            if another then
                spell:Cast(another)
            end
        end
    )
    blackArrow:Callback(
        "default",
        function(spell, t)
            local ttd = t.ttd
            if ttd <= 18 and not t.isdummy then
                return
            end
            spell:Cast(t)
        end
    )
    blackArrow:Callback(
        "miniAoe",
        function(spell, t)
            local ttd = t.ttd
            if ttd > 18 then
                return spell:Cast(t)
            else
                local u = __TS__ArrayFind(
                    self:validPveUnits(),
                    function(____, o) return o.ttd > 18 and spell:Castable(o) end
                )
                if u then
                    spell:Cast(u)
                end
            end
        end
    )
    explosiveShot:Callback(
        "default",
        function(spell, t)
            local shouldWait = false
            if awful.player.buff(self.LOCK_AND_LOAD_BUFF) then
                if (t.debuffRemains(spell.id) > 0 or spell:Castable(t)) and t.debuffRemains(spell.id) <= awful.gcd then
                    shouldWait = "wait"
                end
            end
            if self:canApplyES(t) then
                if awful.time - self.lastExploTime <= awful.gcd then
                    return
                end
                spell:Cast(t)
            end
            return shouldWait
        end
    )
    explosiveShot:Callback(
        "mini-aoe",
        function(spell, t)
            local LL = awful.player.buff(self.LOCK_AND_LOAD_BUFF)
            if self:canApplyES(t) then
                spell:Cast(t)
            end
            if t.debuffRemainsFromMe(explosiveShot.id) > 0 and LL then
                local u = __TS__ArrayFind(
                    self:validPveUnits(),
                    function(____, o) return o.debuffRemainsFromMe(explosiveShot.id) <= 0 and spell:Castable(o) end
                )
                if u then
                    spell:Cast(u)
                end
            end
        end
    )
end
function survLib.canApplyES(self, t)
    local debuffRemains = t.debuffRemainsFromMe(explosiveShot.id)
    if debuffRemains <= 0 then
        return true
    end
    local projectileSpeed = 41
    local distance = t.distance
    local time = math.max(0, distance / projectileSpeed)
    if debuffRemains >= time then
        return false
    end
    return true
end
function survLib.autoTarget(self)
    if not awful.player.combat then
        return
    end
    local t = awful.target
    if t and t.exists then
        return
    end
    local a, b = IsInInstance()
    if b ~= "party" and b ~= "raid" then
        return
    end
    local tank = self:findTank()
    if not tank then
        return
    end
    if not tank or not tank.exists or tank.dead or not tank.visible then
        return
    end
    local u = __TS__ArrayFind(
        awful.enemies,
        function(____, o) return tank and tank.isUnit(o.target) and o.los and o.distance <= 40 end
    )
    if not u or not u.exists then
        return
    end
    u.setTarget()
end
function survLib.petComebackPve(self)
    local p = awful.pet
    if not p or not p.exists or p.dead then
        return
    end
    if awful.time - self.petCombackTimer > 0 then
        return
    end
    self.petBehaviour = PET_ACTION.COMEBACK
    if awful.time - self.lastPetCommandTimer < 0.2 then
        return
    end
    local tar = p.target
    if not tar.exists or tar.friend then
        return
    end
    awful.call("PetFollow")
    self.lastPetCommandTimer = awful.time
end
function survLib.pvePetBehaviour(self)
    self:petComebackPve()
    if self.petBehaviour == PET_ACTION.COMEBACK then
        return
    end
    if not awful.player.combat then
        return
    end
    if awful.target.exists and not awful.target.friend and not awful.target.dead then
        self:petAttack()
    end
end
function survLib.fillerLogic(self, t)
    local function fillerSpell()
        if awful.player.level < 81 then
            return steadyShot
        else
            return cobraShot
        end
    end
    local filler = fillerSpell()
    if awful.player.focus >= 40 and awful.player.buff(self.LOCK_AND_LOAD_BUFF) and awful.player.buffUptime(self.LOCK_AND_LOAD_BUFF) <= 1 and awful.player.castTimeLeft > 0.5 then
        if explosiveShot.cd <= awful.player.gcdRemains then
            self:stopCasting("Cancel to fast cast explosive shot")
        end
    end
    local cd = explosiveShot.cd
    local cd2 = blackArrow.cd
    if explosiveShot:Castable(t, {ignoreCasting = true}) then
        return
    end
    local playerFocus = self:playerFocus()
    if explosiveShot.cd <= 0.2 and playerFocus >= explosiveShot.cost.focus then
        return
    end
    if cd <= filler.castTime + awful.buffer then
        local costES = explosiveShot.cost.focus
        if awful.player.buff(self.LOCK_AND_LOAD_BUFF) then
            costES = 0
            return
        end
        local delta = costES - awful.player.focus
        if delta <= 2 then
            return
        end
        if playerFocus < costES then
            local time = self:timeToReachFocus(costES)
            if time <= cd then
                return
            end
        end
    end
    if cd2 <= filler.castTime + awful.player.gcdRemains + awful.buffer * 2 then
        local costBA = blackArrow.cost.focus
        if playerFocus < costBA then
            local time = self:timeToReachFocus(costBA)
            if time <= cd2 then
                return
            end
        end
    end
    filler:Cast(t)
end
function survLib.weaveLogic(self, t)
    local status = explosiveShot("default", t)
    if status == "wait" then
        local fillerReferal = awful.player.level >= 81 and cobraShot or steadyShot
        local remains = t.debuffRemains(explosiveShot.id)
        if killShot:Castable(t) and t.hp <= 20 then
            if remains >= awful.gcd then
                killShot:Cast(t)
            end
        end
        if awful.player.focus <= 60 then
            if remains <= fillerReferal.castTime + awful.buffer then
                self:fillerLogic(t)
            end
        end
        Alert.sendAlert(false, explosiveShot.id, "Explosive Shot", "Delay")
        return "wait"
    end
end
function survLib.launchedExplosiveTrap(self, t)
    if explosiveTrapNormal.cd > awful.gcd + awful.buffer then
        return
    end
    local tar = t.target
    local canHeMove = tar.exists and tar.distanceTo(t) > 7 and not t.cc and t.castIdEx ~= 0 and t.castTimeLeft <= 3 and not t.isdummy
    if not t.los or t.distance > 39 then
        return
    end
    if not awful.player.buff(trapLauncher.id) then
        return trapLauncher:Cast()
    end
    explosiveTrapLaunched:AoECast(t)
end
function survLib.STLogic(self, t)
    killShot("default", t)
    serpentSting("default", t)
    if self:weaveLogic(t) == "wait" then
        return
    end
    blackArrow("default", t)
    arcaneShot("default", t)
    self:fillerLogic(t)
end
function survLib.miniAOELogic(self, t)
    killShot("default", t)
    serpentSting("default", t)
    explosiveShot("mini-aoe", t)
    self:launchedExplosiveTrap(t)
    self:fillerLogic(t)
end
function survLib.AOELogic(self, t)
    multiShot:Cast(t)
    if awful.player.buff(self.LOCK_AND_LOAD_BUFF) then
        explosiveShot("mini-aoe", t)
    end
    killShot("default", t)
    self:fillerLogic(t)
end
function survLib.damageLoop(self)
    local t = awful.target
    if not t.exists or t.friend or not t.los then
        return
    end
    self:autoTarget()
    if t.distanceLiteral > 5 then
        huntersMark("default", t)
        misdirection("default")
        if not awful.player.combat and t.combat and not t.isPlayer then
            if not t.target.exists or not t.target.isPlayer then
                return
            end
        end
        local around = awful.enemies.filter(function(o) return o.los and o.distanceTo(t) <= 8 end)
        local l = #around
        if l <= 0 then
            return
        end
        local singleTarget = l == 1 or self.forceSingle
        local miniAOE = l < 4
        local AOE = l >= 4
        self:startAttack()
        local status = "SINGLE TARGET"
        if singleTarget then
            self:STLogic(t)
        elseif miniAOE then
            self:miniAOELogic(t)
            status = "MINI AOE"
        else
            self:AOELogic(t)
            status = "AOE"
        end
        Alert.sendAlert(false, 0, "Rotation", status)
    end
    if t.meleeRange then
        raptorStrike:Cast(t)
    end
end
survLib.LOCK_AND_LOAD_BUFF = 56453
survLib.forceSingle = false
survLib.forceApectfOtheWild = false
survLib.lastExploTime = 0
survLib.ETMoveTimer = 0
awful.Populate(
    {
        ["rotation.hunter.survival.survLib"] = ____exports,
    },
    ravn,
    getfenv(1)
)
