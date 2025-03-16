local Unlocker, awful, project = ...

project.priest.spells.premonitionOfInsight:Callback("atleast1CD", function(spell)
    if project.util.friend.total_cds == 0
            and project.util.enemy.total_cds == 0 then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfInsight:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return spell:Cast()
end)

project.priest.spells.premonitionOfInsight:Callback("pvp", function(spell)
    if project.priest.spells.penance.cd > awful.gcd * 2 then
        return
    end

    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    if (not project.util.friend.existing_classes[project.util.id.class.PRIEST] or awful.player.manaPct > 90)
            and project.priest.spells.powerInfusion.cd <= awful.gcd * 2 then
        return
    end

    if project.priest.spells.shadowfiend.cd <= awful.gcd * 2 then
        return
    end

    if IsPlayerSpell(project.util.id.spell.DARK_ARCHANGEL) then
        if project.priest.spells.darkArchangel.cd <= awful.gcd * 2 then
            return
        end
    end

    return project.priest.spells.premonitionOfInsight("atleast1CD")
            or project.priest.spells.premonitionOfInsight("danger")
end)

project.priest.spells.premonitionOfInsight:Callback("pve", function(spell)
    if project.priest.spells.penance.cd > awful.gcd * 2 then
        return
    end

    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    if (not project.util.friend.existing_classes[project.util.id.class.PRIEST] or awful.player.manaPct > 90)
            and project.priest.spells.powerInfusion.cd <= awful.gcd * 2 then
        return
    end

    if project.priest.spells.shadowfiend.cd <= awful.gcd * 2 then
        return
    end

    return project.priest.spells.premonitionOfInsight("atleast1CD")
            or project.priest.spells.premonitionOfInsight("danger")
end)
