-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleManager.lua
-- *  PURPOSE:     Vehicle manager class
-- *
-- ****************************************************************************
VehicleManager = inherit(Singleton)
VehicleManager.sPulse = TimedPulse:new(5*1000)

function VehicleManager:constructor()
	self.m_TuningClasses =
	{
		["EngineKit"] = EngineTuning,
		["BrakeKit"] = BrakeTuning,
		["WheelKit"] = WheelTuning,
		["SuspensionKit"] = SuspensionTuning,
	}
	self.m_Vehicles = {}
	self.m_TemporaryVehicles = {}
	self.m_CompanyVehicles = {}
	self.m_GroupVehicles = {}
	self.m_FactionVehicles = {}
	self.m_VehiclesWithEngineOn = {}
	self.m_VehicleMarks = {}
	self.m_BankAccountServer = BankServer.get("server.vehicle")
	self:setSpeedLimits()

	-- Add events
	addRemoteEvents{"vehicleLock", "vehicleRequestKeys", "vehicleAddKey", "vehicleRemoveKey", "vehicleRepair", "vehicleRespawn", "vehicleRespawnWorld", "vehicleDelete",
	"vehicleSell", "vehicleSellAccept", "vehicleRequestInfo", "vehicleUpgradeGarage", "vehicleEmpty", "vehicleSyncMileage", "vehicleBreak", "vehicleBlow",
	"vehicleUpgradeHangar", "vehiclePark", "soundvanChangeURL", "soundvanStopSound", "vehicleToggleHandbrake", "onVehicleCrash","checkPaintJobPreviewCar",
	"vehicleGetTuningList", "adminVehicleEdit", "adminVehicleSetInTuning", "adminVehicleGetTextureList", "adminVehicleOverrideTextures", "vehicleLoadObject", "vehicleDeloadObject", "clientMagnetGrabVehicle", "clientToggleVehicleEngine",
	"clientToggleVehicleLight", "clientToggleHandbrake", "vehicleSetVariant", "vehicleSetTuningPropertyTable", "vehicleRequestHandling", "vehicleResetHandling", "requestVehicleMarks", "vehicleToggleLoadingRamp",
	"VehicleInfrared:onUse", "VehicleInfrared:onStop", "VehicleInfrared:onPlayerExit", "VehicleInfrared:onSyncLight", "VehicleInfrared:onCreateLight", "VehicleInfrared:onStopLight", "requestVehicles", "onToggleVehicleRegister",
	"toggleShamalInterior", "requestKeyList", "vehicleToggleRC"}

	addEventHandler("vehicleLock", root, bind(self.Event_vehicleLock, self))
	addEventHandler("vehicleRequestKeys", root, bind(self.Event_vehicleRequestKeys, self))
	addEventHandler("vehicleAddKey", root, bind(self.Event_vehicleAddKey, self))
	addEventHandler("vehicleRemoveKey", root, bind(self.Event_vehicleRemoveKey, self))
	addEventHandler("vehicleRepair", root, bind(self.Event_vehicleRepair, self))
	addEventHandler("vehicleRespawn", root, bind(self.Event_vehicleRespawn, self))
	addEventHandler("vehicleRespawnWorld", root, bind(self.Event_vehicleRespawnWorld, self))
	addEventHandler("vehicleDelete", root, bind(self.Event_vehicleDelete, self))
	addEventHandler("vehicleSell", root, bind(self.Event_vehicleSell, self))
	addEventHandler("vehicleSellAccept", root, bind(self.Event_acceptVehicleSell, self))
	addEventHandler("vehicleRequestInfo", root, bind(self.Event_vehicleRequestInfo, self))
	addEventHandler("vehicleUpgradeGarage", root, bind(self.Event_vehicleUpgradeGarage, self))
	addEventHandler("vehicleEmpty", root, bind(self.Event_vehicleEmpty, self))
	addEventHandler("vehicleSyncMileage", root, bind(self.Event_vehicleSyncMileage, self))
	addEventHandler("vehicleBreak", root, bind(self.Event_vehicleBreak, self))
	addEventHandler("vehicleBlow", root, bind(self.Event_vehicleBlow, self))
	addEventHandler("vehicleUpgradeHangar", root, bind(self.Event_vehicleUpgradeHangar, self))
	addEventHandler("vehiclePark", root, bind(self.Event_vehiclePark, self))
	addEventHandler("vehicleToggleHandbrake", root, bind(self.Event_toggleHandBrake, self))
	addEventHandler("soundvanChangeURL", root, bind(self.Event_soundvanChangeURL, self))
	addEventHandler("soundvanStopSound", root, bind(self.Event_soundvanStopSound, self))
	addEventHandler("onTrailerAttach", root, bind(self.Event_TrailerAttach, self))
	addEventHandler("onVehicleCrash", root, bind(self.Event_OnVehicleCrash, self))
	addEventHandler("vehicleGetTuningList",root,bind(self.Event_GetTuningList, self))
	addEventHandler("adminVehicleEdit",root,bind(self.Event_AdminEdit, self))
	addEventHandler("adminVehicleSetInTuning",root,bind(self.Event_AdminStartTuningSession, self))
	addEventHandler("adminVehicleGetTextureList",root,bind(self.Event_AdminGetTextureList, self))
	addEventHandler("adminVehicleOverrideTextures",root,bind(self.Event_AdminOverrideTextures, self))
	addEventHandler("vehicleLoadObject",root,bind(self.Event_LoadObject, self))
	addEventHandler("vehicleDeloadObject",root,bind(self.Event_DeLoadObject, self))
	addEventHandler("vehicleSetVariant", root, bind(self.Event_SetVariant, self))
	addEventHandler("clientMagnetGrabVehicle", root, bind(self.Event_MagnetVehicleCheck, self))
	addEventHandler("vehicleSetTuningPropertyTable", root, bind(self.Event_SetPerformanceTuningTable, self))
	addEventHandler("vehicleRequestHandling", root, bind(self.Event_GetVehicleHandling, self))
	addEventHandler("vehicleResetHandling", root, bind(self.Event_ResetVehicleHandling, self))
	addEventHandler("requestVehicleMarks", root, bind(self.Event_RequestVehicleMarks, self))
	addEventHandler("vehicleToggleLoadingRamp", root, bind(self.Event_ToggleLoadingRamp, self))
	addEventHandler("requestVehicles", root, bind(self.Event_requestVehicles, self))
	addEventHandler("onToggleVehicleRegister", root, bind(self.Event_toggleVehicleRegister, self))
	addEventHandler("toggleShamalInterior", root, bind(self.Event_toggleShamalInterior, self))
	addEventHandler("requestKeyList", root, bind(self.Event_requestKeyList, self))
	addEventHandler("vehicleToggleRC", root, bind(self.Event_vehicleToggleRC, self))

	addEventHandler("onVehicleExplode", root,
		function()
			if source.m_Magnet and source.m_GrabbedVehicle then
				source.m_MagnetActivated = false
				detachElements(source.m_GrabbedVehicle)
				setElementData(source, "MagnetGrabbedVehicle", nil)

				source.m_GrabbedVehicle:blow()
			end

			if source:getVehicleType() == "Helicopter" then
				for key, element in pairs(source:getAttachedElements()) do
					if element:getType() == "player" then
						if element.m_HelicopterDrivebyVehicle and element.m_HelicopterDrivebyVehicle == source then
							element:detach()
							element.m_HelicopterDrivebyVehicle = nil
							element.m_HelicopterDrivebySeat = nil
							element:setPublicSync("isDoingHelicopterDriveby", false)
						end
					end
				end
			end
		end
	)

	addEventHandler("clientToggleVehicleEngine", root,
		function()
			if client.vehicleSeat ~= 0 then return end
			client.vehicle:toggleEngine(client)
		end
	)

	addEventHandler("clientToggleVehicleLight", root,
		function()
			if client.vehicleSeat ~= 0 then return end
			client.vehicle:toggleLight(client)
		end
	)

	addEventHandler("clientToggleHandbrake", root,
		function()
			if client.vehicleSeat ~= 0 then return end

			if client.vehicle:hasKey(client) or
					client.vehicle:canObjectBeLoaded() or
					client.vehicle:getData("isGangwarVehicle") or
					(client.vehicle.isRcVehicle and client:getData("RcVehicle")) or
					client.vehicle:getData("Vehicle:Stolen") or
					(client.vehicle.importVehicle and client:getCompany() and client:getCompany():getId() == CompanyStaticId.EPT) or
					client:getRank() >= ADMIN_RANK_PERMISSION["looseVehicleHandbrake"]  then
				client.vehicle:toggleHandBrake(client)
			else
				client:sendError(_("Du hast kein Schlüssel für das Fahrzeug!", client))
			end
		end
	)

	addEventHandler("checkPaintJobPreviewCar", root, function()
		if client then
			local occVeh = getPedOccupiedVehicle(client)
			if occVeh then
				if occVeh.m_Owner == client:getId() then
					triggerClientEvent("onClientPreviewVehicleChecked", client, occVeh)
				end
			end
		end
	end)
	-- Check Licenses
	addEventHandler("onVehicleStartEnter", root,
		function (player, seat)
			if player:getType() ~= "player" then return end

			if source:isAttached() and not source.m_CurrentlyAttachedToTransporter then -- If the vehicle is attached to a magnet helicopter
				return cancelEvent()
			end
			if source:getData("Burned") then -- if the vehicle is left from a fire
				return cancelEvent()
			end

			if seat == 0 then
				self:checkVehicle(source)

				if not source:isLocked() then
					local vehicleType = source:getVehicleType()
					if (vehicleType == VehicleType.Plane or vehicleType == VehicleType.Helicopter) and not player:hasPilotsLicense() and not player:getPublicSync("inDrivingLession") == true then
						player:removeFromVehicle(source)
						player:setPosition(source.matrix:transformPosition(-1.5, 5, 0))
						player:sendShortMessage(_("Du hast keinen Flugschein!", player))
					elseif vehicleType == Vehicle.Automobile and not player:hasDrivingLicense() then
						player:sendShortMessage(_("Du hast keinen Führerschein! Lass dich nicht erwischen!", player))
					end
				end
				
				if player:getPublicSync("cuffed") then
					cancelEvent()
				end
			end
		end
	)

	-- Prevent the engine from being turned on
	addEventHandler("onVehicleEnter", root,
		function(player, seat, jackingPlayer)
			if player:getType() ~= "player" then return end
			if seat == 0 then
				self:checkVehicle(source)
				source.m_LastMileageCheck = getTickCount() -- this is probably close to the enter time at which the client starts measuring the mileage, only for anti-cheat
				setVehicleEngineState(source, source:getEngineState())
			end
		end
	)

	addEventHandler("VehicleInfrared:onPlayerExit", root, function(vehicle)
		if client then
			if vehicle and isValidElement(vehicle, "vehicle") and vehicle ~= client.vehicle then
				if vehicle.m_InfraredUsedBy and vehicle.m_InfraredUsedBy == client then
					vehicle.m_InfraredUsedBy = nil
				end
			end
			client:setData("inInfraredVehicle", false, true)
		end
	end)

	addEventHandler("VehicleInfrared:onUse", root, function()
		if client and client.vehicle then
			if client.vehicle.hasInfrared and client.vehicle:hasInfrared() then
				if not isValidElement(client.vehicle.m_InfraredUsedBy, "player") then
					client.vehicle.m_InfraredUsedBy = client
					client:setData("inInfraredVehicle", true, true)
					client:triggerEvent("VehicleInfrared:start", client.vehicle)
				else
					if not client.vehicle.m_InfraredUsedBy.vehicle or client.vehicle.m_InfraredUsedBy.vehicle ~= client.vehicle then
						client.vehicle.m_InfraredUsedBy:setData("inInfraredVehicle", false, true)
						client.vehicle.m_InfraredUsedBy = client
						client:setData("inInfraredVehicle", true, true)
						client:triggerEvent("VehicleInfrared:start", client.vehicle)
					else
						if client.vehicle.m_InfraredUsedBy ~= client then
							client:sendError(_("Die Kamera wird zurzeit von %s bedient!", client, client.vehicle.m_InfraredUsedBy:getName()))
						end
					end
				end
			end
		end
	end)

	addEventHandler("VehicleInfrared:onStop", root, function(vehicle)
		if client and client.vehicle then
			if client.vehicle.hasInfrared and client.vehicle:hasInfrared() then
				client:setData("inInfraredVehicle", false, true)
				client.vehicle.m_InfraredUsedBy = nil
			end
			client:triggerEvent("VehicleInfrared:stop")
		end
	end)


	addEventHandler("VehicleInfrared:onSyncLight", root, function(vehicle, data)
		triggerLatentClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "VehicleInfrared:updateLight", vehicle, vehicle, data[1], data[2])
	end)

	addEventHandler("VehicleInfrared:onCreateLight", root, function(vehicle, data)
		triggerLatentClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "VehicleInfrared:createLight", vehicle, vehicle, data[1], data[2])
	end)


	addEventHandler("VehicleInfrared:onStopLight", root, function(vehicle)
		triggerLatentClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "VehicleInfrared:stopLight", vehicle, vehicle)
	end)

	addEventHandler("onElementModelChange", root, function(old, new)
		if source.type == "vehicle" then
			if instanceof(source, PermanentVehicle) then
				if old == 519 then
					source:delShamalExtension()
				elseif new == 519 then
					source:initShamalExtension()
				end

				if VEHICLE_MAX_PASSENGER[old] then
					source:delVehicleSeatExtension()
				end
				
				if VEHICLE_MAX_PASSENGER[new] then
					source:initVehicleSeatExtension()
				end

				if old == 459 then
					source:delRcVanExtension()
				elseif new == 459 then
					source:initRcVanExtension()
				end
			end
		end
	end)

	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			if player:getData("inInfraredVehicle") then
				player:setData("inInfraredVehicle", false, true)
				player:triggerEvent("VehicleInfrared:onWasted")
			end
			if player:getData("SE:InShamal") then
				player:getData("VSE:Vehicle"):seEnterExitInterior(player, "death")
            end
			if player:getData("VSE:IsPassenger") then
				player:getData("VSE:Vehicle"):vseEnterExit(player, "death")
			end
			if player:getData("RcVehicle") then
				player:getData("RCVan"):toggleRC(player, player:getData("RcVehicle"), false, true, true)
			end
		end
	)

	PlayerManager:getSingleton():getQuitHook():register(
		function(player)
			if player:getData("SE:InShamal") then
				player:getData("VSE:Vehicle"):seEnterExitInterior(player, "quit")
            end
			if player:getData("VSE:IsPassenger") then
				player:getData("VSE:Vehicle"):vseEnterExit(player, false)
			end
			if player:getData("RcVehicle") then
				player:getData("RCVan"):toggleRC(player, player:getData("RcVehicle"), false, true)
			end
		end
	)

    core:getStopHook():register(
        function()
            for i, player in pairs(getElementsByType("player")) do
				if player:getData("SE:InShamal") then
					player:getData("VSE:Vehicle"):seEnterExitInterior(player, "quit")
				end
				if player:getData("VSE:IsPassenger") then
					player:getData("VSE:Vehicle"):vseEnterExit(player, false)
				end
				if player:getData("RcVehicle") then
					player:getData("RCVan"):toggleRC(player, player:getData("RcVehicle"), false)
				end
            end
        end
    )

	VehicleManager.sPulse:registerHandler(bind(VehicleManager.removeUnusedVehicles, self))

	setTimer(bind(self.updateFuelOfPermanentVehicles, self), 60*1000, 0)

	self.NonOptionalTextures = --// Textures that cant be toggled off
	{
		FactionVehicle,
		CompanyVehicle,l
	}

	--[[
	sql:queryExec("DROP TABLE IF EXISTS ??_vehicles", sql:getPrefix())
	sql:queryExec("DROP TABLE IF EXISTS ??_vehicles_old", sql:getPrefix())

	sql:queryExec("CREATE TABLE ??_vehicles LIKE ??_vehicles_test; INSERT ??_vehicles SELECT * FROM ??_vehicles_test;",
		sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), sql:getPrefix())
	]]

	if sql:queryFetchSingle("SHOW COLUMNS FROM ??_vehicles WHERE Field = 'Owner';", sql:getPrefix()) then
		self:migrate()
	end

	TuningTemplateManager:new()

	setTimer(bind(self.destroyInactiveVehicles, bind), 3600000, 0)
