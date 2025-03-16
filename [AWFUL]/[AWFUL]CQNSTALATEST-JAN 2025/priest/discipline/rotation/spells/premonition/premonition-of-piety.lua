local Unlocker, awful, project = ...

project.priest.spells.premonitionOfPiety:Callback("noDRB_below60HP", function(spell)
    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 60 then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfPiety:Callback("pvp_noDRB_below90HP_atleast1CD", function(spell)
    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 90 then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfPiety:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfPiety:Callback("pvp", function(spell)
    if awful.player.buff(project.util.id.spell.RAPTURE) then
        return
    end

    if project.priest.spells.rapture.cd <= awful.gcd * 2 then
        return
    end

    return project.priest.spells.premonitionOfPiety("danger")
            or project.priest.spells.premonitionOfPiety("pvp_noDRB_below90HP_atleast1CD")
            or project.priest.spells.premonitionOfPiety("noDRB_below60HP")
end)

project.priest.spells.premonitionOfPiety:Callback("pve", function(spell)
    return project.priest.spells.premonitionOfPiety("danger")
            or project.priest.spells.premonitionOfPiety("noDRB_below60HP")
end)