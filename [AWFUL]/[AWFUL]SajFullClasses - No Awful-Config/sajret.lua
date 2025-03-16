local Unlocker, awful, sajret = ...
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3, party1, party2 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3, awful.party1, awful.party2



sajret.paladin = {}
sajret.paladin.retribution = awful.Actor:New({ spec = 3, class = "paladin" })

local retribution = sajret.paladin.retribution

if player.class == "Paladin" and player.spec == "Retribution" then
    awful.print("[|cffff00ffWelcome|r]")
    awful.print("[|cffff00ffSajs Retribution loaded and enabled|r]")
    awful.print("[|cffff00ffEnjoy|r]")
end

if player.spec ~= "Retribution" then return end

local min, max, bin, cos, sin = min, max, awful.bin, math.cos, math.sin

local cmd = awful.Command("saj", true)
sajret.cmd = cmd

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

-- slap this into your init or some other function that runs onupdate
--WasCastingCheck()

-- then in your spell callback, slap this in
--if wasCasting[spell.id] then return end


----- FREE SUBS -----

function authFuhr()
    if awful.__username == "Fuhr" then
        uCanPlay = true 
    end
end

function authSascha()
    if awful.__username == "Sasha" then
        uCanPlay = true 
    end
end

function authPrizrak()
    if awful.__username == "small_prizrak" then
        uCanPlay = true 
    end
end

function authbrokencyde()
    if awful.__username == "brokencyde" then
        uCanPlay = true 
    end
end

function authSophex() ---LIFETIME USER----
    if awful.__username == "glassjawx" then
        uCanPlay = true 
    end
end

function authBiggelz() ----LIFETIME USER----
    if awful.__username == "Hansyolo" then
        uCanPlay = true 
    end
end

function authBrainz() ----LIFETIME USER----
    if awful.__username == "Brainz" then
        uCanPlay = true 
    end
end

function authPapaflop() ---LIFETIMER USER--- 
    if awful.__username == "Flop" then
        uCanPlay = true 
    end
end

 --------------- --------------- --------------- --------------- UI --------------- --------------- --------------- ---------------

local settings = sajret.settings

local yellow = {245, 235, 55, 1}
local white = {255, 255, 255, 1}
local dark = {21, 21, 21, 0.45}
local orange = {255, 140, 0, 255}
local red = {255, 0, 0, 255}
local brown = {139, 71, 38, 1}
local green = {0, 255, 0, 255}
local black = {0, 0, 0, 1}
local yellowcool = {255, 255, 153, 1}
local redcool = {139, 90, 43, 0.45}
local redtwo = {226, 74, 74, 1}
local redtest = {247, 115, 115, 1}
local greencool = {152, 251, 152, 200}
local browncool = {255, 165, 79, 200}
local newgreencool = {0, 255, 0, 200}
local purple = {102, 0, 204, 1}
local hellpurple = {204, 153, 255, 1}
local palacolor = {245, 140, 186, 1}
local palatest = {140, 80, 149, 1}

local gui, settings = awful.UI:New("sajUI", {
 title = "      SAJ     ",
 show = true, -- show not on load by default
 colors = {
     --color of our ui title in the top left
     title = palatest,
     --primary is the primary text color
     --primary = hellpurple,
     primary = palacolor, 
     --accent controls colors of elements and some element text in the UI. it should contrast nicely with the background.
     --accent = hellpurple,
     accent = palacolor,
     background = dark,
 }
})

local sajUI = gui:Tab("Mode")

sajUI:Text({
    text = awful.textureEscape(231895, 25, "0:0") .. awful.colors.paladin .. " Sajs Retribution",
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
		{ label = awful.textureEscape(2022762, 22, "0:01") .. "  PVP", value = "pvpmode", tooltip = "Choose if you play PVP", default = true },
		{ label = awful.textureEscape(1450787, 22, "0:01") .. "  PVE", value = "pvemode", tooltip = "Choose if you play PVE" },
	},
	placeholder = "PRESS HERE TO SELECT MODE",
	header = "Mode:",
})

sajUI:Checkbox({
    text = awful.textureEscape(3684828, 22, "0:13") .. "  Drawings",
    var = "drawings", -- checked bool = settings.drawings   
    default = true,
    tooltip = "Drawings for like Trap, LoS and stuff" 
})

sajUI:Checkbox({
    text = awful.textureEscape(895885, 22, "0:13") .. "  Alerts enabled",
    var = "alertsmode", -- checked bool = settings.alertsmode
    default = true,
    tooltip = "Alerts in the middle of ur screen, recommended when playing with my Macros" 
})

sajUI:Checkbox({
    text = awful.textureEscape(1357795, 22, "0:13") .. "  Burst Alerts enabled",
    var = "bigalertsmode", -- checked bool = settings.bigalertsmode
    default = true,
    tooltip = "Burst Alerts will be shown in the middle of ur screen, so you know when rotation is bursting" 
})

sajUI:Checkbox({
    text = awful.textureEscape(132284, 22, "0:13") .. "  Drawings for Classes",
    var = "classdrawings", -- checked bool =  
    default = true,
    tooltip = "Enemy classes will be shown next to the characters" 
})

sajUI:Checkbox({
    text = awful.textureEscape(1394971, 22, "0:13") .. "  Drawings for Range",
    var = "drawingsrange", -- checked bool = 
    default = false,
    tooltip = "Drawings for melee range" 
})

sajUI:Checkbox({
    text = awful.textureEscape(1320372, 22, "0:13") .. "  Icons above Bursting Enemies",
    var = "burstdrawings", -- checked bool =  
    default = false,
    tooltip = "Drawing Icons above Players who are bursting (BETA)" 
})

local sajUI = gui:Tab("Control")

sajUI:Text({
    text = awful.textureEscape(231895, 25, "0:0") .. awful.colors.paladin .. " Sajs Retribution",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(853, 22, "0:13") .. "  Auto Stun ",
    var = "autostun", -- checked bool = settings.autostun
    default = true,
    tooltip = "Using auto stuns" 
})

sajUI:Dropdown({
	var = "stunmode",
	tooltip = "Choose Stun Handling",
	options = {
		{ label = awful.textureEscape(853, 22, "0:01") .. "  target", value = "stuntarget", tooltip = "Choose if you are going to stun the target" },
		{ label = awful.textureEscape(853, 22, "0:01") .. "  healer", value = "stunhealer", tooltip = "Choose if you are going to stun the healer", default = true },
        { label = awful.textureEscape(853, 22, "0:01") .. "  shuffle (mixed)", value = "mixedstun", tooltip = "Choose if you want to have it mixed, for example in solo shuffle" },
	},
	placeholder = "PRESS HERE TO SELECT STUN MODE",
	header = "Stun Handling:",
})

sajUI:Checkbox({
    text = awful.textureEscape(115750, 22, "0:13") .. "  Auto Blinding Light ",
    var = "autoblind", -- checked bool = settings.autostun
    default = true,
    tooltip = "Using auto blinding light, for example to CC enemy Healer or to peel in critical moments - use Rep when playing with Dotclasses else it will purge them" 
})

sajUI:Checkbox({
    text = awful.textureEscape(190784, 22, "0:13") .. "  Auto Divine Steed ",
    var = "autosteed", -- checked bool = settings.autosteed
    default = true,
    tooltip = "Using Auto Steed" 
})

sajUI:Checkbox({
    text = awful.textureEscape(96231, 22, "0:13") .. "  Auto Kick   ",
    var = "autokick", -- checked bool = if not settings.autokick then return end
    default = true,
    tooltip = "Auto Kick" 
})



local sajUI = gui:Tab("Offensive")

