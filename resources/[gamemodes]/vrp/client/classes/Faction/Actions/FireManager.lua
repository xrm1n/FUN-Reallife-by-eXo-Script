FireManager = inherit(Singleton)
FireManager.Settings = {
	["smoke"] = true,
	["smokeRenderDistance"] = 100,
	["fireRenderDistance"] = 25,
	["extinguishTime"] = 50,
	["extraEffects"] = true,
}

FireManager.EffectFromFireSize = {
	[1] = "fire",
	[2] = "fire_med",
	[3] = "fire_large",
}

function FireManager:constructor()
	self.m_Fires = {}
	self.m_LoadingQueue = AutomaticQueue:new()
	self.m_FiresWaitingForColUpdate = {}
	self.m_StatisticShortMessage = {}

	addRemoteEvents{"fireElements:onClientRecieveFires", "fireElements:onFireCreate", "fireElements:onFireDestroy", "fireElements:onFireChangeSize", "refreshFireStatistics"}

	addEventHandler("fireElements:onFireCreate", resourceRoot, bind(self.createFireElement, self))
	addEventHandler("fireElements:onFireDestroy", resourceRoot, bind(self.destroyFireElement, self))
	addEventHandler("fireElements:onFireChangeSize", resourceRoot, bind(self.changeFireSize, self))
	addEventHandler("onClientPedHitByWaterCannon", root, bind(self.handlePedWaterCannon, self))
	addEventHandler("refreshFireStatistics", root, bind(self.updateStatistics, self))
	addCommandHandler("reloadFires", bind(self.reloadFiresIfBugged, self), false, false)


	addEventHandler("fireElements:onClientRecieveFires", resourceRoot, bind(self.processInitialFireSync, self))
	triggerServerEvent("fireElements:onClientRequestsFires", root)
end

function FireManager:processInitialFireSync(tblFires)
	for ped, size in pairs(tblFires) do
		self:createFireElement(size, ped, true)
	end
end

function FireManager:destroyElementIfExists(uElement)
	if isElement(uElement) then
		destroyElement(uElement)
		return true
	end
	return false
end

--//
--||  destroyFireElement (local)
--||  	parameters:
--||  		uElement	= the fire element
--||  	returns: success of the function
--\\

function FireManager:destroyFireElement(uElement)
	if self.m_Fires[uElement] then
		self:destroyElementIfExists(self.m_Fires[uElement].uEffect)
		self:destroyElementIfExists(self.m_Fires[uElement].uBurningCol)
		local uSmoke = self.m_Fires[uElement].uSmokeEffect
		if isElement(uSmoke) then setTimer(bind(self.destroyElementIfExists, self), 5000, 1, uSmoke) end -- allow smoke to disappear
		self.m_Fires[uElement] = nil
		return true
	end
	return false
end


--//
--||  handleSmoke (local)
--||  	parameters:
--||  		uFire		= the fire element
--\\

function FireManager:handleSmoke(uFire)
	if FireManager.Settings["smoke"] then
		local iX, iY, iZ	= getElementPosition(localPlayer)
		local iFX, iFY, iFZ = getElementPosition(uFire)
		if getDistanceBetweenPoints3D(iX, iY, iZ, iFX, iFY, iFZ) < FireManager.Settings["smokeRenderDistance"] then
			if self.m_Fires[uFire] and not self.m_Fires[uFire].iSmokeEffectTime or getTickCount()-self.m_Fires[uFire].iSmokeEffectTime > 2000 then
				self:destroyElementIfExists(self.m_Fires[uFire].uSmokeEffect)
				local iX, iY, iZ = getElementPosition(uFire)
				local effect = createEffect("explosion_door", iX, iY, iZ)
					setEffectSpeed(effect, 0.5)
					setEffectDensity(effect, self.m_Fires[uFire].iSize/3*2)
				self.m_Fires[uFire].iSmokeEffectTime = getTickCount()
				self.m_Fires[uFire].uSmokeEffect = effect
			end
		end
	end
