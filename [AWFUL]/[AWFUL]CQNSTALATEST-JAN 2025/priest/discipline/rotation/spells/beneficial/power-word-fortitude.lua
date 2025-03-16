local Unlocker, awful, project = ...

local buffOnCooldown = false
local buffCooldown = 5

local function setBuffCooldown()
    buffOnCooldown = true
    C_Timer.After(buffCooldown, function()
        buffOnCooldown = false
    end)
end

project.priest.spells.powerWordFortitude:Callback(function(spell)
    if buffOnCooldown then
        return
    end

    if project.util.friend.best_target.unit.hp < 80 then
        return
    end

    if project.util.enemy.total_cds > 0 then
        return
    end

    awful.fgroup.loop(function(friend)
        if not project.util.check.target.viable(friend) then
            return
        end

        if not friend.buff(21562) or friend.buffRemains(21562) < 600 then
            setBuffCooldown()
            return spell:Cast()
                    and project.util.debug.alert.beneficial("Power Word: Fortitude! " .. friend.name, project.priest.spells.powerWordFortitude.id)
        end
    end)
end)
