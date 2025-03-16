local Unlocker, awful, project = ...

project.priest.discipline.rotation.stomp = function(type, stomp_high)
    if not project.settings.misc_stomp_totems then
        return
    end

    if type == "pve" then
        return
    end

    local totem = project.util.check.enemy.stomp()
    if not totem
            or not totem.health then
        return
    end

    if totem.health > 30 * 100 then
        if not stomp_high then
            return
        end

        if project.util.friend.best_target.unit.hp < 30 then
            return
        end

        if project.util.friend.best_target.unit.hp < 50 then
            return project.priest.spells.mindBlast("totem_stomp", totem)
                    or project.priest.spells.smite("totem_stomp", totem)
        end

        return project.priest.spells.penance("totem_stomp", totem)
                or project.priest.spells.mindBlast("totem_stomp", totem)
                or project.priest.spells.smite("totem_stomp", totem)
    end

    return project.priest.spells.purgeTheWicked("totem_stomp", totem)
            or project.priest.spells.smite("totem_stomp", totem)
end
