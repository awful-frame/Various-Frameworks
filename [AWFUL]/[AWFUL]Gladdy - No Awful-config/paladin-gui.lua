local Unlocker, awful, project = ...

if awful.player.class2 ~= "PALADIN" then return end
if awful.player.spec ~= "Holy" then return end
local player = awful.player
local pink = {255, 192, 203}
local white = {255, 255, 255, 1}
local black = {6, 4, 4, 0.8}

-- Create GUI
project.gui, project.settings, project.cmd = awful.UI:New("gladdy", {
    title = awful.textureEscape(31884, 15)  .. "Gladdy Holy Paladin",
    show = true,
    width = 350,
    height = 300,
    colors = {
        title = pink,
        primary = white,   
        accent = pink,               
        background = black, 
    }
})

project.flatDam = {}
local function flattenDam(spellTable)
    for _, entry in pairs(spellTable) do
        if entry.tvalue and type(entry.tvalue) == "table" then
            for _, spellID in ipairs(entry.tvalue) do
                project.flatDam[spellID] = true
            end
        elseif entry.value then
            if type(entry.value) == "table" then
                for _, spellID in ipairs(entry.value) do
                    project.flatDam[spellID] = true
                end
            else
                project.flatDam[entry.value] = true
            end
        end
    end
end

project.flatHeals = {}
local function flattenHeals(spellTable)
    for _, entry in pairs(spellTable) do
        if entry.tvalue and type(entry.tvalue) == "table" then
            for _, spellID in ipairs(entry.tvalue) do
                project.flatHeals[spellID] = true
            end
        elseif entry.value then
            if type(entry.value) == "table" then
                for _, spellID in ipairs(entry.value) do
                    project.flatHeals[spellID] = true
                end
            else
                project.flatHeals[entry.value] = true
            end
        end
    end
end



project.flatCC = {}

setmetatable(project.flatCC, {
    __index = function(tbl, spellID)
        local func = rawget(tbl, spellID)
        if func and type(func) == "function" then
            return func()
        else
            return false
        end
    end
})

local function flattenCC(spellTable)
    for _, entry in pairs(spellTable) do
        local func
        if entry.type == "incapacitate" then
            func = function() return player.idr >= 0.5 end
        elseif entry.type == "disorient" then
            func = function() return player.ddr >= 0.5 end
        elseif entry.type == "stun" then
            func = function() return player.sdr >= 0.5 end
        end

        if entry.tvalue and type(entry.tvalue) == "table" then
            for _, spellID in ipairs(entry.tvalue) do
                project.flatCC[spellID] = func
            end
        elseif entry.value then
            if type(entry.value) == "table" then
                for _, spellID in ipairs(entry.value) do
                    project.flatCC[spellID] = func
                end
            else
                project.flatCC[entry.value] = func
            end
        end
    end
end

local CCOptional = {
	{ label = awful.textureEscape(118, 22).."Polymorph", type = "incapacitate", value = "Polymorph", tvalue = { 118,61780,126819,161353,161354,161355,28271,28272,61305,61721,161372,277787,277792,321395,391622 } },
	{ label = awful.textureEscape(51514, 22).."Hex", type = "incapacitate", value = "Hex", tvalue = { 51514,210873,211004,211010,211015,269352,277778,277784,309328 } },
	{ label = awful.textureEscape(305485, 22).."Lightning Lasso", type = "stun", value = 305485 },
	{ label = awful.textureEscape(2637, 22).."Hibernate", type = "incapacitate", value = 2637},
	{ label = awful.textureEscape(33786, 22).."Cyclone", type = "disorient", value = 33786},
    { label = awful.textureEscape(20066, 22).."Repentance", type = "incapacitate", value = 20066},
    { label = awful.textureEscape(410126, 22).."Searing Glare", type = "disorient", value = 410126},
    { label = awful.textureEscape(113724, 22).."Ring of Frost", type = "incapacitate", value = 113724},
    { label = awful.textureEscape(605, 22).."Mind Control", type = "disorient", value = 605},
    { label = awful.textureEscape(198898, 22).."Song of Chi-ji", type = "disorient", value = 198898},
    { label = awful.textureEscape(5782, 22).."Fear", type = "disorient", value = 5782},
	{ label = awful.textureEscape(30283, 22).."ShadowFury", type = "incapacitate", value = 30283},
    { label = awful.textureEscape(710, 22).."Banish", type = "incapacitate", value = 710},
    { label = awful.textureEscape(10326, 22).."Turn Evil", type = "disorient", value = 10326},   
	{ label = awful.textureEscape(360806, 22).."Sleep Walk", type = "disorient", value = 360806},
}

