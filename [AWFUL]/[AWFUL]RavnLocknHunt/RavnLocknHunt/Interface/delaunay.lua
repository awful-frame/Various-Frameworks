local v0, v1 = ...;
local v2, v3, v4 = setmetatable, tostring, assert;
local v5, v6, v7, v8 = math['max'], math['sqrt'], pairs, ipairs;
local v9, v10 = table['remove'], unpack or table['unpack'];
local v11 = {};
local v12 = {};
local v13 = {};
local v14 = {};
local function v15(v52, v53, v54)
	local FlatIdent_61D1F = 109 - (7 + 102);
	local v55;
	while true do
		if ((0 + 0) == FlatIdent_61D1F) then
			v55 = (v52 + v53 + v54) * ((v52 + v53) - v54) * ((v52 - v53) + v54) * (-v52 + v53 + v54);
			return v6(v55);
		end
	end
end
local function v16(v56, v57, v58)
	local FlatIdent_7222B = 0 + 0;
	local v59;
	local v60;
	local v61;
	local v62;
	while true do
		if (FlatIdent_7222B == (0 - 0)) then
			v59, v60 = v57['x'] - v56['x'], v58['x'] - v57['x'];
			v61, v62 = v57['y'] - v56['y'], v58['y'] - v57['y'];
			FlatIdent_7222B = 3 - 2;
		end
		if (FlatIdent_7222B == (1 + 0)) then
			return (v59 * v62) - (v61 * v60);
		end
	end
end
local function v17(v63, v64, v65)
	return v16(v63, v64, v65) == (0 - 0);
end
local v18 = {};
v18['__index'] = v18;
v18.new = function(v66, v67)
	local FlatIdent_2E90A = 0 - 0;
	local v68;
	local v69;
	local v70;
	while true do
		if (FlatIdent_2E90A == (0 - 0)) then
			v68 = v66 .. v67;
			v69 = v11[v68];
			FlatIdent_2E90A = 1 + 0;
		end
		if (FlatIdent_2E90A == (966 - (368 + 597))) then
			if v69 then
				return v69;
			end
			v70 = v2({x=v66,y=v67,id=(0 - 0)}, v18);
			FlatIdent_2E90A = 2 + 0;
		end
		if (FlatIdent_2E90A == (714 - (173 + 539))) then
			v11[v68] = v70;
			return v70;
		end
	end
end;
v18.__eq = function(v72, v73)
	return (v72['x'] == v73['x']) and (v72['y'] == v73['y']);
end;
v18.__tostring = function(v74)
	return ("Point (%s) x: %.2f y: %.2f"):format(v74.id, v74.x, v74.y);
end;
v18.dist2 = function(v75, v76)
	local FlatIdent_3F642 = 0 + 0;
	local v77;
	local v78;
	while true do
		if (FlatIdent_3F642 == (0 + 0)) then
			v77, v78 = v75['x'] - v76['x'], v75['y'] - v76['y'];
			return (v77 * v77) + (v78 * v78);
		end
	end
end;
v18.dist = function(v79, v80)
	return v6(v79:dist2(v80));
end;
v18.isInCircle = function(v81, v82, v83, v84)
	local FlatIdent_6493E = 1640 - (1141 + 499);
	local v85;
	local v86;
	while true do
		if (FlatIdent_6493E == (1 + 0)) then
			return ((v85 * v85) + (v86 * v86)) <= (v84 * v84);
		end
		if (FlatIdent_6493E == (1600 - (994 + 606))) then
			v85 = v82 - v81['x'];
			v86 = v83 - v81['y'];
			FlatIdent_6493E = 454 - (224 + 229);
		end
	end
end;
v2(v18, {__call=function(v87, v88, v89)
	return v18.new(v88, v89);
end});
local v26 = {};
v26['__index'] = v26;
v26.new = function(v90, v91)
	local FlatIdent_6946E = 1716 - (771 + 945);
	local v92;
	local v93;
	while true do
		if (FlatIdent_6946E == (3 - 1)) then
			v12[v90][v91] = v93;
			return v93;
		end
		if (FlatIdent_6946E == (1 + 0)) then
			v93 = v2({p1=v90,p2=v91}, v26);
			if not v12[v90] then
				v12[v90] = {};
			end
			FlatIdent_6946E = 2 + 0;
		end
		if (FlatIdent_6946E == (176 - (124 + 52))) then
			v92 = v12[v90] and v12[v90][v91];
			if v92 then
				return v92;
			end
			FlatIdent_6946E = 1 + 0;
		end
	end
end;
v26.__eq = function(v95, v96)
	return (v95['p1'] == v96['p1']) and (v95['p2'] == v96['p2']);
