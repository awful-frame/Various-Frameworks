local Unlocker, awful, sajrsham = ...
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3, party1, party2 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3, awful.party1, awful.party2



sajrsham.shaman = {}
sajrsham.shaman.restoration = awful.Actor:New({ spec = 3, class = "shaman" })

local restoration = sajrsham.shaman.restoration

if player.spec ~= "Restoration" then return end
if player.class2 ~= "SHAMAN" then return end

if player.class == "Shaman" and player.spec == "Restoration" then
    awful.print("[|cff7ebff1 Welcome to |r]") 
    awful.print("[|cff4550FC Sajs Resto Shaman loaded and enabled |r]")
    awful.print("[|cff7ebff1 Enjoy |r]")
end

local cmd = awful.Command("saj", true)
sajrsham.cmd = cmd

--awful.enabled = true

local min, max, bin, cos, sin = min, max, awful.bin, math.cos, math.sin

local NewSpell = awful.NewSpell

local wasCasting = {}
function WasCastingCheck()
    local time = awful.time
    if player.casting then
        wasCasting[player.castingid] = time
    end
    for spell, when in pairs(wasCasting) do
        if time - when > 0.100 + awful.buffer then
            wasCasting[spell] = nil
        end
    end
end


--------------- --------------- --------------- --------------- UI--------------- --------------- --------------- ---------------

local settings = sajrsham.settings

local yellow = {245, 235, 55, 1}
local white = {255, 255, 255, 1}
local dark = {21, 21, 21, 0.45}
local orange = {255, 140, 0, 255}
local red = {255, 0, 0, 1}
local reddark = {210, 58, 58, 1}
local brown = {139, 71, 38, 255}
local green = {0, 255, 0, 255}
local black = {0, 0, 0, 0}
local yellowcool = {255, 255, 153, 1}
local redcool = {139, 90, 43, 0.45}
local greencool = {152, 251, 152, 200}
local browncool = {255, 165, 79, 200}
local newgreencool = {0, 255, 0, 0.1}
local shamancolor = {0, 112, 221, 1}
local shamancool = {76, 182, 175, 1}

local gui, settings = awful.UI:New("sajUI", {
    title = "      SAJ     ",
    show = true, -- show not on load by default
    colors = {
        --color of our ui title in the top left
        title = shamancolor,
        --primary is the primary text color
        primary = shamancool,
        --accent controls colors of elements and some element text in the UI. it should contrast nicely with the background.
        accent = shamancolor,
        background = dark,
    }
   })
   
   local sajUI = gui:Tab("Mode")
   
   sajUI:Text({
       text = awful.textureEscape(61295, 25, "0:0") .. awful.colors.blue .. " Sajs Restoration",
       header = true,
       size = 12,
       paddingBottom = 7,
   })
   
   --damit abstand ist--
   sajUI:Text({
       text = "  "
   })
   
   sajUI:Dropdown({
       var = "mode",
       tooltip = "Choose if you play PVE or PVP, very important",
       options = {
           { label = awful.textureEscape(400924, 22, "0:01") .. " PVP", value = "pvpmode", tooltip = "Choose if you play PVP" },
           { label = awful.textureEscape(1064, 22, "0:01") .. "  PVE", value = "pvemode", tooltip = "Choose if you play PVE", default = true },
       },
       placeholder = "PRESS HERE TO SELECT MODE",
       header = "Mode:",
   })
   
   sajUI:Checkbox({
       text = awful.textureEscape(3684828, 22, "0:13") .. "  Drawings",
       var = "drawings", -- checked bool = settings.drawings   
       default = true,
       tooltip = "Drawings like Trap, Lines to ur Mates and stuff" 
    })

    -- sajUI:Checkbox({
    --     text = awful.textureEscape(3684828, 22, "0:13") .. "  testings",
    --     var = "testings", -- checked bool = settings.drawings   
    --     default = true,
    --     tooltip = "Drawings like Trap, Lines to ur Mates and stuff" 
    --  })
 

    sajUI:Checkbox({
        text = awful.textureEscape(440001, 22, "0:13") .. "  Drawing Lines to DDs",
        var = "drawinglines", -- checked bool = settings.drawinglines   
        default = true,
        tooltip = "Drawings Lines to ur Damage Dealers in Arena" 
    })
   
   sajUI:Checkbox({
       text = awful.textureEscape(132284, 22, "0:13") .. "  Drawings for Classes",
       var = "classdrawings", -- checked bool =  
       default = true,
       tooltip = "Enemy classes will be shown next to the characters" 
   })

    sajUI:Checkbox({
        text = awful.textureEscape(1320372, 22, "0:13") .. "  Icons above Bursting Enemies",
        var = "burstdrawings", -- checked bool =  
        default = false,
        tooltip = "Drawing Icons above Players who are bursting (BETA)" 
    })
    
   sajUI:Checkbox({
       text = awful.textureEscape(895885, 22, "0:13") .. "  Alerts enabled",
       var = "alertsmode", -- checked bool = settings.alertsmode
       default = true,
       tooltip = "Alerts in the middle of ur screen, recommended when playing with my Macros" 
   })
   
   sajUI:Checkbox({
       text = awful.textureEscape(37529, 22, "0:13") .. "  Start Rotation only in Combat",
       var = "nofightstarter", -- checked bool = settings.nofightstarter
       default = false,
       tooltip = "This is made for questing/leveling to prevent attacking people in town, it will only start the rotation when u are in fight. So you have to press a button to get in combat. You don't need this option in Dungeons/Raids, it's auto checking there if mobs are in fight." 
   })
   
   sajUI:Dropdown({
       var = "hexmode",
       tooltip = "only important in pvp",
       options = {
           { label = awful.textureEscape(51514, 22, "0:01") .. "  Show Hex Icon Healer", value = "hexiconhealer", tooltip = "Will show the hex icon above the enemy Healer, when he is ready for full hex", default = true },
           { label = awful.textureEscape(51514, 22, "0:01") .. "  Show Hex Icon on all", value = "hexiconall", tooltip = "Will show the hex icon above everyone who is able to get a full hex" },
           { label = awful.textureEscape(51514, 22, "0:01") .. "  No Hex Icons", value = "nohexicons", tooltip = "Will disable Icons above players who are ready for full hex" },
       },
       placeholder = "PRESS HERE TO SELECT VISUAL HEX ICON",
       header = "Hex Icon:",
   })
   
   
   -- sajUI:Checkbox({
   --     text = awful.textureEscape(5852173, 22, "0:13") .. "  Legit Mode (soon)",
   --     var = "legitmode", -- checked bool = settings.alertsmode
   --     default = false,
   --     tooltip = "<IN PROGRESS> Legitmode for PVP to make it not look obvious we are botting. It will include a lot of logic and randomness <IN PROGRESS>" 
   -- })
   
   local sajUI = gui:Tab("General")
   
   sajUI:Text({
    text = awful.textureEscape(61295, 25, "0:0") .. awful.colors.blue .. " Sajs Restoration",
    header = true,
    size = 12,
    paddingBottom = 7,
    })
   
   --damit abstand ist--
   sajUI:Text({
       text = "  "
   })
   
   sajUI:Checkbox({
    text = awful.textureEscape(114052, 22, "0:13") .. "  Auto Cooldowns   ",
    var = "autocds", -- checked bool = if not settings.autocds then return end
    default = true,
    tooltip = "Using Cooldowns like Healing Tide, Ascendance and Ancestral Swiftness automatically (PVE/PVP)" 
    })

   
--    sajUI:Checkbox({
--        text = awful.textureEscape(254416, 22, "0:13") .. "  Totem Stomp ",
--        var = "totemstomp", -- checked bool = settings.totemstomps    
--        default = true,
--        tooltip = "Stomping important Totems" 
--    })
   
sajUI:Checkbox({
    text = awful.textureEscape(77130, 22, "0:13") .. "  Auto Dispel   ",
    var = "dispelye", -- checked bool = if not settings.dispelye then return end
    default = true,
    tooltip = "Auto Usage, will always randomize the delay" 
})

   
   sajUI:Checkbox({
       text = awful.textureEscape(8143, 22, "0:13") .. "  Auto Totems ",
       var = "autototem", -- checked bool = settings.autototem
       default = true,
       tooltip = "Using ur Totems automatically (for example Healing Stream, Tremor and stuff)" 
   })

   
sajUI:Checkbox({
    text = awful.textureEscape(57994, 22, "0:13") .. "  Auto Kick   ",
    var = "autokick", -- checked bool = if not settings.autokick then return end
    default = true,
    tooltip = "Auto Kick (PVE/PVP)" 
})
   
sajUI:Checkbox({
    text = awful.textureEscape(79206, 22, "0:13") .. "  Auto Spiritwalker",
    var = "autospiritwalker", -- checked bool = settings.autospiritwalker
    default = true,
    tooltip = "Using Auto Spiritwalker(PVE/PVP)" 
})

sajUI:Checkbox({
    text = awful.textureEscape(51505, 22, "0:13") .. "  Auto Damage    ",
    var = "autodamage", -- checked bool = if not settings.autodamage then return end
    default = true,
    tooltip = "Auto Damage with flameshock/lavaburst proccs (PVE/PVP)" 
})

sajUI:Checkbox({
    text = awful.textureEscape(16191, 22, "0:13") .. "  Auto Mana Totem",
    var = "automanatotem", -- checked bool = settings.automanatotem
    default = true,
    tooltip = "Using Mana Totem automatically (PVE/PVP), some people like it manual so here is the option" 
})

local sajUI = gui:Tab("PVP")
   
sajUI:Text({
 text = awful.textureEscape(61295, 25, "0:0") .. awful.colors.blue .. " Sajs Restoration",
 header = true,
 size = 12,
 paddingBottom = 7,
 })

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(198838, 22, "0:13") .. "  Auto Earthen (PVP) ",
    var = "autoearthenPVP", -- checked bool = if not settings.autoearthenPVP then return end
    default = true,
    tooltip = "Using Auto Earthen automatically, some people like to do it manual so here is the option" 
})

sajUI:Checkbox({
    text = awful.textureEscape(98008, 22, "0:13") .. "  Auto Link (PVP)  ",
    var = "autolink", -- checked bool = if not settings.autocds then return end
    default = true,
    tooltip = "Using Spirit Link automatically, some people like to do it manual so here is the option" 
})


sajUI:Checkbox({
    text = awful.textureEscape(51514, 22, "0:13") .. "  Auto Hex (Arena)",
    var = "autohex", -- checked bool =  
    default = true,
    tooltip = "Auto Hex in PVP Arena" 
})

sajUI:Checkbox({
    text = awful.textureEscape(8143, 22, "0:13") .. "  Auto Pre-Tremor",
    var = "autopretremor", -- checked bool = settings.autopretremor
    default = true,
    tooltip = "<beta> We will pre-tremor goes." 
})

sajUI:Checkbox({
    text = awful.textureEscape(192058, 22, "0:13") .. "  Auto Stun Totem",
    var = "autostuntotem", -- checked bool = settings.autostuntotem
    default = true,
    tooltip = "Using Cap Stun automatically (PVP), some people like it manual so here is the option" 
})

sajUI:Checkbox({
    text = awful.textureEscape(51490, 22, "0:13") .. "  Auto Thunderstorm ",
    var = "autothunderstorm", -- checked bool = settings.autothunderstorm
    default = true,
    tooltip = "Using Thunderstorm vs melees" 
})

sajUI:Checkbox({
    text = awful.textureEscape(356736, 22, "0:13") .. "  Auto Unleash Shield ",
    var = "autounleashshield", -- checked bool = settings.autounleashshield
    default = true,
    tooltip = "Using Unleash Shield automatically" 
})

sajUI:Checkbox({
    text = awful.textureEscape(51485, 22, "0:13") .. "  Auto Root ",
    var = "autoroot", -- checked bool = settings.autoroot   
    default = true,
    tooltip = "Using Auto Root Totem (PVP)" 
})
 
sajUI:Checkbox({
    text = awful.textureEscape(877482, 22, "0:13") .. "  My Mage is a monkey ",
    var = "magemonkey", -- checked bool = settings.magemonkey
    default = false,
    tooltip = "Enable this only on low rating or when you play with a noob mage. The rotation won't trust him on alter time." 
})

sajUI:Checkbox({
    text = awful.textureEscape(366651, 22, "0:13") .. "  Mana Efficient Heal  ",
    var = "manaefficient", -- checked bool = if not settings.manaefficient then return end
    default = false,
    tooltip = "<BETA> Will use more Healing Waves instead of Healing Surge, it's risky and not recommended in Solo Shuffle/3S! More if u play hard caster cleaves or 2s" 
})

sajUI:Checkbox({
    text = awful.textureEscape(88492, 22, "0:13") .. "  Auto Focus ",
    var = "autofocus", -- checked bool =  
    default = true,
    tooltip = "Auto Focus Target in PVP" 
})

sajUI:Checkbox({
    text = awful.textureEscape(402482, 22, "0:13") .. "  (BGs) Auto Pickup Flags",
    var = "autopickupflags", -- checked bool =   if not settings.autopickupflags then return end 
    default = true,
    tooltip = "Will Auto Pickup Flags in BGs" 
})


local sajUI = gui:Tab("PVE")
   
sajUI:Text({
 text = awful.textureEscape(61295, 25, "0:0") .. awful.colors.blue .. " Sajs Restoration",
 header = true,
 size = 12,
 paddingBottom = 7,
 })

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(192077, 22, "0:13") .. "  Auto Windrush Totem ",
    var = "autowindrush", -- checked bool = settings.autowindrus
    default = true,
    tooltip = "Using Windrush Totem automatically in PVE" 
})

sajUI:Checkbox({
    text = awful.textureEscape(98008, 22, "0:13") .. "  Auto Link (PVE)  ",
    var = "autolinkPVE", -- checked bool = if not settings.autocds then return end
    default = true,
    tooltip = "Using Spirit Link automatically, some people like to do it manual so here is the option. Recommended to use it manual in raids" 
})

sajUI:Checkbox({
    text = awful.textureEscape(198838, 22, "0:13") .. "  Auto Earthen (PVE) ",
    var = "autoearthenPVE", -- checked bool = if not settings.autocds then return end
    default = true,
    tooltip = "Using Auto Earthen automatically, some people like to do it manual so here is the option" 
})
   
sajUI:Checkbox({
    text = awful.textureEscape(73920, 22, "0:13") .. "  Auto Healing Rain ",
    var = "autohealingrain", -- checked bool = if not settings.autohealingrain then return end
    default = true,
    tooltip = "Using Auto Healing Rain automatically, some people like to do it manual so here is the option" 
})

sajUI:Checkbox({
    text = awful.textureEscape(196927, 22, "0:13") .. "  Dawnbreaker Instance READ",
    var = "dawnbringershit", -- checked bool =  if settings.dawnbringershit then return end --we are on the ship--
    default = false,
    tooltip = "Enable this when u are on dawnbringer or necrotic wave instance and you are on the ship right now, disable it when u are not on the ship anymore. There are currently problems with the ships on AOE spells, Link/HealingRain/AOE Totems not working here." 
})

   
   local sajUI = gui:Tab("Defensives")
   
   sajUI:Text({
    text = awful.textureEscape(61295, 25, "0:0") .. awful.colors.blue .. " Sajs Restoration",
    header = true,
    size = 12,
    paddingBottom = 7,
    })
   
   --damit abstand ist--
   sajUI:Text({
       text = "  "
   })
   
   sajUI:Checkbox({
       text = awful.textureEscape(108271, 22, "0:13") .. "  Auto Defensives",
       var = "autodefensives", -- checked bool =  
       default = true,
       tooltip = "Auto Using Astral Shift and stuff" 
   })
   
   sajUI:Checkbox({
       text = awful.textureEscape(974, 22, "0:13") .. "  Auto Earth Shield",
       var = "autoearthshield", -- checked bool = settings.autospiritwalker
       default = true,
       tooltip = "Using Auto Earth Shield" 
   })
   
   --damit abstand ist--
   sajUI:Text({
       text = "  "
   })
   
   --done--
   sajUI:Slider({
    text = awful.textureEscape(538745, 22, "0:3") .. "Healthstone",
    var = "healthstoneHP",
    min = 0,
    max = 100,
    step = 1,
    default = 30,
    valueType = "%",
    tooltip = "The routine will use healthstone at"
   })
   --done--
   sajUI:Slider({
       text = awful.textureEscape(202296, 22, "0:3") .. "HP Trinket",
       var = "bmtrinket",
       min = 0,
       max = 100,
       step = 1,
       default = 35,
       valueType = "%",
       tooltip = "The routine will use hp trinket at"
   })
   
   
   -- sajUI:Checkbox({
   -- text = awful.textureEscape(208683, 22, "0:13") .. "  Auto Trinket ",
   -- var = "autotrinketsmart", -- checked bool = settings.autotrinketsmart
   -- default = false,
   -- tooltip = "<For Beginners or SS Bot Users> Using Trinket auto in specific situations, not recomennded" 
   -- })
   
   local sajUI = gui:Tab("Macros")
   
   sajUI:Text({
    text = awful.textureEscape(61295, 25, "0:0") .. awful.colors.blue .. " Sajs Restoration",
    header = true,
    size = 12,
    paddingBottom = 7,
    })
   
   --damit abstand ist--
   sajUI:Text({
       text = "  "
   })
   
   sajUI:Text({
       text = "|cfffff394/username cast [@<unit>] <spell>",
       size = 10,
       paddingBottom = 5,
   })
   
   sajUI:Text({
       text = "|cfffff394/username toggle",
       size = 10,
       paddingBottom = 5,
   })
   
   sajUI:Text({
       text = "|cfffff394/sajui",
       size = 10,
       paddingBottom = 5,
   })
   
   sajUI:Text({
       text = "|cfff2b0ffTo open the menu",
       size = 8,
   })

   sajUI:Text({
    text = "|cfffff394/saj lasso",
    size = 10,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfff2b0ffwill lasso the target but checking for stunDRs, if target is immune it won't lasso",
    size = 8,
})

sajUI:Text({
    text = "|cfffff394/saj drink",
    size = 10,
    paddingBottom = 12,
})
sajUI:Text({
    text = "|cfff2b0ffDrink Macro, works currently with Items [Lava Cola][Quicksilver Sipper][Conjured Mana Bun]. It will be automatically disabled when you are at 100% Mana or in combat. It will stop the rotation completely!",
    size = 8,
 })

