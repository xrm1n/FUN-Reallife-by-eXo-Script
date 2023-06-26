NoDm = inherit(Singleton)
addRemoteEvents{"checkNoDm"}
NoDm.Zones = {
	[1] = {Vector3(1399.112, -1862.453, 12), Vector3(160,120,15)},
	[2] = {Vector3(1754.75, -1722.17, 10), Vector3(57, 40, 30)},
	[3] = {Vector3(430, -100, 998), Vector3(50, 40, 10), 4},
	[5] = {Vector3(1072.5, -1385, 12), Vector3{113, 94.1, 25}}, -- Rescue
	[6] = {Vector3(1266, 22, 20), Vector3{150, 150, 50}}, -- Kart
	--[8] = {Vector3(2713.39, -1880.29, 8), Vector3(104, 80, 50)}, -- Auction Event	
	[9] = {Vector3(1503.79, -1387.92,  23234), Vector3(151, 101, 30), 1}, -- Auction Event Interior
	[10] = {Vector3(2730.97, -2423.91, 810.44), Vector3(100, 200, 30), 5 },
	[11] = {Vector3(456.71, -1742.53, 784.67), Vector3(100, 55, 55), 18} --pershing square
}

if EVENT_HALLOWEEN then
	NoDm.Zones[#NoDm.Zones+1] = {Vector3(807.48, -1130.5, 20), Vector3(145, 75, 40)} --grave yard
end
if EVENT_CHRISTMAS then
	NoDm.Zones[#NoDm.Zones+1] = {Vector3(1441.15, -1720.72, 12), Vector3(76.71, 116.84, 40)} --pershing square
end

function NoDm:constructor()
	self.m_NoDmZones = {}
	self.m_NoDmRadarAreas = {}
	self.m_NoDm = false

	self.m_RenderBind = bind(self.renderNoDmImage, self)
	self.m_UnRenderBind = bind(self.unrenderNoDmImage, self)

	local colshape

	for index, koords in pairs(NoDm.Zones) do
		colshape = createColCuboid(koords[1], koords[2])
		if koords[3] and koords[3] > 0 then
			colshape:setInterior(koords[3])
		else
			self.m_NoDmRadarAreas[index] = HUDRadar:getSingleton():addArea(koords[1].x, koords[1].y, koords[2].x, -1*koords[2].y, {0, 255, 0, 150})
		end
		self:addZone(colshape)
	end
end

function NoDm:onNoDmZoneHit(hitElement, dim)
	if hitElement== localPlayer and dim then
		self:setPlayerNoDm(true)
	end
end

function NoDm:onNoDmZoneLeave(hitElement, dim)
	if hitElement== localPlayer and (dim or hitElement:getDimension() > 0) then
		self:setPlayerNoDm(false)
	end
end

function NoDm:addZone(colShape)
	local index = #self.m_NoDmZones+1
	self.m_NoDmZones[index] = colShape
	addEventHandler ("onClientColShapeHit", colShape, bind(self.onNoDmZoneHit, self))
	addEventHandler ("onClientColShapeLeave", colShape, bind(self.onNoDmZoneLeave, self))
end

function NoDm:setPlayerNoDm(state)
	if state == true then
		if not localPlayer:getPublicSync("Faction:Duty") then
			toggleControl ("fire", false)
			toggleControl ("next_weapon", false)
			toggleControl ("previous_weapon", false)
			toggleControl ("aim_weapon", false)
			toggleControl ("vehicle_fire", false)
			setElementData(localPlayer, "no_driveby", true)
			setPedWeaponSlot(localPlayer, 0)
			if (getPedWeapon ( localPlayer, 9 ) == 42) or (getPedWeapon ( localPlayer, 9 ) == 43) then -- fire extinguisher, camera
				if not isPedInVehicle(localPlayer) then
					setPedWeaponSlot(localPlayer,9)
					toggleControl ("aim_weapon", true)
					toggleControl ("fire", true)
					setTimer(showChat,100,1,true)
				end
			end
		end
		self:toggleNoDmImage(true)
	else
		toggleControl ("fire", true)
		toggleControl ("next_weapon", true)
		toggleControl ("previous_weapon", true)
		toggleControl ("aim_weapon", true)
		toggleControl ("vehicle_fire", true)
		setElementData(localPlayer, "no_driveby", false)
		setElementData(localPlayer,"schutzzone",false)
		self:toggleNoDmImage(false)
		localPlayer.m_FireToggleOff = false
	end
end

function NoDm:setControls(state)
	toggleControl ("fire", state)
	toggleControl ("next_weapon", state)
	toggleControl ("previous_weapon", state)
	toggleControl ("aim_weapon", state)
	toggleControl ("vehicle_fire", state)
end

function NoDm:toggleNoDmImage(state)
	if state == true and self.m_NoDm == false then
		self.m_currentImagePosition = 0
		removeEventHandler ( "onClientRender", getRootElement(), self.m_RenderBind)
		addEventHandler ( "onClientRender", getRootElement(), self.m_RenderBind)
		self.m_NoDm = true
	elseif state == false and self.m_NoDm == true then
		removeEventHandler ( "onClientRender", getRootElement(), self.m_UnRenderBind)
		addEventHandler ( "onClientRender", getRootElement(), self.m_UnRenderBind)
		self.m_NoDm = false
	end
end

function NoDm:renderNoDmImage()
	local target = screenWidth*0.15
	if self.m_currentImagePosition < target then self.m_currentImagePosition = self.m_currentImagePosition +10 end

	local px = screenWidth-self.m_currentImagePosition
	local py = screenHeight/2
	if not Phone:getSingleton():isOpen() then
		dxDrawImage(px,py,screenWidth*0.15,screenWidth*0.08,"files/images/Other/nodm.png")
	end
	if localPlayer:getFactionId() == 1 and localPlayer:getPublicSync("Faction:Duty") then return end
	if localPlayer:getFactionId() == 2 and localPlayer:getPublicSync("Faction:Duty") then return end
	if localPlayer:getFactionId() == 3 and localPlayer:getPublicSync("Faction:Duty") then return end
	if getPedWeapon ( localPlayer, 9 ) == 43 then return end
	if getPedWeapon ( localPlayer, 9 ) == 42 then return end

	setPedWeaponSlot(localPlayer,0)
	self:setControls(false)
end

function NoDm:unrenderNoDmImage()
	if not getElementData(localPlayer, "isTasered") then
		self:setControls(true)
	end
	if self.m_currentImagePosition > 0 then self.m_currentImagePosition = self.m_currentImagePosition -20 end
	if self.m_currentImagePosition <= 0 then
		if not self.m_NoDm then
			removeEventHandler ( "onClientRender", getRootElement(), self.m_RenderBind)
		end
		removeEventHandler ( "onClientRender", getRootElement(), self.m_UnRenderBind)
	end
end

function NoDm:isInNoDmZone()
	for i, shape in pairs (self.m_NoDmZones) do
		if isElementWithinColShape(localPlayer, shape) then
			return true
		end
	end
	return false
end

function NoDm:checkNoDm()
	if self:isInNoDmZone() then
		self:setPlayerNoDm(true)
	else
		self:setPlayerNoDm(false)
	end
end

addEventHandler("checkNoDm", localPlayer, function()
	for index, shape in pairs(NoDm:getSingleton().m_NoDmZones) do
		if isElementWithinColShape(localPlayer, shape) then
			NoDm:getSingleton():setPlayerNoDm(true)
			break
		else
			toggleControl("aim_weapon",true)
		end
	end
end)