end


--//
--||  handlePedDamage (local)
--||  	parameters:
--||  		uAttacker, iWeap	= event parameters
--\\

function FireManager:handlePedDamage(uAttacker, iWeap)
	cancelEvent()
	if self.m_Fires[source] then
		if iWeap == 42 then -- extinguisher
			self:handleSmoke(source)
			if uAttacker == localPlayer and math.random(1, FireManager.Settings["extinguishTime"]) == 1 then
				triggerServerEvent("fireElements:requestFireDeletion", source, self.m_Fires[source].iSize)
			end
		end
	end
end

--//
--||  handlePedWaterCannon (local)
--||  	parameters:
--||  		uPed		= event parameter
--\\

function FireManager:handlePedWaterCannon(uPed)
cancelEvent()
	if self.m_Fires[uPed] then
		if getElementModel(source) == 407 then -- fire truck
		self:handleSmoke(uPed)
			if getVehicleController(source) == localPlayer and math.random(1, FireManager.Settings["extinguishTime"]/3) == 1 then
				triggerServerEvent("fireElements:requestFireDeletion", uPed, self.m_Fires[uPed].iSize)
			end
		end
	end
end


--//
--||  burnPlayer (local)
--||  	parameters:
--||  		uHitElement,bDim	= event parameter
--\\

function FireManager:burnPlayer(uHitElement, bDim)
	if not bDim then return end
	if getElementType(uHitElement) == "player" then
		setPedOnFire(uHitElement, true)
	end
end


--//
--||  changeFireSize (local)
--||  	parameters:
--||  		iSize			= the new size of the fire
--\\

function FireManager:changeFireSize(iSize)
	if self.m_Fires[source] then
		self.m_Fires[source].iSize = iSize
		self:destroyElementIfExists(self.m_Fires[source].uEffect)
		self:destroyElementIfExists(self.m_Fires[source].uBurningCol)
		local iX, iY, iZ = getElementPosition(source)
		self.m_Fires[source].uEffect = createEffect(FireManager.EffectFromFireSize[iSize], iX, iY, iZ,-90, 0, 0, FireManager.Settings["fireRenderDistance"]*iSize, true)
		self.m_Fires[source].uBurningCol = createColSphere(iX, iY, iZ + (self.m_Fires[source].iMaterialID and 1 or 0), iSize/4) -- set the col shape higher when correct ground position got determined
		addEventHandler("onClientColShapeHit", self.m_Fires[source].uBurningCol, bind(self.burnPlayer, self))
		self.m_Fires[source].bCorrectPlaced = false -- force recalculate the height
		self:checkForFireGroundInfo(source)
	end
end


--//
--||  getFireSize
--||  	parameters:
--||  		uFire			= the fire
--\\

function FireManager:getFireSize(uFire)
	if self.m_Fires[uFire] then
		return self.m_Fires[uFire].iSize
	end
end


--//
--||  checkForFireGroundInfo
--||  	parameters:
--||  		uFire			= the fire
--\\

function FireManager:checkForFireGroundInfo(uFire)
	if self.m_Fires[uFire] then
		local iX, iY, iZ = getElementPosition(uFire)
		if FireManager.Settings["extraEffects"] then -- black outline on the ground
			createExplosion (iX, iY, iZ-2, 12, false, 0, false)
		end
		if not self.m_Fires[uFire].bCorrectPlaced and isElementStreamedIn(uFire) then
			local iNewZ = getGroundPosition(iX, iY, iZ + 100)
			setElementPosition(uFire, iX, iY, iNewZ+(self.m_Fires[uFire].iSize/3))
			setElementPosition(self.m_Fires[uFire].uEffect, iX, iY, iNewZ)
			setElementPosition(self.m_Fires[uFire].uBurningCol, iX, iY, iNewZ+1)
			if self.m_Fires[uFire].uEffect:getPosition().z ~= 0 then
				self.m_Fires[uFire].bCorrectPlaced = true
			end

			setElementCollisionsEnabled(uFire, true)
			setElementCollidableWith (uFire, localPlayer, false)
			uFire:setHealth(100)
			for index, vehicle in pairs(getElementsByType("vehicle", root, true)) do
				if uFire and isElement(uFire) and vehicle and isElement(vehicle) then
					setElementCollidableWith(vehicle, uFire, false)
				end
			end
		end
		if not isElementStreamedIn(uFire) then return "nicht eingestreamed" end
		if self.m_Fires[uFire].uEffect:getPosition().z == 0 then return "z auf 0" end
		if self.m_Fires[uFire].uEffect:getPosition().z == self.m_Fires[uFire].baseZ then return "z auf Basishöhe" end
		return "kein Fehler gefunden"
	end
	return "nicht in der Tabelle"
