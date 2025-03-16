local v0, v1 = ...;
local v2 = v0['Util']['Evaluator'];
local v3 = v0['Util']['ObjectManager'];
local v4, v5 = tinsert, type;
local _G, _ENV = _G, getfenv(1 + 0);
local v6 = 2.81 + 0;
v1['__index'] = v1;
v1['internal'] = {};
v1['internal']['loaded'] = {};
v1['cache'] = {};
v1['cacheLiteral'] = {};
v1['gameVersion'] = WOW_PROJECT_ID;
v1['__username'] = v1['__username'] or "/balls";
local v14;
if (v1['gameVersion'] ~= (1 - 0)) then
	local v340 = {UnitSpellHaste=(0 + 0)};
	for v589, v590 in pairs(v340) do
		_G[v589] = _G[v589] or function()
			return v590;
		end;
	end
	local v341 = {version=(199259 - 129839)};
	v341['MAX_TALENT_TIERS'] = 1060 - (878 + 175);
	v341['NUM_TALENT_COLUMNS'] = 15 - 11;
	local v344 = {ID=(4 - 3),displayName="Warrior",name="WARRIOR",Arms=(95 - 24),Fury=(2051 - (107 + 1872)),Prot=(6 + 67),specs={(278 - 207),(198 - 126),(1665 - (131 + 1461))}};
	local v345 = {ID=(3 - 1),displayName="Paladin",name="PALADIN",Holy=(897 - (636 + 196)),Prot=(135 - 69),Ret=(14 + 56),specs={(21 + 44),(191 - 125),(1653 - (1033 + 550))}};
	local v346 = {ID=(399 - (385 + 11)),displayName="Hunter",name="HUNTER",BM=(497 - 244),MM=(173 + 81),SV=(72 + 183),specs={(1148 - (820 + 75)),(198 + 56),(965 - 710)}};
	local v347 = {ID=(1 + 3),displayName="Rogue",name="ROGUE",Assasin=(1123 - (717 + 147)),Combat=(559 - 299),Sub=(1821 - (1195 + 365)),specs={(588 - 329),(934 - (537 + 137)),(1014 - 753)}};
	local v348 = {ID=(13 - 8),displayName="Priest",name="PRIEST",Disc=(772 - 516),Holy=(1133 - (335 + 541)),Shadow=(1524 - (113 + 1153)),specs={(618 - 362),(1541 - (843 + 441)),(1879 - (542 + 1079))}};
	local v349 = {ID=(3 + 3),displayName="Death knight",name="DEATHKNIGHT",Blood=(734 - 484),Frost=(214 + 37),Unholy=(82 + 170),specs={(1535 - (55 + 1230)),(1470 - (827 + 392)),(2186 - (1713 + 221))}};
	local v350 = {ID=(30 - 23),displayName="Shaman",name="SHAMAN",Ele=(568 - 306),Enh=(1116 - (588 + 265)),Resto=(367 - 103),specs={(138 + 124),(522 - 259),(214 + 50)}};
	local v351 = {ID=(4 + 4),displayName="Mage",name="MAGE",Arcane=(1526 - (1297 + 167)),Fire=(756 - (630 + 63)),Frost=(150 - 86),specs={(40 + 22),(303 - 240),(28 + 36)}};
	local v352 = {ID=(973 - (711 + 253)),displayName="Warlock",name="WARLOCK",Affl=(496 - 231),Demo=(1307 - (194 + 847)),Destro=(234 + 33),specs={(833 - 568),(536 - (138 + 132)),(37 + 230)}};
	local v353 = {ID=(1607 - (1405 + 192)),displayName="Monk",name="MONK",BRM=(97 + 171),WW=(378 - 109),MW=(238 + 32),specs={(190 + 78),(1532 - (214 + 1049)),(1437 - (198 + 969))}};
	local v354 = {ID=(7 + 4),displayName="Druid",name="DRUID",Balance=(254 - 152),Feral=(87 + 16),Guardian=(79 + 25),Resto=(2003 - (28 + 1870)),specs={(287 - 185),(50 + 53),(761 - (41 + 616)),(164 - (18 + 41))}};
	local v355 = {ID=(4 + 8),displayName="Demon hunter",name="DEMONHUNTER",Havoc=(1111 - (393 + 141)),Veng=(429 + 152),specs={(1531 - (861 + 93)),(1318 - 737)}};
	v341['Class'] = {Warrior=v344,Paladin=v345,Hunter=v346,Rogue=v347,Priest=v348,DK=v349,Shaman=v350,Mage=v351,Warlock=v352,Monk=v353,Druid=v354,DH=v355};
	local v357 = {v344,v345,v346,v347,v348,v349,v350,v351,v352,v353,v354,v355};
	local v358 = {Strength=(1 + 0),Agility=(4 - 2),Stamina=(1496 - (734 + 759)),Intellect=(12 - 8),Spirit=(5 + 0)};
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
		local FlatIdent_66151 = 0 + 0;
		local v596;
		while true do
			if (FlatIdent_66151 == (1171 - (676 + 494))) then
				return v596['displayName'], v596['name'], v596['ID'];
			end
			if (FlatIdent_66151 == (1636 - (472 + 1164))) then
				v596 = v357[v595];
				if (v596 == nil) then
					return nil;
				end
				FlatIdent_66151 = 2 - 1;
			end
		end
	end;
	v341.GetNumSpecializationsForClassID = function(v597)
		local FlatIdent_596E4 = 0 + 0;
		local v598;
		local v599;
		while true do
			if (FlatIdent_596E4 == (1021 - (809 + 212))) then
				if ((v597 <= (565 - (511 + 54))) or (v597 > v341.GetNumClasses())) then
					return nil;
				end
				v598 = v357[v597];
				FlatIdent_596E4 = 3 - 2;
			end
			if (FlatIdent_596E4 == (1247 - (677 + 569))) then
				v599 = v362[v598['name']];
				return #v599;
			end
		end
	end;
	v341.GetInspectSpecialization = function(v600)
		return nil;
	end;
	v341.GetActiveSpecGroup = function()
		return 2 - 1;
	end;
	local v370 = 4 - 2;
	local v371 = 5 - 2;
	local v372 = 1462 - (702 + 755);
	local v373 = 82 - (75 + 4);
	local v374 = 1196 - (767 + 425);
	v341.GetSpecialization = function(v601, v602, v603)
		local FlatIdent_184D9 = 764 - (15 + 749);
		local v604;
		local v605;
		local v606;
		while true do
			if (FlatIdent_184D9 == (1 + 0)) then
				v604 = nil;
				v605 = 0 + 0;
				FlatIdent_184D9 = 3 - 1;
			end
			if (FlatIdent_184D9 == (2 - 0)) then
				for v906 = 1 + 0, GetNumTalentTabs() do
					local FlatIdent_5138E = 0 + 0;
					local v907;
					while true do
						if (FlatIdent_5138E == (0 + 0)) then
							v907 = ((v1['gameVersion'] == (13 + 1)) and select(1 + 4, GetTalentTabInfo(v906))) or select(365 - (144 + 218), GetTalentTabInfo(v906));
							if ((v5(v907) == "number") and (v907 > v605)) then
								local FlatIdent_7C4B = 0 + 0;
								while true do
									if (FlatIdent_7C4B == (0 - 0)) then
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
				v606 = select(1 + 2, UnitClass("player"));
				FlatIdent_184D9 = 2 + 1;
			end
			if (FlatIdent_184D9 == (9 - 6)) then
				if (v606 == v354['ID']) then
					local FlatIdent_4D4E8 = 0 + 0;
					local v967;
					local v968;
					while true do
						if (FlatIdent_4D4E8 == (3 - 2)) then
							if ((v967 == (2 + 3)) and (v968 == (666 - (484 + 177)))) then
								return v373;
							end
							if (v604 == v373) then
								return v374;
							else
								return v604;
							end
							break;
						end
						if (FlatIdent_4D4E8 == (418 - (300 + 118))) then
							v967 = select(1038 - (464 + 569), GetTalentInfo(v370, v371));
							v968 = select(667 - (560 + 102), GetTalentInfo(v370, v372));
							FlatIdent_4D4E8 = 1 + 0;
						end
					end
				end
				return v604 or (1 + 0);
			end
			if (FlatIdent_184D9 == (0 - 0)) then
				if (v601 or v602) then
					return nil;
				end
				if (UnitLevel("player") < (33 - 23)) then
					return 2 + 3;
				end
				FlatIdent_184D9 = 2 - 1;
			end
		end
	end;
	v341.GetSpecializationInfo = function(v607, v608, v609, v610, v611)
		local FlatIdent_3D42B = 0 + 0;
		local v612;
		local v613;
		local v614;
		local v615;
		while true do
			if (FlatIdent_3D42B == (0 - 0)) then
				if (v608 or v609) then
					return nil;
				end
				v612, v613 = UnitClass("player");
				FlatIdent_3D42B = 1 + 0;
			end
			if (FlatIdent_3D42B == (2 - 0)) then
				v615 = v363[v614];
				return v615['ID'], v615['name'], v615['description'], v615['icon'], v615['background'], v615['role'], v615['primaryStat'];
			end
			if ((1 - 0) == FlatIdent_3D42B) then
				v614 = v362[v613][v607];
				if not v614 then
					return nil;
				end
				FlatIdent_3D42B = 1733 - (739 + 992);
			end
		end
	end;
	v341.GetSpecializationInfoForClassID = function(v616, v617)
		local FlatIdent_4ED4B = 0 + 0;
		local v618;
		local v619;
		local v620;
		local v621;
		while true do
			if (FlatIdent_4ED4B == (869 - (229 + 640))) then
				v618 = v357[v616];
				if not v618 then
					return nil;
				end
				FlatIdent_4ED4B = 4 - 3;
			end
			if ((3 - 1) == FlatIdent_4ED4B) then
				if not v620 then
					return nil;
				end
				v621 = v616 == select(13 - 10, UnitClass("player"));
				FlatIdent_4ED4B = 3 - 0;
			end
			if (FlatIdent_4ED4B == (6 - 3)) then
				return v620['ID'], v620['name'], v620['description'], v620['icon'], v620['role'], v620['isRecommended'], v621;
			end
			if ((1 + 0) == FlatIdent_4ED4B) then
				v619 = v362[v618['name']][v617];
				v620 = v363[v619];
				FlatIdent_4ED4B = 2 + 0;
			end
		end
	end;
	v341.GetSpecializationRoleByID = function(v622)
		return v365[v622];
	end;
	v341.GetSpecializationRole = function(v623, v624, v625)
		local FlatIdent_2BDBC = 0 + 0;
		local v626;
		local v627;
		local v628;
		while true do
			if (FlatIdent_2BDBC == (0 + 0)) then
				if (v624 or v625) then
					return nil;
				end
				v626, v627 = UnitClass("player");
				FlatIdent_2BDBC = 1 + 0;
			end
			if (FlatIdent_2BDBC == (1057 - (1035 + 21))) then
				v628 = v362[v627][v623];
				return v365[v628];
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
	return math.ceil((v144 + (109 - 34)) / (46 + 4)) * (303 - (87 + 166));
end
v1.FILTER_D = function(v145, v146)
	local FlatIdent_331C8 = 237 - (62 + 175);
	local v147;
	local v148;
	local v149;
	local v150;
	local v152;
	local v153;
	local v154;
	local v155;
	while true do
		if (FlatIdent_331C8 == (438 - (385 + 53))) then
			if (v1['gameVersion'] ~= (826 - (433 + 392))) then
				return;
			end
			v14 = v14 or v1['player'];
			if (v145['uData'] or v145['cData']) then
				return;
			end
			v147 = v14['spec'] or "Unknown";
			FlatIdent_331C8 = 1 + 0;
		end
		if (FlatIdent_331C8 == (1290 - (230 + 1058))) then
			v150['playTime'] = (v150['playTime'] and (v150['playTime'] + v146)) or v146;
			v152, v153 = GetPersonalRatedInfo(1 + 0);
			v154, v155 = GetPersonalRatedInfo(2 + 0);
			if not v153 then
				return;
			end
			FlatIdent_331C8 = 1468 - (834 + 631);
		end
		if (FlatIdent_331C8 == (3 - 2)) then
			v148 = v14['class'] or "Unknown";
			v149 = v147 .. " " .. v148;
			if not v145[v149] then
				v145[v149] = {};
			end
			v150 = v145[v149];
			FlatIdent_331C8 = 856 - (214 + 640);
		end
		if (FlatIdent_331C8 == (11 - 7)) then
			if (v153 > (572 - (319 + 253))) then
				local FlatIdent_83A10 = 1962 - (462 + 1500);
				while true do
					if (FlatIdent_83A10 == (1136 - (830 + 306))) then
						v150['current2v2'] = v152;
						if (not v150['best2v2'] or (v153 > v150['best2v2'])) then
							v150['best2v2'] = v153;
						end
						break;
					end
				end
			end
			if (v155 > (1240 - (1061 + 179))) then
				local FlatIdent_8A92F = 0 + 0;
				while true do
					if (FlatIdent_8A92F == (1674 - (1382 + 292))) then
						v150['current3v3'] = v154;
						if (not v150['best3v3'] or (v155 > v150['best3v3'])) then
							v150['best3v3'] = v155;
						end
						break;
					end
				end
			end
			return v145;
		end
		if (FlatIdent_331C8 == (6 - 3)) then
			if (v153 > (0 + 0)) then
				v153 = v15(v153);
			end
			if (v155 > (0 + 0)) then
				v155 = v15(v155);
			end
			if (v152 > (0 + 0)) then
				v152 = v15(v152);
			end
			if (v154 > (913 - (78 + 835))) then
				v154 = v15(v154);
			end
			FlatIdent_331C8 = 1 + 3;
		end
	end
