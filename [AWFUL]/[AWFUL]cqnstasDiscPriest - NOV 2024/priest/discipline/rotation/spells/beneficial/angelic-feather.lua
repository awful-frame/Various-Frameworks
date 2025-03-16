local Unlocker, awful, project = ...

local movementSpeedBuffs = {
    "Angelic Feather",
    "Body and Soul",
    "Sprint",
    "Dash",
    "Aspect of the Cheetah",
    "Stampeding Roar",
    "Tiger's Lust",
    "Blessing of Freedom",
}

project.priest.spells.angelicFeather:Callback("self", function(spell)
    if not project.settings.priest_cds_angelic_feather_self then
        return
    end

    if awful.player.buff("Arena Preparation") then
        return
    end

    if awful.player.buff("Preparation") then
        return
    end

    if awful.player.buff("Premonition of Insight") then
        return
    end

    if project.util.friend.danger then
        return
    end

    if not project.util.check.player.moving_for(1) then
        return
    end

    if awful.player.rooted then
        return
    end

    if awful.player.slowed then
        return
    end

    if awful.player.buffFrom(movementSpeedBuffs) then
        return
    end

    if project.util.friend.totalViable > 1 then
        if spell.charges <= 2 then
            if project.util.friend.bestTarget
                    and project.util.friend.bestTarget.los
                    and project.util.friend.bestTarget.dist < 40
                    and project.util.enemy.bestTarget
                    and project.util.enemy.bestTarget.los
                    and project.util.enemy.bestTarget.dist < 40
                    and awful.enemyHealer
                    and awful.enemyHealer.name
                    and not awful.player.movingToward(awful.enemyHealer, { angle = 90 })
                    and not awful.enemyHealer.cc then
                return
            end
        end
    end

    return spell:Cast(awful.player)
            and project.util.debug.alert.beneficial("Angelic Feather! self", project.priest.spells.angelicFeather.id)
end)

project.priest.spells.angelicFeather:Callback("party", function(spell)
    if not project.settings.priest_cds_angelic_feather_party then
        return
    end

    if not awful.arena then
        return
    end

    if awful.player.buff("Arena Preparation") then
        return
    end

    if awful.player.buff("Preparation") then
        return
    end

    if awful.player.buff("Premonition of Insight") then
        return
    end

    if project.util.friend.danger then
        return
    end

    if project.util.enemy.totalPlayers > 3 then
        return
    end

    if awful.player.hasTalent("Divine Feathers") then
        if not project.util.check.player.moving_for(1) then
            return
        end

        if awful.player.rooted then
            return
        end

        if awful.player.slowed then
            return
        end

        if awful.player.buffFrom(movementSpeedBuffs) then
            return
        end

        if project.util.friend.totalViable > 1 then
            if spell.charges <= 2 then
                if project.util.friend.bestTarget
                        and project.util.friend.bestTarget.los
                        and project.util.friend.bestTarget.dist < 40
                        and project.util.enemy.bestTarget
                        and project.util.enemy.bestTarget.los
                        and project.util.enemy.bestTarget.dist < 40
                        and awful.enemyHealer
                        and awful.enemyHealer.name
                        and not awful.player.movingToward(awful.enemyHealer, { angle = 90 })
                        and not awful.enemyHealer.cc then
                    return
                end
            end
        end
    end

    if not awful.player.hasTalent("Divine Feathers") then
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

        if project.util.friend.melees > 0
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

        if friend.buffFrom(movementSpeedBuffs) then
            return
        end

        if not friend.target.enemy then
            return
        end

        if friend.melee then
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
    if awful.player.buff("Ultimate Penitence") then
        return
    end

    return project.priest.spells.angelicFeather("self")
end)

project.priest.spells.angelicFeather:Callback("pvp", function(spell)
    if awful.player.buff("Ultimate Penitence") then
        return
    end

    if awful.player.hasTalent("Divine Feathers")
            and project.util.friend.melees > 0
            and project.settings.priest_cds_angelic_feather_party then
        return project.priest.spells.angelicFeather("party")
    end

    return project.priest.spells.angelicFeather("self")
            or project.priest.spells.angelicFeather("party")
end)
