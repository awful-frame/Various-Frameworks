local Unlocker, awful, project = ...

project.priest.spells.premonitionOfClairvoyance:Callback("pvp_noDEF_below90HP_atleast1CD", function(spell)
    if project.util.friend.best_target.unit.hp > 90 then
        return
    end

    if project.util.enemy.total_cds == 0 then
        return
    end

    if project.util.friend.best_target.defensives.def > 0 then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfClairvoyance:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfClairvoyance:Callback("pvp", function(spell)
    return project.priest.spells.premonitionOfClairvoyance("danger")
            or project.priest.spells.premonitionOfClairvoyance("pvp_noDEF_below90HP_atleast1CD")
end)

project.priest.spells.premonitionOfClairvoyance:Callback("pve", function(spell)
    return project.priest.spells.premonitionOfClairvoyance("danger")
end)