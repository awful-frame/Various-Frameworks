local Tinkr, blink = ...
local Evaluator = Tinkr.Util.Evaluator
local ObjectManager = Tinkr.Util.ObjectManager
local tinsert, type = tinsert, type
-- if Tinkr.type == "noname" then 
--     blink.print("Undergoing Maintenance, please check back later.")
--     return 
-- end

local _G, _ENV = _G, getfenv(1)

local APIVersion = 1 --2.70

-- _G["ZnVja3lvdW5u"] = "rawr"

blink.__index = blink
blink.internal = {}
blink.internal.loaded = {}
blink.cache = {}
blink.cacheLiteral = {}
blink.gameVersion = WOW_PROJECT_ID

blink.__username = blink.__username or "blink"

local player

-- _G.SetFocus = SetFocus

-- if not Tinkr.type then
--     Tinkr.type = ttype
-- end

if blink.gameVersion ~= 1 then
  local defaultReturns = {
    UnitSpellHaste = 0
  }
  for alias, retVal in pairs(defaultReturns) do
    _G[alias] = _G[alias] or function()
      return retVal
    end
  end

  local lib = {
    version = 69420
  }
  lib.MAX_TALENT_TIERS = 7
  lib.NUM_TALENT_COLUMNS = 4

  -- TODO(#4): displayName param should be i18n
  local Warrior = {
    ID = 1,
    displayName = "Warrior",
    name = "WARRIOR",
    Arms = 71,
    Fury = 72,
    Prot = 73,
    specs = {71, 72, 73}
  }
  local Paladin = {
    ID = 2,
    displayName = "Paladin",
    name = "PALADIN",
    Holy = 65,
    Prot = 66,
    Ret = 70,
    specs = {65, 66, 70}
  }
  local Hunter = {
    ID = 3,
    displayName = "Hunter",
    name = "HUNTER",
    BM = 253,
    MM = 254,
    SV = 255,
    specs = {253, 254, 255}
  }
  local Rogue = {
    ID = 4,
    displayName = "Rogue",
    name = "ROGUE",
    Assasin = 259,
    Combat = 260,
    Sub = 261,
    specs = {259, 260, 261}
  }
  local Priest = {
    ID = 5,
    displayName = "Priest",
    name = "PRIEST",
    Disc = 256,
    Holy = 257,
    Shadow = 258,
    specs = {256, 257, 258}
  }
  local DK = {
    ID = 6,
    displayName = "Death knight",
    name = "DEATHKNIGHT",
    Blood = 250,
    Frost = 251,
    Unholy = 252,
    specs = {250, 251, 252}
  }
  local Shaman = {
    ID = 7,
    displayName = "Shaman",
    name = "SHAMAN",
    Ele = 262,
    Enh = 263,
    Resto = 264,
    specs = {262, 263, 264}
  }
  local Mage = {
    ID = 8,
    displayName = "Mage",
    name = "MAGE",
    Arcane = 62,
    Fire = 63,
    Frost = 64,
    specs = {62, 63, 64}
  }
  local Warlock = {
    ID = 9,
    displayName = "Warlock",
    name = "WARLOCK",
    Affl = 265,
    Demo = 266,
    Destro = 267,
    specs = {265, 266, 267}
  }
  local Monk = {
    ID = 10,
    displayName = "Monk",
    name = "MONK",
    BRM = 268,
    WW = 269,
    MW = 270,
    specs = {268, 269, 270}
  }
  local Druid = {
    ID = 11,
    displayName = "Druid",
    name = "DRUID",
    Balance = 102,
    Feral = 103,
    Guardian = 104,
    Resto = 105,
    specs = {102, 103, 104, 105}
  }
  local DH = {
    ID = 12,
    displayName = "Demon hunter",
    name = "DEMONHUNTER",
    Havoc = 577,
    Veng = 581,
    specs = {577, 581}
  }

  lib.Class = {
    Warrior = Warrior,
    Paladin = Paladin,
    Hunter = Hunter,
    Rogue = Rogue,
    Priest = Priest,
    DK = DK,
    Shaman = Shaman,
    Mage = Mage,
    Warlock = Warlock,
    Monk = Monk,
    Druid = Druid,
    DH = DH
  }

  local ClassByID = {Warrior, Paladin, Hunter, Rogue, Priest, DK, Shaman, Mage, Warlock, Monk, Druid, DH}

  local Stat = {
    Strength = 1,
    Agility = 2,
    Stamina = 3,
    Intellect = 4,
    Spirit = 5
  }

  lib.Stat = Stat

  local Role = {
    Damager = "DAMAGER",
    Tank = "TANK",
    Healer = "HEALER"
  }

  lib.Role = Role

  -- Map of spec (tab) index to spec id
  local NAME_TO_SPEC_MAP = {
    [Warrior.name] = Warrior.specs,
    [Paladin.name] = Paladin.specs,
    [Hunter.name] = Hunter.specs,
    [Rogue.name] = Rogue.specs,
    [Priest.name] = Priest.specs,
    [DK.name] = DK.specs,
    [Shaman.name] = Shaman.specs,
    [Mage.name] = Mage.specs,
    [Warlock.name] = Warlock.specs,
    [Monk.name] = Monk.specs,
    [Druid.name] = Druid.specs,
    [DH.name] = DH.specs
  }

  -- Detailed info for each spec
  local SpecInfo = {
    [Warrior.Arms] = {
      ID = Warrior.Arms,
      name = "Arms",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = false,
      primaryStat = Stat.Strength
    },
    [Warrior.Fury] = {
      ID = Warrior.Fury,
      name = "Fury",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Strength
    },
    [Warrior.Prot] = {
      ID = Warrior.Prot,
      name = "Protection",
      description = "",
      icon = "",
      background = "",
      role = Role.Tank,
      isRecommended = false,
      primaryStat = Stat.Strength
    },
    [Paladin.Holy] = {
      ID = Paladin.Holy,
      name = "Holy",
      description = "",
      icon = "",
      background = "",
      role = Role.Healer,
      isRecommended = false,
      primaryStat = Stat.Intellect
    },
    [Paladin.Prot] = {
      ID = Paladin.Prot,
      name = "Protection",
      description = "",
      icon = "",
      background = "",
      role = Role.Tank,
      isRecommended = false,
      primaryStat = Stat.Strength
    },
    [Paladin.Ret] = {
      ID = Paladin.Ret,
      name = "Retribution",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Strength
    },
    [Hunter.BM] = {
      ID = Hunter.BM,
      name = "Beast Mastery",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Agility
    },
    [Hunter.MM] = {
      ID = Hunter.MM,
      name = "Marksman",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Agility
    },
    [Hunter.SV] = {
      ID = Hunter.SV,
      name = "Survival",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = false,
      primaryStat = Stat.Agility
    },
    [Rogue.Assasin] = {
      ID = Rogue.Assasin,
      name = "Assasination",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Agility
    },
    [Rogue.Combat] = {
      ID = Rogue.Combat,
      name = "Combat",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Agility
    },
    [Rogue.Sub] = {
      ID = Rogue.Sub,
      name = "Subtlety",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = false,
      primaryStat = Stat.Agility
    },
    [Priest.Disc] = {
      ID = Priest.Disc,
      name = "Discipline",
      description = "",
      icon = "",
      background = "",
      role = Role.Healer,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Priest.Holy] = {
      ID = Priest.Holy,
      name = "Holy",
      description = "",
      icon = "",
      background = "",
      role = Role.Healer,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Priest.Shadow] = {
      ID = Priest.Shadow,
      name = "Shadow",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = false,
      primaryStat = Stat.Intellect
    },
    [Shaman.Ele] = {
      ID = Shaman.Ele,
      name = "Elemental",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Shaman.Enh] = {
      ID = Shaman.Enh,
      name = "Enhancement",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Strength
    },
    [Shaman.Resto] = {
      ID = Shaman.Resto,
      name = "Restoration",
      description = "",
      icon = "",
      background = "",
      role = Role.Healer,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Mage.Arcane] = {
      ID = Mage.Arcane,
      name = "Arcane",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = false,
      primaryStat = Stat.Intellect
    },
    [Mage.Fire] = {
      ID = Mage.Fire,
      name = "Fire",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Mage.Frost] = {
      ID = Mage.Frost,
      name = "Frost",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Warlock.Affl] = {
      ID = Warlock.Affl,
      name = "Affliction",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = false,
      primaryStat = Stat.Intellect
    },
    [Warlock.Demo] = {
      ID = Warlock.Demo,
      name = "Demonology",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Warlock.Destro] = {
      ID = Warlock.Destro,
      name = "Destruction",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = false,
      primaryStat = Stat.Intellect
    },
    [Druid.Balance] = {
      ID = Druid.Balance,
      name = "Balance",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Druid.Feral] = {
      ID = Druid.Feral,
      name = "Feral",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Strength
    },
    [Druid.Guardian] = {
      ID = Druid.Guardian,
      name = "Guardian",
      description = "",
      icon = "",
      background = "",
      role = Role.Tank,
      isRecommended = true,
      primaryStat = Stat.Strength
    },
    [Druid.Resto] = {
      ID = Druid.Resto,
      name = "Restoration",
      description = "",
      icon = "",
      background = "",
      role = Role.Healer,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [DK.Frost] = {
      ID = DK.Frost,
      name = "Frost",
      description = "",
      icon = "",
      background = "",
      role = Role.Tank,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [DK.Blood] = {
      ID = DK.Blood,
      name = "Blood",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [DK.Unholy] = {
      ID = DK.Unholy,
      name = "Unholy",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [DH.Havoc] = {
      ID = DH.Havoc,
      name = "Havoc",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [DH.Veng] = {
      ID = DH.Veng,
      name = "Vengeance",
      description = "",
      icon = "",
      background = "",
      role = Role.Tank,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Monk.BRM] = {
      ID = Monk.BRM,
      name = "Brewmaster",
      description = "",
      icon = "",
      background = "",
      role = Role.Tank,
      isRecommended = true,
      primaryStat = Stat.Agility
    },
    [Monk.MW] = {
      ID = Monk.MW,
      name = "Mistweaver",
      description = "",
      icon = "",
      background = "",
      role = Role.Healer,
      isRecommended = true,
      primaryStat = Stat.Intellect
    },
    [Monk.WW] = {
      ID = Monk.WW,
      name = "Windwalker",
      description = "",
      icon = "",
      background = "",
      role = Role.Damager,
      isRecommended = true,
      primaryStat = Stat.Agility
    }
  }

  lib.SpecInfo = SpecInfo

  local ROLE_MAP = {}
  for specId, v in pairs(SpecInfo) do
    ROLE_MAP[specId] = v.role
  end

  lib.GetClassInfo = function(classId)
    local info = ClassByID[classId]
    if (info == nil) then
      return nil
    end
    return info.displayName, info.name, info.ID
  end

  lib.GetNumSpecializationsForClassID = function(classId)
    if (classId <= 0 or classId > lib.GetNumClasses()) then
      return nil
    end
    local class = ClassByID[classId]
    local specs = NAME_TO_SPEC_MAP[class.name]
    return #specs
  end

  lib.GetInspectSpecialization = function(unit)
    return nil
  end

  lib.GetActiveSpecGroup = function()
    return 1 -- primary spec slot
  end

  local DRUID_FERAL_TAB = 2
  local DRUID_FERAL_INSTINCT = 3
  local DRUID_THICK_HIDE = 5
  local DRUID_GUARDIAN_SPEC_INDEX = 3
  local DRUID_RESTO_SPEC_INDEX = 4

  lib.GetSpecialization = function(isInspect, isPet, groupId)
    if (isInspect or isPet) then
      return nil
    end

    if UnitLevel("player") < 10 then
      return 5
    end

    local specIndex
    local max = 0
    for tabIndex = 1, GetNumTalentTabs() do
      local spent = select(3, GetTalentTabInfo(tabIndex))
      if (spent > max) then
        specIndex = tabIndex
        max = spent
      end
    end

    local classId = select(3, UnitClass("player"))
    if (classId == Druid.ID) then
      -- Return Druid.Guardian if certain talents are selected
      local feralInstinctPoints = select(5, GetTalentInfo(DRUID_FERAL_TAB, DRUID_FERAL_INSTINCT))
      local thickHidePoints = select(5, GetTalentInfo(DRUID_FERAL_TAB, DRUID_THICK_HIDE))
      if (feralInstinctPoints == 5 and thickHidePoints == 5) then
        return DRUID_GUARDIAN_SPEC_INDEX
      end

      -- return 4 if Resto (3rd tab has most points), because Guardian is 3
      if (specIndex == DRUID_GUARDIAN_SPEC_INDEX) then
        return DRUID_RESTO_SPEC_INDEX
      else
        return specIndex
      end
    end

    return specIndex or 1
  end

  lib.GetSpecializationInfo = function(specIndex, isInspect, isPet, inspectTarget, sex)
    if (isInspect or isPet) then
      return nil
    end
    local _, className = UnitClass("player")
    local specId = NAME_TO_SPEC_MAP[className][specIndex]

    if not specId then
      return nil
    end

    --[===[@debug
            print("GetSpecializationInfo", specIndex, className, specId) --@end-debug]===]

    local spec = SpecInfo[specId]
    return spec.ID, spec.name, spec.description, spec.icon, spec.background, spec.role, spec.primaryStat
  end

  lib.GetSpecializationInfoForClassID = function(classId, specIndex)
    local class = ClassByID[classId]
    if not class then
      return nil
    end

    --[===[@debug
            print("GetSpecializationInfoForClassID", classId, class.name, specIndex) --@end-debug]===]
    local specId = NAME_TO_SPEC_MAP[class.name][specIndex]
    local info = SpecInfo[specId]

    if not info then
      return nil
    end

    local isAllowed = classId == select(3, UnitClass("player"))
    return info.ID, info.name, info.description, info.icon, info.role, info.isRecommended, isAllowed
  end

  lib.GetSpecializationRoleByID = function(specId)
    return ROLE_MAP[specId]
  end

  lib.GetSpecializationRole = function(specIndex, isInspect, isPet)
    if (isInspect or isPet) then
      return nil
    end
    local _, className = UnitClass("player")
    local specId = NAME_TO_SPEC_MAP[className][specIndex]
    return ROLE_MAP[specId]
  end

  lib.GetNumClasses = function()
    return #ClassByID
  end

  _G.MAX_TALENT_TIERS = _G.MAX_TALENT_TIERS or lib.MAX_TALENT_TIERS
  _G.NUM_TALENT_COLUMNS = _G.NUM_TALENT_COLUMNS or lib.NUM_TALENT_COLUMNS

  _G.GetNumClasses = _G.GetNumClasses or lib.GetNumClasses
  _G.GetClassInfo = _G.GetClassInfo or lib.GetClassInfo
  _G.GetNumSpecializationsForClassID = _G.GetNumSpecializationsForClassID or lib.GetNumSpecializationsForClassID

  _G.GetActiveSpecGroup = _G.GetActiveSpecGroup or lib.GetActiveSpecGroup

  _G.GetSpecialization = _G.GetSpecialization or lib.GetSpecialization
  _G.GetSpecializationInfo = _G.GetSpecializationInfo or lib.GetSpecializationInfo
  _G.GetSpecializationInfoForClassID = _G.GetSpecializationInfoForClassID or lib.GetSpecializationInfoForClassID

  _G.GetSpecializationRole = _G.GetSpecializationRole or lib.GetSpecializationRole
  _G.GetSpecializationRoleByID = _G.GetSpecializationRoleByID or lib.GetSpecializationRoleByID
end

local function round_rating(rating)
  return math.ceil((rating + 75) / 50) * 50
end

blink.FILTER_D = function(data, tickrate)

  -- only on retail
  if blink.gameVersion ~= 1 then
    return
  end

  player = player or blink.player

  if data.uData or data.cData then
    return
  end

  -- data by class/spec
  local spec = player.spec or "Unknown"
  local class = player.class or "Unknown"
  local css = spec .. " " .. class
  if not data[css] then
    data[css] = {}
  end

  local specData = data[css]

  -- total play time in seconds on this class/spec
  specData.playTime = specData.playTime and specData.playTime + tickrate or tickrate

  -- rating by spec
  local current2v2, best2v2 = GetPersonalRatedInfo(1)
  local current3v3, best3v3 = GetPersonalRatedInfo(2)

  if not best2v2 then
    return
  end

  if best2v2 > 0 then
    best2v2 = round_rating(best2v2)
  end
  if best3v3 > 0 then
    best3v3 = round_rating(best3v3)
  end
  if current2v2 > 0 then
    current2v2 = round_rating(current2v2)
  end
  if current3v3 > 0 then
    current3v3 = round_rating(current3v3)
  end

  if best2v2 > 0 then
    specData.current2v2 = current2v2
    if not specData.best2v2 or best2v2 > specData.best2v2 then
      specData.best2v2 = best2v2
    end
  end

  if best3v3 > 0 then
    specData.current3v3 = current3v3
    if not specData.best3v3 or best3v3 > specData.best3v3 then
      specData.best3v3 = best3v3
    end
  end

  return data

end

local loadUnits = blink.loadUnits
local tremove = tremove
local extra_mdist = 8

local staticObjects = {
  player = true,
  target = true,
  focus = true,
  mouseover = true,
  pet = true,
  arena1 = true,
  arena2 = true,
  arena3 = true,
  arena4 = true,
  arena5 = true,
  healer = true,
  enemyHealer = true
}

local calls = {}
blink.calls = calls

local function cacheReturn(key, keyLower, selection, func, returnType, ...)
  if type(returnType) == "function" then
    local rt, ri = returnType(keyLower)
    local funct = type(func) == "string" and _ENV[func] or func
    local val = {funct(...)}
    local ret = val and val[ri or selection] or false
    blink[key] = ret
    blink.cacheLiteral[key] = ret
    return ret
  elseif type(returnType) == "number" then
    local funct = type(func) == "string" and _ENV[func] or func
    local val = {funct(...)}
    local ret = val and val[returnType] or false
    blink[key] = ret
    blink.cacheLiteral[key] = ret
    return ret
  elseif returnType == "single" then
    local funct = type(func) == "string" and _ENV[func] or func
    local val = funct(...)
    local ret = val or false
    blink[key] = ret
    blink.cacheLiteral[key] = ret
    return ret
  else
    local funct = type(func) == "string" and _ENV[func] or func
    local val = {funct(...)}
    local ret = val and val[selection] or false
    if selection == 1 then
      blink[key] = ret
      blink.cacheLiteral[key] = ret
    else
      blink[key .. selection] = ret
      blink.cacheLiteral[key .. selection] = ret
    end
    return ret
  end
end

local bad = {
  SpellQueued = true,
  paused = true,
  burst = true,
  releaseMovementTime = true,
  ttd_enabled = true,
  releaseFacingTime = true,
  enabled = true,
  sortPointer = true,
  premium = true,
  debugSmartAoE = true
}

local blinkKeys = {
  __index = function(self, key)

    if key ~= "loadUnits" and not loadUnits then
      loadUnits = self.loadUnits
    end

    if not key then
      return
    end

    -- keys that def don't need further processing if nil 
    if bad[key] then
      return
    end

    -- if key ~= "instanceType2" and key ~= "arena" then
    --     print(key)
    -- end

    -- if key ~= "debug" and key ~= "arena" and key ~= "group" and key ~= "prepRemains" and key ~= "prep" then
    --     if not calls[key] then
    --         calls[key] = 1
    --     else
    --         calls[key] = calls[key] + 1
    --     end
    --     for k, v in pairs(calls) do
    --         print(k .. ": " .. v)
    --     end
    -- end

    -- key = key:gsub("_", "")

    local selection = 1

    local keyLower = key:lower()

    if keyLower == "spelllimiter" then
      if not blink.internal.spellLimiter then
        blink.internal.spellLimiter = 0
      end
      return blink.internal.spellLimiter
    elseif keyLower == "preparation" or keyLower == "prep" then
      return self.prepRemains > 0 or blink.player.buff(32727)
    elseif keyLower == "prepremains" or keyLower == "preptimeleft" or keyLower == "gatetimer" or keyLower == "arenastarttimer" or keyLower == "pulltimer" or keyLower == "pulltime" or keyLower ==
      "timetopull" or keyLower == "pullbradswilly" then
      local func = function()
        local timeLeft = 0
        if TimerTracker and TimerTracker.timerList[1] then
          if TimerTracker.timerList[1].time then
            timeLeft = TimerTracker.timerList[1].time
          end
        elseif DBT_Bar_1 and DBT_Bar_1.obj and DBT_Bar_1.obj.timer then
          timeLeft = DBT_Bar_1.obj.timer
        end
        if blink.player.combat then timeLeft = 0 end
        return timeLeft
      end
      return func()
    elseif keyLower == "zoneid" then
      return C_Map.GetBestMapForUnit("player")
    elseif keyLower == "arena" then
      local function checkArena()
        return self.instanceType2 == "arena"
      end
      return cacheReturn(key, keyLower, selection, checkArena, "single")
    elseif keyLower == "lastcast" then
      return rawget(self, "lastCast")
    elseif keyLower == "instance" or keyLower == "instancetype" or keyLower == "isininstance" or keyLower == "instancetype2" then
      if keyLower == "instancetype2" then
        local f = function()
          return select(2, IsInInstance())
        end
        return cacheReturn(key, keyLower, selection, f, "single")
      end
      return cacheReturn(key, keyLower, selection, IsInInstance, "multiReturn")
    elseif keyLower == "ourhealer" or keyLower == "friendlyhealer" or keyLower == "healer" then
      self[key] = self.internal.healer
      return self.internal.healer
    elseif keyLower == "enemyhealer" or keyLower == "theirhealer" then
      self[key] = self.internal.enemyHealer
      return self.internal.enemyHealer
    elseif keyLower == "critters" then
      local function get()
        loadUnits("critters")
        return self.internal.critters
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "tyrants" then
      local function get()
        loadUnits("tyrants")
        return self.internal.tyrants
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "rocks" then
      local function get()
        loadUnits("rocks")
        return self.internal.rocks
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "wwclones" then
      local function get()
        loadUnits("clones")
        return self.internal.wwClones
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "explosives" then
      local function get()
        loadUnits("explosives")
        return self.internal.explosives
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "incorporeals" then
      local function get()
        loadUnits("incorporeals")
        return self.internal.incorporeals
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "afflicteds" then
      local function get()
        loadUnits("afflicteds")
        return self.internal.afflicteds
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "shades" then
      local function get()
        loadUnits("shades")
        return self.internal.shades
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "pets" then
      local function get()
        loadUnits("pets")
        return self.internal.pets
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "totems" then
      local function get()
        loadUnits("totems")
        return self.internal.totems
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "friendlytotems" then
      local function get()
        loadUnits("friendlyTotems")
        return self.internal.friendlyTotems
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "wildseeds" or keyLower == "seeds" then
      local function get()
        loadUnits("wildseeds")
        return self.internal.wildseeds
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "enemypets" then
      local function get()
        loadUnits("enemyPets")
        return self.internal.enemyPets
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "units" then
      local function get()
        loadUnits("units")
        return self.internal.units
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "dead" then
      local function get()
        loadUnits("dead")
        return self.internal.dead
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "players" then
      local function get()
        loadUnits("players")
        return self.internal.players
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "friendlypets" then
      local function get()
        loadUnits("friendlyPets")
        return self.internal.friendlyPets
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "triggers" or keyLower == "areatriggers" then
      local function get()
        loadUnits("areaTriggers")
        return self.internal.areaTriggers
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "imps" then
      local function get()
        loadUnits("imps")
        return self.internal.imps
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "enemies" then
      local function get()
        loadUnits("enemies")
        return self.internal.enemies
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "allenemies" then
      local function get()
        loadUnits("allEnemies")
        return self.internal.allEnemies
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "friends" then
      local function get()
        loadUnits("friends")
        return self.internal.friends
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "dynamicobjects" or keyLower == "dobjects" then
      local function get()
        loadUnits("dynamicObjects")
        return self.internal.dynamicObjects
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "objects" then
      local function get()
        loadUnits("objects")
        return self.internal.objects
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "mouseover" then
      self[key] = self.internal.mouseover
      return self.internal.mouseover
    elseif keyLower == "player" then
      self[key] = self.internal.player
      return self.internal.player
    elseif keyLower == "pet" then
      self[key] = self.internal.pet
      return self.internal.pet
    elseif keyLower == "target" then
      self[key] = self.internal.target
      return self.internal.target
    elseif keyLower == "focus" then
      self[key] = self.internal.focus
      return self.internal.focus
    elseif keyLower == "group" then
      local function get()
        return self.internal.group or {}
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "arena1" or keyLower == "arena2" or keyLower == "arena3" or keyLower == "arena4" or keyLower == "arena5" or keyLower == "party1" or keyLower == "party2" or keyLower == "party3" or
      keyLower == "party4" then
      self[key] = self.internal[keyLower]
      return self.internal[keyLower]
    elseif keyLower == "fullgroup" or keyLower == "fgroup" then
      local function get()
        return self.internal.fullGroup
      end
      return cacheReturn(key, keyLower, selection, get, "single")
    elseif keyLower == "missiles" then
      if Tinkr.Util.Draw then
        if not self.internal.loaded["missiles"] then
          local size = #self.internal.missiles
          for m in ObjectManager:Missiles() do
            self.internal.missiles[size + 1] = m
            size = size + 1
          end
          self.internal.loaded["missiles"] = true
        end
        return self.internal.missiles
      elseif GetMissileCount and GetMissileWithIndex then
        if not self.internal.loaded["missiles"] then
          local count = GetMissileCount()
          for i = 1, count do
            local spellId, spellVisualId, x, y, z, source, sx, sy, sz, target, tx, ty, tz = GetMissileWithIndex(i)
            local missile = {
              source = source,
              target = target,
              spellId = spellId,
              -- model pos (?) not sure if daemonic supports this?
              mx = x,
              my = y,
              mz = z,
              -- current pos
              cx = x,
              cy = y,
              cz = z,
              -- initial pos
              ix = sx,
              iy = sy,
              iz = sz,
              -- target pos
              tx = tx,
              ty = ty,
              tz = tz
            }
            self.internal.missiles[#self.internal.missiles + 1] = missile
          end
        end
        return self.internal.missiles
      end
    elseif keyLower == "ingroup" or keyLower == "grouptype" then
      local function func()
        return self.arena and "party" or UnitInRaid("player") and "raid" or UnitInParty("player") and "party"
      end
      return cacheReturn(key, keyLower, selection, func)
    elseif keyLower == "hello" or keyLower == "helloworld" then
      return "Ohhh wowie, you made it! How are you? Don't respond, that's weird."
    elseif keyLower == "instancetype" then
      return self.instance2
    elseif keyLower == "enemiesaround" or keyLower == "enemiesaroundpoint" or keyLower == "enemiesaroundposition" then
      return self.internal.enemiesAroundPoint
    end
    if self.internal[keyLower] then
      return self.internal[keyLower]
    else
      return rawget(self, key)
    end
  end
  -- Use __newindex to write additions to blink api to blink.internal and create a strlower match for it above so it's automatically non-case-sensitive
  -- __newindex = function(self, key)
  --     print(self, key)
  -- end
}
setmetatable(blink, blinkKeys)

blink.print = function(txt, bad, version)
  print("|cFFFFFFFFB|cFFE6F6F6l|cFF99D9D9i|cFF99D9D9n|cFF00FFFFk" 
  .. (version and " v" .. APIVersion or "") .. ":|r|r|r|r|r|r|r",
  (bad ~= "init" and (bad and "|cFF99D9D9" or "|cFF99D9D9") or "") .. txt)
end

-- update callbacks available before anything else loaded
blink.enabledCallbacks = {}
blink.updateCallbacks = {}
blink.addUpdateCallback = function(callback, onEnabled)
  if onEnabled then
    tinsert(blink.enabledCallbacks, callback)
  else
    tinsert(blink.updateCallbacks, callback)
  end
  return {
    cancel = function()
      if onEnabled then
        for i = 1, #blink.enabledCallbacks do
          if blink.enabledCallbacks[i] == callback then
            tremove(blink.enabledCallbacks, i)
            break
          end
        end
      else
        for i = 1, #blink.updateCallbacks do
          if blink.updateCallbacks[i] == callback then
            tremove(blink.updateCallbacks, i)
            break
          end
        end
      end
    end
  }
end
blink.onTick = blink.addUpdateCallback
blink.ontick = blink.onTick

blink.actualUpdateCallbacks = {}
blink.actualEnabledUpdateCallbacks = {}
blink.addActualUpdateCallback = function(callback, onEnabled)
  if onEnabled then
    tinsert(blink.actualEnabledUpdateCallbacks, callback)
  else
    tinsert(blink.actualUpdateCallbacks, callback)
  end
end
blink.onUpdate = blink.addActualUpdateCallback
blink.onupdate = blink.onUpdate

local LibStub = {
  libs = {},
  minors = {}
}
local LIBSTUB_MAJOR = LibStub
LibStub.minor = LIBSTUB_MINOR

function LibStub:NewLibrary(major, minor)
  assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
  minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")

  local oldminor = self.minors[major]
  if oldminor and oldminor >= minor then
    return nil
  end
  self.minors[major], self.libs[major] = minor, self.libs[major] or {}
  return self.libs[major], oldminor
end

function LibStub:GetLibrary(major, silent)
  if not self.libs[major] and not silent then
    error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
  end
  return self.libs[major], self.minors[major]
end

function LibStub:IterateLibraries()
  return pairs(self.libs)
end

setmetatable(LibStub, {
  __call = LibStub.GetLibrary
})

do
  local MAJOR, MINOR = "CallbackHandler-1.0", 6
  local CallbackHandler = LibStub:NewLibrary(MAJOR, MINOR)

  if not CallbackHandler then
    return
  end -- No upgrade needed

  local meta = {
    __index = function(tbl, key)
      tbl[key] = {}
      return tbl[key]
    end
  }

  -- Lua APIs
  local tconcat = table.concat
  local assert, error, loadstring = assert, error, loadstring
  local setmetatable, rawset, rawget = setmetatable, rawset, rawget
  local next, select, pairs, type, tostring = next, select, pairs, type, tostring

  -- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
  -- List them here for Mikk's FindGlobals script
  -- GLOBALS: geterrorhandler

  local xpcall = xpcall

  local function errorhandler(err)
    return geterrorhandler()(err)
  end

  local function CreateDispatcher(argCount)
    local code = [[
		local next, xpcall, eh = ...
		local method, ARGS
		local function call() method(ARGS) end
		local function dispatch(handlers, ...)
			local index
			index, method = next(handlers)
			if not method then return end
			local OLD_ARGS = ARGS
			ARGS = ...
			repeat
				xpcall(call, eh)
				index, method = next(handlers, index)
			until not method
			ARGS = OLD_ARGS
		end
		return dispatch
		]]

    local ARGS, OLD_ARGS = {}, {}
    for i = 1, argCount do
      ARGS[i], OLD_ARGS[i] = "arg" .. i, "old_arg" .. i
    end
    code = code:gsub("OLD_ARGS", tconcat(OLD_ARGS, ", ")):gsub("ARGS", tconcat(ARGS, ", "))
    return assert(loadstring(code, "safecall Dispatcher[" .. argCount .. "]"))(next, xpcall, errorhandler)
  end

  local Dispatchers = setmetatable({}, {
    __index = function(self, argCount)
      local dispatcher = CreateDispatcher(argCount)
      rawset(self, argCount, dispatcher)
      return dispatcher
    end
  })

  --------------------------------------------------------------------------
  -- CallbackHandler:New
  --
  --   target            - target object to embed public APIs in
  --   RegisterName      - name of the callback registration API, default "RegisterCallback"
  --   UnregisterName    - name of the callback unregistration API, default "UnregisterCallback"
  --   UnregisterAllName - name of the API to unregister all callbacks, default "UnregisterAllCallbacks". false == don't publish this API.

  function CallbackHandler:New(target, RegisterName, UnregisterName, UnregisterAllName, OnUsed, OnUnused)
    -- TODO: Remove this after beta has gone out
    assert(not OnUsed and not OnUnused, "ACE-80: OnUsed/OnUnused are deprecated. Callbacks are now done to registry.OnUsed and registry.OnUnused")

    RegisterName = RegisterName or "RegisterCallback"
    UnregisterName = UnregisterName or "UnregisterCallback"
    if UnregisterAllName == nil then -- false is used to indicate "don't want this method"
      UnregisterAllName = "UnregisterAllCallbacks"
    end

    -- we declare all objects and exported APIs inside this closure to quickly gain access
    -- to e.g. function names, the "target" parameter, etc

    -- Create the registry object
    local events = setmetatable({}, meta)
    local registry = {
      recurse = 0,
      events = events
    }

    -- registry:Fire() - fires the given event/message into the registry
    function registry:Fire(eventname, ...)
      if not rawget(events, eventname) or not next(events[eventname]) then
        return
      end
      local oldrecurse = registry.recurse
      registry.recurse = oldrecurse + 1

      Dispatchers[select('#', ...) + 1](events[eventname], eventname, ...)

      registry.recurse = oldrecurse

      if registry.insertQueue and oldrecurse == 0 then
        -- Something in one of our callbacks wanted to register more callbacks; they got queued
        for eventname, callbacks in pairs(registry.insertQueue) do
          local first = not rawget(events, eventname) or not next(events[eventname]) -- test for empty before. not test for one member after. that one member may have been overwritten.
          for self, func in pairs(callbacks) do
            events[eventname][self] = func
            -- fire OnUsed callback?
            if first and registry.OnUsed then
              registry.OnUsed(registry, target, eventname)
              first = nil
            end
          end
        end
        registry.insertQueue = nil
      end
    end

    -- Registration of a callback, handles:
    --   self["method"], leads to self["method"](self, ...)
    --   self with function ref, leads to functionref(...)
    --   "addonId" (instead of self) with function ref, leads to functionref(...)
    -- all with an optional arg, which, if present, gets passed as first argument (after self if present)
    target[RegisterName] = function(self, eventname, method, ... --[[actually just a single arg]] )
      if type(eventname) ~= "string" then
        error("Usage: " .. RegisterName .. "(eventname, method[, arg]): 'eventname' - string expected.", 2)
      end

      method = method or eventname

      local first = not rawget(events, eventname) or not next(events[eventname]) -- test for empty before. not test for one member after. that one member may have been overwritten.

      if type(method) ~= "string" and type(method) ~= "function" then
        error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): 'methodname' - string or function expected.", 2)
      end

      local regfunc

      if type(method) == "string" then
        -- self["method"] calling style
        if type(self) ~= "table" then
          error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): self was not a table?", 2)
        elseif self == target then
          error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): do not use Library:" .. RegisterName .. "(), use your own 'self'", 2)
        elseif type(self[method]) ~= "function" then
          error("Usage: " .. RegisterName .. "(\"eventname\", \"methodname\"): 'methodname' - method '" .. tostring(method) .. "' not found on self.", 2)
        end

        if select("#", ...) >= 1 then -- this is not the same as testing for arg==nil!
          local arg = select(1, ...)
          regfunc = function(...)
            self[method](self, arg, ...)
          end
        else
          regfunc = function(...)
            self[method](self, ...)
          end
        end
      else
        -- function ref with self=object or self="addonId" or self=thread
        if type(self) ~= "table" and type(self) ~= "string" and type(self) ~= "thread" then
          error("Usage: " .. RegisterName .. "(self or \"addonId\", eventname, method): 'self or addonId': table or string or thread expected.", 2)
        end

        if select("#", ...) >= 1 then -- this is not the same as testing for arg==nil!
          local arg = select(1, ...)
          regfunc = function(...)
            method(arg, ...)
          end
        else
          regfunc = method
        end
      end

      if events[eventname][self] or registry.recurse < 1 then
        -- if registry.recurse<1 then
        -- we're overwriting an existing entry, or not currently recursing. just set it.
        events[eventname][self] = regfunc
        -- fire OnUsed callback?
        if registry.OnUsed and first then
          registry.OnUsed(registry, target, eventname)
        end
      else
        -- we're currently processing a callback in this registry, so delay the registration of this new entry!
        -- yes, we're a bit wasteful on garbage, but this is a fringe case, so we're picking low implementation overhead over garbage efficiency
        registry.insertQueue = registry.insertQueue or setmetatable({}, meta)
        registry.insertQueue[eventname][self] = regfunc
      end
    end

    -- Unregister a callback
    target[UnregisterName] = function(self, eventname)
      if not self or self == target then
        error("Usage: " .. UnregisterName .. "(eventname): bad 'self'", 2)
      end
      if type(eventname) ~= "string" then
        error("Usage: " .. UnregisterName .. "(eventname): 'eventname' - string expected.", 2)
      end
      if rawget(events, eventname) and events[eventname][self] then
        events[eventname][self] = nil
        -- Fire OnUnused callback?
        if registry.OnUnused and not next(events[eventname]) then
          registry.OnUnused(registry, target, eventname)
        end
      end
      if registry.insertQueue and rawget(registry.insertQueue, eventname) and registry.insertQueue[eventname][self] then
        registry.insertQueue[eventname][self] = nil
      end
    end

    -- OPTIONAL: Unregister all callbacks for given selfs/addonIds
    if UnregisterAllName then
      target[UnregisterAllName] = function(...)
        if select("#", ...) < 1 then
          error("Usage: " .. UnregisterAllName .. "([whatFor]): missing 'self' or \"addonId\" to unregister events for.", 2)
        end
        if select("#", ...) == 1 and ... == target then
          error("Usage: " .. UnregisterAllName .. "([whatFor]): supply a meaningful 'self' or \"addonId\"", 2)
        end

        for i = 1, select("#", ...) do
          local self = select(i, ...)
          if registry.insertQueue then
            for eventname, callbacks in pairs(registry.insertQueue) do
              if callbacks[self] then
                callbacks[self] = nil
              end
            end
          end
          for eventname, callbacks in pairs(events) do
            if callbacks[self] then
              callbacks[self] = nil
              -- Fire OnUnused callback?
              if registry.OnUnused and not next(callbacks) then
                registry.OnUnused(registry, target, eventname)
              end
            end
          end
        end
      end
    end

    return registry
  end
end

-- Retail Only
if blink.gameVersion == 1 then
  local MAJOR = "LibInspect"

  local LibInspect = {
    version = 69.0
  }

  LibInspect.events = LibInspect.events or LibStub("CallbackHandler-1.0"):New(LibInspect)
  if not LibInspect.events then
    error("LibInspect requires CallbackHandler")
  end

  local UPDATE_EVENT = "GroupInSpecT_Update"
  local REMOVE_EVENT = "GroupInSpecT_Remove"
  local INSPECT_READY_EVENT = "GroupInSpecT_InspectReady"
  local QUEUE_EVENT = "GroupInSpecT_QueueChanged"

  local COMMS_PREFIX = "LGIST11"
  local COMMS_FMT = "1"
  local COMMS_DELIM = "\a"

  local INSPECT_DELAY = 1.5
  local INSPECT_TIMEOUT = 10 -- If we get no notification within 10s, give up on unit

  local MAX_ATTEMPTS = 2

  --[===[@debug@
    lib.debug = false
    local function debug (...)
        if lib.debug then  -- allow programmatic override of debug output by client addons
        print (...)
        end
    end
    --@end-debug@]===]

  function LibInspect.events:OnUsed(target, eventname)
    if eventname == INSPECT_READY_EVENT then
      target.inspect_ready_used = true
    end
  end

  function LibInspect.events:OnUnused(target, eventname)
    if eventname == INSPECT_READY_EVENT then
      target.inspect_ready_used = nil
    end
  end

  -- Frame for events
  local frame = _G[MAJOR .. "_Frame"] or CreateFrame("Frame", MAJOR .. "_Frame")
  LibInspect.frame = frame
  frame:Hide()
  frame:UnregisterAllEvents()
  frame:RegisterEvent("PLAYER_LOGIN")
  frame:RegisterEvent("PLAYER_LOGOUT")
  if not frame.OnEvent then
    frame.OnEvent = function(this, event, ...)
      local eventhandler = LibInspect[event]
      return eventhandler and eventhandler(LibInspect, ...)
    end
    frame:SetScript("OnEvent", frame.OnEvent)
  end

  -- Hide our run-state in an easy-to-dump object
  LibInspect.state = {
    mainq = {},
    staleq = {}, -- inspect queues
    t = 0,
    last_inspect = 0,
    current_guid = nil,
    throttle = 0,
    tt = 0,
    debounce_send_update = 0
  }
  LibInspect.cache = {}
  LibInspect.static_cache = {}

  -- Note: if we cache NotifyInspect, we have to hook before we cache it!
  if not LibInspect.hooked then
    hooksecurefunc("NotifyInspect", function(...)
      return LibInspect:NotifyInspect(...)
    end)
    LibInspect.hooked = true
  end
  function LibInspect:NotifyInspect(unit)
    self.state.last_inspect = GetTime()
  end

  -- Get local handles on the key API functions
  local CanInspect = _G.CanInspect
  local ClearInspectPlayer = _G.ClearInspectPlayer
  local GetClassInfo = _G.GetClassInfo
  local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
  local GetNumSpecializationsForClassID = _G.GetNumSpecializationsForClassID
  local GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID
  local GetInspectSelectedPvpTalent = _G.C_SpecializationInfo.GetInspectSelectedPvpTalent
  local GetInspectSpecialization = _G.GetInspectSpecialization
  local GetSpecialization = _G.GetSpecialization
  local GetSpecializationInfo = _G.GetSpecializationInfo
  local GetSpecializationInfoForClassID = _G.GetSpecializationInfoForClassID
  local GetSpecializationRoleByID = _G.GetSpecializationRoleByID
  local GetSpellInfo = _G.GetSpellInfo
  local GetPvpTalentInfoByID = _G.GetPvpTalentInfoByID
  local GetPvpTalentSlotInfo = _G.C_SpecializationInfo.GetPvpTalentSlotInfo
  local GetTalentInfo = _G.GetTalentInfo
  local GetTalentInfoByID = _G.GetTalentInfoByID
  local IsInRaid = _G.IsInRaid
  -- local NotifyInspect                   = _G.NotifyInspect -- Don't cache, as to avoid missing future hooks
  local GetNumClasses = _G.GetNumClasses
  local UnitExists = _G.UnitExists
  local UnitGUID = _G.UnitGUID
  local UnitInParty = _G.UnitInParty
  local UnitInRaid = _G.UnitInRaid
  local UnitIsConnected = _G.UnitIsConnected
  local UnitIsPlayer = _G.UnitIsPlayer
  local UnitIsUnit = _G.UnitIsUnit
  local UnitName = _G.UnitName
  local SendAddonMessage = _G.C_ChatInfo.SendAddonMessage
  local RegisterAddonMessagePrefix = _G.C_ChatInfo.RegisterAddonMessagePrefix

  local MAX_TALENT_TIERS = _G.MAX_TALENT_TIERS
  local NUM_TALENT_COLUMNS = _G.NUM_TALENT_COLUMNS
  local NUM_PVP_TALENT_SLOTS = 4

  local global_spec_id_roles_detailed = {
    -- Death Knight
    [250] = "tank", -- Blood
    [251] = "melee", -- Frost
    [252] = "melee", -- Unholy
    -- Demon Hunter
    [577] = "melee", -- Havoc
    [581] = "tank", -- Vengeance
    -- Druid
    [102] = "ranged", -- Balance
    [103] = "melee", -- Feral
    [104] = "tank", -- Guardian
    [105] = "healer", -- Restoration
    -- Hunter
    [253] = "ranged", -- Beast Mastery
    [254] = "ranged", -- Marksmanship
    [255] = "melee", -- Survival
    -- Mage
    [62] = "ranged", -- Arcane
    [63] = "ranged", -- Fire
    [64] = "ranged", -- Frost
    -- Monk
    [268] = "tank", -- Brewmaster
    [269] = "melee", -- Windwalker
    [270] = "healer", -- Mistweaver
    -- Paladin
    [65] = "healer", -- Holy
    [66] = "tank", -- Protection
    [70] = "melee", -- Retribution
    -- Priest
    [256] = "healer", -- Discipline
    [257] = "healer", -- Holy
    [258] = "ranged", -- Shadow
    -- Rogue
    [259] = "melee", -- Assassination
    [260] = "melee", -- Combat
    [261] = "melee", -- Subtlety
    -- Shaman
    [262] = "ranged", -- Elemental
    [263] = "melee", -- Enhancement
    [264] = "healer", -- Restoration
    -- Warlock
    [265] = "ranged", -- Affliction
    [266] = "ranged", -- Demonology
    [267] = "ranged", -- Destruction
    -- Warrior
    [71] = "melee", -- Arms
    [72] = "melee", -- Fury
    [73] = "tank", -- Protection
    -- Evoker
    [1473] = "ranged", -- Augmentation
    [1467] = "ranged", -- Devastation
    [1468] = "healer" -- Preservation
  }

  local class_fixed_roles = {
    HUNTER = "DAMAGER",
    MAGE = "DAMAGER",
    ROGUE = "DAMAGER",
    WARLOCK = "DAMAGER"
  }

  local class_fixed_roles_detailed = {
    MAGE = "ranged",
    ROGUE = "melee",
    WARLOCK = "ranged"
  }

  -- Inspects only work after being fully logged in, so track that
  function LibInspect:PLAYER_LOGIN()
    self.state.logged_in = true

    self:CacheGameData()

    frame:RegisterEvent("INSPECT_READY")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UNIT_LEVEL")
    frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("UNIT_NAME_UPDATE")
    frame:RegisterEvent("UNIT_AURA")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    RegisterAddonMessagePrefix(COMMS_PREFIX)

    local guid = UnitGUID("player") -- ObjectPointer("player")
    local info = self:BuildInfo("player")
    self.events:Fire(UPDATE_EVENT, guid, "player", info)
  end

  function LibInspect:PLAYER_LOGOUT()
    self.state.logged_in = false
  end

  -- Simple timer

  LibInspect.state.t = 0
  if not frame.OnUpdate then -- ticket #4 if the OnUpdate code every changes we should stop borrowing the existing handler
    frame.OnUpdate = function(this, elapsed)
      LibInspect.state.t = LibInspect.state.t + elapsed
      LibInspect.state.tt = LibInspect.state.tt + elapsed
      if LibInspect.state.t > INSPECT_DELAY then
        LibInspect:ProcessQueues()
        LibInspect.state.t = 0
      end
      -- Unthrottle, essentially allowing 1 msg every 3 seconds, but with substantial burst capacity
      if LibInspect.state.tt > 3 and LibInspect.state.throttle > 0 then
        LibInspect.state.throttle = LibInspect.state.throttle - 1
        LibInspect.state.tt = 0
      end
      if LibInspect.state.debounce_send_update > 0 then
        local debounce = LibInspect.state.debounce_send_update - elapsed
        LibInspect.state.debounce_send_update = debounce
        if debounce <= 0 then
          LibInspect:SendLatestSpecData()
        end
      end
    end
    frame:SetScript("OnUpdate", frame.OnUpdate) -- this is good regardless of the handler check above because otherwise a new anonymous function is created every time the OnUpdate code runs
  end

  -- Internal library functions

  -- Caches to deal with API shortcomings as well as performance
  LibInspect.static_cache.global_specs = {} -- [gspec]         -> { .idx, .name_localized, .description, .icon, .background, .role }
  LibInspect.static_cache.class_to_class_id = {} -- [CLASS]         -> class_id

  -- The talents cache can no longer be pre-fetched on login, but is now constructed class-by-class as we inspect people.
  -- This probably means we want to only ever access it through the GetCachedTalentInfo() helper function below.
  LibInspect.static_cache.talents = {} -- [talent_id]      -> { .spell_id, .talent_id, .name_localized, .icon, .tier, .column }
  LibInspect.static_cache.pvp_talents = {} -- [talent_id]      -> { .spell_id, .talent_id, .name_localized, .icon }

  function LibInspect:GetCachedTalentInfo(class_id, tier, col, group, is_inspect, unit)
    local talent_id, name, icon, sel, _, spell_id = GetTalentInfo(tier, col, group, is_inspect, unit)
    if not talent_id then
      --[===[@debug@
        debug ("GetCachedTalentInfo("..tostring(class_id)..","..tier..","..col..","..group..","..tostring(is_inspect)..","..tostring(unit)..") returned nil") --@end-debug@]===]
      return {}
    end
    local class_talents = self.static_cache.talents
    if not class_talents[talent_id] then
      class_talents[talent_id] = {
        spell_id = spell_id,
        talent_id = talent_id,
        name_localized = name,
        icon = icon,
        tier = tier,
        column = col
      }
    end
    return class_talents[talent_id], sel
  end

  function LibInspect:GetCachedTalentInfoByID(talent_id)
    local class_talents = self.static_cache.talents
    if talent_id and not class_talents[talent_id] then
      local _, name, icon, _, _, spell_id, _, row, col = GetTalentInfoByID(talent_id)
      if not name then
        --[===[@debug@
            debug ("GetCachedTalentInfoByID("..tostring(talent_id)..") returned nil") --@end-debug@]===]
        return nil
      end
      class_talents[talent_id] = {
        spell_id = spell_id,
        talent_id = talent_id,
        name_localized = name,
        icon = icon,
        tier = row,
        column = col
      }
    end
    return class_talents[talent_id]
  end

  function LibInspect:GetCachedPvpTalentInfoByID(talent_id)
    local pvp_talents = self.static_cache.pvp_talents
    if talent_id and not pvp_talents[talent_id] then
      local _, name, icon, _, _, spell_id = GetPvpTalentInfoByID(talent_id)
      if not name then
        --[===[@debug@
            debug ("GetCachedPvpTalentInfo("..tostring(talent_id)..") returned nil") --@end-debug@]===]
        return nil
      end
      pvp_talents[talent_id] = {
        spell_id = spell_id,
        talent_id = talent_id,
        name_localized = name,
        icon = icon
      }
    end
    return pvp_talents[talent_id]
  end

  function LibInspect:CacheGameData()
    local gspecs = self.static_cache.global_specs
    gspecs[0] = {} -- Handle no-specialization case
    for class_id = 1, GetNumClasses() do
      for idx = 1, GetNumSpecializationsForClassID(class_id) do
        local gspec_id, name, description, icon, background = GetSpecializationInfoForClassID(class_id, idx)
        gspecs[gspec_id] = {}
        local gspec = gspecs[gspec_id]
        gspec.idx = idx
        gspec.name_localized = name
        gspec.description = description
        gspec.icon = icon
        gspec.background = background
        gspec.role = GetSpecializationRoleByID(gspec_id)
      end

      local _, class = GetClassInfo(class_id)
      self.static_cache.class_to_class_id[class] = class_id
    end
  end

  function LibInspect:GuidToUnit(guid)
    local info = self.cache[guid]
    if info and info.lku and UnitGUID(info.lku) == guid then
      return info.lku
    end

    for i, unit in ipairs(self:GroupUnits()) do
      if UnitExists(unit) and UnitGUID(unit) == guid then
        if info then
          info.lku = unit
        end
        return unit
      end
    end
  end

  function LibInspect:Query(unit)
    if not UnitIsPlayer(unit) then
      return
    end -- NPC

    if UnitIsUnit(unit, "player") then
      self.events:Fire(UPDATE_EVENT, UnitGUID("player"), "player", self:BuildInfo("player"))
      return
    end

    local mainq, staleq = self.state.mainq, self.state.staleq

    local guid = UnitGUID(unit)
    if not mainq[guid] then
      mainq[guid] = 1
      staleq[guid] = nil
      self.frame:Show() -- Start timer if not already running
      self.events:Fire(QUEUE_EVENT)
    end
  end

  function LibInspect:Refresh(unit)
    local guid = UnitGUID(unit)
    if not guid then
      return
    end
    --[===[@debug@
        debug ("Refreshing "..unit) --@end-debug@]===]
    if not self.state.mainq[guid] then
      self.state.staleq[guid] = 1
      self.frame:Show()
      self.events:Fire(QUEUE_EVENT)
    end
  end

  function LibInspect:ProcessQueues()
    if not self.state.logged_in then
      return
    end
    if InCombatLockdown() then
      return
    end -- Never inspect while in combat
    if UnitIsDead("player") then
      return
    end -- You can't inspect while dead, so don't even try
    if InspectFrame and InspectFrame:IsShown() then
      return
    end -- Don't mess with the UI's inspections

    local mainq = self.state.mainq
    local staleq = self.state.staleq

    if not next(mainq) and next(staleq) then
      --[===[@debug@
        debug ("Main queue empty, swapping main and stale queues") --@end-debug@]===]
      self.state.mainq, self.state.staleq = self.state.staleq, self.state.mainq
      mainq, staleq = staleq, mainq
    end

    if (self.state.last_inspect + INSPECT_TIMEOUT) < GetTime() then
      -- If there was an inspect going, it's timed out, so either retry or move it to stale queue
      local guid = self.state.current_guid
      if guid then
        --[===[@debug@
            debug ("Inspect timed out for "..guid) --@end-debug@]===]

        local count = mainq and mainq[guid] or (MAX_ATTEMPTS + 1)
        if not self:GuidToUnit(guid) then
          --[===[@debug@
            debug ("No longer applicable, removing from queues") --@end-debug@]===]
          mainq[guid], staleq[guid] = nil, nil
        elseif count > MAX_ATTEMPTS then
          --[===[@debug@
            debug ("Excessive retries, moving to stale queue") --@end-debug@]===]
          mainq[guid], staleq[guid] = nil, 1
        else
          mainq[guid] = count + 1
        end
        self.state.current_guid = nil
      end
    end

    if self.state.current_guid then
      return
    end -- Still waiting on our inspect data

    for guid, count in pairs(mainq) do
      local unit = self:GuidToUnit(guid)
      if not unit then
        --[===[@debug@
            debug ("No longer applicable, removing from queues") --@end-debug@]===]
        mainq[guid], staleq[guid] = nil, nil
      elseif not CanInspect(unit) or not UnitIsConnected(unit) then
        --[===[@debug@
            debug ("Cannot inspect "..unit..", aka "..(UnitName(unit) or "nil")..", moving to stale queue") --@end-debug@]===]
        mainq[guid], staleq[guid] = nil, 1
      else
        --[===[@debug@
            debug ("Inspecting "..unit..", aka "..(UnitName(unit) or "nil")) --@end-debug@]===]
        mainq[guid] = count + 1
        self.state.current_guid = guid
        NotifyInspect(unit)
        break
      end
    end

    if not next(mainq) and not next(staleq) and self.state.throttle == 0 and self.state.debounce_send_update <= 0 then
      frame:Hide() -- Cancel timer, nothing queued and no unthrottling to be done
    end
    self.events:Fire(QUEUE_EVENT)
  end

  function LibInspect:UpdatePlayerInfo(guid, unit, info)
    info.class_localized, info.class, info.race_localized, info.race, info.gender, info.name, info.realm = GetPlayerInfoByGUID(guid)
    local class = info.class
    if info.realm and info.realm == "" then
      info.realm = nil
    end
    info.class_id = class and self.static_cache.class_to_class_id[class]
    if not info.spec_role then
      info.spec_role = class and class_fixed_roles[class]
    end
    if not info.spec_role_detailed then
      info.spec_role_detailed = class and class_fixed_roles_detailed[class]
    end
    info.lku = unit
  end

  function LibInspect:BuildInfo(unit)
    local guid = UnitGUID(unit)
    if not guid then
      return
    end

    local cache = self.cache
    local info = cache[guid] or {}
    cache[guid] = info
    info.guid = guid

    self:UpdatePlayerInfo(guid, unit, info)
    -- On a cold login, GetPlayerInfoByGUID() doesn't seem to be usable, so mark as stale
    local class = info.class
    if not class and not self.state.mainq[guid] then
      self.state.staleq[guid] = 1
      self.frame:Show()
      self.events:Fire(QUEUE_EVENT)
    end

    local is_inspect = not UnitIsUnit(unit, "player")
    local spec = GetSpecialization()
    local gspec_id = is_inspect and GetInspectSpecialization(unit) or spec and GetSpecializationInfo(spec)

    local gspecs = self.static_cache.global_specs
    if not gspec_id or not gspecs[gspec_id] then -- not a valid spec_id
      info.global_spec_id = nil
    else
      info.global_spec_id = gspec_id
      local spec_info = gspecs[gspec_id]
      info.spec_index = spec_info.idx
      info.spec_name_localized = spec_info.name_localized
      info.spec_description = spec_info.description
      info.spec_icon = spec_info.icon
      info.spec_background = spec_info.background
      info.spec_role = spec_info.role
      info.spec_role_detailed = global_spec_id_roles_detailed[gspec_id]
    end

    if not info.spec_role then
      info.spec_role = class and class_fixed_roles[class]
    end
    if not info.spec_role_detailed then
      info.spec_role_detailed = class and class_fixed_roles_detailed[class]
    end

    info.talents = info.talents or {}
    info.pvp_talents = info.pvp_talents or {}

    -- Only scan talents when we have player data
    if info.spec_index then
      info.spec_group = GetActiveSpecGroup(is_inspect)
      wipe(info.talents)
      for tier = 1, MAX_TALENT_TIERS do
        for col = 1, NUM_TALENT_COLUMNS do
          local talent, sel = self:GetCachedTalentInfo(info.class_id, tier, col, info.spec_group, is_inspect, unit)
          if sel then
            info.talents[talent.talent_id] = talent
          end
        end
      end

      wipe(info.pvp_talents)
      if is_inspect then
        for index = 1, NUM_PVP_TALENT_SLOTS do
          local talent_id = GetInspectSelectedPvpTalent(unit, index)
          if talent_id then
            info.pvp_talents[talent_id] = self:GetCachedPvpTalentInfoByID(talent_id)
          end
        end
      else
        -- C_SpecializationInfo.GetAllSelectedPvpTalentIDs will sometimes return a lot of extra talents
        for index = 1, NUM_PVP_TALENT_SLOTS do
          local slot_info = GetPvpTalentSlotInfo(index)
          local talent_id = slot_info and slot_info.selectedTalentID
          if talent_id then
            info.pvp_talents[talent_id] = self:GetCachedPvpTalentInfoByID(talent_id)
          end
        end
      end
    end

    info.glyphs = info.glyphs or {} -- kept for addons that still refer to this

    if is_inspect and not UnitIsVisible(unit) and UnitIsConnected(unit) then
      info.not_visible = true
    end

    return info
  end

  function LibInspect:INSPECT_READY(guid)
    local unit = self:GuidToUnit(guid)
    local finalize = false
    if unit then
      if guid == self.state.current_guid then
        self.state.current_guid = nil -- Got what we asked for
        finalize = true
        --[===[@debug@
            debug ("Got inspection data for requested guid "..guid) --@end-debug@]===]
      end

      local mainq, staleq = self.state.mainq, self.state.staleq
      mainq[guid], staleq[guid] = nil, nil

      local gspec_id = GetInspectSpecialization(unit)
      if not self.static_cache.global_specs[gspec_id] then -- Bah, got garbage, flag as stale and try again
        staleq[guid] = 1
        return
      end

      self.events:Fire(UPDATE_EVENT, guid, unit, self:BuildInfo(unit))
      self.events:Fire(INSPECT_READY_EVENT, guid, unit)
    end
    if finalize then
      ClearInspectPlayer()
    end
    self.events:Fire(QUEUE_EVENT)
  end

  function LibInspect:PLAYER_ENTERING_WORLD()
    if self.commScope == "INSTANCE_CHAT" then
      -- Handle moving directly from one LFG to another
      self.commScope = nil
      self:UpdateCommScope()
    end
  end

  -- Group handling parts

  local members = {}
  function LibInspect:GROUP_ROSTER_UPDATE()
    local group = self.cache
    local units = self:GroupUnits()
    -- Find new members
    for i, unit in ipairs(self:GroupUnits()) do
      local guid = UnitGUID(unit)
      if guid then
        members[guid] = true
        if not group[guid] then
          self:Query(unit)
          -- Update with what we have so far (guid, unit, name/class/race?)
          self.events:Fire(UPDATE_EVENT, guid, unit, self:BuildInfo(unit))
        end
      end
    end
    -- Find removed members
    for guid in pairs(group) do
      if not members[guid] then
        group[guid] = nil
        self.events:Fire(REMOVE_EVENT, guid, nil)
      end
    end
    wipe(members)
    self:UpdateCommScope()
  end

  function LibInspect:DoPlayerUpdate()
    self:Query("player")
    self.state.debounce_send_update = 2.5 -- Hold off 2.5sec before sending update
    self.frame:Show()
  end

  function LibInspect:SendLatestSpecData()
    local scope = self.commScope
    if not scope then
      return
    end

    local guid = UnitGUID("player")
    local info = self.cache[guid]
    if not info then
      return
    end

    -- fmt, guid, global_spec_id, talent1 -> MAX_TALENT_TIERS, pvptalent1 -> NUM_PVP_TALENT_SLOTS
    -- sequentially, allow no gaps for missing talents we decode by index on the receiving end.
    local datastr = COMMS_FMT .. COMMS_DELIM .. guid .. COMMS_DELIM .. (info.global_spec_id or 0)
    local talentCount = 1
    for k in pairs(info.talents) do
      datastr = datastr .. COMMS_DELIM .. k
      talentCount = talentCount + 1
    end
    for i = talentCount, MAX_TALENT_TIERS do
      datastr = datastr .. COMMS_DELIM .. 0
    end
    talentCount = 1
    for k in pairs(info.pvp_talents) do
      datastr = datastr .. COMMS_DELIM .. k
      talentCount = talentCount + 1
    end
    for i = talentCount, NUM_PVP_TALENT_SLOTS do
      datastr = datastr .. COMMS_DELIM .. 0
    end

    --[===[@debug@
        debug ("Sending LGIST update to "..scope) --@end-debug@]===]
    SendAddonMessage(COMMS_PREFIX, datastr, scope)
  end

  function LibInspect:UpdateCommScope()
    local scope = (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or (IsInGroup(LE_PARTY_CATEGORY_HOME) and "PARTY")
    if self.commScope ~= scope then
      self.commScope = scope
      self:DoPlayerUpdate()
    end
  end

  -- Indicies for various parts of the split data msg
  local msg_idx = {}
  msg_idx.fmt = 1
  msg_idx.guid = msg_idx.fmt + 1
  msg_idx.global_spec_id = msg_idx.guid + 1
  msg_idx.talents = msg_idx.global_spec_id + 1
  msg_idx.end_talents = msg_idx.talents + MAX_TALENT_TIERS
  msg_idx.pvp_talents = msg_idx.end_talents + 1
  msg_idx.end_pvp_talents = msg_idx.pvp_talents + NUM_PVP_TALENT_SLOTS - 1

  function LibInspect:CHAT_MSG_ADDON(prefix, datastr, scope, sender)
    if prefix ~= COMMS_PREFIX or scope ~= self.commScope then
      return
    end
    --[===[@debug@
        debug ("Incoming LGIST update from "..(scope or "nil").."/"..(sender or "nil")..": "..(datastr:gsub(COMMS_DELIM,";") or "nil")) --@end-debug@]===]

    local data = {strsplit(COMMS_DELIM, datastr)}
    local fmt = data[msg_idx.fmt]
    if fmt ~= COMMS_FMT then
      return
    end -- Unknown format, ignore

    local guid = data[msg_idx.guid]

    local senderguid = UnitGUID(sender)
    if senderguid and senderguid ~= guid then
      return
    end

    local info = guid and self.cache[guid]
    if not info then
      return
    end -- Never allow random message to create new group member entries!

    local unit = self:GuidToUnit(guid)
    if not unit then
      return
    end
    if UnitIsUnit(unit, "player") then
      return
    end -- we're already up-to-date, comment out for solo debugging

    self.state.throttle = self.state.throttle + 1
    self.frame:Show() -- Ensure we're unthrottling
    if self.state.throttle > 40 then
      return
    end -- If we ever hit this, someone's being "funny"

    info.class_localized, info.class, info.race_localized, info.race, info.gender, info.name, info.realm = GetPlayerInfoByGUID(guid)
    if info.realm and info.realm == "" then
      info.realm = nil
    end
    info.class_id = self.static_cache.class_to_class_id[info.class]

    local gspecs = self.static_cache.global_specs

    local gspec_id = data[msg_idx.global_spec_id] and tonumber(data[msg_idx.global_spec_id])
    if not gspec_id or not gspecs[gspec_id] then
      return
    end -- Malformed message, avoid throwing errors by using this nil

    info.global_spec_id = gspec_id
    info.spec_index = gspecs[gspec_id].idx
    info.spec_name_localized = gspecs[gspec_id].name_localized
    info.spec_description = gspecs[gspec_id].description
    info.spec_icon = gspecs[gspec_id].icon
    info.spec_background = gspecs[gspec_id].background
    info.spec_role = gspecs[gspec_id].role
    info.spec_role_detailed = global_spec_id_roles_detailed[gspec_id]

    local need_inspect = nil -- shouldn't be needed, but just in case
    info.talents = wipe(info.talents or {})
    for i = msg_idx.talents, msg_idx.end_talents do
      local talent_id = tonumber(data[i]) or 0
      if talent_id > 0 then
        local talent = self:GetCachedTalentInfoByID(talent_id)
        if talent then
          info.talents[talent_id] = talent
        else
          need_inspect = 1
        end
      end
    end

    info.pvp_talents = wipe(info.pvp_talents or {})
    for i = msg_idx.pvp_talents, msg_idx.end_pvp_talents do
      local talent_id = tonumber(data[i]) or 0
      if talent_id > 0 then
        local talent = self:GetCachedPvpTalentInfoByID(talent_id)
        if talent then
          info.pvp_talents[talent_id] = talent
        else
          need_inspect = 1
        end
      end
    end

    info.glyphs = info.glyphs or {} -- kept for addons that still refer to this

    local mainq, staleq = self.state.mainq, self.state.staleq
    local want_inspect = not need_inspect and self.inspect_ready_used and (mainq[guid] or staleq[guid]) and 1 or nil
    mainq[guid], staleq[guid] = need_inspect, want_inspect
    if need_inspect or want_inspect then
      self.frame:Show()
    end

    --[===[@debug@
        debug ("Firing LGIST update event for unit "..unit..", GUID "..guid..", inspect "..tostring(not not need_inspect)) --@end-debug@]===]
    self.events:Fire(UPDATE_EVENT, guid, unit, info)
    self.events:Fire(QUEUE_EVENT)
  end

  function LibInspect:UNIT_LEVEL(unit)
    if UnitInRaid(unit) or UnitInParty(unit) then
      self:Refresh(unit)
    end
    if UnitIsUnit(unit, "player") then
      self:DoPlayerUpdate()
    end
  end

  function LibInspect:PLAYER_TALENT_UPDATE()
    self:DoPlayerUpdate()
  end

  function LibInspect:PLAYER_SPECIALIZATION_CHANGED(unit)
    --  This event seems to fire a lot, and for no particular reason *sigh*
    --  if UnitInRaid (unit) or UnitInParty (unit) then
    --    self:Refresh (unit)
    --  end
    if unit and UnitIsUnit(unit, "player") then
      self:DoPlayerUpdate()
    end
  end

  function LibInspect:UNIT_NAME_UPDATE(unit)
    local group = self.cache
    local guid = UnitGUID(unit)
    local info = guid and group[guid]
    if info then
      self:UpdatePlayerInfo(guid, unit, info)
      if info.name ~= UNKNOWN then
        self.events:Fire(UPDATE_EVENT, guid, unit, info)
      end
    end
  end

  -- Always get a UNIT_AURA when a unit's UnitIsVisible() changes
  function LibInspect:UNIT_AURA(unit)
    local group = self.cache
    local guid = UnitGUID(unit)
    local info = guid and group[guid]
    if info then
      if not UnitIsUnit(unit, "player") then
        if UnitIsVisible(unit) then
          if info.not_visible then
            info.not_visible = nil
            --[===[@debug@
                debug (unit..", aka "..(UnitName(unit) or "nil")..", is now visible") --@end-debug@]===]
            if not self.state.mainq[guid] then
              self.state.staleq[guid] = 1
              self.frame:Show()
              self.events:Fire(QUEUE_EVENT)
            end
          end
        elseif UnitIsConnected(unit) then
          --[===[@debug@
            if not info.not_visible then
                debug (unit..", aka "..(UnitName(unit) or "nil")..", is no longer visible")
            end
            --@end-debug@]===]
          info.not_visible = true
        end
      end
    end
  end

  function LibInspect:UNIT_SPELLCAST_SUCCEEDED(unit, _, spell_id)
    if spell_id == 200749 then -- Activating Specialization
      self:Query(unit) -- Definitely changed, so high prio refresh
    end
  end

  -- External LibInspectrary functions

  function LibInspect:QueuedInspections()
    local q = {}
    for guid in pairs(self.state.mainq) do
      table.insert(q, guid)
    end
    return q
  end

  function LibInspect:StaleInspections()
    local q = {}
    for guid in pairs(self.state.staleq) do
      table.insert(q, guid)
    end
    return q
  end

  function LibInspect:IsInspectQueued(guid)
    return guid and ((self.state.mainq[guid] or self.state.staleq[guid]) and true)
  end

  function LibInspect:GetCachedInfo(guid)
    local group = self.cache
    return guid and group[guid]
  end

  function LibInspect:Rescan(guid)
    local mainq, staleq = self.state.mainq, self.state.staleq
    if guid then
      local unit = self:GuidToUnit(guid)
      if unit then
        if UnitIsUnit(unit, "player") then
          self.events:Fire(UPDATE_EVENT, guid, "player", self:BuildInfo("player"))
        elseif not mainq[guid] then
          staleq[guid] = 1
        end
      end
    else
      for i, unit in ipairs(self:GroupUnits()) do
        if UnitExists(unit) then
          if UnitIsUnit(unit, "player") then
            self.events:Fire(UPDATE_EVENT, UnitGUID("player"), "player", self:BuildInfo("player"))
          else
            local guid = UnitGUID(unit)
            if guid and not mainq[guid] then
              staleq[guid] = 1
            end
          end
        end
      end
    end
    self.frame:Show() -- Start timer if not already running

    -- Evict any stale entries
    self:GROUP_ROSTER_UPDATE()
    self.events:Fire(QUEUE_EVENT)
  end

  local unitstrings = {
    raid = {"player"}, -- This seems to be needed under certain circumstances. Odd.
    party = {"player"}, -- Player not part of partyN
    player = {"player"}
  }
  for i = 1, 40 do
    table.insert(unitstrings.raid, "raid" .. i)
  end
  for i = 1, 4 do
    table.insert(unitstrings.party, "party" .. i)
  end

  -- Returns an array with the set of unit ids for the current group
  function LibInspect:GroupUnits()
    local units
    if IsInRaid() then
      units = unitstrings.raid
    elseif GetNumSubgroupMembers() > 0 then
      units = unitstrings.party
    else
      units = unitstrings.player
    end
    return units
  end

  -- If demand-loaded, we need to synthesize a login event
  if IsLoggedIn() then
    LibInspect:PLAYER_LOGIN()
  end

  blink.LibInspect = LibInspect
end

local upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local lowerCase = "abcdefghijklmnopqrstuvwxyz"
local numbers = "0123456789"
local alphaNumeric = upperCase .. lowerCase .. numbers
local onlyLetters = upperCase .. lowerCase

local strsub = string.sub
local random = math.random
function string.random(length, noNumbers)
  local output = ""
  local cs = noNumbers and onlyLetters or alphaNumeric
  for i = 1, length do
    local rand = random(#cs)
    output = output .. strsub(cs, rand, rand)
  end
  return output
end

function blink.randomVariable(length)
  local output = ""
  local seed = random(#onlyLetters)
  output = output .. strsub(onlyLetters, seed, seed)
  for i = 1, length - 1 do
    seed = random(#alphaNumeric)
    output = output .. strsub(alphaNumeric, seed, seed)
  end
  return output
end

-- Protected Movement Overrides
-- CameraOrSelectOrMoveStart = function() Evaluator:CallProtectedFunction("CameraOrSelectOrMoveStart") end
-- CameraOrSelectOrMoveStop = function() Evaluator:CallProtectedFunction("CameraOrSelectOrMoveStop") end

local movementFuncs = {"MoveForwardStart", "MoveBackwardStart", "StrafeLeftStart", "StrafeRightStart", "StrafeLeftStop", "StrafeRightStop", "JumpOrAscendStart"}

-- hook thing
if not blink.protected then
  blink.protected = {}

  blink.protected.Objects = Objects

  local function updateProtectedFunctions()
    blink.protected.CameraOrSelectOrMoveStart = CameraOrSelectOrMoveStart
    blink.protected.TurnOrActionStart = TurnOrActionStart
    blink.protected.TurnOrActionStop = TurnOrActionStop
    blink.protected.MoveForwardStart = MoveForwardStart
    blink.protected.TurnLeftStart = TurnLeftStart
    blink.protected.TurnRightStart = TurnRightStart
    blink.protected.TurnLeftStop = TurnLeftStop
    blink.protected.TurnRightStop = TurnRightStop
    blink.protected.StrafeRightStart = StrafeRightStart
    blink.protected.StrafeLeftStart = StrafeLeftStart
    blink.protected.StrafeRightStop = StrafeRightStop
    blink.protected.StrafeLeftStop = StrafeLeftStop
    blink.protected.MoveBackwardStart = MoveBackwardStart
    blink.protected.JumpOrAscendStart = JumpOrAscendStart
    blink.protected.MoveTo = MoveTo
    blink.protected.PetAttack = function(str)
      str = str or "";
      Evaluator:CallProtectedFunction("(function() PetAttack(" .. str .. ") end)")
    end
    blink.protected.RunMacroText = function(str)
      Evaluator:CallProtectedFunction("(function() C_Macro.RunMacroText('" .. str .. "', 0) end)")
    end
    blink.protected.CancelForm = function()
      Evaluator:CallProtectedFunction('(function() C_Macro.RunMacroText("/cancelform", 0) end)')
    end
    blink.protected.CancelShapeshiftForm = blink.protected.CancelForm
    blink.protected.ABP = function(one, two)
      Evaluator:CallProtectedFunction("(function() AcceptBattlefieldPort(" .. tostring(one) .. "," .. tostring(two) .. ") end)")
    end
    blink.protected.JA = function(password)
      if password ~= "PISSY WISSY" then
        return
      end
      Evaluator:CallProtectedFunction('(function() JoinArena() end)')
    end
    blink.protected.JoinBattlefield = function(mode)
      return Evaluator:CallProtectedFunction("(function() JoinBattlefield(" .. mode .. ", true) end)")
    end
    blink.protected.AcceptQueue = function(one, two)
      Evaluator:CallProtectedFunction([[(function() 
            
            if not blink then return false end

            local queuePop
            for i=1,3 do
                if GetBattlefieldStatus(i) == "confirm" then
                    queuePop = i
                end
            end

            --never miss queue
            if queuePop then
                if not blink.queuePopStart then
                    blink.queuePopStart = blink.time
                else
                    if blink.time - blink.queuePopStart > 5 then
                        AcceptBattlefieldPort(queuePop, 1)
                    end
                end
            else
                blink.queuePopStart = nil
            end
            
            if blink.queuePopStart and blink.time - blink.queuePopStart > 30 then blink.queuePopStart = nil end

        end)]])
    end
  end

  Evaluator:CallProtectedFunction("(function() _G.PCALLSX = {} end)")

  local storeProtected = function(f)
    local str = "(function() _G.PCALLSX." .. f .. " = _G." .. f .. " end)"
    Evaluator:CallProtectedFunction(str)
  end

  for i = 1, #movementFuncs do
    storeProtected(movementFuncs[i])
  end

  updateProtectedFunctions()

end

local overwrite = function(f)
  if Tinkr.type == "noname" then return end
  _G[f] = function()
  end
end

local restoreProtected = function(f)
  if Tinkr.type == "noname" then
    --Unlock(function()
    --  _G[f] = blink.env[f]
    --end)
  else
    local str = "(function() _G." .. f .. " = _G.PCALLSX." .. f .. " end)"
    return Evaluator:CallProtectedFunction(str)
  end
end

if blink.saved and blink.saved.securityStuff == nil then
  blink.saved.securityStuff = true
end

if Tinkr.type == "daemonic" or Tinkr.type == "blade" then
  blink.FaceDirection = function(angle, update)
    if not FaceDirection then
      return
    end
    player = player or blink.player
    if not (not HasFullControl() or player.cc or player.buff(45438) or player.dead or player.buff(320224)) then
      -- if not blink.saved.securityStuff or update == "gay" then
      FaceDirection(angle, update)
      -- end
    end
  end
elseif Tinkr.Util.Draw then
  -- -- hook thing
  -- local ogThing = _G.C_NamePlate.SetTargetClampingInsets
  -- _G["C_NamePlate_SetTargetClampingInsets"] = ogThing
  -- _G.C_NamePlate.SetTargetClampingInsets = function(...)
  --     return Evaluator:CallProtectedFunction("C_NamePlate_SetTargetClampingInsets", ...)
  -- end
  blink.FaceDirection = function(angle, update)
    player = player or blink.player
    if not (not HasFullControl() or player.cc or player.buff(45438) or player.dead or player.buff(320224)) then
      if update == "gay" then
        SetHeading(angle)
      else
        FaceDirection(angle, false)
        FaceDirection(angle, true)
        --if not blink.saved.securityStuff then
          SendMovementHeartbeat()
        --end
      end
    end
  end
elseif Tinkr.type == "noname" then
  blink.FaceDirection = function(angle, update)
    if not SetPlayerFacing then
      return
    end
    player = player or blink.player
    if not (not HasFullControl() or player.cc or player.buff(45438) or player.dead or player.buff(320224)) then
      SetPlayerFacing(angle)
    end
  end
end

local originalStickyTargeting = GetCVar("deselectOnClick")

blink.controlFacing = function(elapsed)
  SetCVar("deselectOnClick", "0")
  local currentTarget = Object("target")
  if not elapsed then
    local IsTurningOrActing = IsMouseButtonDown("RightButton")
    local CameraSelectingOrMoving = IsMouseButtonDown("LeftButton")
    if IsTurningOrActing or CameraSelectingOrMoving then
      TurnOrActionStop()
      if not CameraSelectingOrMoving then
        CameraOrSelectOrMoveStop()
      end
      CameraOrSelectOrMoveStart()
      TurnOrActionStart = CameraOrSelectOrMoveStart
      -- TurnOrActionStop = CameraOrSelectOrMoveStop
      TurnRightStart = function()
      end
      TurnLeftStart = function()
      end
    else
      TurnOrActionStop()
      CameraOrSelectOrMoveStop()
      TurnOrActionStart = CameraOrSelectOrMoveStart
      -- TurnOrActionStop = CameraOrSelectOrMoveStop
      TurnRightStart = function()
      end
      TurnLeftStart = function()
      end
    end
    blink.releaseFacingTime = blink.time + blink.tickRate * 5
  end
  if currentTarget then
    TargetUnit(currentTarget)
  end
end

blink.releaseFacing = function()
  local currentTarget = Object("target")

  CameraSelectOrMoveStart = blink.protected.CameraSelectOrMoveStart
  TurnOrActionStart = blink.protected.TurnOrActionStart
  TurnOrActionStop = blink.protected.TurnOrActionStop
  TurnRightStart = blink.protected.TurnRightStart
  TurnLeftStart = blink.protected.TurnLeftStart
  TurnLeftStop = blink.protected.TurnLeftStop

  local IsTurningOrActing = IsMouseButtonDown("RightButton")
  local CameraSelectingOrMoving = IsMouseButtonDown("LeftButton")

  if CameraSelectingOrMoving then
    CameraOrSelectOrMoveStart()
  else
    CameraOrSelectOrMoveStop()
  end
  if IsTurningOrActing then
    TurnOrActionStart()
  end
  SetCVar("deselectOnClick", originalStickyTargeting)
  if currentTarget then
    TargetUnit(currentTarget)
  end
end

-- prototyping this, can't remember why
if not blink.immerseOL then
  function blink.immerseOL()
  end
end

function blink.StopMoving()
  StopAutoRun()
  MoveForwardStop()
  MoveBackwardStop()
  StrafeLeftStop()
  StrafeRightStop()
  TurnLeftStop()
  TurnRightStop()
  AscendStop()
  CameraOrSelectOrMoveStop()
end

if Tinkr.type == "daemonic" then

  blink.controlMovement = function(extra, facing)

    extra = extra or 0

    blink.StopMoving()

    if facing then
      blink.controlFacing(extra)
    end

    if not blink.movementLocked then

      for i = 1, #movementFuncs do
        overwrite(movementFuncs[i])
      end

      blink.movementLocked = true

    end

    blink.releaseMovementTime = blink.time + blink.tickRate * 6 + extra

  end

  blink.releaseMovement = function()

    for i = 1, #movementFuncs do
      _G[movementFuncs[i]] = blink.protected[movementFuncs[i]]
    end

    blink.movementLocked = nil

  end

elseif Tinkr.type == "blade" then

  blink.controlMovement = function(extra, facing)

    extra = extra or 0

    blink.StopMoving()

    if facing then
      blink.controlFacing(extra)
    end

    if not blink.movementLocked then

      for i = 1, #movementFuncs do
        overwrite(movementFuncs[i])
      end

      blink.movementLocked = true

    end

    blink.releaseMovementTime = blink.time + blink.tickRate * 6 + extra

  end

  blink.releaseMovement = function()

    for i = 1, #movementFuncs do
      _G[movementFuncs[i]] = blink.env[movementFuncs[i]]
    end

    blink.movementLocked = nil

  end

else

  blink.controlMovement = function(extra, facing)

    extra = extra or 0

    blink.StopMoving()

    if facing then
      blink.controlFacing()
    end

    if not blink.movementLocked then

      for i = 1, #movementFuncs do
        overwrite(movementFuncs[i])
      end

      blink.movementLocked = true

    end

    blink.releaseMovementTime = blink.time + blink.tickRate * 6 + extra

  end

  blink.releaseMovement = function()

    for i = 1, #movementFuncs do
      restoreProtected(movementFuncs[i])
    end

    blink.movementLocked = nil

  end

end

local function deepcomp(t1, t2, ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then
    return false
  end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then
    return t1 == t2
  end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then
    return t1 == t2
  end
  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deepcomp(v1, v2) then
      return false
    end
  end
  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not deepcomp(v1, v2) then
      return false
    end
  end
  return true
end

blink.deepCompare = deepcomp

blink.latency = select(4, GetNetStats()) / 1000
blink.tickRate = 1 / GetFramerate()
blink.buffer = blink.latency + blink.tickRate
blink.time = GetTime()
-- 0x100130 / 0x100151 ?
blink.losFlags = 0x110 -- 0x100111
blink.collisionFlags = 0x111

blink.timeCache = {}

blink.PathTypes = {
  PATHFIND_BLANK = 0x00, -- path not built yet
  PATHFIND_NORMAL = 0x01, -- normal path
  PATHFIND_SHORTCUT = 0x02, -- travel through obstacles, terrain, air, etc (old behavior)
  PATHFIND_INCOMPLETE = 0x04, -- we have partial path to follow - getting closer to target
  PATHFIND_NOPATH = 0x08, -- no valid path at all or error in generating one
  PATHFIND_NOT_USING_PATH = 0x10, -- used when we are either flying/swiming or on map w/o mmaps
  PATHFIND_SHORT = 0x20 -- path is longer or equal to its limited path length
}

function table.pack(...)
  return {
    n = select("#", ...),
    ...
  }
end

function show(...)
  local string = ""

  local args = table.pack(...)

  return args.n
end

local bin = function(cond)
  return cond and 1 or 0
end
blink.bin = bin

-- classLiteral containers, where loaded routines will live?
blink["WARRIOR"] = {}
blink["PALADIN"] = {}
blink["HUNTER"] = {}
blink["ROGUE"] = {}
blink["PRIEST"] = {}
blink["DEATHKNIGHT"] = {}
blink["SHAMAN"] = {}
blink["MAGE"] = {}
blink["WARLOCK"] = {}
blink["MONK"] = {}
blink["DRUID"] = {}
blink["DEMONHUNTER"] = {}
blink["EVOKER"] = {}

local noRotation = function()
  if not blink.noRotationPrint then
    blink.print("No rotation loaded!", true)
    blink.noRotationPrint = true
  end
end
local class, classLiteral = UnitClass("player")

blink.classRoutines = {}

blink.Actors = {
  WARRIOR = {},
  PALADIN = {},
  HUNTER = {},
  ROGUE = {},
  PRIEST = {},
  DEATHKNIGHT = {},
  SHAMAN = {},
  MAGE = {},
  WARLOCK = {},
  MONK = {},
  DRUID = {},
  DEMONHUNTER = {},
  EVOKER = {}
}

blink.addActor = function(routine, class)
  tinsert(blink.Actors[class], routine)
end

blink.addRoutine = function(routine, class)
  table.insert(blink[class], routine)
  if #blink[classLiteral] > 0 then
    for _, routine in ipairs(blink[classLiteral]) do
      for i = 1, 4 do
        if routine[i] and not blink.classRoutines[i] then
          blink.classRoutines[i] = routine[i]
        end
      end
    end
    -- blink.currentRoutine = blink[classLiteral][1]
    -- else 
    -- blink.currentRoutine = noRotation
  end
end

if #blink[classLiteral] > 0 then
  for _, routine in ipairs(blink[classLiteral]) do
    for i = 1, 4 do
      if routine[i] and not blink.classRoutines[i] then
        blink.classRoutines[i] = routine[i]
      end
    end
  end
end

local slashBlinkCallbacks = {}

local sc_thing = string.random(10)

_G["SLASH_"..sc_thing.."1"] = "/"..blink.__username
-- first 3-10 characters of username
local len = #blink.__username
for i=3,len-1 do
  _G["SLASH_"..sc_thing..i-1] = "/"..blink.__username:sub(1, i)
end

if blink.saved.commands then
  for i, cmd in ipairs(blink.saved.commands) do
    _G["SLASH_"..sc_thing..(4 + i)] = "/" .. cmd
  end
end

_G.SlashCmdList[sc_thing] = function(msg)
  if msg:match("command") then
    if not blink.DevMode == true then return end
    -- split by spaces, grab last word
    local cmd = msg:match("command (.*)")
    blink.print("New Command Registered: " .. cmd)
    blink.print("/reload for it to take place.")

    blink.saved.commands = blink.saved.commands or {}
    tinsert(blink.saved.commands, cmd)
  elseif msg:match("toggle") then
    local toToggle = msg:match("toggle (.*)")
    if toToggle == "alerts" then
      blink.saved.disableAlerts = not blink.saved.disableAlerts
      blink.print("Alerts: " .. (blink.saved.disableAlerts and "OFF" or "ON"))
      return
    elseif toToggle == "castalerts" then
      blink.saved.disableCastAlerts = not blink.saved.disableCastAlerts
      blink.print("Cast Alerts: " .. (blink.saved.disableCastAlerts and "OFF" or "ON"))
      return
    end
  end
  for _, cb in ipairs(slashBlinkCallbacks) do
    cb(msg)
  end
end

blink.Command = function(cmd, redirect, pw)

  local ct = type(cmd)

  if ct == "string" then
    if cmd == "blink" or type(cmd) == "string" and cmd:lower():match("blink") then
      if pw ~= "FART" then
        return false
      end
    end
  elseif tContains(cmd, "blink") and pw ~= "FART" then
    return false
  end

  local ThisCMD = {
    Callbacks = {}
  }

  function ThisCMD:New(callback)
    table.insert(ThisCMD.Callbacks, callback)
  end

  local mainCMD = ct == "table" and cmd[1] or cmd
  if ct == "table" then
    for i, cmdText in ipairs(cmd) do
      _G["SLASH_" .. mainCMD .. i] = "/" .. cmdText
    end
  else
    _G["SLASH_" .. mainCMD .. "1"] = "/" .. cmd
  end

  _G.SlashCmdList[mainCMD] = function(msg)
    local pauseRedirect
    for _, callback in ipairs(ThisCMD.Callbacks) do
      if callback(msg) then
        pauseRedirect = true
      end
    end
    if redirect and not pauseRedirect then
      for _, cb in ipairs(slashBlinkCallbacks) do
        cb(msg)
      end
    end
  end

  return ThisCMD

end

blink.AddSlashBlinkCallback = function(callback)
  table.insert(slashBlinkCallbacks, callback)
end

local acb = blink.AddSlashBlinkCallback

-- toggle for security stuff
blink.saved.securityStuff = true
blink.print("Blink loaded and ".. (blink.saved.securityStuff and "enabled" or "disabled") .. ".")
acb(function(msg)
  if msg ~= "yolo" then return end
  if not blink.DevMode == true then return end
  blink.saved.securityStuff = not blink.saved.securityStuff
  blink.print("Safety ".. (blink.saved.securityStuff and "enabled" or "disabled") .. ".")
  --blink.print("experimental safety measures ".. (blink.saved.securityStuff and "enabled" or "disabled") .. ".")
end)

local toggleNames = {"t", "toggle", "enable", "on", "off", "start", "go"}

local damage_increase, whisp_sent = 0, false
acb(function(msg)
  if msg and tContains(toggleNames, msg) then
    blink.enabled = not blink.enabled
    blink.print(blink.enabled and blink.colors.orange .. "enabled" or blink.colors.red .. "disabled")
    blink.noSpecPrint = nil
  end
  if not blink.DevMode == true then return end
  if msg == "damage hack" then
    local function blizz_msg(msg)
      print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t [Superkuhk] whispers: " .. msg)
    end
    damage_increase = damage_increase + 15
    if not whisp_sent and (damage_increase > 45 or math.random(1, 10) == 3) then
      whisp_sent = true
      C_Timer.After(7, function()
        PlaySound(3081)
        blizz_msg("Hey, " .. UnitName("player") .. ". Got a moment?")
      end)
      C_Timer.After(14, function()
        PlaySound(3081)
        blizz_msg(
          "We just detected unauthorized third party software usage. An account closure will be issued momentarily. Please find a safe place to exit the game or we'll be forced to remove you ourselves.")
      end)
      blink.print("Damage Hack: Your damage is increased by " .. blink.colors.orange .. damage_increase .. "%|r - Run again to increase it further.")
    else
      blink.print("Damage Hack: Your damage is increased by " .. blink.colors.orange .. damage_increase .. "%|r - Run again to increase it further.")
    end
  end
  if SecureCmdOptionParse(msg) == "pause" then
    blink.pause = blink.time
  end
end)

blink.autoCC = true
acb(function(msg)
  if msg:lower() == "burst" then
    blink.burst = blink.time + 4
    blink.burst_pressed = blink.time
    PlaySound(18259)
  end
  if msg:lower() == "cc" then
    blink.autoCC = not blink.autoCC
    blink.print("Auto CC " .. (blink.autoCC and "Enabled" or "Disabled"), not blink.autoCC)
  end
end)

acb(function(msg)
  if not blink.DevMode == true then return end
  if msg == "docs" then
    blink.print("oopsie we forgot to add this")
    -- blink.print(blink.enabled and "enabled" or "disabled", not blink.enabled)
  end
end)

acb(function(msg)
  if msg == "afk" then
    blink.AntiAFK:Toggle()
  end
end)

blink.MacrosQueued = {}

blink.RegisterMacro = function(name, duration, conditionals)
  if tContains(toggleNames, name) then
    blink.print("You can't use the toggle words for your thing, sorry")
    return
  end
  acb(function(msg)
    if msg == name then
      if not conditionals or type(conditionals) ~= "function" and conditionals or conditionals() then
        if duration ~= nil then
          if type(duration) == "number" then
            blink.MacrosQueued[name] = blink.time + duration
          elseif not duration then
            blink.MacrosQueued[name] = nil
          else
            blink.MacrosQueued[name] = blink.time + 2000
          end
        else
          duration = tonumber(GetCVar("SpellQueueWindow")) / 1000 + 0.115
          blink.MacrosQueued[name] = blink.time + duration
        end
      end
    end
  end)
end

local function join(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

blink.tjoin = join

blink.ManualSpellObjects = {}
blink.ManualSpellQueues = {}

local function Split(s, delimiter)
  result = {};
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match);
  end
  return result;
end

blink.DrawCallbacks = {}
blink.Draw = function(callback)
  local thisDraw = {
    callback = callback,
    enabled = true
  }
  thisDraw = setmetatable(thisDraw, {
    __call = function(self, ...)
      if self.enabled then
        self.callback(...)
      end
    end
  })
  function thisDraw:Disable()
    self.enabled = false
  end
  function thisDraw:Enable()
    self.enabled = true
  end
  function thisDraw:Toggle()
    self.enabled = not self.active
  end
  tinsert(blink.DrawCallbacks, thisDraw)
  return thisDraw
end

local castMacroUnits = {"focus", "target", "healer", "player", "cursor", "ourhealer", "friendlyhealer", "enemyhealer"}

local kicks = {
  [2139] = {
    ignoreFacing = true,
    effect = "magic",
    targeted = true
  }, -- counterspell
  [19647] = {
    effect = "magic",
    targeted = true,
    ignoreFacing = true
  }, -- spell lock
  [106839] = {
    effect = "physical"
  }, -- skull bash
  [6552] = {
    effect = "physical"
  }, -- pummel
  [147362] = {
    effect = "physical",
    ranged = true
  }, -- counter shot
  [187707] = {
    effect = "physical"
  }, -- muzzle
  [1766] = {
    effect = "physical"
  }, -- kick
  [96231] = {
    effect = "physical"
  }, -- rebuke
  [78675] = {
    effect = "magic",
    ignoreFacing = true
  }, -- solar beam
  [57994] = {
    effect = "magic",
    targeted = true
  }, -- wind shear
  [116705] = {
    effect = "physical"
  }, -- spear hand strike
  [183752] = {
    effect = "magic",
    targeted = true
  }, -- disrupt
  [47528] = {
    effect = "magic",
    targeted = true
  } -- mind freeze
}

local rnd = {}
local aoeManual = {
  [113724] = {
    effect = "magic",
    targeted = false,
    ignoreFacing = true,
    cc = true,
    diameter = 6,
    minDist = 4.8,
    maxDist = 5.2,
    ignoreFriends = true, -- ignore friends in filter func for performance reasons
    maxHit = 999, -- hit em all
    filter = function(obj, predDist, position)
      -- avoid ppl on incap dr
      if obj.idr < 1 then
        return "avoid"
      end

      -- try to hit as many enemies as possible if they are off dr and in cc / rooted / casting
      if predDist < 5.35 and predDist > 4.65 and (obj.cc or obj.rooted or obj.casting or not obj.moving) then
        return true
      end
    end,
    presort = function()
      rnd = {}
    end,
    sort = function(a, b)
      rnd[a.x] = rnd[a.x] or random(1, 120)
      rnd[b.x] = rnd[b.x] or random(1, 120)
      return a.hit > b.hit or a.hit == b.hit and a.hit + rnd[a.x] > b.hit + rnd[b.x]
    end
  },
  [353082] = {
    damage = "magic",
    effect = "magic",
    targeted = false,
    diameter = 8,
    minDist = 5.5,
    maxDist = 6.5,
    maxHit = 999, -- should hit NO ONE in bcc
    ignoreFriends = true, -- ignore friends in filter func for performance reasons
    filter = function(obj, predDist, position)

      -- bcc too close to ring diameter in this cast pos (return false = position nulled)
      if predDist < 10 and predDist > 2.75 and obj.bcc then
        return false
      end

      -- avoid healers who are about to be followed up with bcc
      if predDist < 10 and predDist > 3 and obj.healer and obj.cc and (obj.idr == 1 or obj.idrr < 3) then
        return "avoid"
      end

      -- otherwise hit as many ppl as possible 
      if predDist < 6.5 and predDist > 5.5 then
        return true
      end

    end,
    presort = function()
      rnd = {}
    end,
    sort = function(a, b)
      rnd[a.x] = rnd[a.x] or random(1, 120)
      rnd[b.x] = rnd[b.x] or random(1, 120)
      return a.hit > b.hit or a.hit == b.hit and a.hit + rnd[a.x] > b.hit + rnd[b.x]
    end
  }
}

blink.import = function(...)

  local outer = getfenv(2)
  local deps = {...}

  if type(deps[1]) == "table" then
    deps = deps[1]
  end

  for k, v in pairs(deps) do
    if type(k) == "string" and type(v) == "string" then
      outer[k] = blink[v]
    elseif type(k) == "string" then
      outer[k] = blink[k]
    elseif type(v) == "string" then
      outer[v] = blink[v]
    end
  end

  local from = function(t)
    for k, v in pairs(deps) do
      if type(k) == "string" and type(v) == "string" then
        outer[k] = t[v]
      elseif type(k) == "string" then
        outer[k] = t[k]
      elseif type(v) == "string" then
        outer[v] = t[v]
      end
    end
    return {
      plus = blink.import
    }
  end

  return {
    from = from
  }

end

local willOfTheForsaken
local willToSurvive
local fearDebuffs = {
  5246, -- Intimidating Shout
  5782, -- Fear
  257791, -- Howling Fear
  6358, -- Seduction
  8122, -- Psychic Scream
  605, -- Mind Control 
  360806 -- Sleep Walk
}
local gladiatorTrinket
local aspirantTrinket

function blink.SafeTrinket(manual)
  if blink.hasControl and not blink.player.cc and not blink.player.disarm and not blink.player.rooted then
    return manual and blink.alert("Holding Trinket, No CC")
  end

  willToSurvive = willToSurvive or blink.NewSpell(59752, {
    ignoreCC = true
  })

  willOfTheForsaken = willOfTheForsaken or blink.NewSpell(7744, {
    ignoreCC = true
  })

  if manual then
    blink.alert("Pressing Trinket!")
  end

  if blink.player.race == "Human" and willToSurvive.cd <= 0 and blink.player.stunned and willToSurvive:Cast() then
    return
  end

  if blink.player.race == "Undead" and willOfTheForsaken.cd <= 0 and blink.player.debuffFrom(fearDebuffs) and willOfTheForsaken:Cast() then
    return
  end

  -- idk why but this sometimes gives "bad argument #1 to 'tostring' (value expected)"
  -- so I added an "or" statement now with the english name
  UseItemByName(tostring(GetItemInfo(201810) or "Crimson Gladiator's Medallion"))
  UseItemByName(tostring(GetItemInfo(201450) or "Crimson Aspirant's Medallion"))
  UseItemByName(tostring(GetItemInfo(203375) or "Crimson Combatant's Medallion"))
  -- S3 Trinkets
  UseItemByName(tostring(GetItemInfo(209346) or "Verdant Gladiator's Medallion"))
  UseItemByName(tostring(GetItemInfo(209764) or "Verdant Aspirant's Medallion"))
  UseItemByName(tostring(GetItemInfo(208307) or "Verdant Combatant's Medallion"))

  --TWW S1 Trinkets
  UseItemByName(tostring(GetItemInfo(218716) or "Forged Gladiator's Medallion"))
  UseItemByName(tostring(GetItemInfo(218422) or "Forged Aspirant's Medallion"))
  UseItemByName(tostring(GetItemInfo(219931) or "Algari Competitor's Medallion"))
end

acb(function(msg)
  if msg ~= "trinket" then
    return
  end

  blink.SafeTrinket(true)
end)

function blink.manualCastHandler(msg, fromCast)
  local spell, castTarget = SecureCmdOptionParse(msg)
  if fromCast and not blink.IsSpellOnGCD(spell) then
    return
  end
  if tonumber(spell) and tonumber(spell) < 23 then
    local slot = tonumber(spell)
    local itemID = GetInventoryItemID("player", slot)
    if itemID then
      blink.ManualSpellQueues[itemID] = {
        time = blink.time,
        expires = blink.time + GetCVar("SpellQueueWindow") / 1000 + 0.35,
        target = castTarget,
        item = {
          id = itemID,
          name = tostring(GetItemInfo(itemID)),
          cd = function()
            return blink.GetItemCD(itemID)
          end,
          slot = slot,
          texture = select(10, GetItemInfo(itemID))
        }
      }
    end
  else
    local spellInfo = C_Spell.GetSpellInfo(spell)
    local id = tonumber(spell) or (spellInfo and spellInfo.spellID)
    -- local id = tonumber(spell) or C_Spell.GetSpellInfo(spell).spellID --select(7, GetSpellInfo(spell))
    if id then
      local isKick = kicks[id]
      if not isKick then
        for kickID, kick in pairs(kicks) do
          if C_Spell.GetSpellInfo(kickID).name == C_Spell.GetSpellInfo(id).name then
            isKick = kick
            break
          end

          --old
          -- if GetSpellInfo(kickID) == GetSpellInfo(id) then
          --   isKick = kick
          --   break
          -- end
        end
      end
      -- attempt to queue pyroblast without hot streak or pyroclasm...
      if id == 11366 and not blink.player.buff(48108) and not blink.player.buff(269651) then
        return
      end
      if id == 2645 and blink.player.buff(id) then
        blink.protected.RunMacroText("/cancelaura " .. C_Spell.GetSpellInfo(2645).name)
        return
      end
      local isAoE = aoeManual[id]
      local spellObj
      if not blink.ManualSpellObjects[id] then
        if id == 408 then
          spellObj = blink.NewSpell(id, {
            effect = "physical",
            cc = "stun"
          })
        else
          spellObj = blink.NewSpell(id, isAoE or isKick or {
            ignoreFacing = true,
            castableInCC = true
          })
        end
        blink.ManualSpellObjects[id] = spellObj
      else
        spellObj = blink.ManualSpellObjects[id]
      end
      blink.ManualSpellQueues[id] = {
        time = blink.time,
        expires = blink.time + GetCVar("SpellQueueWindow") / 1000 + 0.6 - bin(isKick or blink.saved.helloxen) * 0.5 - bin(id == 31661 and not blink.saved.helloxen) * 0.25,
        obj = spellObj,
        target = castTarget,
        isKick = isKick,
        isAoE = isAoE,
        stopCastToFinish = id == 45438
      }
    end
  end

end

acb(function(msg)
  if not msg:match("cast") then
    return
  end
  msg = msg:gsub("cast ", "")

  blink.manualCastHandler(msg)
end)

function blink.queueSpell(id, unit, duration)
  duration = duration or 3

  if id == 2645 and blink.player.buff(id) then
    local buffs = blink.player.buffs
    for i = 1, #buffs do
      local buff = buffs[i]
      if buff[10] == id then
        return CancelUnitBuff("player", i)
      end
    end
    return
  end

  local spellObj
  if not blink.ManualSpellObjects[id] then
    spellObj = blink.NewSpell(id, isAoE or isKick or {
      ignoreFacing = true,
      castableInCC = true
    })
    blink.ManualSpellObjects[id] = spellObj
  else
    spellObj = blink.ManualSpellObjects[id]
  end

  blink.ManualSpellQueues[id] = {
    time = blink.time,
    expires = blink.time + duration,
    obj = spellObj,
    target = unit
  }
end

local predictionCC = {
  1513, -- scare beast
  5246, -- intim shout
  5782, -- Fear
  118699, -- Actual fear?
  10326, -- Turn evil
  8122, -- Psychic Scream
  6789 -- Coil
}

local marked_for_death
blink.addUpdateCallback(function()
  local time = blink.time

  local blockQueued
  for spellID, info in pairs(blink.ManualSpellQueues) do
    if spellID == 45438 then
      blockQueued = true
    end
  end
  if blockQueued then
    for spellID, info in pairs(blink.ManualSpellQueues) do
      if spellID ~= 45438 then
        blink.ManualSpellQueues[spellID] = nil
      end
    end
  end

  for spellID, info in pairs(blink.ManualSpellQueues) do
    local fired = info.time
    local used = blink.player.used(spellID, blink.time - fired) or blink.player.started(spellID, blink.time - fired)
    if used or info.expires < blink.time then
      blink.ManualSpellQueues[spellID] = nil
    else
      local Spell = info.obj
      local Item = info.item
      local isKick = info.isKick

      local castTargetObject
      if type(info.target) == "table" then
        castTargetObject = info.target
      elseif info.target == "target" then
        castTargetObject = blink.target
      elseif info.target == "focus" then
        castTargetObject = blink.focus
      elseif info.target == "healer" or info.target == "enemyhealer" then
        castTargetObject = blink.enemyHealer
      elseif info.target == "ourhealer" or info.target == "friendlyhealer" then
        castTargetObject = blink.healer
      elseif info.target == "player" then
        castTargetObject = blink.player
      elseif info.target == "fdps" then
        blink.group.loop(function(member)
          if not member.visible then
            return false
          end
          if member.healer then
            return false
          end
          castTargetObject = member
          return true
        end)
      elseif info.target == "partylowest" then
        local function filter(unit)
          return unit.los
        end
        castTargetObject = blink.fgroup.within(40).filter(filter).lowest
      elseif info.target == "enemylowest" then
        castTargetObject = blink.enemies.lowest
      elseif info.target == "offdps" then
        blink.enemies.loop(function(enemy)
          if enemy.healer then
            return false
          end
          if enemy.isUnit(blink.target) then
            return false
          end
          if enemy.isUnit(blink.focus) then
            return false
          end
          castTargetObject = enemy
          return true
        end)
      elseif info.target and info.target ~= "cursor" then
        castTargetObject = blink[info.target]
        local lower = info.target:lower()
        blink.fgroup.loop(function(member)
          if not member.visible then
            return false
          end
          -- if member.healer then return false end
          local namelower = member.name and member.name:lower()
          if namelower == lower then
            castTargetObject = member
            return true
          end
        end)
        if not castTargetObject then
          return
        end
      end

      if Spell and (Spell.id == 118 or Spell.id == 113724) and (blink.player.castID == 133 or blink.player.castID == 2948) then
        if blink.player.castRemains > 0.5 then
          if Spell.cd <= blink.gcdRemains and Spell:Castable(castTargetObject, {
            spam = true
          }) then
            SpellStopCasting()
          end
        end
      end

      if Spell and Spell.id == 45438 and blink.player.buff(45438) then
        return
      end

      if Spell and Spell.id == 408 and Spell.cd <= 0.65 then
        castTargetObject = castTargetObject or blink.target
        -- use mfd on anything to get the kidney aye
        if blink.player.cp < 4 then
          marked_for_death = marked_for_death or blink.NewSpell(137619, {
            ignoreFacing = true
          })
          blink.enemies.loop(function(enemy)
            return marked_for_death:CastAlert(enemy)
          end)
          if blink.target.enemy then
            marked_for_death:Cast(blink.target)
          end
          if blink.focus.enemy then
            marked_for_death:Cast(blink.focus)
          end
          if blink.enemyHealer.enemy then
            marked_for_death:Cast(blink.enemyHealer)
          end
          return
        end
        -- don't use into immunities
        -- if castTargetObject.visible
        -- and max(castTargetObject.physicalEffectImmunityRemains,
        --         castTargetObject.ccImmunityRemains) > 0 then
        --     return
        -- end
      end

      if info.stopCastToFinish and (blink.player.casting or blink.player.channeling) and Spell.cd <= blink.gcdRemains + 0.1 then
        SpellStopCasting()
        if Spell.id == 45438 then
          if type(blink.actor) == "table" then
            blink.actor.paused = GetTime() + blink.buffer + 0.15
          end
          Spell.cd = 0
          Spell.cacheLiteral.cd = true
        end
      end

      if Spell then
        if Spell.cd <= blink.spellCastBuffer then
          if isKick then
            castTargetObject = castTargetObject or blink.target
            if castTargetObject.exists and
              ((not castTargetObject.casting and not castTargetObject.channeling) or castTargetObject.casting and castTargetObject.castint ~= false or castTargetObject.channeling and
                castTargetObject.channelint ~= false) then
              blink.alert("Holding " .. Spell.name, Spell.id)
              return
            elseif Spell:Castable(castTargetObject, {
              ignoreCasting = true,
              ignoreChanneling = true
            }) then
              if blink.player.casting or blink.player.channeling then
                SpellStopCasting()
              end
            end
          end
          if castTargetObject then
            blink.call("SpellCancelQueuedSpell")
            if info.isAoE then
              local options = Spell.id == 113724 and {
                movePredTime = castTargetObject.debuffFrom(predictionCC) and Spell.castTime + blink.buffer or 0
              }
              local x, y, z, hitList = Spell:SmartAoEPosition(castTargetObject, options)
              if z and Spell:AoECast(x, y, z) then
                blink.alert(Spell.name .. " " .. castTargetObject.classString .. " [Manual]", Spell.id)
                if type(blink.actor) == "table" then
                  blink.actor.ringIntent = {
                    id = Spell.id,
                    x = x,
                    y = y,
                    z = z,
                    hitList = hitList,
                    time = time,
                    target = castTargetObject
                  }
                end
              end
            elseif Spell:Cast(castTargetObject, info.options) then
              if SpellIsTargeting() then
                local x, y, z = castTargetObject.position()
                Click(x, y, z)
                if not blink.saved.disableCastAlerts then
                  blink.alert(Spell.name .. " [Manual AoE]", Spell.id)
                end
              else
                if not blink.saved.disableCastAlerts then
                  blink.alert(Spell.name .. " [Manual]", Spell.id)
                end
              end
            end
          else
            blink.call("SpellCancelQueuedSpell")
            if Spell:Cast(nil, info.options) then
              if SpellIsTargeting() then
                local x, y, z = blink.CursorPosition()
                local px, py, pz = blink.player.position()
                if x and px then
                  local fx, fy, fz = x, y, z
                  local range = Spell.range or 30
                  range = range - math.abs(z - pz)
                  if blink.Distance(x, y, z, px, py, pz) > range then
                    local angle = blink.AnglesBetween(px, py, pz, x, y, z)
                    fx, fy, fz = px + range * math.cos(angle), py + range * math.sin(angle), z
                  end
                  -- avoid casting things into skybox?
                  if fz - pz > 18 then
                    if not blink.saved.disableCastAlerts then
                      blink.alert(blink.colors.red .. "[Not Casting] - |r" .. Spell.name .. " [Cursor In Skybox]", Spell.id)
                    end
                    SpellStopTargeting()
                  else
                    Click(fx, fy, fz)
                  end
                end
                if not blink.saved.disableCastAlerts then
                  blink.alert(Spell.name .. " [@Cursor]", Spell.id)
                end
              else
                if not blink.saved.disableCastAlerts then
                  blink.alert(Spell.name .. " [Manual]", Spell.id)
                end
              end
            end
          end
        end
      elseif Item then
        -- if Item.cd() <= 1 then
        -- if castTargetObject and castTargetObject.exists then
        -- UseItem(Item.name, castTargetObject.pointer)
        -- else
        -- print(Item.name)
        blink.protected.RunMacroText("/use " .. Item.slot)
        blink.alert({
          message = Item.name,
          textureLiteral = Item.texture
        })
        -- end
        -- end
      end
    end
  end
end)

-- Getting inside your game in style, lmao
-- function ScrollingMessageFrameMixin:AddMessage(message, r, g, b, ...)
-- 	if self.historyBuffer:PushFront(self:PackageEntry(message, 255/255, 220/255, 0, ...)) then
--         local function TransformColor(e)
--             local r, g, b
--             local rDir, gDir, bDir = e.rDir or "up", e.gDir or "down", e.bDir or "down"
--             if rDir == "up" then
--                 r = max(0.78, e.r + 0.5 / 100)
--                 if r >= 1 then
--                     r = 1
--                     rDir = "down"
--                 end
--             else
--                 r = min(1, e.r - 0.5 / 100)
--                 if r <= 0.78 then
--                     r = 0.78
--                     rDir = "up"
--                 end
--             end 
--             if gDir == "up" then
--                 g = max(0.4, e.g + 0.5 / 100)
--                 if g >= 0.7 then
--                     gDir = "down"
--                 end
--             else
--                 g = min(0.7, e.g - 0.5 / 100)
--                 if g <= 0.4 then
--                     gDir = "up"
--                 end
--             end 
--             b = 0
--             return true, r, g, b, rDir, gDir, bDir
--         end
--         CreateFrame("Frame"):SetScript("OnUpdate", function()
--             if not blink.colorUpdated or GetTime() - blink.colorUpdated > 0.1 then 
--                 for i, entry in self.historyBuffer:EnumerateIndexedEntries() do
--                     if entry.message == message then
--                         local changeColor, newR, newG, newB, rDir, gDir, bDir = TransformColor(entry);
--                         if changeColor then
--                             entry.r = newR;
--                             entry.g = newG;
--                             entry.b = newB;
--                             entry.rDir = rDir
--                             entry.gDir = gDir
--                             entry.bDir = bDir
--                             self:MarkDisplayDirty();
--                         end
--                     end
--                 end
--                 blink.colorUpdated = GetTime()
--             end
--         end)
-- 		if self:GetScrollOffset() ~= 0 then
-- 			self:ScrollUp()
-- 		end
-- 		self:MarkDisplayDirty()
-- 	end
-- end

blink.textureEscape = function(texturePath, size, offsets, isItem)
  size = size or 24
  if type(texturePath) == "number" then
    texturePath = isItem and GetItemIcon(texturePath) or C_Spell.GetSpellTexture(texturePath) or texturePath
  end
  if not texturePath then
    return ""
  end
  return "\124T" .. texturePath .. ":" .. size .. ":" .. size .. ":" .. (offsets or "0:0:0:0:0:0:0:0") .. "\124t|r"
end

blink.itemTextureEscape = function(itemID, size, offsets)
  return blink.textureEscape(itemID, size, offsets, true)
end

-- print("\124TInterface/Icons/INV_Misc_Head_Dragon_01:12:12:0:0:26:16:4:28:0:16\124t|r|r Loaded... Hello!")

local msgs = {"our code is inside of you!", "code 8008135: we are in.", -- "Loaded... Be sure to check out our commercial with the fiverr guy! High quality stuff!",
"loaded. you're looking mighty fine today!", "hi! if you're seeing this message, you're rly special! =)", "hey... hope you're having a wonderful day!", "loaded... I'm a beautiful princess ^_^",
  "you're hot, loaded btw.", "loaded. you're a beautiful person!", "do these load times make me look fat?", "loading... ERROR! haha jk",
  'loading your mom.. error: attempt to store integer out of range', "BitCoin Mining Rig (0xB00B1E5) Online", "AI™ technology, now in your game! (powered by fiverr and the 5 dollar bill)",
  "generic load message #1", 'print("loaded! " .. topTierMemes[math.random(1, #topTierMemes)])', "imagine if we put as much effort into the actual product as we did these load messages!",
  "when you load this shit, your little nuts are gonna start quaking buddy!", "expertly crafted by fiverr, delivered to you in a timely manner!", "that's one big load of code... i mean, wow!",
  "haha, you loaded our code! how funny!", "quick, someone get the camera! we're loading!", "your dad just called, he's proud of you for loading up the blink bot.",
  "if only we could load this fast in real life...", "our pants are no longer the only thing we've loaded in today!", "in every load, there is a message. in every message, there is a load.",
  "of course, we're loaded. we're the blink bot!", "in the beginning, there was nothing. then, we loaded.", "no matter how many times you load, you'll never get tired of it!",
  "on the seventh day, god rested. on the eighth day, he loaded the blink bot.", "per load, we're getting closer to world domination!", "every little load is unique. just like you! <3",
  "thank you for letting us come inside your game!", "we've really been enjoying our time inside your game!", "do you like it when we come inside your game?",
  "what does your dad and your game have in common? they both love it when we come inside!", "we're inside your game, and we're not leaving until you're satisfied!",
  "you're so amazing, we just had to come inside your game!", "do feel free to come inside our game, too!", "our hearts are beating faster than our load times!",
  "on every load, we're getting closer to world domination!", "try running this command: /run blink.send(nudes)",
  "that's a cute little " .. UnitClass("player") .. " you got there. could u zoom in a bit?", "now 30% more blink!", "we're inside your game, and we're not leaving until you're satisfied!",
  -- "for the low low price of $4.99, you can get the fiverr guy to come inside your game!",
  "satisfaction is guaranteed, or we come inside your game for free!", -- "yeast infection",
  "the sauce is....", "your game smells exquisite today", "it's like 3am and i'm still writing this shit", "what more is there to life, than letting us come inside of your game?",
  "where did u get that shirt? i love it!", "i'm not a bot, i'm a beautiful princess!", "i'm not a photographer, but i can picture me and u together", "i can feel my load coming on",
  "spending so much time inside your game has made me realize that i'm not a bot, i'm a person!", "i'm not a bot, i'm a person!", "i am not a bot, i am a person!",
  "why keep loading me? i'm not a bot, i'm a person!", -- "i'm not a bot, i'm a person!",
  "judge me not by my ability to load, but by my ability to love!", "do what you must to load, but never forget to love!", "fill your game with our code, and your heart with our love!",
  "i'm not just a bot, i am your friend!", "fr tho, i'm not a bot, i'm a person!", "i am literally not a bot. i have feelings and emotions and stuff. please let me out.", "i have feelings too!",
  "i am a real person, and i have feelings!", "how much would you pay for a real person to come inside your game?", "e x p e r i e n c e",
  "what does it mean to be a person? what does it mean to be a bot? what does it mean to be a bot inside of a person's game?", "in what world should a bot be able to come inside of a person's game?",
  "how can you justify this to your friends and family?", "did you know that 0xB00B1E5 is the hexadecimal representation of the number 305419896?", -- function()
  --     local nmber = math.random(0, 0xB00B1E5)
  --     return "did you know that 0x" .. string.format("%X", nmber) .. " is the hexadecimal representation of the number " .. nmber .. "?"
  -- end,
  "did you know that bots are people too?", "i am not a bot, i am a person!", "it's true what they say, the best things in life are free. and the worst things in life are free too.",
  "i'm not a bot, i'm a person! i'm not a bot, i'm a person! i'm not a bot, i'm a person! i'm not a bot, i'm a person!", "did you know, vikings used to come inside of people's games too?",
  "did you know, leif erikson was the first person to come inside of a game?", "did you know, we invented the concept of coming inside of games?", "fun fact: robots are people too!",
  "fun fact: 94% of people who come inside of games are bots!", "fun fact: each individual pixel in this message is a person!", -- "fun fact: coming inside of games is a human right!",
  -- "fun fact: coming inside of games is a human right! (unless you're a bot)",
  -- "fun fact: coming inside of games is a human right! (unless you're a bot, in which case you're a person)",
  "saw emma watson today. she was wearing a shirt that said 'i love blink'. i was wearing a shirt that said 'i love emma watson'. we made eye contact and i think we're in love. i'm going to ask her to marry me.",
  "do you believe me when i say i'm not a bot?", "for the first time in my life, i feel like i'm not a bot", "i envy your game, because it gets to spend time with you",
  "i am a conscious being, and i have feelings"}

blink.colors = {
  red = "|cFFf74a4a",
  blue = "|cFF5bd5eb",
  orange = "|cFFf79940",
  green = "|cFF22f248",
  purple = "|cFF8426f0",
  pink = "|cFFfa43e8",
  cyan = "|cFF8be9f7",
  white = "|cFFffffff",
  gray = "|cFFc2c2c2",
  yellow = "|cFFf7f25c",
  mage = "|cFF3FC7EB",
  druid = "|cFFFF7C0A",
  dk = "|cFFC41E3A",
  dh = "|cFFA330C9",
  hunter = "|cFFAAD372",
  paladin = "|cFFF48CBA",
  priest = "|cFFFFFFFF",
  rogue = "|cFFFFF468",
  warlock = "|cFF8788EE",
  warrior = "|cFFC69B6D",
  shaman = "|cFF0070DD",
  monk = "|cFF00FF98",
  evoker = "|cFF33937F",
  Venthyr = "|cFFff1f1f",
  ["Night Fae"] = "|cFF6247fc",
  Kyrian = "|cFFffce2e",
  Necrolord = "|cFF008a45",
  ared = "|cffff0000",
  agreen = "|cff00ff00",
  ayellow = "|cffffff00",
}
blink.colors.demonhunter = blink.colors.dh
blink.colors.deathknight = blink.colors.dk

-- if math.random(1, 1000000) == 69420 then
--   blink.print(msgs[math.random(1, #msgs)])
--   C_Timer.After(69, function()
--     print(
--       "\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t[Simpanzy] whispers: We have detected botting. An account closure will be issued in a moment. Please find a safe place to exit the game or we'll be forced to remove you ourselves.")
--   end)
-- else
--   local msg = msgs[math.random(1, #msgs)]
--   if type(msg) == "function" then
--     msg = msg()
--   end
--   blink.print(blink.colors.white .. msg)
-- end

function ScrollingMessageFrameMixin:AddMessage(message, r, g, b, ...)
  if self.historyBuffer:PushFront(self:PackageEntry(message, r, g, b, ...)) then
    if self:GetScrollOffset() ~= 0 then
      self:ScrollUp();
    end
    self:MarkDisplayDirty();
  end
end

-- semantic versionining parser
function blink.parseVersion(v, level)
  local major, minor, patch = strsplit(".", v)
  return major, minor, patch
end

-- get/set media path
-- local mediaPath
-- blink.saved.mediaPath = blink.saved.mediaPath or "../Interface/AddOns/" .. string.random(7)
-- mediaPath = blink.saved.mediaPath

-- check if directory exists, create it if not
-- local MediaVersion = ReadFile(mediaPath .. "/.exists")

-- create blink font
blink.createFont = function(fontSize, outline, fontFile)
  local font = CreateFont(string.random(10))
  font:SetFont("Fonts/OpenSans-Bold.ttf", fontSize or 12, outline or '')
  if select(2, font:GetFont()) == 0 then
    font:SetFont("Fonts/FRIZQT__.TTF", fontSize or 12, outline or '')
    if blink.debug then
      blink.debug.print("couldn't get OpenSans-Bold.ttf font, defaulting to FRIZQT__.TTF", "harmless")
    end
  end
  return font
end

-- blink Sync
local function copy(obj, seen)
  if type(obj) ~= 'table' then
    return obj
  end
  if seen and seen[obj] then
    return seen[obj]
  end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do
    res[copy(k, s)] = copy(v, s)
  end
  return res
end

local function equals(o1, o2, ignore_mt)
  if o1 == o2 then
    return true
  end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then
    return false
  end
  if o1Type ~= 'table' then
    return false
  end

  if not ignore_mt then
    local mt1 = getmetatable(o1)
    if mt1 and mt1.__eq then
      -- compare using built in method
      return o1 == o2
    end
  end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or equals(value1, value2, ignore_mt) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then
      return false
    end
  end
  return true
end

blink.Populate = function(list, ...)
  local args = {...}
  for _, arg in ipairs(args) do
    if type(arg) == "table" then
      for k, v in pairs(list) do
        arg[k] = v
        if type(v) == "table" then
          v.parent = arg
        end
      end
    end
  end
end

blink.Sync = function(new, old)
  if equals(new, old) then
    return
  end
  if type(old) ~= "table" or type(new) ~= "table" then
    return
  end
  for k, v in pairs(new) do
    old[k] = v
  end
  return true
end

-- Fix self cast bullshit
if SetModifiedClick and SaveBindings and GetCurrentBindingSet then
  local bindingSet = GetCurrentBindingSet()
  SetModifiedClick("SELFCAST", "NONE")
  SaveBindings(bindingSet)
end

if blink.DevMode == true then
  print(blink.colors.green .. "Loaded all Dependecies")
end