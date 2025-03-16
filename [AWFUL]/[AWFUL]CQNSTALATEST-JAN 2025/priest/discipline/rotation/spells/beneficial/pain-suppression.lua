local Unlocker, awful, project = ...

project.priest.spells.painSuppression:Callback("below30HPA", function(spell)
    if project.util.friend.best_target.unit.hpa > 30 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! below30HPA", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below60HP_incomingCC", function(spell)
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        return
    end

    if project.util.friend.best_target.unit.hp > 60 then
        return
    end

    local incoming_cc, _ = project.util.check.target.incoming(awful.player)
    if not incoming_cc then
        return
    end

    if not awful.player.stunned then
        local phase_shift = awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) and project.priest.spells.fade.cd < awful.gcd
        local meld = IsPlayerSpell(project.util.id.spell.SHADOWMELD) and project.util.spells.racials.shadowmeld.cd < awful.gcd

        if phase_shift or meld then
            return
        end
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below60HP_incomingCC", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below95HP_incomingCC_atleast1CD", function(spell)
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 95 then
        return
    end

    local incoming_cc, _ = project.util.check.target.incoming(awful.player)
    if not incoming_cc then
        return
    end

    if not awful.player.stunned then
        local phase_shift = awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) and project.priest.spells.fade.cd < awful.gcd
        local meld = IsPlayerSpell(project.util.id.spell.SHADOWMELD) and project.util.spells.racials.shadowmeld.cd < awful.gcd

        if phase_shift or meld then
            return
        end
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below95HP_incomingCC_atleast1CD", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("danger", function(spell)
    if not project.util.friend.danger then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! danger", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_debuff", function(spell)
    if not project.util.enemy.existing_classes[project.util.id.class.ROGUE]
            and not project.util.enemy.existing_classes[project.util.id.class.ROGUE] then
        return
    end

    local cast = false
    if project.util.friend.best_target.unit.debuffRemains(project.util.id.spell.DEATHMARK) > 10
            and project.util.friend.best_target.unit.debuffUptime(project.util.id.spell.DEATHMARK) < 1 then
        cast = true
    end

    if project.util.friend.best_target.unit.debuffUptime(project.util.id.spell.TOUCH_OF_DEATH_DEBUFF) > 2 then
        cast = true
    end

    if not cast then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_debuff", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below60HP_scorpidvenom", function(spell)
    if not project.util.enemy.existing_classes[project.util.id.class.HUNTER] then
        return
    end

    if not awful.player.debuff(project.util.id.spell.SCORPID_VENOM) then
        return
    end

    if project.util.friend.best_target.unit.hp > 60 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below60HP_scorpidvenom", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below80HP_SELFstunned_atleast1CD", function(spell)
    if not awful.player.stunned then
        return
    end

    if awful.player.debuffUptime(awful.player.stunned) < 1.5 then
        return
    end

    if awful.player.stunRemains < 1 then
        return
    end

    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 80 then
        return
    end

    if project.util.friend.best_target.unit == awful.player then
        for _, cc in ipairs(awful.player.stunInfo) do

            local source = awful.GetObjectWithGUID(cc[5])
            if source
                    and not source.isHealer
                    and source.target
                    and source.target.guid ~= awful.player.guid then
                return
            end
        end
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below80HP_SELFstunned_atleast1CD", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below60HP_SELFstunned", function(spell)
    if not awful.player.stunned then
        return
    end

    if awful.player.debuffUptime(awful.player.stunned) < 1.5 then
        return
    end

    if awful.player.stunRemains < 1 then
        return
    end

    if project.util.friend.best_target.unit.hp > 60 then
        return
    end

    if project.util.friend.best_target.unit == awful.player then
        for _, cc in ipairs(awful.player.stunInfo) do

            local source = awful.GetObjectWithGUID(cc[5])
            if source
                    and not source.isHealer
                    and source.target
                    and source.target.guid ~= awful.player.guid then
                return
            end
        end
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below60HP_SELFstunned", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below95HP_charges2_atleast1CD", function(spell)
    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 95 then
        return
    end

    if spell.charges == 0 then
        return
    end

    if spell.charges == 1 then
        if spell.nextChargeCD > 25 then
            return
        end
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below95HP_charges2_atleast1CD", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pvp_below90HP_atleast2CD", function(spell)
    if project.util.friend.best_target.attackers.cdp < 2 then
        return
    end

    if project.util.friend.best_target.unit.hp > 90 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! pvp_below90HP_atleast2CD", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("below30HPA_noTANK_2charges", function(spell)
    if project.util.friend.best_target.unit.guid == project.util.friend.tank.guid then
        return
    end

    if spell.charges == 0 then
        return
    end

    if spell.charges < 1 then
        if spell.nextChargeCD > 5 then
            return
        end
    end

    if project.util.friend.best_target.unit.hpa > 30 then
        return
    end

    if not project.util.friend.best_target.unit.dotted then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! below30HPA_noTANK_2charges", project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("party_damage_below40HPA", function(spell)
    if awful.time < project.util.party_damage.early_time then
        return
    end

    if project.util.friend.best_target.unit.hpa > 40 then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! party_damage_below40HPA " .. project.util.party_damage.spell, project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("tank_buster", function(spell)
    if awful.time < project.util.tank_buster.time then
        return
    end

    local spell_name = project.util.tank_buster.enemy.casting or project.util.tank_buster.enemy.channel
    if not spell_name then
        return
    end

    local target = project.util.tank_buster.dest or project.util.friend.tank
    local defensives = project.util.check.target.defensives(target)
    if defensives.def_best > 0 then
        return
    end

    if defensives.def > 0 and target.hpa > 50 then
        return
    end

    if target.hpa > 80 then
        return
    end

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.beneficial("Pain Suppression! tank_buster " .. spell_name, project.priest.spells.painSuppression.id)

