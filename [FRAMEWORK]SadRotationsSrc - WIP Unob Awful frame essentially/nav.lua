local unlocker, blink = ...

local tinsert, type, wipe = tinsert, type, wipe
local GeneratePathWeighted, FindPath, GetPathNode, IsSwimming = GeneratePathWeighted, FindPath, GetPathNode, IsSwimming
local unlockerType = unlocker.type or "tinkr"
local memoized_paths = {}

-- Implementation of the Ramer–Douglas–Peucker algorithm
local function getSqDist(p1, p2, X, Y)
  local dx = p1[X] - p2[X]
  local dy = p1[Y] - p2[Y]

  return dx * dx + dy * dy
end

local function getSqSegDist(p, p1, p2, X, Y)
  local x = p1[X]
  local y = p1[Y]
  local dx = p2[X] - x
  local dy = p2[Y] - y

  if dx ~= 0 or dy ~= 0 then
    local t = ((p[X] - x) * dx + (p[Y] - y) * dy) / (dx * dx + dy * dy)

    if t > 1 then
      x = p2[X]
      y = p2[Y]
    elseif t > 0 then
      x = x + dx * t
      y = y + dy * t
    end
  end

  dx = p[X] - x
  dy = p[Y] - y

  return dx * dx + dy * dy
end

local function simplifyRadialDist(points, sqTolerance, X, Y)
  local prevPoint = points[1]
  local newPoints = {
    prevPoint
  }
  local point

  for i = 2, #points do
    point = points[i]

    if getSqDist(point, prevPoint, X, Y) > sqTolerance then
      tinsert(newPoints, point)
      prevPoint = point
    end
  end

  if prevPoint ~= point then
    tinsert(newPoints, point)
  end

  return newPoints
end

local function simplifyDPStep(points, first, last, sqTolerance, simplified, X, Y)
  local maxSqDist = sqTolerance
  local index

  for i = first + 1, last do
    local sqDist = getSqSegDist(points[i], points[first], points[last], X, Y)

    if sqDist > maxSqDist then
      index = i
      maxSqDist = sqDist
    end
  end

  if maxSqDist > sqTolerance then
    if index - first > 1 then
      simplifyDPStep(points, first, index, sqTolerance, simplified, X, Y)
    end

    tinsert(simplified, points[index])

    if last - index > 1 then
      simplifyDPStep(points, index, last, sqTolerance, simplified, X, Y)
    end
  end
end

local function simplifyDouglasPeucker(points, sqTolerance, X, Y)
  local last = #points

  local simplified = {
    points[1]
  }
  simplifyDPStep(points, 1, last, sqTolerance, simplified, X, Y)
  tinsert(simplified, points[last])

  return simplified
end

local immerseOL = blink.immerseOL
function blink.simplifyPath(points, tolerance, highestQuality, X, Y)
  if #points <= 2 then
    return points
  end

  local sqTolerance = tolerance ~= nil and tolerance ^ 2 or 1

  X = X or "x"
  Y = Y or "y"

  points = highestQuality and points or simplifyRadialDist(points, sqTolerance, X, Y)
  points = simplifyDouglasPeucker(points, sqTolerance, X, Y)

  immerseOL(points)
  return points
end

local PathTypes = blink.PathTypes

local fwFunc = function()
  return 0
end
function blink.path(...)
  
  local args = {...}
  
  local x1, y1, z1, x2, y2, z2, weights, mapID, water = unpack(args)

  if type(x1) == "table" and type(y1) == "table" then
    local x, y, z = x1.position()
    local xx, yy, zz = y1.position()
    x1, y1, z1 = x, y, z
    x2, y2, z2 = xx, yy, zz
  elseif type(x1) == "table" then
    local x, y, z = x1.position()
    x2, y2, z2 = y1, z1, x2
    x1, y1, z1 = x, y, z
  end

  if type(args[#args]) == "boolean" then
    water = args[#args]
  end

  mapID = mapID or blink.mapID

  local key = x1 .. y1 .. z1 .. x2 .. y2 .. z2 .. mapID
  if memoized_paths[key] then
    return memoized_paths[key]
  end
  if unlocker.type == "daemonic" then
    local path = {}
    local count = FindPath(mapID, x1, y1, z1, x2, y2, z2, water ~= nil and water or IsSwimming())
    immerseOL(path)
    if count == 0 then
      return path
    end
    for i = 1, count do
      local x, y, z = GetPathNode(i)
      path[#path + 1] = {
        x = x,
        y = y,
        z = z
      }
    end
    return path, PathTypes.PATHFIND_NORMAL
  elseif unlocker.type == "noname" then
    local path
    path = GenerateLocalPath(mapID, x1, y1, z1, x2, y2, z2)
    path = path or {
      { x = x1, y = y1, z = z1 },
      { x = x2, y = y2, z = z2 }
    }
    immerseOL(path)
    return path
  elseif unlocker.Util.Draw then
    local path, pathType
    if IsFlying() then
      path = unlocker.Util.Fly:GetFlightRoute(x1, y1, z1, x2, y2, z2)
    else
      path, pathType = GeneratePathWeighted(x1, y1, z1, x2, y2, z2, mapID, weights or fwFunc)
      if pathType == PathTypes.PATHFIND_NOPATH and not path then
        return false
      end
    end
    path = path or {}
    immerseOL(path)
    return path, pathType
  end
end
blink.Nav = blink.Path

function blink.GetFlightRoute(sx, sy, sz, tx, ty, tz)
  local tl = blink.TraceLine
  
  if unlockerType == "tinkr" then
    return unlocker.Util.Fly:GetFlightRoute(sx, sy, sz, tx, ty, tz)
  else

    local path = {}

    tinsert(path, {
      x = sx,
      y = sy,
      z = sz
    })

    -- do some cool shit to generate a real path here

    tinsert(path, {
      x = tx, 
      y = ty,
      z = tz
    })

    return path

  end
end

function blink:DrawPath(path)
  if type(path) ~= "table" then
    return
  end
  if not path[1] or not path[1].x then
    return
  end
  tinsert(self.PathsToDraw, path)
end
