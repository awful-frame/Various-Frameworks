local Unlocker, awful, project = ...

project.util.check.target.trinket = function(target)
    if target.healer then
        if target.used(336126, 90) then
            return false
        end
    end

    if target.used(336126, 120) then
        return false
    end

    return true
end