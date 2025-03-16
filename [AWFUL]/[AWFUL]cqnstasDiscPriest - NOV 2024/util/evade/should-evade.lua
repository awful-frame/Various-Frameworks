local Unlocker, awful, project = ...

project.util.evade.should_evade = function()
    if project.util.check.scenario.type() ~= "pvp" then
        return
    end

    if awful.player.channel == "Ultimate Penitence" then
        return
    end

    if awful.player.channel == "Mind Control" then
        return
    end

    if awful.player.casting == "Ultimate Penitence"
            and awful.player.castRemains < 0.2 then
        return
    end

    if project.priest.spells.death.cd > 2
            and project.priest.spells.fade.cd > 2
            and project.util.spells.racials.shadowmeld.cd > 2 then
        return
    end

    return true
end