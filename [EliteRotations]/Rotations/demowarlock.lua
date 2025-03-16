local Tinkr = ...
local Elite = _G.Elite
local draw = Tinkr.Util.Draw:New() -- To use Tinkr Drawings
local e = Elite.CallbackManager.spellbook -- Elite Spellbook
local OM = Elite.ObjectManager -- Elite Object Manager
local enemies = OM:GetEnemies() -- for _, enemy in pairs(enemies) do Populate the unit lists (enemies)
local friends = OM:GetFriends() 
local tyrants = OM:GetTyrants() 
local fminions = OM:GetFMinions() 
local areaT = OM:GetAreaT()
local totems = OM:GetTotems() -- enemy
local ftotems = OM:GetFTotems() -- friendly
local portals = OM:GetPortal()
--local objects = OM:GetObject()
Elite:SetUtilitiesEnvironment() -- Set your script environment to run with Elite
_G.TickRate = 0.01 -- the rate at which your script is read in seconds. Default = 0.11

if Spec("player") ~= 266 then return end --demo warlock

------------------------------------ CONFIG ------------------------------------ 

local Builder = Tinkr.Util.GUIBuilder:New {
    config = "erTestConfig"
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
                -- Builder:Checkbox {
                --     key = "enabledrawings",
                --     label = "Drawings to Healer",
                --     default = "yes",
                -- }
            }
        },
        Builder:Rows{
            Builder:Columns {
                Builder:Checkbox {
                    key = "leftShiftPause",
                    label = "Left Shift Routine Pause",
                    default = "yes",
                },
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "enablestomp",
                    label = "Totem Stomp",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "enableAlerts",
                    label = "Enable Informations",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "enablefakecast",
                    label = "Enable Fake Cast on Tyrant + Fear",
                    default = "yes",
                }
            }
        },
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "enableDebug",
                    label = "Debug Mode [don't touch]",
                    default = "no",
                }
            }
        },
    }
}

local general2 = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "autoburst",
                    label = "Auto Burst",
                    default = "yes",
                },
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
                    key = "autodefensives",
                    label = "Auto Defensives",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoshadowmeld",
                    label = "Auto Shadowmeld",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autonetherward",
                    label = "Auto Netherward",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autohealthstone",
                    label = "Auto Heatlhstone",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autosoulwell",
                    label = "Auto Soulwell in Prep",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoportoption",
                    label = "Auto Port",
                    default = "yes",
                },
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
                    key = "autofear",
                    label = "Auto Fear",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autocoil",
                    label = "Auto Coil",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autokick",
                    label = "Auto Kick",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autostun",
                    label = "Auto Stun",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autoshadowfury",
                    label = "Auto Shadowfury",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "autocurses",
                    label = "Auto Curses",
                    default = "yes",
                },
            }
        }
    }
}

local general5 = Builder:Group {
    title = "",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox {
                    key = "drawingsPort",
                    label = "Drawings for Port",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "drawingsPortLine",
                    label = "Drawing Line to Port",
                    default = "yes",
                },
                Builder:Checkbox {
                    key = "drawingsPortRange",
                    label = "Drawings Port Range",
                    default = "yes",
                },
            }
        }
    }
}

-- local SliderGroupDef = Builder:Group {
--     title = "",
--     content = {
--         Builder:Rows {
--             Builder:Columns {
--                 Builder:Slider {
--                     key = 'defensiveSlider1',
--                     label = "Guardian Spirit (Health %)",
--                     description = "Default is: 50%",
--                     min = 15,
--                     max = 100,
--                     step = 1,
--                     default = 50,
--                     percent = false
--                 },
--             }
--         }
--     }
-- }
-- Table to keep track of current bindings for each key
local currentBindings = {}

-- Function to update the key combos whenever the keybind input changes
local function UpdateKeybindCombo()
    -- Define keybind names and their default values
    local keybinds = {
        { name = "portbutton", default = "SHIFT-ALT-5" },
        { name = "gatebutton", default = "SHIFT-ALT-4" },
        { name = "burstbutton", default = "SHIFT-ALT-3" },
        { name = "kickbutton", default = "SHIFT-ALT-2" },
        { name = "fearPeel", default = "SHIFT-ALT-1" },
        { name = "fearHealer", default = "SHIFT-ALT-0" },
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
local KeybindInputGroup = Builder:Group {
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:EditBox {
                    key = "fearHealer",
                    label = "Use Fear on Enemy Heal",
                    default = "SHIFT-ALT-0",
                },
                Builder:EditBox {
                    key = "fearPeel",
                    label = "Use Fear for Peeling",
                    default = "SHIFT-ALT-1",
                },
                Builder:EditBox {
                    key = "kickbutton",
                    label = "Use Kick/Stun on Target",
                    default = "SHIFT-ALT-2",
                },
                Builder:EditBox {
                    key = "burstbutton",
                    label = "Cast Burst Spells",
                    default = "SHIFT-ALT-3",
                },
                Builder:EditBox {
                    key = "gatebutton",
                    label = "For Soulburn + Gateway on ur Cursor",
                    default = "SHIFT-ALT-4",
                },
                Builder:EditBox {
                    key = "portbutton",
                    label = "For Soulburn + Port",
                    default = "SHIFT-ALT-5",
                },
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
                DropdownGroup
            }
        },
        Builder:Tab {
            title = "Drawings",
            content = {
                general5,
                DropdownGroup
            }
        },
        Builder:Tab {
            title = "Offensive",
            content = {
                general2,
                SliderGroupDef
            }
        },
        Builder:Tab {
            title = "Defensive",
            content = {
                general3,
                SliderGroupDef
            }
        },
        Builder:Tab {
            title = "CC",
            content = {
                general4,
                SliderGroupDef
            }
        },
        Builder:Tab {
        title = "Keybinds",
        content = {
            KeybindInputGroup
            }
        },
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
                                text = "You can add text here",
                                size = 18,
                                font = "Fonts\\FRIZQT__.TTF",
                                color = "CCFFCC",
                            },
                            Builder:Spacer {},
                            Builder:Spacer {},
                            Builder:Spacer {},
                            Builder:Spacer {},
                            Builder:Text {
                                text = "More sample text. This is nice to provide info about your routine.",
                                size = 12,
                                font = "Fonts\\FRIZQT__.TTF",
                                color = "CCFFCC"
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
            title = "Sajs Config",
            icon = 1378282,
            content = {
                TabGroup
            }
        },
    }
}

local Window = Builder:Window {
    key = "sajsdemo",
    title = "|cff8788EE Sajs Demo Warlock",
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
    ResetGUIState()
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
erButton:SetSize(60, 60) -- Increase the button size
-- Set default icon for the button
local function UpdateButtonAppearance(button)
    if button.isEnabled then
        --button:SetNormalTexture("Interface\\Icons\\ability_warlock_improveddemonictactics")
        button:SetNormalTexture("Interface\\Icons\\ability_warlock_improveddemonictactics")
        button.text:SetText("ON")
    else
        button:SetNormalTexture("Interface\\Icons\\ability_warlock_demonicempowerment")
        button.text:SetText("OFF")
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
erButton.text:SetPoint("CENTER", erButton, "CENTER", 0, 14)
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
        enabledrawings = "yes",
        leftShiftPause = "yes",
        autonetherward = "yes",
        autodefensives = "yes",
        autofear = "yes",
        autocoil = "yes",
        autokick = "yes",
        autoburst = "yes",
        autoshadowmeld = "yes",
        autohealthstone = "yes",
        autosoulwell = "yes",
        autocurses = "yes",
        enablestomp = "yes",
        enableAlerts = "yes", 
        enableDebug = "no",
        autoportoption = "yes",
        enablefakecast = "yes",
        drawingsPort = "yes",
        drawingsPortLine = "yes",
        drawingsPortRange = "yes",
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

------------------------------------ DRAW ------------------------------------ 

-- draw:Sync(function(draw)
--     if Builder:GetConfig("enabledrawings") == "yes" then
--     local x, y, z = Position("player")
--         if fHealer then 
--             if InArena() then
--                 local healerX, healerY, healerZ = Position(fHealer.key)
--                 if HitboxDistance(fHealer.key, "player") < 40 and los(fHealer.key, "player") then
--                     draw:SetColor(86, 198, 38, 255)
--                 else
--                     draw:SetColor(247, 76, 64, 255)
--                 end
--                 draw:SetWidth(3)
--                 draw:Line(x, y, z, healerX, healerY, healerZ)
--             end 
--         end
--     end
-- end) 

--hiar
-- port 191083 
-- demon 17252

-- drawingsPort = "yes",
-- drawingsPortLine = "yes",
-- drawingsPortRange = "yes",


draw:Sync(function(draw)
    if Builder:GetConfig("drawingsPortRange") == "yes" then
        for guid,totem in pairs(portals) do
            local totemId = oid(guid)
            if totemId == 191083 then
                local a,b,c = Position(totem.key)
                if a and b and c then
                    if Distance(totem.key, "player") < 60 then 
                        draw:SetColor(153, 153, 255, 100)
                        --draw:Text("Port", "NumberFontNormal", a,b,c)
                        draw:Line(a,b,c, 40)
                    end 
                end
            end
        end
    end
end) 

draw:Sync(function(draw)
    if Builder:GetConfig("drawingsPort") == "yes" then
        for guid,totem in pairs(portals) do
            local totemId = oid(guid)
            if totemId == 191083 then
                local a,b,c = Position(totem.key)
                if a and b and c then
                    if Distance(totem.key, "player") < 40 then 
                        draw:SetColor(86, 198, 38)
                        draw:Text("Port", "NumberFontNormal", a,b,c)
                        draw:Outline(a,b,c,3)
                    else 
                        draw:SetColor(247, 76, 64)
                        draw:Text("Port", "NumberFontNormal", a,b,c)
                        draw:Outline(a,b,c,3)
                    end 
                end
            end
        end
    end
end) 

draw:Sync(function(draw)
    if Builder:GetConfig("drawingsPortLine") == "yes" then
    local x, y, z = Position("player")
        for guid,totem in pairs(portals) do
        local totemId = oid(guid)
            if totemId == 191083 then
                local healerX, healerY, healerZ = Position(totem.key)
                if Distance(totem.key, "player") < 40 then
                    draw:SetColor(86, 198, 38, 255)
                else
                    draw:SetColor(247, 76, 64, 255)
                end
                draw:SetWidth(3)
                draw:Line(x, y, z, healerX, healerY, healerZ)
            end
        end
    end 
end) 


-- for _,trigger in pairs(areaT) do
--     local spellID1,spellID2 = AreaSpell(trigger)
--     -- do someting with spell ID 1/2
--   end

-- GameFontNormal
-- GameFontNormalSmall
-- GameFontNormalLarge
-- GameFontHighlight
-- GameFontHighlightSmall
-- GameFontHighlightSmallOutline
-- GameFontHighlightLarge
-- GameFontDisable
-- GameFontDisableSmall
-- GameFontDisableLarge
-- GameFontGreen
-- GameFontGreenSmall
-- GameFontGreenLarge
-- GameFontRed
-- GameFontRedSmall
-- GameFontRedLarge
-- GameFontWhite
-- GameFontDarkGraySmall
-- NumberFontNormalYellow
-- NumberFontNormalSmallGray
-- QuestFontNormalSmall
-- DialogButtonHighlightText
-- ErrorFont
-- TextStatusBarText
-- CombatLogFont


-- local enemyburstingicon = draw:Texture("Interface\\Icons\\ability_warlock_demonicempowerment", 40, "0:16")

-- draw:Sync(function(draw)
--     --if Builder:GetConfig("enabledrawings") == "yes" then
--        -- for _, enemy in pairs(enemies) do
--             --if enemy.player and not enemy.healer then 
--                 --if enemy.cds then 
--                 --if player.cds then
--                 if HasBuff(264173, "player") then   
--                     local px, py, pz = Position("player")
--                     --draw:Text(enemyburstingicon, "GameFontHighlight", px, py, pz+6)
--                     local icon = C_Spell.GetSpellTexture(5782)
--                     draw:Text(icon, "GameFontNormalLarge", px, py, pz +4)
--                     --end 
--                 end 
--             --end 
--        --end
--    -- end 
-- end)

----war test zu allen groups--
-- draw:Sync(function(draw)
--     if Builder:GetConfig("enabledrawings") == "yes" then
--     local x, y, z = Position("player")
--         for guid, friend in pairs(friends) do
--             if friend then
--                 local friendX, friendY, friendZ = Position(friend)
--                 if HitboxDistance(friend, "player") < 60 and los(friend, "player") then
--                     draw:SetColor(86, 198, 38, 255)
--                 else
--                     draw:SetColor(247, 76, 64, 255)
--                 end
--                 draw:SetWidth(3)
--                 draw:Line(x, y, z, friendX, friendY, friendZ)
--             end
--         end 
--     end
-- end) 

------------------------------------ SPELLS ------------------------------------ 

Elite:Populate({
    corruption = NewSpell(172, { damage = "magic", ignoreChanneling = false, targeted = true }), 
    shadowbolt = NewSpell(686, { damage = "magic", ignoreChanneling = false, targeted = true }),
    darkglare = NewSpell(205180, { damage = "magic", ignoreChanneling = false, targeted = true  }),
    dreadstalker = NewSpell(104316, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true }), 
    charhound = NewSpell(264119, { damage = "magic", ignoreChanneling = true, targeted = true, ignoreMoving = false }), 
    tyrant = NewSpell(265187, { damage = "magic", ignoreChanneling = true, targeted = true, castById = true, fakecast = true }), ---castById = true
    tyrantNoFakeCast = NewSpell(265187, { damage = "magic", ignoreChanneling = true, targeted = true, castById = true }), 
    observer = NewSpell(201996, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true }), 
    demonicstrength = NewSpell(267171, { damage = "physical", ignoreChanneling = true, targeted = true }), 
    handofguldan = NewSpell(105174, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true }), 
    demonbolt = NewSpell(264178, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true, ignoreFacing = false }), 
    implosion = NewSpell(196277, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true }), 
    powersiphon = NewSpell(264130, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true, castById = true }), 
    grimfelguard = NewSpell(111898, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true }), 
    implosion = NewSpell(196277, { damage = "magic", ignoreLoS = false, ignoreChanneling = true, targeted = true }), 
    summonfelguard = NewSpell(30146, { targeted = true }), 
    feldomination = NewSpell(333889, { targeted = true }),
    fellord = NewSpell(212459, { damage = "physical", targeted = false }),
    axetoss = NewSpell(119898, { damage = "physical", targeted = true, ignoreFacing = true }), 

    ---CC----
    fearNoFakeCast = NewSpell(5782, { damage = "magic", ignoreChanneling = false, targeted = true, stopMoving = true, ignoreFacing = true }), 
    fear = NewSpell(5782, { damage = "magic", ignoreChanneling = false, targeted = true, stopMoving = true, ignoreFacing = true, fakecast = true }), 
    coil = NewSpell(6789, { damage = "magic", ignoreChanneling = false, targeted = true }), 
    curseoftongues = NewSpell(1714, { damage = "magic", ignoreChanneling = false , targeted = true }), 
    curseofexhaustion = NewSpell(334275, { damage = "magic", ignoreChanneling = false, targeted = true  }), 
    curseofweakness = NewSpell(702, { damage = "magic", ignoreChanneling = false, targeted = true }), 
    shadowfury = NewSpell(30283, { damage = "magic", targeted = false }),

    ---Defs---
    unendingresolve = NewSpell(104773, { targeted = true, ignoreChanneling = true }),  
    darkpact = NewSpell(108416, { targeted = true, ignoreGCD = true, ignoreChanneling = true }), 
    netherward = NewSpell(212295, { targeted = true, ignoreGCD = true, ignoreChanneling = true, ignoreFacing = true }), 
    shadowmeld = NewSpell(58984, { targeted = true, ignoreGCD = true, ignoreChanneling = true }), 

    ---Rest---
    soulwell = NewSpell(29893, { targeted = true }), 
    soulburn = NewSpell(385899, { targeted = true }), 
    demonicgateway = NewSpell(111771, { targeted = true }), 
    demoniccircle = NewSpell(48018, { targeted = true }), 
    demonicteleport = NewSpell(48020, { targeted = true, ignoreGCD = true }), 
    soulrip = NewSpell(410598, { targeted = true }),
    orcracial = NewSpell(33702, { targeted = true, ignoreGCD = true }),
    trollracial = NewSpell(26297, { targeted = true, ignoreGCD = true }),
    
    
    ---PET ABILITIES---
    soulstrike = NewSpell(264057, { damage = "physical", ignoreChanneling = true, targeted = true, ignoreGCD = true }), 
    felstorm = NewSpell(89751, { damage = "physical", ignoreChanneling = true, targeted = true, ignoreGCD = true }), 
})

