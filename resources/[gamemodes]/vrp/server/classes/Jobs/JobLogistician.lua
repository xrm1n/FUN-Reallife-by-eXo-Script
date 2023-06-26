-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobLogistician.lua
-- *  PURPOSE:     Logistician job
-- *
-- ****************************************************************************
JobLogistician = inherit(Job)
local MONEY_PER_TRANSPORT_MIN = 520*2 --// default 200
local MONEY_PER_TRANSPORT_MAX = 1020*2 --// default 500

function JobLogistician:constructor()
	Job.constructor(self)
	self.m_BankAccount = BankServer.get("job.logistician")

	-- Create Cranes
		self.m_Cranes = {
		["LS-Docks"] = Crane:new(2387.30, -2492.40, 19.6, 2387.30, -2625.60, 19.6),
		["Fleischberg"] = Crane:new(-219.70, -269.30, 7.30, -219.70, -200.30, 7.30),
		["Las Venturas"] = Crane:new(1607.5, 2300.1, 16.40, 1607.5, 2371.20, 16.40),
		["San Fierro"] = Crane:new(-1748.382, 104.676, 9.474, -1748.382, 149.426, 9.474),
	}

	self.m_Markers = {
		["LS-Docks"] = self:createCraneMarker(self.m_Cranes["LS-Docks"], Vector3(2386.92, -2494.24, 13), Vector3(2387.60, -2490.87, 14.1), 0),
		["Fleischberg"] = self:createCraneMarker(self.m_Cranes["Fleischberg"], Vector3(-219.35, -268.77, 0.6), Vector3(-219.70, -270.80, 2), 180),
		["Las Venturas"] = self:createCraneMarker(self.m_Cranes["Las Venturas"], Vector3(1607.5, 2300.10, 9.8), Vector3(1607.5, 2299.10, 11.4), 180),
		["San Fierro"] = self:createCraneMarker(self.m_Cranes["San Fierro"], Vector3(-1748.382, 104.676, 2.7), Vector3(-1748.38, 103.41, 4.34), 180),
	}

	self.m_VehicleSpawners = {
		["LS-Docks"] = VehicleSpawner:new(2405.45, -2445.40, 12.6, {"DFT-30"}, 230, bind(Job.requireVehicle, self)),
		["Fleischberg"] = VehicleSpawner:new(-209.97, -273.92, 0.5, {"DFT-30"}, 180, bind(Job.requireVehicle, self)),
		["Las Venturas"] = VehicleSpawner:new(1595.93, 2294.12, 9.8, {"DFT-30"}, 220, bind(Job.requireVehicle, self)),
		["San Fierro"] = VehicleSpawner:new(-1738.31, 87.00, 2.52, {"DFT-30"}, 150, bind(Job.requireVehicle, self)),

	}

	for name, spawner in pairs(self.m_VehicleSpawners) do
		spawner.m_Hook:register(bind(self.onVehicleSpawn,self))
		spawner:disable()
	end

	self:changeLoan()

	GlobalTimer:getSingleton():registerEvent(bind(self.changeLoan, self), "Logistic Job Loan Change", nil, nil, 00) -- Every Hour

end

function JobLogistician:start(player)
	for name, spawner in pairs(self.m_VehicleSpawners) do
		spawner:toggleForPlayer(player, true)
	end
end

function JobLogistician:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_LOGISTICAN) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_LOGISTICAN))
		return false
	end
	return true
end

function JobLogistician:changeLoan()
	self.m_MoneyPerTransport = math.random(MONEY_PER_TRANSPORT_MIN, MONEY_PER_TRANSPORT_MAX)
end

function JobLogistician:stop(player)
	for name, spawner in pairs(self.m_VehicleSpawners) do
		spawner:toggleForPlayer(player, false)
	end
	self:destroyJobVehicle(player)
	if isElement(player.LogisticanContainer) then player.LogisticanContainer:destroy() end
	if player:getData("Logistician:Blip") then delete(player:getData("Logistician:Blip")) end
	player:setData("Logistician:TargetMarker", nil)

end

function JobLogistician:onVehicleSpawn(player,vehicleModel,vehicle)
	player.m_LastJobAction = getRealTime().timestamp
	vehicle.m_DisableToggleHandbrake = true
	vehicle:setData("LogisticanVehicle", true)
	player:setData("Logistican:VehicleSpawn", vehicle:getPosition())
	self:registerJobVehicle(player, vehicle, true, true)
end

function JobLogistician:setNewDestination(player, targetMarker, crane)

	local pos = targetMarker:getPosition()
	player:sendInfo(_("Ein Container wird aufgeladen! Bringe ihn nach %s!", player, getZoneName(pos)))
	-- Destroy the old waypoint blip and create a new one
	if player:getData("Logistician:Blip") then
		delete(player:getData("Logistician:Blip"))
	end
	player:startNavigationTo(pos)

	local blip = Blip:new("Marker.png", pos.x, pos.y, player,9999, BLIP_COLOR_CONSTANTS.Red)
		blip:setDisplayText("Container-Abgabepunkt")
	player:setData("Logistician:Blip", blip)

	player:setData("Logistician:TargetMarker", targetMarker)
	player:setData("Logistician:LastCrane", crane)

