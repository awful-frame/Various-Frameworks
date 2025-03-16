local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local ____exports = {}
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local ____Memory = ravn["Utilities.Memory.Memory"]
local Memory = ____Memory.Memory
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
____exports.arena = __TS__Class()
local arena = ____exports.arena
arena.name = "arena"
function arena.prototype.____constructor(self)
end
function arena.targetSince(self, u)
    if not u.isPlayer then
        return 0
    end
    local tar = u.target
    local cached = self.targetSinceTable[u.guid]
    if cached == nil then
        if not tar.exists then
            self.targetSinceTable[u.guid] = nil
            return 0
        else
            local cache = {
                guid = tar.guid,
                timer = GetTime()
            }
            self.targetSinceTable[u.guid] = cache
            return 0
        end
    else
        if not tar.exists then
            self.targetSinceTable[u.guid] = nil
            return 0
        else
            if tar.guid == cached.guid then
                return GetTime() - cached.timer
            else
                local cache = {
                    guid = tar.guid,
                    timer = GetTime()
                }
                self.targetSinceTable[u.guid] = cache
                return 0
            end
        end
    end
end
function arena.targetUpdate(self)
    self:targetSince(awful.player)
    if not awful.arena then
        return
    end
    __TS__ArrayForEach(
        awful.enemies,
        function(____, e)
            self:targetSince(e)
        end
    )
    __TS__ArrayForEach(
        awful.friends,
        function(____, f)
            self:targetSince(f)
        end
    )
end
function arena.RLSPressure(self)
    if ravn.pressureRLSDebug then
        return true
    end
    if not awful.arena then
        return false
    end
    local rogue = __TS__ArrayFind(
        awful.friends,
        function(____, o) return o.isPlayer and o.class2 == WowClass.ROGUE end
    )
    if not rogue then
        return false
    end
    local rogueTarget = rogue.target
    if not rogueTarget.exists then
        return false
    end
    if not rogueTarget.isPlayer then
        return false
    end
    if rogueTarget.friend then
        return false
    end
    if rogueTarget.hp > 60 then
        return false
    end
    return rogueTarget.stunRemains > 0 or rogueTarget.isSmoked or rogue.debuffRemains(SpellBook.GARROTE)
end
function arena.getOffTarget(self)
    if not awful.arena then
        return nil
    end
    return Memory.caching(
        self.cache,
        "offTarget",
        function()
            local currentTarget = awful.player.target
            if not currentTarget or not currentTarget.isPlayer or not currentTarget.exists then
                return nil
            end
            local arenaBracket = GetNumGroupMembers()
            if arenaBracket == 2 and currentTarget then
                local off = __TS__ArrayFind(
                    awful.enemies,
                    function(____, o) return o.isPlayer and not o.isUnit(awful.target) end
                )
                if off and off.exists then
                    return off
                else
                    return nil
                end
            elseif arenaBracket == 3 and currentTarget then
                local enemyHealer = awful.enemyHealer
                if not enemyHealer.exists then
                    return nil
                end
                if currentTarget.isUnit(enemyHealer) then
                    return nil
                end
                local off = __TS__ArrayFind(
                    awful.enemies,
                    function(____, o) return o.isPlayer and not o.isUnit(awful.target) and not o.isUnit(enemyHealer) end
                )
                if off and off.exists then
                    return off
                else
                    return nil
                end
            else
                return nil
            end
        end
    )
end
function arena.getFriendTarFromClass(self, wowclass)
    if not awful.arena then
        return nil
    end
    return Memory.caching(
        self.cache,
        "getFriendTarFromClass",
        function()
            local off = __TS__ArrayFind(
                awful.friends,
                function(____, o) return o.isPlayer and o.class2 == wowclass end
            )
            if not off then
                return nil
            end
            local tar = off.target
            if not tar.exists then
                return nil
            end
            return tar
        end
    )
