local Unlocker, awful, project = ...

local font = awful.createFont(8, "OUTLINE")

local triggers_to_draw = {
    [187651] = {
        name = "Freezing Trap",
        radius = 3,
        spellId = 187650,
        draw = 'always'
    },

    [187699] = {
        name = "Tar Trap",
        radius = 3,
        spellId = 187698,
        draw = 'enemy'
    },

    [132950] = {
        name = "Flare",
        radius = 10,
        spellId = 1543,
        draw = 'always'
    },

    [109248] = {
        name = "Binding Shot",
        radius = 5,
        spellId = 109248,
        draw = 'always'
    },

    [207684] = {
        name = "Sigil of Misery",
        radius = 8,
        spellId = 207684,
        draw = 'always'
    },

    [353082] = {
        name = "Ring of Fire",
        radius = 8.5,
        spellId = 353082,
        draw = 'enemy'
    },
}

awful.Draw(function(draw)
    if not awful.enabled then
        return
    end

    if not project.settings.draw_enabled then
        return
    end

    if not project.settings.draw_triggers then
        return
    end

    awful.triggers.loop(function(trigger)
        local trigger_to_draw = triggers_to_draw[trigger.id]

        if not trigger_to_draw then
            return
        end

        if trigger.dist > project.util.check.player.range() then
            return
        end

        if trigger_to_draw.draw == 'friend' and not trigger.creator.friend then
            return
        end

        if trigger_to_draw.draw == 'enemy' and not trigger.creator.enemy then
            return
        end

        local x, y, z = trigger.position()
        local txt = awful.textureEscape(trigger_to_draw.spellId, 20)

        draw:SetColor(0, 0, 255, 255)

        if trigger.creator.friend then
            draw:SetColor(0, 255, 0, 255)
        end

        if trigger.creator.enemy then
            draw:SetColor(255, 0, 0, 255)
        end

        draw:Text(txt .. " " .. trigger_to_draw.name, font, x, y, z)
        draw:Outline(x, y, z, trigger_to_draw.radius)
    end)
end)
