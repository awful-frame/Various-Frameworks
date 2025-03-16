local Unlocker, blink, sr = ...

local bin, angles, min, max, cos, sin, inverse, sort = blink.bin, blink.AnglesBetween, min, max, math.cos, math.sin, blink.inverseAngle, table.sort
local druid, feral = sr.druid, sr.druid.feral
local player, pet, target, focus, enemyHealer, healer = blink.player, blink.pet, blink.target, blink.focus, blink.enemyHealer, blink.healer
local NewSpell, NS, events, cmd, colors, colored, alert = blink.Spell, blink.Spell, blink.events, sr.cmd, blink.colors, blink.colored, blink.alert
local UnlockerType = Unlocker.type
local onEvent, onUpdate = blink.addEventCallback, blink.addUpdateCallback
local state = sr.arenaState
local saved = sr.saved
local arena1 = blink.arena1
local arena2 = blink.arena2
local arena3 = blink.arena3
local time = blink.time


local currentSpec = GetSpecialization()

if not feral.ready then return end

if currentSpec ~= 2 then return end

druid.print = function(str)
  blink.print(colors.druid .. "|cFFf7f25c[SadRotations]: " .. str)
end

druid.print("|cFFFFFFFF|r|rCore |cFFf7f25cLoaded")

--Maim
blink.RegisterMacro("maim target", 7)
blink.RegisterMacro("maim focus", 7)
blink.RegisterMacro("maim arena1", 7)
blink.RegisterMacro("maim arena2", 7)
blink.RegisterMacro("maim arena3", 7)

--Bash
blink.RegisterMacro("bash target", 3)
blink.RegisterMacro("bash focus", 3)
blink.RegisterMacro("bash arena1", 3)
blink.RegisterMacro("bash arena2", 3)
blink.RegisterMacro("bash arena3", 3)

--Clones
blink.RegisterMacro("clone target", 1)
blink.RegisterMacro("clone focus", 1)
blink.RegisterMacro("clone arena1", 1)
blink.RegisterMacro("clone arena2", 1)
blink.RegisterMacro("clone arena3", 1)

--etc
blink.RegisterMacro('burst', 2)
blink.RegisterMacro('resonator target', 1)
blink.RegisterMacro('pause', 1)
blink.RegisterMacro('pause 1', 1)
blink.RegisterMacro('pause 2', 2)
blink.RegisterMacro('pause 3', 3)
blink.RegisterMacro('pause 4', 4)
blink.RegisterMacro('pause 5', 5)



-- on-damage events!
local recentDoubleTapAimed = 0
local recentDoubleTap = 0

local barkskin = NS(22812, { ignoreGCD = true, ignoreStuns = true })
local meld = NS(58984)
local fleshcraft = NS(324631)
local bear = NS(5487)
local cat = NS(768)
local prowl = NS(5215)
local frenzy = NS(274837, { damage = "physical", targeted = true, bleed = true })

-- auto attack
local attack = NS(6603)

function attack:start()
  return not self.current and blink.call("StartAttack")
end

function attack:stop()
  return self.current and StopAttack()
end

function druid:Attack()
  if player.stealth then return end
  if target.dead then return end
  -- handle auto attacking
  if target.enemy and target.exists then
    if target.bcc then
      attack:stop()
    else
      attack:start()
    end
  end
  
end

local function dangerousCastsScan()
    druid.currentDangerousCasts = {}
    for i=1,#blink.enemies do
      local enemy = blink.enemies[i]
      local cast = (enemy.castID or enemy.channelID)
      if cast then
        local info = dangerousCasts[cast]
        if info then
          local type = enemy.castID and "cast" or "channel"
          if type ~= "cast" or enemy.castRemains <= blink.buffer then
            local mod = info.mod and info.mod(enemy) or 1
            local dest = info.dest and info.dest(enemy)
            local weight = info.weight * mod
            tinsert(druid.currentDangerousCasts, {
              source = enemy,
              dest = dest or enemy.castTarget,
              weight = weight
            })
          end
        end
      end
    end
end

--! Aegis !--
local aegis = blink.Item(188775)
function aegis:danger()
  if healer.exists and not healer.cc and player.hp > 78 then return end
  if player.hp > 90 then return end
  return self:Use()
