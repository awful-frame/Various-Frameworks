local Unlocker, awful, project = ...
if awful.player.class2 ~= "PRIEST" then return end
if GetSpecialization() ~= 1 then return end
local black = {6, 4, 4, 0.8}
local silver = {192, 192, 192, 1}
local red = {255, 0, 0, 1}

-- Create GUI
project.gui, project.settings, project.cmd = awful.UI:New("gladdy", {
    title = "Gladdy Disc Priest",
    show = true,
	height = 300,
	width = 350,
    colors = {
        title = red,               -- Title color is red
        primary = silver,            -- Primary text color is silver
        accent = red,                -- Accent color is red
        background = black,          -- Background color is black
    }
})

-- Offensive tab
local general = project.gui:Tab("General")
general:Dropdown({
	var = "ilsmode",
	multi = false,
	tooltip = "Choose Inner Light/Shadow Mode.",
    options = {
    { label = "Mana", value = "ilsmana" },
    { label = "Atonement", value = "ilsatone" },
    { label = "Dynamic", value = "ilsdynamic" }},
    default = "ilsmana",
	header = "Inner Light/Shadow Mode",
})

general:Checkbox({
	text = " ".. awful.textureEscape(375901, 15) .. "Auto Mind Games",
	var = "mg", 
	default = true, 
	tooltip = "Use MindGames on %HP (Auto on Enemy Burst or Enemy Healer CC)"
})

general:Checkbox({
	text = " ".. awful.textureEscape(10060, 15) .. "Auto Power Infusion",
	var = "pi", 
	default = true, 
	tooltip = "Enable/Disable Auto Power Infusion in Arena."
})

general:Checkbox({
	text = " ".. awful.textureEscape(32379, 15) .. "Auto Death",
	var = "swd", 
	default = true, 
	tooltip = "Enable/Disable Auto Shadow Word Death Incoming CC."
})

general:Checkbox({
	text = " ".. awful.textureEscape(586, 15) .. "Auto Fade",
	var = "fade", 
	default = true, 
	tooltip = "Enable/Disable Auto Fade(Phase Shift) Incoming CC."
})

general:Checkbox({
	text = " ".. awful.textureEscape(528, 15) .. "Offensive Dispel (Low HP)",
	var = "odispel", 
	default = true, 
	tooltip = "Enable/Disable Dispel Heals on Low HP enemy. (If Allies Above dispel setting HP threshold.)"
})

general:Checkbox({
	text = " "..awful.textureEscape(121536, 15)  .. "Auto Feathers", 
	var = "af", 
	default = true, 
	tooltip = "Enable/Disable Auto Feathers on enemy burst, friendly burst, and player bad positioning."
})

general:Slider({
	text = awful.textureEscape(204197, 15) .. "Purge the Wicked Enemies", 
	var = "ptw", 
	min = 1, 
	max = 3, 
	default = 1, 
	tooltip = "How many enemies to have the PTW Debuff on."
})

general:Slider({
	text = awful.textureEscape(204197, 15) .. "Purge the Wicked Pets", 
	var = "ptwp", 
	min = 0, 
	max = 3, 
	default = 0, 
	tooltip = "How many pets to have the PTW Debuff on."
})

general:Slider({
	text = awful.textureEscape(528, 15) .. "Auto Dispel HP", 
	var = "dispel", 
	min = 0, 
	max = 100, 
	default = 50, 
	valueType = "%", 
	tooltip = "Enable/Disable Auto Dispel if all friends at or above % HP. (Default Value: 50)"
})

general:Slider({
	text = awful.textureEscape(73325, 15) .. "Auto Grip HP", 
	var = "autogrip", 
	min = 0, 
	max = 100, 
	default = 25, 
	valueType = "%", 
	tooltip = "Enable/Disable Auto Grip on low HP friend. (Default Value: 25)"
})

