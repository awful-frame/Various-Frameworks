local Unlocker, awful, project = ...

local damage_break_bcc_spells = {
    -- PRIEST
    [project.util.id.spell.SMITE] = true,
    [project.util.id.spell.MIND_BLAST] = true,
}

project.util.cast.bcc = function()
    if project.util.check.scenario.type() == "pve" then
        return
    end
    
    if project.util.friend.totalViable == 1 then
        return
    end

    local casting_spell_id = awful.player.castID
    if not damage_break_bcc_spells[casting_spell_id] then
        return
    end

    if awful.player.castTarget.guid
            and awful.player.castTarget.enemy
            and awful.player.castTarget.bcc then
        awful.call("SpellStopCasting")
    end
end