sajUI:Text({
    text = awful.textureEscape(231895, 25, "0:0") .. awful.colors.paladin .. " Sajs Retribution",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Checkbox({
    text = awful.textureEscape(236263, 22, "0:13") .. "  Auto Burst ",
    var = "autoburst", -- checked bool = settings.autoburst
    default = true,
    tooltip = "Will Auto burst, if you want to use it manual check macro section." 
})

sajUI:Checkbox({
    text = awful.textureEscape(402482, 22, "0:13") .. "  (BGs) Auto Pickup Flags",
    var = "autopickupflags", -- checked bool =   if not settings.autopickupflags then return end 
    default = true,
    tooltip = "Will Auto Pickup Flags in BGs" 
})



local sajUI = gui:Tab("Defensive")

sajUI:Text({
    text = awful.textureEscape(231895, 25, "0:0") .. awful.colors.paladin .. " Sajs Retribution",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Slider({
    text = awful.textureEscape(538745, 22, "0:3") .. "Healthstone",
    var = "healthstoneHP",
    min = 0,
    max = 100,
    step = 1,
    default = 30,
    valueType = "%",
    tooltip = "The routine will use healthstone at %, however there is still logic to not use it in certain scenarios"
})

sajUI:Checkbox({
    text = awful.textureEscape(19750, 22, "0:13") .. "  Auto Heal ",
    var = "autoheal",
    default = true,
    tooltip = "Will auto heal" 
})

sajUI:Checkbox({
    text = awful.textureEscape(403876, 22, "0:13") .. "  Auto Defensives ",
    var = "autodef",
    default = true,
    tooltip = "Will auto use defensives" 
})

sajUI:Checkbox({
    text = awful.textureEscape(1022, 22, "0:13") .. "  Auto BOPs ",
    var = "autobop",
    default = true,
    tooltip = "Will auto bops" 
})

sajUI:Checkbox({
    text = awful.textureEscape(1022, 22, "0:13") .. "  Auto BOP Karma ",
    var = "autobopKarma",
    default = true,
    tooltip = "Will auto bop Karma from Enemy WW. We won't use it when our target is a paladin and has Bubble/Bop ready." 
})

sajUI:Checkbox({
    text = awful.textureEscape(210256, 22, "0:13") .. "  Auto Sanctuary ",
    var = "autoSanctuary",
    default = true,
    tooltip = "Will auto Sanctuary to get ur Healer out of CCs" 
})

sajUI:Checkbox({
    text = awful.textureEscape(1044, 22, "0:13") .. "  Auto Freedom ",
    var = "autofreedom",
    default = true,
    tooltip = "Will auto freedom" 
})

sajUI:Checkbox({
    text = awful.textureEscape(633, 22, "0:13") .. "  Auto Lay on Hands ",
    var = "autLoH", -- checked bool = settings.autLoH
    default = true,
    tooltip = "Using auto LoH" 
})

local sajUI = gui:Tab("Macros")

sajUI:Text({
    text = awful.textureEscape(231895, 25, "0:0") .. awful.colors.paladin .. " Sajs Retribution",
    header = true,
    size = 12,
    paddingBottom = 7,
})

--damit abstand ist--
sajUI:Text({
    text = "  "
})

sajUI:Text({
    text = "|cfffff394/awfulusername toggle",
    size = 12,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfffff394/sajui",
    size = 12,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfffff394/saj bigburst",
    size = 12,
    paddingBottom = 5,
})

sajUI:Text({
    text = "|cfffff394/saj smallburst",
    size = 12,
    paddingBottom = 5,
})


--------------- --------------- --------------- --------------- SPELL LIST --------------- --------------- --------------- ---------------

awful.Populate({

    ---DMG---
    judgement = awful.Spell(275773, { damage = "magic", ignoreLoS = false }),
    crusader = awful.Spell(35395, { damage = "physical", ignoreLoS = false }),
    hammerofwrath = awful.Spell(24275, { damage = "magic", ignoreLoS = false }),
    bladeofjustice = awful.Spell(184575, { damage = "magic", ignoreLoS = false }),
    divinestorm = awful.Spell(53385, { damage = "magic", ignoreLoS = false }),
    finalverdict = awful.Spell(383328, { damage = "magic", ignoreLoS = false }),
    --wakeofashes = awful.Spell(255937, { damage = "magic", ignoreLoS = false, ignoreRange = true }), 

    --OTHER STUFF--
    sanctuary = awful.Spell(210256, { ignoreLoS = false }),
    spellwarding = awful.Spell(204018, { ignoreLoS = false }),
    shieldofvengeance = awful.Spell(184662),
    devoaura = awful.Spell(465),
    --crusade = awful.Spell(231895),

}, retribution, getfenv(1))


--HEAL--
local flashoflight = NewSpell(19750, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })
local holylight = NewSpell(82326, { heal = true, ignoreLoS = false, ignoreMoving = false, ignoreFacing = true })
local holyshock = NewSpell(20473, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })
local bestowfaith = NewSpell(223306, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })
local divinetoll = NewSpell(375576, { ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })
local lightofdawn = NewSpell(85222, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = false })
local layonhands = NewSpell(633, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })
local wordofglory = NewSpell(85673, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })
local barrieroffaith = NewSpell(148039, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })

local wakeofashes = NewSpell({ 255937, 427453, 427441, 429826 }, { damage = "magic", ignoreRange = true })

--CDS--
local avengingcrusader = NewSpell(216331)
local crusade = NewSpell(231895)
local divinesteed = NewSpell(190784)
local divinefavor = NewSpell(210294) --immun for next cast--
local cleanse = NewSpell(4987, { ignoreFacing = true, ignoreMoving = true })
local finalreckoning = NewSpell(343721, { damage = "magic", diameter = 2, offsetMin = 0, offsetMax = 0, })
--local hammeroflight = NewSpell(427453)
--local hammeroflightTest = NewSpell(255937)
--local hammeroflight = NewSpell({ 427453, 255937 }, { damage = "magic" })

--BLESSINGS--
local bop = NewSpell(1022)
local sac = NewSpell(6940)
local freedom = NewSpell(1044)
local blessingofspring = NewSpell(388013)
local blessingofsummer = NewSpell(388007)
local blessingofautumn = NewSpell(388010)
local blessingofwinter = NewSpell(388011)

--CCs--
local hoj = NewSpell(853, { effect = "magic", cc = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })
local rebuke = NewSpell(96231, { damage = "physical", ignoreLoS = false, ignoreMoving = true, ignoreFacing = false }) --kick--
local blindinglight = NewSpell(115750, { effect = "magic", cc = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })


--DEFENSIVES--
local divineshield = NewSpell(642, { ignoreFacing = true, ignoreLoS = true }) --bubble--
local divineprotection = NewSpell(498, { beneficial = true, ignoreFacing = true }) --wall--
local auramastery = NewSpell(31821)
local taunt = NewSpell(62124, { ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })




--------------- --------------- --------------- --------------- DRAWINGS --------------- --------------- --------------- ---------------

-- melee range, single target + RANGE --
awful.Draw(function(draw)
    if not settings.drawingsrange then return end 
    draw:SetWidth(2.5)
    if target.exists then
        local px, py, pz = player.position()
        local d, a = 21, 140
        draw:SetColor(255, 100, 100, 110)
        if target.arc(d, a, player) then
        draw:SetColor(100, 255, 100, 110)
        end
        draw:Arc(px, py, pz, d, a, player.rotation)
    end
end)

---If i need a text somewhere---
-- local AwfulFont = awful.createFont(10, "OUTLINE")
-- awful.Draw(function(draw)
--     if not settings.drawingsrange then return end 
--     --draw:SetWidth(2.5)
--     if target.exists then
--         draw:SetColor(255, 255, 0)
--         local px, py, pz = target.position()
--         draw:Text("Target", AwfulFont, px, py, pz)
--     end
-- end)

----ICONS----
local hojicon = awful.textureEscape(853, 45, "0:16")

---Stun on Target--
awful.Draw(function(draw)
    if hoj.cd > 1 then return end 
    if not settings.drawings then return end
    if target.stunned then return end  
    if target.stunDR == 1 then 
        if target.exists and not target.friendly then
            --draw:SetColor(255, 255, 0)
            local px, py, pz = target.position()
            --draw:Texture(texttest, px, py, pz, alphaA)
        -- draw:Text(texttest,"GameFontHighlight", px, py, pz)
        draw:Text(hojicon, "GameFontHighlight", px, py, pz+5)
        end
    end  
end)

local AwfulFont = awful.createFont(10, "OUTLINE")

---Stun on Target Text--
awful.Draw(function(draw)
    if hoj.cd > 1 then return end 
    if not settings.drawings then return end
    if target.stunned then return end  
    if target.stunDR == 1 then 
        if target.exists and not target.friendly then
            --draw:SetColor(255, 255, 0)
            local px, py, pz = target.position()
            --draw:Texture(texttest, px, py, pz, alphaA)
        -- draw:Text(texttest,"GameFontHighlight", px, py, pz)
        draw:Text("Target stunable", AwfulFont, px, py, pz)
        end
    end  
end)


---Stun on enemyHealer---
awful.Draw(function(draw)
    if hoj.cd > 1 then return end 
    if not settings.drawings then return end
    if enemyHealer.stunned then return end 
    if enemyHealer.stunDR == 1 then 
        if enemyHealer.exists then
            --draw:SetColor(255, 255, 0)
            local px, py, pz = enemyHealer.position()
            --draw:Texture(texttest, px, py, pz, alphaA)
        -- draw:Text(texttest,"GameFontHighlight", px, py, pz)
        draw:Text(hojicon, "GameFontHighlight", px, py, pz+5)
        end
    end 
end)

---Stun on enemyHealer Text---
awful.Draw(function(draw)
    if hoj.cd > 1 then return end 
    if not settings.drawings then return end
    if enemyHealer.stunned then return end 
    if enemyHealer.stunDR == 1 then 
        if enemyHealer.exists then
            --draw:SetColor(255, 255, 0)
            local px, py, pz = enemyHealer.position()
            --draw:Texture(texttest, px, py, pz, alphaA)
        -- draw:Text(texttest,"GameFontHighlight", px, py, pz)
        draw:Text("Healer stunable", AwfulFont, px, py, pz)
        end
    end 
end)


local blindicon = awful.textureEscape(115750, 45, "0:16")

--Blind on enemyHealer--
-- awful.Draw(function(draw)
--     if not settings.drawings then return end
--     if enemyHealer.ddr == 1 then 
--         if enemyHealer.exists then
--         local px, py, pz = enemyHealer.position()
--         draw:Text(blindicon, "GameFontHighlight", px, py, pz+7)
--         end
--     end 
-- end)


-- --Test on Target--
-- awful.Draw(function(draw)
--     if not settings.drawings then return end
--     --if target.stunned then return end  
--     if target.ddr == 1 then 
--         if target.exists and not target.friendly then
--             --draw:SetColor(255, 255, 0)
--             local px, py, pz = target.position()
--             --draw:Texture(texttest, px, py, pz, alphaA)
--         -- draw:Text(texttest,"GameFontHighlight", px, py, pz)
--         draw:Text(blindicon, "GameFontHighlight", px, py, pz+5)
--         end
--     end  
-- end)

