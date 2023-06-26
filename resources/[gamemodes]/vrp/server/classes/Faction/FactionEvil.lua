-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionEvil.lua
-- *  PURPOSE:     Evil Faction Class
-- *
-- ****************************************************************************

FactionEvil = inherit(Singleton)
  -- implement by children

function FactionEvil:constructor()
	self.InteriorEnterExit = {}
	self.m_WeaponPed = {}
	self.m_ItemDepot = {}
	self.m_EquipmentDepot = {}
	self.m_Raids = {}

	nextframe(function()
		self:loadLCNGates(5)
		--self:loadCartelGates(11)
		--self:loadYakGates(6)
		--self:loadTriadGates(11)
	end)

	for Id, faction in pairs(FactionManager:getAllFactions()) do
		if faction:isEvilFaction() then
			self:createInterior(Id, faction)
			local blip = Blip:new("Evil.png", evilFactionInteriorEnter[Id].x, evilFactionInteriorEnter[Id].y, {faction = Id}, 400, {factionColors[Id].r, factionColors[Id].g, factionColors[Id].b})
				blip:setDisplayText(faction:getName(), BLIP_CATEGORY.Faction)
		end
	end
	nextframe(function()
		self:loadDiplomacy()
	end)

	setGarageOpen(9, true) -- Grove Street Garage

	addRemoteEvents{"factionEvilStartRaid", "factionEvilSuccessRaid", "factionEvilFailedRaid", "factionEvilToggleDuty", "factionEvilRearm", "factionEvilStorageWeapons"}
	addEventHandler("factionEvilStartRaid", root, bind(self.Event_StartRaid, self))
	addEventHandler("factionEvilSuccessRaid", root, bind(self.Event_SuccessRaid, self))
	addEventHandler("factionEvilFailedRaid", root, bind(self.Event_FailedRaid, self))
	addEventHandler("factionEvilToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionEvilRearm", root, bind(self.Event_FactionRearm, self))
	addEventHandler("factionEvilStorageWeapons", root, bind(self.Event_storageWeapons, self))
end

function FactionEvil:destructor()
end

function FactionEvil:createInterior(Id, faction)
	self.InteriorEnterExit[Id] = InteriorEnterExit:new(evilFactionInteriorEnter[Id], Vector3(2807.32, -1173.92, 1025.57), 0, 0, 8, Id)
	self.m_WeaponPed[Id] = NPC:new(FactionManager:getFromId(Id):getRandomSkin(), 2819.20, -1166.77, 1025.58, 133.63)
	self.m_WeaponPed[Id]:setDimension(Id)
	self.m_WeaponPed[Id]:setInterior(8)
	self.m_WeaponPed[Id]:setFrozen(true)
	self.m_WeaponPed[Id]:setImmortal(true)
	self.m_WeaponPed[Id]:setData("clickable",true,true) -- Makes Ped clickable
	self.m_WeaponPed[Id].Faction = faction
	addEventHandler("onElementClicked", self.m_WeaponPed[Id], bind(self.onWeaponPedClicked, self))
	ElementInfo:new(self.m_WeaponPed[Id], "Waffenlager")

	self.m_ItemDepot[Id] = createObject(2972, 2816.8, -1173.5, 1024.4, 0, 0, 0)
	self.m_ItemDepot[Id]:setDimension(Id)
	self.m_ItemDepot[Id]:setInterior(8)
	self.m_ItemDepot[Id].Faction = faction
	self.m_ItemDepot[Id]:setData("clickable",true,true) -- Makes Ped clickable
	addEventHandler("onElementClicked", self.m_ItemDepot[Id], bind(self.onDepotClicked, self))
	ElementInfo:new(self.m_ItemDepot[Id], "Itemlager")

	self.m_EquipmentDepot[Id] = createObject(964, 2819.84, -1173.51, 1024.57, 0, 0, 0)
	self.m_EquipmentDepot[Id]:setDimension(Id)
	self.m_EquipmentDepot[Id]:setInterior(8)
	self.m_EquipmentDepot[Id].Faction = faction
	self.m_EquipmentDepot[Id]:setData("clickable",true,true) -- Makes Ped clickable
	ElementInfo:new(self.m_EquipmentDepot[Id], "Ausrüstungslager")

	addEventHandler("onElementClicked", self.m_EquipmentDepot[Id], bind(self.onEquipmentDepotClicked, self))

	local int = {
		createObject(351, 2818, -1173.6, 1025.6, 80, 340, 0),
		createObject(348, 2813.6001, -1166.8, 1025.64, 90, 0, 332),
		createObject(3016, 2820.3999, -1167.7, 1025.7, 0, 0, 18),
		createObject(1271, 2818.69995, -1167.30005, 1025.40002, 0, 0, 314),
		createObject(1271, 2818.19995, -1166.80005, 1024.69995, 0, 0, 314),
		createObject(1271, 2818.2, -1166.8, 1025.4, 0, 0, 312),
		createObject(1271, 2818.7, -1167.3, 1024.7, 0, 0, 313.995),
		createObject(1271, 2819.2, -1167.8, 1024.7, 0, 0, 314.495),
		createObject(1271, 2819.2, -1167.8, 1025.4, 0, 0, 315.25),
		createObject(2041, 2819.1001, -1165.2, 1025.9, 0, 0, 10),
		createObject(2042, 2818.3, -1166.8, 1025.8),
		createObject(2359, 2817.7, -1165.1, 1025.9, 0, 0, 348),
		createObject(2358, 2820.2, -1165.1, 1024.7 ),
		createObject(2358, 2820.19995, -1165.09998, 1024.90002, 0, 0, 354),
		createObject(2358, 2820.2, -1165.1, 1025.1, 0, 0, 10),
		createObject(2358, 2820.2, -1165.1, 1025.3),
		createObject(2358, 2820.2, -1165.1, 1025.5, 0, 0, 348),
		createObject(349, 2818.8999, -1167.7, 1025.8, 90, 0, 0),
		createObject(349, 2818.8999, -1167.7, 1025.8, 90, 0, 0),
		createObject(2977, 2819.3, -1170.6, 1024.4, 0, 0, 30.5),
		createObject(2332, 2814.6001, -1173.8, 1026.6, 0, 0, 180)
	}
	for k,v in pairs(int) do
		setElementDimension(v, Id)
		setElementInterior(v, 8)
		if v:getModel() == 2332 then
			faction:setSafe(v)
		end
	end

