local Unlocker, awful, gifted = ...
awful.Devmode = true
awful.AntiAFK.enabled = true 

local hunter, bm = gifted.hunter, gifted.hunter.bm
local player, target, focus, healer, enemyHealer, arena1, arena2, arena3 = awful.player, awful.target, awful.focus, awful.healer, awful.enemyHealer, awful.arena1, awful.arena2, awful.arena3
local enemy = awful.enemy
local enemies = awful.enemies
local gcd, buffer, latency, tickRate, gcdRemains = awful.gcd, awful.buffer, awful.latency, awful.tickRate, awful.gcdRemains
local pet = awful.pet
local min, max, bin, cos, sin = awful.min, awful.max, awful.bin, math.cos, math.sin
local angles, acb, gdist, between = awful.AnglesBetween, awful.AddSlashAwfulCallback, awful.Distance, awful.PositionBetween
local events, colors, colored, escape = awful.events, awful.colors, awful.colored, awful.textureEscape
local succs = {127797, 307871, 355591, 355619 , 23284, 376080}
local CopyToClipboard = awful.unlock("CopyToClipboard")
local onUpdate, onEvent, hookCallbacks, hookCasts, Spell, Item = awful.addUpdateCallback, awful.addEventCallback, awful.hookSpellCallbacks, awful.hookSpellCasts, awful.NewSpell, awful.NewItem
local delay = awful.delay(0.3, 0.5)
local quickdelay = awful.delay(0.2, 0.4)
local randomd = math.random(0.4, 1)
local randomValue = math.random(-3, 3)
local dispelDelay = awful.delay(0.3, 0.6)
local NS = awful.NewSpell
local unitIDs = {  [179867] = {r = 69, g = 126, b = 151, a = 75, radius = 8}, -- static field totem
}
local party1, party2, party3 = awful.party1, awful.party2, awful.party3
local SpellStopCasting = awful.unlock("SpellStopCasting")
local settings, state = gifted.settings, gifted.arenaState

if awful.player.class2 ~= "HUNTER" then return end

-- hunters mark --

local mark = NS(257284, {effect = "magic", targeted = true})

local stealthClasses = {
  ["ROGUE"] = true,
  ["HUNTER"] = true,
  ["DRUID"] = true,
}
mark:Callback("stealthunits", function(spell)
  
  local marked_unit
  local stealthies = {}
  for _, enemy in ipairs(enemies) do
    local class = enemy.class2
    if class and stealthClasses[class] then
      stealthies[#stealthies + 1] = enemy
      if enemy.debuffRemains(spell.id, "player") >= 6 then
        marked_unit = enemy
      end
    end
  end

  for _, enemy in ipairs(stealthies) do
    if not marked_unit then-- or enemy.stealth then -- some restealths can cause it to hang?
      return spell:Cast(enemy) and awful.alert("Hunter's Mark " .. (enemy.classString or ""), spell.id)
    end
  end

end)

hunter.mark = mark