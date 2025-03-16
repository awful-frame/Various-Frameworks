local Unlocker, awful, project = ...

local movement_speed_buffs = {
    project.util.id.spell.ANGELIC_FEATHER_BUFF,
    project.util.id.spell.BLAZE_OF_LIGHT,
    project.util.id.spell.BODY_AND_SOUL,
    project.util.id.spell.SPRINT,
    project.util.id.spell.DASH,
    project.util.id.spell.ASPECT_OF_THE_CHEETAH,
    project.util.id.spell.STAMPEDING_ROAR_1,
    project.util.id.spell.STAMPEDING_ROAR_2,
    project.util.id.spell.STAMPEDING_ROAR_3,
    project.util.id.spell.TIGERS_LUST,
    project.util.id.spell.BLESSING_OF_FREEDOM,
}

local function should_feather_self(spell)
    if awful.player.rooted then
        return
    end

    if awful.player.slowed then
        return
    end

    if project.util.check.scenario.type() == "pvp" then
        if awful.player.buff(project.util.id.spell.ARENA_PREPARATION) then
            return
        end

        if awful.player.buff(project.util.id.spell.PREPARATION) then
            return
        end
    end

    local moving_for_sec = 1.5
    if spell.charges == 3 then
        moving_for_sec = 0.5
    end
    if spell.charges == 2 then
        moving_for_sec = 1
    end

    if not project.util.check.player.moving_for(moving_for_sec) then
        return
    end

    if awful.player.buffFrom(movement_speed_buffs) then
        return
    end

    if project.util.friend.totalViable > 1
            and spell.charges <= 1
            and project.util.friend.best_target.unit
            and project.util.friend.best_target.unit.los
            and project.util.friend.best_target.unit.dist < 40
            and project.util.enemy.best_target.unit
            and project.util.enemy.best_target.unit.los
            and project.util.enemy.best_target.unit.dist < 40
            and awful.enemyHealer
            and awful.enemyHealer.name
            and not awful.player.movingToward(awful.enemyHealer, { angle = 120 })
            and not awful.enemyHealer.cc then
        return
    end

    return true
end

project.priest.spells.angelicFeather:Callback("self", function(spell)
    if not project.settings.priest_cds_angelic_feather_self then
        return
    end

    if not should_feather_self(spell) then
        return
    end

    return spell:Cast(awful.player)
            and project.util.debug.alert.beneficial("Angelic Feather! self", project.priest.spells.angelicFeather.id)
end)

project.priest.spells.angelicFeather:Callback("party", function(spell)
    if not project.settings.priest_cds_angelic_feather_party then
        return
    end

    if awful.player.hasTalent(project.util.id.spell.DIVINE_FEATHERS_TALENT)
            and not should_feather_self(spell) then
        return
    end

    if not awful.player.hasTalent(project.util.id.spell.DIVINE_FEATHERS_TALENT) then
        if not awful.arena then
            return
        end

        if spell.charges <= 2 then
            return
        end
    end

    awful.group.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if spell.charges <= 1
                and project.util.friend.melees > 0
                and not friend.melee then
            return
        end

        if not friend.los then
            return
        end

        if not friend.inCombat then
            return
        end

        if not friend.moving then
            return
        end

        if friend.mounted then
            return
        end

        if friend.rooted then
            return
        end

        if friend.buffFrom(movement_speed_buffs) then
            return
        end

        if not friend.target.enemy then
            return
        end

        if friend.melee and spell.charges <= 1 then
            if friend.meleeRangeOf(friend.target) then
                return
            end
        end

        if friend.speed > 10 then
            return
        end

        return spell:SmartAoE(friend)
                and project.util.debug.alert.beneficial("Angelic Feather! party", project.priest.spells.angelicFeather.id)
    end)
end)

project.priest.spells.angelicFeather:Callback("pve", function(spell)
    if project.util.friend.danger then
        return
    end

    if awful.player.used(project.util.id.spell.ANGELIC_FEATHER, 5) then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT) then
        return
    end

    return project.priest.spells.angelicFeather("self")
end)

project.priest.spells.angelicFeather:Callback("pvp", function(spell)
    if project.util.friend.best_target.unit.hp < 60 then
        return
    end

    if awful.player.used(project.util.id.spell.ANGELIC_FEATHER, 5) then
        return
    end

    if awful.player.buff(project.util.id.spell.PREMONITION_OF_INSIGHT) then
        return
    end

    if project.util.friend.withAtonement == 0 then
        return
    end

    if awful.arena
            and awful.player.manaPct > 95
            and not awful.player.combat then
        return
    end

    if awful.player.hasTalent(project.util.id.spell.DIVINE_FEATHERS_TALENT)
            and project.util.friend.melees > 0
            and project.settings.priest_cds_angelic_feather_party then
        return project.priest.spells.angelicFeather("party")
    end

    return project.priest.spells.angelicFeather("self")
            or project.priest.spells.angelicFeather("party")
end)
