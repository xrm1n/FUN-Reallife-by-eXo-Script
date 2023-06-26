-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleSpawner.lua
-- *  PURPOSE:     VehicleSpawner class
-- *
-- ****************************************************************************
VehicleSpawner = inherit(Object)
VehicleSpawner.Map = {}

addEvent("onTryVehicleSpawner", true)
addEventHandler("onTryVehicleSpawner", root, function() 

	if client.m_LastVehicleSpawner then 
		local index = table.find(VehicleSpawner.Map, client.m_LastVehicleSpawner)
		if index then
			local mx, my, mz = getElementPosition(client.m_LastVehicleSpawner.m_Marker)
			local px, py, pz = getElementPosition(client)
			if getDistanceBetweenPoints3D(mx, my, mz, px, py, pz) < 3 then
				client.m_LastVehicleSpawner:markerHit(client, client.m_LastVehicleSpawner.m_Marker:getDimension() == client:getDimension())	
			end
		end
	end
end)

function VehicleSpawner:constructor(x, y, z, vehicles, rotation, spawnConditionFunc, postSpawnFunc)
	VehicleSpawner.Map[#VehicleSpawner.Map + 1] = self
	self.m_Id = #VehicleSpawner.Map
	self.m_Hook = Hook:new()
	self.m_Vehicles = {}
	for k, v in ipairs(vehicles) do
		self.m_Vehicles[type(v) == "number" and v or getVehicleModelFromName(v)] = true
	end

	self.m_Allowed = {}

	self.m_Position = Vector3(x, y, z)
	self.m_Rotation = rotation or 0
	self.m_ConditionFunc = spawnConditionFunc
	self.m_ConditionError = true
	self.m_ShowEPTAdvertisement = false
	self.m_PostSpawnFunc = postSpawnFunc

	self.m_Marker = createMarker(x, y, z, "cylinder", 1.2, 255, 0, 0)
	ElementInfo:new(self.m_Marker, "Ausgang", 1.2, "Car", true)
	--bind(self.markerHit, self)
	
	addEventHandler("onMarkerHit", self.m_Marker, function(hitElement)
		if hitElement:getDimension() == source:getDimension() and hitElement:getInterior() == source:getInterior() and hitElement:getType() == "player" and not hitElement.vehicle then 
			hitElement.m_LastVehicleSpawner = self
			hitElement:triggerEvent("onTryEnterExit", self.m_Marker, "Fahrzeuge", "files/images/Other/info.png") 
		end
	end)
end

function VehicleSpawner:markerHit(hitElement, matchingDimension)
	if not self.m_Disabled or (self.m_Disabled and self.m_Allowed[hitElement]) then
		if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) then
			if self.m_ConditionFunc and not self.m_ConditionFunc(hitElement) then
				if self.m_ConditionError then
					hitElement:sendError(_("Du bist nicht berechtigt dieses Fahrzeug zu erstellen!", hitElement))
				end
				return
			end

			hitElement:triggerEvent("vehicleSpawnGUI", self.m_Id, self.m_Vehicles, self.m_ShowEPTAdvertisement, self.m_Marker)
		end
	end
end

addEvent("vehicleSpawn", true)
addEventHandler("vehicleSpawn", root,
	function(spawnerId, vehicleModel)
		local shop = VehicleSpawner.Map[spawnerId]
		if not shop then return end

		if (client:getPosition() - shop.m_Marker:getPosition()).length > 10 then
			client:sendError(_("Du bist zu weit entfernt!", client))
			return
		end

		if not shop.m_Vehicles[vehicleModel] then
			-- Todo: Report possible attack
			return
		end

		if client:getSpawnerVehicle() and isElement(client:getSpawnerVehicle()) then
			destroyElement(client:getSpawnerVehicle())
		end

		local vehicle = TemporaryVehicle.create(vehicleModel, shop.m_Position.x, shop.m_Position.y, shop.m_Position.z + 1.5, shop.m_Rotation)

		nextframe(
			function(player)
				if not player:hasCorrectLicense(vehicle) then
					player:sendWarning(_("Du hast nicht den passenden Führerschein!", player))
					vehicle:destroy()
					return
				end

				if shop.m_PostSpawnFunc then
					shop.m_PostSpawnFunc(vehicle, player)
				end

				if shop.m_Hook then
					shop.m_Hook:call(player,vehicleModel,vehicle)
				end
				player:setSpawnerVehicle(vehicle)
				warpPedIntoVehicle(player, vehicle)
			end
		,client)


	end
)

function VehicleSpawner:disable()
	setElementVisibleTo(self.m_Marker, root, false)
	self.m_Disabled = true
end

function VehicleSpawner:toggleForPlayer(player, state)
	if state then
		setElementVisibleTo(self.m_Marker, player, true)
		self.m_Allowed[player] = true
	else
		setElementVisibleTo(self.m_Marker, player, false)
		self.m_Allowed[player] = false
	end
end

function VehicleSpawner:setSpawnPosition(pos, rot)
	self.m_Position = pos
	self.m_Rotation = rot or 0
end

function VehicleSpawner:toggleConditionError(state)
	self.m_ConditionError = state
	return self
end

function VehicleSpawner:showEPTAdvertisement(state)
	self.m_ShowEPTAdvertisement = state
	return self
end

function VehicleSpawner:initializeAll()
	-- Create 'general' vehicle spawners
	local function spawnCondition(player)
		if player:getMoney() >= VEHICLE_RENTAL_PRICE then
			return true
		else
			player:sendError(_("Du hast nicht genug Geld dabei! (%s$)", player, VEHICLE_RENTAL_PRICE))
		end
	end

	local function postSpawn(vehicle, player)
		player:transferMoney({CompanyManager:getSingleton():getFromId(CompanyStaticId.EPT), nil, true}, VEHICLE_RENTAL_PRICE, "Fahrzeugverleih", "Gameplay", "VehicleRent")
	end

	VehicleSpawner:new( 1508.79, -1749.41, 12.55, {"Bike", "BMX", "Faggio"}, 0, spawnCondition, postSpawn):toggleConditionError(false):showEPTAdvertisement(true) -- city hall
	VehicleSpawner:new(1767.34, -1723.21, 12.55, {"Bike", "BMX", "Faggio"}, 270, spawnCondition, postSpawn):toggleConditionError(false):showEPTAdvertisement(true) -- driving school
	VehicleSpawner:new(1182.59, -1331.99, 12.5, {"Bike", "BMX", "Faggio"}, 270, spawnCondition, postSpawn):toggleConditionError(false):showEPTAdvertisement(true)
end
