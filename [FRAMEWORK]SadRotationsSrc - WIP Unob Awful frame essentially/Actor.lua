local Unlocker, blink = ...
local player = blink.player

local classes = { 
  "WARRIOR",
  "PALADIN",
  "HUNTER",
  "ROGUE",
  "PRIEST",
  "DEATHKNIGHT",
  "SHAMAN",
  "MAGE",
  "WARLOCK",
  "MONK",
  "DRUID",
  "DEMONHUNTER",
  "EVOKER"
}

local findExactClass = function(shorthand)
  if type(shorthand) ~= "string" then 
    blink.debug.pring("need class passed as a string", "debug")
    return false 
  end
  local sl = shorthand:lower()
  for _, class in ipairs(classes) do
    local cl = class:lower()
    if sl:match("dk") and class == "DEATHKNIGHT"
    or sl:match("dh") and class == "DEMONHUNTER"
    or cl:match(shorthand) then
      return class
    end
  end
end

local Actor = {}
Actor.__index = Actor

function Actor:Init(callback, ACTOR_TICKRATE)

  if self.init then print("already initialized") return false end

  local env = getfenv(callback)

  local actor_env = setmetatable(self, {
    __index = function(self, key)
                return env[key] or blink[key]
              end,
    __call = function(self, ...)
      callback(self, ...)
    end
  })  

  setfenv(callback, actor_env)

  -- 50ms default tbh :)
  self.ACTOR_TICKRATE = ACTOR_TICKRATE or 0.05

  C_Timer.NewTicker(2, function()
    if blink.arena then
      self.ACTOR_TICKRATE = self.MANUAL_TICKRATE or 0.025
    else
      self.ACTOR_TICKRATE = self.MANUAL_TICKRATE or ACTOR_TICKRATE or 0.05
    end
  end)

  self.init = true

  -- find class alias, add routine
  local class2 = findExactClass(self.class)
  if not class2 then
    blink.debug.print("wasn't able to init routine because of invalid class name", "debug")
    return false
  end

  blink.addActor(self, class2)

  return true

end

function Actor:New(options)

  local attributes = {
    ready = player.class2 == findExactClass(options.class),
    name = options.name,
    class = options.class,
    spec = options.spec
  }

  local thisActor = setmetatable(attributes, Actor)

  return thisActor

end

-- export
blink.Actor = Actor