end

function barkskin:CastWhenPossible(callback)
    local attempts = 0
    if self.cd <= 0.5 then
      C_Timer.NewTicker(0.05, function(self)
        if barkskin:Cast({ ignoreStuns = true }) then
          self:Cancel()
          return callback and callback()
        elseif attempts >= 15 then
          self:Cancel()
        else
          attempts = attempts + 1
        end
      end)
    end
end

--sit bear abit then back cat
function bear:Hold(callback)
  if bear:Cast() then
    blink.alert("Holding Bear", bear.id)
    if not player.cc or player.stunned then
      C_Timer.After(8.1, function()
        cat:Cast()
      end)
    end
  end
end

-- on-damage events!
onEvent(function(info, event, source, dest)
  local time = GetTime()
  if event ~= "SPELL_CAST_SUCCESS" then return end
  if not source.enemy then return end

  local spellID, spellName = select(12, unpack(info))
  local events = blink.events
  local happened = event.time
  local TheHuntCast = spellID == 370965 or spellID == 323639 or spellID == 370967
  
  --check
  if not blink.enabled then return end

  -- double tapped aimed shot? barkskin it.
  if spellID == 19434 and time - recentDoubleTapAimed <= 0.15 and dest.isUnit(player) then 
    if barkskin.cd <= 0.25 then
      barkskin:CastWhenPossible(function()
        blink.alert("Barkskin (" .. colored("Double Tap Aimed Shot", colors.hunter) .. ")", barkskin.id)
      end)
    elseif barkskin.cd > 0.5 and player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Double Tap Aimed Shot", colors.hunter) .. ")", meld.id)
      end
    end
  end

  -- double tapped rapidfire? barkskin/Meld it.
  if spellID == 257044 and source.buff(260402) and dest.isUnit(player) then 
    if barkskin.cd <= 0.25 then
      barkskin:CastWhenPossible(function()
        blink.alert("Barkskin (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", barkskin.id)
      end)
    elseif barkskin.cd > 0.5 and player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Double Tap Rapid Fire", colors.hunter) .. ")", meld.id)
      end
    end
  end

  -- deathbolt? barkskin it.
  if spellID == 264106 and dest.isUnit(player) then
    if barkskin.cd <= 0.25 then
      barkskin:CastWhenPossible(function()
        blink.alert("Barkskin (" .. colored("Deathbolt", colors.warlock) .. ")", barkskin.id)
      end)
    elseif barkskin.cd > 0.5 and player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Deathbolt", colors.warlock) .. ")", meld.id)
      end
    end
  end

  -- dark soul bolt
  if spellID == 116858 and source.buff(113858) and dest.isUnit(player) then
    if barkskin.cd <= 0.25 then
      barkskin:CastWhenPossible(function()
        blink.alert("Barkskin (" .. colored("Dark Soul Chaos Bolt", colors.warlock) .. ")", barkskin.id)
      end)
    elseif barkskin.cd > 0.5 and player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Dark Soul Chaos Bolt", colors.warlock) .. ")", meld.id)
      end
    end
  end

  -- ShadowMeld Stormbolt
  if spellID == 107570 
  and dest.isUnit(player) 
  and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
    if player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Stormbolt", colors.warrior) .. ")", meld.id)
      end
    end
  end

  -- ShadowMeld Coil
  if spellID == 6789 and dest.isUnit(player) 
  and source.dist > blink.latency / (5 - bin(player.moving) * 1) then
    if player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("Coil", colors.warlock) .. ")", meld.id)
      end
    end
  end

  -- ShadowMeld the hunt
  if spellID == 370965
  and dest.isUnit(player) 
  and source.speed > 45 
  and source.dist > blink.latency / (5 - bin(player.moving) * 1) then 
    if player.race == "Night Elf" then
      if meld:Cast({stopMoving = true}) then
        return blink.alert("Shadow Meld (" .. colored("The Hunt", colors.dh) .. ")", meld.id)
      end
    end
  end

  
end)


