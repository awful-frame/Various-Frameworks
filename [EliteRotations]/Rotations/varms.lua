local Elite = _G.Elite
local Draw = Tinkr.Util.Draw:New()
local e = Elite.CallbackManager.spellbook
local OM = Elite.ObjectManager
local enemies = OM:GetEnemies()
local friends = OM:GetFriends()
local tyrants = OM:GetTyrants()
local totems = OM:GetTotems()
local ftotems = OM:GetFTotems()
local EventManager = _G.Elite.EventManager
Elite:SetUtilitiesEnvironment()
if Spec("player") ~= 71 then return end

----------------------------- gui -----------------------------
local Builder = Tinkr.Util.GUIBuilder:New {
    config = "varmsConfig"
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
                    label = "Display if you're in PvE vs PvP mode",
                    default = "yes",
                },

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
                    key = "autoDBTS",
                    label = "Auto Die by the Sword",
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
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "autoDisarm",
                    label = "Auto Disarm",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoIntervene",
                    label = "Auto Intervene",
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
                    default = "yes",
                }
            }
        }
    }
}

local general4 = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "autoSmash",
                    label = "Auto use Colossus Smash/Warbreaker",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoBladestorm",
                    label = "Auto use Bladestorm",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "autoRoar",
                    label = "Auto use Thunderous Roar",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoAvatar",
                    label = "Auto use Avatar",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "autoShockwave",
                    label = "Auto use Shockwave",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoStormBolt",
                    label = "Auto use Storm Bolt",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "slowPriority",
                    label = "Ensure Permanent Slow",
                    default = "yes"
                },
                Builder:Checkbox {
                    key = "autoFear",
                    label = "Auto use fear on healer",
                    default = "yes",
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
                    key = 'dbtsSlider',
                    label = "Die by the Sword (Health %)",
                    description = "Default is: 40%",
                    min = 15,
                    max = 100,
                    step = 1,
                    default = 40,
                    percent = false
                },
                Builder:Slider {
                    key = 'biSlider',
                    label = "Bitter Immunity (Health %)",
                    description = "Default is: 30%",
                    min = 15,
                    max = 100,
                    step = 1,
                    default = 30,
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
                    description = "Default is: 60%",
                    min = 15,
                    max = 100,
                    step = 1,
                    default = 60,
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
        { name = "burstBind",       default = "SHIFT-ALT-0" },
        { name = "sbeHealer",       default = "SHIFT-ALT-1" },

        { name = "sbTarget",        default = "SHIFT-ALT-2" },
        { name = "swTarget",        default = "SHIFT-ALT-3" },

        { name = "hlTarget",        default = "SHIFT-ALT-4" },
        { name = "hleHealer",       default = "SHIFT-ALT-5" },

        { name = "hlfHealer",       default = "SHIFT-ALT-6" },
        { name = "chargeeHealer",   default = "SHIFT-ALT-7" },

        { name = "interveneHealer", default = "SHIFT-ALT-8" },
        { name = "interveneLowest", default = "SHIFT-ALT-9" },

        { name = "disarmFocus",     default = "SHIFT-ALT-0" },
        { name = "fearFocus",       default = "SHIFT-1" }
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
    C_Timer.After(1, PeriodicKeybindUpdate) -- Check every 1 second
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
                    size = 12
                }
            }
        }, Builder:Rows {
        Builder:Columns {
            Builder:EditBox {
                key = "burstBind",
                label = "Keybind to hold down and pop all CDs",
                default = "SHIFT-ALT-0"
            }, Builder:EditBox {
            key = "sbeHealer",
            label = "Storm Bolt enemy healer",
            default = "SHIFT-ALT-1"
        }
        }
    }, Builder:Rows {
        Builder:Columns {
            Builder:EditBox {
                key = "sbTarget",
                label = "Storm bolt target",
                default = "SHIFT-ALT-2"
            }, Builder:EditBox {
            key = "sweHealer",
            label = "Shockwave enemy healer",
            default = "SHIFT-ALT-3"
        }
        }
    }, Builder:Rows {
        Builder:Columns {
            Builder:EditBox {
                key = "swTarget",
                label = "Shockwave target",
                default = "SHIFT-ALT-4"
            }, Builder:EditBox {
            key = "hleHealer",
            label = "Heroic leap to enemy healer",
            default = "SHIFT-ALT-5"
        }
        }
    }, Builder:Rows {
        Builder:Columns {
            Builder:EditBox {
                key = "hlfHealer",
                label = "Heroic leap to friendly healer",
                default = "SHIFT-ALT-6"
            }, Builder:EditBox {
            key = "chargeeHealer",
            label = "Charge to enemy healer",
            default = "SHIFT-ALT-7"
        }
        }
    }, Builder:Rows {
        Builder:Columns {
            Builder:EditBox {
                key = "interveneHealer",
                label = "Intervene enemy healer",
                default = "SHIFT-ALT-8"
            }, Builder:EditBox {
            key = "interveneLowest",
            label = "Intervene lowest team member",
            default = "SHIFT-ALT-9"
        }
        }
    }, Builder:Rows {
        Builder:Columns {
            Builder:EditBox {
                key = "disarmFocus",
                label = "Disarm focus target",
                default = "SHIFT-ALT-0"
            }
        },
        Builder:Columns {
            Builder:EditBox {
                key = "fearFocus",
                label = "Fear focus target",
                default = "SHIFT-1"
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
            title = "Offensive",
            content = {
                general4
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
            title = "Arms General",
            icon = 132355,
            content = {
                TabGroup
            }
        },
        Builder:TreeBranch {
            title = "Arms Info",
            icon = 132223,
            content = {
                TypographyTabGroup
            }
        }
    }
}

local Window = Builder:Window {
    key = "vexArms",
    title = "|cff51322DVex Arms Warrior",
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
local MyCommands = Tinkr.Util.Commands:New("er")
MyCommands:Register("config", function()
    ResetGUIState() -- Call this before opening the GUI
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
        button:SetNormalTexture("Interface\\Icons\\ability_warrior_savageblow")
        button.text:SetText("Enabled")
    else
        button:SetNormalTexture("Interface\\Icons\\ability_meleedamage")
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

        -- Offensive Settings
        autoStormBolt = "yes",
        autoShockwave = "yes",
        autoBladestorm = "yes",
        autoAvatar = "yes",
        autoRoar = "yes",
        autoSmash = "yes",
        slowPriority = "yes",
        autoFear = "yes",

        -- Defensive Settings
        autoDBTS = "yes",
        autoBI = "yes",
        autoRC = "yes",
        autoStance = "yes",
        autoDisarm = "yes",
        autoIntervene = "yes",

        -- Drawing Settings
        enableMeleeDraw = "yes",
        enableESP = "yes",
        fearDraw = "yes",

        -- Dropdown for alert X and Y position
        alertXPosition = "option_e", -- Default to -100
        alertYPosition = "option_j", -- Default to 400

        -- Dropdown for static alert X and Y position
        alertXPositionStatic = "option_g", -- Default to 100
        alertYPositionStatic = "option_j", -- Default to 400

        -- Sliders for defensive health percentages
        dbtsSlider = 40, -- Default is 40% for Die by the Sword
        biSlider = 30,   -- Default is 30% for Bitter Immunity
        rcSlider = 25,   -- Default is 25% for Rallying Cry
        dSlider = 60,    -- Default is 60% for Defensive Stance swap

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
Alert(12294, "Alerts are online!", GetDropdownValues())
------------------------------ set tick rate -----------------------------
_G.TickRate = 0.01
------------------------------------------------------------start drawings
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
        if facing ~= nil and UnitExists("target") and UnitCanAttack("player", "target") and Alive("target") then
            if x and y and z then
                if InMelee("target") and IsFacing("target") then
                    draw:SetColor(0, 255, 0)
                else
                    draw:SetColor(255, 0, 0)
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
                draw:SetColor(178, 102, 255)
                draw:Circle(x1, y1, z1, 8)
            end
        end
    end
end)
Draw:Enable()
-------------------------- lists start --------------------------------------
Elite:Populate({
    skullsplitter = NewSpell(260643, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false }),
    hamstring = NewSpell(1715,
        { damage = "physical", targeted = true, ignoreMoving = true, cc = "snare", ignoreFacing = false }),
    rend = NewSpell(772,
        { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false, facesmooth = true }),
    mortalWounds = NewSpell(115804, { damage = "physical", targeted = true }),
    sweepingStrikes = NewSpell(260708,
        { beneficial = true, ignoreMoving = true, ignoreFacing = false, damage = "physical" }),
    avatar = NewSpell(107574,
        { beneficial = true, damage = "physical", ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    warbreaker = NewSpell(262161, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = true }),
    colossusSmash = NewSpell(167105, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false }),
    colossusSmashDebuff = NewSpell(208086, { damage = "physical", targeted = true }),
    mortalStrike = NewSpell(12294,
        { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false, facesmooth = true }),
    suddenDeathBuff = NewSpell(52437, { beneficial = true }),
    overpower = NewSpell(7384, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false }),
    thunderClap = NewSpell(6343,
        { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = true, ignoreDisarmed = true }),
    charge = NewSpell(100,
        { beneficial = true, ignoreGCD = true, targeted = true, damage = "physical", ignoreFacing = false, ignoreMoving = true, facehack = true }),
    stormBolt = NewSpell(107570,
        { damage = "physical", targeted = true, ignoreMoving = true, cc = "stun", facesmooth = true, ignoreDisarmed = true }),
    shockwave = NewSpell(46968,
        { damage = "physical", targeted = true, ignoreMoving = true, cc = "stun", facesmooth = true, ignoreDisarmed = true }),
    spearOfBastion = NewSpell(376079, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false }),
    thunderousRoar = NewSpell(384318, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = true }),
    sharpenBlade = NewSpell(198817, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    intimidatingShout = NewSpell(5246,
        { damage = "physical", targeted = true, ignoreMoving = true, cc = "fear", ignoreFacing = true }),
    defensiveStance = NewSpell(386208, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    battleStance = NewSpell(386164, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    rallyingCry = NewSpell(97462, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreDisarmed = true }),
    impendingVictory = NewSpell(202168,
        { beneficial = true, damage = "physical", ignoreMoving = true, facesmooth = true }),
    bladestorm = NewSpell(227847, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = true }),
    bladestormColossus = NewSpell(227847,
        { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = true, castById = true }),
    intervene = NewSpell(3411, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    spellReflect = NewSpell(23920,
        { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true, ignoreDisarmed = true }),
    dieByTheSword = NewSpell(118038, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    bitterImmunity = NewSpell(383762, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    pummel = NewSpell(6552,
        { damage = "physical", targeted = true, ignoreMoving = true, facesmooth = true, ignoreGCD = true, ignoreDisarmed = true }),
    disarm = NewSpell(236077, { damage = "physical", targeted = true, ignoreMoving = true, facesmooth = true }),
    heroicThrow = NewSpell(57755,
        { damage = "physical", targeted = true, ignoreMoving = true, minRange = 8, ignoreFacing = false }),
    heroicLeap = NewSpell(6544, { beneficial = true, targeted = false, ignoreMoving = true, ignoreFacing = true }),
    bloodAndThunder = NewSpell(384277, { beneficial = true }),
    battleShout = NewSpell(6673, { beneficial = true, ignoreMoving = true, damage = "physical", ignoreDisarmed = true }),
    berserkerRage = NewSpell(18499, { beneficial = true, ignoreMoving = true, ignoreFacing = true, ignoreGCD = true }),
    piercingHowl = NewSpell(12323,
        { damage = "physical", targeted = true, ignoreMoving = true, cc = "snare", ignoreFacing = true, ignoreDisarmed = true }),
    shatteringThrow = NewSpell(64382,
        { beneficial = true, targeted = true, ignoreMoving = true, ignoreFacing = false, facend = true }),
    wreckingThrow = NewSpell(384110, { damage = "physical", targeted = true, ignoreMoving = true }),
    ignorePain = NewSpell(190456, { beneficial = true, ignoreFacing = true, ignoreGCD = true }),
    martialProwess = NewSpell(316440, { beneficial = true }),
    colossalMight = NewSpell(440989, { beneficial = true }),
    warBanner = NewSpell(236320, { beneficial = true, ignoreMoving = true, ignoreFacing = true, targeted = false }),
    taunt = NewSpell(355, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = true }),
    slam = NewSpell(1464, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false }),
    duel = NewSpell(236273, { damage = "physical", targeted = true, ignoreMoving = true }),
    execute = NewSpell(163201, { damage = "physical", targeted = true, ignoreMoving = true, facesmooth = true }),
    cleave = NewSpell(845, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false }),
    demolish = NewSpell(436358, { damage = "physical", targeted = true, ignoreMoving = true, ignoreFacing = false }),
    -- debuffs and talents
    rendDebuff = NewSpell(388539, { beneficial = false }),
    executionersPrecision = NewSpell(386634, { beneficial = true }),
    executionersPrecisionDebuff = NewSpell(386633, { targeted = true }),
    massacre = NewSpell(281001, { beneficial = true }),
    deepWounds = NewSpell(262115, { targeted = true }),
    -- Racials
    berserking = NewSpell(33697, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    bloodFury = NewSpell(20572, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    bloodFury2 = NewSpell(33702, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    bloodFury3 = NewSpell(20572, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    fireBlood = NewSpell(265221, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
    escapeArtist = NewSpell(20589, { beneficial = true, ignoreMoving = true, ignoreFacing = true }),
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


function RandomKickGenarator()
    local chance = Random(0.001, 1.001, 1)
    if chance <= 0.25 then
        return Random(25, 35, 1)
    else
        return Random(65, 85, 1)
    end
end

function CountPhysicalDmgDealers()
    local count = 0
    ObjectsLoop(enemies, function(enemy)
        if not IsPlayer(enemy.key) then return false end
        if not Alive(enemy.key) then
            return false
        end
        if IsMelee(enemy.key)
        then
            count = count + 1
        end
        return false
    end)
    return count
end
------------------------------------ variables ------------------------------------
local randomKick = RandomKickGenarator() + Buffer()
local randomKickChannel = Random(25, 35, 2) + Buffer()
local pvpStoneUsed = false

------------------------------------ lists ----------------------------------------
local totem1 = {
    [61245] = true,  -- capacitorTotem
    [53006] = true,  -- spiritLinkTotem
    [60561] = true,  -- earthgrab totem
    [179867] = true, -- staticFieldTotem
    [59764] = true   -- healingTideTotem
}

local totem2 = {
    [105451] = true, -- counterstrikeTotem
    [5913] = true,   -- tremorTotem
    [5925] = true,   -- groundingTotem
    [105427] = true, -- skyfuryTotem
    [53006] = true,  -- spiritLinkTotem
}


local pvpStomps = {
    [179193] = true, -- observer
    [107100] = true, -- observer2
    [101398] = true, -- psyfiend
    [119052] = true  -- warBanner
}
local externalDefensiveBuff = {
    184364, -- enragedRegen
    370960, -- emeraldCommune
    199452, -- ultimateSacrifice
    116849, -- lifeCocoon
    363534, -- rewind
    47788   -- guardianSpirit
}
local externalDefensiveBuffIV = {
    199452, -- ultimateSacrifice
    116849, -- lifeCocoon
    47788   -- guardianSpirit
}
local reflectListCCDR = {
    [33786] = 0.5,  -- cyclone
    [118] = 0.5,    -- polymorph
    [28271] = 0.5,  -- polymorphTurtle
    [28272] = 0.5,  -- polymorphPig
    [61025] = 0.5,  -- polymorphSnake
    [61305] = 0.5,  -- polymorphBlackCat
    [61780] = 0.5,  -- polymorphTurkey
    [61721] = 0.5,  -- polymorphRabbit
    [126819] = 0.5, -- polymorphPorcupine
    [161353] = 0.5, -- polymorphPolarBearCub
    [161354] = 0.5, -- polymorphMonkey
    [161355] = 0.5, -- polymorphPenguin
    [161372] = 0.5, -- polymorphPeacock
    [277787] = 0.5, -- polymorphBabyDirehorn
    [277792] = 0.5, -- polymorphBumblebee
    [321395] = 0.5, -- polymorphMawrat
    [391622] = 0.5, -- polymorphDuck
    [51514] = 0.5,  -- hex
    [196942] = 0.5, -- hexVoodooTotem
    [210873] = 0.5, -- hexRaptor
    [211004] = 0.5, -- hexSpider
    [211010] = 0.5, -- hexSnake
    [211015] = 0.5, -- hexCockroach
    [269352] = 0.5, -- hexSkeletalHatchling
    [309328] = 0.5, -- hexLivingHoney
    [277778] = 0.5, -- hexZandalariTendonripper
    [277784] = 0.5, -- hexWickerMongrel
    [20066] = 0.5,  -- repentance
    [360806] = 0.5  -- sleepWalk
}
local reflectListCC = {
    [33786] = true,  -- cyclone
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
    [20066] = true,  -- repentance
    [360806] = true  -- sleepWalk
}
local reflectListDMG = {
    [686] = true,    -- shadow bolt
    [48181] = true,  -- haunt
    [431044] = true, -- frostfire bolt
    [407466] = true, -- mindSpikeInsanity
    [375901] = true, -- mindGames
    [116858] = true, -- chaosBolt
    [51505] = true,  -- lava burst
    [203286] = true, -- greaterPyro
    [199786] = true, -- glacialSpike
    [6353] = true,   -- soulFire
    [365350] = true, -- arcaneSurge
    [30451] = true,  -- arcaneBlast
    [274283] = true, -- fullMoon
    [274282] = true, -- halfMoon
    [396286] = true, -- upheavel
    [390612] = true, -- frost bomb
    [342938] = true, -- unstableAffliction
    [316099] = true  -- unstableAfflictionNoTalent
}
interruptListHealer = {
    [8936] = true,   -- regrowth
    [2061] = true,   -- flashHeal
    [8004] = true,   -- healingSurge
    [77472] = true,  -- healingWave
    [82326] = true,  -- holyLight
    [19750] = true,  -- flashOfLight
    [200652] = true, -- tyrsDeliverance
    [64843] = true,  -- divineHymn
    [367226] = true, -- spiritbloom
    [355936] = true, -- dreamBreath
    [1064] = true,   -- chainHeal
    [421453] = true, -- ultimatePenitence
    [431443] = true  -- chrono flame
}

chanlists = {
    [205021] = true, -- rayOfFrost
    [117952] = true, -- crackling jade lightning
    [263165] = true, -- voidTorrent
    [417537] = true, -- oblivion
    [391401] = true, -- mindflayinsanity
    [382411] = true, -- eternitySurge
    [357208] = true, -- fireBreath
    [234153] = true, -- drain life
    [356995] = true, -- disintegrate
    [382440] = true, -- shifting powers
    [605] = true     -- mindControl
}

chanListHeals = {
    [115175] = true, -- soothingMist
    [186723] = true, -- penance
    [47540] = true,  -- penance 2
    [400169] = true, -- penance 3
    [47758] = true,  -- penance 4
    [382614] = true, -- dream breath
    [382731] = true, -- spirit bloom
    [377509] = true  -- dream projection
}
ccInterruptList = {
    [410126] = true, -- searingGlare
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
    [269352] = true, -- hexSkeletalHatchlingha
    [309328] = true, -- hexLivingHoney
    [277778] = true, -- hexZandalariTendonripper
    [277784] = true, -- hexWickerMongre
    [20066] = true,  -- repentance
    [113724] = true, -- ringOfFrost
    [33786] = true,  -- cyclone
    [605] = true,    -- mindControl
    [198898] = true, -- songOfChiji
    [5782] = true,   -- fear
    [2637] = true,   -- hibernate
    [710] = true,    -- banish
    [360806] = true, -- sleepWalk
    [30283] = true,  -- shadowFury
}

slowingDebuffs = {
    6343,   -- Thunder Clap                        (warrior, protection)
    435203, -- Thunder Clap                        (warrior, protection)
    45524,  -- Chains of Ice
    198793, -- Vengeful Retreat
    58180,  -- Infected Wounds
    5116,   -- Concussive Shot
    187698, -- Tar Trap
    116,    -- Frostbolt
    120,    -- Cone of Cold
    116095, -- Disable
    183218, -- Hand of Hindrance
    15407,  -- Mind Flay
    3408,   -- Crippling Poison
    26679,  -- Deadly Throw
    196840, -- Frost Shock
    334275, -- Curse of Exhaustion
    12323,  -- Piercing Howl
}

healerDispels = {
    115450, -- detox
    4987,   -- cleanse
    77130,  -- purifySpirit
    88423,  -- naturesCure
    360823, -- naturalize
    527,    -- purify

}

dmgInterruptList = {
    [51505] = true,  -- lava burst
    [48181] = true,  -- haunt
    [431044] = true, -- frostfire bolt
    [120644] = true, -- halo
    [686] = true,    -- shadow bolt
    [34914] = true,  -- vamp touch
    [404977] = true, -- timeSkip
    [377509] = true, -- dreamProjection
    [407466] = true, -- mindSpikeInsanity
    [395160] = true, -- eruption
    [375901] = true, -- mindGames
    [323764] = true, -- convoke
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
    [6353] = true,   -- soulFire
    [199786] = true, -- glacialSpike
    [342938] = true, -- unstableAffliction
    [316099] = true, -- unstableAfflictionNoTalent
    [265187] = true, -- summonTyrant
    [365350] = true, -- arcaneSurge
    [202347] = true, -- stellarFlare
    [378464] = true, -- nullifyingShroud
    [274283] = true, -- fullMoon
    [274282] = true, -- halfMoon
    [200652] = true, -- tyrsDeliverance
    [30146] = true,  -- summonfelguard
    [390612] = true, -- frostBomb
    [104316] = true, -- callDreadStalkers
    [133] = true,    -- fireBall
    [116] = true,    -- frostBolt
    [395152] = true, -- ebonMight
    [396286] = true, -- upheavel
    [324536] = true, -- maleficRapture
    [30451] = true   -- arcaneBlast
}

optimalInterruptList = {
    [51505] = true,  -- lava burst
    [48181] = true,  -- haunt
    [431044] = true, -- frostfire bolt
    [199786] = true, -- glacialSpike
    [342938] = true, -- unstableAffliction
    [116858] = true, -- chaosBolt
    [316099] = true, -- unstableAfflictionNoTalent
    [265187] = true, -- summonTyrant
    [365350] = true, -- arcaneSurge
    [390612] = true, -- frostBomb
    [30146] = true,  -- summonfelguard
    [105174] = true, -- handOfGuldan
    [30451] = true,  -- arcaneBlast
    [116] = true,    -- frostBolt
    [133] = true,    -- fireBall
    [391109] = true, -- darkAscension
    [228260] = true, -- voidEruption
    [33786] = true,  -- cyclone
    [410126] = true, -- searingGlare
}

healerInterruptList = {
    [410126] = true, -- searingGlare
    [8936] = true,   -- regrowth
    [2061] = true,   -- flashHeal
    [8004] = true,   -- healingSurge
    [77472] = true,  -- healingWave
    [82326] = true,  -- holyLight
    [19750] = true,  -- flashOfLight
    [200652] = true, -- tyrsDeliverance
    [64843] = true,  -- divineHymn
    [367226] = true, -- spiritbloom
    [355936] = true, -- dreamBreath
    [1064] = true,   -- chainHeal
    [421453] = true, -- ultimatePenitence
    [431443] = true, -- chrono flame
    [33786] = true,  -- cyclone
    [20066] = true,  -- repentance
    [360806] = true, -- sleepWalk
    [605] = true     -- mindControl

}

hybridHealingInterruptList = {
    [8936] = true,   -- regrowth
    [2061] = true,   -- flashHeal
    [8004] = true,   -- healingSurge
    [19750] = true,  -- flashOfLight
    [367226] = true, -- spiritbloom
    [355936] = true, -- dreamBreath
    [421453] = true, -- ultimatePenitence
    [431443] = true, -- chrono flame
}
interruptList = {
    [51505] = true,  -- lava burst
    [48181] = true,  -- haunt
    [431044] = true, -- frostfire bolt
    [120644] = true, -- halo
    [686] = true,    -- shadow bolt
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
    [324536] = true  -- maleficRapture
}
specialInterrupt = {
    [113656] = true, -- fistOfFury
    [257044] = true, -- rapidFire
    [203155] = true  -- sniperShot
}
berserkerRageList = {
    5782,   -- fear
    5484,   -- howlofTerror
    6358,   -- Seduction
    360806, -- sleepWalk
    8122,   -- psychicScream
    136184, -- psychicScream
    316593, -- intimidatingShout
    5246,   -- intimidatingShout2
    20066,  -- repentance
    1776,   -- gouge
    207685, -- sigilOfMisery
    115078, -- paralysis
    118699, -- Fear
    130616, -- Fear (Horrify)

}
shatterList = {
    45438, -- iceBlock
    642,   -- divineShield
    378441 -- time stop
}
wreckList = {
    116849, -- lifeCocoon
    17,     -- pws
    108416, -- dark pact
    198111, -- temporalShield
    11426,  -- iceBarrier
    235450, -- prismaticBarrier
    235313, -- blazingBarrier
    382290  -- tempestBarrier
}
okayHit = {
    8122,   -- psychic scream
    207167, -- blinding sleet
    5246,   -- intimidatingShout1
    316593, -- intimidatingShout2
    316595  -- intimidatingShout3
}
bladestormList = { 227847, 446035 }

local bannerDebuffs = {
    24394, -- intim
    64044, -- psychicHorror
    31661, -- dragonsBreath
}
------------------------ functions start ------------------------------------
function BrsrkRageCheck(unit)
    unit = unit or "player"
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
    local random_offset = Random(-2, 2, 99)

    -- Apply the offset to the input number
    local randomized_number = num + random_offset

    -- Ensure the number doesn't go below 1
    if randomized_number < 1 then
        return 1
    end

    return randomized_number
end

Elite.StompTotems(function(totem, totemId)
    if totem1[totemId] and CanCast(e.overpower.id) and HitboxDistance(totem, "player") <= 6 then
        FaceSmooth(totem, e.overpower.id, "Stomping - " .. Name(totem), GetDropdownValues())
        return
    end
    if totem2[totemId] and CanCast(e.heroicThrow.id) and HitboxDistance(totem, "player") <= 30 and HitboxDistance(totem, "player") > 8 then
        FaceSmooth(totem, e.heroicThrow.id, "Stomping - " .. Name(totem), GetDropdownValues())
        return
    end
    if totem2[totemId] and CanCast(e.mortalStrike.id) and HitboxDistance(totem, "player") <= 6 then
        FaceSmooth(totem, e.mortalStrike.id, "Stomping - " .. Name(totem), GetDropdownValues())
        return
    end
end, 0.5)
--- stomp PvP Objects from the pvpobjects list
--- these object IDs include 179193, 101398, 119052
Elite.Stomp(function(pobject, stompItemID)
    if pvpStomps[stompItemID] and CanCast(e.overpower.id) and HitboxDistance(pobject, "player") <= SpellRange(e.overpower.id) then
        FaceSmooth(pobject, e.overpower.id, "Stomping - " .. Name(pobject), GetDropdownValues())
        return
    end
    if pvpStomps[stompItemID] and CanCast(e.heroicThrow.id) and HitboxDistance(pobject, "player") <= 30 and HitboxDistance(pobject, "player") > 8 then
        FaceSmooth(pobject, e.heroicThrow.id, "Stomping - " .. Name(pobject), GetDropdownValues())
        return
    end
    if pvpStomps[stompItemID] and CanCast(e.mortalStrike.id) and HitboxDistance(pobject, "player") <= 6 then
        FaceSmooth(pobject, e.mortalStrike.id, "Stomping - " .. Name(pobject), GetDropdownValues())
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
    if not Used(e.avatar.id, 3) or not Used(e.bladestorm.id, 3) then return end
    if CanCast(e.berserking.id) then Cast(e.berserking.id, "player") end
    if CanCast(e.bloodFury.id) then Cast(e.bloodFury.id, "player") end
    if CanCast(e.bloodFury2.id) then Cast(e.bloodFury2.id, "player") end
    if CanCast(e.bloodFury3.id) then Cast(e.bloodFury3.id, "player") end
    if CanCast(e.fireBlood.id) then Cast(e.fireBlood.id, "player") end
    UseEquippedItemByID(218713) -- conq s1
    UseEquippedItemByID(218421) -- honor s1
end

------------------Callbacks-----------------------------------------

pummel:Callback("optimalInterrupt", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if CastTarget(enemy, "player")
            and IsCastingT(enemy.key, ccInterruptList)
            and BuffFrom("player", bladestormList) then
            return false
        end
        if not IsPlayer(enemy.key) then return false end
        if not IsHealer(enemy.key) then
            if not IsCastingT(enemy.key, optimalInterruptList) then return false end
        end
        if IsHealer(enemy.key) then
            if not IsCastingT(enemy.key, healerInterruptList) then return false end
        end
        if not CanInterruptCast(enemy.key) then return false end
        if not interruptAt(enemy.key, randomKick) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)


pummel:Callback("pummelHybridHeals", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if IsHealer(enemy.key) then return false end
        if not IsHealer(enemy.key) then
            if TrueHealthP(enemy.key) >= 45 then
                if not IsCastingT(enemy.key, hybridHealingInterruptList) then return false end
            end
        end

        if not CanInterruptCast(enemy.key) then return false end
        if not interruptAt(enemy.key, randomKick) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

pummel:Callback("interruptWhenPressured", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    if not lowest then return end
    if TrueHealthP(lowest.key) >= 70 then return end
    if fHealer and not cc(fHealer.key) then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not CanInterruptCast(enemy.key) then return false end
        if not IsCastingT(enemy.key, interruptList) then return false end
        if not interruptAt(enemy.key, randomKick) then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

pummel:Callback("interruptCC", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    if not fHealer then return end
    if BuffFrom("player", bladestormList) then return end
    local interrupted = false
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not CanInterruptCast(enemy.key) then return false end
        if IsCastingT(enemy.key, ccInterruptList) and CastTarget(enemy.key, fHealer.key) then
            if spell:Cast(enemy.key) then
                Alert(spell.id, "Interrupting CC on Healer", GetDropdownValues())
                interrupted = true
                return true
            end
        end
        return false
    end)
    if interrupted then
        return
    end
    if not (cc(fHealer.key) or UsedT(fHealer.key, healerDispels, 7)) then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if CastTarget(enemy.key, "player")
            and IsCastingT(enemy.key, ccInterruptList)
            and BuffFrom("player", bladestormList) then
            return false
        end
        if not IsCastingT(enemy.key, ccInterruptList) then return false end
        if not IsPlayer(enemy.key) then return false end
        if not CanInterruptCast(enemy.key) then return false end
        if not interruptAt(enemy.key, randomKick) then
            return false
        end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)


pummel:Callback("chan", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsChannelingT(enemy.key, chanlists) then return false end
        if not CanInterruptChannel(enemy.key) then return false end
        if not interruptAt(enemy.key, randomKickChannel) then
            return false
        end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)


pummel:Callback("healsChan", function(spell)
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsChannelingT(enemy.key, chanListHeals) then return false end
        if not CanInterruptChannel(enemy.key) then return false end
        if not interruptAt(enemy.key, randomKickChannel) then
            return false
        end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return true
        end
    end)
end)

spellReflect:Callback("CC", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    local shouldReflect = false
    if BuffFrom("player", bladestormList) then return false end
    ObjectsLoop(enemies, function(enemy, guid)
        if not CastTarget(enemy.key, "player") then return false end
        if not IsCastingT(enemy.key, reflectListCC) then return false end
        if IsTarget(enemy.key) then
            if Used(e.pummel.id, 1) then return false end
            if Used(e.shockwave.id, 1) then return false end
            if Used(e.stormBolt.id, 1) then return false end
            if CanInterruptCast(enemy.key) and SpellCd(e.pummel.id) == 0 and HitboxDistance(enemy.key) <= 8 and not Used(e.pummel.id, 0.5) then
                shouldReflect = false
                return true
            end
            if StunDr(enemy.key) > 0.5 and HitboxDistance(enemy.key) <= 8 and
                (SpellCd(e.shockwave.id) < gcd() or SpellCd(e.stormBolt.id) < gcd()) then
                shouldReflect = false
                return true
            end
        end
        if CastRemains(enemy.key) <= (Buffer() * 6) then
            shouldReflect = true
            return true
        end
    end)
    if shouldReflect and spell:Cast() then
        Alert(spell.id, "Reflecting", GetDropdownValues())
        return true
    end
end)

spellReflect:Callback("DMG", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    if TrueHealthP("player") > 70 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not CastTarget(enemy.key, "player") then return false end
        if not IsCastingT(enemy.key, reflectListDMG) then return false end
        if CanInterruptCast(enemy.key) and SpellCd(e.pummel.id) == 0 and HitboxDistance(enemy.key) <= 8 then return false end
        if CastRemains(enemy) <= (Buffer() * 6) then
            if spell:Cast() then
                Alert(spell.id, "Reflecting", GetDropdownValues())
                return true
            end
        end
    end)
end)

spellReflect:Callback("lowHp", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    if TrueHealthP("player") > 35 then return end
    if spell:Cast() then
        Alert(spell.id, "Reflecting", GetDropdownValues())
        return
    end
end)
impendingVictory:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if TrueHealthP("player") > 60 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if defensiveBuffCheck("player") and TrueHealthP("player") > 40 then return end
    if defensiveBuffCheckIV("player") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Maintain Target", GetDropdownValues())
        return
    end
end)
battleShout:Callback("maintain", function(spell)
    if Prep() then return end
    if HasBuff(spell.id, "player") then return end
    if not Alive("player") then return end
    if spell:Cast() then
        Alert(spell.id, "Maintain Shout", GetDropdownValues())
        return
    end
end)
battleShout:Callback("maintainPvpArea", function(spell)
    if not Prep() then return end
    if HasBuff(spell.id, "player") then return end
    if not Alive("player") then return end
    DelayedCast(spell.id, 3, 5)
end)
battleShout:Callback("maintainCombat", function(spell)
    if HasBuff(spell.id, "player") then return end
    if not Alive("player") then return end
    if UnitExists("target") and Health("target") < 30 then return end
    if spell:Cast("player") then
        Alert(spell.id, "Maintain Shout", GetDropdownValues())
        return
    end
end)
rend:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Rage() < 20 then return end
    if HasTalent(6343) then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if GetDebuffRemaining(e.rendDebuff.id, "target") > 4 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Maintain Target", GetDropdownValues())
        return
    end
end)

mortalStrike:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Rage() < 30 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        -- Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)

overpower:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        --  Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)

avatar:Callback(function(spell)
    if Builder:GetConfig("autoAvatar") ~= "yes" then return end
    if Rage() < 30 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if InPvp() and not IsPlayer("target") then return end
    if HasBuff(e.avatar.id, "player") then return end
    if HitboxDistance("target") > 8 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end)
warbreaker:Callback(function(spell)
    if Builder:GetConfig("autoSmash") ~= "yes" then return end
    if not HasTalent(262161) then return end
    if InPvp() and not IsPlayer("target") then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if SpellCd(e.warbreaker.id) > gcd() then return end
    if SpellCd(e.mortalStrike.id) > 2 then return end
    if HitboxDistance("target") > 8 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
colossusSmash:Callback(function(spell)
    if Builder:GetConfig("autoSmash") ~= "yes" then return end
    if HasTalent(262161) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if SpellCd(e.colossusSmash.id) > gcd() then return end
    if SpellCd(e.mortalStrike.id) > 2 then return end
    if HitboxDistance("target") > 8 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
sharpenBlade:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if TrueHealthP("target") > 70 then return end
    if SpellCd(e.mortalStrike.id) > gcd() then return end
    if HitboxDistance("target") > 10 then return end
    if Used(spell.id, 1) then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast() then
        -- Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)

thunderousRoar:Callback(function(spell)
    if Builder:GetConfig("autoRoar") ~= "yes" then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if InPvp() and not IsPlayer("target") then return end
    if HitboxDistance("target") > 8 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end)
bladestorm:Callback(function(spell)
    if Builder:GetConfig("autoBladestorm") ~= "yes" then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if SpellCd(spell.id) > gcd() then return end
    if HitboxDistance("target") > 8 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if Used(e.spellReflect.id, 0.5) then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end)
bladestorm:Callback("avatarFading", function(spell)
    if Builder:GetConfig("autoBladestorm") ~= "yes" then return end
    if HasTalent(e.demolish.id) then return end
    if Prep() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if SpellCd(e.warbreaker.id) <= gcd() and SpellCd(e.colossusSmash.id) <= gcd() then return end
    if HitboxDistance("target") > 8 then return end
    if not HasBuff(e.avatar.id, "player") then return end
    if GetBuffRemaining(e.avatar.id, "player") > 5.5 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end)
bladestormColossus:Callback(function(spell)
    if Builder:GetConfig("autoBladestorm") ~= "yes" then return end
    if not HasTalent(e.demolish.id) then return end
    if Prep() then return end
    if SpellCd(e.warbreaker.id) <= gcd() and SpellCd(e.colossusSmash.id) <= gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if HitboxDistance("target") > 8 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        if HasTalent(e.demolish.id) then
            CastSpellByID(227847)
        end
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end)
bladestormColossus:Callback("avatarFading", function(spell)
    if Builder:GetConfig("autoBladestorm") ~= "yes" then return end
    if not HasTalent(e.demolish.id) then return end
    if Prep() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if SpellCd(e.warbreaker.id) <= gcd() and SpellCd(e.colossusSmash.id) <= gcd() then return end
    if HitboxDistance("target") > 8 then return end
    if not HasBuff(e.avatar.id, "player") then return end
    if GetBuffRemaining(e.avatar.id, "player") > 5.5 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end)
execute:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if SpellCd(spell.id) > gcd() then return end
    if Health("target") > 20 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then return end
end)
execute:Callback("suddenDeath", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if SpellCd(spell.id) > gcd() then return end
    if not HasBuff(e.suddenDeathBuff.id, "player") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then return end
end)
execute:Callback("massacre", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if SpellCd(spell.id) > gcd() then return end
    if not HasTalent(206315) then return end
    if Health("target") > 35 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then return end
end)
hamstring:Callback("slowPriority", function(spell)
    if Builder:GetConfig("slowPriority") ~= "yes" then return end
    if Used(spell.id, 2) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if IsMelee("target") and not DistanceMoved("target", 3) then return end
    if cc("target") then return false end
    if DebuffFrom("target", slowingDebuffs) then return end
    if HasDebuff(1715, "target") and GetDebuffRemaining(1715, "target") > 4 then return end
    if HasBuff(1022, "target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if not IsPlayer("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
hamstring:Callback(function(spell)
    if Builder:GetConfig("slowPriority") ~= "no" then return end
    if Used(spell.id, 2) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if cc("target") then return false end
    if DebuffFrom("target", slowingDebuffs) then return end
    if HasDebuff(1715, "target") and GetDebuffRemaining(1715, "target") > 4 then return end
    if not DistanceMoved("target", 4) then return end
    if HasBuff(1022, "target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if not IsPlayer("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)

hamstring:Callback("casterLow", function(spell)
    if Used(spell.id, 1) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if IsMelee("target") then return end
    if Spec("target") == 102 then return end
    if HasDebuff(e.piercingHowl.id, "target") then return end
    if HasDebuff(1715, "target") then return end
    if HasBuff(1022, "target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if not IsPlayer("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
hamstring:Callback("balanceDruid", function(spell)
    if Used(spell.id, 1) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if Spec("target") ~= 102 then return end
    if HasDebuff(e.piercingHowl.id, "target") then return end
    if HasDebuff(1715, "target") then return end
    if HasBuff(1022, "target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if not IsPlayer("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
hamstring:Callback("melee", function(spell)
    if Used(spell.id, 1) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then
        return
    end
    if not IsMelee("target") then return end
    if HasDebuff(e.piercingHowl.id, "target") then return end
    if HasDebuff(1715, "target") then return end
    if HasBuff(1022, "target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if not IsPlayer("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
piercingHowl:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") or IsPlayer("target") then return end
    if HasTalent(5630) then
        if Distance("target") > 18 then return end
    else
        if Distance("target") > 12 then return end
    end
    if Used(e.charge.id, 2) then return end
    if Distance("target") < 8 then return end
    if GetDebuffRemaining(e.piercingHowl.id, "target") > 1 or GetDebuffRemaining(e.hamstring.id, "target") > 1 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if onlyMeleeToggle then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)

escapeArtist:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if TrueHealthP("target") > 90 then return end
    if RootedRemains("player") < 2 then return end
    DelayedCast(spell.id, 0.6, 0.8, "player")
end)

dieByTheSword:Callback(function(spell)
    if Prep() then return end
    if Builder:GetConfig("autoDBTS") == "no" then return end
    local dbts = rslider(Builder:GetConfig("dbtsSlider", 60))
    if TrueHealthP("player") > dbts then return end
    if spell:Cast() then
        Alert(spell.id, "Defensive: Die by the Sword! - LOW HP", GetDropdownValues())
    end
end)

bitterImmunity:Callback(function(spell)
    if Builder:GetConfig("autoBI") == "no" then return end
    if not HasTalent(383762) then return end
    if defensiveBuffCheck("player") then return end
    local bi = rslider(Builder:GetConfig("biSlider", 50))
    if TrueHealthP("player") > bi then return end
    if spell:Cast() then
        Alert(spell.id, "Defensive: Bitter Immunity! - LOW HP", GetDropdownValues())
    end
end)

rallyingCry:Callback("lowest", function(spell)
    if Prep() then return end
    if Builder:GetConfig("autoRC") ~= "yes" then return end
    if defensiveBuffCheck("player") then return end
    local rc = rslider(Builder:GetConfig("rcSlider", 60))
    if not lowest then return end
    if not Alive(lowest.key) then return end
    if TrueHealthP(lowest.key) > rc then return end
    if Distance(lowest.key, "player") > 40 then return end
    if spell:Cast() then
        Alert(spell.id, "Defensive: Rallying Cry! - LOW ", GetDropdownValues())
        return
    end
end)
rallyingCry:Callback(function(spell)
    if Prep() then return end
    if Builder:GetConfig("autoRC") ~= "yes" then return end
    if defensiveBuffCheck("player") then return end
    local rc = rslider(Builder:GetConfig("rcSlider", 60))
    if not Alive("player") then return end
    if TrueHealthP("player") > rc then return end
    if spell:Cast() then
        Alert(spell.id, "Defensive: Rallying Cry! - LOW ", GetDropdownValues())
        return
    end
end)

defensiveStance:Callback(function(spell)
    if Builder:GetConfig("autoStance") ~= "yes" then return end
    if not Alive("player") then return end
    if HasBuff(e.defensiveStance.id, "player") then return end
    if TrueHealthP("player") > rslider(Builder:GetConfig("dSlider", 60)) then return end
    if spell:Cast() then
        Alert(spell.id, "Swapped to Defensive Stance!", GetDropdownValues())
    end
end)

defensiveStance:Callback("outCombat", function(spell)
    if Builder:GetConfig("autoStance") ~= "yes" then return end
    if not Alive("player") then return end
    if HasBuff(e.defensiveStance.id, "player") then return end
    if spell:Cast() then
        Alert(spell.id, "Swapped to Defensive Stance!", GetDropdownValues())
    end
end)

battleStance:Callback(function(spell)
    if Builder:GetConfig("autoStance") ~= "yes" then return end
    if not Alive("player") then return end
    if HasBuff(e.battleStance.id, "player") then return end
    if TrueHealthP("player") <= rslider(Builder:GetConfig("dSlider", 60)) then return end
    if spell:Cast() then
        Alert(spell.id, "Swapped to Battle Stance!", GetDropdownValues())
    end
end)

thunderClap:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not HasTalent(772) then return end
    if Rage() < 20 then return end
    if HasTalent(203201) then
        if HitboxDistance("target") > 12 then return end
    else
        if HitboxDistance("target") > 8 then return end
    end
    if GetDebuffRemaining(e.rendDebuff.id, "target") > 4 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Clappin' some cheeks", GetDropdownValues())
        return
    end
end)

thunderClap:Callback("spendRage", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not HasTalent(772) then return end
    if Rage() < 60 then return end
    if HasTalent(203201) then
        if HitboxDistance("target") > 12 then return end
    else
        if HitboxDistance("target") > 8 then return end
    end
    if spell:Cast("target") then
        Alert(spell.id, "Clappin' some cheeks", GetDropdownValues())
        return
    end
end)

taunt:Callback(function(spell)
    if SpellCd(e.spellReflect.id) <= gcd() then return end
    if SpellCd(spell.id) > gcd() then return end
    for _, enemy in pairs(enemies) do
        if IsPlayer(enemy) and CastTarget(enemy, "player") and IsCastingT(enemy, reflectListCC) and CheckDR("player", CastInfo(enemy.key), reflectListCCDR) and CastRemains(enemy) <= (Buffer() * 2) then
            for _, enemy2 in pairs(enemies) do
                if not IsPlayer(enemy2) and Alive(enemy2) then
                    if spell:Cast(enemy2.key) then
                        Alert(spell.id, "Taunting pet to break", GetDropdownValues())
                    end
                end
            end
        end
    end
end)


warBanner:Callback(function(spell)
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) ~= 0 then return end
    if not fHealer then return end
    if DebuffFromR(fHealer.key, bannerDebuffs) > 3 then return end
    if DebuffFromR(fHealer.key, bannerDebuffs) == 0 then return end
    if Distance(fHealer.key) > 30 then return end
    if spell:Cast() then
        return
    end
end)





berserkerRage:Callback(function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    if BrsrkRageCheck() < 2 then return end
    DelayedCast(spell.id, 0.6, 0.8)
end)

berserkerRage:Callback("fHealer", function(spell)
    if not HasTalent(384100) then return end
    if SpellCd(spell.id) ~= 0 then return end
    if fHealer and fHealer.key then
        if BrsrkRageCheck(fHealer.key) < 2 then return end
        if HasTalent(5630) then
            if Distance(fHealer.key, "player") > 20 then return end
        else
            if Distance(fHealer.key, "player") > 12 then return end
        end
        if spell:Cast() then
            Alert(spell.id, "Removing cc on " .. Name(fHealer.key), GetDropdownValues())
            return
        end
    end
end)

shatteringThrow:Callback(function(spell)
    if not HasTalent(64382) then return end
    if Moving() then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsEnemy(enemy.key) then return false end
        if not BuffFrom(enemy.key, shatterList) then return false end
        if Distance(enemy.key) > 30 then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Shattering defensive on " .. Name(enemy.key), GetDropdownValues())
            return true
        end
    end)
end)
wreckingThrow:Callback(function(spell)
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not IsEnemy("target") then return end
    if not BuffFrom("target", wreckList) then return end
    if spell:Cast("target") then
        return
    end
end)


ignorePain:Callback(function(spell)
    if not HasTalent(190456) then return end
    if (Rage() > 80 and TrueHealthP("player") <= 90) or TrueHealthP("player") < 50 then
        if spell:Cast() then
            Alert(spell.id, "Absorbing Damage", GetDropdownValues())
            return
        end
    end
end)


demolish:Callback(function(spell)
    if Builder:GetConfig("autoDemolish") ~= "yes" then return end
    if not HasTalent(spell.id) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if not HasBuff(e.colossalMight.id, "player") then return end
    if GetBuffCount(e.colossalMight.id, "player") < 10 then return end
    if HasBuff(e.bladestorm.id, "player") or HasBuff(e.sweepingStrikes.id, "player") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
charge:Callback("chargeeHealerbind", function(spell)
    if SpellCd(spell.id) ~= 0 then return end
    if not eHealer then return end
    if spell:Cast(eHealer.key) then
        return
    end
end)
demolish:Callback("demolishKeybind", function(spell)
    if not HasTalent(spell.id) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if HasBuff(e.bladestorm.id, "player") or HasBuff(e.sweepingStrikes.id, "player") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
slam:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        --   Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
heroicThrow:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if HitboxDistance("target") < 9 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        --   Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end)
intimidatingShout:Callback("arena", function(spell)
    if SpellCd(spell.id) > gcd() then return end
    if Used(e.stormBolt.id, 1.5) then return end
    if Used(e.shockwave.id, 1.5) then return end
    if not InArena() then return end
    if not eHealer then return end
    if IsTarget(eHealer.key) then return end
    if cc(eHealer.key) then return end
    if dr(eHealer.key, spell.id) >= 1 then
        if spell:Cast(eHealer.key) then
            Alert(spell.id, "Fearing enemy healer", GetDropdownValues())
            return
        end
    end
end)
intimidatingShout:Callback("bg", function(spell)
    if SpellCd(spell.id) > gcd() then return end
    if Used(e.stormBolt.id, 1.5) then return end
    if Used(e.shockwave.id, 1.5) then return end
    if not InBg() then return end
    if IsHealer("target") then return end
    for _, enemy in pairs(enemies) do
        if IsPlayer(enemy.key) and IsHealer(enemy.key) and not cc(enemy.key) and not IsTarget(enemy.key) then
            if dr(enemy.key, spell.id) >= 1 then
                if spell:Cast(enemy.key) then
                    Alert(spell.id, "Fearing enemy healer", GetDropdownValues())
                    return
                end
            end
        end
    end
end)
intimidatingShout:Callback("bgHealerAttackers", function(spell)
    if SpellCd(spell.id) > gcd() then return end
    if Used(e.stormBolt.id, 1.5) then return end
    if Used(e.shockwave.id, 1.5) then return end
    if not InBg() then return end
    if TrueHealthP("player") > 35 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsHealer(enemy.key) then return false end
        if cc(enemy.key) then return false end
        if Distance(enemy.key, "player") > 8 then return false end
        if dr(enemy.key, spell.id) < 1 then return false end
        local melee, caster, total, cooldowns = Attackers(enemy.key)
        if cooldowns >= 2 then return false end
        if total >= 3 then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Fearing " .. Name(enemy.key))
            return true
        end
    end)
end)

intimidatingShout:Callback("focus", function(spell)
    if not UnitExists("focus") then return end
    if not IsEnemy("focus") then return end
    if not Alive("focus") then return end
    if cc("focus") then return end
    if spell:Cast("focus") then
        Alert(spell.id, "Fearing focus", GetDropdownValues())
        return
    end
end)

heroicLeap:Callback("hleHealer", function(spell)
    if not eHealer then return end
    if eHealer.bcc and eHealer.bccRemains > 1 then return end
    if spell:Cast(eHealer.key) then
        return
    end
end)
heroicLeap:Callback("hlTarget", function(spell)
    if not fHealer then return end
    if spell:Cast("target") then return end
end)
heroicLeap:Callback("hlfHealer", function(spell)
    if not fHealer then return end
    if spell:Cast(fHealer.key) then
        return
    end
end)
stormBolt:Callback("sbeHealer", function(spell)
    if not eHealer then return end
    if cc(eHealer.key) then return end
    if StunDr(eHealer.key) >= 0.5 then
        if spell:Cast(eHealer.key) then
            return
        end
    end
end)
stormBolt:Callback("sbTarget", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if cc("target") then return end
    if StunDr("target") >= 0.5 then
        if spell:Cast("target") then
            return
        end
    end
end)

shockwave:Callback("swTarget", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if cc("target") then return end
    if StunDr("target") >= 0.5 then
        if spell:Cast("target") then
            return
        end
    end
end)
stormBolt:Callback("freedom", function(spell)
    if not IsPlayer("target") then return end
    if Builder:GetConfig("autoStormBolt") ~= "yes" then return end
    if HasBuff(377362, "target") then return end
    if cc("target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not SlowImmune("target") then return end
    if StunDr("target") ~= 1 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Stun on " .. Name("target"), GetDropdownValues())
        return
    end
end)
stormBolt:Callback("cast", function(spell)
    if not IsPlayer("target") then return end
    if Builder:GetConfig("autoStormBolt") ~= "yes" then return end
    if cc("target") then return end
    if HasBuff(377362, "target") then return end
    if Used(e.pummel.id, 0.3) then return end
    if CanInterruptCast("target") and
        SpellCd(e.pummel.id) == 0 and
        HitboxDistance("target") <= 8 then
        return
    end
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not IsCastingT("target", interruptList) then return end
    if StunDr("target") < 0.5 then return end
    if StunDrr("target") < 16 and StunDrr("target") ~= 0 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Stun on " .. Name("target"), GetDropdownValues())
        return
    end
end)
stormBolt:Callback("castCloneInterrupt", function(spell)
    if Builder:GetConfig("autoStormBolt") ~= "yes" then return end
    if SpellCd(spell.id) ~= 0 then return end
    if not InPvp() then return end
    ObjectsLoop(enemies, function(enemy)
        if Distance(enemy.key, "player") < 6 then return false end
        if not IsPlayer(enemy.key) then return false end
        if StunDrr(enemy.key) > 16 then return false end
        if HasBuff(377362, enemy.key) then return end
        if IsCastingT(enemy.key, { 33786 }) then
            if spell:Cast(enemy.key) then
                Alert(spell.id, "Stun on " .. Name(enemy.key), GetDropdownValues())
                return true
            end
        end
        return false
    end)
end)

stormBolt:Callback("healer", function(spell)
    if Builder:GetConfig("autoStormBolt") ~= "yes" then return end
    if cc("target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if TrueHealthP("target") > 60 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if not IsHealer(enemy.key) then return false end
        if HasBuff(377362, enemy.key) then return end
        if StunDr(enemy.key) ~= 1 then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Stun on " .. Name(enemy), GetDropdownValues())
            return
        end
    end)
end)

stormBolt:Callback("desperate", function(spell)
    if Builder:GetConfig("autoStormBolt") ~= "yes" then return end
    if cc("target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if lowest and TrueHealthP(lowest.key) < 40 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy.key) then return false end
        if IsHealer(enemy.key) then return false end
        if HasBuff(377362, enemy.key) then return end
        if StunDr(enemy.key) ~= 1 then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Stun on " .. Name(enemy), GetDropdownValues())
            return
        end
    end)
end)

stormBolt:Callback("targetLow", function(spell)
    if not IsPlayer("target") then return false end
    if Builder:GetConfig("autoStormBolt") ~= "yes" then return end
    if cc("target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if HasBuff(377362, "target") then return end
    if Used(e.pummel.id, 2) then return end
    if cc("target") then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if TrueHealthP("target") > 40 then return end
    if StunDr("target") ~= 1 then return false end
    if spell:Cast("target") then
        Alert(spell.id, "Stun on " .. Name("target"), GetDropdownValues())
        return
    end
end)

shockwave:Callback("cast", function(spell)
    if Builder:GetConfig("autoShockwave") ~= "yes" then return end
    if cc("target") then return end
    if not IsPlayer("target") then return end
    if Used(e.pummel.id, 0.3) then return end
    if HasBuff(377362, "target") then return end
    if CanInterruptCast("target") and
        SpellCd(e.pummel.id) == 0 and
        HitboxDistance("target") <= 8 then
        return false
    end
    if HitboxDistance("target") > 8 then return end
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not IsCastingT("target", interruptList) then return end
    if StunDr("target") < 0.5 then return end
    if StunDrr("target") < 16 and StunDrr("target") ~= 0 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Stun on " .. Name("target"), GetDropdownValues())
        return
    end
end)

shockwave:Callback("desperate", function(spell)
    if Builder:GetConfig("autoShockwave") ~= "yes" then return end
    if not IsPlayer("target") then return end
    if cc("target") then return end
    if HasBuff(377362, "target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if HitboxDistance("target") > 8 then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if lowest and TrueHealthP(lowest.key) < 40 then return end
    if IsHealer("target") then return end
    if StunDr("target") ~= 1 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Stun on " .. Name("target"), GetDropdownValues())
        return
    end
end)

shockwave:Callback("targetLow", function(spell)
    if Builder:GetConfig("autoShockwave") ~= "yes" then return end
    if not IsPlayer("target") then return end
    if HasBuff(377362, "target") then return end
    if cc("target") then return end
    if Used(e.pummel.id, 2) then return end
    if HitboxDistance("target") > 8 then return end
    if SpellCd(spell.id) > gcd() then return end
    if cc("target") then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if TrueHealthP("target") > 40 then return end
    if StunDr("target") ~= 1 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Stun on " .. Name("target"), GetDropdownValues())
        return
    end
end)
disarm:Callback("bursting", function(spell)
    if Builder:GetConfig("autoDisarm") ~= "yes" then return end
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) > gcd() then return end
    if TrueHealthP("player") > 70 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy) then return false end
        if not IsMelee(enemy) and Spec(enemy.key) ~= 254 then
            return false
        end
        if IsClass(enemy, 11) then return false end
        if IsClass(enemy, 10) then return false end
        if not enemy.bursting then return false end
        if BuffFrom(enemy.key, bladestormList) then return false end
        if cc(enemy.key) then return false end
        if enemy.disarmed then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Disarming burst", GetDropdownValues())
            return
        end
    end)
end)

disarm:Callback("low", function(spell)
    if Builder:GetConfig("autoDisarm") ~= "yes" then return end
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) > gcd() then return end
    if TrueHealthP("player") > 30 then return end
    ObjectsLoop(enemies, function(enemy, guid)
        if not IsPlayer(enemy) then return false end
        if not IsMelee(enemy) and Spec(enemy.key) ~= 254 then
            return false
        end
        if IsClass(enemy, 11) then return false end
        if IsClass(enemy, 10) then return false end
        if BuffFrom(enemy.key, bladestormList) then return false end
        if cc(enemy.key) then return false end
        if enemy.disarmed then return false end
        if spell:Cast(enemy.key) then
            Alert(spell.id, "Disarming low", GetDropdownValues())
            return
        end
    end)
end)

disarm:Callback("focus", function(spell)
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) > gcd() then return end
    if not UnitExists("focus") then return end
    if not IsPlayer("focus") then return end
    if not IsMelee("focus") and Spec("focus") ~= 254 then return end
    if BuffFrom("focus", bladestormList) then return end
    if cc("focus") then return end
    if spell:Cast("focus") then
        Alert(spell.id, "Disarming focus", GetDropdownValues())
        return
    end
end)

intervene:Callback("lowHpFriend", function(spell)
    if Builder:GetConfig("autoIntervene") ~= "yes" then return end
    if not HasTalent(spell.id) then return end
    local physicalDmgDealers = CountPhysicalDmgDealers()
    if physicalDmgDealers == 0 then return end
    if SpellCd(spell.id) > gcd() then return end
    if not InPvp() then return end
    if not lowest then return end
    if Distance(lowest.key, "player") > 20 then return end
    if TrueHealthP(lowest.key) >= 65 or Health("player") < 50 then return end
    ObjectsLoop(enemies, function(enemy)
        if not TargetingAB(enemy.key, lowest.key) then return false end
        if not IsMelee(enemy.key) and not IsHunter(enemy.key) then return false end
        if spell:Cast(lowest.key) then
            Alert(spell.id, "Saving friend", GetDropdownValues())
            return true
        end
    end)
end)

intervene:Callback("mobility", function(spell)
    if Builder:GetConfig("autoIntervene") ~= "yes" then return end
    if Used(e.charge.id, 1.5) then return end
    if Used(e.heroicLeap.id, 1.5) then return end
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) > gcd() then return end
    if not InPvp() then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Distance("target", "player") > 10 then return end
    local physicalDmgDealers = CountPhysicalDmgDealers()
    if physicalDmgDealers > 0 then
        if not lowest or TrueHealthP(lowest.key) <= 80 then
            return
        end
    end
    local bestFriend = nil
    local shortestDistance = math.huge
    local maxInterveneRange = 25

    ObjectsLoop(friends, function(friend)
        if not NotPlayer(friend.key) then return false end
        if not Alive(friend.key) then return false end
        if Distance(friend.key, "player") > maxInterveneRange then return false end

        local friendToTargetDistance = Distance(friend.key, "target")
        if not friendToTargetDistance then return false end

        local playerToTargetDistance = Distance("player", "target")
        if not playerToTargetDistance then return false end

        if friendToTargetDistance < playerToTargetDistance then
            if friendToTargetDistance < shortestDistance then
                bestFriend = friend
                shortestDistance = friendToTargetDistance
            end
        end
        return false
    end)
    if bestFriend then
        if spell:Cast(bestFriend.key) then
            Alert(spell.id, "Intervening to " .. Name(bestFriend.key) .. " for mobility", GetDropdownValues())
            return true
        end
    end
end)

intervene:Callback("healer", function(spell)
    if Builder:GetConfig("autoIntervene") ~= "yes" then return end
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) > gcd() then return end
    if not InPvp() then return end
    if not fHealer then return end
    if not IsPlayer(fHealer.key) then return end
    if not Alive(fHealer.key) then return end
    if Distance(fHealer.key, "player") > 25 then return end
    if not IsHealer(fHealer.key) then return end
    if not cc(fHealer.key) then return end
    if spell:Cast(fHealer.key) then
        return
    end
end)
intervene:Callback("lowest", function(spell)
    if not HasTalent(spell.id) then return end
    if SpellCd(spell.id) > gcd() then return end
    if not InPvp() then return end
    if not lowest then return end
    if not Alive(lowest.key) then return end
    if Distance(lowest.key, "player") > 25 then return end
    if not cc(lowest.key) then return end
    if spell:Cast(lowest.key) then
        return
    end
end)


sweepingStrikes:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Used(e.bladestorm.id, 5) then return end
    if SpellCd(e.bladestorm.id) < gcd() then return end
    if HitboxDistance("target") > 8 then return end
    if AreaEnemies("player", 8) < 2 then return end
    if AreaBcc("player", 8) > 0 then return end
    if spell:Cast() then
        return
    end
end)
skullsplitter:Callback(function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not HasTalent(spell.id) then return end
    if not HasDebuff(e.deepWounds.id, "target") then return end
    if not HasDebuff(e.rendDebuff.id, "target") then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if spell:Cast("target") then
        return
    end
end)
--------------------------------- leveling build ----------------------------
thunderClap:Callback("pve", function(spell)
    if not HasTalent(772) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Health("target") <= 30 then return end
    local enemyCount = 0
    if HasTalent(203201) then
        if HitboxDistance("target") > 12 then return end
        enemyCount = AreaEnemies("player", 12)
        if enemyCount <= 2 then return end
    else
        if HitboxDistance("target") > 8 then return end
        enemyCount = AreaEnemies("player", 8)
        if enemyCount <= 2 then return end
    end
    if rendDotCountPve() >= enemyCount then return end
    if spell:Cast() then
        Alert(spell.id, "Clappin' some cheeks", GetDropdownValues())
    end
end, true)

rend:Callback("maintainPve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if HasTalent(6343) then
        if HasTalent(203201) then
            if AreaEnemies("player", 12) > 1 then return end
        else
            if AreaEnemies("player", 8) > 1 then return end
        end
    end
    if GetDebuffRemaining(e.rendDebuff.id, "target") > 5 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Maintain Target", GetDropdownValues())
        return
    end
end, true)

avatar:Callback("pve", function(spell)
    if not HasTalent(spell.id) then return end
    if Builder:GetConfig("autoAvatar") ~= "yes" then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if (UnitClassification("target") ~= "worldboss" and UnitClassification("target") ~= "rareelite" and UnitClassification("target") ~= "elite" and UnitClassification("target") ~= "rare") and Health("player") > 30 and AreaEnemies("player", 10) < 2 then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end, true)

thunderousRoar:Callback("pve", function(spell)
    if Builder:GetConfig("autoRoar") ~= "yes" then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if (UnitClassification("target") ~= "worldboss" and UnitClassification("target") ~= "rareelite" and UnitClassification("target") ~= "elite" and UnitClassification("target") ~= "rare") and Health("player") > 30 and AreaEnemies("player", 12) < 2 then return end
    if HitboxDistance("target") > 8 then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end, true)

bladestorm:Callback("pve", function(spell)
    if Builder:GetConfig("autoBladestorm") ~= "yes" then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if (UnitClassification("target") ~= "worldboss" and UnitClassification("target") ~= "rareelite" and UnitClassification("target") ~= "elite" and UnitClassification("target") ~= "rare") and Health("player") > 30 and AreaEnemies("player", 8) < 3 then return end
    if HasBuff(e.sweepingStrikes.id, "player") then return end
    if HitboxDistance("target") > 8 then return end
    if spell:Cast("target") then
        Alert(spell.id, "DMG", GetDropdownValues())
        return
    end
end, true)

warbreaker:Callback("pve", function(spell)
    if Builder:GetConfig("autoSmash") ~= "yes" then return end
    if not HasTalent(262161) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if HitboxDistance("target") > 10 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

colossusSmash:Callback("pve", function(spell)
    if Builder:GetConfig("autoSmash") ~= "yes" then return end
    if HasTalent(262161) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

sweepingStrikes:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if HasBuff(e.bladestorm.id, "player") then return end
    if (SpellCd(e.bladestorm.id) < Buffer() + gcd()) and AreaEnemies("player", 8) > 2 then return end
    if HitboxDistance("target") > 8 then return end
    if AreaEnemies("player", 8) < 2 then return end
    if spell:Cast() then
        Alert(spell.id, "Cleaving!", GetDropdownValues())
        return
    end
end, true)

cleave:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if AreaEnemies("player", 8) < 2 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Cleaving!", GetDropdownValues())
        return
    end
end, true)

cleave:Callback("collateralDamagePve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if not HasBuff(334783, "player") then return end
    if AreaEnemies("player", 8) < 2 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Cleaving!", GetDropdownValues())
        return
    end
end, true)

mortalStrike:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

execute:Callback("suddenDeathPve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if not HasBuff(e.suddenDeathBuff.id, "player") then return end
    if spell:Cast("target") then
        return
    end
end, true)
execute:Callback("massacrePve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if Health("target") > 35 and HasTalent(281001) then return end
    if spell:Cast("target") then
        return
    end
end, true)
execute:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if SpellCd(spell.id) > gcd() then return end
    if Health("target") > 20 then return end
    if spell:Cast("target") then
        return
    end
end, true)

