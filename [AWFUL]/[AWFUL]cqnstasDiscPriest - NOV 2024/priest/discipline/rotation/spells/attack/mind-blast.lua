local Unlocker, awful, project = ...

local function should_mind_blast()
    if awful.player.buffRemains("Premonition of Insight") > 3 then
        return
    end

    if awful.player.buff("Power of the Dark Side") then
        return
    end

    if project.priest.discipline.rotation.util.is_premonition()
            and project.util.friend.danger then
        return
    end

    if awful.player.debuff("Scorpid Venom")
            and awful.player.debuffRemains("Scorpid Venom") < project.priest.spells.mindBlast.castTime then
        return
    end

    return true
end

project.priest.spells.mindBlast:Callback("totem_stomp", function(spell, totem)
    if not should_mind_blast() then
        return
    end

    return project.util.cast.stop_moving(spell, totem, true, true)
            and project.util.debug.alert.attack("Mind Blast! totem_stomp " .. totem.name, project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("pvp", function(spell, target)
    if not should_mind_blast() then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! spam_notCB", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("fullaton", function(spell, target)
    if not project.priest.discipline.rotation.util.full_aton() then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! fullaton", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("radiance", function(spell, target)
    if not should_mind_blast() then
        return
    end

    if not awful.player.used(project.priest.spells.radiance.id, 5) then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! radiance", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("shadow_covenant", function(spell, target)
    if not awful.player.buff("Shadow Covenant") then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! shadow_covenant", project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("dbm_bars", function(spell, target)
    for spell_name, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.prio ~= 0 then
            return
        end

        if bar_data.timer < awful.time then
            return project.util.cast.stop_moving(spell, target, true)
                    and project.util.debug.alert.offensive("Mind Blast! dbm_bars " .. spell_name, project.priest.spells.mindBlast.id)
        end
    end
end)

project.priest.spells.mindBlast:Callback("party_damage", function(spell, target)
    if awful.time < project.util.party_damage.early_time then
        return
    end

    return project.util.cast.stop_moving(spell, target, true)
            and project.util.debug.alert.attack("Mind Blast! party_damage " .. project.util.party_damage.spell, project.priest.spells.mindBlast.id)
end)

project.priest.spells.mindBlast:Callback("pve", function(spell, target)
    if not should_mind_blast() then
        return
    end

    if project.util.enemy.bestTarget
            and project.util.enemy.bestTarget.ttd < 5 then
        return
    end

    if not project.priest.discipline.rotation.util.is_premonition() then
        if IsPlayerSpell(451234) and project.priest.spells.voidwraith.cd <= awful.gcd * 2 then
            return
        end
    end

    if project.util.friend.total == 1 then
        return project.util.cast.stop_moving(spell, target, true)
                and project.util.debug.alert.attack("Mind Blast! spam_solo", project.priest.spells.mindBlast.id)
    end

    return project.priest.spells.mindBlast("fullaton", target)
            or project.priest.spells.mindBlast("shadow_covenant", target)
            or project.priest.spells.mindBlast("dbm_bars", target)
            or project.priest.spells.mindBlast("party_damage", target)
            or project.priest.spells.mindBlast("radiance", target)
end)