---class drawings---
-- awful.Draw(function(draw)
--     if not settings.classdrawings then return end
--     local icon = awful.textureEscape(626006, 16, "0:2")
--     awful.enemies.loop(function(enemy)
--         local ex, ey, ez = enemy.position()
--             if enemy.class2 == "SHAMAN" then 
--                 draw:SetColor(0, 112, 221, 225) 
--                 icon = awful.textureEscape(626006, 16, "0:2")  
--             elseif enemy.class2 == "ROGUE" then 
--                 draw:SetColor(255, 244, 104, 225)  
--                 icon = awful.textureEscape(626005, 16, "0:2") 
--             elseif enemy.class2 == "WARRIOR" then 
--                 draw:SetColor(198, 155, 109, 225) 
--                 icon = awful.textureEscape(626008, 16, "0:2") 
--             elseif enemy.class2 == "WARLOCK" then 
--                 draw:SetColor(135, 136, 238, 225) 
--                 icon = awful.textureEscape(626007, 16, "0:2")  
--             elseif enemy.class2 == "DRUID" then 
--                 draw:SetColor(255, 124, 10, 225) 
--                 icon = awful.textureEscape(625999, 16, "0:2")  
--             elseif enemy.class2 == "PRIEST" then 
--                 draw:SetColor(255, 255, 255, 225) 
--                 icon = awful.textureEscape(626004, 16, "0:2")  
--             elseif enemy.class2 == "PALADIN" then 
--                 draw:SetColor(244, 140, 104, 225) 
--                 icon = awful.textureEscape(626003, 16, "0:2")  
--             elseif enemy.class2 == "MAGE" then 
--                 draw:SetColor(63, 199, 235, 225) 
--                 icon = awful.textureEscape(626001, 16, "0:2")  
--             elseif enemy.class2 == "DEATHKNIGHT" then 
--                 draw:SetColor(196, 30, 58, 225) 
--                 icon = awful.textureEscape(135771, 16, "0:2") 
--             elseif enemy.class2 == "HUNTER" then 
--                 draw:SetColor(170, 211, 114, 225) 
--                 icon = awful.textureEscape(626000, 16, "0:2") 
--             elseif enemy.class2 == "DEMONHUNTER" then 
--                 draw:SetColor(163, 48, 201, 225) 
--                 icon = awful.textureEscape(1260827, 16, "0:2") 
--             elseif enemy.class2 == "MONK" then 
--                 draw:SetColor(0, 255, 152, 225) 
--                 icon = awful.textureEscape(626002, 16, "0:2") 
--             end
--         draw:Text(icon ,"GameFontHighlight", ex, ey+1, ez+4)
--     end)
-- end) 

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

--------------- --------------- --------------- --------------- MISC & TABLES --------------- --------------- --------------- ---------------

local bigDefensives = { 
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
 }

 local noPanic = { 
    204018, --spellwarding
    116849, --cocoon
    47788, -- guard spirit
    232707, --ray
    1022, --bop
    -- 196718, --darkness--
    -- 209426, --darkness#2--
    --102342, ---ironbark
    642, -- bubble
    215769, --angel
 }

 local BigDefonMe = { 
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
    642, -- bubble
    184662, --shield of vengance
}

local healthStone = awful.Item(5512)
healthStone:Update(function(item)
    if player.buffFrom(noPanic) then return end 
    if not item:Usable(player) then return end
    if player.hp <= settings.healthstoneHP then
      return item:Use() 
    end
end)

local healthstone = awful.NewItem(5512)
-- local checked_for_hs = 0
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


 --------------- --------------- --------------- --------------- BURST --------------- --------------- --------------- ---------------

 local smallburst = false
 local bigburst = false
 
 ---smallbursts---
 cmd:New(function(msg)
     if bigburst == true then return end 
     if crusade.cd < 1 and not player.hasTalent(458359) then awful.alert({ message = awful.colors.red.. "Big Burst ready", texture = 231895, duration = 1 }) return end --we have big burst ready--
     if msg == "smallburst" then 
     smallburst = not smallburst
     end
 end)
 
 ---bigbursts---
 cmd:New(function(msg)
     if msg == "bigburst" then  
     bigburst = not bigburst
     smallburst = false 
     end
 end)
 
 function smallBurstTrigger1()
     if finalreckoning.cd > 0.1 and finalreckoning.cd < 8 and not target.stunned then return end 
     if not settings.autoburst then return end 
     if player.hasTalent(458359) then return end
     if target.friendly then return end 
     if bigburst == true then return end --already enabled--
     if smallburst == true then return end --already enabled--
     if crusade.cd < 30 then return end --big burst ready (soon)--
     if not enemyHealer.exists and target.stunned and target.distance < 20 and target.los then 
         smallburst = true 
      end
 end 
 
 function smallBurstTrigger2()
     if finalreckoning.cd > 0.1 and finalreckoning.cd < 8 and not target.stunned then return end 
     if not settings.autoburst then return end 
     if player.hasTalent(458359) then return end
     if target.friendly then return end 
     if bigburst == true then return end --already enabled--
     if smallburst == true then return end --already enabled--
     if crusade.cd < 30 then return end --big burst ready (soon)--
     if not target.buffFrom(bigDefensives) and target.distance < 20 and target.los then 
         smallburst = true 
     end
 end 
 
 function smallBurstTrigger3()
     if not settings.autoburst then return end 
     if player.hasTalent(458359) then return end
     if bigburst == true then return end --already enabled--
     if smallburst == true then return end --already enabled--
     if crusade.cd < 1 then return end --big burst ready, wir ballern trotzdem direkt rein weil cc Healer is immer gut----
     if target.friendly then return end 
     if enemyHealer.cc and enemyHealer.ccRemains > 2 and target.distance < 20 and target.los then 
         smallburst = true 
      end
 end 
 
 function bigBurstTrigger1()
     if not settings.autoburst then return end 
     if player.hasTalent(458359) then return end 
     if not player.combat then return end 
     if crusade.cd > 1 then return end 
     if finalreckoning.cd > 0.1 and finalreckoning.cd < 6 and not target.stunned then return end 
     if bigburst == true then return end --already enabled--
     if target.friendly then return end 
     if not enemyHealer.exists and target.stunned and target.distance < 20 and target.los then 
         bigburst = true
         smallburst = false 
      end
 end 


 function bigBurstTrigger2()
     if not settings.autoburst then return end 
     if player.hasTalent(458359) then return end 
     if not player.combat then return end 
     if crusade.cd > 1 then return end 
     if finalreckoning.cd > 0.1 and finalreckoning.cd < 6 and not target.stunned then return end 
     if target.friendly then return end 
     if bigburst == true then return end --already enabled--
     if finalreckoning.cd > 0.1 and finalreckoning.cd < 5 then return end --ready soon--
     if not target.buffFrom(bigDefensives) and target.distance < 20 and target.los then 
         bigburst = true
         smallburst = false 
     end
 end 
 
 function bigBurstTrigger3()
     if not settings.autoburst then return end
     if player.hasTalent(458359) then return end 
     if not player.combat then return end 
     if crusade.cd > 1 then return end 
     if finalreckoning.cd > 0.1 and finalreckoning.cd < 6 and not target.stunned then return end 
     if target.friendly then return end 
     if bigburst == true then return end --already enabled--
     if enemyHealer.cc and enemyHealer.ccRemains > 2 and target.distance < 20 and target.los then 
         bigburst = true
         smallburst = false 
     end
 end 
 
 function bigBurstTrigger4()
     if not settings.autoburst then return end
     if player.hasTalent(458359) then return end --radiant glory--
     if not player.combat then return end 
     if crusade.cd > 1 then return end 
     if finalreckoning.cd > 0.1 and finalreckoning.cd < 6 and not target.stunned then return end 
     if target.friendly then return end 
     if bigburst == true then return end --already enabled--
     if player.buff(231895) and target.distance < 20 and target.los then 
         --bigburst = not bigburst
         bigburst = true 
         smallburst = false 
     end
 end 

 function bigBurstTriggerWakeOfAshes()
    if not settings.autoburst then return end 
    if not player.hasTalent(458359) then return end 
    if not player.combat then return end 
    if player.cooldown(255937) > 0.1 then return end 
    if finalreckoning.cd > 0.1 and finalreckoning.cd < 6 and not target.stunned then return end 
    if bigburst == true then return end --already enabled--
    if target.friendly then return end 
    if not enemyHealer.exists and target.stunned and target.distance < 20 and target.los then 
        bigburst = true
        smallburst = false 
     end
end 

function bigBurstTriggerWakeOfAshes2()
    if not settings.autoburst then return end 
    if not player.hasTalent(458359) then return end 
    if not player.combat then return end 
    if player.cooldown(255937) > 0.1 then return end 
    if finalreckoning.cd > 0.1 and finalreckoning.cd < 6 and not target.stunned then return end 
    if bigburst == true then return end --already enabled--
    if target.friendly then return end 
    if not target.buffFrom(bigDefensives) and target.distance < 20 and target.los then 
        bigburst = true
        smallburst = false 
     end
end 


function bigBurstTriggerWakeOfAshes3()
    if not settings.autoburst then return end 
    if not player.hasTalent(458359) then return end 
    if not player.combat then return end 
    if player.cooldown(255937) > 0.1 then return end 
    if finalreckoning.cd > 0.1 and finalreckoning.cd < 6 and not target.stunned then return end 
    if bigburst == true then return end --already enabled--
    if target.friendly then return end 
    if enemyHealer.cc and enemyHealer.ccRemains > 2 and target.distance < 20 and target.los then 
        bigburst = true
        smallburst = false 
     end
end 
 
 ----burst turning off----
 
 function bigburstOFF()
     if not settings.autoburst then return end 
     if player.hasTalent(458359) then return end --radiant glory--
     if bigburst == false then return end 
     if bigburst then 
         if crusade.cd > 0.5 and crusade.cd < 90 or not player.combat or awful.prep then 
        -- if not player.buff(231895) then 
         bigburst = false
         end 
     end 
 end 

 function bigburstOFFRadiant()
    if not settings.autoburst then return end 
    if not player.hasTalent(458359) then return end --radiant glory--
    if bigburst == false then return end 
    if bigburst then 
        if not player.combat or awful.prep then 
       -- if not player.buff(231895) then 
        bigburst = false
        end 
    end 
end 
 
 function smallburstOFF()
     if not settings.autoburst then return end 
     if player.hasTalent(458359) then return end --radiant glory--
     if smallburst == false then return end
     if smallburst then 
         if crusade.cd < 1 or not player.combat or awful.prep then 
         smallburst = false
         end 
     end 
 end 

function smallburstOFFtwo()
    if not settings.autoburst then return end 
    if player.hasTalent(458359) then return end --radiant glory--
    if smallburst == false then return end
    if smallburst then 
        if crusade.cd < 30 and finalreckoning.cd < 30 then 
        smallburst = false
        end 
    end 
end 


 --------------- --------------- --------------- --------------- DEFENSIVES --------------- --------------- --------------- ---------------

--Aura--
devoaura:Callback(function(spell)
    if not player.combat and player.buff(32223) then return end --mount aura--
    if player.buff(465) then return end 
    if player.buff(317920) then return end 
    if not player.buff(465) or not player.buff(317920) then  --not devaura or concentration aura--
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end
end)

