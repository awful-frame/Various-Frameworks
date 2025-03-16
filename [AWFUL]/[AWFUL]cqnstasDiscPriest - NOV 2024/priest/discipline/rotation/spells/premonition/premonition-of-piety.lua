local Unlocker, awful, project = ...

project.priest.spells.premonitionOfPiety:Callback("noDRB_charges2_below50HP", function(spell)
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

    return spell:Cast()
            and project.util.debug.alert.beneficial("Premonition of Piety! noDRB_charges2_below50HP", project.priest.spells.premonitionOfPiety.id)
end)

project.priest.spells.premonitionOfPiety:Callback("pvp_noDRB_below80HP_atleast1CD", function(spell)
    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Premonition of Piety! pvp_noDRB_below80HP_atleast1CD", project.priest.spells.premonitionOfPiety.id)
end)

project.priest.spells.premonitionOfPiety:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Premonition of Piety! danger", project.priest.spells.premonitionOfPiety.id)
end)

project.priest.spells.premonitionOfPiety:Callback("pvp", function(spell)
    if awful.player.buff("Rapture") then
        return
    end

    if project.priest.spells.rapture.cd <= awful.gcd * 2 then
        return
    end

    return project.priest.spells.premonitionOfPiety("danger")
            or project.priest.spells.premonitionOfPiety("pvp_noDRB_below80HP_atleast1CD")
end)

project.priest.spells.premonitionOfPiety:Callback("pve", function(spell)
    return project.priest.spells.premonitionOfPiety("danger")
            or project.priest.spells.premonitionOfPiety("noDRB_charges2_below50HP")
end)