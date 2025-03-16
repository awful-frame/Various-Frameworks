local v0, v1 = ...;
local v2 = math;
local v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13 = v2['abs'], v2['sqrt'], v2['rad'], v2['sin'], v2['cos'], v2['floor'], v2['min'], v2['max'], v2['pi'], v2['pi'] * (297 - (197 + 98)), v2['atan'];
local v14, v15, v16, v17, v18 = type, string['len'], tonumber, pairs, ipairs;
local v19, v20, v21 = table['insert'], table['remove'], table['sort'];
local v22, v23 = GetScreenHeight, GetScreenWidth;
local v24 = IsMacClient;
local v25 = v0['type'] or "tinkr";
local v26 = ((v25 ~= "daemonic") and CameraPosition) or GetCameraPosition;
local v27 = v1['Distance'];
local v28, v29, v30 = v1['player'], v1['target'], v1['healer'];
local v31 = v1['colors'];
local v32 = v1['delaunay'] or {};
local v33 = v32['triangulate'];
local v34 = v32['Point'];
local v35 = CreateFont("tempFont");
v35:SetFont("Fonts\\ARIALN.TTF", 52 - 38, "");
local function v36(v99)
	local FlatIdent_93508 = 0 - 0;
	local v99;
	while true do
		if (FlatIdent_93508 == (2 - 1)) then
			return v16("0x" .. v99:sub(1 + 0, 4 - 2)), v16("0x" .. v99:sub(1 + 2, 386 - (318 + 64))), v16("0x" .. v99:sub(1181 - (529 + 647), 3 + 3));
		end
		if (FlatIdent_93508 == (494 - (192 + 302))) then
			v99 = v99:gsub("#", "");
			v99 = v99:gsub("|cFF", "");
			FlatIdent_93508 = 1 - 0;
		end
	end
end
local v37 = v1['posFromPos'];
local v38 = v1['getRect'];
local v39 = {{},{},{},{},{}};
local v40 = {v1={(0 - 0),(1220 - (983 + 237)),(1574 - (1222 + 352))},v2={(838 - (195 + 643)),(0 + 0),(0 - 0)},v3={(0 + 0),(0 + 0),(0 + 0)}};
v1['PathsToDraw'] = {};
local v42 = {colors={white={(703 - 448),(2147 - (128 + 1764)),(1107 - 852)},red={(186 + 69),(314 - 234),(1 + 79)},orange={(1090 - 835),(1326 - (263 + 922)),(1919 - (1346 + 493))},yellow={(754 - (365 + 134)),(74 + 154),(98 - 18)},green={(5 + 75),(1434 - (593 + 586)),(237 - 96)},teal={(167 - 87),(2123 - (1790 + 78)),(2028 - (974 + 826))},blue={(1626 - (213 + 1333)),(570 - (211 + 218)),(1163 - (673 + 235))},purple={(428 - 287),(440 - (96 + 264)),(120 + 135)},pink={(134 + 121),(33 + 47),(16 + 89)},grey={(112 + 29),(341 - (94 + 106)),(245 - 104)}}};
v42.CameraPosition = function(v100)
	return v26();
end;
v42.Map = function(v101, v102, v103, v104, v105, v106)
	return v105 + (((v102 - v103) * (v106 - v105)) / (v104 - v103));
end;
v42.SetColor = function(v107, v108, v109, v110, v111)
	local FlatIdent_A61D = 0 - 0;
	while true do
		if (FlatIdent_A61D == (3 - 2)) then
			v107['color'][1 + 1] = v109 / (66 + 189);
			v107['color'][1329 - (1056 + 270)] = v110 / (781 - (298 + 228));
			FlatIdent_A61D = 5 - 3;
		end
		if (FlatIdent_A61D == (1856 - (1017 + 837))) then
			v107['color'][2 + 2] = (v111 or (20 + 235)) / (787 - 532);
			break;
		end
		if (FlatIdent_A61D == (0 - 0)) then
			if (v14(v108) == "string") then
				v108, v109, v110, v111 = v107:HexToRGB(v108);
			elseif (v14(v108) == "table") then
				v108, v109, v110, v111 = v108[1607 - (193 + 1413)], v108[2 + 0], v108[2 + 1], v109;
			end
			v107['color'][1 + 0] = v108 / (1856 - (534 + 1067));
			FlatIdent_A61D = 1 + 0;
		end
	end
end;
v42.SetColorRaw = function(v116, v117, v118, v119, v120)
	if (v14(v117) == "table") then
		local FlatIdent_8C01D = 0 + 0;
		while true do
			if (FlatIdent_8C01D == (689 - (257 + 431))) then
				v116['color'][7 - 4] = v117[7 - 4];
				v116['color'][4 + 0] = v117[272 - (124 + 144)] or (305 - (16 + 288));
				break;
			end
			if (FlatIdent_8C01D == (0 - 0)) then
				v116['color'][1 - 0] = v117[1 + 0];
				v116['color'][933 - (491 + 440)] = v117[1643 - (971 + 670)];
				FlatIdent_8C01D = 1 + 0;
			end
		end
	else
		local FlatIdent_804A3 = 0 - 0;
		while true do
			if (FlatIdent_804A3 == (1681 - (1146 + 534))) then
				v116['color'][216 - (112 + 101)] = v119;
				v116['color'][1 + 3] = v120;
				break;
			end
			if (FlatIdent_804A3 == (0 + 0)) then
				v116['color'][723 - (459 + 263)] = v117;
				v116['color'][5 - 3] = v118;
				FlatIdent_804A3 = 1 + 0;
			end
		end
	end
end;
v42.SetAlpha = function(v121, v122)
	v121['color'][52 - (47 + 1)] = (v122 or (169 + 86)) / (524 - 269);
end;
v42.Distance = function(v124, v125, v126, v127, v128, v129, v130)
	return v27(v125, v126, v127, v128, v129, v130);
end;
v42.SetWidth = function(v131, v132)
	v131['line_width'] = v132;
end;
local function v50(v134, v135, v136, v137)
	local FlatIdent_95EDF = 0 + 0;
	local v138;
	local v139;
	local v140;
	local v141;
	local v142;
	local v143;
	local v144;
	local v145;
	local v146;
	local v147;
	while true do
		if (FlatIdent_95EDF == (1943 - (1764 + 178))) then
			v138 = v2.sin(v135);
			v139 = v2.cos(v135);
			v140 = v2.sin(v136);
			FlatIdent_95EDF = 2 + 0;
		end
		if (FlatIdent_95EDF == (2 + 3)) then
			v146 = (v147 * v142) + (v146 * v143);
			return {x=v144,y=v146,z=v145};
		end
		if (FlatIdent_95EDF == (0 + 0)) then
			v135 = v135 or (0 - 0);
			v136 = v136 or (0 - 0);
			v137 = v137 or (0 - 0);
			FlatIdent_95EDF = 1 + 0;
		end
		if (FlatIdent_95EDF == (790 - (276 + 511))) then
			v144 = (v134['x'] * v141) - (v134['z'] * v140);
			v145 = (v134['x'] * v140) + (v134['z'] * v141);
			v146 = (v134['y'] * v139) - (v145 * v138);
			FlatIdent_95EDF = 3 + 1;
		end
		if (FlatIdent_95EDF == (1841 - (516 + 1323))) then
			v141 = v2.cos(v136);
			v142 = v2.sin(v137);
			v143 = v2.cos(v137);
			FlatIdent_95EDF = 11 - 8;
		end
		if (FlatIdent_95EDF == (3 + 1)) then
			v145 = (v134['y'] * v138) + (v145 * v139);
			v147 = v144;
			v144 = (v147 * v143) - (v146 * v142);
			FlatIdent_95EDF = 1123 - (90 + 1028);
		end
	end
end
local function v51(v148, v149, v150, v151)
	local FlatIdent_71F0C = 1809 - (1648 + 161);
	local v152;
	while true do
		if (FlatIdent_71F0C == (1 + 0)) then
			v148['v'] = v152;
			break;
		end
		if ((0 + 0) == FlatIdent_71F0C) then
			v152 = {};
			for v596, v597 in v18(v148.v) do
				v19(v152, v50(v597, v149, v150, v151));
			end
			FlatIdent_71F0C = 1 + 0;
		end
	end
end
v42.RotateObject = function(v154, v155, v156, v157, v158)
	v51(v155, v156, v157, v158);
end;
v42.Object = function(v159, v160, v161, v162, v163, v164, v165)
	v164 = v164 or (2 - 1);
	local v166 = v160['f'];
	local v167 = v160['v'];
	local v168 = v160['materials'] or {};
	local v169, v170, v171 = v159:CameraPosition();
	local v172 = {};
	local v173 = v159['color'][7 - 3] or (1 - 0);
	local v174, v175, v176 = v159['color'][1 + 0], v159['color'][1 + 1], v159['color'][4 - 1];
	for v598, v599 in v18(v166) do
		local v600 = {};
		for v709, v710 in v18(v599) do
			local FlatIdent_2BFCD = 0 - 0;
			local v711;
			local v712;
			while true do
				if (FlatIdent_2BFCD == (2 - 1)) then
					v712['z'] = v711['z'] * v164;
					v19(v600, v712);
					break;
				end
				if (FlatIdent_2BFCD == (1649 - (1370 + 279))) then
					v711 = v167[v710['v']];
					v712 = v34(v711['x'] * v164, v711['y'] * v164);
					FlatIdent_2BFCD = 1 - 0;
				end
			end
		end
		local v601 = v33(v600);
		for v714, v715 in v18(v601) do
			local FlatIdent_84A9C = 1996 - (742 + 1254);
			local v716;
			local v717;
			local v718;
			local v719;
			local v720;
			local v721;
			local v722;
			local v723;
			local v724;
			local v725;
			local v726;
			local v727;
			local v728;
			local v729;
			local v730;
			local v731;
			local v732;
			local v733;
			local v734;
			local v735;
			local v736;
			local v737;
			while true do
				if (FlatIdent_84A9C == (2 + 0)) then
					v732, v733, v734 = v169 - v723, v170 - v724, v171 - v725;
					v735 = v2.sqrt((v726 * v726) + (v727 * v727) + (v728 * v728));
					v736 = v2.sqrt((v729 * v729) + (v730 * v730) + (v731 * v731));
					FlatIdent_84A9C = 264 - (176 + 85);
				end
				if ((1208 - (1146 + 61)) == FlatIdent_84A9C) then
					v723, v724, v725 = v715['p3']['x'] + v161, v715['p3']['y'] + v162, v715['p3']['z'] + v163;
					v726, v727, v728 = v169 - v717, v170 - v718, v171 - v719;
					v729, v730, v731 = v169 - v720, v170 - v721, v171 - v722;
					FlatIdent_84A9C = 2 - 0;
				end
				if (FlatIdent_84A9C == (2 + 1)) then
					v737 = v2.sqrt((v732 * v732) + (v733 * v733) + (v734 * v734));
					v716['distance'] = (v735 + v736 + v737) / (3 - 0);
					v19(v172, v716);
					break;
				end
				if ((1758 - (1222 + 536)) == FlatIdent_84A9C) then
					v716 = {p1=v715['p1'],p2=v715['p2'],p3=v715['p3'],mat=v599['material']};
					v717, v718, v719 = v715['p1']['x'] + v161, v715['p1']['y'] + v162, v715['p1']['z'] + v163;
					v720, v721, v722 = v715['p2']['x'] + v161, v715['p2']['y'] + v162, v715['p2']['z'] + v163;
					FlatIdent_84A9C = 1 + 0;
				end
			end
		end
	end
	v21(v172, function(v602, v603)
		return v602['distance'] < v603['distance'];
	end);
	local v177 = #v172;
	local v178 = v177 / (4 + 0);
	local v179;
	for v604, v605 in v18(v172) do
		local FlatIdent_6F0C3 = 0 - 0;
		local v606;
		local v607;
		while true do
			if (FlatIdent_6F0C3 == (37 - (10 + 25))) then
				v40['v2']['z'] = v605['p2']['z'] + v163;
				v40['v3']['x'] = v605['p3']['x'] + v161;
				v40['v3']['y'] = v605['p3']['y'] + v162;
				v40['v3']['z'] = v605['p3']['z'] + v163;
				FlatIdent_6F0C3 = 2 + 1;
			end
			if (FlatIdent_6F0C3 == (0 + 0)) then
				v606 = ((v604 < (v178 / (9.8 - 7))) and "OVERLAY") or ((v604 < (v178 / (9 - 7))) and "ARTWORK") or ((v604 < (v178 * (239 - (72 + 165)))) and "BORDER") or "BACKGROUND";
				v607 = v605['mat'];
				if v607 then
					if (v179 ~= v607) then
						local FlatIdent_7DB3C = 0 + 0;
						local v889;
						while true do
							if (FlatIdent_7DB3C == (0 + 0)) then
								v179 = v607;
								v889 = v168[v607];
								FlatIdent_7DB3C = 1 + 0;
							end
							if (FlatIdent_7DB3C == (1355 - (1228 + 126))) then
								if v889 then
									local FlatIdent_7D82E = 0 + 0;
									local v936;
									while true do
										if (FlatIdent_7D82E == (1443 - (278 + 1165))) then
											v936 = v889['Kd'];
											if v936 then
												local FlatIdent_233DB = 0 + 0;
												local v939;
												local v940;
												local v941;
												while true do
													if (FlatIdent_233DB == (0 + 0)) then
														v939, v940, v941 = v936['r'], v936['g'], v936['b'];
														if (v165 and (v939 > (1001.7 - (129 + 872))) and (v940 > (0.7 - 0)) and (v941 > (701.7 - (58 + 643)))) then
															v159:SetColor(v174 * (401 - 146), v175 * (418 - 163), v176 * (142 + 113), v173 * (197 + 58));
														else
															v159:SetColor(v939 * (69 + 186), v940 * (896 - 641), v941 * (1816 - (517 + 1044)), v173 * (1929 - (789 + 885)));
														end
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
						end
					end
				end
				v40['v1']['x'] = v605['p1']['x'] + v161;
				FlatIdent_6F0C3 = 2 - 1;
			end
			if (FlatIdent_6F0C3 == (3 + 0)) then
				v159:Triangle(750 - (484 + 266), 1767 - (1538 + 229), 1032 - (142 + 890), v40.v1, v40.v2, v40.v3, true, false, v606);
				break;
			end
			if (FlatIdent_6F0C3 == (857 - (326 + 530))) then
				v40['v1']['y'] = v605['p1']['y'] + v162;
				v40['v1']['z'] = v605['p1']['z'] + v163;
				v40['v2']['x'] = v605['p2']['x'] + v161;
				v40['v2']['y'] = v605['p2']['y'] + v162;
				FlatIdent_6F0C3 = 449 - (363 + 84);
			end
		end
	end
	v159:SetColor(v174, v175, v176);