local dangerDebuffs = {
  [167105]  = { min = 4, weight = 13 },      -- warbreaker
  [386276]  = { min = 6.5, weight = 15 },    -- bonedust brew
  [274838]  = { min = 4, weight = 7 },       -- frenzy
  [274837]  = { min = 4, weight = 7 },       -- frenzy
  [363830]  = { min = 7.5, weight = 14 },    -- sickle
  [323673]  = { min = 3, weight = 7 },       -- games
  [375901]  = { min = 3, weight = 7 },       -- games
  --[385408]  = { min = 7, weight = 8 },       -- sepsis
  -- [324149] = { min = 5 },                 -- flayed shot
  [79140]   = { min = 7, weight = 18 },      -- vendetta FIXME: ID FOR DF
  [206491]  = { min = 30, weight = 10 },     -- nemesis..?
  [376079]  = { weight = 11 },               -- spear of bastion 
}

local dangerousCasts = {
  -- mindgames
  [323673] = { weight = 17 }, 
  [375901] = { weight = 17 }, 
  -- Glacial Spike
  [199786] = { 
    weight = 12, 
    mod = function(obj, dest) 
      return 1 + bin(obj.castPct > 75) * 3 
    end 
  },
  -- chaos bolt / dark soul bolt
  [116858] = { 
    weight = 12, 
    mod = function(obj, dest) 
      return 1 + bin(obj.buff(113858)) * 3 
    end 
  },
  -- convoke (feral and boomert)
  [323764] = {
    weight = 16,
    mod = function(obj)
      return 1 + obj.channelRemains * 0.33
    end,
    dest = function(obj)
      if obj.melee then
        if obj.target.exists and obj.target.distanceTo(obj) < 7 then 
          return obj.target 
        else
          local _, _, around = blink.fullGroup.around(obj, 7.5)
          for _, friend in ipairs(around) do
            if obj.facing(friend) then
              return friend
            end
          end
        end
      else
        return obj.target
      end
    end
  },
  -- deathbolt
  [264106] = {
    weight = 12,
    mod = function(obj)
      -- rapid contagion 33% increase, but they're probably tryna do big dam
      -- dark soul is just haste increase but they probably used phantom/darkglare/all dots for this deathbolt..
      return 1 + bin(obj.buff(344566)) * 0.66 + bin(obj.buff(113860)) * 0.88
    end
  },
  -- rapid fire
  [257044] = {
    weight = 8,
    mod = function(obj)
      -- double tap rapid fire full channel biggg scary
      return (1 + bin(obj.buff(260402)) * 2) / max(0.1, 2 - obj.channelRemains)
    end
  },
  -- aimed shot
  [19434] = {
    weight = 9,
    mod = function(obj)
      -- double tap aimed shot essentially 2x dmg.. buuut trading cds and crits are scary etc etc
      return 1 + bin(obj.buff(260402)) * 2
    end
  },
}

local function dangerousCastsScan()
  druid.currentDangerousCasts = {}
  for i=1,#blink.enemies do
    local enemy = blink.enemies[i]
    local cast = (enemy.castID or enemy.channelID)
    --if enemy.distance > 90 then return end
    if cast then
      local info = dangerousCasts[cast]
      if info then
        local type = enemy.castID and "cast" or "channel"
        if type ~= "cast" or enemy.castRemains <= blink.buffer then
          local mod = info.mod and info.mod(enemy) or 1
          local dest = info.dest and info.dest(enemy)
          local weight = info.weight * mod
          tinsert(druid.currentDangerousCasts, {
            source = enemy,
            dest = dest or enemy.castTarget,
            weight = weight
          })
        end
      end
    end
  end
end

