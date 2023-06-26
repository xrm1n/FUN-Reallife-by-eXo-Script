-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)
FactionManager.Map = {}

function FactionManager:constructor()
	self:loadFactions()

  -- Events

	addRemoteEvents{"getFactions", "factionRequestInfo", "factionQuit", "factionDeposit", "factionWithdraw", 
	"factionAddPlayer", "factionDeleteMember", "factionInvitationAccept", "factionInvitationDecline",	
	"factionRankUp", "factionRankDown","factionReceiveWeaponShopInfos","factionWeaponShopBuy","factionSaveRank",
	"factionRespawnVehicles", "factionRequestDiplomacy", "factionChangeDiplomacy", "factionToggleLoan", 
	"factionToggleWeapon", "factionDiplomacyAnswer", "factionChangePermission", "factionRequestSkinSelection", 
	"factionPlayerSelectSkin", "factionUpdateSkinPermissions", "factionRequestSkinSelectionSpecial" , 
	"factionEquipmentOptionRequest", "factionEquipmentOptionSubmit", "factionPlayerNeedhelp", "factionStorageSelectedWeapons",
	"stopFactionRespawnAnnouncement"}

	addEventHandler("getFactions", root, bind(self.Event_getFactions, self))
	addEventHandler("factionRequestInfo", root, bind(self.Event_factionRequestInfo, self))
	addEventHandler("factionQuit", root, bind(self.Event_factionQuit, self))
	addEventHandler("factionDeposit", root, bind(self.Event_factionDeposit, self))
	addEventHandler("factionWithdraw", root, bind(self.Event_factionWithdraw, self))
	addEventHandler("factionAddPlayer", root, bind(self.Event_factionAddPlayer, self))
	addEventHandler("factionDeleteMember", root, bind(self.Event_factionDeleteMember, self))
	addEventHandler("factionInvitationAccept", root, bind(self.Event_factionInvitationAccept, self))
	addEventHandler("factionInvitationDecline", root, bind(self.Event_factionInvitationDecline, self))
	addEventHandler("factionRankUp", root, bind(self.Event_factionRankUp, self))
	addEventHandler("factionRankDown", root, bind(self.Event_factionRankDown, self))
	addEventHandler("factionReceiveWeaponShopInfos", root, bind(self.Event_receiveFactionWeaponShopInfos, self))
	addEventHandler("factionWeaponShopBuy", root, bind(self.Event_factionWeaponShopBuy, self))
	addEventHandler("factionSaveRank", root, bind(self.Event_factionSaveRank, self))
	addEventHandler("factionRespawnVehicles", root, bind(self.Event_factionRespawnVehicles, self))
	addEventHandler("factionRequestDiplomacy", root, bind(self.Event_requestDiplomacy, self))
	addEventHandler("factionChangeDiplomacy", root, bind(self.Event_changeDiplomacy, self))
	addEventHandler("factionDiplomacyAnswer", root, bind(self.Event_answerDiplomacyRequest, self))
	addEventHandler("factionChangePermission", root, bind(self.Event_changePermission, self))
	addEventHandler("factionToggleLoan", root, bind(self.Event_ToggleLoan, self))
	addEventHandler("factionToggleWeapon", root, bind(self.Event_ToggleWeapon, self))
	addEventHandler("factionRequestSkinSelection", root, bind(self.Event_requestSkins, self))
	addEventHandler("factionPlayerSelectSkin", root, bind(self.Event_setPlayerDutySkin, self))
	addEventHandler("factionUpdateSkinPermissions", root, bind(self.Event_UpdateSkinPermissions, self))
	addEventHandler("factionRequestSkinSelectionSpecial", root, bind(self.Event_setPlayerDutySkinSpecial, self))
	addEventHandler("factionEquipmentOptionRequest", root, bind(self.Event_factionEquipmentOptionRequest, self))
	addEventHandler("factionEquipmentOptionSubmit", root, bind(self.Event_factionEquipmentOptionSubmit, self))
	addEventHandler("factionPlayerNeedhelp", root, bind(self.Event_playerNeedhelp, self))
	addEventHandler("factionStorageSelectedWeapons", root, bind(self.Event_storageSelecteWeapons, self))
	addEventHandler("stopFactionRespawnAnnouncement", root, bind(self.Event_stopRespawnAnnoucement, self))

	addCommandHandler("needhelp",bind(self.Command_needhelp, self))

	FactionState:new()
	FactionRescue:new()
	--FactionInsurgent:new()
	FactionEvil:new(self.EvilFactions)
end

function FactionManager:destructor()
	for k, v in pairs(FactionManager.Map) do
		delete(v)
	end
end

