Townhall = inherit(Singleton)

Townhall.Textures = {  "lacityhwal1", "decobuild2b_lan", "greyground256", "cj_white_wall2", "cj_galvanised", "gen_chrome", "cj_wooddoor3", "waterclear256", "metalic_64", "tislndshpillar01_128", "block2bb", "didersachs01", "semi3dirty", "cj_don_post_3", "starspangban1_256","wmyconb" }
Townhall.TexturePath = "files/images/Textures/Cityhall"
addRemoteEvents{"Townhall:applyTexture", "Townhall:removeTexture"}

function Townhall:constructor()
	self.m_Peds = {}
	self.m_OnClickFunc = bind(self.Event_OnPedClick, self)

	-- Job Info
	--[[ local jobInfoPed = Ped.create(12, Vector3(2754.63, -2374.09, 819.24))
	jobInfoPed:setRotation(Vector3(0, 0, 180))
	jobInfoPed:setInterior(5)
	jobInfoPed.Name = _"Spielhilfe"
	jobInfoPed.Description = _"Für mehr Infos klicke mich an!"
	jobInfoPed.Type = 1
	jobInfoPed.Func = function() HelpGUI:new() end
	self.m_Peds[#self.m_Peds + 1] = jobInfoPed ]]

	--[[ Activities
	local activitiesInfoPed = Ped.create(9, Vector3(1824, -1271.5, 120.3))
	activitiesInfoPed:setRotation(Vector3(0, 0, 182.754))
	activitiesInfoPed.Name = _"Stadthalle: Aktivitäten"
	activitiesInfoPed.Description = _"Für mehr Infos klicke mich an!"
	activitiesInfoPed.Type = 2
	self.m_Peds[#self.m_Peds + 1] = activitiesInfoPed
	]]
	-- Groups
	--// Group create ped
	local groupInfoPed = Ped.create(9, Vector3(2758.87, -2374.48, 819.24))
	groupInfoPed:setRotation(Vector3(0, 0, 180))
	groupInfoPed:setInterior(5)
	groupInfoPed.Name = _"Private Firmen und Gangs"
	groupInfoPed.Description = _"Für mehr Infos klicke mich an!"
	groupInfoPed.Type = 3
	groupInfoPed.Func = function() GroupCreationGUI:new() end
	self.m_Peds[#self.m_Peds + 1] = groupInfoPed

	--// Group property ped
	local groupImmoPed = Ped.create(290, Vector3(2763.79, -2374.51, 819.24))
	groupImmoPed:setRotation(Vector3(0, 0, 180))
	groupImmoPed.Name = _"Firmen-/Gangimmobilien"
	groupImmoPed:setInterior(5)
	groupImmoPed.Description = _"Für mehr Infos klicke mich an!"
	groupImmoPed.Type = 5
	groupImmoPed.Func = function()
		if localPlayer:getGroupName() ~= "" then
			GroupPropertyBuy:new()
		else ErrorBox:new(_"Du hast keine Firma/Gang!")
		end
	end
	self.m_Peds[#self.m_Peds + 1] = groupImmoPed

	--Houses for sale Ped
	local housesForSalePed = Ped.create(290, Vector3(2762.49, -2374.51, 819.24))
	housesForSalePed:setRotation(Vector3(0, 0, 180))
	housesForSalePed.Name = _"Häuser"
	housesForSalePed:setInterior(5)
	housesForSalePed.Description = _"Für mehr Infos klicke mich an!"
	housesForSalePed.Func = function()
		HousesForSaleGUI:new(housesForSalePed)
	end
	self.m_Peds[#self.m_Peds + 1] = housesForSalePed
	
	-- Items
	local itemInfoPed = Ped.create(9, Vector3( 2767.47, -2374.46, 819.24))
	itemInfoPed:setRotation(Vector3(0, 0, 180))
	itemInfoPed.Name = _"Ausweis / Kaufvertrag"
	itemInfoPed:setInterior(5)
	itemInfoPed.Description = _"Für mehr Infos klicke mich an!"
	itemInfoPed.Type = 4
	itemInfoPed.Func = function() triggerServerEvent("shopOpenGUI", localPlayer, 50) end
	self.m_Peds[#self.m_Peds + 1] = itemInfoPed

	local unregisterVehiclePed = Ped.create(12, Vector3(2754.63, -2374.46, 819.24))
	unregisterVehiclePed:setRotation(Vector3(0, 0, 180))
	unregisterVehiclePed.Name = _"Fahrzeuge an-/abmelden"
	unregisterVehiclePed:setInterior(5)
	unregisterVehiclePed.Description = _"Für mehr Infos klicke mich an!"
	unregisterVehiclePed.Type = 6
	unregisterVehiclePed.Func = function() VehicleUnregisterGUI:new(unregisterVehiclePed) end
	self.m_Peds[#self.m_Peds + 1] = unregisterVehiclePed

	--// VEHICLE SPAWNER PEDS
	local itemSpawnerPed = Ped.create(171, Vector3(1767.33, -1721.86, 13.37)) -- driving school
	itemSpawnerPed:setRotation(Vector3(0, 0, 180))
	itemSpawnerPed.Name = _"Fahrzeugverleih"
	itemSpawnerPed.Description = _("Fahrzeug für %s$ ausleihen!", VEHICLE_RENTAL_PRICE)
	itemSpawnerPed.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed

	local itemSpawnerPed2 = Ped.create(171, Vector3(1509.99, -1749.29, 13.55)) -- city hall
	itemSpawnerPed2:setRotation(Vector3(0, 0, 97.13))
	itemSpawnerPed2.Name = _"Fahrzeugverleih"
	itemSpawnerPed2.Description = _("Fahrzeug für %s$ ausleihen!", VEHICLE_RENTAL_PRICE)
	itemSpawnerPed2.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed2


	--// WT PED AREA
	local itemSpawnerPed3 = Ped.create(287, Vector3(117.39, 1883.09, 17.88))
	itemSpawnerPed3:setRotation(Vector3(0, 0, 0))
	itemSpawnerPed3.Name = _"Ausrüstungsfahrzeug"
	itemSpawnerPed3.Description = _"Hier startet der Waffentruck!"
	itemSpawnerPed3.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed3


	--// WT PED SF
	local itemSpawnerPed4 = Ped.create(307, Vector3(-1869.94, 1422.34, 7.18))
	itemSpawnerPed4:setRotation(Vector3(0, 0, 220))
	itemSpawnerPed4.Name = _"Illegaler Waffentruck"
	itemSpawnerPed4.Description = _"Hier startet der Waffentruck!"
	itemSpawnerPed4.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed4


	--// VEHICLE SPAWNER RESCUE
	local itemSpawnerPed5 = Ped.create(171, Vector3(1180.90, -1331.90, 13.58))
	itemSpawnerPed5:setRotation(Vector3(0, 0, 270))
	itemSpawnerPed5.Name = _"Fahrzeugverleih"
	itemSpawnerPed5.Description = _("Fahrzeug für %s$ ausleihen!", VEHICLE_RENTAL_PRICE)
	itemSpawnerPed5.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed5

	--// RESCUE BASE HEAL PED

	local itemSpawnerPed6 = Ped.create(70, Vector3(1172.33, -1321.48, 15.40))
	itemSpawnerPed6:setRotation(Vector3(0, 0, 270))
	itemSpawnerPed6.Name = _"Erste Hilfe"
	itemSpawnerPed6.Description = _"Klicke mich für Heilung an!"
	itemSpawnerPed6.Func = function() triggerServerEvent("factionRescuePlayerHealBase", localPlayer) end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed6
	
	
	--// TOWN HALL JOB LIST 
	local itemSpawnerPed7 = Ped.create(70, Vector3(2750.27, -2374.66, 819.24))
	itemSpawnerPed7:setRotation(Vector3(0, 0, 180))
	itemSpawnerPed7.Name = _"Jobliste"
	itemSpawnerPed7:setInterior(5)
	itemSpawnerPed7.Description = _"Klicke hier für Informationen!"
	itemSpawnerPed7.Func = function() HelpGUI:getSingleton():openLexiconPage(LexiconPages.JobOverview) end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed7
	

	--// DT PED 
	local itemSpawnerPed8 = Ped.create(1, Vector3(-1096.38, -1614.74, 76.37))
	itemSpawnerPed8:setRotation(Vector3(0, 0, 270))
	itemSpawnerPed8.Name = _"Illegaler Weed-Transport"
	itemSpawnerPed8.Description = _"Hier startet der Drogentruck!"
	itemSpawnerPed8.Func = function() end
	self.m_Peds[#self.m_Peds + 1] = itemSpawnerPed8

	local president = Ped.create(153, Vector3(2747.92, -2378.36, 818.9))
	president:setAnimation("cop_ambient", "Coplook_loop", -1, true, false, false, true)
	president:setRotation(Vector3(0, 0, 266.67))
	president:setData("NPC:Immortal", true)
	president:setFrozen(true)
	president:setInterior(5)
	
	-- Initialize
	self:initalizePeds()

	local col = createColRectangle(1399.60, -1835.2, 1540.14-1399.60, 1835.2-1582.84) -- pershing square
	self.m_NoParkingZone = NoParkingZone:new(col)
	NonCollisionArea:new("Cuboid", {Vector3(1502.43, -1850.71, 12), 40, 10 ,10})

	self.m_ApplyInteriorTexture = bind(self.applyInteriorTexture, self)
	addEventHandler("Townhall:applyTexture", localPlayer, self.m_ApplyInteriorTexture)
	
	self.m_RemoveInteriorTexture = bind(self.removeInteriorTexture, self)
	addEventHandler("Townhall:removeTexture", localPlayer, self.m_RemoveInteriorTexture)
end

function Townhall:destructor()
	for i, v in pairs(self.m_Peds) do
		if v.SpeakBubble then
			delete(v.SpeakBubble) -- would also happen automatically ^^
		end
		v:destroy()
	end
end

function Townhall:initalizePeds()
	for i, v in pairs(self.m_Peds) do
		setElementData(v, "clickable", true)
		v:setData("NPC:Immortal", true)
		v:setData("Townhall:onClick", function () self.m_OnClickFunc(v) end)
		v:setFrozen(true)
		v.SpeakBubble = SpeakBubble3D:new(v, v.Name, v.Description)
	end
end

function Townhall:Event_OnPedClick(ped)
	if ped.Func then
		ped.Func()
	else
		ShortMessage:new("Clicked-Ped: "..ped.Type)
		TownhallInfoGUI:getSingleton():openTab(ped.Type)
	end
end

function Townhall:applyInteriorTexture()
	if self.m_InteriorTexture and #self.m_InteriorTexture > 0 then 
		self:removeInteriorTexture()
	end
	self.m_InteriorTexture = {}
	for i = 1, #Townhall.Textures do 
		if fileExists(Townhall.TexturePath.."/tex"..i..".jpg") then
			self.m_InteriorTexture[i] = StaticFileTextureReplacer:new(Townhall.TexturePath.."/tex"..i..".jpg", Townhall.Textures[i])
		end
	end
end

function Townhall:removeInteriorTexture()
	if self.m_InteriorTexture then
		for i = 1, #self.m_InteriorTexture do 
			self.m_InteriorTexture[i]:delete()
		end	
	end
end

--[[
<ped id="ped (1)" dimension="0" model="12" interior="0" rotZ="212.004" alpha="255" posX="1819.6" posY="-1272.9" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (2)" dimension="0" model="9" interior="0" rotZ="182.754" alpha="255" posX="1824" posY="-1271.5" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (3)" dimension="0" model="150" interior="0" rotZ="182.754" alpha="255" posX="1828.3" posY="-1271.6" posZ="120.3" rotX="0" rotY="0"></ped>
<ped id="ped (4)" dimension="0" model="219" interior="0" rotZ="132.754" alpha="255" posX="1832.8" posY="-1273.5" posZ="120.3" rotX="0" rotY="0"></ped>
]]
