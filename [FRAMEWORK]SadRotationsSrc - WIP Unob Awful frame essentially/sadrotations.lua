local Unlocker, blink, sr = ...
local player, target, focus, healer = blink.player, blink.target, blink.focus, blink.healer
local onEvent = blink.addEventCallback
local bin, onUpdate = blink.bin, blink.addUpdateCallback
local BlinkFont, BlinkFontLarge = blink.createFont(8, "OUTLINE"), blink.createFont(16)
local saved = sr.saved
local colors = blink.colors
local alert = blink.alert
local colors = blink.colors
local enemy = blink.enemy
local fhealer = blink.healer
local enemyHealer = blink.enemyHealer
local bin = blink.bin
local enemyPets = blink.enemyPets
local autoFocus = blink.AutoFocus
local delay = blink.delay(0.4, 0.7)

sr.CastSpellByName = blink.unlock("CastSpellByName")
sr.CastSpellByID = blink.unlock("CastSpellByID")

-- blink.DevMode = true

local cmd = blink.Command({"sr", "spit", "love", "laugh", "tomtom"}, true)

sr.cmd = cmd

local class = player.class2
local spec = player.spec2


sr.hunter = {}
sr.druid = {}
sr.rogue = {}
sr.paladin = {}
sr.priest = {}
sr.warrior = {}
sr.shaman = {}

--hunter
sr.hunter.ready = class == "HUNTER"
sr.hunter.bm = blink.Actor:New({ spec = 1, class = "hunter" })
sr.hunter.mm = blink.Actor:New({ spec = 2, class = "hunter" })
sr.hunter.sv = blink.Actor:New({ spec = 3, class = "hunter" })
sr.hunter.pve = blink.Actor:New({ spec = 1, class = "hunter" })

--druid
sr.druid.ready = class == "DRUID"
sr.druid.feral = blink.Actor:New({ spec = 2, class = "druid" })

--rogue
sr.rogue.ready = class == "ROGUE"
sr.rogue.assa = blink.Actor:New({ spec = 1, class = "rogue" })
sr.rogue.sub = blink.Actor:New({ spec = 3, class = "rogue" })

--paladin
sr.paladin.ready = class == "PALADIN"
sr.paladin.ret = blink.Actor:New({ spec = 3, class = "paladin" })

--priest
sr.priest.ready = class == "PRIEST"
sr.priest.disc = blink.Actor:New({ spec = 1, class = "priest" })
sr.priest.holy = blink.Actor:New({ spec = 2, class = "priest" })

--warrior
sr.warrior.ready = class == "WARRIOR"
sr.warrior.arms = blink.Actor:New({ spec = 1, class = "warrior" })

--shaman
sr.shaman.ready = class == "SHAMAN"
sr.shaman.ele = blink.Actor:New({ spec = 1, class = "shaman" })
sr.shaman.resto = blink.Actor:New({ spec = 3, class = "shaman" })


-- local keysToExclude = {
--   "w",          -- "W"
--   "a",          -- "A"
--   "s",          -- "S"
--   "d",          -- "D"
--   "q",          -- "Q"
--   "e",          -- "E"
--   --"unknown", -- "UNKNOWN"
--   -- "LeftButton", -- Left mouse button
--   -- "RightButton",-- Right mouse button
--   -- "SPACE",      -- Space key
-- }

-- sr.autoPause = function()
--   if GetKeyState("w") == 1 
--   or GetKeyState("a") == 1
--   or GetKeyState("s") == 1
--   or GetKeyState("d") == 1
--   or GetKeyState("q") == 1
--   or GetKeyState("e") == 1 then 
--     return false
--   else
--     return blink.alert(colors.cyan .. " Pause GCD") 
--   end
-- end

sr.delay = function()
  return delay.now
end

sr.lowest = function(list)
  if list and list.lowest then
    return list.lowest.hp or 100
  else
    return 100
  end
end