local pvpStomps = {
    [179193] = true, -- observer
    [107100] = true, -- observer2
    [101398] = true, -- psyfiend
    [119052] = true, -- warBanner
}

Elite.Stomp(function(pobject, stompItemID)
    if not IsFacing(pobject.key) or not los(pobject.key) then return end 
    if Used("player", 264178, 2) then return end --already stomped--
    if Used("player", 686, 1) then return end --already stomped--
    if Builder:GetConfig("enablestomp") == "yes" then
        if pvpStomps[stompItemID] and HasBuff(264173, "player") and CanCast(264178) and los(pobject.key,"player") and IsFacing(pobject.key) and Distance(pobject.key,"player") <= SpellRange(264178) then
            FaceSmooth(pobject.key, 264178, "Stomping - " .. Name(pobject.key), GetDropdownValues())
            return
        end
        if pvpStomps[stompItemID] and CanCast(686) and los(pobject.key,"player") and IsFacing(pobject.key) and Distance(pobject.key,"player") <= SpellRange(686) then
            FaceSmooth(pobject.key, 686, "Stomping - " .. Name(pobject.key), GetDropdownValues())
            return
        end
        if pvpStomps[stompItemID] and CanCast(686) and Distance(pobject.key,"player") <= SpellRange(686) and IsFacing(pobject.key) and los(pobject.key,"player") then
            FaceSmooth(pobject.key, 686, "Stomping - " .. Name(pobject.key), GetDropdownValues())
            return
        end
    end 
end)

--[6112] = true,   -- windfuryTotem
--[61245] = true,  -- capacitorTotem
--[53006] = true,  -- spiritLinkTotem

local totem1 = {
    [105451] = true, -- counterstrikeTotem
    [5913] = true,   -- tremorTotem
    [5925] = true,   -- groundingTotem
    [105427] = true, -- skyfuryTotem
}
Elite.StompTotems(function(totem, totemId)
    if not IsFacing(totem.key) or not los(totem.key) then return end 
    if Builder:GetConfig("enablestomp") == "yes" then
        if totem1[totemId] and CanCast(686) and Distance(totem.key, "player") <= SpellRange(686) and IsFacing(totem.key) and los(totem.key, "player") then
            FaceSmooth(totem.key, 686, "Stomping - " .. Name(totem.key), GetDropdownValues())
            return
        end
    end 
end)

-------------------------------------------  TABLES -------------------------------------------

local noPanic = { 
    -- 642, --bubble
    -- 186265, --turtle--
    -- 47585, --dispersion--
    -- 125174, --karma--
    -- 45438, --iceblock--
    -- 232707, --ray
    -- 342246, --alter time
    -- 47788, --guardian spirit
    -- 204018, --spellwarding
    -- 116849, --cocoon
    -- 409293, --burrow
    -- 240133, --iceblock#2--
    -- 11327, --vannish--
    -- 114893, --bulwark totem--

    [232707] = true, --ray
    [47788] = true, --guardian spirit
    [204018] = true, --spellwarding
    [642] = true, --bubble
    [186265] = true, --turtle--
    [125174] = true, --karma--
    [45438] = true, --iceblock--
    [342246] = true, --alter time
    [116849] = true, --cocoon
    [409293] = true, --burrow
    [240133] = true, --iceblock#2--
    [11327] = true,  --vannish--
    [114893] = true, --bulwark totem--
 }


--  local someDefensives = { 
--     108271, --astral shift
--     642, --bubble
--     1022, --BoP
--     186265, --turtle--
--     53480, --hunter sac--
--     47585, --dispersion--
--     104773, --warlock wall unsolving res--
--     31224, --cloak--
--     5277, --evasion--
--     125174, --karma--
--     48707, --Anti Magic shell--
--     311975, --anti magic shell#2--
--     48792, --icebound fortitude--
--     292152, --iebound forti#2--
--     45438, --iceblock--
--     240133, --iceblock#2--
--     118038, --die by the sword--
--     196718, --darkness--
--     209426, --darkness#2--
--     363916, --obsidian scales--
--     61336, --survival instincts--
--     --409293, --burrow
--     --116849, --cocoon
--    -- 114893, --bulwark totem--


--     [232707] = true, --ray
--     [47788] = true, --guardian spirit
--     [204018] = true, --spellwarding
--     [642] = true, --bubble
--     [186265] = true, --turtle--
--     [125174] = true, --karma--
--     [45438] = true, --iceblock--
--     [342246] = true, --alter time
--     [116849] = true, --cocoon
--     [409293] = true, --burrow
--     [240133] = true, --iceblock#2--
--     [11327] = true,  --vannish--
--     [114893] = true, --bulwark totem--
--  }

 local immuneBuffs = { 
    -- 212295, --netherward
    -- --48707, --ams
    -- 47585, --dispersion
    -- 23920, --reflect
    -- 125174, --karma
    -- 409293, --burrow
    -- 642, --bubble
    -- 204018, --spellwarding
    -- 45438, --iceblock--
    -- 186265, --turtle--
    -- 33786, --cyclone
    -- 353319, --monk revival 
    -- 408558, --priest immunity fade

    [212295] = true, --netherward
    [47585] = true, --dispersion
    [642] = true, --bubble
    [186265] = true, --turtle--
    [125174] = true, --karma--
    [45438] = true, --iceblock--
    [409293] = true, --burrow
    [240133] = true, --iceblock#2--
    [33786] = true, --cyclone
    [353319] = true,  --monk revival 
    [408558] = true, --priest immunity fade
    [23920] = true, --reflect
}

local noPanicAndDef = { 
    -- 232707, --ray
    -- 47788, --guardian spirit
    -- 204018, --spellwarding
    -- 116849, --cocoon
    -- 33206, --Pain Suppression
    -- 81782, --Dome
    -- 102342, --Ironbark
    -- 1022, --BOP
    -- 6940, --SAC
    -- 325174, --link totem buff
    -- 363534, --rewind prevoker--
    -- 357170, --time dilation--
    -- 196718, --darkness--
    -- 209426, --darkness#2--
    -- 104773, -- unending resolve 
    -- 108416, -- dark pact 

    [232707] = true, --ray
    [47788] = true, --guardian spirit
    [204018] = true, --spellwarding
    [116849] = true, --cocoon
    [33206] = true, --Pain Suppression
    [81782] = true, --Dome
    [102342] = true,  --Ironbark
    [1022] = true, --BOP 
    [6940] = true, --SAC
    [325174] = true, --link totem buff
    [363534] = true, --rewind prevoker--
    [357170] = true, --time dilation--
    [196718] = true, --darkness--
    [209426] = true, --darkness#2--
    [104773] = true, -- unending resolve 
    [108416] = true, -- dark pact
 }

local BigDefonMe = { 
    -- 33206, --Pain Suppression
    -- 102342, --Ironbark
    -- 47788, --Guardian Spirit
    -- 232707, --Ray of Hope
    -- 116849, --cocoon
    -- 1022, --BOP
    -- 6940, --SAC
    -- 325174, --link totem buff
    -- 363534, --rewind prevoker--
    -- 357170, --time dilation--
    -- 196718, --darkness--
    -- 209426, --darkness#2--
    -- 104773, -- unending resolve 
    -- 108416, -- dark pact 

    [232707] = true, --ray
    [47788] = true, --guardian spirit
    [204018] = true, --spellwarding
    [116849] = true, --cocoon
    [33206] = true, --Pain Suppression
    [102342] = true,  --Ironbark
    [1022] = true, --BOP 
    [6940] = true, --SAC
    [325174] = true, --link totem buff
    [363534] = true, --rewind prevoker--
    [357170] = true, --time dilation--
    [104773] = true, -- unending resolve 
    [108416] = true, -- dark pact
}

------------------------------------------- PET CONTROL -------------------------------------------

summonfelguard:Callback(function(spell)
    if UnitExists("pet") and Alive("pet") then return end 
    if oid("pet") ~= 17252 then 
        if spell:Cast() and Alert(spell.id, "Summon Out of Combat!", 100, 200) then
            return
        end
    end 
end)

--- Combo ---
feldomination:Callback(function(spell)
    if UnitExists("pet") and Alive("pet") then return end 
    if Locked() then return end
    if oid("pet") ~= 17252 or oid("pet") == 17252 and not Alive("pet") then 
        if spell:Cast() and Alert(spell.id, "!", 100, 200) then
            return
        end
    end 
end)

summonfelguard:Callback("feldomination", function(spell)
    --if UnitExists("pet") and Alive("pet") then return end 
    if not HasBuff(333889, "player") then return end --procc--
    if oid("pet") ~= 17252 then
        if spell:Cast() and Alert(spell.id, "Summon in Combat!", 100, 200) then
            ControlMovement(0.7)
            return
        end
    end 
end)

-------------------------------------------  DAMAGE -------------------------------------------

