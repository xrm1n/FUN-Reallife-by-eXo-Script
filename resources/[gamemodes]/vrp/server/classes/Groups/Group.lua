-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/Group.lua
-- * PURPOSE: Group class
-- *
-- ****************************************************************************
Group = inherit(Object)

function Group:constructor(Id, name, type, money, playTime, lastNameChange, rankNames, rankLoans, rankPermissions)
	if not players then players = {} end -- can happen due to Group.create using different constructor

	self.m_Id = Id
	self.m_Players = {}
	self.m_PlayerLoans = {}
	self.m_PlayerActivity = {}
	self.m_PlayerPermissions = {}
	self.m_LastActivityUpdate = 0
	self.m_Name = name
	self.m_Money = money or 0
	self.m_PlayTime = playTime or 0
	self.m_IsActive = false
	self.m_ProfitProportion = 0.5 -- Amount of money for the group fund
	self.m_Invitations = {}
	self.m_LastNameChange = lastNameChange or 0
	self.m_Type = type
	self.m_Shops = {} -- shops automatically add the reference
	self.m_Markers = {}
	self.m_Vehicles = {}
	self.m_MarkersAttached = false
	self.m_BankAccountServer = BankServer.get("group")
	self.m_Settings = UserGroupSettings:new(USER_GROUP_TYPES.Group, Id)

	self.m_BankAccount = BankAccount.loadByOwner(self.m_Id, BankAccountTypes.Group)
	if not self.m_BankAccount then
		outputServerLog("Create account for " .. self.m_Id .. " " .. inspect(self.m_BankAccount))
		self.m_BankAccount = BankAccount.create(BankAccountTypes.Group, self.m_Id)
		self.m_BankAccountServer:transferMoney(self.m_BankAccount, self.m_Money, "Migration", "Group", "Migration")
		self.m_Money = 0
		self.m_BankAccount:save()
	end

	self.m_VehiclesSpawned = false

	local saveRanks = false
	if not rankNames or rankNames == "" then rankNames = {} for i=0,6 do rankNames[i] = "Rang "..i end rankNames = toJSON(rankNames) outputDebug("Created RankNames for group "..Id) saveRanks = true end
	if not rankLoans or rankLoans == "" then rankLoans = {} for i=0,6 do rankLoans[i] = 0 end rankLoans = toJSON(rankLoans) outputDebug("Created RankLoans for group "..Id) saveRanks = true end
	if not rankPermissions or rankPermissions == "" then rankPermissions = {} for i=0,6 do rankPermissions[i] = PermissionsManager:getSingleton():createRankPermissions("group", self.m_Id, i) end rankPermissions = toJSON(rankPermissions) outputDebug("Created RankPermissions for group "..Id) saveRanks = true end


	self.m_RankNames = fromJSON(rankNames)
	self.m_RankLoans = fromJSON(rankLoans)
	self.m_RankPermissions = fromJSON(rankPermissions)
	
	if saveRanks == true then
		self:saveRankSettings()
	end


	self.m_PhoneNumber = (PhoneNumber.load(4, self.m_Id) or PhoneNumber.generateNumber(4, self.m_Id))
	self.m_PhoneTakeOff = bind(self.phoneTakeOff, self)
end

function Group:destructor()
end

function Group.create(name, type)
	if sql:queryExec("INSERT INTO ??_groups (Name,Type) VALUES(?,?)", sql:getPrefix(), name,type) then
		local group = Group:new(sql:lastInsertId(), name, GroupManager.GroupTypes[type])

		-- Add refernece
		GroupManager:getSingleton():addRef(group)

		return group
	end
	return false
end