function barkskin:threshold(unit, bypass)

  -- modifiers by units on the unit
  local total, _, _, cds = unit.v2attackers()

  -- the hunt flying
  local theHuntWeight = 0
  local huntEvent = events.huntCast
  if huntEvent then
    local event = huntEvent
    local source, dest, happened = event.source, event.dest, event.time
    local time = blink.time
    if time - happened <= 2.25
    and source.exists 
    and source.speed > 45
    and dest.isUnit(unit)
    and source.distanceTo(dest) > 8 then
      theHuntWeight = theHuntWeight + 50
    end
  end

  -- debuffs that mean big dam' be comin'
  local debuffWeights = 0
  local hasDebuffs = unit.debuffFrom(dangerDebuffs)
  if hasDebuffs then 
    for _, id in ipairs(hasDebuffs) do 
      debuffWeights = debuffWeights + dangerDebuffs[id].weight 
    end 
  end

  -- dangerous casts or channels currently happening
  local dangerousCastsWeight = 0
  for _, cast in ipairs(druid.currentDangerousCasts) do 
    if cast.dest.isUnit(unit) then
      dangerousCastsWeight = dangerousCastsWeight + cast.weight
    end
  end

  -- bit 'o weight for them committing a stun to their target
  local stunWeight = unit.stunned and 10 or 0

  local threshold = 28 + debuffWeights / 2 + dangerousCastsWeight

  threshold = threshold + total * (10 + debuffWeights / 2.5 + stunWeight / 2 + dangerousCastsWeight / 2.5)
  threshold = threshold + cds * (17 + debuffWeights + stunWeight + dangerousCastsWeight / 2)

  -- slight multiplicative mod for no heals, mitigation more important
  threshold = threshold * 1 + bin(not healer.exists or healer.ccr > 2) * 0.1

  return threshold

end
  
barkskin:Callback("emergency", function(spell, info)

  if not saved.AutoBarkskin then return end

  -- scan for any dangerous casts
  dangerousCastsScan()


  if player.hp <= barkskin:threshold(player) then
    return spell:Cast() and alert("Barkskin " .. colors.red.."[Danger]", spell.id)
  end

end)

barkskin:Callback("slider", function(spell)
  
  if not saved.AutoBarkskin then return end
  local count, _, _, cds = player.v2attackers()
  
  local threshold = 17
  threshold = threshold + bin(player.stunned) * 5
  threshold = threshold + count * 9
  threshold = threshold + cds * 12

  threshold = threshold * (1 + bin(not healer.exists or healer.cc and healer.ccr > 2.5) * 0.8 + bin(player.stunned) * 0.35)
  threshold = threshold * saved.BarkskinSensitivity

  if player.hpa > threshold then return end
  return spell:Cast() and alert("Barkskin "..colors.red.."[Danger]", spell.id)

end)

druid.barkskin = barkskin