shadowbolt:Callback(function(spell)
    if SoulShards("player") >= 3 then return end --we will use hand of guldan--
    if Moving() then return end 
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if los("target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

demonbolt:Callback(function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if not HasBuff(264173, "player") then return end --procc--
    if SoulShards("player") >= 4 then return end 
    if los("target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

local doomCurse = { 
    460553, --doom
}

demonbolt:Callback("target", function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if not HasBuff(264173, "player") then return end --procc--
    if SoulShards("player") >= 4 then return end 
    if not HasDebuff(460553, "target", "player") then --or not HasDebuff(450538, "target", "player") then --Doom or Anima--
        if los("target") then 
            if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                return
            end
        end
    end 
end)

demonbolt:Callback("spread", function(spell)
    for _, enemy in pairs(enemies) do
        if not HasBuff(264173, "player") then return end --procc--
        if BuffFrom(enemy.key, immuneBuffs) then return end 
        if Distance(enemy.key) > 40 then return end 
        if SoulShards("player") >= 4 then return end 
        if InPvp() and not IsPlayer(enemy.key) then return end --in pvp we do different--
        if cc(enemy.key) then return end --running cc on him--
        if bcc(enemy.key) then return end --running bcc on him--
        --if Health("target") < 40 and not BuffFrom("target", BigDefonMe) or not BuffFrom("target", immuneBuffs) then return end  --we kill target maybe--
        if not HasDebuff(460553, enemy.key, "player") then --doom 460553 or anima 450538 
            if los(enemy.key) then 
                if not IsTarget(enemy.key) then
                    if spell:Cast(enemy.key) then --and Alert(spell.id, "!", 100, 200) then
                        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                        return
                    end
                end 
            end 
        end 
    end 
end)

demonbolt:Callback("lowHP", function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if not HasBuff(264173, "player") then return end --procc--
    if AbsorbR("target") > 400000 then return end 
    if BuffFrom("target", BigDefonMe) then return end 
    if los("target") then 
        if Health("target") < 30 then --and not AbsorbR("target") > 400000 then  --above 15% absorb as health--
            if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                return
            end
        end 
    end 
end)

handofguldan:Callback(function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if los("target") then 
        if spell:Cast("target") and Alert(spell.id, "!", 100, 200) then
            return
        end
    end 
end)

handofguldan:Callback("buff", function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if not HasBuff(449793, "player") then return end 
    if SoulShards("player") >= 3 then 
        if los("target") then 
            if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                return
            end
        end 
    end 
end)

dreadstalker:Callback(function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if los("target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

dreadstalker:Callback("procc", function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if not HasBuff(205146, "player") then return end 
    if los("target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

demonbolt:Callback("lowHP", function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if not HasBuff(264173, "player") then return end --procc--
    if AbsorbR("target") > 400000 then return end 
    --if BuffFrom("target", BigDefonMe) then return end 
    if los("target") then 
        if Health("target") < 25 then --and not AbsorbR("target") > 400000 then  --above 15% absorb as health--
            if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "kill!", 100, 200) end 
                return
            end
        end 
    end 
end)

 --we only HIS FUNCTION on opener when everything is rdy, in fight it doesnt matter anymore OR when enemy is low and we have insta procc--
dreadstalker:Callback("highprio", function(spell)
    if SpellCd(265187) < 0.1 and SpellCd(111898) < 0.1 
    or HasBuff(205146, "player") and Health("target") < 30 then 
        if BuffFrom("target", immuneBuffs) then return end 
        if Distance("target") > 40 then return end 
        --if not HasBuff(205146, "player") then return end 
        if los("target") then 
            if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "high prio!", 100, 200) end 
                return
            end
        end 
    end 
end)

dreadstalker:Callback("precast", function(spell)
    if not IsEnemy("target") then return end  --if not enemy--
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if los("target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "precast!", 100, 200) end 
            return
        end
    end 
end)

charhound:Callback(function(spell)
    if SpellCd(265187) > 3 and SpellCd(265187) < 10 then return end --tyrant go rdy soon--
    if SpellCd(455476) > 0.1 then return end --charhound--
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    --if los("target") then 
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    --end 
end)

charhound:Callback("precast", function(spell)
    if not IsEnemy("target") then return end  --if not enemy--
    if SpellCd(455476) > 0.1 then return end --charhound--
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 60 then return end 
   -- if los("target") then 
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "precast!", 100, 200) end 
            return
        end
    --end 
end)

powersiphon:Callback(function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
   --if not HasBuff(264173, "player") then return end --insta demo procc--
    if los("target") then 
        if spell:Cast("player") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "precast!", 100, 200) end 
            return
        end
    end 
end)

--- burst ---

tyrantNoFakeCast:Callback(function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end
    if SpellCd(455476) < 16 then return end --charhound not out--
    if SpellCd(104316) < 4 then return end --dreadstalker not out--
    if Builder:GetConfig("autoburst") == "yes" then -- fake cast is enabled--
        for _,minion in pairs(fminions) do
            if SpellCd(111898) > 0.1 and SpellCd(111898) < 13 then return end --we have Big 2 min Felguard rdy soon--
            local minionID = oid(minion)
            if minionID == 226269 then --charhound--
               -- if minionID == 98035 then --doggies
                    if BuffFrom("target", immuneBuffs) then return end 
                    if Distance("target") > 60 then return end 
                    --if los("target") then 
                        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "no fakecast!", 100, 200) end 
                            return
                        end
                    --end 
                --end 
            end 
        end 
    end 
end)

tyrant:Callback(function(spell)
    if GuardActive(0.1) then return end
    if SpellCd(455476) < 16 then return end --charhound not out--
    if SpellCd(104316) < 4 then return end --dreadstalker not out--
    if Builder:GetConfig("enablefakecast") == "no" then return end
    if Builder:GetConfig("autoburst") == "yes" then
        for _,minion in pairs(fminions) do
            if SpellCd(111898) > 0.1 and SpellCd(111898) < 13 then return end --we have Big 2 min Felguard rdy soon--
            local minionID = oid(minion)
            if minionID == 226269 then --charhound--
               -- if minionID == 98035 then ----doggies
                    if BuffFrom("target", immuneBuffs) then return end 
                    if Distance("target") > 60 then return end 
                    --if los("target") then 
                        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "fakecast!", 100, 200) end 
                            return
                        end
                    --end 
              --  end 
            end 
        end 
    end
end)

tyrant:Callback("binds", function(spell)
    if Builder:GetConfig("enablefakecast") == "no" then return end
    if GuardActive(0.1) then return end
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    --if ccr(eHealer) >= 2 then 
    --elseif not UnitExists(eHealer) then 
    if los("target") then 
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

tyrantNoFakeCast:Callback("binds", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end
    --if GuardActive(0.1) then return end
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    --if ccr(eHealer) >= 2 then 
    --elseif not UnitExists(eHealer) then 
    if los("target") then 
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

grimfelguard:Callback(function(spell)
    if SpellCd(265187) > 0.1 and SpellCd(265187) < 22 then return end --tyrant rdy soon--
    if SpellCd(455476) < 10 then return end --charhound not out--
    if Builder:GetConfig("autoburst") == "yes" then
        if not eHealer then 
            if BuffFrom("target", immuneBuffs) then return end 
            if Distance("target") > 40 then return end 
            if los("target") then 
                if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                    if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                    return
                end
            end 
        end 
    end 
end)

grimfelguard:Callback("vsHealer", function(spell)
    if SpellCd(265187) > 0.1 and SpellCd(265187) < 22 then return end --tyrant rdy soon--
    if SpellCd(455476) < 20 then return end --charhound not out--
    if Builder:GetConfig("autoburst") == "yes" then
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
        if eHealer then 
            if cc(eHealer.key) and ccr(eHealer.key) > 2 then 
                if los("target") then 
                    if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                        return
                    end
                end 
            end 
        end 
    end 
end)

grimfelguard:Callback("binds", function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if los("target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

demonicstrength:Callback(function(spell)
    if SpellCd(265187) < 0.1 then return end --we will tyrant first--
    if SpellCd(265187) > 0.1 and SpellCd(265187) < 15 then return end --tyrant rdy soon--
    if not eHealer then 
        if Builder:GetConfig("autoburst") == "yes" then
        if BuffFrom("target", immuneBuffs) then return end 
        if Distance("target") > 40 then return end 
            if los("target") then 
                if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                    if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                    return
                end
            end
        end 
    end 
end)

demonicstrength:Callback("vsHealer", function(spell)
    if SpellCd(265187) < 0.1 then return end --we will tyrant first--
    if SpellCd(265187) > 0.1 and SpellCd(265187) < 15 then return end --tyrant rdy soon--
    if Builder:GetConfig("autoburst") == "yes" then
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
        if eHealer then 
            if cc(eHealer.key) and ccr(eHealer.key) > 1 
            or Health("target") < 30 then 
                if los("target") then 
                    if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                        return
                    end
                end 
            end 
        end 
    end 
end)

demonicstrength:Callback("binds", function(spell)
    if BuffFrom("target", immuneBuffs) then return end 
    if Distance("target") > 40 then return end 
    if los("target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end)

soulstrike:Callback("petability", function(spell)
    if SoulShards("player") >= 5 then return end --we will use hand of guldan--
    if SpellCd(264057) > 0.1 then return end 
    if BuffFrom("target", immuneBuffs) then return end 
    --if Distance("target") > 50 then return end 
    --if los("pet", "target") then 
        if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    --end 
end)

felstorm:Callback("petability", function(spell)
    if not IsEnemy("target") then return end
    --if SpellCd(89766) < 0.1 and StunDr("target") == 1 then return end  --stun ready and we can stun him--
    if SpellCd(89751) > 0.1 then return end 
    if BuffFrom("target", immuneBuffs) then return end 
    if bcc("target") then return end 
    if Distance("target", "pet") < 8 then 
        if los("pet", "target") then 
            if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                return
            end
        end 
    end 
end)

observer:Callback(function(spell)
    if Used("player", 48020, 1) then return end  --we ported us, so prob not open field--
    if not HasTalent(spell.id) then return end
    if InPvp() then 
        for _, enemy in pairs(enemies) do
            if Distance(enemy.key, "player") < 30 and los(enemy.key) then 
                if Used(enemy.key, 190319, 8) --combustion--
                or Spec(enemy.key) == 102 and Used(enemy.key, 102543, 15) --incarn Boomkin--
                or Used(enemy.key, 12472, 15)  --veins--
                or Used(enemy.key, 386997, 5) --affli soulrot
                or Used(enemy.key, 205180, 10) --affli dark glare
                or Used(enemy.key, 1122, 4) --destro summon infernal
                or Used(enemy.key, 196447, 1) --destro channel demonfire 
                or Used(enemy.key, 264130, 3) --demo power siphon
                or Used(enemy.key, 265187, 8) --demo tyrant
                or Used(enemy.key, 327162, 4)  --primo wave enhance--
                or Used(enemy.key, 375982, 4)  --primo wave ele --
                or Spec(enemy.key) == 262 and HasBuff(114050, enemy.key) --ele ascendance 
                or Spec(enemy.key) == 263 and HasBuff(114050, enemy.key) --enhaance ascendance 
                or Used(enemy.key, 391109, 6)  --dark ascension Priest
                or Used(enemy.key, 10060, 5)  --PI
                or Used(enemy.key, 211522, 2)  --psyfiend
                or Used(enemy.key, 191634, 2)  --stormkeeper
                or Spec(enemy.key) == 256 and Used(enemy.key, 8092, 6) -- Disc Priest Mind blast w Voidweaver
                or Used(enemy.key, 228260, 4)  -- SP Void Erruption 
                or Used(enemy.key, 263165, 2)  -- SP Void Torrent
                or Used(enemy.key, 375087, 10)  -- Dragonrage
                or Used(enemy.key, 357210, 2) then --Dragon breath
                    if spell:Cast("player") then --and Alert(spell.id, "!", 100, 200) then
                        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                        return
                    end 
                end 
            end
        end
    end 
end)

fellord:Callback(function(spell)
    if not HasTalent(spell.id) then return end
    if Builder:GetConfig("autoburst") == "yes" then
        for _, enemy in pairs(enemies) do
            if Used(enemy.key, 227847, 4) then return end --bladestorm because its not taking the buffid
            if HasBuff(345228, enemy.key) then return end  --lolstorm--
            if HasBuff(227847, enemy.key) then return end  --lolstorm--
            if Mounted(enemy.key) or SlowImmune(enemy.key) then return end 
            if IsMelee(enemy.key) and Bursting(enemy.key) and los(enemy.key) 
            or Stunned(enemy.key) and StunRemains(enemy.key) >= 2 then 
                if spell:Cast(enemy.key) then --and Alert(spell.id, "!", 100, 200) then
                    if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                    return
                end
            end
        end
    end 
end)

fellord:Callback("binds", function(spell)
    if not HasTalent(spell.id) then return end
    for _, enemy in pairs(enemies) do
        if Mounted(enemy.key) or SlowImmune(enemy.key) then return end 
        if IsMelee(enemy.key) and Bursting(enemy.key) and los(enemy.key)  
        or Stunned(enemy.key) and StunRemains(enemy.key) >= 2 then 
            if spell:Cast(enemy.key) then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
                return
            end
        end
    end
end)

-------------------------------------------  DEFENSIVES -------------------------------------------

darkpact:Callback("healerCC", function(spell)
    if Builder:GetConfig("autodefensives") == "yes" then
        if BuffFrom("player", BigDefonMe) then return end 
        if BuffFrom("player", noPanic) then return end 
        if Used("player", 48020, 3) then return end  --we ported us--
        if Used("player", 104773, 4) then return end  --unending resolve used--
        if AbsorbR("player") > 400000 then return end 
        for _, enemy in pairs(enemies) do
            if Health("player") > 50 and  Health("player") < 98 then
                if fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2 
                or fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2
                or fHealer and Silence(fHealer.key)
                or not fHealer then 
                    if los(enemy.key) and TargetingAB(enemy.key, "player") then
                        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "Pact!", 100, 200) end 
                            return
                        end
                    end
                end
            end 
        end
    end 
end)

unendingresolve:Callback("healerCC", function(spell)
    if Builder:GetConfig("autodefensives") == "yes" then
        if SpellCd(108416) > 0.1 and Health("player") > 50 then return end --we will use pact first--
        if BuffFrom("player", BigDefonMe) then return end 
        if BuffFrom("player", noPanic) then return end 
        if Used("player", 48020, 3) then return end  --we ported us--
        if Used("player", 108416, 2) then return end  --dark pact used--
        if AbsorbR("player") > 350000 then return end 
        for _, enemy in pairs(enemies) do
            if Bursting(enemy.key) then
                if fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2
                or fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2 
                or fHealer and Silence(fHealer.key) 
                or fHealer and Health("player") < 40  --if our healer is really not healing us--
                or not fHealer and Health("player") < 90 then 
                    if los(enemy.key) and TargetingAB(enemy.key, "player") then
                        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "Resolve", 100, 200) end 
                            return
                        end
                    end
                end
            end 
        end
    end 
end)

local UsedHS = false

soulburn:Callback("HS", function(spell)

    if Used("player", 48020, 2) then return end  --we ported us--
    if Used("player", 108416, 2) then return end  --dark pact used--
    --if AbsorbR("player") > 300000 then return end 
    if SoulShards("player") < 1 then return end 
   -- if not BuffFrom("player", noPanicAndDef) then
        if Health("player") <= 35 then
            if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "HS Soulburn!", 100, 200) end 
                return
            end
        end 
   -- end
end) 

function HealthStoneUsage()
    if Builder:GetConfig("autohealthstone") == "yes" then
     
        if Used("player", 48020, 2) then return end  --we ported us--
        if Used("player", 108416, 2) then return end  --dark pact used--
        --if AbsorbR("player") > 300000 then return end 
        if Health("player") <= 35 then
            --if not BuffFrom("player", noPanicAndDef) then
            rmt("/use Demonic Healthstone")
           
            --end 
        end 
    end 
end 

soulburn:Callback("HSverylow", function(spell)
    if Used("player", 48020, 2) then return end  --we ported us--
    if Used("player", 108416, 2) then return end  --dark pact used--
    if AbsorbR("player") > 500000 then return end 
    if SoulShards("player") < 1 then return end 
    --if not BuffFrom("player", noPanicAndDef) then
        if Health("player") <= 20 then
            if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "HS Soulburn!", 100, 200) end 
                return
            end
        end 
    --end
end) 

function HealthStoneUsageVerylow()
    if Builder:GetConfig("autohealthstone") == "yes" then
        if UsedHS then return end 
        if Used("player", 48020, 2) then return end  --we ported us--
        if Used("player", 108416, 2) then return end  --dark pact used--
        if AbsorbR("player") > 500000 then return end 
        if Health("player") <= 20 then
            --if not BuffFrom("player", noPanicAndDef) then
            rmt("/use Demonic Healthstone")
            UsedHS = true 
            --end 
        end 
    end 
end 

-- soulburn:Callback("HS", function(spell)
--     if UsedHS then return end 
--     if Used("player", 48020, 2) then return end  --we ported us--
--     if Used("player", 108416, 2) then return end  --dark pact used--
--     if Used("player", 48020, 2) then return end  --we ported us--
--     if AbsorbR("player") > 300000 then return end 
--     if SpellCd(111771) > 2 then return end 
--     if SoulShards("player") < 1 then return end 
--     if spell:Cast() and Alert(spell.id, "!", 100, 200) then 
--         return 
--     end 
-- end) 

-- local reflects = {
--     118, --sheep
--     161355, --sheep
--     161354, --sheep
--     161353, --sheep
--     126819, --sheep
--     61780, --sheep
--     161372, --sheep
--     61721, --sheep
--     61305, --sheep
--     28272, --sheep
--     28271, --sheep
--     277792, --sheep
--     277787, --sheep
--     460392, --Newsheep
--     51514, -- Hex Standard
--     211015, -- Hex Kakerlake
--     210873, -- Hex Raptor
--     277784, -- Hex Köter
--     277784, -- Hex Köter
--     277778, -- Hex Zandalari
--     269352, -- Hex Skelett
--     211004, -- Hex Spider
--     20066, -- repentance
--     33786, -- clone
--     5782, -- fear
--     198898,  -- Sleep Walk
--     116858,  -- chaos bolt
--     199786, --glacial spike
--     228260, --void erruption
--     323764, --convoke
--     365350, --arcane surge
--     386997, --soulrot
--   }

local reflects = {
    [118] = true, --sheep
    [161355] = true, --sheep
    [161354] = true, --sheep
    [161353] = true, --sheep
    [126819] = true, --sheep
    [61780] = true, --sheep
    [161372] = true, --sheep
    [61721] = true, --sheep
    [61305] = true, --sheep
    [28272] = true, --sheep
    [28271] = true, --sheep
    [277792] = true, --sheep
    [277787] = true, --sheep
    [460392] = true, --Newsheep
    [51514] = true, -- Hex Standard
    [211015] = true, -- Hex Kakerlake
    [210873] = true, -- Hex Raptor
    [277784] = true, -- Hex Köter
    [277778] = true,  -- Hex Zandalari
    [269352] = true, -- Hex Skelett
    [211004] = true, -- Hex Spider
    [20066] = true, -- repentance
    [33786] = true, -- clone
    [5782] = true, -- fear
    [198898] = true, -- Sleep Walk
    [116858] = true, -- chaos bolt
    [199786] = true, --glacial spike
    [228260] = true,  --void erruption
    [323764] = true, --convoke
    [365350] = true, --arcane surge
    [386997] = true, --soulrot
    -- [] = true,
} 

netherward:Callback(function(spell)
    if Builder:GetConfig("autonetherward") == "yes" then
        if not HasTalent(spell.id) then return end
        for _, enemy in pairs(enemies) do
            if IsCastingT(enemy.key, reflects) then
                if CastTarget(enemy.key, "player") then
                    local percentCast = CastingPercent(enemy.key)
                    if IsCasting(enemy.key) and percentCast > 65 then 
                        if los(enemy.key) then 
                            if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "reflect!", 100, 200) end 
                                return
                            end
                        end 
                    end 
               end 
            end 
        end 
    end 
end)

netherward:Callback("Bursting", function(spell)
    if Builder:GetConfig("autonetherward") == "yes" then
        if not HasTalent(spell.id) then return end
        for _, enemy in pairs(enemies) do
            if Used(enemy.key, 375982, 1) --primo--
            or Used(enemy.key, 375087, 1) then  -- Dragonrage
                if los(enemy.key) and TargetingAB(enemy.key, "player") then
                    if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "reflect!", 100, 200) end 
                        return
                    end
                end 
            end 
        end 
    end 
end)

soulrip:Callback("Bursting", function(spell)
    --if Builder:GetConfig("autonetherward") == "yes" then
        if not HasTalent(spell.id) then return end
        for _, enemy in pairs(enemies) do
            if Used(enemy.key, 375982, 1) or Bursting(enemy.key) then 
                if los(enemy.key) and Distance("player", enemy.key) < 20 then
                    if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
                        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "bursting!", 100, 200) end 
                        return
                    end
                end 
            end 
        end 
    --end 
end)

shadowmeld:Callback("cc", function(spell)
    if Builder:GetConfig("autoshadowmeld") == "yes" then
        if SpellCd(58984) > 1 then return end 
        if HasTalent(212295) and SpellCd(212295) < 0.1 then return end --spell reflect talented rdy--
        for _, enemy in pairs(enemies) do
            if IsCastingT(enemy.key, reflects) then
                if CastTarget(enemy.key, "player") then
                    local percent = CastingPercent(enemy.key)
                    if IsCasting(enemy.key) and percent > 90 then 
                        if los(enemy.key) then 
                            if spell:Cast() and Alert(spell.id, "Meld CC", 100, 200) then 
                                return 
                            end 
                        end 
                    end 
                end 
            end 
        end
    end 
end)

soulburn:Callback("autoport", function(spell)
    if Builder:GetConfig("autoportoption") == "yes" then
        if BuffFrom("player", BigDefonMe) then return end 
        if BuffFrom("player", noPanic) then return end 
        if Used("player", 48020, 2) then return end  --we ported us--
        if Used("player", 104773, 4) then return end  --unending resolve used--
        if Used("player", 108416, 4) then return end  --dark pact--
        if AbsorbR("player") > 1000000 then return end 
        if SpellCd(48020) > 0.5 then return end 
        if SoulShards("player") < 1 then return end 
        if Builder:GetConfig("autodefensives") == "yes" then
            if CanCast(48020) then 
                for _, enemy in pairs(enemies) do
                    if Distance(enemy.key, "player") < 40 then --Bursting(enemy.key) and 
                        if fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2 and TargetingAB(enemy.key, "player") 
                        or fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2 and TargetingAB(enemy.key, "player") 
                        or fHealer and Silence(fHealer.key) and TargetingAB(enemy.key, "player") 
                        or Used(enemy.key, 443028, 5) --vortex used by enemy--
                        or InMelee(enemy.key) and Used(enemy.key, 1719, 8) and TargetingAB(enemy.key, "player") ---Fury Recklessness
                        or InMelee(enemy.key) and Used(enemy.key, 227847, 4) and TargetingAB(enemy.key, "player") -- War bladestorm
                        or InMelee(enemy.key) and Used(enemy.key, 107574, 12) and TargetingAB(enemy.key, "player") -- War Avatar
                        or InMelee(enemy.key) and Used(enemy.key, 443028, 4) and TargetingAB(enemy.key, "player") -- WW celestial-conduit
                        or InMelee(enemy.key) and Used(enemy.key, 285272, 6) and TargetingAB(enemy.key, "player") -- Serenity
                        or InMelee(enemy.key) and Used(enemy.key, 383269, 8) and TargetingAB(enemy.key, "player") --DK Burst Abo
                        or InMelee(enemy.key) and Used(enemy.key, 455395, 8) and TargetingAB(enemy.key, "player") --DK Burst Transformaiton 
                        or InMelee(enemy.key) and Used(enemy.key, 207289, 8) and TargetingAB(enemy.key, "player") --DK Burst unholy assault
                        or InMelee(enemy.key) and Used(enemy.key, 279302, 8) and TargetingAB(enemy.key, "player") ---Frost DK burst 
                        or InMelee(enemy.key) and Used(enemy.key, 360194, 6) and TargetingAB(enemy.key, "player") -- Assa deathmark 
                        or InMelee(enemy.key) and Used(enemy.key, 121471, 6) and TargetingAB(enemy.key, "player") -- Sub shadowblades 
                        or InMelee(enemy.key) and Used(enemy.key, 185313, 6) and TargetingAB(enemy.key, "player") -- Sub shadowdance  152173
                        or InMelee(enemy.key) and HasBuff(162264, enemy.key) and TargetingAB(enemy.key, "player") --DH Meta
                        or InMelee(enemy.key) and HasBuff(231895, enemy.key) and TargetingAB(enemy.key, "player") --Ret Crusade
                        or InMelee(enemy.key) and HasDebuff(196937, "player", enemy.key) and TargetingAB(enemy.key, "player") -- Outlaw Ghost Strike Debuff
                        or Spec(enemy.key) == 70 and Distance(enemy.key) < 12 and Used(enemy.key, 231895, 12) and TargetingAB(enemy.key, "player") -- Ret Wings
                        or Spec(enemy.key) == 103 and InMelee(enemy.key) and Used(enemy.key, 102543, 12) and TargetingAB(enemy.key, "player") -- Feral Burst Incarn
                        or Spec(enemy.key) == 103 and InMelee(enemy.key) and Used(enemy.key, 106951, 12) and TargetingAB(enemy.key, "player") -- Feral Burst Berserker
                        or Spec(enemy.key) == 253 and Distance(enemy.key, "player") < 30 and Used(enemy.key, 19574, 7) and TargetingAB(enemy.key, "player") -- BM Hunter Burst
                        or Spec(enemy.key) == 255 and Distance(enemy.key, "player") < 15 and Used(enemy.key, 266779, 10) and TargetingAB(enemy.key, "player") -- Survival Hunter Burst 
                        or Spec(enemy.key) == 263 and InMelee(enemy.key) and HasBuff(114051, enemy.key) and TargetingAB(enemy.key, "player") then -- Enhance Burst
                            --if TargetingAB(enemy.key, "player") then
                                if spell:Cast() and Alert(spell.id, "Auto Port", 100, 200) then 
                                    return 
                                end 
                            -- end
                        end
                    end
                end
            end 
        end 
    end 
end) 

  --or IsMelee(enemy.key) and InMelee(enemy.key) and Bursting(enemy.key)
demonicteleport:Callback("autoport", function(spell)
    if Builder:GetConfig("autoportoption") == "yes" then
        if BuffFrom("player", BigDefonMe) then return end 
        if BuffFrom("player", noPanic) then return end 
        if Used("player", 48020, 3) then return end  --we ported us--
        if Used("player", 104773, 4) then return end  --unending resolve used--
        if AbsorbR("player") > 1000000 then return end 
        if Builder:GetConfig("autodefensives") == "yes" then
            if HasBuff(387626, "player") then --soulburn for freedom--
                if CanCast(48020) then 
                    for _, enemy in pairs(enemies) do
                        if Distance(enemy.key, "player") < 40 then --Bursting(enemy.key) and 
                            if fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2 and TargetingAB(enemy.key, "player") 
                            or fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2 and TargetingAB(enemy.key, "player") 
                            or fHealer and Silence(fHealer.key) and TargetingAB(enemy.key, "player") 
                            or Used(enemy.key, 443028, 5) --vortex used by enemy-- 
                            or InMelee(enemy.key) and Used(enemy.key, 1719, 8) and TargetingAB(enemy.key, "player") ---Fury Recklessness
                            or InMelee(enemy.key) and Used(enemy.key, 227847, 4) and TargetingAB(enemy.key, "player") -- War bladestorm
                            or InMelee(enemy.key) and Used(enemy.key, 107574, 12) and TargetingAB(enemy.key, "player") -- War Avatar
                            or InMelee(enemy.key) and Used(enemy.key, 443028, 4) and TargetingAB(enemy.key, "player") -- WW celestial-conduit
                            or InMelee(enemy.key) and Used(enemy.key, 285272, 6) and TargetingAB(enemy.key, "player") -- Serenity
                            or InMelee(enemy.key) and Used(enemy.key, 383269, 8) and TargetingAB(enemy.key, "player") --DK Burst Abo
                            or InMelee(enemy.key) and Used(enemy.key, 455395, 8) and TargetingAB(enemy.key, "player") --DK Burst Transformaiton 
                            or InMelee(enemy.key) and Used(enemy.key, 207289, 8) and TargetingAB(enemy.key, "player") --DK Burst unholy assault
                            or InMelee(enemy.key) and Used(enemy.key, 279302, 8) and TargetingAB(enemy.key, "player") ---Frost DK burst 
                            or InMelee(enemy.key) and Used(enemy.key, 360194, 6) and TargetingAB(enemy.key, "player") -- Assa deathmark 
                            or InMelee(enemy.key) and Used(enemy.key, 121471, 6) and TargetingAB(enemy.key, "player") -- Sub shadowblades 
                            or InMelee(enemy.key) and Used(enemy.key, 185313, 6) and TargetingAB(enemy.key, "player") -- Sub shadowdance  152173
                            or InMelee(enemy.key) and HasBuff(162264, enemy.key) and TargetingAB(enemy.key, "player") --DH Meta
                            or InMelee(enemy.key) and HasBuff(231895, enemy.key) and TargetingAB(enemy.key, "player") --Ret Crusade
                            or InMelee(enemy.key) and HasDebuff(196937, "player", enemy.key) and TargetingAB(enemy.key, "player") -- Outlaw Ghost Strike Debuff
                            or Spec(enemy.key) == 70 and Distance(enemy.key) < 12 and Used(enemy.key, 231895, 12) and TargetingAB(enemy.key, "player") -- Ret Wings
                            or Spec(enemy.key) == 103 and InMelee(enemy.key) and Used(enemy.key, 102543, 12) and TargetingAB(enemy.key, "player") -- Feral Burst
                            or Spec(enemy.key) == 103 and InMelee(enemy.key) and Used(enemy.key, 106951, 12) and TargetingAB(enemy.key, "player") -- Feral Burst Berserker
                            or Spec(enemy.key) == 253 and Distance(enemy.key, "player") < 30 and Used(enemy.key, 19574, 7) and TargetingAB(enemy.key, "player") -- BM Hunter Burst
                            or Spec(enemy.key) == 255 and Distance(enemy.key, "player") < 15 and Used(enemy.key, 266779, 10) and TargetingAB(enemy.key, "player") -- Survival Hunter Burst 
                            or Spec(enemy.key) == 263 and InMelee(enemy.key) and HasBuff(114051, enemy.key) and TargetingAB(enemy.key, "player") then -- Enhance Burst
                                --- ww fist of furies adden?--
                                --if TargetingAB(enemy.key, "player") then
                                    if spell:Cast() and Alert(spell.id, "Auto Port", 100, 200) then 
                                        return 
                                    end 
                            -- end
                            end
                        end
                    end
                end 
            end 
        end 
    end 
end)


-------------------------------------------  CC -------------------------------------------

local nofearthings = { 
    -- 377362, --precog
    -- 8178, --grounding
    -- 23920, --reflect
    -- 212295, --netherward--
    -- 353319, --monk revival
    -- 409293, --burrow
    -- 215769, --angel
    -- 378464, --nullyfying shroud
    -- 6940, -- sac
    [377362] = true, --precog
    [8178] = true, --grounding
    [23920] = true, --reflect
    [212295] = true, --netherward--
    [353319] = true, --monk revival
    [409293] = true, --burrow
    [215769] = true, --angel
    [378464] = true, --nullyfying shroud
    [6940] = true, -- sac
    [345228] = true, --burrow
    [227847] = true, --angel
    [49039] = true, --lichborne
}

fear:Callback("healer", function(spell)
    if Builder:GetConfig("enablefakecast") == "no" then return end
    if GuardActive(0.1) then return end
    for _,minion in pairs(fminions) do
    local minionID = oid(minion)
        if minionID == 226269 then --charhound--
            if minionID == 98035 then ----doggies
                if Builder:GetConfig("autofear") == "yes" then
                    if not BuffFrom("target", noPanic) and Health("target") < 20 then return end 
                    if Used(spell.id, 1) then return end
                    if not eHealer then return end 
                    -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
                    if InArena() then
                        if HasDebuff(81261, eHealer.key) then return end --he is root-beamed-
                        if BuffFrom(eHealer.key, nofearthings) then return end 
                        if BuffFrom(eHealer.key, immuneBuffs) then return end 
                        if HasDebuff(118699, eHealer.key) and GetDebuffRemaining(118699, eHealer.key) > 3 then return end  --already feard--
                        if not los(eHealer.key) then return end -- not LoS ---
                        if dr(eHealer.key, 118699) < 0.5 then return end --we dont trippe fear--
                        if dr(eHealer.key, 118699) < 1 and drr(eHealer.key, 118699) < 11 then return end --dr remains--
                        if dr(eHealer.key, 118699) < 0.5 and drr(eHealer.key, 118699) < 17 then return end --dr remains--
                        if IsTarget(eHealer.key) then return end --we go on him, so we don't fear--
                        local fearCastTime = CastTime(5782)    
                        if cc(eHealer.key) and ccr(eHealer.key) > fearCastTime then return end 
                        if bcc(eHealer.key) and bccr(eHealer.key) > 2 then return end      
                        if GetDebuffRemaining(118699, eHealer.key) < fearCastTime or not HasDebuff(118699, eHealer.key) then
                            if spell:Cast(eHealer.key) and Alert(spell.id, "Fear Healer", 100, 200) then 
                                return
                            end
                        end
                    end 
                end 
            end
        end 
    end 
end)

fearNoFakeCast:Callback("healer", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end
    for _,minion in pairs(fminions) do
    local minionID = oid(minion)
        if minionID == 226269 then --charhound--
            if minionID == 98035 then ----doggies
                if Builder:GetConfig("autofear") == "yes" then
                    if not BuffFrom("target", noPanic) and Health("target") < 20 then return end 
                    if Used(spell.id, 1) then return end
                    if not eHealer then return end 
                    -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
                    if InArena() then
                        if HasDebuff(81261, eHealer.key) then return end --he is root-beamed-
                        if BuffFrom(eHealer.key, nofearthings) then return end 
                        if BuffFrom(eHealer.key, immuneBuffs) then return end 
                        if HasDebuff(118699, eHealer.key) and GetDebuffRemaining(118699, eHealer.key) > 3 then return end  --already feard--
                        if not los(eHealer.key) then return end -- not LoS ---
                        if dr(eHealer.key, 118699) < 0.5 then return end 
                        if dr(eHealer.key, 118699) < 1 and drr(eHealer.key, 118699) < 11 then return end --dr remains--
                        if dr(eHealer.key, 118699) < 0.5 and drr(eHealer.key, 118699) < 17 then return end --dr remains--
                        if IsTarget(eHealer.key) then return end --we go on him, so we don't fear--
                        local fearCastTime = CastTime(5782)    
                        if cc(eHealer.key) and ccr(eHealer.key) > fearCastTime then return end 
                        if bcc(eHealer.key) and bccr(eHealer.key) > 2 then return end      
                        if GetDebuffRemaining(118699, eHealer.key) < fearCastTime or not HasDebuff(118699, eHealer.key) then
                            if spell:Cast(eHealer.key) and Alert(spell.id, "Fear Healer", 100, 200) then 
                                return
                            end
                        end
                    end 
                end 
            end
        end 
    end 
end)

local nofearthingsNoShroud = { 
    -- 377362, --precog
    -- 8178, --grounding
    -- 23920, --reflect
    -- 212295, --netherward--
    -- 353319, --monk revival
    -- 409293, --burrow
    -- 215769, --angel
    -- 6940, -- sac
    -- 345228, --lolstorm
    -- 227847, --lolstorm2
    -- 48707, --AMS

    [377362] = true, --precog
    [8178] = true, --grounding
    [23920] = true, --reflect
    [212295] = true, --netherward--
    [353319] = true, --monk revival
    [409293] = true, --burrow
    [215769] = true, --angel
    [378464] = true, --nullyfying shroud
    [6940] = true, -- sac
    [345228] = true, --burrow
    [227847] = true, --angel
    [227847] = true, --lolstorm
    --[48707] = true, --nullyfying shroud
}

fear:Callback("healerbinds", function(spell)
    if Builder:GetConfig("enablefakecast") == "no" then return end
    if GuardActive(0.1) then return end
    if Used(spell.id, 1) then return end
    if InPvp() then
        if not eHealer then return end
        if BuffFrom(eHealer.key, nofearthingsNoShroud) then return end 
        if BuffFrom(eHealer.key, immuneBuffs) then return end 
        if not los(eHealer.key) then return end -- not LoS ---
        if dr(eHealer.key, 118699) < 0.25 then return end 
        if dr(eHealer.key, 118699) < 0.5 and drr(eHealer.key, 118699) < 5 then return end --dr remains--
        if spell:Cast(eHealer.key) and Alert(spell.id, "Fear Healer", 100, 200) then 
            return
        end
    end 
end)

fearNoFakeCast:Callback("healerbinds", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end
    if Used(spell.id, 1) then return end
    if InPvp() then
        if not eHealer then return end
        if BuffFrom(eHealer.key, nofearthingsNoShroud) then return end 
        if BuffFrom(eHealer.key, immuneBuffs) then return end 
        if not los(eHealer.key) then return end -- not LoS ---
        if dr(eHealer.key, 118699) < 0.25 then return end 
        if dr(eHealer.key, 118699) < 0.5 and drr(eHealer.key, 118699) < 5 then return end --dr remains--
        if spell:Cast(eHealer.key) and Alert(spell.id, "Fear Healer", 100, 200) then 
            return
        end
    end 
end)

fear:Callback("peel", function(spell)
    if Builder:GetConfig("enablefakecast") == "no" then return end --we fake cast--
    if GuardActive(0.1) then return end
    if Used("player", 6789, 2) then return end --coil used--
    if Builder:GetConfig("autofear") == "yes" then
        if not fHealer then return end 
        if not BuffFrom("target", noPanic) and Health("target") < 30 then return end 
        if CheckWasCasting() then return end 
        if Used(spell.id, 1) then return end
        -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
        if InArena() then
            for _, enemy in pairs(enemies) do
            if not IsPlayer(enemy.key) then return end 
            if IsHealer(enemy.key) then return end -- not on heal --
            if HasDebuff(118699, enemy.key) then return end --current fear is running on enemy casted by me--
            if eHealer and HasDebuff(118699, eHealer.key, "player") then return end --current fear is running on enemy casted by me--
            if cc(enemy.key) and ccr(enemy.key) > 3 then return end --running cc on him--
            if BuffFrom(enemy.key, nofearthings) then return end 
            if BuffFrom(enemy.key, immuneBuffs) then return end 
            if dr(enemy.key, 118699) < 1 and drr(enemy.key, 118699) < 11 then return end --dr remains--
            if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 17 then return end --dr remains--
            if not los(enemy.key) then return end 
                if not IsTarget(enemy.key) then  --if not TargetingAB("player", enemy) then --off target--
                    local fearCastTime = CastTime(5782)
                    if cc(enemy.key) and ccr(enemy.key) > fearCastTime then return end 
                    if bcc(enemy.key) and bccr(enemy.key) > 2 then return end
                    if GetDebuffRemaining(118699, enemy.key) < fearCastTime or not HasDebuff(118699, enemy) then        
                        if cc(fHealer.key) and ccr(fHealer.key) > 2 or bcc(fHealer.key) and bccr(fHealer.key) > 2 then --our heal in cc--
                            if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                                return
                            end
                        end
                    end
                end
            end
        end 
    end 
end)

fearNoFakeCast:Callback("peel", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end --we fakecast--
    if Used("player", 6789, 2) then return end --coil used--
    if Builder:GetConfig("autofear") == "yes" then
        if not fHealer then return end 
        if not BuffFrom("target", noPanic) and Health("target") < 30 then return end 
        if CheckWasCasting() then return end 
        if Used(spell.id, 1) then return end
        -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
        if InArena() then
            for _, enemy in pairs(enemies) do
            if not IsPlayer(enemy.key) then return end 
            if IsHealer(enemy.key) then return end -- not on heal --
            if HasDebuff(118699, enemy.key) then return end --current fear is running on enemy casted by me--
            if eHealer and HasDebuff(118699, eHealer.key, "player") then return end --current fear is running on enemy casted by me--
            if cc(enemy.key) and ccr(enemy.key) > 3 then return end --running cc on him--
            if BuffFrom(enemy.key, nofearthings) then return end 
            if BuffFrom(enemy.key, immuneBuffs) then return end 
            if dr(enemy.key, 118699) < 1 and drr(enemy.key, 118699) < 11 then return end --dr remains--
            if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 17 then return end --dr remains--
            if not los(enemy.key) then return end 
                if not IsTarget(enemy.key) then  --if not TargetingAB("player", enemy) then --off target--
                    local fearCastTime = CastTime(5782)
                    if cc(enemy.key) and ccr(enemy.key) > fearCastTime then return end 
                    if bcc(enemy.key) and bccr(enemy.key) > 2 then return end
                    if GetDebuffRemaining(118699, enemy.key) < fearCastTime or not HasDebuff(118699, enemy) then        
                        if cc(fHealer.key) and ccr(fHealer.key) > 2 or bcc(fHealer.key) and bccr(fHealer.key) > 2 then --our heal in cc--
                            if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                                return
                            end
                        end
                    end
                end
            end
        end 
    end 
end)

fear:Callback("peelLOWHP", function(spell)
    if Builder:GetConfig("enablefakecast") == "no" then return end --we fakecast--
    if GuardActive(0.1) then return end
    if Used("player", 6789, 2) then return end --coil used--
    if Builder:GetConfig("autofear") == "yes" then
        if not BuffFrom("target", noPanic) and Health("target") < 30 then return end 
        if CheckWasCasting() then return end 
        if Used(spell.id, 1) then return end
        -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
        if InArena() then
            for _, enemy in pairs(enemies) do
            if not IsPlayer(enemy.key) then return end 
            if IsHealer(enemy.key) then return end -- not on heal --
            if HasDebuff(118699, enemy.key) then return end --already feard--
            if eHealer and HasDebuff(118699, eHealer.key, "player") then return end --current fear is running on enemy casted by me--
            if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
            if cc(enemy.key) and ccr(enemy.key) > 3 then return end --running cc on him--
            if BuffFrom(enemy.key, nofearthings) then return end 
            if BuffFrom(enemy.key, immuneBuffs) then return end 
            if dr(enemy.key, 118699) < 1 and drr(enemy.key, 118699) < 11 then return end --dr remains--
            if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 17 then return end --dr remains--
            if not los(enemy.key) then return end 
                for guid, friend in pairs(friends) do 
                    local fearCastTime = CastTime(5782)
                    if cc(enemy.key) and ccr(enemy.key) > fearCastTime then return end 
                    if bcc(enemy.key) and bccr(enemy.key) > 2 then return end
                    if Health(friend.key) < 50 and not BuffFrom(friend.key, noPanic) then --low hp--
                        if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                            return
                        end
                    end
                end
            end
        end 
    end 
end)

fearNoFakeCast:Callback("peelLOWHP", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end --we dont fakecast--
    if Used("player", 6789, 2) then return end --coil used--
    if Builder:GetConfig("autofear") == "yes" then
        if not BuffFrom("target", noPanic) and Health("target") < 30 then return end 
        if CheckWasCasting() then return end 
        if Used(spell.id, 1) then return end
        -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
        if InArena() then
            for _, enemy in pairs(enemies) do
            if not IsPlayer(enemy.key) then return end 
            if IsHealer(enemy.key) then return end -- not on heal --
            if HasDebuff(118699, enemy.key) then return end --already feard--
            if eHealer and HasDebuff(118699, eHealer.key, "player") then return end --current fear is running on enemy casted by me--
            if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
            if cc(enemy.key) and ccr(enemy.key) > 3 then return end --running cc on him--
            if BuffFrom(enemy.key, nofearthings) then return end 
            if BuffFrom(enemy.key, immuneBuffs) then return end 
            if dr(enemy.key, 118699) < 1 and drr(enemy.key, 118699) < 11 then return end --dr remains--
            if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 17 then return end --dr remains--
            if not los(enemy.key) then return end 
                for guid, friend in pairs(friends) do 
                    local fearCastTime = CastTime(5782)
                    if cc(enemy.key) and ccr(enemy.key) > fearCastTime then return end 
                    if bcc(enemy.key) and bccr(enemy.key) > 2 then return end
                    if Health(friend.key) < 50 and not BuffFrom(friend.key, noPanic) then --low hp--
                        if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                            return
                        end
                    end
                end
            end
        end 
    end 
end)

fear:Callback("rogue", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end --we fakecast--
    if GuardActive(0.1) then return end
    if Used("player", 6789, 2) then return end --coil used--
    if Builder:GetConfig("autofear") == "yes" then
        if not BuffFrom("target", noPanic) and Health("target") < 30 then return end 
        if CheckWasCasting() then return end 
        if Used(spell.id, 1) then return end
        -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
        if InPvp() then
            for _, enemy in pairs(enemies) do
                if IsClass(enemy.key, 4) then    --rogue only--
                    if Used(enemy.key, 360194, 7) --deathmark 
                    or Used(enemy.key, 121471, 7)  -- shadowblades 
                    or Used(enemy.key, 185313, 6) then  -- shadowdance 
                        if not IsPlayer(enemy.key) then return end 
                        if HasDebuff(118699, enemy.key) then return end --already feard--
                        if eHealer and HasDebuff(118699, eHealer.key, "player") then return end --current fear is running on enemy casted by me--
                        if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
                        if cc(enemy.key) and ccr(enemy.key) > 3 then return end --running cc on him--
                        if BuffFrom(enemy.key, nofearthings) then return end 
                        if BuffFrom(enemy.key, immuneBuffs) then return end 
                        if dr(enemy.key, 118699) < 1 and drr(enemy.key, 118699) < 11 then return end --dr remains--
                        if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 17 then return end --dr remains--
                        if not los(enemy.key) then return end 
                        local fearCastTime = CastTime(5782)
                        if cc(enemy.key) and ccr(enemy.key) > fearCastTime then return end 
                        if bcc(enemy.key) and bccr(enemy.key) > 3 then return end
                        if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                            return
                        end
                    end 
                end 
            end 
        end 
    end 
end)

fearNoFakeCast:Callback("rogue", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end --we dont fakecast--
    if Used("player", 6789, 2) then return end --coil used--
    if Builder:GetConfig("autofear") == "yes" then
        if not BuffFrom("target", noPanic) and Health("target") < 30 then return end 
        if CheckWasCasting() then return end 
        if Used(spell.id, 1) then return end
        -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
        if InPvp() then
            for _, enemy in pairs(enemies) do
                if IsClass(enemy.key, 4) then    --rogue only--
                    if Used(enemy.key, 360194, 7) --deathmark 
                    or Used(enemy.key, 121471, 7)  -- shadowblades 
                    or Used(enemy.key, 185313, 6) then  -- shadowdance 
                        if not IsPlayer(enemy.key) then return end 
                        if HasDebuff(118699, enemy.key) then return end --already feard--
                        if eHealer and HasDebuff(118699, eHealer.key, "player") then return end --current fear is running on enemy casted by me--
                        if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
                        if cc(enemy.key) and ccr(enemy.key) > 3 then return end --running cc on him--
                        if BuffFrom(enemy.key, nofearthings) then return end 
                        if BuffFrom(enemy.key, immuneBuffs) then return end 
                        if dr(enemy.key, 118699) < 1 and drr(enemy.key, 118699) < 11 then return end --dr remains--
                        if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 17 then return end --dr remains--
                        if not los(enemy.key) then return end 
                        local fearCastTime = CastTime(5782)
                        if cc(enemy.key) and ccr(enemy.key) > fearCastTime then return end 
                        if bcc(enemy.key) and bccr(enemy.key) > 3 then return end
                        if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel Rogue", 100, 200) then 
                            return
                        end
                    end 
                end 
            end 
        end 
    end 
end)

fear:Callback("peelbinds", function(spell)
    if Builder:GetConfig("enablefakecast") == "no" then return end --we fakecast--
    if GuardActive(0.1) then return end
    if Used("player", 6789, 1) then return end --coil used--
    if Used(spell.id, 1) then return end
    if InPvp() then
        for _, enemy in pairs(enemies) do
        if not IsPlayer(enemy.key) then return end 
        if IsHealer(enemy.key) then return end -- not on heal --
        if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
        if BuffFrom(enemy.key, nofearthingsNoShroud) then return end 
        if dr(enemy.key, 118699) < 0.25 then return end 
        if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 5 then return end --dr remains--
        if not los(enemy.key) then return end 
            if not IsTarget(enemy.key) then  --if not TargetingAB("player", enemy) then --off target--
                if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                    return
                end
            end
        end
    end 
end)

fearNoFakeCast:Callback("peelbinds", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end --we dont fakecast--
    if Used("player", 6789, 1) then return end --coil used--
    if Used(spell.id, 1) then return end
    if InPvp() then
        for _, enemy in pairs(enemies) do
        if not IsPlayer(enemy.key) then return end 
        if IsHealer(enemy.key) then return end -- not on heal --
        if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
        if BuffFrom(enemy.key, nofearthingsNoShroud) then return end 
        if dr(enemy.key, 118699) < 0.25 then return end 
        if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 5 then return end --dr remains--
        if not los(enemy.key) then return end 
            if not IsTarget(enemy.key) then  --if not TargetingAB("player", enemy) then --off target--
                if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                    return
                end
            end
        end
    end 
end)

fear:Callback("peelbindsTarget", function(spell)
    if Builder:GetConfig("enablefakecast") == "no" then return end --we fakecast--
    if GuardActive(0.1) then return end
    if Used(spell.id, 1) then return end
    if InPvp() then
        for _, enemy in pairs(enemies) do
        if not IsPlayer(enemy.key) then return end 
        if IsHealer(enemy.key) then return end -- not on heal --
        if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
        if BuffFrom(enemy.key, nofearthingsNoShroud) then return end 
        if dr(enemy.key, 118699) < 0.25 then return end 
        if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 5 then return end --dr remains--
        if not los(enemy.key) then return end 
           -- if not IsTarget(enemy.key) then  --if not TargetingAB("player", enemy) then --off target--
                if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                    return
                end
           -- end
        end
    end 
end)

fearNoFakeCast:Callback("peelbindsTarget", function(spell)
    if Builder:GetConfig("enablefakecast") == "yes" then return end --we dont fakecast--
    if Used(spell.id, 1) then return end
    if InPvp() then
        for _, enemy in pairs(enemies) do
        if not IsPlayer(enemy.key) then return end 
        if IsHealer(enemy.key) then return end -- not on heal --
        if HasDebuff(118699, enemy.key, "player") then return end --current fear is running on enemy casted by me--
        if BuffFrom(enemy.key, nofearthingsNoShroud) then return end 
        if dr(enemy.key, 118699) < 0.25 then return end 
        if dr(enemy.key, 118699) < 0.5 and drr(enemy.key, 118699) < 5 then return end --dr remains--
        if not los(enemy.key) then return end 
           -- if not IsTarget(enemy.key) then  --if not TargetingAB("player", enemy) then --off target--
                if spell:Cast(enemy.key) and Alert(spell.id, "Fear Peel", 100, 200) then 
                    return
                end
           -- end
        end
    end 
end)

local reFearstuff = {
    -- 118, -- sheep
    -- 51514, --hex
    -- 82691, --ring of frost
    -- 3355, --freezing trap
    -- 20066, --rep
    -- 118699, --fear 
    -- 8122, --priest fear
    -- 33786, --cyclone
    [118] = true,  -- sheep
    [51514] = true,
    [82691] = true,
    [3355] = true,
    [20066] = true,
    [118699] = true,
    [8122] = true,
    [33786] = true,
}

---we only no fake cast here, we dont want to fakecast on refear...--
fearNoFakeCast:Callback("healer-refear", function(spell)
   -- if GuardActive(0.1) then return end
    if Builder:GetConfig("autofear") == "yes" then
        if not BuffFrom("target", noPanic) and Health("target") < 20 then return end 
        --if CheckWasCasting() then return end 
        if Used(spell.id, 0.5) then return end
        if not eHealer then return end
        -- könnten sonst was einbauen, dass wir auf aktuellen fear checken wenn er > fearcasttime ist und dann StopSpellCast()
        if InArena() then
            if HasDebuff(81261, eHealer.key) then return end --he is root-beamed-
            if BuffFrom(eHealer.key, nofearthings) then return end 
            if HasDebuff(118699, eHealer.key) and GetDebuffRemaining(118699, eHealer.key) > 3 then return end  --already feard--
            if not los(eHealer.key) then return end -- not LoS ---
            if dr(eHealer.key, 118699) < 0.25 then return end 
            if dr(eHealer.key, 118699) < 0.25 and drr(eHealer.key, 118699) < 12 then return end --dr remains--
            if IsTarget(eHealer.key) then return end --we go on him, so we don't fear--
            local fearCastTime = CastTime(5782)  
            if not BuffFrom(eHealer.key, reFearstuff) then return end    
            if cc(eHealer.key) and ccr(eHealer.key) < fearCastTime
            or bcc(eHealer.key) and bccr(eHealer.key) < fearCastTime then
                --if GetDebuffRemaining(118699, eHealer.key) < fearCastTime or not HasDebuff(118699, eHealer.key) then
                    if spell:Cast(eHealer.key) and Alert(spell.id, "Re Healer", 100, 200) then 
                        return
                    end
                --end
            end 
        end 
    end 
end)

coil:Callback("peel", function(spell)
    if Used("player", 5782, 1) then return end --fear used--
    if Builder:GetConfig("autocoil") == "yes" then
        if InPvp() then
            for _, enemy in pairs(enemies) do
            if not IsPlayer(enemy.key) then return end 
            if IsHealer(enemy.key) then return end -- not on heal --
            if HasDebuff(118699, enemy.key) then return end --already feard--
            if cc(enemy.key) then return end --running cc on him--
            if bcc(enemy.key) then return end --running bcc on him--
            if BuffFrom(enemy.key, nofearthings) then return end 
            if dr(enemy.key, 6789) < 1 then return end 
            if not los(enemy.key) then return end 
                for guid, friend in pairs(friends) do 
                    if (fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2) 
                    or (fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2) 
                    or (Health(friend.key) < 50 and not BuffFrom(friend.key, noPanic)) --our heal in cc--
                    or Used(enemy.key, 360194, 3) --assa burst--
                    or Used(enemy.key, 121471, 4) then --shadowblades
                        if spell:Cast(enemy.key) and Alert(spell.id, "Coil Peel", 100, 200) then 
                            return
                        end
                    end
                end 
            end
        end 
    end 
end)

coil:Callback("kill", function(spell)
    if Builder:GetConfig("autocoil") == "yes" then
        if InPvp() then
            if not IsPlayer("target") then return end 
            if cc("target") then return end --running cc on him--
            if bcc("target") then return end --running bcc on him--
            if BuffFrom("target", nofearthings) then return end 
            if dr("target", 6789) < 1 then return end 
            if not los("target") then return end 
            if BuffFrom("target", immuneBuffs) then return end 
            if Health("target") < 30 
            or Health("player") < 20 and not BuffFrom("player", noPanic) then --and not AbsorbR("target") > 400000 then  --above 15% absorb--
                if spell:Cast("target") and Alert(spell.id, "Coil Kill", 100, 200) then 
                    return
                end
            end
        end 
    end 
end)


--- we kill target, so we coil healer ---
-- coil:Callback("killCCHealer", function(spell)
--     if Builder:GetConfig("autocoil") == "yes" then
--         if InPvp() then
--             if not IsPlayer("target") then return end 
--             if cc("target") then return end --running cc on him--
--             if bcc("target") then return end --running bcc on him--
--             if BuffFrom("target", nofearthings) then return end 
--             if dr("target", 6789) < 1 then return end 
--             if not los("target") then return end 
--             if BuffFrom("target", immuneBuffs) then return end 
--             if Health("target") < 30 then 
--                 if spell:Cast("target") and Alert(spell.id, "Coil Kill", 100, 200) then 
--                     return
--                 end
--             end
--         end 
--     end 
-- end)

shadowfury:Callback("peel", function(spell)
    if Used("player", 5782, 1) then return end --fear used--
    if Used("player", 6789, 2) then return end --coil used--
    if not fHealer then return end 
    if Builder:GetConfig("autoshadowfury") == "yes" then
        if InPvp() then
            for _, enemy in pairs(enemies) do
            if not IsPlayer(enemy.key) then return end 
            if IsHealer(enemy.key) then return end -- not on heal --
            if HasDebuff(118699, enemy.key) then return end --already feard--
            if Used("player", 6789, 2) then return end  --coiled--
            if cc(enemy.key) then return end --running cc on him--
            if bcc(enemy.key) then return end --running bcc on him--
            if BuffFrom(enemy.key, nofearthings) then return end 
            if dr(enemy.key, 30283) < 1 then return end 
            if not los(enemy.key) then return end 
                if cc(fHealer.key) and ccr(fHealer.key) > 2 or bcc(fHealer.key) and bccr(fHealer.key) > 2 then --our heal in cc--
                    if spell:Cast(enemy.key) and Alert(spell.id, "Shadowfury Peel", 100, 200) then 
                        return
                    end
                end
            end
        end 
    end 
end) 
-------------------------------------------  Kick -------------------------------------------

-- local kickList = { 5782, 33786, 116858, 2637, 375901, 211015, 210873, 277784, 277778, 269352, 211004, 51514, 28272, 118, 277792, 161354, 277787, 
-- 161355, 161353, 120140, 61305, 61721, 61780, 28271, 82691, 391622, 20066, 605, 113724, 198898, 186723, 32375, 982, 320137, 254418, 8936, 82326, 
-- 209525, 289666, 2061, 283006, 19750, 77472, 199786, 204437, 227344, 30283, 115175, 191837, 124682, 360806, 382614, 382731, 382266, 8004, 355936, 367226, 2060, 64843, 263165, 228260, 
-- 205021, 404977, 421453, 342938, 316099, 200652, 51505, 1064, 48181, 120644, 410126 }

local kickList = {
    [5782] = true,
    [33786] = true,
    [116858] = true,
    [2637] = true,
    [375901] = true,
    [211015] = true,
    [210873] = true,
    [277784] = true,
    [277778] = true,
    [269352] = true,
    [211004] = true,
    [51514] = true,
    [28272] = true,
    [28272] = true,
    [118] = true,
    [277792] = true,
    [161354] = true,
    [277787] = true,
    [161355] = true,
    [161353] = true,
    [120140] = true,
    [61305] = true,
    [61721] = true,
    [61780] = true,
    [28271] = true,
    [82691] = true,
    [391622] = true,
    [20066] = true,
    [605] = true,
    [113724] = true,
    [198898] = true,
    [186723] = true,
    [32375] = true,
    [982] = true,
    [20137] = true,
    [254418] = true,
    [8936] = true,
    [82326] = true,
    [209525] = true,
    [289666] = true,
    [2061] = true,
    [283006] = true,
    [19750] = true,
    [77472] = true,
    [199786] = true,
    [204437] = true,
    [227344] = true,
    [30283] = true,
    [115175] = true,
    [191837] = true,
    [124682] = true,
    [360806] = true,
    [382614] = true,
    [382731] = true,
    [382266] = true,
    [8004] = true,
    [355936] = true,
    [367226] = true,
    [2060] = true,
    [64843] = true,
    [263165] = true,
    [228260] = true,
    [205021] = true,
    [404977] = true,
    [421453] = true,
    [342938] = true,
    [316099] = true,
    [200652] = true,
    [51505] = true,
    [1064] = true,
    [48181] = true,
    [120644] = true,
    [410126] = true,
}

--soothing mist, penance, essence font, Lasso, Convoke, Dream Breath, Spiritbloom, Sleep Walk, Gotteshymne, Void Torrent, Desintegrate, ray of frost, time skip--
-- local kickChannels = { 115175, 47540, 191837, 305483, 391528, 355936, 367226, 360806, 64843, 263165, 205021, 404977 } 

local kickChannels = {
    [115175] = true, --soothing mist
    [47540] = true, --penance
    [191837] = true, --essence font
    [305483] = true, --lasso
    [391528] = true, --convoke
    [355936] = true, --dreambreath
    [367226] = true, --spiritbloom
    [360806] = true, --sleep walk
    [64843] = true, --gotteshymne
    [263165] = true, --void torrent
    [205021] = true, --desintegrate
    [404977] = true, -- ray of frost or time skip
}

local noKickthings = { 
    [377362] = true, --precog
    [215769] = true, --angel
    [345228] = true, --lolstorm--
    [227847] = true, --lolstorm2--
    [408558] = true, --fade immunity--
    [378464] = true, --nullyfying shroud
    [1022] = true, --BoP
    --  [] = true,
    -- 377362, --precog
    -- 209584, --zen tea
    -- 378078, --shaman spirit walker immunity
    -- 363916, --prevoker immunity--
    -- 104773, --unending resolve
    -- 317929, --hpal aura mastery immunity
    -- 215769, --angel
    ----RAUSGENOMMEN WEIL WIR JA STUNNEN!!-----
    --[209584] = true, --zen tea
    --[378078] = true, --shaman spirit walker immunity
    --[363916] = true, --prevoker immunity--
    --[104773] = true, --unending resolve
    --[317929] = true, --hpal aura mastery immunity
}

axetoss:Callback("casts", function(spell)  
    if Used("player", 5782, 1) then return end --fear used--
    if SpellCd(119914) > 1 then return end 
    if Builder:GetConfig("autokick") == "yes" then
        if not InPvp() then return end
        if oid("pet") == 17252 and Rooted("pet") then return end --can't kick--
        for _, enemy in pairs(enemies) do
        if StunDr(enemy) < 1 and StunDrr(enemy) < 10 then return end --full stun rdy soon--
        if StunDr(enemy) < 0.5 then return end    
            if IsCastingT(enemy.key, kickList) then
                if BuffFrom(enemy.key, noKickthings) then return end 
                if HasDebuff(410216, enemy.key) then return end --searing glare on him--
                if los("pet", enemy.key) then  --pet is LoS to enemy--
                    if CanInterruptCast(enemy.key) then
                        --local percent = CastingPercent(enemy.key)
                        --if IsCasting(enemy.key) and percent > 70 then 
                        if interruptAt(enemy.key, 60) then
                            if spell:Cast(enemy.key) and Alert(spell.id, "Interrupt Cast", 100, 200) then 
                                return 
                            end 
                        end
                    end 
                end 
            end 
        end
    end 
end)

axetoss:Callback("channel", function(spell)  
    if Used("player", 5782, 1) then return end --fear used--
    if SpellCd(119914) > 1 then return end 
    if Builder:GetConfig("autokick") == "yes" then
        if not InPvp() then return end
        if oid("pet") == 17252 and Rooted("pet") then return end --can't kick--
        for _, enemy in pairs(enemies) do
        if StunDr(enemy) < 1 and StunDrr(enemy) < 10 then return end --full stun rdy soon--
        if StunDr(enemy) < 0.5 then return end       
            if IsCastingT(enemy.key, kickChannels) then
                if BuffFrom(enemy.key, noKickthings) then return end 
                if HasDebuff(410216, enemy.key) then return end --searing glare on him--
                if los("pet", enemy.key) then --pet is LoS to enemy--
                    if CanInterruptChannel(enemy.key) then
                        --local percent = ChannelingPercent(enemy.key)
                       -- if IsCastChan(enemy.key) and percent < 99 then 
                        if interruptAt(enemy.key, 99) then
                            if spell:Cast(enemy.key) and Alert(spell.id, "Interrupt Channel", 100, 200) then 
                                return 
                            end 
                        end
                    end 
                end 
            end 
        end
    end 
end)

axetoss:Callback("castsbinds", function(spell)  
    if SpellCd(119914) > 0.1 then return end 
    if oid("pet") == 17252 and Rooted("pet") then return end --can't kick--
    if HasDebuff(410216, "target") then return end --searing glare on him--
    if los("pet", "target") then  --pet is LoS to enemy--
    if StunDr(enemy) <= 0.5 and StunDrr(enemy) < 10 then return end --full stun rdy soon--
    if StunDr("target") < 0.25 then return end   
    if BuffFrom("target", noKickthings) then return end 
        if CanInterruptCast("target") then
            local percent = CastingPercent("target")
            if IsCasting("target") and percent > 2 then 
                if spell:Cast("target") and Alert(spell.id, "Interrupt Target", 100, 200) then 
                    return 
                end 
            end
        end 
    end 
end)

axetoss:Callback("channelbinds", function(spell)  
    if SpellCd(119914) > 0.1 then return end 
    if oid("pet") == 17252 and Rooted("pet") then return end --can't kick--
    if HasDebuff(410216, "target") then return end --searing glare on him--
    if los("pet", "target") then  --pet is LoS to enemy--
    if StunDr("target") < 0.25 then return end   
    if BuffFrom("target", noKickthings) then return end 
        if CanInterruptChannel("target") then
            local percent = ChannelingPercent("target")
            if IsCastChan("target") and percent < 99 then 
                if spell:Cast("target") and Alert(spell.id, "Interrupt Target", 100, 200) then 
                    return 
                end 
            end
        end 
    end 
end)

axetoss:Callback("stunbinds", function(spell)
    if SpellCd(119914) > 0.1 then return end 
    if Stunned("target") then return end --already in stun--
    --if not IsPlayer("target") then return end 
    if BuffFrom("target", noKickthings) then return end 
    if HasBuff(345228, "target") then return end  --lolstorm--
    if HasBuff(227847 , "target") then return end  --lolstor2m--
    if HasBuff(408558, "target") then return end  --fade immunity--
    if HasBuff(377362, "target") then return end  --precog--
    if not los("target") then return end -- not LoS ---
    if StunDr("target") <= 0.5 and StunDrr("target") < 7 then return end --full stun rdy soon--
    --if dr("target", 1833) >= 0.25 then 
    if StunDr("target") >= 0.25 then
        if spell:Cast("target") and Alert(spell.id, "Stun Target", 100, 200) then 
            return
        end
    end
end)

axetoss:Callback("TargetenemyHealerinCC", function(spell)
    if SpellCd(111898) < 0.5 and Builder:GetConfig("autostun") == "yes" then return end 
    if SpellCd(111898) > 110 and Builder:GetConfig("autostun") == "yes" then return end --to prevent double usage of axetoss--
    if SpellCd(119914) > 0.1 then return end 
    if Used("player", 111898, 5) then return end 
    if not eHealer then return end
    if Builder:GetConfig("autostun") == "yes" then
        if cc(eHealer.key) and ccr(eHealer.key) >= 3 then 
            if Stunned("target") then return end --already in stun--
            if BuffFrom("target", noKickthings) then return end 
            if not IsPlayer("target") then return end 
            if HasBuff(345228, "target") then return end  --lolstorm--
            if HasBuff(227847 , "target") then return end  --lolstor2m--
            if HasBuff(408558, "target") then return end  --fade immunity--
            if HasBuff(377362, "target") then return end  --precog--
            if not los("target") then return end -- not LoS ---
            if dr("target", 1833) >= 1 then 
               if spell:Cast("target") and Alert(spell.id, "Stun Target", 100, 200) then 
                    return
                end
            end
        end
    end 
end)

axetoss:Callback("TargetnoEnemyHealer", function(spell)
   if SpellCd(111898) < 0.5 and Builder:GetConfig("autostun") == "yes" then return end 
   if SpellCd(111898) > 110 and Builder:GetConfig("autostun") == "yes" then return end --to prevent double usage of axetoss--
   if SpellCd(119914) > 0.1 then return end 
   if Used("player", 111898, 5) then return end 
   if Builder:GetConfig("autostun") == "yes" then
       if not eHealer then 
            if Bursting("player") or Used("player", 267171, 5) or Used("player", 265187, 5) or Used("player", 267171, 5) or Used("player", 264119, 3) then 
                if Stunned("target") then return end --already in stun--
                if BuffFrom("target", noKickthings) then return end 
                --if not IsPlayer("target") then return end 
                if HasBuff(345228, "target") then return end  --lolstorm--
                if HasBuff(227847 , "target") then return end  --lolstor2m--
                if HasBuff(408558, "target") then return end  --fade immunity--
                if HasBuff(377362, "target") then return end  --precog--
                if not los("target") then return end -- not LoS ---
                if dr("target", 1833) >= 1 then 
                    if spell:Cast("target") and Alert(spell.id, "Stun Target", 100, 200) then 
                        return
                    end
                end
            end
       end 
   end 
end)

axetoss:Callback("TargetOurHealerinCC", function(spell)
    if Used("player", 5782, 1) then return end --fear used--
    if SpellCd(111898) < 0.5 and Builder:GetConfig("autostun") == "yes" then return end 
    if SpellCd(111898) > 110 and Builder:GetConfig("autostun") == "yes" then return end --to prevent double usage of axetoss--
    if SpellCd(119914) > 0.1 then return end 
    if Used("player", 111898, 5) then return end 
    if Used("player", 111898, 1) then return end  --coil used--
    if not fHealer then return end
    if Builder:GetConfig("autostun") == "yes" then
        for guid, friend in pairs(friends) do 
            if cc(fHealer.key) and ccr(fHealer.key) >= 3  --our heal in cc--
            or (Health(friend.key) < 50 and not BuffFrom(friend.key, noPanic))  --low hp our party--
            or Used("target", 360194, 3) ---assa burst
            or Used("target", 121471, 4) then --shadowblades 
                if Stunned("target") then return end --already in stun--
                if BuffFrom("target", noKickthings) then return end 
                if cc("target") then return end --running cc on him--
                if bcc("target") then return end --running bcc on him--
                if not IsPlayer("target") then return end 
                if HasBuff(345228, "target") then return end  --lolstorm--
                if HasBuff(227847, "target") then return end  --lolstor2m--
                if HasBuff(408558, "target") then return end  --fade immunity--
                if HasBuff(377362, "target") then return end  --precog--
                if not los("target") then return end -- not LoS ---
                if dr("target", 1833) >= 1 then 
                    if spell:Cast("target") and Alert(spell.id, "Stun Target Peel", 100, 200) then 
                        return
                    end
                end
            end
        end 
    end 
end)

function petAttack()
    --if Builder:GetConfig("autostun") == "yes" and SpellCd(119914) < 0.5 and 
    if UnitExists("target") and Alive("target") and IsEnemy("target") and Distance("target", "player") < 60 then
        PetAttackUnit("target")
    end
end 
        

-------------------------------------------  MISC -------------------------------------------

soulwell:Callback(function(spell)
    if Builder:GetConfig("autosoulwell") == "yes" then
        if Prep() then  
            if spell:Cast() and Alert(spell.id, "Prep Soulwell", 100, 200) then 
                return 
            end
        end  
    end 
end) 

curseofweakness:Callback("reflect", function(spell)
    if Builder:GetConfig("autocurses") == "yes" then
        if InPvp() then
            for _, enemy in pairs(enemies) do
            --if not IsPlayer(enemy.key) then return end 
            --if not Class(enemy.key) == "WARRIOR" then return end --wenn es nicht geht liegt es daran--
            if cc(enemy.key) then return end --running cc on him--
            if bcc(enemy.key) then return end --running bcc on him--
            if not los(enemy.key) then return end 
                if HasBuff(23920, enemy.key) then --has reflect on
                    if spell:Cast(enemy.key) and Alert(spell.id, "Reflect Bait", 100, 200) then 
                        return
                    end
                end 
            end
        end 
    end 
end)



local slowImmunities = {
    -- 345228, --lolstorm
    -- 1044, --freedom
    [345228] = true, --lolstorm
    [227847] = true, --lolstorm2
    [1044] = true, --freedom
}

curseoftongues:Callback("healer", function(spell)
    if Builder:GetConfig("autocurses") == "yes" then
        if InPvp() then
            --if IsTarget(eHealer.key) and HasDebuff(334275, eHealer.key) then return end --we go on him and have exhaustion on him
            if not eHealer then return end 
            if BuffFrom(eHealer.key, immuneBuffs) then return end 
            if cc(eHealer.key) then return end --running cc on him--
            --if bcc(eHealer.key) then return end --running bcc on him--
            if not los(eHealer.key) then return end 
            if not HasDebuff(1714, eHealer.key) then 
                if spell:Cast(eHealer.key) then --and Alert(spell.id, "!", 100, 200) then
                    if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "tongue healer!", 100, 200) end 
                    return
                end
            end 
        end 
    end 
end)

curseoftongues:Callback("caster", function(spell)
    if Builder:GetConfig("autocurses") == "yes" then
        if InPvp() then
            for _, enemy in pairs(enemies) do
            if IsTarget(enemy.key) and HasDebuff(334275, enemy.key) then return end --we go on him and have exhaustion on him
                if IsCaster(enemy.key) then 
                    if BuffFrom(enemy.key, immuneBuffs) then return end 
                    if cc(enemy.key) then return end --running cc on him--
                    if bcc(enemy.key) then return end --running bcc on him--
                    if not los(enemy.key) then return end 
                    if not HasDebuff(1714, enemy.key) then 
                        if spell:Cast(enemy.key) then --and Alert(spell.id, "!", 100, 200) then
                            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "tongue caster!", 100, 200) end 
                            return
                        end
                    end 
                end 
            end 
        end 
    end 
end)

