INJURY_WEAPON_TO_CAUSE = 
{
	[0] = "Prellungen",
	[1] = "Prellungen",
	[2] = "Prellungen",
	[3] = "Prellungen",
	[4] = "Schnittwunde",
	[5] = "Prellungen",
	[6] = "Prellungen",
	[7] = "Prellungen",
	[8] = "Schnittwunde",
	[9] = "Schnittwunde",
	[10] = "Prellungen",
	[11] = "Prellungen",
	[12] = "Prellungen",
	[13] = "Prellungen",
	[14] = "Prellungen",
	[15] = "Prellungen",
	[22] = "Schusswunde (Kal. 9mm)",
	[23] = "Schusswunde (Kal. 9mm)",
	[24] = "Schusswunde (Kal. 50)",
	[25] = "Schusssplitter (Schrot)",
	[26] = "Schusssplitter (Schrot)",
	[27] = "Schusssplitter (Schrot)",
	[28] = "Schusswunde (Kal. 9mm)",
	[29] = "Schusswunde (Kal. 9mm)",
	[30] = "Schusswunde (Kal. 7,62)",
	[31] = "Schusswunde (Kal. 5,56)",
	[32] = "Schusswunde (Kal. 9mm)",
	[33] = "Schusswunde (Kal. 44)",
	[34] = "Schusswunde (Kal. 50)",
	[35] = "Schrapnellen",
	[36] = "Schrapnellen",
	[37] = "Verbrennungen",
	[38] = "Schusswunde",
	[16] = "Schrapnellen",
	[18] = "Verbrennungen",
	[39] = "Schrapnellen",
	[41] = "Vergiftung",
	[42] = "Vergiftung",
	[19] = "Schrapnellen",
	[49] = "Prellungen",
	[50] = "Prellungen",
	[51] = "Schrapnellen",
	[52] = "Schusswunde",
	[53] = "Atemprobleme",
	[54] = "Verstauchungen",
	[55] = "Unbekannt",
	[56] = "Prellung",
	[57] = "Schusswunde",
	[59] = "Schrapnellen",
	[63] = "Verbrennungen"
}

TIME_FOR_TREAT_BODYPART = 
{
	[9] = 2,
	[8] = 1, 
	[7] = 1, 
	[6] = 1, 
	[5] = 1, 
	[4] = 1.25, 
	[3] = 1.5,
}

TIME_FOR_TREAT_DAMAGE = 
{
	["Schusswunde (Kal. 9mm)"] = 2, 
	["Schusswunde (Kal. 7,62)"] = 3, 
	["Schusswunde (Kal. 5,56)"] = 2.5,
	["Schusswunde (Kal. 44)"] = 2,
	["Schusssplitter (Schrot)"] = 4,
	["Schusswunde (Kal. 50)"] = 4, 
	["Prellungen"] = 1, 
	["Schrapnellen"] = 1, 
	["Verbrennungen"] = 1, 
	["Atemprobleme"] = 0.5,
	["Schnittwunde"] = 1, 
	["Unbekannt"] = 1,
}

TIME_FOR_HEALERS = 
{
	SELF_TREATMENT = 3, 
	NON_RESCUE_PLAYER = 2, 
	RESCUE_PLAYER = 1,
	TRAINED_NON_RESCUE = 1.2,
}

TEXT_FOR_HEALER_PENALTY = 
{
	SELF_TREATMENT = "",
	NON_RESCUE_PLAYER = "",
	RESCUE_PLAYER = "",
	TRAINED_NON_RESCUE = "",
}

TREAT_ANIMATION_PATIENT = 
{
	SELF_TREATMENT = {"bomber", "bom_plant_loop", .5},
	NON_RESCUE_PLAYER = {"crack", "crckidle1", .1},
	RESCUE_PLAYER = {"crack", "crckidle1", .1},
	TRAINED_NON_RESCUE = {"crack", "crckidle1", .1},
}

TREAT_ANIMATION_HEALER = 
{
	SELF_TREATMENT = {"bomber", "bom_plant_loop", .5},
	NON_RESCUE_PLAYER = {"bomber", "bom_plant_loop", .5},
	RESCUE_PLAYER = {"bomber", "bom_plant_loop", .5},
	TRAINED_NON_RESCUE = {"bomber", "bom_plant_loop", .5},
}
