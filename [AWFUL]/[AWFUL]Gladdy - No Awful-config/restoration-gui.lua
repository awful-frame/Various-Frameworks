local Unlocker, awful, project = ...
if awful.player.class2 ~= "SHAMAN" then return end
if GetSpecialization() ~= 3 then return end
local blue = {0, 0, 255, 1}
local white = {255, 255, 255, 1}
local black = {6, 4, 4, 0.8}


project = project or {}
project.settings = project.settings or {}

project.flatDam = {}

local function flattenDam(spellTable, selectedSpells)
    for _, entry in pairs(spellTable) do
        if entry.tvalue and type(entry.tvalue) == "table" then
            for _, spellID in ipairs(entry.tvalue) do
                if selectedSpells[spellID] then
                    project.flatDam[spellID] = true
                end
            end
        elseif entry.value then
            if type(entry.value) == "table" then
                for _, spellID in ipairs(entry.value) do
                    if selectedSpells[spellID] then
                        project.flatDam[spellID] = true
                    end
                end
            else
                if selectedSpells[entry.value] then
                    project.flatDam[entry.value] = true
                end
            end
        end
    end
end

project.flatHeals = {}
local function flattenHeals(spellTable, selectedSpells)
    for _, entry in pairs(spellTable) do
        local function storeHealSpell(spellID)
            if selectedSpells[spellID] or selectedSpells[entry.value] then
                if entry.alwaysKick then
                    project.flatHeals[spellID] = "always"
                else
                    project.flatHeals[spellID] = true
                end
            else
            end
        end

        -- Handle table of spell IDs
        if entry.tvalue and type(entry.tvalue) == "table" then
            for _, spellID in ipairs(entry.tvalue) do
                storeHealSpell(spellID)
            end
        -- Handle single or table value
        elseif entry.value then
            if type(entry.value) == "table" then
                for _, spellID in ipairs(entry.value) do
                    storeHealSpell(spellID)
                end
            else
                storeHealSpell(entry.value)
            end
        end
    end
end

project.flatCC = {}
setmetatable(project.flatCC, {
    __index = function(tbl, spellID)
        local entry = rawget(tbl, spellID)
        if type(entry) == "function" then
            return entry
        end
        return false
    end
})

local function flattenCC(spellTable, selectedSpells)
    for _, entry in pairs(spellTable) do
        local check
        local isAoE = entry.aoe or false

        -- Handle spells with DR categories
        if entry.type then
            if entry.type == "incapacitate" then
                check = function(enemy)
                    return enemy.castTarget and 
                         (enemy.castTarget.isUnit(player) and player.idr >= 0.5)
                end
            elseif entry.type == "disorient" then
                check = function(enemy)
                    return enemy.castTarget and
                         (enemy.castTarget.isUnit(player) and player.ddr >= 0.5)
                end
            elseif entry.type == "stun" then
                check = function(enemy)
                    return enemy.castTarget and
                         (enemy.castTarget.isUnit(player) and player.sdr >= 0.5)
                end
            end
        else
            check = function(enemy) return true end
        end

        -- Store the check function and aoe flag
        local spellData = {
            check = check,
            aoe = isAoE
        }

        -- Handle table of spell IDs
        if entry.tvalue and type(entry.tvalue) == "table" then
            for _, spellID in ipairs(entry.tvalue) do
                if selectedSpells[spellID] then
                    project.flatCC[spellID] = spellData
                end
            end
        -- Handle single or table value
        elseif entry.value then
            if type(entry.value) == "table" then
                for _, spellID in ipairs(entry.value) do
                    if selectedSpells[spellID] then
                        project.flatCC[spellID] = spellData
                    end
                end
            else
                if selectedSpells[entry.value] then
                    project.flatCC[entry.value] = spellData
                end
            end
        end
    end
end

