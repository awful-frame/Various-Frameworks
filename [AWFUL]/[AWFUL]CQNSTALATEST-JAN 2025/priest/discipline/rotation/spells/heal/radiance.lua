local Unlocker, awful, project = ...

local combat_viable_exceptions = {
    project.util.id.npc.ANUBIKKAJ,
    project.util.id.npc.IZO_THE_GRAND_SPLICER,
    project.util.id.npc.THE_COAGLAMATION,
}

local function should_radiance()
    if awful.player.used(project.priest.spells.radiance.id, 3)
            and project.util.friend.best_target.unit.hp > 30 then
        return
    end

    if project.util.friend.best_target.unit.dist > 30 - 1 then
        return
    end

    if not project.util.friend.best_target.unit.los then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.HARSH_DISCIPLINE) > project.util.thresholds.buff()
            and awful.player.buffStacks(project.util.id.spell.HARSH_DISCIPLINE) == 2
            and not project.util.friend.danger then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_SOLACE)
            and project.util.friend.danger then
        return
    end

    return true
end

project.priest.spells.radiance:Callback("expireWNT_aton", function(spell)
    if not awful.player.inCombat then
        return
    end

    if not awful.player.buff(project.util.id.spell.WASTE_NO_TIME) then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.WASTE_NO_TIME) > project.util.thresholds.buff() then
        return
    end

    if project.util.friend.best_target.unit.hp < 90 then
        return
    end

    if project.util.friend.withoutAtonement30Yards < 1 then
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

    if project.util.friend.best_target.unit.hp > 95 then
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

project.priest.spells.radiance:Callback("below70HP", function(spell)
    if project.util.friend.best_target.unit.hp > 70 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! below70HP", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("below85HP_atleast1CD", function(spell)
    if project.util.friend.best_target.attackers.cdp == 0 then
        return
    end

    if project.util.friend.best_target.unit.hp > 85 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! below85HP_atleast1CD", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("2below90HP_aton", function(spell)
    if project.util.friend.under90Hp30Yards < 2 then
        return
    end

    if project.util.friend.withoutAtonement30Yards < 2 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! 2below90HP_aton", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("2below70HP_aton", function(spell)
    if project.util.friend.under70Hp30Yards < 2 then
        return
    end

    if project.util.friend.withoutAtonement30Yards < 2 then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! 2below70HP_aton", project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("atonement", function(spell)
    for _, id in ipairs(combat_viable_exceptions) do
        if project.util.enemy.combat_viable_ids[id] then
            return
        end
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

    if spell.charges == 0 then
        return
    end

    if spell.charges == 1 then
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

    local dbm_spell_name = project.util.dbm_bars.check(0, spell.castTime / 2)
    if not dbm_spell_name then
        return
    end

    return spell:Cast()
            and project.util.debug.alert.beneficial("Radiance! dbm_bars " .. dbm_spell_name, project.priest.spells.radiance.id)
end)

project.priest.spells.radiance:Callback("void_rift", function(spell)
    if awful.instanceType2 ~= project.util.id.instance.PARTY then
        return
    end

    if project.util.friend.within30Yards < 2 then
        return
    end

    if project.priest.discipline.rotation.util.full_aton() then
        return
    end

    if IsPlayerSpell(project.util.id.spell.MASS_DISPEL)
            and project.priest.spells.massDispel.cd > 1 then
        return
    end

    awful.fgroup.loop(function(friend)
        if friend.dead then
            return
        end

        if friend.dist > 30 then
            return
        end

        if not friend.debuff(project.util.id.spell.VOID_RIFT) then
            return
        end

        return spell:Cast()
                and project.util.debug.alert.beneficial("Radiance! void_rift ", project.priest.spells.radiance.id)
    end)
end)

project.priest.spells.radiance:Callback("below50HP", function(spell)
    if project.util.friend.best_target.unit.hp > 50 then
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

    if project.util.enemy.total_cds == 0 then
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

    if project.priest.spells.rapture.queued then
        return
    end

    if not project.util.enemy.best_target.unit then
        return
    end

    if project.util.enemy.totalViable == 1
            and project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.ttd < 3 then
        return
    end

    return project.priest.spells.radiance("party_damage")
            or project.priest.spells.radiance("dbm_bars")
            or project.priest.spells.radiance("atonement")
            or project.priest.spells.radiance("void_rift")
            or project.priest.spells.radiance("2below70HP_aton")
end)

project.priest.spells.radiance:Callback("pvp", function(spell)
    if not should_radiance() then
        return
    end

    if awful.player.buffRemains(project.util.id.spell.PREMONITION_OF_INSIGHT) > 3
            and project.util.friend.best_target.unit.hp > 50 then
        return
    end

    return project.priest.spells.radiance("expireWNT_aton")
            or project.priest.spells.radiance("arena_aton")
            or project.priest.spells.radiance("2below90HP_aton")
            or project.priest.spells.radiance("below85HP_atleast1CD")
            or project.priest.spells.radiance("below70HP")
            or project.priest.spells.radiance("pvp_combat_below3ATON_atleast1CD")
end)

awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_priest_enabled then
        return
    end

    if not project.settings.draw_priest_radiance_range then
        return
    end

    local x, y, z = awful.player.position()
    draw:SetColor(0, 255, 0, 255)
    draw:Circle(x, y, z, 30)
end)

local font = awful.createFont(8, "OUTLINE")
awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_priest_enabled then
        return
    end

    if not project.settings.draw_priest_radiance_icon then
        return
    end

    if awful.instanceType2 == project.util.id.instance.RAID then
        return
    end

    local txt = awful.textureEscape(project.priest.spells.radiance.id, 15, "0:10")

    awful.group.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if not friend.los then
            return
        end

        if friend.dist > 28 then
            return
        end

        local x, y, z = friend.position()
        draw:Text(txt, font, x, y, z)
    end)
end)