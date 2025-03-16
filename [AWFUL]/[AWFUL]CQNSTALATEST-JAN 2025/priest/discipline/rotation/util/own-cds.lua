local Unlocker, awful, project = ...

project.priest.discipline.rotation.util.own_cds = function()
    local own_cds = false

    if awful.player.used(project.priest.spells.shadowfiend.id, 15)
            or awful.player.used(project.priest.spells.powerInfusion.id, 15)
            or awful.player.used(project.priest.spells.darkArchangel.id, 8)
            or awful.player.buff(project.util.id.spell.POWER_INFUSION)
            or awful.player.buff(project.util.id.spell.DARK_ARCHANGEL) then
        own_cds = true
    end

    if project.settings.priest_burst then
        own_cds = true
        awful.alert(awful.colors.red .. "BURST MODE", project.priest.spells.powerInfusion.id)
        C_Timer.After(5 * awful.gcd, function()
            project.settings.priest_burst = false
        end)
    end

    if own_cds then
        project.util.friend.total_cds = project.util.friend.total_cds + 1
    end

    return own_cds
end
