local Unlocker, awful, project = ...

project.priest.spells.archangel:Callback("pvp_atleast1CD", function(spell)
    if project.util.enemy.total_cds == 0 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Archangel! pvp_atleast1CD", project.priest.spells.archangel.id)
end)

project.priest.spells.archangel:Callback("below60HP", function(spell)
    if project.util.friend.best_target.unit.hp > 60 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Archangel! below60HP", project.priest.spells.archangel.id)
end)

project.priest.spells.archangel:Callback("pve", function()
    return
end)

project.priest.spells.archangel:Callback("pvp", function()
    if not project.settings.priest_cds_archangel then
        return
    end

    if project.util.friend.best_target.unit.hp < 30 then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if not project.util.friend.best_target.unit.buff(project.util.id.spell.ATONEMENT) then
        return
    end

    if project.util.friend.total > 1
            and project.util.friend.withAtonement < 2 then
        return
    end

    return project.priest.spells.archangel("pvp_atleast1CD")
            or project.priest.spells.archangel("below60HP")
end)