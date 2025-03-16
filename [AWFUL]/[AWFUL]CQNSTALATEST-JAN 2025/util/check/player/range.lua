 local Unlocker, awful, project = ...

project.util.check.player.range = function()
    if awful.player.hasTalent(project.util.id.spell.PHANTOM_REACH_TALENT) then
        return 46
    end
    return 40
end

