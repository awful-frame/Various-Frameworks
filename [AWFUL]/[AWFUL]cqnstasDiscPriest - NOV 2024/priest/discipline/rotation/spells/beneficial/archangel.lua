local Unlocker, awful, project = ...

project.priest.spells.archangel:Callback("pvp_atleast1CD", function(spell)
    if project.util.enemy.withOffensiveCds == 0 then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Archangel! pvp_atleast1CD", project.priest.spells.archangel.id)
end)

project.priest.spells.archangel:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell)
            and project.util.debug.alert.beneficial("Archangel! danger", project.priest.spells.archangel.id)
end)

project.priest.spells.archangel:Callback("pve", function()
    return
end)

project.priest.spells.archangel:Callback("pvp", function()
    if not project.settings.priest_cds_archangel then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    return project.priest.spells.archangel("pvp_atleast1CD")
            or project.priest.spells.archangel("danger")
end)