sr.Pause = function()
  if blink.MacrosQueued['pause'] then 
    return blink.alert(colors.cyan .. " Pause GCD")  
  elseif blink.MacrosQueued['pause 1'] then
    return blink.alert(colors.cyan .. " Pause 1") 
  elseif blink.MacrosQueued['pause 2'] then
    return blink.alert(colors.cyan .. " Pause 2") 
  elseif blink.MacrosQueued['pause 3'] then
    return blink.alert(colors.cyan .. " Pause 3") 
  elseif blink.MacrosQueued['pause 4'] then
    return blink.alert(colors.cyan .. " Pause 4") 
  elseif blink.MacrosQueued['pause 5'] then
    return blink.alert(colors.cyan .. " Pause 5") 
  end	
end

-- blink.addEventCallback(function() 
--   return blink.alert("|cFFf7f25c[SadRotations]:|r Loading...")
-- end, "PLAYER_ENTERING_WORLD")

function sr.randomDelay(callback)
  local delay = math.random(2, 5)
  C_Timer.After(delay, callback)
end

local shortSrDelay = blink.delay(0.5, 0.8)
local shortSrTime = blink.time + shortSrDelay.now
function sr.shortDelay()
  if blink.time > shortSrTime then
    shortSrDelay = blink.delay(2, 3)
    shortSrTime = blink.time + shortSrDelay.now
    return true
  else
    return false
  end
end

local longSrDelay = blink.delay(2, 4)
local longSrTime = blink.time + longSrDelay.now
function sr.longDelay()
  if blink.time > longSrTime then
    longSrDelay = blink.delay(2, 4)
    longSrTime = blink.time + longSrDelay.now
    return true
  else
    return false
  end
end

function sr.kickDelay(callback)
  local delay = math.random(50, 60) / 100
  C_Timer.After(delay, callback)
end

local flags = {"Alliance Flag", "Horde Flag"}
local flagDropTime = 0

onEvent(function(info, event, source, dest)
  local time = GetTime()
  if event ~= "SPELL_AURA_REMOVED" then return end
  local spellID, spellName, _, auraType = select(12, unpack(info))
  if auraType ~= "DEBUFF" then return end
  if source.isUnit(blink.player) and tContains(flags, spellName) then
    flagDropTime = time
  end
end)

function sr.FlagPick()
  if Unlocker.type == "noname" then return end
  if not sr.saved.pickUpFlag then return end
  if blink.instanceType2 == "pvp" then
    if GetTime() - flagDropTime > 3 then
      blink.objects.loop(function(obj)

        if obj.distance > 5 then return end
        C_Timer.After(0.5, function()  
          if obj.name == "Alliance Flag" then
            obj:interact()
            return blink.alert(blink.colors.blue .. "Pickup Alliance Flag", 23335)
          elseif obj.name == "Horde Flag" then 
            obj:interact()
            return blink.alert(blink.colors.red .."Pickup Horde Flag", 23333)
          end  
        end) 
      end)
    end
  end
end

--Update our target SQW/new DF shitty CVars
-- blink.SpellQueueWindow_Update = 50000000
-- sr.SQW = tonumber(GetCVar("SpellQueueWindow"))
-- local TargetSQW = (select(3, GetNetStats())*2)+15
-- if sr.SQW ~= TargetSQW then
--   C_Timer.After(5, function() 
--     SetCVar("SpellQueueWindow", TargetSQW)
--     SetCVar("SoftTargetInteract", 0)
--     SetCVar("SoftTargetEnemyRange", 0)
--     SetCVar("SoftTargetFriendRange", 0) 
--     blink.print("|cFFf7f25c[SadRotations]: SpellQueueWindow has been set to (" .. TargetSQW .. ")")
--   end)
--   --SetCVar("SpellQueueWindow", TargetSQW)
-- end

-- Disable Blink's automatic SpellQueueWindow control, if desired
if not blink.disableSQWControl then
  blink.SpellQueueWindow_Update = 6969696969696969
  blink.disableSQWControl = true
