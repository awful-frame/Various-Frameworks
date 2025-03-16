local Unlocker, awful, project = ...

project.priest.discipline.rotation.defensive = function(type)
    if not project.settings.priest_defensives_enabled then
        return
    end

    return project.util.spells.defensive.healthstone(type)
            or project.priest.spells.desperatePrayer(type)
            or project.priest.spells.fade(type)
end