end

function FactionEvil:getFactions()
	local factions = FactionManager:getSingleton():getAllFactions()
	local returnFactions = {}
	for i, faction in pairs(factions) do
		if faction:isEvilFaction() then
			table.insert(returnFactions, faction)
		end
	end
	return returnFactions
end

function FactionEvil:getOnlinePlayers(afkCheck, dutyCheck)
	local factions = FactionManager:getSingleton():getAllFactions()
	local players = {}
	for index,faction in pairs(factions) do
		if faction:isEvilFaction() then
			for index, value in pairs(faction:getOnlinePlayers(afkCheck, dutyCheck)) do
				table.insert(players, value)
			end
		end
	end
	return players
end

function FactionEvil:countPlayers(afkCheck, dutyCheck)
	local count = #self:getOnlinePlayers(afkCheck, dutyCheck)
	return count
end

function FactionEvil:sendWarning(text, header, withOffDuty, pos, ...)
	for k, player in pairs(self:getOnlinePlayers(false, not withOffDuty)) do
		player:sendWarning(_(text, player, ...), 30000, header)
	end
	if pos and pos.x then pos = {pos.x, pos.y, pos.z} end -- serialiseVector conversion
	if pos and pos[1] and pos[2] then
		local blip = Blip:new("Gangwar.png", pos[1], pos[2], {factionType = "Evil", duty = (not withOffDuty)}, 4000, BLIP_COLOR_CONSTANTS.Orange)
			blip:setDisplayText(header)
		if pos[3] then
			blip:setZ(pos[3])
		end
		setTimer(function()
			blip:delete()
		end, 30000, 1)
	end
end

function FactionEvil:onWeaponPedClicked(button, state, player)
	if button == "left" and state == "up" then
		if player:getFaction() and (player:getFaction() == source.Faction or source.Faction:checkAlliancePermission(player:getFaction(), "weapons")) then
			player.m_CurrentDutyPickup = source
			player:getFaction():updateDutyGUI(player)
		else
			player:sendError(_("Dieser Waffenverkäufer liefert nicht an deine Fraktion!", player))
		end
	end
end

function FactionEvil:onDepotClicked(button, state, player)
	if button == "left" and state == "up" then
		if player:getFaction() and player:getFaction() == source.Faction then
			player:getFaction():getDepot():showItemDepot(player, source)
		else
			player:sendError(_("Dieses Depot gehört nicht deiner Fraktion!", player))
		end
	end
end

