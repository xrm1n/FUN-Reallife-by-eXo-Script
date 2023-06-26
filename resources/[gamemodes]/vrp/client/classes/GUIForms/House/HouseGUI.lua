-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HouseGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
HouseGUI = inherit(GUIForm)
inherit(Singleton, HouseGUI)

addRemoteEvents{"showHouseMenu","hideHouseMenu", "addHouseBlip", "removeHouseBlip", "addGarageBlip", "removeGarageBlip"}

HouseGUI.Blips = {}
HouseGUI.GarageBlips = {}
function HouseGUI:constructor(ownerName, price, rentprice, isValidRob, isClosed, tenants, money, hasKey, houseId, pickup, garage, salePrice)
	self.m_isOwner = ownerName == localPlayer:getName()
	self.m_isTenant = tenants and tenants[localPlayer:getPrivateSync("Id")]
	self.m_isRentEnabled = rentprice > 0
	self.m_isInside = localPlayer:getDimension() > 0 or localPlayer:getInterior() > 0
	self.m_Tenants = tenants
	self.m_Money = money
	self.m_Price = price
	self.m_SalePrice = salePrice
	self.m_ForSale = salePrice and salePrice > 0 or false

	GUIWindow.updateGrid()
	self.m_Width = grid("x", self.m_isOwner and 13 or 7)
	self.m_Height = grid("y", self.m_isOwner and 11 or 10)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, pickup)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Hausmenü (Hausnr. %d)", houseId), true, true, self)

	self.m_OwnerLbl = GUIGridLabel:new(1, 0.8, 6, 1, _("Besitzer: %s", ownerName or "Niemand"), self.m_Window)
	self.m_PriceLbl = GUIGridLabel:new(1, 1.5, 5, 1, _("Grundpreis: %s", toMoneyString(price)), self.m_Window)
	self.m_SalePriceLbl = GUIGridLabel:new(1, 2.3, 6, 1, _("Verkaufspreis: %s", toMoneyString(salePrice)), self.m_Window):setColor(Color.LightBlue):setVisible((salePrice and salePrice > 0) or false)
	self.m_GarageLbl = GUIGridLabel:new(1, 3.1, 4, 1, _("Garage: %s", garage), self.m_Window)

	if not ownerName then
		self.m_BuyBtn = GUIGridButton:new(1, 4, 6, 1, _"Haus kaufen", self.m_Window):setBackgroundColor(Color.Green)
		self.m_BuyBtn.onLeftClick = bind(HouseGUI.buyHouse, self)
	elseif self.m_isRentEnabled or self.m_isTenant then
		self.m_RentPriceLbl = GUIGridLabel:new(1, 4, 4, 1, _("Mietpreis: %s", toMoneyString(rentprice)), self.m_Window)
		self.m_RentBtn = GUIGridButton:new(4, 4, 3, 1, self.m_isTenant and _"Ausmieten" or _"Einmieten", self.m_Window):setEnabled(not self.m_isOwner)

		self.m_RentBtn.onLeftClick = function()
			if self.m_isTenant then
				triggerServerEvent("unrentHouse",root)
			else
				triggerServerEvent("rentHouse",root)
			end
		end
	else
		GUIGridLabel:new(1, 4, 6, 1, _"(Keine neuen Mieter akzeptiert)", self.m_Window)
	end

	self.m_LockBtn = GUIGridButton:new(1, 5, 6, 1, isClosed and _"Aufschließen" or _"Abschließen", self.m_Window):setEnabled(hasKey)
	self.m_SpawnBtn = GUIGridButton:new(1, 6, 6, 1, _"als Spawnpunkt festlegen", self.m_Window):setEnabled(hasKey)
	self.m_BuyHouseFromPlayerBtn = GUIGridButton:new(1, 7, 6, 1, _"Haus von Spieler kaufen", self.m_Window):setEnabled((salePrice and salePrice > 0 and not self.m_isOwner) or false):setBackgroundColor(Color.Green)
	self.m_BuyHouseFromPlayerBtn.onLeftClick = function()
		QuestionBox:new(_("Möchtest du das Haus für %s (%s Grundpreis & %s Verkaufspreis) kaufen?", toMoneyString(price + salePrice), toMoneyString(price), toMoneyString(salePrice)), 
		function()
			triggerServerEvent("buyHouseFromPlayer", localPlayer)
		end, nil, localPlayer, 10)
	end
	self.m_RobBtn = GUIGridButton:new(1, 8, 6, 1, (localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true) and _"Tür aufbrechen" or _"Raub starten", self.m_Window):setBackgroundColor(Color.Orange):setEnabled(isValidRob)
	self.m_EnterLeaveBtn = GUIGridButton:new(1, 9, self.m_isInside and 6 or 5, 1, self.m_isInside and _"Verlassen" or (ownerName and _"Betreten" or _"Besichtigen"), self.m_Window):setBarEnabled(false)
	if not self.m_isInside then
		self.m_DoorBellBtn = GUIGridIconButton:new(6, 9, FontAwesomeSymbols.Bell, self.m_Window):setTooltip(_"an der Tür klingeln", "bottom")
		self.m_DoorBellBtn.onLeftClick = function()
			triggerServerEvent("houseRingDoor",root)
		end
	end

	self.m_LockBtn.onLeftClick = function()
		triggerServerEvent("lockHouse",root)
	end

	self.m_SpawnBtn.onLeftClick = function()
		triggerServerEvent("onPlayerUpdateSpawnLocation", localPlayer, SPAWN_LOCATIONS.HOUSE)
	end

	self.m_RobBtn.onLeftClick = function()
		if (localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true) then
			triggerServerEvent("breakHouseDoor", localPlayer)
		else
			triggerServerEvent("tryRobHouse", localPlayer)
		end
	end

	self.m_EnterLeaveBtn.onLeftClick = function()
		if self.m_isInside then
			triggerServerEvent("leaveHouse",root)
		else
			triggerServerEvent("enterHouse",root)
		end
		delete(self)
	end

	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION.editHouseGeneral then
		self.m_EditBtn = GUIGridIconButton:new(6, 3, FontAwesomeSymbols.Edit, self.m_Window):setBackgroundColor(Color.Orange):setTooltip(_"Haus editieren", "left")
			self.m_EditBtn.onLeftClick = function()
			HouseEditGUI:new(self.m_ForSale)
		end
	end

	if self.m_isOwner then
		self:loadOwnerOptions()
	end
