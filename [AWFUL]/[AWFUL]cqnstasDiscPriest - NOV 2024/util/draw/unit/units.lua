local Unlocker, awful, project = ...

local font = awful.createFont(8, "OUTLINE")

local units_to_draw = {
    -- only enemy drawing
    [61245] = {
        name = "Capacitor Totem",
        radius = 8,
        spellId = 192058,
        draw = 'enemy'
    },
    [60561] = {
        name = "Earthgrab Totem",
        radius = 8,
        spellId = 51485,
        draw = 'enemy'
    },
    [44199] = {
        name = "Ring of Frost",
        radius = 6.5,
        spellId = 113724,
        draw = 'enemy'
    },

    -- only friend drawing
    [100943] = {
        name = "Earthen Wall Totem",
        radius = 10,
        spellId = 198838,
        draw = 'friend'
    },

    -- always drawing
    [53006] = {
        name = "Spirit Link Totem",
        radius = 10,
        spellId = 98008,
        draw = 'always'
    },
    [5913] = {
        name = "Tremor Totem",
        radius = 1,
        spellId = 8143,
        draw = 'always'
    },
    [5925] = {
        name = "Grounding Totem",
        radius = 1,
        spellId = 204336,
        draw = 'always'
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

    awful.units.loop(function(unit)
        local unit_to_draw = units_to_draw[unit.id]

        if not unit_to_draw then
            return
        end

        if unit.dist > project.util.check.player.range() then
            return
        end

        if unit_to_draw.draw == 'friend' and not unit.friend then
            return
        end

        if unit_to_draw.draw == 'enemy' and not unit.enemy then
            return
        end

        local x, y, z = unit.position()
        local txt = awful.textureEscape(unit_to_draw.spellId, 20)

        if unit.friend then
            draw:SetColor(0, 255, 0, 255)
        end

        if unit.enemy then
            draw:SetColor(255, 0, 0, 255)
        end

        draw:Text(txt .. " " .. unit_to_draw.name, font, x, y, z)
        draw:Outline(x, y, z, unit_to_draw.radius)
    end)
end)