function FactionManager:loadFactions()
  	local st, count = getTickCount(), 0
  	local result = sql:queryFetch("SELECT * FROM ??_factions WHERE active = 1", sql:getPrefix())
  	for k, row in pairs(result) do
		local result2 = sql:queryFetch("SELECT Id, FactionRank, FactionLoanEnabled, FactionWeaponEnabled, FactionPermissions, FactionWeaponPermissions, FactionActionPermissions FROM ??_character WHERE FactionID = ?", sql:getPrefix(), row.Id)
		local players, playerLoans, playerWeapons, playerPermissions, playerWeaponPermissions, playerActionPermissions = {}, {}, {}, {}, {}, {}
		for i, factionRow in ipairs(result2) do
			players[factionRow.Id] = factionRow.FactionRank
			playerLoans[factionRow.Id] = factionRow.FactionLoanEnabled
			playerWeapons[factionRow.Id] = factionRow.FactionWeaponEnabled
			playerPermissions[factionRow.Id] = fromJSON(factionRow.FactionPermissions)
			playerWeaponPermissions[factionRow.Id] = fromJSON(factionRow.FactionWeaponPermissions)
			playerActionPermissions[factionRow.Id] = fromJSON(factionRow.FactionActionPermissions)
		end

		local instance = Faction:new(row.Id, row.Name_Short, row.Name_Shorter, row.Name, row.BankAccount, {players, playerLoans, playerWeapons, playerPermissions, playerWeaponPermissions, playerActionPermissions}, row.RankLoans, row.RankSkins, row.RankWeapons, row.Depot, row.Type, row.Diplomacy, row.RankPermissions, row.RankActions)
		FactionManager.Map[row.Id] = instance
		count = count + 1
	end

  	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s factions in %sms"):format(count, getTickCount()-st)) end
end

function FactionManager:getAllFactions()
	return self.Map
end

function FactionManager:getFromId(Id)
	return self.Map[Id]
end

function FactionManager:getFromName(name)
	for i, faction in pairs(self.Map) do
		if faction.m_Name_Short == name then
			return faction
		end
	end
end

function FactionManager:Event_factionSaveRank(rank,loan,rankWeapons)
	local success = false
	local faction = client:getFaction()
	local wpn = {}
	if faction then
		if tonumber(loan) > FACTION_MAX_RANK_LOANS[rank] then
			client:sendError(_("Der maximale Lohn für diesen Rang beträgt %d$", client, FACTION_MAX_RANK_LOANS[rank]))
			return
		end
		if tonumber(faction.m_RankLoans[tostring(rank)]) ~= tonumber(loan) then
			if PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editLoan") then
				if faction:getPlayerRank(client) > rank or faction:getPlayerRank(client) == FactionRank.Leader then
					faction:setRankLoan(rank,loan)
					success = true
				else
					client:sendError(_("Du kannst das Gehalt von dem Rang nicht verändern!", client))
				end
			else
				client:sendError(_("Du bist nicht berechtigt das Gehalt zu ändern", client))
			end
		end

		local newWeapons = false
		for i, v in pairs(faction.m_RankWeapons[tostring(rank)]) do
			if tonumber(rankWeapons[i]) ~= tonumber(v) then
				newWeapons = true
				break
			end
		end
		if newWeapons then
			if PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editWeaponPermissions") then
				if faction:getPlayerRank(client) > rank or (PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "changePermissions") and faction:getPlayerRank(client) >= rank) then
					for id, state in pairs(rankWeapons) do
						if not PermissionsManager:getSingleton():isPlayerAllowedToTake(client, "faction", id) then
							rankWeapons[id] = faction.m_RankWeapons[tostring(rank)][id]
						end
					end
					faction:setRankWeapons(rank,rankWeapons)
					success = true
				else
					client:sendError(_("Du kannst die Waffenrechte von dem Rang nicht verändern!", client))
				end
			else
				client:sendError(_("Du bist nicht berechtigt die Rangwaffen zu ändern", client))
			end
		end
		
		if success then
			faction:save()
			client:sendInfo(_("Die Einstellungen für Rang %d wurden gespeichert!", client, rank))
			faction:addLog(client, "Fraktion", "hat die Einstellungen für Rang "..rank.." geändert!")
		end
		self:sendInfosToClient(client)
	end
end

function FactionManager:Event_factionEquipmentOptionRequest()
	if client:getFaction() then
		client:triggerEvent("onRefreshEquipmentOption", client:getFaction():getEquipmentPermissions())
	end
end

function FactionManager:Event_factionEquipmentOptionSubmit(update)
	if PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editEquipment") then
		client:getFaction():updateEquipmentPermissions(client, update)
		client:triggerEvent("onRefreshEquipmentOption", client:getFaction():getEquipmentPermissions())
	else
		client:sendError(_("Du bist nicht berechtigt die Equipment Einstellungen zu ändern!", client))
	end
end

function FactionManager:Event_factionRequestInfo()
	self:sendInfosToClient(client)
end

function FactionManager:Event_playerNeedhelp()
	self:Command_needhelp(client)
end

