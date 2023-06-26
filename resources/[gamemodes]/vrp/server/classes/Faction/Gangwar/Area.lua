-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/Area.lua
-- *  PURPOSE:     Gangwar Area Class
-- *
-- ****************************************************************************

Area = inherit(Object)

function Area:constructor( dataset, pGManager )
	self.m_Name = dataset["Name"]
	self.m_ID = dataset["ID"]
	self.m_Owner = tonumber(dataset["Besitzer"])
	self.m_LastAttack = dataset["lastAttack"]
	self.m_Position = {tonumber(dataset["x"]),tonumber(dataset["y"]),tonumber(dataset["z"])}
	self.m_PositionRadar = {tonumber(dataset["cX"]),tonumber(dataset["cY"]),tonumber(dataset["cX2"]),tonumber(dataset["cY2"])}
	self.m_CarCount = dataset["Autos"]
	self:createCenterCol( )
	self:createRadar()
	self.m_GangwarManager = pGManager
	self:createCenterPickup()
end

function Area:destructor( )
	if self.m_Pickup and isElement(self.m_Pickup) then destroyElement(self.m_Pickup) end
	if self.m_RadarArea then delete(self.m_RadarArea) end
	if self.m_CenterSphere and isElement(self.m_CenterSphere) then destroyElement(self.m_CenterSphere) end
	if self.m_BlipImage then self.m_BlipImage:delete() end
	if self.m_AttackSession then self.m_AttackSession:stopClients( true ); self.m_AttackSession:delete() end
	self:destroySurroundingCol()
end

function Area:getName()
	return self.m_Name
end

function Area:getPosition()
	return self.m_Position
end

function Area:getLastAttack()
	return self.m_LastAttack
end

function Area:getOwnerId()
	return self.m_Owner
end

function Area:getId() 
	return self.m_ID
end

function Area:createRadar()
	local areaX,areaY = self.m_PositionRadar[1],self.m_PositionRadar[2]
	local areaX2, areaY2 = self.m_PositionRadar[3],self.m_PositionRadar[4]
	local areaWidth = math.abs(areaX -  areaX2)
	local areaHeight = math.abs(areaY - areaY2)
	local factionColor = factionColors[self.m_Owner]
	if factionColor then
		 factionColor = setBytesInInt32(150,factionColor.r,factionColor.g,factionColor.b)
	else factionColor = GANGWAR_DUMP_COLOR
	end
	if self.m_IsAttacked then
		factionColor = setBytesInInt32(150,220,0,0)
	end
	self.m_RadarArea = RadarArea:new(areaX, areaY, areaWidth, -1*areaHeight,factionColor )
end

--colshape where players who do not participate in the gang war get a warning
function Area:createSurroundingCol()
	if self.m_SurroundingCol then self:destroySurroundingCol() end
	local surroundingDistance = 100
	local areaX,areaY = self.m_PositionRadar[1],self.m_PositionRadar[2]
	local areaX2, areaY2 = self.m_PositionRadar[3],self.m_PositionRadar[4]
	local centerZ = self.m_Position[3]
	local areaWidth = math.abs(areaX -  areaX2) + surroundingDistance*2
	local areaHeight = math.abs(areaY - areaY2) + surroundingDistance*2

	self.m_SurroundingCol = createColCuboid (areaX-surroundingDistance, areaY-surroundingDistance, centerZ - surroundingDistance, areaWidth, areaHeight, surroundingDistance*2 )
	addEventHandler("onColShapeHit" ,self.m_SurroundingCol, bind(self.onSurroundingEnter,self))
end

function Area:destroySurroundingCol()
	if self.m_SurroundingCol and isElement(self.m_SurroundingCol) then
		destroyElement(self.m_SurroundingCol)
		self.m_SurroundingCol = nil
	end
end

--player is near a gang zone, but did not enter it by now
function Area:onSurroundingEnter(hitElement, dim)
	if hitElement and getElementType(hitElement) == "player" and dim and not hitElement:isInGangwar() then
		hitElement:sendWarning("Du näherst dich einem aktiven Gangwar-Gebiet! Bitte verlasse dieses Areal und nutze eine andere Route oder warte, bis der Kampf vorbei ist.")
	end
end

function Area:createCenterPickup()
	local x,y,z = self.m_Position[1],self.m_Position[2],self.m_Position[3]
	self.m_Pickup = createPickup( x,y,z ,3,2993,5)
