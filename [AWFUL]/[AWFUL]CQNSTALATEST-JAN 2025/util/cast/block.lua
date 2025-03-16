local Unlocker, awful, project = ...

local double_cast_spells = {
    -- PRIEST
    [project.util.id.spell.FLASH_HEAL] = true,
    [project.util.id.spell.RADIANCE] = true,
    [project.util.id.spell.MIND_BLAST] = true,
    [project.util.id.spell.SMITE] = true,
    [project.util.id.spell.VOID_BLAST] = true,
    [project.util.id.spell.MIND_CONTROL] = true,
    [project.util.id.spell.ULTIMATE_PENITENCE] = true,


}

project.util.cast.block.spell = nil

project.util.cast.block.check = function()
    if not awful.player.castID and project.util.cast.block.spell then
        C_Timer.After(awful.buffer, function()
            project.util.cast.block.spell = nil
        end)
        return
    end

    if project.util.cast.block.spell then
        return
    end

    local casting_spell_id = awful.player.castID
    if not double_cast_spells[casting_spell_id] then
        return
    end

    project.util.cast.block.spell = casting_spell_id
    C_Timer.After(awful.player.castRemains + awful.buffer, function()
        project.util.cast.block.spell = nil
    end)
end