local Unlocker, awful, project = ...

project.util.evade.should_evade = function(allow_pve)
    if not allow_pve then
        if project.util.check.scenario.type() ~= "pvp" then
            return
        end
    end

    if IsPlayerSpell(project.util.id.spell.ULTIMATE_PENITENCE)
            and awful.player.buffRemains(project.util.id.spell.ULTIMATE_PENITENCE) > 2 then
        return
    end

    if awful.player.channelID == project.util.id.spell.MIND_CONTROL then
        return
    end

    local no_phase_shift = not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) or project.priest.spells.fade.cd > 3
    local no_meld = not IsPlayerSpell(project.util.id.spell.SHADOWMELD) or project.util.spells.racials.shadowmeld.cd > 3

    if project.util.check.scenario.type() == "pve"
            and no_meld then
        return
    end

    if project.util.check.scenario.type() == "pvp"
            and project.priest.spells.death.cd > 3
            and no_phase_shift
            and no_meld then
        return
    end

    return true
end