-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppSanNews.lua
-- *  PURPOSE:     San News app class
-- *
-- ****************************************************************************
AppSanNews = inherit(PhoneApp)

local ColorTable = {
	["Orange"] = Color.Orange,
	["Grün"] = Color.Green,
	["Blau-Grün"] = Color.AD_LightBlue,
	["Rot"] = Color.Red,
}

function AppSanNews:constructor()
	PhoneApp.constructor(self, "SanNews", "IconSanNews.png")
	
	addRemoteEvents{"receiveFuelPrices"}
	addEventHandler("receiveFuelPrices", localPlayer, bind(self.Event_receiveFuelPrices, self))
end

function AppSanNews:onOpen(form)

	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_Tabs["News"] = self.m_TabPanel:addTab(_"Nachrichten", FontAwesomeSymbols.Newspaper)
	local tab = self.m_Tabs["News"]
	self.m_NewsBrowser = GUIWebView:new(0, 0, tab.m_Width, tab.m_Height-10, (INGAME_WEB_PATH .. "/ingame/vRPphone/apps/sannews/index.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), true, self.m_Tabs["News"])


	self.m_Tabs["Advertisment"] = self.m_TabPanel:addTab(_"Werbung", FontAwesomeSymbols.Advertisement)
	tab = self.m_Tabs["Advertisment"]
	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.01, tab.m_Width*0.98, tab.m_Height*0.12, "Werbung", self.m_Tabs["Advertisment"]):setMultiline(true)
	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.15, tab.m_Width*0.98, tab.m_Height*0.07, "Werbe-Text:", self.m_Tabs["Advertisment"]):setMultiline(true)
	self.m_EditBox = GUIEdit:new(tab.m_Width*0.02, tab.m_Height*0.22, tab.m_Width*0.96, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	self.m_EditBox.onChange = function () self:calcCosts() end

	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.32, tab.m_Width*0.48, tab.m_Height*0.07, "Farbe:", self.m_Tabs["Advertisment"])
	self.m_ColorChanger = GUIChanger:new(tab.m_Width*0.4, tab.m_Height*0.32, tab.m_Width*0.58, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	for name, color in pairs(ColorTable) do
		self.m_ColorChanger:addItem(name)
	end
	self.m_ColorChanger.onChange = function () self:calcCosts() end

	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.42, tab.m_Width*0.5, tab.m_Height*0.07, "Dauer:", self.m_Tabs["Advertisment"])
	self.m_DurationChanger = GUIChanger:new(tab.m_Width*0.4, tab.m_Height*0.42, tab.m_Width*0.58, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	for name, duration in pairs(AD_DURATIONS) do
		self.m_DurationChanger:addItem(name)
	end
	self.m_DurationChanger.onChange = function () self:calcCosts() end

	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.52, tab.m_Width*0.5, tab.m_Height*0.07, "Sender:", self.m_Tabs["Advertisment"])
	self.m_SenderNameChanger = GUIChanger:new(tab.m_Width*0.4, tab.m_Height*0.52, tab.m_Width*0.58, tab.m_Height*0.07, self.m_Tabs["Advertisment"])
	self.m_SenderNameChanger:addItem(localPlayer:getName())
	if localPlayer:getGroupName() and localPlayer:getGroupName() ~= "" then
		self.m_SenderNameChanger:addItem(_"Firma / Gang")
	end
	if localPlayer:getFaction() then
		self.m_SenderNameChanger:addItem(_"Fraktion")
	end
	if localPlayer:getCompany() then
		self.m_SenderNameChanger:addItem(_"Unternehmen")
	end

	self.m_InfoRect = GUIRectangle:new(tab.m_Width*0.02, tab.m_Height*0.65, tab.m_Width*0.96, tab.m_Height*0.13, Color.Red, self.m_Tabs["Advertisment"])
	self.m_InfoLabel = GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.65, tab.m_Width*0.96, tab.m_Height*0.07, "Kosten: 0$", self.m_Tabs["Advertisment"]):setFontSize(0.8):setAlignX("center")

	self.m_SubmitButton = GUIButton:new(tab.m_Width*0.02, tab.m_Height*0.85, tab.m_Width*0.96, tab.m_Height*0.09, _"Werbung schalten", self.m_Tabs["Advertisment"]):setBackgroundColor(Color.Green)


	self.m_SubmitButton.onLeftClick =
		function()
			if localPlayer:isInPrison() then return ErrorBox:new(_"Du kannst im Prison keine Werbung schalten.") end
			local senderName = self.m_SenderNameChanger:getIndex()
			--we have to do this because otherwise we can't get the correct ad type if some options are not added in the first place
			local senderIndex = 1
			if senderName == _"Firma / Gang" then senderIndex = 2
			elseif senderName == _"Fraktion" then senderIndex = 3
			elseif senderName == _"Unternehmen" then senderIndex = 4 end

			triggerServerEvent("sanNewsAdvertisement", localPlayer, senderIndex, self.m_EditBox:getText(), self.m_ColorChanger:getIndex(), self.m_DurationChanger:getIndex())
		end
	self:calcCosts()

	self.m_Tabs["FuelPrices"] = self.m_TabPanel:addTab(_"Tankpreise", FontAwesomeSymbols.Newspaper)
	tab = self.m_Tabs["FuelPrices"]

	GUILabel:new(tab.m_Width*0.02, tab.m_Height*0.01, tab.m_Width*0.98, tab.m_Height*0.06, "Doppelklick zum Route berechnen", self.m_Tabs["FuelPrices"]):setAlignX("center")
	self.m_FuelPriceGrid = GUIGridList:new(10, 40, form.m_Width-20, form.m_Height-90, tab)
	self.m_FuelPriceGrid:addColumn("Aktuelle Tankpreise", 0.4)
	self.m_FuelPriceGrid:addColumn("", 0.6)
	
	self.m_TabPanel.onTabChanged = function(tabId)
		if tabId == self.m_Tabs["FuelPrices"].TabIndex then
			triggerServerEvent("requestFuelPrices", localPlayer)
		end
	end
