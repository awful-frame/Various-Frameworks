local Unlocker, awful, project = ...

local function attackers_check(enemy)
    if not awful.arena then
        return false
    end

    if project.util.friend.total == 2 then
        if project.util.friend.total_cds > 0 then
            return true
        end

        return false
    end

    local total = project.util.check.target.attackers(enemy).total
    if total > 0 then
        return true
    end

    return false
end

project.priest.spells.mindControl:Callback("pvp_enemy_healer", function(spell)
    if not project.settings.priest_cc_mind_control_healer then
        return
    end

    if not awful.enemyHealer then
        return
    end

    if not awful.enemyHealer.name then
        return
    end

    if not project.util.enemy.best_target.unit then
        return
    end

    if project.util.enemy.best_target.unit.guid == awful.enemyHealer.guid then
        return
    end

    if project.util.enemy.total_cds > 0
            and project.util.friend.total_cds == 0 then
        return
    end

    if project.util.friend.best_target.unit.hpa < 70 then
        return
    end

    if not project.util.cc.check_fear(awful.enemyHealer) then
        return
    end

    if attackers_check(awful.enemyHealer) then
        return
    end

    return spell:Cast(awful.enemyHealer)
            and project.util.debug.alert.cc("Mind Control! pvp_enemy_healer", project.priest.spells.mindControl.id)
end)

project.priest.spells.mindControl:Callback("pvp_enemy_bursting", function(spell)
    if not project.settings.priest_cc_mind_control_bursting then
        return
    end

    if project.util.enemy.total_cds == 0 then
        return
    end

    if project.util.friend.best_target.unit.hpa < 80 then
        return
    end

    awful.enemies.loop(function(enemy)
        if not project.util.cc.check_fear(enemy) then
            return
        end

        if attackers_check(enemy) then
            return
        end

        if not enemy.target then
            return
        end

        if not enemy.target.friend then
            return
        end

        local total = project.util.check.target.cooldowns(enemy.target, enemy).total
        if total == 0 then
            return
        end

        return spell:Cast(enemy)
                and project.util.debug.alert.cc("Mind Control! pvp_enemy_bursting", project.priest.spells.mindControl.id)
    end)
end)

project.priest.spells.mindControl:Callback("pve", function(spell)
    return
end)

project.priest.spells.mindControl:Callback("pvp", function(spell)
    if not project.settings.priest_cc_mind_control then
        return
    end

    if project.util.evade.block_cast then
        return
    end

    if project.util.friend.danger then
        return
    end

    if awful.player.buffFrom({ project.util.id.spell.SHADOW_COVENANT,
                               project.util.id.spell.VOIDHEART,
                               project.util.id.spell.PREMONITION_OF_INSIGHT,
                               project.util.id.spell.PREMONITION_OF_SOLACE,
                               project.util.id.spell.PREMONITION_OF_PIETY }) then
        return
    end

    if project.util.enemy.totalViable == 1 then
        return
    end

    return project.priest.spells.mindControl("pvp_enemy_healer")
            or project.priest.spells.mindControl("pvp_enemy_bursting")
end)