--------------- --------------- --------------- --------------- VISUALS --------------- --------------- --------------- ---------------


local icon = nil

---SHAMAN---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local ax, ay, az = enemy.position()
        if enemy.class2 == "SHAMAN" then 
            icon = awful.textureEscape(626006, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", ax, ay, az+4)
        end
    end)
end)

---ROGUE---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local bx, by, bz = enemy.position()
        if enemy.class2 == "ROGUE" then 
            icon = awful.textureEscape(626005, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", bx, by, bz+4)
        end
    end)
end)

---WARRIOR--
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local cx, cy, cz = enemy.position()
        if enemy.class2 == "WARRIOR" then 
            icon = awful.textureEscape(626008, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", cx, cy, cz+4)
        end
    end)
end)

---WARLOCK---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local dx, dy, dz = enemy.position()
        if enemy.class2 == "WARLOCK" then 
            icon = awful.textureEscape(626007, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", dx, dy, dz+4)
        end
    end)
end)

---DRUID---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local ex, ey, ez = enemy.position()
        if enemy.class2 == "DRUID" then 
            icon = awful.textureEscape(625999, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", ex, ey, ez+4)
        end
    end)
end)

---PRIEST
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local gx, gy, gz = enemy.position()
        if enemy.class2 == "PRIEST" then 
            icon = awful.textureEscape(626004, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", gx, gy, gz+4)
        end
    end)
end)

---PALADIN---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local hx, hy, hz = enemy.position()
        if enemy.class2 == "PALADIN" then 
            icon = awful.textureEscape(626003, 20, "0:2")
            draw:Text(icon, "GameFontHighlight", hx, hy, hz+4)
        end
    end)
end)

---MAGE---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local jx, jy, jz = enemy.position()
        if enemy.class2 == "MAGE" then 
            icon = awful.textureEscape(626001, 20, "0:2")  
            draw:Text(icon, "GameFontHighlight", jx, jy, jz+4)
        end
    end)
end)

---DK---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local kx, ky, kz = enemy.position()
        if enemy.class2 == "DEATHKNIGHT" then 
            icon = awful.textureEscape(187893, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", kx, ky, kz+4)
        end
    end)
end)

---HUNTER---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local mx, my, mz = enemy.position()
        if enemy.class2 == "HUNTER" then 
            icon = awful.textureEscape(626000, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", mx, my, mz+4)
        end
    end)
end)

---DH---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local nx, ny, nz = enemy.position()
        if enemy.class2 == "DEMONHUNTER" then 
            icon = awful.textureEscape(1260827, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", nx, ny, nz+4)
        end
    end)
end)

---MONK---
awful.Draw(function(draw)
    if not settings.classdrawings then return end
    awful.enemies.loop(function(enemy)
        if awful.instanceType2 == "arena" and not enemy.isPlayer then return end 
        local ox, oy, oz = enemy.position()
        if enemy.class2 == "MONK" then 
            icon = awful.textureEscape(626002, 20, "0:2") 
            draw:Text(icon, "GameFontHighlight", ox, oy, oz+4)
        end
    end)
end)

local enemyburstingicon = awful.textureEscape(1320372, 40, "0:16")

awful.Draw(function(draw)
    if not settings.burstdrawings then return end
    awful.enemies.loop(function(enemy)
        if enemy.player and not enemy.healer then 
            if enemy.cds then 
            --if player.cds then
                if enemy.distanceTo(player) < 40 then 
                local px, py, pz = enemy.position()
                --local px, py, pz = player.position()
                draw:Text(enemyburstingicon, "GameFontHighlight", px, py, pz+6)
                end 
            end 
        end 
    end)
end)

local hexicon = awful.textureEscape(51514, 45, "0:16")

--possible hexes on enemies--
awful.Draw(function(draw)
    if settings.hexmode == "nohexicons" then return end 
    if settings.hexmode == "hexiconall" then 
        if select(2,GetInstanceInfo()) == "pvp" then return end --in bg--
        if not settings.drawings then return end
        awful.enemies.loop(function(enemy) 
            if enemy.idr == 1 then 
                if enemy.exists and enemy.isPlayer then
                local px, py, pz = enemy.position()
                draw:Text(hexicon, "GameFontHighlight", px, py, pz+7)
                end
            end 
        end)
    end 
end)

---possible hexes only on enemyhealer---

--possible hexes on enemyHealer--
awful.Draw(function(draw)
    if settings.hexmode == "nohexicons" then return end 
    if settings.hexmode == "hexiconhealer" then 
        if select(2,GetInstanceInfo()) == "pvp" then return end --in bg--
        if not settings.drawings then return end
        if enemyHealer.idr == 1 then 
            if enemyHealer.exists then
            local px, py, pz = enemyHealer.position()
            draw:Text(hexicon, "GameFontHighlight", px, py, pz+7)
            end
        end 
    end 
end)


---- REST ----

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.triggers.loop(function(trigger)
        if trigger.id ~= 187651 then return end --freezing trap--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then return end
        local x,y,z = trigger.position()
        draw:SetColor(255, 1, 1, 169)
        draw:Outline(x,y,z,2.5)
    end)
end)

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.triggers.loop(function(trigger)
        if trigger.id ~= 132950 then return end --flair--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then return end
        local x,y,z = trigger.position()
        draw:SetColor(255, 1, 1, 169)
        draw:Outline(x,y,z,10)
    end)
end)

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.triggers.loop(function(trigger)
        if trigger.id ~= 389813 then return end --DH FEAR--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then return end
        local x,y,z = trigger.position()
        draw:SetColor(255, 1, 1, 169)
        draw:Outline(x,y,z,8)
    end)
end)

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.triggers.loop(function(trigger)
        if trigger.id ~= 198839 then return end --friendly earthen--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then
        local x,y,z = trigger.position()
        draw:SetColor(100, 255, 100, 200)
        draw:Outline(x,y,z,10.5)
        end
    end)
end)

awful.Draw(function(draw)
    if not settings.drawings then return end
    awful.group.loop(function(unit)
        if select(2,GetInstanceInfo()) == "arena" then
        if unit.distance > 50 then return end
        local x, y, z = unit.position()
        if unit.class == "Druid" then draw:SetColor(255, 140, 0, 255) end
        if unit.class == "Rogue" then draw:SetColor(255, 215, 0, 255) end
        if unit.class == "Hunter" then draw:SetColor(0, 100, 0, 255) end
        if unit.class == "Warrior" then draw:SetColor(139, 71, 38, 255) end
        if unit.class == "Paladin" then draw:SetColor(255, 20, 147, 255) end
        if unit.class == "Monk" then draw:SetColor(0, 255, 127, 255) end
        if unit.class == "Priest" then draw:SetColor(140, 140, 140, 255) end
        if unit.class == "Mage" then draw:SetColor(99, 184, 255, 255) end
        if unit.class == "Shaman" then draw:SetColor(0, 0, 255, 255) end
        if unit.class == "Warlock" then draw:SetColor(106, 90, 205, 255) end
        if unit.class == "Death Knight" then draw:SetColor(255, 0, 0, 255) end
        if unit.class == "Demon Hunter" then draw:SetColor(76, 0, 153, 255) end
        if unit.class == "Evoker" then draw:SetColor(8, 87, 75, 255) end
        draw:Outline(x, y, z, 2)
        end
    end)
end)

--drawings to heal--
awful.Draw(function(draw)
    if not settings.drawings then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if healer.dead then return end
    if healer.exists then
      local hx, hy, hz = healer.position()
      if (not healer.los) or healer.distanceLiteral > 40 then
          draw:SetColor(draw.colors.red)
          draw:Line(px, py, pz, hx, hy, hz, 3)
      end
     end
    end
  end)

  awful.Draw(function(draw)
    if not settings.drawings then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if healer.dead then return end
    if healer.exists then
      local hx, hy, hz = healer.position()
      if (not healer.los) or healer.distanceLiteral < 40 then
          draw:SetColor(draw.colors.green)
          draw:Line(px, py, pz, hx, hy, hz, 3)
      end
     end
    end
  end)

--- Lines ---- hiar

awful.Draw(function(draw)
    if not settings.drawinglines then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if party1.dead then return end
    if party1.exists then
      local hx, hy, hz = party1.position()
      if not party1.los or party1.distanceLiteral > 40 then
          draw:SetColor(draw.colors.red)
          draw:Line(px, py, pz, hx, hy, hz, 2)
      end
     end
    end
  end)

  awful.Draw(function(draw)
    if not settings.drawinglines then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if party1.dead then return end
    if party1.exists then
      local hx, hy, hz = party1.position()
      if party1.los or party1.distanceLiteral < 40 then
          draw:SetColor(draw.colors.green)
          draw:Line(px, py, pz, hx, hy, hz, 2)
      end
    end
   end
  end)

  awful.Draw(function(draw)
    if not settings.drawinglines then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if party2.dead then return end
    if party2.exists then
      local hx, hy, hz = party2.position()
      if not party2.los or party2.distanceLiteral > 40 then
          draw:SetColor(draw.colors.red)
          draw:Line(px, py, pz, hx, hy, hz, 2)
      end
    end
   end
  end)

  awful.Draw(function(draw)
    if not settings.drawinglines then return end
    if select(2,GetInstanceInfo()) == "arena" then
    local px, py, pz = player.position()
    if party2.dead then return end
    if party2.exists then
      local hx, hy, hz = party2.position()
      if party2.los or party2.distanceLiteral < 40 then
          draw:SetColor(draw.colors.green)
          draw:Line(px, py, pz, hx, hy, hz, 2)
      end
    end
   end
  end)

------ EARTHEN ------
local earthenicon = awful.textureEscape(198838, 35, "0:16")

awful.Draw(function(draw)
    --if not settings.totemdrawings then return end
    awful.triggers.loop(function(trigger) 
        if trigger.id ~= 198839 then return end --friendly earthen--
        if trigger.distance > 60 then return end 
        if trigger.creator.friend then
            local px, py, pz = trigger.position()
            draw:Text(earthenicon, "GameFontHighlight", px, py, pz+3)
        end 
    end)
end)


------ HEALING RAIN TOTEM ------
local surgetotemicon = awful.textureEscape(444995, 35, "0:16")

-- awful.Draw(function(draw)
--     --if not settings.totemdrawings then return end
--     awful.triggers.loop(function(trigger) 
--         if trigger.id ~=  then return end --friendly earthen--
--         if trigger.distance > 60 then return end 
--         if trigger.creator.friend then
--             local px, py, pz = trigger.position()
--             draw:Text(surgetotemicon, "GameFontHighlight", px, py, pz+3)
--         end 
--     end)
-- end)


--------------- --------------- --------------- --------------- TABLES --------------- --------------- --------------- ---------------

  local noPanic = { 
    642, --bubble
    186265, --turtle--
    47585, --dispersion--
    125174, --karma--
    45438, --iceblock--
    232707, --ray
    342246, --alter time
    47788, --guardian spirit
    204018, --spellwarding
    116849, --cocoon
    409293, --burrow
    240133, --iceblock#2--
    11327, --vannish--
 }

 local someDefensives = { 
    108271, --astral shift
    642, --bubble
    1022, --BoP
    186265, --turtle--
    53480, --hunter sac--
    47585, --dispersion--
    104773, --warlock wall unsolving res--
    31224, --cloak--
    5277, --evasion--
    125174, --karma--
    48707, --Anti Magic shell--
    311975, --anti magic shell#2--
    48792, --icebound fortitude--
    292152, --iebound forti#2--
    45438, --iceblock--
    240133, --iceblock#2--
    118038, --die by the sword--
    196718, --darkness--
    209426, --darkness#2--
    363916, --obsidian scales--
    61336, --survival instincts--
    409293, --burrow
    116849, --cocoon
    114893, --bulwark
 }

 local immuneBuffs = { 
    212295, --netherward
    --48707, --ams
    47585, --dispersion
    23920, --reflect
    125174, --karma
    409293, --burrow
    642, --bubble
    204018, --spellwarding
    45438, --iceblock--
    186265, --turtle--
    33786, --cyclone
    353319, --monk revival 
}

local BigDef = { 
    33206, --Pain Suppression
    81782, --Dome
    102342, --Ironbark
    47788, --Guardian Spirit
    232707, --Ray of Hope
    116849, --cocoon
    1022, --BOP
    6940, --SAC
    325174, --link totem buff
    363534, --rewind prevoker--
    357170, --time dilation--
    196718, --darkness--
    209426, --darkness#2--
    108271, --astral shift
    184364, --warrior enraged regeneration
}

--------------- --------------- --------------- --------------- SPELLS --------------- --------------- --------------- ---------------