devoaura:Callback("prep", function(spell)
    if awful.prep then 
        if not player.combat and player.buff(32223) then return end --mount aura--
        if player.buff(465) then return end 
        if player.buff(317920) then return end 
        if not player.buff(465) or not player.buff(317920) then  --not devaura or concentration aura--
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end 
end)

-- No Big Defs on me and Healer is in CC --
divineshield:Callback("nobigdefs", function(spell)
    if player.buffFrom(BigDefonMe) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.debuff(25771) then return end --Forberance--
    if player.hp < 25 then
        if healer.cc or healer.silenced then
            --awful.enemies.loop(function(enemy) 
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            --end)
        end
    end
end)

-- No Big Defs and no Healer --
divineshield:Callback("noHealer", function(spell)
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.debuff(25771) then return end --Forberance--
    if player.hp < 25 then
        if not healer.exists then
            --awful.enemies.loop(function(enemy) 
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            --end)
        end
    end
end)

divineshield:Callback("ordead", function(spell)
    if player.buffFrom(BigDefonMe) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.debuff(25771) then return end --Forberance--
    if player.hp < 25 then
        --if healer.cc and healer.ccRemains > 1 then
            --awful.enemies.loop(function(enemy) 
                if spell:Cast() then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            --end)
        --end
    end
end)

layonhands:Callback("OnPlayerNoHealer", function(spell)
    if not settings.autLoH then return end 
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.debuff(25771) then return end --Forberance--
    if player.cooldown(642) < 1 then return end 
    if player.hp < 20 then
        if not healer.exists then
            --awful.enemies.loop(function(enemy) 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            --end)
        end
    end
end)

layonhands:Callback("OnPlayerHealerinCC", function(spell)
    if not settings.autLoH then return end 
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.debuff(25771) then return end --Forberance--
    if player.cooldown(642) < 1 then return end 
    if player.hp < 20 then
        if healer.cc and healer.ccRemains > 1 then
            --awful.enemies.loop(function(enemy) 
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            --end)
        end
    end
end)

layonhands:Callback("OnGroupvsMelee", function(spell)
    if not settings.autLoH then return end 
    awful.enemies.loop(function(unit)
        if unit.role ~= "melee" then return end --if not meele--
        if bop.cd < 0.1 then return end 
        awful.group.loop(function(group)
            if group.debuff(25771) then return end ---Forbearance--
            if group.class == "Paladin" then return end --he has bops for himself--
            if not spell:Castable(group) then return end
            if group.buffFrom(noPanic) then return end
            if group.buffFrom(bigDefensives) then return end 
            if unit.target.isUnit(group) and unit.losOf(group) then 
                if group.hp < 30 then
                    if spell:Cast(group) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end  
                end
            end 
        end)
    end)
end)

layonhands:Callback("OnGroupvsCaster", function(spell)
    if not settings.autLoH then return end 
    awful.enemies.loop(function(unit)
        if unit.role ~= "range" then return end --if not range--
        if unit.class == "Hunter" then return end --not a hunter--
        if player.hasTalent(204018) and spellwarding.cd < 0.1 then return end 
        awful.group.loop(function(group)
            if group.debuff(25771) then return end ---Forbearance--
            if group.class == "Paladin" then return end --he has bops for himself--
            if not spell:Castable(group) then return end
            if group.buffFrom(noPanic) then return end
            if group.buffFrom(bigDefensives) then return end 
            if unit.target.isUnit(group) and unit.losOf(group) then 
                if group.hp < 30 then
                    if spell:Cast(group) then
                        if settings.alertsmode then awful.alert(awful.colors.pink.. "" .. awful.colors.pink.. (group.name), spell.id) end 
                    end  
                end
            end 
        end)
    end)
end)

bop:Callback("onPlayer", function(spell)
    if not settings.autobop then return end 
    if player.cooldown(642) < 1 then return end  --divine shield--
    if player.cooldown(633) < 1 then return end  --lay on hands--
    awful.enemies.loop(function(unit)
        if unit.role ~= "melee" then return end --if not meele--
        --if (unit.class == "Priest" or unit.class == "Shaman" or unit.class == "Demon Hunter" or unit.class == "Mage") and layonhands.cd < 1 then return end 
        if player.debuff(25771) then return end ---Forbearance--
        if not spell:Castable(group) then return end
        if player.buffFrom(noPanic) then return end
        if player.buffFrom(bigDefensives) then return end 
        if unit.target.isUnit(player) and unit.losOf(player) then 
            if player.hp < 40 then
                if spell:Cast(player) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end  
            end
        end 
    end)
end)

--- Bop on Kidneys with a healer ---
bop:Callback("kidney", function(spell)
    if not settings.autobop then return end 
    awful.enemies.loop(function(unit)
        if unit.class ~= "Rogue" then return end --if not rogue--
        if healer.cc and healer.ccRemains > 2 then 
            awful.group.loop(function(group)
                if group.debuff(25771) then return end ---Forbearance--
                if group.class == "Paladin" then return end --he has bops for himself--
                if not spell:Castable(group) then return end
                if group.buffFrom(noPanic) then return end
                if group.buffFrom(bigDefensives) then return end 
                if group.isHealer and player.cooldown(210256) < 0.1 then return end --we will use sanc to help him--
                if unit.target.isUnit(group) then 
                    if group.debuffRemains("Kidney Shot") > 4 then
                        if spell:Cast(group) then
                            --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                            if settings.alertsmode then awful.alert(awful.colors.pink.. "BOP" .. awful.colors.pink.. (group.name), spell.id) end 
                        end  
                    end
                end
            end)
        end
    end)
end)

--- Bop on Kidneys without a healer ---
bop:Callback("kidneyNoHeal", function(spell)
    if not settings.autobop then return end 
    awful.enemies.loop(function(unit)
        if unit.class ~= "Rogue" then return end --if not rogue--
        if not healer.exists then 
            awful.group.loop(function(group)
                if group.debuff(25771) then return end ---Forbearance--
                if group.class == "Paladin" then return end --he has bops for himself--
                if not spell:Castable(group) then return end
                if group.buffFrom(noPanic) then return end
                if group.buffFrom(bigDefensives) then return end 
                if unit.target.isUnit(group) then 
                    if group.debuffRemains("Kidney Shot") > 4 then
                        if spell:Cast(group) then
                           -- if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                            if settings.alertsmode then awful.alert(awful.colors.pink.. "BOP" .. awful.colors.pink.. (group.name), spell.id) end 
                        end  
                    end
                end
            end)
        end
    end)
end)

-- we bop vs melees when we don't play with a paladin and no big defs up and under % hp--
bop:Callback("melee", function(spell)
    if not settings.autobop then return end 
    awful.enemies.loop(function(unit)
        if unit.role == "range" and not unit.class == "hunter" then return end --makes no sense anyways--
        if unit.class2 == "MAGE" and not unit.cc then return end --he will steal our bop--
        if unit.class2 == "MAGE" and player.cooldown(204018) < 1 then return end --he will steal our bop--
        if unit.class2 == "MAGE" and player.cooldown(633) < 1 then return end -- lay on hands rdy--
        if unit.role ~= "melee" then return end --if not meele--
        if (unit.class == "Priest" or unit.class == "Shaman" or unit.class == "Demon Hunter" or unit.class == "Mage") and layonhands.cd < 1 then return end 
        awful.group.loop(function(group)
            if group.debuff(25771) then return end ---Forbearance--
            if group.class == "Paladin" then return end --he has bops for himself--
            if not spell:Castable(group) then return end
            if group.buffFrom(noPanic) then return end
            if group.buffFrom(bigDefensives) then return end 
            if unit.target.isUnit(group) and unit.losOf(group) then 
                if group.hp < 40 then
                    if spell:Cast(group) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end  
                end
            end 
        end)
    end)
end)

bop:Callback("karma", function(spell)
    if not settings.autobopKarma then return end 
    awful.group.loop(function(group)
        if group.debuff(25771) then return end ---Forbearance--
        if group.class == "Paladin" then return end --he has bops for himself--
        if not spell:Castable(group) then return end
        if group.buffFrom(noPanic) then return end
        if group.debuff(124280) and group.debuffRemains(124280) > 5 then ---karma---
            if spell:Cast(group) then
                --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                if settings.alertsmode then awful.alert(awful.colors.pink.. "BOP Karma" .. awful.colors.pink.. (group.name), spell.id) end 
            end  
        end
    end)
end)

spellwarding:Callback("caster", function(spell)
    awful.enemies.loop(function(unit)
        if unit.role ~= "range" then return end --if not range--
        if unit.class == "Hunter" then return end --not a hunter--
        awful.group.loop(function(group)
            if group.debuff(25771) then return end ---Forbearance--
            if group.class == "Paladin" then return end --he has bops for himself--
            if not spell:Castable(group) then return end
            if group.buffFrom(noPanic) then return end
            if group.buffFrom(bigDefensives) then return end 
            if unit.target.isUnit(group) and unit.losOf(group) then 
                if group.hp < 30 then
                    if spell:Cast(group) then
                        if settings.alertsmode then awful.alert(awful.colors.pink.. "" .. awful.colors.pink.. (group.name), spell.id) end 
                    end  
                end
            end 
        end)
    end)
end)

