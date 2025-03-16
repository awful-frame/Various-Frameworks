local Elite = _G.Elite
local Draw = Tinkr.Util.Draw:New()
local e = Elite.CallbackManager.spellbook
local OM = Elite.ObjectManager
local enemies = OM:GetEnemies()
local friends = OM:GetFriends()
local tyrants = OM:GetTyrants()
local totems = OM:GetTotems()
local ftotems = OM:GetFTotems()
Elite:SetUtilitiesEnvironment()
if Spec("player") ~= 103 then return end

----------------------------- gui -----------------------------
local Builder = Tinkr.Util.GUIBuilder:New {
    config = "xx"
}

local alertXPositionValues = {
    option_a = "-500",
    option_b = "-400",
    option_c = "-300",
    option_d = "-200",
    option_e = "-100",
    option_f = "0",
    option_g = "100",
    option_h = "200",
    option_i = "300",
    option_j = "400",
    option_k = "500"
}

local alertYPositionValues = {
    option_a = "-500",
    option_b = "-400",
    option_c = "-300",
    option_d = "-200",
    option_e = "-100",
    option_f = "0",
    option_g = "100",
    option_h = "200",
    option_i = "300",
    option_j = "400",
    option_k = "500"
}

local general1 = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "leftShiftPause",
                    label = "Left Shift Routine Pause",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "pveMode",
                    label = "Enables PvE Logic for Leveling",
                    default = "no",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "combatMode",
                    label = "Display an alert for if you're in PvE vs PvP mode",
                    default = "yes",
                }
            }
        }
    }
}

local general2 = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "autoERage",
                    label = "Auto Enraged Regeneration",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoBI",
                    label = "Auto Bitter Immunity",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "autoRC",
                    label = "Auto Rallying Cry",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoStance",
                    label = "Auto Stance",
                    default = "yes",
                }
            }
        }
    }
}

local general3 = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "enableMeleeDraw",
                    label = "Draw melee box",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "enableESP",
                    label = "Enable Target Line Drawing",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "fearDraw",
                    label = "Enable Intimidating Shout Radius Draw",
                    default = "no",
                }
            }
        }
    }
}

local DropdownGroup = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Dropdown {
                    key = "alertXPosition",
                    label = "Alert X Position",
                    default = "option_e",
                    values = {
                        option_a = "-500",
                        option_b = "-400",
                        option_c = "-300",
                        option_d = "-200",
                        option_e = "-100",
                        option_f = "0",
                        option_g = "100",
                        option_h = "200",
                        option_i = "300",
                        option_j = "400",
                        option_k = "500"
                    }
                },
                Builder:Dropdown {
                    key = "alertYPosition",
                    label = "Alert Y Position",
                    default = "option_j",
                    values = {
                        option_a = "-500",
                        option_b = "-400",
                        option_c = "-300",
                        option_d = "-200",
                        option_e = "-100",
                        option_f = "0",
                        option_g = "100",
                        option_h = "200",
                        option_i = "300",
                        option_j = "400",
                        option_k = "500"
                    }
                }
            }
        }
    }
}

local DropdownGroup2 = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Dropdown {
                    key = "alertXPositionStatic",
                    label = "Static Alert X Position",
                    default = "option_g",
                    values = {
                        option_a = "-500",
                        option_b = "-400",
                        option_c = "-300",
                        option_d = "-200",
                        option_e = "-100",
                        option_f = "0",
                        option_g = "100",
                        option_h = "200",
                        option_i = "300",
                        option_j = "400",
                        option_k = "500"
                    }
                },
                Builder:Dropdown {
                    key = "alertYPositionStatic",
                    label = "Static Alert Y Position",
                    default = "option_j",
                    values = {
                        option_a = "-500",
                        option_b = "-400",
                        option_c = "-300",
                        option_d = "-200",
                        option_e = "-100",
                        option_f = "0",
                        option_g = "100",
                        option_h = "200",
                        option_i = "300",
                        option_j = "400",
                        option_k = "500"
                    }
                }
            }
        }
    }
}

local SliderGroupDef = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Slider {
                    key = 'erageSlider',
                    label = "Enraged Regeneration (Health % of lowest team member)",
                    description = "Default is: 60%",
                    min = 15,
                    max = 100,
                    step = 1,
                    default = 60,
                    percent = false
                },
                Builder:Slider {
                    key = 'biSlider',
                    label = "Bitter Immunity (Health %)",
                    description = "Default is: 50%",
                    min = 15,
                    max = 100,
                    step = 1,
                    default = 50,
                    percent = false
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Slider {
                    key = 'rcSlider',
                    label = "Rallying Cry (Health % of lowest team member)",
                    description = "Default is: 25%",
                    min = 15,
                    max = 100,
                    step = 1,
                    default = 25,
                    percent = false
                },
                Builder:Slider {
                    key = 'dSlider',
                    label = "Swap to Defensive Stance (Health %)",
                    description = "Default is: 45%",
                    min = 15,
                    max = 100,
                    step = 1,
                    default = 45,
                    percent = false
                }
            }
        }
    }
}

-- Table to keep track of current bindings for each key
local currentBindings = {}

-- Function to update the key combos whenever the keybind input changes
local function UpdateKeybindCombo()
    -- Define keybind names and their default values
    local keybinds = {
        { name = "burstBind", default = "SHIFT-ALT-0" },
        { name = "sbeHealer", default = "SHIFT-ALT-1" },
        { name = "sbTarget", default = "SHIFT-ALT-2" },
        { name = "sweHealer", default = "SHIFT-ALT-3" },
        { name = "swTarget", default = "SHIFT-ALT-4" },
        { name = "hleHealer", default = "SHIFT-ALT-5" },
        { name = "hlfHealer", default = "SHIFT-ALT-6" }
    }

    -- Loop through each keybind and check for updates
    for _, keybind in ipairs(keybinds) do
        local newBinding = Builder:GetConfig(keybind.name, keybind.default)
        
        -- Only update and register the combo if the keybind has changed
        if currentBindings[keybind.name] ~= newBinding then
            currentBindings[keybind.name] = newBinding
            RegisterCombo(keybind.name, newBinding)
        end
    end
end

-- Set a timer to periodically check and update the keybind
local function PeriodicKeybindUpdate()
    UpdateKeybindCombo()
    C_Timer.After(1, PeriodicKeybindUpdate)  -- Check every 1 second
end

-- Start the periodic check
PeriodicKeybindUpdate()

