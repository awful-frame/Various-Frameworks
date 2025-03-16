local Unlocker, awful, project = ...

if project.subscription.is_active(awful.player.name, awful.player.class, awful.player.spec) ~= 2 then
    return
end

if not project.gui then
    return
end

if awful.DevMode then
    project.gui:Group({
        name = awful.colors.red .. "---------------------",
    })

    project.gui.admin_group = project.gui:Group({
        name = "Admin",
    })
end

