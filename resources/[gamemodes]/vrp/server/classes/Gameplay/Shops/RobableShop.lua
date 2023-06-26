-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/Gameplay/RobableShop.lua
-- * PURPOSE: Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

addRemoteEvents{"robableShopGiveBagFromCrash"}

ROBSHOP_TIME = 15*60*1000
ROBSHOP_PAUSE = 30*60 --in Sec
ROBSHOP_PAUSE_SAME_SHOP = 6*60*60 -- 6h in Sec
ROBSHOP_MAX_MONEY = 15000
ROBSHOP_LAST_ROB = 0

function RobableShop:constructor(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension)
	-- Create NPC(s)
	self.m_Shop = shop
	self.m_LastRob = self.m_LastRob or 0
	self:spawnPed(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension)
	self.m_BankAccountServer = BankServer.get("gameplay.shop_rob")

	-- Respawn ped after a while (if necessary)
	addEventHandler("onPedWasted", self.m_Ped,
	function()
		setTimer(function() self:spawnPed(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension) end, 5*60*1000, 1)
	end
)

end

function RobableShop:spawnPed(shop, pedPosition, pedRotation, pedSkin, interiorId, dimension)
	if self.m_Ped and isElement(self.m_Ped) then
		self.m_Ped:destroy()
	end

	self.m_Ped = TargetableNPC:new(pedSkin, pedPosition.x, pedPosition.y, pedPosition.z, pedRotation)
	self.m_Ped:setInterior(interiorId)
	self.m_Ped:setDimension(dimension)
	self.m_Ped.Shop = shop
	self.m_Ped.onTargetted = bind(self.Ped_Targetted, self)

end

function RobableShop:Ped_Targetted(ped, attacker)
	if attacker:getGroup() then
		if attacker:getGroup() == self.m_AttackerGroup then return false end -- prevent error toasts when the robbers of the current rob attack the shop ped
		if attacker:getGroup():getType() == "Gang" then
			if not (attacker:getFaction() and attacker:getFaction():isStateFaction()) then
				if not attacker:isFactionDuty() then
					if not timestampCoolDown(ROBSHOP_LAST_ROB, ROBSHOP_PAUSE) then
						attacker:sendError(_("Der nächste Shop-Überfall ist am/um möglich: %s!", attacker, getOpticalTimestamp(ROBSHOP_LAST_ROB+ROBSHOP_PAUSE)))
						return false
					end

					if not timestampCoolDown(self.m_LastRob, ROBSHOP_PAUSE_SAME_SHOP) then
						attacker:sendError(_("Dieser Shop kann erst am/um überfallen werden: %s!", attacker, getOpticalTimestamp(ROBSHOP_LAST_ROB+ROBSHOP_PAUSE_SAME_SHOP)))
						return false
					end

					if FactionState:getSingleton():countPlayers(true, false) < SHOPROB_MIN_MEMBERS then
						attacker:sendError(_("Es müssen mindestens %d aktive Staatsfraktionisten online sein!",attacker, SHOPROB_MIN_MEMBERS))
						return false
					end
					local shop = ped.Shop
					self.m_Shop = shop
					if shop:getMoney() >= 250 then
						self.m_LastRob = getRealTime().timestamp
						ROBSHOP_LAST_ROB = getRealTime().timestamp
						self:startRob(shop, attacker, ped)
					else
						attacker:sendError(_("Es ist nicht genug Geld zum ausrauben in der Shopkasse!", attacker))
					end
				else
					attacker:sendError(_("Du bist im Dienst, du darfst keinen Überfall machen!", attacker))
				end
			else
				attacker:sendError(_("Du bist Polizist, du darfst keinen Überfall machen!", attacker))
			end
		else
			attacker:sendError(_("Du bist Mitglied einer privaten Firma! Nur Gangs können überfallen!", attacker))
		end
	else
		attacker:sendError(_("Du bist kein Mitglied einer privaten Gang!", attacker))
	end
end

