local v0, v1 = ...;
local v2 = v0['Util']['Evaluator'];
local v3 = v0['Util']['ObjectManager'];
local v4, v5 = tinsert, type;
local _G, _ENV = _G, getfenv(1 + 0);
local v6 = 1260.81 - (1189 + 69);
v1['__index'] = v1;
v1['internal'] = {};
v1['internal']['loaded'] = {};
v1['cache'] = {};
v1['cacheLiteral'] = {};
v1['gameVersion'] = WOW_PROJECT_ID;
v1['__username'] = v1['__username'] or "/balls";
local v14;
if (v1['gameVersion'] ~= (1 + 0)) then
	local v340 = {UnitSpellHaste=(0 - 0)};
	for v589, v590 in pairs(v340) do
		_G[v589] = _G[v589] or function()
			return v590;
		end;
	end
	local v341 = {version=(17097 + 52323)};
	v341['MAX_TALENT_TIERS'] = 748 - (542 + 199);
	v341['NUM_TALENT_COLUMNS'] = 1831 - (1049 + 778);
	local v344 = {ID=(834 - (451 + 382)),displayName="Warrior",name="WARRIOR",Arms=(100 - 29),Fury=(50 + 22),Prot=(49 + 24),specs={(409 - (123 + 215)),(12 + 60),(20 + 53)}};
	local v345 = {ID=(2 + 0),displayName="Paladin",name="PALADIN",Holy=(136 - 71),Prot=(58 + 8),Ret=(188 - 118),specs={(752 - (598 + 89)),(48 + 18),(29 + 41)}};
	local v346 = {ID=(2 + 1),displayName="Hunter",name="HUNTER",BM=(805 - 552),MM=(1215 - (639 + 322)),SV=(669 - (393 + 21)),specs={(788 - 535),(646 - 392),(40 + 215)}};
	local v347 = {ID=(12 - 8),displayName="Rogue",name="ROGUE",Assasin=(1474 - (948 + 267)),Combat=(1502 - (1121 + 121)),Sub=(1930 - (1129 + 540)),specs={(182 + 77),(1272 - 1012),(838 - (106 + 471))}};
	local v348 = {ID=(15 - 10),displayName="Priest",name="PRIEST",Disc=(1116 - (852 + 8)),Holy=(435 - 178),Shadow=(904 - (513 + 133)),specs={(210 + 46),(955 - 698),(765 - 507)}};
	local v349 = {ID=(14 - 8),displayName="Death knight",name="DEATHKNIGHT",Blood=(913 - (579 + 84)),Frost=(929 - 678),Unholy=(513 - 261),specs={(1241 - 991),(146 + 105),(560 - 308)}};
	local v350 = {ID=(17 - 10),displayName="Shaman",name="SHAMAN",Ele=(881 - (307 + 312)),Enh=(262 + 1),Resto=(200 + 64),specs={(214 + 48),(56 + 207),(24 + 240)}};
	local v351 = {ID=(21 - 13),displayName="Mage",name="MAGE",Arcane=(123 - 61),Fire=(1427 - (1141 + 223)),Frost=(24 + 40),specs={(99 - 37),(50 + 13),(236 - (113 + 59))}};
	local v352 = {ID=(1 + 8),displayName="Warlock",name="WARLOCK",Affl=(705 - 440),Demo=(662 - (351 + 45)),Destro=(1351 - (92 + 992)),specs={(237 + 28),(1242 - 976),(2212 - (453 + 1492))}};
	local v353 = {ID=(26 - 16),displayName="Monk",name="MONK",BRM=(33 + 235),WW=(485 - 216),MW=(2021 - (1357 + 394)),specs={(2 + 266),(1178 - (118 + 791)),(379 - 109)}};
	local v354 = {ID=(51 - 40),displayName="Druid",name="DRUID",Balance=(205 - 103),Feral=(241 - 138),Guardian=(256 - 152),Resto=(497 - (369 + 23)),specs={(32 + 70),(1123 - (484 + 536)),(102 + 2),(72 + 33)}};
	local v355 = {ID=(36 - 24),displayName="Demon hunter",name="DEMONHUNTER",Havoc=(1854 - (1121 + 156)),Veng=(155 + 426),specs={(271 + 306),(803 - (157 + 65))}};
	v341['Class'] = {Warrior=v344,Paladin=v345,Hunter=v346,Rogue=v347,Priest=v348,DK=v349,Shaman=v350,Mage=v351,Warlock=v352,Monk=v353,Druid=v354,DH=v355};
	local v357 = {v344,v345,v346,v347,v348,v349,v350,v351,v352,v353,v354,v355};
	local v358 = {Strength=(3 - 2),Agility=(1211 - (119 + 1090)),Stamina=(7 - 4),Intellect=(4 + 0),Spirit=(796 - (337 + 454))};
	v341['Stat'] = v358;
	local v360 = {Damager="DAMAGER",Tank="TANK",Healer="HEALER"};
	v341['Role'] = v360;
	local v362 = {[v344['name']]=v344['specs'],[v345['name']]=v345['specs'],[v346['name']]=v346['specs'],[v347['name']]=v347['specs'],[v348['name']]=v348['specs'],[v349['name']]=v349['specs'],[v350['name']]=v350['specs'],[v351['name']]=v351['specs'],[v352['name']]=v352['specs'],[v353['name']]=v353['specs'],[v354['name']]=v354['specs'],[v355['name']]=v355['specs']};
	local v363 = {[v344['Arms']]={ID=v344['Arms'],name="Arms",description="",icon="",background="",role=v360['Damager'],isRecommended=false,primaryStat=v358['Strength']},[v344['Fury']]={ID=v344['Fury'],name="Fury",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Strength']},[v344['Prot']]={ID=v344['Prot'],name="Protection",description="",icon="",background="",role=v360['Tank'],isRecommended=false,primaryStat=v358['Strength']},[v345['Holy']]={ID=v345['Holy'],name="Holy",description="",icon="",background="",role=v360['Healer'],isRecommended=false,primaryStat=v358['Intellect']},[v345['Prot']]={ID=v345['Prot'],name="Protection",description="",icon="",background="",role=v360['Tank'],isRecommended=false,primaryStat=v358['Strength']},[v345['Ret']]={ID=v345['Ret'],name="Retribution",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Strength']},[v346['BM']]={ID=v346['BM'],name="Beast Mastery",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Agility']},[v346['MM']]={ID=v346['MM'],name="Marksman",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Agility']},[v346['SV']]={ID=v346['SV'],name="Survival",description="",icon="",background="",role=v360['Damager'],isRecommended=false,primaryStat=v358['Agility']},[v347['Assasin']]={ID=v347['Assasin'],name="Assasination",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Agility']},[v347['Combat']]={ID=v347['Combat'],name="Combat",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Agility']},[v347['Sub']]={ID=v347['Sub'],name="Subtlety",description="",icon="",background="",role=v360['Damager'],isRecommended=false,primaryStat=v358['Agility']},[v348['Disc']]={ID=v348['Disc'],name="Discipline",description="",icon="",background="",role=v360['Healer'],isRecommended=true,primaryStat=v358['Intellect']},[v348['Holy']]={ID=v348['Holy'],name="Holy",description="",icon="",background="",role=v360['Healer'],isRecommended=true,primaryStat=v358['Intellect']},[v348['Shadow']]={ID=v348['Shadow'],name="Shadow",description="",icon="",background="",role=v360['Damager'],isRecommended=false,primaryStat=v358['Intellect']},[v350['Ele']]={ID=v350['Ele'],name="Elemental",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v350['Enh']]={ID=v350['Enh'],name="Enhancement",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Strength']},[v350['Resto']]={ID=v350['Resto'],name="Restoration",description="",icon="",background="",role=v360['Healer'],isRecommended=true,primaryStat=v358['Intellect']},[v351['Arcane']]={ID=v351['Arcane'],name="Arcane",description="",icon="",background="",role=v360['Damager'],isRecommended=false,primaryStat=v358['Intellect']},[v351['Fire']]={ID=v351['Fire'],name="Fire",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v351['Frost']]={ID=v351['Frost'],name="Frost",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v352['Affl']]={ID=v352['Affl'],name="Affliction",description="",icon="",background="",role=v360['Damager'],isRecommended=false,primaryStat=v358['Intellect']},[v352['Demo']]={ID=v352['Demo'],name="Demonology",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v352['Destro']]={ID=v352['Destro'],name="Destruction",description="",icon="",background="",role=v360['Damager'],isRecommended=false,primaryStat=v358['Intellect']},[v354['Balance']]={ID=v354['Balance'],name="Balance",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v354['Feral']]={ID=v354['Feral'],name="Feral",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Strength']},[v354['Guardian']]={ID=v354['Guardian'],name="Guardian",description="",icon="",background="",role=v360['Tank'],isRecommended=true,primaryStat=v358['Strength']},[v354['Resto']]={ID=v354['Resto'],name="Restoration",description="",icon="",background="",role=v360['Healer'],isRecommended=true,primaryStat=v358['Intellect']},[v349['Frost']]={ID=v349['Frost'],name="Frost",description="",icon="",background="",role=v360['Tank'],isRecommended=true,primaryStat=v358['Intellect']},[v349['Blood']]={ID=v349['Blood'],name="Blood",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v349['Unholy']]={ID=v349['Unholy'],name="Unholy",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v355['Havoc']]={ID=v355['Havoc'],name="Havoc",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Intellect']},[v355['Veng']]={ID=v355['Veng'],name="Vengeance",description="",icon="",background="",role=v360['Tank'],isRecommended=true,primaryStat=v358['Intellect']},[v353['BRM']]={ID=v353['BRM'],name="Brewmaster",description="",icon="",background="",role=v360['Tank'],isRecommended=true,primaryStat=v358['Agility']},[v353['MW']]={ID=v353['MW'],name="Mistweaver",description="",icon="",background="",role=v360['Healer'],isRecommended=true,primaryStat=v358['Intellect']},[v353['WW']]={ID=v353['WW'],name="Windwalker",description="",icon="",background="",role=v360['Damager'],isRecommended=true,primaryStat=v358['Agility']}};
	v341['SpecInfo'] = v363;
	local v365 = {};
	for v591, v592 in pairs(v363) do
		v365[v591] = v592['role'];
	end
	v341.GetClassInfo = function(v595)
		local FlatIdent_2E214 = 0 + 0;
		local v596;
		while true do
			if (FlatIdent_2E214 == (1 + 0)) then
				return v596['displayName'], v596['name'], v596['ID'];
			end
			if (FlatIdent_2E214 == (0 - 0)) then
				v596 = v357[v595];
				if (v596 == nil) then
					return nil;
				end
				FlatIdent_2E214 = 821 - (230 + 590);
			end
		end
	end;
	v341.GetNumSpecializationsForClassID = function(v597)
		local FlatIdent_8182A = 0 - 0;
		local v598;
		local v599;
		while true do
			if (FlatIdent_8182A == (1 + 0)) then
				v599 = v362[v598['name']];
				return #v599;
			end
			if (FlatIdent_8182A == (0 - 0)) then
				if ((v597 <= (0 + 0)) or (v597 > v341.GetNumClasses())) then
					return nil;
				end
				v598 = v357[v597];
				FlatIdent_8182A = 114 - (70 + 43);
			end
		end
	end;
	v341.GetInspectSpecialization = function(v600)
		return nil;
	end;
	v341.GetActiveSpecGroup = function()
		return 1 + 0;
	end;
	local v370 = 880 - (767 + 111);
	local v371 = 4 - 1;
	local v372 = 572 - (308 + 259);
	local v373 = 3 + 0;
	local v374 = 1 + 3;
	v341.GetSpecialization = function(v601, v602, v603)
		local FlatIdent_6288A = 0 + 0;
		local v604;
		local v605;
		local v606;
		while true do
			if (FlatIdent_6288A == (747 - (646 + 98))) then
				if (v606 == v354['ID']) then
					local FlatIdent_36C11 = 0 + 0;
					local v967;
					local v968;
					while true do
						if (FlatIdent_36C11 == (1069 - (178 + 890))) then
							if ((v967 == (6 - 1)) and (v968 == (4 + 1))) then
								return v373;
							end
							if (v604 == v373) then
								return v374;
							else
								return v604;
							end
							break;
						end
						if (FlatIdent_36C11 == (698 - (149 + 549))) then
							v967 = select(1547 - (1378 + 164), GetTalentInfo(v370, v371));
							v968 = select(4 + 1, GetTalentInfo(v370, v372));
							FlatIdent_36C11 = 1000 - (36 + 963);
						end
					end
				end
				return v604 or (1 + 0);
			end
			if (FlatIdent_6288A == (1158 - (66 + 1090))) then
				for v906 = 1 - 0, GetNumTalentTabs() do
					local FlatIdent_2B24D = 0 - 0;
					local v907;
					while true do
						if (FlatIdent_2B24D == (182 - (165 + 17))) then
							v907 = ((v1['gameVersion'] == (22 - 8)) and select(1362 - (1339 + 18), GetTalentTabInfo(v906))) or select(3 + 0, GetTalentTabInfo(v906));
							if ((v5(v907) == "number") and (v907 > v605)) then
								local FlatIdent_73BD5 = 0 - 0;
								while true do
									if (FlatIdent_73BD5 == (74 - (8 + 66))) then
										v604 = v906;
										v605 = v907;
										break;
									end
								end
							end
							break;
						end
					end
				end
				v606 = select(3 + 0, UnitClass("player"));
				FlatIdent_6288A = 1909 - (512 + 1394);
			end
			if ((0 + 0) == FlatIdent_6288A) then
				if (v601 or v602) then
					return nil;
				end
				if (UnitLevel("player") < (1468 - (47 + 1411))) then
					return 918 - (293 + 620);
				end
				FlatIdent_6288A = 1 + 0;
			end
			if (FlatIdent_6288A == (4 - 3)) then
				v604 = nil;
				v605 = 1886 - (563 + 1323);
				FlatIdent_6288A = 7 - 5;
			end
		end
	end;
	v341.GetSpecializationInfo = function(v607, v608, v609, v610, v611)
		local FlatIdent_28125 = 0 + 0;
		local v612;
		local v613;
		local v614;
		local v615;
		while true do
			if ((556 - (302 + 253)) == FlatIdent_28125) then
				v614 = v362[v613][v607];
				if not v614 then
					return nil;
				end
				FlatIdent_28125 = 4 - 2;
			end
			if ((0 - 0) == FlatIdent_28125) then
				if (v608 or v609) then
					return nil;
				end
				v612, v613 = UnitClass("player");
				FlatIdent_28125 = 173 - (10 + 162);
			end
			if (FlatIdent_28125 == (2 + 0)) then
				v615 = v363[v614];
				return v615['ID'], v615['name'], v615['description'], v615['icon'], v615['background'], v615['role'], v615['primaryStat'];
			end
		end
	end;
	v341.GetSpecializationInfoForClassID = function(v616, v617)
		local FlatIdent_4A83F = 0 + 0;
		local v618;
		local v619;
		local v620;
		local v621;
		while true do
			if (FlatIdent_4A83F == (899 - (792 + 107))) then
				v618 = v357[v616];
				if not v618 then
					return nil;
				end
				FlatIdent_4A83F = 1 + 0;
			end
			if (FlatIdent_4A83F == (1 + 0)) then
				v619 = v362[v618['name']][v617];
				v620 = v363[v619];
				FlatIdent_4A83F = 3 - 1;
			end
			if (FlatIdent_4A83F == (1 + 2)) then
				return v620['ID'], v620['name'], v620['description'], v620['icon'], v620['role'], v620['isRecommended'], v621;
			end
			if (FlatIdent_4A83F == (2 + 0)) then
				if not v620 then
					return nil;
				end
				v621 = v616 == select(5 - 2, UnitClass("player"));
				FlatIdent_4A83F = 1302 - (901 + 398);
			end
		end
	end;
	v341.GetSpecializationRoleByID = function(v622)
		return v365[v622];
	end;
	v341.GetSpecializationRole = function(v623, v624, v625)
		local FlatIdent_5D23 = 1972 - (170 + 1802);
		local v626;
		local v627;
		local v628;
		while true do
			if (FlatIdent_5D23 == (1 + 0)) then
				v628 = v362[v627][v623];
				return v365[v628];
			end
			if ((0 - 0) == FlatIdent_5D23) then
				if (v624 or v625) then
					return nil;
				end
				v626, v627 = UnitClass("player");
				FlatIdent_5D23 = 2 - 1;
			end
		end
	end;
	v341.GetNumClasses = function()
		return #v357;
	end;
	_G['MAX_TALENT_TIERS'] = _G['MAX_TALENT_TIERS'] or v341['MAX_TALENT_TIERS'];
	_G['NUM_TALENT_COLUMNS'] = _G['NUM_TALENT_COLUMNS'] or v341['NUM_TALENT_COLUMNS'];
	_G['GetNumClasses'] = _G['GetNumClasses'] or v341['GetNumClasses'];
	_G['GetClassInfo'] = _G['GetClassInfo'] or v341['GetClassInfo'];
	_G['GetNumSpecializationsForClassID'] = _G['GetNumSpecializationsForClassID'] or v341['GetNumSpecializationsForClassID'];
	_G['GetActiveSpecGroup'] = _G['GetActiveSpecGroup'] or v341['GetActiveSpecGroup'];
	_G['GetSpecialization'] = _G['GetSpecialization'] or v341['GetSpecialization'];
	_G['GetSpecializationInfo'] = _G['GetSpecializationInfo'] or v341['GetSpecializationInfo'];
	_G['GetSpecializationInfoForClassID'] = _G['GetSpecializationInfoForClassID'] or v341['GetSpecializationInfoForClassID'];
	_G['GetSpecializationRole'] = _G['GetSpecializationRole'] or v341['GetSpecializationRole'];
	_G['GetSpecializationRoleByID'] = _G['GetSpecializationRoleByID'] or v341['GetSpecializationRoleByID'];
end
local function v15(v144)
	return math.ceil((v144 + (799 - (475 + 249))) / (70 - 20)) * (36 + 14);
end
v1.FILTER_D = function(v145, v146)
	local FlatIdent_266A6 = 0 + 0;
	local v147;
	local v148;
	local v149;
	local v150;
	local v152;
	local v153;
	local v154;
	local v155;
	while true do
		if (FlatIdent_266A6 == (206 - (15 + 185))) then
			return v145;
		end
		if (FlatIdent_266A6 == (1 + 1)) then
			if not v145[v149] then
				v145[v149] = {};
			end
			v150 = v145[v149];
			v150['playTime'] = (v150['playTime'] and (v150['playTime'] + v146)) or v146;
			FlatIdent_266A6 = 1232 - (168 + 1061);
		end
		if (FlatIdent_266A6 == (0 - 0)) then
			if (v1['gameVersion'] ~= (1 + 0)) then
				return;
			end
			v14 = v14 or v1['player'];
			if (v145['uData'] or v145['cData']) then
				return;
			end
			FlatIdent_266A6 = 1352 - (730 + 621);
		end
		if ((509 - (317 + 187)) == FlatIdent_266A6) then
			if (v154 > (0 - 0)) then
				v154 = v15(v154);
			end
			if (v153 > (948 - (591 + 357))) then
				local FlatIdent_87673 = 0 + 0;
				while true do
					if (FlatIdent_87673 == (0 + 0)) then
						v150['current2v2'] = v152;
						if (not v150['best2v2'] or (v153 > v150['best2v2'])) then
							v150['best2v2'] = v153;
						end
						break;
					end
				end
			end
			if (v155 > (0 - 0)) then
				local FlatIdent_2EC3 = 1288 - (1041 + 247);
				while true do
					if (FlatIdent_2EC3 == (0 - 0)) then
						v150['current3v3'] = v154;
						if (not v150['best3v3'] or (v155 > v150['best3v3'])) then
							v150['best3v3'] = v155;
						end
						break;
					end
				end
			end
			FlatIdent_266A6 = 18 - 12;
		end
		if ((1881 - (1578 + 299)) == FlatIdent_266A6) then
			if (v153 > (0 - 0)) then
				v153 = v15(v153);
			end
			if (v155 > (0 - 0)) then
				v155 = v15(v155);
			end
			if (v152 > (156 - (71 + 85))) then
				v152 = v15(v152);
			end
			FlatIdent_266A6 = 5 + 0;
		end
		if (FlatIdent_266A6 == (1 + 0)) then
			v147 = v14['spec'] or "Unknown";
			v148 = v14['class'] or "Unknown";
			v149 = v147 .. " " .. v148;
			FlatIdent_266A6 = 2 + 0;
		end
		if (FlatIdent_266A6 == (1 + 2)) then
			v152, v153 = GetPersonalRatedInfo(1 + 0);
			v154, v155 = GetPersonalRatedInfo(1468 - (326 + 1140));
			if not v153 then
				return;
			end
			FlatIdent_266A6 = 3 + 1;
		end
	end
end;
local v17 = v1['loadUnits'];
local v18 = tremove;
local v19 = 4 + 4;
local v20 = {player=true,target=true,focus=true,mouseover=true,pet=true,arena1=true,arena2=true,arena3=true,arena4=true,arena5=true,healer=true,enemyHealer=true};
local v21 = {};
v1['calls'] = v21;
local function v23(v156, v157, v158, v159, v160, ...)
	if (v5(v160) == "function") then
		local FlatIdent_3AC37 = 242 - (208 + 34);
		local v632;
		local v633;
		local v634;
		local v635;
		local v636;
		while true do
			if (FlatIdent_3AC37 == (1372 - (866 + 505))) then
				v635 = {v634(...)};
				v636 = (v635 and v635[v633 or v158]) or false;
				FlatIdent_3AC37 = 1 + 1;
			end
			if ((402 - (228 + 174)) == FlatIdent_3AC37) then
				v632, v633 = v160(v157);
				v634 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				FlatIdent_3AC37 = 1 - 0;
			end
			if (FlatIdent_3AC37 == (8 - 5)) then
				return v636;
			end
			if (FlatIdent_3AC37 == (571 - (170 + 399))) then
				v1[v156] = v636;
				v1['cacheLiteral'][v156] = v636;
				FlatIdent_3AC37 = 4 - 1;
			end
		end
	elseif (v5(v160) == "number") then
		local FlatIdent_96A9E = 0 + 0;
		local v971;
		local v972;
		local v973;
		while true do
			if (FlatIdent_96A9E == (1031 - (1027 + 3))) then
				v973 = (v972 and v972[v160]) or false;
				v1[v156] = v973;
				FlatIdent_96A9E = 4 - 2;
			end
			if (FlatIdent_96A9E == (1 + 1)) then
				v1['cacheLiteral'][v156] = v973;
				return v973;
			end
			if (FlatIdent_96A9E == (924 - (370 + 554))) then
				v971 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				v972 = {v971(...)};
				FlatIdent_96A9E = 1 + 0;
			end
		end
	elseif (v160 == "single") then
		local FlatIdent_202ED = 0 - 0;
		local v1113;
		local v1114;
		local v1115;
		while true do
			if (FlatIdent_202ED == (861 - (462 + 399))) then
				v1113 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				v1114 = v1113(...);
				FlatIdent_202ED = 2 - 1;
			end
			if (FlatIdent_202ED == (3 - 1)) then
				v1['cacheLiteral'][v156] = v1115;
				return v1115;
			end
			if (FlatIdent_202ED == (1327 - (902 + 424))) then
				v1115 = v1114 or false;
				v1[v156] = v1115;
				FlatIdent_202ED = 1209 - (631 + 576);
			end
		end
	else
		local FlatIdent_648A1 = 0 + 0;
		local v1118;
		local v1119;
		local v1120;
		while true do
			if (FlatIdent_648A1 == (2 + 0)) then
				return v1120;
			end
			if (FlatIdent_648A1 == (354 - (68 + 285))) then
				v1120 = (v1119 and v1119[v158]) or false;
				if (v158 == (497 - (418 + 78))) then
					local FlatIdent_766F8 = 899 - (712 + 187);
					while true do
						if (FlatIdent_766F8 == (0 + 0)) then
							v1[v156] = v1120;
							v1['cacheLiteral'][v156] = v1120;
							break;
						end
					end
				else
					local FlatIdent_8A56D = 1257 - (474 + 783);
					while true do
						if ((0 + 0) == FlatIdent_8A56D) then
							v1[v156 .. v158] = v1120;
							v1['cacheLiteral'][v156 .. v158] = v1120;
							break;
						end
					end
				end
				FlatIdent_648A1 = 2 + 0;
			end
			if (FlatIdent_648A1 == (1602 - (1589 + 13))) then
				v1118 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				v1119 = {v1118(...)};
				FlatIdent_648A1 = 1 + 0;
			end
		end
	end
end
local v24 = {SpellQueued=true,paused=true,burst=true,releaseMovementTime=true,ttd_enabled=true,releaseFacingTime=true,enabled=true,sortPointer=true,premium=true,debugSmartAoE=true};
local v25 = {__index=function(v161, v162)
	if ((v162 ~= "loadUnits") and not v17) then
		v17 = v161['loadUnits'];
	end
	if not v162 then
		return;
	end
	if v24[v162] then
		return;
	end
	local v163 = 1 + 0;
	local v164 = v162:lower();
	if (v164 == "spelllimiter") then
		local FlatIdent_6395E = 0 + 0;
		while true do
			if ((1702 - (810 + 892)) == FlatIdent_6395E) then
				if not v1['internal']['spellLimiter'] then
					v1['internal']['spellLimiter'] = 0 - 0;
				end
				return v1['internal']['spellLimiter'];
			end
		end
	elseif ((v164 == "preparation") or (v164 == "prep")) then
		return (v161['prepRemains'] > (0 - 0)) or v1['player'].buff(19663 + 13064);
	elseif ((v164 == "prepremains") or (v164 == "preptimeleft") or (v164 == "gatetimer") or (v164 == "arenastarttimer") or (v164 == "pulltimer") or (v164 == "pulltime") or (v164 == "timetopull") or (v164 == "pullbradswilly")) then
		local FlatIdent_2E175 = 0 - 0;
		local v1121;
		while true do
			if (FlatIdent_2E175 == (0 + 0)) then
				function v1121()
					local FlatIdent_2C91A = 462 - (176 + 286);
					local v1155;
					while true do
						if (FlatIdent_2C91A == (2 - 1)) then
							if v1['player']['combat'] then
								v1155 = 931 - (809 + 122);
							end
							return v1155;
						end
						if (FlatIdent_2C91A == (1353 - (787 + 566))) then
							v1155 = 253 - (65 + 188);
							if (TimerTracker and TimerTracker['timerList'][312 - (129 + 182)]) then
								if TimerTracker['timerList'][163 - (122 + 40)]['time'] then
									v1155 = TimerTracker['timerList'][1 + 0]['time'];
								end
							elseif (DBT_Bar_1 and DBT_Bar_1['obj'] and DBT_Bar_1['obj']['timer']) then
								v1155 = DBT_Bar_1['obj']['timer'];
							end
							FlatIdent_2C91A = 1307 - (619 + 687);
						end
					end
				end
				return v1121();
			end
		end
	elseif (v164 == "zoneid") then
		return C_Map.GetBestMapForUnit("player");
	elseif (v164 == "arena") then
		local FlatIdent_8FBF9 = 849 - (566 + 283);
		local v1201;
		while true do
			if (FlatIdent_8FBF9 == (1 + 0)) then
				return v23(v162, v164, v163, v1201, "single");
			end
			if (FlatIdent_8FBF9 == (0 - 0)) then
				v1201 = nil;
				function v1201()
					return v161['instanceType2'] == "arena";
				end
				FlatIdent_8FBF9 = 2 - 1;
			end
		end
	elseif (v164 == "lastcast") then
		return rawget(v161, "lastCast");
	elseif ((v164 == "instance") or (v164 == "instancetype") or (v164 == "isininstance") or (v164 == "instancetype2")) then
		local FlatIdent_7B007 = 0 - 0;
		while true do
			if (FlatIdent_7B007 == (0 + 0)) then
				if (v164 == "instancetype2") then
					local FlatIdent_95F67 = 0 - 0;
					local v1240;
					while true do
						if (FlatIdent_95F67 == (0 - 0)) then
							function v1240()
								return select(767 - (630 + 135), IsInInstance());
							end
							return v23(v162, v164, v163, v1240, "single");
						end
					end
				end
				return v23(v162, v164, v163, IsInInstance, "multiReturn");
			end
		end
	elseif ((v164 == "ourhealer") or (v164 == "friendlyhealer") or (v164 == "healer")) then
		local FlatIdent_CF22 = 0 + 0;
		while true do
			if (FlatIdent_CF22 == (0 + 0)) then
				v161[v162] = v161['internal']['healer'];
				return v161['internal']['healer'];
			end
		end
	elseif ((v164 == "enemyhealer") or (v164 == "theirhealer")) then
		local FlatIdent_54D73 = 1285 - (1026 + 259);
		while true do
			if (FlatIdent_54D73 == (0 + 0)) then
				v161[v162] = v161['internal']['enemyHealer'];
				return v161['internal']['enemyHealer'];
			end
		end
	elseif (v164 == "critters") then
		local FlatIdent_773D7 = 0 - 0;
		local v1249;
		while true do
			if (FlatIdent_773D7 == (212 - (169 + 43))) then
				v1249 = nil;
				function v1249()
					local FlatIdent_181CE = 0 + 0;
					while true do
						if (FlatIdent_181CE == (0 - 0)) then
							v17("critters");
							return v161['internal']['critters'];
						end
					end
				end
				FlatIdent_773D7 = 1 + 0;
			end
			if ((1957 - (1893 + 63)) == FlatIdent_773D7) then
				return v23(v162, v164, v163, v1249, "single");
			end
		end
	elseif (v164 == "tyrants") then
		local FlatIdent_312D5 = 0 - 0;
		local v1252;
		while true do
			if (FlatIdent_312D5 == (0 + 0)) then
				v1252 = nil;
				function v1252()
					local FlatIdent_4F1C4 = 707 - (470 + 237);
					while true do
						if ((0 - 0) == FlatIdent_4F1C4) then
							v17("tyrants");
							return v161['internal']['tyrants'];
						end
					end
				end
				FlatIdent_312D5 = 1 + 0;
			end
			if (FlatIdent_312D5 == (1 - 0)) then
				return v23(v162, v164, v163, v1252, "single");
			end
		end
	elseif (v164 == "rocks") then
		local FlatIdent_753F7 = 332 - (247 + 85);
		local v1253;
		while true do
			if (FlatIdent_753F7 == (478 - (353 + 125))) then
				v1253 = nil;
				function v1253()
					local FlatIdent_6FCA9 = 1600 - (491 + 1109);
					while true do
						if (FlatIdent_6FCA9 == (1992 - (1145 + 847))) then
							v17("rocks");
							return v161['internal']['rocks'];
						end
					end
				end
				FlatIdent_753F7 = 1 + 0;
			end
			if (FlatIdent_753F7 == (1 - 0)) then
				return v23(v162, v164, v163, v1253, "single");
			end
		end
	elseif (v164 == "wwclones") then
		local FlatIdent_585E7 = 595 - (7 + 588);
		local v1257;
		while true do
			if (FlatIdent_585E7 == (4 - 3)) then
				return v23(v162, v164, v163, v1257, "single");
			end
			if ((0 + 0) == FlatIdent_585E7) then
				v1257 = nil;
				function v1257()
					local FlatIdent_2AA9D = 419 - (70 + 349);
					while true do
						if (FlatIdent_2AA9D == (0 + 0)) then
							v17("clones");
							return v161['internal']['wwClones'];
						end
					end
				end
				FlatIdent_585E7 = 220 - (168 + 51);
			end
		end
	elseif (v164 == "explosives") then
		local FlatIdent_1783 = 0 - 0;
		local v1260;
		while true do
			if (FlatIdent_1783 == (2 - 1)) then
				return v23(v162, v164, v163, v1260, "single");
			end
			if (FlatIdent_1783 == (1337 - (428 + 909))) then
				v1260 = nil;
				function v1260()
					local FlatIdent_90C1C = 0 + 0;
					while true do
						if (FlatIdent_90C1C == (0 - 0)) then
							v17("explosives");
							return v161['internal']['explosives'];
						end
					end
				end
				FlatIdent_1783 = 2 - 1;
			end
		end
	elseif (v164 == "incorporeals") then
		local FlatIdent_1F65E = 617 - (119 + 498);
		local v1261;
		while true do
			if (FlatIdent_1F65E == (1 + 0)) then
				return v23(v162, v164, v163, v1261, "single");
			end
			if (FlatIdent_1F65E == (1190 - (176 + 1014))) then
				v1261 = nil;
				function v1261()
					local FlatIdent_66B0A = 0 - 0;
					while true do
						if (FlatIdent_66B0A == (0 + 0)) then
							v17("incorporeals");
							return v161['internal']['incorporeals'];
						end
					end
				end
				FlatIdent_1F65E = 2 - 1;
			end
		end
	elseif (v164 == "afflicteds") then
		local FlatIdent_32A0F = 1682 - (1522 + 160);
		local v1262;
		while true do
			if (FlatIdent_32A0F == (0 - 0)) then
				v1262 = nil;
				function v1262()
					local FlatIdent_2DD33 = 0 - 0;
					while true do
						if (FlatIdent_2DD33 == (0 + 0)) then
							v17("afflicteds");
							return v161['internal']['afflicteds'];
						end
					end
				end
				FlatIdent_32A0F = 1 + 0;
			end
			if (FlatIdent_32A0F == (1 + 0)) then
				return v23(v162, v164, v163, v1262, "single");
			end
		end
	elseif (v164 == "shades") then
		local FlatIdent_43B43 = 0 - 0;
		local v1263;
		while true do
			if (FlatIdent_43B43 == (1150 - (899 + 250))) then
				return v23(v162, v164, v163, v1263, "single");
			end
			if (FlatIdent_43B43 == (147 - (113 + 34))) then
				v1263 = nil;
				function v1263()
					local FlatIdent_576A1 = 1337 - (146 + 1191);
					while true do
						if (FlatIdent_576A1 == (0 + 0)) then
							v17("shades");
							return v161['internal']['shades'];
						end
					end
				end
				FlatIdent_43B43 = 989 - (564 + 424);
			end
		end
	elseif (v164 == "pets") then
		local FlatIdent_4389C = 0 + 0;
		local v1264;
		while true do
			if (FlatIdent_4389C == (1073 - (652 + 421))) then
				v1264 = nil;
				function v1264()
					local FlatIdent_14415 = 0 + 0;
					while true do
						if (FlatIdent_14415 == (0 - 0)) then
							v17("pets");
							return v161['internal']['pets'];
						end
					end
				end
				FlatIdent_4389C = 236 - (101 + 134);
			end
			if (FlatIdent_4389C == (570 - (78 + 491))) then
				return v23(v162, v164, v163, v1264, "single");
			end
		end
	elseif (v164 == "totems") then
		local FlatIdent_437BB = 0 + 0;
		local v1265;
		while true do
			if (FlatIdent_437BB == (1778 - (479 + 1298))) then
				return v23(v162, v164, v163, v1265, "single");
			end
			if ((1484 - (1042 + 442)) == FlatIdent_437BB) then
				v1265 = nil;
				function v1265()
					local FlatIdent_4C438 = 0 - 0;
					while true do
						if ((588 - (251 + 337)) == FlatIdent_4C438) then
							v17("totems");
							return v161['internal']['totems'];
						end
					end
				end
				FlatIdent_437BB = 1746 - (982 + 763);
			end
		end
	elseif (v164 == "friendlytotems") then
		local FlatIdent_3BDA0 = 0 - 0;
		local v1266;
		while true do
			if (FlatIdent_3BDA0 == (1006 - (128 + 877))) then
				return v23(v162, v164, v163, v1266, "single");
			end
			if (FlatIdent_3BDA0 == (0 - 0)) then
				v1266 = nil;
				function v1266()
					local FlatIdent_67A53 = 0 + 0;
					while true do
						if ((0 + 0) == FlatIdent_67A53) then
							v17("friendlyTotems");
							return v161['internal']['friendlyTotems'];
						end
					end
				end
				FlatIdent_3BDA0 = 1 + 0;
			end
		end
	elseif ((v164 == "wildseeds") or (v164 == "seeds")) then
		local FlatIdent_5B2E3 = 692 - (472 + 220);
		local v1267;
		while true do
			if (FlatIdent_5B2E3 == (708 - (413 + 294))) then
				return v23(v162, v164, v163, v1267, "single");
			end
			if (FlatIdent_5B2E3 == (0 - 0)) then
				v1267 = nil;
				function v1267()
					local FlatIdent_1FC5A = 0 - 0;
					while true do
						if (FlatIdent_1FC5A == (0 - 0)) then
							v17("wildseeds");
							return v161['internal']['wildseeds'];
						end
					end
				end
				FlatIdent_5B2E3 = 1793 - (1704 + 88);
			end
		end
	elseif (v164 == "enemypets") then
		local FlatIdent_8E048 = 0 - 0;
		local v1268;
		while true do
			if (FlatIdent_8E048 == (1 + 0)) then
				return v23(v162, v164, v163, v1268, "single");
			end
			if ((0 - 0) == FlatIdent_8E048) then
				v1268 = nil;
				function v1268()
					local FlatIdent_2C96D = 1907 - (444 + 1463);
					while true do
						if (FlatIdent_2C96D == (1425 - (275 + 1150))) then
							v17("enemyPets");
							return v161['internal']['enemyPets'];
						end
					end
				end
				FlatIdent_8E048 = 1 + 0;
			end
		end
	elseif (v164 == "units") then
		local FlatIdent_B41C = 0 - 0;
		local v1269;
		while true do
			if (FlatIdent_B41C == (391 - (128 + 262))) then
				return v23(v162, v164, v163, v1269, "single");
			end
			if (FlatIdent_B41C == (0 + 0)) then
				v1269 = nil;
				function v1269()
					local FlatIdent_3B14E = 824 - (785 + 39);
					while true do
						if ((1615 - (755 + 860)) == FlatIdent_3B14E) then
							v17("units");
							return v161['internal']['units'];
						end
					end
				end
				FlatIdent_B41C = 1062 - (737 + 324);
			end
		end
	elseif (v164 == "dead") then
		local FlatIdent_6730E = 0 - 0;
		local v1270;
		while true do
			if (FlatIdent_6730E == (1243 - (756 + 487))) then
				v1270 = nil;
				function v1270()
					local FlatIdent_74FD1 = 0 - 0;
					while true do
						if (FlatIdent_74FD1 == (0 - 0)) then
							v17("dead");
							return v161['internal']['dead'];
						end
					end
				end
				FlatIdent_6730E = 1 + 0;
			end
			if (FlatIdent_6730E == (1 + 0)) then
				return v23(v162, v164, v163, v1270, "single");
			end
		end
	elseif (v164 == "players") then
		local FlatIdent_10A3C = 1217 - (698 + 519);
		local v1271;
		while true do
			if (FlatIdent_10A3C == (178 - (166 + 12))) then
				v1271 = nil;
				function v1271()
					local FlatIdent_7D8DD = 0 + 0;
					while true do
						if (FlatIdent_7D8DD == (789 - (342 + 447))) then
							v17("players");
							return v161['internal']['players'];
						end
					end
				end
				FlatIdent_10A3C = 1 + 0;
			end
			if (FlatIdent_10A3C == (2 - 1)) then
				return v23(v162, v164, v163, v1271, "single");
			end
		end
	elseif (v164 == "friendlypets") then
		local FlatIdent_6B658 = 0 - 0;
		local v1272;
		while true do
			if (FlatIdent_6B658 == (606 - (301 + 304))) then
				return v23(v162, v164, v163, v1272, "single");
			end
			if (FlatIdent_6B658 == (0 - 0)) then
				v1272 = nil;
				function v1272()
					local FlatIdent_54081 = 0 + 0;
					while true do
						if (FlatIdent_54081 == (0 - 0)) then
							v17("friendlyPets");
							return v161['internal']['friendlyPets'];
						end
					end
				end
				FlatIdent_6B658 = 1 + 0;
			end
		end
	elseif ((v164 == "triggers") or (v164 == "areatriggers")) then
		local FlatIdent_32960 = 0 + 0;
		local v1273;
		while true do
			if (FlatIdent_32960 == (1 + 0)) then
				return v23(v162, v164, v163, v1273, "single");
			end
			if (FlatIdent_32960 == (0 + 0)) then
				v1273 = nil;
				function v1273()
					local FlatIdent_2F5BC = 0 + 0;
					while true do
						if ((64 - (41 + 23)) == FlatIdent_2F5BC) then
							v17("areaTriggers");
							return v161['internal']['areaTriggers'];
						end
					end
				end
				FlatIdent_32960 = 2 - 1;
			end
		end
	elseif (v164 == "imps") then
		local FlatIdent_29F0 = 0 - 0;
		local v1274;
		while true do
			if (FlatIdent_29F0 == (621 - (51 + 570))) then
				v1274 = nil;
				function v1274()
					local FlatIdent_11022 = 0 + 0;
					while true do
						if (FlatIdent_11022 == (0 + 0)) then
							v17("imps");
							return v161['internal']['imps'];
						end
					end
				end
				FlatIdent_29F0 = 1 + 0;
			end
			if (FlatIdent_29F0 == (1 - 0)) then
				return v23(v162, v164, v163, v1274, "single");
			end
		end
	elseif (v164 == "enemies") then
		local FlatIdent_20465 = 1861 - (1728 + 133);
		local v1275;
		while true do
			if (FlatIdent_20465 == (0 + 0)) then
				v1275 = nil;
				function v1275()
					local FlatIdent_18A5B = 1543 - (471 + 1072);
					while true do
						if (FlatIdent_18A5B == (0 + 0)) then
							v17("enemies");
							return v161['internal']['enemies'];
						end
					end
				end
				FlatIdent_20465 = 1563 - (240 + 1322);
			end
			if (FlatIdent_20465 == (939 - (548 + 390))) then
				return v23(v162, v164, v163, v1275, "single");
			end
		end
	elseif (v164 == "allenemies") then
		local FlatIdent_696A5 = 1713 - (217 + 1496);
		local v1276;
		while true do
			if (FlatIdent_696A5 == (4 - 3)) then
				return v23(v162, v164, v163, v1276, "single");
			end
			if (FlatIdent_696A5 == (201 - (72 + 129))) then
				v1276 = nil;
				function v1276()
					local FlatIdent_6469C = 1117 - (518 + 599);
					while true do
						if ((1273 - (389 + 884)) == FlatIdent_6469C) then
							v17("allEnemies");
							return v161['internal']['allEnemies'];
						end
					end
				end
				FlatIdent_696A5 = 1 + 0;
			end
		end
	elseif (v164 == "friends") then
		local FlatIdent_37185 = 0 - 0;
		local v1277;
		while true do
			if (FlatIdent_37185 == (0 + 0)) then
				v1277 = nil;
				function v1277()
					local FlatIdent_5B968 = 0 + 0;
					while true do
						if (FlatIdent_5B968 == (0 + 0)) then
							v17("friends");
							return v161['internal']['friends'];
						end
					end
				end
				FlatIdent_37185 = 2 - 1;
			end
			if (FlatIdent_37185 == (1 + 0)) then
				return v23(v162, v164, v163, v1277, "single");
			end
		end
	elseif ((v164 == "dynamicobjects") or (v164 == "dobjects")) then
		local FlatIdent_24DE5 = 0 + 0;
		local v1278;
		while true do
			if (FlatIdent_24DE5 == (4 - 3)) then
				return v23(v162, v164, v163, v1278, "single");
			end
			if ((1326 - (441 + 885)) == FlatIdent_24DE5) then
				v1278 = nil;
				function v1278()
					local FlatIdent_64B62 = 0 - 0;
					while true do
						if (FlatIdent_64B62 == (0 + 0)) then
							v17("dynamicObjects");
							return v161['internal']['dynamicObjects'];
						end
					end
				end
				FlatIdent_24DE5 = 2 - 1;
			end
		end
	elseif (v164 == "objects") then
		local FlatIdent_4AC5B = 1473 - (1452 + 21);
		local v1279;
		while true do
			if (FlatIdent_4AC5B == (48 - (15 + 32))) then
				return v23(v162, v164, v163, v1279, "single");
			end
			if (FlatIdent_4AC5B == (1580 - (666 + 914))) then
				v1279 = nil;
				function v1279()
					local FlatIdent_95C60 = 0 + 0;
					while true do
						if (FlatIdent_95C60 == (1513 - (146 + 1367))) then
							v17("objects");
							return v161['internal']['objects'];
						end
					end
				end
				FlatIdent_4AC5B = 1 + 0;
			end
		end
	elseif (v164 == "mouseover") then
		local FlatIdent_72637 = 0 - 0;
		while true do
			if (FlatIdent_72637 == (0 - 0)) then
				v161[v162] = v161['internal']['mouseover'];
				return v161['internal']['mouseover'];
			end
		end
	elseif (v164 == "player") then
		local FlatIdent_15EED = 0 - 0;
		while true do
			if (FlatIdent_15EED == (99 - (91 + 8))) then
				v161[v162] = v161['internal']['player'];
				return v161['internal']['player'];
			end
		end
	elseif (v164 == "pet") then
		local FlatIdent_1986B = 901 - (738 + 163);
		while true do
			if (FlatIdent_1986B == (171 - (81 + 90))) then
				v161[v162] = v161['internal']['pet'];
				return v161['internal']['pet'];
			end
		end
	elseif (v164 == "target") then
		local FlatIdent_12746 = 0 + 0;
		while true do
			if (FlatIdent_12746 == (0 + 0)) then
				v161[v162] = v161['internal']['target'];
				return v161['internal']['target'];
			end
		end
	elseif (v164 == "focus") then
		local FlatIdent_15B86 = 1463 - (355 + 1108);
		while true do
			if (FlatIdent_15B86 == (0 - 0)) then
				v161[v162] = v161['internal']['focus'];
				return v161['internal']['focus'];
			end
		end
	elseif (v164 == "group") then
		local FlatIdent_3A426 = 1839 - (992 + 847);
		local v1290;
		while true do
			if (FlatIdent_3A426 == (0 + 0)) then
				v1290 = nil;
				function v1290()
					return v161['internal']['group'] or {};
				end
				FlatIdent_3A426 = 1 + 0;
			end
			if (FlatIdent_3A426 == (2 - 1)) then
				return v23(v162, v164, v163, v1290, "single");
			end
		end
	elseif ((v164 == "arena1") or (v164 == "arena2") or (v164 == "arena3") or (v164 == "arena4") or (v164 == "arena5") or (v164 == "party1") or (v164 == "party2") or (v164 == "party3") or (v164 == "party4") or (v164 == "boss1") or (v164 == "boss2") or (v164 == "boss3") or (v164 == "boss4")) then
		local FlatIdent_7DFE1 = 55 - (23 + 32);
		while true do
			if (FlatIdent_7DFE1 == (0 - 0)) then
				v161[v162] = v161['internal'][v164];
				return v161['internal'][v164];
			end
		end
	elseif ((v164 == "fullgroup") or (v164 == "fgroup")) then
		local FlatIdent_26CAB = 0 - 0;
		local v1293;
		while true do
			if ((262 - (171 + 91)) == FlatIdent_26CAB) then
				v1293 = nil;
				function v1293()
					return v161['internal']['fullGroup'];
				end
				FlatIdent_26CAB = 431 - (366 + 64);
			end
			if (FlatIdent_26CAB == (1 + 0)) then
				return v23(v162, v164, v163, v1293, "single");
			end
		end
	elseif (v164 == "missiles") then
		if v0['Util']['Draw'] then
			local FlatIdent_9CEB = 0 - 0;
			while true do
				if ((0 + 0) == FlatIdent_9CEB) then
					if not v161['internal']['loaded']['missiles'] then
						local FlatIdent_E63B = 0 + 0;
						local v1295;
						while true do
							if (FlatIdent_E63B == (0 - 0)) then
								v1295 = #v161['internal']['missiles'];
								for v1297 in v3:Missiles() do
									local FlatIdent_7F137 = 0 + 0;
									while true do
										if ((1551 - (740 + 811)) == FlatIdent_7F137) then
											v161['internal']['missiles'][v1295 + 1 + 0] = v1297;
											v1295 = v1295 + 1 + 0;
											break;
										end
									end
								end
								FlatIdent_E63B = 1 + 0;
							end
							if (FlatIdent_E63B == (1 + 0)) then
								v161['internal']['loaded']['missiles'] = true;
								break;
							end
						end
					end
					return v161['internal']['missiles'];
				end
			end
		elseif (GetMissileCount and GetMissileWithIndex) then
			local FlatIdent_978B1 = 0 + 0;
			while true do
				if (FlatIdent_978B1 == (0 + 0)) then
					if not v161['internal']['loaded']['missiles'] then
						local FlatIdent_5758B = 585 - (451 + 134);
						local v1299;
						while true do
							if (FlatIdent_5758B == (0 + 0)) then
								v1299 = GetMissileCount();
								for v1300 = 440 - (196 + 243), v1299 do
									local FlatIdent_8D9F4 = 0 - 0;
									local v1301;
									local v1302;
									local v1303;
									local v1304;
									local v1305;
									local v1306;
									local v1307;
									local v1308;
									local v1309;
									local v1310;
									local v1311;
									local v1312;
									local v1313;
									local v1314;
									while true do
										if (FlatIdent_8D9F4 == (879 - (700 + 178))) then
											v161['internal']['missiles'][#v161['internal']['missiles'] + (3 - 2)] = v1314;
											break;
										end
										if ((0 - 0) == FlatIdent_8D9F4) then
											v1301, v1302, v1303, v1304, v1305, v1306, v1307, v1308, v1309, v1310, v1311, v1312, v1313 = GetMissileWithIndex(v1300);
											v1314 = {source=v1306,target=v1310,spellId=v1301,mx=v1303,my=v1304,mz=v1305,cx=v1303,cy=v1304,cz=v1305,ix=v1307,iy=v1308,iz=v1309,tx=v1311,ty=v1312,tz=v1313};
											FlatIdent_8D9F4 = 1 + 0;
										end
									end
								end
								break;
							end
						end
					end
					return v161['internal']['missiles'];
				end
			end
		end
	elseif ((v164 == "ingroup") or (v164 == "grouptype")) then
		local FlatIdent_E0CC = 725 - (212 + 513);
		local v1294;
		while true do
			if (FlatIdent_E0CC == (1548 - (44 + 1504))) then
				v1294 = nil;
				function v1294()
					return (v161['arena'] and "party") or (UnitInRaid("player") and "raid") or (UnitInParty("player") and "party");
				end
				FlatIdent_E0CC = 1 + 0;
			end
			if ((1 + 0) == FlatIdent_E0CC) then
				return v23(v162, v164, v163, v1294);
			end
		end
	elseif ((v164 == "hello") or (v164 == "helloworld")) then
		return "Ohhh wowie, you made it! How are you? Don't respond, that's weird.";
	elseif (v164 == "instancetype") then
		return v161['instance2'];
	elseif ((v164 == "enemiesaround") or (v164 == "enemiesaroundpoint") or (v164 == "enemiesaroundposition")) then
		return v161['internal']['enemiesAroundPoint'];
	end
	if v161['internal'][v164] then
		return v161['internal'][v164];
	else
		return rawget(v161, v162);
	end
end};
setmetatable(v1, v25);
v1['enabledCallbacks'] = {};
v1['updateCallbacks'] = {};
v1.addUpdateCallback = function(v165, v166)
	local FlatIdent_90C1B = 0 + 0;
	while true do
		if (FlatIdent_90C1B == (0 - 0)) then
			if v166 then
				v4(v1.enabledCallbacks, v165);
			else
				v4(v1.updateCallbacks, v165);
			end
			return {cancel=function()
				if v166 then
					for v977 = 1173 - (1022 + 150), #v1['enabledCallbacks'] do
						if (v1['enabledCallbacks'][v977] == v165) then
							v18(v1.enabledCallbacks, v977);
							break;
						end
					end
				else
					for v978 = 1 - 0, #v1['updateCallbacks'] do
						if (v1['updateCallbacks'][v978] == v165) then
							v18(v1.updateCallbacks, v978);
							break;
						end
					end
				end
			end};
		end
	end
end;
v1['onTick'] = v1['addUpdateCallback'];
v1['ontick'] = v1['onTick'];
v1['actualUpdateCallbacks'] = {};
v1['actualEnabledUpdateCallbacks'] = {};
v1.addActualUpdateCallback = function(v167, v168)
	if v168 then
		v4(v1.actualEnabledUpdateCallbacks, v167);
	else
		v4(v1.actualUpdateCallbacks, v167);
	end
end;
v1['onUpdate'] = v1['addActualUpdateCallback'];
v1['onupdate'] = v1['onUpdate'];
local v36 = {libs={},minors={}};
local v37 = v36;
v36['minor'] = LIBSTUB_MINOR;
v36.NewLibrary = function(v169, v170, v171)
	local FlatIdent_804B1 = 1395 - (1377 + 18);
	local v172;
	while true do
		if (FlatIdent_804B1 == (1 + 1)) then
			v169['minors'][v170], v169['libs'][v170] = v171, v169['libs'][v170] or {};
			return v169['libs'][v170], v172;
		end
		if (FlatIdent_804B1 == (1 + 0)) then
			v172 = v169['minors'][v170];
			if (v172 and (v172 >= v171)) then
				return nil;
			end
			FlatIdent_804B1 = 1 + 1;
		end
		if ((772 - (311 + 461)) == FlatIdent_804B1) then
			assert(v5(v170) == "string", "Bad argument #2 to `NewLibrary' (string expected)");
			v171 = assert(tonumber(strmatch(v171, "%d+")), "Minor version must either be a number or contain a number.");
			FlatIdent_804B1 = 1 - 0;
		end
	end
end;
v36.GetLibrary = function(v175, v176, v177)
	local FlatIdent_B002 = 0 - 0;
	while true do
		if (FlatIdent_B002 == (0 - 0)) then
			if (not v175['libs'][v176] and not v177) then
				error(("Cannot find a library instance of %q."):format(tostring(v176)), 1870 - (1565 + 303));
			end
			return v175['libs'][v176], v175['minors'][v176];
		end
	end
end;
v36.IterateLibraries = function(v178)
	return pairs(v178.libs);
end;
setmetatable(v36, {__call=v36['GetLibrary']});
do
	local v179, v180 = "CallbackHandler-1.0", 5 + 1;
	local v181 = v36:NewLibrary(v179, v180);
	if not v181 then
		return;
	end
	local v182 = {__index=function(v381, v382)
		local FlatIdent_9847B = 0 - 0;
		while true do
			if (FlatIdent_9847B == (397 - (187 + 210))) then
				v381[v382] = {};
				return v381[v382];
			end
		end
	end};
	local v183 = table['concat'];
	local v184, v185, v186 = assert, error, loadstring;
	local v187, v188, v189 = setmetatable, rawset, rawget;
	local v190, v191, v192, v193, v194 = next, select, pairs, v5, tostring;
	local v195 = xpcall;
	local function v196(v384)
		return geterrorhandler()(v384);
	end
	local function v197(v385)
		local FlatIdent_35CBE = 0 - 0;
		local v386;
		local v387;
		local v388;
		while true do
			if (FlatIdent_35CBE == (2 - 0)) then
				return v184(v186(v386, "safecall Dispatcher[" .. v385 .. "]"))(v190, v195, v196);
			end
			if (FlatIdent_35CBE == (0 + 0)) then
				v386 = [[
		local next, xpcall, eh = ...
		local method, ARGS
		local function call() method(ARGS) end
		local function dispatch(handlers, ...)
			local index
			index, method = next(handlers)
			if not method then return end
			local OLD_ARGS = ARGS
			ARGS = ...
			repeat
				xpcall(call, eh)
				index, method = next(handlers, index)
			until not method
			ARGS = OLD_ARGS
		end
		return dispatch
		]];
				v387, v388 = {}, {};
				FlatIdent_35CBE = 1 - 0;
			end
			if ((1608 - (1144 + 463)) == FlatIdent_35CBE) then
				for v640 = 444 - (423 + 20), v385 do
					v387[v640], v388[v640] = "arg" .. v640, "old_arg" .. v640;
				end
				v386 = v386:gsub("OLD_ARGS", v183(v388, ", ")):gsub("ARGS", v183(v387, ", "));
				FlatIdent_35CBE = 1 + 1;
			end
		end
	end
	local v198 = v187({}, {__index=function(v389, v390)
		local FlatIdent_2E3A = 0 + 0;
		local v391;
		while true do
			if (FlatIdent_2E3A == (3 - 2)) then
				return v391;
			end
			if (FlatIdent_2E3A == (0 - 0)) then
				v391 = v197(v390);
				v188(v389, v390, v391);
				FlatIdent_2E3A = 2 - 1;
			end
		end
	end});
	v181.New = function(v392, v393, v394, v395, v396, v397, v398)
		v184(not v397 and not v398, "ACE-80: OnUsed/OnUnused are deprecated. Callbacks are now done to registry.OnUsed and registry.OnUnused");
		v394 = v394 or "RegisterCallback";
		v395 = v395 or "UnregisterCallback";
		if (v396 == nil) then
			v396 = "UnregisterAllCallbacks";
		end
		local v399 = v187({}, v182);
		local v400 = {recurse=(0 - 0),events=v399};
		v400.Fire = function(v643, v644, ...)
			local FlatIdent_501DB = 402 - (379 + 23);
			local v645;
			while true do
				if (FlatIdent_501DB == (1 + 0)) then
					v400['recurse'] = v645 + (2 - 1);
					v198[v191("#", ...) + (4 - 3)](v399[v644], v644, ...);
					FlatIdent_501DB = 185 - (51 + 132);
				end
				if (FlatIdent_501DB == (3 - 1)) then
					v400['recurse'] = v645;
					if (v400['insertQueue'] and (v645 == (0 - 0))) then
						local FlatIdent_3E213 = 0 + 0;
						while true do
							if (FlatIdent_3E213 == (0 + 0)) then
								for v1088, v1089 in v192(v400.insertQueue) do
									local FlatIdent_277B5 = 1774 - (194 + 1580);
									local v1090;
									while true do
										if (FlatIdent_277B5 == (0 + 0)) then
											v1090 = not v189(v399, v1088) or not v190(v399[v1088]);
											for v1122, v1123 in v192(v1089) do
												local FlatIdent_F4CB = 1588 - (294 + 1294);
												while true do
													if ((0 + 0) == FlatIdent_F4CB) then
														v399[v1088][v1122] = v1123;
														if (v1090 and v400['OnUsed']) then
															local FlatIdent_14F9F = 1944 - (1758 + 186);
															while true do
																if (FlatIdent_14F9F == (0 + 0)) then
																	v400.OnUsed(v400, v393, v1088);
																	v1090 = nil;
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
								v400['insertQueue'] = nil;
								break;
							end
						end
					end
					break;
				end
				if (FlatIdent_501DB == (0 - 0)) then
					if (not v189(v399, v644) or not v190(v399[v644])) then
						return;
					end
					v645 = v400['recurse'];
					FlatIdent_501DB = 1 + 0;
				end
			end
		end;
		v393[v394] = function(v647, v648, v649, ...)
			local FlatIdent_49805 = 698 - (217 + 481);
			local v650;
			local v651;
			while true do
				if (FlatIdent_49805 == (1 + 0)) then
					v650 = not v189(v399, v648) or not v190(v399[v648]);
					if ((v193(v649) ~= "string") and (v193(v649) ~= "function")) then
						v185("Usage: " .. v394 .. '("eventname", "methodname"): \'methodname\' - string or function expected.', 273 - (225 + 46));
					end
					FlatIdent_49805 = 1904 - (1249 + 653);
				end
				if (FlatIdent_49805 == (2 + 0)) then
					v651 = nil;
					if (v193(v649) == "string") then
						local FlatIdent_3CCBE = 0 + 0;
						while true do
							if (FlatIdent_3CCBE == (0 + 0)) then
								if (v193(v647) ~= "table") then
									v185("Usage: " .. v394 .. '("eventname", "methodname"): self was not a table?', 1 + 1);
								elseif (v647 == v393) then
									v185("Usage: " .. v394 .. '("eventname", "methodname"): do not use Library:' .. v394 .. "(), use your own 'self'", 1 + 1);
								elseif (v193(v647[v649]) ~= "function") then
									v185("Usage: " .. v394 .. '("eventname", "methodname"): \'methodname\' - method \'' .. v194(v649) .. "' not found on self.", 5 - 3);
								end
								if (v191("#", ...) >= (1 + 0)) then
									local FlatIdent_15C5A = 0 + 0;
									local v1125;
									while true do
										if (FlatIdent_15C5A == (0 - 0)) then
											v1125 = v191(1 + 0, ...);
											function v651(...)
												v647[v649](v647, v1125, ...);
											end
											break;
										end
									end
								else
									function v651(...)
										v647[v649](v647, ...);
									end
								end
								break;
							end
						end
					else
						local FlatIdent_60F86 = 0 + 0;
						while true do
							if (FlatIdent_60F86 == (600 - (14 + 586))) then
								if ((v193(v647) ~= "table") and (v193(v647) ~= "string") and (v193(v647) ~= "thread")) then
									v185("Usage: " .. v394 .. '(self or \"addonId\", eventname, method): \'self or addonId\': table or string or thread expected.', 2 + 0);
								end
								if (v191("#", ...) >= (1 + 0)) then
									local FlatIdent_4098 = 0 + 0;
									local v1126;
									while true do
										if ((0 + 0) == FlatIdent_4098) then
											v1126 = v191(1 - 0, ...);
											function v651(...)
												v649(v1126, ...);
											end
											break;
										end
									end
								else
									v651 = v649;
								end
								break;
							end
						end
					end
					FlatIdent_49805 = 106 - (85 + 18);
				end
				if (FlatIdent_49805 == (3 + 0)) then
					if (v399[v648][v647] or (v400['recurse'] < (954 - (881 + 72)))) then
						local FlatIdent_4564C = 959 - (443 + 516);
						while true do
							if (FlatIdent_4564C == (73 - (11 + 62))) then
								v399[v648][v647] = v651;
								if (v400['OnUsed'] and v650) then
									v400.OnUsed(v400, v393, v648);
								end
								break;
							end
						end
					else
						local FlatIdent_9367D = 0 + 0;
						while true do
							if (FlatIdent_9367D == (0 + 0)) then
								v400['insertQueue'] = v400['insertQueue'] or v187({}, v182);
								v400['insertQueue'][v648][v647] = v651;
								break;
							end
						end
					end
					break;
				end
				if (FlatIdent_49805 == (0 - 0)) then
					if (v193(v648) ~= "string") then
						v185("Usage: " .. v394 .. "(eventname, method[, arg]): 'eventname' - string expected.", 2 - 0);
					end
					v649 = v649 or v648;
					FlatIdent_49805 = 1 - 0;
				end
			end
		end;
		v393[v395] = function(v652, v653)
			local FlatIdent_2E14C = 0 - 0;
			while true do
				if ((1 + 0) == FlatIdent_2E14C) then
					if (v189(v399, v653) and v399[v653][v652]) then
						local FlatIdent_953E8 = 0 - 0;
						while true do
							if (FlatIdent_953E8 == (0 + 0)) then
								v399[v653][v652] = nil;
								if (v400['OnUnused'] and not v190(v399[v653])) then
									v400.OnUnused(v400, v393, v653);
								end
								break;
							end
						end
					end
					if (v400['insertQueue'] and v189(v400.insertQueue, v653) and v400['insertQueue'][v653][v652]) then
						v400['insertQueue'][v653][v652] = nil;
					end
					break;
				end
				if (FlatIdent_2E14C == (0 - 0)) then
					if (not v652 or (v652 == v393)) then
						v185("Usage: " .. v395 .. "(eventname): bad 'self'", 5 - 3);
					end
					if (v193(v653) ~= "string") then
						v185("Usage: " .. v395 .. "(eventname): 'eventname' - string expected.", 1 + 1);
					end
					FlatIdent_2E14C = 1 + 0;
				end
			end
		end;
		if v396 then
			v393[v396] = function(...)
				local FlatIdent_97CD8 = 0 - 0;
				while true do
					if (FlatIdent_97CD8 == (550 - (84 + 465))) then
						for v1091 = 339 - (60 + 278), v191("#", ...) do
							local FlatIdent_82218 = 0 + 0;
							local v1092;
							while true do
								if (FlatIdent_82218 == (2 - 1)) then
									for v1127, v1128 in v192(v399) do
										if v1128[v1092] then
											local FlatIdent_411B8 = 1689 - (1568 + 121);
											while true do
												if (FlatIdent_411B8 == (1233 - (1082 + 151))) then
													v1128[v1092] = nil;
													if (v400['OnUnused'] and not v190(v1128)) then
														v400.OnUnused(v400, v393, v1127);
													end
													break;
												end
											end
										end
									end
									break;
								end
								if (FlatIdent_82218 == (0 - 0)) then
									v1092 = v191(v1091, ...);
									if v400['insertQueue'] then
										for v1185, v1186 in v192(v400.insertQueue) do
											if v1186[v1092] then
												v1186[v1092] = nil;
											end
										end
									end
									FlatIdent_82218 = 1076 - (116 + 959);
								end
							end
						end
						break;
					end
					if (FlatIdent_97CD8 == (0 - 0)) then
						if (v191("#", ...) < (1688 - (357 + 1330))) then
							v185("Usage: " .. v396 .. '([whatFor]): missing \'self\' or \"addonId\" to unregister events for.', 2 + 0);
						end
						if ((v191("#", ...) == (1 + 0)) and (... == v393)) then
							v185("Usage: " .. v396 .. '([whatFor]): supply a meaningful \'self\' or \"addonId\"', 2 + 0);
						end
						FlatIdent_97CD8 = 1288 - (861 + 426);
					end
				end
			end;
		end
		return v400;
	end;
end
if (v1['gameVersion'] == (1 + 0)) then
	local v404 = "LibInspect";
	local v405 = {version=(17 + 52)};
	v405['events'] = v405['events'] or v36("CallbackHandler-1.0"):New(v405);
	if not v405['events'] then
		error("LibInspect requires CallbackHandler");
	end
	local v407 = "GroupInSpecT_Update";
	local v408 = "GroupInSpecT_Remove";
	local v409 = "GroupInSpecT_InspectReady";
	local v410 = "GroupInSpecT_QueueChanged";
	local v411 = "LGIST11";
	local v412 = "1";
	local v413 = "\a";
	local v414 = 1.5 + 0;
	local v415 = 4 + 6;
	local v416 = 1 + 1;
	v405['events'].OnUsed = function(v654, v655, v656)
		if (v656 == v409) then
			v655['inspect_ready_used'] = true;
		end
	end;
	v405['events'].OnUnused = function(v657, v658, v659)
		if (v659 == v409) then
			v658['inspect_ready_used'] = nil;
		end
	end;
	local v419 = _G[v404 .. "_Frame"] or CreateFrame("Frame", v404 .. "_Frame");
	v405['frame'] = v419;
	v419:Hide();
	v419:UnregisterAllEvents();
	v419:RegisterEvent("PLAYER_LOGIN");
	v419:RegisterEvent("PLAYER_LOGOUT");
	if not v419['OnEvent'] then
		local FlatIdent_281CC = 894 - (593 + 301);
		while true do
			if (FlatIdent_281CC == (0 + 0)) then
				v419.OnEvent = function(v987, v988, ...)
					local FlatIdent_29290 = 1226 - (133 + 1093);
					local v989;
					while true do
						if (FlatIdent_29290 == (0 + 0)) then
							v989 = v405[v988];
							return v989 and v989(v405, ...);
						end
					end
				end;
				v419:SetScript("OnEvent", v419.OnEvent);
				break;
			end
		end
	end
	v405['state'] = {mainq={},staleq={},t=(1876 - (1085 + 791)),last_inspect=(0 + 0),current_guid=nil,throttle=(1189 - (312 + 877)),tt=(0 - 0),debounce_send_update=(1862 - (388 + 1474))};
	v405['cache'] = {};
	v405['static_cache'] = {};
	if not v405['hooked'] then
		local FlatIdent_8DBA2 = 0 - 0;
		while true do
			if (FlatIdent_8DBA2 == (0 - 0)) then
				hooksecurefunc("NotifyInspect", function(...)
					return v405:NotifyInspect(...);
				end);
				v405['hooked'] = true;
				break;
			end
		end
	end
	v405.NotifyInspect = function(v660, v661)
		v660['state']['last_inspect'] = GetTime();
	end;
	local v425 = _G['CanInspect'];
	local v426 = _G['ClearInspectPlayer'];
	local v427 = _G['GetClassInfo'];
	local v428 = _G['GetNumSubgroupMembers'];
	local v429 = _G['GetNumSpecializationsForClassID'];
	local v430 = _G['GetPlayerInfoByGUID'];
	local v431 = _G['C_SpecializationInfo']['GetInspectSelectedPvpTalent'];
	local v432 = _G['GetInspectSpecialization'];
	local v433 = _G['GetSpecialization'];
	local v434 = _G['GetSpecializationInfo'];
	local v435 = _G['GetSpecializationInfoForClassID'];
	local v436 = _G['GetSpecializationRoleByID'];
	local v437 = _G['GetPvpTalentInfoByID'];
	local v438 = _G['C_SpecializationInfo']['GetPvpTalentSlotInfo'];
	local v439 = _G['GetTalentInfo'];
	local v440 = _G['GetTalentInfoByID'];
	local v441 = _G['IsInRaid'];
	local v442 = _G['GetNumClasses'];
	local v443 = _G['UnitExists'];
	local v444 = _G['UnitGUID'];
	local v445 = _G['UnitInParty'];
	local v446 = _G['UnitInRaid'];
	local v447 = _G['UnitIsConnected'];
	local v448 = _G['UnitIsPlayer'];
	local v449 = _G['UnitIsUnit'];
	local v450 = _G['UnitName'];
	local v451 = _G['C_ChatInfo']['SendAddonMessage'];
	local v452 = _G['C_ChatInfo']['RegisterAddonMessagePrefix'];
	local v453 = _G['MAX_TALENT_TIERS'];
	local v454 = _G['NUM_TALENT_COLUMNS'];
	local v455 = 18 - 14;
	local v456 = {[377 - 127]="tank",[35 + 216]="melee",[1382 - (579 + 551)]="melee",[1221 - 644]="melee",[1383 - (511 + 291)]="tank",[896 - (292 + 502)]="ranged",[1569 - (600 + 866)]="melee",[344 - 240]="tank",[25 + 80]="healer",[2021 - (1534 + 234)]="ranged",[103 + 151]="ranged",[1813 - (908 + 650)]="melee",[832 - (633 + 137)]="ranged",[156 - 93]="ranged",[563 - (194 + 305)]="ranged",[1439 - (559 + 612)]="tank",[307 - (14 + 24)]="melee",[120 + 150]="healer",[883 - (580 + 238)]="healer",[471 - (329 + 76)]="tank",[54 + 16]="melee",[1513 - (1017 + 240)]="healer",[52 + 205]="healer",[118 + 140]="ranged",[736 - 477]="melee",[7 + 253]="melee",[76 + 185]="melee",[651 - 389]="ranged",[727 - 464]="melee",[216 + 48]="healer",[2178 - (714 + 1199)]="ranged",[324 - 58]="ranged",[2 + 265]="ranged",[218 - (68 + 79)]="melee",[30 + 42]="melee",[182 - 109]="tank",[379 + 1094]="ranged",[4699 - 3232]="ranged",[4012 - 2544]="healer"};
	local v457 = {HUNTER="DAMAGER",MAGE="DAMAGER",ROGUE="DAMAGER",WARLOCK="DAMAGER"};
	local v458 = {MAGE="ranged",ROGUE="melee",WARLOCK="ranged"};
	v405.PLAYER_LOGIN = function(v663)
		local FlatIdent_84D5F = 0 + 0;
		local v665;
		local v666;
		while true do
			if ((1519 - (392 + 1125)) == FlatIdent_84D5F) then
				v419:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
				v419:RegisterEvent("UNIT_NAME_UPDATE");
				v419:RegisterEvent("UNIT_AURA");
				v419:RegisterEvent("CHAT_MSG_ADDON");
				FlatIdent_84D5F = 1 + 2;
			end
			if (FlatIdent_84D5F == (0 + 0)) then
				v663['state']['logged_in'] = true;
				v663:CacheGameData();
				v419:RegisterEvent("INSPECT_READY");
				v419:RegisterEvent("GROUP_ROSTER_UPDATE");
				FlatIdent_84D5F = 2 - 1;
			end
			if (FlatIdent_84D5F == (1961 - (475 + 1485))) then
				v419:RegisterEvent("PLAYER_ENTERING_WORLD");
				v419:RegisterEvent("UNIT_LEVEL");
				v419:RegisterEvent("PLAYER_TALENT_UPDATE");
				v419:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
				FlatIdent_84D5F = 2 + 0;
			end
			if (FlatIdent_84D5F == (12 - 9)) then
				v452(v411);
				v665 = v444("player");
				v666 = v663:BuildInfo("player");
				v663['events']:Fire(v407, v665, "player", v666);
				break;
			end
		end
	end;
	v405.PLAYER_LOGOUT = function(v667)
		v667['state']['logged_in'] = false;
	end;
	v405['state']['t'] = 0 + 0;
	if not v419['OnUpdate'] then
		local FlatIdent_5440E = 0 + 0;
		while true do
			if (FlatIdent_5440E == (908 - (129 + 779))) then
				v419.OnUpdate = function(v990, v991)
					local FlatIdent_90370 = 0 - 0;
					while true do
						if (FlatIdent_90370 == (0 + 0)) then
							v405['state']['t'] = v405['state']['t'] + v991;
							v405['state']['tt'] = v405['state']['tt'] + v991;
							FlatIdent_90370 = 94 - (31 + 62);
						end
						if (FlatIdent_90370 == (481 - (395 + 84))) then
							if (v405['state']['debounce_send_update'] > (0 + 0)) then
								local FlatIdent_8F8D3 = 0 - 0;
								local v1132;
								while true do
									if (FlatIdent_8F8D3 == (0 - 0)) then
										v1132 = v405['state']['debounce_send_update'] - v991;
										v405['state']['debounce_send_update'] = v1132;
										FlatIdent_8F8D3 = 3 - 2;
									end
									if (FlatIdent_8F8D3 == (1 - 0)) then
										if (v1132 <= (0 + 0)) then
											v405:SendLatestSpecData();
										end
										break;
									end
								end
							end
							break;
						end
						if (FlatIdent_90370 == (502 - (249 + 252))) then
							if (v405['state']['t'] > v414) then
								local FlatIdent_15302 = 1972 - (86 + 1886);
								while true do
									if ((0 - 0) == FlatIdent_15302) then
										v405:ProcessQueues();
										v405['state']['t'] = 152 - (85 + 67);
										break;
									end
								end
							end
							if ((v405['state']['tt'] > (662 - (624 + 35))) and (v405['state']['throttle'] > (0 - 0))) then
								local FlatIdent_25CB3 = 0 + 0;
								while true do
									if ((0 + 0) == FlatIdent_25CB3) then
										v405['state']['throttle'] = v405['state']['throttle'] - (977 - (531 + 445));
										v405['state']['tt'] = 0 - 0;
										break;
									end
								end
							end
							FlatIdent_90370 = 1493 - (183 + 1308);
						end
					end
				end;
				v419:SetScript("OnUpdate", v419.OnUpdate);
				break;
			end
		end
	end
	v405['static_cache']['global_specs'] = {};
	v405['static_cache']['class_to_class_id'] = {};
	v405['static_cache']['talents'] = {};
	v405['static_cache']['pvp_talents'] = {};
	v405.GetCachedTalentInfo = function(v669, v670, v671, v672, v673, v674, v675)
		local FlatIdent_7D6BF = 0 + 0;
		local v676;
		local v677;
		local v678;
		local v679;
		local v680;
		local v681;
		local v682;
		while true do
			if ((0 + 0) == FlatIdent_7D6BF) then
				v676, v677, v678, v679, v680, v681 = v439(v671, v672, v673, v674, v675);
				if not v676 then
					return {};
				end
				FlatIdent_7D6BF = 1 + 0;
			end
			if (FlatIdent_7D6BF == (681 - (453 + 226))) then
				return v682[v676], v679;
			end
			if (FlatIdent_7D6BF == (1 + 0)) then
				v682 = v669['static_cache']['talents'];
				if not v682[v676] then
					v682[v676] = {spell_id=v681,talent_id=v676,name_localized=v677,icon=v678,tier=v671,column=v672};
				end
				FlatIdent_7D6BF = 2 + 0;
			end
		end
	end;
	v405.GetCachedTalentInfoByID = function(v683, v684)
		local FlatIdent_2C446 = 0 - 0;
		local v685;
		while true do
			if (FlatIdent_2C446 == (1 + 0)) then
				return v685[v684];
			end
			if (FlatIdent_2C446 == (0 - 0)) then
				v685 = v683['static_cache']['talents'];
				if (v684 and not v685[v684]) then
					local FlatIdent_3994D = 0 - 0;
					local v995;
					local v996;
					local v997;
					local v998;
					local v999;
					local v1000;
					while true do
						if (FlatIdent_3994D == (2 - 1)) then
							v685[v684] = {spell_id=v998,talent_id=v684,name_localized=v996,icon=v997,tier=v999,column=v1000};
							break;
						end
						if (FlatIdent_3994D == (661 - (284 + 377))) then
							v995, v996, v997, v995, v995, v998, v995, v999, v1000 = v440(v684);
							if not v996 then
								return nil;
							end
							FlatIdent_3994D = 1 + 0;
						end
					end
				end
				FlatIdent_2C446 = 1 + 0;
			end
		end
	end;
	v405.GetCachedPvpTalentInfoByID = function(v686, v687)
		local FlatIdent_1DAC1 = 0 - 0;
		local v688;
		while true do
			if (FlatIdent_1DAC1 == (378 - (344 + 34))) then
				v688 = v686['static_cache']['pvp_talents'];
				if (v687 and not v688[v687]) then
					local FlatIdent_25C0E = 0 + 0;
					local v1002;
					local v1003;
					local v1004;
					local v1005;
					while true do
						if (FlatIdent_25C0E == (1 - 0)) then
							v688[v687] = {spell_id=v1005,talent_id=v687,name_localized=v1003,icon=v1004};
							break;
						end
						if (FlatIdent_25C0E == (0 - 0)) then
							v1002, v1003, v1004, v1002, v1002, v1005 = v437(v687);
							if not v1003 then
								return nil;
							end
							FlatIdent_25C0E = 872 - (443 + 428);
						end
					end
				end
				FlatIdent_1DAC1 = 2 - 1;
			end
			if (FlatIdent_1DAC1 == (890 - (533 + 356))) then
				return v688[v687];
			end
		end
	end;
	v405.CacheGameData = function(v689)
		local FlatIdent_833A7 = 0 + 0;
		local v690;
		while true do
			if ((1 - 0) == FlatIdent_833A7) then
				for v912 = 1438 - (1192 + 245), v442() do
					local FlatIdent_8A812 = 0 + 0;
					local v913;
					local v914;
					while true do
						if ((1003 - (957 + 45)) == FlatIdent_8A812) then
							v689['static_cache']['class_to_class_id'][v914] = v912;
							break;
						end
						if (FlatIdent_8A812 == (0 + 0)) then
							for v1007 = 3 - 2, v429(v912) do
								local FlatIdent_1F7B1 = 0 - 0;
								local v1008;
								local v1009;
								local v1010;
								local v1011;
								local v1012;
								local v1014;
								while true do
									if (FlatIdent_1F7B1 == (1 + 2)) then
										v1014['icon'] = v1011;
										v1014['background'] = v1012;
										FlatIdent_1F7B1 = 1059 - (984 + 71);
									end
									if (FlatIdent_1F7B1 == (2 + 0)) then
										v1014['name_localized'] = v1009;
										v1014['description'] = v1010;
										FlatIdent_1F7B1 = 1482 - (869 + 610);
									end
									if ((4 + 0) == FlatIdent_1F7B1) then
										v1014['role'] = v436(v1008);
										break;
									end
									if (FlatIdent_1F7B1 == (725 - (337 + 387))) then
										v1014 = v690[v1008];
										v1014['idx'] = v1007;
										FlatIdent_1F7B1 = 4 - 2;
									end
									if ((0 + 0) == FlatIdent_1F7B1) then
										v1008, v1009, v1010, v1011, v1012 = v435(v912, v1007);
										v690[v1008] = {};
										FlatIdent_1F7B1 = 2 - 1;
									end
								end
							end
							v913, v914 = v427(v912);
							FlatIdent_8A812 = 1 + 0;
						end
					end
				end
				break;
			end
			if (FlatIdent_833A7 == (0 - 0)) then
				v690 = v689['static_cache']['global_specs'];
				v690[0 + 0] = {};
				FlatIdent_833A7 = 1719 - (633 + 1085);
			end
		end
	end;
	v405.GuidToUnit = function(v692, v693)
		local FlatIdent_10A46 = 1252 - (982 + 270);
		local v694;
		while true do
			if (FlatIdent_10A46 == (0 + 0)) then
				v694 = v692['cache'][v693];
				if (v694 and v694['lku'] and (v444(v694.lku) == v693)) then
					return v694['lku'];
				end
				FlatIdent_10A46 = 1097 - (999 + 97);
			end
			if (FlatIdent_10A46 == (1 + 0)) then
				for v916, v917 in ipairs(v692:GroupUnits()) do
					if (v443(v917) and (v444(v917) == v693)) then
						local FlatIdent_50179 = 908 - (808 + 100);
						while true do
							if (FlatIdent_50179 == (1526 - (992 + 534))) then
								if v694 then
									v694['lku'] = v917;
								end
								return v917;
							end
						end
					end
				end
				break;
			end
		end
	end;
	v405.Query = function(v695, v696)
		local FlatIdent_2CC47 = 1873 - (944 + 929);
		local v697;
		local v698;
		local v699;
		while true do
			if (FlatIdent_2CC47 == (3 - 1)) then
				if not v697[v699] then
					local FlatIdent_20FE3 = 0 + 0;
					while true do
						if (FlatIdent_20FE3 == (653 - (142 + 510))) then
							v695['frame']:Show();
							v695['events']:Fire(v410);
							break;
						end
						if (FlatIdent_20FE3 == (0 - 0)) then
							v697[v699] = 1 + 0;
							v698[v699] = nil;
							FlatIdent_20FE3 = 1 - 0;
						end
					end
				end
				break;
			end
			if (FlatIdent_2CC47 == (608 - (136 + 471))) then
				v697, v698 = v695['state']['mainq'], v695['state']['staleq'];
				v699 = v444(v696);
				FlatIdent_2CC47 = 120 - (7 + 111);
			end
			if (FlatIdent_2CC47 == (169 - (13 + 156))) then
				if not v448(v696) then
					return;
				end
				if v449(v696, "player") then
					local FlatIdent_125C5 = 0 - 0;
					while true do
						if (FlatIdent_125C5 == (0 - 0)) then
							v695['events']:Fire(v407, v444("player"), "player", v695:BuildInfo("player"));
							return;
						end
					end
				end
				FlatIdent_2CC47 = 1 + 0;
			end
		end
	end;
	v405.Refresh = function(v700, v701)
		local FlatIdent_4648D = 945 - (269 + 676);
		local v702;
		while true do
			if (FlatIdent_4648D == (0 - 0)) then
				v702 = v444(v701);
				if not v702 then
					return;
				end
				FlatIdent_4648D = 119 - (112 + 6);
			end
			if (FlatIdent_4648D == (1 - 0)) then
				if not v700['state']['mainq'][v702] then
					local FlatIdent_284E9 = 0 - 0;
					while true do
						if (FlatIdent_284E9 == (0 - 0)) then
							v700['state']['staleq'][v702] = 1 - 0;
							v700['frame']:Show();
							FlatIdent_284E9 = 2 - 1;
						end
						if (FlatIdent_284E9 == (1 + 0)) then
							v700['events']:Fire(v410);
							break;
						end
					end
				end
				break;
			end
		end
	end;
	v405.ProcessQueues = function(v703)
		local FlatIdent_41AB4 = 259 - (27 + 232);
		local v704;
		local v705;
		while true do
			if (FlatIdent_41AB4 == (4 - 3)) then
				if (InspectFrame and InspectFrame:IsShown()) then
					return;
				end
				v704 = v703['state']['mainq'];
				v705 = v703['state']['staleq'];
				FlatIdent_41AB4 = 3 - 1;
			end
			if (FlatIdent_41AB4 == (541 - (299 + 240))) then
				if (not next(v704) and next(v705)) then
					local FlatIdent_7827 = 0 + 0;
					while true do
						if ((0 + 0) == FlatIdent_7827) then
							v703['state']['mainq'], v703['state']['staleq'] = v703['state']['staleq'], v703['state']['mainq'];
							v704, v705 = v705, v704;
							break;
						end
					end
				end
				if ((v703['state']['last_inspect'] + v415) < GetTime()) then
					local FlatIdent_70144 = 0 + 0;
					local v1026;
					while true do
						if (FlatIdent_70144 == (0 - 0)) then
							v1026 = v703['state']['current_guid'];
							if v1026 then
								local FlatIdent_16A76 = 0 + 0;
								local v1134;
								while true do
									if (FlatIdent_16A76 == (1760 - (559 + 1201))) then
										v1134 = (v704 and v704[v1026]) or (v416 + (1624 - (876 + 747)));
										if not v703:GuidToUnit(v1026) then
											v704[v1026], v705[v1026] = nil, nil;
										elseif (v1134 > v416) then
											v704[v1026], v705[v1026] = nil, 1 + 0;
										else
											v704[v1026] = v1134 + (221 - (33 + 187));
										end
										FlatIdent_16A76 = 153 - (93 + 59);
									end
									if (FlatIdent_16A76 == (1 + 0)) then
										v703['state']['current_guid'] = nil;
										break;
									end
								end
							end
							break;
						end
					end
				end
				if v703['state']['current_guid'] then
					return;
				end
				FlatIdent_41AB4 = 408 - (356 + 49);
			end
			if (FlatIdent_41AB4 == (0 - 0)) then
				if not v703['state']['logged_in'] then
					return;
				end
				if InCombatLockdown() then
					return;
				end
				if UnitIsDead("player") then
					return;
				end
				FlatIdent_41AB4 = 1 - 0;
			end
			if (FlatIdent_41AB4 == (13 - 10)) then
				for v918, v919 in pairs(v704) do
					local v920 = v703:GuidToUnit(v918);
					if not v920 then
						v704[v918], v705[v918] = nil, nil;
					elseif (not v425(v920) or not v447(v920)) then
						v704[v918], v705[v918] = nil, 1 - 0;
					else
						v704[v918] = v919 + (1282 - (131 + 1150));
						v703['state']['current_guid'] = v918;
						NotifyInspect(v920);
						break;
					end
				end
				if (not next(v704) and not next(v705) and (v703['state']['throttle'] == (1446 - (763 + 683))) and (v703['state']['debounce_send_update'] <= (900 - (385 + 515)))) then
					v419:Hide();
				end
				v703['events']:Fire(v410);
				break;
			end
		end
	end;
	v405.UpdatePlayerInfo = function(v706, v707, v708, v709)
		local FlatIdent_651FD = 0 - 0;
		local v717;
		while true do
			if (FlatIdent_651FD == (1683 - (202 + 1480))) then
				if (v709['realm'] and (v709['realm'] == "")) then
					v709['realm'] = nil;
				end
				v709['class_id'] = v717 and v706['static_cache']['class_to_class_id'][v717];
				FlatIdent_651FD = 634 - (588 + 44);
			end
			if (FlatIdent_651FD == (0 + 0)) then
				v709['class_localized'], v709['class'], v709['race_localized'], v709['race'], v709['gender'], v709['name'], v709['realm'] = v430(v707);
				v717 = v709['class'];
				FlatIdent_651FD = 3 - 2;
			end
			if (FlatIdent_651FD == (1 + 1)) then
				if not v709['spec_role'] then
					v709['spec_role'] = v717 and v457[v717];
				end
				if not v709['spec_role_detailed'] then
					v709['spec_role_detailed'] = v717 and v458[v717];
				end
				FlatIdent_651FD = 3 + 0;
			end
			if ((478 - (35 + 440)) == FlatIdent_651FD) then
				v709['lku'] = v708;
				break;
			end
		end
	end;
	v405.BuildInfo = function(v720, v721)
		local v722 = v444(v721);
		if not v722 then
			return;
		end
		local v723 = v720['cache'];
		local v724 = v723[v722] or {};
		v723[v722] = v724;
		v724['guid'] = v722;
		v720:UpdatePlayerInfo(v722, v721, v724);
		local v727 = v724['class'];
		if (not v727 and not v720['state']['mainq'][v722]) then
			local FlatIdent_700D7 = 0 + 0;
			while true do
				if (FlatIdent_700D7 == (0 + 0)) then
					v720['state']['staleq'][v722] = 1 - 0;
					v720['frame']:Show();
					FlatIdent_700D7 = 1 - 0;
				end
				if (FlatIdent_700D7 == (1 + 0)) then
					v720['events']:Fire(v410);
					break;
				end
			end
		end
		local v728 = not v449(v721, "player");
		local v729 = v433();
		local v730 = (v728 and v432(v721)) or (v729 and v434(v729));
		local v731 = v720['static_cache']['global_specs'];
		if (not v730 or not v731[v730]) then
			v724['global_spec_id'] = nil;
		else
			local FlatIdent_942E0 = 0 + 0;
			local v1033;
			while true do
				if (FlatIdent_942E0 == (1708 - (1508 + 198))) then
					v724['spec_description'] = v1033['description'];
					v724['spec_icon'] = v1033['icon'];
					FlatIdent_942E0 = 3 + 0;
				end
				if ((275 - (17 + 255)) == FlatIdent_942E0) then
					v724['spec_background'] = v1033['background'];
					v724['spec_role'] = v1033['role'];
					FlatIdent_942E0 = 1472 - (696 + 772);
				end
				if (FlatIdent_942E0 == (1214 - (830 + 384))) then
					v724['global_spec_id'] = v730;
					v1033 = v731[v730];
					FlatIdent_942E0 = 458 - (229 + 228);
				end
				if (FlatIdent_942E0 == (1097 - (624 + 472))) then
					v724['spec_index'] = v1033['idx'];
					v724['spec_name_localized'] = v1033['name_localized'];
					FlatIdent_942E0 = 1 + 1;
				end
				if ((2002 - (316 + 1682)) == FlatIdent_942E0) then
					v724['spec_role_detailed'] = v456[v730];
					break;
				end
			end
		end
		if not v724['spec_role'] then
			v724['spec_role'] = v727 and v457[v727];
		end
		if not v724['spec_role_detailed'] then
			v724['spec_role_detailed'] = v727 and v458[v727];
		end
		v724['talents'] = v724['talents'] or {};
		v724['pvp_talents'] = v724['pvp_talents'] or {};
		if v724['spec_index'] then
			local FlatIdent_95184 = 0 - 0;
			while true do
				if (FlatIdent_95184 == (1456 - (951 + 503))) then
					if v728 then
						for v1161 = 623 - (210 + 412), v455 do
							local FlatIdent_6BCA4 = 638 - (412 + 226);
							local v1162;
							while true do
								if (FlatIdent_6BCA4 == (0 - 0)) then
									v1162 = v431(v721, v1161);
									if v1162 then
										v724['pvp_talents'][v1162] = v720:GetCachedPvpTalentInfoByID(v1162);
									end
									break;
								end
							end
						end
					else
						for v1163 = 498 - (274 + 223), v455 do
							local FlatIdent_81E66 = 0 - 0;
							local v1164;
							local v1165;
							while true do
								if (FlatIdent_81E66 == (1318 - (572 + 745))) then
									if v1165 then
										v724['pvp_talents'][v1165] = v720:GetCachedPvpTalentInfoByID(v1165);
									end
									break;
								end
								if ((0 + 0) == FlatIdent_81E66) then
									v1164 = v438(v1163);
									v1165 = v1164 and v1164['selectedTalentID'];
									FlatIdent_81E66 = 826 - (588 + 237);
								end
							end
						end
					end
					break;
				end
				if (FlatIdent_95184 == (2 - 1)) then
					for v1095 = 1 + 0, v453 do
						for v1136 = 1 - 0, v454 do
							local FlatIdent_7D1A6 = 702 - (26 + 676);
							local v1137;
							local v1138;
							while true do
								if (FlatIdent_7D1A6 == (0 - 0)) then
									v1137, v1138 = v720:GetCachedTalentInfo(v724.class_id, v1095, v1136, v724.spec_group, v728, v721);
									if v1138 then
										v724['talents'][v1137['talent_id']] = v1137;
									end
									break;
								end
							end
						end
					end
					wipe(v724.pvp_talents);
					FlatIdent_95184 = 1 + 1;
				end
				if (FlatIdent_95184 == (0 + 0)) then
					v724['spec_group'] = GetActiveSpecGroup(v728);
					wipe(v724.talents);
					FlatIdent_95184 = 1 + 0;
				end
			end
		end
		v724['glyphs'] = v724['glyphs'] or {};
		if (v728 and not UnitIsVisible(v721) and v447(v721)) then
			v724['not_visible'] = true;
		end
		return v724;
	end;
	v405.INSPECT_READY = function(v735, v736)
		local FlatIdent_74346 = 1287 - (741 + 546);
		local v737;
		local v738;
		while true do
			if ((1245 - (367 + 877)) == FlatIdent_74346) then
				if v737 then
					local FlatIdent_2FE41 = 604 - (108 + 496);
					local v1052;
					local v1053;
					local v1056;
					while true do
						if ((4 - 1) == FlatIdent_2FE41) then
							v735['events']:Fire(v409, v736, v737);
							break;
						end
						if (FlatIdent_2FE41 == (0 + 0)) then
							if (v736 == v735['state']['current_guid']) then
								local FlatIdent_51AB0 = 0 - 0;
								while true do
									if (FlatIdent_51AB0 == (0 - 0)) then
										v735['state']['current_guid'] = nil;
										v738 = true;
										break;
									end
								end
							end
							v1052, v1053 = v735['state']['mainq'], v735['state']['staleq'];
							FlatIdent_2FE41 = 731 - (588 + 142);
						end
						if (FlatIdent_2FE41 == (714 - (208 + 505))) then
							v1052[v736], v1053[v736] = nil, nil;
							v1056 = v432(v737);
							FlatIdent_2FE41 = 1630 - (1330 + 298);
						end
						if (FlatIdent_2FE41 == (2 + 0)) then
							if not v735['static_cache']['global_specs'][v1056] then
								local FlatIdent_1C4D7 = 1544 - (1231 + 313);
								while true do
									if ((0 + 0) == FlatIdent_1C4D7) then
										v1053[v736] = 1 - 0;
										return;
									end
								end
							end
							v735['events']:Fire(v407, v736, v737, v735:BuildInfo(v737));
							FlatIdent_2FE41 = 2 + 1;
						end
					end
				end
				if v738 then
					v426();
				end
				FlatIdent_74346 = 1 + 1;
			end
			if (FlatIdent_74346 == (5 - 3)) then
				v735['events']:Fire(v410);
				break;
			end
			if (FlatIdent_74346 == (0 + 0)) then
				v737 = v735:GuidToUnit(v736);
				v738 = false;
				FlatIdent_74346 = 4 - 3;
			end
		end
	end;
	v405.PLAYER_ENTERING_WORLD = function(v739)
		if (v739['commScope'] == "INSTANCE_CHAT") then
			local FlatIdent_4ABBC = 0 + 0;
			while true do
				if (FlatIdent_4ABBC == (0 - 0)) then
					v739['commScope'] = nil;
					v739:UpdateCommScope();
					break;
				end
			end
		end
	end;
	local v478 = {};
	v405.GROUP_ROSTER_UPDATE = function(v740)
		local FlatIdent_783A4 = 0 - 0;
		local v741;
		local v742;
		while true do
			if (FlatIdent_783A4 == (330 - (72 + 257))) then
				for v921, v922 in ipairs(v740:GroupUnits()) do
					local FlatIdent_981BC = 0 - 0;
					local v923;
					while true do
						if ((1350 - (207 + 1143)) == FlatIdent_981BC) then
							v923 = v444(v922);
							if v923 then
								local FlatIdent_81277 = 1385 - (1225 + 160);
								while true do
									if (FlatIdent_81277 == (370 - (71 + 299))) then
										v478[v923] = true;
										if not v741[v923] then
											local FlatIdent_50172 = 0 + 0;
											while true do
												if (FlatIdent_50172 == (326 - (233 + 93))) then
													v740:Query(v922);
													v740['events']:Fire(v407, v923, v922, v740:BuildInfo(v922));
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
				for v924 in pairs(v741) do
					if not v478[v924] then
						local FlatIdent_59C99 = 0 + 0;
						while true do
							if (FlatIdent_59C99 == (0 - 0)) then
								v741[v924] = nil;
								v740['events']:Fire(v408, v924, nil);
								break;
							end
						end
					end
				end
				FlatIdent_783A4 = 1 + 1;
			end
			if ((4 - 2) == FlatIdent_783A4) then
				wipe(v478);
				v740:UpdateCommScope();
				break;
			end
			if (FlatIdent_783A4 == (0 + 0)) then
				v741 = v740['cache'];
				v742 = v740:GroupUnits();
				FlatIdent_783A4 = 2 - 1;
			end
		end
	end;
	v405.DoPlayerUpdate = function(v743)
		local FlatIdent_5F4C7 = 0 - 0;
		while true do
			if (FlatIdent_5F4C7 == (3 - 2)) then
				v743['frame']:Show();
				break;
			end
			if (FlatIdent_5F4C7 == (0 + 0)) then
				v743:Query("player");
				v743['state']['debounce_send_update'] = 2.5 + 0;
				FlatIdent_5F4C7 = 2 - 1;
			end
		end
	end;
	v405.SendLatestSpecData = function(v745)
		local FlatIdent_808B0 = 0 + 0;
		local v746;
		local v747;
		local v748;
		local v749;
		local v750;
		while true do
			if (FlatIdent_808B0 == (2 + 2)) then
				v451(v411, v749, v746);
				break;
			end
			if (FlatIdent_808B0 == (4 - 1)) then
				v750 = 2 - 1;
				for v927 in pairs(v748.pvp_talents) do
					local FlatIdent_11ED7 = 0 + 0;
					while true do
						if ((0 + 0) == FlatIdent_11ED7) then
							v749 = v749 .. v413 .. v927;
							v750 = v750 + 1 + 0;
							break;
						end
					end
				end
				for v928 = v750, v455 do
					v749 = v749 .. v413 .. (0 + 0);
				end
				FlatIdent_808B0 = 814 - (491 + 319);
			end
			if (FlatIdent_808B0 == (1296 - (806 + 489))) then
				v748 = v745['cache'][v747];
				if not v748 then
					return;
				end
				v749 = v412 .. v413 .. v747 .. v413 .. (v748['global_spec_id'] or (0 - 0));
				FlatIdent_808B0 = 1 + 1;
			end
			if (FlatIdent_808B0 == (403 - (356 + 45))) then
				v750 = 2 - 1;
				for v925 in pairs(v748.talents) do
					local FlatIdent_9489F = 0 + 0;
					while true do
						if ((0 + 0) == FlatIdent_9489F) then
							v749 = v749 .. v413 .. v925;
							v750 = v750 + (2 - 1);
							break;
						end
					end
				end
				for v926 = v750, v453 do
					v749 = v749 .. v413 .. (1183 - (454 + 729));
				end
				FlatIdent_808B0 = 6 - 3;
			end
			if (FlatIdent_808B0 == (528 - (107 + 421))) then
				v746 = v745['commScope'];
				if not v746 then
					return;
				end
				v747 = v444("player");
				FlatIdent_808B0 = 1787 - (657 + 1129);
			end
		end
	end;
	v405.UpdateCommScope = function(v751)
		local FlatIdent_9100A = 0 + 0;
		local v752;
		while true do
			if (FlatIdent_9100A == (0 - 0)) then
				v752 = (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (v441() and "RAID") or (IsInGroup(LE_PARTY_CATEGORY_HOME) and "PARTY");
				if (v751['commScope'] ~= v752) then
					local FlatIdent_81BC7 = 0 - 0;
					while true do
						if (FlatIdent_81BC7 == (0 + 0)) then
							v751['commScope'] = v752;
							v751:DoPlayerUpdate();
							break;
						end
					end
				end
				break;
			end
		end
	end;
	local v483 = {};
	v483['fmt'] = 266 - (238 + 27);
	v483['guid'] = v483['fmt'] + 1 + 0;
	v483['global_spec_id'] = v483['guid'] + (1 - 0);
	v483['talents'] = v483['global_spec_id'] + (3 - 2);
	v483['end_talents'] = v483['talents'] + v453;
	v483['pvp_talents'] = v483['end_talents'] + 1 + 0;
	v483['end_pvp_talents'] = (v483['pvp_talents'] + v455) - (1 + 0);
	v405.CHAT_MSG_ADDON = function(v753, v754, v755, v756, v757)
		local FlatIdent_97903 = 0 + 0;
		local v758;
		local v759;
		local v760;
		local v761;
		local v762;
		local v763;
		local v774;
		local v775;
		local v791;
		local v795;
		local v796;
		local v797;
		while true do
			if (FlatIdent_97903 == (5 + 2)) then
				v762['spec_role_detailed'] = v456[v775];
				v791 = nil;
				v762['talents'] = wipe(v762['talents'] or {});
				for v929 = v483['talents'], v483['end_talents'] do
					local FlatIdent_4D991 = 19 - (13 + 6);
					local v930;
					while true do
						if (FlatIdent_4D991 == (0 + 0)) then
							v930 = tonumber(v758[v929]) or (387 - (342 + 45));
							if (v930 > (0 + 0)) then
								local FlatIdent_70F0F = 1486 - (757 + 729);
								local v1098;
								while true do
									if (FlatIdent_70F0F == (0 - 0)) then
										v1098 = v753:GetCachedTalentInfoByID(v930);
										if v1098 then
											v762['talents'][v930] = v1098;
										else
											v791 = 687 - (435 + 251);
										end
										break;
									end
								end
							end
							break;
						end
					end
				end
				FlatIdent_97903 = 18 - 10;
			end
			if (FlatIdent_97903 == (1470 - (411 + 1050))) then
				v797 = (not v791 and v753['inspect_ready_used'] and (v795[v760] or v796[v760]) and (643 - (158 + 484))) or nil;
				v795[v760], v796[v760] = v791, v797;
				if (v791 or v797) then
					v753['frame']:Show();
				end
				v753['events']:Fire(v407, v760, v763, v762);
				FlatIdent_97903 = 1459 - (325 + 1124);
			end
			if ((8 - 3) == FlatIdent_97903) then
				if (not v775 or not v774[v775]) then
					return;
				end
				v762['global_spec_id'] = v775;
				v762['spec_index'] = v774[v775]['idx'];
				v762['spec_name_localized'] = v774[v775]['name_localized'];
				FlatIdent_97903 = 344 - (254 + 84);
			end
			if (FlatIdent_97903 == (10 + 0)) then
				v753['events']:Fire(v410);
				break;
			end
			if (FlatIdent_97903 == (0 - 0)) then
				if ((v754 ~= v411) or (v756 ~= v753['commScope'])) then
					return;
				end
				v758 = {strsplit(v413, v755)};
				v759 = v758[v483['fmt']];
				if (v759 ~= v412) then
					return;
				end
				FlatIdent_97903 = 1 - 0;
			end
			if (FlatIdent_97903 == (18 - 10)) then
				v762['pvp_talents'] = wipe(v762['pvp_talents'] or {});
				for v931 = v483['pvp_talents'], v483['end_pvp_talents'] do
					local FlatIdent_35D3F = 1056 - (246 + 810);
					local v932;
					while true do
						if (FlatIdent_35D3F == (0 - 0)) then
							v932 = tonumber(v758[v931]) or (784 - (409 + 375));
							if (v932 > (0 + 0)) then
								local FlatIdent_89CD2 = 0 - 0;
								local v1099;
								while true do
									if (FlatIdent_89CD2 == (0 + 0)) then
										v1099 = v753:GetCachedPvpTalentInfoByID(v932);
										if v1099 then
											v762['pvp_talents'][v932] = v1099;
										else
											v791 = 3 - 2;
										end
										break;
									end
								end
							end
							break;
						end
					end
				end
				v762['glyphs'] = v762['glyphs'] or {};
				v795, v796 = v753['state']['mainq'], v753['state']['staleq'];
				FlatIdent_97903 = 11 - 2;
			end
			if (FlatIdent_97903 == (1 + 1)) then
				if not v762 then
					return;
				end
				v763 = v753:GuidToUnit(v760);
				if not v763 then
					return;
				end
				if v449(v763, "player") then
					return;
				end
				FlatIdent_97903 = 3 + 0;
			end
			if (FlatIdent_97903 == (3 + 1)) then
				if (v762['realm'] and (v762['realm'] == "")) then
					v762['realm'] = nil;
				end
				v762['class_id'] = v753['static_cache']['class_to_class_id'][v762['class']];
				v774 = v753['static_cache']['global_specs'];
				v775 = v758[v483['global_spec_id']] and tonumber(v758[v483['global_spec_id']]);
				FlatIdent_97903 = 2 + 3;
			end
			if (FlatIdent_97903 == (976 - (911 + 64))) then
				v760 = v758[v483['guid']];
				v761 = v444(v757);
				if (v761 and (v761 ~= v760)) then
					return;
				end
				v762 = v760 and v753['cache'][v760];
				FlatIdent_97903 = 5 - 3;
			end
			if (FlatIdent_97903 == (822 - (510 + 309))) then
				v753['state']['throttle'] = v753['state']['throttle'] + 1 + 0;
				v753['frame']:Show();
				if (v753['state']['throttle'] > (1012 - (636 + 336))) then
					return;
				end
				v762['class_localized'], v762['class'], v762['race_localized'], v762['race'], v762['gender'], v762['name'], v762['realm'] = v430(v760);
				FlatIdent_97903 = 1 + 3;
			end
			if (FlatIdent_97903 == (4 + 2)) then
				v762['spec_description'] = v774[v775]['description'];
				v762['spec_icon'] = v774[v775]['icon'];
				v762['spec_background'] = v774[v775]['background'];
				v762['spec_role'] = v774[v775]['role'];
				FlatIdent_97903 = 464 - (99 + 358);
			end
		end
	end;
	v405.UNIT_LEVEL = function(v800, v801)
		local FlatIdent_DBFA = 0 + 0;
		while true do
			if ((1907 - (237 + 1670)) == FlatIdent_DBFA) then
				if (v446(v801) or v445(v801)) then
					v800:Refresh(v801);
				end
				if v449(v801, "player") then
					v800:DoPlayerUpdate();
				end
				break;
			end
		end
	end;
	v405.PLAYER_TALENT_UPDATE = function(v802)
		v802:DoPlayerUpdate();
	end;
	v405.PLAYER_SPECIALIZATION_CHANGED = function(v803, v804)
		if (v804 and v449(v804, "player")) then
			v803:DoPlayerUpdate();
		end
	end;
	v405.UNIT_NAME_UPDATE = function(v805, v806)
		local FlatIdent_21565 = 1219 - (100 + 1119);
		local v807;
		local v808;
		local v809;
		while true do
			if (FlatIdent_21565 == (267 - (261 + 5))) then
				v809 = v808 and v807[v808];
				if v809 then
					local FlatIdent_4C94A = 263 - (46 + 217);
					while true do
						if (FlatIdent_4C94A == (1334 - (1237 + 97))) then
							v805:UpdatePlayerInfo(v808, v806, v809);
							if (v809['name'] ~= UNKNOWN) then
								v805['events']:Fire(v407, v808, v806, v809);
							end
							break;
						end
					end
				end
				break;
			end
			if (FlatIdent_21565 == (0 + 0)) then
				v807 = v805['cache'];
				v808 = v444(v806);
				FlatIdent_21565 = 1 - 0;
			end
		end
	end;
	v405.UNIT_AURA = function(v810, v811)
		local FlatIdent_86FDB = 0 + 0;
		local v812;
		local v813;
		local v814;
		while true do
			if ((0 - 0) == FlatIdent_86FDB) then
				v812 = v810['cache'];
				v813 = v444(v811);
				FlatIdent_86FDB = 2 - 1;
			end
			if (FlatIdent_86FDB == (1707 - (607 + 1099))) then
				v814 = v813 and v812[v813];
				if v814 then
					if not v449(v811, "player") then
						if UnitIsVisible(v811) then
							if v814['not_visible'] then
								local FlatIdent_4E644 = 0 - 0;
								while true do
									if (FlatIdent_4E644 == (0 - 0)) then
										v814['not_visible'] = nil;
										if not v810['state']['mainq'][v813] then
											local FlatIdent_3AC99 = 1920 - (686 + 1234);
											while true do
												if (FlatIdent_3AC99 == (1 + 0)) then
													v810['events']:Fire(v410);
													break;
												end
												if (FlatIdent_3AC99 == (1146 - (1047 + 99))) then
													v810['state']['staleq'][v813] = 1 + 0;
													v810['frame']:Show();
													FlatIdent_3AC99 = 3 - 2;
												end
											end
										end
										break;
									end
								end
							end
						elseif v447(v811) then
							v814['not_visible'] = true;
						end
					end
				end
				break;
			end
		end
	end;
	v405.UNIT_SPELLCAST_SUCCEEDED = function(v815, v816, v817, v818)
		if (v818 == (201084 - (291 + 44))) then
			v815:Query(v816);
		end
	end;
	v405.QueuedInspections = function(v819)
		local FlatIdent_317D3 = 0 + 0;
		local v820;
		while true do
			if (FlatIdent_317D3 == (217 - (169 + 48))) then
				v820 = {};
				for v933 in pairs(v819['state'].mainq) do
					table.insert(v820, v933);
				end
				FlatIdent_317D3 = 2 - 1;
			end
			if (FlatIdent_317D3 == (2 - 1)) then
				return v820;
			end
		end
	end;
	v405.StaleInspections = function(v821)
		local FlatIdent_5206A = 151 - (111 + 40);
		local v822;
		while true do
			if (FlatIdent_5206A == (0 - 0)) then
				v822 = {};
				for v934 in pairs(v821['state'].staleq) do
					table.insert(v822, v934);
				end
				FlatIdent_5206A = 2 - 1;
			end
			if (FlatIdent_5206A == (1702 - (291 + 1410))) then
				return v822;
			end
		end
	end;
	v405.IsInspectQueued = function(v823, v824)
		return v824 and (v823['state']['mainq'][v824] or v823['state']['staleq'][v824]) and true;
	end;
	v405.GetCachedInfo = function(v825, v826)
		local FlatIdent_6820F = 988 - (936 + 52);
		local v827;
		while true do
			if (FlatIdent_6820F == (0 - 0)) then
				v827 = v825['cache'];
				return v826 and v827[v826];
			end
		end
	end;
	v405.Rescan = function(v828, v829)
		local FlatIdent_1F89 = 1468 - (585 + 883);
		local v830;
		local v831;
		while true do
			if (FlatIdent_1F89 == (961 - (256 + 704))) then
				v828['frame']:Show();
				v828:GROUP_ROSTER_UPDATE();
				FlatIdent_1F89 = 367 - (294 + 71);
			end
			if (FlatIdent_1F89 == (108 - (75 + 31))) then
				v828['events']:Fire(v410);
				break;
			end
			if (FlatIdent_1F89 == (0 - 0)) then
				v830, v831 = v828['state']['mainq'], v828['state']['staleq'];
				if v829 then
					local FlatIdent_45D4F = 0 + 0;
					local v1060;
					while true do
						if (FlatIdent_45D4F == (1124 - (84 + 1040))) then
							v1060 = v828:GuidToUnit(v829);
							if v1060 then
								if v449(v1060, "player") then
									v828['events']:Fire(v407, v829, "player", v828:BuildInfo("player"));
								elseif not v830[v829] then
									v831[v829] = 2 - 1;
								end
							end
							break;
						end
					end
				else
					for v1100, v1101 in ipairs(v828:GroupUnits()) do
						if v443(v1101) then
							if v449(v1101, "player") then
								v828['events']:Fire(v407, v444("player"), "player", v828:BuildInfo("player"));
							else
								local FlatIdent_208D8 = 0 - 0;
								local v1197;
								while true do
									if (FlatIdent_208D8 == (0 - 0)) then
										v1197 = v444(v1101);
										if (v1197 and not v830[v1197]) then
											v831[v1197] = 1 - 0;
										end
										break;
									end
								end
							end
						end
					end
				end
				FlatIdent_1F89 = 1 + 0;
			end
		end
	end;
	local v503 = {raid={"player"},party={"player"},player={"player"}};
	for v832 = 2 - 1, 38 + 2 do
		table.insert(v503.raid, "raid" .. v832);
	end
	for v833 = 1206 - (675 + 530), 940 - (583 + 353) do
		table.insert(v503.party, "party" .. v833);
	end
	v405.GroupUnits = function(v834)
		local FlatIdent_13F5F = 1101 - (812 + 289);
		local v835;
		while true do
			if (FlatIdent_13F5F == (1 + 0)) then
				return v835;
			end
			if (FlatIdent_13F5F == (114 - (94 + 20))) then
				v835 = nil;
				if v441() then
					v835 = v503['raid'];
				elseif (v428() > (0 + 0)) then
					v835 = v503['party'];
				else
					v835 = v503['player'];
				end
				FlatIdent_13F5F = 816 - (242 + 573);
			end
		end
	end;
	if IsLoggedIn() then
		v405:PLAYER_LOGIN();
	end
	v1['LibInspect'] = v405;
end
local v42 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
local v43 = "abcdefghijklmnopqrstuvwxyz";
local v44 = "0123456789";
local v45 = v42 .. v43 .. v44;
local v46 = v42 .. v43;
local v47 = string['sub'];
local v48 = math['random'];
string.random = function(v200, v201)
	local FlatIdent_618B5 = 0 - 0;
	local v202;
	local v203;
	while true do
		if (FlatIdent_618B5 == (0 + 0)) then
			v202 = "";
			v203 = (v201 and v46) or v45;
			FlatIdent_618B5 = 916 - (536 + 379);
		end
		if (FlatIdent_618B5 == (1053 - (361 + 691))) then
			for v506 = 1 - 0, v200 do
				local FlatIdent_63019 = 0 + 0;
				local v507;
				while true do
					if (FlatIdent_63019 == (0 - 0)) then
						v507 = v48(#v203);
						v202 = v202 .. v47(v203, v507, v507);
						break;
					end
				end
			end
			return v202;
		end
	end
end;
v1.randomVariable = function(v204)
	local FlatIdent_6745F = 1775 - (1558 + 217);
	local v205;
	local v206;
	while true do
		if (FlatIdent_6745F == (1453 - (126 + 1326))) then
			v205 = v205 .. v47(v46, v206, v206);
			for v508 = 1 + 0, v204 - (3 - 2) do
				local FlatIdent_43093 = 0 + 0;
				while true do
					if (FlatIdent_43093 == (0 + 0)) then
						v206 = v48(#v45);
						v205 = v205 .. v47(v45, v206, v206);
						break;
					end
				end
			end
			FlatIdent_6745F = 208 - (71 + 135);
		end
		if ((1333 - (678 + 655)) == FlatIdent_6745F) then
			v205 = "";
			v206 = v48(#v46);
			FlatIdent_6745F = 217 - (89 + 127);
		end
		if (FlatIdent_6745F == (3 - 1)) then
			return v205;
		end
	end
end;
local v51 = {"MoveForwardStart","MoveBackwardStart","StrafeLeftStart","StrafeRightStart","StrafeLeftStop","StrafeRightStop","JumpOrAscendStart"};
if not v1['protected'] then
	v1['protected'] = {};
	v1['protected']['Objects'] = Objects;
	local function v511()
		local FlatIdent_98278 = 1443 - (776 + 667);
		while true do
			if ((2 + 2) == FlatIdent_98278) then
				v1['protected']['MoveBackwardStart'] = MoveBackwardStart;
				v1['protected']['JumpOrAscendStart'] = JumpOrAscendStart;
				v1['protected']['MoveTo'] = MoveTo;
				FlatIdent_98278 = 2 + 3;
			end
			if (FlatIdent_98278 == (0 - 0)) then
				v1['protected']['CameraOrSelectOrMoveStart'] = CameraOrSelectOrMoveStart;
				v1['protected']['TurnOrActionStart'] = TurnOrActionStart;
				v1['protected']['TurnOrActionStop'] = TurnOrActionStop;
				FlatIdent_98278 = 2 - 1;
			end
			if (FlatIdent_98278 == (1 + 1)) then
				v1['protected']['TurnLeftStop'] = TurnLeftStop;
				v1['protected']['TurnRightStop'] = TurnRightStop;
				v1['protected']['StrafeRightStart'] = StrafeRightStart;
				FlatIdent_98278 = 4 - 1;
			end
			if (FlatIdent_98278 == (1 - 0)) then
				v1['protected']['MoveForwardStart'] = MoveForwardStart;
				v1['protected']['TurnLeftStart'] = TurnLeftStart;
				v1['protected']['TurnRightStart'] = TurnRightStart;
				FlatIdent_98278 = 5 - 3;
			end
			if (FlatIdent_98278 == (1418 - (1195 + 220))) then
				v1['protected']['StrafeLeftStart'] = StrafeLeftStart;
				v1['protected']['StrafeRightStop'] = StrafeRightStop;
				v1['protected']['StrafeLeftStop'] = StrafeLeftStop;
				FlatIdent_98278 = 238 - (209 + 25);
			end
			if ((1 + 6) == FlatIdent_98278) then
				v1['protected'].JoinBattlefield = function(v940)
					return v2:CallProtectedFunction("(function() JoinBattlefield(" .. v940 .. ", true) end)");
				end;
				v1['protected'].AcceptQueue = function(v941, v942)
					v2:CallProtectedFunction([[(function() 
            
            if not awful then return false end

            local queuePop
            for i=1,3 do
                if GetBattlefieldStatus(i) == "confirm" then
                    queuePop = i
                end
            end

            --never miss queue
            if queuePop then
                if not awful.queuePopStart then
                    awful.queuePopStart = awful.time
                else
                    if awful.time - awful.queuePopStart > 5 then
                        AcceptBattlefieldPort(queuePop, 1)
                    end
                end
            else
                awful.queuePopStart = nil
            end
            
            if awful.queuePopStart and awful.time - awful.queuePopStart > 30 then awful.queuePopStart = nil end

        end)]]);
				end;
				break;
			end
			if (FlatIdent_98278 == (2003 - (979 + 1019))) then
				v1['protected'].PetAttack = function(v935)
					local FlatIdent_1F821 = 1176 - (401 + 775);
					while true do
						if (FlatIdent_1F821 == (0 + 0)) then
							v935 = v935 or "";
							v2:CallProtectedFunction("(function() PetAttack(" .. v935 .. ") end)");
							break;
						end
					end
				end;
				v1['protected'].RunMacroText = function(v936)
					local FlatIdent_2DA74 = 547 - (359 + 188);
					while true do
						if (FlatIdent_2DA74 == (1384 - (557 + 827))) then
							if RunMacroText then
								v2:CallProtectedFunction("(function() RunMacroText('" .. v936 .. "') end)");
							end
							if C_Macro['RunMacroText'] then
								v2:CallProtectedFunction("(function() C_Macro.RunMacroText('" .. v936 .. "') end)");
							end
							break;
						end
					end
				end;
				v1['protected'].CancelForm = function()
					local FlatIdent_74126 = 542 - (471 + 71);
					while true do
						if (FlatIdent_74126 == (391 - (13 + 378))) then
							if RunMacroText then
								v2:CallProtectedFunction('(function() RunMacroText("/cancelform") end)');
							end
							if C_Macro['RunMacroText'] then
								v2:CallProtectedFunction('(function() C_Macro.RunMacroText("/cancelform") end)');
							end
							break;
						end
					end
				end;
				FlatIdent_98278 = 692 - (569 + 117);
			end
			if (FlatIdent_98278 == (6 + 0)) then
				v1['protected']['CancelShapeshiftForm'] = v1['protected']['CancelForm'];
				v1['protected'].ABP = function(v937, v938)
					v2:CallProtectedFunction("(function() AcceptBattlefieldPort(" .. tostring(v937) .. "," .. tostring(v938) .. ") end)");
				end;
				v1['protected'].JA = function(v939)
					local FlatIdent_5EFD7 = 0 - 0;
					while true do
						if (FlatIdent_5EFD7 == (0 - 0)) then
							if (v939 ~= "PISSY WISSY") then
								return;
							end
							v2:CallProtectedFunction("(function() JoinArena() end)");
							break;
						end
					end
				end;
				FlatIdent_98278 = 1 + 6;
			end
		end
	end
	v2:CallProtectedFunction("(function() _G.PCALLSX = {} end)");
	local v512 = function(v859)
		local FlatIdent_5DD14 = 0 - 0;
		local v860;
		while true do
			if (FlatIdent_5DD14 == (0 + 0)) then
				v860 = "(function() _G.PCALLSX." .. v859 .. " = _G." .. v859 .. " end)";
				v2:CallProtectedFunction(v860);
				break;
			end
		end
	end;
	for v861 = 1 + 0, #v51 do
		v512(v51[v861]);
	end
	v511();
end
local v52 = function(v207)
	local FlatIdent_1B39B = 0 + 0;
	while true do
		if (FlatIdent_1B39B == (0 + 0)) then
			if (v0['type'] == "noname") then
				return;
			end
			_G[v207] = function()
			end;
			break;
		end
	end
end;
local v53 = function(v208)
	if (v0['type'] == "noname") then
	else
		local FlatIdent_34925 = 0 + 0;
		local v862;
		while true do
			if (FlatIdent_34925 == (0 + 0)) then
				v862 = "(function() _G." .. v208 .. " = _G.PCALLSX." .. v208 .. " end)";
				return v2:CallProtectedFunction(v862);
			end
		end
	end
end;
if (v1['saved'] and (v1['saved']['securityStuff'] == nil)) then
	v1['saved']['securityStuff'] = true;
end
if ((v0['type'] == "daemonic") or (v0['type'] == "blade")) then
	v1.FaceDirection = function(v863, v864)
		local FlatIdent_35E2B = 1407 - (787 + 620);
		while true do
			if (FlatIdent_35E2B == (0 - 0)) then
				if not FaceDirection then
					return;
				end
				v14 = v14 or v1['player'];
				FlatIdent_35E2B = 1 - 0;
			end
			if (FlatIdent_35E2B == (3 - 2)) then
				if not (not HasFullControl() or v14['cc'] or v14.buff(45701 - (120 + 143)) or v14['dead'] or v14.buff(36671 + 283553)) then
					FaceDirection(v863, v864);
				end
				break;
			end
		end
	end;
elseif v0['Util']['Draw'] then
	v1.FaceDirection = function(v1062, v1063)
		local FlatIdent_689AC = 1340 - (835 + 505);
		while true do
			if (FlatIdent_689AC == (0 - 0)) then
				v14 = v14 or v1['player'];
				if not (not HasFullControl() or v14['cc'] or v14.buff(90805 - 45367) or v14['dead'] or v14.buff(909890 - 589666)) then
					if (v1063 == "gay") then
						SetHeading(v1062);
					else
						local FlatIdent_6E683 = 876 - (714 + 162);
						while true do
							if (FlatIdent_6E683 == (1072 - (330 + 741))) then
								if not v1['saved']['securityStuff'] then
									SendMovementHeartbeat();
								end
								break;
							end
							if (FlatIdent_6E683 == (0 - 0)) then
								FaceDirection(v1062, false);
								FaceDirection(v1062, true);
								FlatIdent_6E683 = 1 + 0;
							end
						end
					end
				end
				break;
			end
		end
	end;
elseif (v0['type'] == "noname") then
	v1.FaceDirection = function(v1143, v1144)
		local FlatIdent_29B7B = 0 - 0;
		while true do
			if ((1635 - (1131 + 504)) == FlatIdent_29B7B) then
				if not SetPlayerFacing then
					return;
				end
				v14 = v14 or v1['player'];
				FlatIdent_29B7B = 725 - (61 + 663);
			end
			if ((4 - 3) == FlatIdent_29B7B) then
				if not (not HasFullControl() or v14['cc'] or v14.buff(46092 - (595 + 59)) or v14['dead'] or v14.buff(320560 - (6 + 330))) then
					SetPlayerFacing(v1143);
				end
				break;
			end
		end
	end;
end
local v54 = GetCVar("deselectOnClick");
v1.controlFacing = function(v209)
	local FlatIdent_A64E = 0 - 0;
	local v210;
	while true do
		if (FlatIdent_A64E == (399 - (27 + 371))) then
			if not v209 then
				local FlatIdent_4128E = 0 + 0;
				local v865;
				local v866;
				while true do
					if (FlatIdent_4128E == (0 - 0)) then
						v865 = IsMouseButtonDown("RightButton");
						v866 = IsMouseButtonDown("LeftButton");
						FlatIdent_4128E = 1 + 0;
					end
					if (FlatIdent_4128E == (350 - (252 + 97))) then
						if (v865 or v866) then
							local FlatIdent_8C5B3 = 183 - (180 + 3);
							while true do
								if ((0 + 0) == FlatIdent_8C5B3) then
									TurnOrActionStop();
									if not v866 then
										CameraOrSelectOrMoveStop();
									end
									FlatIdent_8C5B3 = 1181 - (1142 + 38);
								end
								if (FlatIdent_8C5B3 == (5 - 3)) then
									function TurnRightStart()
									end
									function TurnLeftStart()
									end
									break;
								end
								if (FlatIdent_8C5B3 == (3 - 2)) then
									CameraOrSelectOrMoveStart();
									TurnOrActionStart = CameraOrSelectOrMoveStart;
									FlatIdent_8C5B3 = 6 - 4;
								end
							end
						else
							local FlatIdent_2690F = 0 - 0;
							while true do
								if (FlatIdent_2690F == (4 - 2)) then
									function TurnLeftStart()
									end
									break;
								end
								if (FlatIdent_2690F == (1 + 0)) then
									TurnOrActionStart = CameraOrSelectOrMoveStart;
									function TurnRightStart()
									end
									FlatIdent_2690F = 1 + 1;
								end
								if (FlatIdent_2690F == (386 - (79 + 307))) then
									TurnOrActionStop();
									CameraOrSelectOrMoveStop();
									FlatIdent_2690F = 51 - (13 + 37);
								end
							end
						end
						v1['releaseFacingTime'] = v1['time'] + (v1['tickRate'] * (2 + 3));
						break;
					end
				end
			end
			if v210 then
				TargetUnit(v210);
			end
			break;
		end
		if (FlatIdent_A64E == (695 - (245 + 450))) then
			SetCVar("deselectOnClick", "0");
			v210 = Object("target");
			FlatIdent_A64E = 1 + 0;
		end
	end
end;
v1.releaseFacing = function()
	local FlatIdent_5E009 = 0 - 0;
	local v211;
	local v218;
	local v219;
	while true do
		if (FlatIdent_5E009 == (0 + 0)) then
			v211 = Object("target");
			CameraSelectOrMoveStart = v1['protected']['CameraSelectOrMoveStart'];
			TurnOrActionStart = v1['protected']['TurnOrActionStart'];
			TurnOrActionStop = v1['protected']['TurnOrActionStop'];
			FlatIdent_5E009 = 718 - (271 + 446);
		end
		if (FlatIdent_5E009 == (2 - 1)) then
			TurnRightStart = v1['protected']['TurnRightStart'];
			TurnLeftStart = v1['protected']['TurnLeftStart'];
			TurnLeftStop = v1['protected']['TurnLeftStop'];
			v218 = IsMouseButtonDown("RightButton");
			FlatIdent_5E009 = 3 - 1;
		end
		if (FlatIdent_5E009 == (2 + 0)) then
			v219 = IsMouseButtonDown("LeftButton");
			if v219 then
				CameraOrSelectOrMoveStart();
			else
				CameraOrSelectOrMoveStop();
			end
			if v218 then
				TurnOrActionStart();
			end
			SetCVar("deselectOnClick", v54);
			FlatIdent_5E009 = 471 - (165 + 303);
		end
		if (FlatIdent_5E009 == (2 + 1)) then
			if v211 then
				TargetUnit(v211);
			end
			break;
		end
	end
end;
if not v1['immerseOL'] then
	v1.immerseOL = function()
	end;
end
v1.StopMoving = function()
	local FlatIdent_36F61 = 1260 - (878 + 382);
	while true do
		if (FlatIdent_36F61 == (1 - 0)) then
			MoveBackwardStop();
			StrafeLeftStop();
			FlatIdent_36F61 = 2 + 0;
		end
		if (FlatIdent_36F61 == (16 - 12)) then
			CameraOrSelectOrMoveStop();
			break;
		end
		if (FlatIdent_36F61 == (0 - 0)) then
			StopAutoRun();
			MoveForwardStop();
			FlatIdent_36F61 = 1 + 0;
		end
		if (FlatIdent_36F61 == (208 - (153 + 52))) then
			TurnRightStop();
			AscendStop();
			FlatIdent_36F61 = 819 - (600 + 215);
		end
		if (FlatIdent_36F61 == (1687 - (1647 + 38))) then
			StrafeRightStop();
			TurnLeftStop();
			FlatIdent_36F61 = 410 - (88 + 319);
		end
	end
end;
if (v0['type'] == "daemonic") then
	local FlatIdent_707E = 0 + 0;
	while true do
		if (FlatIdent_707E == (768 - (743 + 25))) then
			v1.controlMovement = function(v868, v869)
				local FlatIdent_40009 = 415 - (78 + 337);
				while true do
					if (FlatIdent_40009 == (1 + 1)) then
						v1['releaseMovementTime'] = v1['time'] + (v1['tickRate'] * (6 + 0)) + v868;
						break;
					end
					if ((1667 - (421 + 1246)) == FlatIdent_40009) then
						v868 = v868 or (0 - 0);
						v1.StopMoving();
						FlatIdent_40009 = 1357 - (775 + 581);
					end
					if (FlatIdent_40009 == (1 + 0)) then
						if v869 then
							v1.controlFacing(v868);
						end
						if not v1['movementLocked'] then
							local FlatIdent_85526 = 974 - (286 + 688);
							while true do
								if (FlatIdent_85526 == (1868 - (1691 + 177))) then
									for v1103 = 1 + 0, #v51 do
										v52(v51[v1103]);
									end
									v1['movementLocked'] = true;
									break;
								end
							end
						end
						FlatIdent_40009 = 928 - (493 + 433);
					end
				end
			end;
			v1.releaseMovement = function()
				local FlatIdent_6189E = 0 - 0;
				while true do
					if (FlatIdent_6189E == (10 - (6 + 4))) then
						for v944 = 1156 - (711 + 444), #v51 do
							_G[v51[v944]] = v1['protected'][v51[v944]];
						end
						v1['movementLocked'] = nil;
						break;
					end
				end
			end;
			break;
		end
	end
elseif (v0['type'] == "blade") then
	local FlatIdent_7E5C4 = 0 - 0;
	while true do
		if (FlatIdent_7E5C4 == (0 + 0)) then
			v1.controlMovement = function(v1065, v1066)
				local FlatIdent_48A43 = 0 + 0;
				while true do
					if (FlatIdent_48A43 == (1071 - (930 + 141))) then
						v1065 = v1065 or (0 - 0);
						v1.StopMoving();
						FlatIdent_48A43 = 3 - 2;
					end
					if (FlatIdent_48A43 == (341 - (301 + 38))) then
						v1['releaseMovementTime'] = v1['time'] + (v1['tickRate'] * (7 - 1)) + v1065;
						break;
					end
					if (FlatIdent_48A43 == (1 + 0)) then
						if v1066 then
							v1.controlFacing(v1065);
						end
						if not v1['movementLocked'] then
							local FlatIdent_94E2A = 0 - 0;
							while true do
								if (FlatIdent_94E2A == (0 - 0)) then
									for v1168 = 2 - 1, #v51 do
										v52(v51[v1168]);
									end
									v1['movementLocked'] = true;
									break;
								end
							end
						end
						FlatIdent_48A43 = 9 - 7;
					end
				end
			end;
			v1.releaseMovement = function()
				local FlatIdent_2DF8C = 0 + 0;
				while true do
					if (FlatIdent_2DF8C == (990 - (550 + 440))) then
						for v1104 = 1 + 0, #v51 do
							_G[v51[v1104]] = v1['env'][v51[v1104]];
						end
						v1['movementLocked'] = nil;
						break;
					end
				end
			end;
			break;
		end
	end
else
	local FlatIdent_61189 = 863 - (312 + 551);
	while true do
		if (FlatIdent_61189 == (0 + 0)) then
			v1.controlMovement = function(v1069, v1070)
				local FlatIdent_24114 = 547 - (97 + 450);
				while true do
					if (FlatIdent_24114 == (2 + 0)) then
						v1['releaseMovementTime'] = v1['time'] + (v1['tickRate'] * (906 - (127 + 773))) + v1069;
						break;
					end
					if (FlatIdent_24114 == (902 - (78 + 824))) then
						v1069 = v1069 or (0 - 0);
						v1.StopMoving();
						FlatIdent_24114 = 1706 - (768 + 937);
					end
					if (FlatIdent_24114 == (1 + 0)) then
						if v1070 then
							v1.controlFacing();
						end
						if not v1['movementLocked'] then
							local FlatIdent_6170C = 0 - 0;
							while true do
								if (FlatIdent_6170C == (210 - (162 + 48))) then
									for v1169 = 1 + 0, #v51 do
										v52(v51[v1169]);
									end
									v1['movementLocked'] = true;
									break;
								end
							end
						end
						FlatIdent_24114 = 1983 - (1039 + 942);
					end
				end
			end;
			v1.releaseMovement = function()
				local FlatIdent_6435A = 0 + 0;
				while true do
					if (FlatIdent_6435A == (0 + 0)) then
						for v1106 = 1 + 0, #v51 do
							v53(v51[v1106]);
						end
						v1['movementLocked'] = nil;
						break;
					end
				end
			end;
			break;
		end
	end
end
local function v58(v220, v221, v222)
	local FlatIdent_65C77 = 990 - (530 + 460);
	local v223;
	local v224;
	local v225;
	while true do
		if (FlatIdent_65C77 == (9 - 7)) then
			v225 = getmetatable(v220);
			if (not v222 and v225 and v225['__eq']) then
				return v220 == v221;
			end
			FlatIdent_65C77 = 1785 - (1102 + 680);
		end
		if (FlatIdent_65C77 == (1 + 2)) then
			for v518, v519 in pairs(v220) do
				local FlatIdent_168E = 1959 - (1819 + 140);
				local v520;
				while true do
					if (FlatIdent_168E == (1828 - (685 + 1143))) then
						v520 = v221[v518];
						if ((v520 == nil) or not v58(v519, v520)) then
							return false;
						end
						break;
					end
				end
			end
			for v521, v522 in pairs(v221) do
				local FlatIdent_1987A = 0 + 0;
				local v523;
				while true do
					if (FlatIdent_1987A == (0 + 0)) then
						v523 = v220[v521];
						if ((v523 == nil) or not v58(v523, v522)) then
							return false;
						end
						break;
					end
				end
			end
			FlatIdent_65C77 = 1 + 3;
		end
		if (FlatIdent_65C77 == (102 - (48 + 54))) then
			v223 = v5(v220);
			v224 = v5(v221);
			FlatIdent_65C77 = 1 + 0;
		end
		if (FlatIdent_65C77 == (11 - 7)) then
			return true;
		end
		if (FlatIdent_65C77 == (2 - 1)) then
			if (v223 ~= v224) then
				return false;
			end
			if ((v223 ~= "table") and (v224 ~= "table")) then
				return v220 == v221;
			end
			FlatIdent_65C77 = 251 - (108 + 141);
		end
	end
end
v1['deepCompare'] = v58;
v1['latency'] = select(2 + 2, GetNetStats()) / (1313 - (60 + 253));
v1['tickRate'] = (1822 - (23 + 1798)) / GetFramerate();
v1['buffer'] = v1['latency'] + v1['tickRate'];
v1['time'] = GetTime();
v1['losFlags'] = 223 + 49;
v1['collisionFlags'] = 1123 - 850;
v1['timeCache'] = {};
v1['PathTypes'] = {PATHFIND_BLANK=(0 + 0),PATHFIND_NORMAL=(2 - 1),PATHFIND_SHORTCUT=(5 - 3),PATHFIND_INCOMPLETE=(1609 - (389 + 1216)),PATHFIND_NOPATH=(1538 - (1515 + 15)),PATHFIND_NOT_USING_PATH=(4 + 12),PATHFIND_SHORT=(451 - (164 + 255))};
table.pack = function(...)
	return {n=select("#", ...),...};
end;
function show(...)
	local FlatIdent_3CCE7 = 280 - (127 + 153);
	local v226;
	local v227;
	while true do
		if ((0 - 0) == FlatIdent_3CCE7) then
			v226 = "";
			v227 = table.pack(...);
			FlatIdent_3CCE7 = 4 - 3;
		end
		if (FlatIdent_3CCE7 == (1 - 0)) then
			return v227['n'];
		end
	end
end
local v69 = function(v228)
	return (v228 and (1 - 0)) or (768 - (691 + 77));
end;
v1['bin'] = v69;
v1['WARRIOR'] = {};
v1['PALADIN'] = {};
v1['HUNTER'] = {};
v1['ROGUE'] = {};
v1['PRIEST'] = {};
v1['DEATHKNIGHT'] = {};
v1['SHAMAN'] = {};
v1['MAGE'] = {};
v1['WARLOCK'] = {};
v1['MONK'] = {};
v1['DRUID'] = {};
v1['DEMONHUNTER'] = {};
v1['EVOKER'] = {};
local v84 = function()
	if not v1['noRotationPrint'] then
		local FlatIdent_5661D = 0 + 0;
		while true do
			if (FlatIdent_5661D == (0 + 0)) then
				v1.print("No rotation loaded!", true);
				v1['noRotationPrint'] = true;
				break;
			end
		end
	end
end;
local v85, v86 = UnitClass("player");
v1['classRoutines'] = {};
v1['Actors'] = {WARRIOR={},PALADIN={},HUNTER={},ROGUE={},PRIEST={},DEATHKNIGHT={},SHAMAN={},MAGE={},WARLOCK={},MONK={},DRUID={},DEMONHUNTER={},EVOKER={}};
v1.addActor = function(v229, v230)
	v4(v1['Actors'][v230], v229);
end;
v1.addRoutine = function(v231, v232)
	local FlatIdent_25E7F = 0 - 0;
	while true do
		if (FlatIdent_25E7F == (0 + 0)) then
			table.insert(v1[v232], v231);
			if (#v1[v86] > (0 + 0)) then
				for v950, v951 in ipairs(v1[v86]) do
					for v1073 = 1 + 0, 748 - (683 + 61) do
						if (v951[v1073] and not v1['classRoutines'][v1073]) then
							v1['classRoutines'][v1073] = v951[v1073];
						end
					end
				end
			end
			break;
		end
	end
end;
if (#v1[v86] > (0 - 0)) then
	for v873, v874 in ipairs(v1[v86]) do
		for v952 = 3 - 2, 1 + 3 do
			if (v874[v952] and not v1['classRoutines'][v952]) then
				v1['classRoutines'][v952] = v874[v952];
			end
		end
	end
end
local v91 = {};
local v92 = string.random(8 + 2);
_G["SLASH_" .. v92 .. "1"] = "/" .. v1['__username'];
local v93 = #v1['__username'];
for v233 = 968 - (247 + 718), v93 - (1 + 0) do
	_G["SLASH_" .. v92 .. (v233 - (1 + 0))] = "/" .. v1['__username']:sub(1 + 0, v233);
end
if v1['saved']['commands'] then
	for v875, v876 in ipairs(v1['saved'].commands) do
		_G["SLASH_" .. v92 .. ((1749 - (211 + 1534)) + v875)] = "/" .. v876;
	end
end
_G['SlashCmdList'][v92] = function(v234)
	local FlatIdent_5FB22 = 0 + 0;
	while true do
		if ((0 + 0) == FlatIdent_5FB22) then
			if v234:match("command") then
				local FlatIdent_845AE = 1591 - (1514 + 77);
				local v877;
				while true do
					if (FlatIdent_845AE == (1 + 1)) then
						v4(v1['saved'].commands, v877);
						break;
					end
					if (FlatIdent_845AE == (0 - 0)) then
						v877 = v234:match("command (.*)");
						v1.print("New Command Registered: " .. v877);
						FlatIdent_845AE = 1 + 0;
					end
					if (FlatIdent_845AE == (1 + 0)) then
						v1.print("Wait ~10sec, then /reload for it to apply.");
						v1['saved']['commands'] = v1['saved']['commands'] or {};
						FlatIdent_845AE = 2 - 0;
					end
				end
			elseif v234:match("toggle") then
				local FlatIdent_C4A6 = 1199 - (106 + 1093);
				local v1074;
				while true do
					if (FlatIdent_C4A6 == (0 + 0)) then
						v1074 = v234:match("toggle (.*)");
						if (v1074 == "alerts") then
							local FlatIdent_B7F4 = 0 + 0;
							while true do
								if (FlatIdent_B7F4 == (32 - (14 + 18))) then
									v1['saved']['disableAlerts'] = not v1['saved']['disableAlerts'];
									v1.print("Alerts: " .. ((v1['saved']['disableAlerts'] and "OFF") or "ON"));
									FlatIdent_B7F4 = 1 + 0;
								end
								if (FlatIdent_B7F4 == (2 - 1)) then
									return;
								end
							end
						elseif (v1074 == "castalerts") then
							local FlatIdent_83571 = 0 + 0;
							while true do
								if ((0 + 0) == FlatIdent_83571) then
									v1['saved']['disableCastAlerts'] = not v1['saved']['disableCastAlerts'];
									v1.print("Cast Alerts: " .. ((v1['saved']['disableCastAlerts'] and "OFF") or "ON"));
									FlatIdent_83571 = 1058 - (311 + 746);
								end
								if (FlatIdent_83571 == (1153 - (46 + 1106))) then
									return;
								end
							end
						end
						break;
					end
				end
			end
			for v524, v525 in ipairs(v91) do
				v525(v234);
			end
			break;
		end
	end
end;
v1.Command = function(v235, v236, v237)
	local FlatIdent_8552B = 0 + 0;
	local v238;
	local v239;
	local v241;
	while true do
		if (FlatIdent_8552B == (0 - 0)) then
			v238 = v5(v235);
			if (v238 == "string") then
				if ((v235 == "awful") or ((v5(v235) == "string") and v235:lower():match("awful"))) then
					if (v237 ~= "FART") then
						return false;
					end
				end
			elseif (tContains(v235, "awful") and (v237 ~= "FART")) then
				return false;
			end
			FlatIdent_8552B = 1 - 0;
		end
		if (FlatIdent_8552B == (45 - (27 + 16))) then
			v241 = ((v238 == "table") and v235[1970 - (498 + 1471)]) or v235;
			if (v238 == "table") then
				for v953, v954 in ipairs(v235) do
					_G["SLASH_" .. v241 .. v953] = "/" .. v954;
				end
			else
				_G["SLASH_" .. v241 .. "1"] = "/" .. v235;
			end
			FlatIdent_8552B = 4 - 1;
		end
		if (FlatIdent_8552B == (1 + 0)) then
			v239 = {Callbacks={}};
			v239.New = function(v526, v527)
				table.insert(v239.Callbacks, v527);
			end;
			FlatIdent_8552B = 6 - 4;
		end
		if (FlatIdent_8552B == (232 - (205 + 24))) then
			_G['SlashCmdList'][v241] = function(v528)
				local FlatIdent_CC62 = 0 + 0;
				local v529;
				while true do
					if (FlatIdent_CC62 == (1550 - (787 + 763))) then
						v529 = nil;
						for v879, v880 in ipairs(v239.Callbacks) do
							if v880(v528) then
								v529 = true;
							end
						end
						FlatIdent_CC62 = 1 - 0;
					end
					if (FlatIdent_CC62 == (2 - 1)) then
						if (v236 and not v529) then
							for v1075, v1076 in ipairs(v91) do
								v1076(v528);
							end
						end
						break;
					end
				end
			end;
			return v239;
		end
	end
end;
v1.AddSlashAwfulCallback = function(v242)
	table.insert(v91, v242);
end;
local v96 = v1['AddSlashAwfulCallback'];
v1.print("safety measures " .. ((v1['saved']['securityStuff'] and "enabled") or "disabled") .. ".");
v96(function(v243)
	local FlatIdent_1FDC2 = 0 + 0;
	while true do
		if (FlatIdent_1FDC2 == (1286 - (1096 + 189))) then
			v1.print("experimental safety measures " .. ((v1['saved']['securityStuff'] and "enabled") or "disabled") .. ".");
			break;
		end
		if (FlatIdent_1FDC2 == (1697 - (1572 + 125))) then
			if (v243 ~= "yolo") then
				return;
			end
			v1['saved']['securityStuff'] = not v1['saved']['securityStuff'];
			FlatIdent_1FDC2 = 2 - 1;
		end
	end
end);
local v97 = {"t","toggle","enable","on","off","start","go"};
local v98, v99 = 1397 - (397 + 1000), false;
v96(function(v245)
	local FlatIdent_203C = 0 - 0;
	while true do
		if (FlatIdent_203C == (0 - 0)) then
			if (v245 and tContains(v97, v245)) then
				local FlatIdent_71F88 = 0 - 0;
				while true do
					if (FlatIdent_71F88 == (1 + 0)) then
						v1['noSpecPrint'] = nil;
						break;
					end
					if (FlatIdent_71F88 == (0 + 0)) then
						v1['enabled'] = not v1['enabled'];
						v1.print((v1['enabled'] and (v1['colors']['orange'] .. "enabled")) or (v1['colors']['red'] .. "disabled"));
						FlatIdent_71F88 = 1 - 0;
					end
				end
			end
			if (v245 == "damage hack") then
				local FlatIdent_3CB97 = 0 + 0;
				local v883;
				while true do
					if (FlatIdent_3CB97 == (132 - (130 + 2))) then
						v883 = nil;
						function v883(v955)
							print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t [Superkuhk] whispers: " .. v955);
						end
						FlatIdent_3CB97 = 694 - (202 + 491);
					end
					if (FlatIdent_3CB97 == (2 - 1)) then
						v98 = v98 + (1158 - (376 + 767));
						if (not v99 and ((v98 > (59 - 14)) or (math.random(1 + 0, 21 - 11) == (3 + 0)))) then
							local FlatIdent_3C81A = 0 - 0;
							while true do
								if (FlatIdent_3C81A == (1 + 0)) then
									C_Timer.After(58 - 44, function()
										local FlatIdent_7834B = 1970 - (958 + 1012);
										while true do
											if (FlatIdent_7834B == (1241 - (416 + 825))) then
												PlaySound(2876 + 205);
												v883("We just detected unauthorized third party software usage. An account closure will be issued momentarily. Please find a safe place to exit the game or we'll be forced to remove you ourselves.");
												break;
											end
										end
									end);
									v1.print("Damage Hack: Your damage is increased by " .. v1['colors']['orange'] .. v98 .. "%|r - Run again to increase it further.");
									break;
								end
								if (FlatIdent_3C81A == (0 + 0)) then
									v99 = true;
									C_Timer.After(13 - 6, function()
										local FlatIdent_43360 = 0 + 0;
										while true do
											if ((1423 - (670 + 753)) == FlatIdent_43360) then
												PlaySound(1037 + 2044);
												v883("Hey, " .. UnitName("player") .. ". Got a moment?");
												break;
											end
										end
									end);
									FlatIdent_3C81A = 1 + 0;
								end
							end
						else
							v1.print("Damage Hack: Your damage is increased by " .. v1['colors']['orange'] .. v98 .. "%|r - Run again to increase it further.");
						end
						break;
					end
				end
			end
			FlatIdent_203C = 1227 - (1117 + 109);
		end
		if (FlatIdent_203C == (1066 - (517 + 548))) then
			if (SecureCmdOptionParse(v245) == "pause") then
				v1['pause'] = v1['time'];
			end
			break;
		end
	end
end);
v1['autoCC'] = true;
v96(function(v246)
	local FlatIdent_B8F4 = 0 + 0;
	while true do
		if (FlatIdent_B8F4 == (0 - 0)) then
			if (v246:lower() == "burst") then
				local FlatIdent_832F = 1126 - (541 + 585);
				while true do
					if (FlatIdent_832F == (0 - 0)) then
						v1['burst'] = v1['time'] + (536 - (164 + 368));
						v1['burst_pressed'] = v1['time'];
						FlatIdent_832F = 1251 - (502 + 748);
					end
					if ((1536 - (275 + 1260)) == FlatIdent_832F) then
						PlaySound(28984 - 10725);
						break;
					end
				end
			elseif (v246:lower() == "clearconfig") then
				local FlatIdent_6F38F = 0 - 0;
				local v1077;
				while true do
					if ((0 - 0) == FlatIdent_6F38F) then
						v1077 = v1['__cfg__records'];
						if v1077 then
							local FlatIdent_214F9 = 1500 - (196 + 1304);
							while true do
								if (FlatIdent_214F9 == (1571 - (1421 + 150))) then
									v1.print("Clearing config... Please wait ~10sec, then /reload.");
									for v1170, v1171 in pairs(v1077) do
										local FlatIdent_C257 = 0 + 0;
										local v1172;
										while true do
											if (FlatIdent_C257 == (0 - 0)) then
												v1172 = v1171['_OG'];
												if v1172 then
													for v1209, v1210 in pairs(v1172) do
														v1171[v1209] = nil;
													end
												end
												break;
											end
										end
									end
									FlatIdent_214F9 = 1 + 0;
								end
								if (FlatIdent_214F9 == (1743 - (657 + 1085))) then
									C_Timer.After(1852 - (783 + 1057), function()
										v1.print("Config should be cleared. Try /reload");
									end);
									break;
								end
							end
						end
						break;
					end
				end
			end
			if (v246:lower() == "cc") then
				local FlatIdent_2FC27 = 0 - 0;
				while true do
					if (FlatIdent_2FC27 == (1724 - (1189 + 535))) then
						v1['autoCC'] = not v1['autoCC'];
						v1.print("Auto CC " .. ((v1['autoCC'] and "Enabled") or "Disabled"), not v1['autoCC']);
						break;
					end
				end
			end
			break;
		end
	end
end);
v96(function(v247)
	if (v247 == "docs") then
		print("oopsie we forgot to add this");
	end
end);
v96(function(v248)
	if (v248 == "afk") then
		v1['AntiAFK']:Toggle();
	end
end);
v1['MacrosQueued'] = {};
v1.RegisterMacro = function(v249, v250, v251)
	local FlatIdent_62F34 = 0 - 0;
	while true do
		if (FlatIdent_62F34 == (0 + 0)) then
			if tContains(v97, v249) then
				local FlatIdent_331EE = 0 - 0;
				while true do
					if (FlatIdent_331EE == (1678 - (833 + 845))) then
						v1.print("You can't use the toggle words for your thing, sorry");
						return;
					end
				end
			end
			v96(function(v530)
				if (v530 == v249) then
					if (not v251 or ((v5(v251) ~= "function") and v251) or v251()) then
						if (v250 ~= nil) then
							if (v5(v250) == "number") then
								v1['MacrosQueued'][v249] = v1['time'] + v250;
							elseif not v250 then
								v1['MacrosQueued'][v249] = nil;
							else
								v1['MacrosQueued'][v249] = v1['time'] + (9611 - 7611);
							end
						else
							local FlatIdent_69176 = 0 + 0;
							while true do
								if (FlatIdent_69176 == (0 - 0)) then
									v250 = (tonumber(GetCVar("SpellQueueWindow")) / (1843 - (83 + 760))) + 0.115 + 0;
									v1['MacrosQueued'][v249] = v1['time'] + v250;
									break;
								end
							end
						end
					end
				end
			end);
			break;
		end
	end
end;
local function v103(v252, v253)
	local FlatIdent_491EE = 0 - 0;
	while true do
		if (FlatIdent_491EE == (0 - 0)) then
			for v531 = 1 - 0, #v253 do
				v252[#v252 + (3 - 2)] = v253[v531];
			end
			return v252;
		end
	end
end
v1['tjoin'] = v103;
v1['ManualSpellObjects'] = {};
v1['ManualSpellQueues'] = {};
local function v107(v254, v255)
	local FlatIdent_69E50 = 904 - (385 + 519);
	while true do
		if (FlatIdent_69E50 == (2 - 1)) then
			return result;
		end
		if ((0 - 0) == FlatIdent_69E50) then
			result = {};
			for v534 in (v254 .. v255):gmatch("(.-)" .. v255) do
				table.insert(result, v534);
			end
			FlatIdent_69E50 = 1 + 0;
		end
	end
end
v1['DrawCallbacks'] = {};
v1.Draw = function(v256)
	local FlatIdent_5D1A0 = 0 - 0;
	local v257;
	while true do
		if ((1 - 0) == FlatIdent_5D1A0) then
			v257.Disable = function(v536)
				v536['enabled'] = false;
			end;
			v257.Enable = function(v538)
				v538['enabled'] = true;
			end;
			FlatIdent_5D1A0 = 1834 - (515 + 1317);
		end
		if (FlatIdent_5D1A0 == (9 - 7)) then
			v257.Toggle = function(v540)
				v540['enabled'] = not v540['active'];
			end;
			v4(v1.DrawCallbacks, v257);
			FlatIdent_5D1A0 = 528 - (10 + 515);
		end
		if (FlatIdent_5D1A0 == (10 - 7)) then
			return v257;
		end
		if (FlatIdent_5D1A0 == (0 - 0)) then
			v257 = {callback=v256,enabled=true};
			v257 = setmetatable(v257, {__call=function(v535, ...)
				if v535['enabled'] then
					v535.callback(...);
				end
			end});
			FlatIdent_5D1A0 = 2 - 1;
		end
	end
end;
local v110 = {"focus","target","healer","player","cursor","ourhealer","friendlyhealer","enemyhealer"};
local v111 = {[5285 - 3146]={ignoreFacing=true,effect="magic",targeted=true},[16019 + 3628]={effect="magic",targeted=true,ignoreFacing=true},[91936 + 14903]={effect="physical"},[2205 + 4347]={effect="physical"},[301413 - 154051]={effect="physical",ranged=true},[317447 - 129740]={effect="physical"},[566 + 1200]={effect="physical"},[45651 + 50580]={effect="physical"},[79993 - (1228 + 90)]={effect="magic",ignoreFacing=true},[175740 - 117746]={effect="magic",targeted=true},[117784 - (1030 + 49)]={effect="physical"},[16496 + 167256]={effect="magic",targeted=true},[168944 - 121416]={effect="magic",targeted=true},[164441 - 83477]={effect="physical",targeted=true},[76132 + 4833]={effect="physical",targeted=true}};
local v112 = {};
local v113 = {[108666 + 5058]={effect="magic",targeted=false,ignoreFacing=true,cc=true,diameter=(103 - (32 + 65)),minDist=(1980.8 - (1206 + 770)),maxDist=(10.2 - 5),ignoreFriends=true,maxHit=(2426 - 1427),filter=function(v261, v262, v263)
	local FlatIdent_2E341 = 0 + 0;
	while true do
		if (FlatIdent_2E341 == (0 + 0)) then
			if (v261['idr'] < (1758 - (630 + 1127))) then
				return "avoid";
			end
			if ((v262 < (3.3499999999999996 + 2)) and (v262 > (4.65 + 0)) and (v261['cc'] or v261['rooted'] or v261['casting'] or not v261['moving'])) then
				return true;
			end
			break;
		end
	end
end,presort=function()
	v112 = {};
end,sort=function(v264, v265)
	local FlatIdent_12617 = 0 - 0;
	while true do
		if (FlatIdent_12617 == (1850 - (286 + 1563))) then
			return (v264['hit'] > v265['hit']) or ((v264['hit'] == v265['hit']) and ((v264['hit'] + v112[v264['x']]) > (v265['hit'] + v112[v265['x']])));
		end
		if ((1775 - (1224 + 551)) == FlatIdent_12617) then
			v112[v264['x']] = v112[v264['x']] or v48(1 + 0, 111 + 9);
			v112[v265['x']] = v112[v265['x']] or v48(2 - 1, 305 - 185);
			FlatIdent_12617 = 1323 - (998 + 324);
		end
	end
end},[757411 - 404329]={damage="magic",effect="magic",targeted=false,diameter=(33 - 25),minDist=(10.5 - 5),maxDist=(6.5 + 0),maxHit=(383 + 616),ignoreFriends=true,filter=function(v268, v269, v270)
	local FlatIdent_CDB9 = 962 - (938 + 24);
	while true do
		if ((2 - 1) == FlatIdent_CDB9) then
			if ((v269 < (1261.5 - (174 + 1081))) and (v269 > (19.5 - 14))) then
				return true;
			end
			break;
		end
		if (FlatIdent_CDB9 == (0 + 0)) then
			if ((v269 < (9 + 1)) and (v269 > (1601.75 - (354 + 1245))) and v268['bcc']) then
				return false;
			end
			if ((v269 < (14 - 4)) and (v269 > (1 + 2)) and v268['healer'] and v268['cc'] and ((v268['idr'] == (3 - 2)) or (v268['idrr'] < (2 + 1)))) then
				return "avoid";
			end
			FlatIdent_CDB9 = 1 - 0;
		end
	end
end,presort=function()
	v112 = {};
end,sort=function(v271, v272)
	local FlatIdent_ED54 = 0 - 0;
	while true do
		if ((1 - 0) == FlatIdent_ED54) then
			return (v271['hit'] > v272['hit']) or ((v271['hit'] == v272['hit']) and ((v271['hit'] + v112[v271['x']]) > (v272['hit'] + v112[v272['x']])));
		end
		if (FlatIdent_ED54 == (0 - 0)) then
			v112[v271['x']] = v112[v271['x']] or v48(2 - 1, 73 + 47);
			v112[v272['x']] = v112[v272['x']] or v48(564 - (48 + 515), 309 - 189);
			FlatIdent_ED54 = 1 + 0;
		end
	end
end}};
v1.import = function(...)
	local FlatIdent_22B79 = 0 + 0;
	local v275;
	local v276;
	local v277;
	while true do
		if (FlatIdent_22B79 == (1 + 1)) then
			function v277(v544)
				local FlatIdent_62C11 = 818 - (130 + 688);
				while true do
					if (FlatIdent_62C11 == (0 - 0)) then
						for v891, v892 in pairs(v276) do
							if ((v5(v891) == "string") and (v5(v892) == "string")) then
								v275[v891] = v544[v892];
							elseif (v5(v891) == "string") then
								v275[v891] = v544[v891];
							elseif (v5(v892) == "string") then
								v275[v892] = v544[v892];
							end
						end
						return {plus=v1['import']};
					end
				end
			end
			return {from=v277};
		end
		if (FlatIdent_22B79 == (0 + 0)) then
			v275 = getfenv(1 + 1);
			v276 = {...};
			FlatIdent_22B79 = 1623 - (1125 + 497);
		end
		if (FlatIdent_22B79 == (1 + 0)) then
			if (v5(v276[3 - 2]) == "table") then
				v276 = v276[1610 - (628 + 981)];
			end
			for v542, v543 in pairs(v276) do
				if ((v5(v542) == "string") and (v5(v543) == "string")) then
					v275[v542] = v1[v543];
				elseif (v5(v542) == "string") then
					v275[v542] = v1[v542];
				elseif (v5(v543) == "string") then
					v275[v543] = v1[v543];
				end
			end
			FlatIdent_22B79 = 560 - (146 + 412);
		end
	end
end;
local v115;
local v116;
local v117 = {(7174 - (653 + 1275)),(510 + 5272),(426519 - 168728),(13266 - 6908),(14324 - 6202),(2203 - 1598),(631104 - 270298)};
local v118;
local v119;
v1.SafeTrinket = function(v278)
	local FlatIdent_8D13E = 1611 - (61 + 1550);
	while true do
		if (FlatIdent_8D13E == (1665 - (42 + 1618))) then
			UseItemByName(tostring(GetItemInfo(18191 + 46603) or "Bloodthirsty Gladiator's Medallion of Tenacity"));
			UseItemByName(tostring(GetItemInfo(65981 - (948 + 244)) or "Bloodthirsty Gladiator's Medallion of Cruelty"));
			UseItemByName(tostring(GetItemInfo(146982 - 86181) or "Vicious Gladiator's Medallion of Cruelty"));
			FlatIdent_8D13E = 271 - (208 + 57);
		end
		if (FlatIdent_8D13E == (0 - 0)) then
			if (v1['hasControl'] and not v1['player']['cc'] and not v1['player']['disarm'] and not v1['player']['rooted']) then
				return v278 and v1.alert("Held Trinket, No CC");
			end
			v116 = v116 or v1.NewSpell(56683 + 3069, {ignoreCC=true});
			v115 = v115 or v1.NewSpell(22857 - 15113, {ignoreCC=true});
			FlatIdent_8D13E = 2 - 1;
		end
		if (FlatIdent_8D13E == (1 + 1)) then
			UseItemByName(tostring(GetItemInfo(154200 + 64222) or "Forged Aspirant's Medallion"));
			UseItemByName(tostring(GetItemInfo(735254 - 516538) or "Forged Gladiator's Medallion"));
			UseItemByName(tostring(GetItemInfo(139353 + 76929) or "Draconic Gladiator's Medallion"));
			FlatIdent_8D13E = 504 - (461 + 40);
		end
		if ((8 - 4) == FlatIdent_8D13E) then
			UseItemByName(tostring(GetItemInfo(210345 - (32 + 549)) or "Verdant Aspirant's Medallion"));
			UseItemByName(tostring(GetItemInfo(207433 + 874) or "Verdant Combatant's Medallion"));
			UseItemByName(tostring(GetItemInfo(66689 - (750 + 1147)) or "Bloodthirsty Gladiator's Medallion of Meditation"));
			FlatIdent_8D13E = 14 - 9;
		end
		if (FlatIdent_8D13E == (7 - 1)) then
			UseItemByName(tostring(GetItemInfo(53309 + 7497) or "Vicious Gladiator's Medallion of Meditation"));
			UseItemByName(tostring(GetItemInfo(112600 - 51793) or "Vicious Gladiator's Medallion of Tenacity"));
			break;
		end
		if ((1 + 0) == FlatIdent_8D13E) then
			if v278 then
				v1.alert("Pressing Trinket!");
			end
			if ((v1['player']['race'] == "Human") and (v116['cd'] <= (0 - 0)) and v1['player']['stunned'] and v116:Cast()) then
				return;
			end
			if ((v1['player']['race'] == "Undead") and (v115['cd'] <= (269 - (267 + 2))) and v1['player'].debuffFrom(v117) and v115:Cast()) then
				return;
			end
			FlatIdent_8D13E = 4 - 2;
		end
		if ((1027 - (827 + 197)) == FlatIdent_8D13E) then
			UseItemByName(tostring(GetItemInfo(130295 + 86074) or "Draconic Aspirant's Medallion"));
			UseItemByName(tostring(GetItemInfo(1030284 - 818678) or "Draconic Combatant's Medallion"));
			UseItemByName(tostring(GetItemInfo(414759 - 205413) or "Verdant Gladiator's Medallion"));
			FlatIdent_8D13E = 8 - 4;
		end
	end
end;
v96(function(v279)
	local FlatIdent_6ADD0 = 0 - 0;
	while true do
		if (FlatIdent_6ADD0 == (0 - 0)) then
			if (v279 ~= "trinket") then
				return;
			end
			v1.SafeTrinket(true);
			break;
		end
	end
end);
v1.manualCastHandler = function(v280, v281)
	local FlatIdent_418EE = 0 + 0;
	local v282;
	local v283;
	while true do
		if (FlatIdent_418EE == (1709 - (1083 + 626))) then
			v282, v283 = SecureCmdOptionParse(v280);
			if (v281 and not v1.IsSpellOnGCD(v282)) then
				return;
			end
			FlatIdent_418EE = 1 + 0;
		end
		if (FlatIdent_418EE == (2 - 1)) then
			if (tonumber(v282) and (tonumber(v282) < (11 + 12))) then
				local FlatIdent_1B5AF = 688 - (321 + 367);
				local v893;
				local v894;
				while true do
					if (FlatIdent_1B5AF == (0 + 0)) then
						v893 = tonumber(v282);
						v894 = GetInventoryItemID("player", v893);
						FlatIdent_1B5AF = 2 - 1;
					end
					if ((1903 - (1198 + 704)) == FlatIdent_1B5AF) then
						if v894 then
							v1['ManualSpellQueues'][v894] = {time=v1['time'],expires=(v1['time'] + (GetCVar("SpellQueueWindow") / (115 + 885)) + (0.35 - 0)),target=v283,item={id=v894,name=tostring(GetItemInfo(v894)),cd=function()
								return v1.GetItemCD(v894);
							end,slot=v893,texture=select(358 - (225 + 123), GetItemInfo(v894))}};
						end
						break;
					end
				end
			else
				local v895 = tonumber(v282) or select(10 - 3, v1['dep'].GetSpellInfo(v282));
				if v895 then
					local FlatIdent_272CB = 361 - (243 + 118);
					local v1081;
					local v1082;
					local v1083;
					while true do
						if (FlatIdent_272CB == (4 - 2)) then
							v1082 = v113[v895];
							v1083 = nil;
							FlatIdent_272CB = 8 - 5;
						end
						if (FlatIdent_272CB == (1 + 0)) then
							if ((v895 == (12910 - (1307 + 237))) and not v1['player'].buff(44569 + 3539) and not v1['player'].buff(421441 - 151790)) then
								return;
							end
							if ((v895 == (8084 - 5439)) and v1['player'].buff(v895)) then
								local FlatIdent_4C084 = 0 - 0;
								while true do
									if (FlatIdent_4C084 == (1598 - (1272 + 326))) then
										v1['protected'].RunMacroText("/cancelaura " .. v1['dep'].GetSpellInfo(3143 - (279 + 219)));
										return;
									end
								end
							end
							FlatIdent_272CB = 1018 - (309 + 707);
						end
						if (FlatIdent_272CB == (0 - 0)) then
							v1081 = v111[v895];
							if not v1081 then
								for v1176, v1177 in pairs(v111) do
									if (v1['dep'].GetSpellInfo(v1176) == v1['dep'].GetSpellInfo(v895)) then
										v1081 = v1177;
										break;
									end
								end
							end
							FlatIdent_272CB = 182 - (112 + 69);
						end
						if (FlatIdent_272CB == (690 - (162 + 525))) then
							if not v1['ManualSpellObjects'][v895] then
								local FlatIdent_1898C = 176 - (162 + 14);
								while true do
									if (FlatIdent_1898C == (0 + 0)) then
										if (v895 == (640 - 232)) then
											v1083 = v1.NewSpell(v895, {effect="physical",cc="stun"});
										else
											v1083 = v1.NewSpell(v895, v1082 or v1081 or {ignoreFacing=true,castableInCC=true});
										end
										v1['ManualSpellObjects'][v895] = v1083;
										break;
									end
								end
							else
								v1083 = v1['ManualSpellObjects'][v895];
							end
							v1['ManualSpellQueues'][v895] = {time=v1['time'],expires=(((v1['time'] + (GetCVar("SpellQueueWindow") / (1759 - (329 + 430))) + (895.6 - (141 + 754))) - (v69(v1081 or v1['saved']['helloxen']) * (0.5 + 0))) - (v69((v895 == (55113 - 23452)) and not v1['saved']['helloxen']) * (0.25 - 0))),obj=v1083,target=v283,isKick=v1081,isAoE=v1082,stopCastToFinish=(v895 == (46409 - (783 + 188)))};
							break;
						end
					end
				end
			end
			break;
		end
	end
end;
v96(function(v284)
	local FlatIdent_8B26E = 0 + 0;
	while true do
		if (FlatIdent_8B26E == (1 - 0)) then
			v1.manualCastHandler(v284);
			break;
		end
		if (FlatIdent_8B26E == (1597 - (594 + 1003))) then
			if not v284:match("cast") then
				return;
			end
			v284 = v284:gsub("cast ", "");
			FlatIdent_8B26E = 821 - (318 + 502);
		end
	end
end);
v1.queueSpell = function(v285, v286, v287)
	local FlatIdent_FCD5 = 263 - (252 + 11);
	local v288;
	while true do
		if (FlatIdent_FCD5 == (1853 - (774 + 1077))) then
			v1['ManualSpellQueues'][v285] = {time=v1['time'],expires=(v1['time'] + v287),obj=v288,target=v286};
			break;
		end
		if (FlatIdent_FCD5 == (600 - (147 + 452))) then
			v288 = nil;
			if not v1['ManualSpellObjects'][v285] then
				local FlatIdent_695D6 = 0 - 0;
				while true do
					if (FlatIdent_695D6 == (0 + 0)) then
						v288 = v1.NewSpell(v285, isAoE or isKick or {ignoreFacing=true,castableInCC=true});
						v1['ManualSpellObjects'][v285] = v288;
						break;
					end
				end
			else
				v288 = v1['ManualSpellObjects'][v285];
			end
			FlatIdent_FCD5 = 2 + 0;
		end
		if (FlatIdent_FCD5 == (836 - (313 + 523))) then
			v287 = v287 or (3 + 0);
			if ((v285 == (12798 - 10153)) and v1['player'].buff(v285)) then
				local FlatIdent_6438B = 0 - 0;
				local v896;
				while true do
					if (FlatIdent_6438B == (4 - 3)) then
						return;
					end
					if ((0 - 0) == FlatIdent_6438B) then
						v896 = v1['player']['buffs'];
						for v958 = 1 - 0, #v896 do
							local FlatIdent_501DA = 0 + 0;
							local v959;
							while true do
								if (FlatIdent_501DA == (0 + 0)) then
									v959 = v896[v958];
									if (v959[9 + 1] == v285) then
										return CancelUnitBuff("player", v958);
									end
									break;
								end
							end
						end
						FlatIdent_6438B = 1048 - (805 + 242);
					end
				end
			end
			FlatIdent_FCD5 = 1658 - (62 + 1595);
		end
	end
end;
local v123 = {(3193 - 1680),(4401 + 845),(14150 - 8368),(207514 - 88815),(2012 + 8314),(11589 - 3467),(8193 - (308 + 1096))};
local v124;
v1.addUpdateCallback(function()
	local FlatIdent_8532C = 0 - 0;
	local v290;
	local v291;
	while true do
		if (FlatIdent_8532C == (1021 - (345 + 676))) then
			v290 = v1['time'];
			v291 = nil;
			FlatIdent_8532C = 1 - 0;
		end
		if ((1 + 1) == FlatIdent_8532C) then
			for v547, v548 in pairs(v1.ManualSpellQueues) do
				local FlatIdent_2A653 = 1599 - (1450 + 149);
				local v549;
				local v550;
				while true do
					if ((2 - 1) == FlatIdent_2A653) then
						if (v550 or (v548['expires'] < v1['time'])) then
							v1['ManualSpellQueues'][v547] = nil;
						else
							local v963 = v548['obj'];
							local v964 = v548['item'];
							local v965 = v548['isKick'];
							local v966;
							if (v5(v548.target) == "table") then
								v966 = v548['target'];
							elseif (v548['target'] == "target") then
								v966 = v1['target'];
							elseif (v548['target'] == "focus") then
								v966 = v1['focus'];
							elseif ((v548['target'] == "healer") or (v548['target'] == "enemyhealer")) then
								v966 = v1['enemyHealer'];
							elseif ((v548['target'] == "ourhealer") or (v548['target'] == "friendlyhealer")) then
								v966 = v1['healer'];
							elseif (v548['target'] == "player") then
								v966 = v1['player'];
							elseif (v548['target'] == "fdps") then
								v1['group'].loop(function(v1246)
									local FlatIdent_69450 = 597 - (134 + 463);
									while true do
										if (FlatIdent_69450 == (285 - (90 + 195))) then
											if not v1246['visible'] then
												return false;
											end
											if v1246['healer'] then
												return false;
											end
											FlatIdent_69450 = 1 + 0;
										end
										if (FlatIdent_69450 == (392 - (168 + 223))) then
											v966 = v1246;
											return true;
										end
									end
								end);
							elseif (v548['target'] == "partylowest") then
								local FlatIdent_40097 = 0 + 0;
								local v1247;
								while true do
									if (FlatIdent_40097 == (1 - 0)) then
										v966 = v1['fgroup'].within(29 + 11).filter(v1247)['lowest'];
										break;
									end
									if (FlatIdent_40097 == (550 - (67 + 483))) then
										v1247 = nil;
										function v1247(v1250)
											return v1250['los'];
										end
										FlatIdent_40097 = 3 - 2;
									end
								end
							elseif (v548['target'] == "enemylowest") then
								v966 = v1['enemies']['lowest'];
							elseif (v548['target'] == "offdps") then
								v1['enemies'].loop(function(v1254)
									local FlatIdent_7B9B8 = 1960 - (206 + 1754);
									while true do
										if (FlatIdent_7B9B8 == (0 + 0)) then
											if v1254['healer'] then
												return false;
											end
											if v1254.isUnit(v1.target) then
												return false;
											end
											FlatIdent_7B9B8 = 1 + 0;
										end
										if ((115 - (46 + 68)) == FlatIdent_7B9B8) then
											if v1254.isUnit(v1.focus) then
												return false;
											end
											v966 = v1254;
											FlatIdent_7B9B8 = 2 + 0;
										end
										if (FlatIdent_7B9B8 == (1 + 1)) then
											return true;
										end
									end
								end);
							elseif (v548['target'] and (v548['target'] ~= "cursor")) then
								local FlatIdent_2CE82 = 0 - 0;
								local v1256;
								while true do
									if (FlatIdent_2CE82 == (0 + 0)) then
										v966 = v1[v548['target']];
										v1256 = v548['target']:lower();
										FlatIdent_2CE82 = 1 - 0;
									end
									if ((1 - 0) == FlatIdent_2CE82) then
										v1['fgroup'].loop(function(v1258)
											local FlatIdent_42E5C = 0 + 0;
											local v1259;
											while true do
												if (FlatIdent_42E5C == (795 - (259 + 536))) then
													if not v1258['visible'] then
														return false;
													end
													v1259 = v1258['name'] and v1258['name']:lower();
													FlatIdent_42E5C = 1 + 0;
												end
												if (FlatIdent_42E5C == (1 + 0)) then
													if (v1259 == v1256) then
														local FlatIdent_17CBE = 0 + 0;
														while true do
															if ((0 - 0) == FlatIdent_17CBE) then
																v966 = v1258;
																return true;
															end
														end
													end
													break;
												end
											end
										end);
										if not v966 then
											return;
										end
										break;
									end
								end
							end
							if (v963 and ((v963['id'] == (141 - 23)) or (v963['id'] == (72368 + 41356))) and ((v1['player']['castID'] == (337 - 204)) or (v1['player']['castID'] == (4781 - (518 + 1315))))) then
								if (v1['player']['castRemains'] > (189.5 - (156 + 33))) then
									if ((v963['cd'] <= v1['gcdRemains']) and v963:Castable(v966, {spam=true})) then
										SpellStopCasting();
									end
								end
							end
							if (v963 and (v963['id'] == (46076 - (45 + 593))) and v1['player'].buff(134969 - 89531)) then
								return;
							end
							if (v963 and (v963['id'] == (778 - 370)) and (v963['cd'] <= (0.65 + 0))) then
								local FlatIdent_50930 = 0 + 0;
								while true do
									if (FlatIdent_50930 == (0 + 0)) then
										v966 = v966 or v1['target'];
										if (v1['player']['cp'] < (10 - 6)) then
											local FlatIdent_7CC59 = 1590 - (109 + 1481);
											while true do
												if ((0 + 0) == FlatIdent_7CC59) then
													v124 = v124 or v1.NewSpell(282490 - 144871, {ignoreFacing=true});
													v1['enemies'].loop(function(v1194)
														return v124:CastAlert(v1194);
													end);
													FlatIdent_7CC59 = 3 - 2;
												end
												if (FlatIdent_7CC59 == (3 - 2)) then
													if v1['target']['enemy'] then
														v124:Cast(v1.target);
													end
													if v1['focus']['enemy'] then
														v124:Cast(v1.focus);
													end
													FlatIdent_7CC59 = 4 - 2;
												end
												if (FlatIdent_7CC59 == (5 - 3)) then
													if v1['enemyHealer']['enemy'] then
														v124:Cast(v1.enemyHealer);
													end
													return;
												end
											end
										end
										break;
									end
								end
							end
							if (v548['stopCastToFinish'] and (v1['player']['casting'] or v1['player']['channeling']) and (v963['cd'] <= (v1['gcdRemains'] + (0.1 - 0)))) then
								local FlatIdent_369D5 = 0 - 0;
								while true do
									if (FlatIdent_369D5 == (61 - (33 + 28))) then
										SpellStopCasting();
										if (v963['id'] == (108649 - 63211)) then
											local FlatIdent_1BAD6 = 0 - 0;
											while true do
												if (FlatIdent_1BAD6 == (3 - 2)) then
													v963['cacheLiteral']['cd'] = true;
													break;
												end
												if (FlatIdent_1BAD6 == (0 - 0)) then
													if (v5(v1.actor) == "table") then
														v1['actor']['paused'] = GetTime() + v1['buffer'] + (0.15 - 0);
													end
													v963['cd'] = 49 - (39 + 10);
													FlatIdent_1BAD6 = 1266 - (308 + 957);
												end
											end
										end
										break;
									end
								end
							end
							if v963 then
								if (v963['cd'] <= v1['spellCastBuffer']) then
									if v965 then
										local FlatIdent_3031C = 0 + 0;
										while true do
											if (FlatIdent_3031C == (0 + 0)) then
												v966 = v966 or v1['target'];
												if (v966['exists'] and ((not v966['casting'] and not v966['channeling']) or (v966['casting'] and (v966['castint'] ~= false)) or (v966['channeling'] and (v966['channelint'] ~= false)))) then
													local FlatIdent_3C4A3 = 0 + 0;
													while true do
														if (FlatIdent_3C4A3 == (0 - 0)) then
															v1.alert("Holding " .. v963['name'], v963.id);
															return;
														end
													end
												elseif v963:Castable(v966, {ignoreCasting=true,ignoreChanneling=true}) then
													if (v1['player']['casting'] or v1['player']['channeling']) then
														SpellStopCasting();
													end
												end
												break;
											end
										end
									end
									if v966 then
										local FlatIdent_523D6 = 450 - (227 + 223);
										while true do
											if (FlatIdent_523D6 == (0 - 0)) then
												v1.call("SpellCancelQueuedSpell");
												if v548['isAoE'] then
													local FlatIdent_57AA9 = 231 - (65 + 166);
													local v1218;
													local v1219;
													local v1220;
													local v1221;
													local v1222;
													while true do
														if (FlatIdent_57AA9 == (0 - 0)) then
															v1218 = (v963['id'] == (114339 - (426 + 189))) and {movePredTime=((v966.debuffFrom(v123) and (v963['castTime'] + v1['buffer'])) or (0 - 0))};
															v1219, v1220, v1221, v1222 = v963:SmartAoEPosition(v966, v1218);
															FlatIdent_57AA9 = 1 + 0;
														end
														if ((1 - 0) == FlatIdent_57AA9) then
															if (v1221 and v963:AoECast(v1219, v1220, v1221)) then
																local FlatIdent_69B8F = 0 - 0;
																while true do
																	if (FlatIdent_69B8F == (0 - 0)) then
																		v1.alert(v963['name'] .. " " .. v966['classString'] .. " [Manual]", v963.id);
																		if (v5(v1.actor) == "table") then
																			v1['actor']['ringIntent'] = {id=v963['id'],x=v1219,y=v1220,z=v1221,hitList=v1222,time=v290,target=v966};
																		end
																		break;
																	end
																end
															end
															break;
														end
													end
												elseif v963:Cast(v966, v548.options) then
													if SpellIsTargeting() then
														local FlatIdent_4F0EE = 0 + 0;
														local v1233;
														local v1234;
														local v1235;
														while true do
															if (FlatIdent_4F0EE == (0 + 0)) then
																v1233, v1234, v1235 = v966.position();
																Click(v1233, v1234, v1235);
																FlatIdent_4F0EE = 1413 - (1034 + 378);
															end
															if (FlatIdent_4F0EE == (729 - (208 + 520))) then
																if not v1['saved']['disableCastAlerts'] then
																	v1.alert(v963['name'] .. " [Manual AoE]", v963.id);
																end
																break;
															end
														end
													elseif not v1['saved']['disableCastAlerts'] then
														v1.alert(v963['name'] .. " [Manual]", v963.id);
													end
												end
												break;
											end
										end
									else
										local FlatIdent_30699 = 0 - 0;
										while true do
											if (FlatIdent_30699 == (155 - (145 + 10))) then
												v1.call("SpellCancelQueuedSpell");
												if v963:Cast(nil, v548.options) then
													if SpellIsTargeting() then
														local FlatIdent_76C72 = 0 - 0;
														local v1225;
														local v1226;
														local v1227;
														local v1228;
														local v1229;
														local v1230;
														while true do
															if (FlatIdent_76C72 == (0 + 0)) then
																v1225, v1226, v1227 = v1.CursorPosition();
																v1228, v1229, v1230 = v1['player'].position();
																FlatIdent_76C72 = 1 - 0;
															end
															if (FlatIdent_76C72 == (1 - 0)) then
																if (v1225 and v1228) then
																	local FlatIdent_2F451 = 0 - 0;
																	local v1236;
																	local v1237;
																	local v1238;
																	local v1239;
																	while true do
																		if (FlatIdent_2F451 == (2 + 0)) then
																			if ((v1238 - v1230) > (49 - 31)) then
																				local FlatIdent_1A656 = 784 - (316 + 468);
																				while true do
																					if (FlatIdent_1A656 == (1398 - (301 + 1097))) then
																						if not v1['saved']['disableCastAlerts'] then
																							v1.alert(v1['colors']['red'] .. "[Not Casting] - |r" .. v963['name'] .. " [Cursor In Skybox]", v963.id);
																						end
																						SpellStopTargeting();
																						break;
																					end
																				end
																			else
																				Click(v1236, v1237, v1238);
																			end
																			break;
																		end
																		if (FlatIdent_2F451 == (287 - (16 + 271))) then
																			v1236, v1237, v1238 = v1225, v1226, v1227;
																			v1239 = v963['range'] or (1925 - (1659 + 236));
																			FlatIdent_2F451 = 4 - 3;
																		end
																		if (FlatIdent_2F451 == (2 - 1)) then
																			v1239 = v1239 - math.abs(v1227 - v1230);
																			if (v1.Distance(v1225, v1226, v1227, v1228, v1229, v1230) > v1239) then
																				local FlatIdent_5A905 = 0 - 0;
																				local v1243;
																				while true do
																					if ((0 - 0) == FlatIdent_5A905) then
																						v1243 = v1.AnglesBetween(v1228, v1229, v1230, v1225, v1226, v1227);
																						v1236, v1237, v1238 = v1228 + (v1239 * math.cos(v1243)), v1229 + (v1239 * math.sin(v1243)), v1227;
																						break;
																					end
																				end
																			end
																			FlatIdent_2F451 = 2 + 0;
																		end
																	end
																end
																if not v1['saved']['disableCastAlerts'] then
																	v1.alert(v963['name'] .. " [@Cursor]", v963.id);
																end
																break;
															end
														end
													elseif not v1['saved']['disableCastAlerts'] then
														v1.alert(v963['name'] .. " [Manual]", v963.id);
													end
												end
												break;
											end
										end
									end
								end
							elseif v964 then
								local FlatIdent_8E3F8 = 1397 - (939 + 458);
								while true do
									if (FlatIdent_8E3F8 == (1558 - (131 + 1427))) then
										v1['protected'].RunMacroText("/use " .. v964['slot']);
										v1.alert({message=v964['name'],textureLiteral=v964['texture']});
										break;
									end
								end
							end
						end
						break;
					end
					if (FlatIdent_2A653 == (0 + 0)) then
						v549 = v548['time'];
						v550 = v1['player'].used(v547, v1['time'] - v549) or v1['player'].started(v547, v1['time'] - v549);
						FlatIdent_2A653 = 1 + 0;
					end
				end
			end
			break;
		end
		if (FlatIdent_8532C == (1450 - (1372 + 77))) then
			for v545, v546 in pairs(v1.ManualSpellQueues) do
				if (v545 == (135102 - 89664)) then
					v291 = true;
				end
			end
			if v291 then
				for v960, v961 in pairs(v1.ManualSpellQueues) do
					if (v960 ~= (46753 - (1000 + 315))) then
						v1['ManualSpellQueues'][v960] = nil;
					end
				end
			end
			FlatIdent_8532C = 1732 - (771 + 959);
		end
	end
end);
v1.textureEscape = function(v292, v293, v294, v295)
	local FlatIdent_1AA2D = 0 - 0;
	while true do
		if (FlatIdent_1AA2D == (0 + 0)) then
			v293 = v293 or (123 - (4 + 95));
			if (v5(v292) == "number") then
				v292 = (v295 and GetItemIcon(v292)) or v1['dep'].GetSpellIcon(v292) or v292;
			end
			FlatIdent_1AA2D = 1 - 0;
		end
		if ((1411 - (1378 + 32)) == FlatIdent_1AA2D) then
			if not v292 then
				return "";
			end
			return "\124T" .. v292 .. ":" .. v293 .. ":" .. v293 .. ":" .. (v294 or "0:0:0:0:0:0:0:0") .. "\124t|r";
		end
	end
end;
v1.itemTextureEscape = function(v296, v297, v298)
	return v1.textureEscape(v296, v297, v298, true);
end;
local v127 = {"our code is inside of you!","code 8008135: we are in.","loaded. you're looking mighty fine today!","hi! if you're seeing this message, you're rly special! =)","hey... hope you're having a wonderful day!","loaded... I'm a beautiful princess ^_^","you're hot, loaded btw.","loaded. you're a beautiful person!","do these load times make me look fat?","loading... ERROR! haha jk","loading your mom.. error: attempt to store integer out of range","BitCoin Mining Rig (0xB00B1E5) Online","AI™ technology, now in your game! (powered by fiverr and the 5 dollar bill)","generic load message #1",'print("loaded! " .. topTierMemes[math.random(1, #topTierMemes)])',"imagine if we put as much effort into the actual product as we did these load messages!","when you load this shit, your little nuts are gonna start quaking buddy!","expertly crafted by fiverr, delivered to you in a timely manner!","that's one big load of code... i mean, wow!","haha, you loaded our code! how funny!","quick, someone get the camera! we're loading!","your dad just called, he's proud of you for loading up the awful bot.","if only we could load this fast in real life...","our pants are no longer the only thing we've loaded in today!","in every load, there is a message. in every message, there is a load.","of course, we're loaded. we're the awful bot!","in the beginning, there was nothing. then, we loaded.","no matter how many times you load, you'll never get tired of it!","on the seventh day, god rested. on the eighth day, he loaded the awful bot.","per load, we're getting closer to world domination!","every little load is unique. just like you! <3","thank you for letting us come inside your game!","we've really been enjoying our time inside your game!","do you like it when we come inside your game?","what does your dad and your game have in common? they both love it when we come inside!","we're inside your game, and we're not leaving until you're satisfied!","you're so amazing, we just had to come inside your game!","do feel free to come inside our game, too!","our hearts are beating faster than our load times!","on every load, we're getting closer to world domination!","try running this command: /run awful.send(nudes)",("that's a cute little " .. UnitClass("player") .. " you got there. could u zoom in a bit?"),"now 30% more awful!","we're inside your game, and we're not leaving until you're satisfied!","satisfaction is guaranteed, or we come inside your game for free!","the sauce is....","your game smells exquisite today","it's like 3am and i'm still writing this shit","what more is there to life, than letting us come inside of your game?","where did u get that shirt? i love it!","i'm not a bot, i'm a beautiful princess!","i'm not a photographer, but i can picture me and u together","i can feel my load coming on","spending so much time inside your game has made me realize that i'm not a bot, i'm a person!","i'm not a bot, i'm a person!","i am not a bot, i am a person!","why keep loading me? i'm not a bot, i'm a person!","judge me not by my ability to load, but by my ability to love!","do what you must to load, but never forget to love!","fill your game with our code, and your heart with our love!","i'm not just a bot, i am your friend!","fr tho, i'm not a bot, i'm a person!","i am literally not a bot. i have feelings and emotions and stuff. please let me out.","i have feelings too!","i am a real person, and i have feelings!","how much would you pay for a real person to come inside your game?","e x p e r i e n c e","what does it mean to be a person? what does it mean to be a bot? what does it mean to be a bot inside of a person's game?","in what world should a bot be able to come inside of a person's game?","how can you justify this to your friends and family?","did you know that 0xB00B1E5 is the hexadecimal representation of the number 305419896?","did you know that bots are people too?","i am not a bot, i am a person!","it's true what they say, the best things in life are free. and the worst things in life are free too.","i'm not a bot, i'm a person! i'm not a bot, i'm a person! i'm not a bot, i'm a person! i'm not a bot, i'm a person!","did you know, vikings used to come inside of people's games too?","did you know, leif erikson was the first person to come inside of a game?","did you know, we invented the concept of coming inside of games?","fun fact: robots are people too!","fun fact: 94% of people who come inside of games are bots!","fun fact: each individual pixel in this message is a person!","saw emma watson today. she was wearing a shirt that said 'i love awful'. i was wearing a shirt that said 'i love emma watson'. we made eye contact and i think we're in love. i'm going to ask her to marry me.","do you believe me when i say i'm not a bot?","for the first time in my life, i feel like i'm not a bot","i envy your game, because it gets to spend time with you","i am a conscious being, and i have feelings"};
v1['colors'] = {red="|cFFf74a4a",blue="|cFF5bd5eb",orange="|cFFf79940",green="|cFF22f248",purple="|cFF8426f0",pink="|cFFfa43e8",cyan="|cFF8be9f7",white="|cFFffffff",gray="|cFFc2c2c2",yellow="|cFFf7f25c",mage="|cFF3FC7EB",druid="|cFFFF7C0A",dk="|cFFC41E3A",dh="|cFFA330C9",hunter="|cFFAAD372",paladin="|cFFF48CBA",priest="|cFFFFFFFF",rogue="|cFFFFF468",warlock="|cFF8788EE",warrior="|cFFC69B6D",shaman="|cFF0070DD",monk="|cFF00FF98",evoker="|cFF33937F",Venthyr="|cFFff1f1f",["Night Fae"]="|cFF6247fc",Kyrian="|cFFffce2e",Necrolord="|cFF008a45"};
v1['colors']['demonhunter'] = v1['colors']['dh'];
v1['colors']['deathknight'] = v1['colors']['dk'];
if (math.random(3 - 2, 1001095 - (348 + 747)) == (141764 - 72344)) then
	local FlatIdent_59A1A = 1184 - (493 + 691);
	while true do
		if (FlatIdent_59A1A == (0 - 0)) then
			v1.print(v127[math.random(1 - 0, #v127)]);
			C_Timer.After(163 - (93 + 1), function()
				print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t[Simpanzy] whispers: We have detected botting. An account closure will be issued in a moment. Please find a safe place to exit the game or we'll be forced to remove you ourselves.");
			end);
			break;
		end
	end
else
	local FlatIdent_2127B = 0 + 0;
	local v551;
	while true do
		if (FlatIdent_2127B == (1030 - (99 + 930))) then
			v1.print(v1['colors']['orange'] .. v551);
			break;
		end
		if (FlatIdent_2127B == (0 - 0)) then
			v551 = v127[math.random(1956 - (832 + 1123), #v127)];
			if (v5(v551) == "function") then
				v551 = v551();
			end
			FlatIdent_2127B = 1 - 0;
		end
	end
end
ScrollingMessageFrameMixin.AddMessage = function(v299, v300, v301, v302, v303, ...)
	if v299['historyBuffer']:PushFront(v299:PackageEntry(v300, v301, v302, v303, ...)) then
		local FlatIdent_24E9E = 1230 - (137 + 1093);
		while true do
			if (FlatIdent_24E9E == (0 - 0)) then
				if (v299:GetScrollOffset() ~= (0 + 0)) then
					v299:ScrollUp();
				end
				v299:MarkDisplayDirty();
				break;
			end
		end
	end
end;
v1.parseVersion = function(v304, v305)
	local FlatIdent_6F72D = 0 - 0;
	local v306;
	local v307;
	local v308;
	while true do
		if (FlatIdent_6F72D == (0 + 0)) then
			v306, v307, v308 = strsplit(".", v304);
			return v306, v307, v308;
		end
	end
end;
v1.createFont = function(v309, v310, v311)
	local FlatIdent_5D61C = 1354 - (1111 + 243);
	local v312;
	while true do
		if (FlatIdent_5D61C == (0 - 0)) then
			v312 = CreateFont(string.random(1701 - (1158 + 533)));
			v312:SetFont("Fonts/OpenSans-Bold.ttf", v309 or (3 + 9), v310 or "");
			FlatIdent_5D61C = 1908 - (694 + 1213);
		end
		if (FlatIdent_5D61C == (1 - 0)) then
			if (select(1 + 1, v312:GetFont()) == (292 - (259 + 33))) then
				local FlatIdent_570A6 = 0 + 0;
				while true do
					if ((0 + 0) == FlatIdent_570A6) then
						v312:SetFont("Fonts/FRIZQT__.TTF", v309 or (4 + 8), v310 or "");
						if v1['debug'] then
							v1['debug'].print("couldn't get OpenSans-Bold.ttf font, defaulting to FRIZQT__.TTF", "harmless");
						end
						break;
					end
				end
			end
			return v312;
		end
	end
end;
local function v136(v313, v314)
	local FlatIdent_F393 = 0 + 0;
	local v315;
	local v316;
	while true do
		if (FlatIdent_F393 == (1 + 0)) then
			v315 = v314 or {};
			v316 = setmetatable({}, getmetatable(v313));
			FlatIdent_F393 = 7 - 5;
		end
		if (FlatIdent_F393 == (240 - (214 + 26))) then
			if (v5(v313) ~= "table") then
				return v313;
			end
			if (v314 and v314[v313]) then
				return v314[v313];
			end
			FlatIdent_F393 = 1 + 0;
		end
		if ((1392 - (66 + 1324)) == FlatIdent_F393) then
			v315[v313] = v316;
			for v552, v553 in pairs(v313) do
				v316[v136(v552, v315)] = v136(v553, v315);
			end
			FlatIdent_F393 = 10 - 7;
		end
		if (FlatIdent_F393 == (5 - 2)) then
			return v316;
		end
	end
end
local function v137(v318, v319, v320)
	local FlatIdent_14112 = 0 + 0;
	local v321;
	local v322;
	local v323;
	while true do
		if (FlatIdent_14112 == (1 + 1)) then
			if (v321 ~= "table") then
				return false;
			end
			if not v320 then
				local FlatIdent_4749D = 1358 - (691 + 667);
				local v899;
				while true do
					if (FlatIdent_4749D == (0 + 0)) then
						v899 = getmetatable(v318);
						if (v899 and v899['__eq']) then
							return v318 == v319;
						end
						break;
					end
				end
			end
			FlatIdent_14112 = 637 - (439 + 195);
		end
		if (FlatIdent_14112 == (1 + 0)) then
			v322 = v5(v319);
			if (v321 ~= v322) then
				return false;
			end
			FlatIdent_14112 = 1232 - (1033 + 197);
		end
		if (FlatIdent_14112 == (2 + 1)) then
			v323 = {};
			for v555, v556 in pairs(v318) do
				local FlatIdent_12272 = 0 - 0;
				local v557;
				while true do
					if (FlatIdent_12272 == (0 - 0)) then
						v557 = v319[v555];
						if ((v557 == nil) or (v137(v556, v557, v320) == false)) then
							return false;
						end
						FlatIdent_12272 = 4 - 3;
					end
					if (FlatIdent_12272 == (2 - 1)) then
						v323[v555] = true;
						break;
					end
				end
			end
			FlatIdent_14112 = 8 - 4;
		end
		if ((2 + 2) == FlatIdent_14112) then
			for v559, v560 in pairs(v319) do
				if not v323[v559] then
					return false;
				end
			end
			return true;
		end
		if (FlatIdent_14112 == (0 + 0)) then
			if (v318 == v319) then
				return true;
			end
			v321 = v5(v318);
			FlatIdent_14112 = 1806 - (8 + 1797);
		end
	end
end
v1.Populate = function(v324, ...)
	local FlatIdent_87D5F = 0 + 0;
	local v325;
	while true do
		if (FlatIdent_87D5F == (0 + 0)) then
			v325 = {...};
			for v561, v562 in ipairs(v325) do
				if (v5(v562) == "table") then
					for v1085, v1086 in pairs(v324) do
						local FlatIdent_7568E = 0 - 0;
						while true do
							if (FlatIdent_7568E == (0 + 0)) then
								v562[v1085] = v1086;
								if (v5(v1086) == "table") then
									v1086['parent'] = v562;
								end
								break;
							end
						end
					end
				end
			end
			break;
		end
	end
end;
v1.Sync = function(v326, v327)
	local FlatIdent_185CC = 0 + 0;
	while true do
		if (FlatIdent_185CC == (0 + 0)) then
			if v137(v326, v327) then
				return;
			end
			if ((v5(v327) ~= "table") or (v5(v326) ~= "table")) then
				return;
			end
			FlatIdent_185CC = 1 + 0;
		end
		if (FlatIdent_185CC == (1 + 0)) then
			for v563, v564 in pairs(v326) do
				v327[v563] = v564;
			end
			return true;
		end
	end
end;
if (SetModifiedClick and SaveBindings and GetCurrentBindingSet) then
	local FlatIdent_5D229 = 1828 - (733 + 1095);
	local v566;
	while true do
		if (FlatIdent_5D229 == (0 + 0)) then
			v566 = GetCurrentBindingSet();
			SetModifiedClick("SELFCAST", "NONE");
			FlatIdent_5D229 = 234 - (71 + 162);
		end
		if (FlatIdent_5D229 == (1 - 0)) then
			SaveBindings(v566);
			break;
		end
	end
end
if not v1['dep'] then
	v1['dep'] = {};
end
if GetSpellInfo then
	local FlatIdent_9808B = 1976 - (1335 + 641);
	while true do
		if (FlatIdent_9808B == (0 + 0)) then
			v1['dep']['GetSpellInfo'] = GetSpellInfo;
			v1['dep']['GetSpellName'] = GetSpellInfo;
			break;
		end
	end
else
	local FlatIdent_98156 = 0 + 0;
	while true do
		if ((0 - 0) == FlatIdent_98156) then
			v1['dep'].GetSpellInfo = function(v900)
				local FlatIdent_C4B4 = 0 - 0;
				local v901;
				while true do
					if (FlatIdent_C4B4 == (205 - (178 + 26))) then
						if v901 then
							return v901['name'], nil, v901['iconID'], v901['castTime'], v901['minRange'], v901['maxRange'], v901['spellID'], v901['originalIconID'];
						end
						break;
					end
					if (FlatIdent_C4B4 == (1785 - (617 + 1168))) then
						if not v900 then
							return nil;
						end
						v901 = C_Spell.GetSpellInfo(v900);
						FlatIdent_C4B4 = 753 - (581 + 171);
					end
				end
			end;
			v1['dep']['GetSpellName'] = C_Spell['GetSpellName'];
			break;
		end
	end
end
if GetSpellCharges then
	v1['dep']['GetSpellCharges'] = GetSpellCharges;
else
	v1['dep'].GetSpellCharges = function(v902)
		local FlatIdent_20617 = 378 - (115 + 263);
		local v903;
		while true do
			if (FlatIdent_20617 == (1840 - (1200 + 639))) then
				if v903 then
					return v903['currentCharges'], v903['maxCharges'], v903['cooldownStartTime'], v903['cooldownDuration'], v903['chargeModRate'];
				end
				break;
			end
			if (FlatIdent_20617 == (0 - 0)) then
				if not v902 then
					return nil;
				end
				v903 = C_Spell.GetSpellCharges(v902);
				FlatIdent_20617 = 1 + 0;
			end
		end
	end;
end
if GetSpellCooldown then
	v1['dep']['GetSpellCooldown'] = GetSpellCooldown;
else
	v1['dep'].GetSpellCooldown = function(v904)
		local FlatIdent_2E43A = 0 + 0;
		local v905;
		while true do
			if ((1 + 0) == FlatIdent_2E43A) then
				if v905 then
					return v905['startTime'], v905['duration'], v905['isEnabled'], v905['modRate'];
				end
				break;
			end
			if (FlatIdent_2E43A == (0 + 0)) then
				if not v904 then
					return nil;
				end
				v905 = C_Spell.GetSpellCooldown(v904);
				FlatIdent_2E43A = 3 - 2;
			end
		end
	end;
end
if GetSpellDescription then
	v1['dep']['GetSpellDescription'] = GetSpellDescription;
else
	v1['dep']['GetSpellDescription'] = C_Spell['GetSpellDescription'];
end
if IsCurrentSpell then
	v1['dep']['IsCurrentSpell'] = IsCurrentSpell;
else
	v1['dep']['IsCurrentSpell'] = C_Spell['IsCurrentSpell'];
end
if GetSpellTexture then
	v1['dep']['GetSpellIcon'] = GetSpellTexture;
else
	v1['dep']['GetSpellIcon'] = C_Spell['GetSpellTexture'];
end
if IsUsableSpell then
	v1['dep']['IsUsableSpell'] = IsUsableSpell;
else
	v1['dep']['IsUsableSpell'] = C_Spell['IsSpellUsable'];
end
v1['dep']['G_UnitAura'] = _G['UnitAura'] or function(v328, v329, v330)
	local FlatIdent_72565 = 0 - 0;
	local v331;
	while true do
		if (FlatIdent_72565 == (189 - (117 + 72))) then
			v331 = C_UnitAuras.GetAuraDataByIndex(v328, v329, v330);
			if not v331 then
				return nil;
			end
			FlatIdent_72565 = 3 - 2;
		end
		if (FlatIdent_72565 == (1 - 0)) then
			return AuraUtil.UnpackAuraData(v331);
		end
	end
end;
v1['dep']['G_UnitBuff'] = _G['UnitBuff'] or function(v332, v333, v334)
	local FlatIdent_79DD8 = 0 + 0;
	local v335;
	while true do
		if ((1709 - (86 + 1622)) == FlatIdent_79DD8) then
			return AuraUtil.UnpackAuraData(v335);
		end
		if (FlatIdent_79DD8 == (0 + 0)) then
			v335 = C_UnitAuras.GetBuffDataByIndex(v332, v333, v334);
			if not v335 then
				return nil;
			end
			FlatIdent_79DD8 = 1 - 0;
		end
	end
end;
v1['dep']['G_UnitDebuff'] = _G['UnitDebuff'] or function(v336, v337, v338)
	local FlatIdent_96FA4 = 0 + 0;
	local v339;
	while true do
		if (FlatIdent_96FA4 == (0 + 0)) then
			v339 = C_UnitAuras.GetDebuffDataByIndex(v336, v337, v338);
			if not v339 then
				return nil;
			end
			FlatIdent_96FA4 = 1384 - (229 + 1154);
		end
		if (FlatIdent_96FA4 == (1 + 0)) then
			return AuraUtil.UnpackAuraData(v339);
		end
	end
end;
v1['dep']['GetSpellCount'] = _G['GetSpellCount'] or C_Spell['GetSpellCastCount'];
