local Unlocker, awful, project = ...

project.priest.discipline.rotation.cc = function(type)
    if not project.settings.priest_cc_enabled then
        return
    end

    if awful.player.buff("Arena Preparation") then
        return
    end

    if awful.player.buff("Preparation") then
        return
    end

    local count, enemies = project.priest.discipline.rotation.util.fearable_enemies()

    return project.priest.spells.psychicScream(type, count, enemies)
            or project.priest.spells.mindControl(type)
end
