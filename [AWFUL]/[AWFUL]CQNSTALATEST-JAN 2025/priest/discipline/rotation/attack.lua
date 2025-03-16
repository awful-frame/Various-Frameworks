local Unlocker, awful, project = ...

local function rotation(type, target)
    if project.util.cast.block.spell == project.util.id.spell.RADIANCE then
        return
    end

    local best_penance_target = project.priest.discipline.rotation.util.find_best_target_to_ptw_penance_spread(type)
    project.priest.spells.purgeTheWicked("default", best_penance_target)

    if not project.priest.discipline.rotation.util.is_premonition()
            and awful.player.buff(project.util.id.spell.VOIDHEART) then
        return project.priest.spells.penance("from_attack", best_penance_target)
                or project.priest.spells.smite(type, target)
    end

    project.priest.spells.death(type, target)
    project.priest.spells.mindBlast(type, target)
    project.priest.spells.penance("from_attack", best_penance_target)
    project.priest.spells.penance("from_heal")

    return project.priest.spells.purgeTheWicked("spread", type)
            or project.priest.spells.smite(type, target)
end

project.priest.discipline.rotation.attack = function(type)
    project.priest.spells.purgeTheWicked("pvp_interrupt", type)

    if type == "pvp" and project.util.enemy.best_target.unit then
        project.priest.spells.death("execute", project.util.enemy.best_target.unit)
    end

    if type == "pve"
            and project.util.friend.total > 1
            and not awful.target.inCombat then
        return
    end

    if awful.arena
            and project.util.friend.existing_classes[project.util.id.class.ROGUE]
            and not awful.target.inCombat then
        return
    end

    if not awful.target.enemy then
        return project.priest.spells.purgeTheWicked("spread", type)
    end

    if not project.util.check.target.viable(awful.target) then
        return project.priest.spells.purgeTheWicked("spread", type)
    end

    return rotation(type, awful.target)
end