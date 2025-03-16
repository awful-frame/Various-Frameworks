local Unlocker, awful, project = ...

project.priest.spells.powerInfusion:Callback(function(spell, target)
    if not project.settings.priest_offensives_power_infusion then
        return
    end

    if target.buff(project.util.id.spell.POWER_INFUSION) then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if awful.player.channelID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.offensive("Power Infusion!", project.priest.spells.powerInfusion.id)
end)