end

function VehicleManager:destructor()
	local st, count = getTickCount(), 0
	for ownerId, vehicles in pairs(self.m_Vehicles) do
		for k, vehicle in ipairs(table.reverse(vehicles)) do
			vehicle:destroy()
			count = count + 1
		end
	end
	self.m_Vehicles = {}
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s private_vehicles in %sms"):format(count, getTickCount()-st)) end

	local st, count = getTickCount(), 0
	for companyId, vehicles in pairs(self.m_CompanyVehicles) do
		for k, vehicle in ipairs(table.reverse(vehicles)) do
			vehicle:destroy()
			count = count + 1
		end
	end
	self.m_CompanyVehicles = {}
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s company_vehicles in %sms"):format(count, getTickCount()-st)) end

	local st, count = getTickCount(), 0
	for groupId, vehicles in pairs(self.m_GroupVehicles) do
		for k, vehicle in ipairs(table.reverse(vehicles)) do
			vehicle:destroy()
			count = count + 1
		end
	end
	self.m_GroupVehicles = {}
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s group_vehicles in %sms"):format(count, getTickCount()-st)) end

	local st, count = getTickCount(), 0
	for factionId, vehicles in pairs(self.m_FactionVehicles) do
		for k, vehicle in ipairs(table.reverse(vehicles)) do
			vehicle:destroy()
			count = count + 1
		end
	end
	self.m_FactionVehicles = {}
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s faction_vehicles in %sms"):format(count, getTickCount()-st)) end
end

function VehicleManager:getServerBankAccount()
	return self.m_BankAccountServer
end

function VehicleManager:Event_OnRadioChange(vehicle, radio)
	if vehicle and radio then

	end
end

function VehicleManager:Event_GetTuningList()
	source:getTuningList(client)
end

function VehicleManager:Event_AdminEdit(vehicle, changes)
	local hasToBeSaved = false

	if changes.Model then
		if client:getRank() < ADMIN_RANK_PERMISSION["editVehicleModel"] then client:sendError(_("Du hast nicht genügend Rechte!", client)) return false end
		local oldModel = vehicle:getModel()
		vehicle:setModel(changes.Model)
		vehicle.m_BuyPrice = OLD_VEHICLE_PRICES[changes.Model] or -1
		StatisticsLogger:getSingleton():addAdminVehicleAction(client, "changeModel", vehicle, oldModel.." -> "..(changes.Model))
		hasToBeSaved = true
	end

	if changes.ELS then
		if client:getRank() < ADMIN_RANK_PERMISSION["editVehicleModel"] then client:sendError(_("Du hast nicht genügend Rechte!", client)) return false end
		vehicle:removeELS()
		if changes.ELS ~= "__REMOVE" then
			vehicle:setELSPreset(changes.ELS)
		end
		StatisticsLogger:getSingleton():addAdminVehicleAction(client, "changeELS", vehicle, changes.ELS)
		client:sendSuccess(_("ELS aktualisiert", client))
		hasToBeSaved = true
	end

	--[[if changes.OwnerID then Note by MasterM: oh shit this code is so stupid, please shoot me so that I never have to look at it again
		if vehicle.m_OwnerType == VehicleTypes.Player then -- check if the player is online

		elseif vehicle.m_OwnerType == VehicleTypes.Group then -- check if the group is loaded

		elseif vehicle.m_OwnerType == VehicleTypes.Company then -- just change the company
			if table.removevalue(self.m_CompanyVehicles[vehicle.m_Owner], vehicle) then
				table.insert(self.m_CompanyVehicles[changes.OwnerID], vehicle)
				vehicle.m_Owner = changes.OwnerID
			end
		elseif vehicle.m_OwnerType == VehicleTypes.Faction then -- just change the faction
			if table.removevalue(self.m_FactionVehicles[vehicle.m_Owner], vehicle) then
				table.insert(self.m_FactionVehicles[changes.OwnerID], vehicle)
				vehicle.m_Owner = changes.OwnerID
			end
		end
	end]]

	if hasToBeSaved and instanceof(vehicle, PermanentVehicle) then
		vehicle:saveAdminChanges()
	end
end

function VehicleManager:Event_AdminStartTuningSession(vehicle)
	if client:getRank() < ADMIN_RANK_PERMISSION["editVehicleTunings"] then client:sendError(_("Du hast nicht genügend Rechte!", client)) return false end
	if vehicle:getOccupantsCount() > 0 then
		for i,v in pairs(vehicle:getOccupants()) do
			v:removeFromVehicle()
		end
	end
	client:warpIntoVehicle(vehicle)
	VehicleTuningShop:getSingleton():openForAdmin(client, vehicle)
end

function VehicleManager:Event_AdminGetTextureList(vehicle)
	client:triggerEvent("vehicleAdminReceiveTextureList", vehicle, vehicle.m_Tunings.m_Tuning.Texture)
end

