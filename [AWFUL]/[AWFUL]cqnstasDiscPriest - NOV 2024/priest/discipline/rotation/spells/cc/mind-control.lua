local Unlocker, awful, project = ...

local function is_enemy_charmable(enemy)
    if not enemy then
        return
    end

    if not enemy.player then
        return
    end

    if enemy.dead then
        return
    end

    if not enemy.los then
        return
    end

    if not enemy.inCombat then
        return
    end

    if enemy.dist > project.priest.spells.mindControl.range - 2 then
        return
    end

    if enemy.ccImmunityRemains > project.priest.spells.mindControl.castTime then
        return
    end

    if project.util.enemy.danger and enemy.disorientDR < 0.25 then
        return
    end

    if not project.util.enemy.danger and enemy.disorientDR < 0.5 then
        return
    end

    if not enemy.cc then
        if enemy.disorientDR ~= 1 and enemy.disorientDRRemains < 8 then
            return
        end
    end

    if enemy.cc and enemy.ccRemains >= project.priest.spells.mindControl.castTime then
        return
    end

    return true
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

    if not project.util.enemy.bestTarget then
        return
    end

    if project.util.enemy.bestTarget.guid == awful.enemyHealer.guid then
        return
    end

    if not is_enemy_charmable(awful.enemyHealer) then
        return
    end

    if project.util.enemy.withOffensiveCds > 0 then
        return
    end

    if project.util.friend.bestTarget.hp < 70 then
        return
    end

    if project.util.enemy.attackers.get(awful.enemyHealer.guid).t > 0 then
        return
    end

    return spell:Cast(awful.enemyHealer)
            and project.util.debug.alert.cc("Mind Control! pvp_enemy_healer", project.priest.spells.mindControl.id)
end)

project.priest.spells.mindControl:Callback("pvp_enemy_bursting", function(spell)
    if not project.settings.priest_cc_mind_control_bursting then
        return
    end

    if project.util.friend.bestTarget.hp < 70 then
        return
    end

    awful.enemies.loop(function(enemy)
        if not is_enemy_charmable(enemy) then
            return
        end

        local cds = project.util.check.target.cooldowns(enemy.target, enemy)
        if cds == 0 then
            return
        end

        local total = project.util.enemy.attackers.get(enemy.guid).t
        if total > 0 then
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

    if project.util.friend.danger then
        return
    end

    if awful.player.buff("Shadow Covenant")
            or awful.player.buff("Voidheart") then
        return
    end

    if awful.player.buff("Premonition of Insight") then
        return
    end

    if project.util.enemy.totalViable == 1 then
        return
    end

    return project.priest.spells.mindControl("pvp_enemy_healer")
            or project.priest.spells.mindControl("pvp_enemy_bursting")
end)