end

--//
--||  createFireElement (local)
--||  	parameters:
--||  		iSize			= the size of the fire
--||  		uPed			= the ped element synced by the server
--\\

function FireManager:createFireElement(iSize, uPed)
	if not uPed then uPed = source end
	local iX, iY, iZ = getElementPosition(uPed)
	self.m_Fires[uPed] = {}
	self.m_Fires[uPed].iSize = iSize
	self.m_Fires[uPed].baseZ = iZ
	self.m_Fires[uPed].uEffect = createEffect(FireManager.EffectFromFireSize[iSize], iX, iY, iZ,-90, 0, 0, FireManager.Settings["fireRenderDistance"]*iSize)
	self.m_Fires[uPed].uBurningCol = createColSphere(iX, iY, iZ, iSize/4)
	setElementCollisionsEnabled(uPed, false) --temporary until stream in
	self:checkForFireGroundInfo(uPed)
	uPed:setData("NPC:Immortal", true)
	addEventHandler("onClientPedDamage", uPed, bind(self.handlePedDamage, self))
	addEventHandler("onClientColShapeHit", self.m_Fires[uPed].uBurningCol, bind(self.burnPlayer, self))
	addEventHandler("onClientElementStreamIn", uPed, function()
		setTimer(function() -- allow the client to let the element fully stream in as this process is apparently asynchronous
			if isElement(uPed) and isElementStreamedIn(uPed) then
				self:checkForFireGroundInfo(uPed)
			end
		end, 500, 1)
	end)
end

function FireManager:updateStatistics(tblStats, timeSinceStart, timeEstimated, w, h)
	if not self.m_StatisticShortMessage[tblStats.name] then
		self.m_StatisticShortMessage[tblStats.name] = ShortMessage:new("", "Brand-Übersicht ("..(tblStats.name)..")", Color.Orange, 6000, nil, function()
			self.m_StatisticShortMessage[tblStats.name] = nil
		end)
	end
	local sm = self.m_StatisticShortMessage[tblStats.name]

	local t = ("Zeit seit Ausbruch: %s\nFlammen: %s aktiv, %s seit Ausbruch\n\nbeteiligte Einsatzkräfte:"):format(string.duration((timeSinceStart)/1000), tblStats.firesActive, tblStats.firesTotal)

	for i, v in pairs(tblStats.pointsByPlayer) do
		t = t.. ("\n %s - %s Punkte (%s Feuer gelöscht)"):format(i:getName(), v, tblStats.firesByPlayer[i] or 0)
	end
	if DEBUG then
		t = t.. ("\n\n~~~DEBUG~~~\nDimension (w,h): %s, %s\ngeschätzte Lösch-Zeit (min): %s"):format(w, h, string.duration((timeEstimated)/1000))
	end
	sm:setText(t)
	sm:resetTimeout()
end

function FireManager:reloadFiresIfBugged()
	local count = {}
	for ped, fire in pairs(self.m_Fires) do
		local r = self:checkForFireGroundInfo(ped)
		if not count[r] then count[r] = 0 end
		count[r] = count[r] + 1
	end
	ShortMessage:new(inspect(count), _"aktualisierte Feuer")
end