end

function HouseGUI:loadOwnerOptions()
	GUIGridLabel:new(7, 1, 6, 1, _"Besitzer-Optionen", self.m_Window):setHeader("sub")

	self.m_LblMoney = GUIGridLabel:new(7, 2, 6, 1, _("Kasse: %s", toMoneyString(self.m_Money)), self.m_Window)
	self.m_EditMoney = GUIGridEdit:new(7, 3, 4, 1, self.m_Window):setCaption(_"Betrag"):setNumeric(true, true)
	self.m_MoneyDepositBtn = GUIGridIconButton:new(11, 3, FontAwesomeSymbols.Double_Up, self.m_Window):setTooltip(_"Einzahlen")
	self.m_MoneyWithdrawBtn = GUIGridIconButton:new(12, 3, FontAwesomeSymbols.Double_Down, self.m_Window):setTooltip(_"Auszahlen")
	self.m_MoneyDepositBtn.onLeftClick = bind(HouseGUI.deposit, self)
	self.m_MoneyWithdrawBtn.onLeftClick = bind(HouseGUI.withdraw, self)

	self.m_TenantGrid = GUIGridGridList:new(7, 4, 6, 4, self.m_Window)
	self.m_TenantGrid:addColumn(_"Mieter", 1)

	for id, tenant in pairs(self.m_Tenants) do
		local item = self.m_TenantGrid:addItem(tenant)
		item.Id = id
	end

	self.m_RemoveTenantBtn = GUIGridIconButton:new(12, 4, FontAwesomeSymbols.Minus, self.m_Window):setTooltip(_"Mieter entfernen", "left"):setBackgroundColor(Color.Red)
	self.m_RemoveTenantBtn.onLeftClick = bind(HouseGUI.removeTenant, self)

	self.m_EditRent = GUIGridEdit:new(7, 8, 4, 1, self.m_Window):setCaption(_"Miete"):setNumeric(true, true)
	self.m_SaveRentBtn = GUIGridIconButton:new(11, 8, FontAwesomeSymbols.Save, self.m_Window):setBackgroundColor(Color.Green)
	self.m_RemoveRentBtn = GUIGridIconButton:new(12, 8, FontAwesomeSymbols.Ban, self.m_Window):setTooltip(_"Einmieten verbieten"):setBackgroundColor(Color.Red)

	self.m_SaveRentBtn.onLeftClick = bind(HouseGUI.saveRent, self)
	self.m_RemoveRentBtn.onLeftClick = bind(HouseGUI.saveRent, self, true)

	self.m_SetForSaleBtn = GUIGridButton:new(7, 9, 6, 1, _("%s", self.m_ForSale and "Verkauf beenden" or "Zum Verkauf anbieten"), self.m_Window):setBackgroundColor(Color.Orange)
	self.m_SetForSaleBtn.onLeftClick = bind(self.openPriceQuestionBox, self)

	self.m_SellBtn = GUIGridButton:new(7, 10, 6, 1, "Haus verkaufen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_SellBtn.onLeftClick = bind(HouseGUI.sellHouse, self)
end

function HouseGUI:deposit()
	local amount = self.m_EditMoney:getText()
	if amount and tonumber(amount) and tonumber(amount) > 0 then
		triggerServerEvent("houseDeposit", root, amount)
	else
		ErrorBox:new(_"Ungültiger Betrag!")
	end
end

function HouseGUI:withdraw()
	local amount = self.m_EditMoney:getText()
	if amount and tonumber(amount) and tonumber(amount) > 0 then
		triggerServerEvent("houseWithdraw", root, amount)
	else
		ErrorBox:new(_"Ungültiger Betrag!")
	end
end

function HouseGUI:removeTenant()
	local tenant = self.m_TenantGrid:getSelectedItem()
	if tenant and tenant.Id then
		triggerServerEvent("houseRemoveTenant", root, tenant.Id)
	else
		WarningBox:new(_"Bitte wähle einen Mieter aus!")
		return
	end

end

function HouseGUI:buyHouse()
	QuestionBox:new(_("Möchtest du wirklich dieses Haus kaufen? %s werden dir von deinem Konto abgebucht! Zudem kannst du nur ein Haus besitzen.", toMoneyString(self.m_Price)),
	function() triggerServerEvent("buyHouse",root) end,
	nil,
	localPlayer.position
	)

end

function HouseGUI:sellHouse()
	QuestionBox:new("Möchtest du wirklich dein Haus verkaufen? Du erhälst 75% des Preises auf dein Konto gutgeschrieben!",
	function() triggerServerEvent("sellHouse",root) end,
	nil,
	localPlayer.position
	)

end

function HouseGUI:saveRent(disable)
	local amount = disable == true and 0 or tonumber(self.m_EditRent:getText()) or 0

	if disable ~= true and math.clamp(100, amount, 5000) ~= amount then
		return WarningBox:new("Die Miete muss zwischen 100$ und 5000$ liegen")
	end
	triggerServerEvent("houseSetRent", root, amount)

end

function HouseGUI:openPriceQuestionBox()
	if self.m_ForSale then
		QuestionBox:new("Möchtest du den Verkauf des Hauses beenden?", 
		function()
			triggerServerEvent("setHouseForSale", localPlayer, false, 0)
		end, nil, localPlayer, 10)
	else
		InputBoxWithCheckbox:new("Haus zum Verkauf anbieten", "Für welchen Betrag möchtest du das Haus anbieten?", "Möchtest du das Haus für 5.000$ in der Stadthalle anzeigen lassen?",
		function(amount, showInTownhall)
			if not amount or amount == "" then
				return ErrorBox:new(_"Bitte gib einen Preis an.")
			end
			
			if math.clamp(1, amount, 10000000) == tonumber(amount) then
				triggerServerEvent("setHouseForSale", localPlayer, true, amount, showInTownhall)
			else
				WarningBox:new(_"Der Preis muss zwischen 1$ und 10.000.000$ liegen")
			end
		end, true)
	end
end

addEventHandler("showHouseMenu", root,
	function(...)
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
		HouseGUI:new(...)
	end
)

addEventHandler("hideHouseMenu", root,
	function()
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
	end
)

addEventHandler("addHouseBlip", root,
	function(id, x, y)
		if not HouseGUI.Blips[id] then
			HouseGUI.Blips[id] = Blip:new("House.png", x, y, 2000)
			HouseGUI.Blips[id]:setDisplayText("Haus")
			HouseGUI.Blips[id]:setOptionalColor({122, 163, 57})
			--HouseGUI.Blips[id]:setZ(1)
		end
	end
)

addEventHandler("addGarageBlip", root,
	function(id, x, y)
		if not HouseGUI.GarageBlips[id] then
			HouseGUI.GarageBlips[id] = Blip:new("Garage.png", x, y, 2000)
			HouseGUI.GarageBlips[id]:setDisplayText("Privater Stellplatz")
			HouseGUI.GarageBlips[id]:setOptionalColor({122, 163, 57})
			--HouseGUI.GarageBlips[id]:setZ(-100)
		end
	end
)

addEventHandler("removeHouseBlip", root,
	function(id)
		 if HouseGUI.Blips[id] then
		 	delete(HouseGUI.Blips[id])
			HouseGUI.Blips[id] = nil
		end
	end
)

addEventHandler("removeGarageBlip", root,
	function(id)
		 if HouseGUI.GarageBlips[id] then
		 	delete(HouseGUI.GarageBlips[id])
			HouseGUI.GarageBlips[id] = nil
		end
	end
)
