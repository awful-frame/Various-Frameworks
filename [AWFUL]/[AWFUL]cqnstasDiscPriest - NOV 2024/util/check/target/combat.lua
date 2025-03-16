local Unlocker, awful, project = ...

project.util.check.target.combat = function(target)
    if not target then
        return 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    end

    local total, melee, ranged, cds, cdp, cds_big, cds_small = project.util.check.target.attackers(target)
    local def, def_dr, def_best = project.util.check.target.defensives(target)

    return total or 0, melee or 0, ranged or 0, cds or 0, cdp or 0, cds_big or 0, cds_small or 0, def or 0, def_dr or 0, def_best or 0
end
