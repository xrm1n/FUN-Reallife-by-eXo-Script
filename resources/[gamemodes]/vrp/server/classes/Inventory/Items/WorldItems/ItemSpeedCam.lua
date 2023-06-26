-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemSpeedCam.lua
-- *  PURPOSE:     Speed Cam item class
-- *
-- ****************************************************************************
ItemSpeedCam = inherit(Item)
ItemSpeedCam.Map = {}

local MAX_SPEEDCAMS = 3
local COST_FACTOR = 15
local MIN_RANK = 2

function ItemSpeedCam:constructor()

end

function ItemSpeedCam:destructor()

end

function ItemSpeedCam:use(player)
	if player:getFaction() and player:getFaction():getId() == 1 and player:isFactionDuty() then
		if self:count() < MAX_SPEEDCAMS then
			if PermissionsManager:getSingleton():hasPlayerPermissionsTo(player, "faction", "useSpeedCam") then
				local result = self:startObjectPlacing(player,
					function(item, position, rotation)
						if item ~= self or not position then return end

						local worldItem = FactionWorldItem:new(self, player:getFaction(), position, rotation, false, player)
						worldItem:setFactionSuperOwner(true)
						--worldItem:setMinRank(MIN_RANK)

						player:getInventory():removeItem(self:getName(), 1)

						local object = worldItem:getObject()
						setElementData(object, "earning", 0)
						ItemSpeedCam.Map[#ItemSpeedCam.Map+1] = object

						object.col = worldItem:attach(createColSphere(position, 10))
						object.col.object = object
						self.m_func = bind(self.onColShapeHit, self)
						addEventHandler("onColShapeHit", object.col, self.m_func )

						object.radarDetectorCol = worldItem:attach(createColSphere(position, 100))
						self.m_RadarDetectorFunc = bind(self.onRadarDetectorColShapeHit, self)
						addEventHandler("onColShapeHit", object.radarDetectorCol, self.m_RadarDetectorFunc)

						local pos = player:getPosition()
						FactionState:getSingleton():sendShortMessage(_("%s hat einen Blitzer bei %s/%s aufgestellt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))
						StatisticsLogger:getSingleton():itemPlaceLogs( player, "Blitzer", pos.x..","..pos.y..","..pos.z)
					end
				)
			else
				player:sendError(_("Du bist nicht berechtigt Blitzer aufzustellen!", player))
			end
		else
			player:sendError(_("Es sind bereits %d/%d Anlagen aufgestellt!", player, self:count(), MAX_SPEEDCAMS))
		end
	else
		player:sendError(_("Du bist nicht berechtigt! Das Item wurde abgenommen!", player))
		player:getInventory():removeAllItem(self:getName())
	end
end

function ItemSpeedCam:count()
	local count = 0
	for index, cam in pairs(ItemSpeedCam.Map) do
		count = count + 1
	end
	return count
end

function ItemSpeedCam:onColShapeHit(element, dim)
	if dim then
		if element:getType() == "vehicle" then
			if element:getSpeed() > 85 then
				if element:getOccupant() then
					local player = element:getOccupant()

					if player:getFaction() and (player:getFaction():isStateFaction() or player:getFaction():isRescueFaction()) and player:isFactionDuty() then return end

					local speed = math.floor(element:getSpeed())
					local costs = (speed-80)*COST_FACTOR

					player:transferBankMoney({FactionManager:getSingleton():getFromId(1), nil, true}, costs, "Blitzer-Strafe", "Gameplay", "Speedcam")
					player:sendShortMessage(_("Du wurdest mit %d km/h geblitzt!\nStrafe: %d$", player, speed, costs), "SA Police Department")

					player:giveAchievement(62)
					if speed > 180 then
						player:giveAchievement(63)
					end

					if player:getCompany() and player:isCompanyDuty() and player:getCompany():getId() == CompanyStaticId.SANNEWS then
						if element:getModel() == 582 then
							player:giveAchievement(99) -- Rasender Reporter
						end
					end

					setElementData(source.object, "earning", getElementData(source.object, "earning") + costs)
				end
			end
		end
	end
end

function ItemSpeedCam:onRadarDetectorColShapeHit(element, dim)
	if dim then
		if element:getType() == "vehicle" then
			if element:getOccupant() and element:hasRadarDetector() then
				local player = element:getOccupant()
				player:sendWarning(_("Achtung! Das Radarwarngerät meldet einen Blitzer in der Nähe!", player))
			end
		end
	end
end

function ItemSpeedCam:removeFromWorld(player, worlditem)
	local object = worlditem:getObject()
	for index, cam in pairs(ItemSpeedCam.Map) do
		if cam == object then
			table.remove(ItemSpeedCam.Map, index)
		end
	end
end
