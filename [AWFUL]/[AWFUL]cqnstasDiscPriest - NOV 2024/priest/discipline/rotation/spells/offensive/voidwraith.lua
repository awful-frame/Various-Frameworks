local Unlocker, awful, project = ...

project.priest.spells.voidwraith:Callback("voidheart", function(spell)
    if not awful.player.buff("Voidheart") then
        return
    end

    return spell:Cast(project.util.enemy.bestTarget)
            and project.util.debug.alert.offensive("Voidwraith! voidheart", project.priest.spells.voidwraith.id)
end)

project.priest.spells.voidwraith:Callback("atleast1CD", function(spell)
    if project.util.friend.withOffensiveCds == 0 then
        return
    end

    if awful.player.buff("Power of the Dark Side") then
        return
    end

    return spell:Cast(project.util.enemy.bestTarget)
            and project.util.debug.alert.offensive("Voidwraith! atleast1CD", project.priest.spells.voidwraith.id)
end)

project.priest.spells.voidwraith:Callback("fullaton", function(spell)
    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    return spell:Cast(project.util.enemy.bestTarget)
            and project.util.debug.alert.offensive("Voidwraith! fullaton", project.priest.spells.voidwraith.id)
end)

project.priest.spells.voidwraith:Callback("radiance", function(spell)
    if not awful.player.used(project.priest.spells.radiance.id, 5) then
        return
    end

    return spell:Cast(project.util.enemy.bestTarget)
            and project.util.debug.alert.offensive("Voidwraith! radiance", project.priest.spells.voidwraith.id)
end)

project.priest.spells.voidwraith:Callback("party_damage", function(spell)
    if awful.time < project.util.party_damage.early_time then
        return
    end

    return spell:Cast(project.util.enemy.bestTarget)
            and project.util.debug.alert.offensive("Voidwraith! party_damage " .. project.util.party_damage.spell, project.priest.spells.voidwraith.id)
end)

project.priest.spells.voidwraith:Callback("dbm_bars", function(spell)
    for spell_name, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.prio ~= 0 then
            return
        end

        if bar_data.timer < awful.time then
            return spell:Cast(project.util.enemy.bestTarget)
                    and project.util.debug.alert.offensive("Voidwraith! dbm_bars " .. spell_name, project.priest.spells.voidwraith.id)
        end
    end
end)

project.priest.spells.voidwraith:Callback("pve", function(spell)
    if not project.settings.priest_offensives_shadowfiend then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if project.util.enemy.bestTarget
            and project.util.enemy.bestTarget.ttd < 8 then
        return
    end

    if project.util.enemy.withPurge == 0 then
        return
    end

    if project.priest.spells.mindBlast.cd > awful.gcd * 2 then
        return
    end

    if awful.player.buff("Power of the Dark Side") then
        return
    end

    if project.util.friend.total == 1 then
        return spell:Cast(project.util.enemy.bestTarget)
                and project.util.debug.alert.offensive("Voidwraith! spam_solo", project.priest.spells.voidwraith.id)
    end

    return project.priest.spells.voidwraith("dbm_bars")
            or project.priest.spells.voidwraith("party_damage")
            or project.priest.spells.voidwraith("fullaton")
            or project.priest.spells.voidwraith("radiance")
end)

project.priest.spells.voidwraith:Callback("pvp", function(spell)
    if not project.settings.priest_offensives_shadowfiend then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if project.util.enemy.bestTarget
            and project.util.enemy.bestTarget.ttd < 5
            and not awful.arena then
        return
    end

    if project.util.enemy.withPurge == 0 then
        return
    end

    return project.priest.spells.voidwraith("voidheart")
            or project.priest.spells.voidwraith("atleast1CD")
end)




