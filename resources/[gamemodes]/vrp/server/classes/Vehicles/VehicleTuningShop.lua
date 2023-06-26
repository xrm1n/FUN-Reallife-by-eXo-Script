-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleTuningShop.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleTuningShop = inherit(Singleton)
addEvent("vehicleUpgradesBuy", true)
addEvent("vehicleUpgradesAbort", true)

function VehicleTuningShop:constructor()
    addEventHandler("vehicleUpgradesBuy", root, bind(self.Event_vehicleUpgradesBuy, self))
    addEventHandler("vehicleUpgradesAbort", root, bind(self.Event_vehicleUpgradesAbort, self))

    -- Create map objects / remove objects
    removeWorldModel(5340, 5.8436832, 2646.542, -2039.1484, 14.05193)
    removeWorldModel(5043, 4.5020704, 1843.3203, -1856.1953, 14.1901)
    removeWorldModel(5779, 5.0575686, 1041.1357, -1025.9763, 32.77094)
    createObject(5340, 2644.8999, -2040, 15.6, 0, 270, 90)
    createObject(5043, 1845.4, -1856.3, 15.6, 0.051, 78.25, 359.755)
    createObject(11326, 2511.3999, -1775.7, 14.9, 0, 0, 180)
    createObject(5779, 1041.4, -1025.2, 35.5, 0, 19, 90)
    setGarageOpen(10, true)
    setGarageOpen(33, true)
    self.m_BankAccountServer = BankServer.get("vehicle.tuning")

    -- Create garages
    self.m_GarageInfo = {
        -- Entrance - Exit (pos, rot) - Interior
        {
            Vector3(1041.4, -1017.5, 31), -- LS Temple
            {Vector3(1041.9, -1031.5, 31.2), 180},
            Vector3(953.59998, -983.09998, 2454.8999) -- TODO: Add Toxsi's garage here
        },
		{
            Vector3(1483.14, -2438.56, 13), -- LS Airport
            {Vector3(1494.73, -2455.32, 13), 180},
            Vector3(1483.14, -2438.56, 13),
			"AirportPainter"
        },
		{
			Vector3(2364, -2570, 1), -- LS Boot
			{Vector3(2351, -2570, 1), 90},
			Vector3(2260, -5880, 1),
			"BoatsPainter"
		}
    }

    for garageId, info in pairs(self.m_GarageInfo) do
        local position = info[1]
        local colshape = createColSphere(position, 3)
        addEventHandler("onColShapeHit", colshape, bind(self.EntryColShape_Hit, self, garageId))
        local blip = Blip:new("TuningGarage.png", position.x, position.y,root,600)
		local blipText = "Tuninggarage"

		if info[4] == "AirportPainter" then
			blipText = blipText.." (Flugzeuge)"
		elseif info[4] == "BoatsPainter" then
			blipText = blipText.." (Boote)"
		end

		blip:setDisplayText(blipText, BLIP_CATEGORY.VehicleMaintenance)
        blip:setOptionalColor({3, 169, 244})

		if info[4] and (info[4] == "AirportPainter" or info[4] == "BoatsPainter") then
			createMarker(position.x, position.y, position.z-1.2, "cylinder", 6, 50, 200, 255)
			colshape.Type = info[4]
		end
    end



    -- Register quit hook that moves the player out of the garage before saving
    Player.getQuitHook():register(
        function(player)
            -- Check if he is in a garage
            local vehicle = player:getOccupiedVehicle()
            if player.m_VehicleTuningGarageId and vehicle then
                self:closeFor(player, vehicle, true)
            end
        end
    )
end

function VehicleTuningShop:openFor(player, vehicle, garageId, specialType, adminSession)
    player:triggerEvent("vehicleTuningShopEnter", vehicle or player:getPedOccupiedVehicle(), specialType, adminSession)
    if adminSession then --save position so that the admin can return to it later
        player.m_VehicleTuningLastPosition = vehicle.position
        player.m_VehicleTuningLastRotation = vehicle.rotation
    end
    vehicle:setFrozen(true)
    player:setFrozen(true)
    local position = self.m_GarageInfo[garageId][3]
    vehicle:setPosition(position + vehicle:getBaseHeight(true))
    setTimer(function() warpPedIntoVehicle(player, vehicle) end, 500, 1)
    player.m_VehicleTuningGarageVehicle = vehicle
    player.m_VehicleTuningGarageId = garageId
    player.m_VehicleTuningAdminMode = adminSession
	player.m_WasBuckeled = getElementData(player, "isBuckeled")
end

function VehicleTuningShop:openForAdmin(admin, vehicle)
    local type
    if admin.vehicle == vehicle then
    if vehicle:isAirVehicle() then type = "AirportPainter" end
    if vehicle:isWaterVehicle() then type = "BoatsPainter" end
    self:openFor(admin, vehicle, 1, type, true)
    else
        admin:sendError(_("Du musst im Fahrzeug sitzen bleiben!", admin))
    end
end

function VehicleTuningShop:closeFor(player, vehicle, doNotCallEvent)
    if not doNotCallEvent then
        player:triggerEvent("vehicleTuningShopExit")
    end

    local garageId = player.m_VehicleTuningGarageId
    if garageId then
        local position, rotation = unpack(self.m_GarageInfo[garageId][2])
        if vehicle then
            vehicle:setFrozen(false)
            if player.m_VehicleTuningAdminMode then
                vehicle:setPosition(player.m_VehicleTuningLastPosition)
                vehicle:setRotation(player.m_VehicleTuningLastRotation)
            else
                vehicle:setPosition(position + vehicle:getBaseHeight(true))
                vehicle:setRotation(0, 0, rotation)
            end
        end

        player:setPosition(position) -- Set player position also as it will not be updated automatically before quit
        player:setFrozen(false)
        player.m_VehicleTuningGarageId = nil

        -- Hackfix for MTA issue #4658
        if vehicle and getVehicleType(vehicle) == VehicleType.Bike then
            teleportPlayerNextToVehicle(player, vehicle)
            warpPedIntoVehicle(player, vehicle)
        end

		if player.m_WasBuckeled then
			player.m_SeatBelt = vehicle
			setElementData(player, "isBuckeled", true)
		end
    end
