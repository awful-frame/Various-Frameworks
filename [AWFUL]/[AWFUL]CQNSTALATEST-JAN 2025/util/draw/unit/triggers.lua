local Unlocker, awful, project = ...

local font = awful.createFont(8, "OUTLINE")

local triggers_to_draw = {
    [187651] = {
        name = "Freezing Trap",
        radius = 3,
        spellId = 187650,
        draw = 'always',
        condition = function()
            return project.util.check.scenario.type() == "pvp"
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.HUNTER])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.HUNTER]))
        end
    },
    [187699] = {
        name = "Tar Trap",
        radius = 3,
        spellId = 187698,
        draw = 'enemy',
        condition = function()
            return awful.arena
                    and awful.player.combat
                    and project.util.enemy.existing_classes
                    and project.util.enemy.existing_classes[project.util.id.class.HUNTER]
        end
    },
    [132950] = {
        name = "Flare",
        radius = 10,
        spellId = 1543,
        draw = 'always',
        condition = function()
            return project.util.check.scenario.type() == "pvp"
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.HUNTER])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.HUNTER]))
        end
    },
    [109248] = {
        name = "Binding Shot",
        radius = 5,
        spellId = 109248,
        draw = 'always',
        condition = function()
            return project.util.check.scenario.type() == "pvp"
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.HUNTER])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.HUNTER]))
        end
    },
    [207684] = {
        name = "Sigil of Misery",
        radius = 8,
        spellId = 207684,
        draw = 'always',
        condition = function()
            return awful.arena
                    and awful.player.combat
                    and ((project.util.friend.existing_classes and project.util.friend.existing_classes[project.util.id.class.DEMON_HUNTER])
                    or (project.util.enemy.existing_classes and project.util.enemy.existing_classes[project.util.id.class.DEMON_HUNTER]))
        end
    },
    [353082] = {
        name = "Ring of Fire",
        radius = 8.5,
        spellId = 353082,
        draw = 'enemy',
        condition = function()
            return awful.arena
                    and awful.player.combat
                    and project.util.enemy.existing_classes
                    and project.util.enemy.existing_classes[project.util.id.class.MAGE]
        end
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

    if project.util.check.scenario.type() == "pve" then
        return
    end

    local relevant_triggers = {}
    for key, data in pairs(triggers_to_draw) do
        if data.condition() then
            relevant_triggers[key] = data
        end
    end

    if next(relevant_triggers) == nil then
        return
    end

    awful.triggers
         .within(project.util.check.player.range())
         .filter(function(trigger)
        local trigger_to_draw = relevant_triggers[trigger.id]

        if not trigger_to_draw then
            return false
        end

        if trigger_to_draw.draw == 'friend' and not trigger.creator.friend then
            return false
        end

        if trigger_to_draw.draw == 'enemy' and not trigger.creator.enemy then
            return false
        end

        return true
    end)
         .loop(function(trigger)
        local trigger_to_draw = relevant_triggers[trigger.id]

        local x, y, z = trigger.position()
        local txt = awful.textureEscape(trigger_to_draw.spellId, 20)

        draw:SetColor(0, 0, 255, 255)

        if trigger.creator and trigger.creator.friend then
            draw:SetColor(0, 255, 0, 255)
        end

        if trigger.creator and trigger.creator.enemy then
            draw:SetColor(255, 0, 0, 255)
        end

        draw:Text(txt .. " " .. trigger_to_draw.name, font, x, y, z)
        draw:Circle(x, y, z, trigger_to_draw.radius)
    end)
end)
