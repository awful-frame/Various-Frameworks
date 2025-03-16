local Unlocker, awful, project = ...

if not project.subscription.is_active() then
    return
end


if not project.gui then
    return
end

if awful.player.specID ~= project.util.id.spec.HOLY_PRIEST then
    return
end

project.gui:Group({
    name = awful.colors.red .. "---------------------",
})

project.gui.priest_holy_group = project.gui:Group({
    name = "PRIEST - Holy",
})
