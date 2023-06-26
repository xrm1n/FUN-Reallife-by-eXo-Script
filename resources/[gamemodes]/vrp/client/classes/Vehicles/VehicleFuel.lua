-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
VehicleFuel = inherit(GUIForm3D)
inherit(Singleton, VehicleFuel)
addRemoteEvents{"forceCloseVehicleFuel"}

function VehicleFuel:constructor(vehicle, confirmCallback, confirmWithSpace, gasStation)
	self.m_Fuel = 0
	self.m_FuelOffset = vehicle:getFuel()
	self.m_Vehicle = vehicle
	self.m_MouseDown = false
	self.m_GasStation = gasStation
	self.m_ConfirmCallback = confirmCallback
	self.m_ConfirmWithSpace = confirmWithSpace

	self.m_isServiceStation = localPlayer.usingGasStation and localPlayer.usingGasStation:getData("isServiceStation")
	self.m_isEvilStation = localPlayer.usingGasStation and localPlayer.usingGasStation:getData("isEvilStation")

	self.m_FuelProgress = CAnimation:new(self, "m_Fuel")

	self.m_HandleClick = bind(VehicleFuel.handleClick, self)
	self.m_HandleShift = bind(VehicleFuel.handleShift, self)
	self.m_Confirm = bind(VehicleFuel.confirm, self)
	self.m_StopInteraction = bind(VehicleFuel.stopInteraction, self)

	Cursor:getHook():register(self.m_StopInteraction)

	local pos = vehicle:getPosition()
	local __,__,__,__,__,bbz2 = getElementBoundingBox(vehicle)
	pos = pos + vehicle.matrix.up*(bbz2 + 0.5)
	GUIForm3D.constructor(self, pos, vehicle:getRotation(), Vector2(1, 0.34), Vector2(200,70), 30, true)
	self.m_ShortMessage = ShortMessage:new(_("Halte die Linke Maustaste gedrückt und schaue dabei auf das Fahrzeug, um zu tanken (der Mauszeiger darf nicht aktiv sein). %s", confirmWithSpace and "\nDrücke die Leertaste, um den Kunden zum Bezahlen aufzufordern." or ""), "Fahrzeug befüllen", {230, 100, 0}, -1)

	bindKey("mouse1", "both", self.m_HandleClick)
	bindKey("lshift", "both", self.m_HandleShift)
	if confirmWithSpace then bindKey("space", "down", self.m_Confirm) end
end

function VehicleFuel:virtual_destructor()
	if not self.m_ConfirmWithSpace then self:confirm() end
	unbindKey("space", "down", self.m_Confirm)
	unbindKey("mouse1", "both", self.m_HandleClick)
	unbindKey("lshift", "both", self.m_HandleShift)
	toggleAllControls(true, true, false)
	self.m_ShortMessage:delete()
	Cursor:getHook():unregister(self.m_StopInteraction)
end

function VehicleFuel:confirm()
	if self.m_Fuel > 0 then
		if self.m_ConfirmCallback then self.m_ConfirmCallback(self.m_Vehicle, self:getFuelAmount(), self.m_GasStation, self:getFuelPrice(self.m_GasStation), self:getOpticalFuelAmount()) end
	end
end

function VehicleFuel:getOpticalFuelAmount()
	local tankSize = self.m_Vehicle:getFuelTankSize()
	return math.round((self.m_Fuel or 0)/100*tankSize, 2)
end

function VehicleFuel:getFuelAmount()
	return self.m_Fuel
end

function VehicleFuel:getFuelPrice(station)
	if not station or not station:getData("FuelTypePrices") or not station:getData("FuelTypePrices")[self.m_Vehicle:getFuelType()] then return 0 end
	local mult = ((self.m_isServiceStation and SERVICE_FUEL_PRICE_MULTIPLICATOR) or (self.m_isEvilStation and EVIL_FUEL_PRICE_MULTIPLICATOR) or 1)
	return math.round(self:getOpticalFuelAmount() * station:getData("FuelTypePrices")[self.m_Vehicle:getFuelType()] * mult, 2)
end

function VehicleFuel:handleClick(__, state)
	if isCursorShowing() then return end
	setPedControlState("fire", false)
	toggleControl("fire", false)
	if localPlayer.vehicle then return end

	self.m_MouseDown = state == "down"

	if self.m_MouseDown then
		if localPlayer:getWorldVehicle() ~= self.m_Vehicle then return end
		if self.m_Vehicle:getData("syncEngine") then WarningBox:new("Bitte schalte den Motor aus!") return end
		if self.m_Vehicle:getFuelType() ~= "universal" and not localPlayer:getPrivateSync("hasMechanicFuelNozzle") and localPlayer:getPrivateSync("hasGasStationFuelNozzle") ~= self.m_Vehicle:getFuelType() then
			WarningBox:new(_("In diesen Tank solltest du nur %s füllen.", FUEL_NAME[self.m_Vehicle:getFuelType()])) return end

		local time = self.m_Vehicle:getFuelTankSize()*1.5
		self.m_FuelProgress:startAnimation((100-(self.m_FuelOffset+self.m_Fuel))*time, "Linear", 100 - self.m_FuelOffset)
		toggleAllControls(false, true, false)
	else
		self:stopInteraction(true)
	end
end

function VehicleFuel:handleShift(__, state)
	if isCursorShowing() then return end
	local ele = self.m_Vehicle
	if state == "down" then
		ele = self.m_GasStation
	end
	local pos = ele:getPosition()
	local __,__,__,__,__,bbz2 = getElementBoundingBox(ele)
	self:setPosition(pos + ele.matrix.up*(bbz2 + 0.5))
end

function VehicleFuel:stopInteraction(state)
	if not state then return end

	self.m_FuelProgress:stopAnimation()
	toggleAllControls(true, true, false)
	setPedControlState("fire", false)
end

function VehicleFuel:onStreamIn(surface)
	GUIImage:new(0, 0, 128, 128, "files/images/Speedo/fuel.png", surface)
	self.m_Needle = GUIImage:new(0, 0, 128, 128, "files/images/Speedo/fuel_needle.png", surface)
	self.m_Needle.m_Rotation = (self.m_Fuel + self.m_FuelOffset)*180/100
	self.m_Surface = surface
end

function VehicleFuel:updateRenderTarget()
	if not self.m_Needle then return end
	self.m_Needle.m_Rotation = (self.m_Fuel + self.m_FuelOffset)*180/100
	self.m_Surface:anyChange()
end

function VehicleFuel.forceClose()
	if VehicleFuel:isInstantiated() then
		delete(VehicleFuel:getSingleton())
	end
end
addEventHandler("forceCloseVehicleFuel", root, VehicleFuel.forceClose)
