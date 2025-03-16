local Unlocker, awful, project = ...

awful.Populate({
    shadowmeld = awful.Spell(58984, {  ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),
    bloodfury = awful.Spell(20572)
}, project.util.spells.racials, getfenv(1))