function VehicleManager:Event_AdminOverrideTextures(vehicle, texture)
	if client:getRank() >= ADMIN_RANK_PERMISSION["editVehicleTexture"] then
		if vehicle.m_Tunings then
			vehicle.m_Tunings:overrideTextures(texture)
			vehicle.m_Tunings:applyTuning()
		else
			client:sendError(_("Dieses Fahrzeug hat kein Tuning!", client))
		end
	end
end

function VehicleManager:Event_MagnetVehicleCheck(groundPosition)
	source:magnetVehicleCheck(groundPosition)
end

function VehicleManager:Event_GetVehicleHandling( vehicle )
	client:triggerEvent("updateVehicleHandling", vehicle, vehicle:getHandling())
end

function VehicleManager:Event_ResetVehicleHandling( )
	local vehicle = client:getOccupiedVehicle() or client:getContactElement()
	if vehicle and isElement(vehicle) and getElementType(vehicle) == "vehicle" then
		if vehicle.m_Tunings then
			vehicle.m_Tunings:removeAllTuningKits()
			client:sendInfo(_("Fahrzeug wurde zurückgesetzt!", client, name))
		end
	end
end

function VehicleManager:Event_SetPerformanceTuningTable( vehicle, tuningTable, reset )
	if not vehicle.m_Tunings then
        vehicle.m_Tunings = VehicleTuning:new(vehicle)
    end
	vehicle.m_Tunings:setPerformanceTuningTable( tuningTable, client, reset )
end

function VehicleManager:getFactionVehicles(factionId)
	return self.m_FactionVehicles[factionId] or {}
end

function VehicleManager:getCompanyVehicles(companyId)
	return self.m_CompanyVehicles[companyId] or {}
end

function VehicleManager:getGroupVehicles(groupId)
	return self.m_GroupVehicles[groupId] or {}
end

function VehicleManager:getPlayerVehicleById(playerId, vehicleId)
	for _, vehicle in pairs(self:getPlayerVehicles(playerId)) do
		if vehicle:getId() == vehicleId then
			return vehicle
		end
	end
end

function VehicleManager:createNewVehicle(ownerId, ownerType, model, posX, posY, posZ, rotX, rotY, rotZ, premium, shopIndex, price, template)
	-- owner, model, posX, posY, posZ, rotX, rotY, rotation, trunkId, premium
	if type(ownerId) == "userdata" then
		ownerId = ownerId:getId()
		ownerType = VehicleTypes.Player
	end

	assert(VehicleTypeName[ownerType], "Invalid vehicle type")
	local rotX = rotX or 0
	local rotY = rotY or 0
	local rotZ = rotZ or 0
	local premium = premium or 0
	local price = price or 0
	local shopIndex = shopIndex or 1

	if sql:queryExec("INSERT INTO ??_vehicles (OwnerId, OwnerType, Model, PosX, PosY, PosZ, RotX, RotY, RotZ, Interior, Dimension, Premium, `Keys`, BuyPrice, ShopIndex) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?, '[[]]', ?, ?)", sql:getPrefix(), ownerId, ownerType, model, posX, posY, posZ, rotX, rotY, rotZ, premium, price, shopIndex) then
		return self:createVehicle(sql:lastInsertId(), template)
	end
	return false
end

function VehicleManager:createVehicle(idOrData, handlingTemplate)
	local data = {}
	if type(idOrData) == "number" then
		data = sql:queryFetchSingle("SELECT * FROM ??_vehicles WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), idOrData)
	else
		data = idOrData
	end

	if data then
		local vehicle = createVehicle(data.Model, data.PosX, data.PosY, data.PosZ, data.RotX or 0, data.RotY or 0, data.RotZ or 0)
		local typeClass = PermanentVehicle

		if data.OwnerType == VehicleTypes.Faction then
			typeClass = FactionVehicle
		elseif data.OwnerType == VehicleTypes.Company then
			typeClass = CompanyVehicle
		elseif data.OwnerType == VehicleTypes.Group then
			typeClass = GroupVehicle
		end

		enew(vehicle, typeClass, data)
		self:addRef(vehicle, false)
		if vehicle:getDimension() ~= PRIVATE_DIMENSION_SERVER then -- don't set interior and dimension if it is already despawned
			vehicle:setInterior(data.Interior or 0)
			vehicle:setDimension(data.Dimension or 0)
		end
		vehicle:setHealth(data.Health)
		if data.Health <= VEHICLE_TOTAL_LOSS_HEALTH then
			vehicle:setBroken(true)
		end
		if handlingTemplate then
			local template = TuningTemplateManager:getSingleton():getTemplateFromId( handlingTemplate )
			if template then
				template:applyTemplate(vehicle)
			end
		end
		local pershingSquareSpecialCase = false
		if data.PosX > 1399.40 and data.PosX <= 1559 then
			if data.PosY > -1835 and data.PosY < -1742 then
				if data.PosZ > 12 and data.PosZ < 25 then
					vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
					vehicle.despawned = true
					pershingSquareSpecialCase = true
				end
			end
		end
		return vehicle, pershingSquareSpecialCase
	else
		return false
	end
end

function VehicleManager:createVehiclesForPlayer(player)
	if player then
		local id = player:getId()
		if id then
			if not self.m_Vehicles[id] then
				self.m_Vehicles[id] = {}
			end
			local result = sql:queryFetch("SELECT * FROM ??_vehicles WHERE OwnerId = ? AND OwnerType = ? AND Deleted IS NULL", sql:getPrefix(), id, VehicleTypes.Player)
			local vehicleObj
			local skip = false
			for i, row in pairs( result ) do
				for i = 1, #self.m_Vehicles[id] do
					vehicleObj = self.m_Vehicles[id][i]
					if vehicleObj then
						if vehicleObj.m_Id == row.Id then
							skip = true
						end
					end
				end
				if not skip then
					local veh, specialcase = self:createVehicle(row)
					if veh and specialcase then
						player:sendShortMessage(_("Dein Fahrzeug %s wurde nicht gespawnt, da es sich im Pershing Square befindet, melde dich bei einem Administrator und parke es um!", player, getVehicleNameFromModel(veh:getModel())),  "Information", nil, 30000)
					end
				end
				skip = false
			end
		end
	end
end

function VehicleManager:destroyUnusedVehicles( player )
	if player then
		local vehTable = self:getPlayerVehicles(player)
		if vehTable then
			local tempTable = {}
			for k, vehicle in ipairs(vehTable) do
				tempTable[k] = vehicle
			end
			local counter = 0
			for k , vehicle in pairs(tempTable) do
				if vehicle then
					if vehicle.m_HasBeenUsed then
						if vehicle.m_HasBeenUsed == 0 then
							if vehicle:getModel() == 459 then vehicle:delRcVanExtension() end
							destroyElement(vehicle)
							counter = counter + 1
						end
					end
				end
			end
			--outputDebugString("[Vehicle-Manager] Cleaned "..counter.." vehicles for player "..getPlayerName(player).."!",3,0,200,0)
			--outputServerLog("[Vehicle-Manager] Cleaned "..counter.." vehicles for player "..getPlayerName(player).."!",3,0,200,0)
		end
	end
end

function VehicleManager.loadVehicles()
	local st, count = getTickCount(), 0
	local result = sql:queryFetch("SELECT * FROM ??_vehicles WHERE OwnerType = ? AND Deleted IS NULL", sql:getPrefix(), VehicleTypes.Company)
	for i, row in pairs(result) do
		VehicleManager:getSingleton():createVehicle(row)
		--[[
		local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, row.RotX, row.RotY, row.Rotation)
		enew(vehicle, CompanyVehicle, tonumber(row.Id), CompanyManager:getSingleton():getFromId(row.Company), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage, row.Fuel, row.ELSPreset)
		VehicleManager:getSingleton():addRef(vehicle, false)]]
		count = count + 1
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s company_vehicles in %sms"):format(count, getTickCount()-st)) end

	local st, count = getTickCount(), 0
	local result = sql:queryFetch("SELECT * FROM ??_vehicles WHERE OwnerType = ? AND Deleted IS NULL", sql:getPrefix(), VehicleTypes.Faction)
	for i, row in pairs(result) do
		if FactionManager:getFromId(row.OwnerId) then
			VehicleManager:getSingleton():createVehicle(row)
			--[[local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, row.RotX, row.RotY, row.Rotation)
			enew(vehicle, FactionVehicle, tonumber(row.Id), FactionManager:getFromId(row.Faction), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage, row.handling, fromJSON(row.decal), row.Fuel, row.ELSPreset)
			VehicleManager:getSingleton():addRef(vehicle, false)]]
			count = count + 1
		end
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s faction_vehicles in %sms"):format(count, getTickCount()-st)) end
end

