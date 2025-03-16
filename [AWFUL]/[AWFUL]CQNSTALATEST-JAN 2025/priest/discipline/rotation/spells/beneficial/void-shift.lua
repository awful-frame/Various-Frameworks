local Unlocker, awful, project = ...

local function find_best_target_to_shift()
    if project.util.friend.total < 2 then
        return
    end

    local threshold_hp = 30

    local best_friend
    local min_attackers = 10
    local max_hp = 0

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if friend.hp < threshold_hp then
            return
        end

        local total = project.util.check.target.attackers(friend).total

        if total < min_attackers then
            min_attackers = total
            best_friend = friend
            max_hp = friend.hp
        elseif total == min_attackers then
            if friend.hp > max_hp then
                best_friend = friend
                max_hp = friend.hp
            end
        end
    end)

    if best_friend then
        project.util.debug.alert.beneficial(string.format("Best target to shift: %s | HP: %d | Attackers: %d", best_friend.name, best_friend.hp, best_friend.attackers), project.priest.spells.voidShift.id)
    else
        project.util.debug.alert.beneficial("No suitable target found to shift.", project.priest.spells.voidShift.id)
    end

    return best_friend
end

project.priest.spells.voidShift:Callback("below30HP_noDEF_noTRINKET_atleast1CD", function(spell)
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        return
    end

    if project.util.enemy.total_cds == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 30 then
        return
    end

    if project.util.friend.best_target.defensives.def > 0 then
        return
    end

    local target = project.util.friend.best_target.unit
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        target = find_best_target_to_shift()
    end

    if project.util.spells.items.conquestTrinket.cd < 10 and project.util.spells.items.honorTrinket.cd < 10 then
        return
    end

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.beneficial("Void Shift! below30HP_noDEF_noTRINKET_atleast1CD", project.priest.spells.voidShift.id)
end)

project.priest.spells.voidShift:Callback("below30HP_noDEF_noTRINKET_incomingCC", function(spell)
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        return
    end

    local incoming_cc, _ = project.util.check.target.incoming(awful.player)
    if not incoming_cc then
        return
    end

    local phase_shift = awful.player.hasTalent(project.util.id.spell.PHASE_SHIFT_TALENT) and project.priest.spells.fade.cd < awful.gcd
    local meld = IsPlayerSpell(project.util.id.spell.SHADOWMELD) and project.util.spells.racials.shadowmeld.cd < awful.gcd

    if phase_shift or meld then
        return
    end

    if project.util.friend.best_target.unit.hp > 30 then
        return
    end

    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    local target = project.util.friend.best_target.unit
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        target = find_best_target_to_shift()
    end

    if project.util.spells.items.conquestTrinket.cd < 10 and project.util.spells.items.honorTrinket.cd < 10 then
        return
    end

    if awful.player.castID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.beneficial("Void Shift! below30HP_noDEF_noTRINKET_incomingCC", project.priest.spells.voidShift.id)
end)

project.priest.spells.voidShift:Callback("below20HP_noDRB", function(spell)
    if project.util.friend.best_target.unit.hp > 20 then
        return
    end

    if project.util.friend.best_target.defensives.def_best > 0 then
        return
    end

    local target = project.util.friend.best_target.unit
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        target = find_best_target_to_shift()
    end

    if project.settings.priest_cds_trinket_void_shift
            and project.util.friend.best_target.defensives.def == 0
            and awful.player.ccRemains > 2 then
        if project.util.spells.items.conquestTrinket:Use() or project.util.spells.items.honorTrinket:Use() then
            awful.alert(awful.colors.red .. "Trinket -> Void Shift", 336126)
        end
    end

    if awful.player.castID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.beneficial("Void Shift! below20HP_noDRB", project.priest.spells.voidShift.id)
end)

project.priest.spells.voidShift:Callback("below10HP", function(spell)
    if project.util.friend.best_target.unit.hp > 10 then
        return
    end

    local target = project.util.friend.best_target.unit
    if project.util.friend.best_target.unit.guid == awful.player.guid then
        target = find_best_target_to_shift()
    end

    if project.settings.priest_cds_trinket_void_shift then
        if awful.player.ccRemains > 2 then
            if project.util.spells.items.conquestTrinket:Use()
                    or project.util.spells.items.honorTrinket:Use() then
                awful.alert(awful.colors.red .. "Trinket -> Void Shift", 336126)
            end
        end
    end

    if awful.player.castID then
        awful.call("SpellCancelQueuedSpell")
        awful.call("SpellStopCasting")
    end

    return project.util.cast.overlap.cast(spell, target)
            and project.util.debug.alert.beneficial("Void Shift! below10HP", project.priest.spells.voidShift.id)
end)

project.priest.spells.voidShift:Callback("pve", function()
    if not project.settings.priest_cds_void_shift then
        return
    end

    return project.priest.spells.voidShift("below20HP_noDRB")
            or project.priest.spells.voidShift("below10HP")
end)

project.priest.spells.voidShift:Callback("pvp", function()
    if not project.settings.priest_cds_void_shift then
        return
    end

    if project.util.friend.best_target.unit ~= awful.player.guid
            and project.util.friend.best_target.unit.class3 == project.util.id.class.PRIEST
            and project.util.friend.best_target.unit.used(project.util.id.spell.VOID_SHIFT, 3) then
        return
    end

    if awful.player.channelID then
        return project.priest.spells.voidShift("below10HP")
    end

    return project.priest.spells.voidShift("below30HP_noDEF_noTRINKET_atleast1CD")
            or project.priest.spells.voidShift("below30HP_noDEF_noTRINKET_incomingCC")
            or project.priest.spells.voidShift("below20HP_noDRB")
            or project.priest.spells.voidShift("below10HP")
end)