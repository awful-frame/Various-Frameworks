local Unlocker, awful, project = ...

project.priest.spells.powerInfusion:Callback(function(spell, target)
    if not project.settings.priest_offensives_power_infusion then
        return
    end

    if target.buff("Power Infusion") then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if awful.player.channeling then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.offensive("Power Infusion!", project.priest.spells.powerInfusion.id)
end)