local DamageOptional = {
    { label = awful.textureEscape(314791, 22).."Shifting Power", value = 382440 },
    { label = awful.textureEscape(191634, 22).."Stormkeeper", value = 383009 },
	{ label = awful.textureEscape(365350, 22).."Arcane Surge", value = 365350 },
    { label = awful.textureEscape(203286, 22).."Greater Pyro", value = 203286 },
    { label = awful.textureEscape(199786, 22).."Glacial Spike", value = 199786 },
	{ label = awful.textureEscape(353082, 22).."Ring of Fire", value = 353082 },
    { label = awful.textureEscape(205021, 22).."Ray of Frost", value = 205021 },
	{ label = awful.textureEscape(234153, 22).."Drain Life", value = 234153 },
    { label = awful.textureEscape(116858, 22).."Chaos Bolt", value = 116858 },
    { label = awful.textureEscape(6353, 22).."Soul Fire", value = 6353 },
    { label = awful.textureEscape(342938, 22).."Unstable Affliction", value = 342938 },
	{ label = awful.textureEscape(105174, 22).."Hand of Guldan", value = 105174 },
	{ label = awful.textureEscape(105174, 22).."Summon Dreadstalkers", value = 104316 },
    { label = awful.textureEscape(265187, 22).."Summon Tyrant", value = 265187 },
	{ label = awful.textureEscape(30146, 22).."Summon FelGuard", value = 30146 },
    { label = awful.textureEscape(198013, 22).."Eye Beam", value = 198013 },
	{ label = awful.textureEscape(391528, 22).."Convoke", value = 391528 },
	{ label = awful.textureEscape(274283, 22).."Full Moon", value = 274283 },
    { label = awful.textureEscape(274282, 22).."Half Moon", value = 274282 },
    { label = awful.textureEscape(263165, 22).."Void Torrent", value = 263165 },
    { label = awful.textureEscape(228260, 22).."Void Eruption", value = 228260 },
	{ label = awful.textureEscape(375901, 22).."Mind Games", value = 375901 },
    { label = awful.textureEscape(202347, 22).."Stellar Flare", value = 202347 },
    { label = awful.textureEscape(382411, 22).."Eternity Surge", value= "Eternity Surge", tvalue = { 382411, 359073, 387839 } },
    { label = awful.textureEscape(356995, 22).."Disintegrate", value = 356995 },
	{ label = awful.textureEscape(395152, 22).."Ebon Might", value = 395152 },
	{ label = awful.textureEscape(396286, 22).."Upheavel", value = "Upheavel", tvalue = { 396286, 408092 }},
    { label = awful.textureEscape(32375, 22).."Mass Dispel", value = 32375 },
    { label = awful.textureEscape(378464, 22).."Nullifying Shroud", value = 378464 },
}

local HealsOptional = {
    { label = awful.textureEscape(2061, 22).."Flash Heal", value = 2061 },
    { label = awful.textureEscape(2060, 22).."Heal", value = 2060 },
    { label = awful.textureEscape(289666, 22).."Greater Heal", value = 289666 },
    { label = awful.textureEscape(47540, 22).."Penance", value = 47757},
    { label = awful.textureEscape(421453, 22).."Ultimate Penitence", value = 421453},
    { label = awful.textureEscape(8936, 22).."Regrowth", value = 8936 },
    { label = awful.textureEscape(48438, 22).."Wild Growth", value = 48438 },
    { label = awful.textureEscape(50464, 22).."Nourish", value = 50464 },
    { label = awful.textureEscape(19750, 22).."Flash of Light", value = 19750 },
    { label = awful.textureEscape(82326, 22).."Holy Light", value = 82326 },
	{ label = awful.textureEscape(200652, 22).."Tyrs Deliverance", value = 200652 },
    { label = awful.textureEscape(1064, 22).."Chain Heal", value = 1064 },
    { label = awful.textureEscape(8004, 22).."Healing Surge", value = 8004 },
    { label = awful.textureEscape(77472, 22).."Healing Wave", value = 77472 },
	{ label = awful.textureEscape(115175, 22).."Soothing Mist", value = 115175,},
    { label = awful.textureEscape(116670, 22).."Vivify", value = 116670 },
    { label = awful.textureEscape(124682, 22).."Enveloping Mist", value = 124682},
	{ label = awful.textureEscape(382614, 22).."Dream Breath", value = 355936 },
	{ label = awful.textureEscape(382731, 22).."Spirit Bloom", value = 367226 },
    { label = awful.textureEscape(361469, 22).."Living Flame", value = 361469 },
}