function VehicleManager:addRef(vehicle, isTemp)
	if isTemp then
		self.m_TemporaryVehicles[#self.m_TemporaryVehicles+1] = vehicle
		return
	end
	if instanceof(vehicle, CompanyVehicle) then
		local companyId = vehicle:getCompany() and vehicle:getCompany():getId()
		assert(companyId, "Bad company specified")

		if not self.m_CompanyVehicles[companyId] then
			self.m_CompanyVehicles[companyId] = {}
		end

		table.insert(self.m_CompanyVehicles[companyId], vehicle)
		return
	end
	if instanceof(vehicle, GroupVehicle) then
		local groupId = vehicle:getGroup() and vehicle:getGroup():getId()
		assert(groupId, "Bad group specified")

		if not self.m_GroupVehicles[groupId] then
			self.m_GroupVehicles[groupId] = {}
		end

		table.insert(self.m_GroupVehicles[groupId], vehicle)
		return
	end
	if instanceof(vehicle, FactionVehicle) and vehicle:getFaction() then
		local factionId = vehicle:getFaction() and vehicle:getFaction():getId()
		assert(factionId, "Bad owner specified")

		if not self.m_FactionVehicles[factionId] then
			self.m_FactionVehicles[factionId] = {}
		end

		table.insert(self.m_FactionVehicles[factionId], vehicle)
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")

	if not self.m_Vehicles[ownerId] then
		self.m_Vehicles[ownerId] = {}
	end

	table.insert(self.m_Vehicles[ownerId], vehicle)
end

function VehicleManager:removeRef(vehicle, isTemp)
	if isTemp then
		local idx = table.find(self.m_TemporaryVehicles, vehicle)
		if idx then
			table.remove(self.m_TemporaryVehicles, idx)
		end
		return
	end
	if instanceof(vehicle, CompanyVehicle) and vehicle:getCompany() then
		local companyId = vehicle:getCompany() and vehicle:getCompany():getId()
		assert(companyId, "Bad company specified")

		if self.m_CompanyVehicles[companyId] then
			local idx = table.find(self.m_CompanyVehicles[companyId], vehicle)
			if idx then
				table.remove(self.m_CompanyVehicles[companyId], idx)
			end
		end
		return
	end

	if instanceof(vehicle, GroupVehicle) and vehicle:getGroup() then
		local groupId = vehicle:getGroup() and vehicle:getGroup():getId()
		assert(groupId, "Bad company specified")

		if self.m_GroupVehicles[groupId] then
			local idx = table.find(self.m_GroupVehicles[groupId], vehicle)
			if idx then
				table.remove(self.m_GroupVehicles[groupId], idx)
			end
		end
		return
	end

	if instanceof(vehicle, FactionVehicle) and vehicle:getFaction() then
		local factionId = vehicle:getFaction() and vehicle:getFaction():getId()
		assert(factionId, "Bad faction specified")

		if self.m_FactionVehicles[factionId] then
			local idx = table.find(self.m_FactionVehicles[factionId], vehicle)
			if idx then
				table.remove(self.m_FactionVehicles[factionId], idx)
			end
		end
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")

	if self.m_Vehicles[ownerId] then
		local idx = table.find(self.m_Vehicles[ownerId], vehicle)
		if idx then
			table.remove(self.m_Vehicles[ownerId], idx)
		end
	end
end

function VehicleManager:removeUnusedVehicles()
	-- ToDo: Lateron, do not loop through all vehicles
	for ownerid, data in pairs(self.m_Vehicles) do
		for k, vehicle in pairs(data) do
			if vehicle:isBlown() then
				if vehicle:getVehicleType() == VehicleType.Automobile or vehicle:getVehicleType() == VehicleType.Bike then
					outputDebug("Respawning blown vehicle in mechanic base")
					vehicle:setPositionType(VehiclePositionType.Mechanic)
					vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
					respawnVehicle(vehicle)

					CompanyManager:getSingleton():getFromId(2):addLog(nil, "Respawn-Log", ("%s von %s wurde zerstört und respawnt!"):format(vehicle:getName(), Account.getNameFromId(vehicle:getOwner()) or "-"))
				else
					vehicle:respawn()
				end
			end
		end
	end

	for k, vehicle in pairs(self.m_TemporaryVehicles) do
		if vehicle and isElement(vehicle) then
			if vehicle:isRespawnAllowed() then
				if vehicle:getHealth() < 0.1 and vehicle:getLastUseTime() < getTickCount() - 1*60*1000 then
					vehicle:respawn()
				else
					if vehicle:getLastUseTime() < getTickCount() - 2*60*1000 then
						if vehicle:getModel() == 435 then
							if vehicle:getTowingVehicle() then
								return
							end
						end

						vehicle:respawn()
					end
				end
			end
		else
			self.m_TemporaryVehicles[k] = nil
		end
	end
end

function VehicleManager:getPlayerVehicles(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	return self.m_Vehicles[player] or {}
end

function VehicleManager:savePlayerVehicles(player)
	for k, vehicle in pairs(self:getPlayerVehicles(player)) do
		vehicle:save()
	end
end

function VehicleManager:refreshGroupVehicles(group)
	local groupId = group:getId()
	if not groupId then
		outputDebug("VehicleManager:refreshGroupVehicles: Group-Id Not Found!")
		return
	end
	-- Delete old Group Vehicles
	self:destroyGroupVehicles(group)

	-- Reload Group Vehicles from DB
	self:loadGroupVehicles(group)
end

function VehicleManager:destroyGroupVehicles(group)
	local groupId = group:getId()
	if not groupId then
		outputDebug("VehicleManager:destroyGroupVehicles: Group-Id Not Found!")
		return
	end

	if self.m_GroupVehicles[groupId] then
		for index, veh in pairs(table.copy(self.m_GroupVehicles[groupId])) do
			if not veh.m_IsRented then
				if veh.m_ForSale then triggerClientEvent("groupSaleVehiclesDestroyBubble", root, veh) end
				if veh.m_ForRent then triggerClientEvent("groupRentVehiclesDestroyBubble", root, veh) end
				if veh:getModel() == 459 then veh:delRcVanExtension() end
				table.removevalue(self.m_GroupVehicles, veh)

				veh:save()
				veh:destroy()
			end
		end
	end
	-- self.m_GroupVehicles[groupId] = {}
end

function VehicleManager:loadGroupVehicles(group)
	local groupId = group:getId()
	if not groupId then
		outputDebug("VehicleManager:loadGroupVehicles: Group-Id Not Found!")
		return
	end

	local result = sql:queryFetch("SELECT * FROM ??_vehicles WHERE OwnerId = ? AND OwnerType = ? AND Deleted IS NULL", sql:getPrefix(), groupId, VehicleTypes.Group)
	for i, row in pairs(result) do
		if GroupManager:getFromId(row.OwnerId) then
			local found = false -- Check if vehicle is already spawned
			for i2, veh in pairs(self.m_GroupVehicles[row.OwnerId] or {}) do
				if veh.m_Id == row.Id then
					found = true
					break
				end
			end
			if not found then
				self:createVehicle(row)
			end
		else
			sql:queryExec("UPDATE ??_vehicles SET Deleted = NOW() WHERE ID = ?", sql:getPrefix(), row.Id)
		end
	end
end

function VehicleManager:updateFuelOfPermanentVehicles() -- gets called every min
	for veh, mileage in pairs(self.m_VehiclesWithEngineOn) do --table gets managed on engine switch in Vehicle class
		if veh and isElement(veh) and veh.getEngineState and veh.getFuel and veh.getSpeed and veh:getEngineState() then
			local curVel = (veh:getMileage()-mileage)/1000*60 --60 because we want km/h from km/min
			if curVel == 0 then -- fallback on updating with speed if mileage did not change
				curVel = veh:getSpeed()
			end
			local mass = veh:getHandling()["mass"]
			local consumptionMultiplicator = veh:getFuelConsumptionMultiplicator() or 1 -- returns boolean for temporaryVehicles
			local cons = ((curVel/50 * consumptionMultiplicator) + mass/5000) --basic consumption based on speed and mass (in liter)
			local vehFuelSize = veh:getFuelTankSize() or 1
			veh:setFuel(veh:getFuel() - cons/vehFuelSize*100)
			--outputDebug(veh, "liter", cons, "curVel", curVel, "mass", mass)
			self.m_VehiclesWithEngineOn[veh] = veh:getMileage()
		else --garbage collection
			self.m_VehiclesWithEngineOn[veh] = nil
		end
	end
end

function VehicleManager:checkVehicle(vehicle)
	-- Lightweight instanceof(vehicle, Vehicle)
	if not vehicle.toggleLight then
		-- Make a temporary vehicle if vehicle is not yet instance of any class
		enew(vehicle, TemporaryVehicle)
	end
end

function VehicleManager:Event_vehiclePark()
 	if not source or not isElement(source) then return end
 	self:checkVehicle(source)
	if source:isPermanent() or instanceof(source, GroupVehicle) then
		if source:hasKey(client) or client:getRank() >= ADMIN_RANK_PERMISSION["parkVehicle"] then
			if source:isBroken() then
				client:sendError(_("Dein Fahrzeug ist kaputt und kann nicht geparkt werden!", client))
				return
			end

			if (instanceof(source, GroupVehicle) and not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "group", "vehiclePark")) then
				client:sendError(_("Du bist nicht berechtigt Gruppen-Fahrzeuge zu parken.", client))
				return
			end
			
			if not source:isOnGround() then
				client:sendError(_("Das Fahrzeug muss zum Parken stillstehen!", client))
				return
			end

			if source:isInGarage() then
				source:setCurrentPositionAsSpawn(VehiclePositionType.Garage)
				client:sendInfo(_("Du hast das Fahrzeug erfolgreich in der Garage geparkt!", client))
				return
			end

			-- enable parking in interiors for team members only (e.g. auction interior)
			if source:getInterior() == 0 or source.m_InParkGarage or client:getRank() >= ADMIN_RANK_PERMISSION["parkVehicle"] then
				source:setCurrentPositionAsSpawn(VehiclePositionType.World)
				client:sendInfo(_("Du hast das Fahrzeug erfolgreich geparkt!", client))
				
				if  instanceof(source, GroupVehicle) and (source:getGroup() and client:getGroup()) and (source:getGroup() == client:getGroup()) then
					client:getGroup():addLog(client, "Fahrzeuge", ("hat das Fahrzeug %s (%d) umgeparkt!"):format(source:getName(), source:getId()))
				end

			else
				client:sendError(_("Du kannst dein Fahrzeug hier nicht parken!", client))
			end
		else
			client:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug", client))
		end
	else
		client:sendError(_("Dieses Fahrzeug kann nicht geparkt werden!", client))
	end
 end

function VehicleManager:Event_toggleHandBrake()
	if not source.m_HandBrake then return client:sendError(_("Die Handbremse ist nicht angezogen!", client)) end
	
	if client:getCompany() and client:getCompany():getId() == CompanyStaticId.MECHANIC and client:isCompanyDuty() then
		if getElementData(source, "forSale") then
			source:setForSale(false, 0)
		end
		if getElementData(source, "forRent") then
			source:setForRent(false, 0)
		end
		client:getCompany():addLog(client, "Handbremsen-Logs", ("hat eine Handbremse gelöst. %s von %s"):format(source:getName(), getElementData(source, "OwnerName") or "Unbekannt"))
	elseif client:getRank() >= ADMIN_RANK_PERMISSION["looseVehicleHandbrake"] then
		StatisticsLogger:getSingleton():addAdminVehicleAction(client, "looseHandbrake", source)
	else
		client:sendError(_("Du bist nicht berechtigt!", client))
		return
	end

	source:toggleHandBrake(client)
	client:sendSuccess(_("Die Handbremse wurde gelöst!", client))
end

function VehicleManager:setSpeedLimits()
	setModelHandling(451, "maxVelocity", 260) -- Turismo
	setModelHandling(462, "maxVelocity", 50) -- Faggio
	setModelHandling(509, "maxVelocity", 50) -- Bike
	setModelHandling(481, "maxVelocity", 50) -- BMX
	setModelHandling(510, "maxVelocity", 50) -- Mountain Bike
end

function VehicleManager:syncVehicleInfo(player)
	player:triggerEvent("vehicleRetrieveInfo", self:getVehiclesFromPlayer(player), player:getGarageType(), player:getHangarType())
end

function VehicleManager:Event_OnVehicleCrash(loss)
	if not source then return end
	if source:getVehicleType() == VehicleType.Plane or source:getVehicleType() == VehicleType.Helicopter or source:getVehicleType() == VehicleType.Bike then
		return false
	end
	if source:getDamageHook() and source:getDamageHook():call(source, loss) then
		return false
	end
	local occupants = getVehicleOccupants(source)
	local speedx, speedy, speedz = getElementVelocity(source)
	local sForce = (speedx^2 + speedy^2 + speedz^2)^(0.5)
	local tickCount = getTickCount()
	if client.vehicle == source then
		if sForce >0.4 and loss*0.1 >= 2  then
			for seat, player in pairs(occupants) do
				if getElementType(player) == "player" then
					local playerHealth = getElementHealth(player)
					local bIsKill = (playerHealth - loss*0.02)  <= 0
					if not player.m_SeatBelt then
						if not bIsKill then
							setElementHealth(player, playerHealth - loss*0.02)
						else
							setElementHealth(player, 1)
						end
					end
					if sForce < 0.85 then
						if not player.m_lastInjuryMe then
							player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
							player.m_lastInjuryMe = tickCount
						elseif player.m_lastInjuryMe + 5000 <= tickCount then
							player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
							player.m_lastInjuryMe = tickCount
						end
						setPedAnimation(player, "ped", "hit_walk",700,true,false,false)
						setTimer(setPedAnimation, 700,2, player, nil)
					elseif sForce >= 0.85 then
						if not player.m_SeatBelt then
							player:meChat(true, "erleidet innere Blutungen durch den Aufprall!")
							if  source:getVehicleType() ~= VehicleType.Bike and not VEHICLE_BIKES[source] then
								removePedFromVehicle(player) -- causes network trouble for the client
								setPedAnimation(player, "crack", "crckdeth2", 5000, false, false, false)
								setTimer(setPedAnimation, 5000,1, player, nil)
							end
						elseif player.m_SeatBelt == source then
							if not player.m_lastInjuryMe then
								player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
								player.m_lastInjuryMe = tickCount
							elseif player.m_lastInjuryMe + 5000 <= tickCount then
								player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
								player.m_lastInjuryMe = tickCount
							end
						end
					end
					player:triggerEvent("clientBloodScreen")
				end
			end
		end
	end
end

function VehicleManager:getVehiclesFromPlayer()
	local vehicles = {}
	for k, vehicle in pairs(self:getPlayerVehicles(client)) do
		vehicles[vehicle:getId()] = {vehicle, vehicle:getPositionType()}
	end
	return vehicles
end

function VehicleManager:Event_vehicleLock()
	if not source or not isElement(source) then return end
	self:checkVehicle(source)

	if source:hasKey(client) or client:getRank() >= RANK.Moderator then
		source:playLockEffect()
		source:setLocked(not source:isLocked())
		return
	end

	client:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug", client))
end

function VehicleManager:Event_vehicleRequestKeys()
	if not instanceof(source, PermanentVehicle, true) then
		triggerClientEvent(client, "vehicleKeysRetrieve", source, false)
		return
	end

	local names = source:getKeyNameList()
	triggerClientEvent(client, "vehicleKeysRetrieve", source, names)
end

function VehicleManager:Event_vehicleAddKey(player)
	if not player or not isElement(player) then return end
	if not player:isLoggedIn() then return end
	if not instanceof(source, PermanentVehicle, true) then return end

	if not source:isPermanent() then
		client:sendError(_("Nur permanente Fahrzeuge können Schlüssel haben!", client))
		return
	end

	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	if source:hasKey(player:getId()) then
		client:sendWarning(_("Dieser Spieler besitzt bereits einen Schlüssel!", client))
		return
	end

	-- Finally, add the key
	source:addKey(player)

	-- Give achievement
	client:giveAchievement(70)

	-- Tell the client that we added a new key
	triggerClientEvent(client, "vehicleKeysRetrieve", source, source:getKeyNameList())

	player:sendShortMessage(_("Du hast einen Fahrzeugschlüssel von %s erhalten! (%s)", player, client:getName(), source:getName()))
	client:sendShortMessage(_("Du hast %s einen Fahrzeugschlüssel gegeben! (%s)", client, player:getName(), source:getName()))
end

function VehicleManager:Event_vehicleRemoveKey(characterId)
	if not source:hasKey(characterId) then
		client:sendWarning(_("The specified player is not in possession of a key", client))
		return
	end

	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	-- Finally, remove the key
	source:removeKey(characterId)

	-- Tell the client that we removed the key
	triggerClientEvent(client, "vehicleKeysRetrieve", source, source:getKeyNameList())

	client:sendShortMessage(_("Du hast dem Spieler einen Fahrzeugschlüssel abgenommen! (%s)", client, source:getName()))
end

function VehicleManager:Event_vehicleRepair()
	if client:getRank() < ADMIN_RANK_PERMISSION["repairVehicle"] then
		AntiCheat:getSingleton():report(client, "DisallowedEvent", CheatSeverity.High)
		return
	end

	source:fix()

	Admin:getSingleton():sendShortMessage(_("%s hat das Fahrzeug %s von %s repariert.", client, client:getName(), source:getName(), getElementData(source, "OwnerName") or "Unknown"))
	StatisticsLogger:getSingleton():addAdminVehicleAction(client, "repair", source)
end

function VehicleManager:Event_vehicleRespawn(garageOnly)
	self:checkVehicle(source)
	source:removeAttachedPlayers()

	if not source:isRespawnAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht respawnt werden!", client))
		return
	end

	if source:getOccupantsCount() > 0 then
		client:sendError(_("Das Fahrzeug ist nicht leer!", client))
		return
	end

	if not instanceof(source, PermanentVehicle) then
		client:sendError(_("Das ist kein permanentes Server Fahrzeug!", client))
		return
	end

	if source:getPositionType() == VehiclePositionType.Mechanic then
			client:sendError(_("Das Fahrzeug wurde abgeschleppt oder zerstört! Hole es an der Mech&Tow Base ab!", client))
			return
	end

	if source:getPositionType() == VehiclePositionType.Unregistered then
		client:sendError(_("Dieses Fahrzeug ist abgemeldet und kann nicht respawnt werden!", client))
		return
	end

	if source:isBroken() and client:getRank() < ADMIN_RANK_PERMISSION["respawnVehicle"] then
		client:sendError(_("Dieses Fahrzeug ist kaputt und kann nicht respawnt werden!", client))
		return
	end

	if instanceof(source, FactionVehicle) then
		if client:getRank() >= ADMIN_RANK_PERMISSION["respawnVehicle"] then
			source:respawn(true, true)
			StatisticsLogger:getSingleton():addAdminVehicleAction(client, "respawn", source)
			Admin:getSingleton():sendShortMessage(_("%s hat das Fahrzeug %s von %s respawnt.", client, client:getName(), source:getName(), getElementData(source, "OwnerName") or "Unknown"))
			return
		else
			if (not client:getFaction()) or source:getFaction():getId() ~= client:getFaction():getId() then
				client:sendError(_("Dieses Fahrzeug ist nicht von deiner Fraktion!", client))
				return
			end
			if client:getFaction():getPlayerRank(client) >= 4 then
				source:respawn()
			else
				client:sendError(_("Du bist nicht berechtigt!", client))
			end
			return
		end
	end

	if instanceof(source, CompanyVehicle) then
		if client:getRank() >= ADMIN_RANK_PERMISSION["respawnVehicle"] then
			source:respawn(true, true)
			StatisticsLogger:getSingleton():addAdminVehicleAction(client, "respawn", source)
			Admin:getSingleton():sendShortMessage(_("%s hat das Fahrzeug %s von %s respawnt.", client, client:getName(), source:getName(), getElementData(source, "OwnerName") or "Unknown"))
			return
		else
			if (not client:getCompany()) or source:getCompany():getId() ~= client:getCompany():getId() then
				client:sendError(_("Diese Fahrzeug ist nicht von deinen Unternehmen!", client))
				return
			end
			if client:getCompany():getPlayerRank(client) >= 3 then
				source:respawn()
			else
				client:sendError(_("Du bist nicht berechtigt!", client))
			end
			return
		end
	end

	if instanceof(source, GroupVehicle) then
		if (client:getRank() >= ADMIN_RANK_PERMISSION["respawnVehicle"]) then
			source:respawn(true)
			StatisticsLogger:getSingleton():addAdminVehicleAction(client, "respawn", source)
			Admin:getSingleton():sendShortMessage(_("%s hat das Fahrzeug %s von %s respawnt.", client, client:getName(), source:getName(), getElementData(source, "OwnerName") or "Unknown"))
			return
		else
			if (not client:getGroup()) or source:getGroup():getId() ~= client:getGroup():getId() then
				client:sendError(_("Diese Fahrzeug ist nicht von deiner Gruppe!", client))
				return
			end

			if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "group", "vehicleRespawn") then
				client:sendError(_("Du bist nicht berechtigt Gruppen-Fahrzeuge zu respawnen!", client))
				return
			end

			local group = client:getGroup()
			if group:getMoney() >= 100 then
				group:transferMoney(self.m_BankAccountServer, 100, "Fahrzeug-Respawn", "Vehicle", "Respawn")
				group:sendShortMessage(_("%s hat ein Fahrzeug deiner %s respawnt! (%s)", client, client:getName(), group:getType(), source:getName()))
			else
				client:sendError(_("In eurer %s-Kasse befindet sich nicht genug Geld! (100$)", client, group:getType()))
				return
			end

			source:respawn()
			return
		end
	end

	if source:getOwner() ~= client:getId() and client:getRank() < ADMIN_RANK_PERMISSION["respawnVehicle"] then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	if client:getBankMoney() < 100 and source:getOwner() == client:getId() then
		client:sendError(_("Du hast nicht genügend Geld auf deinem Bankkonto (100$)!", client))
		return
	end

	if source:isInGarage() then
		source:fix()
		setVehicleOverrideLights(source, 1)
		setVehicleEngineState(source, false)
		source.m_EngineState = false
		source:setSirensOn(false)
		if source:getOwner() == client:getId() then
			client:transferBankMoney(self.m_BankAccountServer, 100, "Fahrzeug-Respawn", "Vehicle", "Respawn")
		end
		client:sendShortMessage(_("Fahrzeug repariert!", client))
		return
	end

	local occupants = getVehicleOccupants(source)
	for seat, player in pairs(occupants) do
		removePedFromVehicle(player)
	end

	if source:respawn(garageOnly) then
		if source:getOwner() == client:getId() then
			client:transferBankMoney(self.m_BankAccountServer, 100, "Fahrzeug-Respawn", "Vehicle", "Respawn")
		end
		source:fix()
		setVehicleOverrideLights(source, 1)
		source:setEngineState(false)
		source:setSirensOn(false)
	end

	-- Refresh location in the self menu
	client:triggerEvent("vehicleRetrieveInfo", self:getVehiclesFromPlayer(client))
