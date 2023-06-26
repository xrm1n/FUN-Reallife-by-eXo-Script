-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleTuningTemplateGUI.lua
-- *  PURPOSE:     VehicleTuningTemplate-GUI, managing tuning templates
-- *
-- ****************************************************************************
VehicleTuningTemplateGUI = inherit(GUIForm)
inherit(Singleton, VehicleTuningTemplateGUI)

addRemoteEvents{"onReceiveHandlingTemplates", "onReceiveVehicleShops" }

function VehicleTuningTemplateGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Admin: Fahrzeug-Menü", true, true, self)

	self.m_Window:addBackButton(function ()  delete(self) AdminGUI:getSingleton():show() end)

	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel({"Vorlagen", "Entwicklung", "Shop-Fahrzeuge"})
	if self.m_TabPanel then
		self.m_TabPanel:updateGrid()
		self:setupTemplateTab()
		self:setupShop()
	end

	addEventHandler("onReceiveHandlingTemplates", root, bind(self.Event_GetHandlingTemplates, self))
	addEventHandler("onReceiveVehicleShops", root, bind(self.Event_GetVehicleShops, self))
	triggerServerEvent("requestHandlingTemplates", root, localPlayer)
	triggerServerEvent("requestVehicleShops", root, localPlayer)
end

function VehicleTuningTemplateGUI:setupTemplateTab()
	self.m_InfoLabel = GUIGridLabel:new(1, 1, 16, 1, "Es wurden 0 Performance-Tunings gefunden für 0 Modelle!", self.m_Tabs[1])
	self.m_NameSearch = GUIGridEdit:new(1, 2, 11, 1, self.m_Tabs[1]):setCaption("Vorlage-Name")
	self.m_NameSearch.onChange = function () self:onSearch() end

	self.m_ModelSearch = GUIGridEdit:new(12, 2, 2, 1, self.m_Tabs[1]):setCaption("Modell"):setNumeric(true)
	self.m_ModelSearch.onChange = function () self:onSearch() end

	self.m_SearchButton = GUIGridIconButton:new(14, 2, FontAwesomeSymbols.Search, self.m_Tabs[1]):setTooltip("Nach Vorlage anhand von Modell & Name suchen!", "top")
	self.m_RefreshButton = GUIGridIconButton:new(15, 2, FontAwesomeSymbols.Refresh, self.m_Tabs[1]):setTooltip("Vorlagen manuell vom Server aktualisieren!", "top")
	self.m_SearchButton.onLeftClick = function () self:onSearch() end
	self.m_RefreshButton.onLeftClick = function() self:refresh() end

	self.m_TemplateGrid = GUIGridGridList:new(1, 3, 15, 7, self.m_Tabs[1])
	self.m_TemplateGrid:addColumn(_"Id", 0.1)
	self.m_TemplateGrid:addColumn(_"Name", 0.6)
	self.m_TemplateGrid:addColumn(_"Model", 0.3)
	GUIGridRectangle:new(1, 10, 11, 1, Color.Grey, self.m_Tabs[1])
	self.m_TemplateInfoLabel = GUIGridLabel:new(1, 10, 11, 1, "Vorlage #", self.m_Tabs[1]):setAlignX("center")

	self.m_ApplyButton = GUIGridIconButton:new(12, 10, FontAwesomeSymbols.Check, self.m_Tabs[1]):setTooltip("Auf aktuelles Fahrzeug anwenden", "bottom"):setBackgroundColor(Color.Green)
	self.m_ApplyButton.onLeftClick = function() self:applyClick() end

	self.m_ResetButton = GUIGridIconButton:new(13, 10, FontAwesomeSymbols.Erase, self.m_Tabs[1]):setTooltip("Aktuelles Fahrzeug auf Original resetten", "bottom"):setBackgroundColor(Color.Orange)
	self.m_ResetButton.onLeftClick = function() self:resetClick() end

	self.m_TemplateSave = GUIGridIconButton:new(14, 10, FontAwesomeSymbols.Save, self.m_Tabs[1]):setTooltip("Vorlage überschreiben", "bottom"):setBackgroundColor(Color.Red)
	self.m_TemplateSave.onLeftClick = function() self:saveClick() end

	self.m_TemplateDelete = GUIGridIconButton:new(15, 10, FontAwesomeSymbols.Trash, self.m_Tabs[1]):setTooltip("Vorlage löschen", "bottom"):setBackgroundColor(Color.Red)
	self.m_TemplateDelete.onLeftClick = function() self:deleteClick() end

	self.m_SelectedName = ""
	self.m_SelectedModel = 0
