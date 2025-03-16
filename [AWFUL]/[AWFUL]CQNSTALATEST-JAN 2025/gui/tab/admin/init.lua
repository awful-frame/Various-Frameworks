local Unlocker, awful, project = ...

if not project.subscription.is_active() then
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