end

local messagePrinted = false
local function UpdateSpellQueueWindow()
  if blink.player.combat then return end
  local ourLatency = select(3, GetNetStats())
  local currentSQW = tonumber(GetCVar("SpellQueueWindow"))
  local targetSQW

  --latency is high don't set anything 
  if ourLatency > 200 then return false end

  -- if saved.DebugMode then
  --   targetSQW = (select(3, GetNetStats()) * 2) + 15 --Debug mode: targetSQW = 50
  -- else
  --   targetSQW = (select(3, GetNetStats()) * 2) + 15
  -- end
  targetSQW = (select(3, GetNetStats()) * 2) + 15

  --chill first login and latency isn't shown yet
  if targetSQW <= 15 then return false end
    
  -- Update the SpellQueueWindow CVar if the current value does not match the target
  if currentSQW ~= targetSQW and not messagePrinted then

    SetCVar("SpellQueueWindow", targetSQW)
    SetCVar("SoftTargetInteract", 0)
    SetCVar("SoftTargetEnemyRange", 0)
    SetCVar("SoftTargetFriendRange", 0)

    if not messagePrinted then
      sr.debugPrint("SQW has been set to |cFFf7f25c" .. targetSQW)
      messagePrinted = true
    end

  end
end
blink.addUpdateCallback(UpdateSpellQueueWindow)

function sr.friendlyPhysical()
  local FriendlyPhysical = blink.fgroup.find(function(obj)
    return obj.role == "melee" or obj.class2 == "HUNTER"
  end)
  if FriendlyPhysical then return true end
end

function sr.friendlyMelee()
  local FriendlyMelee = blink.fgroup.find(function(obj)
    return obj.role == "melee"
  end)
  if FriendlyMelee then return true end
end

function sr.enemyMelee()
  local EnemyMelee = blink.enemies.find(function(obj)
    return obj.role == "melee"
  end)
  if EnemyMelee then return true end
end


local noNeedToKick = {
  21562,  --test
  642,    -- Divine Shield
  213610, -- Holy Ward
  23920,  -- Reflect
  8178,   -- Grounding
  362486, -- Keeper of the Grove
  228050, -- Forgotten Queen
  204018, -- Spell Warding
  378464, -- Nullifying Shroud
  383618, -- Nullifying Shroud2
  353319, -- Monk Retoral
  408558, -- Priest Phase Shift
  377362, -- Prec
  196555, -- Netherwalk
  212295, -- Warlock Netherward
  215769, -- Priest Angel
  421453, -- Priest Pentence
  354610, -- DH Glimpse
}

function sr.NoNeedToKickThis(unit)
  if not blink.arena then return false end

  local shouldNotKick = false

  blink.fgroup.loop(function(member)
    -- Hunters won't get feared due to "The Beast Within"
    if unit.casting 
    and unit.castID == 5782 
    and unit.castTarget.isUnit(member) 
    and member.buff(212668) then
      shouldNotKick = true
      return true
    end

    if unit.casting 
    and unit.castTarget.isUnit(member) then
      if member.ccImmunityRemains > unit.castRemains then
        shouldNotKick = true
        return true
      end
    end
  end)

  return shouldNotKick
end

function printTable(table)
  for key, value in pairs(table) do
    print(key, value)
  end
end