end;
v26.__tostring = function(v97)
	return (("Edge :\n  %s\n  %s"):format(v3(v97.p1), v3(v97.p2)));
end;
v26.same = function(v98, v99)
	return ((v98['p1'] == v99['p1']) and (v98['p2'] == v99['p2'])) or ((v98['p1'] == v99['p2']) and (v98['p2'] == v99['p1']));
end;
v26.length = function(v100)
	return v100['p1']:dist(v100.p2);
end;
v26.getMidPoint = function(v101)
	local FlatIdent_95366 = 1221 - (706 + 515);
	local v102;
	local v103;
	while true do
		if (FlatIdent_95366 == (0 + 0)) then
			v102 = v101['p1']['x'] + ((v101['p2']['x'] - v101['p1']['x']) / (4 - 2));
			v103 = v101['p1']['y'] + ((v101['p2']['y'] - v101['p1']['y']) / (3 - 1));
			FlatIdent_95366 = 2 - 1;
		end
		if (FlatIdent_95366 == (2 - 1)) then
			return v102, v103;
		end
	end
end;
v2(v26, {__call=function(v104, v105, v106)
	return v26.new(v105, v106);
end});
local v34 = {};
v34['__index'] = v34;
v34.new = function(v107, v108, v109)
	local FlatIdent_3B8B0 = 0 + 0;
	local v110;
	local v111;
	while true do
		if (FlatIdent_3B8B0 == (2 - 0)) then
			if not v13[v107][v108] then
				v13[v107][v108] = {};
			end
			v111 = v2({p1=v107,p2=v108,p3=v109,e1=v26(v107, v108),e2=v26(v108, v109),e3=v26(v109, v107)}, v34);
			FlatIdent_3B8B0 = 1 + 2;
		end
		if (FlatIdent_3B8B0 == (1 - 0)) then
			if v110 then
				return v110;
			end
			if not v13[v107] then
				v13[v107] = {};
			end
			FlatIdent_3B8B0 = 1 + 1;
		end
		if (FlatIdent_3B8B0 == (1475 - (1208 + 264))) then
			v13[v107][v108][v109] = v111;
			return v111;
		end
		if (FlatIdent_3B8B0 == (0 - 0)) then
			if (not v107 or not v108 or not v109) then
				return nil;
			end
			v110 = v13[v107] and v13[v107][v108] and v13[v107][v108][v109];
			FlatIdent_3B8B0 = 3 - 2;
		end
	end
end;
v34.__tostring = function(v113)
	return (("Triangle: \n  %s\n  %s\n  %s"):format(v3(v113.p1), v3(v113.p2), v3(v113.p3)));
end;
v34.isCW = function(v114)
	return v16(v114.p1, v114.p2, v114.p3) < (1490 - (865 + 625));
end;
v34.isCCW = function(v115)
	return v16(v115.p1, v115.p2, v115.p3) > (0 - 0);
end;
v34.getSidesLength = function(v116)
	return v116['e1']:length(), v116['e2']:length(), v116['e3']:length();
end;
v34.getCenter = function(v117)
	local FlatIdent_6E09E = 0 - 0;
	local v118;
	local v119;
	while true do
		if (FlatIdent_6E09E == (3 - 2)) then
			return v118, v119;
		end
		if (FlatIdent_6E09E == (0 - 0)) then
			v118 = (v117['p1']['x'] + v117['p2']['x'] + v117['p3']['x']) / (3 - 0);
			v119 = (v117['p1']['y'] + v117['p2']['y'] + v117['p3']['y']) / (3 - 0);
			FlatIdent_6E09E = 2 - 1;
		end
	end
end;
v34.getCircumCircle = function(v120)
	local FlatIdent_36FB8 = 0 + 0;
	local v121;
	local v122;
	local v123;
	while true do
		if (FlatIdent_36FB8 == (456 - (136 + 320))) then
			v121, v122 = v120:getCircumCenter();
			v123 = v120:getCircumRadius();
			FlatIdent_36FB8 = 2 - 1;
		end
		if (FlatIdent_36FB8 == (1 + 0)) then
			return v121, v122, v123;
		end
	end
