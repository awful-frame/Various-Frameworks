local Unlocker, awful, project = ...

project.priest.spells.death:Callback("execute", function(spell, target)
    if awful.player.channel or awful.player.casting then
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

    if not awful.player.hasTalent("Devour Matter") then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if target.hpa == target.hp then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Shadow Word: Death! devour_shield", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("pvp", function(spell, target)
    if awful.player.channel or awful.player.casting then
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

project.priest.spells.death:Callback("pve_SELFabove10HP", function(spell, target)
    if awful.player.hpa < 10 then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    return spell:Cast(target)
            and project.util.debug.alert.attack("Shadow Word: Death! pve_SELFabove10HP", project.priest.spells.death.id)
end)

project.priest.spells.death:Callback("pve", function(spell, target)
    if awful.player.channel or awful.player.casting then
        return
    end

    if awful.player.buff("Voidheart") then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if awful.player.lastCast == project.priest.spells.ultimatePenitence.id then
        return
    end

    return project.priest.spells.death("pve_SELFabove10HP", target)
            or project.priest.spells.death("devour_shield", target)
            or project.priest.spells.death("execute", target)
end)