function FactionManager:Command_needhelp(player)
	local faction = player:getFaction()
	local player = player
	if faction then
		if player:isFactionDuty() then
			if player:getInterior() == 0 and player:getDimension() == 0 then
				if player.m_ActiveNeedHelp then return false end
				local rankName = faction:getRankName(faction:getPlayerRank(player))
				local color = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
				
				if faction:isStateFaction() then
					visibility = {factionType = "State", duty = true}
					for k, onlinePlayer in pairs(FactionState:getSingleton():getOnlinePlayers(true, true)) do
						onlinePlayer:sendShortMessage(_("%s %s benötigt Unterstützung!", onlinePlayer, rankName, player:getName()), "Unterstützungseinheit erforderlich", color, 20000)
					end
				elseif faction:isRescueFaction() then
					visibility = {faction = {faction:getId()}, duty = true}
					for k, onlinePlayer in pairs(FactionRescue:getSingleton():getOnlinePlayers(true, true)) do
						onlinePlayer:sendShortMessage(_("%s %s fordert weitere Einsatzkräfte an!", onlinePlayer, rankName, player:getName()), "Unterstützungseinheit erforderlich", color, 20000)
					end
				else
					if not player:isPhoneEnabled() then player:sendError(_("Dein Handy ist ausgeschaltet!", player)) return false end
					if faction:getAllianceFaction() then
						visibility = {faction = {faction:getId(), faction:getAllianceFaction():getId()}, duty = true}
						--show for alliance only if there is an alliance faction
						for k, onlinePlayer in pairs(faction:getAllianceFaction():getOnlinePlayers(true, true)) do
							onlinePlayer:sendShortMessage(_("Bündnispartner %s benötigt Hilfe!", onlinePlayer, player:getName()), "Unterstützung erforderlich", color, 20000)
						end
					else
						visibility = {faction = {faction:getId()}, duty = true}
					end
					--show for players of same faction in either case
					for k, onlinePlayer in pairs(faction:getOnlinePlayers(true, true)) do
						onlinePlayer:sendShortMessage(_("%s %s benötigt Hilfe!", onlinePlayer, rankName, player:getName()), "Unterstützung erforderlich", color, 20000)
					end
				end

				local blip = Blip:new("Marker.png", player.position.x, player.position.y, visibility, 9999, color)
					blip:setDisplayText(player.name)
					blip:attach(player)

				player.m_ActiveNeedHelp = true

				setTimer(function()
					blip:delete()
					if isElement(player) then
						player.m_ActiveNeedHelp = false
					end
				end, 20000, 1)
			else
				player:sendError(_("Du kannst hier keine Hilfe anfordern!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	else
		player:sendError(_("Du bist nicht in der richtigen Fraktion!", player))
	end
end

function FactionManager:sendInfosToClient(client)
	local faction = client:getFaction()
	local wpn = {}
	if faction:isEvilFaction() then
		for i, v in pairs(factionWeaponDepotInfo) do
			if v["Waffe"] ~= 0 then
				wpn[i] = true
			end
		end
	else
		wpn = faction.m_ValidWeapons
	end

	if faction then --use triggerLatentEvent to improve serverside performance
		if faction:getPlayerRank(client) < FactionRank.Manager and not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editLoan") and not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editWeaponPermissions") and not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editActionPermissions") then
			client:triggerLatentEvent("factionRetrieveInfo", faction:getId(), faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers(), ActionsCheck:getSingleton():getStatus(), faction.m_RankNames)
		else
			client:triggerLatentEvent("factionRetrieveInfo", faction:getId(), faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers(), ActionsCheck:getSingleton():getStatus(), faction.m_RankNames, faction.m_RankLoans, wpn, faction.m_RankWeapons)
		end
	else
		client:triggerEvent("factionRetrieveInfo")
	end
end

function FactionManager:Event_factionQuit()
	local faction = client:getFaction()
	if not faction then return end

	if faction:getPlayerRank(client) == FactionRank.Leader then
		client:sendWarning(_("Als Leader kannst du nicht die Fraktion verlassen!", client))
		return
	end
	faction:removePlayer(client)
	client:sendSuccess(_("Du hast die Fraktion erfolgreich verlassen!", client))
	faction:addLog(client, "Fraktion", "hat die Fraktion verlassen!")
	self:sendInfosToClient(client)
	Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(client.m_Id)
end

function FactionManager:Event_factionDeposit(amount)
	local faction = client:getFaction()
	if not faction then return end
	if not amount then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	client:transferMoney(faction, amount, "Fraktion-Einlage", "Faction", "Deposit")
	faction:addLog(client, "Kasse", "hat "..toMoneyString(amount).." in die Kasse gelegt!")
	self:sendInfosToClient(client)
	faction:refreshBankAccountGUI(client)
end

function FactionManager:Event_factionWithdraw(amount)
	local faction = client:getFaction()
	if not faction then return end
	if not amount then return end

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "withdrawMoney") then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getMoney() < amount then
		client:sendError(_("In der Fraktionskasse befindet sich nicht genügend Geld!", client))
		return
	end

	faction:transferMoney(client, amount, "Fraktion-Auslage", "Faction", "Deposit")
	faction:addLog(client, "Kasse", "hat "..toMoneyString(amount).." aus der Kasse genommen!")
	self:sendInfosToClient(client)
	faction:refreshBankAccountGUI(client)