-- Dmg spells --
awful.Populate({
    flameshock = awful.Spell(188389, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    lightbolt = awful.Spell(188196, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    chainlight = awful.Spell(188443, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    lavaburst = awful.Spell(51505, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    earthshock = awful.Spell(8042, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    frostshock = awful.Spell(196840, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }), --
    primowave = awful.Spell(428332, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    lasso = awful.Spell(305483, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreCasting = true }),
    fireele = awful.Spell(198067),
    fireeleAOE = awful.Spell(117588, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    earthele = awful.Spell(198103),
    eartheleSTUN = awful.Spell(118345, { damage = "physical", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    astralshift = awful.Spell(108271), 
    downpour = awful.Spell(462603),
}, restoration, getfenv(1))

-- totems ---
awful.Populate({
    totemtremor = awful.Spell(8143, { ignoreChanneling = false, ignoreFacing = true }), --
    totemhealingstream = awful.Spell(5394, { ignoreChanneling = false, ignoreFacing = true }), --
    --totemgrounding = awful.Spell(204336, { ignoreChanneling = false, ignoreFacing = true }), --
    totemskyfury = awful.Spell(204330, { ignoreChanneling = false, ignoreFacing = true }),
    totemcounterstrike = awful.Spell(204331, { ignoreChanneling = false, ignoreFacing = true }),
    totemhealingtide = awful.Spell(108280, { ignoreChanneling = false, ignoreFacing = true }), --
}, restoration, getfenv(1))

local totemstatic = NewSpell(355580, { diameter = 9, offsetMin = 0, offsetMax = 2, })
local totemstun = NewSpell(192058, { diameter = 7, offsetMin = 0, offsetMax = 2, })
local totemroot = NewSpell(51485, { 
    effect = "magic", 
    targeted = false,
    circleSteps = 24,
    distChecks = 12,
    radius = 9, 
    minDist = 6, 
    maxDist = 8,
    maxHit = 999, -- should hit NO ONE in bcc
    ignoreFriends = true, -- ignore friends in filter func for performance reasons
  })
--local totemslow = NewSpell(355580, { diameter = 10, offsetMin = 0, offsetMax = 2, })
local totemgrounding = NewSpell(204336, { ignoreChanneling = false, ignoreFacing = true, ignoreCasting = true })
local burrow = NewSpell(409293, { ignoreCasting = true, ignoreChanneling = true })
local windshear = NewSpell(57994, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false, ignoreCasting = true })
local windshearPVE = NewSpell(57994, { ignoreCasting = true })
local totempoisoncleanse = NewSpell(383013, { ignoreChanneling = false, ignoreFacing = true })
local totemlink = NewSpell(98008, {  diameter = 11, offsetMin = 0, offsetMax = 2, ignoreChanneling = false, ignoreFacing = true })
--local totemearthen = NewSpell(198838, { diameter = 12, offsetMin = 0, offsetMax = 2, ignoreChanneling = false, ignoreFacing = true })

local totemearthen = NewSpell(198838, { 
    targeted = false,
    circleSteps = 24,
    distChecks = 12,
    radius = 12, 
    minDist = 1, 
    maxDist = 5.5,
    minHit = 1,
    maxHit = 999, -- should hit NO ONE in bcc
    ignoreEnemies = true, -- ignore friends in filter func for performance reasons
  })

local totemmana = NewSpell(16191, { ignoreChanneling = false, ignoreCasting = false, ignoreFacing = true })
local totemStoneBulwark = NewSpell(108270, { ignoreChanneling = false, ignoreFacing = true })
local skyfuryBuff = NewSpell(462854, { ignoreChanneling = false, ignoreFacing = true })
local totemicrecall = NewSpell(108285, { ignoreChanneling = false })
local thunderstorm = NewSpell(51490, { effect = "magic", ignoreControl = true  })
local ascendance = NewSpell(114052, { ignoreChanneling = false, ignoreFacing = true, ignoreCasting = true })
local totemwindrush = NewSpell(192077, { diameter = 10, offsetMin = 0, offsetMax = 1 })
local healingrain = NewSpell(73920, { diameter = 15, offsetMin = 1, offsetMax = 3 })
local healingrainTotemic = NewSpell(444995, { diameter = 10, offsetMin = 1, offsetMax = 1 })

-- def/heal --
awful.Populate({
    earthshield = awful.Spell(974, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    flametongue = awful.Spell(318038, { ignoreChanneling = false, ignoreFacing = true }),
    lightningshield = awful.Spell(192106, { ignoreChanneling = false, ignoreFacing = true }),
    healingsurge = awful.Spell(8004, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }), --
    dispelcurse = awful.Spell(51886, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true, ignoreCasting = true }), --
    ancestralguidance = awful.Spell(108281, { heal = true, ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }), 
    ancestralSwiftness = awful.Spell(443454, { ignoreGCD = true }),
    spiritwalker = awful.Spell(79206),
}, restoration, getfenv(1))

-- misc --
awful.Populate({
   -- windshear = awful.Spell(57994, { damage = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = false }),
    hex = awful.Spell(51514, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    unleashshield = awful.Spell(356736, { effect = "magic", ignoreLoS = false, ignoreChanneling = false }),
    purge = awful.Spell(370, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    greaterpurge = awful.Spell(378773, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    stormkeeper = awful.Spell(191634, { effect = "magic", ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    trollracial = awful.Spell(26297, { effect = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
    orcracial = awful.Spell(33697, { effect = "magic", ignoreLoS = true, ignoreChanneling = false, ignoreFacing = true }),
}, restoration, getfenv(1))

awful.Populate({
    earthlivingweapon = awful.Spell(382021, { ignoreChanneling = false, ignoreFacing = true }),
    watershield = awful.Spell(52127, { ignoreChanneling = false, ignoreFacing = true }),
    dispel = awful.Spell(77130, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true, ignoreCasting = true }), 
    riptide = awful.Spell(61295, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    unleashlife = awful.Spell(73685, { heal = true, ignoreLoS = false, ignoreChanneling = false, ignoreFacing = true }),
    natureswiftSwiftness = awful.Spell(378081, { heal = true, ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    healingwave = awful.Spell(77472, { heal = true, ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
    chainheal = awful.Spell(1064, { heal = true, ignoreLoS = false, ignoreChanneling = true, ignoreFacing = true }),
}, restoration, getfenv(1))

--------------- --------------- --------------- --------------- CMDs --------------- --------------- --------------- ---------------
local bursti = false
local drink = false 

cmd:New(function(msg)
    if msg == "burst" then
        burst = not burst
        and awful.alert({ message = awful.colors.red.. "This is not needed on R-SHAM", texture = 135727, duration = awful.tickRate * 2, duration = 9 })
    end
end)

--------------- --------------- --------------- --------------- BURST --------------- --------------- --------------- ---------------
cmd:New(function(msg)
    if msg == "bursti" then
        bursti = not bursti
    end
end)

cmd:New(function(msg)
    if msg == "drink" then
        drink = not drink
    end
end)

orcracial:Callback("burst", function(spell)
    if player.cds or bursti then 
        if target.friendly then return end
        if player.combat then
            if target.distance < 41 then 
                if orcracial.known then
                return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Racial", texture = spell.id, duration = 1 })
                end
            end
        end
    end
end)

trollracial:Callback("burst", function(spell)
    if player.cds or bursti then 
        if target.friendly then return end
        if player.combat then
            if target.distance < 41 then 
                if trollracial.known then
                return spell:Cast(player) and awful.alert({ message = awful.colors.yellow.. "Racial", texture = spell.id, duration = 1 })
                end
            end
        end
    end
end)

local healthStone = awful.Item(5512)
healthStone:Update(function(item)
    if not item:Usable(player) then return end
    if player.hp <= settings.healthstoneHP then
      return item:Use() and awful.alert({ message = awful.colors.orange.. "Healthstone", texture = 5512, duration = 1 })
    end
end)

local healthstone = awful.NewItem(5512)

local checked_for_hs = 0
-- function healthstone:grab()
--     if awful.time - checked_for_hs < 1 + bin(not awful.prep) * 6 then return end
--     if self.charges == 3 then return end
--     if player.casting or player.channeling then return end
--     if awful.GetNumFreeBagSlots() ~= nil then 
--       if awful.GetNumFreeBagSlots() == 0 then
--         checked_for_hs = awful.time
--         return
--       end
--     end
--     local soulWell = {
--         [303148] = true, -- soulwell
--     }
--     awful.objects.loop(function(obj)
--         if not soulWell[obj.id] then return end
--         if obj.creator.enemy then return end
--         if obj.dist > 5 then
--             awful.alert("Healthstone available")
--         end
--         if obj.dist > 5 then return end
--         obj:interact()
--     end)
--     checked_for_hs = awful.time
-- end


--------------- --------------- --------------- --------------- DEFENSIVE & BUFFS --------------- --------------- --------------- --------------

skyfuryBuff:Callback(function(spell)
    if player.combat then return end 
    if player.used(462854, 5) then return end --we have used it recently--
    if awful.instanceType2 == "arena" and not awful.prep then return end 
    awful.fullGroup.loop(function(group)
        if not group.los then return end
        if group.distance > 40 then return end 
        if not group.buff(462854) then
            if spell:Cast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

earthlivingweapon:Callback(function(spell)
    if player.mainhandEnchantRemains == 0 or player.mainhandEnchantRemains > 0 and player.mainhandEnchantRemains < 120 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

earthshield:Callback("onme", function(spell)
    if settings.mode == "pvemode" then return end 
    if not settings.autoearthshield then return end 
    if player.buff(383648) then return end --earthshield--
    if not player.buff(383648) then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

earthshield:Callback("onmeOutOfCombat", function(spell)
    if settings.mode == "pvemode" then return end 
    if player.combat then return end 
    if not settings.autoearthshield then return end 
    if not player.buff(383648) or player.buffStacks(383648) < 7 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

earthshield:Callback("onTank", function(spell)
    if awful.instanceType2 == "raid" then return end
    if not settings.autoearthshield then return end 
    --if select(2,GetInstanceInfo()) ~= "arena" then return end  --we only use it in arena--
    if player.mana < 10000 then return end 
    awful.group.loop(function(friend)
        if friend.role == "tank" then 
            if not friend.buff(974) or friend.buffStacks(974) < 3 then --earthshield--
                if spell:Cast(friend) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "Tank", texture = spell.id, duration = 1 }) end 
                end 
            end
        end 
    end)
end)

earthshield:Callback("onTankRaid", function(spell)
    if awful.instanceType2 ~= "raid" then return end
    if not settings.autoearthshield then return end 
    --if select(2,GetInstanceInfo()) ~= "arena" then return end  --we only use it in arena--
    if player.mana < 10000 then return end 
    local escount = 0
    if tank.buff(974, player) or player.used(974) and player.castTarget.isUnit(tank) then escount = escount + 1 end 
    if escount >= 1 then return true end    
    if tank.exists then 
        if spell:Cast(tank) then
            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "Tank", texture = spell.id, duration = 1 }) end 
        end
    end 
end)

earthshield:Callback("onTankOutOfCombat", function(spell)
    if not settings.autoearthshield then return end 
    if awful.instanceType2 == "raid" then return end
    --if select(2,GetInstanceInfo()) ~= "arena" then return end  --we only use it in arena--
    if player.mana < 10000 then return end 
    if player.combat then return end 
    awful.group.loop(function(friend)
        if friend.combat then return end 
        if friend.role == "tank" then 
            if not friend.buff(974) or friend.buffStacks(974) < 7 then --earthshield--
                if spell:Cast(friend) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "Tank Refresh", texture = spell.id, duration = 1 }) end 
                end 
            end
        end 
    end)
end)

-- earthshield:Callback("PVPonDPS", function(spell)
--     if not settings.autoearthshield then return end 
--     local escount = 0
--     awful.group.loop(function(group)
--    -- if group.buff(974, player) then return end 
--     if group.buff(974, player) then escount = escount + 1 end 
--     if escount >= 1 then return true end     
--         if not group.buff(974, player) then
--             if spell:Cast(group) then
--                 if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
--             end 
--         end 
--     end) 
-- end)

---we eartshield a dps outside of arena 3s, because in 3s we have another logic for swaps--
earthshield:Callback("PVPonDPS", function(spell)
    if party1.exists and party2.exists and awful.instanceType2 == "arena" then return end --we have another logic for that--
    if not settings.autoearthshield then return end 
    local escount = 0
    awful.group.loop(function(group)
    if group.buff(974, player) or player.used(974) and player.castTarget.isUnit(group) then escount = escount + 1 end 
    if escount >= 1 then return true end     
        if not group.buff(974, player) then
            if spell:Cast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
            end 
        end 
    end) 
end)

earthshield:Callback("ReactiveWarding", function(spell)
    if not player.hasTalent(462454) then return end 
    if awful.instanceType2 ~= "arena" then return end
    if awful.prep then return end 
    if not settings.autoearthshield then return end 
    awful.fullGroup.loop(function(group)  
        if group.buff(974, player) and group.buffStacks(974) < 3 and group.hp < 90 then
            if spell:Cast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "Warding", texture = spell.id, duration = 1 }) end 
            end 
        end 
    end) 
end)

earthshield:Callback("ReactiveWardingPlayer", function(spell)
    --if awful.instanceType2 ~= "arena" then return end
    if not player.hasTalent(462454) then return end 
    if awful.prep then return end 
    if not settings.autoearthshield then return end 
    if player.buff(383648) and player.buffStacks(383648) < 4 and player.hp < 85 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "Warding Player", texture = spell.id, duration = 1 }) end 
        end 
    end  
end)

--so this is different to swaps, because we need to have 1 earthshield by default on someone--
--ToDo: prio liste machen für klassen--
earthshield:Callback("PVPonDPS3sprep", function(spell)
    if not awful.prep then return end
    if not settings.autoearthshield then return end 
    local escount = 0
    awful.group.loop(function(group)
    if group.buff(974, player) or player.used(974) and player.castTarget.isUnit(group) then escount = escount + 1 end 
    if escount >= 1 then return true end     
        if not group.buff(974, player) then
            if spell:Cast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
            end 
        end 
    end) 
end)

--this is our swap and only in 3s--
earthshield:Callback("swap", function(spell)
    if not settings.autoearthshield then return end 
    if awful.instanceType2 ~= "arena" then return end
    if not party1.exists and not party2.exists then return end  --only in 3s we need that logic--
    awful.group.loop(function(group) 
        local total, melee, ranged, cooldowns = group.v2attackers()
        if total >= 2 then
            awful.enemies.loop(function(enemy) 
                if enemy.target.isUnit(group) then
                    if not group.buff(974, player) then
                        if spell:Cast(group) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "swap", texture = spell.id, duration = 1 }) end 
                        end 
                    end 
                end 
            end)
        end 
    end) 
end)

watershield:Callback(function(spell)
    if player.hp < 70 then return end --we have better stuff to do--
    if player.buff(52127) then return end --WS--
    if not player.buff(52127) then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

--------------- --------------- --------------- --------------- PVE --------------- --------------- --------------- --------------

totemStoneBulwark:Callback("PVE", function(spell)
    if not settings.autodefensives then return end 
    if not player.combat then return end 
    if player.buffFrom(noPanic) then return end 
    if player.mana < 5000 then return end -- costs of that totem---
    if player.hp >= 60 then return end 
    if player.hp < 60 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

totemhealingstream:Callback(function(spell)

    if wasCasting[spell.id] then return end
    if player.used(5394, 18) then return end 

    awful.fullGroup.loop(function(friend)
        if player.mana < 10000 then return end -- costs of that totem---
        if friend.hp < 95 and friend.hp > 50 then
            if friend.distanceTo(player) < 46 then 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end
    end)
end)

healingsurge:Callback("PVEcasting", function(spell)
    if wasCasting[spell.id] then return end
    --local count = #awful.fullGroup.filter(function(unit) return unit.hp < 90 end)  --we need to chainheal---
    --if count >= 2 then return end 
    awful.fullGroup.loop(function(group)
        if group.dist > healingsurge.range then return end
        if not group.los then return end --not in sight-- 
        if not spell:Castable(group) then return end
        local lowest = awful.fullGroup.lowest
        if lowest.hp < 85 or awful.instanceType2 == "raid" and lowest.hp < 45 then
        return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 0.5 })
        end
    end)
end)

healingsurge:Callback("PVEcastingTank", function(spell)
    if wasCasting[spell.id] then return end
    if tank.dist > healingsurge.range then return end
    if not tank.los then return end --not in sight-- 
    if not spell:Castable(tank) then return end
    if tank.hp < 70 or awful.instanceType2 == "raid" and tank.hp < 45 then
    return spell:Cast(tank) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 0.5 })
    end
end)

healingwave:Callback("PVEcasting", function(spell)
    if wasCasting[spell.id] then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 90 end)  --we need to chainheal---
    if count >= 2 then return end 
    awful.fullGroup.loop(function(group)
        if group.dist > healingwave.range then return end
        if not group.los then return end --not in sight-- 
        if not spell:Castable(group) then return end
        local lowest = awful.fullGroup.lowest
        if lowest.hp < 95 then
        return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 0.5 })
        end
    end)
end)

healingwave:Callback("HasteDebuffMPlus", function(spell)
    if wasCasting[spell.id] then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 70 end)  --we need to chainheal---
    if count >= 2 then return end 
    if player.debuff(461910) and player.debuffStacks(461910) > 7 then 
        awful.fullGroup.loop(function(group)
            if group.dist > healingwave.range then return end
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 95 and lowest.hp > 50 then
            return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "t", texture = spell.id, duration = 0.5 })
            end
        end)
    end 
end)

chainheal:Callback("PVEcasting", function(spell)
    if wasCasting[spell.id] then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 90 end)  --we need to chainheal---
    if count >= 2 then
        awful.fullGroup.loop(function(group)
            if group.dist > chainheal.range then return end
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 90 and lowest.hp > 50 then
            return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 0.5 })
            end
        end)
    end 
end)

chainheal:Callback("PVEtidebringer", function(spell)
    if wasCasting[spell.id] then return end
    if not player.buff(236502) then return end --tidebringer
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 90 end)  --we need to chainheal---
    if count >= 2 then
        awful.fullGroup.loop(function(group)
            if group.dist > chainheal.range then return end
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 90 or awful.instanceType2 == "raid" and lowest.hp < 80 then
            return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "tide/hb", texture = spell.id, duration = 0.5 })
            end
        end)
    end 
end)

chainheal:Callback("PVEtotemicbuff", function(spell)
    if wasCasting[spell.id] then return end
    if not player.buff(453406) then return end --totemic buff
    --local count = #awful.fullGroup.filter(function(unit) return unit.hp < 90 end)  --we need to chainheal---
    --if count >= 2 then
        awful.fullGroup.loop(function(group)
            if not group.combat then return end 
            if group.dist > chainheal.range then return end
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
            local lowest = awful.fullGroup.lowest
            if lowest.hp < 90 or awful.instanceType2 == "raid" and lowest.hp < 80 then
            return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "tide/hb", texture = spell.id, duration = 0.5 })
            end
        end)
   --end 
end)


riptide:Callback("PVE", function(spell)
    if wasCasting[spell.id] then return end
    if player.used(61295, 3) and player.buff(61295) then return end --we already used it--
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 40 end)  --we need to chainheal---
    if count >= 3 then return end 
    awful.fullGroup.loop(function(group)
        if group.dist > riptide.range then return end
        if not group.los then return end --not in sight-- 
        if not spell:Castable(group) then return end
        local lowest = awful.fullGroup.lowest
        if lowest.hp < 90 or awful.instanceType2 == "raid" and lowest.hp < 70 then
        return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 0.5 })
        end
    end)
end)

astralshift:Callback("PVE", function(spell)
    if not settings.autodefensives then return end 
    if not player.combat then return end 
    if player.buff(114893) then return end --bulwark totem--
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.hp < 60 then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

healingwave:Callback("PVEcasting", function(spell)
    if wasCasting[spell.id] then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 90 end)  --we need to chainheal---
    if count >= 2 then return end 
    awful.fullGroup.loop(function(group)
        if group.dist > healingwave.range then return end
        if not group.los then return end --not in sight-- 
        if not spell:Castable(group) then return end
        local lowest = awful.fullGroup.lowest
        if lowest.hp < 95 then
        return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 0.5 })
        end
    end)
end)

totemlink:Callback("PVE", function(spell)
    if settings.dawnbringershit then return end --we are on the ship--
    if not settings.autolinkPVE then return end
    awful.fullGroup.loop(function(group)
        if not group.combat then return end 
        local count = #awful.fullGroup.filter(function(unit) return unit.isPlayer end)
        if count >= 2 and group.hp < 30 then 
            if spell:AoECast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end) 
end)


---kicklist from https://keyandheal.com/dungeons/SpellBank/
local kickListPVE = { 
    426283,
    275826,
    324776,
    272571,
    322450,
    431309,
    328667,
    338353,
    451871,
    452162,
    430097,
    324914,
    445207,
    324293,
    434793,
    429109,
    448248,
    443430,
    323057,
    340544,
    326046,
    431333,
    433841,
    256957,
    450756,
    449734,
    429110,
    426283,
    275826,
    335143,
    257063,
    324776,
    429545,
    272571,
    452099,
    322450,
    334748,
    451261,
    322274,
    431309,
    320336,
    333602,
    328667,
    338353,
    327396,
    442536,
    322938,
    434802,
    449455,
    451871,
    452162,
    430097,
    320171,
    320462,
    431303,
    324914,
    321828,
    445207,
    436322,
    324293,
    434793,
    429109,
    448248,
    76711,
    428086,
    447966,
    76369,
    443430,
    323057,
    322767,
    340544,
    326046,
    454440,
    429422,
    431333,
    443433,
    432520,
    433841,
    434122,
    446086,
    272581,
    256957,
    451113,
    443427,
    434786,
 }

local KickDelayCasts = awful.delay(1.5, 2)

windshearPVE:Callback("PVE", function(spell)  
    if settings.mode == "pvpmode" then return end 
    if not settings.autokick then return end 
    if player.cooldown(57994) > 0.1 then return end 
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end 
        if not enemy.los then return end 
        if not tContains(kickListPVE, enemy.castID) then return end
        if enemy.casting then
            if enemy.castRemains < 1.5 then 
                if spell:Cast(enemy) then -- 
                    --awful.alert({ message = awful.colors.red.. "Kick", texture = spell.id, duration = 2 })
                    awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                    return true -- we return true to stop the loop.
                end
            end
        end
    end)
end)

local stuffToCleansePVE = {
    --461487,
    326092,
    340283,
    448248,
    275836,
    340288,
    443401,
    433841,
    438618,
    461630,
    444985,
    439198, --raid
    458505, -- raid
}

totempoisoncleanse:Callback("PVE", function(spell)
    if not settings.autototem then return end 
    if not player.hasTalent(383013) then return end 
    awful.fullGroup.loop(function(group)
    if not group.debuffFrom(stuffToCleansePVE) then return end
        if group.distanceTo(player) < 30 then --cleanse 30 y range -- 
        return spell:Cast(player) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) 
        end
    end)
end)

local natureCureDelayPVE = awful.delay(0.6, 1)

local curseDebuffsPVE = {
    [450095] = { uptime = natureCureDelayPVE.now, min = 2 },
    [257168] = { uptime = natureCureDelayPVE.now, min = 2 },
    [322968] = { uptime = natureCureDelayPVE.now, min = 2 },
    [431309] = { uptime = natureCureDelayPVE.now, min = 2 },
    [451224] = { uptime = natureCureDelayPVE.now, min = 2 },
    [426308] = { uptime = natureCureDelayPVE.now, min = 2 },
    [440622] = { uptime = natureCureDelayPVE.now, min = 2 },
    [451606] = { uptime = natureCureDelayPVE.now, min = 2 },
    [426735] = { uptime = natureCureDelayPVE.now, min = 2 },
    [437956] = { uptime = natureCureDelayPVE.now, min = 2 },
    [443437] = { uptime = natureCureDelayPVE.now, min = 2 },
    [322557] = { uptime = natureCureDelayPVE.now, min = 2 },
    [424889] = { uptime = natureCureDelayPVE.now, min = 2 },
    [459923] = { uptime = natureCureDelayPVE.now, min = 2 },
    [448060] = { uptime = natureCureDelayPVE.now, min = 2 },
    325224,
    431494,
    324859,
    426735,
    429545,
    328664,
    464876,
    450095,
    257168,
    322968,
    431309,
    451224,
    425974,
    449455,
    440238,
    275014,
    424889,
    448561,
    443437,
    322557,
    432448,
}