end


function VehicleTuningShop:EntryColShape_Hit(garageId, hitElement, matchingDimension)
    if getElementType(hitElement) == "player" and matchingDimension then
        local vehicle = hitElement:getOccupiedVehicle()
        if not vehicle or hitElement:getOccupiedVehicleSeat() ~= 0 then return end

        if instanceof(vehicle, CompanyVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Unternehmens-Wagen darf nicht getunt werden!", hitElement))
              return
          end
		elseif instanceof(vehicle, FactionVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Fraktions-Wagen darf nicht getunt werden!", hitElement))
              return
          end
        elseif instanceof(vehicle, GroupVehicle) then
            if vehicle:getGroup() ~= hitElement:getGroup() then
                hitElement:sendError(_("Du kannst dieses Fahrzeug nicht tunen!", hitElement))
                return
            end
            if not vehicle:canBeModified()  then
                hitElement:sendError(_("Dein Leader muss das Tunen von Fahrzeugen aktivieren! Im Firmen/Gangmenü unter Leader!", hitElement))
                return
            end
            if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(hitElement, "group", "editVehicleTuning") then
                hitElement:sendError(_("Du bist nicht berechtigt Gruppen-Fahrzeuge zu tunen!", hitElement))
                return
            end
        elseif vehicle:isPermanent() then
            if vehicle:getOwner() ~= hitElement:getId() then
                hitElement:sendError(_("Du kannst nur deine eigenen Fahrzeuge tunen!", hitElement))
                return
            end
        else
			hitElement:sendError(_("Du kannst dieses Fahrzeug nicht tunen!", hitElement))
			return
        end

        -- removing occupants via removeFromVehicle() is not save as laggs can delay removal and the occupants end up in the interior
        if vehicle:getOccupantsCount(true) > 1 then 
            hitElement:sendError(_("Lasse deine Mitfahrer zuerst aussteigen!", hitElement))
            return
        end

        local vehicleType = vehicle:getVehicleType()
        if source.Type and source.Type == "AirportPainter" and (vehicleType == VehicleType.Helicopter or vehicleType == VehicleType.Plane) then
			 self:openFor(hitElement, vehicle, garageId, source.Type)
		elseif source.Type and source.Type == "BoatsPainter" and vehicleType == VehicleType.Boat then
			self:openFor(hitElement, vehicle, garageId, source.Type)
		elseif vehicleType == VehicleType.Automobile or vehicleType == VehicleType.Bike then
            self:openFor(hitElement, vehicle, garageId)
        else
            hitElement:sendError(_("Mit diesem Fahrzeugtyp kannst du die Tuningwerkstatt nicht betreten!", hitElement))
        end
    end
end

function VehicleTuningShop:Event_vehicleUpgradesBuy(cartContent)
    local vehicle = client:getOccupiedVehicle()
    if not vehicle then return end
    if not client.m_VehicleTuningGarageVehicle then return end 
    if client.m_VehicleTuningGarageVehicle ~= vehicle then return end
    -- Calculate price
    local overallPrice = 0
    for slot, upgradeId in pairs(cartContent) do
        if upgradeId ~= 0 then
            local price = getVehicleUpgradePrice(upgradeId)
            -- Search for part price if not available
           	if not price then
				price = getVehicleUpgradePrice(slot)
				if not price then
					price = 0
				else
					if not tonumber(price) then
						price = 0
					end
				end
			else
				if not tonumber(price) then
					price = getVehicleUpgradePrice(slot)
					if not price then
						price = 0
					else
						if not tonumber(price) then
							price = 0
						end
					end
				end
			end

            overallPrice = overallPrice + price
        end
    end

    if client:getBankMoney() < overallPrice and not client.m_VehicleTuningAdminMode then
        client:sendError(_("Du hast nicht genügend Geld!", client))
        return
    end

    if not client.m_VehicleTuningAdminMode then
        client:transferBankMoney(self.m_BankAccountServer, overallPrice, "Tuningshop", "Vehicle", "Tuning")
    else
        StatisticsLogger:getSingleton():addAdminVehicleAction(client, "tuningShop", vehicle, toJSON(cartContent))
    end
    for slot, upgradeId in pairs(cartContent) do
        if type(slot) == "number" and slot >= 0 then
            if upgradeId ~= 0 then
                vehicle:addUpgrade(upgradeId)
            else
                vehicle:removeUpgrade(vehicle:getUpgradeOnSlot(slot))
            end
        else
			--outputChatBox(slot..": "..tostring(upgradeId))
			if slot ~= "Texture" then
				vehicle.m_Tunings:saveTuning(slot, upgradeId)
			else
				vehicle.m_Tunings:addTexture(upgradeId, "vehiclegrunge256")
			end
        end
    end
	vehicle.m_Tunings:saveGTATuning()
	vehicle.m_Tunings:applyTuning()
    client:triggerEvent("syncVehicleTunings", vehicle, vehicle.m_Tunings:getTunings())

    client:sendSuccess(_("Upgrades gekauft!", client))

	if instanceof(vehicle, PermanentVehicle) then
		vehicle:save()
	end

    -- Exit
    self:closeFor(client, vehicle)
end

function VehicleTuningShop:Event_vehicleUpgradesAbort()
    self:closeFor(client, client:getOccupiedVehicle())
end
