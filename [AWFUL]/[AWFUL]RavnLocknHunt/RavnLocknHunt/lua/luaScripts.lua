local Unlocker, awful, ravn = ...
local ____lualib = ravn["lualib_bundle"]
local ____exports = {}

local luaScripts = {}

function luaScripts:InitJSON()
    if ravnJSON then return end;
    local JSON = { _version = "0.1.2" }

    -------------------------------------------------------------------------------
    -- Encode
    -------------------------------------------------------------------------------

    local encode

    local escape_char_map = {
        ["\\"] = "\\",
        ["\""] = "\"",
        ["\b"] = "b",
        ["\f"] = "f",
        ["\n"] = "n",
        ["\r"] = "r",
        ["\t"] = "t",
    }

    local escape_char_map_inv = { ["/"] = "/" }
    for k, v in pairs(escape_char_map) do
        escape_char_map_inv[v] = k
    end


    local function escape_char(c)
        return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
    end


    local function encode_nil(val)
        return "null"
    end


    local function encode_table(val, stack)
        local res = {}
        stack = stack or {}

        -- Circular reference?
        if stack[val] then error("circular reference") end

        stack[val] = true

        if rawget(val, 1) ~= nil or next(val) == nil then
            -- Treat as array -- check keys are valid and it is not sparse
            local n = 0
            for k in pairs(val) do
                if type(k) ~= "number" then
                    error("invalid table: mixed or invalid key types")
                end
                n = n + 1
            end
            if n ~= #val then
                error("invalid table: sparse array")
            end
            -- Encode
            for i, v in ipairs(val) do
                table.insert(res, encode(v, stack))
            end
            stack[val] = nil
            return "[" .. table.concat(res, ",") .. "]"
        else
            -- Treat as an object
            for k, v in pairs(val) do
                if type(k) ~= "string" then
                    error("invalid table: mixed or invalid key types")
                end
                table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
            end
            stack[val] = nil
            return "{" .. table.concat(res, ",") .. "}"
        end
    end


    local function encode_string(val)
        return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
    end


    local function encode_number(val)
        -- Check for NaN, -inf and inf
        if val ~= val or val <= -math.huge or val >= math.huge then
            error("unexpected number value '" .. tostring(val) .. "'")
        end
        return string.format("%.14g", val)
    end


    local type_func_map = {
        ["nil"] = encode_nil,
        ["table"] = encode_table,
        ["string"] = encode_string,
        ["number"] = encode_number,
        ["boolean"] = tostring,
    }


    encode = function(val, stack)
        local t = type(val)
        local f = type_func_map[t]
        if f then
            return f(val, stack)
        end
        error("unexpected type '" .. t .. "'")
    end


    function JSON.stringify(self, val)
        return (encode(val))
    end

    -------------------------------------------------------------------------------
    -- Decode
    -------------------------------------------------------------------------------

    local parse

    local function create_set(...)
        local res = {}
        for i = 1, select("#", ...) do
            res[select(i, ...)] = true
        end
        return res
    end

    local space_chars  = create_set(" ", "\t", "\r", "\n")
    local delim_chars  = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
    local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
    local literals     = create_set("true", "false", "null")

    local literal_map  = {
        ["true"] = true,
        ["false"] = false,
        ["null"] = nil,
    }


    local function next_char(str, idx, set, negate)
        for i = idx, #str do
            if set[str:sub(i, i)] ~= negate then
                return i
            end
        end
        return #str + 1
    end


    local function decode_error(str, idx, msg)
        local line_count = 1
        local col_count = 1
        for i = 1, idx - 1 do
            col_count = col_count + 1
            if str:sub(i, i) == "\n" then
                line_count = line_count + 1
                col_count = 1
            end
        end
        error(string.format("%s at line %d col %d", msg, line_count, col_count))
    end


    local function codepoint_to_utf8(n)
        -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
        local f = math.floor
        if n <= 0x7f then
            return string.char(n)
        elseif n <= 0x7ff then
            return string.char(f(n / 64) + 192, n % 64 + 128)
        elseif n <= 0xffff then
            return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
        elseif n <= 0x10ffff then
            return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                f(n % 4096 / 64) + 128, n % 64 + 128)
        end
        error(string.format("invalid unicode codepoint '%x'", n))
    end


    local function parse_unicode_escape(s)
        local n1 = tonumber(s:sub(1, 4), 16)
        local n2 = tonumber(s:sub(7, 10), 16)
        -- Surrogate pair?
        if n2 then
            return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
        else
            return codepoint_to_utf8(n1)
        end
    end


    local function parse_string(str, i)
        local res = ""
        local j = i + 1
        local k = j

        while j <= #str do
            local x = str:byte(j)

            if x < 32 then
                decode_error(str, j, "control character in string")
            elseif x == 92 then -- `\`: Escape
                res = res .. str:sub(k, j - 1)
                j = j + 1
                local c = str:sub(j, j)
                if c == "u" then
                    local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                        or str:match("^%x%x%x%x", j + 1)
                        or decode_error(str, j - 1, "invalid unicode escape in string")
                    res = res .. parse_unicode_escape(hex)
                    j = j + #hex
                else
                    if not escape_chars[c] then
                        decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                    end
                    res = res .. escape_char_map_inv[c]
                end
                k = j + 1
            elseif x == 34 then -- `"`: End of string
                res = res .. str:sub(k, j - 1)
                return res, j + 1
            end

            j = j + 1
        end

        decode_error(str, i, "expected closing quote for string")
    end


    local function parse_number(str, i)
        local x = next_char(str, i, delim_chars)
        local s = str:sub(i, x - 1)
        local n = tonumber(s)
        if not n then
            decode_error(str, i, "invalid number '" .. s .. "'")
        end
        return n, x
    end


    local function parse_literal(str, i)
        local x = next_char(str, i, delim_chars)
        local word = str:sub(i, x - 1)
        if not literals[word] then
            decode_error(str, i, "invalid literal '" .. word .. "'")
        end
        return literal_map[word], x
    end


    local function parse_array(str, i)
        local res = {}
        local n = 1
        i = i + 1
        while 1 do
            local x
            i = next_char(str, i, space_chars, true)
            -- Empty / end of array?
            if str:sub(i, i) == "]" then
                i = i + 1
                break
            end
            -- Read token
            x, i = parse(str, i)
            res[n] = x
            n = n + 1
            -- Next token
            i = next_char(str, i, space_chars, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "]" then break end
            if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
        end
        return res, i
    end


    local function parse_object(str, i)
        local res = {}
        i = i + 1
        while 1 do
            local key, val
            i = next_char(str, i, space_chars, true)
            -- Empty / end of object?
            if str:sub(i, i) == "}" then
                i = i + 1
                break
            end
            -- Read key
            if str:sub(i, i) ~= '"' then
                decode_error(str, i, "expected string for key")
            end
            key, i = parse(str, i)
            -- Read ':' delimiter
            i = next_char(str, i, space_chars, true)
            if str:sub(i, i) ~= ":" then
                decode_error(str, i, "expected ':' after key")
            end
            i = next_char(str, i + 1, space_chars, true)
            -- Read value
            val, i = parse(str, i)
            -- Set
            res[key] = val
            -- Next token
            i = next_char(str, i, space_chars, true)
            local chr = str:sub(i, i)
            i = i + 1
            if chr == "}" then break end
            if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
        end
        return res, i
    end


    local char_func_map = {
        ['"'] = parse_string,
        ["0"] = parse_number,
        ["1"] = parse_number,
        ["2"] = parse_number,
        ["3"] = parse_number,
        ["4"] = parse_number,
        ["5"] = parse_number,
        ["6"] = parse_number,
        ["7"] = parse_number,
        ["8"] = parse_number,
        ["9"] = parse_number,
        ["-"] = parse_number,
        ["t"] = parse_literal,
        ["f"] = parse_literal,
        ["n"] = parse_literal,
        ["["] = parse_array,
        ["{"] = parse_object,
    }


    parse = function(str, idx)
        local chr = str:sub(idx, idx)
        local f = char_func_map[chr]
        if f then
            return f(str, idx)
        end
        decode_error(str, idx, "unexpected character '" .. chr .. "'")
    end


    function JSON.parse(self, str)
        if type(str) ~= "string" then
            error("expected argument of type string, got " .. type(str))
        end
        local res, idx = parse(str, next_char(str, 1, space_chars, true))
        idx = next_char(str, idx, space_chars, true)
        if idx <= #str then
            decode_error(str, idx, "trailing garbage")
        end
        return res
    end

    _G['ravnJSON'] = JSON
end

function luaScripts:InitRavnStub()
    local RAVNSTUB_MAJOR, RAVNSTUB_MINOR = "RavnStub",
        2                                                -- NEVER MAKE THIS AN SVN REVISION! IT NEEDS TO BE USABLE IN ALL REPOS!
    local RavnStub = _G[RAVNSTUB_MAJOR]

    if not RavnStub or RavnStub.minor < RAVNSTUB_MINOR then
        RavnStub = RavnStub or { libs = {}, minors = {} }
        _G[RAVNSTUB_MAJOR] = RavnStub
        RavnStub.minor = RAVNSTUB_MINOR

        function RavnStub:NewLibrary(major, minor)
            assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
            minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")

            local oldminor = self.minors[major]
            if oldminor and oldminor >= minor then return nil end
            self.minors[major], self.libs[major] = minor, self.libs[major] or {}
            return self.libs[major], oldminor
        end

        function RavnStub:GetLibrary(major, silent)
            if not self.libs[major] and not silent then
                error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
            end
            return self.libs[major], self.minors[major]
        end

        function RavnStub:IterateLibraries() return pairs(self.libs) end

        setmetatable(RavnStub, { __call = RavnStub.GetLibrary })
    end
end

function luaScripts:InitMenuFramework()
    local MAJOR, MINOR = 'StdUi', 5;

    --- @class StdUi
    local StdUi = RavnStub:NewLibrary(MAJOR, MINOR);

    if not StdUi then
        return
    end
    local TableInsert = tinsert;

    StdUi.moduleVersions = {};
    if not StdUiInstances then
        StdUiInstances = { StdUi };
    else
        TableInsert(StdUiInstances, StdUi);
    end

    function StdUi:NewInstance()
        local instance = CopyTable(self);
        instance:ResetConfig();
        TableInsert(StdUiInstances, instance);
        return instance;
    end

    function StdUi:RegisterModule(module, version)
        self.moduleVersions[module] = version;
    end

    function StdUi:UpgradeNeeded(module, version)
        if not self.moduleVersions[module] then
            return true;
        end

        return self.moduleVersions[module] < version;
    end

    function StdUi:RegisterWidget(name, func)
        if not self[name] then
            self[name] = func;
            return true;
        end

        return false;
    end

    function StdUi:InitWidget(widget)
        widget.isWidget = true;

        function widget:GetChildrenWidgets()
            local children = { widget:GetChildren() };
            local result = {};
            for i = 1, #children do
                local child = children[i];
                if child.isWidget then
                    TableInsert(result, child);
                end
            end

            return result;
        end
    end

    function StdUi:SetObjSize(obj, width, height)
        if width then
            obj:SetWidth(width);
        end

        if height then
            obj:SetHeight(height);
        end
    end

    function StdUi:SetTextColor(fontString, colorType)
        colorType = colorType or 'normal';
        if fontString.SetTextColor then
            local c = self.config.font.color[colorType];
            fontString:SetTextColor(c.r, c.g, c.b, c.a);
        end
    end

    StdUi.SetHighlightBorder = function(self)
        if self.target then
            self = self.target;
        end

        if self.isDisabled then
            return
        end

        local hc = self.stdUi.config.highlight.color;
        if not self.origBackdropBorderColor then
            self.origBackdropBorderColor = { self:GetBackdropBorderColor() };
        end
        self:SetBackdropBorderColor(hc.r, hc.g, hc.b, 1);
    end

    StdUi.ResetHighlightBorder = function(self)
        if self.target then
            self = self.target;
        end

        if self.isDisabled then
            return
        end

        local hc = self.origBackdropBorderColor;
        if hc then
            self:SetBackdropBorderColor(unpack(hc));
        end
    end

    function StdUi:HookHoverBorder(object)
        if not object.SetBackdrop then
            Mixin(object, BackdropTemplateMixin)
        end
        object:HookScript('OnEnter', self.SetHighlightBorder);
        object:HookScript('OnLeave', self.ResetHighlightBorder);
    end

    function StdUi:ApplyBackdrop(frame, type, border, insets)
        local config = frame.config or self.config;
        local backdrop = {
            bgFile   = config.backdrop.texture,
            edgeFile = config.backdrop.texture,
            edgeSize = 1,
        };
        if insets then
            backdrop.insets = insets;
        end
        if not frame.SetBackdrop then
            Mixin(frame, BackdropTemplateMixin)
        end
        frame:SetBackdrop(backdrop);

        type = type or 'button';
        border = border or 'border';

        if config.backdrop[type] then
            frame:SetBackdropColor(
                config.backdrop[type].r,
                config.backdrop[type].g,
                config.backdrop[type].b,
                config.backdrop[type].a
            );
        end

        if config.backdrop[border] then
            frame:SetBackdropBorderColor(
                config.backdrop[border].r,
                config.backdrop[border].g,
                config.backdrop[border].b,
                config.backdrop[border].a
            );
        end
    end

    function StdUi:ClearBackdrop(frame)
        if not frame.SetBackdrop then
            Mixin(frame, BackdropTemplateMixin)
        end
        frame:SetBackdrop(nil);
    end

    function StdUi:ApplyDisabledBackdrop(frame, enabled)
        if frame.target then
            frame = frame.target;
        end

        if enabled then
            self:ApplyBackdrop(frame, 'button', 'border');
            self:SetTextColor(frame, 'normal');
            if frame.label then
                self:SetTextColor(frame.label, 'normal');
            end

            if frame.text then
                self:SetTextColor(frame.text, 'normal');
            end
            frame.isDisabled = false;
        else
            self:ApplyBackdrop(frame, 'buttonDisabled', 'borderDisabled');
            self:SetTextColor(frame, 'disabled');
            if frame.label then
                self:SetTextColor(frame.label, 'disabled');
            end

            if frame.text then
                self:SetTextColor(frame.text, 'disabled');
            end
            frame.isDisabled = true;
        end
    end

    function StdUi:HookDisabledBackdrop(frame)
        local this = self;
        hooksecurefunc(frame, 'Disable', function(self)
            this:ApplyDisabledBackdrop(self, false);
        end);

        hooksecurefunc(frame, 'Enable', function(self)
            this:ApplyDisabledBackdrop(self, true);
        end);
    end

    function StdUi:StripTextures(frame)
        for i = 1, frame:GetNumRegions() do
            local region = select(i, frame:GetRegions());

            if region and region:GetObjectType() == 'Texture' then
                region:SetTexture(nil);
            end
        end
    end

    function StdUi:MakeDraggable(frame, handle)
        frame:SetMovable(true);
        frame:EnableMouse(true);
        frame:RegisterForDrag('LeftButton');
        frame:SetScript('OnDragStart', frame.StartMoving);
        frame:SetScript('OnDragStop', frame.StopMovingOrSizing);

        if handle then
            handle:EnableMouse(true);
            handle:SetMovable(true);
            handle:RegisterForDrag('LeftButton');

            handle:SetScript('OnDragStart', function(self)
                frame.StartMoving(frame);
            end);

            handle:SetScript('OnDragStop', function(self)
                frame.StopMovingOrSizing(frame);
            end);
        end
    end

    -- Make a frame resizable
    function StdUi:MakeResizable(frame, direction)
        -- Possible resize directions and handle rotation values
        local anchorDirections = {
            ["TOP"] = 0,
            ["TOPRIGHT"] = 1.5708,
            ["RIGHT"] = 0,
            ["BOTTOMRIGHT"] = 0,
            ["BOTTOM"] = 0,
            ["BOTTOMLEFT"] = -1.5708,
            ["LEFT"] = 0,
            ["TOPLEFT"] = 3.1416,
        }

        direction = string.upper(direction);

        -- Return if invalid direction
        if not anchorDirections[direction] then return false end

        frame:SetResizable(true);

        -- Create the resize anchor
        local anchor = CreateFrame("Button", nil, frame);
        anchor:SetPoint(direction, frame, direction);

        -- Attach side anchor to adjacent sides of frame
        if direction == "TOP" or direction == "BOTTOM" then
            anchor:SetHeight(self.config.resizeHandle.height);
            anchor:SetPoint("LEFT", frame, "LEFT", self.config.resizeHandle.width, 0);
            anchor:SetPoint("RIGHT", frame, "RIGHT", self.config.resizeHandle.width * -1, 0);
        elseif direction == "LEFT" or direction == "RIGHT" then
            anchor:SetWidth(self.config.resizeHandle.width);
            anchor:SetPoint("TOP", frame, "TOP", 0, self.config.resizeHandle.height * -1);
            anchor:SetPoint("BOTTOM", frame, "BOTTOM", 0, self.config.resizeHandle.height);
        else
            -- Set the corner anchor textures
            anchor:SetNormalTexture(self.config.resizeHandle.texture.normal);
            if (self.config.resizeHandle.texture.highlight == nil) then
                anchor:SetHighlightTexture('');
            else
                anchor:SetHighlightTexture(self.config.resizeHandle.texture.highlight);
            end
            anchor:SetPushedTexture(self.config.resizeHandle.texture.pushed);

            -- Set size and rotate corner anchor
            anchor:SetSize(self.config.resizeHandle.width, self.config.resizeHandle.height);
            anchor:GetNormalTexture():SetRotation(anchorDirections[direction]);
            anchor:GetHighlightTexture():SetRotation(anchorDirections[direction]);
            anchor:GetPushedTexture():SetRotation(anchorDirections[direction]);
        end

        -- Resize anchor click handlers
        anchor:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                frame:StartSizing(direction);
                frame:SetUserPlaced(true);
            end
        end)
        anchor:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                frame:StopMovingOrSizing();
            end
        end)
    end

    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Builder', 6;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local util = StdUi.Util;

    local function setDatabaseValue(db, key, value)
        if key:find('.') then
            local accessor = StdUi.Util.stringSplit('.', key);
            local startPos = db;

            for i, subKey in pairs(accessor) do
                if i == #accessor then
                    startPos[subKey] = value;
                    return
                end

                startPos = startPos[subKey];
            end
        else
            db[key] = value;
        end
    end

    local function getDatabaseValue(db, key)
        if key:find('.') then
            local accessor = StdUi.Util.stringSplit('.', key);
            local startPos = db;

            for i, subKey in pairs(accessor) do
                if i == #accessor then
                    return startPos[subKey];
                end

                startPos = startPos[subKey];
            end
        else
            return db[key];
        end
    end

    ---BuildElement
    ---@param frame Frame
    ---@param row EasyLayoutRow
    ---@param info table
    ---@param dataKey string
    ---@param db table
    function StdUi:BuildElement(frame, row, info, dataKey, db)
        local element;

        local genericChangeEvent = function(el, value)
            setDatabaseValue(el.dbReference, el.dataKey, value);
            if el.onChange then
                el:onChange(value);
            end
        end

        local hasLabel = false;
        if info.type == 'checkbox' then
            element = self:Checkbox(frame, info.label);
        elseif info.type == 'editBox' then
            element = self:EditBox(frame, nil, 20);
        elseif info.type == 'multiLineBox' then
            element = self:MultiLineBox(frame, 300, 20);
        elseif info.type == 'dropdown' then
            element = self:Dropdown(frame, 300, 20, info.options or {}, nil, info.multi or nil, info.assoc or false);
        elseif info.type == 'autocomplete' then
            element = self:Autocomplete(frame, 300, 20, '');

            if info.validator then
                element.validator = info.validator;
            end
            if info.transformer then
                element.transformer = info.transformer;
            end
            if info.buttonCreate then
                element.buttonCreate = info.buttonCreate;
            end
            if info.buttonUpdate then
                element.buttonUpdate = info.buttonUpdate;
            end
            if info.items then
                element:SetItems(info.items);
            end
        elseif info.type == 'slider' or info.type == 'sliderWithBox' then
            element = self:SliderWithBox(frame, nil, 32, 0, info.min or 0, info.max or 2);

            if info.precision then
                element:SetPrecision(info.precision);
            end
        elseif info.type == 'color' then
            element = self:ColorInput(frame, info.label, 100, 20, info.color);
        elseif info.type == 'button' then
            element = self:Button(frame, nil, 20, info.text or '');

            if info.onClick then
                element:SetScript('OnClick', info.onClick);
            end
        elseif info.type == 'header' then
            element = self:Header(frame, info.label);
        elseif info.type == 'label' then
            element = self:Label(frame, info.label);
        elseif info.type == 'texture' then
            element = self:Texture(frame, info.width or 24, info.height or 24, info.texture);
        elseif info.type == 'panel' then -- Containers
            element = self:Panel(frame, 300, 20);
        elseif info.type == 'scroll' then
            element = self:ScrollFrame(
                frame,
                300,
                20,
                type(info.scrollChild) == 'table' and info.scrollChild or nil
            );
            if type(info.scrollChild) == 'function' then
                info.scrollChild(element);
            end
        elseif info.type == 'fauxScroll' then
            element = self:FauxScrollFrame(
                frame,
                300,
                20,
                info.displayCount or 5,
                info.lineHeight or 22,
                type(info.scrollChild) == 'table' and info.scrollChild or nil
            );
            if type(info.scrollChild) == 'function' then
                info.scrollChild(element);
            end
        elseif info.type == 'tab' then
            element = self:TabPanel(
                frame,
                300,
                20,
                info.tabs or {},
                info.vertical or false,
                info.buttonWidth,
                info.buttonHeight
            );
        elseif info.type == 'custom' then
            element = info.createFunction(frame, row, info, dataKey, db);
        end

        if not element then
            print('Could not build element with type: ', info.type);
        end

        -- Widgets can have initialization code
        if info.init then
            info.init(element);
        end

        element.dbReference = db;
        element.dataKey = dataKey;
        if info.onChange then
            element.onChange = info.onChange;
        end

        if element.hasLabel then
            hasLabel = true;
        end

        local canHaveLabel = info.type ~= 'checkbox' and
            info.type ~= 'header' and
            info.type ~= 'label' and
            info.type ~= 'color';

        if info.label and canHaveLabel then
            self:AddLabel(frame, element, info.label);
            hasLabel = true;
        end

        if info.initialValue then
            if element.SetChecked then
                element:SetChecked(info.initialValue);
            elseif element.SetColor then
                element:SetColor(info.initialValue);
            elseif element.SetValue then
                element:SetValue(info.initialValue);
            end
        end

        -- Setting onValueChanged disqualifies from any writes to database
        if info.onValueChanged then
            element.OnValueChanged = info.onValueChanged;
        elseif db then
            local iVal = getDatabaseValue(db, dataKey);

            if info.type == 'checkbox' then
                element:SetChecked(iVal)
            elseif element.SetColor then
                element:SetColor(iVal);
            elseif element.SetValue then
                element:SetValue(iVal);
            end

            element.OnValueChanged = genericChangeEvent;
        end

        -- Technically, every frame can be a container
        if info.children then
            self:BuildWindow(element, info.children);
            self:EasyLayout(element, { padding = { top = 10 } });

            element:SetScript('OnShow', function(of)
                of:DoLayout();
            end);
        end

        row:AddElement(element, {
            column = info.column or 12,
            fullSize = info.fullSize or false,
            fullHeight = info.fullHeight or false,
            margin = info.layoutMargins or {
                top = (hasLabel and 20 or 0)
            }
        });

        return element;
    end

    ---BuildRow
    ---@param frame Frame
    ---@param info table
    ---@param db table
    function StdUi:BuildRow(frame, info, db)
        local row = frame:AddRow();

        for key, element in util.orderedPairs(info) do
            local dataKey = element.key or key or nil;

            local el = self:BuildElement(frame, row, element, dataKey, db);
            if element then
                if not frame.elements then
                    frame.elements = {};
                end

                frame.elements[key] = el;
            end
        end
    end

    ---BuildWindow
    ---@param frame Frame
    ---@param info table
    function StdUi:BuildWindow(frame, info)
        local db = info.database or nil;

        assert(info.rows, 'Rows are required in order to build table');
        local rows = info.rows;

        self:EasyLayout(frame, info.layoutConfig);

        for _, row in util.orderedPairs(rows) do
            self:BuildRow(frame, row, db);
        end

        frame:DoLayout();
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Config', 4;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local IsAddOnLoaded = IsAddOnLoaded;

    StdUi.config = {};

    function StdUi:ResetConfig()
        local font, fontSize = GameFontNormal:GetFont();
        local _, largeFontSize = GameFontNormalLarge:GetFont();

        self.config = {
            font         = {
                family    = font,
                size      = fontSize,
                titleSize = largeFontSize,
                effect    = '',
                strata    = 'OVERLAY',
                color     = {
                    normal   = { r = 1, g = 1, b = 1, a = 1 },
                    disabled = { r = 0.55, g = 0.55, b = 0.55, a = 1 },
                    header   = { r = 1, g = 0.9, b = 0, a = 1 },
                }
            },

            backdrop     = {
                texture        = [[Interface\Buttons\WHITE8X8]],
                panel          = { r = 0.0588, g = 0.0588, b = 0, a = 0.8 },
                slider         = { r = 0.15, g = 0.15, b = 0.15, a = 1 },

                highlight      = { r = 0.40, g = 0.40, b = 0, a = 0.5 },
                button         = { r = 0.20, g = 0.20, b = 0.20, a = 1 },
                buttonDisabled = { r = 0.15, g = 0.15, b = 0.15, a = 1 },

                border         = { r = 0.00, g = 0.00, b = 0.00, a = 1 },
                borderDisabled = { r = 0.40, g = 0.40, b = 0.40, a = 1 }
            },

            progressBar  = {
                color = { r = 1, g = 0.9, b = 0, a = 0.5 },
            },

            highlight    = {
                color = { r = 1, g = 0.9, b = 0, a = 0.4 },
                blank = { r = 0, g = 0, b = 0, a = 0 }
            },

            dialog       = {
                width  = 400,
                height = 100,
                button = {
                    width  = 100,
                    height = 20,
                    margin = 5
                }
            },

            tooltip      = {
                padding = 10
            },

            resizeHandle = {
                width = 10,
                height = 10,
                texture = {
                    normal = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up",
                    highlight = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up",
                    pushed = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down"
                }
            }
        };

        if IsAddOnLoaded('ElvUI') then
            local eb = ElvUI[1].media.backdropfadecolor;
            self.config.backdrop.panel = { r = eb[1], g = eb[2], b = eb[3], a = eb[4] };
        end
    end

    StdUi:ResetConfig();

    function StdUi:SetDefaultFont(font, size, effect, strata)
        self.config.font.family = font;
        self.config.font.size = size;
        self.config.font.effect = effect;
        self.config.font.strata = strata;
    end

    StdUi:RegisterModule(module, version);

    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Grid', 4;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    --- Creates frame list that reuses frames and is based on array data
    --- @param parent Frame
    --- @param create function
    --- @param update function
    --- @param data table
    --- @param padding number
    --- @param oX number
    --- @param oY number
    --- @param limitFn function
    function StdUi:ObjectList(parent, itemsTable, create, update, data, padding, oX, oY, limitFn)
        local this = self;
        oX = oX or 1;
        oY = oY or -1;
        padding = padding or 0;

        if not itemsTable then
            itemsTable = {};
        end

        for i = 1, #itemsTable do
            itemsTable[i]:Hide();
        end

        local totalHeight = -oY;

        local i = 1;
        for key, value in pairs(data) do
            local itemFrame = itemsTable[i];

            if not itemFrame then
                if type(create) == 'string' then
                    -- create a widget and anchor it to
                    itemsTable[i] = this[create](this, parent);
                else
                    itemsTable[i] = create(parent, value, i, key);
                end
                itemFrame = itemsTable[i];
            end

            -- If you create simple widget you need to handle anchoring yourself
            update(parent, itemFrame, value, i, key);
            itemFrame:Show();

            totalHeight = totalHeight + itemFrame:GetHeight();
            if i == 1 then
                -- glue first item to offset
                this:GlueTop(itemFrame, parent, oX, oY, 'LEFT');
            else
                -- glue next items to previous
                this:GlueBelow(itemFrame, itemsTable[i - 1], 0, -padding);
                totalHeight = totalHeight + padding;
            end

            if limitFn and limitFn(i, totalHeight, itemFrame:GetHeight()) then
                break;
            end

            i = i + 1;
        end

        return itemsTable, totalHeight;
    end

    --- Creates frame list that reuses frames and is based on array data
    --- @param parent Frame
    --- @param create function
    --- @param update function
    --- @param data table
    --- @param paddingX number
    --- @param paddingY number
    --- @param oX number
    --- @param oY number
    function StdUi:ObjectGrid(parent, itemsMatrix, create, update, data, paddingX, paddingY, oX, oY)
        oX = oX or 1;
        oY = oY or -1;
        paddingX = paddingX or 0;
        paddingY = paddingY or 0;

        if not itemsMatrix then
            itemsMatrix = {};
        end

        for y = 1, #itemsMatrix do
            for x = 1, #itemsMatrix[y] do
                itemsMatrix[y][x]:Hide();
            end
        end

        for rowI = 1, #data do
            local row = data[rowI];

            for colI = 1, #row do
                if not itemsMatrix[rowI] then
                    -- whole row does not exist yet
                    itemsMatrix[rowI] = {};
                end

                local itemFrame = itemsMatrix[rowI][colI];

                if not itemFrame then
                    if type(create) == 'string' then
                        -- create a widget and set parent it to
                        itemFrame = self[create](self, parent);
                    else
                        itemFrame = create(parent, data[rowI][colI], rowI, colI);
                    end
                    itemsMatrix[rowI][colI] = itemFrame;
                end

                -- If you create simple widget you need to handle anchoring yourself
                update(parent, itemFrame, data[rowI][colI], rowI, colI);
                itemFrame:Show();

                if rowI == 1 and colI == 1 then
                    -- glue first item to offset
                    self:GlueTop(itemFrame, parent, oX, oY, 'LEFT');
                else
                    if colI == 1 then
                        -- glue first item in column to previous row
                        self:GlueBelow(itemFrame, itemsMatrix[rowI - 1][colI], 0, -paddingY, 'LEFT');
                    else
                        -- glue next column to previous column
                        self:GlueRight(itemFrame, itemsMatrix[rowI][colI - 1], paddingX, 0);
                    end
                end
            end
        end
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);

    if not StdUi then
        return
    end

    local module, version = 'Layout', 3;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local TableInsert = tinsert;
    local TableRemove = tremove;
    local pairs = pairs;
    local MathMax = math.max;
    local MathFloor = math.floor;

    local defaultLayoutConfig = {
        gutter  = 10,
        columns = 12,
        padding = {
            top    = 0,
            right  = 10,
            left   = 10,
            bottom = 10,
        }
    };

    local defaultRowConfig = {
        margin = {
            top    = 0,
            right  = 0,
            bottom = 15,
            left   = 0
        }
    };

    local defaultElementConfig = {
        margin = {
            top    = 0,
            right  = 0,
            bottom = 0,
            left   = 0
        }
    };

    local EasyLayoutRow = {
        AddElement      = function(self, frame, config)
            if not frame.layoutConfig then
                frame.layoutConfig = StdUi.Util.tableMerge(defaultElementConfig, config or {});
            elseif config then
                frame.layoutConfig = StdUi.Util.tableMerge(frame.layoutConfig, config or {});
            end

            TableInsert(self.elements, frame);
        end,

        AddElements     = function(self, ...)
            local r = { ... };
            local cfg = TableRemove(r, #r);

            if cfg.column == 'even' then
                cfg.column = MathFloor(self.parent.layout.columns / #r);
            end

            for i = 1, #r do
                self:AddElement(r[i], StdUi.Util.tableMerge(defaultElementConfig, cfg));
            end
        end,

        GetColumnsTaken = function(self)
            local columnsTaken = 0;
            local l = self.parent.layout;

            for i = 1, #self.elements do
                local lc = self.elements[i].layoutConfig;
                local col = lc.column or l.columns;
                columnsTaken = columnsTaken + col;
            end

            return columnsTaken;
        end,

        DrawRow         = function(self, parentWidth, yOffset)
            yOffset = yOffset or 0;
            local l = self.parent.layout;
            local g = l.gutter;

            local rowMargin = self.config.margin;
            local totalHeight = 0;
            local columnsTaken = 0;
            local x = g + l.padding.left + rowMargin.left;

            -- if row has margins, cut down available width
            parentWidth = parentWidth - rowMargin.left - rowMargin.right;

            for i = 1, #self.elements do
                local frame = self.elements[i];

                frame:ClearAllPoints();

                -- Frame layout config
                local lc = frame.layoutConfig;
                local m = lc.margin;

                -- take full size
                if lc.fullSize then
                    StdUi:GlueAcross(
                        frame,
                        self.parent,
                        l.padding.left,
                        -l.padding.top,
                        -l.padding.right,
                        l.padding.bottom
                    );

                    if frame.DoLayout then
                        frame:DoLayout();
                    end

                    totalHeight = MathMax(totalHeight,
                        frame:GetHeight() + m.bottom + m.top + rowMargin.top + rowMargin.bottom);
                    return totalHeight;
                end

                local col = lc.column or l.columns;
                local w = (parentWidth / (l.columns / col)) - 2 * g;

                frame:SetWidth(w);

                if columnsTaken + col > self.parent.layout.columns then
                    print('Element will not fit row capacity: ' .. l.columns);
                    return totalHeight;
                end

                -- move it down by rowMargin and element margin
                frame:SetPoint('TOPLEFT', self.parent, 'TOPLEFT', x, yOffset - m.top - rowMargin.top);

                if lc.fullHeight then
                    frame:SetPoint('BOTTOMLEFT', self.parent, 'BOTTOMLEFT', x, m.bottom + rowMargin.bottom);
                end

                --each element takes 1 gutter plus column * colWidth, while gutter is inclusive
                x = x + w + 2 * g; -- double the gutter because width subtracts gutter

                -- if that frame is container itself, do layout for it too
                if frame.DoLayout then
                    frame:DoLayout();
                end

                totalHeight = MathMax(totalHeight,
                    frame:GetHeight() + m.bottom + m.top + rowMargin.top + rowMargin.bottom);
                columnsTaken = columnsTaken + col;
            end

            return totalHeight;
        end
    }

    ---EasyLayoutRow
    ---@param parent Frame
    ---@param config table
    function StdUi:EasyLayoutRow(parent, config)
        ---@class EasyLayoutRow
        local row = {
            parent   = parent,
            config   = self.Util.tableMerge(defaultRowConfig, config or {}),
            elements = {}
        };

        for k, v in pairs(EasyLayoutRow) do
            row[k] = v;
        end

        return row;
    end

    local EasyLayout = {
        ---@return EasyLayoutRow
        AddRow = function(self, config)
            if not self.rows then
                self.rows = {};
            end

            local row = self.stdUi:EasyLayoutRow(self, config);
            TableInsert(self.rows, row);

            return row;
        end,

        DoLayout = function(self)
            local l = self.layout;
            local width = self:GetWidth() - l.padding.left - l.padding.right;

            local y = -l.padding.top;
            for i = 1, #self.rows do
                local row = self.rows[i];
                y = y - row:DrawRow(width, y);
            end
        end
    };

    function StdUi:EasyLayout(parent, config)
        parent.stdUi = self;
        parent.layout = self.Util.tableMerge(defaultLayoutConfig, config or {});

        for k, v in pairs(EasyLayout) do
            parent[k] = v;
        end
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Position', 2;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    -- Points
    local Center = 'CENTER';

    local Top = 'TOP';
    local Bottom = 'BOTTOM';
    local Left = 'LEFT';
    local Right = 'RIGHT';

    local TopLeft = 'TOPLEFT';
    local TopRight = 'TOPRIGHT';
    local BottomLeft = 'BOTTOMLEFT';
    local BottomRight = 'BOTTOMRIGHT';

    StdUi.Anchors = {
        Center = Center,

        Top = Top,
        Bottom = Bottom,
        Left = Left,
        Right = Right,

        TopLeft = TopLeft,
        TopRight = TopRight,
        BottomLeft = BottomLeft,
        BottomRight = BottomRight,
    }

    --- Glues object below referenced object
    function StdUi:GlueBelow(object, referencedObject, x, y, align)
        if align == Left then
            object:SetPoint(TopLeft, referencedObject, BottomLeft, x, y);
        elseif align == Right then
            object:SetPoint(TopRight, referencedObject, BottomRight, x, y);
        else
            object:SetPoint(Top, referencedObject, Bottom, x, y);
        end
    end

    --- Glues object above referenced object
    function StdUi:GlueAbove(object, referencedObject, x, y, align)
        if align == Left then
            object:SetPoint(BottomLeft, referencedObject, TopLeft, x, y);
        elseif align == Right then
            object:SetPoint(BottomRight, referencedObject, TopRight, x, y);
        else
            object:SetPoint(Bottom, referencedObject, Top, x, y);
        end
    end

    function StdUi:GlueTop(object, referencedObject, x, y, align)
        if align == Left then
            object:SetPoint(TopLeft, referencedObject, TopLeft, x, y);
        elseif align == Right then
            object:SetPoint(TopRight, referencedObject, TopRight, x, y);
        else
            object:SetPoint(Top, referencedObject, Top, x, y);
        end
    end

    function StdUi:GlueBottom(object, referencedObject, x, y, align)
        if align == Left then
            object:SetPoint(BottomLeft, referencedObject, BottomLeft, x, y);
        elseif align == Right then
            object:SetPoint(BottomRight, referencedObject, BottomRight, x, y);
        else
            object:SetPoint(Bottom, referencedObject, Bottom, x, y);
        end
    end

    function StdUi:GlueRight(object, referencedObject, x, y, inside)
        if inside then
            object:SetPoint(Right, referencedObject, Right, x, y);
        else
            object:SetPoint(Left, referencedObject, Right, x, y);
        end
    end

    function StdUi:GlueLeft(object, referencedObject, x, y, inside)
        if inside then
            object:SetPoint(Left, referencedObject, Left, x, y);
        else
            object:SetPoint(Right, referencedObject, Left, x, y);
        end
    end

    function StdUi:GlueAfter(object, referencedObject, topX, topY, bottomX, bottomY)
        if topX and topY then
            object:SetPoint(TopLeft, referencedObject, TopRight, topX, topY);
        end
        if bottomX and bottomY then
            object:SetPoint(BottomLeft, referencedObject, BottomRight, bottomX, bottomY);
        end
    end

    function StdUi:GlueBefore(object, referencedObject, topX, topY, bottomX, bottomY)
        if topX and topY then
            object:SetPoint(TopRight, referencedObject, TopLeft, topX, topY);
        end
        if bottomX and bottomY then
            object:SetPoint(BottomRight, referencedObject, BottomLeft, bottomX, bottomY);
        end
    end

    -- More advanced positioning functions
    function StdUi:GlueAcross(object, referencedObject, topLeftX, topLeftY, bottomRightX, bottomRightY)
        object:SetPoint(TopLeft, referencedObject, TopLeft, topLeftX, topLeftY);
        object:SetPoint(BottomRight, referencedObject, BottomRight, bottomRightX, bottomRightY);
    end

    -- Glues object to opposite side of anchor
    function StdUi:GlueOpposite(object, referencedObject, x, y, anchor)
        if anchor == 'TOP' then
            object:SetPoint('BOTTOM', referencedObject, anchor, x, y);
        elseif anchor == 'BOTTOM' then
            object:SetPoint('TOP', referencedObject, anchor, x, y);
        elseif anchor == 'LEFT' then
            object:SetPoint('RIGHT', referencedObject, anchor, x, y);
        elseif anchor == 'RIGHT' then
            object:SetPoint('LEFT', referencedObject, anchor, x, y);
        elseif anchor == 'TOPLEFT' then
            object:SetPoint('BOTTOMRIGHT', referencedObject, anchor, x, y);
        elseif anchor == 'TOPRIGHT' then
            object:SetPoint('BOTTOMLEFT', referencedObject, anchor, x, y);
        elseif anchor == 'BOTTOMLEFT' then
            object:SetPoint('TOPRIGHT', referencedObject, anchor, x, y);
        elseif anchor == 'BOTTOMRIGHT' then
            object:SetPoint('TOPLEFT', referencedObject, anchor, x, y);
        else
            object:SetPoint('CENTER', referencedObject, anchor, x, y);
        end
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Util', 10;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local TableGetN = table.getn;
    local TableInsert = tinsert;
    local TableSort = table.sort;

    --- @param frame Frame
    function StdUi:MarkAsValid(frame, valid)
        if not frame.SetBackdrop then
            Mixin(frame, BackdropTemplateMixin)
        end
        if not valid then
            frame:SetBackdropBorderColor(1, 0, 0, 1);
            frame.origBackdropBorderColor = { frame:GetBackdropBorderColor() };
        else
            frame:SetBackdropBorderColor(
                self.config.backdrop.border.r,
                self.config.backdrop.border.g,
                self.config.backdrop.border.b,
                self.config.backdrop.border.a
            );
            frame.origBackdropBorderColor = { frame:GetBackdropBorderColor() };
        end
    end

    StdUi.Util = {
        --- @param self EditBox
        editBoxValidator     = function(self)
            self.value = self:GetText();

            self.stdUi:MarkAsValid(self, true);
            return true;
        end,

        --- @param self EditBox
        moneyBoxValidator    = function(self)
            local text = self:GetText();
            text = text:trim();
            local total, gold, silver, copper, isValid = StdUi.Util.parseMoney(text);

            if not isValid or total == 0 then
                self.stdUi:MarkAsValid(self, false);
                return false;
            end

            self:SetText(StdUi.Util.formatMoney(total));
            self.value = total;

            self.stdUi:MarkAsValid(self, true);
            return true;
        end,

        --- @param self EditBox
        moneyBoxValidatorExC = function(self)
            local text = self:GetText();
            text = text:trim();
            local total, gold, silver, copper, isValid = StdUi.Util.parseMoney(text);

            if not isValid or total == 0 or (copper and tonumber(copper) > 0) then
                self.stdUi:MarkAsValid(self, false);
                return false;
            end

            self:SetText(StdUi.Util.formatMoney(total, true));
            self.value = total;

            self.stdUi:MarkAsValid(self, true);
            return true;
        end,

        --- @param self EditBox
        numericBoxValidator  = function(self)
            local text = self:GetText();
            text = text:trim();

            local value = tonumber(text);

            if value == nil then
                self.stdUi:MarkAsValid(self, false);
                return false;
            end

            if self.maxValue and self.maxValue < value then
                self.stdUi:MarkAsValid(self, false);
                return false;
            end

            if self.minValue and self.minValue > value then
                self.stdUi:MarkAsValid(self, false);
                return false;
            end

            self.value = value;

            self.stdUi:MarkAsValid(self, true);

            return true;
        end,

        --- @param self EditBox
        spellValidator       = function(self)
            local text = self:GetText();
            text = text:trim();
            local name, _, icon, _, _, _, spellId = GetSpellInfo(text);

            if not name then
                self.stdUi:MarkAsValid(self, false);
                return false;
            end

            self:SetText(name);
            self.value = spellId;
            self.icon:SetTexture(icon);

            self.stdUi:MarkAsValid(self, true);
            return true;
        end,

        parseMoney           = function(text)
            text = StdUi.Util.stripColors(text);
            local total = 0;
            local cFound, _, copper = string.find(text, '(%d+)c$');
            if cFound then
                text = string.gsub(text, '(%d+)c$', '');
                text = text:trim();
                total = tonumber(copper);
            end

            local sFound, _, silver = string.find(text, '(%d+)s$');
            if sFound then
                text = string.gsub(text, '(%d+)s$', '');
                text = text:trim();
                total = total + tonumber(silver) * 100;
            end

            local gFound, _, gold = string.find(text, '(%d+)g$');
            if gFound then
                text = string.gsub(text, '(%d+)g$', '');
                text = text:trim();
                total = total + tonumber(gold) * 100 * 100;
            end

            local left = tonumber(text:len());
            local isValid = (text:len() == 0 and total > 0);

            return total, gold, silver, copper, isValid;
        end,

        formatMoney          = function(money, excludeCopper)
            if type(money) ~= 'number' then
                return money;
            end

            money = tonumber(money);
            local goldColor = '|cfffff209';
            local silverColor = '|cff7b7b7a';
            local copperColor = '|cffac7248';

            local gold = floor(money / COPPER_PER_GOLD);
            local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
            local copper = floor(money % COPPER_PER_SILVER);

            local output = '';

            if gold > 0 then
                output = format('%s%i%s ', goldColor, gold, '|rg');
            end

            if gold > 0 or silver > 0 then
                output = format('%s%s%02i%s ', output, silverColor, silver, '|rs');
            end

            if not excludeCopper then
                output = format('%s%s%02i%s ', output, copperColor, copper, '|rc');
            end

            return output:trim();
        end,

        stripColors          = function(text)
            text = string.gsub(text, '|c%x%x%x%x%x%x%x%x', '');
            text = string.gsub(text, '|r', '');
            return text;
        end,

        WrapTextInColor      = function(text, r, g, b, a)
            local hex = string.format(
                '%02x%02x%02x%02x',
                Clamp(a * 255, 0, 255),
                Clamp(r * 255, 0, 255),
                Clamp(g * 255, 0, 255),
                Clamp(b * 255, 0, 255)
            );

            return WrapTextInColorCode(text, hex);
        end,

        tableCount           = function(tab)
            local n = #tab;

            if n == 0 then
                for _ in pairs(tab) do
                    n = n + 1;
                end
            end

            return n;
        end,

        tableMerge           = function(default, new)
            local result = {};
            for k, v in pairs(default) do
                if type(v) == 'table' then
                    if new[k] then
                        result[k] = StdUi.Util.tableMerge(v, new[k]);
                    else
                        result[k] = v;
                    end
                else
                    result[k] = new[k] or default[k];
                end
            end

            for k, v in pairs(new) do
                if not result[k] then
                    result[k] = v;
                end
            end

            return result;
        end,

        stringSplit          = function(separator, input, limit)
            return { strsplit(separator, input, limit) };
        end,

        --- Ordered pairs

        __genOrderedIndex    = function(t)
            local orderedIndex = {};

            for key in pairs(t) do
                TableInsert(orderedIndex, key)
            end

            TableSort(orderedIndex, function(a, b)
                if not t[a].order or not t[b].order then
                    return a < b;
                end

                return t[a].order < t[b].order;
            end);

            return orderedIndex;
        end,

        orderedNext          = function(t, state)
            local key;

            if state == nil then
                -- the first time, generate the index
                t.__orderedIndex = StdUi.Util.__genOrderedIndex(t);
                key = t.__orderedIndex[1];
            else
                -- fetch the next value
                for i = 1, TableGetN(t.__orderedIndex) do
                    if t.__orderedIndex[i] == state then
                        key = t.__orderedIndex[i + 1];
                    end
                end
            end

            if key then
                return key, t[key];
            end

            -- no more value to return, cleanup
            t.__orderedIndex = nil;
            return
        end,

        orderedPairs         = function(t)
            return StdUi.Util.orderedNext, t, nil;
        end,

        roundPrecision       = function(value, precision)
            local multiplier = 10 ^ (precision or 0);
            return math.floor(value * multiplier + 0.5) / multiplier;
        end
    };

    StdUi:RegisterModule(module, version);

    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Autocomplete', 4;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    local TableInsert = tinsert;

    StdUi.Util.autocompleteTransformer = function(_, value)
        return value;
    end

    StdUi.Util.autocompleteValidator = function(self)
        self.stdUi:MarkAsValid(self, true);
        return true;
    end

    StdUi.Util.autocompleteItemTransformer = function(_, value)
        if not value or value == '' then
            return value;
        end

        local itemName = GetItemInfo(value);
        return itemName;
    end

    StdUi.Util.autocompleteItemValidator = function(ac)
        local itemName, itemId;
        local t = ac:GetText();
        local v = ac:GetValue();

        if tonumber(t) ~= nil then
            -- it's a number
            itemName = GetItemInfo(tonumber(t));
            if itemName then
                itemId = tonumber(t);
            end
        elseif v then
            itemName = GetItemInfo(v);
            if itemName == t then
                itemId = v;
            end
        end

        if itemId then
            ac.value = itemId;
            ac:SetText(itemName);
            self.stdUi:MarkAsValid(ac, true);

            return true;
        else
            self.stdUi:MarkAsValid(ac, false);
            return false;
        end
    end

    local AutocompleteMethods = {
        --- Private methods
        buttonCreate = function(panel)
            local optionButton;

            optionButton = StdUi:HighlightButton(panel, panel:GetWidth(), 20, '');
            optionButton.highlight = StdUi:HighlightButtonTexture(optionButton);
            optionButton.highlight:Hide();
            optionButton.text:SetJustifyH("LEFT");
            optionButton.autocomplete = panel.autocomplete;
            optionButton:SetFrameLevel(panel:GetFrameLevel() + 2);

            optionButton:SetScript('OnClick', function(b)
                local ac = b.autocomplete;
                if b.boundItem then
                    b.autocomplete.selectedItem = b.boundItem;
                end

                ac.indexChosen = 0;
                ac:SetValue(b.value, b:GetText());
                b.autocomplete.dropdown:Hide();
                ac:SetFocus();
            end);

            return optionButton;
        end,

        buttonUpdate = function(panel, optionButton, data)
            optionButton.boundItem = data;
            optionButton.value = data.value;

            optionButton:SetWidth(panel:GetWidth());
            optionButton:SetText(data.text);
        end,

        filterItems = function(ac, search, itemsToSearch)
            local result = {};

            for _, item in pairs(itemsToSearch) do
                local valueString = tostring(item.value);
                if
                    item.text:lower():find(search:lower(), nil, true) or
                    valueString:lower():find(search:lower(), nil, true)
                then
                    TableInsert(result, item);
                end

                if #result >= ac.itemLimit then
                    break;
                end
            end

            return result;
        end,

        --- Public methods
        SetItems = function(self, newItems)
            self.items = newItems;
            self:RenderItems();
            self.dropdown:Hide();
        end,

        RenderItems = function(self)
            local dropdownHeight = 20 * #self.filteredItems;
            self.dropdown:SetHeight(dropdownHeight);

            self.stdUi:ObjectList(
                self.dropdown,
                self.itemTable,
                self.buttonCreate,
                self.buttonUpdate,
                self.filteredItems
            );
        end,

        ToggleHighlightItems = function(self, flag)
            for _, button in pairs(self.itemTable) do
                if flag then
                    button.highlight:Show();
                else
                    button.highlight:Hide();
                end
            end
        end,

        ToggleHighlight = function(self, index, flag)
            if flag then
                self.itemTable[index].highlight:Show();
            else
                self.itemTable[index].highlight:Hide();
            end
        end,

        ValueToText = function(self, value)
            return self.transformer(value)
        end,

        SetValue = function(self, value, t)
            self.value = value;
            self:SetText(t or self:ValueToText(value) or '');
            self:Validate();
            self.button:Hide();
        end,

        Validate = function(self)
            self.isValidated = true;
            self.isValid = self:validator();

            if self.isValid then
                if self.OnValueChanged then
                    self:OnValueChanged(self.value, self:GetText());
                end
            end
            self.isValidated = false;
        end,
    };

    local AutocompleteEvents = {
        OnEditFocusLost = function(s)
            C_Timer.After(0.1, function() s.dropdown:Hide(); end);
        end,

        OnEnterPressed = function(ac)
            ac.dropdown:Hide();

            -- User was using arrows to select item
            if ac.indexChosen > 0 and ac.indexChosen <= #ac.filteredItems then
                local item = ac.filteredItems[ac.indexChosen];
                ac:SetValue(item.value, item.text);
                ac.indexChosen = 0;
                ac:ToggleHighlightItems(false);
            end
            ac:Validate();

            if ac.CustomEnterPressed then
                ac:CustomEnterPressed(ac);
            end
        end,

        OnTextChanged = function(ac, isUserInput)
            local plainText = StdUi.Util.stripColors(ac:GetText());
            ac.selectedItem = nil;

            if isUserInput then
                -- reset value if user changed something
                ac.value = nil;

                if type(ac.items) == 'function' then
                    -- We ensure to pass whole autocomplete as well
                    ac.filteredItems = ac:items(plainText);
                elseif type(ac.items) == 'table' then
                    ac.filteredItems = ac:filterItems(plainText, ac.items);
                end

                if not ac.filteredItems or #ac.filteredItems == 0 then
                    ac.dropdown:Hide();
                else
                    ac:RenderItems();
                    ac.dropdown:Show();
                end
            end
        end,

        OnKeyUp = function(ac, key)
            local arrowKeyPressed = false;
            if key == 'UP' then
                ac.indexChosen = ac.indexChosen - 1;
                arrowKeyPressed = true;
            elseif key == 'DOWN' then
                ac.indexChosen = ac.indexChosen + 1;
                arrowKeyPressed = true;
            end

            if arrowKeyPressed then
                if ac.indexChosen < 1 then
                    ac.indexChosen = #ac.filteredItems;
                end

                if ac.indexChosen > #ac.filteredItems then
                    ac.indexChosen = 1;
                end

                ac:ToggleHighlightItems(false);
                ac:ToggleHighlight(ac.indexChosen, true);
            end
        end
    }

    --- Very similar to dropdown except it has the ability to create new records and filters results
    --- @return EditBox
    function StdUi:Autocomplete(parent, width, height, text, validator, transformer, items)
        transformer = transformer or StdUi.Util.autocompleteTransformer;
        validator = validator or StdUi.Util.autocompleteValidator;

        local autocomplete = self:EditBox(parent, width, height, text, validator);
        ---@type StdUi
        autocomplete.stdUi = self;
        autocomplete.transformer = transformer;
        autocomplete.items = items;
        autocomplete.filteredItems = {};
        autocomplete.selectedItem = nil;
        autocomplete.itemLimit = 8;
        autocomplete.itemTable = {};
        autocomplete.indexChosen = 0;

        autocomplete.dropdown = self:Panel(parent, width, 20);
        autocomplete.dropdown:SetPoint('TOPLEFT', autocomplete, 'BOTTOMLEFT', 0, 0);
        autocomplete.dropdown:SetPoint('TOPRIGHT', autocomplete, 'BOTTOMRIGHT', 0, 0);
        autocomplete.dropdown:Hide();
        autocomplete.dropdown:SetFrameLevel(autocomplete:GetFrameLevel() + 10);

        -- keep back reference
        autocomplete.dropdown.autocomplete = autocomplete;

        for k, v in pairs(AutocompleteMethods) do
            autocomplete[k] = v;
        end

        for k, v in pairs(AutocompleteEvents) do
            autocomplete:SetScript(k, v);
        end

        return autocomplete;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Basic', 3;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    function StdUi:Frame(parent, width, height, inherits)
        local frame = CreateFrame('Frame', nil, parent, inherits);
        self:InitWidget(frame);
        self:SetObjSize(frame, width, height);

        return frame;
    end

    function StdUi:Panel(parent, width, height, inherits)
        local frame = self:Frame(parent, width, height, inherits);
        self:ApplyBackdrop(frame, 'panel');

        return frame;
    end

    function StdUi:PanelWithLabel(parent, width, height, inherits, text)
        local frame = self:Panel(parent, width, height, inherits);

        frame.label = self:Header(frame, text);
        frame.label:SetAllPoints();
        frame.label:SetJustifyH("CENTER");

        return frame;
    end

    function StdUi:PanelWithTitle(parent, width, height, text)
        local frame = self:Panel(parent, width, height);

        frame.titlePanel = self:PanelWithLabel(frame, 100, 20, nil, text);
        frame.titlePanel:SetPoint('TOP', 0, -10);
        frame.titlePanel:SetPoint('LEFT', 30, 0);
        frame.titlePanel:SetPoint('RIGHT', -30, 0);
        frame.titlePanel:SetBackdrop(nil);

        return frame;
    end

    --- @return Texture
    function StdUi:Texture(parent, width, height, texture)
        local tex = parent:CreateTexture(nil, 'ARTWORK');

        self:SetObjSize(tex, width, height);
        if texture then
            tex:SetTexture(texture);
        end

        return tex;
    end

    --- @return Texture
    function StdUi:ArrowTexture(parent, direction)
        local texture = self:Texture(parent, 16, 8, [[Interface\Buttons\Arrow-Up-Down]]);

        if direction == 'UP' then
            texture:SetTexCoord(0, 1, 0.5, 1);
        else
            texture:SetTexCoord(0, 1, 1, 0.5);
        end

        return texture;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Button', 6;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    local SquareButtonCoords = {
        UP = { 0.45312500, 0.64062500, 0.01562500, 0.20312500 },
        DOWN = { 0.45312500, 0.64062500, 0.20312500, 0.01562500 },
        LEFT = { 0.23437500, 0.42187500, 0.01562500, 0.20312500 },
        RIGHT = { 0.42187500, 0.23437500, 0.01562500, 0.20312500 },
        DELETE = { 0.01562500, 0.20312500, 0.01562500, 0.20312500 },
    };

    local SquareButtonMethods = {
        SetIconDisabled = function(self, texture, iconWidth, iconHeight)
            self.iconDisabled = self.stdUi:Texture(self, iconWidth, iconHeight, texture);
            self.iconDisabled:SetDesaturated(true);
            self.iconDisabled:SetPoint('CENTER', 0, 0);

            self:SetDisabledTexture(self.iconDisabled);
        end,

        SetIcon = function(self, texture, iconWidth, iconHeight, alsoDisabled)
            self.icon = self.stdUi:Texture(self, iconWidth, iconHeight, texture);
            self.icon:SetPoint('CENTER', 0, 0);

            self:SetNormalTexture(self.icon);

            if alsoDisabled then
                self:SetIconDisabled(texture, iconWidth, iconHeight);
            end
        end
    };

    function StdUi:SquareButton(parent, width, height, icon)
        local button = CreateFrame('Button', nil, parent);
        button.stdUi = self;

        self:InitWidget(button);
        self:SetObjSize(button, width, height);

        self:ApplyBackdrop(button);
        self:HookDisabledBackdrop(button);
        self:HookHoverBorder(button);

        for k, v in pairs(SquareButtonMethods) do
            button[k] = v;
        end

        local coords = SquareButtonCoords[icon];
        if coords then
            button:SetIcon([[Interface\Buttons\SquareButtonTextures]], 16, 16, true);
            button.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
            button.iconDisabled:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
        end

        return button;
    end

    function StdUi:ButtonLabel(parent, text)
        local label = self:Label(parent, text);
        label:SetJustifyH("CENTER");
        self:GlueAcross(label, parent, 2, -2, -2, 2);
        parent:SetFontString(label);

        return label;
    end

    function StdUi:HighlightButtonTexture(button)
        local hTex = self:Texture(button, nil, nil, nil);
        hTex:SetColorTexture(
            self.config.highlight.color.r,
            self.config.highlight.color.g,
            self.config.highlight.color.b,
            self.config.highlight.color.a
        );
        hTex:SetAllPoints();

        return hTex;
    end

    --- Creates a button with only a highlight
    --- @return Button
    function StdUi:HighlightButton(parent, width, height, text, inherit)
        local button = CreateFrame('Button', nil, parent, inherit);
        self:InitWidget(button);
        self:SetObjSize(button, width, height);
        button.text = self:ButtonLabel(button, text);

        function button:SetFontSize(newSize)
            self.text:SetFontSize(newSize);
        end

        local hTex = self:HighlightButtonTexture(button);
        hTex:SetBlendMode('ADD');

        --      button:SetHighlightTexture(hTex);
        if (hTex == nil) then
            button:SetHighlightTexture('');
        else
            button:SetHighlightTexture(hTex);
        end
        button.highlightTexture = hTex;

        return button;
    end

    --- @return Button
    function StdUi:Button(parent, width, height, text, inherit)
        local button = self:HighlightButton(parent, width, height, text, inherit)
        button.stdUi = self;

        button:SetHighlightTexture('');
        self:ApplyBackdrop(button);
        self:HookDisabledBackdrop(button);
        self:HookHoverBorder(button);

        return button;
    end

    function StdUi:ButtonAutoWidth(button, padding)
        padding = padding or 5;
        button:SetWidth(button.text:GetStringWidth() + padding * 2);
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Checkbox', 5;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    ----------------------------------------------------
    --- Checkbox
    ----------------------------------------------------

    local CheckboxMethods = {
        --- Set checkbox state
        ---
        --- @param flag boolean
        --- @param internal boolean - indicates to not run OnValueChanged
        SetChecked = function(self, flag, internal)
            self.isChecked = flag;

            if not internal and self.OnValueChanged then
                self:OnValueChanged(flag, self.value);
            end

            if not flag then
                self.checkedTexture:Hide();
                self.disabledCheckedTexture:Hide();
                return
            end

            if self.isDisabled then
                self.checkedTexture:Hide();
                self.disabledCheckedTexture:Show();
            else
                self.checkedTexture:Show();
                self.disabledCheckedTexture:Hide();
            end
        end,

        GetChecked = function(self)
            return self.isChecked;
        end,

        SetText    = function(self, t)
            self.text:SetText(t);
        end,

        SetValue   = function(self, value)
            self.value = value;
        end,

        GetValue   = function(self)
            if self:GetChecked() then
                return self.value;
            else
                return nil;
            end
        end,

        Disable    = function(self)
            self.isDisabled = true;
            self:SetChecked(self.isChecked);
        end,

        Enable     = function(self)
            self.isDisabled = false;
            self:SetChecked(self.isChecked);
        end,

        AutoWidth  = function(self)
            self:SetWidth(self.target:GetWidth() + 15 + self.text:GetWidth());
        end
    };

    local CheckboxEvents = {
        OnClick = function(self)
            if not self.isDisabled then
                self:SetChecked(not self:GetChecked());
            end
        end
    }

    ---@return CheckButton
    function StdUi:Checkbox(parent, text, width, height)
        local checkbox = CreateFrame('Button', nil, parent);
        checkbox.stdUi = self;

        checkbox:EnableMouse(true);
        self:SetObjSize(checkbox, width, height or 20);
        self:InitWidget(checkbox);

        checkbox.target = self:Panel(checkbox, 16, 16);
        checkbox.target.stdUi = self;
        checkbox.target:SetPoint('LEFT', 0, 0);

        checkbox.value = true;
        checkbox.isChecked = false;

        checkbox.text = self:Label(checkbox, text);
        checkbox.text:SetPoint('LEFT', checkbox.target, 'RIGHT', 5, 0);
        checkbox.text:SetPoint('RIGHT', checkbox, 'RIGHT', -5, 0);
        checkbox.target.text = checkbox.text; -- reference for disabled

        checkbox.checkedTexture = self:Texture(checkbox.target, nil, nil, [[Interface\Buttons\UI-CheckBox-Check]]);
        checkbox.checkedTexture:SetAllPoints();
        checkbox.checkedTexture:Hide();

        checkbox.disabledCheckedTexture = self:Texture(checkbox.target, nil, nil,
            [[Interface\Buttons\UI-CheckBox-Check-Disabled]]);
        checkbox.disabledCheckedTexture:SetAllPoints();
        checkbox.disabledCheckedTexture:Hide();

        for k, v in pairs(CheckboxMethods) do
            checkbox[k] = v;
        end

        self:ApplyBackdrop(checkbox.target);
        self:HookDisabledBackdrop(checkbox);
        self:HookHoverBorder(checkbox);

        if width == nil then
            checkbox:AutoWidth();
        end

        for k, v in pairs(CheckboxEvents) do
            checkbox:SetScript(k, v);
        end

        return checkbox;
    end

    ----------------------------------------------------
    --- IconCheckbox
    ----------------------------------------------------

    function StdUi:IconCheckbox(parent, icon, text, width, height, iconSize)
        iconSize = iconSize or 16
        local checkbox = self:Checkbox(parent, text, width, height);
        checkbox.icon = self:Texture(checkbox, iconSize, iconSize, icon);
        checkbox.icon:SetPoint('LEFT', checkbox.target, 'RIGHT', 5, 0);

        checkbox.text:ClearAllPoints();
        checkbox.text:SetPoint('LEFT', checkbox.target, 'RIGHT', iconSize + 5, 0);
        checkbox.text:SetPoint('RIGHT', checkbox, 'RIGHT', -5, 0);

        return checkbox;
    end

    ----------------------------------------------------
    --- Radio
    ----------------------------------------------------

    local RadioEvents = {
        OnClick = function(self)
            if not self.isDisabled then
                self:SetChecked(true);
            end
        end
    };

    ---@return CheckButton
    function StdUi:Radio(parent, text, groupName, width, height)
        local radio = self:Checkbox(parent, text, width, height);

        radio.checkedTexture = self:Texture(radio.target, nil, nil, [[Interface\Buttons\UI-RadioButton]]);
        radio.checkedTexture:SetAllPoints(radio.target);
        radio.checkedTexture:Hide();
        radio.checkedTexture:SetTexCoord(0.25, 0.5, 0, 1);

        radio.disabledCheckedTexture = self:Texture(radio.target, nil, nil,
            [[Interface\Buttons\UI-RadioButton]]);
        radio.disabledCheckedTexture:SetAllPoints(radio.target);
        radio.disabledCheckedTexture:Hide();
        radio.disabledCheckedTexture:SetTexCoord(0.75, 1, 0, 1);

        for k, v in pairs(RadioEvents) do
            radio:SetScript(k, v);
        end

        if groupName then
            self:AddToRadioGroup(radio, groupName);
        end

        return radio;
    end

    StdUi.radioGroups = {};
    StdUi.radioGroupValues = {};

    ---@return CheckButton[]
    function StdUi:RadioGroup(groupName)
        if not self.radioGroups[groupName] then
            self.radioGroups[groupName] = {};
        end

        if not self.radioGroupValues[groupName] then
            self.radioGroupValues[groupName] = {};
        end

        return self.radioGroups[groupName];
    end

    function StdUi:GetRadioGroupValue(groupName)
        local group = self:RadioGroup(groupName);

        for i = 1, #group do
            local radio = group[i];
            if radio:GetChecked() then
                return radio:GetValue();
            end
        end

        return nil;
    end

    function StdUi:SetRadioGroupValue(groupName, value)
        local group = self:RadioGroup(groupName);

        for i = 1, #group do
            local radio = group[i];
            radio:SetChecked(radio.value == value)
        end

        return nil;
    end

    local radioGroupOnValueChanged = function(radio)
        radio.notified = true;
        local group = radio.radioGroup;
        local groupName = radio.radioGroupName;

        -- We must get all notifications from group
        for i = 1, #group do
            if not group[i].notified then
                return
            end
        end

        local newValue = radio.stdUi:GetRadioGroupValue(groupName);
        if radio.stdUi.radioGroupValues[groupName] ~= newValue then
            radio.OnValueChangedCallback(newValue, groupName);
        end
        radio.stdUi.radioGroupValues[groupName] = newValue;

        for i = 1, #group do
            group[i].notified = false;
        end
    end

    function StdUi:OnRadioGroupValueChanged(groupName, callback)
        local group = self:RadioGroup(groupName);

        for i = 1, #group do
            local radio = group[i];
            radio.OnValueChangedCallback = callback;
            radio.OnValueChanged = radioGroupOnValueChanged;
        end

        return nil;
    end

    local RadioGroupEvents = {
        OnClick = function(radio)
            for i = 1, #radio.radioGroup do
                local otherRadio = radio.radioGroup[i];

                if otherRadio ~= radio then
                    otherRadio:SetChecked(false);
                end
            end
        end
    };

    function StdUi:AddToRadioGroup(radio, groupName)
        local group = self:RadioGroup(groupName);
        tinsert(group, radio);
        radio.radioGroup = group;
        radio.radioGroupName = groupName;

        for k, v in pairs(RadioGroupEvents) do
            radio:HookScript(k, v);
        end
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'ColorPicker', 6;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local ColorPickerMethods = {
        SetColorRGBA = function(self, r, g, b, a)
            self:SetColorAlpha(a);
            self:SetColorRGB(r, g, b);

            self.newTexture:SetVertexColor(r, g, b, a);
        end,

        GetColorRGBA = function(self)
            local r, g, b = self:GetColorRGB();
            return r, g, b, self:GetColorAlpha();
        end,

        SetColor = function(self, c)
            self:SetColorAlpha(c.a or 1);
            self:SetColorRGB(c.r, c.g, c.b);

            self.newTexture:SetVertexColor(c.r, c.g, c.b, c.a or 1);
        end,

        GetColor = function(self)
            local r, g, b = self:GetColorRGB();
            return { r = r, g = g, b = b, a = self:GetColorAlpha() };
        end,

        SetColorAlpha = function(self, a, fromSlider)
            a = Clamp(a, 0, 1);

            if not fromSlider then
                self.alphaSlider:SetValue(100 - a * 100);
            end

            self.aEdit:SetValue(Round(a * 100));
            self.aEdit:Validate();
            self:SetColorRGB(self:GetColorRGB());
        end,

        GetColorAlpha = function(self)
            local a = Clamp(tonumber(self.aEdit:GetValue()) or 100, 0, 100);
            return a / 100;
        end
    };

    local ColorPickerEvents = {
        OnColorSelect = function(self)
            -- Ensure custom fields are updated.
            local r, g, b, a = self:GetColorRGBA();

            if not self.skipTextUpdate then
                self.rEdit:SetValue(r * 255);
                self.gEdit:SetValue(g * 255);
                self.bEdit:SetValue(b * 255);
                self.aEdit:SetValue(100 * a);

                self.rEdit:Validate();
                self.gEdit:Validate();
                self.bEdit:Validate();
                self.aEdit:Validate();
            end

            self.newTexture:SetVertexColor(r, g, b, a);
            self.alphaTexture:SetGradientAlpha('VERTICAL', 1, 1, 1, 0, r, g, b, 1);
        end
    };

    local function OnColorPickerValueChanged(self)
        local cpf = self:GetParent();
        local r = tonumber(cpf.rEdit:GetValue() or 255) / 255;
        local g = tonumber(cpf.gEdit:GetValue() or 255) / 255;
        local b = tonumber(cpf.bEdit:GetValue() or 255) / 255;
        local a = tonumber(cpf.aEdit:GetValue() or 100) / 100;

        cpf.skipTextUpdate = true;
        cpf:SetColorRGB(r, g, b);
        cpf.alphaSlider:SetValue(100 - a * 100);
        cpf.skipTextUpdate = false;
    end

    --- alphaSliderTexture = [[Interface\AddOns\YourAddon\Libs\StdUi\media\Checkers.tga]]
    function StdUi:ColorPicker(parent, alphaSliderTexture)
        local wheelWidth = 128;
        local thumbWidth = 10;
        local barWidth = 16;

        local cpf = CreateFrame('ColorSelect', nil, parent);
        --self:MakeDraggable(cpf);
        cpf:SetPoint('CENTER');
        self:ApplyBackdrop(cpf, 'panel');
        self:SetObjSize(cpf, 340, 200);

        -- Create colorpicker wheel.
        cpf.wheelTexture = self:Texture(cpf, wheelWidth, wheelWidth);
        self:GlueTop(cpf.wheelTexture, cpf, 10, -10, 'LEFT');

        cpf.wheelThumbTexture = self:Texture(cpf, thumbWidth, thumbWidth, [[Interface\Buttons\UI-ColorPicker-Buttons]]);
        cpf.wheelThumbTexture:SetTexCoord(0, 0.15625, 0, 0.625);

        -- Create the colorpicker slider.
        cpf.valueTexture = self:Texture(cpf, barWidth, wheelWidth);
        self:GlueRight(cpf.valueTexture, cpf.wheelTexture, 10, 0);

        cpf.valueThumbTexture = self:Texture(cpf, barWidth, thumbWidth, [[Interface\Buttons\UI-ColorPicker-Buttons]]);
        cpf.valueThumbTexture:SetTexCoord(0.25, 1, 0.875, 0);

        cpf:SetColorWheelTexture(cpf.wheelTexture);
        cpf:SetColorWheelThumbTexture(cpf.wheelThumbTexture);
        cpf:SetColorValueTexture(cpf.valueTexture);
        cpf:SetColorValueThumbTexture(cpf.valueThumbTexture);

        cpf.alphaSlider = CreateFrame('Slider', nil, cpf);
        cpf.alphaSlider:SetOrientation('VERTICAL');
        cpf.alphaSlider:SetMinMaxValues(0, 100);
        cpf.alphaSlider:SetValue(0);
        self:SetObjSize(cpf.alphaSlider, barWidth, wheelWidth + thumbWidth); -- hack
        self:GlueRight(cpf.alphaSlider, cpf.valueTexture, 10, 0);

        cpf.alphaTexture = self:Texture(cpf.alphaSlider, nil, nil, alphaSliderTexture);
        self:GlueAcross(cpf.alphaTexture, cpf.alphaSlider, 0, -thumbWidth / 2, 0, thumbWidth / 2); -- hack
        --cpf.alphaTexture:SetColorTexture(1, 1, 1, 1);
        --cpf.alphaTexture:SetGradientAlpha('VERTICAL', 0, 0, 0, 1, 1, 1, 1, 1);

        cpf.alphaThumbTexture = self:Texture(cpf.alphaSlider, barWidth, thumbWidth,
            [[Interface\Buttons\UI-ColorPicker-Buttons]]);
        cpf.alphaThumbTexture:SetTexCoord(0.275, 1, 0.875, 0);
        cpf.alphaThumbTexture:SetDrawLayer('ARTWORK', 2);
        cpf.alphaSlider:SetThumbTexture(cpf.alphaThumbTexture);

        cpf.newTexture = self:Texture(cpf, 32, 32, [[Interface\Buttons\WHITE8X8]]);
        cpf.oldTexture = self:Texture(cpf, 32, 32, [[Interface\Buttons\WHITE8X8]]);
        cpf.newTexture:SetDrawLayer('ARTWORK', 5);
        cpf.oldTexture:SetDrawLayer('ARTWORK', 4);

        self:GlueTop(cpf.newTexture, cpf, -30, -30, 'RIGHT');
        self:GlueBelow(cpf.oldTexture, cpf.newTexture, 20, 45);

        ----------------------------------------------------
        --- Buttons
        ----------------------------------------------------

        cpf.rEdit = self:NumericBox(cpf, 60, 20);
        cpf.gEdit = self:NumericBox(cpf, 60, 20);
        cpf.bEdit = self:NumericBox(cpf, 60, 20);
        cpf.aEdit = self:NumericBox(cpf, 60, 20);

        cpf.rEdit:SetMinMaxValue(0, 255);
        cpf.gEdit:SetMinMaxValue(0, 255);
        cpf.bEdit:SetMinMaxValue(0, 255);
        cpf.aEdit:SetMinMaxValue(0, 100);

        self:AddLabel(cpf, cpf.rEdit, 'R', 'LEFT');
        self:AddLabel(cpf, cpf.gEdit, 'G', 'LEFT');
        self:AddLabel(cpf, cpf.bEdit, 'B', 'LEFT');
        self:AddLabel(cpf, cpf.aEdit, 'A', 'LEFT');

        self:GlueAfter(cpf.rEdit, cpf.alphaSlider, 20, -thumbWidth / 2);
        self:GlueBelow(cpf.gEdit, cpf.rEdit, 0, -10);
        self:GlueBelow(cpf.bEdit, cpf.gEdit, 0, -10);
        self:GlueBelow(cpf.aEdit, cpf.bEdit, 0, -10);

        cpf.okButton = StdUi:Button(cpf, 100, 20, OKAY);
        cpf.cancelButton = StdUi:Button(cpf, 100, 20, CANCEL);
        self:GlueBottom(cpf.okButton, cpf, 40, 20, 'LEFT');
        self:GlueBottom(cpf.cancelButton, cpf, -40, 20, 'RIGHT');

        ----------------------------------------------------
        --- Methods
        ----------------------------------------------------

        for k, v in pairs(ColorPickerMethods) do
            cpf[k] = v;
        end

        ----------------------------------------------------
        --- Events
        ----------------------------------------------------

        cpf.alphaSlider:SetScript('OnValueChanged', function(slider)
            cpf:SetColorAlpha((100 - slider:GetValue()) / 100, true);
        end);

        for k, v in pairs(ColorPickerEvents) do
            cpf:SetScript(k, v);
        end

        cpf.rEdit.OnValueChanged = OnColorPickerValueChanged;
        cpf.gEdit.OnValueChanged = OnColorPickerValueChanged;
        cpf.bEdit.OnValueChanged = OnColorPickerValueChanged;
        cpf.aEdit.OnValueChanged = OnColorPickerValueChanged;

        return cpf;
    end

    local ColorPickerFrameOkCallback = function(self)
        local cpf = self:GetParent();
        if cpf.okCallback then
            cpf.okCallback(cpf);
        end

        cpf:Hide();
    end

    local ColorPickerFrameCancelCallback = function(self)
        local cpf = self:GetParent();
        if cpf.cancelCallback then
            cpf.cancelCallback(cpf);
        end

        cpf:Hide();
    end

    -- placeholder
    function StdUi:ColorPickerFrame(r, g, b, a, okCallback, cancelCallback, alphaSliderTexture)
        local colorPickerFrame = self.colorPickerFrame;
        if not colorPickerFrame then
            colorPickerFrame = self:ColorPicker(UIParent, alphaSliderTexture);
            colorPickerFrame:SetFrameStrata('FULLSCREEN_DIALOG');
            self.colorPickerFrame = colorPickerFrame;
        end

        colorPickerFrame.okCallback = okCallback;
        colorPickerFrame.cancelCallback = cancelCallback;

        colorPickerFrame.okButton:SetScript('OnClick', ColorPickerFrameOkCallback);
        colorPickerFrame.cancelButton:SetScript('OnClick', ColorPickerFrameCancelCallback);

        colorPickerFrame:SetColorRGBA(r or 1, g or 1, b or 1, a or 1);
        colorPickerFrame.oldTexture:SetVertexColor(r or 1, g or 1, b or 1, a or 1);

        colorPickerFrame:ClearAllPoints();
        colorPickerFrame:SetPoint('CENTER');
        colorPickerFrame:Show();
    end

    local ColorInputMethods = {
        SetColor = function(self, c)
            if type(c) == 'table' then
                self.color.r = c.r;
                self.color.g = c.g;
                self.color.b = c.b;
                self.color.a = c.a or 1;
            end

            self.target:SetBackdropColor(c.r, c.g, c.b, c.a or 1);
            if self.OnValueChanged then
                self:OnValueChanged(c);
            end
        end,

        GetColor = function(self, type)
            if type == 'hex' then
            elseif type == 'rgba' then
                return self.color.r, self.color.g, self.color.b, self.color.a
            else
                -- object
                return self.color;
            end
        end
    };

    local ColorInputEvents = {
        OnClick = function(self)
            self.stdUi:ColorPickerFrame(
                self.color.r,
                self.color.g,
                self.color.b,
                self.color.a,
                function(cpf)
                    self:SetColor(cpf:GetColor());
                end
            );
        end
    };

    function StdUi:ColorInput(parent, label, width, height, color)
        local button = CreateFrame('Button', nil, parent);
        button.stdUi = self;
        button:EnableMouse(true);
        self:SetObjSize(button, width, height or 20);
        self:InitWidget(button);

        button.target = self:Panel(button, 16, 16);
        button.target.stdUi = self;
        button.target:SetPoint('LEFT', 0, 0);

        button.text = self:Label(button, label);
        button.text:SetPoint('LEFT', button.target, 'RIGHT', 5, 0);
        button.text:SetPoint('RIGHT', button, 'RIGHT', -5, 0);

        button.color = { r = 1, g = 1, b = 1, a = 1 };

        if not button.SetBackdrop then
            Mixin(button, BackdropTemplateMixin)
        end
        self:HookDisabledBackdrop(button); --ColorInput has no visual difference when disabled unlike Checkbox
        self:HookHoverBorder(button);

        for k, v in pairs(ColorInputMethods) do
            button[k] = v;
        end

        for k, v in pairs(ColorInputEvents) do
            button:SetScript(k, v);
        end

        if color then
            button:SetColor(color);
        end

        return button;
    end

    StdUi:RegisterModule(module, version);

    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'ContextMenu', 3;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    --- ContextMenuItem Events

    local ContextMenuItemOnEnter = function(itemFrame, button)
        itemFrame.parentContext:CloseSubMenus();

        itemFrame.childContext:ClearAllPoints();
        itemFrame.childContext:SetPoint('TOPLEFT', itemFrame, 'TOPRIGHT', 0, 0);
        itemFrame.childContext:Show();
    end

    local ContextMenuItemOnMouseUp = function(itemFrame, button)
        local hide
        if button == 'LeftButton' and itemFrame.contextMenuData.callback then
            hide = itemFrame.contextMenuData.callback(itemFrame, itemFrame.parentContext)
        elseif button == 'RightButton' then
            hide = true
        end
        if hide == true and itemFrame.mainContext then
            itemFrame.mainContext:Hide()
        end
    end

    --- ContextMenuEvents

    local ContextMenuOnMouseUp = function(self, button)
        if button == 'RightButton' then
            local uiScale = UIParent:GetScale();
            local cursorX, cursorY = GetCursorPosition();

            cursorX = cursorX / uiScale;
            cursorY = cursorY / uiScale;

            self:ClearAllPoints();

            if self:IsShown() then
                self:Hide();
            else
                self:SetPoint('TOPLEFT', nil, 'BOTTOMLEFT', cursorX, cursorY);
                self:Show();
            end
        end
    end

    ---@type ContextMenu
    StdUi.ContextMenuMethods = {

        CloseMenu         = function(self)
            self:CloseSubMenus();
            self:Hide();
        end,

        CloseSubMenus     = function(self)
            for i = 1, #self.optionFrames do
                local optionFrame = self.optionFrames[i];
                if optionFrame.childContext then
                    optionFrame.childContext:CloseMenu();
                end
            end
        end,

        HookRightClick    = function(self)
            local parent = self:GetParent();
            if parent then
                -- ContextMenuOnMouseUp requires a reference to this menu (self)
                local menu = self -- don't trust magic variable names
                parent:HookScript('OnMouseUp', function(_, button) ContextMenuOnMouseUp(menu, button) end);
            end
        end,

        HookChildrenClick = function(self)

        end,

        CreateItem        = function(parent, data, i)
            local itemFrame;

            if data.title then
                itemFrame = parent.stdUi:Frame(parent, nil, 20);
                itemFrame.text = parent.stdUi:Label(itemFrame);
                parent.stdUi:GlueLeft(itemFrame.text, itemFrame, 0, 0, true);
            elseif data.isSeparator then
                itemFrame = parent.stdUi:Frame(parent, nil, 20);
                itemFrame.texture = parent.stdUi:Texture(itemFrame, nil, 8,
                    [[Interface\COMMON\UI-TooltipDivider-Transparent]]);
                itemFrame.texture:SetPoint('CENTER');
                itemFrame.texture:SetPoint('LEFT');
                itemFrame.texture:SetPoint('RIGHT');
            elseif data.checkbox then
                itemFrame = parent.stdUi:Checkbox(parent, '');
            elseif data.radio then
                itemFrame = parent.stdUi:Radio(parent, '', data.radioGroup);
            elseif data.text then
                itemFrame = parent.stdUi:HighlightButton(parent, nil, 20);
            end

            itemFrame.contextMenuData = data;

            -- Need mainContext on all items for right click compatibility.
            -- This will also keep propagating mainContext thru all children.
            -- Note: In the top-most level of items frames, the parent does NOT have a
            -- mainContext, and in that case the parent itself IS the mainContext.
            itemFrame.mainContext = parent.mainContext or parent

            if not data.isSeparator then
                itemFrame.text:SetJustifyH("LEFT");
            end

            if not data.isSeparator and data.children then
                itemFrame.icon = parent.stdUi:Texture(itemFrame, 10, 10, [[Interface\Buttons\SquareButtonTextures]]);
                itemFrame.icon:SetTexCoord(0.42187500, 0.23437500, 0.01562500, 0.20312500);
                parent.stdUi:GlueRight(itemFrame.icon, itemFrame, -4, 0, true);

                itemFrame.childContext = parent.stdUi:ContextMenu(parent, data.children, true, parent.level + 1);
                itemFrame.parentContext = parent;

                itemFrame:HookScript('OnEnter', ContextMenuItemOnEnter);
            end

            if data.events then
                for eventName, eventHandler in pairs(data.events) do
                    itemFrame:SetScript(eventName, eventHandler);
                end
            end

            -- Always need Right click capability in item frames to close the menu
            itemFrame:SetScript('OnMouseUp', ContextMenuItemOnMouseUp)

            if data.custom then
                for key, value in pairs(data.custom) do
                    itemFrame[key] = value;
                end
            end

            return itemFrame;
        end,

        UpdateItem        = function(parent, itemFrame, data, i)
            local padding = parent.padding;

            if data.title then
                itemFrame.text:SetText(data.title);
                parent.stdUi:ButtonAutoWidth(itemFrame);
            elseif data.checkbox or data.radio then
                itemFrame.text:SetText(data.checkbox or data.radio);
                itemFrame:AutoWidth();
                if data.value then
                    itemFrame:SetValue(data.value);
                end
            elseif data.text then
                itemFrame:SetText(data.text);
                parent.stdUi:ButtonAutoWidth(itemFrame);
            end

            if data.children then
                -- add arrow size
                itemFrame:SetWidth(itemFrame:GetWidth() + 16);
            end

            if (parent:GetWidth() - padding * 2) < itemFrame:GetWidth() then
                parent:SetWidth(itemFrame:GetWidth() + padding * 2);
            end

            itemFrame:SetPoint('LEFT', padding, 0);
            itemFrame:SetPoint('RIGHT', -padding, 0);

            if data.color and not data.isSeparator then
                itemFrame.text:SetTextColor(unpack(data.color));
            end
        end,

        DrawOptions       = function(self, options)
            if not self.optionFrames then
                self.optionFrames = {};
            end

            local _, totalHeight = self.stdUi:ObjectList(
                self,
                self.optionFrames,
                self.CreateItem,
                self.UpdateItem,
                options,
                0,
                self.padding,
                -self.padding
            );

            self:SetHeight(totalHeight + self.padding);
        end,

        StartHideCounter  = function(self)
            if self.timer then
                self.timer:Cancel();
            end
            self.timer = C_Timer:NewTimer(3, self.TimerCallback);
        end,

        StopHideCounter   = function()

        end
    };

    StdUi.ContextMenuEvents = {
        OnEnter = function(self)

        end,
        OnLeave = function(self)

        end
    };

    function StdUi:ContextMenu(parent, options, stopHook, level)
        ---@class ContextMenu
        local panel = self:Panel(parent);
        panel.stdUi = self;
        panel.level = level or 1;
        panel.padding = 16;

        panel:SetFrameStrata('FULLSCREEN_DIALOG');

        -- force context menus to stay on the screen where they can be used
        panel:SetClampedToScreen(true)

        for k, v in pairs(self.ContextMenuMethods) do
            panel[k] = v;
        end

        for k, v in pairs(self.ContextMenuEvents) do
            panel:SetScript(k, v);
        end

        panel:DrawOptions(options);

        if panel.level == 1 then
            -- self reference for children
            panel.mainContext = panel;
            if not stopHook then
                panel:HookRightClick();
            end
        end

        panel:Hide();

        return panel;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Dropdown', 4;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    local TableInsert = tinsert;

    -- reference to all other dropdowns to close them when new one opens
    local dropdowns = StdUiDropdowns or {};
    StdUiDropdowns = dropdowns;

    local DropdownItemOnClick = function(self)
        self.dropdown:SetValue(self.value, self:GetText());
        self.dropdown.optsFrame:Hide();
    end

    local DropdownItemOnValueChanged = function(checkbox, isChecked)
        checkbox.dropdown:ToggleValue(checkbox.value, isChecked);
    end

    local DropdownMethods = {
        buttonCreate = function(parent)
            local dropdown = parent.dropdown;
            local optionButton;

            if dropdown.multi then
                optionButton = dropdown.stdUi:Checkbox(parent, '', parent:GetWidth(), 20);
            else
                optionButton = dropdown.stdUi:HighlightButton(parent, parent:GetWidth(), 20, '');
                optionButton.text:SetJustifyH("LEFT");
            end

            optionButton.dropdown = dropdown;
            optionButton:SetFrameLevel(parent:GetFrameLevel() + 2);
            if not dropdown.multi then
                optionButton:SetScript('OnClick', DropdownItemOnClick);
            else
                optionButton.OnValueChanged = DropdownItemOnValueChanged;
            end

            return optionButton;
        end,

        buttonUpdate = function(parent, itemFrame, data)
            itemFrame:SetWidth(parent:GetWidth());
            itemFrame:SetText(data.text);

            if itemFrame.dropdown.multi then
                itemFrame:SetValue(data.value);
            else
                itemFrame.value = data.value;
            end
        end,

        ShowOptions = function(self)
            for i = 1, #dropdowns do
                dropdowns[i]:HideOptions();
            end

            self.optsFrame:UpdateSize(self:GetWidth(), self.optsFrame:GetHeight());
            self.optsFrame:Show();
            self.optsFrame:Update();
            self:RepaintOptions();
        end,

        HideOptions = function(self)
            self.optsFrame:Hide();
        end,

        ToggleOptions = function(self)
            if self.optsFrame:IsShown() then
                self:HideOptions();
            else
                self:ShowOptions();
            end
        end,

        SetPlaceholder = function(self, placeholderText)
            if self:GetText() == '' or self:GetText() == self.placeholder then
                self:SetText(placeholderText);
            end

            self.placeholder = placeholderText;
        end,

        RepaintOptions = function(self)
            local scrollChild = self.optsFrame.scrollChild;
            self.stdUi:ObjectList(
                scrollChild,
                scrollChild.items,
                self.buttonCreate,
                self.buttonUpdate,
                self.options
            );
            self.optsFrame:UpdateItemsCount(#self.options);
        end,

        SetOptions = function(self, newOptions)
            self.options = newOptions;
            local optionsHeight = #newOptions * 20;
            local scrollChild = self.optsFrame.scrollChild;
            if not scrollChild.items then
                scrollChild.items = {};
            end

            self.optsFrame:SetHeight(math.min(optionsHeight + 4, 200));
            scrollChild:SetHeight(optionsHeight);

            self:RepaintOptions();
        end,

        ToggleValue = function(self, value, state)
            assert(self.multi, 'Single dropdown cannot have more than one value!');

            -- Treat is as associative array
            if self.assoc then
                self.value[value] = state;
            else
                if state then
                    -- we are toggling it on
                    if not tContains(self.value, value) then
                        TableInsert(self.value, value);
                    end
                else
                    -- we are removing it from table
                    if tContains(self.value, value) then
                        tDeleteItem(self.value, value);
                    end
                end
            end

            self:SetValue(self.value);
        end,

        SetValue = function(self, value, text)
            self.value = value;

            if text then
                self:SetText(text);
            else
                self:SetText(self:FindValueText(value));
            end

            if self.multi then
                for _, checkbox in pairs(self.optsFrame.scrollChild.items) do
                    local isChecked = false;
                    if self.assoc then
                        isChecked = self.value[checkbox.value];
                    else
                        isChecked = tContains(self.value, checkbox.value);
                    end

                    checkbox:SetChecked(isChecked, true);
                end
            end

            if self.OnValueChanged then
                self.OnValueChanged(self, value, self:GetText());
            end
        end,

        GetValue = function(self)
            return self.value;
        end,

        FindValueText = function(self, value)
            if type(value) ~= 'table' then
                for i = 1, #self.options do
                    local opt = self.options[i];

                    if opt.value == value then
                        return opt.text;
                    end
                end

                return self.placeholder or '';
            else
                local result = '';

                for i = 1, #self.options do
                    local opt = self.options[i];

                    if self.assoc then
                        for key, checked in pairs(value) do
                            if checked and key == opt.value then
                                if result == '' then
                                    result = opt.text;
                                else
                                    result = result .. ', ' .. opt.text;
                                end
                            end
                        end
                    else
                        for x = 1, #value do
                            if value[x] == opt.value then
                                if result == '' then
                                    result = opt.text;
                                else
                                    result = result .. ', ' .. opt.text;
                                end
                            end
                        end
                    end
                end

                if result ~= '' then
                    return result
                else
                    return self.placeholder or '';
                end
            end
        end
    };

    local DropdownEvents = {
        OnClick = function(self)
            self:ToggleOptions();
        end
    };

    --- Creates a single level dropdown menu
    --- local options = {
    ---		{text = 'some text', value = 10},
    ---		{text = 'some text2', value = 11},
    ---		{text = 'some text3', value = 12},
    --- }
    --- @return Dropdown
    function StdUi:Dropdown(parent, width, height, options, value, multi, assoc)
        --- @class Dropdown
        local dropdown = self:Button(parent, width, height, '');
        dropdown.stdUi = self;

        dropdown.text:SetJustifyH("LEFT");
        -- make it shorter because of arrow
        dropdown.text:ClearAllPoints();
        self:GlueAcross(dropdown.text, dropdown, 2, -2, -16, 2);

        local dropTex = self:Texture(dropdown, 15, 15, [[Interface\Buttons\SquareButtonTextures]]);
        dropTex:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500);
        self:GlueRight(dropTex, dropdown, -2, 0, true);

        local optsFrame = self:FauxScrollFrame(dropdown, dropdown:GetWidth(), 200, 10, 20);
        optsFrame:Hide();
        self:GlueBelow(optsFrame, dropdown, 0, 1, 'LEFT');
        dropdown:SetFrameLevel(optsFrame:GetFrameLevel() + 1);

        dropdown.multi = multi;
        dropdown.assoc = assoc;

        dropdown.optsFrame = optsFrame;
        dropdown.dropTex = dropTex;
        dropdown.options = options;

        optsFrame.scrollChild.dropdown = dropdown;

        for k, v in pairs(DropdownMethods) do
            dropdown[k] = v;
        end

        if options then
            dropdown:SetOptions(options);
        end

        if value then
            dropdown:SetValue(value);
        elseif multi then
            dropdown.value = {};
        end

        for k, v in pairs(DropdownEvents) do
            dropdown:SetScript(k, v);
        end

        TableInsert(dropdowns, dropdown);

        return dropdown;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'EditBox', 9;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    local pairs = pairs;
    local strlen = strlen;

    ----------------------------------------------------
    --- SimpleEditBox
    ----------------------------------------------------

    local SimpleEditBoxMethods = {
        SetFontSize = function(self, newSize)
            self:SetFont(self:GetFont(), newSize, self.stdUi.config.font.effect);
        end
    };

    local SimpleEditBoxEvents = {
        OnEscapePressed = function(self)
            self:ClearFocus();
        end
    }

    --- @return EditBox
    function StdUi:SimpleEditBox(parent, width, height, text)
        --- @type EditBox
        local editBox = CreateFrame('EditBox', nil, parent);
        editBox.stdUi = self;
        self:InitWidget(editBox);

        editBox:SetTextInsets(3, 3, 3, 3);
        editBox:SetFontObject(ChatFontNormal);
        editBox:SetAutoFocus(false);

        for k, v in pairs(SimpleEditBoxMethods) do
            editBox[k] = v;
        end

        for k, v in pairs(SimpleEditBoxEvents) do
            editBox:SetScript(k, v);
        end

        if text then
            editBox:SetText(text);
        end

        self:HookDisabledBackdrop(editBox);
        self:HookHoverBorder(editBox);
        self:ApplyBackdrop(editBox);
        self:SetObjSize(editBox, width, height);

        return editBox;
    end

    ----------------------------------------------------
    --- ApplyPlaceholder
    ----------------------------------------------------

    local ApplyPlaceholderOnTextChanged = function(self)
        if strlen(self:GetText()) > 0 then
            self.placeholder.icon:Hide();
            self.placeholder.label:Hide();
        else
            self.placeholder.icon:Show();
            self.placeholder.label:Show();
        end
    end

    function StdUi:ApplyPlaceholder(widget, placeholderText, icon, iconColor)
        widget.placeholder = {};

        local label = self:Label(widget, placeholderText);
        self:SetTextColor(label, 'disabled');
        widget.placeholder.label = label;

        if icon then
            local texture = self:Texture(widget, 14, 14, icon);
            local c = iconColor or self.config.font.color.disabled;
            texture:SetVertexColor(c.r, c.g, c.b, c.a);

            self:GlueLeft(texture, widget, 5, 0, true);
            self:GlueRight(label, texture, 2, 0);
            widget.placeholder.icon = texture;
        else
            self:GlueLeft(label, widget, 2, 0, true);
        end

        widget:HookScript('OnTextChanged', ApplyPlaceholderOnTextChanged);
    end

    ----------------------------------------------------
    --- SearchEditBox
    ----------------------------------------------------

    local SearchEditBoxOnTextChanged = function(self)
        if self.OnValueChanged then
            self:OnValueChanged(self:GetText());
        end
    end

    function StdUi:SearchEditBox(parent, width, height, placeholderText)
        local editBox = self:SimpleEditBox(parent, width, height, '');

        editBox:SetScript('OnTextChanged', SearchEditBoxOnTextChanged);

        self:ApplyPlaceholder(editBox, placeholderText, [[Interface\Common\UI-Searchbox-Icon]]);

        return editBox;
    end

    ----------------------------------------------------
    --- SearchEditBox
    ----------------------------------------------------

    local EditBoxMethods = {
        GetValue = function(self)
            return self.value;
        end,

        SetValue = function(self, value)
            self.value = value;
            self:SetText(value);
            self:Validate();
            self.button:Hide();
        end,

        IsValid = function(self)
            return self.isValid;
        end,

        Validate = function(self)
            self.isValidated = true;
            self.isValid = self.validator(self);

            if self.isValid then
                if self.button then
                    self.button:Hide();
                end

                if self.OnValueChanged and tostring(self.lastValue) ~= tostring(self.value) then
                    self:OnValueChanged(self.value);
                    self.lastValue = self.value;
                end
            end

            self.isValidated = false;
        end,
    }

    local EditBoxButtonOnClick = function(self)
        self.editBox:Validate(self.editBox);
    end

    local EditBoxEvents = {
        OnEnterPressed = function(self)
            self:Validate();
        end,

        OnTextChanged = function(self, isUserInput)
            local value = StdUi.Util.stripColors(self:GetText());
            if tostring(value) ~= tostring(self.value) then
                if not self.isValidated and self.button and isUserInput then
                    self.button:Show();
                end
            else
                self.button:Hide();
            end
        end
    }

    --- @return EditBox
    function StdUi:EditBox(parent, width, height, text, validator)
        validator = validator or StdUi.Util.editBoxValidator;

        local editBox = self:SimpleEditBox(parent, width, height, text);
        editBox.validator = validator;

        local button = self:Button(editBox, 40, height - 4, OKAY);
        button:SetPoint('RIGHT', -2, 0);
        button:Hide();
        button.editBox = editBox;
        editBox.button = button;

        for k, v in pairs(EditBoxMethods) do
            editBox[k] = v;
        end

        button:SetScript('OnClick', EditBoxButtonOnClick);

        for k, v in pairs(EditBoxEvents) do
            editBox:SetScript(k, v);
        end

        return editBox;
    end

    ----------------------------------------------------
    --- SearchEditBox
    ----------------------------------------------------

    local NumericBoxMethods = {
        SetMaxValue = function(self, value)
            self.maxValue = value;
            self:Validate();
        end,

        SetMinValue = function(self, value)
            self.minValue = value;
            self:Validate();
        end,

        SetMinMaxValue = function(self, min, max)
            self.minValue = min;
            self.maxValue = max;
            self:Validate();
        end
    }

    function StdUi:NumericBox(parent, width, height, text, validator)
        validator = validator or self.Util.numericBoxValidator;

        local editBox = self:EditBox(parent, width, height, text, validator);
        editBox:SetNumeric(true);

        for k, v in pairs(NumericBoxMethods) do
            editBox[k] = v;
        end

        return editBox;
    end

    ----------------------------------------------------
    --- MoneyBox
    ----------------------------------------------------

    local MoneyBoxMethods = {
        SetValue = function(self, value)
            self.value = value;
            local formatted = self.stdUi.Util.formatMoney(value);
            self:SetText(formatted);
            self:Validate();
            self.button:Hide();
        end,
    };

    function StdUi:MoneyBox(parent, width, height, text, validator, excludeCopper)
        if excludeCopper then
            validator = validator or self.Util.moneyBoxValidatorExC;
        else
            validator = validator or self.Util.moneyBoxValidator;
        end

        local editBox = self:EditBox(parent, width, height, text, validator);
        editBox.stdUi = self;
        editBox:SetMaxLetters(20);

        for k, v in pairs(MoneyBoxMethods) do
            editBox[k] = v;
        end

        return editBox;
    end

    ----------------------------------------------------
    --- MultiLineBox
    ----------------------------------------------------

    local MultiLineBoxMethods = {
        SetValue = function(self, value)
            self.editBox:SetText(value);

            if self.OnValueChanged then
                self:OnValueChanged(value);
            end
        end,

        GetValue = function(self)
            return self.editBox:GetText();
        end,

        SetFont = function(self, font, size, flags)
            self.editBox:SetFont(font, size, flags);
        end,

        Enable = function(self)
            self.editBox:Enable();
        end,

        Disable = function(self)
            self.editBox:Disable();
        end,

        SetFocus = function(self)
            self.editBox:SetFocus();
        end,

        ClearFocus = function(self)
            self.editBox:ClearFocus();
        end,

        HasFocus = function(self)
            return self.editBox:HasFocus();
        end
    };

    local MultiLineBoxOnCursorChanged = function(self, _, y, _, cursorHeight)
        local sf, newY = self.scrollFrame, -y;
        local offset = sf:GetVerticalScroll();

        if newY < offset then
            sf:SetVerticalScroll(newY);
        else
            newY = newY + cursorHeight - sf:GetHeight() + 6; --text insets
            if newY > offset then
                sf:SetVerticalScroll(math.ceil(newY));
            end
        end
    end

    local MultiLineBoxOnTextChanged = function(self)
        if self.panel.OnValueChanged then
            self.panel.OnValueChanged(self.panel, self:GetText());
        end
    end

    local MultiLineBoxScrollOnMouseDown = function(self, button)
        self.scrollChild:SetFocus();
    end

    local MultiLineBoxScrollOnVerticalScroll = function(self, offset)
        self.scrollChild:SetHitRectInsets(0, 0, offset, self.scrollChild:GetHeight() - offset - self:GetHeight());
    end

    function StdUi:MultiLineBox(parent, width, height, text)
        local editBox = CreateFrame('EditBox');
        local widget = self:ScrollFrame(parent, width, height, editBox);
        editBox.stdUi = self;

        local scrollFrame = widget.scrollFrame;
        scrollFrame.editBox = editBox;
        widget.editBox = editBox;
        editBox.panel = widget;

        self:ApplyBackdrop(widget, 'button');
        self:HookHoverBorder(scrollFrame);
        self:HookHoverBorder(editBox);

        editBox:SetWidth(scrollFrame:GetWidth());
        self:GlueAcross(scrollFrame, widget, 2, -2, -widget.scrollBarWidth - 2, 3);
        --editBox:SetHeight(scrollFrame:GetHeight());

        editBox:SetTextInsets(3, 3, 3, 3);
        editBox:SetFontObject(ChatFontNormal);
        editBox:SetAutoFocus(false);
        editBox:SetScript('OnEscapePressed', editBox.ClearFocus);
        editBox:SetMultiLine(true);
        editBox:EnableMouse(true);
        editBox:SetAutoFocus(false);
        editBox:SetCountInvisibleLetters(false);
        editBox:SetAllPoints();

        editBox.scrollFrame = scrollFrame;
        editBox.panel = widget;

        for k, v in pairs(MultiLineBoxMethods) do
            widget[k] = v;
        end

        if text then
            editBox:SetText(text);
        end

        editBox:SetScript('OnCursorChanged', MultiLineBoxOnCursorChanged)
        editBox:SetScript('OnTextChanged', MultiLineBoxOnTextChanged);

        scrollFrame:HookScript('OnMouseDown', MultiLineBoxScrollOnMouseDown);
        scrollFrame:HookScript('OnVerticalScroll', MultiLineBoxScrollOnVerticalScroll);

        widget.SetText = widget.SetValue;
        widget.GetText = widget.GetValue;

        return widget;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Label', 3;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    ----------------------------------------------------
    --- FontString
    ----------------------------------------------------

    local FontStringMethods = {
        SetFontSize = function(self, newSize)
            self:SetFont(self:GetFont(), newSize);
        end
    }

    --- @return FontString
    function StdUi:FontString(parent, text, inherit)
        local fs = parent:CreateFontString(nil, self.config.font.strata, inherit or 'GameFontNormal');

        fs:SetText(text);
        fs:SetJustifyH("LEFT");
        fs:SetJustifyV("MIDDLE");

        for k, v in pairs(FontStringMethods) do
            fs[k] = v;
        end

        return fs;
    end

    ----------------------------------------------------
    --- Label
    ----------------------------------------------------

    --- @return FontString
    function StdUi:Label(parent, text, size, inherit, width, height)
        local fs = self:FontString(parent, text, inherit);
        if size then
            fs:SetFontSize(size);
        end

        self:SetTextColor(fs, 'normal');
        self:SetObjSize(fs, width, height);

        return fs;
    end

    ----------------------------------------------------
    --- Header
    ----------------------------------------------------

    --- @return FontString
    function StdUi:Header(parent, text, size, inherit, width, height)
        local fs = self:Label(parent, text, size, inherit or 'GameFontNormalLarge', width, height);

        self:SetTextColor(fs, 'header');

        return fs;
    end

    ----------------------------------------------------
    --- AddLabel
    ----------------------------------------------------

    --- @return FontString
    function StdUi:AddLabel(parent, object, text, labelPosition, labelWidth)
        local labelHeight = (self.config.font.size) + 4;
        local label = self:Label(parent, text, self.config.font.size, nil, labelWidth, labelHeight);

        if labelPosition == 'TOP' or labelPosition == nil then
            self:GlueAbove(label, object, 0, 4, 'LEFT');
        elseif labelPosition == 'RIGHT' then
            self:GlueRight(label, object, 4, 0);
        else -- labelPosition == 'LEFT'
            label:SetWidth(labelWidth or label:GetStringWidth())
            self:GlueLeft(label, object, -4, 0);
        end

        object.label = label;

        return label;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'ProgressBar', 3;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    ----------------------------------------------------
    --- ProgressBar
    ----------------------------------------------------

    local ProgressBarMethods = {
        GetPercentageValue = function(self)
            local _, max = self:GetMinMaxValues();
            local value = self:GetValue();
            return (value / max) * 100;
        end,

        TextUpdate = function(self) -- min, max, value
            return Round(self:GetPercentageValue()) .. '%';
        end
    };

    local ProgressBarEvents = {
        OnValueChanged = function(self, value)
            local min, max = self:GetMinMaxValues();
            self.text:SetText(self:TextUpdate(min, max, value));
        end,

        OnMinMaxChanged = function(self)
            local min, max = self:GetMinMaxValues();
            local value = self:GetValue();
            self.text:SetText(self:TextUpdate(min, max, value));
        end
    }

    --- @return StatusBar
    function StdUi:ProgressBar(parent, width, height, vertical)
        vertical = vertical or false;

        local progressBar = CreateFrame('StatusBar', nil, parent);
        progressBar:SetStatusBarTexture(self.config.backdrop.texture);
        progressBar:SetStatusBarColor(
            self.config.progressBar.color.r,
            self.config.progressBar.color.g,
            self.config.progressBar.color.b,
            self.config.progressBar.color.a
        );
        self:SetObjSize(progressBar, width, height);

        progressBar.texture = progressBar:GetRegions();
        progressBar.texture:SetDrawLayer('BORDER', -1);

        if (vertical) then
            progressBar:SetOrientation('VERTICAL');
        end

        progressBar.text = self:Label(progressBar, '');
        progressBar.text:SetJustifyH("CENTER");
        progressBar.text:SetAllPoints();

        self:ApplyBackdrop(progressBar);

        for k, v in pairs(ProgressBarMethods) do
            progressBar[k] = v;
        end

        for k, v in pairs(ProgressBarEvents) do
            progressBar:SetScript(k, v);
        end

        return progressBar;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Scroll', 6;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local round = function(num)
        return math.floor(num + .5);
    end

    ----------------------------------------------------
    --- ScrollFrame
    ----------------------------------------------------

    StdUi.ScrollBarEvents = {

        UpDownButtonOnClick = function(self)
            local scrollBar = self.scrollBar;
            local scrollFrame = scrollBar.scrollFrame;
            local scrollStep = scrollBar.scrollStep or (scrollFrame:GetHeight() / 2);

            if self.direction == 1 then
                scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
            else
                scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
            end
        end,

        OnValueChanged      = function(self, value)
            self.scrollFrame:SetVerticalScroll(value);
        end
    };

    StdUi.ScrollFrameEvents = {
        OnMouseWheel         = function(self, value, scrollBar)
            scrollBar = scrollBar or self.scrollBar;
            local scrollStep = scrollBar.scrollStep or scrollBar:GetHeight() / 2;

            if value > 0 then
                scrollBar:SetValue(scrollBar:GetValue() - scrollStep);
            else
                scrollBar:SetValue(scrollBar:GetValue() + scrollStep);
            end
        end,

        OnScrollRangeChanged = function(self, _, yRange)
            -- xRange
            local scrollbar = self.scrollBar;
            if not yRange then
                yRange = self:GetVerticalScrollRange();
            end

            -- Accounting for very small ranges
            yRange = math.floor(yRange);

            local value = math.min(scrollbar:GetValue(), yRange);
            scrollbar:SetMinMaxValues(0, yRange);
            scrollbar:SetValue(value);

            local scrollDownButton = scrollbar.ScrollDownButton;
            local scrollUpButton = scrollbar.ScrollUpButton;
            local thumbTexture = scrollbar.ThumbTexture;

            if yRange == 0 then
                if self.scrollBarHideable then
                    scrollbar:Hide();
                    scrollDownButton:Hide();
                    scrollUpButton:Hide();
                    thumbTexture:Hide();
                else
                    scrollDownButton:Disable();
                    scrollUpButton:Disable();
                    scrollDownButton:Show();
                    scrollUpButton:Show();
                    if (not self.noScrollThumb) then
                        thumbTexture:Show();
                    end
                end
            else
                scrollDownButton:Show();
                scrollUpButton:Show();
                scrollbar:Show();
                if not self.noScrollThumb then
                    thumbTexture:Show();
                end
                -- The 0.005 is to account for precision errors
                if yRange - value > 0.005 then
                    scrollDownButton:Enable();
                else
                    scrollDownButton:Disable();
                end
            end
        end,

        OnVerticalScroll     = function(self, offset)
            local scrollBar = self.scrollBar;
            scrollBar:SetValue(offset);

            local _, max = scrollBar:GetMinMaxValues();
            scrollBar.ScrollUpButton:SetEnabled(offset ~= 0);
            scrollBar.ScrollDownButton:SetEnabled((scrollBar:GetValue() - max) ~= 0);
        end
    }

    StdUi.ScrollFrameMethods = {
        SetScrollStep  = function(self, scrollStep)
            scrollStep = round(scrollStep);
            self.scrollBar.scrollStep = scrollStep;
            self.scrollBar:SetValueStep(scrollStep);
        end,

        GetChildFrames = function(self)
            return self.scrollBar, self.scrollChild, self.scrollBar.ScrollUpButton, self.scrollBar.ScrollDownButton;
        end,

        UpdateSize     = function(self, newWidth, newHeight)
            self:SetSize(newWidth, newHeight);
            self.scrollFrame:ClearAllPoints();

            -- scrollbar width and margins
            self.scrollFrame:SetSize(newWidth - self.scrollBarWidth - 5, newHeight - 4);
            self.stdUi:GlueAcross(self.scrollFrame, self, 2, -2, -self.scrollBarWidth - 2, 2);

            -- panel of scrollBar
            self.scrollBar.panel:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -2, -2);
            self.scrollBar.panel:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -2, 2);

            if self.scrollChild then
                self.scrollChild:SetWidth(self.scrollFrame:GetWidth());
                self.scrollChild:SetHeight(self.scrollFrame:GetHeight());
            end
        end
    };

    function StdUi:ScrollFrame(parent, width, height, scrollChild)
        local panel = self:Panel(parent, width, height);
        panel.stdUi = self;
        panel.offset = 0;
        panel.scrollBarWidth = 16;

        local scrollFrame = CreateFrame('ScrollFrame', nil, panel);
        local scrollBar = self:ScrollBar(panel, panel.scrollBarWidth);
        scrollBar:SetMinMaxValues(0, 0);
        scrollBar:SetValue(0);

        scrollBar:SetScript('OnValueChanged', self.ScrollBarEvents.OnValueChanged);
        scrollBar.ScrollUpButton.direction = 1;
        scrollBar.ScrollDownButton.direction = -1;
        scrollBar.ScrollDownButton:SetScript('OnClick', self.ScrollBarEvents.UpDownButtonOnClick);
        scrollBar.ScrollUpButton:SetScript('OnClick', self.ScrollBarEvents.UpDownButtonOnClick);
        scrollBar.ScrollDownButton:Disable();
        scrollBar.ScrollUpButton:Disable();

        if self.noScrollThumb then
            scrollBar.ThumbTexture:Hide();
        end

        scrollBar.scrollFrame = scrollFrame;
        scrollFrame.scrollBar = scrollBar;
        scrollFrame.panel = panel;

        panel.scrollBar = scrollBar;
        panel.scrollFrame = scrollFrame;

        for k, v in pairs(self.ScrollFrameMethods) do
            panel[k] = v;
        end

        for k, v in pairs(self.ScrollFrameEvents) do
            scrollFrame:SetScript(k, v);
        end

        if not scrollChild then
            scrollChild = CreateFrame('Frame', nil, scrollFrame);
            scrollChild:SetWidth(scrollFrame:GetWidth());
            scrollChild:SetHeight(scrollFrame:GetHeight());
        else
            scrollChild:SetParent(scrollFrame);
        end
        panel.scrollChild = scrollChild;

        panel:UpdateSize(width, height);

        scrollFrame:SetScrollChild(scrollChild);
        scrollFrame:EnableMouse(true);
        scrollFrame:SetClampedToScreen(true);
        scrollFrame:SetClipsChildren(true);

        scrollChild:SetPoint('RIGHT', scrollFrame, 'RIGHT', 0, 0);

        scrollFrame.scrollChild = scrollChild;

        return panel;
    end

    ----------------------------------------------------
    --- FauxScrollFrame
    ----------------------------------------------------

    StdUi.FauxScrollFrameMethods = {
        GetOffset        = function(self)
            return self.offset or 0;
        end,

        --- Performs vertical scroll
        DoVerticalScroll = function(self, value, itemHeight, updateFunction)
            local scrollBar = self.scrollBar;
            itemHeight = itemHeight or self.lineHeight;

            scrollBar:SetValue(value);
            self.offset = floor((value / itemHeight) + 0.5);

            if updateFunction then
                updateFunction(self);
            end
        end,

        --- Redraws items in case of manual update from outside without changing parameters
        Redraw           = function(self)
            self:Update(
                self.itemCount or #self.scrollChild.items,
                self.displayCount,
                self.lineHeight
            );
        end,

        UpdateItemsCount = function(self, newCount)
            self.itemCount = newCount;
            self:Update(
                newCount,
                self.displayCount,
                self.lineHeight
            );
        end,

        Update           = function(self, numItems, numToDisplay, buttonHeight)
            local scrollBar, scrollChildFrame, scrollUpButton, scrollDownButton = self:GetChildFrames();

            local showScrollBar;
            if numItems == nil or numToDisplay == nil then
                return;
            end

            if numItems > numToDisplay then
                showScrollBar = 1;
            else
                scrollBar:SetValue(0);
            end

            if self:IsShown() then
                local scrollFrameHeight = 0;
                local scrollChildHeight = 0;

                if numItems > 0 then
                    scrollFrameHeight = (numItems - numToDisplay) * buttonHeight;
                    scrollChildHeight = numItems * buttonHeight;
                    if (scrollFrameHeight < 0) then
                        scrollFrameHeight = 0;
                    end
                    scrollChildFrame:Show();
                else
                    scrollChildFrame:Hide();
                end

                local maxRange = (numItems - numToDisplay) * buttonHeight;
                if maxRange < 0 then
                    maxRange = 0;
                end

                scrollBar:SetMinMaxValues(0, maxRange);
                self:SetScrollStep(buttonHeight);
                scrollBar:SetStepsPerPage(numToDisplay - 1);
                scrollChildFrame:SetHeight(scrollChildHeight);

                -- Arrow button handling
                if scrollBar:GetValue() == 0 then
                    scrollUpButton:Disable();
                else
                    scrollUpButton:Enable();
                end

                if (scrollBar:GetValue() - scrollFrameHeight) == 0 then
                    scrollDownButton:Disable();
                else
                    scrollDownButton:Enable();
                end
            end

            return showScrollBar;
        end,
    };

    local OnVerticalScrollUpdate = function(self)
        self:Redraw();
    end;

    StdUi.FauxScrollFrameEvents = {
        OnVerticalScroll = function(self, value)
            value = round(value);
            local panel = self.panel;

            panel:DoVerticalScroll(
                value,
                panel.lineHeight,
                OnVerticalScrollUpdate
            );
        end
    };

    --- Works pretty much the same as scroll frame however it does not have smooth scroll and only display a certain amount
    --- of items
    function StdUi:FauxScrollFrame(parent, width, height, displayCount, lineHeight, scrollChild)
        local panel = self:ScrollFrame(parent, width, height, scrollChild);

        panel.lineHeight = lineHeight;
        panel.displayCount = displayCount;

        for k, v in pairs(self.FauxScrollFrameMethods) do
            panel[k] = v;
        end

        for k, v in pairs(self.FauxScrollFrameEvents) do
            panel.scrollFrame:SetScript(k, v);
        end

        return panel;
    end

    ----------------------------------------------------
    --- HybridScrollFrame
    ----------------------------------------------------
    StdUi.HybridScrollFrameMethods = {
        Update                = function(self, totalHeight)
            local range = floor(totalHeight - self.scrollChild:GetHeight() + 0.5);

            if range > 0 and self.scrollBar then
                local _, maxVal = self.scrollBar:GetMinMaxValues();

                if math.floor(self.scrollBar:GetValue()) >= math.floor(maxVal) then
                    self.scrollBar:SetMinMaxValues(0, range);

                    if range < maxVal then
                        if math.floor(self.scrollBar:GetValue()) ~= math.floor(range) then
                            self.scrollBar:SetValue(range);
                        else
                            -- If we've scrolled to the bottom, we need to recalculate the offset.
                            self:SetOffset(self, range);
                        end
                    end
                else
                    self.scrollBar:SetMinMaxValues(0, range)
                end

                self.scrollBar:Enable();
                self:UpdateScrollBarState();
                self.scrollBar:Show();
            elseif self.scrollBar then
                self.scrollBar:SetValue(0);
                if self.scrollBar.doNotHide then
                    self.scrollBar:Disable();
                    self.scrollBar.ScrollUpButton:Disable();
                    self.scrollBar.ScrollDownButton:Disable();
                    self.scrollBar.ThumbTexture:Hide();
                else
                    self.scrollBar:Hide();
                end
            end

            self.range = range;
            self.totalHeight = totalHeight;
            self.scrollFrame:UpdateScrollChildRect();
        end,

        SetData               = function(self, data)
            self.data = data;
        end,

        SetUpdateFunction     = function(self, updateFn)
            self.updateFn = updateFn;
        end,

        UpdateScrollBarState  = function(self, currValue)
            if not currValue then
                currValue = self.scrollBar:GetValue();
            end

            self.scrollBar.ScrollUpButton:Enable();
            self.scrollBar.ScrollDownButton:Enable();

            local minVal, maxVal = self.scrollBar:GetMinMaxValues();
            if currValue >= maxVal then
                self.scrollBar.ThumbTexture:Show();
                if self.scrollBar.ScrollDownButton then
                    self.scrollBar.ScrollDownButton:Disable()
                end
            end

            if currValue <= minVal then
                self.scrollBar.ThumbTexture:Show();
                if self.scrollBar.ScrollUpButton then
                    self.scrollBar.ScrollUpButton:Disable();
                end
            end
        end,

        GetOffset             = function(self)
            return math.floor(self.offset or 0), (self.offset or 0);
        end,

        SetOffset             = function(self, offset)
            local items = self.items;
            local itemHeight = self.itemHeight;
            local element, overflow;

            local scrollHeight = 0;

            if self.dynamic then
                --This is for frames where items will have different heights
                if offset < itemHeight then
                    -- a little optimization
                    element, scrollHeight = 0, offset;
                else
                    element, scrollHeight = self.dynamic(offset);
                end
            else
                element = offset / itemHeight;
                overflow = element - math.floor(element);
                scrollHeight = overflow * itemHeight;
            end

            if math.floor(self.offset or 0) ~= math.floor(element) and self.updateFn then
                self.offset = element;
                self:UpdateItems();
            else
                self.offset = element;
            end

            self.scrollFrame:SetVerticalScroll(scrollHeight);
        end,

        CreateItems           = function(self, data, create, update, padding, oX, oY)
            local scrollChild = self.scrollChild;
            local itemHeight = 0;
            local numItems = #data;
            --initialPoint = initialPoint or 'TOPLEFT';
            --initialRelative = initialRelative or 'TOPLEFT';
            --point = point or 'TOPLEFT';
            --relativePoint = relativePoint or 'BOTTOMLEFT';
            --offsetX = offsetX or 0;
            --offsetY = offsetY or 0;

            if not self.items then
                self.items = {};
            end

            self.data = data;
            self.createFn = create;
            self.updateFn = update;
            self.itemPadding = padding;

            self.stdUi:ObjectList(scrollChild, self.items, create, update, data, padding, oX, oY,
                function(i, totalHeight, lih)
                    return totalHeight > self:GetHeight() + lih;
                end);

            if self.items[1] then
                itemHeight = round(self.items[1]:GetHeight() + padding);
            end
            self.itemHeight = itemHeight;

            local totalHeight = numItems * itemHeight;
            self.scrollFrame:SetVerticalScroll(0);

            local scrollBar = self.scrollBar;
            scrollBar:SetMinMaxValues(0, totalHeight);
            scrollBar.itemHeight = itemHeight;
            self:SetScrollStep(itemHeight / 2);

            -- one additional item was added above. Need to remove that,
            -- and one more to make the current bottom the new top (and vice versa)
            scrollBar:SetStepsPerPage(numItems - 2);
            scrollBar:SetValue(0);

            self:Update(totalHeight);
        end,

        UpdateItems           = function(self)
            local count = #self.data;

            local offset = self:GetOffset();
            local items = self:GetItems();

            for i = 1, #items do
                local item = items[i];

                local index = offset + i;
                if index <= count then
                    self.updateFn(self.scrollChild, item, self.data[index], index, i);
                end
            end

            local firstButton = items[1];
            local totalHeight = 0;
            if firstButton then
                totalHeight = count * (firstButton:GetHeight() + self.itemPadding);
            end

            self:Update(totalHeight, self:GetHeight());
        end,

        GetItems              = function(self)
            return self.items;
        end,

        SetDoNotHideScrollBar = function(self, doNotHide)
            if not self.scrollBar or self.scrollBar.doNotHide == doNotHide then
                return;
            end

            self.scrollBar.doNotHide = doNotHide;
            self:Update(self.totalHeight or 0, self.scrollChild:GetHeight());
        end,

        ScrollToIndex         = function(self, index, getHeightFunc)
            local totalHeight = 0;
            local scrollFrameHeight = self:GetHeight();

            for i = 1, index do
                local entryHeight = getHeightFunc(i);

                if i == index then
                    local offset = 0;

                    -- we don't need to do anything if the entry is fully displayed with the scroll all the way up
                    if totalHeight + entryHeight > scrollFrameHeight then
                        if (entryHeight > scrollFrameHeight) then
                            -- this entry is larger than the entire scrollframe, put it at the top
                            offset = totalHeight;
                        else
                            -- otherwise place it in the center
                            local diff = scrollFrameHeight - entryHeight;
                            offset = totalHeight - diff / 2;
                        end

                        -- because of valuestep our positioning might change
                        -- we'll do the adjustment ourselves to make sure the entry ends up above the center rather than below
                        local valueStep = self.scrollBar:GetValueStep();
                        offset = offset + valueStep - mod(offset, valueStep);

                        -- but if we ended up moving the entry so high up that its top is not visible, move it back down
                        if offset > totalHeight then
                            offset = offset - valueStep;
                        end
                    end

                    self.scrollBar:SetValue(offset);
                    break;
                end

                totalHeight = totalHeight + entryHeight;
            end
        end
    };

    local HybridScrollBarOnValueChanged = function(self, value)
        local widget = self.scrollFrame.panel;
        value = round(value);
        widget:SetOffset(value);
        widget:UpdateScrollBarState(value);
    end

    function StdUi:HybridScrollFrame(parent, width, height, scrollChild)
        local panel = self:ScrollFrame(parent, width, height, scrollChild);

        panel.scrollBar:SetScript('OnValueChanged', HybridScrollBarOnValueChanged);

        panel.scrollFrame:SetScript('OnScrollRangeChanged', nil);
        panel.scrollFrame:SetScript('OnVerticalScroll', nil);

        for k, v in pairs(self.HybridScrollFrameMethods) do
            panel[k] = v;
        end

        --for k, v in pairs(self.HybridScrollFrameEvents) do
        --	panel.scrollFrame:SetScript(k, v);
        --end


        return panel;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'ScrollTable', 6;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local TableInsert = tinsert;
    local TableSort = table.sort;
    local padding = 2.5;

    --- Public methods of ScrollTable
    local methods = {

        -------------------------------------------------------------
        --- Basic Methods
        -------------------------------------------------------------

        SetAutoHeight        = function(self)
            self:SetHeight((self.numberOfRows * self.rowHeight) + 10);
            self:Refresh();
        end,

        SetAutoWidth         = function(self)
            local width = 13;
            for _, col in pairs(self.columns) do
                width = width + col.width;
            end
            self:SetWidth(width + 20);
            self:Refresh();
        end,

        ScrollToLine         = function(self, line)
            line = Clamp(line, 1, #self.filtered - self.numberOfRows + 1);

            self:DoVerticalScroll(
                self.rowHeight * (line - 1),
                self.rowHeight, function(s)
                    s:Refresh();
                end
            );
        end,

        -------------------------------------------------------------
        --- Drawing Methods
        -------------------------------------------------------------

        --- Set the column info for the scrolling table
        --- @usage st:SetColumns(columns)
        SetColumns           = function(self, columns)
            local table = self; -- reference saved for closure
            self.columns = columns;

            local columnHeadFrame = self.head;

            if not columnHeadFrame then
                columnHeadFrame = CreateFrame('Frame', nil, self);
                columnHeadFrame:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 4, 0);
                columnHeadFrame:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -4, 0);
                columnHeadFrame:SetHeight(self.rowHeight);
                columnHeadFrame.columns = {};
                self.head = columnHeadFrame;
            end

            for i = 1, #columns do
                local column = self.columns[i];
                local columnFrame = columnHeadFrame.columns[i];
                if not columnHeadFrame.columns[i] then
                    columnFrame = self.stdUi:HighlightButton(columnHeadFrame);
                    columnFrame:SetPushedTextOffset(0, 0);

                    columnFrame.arrow = self.stdUi:Texture(columnFrame, 8, 8, [[Interface\Buttons\UI-SortArrow]]);
                    columnFrame.arrow:Hide();

                    if self.headerEvents then
                        for event, handler in pairs(self.headerEvents) do
                            columnFrame:SetScript(event, function(cellFrame, ...)
                                table:FireHeaderEvent(event, handler, columnFrame, columnHeadFrame, i, ...);
                            end);
                        end
                    end

                    columnHeadFrame.columns[i] = columnFrame;

                    -- Add column head reference to it's column
                    column.head = columnFrame;

                    -- Create a table of empty column cell references
                    column.cells = {};
                end

                local align = columns[i].align or "LEFT";
                -- TODO : fix it properly;
                columnFrame.text:SetJustifyH("LEFT"); -- should be align

                columnFrame.text:SetText(columns[i].name);

                if align == 'LEFT' then
                    columnFrame.arrow:ClearAllPoints();
                    self.stdUi:GlueRight(columnFrame.arrow, columnFrame, 0, 0, true);
                else
                    columnFrame.arrow:ClearAllPoints();
                    self.stdUi:GlueLeft(columnFrame.arrow, columnFrame, 5, 0, true);
                end

                if columns[i].sortable == false and columns[i].sortable ~= nil then

                else

                end

                if i > 1 then
                    columnFrame:SetPoint('LEFT', columnHeadFrame.columns[i - 1], 'RIGHT', 0, 0);
                else
                    columnFrame:SetPoint('LEFT', columnHeadFrame, 'LEFT', 2, 0);
                end

                columnFrame:SetHeight(self.rowHeight);
                columnFrame:SetWidth(columns[i].width);

                --- Set the width of a column
                --- @usage st.columns[i]:SetWidth(width)
                function column:SetWidth(width)
                    -- Update the column's width value
                    column.width = width;

                    -- Set the width of the column's head
                    column.head:SetWidth(width);

                    -- Set the width of each cell in the column
                    for j = 1, #column.cells do
                        column.cells[j]:SetWidth(width)
                    end
                end
            end

            self:SetDisplayRows(self.numberOfRows, self.rowHeight);
            self:SetAutoWidth();
        end,

        --- Set the number and height of displayed rows
        --- @usage st:SetDisplayRows(10, 15)
        SetDisplayRows       = function(self, numberOfRows, rowHeight)
            local table = self; -- reference saved for closure
            -- should always set columns first
            self.numberOfRows = numberOfRows;
            self.rowHeight = rowHeight;

            if not self.rows then
                self.rows = {};
            end

            for i = 1, numberOfRows do
                local rowFrame = self.rows[i];

                if not rowFrame then
                    rowFrame = CreateFrame('Button', nil, self);
                    self.rows[i] = rowFrame;

                    if i > 1 then
                        rowFrame:SetPoint('TOPLEFT', self.rows[i - 1], 'BOTTOMLEFT', 0, 0);
                        rowFrame:SetPoint('TOPRIGHT', self.rows[i - 1], 'BOTTOMRIGHT', 0, 0);
                    else
                        rowFrame:SetPoint('TOPLEFT', self.scrollFrame, 'TOPLEFT', 1, -1);
                        rowFrame:SetPoint('TOPRIGHT', self.scrollFrame, 'TOPRIGHT', -1, -1);
                    end

                    rowFrame:SetHeight(rowHeight);
                end

                if not rowFrame.columns then
                    rowFrame.columns = {};
                end

                for j = 1, #self.columns do
                    local columnData = self.columns[j];

                    local cell = rowFrame.columns[j];
                    if not cell then
                        cell = CreateFrame('Button', nil, rowFrame);
                        cell.text = self.stdUi:FontString(cell, '');

                        rowFrame.columns[j] = cell;

                        -- Add cell reference to column
                        self.columns[j].cells[i] = cell;

                        local align = columnData.align or 'LEFT';

                        --cell.text:SetJustifyH(align); TODO FIX PROPERLY
                        cell.text:SetJustifyH("LEFT");
                        cell:EnableMouse(true);
                        cell:RegisterForClicks('AnyUp');

                        if self.cellEvents then
                            for event, handler in pairs(self.cellEvents) do
                                cell:SetScript(event, function(cellFrame, ...)
                                    if table.offset then
                                        local rowIndex = table.filtered[i + table.offset];
                                        local rowData = table:GetRow(rowIndex);
                                        table:FireCellEvent(event, handler, cellFrame, rowFrame, rowData, columnData,
                                            rowIndex, ...);
                                    end
                                end);
                            end
                        end

                        -- override a column based events
                        if columnData.events then
                            for event, handler in pairs(columnData.events) do
                                cell:SetScript(event, function(cellFrame, ...)
                                    if table.offset then
                                        local rowIndex = table.filtered[i + table.offset];
                                        local rowData = table:GetRow(rowIndex);
                                        table:FireCellEvent(event, handler, cellFrame, rowFrame, rowData, columnData,
                                            rowIndex, ...);
                                    end
                                end);
                            end
                        end
                    end

                    if j > 1 then
                        cell:SetPoint('LEFT', rowFrame.columns[j - 1], 'RIGHT', 0, 0);
                    else
                        cell:SetPoint('LEFT', rowFrame, 'LEFT', 2, 0);
                    end

                    cell:SetHeight(rowHeight);
                    cell:SetWidth(self.columns[j].width);

                    cell.text:SetPoint('TOP', cell, 'TOP', 0, 0);
                    cell.text:SetPoint('BOTTOM', cell, 'BOTTOM', 0, 0);
                    cell.text:SetWidth(self.columns[j].width - 2 * padding);
                end

                local j = #self.columns + 1;
                local col = rowFrame.columns[j];
                while col do
                    col:Hide();
                    j = j + 1;
                    col = rowFrame.columns[j];
                end
            end

            for i = numberOfRows + 1, #self.rows do
                self.rows[i]:Hide();
            end

            self:SetAutoHeight();
        end,

        --- Set the width of a column
        --- @usage st:SetColumnWidth(2, 65)
        SetColumnWidth       = function(self, columnNumber, width)
            self.columns[columnNumber]:SetWidth(width);
        end,

        -------------------------------------------------------------
        --- Sorting Methods
        -------------------------------------------------------------

        --- Resorts the table using the rules specified in the table column info.
        --- @usage st:SortData()
        SortData             = function(self, sortBy)
            -- sanity check
            if not (self.sortTable) or (#self.sortTable ~= #self.data) then
                self.sortTable = {};
            end

            if #self.sortTable ~= #self.data then
                for i = 1, #self.data do
                    self.sortTable[i] = i;
                end
            end

            -- go on sorting
            if not sortBy then
                local i = 1;
                while i <= #self.columns and not sortBy do
                    if self.columns[i].sort then
                        sortBy = i;
                    end
                    i = i + 1;
                end
            end

            if sortBy then
                TableSort(self.sortTable, function(rowA, rowB)
                    local column = self.columns[sortBy];
                    if column.compareSort then
                        return column.compareSort(self, rowA, rowB, sortBy);
                    else
                        return self:CompareSort(rowA, rowB, sortBy);
                    end
                end);
            end

            self.filtered = self:DoFilter();
            self:Refresh();
            self:UpdateSortArrows(sortBy);
        end,

        --- CompareSort function used to determine how to sort column values. Can be overridden in column data or table data.
        --- @usage used internally.
        CompareSort          = function(self, rowA, rowB, sortBy)
            local a = self:GetRow(rowA);
            local b = self:GetRow(rowB);
            local column = self.columns[sortBy];
            local idx = column.index;

            local direction = column.sort or column.defaultSort or 'asc';

            if direction:lower() == 'asc' then
                return a[idx] > b[idx];
            else
                return a[idx] < b[idx];
            end
        end,

        Filter               = function(self, rowData)
            return true;
        end,

        --- Set a display filter for the table.
        --- @usage st:SetFilter( function (self, ...) return true end )
        SetFilter            = function(self, filter, noSort)
            self.Filter = filter;
            if not noSort then
                self:SortData();
            end
        end,

        DoFilter             = function(self)
            local result = {};

            for row = 1, #self.data do
                local realRow = self.sortTable[row];
                local rowData = self:GetRow(realRow);

                if self:Filter(rowData) then
                    TableInsert(result, realRow);
                end
            end

            return result;
        end,

        -------------------------------------------------------------
        --- Highlight Methods
        -------------------------------------------------------------

        --- Set the row highlight color of a frame ( cell or row )
        --- @usage st:SetHighLightColor(rowFrame, color)
        SetHighLightColor    = function(self, frame, color)
            if not frame.highlight then
                frame.highlight = frame:CreateTexture(nil, 'OVERLAY');
                frame.highlight:SetAllPoints(frame);
            end

            if not color then
                frame.highlight:SetColorTexture(0, 0, 0, 0);
            else
                frame.highlight:SetColorTexture(color.r, color.g, color.b, color.a);
            end
        end,

        ClearHighlightedRows = function(self)
            self.highlightedRows = {};
            self:Refresh();
        end,

        HighlightRows        = function(self, rowIndexes)
            self.highlightedRows = rowIndexes;
            self:Refresh();
        end,

        -------------------------------------------------------------
        --- Selection Methods
        -------------------------------------------------------------

        --- Turn on or off selection on a table according to flag. Will not refresh the table display.
        --- @usage st:EnableSelection(true)
        EnableSelection      = function(self, flag)
            self.selectionEnabled = flag;
        end,

        --- Clear the currently selected row. You should not need to refresh the table.
        --- @usage st:ClearSelection()
        ClearSelection       = function(self)
            self:SetSelection(nil);
        end,

        --- Sets the currently selected row to 'realRow'. RealRow is the unaltered index of the data row in your table.
        --- You should not need to refresh the table.
        --- @usage st:SetSelection(12)
        SetSelection         = function(self, rowIndex)
            self.selected = rowIndex;
            self:Refresh();
        end,

        --- Gets the currently selected row.
        --- Return will be the unaltered index of the data row that is selected.
        --- @usage st:GetSelection()
        GetSelection         = function(self)
            return self.selected;
        end,

        --- Gets the currently selected row.
        --- Return will be the unaltered index of the data row that is selected.
        --- @usage st:GetSelection()
        GetSelectedItem      = function(self)
            return self:GetRow(self.selected);
        end,

        -------------------------------------------------------------
        --- Data Methods
        -------------------------------------------------------------

        --- Sets the data for the scrolling table
        --- @usage st:SetData(datatable)
        SetData              = function(self, data)
            self.data = data;
            self:SortData();
        end,

        --- Returns the data row of the table from the given data row index
        --- @usage used internally.
        GetRow               = function(self, rowIndex)
            return self.data[rowIndex];
        end,

        --- Returns the cell data of the given row from the given row and column index
        --- @usage used internally.
        GetCell              = function(self, row, col)
            local rowData = row;
            if type(row) == 'number' then
                rowData = self:GetRow(row);
            end

            return rowData[col];
        end,

        --- Checks if a row is currently being shown
        --- @usage st:IsRowVisible(realrow)
        --- @thanks sapu94
        IsRowVisible         = function(self, rowIndex)
            return (rowIndex > self.offset and rowIndex <= (self.numberOfRows + self.offset));
        end,

        -------------------------------------------------------------
        --- Update Internal Methods
        -------------------------------------------------------------

        --- Cell update function used to paint each cell.  Can be overridden in column data or table data.
        --- @usage used internally.
        DoCellUpdate         = function(table, shouldShow, rowFrame, cellFrame, value, columnData, rowData, rowIndex)
            if shouldShow then
                local format = columnData.format;

                if type(format) == 'function' then
                    cellFrame.text:SetText(format(value, rowData, columnData));
                elseif format == 'money' then
                    value = table.stdUi.Util.formatMoney(value);
                    cellFrame.text:SetText(value);
                elseif format == 'moneyShort' then
                    value = table.stdUi.Util.formatMoney(value, true);
                    cellFrame.text:SetText(value);
                elseif format == 'number' then
                    value = tostring(value);
                    cellFrame.text:SetText(value);
                elseif format == 'icon' then
                    if cellFrame.texture then
                        cellFrame.texture:SetTexture(value);
                    else
                        local iconSize = columnData.iconSize or table.rowHeight;
                        cellFrame.texture = table.stdUi:Texture(cellFrame, iconSize, iconSize, value);
                        cellFrame.texture:SetPoint('CENTER', 0, 0);
                    end
                elseif format == 'custom' then
                    columnData.renderer(cellFrame, value, rowData, columnData);
                else
                    cellFrame.text:SetText(value);
                end

                local color;
                if rowData.color then
                    color = rowData.color;
                elseif columnData.color then
                    color = columnData.color;
                end

                if type(color) == 'function' then
                    color = color(table, value, rowData, columnData);
                end

                if color then
                    cellFrame.text:SetTextColor(color.r, color.g, color.b, color.a);
                else
                    table.stdUi:SetTextColor(cellFrame.text, 'normal');
                end

                if table.selectionEnabled then
                    if table.selected == rowIndex then
                        table:SetHighLightColor(rowFrame, table.stdUi.config.highlight.color);
                    else
                        table:SetHighLightColor(rowFrame, nil);
                    end
                else
                    if tContains(table.highlightedRows, rowIndex) then
                        table:SetHighLightColor(rowFrame, table.stdUi.config.highlight.color);
                    else
                        table:SetHighLightColor(rowFrame, nil);
                    end
                end
            else
                cellFrame.text:SetText('');
            end
        end,

        Refresh              = function(self)
            self:Update(#self.filtered, self.numberOfRows, self.rowHeight);

            local o = self:GetOffset();
            self.offset = o;

            for i = 1, self.numberOfRows do
                local row = i + o;

                if self.rows then
                    local rowFrame = self.rows[i];

                    local rowIndex = self.filtered[row];
                    local rowData = self:GetRow(rowIndex);
                    local shouldShow = true;

                    for col = 1, #self.columns do
                        local cellFrame = rowFrame.columns[col];
                        local columnData = self.columns[col];
                        local fnDoCellUpdate = self.DoCellUpdate;
                        local value;

                        if rowData then
                            value = rowData[columnData.index];

                            self.rows[i]:Show();

                            if rowData.doCellUpdate then
                                fnDoCellUpdate = rowData.doCellUpdate;
                            elseif columnData.doCellUpdate then
                                fnDoCellUpdate = columnData.doCellUpdate;
                            end
                        else
                            self.rows[i]:Hide();
                            shouldShow = false;
                        end

                        fnDoCellUpdate(self, shouldShow, rowFrame, cellFrame, value, columnData, rowData, rowIndex);
                    end
                end
            end
        end,

        -------------------------------------------------------------
        --- Private Methods
        -------------------------------------------------------------

        UpdateSortArrows     = function(self, sortBy)
            if not self.head then
                return
            end

            for i = 1, #self.columns do
                local col = self.head.columns[i];
                if col then
                    if i == sortBy then
                        local column = self.columns[sortBy];
                        local direction = column.sort or column.defaultSort or 'asc';
                        if direction == 'asc' then
                            col.arrow:SetTexCoord(0, 0.5625, 0, 1);
                        else
                            col.arrow:SetTexCoord(0, 0.5625, 1, 0);
                        end

                        col.arrow:Show();
                    else
                        col.arrow:Hide();
                    end
                end
            end
        end,

        FireCellEvent        = function(self, event, handler, ...)
            if not handler(self, ...) then
                if self.cellEvents[event] then
                    self.cellEvents[event](self, ...);
                end
            end
        end,

        FireHeaderEvent      = function(self, event, handler, ...)
            if not handler(self, ...) then
                if self.headerEvents[event] then
                    self.headerEvents[event](self, ...);
                end
            end
        end,

        --- Set the event handlers for various ui events for each cell.
        --- @usage st:RegisterEvents(events, true)
        RegisterEvents       = function(self, cellEvents, headerEvents, removeOldEvents)
            local table = self; -- save for closure later

            if cellEvents then
                -- Register events for each cell
                for i, rowFrame in ipairs(self.rows) do
                    for j, cell in ipairs(rowFrame.columns) do
                        local columnData = self.columns[j];

                        -- unregister old events.
                        if removeOldEvents and self.cellEvents then
                            for event, handler in pairs(self.cellEvents) do
                                cell:SetScript(event, nil);
                            end
                        end

                        -- register new ones.
                        for event, handler in pairs(cellEvents) do
                            cell:SetScript(event, function(cellFrame, ...)
                                local rowIndex = table.filtered[i + table.offset];
                                local rowData = table:GetRow(rowIndex);
                                table:FireCellEvent(event, handler, cellFrame, rowFrame, rowData, columnData,
                                    rowIndex, ...);
                            end);
                        end

                        -- override a column based events
                        if columnData.events then
                            for event, handler in pairs(self.columns[j].events) do
                                cell:SetScript(event, function(cellFrame, ...)
                                    if table.offset then
                                        local rowIndex = table.filtered[i + table.offset];
                                        local rowData = table:GetRow(rowIndex);
                                        table:FireCellEvent(event, handler, cellFrame, rowFrame, rowData, columnData,
                                            rowIndex, ...);
                                    end
                                end);
                            end
                        end
                    end
                end
            end

            if headerEvents then
                -- Register events on column headers
                for columnIndex, columnFrame in ipairs(self.head.columns) do
                    -- unregister old events.
                    if removeOldEvents and self.headerEvents then
                        for event, _ in pairs(self.headerEvents) do
                            columnFrame:SetScript(event, nil);
                        end
                    end

                    -- register new ones.
                    for event, handler in pairs(headerEvents) do
                        columnFrame:SetScript(event, function(cellFrame, ...)
                            table:FireHeaderEvent(event, handler, columnFrame, self.head, columnIndex, ...);
                        end);
                    end
                end
            end
        end,
    };

    local cellEvents = {
        OnEnter = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
            table:SetHighLightColor(rowFrame, table.stdUi.config.highlight.color);
            return true;
        end,

        OnLeave = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex)
            if rowIndex ~= table.selected or not table.selectionEnabled then
                table:SetHighLightColor(rowFrame, nil);
            end

            return true;
        end,

        OnClick = function(table, cellFrame, rowFrame, rowData, columnData, rowIndex, button)
            if button == 'LeftButton' then
                if table:GetSelection() == rowIndex then
                    table:ClearSelection();
                else
                    table:SetSelection(rowIndex);
                end

                return true;
            end
        end,
    };

    local headerEvents = {
        OnClick = function(table, columnFrame, columnHeadFrame, columnIndex, button, ...)
            if button == 'LeftButton' then
                local columns = table.columns;
                local column = columns[columnIndex];

                -- clear sort for other columns
                for i, _ in ipairs(columnHeadFrame.columns) do
                    if i ~= columnIndex then
                        columns[i].sort = nil;
                    end
                end

                local sortOrder = 'asc';

                if not column.sort and column.defaultSort then
                    -- sort by columns default sort first;
                    sortOrder = column.defaultSort;
                elseif column.sort and column.sort:lower() == 'asc' then
                    sortOrder = 'dsc';
                end

                column.sort = sortOrder;
                table:SortData();

                return true;
            end
        end
    };

    local ScrollTableUpdateFn = function(self)
        self:Refresh();
    end

    local ScrollTableOnVerticalScroll = function(self, offset)
        local scrollTable = self.panel;
        -- LS: putting st:Refresh() in a function call passes the st as the 1st arg which lets you
        -- reference the st if you decide to hook the refresh
        scrollTable:DoVerticalScroll(offset, scrollTable.rowHeight, ScrollTableUpdateFn);
    end

    function StdUi:ScrollTable(parent, columns, numRows, rowHeight)
        local scrollTable = self:FauxScrollFrame(parent, 100, 100, rowHeight or 15);
        local scrollFrame = scrollTable.scrollFrame;

        scrollTable.stdUi = self;
        scrollTable.numberOfRows = numRows or 12;
        scrollTable.rowHeight = rowHeight or 15;
        scrollTable.columns = columns;
        scrollTable.data = {};
        scrollTable.cellEvents = cellEvents;
        scrollTable.headerEvents = headerEvents;
        scrollTable.highlightedRows = {};

        -- Add all methods
        for methodName, method in pairs(methods) do
            scrollTable[methodName] = method;
        end

        scrollFrame:SetScript('OnVerticalScroll', ScrollTableOnVerticalScroll);
        scrollTable:SortData();
        scrollTable:SetColumns(scrollTable.columns);
        scrollTable:UpdateSortArrows();
        scrollTable:RegisterEvents(scrollTable.cellEvents, scrollTable.headerEvents);
        -- no need to assign it once again and override all column events

        return scrollTable;
    end

    StdUi:RegisterModule(module, version);

    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Slider', 7;
    if not StdUi:UpgradeNeeded(module, version) then return end

    ----------------------------------------------------
    --- SliderButton
    ----------------------------------------------------

    function StdUi:SliderButton(parent, width, height, direction)
        local button = self:Button(parent, width, height);

        local texture = self:ArrowTexture(button, direction);
        texture:SetPoint('CENTER');

        local textureDisabled = self:ArrowTexture(button, direction);
        textureDisabled:SetPoint('CENTER');
        textureDisabled:SetDesaturated(0);

        button:SetNormalTexture(texture);
        button:SetDisabledTexture(textureDisabled);

        return button;
    end

    ----------------------------------------------------
    --- StyleScrollBar
    ----------------------------------------------------

    --- This is only useful for scrollBars not created using StdUi
    function StdUi:StyleScrollBar(scrollBar)
        local buttonUp, buttonDown = scrollBar:GetChildren();

        scrollBar.background = StdUi:Panel(scrollBar);
        scrollBar.background:SetFrameLevel(scrollBar:GetFrameLevel() - 1);
        scrollBar.background:SetWidth(scrollBar:GetWidth());
        self:GlueAcross(scrollBar.background, scrollBar, 0, 1, 0, -1);

        self:StripTextures(buttonUp);
        self:StripTextures(buttonDown);

        self:ApplyBackdrop(buttonUp, 'button');
        self:ApplyBackdrop(buttonDown, 'button');

        buttonUp:SetWidth(scrollBar:GetWidth());
        buttonDown:SetWidth(scrollBar:GetWidth());

        local upTex = self:ArrowTexture(buttonUp, 'UP');
        upTex:SetPoint('CENTER');

        local upTexDisabled = self:ArrowTexture(buttonUp, 'UP');
        upTexDisabled:SetPoint('CENTER');
        upTexDisabled:SetDesaturated(0);

        buttonUp:SetNormalTexture(upTex);
        buttonUp:SetDisabledTexture(upTexDisabled);

        local downTex = self:ArrowTexture(buttonDown, 'DOWN');
        downTex:SetPoint('CENTER');

        local downTexDisabled = self:ArrowTexture(buttonDown, 'DOWN');
        downTexDisabled:SetPoint('CENTER');
        downTexDisabled:SetDesaturated(0);

        buttonDown:SetNormalTexture(downTex);
        buttonDown:SetDisabledTexture(downTexDisabled);

        local thumbSize = scrollBar:GetWidth();
        scrollBar:GetThumbTexture():SetWidth(thumbSize);

        self:StripTextures(scrollBar);

        scrollBar.thumb = self:Panel(scrollBar);
        scrollBar.thumb:SetAllPoints(scrollBar:GetThumbTexture());
        self:ApplyBackdrop(scrollBar.thumb, 'button');
    end

    ----------------------------------------------------
    --- Slider
    ----------------------------------------------------

    local SliderMethods = {
        SetPrecision = function(self, numberOfDecimals)
            self.precision = numberOfDecimals;
        end,

        GetPrecision = function(self)
            return self.precision;
        end,

        GetValue = function(self)
            local minimum, maximum = self:GetMinMaxValues();
            return Clamp(StdUi.Util.roundPrecision(self:OriginalGetValue(), self.precision), minimum, maximum);
        end
    };

    local SliderEvents = {
        OnValueChanged = function(self, value, ...)
            if self.lock then return end
            self.lock = true;

            value = self:GetValue();

            if self.OnValueChanged then
                self:OnValueChanged(value, ...);
            end

            self.lock = false;
        end
    }

    function StdUi:Slider(parent, width, height, value, vertical, min, max)
        local slider = CreateFrame('Slider', nil, parent);
        self:InitWidget(slider);
        self:ApplyBackdrop(slider, 'panel');
        self:SetObjSize(slider, width, height);

        slider.vertical = vertical;
        slider.precision = 1;

        local thumbWidth = vertical and width or 20;
        local thumbHeight = vertical and 20 or height;

        slider.ThumbTexture = self:Texture(slider, thumbWidth, thumbHeight, self.config.backdrop.texture);
        slider.ThumbTexture:SetVertexColor(
            self.config.backdrop.slider.r,
            self.config.backdrop.slider.g,
            self.config.backdrop.slider.b,
            self.config.backdrop.slider.a
        );
        slider:SetThumbTexture(slider.ThumbTexture);

        slider.thumb = self:Frame(slider);
        slider.thumb:SetAllPoints(slider:GetThumbTexture());
        self:ApplyBackdrop(slider.thumb, 'button');

        if vertical then
            slider:SetOrientation('VERTICAL');
            slider.ThumbTexture:SetPoint('LEFT');
            slider.ThumbTexture:SetPoint('RIGHT');
        else
            slider:SetOrientation('HORIZONTAL');
            slider.ThumbTexture:SetPoint('TOP');
            slider.ThumbTexture:SetPoint('BOTTOM');
        end

        slider.OriginalGetValue = slider.GetValue;

        for k, v in pairs(SliderMethods) do
            slider[k] = v;
        end

        slider:SetMinMaxValues(min or 0, max or 100);
        slider:SetValue(value or min or 0);

        for k, v in pairs(SliderEvents) do
            slider:HookScript(k, v);
        end

        return slider;
    end

    ----------------------------------------------------
    --- SliderWithBox
    ----------------------------------------------------

    local SliderWithBoxMethods = {
        SetValue = function(self, v)
            self.lock = true;
            self.slider:SetValue(v);
            v = self.slider:GetValue();
            self.editBox:SetValue(v);
            self.value = v;
            self.lock = false;

            if self.OnValueChanged then
                self.OnValueChanged(self, v);
            end
        end,

        GetValue = function(self)
            return self.value;
        end,

        SetValueStep = function(self, step)
            self.slider:SetValueStep(step);
        end,

        SetPrecision = function(self, numberOfDecimals)
            self.slider.precision = numberOfDecimals;
        end,

        GetPrecision = function(self)
            return self.slider.precision;
        end,

        SetMinMaxValues = function(self, min, max)
            self.min = min;
            self.max = max;

            self.editBox:SetMinMaxValue(min, max);
            self.slider:SetMinMaxValues(min, max);
            self.leftLabel:SetText(min);
            self.rightLabel:SetText(max);
        end
    };

    local SliderWithBoxOnValueChanged = function(self, val)
        if self.widget.lock then return end;

        self.widget:SetValue(val);
    end

    function StdUi:SliderWithBox(parent, width, height, value, min, max)
        local widget = CreateFrame('Frame', nil, parent);
        self:SetObjSize(widget, width, height);

        widget.slider = self:Slider(widget, 100, 12, value, false);
        widget.editBox = self:NumericBox(widget, 80, 16, value);
        widget.value = value;
        widget.editBox:SetNumeric(false);
        widget.leftLabel = self:Label(widget, '');
        widget.rightLabel = self:Label(widget, '');

        widget.slider.widget = widget;
        widget.editBox.widget = widget;

        for k, v in pairs(SliderWithBoxMethods) do
            widget[k] = v;
        end

        if min and max then
            widget:SetMinMaxValues(min, max);
        end

        widget.slider.OnValueChanged = SliderWithBoxOnValueChanged;
        widget.editBox.OnValueChanged = SliderWithBoxOnValueChanged;

        widget.slider:SetPoint('TOPLEFT', widget, 'TOPLEFT', 0, 0);
        widget.slider:SetPoint('TOPRIGHT', widget, 'TOPRIGHT', 0, 0);
        self:GlueBelow(widget.editBox, widget.slider, 0, -5, 'CENTER');
        widget.leftLabel:SetPoint('TOPLEFT', widget.slider, 'BOTTOMLEFT', 0, 0);
        widget.rightLabel:SetPoint('TOPRIGHT', widget.slider, 'BOTTOMRIGHT', 0, 0);

        return widget;
    end

    ----------------------------------------------------
    --- ScrollBar
    ----------------------------------------------------

    function StdUi:ScrollBar(parent, width, height, horizontal)
        local panel = self:Panel(parent, width, height);
        local scrollBar = self:Slider(parent, width, height, 0, not horizontal);

        scrollBar.ScrollDownButton = self:SliderButton(parent, width, 16, 'DOWN');
        scrollBar.ScrollUpButton = self:SliderButton(parent, width, 16, 'UP');
        scrollBar.panel = panel;

        scrollBar.ScrollUpButton.scrollBar = scrollBar;
        scrollBar.ScrollDownButton.scrollBar = scrollBar;

        if horizontal then
            --@TODO do this
            --scrollBar.ScrollUpButton:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, 0);
            --scrollBar.ScrollUpButton:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', 0, 0);
            --
            --scrollBar.ScrollDownButton:SetPoint('BOTTOMLEFT', panel, 'BOTTOMLEFT', 0, 0);
            --scrollBar.ScrollDownButton:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 0, 0);
            --
            --scrollBar:SetPoint('TOPLEFT', scrollBar.ScrollUpButton, 'TOPLEFT', 0, 1);
            --scrollBar:SetPoint('TOPRIGHT', scrollBar.ScrollUpButton, 'TOPRIGHT', 0, 1);
            --scrollBar:SetPoint('BOTTOMLEFT', scrollBar.ScrollDownButton, 'BOTTOMLEFT', 0, -1);
            --scrollBar:SetPoint('BOTTOMRIGHT', scrollBar.ScrollDownButton, 'BOTTOMRIGHT', 0, -1);
        else
            scrollBar.ScrollUpButton:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, 0);
            scrollBar.ScrollUpButton:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', 0, 0);

            scrollBar.ScrollDownButton:SetPoint('BOTTOMLEFT', panel, 'BOTTOMLEFT', 0, 0);
            scrollBar.ScrollDownButton:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 0, 0);

            scrollBar:SetPoint('TOPLEFT', scrollBar.ScrollUpButton, 'BOTTOMLEFT', 0, 1);
            scrollBar:SetPoint('TOPRIGHT', scrollBar.ScrollUpButton, 'BOTTOMRIGHT', 0, 1);
            scrollBar:SetPoint('BOTTOMLEFT', scrollBar.ScrollDownButton, 'TOPLEFT', 0, -1);
            scrollBar:SetPoint('BOTTOMRIGHT', scrollBar.ScrollDownButton, 'TOPRIGHT', 0, -1);
        end

        return scrollBar, panel;
    end

    StdUi:RegisterModule(module, version);

    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Spell', 2;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    ----------------------------------------------------
    --- SpellBox
    ----------------------------------------------------

    local SpellBoxEvents = {
        OnEnter = function(self)
            if self.editBox.value then
                GameTooltip:SetOwner(self.editBox);
                GameTooltip:SetSpellByID(self.editBox.value);
                GameTooltip:Show();
            end
        end,

        OnLeave = function(self)
            if self.editBox.value then
                GameTooltip:Hide();
            end
        end
    };

    function StdUi:SpellBox(parent, width, height, iconSize, spellValidator)
        iconSize = iconSize or 16;
        local editBox = self:EditBox(parent, width, height, '', spellValidator or self.Util.spellValidator);
        editBox:SetTextInsets(iconSize + 7, 3, 3, 3);

        local iconFrame = self:Panel(editBox, iconSize, iconSize);
        self:GlueLeft(iconFrame, editBox, 2, 0, true);

        local icon = self:Texture(iconFrame, iconSize, iconSize, 134400);
        icon:SetAllPoints();

        editBox.icon = icon;
        iconFrame.editBox = editBox;

        for k, v in pairs(SpellBoxEvents) do
            iconFrame:SetScript(k, v);
        end

        return editBox;
    end

    ----------------------------------------------------
    --- SpellInfo
    ----------------------------------------------------
    local SpellInfoMethods = {
        SetSpell = function(self, nameOrId)
            local name, _, i, _, _, _, spellId = GetSpellInfo(nameOrId);
            self.spellId = spellId;
            self.spellName = name;

            self.icon:SetTexture(i);
            self.text:SetText(name);
        end
    };

    local SpellInfoEvents = {
        OnEnter = function(self)
            GameTooltip:SetOwner(self.widget);
            GameTooltip:SetSpellByID(self.widget.spellId);
            GameTooltip:Show();
        end,

        OnLeave = function()
            GameTooltip:Hide();
        end
    };

    function StdUi:SpellInfo(parent, width, height, iconSize)
        iconSize = iconSize or 16;
        local frame = self:Panel(parent, width, height);

        local iconFrame = self:Panel(frame, iconSize, iconSize);
        self:GlueLeft(iconFrame, frame, 2, 0, true);

        local icon = self:Texture(iconFrame, iconSize, iconSize);
        icon:SetAllPoints();

        local btn = self:SquareButton(frame, iconSize, iconSize, 'DELETE');
        StdUi:GlueRight(btn, frame, -3, 0, true);

        local text = self:Label(frame);
        text:SetPoint('LEFT', icon, 'RIGHT', 3, 0);
        text:SetPoint('RIGHT', btn, 'RIGHT', -3, 0);

        frame.removeBtn = btn;
        frame.icon = icon;
        frame.text = text;

        btn.parent = frame;

        iconFrame.widget = frame;

        for k, v in pairs(SpellInfoMethods) do
            frame[k] = v;
        end

        for k, v in pairs(SpellInfoEvents) do
            iconFrame:SetScript(k, v);
        end

        return frame;
    end;

    ----------------------------------------------------
    --- SpellCheckbox
    ----------------------------------------------------

    local SpellCheckboxMethods = {
        SetSpell = function(self, nameOrId)
            local name, _, i, _, _, _, spellId = GetSpellInfo(nameOrId);
            self.spellId = spellId;
            self.spellName = name;

            self.icon:SetTexture(i);
            self.text:SetText(name);
        end
    };

    local SpellCheckboxEvents = {
        OnEnter = function(self)
            if self.spellId then
                GameTooltip:SetOwner(self);
                GameTooltip:SetSpellByID(self.spellId);
                GameTooltip:Show();
            end
        end,

        OnLeave = function(self)
            if self.spellId then
                GameTooltip:Hide();
            end
        end
    };

    function StdUi:SpellCheckbox(parent, width, height, iconSize)
        iconSize = iconSize or 16;
        local checkbox = self:Checkbox(parent, '', width, height);
        checkbox.spellId = nil;
        checkbox.spellName = '';

        local iconFrame = self:Panel(checkbox, iconSize, iconSize);
        iconFrame:SetPoint('LEFT', checkbox.target, 'RIGHT', 5, 0);

        local icon = self:Texture(iconFrame, iconSize, iconSize);
        icon:SetAllPoints();

        checkbox.icon = icon;

        checkbox.text:SetPoint('LEFT', iconFrame, 'RIGHT', 5, 0);

        for k, v in pairs(SpellCheckboxMethods) do
            checkbox[k] = v;
        end

        for k, v in pairs(SpellCheckboxEvents) do
            checkbox:SetScript(k, v);
        end

        return checkbox;
    end;

    StdUi:RegisterModule(module, version);

    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Tab', 4;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    ----------------------------------------------------
    --- TabPanel
    ----------------------------------------------------

    local TabPanelMethods = {
        --- Runs callback thru all tabs, if callback returns truthy value, enumeration stops and function returns result
        EnumerateTabs = function(self, callback, ...)
            local result;

            for i = 1, #self.tabs do
                local tab = self.tabs[i];
                result = callback(tab, self, i, ...);
                if result then
                    break
                end
            end

            return result;
        end,

        HideAllFrames = function(self)
            for _, tab in pairs(self.tabs) do
                if tab.frame then
                    tab.frame:Hide();
                end
            end
        end,

        DrawButtons = function(self)
            local prevBtn;
            for _, tab in pairs(self.tabs) do
                if tab.button then
                    tab.button:Hide();
                end

                local btn = tab.button;
                local btnContainer = self.buttonContainer;

                if not btn then
                    btn = self.stdUi:Button(btnContainer, nil, self.buttonHeight);
                    tab.button = btn;
                    btn.tabFrame = self;

                    btn:SetScript('OnClick', function(bt)
                        bt.tabFrame:SelectTab(bt.tab.name);
                    end);
                end

                btn.tab = tab;
                btn:SetText(tab.title);
                btn:ClearAllPoints();

                if self.vertical then
                    btn:SetWidth(self.buttonWidth);
                else
                    self.stdUi:ButtonAutoWidth(btn);
                end

                if self.vertical then
                    if not prevBtn then
                        self.stdUi:GlueTop(btn, btnContainer, 0, 0, 'CENTER');
                    else
                        self.stdUi:GlueBelow(btn, prevBtn, 0, -1);
                    end
                else
                    if not prevBtn then
                        self.stdUi:GlueTop(btn, btnContainer, 0, 0, 'LEFT');
                    else
                        self.stdUi:GlueRight(btn, prevBtn, 5, 0);
                    end
                end

                btn:Show();
                prevBtn = btn;
            end
        end,

        DrawFrames = function(self)
            for _, tab in pairs(self.tabs) do
                if not tab.frame then
                    tab.frame = self.stdUi:Frame(self.container);
                end

                tab.frame:ClearAllPoints();
                tab.frame:SetAllPoints();

                if tab.layout then
                    self.stdUi:BuildWindow(tab.frame, tab.layout);
                    self.stdUi:EasyLayout(tab.frame, { padding = { top = 10 } });

                    tab.frame:SetScript('OnShow', function(of)
                        of:DoLayout();
                    end);
                end

                if tab.onHide then
                    tab.frame:SetScript('OnHide', tab.onHide);
                end
            end
        end,

        Update = function(self, newTabs)
            if newTabs then
                self.tabs = newTabs;
            end
            self:DrawButtons();
            self:DrawFrames();
        end,

        GetTabByName = function(self, name)
            for _, tab in pairs(self.tabs) do
                if tab.name == name then
                    return tab;
                end
            end
        end,

        SelectTab = function(self, name)
            self.selected = name;
            if self.selectedTab then
                self.selectedTab.button:Enable();
            end

            self:HideAllFrames();
            local foundTab = self:GetTabByName(name);

            if foundTab.name == name and foundTab.frame then
                foundTab.button:Disable();
                foundTab.frame:Show();
                self.selectedTab = foundTab;
                return true;
            end
        end,

        GetSelectedTab = function(self)
            return self.selectedTab;
        end,

        DoLayout = function(self)
            -- redoing layout as container
            local tab = self:GetSelectedTab();
            if tab then
                if tab.frame and tab.frame.DoLayout then
                    tab.frame:DoLayout();
                end
            end
        end
    };

    ---
    ---local t = {
    ---    {
    ---        name = 'firstTab',
    ---        title = 'First',
    ---    },
    ---    {
    ---        name = 'secondTab',
    ---        title = 'Second',
    ---    },
    ---    {
    ---        name = 'thirdTab',
    ---        title = 'Third'
    ---    }
    ---}
    function StdUi:TabPanel(parent, width, height, tabs, vertical, buttonWidth, buttonHeight)
        vertical = vertical or false;
        buttonWidth = buttonWidth or 160;
        buttonHeight = buttonHeight or 20;

        local tabFrame = self:Frame(parent, width, height);
        tabFrame.stdUi = self;
        tabFrame.tabs = tabs;
        tabFrame.vertical = vertical;
        tabFrame.buttonWidth = buttonWidth;
        tabFrame.buttonHeight = buttonHeight;

        tabFrame.buttonContainer = self:Frame(tabFrame);
        tabFrame.container = self:Panel(tabFrame);

        if vertical then
            tabFrame.buttonContainer:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 0, 0);
            tabFrame.buttonContainer:SetPoint('BOTTOMLEFT', tabFrame, 'BOTTOMLEFT', 0, 0);
            tabFrame.buttonContainer:SetWidth(buttonWidth);

            tabFrame.container:SetPoint('TOPLEFT', tabFrame.buttonContainer, 'TOPRIGHT', 5, 0);
            tabFrame.container:SetPoint('BOTTOMLEFT', tabFrame.buttonContainer, 'BOTTOMRIGHT', 5, 0);
            tabFrame.container:SetPoint('TOPRIGHT', tabFrame, 'TOPRIGHT', 0, 0);
            tabFrame.container:SetPoint('BOTTOMRIGHT', tabFrame, 'BOTTOMRIGHT', 0, 0);
        else
            tabFrame.buttonContainer:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 0, 0);
            tabFrame.buttonContainer:SetPoint('TOPRIGHT', tabFrame, 'TOPRIGHT', 0, 0);
            tabFrame.buttonContainer:SetHeight(buttonHeight);

            tabFrame.container:SetPoint('TOPLEFT', tabFrame.buttonContainer, 'BOTTOMLEFT', 0, -5);
            tabFrame.container:SetPoint('TOPRIGHT', tabFrame.buttonContainer, 'BOTTOMRIGHT', 0, -5);
            tabFrame.container:SetPoint('BOTTOMLEFT', tabFrame, 'BOTTOMLEFT', 0, 0);
            tabFrame.container:SetPoint('BOTTOMRIGHT', tabFrame, 'BOTTOMRIGHT', 0, 0);
        end

        for k, v in pairs(TabPanelMethods) do
            tabFrame[k] = v;
        end

        tabFrame:Update();
        if #tabFrame.tabs > 0 then
            tabFrame:SelectTab(tabFrame.tabs[1].name);
        end

        return tabFrame;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Table', 2;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    local TableInsert = tinsert;
    local StringLength = strlen;

    ----------------------------------------------------
    --- Table
    ----------------------------------------------------

    --- Draws table in a panel according to data, example:
    --- local columns = {
    ---        {header = 'Name', index = 'name', width = 20, align = 'RIGHT'},
    ---        {header = 'Price', index = 'price', width = 60},
    --- };
    --- local data {
    ---        {name = 'Item one', price = 12.22},
    ---        {name = 'Item two', price = 11.11},
    ---        {name = 'Item three', price = 10.12},
    --- }

    local TableMethods = {
        SetColumns = function(self, columns)
            self.columns = columns;
        end,

        SetData = function(self, data)
            self.tableData = data;
        end,

        AddRow = function(self, row)
            if not self.tableData then
                self.tableData = {};
            end

            TableInsert(self.tableData, row);
        end,

        DrawHeaders = function(self)
            if not self.headers then
                self.headers = {};
            end

            local marginLeft = 0;
            for i = 1, #self.columns do
                local col = self.columns[i];

                if col.header and StringLength(col.header) > 0 then
                    if not self.headers[i] then
                        self.headers[i] = {
                            text = self.stdUi:FontString(self, ''),
                        };
                    end

                    local column = self.headers[i];

                    column.text:SetText(col.header);
                    column.text:SetWidth(col.width);
                    column.text:SetHeight(self.rowHeight);
                    column.text:ClearAllPoints();
                    if col.align then
                        --column.text:SetJustifyH(col.align);
                        column.text:SetJustifyH("LEFT");
                    end

                    self.stdUi:GlueTop(column.text, self, marginLeft, 0, 'LEFT');
                    marginLeft = marginLeft + col.width;

                    column.index = col.index
                    column.width = col.width
                end
            end
        end,

        DrawData = function(self)
            if not self.rows then
                self.rows = {};
            end

            local marginTop = -self.rowHeight;
            for y = 1, #self.tableData do
                local row = self.tableData[y];

                local marginLeft = 0;
                for x = 1, #self.columns do
                    local col = self.columns[x];

                    if not self.rows[y] then
                        self.rows[y] = {};
                    end

                    if not self.rows[y][x] then
                        self.rows[y][x] = {
                            text = self.stdUi:FontString(self, ''),
                        };
                    end

                    local cell = self.rows[y][x];

                    cell.text:SetText(row[col.index]);
                    cell.text:SetWidth(col.width);
                    cell.text:SetHeight(self.rowHeight);
                    cell.text:ClearAllPoints();
                    if col.align then
                        --cell.text:SetJustifyH(col.align);
                        cell.text:SetJustifyH("LEFT");
                    end

                    self.stdUi:GlueTop(cell.text, self, marginLeft, marginTop, 'LEFT');
                    marginLeft = marginLeft + col.width;
                end

                marginTop = marginTop - self.rowHeight;
            end
        end,

        DrawTable = function(self)
            self:DrawHeaders();
            self:DrawData();
        end
    };

    function StdUi:Table(parent, width, height, rowHeight, columns, data)
        local panel = self:Panel(parent, width, height);
        panel.stdUi = self;
        panel.rowHeight = rowHeight;

        for k, v in pairs(TableMethods) do
            panel[k] = v;
        end

        panel:SetColumns(columns);
        panel:SetData(data);
        panel:DrawTable();

        return panel;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Tooltip', 3;
    if not StdUi:UpgradeNeeded(module, version) then
        return
    end

    StdUi.tooltips = {};
    StdUi.frameTooltips = {};

    ----------------------------------------------------
    --- Tooltip
    ----------------------------------------------------

    local TooltipEvents = {
        OnEnter = function(self)
            local tip = self.stdUiTooltip;
            tip:SetOwner(tip.owner or UIParent, tip.anchor or 'ANCHOR_NONE');

            if type(tip.text) == 'string' then
                tip:SetText(tip.text,
                    tip.stdUi.config.font.color.r,
                    tip.stdUi.config.font.color.g,
                    tip.stdUi.config.font.color.b,
                    tip.stdUi.config.font.color.a
                );
            elseif type(tip.text) == 'function' then
                tip.text(tip);
            end

            tip:Show();
            tip:ClearAllPoints();
            tip.stdUi:GlueOpposite(tip, tip.owner, 0, 0, tip.anchor);
        end,

        OnLeave = function(self)
            local tip = self.stdUiTooltip;
            tip:Hide();
        end
    }

    --- Standard blizzard tooltip
    ---@return GameTooltip
    function StdUi:Tooltip(owner, text, tooltipName, anchor, automatic)
        --- @type GameTooltip
        local tip;

        if tooltipName and self.tooltips[tooltipName] then
            tip = self.tooltips[tooltipName];
        else
            tip = CreateFrame('GameTooltip', tooltipName, UIParent, 'GameTooltipTemplate');
            self:ApplyBackdrop(tip, 'panel');
        end

        tip.owner = owner;
        tip.anchor = anchor;
        tip.text = text;
        tip.stdUi = self;
        owner.stdUiTooltip = tip;

        if automatic then
            for k, v in pairs(TooltipEvents) do
                owner:HookScript(k, v);
            end
        end

        return tip;
    end

    ----------------------------------------------------
    --- Tooltip
    ----------------------------------------------------

    local FrameTooltipMethods = {
        SetText         = function(self, text, r, g, b)
            if r and g and b then
                text = self.stdUi.Util.WrapTextInColor(text, r, g, b, 1);
            end
            self.text:SetText(text);

            self:RecalculateSize();
        end,

        GetText         = function(self)
            return self.text:GetText();
        end,

        AddLine         = function(self, text, r, g, b)
            local txt = self:GetText();
            if not txt then
                txt = '';
            else
                txt = txt .. '\n'
            end
            if r and g and b then
                text = self.stdUi.Util.WrapTextInColor(text, r, g, b, 1);
            end
            self:SetText(txt .. text);
        end,

        RecalculateSize = function(self)
            self:SetSize(
                self.text:GetWidth() + self.padding * 2,
                self.text:GetHeight() + self.padding * 2
            );
        end
    };

    local OnShowFrameTooltip = function(self)
        self:RecalculateSize();
        self:ClearAllPoints();
        self.stdUi:GlueOpposite(self, self.owner, 0, 0, self.anchor);
    end

    local FrameTooltipEvents = {
        OnEnter = function(self)
            self.stdUiTooltip:Show();
        end,

        OnLeave = function(self)
            self.stdUiTooltip:Hide();
        end,
    };

    function StdUi:FrameTooltip(owner, text, tooltipName, anchor, automatic, manualPosition)
        local tip;

        if tooltipName and self.frameTooltips[tooltipName] then
            tip = self.frameTooltips[tooltipName];
        else
            tip = self:Panel(owner, 10, 10);
            tip.stdUi = self;
            tip:SetFrameStrata('TOOLTIP');
            self:ApplyBackdrop(tip, 'panel');

            tip.padding = self.config.tooltip.padding;

            tip.text = self:FontString(tip, '');
            self:GlueTop(tip.text, tip, tip.padding, -tip.padding, 'LEFT');

            for k, v in pairs(FrameTooltipMethods) do
                tip[k] = v;
            end

            if not manualPosition then
                hooksecurefunc(tip, 'Show', OnShowFrameTooltip);
            end
        end

        tip.owner = owner;
        tip.anchor = anchor;

        owner.stdUiTooltip = tip;

        if type(text) == 'string' then
            tip:SetText(text);
        elseif type(text) == 'function' then
            text(tip);
        end

        if automatic then
            for k, v in pairs(FrameTooltipEvents) do
                owner:HookScript(k, v);
            end
        end

        return tip;
    end

    StdUi:RegisterModule(module, version);
    --- @type StdUi
    local StdUi = RavnStub and RavnStub('StdUi', true);
    if not StdUi then
        return
    end

    local module, version = 'Window', 5;
    if not StdUi:UpgradeNeeded(module, version) then return end;

    --- @return Frame
    function StdUi:Window(parent, width, height, title)
        parent = parent or UIParent;
        local frame = self:PanelWithTitle(parent, width, height, title);
        frame:SetClampedToScreen(true);
        frame.titlePanel.isWidget = false;
        self:MakeDraggable(frame); -- , frame.titlePanel

        local closeBtn = self:Button(frame, 16, 16, 'X');
        closeBtn.text:SetFontSize(12);
        closeBtn.isWidget = false;
        self:GlueTop(closeBtn, frame, -10, -10, 'RIGHT');

        closeBtn:SetScript('OnClick', function(self)
            self:GetParent():Hide();
        end);

        frame.closeBtn = closeBtn;

        function frame:SetWindowTitle(t)
            self.titlePanel.label:SetText(t);
        end

        -- Resizable window shortcut
        function frame:MakeResizable(direction)
            StdUi:MakeResizable(frame, direction);
            return frame;
        end

        return frame;
    end

    -- Reusing dialogs
    StdUi.dialogs = {};
    --- @return Frame
    function StdUi:Dialog(title, message, dialogId)
        local window;
        if dialogId and self.dialogs[dialogId] then
            window = self.dialogs[dialogId];
        else
            window = self:Window(nil, self.config.dialog.width, self.config.dialog.height, title);
            window:SetPoint('CENTER');
            window:SetFrameStrata('DIALOG');
        end

        if window.messageLabel then
            window.messageLabel:SetText(message);
        else
            window.messageLabel = self:Label(window, message);
            window.messageLabel:SetJustifyH("CENTER");
            self:GlueAcross(window.messageLabel, window, 5, -10, -5, 5);
        end

        window:Show();

        if dialogId then
            self.dialogs[dialogId] = window;
        end

        return window;
    end

    --- Dialog with additional buttons, buttons can be like this
    --- local btn = {
    ---		ok = {
    ---			text = 'OK',
    ---			onClick = function() end
    ---		},
    ---		cancel = {
    ---			text = 'Cancel',
    ---			onClick = function() end
    ---		}
    --- }
    --- @return Frame
    function StdUi:Confirm(title, message, buttons, dialogId)
        local window = self:Dialog(title, message, dialogId);

        if buttons and not window.buttons then
            window.buttons = {};

            local btnCount = self.Util.tableCount(buttons);

            local btnMargin = self.config.dialog.button.margin;
            local btnWidth = self.config.dialog.button.width;
            local btnHeight = self.config.dialog.button.height;

            local totalWidth = btnCount * btnWidth + (btnCount - 1) * btnMargin;
            local leftMargin = math.floor((self.config.dialog.width - totalWidth) / 2);

            local i = 0;
            for k, btnDefinition in pairs(buttons) do
                local btn = self:Button(window, btnWidth, btnHeight, btnDefinition.text);
                btn.window = window;

                self:GlueBottom(btn, window, leftMargin + (i * (btnWidth + btnMargin)), 10, 'LEFT');

                if btnDefinition.onClick then
                    btn:SetScript('OnClick', btnDefinition.onClick);
                end

                window.buttons[k] = btn;
                i = i + 1;
            end

            window.messageLabel:ClearAllPoints();
            self:GlueAcross(window.messageLabel, window, 5, -10, -5, 5 + btnHeight + 5);
        end

        return window;
    end

    StdUi:RegisterModule(module, version);
end

luaScripts.InitJSON();
luaScripts.InitRavnStub();
luaScripts.InitMenuFramework();

awful.Populate(
    {
        ["lua.luaScripts"] = ____exports,
    },
    ravn,
    getfenv(1)
)

return luaScripts