function RobableShop:startRob(shop, attacker, ped)
	if shop.m_Marker then
		shop.m_Marker:setAlpha(0)
	end

	self.m_RobActive = true

	PlayerManager:getSingleton():breakingNews("%s meldet einen Überfall durch eine Straßengang!", shop:getName())
	Discord:getSingleton():outputBreakingNews(string.format("%s meldet einen Überfall durch eine Straßengang!", shop:getName()))

	FactionState:getSingleton():sendWarning("Die Alarmanlage von %s meldet einen Überfall!", "Neuer Einsatz", false, serialiseVector(shop.m_Position), shop:getName())
	shop.m_LastRob = getRealTime().timestamp

	-- Play an alarm
	local pos = ped:getPosition()
	triggerClientEvent("shopRobbed", attacker, pos.x, pos.y, pos.z, ped:getDimension())
	triggerClientEvent("shopRobbed", attacker, self.m_Shop.m_Position.x, self.m_Shop.m_Position.y, self.m_Shop.m_Position.z, 0)

	-- Report the crime
	--attacker:reportCrime(Crime.ShopRob)
	attacker:sendInfo(_("Ziele mit deinen Komplizen weiter auf den Verkäufer, um immer mehr Geld zu bekommen!", attacker))

	self.m_Attacker = attacker
	self.m_AttackerGroup = attacker:getGroup()

	self.m_Bag = createObject(1550, pos)
	self.m_Bag:setData("MoneyBag", true, true)
	self.m_Bag:setData("Money", 0, true)
	self.m_Bag.Money = 0
	addEventHandler("onElementClicked", self.m_Bag, bind(self.onBagClick, self))

	local evilPosis = {self:getNearestMarker(self.m_Shop.m_Position, ROBABLE_SHOP_EVIL_TARGETS)}
	local evilPos = evilPosis[math.random(2, 3)]
	local statePos = self:getNearestMarker(self.m_Shop.m_Position, ROBABLE_SHOP_STATE_TARGETS)


	self.m_Gang = attacker:getGroup()
	self.m_Gang:attachPlayerMarkers()
	self.m_EvilBlip = Blip:new("Marker.png", evilPos.x, evilPos.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_EvilBlip:setDisplayText("Beute-Abgabepunkt")
	self.m_EvilBlip:setZ(evilPos.z)
	self.m_StateBlip = Blip:new("PoliceRob.png", statePos.x, statePos.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Yellow)
	self.m_StateBlip:setDisplayText("Beute-Abgabe (Staat)")
	self.m_StateBlip:setZ(statePos.z)
	self.m_EvilMarker = createMarker(evilPos, "cylinder", 2.5, 255, 0, 0, 100)
	self.m_StateMarker = createMarker(statePos, "cylinder", 2.5, 0, 255, 0, 100)
	self.m_onDeliveryMarkerHit = bind(self.onDeliveryMarkerHit, self)
	addEventHandler("onMarkerHit", self.m_EvilMarker, self.m_onDeliveryMarkerHit)
	addEventHandler("onMarkerHit", self.m_StateMarker, self.m_onDeliveryMarkerHit)
	self.m_onCrash = bind(self.onCrash, self)
	addEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)
	--self.m_characterInitializedFunc = bind(self.characterInitialized, self)
	--addEventHandler("characterInitialized", root, self.m_characterInitializedFunc)

	StatisticsLogger:getSingleton():addActionLog("Shop-Rob", "start", attacker, self.m_Gang, "group")

	self:giveBag(attacker)
	self.m_Ped.onTargetRefresh = function(count, startingPlayer)
		outputDebug(count)
		if count == 0 then return false end
		local attackers = self.m_Ped:getAttackers()
		local hasAnyoneBag = false
		local eyeryoneInRange = true
		local realCount = 0
		for attacker in pairs(attackers) do
			if attacker:getPlayerAttachedObject() == self.m_Bag then
				if (attacker:getPosition()-self.m_Ped:getPosition()).length < 50 then
					hasAnyoneBag = attacker
				end
			end
			if attacker:getGroup() == self.m_AttackerGroup then
				realCount = realCount + 1
			end
		end
		if hasAnyoneBag then
			local rnd = math.random(40*realCount, 100*realCount)
			local rob = self.m_Bag.Money + rnd
			if shop:getMoney() >= rnd and rob <= ROBSHOP_MAX_MONEY then
				if not self.m_Bag.Money then self.m_Bag.Money = 0 end
				self.m_Bag.Money = rob
				self.m_Bag:setData("Money", self.m_Bag.Money, true)
				shop.m_BankAccount:transferMoney(self.m_BankAccountServer, rnd, "Raub", "Gameplay", "ShopRob")
				hasAnyoneBag:sendShortMessage(_("+%d$ - Tascheninhalt: %d$", hasAnyoneBag, rnd, self.m_Bag.Money))
			else
				hasAnyoneBag:sendInfo(_("Die Kasse ist nun leer! Du hast die maximale Beute!", hasAnyoneBag))
			end
		else
			startingPlayer:sendWarning(_("Mindestens ein Gang-Mitglied muss den Verkäufer bedrohen und dabei den Geldsack dabei haben!", startingPlayer))
		end
	end

	self.m_Func = bind(RobableShop.m_onExpire, self)
	self.m_ExpireTimer = setTimer(self.m_Func, ROBSHOP_TIME,1)

	attacker:triggerEvent("Countdown", ROBSHOP_TIME/1000, "Shop Überfall")

