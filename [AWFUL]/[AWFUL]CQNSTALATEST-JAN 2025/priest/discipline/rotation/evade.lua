local Unlocker, awful, project = ...

project.priest.discipline.rotation.evade = function(type)
    if not project.settings.priest_evade_enabled then
        return
    end

    project.priest.spells.voidShift(type)

    if awful.player.lastCast == project.priest.spells.ultimatePenitence.id then
        return
    end

    return project.priest.spells.death("evade")
            or project.priest.spells.fade("evade")
            or (IsPlayerSpell(project.util.id.spell.SHADOWMELD) and project.util.spells.racials.shadowmeld("evade"))
end