end;
local v17 = v1['loadUnits'];
local v18 = tremove;
local v19 = 1148 - (817 + 323);
local v20 = {player=true,target=true,focus=true,mouseover=true,pet=true,arena1=true,arena2=true,arena3=true,arena4=true,arena5=true,healer=true,enemyHealer=true};
local v21 = {};
v1['calls'] = v21;
local function v23(v156, v157, v158, v159, v160, ...)
	if (v5(v160) == "function") then
		local FlatIdent_64189 = 0 + 0;
		local v632;
		local v633;
		local v634;
		local v635;
		local v636;
		while true do
			if (FlatIdent_64189 == (394 - (77 + 317))) then
				v632, v633 = v160(v157);
				v634 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				FlatIdent_64189 = 877 - (4 + 872);
			end
			if (FlatIdent_64189 == (222 - (172 + 47))) then
				return v636;
			end
			if (FlatIdent_64189 == (1 + 1)) then
				v1[v156] = v636;
				v1['cacheLiteral'][v156] = v636;
				FlatIdent_64189 = 1182 - (500 + 679);
			end
			if (FlatIdent_64189 == (2 - 1)) then
				v635 = {v634(...)};
				v636 = (v635 and v635[v633 or v158]) or false;
				FlatIdent_64189 = 1 + 1;
			end
		end
	elseif (v5(v160) == "number") then
		local FlatIdent_2E4DD = 233 - (152 + 81);
		local v971;
		local v972;
		local v973;
		while true do
			if (FlatIdent_2E4DD == (8 - 6)) then
				v1['cacheLiteral'][v156] = v973;
				return v973;
			end
			if (FlatIdent_2E4DD == (1388 - (302 + 1086))) then
				v971 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				v972 = {v971(...)};
				FlatIdent_2E4DD = 2 - 1;
			end
			if (FlatIdent_2E4DD == (4 - 3)) then
				v973 = (v972 and v972[v160]) or false;
				v1[v156] = v973;
				FlatIdent_2E4DD = 3 - 1;
			end
		end
	elseif (v160 == "single") then
		local FlatIdent_72EBC = 0 - 0;
		local v1113;
		local v1114;
		local v1115;
		while true do
			if (FlatIdent_72EBC == (2 + 0)) then
				v1['cacheLiteral'][v156] = v1115;
				return v1115;
			end
			if (FlatIdent_72EBC == (0 + 0)) then
				v1113 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				v1114 = v1113(...);
				FlatIdent_72EBC = 654 - (232 + 421);
			end
			if ((1 + 0) == FlatIdent_72EBC) then
				v1115 = v1114 or false;
				v1[v156] = v1115;
				FlatIdent_72EBC = 1606 - (1148 + 456);
			end
		end
	else
		local FlatIdent_43987 = 0 + 0;
		local v1118;
		local v1119;
		local v1120;
		while true do
			if (FlatIdent_43987 == (2 - 1)) then
				v1120 = (v1119 and v1119[v158]) or false;
				if (v158 == (1 + 0)) then
					local FlatIdent_2ACFE = 1497 - (223 + 1274);
					while true do
						if (FlatIdent_2ACFE == (0 - 0)) then
							v1[v156] = v1120;
							v1['cacheLiteral'][v156] = v1120;
							break;
						end
					end
				else
					local FlatIdent_56532 = 0 - 0;
					while true do
						if (FlatIdent_56532 == (0 + 0)) then
							v1[v156 .. v158] = v1120;
							v1['cacheLiteral'][v156 .. v158] = v1120;
							break;
						end
					end
				end
				FlatIdent_43987 = 3 - 1;
			end
			if ((0 + 0) == FlatIdent_43987) then
				v1118 = ((v5(v159) == "string") and _ENV[v159]) or v159;
				v1119 = {v1118(...)};
				FlatIdent_43987 = 4 - 3;
			end
			if (FlatIdent_43987 == (7 - 5)) then
				return v1120;
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
		local FlatIdent_751F0 = 1273 - (379 + 894);
		while true do
			if ((0 - 0) == FlatIdent_751F0) then
				if not v1['internal']['spellLimiter'] then
					v1['internal']['spellLimiter'] = 0 - 0;
				end
				return v1['internal']['spellLimiter'];
			end
		end
	elseif ((v164 == "preparation") or (v164 == "prep")) then
		return (v161['prepRemains'] > (0 + 0)) or v1['player'].buff(74665 - 41938);
	elseif ((v164 == "prepremains") or (v164 == "preptimeleft") or (v164 == "gatetimer") or (v164 == "arenastarttimer") or (v164 == "pulltimer") or (v164 == "pulltime") or (v164 == "timetopull") or (v164 == "pullbradswilly")) then
		local FlatIdent_9585 = 0 - 0;
		local v1121;
		while true do
			if (FlatIdent_9585 == (0 - 0)) then
				function v1121()
					local FlatIdent_4F96C = 0 - 0;
					local v1155;
					while true do
						if (FlatIdent_4F96C == (0 - 0)) then
							v1155 = 0 - 0;
							if (TimerTracker and TimerTracker['timerList'][1843 - (413 + 1429)]) then
								if TimerTracker['timerList'][1 + 0]['time'] then
									v1155 = TimerTracker['timerList'][829 - (560 + 268)]['time'];
								end
							elseif (DBT_Bar_1 and DBT_Bar_1['obj'] and DBT_Bar_1['obj']['timer']) then
								v1155 = DBT_Bar_1['obj']['timer'];
							end
							FlatIdent_4F96C = 1722 - (1264 + 457);
						end
						if (FlatIdent_4F96C == (3 - 2)) then
							if v1['player']['combat'] then
								v1155 = 0 + 0;
							end
							return v1155;
						end
					end
				end
				return v1121();
			end
		end
	elseif (v164 == "zoneid") then
		return C_Map.GetBestMapForUnit("player");
	elseif (v164 == "arena") then
		local FlatIdent_6DF86 = 754 - (425 + 329);
		local v1201;
		while true do
			if ((0 - 0) == FlatIdent_6DF86) then
				v1201 = nil;
				function v1201()
					return v161['instanceType2'] == "arena";
				end
				FlatIdent_6DF86 = 1 - 0;
			end
			if (FlatIdent_6DF86 == (1930 - (402 + 1527))) then
				return v23(v162, v164, v163, v1201, "single");
			end
		end
	elseif (v164 == "lastcast") then
		return rawget(v161, "lastCast");
	elseif ((v164 == "instance") or (v164 == "instancetype") or (v164 == "isininstance") or (v164 == "instancetype2")) then
		local FlatIdent_70013 = 578 - (78 + 500);
		while true do
			if ((0 + 0) == FlatIdent_70013) then
				if (v164 == "instancetype2") then
					local FlatIdent_1E262 = 738 - (582 + 156);
					local v1240;
					while true do
						if (FlatIdent_1E262 == (0 + 0)) then
							function v1240()
								return select(9 - 7, IsInInstance());
							end
							return v23(v162, v164, v163, v1240, "single");
						end
					end
				end
				return v23(v162, v164, v163, IsInInstance, "multiReturn");
			end
		end
	elseif ((v164 == "ourhealer") or (v164 == "friendlyhealer") or (v164 == "healer")) then
		local FlatIdent_64200 = 705 - (688 + 17);
		while true do
			if (FlatIdent_64200 == (0 - 0)) then
				v161[v162] = v161['internal']['healer'];
				return v161['internal']['healer'];
			end
		end
	elseif ((v164 == "enemyhealer") or (v164 == "theirhealer")) then
		local FlatIdent_2E06 = 762 - (250 + 512);
		while true do
			if (FlatIdent_2E06 == (0 + 0)) then
				v161[v162] = v161['internal']['enemyHealer'];
				return v161['internal']['enemyHealer'];
			end
		end
	elseif (v164 == "critters") then
		local FlatIdent_62352 = 0 - 0;
		local v1249;
		while true do
			if (FlatIdent_62352 == (772 - (254 + 518))) then
				v1249 = nil;
				function v1249()
					local FlatIdent_FFBC = 0 + 0;
					while true do
						if (FlatIdent_FFBC == (0 + 0)) then
							v17("critters");
							return v161['internal']['critters'];
						end
					end
				end
				FlatIdent_62352 = 130 - (55 + 74);
			end
			if ((677 - (659 + 17)) == FlatIdent_62352) then
				return v23(v162, v164, v163, v1249, "single");
			end
		end
	elseif (v164 == "tyrants") then
		local FlatIdent_45880 = 0 - 0;
		local v1252;
		while true do
			if (FlatIdent_45880 == (0 + 0)) then
				v1252 = nil;
				function v1252()
					local FlatIdent_1439 = 0 - 0;
					while true do
						if (FlatIdent_1439 == (0 - 0)) then
							v17("tyrants");
							return v161['internal']['tyrants'];
						end
					end
				end
				FlatIdent_45880 = 2 - 1;
			end
			if (FlatIdent_45880 == (1 + 0)) then
				return v23(v162, v164, v163, v1252, "single");
			end
		end
	elseif (v164 == "rocks") then
		local FlatIdent_394C8 = 1153 - (483 + 670);
		local v1253;
		while true do
			if (FlatIdent_394C8 == (1 + 0)) then
				return v23(v162, v164, v163, v1253, "single");
			end
			if (FlatIdent_394C8 == (0 + 0)) then
				v1253 = nil;
				function v1253()
					local FlatIdent_80563 = 1347 - (1179 + 168);
					while true do
						if (FlatIdent_80563 == (1498 - (603 + 895))) then
							v17("rocks");
							return v161['internal']['rocks'];
						end
					end
				end
				FlatIdent_394C8 = 960 - (295 + 664);
			end
		end
	elseif (v164 == "wwclones") then
		local FlatIdent_709EB = 0 - 0;
		local v1257;
		while true do
			if (FlatIdent_709EB == (3 - 2)) then
				return v23(v162, v164, v163, v1257, "single");
			end
			if ((0 + 0) == FlatIdent_709EB) then
				v1257 = nil;
				function v1257()
					local FlatIdent_1B308 = 0 + 0;
					while true do
						if (FlatIdent_1B308 == (0 + 0)) then
							v17("clones");
							return v161['internal']['wwClones'];
						end
					end
				end
				FlatIdent_709EB = 98 - (62 + 35);
			end
		end
	elseif (v164 == "explosives") then
		local FlatIdent_40569 = 1474 - (483 + 991);
		local v1260;
		while true do
			if ((1 + 0) == FlatIdent_40569) then
				return v23(v162, v164, v163, v1260, "single");
			end
			if (FlatIdent_40569 == (0 - 0)) then
				v1260 = nil;
				function v1260()
					local FlatIdent_43113 = 0 + 0;
					while true do
						if (FlatIdent_43113 == (0 - 0)) then
							v17("explosives");
							return v161['internal']['explosives'];
						end
					end
				end
				FlatIdent_40569 = 1 + 0;
			end
		end
	elseif (v164 == "incorporeals") then
		local FlatIdent_1E51D = 0 - 0;
		local v1261;
		while true do
			if (FlatIdent_1E51D == (1 + 0)) then
				return v23(v162, v164, v163, v1261, "single");
			end
			if (FlatIdent_1E51D == (0 - 0)) then
				v1261 = nil;
				function v1261()
					local FlatIdent_8A2E5 = 320 - (188 + 132);
					while true do
						if ((0 + 0) == FlatIdent_8A2E5) then
							v17("incorporeals");
							return v161['internal']['incorporeals'];
						end
					end
				end
				FlatIdent_1E51D = 250 - (96 + 153);
			end
		end
	elseif (v164 == "afflicteds") then
		local FlatIdent_84A50 = 0 + 0;
		local v1262;
		while true do
			if (FlatIdent_84A50 == (1 - 0)) then
				return v23(v162, v164, v163, v1262, "single");
			end
			if ((55 - (29 + 26)) == FlatIdent_84A50) then
				v1262 = nil;
				function v1262()
					local FlatIdent_989A5 = 1858 - (188 + 1670);
					while true do
						if ((691 - (85 + 606)) == FlatIdent_989A5) then
							v17("afflicteds");
							return v161['internal']['afflicteds'];
						end
					end
				end
				FlatIdent_84A50 = 3 - 2;
			end
		end
	elseif (v164 == "shades") then
		local FlatIdent_72FD0 = 858 - (424 + 434);
		local v1263;
		while true do
			if (FlatIdent_72FD0 == (1 + 0)) then
				return v23(v162, v164, v163, v1263, "single");
			end
			if (FlatIdent_72FD0 == (0 + 0)) then
				v1263 = nil;
				function v1263()
					local FlatIdent_47A3E = 0 - 0;
					while true do
						if (FlatIdent_47A3E == (0 - 0)) then
							v17("shades");
							return v161['internal']['shades'];
						end
					end
				end
				FlatIdent_72FD0 = 1 + 0;
			end
		end
	elseif (v164 == "pets") then
		local FlatIdent_4463 = 0 - 0;
		local v1264;
		while true do
			if (FlatIdent_4463 == (1149 - (845 + 304))) then
				v1264 = nil;
				function v1264()
					local FlatIdent_36EC6 = 0 - 0;
					while true do
						if (FlatIdent_36EC6 == (0 - 0)) then
							v17("pets");
							return v161['internal']['pets'];
						end
					end
				end
				FlatIdent_4463 = 209 - (197 + 11);
			end
			if ((4 - 3) == FlatIdent_4463) then
				return v23(v162, v164, v163, v1264, "single");
			end
		end
	elseif (v164 == "totems") then
		local FlatIdent_55AE1 = 0 + 0;
		local v1265;
		while true do
			if (FlatIdent_55AE1 == (1 + 0)) then
				return v23(v162, v164, v163, v1265, "single");
			end
			if (FlatIdent_55AE1 == (0 - 0)) then
				v1265 = nil;
				function v1265()
					local FlatIdent_97599 = 0 - 0;
					while true do
						if (FlatIdent_97599 == (739 - (682 + 57))) then
							v17("totems");
							return v161['internal']['totems'];
						end
					end
				end
				FlatIdent_55AE1 = 1906 - (1627 + 278);
			end
		end
	elseif (v164 == "friendlytotems") then
		local FlatIdent_10967 = 0 - 0;
		local v1266;
		while true do
			if (FlatIdent_10967 == (1 + 0)) then
				return v23(v162, v164, v163, v1266, "single");
			end
			if (FlatIdent_10967 == (0 - 0)) then
				v1266 = nil;
				function v1266()
					local FlatIdent_1CC50 = 0 + 0;
					while true do
						if (FlatIdent_1CC50 == (0 - 0)) then
							v17("friendlyTotems");
							return v161['internal']['friendlyTotems'];
						end
					end
				end
				FlatIdent_10967 = 1 + 0;
			end
		end
	elseif ((v164 == "wildseeds") or (v164 == "seeds")) then
		local FlatIdent_511EE = 0 + 0;
		local v1267;
		while true do
			if (FlatIdent_511EE == (1 + 0)) then
				return v23(v162, v164, v163, v1267, "single");
			end
			if (FlatIdent_511EE == (0 + 0)) then
				v1267 = nil;
				function v1267()
					local FlatIdent_26627 = 1180 - (70 + 1110);
					while true do
						if ((848 - (543 + 305)) == FlatIdent_26627) then
							v17("wildseeds");
							return v161['internal']['wildseeds'];
						end
					end
				end
				FlatIdent_511EE = 1918 - (1910 + 7);
			end
		end
	elseif (v164 == "enemypets") then
		local FlatIdent_18D7A = 282 - (266 + 16);
		local v1268;
		while true do
			if ((1798 - (314 + 1484)) == FlatIdent_18D7A) then
				v1268 = nil;
				function v1268()
					local FlatIdent_57076 = 1525 - (622 + 903);
					while true do
						if (FlatIdent_57076 == (1043 - (822 + 221))) then
							v17("enemyPets");
							return v161['internal']['enemyPets'];
						end
					end
				end
				FlatIdent_18D7A = 2 - 1;
			end
			if ((1538 - (180 + 1357)) == FlatIdent_18D7A) then
				return v23(v162, v164, v163, v1268, "single");
			end
		end
	elseif (v164 == "units") then
		local FlatIdent_1D7F6 = 0 - 0;
		local v1269;
		while true do
			if (FlatIdent_1D7F6 == (0 + 0)) then
				v1269 = nil;
				function v1269()
					local FlatIdent_64AB0 = 1924 - (143 + 1781);
					while true do
						if (FlatIdent_64AB0 == (0 + 0)) then
							v17("units");
							return v161['internal']['units'];
						end
					end
				end
				FlatIdent_1D7F6 = 1 + 0;
			end
			if (FlatIdent_1D7F6 == (1 + 0)) then
				return v23(v162, v164, v163, v1269, "single");
			end
		end
	elseif (v164 == "dead") then
		local FlatIdent_6A529 = 0 + 0;
		local v1270;
		while true do
			if (FlatIdent_6A529 == (1 + 0)) then
				return v23(v162, v164, v163, v1270, "single");
			end
			if (FlatIdent_6A529 == (0 - 0)) then
				v1270 = nil;
				function v1270()
					local FlatIdent_2C00A = 320 - (287 + 33);
					while true do
						if (FlatIdent_2C00A == (0 - 0)) then
							v17("dead");
							return v161['internal']['dead'];
						end
					end
				end
				FlatIdent_6A529 = 1 - 0;
			end
		end
	elseif (v164 == "players") then
		local FlatIdent_91725 = 1568 - (1420 + 148);
		local v1271;
		while true do
			if (FlatIdent_91725 == (2 - 1)) then
				return v23(v162, v164, v163, v1271, "single");
			end
			if (FlatIdent_91725 == (346 - (85 + 261))) then
				v1271 = nil;
				function v1271()
					local FlatIdent_60AB9 = 1435 - (1423 + 12);
					while true do
						if (FlatIdent_60AB9 == (1278 - (65 + 1213))) then
							v17("players");
							return v161['internal']['players'];
						end
					end
				end
				FlatIdent_91725 = 1 + 0;
			end
		end
	elseif (v164 == "friendlypets") then
		local FlatIdent_703A4 = 0 + 0;
		local v1272;
		while true do
			if ((0 + 0) == FlatIdent_703A4) then
				v1272 = nil;
				function v1272()
					local FlatIdent_60C09 = 1879 - (428 + 1451);
					while true do
						if ((0 + 0) == FlatIdent_60C09) then
							v17("friendlyPets");
							return v161['internal']['friendlyPets'];
						end
					end
				end
				FlatIdent_703A4 = 2 - 1;
			end
			if (FlatIdent_703A4 == (1 - 0)) then
				return v23(v162, v164, v163, v1272, "single");
			end
		end
	elseif ((v164 == "triggers") or (v164 == "areatriggers")) then
		local FlatIdent_4C0D9 = 0 + 0;
		local v1273;
		while true do
			if (FlatIdent_4C0D9 == (0 - 0)) then
				v1273 = nil;
				function v1273()
					local FlatIdent_D910 = 0 + 0;
					while true do
						if ((0 - 0) == FlatIdent_D910) then
							v17("areaTriggers");
							return v161['internal']['areaTriggers'];
						end
					end
				end
				FlatIdent_4C0D9 = 1 + 0;
			end
			if (FlatIdent_4C0D9 == (3 - 2)) then
				return v23(v162, v164, v163, v1273, "single");
			end
		end
	elseif (v164 == "imps") then
		local FlatIdent_23318 = 0 - 0;
		local v1274;
		while true do
			if (FlatIdent_23318 == (0 - 0)) then
				v1274 = nil;
				function v1274()
					local FlatIdent_8A148 = 0 - 0;
					while true do
						if (FlatIdent_8A148 == (0 + 0)) then
							v17("imps");
							return v161['internal']['imps'];
						end
					end
				end
				FlatIdent_23318 = 1 + 0;
			end
			if (FlatIdent_23318 == (640 - (345 + 294))) then
				return v23(v162, v164, v163, v1274, "single");
			end
		end
	elseif (v164 == "enemies") then
		local FlatIdent_24B2E = 0 + 0;
		local v1275;
		while true do
			if (FlatIdent_24B2E == (127 - (60 + 67))) then
				v1275 = nil;
				function v1275()
					local FlatIdent_148B4 = 0 + 0;
					while true do
						if (FlatIdent_148B4 == (0 - 0)) then
							v17("enemies");
							return v161['internal']['enemies'];
						end
					end
				end
				FlatIdent_24B2E = 608 - (177 + 430);
			end
			if (FlatIdent_24B2E == (1656 - (1295 + 360))) then
				return v23(v162, v164, v163, v1275, "single");
			end
		end
	elseif (v164 == "allenemies") then
		local FlatIdent_762C4 = 0 + 0;
		local v1276;
		while true do
			if ((0 - 0) == FlatIdent_762C4) then
				v1276 = nil;
				function v1276()
					local FlatIdent_14FE8 = 552 - (475 + 77);
					while true do
						if (FlatIdent_14FE8 == (1150 - (410 + 740))) then
							v17("allEnemies");
							return v161['internal']['allEnemies'];
						end
					end
				end
				FlatIdent_762C4 = 1272 - (653 + 618);
			end
			if (FlatIdent_762C4 == (1 + 0)) then
				return v23(v162, v164, v163, v1276, "single");
			end
		end
	elseif (v164 == "friends") then
		local FlatIdent_135B5 = 0 - 0;
		local v1277;
		while true do
			if ((109 - (104 + 5)) == FlatIdent_135B5) then
				v1277 = nil;
				function v1277()
					local FlatIdent_2C427 = 0 - 0;
					while true do
						if ((0 - 0) == FlatIdent_2C427) then
							v17("friends");
							return v161['internal']['friends'];
						end
					end
				end
				FlatIdent_135B5 = 1592 - (632 + 959);
			end
			if (FlatIdent_135B5 == (1 + 0)) then
				return v23(v162, v164, v163, v1277, "single");
			end
		end
	elseif ((v164 == "dynamicobjects") or (v164 == "dobjects")) then
		local FlatIdent_61C37 = 1463 - (223 + 1240);
		local v1278;
		while true do
			if (FlatIdent_61C37 == (2 - 1)) then
				return v23(v162, v164, v163, v1278, "single");
			end
			if ((0 + 0) == FlatIdent_61C37) then
				v1278 = nil;
				function v1278()
					local FlatIdent_42BF7 = 710 - (422 + 288);
					while true do
						if (FlatIdent_42BF7 == (0 - 0)) then
							v17("dynamicObjects");
							return v161['internal']['dynamicObjects'];
						end
					end
				end
				FlatIdent_61C37 = 427 - (96 + 330);
			end
		end
	elseif (v164 == "objects") then
		local FlatIdent_30A26 = 0 - 0;
		local v1279;
		while true do
			if (FlatIdent_30A26 == (3 - 2)) then
				return v23(v162, v164, v163, v1279, "single");
			end
			if (FlatIdent_30A26 == (0 - 0)) then
				v1279 = nil;
				function v1279()
					local FlatIdent_F0A9 = 227 - (224 + 3);
					while true do
						if (FlatIdent_F0A9 == (0 - 0)) then
							v17("objects");
							return v161['internal']['objects'];
						end
					end
				end
				FlatIdent_30A26 = 3 - 2;
			end
		end
	elseif (v164 == "mouseover") then
		local FlatIdent_81D36 = 818 - (646 + 172);
		while true do
			if (FlatIdent_81D36 == (551 - (403 + 148))) then
				v161[v162] = v161['internal']['mouseover'];
				return v161['internal']['mouseover'];
			end
		end
	elseif (v164 == "player") then
		local FlatIdent_49548 = 0 - 0;
		while true do
			if (FlatIdent_49548 == (1224 - (908 + 316))) then
				v161[v162] = v161['internal']['player'];
				return v161['internal']['player'];
			end
		end
	elseif (v164 == "pet") then
		local FlatIdent_42C53 = 0 + 0;
		while true do
			if ((179 - (83 + 96)) == FlatIdent_42C53) then
				v161[v162] = v161['internal']['pet'];
				return v161['internal']['pet'];
			end
		end
	elseif (v164 == "target") then
		local FlatIdent_48D4A = 0 + 0;
		while true do
			if (FlatIdent_48D4A == (0 - 0)) then
				v161[v162] = v161['internal']['target'];
				return v161['internal']['target'];
			end
		end
	elseif (v164 == "focus") then
		local FlatIdent_39C73 = 0 + 0;
		while true do
			if (FlatIdent_39C73 == (1233 - (587 + 646))) then
				v161[v162] = v161['internal']['focus'];
				return v161['internal']['focus'];
			end
		end
	elseif (v164 == "group") then
		local FlatIdent_2888D = 0 - 0;
		local v1290;
		while true do
			if (FlatIdent_2888D == (538 - (454 + 83))) then
				return v23(v162, v164, v163, v1290, "single");
			end
			if (FlatIdent_2888D == (1109 - (67 + 1042))) then
				v1290 = nil;
				function v1290()
					return v161['internal']['group'] or {};
				end
				FlatIdent_2888D = 1909 - (357 + 1551);
			end
		end
	elseif ((v164 == "arena1") or (v164 == "arena2") or (v164 == "arena3") or (v164 == "arena4") or (v164 == "arena5") or (v164 == "party1") or (v164 == "party2") or (v164 == "party3") or (v164 == "party4") or (v164 == "boss1") or (v164 == "boss2") or (v164 == "boss3") or (v164 == "boss4")) then
		local FlatIdent_3E860 = 0 - 0;
		while true do
			if (FlatIdent_3E860 == (579 - (287 + 292))) then
				v161[v162] = v161['internal'][v164];
				return v161['internal'][v164];
			end
		end
	elseif ((v164 == "fullgroup") or (v164 == "fgroup")) then
		local FlatIdent_7A067 = 16 - (7 + 9);
		local v1293;
		while true do
			if (FlatIdent_7A067 == (1929 - (1101 + 828))) then
				v1293 = nil;
				function v1293()
					return v161['internal']['fullGroup'];
				end
				FlatIdent_7A067 = 3 - 2;
			end
			if (FlatIdent_7A067 == (1 + 0)) then
				return v23(v162, v164, v163, v1293, "single");
			end
		end
	elseif (v164 == "missiles") then
		if v0['Util']['Draw'] then
			local FlatIdent_81F4B = 1643 - (485 + 1158);
			while true do
				if (FlatIdent_81F4B == (1344 - (619 + 725))) then
					if not v161['internal']['loaded']['missiles'] then
						local FlatIdent_8D8CE = 0 + 0;
						local v1295;
						while true do
							if (FlatIdent_8D8CE == (1 + 0)) then
								v161['internal']['loaded']['missiles'] = true;
								break;
							end
							if (FlatIdent_8D8CE == (0 + 0)) then
								v1295 = #v161['internal']['missiles'];
								for v1297 in v3:Missiles() do
									local FlatIdent_8B48D = 0 + 0;
									while true do
										if (FlatIdent_8B48D == (0 - 0)) then
											v161['internal']['missiles'][v1295 + (1 - 0)] = v1297;
											v1295 = v1295 + 1 + 0;
											break;
										end
									end
								end
								FlatIdent_8D8CE = 814 - (154 + 659);
							end
						end
					end
					return v161['internal']['missiles'];
				end
			end
		elseif (GetMissileCount and GetMissileWithIndex) then
			local FlatIdent_3CA9C = 0 - 0;
			while true do
				if (FlatIdent_3CA9C == (0 - 0)) then
					if not v161['internal']['loaded']['missiles'] then
						local FlatIdent_5F651 = 0 + 0;
						local v1299;
						while true do
							if (FlatIdent_5F651 == (0 - 0)) then
								v1299 = GetMissileCount();
								for v1300 = 2 - 1, v1299 do
									local FlatIdent_564F4 = 0 - 0;
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
										if (FlatIdent_564F4 == (0 + 0)) then
											v1301, v1302, v1303, v1304, v1305, v1306, v1307, v1308, v1309, v1310, v1311, v1312, v1313 = GetMissileWithIndex(v1300);
											v1314 = {source=v1306,target=v1310,spellId=v1301,mx=v1303,my=v1304,mz=v1305,cx=v1303,cy=v1304,cz=v1305,ix=v1307,iy=v1308,iz=v1309,tx=v1311,ty=v1312,tz=v1313};
											FlatIdent_564F4 = 1 + 0;
										end
										if (FlatIdent_564F4 == (1204 - (50 + 1153))) then
											v161['internal']['missiles'][#v161['internal']['missiles'] + 1 + 0] = v1314;
											break;
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
		local FlatIdent_45AA4 = 541 - (150 + 391);
		local v1294;
		while true do
			if (FlatIdent_45AA4 == (0 - 0)) then
				v1294 = nil;
				function v1294()
					return (v161['arena'] and "party") or (UnitInRaid("player") and "raid") or (UnitInParty("player") and "party");
				end
				FlatIdent_45AA4 = 1 + 0;
			end
			if (FlatIdent_45AA4 == (1 + 0)) then
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
	local FlatIdent_27B7B = 0 + 0;
	while true do
		if (FlatIdent_27B7B == (0 - 0)) then
			if v166 then
				v4(v1.enabledCallbacks, v165);
			else
				v4(v1.updateCallbacks, v165);
			end
			return {cancel=function()
				if v166 then
					for v977 = 532 - (187 + 344), #v1['enabledCallbacks'] do
						if (v1['enabledCallbacks'][v977] == v165) then
							v18(v1.enabledCallbacks, v977);
							break;
						end
					end
				else
					for v978 = 1 + 0, #v1['updateCallbacks'] do
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
	local FlatIdent_5F38B = 0 + 0;
	local v172;
	while true do
		if (FlatIdent_5F38B == (8 - 6)) then
			v169['minors'][v170], v169['libs'][v170] = v171, v169['libs'][v170] or {};
			return v169['libs'][v170], v172;
		end
		if (FlatIdent_5F38B == (1 + 0)) then
			v172 = v169['minors'][v170];
			if (v172 and (v172 >= v171)) then
				return nil;
			end
			FlatIdent_5F38B = 1515 - (1386 + 127);
		end
		if (FlatIdent_5F38B == (1431 - (179 + 1252))) then
			assert(v5(v170) == "string", "Bad argument #2 to `NewLibrary' (string expected)");
			v171 = assert(tonumber(strmatch(v171, "%d+")), "Minor version must either be a number or contain a number.");
			FlatIdent_5F38B = 1 - 0;
		end
	end
end;
v36.GetLibrary = function(v175, v176, v177)
	local FlatIdent_2E6F9 = 0 + 0;
	while true do
		if (FlatIdent_2E6F9 == (267 - (85 + 182))) then
			if (not v175['libs'][v176] and not v177) then
				error(("Cannot find a library instance of %q."):format(tostring(v176)), 1 + 1);
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
	local v179, v180 = "CallbackHandler-1.0", 1923 - (1271 + 646);
	local v181 = v36:NewLibrary(v179, v180);
	if not v181 then
		return;
	end
	local v182 = {__index=function(v381, v382)
		local FlatIdent_8BFC5 = 0 + 0;
		while true do
			if (FlatIdent_8BFC5 == (0 - 0)) then
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
		local FlatIdent_96B53 = 0 + 0;
		local v386;
		local v387;
		local v388;
		while true do
			if ((0 - 0) == FlatIdent_96B53) then
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
				FlatIdent_96B53 = 1225 - (594 + 630);
			end
			if (FlatIdent_96B53 == (978 - (674 + 303))) then
				for v640 = 1085 - (195 + 889), v385 do
					v387[v640], v388[v640] = "arg" .. v640, "old_arg" .. v640;
				end
				v386 = v386:gsub("OLD_ARGS", v183(v388, ", ")):gsub("ARGS", v183(v387, ", "));
				FlatIdent_96B53 = 2 + 0;
			end
			if ((3 - 1) == FlatIdent_96B53) then
				return v184(v186(v386, "safecall Dispatcher[" .. v385 .. "]"))(v190, v195, v196);
			end
		end
	end
	local v198 = v187({}, {__index=function(v389, v390)
		local FlatIdent_71B7E = 0 + 0;
		local v391;
		while true do
			if ((1 + 0) == FlatIdent_71B7E) then
				return v391;
			end
			if (FlatIdent_71B7E == (1774 - (1230 + 544))) then
				v391 = v197(v390);
				v188(v389, v390, v391);
				FlatIdent_71B7E = 3 - 2;
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
		local v400 = {recurse=(1615 - (827 + 788)),events=v399};
		v400.Fire = function(v643, v644, ...)
			local FlatIdent_22F78 = 0 + 0;
			local v645;
			while true do
				if (FlatIdent_22F78 == (0 + 0)) then
					if (not v189(v399, v644) or not v190(v399[v644])) then
						return;
					end
					v645 = v400['recurse'];
					FlatIdent_22F78 = 1 + 0;
				end
				if (FlatIdent_22F78 == (1 + 1)) then
					v400['recurse'] = v645;
					if (v400['insertQueue'] and (v645 == (1828 - (1668 + 160)))) then
						local FlatIdent_3CFF8 = 0 - 0;
						while true do
							if (FlatIdent_3CFF8 == (0 + 0)) then
								for v1088, v1089 in v192(v400.insertQueue) do
									local FlatIdent_8A05C = 664 - (496 + 168);
									local v1090;
									while true do
										if (FlatIdent_8A05C == (1383 - (443 + 940))) then
											v1090 = not v189(v399, v1088) or not v190(v399[v1088]);
											for v1122, v1123 in v192(v1089) do
												local FlatIdent_6ED07 = 616 - (540 + 76);
												while true do
													if (FlatIdent_6ED07 == (0 + 0)) then
														v399[v1088][v1122] = v1123;
														if (v1090 and v400['OnUsed']) then
															local FlatIdent_3FDAC = 0 - 0;
															while true do
																if (FlatIdent_3FDAC == (0 + 0)) then
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
				if (FlatIdent_22F78 == (3 - 2)) then
					v400['recurse'] = v645 + (1763 - (1357 + 405));
					v198[v191("#", ...) + (1 - 0)](v399[v644], v644, ...);
					FlatIdent_22F78 = 944 - (199 + 743);
				end
			end
		end;
		v393[v394] = function(v647, v648, v649, ...)
			local FlatIdent_5BE32 = 0 - 0;
			local v650;
			local v651;
			while true do
				if (FlatIdent_5BE32 == (0 - 0)) then
					if (v193(v648) ~= "string") then
						v185("Usage: " .. v394 .. "(eventname, method[, arg]): 'eventname' - string expected.", 6 - 4);
					end
					v649 = v649 or v648;
					FlatIdent_5BE32 = 1203 - (861 + 341);
				end
				if (FlatIdent_5BE32 == (3 - 1)) then
					v651 = nil;
					if (v193(v649) == "string") then
						local FlatIdent_8D8AF = 0 + 0;
						while true do
							if (FlatIdent_8D8AF == (0 + 0)) then
								if (v193(v647) ~= "table") then
									v185("Usage: " .. v394 .. '("eventname", "methodname"): self was not a table?', 9 - 7);
								elseif (v647 == v393) then
									v185("Usage: " .. v394 .. '("eventname", "methodname"): do not use Library:' .. v394 .. "(), use your own 'self'", 387 - (278 + 107));
								elseif (v193(v647[v649]) ~= "function") then
									v185("Usage: " .. v394 .. '("eventname", "methodname"): \'methodname\' - method \'' .. v194(v649) .. "' not found on self.", 3 - 1);
								end
								if (v191("#", ...) >= (1 - 0)) then
									local FlatIdent_C9B0 = 0 + 0;
									local v1125;
									while true do
										if (FlatIdent_C9B0 == (0 + 0)) then
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
						local FlatIdent_6FA30 = 1016 - (730 + 286);
						while true do
							if (FlatIdent_6FA30 == (336 - (190 + 146))) then
								if ((v193(v647) ~= "table") and (v193(v647) ~= "string") and (v193(v647) ~= "thread")) then
									v185("Usage: " .. v394 .. '(self or \"addonId\", eventname, method): \'self or addonId\': table or string or thread expected.', 1 + 1);
								end
								if (v191("#", ...) >= (1 - 0)) then
									local FlatIdent_75E6 = 0 + 0;
									local v1126;
									while true do
										if (FlatIdent_75E6 == (0 - 0)) then
											v1126 = v191(1 + 0, ...);
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
					FlatIdent_5BE32 = 2 + 1;
				end
				if (FlatIdent_5BE32 == (1 + 2)) then
					if (v399[v648][v647] or (v400['recurse'] < (1 - 0))) then
						local FlatIdent_7D8E9 = 34 - (27 + 7);
						while true do
							if ((0 - 0) == FlatIdent_7D8E9) then
								v399[v648][v647] = v651;
								if (v400['OnUsed'] and v650) then
									v400.OnUsed(v400, v393, v648);
								end
								break;
							end
						end
					else
						local FlatIdent_2F169 = 0 + 0;
						while true do
							if (FlatIdent_2F169 == (0 - 0)) then
								v400['insertQueue'] = v400['insertQueue'] or v187({}, v182);
								v400['insertQueue'][v648][v647] = v651;
								break;
							end
						end
					end
					break;
				end
				if ((281 - (95 + 185)) == FlatIdent_5BE32) then
					v650 = not v189(v399, v648) or not v190(v399[v648]);
					if ((v193(v649) ~= "string") and (v193(v649) ~= "function")) then
						v185("Usage: " .. v394 .. '("eventname", "methodname"): \'methodname\' - string or function expected.', 7 - 5);
					end
					FlatIdent_5BE32 = 1686 - (481 + 1203);
				end
			end
		end;
		v393[v395] = function(v652, v653)
			local FlatIdent_1FA30 = 0 + 0;
			while true do
				if (FlatIdent_1FA30 == (1515 - (1034 + 480))) then
					if (v189(v399, v653) and v399[v653][v652]) then
						local FlatIdent_49DC3 = 1740 - (773 + 967);
						while true do
							if (FlatIdent_49DC3 == (1405 - (198 + 1207))) then
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
				if (FlatIdent_1FA30 == (0 + 0)) then
					if (not v652 or (v652 == v393)) then
						v185("Usage: " .. v395 .. "(eventname): bad 'self'", 1410 - (547 + 861));
					end
					if (v193(v653) ~= "string") then
						v185("Usage: " .. v395 .. "(eventname): 'eventname' - string expected.", 1248 - (465 + 781));
					end
					FlatIdent_1FA30 = 2 - 1;
				end
			end
		end;
		if v396 then
			v393[v396] = function(...)
				local FlatIdent_3AE5 = 0 - 0;
				while true do
					if ((0 - 0) == FlatIdent_3AE5) then
						if (v191("#", ...) < (1 - 0)) then
							v185("Usage: " .. v396 .. '([whatFor]): missing \'self\' or \"addonId\" to unregister events for.', 1423 - (866 + 555));
						end
						if ((v191("#", ...) == (1 - 0)) and (... == v393)) then
							v185("Usage: " .. v396 .. '([whatFor]): supply a meaningful \'self\' or \"addonId\"', 6 - 4);
						end
						FlatIdent_3AE5 = 83 - (15 + 67);
					end
					if (FlatIdent_3AE5 == (198 - (49 + 148))) then
						for v1091 = 1 - 0, v191("#", ...) do
							local FlatIdent_85D9B = 0 + 0;
							local v1092;
							while true do
								if (FlatIdent_85D9B == (399 - (45 + 354))) then
									v1092 = v191(v1091, ...);
									if v400['insertQueue'] then
										for v1185, v1186 in v192(v400.insertQueue) do
											if v1186[v1092] then
												v1186[v1092] = nil;
											end
										end
									end
									FlatIdent_85D9B = 2 - 1;
								end
								if ((518 - (83 + 434)) == FlatIdent_85D9B) then
									for v1127, v1128 in v192(v399) do
										if v1128[v1092] then
											local FlatIdent_34590 = 0 - 0;
											while true do
												if (FlatIdent_34590 == (0 - 0)) then
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
							end
						end
						break;
					end
				end
			end;
		end
		return v400;
	end;
end
if (v1['gameVersion'] == (31 - (19 + 11))) then
	local v404 = "LibInspect";
	local v405 = {version=(189 - 120)};
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
	local v414 = 1273.5 - (973 + 299);
	local v415 = 589 - (418 + 161);
	local v416 = 1679 - (351 + 1326);
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
		local FlatIdent_3BFE2 = 1439 - (205 + 1234);
		while true do
			if (FlatIdent_3BFE2 == (0 - 0)) then
				v419.OnEvent = function(v987, v988, ...)
					local FlatIdent_815AE = 564 - (60 + 504);
					local v989;
					while true do
						if (FlatIdent_815AE == (1557 - (621 + 936))) then
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
	v405['state'] = {mainq={},staleq={},t=(0 + 0),last_inspect=(0 - 0),current_guid=nil,throttle=(0 + 0),tt=(0 + 0),debounce_send_update=(63 - (62 + 1))};
	v405['cache'] = {};
	v405['static_cache'] = {};
	if not v405['hooked'] then
		local FlatIdent_614D6 = 0 - 0;
		while true do
			if (FlatIdent_614D6 == (0 + 0)) then
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
	local v455 = 3 + 1;
	local v456 = {[2227 - (1950 + 27)]="tank",[1060 - 809]="melee",[93 + 159]="melee",[2288 - (121 + 1590)]="melee",[984 - 403]="tank",[1364 - (400 + 862)]="ranged",[74 + 29]="melee",[504 - 400]="tank",[1197 - (320 + 772)]="healer",[533 - 280]="ranged",[2109 - (595 + 1260)]="ranged",[55 + 200]="melee",[788 - (670 + 56)]="ranged",[224 - 161]="ranged",[1980 - (384 + 1532)]="ranged",[1114 - 846]="tank",[457 - 188]="melee",[207 + 63]="healer",[182 - 117]="healer",[23 + 43]="tank",[1006 - (386 + 550)]="melee",[995 - 739]="healer",[237 + 20]="healer",[1048 - (521 + 269)]="ranged",[688 - 429]="melee",[2249 - (1565 + 424)]="melee",[257 + 4]="melee",[36 + 226]="ranged",[403 - (105 + 35)]="melee",[421 - 157]="healer",[840 - 575]="ranged",[169 + 97]="ranged",[347 - 80]="ranged",[842 - (530 + 241)]="melee",[1 + 71]="melee",[55 + 18]="tank",[2096 - (106 + 517)]="ranged",[5484 - 4017]="ranged",[325 + 1143]="healer"};
	local v457 = {HUNTER="DAMAGER",MAGE="DAMAGER",ROGUE="DAMAGER",WARLOCK="DAMAGER"};
	local v458 = {MAGE="ranged",ROGUE="melee",WARLOCK="ranged"};
	v405.PLAYER_LOGIN = function(v663)
		local FlatIdent_5C06C = 0 + 0;
		local v665;
		local v666;
		while true do
			if (FlatIdent_5C06C == (5 - 2)) then
				v419:RegisterEvent("UNIT_NAME_UPDATE");
				v419:RegisterEvent("UNIT_AURA");
				v419:RegisterEvent("CHAT_MSG_ADDON");
				FlatIdent_5C06C = 1 + 3;
			end
			if (FlatIdent_5C06C == (0 + 0)) then
				v663['state']['logged_in'] = true;
				v663:CacheGameData();
				v419:RegisterEvent("INSPECT_READY");
				FlatIdent_5C06C = 1 + 0;
			end
			if (FlatIdent_5C06C == (3 - 2)) then
				v419:RegisterEvent("GROUP_ROSTER_UPDATE");
				v419:RegisterEvent("PLAYER_ENTERING_WORLD");
				v419:RegisterEvent("UNIT_LEVEL");
				FlatIdent_5C06C = 1 + 1;
			end
			if (FlatIdent_5C06C == (2 + 2)) then
				v452(v411);
				v665 = v444("player");
				v666 = v663:BuildInfo("player");
				FlatIdent_5C06C = 10 - 5;
			end
			if (FlatIdent_5C06C == (1 + 1)) then
				v419:RegisterEvent("PLAYER_TALENT_UPDATE");
				v419:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
				v419:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
				FlatIdent_5C06C = 1346 - (173 + 1170);
			end
			if ((1787 - (538 + 1244)) == FlatIdent_5C06C) then
				v663['events']:Fire(v407, v665, "player", v666);
				break;
			end
		end
	end;
	v405.PLAYER_LOGOUT = function(v667)
		v667['state']['logged_in'] = false;
	end;
	v405['state']['t'] = 1336 - (1020 + 316);
	if not v419['OnUpdate'] then
		local FlatIdent_54B5A = 0 + 0;
		while true do
			if (FlatIdent_54B5A == (453 - (285 + 168))) then
				v419.OnUpdate = function(v990, v991)
					local FlatIdent_7BF07 = 0 - 0;
					while true do
						if (FlatIdent_7BF07 == (79 - (43 + 35))) then
							if (v405['state']['t'] > v414) then
								local FlatIdent_85E4A = 0 - 0;
								while true do
									if ((0 - 0) == FlatIdent_85E4A) then
										v405:ProcessQueues();
										v405['state']['t'] = 574 - (126 + 448);
										break;
									end
								end
							end
							if ((v405['state']['tt'] > (3 + 0)) and (v405['state']['throttle'] > (0 + 0))) then
								local FlatIdent_81948 = 0 - 0;
								while true do
									if (FlatIdent_81948 == (40 - (32 + 8))) then
										v405['state']['throttle'] = v405['state']['throttle'] - (1 + 0);
										v405['state']['tt'] = 0 + 0;
										break;
									end
								end
							end
							FlatIdent_7BF07 = 3 - 1;
						end
						if (FlatIdent_7BF07 == (0 - 0)) then
							v405['state']['t'] = v405['state']['t'] + v991;
							v405['state']['tt'] = v405['state']['tt'] + v991;
							FlatIdent_7BF07 = 910 - (907 + 2);
						end
						if (FlatIdent_7BF07 == (2 + 0)) then
							if (v405['state']['debounce_send_update'] > (0 - 0)) then
								local FlatIdent_12E3E = 328 - (196 + 132);
								local v1132;
								while true do
									if (FlatIdent_12E3E == (498 - (372 + 126))) then
										v1132 = v405['state']['debounce_send_update'] - v991;
										v405['state']['debounce_send_update'] = v1132;
										FlatIdent_12E3E = 4 - 3;
									end
									if (FlatIdent_12E3E == (3 - 2)) then
										if (v1132 <= (0 + 0)) then
											v405:SendLatestSpecData();
										end
										break;
									end
								end
							end
							break;
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
		local FlatIdent_97F3E = 748 - (83 + 665);
		local v676;
		local v677;
		local v678;
		local v679;
		local v680;
		local v681;
		local v682;
		while true do
			if ((0 - 0) == FlatIdent_97F3E) then
				v676, v677, v678, v679, v680, v681 = v439(v671, v672, v673, v674, v675);
				if not v676 then
					return {};
				end
				FlatIdent_97F3E = 1575 - (208 + 1366);
			end
			if ((1 + 0) == FlatIdent_97F3E) then
				v682 = v669['static_cache']['talents'];
				if not v682[v676] then
					v682[v676] = {spell_id=v681,talent_id=v676,name_localized=v677,icon=v678,tier=v671,column=v672};
				end
				FlatIdent_97F3E = 2 - 0;
			end
			if (FlatIdent_97F3E == (618 - (160 + 456))) then
				return v682[v676], v679;
			end
		end
	end;
	v405.GetCachedTalentInfoByID = function(v683, v684)
		local FlatIdent_49D2A = 0 + 0;
		local v685;
		while true do
			if (FlatIdent_49D2A == (0 + 0)) then
				v685 = v683['static_cache']['talents'];
				if (v684 and not v685[v684]) then
					local FlatIdent_6CAA0 = 467 - (153 + 314);
					local v995;
					local v996;
					local v997;
					local v998;
					local v999;
					local v1000;
					while true do
						if (FlatIdent_6CAA0 == (3 - 2)) then
							v685[v684] = {spell_id=v998,talent_id=v684,name_localized=v996,icon=v997,tier=v999,column=v1000};
							break;
						end
						if (FlatIdent_6CAA0 == (1391 - (512 + 879))) then
							v995, v996, v997, v995, v995, v998, v995, v999, v1000 = v440(v684);
							if not v996 then
								return nil;
							end
							FlatIdent_6CAA0 = 4 - 3;
						end
					end
				end
				FlatIdent_49D2A = 2 - 1;
			end
			if ((1 + 0) == FlatIdent_49D2A) then
				return v685[v684];
			end
		end
	end;
	v405.GetCachedPvpTalentInfoByID = function(v686, v687)
		local FlatIdent_4699E = 437 - (33 + 404);
		local v688;
		while true do
			if (FlatIdent_4699E == (390 - (287 + 102))) then
				return v688[v687];
			end
			if ((0 - 0) == FlatIdent_4699E) then
				v688 = v686['static_cache']['pvp_talents'];
				if (v687 and not v688[v687]) then
					local FlatIdent_66526 = 1196 - (1102 + 94);
					local v1002;
					local v1003;
					local v1004;
					local v1005;
					while true do
						if (FlatIdent_66526 == (0 + 0)) then
							v1002, v1003, v1004, v1002, v1002, v1005 = v437(v687);
							if not v1003 then
								return nil;
							end
							FlatIdent_66526 = 1 + 0;
						end
						if (FlatIdent_66526 == (1 + 0)) then
							v688[v687] = {spell_id=v1005,talent_id=v687,name_localized=v1003,icon=v1004};
							break;
						end
					end
				end
				FlatIdent_4699E = 1 + 0;
			end
		end
	end;
	v405.CacheGameData = function(v689)
		local FlatIdent_56486 = 0 - 0;
		local v690;
		while true do
			if (FlatIdent_56486 == (1143 - (203 + 939))) then
				for v912 = 1686 - (647 + 1038), v442() do
					local FlatIdent_283CF = 0 - 0;
					local v913;
					local v914;
					while true do
						if (FlatIdent_283CF == (2 - 1)) then
							v689['static_cache']['class_to_class_id'][v914] = v912;
							break;
						end
						if (FlatIdent_283CF == (0 - 0)) then
							for v1007 = 148 - (54 + 93), v429(v912) do
								local FlatIdent_2DF9E = 0 - 0;
								local v1008;
								local v1009;
								local v1010;
								local v1011;
								local v1012;
								local v1014;
								while true do
									if (FlatIdent_2DF9E == (14 - 10)) then
										v1014['role'] = v436(v1008);
										break;
									end
									if (FlatIdent_2DF9E == (0 + 0)) then
										v1008, v1009, v1010, v1011, v1012 = v435(v912, v1007);
										v690[v1008] = {};
										FlatIdent_2DF9E = 1 + 0;
									end
									if (FlatIdent_2DF9E == (74 - (15 + 56))) then
										v1014['icon'] = v1011;
										v1014['background'] = v1012;
										FlatIdent_2DF9E = 1 + 3;
									end
									if ((2 - 0) == FlatIdent_2DF9E) then
										v1014['name_localized'] = v1009;
										v1014['description'] = v1010;
										FlatIdent_2DF9E = 5 - 2;
									end
									if (FlatIdent_2DF9E == (1 + 0)) then
										v1014 = v690[v1008];
										v1014['idx'] = v1007;
										FlatIdent_2DF9E = 1 + 1;
									end
								end
							end
							v913, v914 = v427(v912);
							FlatIdent_283CF = 1 + 0;
						end
					end
				end
				break;
			end
			if (FlatIdent_56486 == (0 + 0)) then
				v690 = v689['static_cache']['global_specs'];
				v690[0 + 0] = {};
				FlatIdent_56486 = 1 + 0;
			end
		end
	end;
	v405.GuidToUnit = function(v692, v693)
		local FlatIdent_4EC1D = 0 - 0;
		local v694;
		while true do
			if ((0 + 0) == FlatIdent_4EC1D) then
				v694 = v692['cache'][v693];
				if (v694 and v694['lku'] and (v444(v694.lku) == v693)) then
					return v694['lku'];
				end
				FlatIdent_4EC1D = 1136 - (637 + 498);
			end
			if (FlatIdent_4EC1D == (1 - 0)) then
				for v916, v917 in ipairs(v692:GroupUnits()) do
					if (v443(v917) and (v444(v917) == v693)) then
						local FlatIdent_7671E = 0 + 0;
						while true do
							if (FlatIdent_7671E == (1367 - (247 + 1120))) then
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
		local FlatIdent_1F5CF = 0 - 0;
		local v697;
		local v698;
		local v699;
		while true do
			if ((1016 - (929 + 87)) == FlatIdent_1F5CF) then
				if not v448(v696) then
					return;
				end
				if v449(v696, "player") then
					local FlatIdent_8D0EB = 1477 - (164 + 1313);
					while true do
						if (FlatIdent_8D0EB == (0 - 0)) then
							v695['events']:Fire(v407, v444("player"), "player", v695:BuildInfo("player"));
							return;
						end
					end
				end
				FlatIdent_1F5CF = 1 + 0;
			end
			if (FlatIdent_1F5CF == (7 - 5)) then
				if not v697[v699] then
					local FlatIdent_1342B = 0 + 0;
					while true do
						if (FlatIdent_1342B == (0 - 0)) then
							v697[v699] = 1367 - (692 + 674);
							v698[v699] = nil;
							FlatIdent_1342B = 664 - (381 + 282);
						end
						if (FlatIdent_1342B == (2 - 1)) then
							v695['frame']:Show();
							v695['events']:Fire(v410);
							break;
						end
					end
				end
				break;
			end
			if (FlatIdent_1F5CF == (1885 - (1607 + 277))) then
				v697, v698 = v695['state']['mainq'], v695['state']['staleq'];
				v699 = v444(v696);
				FlatIdent_1F5CF = 1 + 1;
			end
		end
	end;
	v405.Refresh = function(v700, v701)
		local FlatIdent_14C5A = 0 + 0;
		local v702;
		while true do
			if (FlatIdent_14C5A == (1667 - (592 + 1075))) then
				v702 = v444(v701);
				if not v702 then
					return;
				end
				FlatIdent_14C5A = 4 - 3;
			end
			if (FlatIdent_14C5A == (1 + 0)) then
				if not v700['state']['mainq'][v702] then
					local FlatIdent_57D97 = 0 - 0;
					while true do
						if (FlatIdent_57D97 == (1101 - (165 + 935))) then
							v700['events']:Fire(v410);
							break;
						end
						if (FlatIdent_57D97 == (0 + 0)) then
							v700['state']['staleq'][v702] = 1185 - (788 + 396);
							v700['frame']:Show();
							FlatIdent_57D97 = 2 - 1;
						end
					end
				end
				break;
			end
		end
	end;
	v405.ProcessQueues = function(v703)
		local FlatIdent_954C5 = 1571 - (320 + 1251);
		local v704;
		local v705;
		while true do
			if (FlatIdent_954C5 == (1740 - (1047 + 690))) then
				for v918, v919 in pairs(v704) do
					local v920 = v703:GuidToUnit(v918);
					if not v920 then
						v704[v918], v705[v918] = nil, nil;
					elseif (not v425(v920) or not v447(v920)) then
						v704[v918], v705[v918] = nil, 2 - 1;
					else
						v704[v918] = v919 + 1 + 0;
						v703['state']['current_guid'] = v918;
						NotifyInspect(v920);
						break;
					end
				end
				if (not next(v704) and not next(v705) and (v703['state']['throttle'] == (0 - 0)) and (v703['state']['debounce_send_update'] <= (0 + 0))) then
					v419:Hide();
				end
				v703['events']:Fire(v410);
				break;
			end
			if (FlatIdent_954C5 == (1 + 1)) then
				if (not next(v704) and next(v705)) then
					local FlatIdent_76021 = 0 - 0;
					while true do
						if (FlatIdent_76021 == (0 - 0)) then
							v703['state']['mainq'], v703['state']['staleq'] = v703['state']['staleq'], v703['state']['mainq'];
							v704, v705 = v705, v704;
							break;
						end
					end
				end
				if ((v703['state']['last_inspect'] + v415) < GetTime()) then
					local FlatIdent_59889 = 0 - 0;
					local v1026;
					while true do
						if ((0 - 0) == FlatIdent_59889) then
							v1026 = v703['state']['current_guid'];
							if v1026 then
								local FlatIdent_6EB8E = 0 + 0;
								local v1134;
								while true do
									if (FlatIdent_6EB8E == (732 - (699 + 33))) then
										v1134 = (v704 and v704[v1026]) or (v416 + 1 + 0);
										if not v703:GuidToUnit(v1026) then
											v704[v1026], v705[v1026] = nil, nil;
										elseif (v1134 > v416) then
											v704[v1026], v705[v1026] = nil, 1 + 0;
										else
											v704[v1026] = v1134 + 1 + 0;
										end
										FlatIdent_6EB8E = 1 - 0;
									end
									if (FlatIdent_6EB8E == (1 + 0)) then
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
				FlatIdent_954C5 = 4 - 1;
			end
			if (FlatIdent_954C5 == (1 + 0)) then
				if (InspectFrame and InspectFrame:IsShown()) then
					return;
				end
				v704 = v703['state']['mainq'];
				v705 = v703['state']['staleq'];
				FlatIdent_954C5 = 2 + 0;
			end
			if (FlatIdent_954C5 == (0 + 0)) then
				if not v703['state']['logged_in'] then
					return;
				end
				if InCombatLockdown() then
					return;
				end
				if UnitIsDead("player") then
					return;
				end
				FlatIdent_954C5 = 1 + 0;
			end
		end
	end;
	v405.UpdatePlayerInfo = function(v706, v707, v708, v709)
		local FlatIdent_475C = 0 - 0;
		local v717;
		while true do
			if (FlatIdent_475C == (30 - (5 + 23))) then
				if not v709['spec_role'] then
					v709['spec_role'] = v717 and v457[v717];
				end
				if not v709['spec_role_detailed'] then
					v709['spec_role_detailed'] = v717 and v458[v717];
				end
				FlatIdent_475C = 5 - 2;
			end
			if (FlatIdent_475C == (263 - (184 + 76))) then
				v709['lku'] = v708;
				break;
			end
			if (FlatIdent_475C == (867 - (340 + 526))) then
				if (v709['realm'] and (v709['realm'] == "")) then
					v709['realm'] = nil;
				end
				v709['class_id'] = v717 and v706['static_cache']['class_to_class_id'][v717];
				FlatIdent_475C = 8 - 6;
			end
			if (FlatIdent_475C == (274 - (151 + 123))) then
				v709['class_localized'], v709['class'], v709['race_localized'], v709['race'], v709['gender'], v709['name'], v709['realm'] = v430(v707);
				v717 = v709['class'];
				FlatIdent_475C = 415 - (42 + 372);
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
			local FlatIdent_87A6C = 1382 - (31 + 1351);
			while true do
				if (FlatIdent_87A6C == (1 + 0)) then
					v720['events']:Fire(v410);
					break;
				end
				if (FlatIdent_87A6C == (0 + 0)) then
					v720['state']['staleq'][v722] = 80 - (48 + 31);
					v720['frame']:Show();
					FlatIdent_87A6C = 880 - (812 + 67);
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
			local FlatIdent_47C6C = 1281 - (399 + 882);
			local v1033;
			while true do
				if (FlatIdent_47C6C == (4 - 0)) then
					v724['spec_role_detailed'] = v456[v730];
					break;
				end
				if (FlatIdent_47C6C == (0 - 0)) then
					v724['global_spec_id'] = v730;
					v1033 = v731[v730];
					FlatIdent_47C6C = 1 + 0;
				end
				if (FlatIdent_47C6C == (648 - (528 + 119))) then
					v724['spec_index'] = v1033['idx'];
					v724['spec_name_localized'] = v1033['name_localized'];
					FlatIdent_47C6C = 1 + 1;
				end
				if ((2 + 0) == FlatIdent_47C6C) then
					v724['spec_description'] = v1033['description'];
					v724['spec_icon'] = v1033['icon'];
					FlatIdent_47C6C = 5 - 2;
				end
				if (FlatIdent_47C6C == (3 + 0)) then
					v724['spec_background'] = v1033['background'];
					v724['spec_role'] = v1033['role'];
					FlatIdent_47C6C = 1 + 3;
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
			local FlatIdent_45451 = 0 - 0;
			while true do
				if (FlatIdent_45451 == (2 + 0)) then
					if v728 then
						for v1161 = 1 - 0, v455 do
							local FlatIdent_5F353 = 0 - 0;
							local v1162;
							while true do
								if (FlatIdent_5F353 == (1104 - (77 + 1027))) then
									v1162 = v431(v721, v1161);
									if v1162 then
										v724['pvp_talents'][v1162] = v720:GetCachedPvpTalentInfoByID(v1162);
									end
									break;
								end
							end
						end
					else
						for v1163 = 1 - 0, v455 do
							local FlatIdent_A615 = 1088 - (938 + 150);
							local v1164;
							local v1165;
							while true do
								if ((0 + 0) == FlatIdent_A615) then
									v1164 = v438(v1163);
									v1165 = v1164 and v1164['selectedTalentID'];
									FlatIdent_A615 = 469 - (183 + 285);
								end
								if (FlatIdent_A615 == (1166 - (607 + 558))) then
									if v1165 then
										v724['pvp_talents'][v1165] = v720:GetCachedPvpTalentInfoByID(v1165);
									end
									break;
								end
							end
						end
					end
					break;
				end
				if ((0 - 0) == FlatIdent_45451) then
					v724['spec_group'] = GetActiveSpecGroup(v728);
					wipe(v724.talents);
					FlatIdent_45451 = 1293 - (324 + 968);
				end
				if (FlatIdent_45451 == (647 - (83 + 563))) then
					for v1095 = 567 - (441 + 125), v453 do
						for v1136 = 1 + 0, v454 do
							local FlatIdent_3F20B = 0 - 0;
							local v1137;
							local v1138;
							while true do
								if ((0 + 0) == FlatIdent_3F20B) then
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
					FlatIdent_45451 = 1401 - (711 + 688);
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
		local FlatIdent_6787E = 0 + 0;
		local v737;
		local v738;
		while true do
			if (FlatIdent_6787E == (0 - 0)) then
				v737 = v735:GuidToUnit(v736);
				v738 = false;
				FlatIdent_6787E = 2 - 1;
			end
			if ((1901 - (189 + 1711)) == FlatIdent_6787E) then
				if v737 then
					local FlatIdent_2EEE9 = 505 - (215 + 290);
					local v1052;
					local v1053;
					local v1056;
					while true do
						if (FlatIdent_2EEE9 == (1 + 1)) then
							if not v735['static_cache']['global_specs'][v1056] then
								local FlatIdent_4AA76 = 0 - 0;
								while true do
									if (FlatIdent_4AA76 == (105 - (62 + 43))) then
										v1053[v736] = 1 + 0;
										return;
									end
								end
							end
							v735['events']:Fire(v407, v736, v737, v735:BuildInfo(v737));
							FlatIdent_2EEE9 = 7 - 4;
						end
						if (FlatIdent_2EEE9 == (0 + 0)) then
							if (v736 == v735['state']['current_guid']) then
								local FlatIdent_8F077 = 0 + 0;
								while true do
									if (FlatIdent_8F077 == (1803 - (466 + 1337))) then
										v735['state']['current_guid'] = nil;
										v738 = true;
										break;
									end
								end
							end
							v1052, v1053 = v735['state']['mainq'], v735['state']['staleq'];
							FlatIdent_2EEE9 = 1135 - (358 + 776);
						end
						if (FlatIdent_2EEE9 == (1300 - (450 + 847))) then
							v735['events']:Fire(v409, v736, v737);
							break;
						end
						if ((1757 - (1005 + 751)) == FlatIdent_2EEE9) then
							v1052[v736], v1053[v736] = nil, nil;
							v1056 = v432(v737);
							FlatIdent_2EEE9 = 7 - 5;
						end
					end
				end
				if v738 then
					v426();
				end
				FlatIdent_6787E = 2 + 0;
			end
			if ((5 - 3) == FlatIdent_6787E) then
				v735['events']:Fire(v410);
				break;
			end
		end
	end;
	v405.PLAYER_ENTERING_WORLD = function(v739)
		if (v739['commScope'] == "INSTANCE_CHAT") then
			local FlatIdent_5705F = 0 - 0;
			while true do
				if (FlatIdent_5705F == (1594 - (912 + 682))) then
					v739['commScope'] = nil;
					v739:UpdateCommScope();
					break;
				end
			end
		end
	end;
	local v478 = {};
	v405.GROUP_ROSTER_UPDATE = function(v740)
		local FlatIdent_83608 = 1320 - (527 + 793);
		local v741;
		local v742;
		while true do
			if (FlatIdent_83608 == (1 + 1)) then
				wipe(v478);
				v740:UpdateCommScope();
				break;
			end
			if (FlatIdent_83608 == (0 - 0)) then
				v741 = v740['cache'];
				v742 = v740:GroupUnits();
				FlatIdent_83608 = 1 + 0;
			end
			if (FlatIdent_83608 == (3 - 2)) then
				for v921, v922 in ipairs(v740:GroupUnits()) do
					local FlatIdent_3EF8A = 0 - 0;
					local v923;
					while true do
						if (FlatIdent_3EF8A == (236 - (195 + 41))) then
							v923 = v444(v922);
							if v923 then
								local FlatIdent_47A28 = 1571 - (504 + 1067);
								while true do
									if ((868 - (181 + 687)) == FlatIdent_47A28) then
										v478[v923] = true;
										if not v741[v923] then
											local FlatIdent_32C49 = 0 - 0;
											while true do
												if (FlatIdent_32C49 == (0 + 0)) then
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
						local FlatIdent_48E9F = 1298 - (625 + 673);
						while true do
							if ((218 - (117 + 101)) == FlatIdent_48E9F) then
								v741[v924] = nil;
								v740['events']:Fire(v408, v924, nil);
								break;
							end
						end
					end
				end
				FlatIdent_83608 = 1272 - (168 + 1102);
			end
		end
	end;
	v405.DoPlayerUpdate = function(v743)
		local FlatIdent_534C1 = 0 - 0;
		while true do
			if (FlatIdent_534C1 == (1906 - (1350 + 556))) then
				v743:Query("player");
				v743['state']['debounce_send_update'] = 5.5 - 3;
				FlatIdent_534C1 = 1 + 0;
			end
			if (FlatIdent_534C1 == (1 + 0)) then
				v743['frame']:Show();
				break;
			end
		end
	end;
	v405.SendLatestSpecData = function(v745)
		local FlatIdent_31E16 = 834 - (413 + 421);
		local v746;
		local v747;
		local v748;
		local v749;
		local v750;
		while true do
			if (FlatIdent_31E16 == (944 - (785 + 157))) then
				v750 = 862 - (358 + 503);
				for v925 in pairs(v748.talents) do
					local FlatIdent_754B3 = 0 + 0;
					while true do
						if (FlatIdent_754B3 == (453 - (296 + 157))) then
							v749 = v749 .. v413 .. v925;
							v750 = v750 + (2 - 1);
							break;
						end
					end
				end
				for v926 = v750, v453 do
					v749 = v749 .. v413 .. (0 - 0);
				end
				FlatIdent_31E16 = 3 + 0;
			end
			if (FlatIdent_31E16 == (284 - (186 + 98))) then
				v746 = v745['commScope'];
				if not v746 then
					return;
				end
				v747 = v444("player");
				FlatIdent_31E16 = 2 - 1;
			end
			if (FlatIdent_31E16 == (497 - (428 + 66))) then
				v750 = 4 - 3;
				for v927 in pairs(v748.pvp_talents) do
					local FlatIdent_73B3E = 600 - (508 + 92);
					while true do
						if (FlatIdent_73B3E == (0 - 0)) then
							v749 = v749 .. v413 .. v927;
							v750 = v750 + (3 - 2);
							break;
						end
					end
				end
				for v928 = v750, v455 do
					v749 = v749 .. v413 .. (1258 - (1229 + 29));
				end
				FlatIdent_31E16 = 4 + 0;
			end
			if (FlatIdent_31E16 == (6 - 2)) then
				v451(v411, v749, v746);
				break;
			end
			if (FlatIdent_31E16 == (669 - (125 + 543))) then
				v748 = v745['cache'][v747];
				if not v748 then
					return;
				end
				v749 = v412 .. v413 .. v747 .. v413 .. (v748['global_spec_id'] or (273 - (146 + 127)));
				FlatIdent_31E16 = 4 - 2;
			end
		end
	end;
	v405.UpdateCommScope = function(v751)
		local FlatIdent_489B9 = 0 - 0;
		local v752;
		while true do
			if ((800 - (385 + 415)) == FlatIdent_489B9) then
				v752 = (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT") or (v441() and "RAID") or (IsInGroup(LE_PARTY_CATEGORY_HOME) and "PARTY");
				if (v751['commScope'] ~= v752) then
					local FlatIdent_78D63 = 0 - 0;
					while true do
						if (FlatIdent_78D63 == (0 + 0)) then
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
	v483['fmt'] = 1 + 0;
	v483['guid'] = v483['fmt'] + (519 - (333 + 185));
	v483['global_spec_id'] = v483['guid'] + 1 + 0;
	v483['talents'] = v483['global_spec_id'] + (4 - 3);
	v483['end_talents'] = v483['talents'] + v453;
	v483['pvp_talents'] = v483['end_talents'] + (3 - 2);
	v483['end_pvp_talents'] = (v483['pvp_talents'] + v455) - (1 + 0);
	v405.CHAT_MSG_ADDON = function(v753, v754, v755, v756, v757)
		local FlatIdent_3506D = 442 - (7 + 435);
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
			if ((1186 - (978 + 202)) == FlatIdent_3506D) then
				v762['talents'] = wipe(v762['talents'] or {});
				for v929 = v483['talents'], v483['end_talents'] do
					local FlatIdent_18E28 = 0 + 0;
					local v930;
					while true do
						if (FlatIdent_18E28 == (0 + 0)) then
							v930 = tonumber(v758[v929]) or (0 + 0);
							if (v930 > (0 + 0)) then
								local FlatIdent_30F65 = 0 + 0;
								local v1098;
								while true do
									if ((0 - 0) == FlatIdent_30F65) then
										v1098 = v753:GetCachedTalentInfoByID(v930);
										if v1098 then
											v762['talents'][v930] = v1098;
										else
											v791 = 566 - (13 + 552);
										end
										break;
									end
								end
							end
							break;
						end
					end
				end
				v762['pvp_talents'] = wipe(v762['pvp_talents'] or {});
				for v931 = v483['pvp_talents'], v483['end_pvp_talents'] do
					local FlatIdent_3357D = 0 - 0;
					local v932;
					while true do
						if ((0 - 0) == FlatIdent_3357D) then
							v932 = tonumber(v758[v931]) or (0 - 0);
							if (v932 > (0 + 0)) then
								local FlatIdent_6B254 = 0 + 0;
								local v1099;
								while true do
									if ((1170 - (826 + 344)) == FlatIdent_6B254) then
										v1099 = v753:GetCachedPvpTalentInfoByID(v932);
										if v1099 then
											v762['pvp_talents'][v932] = v1099;
										else
											v791 = 2 - 1;
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
				FlatIdent_3506D = 6 + 1;
			end
			if (FlatIdent_3506D == (347 - (57 + 289))) then
				v761 = v444(v757);
				if (v761 and (v761 ~= v760)) then
					return;
				end
				v762 = v760 and v753['cache'][v760];
				if not v762 then
					return;
				end
				v763 = v753:GuidToUnit(v760);
				FlatIdent_3506D = 490 - (277 + 211);
			end
			if (FlatIdent_3506D == (1890 - (380 + 1503))) then
				v795, v796 = v753['state']['mainq'], v753['state']['staleq'];
				v797 = (not v791 and v753['inspect_ready_used'] and (v795[v760] or v796[v760]) and (1327 - (867 + 459))) or nil;
				v795[v760], v796[v760] = v791, v797;
				if (v791 or v797) then
					v753['frame']:Show();
				end
				v753['events']:Fire(v407, v760, v763, v762);
				FlatIdent_3506D = 3 + 5;
			end
			if (FlatIdent_3506D == (373 - (322 + 43))) then
				v753['events']:Fire(v410);
				break;
			end
			if (FlatIdent_3506D == (14 - 9)) then
				v762['spec_icon'] = v774[v775]['icon'];
				v762['spec_background'] = v774[v775]['background'];
				v762['spec_role'] = v774[v775]['role'];
				v762['spec_role_detailed'] = v456[v775];
				v791 = nil;
				FlatIdent_3506D = 578 - (92 + 480);
			end
			if ((8 - 4) == FlatIdent_3506D) then
				if (not v775 or not v774[v775]) then
					return;
				end
				v762['global_spec_id'] = v775;
				v762['spec_index'] = v774[v775]['idx'];
				v762['spec_name_localized'] = v774[v775]['name_localized'];
				v762['spec_description'] = v774[v775]['description'];
				FlatIdent_3506D = 1478 - (179 + 1294);
			end
			if ((2 + 1) == FlatIdent_3506D) then
				v762['class_localized'], v762['class'], v762['race_localized'], v762['race'], v762['gender'], v762['name'], v762['realm'] = v430(v760);
				if (v762['realm'] and (v762['realm'] == "")) then
					v762['realm'] = nil;
				end
				v762['class_id'] = v753['static_cache']['class_to_class_id'][v762['class']];
				v774 = v753['static_cache']['global_specs'];
				v775 = v758[v483['global_spec_id']] and tonumber(v758[v483['global_spec_id']]);
				FlatIdent_3506D = 1311 - (96 + 1211);
			end
			if (FlatIdent_3506D == (1930 - (1318 + 610))) then
				if not v763 then
					return;
				end
				if v449(v763, "player") then
					return;
				end
				v753['state']['throttle'] = v753['state']['throttle'] + (1 - 0);
				v753['frame']:Show();
				if (v753['state']['throttle'] > (1764 - (257 + 1467))) then
					return;
				end
				FlatIdent_3506D = 1 + 2;
			end
			if (FlatIdent_3506D == (0 + 0)) then
				if ((v754 ~= v411) or (v756 ~= v753['commScope'])) then
					return;
				end
				v758 = {strsplit(v413, v755)};
				v759 = v758[v483['fmt']];
				if (v759 ~= v412) then
					return;
				end
				v760 = v758[v483['guid']];
				FlatIdent_3506D = 906 - (698 + 207);
			end
		end
	end;
	v405.UNIT_LEVEL = function(v800, v801)
		local FlatIdent_92B70 = 0 - 0;
		while true do
			if ((250 - (160 + 90)) == FlatIdent_92B70) then
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
		local FlatIdent_7A597 = 0 + 0;
		local v807;
		local v808;
		local v809;
		while true do
			if ((32 - (6 + 25)) == FlatIdent_7A597) then
				v809 = v808 and v807[v808];
				if v809 then
					local FlatIdent_8EC78 = 0 + 0;
					while true do
						if ((1705 - (1564 + 141)) == FlatIdent_8EC78) then
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
			if (FlatIdent_7A597 == (0 - 0)) then
				v807 = v805['cache'];
				v808 = v444(v806);
				FlatIdent_7A597 = 447 - (133 + 313);
			end
		end
	end;
	v405.UNIT_AURA = function(v810, v811)
		local FlatIdent_8BB5E = 0 - 0;
		local v812;
		local v813;
		local v814;
		while true do
			if (FlatIdent_8BB5E == (0 + 0)) then
				v812 = v810['cache'];
				v813 = v444(v811);
				FlatIdent_8BB5E = 1173 - (116 + 1056);
			end
			if ((1403 - (262 + 1140)) == FlatIdent_8BB5E) then
				v814 = v813 and v812[v813];
				if v814 then
					if not v449(v811, "player") then
						if UnitIsVisible(v811) then
							if v814['not_visible'] then
								local FlatIdent_37F10 = 1280 - (783 + 497);
								while true do
									if ((0 + 0) == FlatIdent_37F10) then
										v814['not_visible'] = nil;
										if not v810['state']['mainq'][v813] then
											local FlatIdent_86BD9 = 0 + 0;
											while true do
												if (FlatIdent_86BD9 == (0 - 0)) then
													v810['state']['staleq'][v813] = 1 - 0;
													v810['frame']:Show();
													FlatIdent_86BD9 = 2 - 1;
												end
												if (FlatIdent_86BD9 == (2 - 1)) then
													v810['events']:Fire(v410);
													break;
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
		if (v818 == (83005 + 117744)) then
			v815:Query(v816);
		end
	end;
	v405.QueuedInspections = function(v819)
		local FlatIdent_7B72F = 0 + 0;
		local v820;
		while true do
			if (FlatIdent_7B72F == (1947 - (831 + 1115))) then
				return v820;
			end
			if (FlatIdent_7B72F == (717 - (233 + 484))) then
				v820 = {};
				for v933 in pairs(v819['state'].mainq) do
					table.insert(v820, v933);
				end
				FlatIdent_7B72F = 1057 - (297 + 759);
			end
		end
	end;
	v405.StaleInspections = function(v821)
		local FlatIdent_518E2 = 0 + 0;
		local v822;
		while true do
			if (FlatIdent_518E2 == (1392 - (497 + 895))) then
				v822 = {};
				for v934 in pairs(v821['state'].staleq) do
					table.insert(v822, v934);
				end
				FlatIdent_518E2 = 1 + 0;
			end
			if ((1 - 0) == FlatIdent_518E2) then
				return v822;
			end
		end
	end;
	v405.IsInspectQueued = function(v823, v824)
		return v824 and (v823['state']['mainq'][v824] or v823['state']['staleq'][v824]) and true;
	end;
	v405.GetCachedInfo = function(v825, v826)
		local FlatIdent_427E5 = 0 + 0;
		local v827;
		while true do
			if (FlatIdent_427E5 == (1034 - (393 + 641))) then
				v827 = v825['cache'];
				return v826 and v827[v826];
			end
		end
	end;
	v405.Rescan = function(v828, v829)
		local FlatIdent_70533 = 0 - 0;
		local v830;
		local v831;
		while true do
			if (FlatIdent_70533 == (351 - (20 + 330))) then
				v828['frame']:Show();
				v828:GROUP_ROSTER_UPDATE();
				FlatIdent_70533 = 810 - (472 + 336);
			end
			if (FlatIdent_70533 == (5 - 3)) then
				v828['events']:Fire(v410);
				break;
			end
			if ((0 + 0) == FlatIdent_70533) then
				v830, v831 = v828['state']['mainq'], v828['state']['staleq'];
				if v829 then
					local FlatIdent_86D20 = 0 + 0;
					local v1060;
					while true do
						if (FlatIdent_86D20 == (0 + 0)) then
							v1060 = v828:GuidToUnit(v829);
							if v1060 then
								if v449(v1060, "player") then
									v828['events']:Fire(v407, v829, "player", v828:BuildInfo("player"));
								elseif not v830[v829] then
									v831[v829] = 1 + 0;
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
								local FlatIdent_1DE56 = 0 + 0;
								local v1197;
								while true do
									if (FlatIdent_1DE56 == (1348 - (1006 + 342))) then
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
				FlatIdent_70533 = 1 + 0;
			end
		end
	end;
	local v503 = {raid={"player"},party={"player"},player={"player"}};
	for v832 = 594 - (459 + 134), 40 + 0 do
		table.insert(v503.raid, "raid" .. v832);
	end
	for v833 = 2 - 1, 1303 - (1061 + 238) do
		table.insert(v503.party, "party" .. v833);
	end
	v405.GroupUnits = function(v834)
		local FlatIdent_57B41 = 0 - 0;
		local v835;
		while true do
			if (FlatIdent_57B41 == (714 - (349 + 364))) then
				return v835;
			end
			if (FlatIdent_57B41 == (0 + 0)) then
				v835 = nil;
				if v441() then
					v835 = v503['raid'];
				elseif (v428() > (0 - 0)) then
					v835 = v503['party'];
				else
					v835 = v503['player'];
				end
				FlatIdent_57B41 = 1 + 0;
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
	local FlatIdent_6AD84 = 0 - 0;
	local v202;
	local v203;
	while true do
		if (FlatIdent_6AD84 == (619 - (244 + 374))) then
			for v506 = 1 + 0, v200 do
				local FlatIdent_2138C = 0 - 0;
				local v507;
				while true do
					if (FlatIdent_2138C == (0 + 0)) then
						v507 = v48(#v203);
						v202 = v202 .. v47(v203, v507, v507);
						break;
					end
				end
			end
			return v202;
		end
		if (FlatIdent_6AD84 == (0 + 0)) then
			v202 = "";
			v203 = (v201 and v46) or v45;
			FlatIdent_6AD84 = 1 + 0;
		end
	end
end;
v1.randomVariable = function(v204)
	local FlatIdent_862FD = 1633 - (1243 + 390);
	local v205;
	local v206;
	while true do
		if ((664 - (368 + 294)) == FlatIdent_862FD) then
			return v205;
		end
		if (FlatIdent_862FD == (1 + 0)) then
			v205 = v205 .. v47(v46, v206, v206);
			for v508 = 758 - (374 + 383), v204 - (1 + 0) do
				local FlatIdent_5B04E = 0 + 0;
				while true do
					if (FlatIdent_5B04E == (49 - (19 + 30))) then
						v206 = v48(#v45);
						v205 = v205 .. v47(v45, v206, v206);
						break;
					end
				end
			end
			FlatIdent_862FD = 1 + 1;
		end
		if (FlatIdent_862FD == (0 + 0)) then
			v205 = "";
			v206 = v48(#v46);
			FlatIdent_862FD = 688 - (365 + 322);
		end
	end
end;
local v51 = {"MoveForwardStart","MoveBackwardStart","StrafeLeftStart","StrafeRightStart","StrafeLeftStop","StrafeRightStop","JumpOrAscendStart"};
if not v1['protected'] then
	v1['protected'] = {};
	v1['protected']['Objects'] = Objects;
	local function v511()
		local FlatIdent_40A2A = 0 + 0;
		while true do
			if (FlatIdent_40A2A == (3 + 1)) then
				v1['protected']['MoveBackwardStart'] = MoveBackwardStart;
				v1['protected']['JumpOrAscendStart'] = JumpOrAscendStart;
				v1['protected']['MoveTo'] = MoveTo;
				FlatIdent_40A2A = 7 - 2;
			end
			if (FlatIdent_40A2A == (1381 - (708 + 670))) then
				v1['protected']['StrafeLeftStart'] = StrafeLeftStart;
				v1['protected']['StrafeRightStop'] = StrafeRightStop;
				v1['protected']['StrafeLeftStop'] = StrafeLeftStop;
				FlatIdent_40A2A = 2 + 2;
			end
			if (FlatIdent_40A2A == (0 - 0)) then
				v1['protected']['CameraOrSelectOrMoveStart'] = CameraOrSelectOrMoveStart;
				v1['protected']['TurnOrActionStart'] = TurnOrActionStart;
				v1['protected']['TurnOrActionStop'] = TurnOrActionStop;
				FlatIdent_40A2A = 2 - 1;
			end
			if (FlatIdent_40A2A == (14 - 9)) then
				v1['protected'].PetAttack = function(v935)
					local FlatIdent_10D35 = 235 - (152 + 83);
					while true do
						if ((1980 - (465 + 1515)) == FlatIdent_10D35) then
							v935 = v935 or "";
							v2:CallProtectedFunction("(function() PetAttack(" .. v935 .. ") end)");
							break;
						end
					end
				end;
				v1['protected'].RunMacroText = function(v936)
					local FlatIdent_15F45 = 592 - (145 + 447);
					while true do
						if (FlatIdent_15F45 == (0 - 0)) then
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
					local FlatIdent_7C20A = 0 + 0;
					while true do
						if (FlatIdent_7C20A == (0 + 0)) then
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
				FlatIdent_40A2A = 1451 - (100 + 1345);
			end
			if (FlatIdent_40A2A == (12 - 6)) then
				v1['protected']['CancelShapeshiftForm'] = v1['protected']['CancelForm'];
				v1['protected'].ABP = function(v937, v938)
					v2:CallProtectedFunction("(function() AcceptBattlefieldPort(" .. tostring(v937) .. "," .. tostring(v938) .. ") end)");
				end;
				v1['protected'].JA = function(v939)
					local FlatIdent_213B3 = 0 + 0;
					while true do
						if (FlatIdent_213B3 == (1815 - (1592 + 223))) then
							if (v939 ~= "PISSY WISSY") then
								return;
							end
							v2:CallProtectedFunction("(function() JoinArena() end)");
							break;
						end
					end
				end;
				FlatIdent_40A2A = 2 + 5;
			end
			if ((3 + 4) == FlatIdent_40A2A) then
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
			if (FlatIdent_40A2A == (1 + 1)) then
				v1['protected']['TurnLeftStop'] = TurnLeftStop;
				v1['protected']['TurnRightStop'] = TurnRightStop;
				v1['protected']['StrafeRightStart'] = StrafeRightStart;
				FlatIdent_40A2A = 474 - (447 + 24);
			end
			if (FlatIdent_40A2A == (914 - (320 + 593))) then
				v1['protected']['MoveForwardStart'] = MoveForwardStart;
				v1['protected']['TurnLeftStart'] = TurnLeftStart;
				v1['protected']['TurnRightStart'] = TurnRightStart;
				FlatIdent_40A2A = 906 - (181 + 723);
			end
		end
	end
	v2:CallProtectedFunction("(function() _G.PCALLSX = {} end)");
	local v512 = function(v859)
		local FlatIdent_28A8A = 1921 - (1278 + 643);
		local v860;
		while true do
			if (FlatIdent_28A8A == (0 + 0)) then
				v860 = "(function() _G.PCALLSX." .. v859 .. " = _G." .. v859 .. " end)";
				v2:CallProtectedFunction(v860);
				break;
			end
		end
	end;
	for v861 = 1 - 0, #v51 do
		v512(v51[v861]);
	end
	v511();
end
local v52 = function(v207)
	local FlatIdent_7E4AF = 0 - 0;
	while true do
		if (FlatIdent_7E4AF == (1414 - (657 + 757))) then
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
		local FlatIdent_40CA7 = 521 - (218 + 303);
		local v862;
		while true do
			if (FlatIdent_40CA7 == (0 - 0)) then
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
		local FlatIdent_9488C = 0 - 0;
		while true do
			if (FlatIdent_9488C == (0 + 0)) then
				if not FaceDirection then
					return;
				end
				v14 = v14 or v1['player'];
				FlatIdent_9488C = 1441 - (911 + 529);
			end
			if (FlatIdent_9488C == (1 - 0)) then
				if not (not HasFullControl() or v14['cc'] or v14.buff(78247 - 32809) or v14['dead'] or v14.buff(320460 - (67 + 169))) then
					FaceDirection(v863, v864);
				end
				break;
			end
		end
	end;
elseif v0['Util']['Draw'] then
	v1.FaceDirection = function(v1062, v1063)
		local FlatIdent_8FFBD = 0 - 0;
		while true do
			if (FlatIdent_8FFBD == (497 - (428 + 69))) then
				v14 = v14 or v1['player'];
				if not (not HasFullControl() or v14['cc'] or v14.buff(41301 + 4137) or v14['dead'] or v14.buff(832176 - 511952)) then
					if (v1063 == "gay") then
						SetHeading(v1062);
					else
						local FlatIdent_54080 = 0 + 0;
						while true do
							if ((0 - 0) == FlatIdent_54080) then
								FaceDirection(v1062, false);
								FaceDirection(v1062, true);
								FlatIdent_54080 = 2 - 1;
							end
							if (FlatIdent_54080 == (1501 - (1042 + 458))) then
								if not v1['saved']['securityStuff'] then
									SendMovementHeartbeat();
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
elseif (v0['type'] == "noname") then
	v1.FaceDirection = function(v1143, v1144)
		local FlatIdent_6016A = 1207 - (419 + 788);
		while true do
			if (FlatIdent_6016A == (1 + 0)) then
				if not (not HasFullControl() or v14['cc'] or v14.buff(7451 + 37987) or v14['dead'] or v14.buff(192381 + 127843)) then
					SetPlayerFacing(v1143);
				end
				break;
			end
			if (FlatIdent_6016A == (0 + 0)) then
				if not SetPlayerFacing then
					return;
				end
				v14 = v14 or v1['player'];
				FlatIdent_6016A = 2 - 1;
			end
		end
	end;
end
local v54 = GetCVar("deselectOnClick");
v1.controlFacing = function(v209)
	local FlatIdent_3F068 = 0 - 0;
	local v210;
	while true do
		if (FlatIdent_3F068 == (0 - 0)) then
			SetCVar("deselectOnClick", "0");
			v210 = Object("target");
			FlatIdent_3F068 = 2 - 1;
		end
		if (FlatIdent_3F068 == (341 - (325 + 15))) then
			if not v209 then
				local FlatIdent_72635 = 0 + 0;
				local v865;
				local v866;
				while true do
					if (FlatIdent_72635 == (1 + 0)) then
						if (v865 or v866) then
							local FlatIdent_3DE11 = 0 - 0;
							while true do
								if (FlatIdent_3DE11 == (0 + 0)) then
									TurnOrActionStop();
									if not v866 then
										CameraOrSelectOrMoveStop();
									end
									FlatIdent_3DE11 = 1 + 0;
								end
								if (FlatIdent_3DE11 == (389 - (267 + 120))) then
									function TurnRightStart()
									end
									function TurnLeftStart()
									end
									break;
								end
								if (FlatIdent_3DE11 == (3 - 2)) then
									CameraOrSelectOrMoveStart();
									TurnOrActionStart = CameraOrSelectOrMoveStart;
									FlatIdent_3DE11 = 786 - (533 + 251);
								end
							end
						else
							local FlatIdent_8B2AB = 0 + 0;
							while true do
								if (FlatIdent_8B2AB == (1 + 0)) then
									TurnOrActionStart = CameraOrSelectOrMoveStart;
									function TurnRightStart()
									end
									FlatIdent_8B2AB = 2 + 0;
								end
								if (FlatIdent_8B2AB == (1216 - (798 + 418))) then
									TurnOrActionStop();
									CameraOrSelectOrMoveStop();
									FlatIdent_8B2AB = 1 + 0;
								end
								if ((1 + 1) == FlatIdent_8B2AB) then
									function TurnLeftStart()
									end
									break;
								end
							end
						end
						v1['releaseFacingTime'] = v1['time'] + (v1['tickRate'] * (10 - 5));
						break;
					end
					if ((0 + 0) == FlatIdent_72635) then
						v865 = IsMouseButtonDown("RightButton");
						v866 = IsMouseButtonDown("LeftButton");
						FlatIdent_72635 = 941 - (689 + 251);
					end
				end
			end
			if v210 then
				TargetUnit(v210);
			end
			break;
		end
	end
end;
v1.releaseFacing = function()
	local FlatIdent_1413C = 0 + 0;
	local v211;
	local v218;
	local v219;
	while true do
		if (FlatIdent_1413C == (6 - 4)) then
			TurnLeftStop = v1['protected']['TurnLeftStop'];
			v218 = IsMouseButtonDown("RightButton");
			v219 = IsMouseButtonDown("LeftButton");
			FlatIdent_1413C = 1344 - (290 + 1051);
		end
		if (FlatIdent_1413C == (3 - 2)) then
			TurnOrActionStop = v1['protected']['TurnOrActionStop'];
			TurnRightStart = v1['protected']['TurnRightStart'];
			TurnLeftStart = v1['protected']['TurnLeftStart'];
			FlatIdent_1413C = 1 + 1;
		end
		if (FlatIdent_1413C == (0 + 0)) then
			v211 = Object("target");
			CameraSelectOrMoveStart = v1['protected']['CameraSelectOrMoveStart'];
			TurnOrActionStart = v1['protected']['TurnOrActionStart'];
			FlatIdent_1413C = 1 + 0;
		end
		if (FlatIdent_1413C == (12 - 8)) then
			if v211 then
				TargetUnit(v211);
			end
			break;
		end
		if ((6 - 3) == FlatIdent_1413C) then
			if v219 then
				CameraOrSelectOrMoveStart();
			else
				CameraOrSelectOrMoveStop();
			end
			if v218 then
				TurnOrActionStart();
			end
			SetCVar("deselectOnClick", v54);
			FlatIdent_1413C = 12 - 8;
		end
	end
end;
if not v1['immerseOL'] then
	v1.immerseOL = function()
	end;
end
v1.StopMoving = function()
	local FlatIdent_6161 = 430 - (261 + 169);
	while true do
		if ((2 + 0) == FlatIdent_6161) then
			StrafeRightStop();
			TurnLeftStop();
			FlatIdent_6161 = 11 - 8;
		end
		if (FlatIdent_6161 == (1 + 2)) then
			TurnRightStop();
			AscendStop();
			FlatIdent_6161 = 3 + 1;
		end
		if (FlatIdent_6161 == (0 - 0)) then
			StopAutoRun();
			MoveForwardStop();
			FlatIdent_6161 = 1 - 0;
		end
		if (FlatIdent_6161 == (1250 - (156 + 1090))) then
			CameraOrSelectOrMoveStop();
			break;
		end
		if (FlatIdent_6161 == (1 + 0)) then
			MoveBackwardStop();
			StrafeLeftStop();
			FlatIdent_6161 = 2 - 0;
		end
	end
end;
if (v0['type'] == "daemonic") then
	local FlatIdent_788C3 = 0 + 0;
	while true do
		if (FlatIdent_788C3 == (0 - 0)) then
			v1.controlMovement = function(v868, v869)
				local FlatIdent_33397 = 0 + 0;
				while true do
					if (FlatIdent_33397 == (1725 - (54 + 1670))) then
						if v869 then
							v1.controlFacing(v868);
						end
						if not v1['movementLocked'] then
							local FlatIdent_71BB1 = 833 - (418 + 415);
							while true do
								if (FlatIdent_71BB1 == (0 + 0)) then
									for v1103 = 1738 - (342 + 1395), #v51 do
										v52(v51[v1103]);
									end
									v1['movementLocked'] = true;
									break;
								end
							end
						end
						FlatIdent_33397 = 1738 - (1349 + 387);
					end
					if (FlatIdent_33397 == (3 - 1)) then
						v1['releaseMovementTime'] = v1['time'] + (v1['tickRate'] * (4 + 2)) + v868;
						break;
					end
					if (FlatIdent_33397 == (0 - 0)) then
						v868 = v868 or (1253 - (977 + 276));
						v1.StopMoving();
						FlatIdent_33397 = 1062 - (66 + 995);
					end
				end
			end;
			v1.releaseMovement = function()
				local FlatIdent_4407 = 0 + 0;
				while true do
					if (FlatIdent_4407 == (0 + 0)) then
						for v944 = 1 + 0, #v51 do
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
	local FlatIdent_2E949 = 0 - 0;
	while true do
		if (FlatIdent_2E949 == (0 + 0)) then
			v1.controlMovement = function(v1065, v1066)
				local FlatIdent_3907E = 121 - (57 + 64);
				while true do
					if (FlatIdent_3907E == (487 - (385 + 102))) then
						v1065 = v1065 or (1044 - (942 + 102));
						v1.StopMoving();
						FlatIdent_3907E = 329 - (287 + 41);
					end
					if (FlatIdent_3907E == (590 - (37 + 551))) then
						v1['releaseMovementTime'] = v1['time'] + (v1['tickRate'] * (567 - (443 + 118))) + v1065;
						break;
					end
					if (FlatIdent_3907E == (1 - 0)) then
						if v1066 then
							v1.controlFacing(v1065);
						end
						if not v1['movementLocked'] then
							local FlatIdent_12810 = 1858 - (926 + 932);
							while true do
								if (FlatIdent_12810 == (309 - (270 + 39))) then
									for v1168 = 1 + 0, #v51 do
										v52(v51[v1168]);
									end
									v1['movementLocked'] = true;
									break;
								end
							end
						end
						FlatIdent_3907E = 2 + 0;
					end
				end
			end;
			v1.releaseMovement = function()
				local FlatIdent_8B07F = 0 - 0;
				while true do
					if (FlatIdent_8B07F == (0 + 0)) then
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
	local FlatIdent_63DC = 0 - 0;
	while true do
		if (FlatIdent_63DC == (1265 - (386 + 879))) then
			v1.controlMovement = function(v1069, v1070)
				local FlatIdent_5912C = 0 + 0;
				while true do
					if (FlatIdent_5912C == (0 - 0)) then
						v1069 = v1069 or (0 - 0);
						v1.StopMoving();
						FlatIdent_5912C = 1 + 0;
					end
					if (FlatIdent_5912C == (2 - 0)) then
						v1['releaseMovementTime'] = v1['time'] + (v1['tickRate'] * (916 - (630 + 280))) + v1069;
						break;
					end
					if (FlatIdent_5912C == (2 - 1)) then
						if v1070 then
							v1.controlFacing();
						end
						if not v1['movementLocked'] then
							local FlatIdent_9678 = 0 + 0;
							while true do
								if (FlatIdent_9678 == (0 + 0)) then
									for v1169 = 4 - 3, #v51 do
										v52(v51[v1169]);
									end
									v1['movementLocked'] = true;
									break;
								end
							end
						end
						FlatIdent_5912C = 8 - 6;
					end
				end
			end;
			v1.releaseMovement = function()
				local FlatIdent_5280C = 0 - 0;
				while true do
					if ((205 - (23 + 182)) == FlatIdent_5280C) then
						for v1106 = 2 - 1, #v51 do
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
	local FlatIdent_393A5 = 0 + 0;
	local v223;
	local v224;
	local v225;
	while true do
		if (FlatIdent_393A5 == (0 + 0)) then
			v223 = v5(v220);
			v224 = v5(v221);
			FlatIdent_393A5 = 2 - 1;
		end
		if (FlatIdent_393A5 == (1 + 1)) then
			v225 = getmetatable(v220);
			if (not v222 and v225 and v225['__eq']) then
				return v220 == v221;
			end
			FlatIdent_393A5 = 2 + 1;
		end
		if (FlatIdent_393A5 == (6 - 2)) then
			return true;
		end
		if (FlatIdent_393A5 == (1 + 0)) then
			if (v223 ~= v224) then
				return false;
			end
			if ((v223 ~= "table") and (v224 ~= "table")) then
				return v220 == v221;
			end
			FlatIdent_393A5 = 9 - 7;
		end
		if (FlatIdent_393A5 == (4 - 1)) then
			for v518, v519 in pairs(v220) do
				local FlatIdent_8DFA3 = 0 + 0;
				local v520;
				while true do
					if (FlatIdent_8DFA3 == (0 - 0)) then
						v520 = v221[v518];
						if ((v520 == nil) or not v58(v519, v520)) then
							return false;
						end
						break;
					end
				end
			end
			for v521, v522 in pairs(v221) do
				local FlatIdent_9807D = 0 + 0;
				local v523;
				while true do
					if ((0 - 0) == FlatIdent_9807D) then
						v523 = v220[v521];
						if ((v523 == nil) or not v58(v523, v522)) then
							return false;
						end
						break;
					end
				end
			end
			FlatIdent_393A5 = 1726 - (705 + 1017);
		end
	end
end
v1['deepCompare'] = v58;
v1['latency'] = select(816 - (10 + 802), GetNetStats()) / (970 + 30);
v1['tickRate'] = (890 - (353 + 536)) / GetFramerate();
v1['buffer'] = v1['latency'] + v1['tickRate'];
v1['time'] = GetTime();
v1['losFlags'] = 475 - 203;
v1['collisionFlags'] = 7 + 266;
v1['timeCache'] = {};
v1['PathTypes'] = {PATHFIND_BLANK=(0 + 0),PATHFIND_NORMAL=(787 - (476 + 310)),PATHFIND_SHORTCUT=(1 + 1),PATHFIND_INCOMPLETE=(7 - 3),PATHFIND_NOPATH=(688 - (317 + 363)),PATHFIND_NOT_USING_PATH=(54 - (29 + 9)),PATHFIND_SHORT=(84 - 52)};
table.pack = function(...)
	return {n=select("#", ...),...};
end;
function show(...)
	local FlatIdent_441F9 = 0 - 0;
	local v226;
	local v227;
	while true do
		if (FlatIdent_441F9 == (1675 - (224 + 1451))) then
			v226 = "";
			v227 = table.pack(...);
			FlatIdent_441F9 = 343 - (20 + 322);
		end
		if (FlatIdent_441F9 == (3 - 2)) then
			return v227['n'];
		end
	end
end
local v69 = function(v228)
	return (v228 and (1 + 0)) or (0 + 0);
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
		local FlatIdent_6978B = 762 - (10 + 752);
		while true do
			if (FlatIdent_6978B == (1844 - (1335 + 509))) then
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
	local FlatIdent_54FB5 = 0 - 0;
	while true do
		if ((0 - 0) == FlatIdent_54FB5) then
			table.insert(v1[v232], v231);
			if (#v1[v86] > (1426 - (537 + 889))) then
				for v950, v951 in ipairs(v1[v86]) do
					for v1073 = 2 - 1, 1791 - (1623 + 164) do
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
if (#v1[v86] > (132 - (88 + 44))) then
	for v873, v874 in ipairs(v1[v86]) do
		for v952 = 888 - (189 + 698), 503 - (273 + 226) do
			if (v874[v952] and not v1['classRoutines'][v952]) then
				v1['classRoutines'][v952] = v874[v952];
			end
		end
	end
end
local v91 = {};
local v92 = string.random(34 - 24);
_G["SLASH_" .. v92 .. "1"] = "/" .. v1['__username'];
local v93 = #v1['__username'];
for v233 = 4 - 1, v93 - (1785 - (757 + 1027)) do
	_G["SLASH_" .. v92 .. (v233 - (104 - (4 + 99)))] = "/" .. v1['__username']:sub(1 + 0, v233);
end
if v1['saved']['commands'] then
	for v875, v876 in ipairs(v1['saved'].commands) do
		_G["SLASH_" .. v92 .. ((866 - (536 + 326)) + v875)] = "/" .. v876;
	end
end
_G['SlashCmdList'][v92] = function(v234)
	local FlatIdent_4FAB5 = 508 - (35 + 473);
	while true do
		if ((974 - (101 + 873)) == FlatIdent_4FAB5) then
			if v234:match("command") then
				local FlatIdent_35B7F = 0 - 0;
				local v877;
				while true do
					if (FlatIdent_35B7F == (1 + 0)) then
						v1.print("Wait ~10sec, then /reload for it to apply.");
						v1['saved']['commands'] = v1['saved']['commands'] or {};
						FlatIdent_35B7F = 1 + 1;
					end
					if (FlatIdent_35B7F == (2 + 0)) then
						v4(v1['saved'].commands, v877);
						break;
					end
					if (FlatIdent_35B7F == (0 + 0)) then
						v877 = v234:match("command (.*)");
						v1.print("New Command Registered: " .. v877);
						FlatIdent_35B7F = 3 - 2;
					end
				end
			elseif v234:match("toggle") then
				local FlatIdent_2CC36 = 863 - (185 + 678);
				local v1074;
				while true do
					if (FlatIdent_2CC36 == (0 + 0)) then
						v1074 = v234:match("toggle (.*)");
						if (v1074 == "alerts") then
							local FlatIdent_25342 = 117 - (21 + 96);
							while true do
								if (FlatIdent_25342 == (2 - 1)) then
									return;
								end
								if (FlatIdent_25342 == (594 - (367 + 227))) then
									v1['saved']['disableAlerts'] = not v1['saved']['disableAlerts'];
									v1.print("Alerts: " .. ((v1['saved']['disableAlerts'] and "OFF") or "ON"));
									FlatIdent_25342 = 1 + 0;
								end
							end
						elseif (v1074 == "castalerts") then
							local FlatIdent_298D9 = 0 - 0;
							while true do
								if ((941 - (151 + 789)) == FlatIdent_298D9) then
									return;
								end
								if (FlatIdent_298D9 == (0 - 0)) then
									v1['saved']['disableCastAlerts'] = not v1['saved']['disableCastAlerts'];
									v1.print("Cast Alerts: " .. ((v1['saved']['disableCastAlerts'] and "OFF") or "ON"));
									FlatIdent_298D9 = 2 - 1;
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
	local FlatIdent_EB67 = 0 + 0;
	local v238;
	local v239;
	local v241;
	while true do
		if (FlatIdent_EB67 == (1272 - (1110 + 159))) then
			_G['SlashCmdList'][v241] = function(v528)
				local FlatIdent_3C172 = 785 - (644 + 141);
				local v529;
				while true do
					if (FlatIdent_3C172 == (2 - 1)) then
						if (v236 and not v529) then
							for v1075, v1076 in ipairs(v91) do
								v1076(v528);
							end
						end
						break;
					end
					if (FlatIdent_3C172 == (0 - 0)) then
						v529 = nil;
						for v879, v880 in ipairs(v239.Callbacks) do
							if v880(v528) then
								v529 = true;
							end
						end
						FlatIdent_3C172 = 1 - 0;
					end
				end
			end;
			return v239;
		end
		if (FlatIdent_EB67 == (0 + 0)) then
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
			FlatIdent_EB67 = 1 + 0;
		end
		if (FlatIdent_EB67 == (2 - 0)) then
			v241 = ((v238 == "table") and v235[1 + 0]) or v235;
			if (v238 == "table") then
				for v953, v954 in ipairs(v235) do
					_G["SLASH_" .. v241 .. v953] = "/" .. v954;
				end
			else
				_G["SLASH_" .. v241 .. "1"] = "/" .. v235;
			end
			FlatIdent_EB67 = 1043 - (71 + 969);
		end
		if (FlatIdent_EB67 == (1 - 0)) then
			v239 = {Callbacks={}};
			v239.New = function(v526, v527)
				table.insert(v239.Callbacks, v527);
			end;
			FlatIdent_EB67 = 3 - 1;
		end
	end
end;
v1.AddSlashAwfulCallback = function(v242)
	table.insert(v91, v242);
end;
local v96 = v1['AddSlashAwfulCallback'];
v1.print("safety measures " .. ((v1['saved']['securityStuff'] and "enabled") or "disabled") .. ".");
v96(function(v243)
	local FlatIdent_530DC = 1855 - (927 + 928);
	while true do
		if (FlatIdent_530DC == (221 - (48 + 173))) then
			if (v243 ~= "yolo") then
				return;
			end
			v1['saved']['securityStuff'] = not v1['saved']['securityStuff'];
			FlatIdent_530DC = 1969 - (376 + 1592);
		end
		if (FlatIdent_530DC == (1 - 0)) then
			v1.print("experimental safety measures " .. ((v1['saved']['securityStuff'] and "enabled") or "disabled") .. ".");
			break;
		end
	end
end);
local v97 = {"t","toggle","enable","on","off","start","go"};
local v98, v99 = 0 - 0, false;
v96(function(v245)
	local FlatIdent_D2A5 = 888 - (759 + 129);
	while true do
		if (FlatIdent_D2A5 == (0 - 0)) then
			if (v245 and tContains(v97, v245)) then
				local FlatIdent_20919 = 0 + 0;
				while true do
					if ((1 + 0) == FlatIdent_20919) then
						v1['noSpecPrint'] = nil;
						break;
					end
					if ((0 + 0) == FlatIdent_20919) then
						v1['enabled'] = not v1['enabled'];
						v1.print((v1['enabled'] and (v1['colors']['orange'] .. "enabled")) or (v1['colors']['red'] .. "disabled"));
						FlatIdent_20919 = 1120 - (350 + 769);
					end
				end
			end
			if (v245 == "damage hack") then
				local FlatIdent_2EEF = 0 - 0;
				local v883;
				while true do
					if ((1 + 0) == FlatIdent_2EEF) then
						v98 = v98 + (53 - 38);
						if (not v99 and ((v98 > (2002 - (261 + 1696))) or (math.random(1 + 0, 307 - (55 + 242)) == (3 + 0)))) then
							local FlatIdent_6B2FD = 0 - 0;
							while true do
								if (FlatIdent_6B2FD == (0 - 0)) then
									v99 = true;
									C_Timer.After(1515 - (42 + 1466), function()
										local FlatIdent_56555 = 0 + 0;
										while true do
											if (FlatIdent_56555 == (0 + 0)) then
												PlaySound(637 + 2444);
												v883("Hey, " .. UnitName("player") .. ". Got a moment?");
												break;
											end
										end
									end);
									FlatIdent_6B2FD = 1 + 0;
								end
								if (FlatIdent_6B2FD == (1411 - (66 + 1344))) then
									C_Timer.After(41 - 27, function()
										local FlatIdent_2F168 = 0 + 0;
										while true do
											if (FlatIdent_2F168 == (1749 - (393 + 1356))) then
												PlaySound(4196 - (543 + 572));
												v883("We just detected unauthorized third party software usage. An account closure will be issued momentarily. Please find a safe place to exit the game or we'll be forced to remove you ourselves.");
												break;
											end
										end
									end);
									v1.print("Damage Hack: Your damage is increased by " .. v1['colors']['orange'] .. v98 .. "%|r - Run again to increase it further.");
									break;
								end
							end
						else
							v1.print("Damage Hack: Your damage is increased by " .. v1['colors']['orange'] .. v98 .. "%|r - Run again to increase it further.");
						end
						break;
					end
					if (FlatIdent_2EEF == (0 + 0)) then
						v883 = nil;
						function v883(v955)
							print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t [Superkuhk] whispers: " .. v955);
						end
						FlatIdent_2EEF = 2 - 1;
					end
				end
			end
			FlatIdent_D2A5 = 1 + 0;
		end
		if (FlatIdent_D2A5 == (1 + 0)) then
			if (SecureCmdOptionParse(v245) == "pause") then
				v1['pause'] = v1['time'];
			end
			break;
		end
	end
end);
v1['autoCC'] = true;
v96(function(v246)
	local FlatIdent_5C0DD = 0 + 0;
	while true do
		if (FlatIdent_5C0DD == (1357 - (37 + 1320))) then
			if (v246:lower() == "burst") then
				local FlatIdent_8AEA9 = 0 + 0;
				while true do
					if (FlatIdent_8AEA9 == (0 - 0)) then
						v1['burst'] = v1['time'] + (6 - 2);
						v1['burst_pressed'] = v1['time'];
						FlatIdent_8AEA9 = 1015 - (720 + 294);
					end
					if (FlatIdent_8AEA9 == (3 - 2)) then
						PlaySound(45177 - 26918);
						break;
					end
				end
			elseif (v246:lower() == "clearconfig") then
				local FlatIdent_89AC9 = 0 - 0;
				local v1077;
				while true do
					if (FlatIdent_89AC9 == (0 - 0)) then
						v1077 = v1['__cfg__records'];
						if v1077 then
							local FlatIdent_299C1 = 242 - (33 + 209);
							while true do
								if (FlatIdent_299C1 == (0 - 0)) then
									v1.print("Clearing config... Please wait ~10sec, then /reload.");
									for v1170, v1171 in pairs(v1077) do
										local FlatIdent_23C9B = 0 + 0;
										local v1172;
										while true do
											if (FlatIdent_23C9B == (244 - (177 + 67))) then
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
									FlatIdent_299C1 = 1 + 0;
								end
								if (FlatIdent_299C1 == (3 - 2)) then
									C_Timer.After(319 - (247 + 60), function()
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
				local FlatIdent_63D5D = 0 - 0;
				while true do
					if (FlatIdent_63D5D == (0 + 0)) then
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
	local FlatIdent_52AE9 = 0 + 0;
	while true do
		if (FlatIdent_52AE9 == (0 + 0)) then
			if tContains(v97, v249) then
				local FlatIdent_1DA21 = 0 + 0;
				while true do
					if (FlatIdent_1DA21 == (0 - 0)) then
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
								v1['MacrosQueued'][v249] = v1['time'] + (5616 - 3616);
							end
						else
							local FlatIdent_4C3C8 = 932 - (733 + 199);
							while true do
								if (FlatIdent_4C3C8 == (485 - (12 + 473))) then
									v250 = (tonumber(GetCVar("SpellQueueWindow")) / (2750 - (486 + 1264))) + (442.115 - (384 + 58));
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
	local FlatIdent_2B1EF = 0 + 0;
	while true do
		if (FlatIdent_2B1EF == (597 - (577 + 20))) then
			for v531 = 3 - 2, #v253 do
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
	local FlatIdent_2AE54 = 0 + 0;
	while true do
		if (FlatIdent_2AE54 == (1681 - (1145 + 535))) then
			return result;
		end
		if (FlatIdent_2AE54 == (0 + 0)) then
			result = {};
			for v534 in (v254 .. v255):gmatch("(.-)" .. v255) do
				table.insert(result, v534);
			end
			FlatIdent_2AE54 = 546 - (383 + 162);
		end
	end
end
v1['DrawCallbacks'] = {};
v1.Draw = function(v256)
	local FlatIdent_7598 = 0 + 0;
	local v257;
	while true do
		if ((961 - (324 + 636)) == FlatIdent_7598) then
			v257.Disable = function(v536)
				v536['enabled'] = false;
			end;
			v257.Enable = function(v538)
				v538['enabled'] = true;
			end;
			FlatIdent_7598 = 4 - 2;
		end
		if (FlatIdent_7598 == (1107 - (1014 + 91))) then
			v257.Toggle = function(v540)
				v540['enabled'] = not v540['active'];
			end;
			v4(v1.DrawCallbacks, v257);
			FlatIdent_7598 = 189 - (139 + 47);
		end
		if (FlatIdent_7598 == (1633 - (1103 + 527))) then
			return v257;
		end
		if (FlatIdent_7598 == (1945 - (610 + 1335))) then
			v257 = {callback=v256,enabled=true};
			v257 = setmetatable(v257, {__call=function(v535, ...)
				if v535['enabled'] then
					v535.callback(...);
				end
			end});
			FlatIdent_7598 = 2 - 1;
		end
	end
end;
local v110 = {"focus","target","healer","player","cursor","ourhealer","friendlyhealer","enemyhealer"};
local v111 = {[585 + 1554]={ignoreFacing=true,effect="magic",targeted=true},[19843 - (90 + 106)]={effect="magic",targeted=true,ignoreFacing=true},[3489 + 103350]={effect="physical"},[14819 - 8267]={effect="physical"},[308452 - 161090]={effect="physical",ranged=true},[515443 - 327736]={effect="physical"},[3880 - 2114]={effect="physical"},[97207 - (362 + 614)]={effect="physical"},[80021 - (293 + 1053)]={effect="magic",ignoreFacing=true},[239931 - 181937]={effect="magic",targeted=true},[117219 - (216 + 298)]={effect="physical"},[528193 - 344441]={effect="magic",targeted=true},[3742 + 43786]={effect="magic",targeted=true},[177567 - 96603]={effect="physical",targeted=true},[82605 - (1332 + 308)]={effect="physical",targeted=true}};
local v112 = {};
local v113 = {[114692 - (635 + 333)]={effect="magic",targeted=false,ignoreFacing=true,cc=true,diameter=(18 - 12),minDist=(1.7999999999999998 + 3),maxDist=(5.2 + 0),ignoreFriends=true,maxHit=(1597 - (385 + 213)),filter=function(v261, v262, v263)
	local FlatIdent_72E54 = 0 + 0;
	while true do
		if (FlatIdent_72E54 == (0 - 0)) then
			if (v261['idr'] < (3 - 2)) then
				return "avoid";
			end
			if ((v262 < (7.35 - 2)) and (v262 > (6.65 - 2)) and (v261['cc'] or v261['rooted'] or v261['casting'] or not v261['moving'])) then
				return true;
			end
			break;
		end
	end
end,presort=function()
	v112 = {};
end,sort=function(v264, v265)
	local FlatIdent_8E530 = 0 + 0;
	while true do
		if (FlatIdent_8E530 == (0 - 0)) then
			v112[v264['x']] = v112[v264['x']] or v48(1657 - (920 + 736), 167 - 47);
			v112[v265['x']] = v112[v265['x']] or v48(629 - (178 + 450), 203 - (25 + 58));
			FlatIdent_8E530 = 1106 - (425 + 680);
		end
		if (FlatIdent_8E530 == (957 - (697 + 259))) then
			return (v264['hit'] > v265['hit']) or ((v264['hit'] == v265['hit']) and ((v264['hit'] + v112[v264['x']]) > (v265['hit'] + v112[v265['x']])));
		end
	end
end},[354981 - (1010 + 889)]={damage="magic",effect="magic",targeted=false,diameter=(3 + 5),minDist=(21.5 - 16),maxDist=(10.5 - 4),maxHit=(1455 - (10 + 446)),ignoreFriends=true,filter=function(v268, v269, v270)
	local FlatIdent_212E8 = 0 - 0;
	while true do
		if (FlatIdent_212E8 == (0 + 0)) then
			if ((v269 < (41 - 31)) and (v269 > (1.75 + 1)) and v268['bcc']) then
				return false;
			end
			if ((v269 < (43 - 33)) and (v269 > (2 + 1)) and v268['healer'] and v268['cc'] and ((v268['idr'] == (1562 - (926 + 635))) or (v268['idrr'] < (1812 - (164 + 1645))))) then
				return "avoid";
			end
			FlatIdent_212E8 = 1 + 0;
		end
		if ((980 - (856 + 123)) == FlatIdent_212E8) then
			if ((v269 < (6.5 + 0)) and (v269 > (13.5 - 8))) then
				return true;
			end
			break;
		end
	end
end,presort=function()
	v112 = {};
end,sort=function(v271, v272)
	local FlatIdent_941D9 = 0 + 0;
	while true do
		if (FlatIdent_941D9 == (0 - 0)) then
			v112[v271['x']] = v112[v271['x']] or v48(1 - 0, 356 - 236);
			v112[v272['x']] = v112[v272['x']] or v48(1 + 0, 113 + 7);
			FlatIdent_941D9 = 1 + 0;
		end
		if (FlatIdent_941D9 == (1 + 0)) then
			return (v271['hit'] > v272['hit']) or ((v271['hit'] == v272['hit']) and ((v271['hit'] + v112[v271['x']]) > (v272['hit'] + v112[v272['x']])));
		end
	end
end}};
v1.import = function(...)
	local FlatIdent_479B4 = 0 - 0;
	local v275;
	local v276;
	local v277;
	while true do
		if (FlatIdent_479B4 == (1857 - (10 + 1847))) then
			v275 = getfenv(1 + 1);
			v276 = {...};
			FlatIdent_479B4 = 1 + 0;
		end
		if (FlatIdent_479B4 == (1490 - (809 + 680))) then
			if (v5(v276[3 - 2]) == "table") then
				v276 = v276[1 + 0];
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
			FlatIdent_479B4 = 1715 - (449 + 1264);
		end
		if ((1001 - (707 + 292)) == FlatIdent_479B4) then
			function v277(v544)
				local FlatIdent_67AA0 = 0 + 0;
				while true do
					if ((0 + 0) == FlatIdent_67AA0) then
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
	end
end;
local v115;
local v116;
local v117 = {(13853 - 8607),(16919 - 11137),(259596 - (1012 + 793)),(11852 - 5494),(9995 - (915 + 958)),(235 + 370),(75486 + 285320)};
local v118;
local v119;
v1.SafeTrinket = function(v278)
	local FlatIdent_8D369 = 0 + 0;
	while true do
		if (FlatIdent_8D369 == (1 + 4)) then
			UseItemByName(tostring(GetItemInfo(108475 - 43681) or "Bloodthirsty Gladiator's Medallion of Tenacity"));
			UseItemByName(tostring(GetItemInfo(19344 + 45445) or "Bloodthirsty Gladiator's Medallion of Cruelty"));
			UseItemByName(tostring(GetItemInfo(61453 - (367 + 285)) or "Vicious Gladiator's Medallion of Cruelty"));
			FlatIdent_8D369 = 3 + 3;
		end
		if (FlatIdent_8D369 == (1 + 5)) then
			UseItemByName(tostring(GetItemInfo(52734 + 8072) or "Vicious Gladiator's Medallion of Meditation"));
			UseItemByName(tostring(GetItemInfo(60935 - (19 + 109)) or "Vicious Gladiator's Medallion of Tenacity"));
			break;
		end
		if (FlatIdent_8D369 == (1823 - (1329 + 493))) then
			if v278 then
				v1.alert("Pressing Trinket!");
			end
			if ((v1['player']['race'] == "Human") and (v116['cd'] <= (0 - 0)) and v1['player']['stunned'] and v116:Cast()) then
				return;
			end
			if ((v1['player']['race'] == "Undead") and (v115['cd'] <= (0 - 0)) and v1['player'].debuffFrom(v117) and v115:Cast()) then
				return;
			end
			FlatIdent_8D369 = 501 - (274 + 225);
		end
		if (FlatIdent_8D369 == (3 - 1)) then
			UseItemByName(tostring(GetItemInfo(654537 - 436115) or "Forged Aspirant's Medallion"));
			UseItemByName(tostring(GetItemInfo(556706 - 337990) or "Forged Gladiator's Medallion"));
			UseItemByName(tostring(GetItemInfo(207073 + 9209) or "Draconic Gladiator's Medallion"));
			FlatIdent_8D369 = 5 - 2;
		end
		if (FlatIdent_8D369 == (7 - 4)) then
			UseItemByName(tostring(GetItemInfo(218129 - (1065 + 695)) or "Draconic Aspirant's Medallion"));
			UseItemByName(tostring(GetItemInfo(212356 - (512 + 238)) or "Draconic Combatant's Medallion"));
			UseItemByName(tostring(GetItemInfo(210791 - (922 + 523)) or "Verdant Gladiator's Medallion"));
			FlatIdent_8D369 = 3 + 1;
		end
		if ((1340 - (882 + 458)) == FlatIdent_8D369) then
			if (v1['hasControl'] and not v1['player']['cc'] and not v1['player']['disarm'] and not v1['player']['rooted']) then
				return v278 and v1.alert("Held Trinket, No CC");
			end
			v116 = v116 or v1.NewSpell(61287 - (420 + 1115), {ignoreCC=true});
			v115 = v115 or v1.NewSpell(8441 - (414 + 283), {ignoreCC=true});
			FlatIdent_8D369 = 1133 - (488 + 644);
		end
		if (FlatIdent_8D369 == (5 - 1)) then
			UseItemByName(tostring(GetItemInfo(90932 + 118832) or "Verdant Aspirant's Medallion"));
			UseItemByName(tostring(GetItemInfo(116763 + 91544) or "Verdant Combatant's Medallion"));
			UseItemByName(tostring(GetItemInfo(88290 - 23498) or "Bloodthirsty Gladiator's Medallion of Meditation"));
			FlatIdent_8D369 = 2 + 3;
		end
	end
end;
v96(function(v279)
	local FlatIdent_E6C3 = 0 - 0;
	while true do
		if (FlatIdent_E6C3 == (0 - 0)) then
			if (v279 ~= "trinket") then
				return;
			end
			v1.SafeTrinket(true);
			break;
		end
	end
end);
v1.manualCastHandler = function(v280, v281)
	local FlatIdent_339CF = 0 + 0;
	local v282;
	local v283;
	while true do
		if (FlatIdent_339CF == (1572 - (260 + 1312))) then
			v282, v283 = SecureCmdOptionParse(v280);
			if (v281 and not v1.IsSpellOnGCD(v282)) then
				return;
			end
			FlatIdent_339CF = 2 - 1;
		end
		if (FlatIdent_339CF == (1 + 0)) then
			if (tonumber(v282) and (tonumber(v282) < (9 + 14))) then
				local FlatIdent_7E70 = 0 + 0;
				local v893;
				local v894;
				while true do
					if (FlatIdent_7E70 == (0 + 0)) then
						v893 = tonumber(v282);
						v894 = GetInventoryItemID("player", v893);
						FlatIdent_7E70 = 190 - (179 + 10);
					end
					if (FlatIdent_7E70 == (1 + 0)) then
						if v894 then
							v1['ManualSpellQueues'][v894] = {time=v1['time'],expires=(v1['time'] + (GetCVar("SpellQueueWindow") / (433 + 567)) + 0.35 + 0),target=v283,item={id=v894,name=tostring(GetItemInfo(v894)),cd=function()
								return v1.GetItemCD(v894);
							end,slot=v893,texture=select(6 + 4, GetItemInfo(v894))}};
						end
						break;
					end
				end
			else
				local v895 = tonumber(v282) or select(970 - (191 + 772), v1['dep'].GetSpellInfo(v282));
				if v895 then
					local FlatIdent_3F112 = 608 - (315 + 293);
					local v1081;
					local v1082;
					local v1083;
					while true do
						if (FlatIdent_3F112 == (0 + 0)) then
							v1081 = v111[v895];
							if not v1081 then
								for v1176, v1177 in pairs(v111) do
									if (v1['dep'].GetSpellInfo(v1176) == v1['dep'].GetSpellInfo(v895)) then
										v1081 = v1177;
										break;
									end
								end
							end
							FlatIdent_3F112 = 1402 - (566 + 835);
						end
						if (FlatIdent_3F112 == (10 - 7)) then
							if not v1['ManualSpellObjects'][v895] then
								local FlatIdent_6D60E = 0 - 0;
								while true do
									if (FlatIdent_6D60E == (23 - (12 + 11))) then
										if (v895 == (2095 - (740 + 947))) then
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
							v1['ManualSpellQueues'][v895] = {time=v1['time'],expires=(((v1['time'] + (GetCVar("SpellQueueWindow") / (2843 - (1081 + 762))) + (0.6 - 0)) - (v69(v1081 or v1['saved']['helloxen']) * (455.5 - (409 + 46)))) - (v69((v895 == (31970 - (183 + 126))) and not v1['saved']['helloxen']) * (257.25 - (229 + 28)))),obj=v1083,target=v283,isKick=v1081,isAoE=v1082,stopCastToFinish=(v895 == (46713 - (189 + 1086)))};
							break;
						end
						if (FlatIdent_3F112 == (3 - 2)) then
							if ((v895 == (12289 - (97 + 826))) and not v1['player'].buff(49876 - (519 + 1249)) and not v1['player'].buff(55130 + 214521)) then
								return;
							end
							if ((v895 == (3355 - (426 + 284))) and v1['player'].buff(v895)) then
								local FlatIdent_23847 = 1192 - (1091 + 101);
								while true do
									if ((0 + 0) == FlatIdent_23847) then
										v1['protected'].RunMacroText("/cancelaura " .. v1['dep'].GetSpellInfo(1998 + 647));
										return;
									end
								end
							end
							FlatIdent_3F112 = 1 + 1;
						end
						if (FlatIdent_3F112 == (7 - 5)) then
							v1082 = v113[v895];
							v1083 = nil;
							FlatIdent_3F112 = 1996 - (798 + 1195);
						end
					end
				end
			end
			break;
		end
	end
end;
v96(function(v284)
	local FlatIdent_12E18 = 0 - 0;
	while true do
		if (FlatIdent_12E18 == (10 - (4 + 6))) then
			if not v284:match("cast") then
				return;
			end
			v284 = v284:gsub("cast ", "");
			FlatIdent_12E18 = 1 + 0;
		end
		if (FlatIdent_12E18 == (1 + 0)) then
			v1.manualCastHandler(v284);
			break;
		end
	end
end);
v1.queueSpell = function(v285, v286, v287)
	local FlatIdent_28156 = 1978 - (1559 + 419);
	local v288;
	while true do
		if (FlatIdent_28156 == (1928 - (1539 + 389))) then
			v287 = v287 or (8 - 5);
			if ((v285 == (5848 - 3203)) and v1['player'].buff(v285)) then
				local FlatIdent_143D5 = 1261 - (257 + 1004);
				local v896;
				while true do
					if ((1 - 0) == FlatIdent_143D5) then
						return;
					end
					if (FlatIdent_143D5 == (0 - 0)) then
						v896 = v1['player']['buffs'];
						for v958 = 530 - (303 + 226), #v896 do
							local FlatIdent_904CC = 1180 - (591 + 589);
							local v959;
							while true do
								if (FlatIdent_904CC == (0 - 0)) then
									v959 = v896[v958];
									if (v959[3 + 7] == v285) then
										return CancelUnitBuff("player", v958);
									end
									break;
								end
							end
						end
						FlatIdent_143D5 = 1 + 0;
					end
				end
			end
			FlatIdent_28156 = 2 - 1;
		end
		if (FlatIdent_28156 == (1 + 0)) then
			v288 = nil;
			if not v1['ManualSpellObjects'][v285] then
				local FlatIdent_70823 = 0 - 0;
				while true do
					if (FlatIdent_70823 == (0 + 0)) then
						v288 = v1.NewSpell(v285, isAoE or isKick or {ignoreFacing=true,castableInCC=true});
						v1['ManualSpellObjects'][v285] = v288;
						break;
					end
				end
			else
				v288 = v1['ManualSpellObjects'][v285];
			end
			FlatIdent_28156 = 9 - 7;
		end
		if (FlatIdent_28156 == (2 + 0)) then
			v1['ManualSpellQueues'][v285] = {time=v1['time'],expires=(v1['time'] + v287),obj=v288,target=v286};
			break;
		end
	end
end;
local v123 = {(880 + 633),(15316 - 10070),(5041 + 741),(294725 - 176026),(15853 - 5527),(4146 + 3976),(5879 + 910)};
local v124;
v1.addUpdateCallback(function()
	local FlatIdent_1E6FC = 0 + 0;
	local v290;
	local v291;
	while true do
		if (FlatIdent_1E6FC == (2 - 0)) then
			for v547, v548 in pairs(v1.ManualSpellQueues) do
				local FlatIdent_3E7BE = 0 + 0;
				local v549;
				local v550;
				while true do
					if (FlatIdent_3E7BE == (1054 - (165 + 889))) then
						v549 = v548['time'];
						v550 = v1['player'].used(v547, v1['time'] - v549) or v1['player'].started(v547, v1['time'] - v549);
						FlatIdent_3E7BE = 3 - 2;
					end
					if (FlatIdent_3E7BE == (1 + 0)) then
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
									local FlatIdent_FA9D = 1722 - (1492 + 230);
									while true do
										if ((323 - (226 + 97)) == FlatIdent_FA9D) then
											if not v1246['visible'] then
												return false;
											end
											if v1246['healer'] then
												return false;
											end
											FlatIdent_FA9D = 4 - 3;
										end
										if (FlatIdent_FA9D == (475 - (51 + 423))) then
											v966 = v1246;
											return true;
										end
									end
								end);
							elseif (v548['target'] == "partylowest") then
								local FlatIdent_512CB = 0 + 0;
								local v1247;
								while true do
									if (FlatIdent_512CB == (3 - 2)) then
										v966 = v1['fgroup'].within(121 - 81).filter(v1247)['lowest'];
										break;
									end
									if (FlatIdent_512CB == (504 - (289 + 215))) then
										v1247 = nil;
										function v1247(v1250)
											return v1250['los'];
										end
										FlatIdent_512CB = 1752 - (520 + 1231);
									end
								end
							elseif (v548['target'] == "enemylowest") then
								v966 = v1['enemies']['lowest'];
							elseif (v548['target'] == "offdps") then
								v1['enemies'].loop(function(v1254)
									local FlatIdent_8EF55 = 0 + 0;
									while true do
										if (FlatIdent_8EF55 == (4 - 2)) then
											return true;
										end
										if (FlatIdent_8EF55 == (0 + 0)) then
											if v1254['healer'] then
												return false;
											end
											if v1254.isUnit(v1.target) then
												return false;
											end
											FlatIdent_8EF55 = 1 - 0;
										end
										if (FlatIdent_8EF55 == (1022 - (98 + 923))) then
											if v1254.isUnit(v1.focus) then
												return false;
											end
											v966 = v1254;
											FlatIdent_8EF55 = 549 - (65 + 482);
										end
									end
								end);
							elseif (v548['target'] and (v548['target'] ~= "cursor")) then
								local FlatIdent_495A8 = 0 - 0;
								local v1256;
								while true do
									if ((199 - (134 + 65)) == FlatIdent_495A8) then
										v966 = v1[v548['target']];
										v1256 = v548['target']:lower();
										FlatIdent_495A8 = 1 + 0;
									end
									if (FlatIdent_495A8 == (1468 - (1325 + 142))) then
										v1['fgroup'].loop(function(v1258)
											local FlatIdent_B08D = 0 + 0;
											local v1259;
											while true do
												if (FlatIdent_B08D == (952 - (766 + 186))) then
													if not v1258['visible'] then
														return false;
													end
													v1259 = v1258['name'] and v1258['name']:lower();
													FlatIdent_B08D = 1 + 0;
												end
												if (FlatIdent_B08D == (992 - (48 + 943))) then
													if (v1259 == v1256) then
														local FlatIdent_713EF = 0 + 0;
														while true do
															if (FlatIdent_713EF == (1063 - (302 + 761))) then
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
							if (v963 and ((v963['id'] == (260 - 142)) or (v963['id'] == (115681 - (899 + 1058)))) and ((v1['player']['castID'] == (2070 - (712 + 1225))) or (v1['player']['castID'] == (1340 + 1608)))) then
								if (v1['player']['castRemains'] > (0.5 + 0)) then
									if ((v963['cd'] <= v1['gcdRemains']) and v963:Castable(v966, {spam=true})) then
										SpellStopCasting();
									end
								end
							end
							if (v963 and (v963['id'] == (46207 - (275 + 494))) and v1['player'].buff(122348 - 76910)) then
								return;
							end
							if (v963 and (v963['id'] == (1692 - (905 + 379))) and (v963['cd'] <= (0.65 - 0))) then
								local FlatIdent_3D2C3 = 0 - 0;
								while true do
									if ((0 + 0) == FlatIdent_3D2C3) then
										v966 = v966 or v1['target'];
										if (v1['player']['cp'] < (9 - 5)) then
											local FlatIdent_957F0 = 0 - 0;
											while true do
												if (FlatIdent_957F0 == (223 - (41 + 182))) then
													v124 = v124 or v1.NewSpell(275282 - 137663, {ignoreFacing=true});
													v1['enemies'].loop(function(v1194)
														return v124:CastAlert(v1194);
													end);
													FlatIdent_957F0 = 1 + 0;
												end
												if (FlatIdent_957F0 == (1 + 0)) then
													if v1['target']['enemy'] then
														v124:Cast(v1.target);
													end
													if v1['focus']['enemy'] then
														v124:Cast(v1.focus);
													end
													FlatIdent_957F0 = 5 - 3;
												end
												if ((7 - 5) == FlatIdent_957F0) then
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
								local FlatIdent_43757 = 0 - 0;
								while true do
									if (FlatIdent_43757 == (0 - 0)) then
										SpellStopCasting();
										if (v963['id'] == (46744 - (866 + 440))) then
											local FlatIdent_8F1D8 = 0 - 0;
											while true do
												if (FlatIdent_8F1D8 == (0 + 0)) then
													if (v5(v1.actor) == "table") then
														v1['actor']['paused'] = GetTime() + v1['buffer'] + (517.15 - (485 + 32));
													end
													v963['cd'] = 1771 - (1403 + 368);
													FlatIdent_8F1D8 = 1 + 0;
												end
												if (FlatIdent_8F1D8 == (2 - 1)) then
													v963['cacheLiteral']['cd'] = true;
													break;
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
										local FlatIdent_8FD5B = 585 - (451 + 134);
										while true do
											if (FlatIdent_8FD5B == (0 + 0)) then
												v966 = v966 or v1['target'];
												if (v966['exists'] and ((not v966['casting'] and not v966['channeling']) or (v966['casting'] and (v966['castint'] ~= false)) or (v966['channeling'] and (v966['channelint'] ~= false)))) then
													local FlatIdent_74320 = 0 + 0;
													while true do
														if (FlatIdent_74320 == (1722 - (1061 + 661))) then
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
										local FlatIdent_75A37 = 0 - 0;
										while true do
											if (FlatIdent_75A37 == (1625 - (1246 + 379))) then
												v1.call("SpellCancelQueuedSpell");
												if v548['isAoE'] then
													local FlatIdent_6596C = 478 - (391 + 87);
													local v1218;
													local v1219;
													local v1220;
													local v1221;
													local v1222;
													while true do
														if (FlatIdent_6596C == (1 - 0)) then
															if (v1221 and v963:AoECast(v1219, v1220, v1221)) then
																local FlatIdent_2538 = 0 - 0;
																while true do
																	if (FlatIdent_2538 == (0 + 0)) then
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
														if (FlatIdent_6596C == (1669 - (1247 + 422))) then
															v1218 = (v963['id'] == (523134 - 409410)) and {movePredTime=((v966.debuffFrom(v123) and (v963['castTime'] + v1['buffer'])) or (0 + 0))};
															v1219, v1220, v1221, v1222 = v963:SmartAoEPosition(v966, v1218);
															FlatIdent_6596C = 358 - (116 + 241);
														end
													end
												elseif v963:Cast(v966, v548.options) then
													if SpellIsTargeting() then
														local FlatIdent_53EE6 = 0 - 0;
														local v1233;
														local v1234;
														local v1235;
														while true do
															if (FlatIdent_53EE6 == (226 - (157 + 68))) then
																if not v1['saved']['disableCastAlerts'] then
																	v1.alert(v963['name'] .. " [Manual AoE]", v963.id);
																end
																break;
															end
															if (FlatIdent_53EE6 == (0 + 0)) then
																v1233, v1234, v1235 = v966.position();
																Click(v1233, v1234, v1235);
																FlatIdent_53EE6 = 1 + 0;
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
										local FlatIdent_16EE2 = 685 - (226 + 459);
										while true do
											if (FlatIdent_16EE2 == (0 + 0)) then
												v1.call("SpellCancelQueuedSpell");
												if v963:Cast(nil, v548.options) then
													if SpellIsTargeting() then
														local FlatIdent_26EF9 = 0 + 0;
														local v1225;
														local v1226;
														local v1227;
														local v1228;
														local v1229;
														local v1230;
														while true do
															if (FlatIdent_26EF9 == (0 + 0)) then
																v1225, v1226, v1227 = v1.CursorPosition();
																v1228, v1229, v1230 = v1['player'].position();
																FlatIdent_26EF9 = 1 - 0;
															end
															if (FlatIdent_26EF9 == (3 - 2)) then
																if (v1225 and v1228) then
																	local FlatIdent_27C4E = 0 - 0;
																	local v1236;
																	local v1237;
																	local v1238;
																	local v1239;
																	while true do
																		if ((0 + 0) == FlatIdent_27C4E) then
																			v1236, v1237, v1238 = v1225, v1226, v1227;
																			v1239 = v963['range'] or (65 - 35);
																			FlatIdent_27C4E = 1 + 0;
																		end
																		if ((1 + 1) == FlatIdent_27C4E) then
																			if ((v1238 - v1230) > (54 - 36)) then
																				local FlatIdent_3A91F = 0 + 0;
																				while true do
																					if (FlatIdent_3A91F == (0 - 0)) then
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
																		if ((2 - 1) == FlatIdent_27C4E) then
																			v1239 = v1239 - math.abs(v1227 - v1230);
																			if (v1.Distance(v1225, v1226, v1227, v1228, v1229, v1230) > v1239) then
																				local FlatIdent_69728 = 419 - (167 + 252);
																				local v1243;
																				while true do
																					if (FlatIdent_69728 == (0 - 0)) then
																						v1243 = v1.AnglesBetween(v1228, v1229, v1230, v1225, v1226, v1227);
																						v1236, v1237, v1238 = v1228 + (v1239 * math.cos(v1243)), v1229 + (v1239 * math.sin(v1243)), v1227;
																						break;
																					end
																				end
																			end
																			FlatIdent_27C4E = 1347 - (812 + 533);
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
								local FlatIdent_98463 = 0 + 0;
								while true do
									if ((0 + 0) == FlatIdent_98463) then
										v1['protected'].RunMacroText("/use " .. v964['slot']);
										v1.alert({message=v964['name'],textureLiteral=v964['texture']});
										break;
									end
								end
							end
						end
						break;
					end
				end
			end
			break;
		end
		if (FlatIdent_1E6FC == (0 - 0)) then
			v290 = v1['time'];
			v291 = nil;
			FlatIdent_1E6FC = 1723 - (1440 + 282);
		end
		if (FlatIdent_1E6FC == (1856 - (463 + 1392))) then
			for v545, v546 in pairs(v1.ManualSpellQueues) do
				if (v545 == (110018 - 64580)) then
					v291 = true;
				end
			end
			if v291 then
				for v960, v961 in pairs(v1.ManualSpellQueues) do
					if (v960 ~= (47089 - (472 + 1179))) then
						v1['ManualSpellQueues'][v960] = nil;
					end
				end
			end
			FlatIdent_1E6FC = 147 - (79 + 66);
		end
	end
end);
v1.textureEscape = function(v292, v293, v294, v295)
	local FlatIdent_5D110 = 0 - 0;
	while true do
		if ((0 + 0) == FlatIdent_5D110) then
			v293 = v293 or (876 - (702 + 150));
			if (v5(v292) == "number") then
				v292 = (v295 and GetItemIcon(v292)) or v1['dep'].GetSpellIcon(v292) or v292;
			end
			FlatIdent_5D110 = 1 + 0;
		end
		if (FlatIdent_5D110 == (1 - 0)) then
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
if (math.random(1 + 0, 1000345 - (175 + 170)) == (203990 - 134570)) then
	local FlatIdent_5BD81 = 0 + 0;
	while true do
		if (FlatIdent_5BD81 == (705 - (590 + 115))) then
			v1.print(v127[math.random(4 - 3, #v127)]);
			C_Timer.After(29 + 40, function()
				print("\124cffff80ff\124Tinterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16\124t[Simpanzy] whispers: We have detected botting. An account closure will be issued in a moment. Please find a safe place to exit the game or we'll be forced to remove you ourselves.");
			end);
			break;
		end
	end
else
	local FlatIdent_6B9ED = 0 + 0;
	local v551;
	while true do
		if (FlatIdent_6B9ED == (1 + 0)) then
			v1.print(v1['colors']['orange'] .. v551);
			break;
		end
		if ((0 - 0) == FlatIdent_6B9ED) then
			v551 = v127[math.random(1 + 0, #v127)];
			if (v5(v551) == "function") then
				v551 = v551();
			end
			FlatIdent_6B9ED = 1 + 0;
		end
	end
end
ScrollingMessageFrameMixin.AddMessage = function(v299, v300, v301, v302, v303, ...)
	if v299['historyBuffer']:PushFront(v299:PackageEntry(v300, v301, v302, v303, ...)) then
		local FlatIdent_45FE7 = 334 - (87 + 247);
		while true do
			if (FlatIdent_45FE7 == (0 - 0)) then
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
	local FlatIdent_47153 = 1885 - (1634 + 251);
	local v306;
	local v307;
	local v308;
	while true do
		if (FlatIdent_47153 == (634 - (522 + 112))) then
			v306, v307, v308 = strsplit(".", v304);
			return v306, v307, v308;
		end
	end
end;
v1.createFont = function(v309, v310, v311)
	local FlatIdent_85F73 = 1450 - (1044 + 406);
	local v312;
	while true do
		if ((392 - (24 + 368)) == FlatIdent_85F73) then
			v312 = CreateFont(string.random(34 - 24));
			v312:SetFont("Fonts/OpenSans-Bold.ttf", v309 or (921 - (413 + 496)), v310 or "");
			FlatIdent_85F73 = 1 + 0;
		end
		if (FlatIdent_85F73 == (1 + 0)) then
			if (select(1214 - (1033 + 179), v312:GetFont()) == (1168 - (1109 + 59))) then
				local FlatIdent_2EFD9 = 0 + 0;
				while true do
					if (FlatIdent_2EFD9 == (0 - 0)) then
						v312:SetFont("Fonts/FRIZQT__.TTF", v309 or (6 + 6), v310 or "");
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
	local FlatIdent_128B4 = 0 - 0;
	local v315;
	local v316;
	while true do
		if ((1 + 1) == FlatIdent_128B4) then
			v315[v313] = v316;
			for v552, v553 in pairs(v313) do
				v316[v136(v552, v315)] = v136(v553, v315);
			end
			FlatIdent_128B4 = 600 - (9 + 588);
		end
		if ((0 + 0) == FlatIdent_128B4) then
			if (v5(v313) ~= "table") then
				return v313;
			end
			if (v314 and v314[v313]) then
				return v314[v313];
			end
			FlatIdent_128B4 = 1976 - (752 + 1223);
		end
		if (FlatIdent_128B4 == (1030 - (924 + 105))) then
			v315 = v314 or {};
			v316 = setmetatable({}, getmetatable(v313));
			FlatIdent_128B4 = 1 + 1;
		end
		if (FlatIdent_128B4 == (8 - 5)) then
			return v316;
		end
	end
end
local function v137(v318, v319, v320)
	local FlatIdent_9630C = 0 + 0;
	local v321;
	local v322;
	local v323;
	while true do
		if ((7 - 3) == FlatIdent_9630C) then
			for v559, v560 in pairs(v319) do
				if not v323[v559] then
					return false;
				end
			end
			return true;
		end
		if (FlatIdent_9630C == (7 - 4)) then
			v323 = {};
			for v555, v556 in pairs(v318) do
				local FlatIdent_8790A = 205 - (13 + 192);
				local v557;
				while true do
					if (FlatIdent_8790A == (317 - (112 + 205))) then
						v557 = v319[v555];
						if ((v557 == nil) or (v137(v556, v557, v320) == false)) then
							return false;
						end
						FlatIdent_8790A = 3 - 2;
					end
					if (FlatIdent_8790A == (1 + 0)) then
						v323[v555] = true;
						break;
					end
				end
			end
			FlatIdent_9630C = 1929 - (1906 + 19);
		end
		if (FlatIdent_9630C == (979 - (328 + 651))) then
			if (v318 == v319) then
				return true;
			end
			v321 = v5(v318);
			FlatIdent_9630C = 1339 - (788 + 550);
		end
		if (FlatIdent_9630C == (5 - 3)) then
			if (v321 ~= "table") then
				return false;
			end
			if not v320 then
				local FlatIdent_464A6 = 0 + 0;
				local v899;
				while true do
					if (FlatIdent_464A6 == (0 + 0)) then
						v899 = getmetatable(v318);
						if (v899 and v899['__eq']) then
							return v318 == v319;
						end
						break;
					end
				end
			end
			FlatIdent_9630C = 389 - (323 + 63);
		end
		if (FlatIdent_9630C == (1629 - (1192 + 436))) then
			v322 = v5(v319);
			if (v321 ~= v322) then
				return false;
			end
			FlatIdent_9630C = 110 - (34 + 74);
		end
	end
end
v1.Populate = function(v324, ...)
	local FlatIdent_53DF2 = 0 - 0;
	local v325;
	while true do
		if ((0 - 0) == FlatIdent_53DF2) then
			v325 = {...};
			for v561, v562 in ipairs(v325) do
				if (v5(v562) == "table") then
					for v1085, v1086 in pairs(v324) do
						local FlatIdent_3B3D7 = 0 + 0;
						while true do
							if (FlatIdent_3B3D7 == (0 - 0)) then
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
	local FlatIdent_780BF = 0 - 0;
	while true do
		if (FlatIdent_780BF == (1 + 0)) then
			for v563, v564 in pairs(v326) do
				v327[v563] = v564;
			end
			return true;
		end
		if (FlatIdent_780BF == (0 + 0)) then
			if v137(v326, v327) then
				return;
			end
			if ((v5(v327) ~= "table") or (v5(v326) ~= "table")) then
				return;
			end
			FlatIdent_780BF = 1 + 0;
		end
	end
end;
if (SetModifiedClick and SaveBindings and GetCurrentBindingSet) then
	local FlatIdent_8CCB5 = 0 + 0;
	local v566;
	while true do
		if (FlatIdent_8CCB5 == (1 + 0)) then
			SaveBindings(v566);
			break;
		end
		if (FlatIdent_8CCB5 == (1420 - (192 + 1228))) then
			v566 = GetCurrentBindingSet();
			SetModifiedClick("SELFCAST", "NONE");
			FlatIdent_8CCB5 = 1185 - (106 + 1078);
		end
	end
end
if not v1['dep'] then
	v1['dep'] = {};
end
if GetSpellInfo then
	local FlatIdent_62F2F = 0 - 0;
	while true do
		if (FlatIdent_62F2F == (0 - 0)) then
			v1['dep']['GetSpellInfo'] = GetSpellInfo;
			v1['dep']['GetSpellName'] = GetSpellInfo;
			break;
		end
	end
else
	local FlatIdent_1E3EA = 1175 - (469 + 706);
	while true do
		if (FlatIdent_1E3EA == (0 - 0)) then
			v1['dep'].GetSpellInfo = function(v900)
				local FlatIdent_12571 = 1051 - (989 + 62);
				local v901;
				while true do
					if (FlatIdent_12571 == (0 + 0)) then
						if not v900 then
							return nil;
						end
						v901 = C_Spell.GetSpellInfo(v900);
						FlatIdent_12571 = 1 + 0;
					end
					if ((1 + 0) == FlatIdent_12571) then
						if v901 then
							return v901['name'], nil, v901['iconID'], v901['castTime'], v901['minRange'], v901['maxRange'], v901['spellID'], v901['originalIconID'];
						end
						break;
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
		local FlatIdent_122CA = 0 + 0;
		local v903;
		while true do
			if (FlatIdent_122CA == (0 + 0)) then
				if not v902 then
					return nil;
				end
				v903 = C_Spell.GetSpellCharges(v902);
				FlatIdent_122CA = 1 + 0;
			end
			if (FlatIdent_122CA == (1 + 0)) then
				if v903 then
					return v903['currentCharges'], v903['maxCharges'], v903['cooldownStartTime'], v903['cooldownDuration'], v903['chargeModRate'];
				end
				break;
			end
		end
	end;
end
if GetSpellCooldown then
	v1['dep']['GetSpellCooldown'] = GetSpellCooldown;
else
	v1['dep'].GetSpellCooldown = function(v904)
		local FlatIdent_2CAA7 = 0 - 0;
		local v905;
		while true do
			if (FlatIdent_2CAA7 == (1 + 0)) then
				if v905 then
					return v905['startTime'], v905['duration'], v905['isEnabled'], v905['modRate'];
				end
				break;
			end
			if (FlatIdent_2CAA7 == (41 - (11 + 30))) then
				if not v904 then
					return nil;
				end
				v905 = C_Spell.GetSpellCooldown(v904);
				FlatIdent_2CAA7 = 2 - 1;
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
	local FlatIdent_1EB48 = 0 - 0;
	local v331;
	while true do
		if (FlatIdent_1EB48 == (0 - 0)) then
			v331 = C_UnitAuras.GetAuraDataByIndex(v328, v329, v330);
			if not v331 then
				return nil;
			end
			FlatIdent_1EB48 = 1 + 0;
		end
		if (FlatIdent_1EB48 == (1621 - (1414 + 206))) then
			return AuraUtil.UnpackAuraData(v331);
		end
	end
end;
v1['dep']['G_UnitBuff'] = _G['UnitBuff'] or function(v332, v333, v334)
	local FlatIdent_1B31C = 0 - 0;
	local v335;
	while true do
		if (FlatIdent_1B31C == (1139 - (1123 + 16))) then
			v335 = C_UnitAuras.GetBuffDataByIndex(v332, v333, v334);
			if not v335 then
				return nil;
			end
			FlatIdent_1B31C = 2 - 1;
		end
		if (FlatIdent_1B31C == (1 + 0)) then
			return AuraUtil.UnpackAuraData(v335);
		end
	end
end;
v1['dep']['G_UnitDebuff'] = _G['UnitDebuff'] or function(v336, v337, v338)
	local FlatIdent_8AD20 = 1653 - (1062 + 591);
	local v339;
	while true do
		if ((1089 - (878 + 211)) == FlatIdent_8AD20) then
			v339 = C_UnitAuras.GetDebuffDataByIndex(v336, v337, v338);
			if not v339 then
				return nil;
			end
			FlatIdent_8AD20 = 1 - 0;
		end
		if (FlatIdent_8AD20 == (608 - (402 + 205))) then
			return AuraUtil.UnpackAuraData(v339);
		end
	end
end;
v1['dep']['GetSpellCount'] = _G['GetSpellCount'] or C_Spell['GetSpellCastCount'];
