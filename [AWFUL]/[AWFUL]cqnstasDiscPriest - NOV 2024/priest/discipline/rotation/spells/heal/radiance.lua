local Unlocker, awful, project = ...

local function should_radiance()
    if awful.player.used(project.priest.spells.radiance.id, 2)
            and project.util.friend.bestTarget.hp > 30 then
        return
    end

    if project.util.friend.bestTarget.dist > 30 - 1 then
        return
    end

    if not project.util.friend.bestTarget.los then
        return
    end

    if awful.player.buffRemains("Harsh Discipline") > project.util.thresholds.buff()
            and awful.player.buffStacks("Harsh Discipline") == 2
            and not project.util.friend.danger then
        return
    end

    return true
end

project.priest.spells.radiance:Callback("expireWNT_aton", function(spell)
    if not awful.player.inCombat then
        return
    end

    if not awful.player.buff("Waste No Time") then
        return
    end

    if awful.player.buffRemains("Waste No Time") > project.util.thresholds.buff() then
        return
    end

    if project.util.friend.bestTarget.hp < 90 then
        return
    end

    if project.util.friend.withoutAtonement30Yards < 2 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! expireWNT_aton", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("arena_aton", function(spell)
    if not awful.arena then
        return
    end

    if not awful.player.inCombat then
        return
    end

    if awful.player.manaPct > 90 then
        return
    end

    if project.util.friend.bestTarget.hp > 95 then
        return
    end

    if project.util.friend.withoutAtonement30Yards < 2 then
        return
    end

    if spell.charges < 2 then
        if spell.nextChargeCD > 3 then
            return
        end
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! arena_aton", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("below60HP", function(spell)
    if project.util.friend.bestTarget.hp > 60 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! below60HP", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("below80HP_atleast1CD", function(spell)
    if project.util.friend.attackers.cd.players == 0 then
        return
    end

    if project.util.friend.bestTarget.hp > 80 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! below80HP_atleast1CD", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("2below70HP", function(spell)
    if project.util.friend.under70Hp30Yards < 2 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! 2below70HP", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("3below70HP_aton", function(spell)
    if project.util.friend.under70Hp30Yards < 3 then
        return
    end

    if project.util.friend.withoutAtonement30Yards < 3 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! 3below70HP_aton", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("atonement", function(spell)
    if project.util.enemy.bestTarget.name == "Anub'ikkaj" then
        return
    end

    if not awful.player.inCombat then
        return
    end

    if project.util.friend.within30Yards < 2 then
        return
    end

    if project.priest.discipline.rotation.util.full_aton() then
        return
    end

    if spell.charges < 2 then
        if spell.nextChargeCD > 3 then
            return
        end
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! atonement", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("party_damage", function(spell)
    if awful.time < project.util.party_damage.time - spell.castTime then
        return
    end

    if project.util.friend.within30Yards < 2 then
        return
    end

    if project.priest.discipline.rotation.util.full_aton() then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! party_damage " .. project.util.party_damage.spell, project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("dbm_bars", function(spell)
    if project.util.friend.within30Yards < 2 then
        return
    end

    if project.priest.discipline.rotation.util.full_aton() then
        return
    end

    for spell_name, bar_data in pairs(project.util.dbm_bars.active) do
        if bar_data.prio ~= 0 then
            return
        end

        if bar_data.timer - spell.castTime < awful.time then
            return spell:Cast()
                    and project.util.debug.alert.beneficial("Radiance! dbm_bars " .. spell_name, project.priest.spells.radiance.id)
        end
    end
end)

project.priest.spells.radiance:Callback("void_rift", function(spell)
    if project.util.friend.within30Yards < 2 then
        return
    end

    if project.priest.discipline.rotation.util.full_aton() then
        return
    end

    if project.priest.spells.massDispel.known and project.priest.spells.massDispel.cd > 2 then
        return
    end

    awful.fgroup.loop(function(friend)
        if friend.dead then
            return
        end

        if not friend.debuff("Void Rift") then
            return
        end

        if friend.dist > 30 then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.beneficial("Radiance! void_rift ", project.priest.spells.radiance.id)
    end)
end)

project.priest.spells.radiance:Callback("below50HP", function(spell)
    if project.util.friend.bestTarget.hp > 50 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! below50HP", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("pvp_combat_below3ATON_atleast1CD", function(spell)
    if not awful.player.inCombat then
        return
    end

    if project.util.friend.within30Yards < 3 then
        return
    end

    if project.util.friend.withAtonement30Yards >= 3 then
        return
    end

    if project.util.enemy.withOffensiveCds == 0 then
        return
    end

    if awful.arena then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! pvp_combat_below3ATON_atleast1CD", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("pve", function(spell)
    if not should_radiance() then
        return
    end

    if not project.util.enemy.bestTarget then
        return
    end

    if project.util.enemy.totalViable == 1 then
        if project.util.enemy.bestTarget
                and project.util.enemy.bestTarget.ttd < 3 then
            return
        end
    end

    return project.priest.spells.radiance("party_damage")
            or project.priest.spells.radiance("dbm_bars")
            or project.priest.spells.radiance("atonement")
            or project.priest.spells.radiance("void_rift")
            or project.priest.spells.radiance("3below70HP_aton")
end)

project.priest.spells.radiance:Callback("pvp", function(spell)
    if not should_radiance() then
        return
    end

    if awful.player.buffRemains("Premonition of Insight") > 3
            and project.util.friend.bestTarget.hp > 50 then
        return
    end

    return project.priest.spells.radiance("expireWNT_aton")
            or project.priest.spells.radiance("arena_aton")
            or project.priest.spells.radiance("2below70HP")
            or project.priest.spells.radiance("below80HP_atleast1CD")
            or project.priest.spells.radiance("below60HP")
            or project.priest.spells.radiance("pvp_combat_below3ATON_atleast1CD")
end)