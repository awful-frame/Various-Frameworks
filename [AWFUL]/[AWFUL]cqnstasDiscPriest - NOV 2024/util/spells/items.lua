local Unlocker, awful, project = ...

awful.Populate({
    honorTrinket = awful.Item(218422),
    conquestTrinket = awful.Item(218716),

    healthstone = awful.Item(5512),
    conjured_mana_bun = awful.Item(113509)
}, project.util.spells.items, getfenv(1))
