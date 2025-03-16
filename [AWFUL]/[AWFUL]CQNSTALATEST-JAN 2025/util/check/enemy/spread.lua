local Unlocker, awful, project = ...

project.util.check.enemy.spread = function(debuff, player, facing, combat)
    return awful.enemies.find(function(enemy)
        if not project.util.check.target.viable(enemy, facing) then
            return
        end

        if player and not enemy.player then
            return
        end

        if combat and not enemy.inCombat then
            return
        end

        if enemy.debuffRemains(debuff) > project.util.thresholds.buff() then
            return
        end

        if enemy.buffFrom({ project.util.id.spell.SPELL_REFLECTION, project.util.id.spell.NETHER_WARD }) then
            return
        end

        return true
    end)
end
