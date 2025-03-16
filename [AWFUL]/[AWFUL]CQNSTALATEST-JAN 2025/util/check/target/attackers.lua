local Unlocker, awful, project = ...

local unable_to_attack_buffs = {
    project.util.id.spell.ICE_BLOCK,
    project.util.id.spell.DISPERSION,
    project.util.id.spell.ASPECT_OF_THE_TURTLE,
    project.util.id.spell.NETHERWALK,
    project.util.id.spell.BURROW,
}

project.util.check.target.attackers = function(target)
    if not target then
        return { total = 0, melee = 0, ranged = 0, cds = 0, cdp = 0, cds_big = 0, cds_small = 0 }
    end

    local result = {
        total = 0,
        melee = 0,
        ranged = 0,
        cds = 0,
        cdp = 0,
        cds_big = 0,
        cds_small = 0,
    }

    local list
    if target.friend then
        list = awful.enemies
    elseif target.enemy then
        list = awful.fgroup
    end

    if not list then
        return result
    end

    list.loop(function(attacker)
        if not attacker.target
                or attacker.target.guid ~= target.guid then
            return
        end

        if attacker.healer
                or attacker.cc
                or not attacker.losOf(target)
                or attacker.buffFrom(unable_to_attack_buffs) then
            return
        end

        if attacker.melee then
            if attacker.meleeRangeOf(target)
                    or attacker.distanceTo(target) < 15 then
                result.total = result.total + 1
                result.melee = result.melee + 1
            end
        end

        if attacker.ranged and attacker.distanceTo(target) <= 40 then
            result.total = result.total + 1
            result.ranged = result.ranged + 1
        end

        if not attacker.melee and not attacker.ranged then
            result.total = result.total + 1
        end

        local cooldowns = project.util.check.target.cooldowns(target, attacker)
        if cooldowns.total > 0 then
            result.cdp = result.cdp + 1
            result.cds = result.cds + cooldowns.total
            result.cds_big = result.cds_big + cooldowns.big
            result.cds_small = result.cds_small + cooldowns.small
        end
    end)

    return result
end
