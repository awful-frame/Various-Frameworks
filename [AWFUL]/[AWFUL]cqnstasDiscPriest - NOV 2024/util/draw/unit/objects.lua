local Unlocker, awful, project = ...

local font = awful.createFont(8, "OUTLINE")

local objectsToDraw = {
    ["Soulwell"] = 6262,
    ["Refreshment Table"] = 167152,
    ["Lavish Refreshment Table"] = 167152,
    ["Demonic Gateway"] = 111771
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

    awful.objects.loop(function(object)
        if not objectsToDraw[object.name] then
            return
        end

        if object.dist > project.util.check.player.range() then
            return
        end

        local x, y, z = object.position()
        local txt = awful.textureEscape(objectsToDraw[object.name], 20)

        if object.name == "Soulwell" then
            if not project.util.spells.items.healthstone then
                return
            end

            if project.util.spells.items.healthstone:Usable() then
                return
            end
        end

        if object.name == "Refreshment Table" then
            if not project.util.spells.items.conjured_mana_bun then
                return
            end

            if project.util.spells.items.conjured_mana_bun:Usable() then
                return
            end
        end

        draw:SetColor(0, 0, 255, 255)

        if object.friend then
            draw:SetColor(0, 255, 0, 255)
        end

        if object.enemy then
            draw:SetColor(255, 0, 0, 255)
        end

        draw:Text(txt .. " " .. object.name, font, x, y, z)
        draw:SetColor(0, 0, 255, 255)
        draw:Outline(x, y, z, 2)
    end)
end)
