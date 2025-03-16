local Unlocker, awful, project = ...

project.priest.discipline.rotation.premonition = function(type)
    if not project.settings.priest_cds_premonition then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition() then
        return
    end

    if project.util.friend.bestTarget.hp > 30
            and (awful.player.buff("Premonition of Insight") or awful.player.buff("Premonition of Solace") or awful.player.buff("Premonition of Piety")) then
        return
    end

    local target = project.util.friend.bestTarget

    if not target then
        return
    end

    if target.buff("Temporal Shield")
            or target.buff("Alter Time") then
        return
    end

    if target.immuneMagicDamage
            or target.immunePhysicalDamage then
        return
    end

    if not target.inCombat then
        return
    end

    if awful.player.buff("Ultimate Penitence") then
        return
    end

    if awful.player.used(project.priest.spells.premonitionOfInsight.id, 5)
            or awful.player.used(project.priest.spells.premonitionOfPiety.id, 5)
            or awful.player.used(project.priest.spells.premonitionOfSolace.id, 5)
            or awful.player.used(project.priest.spells.premonitionOfClairvoyance.id, 5) then
        return
    end

    project.priest.spells.premonitionOfInsight(type)
    project.priest.spells.premonitionOfPiety(type)
    project.priest.spells.premonitionOfSolace(type)
    project.priest.spells.premonitionOfClairvoyance(type)
end
