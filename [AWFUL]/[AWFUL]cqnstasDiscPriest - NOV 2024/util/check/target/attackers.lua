local Unlocker, awful, project = ...

local unable_to_attack_buffs = {
    ["Ice Block"] = true,
    ["Dispersion"] = true,
    ["Aspect of the Turtle"] = true,
    ["Netherwalk"] = true,
    ["Burrow"] = true,
}

project.util.check.target.attackers = function(target)
    local total, melee, ranged, cds, cdp, cds_big, cds_small = 0, 0, 0, 0, 0, 0, 0

    if not target then
        return total, melee, ranged, cdp, cds, cds_big, cds_small
    end

    local list

    if target.friend then
        list = awful.enemies
    end

    if target.enemy then
        list = awful.fgroup
    end

    if not list then
        return
    end

    list.loop(function(attacker)
        if not attacker.target then
            return
        end

        if attacker.target.guid ~= target.guid then
            return
        end

        if attacker.healer then
            return
        end

        if attacker.cc then
            return
        end

        if not attacker.losOf(target) then
            return
        end

        if attacker.buffFrom(unable_to_attack_buffs) then
            return
        end

        if attacker.melee then
            if attacker.meleeRangeOf(target)
                    or attacker.distanceTo(target) < 15
                    or (attacker.class == "Paladin" and attacker.distanceTo(target) < 25) then
                total = total + 1
                melee = melee + 1
            end
        end

        if attacker.ranged and attacker.distanceTo(target) <= 40 then
            total = total + 1
            ranged = ranged + 1
        end

        if not attacker.melee and not attacker.ranged then
            total = total + 1
        end

        local total_cds, big_cds, small_cds = project.util.check.target.cooldowns(target, attacker)
        if total_cds > 0 then
            cdp = cdp + 1
            cds = cds + total_cds
            cds_big = cds_big + big_cds
            cds_small = cds_small + small_cds
        end
    end)

    return total, melee, ranged, cds, cdp, cds_big, cds_small
end