end

function FactionManager:Event_factionAddPlayer(player)
	if not player then return end
	local faction = client:getFaction()
	if not faction then return end

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "invite") then
		client:sendError(_("Du bist nicht berechtigt Fraktionsmitglieder hinzuzufügen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if player:getFaction() then
		client:sendError(_("Dieser Benutzer ist bereits in einer Fraktion!", client))
		return
	end

	if not faction:isPlayerMember(player) then
		if not faction:hasInvitation(player) then
			faction:invitePlayer(player)
			faction:addLog(client, "Fraktion", "hat den Spieler "..player:getName().." in die Fraktion eingeladen!")
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!", client))
		end
	else
		client:sendError(_("Dieser Spieler ist bereits in der Fraktion!", client))
	end
end

function FactionManager:Event_factionDeleteMember(playerId, reasonInternaly, reasonExternaly)
	if not playerId then return end
	local faction = client:getFaction()
	local pElement = PlayerManager:getSingleton():getPlayerFromId(playerId)
	if not faction then return end

	if client:getId() == playerId then
		client:sendError(_("Du kannst dich nicht selbst aus der Fraktion werfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "uninvite") then
		client:sendError(_("Du kannst den Spieler nicht rauswerfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getPlayerRank(client) <= faction:getPlayerRank(playerId) then
		client:sendError(_("Du kannst den Spieler nicht rauswerfen!", client))
		return
	end
	
	if faction:getPlayerRank(playerId) == FactionRank.Leader then
		client:sendError(_("Du kannst den Fraktionsleiter nicht rauswerfen!", client))
		return
	end

	if reasonExternaly == "" then
		client:sendError(_("Externer Grund für den Rauswurf muss ausgefüllt werden!", client))
		return
	end

	HistoryPlayer:getSingleton():addLeaveEntry(playerId, client.m_Id, faction.m_Id, "faction", faction:getPlayerRank(playerId), reasonInternaly, reasonExternaly)

	faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." aus der Fraktion geworfen!")

	faction:removePlayer(playerId)
	self:sendInfosToClient(client)
	Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(playerId)
end

function FactionManager:Event_factionInvitationAccept(factionId)
	local faction = self:getFromId(factionId)
	if not faction then
		client:sendError(_("Faction not found!", client))
		return
	end

	if faction:hasInvitation(client) then
		if not client:getFaction() then
			faction:addPlayer(client)
			faction:addLog(client, "Fraktion", "ist der Fraktion beigetreten!")
			faction:sendMessage(_("#008888Fraktion: #FFFFFF%s ist soeben der Fraktion beigetreten!", client, getPlayerName(client)),200,200,200,true)

			HistoryPlayer:getSingleton():addJoinEntry(client.m_Id, faction:hasInvitation(client), faction.m_Id, "faction")

			self:sendInfosToClient(client)
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(client.m_Id)
		else
			client:sendError(_("Du bisd bereits einer Fraktion beigetreten!", client))
		end

		faction:removeInvitation(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Fraktion", client))
	end
end

function FactionManager:Event_factionInvitationDecline(factionId)
	local faction = self:getFromId(factionId)
	if not faction then return end

	if faction:hasInvitation(client) then
		faction:removeInvitation(client)
		faction:sendMessage(_("%s hat die Fraktionseinladung abgelehnt", client, getPlayerName(client)))
		faction:addLog(client, "Fraktion", "hat die Einladung abgelehnt!")

		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Fraktion", client))
	end
end

function FactionManager:Event_factionRankUp(playerId, leaderSwitch)
	Async.create(
		function (client)
			if not playerId then return end
			local faction = client:getFaction()
			if not faction then return end

			if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
				return
			end

			if client:getId() == playerId then
				client:sendError(_("Du kannst nicht deinen eigenen Rang verändern!", client))
				return
			end

			if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "changeRank") then
				client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
				-- Todo: Report possible cheat attempt
				return
			end

			if faction:getPlayerRank(client) ~= FactionRank.Leader and faction:getPlayerRank(client) <= faction:getPlayerRank(playerId) + 1 then
				client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
				return
			end

			if client:getId() == playerId then
				client:sendError(_("Du kannst deinen eigenen Rang nicht höher setzen!", client))
				return
			end

			if faction:getPlayerRank(playerId) + 1 >= FactionRank.Manager then
				if LeaderCheck:getSingleton():hasPlayerLeaderBan(playerId) then
					client:sendError(_("Dieser Spieler kann aufgrund einer Leadersperre nicht befördert werden!", client))
					return
				end
			end

			local playerRank = faction:getPlayerRank(playerId)
			local player, isOffline = DatabasePlayer.get(playerId)
			if isOffline then
				player:load()
			end

			if playerRank < FactionRank.Leader then
				if playerRank < faction:getPlayerRank(client) then
					if leaderSwitch then
						self:switchLeaders(client, playerId)
					end

					faction:setPlayerRank(playerId, playerRank + 1)
					HistoryPlayer:getSingleton():setHighestRank(playerId, (playerRank + 1), faction.m_Id, "faction")
					faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..(playerRank + 1).." befördert!")
					if isOffline then
						delete(player)
					else
						if isElement(player) then
							player:sendShortMessage(_("Du wurdest von %s auf Rang %d befördert!", player, client:getName(), faction:getPlayerRank(playerId)), faction:getName())
							player:setPublicSync("FactionRank", faction:getPlayerRank(player))
						end
					end
					self:sendInfosToClient(client)
					PermissionsManager:getSingleton():onRankChange("up", client, playerId, "faction")
					Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(playerId)
				else
					client:sendError(_("Mit deinem Rang kannst du Spieler maximal auf Rang %d befördern!", client, faction:getPlayerRank(client)))
				end
			else
				client:sendError(_("Du kannst Spieler nicht höher als auf Rang 6 befördern!", client))
				if isOffline then delete(player) end
			end
			self:sendInfosToClient(client)
		end
	)(client)
end

function FactionManager:Event_factionRankDown(playerId)
	Async.create(
		function(client)
			if not playerId then return end
			local faction = client:getFaction()
			if not faction then return end

			if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
				client:sendError(_("Du oder das Ziel sind nicht mehr in der Fraktion!", client))
				return
			end

			if client:getId() == playerId then
				client:sendError(_("Du kannst nicht deinen eigenen Rang verändern!", client))
				return
			end

			if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "changeRank") then
				client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
				-- Todo: Report possible cheat attempt
				return
			end

			if faction:getPlayerRank(client) ~= FactionRank.Leader and faction:getPlayerRank(client) <= faction:getPlayerRank(playerId) then
				client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
				return
			end
			
			local player, isOffline = DatabasePlayer.get(playerId)
			if isOffline then
				player:load()
			end
			if faction:getPlayerRank(playerId)-1 >= FactionRank.Normal then
				if faction:getPlayerRank(playerId) <= faction:getPlayerRank(client) then
					faction:setPlayerRank(playerId, faction:getPlayerRank(playerId) - 1)
					HistoryPlayer:getSingleton():setHighestRank(playerId, faction:getPlayerRank(playerId) + 1, faction.m_Id, "faction")
					faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..faction:getPlayerRank(playerId).." degradiert!")
					if isOffline then
						delete(player)
					else
						if isElement(player) then
							player:sendShortMessage(_("Du wurdest von %s auf Rang %d degradiert!", player, client:getName(), faction:getPlayerRank(playerId)), faction:getName())
							player:setPublicSync("FactionRank", faction:getPlayerRank(playerId))
						end
					end
					self:sendInfosToClient(client)
					PermissionsManager:getSingleton():onRankChange("down", client, playerId, "faction")
					Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(playerId)
				else
					client:sendError(_("Du kannst ranghöhere Mitglieder nicht degradieren!", client))
				end
			else
				client:sendError(_("Du kannst Spieler nicht niedriger als auf Rang 0 setzen!", client))
				if isOffline then delete(player) end
			end
			self:sendInfosToClient(client)
		end
	)(client)
end

function FactionManager:switchLeaders(oldLeader, newLeader)
	Async.create(
		function(oldLeader)
			local faction = oldLeader:getFaction()
			
			faction:setPlayerRank(oldLeader, faction:getPlayerRank(oldLeader) - 1)
			faction:addLog(newLeader, "Fraktion", "hat den Spieler "..oldLeader:getName().." auf Rang "..faction:getPlayerRank(oldLeader).." degradiert!")

			if isElement(oldLeader) then
				oldLeader:sendShortMessage(_("Du wurdest von %s auf Rang %d degradiert!", player, Account.getNameFromId(newLeader), faction:getPlayerRank(oldLeader)), faction:getName())
				oldLeader:setPublicSync("FactionRank", faction:getPlayerRank(oldLeader))
			end
			
			self:sendInfosToClient(oldLeader)
			PermissionsManager:getSingleton():onRankChange("down", oldLeader, oldLeader:getId(), "faction")
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(oldLeader:getId())
		end
	)(oldLeader)
end

function FactionManager:Event_receiveFactionWeaponShopInfos()
	local faction = client:getFaction()
	local depot = faction.m_Depot
	local playerId = client:getId()
	local rank = faction.m_Players[playerId]
	triggerClientEvent(client,"updateFactionWeaponShopGUI",client,faction.m_ValidWeapons, faction.m_WeaponDepotInfo, depot:getWeaponTable(id), faction:getRankWeapons(rank), faction.m_PlayerWeaponPermissions[playerId])
end

function FactionManager:Event_factionWeaponShopBuy(weaponTable)
	if not client.m_WeaponStoragePosition then return outputDebug("no weapon storage position for this faction implemented") end
	if client:getFaction().m_PlayerWeapons[client:getId()] == 0 then return client:sendError(_("Du darfst keine Waffen entnehmen!", client)) end
	if getDistanceBetweenPoints3D(client.position, client.m_WeaponStoragePosition) <= 10 then
		local faction = client:getFaction()
		local depot = faction.m_Depot
		if faction:isStateFaction() and not client:isFactionDuty() then
			client:sendError(_("Du bist nicht im Dienst!", client))
			return
		end
		depot:takeWeaponsFromDepot(client,weaponTable)
	else
		client:sendError(_("Du bist zu weit entfernt", client))
	end
end

function FactionManager:Event_factionRespawnVehicles(instant)
	if client:getFaction() then
		local faction = client:getFaction()

		if PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "vehicleRespawnAll") then
			if not client:getFaction().m_RespawnTimer or not isTimer(client:getFaction().m_RespawnTimer) then
				if instant then
					faction:respawnVehicles()
				else
					faction:startRespawnAnnouncement(client)
				end
			else
				client:sendError(_("Es wurde bereits eine Respawn Ankündigung erstellt.", client))
			end
		else
			client:sendError(_("Dazu bist du nicht berechtigt.", client))
		end
	end
end

function FactionManager:Event_getFactions()
	for id, faction in pairs(FactionManager.Map) do -- send the wt destination as point where players can navigate to
		client:triggerEvent("loadClientFaction", faction:getId(), faction:getName(), faction:getShortName(), faction:getRankNames(), faction:getType(), faction:getColor(), serialiseVector(factionNavigationpoint[faction:getId()]), faction.m_Diplomacy) -- navigation point on some instances missing! 
	end
end

function FactionManager:Event_requestDiplomacy(factionId)
	local faction = self:getFromId(factionId)
	if faction and faction.m_Diplomacy and client.getFaction and client:getFaction() then
		client:triggerEvent("factionRetrieveDiplomacy", factionId, faction.m_Diplomacy, faction.m_DiplomacyPermissions, client:getFaction().m_DiplomacyRequests)
	end
end

function FactionManager:Event_changeDiplomacy(target, diplomacy)
	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editDiplomacy") then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	local faction1 = client:getFaction()
	local faction2 = self:getFromId(target)

	if diplomacy == FACTION_DIPLOMACY["Verbündet"] then
		if faction1:getAllianceFaction() then
			client:sendError(_("Ihr habt bereits ein Bündnis mit der %s!", client, faction1:getAllianceFaction():getShortName()))
			client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, faction1.m_DiplomacyRequests)
			return
		end
		if faction2:getAllianceFaction() then
			client:sendError(_("Die Fraktion %s hat bereits ein Bündnis mit der %s!", client, faction2:getShortName(), faction2:getAllianceFaction():getShortName()))
			client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, faction1.m_DiplomacyRequests)
			return
		end
	end

	if diplomacy < faction1:getDiplomacy(faction2) then
		for index, data in pairs(faction1.m_DiplomacyRequests) do
			if data["source"] == faction1:getId() and data["status"] == FACTION_DIPLOMACY["Verbündet"] then
				client:sendError(_("Es läuft aktuell bereits eine Bündnis-Anfrage eurer Fraktion! Ziehe die andere Anfrage erst zurück!", client))
				client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, faction1.m_DiplomacyRequests)
				return
			elseif data["target"] == faction2:getId() then
				client:sendError(_("Es läuft aktuell bereits eine Anfrage an diese Fraktion! Ziehe die andere Anfrage erst zurück!", client))
				client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, faction1.m_DiplomacyRequests)
				return
			end
		end

		faction1:createDiplomacyRequest(faction1, faction2, diplomacy, client)
		faction2:createDiplomacyRequest(faction1, faction2, diplomacy, client)
	else
		faction1:changeDiplomacy(faction2, diplomacy, client)
		faction2:changeDiplomacy(faction1, diplomacy, client)
		self:sendDiplomaciesToClient()
	end

	client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, faction1.m_DiplomacyRequests)