divineprotection:Callback("nobigdefs", function(spell)
    if not settings.autodef then return end 
    if player.buffFrom(BigDefonMe) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 0 then
        if healer.cc or healer.silenced then
            awful.enemies.loop(function(enemy) 
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast() then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        end
    end
end)

divineprotection:Callback("nobigdefsNoHealer", function(spell)
    if not settings.autodef then return end 
    if player.buffFrom(BigDefonMe) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 0 then
        if not healer.exists then
            awful.enemies.loop(function(enemy) 
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast() then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        end
    end
end)

divineprotection:Callback("stunned", function(spell)
    if not settings.autodef then return end 
    if not settings.autobarkskin then return end
    if player.buffFrom(BigDefonMe) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if player.stunned then
        awful.enemies.loop(function(enemy) 
            if enemy.los and enemy.target.isUnit(player) then
                if spell:Cast() then 
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end
        end)
    end
end)

shieldofvengeance:Callback("nobigdefs", function(spell)
    if not settings.autodef then return end 
    if player.buffFrom(BigDefonMe) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    if player.buff(403876) and player.hp > 60 then return end --we have divine protection wall up--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 0 then
        if healer.cc and healer.ccRemains > 1 then
            awful.enemies.loop(function(enemy) 
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast() then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        end
    end
end)

shieldofvengeance:Callback("nobigdefsNoHeal", function(spell)
    if not settings.autodef then return end 
    if player.buffFrom(BigDefonMe) then return end --we already have big def up--
    if player.buffFrom(noPanic) then return end --we already have big def up--
    --if player.buff(403876) and player.hp > 60 then return end --we have divine protection wall up--
    local total, melee, ranged, cooldowns = player.v2attackers()
    if cooldowns > 0 or player.hp < 75 then
        if not healer.exists then
            awful.enemies.loop(function(enemy) 
                if enemy.los and enemy.target.isUnit(player) then
                    if spell:Cast() then 
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end 
                end
            end)
        end
    end
end)

local natureCureDelay = awful.delay(0.1, 0.3)

local rootStuff = {
    [339] = { uptime = natureCureDelay.now, min = 2 },      -- Entangling Roots
    [235963] = { uptime = natureCureDelay.now, min = 2 },   -- Entangling Roots
    [102359] = { uptime = natureCureDelay.now, min = 2 },   -- Mass Entanglement
    [117526] = { uptime = natureCureDelay.now, min = 2 },   -- Binding Shot
    [122] = { uptime = natureCureDelay.now, min = 2 },      -- Frost Nova 
    [33395] = { uptime = natureCureDelay.now, min = 2 },    -- Freeze
    [64695] = { uptime = natureCureDelay.now, min = 2 },    -- Earthgrab
    [355689] = { uptime = natureCureDelay.now, min = 2 },   -- Landslide evoker
}

freedom:Callback("roots", function(spell)
    if not settings.autofreedom then return end 
    awful.enemies.loop(function(enemy)
        awful.group.loop(function(unit, i, uptime)
            if unit.distance > 40 then return end 
            if enemy.class == "Druid" and enemy.spec == "Balance" and enemy.cooldown(78675) < 25 then return end -- we hold freedom for rootbeam --
            if unit.buff(1044) then return end --freedom already up--
            if unit.debuffFrom(rootStuff) or player.debuffFrom(rootStuff) or player.rooted then
                if unit.class == "Paladin" then return end
                if not spell:Castable(unit) then return end
                if spell:Cast(unit) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    --awful.alert(awful.colors.pink.. "testerino" .. awful.colors.pink.. (unit.name), spell.id) end 
                end  
            end 
        end)
    end)
end)

freedom:Callback("solarbeam", function(spell)
    if not settings.autofreedom then return end 
   --awful.group.loop(function(unit, i, uptime)
        if unit.distance > 40 then return end 
        if unit.buff(1044) then return end --freedom already up-- 
        if not unit.debuff(81261) then return end 
        if not spell:Castable(unit) then return end 
        if unit.isHealer and unit.debuff(81261) and unit.rooted then --solarbeam--
            if spell:Cast(unit) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "BEEEEAAAM", texture = spell.id, duration = 1 }) end
                --awful.alert(awful.colors.pink.. "Beam" .. awful.colors.pink.. (unit.name), spell.id) end 
            end
        end 
   -- end)
end)

freedom:Callback("slowed", function(spell)
    if not settings.autofreedom then return end 
    awful.enemies.loop(function(enemy)
        awful.group.loop(function(unit, i, uptime)
            if unit.distance > 40 then return end 
            if enemy.class == "Druid" and enemy.spec == "Balance" and enemy.cooldown(78675) < 25 then return end -- we hold freedom for rootbeam --
            if unit.buff(1044) then return end --freedom already up-- 
            --if unit.class == "Paladin" then return end
            if not spell:Castable(unit) then return end
            if target.speed > player.speed and player.slowed and not unit.isHealer then
                if spell:Cast(unit) then
                    if settings.alertsmode then  awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    --awful.alert(awful.colors.pink.. "" .. awful.colors.pink.. (unit.name), spell.id) end 
                end  
            end 
        end)
    end)
end)

sac:Callback("healerinCC", function(spell)
    if healer.cc and healer.ccRemains > 1 then --or healer.silenced then 
        awful.enemies.loop(function(enemy)
            awful.group.loop(function(group)
                if group.buffFrom(bigDefensives) then return end    
                local total, melee, ranged, cooldowns = group.v2attackers()
                if cooldowns > 0 and group.hp < 80 then
                    if enemy.target.isUnit(group) then
                        if spell:Cast(group) then
                            if settings.alertsmode then awful.alert(awful.colors.pink.. "" .. awful.colors.pink.. (group.name), spell.id) end 
                        end  
                    end
                end
            end)
        end)
    end 
end)

sac:Callback("noHealer", function(spell)
    if not healer.exists then 
        awful.enemies.loop(function(enemy)
            awful.group.loop(function(group)
                if group.buffFrom(bigDefensives) then return end    
                local total, melee, ranged, cooldowns = group.v2attackers()
                if enemy.target.isUnit(group) and group.hp < 85 then
                    if spell:Cast(group) then
                        if settings.alertsmode then awful.alert(awful.colors.pink.. "" .. awful.colors.pink.. (group.name), spell.id) end 
                    end  
                end
            end)
        end)
    end 
end)

 --------------- --------------- --------------- --------------- DAMAGE --------------- --------------- --------------- ---------------

 local immuneBuffs = { 
    212295, --netherward
    --48707, --ams
    47585, --dispersion
    --23920, --reflect
    125174, --karma
    409293, --burrow
    642, --bubble
    204018, --spellwarding
    45438, --iceblock--
    186265, --turtle--
    33786, --cyclone
    353319, --monk revival 
    290049, --iceblock
    283627, --2. bubblle?
}

hammerofwrath:Callback(function(spell)
    if player.holypower >= 5 then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    --if not spell:Castable(target) then return end
    if target.bcc then return end 
    if target.dead then return end
    if target.dist > hammerofwrath.range then return end
    if target.friendly then return end
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

bladeofjustice:Callback(function(spell)
    --if player.used(255937, 1) and player.holypower >= 3 then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    --if not spell:Castable(target) then return end
    if target.bcc then return end 
    if target.dead then return end
    if target.dist > bladeofjustice.range then return end
    if target.friendly then return end
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

judgement:Callback(function(spell)
    --if player.holypower >= 4 then return end 
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    --if not spell:Castable(target) then return end
   -- if target.bcc then return end 
    if target.dead then return end
    if target.dist > judgement.range then return end
    if target.friendly then return end
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

finalverdict:Callback(function(spell)
    if crusade.cd < 1 and not player.hasTalent(458359) then return end --we want it for the big go--
    --if player.used(255937, 3) then return end --wake of ashes used--
    if target.buffFrom(immuneBuffs) then return end 
    if target.immuneMagicDamage then return end 
    --if not spell:Castable(target) then return end
    if target.bcc then return end 
    if target.dead then return end
    if target.dist > finalverdict.range then return end
    if target.friendly then return end
    if target.los then
        if spell:Cast(target) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
        end
    end
end)

divinestorm:Callback("PVE", function(spell)
    --if not target.combat then return end 
   -- if player.used(255937, 1) then return end --wake of ashes used--
    if settings.mode == "pvemode" then
        if target.immuneMagicDamage then return end 
        --if not spell:Castable(target) then return end
        if target.dead then return end
        if target.bcc then return end
        if target.friendly then return end
        if target.dist > 40 then return end
        --if allEnemies.around(target, 8) >= 2 then
        local abc, abcCount = enemies.around(target, 5, function(obj) return obj.combat and not obj.dead and not obj.friendly end)
        if abc and abcCount >= 3 then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end 
        end
    end 
end)

 --------------- --------------- --------------- --------------- SPELLS --------------- --------------- --------------- ---------------

finalverdict:Callback("burst", function(spell)
    --if player.used(255937, 1) then return end --wake of ashes used--
    if smallburst or bigburst then  
        if crusade.cd < 1 and not player.hasTalent(458359) then return end --we want it for the big go--
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        --if not spell:Castable(target) then return end
        if target.bcc then return end 
        if target.dead then return end
        if target.dist > finalverdict.range then return end
        if target.friendly then return end
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end
        end
    end 
end)

wakeofashes:Callback("burst", function(spell)
    if smallburst or bigburst then 
        if player.holypower >= 4 then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        --if not spell:Castable(target) then return end
        if target.bcc then return end 
        if target.dead then return end
        if target.friendly then return end
        if target.los and target.distanceTo(player) < 12 then
            if spell:Cast(target, {face = true}) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end
        end
    end 
end)

local hammeroflight = NewSpell({ 427453, 427441, 429826 }, { damage = "magic", ignoreUsable = true, ignoreCasting = true })

awful.RegisterMacro("hammer", 2)

hammeroflight:Callback(function(spell)
    if target.los then
       if awful.call('CastSpellByID', 427453) then return true end 
           --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "TEST hammeroflight", texture = spell.id, duration = 1 }) end
    end
end)

hammeroflight:Callback("burst", function(spell)

    -- function getSpellIcon(spellId)
    --     local _, _1, icon = GetSpellInfo(spellId)
    --     return icon
    -- end
    -- if getSpellIcon(427453) == 5342121 then

        if smallburst or bigburst then 
            if target.buffFrom(immuneBuffs) then return end 
            if target.immuneMagicDamage then return end 
        --  if not spell:Castable(target) then return end
            if target.bcc then return end 
            if target.dead then return end
            --if target.friendly then return end
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "YEE", texture = spell.id, duration = 1 }) end
                end
            end
        end 
    --end 
end)