end

function VehicleManager:Event_vehicleRespawnWorld()
	self:checkVehicle(source)
	source:removeAttachedPlayers()
	if not source:isRespawnAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht respawnt werden!", client))
		return
	end

	if source:getOccupantsCount() > 0 then
		client:sendError(_("Das Fahrzeug ist nicht leer!", client))
		return
	end

 	if not instanceof(source, PermanentVehicle, true) and not instanceof(source, GroupVehicle) then
 		client:sendError(_("Das ist kein permanentes Server Fahrzeug!", client))
 		return
 	end

 	if source:getPositionType() == VehiclePositionType.Mechanic then
 		client:sendError(_("Das Fahrzeug wurde abgeschleppt oder zerstört! Hole es an der Mech&Tow Base ab!", client))
 		return
 	end

 	if source:getPositionType() == VehiclePositionType.Harbor then
		client:sendError(_("Das Fahrzeug wurde abgeschleppt oder zerstört! Hole es am Hafen in Los Santos ab!", client))
		return
	end

 	if source:getOwner() ~= client:getId() and not source:hasKey(client) and client:getRank() < ADMIN_RANK_PERMISSION["respawnVehicle"] then
 		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
 		return
	end

	if source:isBroken() and client:getRank() < ADMIN_RANK_PERMISSION["respawnVehicle"] then
		client:sendError(_("Dein Fahrzeug ist kaputt und kann nicht respawnt werden!", client))
		return
	end

 	if (source:getOwner() == client:getId() or source:hasKey(client)) and client:getBankMoney() < 100 then
 		client:sendError(_("Du hast nicht genügend Geld auf deinem Bankkonto (100$)!", client))
 		return
	end

 	if source:getPositionType() == VehiclePositionType.World then
		 if source:getOwner() == client:getId() or source:hasKey(client) then
			client:transferBankMoney(self.m_BankAccountServer, 100, "Fahrzeug-Respawn", "Vehicle", "Respawn")
		elseif client:getRank() >= ADMIN_RANK_PERMISSION["respawnVehicle"] then
			StatisticsLogger:getSingleton():addAdminVehicleAction(client, "respawn", source)
			Admin:getSingleton():sendShortMessage(_("%s hat das Fahrzeug %s von %s respawnt.", client, client:getName(), source:getName(), getElementData(source, "OwnerName") or "Unknown"))
		end
		source:respawnOnSpawnPosition()
 	else
 		client:sendError(_("Das Fahrzeug hat keine Park-Position!", client))
 	end
 end

