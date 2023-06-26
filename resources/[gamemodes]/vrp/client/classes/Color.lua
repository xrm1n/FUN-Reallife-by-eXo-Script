-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Color.lua
-- *  PURPOSE:     Static color "pseudo-class"
-- *
-- ****************************************************************************

local defaultAlpha = 150

Color = {
	Clear     = {0, 0, 0, 0   },
	Black     = {0,     0,   0},
	White     = {255, 255, 255},
	Grey	  = {0x23, 0x23, 0x23, 230},
	LightGrey = {128, 128, 128, 255},
	Red       = {178,  35,  33}, --{255,   0,   0},
	Yellow    = {255, 255,   0},
	Green     = {11,  102,   8}, --{0,   255,   0},
	Blue      = {0,     0, 255},
	DarkBlue  = {0,    32,  63},
	DarkBlueAlpha   = {0,32,  63, 200},
    DarkLightBlue = {0, 50, 100, 255},
	Brown     = {128, 64, 0},
	BrownAlpha= {189, 109, 19, 180},
	LightBlue = {50, 200, 255},
	Orange    = {254, 138, 0},
	LightRed  = {244, 73, 85},
	Purple 	  = {128, 0, 128},

	HUD_Red		= {161,	47,	47},
	HUD_Red_D	= {133,	28,	28},
	HUD_Grey	= {158,158,158},
	HUD_Grey_D	= {97,97,97},
	HUD_Green	= {56,	142,60},
	HUD_Green_D	= {27,	94,	32},
	HUD_Blue	= {25,118,210},
	HUD_Blue_D	= {13,71,161},
	HUD_Cyan	= {0,151,167},
	HUD_Cyan_D	= {0,96,100},
	HUD_Orange_D= {245,127,23},
	HUD_Lime_D	= {130,119,23},
	HUD_Brown_D	= {62,39,35},

	Background	= {0, 0, 0, defaultAlpha}, --black
	Primary		= {35, 35, 35, 230}, --grey
	PrimaryNoClick	= {55, 55, 55, 230}, -- light grey
	Accent		= {58, 186, 242}, --light blue
	Success 	= {11,  102,   8}, -- green
	Error 		= {178,  35,  33}, -- green
	Warning 	= {254, 138, 0}, -- green

	AD_LightBlue = {0, 125, 125},

	Wood = {143, 91, 41},
}

function Color.changeAlphaRate(color, p) -- 0 = 0 alpha, 1 = full alpha depending on color
	local p = math.clamp(0, p, 1)
	if p == 0 then return Color.Clear end
	if p == 1 then return color end
	return bitReplace(color, bitExtract(color, 24, 8) * p, 24, 8)
end

function Color.changeAlpha(color, alpha)
	if math.clamp(0, alpha, 255) == 0 then return Color.Clear end
	return bitReplace(color, alpha, 24, 8)
end

Color.calculateColorScheme = function()
	Color.Accent_Alpha = Color.changeAlpha(Color.Accent, defaultAlpha)
	Color.Success_Alpha = Color.changeAlpha(Color.Success, defaultAlpha)
	Color.Error_Alpha = Color.changeAlpha(Color.Error, defaultAlpha)
	Color.Warning_Alpha = Color.changeAlpha(Color.Warning, defaultAlpha)

end

AdminColor = {
	[0] = {255,255,255},
	[1] = {0,128,0},
	[2] = {4,95,180},
	[3] = {4,95,180},
	[4] = {4,95,180},
	[5] = {255,0,0},
	[6] = {255,0,0},
	[7] = {255,0,0},
	[8] = {255,0,0},
	[9] = {255,0,0},
}

for k,v in pairs(AdminColor) do
	AdminColor[k] = tocolor(unpack(v))
end

for k, v in pairs(Color) do
	if type(v) == "table" then
		Color[k] = tocolor(unpack(v))
	end
end

Color.calculateColorScheme()

--https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
function Color.rgbToHsv(r, g, b, a)
	if not a then a = 255 end
	local r, g, b, a = r / 255, g / 255, b / 255, a / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
		h = (g - b) / d
		if g < b then h = h + 6 end
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, v, a
end

function Color.hsvToRgb(h, s, v, a)
	if not a then a = 1 end
	local r, g, b

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return r * 255, g * 255, b * 255, a * 255
end