local v0, v1 = ...;
local v2 = function(v7, v8, v9)
	return v7 + ((v8 - v7) * v9);
end;
v1['lerp'] = v2;
v1.cubicBezier = function(v10, v11, v12, v13, v14)
	local FlatIdent_1F9B8 = 1006 - (455 + 551);
	local v15;
	local v16;
	local v17;
	local v18;
	local v19;
	local v20;
	while true do
		if ((3 - 0) == FlatIdent_1F9B8) then
			return v20;
		end
		if (FlatIdent_1F9B8 == (0 - 0)) then
			v15 = v2(v11, v12, v10);
			v16 = v2(v12, v13, v10);
			FlatIdent_1F9B8 = 1 - 0;
		end
		if (FlatIdent_1F9B8 == (383 - (369 + 13))) then
			v17 = v2(v13, v14, v10);
			v18 = v2(v15, v16, v10);
			FlatIdent_1F9B8 = 7 - 5;
		end
		if (FlatIdent_1F9B8 == (1022 - (464 + 556))) then
			v19 = v2(v16, v17, v10);
			v20 = v2(v18, v19, v10);
			FlatIdent_1F9B8 = 2 + 1;
		end
	end
end;
v1['rgbColors'] = {blue={((229 - 49) / (95 + 160)),((337 - 157) / (622 - (34 + 333))),((94 + 161) / (135 + 120))},red={((2140 - (992 + 893)) / (482 - (72 + 155))),((2058 - (49 + 1949)) / (823 - 568)),((879 - (227 + 592)) / (192 + 63))},gray={((69 + 6) / (187 + 68)),((49 + 26) / (1031 - (557 + 219))),((418 - (33 + 310)) / (640 - (184 + 201)))},yellow={((541 - 286) / (1330 - (273 + 802))),((359 - 124) / (66 + 189)),((80 - 55) / (1249 - 994))},green={((911 - (363 + 518)) / (1264 - 1009)),((59 + 171) / (1662 - (1292 + 115))),((185 - 125) / (2098 - (1808 + 35)))}};
v1.colored = function(v21, v22)
	return v22 .. v21 .. "|r";
end;