function Group:purge()
	if sql:queryExec("UPDATE ??_groups SET Deleted = NOW() WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		self:save()
		--remove active props
		GroupPropertyManager:getSingleton():takePropsFromGroup(self)
		-- Remove all players
		for playerId in pairs(self.m_Players) do
			self:removePlayer(playerId)
		end

		-- Remove reference
		GroupManager:getSingleton():removeRef(self)

		-- Free owned gangareas
		-- GangAreaManager:getSingleton():freeAreas()

		-- TODO: Should we also free the number?

		return true
	end
	return false
end

function Group:getId()
	return self.m_Id
end

function Group:getType()
	return self.m_Type
end

function Group:getColor()
	return self:getType() == "Firma" and {0, 100, 250} or {150, 0, 0}
end

function Group:setType(type, player)
	if type == "Firma" or type == "Gang" then
		self.m_Type = type
		for i, player in pairs(self:getOnlinePlayers()) do
			player:setPublicSync("GroupType", self:getType())
		end
		for k, vehicle in pairs(self:getVehicles() or {}) do
			setElementData(vehicle, "GroupType", self:getType())
		end
	else
		player:sendError(_("Invalid Group Type", player))
	end
end

function Group:onPlayerJoin(player)
	self.m_IsActive = true
	self:sendShortMessage(_("%s ist gejoint!", player, player:getName()))
	if self.m_MarkersAttached == true then
		self.m_Markers[player] = createMarker(player:getPosition(),"arrow",0.4,255,0,0,125)
		self.m_Markers[player]:setDimension(player:getDimension())
		self.m_Markers[player]:setInterior(player:getInterior())
		self.m_Markers[player]:attach(player,0,0,1.5)
		self.m_RefreshAttachedMarker = bind(self.refreshAttachedMarker, self)
		self.m_RemovePlayerMarkerOnQuit = bind(self.Event_RemovePlayerMarkerOnQuit, self)
		addEventHandler("onElementDimensionChange", player, self.m_RefreshAttachedMarker)
		addEventHandler("onElementInteriorChange", player, self.m_RefreshAttachedMarker)
		addEventHandler("onPlayerQuit", player, self.m_RemovePlayerMarkerOnQuit)
	end

	GroupManager:getSingleton():addActiveGroup(self)
end

function Group:onPlayerQuit(player)
	if #self:getOnlinePlayers() == 0 then
		self.m_IsActive = false
		GroupManager:getSingleton():removeActiveGroup(self)
	end
end

function Group:getVehicles()
	return VehicleManager:getSingleton():getGroupVehicles(self.m_Id)
end

function Group:canVehiclesBeModified()
	return true
end

function Group:setName(name)
	local timestamp = getRealTime().timestamp
	if not sql:queryExec("UPDATE ??_groups SET Name = ?, lastNameChange = ?, RankNames = ?, RankLoans = ? WHERE Id = ?", sql:getPrefix(), name, timestamp, toJSON(self.m_RankNames), toJSON(self.m_RankLoans), self.m_Id) then
		return false
	end

	self.m_Name = name
	self.m_LastNameChange = timestamp

	for i, player in pairs(self:getOnlinePlayers()) do
		player:setPublicSync("GroupName", self:getName())
		player:setPublicSync("GroupType", self:getType())
	end

	for k, vehicle in pairs(self:getVehicles() or {}) do
		setElementData(vehicle, "OwnerName", name)
		setElementData(vehicle, "GroupType", self:getType())

	end

	return true
end

function Group:saveRankSettings()
	if not sql:queryExec("UPDATE ??_groups SET RankNames = ?, RankLoans = ?, RankPermissions = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_RankNames), toJSON(self.m_RankLoans), toJSON(self.m_RankPermissions), self.m_Id) then
		return false
	end
	return true
end

function Group:getId()
	return self.m_Id
end

function Group:getName()
	return self.m_Name
end

function Group:getPlayTime()
	return self.m_PlayTime
end

function Group:addPlayTime(time)
	self.m_PlayTime = self:getPlayTime() + time

	return self.m_PlayTime
end

function Group:setRankName(rank,name)
	self.m_RankNames[tostring(rank)] = name
end

function Group:setRankLoan(rank, amount)
	self.m_RankLoans[tostring(rank)] = tonumber(amount) or 0
end

function Group:updateRankNameSync()
	local ranks = table.copy(self.m_RankNames)
	for key, player in ipairs(self:getOnlinePlayers()) do
		player:setPublicSync("GroupRankNames", ranks)
	end
end

function Group:paydayPlayer(player)
	local rank = self.m_Players[player:getId()]
	local loanEnabled = self:isPlayerLoanEnabled(player:getId())
	local loan = loanEnabled and tonumber(self.m_RankLoans[tostring(rank)]) or 0

	if self:getMoney() < loan then loan = self:getMoney() end
	if loan < 0 then loan = 0 end
	return loan
end

function Group:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or GroupRank.Normal
	self.m_Players[playerId] = rank
	self.m_PlayerLoans[playerId] = 1
	self.m_PlayerPermissions[playerId] = {}
	local player = Player.getFromId(playerId)
	if player then
		player:setGroup(self)
		player:reloadBlips()
		if self.m_Type == "Gang" then
			player:giveAchievement(8)
		elseif self.m_Type == "Firma" then
			player:giveAchievement(28)
		end
		PermissionsManager:getSingleton():syncPermissions(player, "group")
	end

	sql:queryExec("UPDATE ??_character SET GroupId = ?, GroupRank = ?, GroupLoanEnabled = 1 WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)
	local props = GroupPropertyManager:getSingleton():getPropsForPlayer( player )
	local x,y,z
	for k,v in ipairs( props ) do
		player:triggerEvent("addPickupToGroupStream",v.m_ExitMarker, v.m_Id)
		x,y,z = getElementPosition( v.m_Pickup )
		player:triggerEvent("createGroupBlip", x, y, z, v.m_Id, self.m_Type)
	end

	Async.create(
		function(self)
			self:getActivity(true)
		end
	)(self)
end

function Group:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	self.m_PlayerLoans[playerId] = nil
	self.m_PlayerPermissions[playerId] = nil
	local player = Player.getFromId(playerId)
	local props = GroupPropertyManager:getSingleton():getPropsForPlayer( player )
	for k,v in ipairs( props ) do
		player:triggerEvent("destroyGroupBlip",v.m_Id)
		player:triggerEvent("forceGroupPropertyClose")
	end
	if player then
		player:saveAccountActivity()
		setElementData(player, "playingTimeGroup", 0)
		player:setGroup(nil)
		if isElement(player) then
			player:reloadBlips()
			player:sendShortMessage(_("Du wurdest aus deiner %s entlassen!", player, self:getType()))
			self:sendShortMessage(_("%s hat deine %s verlassen!", player, player:getName(), self:getType()))
		end
		PermissionsManager:getSingleton():syncPermissions(player, "group", true)
	end
	sql:queryExec("UPDATE ??_character SET GroupId = 0, GroupRank = 0, GroupLoanEnabled = 0 WHERE Id = ?", sql:getPrefix(), playerId)
	self:removePlayerMarker(player)
	self:checkDespawnVehicle()
end

function Group:invitePlayer(player)
	client:sendShortMessage(("Du hast %s erfolgreich in deine %s eingeladen."):format(getPlayerName(player), self:getType()))

	player:triggerEvent("groupInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = client.m_Id
end

function Group:removeInvitation(player)
	self.m_Invitations[player] = nil
end

function Group:hasInvitation(player)
	return self.m_Invitations[player]
end

function Group:isPlayerMember(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId] ~= nil
end

function Group:getPlayerRank(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId]
end

function Group:setPlayerRank(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	self.m_Players[playerId] = rank
	sql:queryExec("UPDATE ??_character SET GroupRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
	local player = Player.getFromId(playerId)
	if player then
		if player.m_LastPropertyPickup then
			if rank < 1 then
				player:triggerEvent("forceGroupPropertyClose")
			else
				if player:getData("insideGroupInterior") then
					player:triggerEvent("setPropGUIActive", player.m_LastPropertyPickup)
				end
			end
		end
	end
end

function Group:isPlayerLoanEnabled(playerId)
	return self.m_PlayerLoans[playerId] == 1
end

function Group:setPlayerLoanEnabled(playerId, state)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_PlayerLoans[playerId] = state
	sql:queryExec("UPDATE ??_character SET GroupLoanEnabled = ? WHERE Id = ?", sql:getPrefix(), state, playerId)
end

function Group:savePlayerPermissions(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	sql:queryExec("UPDATE ??_character SET GroupPermissions = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_PlayerPermissions[tonumber(playerId)]) or toJSON({}), playerId)
end

function Group:getMoney()
	return self.m_BankAccount:getMoney()
end

function Group:__giveMoney(amount, reason, slient)
	StatisticsLogger:getSingleton():addMoneyLog("group", self, amount, reason or "Unbekannt")
	return self.m_BankAccount:__giveMoney(amount, reason, slient)
end

function Group:__takeMoney(amount, reason, slient)
	StatisticsLogger:getSingleton():addMoneyLog("group", self, -amount, reason or "Unbekannt")
	return self.m_BankAccount:__takeMoney(amount, reason, slient)
end

function Group:transferMoney(...)
	return self.m_BankAccount:transferMoney(...)
end

function Group:setSetting(category, key, value, responsiblePlayer)
	local allowed = true
	if responsiblePlayer and isElement(responsiblePlayer) and getElementType(responsiblePlayer) == "player" then
		if not responsiblePlayer:getGroup() then allowed = false end
		if responsiblePlayer:getGroup() ~= self then allowed = false end
		if category == "Equipment" then
			if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "group", "editEquipment") then allowed = false end
		elseif category == "Skin" then
			if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "group", "editRankSkins") then allowed = false end
		end
	end
	if allowed then
		self.m_Settings:setSetting(category, key, value)
	else
		responsiblePlayer:sendError(_("Du bist nicht berechtigt die %s Einstellungen zu ändern!", responsiblePlayer, category))
	end
end

function Group:getSetting(category, key, defaultValue)
	return self.m_Settings:getSetting(category, key, defaultValue)
end

--[[
function Group:__setMoney(amount)
	self.m_Money = amount

	sql:queryExec("UPDATE ??_groups SET Money = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Id)
end
]]
function Group:getActivity(force)
	if self.m_LastActivityUpdate > getRealTime().timestamp - 30 * 60 and not force then
		return
	end

	self.m_LastActivityUpdate = getRealTime().timestamp
	local playerIds = {}

	for playerId, rank in pairs(self.m_Players) do
		table.insert(playerIds, playerId)
	end

	local query = "SELECT UserId, FLOOR(SUM(Duration) / 60) AS Activity FROM ??_account_activity WHERE UserId IN (?" .. string.rep(", ?", #playerIds - 1) ..  ") AND Date BETWEEN DATE(DATE_SUB(NOW(), INTERVAL 1 WEEK)) AND DATE(NOW()) GROUP BY UserId"

	sql:queryFetch(Async.waitFor(), query, sql:getPrefix(), unpack(playerIds))

	local rows = Async.wait()

	self.m_PlayerActivity = {}
	for playerId, rank in pairs(self.m_Players) do
		self.m_PlayerActivity[playerId] = 0
	end

	for _, row in ipairs(rows) do
		local activity = 0

		if row and row.Activity then
			activity = row.Activity
		end

		self.m_PlayerActivity[row.UserId] = activity
	end
end

function Group:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end

	Async.create(
		function(self)
			self:getActivity()
		end
	)(self)

	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		local loanEnabled = self.m_PlayerLoans[playerId]
		local activity = self.m_PlayerActivity[playerId] or 0

		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank, loanEnabled = loanEnabled, activity = activity}
	end
	return temp
end

function Group:getPlayerNamesFromLog(getIDsOnly)
	local userIDs = StatisticsLogger:getSingleton():getGroupLogUserIDs("group", self.m_Id) or {}
	local temp = {}

	for _, row in pairs(userIDs) do
		temp[row.UserId] = {name = Account.getNameFromId(row.UserId)}
	end
	return temp
end

function Group:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player and isElement(player) and player:isLoggedIn() and not player:isDisconnecting() then
			players[#players + 1] = player
		end
	end
	return players
end

function Group:sendChatMessage(sourcePlayer, message)
	if not getElementData(sourcePlayer, "GroupChatEnabled") then return sourcePlayer:sendError(_("Du hast den Gruppenchat deaktiviert!", sourcePlayer)) end
	local lastMsg, msgTimeSent = sourcePlayer:getLastChatMessage()
	if getTickCount()-msgTimeSent < (message == lastMsg and CHAT_SAME_MSG_REPEAT_COOLDOWN or CHAT_MSG_REPEAT_COOLDOWN) then -- prevent chat spam
		cancelEvent()
		return
	end
	sourcePlayer:setLastChatMessage(message)

	local playerId = sourcePlayer:getId()
	local rank = self.m_Players[playerId]
	local rankName = self.m_RankNames[tostring(rank)]
	local receivedPlayers = {}
	message = message:gsub("%%", "%%%%")
	local text = ("[%s] %s %s: %s"):format(self:getName(), rankName, sourcePlayer:getName(), message)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if getElementData(player, "GroupChatEnabled") then
			player:sendMessage(text, 0, 255, 150)
		end
		if player ~= sourcePlayer then
			receivedPlayers[#receivedPlayers+1] = player
		end
	end
	StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "group:"..self.m_Id, message, receivedPlayers)
end

function Group:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Group:sendShortMessage(text, timeout)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendShortMessage(("%s"):format(text), self:getName(), self:getColor(), timeout)
	end
end

function Group:sendMessageWithRank(text, r, g, b, minRank, withPrefix, ...)
	local r = r or 0
	local g = g or 255
	local b = b or 155
	local prefix = withPrefix and ("[%s] "):format(self:getName()) or ""

	for k, player in pairs(self:getOnlinePlayers()) do
		if self:getPlayerRank(player) >= (minRank or 0) then
			player:sendMessage(prefix .. text, r, g, b, true, ...)
		end
	end
end

function Group:sendShortMessageWithRank(text, minRank, title, color, ...)
	local color = {color.r or 0, color.g or 255, color.b or 155}
	local suffix = title and ": " .. title or ""
	for k, player in pairs(self:getOnlinePlayers()) do
		if self:getPlayerRank(player) >= (minRank or 0) then
			player:sendShortMessage(text, self:getName() .. suffix, color, ...)
		end
	end
end

function Group:distributeMoney(sender, amount, reason, category, subcategory)
	local moneyForFund = amount * self.m_ProfitProportion
	sender:transferMoney(self, moneyForFund, reason, category, subcategory)

	local moneyForPlayers = amount - moneyForFund
	local onlinePlayers = self:getOnlinePlayers()
	local amountPerPlayer = math.floor(moneyForPlayers / #onlinePlayers)

	for k, player in pairs(onlinePlayers) do
		sender:transferMoney(player, amountPerPlayer, reason, category, subcategory)
	end
end

function Group:attachPlayerMarkers()
	self.m_MarkersAttached = true
	self.m_Markers = {}
	for k, player in ipairs(self:getOnlinePlayers()) do
		self.m_Markers[player] = createMarker(player:getPosition(),"arrow",0.4,255,0,0,125)
		self.m_Markers[player]:setDimension(player:getDimension())
		self.m_Markers[player]:setInterior(player:getInterior())
		self.m_Markers[player]:attach(player,0,0,1.5)
		self.m_RefreshAttachedMarker = bind(self.refreshAttachedMarker, self)
		self.m_RemovePlayerMarkerOnQuit = bind(self.Event_RemovePlayerMarkerOnQuit, self)
		addEventHandler("onElementDimensionChange", player, self.m_RefreshAttachedMarker)
		addEventHandler("onElementInteriorChange", player, self.m_RefreshAttachedMarker)
		addEventHandler("onPlayerQuit", player, self.m_RemovePlayerMarkerOnQuit)
	end
end

function Group:attachPlayerMarker(player)
	if not self.m_Markers then self.m_Markers = {} end
	self.m_Markers[player] = createMarker(player:getPosition(),"arrow",0.4,255,0,0,125)
	self.m_Markers[player]:setDimension(player:getDimension())
	self.m_Markers[player]:setInterior(player:getInterior())
	self.m_Markers[player]:attach(player,0,0,1.5)
	self.m_RefreshAttachedMarker = bind(self.refreshAttachedMarker, self)
	self.m_RemovePlayerMarkerOnQuit = bind(self.Event_RemovePlayerMarkerOnQuit, self)
	addEventHandler("onElementDimensionChange", player, self.m_RefreshAttachedMarker)
	addEventHandler("onElementInteriorChange", player, self.m_RefreshAttachedMarker)
	addEventHandler("onPlayerQuit", player, self.m_RemovePlayerMarkerOnQuit)
end

function Group:removePlayerMarkers()
	self.m_MarkersAttached = false
	for k, player in ipairs(self:getOnlinePlayers()) do
		if self.m_Markers[player] then self.m_Markers[player]:destroy() end
		removeEventHandler("onElementDimensionChange", player, self.m_RefreshAttachedMarker)
		removeEventHandler("onElementInteriorChange", player, self.m_RefreshAttachedMarker)
		removeEventHandler("onPlayerQuit", player, self.m_RemovePlayerMarkerOnQuit)
	end
	self.m_Markers = {}
end

function Group:removePlayerMarker(player)
	if not self.m_Markers then return end
	if not self.m_Markers[player] then return end
	self.m_Markers[player]:destroy()
	removeEventHandler("onElementDimensionChange", player, self.m_RefreshAttachedMarker)
	removeEventHandler("onElementInteriorChange", player, self.m_RefreshAttachedMarker)
	removeEventHandler("onPlayerQuit", player, self.m_RemovePlayerMarkerOnQuit)
	self.m_Markers[player] = nil
end

function Group:Event_RemovePlayerMarkerOnQuit()
	if not self.m_Markers then return end
	if not self.m_Markers[source] then return end
	self.m_Markers[source]:destroy()
	removeEventHandler("onElementDimensionChange", source, self.m_RefreshAttachedMarker)
	removeEventHandler("onElementInteriorChange", source, self.m_RefreshAttachedMarker)
	removeEventHandler("onPlayerQuit", source, self.m_RemovePlayerMarkerOnQuit)
	self.m_Markers[source] = nil
end

function Group:refreshAttachedMarker(oldDimInt, dimInt)
	if not self.m_Markers then return end
	if not self.m_Markers[source] then return end
	if eventName == "onElementDimensionChange" then
		self.m_Markers[source]:setDimension(dimInt)
	elseif eventName == "onElementInteriorChange" then
		self.m_Markers[source]:setInterior(dimInt)
	end
end

function Group:phoneCall(caller)
	if #self:getOnlinePlayers() > 0 then
		for k, player in ipairs(self:getOnlinePlayers()) do
			if not player:getPhonePartner() then
				if player ~= caller then
					local color = self:getColor()
					triggerClientEvent(player, "callIncomingSM", resourceRoot, caller, false, ("%s ruft euch an."):format(caller:getName()), ("eingehender Anruf - %s"):format(self:getName()), color, "group")
				end
			end
		end
	else
		caller:sendShortMessage(_("Es ist aktuell kein Spieler der %s online!", caller, self:getType()))
		caller:triggerEvent("callBusy", caller)
	end
end


function Group:phoneCallAbbort(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		triggerClientEvent(player, "callRemoveSM", resourceRoot, caller, false)
	end
end

function Group:phoneTakeOff(player, caller, voiceCall)
	if player and caller then
		if instanceof(caller, Player) and instanceof(player, Player) then -- check if we can call methods from the Player-class
			if player.m_PhoneOn == false then
				player:sendError(_("Dein Telefon ist ausgeschaltet!", player))
				return
			end
			if player:getPhonePartner() then
				player:sendError(_("Du telefonierst bereits!", player))
				return
			end
			caller:triggerEvent("callAnswer", player, voiceCall)
			player:triggerEvent("callAnswer", caller, voiceCall)
			self:addLog(player, "Anrufe", ("hat ein Telefonat mit %s geführt!"):format(caller:getName()))
			caller:setPhonePartner(player)
			player:setPhonePartner(caller)
			for k, groupPlayer in ipairs(self:getOnlinePlayers()) do
				triggerClientEvent(groupPlayer, "callRemoveSM", resourceRoot, caller, player)
			end
		end
	end
end

function Group:insertPlayer(id, rank, loan, permissions)
	self.m_Players[id] = rank
	self.m_PlayerLoans[id] = loan
	self.m_PlayerPermissions[id] = fromJSON(permissions)
end

function Group:initalizePlayers()
	if not DEBUG then
		Async.create(
			function(self)
				self:getActivity()
			end
		)(self)
	end
	self:updateRankNameSync()
end

function Group:addLog(player, category, text)
	StatisticsLogger:getSingleton():addGroupLog(player, "group", self, category, text)
end

function Group:getLog()
	return StatisticsLogger:getSingleton():getGroupLogs("group", self.m_Id)
end

function Group:addShop(instance)
	table.insert(self.m_Shops, instance)
end

function Group:removeShop(instance)
	local idx = table.find(self.m_Shops, instance)
	if idx then
		table.remove(self.m_Shops, idx)
	end
end

function Group:getShops()
	return self.m_Shops
end

function Group:getPhoneNumber()
	return self.m_PhoneNumber:getNumber()
end

function Group:spawnVehicles()
	if not self.m_VehiclesSpawned then
		VehicleManager:getSingleton():loadGroupVehicles(self)
		self.m_VehiclesSpawned = true
	end
end

function Group:checkDespawnVehicle()
	if self.m_VehiclesSpawned and #self:getOnlinePlayers() == 0 then
		VehicleManager:getSingleton():destroyGroupVehicles(self)
		self.m_VehiclesSpawned = false
	end
end

function Group:respawnVehicles(player)
	local time = getRealTime().timestamp
	if self.m_LastRespawn then
		if time - self.m_LastRespawn <= 900 then --// 15min
			return self:sendShortMessage("Fahrzeuge können nur alle 15 Minuten respawned werden!")
		end
	end
	local groupVehicles = VehicleManager:getSingleton():getGroupVehicles(self.m_Id)
	local fails = 0
	local vehicles = 0
	local costs = 0
	for id, vehicle in pairs(groupVehicles) do
		vehicles = vehicles + 1
		costs = costs + 100
		if costs > self:getMoney() then
			self:sendShortMessage(("Ihr habt nicht genügend Geld um alle Fahrzeuge zu respawnen"):format(vehicles-fails, vehicles))
			break;
		end
		vehicle:removeAttachedPlayers()
		if not vehicle:respawn(false, true) then
			fails = fails + 1
		end
	end
	self.m_LastRespawn = getRealTime().timestamp
	-- adapted from VehicleManager
	self:transferMoney(VehicleManager:getSingleton():getServerBankAccount(), costs, "Fahrzeug-Respawn", "Vehicle", "Respawn")
	self:sendShortMessage(("%s/%s Fahrzeuge wurden von %s respawned!"):format(vehicles-fails, vehicles, player:getName()))
end

function Group:calculateVehicleTax(data)
	local sum = 0
	local tax
	for category, amount in pairs(data) do
		tax = VehicleCategory:getSingleton():getCategoryTax(category)
		if tax then
			tax = math.floor(tax/4)
			sum = sum + tax*amount
		end
	end
	return sum
end

function Group:payDay()
	local incomingPermanently = {}
	local incomingBonus = {}
	local outgoingPermanently = {}
	local outgoingSeperated = {}
	local output = {}

	incomingPermanently["Zinsen"] = 0
	incomingBonus["Spieler (offline)"] = 0
	incomingBonus["Spieler (online)"] = 0
	outgoingPermanently["Fahrzeugsteuern"] = 0

	if self:getMoney() > 0 then
		incomingPermanently["Zinsen"] = self:getMoney() > 300000 and math.floor(300000 * 0.0005) or math.floor(self:getMoney() * 0.0005)
	end

	for index, vehicle in pairs(self:getVehicles()) do
		local tax, isTowed = vehicle:getVehicleTaxForGroup()
		if not isTowed then
			outgoingPermanently["Fahrzeugsteuern"] = outgoingPermanently["Fahrzeugsteuern"] + vehicle:getVehicleTaxForGroup()
		else
			if not outgoingSeperated["Abstellhof Gebühren"] then
				outgoingSeperated["Abstellhof Gebühren"] = 0
			end
			outgoingSeperated["Abstellhof Gebühren"] = outgoingSeperated["Abstellhof Gebühren"] + vehicle:getVehicleTaxForGroup()
		end
	end

	for id in pairs(self:getPlayers()) do
		local player = Player.getFromId(id)

		if player then
			incomingBonus["Spieler (online)"] = incomingBonus["Spieler (online)"] + 100
		else
			local money = self.m_PlayerActivity[id] * 10

			if money > 100 then
				money = 100
			end

			incomingBonus["Spieler (offline)"] = incomingBonus["Spieler (offline)"] + money
		end
	end

	table.insert(output, "Payday:")

	for name, amount in pairs(incomingPermanently) do
		table.insert(output, ("%s: %d$"):format(name, amount))
	end

	for name, amount in pairs(incomingBonus) do
		if amount ~= 0 then
			table.insert(output, ("%s: %d$"):format(name, amount))
		end
	end

	for name, amount in pairs(outgoingPermanently) do
		table.insert(output, ("%s: %d$"):format(name, amount))
	end

	for name, amount in pairs(outgoingSeperated) do
		table.insert(output, ("%s: %d$"):format(name, amount))
	end

	local sum, inc, out = 0, 0, 0

	for name, amount in pairs(incomingPermanently) do
		inc = inc + amount
	end

	for name, amount in pairs(incomingBonus) do
		inc = inc + amount
	end

	for name, amount in pairs(outgoingPermanently) do
		out = out + amount
	end

	sum = inc - out
	table.insert(output, ("Gesamt: %d$"):format(sum))

	if sum > 0 then
		self.m_BankAccountServer:transferMoney({self, nil, true}, sum, "Payday", "Group", "Payday")
	elseif sum < 0 then
		self:transferMoney(self.m_BankAccountServer, sum * -1, "Payday", "Group", "Payday", {allowNegative = true, silent = true})
	end

	if outgoingSeperated["Abstellhof Gebühren"] then
		self:transferMoney({"company", CompanyStaticId.MECHANIC, true, true}, outgoingSeperated["Abstellhof Gebühren"], "Stellkosten", "Group", "Payday", {allowNegative = true, silent = true})
	end

	self:sendShortMessage(table.concat(output, "\n"), 10000)

	self:save()

	if self:getMoney() < 0 then
		if self.m_VehiclesSpawned then
			local mechanic = CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC)
			for index, vehicle in pairs(self:getVehicles()) do
				if not (vehicle:getPositionType() == VehiclePositionType.Mechanic) then
					mechanic:respawnVehicle(vehicle)
				end
			end
		else
			sql:queryExec("UPDATE ??_group_vehicles SET `PositionType` = ? WHERE `Group` = ?", sql:getPrefix(), VehiclePositionType.Mechanic, self:getId())
		end
		self:sendShortMessage("Alle eure Fahrzeuge wurden abgeschleppt, da euer Kontostand im Minus ist!")
	elseif self:getMoney() < (outgoingPermanently["Fahrzeugsteuern"] * 3) then
		self:sendShortMessage("Bei den derzeitigen Finanzen kann die Fahrzeugsteuer bald nicht mehr bezahlt werden!")
 	end
end

function Group:save()
	self.m_BankAccount:save()
	if self.m_Settings then
		self.m_Settings:save()
	end
	sql:queryExec("UPDATE ??_groups SET PlayTime = ? WHERE Id = ?", sql:getPrefix(), self:getPlayTime(), self:getId())
end
