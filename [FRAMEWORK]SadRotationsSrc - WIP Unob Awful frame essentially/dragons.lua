local Unlocker, blink = ...

local player = blink.player

local GetPitch = GetPitch or UnitPitch
local abs = math.abs

local PITCH_UP_DURATION = 2.5

local skywardAscent = blink.Spell(372610)
local surgeForward = blink.Spell(372608)
local whirlingSurge = blink.Spell(361584)

local dragonFlags = bit.bor(0x1, 0x2, 0x10, 0x20, 0x100, 0x10000, 0x20000)
local function dragonLoS(x, y, z)
  local px, py, pz = player.position()
  return blink.TraceLine(px, py, pz + 1.2, x, y, z + 1.2, dragonFlags) == 0
end

local vigor = setmetatable({}, {
  __index = function(self, key)
    return key == "max" and #C_UIWidgetManager.GetTextureAndTextRowVisualizationInfo(4216).entries or key == "now" and
             #C_UIWidgetManager.GetTextureAndTextRowVisualizationInfo(4217).entries or key == "min" and 0
  end
})

local momentum = setmetatable({}, {
  __index = function(self, key)
    return key == "forward" and player.dspeed.horizontal or key == "vertical" and player.dspeed.vertical
  end
})

local yaw = setmetatable({
  last_set = 0,
  current = "none",
  stopTimer = nil
}, {
  __index = function(self, key)
    return key == "left" and function(self)
      self.last_set = GetTime()
      TurnRightStop()
      TurnLeftStart()
      if self.stopTimer then
        self.stopTimer:Cancel()
      end
      self.stopTimer = C_Timer.NewTimer(0.15, function(self)
        TurnLeftStop()
        self:Cancel()
      end)
    end or key == "right" and function(self)
      self.last_set = GetTime()
      TurnLeftStop()
      TurnRightStart()
      if self.stopTimer then
        self.stopTimer:Cancel()
      end
      self.stopTimer = C_Timer.NewTimer(0.15, function(self)
        TurnRightStop()
        self:Cancel()
      end)
    end or key == "stop" and function()
      TurnLeftStop()
      TurnRightStop()
    end or key == "set" and function(self, rotation)
      local current = player.rotation
      local d = blink.DistanceBetweenAngles(current, rotation)
      if d > 0.05 then
        self:right()
      elseif d <= -0.05 then
        self:left()
      else
        self:stop()
      end
    end
  end
})

