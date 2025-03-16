local Unlocker, awful, project = ...

project.priest.discipline.rotation.premonition = function(type)
    if not project.settings.priest_cds_premonition then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition() then
        return
    end

    local target = project.util.friend.best_target.unit

    if project.util.friend.best_target.unit.hp > 30
            and (awful.player.buffFrom({ project.util.id.spell.PREMONITION_OF_INSIGHT,
                                         project.util.id.spell.PREMONITION_OF_SOLACE,
                                         project.util.id.spell.PREMONITION_OF_PIETY })) then
        return
    end

    if not target then
        return
    end

    if not target.inCombat then
        return
    end

    if awful.player.used(project.priest.spells.premonitionOfInsight.id, 5)
            or awful.player.used(project.priest.spells.premonitionOfPiety.id, 5)
            or awful.player.used(project.priest.spells.premonitionOfSolace.id, 5)
            or awful.player.used(project.priest.spells.premonitionOfClairvoyance.id, 5) then
        return
    end

    if awful.player.channelID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    project.priest.spells.premonitionOfInsight(type)
    project.priest.spells.premonitionOfPiety(type)
    project.priest.spells.premonitionOfSolace(type)
    project.priest.spells.premonitionOfClairvoyance(type)
end
