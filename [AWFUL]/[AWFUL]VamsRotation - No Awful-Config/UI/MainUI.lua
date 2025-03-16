local Unlocker, awful, vamsrotation = ...

if awful.player.spec ~= "Retribution" or awful.player.class ~= "Paladin" then
    return
end

-- RGBA color scheme
local white = {255, 255, 255, 1}
local dark = {21, 21, 21, 0.8}
local purple = {244, 140, 186, 1}
-- local accent = vamsrotation:GetCurrentClassColorRGB()
local accent = {244, 140, 186, 1} -- Purple
-- all ui saved variables are stored in `settings`
local gui, settings, cmd = awful.UI:New("retri", {
	title = "Vams\n      Rotations        ",
    size = 100,
    paddingBottom = 20,
	show = true, -- show on load by default
    width = 400,
    height = 350,
    defaultTab = awful.textureEscape(461366, 18, "0:0") .. " -  Information",
	colors = {
		-- color of our ui title in the top left
		title = accent,
		-- primary is the primary text color
		primary = white,
		-- accent controls colors of elements and some element text in the UI. it should contrast nicely with the background.
		accent = accent,
		background = dark,
	}
})

-- making the settings available to the rest of our project
vamsrotation.settings = settings

-- Tabs
local blankTab = gui:Tab("       ")
local emptyTab = gui:Tab("        ")
local spaceTab = gui:Tab("      ")
local infoTab = gui:Tab(awful.textureEscape(461366, 18, "0:0") .. " -  Information")
local spaceTaba = gui:Tab(" ")
local generalTab = gui:Tab(awful.textureEscape(242267, 18, "0:0") .. " - General")
local spaceTabb = gui:Tab("  ")
local controlTab = gui:Tab(awful.textureEscape(853, 18, "0:0") .. " - Control")
local spaceTabc = gui:Tab("   ")
local defensiveTab = gui:Tab(awful.textureEscape(642, 18, "0:0") .. " - Defensive")
local spaceTabd = gui:Tab("     ")
local drawingsTab = gui:Tab(awful.textureEscape(345790, 18, "0:0") .. " - Drawings")

infoTab:Text({
    text = "|cFFF48CBARetri | Information",
    header = true,
    size = 18,
})

infoTab:Text({
    text = "To open the menu, type |cFFF48CBA/retri",
    header = false,
    size = 11
})
infoTab:Text({
	text = "|cFFF48CBABuild Imports:",
    size = 14,
})

infoTab:Text({
    text = awful.textureEscape(431377, 18, "0:2") .. " - Herald of the Sun: |cFFF48CBA[Click]",
    size = 11,
    header = false,
    paddingBottom = 10,
    OnClick = function(self, event)
        if CopyToClipboard("CYEA5ba6OK14IUITjS1kSUVJcBAAAYAAillZmtltZGLzM22MbAAAAAAY2aamFDzM2mxw2wsMLzwDwwMMDLLsBgxsMbzMzSzMTbzysNDAYBYAwYMjB") then
            awful.alert({
                message="Copied to clipboard, stop spamming me retard!",
                texture=86704,
                imgX = 1,
                imgY = 0.55,
                imgScale = 1
            })
        end
    end
})

infoTab:Text({
    text = "|cFFF48CBAMacros:",
    size = 14,
})
-- 190784 ret class icon
infoTab:Text({
    text = awful.textureEscape(190784, 18, "0:2") .. " - /retri freehorse |cFFF48CBAFreedom + Steed",
    size = 11,
    header = false,
    paddingBottom = 10,
})

infoTab:Text({
    text = "|cFFF48CBAPvP Talents:",
    size = 14,
})

infoTab:Text({
    text = awful.textureEscape(210256, 18, "0:2") .. " - Blessing of Sanctuary |cFFF48CBAMandatory",
    size = 11,
    header = false,
})

infoTab:Text({
    text = awful.textureEscape(247675, 18, "0:2") .. " - Aura of Reckoning |cFFF48CBAMandatory",
    size = 11,
    header = false,
})

infoTab:Text({
    text = awful.textureEscape(199428, 18, "0:2") .. " - Luminescence |cFFF48CBAFlexi",
    size = 11,
    header = false,
})

infoTab:Text({
    text = awful.textureEscape(469895, 18, "0:2") .. " - Spellbreaker |cFFF48CBAFlexi",
    size = 11,
    header = false,
})

infoTab:Text({
    text = awful.textureEscape(204018, 18, "0:2") .. " - Blessing of Spellwarding |cFFF48CBAvs Wizards",
    size = 11,
    header = false,
})

generalTab:Text({
    text = "|cFFF48CBARetri | General",
    header = true,
    size = 18,
})

generalTab:Checkbox({
    -- text = awful.textureEscape(31884, 18, "0:0") .. " - Auto Burst",  need to fix placement (weird offset)
    text = awful.textureEscape(255937, 18, "0:12") .. " - Auto Burst",
    var = "autoBurst",
    tooltip = "Automatically use burst without having to press /username burst macro.",
    default = true,
    size = 11,
})

-- generalTab:Checkbox({
--     -- text = awful.textureEscape(185077, 18, "0:0") .. " - Auto Focus Enemy Healer.", need to fix placement (weird offset)
--     text = "Auto Freedom                   ",
--     var = "autoFreedom",
--     tooltip = "Automatically uses Blessing of Freedom to remove roots.",
--     default = true,
--     size = 11,
-- })

-- generalTab:Checkbox({
--     -- text = awful.textureEscape(185077, 18, "0:0") .. " - Auto Focus Enemy Healer.", need to fix placement (weird offset)
--     text = "Auto Steed                   ",
--     var = "autoSteed",
--     tooltip = "Automatically uses Divine Steed to catch up to your target.",
--     default = true,
--     size = 11,
-- })

