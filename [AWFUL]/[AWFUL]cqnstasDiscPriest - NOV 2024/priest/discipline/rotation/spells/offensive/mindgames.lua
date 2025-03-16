local Unlocker, awful, project = ...

project.priest.spells.mindgames:Callback("pve", function(spell)
    return
end)

project.priest.spells.mindgames:Callback("pvp", function(spell)
    if not project.settings.priest_offensives_mindgames then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if not project.util.enemy.danger then
        if project.util.check.enemy.magic_dispel() then
            return
        end
    end

    if not awful.player.hasTalent("Mindgames") then
        return
    end

    return spell:Cast(project.util.enemy.bestTarget, { stopMoving = true, face = true })
            and project.util.debug.alert.offensive("Mindgames! noDISPEL", project.priest.spells.mindgames.id)
end)