end

function FactionManager:Event_answerDiplomacyRequest(id, answer)
	if not client:getFaction() or not client:getFaction().m_DiplomacyRequests[id] then
		client:sendError(_("Die Anfrage ist nicht mehr verfügbar!", client))
	end

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editDiplomacy")  then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	local request = client:getFaction().m_DiplomacyRequests[id]
	local faction1 = self:getFromId(request["source"])
	local faction2 = self:getFromId(request["target"])
	local diplomacy = request["status"]

	if answer == "accept" and diplomacy == FACTION_DIPLOMACY["Verbündet"] then
		if faction1:getAllianceFaction() then
			client:sendError(_("Die Fraktion %s hat bereits ein Bündnis mit der %s!", client, faction1:getShortName(), faction1:getAllianceFaction():getShortName()))
			client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, faction1.m_DiplomacyRequests)
			return
		end
		if faction2:getAllianceFaction() then
			client:sendError(_("Die Fraktion %s hat bereits ein Bündnis mit der %s!", client, faction2:getShortName(), faction2:getAllianceFaction():getShortName()))
			client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, faction1.m_DiplomacyRequests)
			return
		end
	end

	if answer == "accept" then
		faction1:changeDiplomacy(faction2, diplomacy, client)
		faction2:changeDiplomacy(faction1, diplomacy, client)
		self:sendDiplomaciesToClient()
	elseif answer == "decline" then
		faction1:sendShortMessage(("%s hat eure %s an die %s abgelehnt!"):format(client:getName(), FACTION_DIPLOMACY_REQUEST[diplomacy], faction2:getShortName()))
		faction2:sendShortMessage(("%s hat die %s der %s abgelehnt!"):format(client:getName(), FACTION_DIPLOMACY_REQUEST[diplomacy], faction1:getShortName()))
	elseif answer == "remove" then
		faction1:sendShortMessage(("%s hat eure %s an die %s zurückgezogen!"):format(client:getName(), FACTION_DIPLOMACY_REQUEST[diplomacy], faction2:getShortName()))
		faction2:sendShortMessage(("%s hat die %s der %s zurückgezogen!"):format(client:getName(), FACTION_DIPLOMACY_REQUEST[diplomacy], faction1:getShortName()))
	end

	for index, data in pairs(faction1.m_DiplomacyRequests) do
		if data["source"] == request["source"] and data["target"] == request["target"] and data["status"] == request["status"] then
			faction1.m_DiplomacyRequests[index] = nil
		end
	end
	client:getFaction().m_DiplomacyRequests[id] = nil

	client:triggerEvent("factionRetrieveDiplomacy", faction2:getId(), faction2.m_Diplomacy, faction2.m_DiplomacyPermissions, client:getFaction().m_DiplomacyRequests)
