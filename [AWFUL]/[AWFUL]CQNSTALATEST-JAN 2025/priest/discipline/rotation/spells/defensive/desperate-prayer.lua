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

    if project.util.friend.best_target.attackers.total < 3 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.defensive("Desperate Prayer! pvp_below50HPA_atleast3ATT", project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("pvp_below50HPA_atleast1CD", function(spell)
    if awful.player.hpa > 50 then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.defensive("Desperate Prayer! pvp_below50HPA_atleast1CD", project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("pve_debuffs", function(spell)
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
    if awful.time < project.util.party_damage.early_time then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Desperate Prayer! party_damage " .. project.util.party_damage.spell, project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("dbm_bars", function(spell)
    local dbm_spell_name = project.util.dbm_bars.check(0, 1)
    if not dbm_spell_name then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Desperate Prayer! dbm_bars " .. dbm_spell_name, project.priest.spells.desperatePrayer.id)
end)

project.priest.spells.desperatePrayer:Callback("pvp", function(spell)
    if not project.settings.priest_defensives_desperate_prayer then
        return
    end

    if awful.player.channelID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if project.util.friend.best_target.unit.guid ~= awful.player.guid then
        return
    end

    if project.util.friend.best_target.attackers.total == 0 then
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

    if awful.player.channelID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if awful.player.buff(project.util.id.spell.FADE) then
        return project.priest.spells.desperatePrayer("below20HPA")
    end

    return project.priest.spells.desperatePrayer("below20HPA")
            or project.priest.spells.desperatePrayer("party_damage")
            or project.priest.spells.desperatePrayer("pve_debuffs")
            or project.priest.spells.desperatePrayer("dbm_bars")
end)
