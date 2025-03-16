local Unlocker, awful, project = ...

local bl_buffs = {
    project.util.id.spell.BLOODLUST,
    project.util.id.spell.HEROISM,
    project.util.id.spell.TIME_WARP,
    project.util.id.spell.FURY_OF_THE_ASPECTS,
    project.util.id.spell.PRIMAL_RAGE,
    project.util.id.item.DRUMS_OF_RAGE_EFFECT,
    project.util.id.item.DRUMS_OF_FURY_EFFECT,
    project.util.id.item.DRUMS_OF_THE_MOUNTAIN_EFFECT,
    project.util.id.item.DRUMS_OF_THE_MAELSTROM_EFFECT,
    project.util.id.item.DRUMS_OF_DEATHLY_FEROCITY,
    project.util.id.item.FERAL_HIDE_DRUMS,
}

local function tempered_potion_bloodlust(item)
    if not project.settings.offensives_tempered_potion_bloodlust then
        return
    end

    if not awful.player.buffFrom(bl_buffs) then
        return
    end

    return item:Use() and
            project.util.debug.alert.offensive("Tempered Potion! bloodlust", 431932)
end

local function tempered_potion_pve(item)
    return tempered_potion_bloodlust(item)
end

project.util.spells.offensive.tempered_potion = function(type)
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
        project.util.spells.items.tempered_potion_3,
        project.util.spells.items.tempered_potion_2,
        project.util.spells.items.tempered_potion_1,
    }

    for _, potion in ipairs(potions) do
        if potion:Usable() then
            return tempered_potion_pve(potion)
        end
    end
end