function sr.eatTrap()
  if Unlocker.type == "noname" then return end
  if not sr.saved.eatHunterTraps then return end
  if not blink.arena then return end

  if Unlocker.type == "daemonic" then
    for _, missile in ipairs(blink.missiles) do
      if missile.spellId == 187650 then

        local trapToHealerDistance = healer.distanceTo(missile.tx, missile.ty, missile.tz)
        local trapToMeDistance = player.distanceTo(missile.tx, missile.ty, missile.tz)
        local healerToMeDistance = player.distanceTo(healer.x, healer.y, healer.z)
        local missilecreator = blink.GetObjectWithGUID(missile.source)
        if missilecreator.friend then return end

        -- Print the distances
        sr.debugPrint("Distance between me and the trap: " .. trapToMeDistance)
        sr.debugPrint("Trap coordinates: x=" .. missile.tx .. ", y=" .. missile.ty .. ", z=" .. missile.tz)
        --sr.debugPrint("Distance between healer and the trap: " .. trapToHealerDistance)

        if trapToMeDistance < 10 then
          MoveTo(missile.tx, missile.ty, missile.tz)
        end

        if healer.visible
        and player.distanceTo(healer) <= 4
        and trapToHealerDistance <= 8 then
          MoveTo(missile.tx, missile.ty, missile.tz)
          blink.alert(colors.cyan .. "Moving To Get The Trap",187650)
        end
      end
    end
  else
    for _, missile in ipairs(blink.missiles) do
      if missile.spellId == 187650 then
        local missilecreator = blink.GetObjectWithGUID(missile.source)
        if missilecreator and missilecreator.friend then return end

        -- Calculate distances using hit and current positions
        local hitDistanceToHealer = healer.distanceTo(missile.hx, missile.hy, missile.hz)
        local hitDistanceToPlayer = player.distanceTo(missile.hx, missile.hy, missile.hz)
        local currentDistanceToHealer = healer.distanceTo(missile.cx, missile.cy, missile.cz)
        local currentDistanceToPlayer = player.distanceTo(missile.cx, missile.cy, missile.cz)

        -- Debugging distances
        sr.debugPrint("Hit Distance to Healer: " .. tostring(hitDistanceToHealer))
        sr.debugPrint("Current Distance to Healer: " .. tostring(currentDistanceToHealer))
        sr.debugPrint("Hit Distance to Player: " .. tostring(hitDistanceToPlayer))
        sr.debugPrint("Current Distance to Player: " .. tostring(currentDistanceToPlayer))

        if healer.visible
        and player.distanceTo(healer) <= 4
        and hitDistanceToHealer <= 8 then
          sr.debugPrint("Moving To Get The Trap...")
          MoveTo(missile.hx or missile.cx, missile.hy or missile.cy, missile.hz or missile.cz)
          blink.alert(colors.cyan .. "Moving To Get The Trap", 187650)
        end
      end
    end
  end
end

function sr.autoFocus()
  if Unlocker.type == "noname" then return end
  --Auto Focus 
  if sr.saved.autofousunit == "smartfocus" then
    autoFocus()
  elseif sr.saved.autofousunit == "enemyHealerfocus" and enemyHealer and enemyHealer.exists and not enemyHealer.charmed then
    enemyHealer.setFocus()
  elseif sr.saved.autofousunit == "offtargetfocus" then
    local offTar = blink.enemies.find(function(enemy)
      return enemy.exists 
      and (enemy.isRanged or enemy.isMelee) 
      and enemy.isPlayer and not enemy.isUnit(target) 
      and not enemy.isHealer
    end)
    if offTar then
      offTar.setFocus()
    end
    -- blink.enemies.loop(function(enemy)
    --   if enemy.exists 
    --   and (enemy.isRanged or enemy.isMelee) 
    --   and enemy.isPlayer and not enemy.isUnit(target) 
    --   and not enemy.isHealer then
    --     enemy.setFocus()
    --   end
    -- end)
  elseif sr.saved.autofousunit == "turnautofocusoff" then
    --turn off
  end
end

