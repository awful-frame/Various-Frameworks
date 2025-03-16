local Unlocker, awful, project = ...

project.priest.spells.life:Callback("default", function(spell)
    local threshold = 35

    if project.priest.discipline.rotation.util.is_premonition() then
        if awful.player.hasTalent("Miraculous Recovery") then
            threshold = 50
        end
    end

    if project.util.friend.bestTarget.hp > threshold then
        return
    end

    return spell:Cast(project.util.friend.bestTarget)
            and project.util.debug.alert.heal("Power Word: Life! default", project.priest.spells.life.id)
end)