dispel:Callback("PVE", function(spell)
    if not settings.dispelye then return end
    awful.fullGroup.loop(function(friend)
        --if not player.hasTalent(51886) then return end 
        if not spell:Castable(friend) then return end
        if not friend.debuffFrom(curseDebuffsPVE) then return end
        if spell:Cast(friend) then
            awful.alert({ message = awful.colors.red.. "Dispel", texture = spell.id, duration = 1 }) return true
        end
    end)
end)

spiritwalker:Callback("PVE", function(spell)
    if not settings.autospiritwalker then return end 
    if not player.combat then return end 
    if player.buff(443454) then return end 
    if player.moving then 
        awful.fullGroup.loop(function(friend)
            if friend.hp > 90 then return end 
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end
        end)
    end
end)

totemhealingtide:Callback("pveTwolow", function(spell)
    if not settings.autocds then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 65 and unit.distanceTo(player) < 46 and not unit.dead end)  
    if count >= 2 then
        awful.fullGroup.loop(function(group)
            if group.distanceTo(player) < 46 then
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "multiple low", texture = spell.id, duration = 1 }) end 
                end 
            end 
        end)
    end 
end)

ascendance:Callback("pveOnelow", function(spell)
    if not settings.autocds then return end
    if player.buff(443454) then return end --we have insta heal--
    if player.buff(114052) then return end --already ascendance--
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 45 and unit.distanceTo(player) < 46 and not unit.dead end)  
    if count >= 1 then
        awful.fullGroup.loop(function(group)
            if group.distanceTo(player) < 46 then
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "low", texture = spell.id, duration = 1 }) end 
                end 
            end 
        end)
    end 
end)

totemmana:Callback("PVE", function(spell)
    if not settings.automanatotem then return end 
    awful.fullGroup.loop(function(group)
        if player.buff("Drink") then return end --player is drinking--
        if not player.combat then return end --we can drink--
        if group.hp < 60 then return end 
        if player.manaPct > 85 then return end -- do nothing over 85% mana
        --if group.buffFrom(someDefensives) then return end --they have active def and probably getting drained right now--
        return spell:Cast(player) and awful.alert({ message = awful.colors.blue.. "Mana Totem", texture = spell.id, duration = 2 })
    end)
end)

totemicrecall:Callback("PVE", function(spell)
    if player.casting or player.channeling then return end
    if player.used(5394, 8) or player.used(444995, 8) then 
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

ancestralguidance:Callback("PVE", function(spell)
    if not settings.autocds then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 75 and unit.distanceTo(player) < 46 end)  
    if count >= 3 then
        awful.fullGroup.loop(function(group)
            if group.distanceTo(player) < 46 then
            if not group.los then return end --not in sight-- 
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "low", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

earthshield:Callback("PVEonme", function(spell)
    if not settings.autoearthshield then return end 
    if player.buff(383648) then return end --earthshield--
    if not player.buff(383648) then
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

totemwindrush:Callback("PVE", function(spell)
    if settings.dawnbringershit then return end --we are on the ship--
    if not settings.autowindrush then return end 
    if player.mounted then return end 
    if player.combat then return end 
    if player.moving then
        awful.fullGroup.loop(function(friend)
            if not friend.los then return end 
            if friend.mounted then return end 
            local abc, abcCount = friends.around(player, 10, function(obj) return not obj.combat and obj.friendly end)
            if abc and abcCount >= 2 then
                if spell:AoECast(friend) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end)
    end 
end)

primowave:Callback("pve", function(spell)
    --if not settings.autocds then return end
    if wasCasting[spell.id] then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 50 end)  --we need to chainheal---
    if count >= 3 then return end 
    awful.fullGroup.loop(function(group)
        if player.used(61295, 3) and group.buff(61295) then return end --we already used it--
        if group.dist > primowave.range then return end
        if not group.los then return end --not in sight-- 
        if not spell:Castable(group) then return end
        local lowest = awful.fullGroup.lowest
        if lowest.hp < 80 then
        return spell:Cast(lowest) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 0.5 })
        end
    end)
end)

ancestralSwiftness:Callback("pve", function(spell)
    --if not settings.autocds then return end
    if player.used(428332, 5) then 
        if spell:Cast() then
            --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

natureswiftSwiftness:Callback("pve", function(spell)
    --if not settings.autocds then return end
    if tank.hp < 30 then 
        if spell:Cast() then
            --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

healingwave:Callback("PVE-Swiftness", function(spell)
    if not player.buff(443454) or not player.buff(378081) then return end --instant--
    local lowest = awful.fullGroup.lowest
   -- if lowest.dist > healingwave.range then return end
    if lowest.hp < 80 and lowest.los then
        if player.buff(443454) or player.buff(378081) then --ancestral swift, swiftness--
            if spell:Cast(lowest) then 
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test instant", texture = spell.id, duration = 1 }) end 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end 
end)

totemearthen:Callback("pve", function(spell)
    if settings.dawnbringershit then return end --we are on the ship--
    if not settings.autoearthenPVE then return end
    --if wasCasting[spell.id] then return end
    if player.manaPct < 5 then return end -- do nothing under 7% mana
    if player.used(198838, 10) then return end  --earthen used already--
    if not tank.combat then return end 
   -- awful.fullGroup.loop(function(group)
        --if not group.los then return end 
        --local count = #awful.fullGroup.filter(function(unit) return unit.hp < 95 end)
       -- if count >= 2 then 
        if tank.hp < 97 and tank.hp > 40 and tank.los and not tank.moving then 
            --awful.enemies.loop(function(enemy)
                --if enemy.target.isUnit(group) then 
                    if spell:AoECast(tank) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        --if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                    end 
                --end 
            --end) 
        end
   -- end)
end)

unleashlife:Callback("PVE", function(spell)
    if wasCasting[spell.id] then return end
    awful.fullGroup.loop(function(group)
    if group.dist > unleashlife.range then return end
    if not group.los then return end --not in sight--
    --if group.buff(61295) and group.hp > 70 and group.hp < 90 then return end --has riptide on him and is fine--
         if group.hp < 80 and group.hp > 30 then
        --awful.enemies.loop(function(enemy)
            if spell:Cast(group) then
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
       end
    end)
end)

healingrain:Callback("PVE", function(spell)
    if not settings.autohealingrain then return end
    if settings.dawnbringershit then return end --we are on the ship--
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 99 end)  --we need to chainheal---
    if count >= 2 then
        awful.fullGroup.loop(function(group)
            if group.dist > 40 then return end
            if not group.combat then return end 
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
            if group.hp < 99 and group.hp > 85 then
                if not tank.moving then 
                    if spell:AoECast(tank) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        --if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                    end 
                end 
            end
        end)
    end 
end)

healingrainTotemic:Callback("PVE", function(spell)
    if not settings.autohealingrain then return end
    if settings.dawnbringershit then return end --we are on the ship--
    if tank.exists then return end 
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 80 end)  
    if count >= 3 then
        awful.fullGroup.loop(function(group)
            if not group.combat then return end 
            if group.dist > 40 then return end
            if not group.los then return end --not in sight-- 
            if group.hp < 95 and group.hp > 30 then
                if spell:AoECast(group, {castByID = true}) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end 
        end)
    end 
end)

healingrainTotemic:Callback("PVEtank", function(spell)
    if not settings.autohealingrain then return end
    if settings.dawnbringershit then return end --we are on the ship--
    if tank.dist > 40 then return end
    if not tank.combat then return end 
    if tank.moving then return end 
    if not tank.los then return end --not in sight-- 
    if tank.hp < 99 and tank.hp > 10 then
        if spell:AoECast(tank, {castByID = true}) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "tank", texture = spell.id, duration = 1 }) end 
        end 
    end 
end)

healingrainTotemic:Callback("PVEonPlayer", function(spell)
    if not settings.autohealingrain then return end
    if settings.dawnbringershit then return end --we are on the ship--
    if party1.exists and party2.exists then return end  --we are in a group--
    if tank.exists then return end --we are in a group--
    if player.moving then return end 
    if not player.combat then return end 
    if player.hp < 95 and player.hp > 20 then
        if spell:AoECast(player, {castByID = true}) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end 
end)

flameshock:Callback("PVE", function(spell)
    if not settings.autodamage then return end 
    if player.manaPct < 25 then return end 
    --if select(2,GetInstanceInfo()) == "pvp" then return end --in bg or arena--
    awful.fullGroup.loop(function(group)
        if group.hp < 92 then return end 
        local fscount = 0

        awful.enemies.loop(function(pet)

        if pet.dist > flameshock.range then return end
        if pet.debuff(flameshock.id, player) then return end
        if not pet.combat then return end  
        if pet.bcc then return end 
        if pet.dead then return end 

        if pet.debuff(flameshock.id, player) then fscount = fscount + 1 end 
        if fscount >= 3 then return true end 

            if pet.los then
                if spell:Cast(pet) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end)
    end)
end)

lavaburst:Callback("PVEprocc", function(spell)
    if player.manaPct < 25 then return end 
    if not settings.autodamage then return end 
    awful.enemies.loop(function(enemy)
        if enemy.immuneMagicDamage then return end 
        if enemy.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(enemy) then return end
        if not enemy.combat then return end 
        if enemy.dead then return end
        if enemy.bcc then return end
        if enemy.dist > lavaburst.range then return end
        if enemy.los then
            if player.buff(77762) then --lava surge--
                awful.fullGroup.loop(function(group)
                    if group.hp < 92 then return end
                    if group.target.isUnit(enemy) then
                        if spell:Cast(enemy) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    end 
                end)
            end 
        end
    end) 
end)

