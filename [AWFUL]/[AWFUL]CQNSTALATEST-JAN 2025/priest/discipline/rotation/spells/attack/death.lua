local Unlocker, awful, project = ...

project.priest.spells.death:Callback("execute", function(spell, target)
    if awful.player.channelID
            or awful.player.castID then
        return
    end

    if awful.player.hpa < 5 then
        return
    end

    if not target then
        return
    end

    if target.hp > 20 then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if awful.player.lastCast == project.priest.spells.ultimatePenitence.id then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Shadow Word: Death! execute", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("devour_shield", function(spell, target)
    if project.priest.discipline.rotation.util.is_premonition() then
        return
    end

    if not awful.player.hasTalent(project.util.id.spell.DEVOUR_MATTER_TALENT) then
        return
    end

    if target.hpa - target.hp < 10 then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Shadow Word: Death! devour_shield", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("pvp", function(spell, target)
    if awful.player.channelID
            or awful.player.castID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if awful.player.lastCast == project.priest.spells.ultimatePenitence.id then
        return
    end

    return project.priest.spells.death("execute", target)
            or project.priest.spells.death("devour_shield", target)
end)

project.priest.spells.death:Callback("pve_SELFabove20HP", function(spell, target)
    if not project.priest.discipline.rotation.util.is_premonition()
            and not project.util.check.player.moving_for(0.2) then
        if awful.player.buff(project.util.id.spell.VOIDHEART) then
            return
        end

        if project.util.friend.best_target.unit.hp < 70
                and project.priest.spells.mindBlast.cd < awful.gcd then
            return
        end
    end

    if awful.player.hpa < 20 then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Shadow Word: Death! pve_SELFabove20HP", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("pve", function(spell, target)
    if awful.player.channelID
            or awful.player.castID then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if awful.player.lastCast == project.priest.spells.ultimatePenitence.id then
        return
    end

    return project.priest.spells.death("pve_SELFabove20HP", target)
            or project.priest.spells.death("devour_shield", target)
            or project.priest.spells.death("execute", target)
end)