hammeroflight:Callback("burst2", function(spell)

    -- function getSpellIcon(spellId)
    --     local _, _1, icon = GetSpellInfo(spellId)
    --     return icon
    -- end
    -- if getSpellIcon(255937) == 5342121 then

        if smallburst or bigburst then 
            if target.buffFrom(immuneBuffs) then return end 
            if target.immuneMagicDamage then return end 
        --  if not spell:Castable(target) then return end
            if target.bcc then return end 
            if target.dead then return end
           -- if target.friendly then return end
            if target.los then
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "YEE2", texture = spell.id, duration = 1 }) end
                end
            end
        end 
   -- end 
end)



-- wakeofashes:Callback("test", function(spell)
--     if target.los then
--         if spell:Cast(target) then
--             if settings.alertsmode then awful.alert({ message = awful.colors.red.. "TES TESTS", texture = spell.id, duration = 1 }) end
--         end
--     end
-- end)

finalreckoning:Callback("smallburst", function(spell)
    if smallburst and crusade.cd > 45 then  --if crusade is rdy in under 45 seconds, we wait for it and only use it with big burst--
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        --if not spell:Castable(target) then return end
        if target.bcc then return end 
        if target.dead then return end
        if target.dist > finalreckoning.range then return end
        if target.friendly then return end
        if target.los then
            if player.holypower >= 3 or enemyhealer.ccRemains > 2 then
                if spell:AoECast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end
            end 
        end
    end 
end)

finalreckoning:Callback("bigburst", function(spell)
    if player.hasTalent(458359) then return end --radiant glory--
    if bigburst then  
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        --if not spell:Castable(target) then return end
        if target.bcc then return end 
        if target.dead then return end
        if target.dist > finalreckoning.range then return end
        if target.friendly then return end
        if target.los then
            if player.holypower >= 3 and player.buffStacks(231895) >= 8 then
                if spell:AoECast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end
            end 
        end
    end 
end)

finalreckoning:Callback("bigburstRadiant", function(spell)
    if not player.hasTalent(458359) then return end --radiant glory--
    if bigburst then  
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        --if not spell:Castable(target) then return end
        if target.bcc then return end 
        if target.dead then return end
        if target.dist > finalreckoning.range then return end
        if target.friendly then return end
        if target.los then
            if player.holypower >= 3 and player.used(255937, 7) then --wake of ashes used--
                if spell:AoECast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end
            end 
        end
    end 
end)

divinetoll:Callback("burst", function(spell)
    if finalreckoning.cd > 0.1 and finalreckoning.cd < 13 and not target.stunned then return end 
    if smallburst and crusade.cd > 30 or bigburst then  --if crusade is rdy in under 60 seconds, we wait for it and only use it with big burst--
        if player.holypower >= 3 then return end 
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        --if not spell:Castable(target) then return end
        if target.bcc then return end 
        if target.dead then return end
        if target.dist > 20 then return end
        if target.friendly then return end
        if target.los then
            if spell:Cast(target) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end
        end
    end 
end)

---wings---
crusade:Callback("burst", function(spell)
    if player.hasTalent(458359) then return end 
    if bigburst then 
        if target.buffFrom(immuneBuffs) then return end 
        if target.immuneMagicDamage then return end 
        if target.bcc then return end 
        if target.dead then return end
        if target.dist > 15 then return end
        if target.friendly then return end
        if target.los then
            if spell:Cast(player) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
            end
        end
    end 
end)


 --------------- --------------- --------------- --------------- CC --------------- --------------- --------------- ---------------

hoj:Callback("enemyHealerinCC", function(spell)
    if player.hasTalent(458359) and finalreckoning.cd > 0.1 and finalreckoning.cd < 10 then return end --big burst rdy soon--
    if player.hasTalent(458359) and wakeofashes.cd > 0.1 and wakeofashes.cd < 10 then return end 
    if settings.stunmode == "stuntarget" or settings.stunmode == "mixedstun" then
        if not settings.autostun then return end
        if enemyHealer.cc and enemyHealer.ccRemains >= 3 then 
            --if not target.player then return end 
            if target.immuneMagicDamage then return end 
            if target.friendly then return end 
            --if not spell:Castable(target) then return end
            if target.stunned then return end --already in cc--
            if target.buff(345228) then return end  --lolstorm--
            if target.buff(408558) then return end --fade immunity--
            if target.buff(377362) then return end --precog--
            if target.buff(8178) then return end --grounding
            if target.stunDR == 1 then --only stun when FULL stun--
                if spell:Cast(target) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                end
            end
        end
    end 
end)

hoj:Callback("noEnemyHealer", function(spell)
    if finalreckoning.cd > 0.1 and finalreckoning.cd < 10 and divinetoll.cd > 0.1 and divinetoll.cd < 10 then return end --big burst ready soon
    if player.hasTalent(458359) and finalreckoning.cd > 0.1 and finalreckoning.cd < 10 then return end --big burst rdy soon--
    if player.hasTalent(458359) and wakeofashes.cd > 0.1 and wakeofashes.cd < 10 then return end 
    if settings.stunmode == "stuntarget" or settings.stunmode == "mixedstun" then
        if not settings.autostun then return end
        if not enemyHealer.exists then 
            --if not target.player then return end 
            if target.immuneMagicDamage then return end 
            if target.friendly then return end 
            --if not spell:Castable(target) then return end
            if target.stunned then return end --already in cc--
            if target.buff(345228) then return end  --lolstorm--
            if target.buff(408558) then return end --fade immunity--
            if target.buff(377362) then return end --precog--
            if target.buff(8178) then return end --grounding
            if player.buff(231895) or smallburst == true then  --crusade(is big burst auto) active or smallburst-- 
                if target.stunDR == 1 then --only stun when FULL stun--
                    if spell:Cast(target) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end
                end
            end 
        end
    end 
end)

hoj:Callback("onenemyHealer", function(spell)
    if player.hasTalent(458359) and finalreckoning.cd > 0.1 and finalreckoning.cd < 10 then return end --big burst rdy soon--
    if player.hasTalent(458359) and wakeofashes.cd > 0.1 and wakeofashes.cd < 10 then return end 
    if finalreckoning.cd > 0.1 and finalreckoning.cd < 10 and divinetoll.cd > 0.1 and divinetoll.cd < 10 then return end --big burst ready soon
    if player.used(96231, 2) then return end  --we kicked him---
    if settings.stunmode == "stunhealer" or settings.stunmode == "mixedstun" then
        if not settings.autostun then return end
        if enemyHealer.exists then 
            --if not target.player then return end 
            if enemyHealer.immuneMagicDamage then return end 
            if not spell:Castable(enemyHealer) then return end
            if enemyHealer.stunned then return end --already in cc--
            if enemyHealer.buff(345228) then return end  --lolstorm--
            if enemyHealer.buff(408558) then return end --fade immunity--
            if enemyHealer.buff(377362) then return end --precog--
            if enemyHealer.buff(8178) then return end  --grounding
            if player.buff(231895) or smallburst == true or bigburst == true then  --crusade(is big burst auto) active or smallburst-- 
                if enemyHealer.stunDR == 1 and enemyHealer.los then --only stun when FULL stun--
                    if spell:Cast(enemyHealer) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end
                end
            end 
        end
    end 
end)

hoj:Callback("onOffTarget", function(spell)
    if player.hasTalent(458359) and finalreckoning.cd > 0.1 and finalreckoning.cd < 10 then return end --big burst rdy soon--
    if player.hasTalent(458359) and wakeofashes.cd > 0.1 and wakeofashes.cd < 10 then return end 
    if settings.stunmode == "mixedstun" then 
        if not settings.autostun then return end
        awful.enemies.loop(function(enemy)
            if not enemy.player then return end 
            if enemy.role == "healer" then return end --we don't want to stun heal--
            if enemy.immuneMagicDamage then return end 
            if not spell:Castable(enemy) then return end
            if enemy.stunned then return end --already in cc--
            if enemy.buff(345228) then return end  --lolstorm--
            if enemy.buff(408558) then return end --fade immunity--
            if enemy.buff(377362) then return end --precog--
            if enemy.buff(8178) then return end --grounding
            if enemyHealer.cc and enemyHealer.ccRemains > 2 then 
                if player.buff(231895) or smallburst == true or bigburst == true then  --crusade(is big burst auto) active or smallburst-- 
                    if enemy.stunDR == 1 and enemy.los then --only stun when FULL stun--
                        if not player.target.isUnit(enemy) then 
                            if target.stunned then
                                if spell:Cast(enemy) then
                                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "cover", texture = spell.id, duration = 1 }) end
                                end
                            end 
                        end
                    end 
                end 
            end 
        end)
    end 
end)

local noBlindThings = { 378464, 642, 186265, 31224, 48707, 45438, 6940, 199448, 213610, 353319, 362486, 236321, 215769 } --nully, bubble, turtle, cloak, antimagicshieldDK, iceblock, sac, ultimative-sac, holy ward, revivalimmunity, tranqimmu, war banner, angel
local castedCCbyGroup = { 
    33786, --cyclone
    605, --MC
    20066, --repentance
    360806, -- sleep walk, 
    5782, --fear 
    51514,  -- Hex Frog
    211015,  -- Hex Kakerlake
    210873,  -- Hex Raptor
    277784,  -- Hex Köter
    277778,  -- Hex Zandalari
    269352,  -- Hex Skelett
    211004,  -- Hex Spider
    28272,	-- Pig
    118,	-- Sheep
    277792,  -- Bee
    161354,  -- Monkey
    277787,  -- Direhorn
    161355, -- Penguin
    161353, -- Polar Bear
    120140, -- Porcupine
    61305, -- Cat
    61721, -- Rabbit
    61780, -- Turkey
    28271, -- Turtle
    82691, -- Ring of Frost
    391622, -- new mage Duck
    200205, -- new mage Duck 2
    198898, --song ofchi
    30283, --shadowfury
    6358, --seduction
} 

