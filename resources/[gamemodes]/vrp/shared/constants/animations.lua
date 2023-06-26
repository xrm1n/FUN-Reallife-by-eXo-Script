ANIMATION_GROUPS = {"Standard", "Tänze", "Sonstiges", "Vulgär", "Verletzung"}

ANIMATIONS = {
	["Hände hoch"] = 			{["group"] = "Standard", ["block"] = "shop", ["animation"] = "SHP_HandsUp_Scr", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Hinlegen"] = 				{["group"] = "Standard", ["block"] = "beach", ["animation"] = "bather", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Ducken"] = 				{["group"] = "Standard", ["block"] = "ped", ["animation"] = "cower", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Hinsetzen (Sessel)"] = 	{["group"] = "Standard", ["block"] = "beach", ["animation"] = "ParkSit_M_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Hinsetzen"] = 			{["group"] = "Standard", ["block"] = "BEACH", ["animation"] = "SitnWait_loop_W", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Sprechen"] = 				{["group"] = "Standard", ["block"] = "ped", ["animation"] = "IDLE_chat", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Winken"] = 				{["group"] = "Standard", ["block"] = "ON_LOOKERS", ["animation"] = "wave_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Arme verschränken"] = 	{["group"] = "Standard", ["block"] = "cop_ambient", ["animation"] = "Coplook_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Lachen"] = 				{["group"] = "Standard", ["block"] = "rapping", ["animation"] = "Laugh_01", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Links/Rechts schauen"] =	{["group"] = "Standard", ["block"] = "ped", ["animation"] = "roadcross", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Strecken"] =				{["group"] = "Standard", ["block"] = "playidles", ["animation"] = "stretch", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Handstand"] =				{["group"] = "Standard", ["block"] = "dam_jump", ["animation"] = "DAM_Dive_Loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Waffe beidhändig"] =		{["group"] = "Standard", ["block"] = "ped", ["animation"] = "arrestgun", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Waffe Gangster"] =		{["group"] = "Standard", ["block"] = "ped", ["animation"] = "gang_gunstand", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Bombe platzieren"] =		{["group"] = "Standard", ["block"] = "bomber", ["animation"] = "bom_plant", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Wave"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_a", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Chill"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_b", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Ruhig"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_d", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Wild"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dnce_M_e", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Hip-Hop"] = 			{["group"] = "Tänze", ["block"] = "DANCING", ["animation"] = "dance_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Strip"] = 			{["group"] = "Tänze", ["block"] = "STRIP", ["animation"] = "STR_Loop_A", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Nuttig"] = 			{["group"] = "Tänze", ["block"] = "STRIP", ["animation"] = "STR_Loop_B", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanz Sexy"] = 			{["group"] = "Tänze", ["block"] = "STRIP", ["animation"] = "STR_Loop_C", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Taichi"] = 				{["group"] = "Tänze", ["block"] = "park", ["animation"] = "Tai_Chi_Loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Fuck you"] = 				{["group"] = "Sonstiges", ["block"] = "ped", ["animation"] = "fucku", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Po klatschen"] =			{["group"] = "Sonstiges", ["block"] = "sweet", ["animation"] = "sweet_ass_slap", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Bitch Slap"] =			{["group"] = "Sonstiges", ["block"] = "misc", ["animation"] = "bitchslap", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Überreichen"] =			{["group"] = "Sonstiges", ["block"] = "dealer", ["animation"] = "dealer_deal", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Bezahlen"] =				{["group"] = "Sonstiges", ["block"] = "dealer", ["animation"] = "drugs_buy", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Geld abheben"] =			{["group"] = "Sonstiges", ["block"] = "ped", ["animation"] = "atm", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Kaugummi"] =				{["group"] = "Sonstiges", ["block"] = "ped", ["animation"] = "gum_eat", ["loop"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Rauchen"] =				{["group"] = "Sonstiges", ["block"] = "smoking", ["animation"] = "M_smkstnd_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Pinkeln"] =				{["group"] = "Vulgär", ["block"] = "PAULNMAC", ["animation"] = "Piss_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true, ["object"] = 1904},
	["Wichsen"] =				{["group"] = "Vulgär", ["block"] = "PAULNMAC", ["animation"] = "wank_loop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Sex oben"] =				{["group"] = "Vulgär", ["block"] = "sex", ["animation"] = "sex_1_cum_p", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Sex unten"] =				{["group"] = "Vulgär", ["block"] = "sex", ["animation"] = "sex_1_cum_w", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Kotzen"] =				{["group"] = "Vulgär", ["block"] = "food", ["animation"] = "EAT_Vomit_P", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Seitenlage"] =			{["group"] = "Verletzung", ["block"] = "CRACK", ["animation"] = "crckidle2", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Schmerzen"] =				{["group"] = "Verletzung", ["block"] = "SWEET", ["animation"] = "Sweet_injuredloop", ["loop"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
}

WALKINGSTYLE_GROUPS = {"Standard", "Mann", "Frau", "Sonstiges"}

WALKINGSTYLES = {
	["Normal"] = 					{["group"] = "Standard", ["id"] = 0},
	["Fett"] = 						{["group"] = "Standard", ["id"] = 55},
	["Muskulös"] = 					{["group"] = "Standard", ["id"] = 56},
	["Mann"] = 						{["group"] = "Mann", ["id"] = 118},
	["Mann (Alt)"] = 				{["group"] = "Mann", ["id"] = 120},
	["Mann (Fett)"] = 				{["group"] = "Mann", ["id"] = 123},
	["Gesenkter Kopf (alt)"] = 		{["group"] = "Mann", ["id"] = 119},
	["Frau"] = 						{["group"] = "Frau", ["id"] = 129},
	["Frau (Business)"] = 			{["group"] = "Frau", ["id"] = 131},
	["Frau (Sexy)"] = 				{["group"] = "Frau", ["id"] = 132},
	["Frau (Gehoben)"] = 			{["group"] = "Frau", ["id"] = 133},
	["Frau (Alt)"] = 				{["group"] = "Frau", ["id"] = 134},
	["Frau (Fett)"] = 				{["group"] = "Frau", ["id"] = 135},
	["Frau (Einkaufstaschen)"] = 	{["group"] = "Frau", ["id"] = 130},
	["Gangster 1"] = 				{["group"] = "Sonstiges", ["id"] = 121},
	["Gangster 2"] = 				{["group"] = "Sonstiges", ["id"] = 122},
	["SWAT"] = 						{["group"] = "Sonstiges", ["id"] = 128},
}

CUSTOM_ANIMATION_IFP = {
	["files/animations/parkour.ifp"] = "VRP.PARKOUR",
	["files/animations/dance.ifp"] = "VRP.DANCE",
	["files/animations/other.ifp"] = "VRP.OTHER",
}

CUSTOM_ANIMATION_GROUPS = {"Parkour", "Tänze", "Sonstiges"}

CUSTOM_ANIMATIONS = {
	["Flick-Flack mit Salto"] = {["group"] = "Parkour", ["block"] = "VRP.PARKOUR", ["animation"] = "BckHndSpingBTuck", ["loop"] = false, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = false},
	["Flick-Flack"] = 			{["group"] = "Parkour", ["block"] = "VRP.PARKOUR", ["animation"] = "BckHndSping", ["loop"] = false, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = false},
	["Rad"] = 					{["group"] = "Parkour", ["block"] = "VRP.PARKOUR", ["animation"] = "CartWheel", ["loop"] = false, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = false},
	["Überschlag"] = 			{["group"] = "Parkour", ["block"] = "VRP.PARKOUR", ["animation"] = "FrntHndSpring", ["loop"] = false, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = false},
	["Handplant"] = 			{["group"] = "Parkour", ["block"] = "VRP.PARKOUR", ["animation"] = "HandPlant", ["loop"] = false, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = false},

	["Huhn"] = 					{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCECHICKEN", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Liebe"] = 				{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCELOVE", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Macarena"] = 				{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCEMACARENA", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Tanzbein"] = 				{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCELEG", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Wiggler"] = 				{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCEWIGGLE", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Chill"] = 				{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCECHILL", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Sexy"] = 					{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCESEXY", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Hardcore"] = 				{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCEHARD", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Pump It"] = 				{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCEPUMPIT", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},
	["Betrunken"] = 			{["group"] = "Tänze", ["block"] = "VRP.DANCE", ["animation"] = "DANCEDRUNK", ["loop"] = true, ["updatePosition"] = true, ["interruptable"] = false, ["freezeLastFrame"] = true},

	["Hände hinter Kopf"] = 	{["group"] = "Sonstiges", ["block"] = "VRP.OTHER", ["animation"] = "cowerHandsBehindHead", ["loop"] = true, ["updatePosition"] = false, ["interruptable"] = false, ["freezeLastFrame"] = true},
}