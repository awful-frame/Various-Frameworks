local Unlocker, awful, project = ...

project.priest.spells.life:Callback("default", function(spell)
    local threshold = 35

    if project.priest.discipline.rotation.util.is_premonition()
            and awful.player.hasTalent(project.util.id.spell.MIRACULOUS_RECOVERY_TALENT) then
        threshold = 50
    end

    if project.util.friend.best_target.unit.hp > threshold then
        return
    end

    return spell:Cast(project.util.friend.best_target.unit)
            and project.util.debug.alert.heal("Power Word: Life! default", project.priest.spells.life.id)
end)