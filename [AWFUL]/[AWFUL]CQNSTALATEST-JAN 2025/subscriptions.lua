local Unlocker, awful, project = ...

local function print_active()
    print(awful.colors.red .. "[CQNSTA'S ROTATIONS] " .. awful.colors.yellow .. "Rotation is active!")
    print(awful.colors.red .. "[CQNSTA'S ROTATIONS] " .. awful.colors.yellow .. "Enjoy!")
end

project.subscription.is_active = function()
    return awful.player.specID == project.util.id.spec.DISCIPLINE
end

project.subscription.check = function()
    if project.subscription.is_active() then
        print_active()
        return true
    end
end

