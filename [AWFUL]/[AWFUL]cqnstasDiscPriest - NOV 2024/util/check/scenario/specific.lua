local Unlocker, awful, project = ...

-- party
-- raid
-- scenario
-- arena
-- pvp
-- none

--Dump: value=GetInstanceInfo()
--[1]="Khaz Algar (Surface)",   -- The name of the instance or zone. <- dng name
--[2]="none",                    -- The instance type (e.g., "party", "raid", "scenario", or "none" if in the open world).
--[3]=0,                         -- The difficulty ID (numeric representation of difficulty).
--[4]="",                        -- The difficulty name (e.g., "Normal", "Heroic", "Mythic Keystone").
--[5]=5,                         -- The maximum number of players allowed in the instance.
--[6]=0,                         -- The instance ID (unique identifier for the instance).
--[7]=false,                     -- A boolean indicating if the instance is a dynamic (phased) instance.
--[8]=2552,                      -- The map ID of the instance.
--[9]=0                          -- The zone group ID (used internally to group multiple zones in the same instance).
project.util.check.scenario.specific = function()
    local _, instanceType = GetInstanceInfo()
    return awful.instanceType2
end