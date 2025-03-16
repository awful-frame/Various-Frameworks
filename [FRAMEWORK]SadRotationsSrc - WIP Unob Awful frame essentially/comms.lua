local Unlocker, blink = ...
local go, chat = blink.go, C_ChatInfo
local player = blink.player
local b64 = blink.b64

local SendAddonMessage = SendAddonMessage or C_ChatInfo and C_ChatInfo.SendAddonMessage or function() end

local function getCTL()
  local _G = _G
  local CTL_VERSION = 23

  if _G.ChatThrottleLib then
    if _G.ChatThrottleLib.version >= CTL_VERSION then
      -- There's already a newer (or same) version loaded. Buh-bye.
      _G.ChatThrottleLib.MAX_CPS = 1200
      _G.ChatThrottleLib.BURST = 6000
      return _G.ChatThrottleLib
    elseif not _G.ChatThrottleLib.securelyHooked then
      print("ChatThrottleLib: Warning: There's an ANCIENT ChatThrottleLib.lua (pre-wow 2.0, <v16) in an addon somewhere. Get the addon updated or copy in a newer ChatThrottleLib.lua (>=v16) in it!")
      -- ATTEMPT to unhook; this'll behave badly if someone else has hooked...
      -- ... and if someone has securehooked, they can kiss that goodbye too... >.<
      _G.SendChatMessage = _G.ChatThrottleLib.ORIG_SendChatMessage
      if _G.ChatThrottleLib.ORIG_SendAddonMessage then
        _G.SendAddonMessage = _G.ChatThrottleLib.ORIG_SendAddonMessage
      end
    end
    _G.ChatThrottleLib.ORIG_SendChatMessage = nil
    _G.ChatThrottleLib.ORIG_SendAddonMessage = nil
  end

  if not _G.ChatThrottleLib then
    _G.ChatThrottleLib = {}
  end

  local ChatThrottleLib = _G.ChatThrottleLib

  ChatThrottleLib.version = CTL_VERSION

  ------------------ TWEAKABLES -----------------

  ChatThrottleLib.MAX_CPS = 1200			  -- 2000 seems to be safe if NOTHING ELSE is happening. let's call it 800.
  ChatThrottleLib.MSG_OVERHEAD = 40		-- Guesstimate overhead for sending a message; source+dest+chattype+protocolstuff

  ChatThrottleLib.BURST = 6000				-- WoW's server buffer seems to be about 32KB. 8KB should be safe, but seen disconnects on _some_ servers. Using 4KB now.

  ChatThrottleLib.MIN_FPS = 20				-- Reduce output CPS to half (and don't burst) if FPS drops below this value


  local setmetatable = setmetatable
  local table_remove = table.remove
  local tostring = tostring
  local GetTime = GetTime
  local math_min = math.min
  local math_max = math.max
  local next = next
  local strlen = string.len
  local GetFramerate = GetFramerate
  local strlower = string.lower
  local unpack,type,pairs,wipe = unpack,type,pairs,wipe
  local UnitInRaid,UnitInParty = UnitInRaid,UnitInParty


  -----------------------------------------------------------------------
  -- Double-linked ring implementation

  local Ring = {}
  local RingMeta = { __index = Ring }

  function Ring:New()
    local ret = {}
    setmetatable(ret, RingMeta)
    return ret
  end

  function Ring:Add(obj)	-- Append at the "far end" of the ring (aka just before the current position)
    if self.pos then
      obj.prev = self.pos.prev
      obj.prev.next = obj
      obj.next = self.pos
      obj.next.prev = obj
    else
      obj.next = obj
      obj.prev = obj
      self.pos = obj
    end
  end

  function Ring:Remove(obj)
    obj.next.prev = obj.prev
    obj.prev.next = obj.next
    if self.pos == obj then
      self.pos = obj.next
      if self.pos == obj then
        self.pos = nil
      end
    end
  end



  -----------------------------------------------------------------------
  -- Recycling bin for pipes 
  -- A pipe is a plain integer-indexed queue of messages
  -- Pipes normally live in Rings of pipes  (3 rings total, one per priority)

  ChatThrottleLib.PipeBin = nil -- pre-v19, drastically different
  local PipeBin = setmetatable({}, {__mode="k"})

  local function DelPipe(pipe)
    PipeBin[pipe] = true
  end

  local function NewPipe()
    local pipe = next(PipeBin)
    if pipe then
      wipe(pipe)
      PipeBin[pipe] = nil
      return pipe
    end
    return {}
  end




  -----------------------------------------------------------------------
  -- Recycling bin for messages

  ChatThrottleLib.MsgBin = nil -- pre-v19, drastically different
  local MsgBin = setmetatable({}, {__mode="k"})

  local function DelMsg(msg)
    msg[1] = nil
    -- there's more parameters, but they're very repetetive so the string pool doesn't suffer really, and it's faster to just not delete them.
    MsgBin[msg] = true
  end

  local function NewMsg()
    local msg = next(MsgBin)
    if msg then
      MsgBin[msg] = nil
      return msg
    end
    return {}
  end


  -----------------------------------------------------------------------
  -- ChatThrottleLib:Init
  -- Initialize queues, set up frame for OnUpdate, etc

  function ChatThrottleLib:Init()	

    -- Set up queues
    if not self.Prio then
      self.Prio = {}
      self.Prio["ALERT"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
      self.Prio["NORMAL"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
      self.Prio["BULK"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
    end

    -- v4: total send counters per priority
    for _, Prio in pairs(self.Prio) do
      Prio.nTotalSent = Prio.nTotalSent or 0
    end

    if not self.avail then
      self.avail = 0 -- v5
    end
    if not self.nTotalSent then
      self.nTotalSent = 0 -- v5
    end


    -- Set up a frame to get OnUpdate events
    if not self.Frame then
      self.Frame = CreateFrame("Frame")
      self.Frame:Hide()
    end
    self.Frame:SetScript("OnUpdate", self.OnUpdate)
    self.Frame:SetScript("OnEvent", self.OnEvent)	-- v11: Monitor P_E_W so we can throttle hard for a few seconds
    self.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.OnUpdateDelay = 0
    self.LastAvailUpdate = GetTime()
    self.HardThrottlingBeginTime = GetTime()	-- v11: Throttle hard for a few seconds after startup

    -- Hook SendChatMessage and SendAddonMessage so we can measure unpiped traffic and avoid overloads (v7)
    if not self.securelyHooked then
      -- Use secure hooks as of v16. Old regular hook support yanked out in v21.
      self.securelyHooked = true
      --SendChatMessage
      if _G.SendChatMessage then
        hooksecurefunc("SendChatMessage", function(...)
          return ChatThrottleLib.Hook_SendChatMessage(...)
        end)
      end
      --SendAddonMessage
      if _G.SendAddonMessage then
        hooksecurefunc("SendAddonMessage", function(...)
          return ChatThrottleLib.Hook_SendAddonMessage(...)
        end)
      end
    end
    self.nBypass = 0
  end


  -----------------------------------------------------------------------
  -- ChatThrottleLib.Hook_SendChatMessage / .Hook_SendAddonMessage

  local bMyTraffic = false

  function ChatThrottleLib.Hook_SendChatMessage(text, chattype, language, destination, ...)
    if bMyTraffic then
      return
    end
    local self = ChatThrottleLib
    local size = strlen(tostring(text or "")) + strlen(tostring(destination or "")) + self.MSG_OVERHEAD
    self.avail = self.avail - size
    self.nBypass = self.nBypass + size	-- just a statistic
  end
  function ChatThrottleLib.Hook_SendAddonMessage(prefix, text, chattype, destination, ...)
    if bMyTraffic then
      return
    end
    local self = ChatThrottleLib
    local size = tostring(text or ""):len() + tostring(prefix or ""):len();
    size = size + tostring(destination or ""):len() + self.MSG_OVERHEAD
    self.avail = self.avail - size
    self.nBypass = self.nBypass + size	-- just a statistic
  end



  -----------------------------------------------------------------------
  -- ChatThrottleLib:UpdateAvail
  -- Update self.avail with how much bandwidth is currently available

  function ChatThrottleLib:UpdateAvail()
    local now = GetTime()
    local MAX_CPS = self.MAX_CPS;
    local newavail = MAX_CPS * (now - self.LastAvailUpdate)
    local avail = self.avail

    if now - self.HardThrottlingBeginTime < 5 then
      -- First 5 seconds after startup/zoning: VERY hard clamping to avoid irritating the server rate limiter, it seems very cranky then
      avail = math_min(avail + (newavail*0.1), MAX_CPS*0.5)
      self.bChoking = true
    elseif GetFramerate() < self.MIN_FPS then		-- GetFrameRate call takes ~0.002 secs
      avail = math_min(MAX_CPS, avail + newavail*0.5)
      self.bChoking = true		-- just a statistic
    else
      avail = math_min(self.BURST, avail + newavail)
      self.bChoking = false
    end

    avail = math_max(avail, 0-(MAX_CPS*2))	-- Can go negative when someone is eating bandwidth past the lib. but we refuse to stay silent for more than 2 seconds; if they can do it, we can.

    self.avail = avail
    self.LastAvailUpdate = now

    return avail
  end


  -----------------------------------------------------------------------
  -- Despooling logic
  -- Reminder:
  -- - We have 3 Priorities, each containing a "Ring" construct ...
  -- - ... made up of N "Pipe"s (1 for each destination/pipename)
  -- - and each pipe contains messages

  function ChatThrottleLib:Despool(Prio)
    local ring = Prio.Ring
    while ring.pos and Prio.avail > ring.pos[1].nSize do
      local msg = table_remove(ring.pos, 1)
      if not ring.pos[1] then  -- did we remove last msg in this pipe?
        local pipe = Prio.Ring.pos
        Prio.Ring:Remove(pipe)
        Prio.ByName[pipe.name] = nil
        DelPipe(pipe)
      else
        Prio.Ring.pos = Prio.Ring.pos.next
      end
      local didSend=false
      local lowerDest = strlower(msg[3] or "")
      if lowerDest == "raid" and not UnitInRaid("player") then
        -- do nothing
      elseif lowerDest == "party" and not UnitInParty("player") then
        -- do nothing
      else
        Prio.avail = Prio.avail - msg.nSize
        bMyTraffic = true
        msg.f(unpack(msg, 1, msg.n))
        bMyTraffic = false
        Prio.nTotalSent = Prio.nTotalSent + msg.nSize
        DelMsg(msg)
        didSend = true
      end
      -- notify caller of delivery (even if we didn't send it)
      if msg.callbackFn then
        msg.callbackFn (msg.callbackArg, didSend)
      end
      -- USER CALLBACK MAY ERROR
    end
  end


  function ChatThrottleLib.OnEvent(this,event)
    -- v11: We know that the rate limiter is touchy after login. Assume that it's touchy after zoning, too.
    local self = ChatThrottleLib
    if event == "PLAYER_ENTERING_WORLD" then
      self.HardThrottlingBeginTime = GetTime()	-- Throttle hard for a few seconds after zoning
      self.avail = 0
    end
  end


  function ChatThrottleLib.OnUpdate(this,delay)
    local self = ChatThrottleLib

    self.OnUpdateDelay = self.OnUpdateDelay + delay
    if self.OnUpdateDelay < 0.08 then
      return
    end
    self.OnUpdateDelay = 0

    self:UpdateAvail()

    if self.avail < 0  then
      return -- argh. some bastard is spewing stuff past the lib. just bail early to save cpu.
    end

    -- See how many of our priorities have queued messages (we only have 3, don't worry about the loop)
    local n = 0
    for prioname,Prio in pairs(self.Prio) do
      if Prio.Ring.pos or Prio.avail < 0 then 
        n = n + 1 
      end
    end

    -- Anything queued still?
    if n<1 then
      -- Nope. Move spillover bandwidth to global availability gauge and clear self.bQueueing
      for prioname, Prio in pairs(self.Prio) do
        self.avail = self.avail + Prio.avail
        Prio.avail = 0
      end
      self.bQueueing = false
      self.Frame:Hide()
      return
    end

    -- There's stuff queued. Hand out available bandwidth to priorities as needed and despool their queues
    local avail = self.avail/n
    self.avail = 0

    for prioname, Prio in pairs(self.Prio) do
      if Prio.Ring.pos or Prio.avail < 0 then
        Prio.avail = Prio.avail + avail
        if Prio.Ring.pos and Prio.avail > Prio.Ring.pos[1].nSize then
          self:Despool(Prio)
          -- Note: We might not get here if the user-supplied callback function errors out! Take care!
        end
      end
    end

  end




  -----------------------------------------------------------------------
  -- Spooling logic

  function ChatThrottleLib:Enqueue(prioname, pipename, msg)
    local Prio = self.Prio[prioname]
    local pipe = Prio.ByName[pipename]
    if not pipe then
      self.Frame:Show()
      pipe = NewPipe()
      pipe.name = pipename
      Prio.ByName[pipename] = pipe
      Prio.Ring:Add(pipe)
    end

    pipe[#pipe + 1] = msg

    self.bQueueing = true
  end

  function ChatThrottleLib:SendChatMessage(prio, prefix,   text, chattype, language, destination, queueName, callbackFn, callbackArg)
    if not self or not prio or not prefix or not text or not self.Prio[prio] then
      error('Usage: ChatThrottleLib:SendChatMessage("{BULK||NORMAL||ALERT}", "prefix", "text"[, "chattype"[, "language"[, "destination"]]]', 2)
    end
    if callbackFn and type(callbackFn)~="function" then
      error('ChatThrottleLib:ChatMessage(): callbackFn: expected function, got '..type(callbackFn), 2)
    end

    local nSize = text:len()

    if nSize>255 then
      error("ChatThrottleLib:SendChatMessage(): message length cannot exceed 255 bytes", 2)
    end

    nSize = nSize + self.MSG_OVERHEAD

    -- Check if there's room in the global available bandwidth gauge to send directly
    if not self.bQueueing and nSize < self:UpdateAvail() then
      self.avail = self.avail - nSize
      bMyTraffic = true
      _G.SendChatMessage(text, chattype, language, destination)
      bMyTraffic = false
      self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
      if callbackFn then
        callbackFn (callbackArg, true)
      end
      -- USER CALLBACK MAY ERROR
      return
    end

    -- Message needs to be queued
    local msg = NewMsg()
    msg.f = _G.SendChatMessage
    msg[1] = text
    msg[2] = chattype or "SAY"
    msg[3] = language
    msg[4] = destination
    msg.n = 4
    msg.nSize = nSize
    msg.callbackFn = callbackFn
    msg.callbackArg = callbackArg

    self:Enqueue(prio, queueName or (prefix..(chattype or "SAY")..(destination or "")), msg)
  end


  function ChatThrottleLib:SendAddonMessage(prio, prefix, text, chattype, target, queueName, callbackFn, callbackArg)
    if not self or not prio or not prefix or not text or not chattype or not self.Prio[prio] then
      error('Usage: ChatThrottleLib:SendAddonMessage("{BULK||NORMAL||ALERT}", "prefix", "text", "chattype"[, "target"])', 2)
    end
    if callbackFn and type(callbackFn)~="function" then
      error('ChatThrottleLib:SendAddonMessage(): callbackFn: expected function, got '..type(callbackFn), 2)
    end

    local nSize = text:len();

    if RegisterAddonMessagePrefix then
      if nSize>255 then
        error("ChatThrottleLib:SendAddonMessage(): message length cannot exceed 255 bytes", 2)
      end
    else
      nSize = nSize + prefix:len() + 1
      if nSize>255 then
        error("ChatThrottleLib:SendAddonMessage(): prefix + message length cannot exceed 254 bytes", 2)
      end
    end

    nSize = nSize + self.MSG_OVERHEAD;

    -- Check if there's room in the global available bandwidth gauge to send directly
    if not self.bQueueing and nSize < self:UpdateAvail() then
      self.avail = self.avail - nSize
      bMyTraffic = true
      _G.SendAddonMessage(prefix, text, chattype, target)
      bMyTraffic = false
      self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
      if callbackFn then
        callbackFn (callbackArg, true)
      end
      -- USER CALLBACK MAY ERROR
      return
    end

    -- Message needs to be queued
    local msg = NewMsg()
    msg.f = _G.SendAddonMessage
    msg[1] = prefix
    msg[2] = text
    msg[3] = chattype
    msg[4] = target
    msg.n = (target~=nil) and 4 or 3;
    msg.nSize = nSize
    msg.callbackFn = callbackFn
    msg.callbackArg = callbackArg

    self:Enqueue(prio, queueName or (prefix..chattype..(target or "")), msg)
  end

  ChatThrottleLib:Init()

  return ChatThrottleLib
end

local ChatThrottleLib = getCTL()

local comms = {
  prefix = "RiEiZZo",
  callbacks = {},
  sync_req_time = 0
}

function comms.messageHandler(self, event, prefix, text, author)
  if prefix ~= comms.prefix then return end
  local decoded = b64.decode(text)
  for _, callback in ipairs(comms.callbacks) do
    callback(decoded)
  end
end

function comms.unpack(msg)
  local args = {}
  for arg in msg:gmatch("[^|]+") do
    tinsert(args, arg)
  end
  return tremove(args, 1), args
end

function comms:Dispatch(...)
  local args = {...}

  local cmd = ""
  for i, arg in ipairs(args) do
    if i == 1 then
      cmd = arg
    else
      cmd = cmd .. "|" .. arg
    end
  end

  self:Send(cmd)
end

function comms:Send(message)
  local encoded = b64.encode(message)
  ChatThrottleLib:SendAddonMessage("BULK", self.prefix, encoded, "PARTY")
  -- chat.SendAddonMessage(self.prefix, encoded, "PARTY")
end

function comms:SyncRequest()
  if not blink.player.guid then return end
  self.sync_req_time = GetTime()
  self:Send("sync.req:" .. blink.player.guid)
end

function comms:SyncRespond()
  if not blink.player.guid then return end
  self:Send("sync.res:" .. blink.player.guid)
end

function comms:Callback(callback)
  tinsert(self.callbacks, callback)
  return callback
end

function comms:UnregisterCallback(callback)
  for i, cb in ipairs(self.callbacks) do
    if cb == callback then
      tremove(self.callbacks, i)
      return
    end
  end
end

comms.eventFrame = CreateFrame("Frame")
comms.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
comms.eventFrame:SetScript("OnEvent", comms.messageHandler)
chat.RegisterAddonMessagePrefix(comms.prefix)

-- -- request re-sync on certain events
-- local gsize = -1
-- local last_synced_size = 0
-- local last_synced_size2 = 0
-- C_Timer.NewTicker(0.5, function()
--   if #go.team ~= gsize then
--     gsize = #go.team
--     go:ResetSync()
--     comms:SyncRequest()
--   end
--   if gsize ~= last_synced_size and gsize ~= 1 and #go.synced > 0 then
--     last_synced_size = gsize
--     go.print(blink.colors.cyan.."synchronized.")
--     go:UpdateComp()
--   elseif last_synced_size ~= 1 and gsize == 1 then
--     last_synced_size = gsize
--     go.print(blink.colors.red.."no sync")
--     go:UpdateComp()
--   end
-- end)

-- -- when requested to sync, send your guid
-- comms:Callback(function(msg)
--   -- sync request, request for all blink members to send their guid
--   if msg:match("sync.req:") then
--     local guid = msg:match("sync.req:(.+)")
--     if guid == player.guid then return end
--     comms:SyncRespond()
--   -- sync response, someone sent their guid to be synced
--   elseif msg:match("sync.res:") then
--     local guid = msg:match("sync.res:(.+)")
--     if guid == player.guid then return end
--     go:SyncMember(guid)
--   end
-- end)

blink.comms = comms