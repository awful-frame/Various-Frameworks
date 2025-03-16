local Unlocker, awful, project = ...

project.priest.spells.mindgames:Callback("pve", function(spell)
    return
end)

project.priest.spells.mindgames:Callback("pvp", function(spell)
    if not project.settings.priest_offensives_mindgames then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if not project.util.enemy.danger then
        if project.util.check.enemy.magic_dispel() then
            return
        end
    end

    return project.util.cast.stop_moving(spell, project.util.enemy.best_target.unit, true)
            and project.util.debug.alert.offensive("Mindgames! noDISPEL", project.priest.spells.mindgames.id)
end)