end

function FactionManager:Event_changePermission(permission)
	local faction = client:getFaction()
	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editDiplomacy")  then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end
	if table.find(faction.m_DiplomacyPermissions, permission) then
		table.remove(faction.m_DiplomacyPermissions, table.find(faction.m_DiplomacyPermissions, permission))
		faction:sendShortMessage(("Euer Bündnispartner darf nun keine %s mehr nehmen!"):format(permission == "vehicles" and "Fahrzeuge" or "Waffen"))
	else
		table.insert(faction.m_DiplomacyPermissions, permission)
		faction:sendShortMessage(("Euer Bündnispartner darf nun eure %s nehmen!"):format(permission == "vehicles" and "Fahrzeuge" or "Waffen"))
	end
	client:triggerEvent("factionRetrieveDiplomacy", faction:getId(), faction.m_Diplomacy, faction.m_DiplomacyPermissions, faction.m_DiplomacyRequests)
end

function FactionManager:Event_ToggleLoan(playerId)
	if not playerId then return end
	local faction = client:getFaction()
	if not faction then return end

	if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
		client:sendError(_("Du oder das Ziel sind nicht mehr im Unternehmen!", client))
		return
	end

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "toggleLoan") then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end
	
	local current = faction:isPlayerLoanEnabled(playerId)

	if faction:getPlayerRank(client) <= faction:getPlayerRank(playerId) and faction:getPlayerRank(client) ~= FactionRank.Leader then
		client:sendError(_("Du kannst das Gehalt vom dem Spieler nicht %saktivieren", client, current and "de" or ""))
		return
	end

	faction:setPlayerLoanEnabled(playerId, current and 0 or 1)
	self:sendInfosToClient(client)

	faction:addLog(client, "Fraktion", ("hat das Gehalt von Spieler %s %saktiviert!"):format(Account.getNameFromId(playerId), current and "de" or ""))
