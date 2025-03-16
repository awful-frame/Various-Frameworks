local Unlocker, awful, project = ...

project.priest.spells.premonitionOfSolace:Callback("noDRB_charges2_below50HP", function(spell)
    if spell.charges == 0 then
        return
    end

    if spell.charges == 1 then
        if spell.nextChargeCD > 20 then
            return
        end
    end

    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 50 then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfSolace:Callback("pvp_noDEF_below90HP_atleast1CD", function(spell)
    if project.util.friend.best_target.defensives.def > 0 then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 90 then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfSolace:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfSolace:Callback("pvp", function(spell)
    if project.util.friend.best_target.attackers.total == 0 then
        return
    end

    if awful.player.buff(project.util.id.spell.RAPTURE) then
        return
    end

    return project.priest.spells.premonitionOfSolace("danger")
            or project.priest.spells.premonitionOfSolace("pvp_noDEF_below90HP_atleast1CD")
            or project.priest.spells.premonitionOfSolace("noDRB_charges2_below50HP")
end)

project.priest.spells.premonitionOfSolace:Callback("pve", function(spell)
    return project.priest.spells.premonitionOfSolace("danger")
            or project.priest.spells.premonitionOfSolace("noDRB_charges2_below50HP")
end)