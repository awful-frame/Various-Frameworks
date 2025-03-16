local Unlocker, awful, project = ...

project.priest.spells.premonitionOfClairvoyance:Callback("noDRB_charges2_below80HP_atleast1CD", function(spell)
    if spell.charges < 2 then
        if spell.nextChargeCD > 20 then
            return
        end
    end

    if project.util.friend.attackers.def_best > 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    if project.util.enemy.withOffensiveCds == 0 then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Premonition of Clairvoyance! noDRB_charges2_below80HP_atleast1CD", project.priest.spells.premonitionOfClairvoyance.id)
end)

project.priest.spells.premonitionOfClairvoyance:Callback("charges2_below90HP_atleast2CD", function(spell)
    if spell.charges < 2 then
        if spell.nextChargeCD > 20 then
            return
        end
    end

    if project.util.friend.bestTarget.hp > 90 then
        return
    end

    if project.util.enemy.withOffensiveCds < 2 then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Premonition of Clairvoyance! charges2_below90HP_atleast2CD", project.priest.spells.premonitionOfClairvoyance.id)
end)

project.priest.spells.premonitionOfClairvoyance:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Premonition of Clairvoyance! danger", project.priest.spells.premonitionOfClairvoyance.id)
end)

project.priest.spells.premonitionOfClairvoyance:Callback("pvp", function(spell)
    return project.priest.spells.premonitionOfClairvoyance("danger")
            or project.priest.spells.premonitionOfClairvoyance("noDRB_charges2_below80HP_atleast1CD")
            or project.priest.spells.premonitionOfClairvoyance("charges2_below90HP_atleast2CD")
end)

project.priest.spells.premonitionOfClairvoyance:Callback("pve", function(spell)
    return project.priest.spells.premonitionOfClairvoyance("danger")
end)