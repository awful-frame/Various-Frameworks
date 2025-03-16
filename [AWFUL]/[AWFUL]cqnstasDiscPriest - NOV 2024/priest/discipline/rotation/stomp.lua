local Unlocker, awful, project = ...

project.priest.discipline.rotation.stomp = function(type)
    if not project.settings.general_auto_stomp then
        return
    end

    if type == "pve" then
        return
    end

    local totem = project.util.check.enemy.stomp()

    if not totem or not totem.health then
        return
    end

    if totem.health > 50 * 100 then
        if project.util.friend.bestTarget.hp < 20 then
            return
        end

        if project.util.friend.bestTarget.hp < 50 then
            return project.priest.spells.mindBlast("totem_stomp", totem)
                    or project.priest.spells.smite("totem_stomp", totem)
                    or project.priest.spells.purgeTheWicked("totem_stomp", totem)
        end

        return project.priest.spells.penance("totem_stomp", totem)
                or project.priest.spells.mindBlast("totem_stomp", totem)
                or project.priest.spells.smite("totem_stomp", totem)
                or project.priest.spells.purgeTheWicked("totem_stomp", totem)
    end

    return project.priest.spells.purgeTheWicked("totem_stomp", totem)
            or project.priest.spells.smite("totem_stomp", totem)
end
