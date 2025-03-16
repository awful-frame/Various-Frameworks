local Unlocker, awful, project = ...

project.priest.discipline.rotation.beneficial = function(type)
    if not project.settings.priest_cds_enabled then
        return
    end

    project.priest.spells.leapOfFaith(type)

    project.priest.spells.powerWordFortitude()
    project.priest.spells.inner_light_and_shadow()
    project.priest.spells.angelicFeather(type)

    local target = project.util.friend.bestTarget

    if not target then
        return
    end

    if target.buff("Temporal Shield")
            or target.buff("Alter Time") then
        return
    end

    if target.immuneMagicDamage
            or target.immunePhysicalDamage then
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

    if type == "pvp"
            and project.util.friend.attackers.total == 0 then
        return
    end

    if type == "pve"
            and project.util.enemy.bestTarget
            and project.util.enemy.bestTarget.ttd < 5 then
        return
    end

    if awful.player.buff("Arena Preparation") then
        return
    end

    if awful.player.buff("Preparation") then
        return
    end

    if awful.player.buff("Ultimate Penitence") then
        return project.priest.spells.voidShift(type)
    end

    return project.priest.spells.voidShift(type)
            or project.priest.spells.archangel(type)
            or project.priest.spells.rapture(type)
            or project.priest.spells.painSuppression(type)
            or project.priest.spells.ultimatePenitence(type)
            or project.priest.spells.powerWordBarrier(type)
end