end

function FactionManager:Event_ToggleWeapon(playerId)
	if not playerId then return end
	local faction = client:getFaction()
	if not faction then return end

	if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
		client:sendError(_("Du oder das Ziel sind nicht mehr im Unternehmen!", client))
		return
	end

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "toggleWeapon") then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	local current = faction:isPlayerWeaponEnabled(playerId)

	if faction:getPlayerRank(client) <= faction:getPlayerRank(playerId) and faction:getPlayerRank(client) ~= FactionRank.Leader then
		client:sendError(_("Du kannst die Waffenentnahme vom dem Spieler nicht %saktivieren", client, current and "de" or ""))
		return
	end

	faction:setPlayerWeaponEnabled(playerId, current and 0 or 1)
	self:sendInfosToClient(client)

	faction:addLog(client, "Fraktion", ("hat die Waffenentnahme von Spieler %s %saktiviert!"):format(Account.getNameFromId(playerId), current and "de" or ""))
end

function FactionManager:Event_requestSkins()
	if not client:getFaction() then
		client:sendError(_("Du gehörst keiner Fraktion an!", client))
		return false
	end
	local f = client:getFaction()
	local r = f:getPlayerRank(client)
	triggerClientEvent(client, "openSkinSelectGUI", client, f:getSkinsForRank(r), f:getId(), "faction", PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editRankSkins"), f:getAllSkins())
end

function FactionManager:Event_setPlayerDutySkin(skinId)
	if not client:getFaction() then
		client:sendError(_("Du gehörst keiner Fraktion an!", client))
		return false
	end
	if not client:isFactionDuty() then
		client:sendError(_("Du bist nicht im Dienst deiner Fraktion aktiv!", client))
		return
	end
	client:sendInfo(_("Kleidung gewechselt.", client))
	client:getFaction():changeSkin(client, skinId)
end

function FactionManager:Event_UpdateSkinPermissions(skinTable)
	if not client:getFaction() then
		client:sendError(_("Du gehörst keiner Fraktion an!", client))
		return false
	end
	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editRankSkins") then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return false
	end
	for i, v in pairs(skinTable) do
		client:getFaction():setSetting("Skin", i, v)
		if v == -1 then
			client:getFaction().m_SpecialSkin = i
		end
	end
	client:sendSuccess(_("Einstellungen gespeichert!", client))

	local f = client:getFaction()
	local r = f:getPlayerRank(client)
	triggerClientEvent(client, "openSkinSelectGUI", client, f:getSkinsForRank(r), f:getId(), "faction", PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "faction", "editRankSkins"), f:getAllSkins())
