local Unlocker, awful, project = ...

local function get_psychic_scream_enemies()
    if project.priest.spells.psychicScream.cd > awful.gcd then
        return 0, nil
    end

    local dist = 5.5
    local count, _, enemies = awful.enemies.around(awful.player, dist, project.util.cc.check_fear)

    return count, enemies
end

local function get_void_tendrils_enemies()
    if not IsPlayerSpell(project.util.id.spell.VOID_TENDRILS) then
        return 0, nil
    end

    if project.priest.spells.voidTendrils.cd > awful.gcd then
        return 0, nil
    end

    local dist = 5
    local count, _, enemies = awful.enemies.around(awful.player, dist, project.util.cc.check_root)

    return count, enemies
end

project.priest.discipline.rotation.cc = function(type)
    if not project.settings.priest_cc_enabled then
        return
    end

    if type == "pvp" then
        if awful.player.buff(project.util.id.spell.ARENA_PREPARATION) then
            return
        end

        if awful.player.buff(project.util.id.spell.PREPARATION) then
            return
        end
    end

    local count_pc, enemies_pc = get_psychic_scream_enemies()
    local count_vt, enemies_vt = get_void_tendrils_enemies()

    if not project.util.cc.holdGCD
            and project.priest.spells.psychicScream.cd <= awful.gcd
            and not project.util.friend.danger
            and awful.player.moving
            and awful.enemyHealer
            and awful.enemyHealer.name
            and awful.enemyHealer.dist < 8
            and project.util.cc.check_fear(awful.enemyHealer, false, true)
    then
        project.util.cc.holdGCD = true
        awful.call("SpellCancelQueuedSpell")
        C_Timer.After(1, function()
            project.util.cc.holdGCD = false
        end)
    end

    return project.priest.spells.psychicScream(type, count_pc, enemies_pc)
            or (IsPlayerSpell(project.util.id.spell.VOID_TENDRILS) and project.priest.spells.voidTendrils(type, count_vt, enemies_vt))
            or (IsPlayerSpell(project.util.id.spell.MIND_CONTROL) and project.priest.spells.mindControl(type))
end

awful.onEvent(function(info, event, source, dest)
    if not source.guid == awful.player.guid then
        return
    end

    if event == "SPELL_CAST_SUCCESS" then
        local spell_id = select(12, unpack(info))

        if spell_id == project.util.id.spell.PSYCHIC_SCREAM then
            project.util.cc.holdGCD = false
        end
    end
end)