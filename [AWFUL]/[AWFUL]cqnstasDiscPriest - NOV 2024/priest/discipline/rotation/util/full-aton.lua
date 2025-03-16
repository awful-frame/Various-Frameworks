local Unlocker, awful, project = ...

project.priest.discipline.rotation.util.full_aton = function()
    if project.util.check.scenario.type() == "pvp" then
        if project.util.friend.bestTarget.buffRemains("Atonement") < 3 + project.util.thresholds.buff() then
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