function VehicleManager:Event_vehicleDelete(reason)
	self:checkVehicle(source)

	if not source:isRespawnAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht gelöscht werden!", client))
		return
	end

	if client:getRank() < ADMIN_RANK_PERMISSION["deleteVehicle"] then
		-- Todo: Report cheat attempt
		return
	end

	if source:isPermanent() then
		client:sendInfo(_("%s von Besitzer %s wurde von Admin %s gelöscht! Grund: %s", client, source:getName(), getElementData(source, "OwnerName") or "Unknown", client:getName(), reason))

		if getElementData(source, "OwnerName") then
			local targetId = Account.getIdFromName(getElementData(source, "OwnerName"))
			if targetId and targetId > 0 then
				local delTarget, isOffline = DatabasePlayer.get(targetId)
				if delTarget then
					if isOffline then
						delTarget:addOfflineMessage("Dein Fahrzeug ("..source:getName().." wurde von "..client:getName().." gelöscht. ("..reason..")!",1)

						delTarget.m_DoNotSave = true
						delete(delTarget)
					else
						delTarget:sendInfo(_("%s von Besitzer %s wurde von Admin %s gelöscht! Grund: %s", client, source:getName(), getElementData(source, "OwnerName") or "Unknown", client:getName(), reason))
					end
				end
			end
		end

		-- Todo Add Log
		StatisticsLogger:getSingleton():addVehicleDeleteLog(source:getOwner(), client, source:getModel(), reason)
		Admin:getSingleton():sendShortMessage(_("%s hat das Fahrzeug %s von %s gelöscht (Grund: %s).", client, client:getName(), source:getName(), getElementData(source, "OwnerName") or "Unknown", reason))
		source:purge()
	else
		destroyElement(source)
	end
end

function VehicleManager:Event_vehicleSell()
	if not instanceof(source, PermanentVehicle, true) then return end
	if source:getOwner() ~= client:getId() then	return end
	if source.m_Premium then
		client:sendError(_("Dieses Fahrzeug ist ein Premium Fahrzeug und darf nicht verkauft werden!", client))
		return
	end

	local price = source:getBuyPrice()
	if price > 0 then
		QuestionBox:new(client, _("Möchtest du das Fahrzeug wirklich für %d$ verkaufen?", client, math.floor(price * 0.75)), "vehicleSellAccept", nil, false, false, source)
	else
		client:sendError(_("Das Fahrzeug ist in keinem Shop erhätlich und kann nicht an den Server verkauft werden!", client))
		QuestionBox:new(client, _("Möchtest du dieses Fahrzeug entfernen?", client, math.floor(price * 0.75)), "vehicleSellAccept", nil, false, false, source)
	end
end

function VehicleManager:Event_acceptVehicleSell(veh)
	if not instanceof(veh, PermanentVehicle, true) then return end
	if veh:getOwner() ~= source:getId() then return end
	if veh.m_Premium then
		source:sendError(_("Dieses Fahrzeug ist ein Premium Fahrzeug und darf nicht verkauft werden!", source))
		return
	end
	local price = veh:getBuyPrice()
	StatisticsLogger:getSingleton():addVehicleTradeLog(veh, source, 0, price, "server")
	if price then
		veh:purge()
		self.m_BankAccountServer:transferMoney(source, math.floor(price * 0.75), "Fahrzeug-Verkauf", "Vehicle", "SellToServer")

		self:Event_vehicleRequestInfo(source)

	else
		source:sendError(_("Beim verkauf dieses Fahrzeuges ist ein Fehler aufgetreten!", source))
	end
end

function VehicleManager:Event_vehicleRequestInfo(player)
	local client = client or player
	client:triggerEvent("vehicleRetrieveInfo", self:getVehiclesFromPlayer(client), client:getGarageType(), client:getHangarType())
end

function VehicleManager:Event_vehicleUpgradeGarage()
	local currentGarage = client:getGarageType()
	if currentGarage >= 0 then
		local price = GARAGE_UPGRADES_COSTS[currentGarage + 1]
		if price then
			if client:getBankMoney() >= price then

				client:transferBankMoney(self.m_BankAccountServer, price, "Garagen-Upgrade", "Vehicle", "GarageUpgrade")
				client:setGarageType(currentGarage + 1)

				client:triggerEvent("vehicleRetrieveInfo", false, client:getGarageType(), client:getHangarType())
			else
				client:sendError(_("Du hast nicht genügend Geld auf deinem Bankkonto, um die Garage zu kaufen oder upzugraden", client))
			end
		else
			client:sendError(_("Deine Garage ist bereits auf dem höchsten Level", client))
		end
	else
		client:sendError(_("Du besitzt keine gültige Garage!", client))
	end
end

function VehicleManager:Event_vehicleUpgradeHangar()
	local currentHangar = client:getHangarType()
	if currentHangar >= 0 then
		local price = HANGAR_UPGRADES_COSTS[currentHangar + 1]
		if price then
			if client:getMoney() >= price then
				client:transferBankMoney(self.m_BankAccountServer, price, "Hangar-Upgrade", "Vehicle", "HangarUpgrade")
				client:setHangarType(currentHangar + 1)

				client:triggerEvent("vehicleRetrieveInfo", false, client:getGarageType(), client:getHangarType())
			else
				client:sendError(_("Du hast nicht genügend Geld, um dein Hangar zu upgraden", client))
			end
		else
			client:sendError(_("Deine Hangar ist bereits auf dem höchsten Level", client))
		end
	else
		client:sendError(_("Du besitzt keinen gültigen Hangar!", client))
	end
end

function VehicleManager:Event_vehicleEmpty()
	if source:hasKey(client) or client:getRank() >= RANK.Moderator then
		for seat, occupant in pairs(getVehicleOccupants(source) or {}) do
			if seat ~= 0 then
				removePedFromVehicle(occupant)
				if occupant:getData("BeggarId") then
					occupant:onTransportExit(client)
				end
				if occupant:getData("isDrivingCoach") then
					if DrivingSchool.m_LessonVehicles[client] == source then
						DrivingSchool.m_LessonVehicles[client] = nil
						if source.m_NPC then
							destroyElement(source.m_NPC)
						end
						destroyElement(source)
					end
					client:triggerEvent("DrivingLesson:endLesson")
					fadeCamera(client,false,0.5)
					setTimer(setElementPosition,1000,1,client,1759.05, -1690.22, 13.37)
					setTimer(fadeCamera,1500,1, client,true,0.5)
					outputChatBox(_("Du hast den Fahrlehrer rausgeworfen und die Prüfung beendet!", client), client, 200,0,0)
				end
			end
		end

		if source:hasSeatExtension() then
			if source:hasShamalExtension() then
				source:seRemovePlayersFromInterior()
			end
			source:vseRemoveAttachedPlayers()
		end
		if source:getModel() == 459 then
			if source.m_RcVehicleUser then
				for i, player in pairs(source.m_RcVehicleUser) do
					source:toggleRC(player, player:getData("RcVehicle"), false, true)
					player:removeFromVehicle()
				end
			end
		end

		client:sendShortMessage(_("Mitfahrer wurden herausgeworfen!", client))
	else
		client:sendError(_("Hierzu hast du keine Berechtigungen!", client))
	end
end

function VehicleManager:Event_vehicleSyncMileage(diff)
	local diff = diff
	if diff < -0.001 then
		AntiCheat:getSingleton():report(client, "Sent invalid mileage", CheatSeverity.Middle)
		return
	end

	local vehicle = client:getOccupiedVehicle()
	if vehicle then
		if vehicle.setMileage and vehicle.setMileage then
			local deltaTimeMS = (getTickCount() - (vehicle.m_LastMileageCheck or 0))
			local deltaTimeH =  deltaTimeMS/1000/60/60
			local kmh = (diff/1000)/deltaTimeH
			if kmh > vehicle:getHandling()["maxVelocity"] then -- diff is higher than diff with max velocity of this vehicle, so crop it
				kmh = vehicle:getHandling()["maxVelocity"]
				diff = kmh*deltaTimeH*1000
			end
			vehicle:setMileage((vehicle:getMileage() or 0) + diff)
			vehicle.m_LastMileageCheck = getTickCount()
			client:increaseStatistics("Driven", diff)
		end
	end