local StompHighOptional = {
	{ label =  awful.textureEscape(236320, 21).."War Banner", value = 119052},
    { label =  awful.textureEscape(211522, 21).."Psyfiend", value = 101398},
    { label =  awful.textureEscape(353601, 21).."Fel Obelisk", value = 179193},
    { label =  awful.textureEscape(201996, 21).."Observer", value = 107100},
    { label =  awful.textureEscape(204331, 21).."Counterstrike Totem", value = 105451},
    { label =  awful.textureEscape(204330, 21).."Skyfury Totem", value = 105427},
	{ label =  awful.textureEscape(355580, 21).."Static Field Totem", value = 179867},
	{ label =  awful.textureEscape(204331, 21).."Counterstrike Totem", value = 105451},
	{ label =  awful.textureEscape(98008, 21).."Spirit Link Totem", value = 53006},
	{ label =  awful.textureEscape(108280, 21).."Healing Tide Totem", value = 59764},
	{ label =  awful.textureEscape(192058, 21).."Capacitor Totem", value = 61245},
}

local StompOptional = {
    { label =  awful.textureEscape(8143, 21).."Tremor Totem", value = 5913},
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
    105451, --Counterstrike Totem
    5913, --Tremor Totem
    5925, --Grounding Totem
    53006, --Spirit Link Totem
    60561, --Earthgrab Totem
    61245, --Capacitor Totem
    179867, --Static Field Totem
    59764, --Healing Tide Totem
    10467, --Mana Tide Totem
    119052, --War Banner
    101398, --Psyfiend
    166523, --Vesper Totem
    107100, --Observer
}

local StompHighDefault = {}

-- Healing tab
local healing = project.gui:Tab(awful.textureEscape(388013, 15)  .. "Healing")
healing:Slider({
	text = awful.textureEscape(633, 15)  .. "Lay On Hands", 
	var = "loh", 
	min = 0, 
	max = 100, 
	default = 40, 
	valueType = "%", 
	tooltip = "Lay On Hands friend at % HP. (Default: 40)"
})

healing:Slider({
	text = awful.textureEscape(20473, 15)  .. "Holy Shock", 
	var = "hs", 
	min = 0, 
	max = 100, 
	default = 85, 
	valueType = "%", 
	tooltip = "Holy Shock friend at % HP. (Default: 85)"
})

healing:Slider({
	text = awful.textureEscape(19750, 15)  .. "Flash of Light", 
	var = "fol", 
	min = 0, 
	max = 100, 
	default = 65, 
	valueType = "%", 
	tooltip = "Flash of Light friend at % HP. (Default: 65)"
})

healing:Slider({
	text = awful.textureEscape(85673, 15)  .. "Word of Glory", 
	var = "wog", 
	min = 0, 
	max = 100, 
	default = 80, 
	valueType = "%", 
	tooltip = "Word of Glory friend at % HP. (Default: 80)"
})


local defensive = project.gui:Tab(awful.textureEscape(6940, 15)  .. "Defensives")
defensive:Slider({
	text = awful.textureEscape(633, 15)  .. "Bubble", 
	var = "bub", 
	min = 0, 
	max = 100, 
	default = 30, 
	valueType = "%", 
	tooltip = "Bubble at % HP. (Default: 30)"
})

defensive:Checkbox({
	text = "  "..awful.textureEscape(6940, 15).." Blessing of Sacrifice", 
	var = "bos", 
	default = true, 
	tooltip = "Enable/Disable Blessing of Sacrifice Low HP (Default: Enabled)"
})

defensive:Checkbox({
	text = "  "..awful.textureEscape(1022, 15).." Blessing of Protection", 
	var = "bop", 
	default = true, 
	tooltip = "Enable/Disable Blessing of Protection on Enemy Burst / Low HP. (Default: Enabled)"
})

