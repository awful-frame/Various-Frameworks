local Unlocker, awful, project = ...

project.priest.spells.desperatePrayer:Callback("below20HPA", function(spell)
    if awful.player.hpa > 20 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.defensive("Desperate Prayer! below20HPA", project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("pvp_below50HPA_atleast3ATT", function(spell)
    if awful.player.hpa > 50 then
        return
    end

    if project.util.friend.attackers.total < 3 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.defensive("Desperate Prayer! pvp_below50HPA_atleast3ATT", project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("pvp_below50HPA_atleast1CD", function(spell)
    if awful.player.hpa > 50 then
        return
    end

    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.defensive("Desperate Prayer! pvp_below50HPA_atleast1CD", project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("pve_debuffs", function(spell)
    if awful.player.buff("Fade") then
        return
    end

    if not project.util.pve_debuffs.target then
        return
    end

    if project.util.pve_debuffs.target.guid ~= awful.player.guid then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Desperate Prayer! pve_debuffs", project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("party_damage", function(spell)
    if awful.player.buff("Fade") then
        return
    end

    if awful.time < project.util.party_damage.early_time then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Desperate Prayer! party_damage", project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("pvp", function(spell)
    if not project.settings.priest_defensives_desperate_prayer then
        return
    end

    if project.util.friend.bestTarget.guid ~= awful.player.guid then
        return
    end

    if project.util.friend.attackers.total == 0 then
        return
    end

    return project.priest.spells.desperatePrayer("below20HPA")
            or project.priest.spells.desperatePrayer("pvp_below50HPA_atleast1CD")
            or project.priest.spells.desperatePrayer("pvp_below50HPA_atleast3ATT")
end)

project.priest.spells.desperatePrayer:Callback("pve", function(spell)
    if not project.settings.priest_defensives_desperate_prayer then
        return
    end

    if project.util.friend.bestTarget.guid ~= awful.player.guid then
        return
    end

    return project.priest.spells.desperatePrayer("below20HPA")
            or project.priest.spells.desperatePrayer("party_damage")
            or project.priest.spells.desperatePrayer("pve_debuffs")
end)
