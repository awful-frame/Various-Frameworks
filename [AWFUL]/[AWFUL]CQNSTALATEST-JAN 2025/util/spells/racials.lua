local Unlocker, awful, project = ...

awful.Populate({
    shadowmeld = awful.Spell(project.util.id.spell.SHADOWMELD, {  ignoreMoving = true, ignoreCasting = true, ignoreChanneling = true }),
    bloodfury = awful.Spell(project.util.id.spell.BLOODFURY)
}, project.util.spells.racials, getfenv(1))
