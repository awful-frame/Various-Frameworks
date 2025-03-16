local Unlocker, awful, project = ...

project.priest.discipline.rotation.util.is_premonition = function()
    if IsPlayerSpell(428924) then
        return true
    end
    return false
end