end

function RobableShop:m_onExpire()
	if self.m_Shop.m_Marker then
		self.m_Shop.m_Marker:setAlpha(255)
	end

	self.m_RobActive = false

	if isElement( self.m_EvilMarker) then destroyElement(self.m_EvilMarker) end
	if isElement( self.m_StateMarker) then destroyElement(self.m_StateMarker) end
	for key, player in ipairs(getElementsByType("player")) do
		player:detachPlayerObject(self.m_Bag)
		removeEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
		removeEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
		removeEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
		removeEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)
		--removeEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)
	end

	local money = self.m_Bag.Money or 0
	local stateMoney = math.floor(money/3)
	self.m_BankAccountServer:transferMoney({FactionManager:getSingleton():getFromId(1), nil, true}, stateMoney, "Shop Raub Sicherstellung 1/3", "Gameplay", "ShopRob")
	self.m_BankAccountServer:transferMoney(self.m_Shop.m_BankAccount, stateMoney*2, "Shop Raub Sicherstellung 2/3", "Gameplay", "ShopRob")
	self.m_Bag:destroy()

	--removeEventHandler("characterInitialized", root, self.m_characterInitializedFunc)

	delete(self.m_EvilBlip)
	delete(self.m_StateBlip)
	delete(self.m_BagBlip)
	self.m_Ped.onTargetRefresh = nil
	StatisticsLogger:getSingleton():addActionLog("Shop-Rob", "stop", nil, self.m_Gang, "group")

	self.m_Gang:removePlayerMarkers()
	removeEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)
	self.m_Gang:sendMessage("[Shop-Rob] Die Zeit für den Rob ist abgelaufen!",200,0,0,true)
	FactionManager:getSingleton():getFromId(1):sendMessage("[Shop-Rob] #EEEEEEDie Zeit für den Rob ist abgelaufen!",200,200,0,true)

	if self.m_Attacker and isElement(self.m_Attacker) then
		self.m_Attacker:triggerEvent("CountdownStop", "Shop Überfall")
	end
	self.m_Attacker = nil
	self.m_AttackerGroup = nil
end

function RobableShop:getNearestMarker(position, markerPositions)
	table.sort(markerPositions, function(a, b)
		return getDistanceBetweenPoints3D(a, position) < getDistanceBetweenPoints3D(b, position)
	end)
	return markerPositions[1], markerPositions[2], markerPositions[3]
end

