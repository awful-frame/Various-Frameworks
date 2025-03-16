local Unlocker, awful, project = ...

project.priest.discipline.rotation.util.full_aton = function(big)
    if big then
        if project.util.friend.withBigAtonement ~= project.util.friend.within30Yards then
            return
        end
    end

    if project.util.check.scenario.type() == "pvp" then
        if project.util.friend.best_target.unit.buffRemains(project.util.id.spell.ATONEMENT) < 3 + project.util.thresholds.buff() then
            return
        end
    end

    if project.util.friend.total <= 5 then
        if project.util.friend.withAtonement30Yards ~= project.util.friend.within30Yards then
            return
        end
    else
        if project.util.friend.withAtonement < 5 then
            return
        end
    end

    return true
end