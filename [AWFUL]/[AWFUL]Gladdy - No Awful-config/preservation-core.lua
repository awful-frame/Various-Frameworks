local Unlocker, awful, project = ...
if awful.player.class ~= "Evoker" then return end
if awful.player.spec ~= "Preservation" then return end


project.evoker = {}
project.evoker.preservation = awful.Actor:New({ spec = 2, class = "evoker" })