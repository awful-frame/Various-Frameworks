local v0, v1, v2 = ...;
if (v1['player']['class2'] ~= "PRIEST") then
	return;
end
if (GetSpecialization() ~= (1 - 0)) then
	return;
end
local v3 = v2['priest']['discipline'];
local v4 = v1['Draw'];
local v5 = v1['player'];
settings = v2['settings'];
local v7 = v1.createFont(1823 - (1427 + 384), "OUTLINE");
local v8 = {WARRIOR={(305 - 153),(218 - 135),(607 - (516 + 57))},PALADIN={(1855 - (957 + 650)),(162 - 53),(351 - 101)},PRIEST={(899 - (54 + 590)),(11 + 244),(141 + 114)},ROGUE={(196 + 59),(1771 - (528 + 988)),(20 + 42)},HUNTER={(682 - (252 + 317)),(921 - 690),(104 + 9)},DRUID={(136 + 119),(73 + 57),(1266 - (392 + 874))},SHAMAN={(396 - (261 + 135)),(1694 - (866 + 828)),(268 - (6 + 7))},MAGE={(0 - 0),(375 - 224),(565 - (134 + 176))},WARLOCK={(5 + 115),(1689 - (1138 + 551)),(140 + 115)},DEMONHUNTER={(94 + 1),(0 - 0),(411 - (107 + 101))},EVOKER={(22 + 9),(166 + 37),(941 - (47 + 739))},DEATHKNIGHT={(638 - 466),(0 - 0),(0 - 0)},MONK={(1607 - (1529 + 78)),(283 - (5 + 23)),(97 + 45)}};
local v9 = nil;
v4(function(v10)
	if ((select(57 - (29 + 26), IsInInstance()) == "arena") and settings['draws']) then
		local FlatIdent_60FA4 = 375 - (217 + 158);
		local v12;
		local v13;
		local v14;
		while true do
			if (FlatIdent_60FA4 == (1 + 0)) then
				v12, v13, v14 = v5.position();
				v10:SetColor(925 - (515 + 410), 280 - (182 + 98), 216 + 39, 351 - (54 + 97));
				FlatIdent_60FA4 = 4 - 2;
			end
			if (FlatIdent_60FA4 == (0 + 0)) then
				v10:SetWidth(3 - 1);
				v1['fgroup'].loop(function(v15)
					local FlatIdent_63841 = 1917 - (619 + 1298);
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
						if (FlatIdent_63841 == (0 - 0)) then
							v16 = v15['class2'];
							v17, v18, v19 = v15.position();
							FlatIdent_63841 = 1 + 0;
						end
						if (FlatIdent_63841 == (1 + 0)) then
							v20 = v5.losOf(v15);
							v21 = v5.distanceTo(v15);
							FlatIdent_63841 = 1 + 1;
						end
						if (FlatIdent_63841 == (6 - 4)) then
							if (v20 and (v21 <= (138 - 98))) then
								if v8[v16] then
									local FlatIdent_98C54 = 1396 - (1308 + 88);
									local v29;
									local v30;
									local v31;
									while true do
										if (FlatIdent_98C54 == (0 + 0)) then
											v29, v30, v31 = unpack(v8[v16]);
											v10:SetColor(v29, v30, v31, 49 + 151);
											break;
										end
									end
								else
									v10:SetColor(1728 - (316 + 1157), 96 + 159, 551 - 296, 1285 - (807 + 278));
								end
							else
								v10:SetColor(1298 - (26 + 1017), 0 + 0, 0 + 0, 1479 - (628 + 651));
							end
							v22, v23, v24 = v5.position();
							FlatIdent_63841 = 3 - 0;
						end
						if ((3 + 0) == FlatIdent_63841) then
							v10:Line(v22, v23, v24, v17, v18, v19);
							break;
						end
					end
				end);
				FlatIdent_60FA4 = 776 - (257 + 518);
			end
			if ((981 - (492 + 487)) == FlatIdent_60FA4) then
				v10:Circle(v12, v13, v14, 5 + 3);
				break;
			end
		end
	end
end);
v4(function(v11)
	if ((select(113 - (91 + 20), IsInInstance()) == "arena") and settings['draws']) then
		v1['triggers'].loop(function(v25)
			local FlatIdent_72D22 = 1510 - (193 + 1317);
			local v26;
			local v27;
			local v28;
			while true do
				if (FlatIdent_72D22 == (0 + 0)) then
					if (v25['id'] ~= (188889 - (450 + 789))) then
						return;
					end
					v26, v27, v28 = v25.position();
					FlatIdent_72D22 = 327 - (39 + 287);
				end
				if ((392 - (145 + 246)) == FlatIdent_72D22) then
					v11:Circle(v26, v27, v28, 249.5 - (159 + 88));
					break;
				end
			end
		end);
	end
end);