mortalStrike:Callback("lowPve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Health("target") > 30 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

overpower:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

overpower:Callback("2stacksPve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Charges(spell.id) < 2 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

slam:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if AreaEnemies("player", 8) > 1 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

mortalStrike:Callback("2stackPve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if GetBuffCount(e.overpower.id, "player") < 2 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Martial Prowess", GetDropdownValues())
        return
    end
end, true)

mortalStrike:Callback("rageDumpPve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if Rage() < 60 then return end
    if AreaEnemies("player", 8) > 2 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

impendingVictory:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if TrueHealthP("player") > 60 then return end
    if bcc("target") and not DebuffFrom("target", okayHit) then return end
    if defensiveBuffCheck("player") and TrueHealthP("player") > 40 then return end
    if defensiveBuffCheckIV("player") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Maintain Target", GetDropdownValues())
        return
    end
end, true)

shockwave:Callback("pve", function(spell)
    if Builder:GetConfig("autoShockwave") ~= "yes" then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if HitboxDistance("target") > 10 then return end
    if AreaEnemies("target", 5) < 1 then return end
    if TrueHealthP("player") > 80 then return end
    if cc("target") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Maintain Target", GetDropdownValues())
        return
    end
end, true)

demolish:Callback("pve", function(spell)
    if Builder:GetConfig("autoDemolish") ~= "yes" then return end
    if not HasTalent(spell.id) then return end
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if (UnitClassification("target") == "normal" or UnitClassification("target") == "trivial" or UnitClassification("target") == "minus") and Health("target") < 35 then return end
    if HasBuff(e.bladestorm.id, "player") or HasBuff(e.sweepingStrikes.id, "player") then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

pummel:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if CastingPercent("target") >= randomKick and CastingPercent("target") <= 94 and CanInterruptCast("target") then
        if spell:Cast("target") then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return
        end
    end
    if ChannelingPercent("target") >= randomKickChannel and CanInterruptChannel("target") then
        if spell:Cast("target") then
            Alert(spell.id, "Interrupting", GetDropdownValues())
            return
        end
    end
end, true)

spellReflect:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if CastRemains("target") > 0 and CanInterruptCast("target") and SpellCd(e.pummel.id) < gcd() then return end
    if Used(e.pummel.id, 1) then return end
    if CastRemains("target") > 0 and CastRemains("target") <= (Buffer() * 2) then
        if spell:Cast() then
            Alert(spell.id, "Reflecting", GetDropdownValues())
            return
        end
    end
end, true)
heroicThrow:Callback("pve", function(spell)
    if not UnitExists("target") or not Alive("target") or not IsEnemy("target") then return end
    if HitboxDistance("target") < 9 then return end
    if spell:Cast("target") then
        Alert(spell.id, "Target", GetDropdownValues())
        return
    end
end, true)

