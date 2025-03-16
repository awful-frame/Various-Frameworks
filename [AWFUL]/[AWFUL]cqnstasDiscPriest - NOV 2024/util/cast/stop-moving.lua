local Unlocker, awful, project = ...

local stop_moving_on_cd = false
local cd = 3

project.util.cast.stop_moving = function(spell, target, damage, ignore_cd, smart_aoe)
    ignore_cd = ignore_cd or false

    if project.util.check.scenario.type() == "pve" then
        if awful.player.moving then
            return
        end
        return spell:Cast(target, project.util.cast.options())
    end

    if awful.player.moving
            and stop_moving_on_cd then
        return
    end

    if not ignore_cd and stop_moving_on_cd then
        return spell:Cast(target)
    end

    if not awful.player.moving

            or target.predictDistance(spell.castTime + awful.spellCastBuffer) > project.util.check.player.range()
            or target.dist > project.util.check.player.range()
            or not target.predictLoS(spell.castTime + awful.spellCastBuffer)
            or not target.los

            or (awful.enemyHealer and awful.enemyHealer.name and awful.player.movingToward(awful.enemyHealer, { angle = 120, duration = 0.5 }))

            or (damage and project.util.friend.bestTarget.hp < 30)

            or not project.util.friend.bestTarget.los
            or project.util.friend.bestTarget.dist > project.util.check.player.range()
    then
        if smart_aoe then
            return spell:SmartAoE(target)
        end
        return spell:Cast(target)
    end

    if not ignore_cd then
        stop_moving_on_cd = true
        C_Timer.After(cd, function()
            stop_moving_on_cd = false
        end)
    end

    awful.controlMovement(awful.tickRate * 3)
    if smart_aoe then
        return spell:SmartAoE(target, { stopMoving = true })
    end
    return spell:Cast(target, { stopMoving = true })
end