function FactionEvil:onEquipmentDepotClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction() == source.Faction then
			local box = player:getPlayerAttachedObject()
			if box and isElement(box) and box.m_Content then
				self:putOrderInDepot(player, box)
			else
				if not getElementData(player, "isEquipmentGUIOpen") then -- get/setData doesnt seem to sync to client despite sync-arguement beeing true(?)
					setElementData(player, "isEquipmentGUIOpen", true, true)
					player.m_LastEquipmentDepot = source
					player:getFaction():getDepot():showEquipmentDepot(player, source)
				end
			end
		else
			player:sendError(_("Dieses Depot gehört nicht deiner Fraktion!", player))
		end
	end
end

function FactionEvil:isSpecialProduct(product)
	return (product == "RPG-7" or product == "Granate" or product == "Scharfschützengewehr" or product == "Gasgranate")
end

function FactionEvil:putOrderInDepot(player, box)
	local insertWeapomAmount = 0
	local insertAmmoAmount = 0
	local content = box.m_Content
	local type, product, amount, price, id = unpack(box.m_Content)
	local depot = player:getFaction():getDepot()
	local depotInfo = factionWeaponDepotInfo
	if type == "Waffe" or self:isSpecialProduct(product) then
		if not self:isSpecialProduct(product) then
			if id then
				if depotInfo[id]["Waffe"] >= depot.m_Weapons[id]["Waffe"] + amount then
					insertWeapomAmount = amount
				else
					insertWeapomAmount = (depotInfo[id]["Waffe"] - depot.m_Weapons[id]["Waffe"] >= 0 and depotInfo[id]["Waffe"] - depot.m_Weapons[id]["Waffe"] or 0)
				end
				depot:addWeaponD(id, insertWeapomAmount)
				player:getFaction():sendShortMessage(("%s hat %s Waffe/n [ %s ] ins Lager gelegt!"):format(player:getName(), insertWeapomAmount, product))
				player:getFaction():sendShortMessage(("%s hat %s Munition [ %s ] ins Lager gelegt!"):format(player:getName(), insertAmmoAmount, product))
				player:getFaction():addLog(player, "Lager", ("%s hat %s Waffe/n [ %s ] ins Lager gelegt!"):format(player:getName(), insertWeapomAmount, product))
			end
		else
			if id then
				if depotInfo[id]["Waffe"] >= depot.m_Weapons[id]["Waffe"] + amount then
					insertWeapomAmount = amount
				else
					insertWeapomAmount = (depotInfo[id]["Waffe"] - depot.m_Weapons[id]["Waffe"] >= 0 and depotInfo[id]["Waffe"] - depot.m_Weapons[id]["Waffe"] or 0)
				end
				if depotInfo[id]["Magazine"] >= depot.m_Weapons[id]["Munition"] + amount then
					insertAmmoAmount = amount
				else
					insertAmmoAmount = (depotInfo[id]["Magazine"] - depot.m_Weapons[id]["Munition"] >= 0 and depotInfo[id]["Magazine"] - depot.m_Weapons[id]["Munition"] or 0)
				end
				depot:addWeaponD(id,insertWeapomAmount)
				depot:addMagazineD(id,insertAmmoAmount)
				player:getFaction():sendShortMessage(("%s hat %s Spezial-Waffe/n [ %s ] ins Lager gelegt!"):format(player:getName(), insertWeapomAmount, product))
				player:getFaction():sendShortMessage(("%s hat %s Spezial-Munition [ %s ] ins Lager gelegt!"):format(player:getName(), insertAmmoAmount, product))
				player:getFaction():addLog(player, "Lager", ("%s hat %s Spezial-Waffe/n [ %s ] ins Lager gelegt!"):format(player:getName(), insertAmmoAmount, product))
			end
		end
	elseif type == "Munition" then
		if id then
			if depotInfo[id]["Magazine"] >= depot.m_Weapons[id]["Munition"] + amount then
				insertAmmoAmount = amount
			else
				insertAmmoAmount = (depotInfo[id]["Magazine"] - depot.m_Weapons[id]["Munition"] >= 0 and depotInfo[id]["Magazine"] - depot.m_Weapons[id]["Munition"] or 0)
			end
			depot:addMagazineD(id,insertAmmoAmount)
			player:getFaction():sendShortMessage(("%s hat %s Munition [ %s ] ins Lager gelegt!"):format(player:getName(), insertAmmoAmount, product))
			player:getFaction():addLog(player, "Lager", ("%s hat %s Munition [ %s ] ins Lager gelegt!"):format(player:getName(), insertAmmoAmount, product)) 
		end
	else
		depot:addEquipment(player, product, amount, true)
		player:getFaction():sendShortMessage(("%s hat %s Stück %s ins Lager gelegt!"):format(player:getName(), amount, product))
		player:getFaction():addLog(player, "Lager", ("%s hat %s Stück %s ins Lager gelegt!"):format(player:getName(), amount, product))
	end
	box.m_Package:delete()