battleStance:Callback("outCombatPve", function(spell)
    if Builder:GetConfig("autoStance") ~= "yes" then return end
    if not Alive("player") then return end
    if HasBuff(e.battleStance.id, "player") then return end
    if spell:Cast() then
        Alert(spell.id, "Swapped to Battle Stance!", GetDropdownValues())
    end
end, true)
-----------------------------------------------------------------------------
local function inCombat()
    local healthStoneCount = GetItemCount(5512)
    local demonHealthstoneCount = GetItemCount(224464)
    local shiftHeldDown = IsShiftKeyDown()
    local randomHealthstone = Random(35, 37, 3)
    randomKick = Random(60, 80, 88) + Buffer()
    randomKickChannel = Random(25, 35, 2) + Buffer()
    randomReflect = Random(1.01, 1.25, 101)

    if Builder:GetConfig("combatMode") == "yes" then
        if Builder:GetConfig("pveMode") == "no" then
            Alert(e.battleStance.id, "PvP Mode Active", GetDropdownValuesStatic())
        else
            Alert(e.defensiveStance.id, "PvE Mode Active", GetDropdownValuesStatic())
        end
    end
    if not erButton.isEnabled then return end
    if HasDebuff(410126, "player") or HasDebuff(410201, "player") then return end
    --------- keybinds ----------------------
    if IsComboPressed("burstBind") then
        sharpenBlade()
        bladestorm("avatarFading")
        bladestormColossus("avatarFading")
        mortalStrike("sharpenBlade")
        mortalStrike("noDebuff")
        --- warbreak + CDs
        thunderousRoar()
        avatar()
        warbreaker()
        colossusSmash()
        bladestorm()
        bladestormColossus()
    end
    if IsComboPressed("hleHealer") then heroicLeap("hleHealer") end
    if IsComboPressed("hlfHealer") then heroicLeap("hlfHealer") end
    if IsComboPressed("hlTarget") then heroicLeap("hlTarget") end
    if IsComboPressed("chargeeHealer") then charge("chargeeHealerBind") end
    if IsComboPressed("sbeHealer") then stormBolt("sbeHealer") end
    if IsComboPressed("sbTarget") then stormBolt("sbTarget") end
    if IsComboPressed("swTarget") then shockwave("swTarget") end
    if IsComboPressed("interveneHealer") then intervene("healer") end
    if IsComboPressed("interveneLowest") then intervene("lowest") end
    if IsComboPressed("fearFocus") then intimidatingShout("focus") end
    if IsComboPressed("disarmFocus") then disarm("focus") end


    if shiftHeldDown and Builder:GetConfig("leftShiftPause") == "yes" then return end
    ----------------- healthstone --------------
    if (healthStoneCount >= 1) and InPvp() and not pvpStoneUsed then
        if TrueHealthP("player") <= randomHealthstone and not defensiveBuffCheck("player") then
            pvpStoneUsed = true
            rmt("/use Healthstone")
        end
    elseif TrueHealthP("player") <= randomHealthstone and not defensiveBuffCheck("player") then
        if healthStoneCount >= 1 and not ItemOnCooldown(5512) then
            rmt("/use Healthstone")
        end
    end
    if TrueHealthP("player") <= randomHealthstone and not defensiveBuffCheck("player") then
        if demonHealthstoneCount >= 1 and not ItemOnCooldown(22464) then
            rmt("/use Demonic Healthstone")
        end
    end
    escapeArtist()
    berserkerRage("fHealer")
    berserkerRage()
    ----------------- defensives ------------
    defensiveStance()
    if Builder:GetConfig("pveMode") == "no" then
        impendingVictory()
    else
        impendingVictory("pve")
    end
    battleStance()
    bitterImmunity()
    rallyingCry("lowest")
    rallyingCry()
    intervene("lowHpFriend")
    intervene("mobility")
    dieByTheSword()
    ignorePain()
    taunt()
    warBanner()

    intimidatingShout("arena")
    intimidatingShout("bg")
    intimidatingShout("bgHealerAttackers")
    shatteringThrow()
    wreckingThrow()

    ----------------- auto attack -----------
    if UnitExists("target") and HitboxDistance("target") < 6 and los("target") and IsEnemy("target") and Alive("target") and not Immune("target", e.mortalStrike.id, false) then
        AttackUnit("target")
    end
    if Builder:GetConfig("pveMode") == "no" then
        ----------------- stomp sect ------------

        runTotemStomp()
        runStomp()

        ---------- trinkets and racials ---------
        TrinketsRacials()
        ------ interrupt and reflect------
        pummel("interruptCC")
        pummel("interruptWhenPressured")
        pummel("optimalInterrupt")
        pummel("pummelHybridHeals")
        pummel("chan")
        pummel("healsChan")
        charge("chargeCycloneCast")

        spellReflect("CC")
        spellReflect("DMG")
        spellReflect("low")
        ----- cc -----
        stormBolt("castCloneInterrupt")
        stormBolt("freedom")
        stormBolt("targetLow")
        shockwave("targetLow")
        shockwave("cast")
        stormBolt("healer")
        shockwave("desperate")
        stormBolt("cast")
        stormBolt("desperate")
        -- slows and disarm
        disarm("bursting")
        disarm("low")
        piercingHowl()
        hamstring("slowPriority")
        hamstring()
        --- shout
        battleShout("maintainCombat")
        if UnitExists("target") and HasBuff(1022, "target") then return end
        --- cds
        sharpenBlade()
        avatar()
        thunderousRoar()
        warbreaker()
        colossusSmash()
        --- rotation
        execute("suddenDeath")
        skullsplitter()
        rend()
        bladestorm()
        mortalStrike()
        execute("massacre")
        execute()
        thunderClap()
        overpower()
        slam()
        thunderClap("spendRage")
        hamstring("casterLow")
        hamstring("balanceDruid")
        hamstring("melee")
    else
        pummel("pve")
        spellReflect("pve")
        shockwave("pve")
        thunderClap("pve")
        rend("maintainPve")
        battleShout("maintainCombat")
        thunderousRoar("pve")
        avatar("pve")
        warbreaker("pve")
        colossusSmash("pve")
        mortalStrike("rageDumpPve")
        bladestorm("pve")
        bladestormColossus("pve")
        demolish("pve")
        cleave("collateralDamagePve")
        sweepingStrikes("pve")
        mortalStrike("lowPve")
        mortalStrike("2stackPve")
        execute("massacrePve")
        execute("pve")
        cleave("pve")
        overpower("2stacksPve")
        mortalStrike("pve")
        execute("suddenDeathPve")
        overpower("pve")
        heroicThrow("pve")
        slam("pve")
    end