end)

project.priest.spells.painSuppression:Callback("pve_debuffs_below80HPA", function(spell)
    if not project.util.pve_debuffs.target then
        return
    end

    if project.util.pve_debuffs.prio ~= 2 then
        if project.util.pve_debuffs.target.hpa > 80 then
            return
        end
    end

    return project.util.cast.overlap.cast(spell, project.util.pve_debuffs.target)
            and project.util.debug.alert.beneficial("Pain Suppression! pve_debuffs_below80HPA " .. project.util.pve_debuffs.debuff, project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("dbm_bars_tank", function(spell)
    local defensives = project.util.check.target.defensives(project.util.friend.tank)
    if defensives.def_best > 0 then
        return
    end

    if defensives.def > 0 and project.util.friend.tank.hpa > 40 then
        return
    end

    if project.util.friend.tank.hpa > 70 then
        return
    end

    local dbm_spell_name = project.util.dbm_bars.check(1, 1)
    if not dbm_spell_name then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.tank)
            and project.util.debug.alert.beneficial("Pain Suppression! dbm_bars_tank " .. dbm_spell_name, project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("dbm_bars_party_below40HPA", function(spell)
    if project.util.friend.best_target.unit.hpa > 40 then
        return
    end

    local dbm_spell_name = project.util.dbm_bars.check(0, 1)
    if not dbm_spell_name then
        return
    end

    return project.util.cast.overlap.cast(spell, project.util.friend.best_target.unit)
            and project.util.debug.alert.beneficial("Pain Suppression! dbm_bars_party_below40HPA " .. dbm_spell_name, project.priest.spells.painSuppression.id)
end)

project.priest.spells.painSuppression:Callback("pve", function()
    if not project.settings.priest_cds_pain_suppression then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3 then
        return
    end

    if awful.player.channelID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if project.util.friend.best_target.defensives.def > 0 then
        return project.priest.spells.painSuppression("tank_buster")
                or project.priest.spells.painSuppression("dbm_bars_tank")
    end

    return project.priest.spells.painSuppression("tank_buster")
            or project.priest.spells.painSuppression("dbm_bars_tank")
            or project.priest.spells.painSuppression("dbm_bars_party_below40HPA")
            or project.priest.spells.painSuppression("pve_debuffs_below80HPA")
            or project.priest.spells.painSuppression("party_damage_below40HPA")
            or project.priest.spells.painSuppression("below30HPA_noTANK_2charges")
end)

project.priest.spells.painSuppression:Callback("pvp", function()
    if not project.settings.priest_cds_pain_suppression then
        return
    end

    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    if awful.player.used(project.priest.spells.painSuppression.id, 4) then
        return
    end

    if awful.player.used(project.priest.spells.powerWordBarrier.id, 4) then
        return
    end

    if awful.player.used(project.priest.spells.painSuppression.id, 10)
            and project.util.friend.best_target.unit.hp > 30 then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE) then
        return
    end

    if awful.player.channelID then
        return
    end

    if project.priest.spells.penance.queued then
        return
    end

    if (project.util.friend.best_target.defensives.def > 0 and project.util.friend.best_target.unit.hpa < 70)
            or awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3
            or awful.player.buff(project.util.id.spell.RAPTURE)
            or project.priest.spells.rapture.cd < awful.gcd * 2 then
        return project.priest.spells.painSuppression("pvp_below80HP_SELFstunned_atleast1CD")
                or project.priest.spells.painSuppression("pvp_below60HP_SELFstunned")
                or project.priest.spells.painSuppression("pvp_below60HP_incomingCC")
                or project.priest.spells.painSuppression("pvp_below95HP_incomingCC_atleast1CD")
                or project.priest.spells.painSuppression("pvp_debuff")
                or project.priest.spells.painSuppression("below30HPA")
    end

    return project.priest.spells.painSuppression("danger")
            or project.priest.spells.painSuppression("pvp_below80HP_SELFstunned_atleast1CD")
            or project.priest.spells.painSuppression("pvp_below95HP_charges2_atleast1CD")
            or project.priest.spells.painSuppression("pvp_below90HP_atleast2CD")
            or project.priest.spells.painSuppression("pvp_below60HP_SELFstunned")
            or project.priest.spells.painSuppression("pvp_below60HP_incomingCC")
            or project.priest.spells.painSuppression("pvp_below95HP_incomingCC_atleast1CD")
            or project.priest.spells.painSuppression("pvp_below60HP_scorpidvenom")
            or project.priest.spells.painSuppression("pvp_debuff")
end)
