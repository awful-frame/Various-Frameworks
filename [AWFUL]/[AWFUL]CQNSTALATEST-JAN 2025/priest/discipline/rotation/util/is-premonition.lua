local Unlocker, awful, project = ...

project.priest.discipline.rotation.util.is_premonition = function()
    return IsPlayerSpell(project.util.id.spell.PREMONITION)
end