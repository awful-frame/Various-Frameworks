local Unlocker, blink = ...
local setmetatable, rawget, type, tinsert = setmetatable, rawget, type, tinsert
local immerse = blink.immerseOL

local List = {}
List.__index = List

-- /dump pp.loop, pp

function List:New(types, constructor)

  if type(types) ~= "table" then
    return blink.print("must pass array of object types to List:New")
  elseif type(constructor) ~= "function" then
    return blink.print("must pass constructor function to List:New")
  end 

  local list = immerse(
    setmetatable(
      { types = types, constructor = constructor }, 
      { __index = self }
    )
  )

  function list:Clear()
    for i=1,#self do self[i] = nil end
    self.populated = false
  end

  function list:Populate()
    if not self.populated then
      blink.loadUnits(self)
      self.populated = true
    end
  end

  local finalList = setmetatable({}, { 
    __index = function(self, key)
      if key == "Clear" then
        return function()
          list:Clear()
        end
      elseif key == "_List" then
        return list
      elseif not rawget(list, "populated") then
        list:Populate()
      end
      if key == "length" then
        return #list
      end
      return list[key]
    end
  })

  tinsert(blink.Lists, finalList)

  return finalList
end

blink.List = List