end

function FactionEvil:loadYakGates(factionId)
	local lcnGates = {}
	lcnGates[1] = Gate:new(10558, Vector3(1402.4599609375, -1450.0500488281, 9.6000003814697), Vector3(0, 0, 86), Vector3(1402.4599609375, -1450.0500488281, 5.3))
	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
	setObjectScale(lcnGates[1].m_Gates[1], 1.1)
	local elevator = Elevator:new()
	elevator:addStation("Dach", Vector3(1418.78, -1329.92, 23.99))
	elevator:addStation("Hinterhof", Vector3(1423.35, -1356.26, 13.57))
	elevator:addStation("UG Garage", Vector3(1413.57, -1355.19, 8.93))
	local pillar = createObject(2774, Vector3(1397.404, -1450.227, -0.422))
	local pillar2 = createObject(2774, Vector3(1407.404, -1450.227,	 -0.422 ))

end

function FactionEvil:loadTriadGates(factionId)

	local lcnGates = {}
	lcnGates[1] = Gate:new(10558, Vector3(1901.549, 967.301, 11.120 ), Vector3(0, 0, 270), Vector3(1901.549, 967.301, 11.120-4.04))
	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
	local pillar = createObject( 2774, 1906.836, 967.180+0.6, 10.820-7)
	local door = Door:new(6400, Vector3(1908.597, 967.407, 10.750), Vector3(0, 0, 90))
	setElementDoubleSided(door.m_Door, true)
	local crate = createObject(3576, 1909.020,965.252,11.320)
	setElementRotation(crate, 0, 0, 180)
	local box = createObject(18260, 1910.220, 969.863, 11.420)
	local elevator = Elevator:new()
	elevator:addStation("Garage", Vector3(1904.38, 1016.85, 11), 351-180)
	elevator:addStation("Casino", Vector3(1963.30, 973.03, 994.27), 204-180, 10, 0)
	elevator:addStation("Dach - Heliports", Vector3(1941.15, 988.72, 52.74), 0)
end


function FactionEvil:loadCartelGates( factionId)

	local lcnGates = {}
	lcnGates[1] = Gate:new(6400, Vector3(2520.203, -1493.003, 25.094), Vector3(0, 0, 270), Vector3(2520.203, -1493.003, 20.094))
	lcnGates[2] = Gate:new(16773, Vector3(2446.400, -1464.300, 23.800), Vector3(0, 0, 270), Vector3(2446.400, -1464.300, 17.800))

	for index, gate in pairs(lcnGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onBarrierGateHit, self)
	end
end


function FactionEvil:loadLCNGates(factionId)

	self.m_LCNGates = {}
	self.m_LCNGates[1] = Gate:new(988, Vector3(783.255, -1149.449, 23.641), Vector3(0, 0, 90), Vector3(783.255, -1145.52, 23.641))
	self.m_LCNGates[1]:addGate(988, Vector3(783.255, -1155.3, 23.641), Vector3(0, 0, 90), Vector3(783.255, -1159.25, 23.641))
	self.m_LCNGates[1]:setGateScale(Vector3(1.065, 1, 1.09))

	self.m_LCNGates[2] = Gate:new(988, Vector3(660.249, -1230.912, 15.675), Vector3(0, 0, 242), Vector3(658.4, -1234.39, 15.675))
	self.m_LCNGates[2]:addGate(988, Vector3(662.999, -1225.739, 15.675), Vector3(0, 0, 242), Vector3(664.849, -1222.261, 15.675))
	self.m_LCNGates[2]:setGateScale(Vector3(1.065, 1, 1))
	
	self.m_LCNGates[3] = Gate:new(988, Vector3(667.909, -1307.242, 13.6), Vector3(0, 0, 0), Vector3(671.83, -1307.242, 13.6))
	self.m_LCNGates[3]:addGate(988, Vector3(662.059, -1307.242, 13.6), Vector3(0, 0, 0), Vector3(658.12, -1307.242, 13.6))
	self.m_LCNGates[3]:setGateScale(Vector3(1.065, 1, 1.09))

	--setObjectScale(lcnGates[1].m_Gates[1], 1.1)
	-- setObjectBreakable(lcnGates[1].m_Gates[1], false) <- works only clientside
	for index, gate in pairs(self.m_LCNGates) do
		gate:setOwner(FactionManager:getSingleton():getFromId(factionId))
		gate.onGateHit = bind(self.onLCNBarrierGateHit, self)
	end
	--// remove some objects for the new base that totally looks like a bullshit-fortress for some unauthentic factions called "weaboo-yakuza"
	--// ps: have I told you that I hate this new faction-base?
	--// removed removeModel ;)
