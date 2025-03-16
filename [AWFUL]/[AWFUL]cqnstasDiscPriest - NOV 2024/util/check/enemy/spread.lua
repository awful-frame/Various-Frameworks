local Unlocker, awful, project = ...

project.util.check.enemy.spread = function(debuff, player, facing, combat)
    return awful.enemies.find(function(enemy)
        if not project.util.check.target.viable(enemy, facing) then
            return
        end

        if player then
            if not enemy.player then
                return
            end
        end

        if combat then
            if not enemy.inCombat then
                return
            end
        end

        if enemy.debuffRemains(debuff) > project.util.thresholds.buff() then
            return
        end

        if enemy.buff("Spell Reflection") or enemy.buff("Nether Ward") then
            return
        end

        if enemy.debuff("Intimidation") then
            return
        end

        return true
    end)
end