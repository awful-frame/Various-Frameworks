local Tinkr = ...
local blink = { routines = {}, svshx = true }
local namespace = {}
local HTTP2 = Tinkr.Util.HTTP2
local File = Tinkr.Util.File
local Json = Tinkr.Util.JSON
local Evaluator = Tinkr.Util.Evaluator
local AES = Tinkr.Util.Crypto.AES
local Common = Tinkr.Common
local fileCache = {}
blink.DevMode = false

--_G.BLINKX69420 = blink
_G.BLINKX65188881 = blink

--predefine auras locally
_G.UnitAura = function(unitToken, index, filter)
  local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter)
  if not auraData then
    return nil
  end

  return AuraUtil.UnpackAuraData(auraData)
end
_G.UnitBuff = function(unitToken, index, filter)
  local auraData = C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter)
  if not auraData then
    return nil
  end

  return AuraUtil.UnpackAuraData(auraData)
end
_G.UnitDebuff = function(unitToken, index, filter)
  local auraData = C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter)
  if not auraData then
    return nil
  end

  return AuraUtil.UnpackAuraData(auraData)
end


local CONFIG = {
    authUrl = "https://sadrotations.com/authenticate.php",
    presignedUrlEndpoint = "https://sadrotations.com/auth-vone/aws-sdk/generate_presigned_url.php",
    configFile = "blink-config.json",
    credentialsPath = "scripts/SadRotations/SavedCredentials"
}

local allFiles = {
    "dependencies.lua",
    "lib/base64.lua",
    "interface/alerts/animations.lua",
    "interface/alerts/alerts.lua",
    "utils/debug.lua",
    "utils/lists.lua",
    "utils/auras.lua",
    "utils/unit.lua",
    "utils/List.lua",
    "utils/combatlog.lua",
    "utils/objects.lua",
    "utils/macros.lua",
    "utils/nav.lua",
    "utils/helpers.lua",
    "utils/Spell.lua",
    "utils/Actor.lua",
    "utils/dragons.lua",
    "interface/gui/gui.lua",
    "interface/delaunay.lua",
    "interface/drawings.lua",
    "utils/interrupts.lua",
    "utils/go/comms.lua",
    "utils/tick.lua",
    "utils/fun.lua",
    "routines/sadrotations/sadrotations.lua",
    "routines/sadrotations/gui.lua",
    "routines/sadrotations/srdraw.lua",
    "routines/sadrotations/hunter/hunter.lua",
    "routines/sadrotations/hunter/bm-actor.lua",
    "routines/sadrotations/hunter/spells/bm-spells.lua",
    "routines/sadrotations/hunter/sv-actor.lua",
    "routines/sadrotations/hunter/spells/sv-spells.lua",
    "routines/sadrotations/hunter/mm-actor.lua",
    "routines/sadrotations/hunter/spells/mm-spells.lua",
    "routines/sadrotations/druid/druid.lua",
    "routines/sadrotations/druid/feral/dot-tracker.lua",
    "routines/sadrotations/druid/feral/feral-actor.lua",
    "routines/sadrotations/druid/feral/feral-spells.lua",
    "routines/sadrotations/rogue/rogue.lua",
    "routines/sadrotations/rogue/assa/assa-actor.lua",
    "routines/sadrotations/rogue/assa/assa-spells.lua",
    "routines/sadrotations/rogue/sub/sub-actor.lua",
    "routines/sadrotations/rogue/sub/sub-spells.lua",
    "routines/sadrotations/paladin/paladin.lua",
    "routines/sadrotations/paladin/ret-actor.lua",
    "routines/sadrotations/paladin/ret-spells.lua",
    "routines/sadrotations/priest/priest.lua",
    "routines/sadrotations/priest/disc-actor.lua",
    "routines/sadrotations/priest/disc-spells.lua",
    "routines/sadrotations/priest/holy-actor.lua",
    "routines/sadrotations/priest/holy-spells.lua",
    "routines/sadrotations/warrior/warrior.lua",
    "routines/sadrotations/warrior/arms-actor.lua",
    "routines/sadrotations/warrior/arms-spells.lua",
    "routines/sadrotations/shaman/shaman.lua",
    "routines/sadrotations/shaman/ele-actor.lua",
    "routines/sadrotations/shaman/ele-spells.lua",
}

