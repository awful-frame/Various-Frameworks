local Unlocker, awful, project = ...
if awful.player.class ~= "Evoker" then return end
if awful.player.spec ~= "Preservation" then return end
local preservation = project.evoker.preservation
local settings = project.settings
local player = awful.player
local target = awful.target

  
project.medallion = awful.NewItem(218424)
project.medallion2 = awful.NewItem(216281)
project.healthStones = awful.NewItem(5512)
awful.SpellQueueWindow_Update = 6969696969696969

project.SQW = tonumber(GetCVar("SpellQueueWindow"))
local TargetSQW = (select(3, GetNetStats())*2)+15
if project.SQW ~= TargetSQW then
SetCVar("SpellQueueWindow", TargetSQW)
end

awful.print("Gladdy Evoker Loaded")

local tickRate
if settings.mode == "arm" then
    tickRate = 0.01
elseif settings.mode == "bgm" then
    tickRate = 0.2
else
    tickRate = 0.1  -- or some default value
end


preservation:Init(function()
if player.mounted then return end
  if awful.prep then
  blessingOfTheBronze()
  project.stasisState = 0
  project.stasisInitialSequence = false
  end
  if awful.prep then return end
  if player.buff("Refreshment") or player.buff("Food") then return end
  if player.buff("Drink") then return end
  if project.isInValidInstance() then
    local holdGCD1 = sleepWalk("chainHealer")
    local holdGCD2 = wingBuffet("kick")
    local holdGCD3 = tailSwipe("kick")
    project.Lowest()
    nullifyingShroud()
    stasis("cast")
    if project.stasisInitialSequence then
      verdantEmbrace("stasis")
      echo("stasis")
      dreamBreath("stasis")
    end
    stasisRelease()
    azureStrike("combat")
    dreamBreath("low")
    spiritBloom("low")
    timeStop()
    timeStopCancel()
    timeDilation()
    emeraldCommunion()
    rewind()
    verdantEmbrace()
    rescue()
    fireBreath("offensive")
    livingFlame("proc")
    echo()
    reversion()
    dreamBreath()
    dreamBreath("buff")
    spiritBloom()
    fireBreath()
    fireBreath("kill")
    rescue("kill")
    dreamProjection()
    renewingBlaze()
    obsidianScales()
    chronoLoop()
    quell("CC")
    quell("Heal")
    quell("Dam")
    wingBuffet("kick")
    if holdGCD2 then return end
    tailSwipe("kick")
    if holdGCD3 then return end
    wingBuffet("knock")
    naturalize()
    cauterizingFlame()
    livingFlame("friend")
    sleepWalk("enemyHealer")
    sleepWalk("dps")
    sleepWalk("chainHealer")
    if holdGCD1 then return end
    disintegrate("kill")
    disintegrate("dam")
    disintegrate("mana")
    disintegrate("slow")
    landSlide("healer")
    deepBreath("healer")
    deepBreath("multi")
    unravel()
    tailSwipe()
    wingBuffet()
    hover()
    livingFlame("enemy")
    spatialParadox()
    furyOfTheAspects()
    project.collectHealthstone()
    project.useMedallion()
    project.stompTotems()
    project.WasCastingCheck()
    end
end, tickRate)
