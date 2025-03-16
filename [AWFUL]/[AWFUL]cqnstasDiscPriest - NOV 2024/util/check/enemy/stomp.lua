local Unlocker, awful, project = ...

local important_totems = {
    ["Psyfiend"] = true,
    ["Capacitor Totem"] = true,
    ["Observer"] = true,
    ["War Banner"] = true,
}

local ignore_totems = {
    ["Earthgrab Totem"] = true,
    ["Static Field Totem"] = true,
}

project.util.check.enemy.stomp = function()
    local totem_to_return

    awful.totems.stomp(function(totem, uptime)
        if ignore_totems[totem.name] then
            return
        end

        if uptime < awful.delay(0.2, 0.4).now then
            return
        end

        if not totem_to_return
                or totem.health < totem_to_return.health then
            totem_to_return = totem
        end
    end)

    return totem_to_return
end