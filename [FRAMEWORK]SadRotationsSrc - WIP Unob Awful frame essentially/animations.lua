local Tinkr, blink = ...

local lerp = function(a, b, c)
	return a + (b - a) * c
end
blink.lerp = lerp

blink.cubicBezier = function(t, p0, p1, p2, p3)
	local l1 = lerp(p0, p1, t)
	local l2 = lerp(p1, p2, t)
	local l3 = lerp(p2, p3, t)
	local a = lerp(l1, l2, t)
	local b = lerp(l2, l3, t)
	local cubic = lerp(a, b, t)
	return cubic
end

-- blink.cubicBezier = function(t, p0, p1, p2, p3)
-- 	return (1 - t)^3*p0 + 3*(1 - t)^2*t*p1 + 3*(1 - t)*t^2*p2 + t^3*p3
-- end

blink.rgbColors = {
    ["blue"] = {180/255, 180/255, 255/255},
    ["red"] = {255/255, 60/255, 60/255},
    ["gray"] = {75/255, 75/255, 75/255},
    ["yellow"] = {255/255, 235/255, 25/255},
    ["green"] = {30/255, 230/255, 60/255},
}

blink.colored = function(str, color)
    return color .. str .. "|r"
end
