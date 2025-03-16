local Unlocker, awful, project = ...

project.util.cast.stop_moving_block = false
local stop_moving_on_cd = false

local function cast_no_stop(spell, target, smart_aoe)
    if smart_aoe then
        if spell:SmartAoE(target) then
            project.util.debug.alert.evade("STOP MOVING - NO CONTROL", 322712)
            return true
        end
    end

    if spell:Cast(target) then
        project.util.debug.alert.evade("STOP MOVING - NO CONTROL", 322712)
        return true
    end
end

local function cast_stop(spell, target, smart_aoe)
    awful.controlMovement(awful.spellCastBuffer + spell.castTime / 3)
    if smart_aoe then
        return spell:SmartAoE(target, { stopMoving = true })
    end
    return spell:Cast(target, { stopMoving = true })
end

project.util.cast.stop_moving = function(spell, target, damage, ignore_cd, smart_aoe)
    if not target then
        return
    end

    if project.util.evade.block_cast then
        return
    end

    if project.util.check.scenario.type() == "pve" then
        if awful.player.moving then
            return
        end

        if smart_aoe then
            return spell:SmartAoE(target)
        end

        return spell:Cast(target, project.util.cast.options())
    end

    if not stop_moving_on_cd then
        if project.util.cast.stop_moving_block
                or not project.settings.misc_stop_moving then
            project.util.debug.alert.evade("STOP MOVING - BLOCKED", 322712)
            stop_moving_on_cd = true
            C_Timer.After(10, function()
                stop_moving_on_cd = false
            end)
        end
    end

    if not ignore_cd then
        if stop_moving_on_cd then
            if awful.player.moving then
                if not project.settings.misc_stop_moving
                        or project.settings.misc_stop_moving_cd > 5 then
                    awful.alert(awful.colors.red .. "STOP MOVING", 322712)
                end

                return
            end
            return cast_no_stop(spell, target, smart_aoe)
        end

        if target.predictDistance(spell.castTime + awful.buffer) > project.util.check.player.range()
                or target.dist > project.util.check.player.range()
                or not target.los

                or (project.priest.spells.psychicScream.cd < awful.gcd
                    and ((awful.enemyHealer and awful.enemyHealer.name and awful.player.movingToward(awful.enemyHealer, { angle = 180, duration = 0.5 }))
                    or (awful.enemyHealer and awful.enemyHealer.name and awful.enemyHealer.dist < 20 and awful.enemyHealer.cc)))

                or (damage and project.util.friend.best_target.unit.hp < 30)

                or not project.util.friend.best_target.unit.los
                or project.util.friend.best_target.unit.dist > project.util.check.player.range()
        then
            return cast_no_stop(spell, target, smart_aoe)
        end

        stop_moving_on_cd = true
        C_Timer.After(project.settings.misc_stop_moving_cd, function()
            stop_moving_on_cd = false
        end)
    end

    if ignore_cd then
        project.util.debug.alert.evade("STOP MOVING - CONTROL IGNORE_CD", 322712)
    else
        project.util.debug.alert.evade("STOP MOVING - CONTROL " .. awful.time, 322712)
    end
    return cast_stop(spell, target, smart_aoe)
end
