local Unlocker, awful, project = ...

local auto_target_on_cd = false
local auto_target_cd = 0.5

local function set_auto_target_cd()
    auto_target_on_cd = true
    C_Timer.After(auto_target_cd, function()
        auto_target_on_cd = false
    end)
end

project.util.best_target.select = function()
    if not project.settings.general_auto_target then
        return
    end

    if awful.target and awful.target.enemy then
        if auto_target_on_cd then
            return
        end
    end

    if not project.util.enemy.bestTarget then
        return
    end

    if awful.target.guid == project.util.enemy.bestTarget.guid then
        return
    end

    if project.util.friend.total == 1 then
        return
    end

    set_auto_target_cd()
    project.util.enemy.bestTarget.setTarget()
end