local Unlocker, awful, project = ...

project.util.check.target.viable = function(target, should_not_face_enemy)
    if not target then
        return
    end

    if target.debuff("Cyclone") or target.debuff("Diamond Ice") then
        return
    end

    if target.dead then
        return
    end

    if not awful.arena then
        if not target.los then
            return
        end

        if target.dist > project.util.check.player.range() then
            return
        end
    end

    if target.enemy then
        if not target.los then
            return
        end

        if target.dist > project.util.check.player.range() then
            return
        end

        if target.buff("Spell Reflection")
                or target.buff("Nether Ward") then
            return
        end

        if not should_not_face_enemy and not awful.mapID == 2662 then
            if not target.playerFacing then
                return
            end
        end

        if awful.mapID == 2662 then
            if target.distanceTo(project.util.friend.tank) > 10 then
                return
            end

            if target.casting == "Darkness Comes" then
                return
            end
        end

        if target.bcc then
            return
        end

        if target.immuneMagicDamage then
            return
        end
    end

    return true
end