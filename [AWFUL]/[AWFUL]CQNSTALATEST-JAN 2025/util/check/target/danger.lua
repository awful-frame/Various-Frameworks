local Unlocker, awful, project = ...

project.util.check.target.danger = function(target)
    if target.friend then
        if project.util.friend.under50Hp >= 2 then
            return true
        end
    end

    local attackers = project.util.check.target.attackers(target)
    local defensives = project.util.check.target.defensives(target)

    if defensives.def_best == 0 then
        if target.hp <= 30 then
            return true
        end

        if target.hpa <= 50 and defensives.def == 0 and (attackers.cdp > 0 or attackers.total >= 3) then
            return true
        end

        if not awful.arena
                and project.util.check.scenario.type() == "pve"
                and target.hpa <= 50 then
            return true
        end
    end

    return false
end