-- Use the OnChange method to dynamically update the keybind combo when the user changes it in the GUI
local KeybindInputGroup = Builder:Group {
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Text {
                    text = "Keybind examples: SHIFT-F | SHIFT-ALT-F | F",
                    size = 12,
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:EditBox {
                    key = "burstBind",
                    label = "Keybind to hold down and pop all CDs",
                    default = "SHIFT-ALT-0",
                },
                Builder:EditBox {
                    key = "sbeHealer",
                    label = "Storm Bolt enemy healer",
                    default = "SHIFT-ALT-1",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:EditBox {
                    key = "sbTarget",
                    label = "Storm bolt target",
                    default = "SHIFT-ALT-2",
                },
                Builder:EditBox {
                    key = "sweHealer",
                    label = "Shockwave enemy healer",
                    default = "SHIFT-ALT-3",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:EditBox {
                    key = "swTarget",
                    label = "Shockwave target",
                    default = "SHIFT-ALT-4",
                },
                Builder:EditBox {
                    key = "hleHealer",
                    label = "Heroic leap to enemy healer",
                    default = "SHIFT-ALT-5",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:EditBox {
                    key = "hlfHealer",
                    label = "Heroic leap to friendly healer",
                    default = "SHIFT-ALT-6",
                }
            }
        }
    }
}


local TabGroup = Builder:TabGroup {
    key = "input_tabs",
    tabs = {
        Builder:Tab {
            title = "General",
            content = {
                general1,
                DropdownGroup,
                DropdownGroup2
            }
        },
        Builder:Tab {
            title = "Defensives",
            content = {
                general2,
                SliderGroupDef
            }
        },
        Builder:Tab {
            title = "Drawings",
            content = {
                general3
            }
        },
        Builder:Tab {
            title = "Keybinds",
            content = {
                KeybindInputGroup
            }
        }
    }
}

local TypographyTabGroup = Builder:TabGroup {
    key = "typography_tabs",
    tabs = {
        Builder:Tab {
            title = "Info",
            content = {
                Builder:Padding {
                    padding = 5,
                    content = {
                        Builder:Rows {
                            Builder:Text {
                                text = "Report bugs in discord #warrior-suggestions-bugs",
                                size = 18,
                                font = "Fonts\\FRIZQT__.TTF",
                                color = "51322D",
                            },
                            Builder:Spacer {},
                            Builder:Spacer {},
                            Builder:Spacer {},
                            Builder:Spacer {},
                            Builder:Text {
                                text = "To be added.",
                                size = 12,
                                font = "Fonts\\FRIZQT__.TTF",
                                color = "51322D"
                            }
                        }
                    }
                }
            }
        }
    }
}

local TreeGroup = Builder:TreeGroup {
    key = "example_tree",
    branches = {
        Builder:TreeBranch {
            title = "Fury General",
            icon = 132347,
            content = {
                TabGroup
            }
        },
        Builder:TreeBranch {
            title = "Fury Info",
            icon = 132352,
            content = {
                TypographyTabGroup
            }
        }
    }
}

local Window = Builder:Window {
    key = "vexFury",
    title = "|cff51322DVex Fury Warrior",
    width = 800,
    height = 480,
    content = {
        TreeGroup
    }
}

local MyRoutineWindow

local function GetDropdownValues()
    local xKey = Builder:GetConfig("alertXPosition", "option_e")
    local yKey = Builder:GetConfig("alertYPosition", "option_j")

    local xValue = alertXPositionValues[xKey]
    local yValue = alertYPositionValues[yKey]

    return tostring(xValue), tostring(yValue)
end

local function GetDropdownValuesStatic()
    local xKey = Builder:GetConfig("alertXPositionStatic", "option_g")
    local yKey = Builder:GetConfig("alertYPositionStatic", "option_j")

    local xValue = alertXPositionValues[xKey]
    local yValue = alertYPositionValues[yKey]

    return tostring(xValue), tostring(yValue), true
end

local function ResetGUIState()
    Builder:SetConfig("input_tabs", nil)
    Builder:SetConfig("example_tree", nil)
    Builder:SetConfig("keybind_tabs", nil)
end
local MyCommands = Tinkr.Util.Commands:New("drgdgdrgdrgdrgdrgdrgdrgdr")
MyCommands:Register("config", function()
    ResetGUIState()  -- Call this before opening the GUI
    if not MyRoutineWindow then
        MyRoutineWindow = Builder:Build(Window)
        MyRoutineWindow.frame:SetScript("OnHide", function(self)
            self:Hide()
        end)
    elseif MyRoutineWindow:IsShown() then
        MyRoutineWindow:Hide()
    else
        MyRoutineWindow:Show()
    end
end, "Shows the config options window")

-- Create the erButton
local erButton = CreateFrame("Button", "erButton", UIParent, "UIPanelButtonTemplate")
erButton:SetSize(70, 70) -- Increase the button size

-- Set default icon for the button
local function UpdateButtonAppearance(button)
    if button.isEnabled then
        button:SetNormalTexture("Interface\\Icons\\Artifactability_feraldruid_ashamanesbite")
        button.text:SetText("Enabled")
    else
        button:SetNormalTexture("Interface\\Icons\\Artifactability_feraldruid_ashamanesbite")
        button.text:SetText("Disabled")
    end
end

-- Function to save button position
local function SaveButtonPosition()
    local point, relativeTo, relativePoint, xOfs, yOfs = erButton:GetPoint()
    local relativeToName = relativeTo and relativeTo:GetName() or "UIParent"
    Builder:SetConfig("erButtonPos", { point, relativeToName, relativePoint, xOfs, yOfs })
end

-- Make the button draggable
erButton:SetMovable(true)
erButton:EnableMouse(true)
erButton:RegisterForDrag("LeftButton")
erButton:SetScript("OnDragStart", erButton.StartMoving)
erButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveButtonPosition()
end)

-- Add a property to the button to store the state
erButton.isEnabled = true

-- Add text overlay
erButton.text = erButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
erButton.text:SetPoint("CENTER", erButton, "CENTER", 0, 0)

local function ToggleButton()
    erButton.isEnabled = not erButton.isEnabled
    UpdateButtonAppearance(erButton)
end

erButton:SetScript("OnClick", ToggleButton)
UpdateButtonAppearance(erButton) -- Set the default appearance

-- Load button position from config
local pos = Builder:GetConfig("erButtonPos", { "BOTTOMLEFT", "ChatFrame1", "TOPLEFT", 30, 30 })
local relativeTo = _G[pos[2]] or UIParent
erButton:SetPoint(pos[1], relativeTo, pos[3], pos[4], pos[5])

-- Slash command to show or hide the button
MyCommands:Register("button", function()
    if erButton:IsShown() then
        erButton:Hide()
        print("Button hidden")
    else
        erButton:Show()
        print("Button shown")
    end
end, "Toggles the visibility of the button")

-- Function to ensure all default values are saved, but without overriding user's changes
local function InitializeConfigDefaults()
    -- List of default config values
    local defaultConfig = {
        -- General Settings
        leftShiftPause = "yes",
        pveMode = "no",
        combatMode = "yes",

        -- Defensive Settings
        autoERage = "yes",
        autoBI = "yes",
        autoRC = "yes",
        autoStance = "yes",

        -- Drawing Settings
        enableMeleeDraw = "yes",
        enableESP = "yes",
        fearDraw = "no",

        -- Dropdown for alert X and Y position
        alertXPosition = "option_e",  -- Default to -100
        alertYPosition = "option_j",  -- Default to 400

        -- Dropdown for static alert X and Y position
        alertXPositionStatic = "option_g",  -- Default to 100
        alertYPositionStatic = "option_j",  -- Default to 400

        -- Sliders for defensive health percentages
        erageSlider = 60,  -- Default is 60% for Enraged Regeneration
        biSlider = 50,    -- Default is 50% for Bitter Immunity
        rcSlider = 25,    -- Default is 25% for Rallying Cry
        dSlider = 45,      -- Default is 45% for Defensive Stance swap

        --keybinds
        burstBind = "SHIFT-ALT-0",
        sbeHealer = "SHIFT-ALT-1",
        sbTarget = "SHIFT-ALT-2",
        sweHealer = "SHIFT-ALT-3",
        swTarget = "SHIFT-ALT-4",
        hleHealer = "SHIFT-ALT-5",
        hlfhealer = "SHIFT-ALT-6",
    }

    -- Loop through the defaultConfig and ensure each value is set in the Builder
    -- Only set the default value if no value is present in the config file
    for key, defaultValue in pairs(defaultConfig) do
        local currentValue = Builder:GetConfig(key, nil)
        if currentValue == nil then
            -- This will implicitly save the value to the file
            Builder:SetConfig(key, defaultValue)
        end
    end
