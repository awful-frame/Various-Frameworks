local Unlocker, awful, vamsrotation = ...
local settings = vamsrotation.settings
local draw = awful.Draw
local target, healer, enemyHealer, player, group, friend = awful.target, awful.healer, awful.enemyHealer, awful.player, awful.group, awful.friend
local AwfulFont = awful.createFont(10, "OUTLINE")
local hammerOfJustice = awful.Spell(853)

if player.spec ~= "Retribution" or player.class ~= "Paladin" then
    return
end

--line to healer indicating los/range
awful.Draw(function(draw)
    local px, py, pz = player.position()
    local hx, hy, hz = healer.position()
    if not settings.drawOn then return end
    if not settings.drawHealer then return end
    if not healer.exists then return end
    if healer.los and healer.distanceLiteral <= 40 then
        draw:SetColor(draw.colors.green)
    else
        draw:SetColor(draw.colors.red)
    end
    draw:Line(px, py, pz, hx, hy, hz, 2)
end)

-- HoJ range indicator
awful.Draw(function(draw)
    if not player.combat then return end
    if not settings.drawOn then return end
    if not settings.drawHOJ then return end
    if not (settings.stunMode == "auto" or settings.stunMode == "healer") then return end
    if player and not player.dead then
        local playerX, playerY, playerZ = player.position()
        local enemyHealerX, enemyHealerY, enemyHealerZ = enemyHealer.position()
        local outlineRadius = 11.5

        if enemyHealer.stunDR ~= 1 or enemyHealer.stunDRRemains > 3 or hammerOfJustice.cd > 3 then return end
        if enemyHealer.los and enemyHealer.distanceLiteral <= 11.5 then
            draw:SetColor(draw.colors.green)
        else
            draw:SetColor(draw.colors.white)
            draw:Line(playerX, playerY, playerZ, enemyHealerX, enemyHealerY, enemyHealerZ, 2)
        end

        draw:Text("Move to healer to HoJ", AwfulFont, playerX, playerY, playerZ)
        draw:Circle(enemyHealerX, enemyHealerY, enemyHealerZ, outlineRadius)
    end
end)

-- Earthen Wall
awful.Draw(function(draw)
    if not player.combat then return end
    if not settings.drawOn then return end
    if not settings.drawTotems then return end
    
    draw:SetColor(draw.colors.green)
    awful.units.loop(function(unit)
        if unit.id == 100943 and unit.friend then
            local x, y, z = unit.position()
            draw:Outline(x, y, z, 11.5)
            draw:Text(awful.textureEscape(198838, 30, "0:0"), AwfulFont, x, y, z)
        end
    end)
end)