-- Defensive tab
local defensive = project.gui:Tab("Defensive")
defensive:Slider({
	text = awful.textureEscape(19236, 15) .. "Desperate Prayer", 
	var = "dp", 
	min = 0, 
	max = 100, 
	default = 60, 
	valueType = "%", 
	tooltip = "Desperate Prayer triggered at % HP. (Default Value: 60)"
})
defensive:Checkbox({
	text = " "..awful.textureEscape(47536, 15) .. "Rapture", 
	var = "rapture", 
	default = true, 
	tooltip = "Enable/Disable Auto Rapture on enemy burst."
})
defensive:Checkbox({
	text = " "..awful.textureEscape(62618, 15) .. "Power Word: Barrier", 
	var = "pwb", 
	default = true, 
	tooltip = "Enable/Disable Auto PwB on enemy burst or big cooldowns."
})
defensive:Checkbox({
	text = " "..awful.textureEscape(108968, 15) .. "Void Shift", 
	var = "vs", 
	default = true, 
	tooltip = "Enable/Disable Auto VoidShift on low friend HP."
})
defensive:Checkbox({
	text = " "..awful.textureEscape(33206, 15) .. "Pain Suppression", 
	var = "ps", 
	default = true, 
	tooltip = "Enable/Disable Auto PS on enemy burst / low friend HP."
})

-- Healing tab
local healing = project.gui:Tab("Healing")
healing:Slider({
	text = awful.textureEscape(47540, 15) .. "Penance", 
	var = "penance", 
	min = 0, 
	max = 100, 
	default = 70, 
	valueType = "%", 
	tooltip = "Penance friend for direct heals at % HP. (Default Value: 70)"
})
healing:Slider({
	text = awful.textureEscape(139, 15) .. "Renew", 
	var = "renew", 
	min = 0, 
	max = 100, 
	default = 35, 
	valueType = "%", 
	tooltip = "Use Renew on friend at % HP. (Default Value: 35)"
})
healing:Slider({
	text = awful.textureEscape(33076, 15) .. "Prayer of Mending", 
	var = "pom", 
	min = 0, 
	max = 100, 
	default = 35, 
	valueType = "%", 
	tooltip = "Use PoM on friend at % HP. (Default Value: 35)"
})
healing:Slider({
	text = awful.textureEscape(2061, 15) .. "Surge of Light", 
	var = "sol", 
	min = 0, 
	max = 100, 
	default = 75, 
	valueType = "%", 
	tooltip = "Use instant cast SoL Procs at friend % HP. (Default Value: 75)"
})
healing:Slider({
	text = awful.textureEscape(2061, 15) .. "Flash Heal", 
	var = "fh", 
	min = 0, 
	max = 100, 
	default = 55, 
	valueType = "%", 
	tooltip = "Casted Flash Heals at friend % HP. (Default Value: 55)"
})
healing:Slider({
	text = awful.textureEscape(373481, 15) .. "Power Word: Life", 
	var = "pwl", 
	min = 30, 
	max = 35, 
	default = 32, 
	valueType = "%", 
	tooltip = "PwL friend at % HP. (Non Oracle Default Value: 32)"
})
healing:Slider({
	text = awful.textureEscape(194509, 15) .. "Power Word: Radiance", 
	var = "pwr", 
	min = 0, 
	max = 100, 
	default = 80, 
	valueType = "%", 
	tooltip = "PwR at friend % HP. (Default Value: 80)"
})

local StompHighOptional = {
	{ label =  awful.textureEscape(236320, 21).."War Banner", value = 119052},
    { label =  awful.textureEscape(211522, 21).."Psyfiend", value = 101398},
	{ label =  awful.textureEscape(108920, 21).."Void Tendrils", value = 65282},
    { label =  awful.textureEscape(353601, 21).."Fel Obelisk", value = 179193},
    { label =  awful.textureEscape(201996, 21).."Observer", value = 107100},
    { label =  awful.textureEscape(204331, 21).."Counterstrike Totem", value = 105451},
    { label =  awful.textureEscape(204330, 21).."Skyfury Totem", value = 105427},
	{ label =  awful.textureEscape(355580, 21).."Static Field Totem", value = 179867},
	{ label =  awful.textureEscape(204331, 21).."Counterstrike Totem", value = 105451},
	{ label =  awful.textureEscape(98008, 21).."Spirit Link Totem", value = 53006},
	{ label =  awful.textureEscape(108280, 21).."Healing Tide Totem", value = 59764},
	{ label =  awful.textureEscape(192058, 21).."Capacitor Totem", value = 61245},
	{ label =  awful.textureEscape(8143, 21).."Tremor Totem", value = 5913},
}