function sr.autoTarget()

  local bestScore = -9999
  local bestTarget = nil

  local specRole = {
    Arms = "melee", Fury = "melee", Protection = "melee",
    HolyPaladin = "healer", ProtectionPaladin = "melee", Retribution = "melee",
    BeastMastery = "ranged", Marksmanship = "ranged", Survival = "melee",
    Assassination = "melee", Outlaw = "melee", Subtlety = "melee",
    Discipline = "healer", HolyPriest = "healer", Shadow = "ranged",
    Blood = "melee", FrostDK = "melee", Unholy = "melee",
    Elemental = "ranged", Enhancement = "melee", RestorationShaman = "healer",
    Arcane = "ranged", Fire = "ranged", FrostMage = "ranged",
    Affliction = "ranged", Demonology = "ranged", Destruction = "ranged",
    Brewmaster = "melee", Mistweaver = "healer", Windwalker = "melee",
    Balance = "ranged", Feral = "melee", Guardian = "melee", RestorationDruid = "healer",
    Havoc = "melee", Vengeance = "melee",
    Devastation = "ranged", Preservation = "healer", Augmentation = "ranged",
  }

  local roleDamageType = {
    melee = "physical",
    ranged = "physical",
    caster = "magic",
    healer = "magic",
    tank = "physical",
  }

  local playerSpec = player.spec
  local playerRole = specRole[playerSpec]
  local playerDamageType = roleDamageType[playerRole]

  --chill
  if Unlocker.type == "noname" then return end
  if not blink.instanceType2 == "pvp" then return end
  if not sr.saved.autoTargeting then return end
  if not player.combat then return end

  blink.enemies.loop(function(enemy)
    if enemy.los 
    and not enemy.isPet then
      local score = 0

      -- Calculate score based on Health / Absorbs
      score = score - enemy.hp 

      -- Check for Immune Magic
      if playerDamageType == "magic" 
      and enemy.immuneMagicDamage then
        return
      end

      -- Check for Immune physical
      if playerDamageType == "physical" 
      and enemy.immunePhysicalDamage then
        return
      end

      --player not facing the shit
      if not player.facing(enemy, 130) then
        return
      end

      -- Check distance for melee players
      if playerRole == "melee" 
      and enemy.distance > 5 then
        return
      end

      -- Check distance for ranged players
      if playerRole == "ranged" 
      and enemy.distance > 40 then 
        return
      end

      --MM Hunters? more range fuck it
      if player.class2 == "HUNTER" 
      and player.spec == "Marksmanship"
      and enemy.distance > 45 then
        return
      end

      --hey its healer chill
      if enemy.role == "healer" then
        score = score - 1000
      end

      -- Update best target
      if score > bestScore then
        bestScore = score
        bestTarget = enemy
      end
    end
  end)
  
  if bestTarget then 
    bestTarget.setTarget()
  end
end



sr.BadKicks = {
  ["Lava Burst"] = function(obj)
    return obj.role == "healer" or sr.lowest(blink.fgroup) > 75
  end,
--   ["Stormkeeper"] = function(obj)
--     return obj.role == "healer" or sr.lowest(blink.fgroup) > 75
--   end,
--   ["Lightning Lasso"] = function(obj)
--     return obj.role == "healer" or sr.lowest(blink.fgroup) > 80
--   end,
  ["Fireball"] = function(obj)
    return sr.lowest(blink.fgroup) > 50 + bin(obj.cds) * 50
  end,
  ["Scorch"] = function(obj)
    return not obj.cds
  end,
  ["Polymorph"] = function(obj)
    return obj.castTarget.idr and obj.castTarget.idr < 0.5
  end,
  ["Crackling Jade Lightning"] = function(obj)
    return obj.role ~= "healer"
  end,
  ["Vivify"] = function(obj)
    return obj.role ~= "healer"
  end,
  ["Shadow Mend"] = function(obj)
    if obj.lockouts.holy or sr.lowest(blink.enemies) < 42 then 
      return false
    end
    return true
  end,
}