end

-- Call the function to initialize defaults when the script loads
InitializeConfigDefaults()

------ this is an example of how to call a spell alert! the GetDropdownValues will grab the X and Y
------ coordiante from the GUIBuilder
Alert(5308, "Alerts are online!", GetDropdownValues())
------------------------------ set tick rate -----------------------------
_G.TickRate = 0.01
------------------------------------------------------------start drawings
function calculateMidpoint(x, y, z, targetX, targetY, targetZ)
    local midpointX = (x + targetX) / 2
    local midpointY = (y + targetY) / 2
    local midpointZ = (z + targetZ) / 2

    return midpointX, midpointY, midpointZ
end

local function getClassColor(classId)
    local classColors = {
        [1] = { 198, 155, 109 },                             -- Warrior
        [2] = { 244, 140, 186 },                             -- Paladin
        [3] = { 170, 211, 114 },                             -- Hunter
        [4] = { 255, 244, 104 },                             -- Rogue
        [5] = { 255, 255, 255 },                             -- Priest
        [6] = { 102, 0, 0 },                                 -- Death Knight
        [7] = { 0, 112, 221 },                               -- Shaman
        [8] = { 63, 199, 235 },                              -- Mage
        [9] = { 135, 136, 238 },                             -- Warlock
        [10] = { 0, 255, 152 },                              -- Monk
        [11] = { 255, 124, 10 },                             -- Druid
        [12] = { 163, 48, 201 },                             -- Demon Hunter
        [13] = { 51, 147, 127 }                              -- Evoker (if applicable)
    }
    return unpack(classColors[classId] or { 135, 136, 238 }) -- Default color
end