chainlight:Callback("PVE", function(spell)
    if player.manaPct < 25 then return end 
    if not settings.autodamage then return end 
    awful.fullGroup.loop(function(group)
        if group.hp < 98 then return end 
        if target.immuneMagicDamage then return end 
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > 40 then return end
        local abc, abcCount = enemies.around(target, 15, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
        if abc and abcCount >= 5 then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end) 
end)

downpour:Callback(function(spell)
    --if wasCasting[spell.id] then return end
    awful.fullGroup.loop(function(group)
    --if not group.los then return end --not in sight--
        if group.hp < 93 and group.hp > 60 then
        --awful.enemies.loop(function(enemy)
            if spell:Cast() then
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

---hiar---

------------------------------------------- PVP -------------------------------------------

--------------- --------------- --------------- --------------- GROUNDING --------------- --------------- --------------- ---------------


local ccStufftoGround = { 
    51514, --Hex
    211015, --Hex
    210873, --Hex
    277784, --Hex
    277778, --Hex
    309328, --Hex
    269352, --Hex
    211004, --Hex
    211010, --Hex
    20066, --rep pala
    118, --sheep
    161355, --sheep
    161354, --sheep
    161353, --sheep
    126819, --sheep
    61780, --sheep
    161372, --sheep
    61721, --sheep
    61305, --sheep
    28272, --sheep
    28271, --sheep
    277792, --sheep
    277787, --sheep
    460392, --Newsheep
    360806, --sleep walk
    5782, --fear
    605, --MC
    33786, --cyclone
}

local damageStufftoGround = { 
    116858, -- chaos bolt
    199786, --glacial spike
    228260, --void erruption
    323764, --convoke
    365350, --arcane surge
    386997, --soulrot
    375087, --dragon rage
}

local immunityStuff = { 377362, 378078, 363916, 104773, 317929}  --precog, spiritwalker, prevokerim, unendinge resolve, auramastery--

local holdnow = false 

awful.onTick(function()

    awful.enemies.loop(function(enemy)
   -- if not settings.autototem then return end 
    if enemy.distanceTo(player) > 34 then return end 
    if player.buff(8178) then return end --there is already a grounding--
   -- if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
    if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
    if not player.hasTalent(204336) then return end --we dont have grounding talented--

        if player.cooldown(204336) < 0.1 then --grounding--
            
        local totalBuffer = awful.gcd + awful.player.gcdRemains + 0.8

            --if tContains(ccStufftoGround, enemy.castID) and enemy.castRemains < totalBuffer then 
            if tContains(ccStufftoGround, enemy.castID) and enemy.castRemains < totalBuffer then 
                holdnow = true
                --SpellCancelQueuedSpell()
                awful.alert({ message = awful.colors.red.. "HOLD", texture = 204336, duration = 0.5 })
                --if player.casting then SpellStopCasting() end
            end 
        end
    end) 
end)

---second holding to gett holdnow to false again back or it will hold swd forever because it is staying true--
awful.onTick(function()
    awful.enemies.loop(function(enemy)
    --if not settings.autototem then return end 
    --if enemy.distanceTo(player) > 30 then return end 
    if holdnow == false then return end 
        if not tContains(ccStufftoGround, enemy.castID) then 
            holdnow = false 
            --and awful.alert({ message = awful.colors.yellow.. "HOLD OFF", duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0 })
        end
    end)
end)

totemgrounding:Callback(function(spell)
    if settings.mode == "pvemode" then return end 
   -- if not settings.autototem then return end 
    if not player.hasTalent(204336) then return end --grounding talent--
    --if holdnow == true then 
        awful.enemies.loop(function(enemy)
        if not enemy.casting then return end
        --if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
        if enemy.distanceTo(player) > 40 then return end 
        if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
        if not tContains(ccStufftoGround, enemy.castID) then return end
        if tContains(ccStufftoGround, enemy.castID) and enemy.castRemains < awful.buffer + 0.7 and player.casting then SpellStopCasting() end
            --if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castRemains < awful.buffer + 0.4 then
            if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castTimeLeft < awful.buffer + 0.6 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "CC", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    --end 
end)

totemgrounding:Callback("damagespells", function(spell)
    if settings.mode == "pvemode" then return end 
    --if not settings.autototem then return end 
    awful.enemies.loop(function(enemy)
   -- if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
    if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
    if not player.hasTalent(204336) then return end --grounding talent--
    if not enemy.casting then return end
    if not tContains(damageStufftoGround, enemy.castID) then return end
    if tContains(damageStufftoGround, enemy.castID) and enemy.castRemains < awful.buffer + 0.8 and player.casting then SpellStopCasting() end
        --if tContains(damageStufftoGround, enemy.castID) and enemy.distanceTo(player) < 30 and enemy.castRemains < awful.buffer + 0.3 then
        if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 40 and enemy.castTimeLeft < awful.buffer + 0.4 then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "DMG", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

totemgrounding:Callback("CDs", function(spell)
    if settings.mode == "pvemode" then return end 
    --if not settings.autototem then return end 
    if not player.hasTalent(204336) then return end --grounding talent--
    awful.enemies.loop(function(enemy)
        if enemy.distanceTo(player) > 40 then return end 
        if enemy.used(190319, 2) or enemy.used(375982, 2) or enemy.used(421453, 2) or enemy.used(191634, 1) then --combust, primo, ultimative penance, stormkeeper--
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "CDs", texture = spell.id, duration = 1 }) end 
            end 
        end 
    end)
end)

local losTimer
function losSince()
    awful.enemies.loop(function(enemy)
        if enemy.class2 ~= "PALADIN" then return end  
        if (losTimer == 0 and enemy.los) then
            losTimer = awful.time
            return 0
        end
        if (losTimer ~= 0 and not enemy.los) then
            losTimer = 0
            return 0
        end
    end)
end

totemgrounding:Callback("palaHOJ", function(spell)
    if settings.mode == "pvemode" then return end 
    if not settings.autototem then return end 
    if not player.hasTalent(204336) then return end 
    if player.sdr < 1 then return end  --only full drs--
    awful.enemies.loop(function(enemy)
    if enemy.class2 ~= "PALADIN" then return end  
    if enemy.cc or enemy.bcc then return end 
    if not enemy.los then return end 
    --if player.speed > enemy.speed then return end 
    if enemy.cooldown(853) > 0.5 then return end  --priest fear not rdy--  
        if enemy.distanceTo(player) < 13 or enemy.buff(221883) and enemy.distanceTo(player) < 16 or enemy.buff(221883) then --pferd--
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "GROUND HOJ", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

local onUpdate = awful.addUpdateCallback

-- awful.onUpdate(function()
--     totemgrounding:Callback("trap", function(spell)
--         if settings.mode == "pvemode" then return end 
--        -- if not settings.autototem then return end 
--         if awful.instanceType2 == "pvp" then return end -- we don't need that in BGs--
--         awful.missiles.track(function(missile)
--             local id = missile.spellId
--             if not id then return end
--             local missilecreator = awful.GetObjectWithGUID(missile.source)
--             if missilecreator.friend then return end
--             if id ~= 187650 then return end
--             if player.casting and not player.moving then 
--                 SpellStopCasting()
--                 SpellStopCasting()
--             end 
--             local hx, hy, hz = missile.hx,missile.hy,missile.hz
--             if player.distanceTo(hx, hy, hz) < 10 then
--                 return totemgrounding:Cast() and awful.alert({ message = awful.colors.red.. "Trap", texture = spell.id, duration = 1 })
--             end
--         end)
--     end)
-- end)

totemgrounding:Callback("harpoonTrap", function(spell)
    if settings.mode == "pvemode" then return end 
    if not player.hasTalent(204336) then return end --grounding talent--
    if player.idr < 0.5 then return end  --only half or full ddr drs--
    awful.enemies.loop(function(enemy)
        if enemy.class == "Hunter" then 
            if enemy.cooldown(187650) > 1 then return end  --trap not rdy--
            if player.debuff(190925) and player.debuffRemains(190925) < 2.4 then 
                return spell:Cast() and awful.alert({ message = awful.colors.red.. "ground trap", texture = spell.id, duration = 2 })
            end
        end
    end)
end)

--------------- --------------- --------------- --------------- DEFENSIVES  --------------- --------------- --------------- ---------------

local BigDef = { 
    33206, --Pain Suppression
    81782, --Dome
    102342, --Ironbark
    47788, --Guardian Spirit
    232707, --Ray of Hope
    116849, --cocoon
    1022, --BOP
    6940, --SAC
    325174, --link totem buff
    363534, --rewind prevoker--
    357170, --time dilation--
    196718, --darkness--
    209426, --darkness#2--
    125174, --Karma
}

astralshift:Callback("nobigdefs", function(spell)
    if not settings.autodefensives then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if healer.cc and healer.castID == 370984 then return end  --evoker is in cc but communion on--
    if healer.cc and healer.channelID == 370984 then return end  --evoker is in cc but communion on--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 1 and player.hp < 80 then
        --if healer.cc and healer.ccRemains > 1 then
            awful.enemies.loop(function(enemy) 
                if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                    if spell:Cast() then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end)
        --end
    end
end)

astralshift:Callback("pvpEnemyCds", function(spell)
    if not settings.autodefensives then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if healer.cc and healer.castID == 370984 then return end  --evoker is in cc but communion on--
    if healer.cc and healer.channelID == 370984 then return end  --evoker is in cc but communion on--
    awful.enemies.loop(function(enemy) 
    local total, melee, ranged, cooldowns = player.v2attackers()
        --incarn balance, incarn feral, BM bestial wrath, ret wings, avatar, shadowblades --
        if cooldowns >= 1 or enemy.used(102560, 4) or enemy.used(102543, 4) or enemy.used(19574, 4) or enemy.used(375087, 4) or enemy.used(231895, 4) or enemy.used(107574, 4) or enemy.used(121471, 4) then 
            if player.hp < 80 then
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "enemy cds low hp", texture = spell.id, duration = 1 }) end 
                    end 
                end 
            end 
        end 
    end)
end)

astralshift:Callback("inBGs", function(spell)
    if not settings.autodefensives then return end 
    if awful.instanceType2 ~= "pvp" then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 1 and total > 1 then
       -- if healer.cc and healer.ccRemains > 1 then
            if player.hp < 90 then 
                awful.enemies.loop(function(enemy) 
                    if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                        if spell:Cast() then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        end 
                    end
                end)
            end 
        --end
    end
end)

astralshift:Callback("inBGsLow", function(spell)
    if settings.mode == "pvemode" then return end 
    if not settings.autodefensives then return end 
    if awful.instanceType2 ~= "pvp" then return end 
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.hp < 50 then 
        awful.enemies.loop(function(enemy) 
            if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end 
end)

burrow:Callback("BGslow", function(spell)
    if settings.mode == "pvemode" then return end 
    if not settings.autodefensives then return end 
    if awful.instanceType2 ~= "pvp" then return end 
    if player.buffFrom(noPanic) then return end --we already have big def up--
    awful.enemies.loop(function(unit)
        if player.hp < 30 then
            if unit.los then
                if unit.target.isUnit(player) then --and unit.buff(185422) then --or unit.cooldown(408) < 1 then ---enemy has offensive CDs and shadowdance or kidney rdy targeting me---
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end 
        end 
    end)
end)

burrow:Callback("low", function(spell)
    if not settings.autodefensives then return end 
    if player.buffFrom(noPanic) then return end --we already have big def up--
    awful.enemies.loop(function(unit)
        if player.hp < 30 then
            if unit.los then
                if unit.target.isUnit(player) then --and unit.buff(185422) then --or unit.cooldown(408) < 1 then ---enemy has offensive CDs and shadowdance or kidney rdy targeting me---
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end
            end 
        end 
    end)
end)

totemStoneBulwark:Callback("emergency", function(spell)
    if not settings.autodefensives then return end 
    if player.buffFrom(noPanic) then return end  ---we are fine---
    if player.buffFrom(someDefensives) and player.hp > 40 then return end 
    if not player.combat then return end 
    --if player.buffFrom(someDefensives) then return end  ---we are fine---
    if player.mana < 5000 then return end -- costs of that totem---
    if player.hp < 50 then
        awful.enemies.loop(function(enemy)
            if enemy.distanceTo(player) < 40 then 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end
end)

--------------- --------------- --------------- --------------- KICKS --------------- --------------- --------------- ---------------
--- Kick ---
local kickList = { 5782, 33786, 116858, 2637, 375901, 211015, 210873, 277784, 277778, 269352, 211004, 51514, 28272, 118, 277792, 161354, 277787, 
161355, 161353, 120140, 61305, 61721, 61780, 28271, 82691, 391622, 20066, 605, 113724, 198898, 186723, 32375, 982, 320137, 254418, 8936, 82326, 
209525, 289666, 2061, 283006, 19750, 77472, 199786, 204437, 227344, 30283, 115175, 191837, 124682, 360806, 382614, 382731, 382266, 8004, 355936, 367226, 2060, 64843, 263165, 228260, 
205021, 404977, 421453, 342938, 316099, 200652, 51505, 1064, 48181, 120644 } --neu geadded: lavaburst, chainheal, haunt, halo--

---channels die von der castbar "weniger" werden, anders wie bei penance wo die castbar auch channeld ist aber der balken "voll" wird--
--soothing mist, penance, essence font, Lasso, Convoke, Dream Breath, Spiritbloom, Sleep Walk, Gotteshymne, Void Torrent, Desintegrate, ray of frost, time skip--
local kickChannels = { 115175, 47540, 191837, 305483, 391528, 355936, 367226, 360806, 64843, 263165, 205021, 404977 } 

---eben andersherum aber muss noch IDs finden---
local kickDisintigrate = { 356995 } --disintegrate
local kickFireBreath = { 357208 } --fire breath when playing with rdruid

local kickClone = { 33786 }

local noKickthings = { 
    377362, --precog
    209584, --zen tea
    378078, --shaman spirit walker immunity
    363916, --prevoker immunity--
    104773, --unending resolve
    317929, --hpal aura mastery immunity
    215769, --angel
}

local KickDelay = awful.delay(0.4, 0.6)
local KickDelayCasts = awful.delay(0.4, 0.6)

windshear:Callback("casts", function(spell)  
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
        if enemy.class == "Druid" and enemy.spec == "Balance" and awful.instanceType2 == "arena" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Feral" and awful.instanceType2 == "arena" then return end -- we have our own function for it --

        if awful.fighting("Balance") and awful.instanceType2 == "arena" then return end 
        if awful.fighting("Feral") and awful.instanceType2 == "arena" then return end 

        if awful.fighting(102) and awful.instanceType2 == "arena" then return end --balance--
        if awful.fighting(103) and awful.instanceType2 == "arena" then return end --feral--

        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end 
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not tContains(kickList, enemy.castID) then return end
        if enemy.casting then
            --if enemy.castTimeComplete > KickDelay.now then --and enemy.castRemains > awful.buffer then 
            if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                if spell:Cast(enemy) then -- 
                    --awful.alert({ message = awful.colors.red.. "Kick", texture = spell.id, duration = 2 })
                    awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                    return true -- we return true to stop the loop.
                end
            end
        end
    end)
end)

windshear:Callback("vsBoomkins", function(spell) 
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
    if player.buff(8178) then return end --grounding enabled--
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end 
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not tContains(kickClone, enemy.castID) then return end
        if enemy.casting then
            if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                if spell:Cast(enemy) then -- 
                    awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                    return true -- we return true to stop the loop.
                end
            end
        end
    end)
end)

windshear:Callback("channel", function(spell) 
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not enemy.channeling then return end 
        if not tContains(kickList, enemy.channelID) then return end
        if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
        return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
        end
    end)
end)

windshear:Callback("channelotherkicks", function(spell) 
    if not settings.autokick then return end
    if settings.mode == "pvemode" then return end 
    awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.channeling then return end 
        if not enemy.los then return end 
        if not tContains(kickChannels, enemy.channelID) then return end
        if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
        return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
        end
    end)
end)

windshear:Callback("otherchannels", function(spell) 
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
        awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
            if enemy.channel == "Penance" or enemy.channel == "Lightning Lasso" or enemy.channel == "Convoke the Spirits" then
                if enemy.channelTimeComplete > KickDelay.now then  
                return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                end
            end
        end)
end)

---because it's not taking the fcking ID, so I had to do a function only for some single castIDs which are ignored in my kicklist somehow--
windshear:Callback("nottakingthefckID", function(spell) 
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
        awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end
        if not enemy.los then return end 
   
        if enemy.class == "Druid" and enemy.spec == "Balance" and awful.instanceType2 == "arena" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Feral" and awful.instanceType2 == "arena" then return end -- we have our own function for it --

        if awful.fighting("Balance") and awful.instanceType2 == "arena" then return end 
        if awful.fighting("Feral") and awful.instanceType2 == "arena" then return end 

        if awful.fighting(102) and awful.instanceType2 == "arena" then return end --balance--
        if awful.fighting(103) and awful.instanceType2 == "arena" then return end --feral--

        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
            if enemy.castID == 360806 or enemy.castID == 228260 or enemy.castID == 77472 or enemy.castID == 8004 then --sleep walk, void erruption, healing wave--
                if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                end
            end
        end)
end)

windshear:Callback("disintigrate", function(spell) 
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
      
        if enemy.class == "Druid" and enemy.spec == "Balance" and awful.instanceType2 == "arena" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Feral" and awful.instanceType2 == "arena" then return end -- we have our own function for it --

        if awful.fighting("Balance") and awful.instanceType2 == "arena" then return end 
        if awful.fighting("Feral") and awful.instanceType2 == "arena" then return end 

        if awful.fighting(102) and awful.instanceType2 == "arena" then return end --balance--
        if awful.fighting(103) and awful.instanceType2 == "arena" then return end --feral--

        if not spell:Castable(enemy) then return end
        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
        if not enemy.los then return end 
        if not enemy.channeling then return end 
        if enemy.healer then return end --we don't kick Disintigrate on Healer--
        if not tContains(kickDisintigrate, enemy.channelID) then return end
        if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
        return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
        end
    end)
end)

windshear:Callback("firebreath", function(spell)  
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
    awful.fullGroup.loop(function(group)
        if group.class == "Druid" and group.spec == "Restoration" then 
            awful.enemies.loop(function(enemy) 
                if not spell:Castable(enemy) then return end
                if not enemy.casting then return end 
                if enemy.buffFrom(noKickthings) then return end 
                if enemy.debuff(410216) then return end --searing glare on him--
                if not enemy.los then return end 
                if not tContains(kickFireBreath, enemy.castID) then return end
                if enemy.casting then
                    --if enemy.castTimeComplete > KickDelay.now then --and enemy.castRemains > awful.buffer then 
                    if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                        if spell:Cast(enemy) then -- 
                            --awful.alert({ message = awful.colors.red.. "Kick", texture = spell.id, duration = 2 })
                            awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id) 
                            return true -- we return true to stop the loop.
                        end
                    end
                end
            end)
        end 
    end)
end)

windshear:Callback("firebreathChannel", function(spell) 
    if settings.mode == "pvemode" then return end 
    if not settings.autokick then return end
    awful.fullGroup.loop(function(group)
        if group.class == "Druid" and group.spec == "Restoration" then 
            awful.enemies.loop(function(enemy) 
                if not spell:Castable(enemy) then return end
                if enemy.buffFrom(noKickthings) then return end 
                if enemy.debuff(410216) then return end --searing glare on him--
                if not enemy.los then return end 
                if not enemy.channeling then return end 
                if not tContains(kickFireBreath, enemy.channelID) then return end
                if enemy.channeling and enemy.channelTimeComplete > KickDelay.now then
                return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                end
            end)
        end 
    end) 
end)

--------------- --------------- --------------- --------------- HEALINGS --------------- --------------- --------------- ---------------


local DispelMagicDelay = awful.delay(0.3, 0.5)

local purgeList = {
    [1022] = { uptime = DispelMagicDelay.now, min = 3 },    --"Blessing of Protection",
    [342246] = { uptime = DispelMagicDelay.now, min = 0 },  --"Alter Time",
    [10060] = { uptime = DispelMagicDelay.now, min = 5 },  --"Power Infusion",
    [213610] = { uptime = DispelMagicDelay.now, min = 5 }, --"Holy Ward",
    [132158] = { uptime = DispelMagicDelay.now, min = 0 }, --"Nature's Swiftness Druid",
    [378081] = { uptime = DispelMagicDelay.now, min = 0 }, --"Nature's Swiftness Shaman",
    [378464] = { uptime = DispelMagicDelay.now, min = 6 },    ---"Nullifying shroud"---
    [415244] = { uptime = DispelMagicDelay.now, min = 1 },    ---Hpal Divine Plea---
    [415246] = { uptime = DispelMagicDelay.now, min = 1 },    ---Hpal Divine Plea2---
    [114893] = { uptime = DispelMagicDelay.now, min = 1 },    ---New Bulwark Totem--
    [212295] = { uptime = DispelMagicDelay.now, min = 1 },    ---Warlock Reflect netherward
}

greaterpurge:Callback("mindcontrol", function(spell)
    --if not settings.autopurge then return end
    if player.mana < 45000 then return end -- purge costs 44960 mana --
    if awful.fighting("PRIEST") then
        awful.group.loop(function(unit, i, uptime)
            if unit.dead then return end
            if not spell:Castable(unit) then return end
            if unit.cc ~= 605 then return end
            if spell:Cast(unit) then
                awful.alert({ message = awful.colors.red.."", texture = spell.id, duration = 1 }) return true
            end
        end)
    end
end)

greaterpurge:Callback("purge", function(spell)
    --if not settings.autopurge then return end
    if player.mana < 52500 then return end -- purge costs 52500 mana --
    if player.debuffStacks(410063) == 2 then return end --silence stacks of rdruid--
    awful.enemies.loop(function(unit, i, uptime)
        --if uptime < 0.3 then return end
        if unit.dead then return end
        if not spell:Castable(unit) then return end
        if not unit.buffFrom(purgeList) then return end
        --if unit.purgeCount > 15 then return end --too many buffs on him--
        if spell:Cast(unit) then
            awful.alert({ message = awful.colors.red.."", texture = spell.id, duration = 1 }) return true
        end
    end)
end)

local natureCureDelay = awful.delay(0.3, 0.5)

local natureCureDebuffs = {
    -- Mage
    [28272] = { uptime = natureCureDelay.now, min = 3 },	-- Pig
    [118] = { uptime = natureCureDelay.now, min = 3 },		-- Sheep
    [277792] = { uptime = natureCureDelay.now, min = 3 },   -- Bee
    [161354] = { uptime = natureCureDelay.now, min = 3 },   -- Monkey
    [277787] = { uptime = natureCureDelay.now, min = 3 },   -- Direhorn
    [161355] = { uptime = natureCureDelay.now, min = 3 },   -- Penguin
    [161353] = { uptime = natureCureDelay.now, min = 3 },   -- Polar Bear
    [120140] = { uptime = natureCureDelay.now, min = 3 },   -- Porcupine
    [61305] = { uptime = natureCureDelay.now, min = 3 },    -- Cat
    [61721] = { uptime = natureCureDelay.now, min = 3 },    -- Rabbit
    [61780] = { uptime = natureCureDelay.now, min = 3 },    -- Turkey
    [28271] = { uptime = natureCureDelay.now, min = 3 },    -- Turtle
    [82691] = { uptime = natureCureDelay.now, min = 3 },    -- Ring of Frost
    [391622] = { uptime = natureCureDelay.now, min = 3 },   -- new mage Duck
    [200205] = { uptime = natureCureDelay.now, min = 3 },   -- new mage Duck 2
    [390612] = { uptime = natureCureDelay.now, min = 3 },   -- FrostBomb
    -- Hunter
    [3355] = { uptime = natureCureDelay.now, min = 2 },     -- Freezing Trap
    --[212431] = { uptime = natureCureDelay.now, min = 0 },     -- Explo shot
    -- Paladin
    [105421] = { uptime = natureCureDelay.now, min = 2 },   -- Blinding Light
    [20066] = { uptime = natureCureDelay.now, min = 2 },    -- Repentance
    [77787] = { uptime = natureCureDelay.now, min = 1 },    -- Hammer of Justice
    [853] = { uptime = natureCureDelay.now, min = 1 },      -- Hammer of Justice
    -- Warlock
    [5782] = { uptime = natureCureDelay.now, min = 2 },   -- Fear
    [5484] = { uptime = natureCureDelay.now, min = 2 },     -- Howl of Terror
    [6358] = { uptime = natureCureDelay.now, min = 2 },  -- Seduction (Succubus)
    --[325640] = { uptime = natureCureDelay.now, min = awful.gcd },   -- Soul Rot Night Fae
    [6789] = { uptime = natureCureDelay.now, min = 1 },             -- Mortal Coil
    [30283] = { uptime = natureCureDelay.now, min = 2 },             -- shadowfury
    -- Priest
    [8122] = { uptime = natureCureDelay.now, min = 2 },     -- Psychic Scream
    [64044] = { uptime = natureCureDelay.now, min = 2 },    -- Psychic Horror Stun
   -- [323673] = { uptime = natureCureDelay.now, min = awful.gcd },   -- Mindgames
   -- [375901] = { uptime = natureCureDelay.now, min = awful.gcd },   -- Mindgames new
    [226943] = { uptime = natureCureDelay.now, min = awful.gcd },   -- Mind Bomb Fear
    [205369] = { uptime = natureCureDelay.now, min = 0 },           -- Mind Bomb
    [15487] = { uptime = natureCureDelay.now, min = 2 },  -- silence
    -- Demon Hunter
    [207685] = { uptime = natureCureDelay.now, min = 2 },   ---sigil fear---
    [179057] = { uptime = natureCureDelay.now, min = 2 },   --chaos nova--
    -- monk
    [198898] = { uptime = natureCureDelay.now, min = 2 }, -- Songofchi
    -- evoker
    [360806] = { uptime = natureCureDelay.now, min = 2 }, --sleepwalk
    -- shaman  
    [118905] = { uptime = natureCureDelay.now, min = 2 }, --stuntotem-stun
    -- DK
    [377048] = { uptime = natureCureDelay.now, min = 2 }, --Frost DK Freeze
    --Pala
    [410201] = { uptime = natureCureDelay.now, min = 2 }, --Searing Glen
    [2812] = { uptime = natureCureDelay.now, min = 2 }, --Denounce--
    -- Druid
    [209749] = { uptime = natureCureDelay.now, min = 3 }, --Disarm--
    --[164812] = { uptime = natureCureDelay.now, min = 3 }, --test--
}