end

function VehicleTuningTemplateGUI:setupShop()
	self.m_ShopInfoLabel = GUIGridLabel:new(1, 1, 16, 1, "Es wurden 0 Shops gefunden mit 0 Fahrzeugen!", self.m_Tabs[3])

	self.m_ShopTemplateEdit = GUIGridEdit:new(1, 10, 3, 1, self.m_Tabs[3]):setCaption("Vorlagen-ID"):setNumeric(true)
	local btn = GUIGridIconButton:new(4, 10, FontAwesomeSymbols.Save, self.m_Tabs[3]):setTooltip("Vorlage anwenden", "bottom"):setBackgroundColor(Color.Green)
	btn.onLeftClick = function() self:onShopEditClick( "template-add" ) end

	local btn = GUIGridIconButton:new(5, 10, FontAwesomeSymbols.Trash, self.m_Tabs[3]):setTooltip("Vorlage entfernen", "bottom"):setBackgroundColor(Color.Orange)
	btn.onLeftClick = function() self:onShopEditClick( "template-remove" ) end

	self.m_ShopPriceEdit = GUIGridEdit:new(6, 10, 3, 1, self.m_Tabs[3]):setCaption("Preis"):setNumeric(true)
	local btn  = GUIGridIconButton:new(9, 10, FontAwesomeSymbols.Money, self.m_Tabs[3]):setTooltip("Preis anwenden", "bottom"):setBackgroundColor(Color.Green)
	btn.onLeftClick = function() self:onShopEditClick( "price" ) end

	self.m_ShopLevelEdit  = GUIGridEdit:new(10, 10, 2, 1, self.m_Tabs[3]):setCaption("Level"):setNumeric(true)
	local btn = GUIGridIconButton:new(12, 10, FontAwesomeSymbols.Check, self.m_Tabs[3]):setTooltip("Level anwenden", "bottom"):setBackgroundColor(Color.Green)
	btn.onLeftClick = function() self:onShopEditClick( "level" ) end

	self.m_ShopModelEdit = GUIGridEdit:new(13, 10, 2, 1, self.m_Tabs[3]):setCaption("Modell"):setNumeric(true)
	local btn = GUIGridIconButton:new(15, 10, FontAwesomeSymbols.Check, self.m_Tabs[3]):setTooltip("Modell anwenden", "bottom"):setBackgroundColor(Color.Green)
	btn.onLeftClick = function() self:onShopEditClick( "model" ) end


	self.m_ShopChanger = GUIGridChanger:new(1, 2, 15, 1, self.m_Tabs[3])
	self.m_ShopChanger.onChange = function()  self:addShopGrid(self.m_ShopChanger:getSelectedItem()) end
	self.m_ShopGrid = GUIGridGridList:new(1, 3, 15, 7, self.m_Tabs[3])
	self.m_ShopGrid:addColumn(_"Id", 0.1)
	self.m_ShopGrid:addColumn(_"Model", 0.2)
	self.m_ShopGrid:addColumn(_"Preis", 0.2)
	self.m_ShopGrid:addColumn(_"Level", 0.1)
	self.m_ShopGrid:addColumn(_"Vorlage", 0.4)
end

function VehicleTuningTemplateGUI:fillGrid( data ) -- [ Table-structure: data [ model ] [ name ] = { Id, Handling} ]
	local modelCount = 0
	local totalCount = 0
	local checkIfModelNotEmpty = false
	if data then
		for model, subData in pairs(data) do
			checkIfModelNotEmpty = false
			for name, content in pairs(subData) do
				if name:find(self.m_NameSearch:getText()) and (self.m_ModelSearch:getText() == "" or tonumber(self.m_ModelSearch:getText()) == model) then
					if not checkIfModelNotEmpty then
						checkIfModelNotEmpty = true
							modelCount = modelCount + 1
						end
					totalCount = totalCount + 1
					local item = self.m_TemplateGrid:addItem(content.m_Id, name, model)
					item.onLeftClick = function() self:onItemClick(name, model, content) end
				end
			end
		end
	end
	local modelNoun = modelCount == 1 and "Modell" or "Modelle"
	local verb = totalCount == 1 and "wurde" or "wurden"
	self.m_InfoLabel:setText(("Es %s %i Performance-Tunings gefunden für %i %s!"):format(verb, totalCount, modelCount, modelNoun))
