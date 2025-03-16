local v0, v1, v2 = ...;
if (v1['player']['class2'] ~= "PALADIN") then
	return;
end
if (v1['player']['spec'] ~= "Holy") then
	return;
end
v2['paladin'] = {};
v2['paladin']['holy'] = v1['Actor']:New({spec=(1 + 0),class="paladin"});