function RobableShop:stopRob(player)
	if self.m_ExpireTimer and isTimer(self.m_ExpireTimer) then
		killTimer(self.m_ExpireTimer)
	end

	if self.m_Shop.m_Marker then
		self.m_Shop.m_Marker:setAlpha(255)
	end

	self.m_RobActive = false

	if isElement( self.m_EvilMarker) then destroyElement(self.m_EvilMarker) end
	if isElement( self.m_StateMarker) then destroyElement(self.m_StateMarker) end

	player:detachPlayerObject(self.m_Bag)

	self.m_Bag:destroy()

	removeEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
	removeEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
	removeEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
	removeEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)
	--removeEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)
	--removeEventHandler("characterInitialized", root, self.m_characterInitializedFunc)

	delete(self.m_EvilBlip)
	delete(self.m_StateBlip)
	delete(self.m_BagBlip)

	StatisticsLogger:getSingleton():addActionLog("Shop-Rob", "stop", nil, self.m_Gang, "group")

	self.m_Gang:removePlayerMarkers()
	removeEventHandler("robableShopGiveBagFromCrash", root, self.m_onCrash)

	if self.m_Attacker and isElement(self.m_Attacker) then
		self.m_Attacker:triggerEvent("CountdownStop", "Shop Überfall")
	end
	self.m_Attacker = nil
	self.m_AttackerGroup = nil
	self.m_Ped.onTargetRefresh = nil
end

function RobableShop:giveBag(player)
	self.m_Bag:setInterior(player:getInterior())
	self.m_Bag:setDimension(player:getDimension())
	player:attachPlayerObject(self.m_Bag)
	if self.m_BagBlip then delete(self.m_BagBlip) end
	self.m_BagBlip = Blip:new("MoneyBag.png", 0, 0, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, {85, 58, 38})
	self.m_BagBlip:setDisplayText("Shopraub-Beute")
	self.m_BagBlip:attach(self.m_Bag)

	self.m_onDamageFunc = bind(self.onDamage, self)
	self.m_onWastedFunc = bind(self.onWasted, self)
	self.m_onVehicleEnterFunc = bind(self.onVehicleEnter, self)
	self.m_onVehicleExitFunc = bind(self.onVehicleExit, self)
	--self.m_onPlayerQuitFunc = bind(self.onPlayerQuit, self)

	addEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
	addEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
	addEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
	addEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)
	--addEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)

	player:sendShortMessage(_("Du hast die Beute erhalten!", player))

	if player:getOccupiedVehicle() then
		triggerClientEvent(player, "robableShopEnableVehicleCollision", player, player:getOccupiedVehicle())
	end

end

function RobableShop:onBagClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			if self:checkBagAllowed(player) then
			self:giveBag(player)
			else
			player:sendError(_("Du darfst die Beute nicht besitzen!", player))
			end
		else
			player:sendError(_("Du bist zu weit von dem Geldsack entfernt!", player))
		end
	end
end

function RobableShop:removeBag(player, logout)
	if player.vehicle and logout then player.vehicle:setVelocity(0, 0, 0.1) end --to prevent bag from being stuck in vehicle
	player:detachPlayerObject(self.m_Bag, logout)

	removeEventHandler("onPlayerWasted", player, self.m_onWastedFunc)
	removeEventHandler("onPlayerDamage", player, self.m_onDamageFunc)
	removeEventHandler("onPlayerVehicleEnter", player, self.m_onVehicleEnterFunc)
	removeEventHandler("onPlayerVehicleExit", player, self.m_onVehicleExitFunc)
	--removeEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)

	player:sendShortMessage(_("Du hast die Beute verloren!", player))
end

function RobableShop:checkBagAllowed(player)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	if player:getGroup() == self.m_Gang or (player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty()) then
		if not player:isDead() then
			return true
		end
	end
	return false
end

function RobableShop:characterInitialized()
	if not self.m_Gang then
		return
	end
	if not source:getGroup() then
		return
	end
	if self.m_Gang.m_Id == source:getGroup().m_Id then
		source:getGroup():attachPlayerMarker(source)
	end
