local Unlocker, awful, project = ...

local subscriptions = {
    ["Priest"] = {
        ["Discipline"] = {
            ["Disguster"] = {
                purchase_timestamp = 1728930978,
                duration_hours = 720,
            },
        },
    },
}


local function print_active()
    print(awful.colors.red .. "[CQNSTA'S ROTATIONS] " .. awful.colors.yellow .. "Rotation is active!")
    print(awful.colors.red .. "[CQNSTA'S ROTATIONS] " .. awful.colors.yellow .. "Enjoy!")
end

project.subscription.check = function(name, class, spec)
    if class == "Priest" and spec == "Discipline" then
        print_active()
        return true
    end
    --local status, daysLeft, hoursLeft, minutesLeft = project.subscription.is_active(name, class, spec)
    --
    --if status == 0 then
    --    return false
    --elseif status == 1 then
    --    print_inactive()
    --    return false
    --elseif status == 2 then
    --    print_active(daysLeft, hoursLeft, minutesLeft)
    --    return true
    --elseif status == 3 then
    --    print_inactive()
    --    return false
    --end
end

project.subscription.is_active = function(name, class, spec)
    if class == "Priest" and spec == "Discipline" then
        return 2, 0, 0, 0
    end

    --local classSubscriptions = subscriptions[class]
    --
    --if not classSubscriptions then
    --    return 0, 0, 0, 0
    --end
    --
    --local specSubscriptions = classSubscriptions[spec]
    --
    --if not specSubscriptions then
    --    return 0, 0, 0, 0
    --end
    --
    --local subscription = specSubscriptions[name]
    --
    --if not subscription then
    --    return 1, 0, 0, 0
    --end
    --
    --local currentTimestamp = time()
    --local expirationTimestamp = subscription.purchase_timestamp + (subscription.duration_hours * 60 * 60)
    --
    --if currentTimestamp < expirationTimestamp then
    --    local timeLeft = expirationTimestamp - currentTimestamp
    --
    --    local daysLeft = math.floor(timeLeft / (60 * 60 * 24))
    --    local hoursLeft = math.floor((timeLeft % (60 * 60 * 24)) / (60 * 60))
    --    local minutesLeft = math.floor((timeLeft % (60 * 60)) / 60)
    --
    --    return 2, daysLeft, hoursLeft, minutesLeft
    --end
    --
    --return 3, 0, 0, 0
end