end;
v34.getCircumCenter = function(v124)
	local FlatIdent_43C74 = 1738 - (738 + 1000);
	local v125;
	local v126;
	local v127;
	local v128;
	local v129;
	local v130;
	while true do
		if (FlatIdent_43C74 == (5 - 3)) then
			return v129 / v128, v130 / v128;
		end
		if ((2 - 1) == FlatIdent_43C74) then
			v129 = (((v125['x'] * v125['x']) + (v125['y'] * v125['y'])) * (v126['y'] - v127['y'])) + (((v126['x'] * v126['x']) + (v126['y'] * v126['y'])) * (v127['y'] - v125['y'])) + (((v127['x'] * v127['x']) + (v127['y'] * v127['y'])) * (v125['y'] - v126['y']));
			v130 = (((v125['x'] * v125['x']) + (v125['y'] * v125['y'])) * (v127['x'] - v126['x'])) + (((v126['x'] * v126['x']) + (v126['y'] * v126['y'])) * (v125['x'] - v127['x'])) + (((v127['x'] * v127['x']) + (v127['y'] * v127['y'])) * (v126['x'] - v125['x']));
			FlatIdent_43C74 = 6 - 4;
		end
		if (FlatIdent_43C74 == (0 - 0)) then
			v125, v126, v127 = v124['p1'], v124['p2'], v124['p3'];
			v128 = ((v125['x'] * (v126['y'] - v127['y'])) + (v126['x'] * (v127['y'] - v125['y'])) + (v127['x'] * (v125['y'] - v126['y']))) * (1 + 1);
			FlatIdent_43C74 = 2 - 1;
		end
	end
end;
v34.getCircumRadius = function(v131)
	local FlatIdent_8C49E = 1789 - (894 + 895);
	local v132;
	local v133;
	local v134;
	while true do
		if (FlatIdent_8C49E == (0 - 0)) then
			v132, v133, v134 = v131:getSidesLength();
			return (v132 * v133 * v134) / v15(v132, v133, v134);
		end
	end
end;
v34.getArea = function(v135)
	local FlatIdent_66D22 = 0 + 0;
	local v136;
	local v137;
	local v138;
	while true do
		if (FlatIdent_66D22 == (382 - (126 + 256))) then
			v136, v137, v138 = v135:getSidesLength();
			return v15(v136, v137, v138) / (7 - 3);
		end
	end
end;
v34.inCircumCircle = function(v139, v140)
	return v140:isInCircle(v139:getCircumCircle());
end;
v2(v34, {__call=function(v141, v142, v143, v144)
	return v34.new(v142, v143, v144);
end});
local v47 = {Point=v18,Edge=v26,Triangle=v34,convexMultiplier=(1393 - 393)};
local function v48(v145)
	local FlatIdent_5159C = 935 - (397 + 538);
	local v146;
	local v147;
	local v148;
	while true do
		if (FlatIdent_5159C == (0 + 0)) then
			v146, v147 = 29 + 2, 1923 - (1379 + 485);
			v148 = 1097 - (313 + 784);
			FlatIdent_5159C = 1 - 0;
		end
		if (FlatIdent_5159C == (709 - (79 + 629))) then
			for v175, v176 in v8(v145) do
				local FlatIdent_513F6 = 0 - 0;
				while true do
					if (FlatIdent_513F6 == (0 + 0)) then
						v148 = (v148 * v146) + v176['x'];
						v148 = (v148 * v147) + v176['y'];
						break;
					end
				end
			end
			return v3(v148);
		end
	end