local StompOptional = {
    { label =  awful.textureEscape(204336, 21).."Grounding Totem", value = 5925},
    { label =  awful.textureEscape(8512, 21).."Windfury Totem", value = 6112},
    { label =  awful.textureEscape(51485, 21).."Earthgrab Totem", value = 60561},
    { label =  awful.textureEscape(2484, 21).."Earthbind Totem", value = 2630},
    { label =  awful.textureEscape(192058, 21).."Capacitor Totem", value = 61245},
    { label =  awful.textureEscape(355580, 21).."Static Field Totem", value = 179867},
    { label =  awful.textureEscape(16191, 21).."Mana Tide Totem", value = 10467},
    { label =  awful.textureEscape(383013, 21).."Poison Cleansing Totem", value = 5923},
    { label =  awful.textureEscape(383017, 21).."Stoneskin Totem", value = 194117},
    { label =  awful.textureEscape(5394, 21).."Healing Stream Totem", value = 3527},
    { label =  awful.textureEscape(381930, 21).."Mana Spring Totem", value = 193620},
    { label =  awful.textureEscape(324386, 21).."Vesper Totem", value = 166523},
}

local StompDefault = {
    60561, --Earthgrab Totem
    10467, --Mana Tide Totem
    179193, --Fel Obelisk
    166523, --Vesper Totem
    107100, --Observer
}

local stompsGroup = project.gui:Group({name = "Totem Stomps"})

local stomps = stompsGroup:Tab("Low Priority")
stomps:Dropdown({
	var = "stomps",
	multi = true,
	tooltip = "Choose the totems you want to stomp.",
    options = StompOptional,
    default = StompDefault,
	placeholder = "Select totems",
	header = "Totems to Stomp:",
})

local StompHighDefault = {
    105451, --Counterstrike Totem
    119052, --War Banner
    101398, --Psyfiend
    179193, --Fel Obelisk
    107100, --Observer
    204330, --Skyfury Totem
	5913, --Tremor Totem
	59764, --Healing Tide Totem
	105451, --Counterstrike Totem
    5925, --Grounding Totem
    53006, --Spirit Link Totem
	61245, --Capacitor Totem
    179867, --Static Field Totem

}
local stompsHigh = stompsGroup:Tab("High Priority")
stompsHigh:Dropdown({
	var = "stompsHigh",
	multi = true,
	tooltip = "Choose the totems you want to stomp.",
    options = StompHighOptional,
    default = StompHighDefault,
	placeholder = "Select Totems",
	header = "Totems to Stomp:",
})

-- Misc tab
local misc = project.gui:Tab("Misc")
misc:Dropdown({
	var = "mode",
	tooltip = "Choose your mode.",
	options = {
		{ label = "BG Mode", value = "bgm", tooltip = "BG Mode, higher tick rate for more FPS." },
		{ label = "Arena Mode", value = "arm", tooltip = "Arena Mode, lower tick rate for higher performance." },
		{ label = "Balanced Mode", value = "bm", tooltip = "Balanced Mode, balanced mode for good fps and CR performance."}
	},
	header = "Performance Modes",
    default = "arm"
})

misc:Slider({
	text = awful.textureEscape(538745, 15) .. "HealthStone", 
	var = "hst", 
	min = 0, 
	max = 100, 
	default = 35, 
	valueType = "%", 
	tooltip = "Use Health Stone at % HP. (Default Value: 35)"
})
misc:Slider({
	text = awful.textureEscape(277187, 15) .. "Emblem", 
	var = "md", 
	min = 0, 
	max = 100, 
	default = 40, 
	valueType = "%", 
	tooltip = "Use Emblem at % HP. (Default Value: 40)"
})

misc:Checkbox({
	text = "  "..awful.textureEscape(3163628, 15).." Arena Drawings", 
	var = "draws", 
	default = true, 
	tooltip = "Enable/Disable Line / LOS drawings in Arena."
})

misc:Checkbox({
	text = "  "..awful.textureEscape(236352, 15).." Auto Accept Queue", 
	var = "autoaccept", 
	default = true, 
	tooltip = "Enable/Disable Auto Accept Queue."
})