curseofexhaustion:Callback(function(spell)
    if Builder:GetConfig("autocurses") == "yes" then
        if InArena() then
            for _, enemy in pairs(enemies) do
            if IsClass(enemy.key, 11) then return end --we dont use it on druids--
            if Used(enemy.key, 227847, 4) then return end --bladestorm because its not taking the buffid
            if HasBuff(345228, enemy.key) then return end  --lolstorm--
            if HasBuff(227847, enemy.key) then return end  --lolstorm--
            if BuffFrom(enemy.key, immuneBuffs) then return end 
            if BuffFrom(enemy.key, slowImmunities) then return end 
            if not IsPlayer(enemy.key) then return end 
            --if Rooted(enemy.key) then return end 
            if cc(enemy.key) then return end --running cc on him--
            if bcc(enemy.key) then return end --running bcc on him--
            if SlowImmune(enemy.key) then return end 
            if not los(enemy.key) then return end 
                if IsMelee(enemy.key) then 
                    if Speed(enemy.key) >= 7 and Distance(enemy.key) > 10 then 
                        if not HasDebuff(334275, enemy.key) then 
                            if spell:Cast(enemy.key) then --and Alert(spell.id, "!", 100, 200) then
                                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "slow melee!", 100, 200) end 
                                return
                            end
                        end 
                    end 
                end 
            end 
        end 
    end 
