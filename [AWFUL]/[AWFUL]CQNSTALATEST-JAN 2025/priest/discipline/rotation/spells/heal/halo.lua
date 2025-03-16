local Unlocker, awful, project = ...

project.priest.spells.halo:Callback("3under90Hp30Yards", function(spell)
    if project.util.friend.under90Hp30Yards < 3 then
        return
    end

    if awful.player.hasTalent(project.util.id.spell.SHADOW_COVENANT_TALENT)
            and awful.player.buffRemains(project.util.id.spell.SHADOW_COVENANT) < spell.castTime + awful.buffer then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.heal("Halo! 3under90Hp30Yards", spell.id)
end)

project.priest.spells.halo:Callback("pve", function(spell)
    return spell("3under90Hp30Yards")
end)

project.priest.spells.halo:Callback("pvp", function(spell)
    return spell("3under90Hp30Yards")
end)