local BlinkFontLarge = blink.createFont(16)
blink.Draw(function(draw)

    local time = blink.time
    local buffer, latency = blink.buffer, blink.latency

    local feral = sr.druid.feral

    -- back arc when target has evasion/parry stuff
    local dodgeFromFront = {37683, 5277, 118038, 199754, 198589, 212800}
    if target.enemy and target.buffFrom(dodgeFromFront) then
      if target.dist < 6 then
        draw:SetWidth(2)
        draw:SetColor(200, 245, 80, 190)
        local x,y,z = target.position()
        local facing = target.rotation
        local size = 1.6
        draw:Arc(x, y, z, size, 180, mod(facing + math.pi, math.pi * 2))
      end
    end
    -- do stun mod calcs for all stuns not just bash
    -- draw immunities we're waiting for above cooresponding spells
    -- draw cd timer above cooresponding spells
    -- lower opacity drawings while waiting for other cds but bash is available

    -- if feral then

    --     if feral.seedDraw then
    --         local d = feral.seedDraw
    --         if time < d.expires then
    --             if d.seed.visible then
    --                 draw:SetColor(100,215,225,200)
    --                 local x,y,z = d.seed.position()
    --                 if x and y and z then
    --                     draw:Circle(x,y,z,2)
    --                 end
    --             end
    --         end
    --     end
        
    --     -- warstomp draw
    --     if player.castID == 20549 then
    --         draw:SetColor(100,215,225,200)
    --         local px, py, pz = player.position()
    --         draw:Circle(px, py, pz, 7.75)

    --         if player.castRemains > buffer + latency and player.castRemains <= max(buffer+latency, 0.3) then
    --             if blink.enemies.around(player, 12, function(obj) 
    --                 return not obj.dead and obj.predictDistanceLiteral(player.castRemains) < 8 
    --             end) == 0 then
    --                 blink.call("SpellStopCasting")
    --                 blink.alert("StopCasting |cFFff978a(War Stomp Missed)", 20549)
    --             end
    --         end
    --     end

        -- local bash = feral.bash
        -- local bash_info = feral.bash_info
        -- local team_kit = bash_info.kit
        -- local bash_target = bash_info.target
        -- if not true and team_kit and bash_target.visible then
            
        --     local stun_mod = 1 - bin(bash_target.race == "Orc") * 0.2
        --     local bash_duration = 4 * stun_mod

        --     local chain = {
        --         dr = {
        --             ["stun"] = 1,
        --             ["incapacitate"] = 1,
        --             ["disorient"] = 1
        --         },
        --         duration = bash_target.ccr,
        --         followup = { }
        --     }

        --     local function valid_followup(kit)
                
        --         if kit.used then return false end

        --         local ccr = 0
        --         local cd = 0
        --         local dr = 0
        --         for _, reason in ipairs(kit.reasons) do
        --             -- spell on cooldown
        --             if reason.r == "CD" then
        --                 cd = reason.t
        --             end
        --             -- bash target on dr
        --             if reason.r == "DR" then
        --                 dr = reason.t
        --             end
        --             -- obj in cc
        --             if reason.r == "CC" then
        --                 ccr = reason.t
        --             end
        --         end

        --         -- just don't do it during cc
        --         if ccr > 2 then return false end

        --         local timer = max(ccr, cd, dr)

        --         if timer <= chain.duration - bin(not kit.isMe) * 0.3 then
        --             return true
        --         end
                
        --     end

        --     -- pick only the longest cc available for dr category for each step of chain & display that 

        --     local player_kit = {
        --         -- bash
        --         { isMe = true, obj = player, spellID = 5211, reasons = {{r = "CD", t = bash.cd - blink.gcdRemains}, {r = "DR", t = bash_target.sdrr}}, duration = bash_duration, category = "stun" }
        --     }

        --     for _, kit in ipairs(player_kit) do
        --         if valid_followup(kit) then
        --             chain.duration = chain.duration + (kit.duration * chain.dr[kit.category])
        --             chain.dr[kit.category] = chain.dr[kit.category] / 2
        --             table.insert(chain.followup, { kit })
        --         end
        --     end

        --     local done = false
        --     while done == false do
        --         done = true
        --         local thisChain = {}

        --         -- { obj = member, reasons = reasons, duration = kit.duration, dest = bash_target, spellID = spellID }
                
        --         -- draw line from member if out of range ?
        --         for _, kit in ipairs(team_kit) do
                    
        --             kit.uid = math.random(1,1000000)
        --             if valid_followup(kit) then
        --                 chain.duration = chain.duration + (kit.duration * chain.dr[kit.category])
        --                 chain.dr[kit.category] = chain.dr[kit.category] / 2
        --                 kit.used = true
        --                 table.insert(thisChain, kit)
        --                 done = false
        --             end
        --             -- if we add to current followup chain, define kit.used to not re-use same kit and set 'done' back to false
        --         end

        --         if #thisChain > 0 then
        --             -- 'clean up' latest chain by choosing longest duration cc of each dr category & removing the rest
        --             -- adjust 'assumed' DR of object after each cc & modify future cc in the chain by it
                    
        --             local byCat = {
        --                 ["stun"] = {},
        --                 ["incapacitate"] = {},
        --                 ["disorient"] = {}
        --             }

        --             for key, kit in ipairs(thisChain) do
        --                 table.insert(byCat[kit.category], kit)
        --             end

        --             local function removeFromChain(given)
        --                 for key, kit in ipairs(thisChain) do
        --                     if given.uid == kit.uid then
        --                         for key2, kit2 in ipairs(team_kit) do
        --                             if kit2.uid == given.uid then
        --                                 team_kit[key2].used = nil
        --                             end
        --                         end
        --                         thisChain[key] = nil
        --                     end
        --                 end
        --             end

        --             for cat, list in ipairs(byCat) do
        --                 if #list > 0 then
        --                     table.sort(list, function(x,y) return x.duration > y.duration end)
        --                     for i=2, #list do
        --                         chain.dr[kit.category] = chain.dr[kit.category] * 2
        --                         chain.duration = chain.duration - (kit.duration * chain.dr[kit.category])
        --                         removeFromChain(list[i])
        --                     end
        --                 end
        --             end 
                    
        --             table.sort(thisChain, function(x,y) return x.duration and y.duration and x.duration * chain.dr[x.category] > y.duration * chain.dr[y.category] end)
        --             table.insert(chain.followup, thisChain)
        --         end

        --     end
            
        --     _G["chain"] = chain

        --     local x, y, z = bash_target.position()
        --     local px, py, pz = player.position()
        --     local playerDist = blink.Distance(px, py, pz, x, y, z)
        --     local combatDist = player.distanceTo(x, y, z)
        --     local angle = blink.AnglesBetween(x, y, z, px, py, pz)

        --     -- fix me for using other shit with this shit
        --     local mySpellRange = 0
        --     local outOfRange = mySpellRange > 0 and combatDist > mySpellRange or mySpellRange == 0 and not bash_target.meleeRange
        --     local actualRange = mySpellRange == 0 and 5.95 or mySpellRange+player.combatReach+bash_target.combatReach

        --     local status = combatDist > mySpellRange + 8 and 3
        --                 or combatDist > mySpellRange and 2
        --                 or 1
            
        --     -- line
        --     if outOfRange then
        --         draw:SetWidth(45)
        --         -- line to where we are in range
        --         -- if not player.facing(bash_target) then
        --         --     draw:SetColor(100,215,225,25)
        --         --     draw:Line(x,y,z,blink.PositionBetween(px,py,pz,x,y,z,4))
        --         -- end
        --         draw:SetWidth(3)
        --         -- draw:Arc(x,y,z,actualRange,90,blink.AnglesBetween(x,y,z,px,py,pz),true)
        --         draw:SetColor(150,180,230,75)
        --         draw:Circle(x,y,z,actualRange)
        --     else
        --         draw:SetColor(33,245,33,200)
        --         draw:SetWidth(3)
        --         draw:Circle(x,y,z,actualRange)
        --     end

        --     -- arrows
        --     if status >= 1 then
        --         -- green arrow
        --         local arrow_size = 0.7
        --         local arrow_shape = {
        --             {-arrow_size, -arrow_size, 0, 0, 0, 0},
        --             {arrow_size, -arrow_size, 0, 0, 0, 0},
        --         }
        --         draw:SetColor(0, 255, 0, 145)
        --         draw:SetWidth(2)
        --         local greenarrow_dist = min(3.5, playerDist - 3)
        --         draw:Array(arrow_shape, px - greenarrow_dist * math.cos(angle), py - greenarrow_dist * math.sin(angle), pz, nil, nil, math.rad(90) + angle)
        --         -- yellow arrow
        --         if status >= 2 and outOfRange then
        --             local arrow_size = 0.88
        --             local arrow_shape = {
        --                 {-arrow_size, -arrow_size, 0, 0, 0, 0},
        --                 {arrow_size, -arrow_size, 0, 0, 0, 0},
        --             }
        --             draw:SetColor(255, 255, 45, 145)
        --             draw:SetWidth(2)
        --             draw:Array(arrow_shape, px - 3.75 * math.cos(angle), py - 3.75 * math.sin(angle), pz, nil, nil, math.rad(90) + angle)
        --             -- red arrow
        --             if status >= 3 then
        --                 -- red arrow
        --                 local arrow_size = 0.99
        --                 local arrow_shape = {
        --                     {-arrow_size, -arrow_size, 0, 0, 0, 0},
        --                     {arrow_size, -arrow_size, 0, 0, 0, 0},
        --                 }
        --                 draw:SetColor(255, 0, 0, 145)
        --                 draw:SetWidth(2)
        --                 draw:Array(arrow_shape, px - 4 * math.cos(angle), py - 4 * math.sin(angle), pz, nil, nil, math.rad(90) + angle)
        --             end
        --         end
        --     end
            
        --     local plan = chain.followup

        --     if #plan > 1 then
        --         local cum = 0 - #plan
        --         local GoText = ""
        --         for step, followup in ipairs(plan) do
        --             local lastStep = step == #plan
        --             for key, kit in ipairs(followup) do
        --                 local lastKit = key == #followup

        --                 draw:SetColor(245,150,255,255)
        --                 GoText = GoText .. blink.textureEscape(kit.spellID, 22 + bin(step == 1) * 12)
        --                 if not lastKit then
        --                     GoText = GoText .. "/"
        --                 end
        --                 -- local texture = {
        --                 --     texture = GetSpellTexture(kit.spellID),
        --                 --     width = 42 - bin(step ~= 1) * 12, height = 42 - bin(step ~= 1) * 12,
        --                 --     alpha = 1,
        --                 -- }
        --                 -- local texture_dist = playerDist < actualRange and 0 or min(6, playerDist-2)
        --                 -- texture_dist = texture_dist
        --                 -- local tx,ty,tz = px,py,pz
        --                 -- if not newAngle then
        --                 --     newAngle = "one"
        --                 -- elseif newAngle == "one" then
        --                 --     fx = fx - 1.5 * math.cos(angle + math.pi / 2)
        --                 --     fy = fy - 1.5 * math.sin(angle + math.pi / 2)
        --                 --     newAngle = "two"
        --                 -- elseif newAngle == "two" then
        --                 --     fx = fx + 1.5 * math.cos(angle + math.pi / 2)
        --                 --     fy = fy + 1.5 * math.sin(angle + math.pi / 2)
        --                 -- end
        --                 -- draw:Texture(texture,fx,fy,fz)
        --                 -- cum = cum + 5
        --                 -- local range = select(6, GetSpellInfo(kit.spellID))
        --                 -- local red_range = range + 8
        --                 -- local reasons = kit.reasons
        --                 -- local dist = kit.obj.distanceTo(bash_target)
        --                 -- local out_of_range = dist > range


        --                 -- str = str .. GetSpellInfo(kit.spellID) .. (key == #followup and " THEN " or " OR ")
        --             end
        --             if not lastStep then
        --                 GoText = GoText .. " > "
        --             end
        --         end
                
        --         local texture_dist = playerDist < actualRange and 0 or min(6, playerDist-2)
        --         local tx,ty,tz = px,py,pz
        --         if playerDist < actualRange then 
        --             -- angle = bash_target.rotation
        --             -- tx,ty,tz = x, y, z - 3
        --         end
        --         local fx, fy, fz = tx - texture_dist * math.cos(angle), py - texture_dist * math.sin(angle),pz+0.25+bin(step == 1)*2

        --         draw:Text(GoText, BlinkFontLarge, fx, fy, fz + 1)   

        --     end

        -- end
    --end
end)


local healthstones = blink.Item(5512)

local checked_for_hs = 0
function healthstones:grab()
  -- don't need to be checking super frequently
  if blink.time - checked_for_hs < 1 + bin(not blink.arena) * 6 then return end
  -- must not already have hs
  if self.count > 0 then return end
  -- don't grab while casting / channeling
  if player.casting or player.channeling then return end

  blink.objects.loop(function(obj)
    if obj.name ~= "Soulwell" then return end
    if obj.creator.enemy then return end
    if obj.dist > 5 then return end
    -- must have free bag slots, alert user if we don't
    if blink.GetNumFreeBagSlots() == 0 then return blink.alert("Can't grab healthstone! Bags are full.") end
    if not Unlocker.type then
      InteractUnit(obj.pointer)
      return blink.alert("Grabbing Healthstone", self.spell)
    --FIXME: error on daemonic!
    elseif Unlocker.type == "daemonic" then
      -- InteractUnit(obj.pointer)
      -- blink.alert("Grabbing Healthstone", self.spell)
      return
    end
  end)

  checked_for_hs = blink.time
end

function healthstones:auto()
  if not IsUsableItem(5512) then return end
  if self.count == 0 then return end
  if self.cd > 0 then return end
  if player.hp > 80 then return end

  local threshold = 25
  threshold = threshold - bin(player.immuneMagicDamage) * 10
  threshold = threshold - bin(player.immunePhysicalDamage) * 10
  threshold = threshold + bin(not healer.exists or healer.cc) * 25

  if player.hp < threshold and self:Use() then
    blink.alert("Healthstone "..colors.red.."[low hp]", self.spell)
  end
end

druid.healthstones = healthstones