blindinglight:Callback("enemyHealer", function(spell)
    if not settings.autoblind then return end 
    if player.target.isUnit(enemyHealer) then return end --we go on him--
    if player.used(96231, 2) then return end  --we kicked him---
    awful.group.loop(function(group)
        if group.class == "Warlock" and group.spec == "Affliction" then return end --nope we dont want to kill his dmg--
        if group.class == "Shaman" and group.spec == "Elemental" then return end --nope we dont want to kill his dmg--
        if group.class == "Priest" and group.spec == "Shadow" then return end --nope we dont want to kill his dmg--
        if tContains(castedCCbyGroup, group.castID) and group.castTarget.isUnit(enemyHealer) then return end
        if enemyHealer.debuff(80240) and group.used(6789, 2) then return end  --incoming coil--
        if enemyHealer.buffFrom(noBlindThings) then return end 
        if enemyHealer.debuff(81261) and enemyHealer.rooted then return end --beam--
        if enemyHealer.immuneMagicEffects then return end 
        if enemyHealer.cc then return end 
        if enemyHealer.ddr > 0.5 then --only fear on full DR
            if enemyHealer.ccRemains < 0.5 then 
                if enemyHealer.distanceTo(player) < 9 then
                    if spell:Cast(player) then
                        if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end
                    end
                end 
            end 
        end
    end)
end)

--------------- --------------- --------------- --------------- Kicks --------------- --------------- --------------- ---------------

--- Kick ---
local kickList = { 5782, 33786, 116858, 2637, 375901, 211015, 210873, 277784, 277778, 269352, 211004, 51514, 28272, 118, 277792, 161354, 277787, 
161355, 161353, 120140, 61305, 61721, 61780, 28271, 82691, 391622, 20066, 605, 113724, 198898, 186723, 32375, 982, 320137, 254418, 8936, 82326, 
209525, 289666, 2061, 283006, 19750, 77472, 199786, 204437, 227344, 30283, 115175, 191837, 124682, 360806, 382614, 382731, 382266, 8004, 355936, 367226, 2060, 64843, 263165, 228260, 
205021, 404977, 421453, 342938, 316099, 200652, 51505, 1064, 48181, 120644, 171884 } --neu geadded: lavaburst, chainheal, haunt, halo,, denounce--

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

local KickDelay = awful.delay(0.3, 0.35)
local KickDelayCasts = awful.delay(0.2, 0.4)