end

function FactionManager:Event_setPlayerDutySkinSpecial(skinId)
	if not client:getFaction() then
		client:sendError(_("Du gehörst keiner Fraktion an!", client))
		return false
	end
	if not client:isFactionDuty() then return client:sendError(_("Du bist nicht im Dienst deiner Fraktion aktiv!", client)) end
	if not client:getFaction().m_SpecialSkin or tonumber(client:getFaction():getSetting("Skin", client:getFaction().m_SpecialSkin, 0)) ~= -1 then
		client:sendError(_("Fehler bei Spezial/Aktionskleidung, bitte wende dich an deinen Leader!", client))
		return false
	end
	client:sendInfo(_("Kleidung gewechselt.", client))
	if client:getModel() == client:getFaction().m_SpecialSkin then -- in special duty, stop it
		client:getFaction():changeSkin(client, skinId)
	else --start special duty
		client:getFaction():changeSkin(client, client:getFaction().m_SpecialSkin)
	end
end

function FactionManager:getFromName(name)
	for k, faction in pairs(FactionManager.Map) do
		if faction:getName() == name then
			return faction
		end
	end
	return false
end

function FactionManager:sendDiplomaciesToClient(singlePlayer)
	local diplomacies = {}

	for factionId, faction in pairs(FactionManager.Map) do
		diplomacies[factionId] = faction.m_Diplomacy
	end

	if singlePlayer then
		singlePlayer:triggerEvent("onClientDiplomacyReceive", diplomacies)
	else
		for index, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
			player:triggerEvent("onClientDiplomacyReceive", diplomacies)
		end
	end
end

function FactionManager:switchFactionMembers(admin, factionId, factionIdToSwitchTo)
	local faction = self:getFromId(factionId)
	local players = {}

	if not faction then
		local result = sql:queryFetch("SELECT Id, FactionRank FROM ??_character WHERE FactionID = ?", sql:getPrefix(), factionId)
		for i, factionRow in ipairs(result) do
			players[factionRow.Id] = factionRow.FactionRank
		end
	else
		admin:sendError(_("Die Fraktion mit der ID %s ist noch geladen!", admin, factionId))
		return
	end

	local factionToSwitchTo = self:getFromId(factionIdToSwitchTo)
	if not factionToSwitchTo then
		admin:sendError(_("Die Fraktion mit der ID %s ist nicht geladen!", admin, factionIdToSwitchTo))
		return
	end

	for playerId, rank in pairs(players) do
		HistoryPlayer:getSingleton():addLeaveEntry(playerId, admin:getId(), factionId, "faction", rank, "Fraktionstausch", "Fraktionstausch")

		HistoryPlayer:getSingleton():addJoinEntry(playerId, admin:getId(), factionIdToSwitchTo, "faction")
		factionToSwitchTo:addPlayer(playerId, rank)
	end

	admin:sendSuccess(_("Die Fraktionsmitglieder der Fraktions ID %d wurden erfolgreich in die Fraktion %s transferiert!", admin, factionId, factionToSwitchTo:getName()))
end

function FactionManager:factionForceOffduty(player)
	if player:getPublicSync("Faction:Duty") and player:getFaction() then
		if player:getFaction():isStateFaction() then
			FactionState:getSingleton():Event_toggleDuty(true, false, true, player)
		elseif player:getFaction():isRescueFaction() then
			FactionRescue:getSingleton():Event_toggleDuty(false, true, false, true, player)
		elseif player:getFaction():isEvilFaction() then
			FactionEvil:getSingleton():Event_toggleDuty(true, false, true, player)
		end
	end
end
function FactionManager:Event_storageSelecteWeapons(weapons)
	client:getFaction():storageWeapons(client, weapons)
end

function FactionManager:sendPermissionsToClient(faction)
	local players = faction:getOnlinePlayers()
	local permissions = faction.m_Permissions

	for index, player in pairs(players) do
		player:triggerEvent("onClientPermissionsReceive", faction:getId(), permissions)
	end
end

function FactionManager:Event_stopRespawnAnnoucement()
	if client:getFaction() then
		client:getFaction():stopRespawnAnnouncement(client)
	end
end