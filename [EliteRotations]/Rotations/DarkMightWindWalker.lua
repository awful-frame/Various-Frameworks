local Elite = _G.Elite
local Draw = Tinkr.Util.Draw:New()
local spellbook = Elite.CallbackManager.spellbook
local OM = Elite.ObjectManager
local enemies = OM:GetEnemies()
local friends = OM:GetFriends()
local tyrants = OM:GetTyrants()
local totems = OM:GetTotems()
local ftotems = OM:GetFTotems()
local pets = OM:GetPets()
local fpets = OM:GetFPets()
local distance = Distance("player", "target")
Elite:SetUtilitiesEnvironment()

local e = {
    tigerPalm = NewSpell(100780, { ignoreChanneling = false, facehack = false, targeted = true, ignoreFacing = true, ignoreMoving = true }),
    risingSunKick = NewSpell(107428, { ignoreChanneling = false, facehack = true, targeted = true, ignoreFacing = false, ignoreMoving = false }),
    blackoutKick = NewSpell(100784, { ignoreChanneling = false, facehack = true, targeted = true, ignoreFacing = false, ignoreMoving = false }),
    fistsOfFury = NewSpell(113656, { ignoreChanneling = false, facehack = true, targeted = false, ignoreFacing = false, ignoreMoving = false }),
    spinningCraneKick = NewSpell(101546, { ignoreChanneling = false, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    whirlingDragonPunch = NewSpell(152175, { ignoreChanneling = false, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    xuen = NewSpell(123904, { ignoreChanneling = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    touchOfDeath = NewSpell(322109, { ignoreChanneling = true, targeted = true, ignoreFacing = true, ignoreMoving = true }),
    strikeOfTheWindlord = NewSpell(392983, { ignoreChanneling = false, facehack = false, targeted = true, ignoreFacing = true, ignoreMoving = false }),
    celestialConduit = NewSpell(443028, { ignoreChanneling = true, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    paralysis = NewSpell(115078, { ignoreChanneling = true, facehack = false, targeted = true, ignoreFacing = true, ignoreMoving = true }),
    legSweep = NewSpell(119381, { ignoreChanneling = true, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    stormEarthAndFire = NewSpell(137639, { ignoreChanneling = false, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    fortifyingBrew = NewSpell(243435, { Beneficial = true, ignoreChanneling = true, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    diffuseMagic = NewSpell(122783, { Beneficial = true, ignoreChanneling = true, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    dampenHarm = NewSpell(122278, { Beneficial = true, ignoreChanneling = true, facehack = false, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    touchOfKarma = NewSpell(122470, { Beneficial = true, ignoreChanneling = true, facehack = false, targeted = true, ignoreFacing = true, ignoreMoving = true }),
    vivify = NewSpell(116670, { Beneficial = true, ignoreChanneling = true, targeted = true, ignoreFacing = true, ignoreMoving = true }),
    spearHandStrike = NewSpell(116705, { ignoreChanneling = true, facehack = true, targeted = true, ignoreFacing = false, ignoreMoving = true }),
    roll = NewSpell(109132, { ignoreChanneling = true, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    flyingSerpentKick = NewSpell(101545, { ignoreChanneling = true, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    disable = NewSpell(116095, { ignoreChanneling = true, facehack = true, targeted = true, ignoreFacing = false, ignoreMoving = true }),
    clash = NewSpell(324312, { ignoreChanneling = true, targeted = true, ignoreFacing = true, ignoreMoving = true, initiateCombat = true, rootEffect = true }),
    ringOfPeace = NewSpell(116844, { ignoreChanneling = true, targeted = false, ignoreFacing = true, ignoreMoving = true }),
    grappleWeapon = NewSpell(233759, { ignoreChanneling = true, targeted = true, ignoreFacing = true, ignoreMoving = true }),
    detox = NewSpell(218164, { ignoreCC = true, ignoreMoving = true, Beneficial = true, targeted = false }),
    tigersLust = NewSpell(116841, { Beneficial = true, ignoreChanneling = false, targeted = true, ignoreFacing = true, ignoreMoving = true }),
    unitywithin = NewSpell(443591, { ignoreChanneling = true, targeted = true, ignoreFacing = true, ignoreMoving = true })
}

-- Ensure script is for Windwalker Monks
if Spec("player") ~= 269 then return end
_G.TickRate = 0.01

-- Define the darkMight table and helper functions
local darkMight = {}

function darkMight.getSpellInfo(spellId)
    if not spellId or spellId == 0 then
        return 0
    end

    local getSpellInfo = C_Spell.GetSpellInfo(spellId)

    if getSpellInfo then
        return getSpellInfo.name
    end

    return 0
end
local detoxableSpellIDs = {
    [356719] = true,  -- Example: Chimeral Sting
    [335467] = true    -- Example: Devouring Plague
}
-- Define a list of healer spells to interrupt
local interruptListHealer = {
    [8936] = true,    -- Regrowth
    [2061] = true,    -- Flash Heal
    [8004] = true,    -- Healing Surge
    [82326] = true,   -- Holy Light
    [19750] = true,   -- Flash of Light
    [200652] = true,  -- Ty's Deliverance
    [64843] = true,    -- Divine Hymn
    [367226] = true,   -- Spiritbloom
    [355936] = true,   -- Dream Breath
    [1064] = true,     -- Chain Heal
    [421453] = true,   -- Ultimate Penitence
    [360806] = true,   -- Sleep Walk
}

-- Map spell IDs to spell names
darkMight.MIND_CONTROL = darkMight.getSpellInfo(605)
darkMight.FEAR = darkMight.getSpellInfo(5782)
darkMight.POLYMORPH = darkMight.getSpellInfo(118)
darkMight.SONG_OF_CHI_JI = darkMight.getSpellInfo(198909)
darkMight.HEX = darkMight.getSpellInfo(51514)
darkMight.SLEEP_WALK = darkMight.getSpellInfo(360806)
darkMight.REPENTANCE = darkMight.getSpellInfo(20066)
darkMight.CYCLONE = darkMight.getSpellInfo(33786)
darkMight.LIGHTNING_LASSO = darkMight.getSpellInfo(305483)
darkMight.SHADOWFURY = darkMight.getSpellInfo(30283)
darkMight.REGROWTH = darkMight.getSpellInfo(8936)
darkMight.FLASHHEAL = darkMight.getSpellInfo(2061)
darkMight.HEALINGSURGE = darkMight.getSpellInfo(8004)
darkMight.HOLYLIGHT = darkMight.getSpellInfo(82326)
darkMight.FLASHOFLIGHT = darkMight.getSpellInfo(19750)
darkMight.MIND_BLAST = darkMight.getSpellInfo(8092)
darkMight.ULTIMATEPENITANCE = darkMight.getSpellInfo(421453)
darkMight.ICEBLOCK = darkMight.getSpellInfo(45438)
darkMight.DIVINE_SHEILD = darkMight.getSpellInfo(642)
darkMight.BOP = darkMight.getSpellInfo(1022)
darkMight.BOS = darkMight.getSpellInfo(204018)
darkMight.DISPERSION = darkMight.getSpellInfo(47585)
darkMight.CLOAKOFSHADOWS = darkMight.getSpellInfo (31224)
darkMight.EVASION = darkMight.getSpellInfo(5277)
darkMight.TURTLE = darkMight.getSpellInfo(186265)
darkMight.NETHERWALK = darkMight.getSpellInfo(196555)
darkMight.LIFE_COCOON = darkMight.getSpellInfo(116849)
darkMight.KARMA = darkMight.getSpellInfo(122470)
darkMight.DBTS = darkMight.getSpellInfo(118038)
darkMight.DIVINE_HYMN = darkMight.getSpellInfo(64843)
darkMight.HandOfFreedom = darkMight.getSpellInfo(1044)

-- GUI Configuration
local Builder = Tinkr.Util.GUIBuilder:New {
    config = "WindwalkerMonkConfig"
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

-- General Settings Group
local generalSettings = Builder:Group {
    title = "General Settings",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Checkbox { key = "enablePvP", label = "Enable PvP logic", default = "yes" },
                Builder:Checkbox { key = "enableAutoDefense", label = "Auto Use Defensives", default = "yes" },
                Builder:Checkbox { key = "enableDebug", label = "Enable Debug Frame", default = "no" }
            },
            Builder:Columns {
                Builder:Checkbox { key = "enableAutoStomp", label = "Enable Auto Totem Stomp", default = "yes" },
                Builder:Checkbox { key = "enableInterrupts", label = "Auto Interrupt", default = "yes" },
                Builder:Checkbox { key = "enableLegSweep", label = "Enable Leg Sweep", default = "yes" } 
            }
        }
    }
}

-- Defensive Settings Group
local defenseSettings = Builder:Group {
    title = "Defensive Settings",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Slider {
                    key = 'touchOfKarmaHealth',
                    label = "Touch of Karma Health %",
                    description = "Health percentage to use Touch of Karma",
                    min = 1,
                    max = 100,
                    step = 1,
                    default = 70,
                    percent = false
                },
                Builder:Slider {
                    key = 'fortifyingBrewHealth',
                    label = "Fortifying Brew Health %",
                    description = "Health percentage to use Fortifying Brew",
                    min = 1,
                    max = 100,
                    step = 1,
                    default = 50,
                    percent = false
                }
            },
            Builder:Columns {
                Builder:Slider {
                    key = 'dampenHarmHealth',
                    label = "Dampen Harm Health %",
                    description = "Health percentage to use Dampen Harm",
                    min = 1,
                    max = 100,
                    step = 1,
                    default = 40,
                    percent = false
                },
                Builder:Slider {
                    key = 'diffuseMagicHealth',
                    label = "Diffuse Magic Health %",
                    description = "Health percentage to use Diffuse Magic",
                    min = 1,
                    max = 100,
                    step = 1,
                    default = 60,
                    percent = false
                }
            }
        }
    }
}

-- Positioning Settings Group
local positioningSettings = Builder:Group {
    title = "Alert Positioning",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:Dropdown {
                    key = "alertXPosition",
                    label = "Alert X Position",
                    default = "option_e",
                    values = alertXPositionValues,
                    description = "The horizontal screen position for the alerts."
                },
                Builder:Dropdown {
                    key = "alertYPosition",
                    label = "Alert Y Position",
                    default = "option_j",
                    values = alertYPositionValues,
                    description = "The vertical screen position for the alerts."
                }
            }
        }
    }
}

-- Keybind Settings Group
local keybindSettings = Builder:Group {
    title = "Keybinds",
    content = {
        Builder:Rows {
            Builder:Columns {
                Builder:EditBox {
                    key = "keybindRoll",
                    label = "Keybind for Roll",
                    default = "SHIFT-ALT-R"
                },
                Builder:EditBox {
                    key = "keybindFlyingSerpentKick",
                    label = "Keybind for Flying Serpent Kick",
                    default = "SHIFT-ALT-F"
                }
            }
        }
    }
}

-- Tab Group
local TabGroup = Builder:TabGroup {
    key = "monk_tabs",
    tabs = {
        Builder:Tab {
            title = "Settings",
            content = {
                generalSettings,
                defenseSettings,
                positioningSettings -- Added positioningSettings to the Settings tab
            }
        },
        Builder:Tab {
            title = "Keybinds",
            content = {
                keybindSettings
            }
        }
    }
}

-- Tree Group
local TreeGroup = Builder:TreeGroup {
    key = "monk_tree",
    branches = {
        Builder:TreeBranch {
            title = "Windwalker Monk",
            icon = 627606,
            content = {
                TabGroup
            }
        }
    }
}

-- Window
local Window = Builder:Window {
    key = "monkWindow",
    title = "|cff00ff96Windwalker Monk CR|r",
    width = 800,
    height = 480,
    content = {
        TreeGroup
    }
}

-- Function to Get Alert Position
local function GetAlertPosition()
    local xKey = Builder:GetConfig("alertXPosition", "option_e")
    local yKey = Builder:GetConfig("alertYPosition", "option_j")
    local xValue = alertXPositionValues[xKey] or "0"
    local yValue = alertYPositionValues[yKey] or "0"
    return tonumber(xValue), tonumber(yValue)
end

-- Reset GUI State
local function ResetGUIState()
    Builder:SetConfig("monk_tabs", nil)
    Builder:SetConfig("monk_tree", nil)
end

-- Command for Configuration Window
local MyCommands = Tinkr.Util.Commands:New("monkcr")
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
end, "Shows the Windwalker Monk config window")

-- Initialize default configuration values if they aren't set
local function InitializeConfigDefaults()
    local defaultConfig = {
        -- Other defaults...
        alertXPosition = "option_e",
        alertYPosition = "option_j",
        -- ...
    }

    for key, defaultValue in pairs(defaultConfig) do
        local currentValue = Builder:GetConfig(key, nil)
        if currentValue == nil then
            Builder:SetConfig(key, defaultValue)
        end
    end
end

InitializeConfigDefaults()

-- Create the erButton
local erButton = CreateFrame("Button", "erButton", UIParent, "UIPanelButtonTemplate")
erButton:SetSize(70, 70) -- Increase the button size

-- Set default icon for the button
local function UpdateButtonAppearance(button)
    if button.isEnabled then
        button:SetNormalTexture("Interface\\Icons\\monk_ability_fistoffury")
        button.text:SetText("Enabled")
    else
        button:SetNormalTexture("Interface\\Icons\\monk_ability_transcendence")
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

-- Toggle function to start/stop rotation
local function ToggleButton()
    erButton.isEnabled = not erButton.isEnabled
    UpdateButtonAppearance(erButton)
    if erButton.isEnabled then
        if not mainTicker then
            mainTicker = C_Timer.NewTicker(0.1, Main)
            Debug("Rotation Enabled via Button.")
        end
    else
        if mainTicker then
            mainTicker:Cancel()
            mainTicker = nil
            Debug("Rotation Disabled via Button.")
        end
    end
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


-- Custom Debug Frame Setup
local debugFrame = CreateFrame("ScrollingMessageFrame", "WWMonkDebugFrame", UIParent)
debugFrame:SetSize(300, 150)
debugFrame:SetPoint("CENTER", UIParent, "CENTER", 400, 200)
debugFrame:SetFontObject(GameFontNormal)
debugFrame:SetMaxLines(100)
debugFrame:SetFading(true)
debugFrame:SetFadeDuration(1)
debugFrame:SetTimeVisible(10)
debugFrame:EnableMouse(true)
debugFrame:SetMovable(true)
debugFrame:RegisterForDrag("LeftButton")
debugFrame:SetScript("OnDragStart", debugFrame.StartMoving)
debugFrame:SetScript("OnDragStop", debugFrame.StopMovingOrSizing)

-- Define spell keys and display names
local spellKeys = {
    [100780] = "tigerPalm",
    [107428] = "risingSunKick",
    [100784] = "blackoutKick",
    [113656] = "fistsOfFury",
    [101546] = "spinningCraneKick",
    [152175] = "whirlingDragonPunch",
    [123904] = "xuen",
    [322109] = "touchOfDeath",
    [392983] = "strikeOfTheWindlord",
    [443028] = "celestialConduit",
    [115078] = "paralysis",
    [119381] = "legSweep",
    [137639] = "stormEarthAndFire",
    [243435] = "fortifyingBrew",
    [122783] = "diffuseMagic",
    [122278] = "dampenHarm",
    [122470] = "touchOfKarma",
    [116670] = "vivify",
    [116705] = "spearHandStrike",
    [109132] = "roll",
    [101545] = "flyingSerpentKick",
    [116095] = "disable"
}

local spellNames = {
    [100780] = "Tiger Palm",
    [107428] = "Rising Sun Kick",
    [100784] = "Blackout Kick",
    [113656] = "Fists of Fury",
    [101546] = "Spinning Crane Kick",
    [152175] = "Whirling Dragon Punch",
    [123904] = "Invoke Xuen, the White Tiger",
    [322109] = "Touch of Death",
    [392983] = "Strike of the Windlord",
    [443028] = "Celestial Conduit",
    [115078] = "Paralysis",
    [119381] = "Leg Sweep",
    [137639] = "Storm, Earth, and Fire",
    [243435] = "Fortifying Brew",
    [122783] = "Diffuse Magic",
    [122278] = "Dampen Harm",
    [122470] = "Touch of Karma",
    [116670] = "Vivify",
    [116705] = "Spear Hand Strike",
    [109132] = "Roll",
    [101545] = "Flying Serpent Kick",
    [116095] = "Disable"
}

-- Custom Debug Function with Timestamps
local function Debug(message)
    if debugFrame and Builder:GetConfig("enableDebug", "no") == "yes" then
        local timeStamp = date("%H:%M:%S")
        debugFrame:AddMessage("|cff00ff00[" .. timeStamp .. " WW Monk Debug]|r: " .. message)
    end
end

-- TOTEM STOMPING
local totem1 = {
    [105451] = true, -- Counterstrike Totem
    [5913] = true,   -- Tremor Totem
    [5925] = true,   -- Grounding Totem
    [105427] = true, -- Skyfury Totem
    [6112] = true,   -- Windfury Totem
    [53006] = true,  -- Spirit Link Totem
}
local tremorTotems = {
    [5913] = true,   -- Tremor Totem
}
local totem2 = {
    [179867] = true, -- Static Field Totem
    [59764] = true,  -- Healing Tide Totem
    [3527] = false,  -- Healing Stream Totem
    [61245] = true,  -- Capacitor Totem
}

local pvpStomps = {
    [179193] = true, -- Observer
    [107100] = true, -- Observer2
    [101398] = true, -- Psyfiend
    [119052] = true, -- WarBanner
}

-- Updated runTotemStomp function
local function runTotemStomp()
    Elite.StompTotems(function(totem, totemId)
        if totem1[totemId] and e.tigerPalm:CanCast(totem.key) then
            if e.tigerPalm:Cast(totem.key) then
                Debug("Stomping totem1: " .. Name(totem.key) .. " with Tiger Palm.")
            end
            return true -- Stop after casting
        end

        -- Handle totem2 using Blackout Kick
        if totem2[totemId] and e.blackoutKick:CanCast(totem.key) then
            if e.blackoutKick:Cast(totem.key) then
                Debug("Stomping totem1: " .. Name(totem.key) .. " with Blackout Kick.")
            end
            return true -- Stop after casting
        end
    end)

    -- Handle PvP stomps using Tiger's Palm
    Elite.Stomp(function(pobject, stompItemID)
        if pvpStomps[stompItemID] and e.tigerPalm:CanCast(pobject.key) then
            if e.tigerPalm:Cast(pobject.key) then
                Debug("Stomping PvP object: " .. Name(pobject.key) .. " with Tiger Palm.")
            end
            return true -- Stop after casting
        end
    end)
end


-- List of buff IDs to avoid attacking into
local avoidAttackBuffs = {
    [darkMight.ICEBLOCK] = true,
    [darkMight.DIVINE_SHEILD] = true,
    [darkMight.BOP] = true,
    [darkMight.BOS] = true,
    [darkMight.CYCLONE] = true,
    [darkMight.DISPERSION] = true,
    [darkMight.CLOAKOFSHADOWS] = true,
    [darkMight.EVASION] = true,
    [darkMight.TURTLE] = true,
    [darkMight.NETHERWALK] = true,
    [darkMight.LIFE_COCOON] = true,
    [darkMight.KARMA] = true,
}

    -- Helper function to determine if the target is a boss
    local function IsBoss(target)
        return UnitLevel(target) == -1
    end
    
    --AttemptCast Function
    function AttemptCast(spellId, target)
        if not spellId then
            Debug("AttemptCast failed: spellId is nil.")
            return false
        end
    
        local spellName = spellNames[spellId]
        if not spellName then
            Debug("AttemptCast failed: No spell name found for spell ID " .. tostring(spellId))
            return false
        end
    
        -- Check if the spell can be cast
        if not CanCast(spellId) then
            Debug("Cannot cast " .. spellName .. "; conditions not met.")
            return false
        end
    
        -- For targeted spells, check for avoidAttackBuffs
        if DontDMG(target) then
            Debug("AttemptCast aborted: Target has immunity or avoidance buffs.")
            StopAttacking()
            return false
        end
        
        if NoInteract(target) then
            Debug("AttemptCast aborted: Cannot interact with target.")
            return false
        end
        -- Attempt to cast the spell
    if Cast(spellId, target) then
        lastAbilityCast = spellId
        Debug("Casting " .. spellName .. (target and (" on " .. target) or ""))
        return true
    else
        Debug("Failed to cast " .. spellName)
        return false
    end
end

-- Track if Flying Serpent Kick has been queued up to cast again
local flyingSerpentKickQueued = false

-- Function to check and execute keybinds for Roll and Flying Serpent Kick
local function CheckKeybinds()
    -- Use a mapping of keybinds to actions
    local keybindActions = {
        [Builder:GetConfig("keybindRoll", "SHIFT-ALT-R")] = function()
            if e.roll:Cast() then
                Debug("Casting Roll")
            end
        end,
        [Builder:GetConfig("keybindFlyingSerpentKick", "SHIFT-ALT-F")] = function()
            if e.flyingSerpentKick:Cast() then
                Debug("Casting Flying Serpent Kick")
            end
        end,
    }

    for keybind, action in pairs(keybindActions) do
        if IsKeyDown(keybind) then
            action()
            break -- Stop after handling one keybind
        end
    end
end

-- SpellRange Function
function SpellRange(spellID)
    local ranges = {
        [e.tigerPalm] = 5, -- Tiger Palm Range
        [e.blackoutKick] = 5, -- Blackout Kick Range
        [e.disable.id]    = 8,  -- Disable range in yards
        [e.legSweep.id]   = 8,  -- Leg Sweep range in yards (assuming similar to Disable)
        -- Add other spells and their ranges if needed
    }

    return ranges[spellID] or 8  -- Default to 8 yards if not defined
end

-- Hook to reset the flag when out of combat
local function outCombat()
    openerUsed = false
    flyingSerpentKickQueued = false
end

-- Set up a repeating timer to check keybinds every 0.1 seconds
C_Timer.NewTicker(0.1, CheckKeybinds)

-- Function to retrieve CC spells
local function getCcSpells()
    return {
        [darkMight.MIND_CONTROL] = true,
        [darkMight.FEAR] = true,
        [darkMight.POLYMORPH] = true,
        [darkMight.SONG_OF_CHI_JI] = true,
        [darkMight.HEX] = true,
        [darkMight.SLEEP_WALK] = true,
        [darkMight.REPENTANCE] = true,
        [darkMight.SHADOWFURY] = true,
        [darkMight.CYCLONE] = true,
        [darkMight.REGROWTH] = true,
        [darkMight.FLASHHEAL] = true,
        [darkMight.HEALINGSURGE] = true,
        [darkMight.HOLYLIGHT] = true,
        [darkMight.FLASHOFLIGHT] = true,
        [darkMight.ULTIMATEPENITANCE] = true,
        [darkMight.MIND_BLAST] = true,
    }
end

-- Updated shouldInterrupt Function with Randomized Logic
local function shouldInterrupt(enemy)
    if Builder:GetConfig("enableInterrupts", "yes") ~= "yes" then
        return false
    end

    if not IsPlayer(enemy.key) then
        return false
    end

    local spellCasted = darkMight.getSpellInfo(CastInfo(enemy.key))
    local spellChannelled = darkMight.getSpellInfo(ChanInfo(enemy.key))

    if spellCasted == 0 and spellChannelled == 0 then
        return false
    end

    if not IsCastChan(enemy.key) and (CanInterruptCast(enemy.key) or CanInterruptChannel(enemy.key)) then
        return false
    end

    local kickThreshold = random(45, 75)
    local channelThreshold = random(25, 45)

    local castPercent = CastingPercent(enemy.key)
    local channelPercent = ChannelingPercent(enemy.key)
    
    local spellsToKick = getCcSpells()

    if spellCasted ~= 0 and (not spellsToKick[spellCasted] or castPercent <= kickThreshold) then
        return false
    end

    if spellChannelled ~= 0 and (not spellsToKick[spellChannelled] or channelPercent <= channelThreshold) then
        return false
    end

    return true
end

-- Function to handle interrupt logic using the updated shouldInterrupt
local function InterruptLogic()
    if Builder:GetConfig("enableInterrupts", "yes") ~= "yes" then
        return false
    end

    local enemies = OM:GetEnemies()

    ObjectsLoop(OM:GetEnemies(), function(enemy)
        if shouldInterrupt(enemy) then
            if e.spearHandStrike:Cast(enemy.key) then
                Alert(116405, "Interrupted!", GetAlertPosition())
                return true -- Stop after interrupting
            end
        end
    end)
end

-- Function to check for Detox-able debuffs on the player
local function ShouldCastDetox()
    local typesToRemove = detoxableTypes

    -- Iterate over player's debuffs
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = HasDebuff(i, "player")
        if not name then break end

 -- Check if the debuff's spell ID is in detoxableSpellIDs
        if detoxableSpellIDs[spellId] then
            local debuffType = select(7, GetSpellInfo(spellId))  -- e.g., "Poison", "Disease", "Magic"
            Debug(string.format("Detox: Detected debuff '%s' (Spell ID: %d) of type '%s' - needs Detox.", name, spellId, debuffType))
            return true  -- Detox needed
        else
            Debug(string.format("Detox: Detected debuff '%s' (Spell ID: %d) of type '%s' - not Detoxable.", name, spellId, select(7, GetSpellInfo(spellId)) or "Unknown"))
        end
    end

    Debug("Detox: No Detox-able debuffs found.")
    return false  -- No Detox needed
end

-- Function to draw a melee range arc
local function DrawMeleeArc()
    local playerX, playerY = UnitPosition("player")
    local meleeRange = 5 -- Melee range is typically 5 yards
    local arcSegments = 36 -- Number of segments for smoother arc (360 degrees / 10 degrees)

    if playerX and playerY then
        for i = 0, arcSegments do
            local angle1 = math.rad(i * (360 / arcSegments))
            local angle2 = math.rad((i + 1) * (360 / arcSegments))
            local x1 = playerX + meleeRange * math.cos(angle1)
            local y1 = playerY + meleeRange * math.sin(angle1)
            local x2 = playerX + meleeRange * math.cos(angle2)
            local y2 = playerY + meleeRange * math.sin(angle2)
            
        end
    end
end

-- Function to use Tiger's Lust when rooted or snared
local function UseTigersLust()

    Debug("UseTigersLust called.")

    local playerKey = getUnitKey("player")
    local playerUnit = OM.units[playerKey]

    if not playerUnit then
        Debug("Player unit data not found.")
        return false
    end

    if IsRooted("player") or IsSnared("player") then
        if e.tigersLust:Cast("player") then
            Debug("Casting Tiger's Lust to remove root or snare.")
            return true
        end
    end
end



-- Function to check current Chi level
local function CurrentChi()
    return UnitPower("player", Enum.PowerType.Chi)
end

-- Function to get maximum Chi
local function MaxChi()
    return UnitPowerMax("player", Enum.PowerType.Chi)
end

-- Function to check if "Blackout Kick!" buff is active
local function HasBlackoutKickBuff()
    local buffId = 116768 -- Blackout Kick! buff ID
    return HasBuff(buffId, "player")
end

-- Function to check if "Dance of Chi-Ji" buff is active
local function HasDanceOfChiJi()
    local buffId = 325202 -- Dance of Chi-Ji buff ID
    return HasBuff(buffId, "player")
end

-- Function to check if Whirling Dragon Punch is ready
local function CanUseWhirlingDragonPunch()
    local risingSunKickCD = SpellCd(107428)
    local fistsOfFuryCD = SpellCd(113656)
    return risingSunKickCD > 0 and fistsOfFuryCD > 0 and CanCast(152175)
end

-- Function to check if Acclamation is active and its remaining duration
local function HasAcclamationBuff(target)
    local buffId = 451432 -- Acclamation buff ID
    return HasBuff(buffId, target), GetBuffRemaining(buffId, target)
end

-- Function to check if Touch of Death can be used as an executioner
local function CanUseTouchOfDeath(target)
    if not target or not UnitExists(target) then
        Debug("CanUseTouchOfDeath: Invalid target.")
        return false
    end
    if UnitIsDeadOrGhost(target) then
        Debug("CanUseTouchOfDeath: Target is dead or a ghost.")
        return false
    end
    if not UnitCanAttack("player", target) then
        Debug("CanUseTouchOfDeath: Cannot attack target.")
        return false
    end

    local targetHealth = UnitHealth(target)
    local targetHealthMax = UnitHealthMax(target)
    local healthPercent = (targetHealth / targetHealthMax) * 100

    if healthPercent <= 15 then
        Debug("Touch of Death conditions met; target is below 15% health.")
        return true
    else
        Debug("Target health above 15%; cannot use Touch of Death.")
    end
    return false
end

-- Function to prioritize Touch of Death casting
local function PrioritizeTouchOfDeath()
    if CanUseTouchOfDeath("target") then
        if e.touchOfDeath:Cast("target") then
            Debug("Prioritized: Casting Touch of Death.")
            return true  -- Indicate that Touch of Death was cast
        else
            Debug("Prioritized: Failed to cast Touch of Death.")
        end
    end
    return false  -- Touch of Death was not cast
end

-- Define enemy cooldowns to track for peeling
local ENEMY_COOLDOWNS = {
    [49028] = 120,   -- Dancing Rune Weapon (Blood Death Knight)
    [51271] = 60,    -- Pillar of Frost (Frost Death Knight)
    [207289] = 90,   -- Unholy Assault (Unholy Death Knight)
    [191427] = 240,  -- Metamorphosis (Havoc Demon Hunter)
    [212084] = 60,   -- Fel Devastation (Vengeance Demon Hunter)
    [106951] = 180,  -- Berserk (Feral Druid)
    [102558] = 180,  -- Incarnation: Guardian of Ursoc (Guardian Druid)
    [266779] = 120,  -- Coordinated Assault (Survival Hunter)
    [137639] = 90,   -- Storm, Earth, and Fire (Windwalker Monk)
    [31884] = 120,   -- Avenging Wrath (Retribution Paladin)
    [79140] = 120,   -- Vendetta (Assassination Rogue)
    [13750] = 180,   -- Adrenaline Rush (Outlaw Rogue)
    [121471] = 180,  -- Shadow Blades (Subtlety Rogue)
    [114051] = 180,  -- Ascendance (Enhancement Shaman)
    [262161] = 45,   -- Warbreaker (Arms Warrior)
    [1719] = 90,     -- Recklessness (Fury Warrior)
    [107574] = 90    -- Avatar (Protection Warrior)
    
}

-- Function to check if an enemy is using a tracked cooldown
local function IsEnemyUsingCooldown(enemy)
    for spellId, cooldown in pairs(ENEMY_COOLDOWNS) do
        if HasBuff(spellId, enemy.key) then
            Debug("Enemy is using cooldown: " .. (spellNames[spellId] or "Spell ID: " .. tostring(spellId)))
            return true
        end
    end
    return false
end
-- Function to check if Yu'lon's effect is active
local jadeSerpentBuffId = 443424 -- Heart of the Jade Serpent
local buffCount = GetBuffCount(jadeSerpentBuffId, "player")
if buffCount >= 45 then
    if e.strikeOfTheWindlord:Cast("target") then
        Debug("Casting Strike of the Windlord with max stacks of Heart of the Jade Serpent")
    end
end

-- Helper function to find a unit by GUID
    function getUnitByGuid(guid, tablesToSearch)
        if not guid then return nil end
    
        local foundUnit = nil
        local tables = type(tablesToSearch[1]) == "table" and tablesToSearch or { tablesToSearch }
    
        for _, currentTable in ipairs(tables) do
            ObjectsLoop(currentTable, function(object)
                if object.guid and object.guid == guid then
                    foundUnit = object
                    return true
                end
            end)
    
            if foundUnit then break end
        end
    
        return foundUnit
    end
    
    -- Event Manager for handling spell cast success
    local EventManager = Elite.EventManager
    EventManager:On("SPELL_CAST_SUCCESS", true)


-- Initialize Spells with Traits
Elite:Populate(e)
Alert(113656, "Windwalker Initialized!", GetAlertPosition())

-- Track Last Cast Ability and Usage of Celestial Conduit
local lastAbilityCast = nil
local celestialConduitLastCast = false

-- Function to map GUID to UnitID
function GetUnitIDByGUID(guid)
    local unitIDs = { "target", "focus", "mouseover" }

    -- Include arena and nameplate unit IDs
    for i = 1, 5 do
        table.insert(unitIDs, "arena" .. i)
        table.insert(unitIDs, "nameplate" .. i)
    end

    for _, unitID in ipairs(unitIDs) do
        if UnitExists(unitID) and UnitGUID(unitID) == guid then
            return unitID
        end
    end
    return nil
end

-- Updated UseDefensives function without IsFacingMagicDamage
function UseDefensives()
    local playerHealth = Health("player")
    local touchOfKarmaHealth = Builder:GetConfig('touchOfKarmaHealth', 70)
    local fortifyingBrewHealth = Builder:GetConfig('fortifyingBrewHealth', 50)
    local dampenHarmHealth = Builder:GetConfig('dampenHarmHealth', 40)
    local diffuseMagicHealth = Builder:GetConfig('diffuseMagicHealth', 60)

    if playerHealth < touchOfKarmaHealth then
        if e.touchOfKarma:Cast("target") then
            Debug("Casting Touch of Karma")
            return
        end
    end

    if playerHealth < fortifyingBrewHealth then
        if e.fortifyingBrew:Cast() then
            Debug("Casting Fortifying Brew")
            return
        end
    end

    if playerHealth < dampenHarmHealth then
        if e.dampenHarm:Cast() then
            Debug("Casting Dampen Harm")
            return
        end
    end

    if playerHealth < diffuseMagicHealth then
        if e.diffuseMagic:Cast() then
            Debug("Casting Diffuse Magic")
            return
        end
    end
end
    
-- Function to check if a unit is a healer
function IsHealer(unitID)
    return Role(unitID) == "HEALER"
end

-- Function to count enemies within a specified radius of a unit
local enemiesInAoE = AreaEnemies("player", SpellRange(e.legSweep))
Debug("AreaEnemies: " .. enemiesInAoE .. " enemies within " .. SpellRange(e.legSweep) .. " yards.")

function ControlHealerWithDR()
    local healer = eHealer
    if healer and healer.interactable then
        -- Use healer.key directly
        if e.paralysis:Cast(healer.key) then
            Debug("Applied Paralysis to enemy healer with DR tracking.")
            return true
        end
    end
end

-- Function to handle casting Leg Sweep based on conditions
local function HandleLegSweep()
    -- Check if Leg Sweep is enabled in the configuration
    if Builder:GetConfig("enableLegSweep", "yes") ~= "yes" then
        Debug("Leg Sweep usage is disabled in settings.")
        return false
    end

    -- Ensure the current target exists and is attackable
    if not UnitExists("target") or not UnitCanAttack("player", "target") then
        Debug("No valid target to cast Leg Sweep.")
        return false
    end

    -- 1. Cast Leg Sweep on enemy healer
    if IsHealer("target") then
        if AttemptCast(119381, "target") then
            Debug("Casting Leg Sweep on enemy healer: " .. UnitName("target"))
            return true  -- Successfully casted
        else
            Debug("Failed to cast Leg Sweep on enemy healer.")
        end
    end

    -- 2. Cast Leg Sweep when at least two enemies are within AoE
    if enemiesInAoE >= 2 then
        if AttemptCast(119381, "target") then
            Debug("Casting Leg Sweep on multiple enemies near: " .. UnitName("target"))
            return true  -- Successfully casted
        else
            Debug("Failed to cast Leg Sweep on multiple enemies.")
        end
    end

    return false  -- Leg Sweep not cast
end

-- Callback to cast Celestial Conduit in combat
e.celestialConduit:Callback("combat", function(spell)
    if ShouldBurst() and CanCast(spell.id, "target") then
        if spell:Cast() then
            Debug("Casting Celestial Conduit for burst damage.")
            
            -- Immediately cast Unity Within after Celestial Conduit
            if CanCast(e.unitywithin.id, "target") and not Immune("target", "silence") then
                if AttemptCast(e.unitywithin.id, "target") then
                    Debug("Casting Unity Within immediately after Celestial Conduit.")
                else
                    Debug("Failed to cast Unity Within after Celestial Conduit.")
                end
            else
                Debug("Cannot cast Unity Within; conditions not met or target is immune.")
            end
        else
            Debug("Failed to cast Celestial Conduit.")
        end
    end
end)



-- Callback to cast Touch of Death as an execution ability
e.touchOfDeath:Callback("combat", function(spell)
    if CanUseTouchOfDeath("target") then
        if spell:Cast("target") then
            Debug("Casting Touch of Death on target.")
        else
            Debug("Failed to cast Touch of Death.")
        end
    end
end)

-- Callback to use Storm, Earth, and Fire in burst situations
e.stormEarthAndFire:Callback("combat", function(spell)
    if ShouldBurst() then
        if spell:Cast() then
            Debug("Casting Storm, Earth, and Fire for burst damage.")
        end
    end
end)

-- Callback for Fists of Fury - prioritize for AoE
e.fistsOfFury:Callback("combat", function(spell)
    if spell:Cast("target") then
        Debug("Casting Fists of Fury.")
    end
end)

-- Callback to apply Paralysis on high-priority targets like healers or off-targets
e.paralysis:Callback("combat", function(spell)
    local paralysisTarget = nil

    -- First, try to find the enemy healer
    local healer = FindEnemyHealer()

    if healer then
        -- Check if the healer is currently your target and is in combat
        local isHealerTargeted = UnitIsUnit(healer, "target")
        local isHealerInCombat = UnitAffectingCombat(healer)

        if isHealerTargeted and isHealerInCombat then
            -- Healer is targeted and being attacked; find another enemy to cast Paralysis on
            local enemies = OM:GetEnemies()
            for _, enemy in pairs(enemies) do
                local unitID = enemy.key
                -- Ensure the unit exists, is not the healer, is not the current target, is attackable, and is alive
                if UnitExists(unitID) and unitID ~= healer and unitID ~= "target" and UnitCanAttack("player", unitID) and not UnitIsDeadOrGhost(unitID) then
                    if CanCast(spell.id, unitID) and not IsDR("incapacitate", unitID) then
                        paralysisTarget = unitID
                        Debug("Healer is targeted and in combat; casting Paralysis on other enemy: " .. UnitName(unitID))
                        break  -- Exit loop after finding a valid target
                    end
                end
            end
        else
            -- Healer is not currently targeted or not in combat; attempt to cast Paralysis on healer
            if CanCast(spell.id, healer) and not IsDR("incapacitate", healer) then
                paralysisTarget = healer
                Debug("Healer found for Paralysis: " .. UnitName(healer))
            end
        end
    end

    -- If no paralysisTarget has been set yet, find an off-target enemy
    if not paralysisTarget then
        local enemies = OM:GetEnemies()
        for _, enemy in pairs(enemies) do
            local unitID = enemy.key
            -- Exclude the current target, healer, and dead units
            if UnitExists(unitID) and unitID ~= "target" and (not healer or unitID ~= healer) and not UnitIsDeadOrGhost(unitID) then
                if CanCast(spell.id, unitID) and not IsDR("incapacitate", unitID) then
                    paralysisTarget = unitID
                    Debug("Off-target found for Paralysis: " .. UnitName(unitID))
                    break  -- Exit loop after finding a valid target
                end
            end
        end
    end

    -- Attempt to cast Paralysis on the selected target
    if paralysisTarget then
        if spell:Cast(paralysisTarget) then
            Debug("Casting Paralysis on " .. UnitName(paralysisTarget))
            UpdateDR(paralysisTarget, "incapacitate")
        else
            Debug("Failed to cast Paralysis on " .. UnitName(paralysisTarget))
        end
    else
        Debug("No valid target found for Paralysis.")
    end
end)

-- Callback to cast Whirling Dragon Punch in burst windows
e.whirlingDragonPunch:Callback("combat", function(spell)
    if CanUseWhirlingDragonPunch() and ShouldBurst() then
        if spell:Cast() then
            Debug("Casting Whirling Dragon Punch.")
        end
    end
end)

-- Callback for Rising Sun Kick - maintain debuff uptime
e.risingSunKick:Callback("combat", function(spell)
    local hasAcclamation, acclamationDuration = HasAcclamationBuff("target")
    if not hasAcclamation or acclamationDuration < 3 then
        if spell:Cast("target") then
            Debug("Casting Rising Sun Kick to maintain debuff.")
        end
    end
end)

-- Update spearHandStrike Callback with Randomized Interrupt Logic
e.spearHandStrike:Callback("combat", function(spell)
    local enemies = OM:GetEnemies() -- Ensure 'enemies' is defined within the scope

    ObjectsLoop(enemies, function(enemy)
        if not shouldInterrupt(enemy) then
            return false
        end

        if e.spearHandStrike:Cast(enemy.unitID) then
            local unitName = "Unknown"
            if enemy.unitID and UnitExists(enemy.unitID) then
                unitName = UnitName(enemy.unitID)
            end
            Debug("Interrupted " .. unitName)
            Alert(116705, "Interrupted " .. unitName .. "!", GetAlertPosition())
            return true
        end
    end)
end)

-- Callback to cast Detox when needed during combat
e.detox:Callback("combat", function(spell)
    -- Check if Detox should be cast (i.e., if player has relevant debuffs)
    if ShouldCastDetox() then
        -- Attempt to cast Detox
        if spell:Cast() then
            Debug("Casting Detox to remove harmful debuffs.")
            return true  -- Exit after casting Detox to prioritize cleansing
        else
            Debug("Failed to cast Detox.")
        end
    else
        Debug("No Detox-able debuffs detected; skipping Detox.")
    end

    return false  -- Continue with other actions if Detox is not cast
end)

-- Function to use Ring of Peace to peel in PvP
local function UseRingOfPeaceForPeel()
    local enemies = OM:GetEnemies()
    if not enemies or #enemies == 0 then return end

    for _, enemy in ipairs(enemies) do
        -- Check for melee burst conditions
        if enemy.bursting and CanCast(116844, "player") then  -- 116844 is Ring of Peace spell ID
            CastSpellByID(116844, "player")  -- Cast Ring of Peace at player's location
            Debug("Using Ring of Peace to peel bursting melee.")
            return
        end
    end
end

-- Function to detect if a friendly unit is being attacked by melee with cooldowns
local function UseRingOfPeaceOnFriendly()
    -- Get all friends in range
    local friends = OM:GetFriends()
    
    -- Loop through each friendly player
    for _, friend in pairs(friends) do
        -- Check if the friend is alive and is a player
        if Alive(friend.key) and IsPlayer(friend.key) then
            -- Get attackers targeting this friend
            local meleeAttackers, _, _, cooldownAttackers = Attackers(friend.key)
            
            -- If there are melee attackers and any are in burst phase
            if meleeAttackers > 0 and cooldownAttackers > 0 then
                -- Loop through attackers
                for _, attacker in pairs(OM:GetEnemies()) do
                    -- Check if attacker is melee and bursting
                    if IsMelee(attacker.key) and Bursting(attacker.key) then
                        -- Cast Ring of Peace on the friends position
                        if CastGround(e.ringOfPeace.id, friend.key) then
                            Debug("Casting Ring of Peace to protect " .. Name(friend.key))
                            return true -- Exit once we cast on the first detected case
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Set up a repeating timer to check and use Ring of Peace for friends under attack every 0.5 seconds
C_Timer.NewTicker(0.5, UseRingOfPeaceOnFriendly)

-- Function to check if the target has any buffs from a given buff list
function BuffFrom(unit, buffList)
    for buffID, _ in pairs(buffList) do
        if HasBuff(buffID, unit) then
            return true
        end
    end
    return false
end

local disarmList = {
    [107574] = true, -- Avatar
    [184364] = true, -- Enraged Regeneration
    [1719] = true, -- Recklessness
    [307865] = true, -- Spear of Bastion
    [31884]  = true, -- Avenging Wrath
    [343527] = true, -- Execution Sentence
    [231895] = true, -- Crusade
    [343721] = true, -- Final Reckoning
    [49028]  = true, -- Dancing Rune Weapon
    [51271]  = true, -- Pillar of Frost
    [207289] = true, -- Unholy Assault
    [47568]  = true, -- Empower Rune Weapon
    [13750]  = true, -- Adrenaline Rush
    [79140]  = true, -- Vendetta
    [121471] = true, -- Shadow Blades
    [343142] = true, -- Flagellation
    [191427] = true, -- Metamorphosis
    [258860] = true, -- Essence Break
    [258925] = true, -- Fel Barrage
    [323639] = true, -- The Hunt
    [212084] = true, -- Fel Devastation
    [137639] = true, -- Storm, Earth, and Fire
    [123904] = true, -- Invoke Xuen, the White Tiger
    [114051] = true, -- Ascendance
    [51533]  = true, -- Feral Spirit
    [191634] = true, -- Stormkeeper
    [208963] = true, -- Skyfury Totem
}

-- Function to check if the target is a melee class or a hunter
local function IsMeleeOrHunter(enemy)
    local class = Class(enemy.key)
    return IsMelee(enemy.key) or class == "HUNTER"
end

-- Function to peel bursting enemies using Grapple Weapon and Ring of Peace
local function PeelBurstingEnemies()
    local enemies = OM:GetEnemies()
    if not enemies or #enemies == 0 then
        Debug("PeelBurstingEnemies: No enemies found.")
        return
    end

    for _, enemy in ipairs(enemies) do
        local unitID = enemy.key

        -- Validate the enemy unit
        if unitID and UnitExists(unitID) and not UnitIsUnit(unitID, "player") then
            if IsPlayer(unitID) and UnitCanAttack("player", unitID) then
            if IsMelee(unitID) or Class(unitID) == "HUNTER" then
                -- Use the built-in 'Bursting' function to check if the enemy is using offensive cooldowns
                if Bursting(unitID) then
                    Debug("PeelBurstingEnemies: Enemy " .. Name(unitID) .. " is bursting. Prioritizing Grapple Weapon.")
                    
                    -- Attempt to cast Grapple Weapon if the enemy is not immune to disarm
                    if CanCast(e.grappleWeapon.id, unitID) and not Immune(unitID, "disarm", true) then
                        if AttemptCast(e.grappleWeapon.id, unitID) then
                            Alert(e.grappleWeapon.id, "Disarming enemy with Grapple Weapon", GetAlertPosition())
                            Debug("Used Grapple Weapon to disarm " .. Name(unitID))
                        else
                            Debug("Failed to cast Grapple Weapon on " .. Name(unitID))
                        end
                    else
                        Debug("PeelBurstingEnemies: Grapple Weapon not available or enemy is immune.")
                    end

                    -- Attempt to cast Ring of Peace to control the enemy
                    if CanCast(e.ringOfPeace.id, "player") then
                        if AttemptCast(e.ringOfPeace.id, "player") then
                            Alert(e.ringOfPeace.id, "Using Ring of Peace for control", GetAlertPosition())
                            Debug("Used Ring of Peace to control melee or hunter enemy.")
                        else
                            Debug("PeelBurstingEnemies: Failed to cast Ring of Peace.")
                        end
                    end
                else
                    Debug("PeelBurstingEnemies: Enemy " .. Name(unitID) .. " is not bursting.")
                end
            end
        end
    end
end
end

local function CastCelestialConduit()
    local spellId = 443591  -- Replace with actual ID if different
    if CanCast(spellId, "target") then
        Cast(spellId, "target")
        Debug("Casting Celestial Conduit on target")
        return true
    end
    return false
end


local function EnemyHasOffensiveCooldown(unit)
    for buffID, buffName in pairs(enemyCooldowns) do
        if HasBuff(buffID, unit) then
            Debug("Detected enemy offensive cooldown: " .. buffName)
            return true
        end
    end
    return false
end

-- Line of Sight and Range Checks
local function CanAttackTarget(target)
    if not UnitExists(target) then
        Debug("Target does not exist: " .. tostring(target))
        return false
    end
    if not UnitIsVisible(target) then
        Debug("Target is not visible: " .. tostring(target))
        return false
    end
    if not InRange(target, 5) then
        Debug("Target is out of range: " .. tostring(target))
        return false
    end
    if not los("player", target) then
        Debug("No line of sight to target: " .. tostring(target))
        return false
    end
    return true
end

-- Enhanced ShouldBurst function with Healer CC Check and Double DPS Burst Logic
    local function ShouldBurst()
        local targetHealth = Health("target")
        local targetGUID = UnitGUID("target")
    
        -- Check if the target has any immunity or high-defense buffs using the central avoidAttackBuffs list
        if DontDMG("target") then
            return false  -- Avoid bursting if target has immunity or high avoidance buff
        end
        if isHealer then
            -- Define CC debuff types you want to check
            local ccDebuffs = { "stun", "root", "silence", "disorient" }
            local isHealerCCed = false
    
            -- Check each CC debuff type for the healer
            for _, ccType in ipairs(ccDebuffs) do
                if HasDebuff(ccType, healer) then
                    isHealerCCed = true
                    Debug("ShouldBurst triggered: Enemy healer (" .. UnitName(healer) .. ") is under " .. ccType .. " CC.")
                    break
                end
            end
    
            if isHealerCCed then
                return true  -- Burst if the enemy healer is in CC
            end
        else
            -- No healer detected, assume double DPS composition
            Debug("ShouldBurst: No enemy healer found, assuming double DPS.")
            return true  -- Burst immediately in double DPS scenarios
        end
    
        -- Burst condition: Target's health is low (below 30%)
        if targetHealth and targetHealth < 30 then
            Debug("ShouldBurst triggered: Target's health is below 30% (" .. targetHealth .. "%).")
            return true  -- Burst if the target's health is below 30%
        end
    
        -- Burst condition: Player has Storm, Earth, and Fire buff active
        if HasBuff(137639, "player") then  -- Storm, Earth, and Fire buff ID
            Debug("ShouldBurst triggered: Player has Storm, Earth, and Fire active.")
            return true  -- Burst if Storm, Earth, and Fire is active
        end
    
        Debug("ShouldBurst: No burst conditions met.")
        return false  -- Default to not bursting if none of the conditions are met
    end

-- Updated ApplySnare Function with Snare Immunity Check
local function ApplySnare()
    local target = "target"

    -- Skip applying Disable if the target is a boss
    if IsBoss(target) then
        Debug("ApplySnare skipped: target is a boss.")
        return
    end

    -- Check for snare immunity
    if DontDMG(target) then
        return
    end

    -- Attempt to cast Disable if possible
    if CanCast(116095, target) and not HasDebuff(116095, target) then
        if AttemptCast(116095, target) then
            Debug("Applied Disable to target.")
        else
            Debug("Failed to cast Disable on target.")
        end
    else
        if not CanCast(116095, target) then
            Debug("Cannot cast Disable on target; CanCast returned false.")
        elseif HasDebuff(116095, target) then
            Debug("Target already has Disable debuff.")
        end
    end
end

-- Updated Opener Function with Desired Sequence
local function Opener()
    -- 1. Cast Tiger's Palm
    if AttemptCast(100780, "target") then  -- Tiger's Palm
        Debug("Opener: Casting Tiger's Palm.")
        return
    else
        Debug("Opener: Failed to cast Tiger's Palm.")
    end

    -- 2. Cast Rising Sun Kick
    if AttemptCast(107428, "target") then  -- Rising Sun Kick
        Debug("Opener: Casting Rising Sun Kick.")
        return
    else
        Debug("Opener: Failed to cast Rising Sun Kick.")
    end

    -- 3. Cast Storm, Earth, and Fire
    if AttemptCast(137639, "target") then  -- Storm, Earth, and Fire
        Debug("Opener: Casting Storm, Earth, and Fire.")
        return
    else
        Debug("Opener: Failed to cast Storm, Earth, and Fire.")
    end

    -- 4. Cast Rising Sun Kick again to stack Acclamation
    if AttemptCast(107428, "target") then  -- Rising Sun Kick
        Debug("Opener: Casting Rising Sun Kick to stack Acclamation.")
        return
    else
        Debug("Opener: Failed to cast Rising Sun Kick for Acclamation.")
    end

    -- Cast Blackout Kick if "Blackout Kick!" proc is active
    if HasBlackoutKickBuff() and AttemptCast(100784, "target") then
        Debug("Opener: Casting Blackout Kick with 'Blackout Kick!' buff.")
        return
    end

    -- Use Whirling Dragon Punch if available
    if CanUseWhirlingDragonPunch() and AttemptCast(152175) then
        Debug("Opener: Casting Whirling Dragon Punch.")
        return
    end

    -- Cast Fists of Fury early in the opener
    if AttemptCast(113656, "target") then
        Debug("Opener: Casting Fists of Fury.")
        return
    end

    -- Continue with other opener abilities
    if AttemptCast(123904) then
        Debug("Opener: Casting Invoke Xuen.")
        return
    end
    if AttemptCast(322109, "target") then
        Debug("Opener: Casting Touch of Death.")
        return
    end
    if HasDanceOfChiJi() and AttemptCast(101546) then
        Debug("Opener: Casting Spinning Crane Kick with 'Dance of Chi-Ji' buff.")
        return
    end
    if CurrentChi() < MaxChi() and AttemptCast(100780, "target") then
        Debug("Opener: Casting Tiger Palm to generate Chi.")
        return
    end
    if AttemptCast(100784, "target") then
        Debug("Opener: Casting Blackout Kick as filler.")
        return
    end

-- Use Celestial Conduit at the end for maximum effect
if CanCast(443028) then  -- Spell ID for Celestial Conduit
    if AttemptCast(443028, "target") then
        Debug("Casting Celestial Conduit to fill downtime.")
    end
end
-- Cast Unity Within immediately after Celestial Conduit
if AttemptCast(443591, "target") then
    Debug("Sustained: Casting Unity Within immediately after Celestial Conduit.")
else
    Debug("Sustained: Failed to cast Unity Within after Celestial Conduit.")
end
end

-- Updated BurstRotation Function
local function BurstRotation()
    -- Use SEF to duplicate abilities
    if AttemptCast(137639) then
        Debug("Burst: Casting Storm, Earth, and Fire.")
        return
    end

    -- Ensure Rising Sun Kick is used to maintain or apply Acclamation
    local hasAcclamation, acclamationDuration = HasAcclamationBuff("target")
    if not hasAcclamation or acclamationDuration < 3 then
        if AttemptCast(107428, "target") then
            Debug("Burst: Casting Rising Sun Kick to apply or refresh Acclamation.")
            return
        end
    end

    -- Cast Blackout Kick if "Blackout Kick!" proc is active
    if HasBlackoutKickBuff() and AttemptCast(100784, "target") then
        Debug("Burst: Casting Blackout Kick with 'Blackout Kick!' buff.")
        return
    end

       -- Cast Whirling Dragon Punch if available
       if CanUseWhirlingDragonPunch() and e.whirlingDragonPunch:Cast() then
        Debug("Burst: Casting Whirling Dragon Punch.")
        return
    end


    -- Use Fists of Fury as a high priority
    if AttemptCast(113656, "target") then
        Debug("Burst: Casting Fists of Fury.")
        return
    end

    -- Celestial Conduit
    if CanCast(443028) then  -- Spell ID for Celestial Conduit
        if AttemptCast(443028, "target") then
            Debug("Casting Celestial Conduit to fill downtime.")
        end
    end
    -- Cast Unity Within immediately after Celestial Conduit
    if AttemptCast(443591, "target") then
        Debug("Sustained: Casting Unity Within immediately after Celestial Conduit.")
    else
        Debug("Sustained: Failed to cast Unity Within after Celestial Conduit.")
    end

    -- Continue with other burst abilities
    if AttemptCast(123904) then
        Debug("Burst: Casting Invoke Xuen.")
        return
    end
    if AttemptCast(392983, "target") then
        Debug("Burst: Casting Strike of the Windlord.")
        return
    end
       -- Use Spinning Crane Kick if Dance of Chi-Ji buff is active
       if HasDanceOfChiJi() and e.spinningCraneKick:Cast() then
        Debug("Burst: Casting Spinning Crane Kick with 'Dance of Chi-Ji' buff.")
        return
    end
    if CurrentChi() < MaxChi() and AttemptCast(100780, "target") then
        Debug("Burst: Casting Tiger Palm to generate Chi.")
        return
    end
    if AttemptCast(100784, "target") then
        Debug("Burst: Casting Blackout Kick as filler.")
        return
    end
end

-- Updated SustainedRotation Function
local function SustainedRotation()
    -- Use Storm, Earth, and Fire for sustained damage boost
    if CanCast(137639) then
        if AttemptCast(137639, "target") then
            Debug("Casting Storm, Earth, and Fire for sustained damage.")
            return
        end
    end

    -- Summon Xuen, the White Tiger to maintain DPS
    if CanCast(123904) then
        if AttemptCast(123904, "target") then
            Debug("Summoning Xuen for sustained rotation.")
            return
        end
    end

     -- Cast Whirling Dragon Punch if available
     if CanUseWhirlingDragonPunch() and e.whirlingDragonPunch:Cast() then
        Debug("Sustained: Casting Whirling Dragon Punch.")
        return
    end

    -- Use Fists of Fury as soon as its available
    if AttemptCast(113656, "target") then
        Debug("Sustained: Casting Fists of Fury.")
        return
    end

    -- Cast Blackout Kick if "Blackout Kick!" proc is active
    if HasBlackoutKickBuff() and AttemptCast(100784, "target") then
        Debug("Sustained: Casting Blackout Kick with 'Blackout Kick!' buff.")
        return
    end

    -- Use Strike of the Windlord when available for burst damage
    if CanCast(392983) then
        if AttemptCast(392983, "target") then
            Debug("Using Strike of the Windlord for sustained damage.")
            return
        end
    end

    -- Use Rising Sun Kick as a priority filler
    if AttemptCast(107428, "target") then
        Debug("Using Rising Sun Kick.")
        return
    end

     -- Use Spinning Crane Kick if Dance of Chi-Ji buff is active
    if HasDanceOfChiJi() and e.spinningCraneKick:Cast() then
        Debug("Sustained: Casting Spinning Crane Kick with 'Dance of Chi-Ji' buff.")
        return
    end

    -- Use Tiger Palm to generate Chi if below maximum
    if CurrentChi() < MaxChi() and AttemptCast(100780, "target") then
        Debug("Using Tiger Palm to generate Chi.")
        return
    end

   -- **Celestial Conduit** prioritized over Blackout Kick for downtime filler
if CanCast(443028) then  -- Spell ID for Celestial Conduit
    if AttemptCast(443028, "target") then
        Debug("Casting Celestial Conduit to fill downtime.")
    end
end
-- Cast Unity Within immediately after Celestial Conduit
if AttemptCast(443591, "target") then
    Debug("Sustained: Casting Unity Within immediately after Celestial Conduit.")
else
    Debug("Sustained: Failed to cast Unity Within after Celestial Conduit.")
end

    -- Use Blackout Kick as a lower-priority filler
    if AttemptCast(100784, "target") then
        Debug("Using Blackout Kick as filler.")
        return
    end
end

-- PvP Logic using the Elite framework
local function PvPLogic()
    -- Utility actions - checking to auto-loot corpses in battlegrounds or arenas
    if InPvp() and not InCombat() then
        AutoLootCorpses()
        Debug("Auto-looting corpses.")
    end
end
-- Initialize flags
local isInCombat = false
local isInArena = false
local isInArenaPrep = false

-- Event Frame Setup with Enhanced Tracking
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
eventFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")

-- Event Handler with Enhanced Tracking
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        if isInArena and isInArenaPrep then
            -- Combat has officially started after arena prep
            isInArenaPrep = false
            Debug("Arena combat has started.")
        else
            -- Regular combat
            isInCombat = true
            Debug("Entered Combat.")
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        outCombat()
        Debug("Exited Combat.")
    elseif event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
        isInArena = true
        isInArenaPrep = true
        Debug("Arena Preparation Phase Started.")
    elseif event == "ARENA_OPPONENT_UPDATE" then
        -- Additional arena-specific logic can be added here if needed
    end
end)

-- Variable to track if the opener has been used
local openerUsed = false

-- THE MAIN BRAIN
local function Main()
    -- Check if the rotation is enabled via the button; exit if not
    if not erButton.isEnabled then
        return
    end

    -- Check if the player is in combat; exit if not
    if not InCombat("player") then
        return
    end

    -- Prevent rotation when no target is selected
    if not UnitExists("target") or not UnitCanAttack("player", "target") then
        Debug("No valid target selected. Rotation paused.")
        return
    end

    -- Prevent rotation during arena preparation phase
    if Prep() then
        Debug("In preparation phase. Rotation paused.")
        return
    end
    
    if Locked() then
        Debug("Player is under crowd control; rotation paused.")
        return
    end
    -- Invoke UseTigersLust Early in the Rotation
    if UseTigersLust() then
        -- If Tiger's Lust was successfully cast, prioritize movement restoration
        return
    end

    -- Check and Cast Detox if Needed
    if ShouldCastDetox() then
        if e.detox:Cast() then
            Debug("Casting Detox to remove harmful debuffs.")
            return  -- After casting Detox, prioritize other actions
        else
            Debug("Failed to cast Detox.")
        end
    end

    -- Prioritize Touch of Death Casting
    PrioritizeTouchOfDeath()

    -- PvP vs. PvE Logic
    if InPvp() then
        -- In PvP: Control enemy healer with diminishing returns (DR)
        ControlHealerWithDR()
    end

    -- Execute Opener Sequence if it hasn't been used yet
    if not openerUsed then
        Opener()
        openerUsed = true
        Debug("Opener Sequence Executed.")
    end

    -- Cast Celestial Conduit if it hasn't been cast yet
    if not celestialConduitLastCast then
        celestialConduitLastCast = CastCelestialConduit()
        if celestialConduitLastCast then
            Debug("Celestial Conduit Casted.")
        end
    end

    -- Handle Keybinds for Roll and Flying Serpent Kick
    CheckKeybinds()

    -- Execute Interrupt Logic Here
    InterruptLogic()

    -- Big LegSweep
    HandleLegSweep()

    ApplySnare()
    -- Additional PvP Logic
    if InPvp() then
        PvPLogic()
        UseRingOfPeaceForPeel()
    end

    -- Use Defensive Abilities if Auto Defense is Enabled and Conditions are Met
    if Builder:GetConfig("enableAutoDefense", "yes") == "yes" then
        UseDefensives()
    end

    -- Peel Bursting Enemies using Grapple Weapon and Ring of Peace
    PeelBurstingEnemies()

    -- Manage Totems and PvP Objects Stomping
    if Builder:GetConfig("enableAutoStomp", "yes") == "yes" then
        runTotemStomp()
    end

    -- Determine and Execute Appropriate Rotation
    if ShouldBurst() then
        BurstRotation()  -- Execute Burst Rotation
    else
        SustainedRotation()  -- Execute Sustained Rotation
    end
end

-- Set up a repeating timer to execute Main() at regular intervals
if not mainTicker then
    mainTicker = C_Timer.NewTicker(0.1, Main)
end

-- Reset combat and arena flags upon exiting combat or arena
function outCombat()
    openerUsed = false
    celestialConduitLastCast = false
    flyingSerpentKickQueued = false
    isInArena = false
    isInArenaPrep = false
    Debug("Combat and Arena flags reset.")
end

-- Register combat functions with Elite
Elite.inCombat = Main
Elite.outCombat = outCombat 
