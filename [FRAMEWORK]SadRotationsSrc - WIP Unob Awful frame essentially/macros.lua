local Unlocker, blink = ...
local strsub, strmatch, strfind, strlen, strupper = strsub, strmatch, strfind, strlen, strupper

-- local editbox = CreateFrame("Editbox", "MacroEditBox")
-- editbox:RegisterEvent("EXECUTE_CHAT_LINE")
-- editbox:SetScript("OnEvent", function(self, event, text)
--   if event ~= "EXECUTE_CHAT_LINE" then return end
--   if text == "" then return end

--   if strsub(text, 1, 1) ~= "/" then return end

--   -- If the string is in the format "/cmd blah", command will be "/cmd"
--   local command = strmatch(text, "^(/[^%s]+)") or ""
--   local msg = ""

--   if ( command ~= text ) then
--     msg = strsub(text, strlen(command) + 2)
--     msg = strmatch(msg, "^%s*(.*)$") or msg
--   end

--   command = strupper(command)

--   if command == "/CAST" then
--     blink.manualCastHandler(strtrim(msg), true)
--   end
-- end)

-- editbox:Hide()