local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArraySort = ____lualib.__TS__ArraySort
local ____exports = {}
local ____specDetection = ravn["SpecDetection.specDetection"]
local SpecDetection = ____specDetection.SpecDetection
local ____cache = ravn["Utilities.Cache.cache"]
local Cache = ____cache.Cache
local ____spellBook = ravn["Utilities.Lists.spellBook"]
local SpellBook = ____spellBook.SpellBook
local SpellSchool = ____spellBook.SpellSchool
local ____spellList = ravn["Utilities.Lists.spellList"]
local SpellList = ____spellList.SpellList
local ____color = ravn["Utilities.color"]
local Color = ____color.Color
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
local ____library = ravn["rotation.library"]
local Library = ____library.Library
awful.addObjectAttribute(
    "isUnderFullStun",
    function(o)
        return o.stunRemains > 0 and o.stunDR >= 0.5
    end
)
awful.addObjectAttribute(
    "color",
    function(o)
        local wowclass = o.class2
        local ____WowClass_COLOR_CODE_find_result_color_0 = __TS__ArrayFind(
            WowClass.COLOR_CODE,
            function(____, c) return c.wowClass == wowclass end
        )
        if ____WowClass_COLOR_CODE_find_result_color_0 ~= nil then
            ____WowClass_COLOR_CODE_find_result_color_0 = ____WowClass_COLOR_CODE_find_result_color_0.color
        end
        return ____WowClass_COLOR_CODE_find_result_color_0 or Color.WHITE
    end
)
awful.addObjectAttribute(
    "isJumping",
    function(o)
        return bit.band(o.movementFlags, 2048) ~= 0
    end
)
awful.addObjectFunction(
    "debuffRemainsFromMe",
    function(t, spellId)
        return t.debuffRemains(spellId, awful.player)
    end
)
awful.addObjectAttribute(
    "isCaster",
    function(o)
        return o.isRanged and o.class2 ~= WowClass.HUNTER
    end
)
awful.addObjectAttribute(
    "isDummyOrPlayer",
    function(o)
        return o.isdummy or o.isPlayer
    end
)
awful.addObjectAttribute(
    "defensiveWeight",
    function(t)
        local weight = 0
        __TS__ArrayForEach(
            SpellList.weightDefensiveBuff,
            function(____, o)
                if o.wowclass == t.class2 or o.wowclass == "ALL" then
                    if o.isDebuff then
                        if t.debuff(o.id) then
                            weight = weight + o.weight
                        end
                    else
                        if t.buff(o.id) then
                            weight = weight + o.weight
                        end
                    end
                end
            end
        )
        return weight
    end
)
awful.addObjectAttribute(
    "offensiveWeight",
    function(t)
        local weight = 0
        __TS__ArrayForEach(
            SpellList.weightOffensiveBuff,
            function(____, o)
                if t.buff(o.id) then
                    weight = weight + o.weight
                end
            end
        )
    end
)
awful.addObjectAttribute(
    "isHybrid",
    function(t)
        local hybridClass = {WowClass.SHAMAN, WowClass.DRUID, WowClass.PALADIN, WowClass.PRIEST}
        if t.isHealer then
            return false
        end
        return __TS__ArrayIncludes(hybridClass, t.class2)
    end
)
awful.addObjectFunction(
    "losPositionLiteral",
    function(t, p)
        local x, y, z = unpack(p)
        return t.losCoordsLiteral(x, y, z)
    end
)
awful.addObjectFunction(
    "distanceToLiteralPos",
    function(t, p)
        local x, y, z = unpack(p)
        return t.distanceToLiteral(x, y, z)
    end
)
awful.addObjectFunction(
    "attackers",
    function(t)
        local base = t.friend and awful.enemies or awful.friends
        base = base.filter(function(o) return o.isPlayer and o.ccRemains <= 0 end)
        local melee = base.filter(function(o) return t.isUnit(o.target) and o.isMelee and o.meleeRangeOf(t) and o.losOf(t) end)
        local ranged = base.filter(function(o) return t.isUnit(o.target) and o.isRanged and o.distanceTo(t) <= 40 and o.losOf(t) end)
        local burst = base.filter(function(o) return t.isUnit(o.target) and o.cds end)
        return base, melee, ranged, burst
    end
)
awful.addObjectAttribute(
    "castIdEx",
    function(t)
        if t.casting then
            return t.casting9 or 0
        end
        if t.channel then
            return t.channel8 or 0
        end
        return 0
    end
)
awful.addObjectAttribute(
    "cannotBeInterrupted",
    function(t)
        if t.channel then
            if t.channel7 then
                return true
            else
                return false
            end
        end
        if t.casting then
            if t.casting8 then
                return true
            else
                return false
            end
        end
        if not t.casting and not t.channel then
            return true
        end
        return false
    end
)
awful.addObjectFunction(
    "castingFrom",
    function(t, list)
        if not list or #list == 0 then
            return false
        end
        local id = t.castIdEx
        if id == 0 then
            return false
        end
        return __TS__ArrayIncludes(list, id)
    end
)
awful.addObjectAttribute(
    "msRemains",
    function(t)
        return t.debuffRemainsFromTable(SpellList.mortalStrikDebuffs)
    end
)
awful.addObjectFunction(
    "debuffRemainsFromTable",
    function(unit, listIds)
        local v = __TS__ArraySort(
            __TS__ArrayMap(
                __TS__ArrayFilter(
                    unit.debuffs,
                    function(____, o) return __TS__ArrayIncludes(listIds, o[10]) end
                ),
                function(____, o) return o[6] - GetTime() end
            ),
            function(____, a, b) return b - a end
        )
        if #v <= 0 then
            return 0
        end
        return v[1]
    end
)
awful.addObjectFunction(
    "buffRemainsFromTable",
    function(unit, listIds)
        local v = __TS__ArraySort(
            __TS__ArrayMap(
                __TS__ArrayFilter(
                    unit.buffs,
                    function(____, o) return __TS__ArrayIncludes(listIds, o[10]) end
                ),
                function(____, o) return o[6] - GetTime() end
            ),
            function(____, a, b) return b - a end
        )
        if #v <= 0 then
            return 0
        end
        return v[1]
    end
)
awful.addObjectFunction(
    "debuffUptimeFromTable",
    function(unit, listIds)
        local v = __TS__ArraySort(
            __TS__ArrayMap(
                __TS__ArrayFilter(
                    unit.debuffs,
                    function(____, o) return __TS__ArrayIncludes(listIds, o[10]) end
                ),
                function(____, a) return a[5] - math.abs(a[6] - GetTime()) end
            ),
            function(____, a, b) return b - a end
        )
        if #v <= 0 then
            return 0
        end
        return v[1]
    end
)
awful.addObjectFunction(
    "debuffUptimeFromTableEx",
    function(unit, listIds, minimumTime)
        local listImportant = {}
        listImportant = __TS__ArrayMap(
            __TS__ArrayFilter(
                unit.debuffs,
                function(____, o) return __TS__ArrayIncludes(listIds, o[10]) end
            ),
            function(____, a)
                local uptime = a[5] - math.abs(a[6] - GetTime())
                return {id = a[10], uptime = uptime}
            end
        )
        __TS__ArraySort(
            listImportant,
            function(____, a, b) return b.uptime - a.uptime end
        )
        if #listImportant <= 0 then
            return 0
        end
        if listImportant[1].uptime >= minimumTime then
            return listImportant[1].id
        end
        return 0
    end
)
awful.addObjectFunction(
    "buffUptimeFromTable",
    function(unit, listIds)
        local v = __TS__ArraySort(
            __TS__ArrayMap(
                __TS__ArrayFilter(
                    unit.buffs,
                    function(____, o) return __TS__ArrayIncludes(listIds, o[10]) end
                ),
                function(____, a) return a[5] - math.abs(a[6] - GetTime()) end
            ),
            function(____, a, b) return b - a end
        )
        if #v <= 0 then
            return 0
        end
        return v[1]
    end
)
awful.addObjectAttribute(
    "isSmoked",
    function(t)
        return t.debuff(SpellBook.SMOKE_BOMB)
    end
)
awful.addObjectAttribute(
    "ttce",
    function(u)
        local cache = Cache.combatTrackerCache[u.guid]
        if cache == nil then
            return nil
        else
            if not u.combat then
                Cache.combatTrackerCache[u.guid] = GetTime() - 8
                return 0
            else
                return math.max(
                    0,
                    6 - (GetTime() - cache)
                )
            end
        end
    end
)
awful.addObjectAttribute(
    "justTrinketed",
    function(u)
        return __TS__ArrayIncludes(Cache.justTrinketedCache, u.guid)
    end
)
awful.addObjectAttribute(
    "trinketReadyIn",
    function(u)
        local cached = Cache.trinketTrackerCache[u.guid]
        if cached == nil then
            return 0
        else
            local expiration = cached - GetTime()
            if expiration < 0 then
                Cache.trinketTrackerCache[u.guid] = nil
                return 0
            else
                return expiration
            end
        end
    end
)
awful.addObjectAttribute(
    "isGapclosing",
    function(u)
        local cached = Cache.gapcloseCache[u.guid]
        return cached ~= nil
    end
)
awful.addObjectAttribute(
    "isDeathing",
    function(u)
        local cached = Cache.swdCache[u.guid]
        return cached ~= nil
    end
)
awful.addObjectAttribute(
    "castingSince",
    function(t)
        if t.casting then
            local now = GetTime()
            local start = t.casting4 or 0
            start = start * 0.001
            local total = now - start
            return total
        end
        if t.channel then
            local now = GetTime()
            local start = t.channel4 or 0
            start = start * 0.001
            local total = now - start
            return total
        end
    end
)
awful.addObjectAttribute(
    "totalCastTime",
    function(t)
        if not t.casting then
            return 0
        end
        local start = t.casting4 or 0
        local ____end = t.casting5 or 0
        local total = ____end - start
        local inSeconds = total * 0.001
        return inSeconds
    end
)
awful.addObjectAttribute(
    "immobileSince",
    function(t)
        local value = Library._immobileSince
        if value == 0 then
            return 0
        end
        return awful.time - value
    end
)
awful.addObjectAttribute(
    "movingSince",
    function(t)
        local value = Library._movingSince
        if value == 0 then
            return 0
        end
        return awful.time - value
    end
)
awful.addObjectAttribute(
    "raidTargetIndex",
    function(t)
        local value = awful.call("GetRaidTargetIndex", t.pointer)
        local ____value_2 = value
        if ____value_2 == nil then
            ____value_2 = -1
        end
        return ____value_2
    end
)
awful.addObjectAttribute(
    "specIdEx",
    function(unit)
        if not unit or not unit.visible or not unit.exists or not unit.guid then
            return
        end
        local value = SpecDetection.specCache[unit.guid .. "-specId"]
        if not value then
            return nil
        end
        return value
    end
)
awful.addObjectAttribute(
    "bccLock",
    function(t)
        local bcc = t.bcc
        if bcc == SpellBook.FEAR or bcc == SpellBook.HOWL_OF_TERROR then
            return false
        end
        local remains = t.debuffRemainsFromTable(SpellList.hexes)
        if remains > 0 and remains <= 3 then
            return false
        end
        return bcc
    end
)
awful.addObjectAttribute(
    "bccRemainsLock",
    function(t)
        local bcc = t.bccLock
        if not bcc then
            return 0
        end
        return t.bccRemains
    end
)
awful.addObjectAttribute(
    "kickId",
    function(t)
        if not t or not t.exists or not t.visible then
            return 0
        end
        if t.class2 == WowClass.DRUID then
            return SpellBook.SKULL_BASH_CAT
        end
        if t.class2 == WowClass.WARRIOR then
            return SpellBook.PUMMEL
        end
        if t.class2 == WowClass.ROGUE then
            return SpellBook.KICK
        end
        if t.class2 == WowClass.SHAMAN then
            return SpellBook.WIND_SHEAR
        end
        if t.class2 == WowClass.PALADIN then
            return SpellBook.REBUKE
        end
        if t.class2 == WowClass.MAGE then
            return SpellBook.COUNTERSPELL
        end
        if t.class2 == WowClass.HUNTER then
            return SpellBook.SILENCING_SHOT
        end
        if t.class2 == WowClass.DEATHKNIGHT then
            return 47528
        end
    end
)
awful.addObjectAttribute(
    "isDrinking",
    function(t)
        local buffs = {87959, 80167}
        return t.buffRemainsFromTable(buffs) > 0
    end
)
awful.addObjectAttribute(
    "advancedBurstSince",
    function(t)
        if t.isHealer == true then
            return 0
        end
        if t.class2 == WowClass.WARRIOR then
            local tar = t.target
            if tar and tar.exists and tar.visible then
                if tar.immunePhysicalDamage then
                    return 0
                end
                if tar.debuffRemains(SpellBook.COLOSSUS_SMASH, t) > 0 then
                    return tar.debuffUptime(SpellBook.COLOSSUS_SMASH)
                end
                if tar.debuff(SpellBook.THROWDOWN) then
                    return tar.debuffUptime(SpellBook.THROWDOWN)
                end
            end
        end
        if t.specId == 70 then
            if t.buff(SpellBook.ZEALOTRY) then
                return t.buffUptime(SpellBook.ZEALOTRY)
            end
            if t.buff(SpellBook.AVENGING_WRATH) then
                return t.buffUptime(SpellBook.AVENGING_WRATH)
            end
        end
        if t.class2 == WowClass.DEATHKNIGHT then
            if t.buff(SpellBook.UNHOLY_FRENZY) then
                return t.buffUptime(SpellBook.UNHOLY_FRENZY)
            end
        end
        if t.specId == 262 then
            if t.buff(SpellBook.ELEMENTAL_MASTERY) then
                return t.buffUptime(SpellBook.ELEMENTAL_MASTERY)
            end
        elseif t.specId == 263 then
            local cd = t.cooldown(SpellBook.FERAL_SPIRIT)
            local baseCD = 120
            local castedLast15Sec = cd > 105
            if castedLast15Sec then
                return baseCD - cd
            end
        end
        if t.class2 == WowClass.HUNTER then
            local buffRoar = t.buffUptime(53517)
            local buffRapidFire = t.buffUptime(SpellBook.RAPID_FIRE)
            local max = math.max(buffRoar, buffRapidFire)
            return max
        end
        if t.class2 == WowClass.DRUID then
            if t.buff(SpellBook.BERSERK) then
                return t.buffUptime(SpellBook.BERSERK)
            end
        end
        if t.class2 == WowClass.MAGE then
            if t.buff(SpellBook.ICY_VEINS) then
                return t.buffUptime(SpellBook.ICY_VEINS)
            end
            if t.buff(SpellBook.COMBUSTION) then
                return t.buffUptime(SpellBook.COMBUSTION)
            end
        end
        if t.class2 == WowClass.WARLOCK then
            if t.buff(79460) then
                return t.buffUptime(79460)
            end
        end
        if t.class2 == WowClass.PRIEST then
            if t.buff(SpellBook.SHADOWFORM) then
                if t.buff(SpellBook.ARCHANGEL) then
                    return t.buffUptime(SpellBook.ARCHANGEL)
                end
            end
        end
        if t.class2 == WowClass.ROGUE then
            if t.buff(SpellBook.SHADOW_DANCE) then
                return t.buffUptime(SpellBook.SHADOW_DANCE)
            end
        end
        return 0
    end
)
awful.addObjectFunction(
    "lockoutRemains",
    function(t, school)
        local base = nil
        repeat
            local ____switch142 = school
            local ____cond142 = ____switch142 == SpellSchool.ARCANE
            if ____cond142 then
                base = t.lockouts.arcane
                break
            end
            ____cond142 = ____cond142 or ____switch142 == SpellSchool.FIRE
            if ____cond142 then
                base = t.lockouts.fire
                break
            end
            ____cond142 = ____cond142 or ____switch142 == SpellSchool.FROST
            if ____cond142 then
                base = t.lockouts.frost
                break
            end
            ____cond142 = ____cond142 or ____switch142 == SpellSchool.HOLY
            if ____cond142 then
                base = t.lockouts.holy
                break
            end
            ____cond142 = ____cond142 or ____switch142 == SpellSchool.NATURE
            if ____cond142 then
                base = t.lockouts.nature
                break
            end
            ____cond142 = ____cond142 or ____switch142 == SpellSchool.SHADOW
            if ____cond142 then
                base = t.lockouts.shadow
                break
            end
        until true
        if not base then
            return 0
        end
        return base.remains
    end
)
awful.addObjectAttribute(
    "importantLockoutRemains",
    function(t)
        if t.class2 == WowClass.PRIEST then
            if t.buff(SpellBook.SHADOWFORM) then
                return t.lockoutRemains(SpellSchool.SHADOW)
            else
                return t.lockoutRemains(SpellSchool.HOLY)
            end
        end
        if t.class2 == WowClass.DRUID then
            return t.lockoutRemains(SpellSchool.NATURE)
        end
        if t.class2 == WowClass.SHAMAN then
            return t.lockoutRemains(SpellSchool.NATURE)
        end
        if t.class2 == WowClass.PALADIN then
            return t.lockoutRemains(SpellSchool.HOLY)
        end
        return 0
    end
)
awful.addObjectAttribute(
    "currentSchool",
    function(t)
        local value = t.castingSchool or t.channelingSchool
        if not value then
            return nil
        else
            return value
        end
    end
)
awful.Populate(
    {
        ["Extension.awfulExtension"] = ____exports,
    },
    ravn,
    getfenv(1)
)