end
---------- start double melee check ----------
local function outCombat()
    local shiftHeldDown = IsShiftKeyDown()
    randomKick = Random(60, 80, 88) + Buffer()
    randomKickChannel = Random(25, 35, 2) + Buffer()
    randomReflect = Random(1.01, 1.25, 101)
    if Builder:GetConfig("combatMode") == "yes" then
        if Builder:GetConfig("pveMode") == "no" then
            Alert(e.battleStance.id, "PvP Mode Active", GetDropdownValuesStatic())
        else
            Alert(e.defensiveStance.id, "PvE Mode Active", GetDropdownValuesStatic())
        end
    end

    if not erButton.isEnabled then return end
    --------- keybinds ----------------------
    ---if IsComboPressed("burstBind") then
    if not HasDebuff(410126, "player") and not HasDebuff(410201, "player") then
        avatar()
        thunderousRoar()
        bladestorm()
    end

    if IsComboPressed("hleHealer") then heroicLeap("hleHealer") end
    if IsComboPressed("hlfHealer") then heroicLeap("hlfHealer") end
    if IsComboPressed("hlTarget") then heroicLeap("hlTarget") end
    if IsComboPressed("chargeeHealer") then charge("chargeeHealerBind") end
    if shiftHeldDown and Builder:GetConfig("leftShiftPause") == "yes" then
        return
    end
    if shiftHeldDown and Builder:GetConfig("leftShiftPause") == "yes" then return end
    --- reset healthstone counter to only use once in pvp
    if Prep() or not InPvp() then
        pvpStoneUsed = false
    end
    ------------ out combat logic --------------
    if not Mounted() then
        if Builder:GetConfig("pveMode") == "no" then
            defensiveStance("outCombat")
        else
            battleStance("outCombatPve")
        end
        battleShout("maintain")
        battleShout("maintainPvpArea")
        if Builder:GetConfig("pveMode") == "no" then
            thunderClap()
            if not HasDebuff(410126, "player") and not HasDebuff(410201, "player") then
                rend("maintain")
            end
            battleShout("maintainCombat")
        else
            rend("maintainPve")
            overpower("2stacksPve")
            mortalStrike("pve")
            execute("suddenDeathPve")
            overpower("pve")
            heroicThrow("pve")
        end
        GrabHealthstone(1, 3)
    end
end


Elite.inCombat = inCombat
Elite.outCombat = outCombat