local v0, v1 = ...;
local v2, v3, v4 = tinsert, tremove, floor;
local v5, v6, v7 = v1['bin'], v1['lerp'], v1['cubicBezier'];
local v8, v9, v10, v11 = min, max, pairs, ipairs;
local v12, v13, v14 = type, strsub, strlen;
local v15, v16 = math['fmod'], rawset;
local function v17(v79)
	local FlatIdent_5C492 = 953 - (513 + 440);
	local v80;
	while true do
		if (FlatIdent_5C492 == (0 + 0)) then
			v80 = "|cFF";
			if (#v79 > (3 - 0)) then
				v79[8 - 4] = nil;
			end
			FlatIdent_5C492 = 1183 - (389 + 793);
		end
		if (FlatIdent_5C492 == (1590 - (919 + 670))) then
			for v590, v591 in v10(v79) do
				if (v12(v591) == "number") then
					local FlatIdent_68C4 = 0 + 0;
					local v854;
					while true do
						if ((953 - (950 + 3)) == FlatIdent_68C4) then
							v591 = v591 * (116 + 139);
							v854 = "";
							FlatIdent_68C4 = 1 + 0;
						end
						if (FlatIdent_68C4 == (4 - 2)) then
							v80 = v80 .. v854;
							break;
						end
						if ((1 + 0) == FlatIdent_68C4) then
							while v591 > (0 - 0) do
								local FlatIdent_26803 = 0 - 0;
								local v930;
								while true do
									if ((1 + 0) == FlatIdent_26803) then
										v854 = v13("0123456789ABCDEF", v930, v930) .. v854;
										break;
									end
									if (FlatIdent_26803 == (1258 - (1241 + 17))) then
										v930 = v15(v591, 21 - 5) + 1 + 0;
										v591 = v4(v591 / (934 - (859 + 59)));
										FlatIdent_26803 = 1 - 0;
									end
								end
							end
							if (v14(v854) == (400 - (329 + 71))) then
								v854 = "00";
							elseif (v14(v854) == (1 + 0)) then
								v854 = "0" .. v854;
							end
							FlatIdent_68C4 = 5 - 3;
						end
					end
				end
			end
			return v80;
		end
	end
end
local function v18(v81)
	return v8(v9(v81, 0 - 0), 2 - 1);
end
local v19 = {};
local v20 = {backdrops={main={bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",tile=true,tileEdge=true,tileSize=(1590 - (1268 + 306)),edgeSize=(1 + 2),insets={left=(11 - 8),right=(2 + 1),top=(1627 - (1311 + 313)),bottom=(1088 - (696 + 389))}},tooltip={bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",tile=true,tileEdge=true,tileSize=(4 + 12),edgeSize=(226 - (25 + 185)),insets={left=(1 + 2),right=(10 - 7),top=(2 + 1),bottom=(1163 - (372 + 788))}},white={bgFile="Interface\\Buttons\\WHITE8X8",tile=true,tileEdge=true,tileSize=(4 + 12),edgeSize=(32 - 16),insets={left=(688 - (30 + 655)),right=(918 - (262 + 653)),top=(5 - 2),bottom=(862 - (146 + 713))}},thumb={tile=true,tileEdge=true,tileSize=(25 - 9),edgeSize=(1 + 3),insets={top=(5 + 1),left=(0 + 0),right=(824 - (140 + 684)),bottom=(7 - 1)}}},width=(198 + 127),height=(567 - (209 + 163))};
v20['__index'] = v20;
local v22 = {};
v22['__index'] = v22;
local v24 = 22 - 14;
local v25 = 8 + 0;
local v26 = 145 - 85;
local v27 = {(23 + 232),(1591 - (954 + 497)),(13 + 2)};
local v28 = v1.createFont(1955 - (1167 + 774));
local v29 = "Fonts\\FRIZQT__.TTF";
local function v30(v82)
	local FlatIdent_903CF = 0 - 0;
	while true do
		if (FlatIdent_903CF == (808 - (173 + 634))) then
			return v82;
		end
		if (FlatIdent_903CF == (0 + 0)) then
			if v82['adjusted'] then
				return v82;
			end
			for v592, v593 in v11(v82) do
				if (v12(v593) == "table") then
					if not v593['adjusted'] then
						local FlatIdent_45936 = 0 + 0;
						while true do
							if (FlatIdent_45936 == (0 - 0)) then
								for v1057, v1058 in v11(v593) do
									if (v1057 ~= (215 - (83 + 128))) then
										v82[v592][v1057] = v1058 / (180 + 75);
									end
								end
								v593['adjusted'] = true;
								break;
							end
						end
					end
				elseif (v592 ~= (253 - (42 + 207))) then
					local FlatIdent_1DE2C = 1669 - (341 + 1328);
					while true do
						if (FlatIdent_1DE2C == (158 - (99 + 59))) then
							v82[v592] = v82[v592] / (2131 - (1378 + 498));
							v82['adjusted'] = true;
							break;
						end
					end
				end
			end
			FlatIdent_903CF = 1 + 0;
		end
	end
end
v20.New = function(v83, v84, v85)
	local FlatIdent_5E73F = 0 - 0;
	local v86;
	local v89;
	while true do
		if (FlatIdent_5E73F == (1025 - (509 + 514))) then
			if not v86['shadows']['primary'] then
				v86['shadows']['primary'] = {(0 - 0),(0 + 0),(1926 - (865 + 1061)),(1087.25 - (731 + 356)),(2.25 - 1),-(1.25 + 0)};
			end
			if (v86['colors'] and not v86['colors_adjusted']) then
				local FlatIdent_6BAD8 = 0 - 0;
				while true do
					if (FlatIdent_6BAD8 == (0 + 0)) then
						for v855, v856 in v10(v86.colors) do
							v86['colors'][v855] = v30(v856);
						end
						v86['colors_adjusted'] = true;
						break;
					end
				end
			end
			if not v86['el_padding_right'] then
				v86['el_padding_right'] = 3 + 17;
			end
			if not v86['colors'] then
				v86['colors'] = {};
			end
			FlatIdent_5E73F = 262 - (234 + 25);
		end
		if ((7 - 2) == FlatIdent_5E73F) then
			v86['saved'] = setmetatable({}, {__index=v89,__newindex=getmetatable(v89)['__newindex']});
			if v86['subSettings'] then
				for v858, v859 in v11(v86.subSettings) do
					if not v86['saved'][v859] then
						local FlatIdent_41822 = 856 - (118 + 738);
						local v1012;
						while true do
							if (FlatIdent_41822 == (0 + 0)) then
								v1012 = v1.NewConfig(v86['name'] .. "_" .. v859);
								v16(v86.saved, v859, v1012);
								break;
							end
						end
					end
				end
			end
			v86['cmd'] = v1.Command(v85['cmd'] or v84, true, v85.pw);
			setmetatable(v86, v20);
			FlatIdent_5E73F = 17 - 11;
		end
		if (FlatIdent_5E73F == (2 + 2)) then
			if not v86['colors']['tertiary'] then
				v86['colors']['tertiary'] = {(0.7 - 0),(0.7 - 0),(744.7 - (408 + 336)),(0.35 + 0)};
			end
			if not v86['colors']['primary'] then
				v86['colors']['primary'] = {(1 + 0),(1 + 0),(1 + 0),(840 - (500 + 339))};
			end
			v86['sections'] = {};
			v89 = v1.NewConfig(v84, v85.pw);
			FlatIdent_5E73F = 679 - (525 + 149);
		end
		if (FlatIdent_5E73F == (1 + 0)) then
			v86 = v85;
			v86['name'] = v84;
			if not v86['scale'] then
				v86['scale'] = 1 + 0;
			end
			if not v86['shadows'] then
				v86['shadows'] = {};
			end
			FlatIdent_5E73F = 538 - (509 + 27);
		end
		if (FlatIdent_5E73F == (500 - (34 + 463))) then
			if not v86['colors']['accent'] then
				v86['colors']['accent'] = v30(v27);
			end
			if not v86['colors']['background'] then
				v86['colors']['background'] = {(0.06 + 0),(0.06 - 0),(0.04 - 0),(0.85 + 0)};
			end
			if not v86['colors']['elMod'] then
				v86['colors']['elMod'] = 354.6 - (228 + 126);
			end
			if not v86['colors']['elAlpha'] then
				v86['colors']['elAlpha'] = 0.9 + 0;
			end
			FlatIdent_5E73F = 612 - (24 + 584);
		end
		if ((919 - (765 + 154)) == FlatIdent_5E73F) then
			if (v12(v84) ~= "string") then
				return false;
			end
			if v19[v84] then
				local FlatIdent_680C9 = 0 + 0;
				while true do
					if (FlatIdent_680C9 == (0 + 0)) then
						v1.print("UI with that name [" .. v84 .. "] already exists! Please choose another name...", true);
						return false;
					end
				end
			end
			if (v12(v85) ~= "table") then
				local FlatIdent_44F87 = 0 - 0;
				while true do
					if (FlatIdent_44F87 == (0 - 0)) then
						v1.print("UI [" .. v84 .. "] must have valid options! Please pass table of options to 2nd arg 'options'...", true);
						return false;
					end
				end
			end
			if not v85['title'] then
				local FlatIdent_77278 = 0 + 0;
				while true do
					if (FlatIdent_77278 == (0 + 0)) then
						v1.print("UI [" .. v84 .. "] must have a title! Please add the title property to 2nd arg 'options'...", true);
						return false;
					end
				end
			end
			FlatIdent_5E73F = 1 + 0;
		end
		if (FlatIdent_5E73F == (1041 - (160 + 874))) then
			v86:Render();
			return v86, v86['saved'], v86['cmd'];
		end
		if (FlatIdent_5E73F == (16 - 10)) then
			v86['tab'] = {ui=v86};
			v86['tab']['__index'] = v86['tab'];
			setmetatable(v86.tab, v22);
			v19[v84] = v86;
			FlatIdent_5E73F = 18 - 11;
		end
	end
end;
local v32 = {};
v32['__index'] = v32;
v20.Group = function(v95, v96)
	local FlatIdent_3099E = 0 - 0;
	local v97;
	while true do
		if (FlatIdent_3099E == (1611 - (564 + 1047))) then
			v97 = v96;
			if v96['colors'] then
				for v860, v861 in v10(v96.colors) do
					v97['colors'][v860] = v30(v861);
				end
			end
			v97['tabs'] = {};
			v97['group'] = v97;
			FlatIdent_3099E = 1 + 0;
		end
		if (FlatIdent_3099E == (1 + 0)) then
			v97['ui'] = v95;
			v97['uid'] = math.random(0 - 0, 513204 + 486795);
			v97['open'] = true;
			setmetatable(v97, v32);
			FlatIdent_3099E = 1946 - (158 + 1786);
		end
		if (FlatIdent_3099E == (1452 - (414 + 1036))) then
			v95['tabs'] = v95['tabs'] or v95:CreateTabList();
			v2(v95.tabs, v97);
			v95:Rerender();
			return v97;
		end
	end
end;
v32.Tab = function(v104, v105, v106)
	local FlatIdent_61AAF = 1885 - (1285 + 600);
	local v107;
	local v108;
	while true do
		if ((4 - 3) == FlatIdent_61AAF) then
			v107['uid'] = math.random(1017 - (269 + 748), 4492712 - 3492713);
			v107['name'] = v105;
			v107['elements'] = {};
			v107['scrollPos'] = {};
			FlatIdent_61AAF = 708 - (563 + 143);
		end
		if ((807 - (318 + 487)) == FlatIdent_61AAF) then
			v107['inGroup'] = v104;
			if (v12(v106) == "string") then
				if not v108['saved'][v106] then
					local FlatIdent_93B64 = 1483 - (1245 + 238);
					local v931;
					while true do
						if (FlatIdent_93B64 == (1630 - (972 + 657))) then
							v107['saved'] = v931;
							break;
						end
						if (FlatIdent_93B64 == (0 + 0)) then
							v931 = v1.NewConfig(v108['name'] .. "_" .. v106);
							v16(v108.saved, v106, v931);
							FlatIdent_93B64 = 2 - 1;
						end
					end
				else
					v107['saved'] = v108['saved'][v106];
				end
			end
			setmetatable(v107, v108.tab);
			v2(v104.tabs, v107);
			FlatIdent_61AAF = 1734 - (1469 + 262);
		end
		if (FlatIdent_61AAF == (0 + 0)) then
			v107 = {};
			v108 = v104['ui'];
			v107['__index'] = v108['tab'];
			v107['parent'] = v108['frame']['tabs'];
			FlatIdent_61AAF = 1 - 0;
		end
		if (FlatIdent_61AAF == (1 + 2)) then
			v104['ui']:Rerender();
			return v107;
		end
	end
end;
v32.ContainsTab = function(v118, v119)
	for v594, v595 in v11(v118.tabs) do
		if (v595['uid'] == v119) then
			return v595;
		end
	end
end;
v32.Expand = function(v120)
	local FlatIdent_8606D = 0 + 0;
	while true do
		if (FlatIdent_8606D == (1350 - (828 + 522))) then
			if v120['open'] then
				return false;
			end
			v120['group']['open'] = true;
			FlatIdent_8606D = 1532 - (272 + 1259);
		end
		if (FlatIdent_8606D == (1 - 0)) then
			v120['ui']:Rerender(true);
			break;
		end
	end
end;
v32.Collapse = function(v122)
	local FlatIdent_6EC2A = 0 + 0;
	while true do
		if (FlatIdent_6EC2A == (0 + 0)) then
			if not v122['open'] then
				return false;
			end
			v122['group']['open'] = false;
			FlatIdent_6EC2A = 1190 - (982 + 207);
		end
		if ((451 - (344 + 106)) == FlatIdent_6EC2A) then
			v122['ui']:Rerender(true);
			break;
		end
	end
end;
v32.Toggle = function(v124)
	if not v124['open'] then
		v124:Expand();
	else
		v124:Collapse();
	end
end;
v20.Tab = function(v125, v126, v127)
	local FlatIdent_10BD0 = 0 - 0;
	local v128;
	while true do
		if (FlatIdent_10BD0 == (8 - 6)) then
			setmetatable(v128, v125.tab);
			v125['tabs'] = v125['tabs'] or v125:CreateTabList();
			for v596, v597 in v11(v125.tabs) do
				if (v597['name'] == v126) then
					local FlatIdent_580C6 = 216 - (127 + 89);
					while true do
						if ((0 - 0) == FlatIdent_580C6) then
							v1.print("Tab with that name [" .. v126 .. "] already exists! Please choose another name...", true);
							return false;
						end
					end
				end
			end
			v2(v125.tabs, v128);
			FlatIdent_10BD0 = 8 - 5;
		end
		if ((1426 - (282 + 1144)) == FlatIdent_10BD0) then
			v128 = {};
			v128['__index'] = v125['tab'];
			v128['parent'] = v125['frame']['tabs'];
			v128['name'] = v126;
			FlatIdent_10BD0 = 2 - 1;
		end
		if (FlatIdent_10BD0 == (12 - 9)) then
			v125:Rerender();
			return v128;
		end
		if (FlatIdent_10BD0 == (1 + 0)) then
			v128['uid'] = math.random(0 + 0, 901387 + 98612);
			v128['elements'] = {};
			v128['scrollPos'] = {};
			if (v12(v127) == "string") then
				if not v125['saved'][v127] then
					local FlatIdent_93CFF = 0 + 0;
					local v935;
					while true do
						if (FlatIdent_93CFF == (0 + 0)) then
							v935 = v1.NewConfig(v125['name'] .. "_" .. v127);
							v16(v125.saved, v127, v935);
							FlatIdent_93CFF = 1 + 0;
						end
						if (FlatIdent_93CFF == (1 + 0)) then
							v128['saved'] = v125['saved'][v127];
							break;
						end
					end
				else
					v128['saved'] = v125['saved'][v127];
				end
			end
			FlatIdent_10BD0 = 2 + 0;
		end
	end
end;
v22.Checkbox = function(v138, v139, v140, v141)
	local FlatIdent_1E97D = 0 - 0;
	local v142;
	local v143;
	while true do
		if (FlatIdent_1E97D == (1 + 0)) then
			v143['saved'] = v142;
			v143['uid'] = math.random(231 - (15 + 216), 2160273 - 1160274);
			if (v12(v139) == "table") then
				local FlatIdent_8FAB2 = 0 + 0;
				while true do
					if (FlatIdent_8FAB2 == (0 - 0)) then
						v143['var'] = v139['var'];
						v143['tooltip'] = v139['tooltip'];
						FlatIdent_8FAB2 = 843 - (653 + 189);
					end
					if (FlatIdent_8FAB2 == (1424 - (713 + 710))) then
						v143['name'] = v139['text'] or v139['name'];
						v143['default'] = v139['default'];
						break;
					end
				end
			else
				local FlatIdent_28ADA = 0 + 0;
				while true do
					if (FlatIdent_28ADA == (1529 - (1157 + 371))) then
						v143['name'] = v139;
						break;
					end
					if (FlatIdent_28ADA == (0 + 0)) then
						v143['var'] = v140;
						v143['tooltip'] = v141;
						FlatIdent_28ADA = 296 - (208 + 87);
					end
				end
			end
			FlatIdent_1E97D = 1462 - (1170 + 290);
		end
		if ((974 - (44 + 927)) == FlatIdent_1E97D) then
			v2(v138.elements, v143);
			if (v138['ui']['currentTab'] and (v138['ui']['currentTab']['name'] == v138['name'])) then
				v138['ui']:Rerender();
			end
			return v143;
		end
		if (FlatIdent_1E97D == (1 + 1)) then
			if ((v12(v143.text) ~= "string") and (v12(v143.name) ~= "string")) then
				return v1.print("required field [text] {string} missing in Checkbox creation");
			end
			if (v12(v143.var) ~= "string") then
				return v1.print("required field [var] {string} missing in Checkbox creation");
			end
			if (v142[v143['var']] == nil) then
				v142[v143['var']] = v143['default'] or false;
			end
			FlatIdent_1E97D = 4 - 1;
		end
		if (FlatIdent_1E97D == (1945 - (898 + 1047))) then
			v142 = v138['saved'] or v138['ui']['saved'];
			v143 = {};
			v143['type'] = "checkbox";
			FlatIdent_1E97D = 744 - (438 + 305);
		end
	end
end;
v22.Slider = function(v147, v148)
	local FlatIdent_2563 = 1900 - (1716 + 184);
	local v149;
	local v150;
	while true do
		if (FlatIdent_2563 == (0 + 0)) then
			if not v148['var'] then
				return v1.print("You must provide variable for the slider value to be saved under", true);
			end
			v149 = v147['saved'] or v147['ui']['saved'];
			v150 = v148;
			FlatIdent_2563 = 1 - 0;
		end
		if (FlatIdent_2563 == (3 + 1)) then
			if (v12(v150.min) ~= "number") then
				return v1.print("required field [min] {number} missing in Slider creation");
			end
			if (v12(v150.max) ~= "number") then
				return v1.print("required field [max] {number} missing in Slider creation");
			end
			if (v150['default'] and (v12(v150.default) ~= "number")) then
				return v1.print("invalid value type for field [default] {number} in Slider creation");
			end
			FlatIdent_2563 = 1442 - (467 + 970);
		end
		if (FlatIdent_2563 == (1 + 1)) then
			v150['text'] = v150['text'] or v150['label'];
			v150['name'] = v148['name'] or v148['text'] or v148['label'];
			if (v12(v150.var) ~= "string") then
				return v1.print("required field [var] {string} missing in Slider creation");
			end
			FlatIdent_2563 = 4 - 1;
		end
		if (FlatIdent_2563 == (480 - (464 + 10))) then
			return v150;
		end
		if (FlatIdent_2563 == (892 - (721 + 170))) then
			v150['type'] = "slider";
			v150['saved'] = v149;
			v150['uid'] = math.random(0 + 0, 887009 + 112990);
			FlatIdent_2563 = 935 - (220 + 713);
		end
		if (FlatIdent_2563 == (12 - 9)) then
			v150['min'] = v150['min'] or (0 + 0);
			v150['max'] = v150['max'] or (277 - 177);
			v150['step'] = v150['step'] or (617 - (445 + 171));
			FlatIdent_2563 = 1175 - (851 + 320);
		end
		if (FlatIdent_2563 == (5 + 0)) then
			if (v149[v150['var']] == nil) then
				v149[v150['var']] = v150['default'] or v150['value'] or v150['min'];
			end
			v2(v147.elements, v150);
			if (v147['ui']['currentTab'] and (v147['ui']['currentTab']['name'] == v147['name'])) then
				v147['ui']:Rerender();
			end
			FlatIdent_2563 = 877 - (317 + 554);
		end
	end
end;
v22.Dropdown = function(v159, v160)
	if not v160['var'] then
		return v1.print("You must provide variable for the dropdown value to be saved under", true);
	end
	local v161 = v159['saved'] or v159['ui']['saved'];
	local v162 = v160;
	v162['type'] = (v162['multi'] and "multiDropdown") or "dropdown";
	v162['saved'] = v161;
	v162['uid'] = math.random(0 + 0, 3839115 - 2839116);
	v162['name'] = v160['name'] or v160['header'] or v160['text'];
	if (v12(v162.var) ~= "string") then
		return v1.print("required field [var] {string} missing in Dropdown creation");
	end
	if (v161[v162['var']] == nil) then
		if v162['default'] then
			if v162['multi'] then
				local FlatIdent_7A193 = 1626 - (376 + 1250);
				while true do
					if (FlatIdent_7A193 == (101 - (83 + 17))) then
						for v1136, v1137 in v11(v162.default) do
							local FlatIdent_7547F = 0 - 0;
							local v1138;
							while true do
								if (FlatIdent_7547F == (3 - 2)) then
									v161[v162['var']][v1137] = ((v12(v1138) == "table") and v1138['tvalue']) or true;
									break;
								end
								if (FlatIdent_7547F == (0 - 0)) then
									v1138 = nil;
									if v162['options'] then
										for v1186 = 1 - 0, #v162['options'] do
											if (v162['options'][v1186]['value'] == v1137) then
												v1138 = v162['options'][v1186];
												break;
											end
										end
									end
									FlatIdent_7547F = 1 + 0;
								end
							end
						end
						break;
					end
					if (FlatIdent_7A193 == (1997 - (66 + 1931))) then
						if (v12(v162.default) ~= "table") then
							return v1.print("invalid value type for field [default] {table} missing in Multi-Dropdown creation");
						end
						v161[v162['var']] = {};
						FlatIdent_7A193 = 1 - 0;
					end
				end
			else
				v161[v162['var']] = v162['default'];
			end
		elseif v162['multi'] then
			v161[v162['var']] = {};
		end
	end
	v2(v159.elements, v162);
	if (v159['ui']['currentTab'] and (v159['ui']['currentTab']['name'] == v159['name'])) then
		v159['ui']:Rerender();
	end
	return v162;
end;
v22.Text = function(v167, v168)
	local FlatIdent_5C42D = 624 - (332 + 292);
	local v169;
	while true do
		if (FlatIdent_5C42D == (2 + 0)) then
			v2(v167.elements, v169);
			if (v167['ui']['currentTab'] and (v167['ui']['currentTab']['name'] == v167['name'])) then
				v167['ui']:Rerender();
			end
			FlatIdent_5C42D = 8 - 5;
		end
		if (FlatIdent_5C42D == (0 - 0)) then
			v169 = v168;
			v169['type'] = "text";
			FlatIdent_5C42D = 1 + 0;
		end
		if (FlatIdent_5C42D == (2 + 1)) then
			return v169;
		end
		if ((1 + 0) == FlatIdent_5C42D) then
			v169['uid'] = math.random(0 + 0, 1942459 - 942460);
			v169['name'] = v169['name'] or v169['text'];
			FlatIdent_5C42D = 464 - (30 + 432);
		end
	end
end;
v22.Separator = function(v173, v174)
	local FlatIdent_12F6B = 1599 - (1562 + 37);
	local v175;
	while true do
		if ((2 + 1) == FlatIdent_12F6B) then
			v175['text'] = v175['name'];
			v2(v173.elements, v175);
			FlatIdent_12F6B = 10 - 6;
		end
		if ((1366 - (798 + 568)) == FlatIdent_12F6B) then
			v175 = v174 or {};
			v175['type'] = "text";
			FlatIdent_12F6B = 1 + 0;
		end
		if (FlatIdent_12F6B == (1 + 1)) then
			v175['name'] = string.rep("_", v175.width);
			v175['paddingBottom'] = v175['paddingBottom'] or (1671 - (92 + 1565));
			FlatIdent_12F6B = 3 + 0;
		end
		if ((2 + 2) == FlatIdent_12F6B) then
			if (v173['ui']['currentTab'] and (v173['ui']['currentTab']['name'] == v173['name'])) then
				v173['ui']:Rerender();
			end
			break;
		end
		if ((1 + 0) == FlatIdent_12F6B) then
			v175['uid'] = math.random(287 - (64 + 223), 1447457 - 447458);
			v175['width'] = v175['w'] or v175['width'] or v173['ui']['separatorWidth'] or (12 + 33);
			FlatIdent_12F6B = 9 - 7;
		end
	end
end;
v22['Seperator'] = v22['Separator'];
v22['Sep'] = v22['Separator'];
v22.Element = function(v182, v183)
	local FlatIdent_17FB5 = 0 - 0;
	local v184;
	while true do
		if (FlatIdent_17FB5 == (9 - 5)) then
			if (v182['ui']['currentTab'] and (v182['ui']['currentTab']['name'] == v182['name'])) then
				v182['ui']:Rerender();
			end
			break;
		end
		if (FlatIdent_17FB5 == (490 - (227 + 262))) then
			v184 = {};
			v184['type'] = "custom_element";
			FlatIdent_17FB5 = 1 + 1;
		end
		if (FlatIdent_17FB5 == (3 + 0)) then
			v184['uid'] = math.random(0 - 0, 927301 + 72698);
			v2(v182.elements, v184);
			FlatIdent_17FB5 = 1620 - (993 + 623);
		end
		if (FlatIdent_17FB5 == (1882 - (1649 + 231))) then
			v184['category'] = frame['category'];
			v184['frame'] = frame;
			FlatIdent_17FB5 = 3 + 0;
		end
		if (FlatIdent_17FB5 == (0 - 0)) then
			if (v12(v183.factory) ~= "function") then
				return print("You must provide .factory function that builds and returns an instance of your custom element");
			end
			if (v12(v183.category) ~= "string") then
				return print("You must supply .category for UI to identify the type of element");
			end
			FlatIdent_17FB5 = 331 - (148 + 182);
		end
	end
end;
local v49 = {tab={},checkbox={},slider={},dropdown={},multiDropdown={},dropdownMenu={},dropdownMenuScrollFrame={},dropdownScrollChild={},dropdownButton={},dropdownLabel={},text={},secondarySliderThumb={}};
local function v50(v190)
	return ((v190 == "tab") and CreateFrame("Button", nil, nil, nil, "UIPanelButtonTemplate")) or ((v190 == "checkbox") and CreateFrame("CheckButton")) or ((v190 == "slider") and CreateFrame("Slider", "awful-slider-" .. math.random(0 - 0, 461373705 - 361373706), nil, "OptionsSliderTemplate")) or ((v190 == "dropdown") and CreateFrame("Button")) or ((v190 == "multiDropdown") and CreateFrame("Button")) or ((v190 == "dropdownMenu") and CreateFrame("Frame")) or ((v190 == "dropdownMenuScrollFrame") and CreateFrame("ScrollFrame", nil, nil, "UIPanelScrollFrameTemplate")) or ((v190 == "dropdownScrollChild") and CreateFrame("Frame")) or ((v190 == "dropdownButton") and CreateFrame("Button")) or ((v190 == "dropdownLabel") and CreateFrame("Button")) or ((v190 == "text") and CreateFrame("Button")) or ((v190 == "secondarySliderThumb") and CreateFrame("Frame"));
end
local function v51(v191, v192)
	local FlatIdent_32C16 = 0 - 0;
	local v193;
	while true do
		if (FlatIdent_32C16 == (3 - 2)) then
			if v191 then
				v193:SetParent(v191);
			end
			return v193;
		end
		if (FlatIdent_32C16 == (0 + 0)) then
			v193 = v3(v49[v192]) or v50(v192);
			v193:Show();
			FlatIdent_32C16 = 1 - 0;
		end
	end
end
v20.CreateTabList = function(v194)
	local FlatIdent_D53E = 0 + 0;
	local v195;
	while true do
		if (FlatIdent_D53E == (0 + 0)) then
			v195 = v194;
			return setmetatable({}, {__index=function(v598, v599)
				return v195:FindTabObject(v599);
			end});
		end
	end
end;
v20.CreateSection = function(v196, v197, v198, v199, v200, v201)
	v200 = v200 or (10 + 2);
	v199 = v199 or (4 + 8);
	v201 = v201 or (0 + 0);
	local v202 = v196['frame'];
	local v203 = CreateFrame("Frame", v202, BackdropTemplate);
	v202[v197] = v203;
	v203:SetParent(v202);
	v203['elements'] = {};
	v203['tabs'] = v20:CreateTabList();
	v203['ui'] = v196;
	v203['name'] = v197;
	v203:SetHeight(v202:GetHeight() - v200);
	v203:SetWidth(v198 - v201);
	v203:SetPoint("BOTTOMLEFT", v202, "BOTTOMLEFT", v199 + v201, 1411 - (1051 + 360));
	v203['scroll'] = {pos=(1532 - (1504 + 27)),history={},momentum={},frame=CreateFrame("Slider", string.random(44 - 32), v203, "OptionsSliderTemplate")};
	v203.reset = function(v600, v601)
		local FlatIdent_986BD = 0 - 0;
		while true do
			if (FlatIdent_986BD == (1 - 0)) then
				v203['uh'] = 1175 - (404 + 771);
				v203['overflow'] = 1 - 0;
				FlatIdent_986BD = 1 + 1;
			end
			if (FlatIdent_986BD == (3 + 0)) then
				v203['scroll']['pos'] = (v601 and v600['scroll']['pos']) or (2 - 1);
				break;
			end
			if (FlatIdent_986BD == (1362 - (278 + 1084))) then
				v203['vh'] = v203:GetHeight();
				v203['sh'] = v203:GetHeight();
				FlatIdent_986BD = 1902 - (1547 + 354);
			end
			if (FlatIdent_986BD == (1 + 1)) then
				v203['tabs'] = v20:CreateTabList();
				v203['elements'] = {};
				FlatIdent_986BD = 3 + 0;
			end
		end
	end;
	v203:reset();
	local v211 = v203['scroll']['frame'];
	Mixin(v211, BackdropTemplateMixin);
	v211:ClearAllPoints();
	v211:SetPoint("RIGHT", v203, "RIGHT", -(4 - 2), 4 + 1);
	v211:SetFrameStrata("HIGH");
	v211:SetOrientation("VERTICAL");
	v211:SetThumbTexture("Interface\\Buttons\\WHITE8X8");
	v211:SetBackdrop(nil);
	v211:SetBackdropColor(773 - (105 + 668), 0 + 0, 984 - (66 + 918), 0 - 0);
	v211:SetBackdropBorderColor(269 - (70 + 198), 1 + 0, 328 - (82 + 245), 0.6 + 0);
	if v211['NineSlice'] then
		v211['NineSlice']:Hide();
	end
	if v211['Thumb'] then
		local FlatIdent_285DC = 0 - 0;
		while true do
			if (FlatIdent_285DC == (0 - 0)) then
				v211['Thumb']:SetHeight(((v203['vh'] / v203['sh']) * v203:GetHeight()) - (40 - 20));
				v211['Thumb']:SetWidth(1042 - (385 + 655));
				break;
			end
		end
	end
	local v212, v213, v214;
	if (v196['currentTabAccentColors'] or v196['colors']['accent']) then
		v212, v213, v214 = unpack(v196['currentTabAccentColors'] or v196['colors']['accent']);
	else
		v212, v213, v214 = unpack(v27);
	end
	if v211['Thumb'] then
		v211['Thumb']:SetVertexColor(v212, v213, v214, 1 + 0);
	end
	if v211['Thumb'] then
		local FlatIdent_5E57A = 0 - 0;
		while true do
			if (FlatIdent_5E57A == (1350 - (502 + 848))) then
				v211['ThumbPos'] = {v211['Thumb']:GetPoint()};
				Mixin(v211.Thumb, BackdropTemplateMixin);
				FlatIdent_5E57A = 1 + 0;
			end
			if (FlatIdent_5E57A == (1185 - (234 + 950))) then
				v211['Thumb']:SetBackdrop(slider_thumb_bd);
				break;
			end
		end
	end
	v211:SetWidth(11 - 8);
	v211:SetHeight(v203['vh'] - (10 + 0));
	v211:SetMinMaxValues(1 + 0, (v203['overflow'] * v25) + v26);
	v211:SetValue(v203['scroll'].pos);
	v211:SetScript("OnValueChanged", function(v609)
		v203['scroll']['pos'] = v609:GetValue();
	end);
	v211:SetValueStep(105 - (86 + 18));
	getglobal(v211:GetName() .. "Low"):SetText("");
	getglobal(v211:GetName() .. "High"):SetText("");
	local v215 = v196;
	v203:SetScript("OnUpdate", function(v611)
		local FlatIdent_81FDD = 1117 - (30 + 1087);
		local v612;
		local v615;
		local v616;
		local v617;
		local v618;
		local v619;
		while true do
			if (FlatIdent_81FDD == (6 - 3)) then
				if v211['Thumb'] then
					if ((v203['vh'] / v203['sh']) >= (0.98 - 0)) then
						v211['Thumb']:Hide();
					else
						v211['Thumb']:Show();
					end
				end
				v619 = v215['currentTab'];
				if (v619 and v619['scrollPos']) then
					v619['scrollPos'][v197] = v203['scroll']['pos'];
				end
				break;
			end
			if (FlatIdent_81FDD == (1338 - (1040 + 297))) then
				v203['hovering'] = MouseIsOver(v611);
				v615 = 0 + 0;
				v616 = nil;
				v617 = 0.475 + 0;
				FlatIdent_81FDD = 947 - (695 + 250);
			end
			if (FlatIdent_81FDD == (607 - (201 + 404))) then
				v618 = GetTime();
				for v773 = #v203['scroll']['momentum'], 1 + 0, -(2 - 1) do
					local FlatIdent_8822E = 1647 - (261 + 1386);
					local v774;
					local v775;
					local v776;
					local v777;
					while true do
						if (FlatIdent_8822E == (2 + 0)) then
							if (v777 < (0 - 0)) then
								v3(v203['scroll'].momentum, v773);
							else
								local FlatIdent_3D000 = 0 + 0;
								while true do
									if (FlatIdent_3D000 == (0 + 0)) then
										v616 = v775;
										if (v773 == (992 - (600 + 391))) then
											if (v775 == "DOWN") then
												if (v616 ~= "DOWN") then
													local FlatIdent_2C77D = 0 - 0;
													while true do
														if (FlatIdent_2C77D == (676 - (39 + 636))) then
															v615 = v615 + v777;
															break;
														end
														if (FlatIdent_2C77D == (0 + 0)) then
															v615 = 0 - 0;
															v617 = 0 - 0;
															FlatIdent_2C77D = 4 - 3;
														end
													end
												else
													local FlatIdent_6B7BD = 743 - (530 + 213);
													while true do
														if (FlatIdent_6B7BD == (0 + 0)) then
															v615 = v615 + v777;
															v617 = v617 + 0.2 + 0;
															break;
														end
													end
												end
											elseif (v616 ~= "UP") then
												local FlatIdent_4BD2C = 0 + 0;
												while true do
													if (FlatIdent_4BD2C == (2 - 1)) then
														v615 = v615 - v777;
														break;
													end
													if (FlatIdent_4BD2C == (1567 - (95 + 1472))) then
														v615 = 991 - (921 + 70);
														v617 = 0 - 0;
														FlatIdent_4BD2C = 1 + 0;
													end
												end
											else
												local FlatIdent_54897 = 0 - 0;
												while true do
													if (FlatIdent_54897 == (0 + 0)) then
														v615 = v615 - v777;
														v617 = v617 + 0.2 + 0;
														break;
													end
												end
											end
										elseif (v775 == "DOWN") then
											local FlatIdent_3E663 = 0 + 0;
											while true do
												if (FlatIdent_3E663 == (0 + 0)) then
													v615 = v615 + v777;
													v617 = v617 + (1 - 0);
													break;
												end
											end
										else
											local FlatIdent_E741 = 1637 - (93 + 1544);
											while true do
												if (FlatIdent_E741 == (1724 - (1273 + 451))) then
													v615 = v615 - v777;
													v617 = v617 + 1 + 0;
													break;
												end
											end
										end
										break;
									end
								end
							end
							break;
						end
						if (FlatIdent_8822E == (1622 - (348 + 1273))) then
							v776 = v774['ends'];
							v777 = (v776 - v618) / (0.6 - 0);
							FlatIdent_8822E = 2 - 0;
						end
						if (FlatIdent_8822E == (0 - 0)) then
							v774 = v203['scroll']['momentum'][v773];
							v775 = v774['direction'];
							FlatIdent_8822E = 1604 - (1441 + 162);
						end
					end
				end
				v615 = v615 * v617;
				if (abs(v615) > (1349 - (336 + 1013))) then
					v211:SetValue(v211:GetValue() + v615);
				end
				FlatIdent_81FDD = 11 - 8;
			end
			if (FlatIdent_81FDD == (0 + 0)) then
				v612 = ((v203['sh'] > v203['vh']) and v26) or -(5 + 2);
				v203['overflow'] = (v203['sh'] - v203['vh']) + 1 + 0;
				if v211['Thumb'] then
					v211['Thumb']:SetHeight(((v203['vh'] / v203['sh']) * v203:GetHeight()) - (189 - (90 + 79)));
				end
				v211:SetMinMaxValues(2 - 1, (v203['overflow'] * v25) + v612);
				FlatIdent_81FDD = 447 - (274 + 172);
			end
		end
	end);
	v203:SetScript("OnMouseWheel", function(v620, v621)
		if (v621 == -(1 + 0)) then
			v2(v203['scroll'].momentum, {direction="DOWN",ends=(GetTime() + (190.6 - (37 + 153)))});
		elseif (v621 == (1 + 0)) then
			v2(v203['scroll'].momentum, {direction="UP",ends=(GetTime() + (0.6 - 0))});
		end
	end);
	v203.Clear = function(v622, v623)
		local FlatIdent_5A57 = 0 + 0;
		while true do
			if (FlatIdent_5A57 == (741 - (292 + 448))) then
				v203:reset(v623);
				break;
			end
			if (FlatIdent_5A57 == (0 - 0)) then
				if v203['tabs'] then
					for v940, v941 in v11(v203.tabs) do
						local FlatIdent_919DB = 0 + 0;
						while true do
							if (FlatIdent_919DB == (0 - 0)) then
								v941:SetAlpha(1688 - (638 + 1050));
								v941:Hide();
								FlatIdent_919DB = 2 - 1;
							end
							if (FlatIdent_919DB == (1310 - (829 + 480))) then
								v2(v49['tab'], v941);
								break;
							end
						end
					end
				end
				if v203['elements'] then
					for v942, v943 in v11(v203.elements) do
						local FlatIdent_81CE2 = 0 + 0;
						while true do
							if (FlatIdent_81CE2 == (2 - 1)) then
								v943:Hide();
								v2(v49[v943['type']], v943);
								break;
							end
							if (FlatIdent_81CE2 == (0 + 0)) then
								if v943['SetOpen'] then
									v943:SetOpen(false);
								end
								if v943['CleanUp'] then
									v943:CleanUp();
								end
								FlatIdent_81CE2 = 1 - 0;
							end
						end
					end
				end
				FlatIdent_5A57 = 1 + 0;
			end
		end
	end;
	v203.RepositionElements = function(v624, v625)
		local FlatIdent_3C964 = 0 + 0;
		local v626;
		while true do
			if (FlatIdent_3C964 == (0 - 0)) then
				v626 = v624['elements'];
				v624['uh'] = 0 + 0;
				FlatIdent_3C964 = 915 - (287 + 627);
			end
			if (FlatIdent_3C964 == (3 - 2)) then
				for v778, v779 in v11(v626) do
					local v780 = v626[v778 - (1155 - (844 + 309))];
					local v781 = v626[v778 - (3 - 2)];
					local v782;
					if v781 then
						local FlatIdent_7368C = 480 - (75 + 405);
						local v944;
						local v945;
						local v946;
						local v947;
						local v948;
						while true do
							if ((2 - 1) == FlatIdent_7368C) then
								if ((v779['type'] == "checkbox") and (v781['type'] == "checkbox")) then
									if (not v780 or (v780['type'] ~= "checkbox") or (select(885 - (5 + 875), v780:GetPoint()) ~= v947)) then
										local FlatIdent_7795F = 0 + 0;
										local v1164;
										local v1165;
										while true do
											if (FlatIdent_7795F == (1440 - (1239 + 201))) then
												v1164 = v779:GetWidth() + v779['txt']:GetWidth() + v779['textGap'];
												v1165 = v781:GetWidth() + v781['txt']:GetWidth() + v781['textGap'] + v1164;
												FlatIdent_7795F = 1 - 0;
											end
											if ((1 + 0) == FlatIdent_7795F) then
												if (v1165 <= (v624:GetWidth() - v624['ui']['el_padding_right'])) then
													local FlatIdent_841B = 1419 - (120 + 1299);
													local v1187;
													while true do
														if (FlatIdent_841B == (1285 - (204 + 1081))) then
															v782 = true;
															v948 = true;
															FlatIdent_841B = 1 + 0;
														end
														if (FlatIdent_841B == (1 + 1)) then
															v779['originalPos'] = {v779:GetPoint()};
															break;
														end
														if ((887 - (581 + 305)) == FlatIdent_841B) then
															v1187 = v624:GetWidth() - (v1164 + v624['ui']['el_padding_right']);
															v779:SetPoint(v944, v1187, v947);
															FlatIdent_841B = 649 - (36 + 611);
														end
													end
												end
												break;
											end
										end
									end
								end
								if not v948 then
									local FlatIdent_37574 = 0 - 0;
									local v1063;
									local v1064;
									local v1065;
									while true do
										if (FlatIdent_37574 == (525 - (157 + 368))) then
											v1063 = v781['height'];
											v1064 = v781['padding']['bottom'];
											FlatIdent_37574 = 2 - 1;
										end
										if (FlatIdent_37574 == (2 - 1)) then
											v1065 = v1063 + v1064 + v779['padding']['top'];
											v779:SetPoint(v944, 0 + 0 + v779['padding']['left'], v947 - v1065);
											FlatIdent_37574 = 2 + 0;
										end
										if (FlatIdent_37574 == (6 - 4)) then
											v779['originalPos'] = {v779:GetPoint()};
											break;
										end
									end
								end
								break;
							end
							if ((0 - 0) == FlatIdent_7368C) then
								v944, v945, v945, v946, v947 = v781:GetPoint();
								v948 = nil;
								FlatIdent_7368C = 1297 - (749 + 547);
							end
						end
					else
						local FlatIdent_43D7D = 0 + 0;
						while true do
							if (FlatIdent_43D7D == (0 - 0)) then
								v779:SetPoint("TOPLEFT", v624, "TOPLEFT", (0 - 0) + v779['padding']['left'], 404 - (292 + 112));
								v779['originalPos'] = {v779:GetPoint()};
								break;
							end
						end
					end
					if not v782 then
						local FlatIdent_7564C = 0 + 0;
						local v950;
						while true do
							if (FlatIdent_7564C == (0 + 0)) then
								v950 = v779['height'] + v779['padding']['top'] + v779['padding']['bottom'];
								v624['uh'] = v624['uh'] + v950;
								FlatIdent_7564C = 1120 - (801 + 318);
							end
							if (FlatIdent_7564C == (1 + 0)) then
								if (v624['uh'] >= v624['vh']) then
									v624['sh'] = v624['uh'];
								end
								break;
							end
						end
					end
				end
				break;
			end
		end
	end;
	v203.AddElement = function(v628, v629)
		local v630 = v628['elements'];
		local v631;
		if (#v630 > (0 - 0)) then
			local FlatIdent_1FF9F = 1140 - (1139 + 1);
			local v865;
			local v866;
			local v867;
			local v868;
			local v869;
			local v870;
			while true do
				if (FlatIdent_1FF9F == (398 - (105 + 291))) then
					if not v870 then
						local FlatIdent_39A0A = 0 + 0;
						local v1013;
						local v1014;
						local v1015;
						while true do
							if (FlatIdent_39A0A == (2 - 0)) then
								v629['originalPos'] = {v629:GetPoint()};
								break;
							end
							if (FlatIdent_39A0A == (0 + 0)) then
								v1013 = v865['height'];
								v1014 = v865['padding']['bottom'];
								FlatIdent_39A0A = 333 - (327 + 5);
							end
							if (FlatIdent_39A0A == (3 - 2)) then
								v1015 = v1013 + v1014 + v629['padding']['top'];
								v629:SetPoint(v866, (1256 - (28 + 1228)) + v629['padding']['left'], v869 - v1015);
								FlatIdent_39A0A = 4 - 2;
							end
						end
					end
					break;
				end
				if (FlatIdent_1FF9F == (1128 - (491 + 637))) then
					v865 = v630[#v630];
					v866, v867, v867, v868, v869 = v865:GetPoint();
					FlatIdent_1FF9F = 1 + 0;
				end
				if (FlatIdent_1FF9F == (1 - 0)) then
					v870 = nil;
					if ((v629['type'] == "checkbox") and (v865['type'] == "checkbox")) then
						if (not v630[#v630 - (1727 - (829 + 897))] or (v630[#v630 - (157 - (155 + 1))]['type'] ~= "checkbox") or (select(19 - 14, v630[#v630 - (1 + 0)]:GetPoint()) ~= v869)) then
							local FlatIdent_B67B = 0 - 0;
							local v1140;
							local v1141;
							while true do
								if (FlatIdent_B67B == (0 - 0)) then
									v1140 = v629:GetWidth() + v629['txt']:GetWidth() + v629['textGap'];
									v1141 = v865:GetWidth() + v865['txt']:GetWidth() + v865['textGap'] + v1140;
									FlatIdent_B67B = 1222 - (490 + 731);
								end
								if (FlatIdent_B67B == (204 - (78 + 125))) then
									if (v1141 <= (v628:GetWidth() - v628['ui']['el_padding_right'])) then
										local FlatIdent_13E52 = 0 + 0;
										local v1180;
										while true do
											if (FlatIdent_13E52 == (0 + 0)) then
												v631 = true;
												v870 = true;
												FlatIdent_13E52 = 1 + 0;
											end
											if (FlatIdent_13E52 == (1404 - (1360 + 43))) then
												v1180 = v628:GetWidth() - (v1140 + v628['ui']['el_padding_right']);
												v629:SetPoint(v866, v1180, v869);
												FlatIdent_13E52 = 4 - 2;
											end
											if (FlatIdent_13E52 == (1705 - (746 + 957))) then
												v629['originalPos'] = {v629:GetPoint()};
												break;
											end
										end
									end
									break;
								end
							end
						end
					end
					FlatIdent_1FF9F = 1094 - (209 + 883);
				end
			end
		else
			local FlatIdent_7DAA5 = 0 - 0;
			while true do
				if (FlatIdent_7DAA5 == (0 + 0)) then
					v629:SetPoint("TOPLEFT", v628, "TOPLEFT", 0 + 0 + v629['padding']['left'], 0 + 0);
					v629['originalPos'] = {v629:GetPoint()};
					break;
				end
			end
		end
		if not v631 then
			local FlatIdent_7470F = 0 + 0;
			local v872;
			while true do
				if (FlatIdent_7470F == (451 - (156 + 294))) then
					if (v628['uh'] >= v628['vh']) then
						v628['sh'] = v628['uh'];
					end
					break;
				end
				if ((1513 - (414 + 1099)) == FlatIdent_7470F) then
					v872 = v629['height'] + v629['padding']['top'] + v629['padding']['bottom'];
					v628['uh'] = v628['uh'] + v872;
					FlatIdent_7470F = 3 - 2;
				end
			end
		end
		v2(v630, v629);
	end;
	return v203;
end;
v20.Render = function(v219)
	if v219['frame'] then
		return;
	end
	local v220 = CreateFrame("Button", "UIParent", BackdropTemplate);
	v219['frame'] = v220;
	v220['ui'] = v219;
	Mixin(v220, BackdropTemplateMixin);
	v220:SetBackdrop(v219['backdrops'].main);
	v220:SetParent(nil);
	local v223, v224, v225, v226 = unpack(v219['colors'].background);
	v220:SetBackdropColor(v223, v224, v225, v226);
	v220:SetBackdropBorderColor(v223, v224, v225, v226);
	v220:SetHeight(v219.height);
	v220:SetWidth(v219.width);
	local v227 = v219['saved'];
	local v228, v229, v230, v231, v232 = v227['ui_p1'], v227['ui_pframe'], v227['ui_p2'], v227['ui_x'], v227['ui_y'];
	v220:SetPoint(v228 or "CENTER", "UIParent", v230 or "CENTER", v231 or math.random(-(1285 - 985), 1416 - (1076 + 40)), v232 or math.random(-(82 + 18), 394 - 294));
	v220:SetFrameStrata("HIGH");
	v220:SetMovable(true);
	v220:SetScript("OnMouseUp", function(v632)
		local FlatIdent_5136B = 873 - (498 + 375);
		while true do
			if (FlatIdent_5136B == (0 + 0)) then
				v632:StopMovingOrSizing();
				v227['ui_p1'], v227['ui_pframe'], v227['ui_p2'], v227['ui_x'], v227['ui_y'] = v632:GetPoint();
				break;
			end
		end
	end);
	v220:SetScript("OnMouseDown", function(v638)
		local FlatIdent_88720 = 0 + 0;
		while true do
			if (FlatIdent_88720 == (1793 - (1171 + 622))) then
				v638:StartMoving();
				v227['ui_p1'], v227['ui_pframe'], v227['ui_p2'], v227['ui_x'], v227['ui_y'] = v638:GetPoint();
				break;
			end
		end
	end);
	local v233 = {duration=(0.25 - 0),y_offset=(1608 - (1447 + 131))};
	v220.SetOpen = function(v644, v645)
		local FlatIdent_4A588 = 0 - 0;
		local v646;
		local v647;
		while true do
			if (FlatIdent_4A588 == (1 - 0)) then
				v646 = v9(v646, 0 + 0);
				v647 = nil;
				FlatIdent_4A588 = 1068 - (550 + 516);
			end
			if (FlatIdent_4A588 == (0 + 0)) then
				v646 = 0 - 0;
				if v644['animating'] then
					if not v644['secondAnimation'] then
						local FlatIdent_907E6 = 1592 - (511 + 1081);
						while true do
							if (FlatIdent_907E6 == (869 - (258 + 611))) then
								v645 = not v645;
								v646 = (v644['animating']['ends'] - GetTime()) + ((6 - 3) / GetFramerate());
								FlatIdent_907E6 = 2 - 1;
							end
							if (FlatIdent_907E6 == (61 - (50 + 10))) then
								v644['animating']['ends'] = v644['animating']['ends'] + v646;
								v644['secondAnimation'] = true;
								break;
							end
						end
					else
						return;
					end
				else
					v644['secondAnimation'] = false;
				end
				FlatIdent_4A588 = 1 + 0;
			end
			if (FlatIdent_4A588 == (823 - (697 + 124))) then
				function v647()
					local FlatIdent_1F94E = 403 - (224 + 179);
					local v783;
					local v784;
					local v786;
					local v787;
					local v788;
					local v789;
					local v790;
					local v791;
					local v792;
					local v793;
					local v794;
					while true do
						if (FlatIdent_1F94E == (2 - 0)) then
							v794 = nil;
							function v794(v875)
								local FlatIdent_6DB33 = 0 - 0;
								local v876;
								local v877;
								local v878;
								local v879;
								local v880;
								local v881;
								local v882;
								while true do
									if (FlatIdent_6DB33 == (0 - 0)) then
										v783 = GetTime();
										if (v783 >= v793) then
											local FlatIdent_7CCC5 = 0 - 0;
											while true do
												if (FlatIdent_7CCC5 == (0 - 0)) then
													v875:Cancel();
													v220['animating'] = nil;
													FlatIdent_7CCC5 = 1 - 0;
												end
												if (FlatIdent_7CCC5 == (1 + 0)) then
													if not v645 then
														v220:Hide();
													end
													return true;
												end
											end
										end
										v876 = (1060 - (1033 + 26)) - ((v793 - v783) / v792);
										v877 = v790 + v791;
										FlatIdent_6DB33 = 681 - (504 + 176);
									end
									if (FlatIdent_6DB33 == (1347 - (1021 + 324))) then
										v882 = v6(v790, v877, v880);
										v220:SetAlpha(v881);
										v220:SetPoint(v786, "UIParent", v788, v789, v882);
										break;
									end
									if ((1 + 0) == FlatIdent_6DB33) then
										v878 = (v645 and (1857 - (411 + 1445))) or (0.01 - 0);
										v879 = (v645 and (1035.01 - (949 + 86))) or (1 + 0);
										v880 = v7(v876, 1423.13 - (1366 + 57), 1074.1 - (752 + 321), 32.2 - (7 + 24), 1.3 + 0);
										v881 = v18(v6(v879, v878, v880));
										FlatIdent_6DB33 = 642 - (178 + 462);
									end
								end
							end
							C_Timer.NewTicker(0 + 0, v794);
							break;
						end
						if (FlatIdent_1F94E == (0 + 0)) then
							if (v645 and not v220:IsShown()) then
								v220:Show();
							end
							v783 = GetTime();
							v784 = {open=v645,point={v220:GetPoint()},started=v783,ends=(v783 + v233['duration'])};
							v220['animating'] = v784;
							FlatIdent_1F94E = 1 + 0;
						end
						if ((1 - 0) == FlatIdent_1F94E) then
							v786, v787, v788, v789, v790 = unpack(v784.point);
							v791 = (v645 and v233['y_offset']) or -v233['y_offset'];
							v792 = v233['duration'];
							v793 = v784['ends'];
							FlatIdent_1F94E = 1 + 1;
						end
					end
				end
				C_Timer.After(v646, v647);
				break;
			end
		end
	end;
	v219['cmd']:New(function(v648)
		if (v648:gsub(" ", "") == "") then
			local FlatIdent_67DC5 = 77 - (20 + 57);
			while true do
				if (FlatIdent_67DC5 == (0 - 0)) then
					if v220:IsShown() then
						v220:SetOpen(false);
					else
						v220:SetOpen(true);
					end
					return true;
				end
			end
		end
	end);
	v219.UpdateTitle = function(v649, v650, v651)
		v651 = v651 or v649['title'];
		v650 = v650 or v649['colors'];
		if (v12(v651) == "table") then
			local FlatIdent_1ABF5 = 0 + 0;
			local v883;
			while true do
				if (FlatIdent_1ABF5 == (0 + 0)) then
					v883 = v651['size'];
					C_Timer.After(0.1 - 0, function()
						for v1022, v1023 in v11(v651) do
							local FlatIdent_1A126 = 249 - (136 + 113);
							local v1024;
							local v1025;
							local v1026;
							local v1027;
							local v1028;
							local v1029;
							local v1030;
							while true do
								if (FlatIdent_1A126 == (2 + 0)) then
									v1027:SetFont(v29, v1029, "");
									v1027:SetText(v1030);
									if (v1022 == (3 - 2)) then
										v1027:SetPoint("TOPLEFT", v220, "TOPLEFT", 24 - 12, -(36 - 24));
									else
										local FlatIdent_167F8 = 0 + 0;
										local v1144;
										local v1145;
										local v1146;
										local v1147;
										local v1148;
										while true do
											if (FlatIdent_167F8 == (993 - (527 + 465))) then
												v1148 = v1144:GetWidth() + (620.2 - (374 + 246));
												v1027:SetPoint("TOPLEFT", v220, "TOPLEFT", v1146 + v1148, v1147);
												break;
											end
											if (FlatIdent_167F8 == (1778 - (1501 + 277))) then
												v1144 = v220["title" .. (v1022 - (1 - 0))];
												v1145, v1145, v1145, v1146, v1147 = v1144:GetPoint();
												FlatIdent_167F8 = 1448 - (1145 + 302);
											end
										end
									end
									v1027:SetTextColor(v1024, v1025, v1026);
									break;
								end
								if (FlatIdent_1A126 == (0 + 0)) then
									v1024, v1025, v1026 = nil;
									if (v650['title'] and v650['title'][v1022]) then
										v1024, v1025, v1026 = unpack(v650['title'][v1022]);
									else
										v1024, v1025, v1026 = unpack(v649['colors'].primary);
									end
									if not v220["title" .. v1022] then
										v220["title" .. v1022] = v220:CreateFontString("tfontstringz", "OVERLAY");
									end
									v1027 = v220["title" .. v1022];
									FlatIdent_1A126 = 1 + 0;
								end
								if (FlatIdent_1A126 == (2 - 1)) then
									v1028 = v12(v1023) == "table";
									v1029 = (v1028 and v1023['size']) or v883 or (25 - 11);
									v1030 = v1023;
									if v1028 then
										v1030 = v1023['text'];
									end
									FlatIdent_1A126 = 1 + 1;
								end
							end
						end
					end);
					break;
				end
			end
		elseif (v12(v651) == "string") then
			local FlatIdent_3D531 = 0 - 0;
			local v1031;
			local v1032;
			local v1033;
			local v1034;
			local v1035;
			while true do
				if (FlatIdent_3D531 == (467 - (299 + 167))) then
					if not v220['title'] then
						v220['title'] = v220:CreateFontString("ftitle2z", "OVERLAY");
					end
					v1034 = v220['title'];
					FlatIdent_3D531 = 3 - 1;
				end
				if ((1845 - (605 + 1237)) == FlatIdent_3D531) then
					v1034:SetText(v651);
					v1034:SetPoint("TOPLEFT", v220, "TOPLEFT", 12 + 0, -(1195 - (643 + 540)));
					FlatIdent_3D531 = 129 - (59 + 66);
				end
				if (FlatIdent_3D531 == (508 - (354 + 150))) then
					v1034:SetTextColor(v1031, v1032, v1033);
					break;
				end
				if ((3 - 1) == FlatIdent_3D531) then
					v1035 = v649['titleSize'] or (45 - 31);
					v1034:SetFont(v29, v1035, "");
					FlatIdent_3D531 = 10 - 7;
				end
				if (FlatIdent_3D531 == (1824 - (900 + 924))) then
					v1031, v1032, v1033 = nil;
					if v650['title'] then
						v1031, v1032, v1033 = unpack(v650.title);
					elseif v650['primary'] then
						v1031, v1032, v1033 = unpack(v650.primary);
					else
						v1031, v1032, v1033 = 1249 - (46 + 1202), 1 + 0, 1 - 0;
					end
					FlatIdent_3D531 = 2 - 1;
				end
			end
		end
		local v652, v653, v654 = unpack(v650['accent'] or v649['colors']['accent']);
		for v795, v796 in v11(v649.sections) do
			if (v796['scroll'] and v796['scroll']['frame']) then
				local FlatIdent_4363A = 1818 - (728 + 1090);
				while true do
					if (FlatIdent_4363A == (1917 - (765 + 1152))) then
						if v796['scroll']['frame']['Thumb'] then
							v796['scroll']['frame']['Thumb']:SetVertexColor(v652, v653, v654, 1 + 0);
						end
						if v796['scroll']['frame']['NineSlice'] then
							v796['scroll']['frame']['NineSlice']:Hide();
						end
						break;
					end
				end
			end
		end
	end;
	v219:UpdateTitle();
	v220['exit'] = CreateFrame("BUTTON", "", v220);
	v220['exitCircle'] = v220:CreateTexture("fexitbttn", "OVERLAY");
	v220['exitCircle']:SetTexture(v1['dep'].GetSpellIcon(221 - 103));
	v220['exitCircle']:SetWidth(4 + 2);
	v220['exitCircle']:SetHeight(786 - (336 + 444));
	v220['exitCircle']:SetColorTexture(1 + 0, (162 - 80) / (116 + 139), (100 - (8 + 10)) / (1845 - (515 + 1075)), 1 + 0);
	v220['exitCircle']:SetPoint("TOPRIGHT", v220, "TOPRIGHT", -(704 - (669 + 22)), -(3 + 10));
	v220['exitCircleMask'] = v220:CreateMaskTexture();
	v220['exitCircleMask']:SetAllPoints(v220.exitCircle);
	v220['exitCircleMask']:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
	v220['exitCircle']:AddMaskTexture(v220.exitCircleMask);
	v220['exit']:SetAlpha(0 + 0);
	v220['exit']:SetSize(1719 - (814 + 887), 59 - 41);
	v220['exit']:SetPoint("TOPRIGHT", v220, "TOPRIGHT", -(750 - (146 + 600)), -(11 - 7));
	v220['exit']:RegisterForClicks("AnyUp");
	v220['exit']:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up");
	v220['exit']:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down");
	v220['exit']:SetScript("OnClick", function()
		v220:SetOpen(false);
	end);
	v220['exit']:SetScript("OnEnter", function()
		v220['exitCircle']:SetColorTexture(1 + 0, (4 + 121) / (95 + 160), (89 + 36) / (31 + 224), 1540 - (1231 + 308));
	end);
	v220['exit']:SetScript("OnLeave", function()
		v220['exitCircle']:SetColorTexture(320 - (27 + 292), (301 - 219) / (205 + 50), (45 + 37) / (685 - 430), 4 - 3);
	end);
	local v239 = 1596 - (1103 + 493);
	if v220['title'] then
		v239 = v239 + v220['title']:GetWidth();
	end
	for v655 = 996 - (565 + 430), 99 - (39 + 30) do
		if v220["title" .. v655] then
			v239 = v239 + v220["title" .. v655]:GetWidth();
		end
	end
	local v240 = v219['tabs_w'] or v9(548 - (263 + 175), v239 + 3 + 22);
	local v241 = v220:GetWidth();
	if (v240 > (61 + 49)) then
		local FlatIdent_3A28B = 596 - (208 + 388);
		while true do
			if (FlatIdent_3A28B == (1384 - (825 + 559))) then
				v220:SetWidth((v241 + v240) - (899 - (420 + 369)));
				v241 = (v241 + v240) - (566 - (213 + 243));
				break;
			end
		end
	end
	local v242 = 140 - 100;
	local v243 = 0 - 0;
	local v244 = 1 + 9;
	if (v219['sidebar'] ~= false) then
		local FlatIdent_51AE = 0 + 0;
		local v798;
		local v799;
		local v800;
		local v801;
		while true do
			if (FlatIdent_51AE == (1 + 3)) then
				v220['tertiaryAccent']:SetWidth(v240 + 1 + 0);
				v220['tertiaryAccent']:SetPoint("BOTTOMLEFT", v220, "BOTTOMLEFT", 0 - 0, 0 + 0);
				break;
			end
			if (FlatIdent_51AE == (3 - 2)) then
				v220['tertiaryAccent']:SetFrameStrata("LOW");
				Mixin(v220.tertiaryAccent, BackdropTemplateMixin);
				FlatIdent_51AE = 1049 - (553 + 494);
			end
			if (FlatIdent_51AE == (1406 - (674 + 729))) then
				v220['tertiaryAccent']:SetBackdropColor(v798, v799, v800, v801);
				v220['tertiaryAccent']:SetHeight(v220:GetHeight());
				FlatIdent_51AE = 2 + 2;
			end
			if (FlatIdent_51AE == (1904 - (1253 + 651))) then
				v220['tertiaryAccent'] = CreateFrame("Frame", v220, BackdropTemplate);
				v220['tertiaryAccent']:SetParent(v220);
				FlatIdent_51AE = 1 + 0;
			end
			if (FlatIdent_51AE == (522 - (297 + 223))) then
				v798, v799, v800, v801 = unpack(v219['colors'].tertiary);
				v220['tertiaryAccent']:SetBackdrop(v219['backdrops'].white);
				FlatIdent_51AE = 250 - (177 + 70);
			end
		end
	end
	local v245 = v219:CreateSection("tabs", v240, v243, v242);
	v241 = v241 - v240;
	v243 = v243 + v245:GetWidth();
	local v246 = v219:CreateSection("view", v241, v243, v242, v244);
	v2(v219.sections, v246);
	v220:SetScript("OnClick", function(v656)
		for v802, v803 in v11(v656['ui'].sections) do
			for v884, v885 in v11(v803.elements) do
				if v885['SetOpen'] then
					v885:SetOpen(false);
				end
			end
		end
	end);
	v220:SetScale(v219['scale'] or (1158 - (1080 + 77)));
	if not v219['show'] then
		v220:Hide();
	end
end;
local function v55(v247)
	local FlatIdent_636AB = 1912 - (781 + 1131);
	while true do
		if (FlatIdent_636AB == (2 + 0)) then
			v247['right'] = v247['right'] or (0 + 0);
			return v247;
		end
		if (FlatIdent_636AB == (1 + 0)) then
			v247['bottom'] = v247['bottom'] or (0 - 0);
			v247['left'] = v247['left'] or (957 - (102 + 855));
			FlatIdent_636AB = 212 - (197 + 13);
		end
		if (FlatIdent_636AB == (0 - 0)) then
			v247 = v247 or {};
			v247['top'] = v247['top'] or (0 + 0);
			FlatIdent_636AB = 1 + 0;
		end
	end
end
v20.RenderGroup = function(v252, v253, v254)
	local FlatIdent_8C9E6 = 577 - (371 + 206);
	while true do
		if (FlatIdent_8C9E6 == (0 - 0)) then
			v252:RenderTab(v253, v254);
			if v253['open'] then
				for v886, v887 in v11(v253.tabs) do
					local FlatIdent_1DF7C = 1145 - (1020 + 125);
					local v888;
					while true do
						if (FlatIdent_1DF7C == (536 - (514 + 22))) then
							v888 = {};
							for v952, v953 in v10(v254) do
								v888[v952] = v953;
							end
							FlatIdent_1DF7C = 4 - 3;
						end
						if (FlatIdent_1DF7C == (1791 - (1534 + 256))) then
							v252:RenderTab(v887, v888);
							break;
						end
					end
				end
			end
			break;
		end
	end
end;
local function v57(v255)
	local FlatIdent_3A7C0 = 194 - (183 + 11);
	while true do
		if (FlatIdent_3A7C0 == (12 - 8)) then
			v255['uid'] = nil;
			v255['tooltip'] = nil;
			break;
		end
		if (FlatIdent_3A7C0 == (1 + 0)) then
			v255['elements'] = nil;
			v255['tabs'] = nil;
			FlatIdent_3A7C0 = 1642 - (557 + 1083);
		end
		if (FlatIdent_3A7C0 == (0 + 0)) then
			v255['name'] = nil;
			v255['group'] = nil;
			FlatIdent_3A7C0 = 2 - 1;
		end
		if (FlatIdent_3A7C0 == (7 - 5)) then
			v255['group'] = nil;
			v255['Collapse'] = nil;
			FlatIdent_3A7C0 = 8 - 5;
		end
		if (FlatIdent_3A7C0 == (5 - 2)) then
			v255['Expand'] = nil;
			v255['init'] = nil;
			FlatIdent_3A7C0 = 13 - 9;
		end
	end
end
v20.RenderTab = function(v265, v266, v267)
	parent = v265['frame']['tabs'];
	parent['tabs'] = parent['tabs'] or v265:CreatTabList();
	local v270 = v51(parent, "tab");
	v270:SetFrameStrata("HIGH");
	local v271 = v266['name'];
	v270['UI'] = v265;
	v57(v270);
	v270['uid'] = v266['uid'];
	v270['group'] = v266['group'];
	v270['name'] = v271;
	v270['elements'] = v266['elements'];
	v270['inGroup'] = v266['inGroup'];
	local v282 = 1 + 12;
	v270['height'] = v282;
	v270['padding'] = v55(v267);
	v270['padding']['left'] = v270['padding']['left'] + (v5(v270.inGroup) * (2 + 2));
	local v286 = v265;
	local function v287()
		v286:SetTab(v270);
	end
	v270:SetText(v271);
	if not v270['group'] then
		v270:SetScript("OnClick", v287);
	else
		v270:SetScript("OnClick", function(v889, v890)
			v266:Toggle();
		end);
	end
	v270:GetFontString():SetFont(v29, v282, "");
	local v288, v289, v290, v291 = unpack(v265['colors'].primary);
	v270:GetFontString():SetTextColor(v288, v289, v290, v291 or (560 - (363 + 196)));
	v270:GetFontString():SetSize(parent:GetWidth(), v282);
	v270:GetFontString():SetPoint("LEFT", 0 - 0, 0 - 0);
	v270:GetFontString():SetPoint("RIGHT", (-v270:GetWidth() + parent:GetWidth()) - v265['el_padding_right'], 0 + 0);
	v270:GetFontString():SetJustifyV("MIDDLE");
	v270:GetFontString():SetJustifyH("LEFT");
	v270:SetSize(parent:GetWidth() - v265['el_padding_right'], v282);
	if (#parent['tabs'] > (212 - (87 + 125))) then
		local FlatIdent_6740C = 0 - 0;
		local v804;
		local v805;
		local v806;
		local v807;
		local v808;
		local v809;
		local v810;
		local v811;
		while true do
			if (FlatIdent_6740C == (3 - 2)) then
				v809 = v804:GetHeight();
				v810 = v804['padding']['bottom'];
				FlatIdent_6740C = 1 + 1;
			end
			if ((2 + 0) == FlatIdent_6740C) then
				v811 = v809 + v810;
				v270:SetPoint(v805, v270['padding'].left, v808 - v811);
				FlatIdent_6740C = 1666 - (567 + 1096);
			end
			if (FlatIdent_6740C == (9 - 6)) then
				v270['originalPos'] = {v270:GetPoint()};
				break;
			end
			if (FlatIdent_6740C == (0 + 0)) then
				v804 = parent['tabs'][#parent['tabs']];
				v805, v806, v806, v807, v808 = v804:GetPoint();
				FlatIdent_6740C = 340 - (277 + 62);
			end
		end
	else
		local FlatIdent_6ADA5 = 848 - (275 + 573);
		while true do
			if (FlatIdent_6ADA5 == (0 - 0)) then
				v270:SetPoint("TOPLEFT", parent, "TOPLEFT", ((1510 - (911 + 599)) + v270['padding']['left']) - v270['padding']['right'], (0 - 0) + v270['padding']['top']);
				v270['originalPos'] = {v270:GetPoint()};
				break;
			end
		end
	end
	v270.SetInteractive = function(v657, v658)
		local FlatIdent_88425 = 0 - 0;
		while true do
			if (FlatIdent_88425 == (0 - 0)) then
				v657:SetEnabled(v658);
				v657:EnableMouse(v658);
				break;
			end
		end
	end;
	v270:SetScript("OnUpdate", function()
		local FlatIdent_157D0 = 0 + 0;
		local v659;
		local v660;
		local v661;
		local v662;
		local v663;
		local v664;
		local v665;
		local v666;
		local v667;
		local v668;
		local v669;
		local v670;
		while true do
			if (FlatIdent_157D0 == (0 + 0)) then
				if not v270['init'] then
					local FlatIdent_77960 = 0 - 0;
					while true do
						if (FlatIdent_77960 == (0 + 0)) then
							v270['init'] = true;
							return;
						end
					end
				end
				v659, v660, v661, v662, v663 = unpack(v270.originalPos);
				v664 = v663 + (v660['scroll']['pos'] / v25);
				FlatIdent_157D0 = 1 + 0;
			end
			if (FlatIdent_157D0 == (1703 - (1423 + 276))) then
				if ((v670 == v270['uid']) or (v270['group'] and v270['group']:ContainsTab(v670))) then
					local FlatIdent_26B42 = 1645 - (232 + 1413);
					local v893;
					local v894;
					local v895;
					local v896;
					while true do
						if (FlatIdent_26B42 == (566 - (293 + 273))) then
							v893, v894, v895 = nil;
							v896 = v270['group'] or v270['inGroup'];
							FlatIdent_26B42 = 1091 - (979 + 111);
						end
						if (FlatIdent_26B42 == (2 - 1)) then
							if (v896 and v896['colors'] and v896['colors']['accent']) then
								v893, v894, v895 = unpack(v896['colors'].accent);
							elseif (v265['colors'] and v265['colors']['accent']) then
								v893, v894, v895 = unpack(v265['colors'].accent);
							else
								v893, v894, v895 = unpack(v27);
							end
							v270:GetFontString():SetTextColor(v893, v894, v895, 1 + 0);
							break;
						end
					end
				elseif not MouseIsOver(v270) then
					local FlatIdent_1E0DA = 0 - 0;
					local v1037;
					local v1038;
					local v1039;
					local v1040;
					local v1041;
					local v1042;
					while true do
						if (FlatIdent_1E0DA == (24 - (11 + 13))) then
							v1037, v1038, v1039 = nil;
							v1040, v1041, v1042 = nil;
							FlatIdent_1E0DA = 1 + 0;
						end
						if (FlatIdent_1E0DA == (26 - (11 + 14))) then
							if v265['colors'] then
								local FlatIdent_80B6D = 0 - 0;
								while true do
									if (FlatIdent_80B6D == (0 + 0)) then
										if v265['colors']['accent'] then
											v1037, v1038, v1039 = unpack(v265['colors'].accent);
										else
											v1037, v1038, v1039 = 3 - 2, 1 - 0, 1 - 0;
										end
										if v265['colors']['primary'] then
											v1040, v1041, v1042 = unpack(v265['colors'].primary);
										end
										break;
									end
								end
							end
							v270:GetFontString():SetTextColor(v288, v289, v290, v291 or (1 + 0));
							break;
						end
					end
				end
				break;
			end
			if (FlatIdent_157D0 == (583 - (198 + 382))) then
				if (v664 > (0 - 0)) then
					local FlatIdent_14132 = 0 - 0;
					local v892;
					while true do
						if (FlatIdent_14132 == (0 - 0)) then
							v892 = v18((0.95 - 0) - ((v664 - (v270['height'] / (786 - (615 + 169)))) / v668));
							v270:SetAlpha(v892);
							break;
						end
					end
				elseif (v666 < (v270['height'] + v667)) then
					local FlatIdent_5AB5F = 633 - (632 + 1);
					local v1036;
					while true do
						if (FlatIdent_5AB5F == (0 + 0)) then
							v1036 = ((v660['overflow'] * v25) + v26) - v660['scroll']['pos'];
							v270:SetAlpha(v18((v666 / (v270['height'] + v667)) + v18((-v1036 + v669) / (278 - 178))));
							break;
						end
					end
				else
					v270:SetAlpha(1 + 0);
				end
				if (v270:GetAlpha() <= (0.25 - 0)) then
					v270:SetInteractive(false);
				else
					v270:SetInteractive(true);
				end
				v670 = v265['currentTab'] and v265['currentTab']['uid'];
				FlatIdent_157D0 = 4 + 0;
			end
			if (FlatIdent_157D0 == (443 - (59 + 383))) then
				v270:SetPoint(v659, v660, v661, v662, v664);
				v665 = abs(v664);
				v666 = (v660['vh'] - v665) - v270['height'];
				FlatIdent_157D0 = 2 - 0;
			end
			if ((1666 - (574 + 1090)) == FlatIdent_157D0) then
				v667 = 137 - (14 + 117);
				v668 = 30 - 16;
				v669 = 260 - 155;
				FlatIdent_157D0 = 1 + 2;
			end
		end
	end);
	local v293, v294, v295;
	local v296 = v270['group'] or v270['inGroup'];
	if (v296 and v296['colors'] and v296['colors']['accent']) then
		v293, v294, v295 = unpack(v296['colors'].accent);
	elseif (v265['colors'] and v265['colors']['accent']) then
		v293, v294, v295 = unpack(v265['colors'].accent);
	else
		v293, v294, v295 = unpack(v27);
	end
	v270:SetScript("OnEnter", function(v671)
		v671:GetFontString():SetTextColor(v293 * (1.2 - 0), v294 * (1.2 + 0), v295 * (3.2 - 2), 0.95 + 0);
	end);
	v2(parent.tabs, v270);
	local v297 = v282 + v270['padding']['top'] + v270['padding']['bottom'];
	parent['uh'] = parent['uh'] + v297;
	if (parent['uh'] >= parent['vh']) then
		parent['sh'] = parent['uh'];
	end
	return v270;
end;
v20.ShowTooltip = function(v299, v300)
	local FlatIdent_3AF7C = 0 - 0;
	local v301;
	local v302;
	local v303;
	local v304;
	local v305;
	local v306;
	local v307;
	local v308;
	local v309;
	local v310;
	local v311;
	while true do
		if ((1 + 3) == FlatIdent_3AF7C) then
			GameTooltip:SetWidth(v299['frame']:GetWidth());
			GameTooltip:SetMinimumWidth(v299['frame']:GetWidth() + 30 + 0);
			v306, v307, v308, v309, v310, v311 = unpack(v299['shadows'].primary);
			FlatIdent_3AF7C = 1 + 4;
		end
		if (FlatIdent_3AF7C == (1 + 1)) then
			GameTooltip:SetBackdrop(v299['backdrops'].main);
			GameTooltip:SetBackdropColor(v301, v302, v303, v304 or (0.7 + 0));
			GameTooltip:SetBackdropBorderColor(v301, v302, v303, v304 or (0.7 - 0));
			FlatIdent_3AF7C = 5 - 2;
		end
		if (FlatIdent_3AF7C == (1 + 4)) then
			for v672 = 1165 - (757 + 407), GameTooltip:NumLines() do
				local FlatIdent_86B18 = 0 + 0;
				local v673;
				while true do
					if (FlatIdent_86B18 == (6 - 4)) then
						v673:SetShadowOffset(v310, v311);
						break;
					end
					if (FlatIdent_86B18 == (0 - 0)) then
						v673 = _G["GameTooltipTextLeft" .. tostring(v672)];
						v673:SetFont(v29, 4.5 + 6, "");
						FlatIdent_86B18 = 2 - 1;
					end
					if (FlatIdent_86B18 == (3 - 2)) then
						v673:SetJustifyH("LEFT");
						v673:SetShadowColor(v306, v307, v308, v309);
						FlatIdent_86B18 = 1 + 1;
					end
				end
			end
			GameTooltip:SetScale(v299.scale);
			GameTooltip:Show();
			break;
		end
		if (FlatIdent_3AF7C == (4 - 1)) then
			GameTooltip['NineSlice']:Hide();
			v305 = v17(v299['colors'].primary);
			GameTooltip:AddLine(v305 .. v300, nil, nil, nil, true);
			FlatIdent_3AF7C = 1620 - (871 + 745);
		end
		if (FlatIdent_3AF7C == (4 - 3)) then
			GameTooltip:SetOwner(v299.frame);
			GameTooltip:SetAnchorType("ANCHOR_TOPLEFT", 1994 - (114 + 1880), 2 + 0);
			Mixin(GameTooltip, BackdropTemplateMixin);
			FlatIdent_3AF7C = 2 + 0;
		end
		if (FlatIdent_3AF7C == (0 - 0)) then
			if not v300 then
				return;
			end
			if (v299['frame']['animating'] and not v299['frame']['animating']['open']) then
				return;
			end
			v301, v302, v303, v304 = unpack(v299['colors'].background);
			FlatIdent_3AF7C = 1517 - (335 + 1181);
		end
	end
end;
v20.HideTooltip = function(v312)
	local FlatIdent_8B17F = 1542 - (1092 + 450);
	while true do
		if ((0 - 0) == FlatIdent_8B17F) then
			GameTooltip:SetBackdrop(nil);
			GameTooltip['NineSlice']:Show();
			FlatIdent_8B17F = 1798 - (80 + 1717);
		end
		if (FlatIdent_8B17F == (6 - 4)) then
			GameTooltip:Hide();
			break;
		end
		if (FlatIdent_8B17F == (2 - 1)) then
			GameTooltipText:SetFont("Fonts\\FRIZQT__.TTF", 1816 - (703 + 1101), "");
			for v674 = 1133 - (34 + 1098), GameTooltip:NumLines() do
				local FlatIdent_80FB4 = 0 + 0;
				local v675;
				while true do
					if (FlatIdent_80FB4 == (0 + 0)) then
						v675 = _G["GameTooltipTextLeft" .. tostring(v674)];
						v675:SetFont("Fonts\\FRIZQT__.TTF", 652 - (264 + 375), "");
						FlatIdent_80FB4 = 1 + 0;
					end
					if (FlatIdent_80FB4 == (4 - 3)) then
						v675:SetJustifyH("LEFT");
						break;
					end
				end
			end
			FlatIdent_8B17F = 799 - (629 + 168);
		end
	end
end;
local function v61(v313)
	local FlatIdent_370C6 = 222 - (25 + 197);
	local v314;
	local v315;
	local v316;
	local v317;
	local v318;
	local v319;
	local v320;
	local v321;
	local v322;
	local v323;
	local v324;
	while true do
		if (FlatIdent_370C6 == (1163 - (182 + 981))) then
			v314, v315, v316, v317, v318 = unpack(v313.originalPos);
			v319 = v318 + (v313['parent']['scroll']['pos'] / v25);
			FlatIdent_370C6 = 1 + 0;
		end
		if (FlatIdent_370C6 == (9 - 7)) then
			v321 = (v313['parent']['vh'] - v320) - v313['height'];
			v322 = 1724 - (1422 + 290);
			FlatIdent_370C6 = 423 - (287 + 133);
		end
		if (FlatIdent_370C6 == (1418 - (105 + 1310))) then
			v323 = 1 + 5;
			v324 = 39 + 66;
			FlatIdent_370C6 = 1 + 3;
		end
		if (FlatIdent_370C6 == (1623 - (1334 + 285))) then
			if (not v313['pauseAlpha'] or ((GetTime() - v313['pauseAlpha']) > ((1 + 1) / GetFramerate()))) then
				if (v319 > (438 - (352 + 86))) then
					v313:SetAlpha(v18((148 - (82 + 65)) - (v319 / v9(v323, (v323 + 14 + 10) - (v313['height'] / (1861 - (291 + 1568)))))));
				elseif (v321 < v322) then
					local FlatIdent_29945 = 0 + 0;
					local v1069;
					while true do
						if (FlatIdent_29945 == (0 + 0)) then
							v1069 = ((v313['parent']['overflow'] * v25) + v26) - v313['parent']['scroll']['pos'];
							v313:SetAlpha(v18((v321 / v322) + v9(1991 - (1377 + 614), (-v1069 + v324) / (244 - 144))));
							break;
						end
					end
				else
					v313:SetAlpha(2 - 1);
				end
			end
			if (v313:GetAlpha() <= (0.25 + 0)) then
				v313:SetInteractive(false);
			else
				v313:SetInteractive(true);
			end
			break;
		end
		if (FlatIdent_370C6 == (627 - (480 + 146))) then
			v313:SetPoint(v314, v315, v316, v317, v319);
			v320 = abs(v319);
			FlatIdent_370C6 = 913 - (881 + 30);
		end
	end
end
local function v62(v325, v326)
	return v4(v325 / v326) * v326;
end
local v63 = {OnEnter=function(v327)
	if v327['tooltip'] then
		v327['ui']:ShowTooltip(v327.tooltip);
	end
end,OnLeave=function(v328)
	if v328['tooltip'] then
		v328['ui']:HideTooltip(v328.tooltip);
	end
end,checkbox={OnClick=function(v329)
	if v329:GetChecked() then
		v329['saved'][v329['var']] = true;
	else
		v329['saved'][v329['var']] = false;
	end
end,OnUpdate=function(v330)
	local FlatIdent_99094 = 0 - 0;
	local v331;
	while true do
		if (FlatIdent_99094 == (1315 - (310 + 1004))) then
			v61(v330);
			break;
		end
		if ((0 + 0) == FlatIdent_99094) then
			v331 = v330['saved'][v330['var']];
			if ((v331 ~= nil) and (v331 ~= v330:GetChecked())) then
				v330:SetChecked(v331);
			end
			FlatIdent_99094 = 841 - (441 + 399);
		end
	end
end},slider={OnUpdate=function(v332)
	local FlatIdent_6CB99 = 0 - 0;
	local v333;
	while true do
		if (FlatIdent_6CB99 == (244 - (242 + 2))) then
			v333 = v332['saved'][v332['var']];
			if ((v333 ~= nil) and (v333 ~= v62(v332:GetValue(), v332.step))) then
				v332:SetValue(v62(v332:GetValue(), v332.step));
			end
			FlatIdent_6CB99 = 995 - (457 + 537);
		end
		if ((1 + 0) == FlatIdent_6CB99) then
			v61(v332);
			break;
		end
	end
end,OnValueChanged=function(v334, v335)
	local FlatIdent_9226C = 1109 - (191 + 918);
	local v336;
	while true do
		if (FlatIdent_9226C == (339 - (335 + 4))) then
			v336 = v62(v334:GetValue(), v334.step);
			v334['saved'][v334['var']] = v336;
			FlatIdent_9226C = 76 - (71 + 4);
		end
		if (FlatIdent_9226C == (1 - 0)) then
			v334['TEXT']:SetText(v334['text'] .. ": " .. v334['valueColor'] .. v336 .. ((v334['valueType'] and v334['valueType']) or (v334['percentage'] and "%") or ""));
			break;
		end
	end
end},dropdown={OnClick=function(v338, v339)
	if (v339 == "LeftButton") then
		v338:SetOpen();
	elseif (v339 == "RightButton") then
		if not v338['multi'] then
			if not v338['default'] then
				v338:SetSelected(nil);
			else
				v338:SetSelected(v338.default);
			end
		else
			v338:SetSelected(nil);
		end
	end
end,OnUpdate=function(v340)
	local FlatIdent_5269C = 0 + 0;
	local v341;
	local v342;
	while true do
		if (FlatIdent_5269C == (1835 - (834 + 999))) then
			if not v340['multi'] then
				if (v340['labelType'] ~= v340['colorType']) then
					local FlatIdent_1631C = 1152 - (129 + 1023);
					local v958;
					local v959;
					local v960;
					local v961;
					while true do
						if (FlatIdent_1631C == (0 + 0)) then
							v340['colorType'] = v340['labelType'];
							v958, v959, v960, v961 = unpack(v340['ui']['colors'].primary);
							FlatIdent_1631C = 399 - (264 + 134);
						end
						if ((1302 - (171 + 1130)) == FlatIdent_1631C) then
							if (v340['labelType'] == "value") then
								v340['label']:SetTextColor(v958, v959, v960, v961 or (952 - (337 + 614)));
							elseif (v340['labelType'] == "placeholder") then
								v340['label']:SetTextColor(v958 * (0.8 + 0), v959 * (0.8 + 0), v960 * (0.8 + 0), 1 + 0);
							end
							break;
						end
					end
				end
			end
			if (v340['scroll']['child']:GetHeight() <= v340['scroll']['frame']:GetHeight()) then
				v342:Hide();
			end
			FlatIdent_5269C = 3 - 0;
		end
		if ((0 + 0) == FlatIdent_5269C) then
			v341 = v340['saved'][v340['var']];
			if not v340['multi'] then
				if ((v341 ~= nil) and (v341 ~= v340['value'])) then
					local FlatIdent_19A2 = 0 + 0;
					local v955;
					while true do
						if (FlatIdent_19A2 == (0 + 0)) then
							v955 = v340:FindOptionByValue(v341);
							if v955 then
								v340:SetSelected(v955);
							end
							break;
						end
					end
				elseif ((v340['value'] ~= nil) and (v341 == nil)) then
					v340:SetSelected(nil);
				end
			elseif v340['placeholder'] then
				if (#v340['labels'] == (0 + 0)) then
					v340['label']:Show();
				else
					v340['label']:Hide();
				end
			end
			FlatIdent_5269C = 1850 - (312 + 1537);
		end
		if (FlatIdent_5269C == (1 + 2)) then
			v61(v340);
			break;
		end
		if (FlatIdent_5269C == (2 - 1)) then
			v342 = v340['scroll']['frame']['ScrollBar'];
			if (v342['ScrollUpButton']:IsShown() or v342['ScrollDownButton']:IsShown()) then
				local FlatIdent_5073 = 0 + 0;
				while true do
					if ((0 - 0) == FlatIdent_5073) then
						v342['ScrollUpButton']:Hide();
						v342['ScrollDownButton']:Hide();
						break;
					end
				end
			end
			FlatIdent_5269C = 2 + 0;
		end
	end
end},text={OnUpdate=function(v343)
	v61(v343);
end}};
local v64 = {CleanUp=function(v344)
	local FlatIdent_90FF4 = 1383 - (1258 + 125);
	while true do
		if (FlatIdent_90FF4 == (0 - 0)) then
			if v344['label'] then
				v344['label']:Hide();
			end
			for v676, v677 in v11(v344.labels) do
				local FlatIdent_74773 = 1373 - (914 + 459);
				while true do
					if (FlatIdent_74773 == (0 + 0)) then
						v677['text']:Hide();
						v677:Hide();
						FlatIdent_74773 = 415 - (131 + 283);
					end
					if ((2 - 1) == FlatIdent_74773) then
						v2(v49.dropdownLabel, v677);
						break;
					end
				end
			end
			break;
		end
	end
end,ClearMenuButtons=function(v345)
	local FlatIdent_739AF = 0 + 0;
	while true do
		if (FlatIdent_739AF == (0 + 0)) then
			if not v345['buttons'] then
				return;
			end
			for v678, v679 in v11(v345.buttons) do
				local FlatIdent_98328 = 0 - 0;
				while true do
					if (FlatIdent_98328 == (1 + 0)) then
						v2(v49.dropdownButton, v679);
						break;
					end
					if ((0 - 0) == FlatIdent_98328) then
						if v679['txt'] then
							v679['txt']:Hide();
						end
						v679:Hide();
						FlatIdent_98328 = 1 - 0;
					end
				end
			end
			break;
		end
	end
end,RerenderDropdownMenu=function(v346)
	v346:ClearMenuButtons();
	v346['buttons'] = {};
	local v348 = v346;
	local v349 = v346['menu_padding'];
	local v350 = v346['button_height'];
	local v351 = v349;
	local v352 = v346['ui'];
	local v353, v354, v355 = unpack(v352['currentTabAccentColors'] or v352['colors']['accent']);
	local v356, v357, v358, v359 = unpack(v352['colors'].primary);
	local v360, v361, v362, v363 = unpack(v352['colors'].tertiary);
	local v364, v365, v366, v367 = unpack(v352['colors'].background);
	local v368, v369, v370, v371, v372, v373 = unpack(v352['shadows'].primary);
	for v680, v681 in v11(v346.options) do
		if ((v12(v346.selected) ~= "table") or not v346['selected'][v681['value']]) then
			local FlatIdent_2512D = 632 - (210 + 422);
			local v897;
			local v902;
			local v903;
			local v904;
			local v905;
			while true do
				if (FlatIdent_2512D == (2 + 0)) then
					v897:GetHighlightTexture():SetPoint("RIGHT", 616 - (355 + 259), 1155 - (361 + 794));
					v897:GetHighlightTexture():SetPoint("TOP", 0 + 0, 0 - 0);
					v897:GetHighlightTexture():SetPoint("BOTTOM", 1183 - (208 + 975), 0 - 0);
					v897:SetWidth(v346['scroll']['child']:GetWidth() - v352['el_padding_right']);
					FlatIdent_2512D = 593 - (586 + 4);
				end
				if (FlatIdent_2512D == (3 + 1)) then
					v897['txt']:ClearAllPoints();
					v897['txt']:SetFont(v29, 1117 - (1067 + 41), "");
					v897['txt']:SetText(v681.label);
					v897['txt']:SetWidth(v897:GetWidth());
					FlatIdent_2512D = 720 - (272 + 443);
				end
				if (FlatIdent_2512D == (6 - 3)) then
					v897:SetHeight(v350);
					v897:SetScript("OnClick", function(v962, v963)
						v348:SetSelected(v962.option);
					end);
					v897['option'] = v681;
					v897['txt'] = v897:CreateFontString("", "OVERLAY", nil);
					FlatIdent_2512D = 4 + 0;
				end
				if (FlatIdent_2512D == (2 + 3)) then
					v897['txt']:SetJustifyH("LEFT");
					v897['txt']:SetPoint("LEFT", 10 - 6, 0 - 0);
					v897['txt']:SetPoint("RIGHT", -(55 - 35), 1944 - (392 + 1552));
					v897['txt']:SetHeight(v897:GetHeight());
					FlatIdent_2512D = 161 - (29 + 126);
				end
				if (FlatIdent_2512D == (1 - 0)) then
					v897:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD");
					v897:GetHighlightTexture():SetVertexColor(v353 / (1.4 + 0), v354 / (1.4 + 0), v355 / (1619.4 - (1051 + 567)), 0.2 + 0);
					v897:GetHighlightTexture():ClearAllPoints();
					v897:GetHighlightTexture():SetPoint("LEFT", -(13 - 7), 0 - 0);
					FlatIdent_2512D = 1103 - (70 + 1031);
				end
				if (FlatIdent_2512D == (18 - 11)) then
					v2(v346.buttons, v897);
					v351 = v351 + v350;
					break;
				end
				if (FlatIdent_2512D == (0 + 0)) then
					v897 = v51(v346['scroll'].child, "dropdownButton");
					v897['ui'] = v346['ui'];
					if v681['tooltip'] then
						local FlatIdent_FC43 = 1937 - (1083 + 854);
						while true do
							if ((662 - (181 + 481)) == FlatIdent_FC43) then
								v897['tooltip'] = v681['tooltip'];
								v897:SetScript("OnEnter", v63.OnEnter);
								FlatIdent_FC43 = 2 - 1;
							end
							if (FlatIdent_FC43 == (573 - (502 + 70))) then
								v897:SetScript("OnLeave", v63.OnLeave);
								break;
							end
						end
					else
						local FlatIdent_A2BB = 1070 - (419 + 651);
						while true do
							if ((0 + 0) == FlatIdent_A2BB) then
								v897:SetScript("OnEnter", function()
								end);
								v897:SetScript("OnLeave", function()
								end);
								break;
							end
						end
					end
					v897:SetPoint("TOP", v346['scroll'].child, "TOP", 0 - 0, -v351);
					FlatIdent_2512D = 2 - 1;
				end
				if (FlatIdent_2512D == (1 + 5)) then
					v902, v903, v904, v905 = v356, v357, v358, v359;
					v897['txt']:SetTextColor(v353, v354, v355, v18(v905 or (80 - (17 + 62))));
					v897['txt']:SetShadowColor(v368, v369, v370, v371 / (9 - 5));
					v897['txt']:SetShadowOffset(v372, v373);
					FlatIdent_2512D = 25 - 18;
				end
			end
		end
	end
	v346['scroll']['child']:SetHeight(v351 + v349);
	v346['scroll']['frame']:SetHeight(v8((v350 * (1301 - (613 + 683))) + (v349 * (1759 - (465 + 1292))), v351 + v349));
	local v370 = v346['scroll']['frame']['ScrollBar'];
	v370['ThumbTexture']:SetTexture("Interface\\Buttons\\WHITE8X8");
	v370['ThumbTexture']:SetVertexColor(v353, v354, v355, 2 - 1);
	v370['ThumbTexture']:SetWidth(1 + 2);
	v370['ThumbTexture']:SetHeight(1738 - (1088 + 618));
	v370:ClearAllPoints();
	v370:SetHeight(v346['scroll']['frame']:GetHeight() - (1754 - (227 + 1519)));
	v370:SetWidth(4 - 2);
	v370:SetPoint("RIGHT", -(2 - 1), 0 + 0);
end,SetOpen=function(v374, ...)
	local FlatIdent_6DCDB = 0 + 0;
	local v375;
	local v376;
	while true do
		if (FlatIdent_6DCDB == (0 - 0)) then
			v375 = {...};
			v376 = v375[#v375];
			FlatIdent_6DCDB = 1 - 0;
		end
		if (FlatIdent_6DCDB == (873 - (730 + 142))) then
			if (v376 ~= nil) then
				v374['open'] = v376;
			else
				v374['open'] = not v374['open'];
			end
			if v374['open'] then
				local FlatIdent_2A0E1 = 1881 - (1745 + 136);
				while true do
					if (FlatIdent_2A0E1 == (1 + 0)) then
						v374['arrow']:SetRotation(rad(0 - 0));
						v374['arrow']:SetPoint("RIGHT", v374, "RIGHT", v374.initArrowX, v374.initArrowY);
						break;
					end
					if (FlatIdent_2A0E1 == (0 - 0)) then
						for v906, v907 in v11(v374['parent'].elements) do
							if (v907['SetOpen'] and (v907['uid'] ~= v374['uid'])) then
								v907:SetOpen(false);
							end
						end
						v374['menu']:Show();
						FlatIdent_2A0E1 = 1 + 0;
					end
				end
			else
				local FlatIdent_2EAA7 = 0 - 0;
				while true do
					if (FlatIdent_2EAA7 == (0 - 0)) then
						v374['menu']:Hide();
						v374['arrow']:SetRotation(rad(1243 - (242 + 911)));
						FlatIdent_2EAA7 = 1 - 0;
					end
					if (FlatIdent_2EAA7 == (1 + 0)) then
						v374['arrow']:SetPoint("RIGHT", v374, "RIGHT", v374.initArrowX, v374.initArrowY);
						break;
					end
				end
			end
			break;
		end
	end
end,RemoveLabel=function(v377, v378, v379)
	local FlatIdent_55304 = 1704 - (921 + 783);
	while true do
		if (FlatIdent_55304 == (0 + 0)) then
			if not v378 then
				return;
			end
			for v682, v683 in v11(v377.labels) do
				if (v683['option'] and (v683['option']['value'] == v378['value'])) then
					local FlatIdent_492CA = 0 + 0;
					while true do
						if (FlatIdent_492CA == (0 + 0)) then
							v683:Hide();
							v2(v49.dropdownLabel, v377);
							FlatIdent_492CA = 1 - 0;
						end
						if (FlatIdent_492CA == (653 - (432 + 220))) then
							v3(v377.labels, v682);
							if not v379 then
								v377:RearrangeLabels();
							end
							break;
						end
					end
				end
			end
			break;
		end
	end
end,RearrangeLabels=function(v380)
	local FlatIdent_71FFA = 0 + 0;
	local v381;
	local v385;
	local v386;
	local v387;
	local v388;
	while true do
		if ((586 - (31 + 553)) == FlatIdent_71FFA) then
			v385 = v380:GetWidth();
			v386 = v380['label_padding'];
			FlatIdent_71FFA = 3 - 0;
		end
		if (FlatIdent_71FFA == (5 - 1)) then
			for v684, v685 in v11(v380.labels) do
				local FlatIdent_4330F = 0 + 0;
				local v686;
				while true do
					if (FlatIdent_4330F == (708 - (9 + 698))) then
						v685:SetPoint("TOPLEFT", v386 + v380['label_padding'], v387);
						v386 = v386 + v685:GetWidth() + v380['label_padding'];
						FlatIdent_4330F = 1 + 1;
					end
					if (FlatIdent_4330F == (2 - 0)) then
						v388 = v387;
						if v686 then
							local FlatIdent_6EA31 = 0 + 0;
							local v909;
							while true do
								if (FlatIdent_6EA31 == (0 + 0)) then
									v909 = v380:GetHeight();
									v380:SetHeight(v909 + v380['label_line_height']);
									FlatIdent_6EA31 = 849 - (846 + 2);
								end
								if (FlatIdent_6EA31 == (1 + 1)) then
									if v380['scroll'] then
										v380['scroll']['frame']:SetPoint("TOP", 1566 - (179 + 1387), -v380:GetHeight());
									end
									break;
								end
								if (FlatIdent_6EA31 == (2 - 1)) then
									v380['height'] = v380['height'] + v380['label_line_height'];
									v380['lines_added'] = v380['lines_added'] + (3 - 2);
									FlatIdent_6EA31 = 1 + 1;
								end
							end
						end
						break;
					end
					if ((0 + 0) == FlatIdent_4330F) then
						v686 = nil;
						if ((((v385 - v386) - v685:GetWidth()) - v380['label_padding']) <= v380['label_container_padding_right']) then
							local FlatIdent_83FE6 = 0 + 0;
							while true do
								if (FlatIdent_83FE6 == (272 - (133 + 139))) then
									v386 = v380['label_padding'];
									v387 = v387 - v380['label_line_height'];
									FlatIdent_83FE6 = 1 + 0;
								end
								if (FlatIdent_83FE6 == (333 - (16 + 316))) then
									v686 = true;
									break;
								end
							end
						end
						FlatIdent_4330F = 3 - 2;
					end
				end
			end
			if (v380['lines_added'] ~= v381) then
				local FlatIdent_16774 = 1283 - (1018 + 265);
				while true do
					if (FlatIdent_16774 == (0 + 0)) then
						v380:SetHeight(v380['original_height'] + (v380['lines_added'] * v380['label_line_height']));
						if v380['scroll'] then
							v380['scroll']['frame']:SetPoint("TOP", 0 - 0, -v380:GetHeight());
						end
						FlatIdent_16774 = 981 - (126 + 854);
					end
					if (FlatIdent_16774 == (800 - (735 + 64))) then
						v380['parent']:RepositionElements();
						break;
					end
				end
			end
			break;
		end
		if (FlatIdent_71FFA == (0 + 0)) then
			v381 = v380['lines_added'];
			v380['lines_added'] = 0 - 0;
			FlatIdent_71FFA = 635 - (549 + 85);
		end
		if ((8 - 5) == FlatIdent_71FFA) then
			v387 = -v380['label_padding'] * (2 - 0);
			v388 = -v380['label_padding'] * (1873 - (827 + 1044));
			FlatIdent_71FFA = 1 + 3;
		end
		if (FlatIdent_71FFA == (1349 - (881 + 467))) then
			v380:SetHeight(v380.original_height);
			v380['height'] = v380['original_height'];
			FlatIdent_71FFA = 675 - (301 + 372);
		end
	end
end,AppendLabel=function(v389, v390)
	local FlatIdent_13395 = 1291 - (464 + 827);
	local v391;
	local v392;
	local v393;
	local v394;
	local v395;
	local v396;
	local v397;
	local v398;
	local v399;
	local v400;
	local v401;
	local v404;
	local v405;
	local v406;
	local v407;
	local v409;
	local v410;
	local v411;
	while true do
		if (FlatIdent_13395 == (820 - (204 + 616))) then
			if not v390 then
				return;
			end
			v391, v392, v393, v394 = unpack(v389['ui']['currentTabAccentColors'] or v389['ui']['colors']['accent']);
			v395, v396, v397, v398, v399, v400 = unpack(v389['ui']['shadows'].primary);
			v401 = CreateFrame("Button");
			v401:ClearAllPoints();
			FlatIdent_13395 = 1 + 0;
		end
		if (FlatIdent_13395 == (1023 - (941 + 77))) then
			v407:SetShadowOffset(v399, v400);
			v407:SetHeight(v389.label_height);
			v401:SetWidth(2471 - (482 + 989));
			v401:SetHeight(v389.label_height);
			v409 = v389:GetWidth();
			FlatIdent_13395 = 15 - 9;
		end
		if (FlatIdent_13395 == (2 - 1)) then
			v401:SetParent(v389);
			Mixin(v401, BackdropTemplateMixin);
			v401:SetBackdrop(v389['ui']['backdrops'].main);
			v401:SetBackdropBorderColor(v391, v392, v393, 0.6 + 0);
			v401:SetBackdropColor(v391, v392, v393, 1911.6 - (502 + 1409));
			FlatIdent_13395 = 4 - 2;
		end
		if (FlatIdent_13395 == (628 - (524 + 100))) then
			v407 = v401:CreateFontString();
			v401['text'] = v407;
			v407:SetFont(v29, v4(v389['label_height'] * (451.6 - (273 + 178))), "");
			v407:SetText(v390.label);
			v407:SetShadowColor(v395, v396, v397, v398 / (1887.5 - (700 + 1186)));
			FlatIdent_13395 = 3 + 2;
		end
		if (FlatIdent_13395 == (1003 - (217 + 780))) then
			v410 = v8((v409 / (9 - 7)) - (8 + 2), v407:GetWidth() + (v389['label_padding'] * (658 - (101 + 555))));
			v411 = nil;
			if ((((v409 - v404) - v410) - v389['label_padding']) <= v389['label_container_padding_right']) then
				local FlatIdent_79F18 = 660 - (108 + 552);
				while true do
					if (FlatIdent_79F18 == (1 + 0)) then
						v411 = true;
						break;
					end
					if (FlatIdent_79F18 == (0 + 0)) then
						v404 = v389['label_padding'];
						v405 = v405 - v389['label_line_height'];
						FlatIdent_79F18 = 1 - 0;
					end
				end
			end
			v401:SetWidth(v410);
			v407:SetPoint("LEFT", 5 - 1, 0 - 0);
			FlatIdent_13395 = 2 + 5;
		end
		if (FlatIdent_13395 == (23 - 16)) then
			v407:SetPoint("RIGHT", -(4 + 0), 0 - 0);
			v401:SetPoint("TOPLEFT", v404 + v389['label_padding'], v405);
			v2(v389.labels, v401);
			if v411 then
				local FlatIdent_42509 = 1645 - (264 + 1381);
				local v821;
				while true do
					if (FlatIdent_42509 == (0 - 0)) then
						v821 = v389:GetHeight();
						v389:SetHeight(v821 + v389['label_line_height']);
						FlatIdent_42509 = 988 - (382 + 605);
					end
					if (FlatIdent_42509 == (1 + 1)) then
						if v389['scroll'] then
							v389['scroll']['frame']:SetPoint("TOP", 0 + 0, -v389:GetHeight());
						end
						v389['parent']:RepositionElements();
						break;
					end
					if (FlatIdent_42509 == (1 + 0)) then
						v389['height'] = v389['height'] + v389['label_line_height'];
						v389['lines_added'] = v389['lines_added'] + (2 - 1);
						FlatIdent_42509 = 4 - 2;
					end
				end
			end
			break;
		end
		if (FlatIdent_13395 == (1942 - (333 + 1606))) then
			v401:SetScript("OnLeave", function()
				v63.OnLeave(v389);
			end);
			v404 = v389['label_padding'];
			v405 = -v389['label_padding'] * (1 + 1);
			v406 = nil;
			for v689 = #v389['labels'], 123 - (12 + 110), -(62 - (56 + 5)) do
				local v690 = v389['labels'][v689];
				local v691, v692 = select(4 - 0, v690:GetPoint());
				local v693 = v690:GetWidth();
				v405 = v692;
				if (not v406 or (abs(v406 - v692) < (1 + 1))) then
					local FlatIdent_3722F = 175 - (43 + 132);
					while true do
						if (FlatIdent_3722F == (679 - (655 + 24))) then
							v404 = v404 + v693 + v389['label_padding'];
							v406 = v692;
							break;
						end
					end
				else
					v405 = v406;
					break;
				end
			end
			FlatIdent_13395 = 3 + 1;
		end
		if (FlatIdent_13395 == (4 - 2)) then
			v401['option'] = v390;
			v401['parent'] = v389;
			v401:RegisterForClicks("AnyUp");
			v401:SetScript("OnClick", function(v687, v688)
				v687['parent']:Deselect(v687.option);
			end);
			v401:SetScript("OnEnter", function()
				v63.OnEnter(v389);
			end);
			FlatIdent_13395 = 1 + 2;
		end
	end
end,SetSelected=function(v412, v413)
	local FlatIdent_690D = 0 + 0;
	while true do
		if ((0 - 0) == FlatIdent_690D) then
			if ((v12(v413) == "string") or (v12(v413) == "number") or ((v12(v413) == "table") and not v413['value'])) then
				v413 = v412:FindOptionByValue(v413);
			end
			if v412['multi'] then
				local FlatIdent_3D20D = 0 + 0;
				local v825;
				local v827;
				while true do
					if (FlatIdent_3D20D == (667 - (360 + 304))) then
						for v912, v913 in v11(v412.options) do
							if not v412['selected'][v913['value']] then
								v827 = v827 + 1 + 0;
							end
						end
						if (v827 == (0 + 0)) then
							v412:SetOpen(false);
						end
						break;
					end
					if (FlatIdent_3D20D == (0 - 0)) then
						v412['selected'] = v412['selected'] or {};
						v825 = nil;
						FlatIdent_3D20D = 2 - 1;
					end
					if (FlatIdent_3D20D == (1668 - (11 + 1656))) then
						if v413 then
							local FlatIdent_5BD74 = 0 + 0;
							while true do
								if (FlatIdent_5BD74 == (0 - 0)) then
									if v412['selected'][v413['value']] then
										v825 = true;
									end
									if v413['tvalue'] then
										v412['selected'][v413['value']] = v413['tvalue'];
									else
										v412['selected'][v413['value']] = true;
									end
									break;
								end
							end
						end
						v412['saved'][v412['var']] = v412['selected'];
						FlatIdent_3D20D = 5 - 3;
					end
					if (FlatIdent_3D20D == (998 - (64 + 932))) then
						if not v825 then
							local FlatIdent_24725 = 0 - 0;
							while true do
								if (FlatIdent_24725 == (0 - 0)) then
									v412:AppendLabel(v413);
									v412:RerenderDropdownMenu();
									break;
								end
							end
						end
						v827 = 1701 - (1412 + 289);
						FlatIdent_3D20D = 7 - 4;
					end
				end
			else
				local FlatIdent_93EC = 376 - (240 + 136);
				while true do
					if (FlatIdent_93EC == (0 + 0)) then
						v412['selected'] = v413;
						if v412['label'] then
							local FlatIdent_43840 = 0 - 0;
							while true do
								if (FlatIdent_43840 == (0 + 0)) then
									v412['label']:SetText((v413 and v413['label']) or v412['placeholder'] or "");
									v412['labelType'] = (v413 and "value") or "placeholder";
									FlatIdent_43840 = 1 - 0;
								end
								if ((1 + 0) == FlatIdent_43840) then
									v412['value'] = (v413 and v413['value']) or nil;
									v412['saved'][v412['var']] = (v413 and v413['value']) or nil;
									break;
								end
							end
						end
						FlatIdent_93EC = 370 - (327 + 42);
					end
					if (FlatIdent_93EC == (3 - 2)) then
						v412:SetOpen(false);
						break;
					end
				end
			end
			break;
		end
	end
end,Deselect=function(v414, v415)
	local FlatIdent_55A3D = 0 + 0;
	while true do
		if (FlatIdent_55A3D == (0 + 0)) then
			if ((v12(v415) == "string") or (v12(v415) == "number") or ((v12(v415) == "table") and not v415['value'])) then
				v415 = v414:FindOptionByValue(v415);
			end
			if v414['multi'] then
				if v415 then
					local FlatIdent_2BB14 = 0 + 0;
					local v967;
					while true do
						if (FlatIdent_2BB14 == (106 - (83 + 20))) then
							v414:RerenderDropdownMenu();
							break;
						end
						if (FlatIdent_2BB14 == (1654 - (136 + 1516))) then
							v414['selected'][v415['value']] = nil;
							v414:RemoveLabel(v415);
							FlatIdent_2BB14 = 989 - (705 + 281);
						end
						if (FlatIdent_2BB14 == (779 - (573 + 205))) then
							v967[v415['value']] = nil;
							v414['saved'][v414['var']] = v967;
							FlatIdent_2BB14 = 557 - (6 + 549);
						end
						if (FlatIdent_2BB14 == (0 - 0)) then
							v967 = {};
							for v1045, v1046 in v10(v414.selected) do
								v967[v1045] = v1046;
							end
							FlatIdent_2BB14 = 1845 - (973 + 871);
						end
					end
				end
			end
			break;
		end
	end
end,FindOptionByValue=function(v416, v417)
	for v694, v695 in v11(v416.options) do
		if (v695['value'] == v417) then
			return v695;
		end
	end
end};
v22.RenderElement = function(v418, v419)
	local FlatIdent_7D25C = 1859 - (1262 + 597);
	local v420;
	local v421;
	local v422;
	local v423;
	local v424;
	local v425;
	local v426;
	local v427;
	local v428;
	local v429;
	local v430;
	local v431;
	local v432;
	local v433;
	local v434;
	local v435;
	local v436;
	local v437;
	local v438;
	local v439;
	local v440;
	local v441;
	local v442;
	local v443;
	local v444;
	local v445;
	local v446;
	local v447;
	local v448;
	local v449;
	local v450;
	while true do
		if (FlatIdent_7D25C == (1015 - (65 + 942))) then
			if (v419['type'] == "checkbox") then
				local FlatIdent_93068 = 0 - 0;
				local v829;
				local v830;
				local v838;
				local v839;
				local v840;
				local v841;
				local v842;
				while true do
					if (FlatIdent_93068 == (17 - 12)) then
						v829['border']:SetHeight(1308.65 - (631 + 666));
						v829['border']:SetPoint("CENTER", v829, "CENTER", -(876.00032 - (367 + 509)), 0 + 0);
						v829:SetCheckedTexture(v829.checkedTexture);
						v829:GetNormalTexture():SetVertexColor(v440, v441, v442, 0.9 + 0);
						v829['checkedTexture']:AddMaskTexture(v829.mask);
						FlatIdent_93068 = 4 + 2;
					end
					if (FlatIdent_93068 == (1 + 0)) then
						v829['padding']['bottom'] = 251 - (62 + 184);
						v829:SetSize(v830, v830);
						v829:SetNormalTexture("Interface\\Buttons\\WHITE8X8");
						v829:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD");
						v829:GetHighlightTexture():SetVertexColor(296.3 - (152 + 144), 0.3 - 0, 0.3 + 0, 0.3 + 0);
						FlatIdent_93068 = 2 + 0;
					end
					if ((5 - 2) == FlatIdent_93068) then
						v829['checkedTexture']:SetPoint("CENTER", v829, "CENTER", -(0.00072 + 0), 0 - 0);
						v829['checkedTexture']:Hide();
						v829['mask'] = v829:CreateMaskTexture();
						v829['mask']:SetAllPoints(v829.checkedTexture);
						v829['mask']:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
						FlatIdent_93068 = 190 - (81 + 105);
					end
					if (FlatIdent_93068 == (3 + 5)) then
						v841 = 995 - (938 + 49);
						v842 = v829:GetFontString();
						if (v14(v423) < (v422:GetWidth() / v841)) then
						else
						end
						v842:SetTextColor(v432, v433, v434, v435 or (1 + 0));
						v842:SetHeight(98 - 78);
						FlatIdent_93068 = 505 - (58 + 438);
					end
					if ((35 - 25) == FlatIdent_93068) then
						v829:SetAlpha(0 + 0);
						v829['pauseAlpha'] = GetTime();
						v422:AddElement(v829);
						break;
					end
					if (FlatIdent_93068 == (518 - (396 + 113))) then
						v842:SetPoint("LEFT", v8(v422:GetWidth() - (9 + 5), v14(v423) * v841), -(0.75 + 0));
						v842:SetPoint("RIGHT", v829.textGap, -(511.75 - (225 + 286)));
						v842:SetJustifyV("MIDDLE");
						v842:SetJustifyH("LEFT");
						v829['txt'] = v842;
						FlatIdent_93068 = 6 + 4;
					end
					if (FlatIdent_93068 == (0 - 0)) then
						v829 = v450;
						v830 = 4.4 + 6;
						v829['height'] = v830;
						v829['textGap'] = 4 + 1;
						v829['padding']['top'] = 1040 - (74 + 961);
						FlatIdent_93068 = 1 + 0;
					end
					if (FlatIdent_93068 == (659 - (121 + 531))) then
						v829:SetScript("OnUpdate", v63['checkbox'].OnUpdate);
						v829:SetText(v423);
						v829:GetFontString():SetFont(v29, 28 - 19, "");
						v829:GetFontString():SetShadowColor(v444, v445, v446, v447);
						v829:GetFontString():SetShadowOffset(v448, v449);
						FlatIdent_93068 = 5 + 3;
					end
					if (FlatIdent_93068 == (771 - (678 + 87))) then
						v829:SetFrameStrata("HIGH");
						v829:SetChecked(v425[v424]);
						if (v428 == true) then
							if (v425[v424] == nil) then
								local FlatIdent_471DB = 0 + 0;
								while true do
									if ((0 + 0) == FlatIdent_471DB) then
										v829:SetChecked(v428);
										v425[v424] = v428;
										break;
									end
								end
							end
						end
						v829:SetScript("OnClick", v63['checkbox'].OnClick);
						if v829['tooltip'] then
							local FlatIdent_412AE = 1129 - (330 + 799);
							while true do
								if (FlatIdent_412AE == (0 + 0)) then
									v829:SetScript("OnEnter", v63.OnEnter);
									v829:SetScript("OnLeave", v63.OnLeave);
									break;
								end
							end
						end
						FlatIdent_93068 = 1607 - (332 + 1268);
					end
					if ((29 - (18 + 9)) == FlatIdent_93068) then
						v829['checkedTexture'] = v829:CreateTexture("fchktxtr", "ARTWORK");
						v829['checkedTexture']:SetTexture("Interface\\Buttons\\WHITE8X8");
						v829['checkedTexture']:SetColorTexture(v429, v430, v431, 442 - (278 + 163));
						v829['checkedTexture']:SetWidth(8 + 1);
						v829['checkedTexture']:SetHeight(1639 - (443 + 1187));
						FlatIdent_93068 = 1248 - (589 + 656);
					end
					if (FlatIdent_93068 == (19 - 15)) then
						v829['border'] = v829:CreateTexture("fchktxtr", "BORDER");
						v829['border']:SetTexture("Interface\\Buttons\\WHITE8X8");
						v838, v839, v840 = unpack(v420['currentTabAccentColors'] or v420['colors']['accent']);
						v829['border']:SetColorTexture(v838, v839, v840, 385.7 - (204 + 181));
						v829['border']:SetWidth(15.65 - 4);
						FlatIdent_93068 = 1 + 4;
					end
				end
			elseif (v419['type'] == "slider") then
				local v971 = v450;
				Mixin(v971, BackdropTemplateMixin);
				v971:ClearAllPoints();
				v971['min'] = v419['min'];
				v971['max'] = v419['max'];
				v971['value'] = v425[v424] or v419['value'] or v419['default'] or v419['min'];
				v971['step'] = v419['step'] or (2 - 1);
				v971['percentage'] = v419['percentage'];
				v971['valueType'] = v419['valueType'];
				v971['low'] = (v419['low'] or v419['min']) .. ((v971['valueType'] and v971['valueType']) or (v971['percentage'] and "%") or "");
				v971['high'] = (v419['high'] or v419['max']) .. ((v971['valueType'] and v971['valueType']) or (v971['percentage'] and "%") or "");
				v971['text'] = v419['text'];
				local v986 = -(6 - 4);
				v971['height'] = 4 + 20;
				v971['padding']['top'] = 18 + 6;
				local v989 = v422['elements'][#v422['elements']];
				if (v989 and ((v989['type'] == "slider") or (v989['type'] == "dropdown"))) then
					v971['padding']['top'] = v971['padding']['top'] - (18 - 12);
				end
				v971['padding']['bottom'] = 2 + 4;
				v971['padding']['left'] = v986;
				v971:ClearAllPoints();
				v971:SetBackdrop(v420['backdrops'].white);
				v971:SetBackdropColor(v440 * v420['colors']['elMod'], v441 * v420['colors']['elMod'], v442 * v420['colors']['elMod'], v420['colors'].elAlpha);
				local v992 = 8 + 2;
				v971['thumbSize'] = v992;
				if v971['NineSlice'] then
					v971['NineSlice']:Hide();
				end
				v971['thumbTexture'] = v971:CreateTexture("sliderBnThing", "ARTWORK");
				v971['thumbTexture']:SetTexture("Interface\\Buttons\\WHITE8X8");
				v971['thumbTexture']:SetWidth(v992);
				v971['thumbTexture']:SetHeight(v992);
				v971['thumbTexture']:SetColorTexture(v429, v430, v431, 3 - 2);
				v971['thumbTexture']:ClearAllPoints();
				v971['thumbMask'] = v971:CreateMaskTexture();
				v971['thumbMask']:SetAllPoints(v971.thumbTexture);
				v971['thumbMask']:SetTexture("Interface/Masks/CircleMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
				v971['thumbTexture']:AddMaskTexture(v971.thumbMask);
				v971:SetThumbTexture(v971.thumbTexture);
				v971:SetScript("OnMouseDown", function(v1048)
					local FlatIdent_5925 = 0 + 0;
					while true do
						if (FlatIdent_5925 == (1 + 0)) then
							v1048['thumbTexture']:SetColorTexture(v429 * (1987.05 - (121 + 1865)), v430 * (1520.05 - (1174 + 345)), v431 * (2.05 - 1), 1 + 0);
							break;
						end
						if ((0 + 0) == FlatIdent_5925) then
							v1048['thumbTexture']:SetWidth(v992 + (233 - (109 + 123)));
							v1048['thumbTexture']:SetHeight(v992 + (1 - 0));
							FlatIdent_5925 = 724 - (561 + 162);
						end
					end
				end);
				v971:SetScript("OnMouseUp", function(v1049)
					local FlatIdent_360E9 = 0 + 0;
					while true do
						if (FlatIdent_360E9 == (305 - (137 + 168))) then
							v1049['thumbTexture']:SetWidth(v992);
							v1049['thumbTexture']:SetHeight(v992);
							FlatIdent_360E9 = 1524 - (1444 + 79);
						end
						if ((1 - 0) == FlatIdent_360E9) then
							v1049['thumbTexture']:SetColorTexture(v429, v430, v431, 1 - 0);
							break;
						end
					end
				end);
				v971:SetWidth((v422:GetWidth() - v420['el_padding_right']) - v986);
				v971:SetHeight(14 - 6);
				v971:SetMinMaxValues(v971.min, v971.max);
				v971:SetValueStep(v971.step);
				v971:SetValue(v971.value);
				local v996 = getglobal(v971:GetName() .. "Low");
				local v997 = getglobal(v971:GetName() .. "High");
				local v998 = getglobal(v971:GetName() .. "Text");
				v971['TEXT'] = v998;
				local v1000 = v17({v429,v430,v431});
				v971['valueColor'] = v1000;
				v996:SetText(v971.low);
				v996:SetFont(v29, 1733 - (809 + 917), "");
				v997:SetText(v971.high);
				v997:SetFont(v29, 719 - (575 + 137), "");
				v998:SetText(v971['text'] .. ": " .. v1000 .. v971['value'] .. ((v971['valueType'] and v971['valueType']) or (v971['percentage'] and "%") or ""));
				v998:SetFont(v29, 7 + 2, "");
				v998:SetSize(v971:GetWidth(), 6 + 6);
				v998:SetJustifyV("MIDDLE");
				v998:SetJustifyH("LEFT");
				if not v998['moved'] then
					local FlatIdent_400C9 = 0 + 0;
					local v1075;
					local v1076;
					local v1077;
					local v1078;
					while true do
						if (FlatIdent_400C9 == (3 - 1)) then
							v998:SetShadowOffset(v448, v449);
							v998['moved'] = true;
							break;
						end
						if (FlatIdent_400C9 == (1 + 0)) then
							v998:SetTextColor(v432, v433, v434, 1564 - (514 + 1049));
							v998:SetShadowColor(v444, v445, v446, v447);
							FlatIdent_400C9 = 303 - (131 + 170);
						end
						if (FlatIdent_400C9 == (0 - 0)) then
							v1075, v1076, v1076, v1077, v1078 = v998:GetPoint();
							v998:SetPoint(v1075, v1077 + 1 + 1, v1078 + 11 + 3);
							FlatIdent_400C9 = 1 + 0;
						end
					end
				end
				if not v996['moved'] then
					local FlatIdent_604E3 = 0 - 0;
					local v1080;
					local v1081;
					local v1082;
					local v1083;
					while true do
						if (FlatIdent_604E3 == (0 - 0)) then
							v1080, v1081, v1081, v1082, v1083 = v996:GetPoint();
							v996:SetPoint(v1080, v1082 + (17 - 10), v1083 - (19 - 4));
							FlatIdent_604E3 = 1 + 0;
						end
						if (FlatIdent_604E3 == (3 - 1)) then
							v996:SetShadowOffset(v448, v449);
							v996['moved'] = true;
							break;
						end
						if (FlatIdent_604E3 == (2 - 1)) then
							v996:SetTextColor(v436, v437, v438, v9(v439, 0.65 - 0));
							v996:SetShadowColor(v444, v445, v446, v447 / (9 - 6));
							FlatIdent_604E3 = 1715 - (1619 + 94);
						end
					end
				end
				if not v997['moved'] then
					local FlatIdent_3A2A9 = 0 - 0;
					local v1085;
					local v1086;
					local v1087;
					local v1088;
					while true do
						if ((2 - 1) == FlatIdent_3A2A9) then
							v997:SetTextColor(v436, v437, v438, v9(v439, 0.65 + 0));
							v997:SetShadowColor(v444, v445, v446, v447 / (5 - 2));
							FlatIdent_3A2A9 = 2 + 0;
						end
						if (FlatIdent_3A2A9 == (2 - 0)) then
							v997:SetShadowOffset(v448, v449);
							v997['moved'] = true;
							break;
						end
						if (FlatIdent_3A2A9 == (0 + 0)) then
							v1085, v1086, v1086, v1087, v1088 = v997:GetPoint();
							v997:SetPoint(v1085, v1087 - (1952 - (856 + 1089)), v1088 - (3 + 12));
							FlatIdent_3A2A9 = 151 - (62 + 88);
						end
					end
				end
				v971:SetScript("OnUpdate", v63['slider'].OnUpdate);
				v971:SetScript("OnValueChanged", v63['slider'].OnValueChanged);
				if v971['tooltip'] then
					local FlatIdent_75157 = 227 - (123 + 104);
					while true do
						if (FlatIdent_75157 == (1265 - (1050 + 215))) then
							v971:SetScript("OnEnter", v63.OnEnter);
							v971:SetScript("OnLeave", v63.OnLeave);
							break;
						end
					end
				end
				v971:SetAlpha(0 + 0);
				v971['pauseAlpha'] = GetTime();
				v422:AddElement(v971);
			elseif ((v419['type'] == "dropdown") or (v419['type'] == "multiDropdown")) then
				local v1090 = v450;
				v1090:SetFrameStrata("HIGH");
				Mixin(v1090, BackdropTemplateMixin);
				v1090:SetBackdrop(v420['backdrops'].main);
				v1090:SetBackdropColor(v440, v441, v442, v18(v443 * (1816.15 - (1032 + 783))));
				v1090:SetBackdropBorderColor(v440, v441, v442, v18(v443 * (1965.15 - (235 + 1729))));
				v1090:SetWidth(v422:GetWidth() - v420['el_padding_right']);
				v1090['multi'] = v419['multi'];
				v1090['labels'] = {};
				v1090['label_height'] = 1203 - (713 + 478);
				v1090['label_padding'] = 7 - 2;
				v1090['label_container_padding_right'] = 17 + 8;
				v1090['label_line_height'] = 31 - 15;
				v1090['lines_added'] = 971 - (262 + 709);
				v1090['header'] = v419['header'] or v419['text'] or v419['name'];
				v1090['original_height'] = 29 + 1;
				v1090['height'] = v1090['original_height'];
				v1090['max_height'] = v1090['height'] + (v1090['label_line_height'] * (6 - 4));
				v1090:SetHeight(v1090.height);
				v1090['padding']['bottom'] = 581 - (335 + 238);
				v1090['padding']['top'] = 2 + 4 + (v5(v1090.header) * (532 - (467 + 49)));
				local v1105 = v422['elements'][#v422['elements']];
				if (v1105 and ((v1105['type'] == "slider") or (v1105['type'] == "dropdown"))) then
					v1090['padding']['top'] = v1090['padding']['top'] - (5 + 3);
				end
				v1090['placeholder'] = v419['placeholder'];
				v1090['options'] = v419['options'];
				v1090['default'] = v419['default'];
				v1090['valid_options'] = {};
				for v1150, v1151 in v10(v64) do
					v1090[v1150] = v1151;
				end
				v1090:RegisterForClicks("AnyUp");
				v1090:SetScript("OnClick", v63['dropdown'].OnClick);
				if v1090['tooltip'] then
					local FlatIdent_1F774 = 0 + 0;
					while true do
						if (FlatIdent_1F774 == (0 - 0)) then
							v1090:SetScript("OnEnter", v63.OnEnter);
							v1090:SetScript("OnLeave", v63.OnLeave);
							break;
						end
					end
				end
				v1090['initArrowX'] = -(12 + 0);
				v1090['initArrowY'] = 1344 - (1052 + 292);
				if v1090['header'] then
					local FlatIdent_84380 = 0 - 0;
					local v1167;
					while true do
						if (FlatIdent_84380 == (699 - (559 + 138))) then
							v1167:SetShadowOffset(v448, v449);
							v1167:SetTextColor(v432, v433, v434, v435 or (1 + 0));
							break;
						end
						if (FlatIdent_84380 == (83 - (43 + 39))) then
							v1167:SetText(v1090.header);
							v1167:SetShadowColor(v444, v445, v446, v447);
							FlatIdent_84380 = 2 + 0;
						end
						if (FlatIdent_84380 == (381 - (350 + 31))) then
							v1167 = v1090['text'];
							if not v1167 then
								local FlatIdent_42BB6 = 81 - (16 + 65);
								local v1189;
								while true do
									if (FlatIdent_42BB6 == (2 + 0)) then
										v1189 = v1090:GetHeight();
										v1167:SetPoint("LEFT", 1191 - (334 + 857), 0 + 0);
										FlatIdent_42BB6 = 673 - (290 + 380);
									end
									if ((3 - 2) == FlatIdent_42BB6) then
										v1167:ClearAllPoints();
										v1167:SetHeight(3 + 7);
										FlatIdent_42BB6 = 64 - (27 + 35);
									end
									if (FlatIdent_42BB6 == (3 - 0)) then
										v1167:SetPoint("RIGHT", -(1113 - (542 + 543)), 1090 - (709 + 381));
										v1167:SetPoint("TOP", 0 - 0, 9 + 5);
										FlatIdent_42BB6 = 7 - 3;
									end
									if (FlatIdent_42BB6 == (0 - 0)) then
										v1167 = v1090:CreateFontString();
										v1167:SetFont(v29, 592 - (247 + 336), "");
										FlatIdent_42BB6 = 1 + 0;
									end
									if (FlatIdent_42BB6 == (14 - 10)) then
										v1167:SetJustifyH("LEFT");
										v1090['text'] = v1167;
										break;
									end
								end
							else
								v1167:Show();
							end
							FlatIdent_84380 = 1 - 0;
						end
					end
				else
					local FlatIdent_8DC3E = 0 - 0;
					local v1168;
					while true do
						if (FlatIdent_8DC3E == (199 - (131 + 68))) then
							v1168 = v1090['text'];
							if v1168 then
								v1168:Hide();
							end
							break;
						end
					end
				end
				if v1090['multi'] then
					local FlatIdent_70A5F = 0 + 0;
					while true do
						if ((648 - (283 + 364)) == FlatIdent_70A5F) then
							if v1090['placeholder'] then
								local FlatIdent_95C09 = 0 + 0;
								while true do
									if (FlatIdent_95C09 == (519 - (394 + 124))) then
										v1090['label']:SetPoint("LEFT", 1 + 9, 0 - 0);
										v1090['label']:SetPoint("RIGHT", -(1891 - (990 + 873)), 0 - 0);
										v1090['label']:SetJustifyH("LEFT");
										v1090['label']:SetShadowColor(v444, v445, v446, v447 / (7 - 4));
										FlatIdent_95C09 = 4 - 2;
									end
									if (FlatIdent_95C09 == (0 - 0)) then
										v1090['label'] = v1090:CreateFontString();
										v1090['label']:SetFont(v29, 8 + 1, "");
										v1090['label']:ClearAllPoints();
										v1090['label']:SetHeight(283 - (80 + 193));
										FlatIdent_95C09 = 563 - (455 + 107);
									end
									if (FlatIdent_95C09 == (717 - (259 + 456))) then
										v1090['label']:SetShadowOffset(v448, v449);
										v1090['label']:SetTextColor(v432 * (0.8 - 0), v433 * (0.8 - 0), v434 * (0.8 + 0), 2 - 1);
										v1090['label']:SetText(v1090.placeholder);
										v1090['label']:Hide();
										break;
									end
								end
							end
							break;
						end
						if (FlatIdent_70A5F == (1610 - (1286 + 324))) then
							if not v425[v424] then
								local FlatIdent_76C46 = 0 + 0;
								while true do
									if (FlatIdent_76C46 == (0 - 0)) then
										v1090['selected'] = {};
										if v1090['default'] then
											for v1203, v1204 in v10(v1090.default) do
												v1090['selected'][v1204] = true;
											end
										end
										FlatIdent_76C46 = 1 + 0;
									end
									if ((1601 - (393 + 1207)) == FlatIdent_76C46) then
										v425[v424] = v1090['selected'];
										break;
									end
								end
							else
								v1090['selected'] = v425[v424];
							end
							for v1182 in v10(v1090.selected) do
								local FlatIdent_1C1C0 = 0 + 0;
								local v1183;
								while true do
									if (FlatIdent_1C1C0 == (1341 - (629 + 712))) then
										v1183 = v1090:FindOptionByValue(v1182);
										if v1183 then
											v1090:AppendLabel(v1183);
										end
										break;
									end
								end
							end
							FlatIdent_70A5F = 1 + 0;
						end
					end
				else
					local FlatIdent_72EF6 = 0 + 0;
					local v1169;
					while true do
						if (FlatIdent_72EF6 == (0 + 0)) then
							v1169 = v1090['label'];
							if not v1169 then
								local FlatIdent_4FA3D = 0 + 0;
								while true do
									if (FlatIdent_4FA3D == (515 - (57 + 457))) then
										v1169:ClearAllPoints();
										v1169:SetHeight(2 + 8);
										FlatIdent_4FA3D = 4 - 2;
									end
									if (FlatIdent_4FA3D == (2 + 1)) then
										v1169:SetJustifyH("LEFT");
										v1169:SetShadowColor(v444, v445, v446, v447 / (9 - 6));
										FlatIdent_4FA3D = 688 - (142 + 542);
									end
									if (FlatIdent_4FA3D == (0 - 0)) then
										v1169 = v1090:CreateFontString();
										v1169:SetFont(v29, 32 - 23, "");
										FlatIdent_4FA3D = 3 - 2;
									end
									if ((1130 - (717 + 411)) == FlatIdent_4FA3D) then
										v1169:SetPoint("LEFT", 20 - 10, 1953 - (567 + 1386));
										v1169:SetPoint("RIGHT", -(179 - (150 + 1)), 1300 - (1051 + 249));
										FlatIdent_4FA3D = 5 - 2;
									end
									if ((3 + 1) == FlatIdent_4FA3D) then
										v1169:SetShadowOffset(v448, v449);
										v1090['label'] = v1169;
										break;
									end
								end
							end
							FlatIdent_72EF6 = 1 - 0;
						end
						if (FlatIdent_72EF6 == (2 + 0)) then
							v1090['colorType'] = v1090['labelType'];
							if (v1090['labelType'] == "value") then
								v1169:SetTextColor(v432, v433, v434, 1901 - (1806 + 94));
							else
								v1169:SetTextColor(v432 * (0.8 - 0), v433 * (0.8 - 0), v434 * (0.8 - 0), 1 + 0);
							end
							FlatIdent_72EF6 = 1 + 2;
						end
						if (FlatIdent_72EF6 == (1 + 2)) then
							v1169:SetText(v1090['value'] or v1090['placeholder']);
							break;
						end
						if (FlatIdent_72EF6 == (1 + 0)) then
							v1169:Show();
							if v1090['value'] then
								v1090['labelType'] = "value";
							else
								v1090['labelType'] = "placeholder";
							end
							FlatIdent_72EF6 = 427 - (118 + 307);
						end
					end
				end
				if not v1090['arrow'] then
					local FlatIdent_2449B = 0 + 0;
					while true do
						if ((1 + 0) == FlatIdent_2449B) then
							v1090['arrow']:SetWidth(1972 - (805 + 1164));
							v1090['arrow']:SetHeight(12 - 5);
							FlatIdent_2449B = 2 + 0;
						end
						if (FlatIdent_2449B == (2 + 0)) then
							v1090['arrow']:SetRotation(rad(310 - 220));
							v1090['arrow']:SetVertexColor(v429 * (1.02 + 0), v430 * (1.02 + 0), v431 * (1.02 + 0), 419 - (400 + 18));
							FlatIdent_2449B = 1 + 2;
						end
						if (FlatIdent_2449B == (1551 - (1052 + 496))) then
							v1090['arrow']:SetPoint("RIGHT", v1090, "RIGHT", v1090.initArrowX, v1090.initArrowY);
							break;
						end
						if (FlatIdent_2449B == (0 + 0)) then
							v1090['arrow'] = v1090:CreateTexture("ddartxr", "ARTWORK");
							v1090['arrow']:SetTexture("Interface\\Buttons\\WHITE8X8");
							FlatIdent_2449B = 426 - (79 + 346);
						end
					end
				else
					v1090['arrow']:Show();
				end
				v1090['menu'] = v51(v1090, "dropdownMenu");
				v1090['menu']:ClearAllPoints();
				v1090['menu']:SetAllPoints(v1090);
				v1090['menu']:SetFrameStrata("TOOLTIP");
				local v1116 = {};
				v1090['scroll'] = v1116;
				v1116['frame'] = v51(v1090.menu, "dropdownMenuScrollFrame");
				v1116['frame']:ClearAllPoints();
				v1116['frame']:SetPoint("TOP", 1642 - (619 + 1023), -v1090:GetHeight());
				v1116['frame']:SetWidth(v1090:GetWidth());
				Mixin(v1116.frame, BackdropTemplateMixin);
				v1116['frame']:SetBackdrop(v20['backdrops'].main);
				v1116['frame']:SetBackdropColor(v440, v441, v442, 0.92 - 0);
				v1116['frame']:SetBackdropBorderColor(v440, v441, v442, 1789.92 - (857 + 932));
				local v1119 = 6 + 0;
				local v1120 = 69 - 45;
				v1090['menu_padding'] = v1119;
				v1090['button_height'] = v1120;
				v1116['frame']:SetScript("OnMousewheel", function(v1153, v1154)
					local FlatIdent_35884 = 0 - 0;
					local v1155;
					local v1156;
					local v1157;
					local v1158;
					while true do
						if (FlatIdent_35884 == (117 - (91 + 25))) then
							v1157 = ceil(v1116['frame']:GetVerticalScrollRange());
							v1158 = v9(0 + 0, v8(v1157, v1156 + (v1155 * -v1154)));
							FlatIdent_35884 = 1 + 1;
						end
						if (FlatIdent_35884 == (1 + 2)) then
							v1116['frame']:SetVerticalScroll(v1158);
							break;
						end
						if (FlatIdent_35884 == (944 - (828 + 116))) then
							v1155 = v1120;
							v1156 = v1116['frame']:GetVerticalScroll();
							FlatIdent_35884 = 1 + 0;
						end
						if (FlatIdent_35884 == (1956 - (461 + 1493))) then
							if (v1153['resetNextUp'] and (v1154 == (1 + 0))) then
								local FlatIdent_4B601 = 0 - 0;
								while true do
									if (FlatIdent_4B601 == (0 - 0)) then
										v1158 = v1158 - (2 + 1);
										v1153['resetNextUp'] = nil;
										break;
									end
								end
							end
							if (((v1157 - v1158) <= v1119) and v1153['ScrollBar']:IsShown()) then
								local FlatIdent_95694 = 988 - (980 + 8);
								while true do
									if (FlatIdent_95694 == (1 + 0)) then
										v1116['frame']:SetVerticalScroll(v1158);
										break;
									end
									if (FlatIdent_95694 == (0 - 0)) then
										v1158 = v1157 + 1 + 2;
										v1153['resetNextUp'] = true;
										FlatIdent_95694 = 1447 - (843 + 603);
									end
								end
							end
							FlatIdent_35884 = 5 - 2;
						end
					end
				end);
				v1116['child'] = v51(nil, "dropdownScrollChild");
				v1116['child']:ClearAllPoints();
				v1116['child']:SetWidth(v1090:GetWidth());
				v1116['frame']:SetScrollChild(v1116.child);
				v1090:RerenderDropdownMenu();
				v1090:SetAlpha(0 + 0);
				v1090['pauseAlpha'] = GetTime();
				v1090['menu']:Hide();
				if not v1090['multi'] then
					local FlatIdent_7039F = 0 + 0;
					while true do
						if (FlatIdent_7039F == (0 + 0)) then
							if v425[v424] then
								local FlatIdent_2D5CF = 0 - 0;
								local v1199;
								while true do
									if (FlatIdent_2D5CF == (1747 - (1640 + 107))) then
										v1199 = v1090:FindOptionByValue(v425[v424]);
										if v1199 then
											v1090:SetSelected(v1199);
										end
										break;
									end
								end
							end
							if (v1090['default'] and not v1090['selected']) then
								local FlatIdent_7B8B3 = 0 + 0;
								local v1200;
								while true do
									if ((1321 - (815 + 506)) == FlatIdent_7B8B3) then
										v1200 = v1090:FindOptionByValue(v1090.default);
										if v1200 then
											v1090:SetSelected(v1200);
										end
										break;
									end
								end
							end
							break;
						end
					end
				end
				v1090['init'] = true;
				v1090:SetScript("OnUpdate", v63['dropdown'].OnUpdate);
				v422:AddElement(v1090);
			elseif (v419['type'] == "text") then
				local FlatIdent_45CCA = 0 + 0;
				local v1173;
				local v1174;
				while true do
					if (FlatIdent_45CCA == (3 - 2)) then
						if not v1173['fontString'] then
							v1173['fontString'] = v1173:CreateFontString(nil, "ARTWORK");
						end
						v1173['fontString']:SetFont(v29, v1174, "");
						v1173['fontString']:SetText(v1173.text);
						v1173['fontString']:SetTextColor(v432, v433, v434, v435);
						FlatIdent_45CCA = 1734 - (992 + 740);
					end
					if (FlatIdent_45CCA == (3 + 1)) then
						v1173:SetScript("OnUpdate", v63['text'].OnUpdate);
						if v419['OnClick'] then
							v1173:SetScript("OnClick", v419.OnClick);
						else
							v1173:SetScript("OnClick", function()
							end);
						end
						v422:AddElement(v1173);
						break;
					end
					if (FlatIdent_45CCA == (4 - 1)) then
						v1173['padding']['top'] = v419['paddingTop'] or ((19 - 14) + (v5(v419.header) * (9 - 4)));
						v1173['padding']['bottom'] = v419['paddingBottom'] or ((14 - 9) + (v5(v419.header) * (1312 - (295 + 1015))));
						v1173['padding']['left'] = v419['paddingLeft'] or (0 - 0);
						v1173['padding']['right'] = v419['paddingRight'] or (0 + 0);
						FlatIdent_45CCA = 8 - 4;
					end
					if ((1065 - (188 + 877)) == FlatIdent_45CCA) then
						v1173 = v450;
						v1174 = v419['size'] or (v419['header'] and (2 + 10)) or (23 - 14);
						v1173:SetWidth(v422:GetWidth() - v420['el_padding_right']);
						v1173:SetHeight(v1174);
						FlatIdent_45CCA = 1 - 0;
					end
					if (FlatIdent_45CCA == (2 - 0)) then
						v1173['fontString']:SetPoint("LEFT", 0 - 0, 431 - (152 + 279));
						v1173['fontString']:SetPoint("RIGHT", 0 - 0, 180 - (30 + 150));
						v1173['fontString']:SetJustifyH("LEFT");
						v1173['height'] = v1173:GetHeight();
						FlatIdent_45CCA = 1353 - (710 + 640);
					end
				end
			end
			break;
		end
		if (FlatIdent_7D25C == (3 + 2)) then
			v450['tooltip'] = nil;
			v450['name'] = nil;
			for v696, v697 in v10(v419) do
				v450[v696] = v697;
			end
			FlatIdent_7D25C = 45 - (34 + 5);
		end
		if (FlatIdent_7D25C == (3 + 1)) then
			v440, v441, v442, v443 = unpack(v420['colors'].background);
			v444, v445, v446, v447, v448, v449 = unpack(v420['shadows'].primary);
			v450 = v51(v422, v419.type);
			FlatIdent_7D25C = 4 + 1;
		end
		if (FlatIdent_7D25C == (6 + 0)) then
			v450['parent'] = v422;
			v450['saved'] = v425;
			v450['var'] = v424;
			FlatIdent_7D25C = 21 - 14;
		end
		if ((1669 - (1447 + 215)) == FlatIdent_7D25C) then
			v450['ui'] = v420;
			v450['padding'] = v55(v426);
			v450.SetInteractive = function(v699, v700)
				local FlatIdent_3041B = 0 - 0;
				while true do
					if (FlatIdent_3041B == (1651 - (1055 + 596))) then
						if v699['SetEnabled'] then
							v699:SetEnabled(v700);
						end
						v699:EnableMouse(v700);
						break;
					end
				end
			end;
			FlatIdent_7D25C = 1437 - (1095 + 334);
		end
		if ((1441 - (1208 + 230)) == FlatIdent_7D25C) then
			v429, v430, v431 = unpack(v420['currentTabAccentColors'] or v420['colors']['accent']);
			v432, v433, v434, v435 = unpack(v420['colors'].primary);
			v436, v437, v438, v439 = unpack(v420['colors'].tertiary);
			FlatIdent_7D25C = 8 - 4;
		end
		if (FlatIdent_7D25C == (1 - 0)) then
			v423 = v419['text'] or v419['name'];
			v424 = v419['var'];
			v425 = v419['saved'];
			FlatIdent_7D25C = 1 + 1;
		end
		if (FlatIdent_7D25C == (16 - (10 + 6))) then
			v420 = v418['ui'];
			v421 = v420['frame'];
			v422 = v421['view'];
			FlatIdent_7D25C = 1810 - (747 + 1062);
		end
		if (FlatIdent_7D25C == (1479 - (1310 + 167))) then
			v426 = v419['padding'];
			v427 = v419['tooltip'];
			v428 = v419['default'];
			FlatIdent_7D25C = 569 - (221 + 345);
		end
	end
end;
v20.FindTabObject = function(v459, v460)
	local FlatIdent_11961 = 0 + 0;
	while true do
		if (FlatIdent_11961 == (0 - 0)) then
			if not v460 then
				return;
			end
			for v701, v702 in v11(v459.tabs) do
				local FlatIdent_29D83 = 0 - 0;
				while true do
					if (FlatIdent_29D83 == (0 + 0)) then
						if (v702 and v702['group']) then
							for v1003, v1004 in v11(v702.tabs) do
								if (v1004 and ((v1004['uid'] == v460) or (v1004['name'] == v460))) then
									return v1004;
								end
							end
						end
						if (v702 and ((v702['uid'] == v460) or (v702['name'] == v460))) then
							return v702;
						end
						break;
					end
				end
			end
			break;
		end
	end
end;
v20.SetTab = function(v461, v462)
	local FlatIdent_9CA0 = 754 - (539 + 215);
	local v465;
	while true do
		if ((0 - 0) == FlatIdent_9CA0) then
			if v462['group'] then
				local FlatIdent_1E0CE = 0 - 0;
				while true do
					if ((0 - 0) == FlatIdent_1E0CE) then
						if v462['open'] then
							v462:Collapse();
						else
							v462:Expand();
						end
						return;
					end
				end
			end
			if not v462['RenderElement'] then
				v462 = v461:FindTabObject(v462.uid);
			end
			FlatIdent_9CA0 = 2 - 1;
		end
		if (FlatIdent_9CA0 == (2 + 1)) then
			for v703, v704 in v11(v461.sections) do
				v704:Clear();
			end
			if v462['elements'] then
				for v914, v915 in v11(v462.elements) do
					v462:RenderElement(v915);
				end
			end
			FlatIdent_9CA0 = 4 + 0;
		end
		if (FlatIdent_9CA0 == (2 + 0)) then
			v465 = v461['currentTab'];
			if (v465 and v465['inGroup']) then
				local FlatIdent_48554 = 0 - 0;
				while true do
					if ((0 - 0) == FlatIdent_48554) then
						if (v465['inGroup']['colors'] and v465['inGroup']['colors']['accent']) then
							v461['currentTabAccentColors'] = v465['inGroup']['colors']['accent'];
						end
						v461:UpdateTitle(v465['inGroup'].colors, v465['inGroup'].title);
						break;
					end
				end
			else
				v461:UpdateTitle();
			end
			FlatIdent_9CA0 = 7 - 4;
		end
		if (FlatIdent_9CA0 == (1 + 0)) then
			v461['currentTab'] = v462;
			v461['currentTabAccentColors'] = nil;
			FlatIdent_9CA0 = 2 - 0;
		end
		if ((1567 - (101 + 1462)) == FlatIdent_9CA0) then
			if (v462['inGroup'] and not v462['rerendered']) then
				local FlatIdent_236B = 0 + 0;
				while true do
					if (FlatIdent_236B == (0 + 0)) then
						for v916, v917 in v11(v461.sections) do
							v917:Clear();
						end
						if v462['elements'] then
							for v1050, v1051 in v11(v462.elements) do
								v462:RenderElement(v1051);
							end
						end
						FlatIdent_236B = 1195 - (298 + 896);
					end
					if (FlatIdent_236B == (535 - (426 + 108))) then
						v462['rerendered'] = true;
						break;
					end
				end
			end
			for v705, v706 in v11(v461.sections) do
				if v462['scrollPos'] then
					local FlatIdent_3635B = 0 + 0;
					local v918;
					while true do
						if (FlatIdent_3635B == (1975 - (455 + 1520))) then
							v918 = v462['scrollPos'][v706['name']];
							if v918 then
								local FlatIdent_3046 = 0 - 0;
								while true do
									if (FlatIdent_3046 == (0 + 0)) then
										v706['scroll']['pos'] = v918;
										C_Timer.After(1041 - (214 + 827), function()
											local FlatIdent_22878 = 0 - 0;
											while true do
												if (FlatIdent_22878 == (0 - 0)) then
													v706['scroll']['frame']:SetValue(v918);
													v462['scrollPos'][v706['name']] = v918;
													break;
												end
											end
										end);
										break;
									end
								end
							end
							break;
						end
					end
				end
			end
			break;
		end
	end
end;
v20.Rerender = function(v466, v467)
	local FlatIdent_5621B = 0 - 0;
	while true do
		if (FlatIdent_5621B == (254 - (129 + 125))) then
			v466['frame']['tabs']:Clear(v467);
			if not v467 then
				v466['currentTab'] = nil;
			end
			FlatIdent_5621B = 2 - 1;
		end
		if (FlatIdent_5621B == (366 - (233 + 132))) then
			for v707, v708 in v11(v466.tabs) do
				if v708['group'] then
					v466:RenderGroup(v708, {bottom=(121 - (62 + 56)),left=(2 + 10)});
				else
					v466:RenderTab(v708, {bottom=(1944 - (664 + 1277)),left=(28 - 16)});
				end
			end
			if not v467 then
				v466:SetTab(v466:FindTabObject(v466.defaultTab) or v466['tabs'][1683 - (1025 + 657)]);
			end
			break;
		end
	end
end;
local v69 = {};
v69['__index'] = v69;
v20.StatusFrame = function(v468, v469)
	local FlatIdent_880E2 = 0 - 0;
	local v470;
	local v471;
	local v472;
	local v473;
	local v474;
	local v490;
	local v491;
	local v492;
	local v493;
	local v494;
	local v498;
	local v499;
	local v500;
	local v501;
	local v502;
	local v503;
	while true do
		if (FlatIdent_880E2 == (8 + 1)) then
			v503['icon']:SetTexture("Interface\\PetBattles\\PetBattle-LockIcon");
			v503:SetIconColor(v473.sf_locked);
			v490['lock'] = v503;
			v490:EnableMouse(not v473['sf_locked']);
			v490['updateCallbacks'] = {};
			v490:SetScript("OnUpdate", function(v732)
				local FlatIdent_89DE9 = 0 - 0;
				while true do
					if (FlatIdent_89DE9 == (0 + 0)) then
						v474:Update();
						for v850 = 1 + 0, #v732['updateCallbacks'] do
							v732['updateCallbacks'][v850](v732);
						end
						break;
					end
				end
			end);
			FlatIdent_880E2 = 12 - 2;
		end
		if ((0 + 0) == FlatIdent_880E2) then
			if not v468['StatusFramesList'] then
				v468['StatusFramesList'] = {};
			end
			v470 = v468['StatusFramesList'];
			v471 = #v470;
			v472 = "sf" .. v471;
			v473 = nil;
			if v469['use'] then
				local FlatIdent_8310F = 0 - 0;
				local v848;
				while true do
					if (FlatIdent_8310F == (1996 - (1056 + 940))) then
						v848 = v469['use'];
						if (v12(v848) == "string") then
							if not v468['saved'][v848] then
								local FlatIdent_39073 = 0 + 0;
								local v1127;
								while true do
									if ((1361 - (1327 + 33)) == FlatIdent_39073) then
										v473 = v1127;
										break;
									end
									if (FlatIdent_39073 == (0 + 0)) then
										v1127 = v1.NewConfig(v468['name'] .. "_" .. v848);
										v16(v468.saved, v848, v1127);
										FlatIdent_39073 = 2 - 1;
									end
								end
							else
								v473 = v468['saved'][v848];
							end
						end
						break;
					end
				end
			else
				v473 = v468['saved'];
			end
			FlatIdent_880E2 = 1 - 0;
		end
		if (FlatIdent_880E2 == (2 + 4)) then
			v490:SetScript("OnLeave", function(v721)
				local FlatIdent_21508 = 0 + 0;
				while true do
					if (FlatIdent_21508 == (0 + 0)) then
						v721['lock']:SetAlpha(0 - 0);
						v721:SetBackdropColor(v491, v492, v493, v494 or (0 - 0));
						FlatIdent_21508 = 2 - 1;
					end
					if (FlatIdent_21508 == (1 + 0)) then
						v721:SetBackdropBorderColor(v491, v492, v493, v494 or (0 - 0));
						break;
					end
				end
			end);
			v490:SetWidth(68 + 32);
			v490:SetHeight(1489 - (388 + 1001));
			v498, v499, v500, v501, v502 = v473[v472 .. "p1"], v473[v472 .. "pframe"], v473[v472 .. "p2"], v473[v472 .. "x"], v473[v472 .. "y"];
			v490:SetPoint(v498 or "CENTER", "UIParent", v500 or "CENTER", v501 or (0 + 0), v502 or -(214 - 114));
			v503 = CreateFrame("Button", v490);
			FlatIdent_880E2 = 2 + 5;
		end
		if (FlatIdent_880E2 == (865 - (80 + 784))) then
			v474 = v469 or {};
			v474['sf_var'] = v472;
			v474['maxWidth'] = v474['maxWidth'] or (550 - 300);
			v474['__index'] = v69;
			v474['ui'] = v468;
			v474['fontSize'] = v474['fontSize'] or (255 - (98 + 145));
			FlatIdent_880E2 = 669 - (261 + 406);
		end
		if (FlatIdent_880E2 == (2 + 1)) then
			v474['colors']['background'] = v30(v474['colors']['background'] or {(0 - 0),(0 + 0),(487 - (223 + 264)),(1 + 0)});
			v474['uid'] = math.random(1670 - (1451 + 219), 1000836 - (781 + 56));
			v474['elements'] = {};
			v474['padding'] = v469['padding'] or (739 - (651 + 80));
			setmetatable(v474, v69);
			v490 = CreateFrame("Frame");
			FlatIdent_880E2 = 9 - 5;
		end
		if (FlatIdent_880E2 == (1948 - (1473 + 468))) then
			v503:SetParent(v490);
			v503:SetWidth(39 - 27);
			v503:SetHeight(17 - 5);
			v503:SetPoint("TOPLEFT", v490, "TOPLEFT", 1506 - (535 + 971), 0 - 0);
			v503:SetFrameStrata("TOOLTIP");
			v503.SetIconColor = function(v722, v723)
				local FlatIdent_885C1 = 0 + 0;
				local v724;
				local v725;
				local v726;
				local v727;
				while true do
					if ((664 - (459 + 204)) == FlatIdent_885C1) then
						v722['icon']:SetVertexColor(v724, v725, v726, v727);
						break;
					end
					if (FlatIdent_885C1 == (0 - 0)) then
						v724, v725, v726, v727 = nil;
						if v723 then
							v724, v725, v726, v727 = 1512 - (1029 + 482), 0.4 - 0, 0.1 - 0, 4 - 3;
						else
							v724, v725, v726, v727 = 0.4 + 0, 2 - 1, 979.2 - (582 + 397), 731 - (678 + 52);
						end
						FlatIdent_885C1 = 1936 - (544 + 1391);
					end
				end
			end;
			FlatIdent_880E2 = 22 - 14;
		end
		if (FlatIdent_880E2 == (1 + 4)) then
			v490:SetBackdropColor(v491, v492, v493, v494);
			v490:SetBackdropBorderColor(v491, v492, v493, v494);
			v474.IsShown = function(v716)
				return v490:IsShown();
			end;
			v474.Hide = function(v717)
				return v490:Hide();
			end;
			v474.Show = function(v718)
				return v490:Show();
			end;
			v490:SetScript("OnEnter", function(v719)
				local FlatIdent_62208 = 0 - 0;
				local v720;
				while true do
					if (FlatIdent_62208 == (1 - 0)) then
						v719:SetBackdropColor(v491, v492, v493, v720, v720);
						v719:SetBackdropBorderColor(v491, v492, v493, v720, v720);
						break;
					end
					if (FlatIdent_62208 == (1386 - (958 + 428))) then
						v719['lock']:SetAlpha(0.75 + 0);
						v720 = v9(0 - 0, v8(1 + 0, (542.2 - (50 + 492)) + (v494 * (2.5 + 0)))) or (4 - 3);
						FlatIdent_62208 = 4 - 3;
					end
				end
			end);
			FlatIdent_880E2 = 1 + 5;
		end
		if (FlatIdent_880E2 == (8 - 4)) then
			Mixin(v490, BackdropTemplateMixin);
			v490:SetMovable(true);
			v490:SetScript("OnMouseUp", function(v709)
				local FlatIdent_603AF = 0 - 0;
				while true do
					if (FlatIdent_603AF == (0 + 0)) then
						v709:StopMovingOrSizing();
						v473[v472 .. "p1"], v473[v472 .. "pframe"], v473[v472 .. "p2"], v473[v472 .. "x"], v473[v472 .. "y"] = v709:GetPoint();
						break;
					end
				end
			end);
			v490:SetScript("OnMouseDown", function(v715)
				local FlatIdent_816D5 = 0 - 0;
				while true do
					if (FlatIdent_816D5 == (0 - 0)) then
						if v473['sf_locked'] then
							return;
						end
						v715:StartMoving();
						break;
					end
				end
			end);
			v490:SetBackdrop(v468['backdrops'].main);
			v491, v492, v493, v494 = unpack(v474['colors'].background);
			FlatIdent_880E2 = 634 - (422 + 207);
		end
		if ((5 + 5) == FlatIdent_880E2) then
			v2(v468.StatusFramesList, v474);
			v474['frame'] = v490;
			return v474;
		end
		if (FlatIdent_880E2 == (6 - 4)) then
			v474['colors'] = v474['colors'] or {};
			v474['saved'] = v473;
			v474['colors']['value'] = v30(v474['colors']['value'] or {(540 - (356 + 84)),(633 - 388),(20 + 80),(1 + 0)});
			v474['colors']['enabled'] = v30(v474['colors']['enabled'] or v474['colors']['value']);
			v474['colors']['disabled'] = v30(v474['colors']['disabled'] or {(484 - 239),(132 - 32),(4 + 96),(2 - 1)});
			v474['colors']['primary'] = v30(v474['colors']['primary'] or {(165 + 90),(109 + 146),(143 + 112),(1076 - (663 + 412))});
			FlatIdent_880E2 = 3 + 0;
		end
		if (FlatIdent_880E2 == (832 - (390 + 434))) then
			v503:SetScript("OnEnter", function(v728)
				v728:SetAlpha(3 - 2);
			end);
			v503:SetScript("OnLeave", function(v729)
				v729:SetAlpha(0 - 0);
			end);
			v503:SetScript("OnClick", function(v730)
				local FlatIdent_64E69 = 994 - (307 + 687);
				while true do
					if (FlatIdent_64E69 == (25 - (15 + 10))) then
						v473['sf_locked'] = not v473['sf_locked'];
						if v473['sf_locked'] then
							local FlatIdent_43367 = 0 + 0;
							while true do
								if (FlatIdent_43367 == (0 - 0)) then
									v490:EnableMouse(false);
									v1.alert("Frame |cFFffa463Locked");
									break;
								end
							end
						else
							local FlatIdent_8F270 = 0 - 0;
							while true do
								if (FlatIdent_8F270 == (0 - 0)) then
									v490:EnableMouse(true);
									v1.alert("Frame |cFFa1ff6eUnlocked");
									break;
								end
							end
						end
						FlatIdent_64E69 = 3 - 2;
					end
					if (FlatIdent_64E69 == (1799 - (1192 + 606))) then
						v730:SetIconColor(v473.sf_locked);
						break;
					end
				end
			end);
			v503:SetAlpha(646 - (403 + 243));
			v503['icon'] = v503:CreateTexture("locktxtrklo", "ARTWORK");
			v503['icon']:SetAllPoints(v503);
			FlatIdent_880E2 = 29 - 20;
		end
	end
end;
v69.String = function(v509, v510)
	local FlatIdent_58B4E = 0 + 0;
	local v511;
	local v512;
	local v513;
	local v514;
	local v518;
	local v519;
	local v520;
	local v521;
	while true do
		if (FlatIdent_58B4E == (953 - (534 + 416))) then
			v514:SetText(v512);
			v518, v519, v520, v521 = unpack(v509['colors'].primary);
			v514:SetTextColor(v518, v519, v520, v521);
			FlatIdent_58B4E = 1 + 3;
		end
		if (FlatIdent_58B4E == (4 - 3)) then
			v512 = ((v12(v511[v510['var']]) == "string") and v511[v510['var']]) or "";
			v513 = v509['frame'];
			v514 = v513:CreateFontString();
			FlatIdent_58B4E = 1 + 1;
		end
		if ((7 - 5) == FlatIdent_58B4E) then
			v514['type'] = "string";
			v514['var'] = v510['var'];
			v514:SetFont(v29, 1 + 11, "");
			FlatIdent_58B4E = 10 - 7;
		end
		if (FlatIdent_58B4E == (0 + 0)) then
			if (v12(v510) ~= "table") then
				return false;
			end
			if (v12(v510.var) ~= "string") then
				return false;
			end
			v511 = v509['saved'];
			FlatIdent_58B4E = 1783 - (729 + 1053);
		end
		if (FlatIdent_58B4E == (4 + 0)) then
			v509:AddElement(v514);
			return v514;
		end
	end
end;
v69.Toggle = function(v522, v523)
	local FlatIdent_4B9AA = 0 + 0;
	local v524;
	local v525;
	local v526;
	local v527;
	local v536;
	local v537;
	local v538;
	local v539;
	local v540;
	while true do
		if ((4 - 2) == FlatIdent_4B9AA) then
			if v523['onClick'] then
				local FlatIdent_2F33 = 0 - 0;
				while true do
					if (FlatIdent_2F33 == (13 - 10)) then
						v527:SetWidth(3786 - 2786);
						v527:SetHeight(785 - (674 + 91));
						break;
					end
					if (FlatIdent_2F33 == (1117 - (201 + 916))) then
						v527 = CreateFrame("Button", v526);
						v527:SetParent(v526);
						FlatIdent_2F33 = 1557 - (96 + 1460);
					end
					if (FlatIdent_2F33 == (1 + 1)) then
						v527:SetFrameStrata("HIGH");
						v527['txt']:SetPoint("CENTER", v527, "CENTER", 0 + 0, 0 + 0);
						FlatIdent_2F33 = 3 + 0;
					end
					if (FlatIdent_2F33 == (1375 - (919 + 455))) then
						v527['onClick'] = true;
						v527['txt'] = v527:CreateFontString();
						FlatIdent_2F33 = 2 - 0;
					end
				end
			else
				v527 = v526:CreateFontString();
			end
			v527['type'] = "toggle";
			v527['var'] = v523['var'];
			FlatIdent_4B9AA = 1 + 2;
		end
		if (FlatIdent_4B9AA == (1118 - (140 + 972))) then
			v522:AddElement(v527);
			return v527;
		end
		if (FlatIdent_4B9AA == (23 - 18)) then
			v536:SetText(initText);
			v537, v538, v539, v540 = unpack(v522['colors'].primary);
			v536:SetTextColor(v537, v538, v539, v540);
			FlatIdent_4B9AA = 168 - (22 + 140);
		end
		if (FlatIdent_4B9AA == (820 - (225 + 595))) then
			if (v12(v523) ~= "table") then
				return false;
			end
			if (v12(v523.var) ~= "string") then
				return false;
			end
			v524 = v522;
			FlatIdent_4B9AA = 3 - 2;
		end
		if (FlatIdent_4B9AA == (1 + 0)) then
			v525 = v522['saved'];
			v526 = v522['frame'];
			v527 = nil;
			FlatIdent_4B9AA = 2 + 0;
		end
		if (FlatIdent_4B9AA == (1385 - (178 + 1203))) then
			if v523['onClick'] then
				local FlatIdent_796F9 = 0 - 0;
				while true do
					if (FlatIdent_796F9 == (0 - 0)) then
						v527:RegisterForClicks("LeftButtonUp");
						v527.UpdateWidth = function(v920)
							local FlatIdent_B8EE = 0 + 0;
							while true do
								if (FlatIdent_B8EE == (0 - 0)) then
									v920:SetWidth(v920['txt']:GetWidth());
									v920:SetHeight(v920['txt']:GetHeight());
									break;
								end
							end
						end;
						FlatIdent_796F9 = 2 - 1;
					end
					if (FlatIdent_796F9 == (1 + 0)) then
						v527:SetScript("OnClick", function(v921)
							local FlatIdent_42F99 = 0 + 0;
							while true do
								if (FlatIdent_42F99 == (0 - 0)) then
									v523.onClick(v921);
									v921:Update();
									FlatIdent_42F99 = 1 + 0;
								end
								if (FlatIdent_42F99 == (1 + 0)) then
									v921:UpdateWidth();
									break;
								end
							end
						end);
						v527:SetScript("OnUpdate", function(v922)
							v922:UpdateWidth();
						end);
						break;
					end
				end
			end
			v536 = (v527['onClick'] and v527['txt']) or v527;
			v536:SetFont(v29, 11 + 1, "");
			FlatIdent_4B9AA = 11 - 6;
		end
		if (FlatIdent_4B9AA == (11 - 8)) then
			v527['label'] = v523['label'];
			v527['valueText'] = v523['valueText'];
			v527.Update = function(v733)
				local FlatIdent_4B2A3 = 0 - 0;
				local v734;
				local v735;
				local v736;
				local v737;
				while true do
					if ((0 - 0) == FlatIdent_4B2A3) then
						v734 = v733['label'] .. " ";
						v735 = v733['valueText'];
						FlatIdent_4B2A3 = 2 - 1;
					end
					if (FlatIdent_4B2A3 == (1 + 0)) then
						v736 = v525[v733['var']];
						if (v12(v735) == "function") then
							local FlatIdent_49191 = 0 - 0;
							local v919;
							while true do
								if (FlatIdent_49191 == (0 - 0)) then
									v919 = v735(v736);
									if (v919 and tostring(v919)) then
										local FlatIdent_40C28 = 590 - (81 + 509);
										local v1053;
										while true do
											if (FlatIdent_40C28 == (0 - 0)) then
												v1053 = v17(v524['colors'].value);
												v734 = v734 .. v1053 .. tostring(v919);
												break;
											end
										end
									else
										v734 = "";
									end
									break;
								end
							end
						elseif ((v12(v736) == "string") or (v12(v736) == "number")) then
							local FlatIdent_2D831 = 0 + 0;
							local v1054;
							while true do
								if ((75 - (45 + 30)) == FlatIdent_2D831) then
									v1054 = v17(v524['colors'].value);
									v734 = v734 .. v1054 .. v736 .. "|r";
									break;
								end
							end
						elseif v736 then
							local FlatIdent_94584 = 0 + 0;
							local v1159;
							while true do
								if (FlatIdent_94584 == (0 - 0)) then
									v1159 = v17(v524['colors'].enabled);
									v734 = v734 .. v1159 .. "Enabled" .. "|r";
									break;
								end
							end
						else
							local FlatIdent_85D32 = 0 - 0;
							local v1160;
							while true do
								if (FlatIdent_85D32 == (0 + 0)) then
									v1160 = v17(v524['colors'].disabled);
									v734 = v734 .. v1160 .. "Disabled" .. "|r";
									break;
								end
							end
						end
						FlatIdent_4B2A3 = 2 + 0;
					end
					if (FlatIdent_4B2A3 == (518 - (311 + 205))) then
						v737 = (v733['onClick'] and v733['txt']) or v733;
						v737:SetText(v734);
						break;
					end
				end
			end;
			FlatIdent_4B9AA = 9 - 5;
		end
	end
end;
v69.Button = function(v541, v542)
	if (v12(v542) ~= "table") then
		local FlatIdent_92AC5 = 733 - (409 + 324);
		while true do
			if (FlatIdent_92AC5 == (0 + 0)) then
				v1.print("Please pass options as table to StatusFrame:Button");
				return false;
			end
		end
	end
	if (v12(v542.var) ~= "string") then
		local FlatIdent_66D1B = 0 + 0;
		while true do
			if ((0 - 0) == FlatIdent_66D1B) then
				v1.print("Please pass var as string in StatusFrame:Button options");
				return false;
			end
		end
	end
	if (not v542['spellId'] and not v542['spellID']) then
		local FlatIdent_73976 = 0 - 0;
		while true do
			if (FlatIdent_73976 == (816 - (581 + 235))) then
				v1.print("Please pass spellId as number or function in StatusFrame:Button options");
				return false;
			end
		end
	end
	local v543 = v541['frame'];
	local v544 = v542['shouldShow'];
	local v545 = CreateFrame("Button", v543);
	local v546 = CreateFrame("Button", v545);
	v545['btn'] = v546;
	local v548 = CreateFrame("Frame", nil, v546);
	local v549, v550 = v542['spellId'] or v542['spellID'], v542['spellName'];
	local v551 = v12(v549) == "function";
	local v552 = v542['text'];
	local v553 = v542['textSize'] or (28 - 17);
	local v554 = v542['size'] or (85 - 55);
	v545:SetSize(v554, v554);
	v545:SetParent(v543);
	v546:SetSize(v554, v554);
	v546:SetParent(v545);
	v546:SetPoint("CENTER", 0 + 0, 0 + 0);
	v546['sf'] = v541;
	v546:EnableMouse(true);
	v546:SetClampedToScreen(true);
	v546:SetNormalTexture(v1['dep'].GetSpellIcon((v551 and v549()) or v549));
	v546['saved'] = v541['saved'];
	v545['saved'] = v541['saved'];
	local v559 = v542['var'];
	local v560 = v541['saved'][v559];
	v545.Update = function(v738)
		local FlatIdent_1E0BD = 0 - 0;
		local v739;
		while true do
			if (FlatIdent_1E0BD == (1 + 0)) then
				if v544 then
					if v544(v739) then
						v738:Show();
					else
						v738:Hide();
					end
				end
				if (v12(v552) == "string") then
					if (v548['text']:GetText() ~= v552) then
						v548['text']:SetText(v552);
					end
				elseif (v12(v552) == "table") then
					if v738['saved'][v559] then
						if (v548['text']:GetText() ~= v552['enabled']) then
							v548['text']:SetText(v552.enabled);
						end
					elseif (v548['text']:GetText() ~= v552['disabled']) then
						v548['text']:SetText(v552.disabled);
					end
				elseif (v12(v552) == "function") then
					local FlatIdent_98F27 = 1602 - (935 + 667);
					local v1161;
					while true do
						if (FlatIdent_98F27 == (0 + 0)) then
							v1161 = v552(v738['saved'][v559]);
							if (v548['text']:GetText() ~= v1161) then
								v548['text']:SetText(v1161);
							end
							break;
						end
					end
				end
				FlatIdent_1E0BD = 1 + 1;
			end
			if (FlatIdent_1E0BD == (1592 - (1178 + 414))) then
				v739 = v738['saved'][v559];
				if v551 then
					v546:SetNormalTexture(v1['dep'].GetSpellIcon(v549()));
				end
				FlatIdent_1E0BD = 1 + 0;
			end
			if (FlatIdent_1E0BD == (309 - (63 + 244))) then
				if (v548['text']:GetText() ~= "") then
					v545:SetWidth(v9(v548['text']:GetStringWidth(), v554));
				end
				if not v739 then
					v548['texture']:SetTexture([[Interface\GLUES\CREDITS\Arakkoa1]]);
				else
					v548['texture']:SetTexture([[Interface/BUTTONS/CheckButtonHilight-Blue]]);
				end
				break;
			end
		end
	end;
	v546:SetScript("OnMouseDown", function(v740)
		if IsShiftKeyDown() then
			local FlatIdent_8B87D = 1443 - (1325 + 118);
			local v923;
			local v924;
			local v925;
			while true do
				if (FlatIdent_8B87D == (0 - 0)) then
					v923 = v740;
					v924 = v740['sf'];
					FlatIdent_8B87D = 2 - 1;
				end
				if ((931 - (423 + 506)) == FlatIdent_8B87D) then
					C_Timer.NewTicker(121 - (93 + 28), function(v1007)
						local FlatIdent_22655 = 0 - 0;
						while true do
							if (FlatIdent_22655 == (1187 - (449 + 738))) then
								v923['ignoreClicks'] = GetTime();
								if not IsMouseButtonDown("LeftButton") then
									local FlatIdent_6690F = 186 - (156 + 30);
									local v1129;
									local v1130;
									while true do
										if (FlatIdent_6690F == (1551 - (1451 + 99))) then
											v1130 = v924['saved'];
											v1130[v1129 .. "p1"], v1130[v1129 .. "pframe"], v1130[v1129 .. "p2"], v1130[v1129 .. "x"], v1130[v1129 .. "y"] = v925:GetPoint();
											FlatIdent_6690F = 230 - (99 + 129);
										end
										if (FlatIdent_6690F == (0 + 0)) then
											v925:StopMovingOrSizing();
											v1129 = v924['sf_var'];
											FlatIdent_6690F = 1 - 0;
										end
										if (FlatIdent_6690F == (3 - 1)) then
											v1007:Cancel();
											break;
										end
									end
								end
								break;
							end
						end
					end);
					return;
				end
				if (FlatIdent_8B87D == (1 + 0)) then
					v925 = v924['frame'];
					v925:StartMoving();
					FlatIdent_8B87D = 452 - (256 + 194);
				end
			end
		end
	end);
	v546:SetScript("OnClick", function(v741)
		local FlatIdent_5EBE4 = 0 + 0;
		while true do
			if (FlatIdent_5EBE4 == (4 - 2)) then
				if v542['onClick'] then
					v542.onClick();
				end
				break;
			end
			if (FlatIdent_5EBE4 == (1 + 0)) then
				if (v12(v552) == "string") then
					v548['text']:SetText(v552);
				elseif (v12(v552) == "table") then
					if v741['saved'][v559] then
						v548['text']:SetText(v552.enabled);
					else
						v548['text']:SetText(v552.disabled);
					end
				elseif (v12(v552) == "function") then
					v548['text']:SetText(v552(v741['saved'][v559]));
				end
				if (v548['text']:GetText() ~= "") then
					v545:SetWidth(v9(v548['text']:GetStringWidth(), v554));
				end
				FlatIdent_5EBE4 = 1090 - (870 + 218);
			end
			if ((1329 - (852 + 477)) == FlatIdent_5EBE4) then
				if (v741['ignoreClicks'] and ((GetTime() - v741['ignoreClicks']) < (804.1 - (590 + 214)))) then
					return;
				end
				if not v542['disableValueToggle'] then
					if not v741['saved'][v559] then
						local FlatIdent_50A03 = 0 + 0;
						while true do
							if (FlatIdent_50A03 == (0 - 0)) then
								v741['saved'][v559] = true;
								v548['texture']:SetTexture([[Interface/BUTTONS/CheckButtonHilight-Blue]]);
								break;
							end
						end
					else
						local FlatIdent_52BEA = 0 + 0;
						while true do
							if ((0 + 0) == FlatIdent_52BEA) then
								v741['saved'][v559] = false;
								v548['texture']:SetTexture([[Interface\GLUES\CREDITS\Arakkoa1]]);
								break;
							end
						end
					end
				end
				FlatIdent_5EBE4 = 1 - 0;
			end
		end
	end);
	v554 = v554 + (13 - 8);
	v548:SetWidth(v554 * (447.8 - (262 + 184)));
	v548:SetHeight(v554 * (108.8 - (6 + 101)));
	v548:SetPoint("CENTER");
	v548['texture'] = v548:CreateTexture(nil, "OVERLAY");
	v548['texture']:SetAllPoints();
	v548['texture']:SetWidth(v554 * (1.8 + 0));
	v548['texture']:SetHeight(v554 * (1.8 + 0));
	v548['texture']:SetAlpha(2 - 1);
	v548['text'] = v548:CreateFontString(nil, "OVERLAY");
	v548['text']:SetFont(v29, v553, "");
	v548['text']:SetPoint("BOTTOM", 0 - 0, -(1 + 0));
	v548['text']:SetTextColor(1068 - (349 + 718), 470 - (114 + 355), 1 - 0, 604 - (237 + 366));
	if (v12(v552) == "string") then
		v548['text']:SetText(v552);
	elseif (v12(v552) == "table") then
		if v541['saved'][v559] then
			v548['text']:SetText(v552.enabled);
		else
			v548['text']:SetText(v552.disabled);
		end
	elseif (v12(v552) == "function") then
		v548['text']:SetText(v552(v541['saved'][v559]));
	end
	if (v548['text']:GetText() ~= "") then
		v545:SetWidth(v9(v548['text']:GetStringWidth(), v554));
	end
	if not v560 then
		v548['texture']:SetTexture([[Interface\GLUES\CREDITS\Arakkoa1]]);
	else
		v548['texture']:SetTexture([[Interface/BUTTONS/CheckButtonHilight-Blue]]);
	end
	v541:AddElement(v545);
	return v545;
end;
v69.AddElement = function(v564, v565)
	local FlatIdent_8CD5A = 209 - (40 + 169);
	local v566;
	local v567;
	local v568;
	local v569;
	local v570;
	local v571;
	local v572;
	while true do
		if (FlatIdent_8CD5A == (347 - (216 + 131))) then
			v566 = v564['frame'];
			v567 = v564['elements'][#v564['elements']];
			FlatIdent_8CD5A = 2 - 1;
		end
		if ((1 - 0) == FlatIdent_8CD5A) then
			while v567 and not v567:IsShown() do
				v567 = v564['elements'][#v564['elements'] - (77 - (32 + 44))];
			end
			v568, v569, v570, v571, v572 = "TOPLEFT", v566, "TOPLEFT", v564['padding'], -v564['padding'];
			FlatIdent_8CD5A = 185 - (92 + 91);
		end
		if (FlatIdent_8CD5A == (3 + 0)) then
			v2(v564.elements, v565);
			break;
		end
		if (FlatIdent_8CD5A == (1 + 1)) then
			if v567 then
				local FlatIdent_96F35 = 0 + 0;
				while true do
					if (FlatIdent_96F35 == (0 - 0)) then
						v568, v569, v570, v571, v572 = v567:GetPoint();
						v571 = v571 + v567:GetWidth() + v564['padding'];
						break;
					end
				end
			end
			v565:SetPoint(v568, v569, v570, v571, v572);
			FlatIdent_8CD5A = 11 - 8;
		end
	end
end;
v69.WrapElements = function(v573)
	local v574 = v573['frame'];
	local v575 = v573['maxWidth'];
	local v576, v577 = v573['padding'], v573['padding'] * (5 - 3);
	local v578 = 0 - 0;
	local v579, v580, v581 = 0 + 0, 0 + 0, 0 - 0;
	local v582, v583 = 0 + 0, v575;
	local v584 = 0 - 0;
	for v743, v744 in v11(v573.elements) do
		if v744:IsShown() then
			local FlatIdent_6B17E = 0 + 0;
			local v926;
			local v927;
			local v928;
			local v929;
			while true do
				if ((1 + 0) == FlatIdent_6B17E) then
					v928, v929 = v580 + v581, v579;
					if ((v743 - v584) > (1 - 0)) then
						if (v573['column'] or (((v583 - v927) - v573['padding']) < v573['padding'])) then
							local FlatIdent_74945 = 0 - 0;
							while true do
								if (FlatIdent_74945 == (1 + 0)) then
									v582 = v926;
									v928 = 0 + 0;
									FlatIdent_74945 = 2 + 0;
								end
								if (FlatIdent_74945 == (0 - 0)) then
									v929 = v929 - (v582 + v573['padding']);
									v577 = (v577 + ((v573['column'] and v926) or v582)) - (v573['padding'] / (2 + 0));
									FlatIdent_74945 = 1453 - (742 + 710);
								end
								if (FlatIdent_74945 == (2 + 0)) then
									v580 = 0 + 0;
									v583 = v575;
									FlatIdent_74945 = 3 - 0;
								end
								if (FlatIdent_74945 == (1 + 2)) then
									v578 = v9(v578, v576);
									v576 = v573['padding'];
									break;
								end
							end
						end
					end
					FlatIdent_6B17E = 2 + 0;
				end
				if (FlatIdent_6B17E == (5 - 3)) then
					v576 = v576 + v927 + v573['padding'];
					v744:SetPoint("TOPLEFT", v574, "TOPLEFT", v928 + v573['padding'], v929 - v573['padding']);
					FlatIdent_6B17E = 1235 - (662 + 570);
				end
				if (FlatIdent_6B17E == (0 - 0)) then
					v926 = v744:GetHeight();
					v927 = v744:GetWidth();
					FlatIdent_6B17E = 1 - 0;
				end
				if ((13 - 9) == FlatIdent_6B17E) then
					v580 = v928 + v927 + v573['padding'];
					v579 = v929;
					break;
				end
				if (FlatIdent_6B17E == (4 - 1)) then
					if (v929 ~= v579) then
						local FlatIdent_1866C = 0 - 0;
						while true do
							if (FlatIdent_1866C == (0 + 0)) then
								v577 = v577 + v926;
								v582 = v926;
								break;
							end
						end
					elseif (v926 > v582) then
						local FlatIdent_87F22 = 0 + 0;
						while true do
							if (FlatIdent_87F22 == (0 - 0)) then
								v577 = (v577 + v926) - v582;
								v582 = v926;
								break;
							end
						end
					end
					v583 = (v583 - v927) - v573['padding'];
					FlatIdent_6B17E = 7 - 3;
				end
			end
		else
			v584 = v584 + 1 + 0;
		end
	end
	return v9(v578, v576), v577;
end;
v69.Update = function(v585)
	local FlatIdent_5C59F = 799 - (463 + 336);
	local v586;
	local v587;
	local v588;
	local v589;
	while true do
		if ((1726 - (1091 + 635)) == FlatIdent_5C59F) then
			v586, v587 = v585['frame'], v585['ui']['saved'];
			for v745, v746 in v11(v585.elements) do
				local FlatIdent_3F2ED = 1617 - (1384 + 233);
				while true do
					if (FlatIdent_3F2ED == (964 - (392 + 572))) then
						if (v746['type'] == "string") then
							v746:SetText(v587[v746['var']]);
						end
						if v746['Update'] then
							v746:Update();
						end
						break;
					end
				end
			end
			FlatIdent_5C59F = 1 + 0;
		end
		if (FlatIdent_5C59F == (3 - 2)) then
			v588, v589 = v585:WrapElements();
			v586:SetHeight(v589);
			FlatIdent_5C59F = 1 + 1;
		end
		if (FlatIdent_5C59F == (1741 - (930 + 809))) then
			v586:SetWidth(v588);
			break;
		end
	end
end;
v1['UI'] = v20;
