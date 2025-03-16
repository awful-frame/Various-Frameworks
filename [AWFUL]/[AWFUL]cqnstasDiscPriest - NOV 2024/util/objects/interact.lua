local Unlocker, awful, project = ...

local lastInteractTime = 0
local interactCooldown = 1

local objectsToInteract = {
    ["Soulwell"] = true,
    ["Refreshment Table"] = true,
    ["Lavish Refreshment Table"] = true
}

project.util.objects.interact = function()
    local currentTime = awful.time
    if currentTime - lastInteractTime < interactCooldown then
        return
    end
    lastInteractTime = currentTime

    awful.objects.loop(function(object)
        if object.dist > 2 then
            return
        end

        if not objectsToInteract[object.name] then
            return
        end

        if object.name == "Soulwell" then
            if not project.util.spells.items.healthstone:Usable() then
                object:interact()
                project.util.debug.alert.defensive("Grabbing Healthstone")
                return
            end
        end

        if object.name == "Refreshment Table"
                or object.name == "Lavish Refreshment Table" then
            if not project.util.spells.items.conjured_mana_bun:Usable() then
                object:interact()
                project.util.debug.alert.defensive("Grabbing Mage Food")
                return
            end
        end
    end)
end

awful.onTick(function()
    if project.util.spells.items.conjured_mana_bun:Usable() and project.util.spells.items.healthstone:Usable() then
        return
    end

    if project.util.friend.existingClasses then
        if not project.util.friend.existingClasses["Mage"]
                and not project.util.friend.existingClasses["Warlock"] then
            return
        end
    end

    project.util.objects.interact()
end)