end


function VehicleTuningTemplateGUI:fillShopGrid( data ) -- [ Table-structure: data [ model ] [ name ] = { Id, Handling} ]
	self.m_ShopVehicles = {}
	local vehicleCount = 0
	local shopCount = 0
	if data then
		for id, shop in pairs(data) do
			shopCount = shopCount + 1
			self.m_ShopChanger:addItem(shop.m_Name)
			self.m_ShopVehicles[shop.m_Name] = {}
			for model, subdata in pairs(shop.m_VehicleList) do
				for i = 1, #subdata do
					vehicleCount = vehicleCount + 1
					table.insert(self.m_ShopVehicles[shop.m_Name], {subdata[i].id, model, subdata[i].price, subdata[i].level, subdata[i].template, i, shop.m_Id})
				end
			end
		end
	end
	if shopCount > 0 then
		self.m_ShopChanger:setSelectedItem(1)
		self:addShopGrid(self.m_ShopChanger:getSelectedItem())
	end
	local modelNoun = shopCount == 1 and "Shop" or "Shops"
	local verb = shopCount == 1 and "wurde" or "wurden"
	local modelNoun2 = vehicleCount == 1 and "Fahrzeug" or "Fahrzeugen"
	self.m_ShopInfoLabel:setText(("Es %s %i %s gefunden mit %i %s!"):format(verb, shopCount, modelNoun, vehicleCount, modelNoun2))
end

function VehicleTuningTemplateGUI:addShopGrid( name )
	self.m_ShopGrid:clear()
	self:resetShopEdits()
	local id, model, price, level
	if self.m_ShopVehicles[name] then
		for id, data in ipairs(self.m_ShopVehicles[name]) do
			id, model, price, level, template, index, shop = unpack(data)
			if template == "" then template = "Standard" end
			local item = self.m_ShopGrid:addItem(id, getVehicleNameFromModel(model), ("$%i"):format(price), level, template)
			item.index = index
			item.model = model
			item.shop = shop
			item.onLeftClick = function() self:onItemShopClick(item) end
		end
	end
end

function VehicleTuningTemplateGUI:onSearch()
	if self.m_TemplateGridData then
		self.m_TemplateGrid:clear()
		self:fillGrid( self.m_TemplateGridData )
	end
end

function VehicleTuningTemplateGUI:onItemClick(name, model, content)
	if self.m_TemplateShortMessage then
		self.m_TemplateShortMessage:delete()
	end
	self.m_TemplateShortMessage = ShortMessage:new("", ("Performance-Vorlage: #%i"):format(content.m_Id), tocolor(140,40,0), -1, self.m_ClickBind, nil, nil, nil, true)
	self.m_TemplateShortMessage:setText(("• Fahrzeug-Modell %s (%i) \n• Name %s\n• Erstellt von %s\n• Erstellt am: %s"):format(getVehicleNameFromModel(model) or "", model, name, content.m_CreatorName or "Invalid", getOpticalTimestamp(content.m_Time)))
	self.m_TemplateInfoLabel:setText(("#%i %s"):format(content.m_Id, name))
	self.m_SelectedName = name
	self.m_SelectedModel = model
end

function VehicleTuningTemplateGUI:onItemShopClick(item)
	self:resetShopEdits()
	self.m_LastShopShop = item.shop -- yea i know
	self.m_LastShopIndex = item.index
	self.m_LastShopModel = item.model
end

