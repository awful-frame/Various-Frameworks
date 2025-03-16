local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____wowclass = ravn["Utilities.wowclass"]
local WowClass = ____wowclass.WowClass
____exports.LocalPlayer = __TS__Class()
local LocalPlayer = ____exports.LocalPlayer
LocalPlayer.name = "LocalPlayer"
function LocalPlayer.prototype.____constructor(self)
    self.queueWindow = 0
    self.dropFlagTimer = 0
    self.forbidenFlagCatch = false
    self.gcdInUse = 0
    self.previousTargetGuid = nil
    self.currentTargetGuid = nil
    self.previousTargetTotemGuid = nil
    self.isTargettingTotem = false
    self:setCvars()
end
function LocalPlayer.prototype.gcdFreeSince(self)
    local delta = GetTime() - self.gcdInUse
    return math.abs(delta)
end
function LocalPlayer.prototype.setCvars(self)
    SetCVar("SoftTargetInterace", "0")
    SetCVar("SoftTargetEnemyRange", "0")
    SetCVar("SoftTargetFriendRange", "0")
end
function LocalPlayer.prototype.getBaseGcd(self)
    local gcd = (awful.player.class2 == WowClass.ROGUE or awful.player.class2 == WowClass.DRUID) and 1 or 1.5
    gcd = gcd / (1 + awful.call("UnitSpellHaste", "player") / 100)
    return gcd
end
function LocalPlayer.prototype.cancelAura(self, id)
    local name = GetSpellInfo(id)
    awful.call("CancelSpellByName", name)
end
____exports.LP = __TS__New(____exports.LocalPlayer)
awful.Populate(
    {
        ["LocalPlayer.localPlayer"] = ____exports,
    },
    ravn,
    getfenv(1)
)
