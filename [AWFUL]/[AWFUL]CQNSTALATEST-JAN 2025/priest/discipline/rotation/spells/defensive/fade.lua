local Unlocker, awful, project = ...

project.priest.spells.fade:Callback("aggro", function(spell)
    if project.util.friend.tank == awful.player then
        return
    end

    if project.util.enemy.aggro == 0 then
        return
    end

    if project.util.enemy.best_target.unit.dist > 5 then
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
    if awful.time < project.util.party_damage.early_time then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Fade! party_damage " .. project.util.party_damage.spell, project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("dbm_bars", function(spell)
    local dbm_spell_name = project.util.dbm_bars.check(0, 1)
    if not dbm_spell_name then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.evade("Fade! dbm_bars " .. dbm_spell_name, project.priest.spells.fade.id)
end)

project.priest.spells.fade:Callback("pvp_melee_atleast1CD_below70HP", function(spell)
    if project.util.friend.best_target.attackers.melee == 0 then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
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

    if awful.player.channelID
            or awful.player.castID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT) then
        return
    end

    return project.priest.spells.fade("party_damage")
            or project.priest.spells.fade("pve_debuffs")
            or project.priest.spells.fade("dbm_bars")
            or project.priest.spells.fade("aggro")
end)

project.priest.spells.fade:Callback("pvp", function(spell)
    if not project.settings.priest_defensives_fade then
        return
    end

    if project.util.friend.best_target.unit.guid ~= awful.player.guid then
        return
    end

    if project.util.friend.best_target.attackers.total == 0 then
        return
    end

    if not awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT) then
        return
    end

    if awful.player.channelID
            or awful.player.castID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    return project.priest.spells.fade("below15HP")
            or project.priest.spells.fade("pvp_melee_atleast1CD_below70HP")
end)
