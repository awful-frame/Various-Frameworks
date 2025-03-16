local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.Memory = __TS__Class()
local Memory = ____exports.Memory
Memory.name = "Memory"
function Memory.prototype.____constructor(self)
end
function Memory.caching(cache, reference, expression)
    local cached = cache[reference]
    if cached == nil then
        local val = expression()
        if val == nil then
            cache[reference] = "INVALID"
            return nil
        else
            cache[reference] = val
            return val
        end
    else
        if cached == "INVALID" then
            return nil
        end
        return cached
    end
end
function Memory.GetTime(self)
    return self.caching(self._memCache, "time", GetTime)
end
function Memory.tickerFunction(self, key, interval, func)
    local cacheName = key
    local entry = self._memCache[cacheName]
    local canSend = not entry or awful.time - entry > interval
    if canSend then
        func()
        self._memCache[cacheName] = awful.time
    end
end
Memory._memCache = {}
awful.Populate(
    {
        ["Utilities.Memory.Memory"] = ____exports,
    },
    ravn,
    getfenv(1)
)
