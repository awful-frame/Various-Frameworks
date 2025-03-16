local Unlocker, awful, project = ...

project.priest.spells.premonitionOfSolace:Callback("noDRB_charges2_below50HP", function(spell)
    if spell.charges < 2 then
        if spell.nextChargeCD > 20 then
            return
        end
    end

    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 50 then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Premonition of Solace! noDRB_charges2_below50HP", project.priest.spells.premonitionOfSolace.id)
end)

project.priest.spells.premonitionOfSolace:Callback("pvp_noDRB_charges2_below80HP_atleast1CD", function(spell)
    if spell.charges < 2 then
        if spell.nextChargeCD > 20 then
            return
        end
    end

    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Premonition of Solace! pvp_noDRB_charges2_below80HP_atleast1CD", project.priest.spells.premonitionOfSolace.id)
end)

project.priest.spells.premonitionOfSolace:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Premonition of Solace! danger", project.priest.spells.premonitionOfSolace.id)
end)

project.priest.spells.premonitionOfSolace:Callback("pvp", function(spell)
    if project.util.friend.attackers.total == 0 then
        return
    end

    if awful.player.buff("Rapture") then
        return
    end

    return project.priest.spells.premonitionOfSolace("danger")
            or project.priest.spells.premonitionOfSolace("pvp_noDRB_charges2_below80HP_atleast1CD")
            or project.priest.spells.premonitionOfSolace("noDRB_charges2_below50HP")
end)

project.priest.spells.premonitionOfSolace:Callback("pve", function(spell)
    return project.priest.spells.premonitionOfSolace("danger")
            or project.priest.spells.premonitionOfSolace("noDRB_charges2_below50HP")
end)