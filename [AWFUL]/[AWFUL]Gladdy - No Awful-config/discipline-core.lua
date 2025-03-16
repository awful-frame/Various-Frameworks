local v0, v1, v2 = ...;
if (v1['player']['class2'] ~= "PRIEST") then
	return;
end
if (GetSpecialization() ~= (1 - 0)) then
	return;
end
v2['priest'] = {};
v2['priest']['discipline'] = v1['Actor']:New({spec=(1 + 0),class="priest"});
