local v0, v1, v2 = ...;
if (v1['player']['class2'] ~= "PALADIN") then
	return;
end
if (v1['player']['spec'] ~= "Holy") then
	return;
end
local v3 = v2['paladin']['holy'];
local v4 = v1['Draw'];
local v5 = v1['player'];
local v6 = v2['settings'];
local v7 = v1.createFont(3 + 9, "OUTLINE");
local v8 = {WARRIOR={(633 - (147 + 334)),(74 + 9),(87 - 53)},PALADIN={(921 - 673),(205 - 96),(1816 - (1270 + 296))},PRIEST={(225 + 30),(966 - 711),(1437 - (456 + 726))},ROGUE={(121 + 134),(439 - 184),(300 - 238)},HUNTER={(71 + 42),(1653 - (16 + 1406)),(80 + 33)},DRUID={(119 + 136),(51 + 79),(0 + 0)},SHAMAN={(0 - 0),(1674 - (1347 + 327)),(25 + 230)},MAGE={(0 + 0),(208 - 57),(910 - 655)},WARLOCK={(51 + 69),(0 - 0),(1345 - (882 + 208))},DEMONHUNTER={(716 - (175 + 446)),(1006 - (92 + 914)),(102 + 101)},EVOKER={(76 - 45),(31 + 172),(3 + 152)},DEATHKNIGHT={(609 - (196 + 241)),(0 + 0),(0 - 0)},MONK={(0 + 0),(203 + 52),(1037 - (137 + 758))}};
v4(function(v9)
	if ((select(5 - 3, IsInInstance()) == "arena") and v2['settings']['draws']) then
		local FlatIdent_E067 = 0 + 0;
		local v10;
		local v11;
		local v12;
		local v13;
		while true do
			if ((1950 - (1510 + 440)) == FlatIdent_E067) then
				v10 = v1['friendlyTotems'].within(39 + 1).find(function(v14)
					return v14['id'] == (6756 + 94187);
				end);
				v9:SetWidth(1 + 1);
				FlatIdent_E067 = 1 - 0;
			end
			if ((6 - 4) == FlatIdent_E067) then
				v9:SetColor(0 - 0, 0 - 0, 14 + 241, 36 + 164);
				v9:Circle(v11, v12, v13, 1 + 0);
				break;
			end
			if ((1 - 0) == FlatIdent_E067) then
				v1['fgroup'].loop(function(v15)
					local FlatIdent_1097F = 749 - (717 + 32);
					local v16;
					local v17;
					local v18;
					local v19;
					local v20;
					local v21;
					local v22;
					local v23;
					local v24;
					while true do
						if ((7 - 4) == FlatIdent_1097F) then
							v22, v23, v24 = v5.position();
							v9:Line(v22, v23, v24, v17, v18, v19);
							FlatIdent_1097F = 14 - 10;
						end
						if (FlatIdent_1097F == (923 - (258 + 665))) then
							if not v15 then
								return;
							end
							v16 = v15['class2'];
							FlatIdent_1097F = 1 + 0;
						end
						if (FlatIdent_1097F == (652 - (583 + 67))) then
							v21 = v5.distanceTo(v15);
							if (v20 and (v21 <= (455 - (173 + 242)))) then
								if v8[v16] then
									local FlatIdent_7E593 = 0 - 0;
									local v28;
									local v29;
									local v30;
									while true do
										if ((1670 - (171 + 1499)) == FlatIdent_7E593) then
											v28, v29, v30 = unpack(v8[v16]);
											v9:SetColor(v28, v29, v30, 426 - (219 + 7));
											break;
										end
									end
								else
									v9:SetColor(1135 - 880, 238 + 17, 39 + 216, 816 - 616);
								end
							else
								v9:SetColor(684 - (210 + 219), 0 + 0, 1012 - (681 + 331), 497 - 297);
							end
							FlatIdent_1097F = 2 + 1;
						end
						if (FlatIdent_1097F == (1082 - (388 + 690))) then
							if v10 then
								local FlatIdent_4B056 = 0 + 0;
								local v25;
								local v26;
								local v27;
								while true do
									if (FlatIdent_4B056 == (336 - (302 + 34))) then
										v25, v26, v27 = v10.position();
										if (v25 and v26 and v27) then
											local FlatIdent_4DC83 = 0 + 0;
											while true do
												if (FlatIdent_4DC83 == (0 + 0)) then
													v9:SetColor(0 - 0, 927 - (145 + 527), 0 - 0, 518 - 343);
													v9:Outline(v25, v26, v27, 10 + 0);
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
						if (FlatIdent_1097F == (1 + 0)) then
							v17, v18, v19 = v15.position();
							v20 = v5.losOf(v15);
							FlatIdent_1097F = 449 - (63 + 384);
						end
					end
				end);
				v11, v12, v13 = v5.position();
				FlatIdent_E067 = 3 - 1;
			end
		end
	end
end);