local CCOptional = {
	{ label = awful.textureEscape(118, 22).."Polymorph", type = "incapacitate", value = "Polymorph", tvalue = { 118,61780,126819,161353,161354,161355,28271,28272,61305,61721,161372,277787,277792,321395,391622,383121 } },
    { label = awful.textureEscape(352278, 22).."Ice Wall", value = 352278, aoe = true },
	{ label = awful.textureEscape(51514, 22).."Hex", type = "incapacitate", value = "Hex", tvalue = { 51514,210873,211004,211010,211015,269352,277778,277784,309328 } },
	{ label = awful.textureEscape(305485, 22).."Lightning Lasso", type = "stun", value = 305485 },
	{ label = awful.textureEscape(2637, 22).."Hibernate", type = "incapacitate", value = 2637},
	{ label = awful.textureEscape(33786, 22).."Cyclone", type = "disorient", value = 33786},
    { label = awful.textureEscape(20066, 22).."Repentance", type = "incapacitate", value = 20066},
    { label = awful.textureEscape(410126, 22).."Searing Glare", value = 410126, aoe = true },
    { label = awful.textureEscape(113724, 22).."Ring of Frost", type = "incapacitate", value = 113724, aoe = true },
    { label = awful.textureEscape(605, 22).."Mind Control", type = "disorient", value = 605 },
    { label = awful.textureEscape(198898, 22).."Song of Chi-ji", type = "disorient", value = 198898, aoe = true },
    { label = awful.textureEscape(5782, 22).."Fear", type = "disorient", value = 5782 },
	{ label = awful.textureEscape(30283, 22).."ShadowFury", value = 30283, aoe = true },
    { label = awful.textureEscape(710, 22).."Banish", type = "incapacitate", value = 710 },
    { label = awful.textureEscape(10326, 22).."Turn Evil", type = "disorient", value = 10326 },   
	{ label = awful.textureEscape(360806, 22).."Sleep Walk", type = "disorient", value = 360806 },
    { label = awful.textureEscape(378464, 22).."Nullifying Shroud", value = 378464 },
}

local DamageOptional = {
    { label = awful.textureEscape(314791, 22).."Shifting Power", value = 382440 },
    { label = awful.textureEscape(191634, 22).."Stormkeeper", value = 191634 },
	{ label = awful.textureEscape(365350, 22).."Arcane Surge", value = 365350 },
    { label = awful.textureEscape(203286, 22).."Greater Pyro", value = 203286 },
    { label = awful.textureEscape(199786, 22).."Glacial Spike", value = 199786 },
	{ label = awful.textureEscape(353082, 22).."Ring of Fire", value = 353082 },
    { label = awful.textureEscape(205021, 22).."Ray of Frost", value = 205021 },
	{ label = awful.textureEscape(234153, 22).."Drain Life", value = 234153 },
    { label = awful.textureEscape(116858, 22).."Chaos Bolt", value = 116858 },
    { label = awful.textureEscape(6353, 22).."Soul Fire", value = 6353 },
    { label = awful.textureEscape(342938, 22).."Unstable Affliction", value = 342938 },
    { label = awful.textureEscape(48181, 22).."Haunt", value = 48181 },
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
}

