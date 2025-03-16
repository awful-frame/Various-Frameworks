local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
____exports.StompList = __TS__Class()
local StompList = ____exports.StompList
StompList.name = "StompList"
function StompList.prototype.____constructor(self)
end
function StompList.shouldStomp(self, id)
    local item = __TS__ArrayFind(
        self.list,
        function(____, i) return i.id == id end
    )
    if item == nil then
        return false
    end
    if item.preventStompingCb ~= nil and item.preventStompingCb() then
        return false
    end
    if item.reasonStompCb ~= nil and not item.reasonStompCb() then
        return false
    end
    return true
end
function StompList.replacePreventStompCb(self, id, cb)
    do
        local i = 0
        while i < #self.list do
            if self.list[i + 1].id == id then
                self.list[i + 1].preventStompingCb = cb
            end
            i = i + 1
        end
    end
end
function StompList.replaceReasonStompCb(self, id, cb)
    do
        local i = 0
        while i < #self.list do
            if self.list[i + 1].id == id then
                self.list[i + 1].reasonStompCb = cb
            end
            i = i + 1
        end
    end
end
StompList.list = {}
____exports.StompItem = __TS__Class()
local StompItem = ____exports.StompItem
StompItem.name = "StompItem"
function StompItem.prototype.____constructor(self, _id, _isFragile, _noStompCb, _reasonStompCb)
    if _noStompCb == nil then
        _noStompCb = nil
    end
    if _reasonStompCb == nil then
        _reasonStompCb = nil
    end
    self.isFragile = false
    self.id = _id
    self.isFragile = _isFragile()
    self.preventStompingCb = _noStompCb
    self.reasonStompCb = _reasonStompCb
end
awful.Populate(
    {
        ["Utilities.Stomp.stompItem"] = ____exports,
    },
    ravn,
    getfenv(1)
)
