local Unlocker, awful, project = ...

project.priest.discipline.rotation.beneficial = function(type)
    if not project.settings.priest_cds_enabled then
        return
    end

    project.priest.spells.leapOfFaith(type)

    project.priest.spells.powerWordFortitude()
    if type == "pvp" and IsPlayerSpell(project.util.id.spell.INNER_LIGHT_AND_SHADOW) then
        project.priest.spells.inner_light_and_shadow()
    end
    project.priest.spells.angelicFeather(type)

    local target = project.util.friend.best_target.unit

    if not target then
        return
    end

    if not target.inCombat then
        return
    end

    if not awful.arena then
        if project.util.enemy.totalViable == 0 then
            return
        end
    end

    if type == "pve"
            and project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.ttd < 8 then
        return
    end

    if awful.player.buff(project.util.id.spell.ARENA_PREPARATION) then
        return
    end

    if awful.player.buff(project.util.id.spell.PREPARATION) then
        return
    end

    if target.buffFrom({ project.util.id.spell.TEMPORAL_SHIELD, project.util.id.spell.ALTER_TIME, project.util.id.spell.REWIND }) then
        return project.priest.spells.archangel(type)
                or project.priest.spells.ultimatePenitence(type)
    end

    if type == "pvp" and project.util.friend.best_target.attackers.total == 0 then
        if awful.arena then
            return project.priest.spells.archangel(type)
                    or project.priest.spells.rapture(type)
        end

        return
    end

    return project.priest.spells.voidShift(type)
            or project.priest.spells.archangel(type)
            or project.priest.spells.rapture(type)
            or project.priest.spells.painSuppression(type)
            or project.priest.spells.ultimatePenitence(type)
            or project.priest.spells.powerWordBarrier(type)
end