-- GetPitch : polar -1.536 to 1.536 
local pitch = setmetatable({
  last_set = 0,
  stopTimer = nil
}, {
  __index = function(self, key)
    return key == "deg" and GetPitch("player") * 180 / math.pi or key == "abs" and abs(self.deg) or key == "current" and
             GetPitch("player") or key == "toDeg" and function(rad)
      return rad * 360 / math.pi
    end or key == "toRad" and function(deg)
      return deg * math.pi / 180
    end or key == "up" and function()
      PitchDownStop()
      PitchUpStart()
      if self.stopTimer then
        self.stopTimer:Cancel()
      end
      self.stopTimer = C_Timer.NewTimer(0.15, function(self)
        PitchUpStop()
        self:Cancel()
      end)
    end or key == "down" and function()
      PitchUpStop()
      PitchDownStart()
      if self.stopTimer then
        self.stopTimer:Cancel()
      end
      self.stopTimer = C_Timer.NewTimer(0.15, function(self)
        PitchDownStop()
        self:Cancel()
      end)
    end or key == "stop" and function()
      PitchUpStop()
      PitchDownStop()
    end or key == "set" and function(self, deg)
      -- no throttling, but much smaller pitch change step size?
      -- if GetTime() - self.last_set < 0.05 then
      --   return
      -- end
      local rad = self.toRad(deg)
      if self.current < rad then
        self:up()
      elseif self.current > rad then
        self:down()
      else
        self:stop()
      end
      -- SetPitch(self.toRad(deg))
    end or key == "control" and function(self, x, y, z)
      if not player.mounted then
        return
      end
      -- with coordinates passed, we will attempt to optimize pitch to reach them?
      -- heavy pitch up after skyward ascent
      local px, py, pz = player.position()

      local homeFree = dragonLoS(x, y, z + 0.5) and momentum.forward > 20 and pz - z > 2
      if skywardAscent.used(PITCH_UP_DURATION) and not homeFree then
        blink.alert("Pitching up, skyward ascent")

        local ascent_angle = 46 + (momentum.vertical * 0.05) + (momentum.forward * 0.025)
        if abs(self.deg - ascent_angle) > 1.5 then
          self:set(ascent_angle)
        end

        -- maintain pitch to optimize momentum
      else

        -- try to maintain -5deg pitch if forward momentum is > 55
        -- decrease pitch to gain more forward momentum when necessary
        local optimalPitch = -5
        if momentum.forward >= 60 then
          optimalPitch = -5
        elseif momentum.forward > 55 then
          optimalPitch = -10
        elseif momentum.forward > 45 then
          optimalPitch = -12
        elseif momentum.forward > 40 then
          optimalPitch = -15
        elseif momentum.forward > 35 then
          optimalPitch = -20
        elseif momentum.forward > 30 then
          optimalPitch = -25
        elseif momentum.forward > 25 then
          optimalPitch = -30
        elseif momentum.forward > 20 then
          optimalPitch = -35
        elseif momentum.forward > 15 then
          optimalPitch = -37
        elseif momentum.forward > 10 then
          optimalPitch = -40
        elseif momentum.forward > 5 then
          optimalPitch = -42
        else
          optimalPitch = -45
        end

        -- make this one line instead
        -- local optimalPitch = momentum.forward * 0.5 - 20
        -- if pz - z > 5 then
        --   optimalPitch = optimalPitch - (pz - z) * 0.5
        -- end

        -- -- pitch down for thrill
        -- if not player.buff(377234) then
        --   optimalPitch = optimalPitch - 5 - (65 - momentum.forward)
        -- end

        -- if optimalPitch < -70 then
        --   optimalPitch = -70
        -- end

        -- local clear = false

        -- local bottom_clearance = 30
        -- local gz = blink.GroundZ(px, py, pz)
        -- if pz - gz > bottom_clearance then
        --   pz = pz - bottom_clearance
        -- else
        --   pz = gz + 0.6
        -- end

        -- local angle = blink.anglesBetween(px, py, pz, x, y, z)
        -- local duration = 2.5
        -- local dist = momentum.forward * duration + 10 -- projected distance at x sec

        -- local cx, cy, cz = px + dist * math.cos(angle), py + dist * math.sin(angle),
        --   pz + (dist * math.sin(self.deg)) - bottom_clearance
        -- blink.StabPos = {cx, cy, cz}

        -- while optimalPitch < 40 and not clear do
        --   local fx, fy, fz = px + dist * math.cos(angle), py + dist * math.sin(angle),
        --     pz + (dist * math.sin(optimalPitch)) - bottom_clearance
        --   if not dragonLoS(fx, fy, fz) then
        --     optimalPitch = optimalPitch + 10
        --   else
        --     optimalPitch = optimalPitch + 10
        --     blink.GayPos = {fx, fy, fz}
        --     clear = true
        --   end
        -- end

        if abs(self.deg - optimalPitch) > 0.2 then
          self:set(optimalPitch)
        end
      end
    end
  end
})

-- is target position in los? go straight to it.
-- is forward position at -5deg angle 5 seconds ahead of us in LoS?
-- no ? skyward ascent 
-- yes ? continue forward, maintain -5deg pitch 
-- is forward momentum < 10? 
-- no ? continue forward, maintain -5deg pitch
-- yes ? surge forward

local function needAltitude(x, y, z, immediately)
  local duration = 3.25
  local dist = momentum.forward * duration + (immediately and 30 or 0) -- projected distance at x seconds
  local px, py, pz = player.position()
  local angle = blink.anglesBetween(px, py, pz, x, y, z)

  local bottom_clearance = 1
  local fx, fy, fz = px + dist * math.cos(angle), py + dist * math.sin(angle),
    pz + (dist * math.sin(pitch.deg)) + (momentum.vertical * (duration / 4)) - bottom_clearance

  dist = math.sqrt((x - px) ^ 2 + (y - py) ^ 2)

  local zd = z - pz
  -- will be hitting something at our current pitch
  return not (dragonLoS(x, y, z + bottom_clearance) and pz - z > 0) and
           (not dragonLoS(fx, fy, fz + bottom_clearance) -- will not have sufficient altitude to reach target location
    or not immediately and
             (dist < 70 and zd > 15 or dist < 100 and zd > 25 or dist < 150 and zd > 40 or dist < 180 and zd > 55 or
               dist < 240 and zd > 70))
end

local function canReach(x, y, z)
  local px, py, pz = player.position()

  -- out of LoS
  if not dragonLoS(x, y, z + 0.5) then
    return false
  end

  local dist = player.distanceToLiteral(x, y, z)
  local projZ = pz + (dist * math.sin(pitch.deg))

  -- too far
  local dist2d = math.sqrt((x - px) ^ 2 + (y - py) ^ 2)
  if dist2d > 150 then
    return false
  end

  -- too high ( by n yd )
  if projZ + 7 < z and dist > 10 then
    return false
  end

  return true