blink.print = function(txt, bad, version)
    print("|cFFFFFFFFB|cFFE6F6F6l|cFF99D9D9i|cFF99D9D9n|cFF00FFFFk" 
    .. (version and " v" .. APIVersion or "") .. ":|r|r|r|r|r|r|r",
    (bad ~= "init" and (bad and "|cFF99D9D9" or "|cFF99D9D9") or "") .. txt)
end

if not IsInGame() then return end

local serializable = {
    table = true,
    number = true,
    string = true,
    boolean = true
}

local iv = "mgzu1toOosKHALed"
local key = "AUPhZQmgzu1toOosyueIjQCKFSyQvGV5"
local format, rep, tonumber = string.format, string.rep, tonumber

local function serialize(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or true
    depth = depth or 0

    local vtype = type(val)
    if not serializable[vtype] then return "" end

    local tmp = rep(" ", depth)
    local n2n = tonumber(name)

    if n2n then
        tmp = tmp .. "[" .. name .. "]="
    elseif name then
        if not tonumber(name:sub(1, 1)) and not name:match("%W") then
            tmp = tmp .. name .. "="
        else
            tmp = tmp .. '["' .. name .. '"]='
        end
    end

    if vtype == "table" then
        tmp = tmp .. "{"
        local first = true
        for k, v in pairs(val) do
            if not first then tmp = tmp .. "," end
            local subserialize = serialize(v, k, skipnewlines, depth + 2)
            if subserialize ~= "" then
                tmp = tmp .. subserialize
                first = false
            end
        end
        tmp = tmp .. "}"
    elseif vtype == "number" then
        tmp = tmp .. tostring(val)
    elseif vtype == "string" then
        tmp = tmp .. format("%q", val)
    elseif vtype == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    end

    return tmp
end

blink.serializebasic = serialize

local ConfigsToSync = {}
local last_config

local function deepCompare(table1, table2)
    if table1 == table2 then return true end
    if type(table1) ~= "table" or type(table2) ~= "table" then return false end

    for key, val in pairs(table1) do
        if not deepCompare(val, table2[key]) then return false end
    end

    for key, val in pairs(table2) do
        if not deepCompare(val, table1[key]) then return false end
    end

    return true
end

local configDir = 'scripts/SadRotations'
local configFile = configDir .. '/config'

if not DirectoryExists(configDir) then
    local success = CreateDirectory(configDir)
    if not success then
        blink.print("Failed to create the SadRotations directory.")
        return
    end
end

local function ResetConfig()
    if type(last_config) == "table" then
        local serializedConfig = "return " .. serialize(last_config)
        local encryptedConfig = AES:Encrypt(serializedConfig, key, iv)
        WriteFile(configFile, encryptedConfig, false)
        return encryptedConfig
    else
        --blink.print("Config file doesn't exist or is corrupted.", true)
        local encryptedEmptyConfig = AES:Encrypt("return {}", key, iv)
        WriteFile(configFile, encryptedEmptyConfig, false)
        return encryptedEmptyConfig
    end
end

local function SafeDecrypt(input, key, iv)
    local status, result = pcall(function() return AES:Decrypt(input, key, iv) end)
    if status then
        return result
    else
        blink.print("Decryption failed. Resetting the configuration.", true)
        return nil
    end
end

local function SyncConfigs(self, ShouldClear)
    local encryptedConfigRAW = ReadFile(configFile)
    if not encryptedConfigRAW then encryptedConfigRAW = ResetConfig() end

    local configRAW = SafeDecrypt(encryptedConfigRAW, key, iv)
    if not configRAW then configRAW = ResetConfig() end

    local configFunc = loadstring(configRAW)
    local config = type(configFunc) == "function" and configFunc() or {}

    for i = 1, 5 do
        if not config or type(config) ~= "table" then
            config = configFunc()
            if config and type(config) == "table" then break end
            if i == 5 then
                ResetConfig()
                config = {}
            end
        end
    end

    for _, thisConfigContainer in ipairs(ConfigsToSync) do
        local thisConfig, name, getQueue, clearQueue = unpack(thisConfigContainer)
        local queued = getQueue()

        if not config[name] then config[name] = {} end

        for key in pairs(thisConfig) do
            if not config[name][key] then thisConfig[key] = nil end
        end

        for key, val in pairs(queued) do
            if val == "nil" then
                config[name][key] = nil
            else
                config[name][key] = val
            end
        end

        clearQueue()
    end

    if ShouldClear then config[ShouldClear] = {} end

    if not last_config or not deepCompare(last_config, config) then
        local newConfigSerialized = "return " .. serialize(config)
        local encryptedConfig = AES:Encrypt(newConfigSerialized, key, iv)
        WriteFile(configFile, encryptedConfig, false)
        last_config = config
    end
end

blink.serialize = serialize

blink.NewConfig = function(name, SuperSecretPasscode)
    if type(name) ~= "string" then return {} end

    if name:lower() == "blink" and SuperSecretPasscode ~= "FART" then return {} end

    local encryptedConfigRAW = ReadFile(configFile)
    if not encryptedConfigRAW then
        WriteFile(configFile, AES:Encrypt("return {}", key, iv), false)
        encryptedConfigRAW = ReadFile(configFile)
    end

    if not encryptedConfigRAW then
        blink.print("Trouble reading SadRotations Config. Please try reinstalling.")
        return false
    end

    local configRAW = SafeDecrypt(encryptedConfigRAW, key, iv)
    if not configRAW then configRAW = ResetConfig() end

    local configFunc = loadstring(configRAW)
    local config = type(configFunc) == "function" and configFunc() or {}

    for i = 1, 5 do
        if not config or type(config) ~= "table" then
            config = configFunc()
            if config and type(config) == "table" then break end
            if i == 5 then
                blink.print("Config file is corrupted. Creating a new Config file!", true)
                config = {}
            end
        end
    end

    local data = {}
    if config[name] then
        for k, v in pairs(config[name]) do data[k] = v end
    end

    local internal = { name = name, queued = {} }

    local copy = data
    data = {}
    local changedEvent
    local meta = {
        __index = function(self, key)
            if key == "OnConfigChange" then
                local connection = {}
                function connection:Connect(embeddedFunction)
                    changedEvent = embeddedFunction
                end
                return connection
            end
            return copy[key]
        end,
        __newindex = function(self, key, value)
            copy[key] = value
            changedEvent(key, value)
        end
    }
    setmetatable(data, meta)

    local thisConfig = data
    thisConfig.OnConfigChange:Connect(function(key, val)
        internal.queued[key] = val == nil and "nil" or val
    end)

    table.insert(ConfigsToSync, {
        thisConfig,
        internal.name,
        function() return internal.queued end,
        function() internal.queued = {} end,
        function() SyncConfigs(nil, internal.name) end
    })

    return thisConfig
end

SyncConfigs()
C_Timer.NewTicker(2, SyncConfigs)

blink.saved = blink.NewConfig("blink", "FART")
blink.Routine = Tinkr:require('Routine.Modules.Exports')


local authState = { isAuthenticated = false }

local function loadSavedCredentials()
    if File:Exists(CONFIG.credentialsPath) then
        local encryptedContent = File:Read(CONFIG.credentialsPath)
        local decryptedContent = SafeDecrypt(encryptedContent, key, iv)
        if decryptedContent then
            local username, password = strsplit("\n", decryptedContent)
            return username, password
        else
            blink.print("Failed to decrypt SavedCredentials.", true)
            return "", ""
        end
    end
    return "", ""
end

local function saveCredentials(username, password)
    local content = username .. "\n" .. password
    local encryptedContent = AES:Encrypt(content, key, iv)
    if encryptedContent then
        File:Write(CONFIG.credentialsPath, encryptedContent, false)
        --blink.print("Credentials encrypted and saved.")
    else
        blink.print("Failed to encrypt credentials.", true)
    end
end


local function getPresignedUrl(filePath, callback)
    local postData = "objectKey=" .. filePath
    HTTP2:Request({
        url = CONFIG.presignedUrlEndpoint,
        method = "POST",
        body = postData,
        headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        callback = function(status, response)
            if status == 200 and response then
                local presignedUrlData = Json:Decode(response)
                if presignedUrlData and presignedUrlData.url then
                    callback(presignedUrlData.url)
                else
                    -- Generalized error message
                    blink.print("Error: Unable to retrieve file URL. Please try again or /reload.")
                    callback(nil)
                end
            else
                -- Generalized error message
                blink.print("Error: Network issue or server error while fetching file URL.")
                callback(nil)
            end
        end
    })
end

local function preloadFiles(filesToPreload, callback)
    local pendingFiles = #filesToPreload
    local missingFiles = {}  -- Track missing or failed files

    for _, filePath in ipairs(filesToPreload) do
        getPresignedUrl(filePath, function(presignedUrl)
            if presignedUrl then
                HTTP2:Request({
                    url = presignedUrl,
                    method = "GET",
                    callback = function(status, content)
                        if status == 200 and content then
                            fileCache[filePath] = content
                        else
                            -- Log failed fetch without exposing file path
                            table.insert(missingFiles, filePath)
                            if blink.DevMode then
                                blink.print("Debug: Failed to fetch file. Check server or integrity.")
                            else
                                blink.print("Error: Unable to load some required files.")
                            end
                        end
                        pendingFiles = pendingFiles - 1
                        if pendingFiles == 0 then callback(missingFiles) end
                    end
                })
            else
                -- Log missing URL without exposing file path
                table.insert(missingFiles, filePath)
                if blink.DevMode then
                    blink.print("Debug: Presigned URL missing for a file. Investigate server or config.")
                else
                    blink.print("Error: Unable to load some required files.")
                end
                pendingFiles = pendingFiles - 1
                if pendingFiles == 0 then callback(missingFiles) end
            end
        end)
    end
end

local function executeWithInjectedGlobals(content, filePath)
    if not content or content == "" then
        -- Generalized error message
        blink.print("Error: Unable to load required content. Please contact support.")
        return false
    end

    local func, loadError = loadstring(content, filePath)
    if not func then
        -- Generalized error message
        if blink.DevMode then
            blink.print("Debug: Error loading function for file. Load error: " .. tostring(loadError))
        else
            blink.print("Error: Content load failure detected.")
        end
        return false
    end

    Tinkr.Util.Evaluator:InjectGlobals(func)
    if type(func) == "function" then
        local status, execError = pcall(func, Tinkr, blink, namespace)
        if not status then
            -- Generalized error message
            if blink.DevMode then
                blink.print("Debug: Execution error in file. Error: " .. tostring(execError))
            else
                blink.print("Error: Execution failure detected.")
            end
            return false
        end
        return true
    else
        -- Generalized error message
        blink.print("Error: Invalid content format. Please contact support.")
        return false
    end
end

local function loadFilesFromCache(filesToLoad, callback)
    for _, filePath in ipairs(filesToLoad) do
        local content = fileCache[filePath]
        if content then
            executeWithInjectedGlobals(content, filePath)
        else
            -- Generalized error message
            if blink.DevMode then
                blink.print("Debug: File not found in cache: " .. filePath)
            else
                blink.print("Error: Required files are missing or corrupted.")
            end
        end
    end
    callback()
end

local function loadFilesStrictlySequential(presignedUrls, filesToLoad, callback)
    local function loadNextFile(index)
        if index > #filesToLoad then
            blink.print("All files loaded successfully.")
            if callback then callback(true) end
            return
        end

        local filePath = filesToLoad[index]
        local presignedUrl = presignedUrls[filePath]

        if not presignedUrl then
            -- Generalized error message
            if blink.DevMode then
                blink.print("Debug: Skipping file due to missing URL: " .. filePath)
            else
                blink.print("Error: Unable to load some files. Please contact support.")
            end
            loadNextFile(index + 1)
            return
        end

        HTTP2:Request({
            url = presignedUrl,
            method = "GET",
            callback = function(status, content)
                if status == 200 and content then
                    local success = executeWithInjectedGlobals(content, filePath)
                    if not success and blink.DevMode then
                        blink.print("Debug: Execution failed for file.")
                    end
                else
                    -- Generalized error message
                    if blink.DevMode then
                        blink.print("Debug: Failed to fetch file. Status: " .. tostring(status))
                    else
                        blink.print("Error: Unable to fetch required files. Please contact support.")
                    end
                end

                loadNextFile(index + 1)
            end
        })
    end

    loadNextFile(1)
end


local function prefetchPresignedUrls(filesToLoad, callback)
    local presignedUrls = {}
    local pendingUrls = #filesToLoad

    for _, filePath in ipairs(filesToLoad) do
        getPresignedUrl(filePath, function(presignedUrl)
            if presignedUrl then
                presignedUrls[filePath] = presignedUrl
            else
                blink.print("Failed to get pre URL for: " .. filePath)
            end

            pendingUrls = pendingUrls - 1
            if pendingUrls == 0 then
                callback(presignedUrls)
            end
        end)
    end
end

local function loadFilesByProduct(productName)
    local frameworkFiles = {
        "dependencies.lua",
        "lib/base64.lua",
        "interface/alerts/animations.lua",
        "interface/alerts/alerts.lua",
        "utils/debug.lua",
        "utils/lists.lua",
        "utils/auras.lua",
        "utils/unit.lua",
        "utils/List.lua",
        "utils/combatlog.lua",
        "utils/objects.lua",
        "utils/macros.lua",
        "utils/nav.lua",
        "utils/helpers.lua",
        "utils/Spell.lua",
        "utils/Actor.lua",
        "utils/dragons.lua",
        "interface/gui/gui.lua",
        "interface/delaunay.lua",
        "interface/drawings.lua",
        "utils/interrupts.lua",
        "utils/go/comms.lua",
        "utils/tick.lua",
        "utils/fun.lua"
    }

    local suiteFiles = {
        "routines/sadrotations/sadrotations.lua",
        "routines/sadrotations/gui.lua",
        "routines/sadrotations/srdraw.lua",
        "routines/sadrotations/hunter/hunter.lua",
        "routines/sadrotations/hunter/bm-actor.lua",
        "routines/sadrotations/hunter/spells/bm-spells.lua",
        "routines/sadrotations/hunter/sv-actor.lua",
        "routines/sadrotations/hunter/spells/sv-spells.lua",
        "routines/sadrotations/hunter/mm-actor.lua",
        "routines/sadrotations/hunter/spells/mm-spells.lua",
        "routines/sadrotations/druid/druid.lua",
        "routines/sadrotations/druid/feral/dot-tracker.lua",
        "routines/sadrotations/druid/feral/feral-actor.lua",
        "routines/sadrotations/druid/feral/feral-spells.lua",
        "routines/sadrotations/rogue/rogue.lua",
        "routines/sadrotations/rogue/assa/assa-actor.lua",
        "routines/sadrotations/rogue/assa/assa-spells.lua",
        "routines/sadrotations/rogue/sub/sub-actor.lua",
        "routines/sadrotations/rogue/sub/sub-spells.lua",
        "routines/sadrotations/paladin/paladin.lua",
        "routines/sadrotations/paladin/ret-actor.lua",
        "routines/sadrotations/paladin/ret-spells.lua",
        "routines/sadrotations/priest/priest.lua",
        "routines/sadrotations/priest/disc-actor.lua",
        "routines/sadrotations/priest/disc-spells.lua",
        "routines/sadrotations/priest/holy-actor.lua",
        "routines/sadrotations/priest/holy-spells.lua",
        "routines/sadrotations/warrior/warrior.lua",
        "routines/sadrotations/warrior/arms-actor.lua",
        "routines/sadrotations/warrior/arms-spells.lua",
        "routines/sadrotations/shaman/shaman.lua",
        "routines/sadrotations/shaman/ele-actor.lua",
        "routines/sadrotations/shaman/ele-spells.lua",
    }

    local hunterRoutineFiles = {
        "routines/sadrotations/sadrotations.lua",
        "routines/sadrotations/gui.lua",
        "routines/sadrotations/srdraw.lua",
        "routines/sadrotations/hunter/hunter.lua",
        "routines/sadrotations/hunter/bm-actor.lua",
        "routines/sadrotations/hunter/spells/bm-spells.lua",
        "routines/sadrotations/hunter/sv-actor.lua",
        "routines/sadrotations/hunter/spells/sv-spells.lua",
        "routines/sadrotations/hunter/mm-actor.lua",
        "routines/sadrotations/hunter/spells/mm-spells.lua"
    }

    local filesToLoad = {}
    if productName == "Sad Rotations Suite Retail" then
        for _, file in ipairs(frameworkFiles) do
            table.insert(filesToLoad, file)
        end
        for _, file in ipairs(suiteFiles) do
            table.insert(filesToLoad, file)
        end
    elseif productName == "Sad Rotations Hunter Bundle Retail" then
        for _, file in ipairs(frameworkFiles) do
            table.insert(filesToLoad, file)
        end
        for _, file in ipairs(hunterRoutineFiles) do
            table.insert(filesToLoad, file)
        end
    else
        blink.print("No valid product found for conditional loading.")
        return
    end

    loadFilesFromCache(filesToLoad, function()
        --blink.print("All files loaded.." .. productName)
    end)
end

local function authenticateUser(username, password, callback)
    local hwid = GetHWID()
    local postData = "username=" .. username .. "&password=" .. password .. "&hwid=" .. hwid

    local callbackInvoked = false  -- Track if callback has been called to prevent duplicate prints

    HTTP2:Request({
        url = CONFIG.authUrl,
        method = "POST",
        body = postData,
        headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        callback = function(status, response)

            if callbackInvoked then return end  -- Ensure callback is called only once

            if status == 200 then
                authState.isAuthenticated = true
                local isAdmin = response:match("Authenticated as administrator") ~= nil
                local isSubscriber = response:match("Authenticated as subscriber") ~= nil
                local isBanned = response:match("User is banned") ~= nil
                local hwidMismatch = response:match("HWID mismatch") ~= nil
                local productName = response:match("Product Name: (.-)\n")
                local timeLeft = response:match("Subscription Remaining: (.-)$")

                if isBanned then
                    print("|cFFf74a4aAccess Denied:|r Your account is banned.")
                    callbackInvoked = true
                    callback(false, response)
                    return
                end

                -- Apply HWID lock only if user is not an admin
                if hwidMismatch and not isAdmin then
                    print("|cFFf74a4aHWID Mismatch:|r The hardware ID does not match our records.")
                    callbackInvoked = true
                    callback(false, response)
                    return
                end

                if timeLeft == "Expired" then
                    print("|cFFf74a4aSubscription expired.|r Please renew your subscription.")
                    callbackInvoked = true
                    callback(false, response)
                    return
                end

                blink.DevMode = isAdmin or false
                if isAdmin then
                    print("|cFF99D9D9Developer Mode:|r Enabled.")
                end

                if (isAdmin or isSubscriber) and productName and timeLeft then
                    print("|cFF99D9D9Product Name:|r " .. productName)
                    print("|cFF99D9D9Subscription Remaining:|r " .. timeLeft)
                    loadFilesByProduct(productName)
                else
                    blink.print("Error: Product details not found.")
                end

                callbackInvoked = true
                callback(true, response)
            else
                local errorMsg = "|cFF99D9D9[SadRotations]:|r Authentication failed."
                if status == 401 or status == 400 then
                    errorMsg = "|cFF99D9D9[SadRotations]:|r Invalid username or password."
                elseif status == 403 then
                    if response:find("Subscription expired") then
                        errorMsg = "|cFFf74a4aSubscription expired,|r Please renew your subscription."
                    elseif response:find("User is banned") then
                        errorMsg = "|cFFf74a4aAccess Denied:|r Your account is banned."
                    elseif response:find("HWID mismatch") then
                        errorMsg = "|cFFf74a4aHWID Mismatch:|r The hardware ID does not match our records."
                    end
                end

                print(errorMsg)
                callbackInvoked = true
                callback(false, response)
            end
        end
    })
end

-- Set defaults for frame size
local frameWidth, frameHeight = 300, 200

-- Helper function to create labels with white text
local function createLabel(parent, text, offsetX, offsetY)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(text)
    label:SetTextColor(1, 1, 1, 1)  -- Set text color to white
    label:SetPoint("TOP", parent, "TOP", offsetX, offsetY)
    return label
end

-- Helper function to create input boxes
local function createInputBox(parent, offsetX, offsetY, isPassword)
    local inputBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    inputBox:SetSize(150, 30)
    inputBox:SetPoint("TOP", parent, "TOP", offsetX, offsetY)
    if isPassword then inputBox:SetPassword(true) end
    return inputBox
end

-- Main function to create the Login GUI
local function createLoginGUI()
    local frame = CreateFrame("Frame", "Blink_LoginFrame", UIParent, "BackdropTemplate")
    frame:SetSize(frameWidth, frameHeight)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true, edgeSize = 3,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0.1, 0.1, 0.1, 0.9)  -- Dark border color

    frame.title = createLabel(frame, "SadRotations Login", 0, -10)
    frame.title:SetFontObject("GameFontHighlight")

    -- Username and Password labels and input fields
    frame.usernameLabel = createLabel(frame, "Username:", -90, -43)
    frame.usernameEditBox = createInputBox(frame, 25, -35, false)
    frame.passwordLabel = createLabel(frame, "Password:", -90, -80)
    frame.passwordEditBox = createInputBox(frame, 25, -72, true)

    -- Save Credentials Checkbox
    frame.saveCredentialsCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.saveCredentialsCheckbox:SetPoint("TOP", frame.passwordEditBox, "BOTTOM", -65, -1)
    frame.saveCredentialsCheckbox.text:SetText("Save Credentials")
    frame.saveCredentialsCheckbox.text:SetTextColor(1, 1, 1, 1)  -- Set checkbox text color to white

    -- Load saved credentials if available
    local savedUsername, savedPassword = loadSavedCredentials()
    frame.usernameEditBox:SetText(savedUsername)
    frame.passwordEditBox:SetText(savedPassword)
    frame.saveCredentialsCheckbox:SetChecked(savedUsername ~= "" and savedPassword ~= "")

    -- Login button
    frame.submitButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    frame.submitButton:SetSize(100, 30)
    frame.submitButton:SetText("Login")
    frame.submitButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 8)

    -- Exit button
    local f = frame
    f.exit = CreateFrame("BUTTON", '', f)
    f.exitCircle = f:CreateTexture('fexitbttn', "OVERLAY")
    f.exitCircle:SetTexture(C_Spell.GetSpellTexture(118))
    f.exitCircle:SetWidth(6)
    f.exitCircle:SetHeight(6)
    f.exitCircle:SetColorTexture(1, 82/255, 82/255, 1)
    f.exitCircle:SetPoint("TOPRIGHT", f, "TOPRIGHT", -13, -13)

    f.exitCircleMask = f:CreateMaskTexture()
    f.exitCircleMask:SetAllPoints(f.exitCircle)
    f.exitCircleMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    f.exitCircle:AddMaskTexture(f.exitCircleMask)

    f.exit:SetAlpha(0)
    f.exit:SetSize(20,20)
    f.exit:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    f.exit:RegisterForClicks("AnyUp")
    f.exit:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
    f.exit:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
    f.exit:SetScript("OnClick", function() f:Hide() end)
    f.exit:SetScript("OnEnter", function() f.exitCircle:SetColorTexture(1, 125/255, 125/255, 1) end)
    f.exit:SetScript("OnLeave", function() f.exitCircle:SetColorTexture(1, 82/255, 82/255, 1) end)

    -- Login button click handler
    frame.submitButton:SetScript("OnClick", function()
        local username = frame.usernameEditBox:GetText()
        local password = frame.passwordEditBox:GetText()
        -- Disable the login button to prevent multiple clicks
        frame.submitButton:SetEnabled(false)
        authenticateUser(username, password, function(success)
            if success then
                --blink.print("Authentication successful!")
                if frame.saveCredentialsCheckbox:GetChecked() then
                    saveCredentials(username, password)
                end
                frame:Hide()
            else
                print("|cFF99D9D9[SadRotations]: |rAuthentication failed.")
                frame.submitButton:SetEnabled(true)
            end
        end)
    end)

    frame:Show()
end

blink.print("Loading SadRotations...")

preloadFiles(allFiles, function(missingFiles)
    if #missingFiles > 0 then
        -- General error message without exposing file names
        blink.print("|cFFFF0000SadRotations:|r Unable to load some required files. This may be due to network issues or corrupted files. Please try again or contact support.")
        
        -- Optionally, log details to a debug system (if available) for admins
        if blink.DevMode then
            blink.print("Debug Info: Missing files detected. Check server or file integrity.")
        end

        return  -- Do not load GUI if there are missing files
    end

    if not authState.isAuthenticated then
        blink.print("Login with your SadRotation Credentials.")
        createLoginGUI()
    end
end)