local natureCureCurses = {
    [51514] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Frog
    [211015] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Kakerlake
    [210873] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Raptor
    [277784] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Köter
    [277778] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Zandalari
    [269352] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Skelett
    [211004] = { uptime = natureCureDelay.now, min = 2 },  -- Hex Spider
    [80240] = { uptime = natureCureDelay.now, min = 0 },   -- Havoc
}

dispel:Callback("curses", function(spell)
    if not settings.dispelye then return end
    if not player.hasTalent(383016) then return end 
    awful.fullGroup.loop(function(unit, i, uptime)
        if unit.dead then return end
        if not spell:Castable(unit) then return end
        if not unit.debuffFrom(natureCureCurses) then return end
        if unit.debuff(316099) then return end --unstable affliction--
        if unit.debuff(342938) then return end --unstable affliction--
        if unit.debuff(34914) and unit.hp < 40 then return end --vampiric touch, we need to be careful and healing first except angel--
        if spell:Cast(unit) then
            awful.alert({ message = awful.colors.orange.."Dispel Curse", texture = spell.id, duration = 1 }) return true
        end
    end)
end)

dispel:Callback("debuffs", function(spell)
    if not settings.dispelye then return end
    awful.fullGroup.loop(function(unit, i, uptime)
        if unit.dead then return end
        if not spell:Castable(unit) then return end
        if not unit.debuffFrom(natureCureDebuffs) then return end
        if unit.debuff(316099) then return end --unstable affliction--
        if unit.debuff(342938) then return end --unstable affliction--
        if unit.debuff(34914) and unit.hp < 40 then return end --vampiric touch, we need to be careful and healing first except angel--
        if spell:Cast(unit) then
            awful.alert({ message = awful.colors.red.."", texture = spell.id, duration = 1 }) return true
        end
    end)
end)

totemhealingstream:Callback("pvp", function(spell)

    if wasCasting[spell.id] then return end
    if player.used(totemhealingstream.id, 24) then return end 
    if not player.combat then return end 
    if player.mana < 60000 then return end -- costs of that totem---

    awful.fullGroup.loop(function(friend)
        if friend.hp < 99 and friend.hp > 50 then
            if friend.distanceTo(player) < 46 then 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end
    end)
end)

healingsurge:Callback("pvp", function(spell)
    if player.buff(443454) then return end  --instant buff for healing wave--
    awful.fullGroup.loop(function(group)
    if wasCasting[spell.id] then return end
    if group.dist > healingsurge.range then return end
    if not group.los then return end --not in sight--
         if group.hp < 90 then
        --awful.enemies.loop(function(enemy)
            if spell:Cast(group) then
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
            end 
        end
    end)
end)

healingsurge:Callback("lowestpvpSpiritWalker", function(spell)
    if player.buff(443454) then return end  --instant buff for healing wave--
    local lowest = awful.fullGroup.lowest
    if lowest.hp < 40 and player.cooldown(61295) then return end 
    --if wasCasting[spell.id] then return end
    --if lowest.dist > 40 then return end
    if not lowest.los then return end --not in sight--
        if player.buff(378078) then --immunity--
            if lowest.hp < 95 then
            --awful.enemies.loop(function(enemy)
                if spell:Cast(lowest) then
                    --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                    if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                end 
            end
        end 
end)

healingsurge:Callback("pvpSpiritWalker", function(spell)
    if player.buff(443454) then return end  --instant buff for healing wave--
    awful.fullGroup.loop(function(group)
    if group.hp < 40 and player.cooldown(61295) < 1 then return end --we have riptide ready and should use it--
    --if wasCasting[spell.id] then return end
    if group.dist > healingsurge.range then return end
    if not group.los then return end --not in sight--
        if player.buff(378078) then --immunity--
            if group.hp < 95 then
            --awful.enemies.loop(function(enemy)
                if spell:Cast(group) then
                    --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                    if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                end 
            end
        end 
    end)
end)

---through mana totem buff--
healingsurge:Callback("pvpProcc", function(spell)
    if player.buff(443454) then return end  --instant buff for healing wave--
    if not player.buff(404523) then return end --procc--
    awful.fullGroup.loop(function(group)
    if wasCasting[spell.id] then return end
    if group.dist > healingsurge.range then return end
    if not group.los then return end --not in sight--
         if group.hp < 90 then
        --awful.enemies.loop(function(enemy)
            if spell:Cast(group) then
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
            end 
        end
    end)
end)

healingwave:Callback("pvpManaEfficient", function(spell)
    if not settings.manaefficient then return end
    awful.fullGroup.loop(function(group)
    local total, melee, ranged, cooldowns = group.v2attackers()
    if cooldowns >= 1 then return end --enemy bursting--
    if wasCasting[spell.id] then return end
    if group.dist > healingwave.range then return end
    if not group.los then return end --not in sight--
         if group.hp < 95 and group.hp > 82 then
            if player.manaPct < 85 then 
                if spell:Cast(group) then
                    --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                    if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                end 
            end 
        end
    end)
end)

riptide:Callback("pvp", function(spell)
    if wasCasting[spell.id] then return end
    if player.buff(443454) then return end  --instant buff for healing wave--
    awful.fullGroup.loop(function(group)
    if group.dist > riptide.range then return end
    if not group.los then return end --not in sight--
    --if group.buff(61295) and group.hp > 80 and group.hp < 90 then return end --has riptide on him and is fine--
         if group.hp < 85 then
        --awful.enemies.loop(function(enemy)
            if spell:Cast(group) then
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
            end 
       end
    end)
end)

riptide:Callback("arenaBuff", function(spell)
    if awful.instanceType2 ~= "arena" then return end
    if awful.prep then return end 
    if wasCasting[spell.id] then return end
    if player.combat then return end 
    awful.group.loop(function(group)
    if group.dist > riptide.range then return end
    if not group.los then return end --not in sight--
        if not player.combat then 
            if not group.buff(61295) then
        --awful.enemies.loop(function(enemy)
                if spell:Cast(group) then
                    --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                    if settings.alertmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end 
        end
    end)
end)


unleashlife:Callback("pvp", function(spell)
    if wasCasting[spell.id] then return end
    if player.buff(443454) then return end  --instant buff for healing wave--
    awful.fullGroup.loop(function(group)
    if group.dist > unleashlife.range then return end
    if not group.los then return end --not in sight--
    --if group.buff(61295) and group.hp > 70 and group.hp < 90 then return end --has riptide on him and is fine--
         if group.hp < 80 then
        --awful.enemies.loop(function(enemy)
            if spell:Cast(group) then
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
       end
    end)
end)

totemhealingtide:Callback("pvp", function(spell)
    if not settings.autocds then return end
    local count = #awful.fullGroup.filter(function(unit) return unit.hp < 65 and unit.distanceTo(player) < 46 and not unit.dead end)  
    if count >= 2 then
        awful.fullGroup.loop(function(group)
            if group.distanceTo(player) < 46 then
            if not group.los then return end --not in sight-- 
            if not spell:Castable(group) then return end
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end 
        end)
    end 
end)

totemhealingtide:Callback("pvpEnemyCds", function(spell)
    if not settings.autocds then return end
    awful.fullGroup.loop(function(group)
        awful.enemies.loop(function(enemy) 
            local total, melee, ranged, cooldowns = group.v2attackers()
             --incarn balance, incarn feral, BM bestial wrath, ret wings, avatar, shadowblades --
            if cooldowns >= 1 or enemy.used(102560, 4) or enemy.used(102543, 4) or enemy.used(19574, 4) or enemy.used(375087, 4) or enemy.used(231895, 4) or enemy.used(107574, 4) or enemy.used(121471, 4) then 
                if group.hp < 90 then
                    if group.distanceTo(player) < 46 then
                        if spell:Cast(player) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "enemy cds", texture = spell.id, duration = 1 }) end 
                        end 
                    end 
                end 
            end 
        end)
    end)
end)


totemicrecall:Callback(function(spell)
    if player.used(198838, 8) then 
        if spell:Cast() then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

totemearthen:Callback("pvp", function(spell)
    if not settings.autoearthenPVP then return end
    if not player.combat then return end 
    if wasCasting[spell.id] then return end
    if player.manaPct < 5 then return end -- do nothing under 7% mana
    if player.used(198838, 18) then return end  --earthen used already--
    awful.fullGroup.loop(function(group)
        if not settings.magemonkey and group.buff(342246) then return end --alter time enabled--
        if group.buffFrom(someDefensives) then return end 
        if group.buffFrom(noPanic) then return end 
        if group.debuff(33786) then return end --is in clone--
        if group.distanceTo(player) > 40 then return end
        if not group.los then return end 
        --local count = #awful.fullGroup.filter(function(unit) return unit.hp < 95 end)
       -- if count >= 2 then 
        if group.hp < 95 then 
            awful.enemies.loop(function(enemy)
                if enemy.target.isUnit(group) then 
                    if spell:SmartAoE(group) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                        --if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                    end 
                end 
            end) 
        end
    end)
end)

totemearthen:Callback("pvpVSDKs", function(spell)
    if not settings.autoearthenPVP then return end
    awful.fullGroup.loop(function(group)
        --if group.buffFrom(someDefensives) then return end 
        --if group.buffFrom(noPanic) then return end 
        --if player.used(198838, 18) then return end 
       -- if group.debuff(33786) then return end --is in clone--
        if player.manaPct < 5 then return end -- do nothing under 7% mana
        if group.distanceTo(player) > 40 then return end
        --local count = #awful.fullGroup.filter(function(unit) return unit.hp < 95 end)
        if awful.fighting("DEATHKNIGHT") then 
            local total, melee, ranged, cooldowns = group.v2attackers()
            if cooldowns >= 1 then 
                if group.hp < 97 then 
                    awful.enemies.loop(function(enemy)
                        if enemy.target.isUnit(group) then 
                            if spell:AoECast(group) then
                                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                                --if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                            end 
                        end 
                    end) 
                end
            end 
        end 
    end)
end)

totemearthen:Callback("doublemelees", function(spell)
    if not settings.autoearthenPVP then return end
    awful.fullGroup.loop(function(group)
        --if group.buffFrom(someDefensives) then return end 
        --if group.buffFrom(noPanic) then return end 
        --if player.used(198838, 18) then return end 
       -- if group.debuff(33786) then return end --is in clone--
        if player.manaPct < 5 then return end -- do nothing under 7% mana
        if group.distanceTo(player) > 40 then return end
        --local count = #awful.fullGroup.filter(function(unit) return unit.hp < 95 end)
        --if awful.fighting("DEATHKNIGHT") then 
            local total, melee, ranged, cooldowns = group.v2attackers()
            if cooldowns >= 1 and melee > 1 then 
                if group.hp < 99 then 
                    awful.enemies.loop(function(enemy)
                        if enemy.target.isUnit(group) then 
                            if spell:AoECast(group) then
                                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                                --if settings.alertmode then awful.alert(awful.colors.pink.. (group.name), spell.id) end
                            end 
                        end
                    end)
                end
            end 
        --end 
    end)
end)

primowave:Callback("pvp", function(spell)
    --if not settings.autocds then return end
    if wasCasting[spell.id] then return end
    if player.buff(443454) then return end  --instant buff for healing wave--
    awful.fullGroup.loop(function(group)
    if not settings.magemonkey and group.buff(342246) then return end --alter time enabled--
    if group.dist > primowave.range then return end
    if not group.los then return end --not in sight--
    if group.distanceTo(player) > 40 then return end 
    --if group.buff(61295) and group.hp > 70 and group.hp < 90 then return end --has riptide on him and is fine--
         if group.hp < 60 then
            if spell:Cast(group) then
               -- if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
               if settings.alertsmode then awful.alert(awful.colors.pink.. "" .. awful.colors.pink.. (group.name), spell.id) end 
            end 
        end
    end)
end)

ancestralSwiftness:Callback(function(spell)
    --if not settings.autocds then return end
    if player.used(428332, 4) then 
        if spell:Cast() then
            --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test", texture = spell.id, duration = 1 }) end 
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end 
    end
end)

healingwave:Callback("PVP-Swiftness", function(spell)
    if awful.instanceType2 == "arena" then return end  --we have another funciton for arena--
    if not player.buff(443454) then return end --instant--
    awful.fullGroup.loop(function(group)
        if group.dist > healingwave.range then return end
        if not group.los then return end --not in sight-- 
        if not spell:Castable(group) then return end
        local lowest = awful.fullGroup.lowest
        if group.hp < 75 then
            if player.buff(443454) then --ancestral swift
                if spell:Cast(group) then 
                    --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test instant", texture = spell.id, duration = 1 }) end 
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end 
        end 
    end)
end)

healingwave:Callback("PVP-SwiftnessArena", function(spell)
    if awful.instanceType2 ~= "arena" then return end  --only this in arena--
    if not player.buff(443454) then return end --instant--
    local lowest = awful.fullGroup.lowest
    if lowest.dist > healingwave.range then return end
    if lowest.hp < 90 and lowest.los then
        if player.buff(443454) then --ancestral swift
            if spell:Cast(lowest) then 
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test instant", texture = spell.id, duration = 1 }) end 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end 
    end 
end)


local stunList = {
    [5211] = { uptime = 0.8, min = 0.5 }, --bash--
    [203123] = { uptime = 0.8, min = 0.5 }, --maim--
    [163505] = { uptime = 0.8, min = 0.5 }, --rake--
    [853] = { uptime = 0.8, min = 0.5 },  --hoj--
    [119381] = { uptime = 0.8, min = 0.5 }, --legwsweep?--
    [1833] = { uptime = 0.8, min = 0.5 },  --cheashot--
    [408] = { uptime = 0.8, min = 0.5 },  --kidney--
    [132169] = { uptime = 0.8, min = 0.5 }, --stormbolt--
    [132168] = { uptime = 0.8, min = 0.5 }, --shockwave--
    [287250] = { uptime = 0.8, min = 0.5 },  --DK dead of winter--
    [179057] = { uptime = 0.8, min = 0.5 }, --chaos nova--
    [211881] = { uptime = 0.8, min = 0.5 }, --fel eruption--
    [30283] = { uptime = 0.8, min = 0.5 }, --shadowfury--
    [221562] = { uptime = 0.8, min = 0.5 }, --DK asphyxiate stun
    [377047] = { uptime = 0.8, min = 0.5 }, --DK absolute zero 
}

thunderstorm:Callback(function(spell)
    if not settings.autothunderstorm then return end
    awful.enemies.loop(function(enemy, i, uptime) 
        --if uptime < 0.7 then return end 
        if not enemy.player then return end 
        if enemy.role ~= "melee" then return end -- if not meele then dont --
        if enemy.buff(227847) then return end --bladestorm--
        if enemy.distanceTo(player) > 10 then return end
        if enemy.immuneMagicDamage then return end 
        if enemy.buff(642) then return end --bubble--
        if enemy.buff(48707) then return end --AMS--
        if enemy.buff(345228) then return end --lolstorm--
        if enemy.buff(23920) then return end --spell reflect--
        if not enemy.los then return end --enemy is not in sight for casting--
       -- if not spell:Castable(enemy) then return end --is castable like when he has immunities--
       -- if enemy.rootDR <= 0.25 then return end --only rooting him when he is on half or full dr--
        if enemy.distanceTo(player) < 10 then
            if player.debuffFrom(stunList) then --or player.debuff(372245) then ---enemy stunned me--- +dk stun
            return spell:Cast(player) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 })
            end
        end
    end)
end)

local nohexthings = { 
    377362, --precog
    8178, --grounding
    23920, --reflect
    212295, --netherward--
    353319, --monk revival
    409293, --burrow
    215769, --angel
}

local formsDruid = {
    768, --cat
    5487, --bear--
    783, -- travel
    33891, -- incarn
}

---healer--
hex:Callback("Healer", function(spell)
    if player.buff(79206) then return end  --we have another function for this--
    if not settings.autohex then return end
    if awful.instanceType2 ~= "arena" then return end 
    awful.enemies.loop(function(enemy)
        awful.fullGroup.loop(function(group)
            if group.hp < 95 then return end 
            local total, melee, ranged, cooldowns = group.v2attackers()
            if cooldowns >= 1 or enemy.used(102560, 4) or enemy.used(102543, 4) or enemy.used(19574, 4) or enemy.used(375087, 4) or enemy.used(231895, 4) or enemy.used(107574, 4) or enemy.used(121471, 4) then return end 
            if awful.instanceType2 == "arena" then
                if wasCasting[spell.id] then return end
                if enemyHealer.class2 == "DRUID" and enemyHealer.buffFrom(formsDruid) then return end --he will shapeshift--
                if enemyHealer.dist > hex.range then return end
                if enemyHealer.debuff(81261) then return end --he is root-beamed-
                if not spell:Castable(enemyHealer) then return end
                if enemyHealer.buffFrom(nohexthings) then return end 
                if not enemyHealer.los then return end --enemy is not in sight for casting--
                if enemyHealer.idr <= 0.5 then return end 
                if enemyHealer.ccRemains > 3 then return end  --to prevent not ccing already cc'd target--
                if group.target.isUnit(enemyHealer) then return end -- we go on healer ---
                if (enemyHealer.ccRemains - awful.buffer) < hex.castTimeRaw then 
                    --if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                    if spell:Cast(enemyHealer, { stopMoving = true }) then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Healer", texture = 51514, duration = 1 }) end
                        return true
                    end
                end 
            end 
        end) 
    end)
end)

--- another function since we shouldn't stopMoving when we have spiritwalker up--
hex:Callback("HealerSpiritWalker", function(spell)
    if not player.buff(79206) then return end 
    if player.buff(79206) then --spiritwalker--
        if not settings.autohex then return end
        if awful.instanceType2 ~= "arena" then return end 
        awful.enemies.loop(function(enemy)
            awful.fullGroup.loop(function(group)
                if group.hp < 95 then return end 
                local total, melee, ranged, cooldowns = group.v2attackers()
                if cooldowns >= 1 or enemy.used(102560, 4) or enemy.used(102543, 4) or enemy.used(19574, 4) or enemy.used(375087, 4) or enemy.used(231895, 4) or enemy.used(107574, 4) or enemy.used(121471, 4) then return end 
                if awful.instanceType2 == "arena" then
                    if wasCasting[spell.id] then return end
                    if enemyHealer.class2 == "DRUID" and enemyHealer.buffFrom(formsDruid) then return end --he will shapeshift--
                    if enemyHealer.dist > hex.range then return end
                    if enemyHealer.debuff(81261) then return end --he is root-beamed-
                    if not spell:Castable(enemyHealer) then return end
                    if enemyHealer.buffFrom(nohexthings) then return end 
                    if not enemyHealer.los then return end --enemy is not in sight for casting--
                    if enemyHealer.idr <= 0.5 then return end 
                    if enemyHealer.ccRemains > 3 then return end  --to prevent not ccing already cc'd target--
                    if group.target.isUnit(enemyHealer) then return end -- we go on healer ---
                    if (enemyHealer.ccRemains - awful.buffer) < hex.castTimeRaw then 
                        --if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                        if spell:Cast(enemyHealer) then 
                            if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Healer", texture = 51514, duration = 1 }) end
                            return true
                        end
                    end 
                end 
            end) 
        end)
    end 
end)

local nosheepthings = { 
    377362, --precog
    8178, --grounding
    23920, --reflect
    212295, --netherward--
    353319, --monk revival
    409293, --burrow
    215769, --angel
    378464, --nullyfying shroud
    6940, -- sac
}

hex:Callback("testHealer", function(spell)
    if not settings.autohex then return end
    --if target.hp < 20 and not target.buffFrom(noPanic) then return end 
    if awful.instanceType2 == "arena" then
        if wasCasting[spell.id] then return end
        if enemyHealer.class2 == "DRUID" and enemyHealer.buffFrom(formsDruid) then return end --he will shapeshift--
        if enemyHealer.dist > hex.range then return end
        if enemyHealer.debuff(81261) then return end --he is root-beamed-
        if not spell:Castable(enemyHealer) then return end
        if enemyHealer.buffFrom(nosheepthings) then return end 
        if not enemyHealer.los then return end --enemy is not in sight for casting--
        if enemyHealer.idr <= 0.25 then return end 
        if enemyHealer.idr <= 0.5 and enemyHealer.idrRemains < 10 then return end --we can sheep soon again 
        if enemyHealer.ccRemains > 3 then return end  --to prevent not ccing already cc'd target--
        if (enemyHealer.ccRemains - awful.buffer) < hex.castTimeRaw then 
            if spell:Cast(enemyHealer, { stopMoving = true }) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Test Healer", texture = spell.id, duration = 1 }) end
                return true
            end
        end 
    end 
end)

--offCC-- 
--aktuell disabled weil er es manchmal auf target macht von group und irgendwie auch wenn group < 70 ist, evlt auch auf burst check ka
hex:Callback("offCC", function(spell)
    if not settings.autohex then return end
    awful.fullGroup.loop(function(group)
        if group.hp < 95 then return end 
        if awful.instanceType2 == "arena" then
            awful.enemies.loop(function(enemy)
            if not enemy.isPlayer then return end 
            if enemy.class2 == "DRUID" then return end 
            if enemy.ccRemains > 2 then return end  --to prevent not ccing already cc'd target--
            --if enemy.cc then return end 
            if enemy.role == "healer" then return end --we don't want to clone heal--
            if not spell:Castable(enemy) then return end
            if enemy.dist > hex.range then return end
            if enemy.buffFrom(nohexthings) then return end 
            if enemy.idr <= 0.5 then return end 
            if not enemy.los then return end --enemy is not in sight for casting--
                if (enemy.ccRemains - buffer) < hex.castTimeRaw then
                    if not group.target.isUnit(enemy) then  --so it's off target--
                        if not enemy.target.isUnit(player) then --we are not the target--
                            if enemy.cds then
                                --if settings.autolockmovement and spell.current or player.channelID == spell.id then awful.controlMovement(0.3) end
                                if spell:Cast(enemy, { stopMoving = true }) then 
                                    if settings.alertsmode then awful.alert({ message = awful.colors.pink.. "Peel", texture = 51514, duration = 1 }) end
                                    return true
                                end
                            end
                        end 
                    end
                end
            end)
        end 
    end) 
end)

flameshock:Callback("spread", function(spell)
    if not settings.autodamage then return end 
    if player.manaPct < 30 then return end 

    awful.fullGroup.loop(function(group)

        if group.hp < 95 then return end 

        awful.enemies.loop(function(enemy)
            if not enemy.isPlayer then return end 
            if enemy.buff(212295) then return end  --netherward--
            if enemy.buff(48707) then return end --ams--
            if enemy.immuneMagicDamage then return end 
            if not spell:Castable(enemy) then return end
            if enemy.dead then return end
            if enemy.bcc then return end
            --if enemy.cc then return end
            if enemy.dist > flameshock.range then return end
            if enemy.debuff(flameshock.id, player) then return end 
            if enemy.los then
                if enemy.debuffRemains(flameshock.id, player) < 1 then
                return spell:Cast(enemy) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 })
                end
            end
        end)
    end)
end)

lavaburst:Callback("Procc", function(spell)
    if not settings.autodamage then return end 
    awful.enemies.loop(function(enemy)
        if enemy.buff(212295) then return end --netherward--
        if enemy.immuneMagicDamage then return end 
        if enemy.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(enemy) then return end
        --if not enemy.debuff(188389) and awful.instanceType2 ~= "arena" then return end --flame shock for crit--
        if enemy.dead then return end
        if enemy.bcc then return end
        if enemy.dist > lavaburst.range then return end
        --if player.lastCast == 51505 and player.maelstrom > 50 then return end 
        --if player.maelstrom > 50 then return end 
        if enemy.los then
            if player.buff(77762) then --lava surge--
                awful.fullGroup.loop(function(group)
                    if group.hp < 90 then return end
                    if group.target.isUnit(enemy) then
                        if spell:Cast(enemy) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    end 
                end)
            end 
        end
    end) 
end)

lavaburst:Callback("ProccLOW", function(spell)
    if not settings.autodamage then return end 
    if not player.buff(77762) then return end --lava surge--
    awful.enemies.loop(function(enemy)
        if enemy.buff(212295) then return end --netherward--
        if enemy.immuneMagicDamage then return end 
        if enemy.buffFrom(immuneBuffs) then return end 
        if not spell:Castable(enemy) then return end
        --if not enemy.debuff(188389) and awful.instanceType2 ~= "arena" then return end --flame shock for crit--
        if enemy.dead then return end
        if enemy.bcc then return end
        if enemy.dist > lavaburst.range then return end
        --if player.lastCast == 51505 and player.maelstrom > 50 then return end 
        --if player.maelstrom > 50 then return end 
        if enemy.los and enemy.hp < 20 and not enemy.buffFrom(noPanic) then
            if player.buff(77762) then --lava surge--
                awful.fullGroup.loop(function(group)
                    if group.hp < 30 then return end
                    --if group.target.isUnit(enemy) then
                        if spell:Cast(enemy) then
                            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                        end 
                    --end 
                end)
            end 
        end
    end) 
end)

totemmana:Callback(function(spell)
    if not settings.automanatotem then return end 
    awful.fullGroup.loop(function(group)
        if player.buff("Drink") then return end --player is drinking--
        if not player.combat then return end --we can drink--
        if group.hp < 50 then return end 
        if player.manaPct > 85 then return end -- do nothing over 85% mana
        --if group.buffFrom(someDefensives) then return end --they have active def and probably getting drained right now--
        awful.enemies.loop(function(enemy)
            --if enemy.cds then return end --they bursting--
            --f enemy.target.isUnit(player) then return end 
            return spell:Cast(player) and awful.alert({ message = awful.colors.blue.. "", texture = spell.id, duration = 2 })
        end)
    end)
end)

local totemlinkpvp = awful.Spell(98008, {
    heal = true,
    diameter = 11,
    offsetMin = 1,
    offsetMax = 3,
    --circleSteps = 16,
    --distChecks = 8,
    minDist = 2,
    maxDist = 4,
    maxHit = 999,
    minHit = 2,
    ignoreEnemies = true, 
    --   sort = function(a, b)
    --     return a.hit > b.hit
    --   end
  })

totemlinkpvp:Callback(function(spell)
   if awful.instanceType2 == "arena" then return end --we have another funciton for it--
    if not settings.autolink then return end
    if player.buff(443454) then return end --we instant heal now with swiftness--

    local healingtideTotemCheck = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 46 end)
    if healingtideTotemCheck then return end
    
    local link = awful.totems.find(function(obj) return obj.id == 53006 and obj.distance < 11 end)
    if link then return end 

    awful.fullGroup.loop(function(group)
        if group.buffFrom(noPanic) then return end 

        local abc, abcCount = units.around(group, 10, function(obj) return obj.isPlayer and not obj.cc and not obj.buff(342246) and not obj.dead and obj.friendly end)
        if abc and abcCount >= 2 and group.hp <= 30 then
            --if spell:AoECast(group) then
            if spell:SmartAoE(group) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "link", texture = spell.id, duration = 3 }) end
            end 
        end
    end) 
