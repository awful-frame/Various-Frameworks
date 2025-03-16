local Unlocker, awful, project = ...

local last_interact_time = 0
local interact_cd = 1

local objects_to_interact = {
    [project.util.id.object.SOULWELL] = {
        condition = function()
            return not awful.player.combat
                    and project.util.friend.existing_classes
                    and project.util.friend.existing_classes[project.util.id.class.WARLOCK]
                    and not project.util.spells.items.healthstone:Usable()
        end
    },
    [project.util.id.object.REFRESHMENT_TABLE] = {
        condition = function()
            return not awful.player.combat
                    and project.util.friend.existing_classes
                    and project.util.friend.existing_classes[project.util.id.class.MAGE]
                    and not project.util.spells.items.conjured_mana_bun:Usable()
        end
    },
}

project.util.objects.interact = function()
    if awful.time - last_interact_time < interact_cd then
        return
    end
    last_interact_time = awful.time

    local relevant_objects = {}
    for key, data in pairs(objects_to_interact) do
        if data.condition and data.condition() then
            relevant_objects[key] = data
        end
    end

    awful.objects
         .within(2)
         .filter(function(object)
        if not relevant_objects[object.id] then
            return false
        end

        return true
    end)
         .loop(function(object)
        if object.id == project.util.id.object.SOULWELL then
            if not project.util.spells.items.healthstone:Usable() then
                object:interact()
                project.util.debug.alert.defensive("Grabbing Healthstone")
                return
            end
        end

        if object.id == project.util.id.object.REFRESHMENT_TABLE then
            if not project.util.spells.items.conjured_mana_bun:Usable() then
                object:interact()
                project.util.debug.alert.defensive("Grabbing Mage Food")
                return
            end
        end
    end)
end

awful.onTick(function()
    if awful.player.mounted then
        return
    end

    if awful.player.dead then
        return
    end

    if project.util.spells.items.conjured_mana_bun:Usable()
            and project.util.spells.items.healthstone:Usable() then
        return
    end

    if project.util.friend.existing_classes then
        if not project.util.friend.existing_classes[project.util.id.class.MAGE]
                and not project.util.friend.existing_classes[project.util.id.class.WARLOCK] then
            return
        end
    end

    project.util.objects.interact()
end)