generalTab:Checkbox({
    -- text = awful.textureEscape(185077, 18, "0:0") .. " - Auto Focus Enemy Healer.", need to fix placement (weird offset)
    text = awful.textureEscape(197687, 18, "0:12") .. " - Auto Focus", -- Add spaces here
    var = "autoFocus",
    tooltip = "Automatically maintains focus.",
    default = true,
    size = 11,
    paddingLeft = 20,
})

generalTab:Checkbox({
    text = awful.textureEscape(204336, 18, "0:12") .. " - Auto Totem Stomp",
    var = "autoStomp",
    tooltip = "Automatically stomp important enemy totems.",
    default = true,
    size = 11,
    paddingLeft = 20,
})

controlTab:Text({
    text = "|cFFF48CBARetri | Control",
    header = true,
    size = 18,
})

controlTab:Checkbox({
    text = awful.textureEscape(96231, 18, "0:12") .. " - Auto Interrupt", -- Added Rebuke icon with proper spacing
    var = "autoInterrupt",
    tooltip = "Automatically use Rebuke to kick.",
    default = true,
    size = 11,
    paddingBottom = 30,
})

controlTab:Checkbox({
    text = awful.textureEscape(115750, 18, "0:12") .. " - Auto Blind", -- Added Blinding Light icon with proper spacing
    var = "autoBlind",
    tooltip = "Automatically use Blinding Light.",
    default = true,
    size = 11,
})

-- cog, + , swordn shield, X
controlTab:Dropdown({
    var = "stunMode",
    header = awful.textureEscape(853, 18, "0:0") .. " - Stun setting selection:",
    tooltip = "Select the way you want HoJ to behave. Leave on auto unless you're in a coordinated group and they've asked you to only stun X",
    options = {
        {label = awful.textureEscape(304405, 25, "0:0") .. " - Auto", value = "auto", tooltip = "Auto select target based on situation. Generally healer unless they are already stunned/on DR"},
        {label = awful.textureEscape(192251, 25, "0:0") .. " - Healer", value = "healer", tooltip = "Only stun the enemy healer, no cross-cc"},
        {label = awful.textureEscape(189208, 25, "0:0") .. " - Damage", value = "damage", tooltip = "Only stun the kill target when the healer is already in CC"},
        {label = awful.textureEscape(203337, 25, "0:0") .. " - Trap", value = "trap", tooltip = "Only use HoJ on the target if enemy is Trap."},
        {label = awful.textureEscape(357598, 25, "0:0") .. " - Off", value = "off", tooltip = "Disable auto stun"},
    },
    default = "auto",
    size = 11,
})

-- brain, gnome, orc, X
-- controlTab:Dropdown({
--     var = "stunMode",
--     header = awful.textureEscape(853, 18, "0:0") .. " - Stun setting selection:",
--     tooltip = "Select the way you want HoJ to behave. Leave on auto unless you're in a coordinated group and they've asked you to only stun X",
--     options = {
--         {label = awful.textureEscape(293664, 25, "0:0") .. " - Auto", value = "auto", tooltip = "Auto select target based on situation. Generally healer unless they are already stunned."},
--         {label = awful.textureEscape(364451, 25, "0:0") .. " - Healer", value = "healer", tooltip = "Only stun the enemy healer, no cross-cc."},
--         {label = awful.textureEscape(89253, 25, "0:0") .. " - Damage", value = "damage", tooltip = "Only stun the kill target when the healer is already in CC."},
--         {label = awful.textureEscape(357598, 25, "0:0") .. " - Off", value = "off", tooltip = "Disable auto stun."},
--     },
--     default = "auto",
--     size = 11,
-- })

defensiveTab:Text({
    text = "|cFFF48CBARetri | Defensive",
    header = true,
    size = 18,
})

defensiveTab:Slider({
    text = awful.textureEscape(642, 18, "0:0") .. " - Divine Shield HP %",
    var = "bubbleHP",
    min = 0,
    max = 30,
    step = 1,
    default = 25,
    valueType = "%",
    tooltip = "HP % at which the routine will use Divine Shield.\n\nNote: This only affects the safetynet bubble.\nIt will still use it earlier if danger and healer cc'd etc."
})


defensiveTab:Slider({
	text = awful.textureEscape(6262, 18, "0:0") .. " - Healthstone HP %",
	var = "healthstoneHP",
	min = 0,
	max = 100,
	step = 1,
	default = 35,
	valueType = "%",
	tooltip = "HP % at which the routine will use healthstone."
})

drawingsTab:Text({
    text = "|cFFF48CBARetri | Drawings",
    header = true,
    size = 18,
})

drawingsTab:Checkbox({
    text = awful.textureEscape(345790, 18, "0:12") .. " - Enable Drawings",
    var = "drawOn",
    default = true,
    size = 11,
})

drawingsTab:Checkbox({
    text = awful.textureEscape(261531, 18, "0:12") .. " - Healer Line",
    var = "drawHealer",
    default = true,
    size = 11,
    tooltip = "Enable or disable the drawing for Healer Line."
})

drawingsTab:Checkbox({
    text = awful.textureEscape(853, 18, "0:12") .. " - Draw Hammer of Justice Prompts",
    var = "drawHOJ",
    default = true,
    size = 11,
    tooltip = "Enable or disable the drawing for Hammer of Justice alert, direction and range."
})

drawingsTab:Checkbox({
    text = awful.textureEscape(201633, 18, "0:12") .. " - Draw Important Totems",
    var = "drawTotems",
    default = true,
    size = 11,
    tooltip = "Enable or disable the drawing for Totems such as Earthen Wall."
})

