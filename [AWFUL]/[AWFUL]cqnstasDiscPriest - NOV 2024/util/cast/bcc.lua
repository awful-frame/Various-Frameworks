local Unlocker, awful, project = ...

local damage_break_bcc_spells = {
    ["Smite"] = true,
    ["Mind Blast"] = true,
}

project.util.cast.bcc = function()
    if project.util.friend.totalViable == 1 then
        return
    end

    local casting_spell_name = awful.player.casting
    if not damage_break_bcc_spells[casting_spell_name] then
        return
    end

    if awful.player.castTarget
            and awful.player.castTarget.enemy
            and awful.player.castTarget.bcc then
        awful.call("SpellStopCasting")
    end
end