sr.lowHpTotems = {
  [194117] = { TotemName = "Stoneskin Totem", Health = 4 },
  [5925]   = { TotemName = "Grounding Totem", Health = 5 },
  [5913]   = { TotemName = "Tremor Totem", Health = 5 },
  [6112]   = { TotemName = "Windfury Totem", Health = 5 },
  [105451] = { TotemName = "Counterstrike Totem", Health = 50 },
  [105427] = { TotemName = "Skyfury Totem", Health = 50 },
  [60561]  = { TotemName = "Earthgrab Totem", Health = 15194 },
  [61245]  = { TotemName = "Capacitor Totem", Health = 15194 },
  [2630]   = { TotemName = "Earthbind Totem", Health = 15194 },
}

function sr.Dampening()
  local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, damp = player.debuff(110310)
  if damp then
    return damp
  else
    return 0
  end
end

function sr.immuneCC(unit)

  local additionalImmunityBuffs = {377362, 215769, 421453}

  if unit.buffFrom(additionalImmunityBuffs) then
    return true
  end

  return unit.immuneCC
end

function sr.cancelSpellByName(spellInput)

  blink.unlock("CancelSpellByName")

  local spellName

  if type(spellInput) == "number" then
    spellName = C_Spell.GetSpellInfo(spellInput).name
  else
    spellName = spellInput
  end

  return blink.call("CancelSpellByName", spellName)
end

function sr.cancelBuff(buffInput)
  blink.unlock("C_Macro.RunMacroText")

  local buffName

  if type(buffInput) == "number" then
    buffName, _, _, _, _, _, _ = C_Spell.GetSpellInfo(buffInput).name
  else
    buffName = buffInput
  end

  local macroCommand = "/cancelaura " .. buffName
  blink.call('C_Macro.RunMacroText', macroCommand, "")
end

--DebugMode is enabled.
function sr.debugPrint(...)
  if Unlocker.type == "noname" then return end
  if not sr.saved.DebugMode then return end
  local args = {...}
  local message = "|cFFf7f25c[SR Debug]:|r "
  for i, arg in ipairs(args) do
    message = message .. tostring(arg) .. " "
  end
  blink.print(message)
end


function sr.debugAlert(options, texture, isBig)
  if Unlocker.type == "noname" then return end
  if not sr.saved.DebugMode then return end

  local alertOptions = type(options) == 'string' and {message = options} or options

  alertOptions.fadeIn = alertOptions.fadeIn or 0.175
  alertOptions.fadeOut = alertOptions.fadeOut or 0.3

  if texture then
    alertOptions.texture = texture
  end

  blink.alert(alertOptions, alertOptions.texture, isBig)
end

-- local checked = 0
-- sr.autoTargetSeed = function()
--     if not blink.arena then return end
--     if blink.time - checked < 0.1 then return end
--     checked = blink.time
-- 	-- auto target seed
-- 	blink.seeds.stomp(function(seed, uptime) 
-- 		if uptime < 1.25 then
-- 			if seed.enemy and not target.isUnit(seed) and seed.los then
-- 				seed.setTarget()
-- 				blink.alert("|cFFf7f25c[Seed Detected]: |cFFFFFFFFTargeting Seed to Kill it !")
-- 			end
-- 		end
-- 	end)
-- end

local loading, finished = C_AddOns.IsAddOnLoaded("Hekili")
local autoToggledHekili = false
local lastRun = 0
local throttle = 0.1
local gz = blink.GroundZ

local pvpTrinketIDs = {
  [209764] = true,
  [209346] = true,
}

local function pveReady(unit)
  if unit.enemy 
  and not unit.combat 
  and not unit.isDummy 
  and not player.mounted then 
    return false 
  end

  local pveReady = unit.exists and unit.enemy and unit.los 
  and not (unit.bcc or unit.dead or unit.debuff(203337) or player.debuff(410201))

  if not unit.exists 
  or not pveReady then 
    return 
  end

  
  if player.role == "melee" 
  and player.meleeRangeOf(unit) then
    return true
  elseif (player.role == "ranged" and player.distanceTo(unit) <= 40) or (player.spec == "Marksmanship" and player.distanceTo(unit) < 50) then
    return true
  else
    return false
  end

end