function VehicleTuningTemplateGUI:onShopEditClick( edit )
	if self.m_LastShopShop and self.m_LastShopIndex and self.m_LastShopModel then
		local value
		if edit == "template-add" then
			value = tonumber(self.m_ShopTemplateEdit:getText())
		elseif edit == "template-remove" then
			value = -1
		elseif edit == "price" then
			value = tonumber(self.m_ShopPriceEdit:getText())
		elseif edit == "level" then
			value = tonumber(self.m_ShopLevelEdit:getText())
		else
			value = tonumber(self.m_ShopModelEdit:getText())
		end
		if value then
			triggerServerEvent("editVehicleShop", localPlayer, self.m_LastShopShop, self.m_LastShopModel, self.m_LastShopIndex, edit, value)
		end
	end
end

function VehicleTuningTemplateGUI:resetShopEdits()
	self.m_LastShopShop = false -- yea i know
	self.m_LastShopIndex = false
	self.m_LastShopModel = false
	self.m_ShopModelEdit:setText("")
	self.m_ShopLevelEdit:setText("")
	self.m_ShopPriceEdit:setText("")
	self.m_ShopTemplateEdit:setText("")
end


function VehicleTuningTemplateGUI:saveClick()
	local vehicle = localPlayer:getOccupiedVehicle() or localPlayer:getContactElement()
	if vehicle and getElementType(vehicle) =="vehicle" then
		QuestionBox:new(_("Möchtest du diese Vorlage %s überschreiben?", self.m_SelectedName),
		function()
			triggerServerEvent("saveHandlingTemplate", localPlayer, self.m_SelectedName, self.m_SelectedModel, vehicle, true)
		end)
	else
		ErrorBox:new(_"Es wurd kein Fahrzeug gefunden für die Vorlage!")
	end
end

function VehicleTuningTemplateGUI:deleteClick()
	QuestionBox:new(_("Möchtest du diese Vorlage %s löschen?", self.m_SelectedName),
		function()
			triggerServerEvent("deleteHandlingTemplate", localPlayer, self.m_SelectedName, self.m_SelectedModel)
		end)
end

function VehicleTuningTemplateGUI:applyClick()
	local vehicle = localPlayer:getOccupiedVehicle() or localPlayer:getContactElement()
	if vehicle and getElementType(vehicle) =="vehicle" then
		QuestionBox:new(_("Möchtest du diese Vorlage %s auf das Fahrzeug anwenden (Sitze drinnen oder stehe drauf)? ", self.m_SelectedName),
		function()
			triggerServerEvent("applyHandlingTemplate", localPlayer, self.m_SelectedName, self.m_SelectedModel)
		end)

	else
		ErrorBox:new(_"Es wurd kein Fahrzeug gefunden zum Anwenden!")
	end
end

function VehicleTuningTemplateGUI:resetClick()
	local vehicle = localPlayer:getOccupiedVehicle() or localPlayer:getContactElement()
	if vehicle and getElementType(vehicle) =="vehicle" then
		QuestionBox:new(_("Möchtest du das Handling dieses Fahrzeuges auf die Original-Werte zurücksetzen? "),
		function()
			triggerServerEvent("vehicleResetHandling", localPlayer)
		end)

	else
		ErrorBox:new(_"Es wurd kein Fahrzeug gefunden zum Anwenden!")
	end
end

function VehicleTuningTemplateGUI:mergeSearch(result, result2)
	local results = { }
	for i = 1, #result do
		for i = 1, #result2 do
			if result[i] == result[2] then
				table.insert(results, result[i])
			end
		end
	end
	return results
end

function VehicleTuningTemplateGUI:Event_GetHandlingTemplates( data )
	if data then
		self.m_TemplateGridData = data
		self.m_TemplateGrid:clear()
		self:fillGrid( data )
	end
end


function VehicleTuningTemplateGUI:Event_GetVehicleShops( data )
	if data then
		self.m_ShopGrid:clear()
		self:fillShopGrid( data )
	end
end

function VehicleTuningTemplateGUI:refresh()
	triggerServerEvent("requestHandlingTemplates", localPlayer)
	triggerServerEvent("requestVehicleShops", localPlayer)
end

function VehicleTuningTemplateGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	self:refresh()
end

function VehicleTuningTemplateGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
	if self.m_TemplateShortMessage then
		self.m_TemplateShortMessage:delete()
	end
end

