local Unlocker, awful, ravn = ...
local ____exports = {}
____exports.Spell = {}
local Spell = ____exports.Spell
do
    function Spell.getName(spellid)
        local name = {GetSpellInfo(spellid)}
        return name[1] or tostring(spellid)
    end
    function Spell.lockoutDuration(spellid)
        return 0
    end
    function Spell.cd(spellID)
        if spellID == 2061 then
            spellID = 605
        end
        local start, duration, ____ = GetSpellCooldown(spellID)
        local time = GetTime()
        if not start or start == 0 then
            return 0
        end
        local value = duration + (start - time)
        if value > 0 then
            return value
        else
            return 0
        end
    end
    function Spell.baseCD(spellID)
        local baseCD, incursdGCD = GetSpellBaseCooldown(spellID)
        return baseCD
    end
    function Spell.cost(spellId)
        local tbl = GetSpellPowerCost(spellId)
        if not tbl then
            return 0
        end
        local x = tbl[1]
        if not x then
            return 0
        end
        return x.cost
    end
end
awful.Populate(
    {
        ["Utilities.spell"] = ____exports,
    },
    ravn,
    getfenv(1)
)
