local Unlocker, awful, project = ...

local function rotation(type, target, target_to_spread_purge)
    if project.util.cast.block.spell_name == "Smite" then
        return
    end

    if project.util.cast.block.spell_name == "Mind Blast" then
        return
    end

    if project.util.cast.block.spell_name == "Void Blast" then
        return
    end

    if project.util.cast.block.spell_name == "Power Word: Radiance" then
        return
    end

    if awful.player.channel == "Penance" then
        return
    end

    if awful.player.channel == "Dark Reprimand" then
        return
    end

    local best_penance_target = project.priest.discipline.rotation.util.find_best_target_to_ptw_penance_spread(type)

    if project.util.enemy.withPurge == 0 then
        project.priest.spells.purgeTheWicked("default", best_penance_target)
    end

    if awful.player.buff("Voidheart") then
        return project.priest.spells.penance("from_attack", best_penance_target)
                or project.priest.spells.smite(type, target)
    end

    project.priest.spells.death(type, target)
    project.priest.spells.mindBlast(type, target)
    project.priest.spells.penance("from_attack", best_penance_target)

    return project.priest.spells.purgeTheWicked("spread", type, target_to_spread_purge)
            or project.priest.spells.smite(type, target)
end

project.priest.discipline.rotation.attack = function(type)
    if awful.player.buff("Ultimate Penitence") then
        return
    end

    local target_to_spread_purge
    target_to_spread_purge = project.util.check.enemy.spread("Purge the Wicked", true, false, true)

    project.priest.spells.purgeTheWicked("pvp_interrupt", type)
    project.priest.spells.purgeTheWicked("pvp_stealth", type)

    if type == "pvp" then
        if project.util.enemy.bestTarget then
            project.priest.spells.death("execute", project.util.enemy.bestTarget)
        end
    end

    if type == "pve"
            and project.util.friend.total > 1
            and not awful.target.inCombat then
        return
    end

    if awful.arena
            and project.util.friend.existingClasses['Rogue']
            and not awful.target.inCombat then
        return
    end

    if type == "pvp"
            and project.util.friend.bestTarget.hp < 20
            and project.priest.discipline.rotation.util.is_premonition() then
        return
    end

    if not awful.target.enemy then
        return project.priest.spells.purgeTheWicked("spread", type, target_to_spread_purge)
    end

    if not project.util.check.target.viable(awful.target) then
        return project.priest.spells.purgeTheWicked("spread", type, target_to_spread_purge)
    end

    return rotation(type, awful.target, target_to_spread_purge)
end