end)

curseofexhaustion:Callback("target2s", function(spell)
    if Builder:GetConfig("autocurses") == "yes" then
        if InArena() then
            if eHealer then return end --we only use it in 2s--
            for _, enemy in pairs(enemies) do
            if IsClass("target", 11) then return end --we dont use it on druids--
            if Used("target", 227847, 4) then return end --bladestorm because its not taking the buffid
            if HasBuff(345228, "target") then return end  --lolstorm--
            if HasBuff(227847, "target") then return end  --lolstorm--
            if BuffFrom("target", immuneBuffs) then return end 
            if BuffFrom("target", slowImmunities) then return end 
            if not IsPlayer("target") then return end 
            --if Rooted(enemy.key) then return end 
            if cc("target") then return end --running cc on him--
            --if bcc(enemy.key) then return end --running bcc on him--
            if SlowImmune("target") then return end 
            if not los("target") then return end 
                --if IsMelee(enemy.key) then 
                    if Speed("target") >= 7 then  --not slowed--
                        if not HasDebuff(334275, "target") then 
                            if spell:Cast("target") then --and Alert(spell.id, "!", 100, 200) then
                                if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "slow target!", 100, 200) end 
                                return
                            end
                        end 
                    end 
                --end 
            end 
        end 
    end 
end)