end

function VehicleManager:Event_vehicleBreak(weapon)
	if not source.isBroken or not source:isBroken() then
		self:checkVehicle(source)
		if not VEHICLE_BIKES[source:getModel()] then
			outputDebug("Vehicle has been broken by "..client:getName())
			if source.controller then
				source.controller:sendWarning(_("Dein Fahrzeug ist kaputt und muss repariert werden!", source.controller))
			end
			local maxRnd = (weapon and weapon >= 22 and weapon <= 38) and 10 or 20
			if math.random(1, maxRnd) == 1 then
				if FactionRescue:getSingleton():countPlayers(true, false) >= MIN_PLAYERS_FOR_VEHICLE_FIRE then
					FactionRescue:getSingleton():addVehicleFire(source)
				end
			end

			source:setBroken(true)
		end
	end
end

function VehicleManager:Event_vehicleBlow(weapon)
	if not source:isBlown() then
		source:blow(false)
		for key, player in pairs(getVehicleOccupants(source)) do
			StatisticsLogger:getSingleton():addKillLog(client, player, weapon)
			player:removeFromVehicle()
			player:kill()
		end
	end
end

function VehicleManager:Event_soundvanChangeURL(url)
	if source.m_Special and source.m_Special == VehicleSpecial.Soundvan then
		source.m_SoundURL = url
		triggerClientEvent("soundvanChangeURLClient", source, url)
	end
end

function VehicleManager:Event_soundvanStopSound()
	if source.m_Special and source.m_Special == VehicleSpecial.Soundvan then
		source.m_SoundURL = nil
		triggerClientEvent("soundvanStopSoundClient", source, url)
	end
end

function VehicleManager:Event_TrailerAttach(truck)
	if not getVehicleOccupant(truck) then return end
	if not instanceof(truck, PermanentVehicle) and not instanceof(truck, GroupVehicle) then return end
	if not instanceof(source, PermanentVehicle) and not instanceof(source, GroupVehicle) then return end

	if source:getOwner() == truck:getOwner() then
		source:setFrozen(false)
	end
end