end

function FactionEvil:onBarrierGateHit(player, gate)
    if player:getFaction() == gate:getOwner() or player:getFaction():getAllianceFaction() == gate:getOwner() then
		return true
	else
		return false
	end
end

function FactionEvil:onBarrierDoorHit(player)
    if player:getFaction() == self.m_TriadDoor.m_FactionId then
		return true
	else
		return false
	end
end

function FactionEvil:Event_StartRaid(target)
	if client:getFaction() and client:getFaction():isEvilFaction() and client:isFactionDuty() then
		if target and isElement(target) and target:isLoggedIn() then
			if not target:isFactionDuty() and not target:isCompanyDuty() then
				if client.vehicle then
					client:sendError(_("Du kannst nicht aus einem Fahrzeug überfallen!", client))
					return
				end

				if target:getHealth() == 0 then return end

				if target:getPublicSync("supportMode") then
					client:sendError(_("Du kannst keine aktiven Supporter überfallen!", client))
					return
				end

				if target:getInterior() > 0 then
					client:sendError(_("Du kannst Leute nur im Freien überfallen!", client))
					return
				end

				if math.floor(target:getPlayTime()/60) < 10 then
					client:sendError(_("Spieler unter 10 Spielstunden dürfen nicht überfallen werden!", client))
					return
				end

				if target:getMoney() > 0 then
					local targetName = target:getName()
					if self.m_Raids[targetName] and not timestampCoolDown(self.m_Raids[targetName], 2*60*60) then
						client:sendError(_("Dieser Spieler wurde innerhalb der letzten 2 Stunden bereits überfallen!", client))
						return
					end
					target:sendMessage(_("Du wirst von %s (%s) überfallen!", target, client:getName(), client:getFaction():getShortName()), 255, 0, 0)
					target:sendMessage(_("Lauf weg oder bleibe bis der Überfall beendet ist!", target), 255, 0, 0)
					client:meChat(true, _("überfällt %s!", client, targetName))

					target:triggerEvent("CountdownStop",  15, "Überfallen in")
					target:triggerEvent("Countdown", 15, "Überfallen in")
					client:triggerEvent("Countdown", 15, "Überfallen in")
					client:triggerEvent("factionEvilStartRaid", target)
					self.m_Raids[targetName] = getRealTime().timestamp
				else
					client:sendError(_("Der Spieler hat kein Geld dabei!", client))
				end
			else
				client:sendError(_("Du kannst keine Spieler im Dienst überfallen!", client))
			end
		end
	end
end

function FactionEvil:Event_SuccessRaid(target)
	local money = target:getMoney()
	if money > 750 then money = 750 end
	if money > 0 then
		client:meChat(true,"überfällt "..target:getName().." erfolgreich!")
		target:meChat(true, _("wurde erfolgreich von %s überfallen!", target, client:getName()))
		target:transferMoney(client, money, "Überfall", "Faction", "Robbery")
		client:triggerEvent("CountdownStop", "Überfallen in", 15)
		target:triggerEvent("CountdownStop", "Überfallen in", 15)
		StatisticsLogger:getSingleton():addRaidLog(client, target, 1, money)
	else
		client:sendError(_("Der Spieler hat kein Geld dabei!", client))
	end
end

function FactionEvil:Event_FailedRaid(target)
	target:sendSuccess(_("Du bist dem Überfall entkommen!", target))
	client:sendWarning(_("Der Spieler ist dem Überfall entkommen!", client))
	target:meChat(true, _("ist aus dem Überfall von %s entkommen!", target, client:getName()))
	StatisticsLogger:getSingleton():addRaidLog(client, target, 0, 0)
end

function FactionEvil:loadDiplomacy()
	local evilFactions = self:getFactions()
	for Id, faction in pairs(evilFactions) do
		if faction:isEvilFaction() then
			faction:loadDiplomacy()
		end
	end