soulburn:Callback(function(spell)
    if SpellCd(111771) > 2 then return end 
    if SoulShards("player") < 1 then return end 
    if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "soulburn!", 100, 200) end 
        return
    end
end) 

function demonicgateway()
    if SoulShards("player") >= 1 and not HasBuff(387626, "player") then return end 
    if rmt("/cast [@cursor] Demonic Gateway") and Alert(spell.id, "Gateway", 100, 200) then 
        return 
    end 
end

demoniccircle:Callback(function(spell)
    if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
        return
    end
end) 

soulburn:Callback("port", function(spell)
    if SpellCd(48020) > 2 then return end 
    if SoulShards("player") < 1 then return end 
    if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
        if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "port!", 100, 200) end 
        return
    end
end) 

demonicteleport:Callback(function(spell)
    if HasBuff(387626, "player") then  --soulburn combo--
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end) 

demonicteleport:Callback("noshards", function(spell)
    if SoulShards("player") < 1 then  --soulburn combo--
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "no shard port!", 100, 200) end 
            return
        end
    end 
end) 

local reflectStuff = { 
    [212295] = true,
    [3920] = true,
}

local immuneBuffFear = { 
    -- 212295, --netherward
    -- 48707, --ams
    -- 47585, --dispersion
    -- 23920, --reflect
    -- 409293, --burrow
    -- 642, --bubble
    -- 204018, --spellwarding
    -- 45438, --iceblock--
    -- 186265, --turtle--
    -- 33786, --cyclone
    -- 353319, --monk revival 
    -- 408558, --priest immunity fade
    -- 8178, --grounding
    -- 421453, --ult penance--
    [212295] = true, --netherward
    [48707] = true, --ams
    [47585] = true,  --dispersion
    [23920] = true, --reflect
    [409293] = true, --burrow
    [642] = true, --bubble
    [204018] = true, --spellwarding
    [45438] = true, --iceblock--
    [186265] = true,  --turtle--
    [33786] = true, --cyclone
    [353319] = true, --monk revival 
    [408558] = true, --priest immunity fade
    [8178] = true,  --grounding
    [421453] = true, --ult penance--
}