end

function Area:createCenterCol()
	local x,y,z = self.m_Position[1],self.m_Position[2],self.m_Position[3]
	self.m_CenterSphere = createColSphere(x,y,z-1,GANGWAR_CENTER_HOLD_RANGE+1) --+1 because the gangwar includes 15m as inside the col, but isElementWithinCol not
	addEventHandler("onColShapeHit",self.m_CenterSphere,bind(self.onCenterEnter,self))
	addEventHandler("onColShapeLeave",self.m_CenterSphere,bind(self.onCenterLeave,self))
	local tElements = getElementsWithinColShape(self.m_CenterSphere,"player")
	for key,player in ipairs(tElements) do
		player.m_InsideArea = self
	end
end

function Area:attack( faction1, faction2, attackingPlayer)
	if not self.m_IsAttacked then
		self.m_IsAttacked = true
		faction1:sendMessage("[Gangwar] #FFFFFFIhre Fraktion hat einen Attack gestartet! ( Gebiet: "..self.m_Name.." )", 0,204,204,true)
		faction2:sendMessage("[Gangwar] #FFFFFFIhre Fraktion wurde attackiert von "..faction1.m_Name_Short.." ! ( Gebiet: "..self.m_Name.." )", 204,20,0,true)
		self.m_AttackSession = AttackSession:new( self, faction1 , faction2, attackingPlayer)
		self.m_LastAttack = getRealTime().timestamp
		self.m_RadarArea:delete()
		self.m_BlipImage = Blip:new("Gangwar.png", self.m_Position[1], self.m_Position[2], {faction = {faction1:getId(), faction2:getId()}}, 9999)
		self:createRadar()
		self.m_GangwarManager.m_GangwarGuard:addAttack( faction1 )
		local attackCount = self.m_GangwarManager.m_GangwarGuard:getAttackCount( faction1 )
		faction1:sendMessage("[Gangwar] #FFFFFFDurch diesen Attack (Nr. "..attackCount..") ist eure Cooldown-Zeit auf ".. (30+(10*attackCount)).." Sekunden gestiegen !", 204,204, 0,true)
		self.m_RadarArea:setFlashing(true)
		setPickupType(self.m_Pickup,3,GANGWAR_ATTACK_PICKUPMODEL)
		self.m_GangwarManager:addAreaToAttacks( self )
		self:createSurroundingCol()
		faction1:addLog(attackingPlayer, "Gangwar", ("hat das Gebiet %s attackiert!"):format(self.m_Name))
	end
end

function Area:onCenterLeave( leaveElement,dimension )
	if dimension then
		local bType = getElementType(leaveElement) == "player"
		if bType then
			leaveElement.m_InsideArea = nil
			if self.m_IsAttacked then
				self.m_AttackSession:onPlayerLeaveCenter( leaveElement )
			end
		end
	end
end

function Area:onCenterEnter( hitElement,dimension )
	if dimension then
		local bType = getElementType(hitElement) == "player"
		if bType then
			hitElement.m_InsideArea = self
			if self.m_IsAttacked then
				self.m_AttackSession:onPlayerEnterCenter( hitElement )
			end
		end
	end
end

--// :attackEnd //
-- @param_desc: id = WinnerID
function Area:attackEnd(  )
	if self.m_IsAttacked then
		self.m_RadarArea:setFlashing(false)
		delete(self.m_AttackSession)
		self.m_AttackSession = nil
		self.m_IsAttacked = false
		self.m_RadarArea:delete()
		self:createRadar()
		self.m_BlipImage:delete()
		setPickupType(self.m_Pickup,3,2993)
		self.m_GangwarManager:removeAreaFromAttacks( )
		self:destroySurroundingCol()
	end
end

--// :update //
--// @desc: update sql values
function Area:update()
	local sql_query = "UPDATE ??_gangwar SET Besitzer=?,lastAttack=? WHERE ID=?"
	sql:queryFetch(sql_query,sql:getPrefix(),self.m_Owner,self.m_LastAttack,self.m_ID)
end

function Area:isUnderAttack( )
	return self.m_IsAttacked
end

function Area:getMatchFactions()
	if self.m_IsAttacked then
		return self.m_AttackSession:getFactions()
	end
end