end

function JobLogistician:createCraneMarker(crane, pos, vehPos, vehRot)
	local marker = createMarker(pos, "cylinder", 3, 255, 255, 0, 127)
	marker.Crane = crane
	marker.VehPos = vehPos
	marker.VehRot = Vector3(0, 0, vehRot)
	addEventHandler("onMarkerHit", marker, bind(self.onMarkerHit, self))
	return marker
end

function JobLogistician:getRandomTargetMarker(sourceMarker)
	local markers = {}
	for name, marker in pairs(self.m_Markers) do
		if marker ~= sourceMarker then
			table.insert(markers, marker)
		end
	end

	return markers[math.random(1, #markers)]
end

function JobLogistician:onMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getOccupiedVehicle() and hitElement.vehicleSeat == 0 and hitElement:getOccupiedVehicle():getData("LogisticanVehicle") == true then
			local veh = hitElement:getOccupiedVehicle()
			if source.Crane then
				local crane = source.Crane
				veh:setPosition(source.VehPos)
				veh:setRotation(source.VehRot)
				if crane:getVehicleAttachedContainer(veh) then
					if source == hitElement:getData("Logistician:TargetMarker") then
						crane:dropContainer(veh, hitElement,
						function()
							local duration = getRealTime().timestamp - hitElement.m_LastJobAction
							hitElement.m_LastJobAction = getRealTime().timestamp
							outputDebug(getDistanceBetweenPoints3D(hitElement:getData("Logistician:LastCrane").m_Object:getPosition(), crane.m_Object:getPosition()))
							StatisticsLogger:getSingleton():addJobLog(hitElement, "jobLogistician", duration, self.m_MoneyPerTransport * JOB_PAY_MULTIPLICATOR, nil, nil, math.floor(10*JOB_EXTRA_POINT_FACTOR), nil)
							self.m_BankAccount:transferMoney({hitElement, true}, self.m_MoneyPerTransport * JOB_PAY_MULTIPLICATOR, "Logistiker Job", "Job", "Logistician")
							hitElement:givePoints(math.floor(10*JOB_EXTRA_POINT_FACTOR))
						end)
					else
						hitElement:sendError(_("Du bist am falschen Kran!", hitElement))
					end
				else
					if crane.m_Busy then
						hitElement:sendInfo(_("Der Kran ist aktuell beschäftigt! Bitte warte einen kleinen Moment!", hitElement))
					else
						crane:loadContainer(veh, hitElement)
						local target = self:getRandomTargetMarker(source)
						self:setNewDestination(hitElement, target, crane)
					end
				end
			else
				hitElement:sendError(_("Internal Error! No Crane settet to Marker!", hitElement))
			end
		else
			hitElement:sendError(_("Du sitzt in keinem Job Fahrzeug!", hitElement))
		end
	end
end


-- Crane class
Crane = inherit(Object)

function Crane:constructor(startX, startY, startZ, endX, endY, endZ, markerPos)
	self.m_StartX, self.m_StartY, self.m_StartZ = startX, startY, startZ -- position near truck
	self.m_EndX, self.m_EndY, self.m_EndZ = endX, endY, endZ -- position far away from truck
	self.m_Rotation = -math.deg(math.atan2(self.m_EndX-self.m_StartX, self.m_EndY-self.m_StartY))

	self.m_Object = createObject(3474, self.m_StartX, self.m_StartY, self.m_StartZ, 0, 0, self.m_Rotation)
	self.m_Tow = createObject(2917, self.m_StartX+0.5, self.m_StartY-0.7, self.m_StartZ+5, 0, 0, self.m_Rotation)
	--self.m_ColShape = createColSphere(self.m_StartX, self.m_StartY, self.m_StartZ, 10)
	self.m_Busy = false
end

function Crane:reset()
	self.m_Object:setPosition(self.m_StartX, self.m_StartY, self.m_StartZ)
	self.m_Object:setRotation(0, 0, self.m_Rotation)
	self.m_Tow:setPosition(self.m_StartX+0.5, self.m_StartY-0.7, self.m_StartZ+5)
	self.m_Tow:setRotation(0, 0, self.m_Rotation)
	self.m_Busy = false
	if self.m_Container and isElement(self.m_Container) then self.m_Container:destroy() end
end

function Crane:destructor()
	destroyElement(self.m_Object)
	destroyElement(self.m_Tow)
end

function Crane:dropContainer(vehicle, player, callback)
	if self.m_Busy then
		player:sendInfo(_("Der Kran ist aktuell beschäftigt! Bitte warte einen kleinen Moment!", player))
		return false
	end
	if getAttachedElements(vehicle)[1] and getElementType(getAttachedElements(vehicle)[1]) == "player" then
		player:sendError(_("Es darf sich kein Spieler am LKW festhalten!", player))
		return
	end

	self.m_Busy = true
	vehicle:setFrozen(true)
	toggleAllControls(player, false, true, false)

	if self.m_Timer and isTimer(self.m_Timer) then killTimer(self.m_Timer) end
	self.m_Timer = setTimer(function()
		self:reset()
	end, 35000, 1)

	-- First, roll down the tow
	self:rollTowDown(
		function()
			-- Grab the container
			local container = getAttachedElements(vehicle)[1]

			-- Detach it from the player's vehicle and attach it to the tow
			detachElements(container)
			attachElements(container, self.m_Tow, 0, 0, -4.1, 0, 0)
			vehicle:setFrozen(false)
			toggleAllControls(player, true, true, false)

			-- Roll up the tow
			self:rollTowUp(
				function()
					-- Move Crane to the "roll down platform"
					moveObject(self.m_Object, 10000, self.m_EndX, self.m_EndY, self.m_EndZ)

					-- Wait till we're at the target position
					setTimer(
						function(container)
							-- Roll down the tow
							self:rollTowDown(
								function()
									-- Destroy the container (behind a wall)
									destroyElement(container)

									self:rollTowUp(
										function()
											moveObject(self.m_Object, 10000, self.m_StartX, self.m_StartY, self.m_StartZ)
											if callback then callback() end
										end
									)
								end
							)
						end, 10000, 1, container
					)
				end
			)
		end
	)
	return true
end

function Crane:loadContainer(vehicle, player, callback)
	if self.m_Busy then
		player:sendInfo(_("Der Kran ist aktuell beschäftigt! Bitte warte einen kleinen Moment!", player))
		return false
	end
	self.m_Busy = true

	local container = createObject(math.random(2934, 2935), self.m_EndX, self.m_EndY-0.5, self.m_EndZ-4, 0, 0, self.m_Rotation)
	container:setScale(0.95)
	container:setCollisionsEnabled(false)	-- cause does not affect the collision model
	player.LogisticanContainer = container
	self.m_Container = container

	vehicle:setFrozen(true)
	toggleAllControls(player, false, true, false)

	-- Move Crane to the "container platform"
	moveObject(self.m_Object, 10000, self.m_EndX, self.m_EndY, self.m_EndZ)
	moveObject(self.m_Tow, 10000, self.m_EndX+0.5, self.m_EndY-0.7, self.m_EndZ+5)
	-- Wait till we're at the target position
	if self.m_Timer and isTimer(self.m_Timer) then killTimer(self.m_Timer) end
	self.m_Timer = setTimer(function()
		self:reset()
	end, 35000, 1)

	setTimer(
		function(container)
			-- Roll tow down
			self:rollTowDown(
				function()
					-- Attach container to tow and the roll up the tow
					attachElements(container, self.m_Tow, 0, 0, -4.1, 0, 0)

					self:rollTowUp(
						function()
							-- Move Crane to the start position
							moveObject(self.m_Object, 10000, self.m_StartX, self.m_StartY, self.m_EndZ)

							-- Wait till we're there
							setTimer(
								function(container)
									-- Roll tow down and load up the truck
									self:rollTowDown(
										function()
											if not isElement(container ) or not isElement(vehicle) then return end
											detachElements(container, self.m_Tow)
											attachElements(container, vehicle, 0, -1.7, 1.1)
											self.m_Container = nil
											vehicle:setFrozen(false)
											toggleAllControls(player, true, true, false)

											-- Roll up the tow a last time
											self:rollTowUp(
												function()
													if callback then callback() end
												end
											)
										end
									)
								end, 10000, 1, container
							)
						end
					)
				end
			)
		end, 10000, 1, container
	)
	return true
end

function Crane:rollTowDown(callback)
	-- Detach from Crane
	local x, y, z = getElementPosition(self.m_Tow)
	detachElements(self.m_Tow, self.m_Object)
	setElementPosition(self.m_Tow, x, y, z)

	-- Roll down the tow
	moveObject(self.m_Tow, 3000, x, y, z-5)
	if callback then
		setTimer(function() attachElements(self.m_Tow, self.m_Object, 0, 0, 0) callback() end, 3000, 1)
	end
end

function Crane:rollTowUp(callback)
	-- Detach from Crane
	local x, y, z = getElementPosition(self.m_Tow)
	detachElements(self.m_Tow, self.m_Object)

	-- Roll up the tow
	moveObject(self.m_Tow, 3000, x, y, z+5)
	if callback then
		setTimer(function() attachElements(self.m_Tow, self.m_Object, 0, 0, 5) callback() end, 3000, 1)
	end
end

function Crane:getVehicleAttachedContainer(veh)
	for index, element in pairs(veh:getAttachedElements()) do
		if element:getModel() == 2934 or element:getModel() == 2935 then
			return element
		end
	end
	return false
end

function Crane:isBusy()
	return self.m_Busy
end

function Crane:getPosition()
	return self.m_StartX, self.m_StartY, self.m_StartZ
end
