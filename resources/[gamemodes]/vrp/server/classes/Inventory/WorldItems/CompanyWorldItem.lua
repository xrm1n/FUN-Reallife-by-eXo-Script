-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/CompanyWorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
CompanyWorldItem = inherit(WorldItem)

function CompanyWorldItem:setCompanySuperOwner(state) --disallows the owner to interact with the object if he is not part of the OwnerGroup
	self.m_SuperOwner = state
	self.m_Object:setData("SuperOwner", state, true)
end

function CompanyWorldItem:setMinRank(rank)
	self.m_MinRank = rank
	self.m_Object:setData("MinRank", rank, true)
end

function CompanyWorldItem:hasPlayerPermissionTo(player, action)
	if not isElement(player) or player:getType() ~= "player" then return false end
	local rank = self.m_MinRank or 0
	if action == WorldItem.Action.Move then
		if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
			if self:getObject() and (player:getCompany() ~= self:getOwner() or not (player:isCompanyDuty())) then --just show it if the player used his moderator rights
				local x, y, z = getElementPosition(self:getObject())
				local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
				self:getOwner():sendShortMessage(("%s %s verschiebt euer Objekt %s in %s, %s!"):format(RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2))
				return true 
			end
		end
		if player:getCompany() == self:getOwner() and player:isCompanyDuty() then
			if player:getCompany():getPlayerRank(player) >= rank then
				return true
			else
				player:sendError(_("Dazu benötigst du mindestens Rang %d.", player, rank))
			end
		elseif self:getPlacer() == player and not self.m_SuperOwner then
			return true
		else
			player:sendError(_("Dieses Objekt gehört dem Unternehmen %s.", player, self:getOwner():getName()))
			return false
		end
		return false
	elseif action == WorldItem.Action.Collect then
		if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
			--outputDebug("admin rights")
			return true 
		end
		if player:getCompany() == self:getOwner() and player:isCompanyDuty() then
			--outputDebug("faction and duty")
			if player:getCompany():getPlayerRank(player) >= rank then
				--outputDebug("rank")
				return true
			else
				player:sendError(_("Dazu benötigst du mindestens Rang %d.", player, rank))
			end
		elseif self:getPlacer() == player and not self.m_SuperOwner then
			 --outputDebug("private")
			return true
		else
			player:sendError(_("Dieses Objekt gehört dem Unternehmen %s.", player, self:getOwner():getName()))
			return false
		end
		return false
	elseif action == WorldItem.Action.Delete then
		if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
			if self:getObject() and (player:getCompany() ~= self:getOwner() or not (player:isCompanyDuty())) then --just show it if the player used his moderator rights
				local x, y, z = getElementPosition(self:getObject())
				local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
				self:getOwner():sendShortMessage(("%s %s hat euer Objekt %s in %s, %s gelöscht!"):format(RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2))
				return true
			end
		end
		if player:getCompany() == self:getOwner() and player:isCompanyDuty() then
			if player:getCompany():getPlayerRank(player) >= OBJECT_DELETE_MIN_RANK then
				local x, y, z = getElementPosition(self:getObject())
				local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
				self:getOwner():sendShortMessage(("%s hat das Objekt %s in %s, %s gelöscht!"):format(player:getName(), self.m_ItemName, zone1, zone2))
				return true
			else
				player:sendError(_("Um das Objekt %s zu löschen benötigst du mindestens Rang %d", player, self.m_ItemName, OBJECT_DELETE_MIN_RANK))
				return false
			end
		else
			player:sendError(_("Dieses Objekt gehört dem Unternehmen %s", player, self:getOwner():getName()))
			return false
		end
	end
end