end

local function DragonRideTo(x, y, z)
  if GetCVar("dragonRidingPitchSensitivity") ~= "80" then
    SetCVar("dragonRidingPitchSensitivity", 80)
  end
  if GetCVar("dragonRidingTurnSensitivity") ~= "40" then
    SetCVar("dragonRidingTurnSensitivity", 40)
  end
  local dist = player.distanceToLiteral(x, y, z)
  if dist < 5 then
    return
  end
  if player.mounted then
    -- initial liftoff
    if not player.flying and momentum.vertical < 40 then
      if vigor.now > 3 then
        -- temp, for testing (only take off if > 30yd from target location)
        if dist > 30 then
          JumpOrAscendStart()
        end
      else
        blink.alert("Waiting for Vigor")
      end
    else
      local px, py, pz = player.position()

      -- control yaw
      if dist > 35 then
        local angle = blink.anglesBetween(px, py, pz, x, y, z)
        if not player.facing(angle, 1) then
          yaw:set(angle)
        end
      end

      -- go straight to target location when possible 
      -- (need some sort of large box TraceLine scans to the position to validate initial TraceLine. dragon hitbox big.)
      if canReach(x, y, z) then

        -- there's def some calc here to get proper desired pitch for NEXT frame 
        -- based on predicted position
        local timePerFrame = 1 / GetFramerate()
        local px, py, pz = player.position()
        local speed = momentum.forward
        local dir = player.rotation
        local dist = blink.Distance(px, py, pz, x, y, z)

        -- adjust pitch to target location
        local desired_pitch = math.deg(math.atan2(z - pz, dist) * 2) + 0.25
        if abs(pitch.deg - desired_pitch) > 1 then
          blink.alert("Pitching to target location, we're here! :D")
          pitch:set(desired_pitch)
        end
      else
        -- control pitch
        pitch:control(x, y, z)
        -- blink.alert({msg="outer control", duration=0.1})
        if momentum.forward < 20 and not needAltitude(x, y, z, true) then
          if vigor.now >= 2 then
            if not surgeForward.used(1.25) and not skywardAscent.used(2.25) and surgeForward:Castable() then
              -- pitch up to cast at good angle
              -- if pitch.deg < -25 then
              --   blink.alert("Pitching up, surge forward", surgeForward.id)
              --   pitch:set(-20)
              -- end

              surgeForward:CastAlert()
            end
          else
            blink.alert("Not using surge, low vigor")
          end
        elseif needAltitude(x, y, z) then
          skywardAscent:CastAlert()
          -- surge forward for momentum with vigor surplus
        elseif momentum.forward < 55 + (vigor.now > 4 and 10 or 0) and pitch.deg < 35 then
          if vigor.now >= 2 then
            if not skywardAscent.used(2.25) and surgeForward:Castable() then
              -- pitch up to cast at good angle
              -- if pitch.deg < -20 then
              --   blink.alert("Pitching up, surge forward", surgeForward.id)
              --   pitch:set(-15)
              -- end

              surgeForward:CastAlert()
            end
          else
            blink.alert("Not using surge, low vigor")
          end
        end
      end
    end
  end
end

local dragon = {
  pitch = pitch,
  momentum = momentum,
  vigor = vigor,
  ride = DragonRideTo,
  surgeForward = surgeForward,
  skywardAscent = skywardAscent,
  whirlingSurge = whirlingSurge
}

blink.dragon = dragon

-- tests

-- local pos = {
--   235.10836,
--   -655.96862,
--   1234.47375
-- }

-- apex observatory
local pos = {951.29046, 2751.52758, 202.44934}

-- obsidian throne
-- local pos = {
--   2232.210937,
--   2840.99975,
--   684.4161376
-- }

-- PlayerName:SetText("Imagine Dragons")

-- local lastThing = 0
-- blink.Draw(function(draw)
--   if IsMouseButtonDown("LeftButton") and GetTime() - lastThing > 0.5 then
--     pos = {blink.CursorPosition()}
--     lastThing = GetTime()
--   end

--   -- target position circle
--   local x, y, z = unpack(pos)
--   if player.distanceToLiteral(x, y, z) < 1600 then
--     draw:SetColor(155, 155, 155, 250)
--     draw:FilledCircle(x, y, z, 4.5)
--     draw:Outline(x, y, z, 4.5)
--   end

--   -- dragon movement prediction
--   local px, py, pz = player.position()

--   -- momentum forward has value of % angle forward
--   -- vertical momentum has value of % angle upward
-- end)

-- blink.onUpdate(function()
--   if not blink.enabled then
--     return
--   end
--   local x, y, z = unpack(pos)
--   dragon.ride(x, y, z)
-- end)
