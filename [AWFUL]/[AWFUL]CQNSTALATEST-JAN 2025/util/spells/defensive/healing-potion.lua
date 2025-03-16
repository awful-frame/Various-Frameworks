local Unlocker, awful, project = ...

local function healing_potion_below20HPA(item)
    if project.priest.spells.painSuppression.queued then
        return
    end

    if awful.player.hpa > 20 then
        return
    end

    return item:Use()
            and project.util.debug.alert.defensive("Healing Potion! below30HPA " .. item.id, 431416)
end

local function healing_potion_pve(item)
    return healing_potion_below20HPA(item)
end

project.util.spells.defensive.healing_potion = function(type)
    if not project.settings.defensives_healing_potion then
        return
    end

    if type == "pvp" then
        return
    end

    if not awful.player.inCombat then
        return
    end

    if not project.util.enemy.best_target.unit then
        return
    end

    local potions = {
        project.util.spells.items.algari_healing_potion_3,
        project.util.spells.items.algari_healing_potion_2,
        project.util.spells.items.algari_healing_potion_1,
    }

    for _, potion in ipairs(potions) do
        if potion:Usable() then
            return healing_potion_pve(potion)
        end
    end
end