function VehicleManager:Event_LoadObject(veh, type)
	local vehicleObjects, model, name
	vehicleObjects = VEHICLE_BAG_LOAD
	if type == "moneyBag" then
		model = 1550
		name = "keinen Geldsack"
	elseif type == "weaponBox" then
		model = 2912
		name = "keine Waffenbox"

		if veh:getData("WeaponTruck") then
			MWeaponTruck:getSingleton().m_CurrentWT:Event_LoadBox(veh)
			return
		end
		
	elseif type == "drugPackage" then
		model = 1575
		name = "kein Drogenpaket"

	elseif type == "christmasPresent" then
		model = 2912
		name = "kein Geschenk"
	
		if veh:getData("ChristmasTruck:Truck") then
			ChristmasTruckManager:getSingleton().m_Current:Event_LoadPresent(veh)
			return
		end
	end
	if veh:canObjectBeLoaded(model) then
		return veh:tryLoadObject(client, client:getPlayerAttachedObject())
	end
	if client:getFaction() then
		if vehicleObjects[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client:isDead() then
					if not client.vehicle then
						local object = client:getPlayerAttachedObject()
						if #getAttachedElements(veh) < vehicleObjects[veh.model]["count"] then
							if object then
								local count = #getAttachedElements(veh)
								client:detachPlayerObject(object)
								object:attach(veh, vehicleObjects[veh.model][count+1])
								if object.LoadHook then
									object.LoadHook(client, veh, object)
								end
							else
								client:sendError(_("Du hast %s dabei!", client, name))
							end
						else
							client:sendError(_("Das Fahrzeug ist bereits voll beladen!", client))
						end
					else
						client:sendError(_("Du darfst in keinem Fahrzeug sitzen!", client))
					end
				end
			else
				client:sendError(_("Du bist zu weit vom Truck entfernt!", client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht beladen werden!", client))
		end
	else
		client:sendError(_("Nur Fraktionisten können dieses Objekt abladen!", client))
	end
end

function VehicleManager:Event_DeLoadObject(veh, type)
	local vehicleObjects, model, name
	vehicleObjects = VEHICLE_BAG_LOAD
	if type == "moneyBag" then
		model = 1550
		name = "kein Geldsack"
	elseif type == "weaponBox" then
		model = 2912
		name = "keine Waffenbox"

		if veh:getData("WeaponTruck") then
			MWeaponTruck:getSingleton().m_CurrentWT:Event_DeloadBox(veh)
			return
		end
		
	elseif type == "drugPackage" then
		model = 1575
		name = "kein Drogenpaket"
	
	elseif type == "christmasPresent" then
		model = 2912
		name = "kein Geschenk"

		if veh:getData("ChristmasTruck:Truck") then
			ChristmasTruckManager:getSingleton().m_Current:Event_DeloadPresent(veh)
			return
		end
	end
	if veh:canObjectBeLoaded(model) then
		return veh:tryUnloadObject(client)
	end
	if client:getFaction() then
		if vehicleObjects[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client:isDead() then
					if not client.vehicle then
						for key, object in pairs (getAttachedElements(veh)) do
							if object.model == model then
								object:detach(self.m_Truck)
								client:attachPlayerObject(object)
								if object.DeloadHook then
									object.DeloadHook(client, veh, object)
								end
								return
							end
						end
						client:sendError(_("Es befindet sich %s im Truck!", client, name))
						return
					else
						client:sendError(_("Du darfst in keinem Fahrzeug sitzen!", client))
					end
				end
			else
				client:sendError(_("Du bist zu weit vom Truck entfernt!", client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht entladen werden!", client))
		end
	else
		client:sendError(_("Nur Fraktionisten können dieses Objekt abladen!", client))
	end
end

function VehicleManager:Event_SetVariant(variant1, variant2)
	local enginestate = source:getEngineState()
	source:setVariant(variant1, variant2)
	source:setEngineState(enginestate)
end

function VehicleManager:destroyInactiveVehicles()
	local counter = 0
	local lastUseTimeToBeDestroyed = getTickCount() - 1800000
	for key, vehicle in ipairs(getElementsByType("vehicle")) do
		if vehicle.m_OwnerType == 1 then
			if lastUseTimeToBeDestroyed > vehicle:getLastUseTime() then
				if vehicle:getOccupantsCount() == 0 then
					if vehicle.m_Owner then
						if not DatabasePlayer.Map[vehicle.m_Owner] then
							vehicle:destroy()
							counter = counter + 1
						end
					end
				end
			end
		end
	end
	--outputDebugString("[Vehicle-Manager] Cleaned "..counter.." inactive vehicles!")
end

function VehicleManager:migrate()
	local st = getTickCount()
	outputDebugString("========================================")
	outputDebugString("       STARTING VEHICLE MIGRATION       ")
	outputDebugString("========================================")

	sql:queryExec("RENAME TABLE ??_vehicles TO ??_vehicles_old", sql:getPrefix(), sql:getPrefix())

	sql:queryExec([[
		CREATE TABLE ??_vehicles  (
		`Id` int UNSIGNED NOT NULL AUTO_INCREMENT,
		`OldId` int UNSIGNED NULL DEFAULT NULL,
		`OldTable` tinyint NULL DEFAULT NULL,
		`CreationTime` datetime NULL DEFAULT NOW(),
		`Model` smallint UNSIGNED NOT NULL,
		`OwnerId` int UNSIGNED NOT NULL,
		`OwnerType` tinyint UNSIGNED NOT NULL,
		`PosX` float NULL DEFAULT 0,
		`PosY` float NULL DEFAULT 0,
		`PosZ` float NULL DEFAULT 0,
		`RotX` float NULL DEFAULT 0,
		`RotY` float NULL DEFAULT 0,
		`RotZ` float NULL DEFAULT 0,
		`Health` smallint UNSIGNED NOT NULL DEFAULT 1000,
		`Keys` text CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
		`PositionType` tinyint UNSIGNED NOT NULL DEFAULT 0,
		`Fuel` tinyint NOT NULL DEFAULT 100,
		`Mileage` bigint UNSIGNED NOT NULL DEFAULT 0,
		`Premium` int UNSIGNED NOT NULL DEFAULT 0,
		`TrunkId` int NOT NULL DEFAULT 0,
		`Tunings` text CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
		`LastUsed` datetime NULL DEFAULT NOW(),
		`SalePrice` int NOT NULL DEFAULT 0,
		`Handling` text CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
		`ELSPreset` varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
		`Deleted` datetime NULL DEFAULT NULL,
		PRIMARY KEY (`Id`) USING BTREE
		);
	]], sql:getPrefix())

	local vehicles = sql:queryFetch("SELECT * FROM ??_vehicles_old", sql:getPrefix())

	for _, v in ipairs(vehicles) do
		local tunings = v["TuningsNew"] and fromJSON(v["TuningsNew"]) or {}

		if tunings["Texture"] and type(tunings["Texture"]) == "string" then
			local texture = tunings["Texture"]
			tunings["Texture"] = {["vehiclegrunge256"] = texture}
		end

		sql:queryExec([[
			INSERT INTO
				??_vehicles
				(OldId, OldTable, CreationTime, Model, OwnerId, OwnerType,
				PosX, PosY, PosZ, RotX,
				RotY, RotZ, Health, PositionType,
				Fuel, Mileage, Premium, TrunkId,
				Tunings, `Keys`)
				VALUES (?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
			]], sql:getPrefix(), v["Id"], v["CreationTime"], v["Model"], v["Owner"], VehicleTypes.Player, v["PosX"], v["PosY"], v["PosZ"],
			v["RotX"], v["RotY"], v["Rotation"], v["Health"], v["PositionType"], v["Fuel"],
			v["Mileage"], v["Premium"], v["TrunkId"], toJSON(tunings, true), v["Keys"])
	end

	outputDebugString(("Migrated %s player vehicles"):format(#vehicles))



	local vehicles = sql:queryFetch("SELECT * FROM ??_group_vehicles", sql:getPrefix())

	for _, v in ipairs(vehicles) do
		local tunings = v["TuningsNew"] and fromJSON(v["TuningsNew"]) or {}

		if tunings["Texture"] and type(tunings["Texture"]) == "string" then
			local texture = tunings["Texture"]
			tunings["Texture"] = {["vehiclegrunge256"] = texture}
		end

		sql:queryExec([[
			INSERT INTO
				??_vehicles
				(OldId, OldTable, CreationTime, Model, OwnerId, OwnerType,
				PosX, PosY, PosZ, RotX,
				RotY, RotZ, Health, PositionType,
				Fuel, Mileage, Premium, TrunkId,
				Tunings, SalePrice)
				VALUES (?, 2, NOW(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
			]], sql:getPrefix(), v["Id"], v["Model"], v["Group"], VehicleTypes.Group, v["PosX"], v["PosY"], v["PosZ"],
			v["RotX"], v["RotY"], v["Rotation"], v["Health"], v["PositionType"], v["Fuel"],
			v["Mileage"], v["Premium"], v["TrunkId"], toJSON(tunings, true), v["SalePrice"])
	end

	outputDebugString(("Migrated %s group vehicles"):format(#vehicles))


	local vehicles = sql:queryFetch("SELECT * FROM ??_faction_vehicles", sql:getPrefix())

	for _, v in ipairs(vehicles) do
		local tunings = {}

		if v["Color"] and type(v["Color"]) == "string" then
			local c1, c2, c3, c4, c5, c6 = fromJSON(v["Color"])

			if c1 then
				tunings["Color1"] = {c1, c2, c3}
				if c4 then
					tunings["Color2"] = {c4, c5, c6}
				else
					tunings["Color2"] = {factionCarColors[v["Faction"]].r1, factionCarColors[v["Faction"]].g1, factionCarColors[v["Faction"]].b1}
				end
			else
				tunings["Color1"] = {factionCarColors[v["Faction"]].r, factionCarColors[v["Faction"]].g, factionCarColors[v["Faction"]].b}
				tunings["Color2"] = {factionCarColors[v["Faction"]].r1, factionCarColors[v["Faction"]].g1, factionCarColors[v["Faction"]].b1}
			end
		else
			tunings["Color1"] = {factionCarColors[v["Faction"]].r, factionCarColors[v["Faction"]].g, factionCarColors[v["Faction"]].b}
			tunings["Color2"] = {factionCarColors[v["Faction"]].r1, factionCarColors[v["Faction"]].g1, factionCarColors[v["Faction"]].b1}
		end

		if v["decal"] then
			tunings["Texture"] = fromJSON(v["decal"])
			tunings["TextureForce"] = true
		end

		sql:queryExec([[
			INSERT INTO
				??_vehicles
				(OldId, OldTable, CreationTime, Model, OwnerId, OwnerType,
				PosX, PosY, PosZ, RotX,
				RotY, RotZ, Health,
				Fuel, Mileage, Tunings, Handling, ELSPreset)
				VALUES (?, 3, NOW(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
			]], sql:getPrefix(), v["Id"], v["Model"], v["Faction"], VehicleTypes.Faction, v["PosX"], v["PosY"], v["PosZ"],
			v["RotX"], v["RotY"], v["Rotation"], v["Health"], v["Fuel"],
			v["Mileage"], toJSON(tunings, true), v["handling"], v["ELSPreset"])
	end

	outputDebugString(("Migrated %s faction vehicles"):format(#vehicles))


	local vehicles = sql:queryFetch("SELECT * FROM ??_company_vehicles", sql:getPrefix())

	for _, v in ipairs(vehicles) do
		local tunings = {}

		if v["Color"] and type(v["Color"]) == "string" then
			local c1, c2, c3, c4, c5, c6 = fromJSON(v["Color"])

			if c1 then
				tunings["Color1"] = {c1, c2, c3}
				if c4 then
					tunings["Color2"] = {c4, c5, c6}
				else
					tunings["Color2"] = {companyColors[v["Company"]].r, companyColors[v["Company"]].g, companyColors[v["Company"]].b}
				end
			else
				tunings["Color1"] = {companyColors[v["Company"]].r, companyColors[v["Company"]].g, companyColors[v["Company"]].b}
				tunings["Color2"] = {companyColors[v["Company"]].r, companyColors[v["Company"]].g, companyColors[v["Company"]].b}
			end
		else
			tunings["Color1"] = {companyColors[v["Company"]].r, companyColors[v["Company"]].g, companyColors[v["Company"]].b}
			tunings["Color2"] = {companyColors[v["Company"]].r, companyColors[v["Company"]].g, companyColors[v["Company"]].b}
		end
		if companyVehicleShaders[v["Company"]] then
			if companyVehicleShaders[v["Company"]][v["Model"]] then
				local tex = companyVehicleShaders[v["Company"]][v["Model"]]
				tunings["Texture"] = {[tex.textureName] = tex.texturePath}
			end
		end

		sql:queryExec([[
			INSERT INTO
				??_vehicles
				(OldId, OldTable, CreationTime, Model, OwnerId, OwnerType,
				PosX, PosY, PosZ, RotX,
				RotY, RotZ, Health,
				Fuel, Mileage, Tunings, ELSPreset)
				VALUES (?, 4, NOW(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
			]], sql:getPrefix(), v["Id"], v["Model"], v["Company"], VehicleTypes.Company, v["PosX"], v["PosY"], v["PosZ"],
			v["RotX"], v["RotY"], v["Rotation"], v["Health"], v["Fuel"],
			v["Mileage"], toJSON(tunings, true), v["ELSPreset"])
	end

	outputDebugString(("Migrated %s company vehicles"):format(#vehicles))

	outputDebugString(("Finished migration in %sms"):format(getTickCount()-st))

	if not sql:queryFetchSingle("SHOW COLUMNS FROM ??_factions WHERE Field = 'Name_Shorter';", sql:getPrefix()) then
		sql:queryExec([[ALTER TABLE ??_factions ADD COLUMN `Name_Shorter` varchar(2) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT '' COMMENT 'Its even shorter than short' AFTER `Id`;]], sql:getPrefix())

		sql:queryExec([[
			UPDATE ??_factions SET Name_Shorter = 'PD' WHERE Id = 1;
			UPDATE ??_factions SET Name_Shorter = 'FB' WHERE Id = 2;
			UPDATE ??_factions SET Name_Shorter = 'SF' WHERE Id = 3;
			UPDATE ??_factions SET Name_Shorter = 'RT' WHERE Id = 4;
			UPDATE ??_factions SET Name_Shorter = 'LC' WHERE Id = 5;
			UPDATE ??_factions SET Name_Shorter = 'YK' WHERE Id = 6;
			UPDATE ??_factions SET Name_Shorter = 'GS' WHERE Id = 7;
			UPDATE ??_factions SET Name_Shorter = 'BA' WHERE Id = 8;
			UPDATE ??_factions SET Name_Shorter = 'OM' WHERE Id = 9;
			UPDATE ??_factions SET Name_Shorter = 'VL' WHERE Id = 10;
		]], sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), sql:getPrefix(),
			sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), sql:getPrefix())
	end

end

function VehicleManager:Event_ToggleLoadingRamp()
	if getDistanceBetweenPoints3D(client.position, source.position) > 10 then client:sendError(_("Du bist zu weit entfernt!", client)) return end
	if not source:isInVehicleLoadingMode() and (source:isFrozen() or source.m_HandBrake) then client:sendError(_("Bitte löse zuerst die Handbremse!", client)) return end
	if client:getCompany() and client:getCompany():getId() == 4 and client:isCompanyDuty() then
		source:toggleVehicleLoadingMode()
	end
end


function VehicleManager:Event_RequestVehicleMarks()
	client:triggerEvent("receiveVehicleMarks", self.m_VehicleMarks)
end

function VehicleManager:addVehicleMark(vehicle, mark)
	if vehicle and isElement(vehicle) and mark ~= "" then
		self.m_VehicleMarks[vehicle] = mark
		for k, p in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
			p:triggerEvent("addVehicleMark", vehicle, mark)
		end
	end
end

function VehicleManager:removeVehicleMark(vehicle)
	if self.m_VehicleMarks[vehicle] then
		self.m_VehicleMarks[vehicle] = nil
		for k, p in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
			p:triggerEvent("removeVehicleMark", vehicle)
		end
	end
end

function VehicleManager:getStateVehicleCount()
	local facVehicles = VehicleManager:getSingleton().m_FactionVehicles
	local count = (facVehicles[1] and #facVehicles[1] or 0) + (facVehicles[2] and #facVehicles[2] or 0) + (facVehicles[3] and #facVehicles[3] or 0)
	return count
end

function VehicleManager:Event_requestVehicles()
	local temp = {}
	for i, v in pairs(client:getVehicles()) do
		temp[i] = {v, v.m_Unregistered}
	end
	client:triggerEvent("sendRegisteredVehicleList", temp)
end

function VehicleManager:Event_toggleVehicleRegister(type)
	if not source or not isElement(source) or source.type ~= "vehicle" then return end
	if not source:isEmpty() then return client:sendError(_("Das Fahrzeug ist nicht leer.", client)) end
	if source:getOwner() ~= client:getId() then return client:sendError(_("Das Fahrzeug gehört nicht dir.", client)) end 
	
	if type == "register" then
		if source.m_Unregistered <= getRealTime().timestamp - VEHICLE_MIN_DAYS_TO_REGISTER_AGAIN then
			if client:transferBankMoney(self.m_BankAccountServer, 500 + source:getTax()*10, "Fahrzeug-Anmeldung", "Vehicle", "Register") then
				source:toggleRegister(client)
			else
				client:sendError(_("Du hast nicht genügend Geld auf deinem Konto. (%s$)", client, 500 + source:getTax()*10))
			end
		else
			client:sendError(_("Du kannst dein Fahrzeug noch nicht wieder anmelden.", client))
		end
	elseif type == "unregister" then
		if source:getPositionType() ~= VehiclePositionType.World then return client:sendError(_("Das Fahrzeug darf nicht auf dem Autohof oder in der Garage stehen.", client)) end
		source:toggleRegister()
	else
		client:sendError(_("Fehler: Ungültiger Typ.", client))
	end
end

function VehicleManager:Event_toggleShamalInterior()
    local enter = (client:getInterior() == 0 and client:getDimension() == 0) and true or false
    source:seEnterExitInterior(client, enter)
end

function VehicleManager:Event_requestKeyList()
	local temp = {}
	for owner, vehTbl in pairs(self.m_Vehicles) do
		for i, veh in pairs(vehTbl) do
			if veh:hasKey(client) and veh:getOwner() ~= client:getId() then
				table.insert(temp, {veh, veh:getPositionType()})
			end
		end
	end

	client:triggerEvent("showKeyList", temp)
end

function VehicleManager:Event_vehicleToggleRC(vehicleId, state)
	if source:getModel() == 459 then
		if not source.m_RcVehicle[vehicleId] then
			source:toggleRC(client, vehicleId, state)
		else
			client:sendError(_("Der %s wird derzeit verwendet.", client, getVehicleNameFromModel(vehicleId)))
		end
	else
		client:sendError(_("Mit diesem Fahrzeug nicht möglich.", client))
	end
end