end)

totemlinkpvp:Callback("arenaParty1", function(spell)
     --if awful.instanceType2 ~= "arena" then return end 
     if select(2,GetInstanceInfo()) ~= "arena" then return end 
     if not settings.autolink then return end
     if player.buff(443454) then return end --we instant heal now with swiftness--
 
     local healingtideTotemCheck = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 46 end)
     if healingtideTotemCheck then return end

    local hpThreshhold = 35

    if party1.hp < hpThreshhold and party1.distanceTo(party2) < 7 and not party1.buffFrom(noPanic) then
    elseif party1.hp < hpThreshhold and party1.distanceTo(player) < 7 and not party1.buffFrom(noPanic) then
        if spell:SmartAoE(party1) then 
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 3 }) end
        end 
    end
end)

 totemlinkpvp:Callback("arenaParty2", function(spell)
    --if awful.instanceType2 ~= "arena" then return end 
    if select(2,GetInstanceInfo()) ~= "arena" then return end 
    if not settings.autolink then return end
    if player.buff(443454) then return end --we instant heal now with swiftness--

    local healingtideTotemCheck = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 46 end)
    if healingtideTotemCheck then return end

   local hpThreshhold = 35

    if party2.hp < hpThreshhold and party2.distanceTo(party1) < 7 and not party2.buffFrom(noPanic) then
    elseif party2.hp < hpThreshhold and party2.distanceTo(player) < 7 and not party2.buffFrom(noPanic) then 
        if spell:SmartAoE(party2) then 
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 3 }) end
        end  
    end
end)

 totemlinkpvp:Callback("arenaOnPlayer", function(spell)
    --if awful.instanceType2 ~= "arena" then return end 
    --if select(2,GetInstanceInfo()) ~= "arena" then return end 
    if not settings.autolink then return end
    if player.buff(114893) then return end --stone bulwark--
    if player.buff(443454) then return end --we instant heal now with swiftness--

    local healingtideTotemCheck = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 46 end)
    if healingtideTotemCheck then return end

    local hpThreshholdplayer = 35

    awful.group.loop(function(group)
       if player.hp < hpThreshholdplayer and group.distanceTo(player) < 7 and not player.buffFrom(noPanic) then 
            if spell:SmartAoE(player) then 
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 3 }) end
            end 
        end
    end) 
end)

local totemroottest = awful.Spell(51485, {
    heal = true,
    diameter = 9,
    offsetMin = 2,
    offsetMax = 4,
    circleSteps = 16,
    distChecks = 8,
    minDist = 2,
    maxDist = 4,
    maxHit = 999,
    minHit = 2,
    ignoreEnemies = true, 
    --   sort = function(a, b)
    --     return a.hit > b.hit
    --   end
  })

totemroottest:Callback(function(spell)
    if not settings.testings then return end 
    -- if awful.instanceType2 ~= "arena" then return end 
     --if not settings.autolink then return end
     --if player.buff(443454) then return end --we instant heal now with swiftness--
 
     local healingtideTotemCheck = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 46 end)
     if healingtideTotemCheck then return end
     
     local link = awful.totems.find(function(obj) return obj.id == 53006 and obj.distance < 11 end)
     if link then return end 
 
     awful.fullGroup.loop(function(group)
         if group.buffFrom(noPanic) then return end 

         local abc, abcCount = units.around(group, 10, function(obj) return obj.isPlayer and not obj.cc and not obj.buff(342246) and not obj.dead and obj.friendly end)
         if abc and abcCount >= 2 and group.hp <= 100 then

            --local abc, abcCount = units.around(target, 11)--, function(obj) return not obj.dead end)
            --if abc and abcCount >= 2 then
            print("test")
            --if spell:AoECast(group) then
                if spell:SmartAoE(group) then 
                --if spell:SmartAoE(group) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "tst", texture = spell.id, duration = 3 }) end
                end 
            end 
        --end

     end) 
 end)


totemlinkpvp:Callback("critical", function(spell)
    -- if awful.instanceType2 ~= "arena" then return end 
     if not settings.autolink then return end
    
     local link = awful.totems.find(function(obj) return obj.id == 53006 and obj.distance < 10 end)
     if link then return end 
 
     awful.fullGroup.loop(function(group)
         --local count = #awful.fullGroup.filter(function(unit) return unit.isPlayer and not unit.cc and not unit.buff(342246) and not unit.dead end)  --alter time--
         --if count >= 2 and group.hp < 20 then 
        local abc, abcCount = units.around(group, 10, function(obj) return obj.isPlayer and not obj.cc and not obj.buff(342246) and not obj.dead and obj.friendly end)
        if abc and abcCount >= 2 and group.hp < 20 then
             --if spell:AoECast(group) then
             if spell:SmartAoE(group) then 
                 if settings.alertsmode then awful.alert({ message = awful.colors.red.. "test link critical", texture = spell.id, duration = 3 }) end
             end 
         end
     end) 
 end)

---old one--
totemlink:Callback(function(spell)
    if not settings.autolink then return end
    if player.buff(443454) then return end --we instant heal now with swiftness--
    awful.fullGroup.loop(function(group)
        local count = #awful.fullGroup.filter(function(unit) return unit.isPlayer and not unit.cc end)
        if count >= 2 and group.hp < 30 then 
            if spell:AoECast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end) 
end)

local noNeedSpiritWalker = {
    443454, --swiftness
    79206, --spiritwalker itself
}

spiritwalker:Callback(function(spell)
    awful.fullGroup.loop(function(group)
        if group.hp > 95 then return end --all fine--
        if not settings.autospiritwalker then return end 
        if not player.combat then return end 
        if player.buffFrom(noNeedSpiritWalker) then return end 
        if not player.moving then return end 
        --if player.cooldown(61295) < 1 then return end  --riptide is ready--
        if player.cooldown(73685) < 1 then return end  --unleash life--
        if player.cooldown(428332) < 1 then return end  --primo
        if player.cooldown(198838) < 1 then return end  --totemearthen
        if player.cooldown(108285) < 1 then return end  --totemearthen reset
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end)
end)

ascendance:Callback("pvp", function(spell)
    if player.buff(114052) then return end --ascendance already procced from riptide--
    if not settings.autocds then return end

    local link = awful.totems.find(function(obj) return obj.id == 53006 and obj.distance < 10 end)
    if link then return end 

    local healingtideTotemCheck = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 46 end)
    if healingtideTotemCheck then return end 

    awful.fullGroup.loop(function(group)
        if group.hp < 30 and group.los then
            if group.distanceTo(player) < 40 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "low", texture = spell.id, duration = 1 }) end 
                end 
            end 
        end 
    end)
end)

-- local stuffToTremor = {
--     [360806] = { uptime = 0.5, min = 3 }, --sleepwalk
--     [198898] = { uptime = 0.5, min = 3 }, -- Songofchi
--     [207685] = { uptime = 0.5, min = 3 },  ---sigil fear---
--     [8122] = { uptime = 0.5, min = 3 },  -- Psychic Scream
--     [5484] = { uptime = 0.5, min = 3 }, -- Howl of Terror
--     [5782] = { uptime = 0.5, min = 3 }, -- Fear
--     [6358] = { uptime = 0.5, min = 3 }, -- Seduction
--     [5246] = { uptime = 0.5, min = 3 }, -- Int shout warri
-- }

local stuffToTremor = {
    360806, --sleepwalk
    198898, -- Songofchi
    207685,  ---sigil fear---
    8122,  -- Psychic Scream
    5484, -- Howl of Terror
    5782, -- Fear
    6358, -- Seduction
    5246, -- Int shout warri
}

totemtremor:Callback("pvp", function(spell)
    if not settings.autototem then return end 
    if not player.hasTalent(8143) then return end 
    awful.group.loop(function(group)
        if group.debuffFrom(stuffToTremor) then
            if group.distanceTo(player) <= 34 then --tremor 30 y range -- 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end 
            end
        end 
    end) 
end)

---pre tremor---

local stuffToPreTremor = { 
    360806, --sleep walk
    5782, --fear
}

