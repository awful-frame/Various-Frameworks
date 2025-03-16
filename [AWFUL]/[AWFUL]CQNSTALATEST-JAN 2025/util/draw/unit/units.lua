local Unlocker, awful, project = ...

local font = awful.createFont(8, "OUTLINE")

local units_to_draw = {
    -- Only enemy drawing
    [60561] = {
        name = "Earthgrab Totem",
        radius = 8,
        spellId = 51485,
        draw = 'enemy',
        condition = function()
            return project.util.check.scenario.type() == "pvp"
                    and project.util.enemy.existing_classes
                    and project.util.enemy.existing_classes[project.util.id.class.SHAMAN]
        end,
    },

    -- Always drawing
    [61245] = {
        name = "Capacitor Totem",
        radius = 8,
        spellId = 192058,
        draw = 'always',
        condition = function()
            return project.util.check.scenario.type() == "pvp"
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.SHAMAN])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.SHAMAN]))
        end,
    },
    [100943] = {
        name = "Earthen Wall Totem",
        radius = 10,
        spellId = 198838,
        draw = 'always',
        condition = function()
            if awful.player.healer then
                return false
            end

            return (project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.SHAMAN])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.SHAMAN])
        end,
    },
    [53006] = {
        name = "Spirit Link Totem",
        radius = 10,
        spellId = 98008,
        draw = 'always',
        condition = function()
            if awful.player.healer then
                return false
            end

            return (project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.SHAMAN])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.SHAMAN])
        end,
    },
    [5913] = {
        name = "Tremor Totem",
        radius = 1,
        spellId = 8143,
        draw = 'always',
        condition = function()
            return project.util.check.scenario.type() == "pvp"
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.SHAMAN])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.SHAMAN]))
        end,
    },
    [5925] = {
        name = "Grounding Totem",
        radius = 1,
        spellId = 204336,
        draw = 'always',
        condition = function()
            return project.util.check.scenario.type() == "pvp"
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.SHAMAN])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.SHAMAN]))
        end,
    },
}

awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_units then
        return
    end

    if awful.instanceType2 == project.util.id.instance.RAID then
        return
    end

    local relevant_units = {}
    for key, data in pairs(units_to_draw) do
        if data.condition() then
            relevant_units[key] = data
        end
    end

    if next(relevant_units) == nil then
        return
    end

    awful.units
         .within(project.util.check.player.range())
         .filter(function(unit)
        local unit_to_draw = relevant_units[unit.id]
        if not unit_to_draw or not unit_to_draw.condition(unit) then
            return false
        end

        if unit_to_draw.draw == 'friend' and not unit.friend then
            return false
        end

        if unit_to_draw.draw == 'enemy' and not unit.enemy then
            return false
        end

        return true
    end)
         .loop(function(unit)
        local unit_to_draw = relevant_units[unit.id]
        if not unit_to_draw then
            return
        end

        local x, y, z = unit.position()
        local txt = awful.textureEscape(unit_to_draw.spellId, 20)

        draw:SetColor(0, 0, 255, 255)

        if unit.friend then
            draw:SetColor(0, 255, 0, 255)
        end

        if unit.enemy then
            draw:SetColor(255, 0, 0, 255)
        end

        draw:Text(txt .. " " .. unit_to_draw.name, font, x, y, z)
        draw:Circle(x, y, z, unit_to_draw.radius)
    end)
end)