end;
v42.LaplacianSmoothing = function(v180, v181, v182)
	local FlatIdent_7E15B = 0 - 0;
	while true do
		if (FlatIdent_7E15B == (0 + 0)) then
			if v181['smoothed'] then
				return;
			end
			v181['smoothed'] = true;
			FlatIdent_7E15B = 1377 - (783 + 593);
		end
		if (FlatIdent_7E15B == (3 - 2)) then
			v182 = v182 or (653 - (324 + 328));
			for v617 = 951 - (386 + 564), v182 do
				local FlatIdent_1B813 = 0 + 0;
				local v618;
				while true do
					if (FlatIdent_1B813 == (0 + 0)) then
						v618 = {};
						for v739, v740 in v18(v181.v) do
							local FlatIdent_585BD = 0 - 0;
							local v741;
							while true do
								if (FlatIdent_585BD == (1 + 0)) then
									if (#v741 > (0 + 0)) then
										local FlatIdent_31A8C = 0 - 0;
										local v857;
										local v858;
										local v859;
										while true do
											if (FlatIdent_31A8C == (0 + 0)) then
												v857, v858, v859 = 0 + 0, 0 - 0, 315 - (212 + 103);
												for v890, v891 in v18(v741) do
													local FlatIdent_38BBF = 0 - 0;
													while true do
														if (FlatIdent_38BBF == (1813 - (1667 + 145))) then
															v859 = v859 + v891['z'];
															break;
														end
														if (FlatIdent_38BBF == (0 - 0)) then
															v857 = v857 + v891['x'];
															v858 = v858 + v891['y'];
															FlatIdent_38BBF = 1 + 0;
														end
													end
												end
												FlatIdent_31A8C = 2 - 1;
											end
											if (FlatIdent_31A8C == (1596 - (1581 + 14))) then
												v618[v739] = {x=(v857 / #v741),y=(v858 / #v741),z=(v859 / #v741)};
												break;
											end
										end
									else
										v618[v739] = v740;
									end
									break;
								end
								if (FlatIdent_585BD == (0 + 0)) then
									v741 = {};
									for v833, v834 in v18(v181.f) do
										for v855, v856 in v18(v834) do
											if (v856['v'] == v739) then
												for v937, v938 in v18(v834) do
													if (v938['v'] ~= v739) then
														v19(v741, v181['v'][v938['v']]);
													end
												end
											end
										end
									end
									FlatIdent_585BD = 1555 - (1127 + 427);
								end
							end
						end
						FlatIdent_1B813 = 1 - 0;
					end
					if (FlatIdent_1B813 == (1 + 0)) then
						v181['v'] = v618;
						break;
					end
				end
			end
			break;
		end
	end
end;
v42.RotateX = function(v184, v185, v186, v187, v188, v189, v190, v191)
	local FlatIdent_7EE0 = 1389 - (283 + 1106);
	local v192;
	local v193;
	local v194;
	local v195;
	local v196;
	while true do
		if (FlatIdent_7EE0 == (9 - 6)) then
			v196 = (v189 * v192) + (v190 * v193) + v187;
			return v194, v195, v196;
		end
		if ((101 - (83 + 18)) == FlatIdent_7EE0) then
			if not v191 then
				return v188, v189, v190;
			end
			v192 = v6(v191);
			FlatIdent_7EE0 = 2 - 1;
		end
		if (FlatIdent_7EE0 == (548 - (229 + 317))) then
			v194 = v188 + v185;
			v195 = ((v189 * v193) - (v190 * v192)) + v186;
			FlatIdent_7EE0 = 742 - (196 + 543);
		end
		if (FlatIdent_7EE0 == (1 - 0)) then
			v193 = v7(v191);
			v188, v189, v190 = v188 - v185, v189 - v186, v190 - v187;
			FlatIdent_7EE0 = 5 - 3;
		end
	end
end;
v42.RotateY = function(v197, v198, v199, v200, v201, v202, v203, v204)
	local FlatIdent_1BC61 = 0 + 0;
	local v205;
	local v206;
	local v207;
	local v208;
	local v209;
	while true do
		if (FlatIdent_1BC61 == (2 + 1)) then
			v209 = ((v203 * v206) - (v201 * v205)) + v200;
			return v207, v208, v209;
		end
		if (FlatIdent_1BC61 == (4 - 3)) then
			v206 = v7(v204);
			v201, v202, v203 = v201 - v198, v202 - v199, v203 - v200;
			FlatIdent_1BC61 = 1627 - (219 + 1406);
		end
		if (FlatIdent_1BC61 == (0 - 0)) then
			if not v204 then
				return v201, v202, v203;
			end
			v205 = v6(v204);
			FlatIdent_1BC61 = 1627 - (1362 + 264);
		end
		if (FlatIdent_1BC61 == (1 + 1)) then
			v207 = (v203 * v205) + (v201 * v206) + v198;
			v208 = v202 + v199;
			FlatIdent_1BC61 = 2 + 1;
		end
	end
end;
v42.RotateZ = function(v210, v211, v212, v213, v214, v215, v216, v217)
	local FlatIdent_624EC = 0 - 0;
	local v218;
	local v219;
	local v220;
	local v221;
	local v222;
	while true do
		if (FlatIdent_624EC == (0 + 0)) then
			if not v217 then
				return v214, v215, v216;
			end
			v218 = v6(v217);
			FlatIdent_624EC = 1 + 0;
		end
		if (FlatIdent_624EC == (669 - (420 + 247))) then
			v220 = ((v214 * v219) - (v215 * v218)) + v211;
			v221 = (v214 * v218) + (v215 * v219) + v212;
			FlatIdent_624EC = 8 - 5;
		end
		if (FlatIdent_624EC == (258 - (218 + 39))) then
			v219 = v7(v217);
			v214, v215, v216 = v214 - v211, v215 - v212, v216 - v213;
			FlatIdent_624EC = 731 - (198 + 531);
		end
		if (FlatIdent_624EC == (3 + 0)) then
			v222 = v216 + v213;
			return v220, v221, v222;
		end
	end
end;
v42.Line = function(v223, v224, v225, v226, v227, v228, v229, v230, v231)
	local FlatIdent_15160 = 0 + 0;
	while true do
		if (FlatIdent_15160 == (2 - 1)) then
			if (v223:Distance(v224, v225, v226, v227, v228, v229) > v230) then
				if v231 then
					return false;
				else
					local FlatIdent_35151 = 0 - 0;
					local v862;
					local v863;
					local v864;
					while true do
						if (FlatIdent_35151 == (2 - 1)) then
							v223:Line(v862, v863, v864, v227, v228, v229, nil, true);
							break;
						end
						if (FlatIdent_35151 == (0 - 0)) then
							v862, v863, v864 = (v224 + v227) / (3 - 1), (v225 + v228) / (6 - 4), (v226 + v229) / (1 + 1);
							v223:Line(v224, v225, v226, v862, v863, v864, nil, true);
							FlatIdent_35151 = 1 + 0;
						end
					end
				end
			else
				local FlatIdent_2295E = 422 - (116 + 306);
				local v742;
				local v743;
				local v744;
				local v745;
				while true do
					if (FlatIdent_2295E == (1226 - (947 + 279))) then
						v742, v743 = v223:WorldToScreen(v224, v225, v226);
						v744, v745 = v223:WorldToScreen(v227, v228, v229);
						FlatIdent_2295E = 4 - 3;
					end
					if (FlatIdent_2295E == (1470 - (741 + 728))) then
						if (not v742 or not v743 or not v744 or not v745) then
							return;
						end
						v223:Line2D(v742, v743, v744, v745);
						break;
					end
				end
			end
			break;
		end
		if (FlatIdent_15160 == (0 + 0)) then
			if (not v224 or not v225 or not v226 or not v227 or not v228 or not v229) then
				return;
			end
			if not v230 then
				v230 = 128 - 78;
			end
			FlatIdent_15160 = 1 + 0;
		end
	end
end;
v42.LineRaw = function(v232, v233, v234, v235, v236, v237, v238)
	local FlatIdent_3F0A9 = 769 - (753 + 16);
	local v239;
	local v240;
	local v241;
	local v242;
	while true do
		if (FlatIdent_3F0A9 == (0 + 0)) then
			if (not v233 or not v234 or not v235 or not v236 or not v237 or not v238) then
				return;
			end
			v239, v240 = v232:WorldToScreen(v233, v234, v235);
			FlatIdent_3F0A9 = 1 - 0;
		end
		if (FlatIdent_3F0A9 == (3 - 1)) then
			v232:Line2D(v239, v240, v241, v242);
			break;
		end
		if ((1561 - (741 + 819)) == FlatIdent_3F0A9) then
			v241, v242 = v232:WorldToScreen(v236, v237, v238);
			if ((v239 == false) or (v240 == false) or (v241 == false) or (v242 == false)) then
				return;
			end
			FlatIdent_3F0A9 = 4 - 2;
		end
	end
end;
v42.Line2D = function(v243, v244, v245, v246, v247)
	local FlatIdent_92C49 = 1567 - (75 + 1492);
	local v248;
	while true do
		if (FlatIdent_92C49 == (1 + 0)) then
			if (v248 == false) then
				v248 = v243['canvas']:CreateLine();
			end
			v248:SetColorTexture(v243['color'][2 - 1], v243['color'][1 + 1], v243['color'][1994 - (683 + 1308)], v9(1654 - (481 + 1172), v10(0 - 0, v243['color'][3 + 1])));
			v248:SetThickness(v243.line_width);
			v248:SetStartPoint("TOPLEFT", v243.relative, v244, v245);
			FlatIdent_92C49 = 88 - (68 + 18);
		end
		if (FlatIdent_92C49 == (673 - (619 + 54))) then
			if (not v244 or not v245 or not v246 or not v247) then
				return;
			end
			v244, v245, v246, v247 = v8(v244), v8(v245), v8(v246), v8(v247);
			if ((v244 == (725 - (60 + 665))) or (v245 == (0 + 0)) or (v246 == (513 - (174 + 339))) or (v247 == (0 + 0))) then
				return;
			end
			v248 = v20(v243.lines) or false;
			FlatIdent_92C49 = 663 - (485 + 177);
		end
		if ((9 - 7) == FlatIdent_92C49) then
			v248:SetEndPoint("TOPLEFT", v243.relative, v246, v247);
			v248:Show();
			v19(v243.lines_used, v248);
			break;
		end
	end
end;
local v61 = v5(1049 - 689);
local v62 = v5(507 - (149 + 349));
local v63 = v5(77 - 53);
v42.Circle = function(v249, v250, v251, v252, v253, v254)
	local FlatIdent_686FC = 0 - 0;
	local v255;
	local v256;
	local v257;
	local v258;
	while true do
		if ((1530 - (651 + 879)) == FlatIdent_686FC) then
			if not v250 then
				return;
			end
			v254 = (v254 and v254) or v62;
			FlatIdent_686FC = 1049 - (739 + 309);
		end
		if (FlatIdent_686FC == (1 - 0)) then
			v255, v256, v257, v258 = false, false, false, false;
			for v620 = 0 - 0, v61, v254 do
				local FlatIdent_A70F = 0 - 0;
				while true do
					if (FlatIdent_A70F == (1661 - (1425 + 235))) then
						v255, v256 = v257, v258;
						break;
					end
					if (FlatIdent_A70F == (1932 - (55 + 1877))) then
						v257, v258 = v250 + (v7(v620) * v253), v251 + (v6(v620) * v253);
						v249:Line(v255, v256, v252, v257, v258, v252);
						FlatIdent_A70F = 1571 - (1190 + 380);
					end
				end
			end
			break;
		end
	end
end;
v42.Arc = function(v259, v260, v261, v262, v263, v264, v265)
	local FlatIdent_1671A = 0 + 0;
	local v266;
	local v267;
	local v268;
	local v269;
	local v270;
	local v271;
	local v272;
	local v273;
	local v274;
	local v275;
	local v276;
	local v277;
	local v278;
	while true do
		if (FlatIdent_1671A == (1 - 0)) then
			v273 = v264 / v272;
			v274, v275 = -v272, v272;
			FlatIdent_1671A = 2 + 0;
		end
		if (FlatIdent_1671A == (5 - 3)) then
			v276 = nil;
			for v621 = v274, v275, v273 do
				if v621 then
					local FlatIdent_8A884 = 528 - (507 + 21);
					while true do
						if ((933 - (474 + 458)) == FlatIdent_8A884) then
							v266, v267 = v268, v269;
							break;
						end
						if (FlatIdent_8A884 == (0 - 0)) then
							v268, v269 = v259:WorldToScreen(v260 + (v7(v265 + v5(v621)) * v263), v261 + (v6(v265 + v5(v621)) * v263), v262);
							if (v266 and v267 and v268 and v269) then
								v259:Line2D(v266, v267, v268, v269);
							else
								v270, v271 = v268, v269;
							end
							FlatIdent_8A884 = 280 - (33 + 246);
						end
					end
				end
			end
			FlatIdent_1671A = 919 - (871 + 45);
		end
		if ((13 - 10) == FlatIdent_1671A) then
			v277, v278 = v259:WorldToScreen(v260, v261, v262);
			if (v266 and v267 and v270 and v271) then
				local FlatIdent_70345 = 0 - 0;
				while true do
					if (FlatIdent_70345 == (290 - (117 + 173))) then
						v259:Line2D(v277, v278, v266, v267);
						v259:Line2D(v277, v278, v270, v271);
						break;
					end
				end
			end
			break;
		end
		if (FlatIdent_1671A == (0 + 0)) then
			v266, v267, v268, v269, v270, v271 = false, false, false, false, false, false;
			v272 = v264 * (0.5 + 0);
			FlatIdent_1671A = 958 - (213 + 744);
		end
	end
end;
v42.FilledArc = function(v279, v280, v281, v282, v283, v284, v285)
	local FlatIdent_5BDDE = 0 - 0;
	local v286;
	local v287;
	local v288;
	local v289;
	local v290;
	local v291;
	local v292;
	local v293;
	local v294;
	local v295;
	local v296;
	local v297;
	while true do
		if (FlatIdent_5BDDE == (2 + 1)) then
			for v622 = v295, v296, v294 do
				local FlatIdent_6127C = 1474 - (1082 + 392);
				while true do
					if (FlatIdent_6127C == (734 - (449 + 285))) then
						v289, v290 = v280 + (v7(v285 + v5(v622)) * v283), v281 + (v6(v285 + v5(v622)) * v283);
						v19(v286, v34(v289 - v280, v290 - v281));
						break;
					end
				end
			end
			v297 = v33(v286);
			FlatIdent_5BDDE = 78 - (42 + 32);
		end
		if (FlatIdent_5BDDE == (1 + 1)) then
			v294 = v293 / (1936 - (12 + 1920));
			v295, v296 = -v293, v293;
			FlatIdent_5BDDE = 5 - 2;
		end
		if (FlatIdent_5BDDE == (655 - (76 + 575))) then
			for v623, v624 in v18(v297) do
				local FlatIdent_3894F = 536 - (306 + 230);
				while true do
					if ((0 + 0) == FlatIdent_3894F) then
						v40['v1']['x'] = v624['p1']['x'];
						v40['v1']['y'] = v624['p1']['y'];
						FlatIdent_3894F = 1 + 0;
					end
					if (FlatIdent_3894F == (1 + 0)) then
						v40['v1']['z'] = 1469 - (436 + 1033);
						v40['v2']['x'] = v624['p2']['x'];
						FlatIdent_3894F = 3 - 1;
					end
					if (FlatIdent_3894F == (785 - (393 + 390))) then
						v40['v2']['y'] = v624['p2']['y'];
						v40['v2']['z'] = 0 - 0;
						FlatIdent_3894F = 7 - 4;
					end
					if (FlatIdent_3894F == (1048 - (644 + 401))) then
						v40['v3']['x'] = v624['p3']['x'];
						v40['v3']['y'] = v624['p3']['y'];
						FlatIdent_3894F = 10 - 6;
					end
					if (FlatIdent_3894F == (951 - (159 + 788))) then
						v40['v3']['z'] = 0 - 0;
						v279:Triangle(v280, v281, v282, v40.v1, v40.v2, v40.v3, false, false);
						break;
					end
				end
			end
			break;
		end
		if (FlatIdent_5BDDE == (0 + 0)) then
			v286 = {};
			v19(v286, v34(0 + 0, 0 - 0));
			FlatIdent_5BDDE = 1641 - (1345 + 295);
		end
		if ((1 + 0) == FlatIdent_5BDDE) then
			v287, v288, v289, v290, v291, v292 = false, false, false, false, false, false;
			v293 = v284 * (0.5 - 0);
			FlatIdent_5BDDE = 5 - 3;
		end
	end
end;
v42.Rectangle = function(v298, v299, v300, v301, v302, v303, v304)
	local FlatIdent_5FC9A = 0 - 0;
	local v305;
	local v306;
	local v307;
	local v308;
	local v309;
	local v310;
	local v311;
	local v312;
	local v313;
	local v314;
	local v315;
	local v316;
	local v317;
	local v318;
	local v319;
	local v320;
	while true do
		if (FlatIdent_5FC9A == (949 - (527 + 419))) then
			v298:Line(v315, v316, v301, v318, v319, v301);
			v298:Line(v318, v319, v301, v312, v313, v301);
			v298:Line(v312, v313, v301, v309, v310, v301);
			break;
		end
		if (FlatIdent_5FC9A == (0 + 0)) then
			v305 = {x=(v299 - v302),y=(v300 + v303)};
			v306 = {x=(v299 + v302),y=(v300 + v303)};
			v307 = {x=(v299 - v302),y=(v300 - v303)};
			FlatIdent_5FC9A = 1 + 0;
		end
		if ((1 + 1) == FlatIdent_5FC9A) then
			v315, v316, v317 = ((v2.cos(v304) * (v306['x'] - v299)) - (v2.sin(v304) * (v306['y'] - v300))) + v299, (v2.sin(v304) * (v306['x'] - v299)) + (v2.cos(v304) * (v306['y'] - v300)) + v300, v301;
			v318, v319, v320 = ((v2.cos(v304) * (v308['x'] - v299)) - (v2.sin(v304) * (v308['y'] - v300))) + v299, (v2.sin(v304) * (v308['x'] - v299)) + (v2.cos(v304) * (v308['y'] - v300)) + v300, v301;
			v298:Line(v309, v310, v301, v315, v316, v301);
			FlatIdent_5FC9A = 4 - 1;
		end
		if (FlatIdent_5FC9A == (1 - 0)) then
			v308 = {x=(v299 + v302),y=(v300 - v303)};
			v309, v310, v311 = ((v2.cos(v304) * (v305['x'] - v299)) - (v2.sin(v304) * (v305['y'] - v300))) + v299, (v2.sin(v304) * (v305['x'] - v299)) + (v2.cos(v304) * (v305['y'] - v300)) + v300, v301;
			v312, v313, v314 = ((v2.cos(v304) * (v307['x'] - v299)) - (v2.sin(v304) * (v307['y'] - v300))) + v299, (v2.sin(v304) * (v307['x'] - v299)) + (v2.cos(v304) * (v307['y'] - v300)) + v300, v301;
			FlatIdent_5FC9A = 1 + 1;
		end
	end
end;
v42.Cylinder = function(v321, v322, v323, v324, v325, v326)
	local FlatIdent_7419F = 0 - 0;
	local v327;
	local v328;
	local v329;
	local v330;
	while true do
		if ((0 + 0) == FlatIdent_7419F) then
			v327, v328, v329, v330 = false, false, false, false;
			for v640 = 0 + 0, v61, v63 do
				local FlatIdent_356F0 = 1530 - (1164 + 366);
				while true do
					if ((2 - 0) == FlatIdent_356F0) then
						v327, v328 = v329, v330;
						break;
					end
					if (FlatIdent_356F0 == (2 - 1)) then
						v321:Line(v327, v328, v324, v327, v328, v324 + v326);
						v321:Line(v327, v328, v324 + v326, v329, v330, v324 + v326);
						FlatIdent_356F0 = 764 - (757 + 5);
					end
					if (FlatIdent_356F0 == (1747 - (1739 + 8))) then
						v329, v330 = v322 + (v7(v640) * v325), v323 + (v6(v640) * v325);
						v321:Line(v327, v328, v324, v329, v330, v324);
						FlatIdent_356F0 = 372 - (226 + 145);
					end
				end
			end
			break;
		end
	end
end;
v42.Array = function(v331, v332, v333, v334, v335, v336, v337, v338)
	for v641, v642 in v18(v332) do
		local FlatIdent_58777 = 555 - (90 + 465);
		local v643;
		local v644;
		local v645;
		local v646;
		local v647;
		local v648;
		while true do
			if (FlatIdent_58777 == (957 - (456 + 499))) then
				if v338 then
					local FlatIdent_60F94 = 0 + 0;
					while true do
						if (FlatIdent_60F94 == (0 + 0)) then
							v643, v644, v645 = v331:RotateZ(v333, v334, v335, v643, v644, v645, v338);
							v646, v647, v648 = v331:RotateZ(v333, v334, v335, v646, v647, v648, v338);
							break;
						end
					end
				end
				v331:Line(v643, v644, v645, v646, v647, v648);
				break;
			end
			if (FlatIdent_58777 == (0 - 0)) then
				v643, v644, v645 = v333 + v642[1 - 0], v334 + v642[9 - 7], v335 + v642[3 + 0];
				v646, v647, v648 = v333 + v642[14 - 10], v334 + v642[1776 - (1175 + 596)], v335 + v642[5 + 1];
				FlatIdent_58777 = 2 - 1;
			end
			if (FlatIdent_58777 == (1 + 0)) then
				if v336 then
					local FlatIdent_57EDF = 0 - 0;
					while true do
						if (FlatIdent_57EDF == (0 - 0)) then
							v643, v644, v645 = v331:RotateX(v333, v334, v335, v643, v644, v645, v336);
							v646, v647, v648 = v331:RotateX(v333, v334, v335, v646, v647, v648, v336);
							break;
						end
					end
				end
				if v337 then
					local FlatIdent_25C5F = 0 - 0;
					while true do
						if (FlatIdent_25C5F == (0 - 0)) then
							v643, v644, v645 = v331:RotateY(v333, v334, v335, v643, v644, v645, v337);
							v646, v647, v648 = v331:RotateY(v333, v334, v335, v646, v647, v648, v337);
							break;
						end
					end
				end
				FlatIdent_58777 = 1347 - (24 + 1321);
			end
		end
	end
end;
v42.Text = function(v339, v340, v341, v342, v343, v344)
	local FlatIdent_8A37E = 194 - (15 + 179);
	local v345;
	local v346;
	while true do
		if (FlatIdent_8A37E == (0 + 0)) then
			v345, v346 = v339:WorldToScreen(v342, v343, v344);
			if (v345 and v346) then
				local FlatIdent_14C1 = 0 + 0;
				local v746;
				while true do
					if (FlatIdent_14C1 == (1 + 1)) then
						v746:SetText(v340);
						v746:SetTextColor(v339['color'][1 - 0], v339['color'][1631 - (1554 + 75)], v339['color'][1197 - (632 + 562)], v339['color'][11 - 7]);
						FlatIdent_14C1 = 10 - 7;
					end
					if (FlatIdent_14C1 == (5 - 2)) then
						v746:SetPoint("TOPLEFT", v339.relative, "TOPLEFT", v345 - (v746:GetStringWidth() * (255.5 - (152 + 103))), v346);
						v746:Show();
						FlatIdent_14C1 = 291 - (245 + 42);
					end
					if (FlatIdent_14C1 == (9 - 5)) then
						v19(v339.strings_used, v746);
						break;
					end
					if (FlatIdent_14C1 == (1 + 0)) then
						v341 = v35;
						v746:SetFontObject(v341);
						FlatIdent_14C1 = 2 - 0;
					end
					if (FlatIdent_14C1 == (0 - 0)) then
						if ((v345 == (0 - 0)) or (v346 == (0 + 0))) then
							return;
						end
						v746 = v20(v339.strings) or v339['canvas']:CreateFontString(nil, "BACKGROUND");
						FlatIdent_14C1 = 1 + 0;
					end
				end
			end
			break;
		end
	end
end;
v42.Triangle = function(v347, v348, v349, v350, v351, v352, v353, v354, v355, v356)
	local FlatIdent_26563 = 0 + 0;
	local v357;
	local v358;
	local v359;
	local v360;
	local v361;
	local v362;
	while true do
		if (FlatIdent_26563 == (0 + 0)) then
			if (not v351 or not v352 or not v353) then
				return;
			end
			if (v354 == nil) then
				v354 = true;
			end
			FlatIdent_26563 = 2 - 1;
		end
		if ((1 + 1) == FlatIdent_26563) then
			v359, v360 = v347:WorldToScreen(v348 + v352['x'], v349 + v352['y'], v350 + v352['z']);
			v361, v362 = v347:WorldToScreen(v348 + v353['x'], v349 + v353['y'], v350 + v353['z']);
			FlatIdent_26563 = 5 - 2;
		end
		if ((1 + 0) == FlatIdent_26563) then
			if (v355 == nil) then
				v355 = false;
			end
			v357, v358 = v347:WorldToScreen(v348 + v351['x'], v349 + v351['y'], v350 + v351['z']);
			FlatIdent_26563 = 2 - 0;
		end
		if (FlatIdent_26563 == (1 + 2)) then
			if (not v357 or not v358 or not v359 or not v360 or not v361 or not v362) then
				return;
			end
			if v354 then
				local FlatIdent_90521 = 0 - 0;
				local v747;
				local v748;
				local v749;
				local v750;
				local v751;
				while true do
					if (FlatIdent_90521 == (2 + 0)) then
						v751 = (v747 * v750) - (v748 * v749);
						if (v751 > (1587 - (1202 + 385))) then
							local FlatIdent_59AF0 = 0 - 0;
							while true do
								if ((446 - (10 + 436)) == FlatIdent_59AF0) then
									v347:Triangle2D(v357, v358, v359, v360, v361, v362, v356);
									if v355 then
										local FlatIdent_87723 = 0 + 0;
										local v929;
										while true do
											if ((7 - 5) == FlatIdent_87723) then
												v347:Line2D(v361, v362, v357, v358);
												v347:SetColor(v929);
												break;
											end
											if (FlatIdent_87723 == (0 + 0)) then
												v929 = v347['color'];
												v347:SetColor(v347['colors'].green);
												FlatIdent_87723 = 1037 - (178 + 858);
											end
											if (FlatIdent_87723 == (1 - 0)) then
												v347:Line2D(v357, v358, v359, v360);
												v347:Line2D(v359, v360, v361, v362);
												FlatIdent_87723 = 1236 - (634 + 600);
											end
										end
									end
									break;
								end
							end
						end
						break;
					end
					if (FlatIdent_90521 == (2 - 1)) then
						v749 = v361 - v359;
						v750 = v362 - v360;
						FlatIdent_90521 = 6 - 4;
					end
					if (FlatIdent_90521 == (1466 - (886 + 580))) then
						v747 = v361 - v357;
						v748 = v362 - v358;
						FlatIdent_90521 = 1239 - (422 + 816);
					end
				end
			else
				local FlatIdent_18ACD = 0 - 0;
				while true do
					if (FlatIdent_18ACD == (0 + 0)) then
						v347:Triangle2D(v357, v358, v359, v360, v361, v362, v356);
						if v355 then
							local FlatIdent_89704 = 56 - (9 + 47);
							local v865;
							while true do
								if (FlatIdent_89704 == (0 + 0)) then
									v865 = v347['color'];
									v347:SetColor(v347['colors'].green);
									FlatIdent_89704 = 2 - 1;
								end
								if (FlatIdent_89704 == (1658 - (411 + 1246))) then
									v347:Line2D(v357, v358, v359, v360);
									v347:Line2D(v359, v360, v361, v362);
									FlatIdent_89704 = 2 + 0;
								end
								if (FlatIdent_89704 == (2 + 0)) then
									v347:Line2D(v361, v362, v357, v358);
									v347:SetColor(v865);
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
	end
end;
v42.TriangleAbsolut = function(v363, v364, v365, v366)
	local FlatIdent_1530B = 0 + 0;
	local v367;
	local v368;
	local v369;
	local v370;
	local v371;
	local v372;
	while true do
		if (FlatIdent_1530B == (1 + 0)) then
			v371, v372 = v363:WorldToScreen(v366.x, v366.y, v366.z);
			v363:Triangle2D(v367, v368, v369, v370, v371, v372);
			break;
		end
		if (FlatIdent_1530B == (0 - 0)) then
			v367, v368 = v363:WorldToScreen(v364.x, v364.y, v364.z);
			v369, v370 = v363:WorldToScreen(v365.x, v365.y, v365.z);
			FlatIdent_1530B = 1 + 0;
		end
	end
end;
local v73 = (1040 - 530) / (1560 - (934 + 114));
local v74 = (2 - 1) / (837 - (14 + 311));
v42.Triangle2D = function(v373, v374, v375, v376, v377, v378, v379, v380)
	local FlatIdent_76D4F = 146 - (143 + 3);
	local v381;
	local v382;
	local v383;
	local v384;
	local v385;
	local v386;
	local v387;
	local v388;
	local v389;
	local v390;
	local v391;
	local v392;
	local v393;
	while true do
		if (FlatIdent_76D4F == (24 - 18)) then
			v393:SetVertexColor(v373['color'][1597 - (901 + 695)], v373['color'][2 + 0], v373['color'][1973 - (171 + 1799)], v373['color'][4 + 0]);
			v393:Show();
			v19(v373.triangles_used, v393);
			break;
		end
		if (FlatIdent_76D4F == (1 + 4)) then
			if not v393 then
				local FlatIdent_C1D2 = 1980 - (969 + 1011);
				while true do
					if (FlatIdent_C1D2 == (0 - 0)) then
						v393 = v373['canvas']:CreateTexture("Tri" .. (#v373['triangles'] + 1 + 0), v380 or "BACKGROUND");
						v393:SetTexture("Textures\\triangle");
						break;
					end
				end
			else
				v393:SetDrawLayer(v380 or "BACKGROUND");
			end
			v393:SetPoint("BOTTOMLEFT", v373.relative, "TOPLEFT", v381, v382);
			v393:SetPoint("TOPRIGHT", v373.relative, "TOPLEFT", v383, v384);
			v393:SetTexCoord(v374, v376, v378, v379, v374 + v377, v376 + v375, v377 + v378, v375 + v379);
			FlatIdent_76D4F = 1705 - (1045 + 654);
		end
		if ((3 + 0) == FlatIdent_76D4F) then
			v374 = v74 - (v391 * v387 * v388);
			v376 = v74 + (v391 * v388);
			v378 = (v392 * v387) + v374;
			v375 = v391 * (v389 - v388);
			FlatIdent_76D4F = 3 + 1;
		end
		if (FlatIdent_76D4F == (0 - 0)) then
			if (not v374 or not v375 or not v376 or not v377 or not v378 or not v379) then
				return;
			end
			v381 = v9(v374, v376, v378);
			v382 = v9(v375, v377, v379);
			v383 = v10(v374, v376, v378);
			FlatIdent_76D4F = 636 - (368 + 267);
		end
		if (FlatIdent_76D4F == (498 - (399 + 95))) then
			v377 = v391 * (v388 - v390);
			v379 = -v392 + v376;
			if (v3(v392) >= (26616 - 17616)) then
				return;
			end
			v393 = v20(v373.triangles) or false;
			FlatIdent_76D4F = 3 + 2;
		end
		if ((1 + 0) == FlatIdent_76D4F) then
			v384 = v10(v375, v377, v379);
			v385 = v383 - v381;
			v386 = v384 - v382;
			if ((v385 == (0 - 0)) or (v386 == (0 + 0))) then
				return;
			end
			FlatIdent_76D4F = 2 + 0;
		end
		if (FlatIdent_76D4F == (418 - (394 + 22))) then
			v387, v388, v389, v390 = nil;
			if (v374 == v381) then
				if (v376 == v383) then
					v387, v388, v389, v390 = (v378 - v381) / v385, v384 - v375, v384 - v377, v384 - v379;
				else
					v387, v388, v389, v390 = (v376 - v381) / v385, v384 - v375, v384 - v379, v384 - v377;
				end
			elseif (v376 == v381) then
				if (v374 == v383) then
					v387, v388, v389, v390 = (v378 - v381) / v385, v384 - v377, v384 - v375, v384 - v379;
				else
					v387, v388, v389, v390 = (v374 - v381) / v385, v384 - v377, v384 - v379, v384 - v375;
				end
			elseif (v376 == v383) then
				v387, v388, v389, v390 = (v374 - v381) / v385, v384 - v379, v384 - v377, v384 - v375;
			else
				v387, v388, v389, v390 = (v376 - v381) / v385, v384 - v379, v384 - v375, v384 - v377;
			end
			v391 = -v73 / ((v390 - (v387 * v389)) + ((v387 - (2 - 1)) * v388));
			v392 = v386 * v391;
			FlatIdent_76D4F = 3 + 0;
		end
	end
end;
local v76 = {};
for v394 = 2 - 1, 12 - 7 do
	local FlatIdent_537A5 = 0 - 0;
	while true do
		if (FlatIdent_537A5 == (1097 - (446 + 651))) then
			v76[(v394 * (663 - (75 + 586))) - (1 + 0)] = -v7((((2 + 0) * v11) / (471 - (131 + 335))) * (v394 - (755 - (67 + 687))));
			v76[v394 * (1705 - (1207 + 496))] = v6((((500 - (147 + 351)) * v11) / (10 - 5)) * (v394 - (1267 - (137 + 1129))));
			break;
		end
	end
end
v42.FilledCircle = function(v397, v398, v399, v400, v401)
	if (v398 and v399 and v400 and v401) then
		local FlatIdent_96E5C = 0 - 0;
		local v752;
		local v753;
		local v754;
		local v755;
		local v756;
		local v757;
		local v758;
		local v759;
		local v760;
		local v761;
		local v762;
		local v763;
		local v764;
		local v765;
		local v766;
		local v767;
		local v770;
		local v773;
		local v776;
		local v779;
		while true do
			if (FlatIdent_96E5C == (1 + 1)) then
				v770['x'], v770['y'] = v397:WorldToScreen(v755, v756, v757);
				v773 = {};
				v773['x'], v773['y'] = v397:WorldToScreen(v758, v759, v760);
				v776 = {};
				FlatIdent_96E5C = 2 + 1;
			end
			if (FlatIdent_96E5C == (0 - 0)) then
				v752, v753, v754 = v398 - (v76[1 - 0] * v401), v399 - (v76[764 - (487 + 275)] * v401), v400;
				v755, v756, v757 = v398 - (v76[750 - (134 + 613)] * v401), v399 - (v76[7 - 3] * v401), v400;
				v758, v759, v760 = v398 - (v76[14 - 9] * v401), v399 - (v76[14 - 8] * v401), v400;
				v761, v762, v763 = v398 - (v76[1 + 6] * v401), v399 - (v76[17 - 9] * v401), v400;
				FlatIdent_96E5C = 1 - 0;
			end
			if (FlatIdent_96E5C == (3 + 0)) then
				v776['x'], v776['y'] = v397:WorldToScreen(v761, v762, v763);
				v779 = {};
				v779['x'], v779['y'] = v397:WorldToScreen(v764, v765, v766);
				if (v767['x'] and v767['y'] and v770['x'] and v770['y'] and v773['x'] and v773['y'] and v776['x'] and v776['y'] and v779['x'] and v779['y']) then
					v397:Draw3DTexture(v767, v770, v773, v776, v779, false, "Textures\\filledcircle");
				end
				break;
			end
			if (FlatIdent_96E5C == (1 + 0)) then
				v764, v765, v766 = v398 - (v76[1805 - (854 + 942)] * v401), v399 - (v76[840 - (494 + 336)] * v401), v400;
				v767 = {};
				v767['x'], v767['y'] = v397:WorldToScreen(v752, v753, v754);
				v770 = {};
				FlatIdent_96E5C = 7 - 5;
			end
		end
	end
end;
v42.FilledRectangle = function(v402, v403, v404, v405, v406, v407, v408, v409)
	local FlatIdent_6C6AF = 0 - 0;
	local v410;
	local v411;
	local v412;
	local v413;
	local v414;
	local v415;
	local v416;
	local v417;
	local v418;
	local v419;
	local v420;
	local v421;
	local v422;
	local v423;
	while true do
		if (FlatIdent_6C6AF == (499 - (368 + 131))) then
			v410, v411, v412, v413, v414, v415, v416, v417, v418, v419, v420, v421 = v38(v406, v407, v403, v404, v405, v409 or (0 - 0), v408);
			v422 = {v34(0 - 0, 0 - 0),v34(v410 - v403, v411 - v404),v34(v412 - v403, v413 - v404),v34(v414 - v403, v415 - v404),v34(v416 - v403, v417 - v404)};
			FlatIdent_6C6AF = 1 + 0;
		end
		if (FlatIdent_6C6AF == (1 - 0)) then
			v423 = v33(v422);
			for v649, v650 in v18(v423) do
				local FlatIdent_4EB6C = 0 - 0;
				while true do
					if (FlatIdent_4EB6C == (1 + 1)) then
						v40['v2']['y'] = v650['p2']['y'];
						v40['v2']['z'] = 0 + 0;
						FlatIdent_4EB6C = 555 - (500 + 52);
					end
					if (FlatIdent_4EB6C == (1588 - (1230 + 358))) then
						v40['v1']['x'] = v650['p1']['x'];
						v40['v1']['y'] = v650['p1']['y'];
						FlatIdent_4EB6C = 997 - (733 + 263);
					end
					if ((1577 - (429 + 1147)) == FlatIdent_4EB6C) then
						v40['v1']['z'] = 0 - 0;
						v40['v2']['x'] = v650['p2']['x'];
						FlatIdent_4EB6C = 2 + 0;
					end
					if (FlatIdent_4EB6C == (870 - (250 + 616))) then
						v40['v3']['z'] = 823 - (416 + 407);
						v402:Triangle(v403, v404, v405, v40.v1, v40.v2, v40.v3, false, false);
						break;
					end
					if (FlatIdent_4EB6C == (547 - (155 + 389))) then
						v40['v3']['x'] = v650['p3']['x'];
						v40['v3']['y'] = v650['p3']['y'];
						FlatIdent_4EB6C = 6 - 2;
					end
				end
			end
			break;
		end
	end
end;
v42.Outline = function(v424, v425, v426, v427, v428)
	if (v425 and v426 and v427 and v428) then
		local FlatIdent_3E0C1 = 0 - 0;
		local v782;
		local v783;
		local v784;
		local v785;
		local v786;
		local v787;
		local v788;
		local v789;
		local v790;
		local v791;
		local v792;
		local v793;
		local v794;
		local v795;
		local v796;
		local v797;
		local v800;
		local v803;
		local v806;
		local v809;
		while true do
			if (FlatIdent_3E0C1 == (8 - 4)) then
				v806['x'], v806['y'] = v424:WorldToScreen(v791, v792, v793);
				v809 = {};
				v809['x'], v809['y'] = v424:WorldToScreen(v794, v795, v796);
				FlatIdent_3E0C1 = 545 - (472 + 68);
			end
			if (FlatIdent_3E0C1 == (1 + 1)) then
				v797['x'], v797['y'] = v424:WorldToScreen(v782, v783, v784);
				v800 = {};
				v800['x'], v800['y'] = v424:WorldToScreen(v785, v786, v787);
				FlatIdent_3E0C1 = 3 + 0;
			end
			if (FlatIdent_3E0C1 == (0 + 0)) then
				v782, v783, v784 = v425 - (v76[2 - 1] * v428), v426 - (v76[326 - (40 + 284)] * v428), v427;
				v785, v786, v787 = v425 - (v76[13 - 10] * v428), v426 - (v76[3 + 1] * v428), v427;
				v788, v789, v790 = v425 - (v76[1504 - (573 + 926)] * v428), v426 - (v76[1807 - (1591 + 210)] * v428), v427;
				FlatIdent_3E0C1 = 1 + 0;
			end
			if (FlatIdent_3E0C1 == (7 - 4)) then
				v803 = {};
				v803['x'], v803['y'] = v424:WorldToScreen(v788, v789, v790);
				v806 = {};
				FlatIdent_3E0C1 = 10 - 6;
			end
			if (FlatIdent_3E0C1 == (1 + 4)) then
				if (v797['x'] and v797['y'] and v800['x'] and v800['y'] and v803['x'] and v803['y'] and v806['x'] and v806['y'] and v809['x'] and v809['y']) then
					v424:Draw3DTexture(v797, v800, v803, v806, v809, false, "Textures\\outline");
				end
				break;
			end
			if (FlatIdent_3E0C1 == (1366 - (1276 + 89))) then
				v791, v792, v793 = v425 - (v76[30 - 23] * v428), v426 - (v76[7 + 1] * v428), v427;
				v794, v795, v796 = v425 - (v76[1312 - (172 + 1131)] * v428), v426 - (v76[3 + 7] * v428), v427;
				v797 = {};
				FlatIdent_3E0C1 = 3 - 1;
			end
		end
	end
end;
local v80 = {};
v42.Draw3DTexture = function(v429, v430, v431, v432, v433, v434, v435, v436)
	local v437, v438, v439, v440, v441, v442, v443, v444, v445, v446 = v430['x'], v430['y'], v431['x'], v431['y'], v432['x'], v432['y'], v433['x'], v433['y'], v434['x'], v434['y'];
	local v447, v448, v449 = v438 - v440, v439 - v437, (v437 * v440) - (v438 * v439);
	local v450, v451, v452 = v440 - v442, v441 - v439, (v439 * v442) - (v440 * v441);
	local v453, v454, v455 = v442 - v444, v443 - v441, (v441 * v444) - (v442 * v443);
	local v456, v457, v458 = v444 - v446, v445 - v443, (v443 * v446) - (v444 * v445);
	local v459, v460, v461 = (v448 * v458) - (v449 * v457), (v449 * v456) - (v447 * v458), (v447 * v457) - (v448 * v456);
	local v462, v463, v464 = v459, v460, v461;
	local v465, v466, v467 = v450, v451, v452;
	local v468, v469, v470 = v453, v454, v455;
	local v471, v472, v473 = v437, v438, 1365 - (871 + 493);
	local v474, v475, v476 = v445, v446, 262 - (151 + 110);
	local v477 = v475 * v473;
	local v478 = v476 * v472;
	local v479 = v476 * v473;
	local v480 = v475 * v472;
	local v481 = v474 * v473;
	local v482 = v476 * v471;
	local v483 = v474 * v471;
	local v484 = v475 * v471;
	local v485 = v474 * v472;
	local v486 = v465 * v468;
	local v487 = v465 * v469;
	local v488 = v465 * v470;
	local v489 = v466 * v468;
	local v490 = v466 * v469;
	local v491 = v466 * v470;
	local v492 = v467 * v468;
	local v493 = v467 * v469;
	local v494 = v467 * v470;
	local v495, v496, v497, v498;
	local v499 = ((((((-v462 * v486 * v477) + (v462 * v486 * v478)) - (v463 * v489 * v477)) - (v463 * v492 * v479)) + (v463 * v487 * v478) + (v463 * v488 * v479) + (v464 * v489 * v480) + (v464 * v492 * v478)) - (v464 * v487 * v480)) - (v464 * v488 * v477);
	local v500 = ((((((((v462 * v493 * v479) + (v462 * v487 * v481)) - (v462 * v491 * v479)) - (v462 * v489 * v482)) + (v463 * v490 * v481)) - (v463 * v490 * v482)) + (v464 * v491 * v481) + (v464 * v489 * v483)) - (v464 * v493 * v482)) - (v464 * v487 * v483);
	local v501 = ((((((((v462 * v492 * v484) + (v462 * v493 * v480)) - (v462 * v488 * v485)) - (v462 * v491 * v480)) - (v463 * v492 * v483)) - (v463 * v493 * v485)) + (v463 * v488 * v483) + (v463 * v491 * v484)) - (v464 * v494 * v485)) + (v464 * v494 * v484);
	local v502 = ((((((((((((((v462 * v492 * v479) + (v462 * v486 * v481)) - (v462 * v487 * v477)) - (v462 * v488 * v479)) - (v462 * v486 * v482)) + (v462 * v489 * v478) + (v463 * v489 * v481)) - (v463 * v490 * v477)) - (v463 * v493 * v479)) - (v463 * v487 * v482)) + (v463 * v490 * v478) + (v463 * v491 * v479)) - (v464 * v491 * v477)) - (v464 * v489 * v485)) - (v464 * v489 * v484)) - (v464 * v492 * v482)) + (v464 * v493 * v478) + (v464 * v487 * v485) + (v464 * v487 * v484) + (v464 * v488 * v481);
	local v503 = (((((((((((((-v462 * v492 * v477) + (v462 * v486 * v484) + (v462 * v487 * v480) + (v462 * v488 * v478)) - (v462 * v486 * v485)) - (v462 * v489 * v480)) + (v463 * v489 * v484) + (v463 * v492 * v482) + (v463 * v492 * v481) + (v463 * v493 * v478)) - (v463 * v487 * v485)) - (v463 * v488 * v482)) - (v463 * v488 * v481)) - (v463 * v491 * v477)) + (v464 * v491 * v480) + (v464 * v494 * v478)) - (v464 * v492 * v485)) - (v464 * v493 * v480)) - (v464 * v494 * v477)) + (v464 * v488 * v484);
	local v504 = ((((((((((((-v462 * v492 * v482) - (v462 * v493 * v477)) - (v462 * v493 * v478)) - (v462 * v487 * v485)) + (v462 * v488 * v481) + (v462 * v491 * v477) + (v462 * v491 * v478) + (v462 * v489 * v484)) - (v463 * v489 * v483)) - (v463 * v490 * v485)) + (v463 * v493 * v481) + (v463 * v487 * v483) + (v463 * v490 * v484)) - (v463 * v491 * v482)) - (v464 * v491 * v485)) + (v464 * v494 * v481) + (v464 * v492 * v483) + (v464 * v493 * v484)) - (v464 * v494 * v482)) - (v464 * v488 * v483);
	if (v499 ~= (974 - (682 + 292))) then
		local FlatIdent_3C665 = 0 + 0;
		while true do
			if (FlatIdent_3C665 == (0 - 0)) then
				v502 = v502 / v499;
				v500 = v500 / v499;
				FlatIdent_3C665 = 1 + 0;
			end
			if (FlatIdent_3C665 == (3 - 2)) then
				v503 = v503 / v499;
				v504 = v504 / v499;
				FlatIdent_3C665 = 2 + 0;
			end
			if (FlatIdent_3C665 == (1313 - (182 + 1129))) then
				v501 = v501 / v499;
				v499 = 1499 - (1036 + 462);
				break;
			end
		end
	elseif (v502 ~= (1588 - (213 + 1375))) then
		local FlatIdent_756FA = 575 - (398 + 177);
		while true do
			if ((0 - 0) == FlatIdent_756FA) then
				v500 = v500 / v502;
				v503 = v503 / v502;
				FlatIdent_756FA = 1 + 0;
			end
			if (FlatIdent_756FA == (2 + 0)) then
				v502 = 1 + 0;
				break;
			end
			if ((1246 - (590 + 655)) == FlatIdent_756FA) then
				v504 = v504 / v502;
				v501 = v501 / v502;
				FlatIdent_756FA = 2 - 0;
			end
		end
	elseif (v500 ~= (1333 - (451 + 882))) then
		local FlatIdent_7BD3B = 0 + 0;
		while true do
			if ((0 + 0) == FlatIdent_7BD3B) then
				v503 = v503 / v500;
				v504 = v504 / v500;
				FlatIdent_7BD3B = 3 - 2;
			end
			if ((1 + 0) == FlatIdent_7BD3B) then
				v501 = v501 / v500;
				v500 = 1668 - (700 + 967);
				break;
			end
		end
	elseif (v503 ~= (0 + 0)) then
		local FlatIdent_46348 = 1617 - (470 + 1147);
		while true do
			if (FlatIdent_46348 == (1064 - (338 + 725))) then
				v503 = 1 + 0;
				break;
			end
			if (FlatIdent_46348 == (0 - 0)) then
				v504 = v504 / v503;
				v501 = v501 / v503;
				FlatIdent_46348 = 2 - 1;
			end
		end
	elseif (v504 ~= (0 - 0)) then
		local FlatIdent_6FE66 = 0 + 0;
		while true do
			if ((0 + 0) == FlatIdent_6FE66) then
				v501 = v501 / v504;
				v504 = 2 - 1;
				break;
			end
		end
	else
		return;
	end
	v502 = v502 / (2 + 0);
	v503 = v503 / (2 + 0);
	v504 = v504 / (3 - 1);
	v495 = (v502 * v502) - (v499 * v500);
	local v471 = ((v500 * v503) - (v502 * v504)) / v495;
	local v472 = ((v499 * v504) - (v502 * v503)) / v495;
	v496 = (2 - 0) * ((((v499 * v504 * v504) + (v500 * v503 * v503) + (v501 * v502 * v502)) - ((989 - (347 + 640)) * v502 * v503 * v504)) - (v499 * v500 * v501));
	v497 = v4(((v499 - v500) * (v499 - v500)) + ((957 - (766 + 187)) * v502 * v502));
	local v505 = v4(v496 / (v495 * (v497 - (v499 + v500))));
	local v506 = v4(v496 / (v495 * (-v497 - (v499 + v500))));
	local v507;
	if (v502 == (0 + 0)) then
		if (v499 < v500) then
			v507 = 0 + 0;
		else
			v507 = (678.5 - (321 + 357)) * v11;
		end
	elseif (v499 < v500) then
		if (v502 < (1381 - (180 + 1201))) then
			v507 = (0.5 + 0) * (((195.5 - (125 + 70)) * v11) - v13((v499 - v500) / ((2 - 0) * v502)));
		else
			v507 = (1329.5 - (214 + 1115)) * ((-(0.5 + 0) * v11) - v13((v499 - v500) / ((9 - 7) * v502)));
		end
	elseif (v502 < (135 - (86 + 49))) then
		v507 = (190.5 - (23 + 167)) * ((v11 - ((0.5 - 0) * v11)) - v13((v499 - v500) / ((4 - 2) * v502)));
	else
		v507 = (0.5 - 0) * ((v11 + ((0.5 - 0) * v11)) - v13((v499 - v500) / ((903 - (100 + 801)) * v502)));
	end
	local v508 = v20(v429.textures) or false;
	if not v508 then
		local FlatIdent_2EDF9 = 288 - (112 + 176);
		while true do
			if (FlatIdent_2EDF9 == (0 - 0)) then
				v508 = v429['canvas']:CreateTexture(nil, "BACKGROUND");
				v508:SetDrawLayer("BACKGROUND");
				break;
			end
		end
	end
	v508:Hide();
	local v509 = v10(v505, v506);
	v505 = v505 * (5 - 3);
	v506 = v506 * (2 + 0);
	v508:SetPoint("TOPLEFT", v429.canvas, "TOPLEFT", v471 - v509, v472 + v509);
	v508:SetPoint("BOTTOMRIGHT", v429.canvas, "TOPLEFT", v471 + v509, v472 - v509);
	v508:SetTexture(v436);
	v508:SetBlendMode("ADD");
	local v510 = v7(-v507);
	local v511 = v6(-v507);
	v509 = v509 * (2 + 0);
	v505 = v505 / v509;
	v506 = v506 / v509;
	if v435 then
		local FlatIdent_794B2 = 479 - (78 + 401);
		local v812;
		local v813;
		local v814;
		local v815;
		local v816;
		local v817;
		local v818;
		while true do
			if (FlatIdent_794B2 == (0 + 0)) then
				v812 = (v437 - v471) / v509;
				v813 = (v438 - v472) / v509;
				v495 = v4(((v510 * v510 * v505 * v505) + (v511 * v511 * v506 * v506)) - ((6 - 2) * v812 * v812));
				FlatIdent_794B2 = 1 + 0;
			end
			if (FlatIdent_794B2 == (2 + 0)) then
				v816 = (((1092 - (32 + 1058)) * v13(((-v511 * v505) + v496) / ((v510 * v506) - ((5 - 3) * v813)))) + v11) % v12;
				if (v3(v814 - v815) < (1E-07 - 0)) then
				elseif (v3(v814 - v816) < (1E-07 + 0)) then
				else
					v814 = ((384 - (207 + 175)) * v13(((v510 * v505) + v495) / ((v511 * v506) + ((2 + 0) * v812)))) % v12;
				end
				v817 = v7(v814);
				FlatIdent_794B2 = 10 - 7;
			end
			if (FlatIdent_794B2 == (1898 - (1111 + 784))) then
				v818 = v6(v814);
				v495 = (v510 * v817 * v505) - (v511 * v818 * v506);
				v496 = (-v817 * v511 * v506) - (v510 * v818 * v505);
				FlatIdent_794B2 = 327 - (188 + 135);
			end
			if (FlatIdent_794B2 == (424 - (140 + 280))) then
				v497 = (v510 * v818 * v506) + (v817 * v511 * v505);
				v498 = (v510 * v817 * v506) - (v511 * v818 * v505);
				break;
			end
			if (FlatIdent_794B2 == (2 - 1)) then
				v496 = v4(((v510 * v510 * v506 * v506) + (v511 * v511 * v505 * v505)) - ((278 - (217 + 57)) * v813 * v813));
				v814 = ((1890 - (1329 + 559)) * v13(((v510 * v505) - v495) / ((v511 * v506) + ((1368 - (915 + 451)) * v812)))) % v12;
				v815 = (((578 - (496 + 80)) * v13(((-v511 * v505) - v496) / ((v510 * v506) - ((6 - 4) * v813)))) + v11) % v12;
				FlatIdent_794B2 = 493 - (67 + 424);
			end
		end
	else
		local FlatIdent_9456F = 0 + 0;
		while true do
			if (FlatIdent_9456F == (0 + 0)) then
				v495 = v510 * v505;
				v496 = -v511 * v506;
				FlatIdent_9456F = 1718 - (33 + 1684);
			end
			if (FlatIdent_9456F == (1 + 0)) then
				v497 = v511 * v505;
				v498 = v510 * v506;
				break;
			end
		end
	end
	local v512 = v505 * v506 * (484 - (472 + 10));
	if ((v512 < (0.0003 - 0)) or (v512 ~= v512)) then
		local FlatIdent_40145 = 0 + 0;
		while true do
			if ((1527 - (1225 + 302)) == FlatIdent_40145) then
				v508:Hide();
				v19(v429.textures_used, v508);
				FlatIdent_40145 = 1 + 0;
			end
			if (FlatIdent_40145 == (1 + 0)) then
				return;
			end
		end
	end
	v508:SetTexCoord((932.5 - (281 + 651)) + ((v496 - v498) / v512), (1488.5 - (580 + 908)) + ((-v495 + v497) / v512), (1393.5 - (693 + 700)) + ((-v496 - v498) / v512), (371.5 - (226 + 145)) + ((v495 + v497) / v512), (1089.5 - (501 + 588)) + ((v498 + v496) / v512), (0.5 - 0) + ((-v497 - v495) / v512), 0.5 + 0 + ((v498 - v496) / v512), 0.5 + 0 + ((-v497 + v495) / v512));
	local v499 = v429['color'][4 + 0];
	if (v499 < (510 - (477 + 33))) then
		v499 = 0 + 0;
	elseif (v499 > (629 - (575 + 53))) then
		v499 = 1 + 0;
	end
	v508:SetVertexColor(v429['color'][1 + 0], v429['color'][114 - (103 + 9)], v429['color'][7 - 4], v499);
	v508:Show();
	v19(v429.textures_used, v508);
	return v508;
end;
v42.Texture = function(v513, v514, v515, v516, v517, v518)
	local FlatIdent_29B9A = 1166 - (410 + 756);
	local v519;
	local v520;
	local v521;
	local v522;
	local v523;
	local v524;
	local v525;
	local v526;
	local v527;
	local v528;
	local v529;
	local v530;
	local v531;
	local v532;
	local v533;
	local v534;
	while true do
		if (FlatIdent_29B9A == (1342 - (1119 + 219))) then
			v532, v533 = v528 + v530, v529 - v531;
			v534 = v20(v513.textures) or false;
			if not v534 then
				local FlatIdent_4DCFE = 0 + 0;
				while true do
					if (FlatIdent_4DCFE == (0 - 0)) then
						v534 = v513['canvas']:CreateTexture(nil, "BACKGROUND");
						v534:SetDrawLayer("BACKGROUND");
						break;
					end
				end
			end
			FlatIdent_29B9A = 1 + 4;
		end
		if (FlatIdent_29B9A == (0 - 0)) then
			v519, v520, v521 = v514['texture'], v514['width'], v514['height'];
			v522, v523, v524, v525, v526 = v514['left'], v514['right'], v514['top'], v514['bottom'], v514['scale'];
			v527 = v514['alpha'] or v518 or (345 - (7 + 337));
			FlatIdent_29B9A = 3 - 2;
		end
		if (FlatIdent_29B9A == (432 - (79 + 346))) then
			v534:SetPoint("TOPLEFT", v513.relative, "TOPLEFT", v528, v529);
			v534:SetPoint("BOTTOMRIGHT", v513.relative, "TOPLEFT", v532, v533);
			v534:SetVertexColor(1 + 0, 1 + 0, 718 - (124 + 593), 1 + 0);
			FlatIdent_29B9A = 551 - (350 + 193);
		end
		if (FlatIdent_29B9A == (2 - 1)) then
			if (not v519 or not v520 or not v521 or not v515 or not v516 or not v517) then
				return;
			end
			if (not v522 or not v523 or not v524 or not v525) then
				local FlatIdent_754E5 = 0 - 0;
				while true do
					if (FlatIdent_754E5 == (674 - (529 + 145))) then
						v522 = 0 + 0;
						v523 = 1434 - (551 + 882);
						FlatIdent_754E5 = 2 - 1;
					end
					if (FlatIdent_754E5 == (1 + 0)) then
						v524 = 0 + 0;
						v525 = 1 + 0;
						break;
					end
				end
			end
			if not v526 then
				local FlatIdent_70C50 = 0 + 0;
				local v819;
				local v820;
				local v821;
				while true do
					if ((0 - 0) == FlatIdent_70C50) then
						v819, v820, v821 = v513:CameraPosition();
						v526 = v520 / v513:Distance(v515, v516, v517, v819, v820, v821);
						break;
					end
				end
			end
			FlatIdent_29B9A = 1150 - (337 + 811);
		end
		if (FlatIdent_29B9A == (16 - 11)) then
			v534:ClearAllPoints();
			v534:SetTexture(v519);
			v534:SetTexCoord(v522, v523, v524, v525);
			FlatIdent_29B9A = 6 + 0;
		end
		if (FlatIdent_29B9A == (1 + 5)) then
			v534:SetWidth(v520);
			v534:SetHeight(v521);
			if ((v528 == v532) and (v529 == v533)) then
				local FlatIdent_15E9C = 1339 - (1101 + 238);
				while true do
					if (FlatIdent_15E9C == (0 - 0)) then
						v534:SetPoint("TOPLEFT", v513.relative, "TOPLEFT", v528, v529);
						v534:SetPoint("BOTTOMRIGHT", v513.relative, "TOPLEFT", v532 + (2 - 1), v533 - (1211 - (574 + 636)));
						break;
					end
				end
			end
			FlatIdent_29B9A = 576 - (254 + 315);
		end
		if (FlatIdent_29B9A == (8 - 6)) then
			v528, v529 = v513:WorldToScreen(v515, v516, v517);
			if (not v528 or not v529) then
				return;
			end
			v530 = v520 * v526;
			FlatIdent_29B9A = 1754 - (1011 + 740);
		end
		if (FlatIdent_29B9A == (2 + 6)) then
			v534:SetAlpha(v527);
			v534:Show();
			v19(v513.textures_used, v534);
			break;
		end
		if (FlatIdent_29B9A == (8 - 5)) then
			v531 = v521 * v526;
			v528 = v528 - (v530 * (1107.5 - (289 + 818)));
			v529 = v529 + (v531 * (1144.5 - (768 + 376)));
			FlatIdent_29B9A = 8 - 4;
		end
	end
end;
v42.ClearCanvas = function(v535)
	local FlatIdent_17A80 = 0 - 0;
	while true do
		if (FlatIdent_17A80 == (1 + 0)) then
			for v668 = #v535['textures_used'], 2 - 1, -(1237 - (87 + 1149)) do
				local FlatIdent_8A807 = 257 - (191 + 66);
				while true do
					if (FlatIdent_8A807 == (1 - 0)) then
						v535['textures_used'][v668]:SetTexCoord(0 - 0, 1 - 0, 0 - 0, 1 + 0);
						v19(v535.textures, v20(v535.textures_used));
						break;
					end
					if (FlatIdent_8A807 == (499 - (133 + 366))) then
						v535['textures_used'][v668]:Hide();
						v535['textures_used'][v668]:SetTexture("");
						FlatIdent_8A807 = 1 - 0;
					end
				end
			end
			for v669 = #v535['triangles_used'], 1730 - (910 + 819), -(1 + 0) do
				local FlatIdent_745B5 = 0 + 0;
				while true do
					if (FlatIdent_745B5 == (1663 - (1460 + 203))) then
						v535['triangles_used'][v669]:Hide();
						v19(v535.triangles, v20(v535.triangles_used));
						break;
					end
				end
			end
			break;
		end
		if (FlatIdent_17A80 == (0 + 0)) then
			for v666 = #v535['lines_used'], 3 - 2, -(3 - 2) do
				local FlatIdent_81B2C = 0 + 0;
				while true do
					if (FlatIdent_81B2C == (0 + 0)) then
						v535['lines_used'][v666]:Hide();
						v19(v535.lines, v20(v535.lines_used));
						break;
					end
				end
			end
			for v667 = #v535['strings_used'], 1 + 0, -(1 + 0) do
				local FlatIdent_178C3 = 0 - 0;
				while true do
					if (FlatIdent_178C3 == (0 + 0)) then
						v535['strings_used'][v667]:Hide();
						v19(v535.strings, v20(v535.strings_used));
						break;
					end
				end
			end
			FlatIdent_17A80 = 1 + 0;
		end
	end
end;
v42.Update = function(v536)
	local FlatIdent_2EDF6 = 1058 - (366 + 692);
	while true do
		if ((0 + 0) == FlatIdent_2EDF6) then
			v536:ClearCanvas();
			for v670, v671 in v18(v536.callbacks) do
				v671(v536);
			end
			break;
		end
	end
end;
local v85 = v5(198 - (98 + 55));
local v86 = {{(0 + 0),(1006 - (135 + 871)),(0 - 0),(1978.5 - (562 + 1415)),(491 - (240 + 251)),(801 - (790 + 11))},{(1383.5 - (1073 + 309)),(0 + 0),(0 - 0),(1.2 + 0),(951.2 - (366 + 585)),-(0.2 - 0)},{(147.5 - (9 + 137)),(971 - (731 + 240)),(129 - (28 + 101)),(1005.2 - (502 + 502)),-(0.2 - 0),(0.2 + 0)}};
local v87 = {{(0 - 0),(0 - 0),(0 + 0),(0 + 0),(1414.5 - (314 + 1099)),(1403 - (357 + 1046))},{(0 - 0),(1.5 - 0),(0 - 0),(0.2 + 0),(1233.2 - (796 + 436)),-(0.2 - 0)},{(0 - 0),(1.5 + 0),(1679 - (402 + 1277)),-(607.2 - (501 + 106)),(1.2 + 0),(0.2 - 0)}};
local v88 = {{(0 + 0),(0 - 0),(0 + 0),(0 - 0),(0 - 0),(1.5 + 0)},{(0 + 0),(101 - (71 + 30)),(1.5 + 0),(1769.2 - (926 + 843)),-(0.2 + 0),(1.2 - 0)},{(194 - (93 + 101)),(0 + 0),(4.5 - 3),-(0.2 + 0),(550.2 - (351 + 199)),(1.2 + 0)}};
v42.HexToRGB = function(v537, v538)
	local FlatIdent_3726E = 0 - 0;
	while true do
		if (FlatIdent_3726E == (0 - 0)) then
			v538 = v538:gsub("#", "");
			if (v15(v538) == (1 + 2)) then
				return v16("0x" .. v538:sub(1 + 0, 1 - 0) .. v538:sub(1 + 0, 1339 - (919 + 419))), v16("0x" .. v538:sub(4 - 2, 1 + 1) .. v538:sub(2 + 0, 1543 - (663 + 878))), v16("0x" .. v538:sub(3 + 0, 1 + 2) .. v538:sub(3 + 0, 1139 - (275 + 861))), 787 - 532;
			elseif (v15(v538) == (761 - (533 + 222))) then
				return v16("0x" .. v538:sub(3 - 2, 1 + 1)), v16("0x" .. v538:sub(3 + 0, 1 + 3)), v16("0x" .. v538:sub(792 - (714 + 73), 2 + 4)), 206 + 49;
			elseif (v15(v538) == (141 - (61 + 72))) then
				return v16("0x" .. v538:sub(1532 - (838 + 693), 1 + 1)), v16("0x" .. v538:sub(2 + 1, 10 - 6)), v16("0x" .. v538:sub(80 - (71 + 4), 3 + 3)), v16("0x" .. v538:sub(2 + 5, 18 - 10));
			end
			break;
		end
	end
end;
v42.Helper = function(v539)
	local FlatIdent_1E5B = 1186 - (1171 + 15);
	local v540;
	local v541;
	local v542;
	local v543;
	local v544;
	local v545;
	local v546;
	local v547;
	local v548;
	while true do
		if (FlatIdent_1E5B == (0 - 0)) then
			v540, v541, v542 = v1['player'].position();
			v543 = v1['player']['height'];
			v544, v545, v546, v547, v548 = v539['color'][1 + 0], v539['color'][2 + 0], v539['color'][3 - 0], v539['color'][864 - (765 + 95)], v539['line_width'];
			FlatIdent_1E5B = 1 + 0;
		end
		if (FlatIdent_1E5B == (1 - 0)) then
			v539:SetColor(v539['colors'].red);
			v539:SetWidth(1 + 0);
			v539:Array(v86, v540, v541, v542, v85, false, false);
			FlatIdent_1E5B = 3 - 1;
		end
		if (FlatIdent_1E5B == (860 - (710 + 148))) then
			v539:Text("X", "GameFontNormal", v540 + v543, v541, v542);
			v539:SetColor(v539['colors'].green);
			v539:SetWidth(1 + 0);
			FlatIdent_1E5B = 11 - 8;
		end
		if (FlatIdent_1E5B == (2 + 3)) then
			v539['color'][3 - 2], v539['color'][523 - (258 + 263)], v539['color'][2 + 1], v539['color'][4 + 0], v539['line_width'] = v544, v545, v546, v547, v548;
			break;
		end
		if (FlatIdent_1E5B == (1720 - (673 + 1044))) then
			v539:Array(v87, v540, v541, v542, false, -v85, false);
			v539:Text("Y", "GameFontNormal", v540, v541 + v543, v542);
			v539:SetColor(v539['colors'].blue);
			FlatIdent_1E5B = 9 - 5;
		end
		if (FlatIdent_1E5B == (13 - 9)) then
			v539:SetWidth(379 - (261 + 117));
			v539:Array(v88, v540, v541, v542, false, false, false);
			v539:Text("Z", "GameFontNormal", v540, v541, v542 + v543);
			FlatIdent_1E5B = 156 - (79 + 72);
		end
	end
end;
v42.Enable = function(v554)
	local FlatIdent_17FDC = 1615 - (1116 + 499);
	while true do
		if ((0 - 0) == FlatIdent_17FDC) then
			v554['canvas']:SetScript("OnUpdate", function()
				v554:Update();
			end);
			v554['enabled'] = true;
			break;
		end
	end
end;
v42.Disable = function(v556)
	local FlatIdent_80902 = 0 - 0;
	while true do
		if ((3 - 1) == FlatIdent_80902) then
			v556['textures'] = {};
			v556['textures_used'] = {};
			v556['triangles'] = {};
			v556['triangles_used'] = {};
			FlatIdent_80902 = 276 - (89 + 184);
		end
		if ((6 - 3) == FlatIdent_80902) then
			v556['color'] = {(1457.17 - (1070 + 387)),(10.72 - (5 + 5)),(430.87 - (366 + 64))};
			v556['line_width'] = 1844 - (1602 + 241);
			break;
		end
		if ((0 - 0) == FlatIdent_80902) then
			v556:ClearCanvas();
			v556['canvas']:SetScript("OnUpdate", function()
			end);
			v556['enabled'] = false;
			v556['callbacks'] = {};
			FlatIdent_80902 = 1 + 0;
		end
		if ((115 - (44 + 70)) == FlatIdent_80902) then
			v556['lines'] = {};
			v556['lines_used'] = {};
			v556['strings'] = {};
			v556['strings_used'] = {};
			FlatIdent_80902 = 1674 - (1285 + 387);
		end
	end
end;
v42.Enabled = function(v569)
	return v569['enabled'];
end;
v42.Sync = function(v570, v571)
	v19(v570.callbacks, v571);
end;
v42.New = function(v572, v573)
	local v574 = {canvas=CreateFrame("Frame", "ADFrame", v573 or WorldFrame),callbacks={},lines={},lines_used={},strings={},strings_used={},textures={},textures_used={},triangles={},triangles_used={},color={v572:HexToRGB("50c3ff")},line_width=(1 + 0),enabled=false,relative=((v573 and v573) or WorldFrame)};
	v574['scale'] = v574['relative']:GetScale();
	v574['width'], v574['height'] = v574['relative']:GetSize();
	v574['canvas']:SetAllPoints(v574.relative);
	local v578 = WorldToScreen;
	local v579 = false;
	if v0['Util']['Draw'] then
		local FlatIdent_8DC01 = 552 - (77 + 475);
		local v822;
		local v823;
		while true do
			if (FlatIdent_8DC01 == (0 + 0)) then
				v822 = v0['Util']['Draw'];
				v823 = v822['WorldToScreen'];
				FlatIdent_8DC01 = 1 - 0;
			end
			if (FlatIdent_8DC01 == (1195 - (416 + 778))) then
				function v579(v835, v836, v837)
					return v823(v574, v835, v836, v837);
				end
				break;
			end
		end
	elseif (v25 == "noname") then
		function v579(v892, v893, v894)
			local FlatIdent_1F8C3 = 225 - (29 + 196);
			local v895;
			local v896;
			local v897;
			local v898;
			local v899;
			local v900;
			local v901;
			local v902;
			local v903;
			local v904;
			local v905;
			local v906;
			local v907;
			local v908;
			local v909;
			local v910;
			local v911;
			local v912;
			local v913;
			local v914;
			local v915;
			local v916;
			local v917;
			local v918;
			local v919;
			local v920;
			while true do
				if (FlatIdent_1F8C3 == (1643 - (969 + 674))) then
					v895, v896, v897, v898, v899, v900, v901, v902, v903, v904, v905, v906, v907, v908, v909, v910, v911, v912, v913, v914 = v24(31 + 2, v892, v893, v894);
					v895 = v892 - v898;
					v896 = v893 - v899;
					FlatIdent_1F8C3 = 441 - (101 + 339);
				end
				if (FlatIdent_1F8C3 == (5 - 3)) then
					v917 = (7 - 5) * (v2.atan((555.27 - (225 + 330)) * (v916 / v915)));
					v910 = (v895 * v904) + (v896 * v905) + (v897 * v906);
					v911 = (v895 * v907) + (v896 * v908) + (v897 * v909);
					FlatIdent_1F8C3 = 1166 - (10 + 1153);
				end
				if (FlatIdent_1F8C3 == (1 + 0)) then
					v897 = v894 - v900;
					v915 = v22();
					v916 = v23();
					FlatIdent_1F8C3 = 1886 - (943 + 941);
				end
				if (FlatIdent_1F8C3 == (1025 - (779 + 241))) then
					return v918, v919, v920;
				end
				if (FlatIdent_1F8C3 == (3 - 0)) then
					v912 = (v895 * v901) + (v896 * v902) + (v897 * v903);
					v918 = (v910 / v917) / v912;
					v919 = (v911 / (0.5 - 0)) / v912;
					FlatIdent_1F8C3 = 944 - (895 + 45);
				end
				if (FlatIdent_1F8C3 == (759 - (311 + 444))) then
					v920 = v912 > (1747 - (679 + 1068));
					v918 = ((408 - (47 + 360)) - v918) / (156 - (98 + 56));
					v919 = ((1080 - (101 + 978)) - v919) / (2 + 0);
					FlatIdent_1F8C3 = 5 + 0;
				end
			end
		end
	else
		function v579(v921, v922, v923)
			local FlatIdent_93117 = 0 - 0;
			local v924;
			local v925;
			while true do
				if (FlatIdent_93117 == (0 + 0)) then
					v924, v925 = v578(v921, v922, v923);
					return v924, -v925;
				end
			end
		end
	end
	v42.WorldToScreen = function(v672, v673, v674, v675)
		local FlatIdent_8636E = 0 + 0;
		local v676;
		local v677;
		local v678;
		while true do
			if (FlatIdent_8636E == (1 + 0)) then
				if (v25 == "noname") then
					local FlatIdent_7D15F = 0 - 0;
					local v838;
					while true do
						if (FlatIdent_7D15F == (1070 - (675 + 393))) then
							if ((v677 > v838) or (v3(v677) > (v672['height'] + v838))) then
								return false;
							end
							break;
						end
						if ((2 - 1) == FlatIdent_7D15F) then
							v677 = -(v672['height'] * v677 * v672['scale']);
							if ((v676 > (v672['width'] + v838)) or (v676 < -v838)) then
								return false;
							end
							FlatIdent_7D15F = 1 + 1;
						end
						if (FlatIdent_7D15F == (0 + 0)) then
							v838 = 1016 - 616;
							v676 = v672['width'] * v676 * v672['scale'];
							FlatIdent_7D15F = 1 + 0;
						end
					end
				end
				if ((v676 == (0 - 0)) or (v677 == (0 - 0))) then
					return false;
				end
				FlatIdent_8636E = 4 - 2;
			end
			if ((0 - 0) == FlatIdent_8636E) then
				v676, v677, v678 = v579(v673, v674, v675);
				if (v678 == false) then
					return false;
				end
				FlatIdent_8636E = 2 - 1;
			end
			if (FlatIdent_8636E == (1 + 1)) then
				return v676, v677;
			end
		end
	end;
	return setmetatable(v574, {__index=v572});
end;
do
	local FlatIdent_19909 = 1191 - (468 + 723);
	local v581;
	local v582;
	local v583;
	while true do
		if (FlatIdent_19909 == (643 - (342 + 300))) then
			function v583(v679, v680, v681, v682, v683, v684, v685)
				local FlatIdent_493C6 = 0 + 0;
				while true do
					if (FlatIdent_493C6 == (0 + 0)) then
						v684 = v684 / (3 - 1);
						v683 = v683 / (2 - 0);
						FlatIdent_493C6 = 1774 - (891 + 882);
					end
					if (FlatIdent_493C6 == (2 - 1)) then
						v685 = v1.rotate(v685, -v11 * (1316 - (816 + 498)));
						v680 = v680 + (v684 * v7(v685));
						FlatIdent_493C6 = 2 - 0;
					end
					if (FlatIdent_493C6 == (4 - 2)) then
						v681 = v681 + (v684 * v6(v685));
						v685 = v1.rotate(v685, -v11 / (1 + 1));
						FlatIdent_493C6 = 1701 - (729 + 969);
					end
					if (FlatIdent_493C6 == (1528 - (255 + 1270))) then
						return v582(v679, v680, v681, v682, v683, v684, v685);
					end
				end
			end
			v581['Rectangle'] = v583;
			FlatIdent_19909 = 2 + 0;
		end
		if (FlatIdent_19909 == (0 + 0)) then
			v581 = v42:New();
			v582 = v581['Rectangle'];
			FlatIdent_19909 = 992 - (711 + 280);
		end
		if (FlatIdent_19909 == (2 - 0)) then
			v581:Sync(function(v686)
				local FlatIdent_5B9C2 = 1156 - (695 + 461);
				local v687;
				local v688;
				local v689;
				local v690;
				local v691;
				while true do
					if (FlatIdent_5B9C2 == (334 - (292 + 42))) then
						v687 = v1['time'];
						v28 = v28 or v1['player'];
						FlatIdent_5B9C2 = 233 - (58 + 174);
					end
					if (FlatIdent_5B9C2 == (3 - 2)) then
						v688, v689, v690 = v28.position();
						v691 = v1['debug'];
						FlatIdent_5B9C2 = 444 - (378 + 64);
					end
					if ((2 + 0) == FlatIdent_5B9C2) then
						if v691['friends'] then
							for v866, v867 in v18(v1.friends) do
								local FlatIdent_1CA8C = 0 + 0;
								local v868;
								local v869;
								local v870;
								local v871;
								while true do
									if ((0 + 0) == FlatIdent_1CA8C) then
										v868, v869, v870 = v867.position();
										v686:SetColor(270 - 170, 474 - 249, 178 - 78, 147 - 92);
										FlatIdent_1CA8C = 4 - 3;
									end
									if ((1 + 0) == FlatIdent_1CA8C) then
										v871 = v867['combatReach'] or (2.5 - 1);
										v686:FilledCircle(v868, v869, v870, v871);
										FlatIdent_1CA8C = 1281 - (96 + 1183);
									end
									if (FlatIdent_1CA8C == (1 + 1)) then
										if v867['class2'] then
											local FlatIdent_6B4A5 = 1496 - (39 + 1457);
											local v930;
											local v931;
											local v932;
											while true do
												if (FlatIdent_6B4A5 == (0 - 0)) then
													v930, v931, v932 = v36(v31[v867['class2']:lower()]);
													if (v930 and v931 and v932) then
														local FlatIdent_13C96 = 0 - 0;
														while true do
															if (FlatIdent_13C96 == (1586 - (907 + 679))) then
																v686:SetColor(v930, v931, v932, 185 + 60);
																v686:Outline(v868, v869, v870, v871);
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
								end
							end
						end
						if v691['enemies'] then
							for v872, v873 in v18(v1.enemies) do
								local FlatIdent_5FD2C = 232 - (69 + 163);
								local v874;
								local v875;
								local v876;
								while true do
									if (FlatIdent_5FD2C == (1 + 0)) then
										v686:FilledCircle(v874, v875, v876, 856 - (608 + 246));
										if v873['class2'] then
											local FlatIdent_3ABE1 = 0 + 0;
											local v933;
											local v934;
											local v935;
											while true do
												if (FlatIdent_3ABE1 == (0 + 0)) then
													v933, v934, v935 = v36(v31[v873['class2']:lower()]);
													if (v933 and v934 and v935) then
														local FlatIdent_41361 = 0 + 0;
														while true do
															if (FlatIdent_41361 == (0 + 0)) then
																v686:SetColor(v933, v934, v935, 607 - (37 + 325));
																v686:Outline(v874, v875, v876, cr);
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
									if (FlatIdent_5FD2C == (0 + 0)) then
										v874, v875, v876 = v873.position();
										v686:SetColor(931 - (655 + 51), 91 + 9, 145 - 45, 1478 - (432 + 991));
										FlatIdent_5FD2C = 1 + 0;
									end
								end
							end
						end
						FlatIdent_5B9C2 = 1 + 2;
					end
					if ((758 - (125 + 629)) == FlatIdent_5B9C2) then
						if not v1['saved']['disableDrawings'] then
							for v882, v883 in v18(v1.DrawCallbacks) do
								v883(v686);
							end
						end
						break;
					end
					if (FlatIdent_5B9C2 == (635 - (91 + 541))) then
						if (v1['debugSmartAoE'] and v1['pointsDraw']) then
							local FlatIdent_95E1A = 1769 - (499 + 1270);
							while true do
								if (FlatIdent_95E1A == (0 + 0)) then
									v686:SetColor(178 + 77, 1234 - (591 + 642), 896 - (847 + 48), 577 - 322);
									for v877, v878 in v18(v1.pointsDraw) do
										local FlatIdent_22961 = 696 - (640 + 56);
										local v879;
										local v880;
										local v881;
										while true do
											if (FlatIdent_22961 == (0 + 0)) then
												v879, v880, v881 = v878['x'], v878['y'], v878['z'];
												if (v877 > (2 - 1)) then
													v686:SetColor(1552 - (1006 + 291), 778 - 523, 960 - (34 + 671), (((#v1['pointsDraw'] - v877) / #v1['pointsDraw']) * (1339 - (267 + 994))) + (12 - 7));
												end
												FlatIdent_22961 = 537 - (481 + 55);
											end
											if (FlatIdent_22961 == (2 - 1)) then
												v686:FilledCircle(v879, v880, v881, 1704.15 - (1665 + 39));
												break;
											end
										end
									end
									break;
								end
							end
						end
						if (v1['arena'] and v1['saved']['healerLine']) then
							if (v30['exists'] and (not v30['los'] or (v30['dist'] > (17 + 22)))) then
								local FlatIdent_7A2EC = 0 + 0;
								local v926;
								local v927;
								local v928;
								while true do
									if ((0 + 0) == FlatIdent_7A2EC) then
										v926, v927, v928 = v30.position();
										if v926 then
											local FlatIdent_689F = 585 - (384 + 201);
											while true do
												if (FlatIdent_689F == (0 + 0)) then
													v686:SetColor(v686['colors'].red);
													v686:Line(v688, v689, v690, v926, v927, v928);
													break;
												end
											end
										end
										break;
									end
								end
							end
						end
						FlatIdent_5B9C2 = 1 + 3;
					end
				end
			end);
			v581:Enable();
			break;
		end
	end
end
local function v96(v585, v586, v587, v588, v589)
	local FlatIdent_D043 = 0 - 0;
	local v590;
	local v591;
	while true do
		if (FlatIdent_D043 == (0 + 0)) then
			v590 = InetRequest(v585, v586, v587, v588);
			v591 = nil;
			FlatIdent_D043 = 1203 - (521 + 681);
		end
		if (FlatIdent_D043 == (3 - 2)) then
			function v591()
				local FlatIdent_66E22 = 741 - (210 + 531);
				local v692;
				local v693;
				while true do
					if (FlatIdent_66E22 == (677 - (516 + 161))) then
						v692, v693 = InetGetRequest(v590);
						if v692 then
							v589(v692, v693);
						else
							C_Timer.After(221 - (24 + 197), function()
								v591(v590);
							end);
						end
						break;
					end
				end
			end
			return v591(v590);
		end
	end
end
local function v97(v592, v593)
	local FlatIdent_4A688 = 0 + 0;
	local v594;
	while true do
		if ((0 - 0) == FlatIdent_4A688) then
			v594 = nil;
			function v594(v694, v695)
				if (v695 == (34 + 166)) then
					local FlatIdent_25E57 = 0 + 0;
					while true do
						if (FlatIdent_25E57 == (0 - 0)) then
							WriteFile(v593, v694, false);
							return true;
						end
					end
				else
					return false;
				end
			end
			FlatIdent_4A688 = 1 + 0;
		end
		if (FlatIdent_4A688 == (2 - 1)) then
			return v96("GET", v592, "", "", v594);
		end
	end
end
C_Timer.After(0.5 - 0, function()
	if (v0['type'] == "daemonic") then
		local FlatIdent_24B12 = 471 - (394 + 77);
		local v824;
		local v825;
		local v826;
		local v827;
		local v828;
		local v829;
		while true do
			if ((871 - (62 + 809)) == FlatIdent_24B12) then
				v824 = nil;
				function v824(v839, v840, v841, v842, v843)
					local FlatIdent_16BC = 938 - (795 + 143);
					local v844;
					local v845;
					while true do
						if (FlatIdent_16BC == (1 - 0)) then
							function v845()
								local FlatIdent_80915 = 0 - 0;
								local v884;
								local v885;
								while true do
									if (FlatIdent_80915 == (0 + 0)) then
										v884, v885 = InetGetRequest(v844);
										if v884 then
											v843(v884, v885);
										else
											C_Timer.After(0 + 0, function()
												v845(v844);
											end);
										end
										break;
									end
								end
							end
							return v845(v844);
						end
						if (FlatIdent_16BC == (465 - (114 + 351))) then
							v844 = InetRequest(v839, v840, v841, v842);
							v845 = nil;
							FlatIdent_16BC = 1 - 0;
						end
					end
				end
				v825 = {"LineTemplate.tga","filledcircle.tga","outline.tga","triangle.tga","OpenSans-Bold.ttf","OpenSans-Regular.ttf","logo.blp"};
				FlatIdent_24B12 = 2 - 1;
			end
			if (FlatIdent_24B12 == (3 + 0)) then
				v829 = nil;
				function v829(v847)
					local FlatIdent_70391 = 0 + 0;
					local v848;
					local v849;
					while true do
						if (FlatIdent_70391 == (1199 - (102 + 1096))) then
							function v849(v887, v888)
								if (v888 == (1310 - (694 + 416))) then
									if v847:match(".ttf") then
										WriteFile(v827 .. "\\Fonts\\" .. v847, v887, false);
									else
										WriteFile(v827 .. "\\Textures\\" .. v847, v887, false);
									end
								else
									local FlatIdent_7D20B = 248 - (181 + 67);
									while true do
										if (FlatIdent_7D20B == (0 + 0)) then
											v1.print("Failed to download textures...", true);
											return false;
										end
									end
								end
							end
							if not v828 then
								local FlatIdent_1B7F = 0 - 0;
								while true do
									if (FlatIdent_1B7F == (2 - 1)) then
										C_Timer.After(13 - 8, function()
											v1.print("Textures and fonts should be downloaded! Restart your game if you see green stuff showing up :)");
										end);
										v828 = true;
										break;
									end
									if ((657 - (399 + 258)) == FlatIdent_1B7F) then
										v1.alert("Downloading important textures and fonts..");
										v1.print("You may need to restart the game after this!");
										FlatIdent_1B7F = 1 + 0;
									end
								end
							end
							FlatIdent_70391 = 1 + 1;
						end
						if (FlatIdent_70391 == (9 - 7)) then
							v824("GET", v848 .. v847, "", "", v849);
							break;
						end
						if (FlatIdent_70391 == (0 - 0)) then
							v848 = "img.awful.wtf/Textures/";
							v849 = nil;
							FlatIdent_70391 = 2 - 1;
						end
					end
				end
				for v850, v851 in v18(v825) do
					if v851:match(".ttf") then
						if not ReadFile(v827 .. "\\Fonts\\" .. v851) then
							v829(v851);
						end
					elseif not ReadFile(v827 .. "\\Textures\\" .. v851) then
						v829(v851);
					end
				end
				break;
			end
			if ((2 + 0) == FlatIdent_24B12) then
				if not DirectoryExists(v827 .. "\\Textures") then
					CreateDirectory(v827 .. "\\Textures");
				end
				if not DirectoryExists(v827 .. "\\Fonts") then
					CreateDirectory(v827 .. "\\Fonts");
				end
				v828 = false;
				FlatIdent_24B12 = 40 - (26 + 11);
			end
			if (FlatIdent_24B12 == (1 + 0)) then
				v826 = nil;
				function v826(v846)
					for v886 = 1 + 0, #v825 do
						if (v825[v886] == v846) then
							return v886;
						end
					end
				end
				v827 = GetWowDirectory();
				FlatIdent_24B12 = 2 - 0;
			end
		end
	end
end);
v1.Draw(function(v595)
	local FlatIdent_4F3EF = 0 - 0;
	while true do
		if (FlatIdent_4F3EF == (2 - 1)) then
			for v696, v697 in v18(v1.PathsToDraw) do
				for v830, v831 in v18(v697) do
					local FlatIdent_56218 = 0 - 0;
					local v832;
					while true do
						if (FlatIdent_56218 == (0 + 0)) then
							v832 = v697[v830 + 1 + 0];
							if v832 then
								v595:Line(v831.x, v831.y, v831.z, v832.x, v832.y, v832.z);
							end
							break;
						end
					end
				end
			end
			break;
		end
		if (FlatIdent_4F3EF == (40 - (36 + 4))) then
			v595:SetColor(105 + 65, 299 - 129, 702 - 462, 209 + 46);
			v595:SetWidth(1.5 + 0);
			FlatIdent_4F3EF = 2 - 1;
		end
	end
end);
v1['DrawLib'] = v42;