local HealsOptional = {
    { label = awful.textureEscape(2061, 22).."Flash Heal", value = 2061 },
    { label = awful.textureEscape(2060, 22).."Heal", value = 2060 },
    { label = awful.textureEscape(289666, 22).."Greater Heal", value = 289666 },
    { label = awful.textureEscape(47757, 22).. "Penance", value = "Penance", tvalue = { 47757, 373130 }},
    { label = awful.textureEscape(421453, 22).."Ultimate Penitence", value = 421453, alwaysKick = true },
    { label = awful.textureEscape(8936, 22).."Regrowth", value = 8936 },
    { label = awful.textureEscape(48438, 22).."Wild Growth", value = 48438 },
    { label = awful.textureEscape(50464, 22).."Nourish", value = 50464 },
    { label = awful.textureEscape(19750, 22).."Flash of Light", value = 19750 },
    { label = awful.textureEscape(82326, 22).."Holy Light", value = 82326 },
	{ label = awful.textureEscape(200652, 22).."Tyrs Deliverance", value = 200652, alwaysKick = true },
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

-- Create GUI
project.gui, project.settings, project.cmd = awful.UI:New("gladdy", {
    title = awful.textureEscape(626006, 15)  .. "Gladdy RSham",
    show = true,
    width = 350,
    height = 300,
    colors = {
        title = white,               -- Title color is red
        primary = white,            -- Primary text color is silver
        accent = blue,                -- Accent color is red
        background = black,          -- Background color is black
    }
})


local CCDefault = {
    "Polymorph",
    "Hex",
    305485, -- Lightning Lasso
    2637, -- Hibernate
    33786, -- Cyclone
    20066, -- Repentance
    113724, -- Ring of Frost
    605, -- Mind Control
    198898, -- Song of Chi-ji
    5782, -- Fear
    30283, -- ShadowFury
    710, -- Banish
    10326, -- Turn Evil
    360806, -- Sleep Walk
    32375, -- Mass Dispel
    410126, -- Searing Glare
    378464 -- Nullifying Shroud
}


local DamageDefault = {
    382440, -- Shifting Power
    383009, -- Stormkeeper
    365350, -- Arcane Surge
    203286, -- Greater Pyro
    199786, -- Glacial Spike
    353082, -- Ring of Fire
    205021, -- Ray of Frost
    234153, -- Drain Life
    116858, -- Chaos Bolt
    6353, -- Soul Fire
    342938, -- Unstable Affliction
    105174, -- Hand of Guldan
    104316, -- Summon Dreadstalkers
    265187, -- Summon Tyrant
    30146, -- Summon FelGuard
    198013, -- Eye Beam
    391528, -- Convoke
    274283, -- Full Moon
    274282, -- Half Moon
    263165, -- Void Torrent
    375901, -- Mind Games
    202347, -- Stellar Flare
    "Eternity Surge", -- Eternity Surge
    356995, -- Disintegrate
    395152, -- Ebon Might
    "Upheavel" -- Upheavel
}

local HealsDefault = {
    2061, -- Flash Heal
    2060, -- Heal
    289666, -- Greater Heal
    421453, -- Ultimate Penitence
    47540, -- Penance
    8936, -- Regrowth
    48438, -- Wild Growth
    50464, -- Nourish
    19750, -- Flash of Light
    82326, -- Holy Light
    200652, -- Tyrs Deliverance
    8004, -- Healing Surge
    77472, -- Healing Wave
    115175, -- Soothing Mist
    116670, -- Vivify
    124682, -- Enveloping Mist
    "Dream Breath", -- Dream Breath
    "Spirit Bloom", -- Spirit Bloom
    361469 -- Living Flame
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


local offensive = project.gui:Tab(awful.textureEscape(188389, 15)  .. "Offensive")
offensive:Slider({
	text = "DPS", 
	var = "dps", 
	min = 0, 
	max = 100, 
	default = 85, 
	valueType = "%", 
	tooltip = "Flame Shock / Lava Burst if friends are above % HP. (Default: 85)"
})
offensive:Slider({
	text = awful.textureEscape(370, 15)  .. "Auto Purge", 
	var = "prg", 
	min = 0, 
	max = 100, 
	default = 60, 
	valueType = "%", 
	tooltip = "Use Auto Purge if all friends above % HP. (Default: 60)"
})

offensive:Checkbox({
	text = "  "..awful.textureEscape(370, 15).." Offensive Purge", 
	var = "odispel", 
	default = true, 
	tooltip = "Enable/Disable Auto Purge on Low HP Enemies"
})

-- Healing tab
local healing = project.gui:Tab(awful.textureEscape(8004, 15)  .. "Healing")
healing:Slider({
	text = awful.textureEscape(61295, 15)  .. "Riptide", 
	var = "rt", 
	min = 0, 
	max = 100, 
	default = 90, 
	valueType = "%", 
	tooltip = "Riptide friend at % HP. (Default: 90)"
})
healing:Slider({
	text = awful.textureEscape(8004, 15)  .. "Healing Surge", 
	var = "hs", 
	min = 0, 
	max = 100, 
	default = 70,
	valueType = "%", 
	tooltip = "Use Healing Surge on friend at % HP. (Default: 70)"
})
--healing:Slider({
	--text = awful.textureEscape(77472, 15)  .. "Healing Wave", 
	--var = "hw", 
	--min = 0, 
	--max = 100, 
	--default = 80,
	--valueType = "%", 
	--tooltip = "Use Healing Wave on friend at % HP."
--})
healing:Slider({
	text = awful.textureEscape(73920, 15)  .. "Healing Rain", 
	var = "hr", 
	min = 0, 
	max = 100, 
	default = 90, 
	valueType = "%", 
	tooltip = "Use Healing Rain to buff heals on friend at % HP. (Default: 90)"
})
healing:Slider({
	text = awful.textureEscape(132158, 15)  .. "Nature's Swiftness", 
	var = "ns", 
	min = 0, 
	max = 100, 
	default = 50, 
	valueType = "%", 
	tooltip = "Use Big NS combo heals on friend at % HP. (Default: 50)"
})

healing:Slider({
	text = awful.textureEscape(98021, 15)  .. "Spirit Link", 
	var = "sl", 
	min = 0, 
	max = 100, 
	default = 30, 
	valueType = "%", 
	tooltip = "Use Spirit Link on friend at % HP. (Default: 30)"
})

healing:Checkbox({
	text = "  "..awful.textureEscape(73685, 15).." Ascendance", 
	var = "asd", 
	default = true, 
	tooltip = "Enable/Disable Auto Ascendance"
})

healing:Checkbox({
	text = "  "..awful.textureEscape(73685, 15).." Unleash Life", 
	var = "unleash", 
	default = true, 
	tooltip = "Enable/Disable Auto Unleash Life"
})

healing:Checkbox({
	text = "  "..awful.textureEscape(79206, 15).." Auto SpiritWalker's Grace", 
	var = "swg", 
	default = true, 
	tooltip = "Enable/Disable Auto SpiritWalker's Grace to cover casted heals from being kicked."
})

healing:Checkbox({
	text = "  "..awful.textureEscape(204336, 15).." Anti-Kick Grounding", 
	var = "akg", 
	default = true, 
	tooltip = "Enable/Disable Auto Grounding to cover casted heals from being kicked."
})


local defensive = project.gui:Tab(awful.textureEscape(108271, 15)  .. "Defensives")
defensive:Slider({
	text = awful.textureEscape(108271, 15)  .. "Astral Shift", 
	var = "astral", 
	min = 0, 
	max = 100, 
	default = 40, 
	valueType = "%", 
	tooltip = "Use astral shift at % HP. (Default: 40)"
})
defensive:Slider({
	text = awful.textureEscape(409293, 15)  .. "Burrow", 
	var = "burrow", 
	min = 0, 
	max = 100, 
	default = 30, 
	valueType = "%", 
	tooltip = "Use Burrow at % HP. (Default: 30)"
})
defensive:Slider({
	text = awful.textureEscape(198103, 15)  .. "Earth Elemental", 
	var = "ele", 
	min = 0, 
	max = 100, 
	default = 60, 
	valueType = "%", 
	tooltip = "Use Earth Elemental at % HP. (Default: 60)"
})

defensive:Checkbox({
	text = "  "..awful.textureEscape(2645, 15).." Auto Ghost Wolf", 
	var = "gw", 
	default = true, 
	tooltip = "Enable/Disable Auto Ghost Wolf"
})

local control = project.gui:Tab(awful.textureEscape(51514, 15)  .. "Control")
control:Slider({
	text = awful.textureEscape(57994, 15)  .. "WindShear", 
	var = "khp", 
	min = 0, 
	max = 100, 
	default = 70, 
	valueType = "%", 
	tooltip = "Use Windshear to kick heals if an enemy is below % HP. (Default: 70)"
})

control:Checkbox({
	text = "  "..awful.textureEscape(305483, 15).." Auto Lasso", 
	var = "lasso", 
	default = true, 
	tooltip = "Enable/Disable Auto Lasso Enemy Healer / Enemies"
})

control:Checkbox({
	text = "  "..awful.textureEscape(51514, 15).." Auto Hex", 
	var = "hex", 
	default = true, 
	tooltip = "Enable/Disable Auto Hex Enemy Healer / Enemies"
})


local interruptsGroup = project.gui:Group({name = awful.textureEscape(57994, 15)  .. "Interrupts"})

local kickdamage = interruptsGroup:Tab("Damage")
kickdamage:Dropdown({
    var = "kickdamage",
    multi = true,
    tooltip = "Choose the damage spells to interrupt.",
    options = DamageOptional,
    placeholder = "Select Damage Spells",
    header = "Damage Spells to Interrupt:",
    defualt = {}
})

local kickheals = interruptsGroup:Tab("Heals")
kickheals:Dropdown({
    var = "kickheals",
    multi = true,
    tooltip = "Choose the healing spells to interrupt.",
    options = HealsOptional,
    placeholder = "Select Healing Spells",
    header = "Healing Spells to Interrupt:",
    defualt = {}
})

local kickcc = interruptsGroup:Tab("CC")
kickcc:Dropdown({
    var = "kickcc",
    multi = true,
    tooltip = "Choose CC spells to interrupt.",
    options = CCOptional,
    placeholder = "Select CC Spells",
    header = "CC Spells to Interrupt:",
    defualt = {}
})

-- Stomps tab

local stompsGroup = project.gui:Group({name = awful.textureEscape(188389, 15).. "Totem Stomps"})

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
	tooltip = "Use Emblem at % HP. (Default: 40)"
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

local dungeon = project.gui:Tab(awful.textureEscape(1080932, 15)  .. "Dungeon Bot (Alpha)")

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

local function initCC()
    if project.settings.kickcc then
        flattenCC(CCOptional, project.settings.kickcc)
        if project.settings.kickdamage then
            flattenDam(DamageOptional, project.settings.kickdamage)
        end
        if project.settings.kickheals then
            flattenHeals(HealsOptional, project.settings.kickheals)
        end
    end
end

initCC()