end
local v49 = {};
v47.triangulate = function(v149)
	local v150 = #v149;
	v4(v150 > (1739 - (1471 + 266)), "Cannot triangulate, needs more than 3 vertices");
	local v151 = v48(v149);
	local v152 = v14[v151];
	if v152 then
		return v152;
	end
	if (v150 == (1490 - (285 + 1202))) then
		local FlatIdent_61E6E = 0 - 0;
		local v189;
		while true do
			if (FlatIdent_61E6E == (1 + 0)) then
				return v189;
			end
			if (FlatIdent_61E6E == (0 - 0)) then
				v189 = {v34(v149[3 - 2], v149[876 - (346 + 528)], v149[5 - 2])};
				v14[v151] = v189;
				FlatIdent_61E6E = 1284 - (1043 + 240);
			end
		end
	end
	local v153 = v150 * (978 - (327 + 647));
	local v154, v155 = v149[911 - (780 + 130)]['x'], v149[1 - 0]['y'];
	local v156, v157 = v154, v155;
	for v177 = 687 - (265 + 421), #v149 do
		local FlatIdent_9EDB = 387 - (298 + 89);
		local v178;
		while true do
			if ((598 - (360 + 236)) == FlatIdent_9EDB) then
				if (v178['x'] > v156) then
					v156 = v178['x'];
				end
				if (v178['y'] > v157) then
					v157 = v178['y'];
				end
				break;
			end
			if (FlatIdent_9EDB == (2 - 1)) then
				if (v178['x'] < v154) then
					v154 = v178['x'];
				end
				if (v178['y'] < v155) then
					v155 = v178['y'];
				end
				FlatIdent_9EDB = 1 + 1;
			end
			if (FlatIdent_9EDB == (0 + 0)) then
				v178 = v149[v177];
				v178['id'] = v177;
				FlatIdent_9EDB = 4 - 3;
			end
		end
	end
	local v158 = v47['convexMultiplier'];
	local v159, v160 = (v156 - v154) * v158, (v157 - v155) * v158;
	local v161 = v5(v159, v160);
	local v162, v163 = (v154 + v156) * (0.5 + 0), (v155 + v157) * (0.5 + 0);
	local v164 = v18(v162 - ((2 + 0) * v161), v163 - v161);
	local v165 = v18(v162, v163 + ((1 + 1) * v161));
	local v166 = v18(v162 + ((5 - 3) * v161), v163 - v161);
	v164['id'], v165['id'], v166['id'] = v150 + (1 - 0), v150 + (1428 - (976 + 450)), v150 + (55 - (23 + 29));
	v149[v164['id']], v149[v165['id']], v149[v166['id']] = v164, v165, v166;
	local v173 = {v34(v149[v150 + (1 - 0)], v149[v150 + (739 - (89 + 648))], v149[v150 + 2 + 1])};
	for v180 = 1453 - (503 + 949), v150 do
		local FlatIdent_68AF3 = 0 - 0;
		local v181;
		local v182;
		while true do
			if (FlatIdent_68AF3 == (4 - 3)) then
				v182 = #v173;
				for v193 = v182, 1 + 0, -(730 - (307 + 422)) do
					local FlatIdent_763ED = 118 - (61 + 57);
					local v194;
					while true do
						if (FlatIdent_763ED == (0 - 0)) then
							v194 = v173[v193];
							if v194:inCircumCircle(v181) then
								local FlatIdent_408DC = 0 + 0;
								while true do
									if (FlatIdent_408DC == (561 - (517 + 44))) then
										v49[#v49 + 1 + 0] = v194['e1'];
										v49[#v49 + 1 + 0] = v194['e2'];
										FlatIdent_408DC = 1 + 0;
									end
									if (FlatIdent_408DC == (1 + 0)) then
										v49[#v49 + (2 - 1)] = v194['e3'];
										v9(v173, v193);
										break;
									end
								end
							end
							break;
						end
					end
				end
				FlatIdent_68AF3 = 3 - 1;
			end
			if (FlatIdent_68AF3 == (0 + 0)) then
				v181 = v149[v180];
				for v191 = #v49, 325 - (221 + 103), -(2 - 1) do
					v49[v191] = nil;
				end
				FlatIdent_68AF3 = 1 + 0;
			end
			if (FlatIdent_68AF3 == (3 - 1)) then
				for v195 = #v49 - (788 - (324 + 463)), 1531 - (748 + 782), -(205 - (120 + 84)) do
					for v203 = #v49, v195 + (1 - 0), -(2 - 1) do
						if (v49[v195] and v49[v203] and v49[v195]:same(v49[v203])) then
							local FlatIdent_93D08 = 750 - (138 + 612);
							while true do
								if (FlatIdent_93D08 == (0 - 0)) then
									v9(v49, v195);
									v9(v49, v203 - (1 - 0));
									break;
								end
							end
						end
					end
				end
				for v196 = 1 - 0, #v49 do
					local FlatIdent_82BB6 = 1150 - (1051 + 99);
					local v197;
					while true do
						if (FlatIdent_82BB6 == (1 - 0)) then
							v173[v197 + (3 - 2)] = v34(v49[v196].p1, v49[v196].p2, v181);
							break;
						end
						if ((0 + 0) == FlatIdent_82BB6) then
							v197 = #v173;
							v4(v197 <= v153, "Generated more than needed triangles");
							FlatIdent_82BB6 = 1678 - (709 + 968);
						end
					end
				end
				break;
			end
		end
	end
	for v183 = #v173, 1 + 0, -(3 - 2) do
		local FlatIdent_4A83D = 0 + 0;
		local v184;
		while true do
			if (FlatIdent_4A83D == (340 - (159 + 181))) then
				v184 = v173[v183];
				if ((v184['p1']['id'] > v150) or (v184['p2']['id'] > v150) or (v184['p3']['id'] > v150)) then
					v9(v173, v183);
				end
				break;
			end
		end
	end
	for v185 = 1 - 0, 5 - 2 do
		v9(v149);
	end
	v14[v151] = v173;
	return v173;
end;
C_Timer.NewTicker(1 + 4, function()
	local FlatIdent_53B16 = 1621 - (645 + 976);
	while true do
		if (FlatIdent_53B16 == (1 + 0)) then
			wipe(v11);
			wipe(v14);
			break;
		end
		if (FlatIdent_53B16 == (0 - 0)) then
			wipe(v13);
			wipe(v12);
			FlatIdent_53B16 = 1 + 0;
		end
	end
end);
v1['delaunay'] = v47;