defensive:Checkbox({
	text = "  "..awful.textureEscape(31821, 15).." Aura Mastery", 
	var = "am", 
	default = true, 
	tooltip = "Enable/Disable Aura Mastery Burst / Low HP. (Default: Enabled)"
})

defensive:Checkbox({
	text = "  "..awful.textureEscape(498, 15).." Divine Protection", 
	var = "dp", 
	default = true, 
	tooltip = "Enable/Disable Divine Protection on Enemy Burst / Low HP. (Default: Enabled)"
})

defensive:Checkbox({
	text = "  "..awful.textureEscape(410126, 15).." Searing Glare", 
	var = "sg", 
	default = true, 
	tooltip = "Enable/Disable Searing Glare on Melee Enemy Burst / Low HP. (Default: Enabled)"
})


local control = project.gui:Tab(awful.textureEscape(853, 15)  .. "Control")
control:Checkbox({
	text = "  "..awful.textureEscape(853, 15).." Hammer of Justice", 
	var = "hoj", 
	default = true, 
	tooltip = "Enable/Disable Auto Hammer of Justice. (Default: Enabled)"
})

control:Checkbox({
	text = "  "..awful.textureEscape(115750, 15).." Blinding Light", 
	var = "bl", 
	default = true, 
	tooltip = "Enable/Disable Auto Blinding Light. (Default: Enabled)"
})

control:Checkbox({
	text = "  "..awful.textureEscape(20066, 15).." Repentence", 
	var = "rep", 
	default = true, 
	tooltip = "Enable/Disable Auto Repentance. (Default: Enabled)"
})

control:Checkbox({
	text = "  "..awful.textureEscape(6940, 15).." Blessing of Sacrifice Anti-CC", 
	var = "boscc", 
	default = true, 
	tooltip = "Enable/Disable Auto Blessing Of Sacrifice for Anti-CC. (Default: Enabled)"
})

local interruptsGroup = project.gui:Group({name = awful.textureEscape(96231, 15)  .. "Interrupts"})

local kickdamage = interruptsGroup:Tab("Damage")
kickdamage:Dropdown({
    var = "kickdamage",
    multi = true,
    tooltip = "Choose the damage spells to interrupt.",
    options = DamageOptional,
    placeholder = "Select Damage Spells",
    header = "Damage Spells to Interrupt:",
})

local kickheals = interruptsGroup:Tab("Heals")
kickheals:Dropdown({
    var = "kickheals",
    multi = true,
    tooltip = "Choose the healing spells to interrupt.",
    options = HealsOptional,
    placeholder = "Select Healing Spells",
    header = "Healing Spells to Interrupt:",
})

local kickcc = interruptsGroup:Tab("CC")
kickcc:Dropdown({
    var = "kickcc",
    multi = true,
    tooltip = "Choose CC spells to interrupt.",
    options = CCOptional,
    placeholder = "Select CC Spells",
    header = "CC Spells to Interrupt:",
})

-- Stomps tab

local stompsGroup = project.gui:Group({name = awful.textureEscape(20473, 15).. "Totem Stomps"})

local stomps = stompsGroup:Tab("Low Priority")
stomps:Dropdown({
	var = "stomps",
	multi = true,
	tooltip = "Choose the totems you want to stomp.",
    options = StompOptional,
	placeholder = "Select totems",
	header = "Totems to Stomp:",
})

local stompsHigh = stompsGroup:Tab("High Priority")
stompsHigh:Dropdown({
	var = "stompsHigh",
	multi = true,
	tooltip = "Choose the totems you want to stomp.",
    options = StompHighOptional,
	placeholder = "Select Totems",
	header = "Totems to Stomp:",
})

-- Misc tab
local misc = project.gui:Tab(awful.textureEscape(134331, 15)  .. "Misc")
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
	tooltip = "Use Health Stone at % HP."
})
misc:Slider({
	text = awful.textureEscape(277187, 15) .. "Emblem", 
	var = "md", 
	min = 0, 
	max = 100, 
	default = 40, 
	valueType = "%", 
	tooltip = "Use Emblem at % HP."
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

flattenDam(DamageOptional)
flattenHeals(HealsOptional)
flattenCC(CCOptional)



