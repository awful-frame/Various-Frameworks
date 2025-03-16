local Unlocker, awful, project = ...

project.util.check.target.danger = function(target)
    local attackers

    if target.enemy then
        attackers = project.util.enemy.attackers.get(target.guid)
    end

    if target.friend then
        if project.util.friend.under50Hp >= 2 then
            return true
        end

        attackers = project.util.friend.attackers.get(target.guid)
    end

    if not attackers then
        return
    end

    if attackers.def_best == 0 then
        if target.hp <= 30 then
            return true
        end

        if target.hpa <= 50 and attackers.def == 0 and (attackers.cdp > 0 or attackers.t >= 3) then
            return true
        end

        if project.util.check.scenario.type() == "pve" and target.hpa <= 50 then
            return true
        end
    end

    return false
end