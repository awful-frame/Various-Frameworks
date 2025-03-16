local Unlocker, awful, project = ...

local important_totems = {
    [project.util.id.npc.PSYFIEND] = true,
    [project.util.id.npc.CAPACITOR_TOTEM] = true,
    [project.util.id.npc.OBSERVER] = true,
    [project.util.id.npc.WAR_BANNER] = true,
    [project.util.id.npc.SURGING_TOTEM] = true,
}

project.util.check.enemy.stomp = function()
    local totem_to_return

    awful.totems.stomp(function(totem, uptime)
        if uptime < awful.delay(0.1, 0.3).now then
            return
        end

        if totem.health > (30 * 100) and not important_totems[totem.id] then
            return
        end

        if not totem_to_return or totem.health < totem_to_return.health then
            totem_to_return = totem
        end
    end)

    return totem_to_return
end