end

function AppSanNews:calcCosts()
	local length = string.len(self.m_EditBox:getText())
	local selectedDuration = self.m_DurationChanger:getIndex()
	local durationExtra = (AD_DURATIONS[selectedDuration] - 20) * 2

	local colorMultiplicator = 1
	local selectedColor = self.m_ColorChanger:getIndex()
	if selectedColor ~= "Schwarz" then
		colorMultiplicator = 2
	end

	self.m_ColorChanger:setBackgroundColor(ColorTable[selectedColor])

	if self.m_EditBox:getText():find("\\") then
		self.m_InfoLabel:setText(_"Invalid Text!")
		self.m_InfoRect:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
		return
	end
	if length < 5 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu kurz! Mindestens 5 Zeichen!")
		self.m_InfoRect:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	elseif length > 50 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu lang! Maximal 50 Zeichen!")
		self.m_InfoRect:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	else
		local costs = (length*AD_COST_PER_CHAR + AD_COST + durationExtra) * colorMultiplicator
		self.m_InfoLabel:setText(_("Zeichenanzahl: %d Kosten: %d$", length, costs))
		self.m_InfoRect:setColor(Color.Green)
		self.m_SubmitButton:setEnabled(true)
	end
end



local currentAd
addEvent("showAd", true)
addEventHandler("showAd", root, function(sender, text, color, duration)
	if not localPlayer:isLoggedIn() then return end

	local callSender =
	function()
		if Phone:getSingleton():isOn()then
			Phone:getSingleton():onShow()
			Phone:getSingleton():closeAllApps()
			Phone:getSingleton():openAppByClass(AppCall)

			if sender.referenz == "player" then
				local player = getPlayerFromName(sender.name)

				if not player then
					ErrorBox:new(_"Dieser Spieler ist nicht mehr online!")
					return
				end

				if player == localPlayer then
					ErrorBox:new(_"Du kannst dich nicht selbst anrufen!")
					return
				end

				Phone:getSingleton():getAppByClass(AppCall):openInCall("player", player, CALL_RESULT_CALLING, false)
				triggerServerEvent("callStart", root, player, false)
			elseif sender.referenz == "group" then
				Phone:getSingleton():getAppByClass(AppCall):openInCall("group", sender.name, CALL_RESULT_CALLING, false)
				triggerServerEvent("callStartSpecial", root, sender.number)
			elseif sender.referenz == "faction" then
				Phone:getSingleton():getAppByClass(AppCall):openInCall("faction", sender.name, CALL_RESULT_CALLING, false)
				triggerServerEvent("callStartSpecial", root, sender.number)
			elseif sender.referenz == "company" then
				Phone:getSingleton():getAppByClass(AppCall):openInCall("company", sender.name, CALL_RESULT_CALLING, false)
				triggerServerEvent("callStartSpecial", root, sender.number)
			end
		else
			WarningBox:new("Dein Handy ist ausgeschaltet!")
		end
	end

	currentAd = ShortMessage:new(("%s"):format(text), ("Werbung von %s"):format(sender.name), ColorTable[color], AD_DURATIONS[duration]*1000, callSender)
end)

function AppSanNews:Event_receiveFuelPrices(infoTbl)
	self.m_FuelPriceGrid:clear()
	for name, info in pairs(infoTbl) do
		if not name:find("Tankstelle") then
			name = name:gsub(name, _("Tankstelle %s", name))
		end
		local priceMult = (info[3] and SERVICE_FUEL_PRICE_MULTIPLICATOR) or (info[4] and EVIL_FUEL_PRICE_MULTIPLICATOR) or 1
		self.m_FuelPriceGrid:addItemNoClick(name, "")
		for type, price in pairs(info[1]) do
			
			local item = self.m_FuelPriceGrid:addItem(FUEL_NAME[type], _("%s$", math.round(price * priceMult, 1)))
			item.onLeftDoubleClick = function()
				GPS:getSingleton():startNavigationTo(Vector3(info[2][1], info[2][2], info[2][3]))
			end
		end
	end
end

addEvent("closeAd", true)
addEventHandler("closeAd", root, function()
	if currentAd then
		delete(currentAd)
	end
end)