rebuke:Callback("casts", function(spell)  
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
        if enemy.class == "Druid" and enemy.spec == "Balance" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Feral" then return end -- we have our own function for it --

        if awful.fighting("Balance") then return end 
        if awful.fighting("Feral") then return end 

        if awful.fighting(102) then return end --balance--
        if awful.fighting(103) then return end --feral--

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

rebuke:Callback("vsBoomkins", function(spell) 
    if not settings.autokick then return end
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

rebuke:Callback("channel", function(spell) 
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

rebuke:Callback("channelotherkicks", function(spell) 
    if not settings.autokick then return end
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

rebuke:Callback("otherchannels", function(spell) 
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
rebuke:Callback("nottakingthefckID", function(spell) 
    if not settings.autokick then return end
        awful.enemies.loop(function(enemy) 
        if not spell:Castable(enemy) then return end
        if not enemy.casting then return end
        if not enemy.los then return end 
        if enemy.class == "Druid" and enemy.spec == "Feral" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Balance" then return end -- we have our own function for it --

        if awful.fighting("Balance") then return end 
        if awful.fighting("Feral") then return end 

        if awful.fighting(102) then return end --balance--
        if awful.fighting(103) then return end --feral--

        if enemy.buffFrom(noKickthings) then return end 
        if enemy.debuff(410216) then return end --searing glare on him--
            if enemy.castID == 360806 or enemy.castID == 228260 or enemy.castID == 77472 or enemy.castID == 8004 then --sleep walk, void erruption, healing wave--
                if enemy.castRemains < awful.buffer + KickDelayCasts.now then 
                return spell:Cast(enemy) and awful.alert(awful.colors.red.. "Kick " .. awful.colors.pink.. (enemy.casting or enemy.channeling), spell.id)
                end
            end
        end)
end)

rebuke:Callback("disintigrate", function(spell) 
    if not settings.autokick then return end
    awful.enemies.loop(function(enemy) 
        if enemy.class == "Druid" and enemy.spec == "Feral" then return end -- we have our own function for it --
        if enemy.class == "Druid" and enemy.spec == "Balance" then return end -- we have our own function for it --
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

rebuke:Callback("firebreath", function(spell)  
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

rebuke:Callback("firebreathChannel", function(spell) 
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

 --------------- --------------- --------------- --------------- HEAL --------------- --------------- --------------- ---------------

flashoflight:Callback(function(spell)
    if not settings.autoheal then return end 
    if not player.hasTalent(403698) then return end --insta flash heal--
    if player.mana < 27000 then return end 
    awful.fullGroup.loop(function(friend)
        if friend.buff(342246) then return end --alter time--
        if friend.dist > flashoflight.range then return end
        if not friend.los then return end 
        if friend.buffFrom(noPanic) then return end 
        local lowest = awful.fullGroup.lowest
        if not spell:Castable(lowest) then return end
        if lowest.hp < 95 then
            if spell:Cast(lowest) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

flashoflight:Callback("critical", function(spell)
    if not settings.autoheal then return end 
    if not player.hasTalent(403698) then return end --insta flash heal--
    if player.mana < 27000 then return end 
    awful.fullGroup.loop(function(friend)
        if friend.buff(342246) then return end --alter time--
        if not friend.los then return end 
        if friend.dist > flashoflight.range then return end
        local lowest = awful.fullGroup.lowest
        if not spell:Castable(lowest) then return end
        if lowest.hp < 40 then
            if spell:Cast(lowest) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

local eternalFlame = NewSpell(156322, { heal = true, ignoreLoS = false, ignoreMoving = true, ignoreFacing = true })

eternalFlame:Callback("critical", function(spell)
    if not settings.autoheal then return end 
    if player.mana < 250000 then return end 
   -- awful.fullGroup.loop(function(friend)
        local lowest = awful.fullGroup.lowest
        --if lowest.buff(342246) then return end --alter time--
        if not lowest.los then return end 
        if lowest.distanceTo(player) > 40 then return end
        if lowest.buffFrom(noPanic) then return end 
        if not spell:Castable(lowest) then return end
        if lowest.hp < 50 then
            if spell:Cast(lowest) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end 
    --end)
end)

eternalFlame:Callback("HealerCC", function(spell)
    if not settings.autoheal then return end 
    if player.mana < 250000 then return end 
   -- awful.fullGroup.loop(function(friend)
        local lowest = awful.fullGroup.lowest
        --if lowest.buff(342246) then return end --alter time--
        if not lowest.los then return end 
        if lowest.buff(215769) then return end --angel--
        if lowest.distanceTo(player) > 40 then return end
        if lowest.buffFrom(noPanic) then return end 
        if not spell:Castable(lowest) then return end
        if lowest.hp < 75 and healer.cc and healer.ccRemains > 2 then
            if spell:Cast(lowest) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "off heal peel", texture = spell.id, duration = 1 }) end 
            end 
        end 
    --end)
end)



wordofglory:Callback("critical", function(spell)
    if not settings.autoheal then return end 
    if not player.hasTalent(403698) then return end --insta flash heal--
    if player.mana < 27000 then return end 
    awful.fullGroup.loop(function(friend)
        if friend.buff(342246) then return end --alter time--
        if not friend.los then return end 
        if friend.dist > wordofglory.range then return end
        if friend.buffFrom(noPanic) then return end 
        local lowest = awful.fullGroup.lowest
        if not spell:Castable(lowest) then return end
        if lowest.hp < 30 then
            if spell:Cast(lowest) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
    end)
end)

local natureCureDelay = awful.delay(0.3, 0.6)

local blessingList = {
    -- Paladin
    [853] = { uptime = natureCureDelay.now, min = 3 },      -- Hammer of Justice
    -- Warlock
    [5782] = { uptime = natureCureDelay.now, min = 3 },   -- Fear
    [5484] = { uptime = natureCureDelay.now, min = 3 },   -- Howl of Terror
    [30283] = { uptime = natureCureDelay.now, min = 3 },   -- shadowfury
    -- Priest 
    [8122] = { uptime = natureCureDelay.now, min = 3 },     -- Psychic Scream
    [64044] = { uptime = natureCureDelay.now, min = 3 },    -- Psychic Horror Stun
    [15487] = { uptime = natureCureDelay.now, min = 2 },  -- silence
    [88625] = { uptime = natureCureDelay.now, min = 3 },     -- Chastise 
    -- Demon Hunter
    [207685] = { uptime = natureCureDelay.now, min = 3 },   ---sigil fear---
    [179057] = { uptime = natureCureDelay.now, min = 3 },   --chaos nova--
    [211881] = { uptime = natureCureDelay.now, min = 3 },   --DH stun
    -- shaman  
    [118905] = { uptime = natureCureDelay.now, min = 3 }, --stuntotem-stun
    [305485] = { uptime = natureCureDelay.now, min = 3 }, --lasso
    ---DK
    [47476] = { uptime = natureCureDelay.now, min = 3 }, --strang
    [221562] = { uptime = natureCureDelay.now, min = 3 }, --DK stun
    --Rogue 
    [408] = { uptime = natureCureDelay.now, min = 3 }, --kidney 
    [1833] = { uptime = natureCureDelay.now, min = 3 }, --cheapshot
    -- Hunter
    [19577] = { uptime = natureCureDelay.now, min = 3 }, --hunterstun
    -- Druid 2
    [2570] = { uptime = natureCureDelay.now, min = 3 }, --maim
    [5211] = { uptime = natureCureDelay.now, min = 3 }, --bash
    -- Warrior
    [107570] = { uptime = natureCureDelay.now, min = 3 }, --Stormbolt 
    [5246] = { uptime = natureCureDelay.now, min = 3 }, --Intishout 
}

sanctuary:Callback("healer", function(spell)
    if not settings.autoSanctuary then return end 
   -- awful.fullGroup.loop(function(group)
  --  if group.buffFrom(noPanic) then return end 
        if healer.debuffFrom(blessingList) and healer.los then
            if spell:Cast(healer) then
                if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
            end 
        end
   -- end) 
end)


local blessingListPanic = {
  -- Paladin
  [853] = { uptime = natureCureDelay.now, min = 1.5 },      -- Hammer of Justice
  -- Warlock
  [5782] = { uptime = natureCureDelay.now, min = 1.5 },   -- Fear
  [5484] = { uptime = natureCureDelay.now, min = 1.5 },   -- Howl of Terror
  [30283] = { uptime = natureCureDelay.now, min = 1.5 },   -- shadowfury
  -- Priest 
  [8122] = { uptime = natureCureDelay.now, min = 1.5 },     -- Psychic Scream
  [64044] = { uptime = natureCureDelay.now, min = 1.5 },    -- Psychic Horror Stun
  [15487] = { uptime = natureCureDelay.now, min = 1.5 },  -- silence
  [88625] = { uptime = natureCureDelay.now, min = 1.5 },     -- Chastise 
  -- Demon Hunter
  [207685] = { uptime = natureCureDelay.now, min = 1.5 },   ---sigil fear---
  [179057] = { uptime = natureCureDelay.now, min = 1.5 },   --chaos nova--
  [211881] = { uptime = natureCureDelay.now, min = 1.5 },   --DH stun
  -- shaman  
  [118905] = { uptime = natureCureDelay.now, min = 1.5 }, --stuntotem-stun
  [305485] = { uptime = natureCureDelay.now, min = 1.5 }, --lasso
  ---DK
  [47476] = { uptime = natureCureDelay.now, min = 1.5 }, --strang
  [221562] = { uptime = natureCureDelay.now, min = 1.5 }, --DK stun
  --Rogue 
  [408] = { uptime = natureCureDelay.now, min = 1.5 }, --kidney 
  [1833] = { uptime = natureCureDelay.now, min = 1.5 }, --cheapshot
  -- Hunter
  [19577] = { uptime = natureCureDelay.now, min = 1.5 }, --hunterstun
  -- Druid 2
  [2570] = { uptime = natureCureDelay.now, min = 1.5 }, --maim
  [5211] = { uptime = natureCureDelay.now, min = 1.5 }, --bash
  -- Warrior
  [107570] = { uptime = natureCureDelay.now, min = 1.5 }, --Stormbolt 
  [5246] = { uptime = natureCureDelay.now, min = 1.5 }, --Intishout 
}

sanctuary:Callback("healerpanic", function(spell)
    awful.fullGroup.loop(function(group)
        --if group.buffFrom(noPanic) then return end 
        if group.hp < 30 then 
            if healer.debuffFrom(blessingListPanic) then
                if spell:Cast(healer) then
                    if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
                end 
            end 
        end 
    end)
end)

divinesteed:Callback(function(spell)
    if not settings.autosteed then return end
    --if player.hp < 50 or player.hp < 70 and healer.cc then return end 
    awful.enemies.loop(function(enemy)
    if enemy.used(116844, 4) then return end --ring of peace was used--
        if target.friendly then return end 
        if player.buff(77764) then return end --roar activated--
        if player.slowed or player.rooted then return end 
        if target.distance < 23 or target.distance > 40 then return end
        if spell:Cast(player) then
            if settings.alertsmode then awful.alert({ message = awful.colors.red.. "", texture = spell.id, duration = 1 }) end 
        end 
    end)
end)

--------------- --------------- --------------- --------------- UI BUTTONS --------------- --------------- --------------- ---------------

--awful.enabled = true
----hier bis war ok

-- local Buttons = gui:StatusFrame({
--     colors = {
--         background = { 0, 0, 0, 0 },
--         enabled = { 30, 240, 255, 1 },
--     },
--     maxWidth = 500,
--     padding = 7,
-- })

-- Buttons:Button({
-- spellID = 53385,
-- default = true,
-- var = "enableStatusFrame",
-- size = 35,
-- text = function()
--     --return awful.enabled and awful.colors.cyan .. "ON" or awful.colors.red .. "OFF"
--    --return awful.colors.cyan .. "ON" or awful.colors.red .. "OFF"
--     --return awful.colors.green .. "ON" or awful.colors.red .. "OFF"
--     if awful.enabled == true then 
--     return awful.colors.cyan .. "ON" 
--     else
--     return awful.colors.red .. "OFF"
--     end 
-- end,
-- onClick = function()
--     awful.enabled = not awful.enabled
-- end 
-- })

--hier

-- local Buttonsb = gui:StatusFrame({
--     colors = {
--         background = { 0, 0, 0, 0 },
--         enabled = { 30, 240, 255, 1 },
--     },
--     maxWidth = 500,
--     padding = 7,
-- })

-- Buttonsb:Button({ 
-- spellID = 853,
-- default = true,
-- var = "burstStatusFrame",
-- size = 35,
-- text = awful.colors.pink .. "Stun",
-- -- text = function()
-- --     return awful.colors.pink .. "ON" or awful.colors.red .. "OFF"
-- --     --return awful.colors.green .. "ON" or awful.colors.red .. "OFF"
-- -- end,
-- onClick = function()
--     settings.autostun = not settings.autostun
-- end
-- }) 

-- Buttons:Buttonthree({
--     spellID = 123792,
--     default = false,
--     var = "ccHealStatusFrame",
--     size = 32,
--     text = awful.colors.pink .. "CC Heal",
--     onClick = function()
--         ccheal = not ccheal 
--     end
-- })

-- sf:Button({
--     spellId = 188389, -- Flame Shock spell ID
--     var = "ninny_rotationEnabled",
--     text = function()
--         return awful.enabled and awful.colors.green .. "Rotation On!" or awful.colors.red .. "Rotation Off!"
--     end,
--     onClick = function(self, event)
--         awful.enabled = not awful.enabled
--         awful.call("RunMacroText", "/ninny t")
--     end,
--     size = 50
-- })

local onusePvpTrinket = awful.Item{218421}
onusePvpTrinket:Update(function(item)
    if not onusePvpTrinket.equipped then return end
    if not item:Usable(player) then return end
    if player.used(375576, 2) or player.used(231895, 4) or player.used(343721, 4) then
      return item:Use() and awful.alert({ message = awful.colors.red.. "", texture = 345228, duration = 1 })
    end
end)

local autoAttackSpell = NewSpell(6603)

autoAttackSpell:Callback(function(spell)
    if spell.current then return end 
    if target.exists and target.enemy and not target.bcc and not target.dead then
        if spell:Cast() then
            --if settings.alertsmode then awful.alert({ message = awful.colors.red.. "Auto Attack", texture = spell.id, duration = 1 }) end 
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

---actor---
retribution:Init(function()

    if settings.bigalertsmode and bigburst == true then awful.alert({ message = awful.colors.cyan.. "Big Burst", texture = 213895, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end
    if settings.bigalertsmode and smallburst == true then awful.alert({ message = awful.colors.cyan.. "Small Burst", texture = 255937, duration = awful.tickRate * 2, fadeIn = 0, fadeOut = 0, big = true, highlight = true, outline = "OUTLINE" }) end

    if awful.player.mounted then return end 

    autoAttackSpell()


    hammeroflight()
    hammeroflight("burst")
    hammeroflight("burst2")


    devoaura("prep")

    bigBurstTriggerWakeOfAshes()
    bigBurstTriggerWakeOfAshes2()
    bigBurstTriggerWakeOfAshes3()
    bigburstOFF()
    bigburstOFFRadiant()
    smallburstOFF()
    smallburstOFFtwo()

    bigBurstTrigger1()
    bigBurstTrigger2()
    bigBurstTrigger3()
    bigBurstTrigger4()

    smallBurstTrigger1()
    smallBurstTrigger2()
    smallBurstTrigger3()

   -- healthstone:grab()
    if awful.prep then return end 

    onusePvpTrinket()

    divineshield("nobigdefs")
    divineshield("noHealer")
    divineshield("ordead")
    bop("melee")
    layonhands("OnPlayerNoHealer")
    layonhands("OnPlayerHealerinCC")
    layonhands("OnGroupvsMelee")
    layonhands("OnGroupvsCaster")
    bop("onPlayer")
    divineprotection("nobigdefs")
    divineprotection("nobigdefsNoHealer")
    divineprotection("stunned")
    sanctuary("healer")
    sanctuary("healerpanic")
    shieldofvengeance("nobigdefs")
    shieldofvengeance("nobigdefsNoHeal")

    rebuke("casts")
    rebuke("vsBoomkins")
    rebuke("channel")
    rebuke("channelotherkicks")
    rebuke("otherchannels")
    rebuke("nottakingthefckID")
    rebuke("firebreath")
    rebuke("firebreathChannel")
    rebuke("disintigrate")

    bop("kidney")
    bop("kidneyNoHeal")
    bop("karma")
    spellwarding("caster")

    hoj("enemyHealerinCC")
    hoj("noEnemyHealer")
    hoj("onenemyHealer")
    hoj("onOffTarget")
    blindinglight("enemyHealer")

    sac("healerinCC")
    sac("noHealer")

    --freedom("solarbeam")
    freedom("roots")
    freedom("slowed")
    divinesteed()
    flashoflight("critical")
    eternalFlame("critical")
    eternalFlame("HealerCC")
    wordofglory("critical")

    crusade("burst")
    divinetoll("burst")
    finalreckoning("bigburst")
    finalreckoning("bigburstRadiant")
    finalreckoning("smallburst")
    divinestorm("PVE")
    finalverdict("burst")
    finalverdict()
    wakeofashes("burst")
    hammerofwrath()
    devoaura()
    flashoflight()
    judgement()
    bladeofjustice()

    
end)

--smallburst + stun - maybe waiting for final reckoning ?
--hoj auf stun (z.B. kidney) wenn target hp < 50 hp und half DR  stunDR == 0.5
-- überprüfen ob bubble geht