end

function RobableShop:onDamage(attacker, weapon)
	if not source.RobableShopDmgPause then
		if isElement(attacker) and self:checkBagAllowed(attacker) then
			if weapon == 0 then
				source.RobableShopDmgPause = true
				local source = source -- source in timer fix
				setTimer(function() source.RobableShopDmgPause = false end, 1500, 1)
				if source:getPlayerAttachedObject() and source:getPlayerAttachedObject():getModel() == 1550 and self:checkBagAllowed(attacker) then
					self:removeBag(source)
					self:giveBag(attacker)
				else
					attacker:sendError(_("Du darfst die Beute nicht besitzen!", attacker))
				end
			end
		end
	end
end

function RobableShop:onWasted()
	local pos = source:getPosition()
	pos.z = pos.z+1.5
	self:removeBag(source)
	self.m_Bag:setPosition(pos)
	self.m_Bag:setCollisionsEnabled(true)
end

function RobableShop:onVehicleEnter(veh)
	triggerClientEvent(source, "robableShopEnableVehicleCollision", source, veh)
end

function RobableShop:onVehicleExit(veh)
	triggerClientEvent(source, "robableShopDisableVehicleCollision", source, veh)
end

function RobableShop:onPlayerQuit()
	self:removeBag(source, true)
	self.m_Gang:removePlayerMarker(source)
end

function RobableShop:onCrash(player)
	if isElement(player) then
		if client:getPlayerAttachedObject() and client:getPlayerAttachedObject():getModel() == 1550 and self:checkBagAllowed(player) then
			if self:checkBagAllowed(player) then
				self:removeBag(client)
				self:giveBag(player)
			else
				player:sendError(_("Du darfst die Beute nicht besitzen!", player))
			end
		end
	end

end

function RobableShop:onDeliveryMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getPlayerAttachedObject() and hitElement:getPlayerAttachedObject() == self.m_Bag and self:checkBagAllowed(hitElement) then
			local money = self.m_Bag.Money
			if source == self.m_EvilMarker and hitElement:getGroup() == self.m_Gang then
				self.m_BankAccountServer:transferMoney(hitElement, money, "Shop-Raub", "Gameplay", "ShopRob")
				PlayerManager:getSingleton():breakingNews("%s Überfall: Die Täter sind mit der Beute entkommen!", self.m_Shop:getName())
			elseif source == self.m_StateMarker and hitElement:getFaction() and hitElement:getFaction():isStateFaction() and hitElement:isFactionDuty() then
				local stateMoney = math.floor(money/3)
				self.m_BankAccountServer:transferMoney(hitElement, stateMoney, "Shop Raub Sicherstellung 1/3", "Gameplay", "ShopRob")
				self.m_BankAccountServer:transferMoney({FactionManager:getSingleton():getFromId(1), nil, true}, stateMoney, "Shop Raub Sicherstellung 1/3", "Gameplay", "ShopRob")
				self.m_BankAccountServer:transferMoney(self.m_Shop.m_BankAccount, stateMoney, "Shop Raub Sicherstellung 1/3", "Gameplay", "ShopRob")
				hitElement:sendInfo(_("Beute sichergestellt! Der Shop, du und die Staatskasse haben je %d$ erhalten!", hitElement, stateMoney))
				Discord:getSingleton():outputBreakingNews(string.format("Die Beute des %s Überfall wurde sichergestellt!", self.m_Shop:getName()))
				PlayerManager:getSingleton():breakingNews("Die Beute des %s Überfall wurde sichergestellt!", self.m_Shop:getName())
			else
				hitElement:sendError(_("Du darfst die Beute hier nicht abgeben!", hitElement))
				return
			end

			self.m_Bag.Money = 0
			self:stopRob(hitElement)
		else
			hitElement:sendError(_("Du darfst die Beute nicht besitzen!", hitElement))
		end
	end
end