local DemonboltCast = {
    [264178] = true
}

local FearCast = {
    [5782] = true
}

local FelguardCast = {
    [30146] = true
}

function StopCastingInImmunities()
    --if not Casting("player") then return end 
    for _, enemy in pairs(enemies) do
        if IsCastingT("player", FearCast) and CastTarget("player", enemy.key) and BuffFrom(enemy.key, immuneBuffFear) then
            StopCast()
            StopCast()
        end 
        if IsCastingT("player", FearCast) and CastTarget("player", enemy.key) and BuffFrom(enemy.key, reflectStuff) then
            StopCast()
            StopCast()
        end 
        if IsCastingT("player", FearCast) and CastTarget("player", enemy.key) and Immune(enemy.key, "fear", true) then --and Distance("player", enemy.key) < 40 then
            StopCast()
            StopCast()
        end 
        if IsCastingT("player", FearCast) and CastTarget("player", enemy.key) and Stunned(enemy.key) and StunRemains(enemy.key) >= 3 then --and Distance("player", enemy.key) < 40 then
            StopCast()
            StopCast()
        end 
        if IsCastingT("player", FearCast) and CastTarget("player", enemy.key) and cc(enemy.key) and ccr(enemy.key) >= 3 then --and Distance("player", enemy.key) < 40 then
            StopCast()
            StopCast()
        end
        if IsCastingT("player", FearCast) and CastTarget("player", enemy.key) and bcc(enemy.key) and bccr(enemy.key) >= 3 and not HasBuff(fear) then --and Distance("player", enemy.key) < 40 then
            StopCast()
            StopCast()
        end
        if IsCastingT("player", DemonboltCast) then --accidentaly cast demon bolt--
            StopCast()
            StopCast()
        end
        if IsCastingT("player", FelguardCast) and UnitExists("pet") and Alive("pet") then
            StopCast()
            StopCast()
        end
    end
end

function keepKitingAlert()
    if Builder:GetConfig("enableAlerts") == "yes" then
        if HasBuff(387633, "player") then 
        Alert(48020, "Keep Kiting", -75, 300)
        end 
    end 
end 

orcracial:Callback(function(spell)
    if not CanCast(33702) then return end 
    if SpellCd(265187) < 1 then return end 
    if Used("player", 265187, 6) then 
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end) 

trollracial:Callback(function(spell)
    if not CanCast(26297) then return end 
    if SpellCd(265187) < 1 then return end 
    if Used("player", 265187, 6) then 
        if spell:Cast() then --and Alert(spell.id, "!", 100, 200) then
            if Builder:GetConfig("enableDebug") == "yes" then Alert(spell.id, "!", 100, 200) end 
            return
        end
    end 
end) 

-------------------------------------------TEST CENTER -------------------------------------------

fear:Callback("test", function(spell)
    if Builder:GetConfig("autofear") == "yes" then
    if not BuffFrom("target", noPanic) and Health("target") < 20 then return end 
    if Used(spell.id, 1) then return end
    if HasDebuff(81261, "focus") then return end --he is root-beamed-
    if BuffFrom("focus", nofearthings) then return end 
    if HasDebuff(118699, "focus") and GetDebuffRemaining(118699, "focus") > 3 then return end  --already feard--
    if not los("focus") then return end -- not LoS ---
    if dr("focus", 118699) < 0.25 then return end 
    if dr("focus", 118699) < 0.5 and drr("focus", 118699) < 10 then return end --dr remains--
    if IsTarget("focus") then return end --we go on him, so we don't fear--
    if cc("focus") and ccr("focus") > fearCastTime then return end 
    if bcc("focus") and bccr("focus") > 2 then return end 
        local fearCastTime = CastTime(5782)
        if GetDebuffRemaining(118699, "focus") < fearCastTime or not HasDebuff(118699, "focus") then
            if spell:Cast("focus") and Alert(spell.id, "Fear Test", 100, 200) then 
                return
            end
        end 
    end 
end)

unendingresolve:Callback("test", function(spell)
    if BuffFrom("player", BigDefonMe) then return end 
    if BuffFrom("player", noPanic) then return end 
    if Used("player", 48020, 2) then return end  --we ported us--
    if Used("player", 108416, 2) then return end  --dark pact used--
    --if AbsorbR("player") > 300000 then return end 
    for _, enemy in pairs(enemies) do
        --if Bursting(enemy) then
            if fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2 
            or fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2 
            or fHealer and Silence(fHealer.key) 
            or not fHealer then 
                --if los(enemy) then and TargetingAB(enemy.key, "player") then
                if los(enemy) and Health("player") < 100 then 
                    if spell:Cast("player") and Alert(spell.id, "Resolve Test", 100, 200) then 
                        return 
                    end 
                end
            end
        --end 
    end
end)

coil:Callback("test", function(spell)
    --if InArena() then
        --if not IsPlayer("target") then return end 
        if cc("target") then return end --running cc on him--
        if bcc("target") then return end --running bcc on him--
        if BuffFrom("target", nofearthings) then return end 
        if dr("target", 6789) < 1 then return end 
        if not los("target") then return end 
        if BuffFrom("target", immuneBuffs) then return end 
        if Health("target") < 99 then 
            if spell:Cast("target") and Alert(spell.id, "Coil Kill Test", 100, 200) then 
                return
            end
        end
    --end 
end)

fellord:Callback("test", function(spell)
    if not HasTalent(spell.id) then return end
    --for _, enemy in pairs(enemies) do
        if Mounted("target") or SlowImmune("target") then return end 
        if IsMelee("target") and Bursting("target") and los("target") then 
        elseif Stunned("target") then 
            if spell:Cast("target") and Alert(spell.id, "Fel Lord Test", 100, 200) then 
                return 
            end  
        end
    --end
end)

curseoftongues:Callback("test", function(spell)
    --if InPvp() then
        --if not eHealer then return end 
        if cc("target") then return end --running cc on him--
        --if bcc("target") then return end --running bcc on him--
        if not los("target") then return end 
        if not HasDebuff(1714, "target") then 
            if spell:Cast("target") and Alert(spell.id, "Tongue Healer", 100, 200) then 
                return
            end
        end 
    --end 
end)

axetoss:Callback("test", function(spell)
    if spell:Cast("target") and Alert(spell.id, "Stun Target Test", 100, 200) then 
        return
    end 
end)

