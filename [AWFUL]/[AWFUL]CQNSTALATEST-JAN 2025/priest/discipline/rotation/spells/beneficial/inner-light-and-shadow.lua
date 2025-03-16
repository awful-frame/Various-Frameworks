local Unlocker, awful, project = ...


project.priest.spells.inner_light_and_shadow:Callback(function(spell)
    if project.util.enemy.total_cds > 0 then
        return
    end

    if project.util.friend.best_target.unit.hp < 50 then
        return
    end

    if not awful.player.buff(project.util.id.spell.INNER_LIGHT) and not awful.player.buff(project.util.id.spell.INNER_SHADOW) then
        return spell:Cast()
                and project.util.debug.alert.beneficial("Inner Light and Shadow!", project.priest.spells.inner_light_and_shadow.id)
    end

    if awful.player.manaPct < project.settings.priest_cds_inner_light_and_shadow_mana_threshold
            and not awful.player.buff(project.util.id.spell.INNER_LIGHT)
            and awful.arena then
        return spell:Cast()
                and project.util.debug.alert.beneficial("Inner Light!", project.priest.spells.inner_light_and_shadow.id)
    end

    if awful.player.manaPct >= project.settings.priest_cds_inner_light_and_shadow_mana_threshold
            and not awful.player.buff(project.util.id.spell.INNER_SHADOW) then
        return spell:Cast()
                and project.util.debug.alert.beneficial("Inner Shadow!", project.priest.spells.inner_light_and_shadow.id)
    end
end)
