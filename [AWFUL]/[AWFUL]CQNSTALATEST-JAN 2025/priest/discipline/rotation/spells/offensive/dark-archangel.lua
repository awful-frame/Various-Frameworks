local Unlocker, awful, project = ...

project.priest.spells.darkArchangel:Callback("default", function(spell, target)
    return spell:Cast()
            and project.util.debug.alert.offensive("Dark Archangel! default", project.priest.spells.darkArchangel.id)
end)

project.priest.spells.darkArchangel:Callback(function(spell, target)
    if not project.settings.priest_offensives_dark_archangel then
        return
    end

    if not project.util.friend.existing_classes[project.util.id.class.PRIEST]
            and project.priest.spells.powerInfusion.cd <= awful.gcd * 2 then
        return
    end

    if project.util.friend.danger then
        return
    end

    if target.buff(project.util.id.spell.DARK_ARCHANGEL) then
        return
    end

    if not project.priest.discipline.rotation.util.full_aton() then
        if project.priest.spells.radiance.charges == 2
                and not project.priest.spells.radiance.queued
                and target.los
                and target.dist < 30 - 1
                and awful.player.hasTalent(project.util.id.spell.ULTIMATE_RADIANCE_TALENT) then
            if project.priest.spells.radiance:Cast() then
                project.util.debug.alert.offensive("Radiance -> Dark Archangel!", project.priest.spells.darkArchangel.id)
            end
        end
    end

    return project.priest.spells.darkArchangel("default", target)
end)