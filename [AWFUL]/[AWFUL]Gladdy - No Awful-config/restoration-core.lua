local Unlocker, awful, project = ...
if awful.player.class2 ~= "SHAMAN" then return end
if GetSpecialization() ~= 3 then return end

project.shaman = {}
project.shaman.restoration = awful.Actor:New({ spec = 3, class = "shaman" })