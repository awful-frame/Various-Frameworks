local Unlocker, awful, project = ...

local font = awful.createFont(8, "OUTLINE")

local objects_to_draw = {
    [project.util.id.object.SOULWELL] = {
        id = 6262,
        condition = function()
            return not awful.player.combat
                    and project.util.friend.existing_classes
                    and project.util.friend.existing_classes[project.util.id.class.WARLOCK]
                    and not project.util.spells.items.healthstone:Usable()
        end
    },
    [project.util.id.object.REFRESHMENT_TABLE] = {
        id = 167152,
        condition = function()
            return not awful.player.combat
                    and project.util.friend.existing_classes
                    and project.util.friend.existing_classes[project.util.id.class.MAGE]
                    and not project.util.spells.items.conjured_mana_bun:Usable()
        end
    },
    [project.util.id.object.DEMONIC_GATEWAY] = {
        id = 111771,
        condition = function()
            return awful.arena
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.WARLOCK])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.WARLOCK]))
        end
    }
}

awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_objects then
        return
    end

    if awful.instanceType2 == project.util.id.instance.RAID then
        return
    end

    local relevant_objects = {}
    for key, data in pairs(objects_to_draw) do
        if data.condition and data.condition() then
            relevant_objects[key] = data
        end
    end

    if next(relevant_objects) == nil then
        return
    end

    awful.objects
         .within(project.util.check.player.range())
         .filter(function(object)
        if not relevant_objects[object.id] then
            return false
        end

        return true
    end)
         .loop(function(object)
        local x, y, z = object.position()
        local txt = awful.textureEscape(relevant_objects[object.id].id, 20)

        draw:SetColor(0, 0, 255, 255)

        if object.friend then
            draw:SetColor(0, 255, 0, 255)
        end

        if object.enemy then
            draw:SetColor(255, 0, 0, 255)
        end

        draw:Text(txt .. " " .. object.name, font, x, y, z)
        draw:SetColor(0, 0, 255, 255)
        draw:Circle(x, y, z, 2)
    end)
end)
