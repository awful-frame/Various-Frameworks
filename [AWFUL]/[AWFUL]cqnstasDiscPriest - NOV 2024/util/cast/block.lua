local Unlocker, awful, project = ...

local double_cast_spells = {
    ["Flash Heal"] = true,
    ["Power Word: Radiance"] = true,
    ["Mind Blast"] = true,
    ["Smite"] = true,
    ["Void Blast"] = true,
    ["Mind Control"] = true,
    ["Ultimate Penitence"] = true,
}

project.util.cast.block.spell_name = nil

project.util.cast.block.check = function()
    if not awful.player.casting and project.util.cast.block.spell_name then
        C_Timer.After(awful.buffer, function()
            project.util.cast.block.spell_name = nil
        end)
        return
    end

    if project.util.cast.block.spell_name then
        return
    end

    local casting_spell_name = awful.player.casting
    if not double_cast_spells[casting_spell_name] then
        return
    end

    project.util.cast.block.spell_name = casting_spell_name
    C_Timer.After(awful.player.castRemains + awful.buffer, function()
        project.util.cast.block.spell_name = nil
    end)
end