local function manageHekiliRotationToggles()
  if not (loading and finished) then return end
  local HekiliEnabled = Hekili.DB.profile.enabled
  if Unlocker.type == "noname" then return end
  if sr.saved.rotationMode == "hekiliMode" 
  and not HekiliEnabled then
    Hekili:Toggle()
    print(blink.colors.yellow .."[SadRotations]:", blink.colors.green .."Hekili Addon enabled.")
  else
    if sr.saved.rotationMode ~= "hekiliMode" 
    and HekiliEnabled then
      Hekili:Toggle()
      print(blink.colors.yellow .."[SadRotations]:", blink.colors.red .."Hekili Addon disabled.")
    end
  end
end
blink.addUpdateCallback(manageHekiliRotationToggles)

function sr.HekiliRotation()
  if not (loading and finished) then return end
  local HekiliEnabled = Hekili.DB.profile.enabled
  local currentTime = GetTime()
  if currentTime - lastRun < throttle then return end
  lastRun = currentTime

  if not blink.enabled 
  or not HekiliEnabled 
  or sr.saved.rotationMode ~= "hekiliMode" then 
    return 
  end

  if pveReady(target) then
    local id = Hekili_GetRecommendedAbility("Primary", 1)
    if not id then return end
    local absId = math.abs(id)
    local name = C_Spell.GetSpellInfo(absId).name

    sr.debugPrint("Recommended ability ID:", id, "Name:", name)

    if id < 0 then
      local trinketIDs = {GetInventoryItemID("player", 13), GetInventoryItemID("player", 14)}
      for _, trinketId in ipairs(trinketIDs) do
        if not pvpTrinketIDs[trinketId] 
        and IsUsableItem(trinketId) 
        and GetItemCooldown(trinketId) == 0 then
          local slot = GetInventorySlotInfo(trinketId == trinketIDs[1] and "Trinket0Slot" or "Trinket1Slot")
          UseInventoryItem(slot)
          sr.debugPrint("Using Trinket:", trinketId, "at slot:", trinketId == trinketIDs[1] and "Trinket0Slot" or "Trinket1Slot")
          return
        end
      end

      local item = blink.Item(absId)
      if item 
      and item.count > 0 
      and item.cd == 0 then
        if item:Use() then
          return
        end
      end
    else
      
      -- BM Hunter barbed and shit
      if id == 217200 then
        sr.hunter.bm.barbed("PVE")
      elseif id == 193455 then
        sr.hunter.bm.cobra("PVE")
      end

      if SpellIsTargeting() then
        local x, y, z = gz(target.position())
        Click(x, y, z)
      end

      if sr.CastSpellByID(absId) then 
        --sr.debugPrint("Casted ability by id:", absId) 
      else
        sr.CastSpellByName(name)
        sr.debugPrint("Casted ability by name:", name)
      end

      -- if sr.CastSpellByName(name) and sr.debugPrint("Casted ability By name:", name) then
      --   sr.debugPrint("Casted ability By name:", name)
      --   return
      -- end
      -- if sr.CastSpellByID(absId) then
      --   sr.debugPrint("Casted ability by id:", name)
      --   return
      -- end

    end
  end
end

sr.StickyTargetManager = {}
sr.StickyTargetManager.stickyTargetHistory = {}
function sr.analyzeStickyTargetHistory()
  local history = sr.StickyTargetManager.stickyTargetHistory
  if #history > 1 then
    local latest = history[#history]
    local previous = history[#history - 1]
    if latest ~= previous then
      sr.debugPrint("Sticky Targeting setting changed from " .. previous .. " to " .. latest)
      SetCVar("deselectOnClick", previous)
    end
  end
end

function sr.updateStickyTarget()
  local stickyTarget = GetCVar("deselectOnClick")
  table.insert(sr.StickyTargetManager.stickyTargetHistory, stickyTarget)
end

C_Timer.NewTicker(0.5, sr.updateStickyTarget)