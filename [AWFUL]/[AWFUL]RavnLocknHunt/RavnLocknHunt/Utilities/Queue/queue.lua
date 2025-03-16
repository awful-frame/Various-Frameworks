local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
____exports.Queue = __TS__Class()
local Queue = ____exports.Queue
Queue.name = "Queue"
function Queue.prototype.____constructor(self)
end
function Queue.addToQueue(self, u, ind, seconds, spellId)
    if seconds == nil then
        seconds = 4
    end
    if not u.exists then
        return
    end
    if u.dead then
        return
    end
    local time = GetTime() + seconds
    local int = {unit = u.guid, timeOut = time, spellId = spellId}
    self.queues[ind] = int
end
function Queue.purgeQueuePostCast(self, id)
    for key, value in pairs(self.queues) do
        if value.spellId == id then
            self.queues[key] = nil
        end
    end
end
function Queue.update(self)
    local time = GetTime()
    local cleanKeys = {}
    for key, value in pairs(self.queues) do
        local u = awful.GetObjectWithGUID(value.unit)
        if value.timeOut < time or not u or not u.exists or u.dead then
            cleanKeys[#cleanKeys + 1] = key
        end
    end
    __TS__ArrayForEach(
        cleanKeys,
        function(____, key)
            self.queues[key] = nil
        end
    )
end
Queue.queues = {}
Queue.HUNTER_TRAP = "hunterTrap"
Queue.HUNTER_INTIMIDATION = "hunterIntimidation"
Queue.HUNTER_ROS = "hunterRos"
Queue.HUNTER_LIB = "hunterLib"
Queue.HUNTER_BURSTINGSHOT = "hunterBurstingShot"
Queue.HUNTER_SCATTER = "hunterScatter"
Queue.HUNTER_REVERSE = "hunterReverse"
Queue.HUNTER_BADMANNER = "hunterBadManner"
Queue.WARLOCK_FEAR = "wlFear"
Queue.WARLOCK_COIL = "wlCoil"
Queue.WARLOCK_PORT = "wlPort"
Queue.WARLOCK_SCREAM = "wlScream"
awful.Populate(
    {
        ["Utilities.Queue.queue"] = ____exports,
    },
    ravn,
    getfenv(1)
)