totemtremor:Callback("preTremorCasts", function(spell)
    if not settings.autopretremor then return end 
    if not settings.autototem then return end 
    if player.cooldown(204336) < 0.1 then return end --grounding rdy--
    if not player.hasTalent(8143) then return end 
        awful.enemies.loop(function(enemy)
        if not enemy.casting then return end
        --if player.cooldown(57994) < 0.1 and not player.silenced then return end  --windshear--
        if enemy.distanceTo(player) > 40 then return end 
        if player.cooldown(57994) < 0.1 and enemy.losOf(player) and not enemy.buffFrom(immunityStuff) then return end --windshear--
        if not tContains(stuffToPreTremor, enemy.castID) then return end
        if tContains(stuffToPreTremor, enemy.castID) and enemy.castRemains < awful.buffer + 0.7 and player.casting then SpellStopCasting() end
            --if tContains(ccStufftoGround, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castRemains < awful.buffer + 0.4 then
            if tContains(stuffToPreTremor, enemy.castID) and enemy.distanceTo(player) < 34 and enemy.castTimeLeft < awful.buffer + 0.6 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Pre Tremor", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
end)

totemtremor:Callback("priestfear", function(spell)
    if not settings.autopretremor then return end 
    if not settings.autototem then return end 
    if not player.hasTalent(8143) then return end 
    if player.ddr < 0.5 then return end  --only half or full ddr drs--
    awful.enemies.loop(function(enemy)
    if enemy.class2 ~= "PRIEST" then return end  
    if enemy.cc or enemy.bcc then return end 
    if not enemy.los then return end 
    --if player.speed > enemy.speed then return end 
    if enemy.cooldown(8122) > 0.5 then return end  --priest fear not rdy--  
        if enemy.distanceTo(player) < 11 then
            return spell:Cast() and awful.alert({ message = awful.colors.red.. "Pre Tremor", texture = spell.id, duration = 1 })
        end
    end)
end)

totemtremor:Callback("warrileapfear", function(spell)
    if not settings.autopretremor then return end 
    if not settings.autototem then return end 
    if not player.hasTalent(8143) then return end 
    if player.ddr < 0.5 then return end  --only half or full ddr drs--
    awful.enemies.loop(function(enemy)
    if enemy.class2 ~= "WARRIOR" then return end  
    if enemy.cc or enemy.bcc then return end 
    if not enemy.los then return end 
    if enemy.cooldown(5246) > 0.5 then return end  --priest fear not rdy--  
        if enemy.distanceTo(player) < 11 and enemy.used(6544) then
            return spell:Cast() and awful.alert({ message = awful.colors.red.. "Pre Tremor", texture = spell.id, duration = 1 })
        end
    end)
end)

totemroot:Callback("pvp", function(spell)
    if not settings.autoroot then return end
    if player.used(355580, 2) then return end --static totem used--
    awful.enemies.loop(function(enemy) 
        if enemy.buff(227847) then return end --bladestorm--
        if enemy.dist > 40 then return end
        --if enemy.class == "Druid" then return end --if not druid--
        if enemy.role ~= "melee" then return end -- if not meele then dont --
        if enemy.buff(81782) then return end --dome buff--
        --if not enemy.los then return end --enemy is not in sight for casting--
        if not spell:Castable(enemy) then return end --is castable like when he has immunities--
        if enemy.rootDR <= 1 then return end --only rooting him when he is on half or full dr--
        if enemy.cds and enemy.target.isUnit(player) then ---enemy has offensive CDs and targeting me---
            if spell:SmartAoE(enemy) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end)
end)

totemroot:Callback("pvpOnEnemyHealer", function(spell)
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autoroot then return end
    awful.enemies.loop(function(enemy) 
        if enemyHealer.dist > 40 then return end
        if not enemyHealer.los then return end 
        if enemyHealer.buff(1044) then return end --freedom --
        if player.target.isUnit(enemyHealer) then return end --we go on healer--
        --if not enemy.los then return end --enemy is not in sight for casting--
        --if not spell:Castable(enemy) then return end --is castable like when he has immunities--
        if enemyHealer.rootDR <= 0.5 then return end --only rooting him when he is on half or full dr--
        if not enemy.losOf(enemyHealer) then ---enemy has offensive CDs and targeting me---
            if spell:SmartAoE(enemyHealer) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "root Healer LoS", texture = spell.id, duration = 2 }) end
            end 
        end
    end)
end)

totemroot:Callback("pvpPets", function(spell)
    if not settings.autoroot then return end
    awful.enemies.loop(function(enemy) 
        if enemy.class2 ~= "HUNTER" then return end -- if not meele then dont --
        awful.pets.loop(function(pet)
            if pet.rootDR < 0.5 then return end --only rooting him when he is on half or full dr--
            if not pet.los then return end 
            if enemy.used(19574, 5) then ---bestial wrath--
                if spell:SmartAoE(pet) then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "root BM pets", texture = spell.id, duration = 1 }) end
                end 
            end
        end)
    end)
end)

--local totemrootStopDrink = NewSpell(51485, { diameter = 9, offsetMin = 2, offsetMax = 7, })

local totemrootStopDrink = NewSpell(51485, { 
    effect = "magic", 
    targeted = false,
    circleSteps = 24,
    distChecks = 12,
    radius = 9, 
    minDist = 4.5, 
    maxDist = 7.5,
    maxHit = 999, -- should hit NO ONE in bcc
    ignoreFriends = true, -- ignore friends in filter func for performance reasons
    -- filter = function(obj, predDist, position)

    --   -- otherwise hit as many ppl as possible 
    --   if predDist < 6.5 and predDist > 5.5 then
    --     return true
    --   end

    -- end,
    -- sort = function(a, b)
    --   return a.hit > b.hit
    -- end
  })

totemrootStopDrink:Callback(function(spell)
    if awful.instanceType2 ~= "arena" then return end
    if not settings.autototem then return end
    if not enemyHealer.combat and enemyHealer.buff("Drink") then
    --return spell:SmartAoE(enemyHealer) and awful.alert({ message = awful.colors.red.. "Root Enemy Healer to stop Drink", texture = spell.id, duration = 2 })
        --if spell:AoECast(enemyHealer) then
        if spell:SmartAoE(group) then 
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "stop drink", texture = spell.id, duration = 1 }) end
        end 
    end 
end)

ancestralguidance:Callback("twoCDs", function(spell)
    if not settings.autocds then return end

    local link = awful.totems.find(function(obj) return obj.id == 53006 and obj.distance < 10 end)
    if link then return end 

    local healingtideTotemCheck = awful.totems.find(function(obj) return obj.id == 59764 and obj.distance < 46 end)
    if healingtideTotemCheck then return end 

    awful.fullGroup.loop(function(group)
        if group.buffFrom(BigDef) then return end --we already have big def up--
        if group.buffFrom(noPanic) then return end --we already have big def up--
        local total, melee, ranged, cooldowns = group.v2attackers()
        if cooldowns > 1 then
            if group.distanceTo(player) > 40 then return end 
            if group.hp > 50 and player.buff(443454) then return end --we have insta big heal now--
            if group.hp < 70 then
                awful.enemies.loop(function(enemy)
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                    end 
                end)
            end
        end 
    end)
end)

ancestralguidance:Callback("onMe", function(spell)
    if not settings.autocds then return end
    if player.buffFrom(BigDef) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.hp > 60 then return end 
    local total, melee, ranged, cooldowns = player.v2attackers()
        if cooldowns > 1 then
            awful.enemies.loop(function(enemy) 
                if not enemy.isHealer and enemy.los and enemy.target.isUnit(player) and enemy.distanceTo(player) < 40 then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        end
end)

local stuffToCleanseHunter = {
    356723, --silence shot hunter
    356727, --silence shot hunter
}

totempoisoncleanse:Callback("hunter", function(spell)
    awful.fullGroup.loop(function(group)
    if not player.hasTalent(383013) then return end 
    if not group.debuffFrom(stuffToCleanseHunter) then return end
        if group.distanceTo(player) < 30 then --cleanse 30 y range -- 
        return spell:Cast(player) and awful.alert({ message = awful.colors.blue.. "Silence Shot", texture = spell.id, duration = 1 }) 
        end
    end)
end)

local stuffToCleanseAssa = {
    360194, -- deathmark
    319504, -- shiv
}

totempoisoncleanse:Callback("assa", function(spell)
    awful.fullGroup.loop(function(group)
    if not player.hasTalent(383013) then return end 
    if not group.debuffFrom(stuffToCleanseAssa) then return end
        if group.distanceTo(player) < 30 then --cleanse 30 y range -- 
        return spell:Cast(player) and awful.alert({ message = awful.colors.blue.. "Assa Go", texture = spell.id, duration = 1 }) 
        end
    end)
end)

local drinks = awful.Item{113509, 227318, 227310, 227309, 227317}

drinks:Update(function(item)
    if player.moving then return end
    if not item:Usable(player) then return end
    if player.combat then return end
    if player.buff("Drink") or player.buff("Refreshment") or player.buff(452384) or player.buff(167152) then return end
    if drink then
        return item:Use()
    end
end)

function drinkEnd()
    if player.manaPct < 100 then return end 
    if player.manaPct >= 100 or player.combat then 
        drink = false 
    end 
end

totemstun:Callback("pvp", function(spell)
    if not settings.autostuntotem then return end
    awful.group.loop(function(group)
        if not group.los then return end 
        if group.class2 == "DEATHKNIGHT" and group.used(207167) then  --dk binding sleet--
            if spell:AoECast(group) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "dk setup", texture = spell.id, duration = 1 }) end
            end 
        end 
    end) 
end)

unleashshield:Callback("ourDKburst", function(spell)
    if not settings.autounleashshield then return end
    awful.group.loop(function(group)
        if group.class2 ~= "DEATHKNIGHT" then return end --only on our dk--
        if group.used(383269, 3) or group.used(315443, 3) then --our dk used abo for burst-- both ids
            awful.enemies.loop(function(enemy) 
                if group.target.isUnit(enemy) and enemy.los then 
                    if spell:Cast(enemy) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "on DK burst", texture = spell.id, duration = 1 }) end
                    end 
                end 
            end) 
        end
     end)
end)

unleashshield:Callback("ourGroupBurstAndStun", function(spell)
    if not settings.autounleashshield then return end
    awful.group.loop(function(group)
        if group.cds or group.used(102560, 4) or group.used(102543, 4) or group.used(19574, 4) or group.used(375087, 4) or group.used(231895, 4) or group.used(107574, 4) or group.used(121471, 4) then --our dk used abo for burst-- both ids
            awful.enemies.loop(function(enemy) 
                if group.target.isUnit(enemy) and enemy.los and enemy.stunned then 
                    if spell:Cast(enemy) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "group bursts", texture = spell.id, duration = 1 }) end
                    end 
                end 
            end) 
        end
     end)
end)

awful.RegisterMacro("lasso", 1)

lasso:Callback("macro", function(spell)
    if target.immuneMagicDamage then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if not spell:Castable(target) then return end
    if target.dead then return end
    if target.bcc then return end
    if target.friendly then return end
    if target.dist > 40 then return end
    if target.stunDR < 0.25 then return end 
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

-- local flags = {
--     ["Alliance Flag"] = true,  --156621
--     ["Horde Flag"] = true, ---156618
-- }
-- local flagDropTime = 0
-- local function flagActions()
-- if not settings.autopickupflags then return end 
--   if awful.instanceType2 ~= "pvp" then return end
--     --if fullGroup.find(function(e) return (e.role == "tank" and e.dist < 20) end) then return end
--   if awful.time > flagDropTime then
--         awful.objects.loop(function(obj)
--             if not flags[obj.name] then return end
--             if obj.dist > 5 then return end
--             obj:interact()
--         end)
--   end
-- end

totemcounterstrike:Callback(function(spell)
    awful.enemies.loop(function(unit)
        if not unit.isPlayer then return end 
        if unit.distance > 60 then return end 
        if unit.role ~= "melee" then return end --if not unit.role == "meele" then return end  same
        if unit.distanceTo(player) > 40 then return end --unit is over 10 m away
        if unit.cds then ---enemy has offensive CDs and targeting anyone in my group---
        return spell:Cast(player) and awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 })
        end
     end)
end)


local reflectStuff = { 212295, 23920 }
local immuneBuffHex = { 
    212295, --netherward
    48707, --ams
    47585, --dispersion
    23920, --reflect
    409293, --burrow
    642, --bubble
    204018, --spellwarding
    45438, --iceblock--
    186265, --turtle--
    33786, --cyclone
    353319, --monk revival 
    408558, --priest immunity fade
    8178, --grounding
    421453, --ult penance--
}

function StopCastingInImmunities()
    if not player.casting then return end 
    awful.enemies.loop(function(enemy)
    if player.castID == hex.id and player.castTarget.isUnit(enemy) and enemy.immuneMagicDamage and enemy.distanceTo(player) < 40 then SpellStopCasting() end 
    if player.castID == 51514 and player.castTarget.isUnit(enemy) and enemy.immuneMagicDamage and enemy.distanceTo(player) < 40 then SpellStopCasting() end 

    if player.castID == hex.id and player.castTarget.isUnit(enemy) and enemy.buffFrom(reflectStuff) and enemy.distanceTo(player) < 40  then SpellStopCasting() end 
    if player.castID == 51514 and player.castTarget.isUnit(enemy) and enemy.buffFrom(reflectStuff) and enemy.distanceTo(player) < 40  then SpellStopCasting() end 

    if player.castID == hex.id and player.castTarget.isUnit(enemy) and enemy.buffFrom(immuneBuffHex) and enemy.distanceTo(player) < 40 then SpellStopCasting() end 
    if player.castID == 51514 and player.castTarget.isUnit(enemy) and enemy.buffFrom(immuneBuffHex) and enemy.distanceTo(player) < 40 then SpellStopCasting() end 

    if player.castID == hex.id and enemy.buff(8178) and enemy.distanceTo(player) < 40 then SpellStopCasting() end  ---grounding---
    if player.castID == 51514 and enemy.buff(8178) and enemy.distanceTo(player) < 40 then SpellStopCasting()  end  ---grounding---

    if player.castID == hex.id and player.castTarget.isUnit(enemy) and enemy.distanceTo(player) < 40 and enemy.used(32379, 1) then SpellStopCasting() end  --SWD--
    if player.castID == 51514 and player.castTarget.isUnit(enemy) and enemy.distanceTo(player) < 40 and enemy.used(32379, 1) then SpellStopCasting() end --SWD--
    end)
end

---actor---
restoration:Init(function()

    --totemroottest()
    --if settings.testings then return end

    if awful.player.mounted then return end

    if drink == true then awful.alert({ message = awful.colors.cyan.. "Drink", texture = 452384, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    drinks()
    drinkEnd()
    if drink == true then return end 
    StopCastingInImmunities()

    --totemgrounding("trap")
    totemgrounding()
    totemgrounding("damagespells")
    totemgrounding("CDs")
    totemgrounding("harpoonTrap")
    totemgrounding("palaHOJ")
    thunderstorm()

    if holdnow == true then awful.alert({ message = awful.colors.red.. "HOLDING GROUNDING", texture = 204336, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0 }) end
    if holdnow == true then return end 

    windshear("casts")
    windshear("vsBoomkins")
    windshear("channel")
    windshear("channelotherkicks")
    windshear("otherchannels")
    windshear("nottakingthefckID")
    windshear("firebreath")
    windshear("firebreathChannel")
    windshear("disintigrate")

    if awful.player.buff(2645) then return end --ghost wolf--

   -- healthstone:grab()
    healthStone()

    if awful.MacrosQueued["lasso"] then 
        lasso("macro")
    end

    if awful.player.castID == 305483 then return end --lasso--

    skyfuryBuff()
    earthlivingweapon()
    watershield()

    if awful.instanceType2 == "none" and not player.combat then return end 

    if holdnow == true then awful.alert({ message = awful.colors.red.. "HOLDING GROUNDING", texture = 204336, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0 }) end
    if holdnow == true then return end 

    WasCastingCheck()

    if settings.autofocus then
    awful.AutoFocus() 
    end 

    earthshield("onmeOutOfCombat")
    spiritwalker()

    if settings.mode == "pvpmode" then

    earthshield("PVPonDPS")
    earthshield("swap")
    earthshield("PVPonDPS3sprep")

    astralshift("nobigdefs")
    astralshift("pvpEnemyCds")
    astralshift("inBGs")
    astralshift("inBGsLow")
    burrow("BGslow")
    burrow("low")
    totemStoneBulwark("emergency")
    totemlinkpvp()
    totemlinkpvp("arenaParty1")
    totemlinkpvp("arenaParty2")
    totemlinkpvp("arenaOnPlayer")
    totemtremor("preTremorCasts")
    totemtremor("priestfear")
    totemtremor("warrileapfear")
    totemstun("PVP")
    lavaburst("ProccLOW")

    totemtremor("pvp")
    dispel("curses")
    dispel("debuffs")

    if awful.prep then return end 

    greaterpurge("purge")
    greaterpurge("mindcontrol")
    totemcounterstrike()

    ancestralSwiftness()
    --totemlink("critical")
    primowave("pvp")
    healingwave("PVP-Swiftness")
    healingwave("PVP-SwiftnessArena")
    totemhealingtide("pvpEnemyCds")
    totemhealingtide("pvp")
    --totemlink()
    ascendance("pvp")
    ancestralguidance("twoCDs")
    ancestralguidance("onMe")
    earthshield("onme")
    earthshield("ReactiveWarding")
    earthshield("ReactiveWardingPlayer")

    if awful.player.castID == 305483 then return end --lasso--
    
    healingsurge("lowestpvpSpiritWalker")
    healingsurge("pvpSpiritWalker")

    totempoisoncleanse("hunter")
    totempoisoncleanse("assa")
    unleashshield("ourDKburst")
    unleashshield("ourGroupBurstAndStun")

    hex("Healer")
    --hex("testHealer")
    hex("HealerSpiritWalker")
    --hex("offCC")
    totemrootStopDrink()

    unleashlife("pvp")
    healingsurge("pvpProcc")
    riptide("pvp")
    riptide("arenaBuff")
    totemroot("pvp")
    totemroot("pvpOnEnemyHealer")
    totemroot("pvpPets")
    totemicrecall()
    totemearthen("pvp")
    totemearthen("pvpVSDKs")
    totemearthen("doublemelees")
    totemhealingstream("pvp")
    healingwave("pvpManaEfficient")
    healingsurge("pvp")
    totemmana()

    lavaburst("Procc")
    flameshock("spread")

    elseif settings.mode == "pvemode" then

    totemlink("PVE")
    astralshift("PVE")
    totemStoneBulwark("PVE")
    earthshield("onme")

    totemhealingtide("pveTwolow")

    ancestralguidance("PVE")

    healingwave("PVE-Swiftness")
    totemhealingstream()
    healingrainTotemic("PVEtank")
    healingrainTotemic("PVE")
    healingrainTotemic("PVEonPlayer")
    riptide("PVE")
    dispel("PVE")
    windshearPVE("PVE")
    downpour()
    chainheal("PVEtidebringer")
    chainheal("PVEtotemicbuff")
    unleashlife("PVE")
    primowave("pve")
    ancestralSwiftness("pve")
    natureswiftSwiftness("pve")
    ascendance("pveOnelow")
    totemearthen("pve")
    earthshield("onTank")
    earthshield("onTankOutOfCombat")
    earthshield("onTankRaid")
    healingsurge("PVEcastingTank")
    healingrain("PVE")
    totemicrecall("PVE")
    totempoisoncleanse("PVE")
    healingwave("HasteDebuffMPlus")
    chainheal("PVEcasting")
    healingsurge("PVEcasting")
    totemmana("PVE")
    healingwave("PVEcasting")
    spiritwalker("PVE")
    earthshield("PVEonme")
    lavaburst("PVEprocc")
    flameshock("PVE")
    chainlight("PVE")
    totemwindrush("PVE")

    end

end)