misc:Checkbox({
	text = "  "..awful.textureEscape(3643023, 15).." Auto Grab Flag", 
	var = "grabflag", 
	default = true, 
	tooltip = "Enable/Disable Auto Grab Flag."
})

misc:Checkbox({
	text = "  "..awful.textureEscape(1033497, 15) .. " Auto Focus", 
	var = "afocus", 
	default = true, 
	tooltip = "Enable/Disable Auto Focus"
})
misc:Checkbox({
	text = "  "..awful.textureEscape(58984, 15).." Shadowmeld incoming CC", 
	var = "autoShadowMeld", 
	default = true,
	tooltip = "Enable/Disable Shadow Meld."
})

local function GetFollowerDungeons()
    local followerDungeons = {}
    local dungeonList = GetLFDChoiceOrder()
    
    for _, dungeonID in ipairs(dungeonList) do
        if dungeonID > 0 and C_LFGInfo.IsLFGFollowerDungeon(dungeonID) then
            local name, _, _, minLevel, maxLevel, _, _, _, _, _, _, _, _, description = GetLFGDungeonInfo(dungeonID)
            table.insert(followerDungeons, {
                label = awful.textureEscape(3854020, 15) .. name .. " (Level " .. minLevel .. "-" .. maxLevel .. ")",
                value = dungeonID,
                tooltip = description
            })
        end
    end
    
    return followerDungeons
end

local dungeon = project.gui:Tab(awful.textureEscape(1080932, 15).. "Dungeon Bot (Alpha)")

dungeon:Checkbox({
	text = "  "..awful.textureEscape(1080932, 15) .. " Auto Follower Dungeon", 
	var = "autoDungeon", 
	default = false, 
	tooltip = "Enable/Disable Auto Follower Dungeon"
})

dungeon:Dropdown({
    var = "selectedFollowerDungeons",
    multi = true,
    tooltip = "Choose the follower dungeons you want to queue for.",
    options = GetFollowerDungeons(),
    placeholder = "Select Follower Dungeons",
    header = "Follower Dungeons to Queue:",
    default = {},  -- No dungeons selected by default
})

-- Define color schemes with values between 0.0 and 1.0
-- Define color schemes with distinct values for visibility
local colors = {
    background = {0, 0, 0, 0.7},           -- Black with transparency for background
    primary = {1.0, 1.0, 1.0, 1.0},        -- White for the primary text
    highlight = {0.118, 0.941, 1.0, 1.0},  -- Light blue for highlight
    warning = {1.0, 0.647, 0.0, 1.0},      -- Orange for warning
    danger = {1.0, 0.271, 0.0, 1.0},       -- Red for danger
}


-- Define texture IDs (ensure these are correct for your WoW version)
local textures = {
    pressure = 510886,    -- Shield icon
    enemyComp = 236333,   -- Dagger icon
    crossCC = 135860,     -- Stun icon
    burst = 1029581,       -- Wings icon
    killTarget = 878211,  -- Crosshairs icon
}

-- Create status frame with distinct colors for better visibility
--local statusFrame = project.gui:StatusFrame({
    --colors = {
        --background = colors.background,
        --value = colors.primary,  -- Setting the text color to white (primary)
    --},
    --maxWidth = 250,
    --padding = 10,
    --fontSize = 1,
--})

--statusFrame:Toggle({
    --label = awful.textureEscape(textures.pressure, 15) .. " Pressure: ",
    --var = "pressure"
--})

--statusFrame:Toggle({
    --label = awful.textureEscape(textures.enemyComp, 15) .. " Enemy Comp: ",
    --var = "enemyComp"
--})

--statusFrame:Toggle({
    --label = awful.textureEscape(textures.crossCC, 15) .. " Cross CC: ",
    --var = "crossCC"
--})

--statusFrame:Toggle({
    --label = awful.textureEscape(textures.burst, 15) .. " Enemy Burst: ",
    --var = "burst"
--})

--statusFrame:Toggle({
    --label = awful.textureEscape(textures.killTarget, 15) .. " Kill Target: ",
    --var = "killTarget"
--})