end

function FactionEvil:setPlayerDuty(player, state, wastedOrNotOnMarker, preferredSkin, dontChangeSkin)
	local faction = player:getFaction()
	if not state and player:isFactionDuty() then
		if not dontChangeSkin then
			player:setCorrectSkin(true)
		end
		player:setFactionDuty(false)
		player:sendInfo(_("Du bist nun in zivil unterwegs!", player))
		if not wastedOrNotOnMarker then faction:updateDutyGUI(player) end
	elseif state and not player:isFactionDuty() then
		if player:getPublicSync("Company:Duty") and player:getCompany() then
			--player:sendWarning(_("Bitte beende zuerst deinen Dienst im Unternehmen!", player))
			--return false
			--client:triggerEvent("companyForceOffduty")
			CompanyManager:getSingleton():companyForceOffduty(player)
		end
		player:setFactionDuty(true)
		faction:changeSkin(player, preferredSkin or (player.m_tblClientSettings and player.m_tblClientSettings["LastFactionSkin"]))
		player:setHealth(100)
		player:setArmor(100)
		StatisticsLogger:getSingleton():addHealLog(player, 100, "Faction Duty Heal")
		DamageManager:getSingleton():clearPlayer(player)
		player:checkLastDamaged() 
		player:sendInfo(_("Du bist nun als Gangmitglied gekennzeichnet!", player))
		if not wastedOrNotOnMarker then faction:updateDutyGUI(player) end
	end
end

function FactionEvil:isPlayerInDutyPickup(player)
	if not player.m_CurrentDutyPickup then return false end
	return getDistanceBetweenPoints3D(player.position, player.m_CurrentDutyPickup.position) <= 10
end

function FactionEvil:Event_toggleDuty(wasted, preferredSkin, dontChangeSkin, player)
	if not client then client = player end
	if wasted then
		client:removeFromVehicle()
		client.m_WasOnDuty = true
	end

	if getPedOccupiedVehicle(client) then
		return client:sendError("Steige erst aus dem Fahrzeug aus!")
	end
	local faction = client:getFaction()
	if faction:isEvilFaction() then
		if wasted or (client.m_CurrentDutyPickup and getDistanceBetweenPoints3D(client.position, client.m_CurrentDutyPickup.position) <= 10) then
			self:setPlayerDuty(client, not client:isFactionDuty(), wasted, preferredSkin, dontChangeSkin)
		else
			client:sendError(_("Du bist zu weit entfernt!", client))
		end
	else
		client:sendError(_("Du bist in keiner Gang / Mafia!", client))
		return false
	end
end

function FactionEvil:Event_FactionRearm()
	if not self:isPlayerInDutyPickup(client) then return client:sendError(_("Du bist zu weit entfernt!", client)) end
	if client:isFactionDuty() then
		client.m_WeaponStoragePosition = client.position
		client:triggerEvent("showFactionWeaponShopGUI", client.m_CurrentDutyPickup)
		client:setHealth(100)
		client:setArmor(100)
		StatisticsLogger:getSingleton():addHealLog(client, 100, "Faction Rearm Heal")
		DamageManager:getSingleton():clearPlayer(client)
		client:checkLastDamaged()
		local wStorage, aStorage
		for i = 1,12 do
			wStorage, aStorage = Guns:getSingleton():getWeaponInStorage( client, i)
			if wStorage then
				Guns:getSingleton():setWeaponInStorage(client, wStorage, false)
			end
		end
	end
end


function FactionEvil:Event_storageWeapons(player)
	local client = client
	if player and isElement(player) then
		client = player
	end
	if not self:isPlayerInDutyPickup(client) then return client:sendError(_("Du bist zu weit entfernt!", client)) end
	local faction = client:getFaction()
	if faction and faction:isEvilFaction() then
		if client:isFactionDuty() then
			faction:storageWeapons(client)
		end
	end
end

function FactionEvil:forceOpenLCNGates()
	if not self.m_LCNGates then return end
	
	for i, gate in pairs(self.m_LCNGates) do
		if gate.m_Closed == true then
			gate:triggerMovement(false, true)
		end
	end
end

function FactionEvil:onLCNBarrierGateHit(player)
	if player:getFaction() and player:getFaction():getId() == FactionStaticId.LCN and ActionsCheck:getSingleton():isCurrentAction() ~= "Weihnachtstruck" then
		return true
	else
		return false 
	end 
end