tyrant:Callback("test", function(spell)
   --if Builder:GetConfig("autoburst") == "yes" then
        --for _, minion in pairs(minions) do

           -- if oid("pet") == 135816 then  --charhound--
            --if Alive(minion.key) == "Jhuuvegen" then 
            if Used("player", 455476, 5) 
            or Used("player", 264119, 5) then  --charhond--

                if BuffFrom("target", immuneBuffs) then return end 
                if Distance("target") > 40 then return end 
                --if ccr(eHealer) >= 2 then 
                --elseif not UnitExists(eHealer) then 
                if los("target") then 
                    if spell:Cast() and Alert(spell.id, "!", 100, 200) then
                        return
                    end
                end 
            end 
        --end 
    --end
end)

function TestAlert()
    if Bursting("player") then 
        Alert(48020, "Burst Test", -75, 300)
    end 
end 

soulburn:Callback("test", function(spell)
    if BuffFrom("player", BigDefonMe) then return end 
    if BuffFrom("player", noPanic) then return end 
    if Used("player", 48020, 2) then return end  --we ported us--
    if Used("player", 104773, 4) then return end  --unending resolve used--
    if Used("player", 108416, 4) then return end  --dark pact--
    --if AbsorbR("player") > 400000 then return end 
    if SpellCd(48020) > 0.5 then return end 
    if SoulShards("player") < 1 then return end 
    if Builder:GetConfig("autodefensives") == "yes" then
            if CanCast(48020) then 
                for _, enemy in pairs(enemies) do
                    if Distance("target", "player") < 20 then --Bursting(enemy.key) and 
                        -- if fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2 and TargetingAB(enemy.key, "player") 
                        -- or fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2 and TargetingAB(enemy.key, "player") 
                        -- or fHealer and Silence(fHealer.key) and TargetingAB(enemy.key, "player") 
                        -- or InMelee(enemy.key) and Used(enemy.key, 1719, 8) and TargetingAB(enemy.key, "player") ---Fury Recklessness
                        -- or InMelee(enemy.key) and Used(enemy.key, 227847, 4) and TargetingAB(enemy.key, "player") -- War bladestorm
                        -- or InMelee(enemy.key) and Used(enemy.key, 107574, 12) and TargetingAB(enemy.key, "player") -- War Avatar
                        -- or InMelee(enemy.key) and Used(enemy.key, 443028, 4) and TargetingAB(enemy.key, "player") -- WW celestial-conduit
                        -- or InMelee(enemy.key) and Used(enemy.key, 383269, 8) and TargetingAB(enemy.key, "player") --DK Burst Abo
                        -- or InMelee(enemy.key) and Used(enemy.key, 455395, 8) and TargetingAB(enemy.key, "player") --DK Burst Transformaiton 
                        -- or InMelee(enemy.key) and Used(enemy.key, 207289, 8) and TargetingAB(enemy.key, "player") --DK Burst unholy assault
                        -- or InMelee(enemy.key) and Used(enemy.key, 279302, 8) and TargetingAB(enemy.key, "player") ---Frost DK burst 
                        -- or InMelee(enemy.key) and Used(enemy.key, 360194, 6) and TargetingAB(enemy.key, "player") -- Assa deathmark 
                        -- or InMelee(enemy.key) and Used(enemy.key, 121471, 6) and TargetingAB(enemy.key, "player") -- Sub shadowblades 
                        -- or InMelee(enemy.key) and Used(enemy.key, 185313, 6) and TargetingAB(enemy.key, "player") -- Sub shadowdance 
                        -- or InMelee(enemy.key) and HasBuff(162264, enemy.key) and TargetingAB(enemy.key, "player") --DH Meta
                        -- or InMelee(enemy.key) and HasDebuff(196937, "player", enemy.key) and TargetingAB(enemy.key, "player") -- Outlaw Ghost Strike Debuff
                        -- or Spec(enemy.key) == 70 and Distance(enemy.key) < 12 and Used(enemy.key, 231895, 12) and TargetingAB(enemy.key, "player") -- Ret Wings
                        -- or Spec(enemy.key) == 103 and InMelee(enemy.key) and Used(enemy.key, 102543, 12) and TargetingAB(enemy.key, "player") -- Feral Burst
                        -- or Spec(enemy.key) == 263 and InMelee(enemy.key) and HasBuff(114051, enemy.key) and TargetingAB(enemy.key, "player") then -- Enhance Burst
                     
                                if spell:Cast() and Alert(spell.id, "Auto Port test", 100, 200) then 
                                    return 
                                end 
                        
                        --end
                    end
                end
            end
    end 
end) 


demonicteleport:Callback("test", function(spell)
    if BuffFrom("player", BigDefonMe) then return end 
    if BuffFrom("player", noPanic) then return end 
    if Used("player", 48020, 3) then return end  --we ported us--
    if Used("player", 104773, 4) then return end  --unending resolve used--
    --if AbsorbR("player") > 400000 then return end 
    if Builder:GetConfig("autodefensives") == "yes" then
        if HasBuff(387626, "player") then --soulburn for freedom--
            if CanCast(48020) then 
                for _, enemy in pairs(enemies) do
                    if Distance("target", "player") < 20 then --Bursting(enemy.key) and 
                        -- if fHealer and cc(fHealer.key) and ccr(fHealer.key) > 2 
                        -- or fHealer and bcc(fHealer.key) and bccr(fHealer.key) > 2
                        -- or fHealer and Silence(fHealer.key)
                        -- or InMelee(enemy.key) and Used(enemy.key, 1719, 8) and TargetingAB(enemy.key, "player") ---Fury Recklessness
                        -- or InMelee(enemy.key) and Used(enemy.key, 227847, 4) and TargetingAB(enemy.key, "player") -- War bladestorm
                        -- or InMelee(enemy.key) and Used(enemy.key, 107574, 12) and TargetingAB(enemy.key, "player") -- War Avatar
                        -- or InMelee(enemy.key) and Used(enemy.key, 443028, 4) and TargetingAB(enemy.key, "player") -- WW celestial-conduit
                        -- or InMelee(enemy.key) and Used(enemy.key, 383269, 8) and TargetingAB(enemy.key, "player") --DK Burst Abo
                        -- or InMelee(enemy.key) and Used(enemy.key, 455395, 8) and TargetingAB(enemy.key, "player") --DK Burst Transformaiton 
                        -- or InMelee(enemy.key) and Used(enemy.key, 207289, 8) and TargetingAB(enemy.key, "player") --DK Burst unholy assault
                        -- or InMelee(enemy.key) and Used(enemy.key, 279302, 8) and TargetingAB(enemy.key, "player") ---Frost DK burst 
                        -- or InMelee(enemy.key) and Used(enemy.key, 360194, 6) and TargetingAB(enemy.key, "player") -- Assa deathmark 
                        -- or InMelee(enemy.key) and Used(enemy.key, 121471, 6) and TargetingAB(enemy.key, "player") -- Sub shadowblades 
                        -- or InMelee(enemy.key) and Used(enemy.key, 185313, 6) and TargetingAB(enemy.key, "player") -- Sub shadowdance 
                        -- or InMelee(enemy.key) and HasBuff(162264, enemy.key) and TargetingAB(enemy.key, "player") --DH Meta
                        -- or InMelee(enemy.key) and HasDebuff(196937, "player", enemy.key) and TargetingAB(enemy.key, "player") -- Outlaw Ghost Strike Debuff
                        -- or Spec(enemy.key) == 70 and Distance(enemy.key) < 12 and Used(enemy.key, 231895, 12) and TargetingAB(enemy.key, "player") -- Ret Wings
                        -- or Spec(enemy.key) == 103 and InMelee(enemy.key) and Used(enemy.key, 102543, 12) and TargetingAB(enemy.key, "player") -- Feral Burst
                        -- or Spec(enemy.key) == 263 and InMelee(enemy.key) and HasBuff(114051, enemy.key) and TargetingAB(enemy.key, "player") then -- Enhance Burst
                            --if TargetingAB(enemy.key, "player") then
                                if spell:Cast() and Alert(spell.id, "Auto Port", 100, 200) then 
                                    return 
                                end 
                            --end
                        --end
                    end 
                end
            end 
        end 
    end 
end)


function testCharhound()
    for _,minion in pairs(fminions) do
        local charhoundID = oid(minion)
        if charhoundID == 226269 then
            Alert(455476, "char hound out", 100, 200)
        end 
    end 
end

----------------------------------------------------------------------------------------------
-------------------------------------------  INIT  -------------------------------------------
----------------------------------------------------------------------------------------------

function inCombat()

    if not Alive("player") then return end --we are dead--
    local shiftHeldDown = IsShiftKeyDown()
    if shiftHeldDown and Builder:GetConfig("leftShiftPause") == "yes" then return end
    if not erButton.isEnabled then return end
    draw:Enable()
    if Mounted() then return end 

    darkpact("healerCC")
    unendingresolve("healerCC")
    axetoss("TargetenemyHealerinCC")
    axetoss("TargetnoEnemyHealer")
    axetoss("TargetOurHealerinCC")
    axetoss("casts")
    axetoss("channel")

    if Locked() then return end --we are in CC--


    local HSCount = GetItemCount(224464)
    if HSCount >= 1 and Health("player") < 50 then
        soulburn("HSverylow")
        HealthStoneUsageVerylow()

        soulburn("HS")
        HealthStoneUsage()
    end 

    -- soulburn("test")
    -- demonicteleport("test")
    --fear("test")
    --coil("test")
    --fellord("test")
    --curseoftongues("test")
    --Drawings()
   -- unendingresolve("test")
   --tyrant("test")
    -- TestAlert()

    keepKitingAlert()
    orcracial()
    trollracial()

    StopCastingInImmunities()
    soulburn("autoport")
    demonicteleport("autoport")
    netherward()
    netherward("Bursting")
    soulrip("Bursting")
    shadowmeld("cc")

    feldomination()
    summonfelguard("feldomination")

    if IsComboPressed("kickbutton") then
        axetoss("stunbinds")
        axetoss("castsbinds")
        axetoss("channelbinds")
    end 

    if IsComboPressed("fearPeel") then
        fear("peelbinds")
        fearNoFakeCast("peelbinds")
        fear("peelbindsTarget")
        fearNoFakeCast("peelbindsTarget")
    end 

    if IsComboPressed("fearHealer") then
        fear("healerbinds")
        fearNoFakeCast("healerbinds")
    end 

    if IsComboPressed("gatebutton") then
        soulburn()
        demonicgateway()
        --demoniccircle()
    end 

    if IsComboPressed("portbutton") then
        soulburn("port")
        demonicteleport()
        demonicteleport("noshards")
    end 

    if IsComboPressed("burstbutton") then
        fellord("binds")
        tyrant("binds") 
        tyrantNoFakeCast("binds")
        demonicstrength("binds")
        grimfelguard("binds")
    end 

    if HasDebuff(410216, "player") then return end --searing glare--
    if CastInfo("player") == 5782 then return end 

    runTotemStomp()
    runStomp()

    fear("healer")
    fearNoFakeCast("healer")
    fear("peel")
    fearNoFakeCast("peel")
    fearNoFakeCast("healer-refear")
    fear("peelLOWHP")
    fearNoFakeCast("peelLOWHP")
    fear("rogue")
    fearNoFakeCast("rogue")
    coil("peel")
    coil("kill")
    shadowfury("peel")
    curseofweakness("reflect")
    curseofexhaustion()
    --curseofexhaustion("target2s")
    curseoftongues("caster")
    soulstrike("petability")
    felstorm("petability")
    petAttack() 

    if not IsEnemy("target") then return end  --if not enemy--
    if not Alive("target") then return end

    --StompFunction()
    observer()
    fellord()

    dreadstalker("highprio")
    grimfelguard() --burst--
    grimfelguard("vsHealer") --burst--
    tyrant() --burst--
    tyrantNoFakeCast()
    powersiphon()
    charhound()
    dreadstalker("procc")
    demonbolt("target")
    demonbolt("lowHP")
    demonicstrength()
    demonicstrength("vsHealer")
    dreadstalker()
    demonbolt()
    demonbolt("spread")
    curseoftongues("healer")
    curseoftongues("caster")
    handofguldan("buff")
    handofguldan()
    shadowbolt()

end

function outCombat()

    local shiftHeldDown = IsShiftKeyDown()
    if shiftHeldDown and Builder:GetConfig("leftShiftPause") == "yes" then return end
    if not Alive("player") then return end
    if not erButton.isEnabled then return end
    draw:Enable()
    if Locked() then return end
    if Mounted() then return end 
    
    orcracial()
    trollracial()

    StopCastingInImmunities()
    soulwell()
    GrabHealthstone(1,2)
    keepKitingAlert()

    local HSCount = GetItemCount(224464)
    if HSCount >= 1 and Health("player") < 50 then
        soulburn("HSverylow")
        HealthStoneUsageVerylow()

        soulburn("HS")
        HealthStoneUsage()
    end 

   --tyrant("test")
--    soulburn("test")
--    demonicteleport("test")
   --fear("test")
   --unendingresolve("test")

    if IsComboPressed("gatebutton") then
        soulburn()
        demonicgateway()
       -- demoniccircle()
    end 

    if IsComboPressed("portbutton") then
        soulburn("port")
        demonicteleport()
        demonicteleport("noshards")
    end 
 
    if not Alive("target") then return end
    petAttack()
    charhound("precast")
    dreadstalker("precast")
    --soulstrike("petability")
    summonfelguard()

   -- testCharhound()

end

Elite.inCombat = inCombat 
Elite.outCombat = outCombat 


--TODO:--
-- HIGH PRIO:

-- Demon bolt on other targets so Debuff Anathema + Doom is spreading (only Players!) < DONE
-- Defensive Usage, better < DONE? 
-- Auto Port vs melees wenn die bursten  < DONE 
-- we kill big totems with demon bolt procc < DONE 
-- we kill small totems like grounding/tremor with shadowbolt maybe  < DONE 

-- MID PRIO:

---LOW PRIO:
-- Fearen vllt wenn nur 1 oder 2 Shrouds up sind um es zu killen (nur bei healer) und > 15s remaining vom buff 
-- shadowfury auf 2 melees wenn sie auf mich gehen und keine kicks rdy haben 


--ToDo morgen:
-- charhound/tyrant/siphon fix < DONE
-- Healthstone logic < NUTZEN WIR NUR, wenn wir nix an defs mehr rdy haben und keien big defs/panic auf uns  < DONE
-- Fix Felguard Summon < DONE 
-- Coil Logic for peeling + Kill < DONE 
-- Nether reflect logic (mal bei Jas warrior logic schauen ob ich da was hab) < DONE 
-- Fel lord logic (vs melees) < DONE 
-- Axe Toss logic < DONE 
-- Shadowmeld logic < DONE 
-- Arena start Soulwell < DONE 
-- Shadowfury Logic < DONE für peel
-- reflect weakness on warrior reflect  < DONE 
-- Curses (Exhaustion on melee if they target me and i am not slowed) < DONE 
-- Curses (Tongues) on Healer if there is no decurser (for example Priest and not a mage in team) < DONE 
-- STOMP < DONE 
-- Port + Gate < DONE 
-- grim felguard wenn healer existiert wirklich nur nutzen wenn der healer im CC ist > da wir das aktuelle target damit auch stunnen < DONE 
-- Drawings adden  < DONE? 
-- Burst Logic, wir usen burst nur wenn healer im CC < muss getestet werden wann am besten < DONE
-- Fear usen zum peelen, wenn unsere mates low droppen < DONE 
-- überprüfen ob PVP Talents missing sind, vllt mal bei murlok.io schauen ob andere pvp talents gespielt werden (wie bonds) < DONE,
-- IsCastingT Spelltables umändern < DONE 
-- We need to check if there is a current CC running on (for example Healer ) > so we stop cast fear on it  < DONE 