end
function arena.getFriendDPS(self)
    if not awful.arena then
        return nil
    end
    return Memory.caching(
        self.cache,
        "friendDPS",
        function()
            local off
            if GetNumGroupMembers() == 2 then
                off = __TS__ArrayFind(
                    awful.friends,
                    function(____, o) return o.isPlayer end
                )
            elseif GetNumGroupMembers() == 3 then
                if not awful.healer.exists then
                    return nil
                end
                off = __TS__ArrayFind(
                    awful.friends,
                    function(____, e) return e.isPlayer and not e.isUnit(awful.healer) end
                )
            end
            if not off or not off.exists then
                return nil
            end
            return off
        end
    )
end
function arena.inPrep(self)
    if not awful.arena then
        return false
    end
    return awful.player.buff(32727) ~= nil
end
function arena.healerExists(self)
    if not awful.arena then
        return false
    end
    local equal = #awful.fullGroup == #awful.enemies
    if not equal then
        return "?"
    end
    return __TS__ArraySome(
        awful.enemies,
        function(____, o) return o.isHealer end
    )
end
function arena.getFriendDps(self)
    return Memory.caching(
        self.cache,
        "getFriendDps",
        function()
            if not awful.arena then
                return nil
            end
            local off
            if GetNumGroupMembers() == 2 then
                off = __TS__ArrayFind(
                    awful.friends,
                    function(____, o) return o.isPlayer end
                )
                return off
            end
            local classDPS = {
                WowClass.DEATHKNIGHT,
                WowClass.HUNTER,
                WowClass.MAGE,
                WowClass.ROGUE,
                WowClass.WARLOCK
            }
            local isDefinitelyDPS = __TS__ArrayFind(
                awful.friends,
                function(____, o) return o.isPlayer and __TS__ArrayIncludes(classDPS, o.class2) end
            )
            if isDefinitelyDPS then
                off = isDefinitelyDPS
                return off
            else
                off = __TS__ArrayFind(
                    awful.friends,
                    function(____, o) return o.isPlayer and not o.isHealer end
                )
                return off
            end
        end
    )
end
function arena.pressureApplied(self)
    if not awful.arena then
        return false
    end
    local t = awful.target
    if not t.exists then
        return false
    end
    if t.friend then
        return false
    end
    if not t.isPlayer then
        return false
    end
    local cond1 = t.stunRemains > 0
    local cond2 = t.isSmoked
    local h = awful.enemyHealer
    local cond3 = h.isUnit(t) or h.ccRemains > 4
    local friendDPS = self:getFriendDps()
    local constMandatory = not friendDPS or friendDPS.isHealer or t.isUnit(friendDPS.target)
    if not constMandatory then
        return false
    end
    return cond1 or cond2 or cond3
end
function arena.getLowestEnemy(self)
    if not awful.arena then
        return nil
    end
    return Memory.caching(
        self.cache,
        "getLowestEnemy",
        function()
            local lowest = awful.enemies.filter(function(o) return o.isPlayer and not o.dead end).sort(function(a, b) return a.hp < b.hp end)[1]
            return lowest or nil
        end
    )
end
function arena.getHealerOrSecondUnit(self)
    if not awful.arena then
        if not awful.DevMode then
            return nil
        end
        if awful.focus.exists and awful.focus.isdummy then
            return awful.focus
        end
    end
    local bracket = GetNumGroupMembers()
    local equal = #awful.fullGroup == #awful.enemies
    local t = awful.target
    if not t.exists then
        return
    end
    local healer = awful.enemyHealer
    if bracket == 2 then
        if not healer.exists then
            return __TS__ArrayFind(
                awful.enemies,
                function(____, o) return o.isPlayer and not o.isUnit(t) end
            )
        else
            if healer.isUnit(t) then
                return nil
            else
                return healer
            end
        end
    elseif bracket == 3 then
        if not healer.exists or healer.isUnit(awful.target) then
            return nil
        end
        return healer
    elseif bracket == 5 then
        return __TS__ArrayFind(
            awful.enemies,
            function(____, o) return o.isHealer and not o.isUnit(awful.target) end
        )
    end
end
arena.cache = {}
arena.targetSinceTable = {}
awful.Populate(
    {
        ["arena.arena"] = ____exports,
    },
    ravn,
    getfenv(1)
)