Draw:Sync(function(draw)
    local x, y, z = Position("player")
    local target = UnitGUID("target")
    if Builder:GetConfig("enableESP") == "yes" then
        if target then
            local targetX, targetY, targetZ = Position("target")
            local _, _, classId = UnitClass("target")
            if Distance(target, "player") < 40 and los(target, "player") then
                draw:SetColor(getClassColor(classId))
            else
                draw:SetColor(247, 76, 64, 255)
            end
            draw:SetWidth(3)
            draw:Line(x, y, z, targetX, targetY, targetZ)
        end
    end
    --melee range
    if Builder:GetConfig("enableMeleeDraw") == "yes" then
        local facing = Facing()
        if facing ~= nil and UnitExists("target") and UnitCanAttack("player","target") and Alive("target") then
            if x and y and z then
                if InMelee("target") and IsFacing("target") then
                    draw:SetColor(0,255,0)
                else
                    draw:SetColor(255,0,0)
                end
            end
            draw:SetWidth(2)
            draw:Arc(x, y, z, 5.99, 120, facing)
        end
    end
    --fear radius
    if Builder:GetConfig("fearDraw") == "yes" then
        if SpellCd(5246) <= gcd() and InPvp() then
            local x1, y1, z1 = Position("player")
            if x1 and y1 and z1 then
                draw:SetColor(178,102,255)
                draw:Circle(x1,y1,z1,8)
            end
        end
    end
end)
Draw:Enable()
-------------------------- lists start --------------------------------------
Elite:Populate({
    barkskin = NewSpell(22812, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    berserk = NewSpell(106951, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    shadowMeld = NewSpell(58984, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    regrowth = NewSpell(8936, { beneficial = true, ignoreMoving = true, ignoreGCD = true, targeted = true }),
    heartOfTheWild = NewSpell(319454, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    renewal = NewSpell(108238, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    incarnation = NewSpell(102543, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    wildGrowth = NewSpell(48438, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    typhoon = NewSpell(132469, { beneficial = true, ignoreMoving = true, ignoreGCD = true, facehack = true, targeted = false }),
    stampedingRoar = NewSpell(106898, { beneficial = true, ignoreMoving = true }),
    frenziedRegeneration = NewSpell(22842, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    survivalInstincts = NewSpell(61336, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    bearForm = NewSpell(5487, { beneficial = true, ignoreMoving = true }),
    catForm = NewSpell(768, { beneficial = true, ignoreMoving = true }),
    travelForm = NewSpell(783, { beneficial = true, ignoreMoving = true }),
    dash = NewSpell(1850, { beneficial = true, ignoreMoving = true, ignoreGCD = true }),
    entanglingRoots = NewSpell(339, { damage = "magic", ignoreFacing = true, cc = "root" }),
    ferociousBite = NewSpell(22568, { damage = "physical", targeted = true, ignoreMoving = true, facehack = true }),
    adaptiveSwarm = NewSpell(391888, { damage = "magic", targeted = true, ignoreMoving = true }),
    feralFrenzy = NewSpell(274837, { damage = "physical", targeted = true, ignoreMoving = true }),
    mangle = NewSpell(33917, { damage = "physical", targeted = true, ignoreMoving = true }),
    markOfTheWild = NewSpell(1126,{ beneficial = true, ignoreMoving = true, targeted = true }),
    moonfire = NewSpell(8921, { targeted = true, damage = "magic", ignoreMoving = true }),
    moonfireCat = NewSpell(155625, { targeted = true, damage = "magic", ignoreMoving = true }), 
    prowl = NewSpell(5215, { beneficial = true, ignoreMoving = true }),
    rake = NewSpell(1822, { damage = "physical", targeted = true, ignoreMoving = true, facehack = true, cc = "stun" }),
    rip = NewSpell(1079, { damage = "physical", targeted = true, ignoreMoving = true, facehack = true }),
    shred = NewSpell(5221, { damage = "physical", targeted = true, ignoreMoving = true }),
    swipe = NewSpell(106785, { damage = "physical", ignoreMoving = true }),
    brutalSlash = NewSpell(202028, { damage = "physical", ignoreMoving = true }),
    primalWrath = NewSpell(285381, { damage = "physical", ignoreMoving = true }),
    maim = NewSpell(22570, { damage = "physical", targeted = true, ignoreMoving = true, cc = "stun", facehack = true }),
    thrash = NewSpell(106830, { damage = "physical", targeted = true, ignoreMoving = true }),
    tigerFury = NewSpell(5217, { beneficial = true, ignoreMoving = true, ignoreGCD = true  }),
    skullBash = NewSpell(106839, { targeted = true, ignoreMoving = true, facehack = true, ignoreGCD = true }),
    ursolsVortex = NewSpell(102793, { targeted = false, damage = "magic", ignoreFacing = true, ignoreMoving = true }),
    removeCorruption = NewSpell(2782, { beneficial = true, ignoreMoving = true, targeted = true }),
    wildChargeFriendly = NewSpell(102401, { beneficial = true, ignoreMoving = true, targeted = true, facehack = true }),
    wildCharge = NewSpell(49376, { ignoreMoving = true, targeted = true, facehack = true }),
    cyclone = NewSpell(33786, { damage = "magic", ignoreFacing = true, cc = "disorient" }),
    mightyBash = NewSpell(5211, { targeted = true, ignoreMoving = true, facehack = true, cc = "stun", ignoreGCD = true, facehack = true }),

    -- Racials
    berserking = NewSpell(33697, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    bloodFury = NewSpell(20572, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    bloodFury2 = NewSpell(33702, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    bloodFury3 = NewSpell(20572, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    fireBlood = NewSpell(265221, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    escapeArtist = NewSpell(20589, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    -- PVP BUFFS
    arenaPrep = NewSpell(32727, { beneficial = true }),
    bgPrep = NewSpell(44521, { beneficial = true }),
    -- Rogue evasion
    evasion = NewSpell(5277, { beneficial = true }),
    cloakOfShadows = NewSpell(31224, { beneficial = true }),
    -- Warlock gate
    demonicGateway = NewSpell(111771, { beneficial = true }),
    -- Shaman groundingTotemBuff
    groundingTotemBuff = NewSpell(8178, { beneficial = true }),
    -- DH blur
    blur = NewSpell(212800, { beneficial = true }),
    -- Vortex druid
    vortex = NewSpell(127797, { beneficial = true }),
})

------------------------------------ variables ------------------------------------
local pvpStoneUsed = false
local doubleMeleeCheck = true
local rogueCheck = false
local rogueOnTeam = false
local randomKick = math.random(60, 80) + Buffer()
local randomKickChannel = math.random(30, 40) + Buffer()
------------------------------------ lists ----------------------------------------
local totem1 = {
    [105451] = true, -- counterstrikeTotem
    [5913] = true,   -- tremorTotem
    [5925] = true,   -- groundingTotem
    [105427] = true, -- skyfuryTotem
    [6112] = true,   -- windfuryTotem
    [61245] = true,  -- capacitorTotem
    [53006] = true,  -- spiritLinkTotem
    [60561] = true, -- earthgrab totem
}

local totem2 = {
    [179867] = true, -- staticFieldTotem
    [59764] = true,  -- healingTideTotem
}

local pvpStomps = {
    [179193] = true, -- observer
    [107100] = true, -- observer2
    [101398] = true, -- psyfiend
    [119052] = true, -- warBanner
}
local externalDefensiveBuff = {
    184364, -- enragedRegen
    370960, -- emeraldCommune
    199452, -- ultimateSacrifice
    116849, -- lifeCocoon
    363534, -- rewind
    47788,  -- guardianSpirit
    22812, --barkskin
    61336, --survivalInstincts
}
local externalDefensiveBuffIV = {
    199452, -- ultimateSacrifice
    116849, -- lifeCocoon
    47788,  -- guardianSpirit
}
local reflectListCCDR = {
    [33786]  = 0.5, -- cyclone
    [118]    = 0.5, -- polymorph
    [28271]  = 0.5, -- polymorphTurtle
    [28272]  = 0.5, -- polymorphPig
    [61025]  = 0.5, -- polymorphSnake
    [61305]  = 0.5, -- polymorphBlackCat
    [61780]  = 0.5, -- polymorphTurkey
    [61721]  = 0.5, -- polymorphRabbit
    [126819] = 0.5, -- polymorphPorcupine
    [161353] = 0.5, -- polymorphPolarBearCub
    [161354] = 0.5, -- polymorphMonkey
    [161355] = 0.5, -- polymorphPenguin
    [161372] = 0.5, -- polymorphPeacock
    [277787] = 0.5, -- polymorphBabyDirehorn
    [277792] = 0.5, -- polymorphBumblebee
    [321395] = 0.5, -- polymorphMawrat
    [391622] = 0.5, -- polymorphDuck
    [51514]  = 0.5, -- hex
    [196942] = 0.5, -- hexVoodooTotem
    [210873] = 0.5, -- hexRaptor
    [211004] = 0.5, -- hexSpider
    [211010] = 0.5, -- hexSnake
    [211015] = 0.5, -- hexCockroach
    [269352] = 0.5, -- hexSkeletalHatchling
    [309328] = 0.5, -- hexLivingHoney
    [277778] = 0.5, -- hexZandalariTendonripper
    [277784] = 0.5, -- hexWickerMongrel
    [20066]  = 0.5, -- repentance
    [360806] = 0.5, -- sleepWalk
}
local reflectListCC = {
    [33786]  = true, -- cyclone
    [118]    = true, -- polymorph
    [28271]  = true, -- polymorphTurtle
    [28272]  = true, -- polymorphPig
    [61025]  = true, -- polymorphSnake
    [61305]  = true, -- polymorphBlackCat
    [61780]  = true, -- polymorphTurkey
    [61721]  = true, -- polymorphRabbit
    [126819] = true, -- polymorphPorcupine
    [161353] = true, -- polymorphPolarBearCub
    [161354] = true, -- polymorphMonkey
    [161355] = true, -- polymorphPenguin
    [161372] = true, -- polymorphPeacock
    [277787] = true, -- polymorphBabyDirehorn
    [277792] = true, -- polymorphBumblebee
    [321395] = true, -- polymorphMawrat
    [391622] = true, -- polymorphDuck
    [51514]  = true, -- hex
    [196942] = true, -- hexVoodooTotem
    [210873] = true, -- hexRaptor
    [211004] = true, -- hexSpider
    [211010] = true, -- hexSnake
    [211015] = true, -- hexCockroach
    [269352] = true, -- hexSkeletalHatchling
    [309328] = true, -- hexLivingHoney
    [277778] = true, -- hexZandalariTendonripper
    [277784] = true, -- hexWickerMongrel
    [20066]  = true, -- repentance
    [360806] = true, -- sleepWalk
}
local reflectListDMG = {
    [407466] = true, -- mindSpikeInsanity
    [375901] = true, -- mindGames
    [116858] = true, -- chaosBolt
    [203286] = true, -- greaterPyro
    [199786] = true, -- glacialSpike
    [6353] = true,   -- soulFire
    [365350] = true, -- arcaneSurge
    [274283] = true, -- fullMoon
    [274282] = true, -- halfMoon
    [396286] = true, -- upheavel
    [390612] = true, -- frost bomb
    [167385] = true, -- UberStrike
    [335642] = true, -- UberStrike2
    [342938] = true, -- unstableAffliction
    [316099] = true, -- unstableAfflictionNoTalent
}
interruptListHealer = {
    [8936] = true,   -- regrowth
    [2061] = true,   -- flashHeal
    [8004] = true,   -- healingSurge
    [82326] = true,  -- holyLight
    [19750] = true,  -- flashOfLight
    [200652] = true, -- tyrsDeliverance
    [64843] = true,  -- divineHymn
    [367226] = true, -- spiritbloom
    [355936] = true, -- dreamBreath
    [1064] = true,   -- chainHeal
    [421453] = true, -- ultimatePenitence
}

chanlists = {
    --[305483] = true, -- lightningLasso
    --[305485] = true, -- lightningLasso
    [605] = true,    -- mindControl
    [205021] = true, -- rayOfFrost
    [263165] = true, -- voidTorrent
    [417537] = true, -- oblivion
    [391401] = true, -- mindflayinsanity
    [382411] = true, -- eternitySurge
    [357208] = true, -- fireBreath
    [234153] = true, -- drain life
    [356995] = true, -- disintegrate
    [382440] = true, -- shifting powers
}

chanListHeals = {
    [115175] = true, -- soothingMist
    [186723] = true, -- penance
    [47540] = true, -- penance 2
    [400169] = true, -- penance 3
    [47758] = true, -- penance 4
    [382614] = true, -- dream breath
    [382731] = true, -- spirit bloom
    [377509] = true, -- dream projection
}

hexList = {
    [51514] = true,  -- hex
    [196942] = true, -- hexVoodooTotem
    [210873] = true, -- hexRaptor
    [211004] = true, -- hexSpider
    [211010] = true, -- hexSnake
    [211015] = true, -- hexCockroach
    [269352] = true, -- hexSkeletalHatchling
    [309328] = true, -- hexLivingHoney
    [277778] = true, -- hexZandalariTendonripper
    [277784] = true, -- hexWickerMongrel
}

interruptList = {
    [48181] = true, --haunt
    [51505] = true, --lavaburst
    [431044] = true, --frostfire bolt
    [120644] = true, --halo
    [686] = true, -- shadow bolt
    [34914] = true,  -- vamp touch
    [404977] = true, -- timeSkip
    [410126] = true, -- searingGlare
    [377509] = true, -- dreamProjection
    [407466] = true, -- mindSpikeInsanity
    [395160] = true, -- eruption
    [375901] = true, -- mindGames
    [118] = true,    -- polymorph
    [28271] = true,  -- polymorphTurtle
    [28272] = true,  -- polymorphPig
    [61025] = true,  -- polymorphSnake
    [61305] = true,  -- polymorphBlackCat
    [61780] = true,  -- polymorphTurkey
    [61721] = true,  -- polymorphRabbit
    [126819] = true, -- polymorphPorcupine
    [161353] = true, -- polymorphPolarBearCub
    [161354] = true, -- polymorphMonkey
    [161355] = true, -- polymorphPenguin
    [161372] = true, -- polymorphPeacock
    [277787] = true, -- polymorphBabyDirehorn
    [277792] = true, -- polymorphBumblebee
    [321395] = true, -- polymorphMawrat
    [391622] = true, -- polymorphDuck
    [51514] = true,  -- hex
    [196942] = true, -- hexVoodooTotem
    [210873] = true, -- hexRaptor
    [211004] = true, -- hexSpider
    [211010] = true, -- hexSnake
    [211015] = true, -- hexCockroach
    [269352] = true, -- hexSkeletalHatchling
    [309328] = true, -- hexLivingHoney
    [277778] = true, -- hexZandalariTendonripper
    [277784] = true, -- hexWickerMongrel
    [323764] = true, -- convoke
    [20066] = true,  -- repentance
    [113724] = true, -- ringOfFrost
    [33786] = true,  -- cyclone
    [605] = true,    -- mindControl
    [198898] = true, -- songOfChiji
    [5782] = true,   -- fear
    [2637] = true,   -- hibernate
    [710] = true,    -- banish
    [360806] = true, -- sleepWalk
    [691] = true,    -- summonFelhunter
    [688] = true,    -- summonImp
    [712] = true,    -- summonSuccubus
    [32375] = true,  -- massDispel
    [314791] = true, -- shiftingPower
    [982] = true,    -- revivePet
    [191634] = true, -- stormkeeper
    [326434] = true, -- kindredSpirits
    [234153] = true, -- drainLife
    [116858] = true, -- chaosBolt
    [203286] = true, -- greaterPyro
    [199786] = true, -- glacialSpike
    [6353] = true,   -- soulFire
    [342938] = true, -- unstableAffliction
    [316099] = true, -- unstableAfflictionNoTalent
    [265187] = true, -- summonTyrant
    [365350] = true, -- arcaneSurge
    [202347] = true, -- stellarFlare
    [378464] = true, -- nullifyingShroud
    [274283] = true, -- fullMoon
    [274282] = true, -- halfMoon
    [200652] = true, -- tyrsDeliverance
    [30283] = true,  -- shadowFury
    [30146] = true,  -- summonfelguard
    [390612] = true, -- frostBomb
    [104316] = true, -- callDreadStalkers
    [133] = true,    -- fireBall
    [116] = true,    -- frostBolt
    [395152] = true, -- ebonMight
    [396286] = true, -- upheavel
    [324536] = true, -- maleficRapture
    [8936] = true,   -- regrowth
    [2061] = true,   -- flashHeal
    [8004] = true,   -- healingSurge
    [82326] = true,  -- holyLight
    [19750] = true,  -- flashOfLight
    [200652] = true, -- tyrsDeliverance
    [64843] = true,  -- divineHymn
    [367226] = true, -- spiritbloom
    [355936] = true, -- dreamBreath
    [1064] = true,   -- chainHeal
    [421453] = true, -- ultimatePenitence
}
specialInterrupt = {
    [113656] = true, -- fistOfFury
    [257044] = true, -- rapidFire
    [203155] = true, -- sniperShot
}
berserkerRageList = {
    5782,   -- fear
    5484,   -- howlofTerror
    6358,   -- Seduction
    360806, -- sleepWalk
    8122,   -- psychicScream
    316593, -- intimidatingShout
    5246,   -- intimidatingShout2
    20066,  -- repentance
    1776,   -- gouge
    207685, -- sigilOfMisery
    115078, -- paralysis
}
shatterList = {
    45438, -- iceBlock
    642, -- divineShield
}
wreckList = {
    116849, -- lifeCocoon
    17, -- pws
    108416, -- dark pact
    198111, -- temporalShield
    11426, -- iceBarrier
    235450, -- prismaticBarrier
    235313, -- blazingBarrier
    382290, -- tempestBarrier
}
okayHit = {
    8122, --psychic scream
    207167, -- blinding sleet
    5246, -- intimidatingShout1
    316593, -- intimidatingShout2
    316595, -- intimidatingShout3
}
------------------------ functions start ------------------------------------
function bloodthirstCrit()
    local recklessnessCrit = 0
    local bloodcrazeCrit = 0
    bloodcrazeCrit = GetBuffCount(393951,"player") * 15
    if HasBuff(e.recklessness.id,"player") then recklessnessCrit = 20 end
    return recklessnessCrit + bloodcrazeCrit
end
function BrsrkRageCheck()
    for i = 1, #berserkerRageList do
        local fear = berserkerRageList[i]
        if HasDebuff(fear, "player") then
            return GetDebuffRemaining(fear, "player")
        end
    end
    return 0
end

function rslider(num)
    -- Generate a random number between -2 and 2
    local random_offset = math.random(-2, 2)

    -- Apply the offset to the input number
    local randomized_number = num + random_offset

    -- Ensure the number doesn't go below 1
    if randomized_number < 1 then
        return 1
    end

    return randomized_number
end

function backToCatForm()
    if Used("player", 5211, 4) then return end --bash
    if TrueHealthP("player") < 35 then return end
    if HasBuff(768,"player") then return end --catForm--
    if catForm:Cast() then
        return
    end
end

function defensiveBear()
    if TrueHealthP("player") > 35 then return end
    if HasBuff(5487,"player") then return end --bearForm--
    if bearForm:Cast() then
        return
    end
end

function rootRemove()
    if HitboxDistance("target", "player") <= 6 then return end
    if not Alive("player") then return end
    if not Rooted("player") then return end
    if bearForm:Cast() then
        return
    end
end

function slowRemove()
    if HitboxDistance("target", "player") <= 10 then return end
    if not Alive("player") then return end
    if Speed("player") > 7 then return end
    if not Moving("player") then return end
    if bearForm:Cast() then
        return
    end
end

Elite.StompTotems(function(totem, totemId)
    if Used("player", 155625, 5) then return end --moonfire
    if totem1[totemId] and CanCast(e.moonfire.id) and HitboxDistance(totem, "player") < 45 then
        FaceSmooth(totem, e.moonfire.id, "Stomping - " .. Name(totem), GetDropdownValues())
        return
    end
    if totem2[totemId] and CanCast(e.moonfire.id) and HitboxDistance(totem, "player") < 45 then
        FaceSmooth(totem, e.moonfire.id, "Stomping - " .. Name(totem), GetDropdownValues())
        return
    end
end, 0.5)
--- stomp PvP Objects from the pvpobjects list
--- these object IDs include 179193, 101398, 119052
Elite.Stomp(function(pobject, stompItemID)
    if Used("player", 155625, 5) then return end --moonfire
    if pvpStomps[stompItemID] and CanCast(e.moonfire.id) and HitboxDistance(pobject, "player") < 45 then
        FaceSmooth(pobject, e.moonfire.id, "Stomping - " .. Name(pobject), GetDropdownValues())
        return
    end
    if pvpStomps[stompItemID] and CanCast(e.moonfire.id) and HitboxDistance(pobject, "player") < 45 then
        FaceSmooth(pobject, e.moonfire.id, "Stomping - " .. Name(pobject), GetDropdownValues())
        return
    end
end, 0.2)

local function defensiveBuffCheck(unit)
    if unit then
        for i = 1, #externalDefensiveBuff do
            local aura = externalDefensiveBuff[i]
            if HasBuff(aura, unit) then
                return true
            end
        end
    end
    return false
end
local function defensiveBuffCheckIV(unit)
    if unit then
        for i = 1, #externalDefensiveBuffIV do
            local aura = externalDefensiveBuffIV[i]
            if HasBuff(aura, unit) then
                return true
            end
        end
    end
    return false
end
local function TrinketsRacials()
    if (HitboxDistance("target", "player") > 6) then return end
    if CanCast(e.berserking.id) then
        Cast(e.berserking.id, "player")
    end
    if CanCast(e.bloodFury.id) then
        Cast(e.bloodFury.id, "player")
    end
    if CanCast(e.bloodFury2.id) then
        Cast(e.bloodFury2.id, "player")
    end
    if CanCast(e.bloodFury3.id) then
        Cast(e.bloodFury3.id, "player")
    end
    --if CanCast(e.fireBlood.id) then
    --    Cast(e.fireBlood.id, "player")
    --end
    UseEquippedItemByID(218713) -- conq s1
    UseEquippedItemByID(218421) -- honor s1
end

function SwapCheck()
    for _,friend in pairs(friends) do
        if Used(friend.key,108968,2) then return true end
    end
    return false
end

------------------Callbacks-----------------------------------------
shred:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        return
    end
end)

shred:Callback("bloodtalons",function(spell)
    if Used("player", 5221, 4) then return end --shred
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "BT", GetDropdownValues())
        return
    end
end)

rip:Callback(function(spell)
    if GetDebuffRemaining(1079 ,"target") > 3 then return end --rip
    --if not HasBuff(145152,"player") then return end --bloodtalons--
    if ComboPoints("player") < 5 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

rip:Callback("aoe", function(spell)
    if ComboPoints("player") < 5 then return end
    --if not HasBuff(145152,"player") then return end --bloodtalons--
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end 
        if GetDebuffRemaining(1079 ,enemy.key) > 3 then return false end --rip
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "AOE", GetDropdownValues())
            return true
        end
    end)
end)

rip:Callback("MINIONS", function(spell)
    if ComboPoints("player") < 5 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if GetDebuffRemaining(1079 ,enemy.key) > 3 then return false end --rip
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "MINIONS", GetDropdownValues())
            return true
        end
    end)
end)

maim:Callback(function(spell)
    if ComboPoints("player") < 5 then return end
    if not IsPlayer("target") then return end 
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if dr("target", 22570) < 1 then return end --maim
    if spell:Cast("target") then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

maim:Callback("aoe", function(spell)
    if ComboPoints("player") < 5 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if dr(enemy.key, 22570) < 1 then return false end --maim
        if not IsPlayer(enemy.key) then return false end 
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "AOE", GetDropdownValues())
            return true
        end
    end)
end)

rake:Callback("stun", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if dr("target", 1822) < 1 then return end --rake
    if not IsPlayer("target") then return end 
    shadowMeld:Cast()
    if not HasBuff(58984 ,"player") then return end
    if spell:Cast("target") then
        Alert(spell.id, "stun TARGET", GetDropdownValues())
        return
    end
end)

rake:Callback("stunAoe", function(spell)
    ObjectsLoop(enemies, function(enemy, guid)
        if dr(enemy.key, 1822) < 1 then return false end --rake
        if not IsPlayer(enemy.key) then return false end 
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        shadowMeld:Cast()
        if not HasBuff(58984 ,"player") then return end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "stun AOE", GetDropdownValues())
            return true
        end
    end)
end)

wildChargeFriendly:Callback(function(spell)
    if HitboxDistance("target", "player") < 15 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

ursolsVortex:Callback(function(spell)
    if HitboxDistance("target", "player") < 15 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

dash:Callback(function(spell)
    if HitboxDistance("target", "player") < 10 then return end
    if Speed("player") > 10 then return end
    if HasBuff(77764,"player") then return end --stampedingRoar
    if Used("player", 77764, 1) then return end --stampedingRoar
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast() then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

stampedingRoar:Callback(function(spell)
    if HitboxDistance("target", "player") < 10 then return end
    if Speed("player") > 10 then return end
    if HasBuff(1850,"player") then return end --dash
    if Used("player", 1850, 1) then return end --dash
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast() then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

ferociousBite:Callback(function(spell)
    if ComboPoints("player") < 5 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

ferociousBite:Callback("proc", function(spell)
    if not HasBuff(391882,"player") then return end --apex--
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "PROC", GetDropdownValues())
        return
    end
end)

feralFrenzy:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        return
    end
end)

feralFrenzy:Callback("incarn", function(spell)
    if not HasBuff(102543, "player") then return end --incarn
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        return
    end
end)

moonfire:Callback(function(spell)
    if Used("player", 155625, 1) then return end --moonfire
    if GetDebuffRemaining(155625 ,"target") > 3 then return end --moonfire
    if ComboPoints("player") >= 5 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "TARGET", GetDropdownValues())
        return
    end
end)

moonfire:Callback("bloodtalons",function(spell)
    if ComboPoints("player") >= 5 then return end
    if Used("player", 155625, 4) then return end --moonfire
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "BT", GetDropdownValues())
        return
    end
end)

moonfire:Callback("aoe", function(spell)
    if Used("player", 155625, 1) then return end --moonfire
    if ComboPoints("player") >= 5 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end 
        if GetDebuffRemaining(155625 ,enemy.key) > 3 then return false end --moonfire
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "AOE", GetDropdownValues())
            return true
        end
    end)
end)

rake:Callback(function(spell)
    if GetDebuffRemaining(155722 ,"target") > 3 then return end --rake
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        return
    end
end)

rake:Callback("aoe", function(spell)
    ObjectsLoop(enemies, function(enemy, guid)
        if GetDebuffRemaining(155722 ,enemy.key) > 3 then return false end --rake
        if not IsPlayer(enemy.key) then return false end 
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "AOE", GetDropdownValues())
            return true
        end
    end)
end)

rake:Callback("MINIONS", function(spell)
    if ComboPoints("player") >= 5 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if GetDebuffRemaining(155722 ,enemy.key) > 3 then return false end --rake
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "MINIONS", GetDropdownValues())
            return true
        end
    end)
end)

entanglingRoots:Callback(function(spell)
    if not HasBuff(69369, "player") then return end --pred swiftness
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end 
        if dr(enemy.key, 339) < 1 then return false end --entanglingRoots
        if Rooted(enemy.key) then return false end
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "AOE", GetDropdownValues())
            return true
        end
    end)
end)


adaptiveSwarm:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast("target") then
        return
    end
end)

brutalSlash:Callback(function(spell)
    if ComboPoints("player") >= 5 then return end 
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if HitboxDistance("target", "player") > 8 then return end
    if spell:Cast() then
        return
    end
end)

brutalSlash:Callback("bloodtalons", function(spell)
    if Used("player", 202028, 4) then return end --brutalslash
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if HitboxDistance("target", "player") > 8 then return end
    if spell:Cast() then
        Alert(spell.id, "BT", GetDropdownValues())
        return
    end
end)

tigerFury:Callback(function(spell)
    if Energy("player") > 100 then return end
    if HitboxDistance("target", "player") > 8 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast() then
        return
    end
end)

tigerFury:Callback("engage", function(spell)
    if HitboxDistance("target", "player") > 8 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast() then
        return
    end
end)

berserk:Callback(function(spell)
    if HitboxDistance("target", "player") > 8 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast() then
        return
    end
end)

incarnation:Callback(function(spell)
    if HitboxDistance("target", "player") > 8 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target",okayHit) then return end
    if spell:Cast() then
        return
    end
end)

survivalInstincts:Callback(function(spell)
    if not Alive("player") then return end
    if SwapCheck() then return end
    if TrueHealthP("player") > 50 then return end
    if defensiveBuffCheck("player") then return end
    if spell:Cast() then
        return
    end
end)

prowl:Callback(function(spell)
    if not Alive("player") then return end
    if HasBuff(5215 ,"player") then return end --prowl
    if not HasBuff(768 ,"player") then return end --catform
    if spell:Cast() then
        return
    end
end)

frenziedRegeneration:Callback(function(spell)
    if TrueHealthP("player") > 90 then return end
    if not HasBuff(5487,"player") then return end --bearForm--
    if spell:Cast() then
        return
    end
end)

mangle:Callback(function(spell)
    if not HasBuff(5487,"player") then return end --bearForm--
    if spell:Cast() then
        return
    end
end)

renewal:Callback(function(spell)
    if not Alive("player") then return end
    if SwapCheck() then return end
    if TrueHealthP("player") > 70 then return end
    if defensiveBuffCheck("player") then return end
    if spell:Cast() then
        return
    end
end)

barkskin:Callback(function(spell)
    if not Alive("player") then return end
    if SwapCheck() then return end
    if TrueHealthP("player") > 70 then return end
    if defensiveBuffCheck("player") then return end
    if spell:Cast() then
        return
    end
end)

regrowth:Callback(function(spell)
    if TrueHealthP("player") > 50 then return end
    if Used("player", 8936, 1) then return end
    if not HasBuff(69369,"player") then return end
    if spell:Cast("player") then
        Alert(spell.id, "MYSELF", GetDropdownValues())
        return
    end
end)

regrowth:Callback("AOE",function(spell)
    if not HasBuff(69369,"player") then return end
    if Used("player", 8936, 1) then return end
    ObjectsLoop(friends, function(friend, guid)
        if TrueHealthP(friend.key) > 50 then return false end
        if not IsPlayer(friend.key) then return false end
        if not Alive(friend.key) then return false end
        if spell:Cast(friend.key) then
            Alert(spell.id, "AOE", GetDropdownValues())
            return true
        end
    end)
end)

skullBash:Callback("heals", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if HasBuff(e.groundingTotemBuff.id, "player") then return false end
        if not IsPlayer(enemy.key) then return false end
        if not IsCastingT(enemy.key, interruptListHealer) then return false end
        if not CanInterruptCast(enemy.key) then return false end
        if not interruptAt(enemy.key,randomKick) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

skullBash:Callback("healsChan", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsChannelingT(enemy.key, chanListHeals) then return false end
        if not CanInterruptChannel(enemy.key) then return false end
        if not interruptAt(enemy.key,randomKickChannel) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

skullBash:Callback(function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if HasBuff(e.groundingTotemBuff.id, "player") then return false end
        if not IsPlayer(enemy.key) then return false end
        if not IsCastingT(enemy.key, interruptList) then return false end
        if not CanInterruptCast(enemy.key) then return false end
        if not interruptAt(enemy.key,randomKick) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

skullBash:Callback("chan",function(spell)
    if SpellCd(spell.id) > gcd() then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsChannelingT(enemy.key, chanlists) then return false end
        if not CanInterruptChannel(enemy.key) then return false end
        if not interruptAt(enemy.key,randomKickChannel) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

markOfTheWild:Callback(function(spell)
    if Used("player", 1126, 10) then return end --markOfTheWild
    ObjectsLoop(friends, function(friend, guid)
        if not IsPlayer(friend.key) then return false end
        if HasBuff(1126,friend.key) then return false end
        if not Alive(friend.key) then return false end
        if spell:Cast(friend.key) then
            Alert(spell.id, "BUFF", GetDropdownValues())
            return true
        end
    end)
end)

mightyBash:Callback("healer", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    if not eHealer then return end
    if not Alive(eHealer.key) or not IsEnemy(eHealer.key) then return end
    if bcc(eHealer.key) and not DebuffFrom(eHealer.key,okayHit) then return end
    if dr(eHealer.key,spell.id) < 1 then return end
    if spell:Cast(eHealer.key) then
        return
    end
end)

wildChargeFriendly:Callback("healer",function(spell)
    if not eHealer then return end
    if not Alive(eHealer.key) or not IsEnemy(eHealer.key) then return end
    if GetDebuffRemaining(113942 ,eHealer.key) > 87 then return end --warlock gate
    if SpellCd(5211) > gcd() then return end --mightybash
    if dr(eHealer.key, 5211) < 1 then return end --mightybash
    if dr(eHealer.key, 33786) < 1 then return end --cyclone
    if bcc(eHealer.key) and not DebuffFrom(eHealer.key,okayHit) then return end
    if spell:Cast(eHealer.key) then
        return
    end
end)

cyclone:Callback("healer",function(spell)
    if TrueHealthP("target") > 60 then return end
    if not HasDebuff(1079, "target") then return end --rip
    if not HasDebuff(155722, "target") then return end --rake
    if HasBuff(102543, "player") then return end --incarn
    if Used("player", 33786, 5) then return end --cyclone
    if not eHealer then return end
    if not Alive(eHealer.key) or not IsEnemy(eHealer.key) then return end
    if dr(eHealer.key, 33786) < 1 then return end --cyclone
    if bcc(eHealer.key) and not DebuffFrom(eHealer.key,okayHit) then return end
    if Moving("player") then return end
    if spell:Cast(eHealer.key) then
        Alert(spell.id, "HEALER", GetDropdownValues())
        return
    end
end)

cyclone:Callback("AOE", function(spell)
    if Used("player", 33786, 5) then return end --cyclone
    ObjectsLoop(enemies, function(enemy, guid)
        if dr(enemy.key, 33786) < 1 then return false end --cyclone
        if not IsPlayer(enemy.key) then return false end 
        if bcc(enemy.key) and not DebuffFrom(enemy.key,okayHit) then return false end
        if Moving("player") then return end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "AOE", GetDropdownValues())
            return true
        end
    end)
end)

typhoon:Callback("heals", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if HasBuff(e.groundingTotemBuff.id, "player") then return false end
        if not IsPlayer(enemy.key) then return false end
        if not IsCastingT(enemy.key, interruptListHealer) then return false end
        if not CanInterruptCast(enemy.key) then return false end
        if not interruptAt(enemy.key, 40) then return false end
        if HitboxDistance(enemy.key, "player") > 20 then return false end
        if spell:Cast() then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

typhoon:Callback("healsChan", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsChannelingT(enemy.key, chanListHeals) then return false end
        if not CanInterruptChannel(enemy.key) then return false end
        if HitboxDistance(enemy.key, "player") > 20 then return false end
        if not interruptAt(enemy.key,25) then return false end
        if spell:Cast() then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

typhoon:Callback(function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if HasBuff(e.groundingTotemBuff.id, "player") then return false end
        if not IsPlayer(enemy.key) then return false end
        if not IsCastingT(enemy.key, interruptList) then return false end
        if not CanInterruptCast(enemy.key) then return false end
        if not interruptAt(enemy.key,40) then return false end
        if HitboxDistance(enemy.key, "player") > 20 then return false end
        if spell:Cast() then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

typhoon:Callback("chan",function(spell)
    if SpellCd(spell.id) > gcd() then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsChannelingT(enemy.key, chanlists) then return false end
        if not CanInterruptChannel(enemy.key) then return false end
        if HitboxDistance(enemy.key, "player") > 20 then return false end
        if not interruptAt(enemy.key, 25) then return false end
        if spell:Cast() then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)
-----------------------------------------------------------------------------
local function inCombat()
    if Mounted() then return end
    local target = "target"
    local player = "player"
    local healthStoneCount = GetItemCount(5512)
    local shiftHeldDown = IsShiftKeyDown()
    local randomHealthstone = math.random(35, 37)

    if not erButton.isEnabled then return end
    ------------ in CC stop --------------------
    if Disarm("player") then
        ----------------- healthstone -----------
        if healthStoneCount >= 1 and InPvp() and not pvpStoneUsed then
            if TrueHealthP(player) <= randomHealthstone and not defensiveBuffCheck(player) then
                pvpStoneUsed = true
                rmt("/use Healthstone")
            end
        elseif TrueHealthP(player) <= randomHealthstone and not defensiveBuffCheck(player) then
            rmt("/use Healthstone")
        end
        ----------------- defensives ------------
        

        ----------------- auto attack -----------
        if UnitExists("target") and HitboxDistance(target) < 6 and los("target") and IsEnemy("target") and Alive("target") then
            AttackUnit("target")
        end
        if HasDebuff(410126,"player") then return end --glare
        if HasDebuff(410201,"player") then return end --glare
        

        --------------- main rotation ----------
        
    end

    if Locked() then return end
    ----------------- healthstone -----------
    if healthStoneCount >= 1 and InPvp() and not pvpStoneUsed then
        if TrueHealthP(player) <= randomHealthstone and not defensiveBuffCheck(player) then
            pvpStoneUsed = true
            rmt("/use Healthstone")
        end
    elseif TrueHealthP(player) <= randomHealthstone and not defensiveBuffCheck(player) then
        rmt("/use Healthstone")
    end
    ----------------- defensives ------------
    mangle()
    frenziedRegeneration()
    survivalInstincts()
    barkskin()
    renewal()
    regrowth()
    regrowth("AOE")
    dash()
    stampedingRoar()
    wildChargeFriendly()
    ursolsVortex()
    rootRemove()
    backToCatForm()
    defensiveBear()

    if HasBuff(5487, "player") then return end

    ----------------- auto attack -----------
    if UnitExists("target") and HitboxDistance(target) < 6 and los("target") and IsEnemy("target") and Alive("target") then
        AttackUnit("target")
    end
    if HasDebuff(410126,"player") then return end --glare
    if HasDebuff(410201,"player") then return end --glare

    mightyBash("healer")
    wildChargeFriendly("healer")
    cyclone("healer")
    --cyclone("AOE")

    ----------------- stomp sect ------------
    runTotemStomp()
    runStomp()
    --------------- main rotation ----------
    typhoon()
    typhoon("chan")
    typhoon("heals")
    typhoon("healsChan")
    skullBash()
    skullBash("chan")
    skullBash("heals")
    skullBash("healsChan")

    ferociousBite("proc")
    incarnation()
    tigerFury()
    feralFrenzy()
    adaptiveSwarm()
    TrinketsRacials()
    rip()
    rip("aoe")
    maim()
    maim("aoe")
    rip("MINIONS")
    ferociousBite()
    rake()
    rake("aoe")
    rake("stun")
    rake("stunAoe")
    --if not HasBuff(145152,"player") then --bloodtalons
    --    brutalSlash("bloodtalons")
    --    moonfire("bloodtalons")
    --    shred("bloodtalons")
    --end
    entanglingRoots()
    brutalSlash()
    moonfire()
    moonfire("aoe")
    shred()
    markOfTheWild()
end
---------- start double melee check ----------
local function outCombat()
    if not erButton.isEnabled then return end
    ------------ in CC stop --------------------
    if Locked() then return end
    if Mounted() then return end
    GrabHealthstone(1,3)
    markOfTheWild()
    backToCatForm()
    prowl()
    ------------ out combat logic --------------
    wildChargeFriendly()
    if HitboxDistance("target", "player") > 6 then return end
    incarnation()
    tigerFury("engage")
    rake()
    feralFrenzy()
end
Elite.inCombat = inCombat
Elite.outCombat = outCombat