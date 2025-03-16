local Unlocker, awful, project = ...

awful.Populate({
    honorTrinket = awful.Item(project.util.id.item.HONOR_TRINKET),
    conquestTrinket = awful.Item(project.util.id.item.CONQUEST_TRINKET),

    healthstone = awful.Item(project.util.id.item.HEALTHSTONE),

    algari_healing_potion_1 = awful.Item(project.util.id.item.ALGARI_HEALING_POTION_1),
    algari_healing_potion_2 = awful.Item(project.util.id.item.ALGARI_HEALING_POTION_2),
    algari_healing_potion_3 = awful.Item(project.util.id.item.ALGARI_HEALING_POTION_3),

    tempered_potion_1 = awful.Item(project.util.id.item.TEMPERED_POTION_1),
    tempered_potion_2 = awful.Item(project.util.id.item.TEMPERED_POTION_2),
    tempered_potion_3 = awful.Item(project.util.id.item.TEMPERED_POTION_3),

    conjured_mana_bun = awful.Item(project.util.id.item.CONJURED_MANA_BUN)
}, project.util.spells.items, getfenv(1))
