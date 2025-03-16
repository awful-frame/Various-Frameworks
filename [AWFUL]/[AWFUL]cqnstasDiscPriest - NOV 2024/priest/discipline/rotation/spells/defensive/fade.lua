local Unlocker, awful, project = ...

project.priest.spells.fade:Callback("aggro", function(spell)
    if project.util.friend.tank == awful.player then
        return
    end

    if project.util.enemy.aggro < 3 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Fade! aggro", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("below15HP", function(spell)
    if awful.player.hp > 15 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Fade! below15HP", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("pve_debuffs", function(spell)
    if awful.player.buff("Desperate Prayer") then
        return
    end

    if not project.util.pve_debuffs.target then
        return
    end

    if project.util.pve_debuffs.target.guid ~= awful.player.guid then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Fade! pve_debuffs", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("party_damage", function(spell)
    if awful.player.buff("Desperate Prayer") then
        return
    end

    if awful.time < project.util.party_damage.early_time then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Fade! party_damage", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("pvp_melee_atleast1CD_below70HP", function(spell)
    if project.util.friend.attackers.melee == 0 then
        return
    end

    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    if awful.player.hp > 70 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Fade! pvp_melee_atleast1CD_below70HP", project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("pve", function(spell)
    if not project.settings.priest_defensives_fade then
        return
    end

    if awful.player.channel
            or awful.player.casting then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if awful.player.buff("Premonition of Insight") then
        return
    end

    if awful.player.lastCast == project.priest.spells.ultimatePenitence.id then
        return
    end

    return project.priest.spells.fade("party_damage")
            or project.priest.spells.fade("pve_debuffs")
            or project.priest.spells.fade("aggro")
end)

project.priest.spells.fade:Callback("pvp", function(spell)
    if not project.settings.priest_defensives_fade then
        return
    end

    if project.util.friend.bestTarget.guid ~= awful.player.guid then
        return
    end

    if project.util.friend.attackers.total == 0 then
        return
    end

    if not awful.player.hasTalent("Phase Shift") then
        return
    end

    if awful.player.buff("Premonition of Insight") then
        return
    end

    if awful.player.channel
            or awful.player.casting then
        return
    end

    if awful.player.lastCast == project.priest.spells.ultimatePenitence.id then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    return project.priest.spells.fade("below15HP")
            or project.priest.spells.fade("pvp_melee_atleast1CD_below70HP")
end)
