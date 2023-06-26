-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CompanyGUI.lua
-- *  PURPOSE:     Company Menu GUI class
-- *
-- ****************************************************************************
CompanyGUI = inherit(GUIForm)
inherit(Singleton, CompanyGUI)

function CompanyGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Accent):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	self.m_LeaderTab = false
	self.m_LogTab = false

	-- Tab: Allgemein
	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	self.m_tabAllgemein = tabAllgemein
	self.m_CompanyNameLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.96, self.m_Height*0.10, "", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.12, self.m_Width*0.25, self.m_Height*0.06, _"Rang:", tabAllgemein)
	self.m_CompanyRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, "", tabAllgemein)
--	self.m_CompanyQuitButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Fraktion verlassen", tabAllgemein):setBackgroundColor(Color.Red)::setBarEnabled(true)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.1, _"Kasse:", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, _"Inhalt:", tabAllgemein)
	self.m_CompanyMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, "", tabAllgemein)
	--self.m_CompanyMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.27, self.m_Height*0.07, tabAllgemein):setCaption(_"Betrag")
	--self.m_CompanyMoneyDepositButton = GUIButton:new(self.m_Width*0.3, self.m_Height*0.39, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", tabAllgemein):setBarEnabled(true)
	--self.m_CompanyMoneyWithdrawButton = GUIButton:new(self.m_Width*0.56, self.m_Height*0.39, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", tabAllgemein):setBarEnabled(true)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.25, self.m_Height*0.1, _"Funktionen:", tabAllgemein)
	self.m_CompanyRespawnVehicleButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.3, self.m_Height*0.07, _"Fahrzeuge respawnen", tabAllgemein):setBarEnabled(true):setTooltip("Linksklick für sofortigen Respawn \nRechtsklick für angekündigten Respawn", "button", true)
	self.m_CompanyRespawnVehicleButton.onLeftClick = bind(self.CompanyRespawnVehicles, self, true)
	self.m_CompanyRespawnVehicleButton.onRightClick = bind(self.CompanyRespawnVehicles, self, false)

	if localPlayer:getCompany():getId() == 3 then -- San News
		self.m_SanNewsToggleMsg = GUIButton:new(self.m_Width*0.02, self.m_Height*0.68, self.m_Width*0.3, self.m_Height*0.07, _"/sannews de/aktivieren", tabAllgemein):setBarEnabled(true)
		self.m_SanNewsToggleMsg.onLeftClick = bind(self.SanNewsToggleMessage, self)

		self.m_SanNewsStartStreetrace = GUIButton:new(self.m_Width*0.02, self.m_Height*0.76, self.m_Width*0.3, self.m_Height*0.07, _"Straßenrennen starten", tabAllgemein):setBarEnabled(true)
		self.m_SanNewsStartStreetrace.onLeftClick = function() triggerServerEvent("sanNewsStartStreetrace", root) end
		self.m_SanNewsStartStreetrace:setEnabled(false)

		self.m_SanNewsAddBlip = GUIButton:new(self.m_Width*0.02, self.m_Height*0.84, self.m_Width*0.3, self.m_Height*0.07, _"Blip hinzufügen", tabAllgemein):setBarEnabled(true)
		self.m_SanNewsAddBlip:setEnabled(false)
		self.m_SanNewsAddBlip.onLeftClick =
		function()
			self:hide()
			CustomF11Map:getSingleton():setCustomClickCallback(
				function(posX, posY)
					InputBox:new(_"Blip Beschreibung", _"Gib einen Namen für den Blip ein, der auf der F11 Karte angezeigt wird:",
						function(text)
							triggerServerEvent("sanNewsAddBlip", localPlayer, posX, posY, text)
						end
					)
					return true
				end
			)
		end

		self.m_SanNewsDeleteBlips = GUIButton:new(self.m_Width*0.33, self.m_Height*0.84, self.m_Height*0.07, self.m_Height*0.07, FontAwesomeSymbols.Trash, tabAllgemein):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false):setBackgroundColor(Color.Red)
		self.m_SanNewsDeleteBlips.onLeftClick = function() triggerServerEvent("sanNewsDeleteBlips", localPlayer) end
		self.m_SanNewsDeleteBlips:setTooltip("Alle Blips löschen")
		self.m_SanNewsDeleteBlips:setEnabled(false)
	end

	self.m_BindButton = GUIButton:new(self.m_Width*0.36, self.m_Height*0.6, self.m_Width*0.3, self.m_Height*0.07, _"Binds verwalten", tabAllgemein):setBarEnabled(true)
	self.m_BindButton.onLeftClick = function()
	if self.m_BindManageGUI then delete(self.m_BindManageGUI) end
		self:close()
		self.m_BindManageGUI = BindManageGUI:new("company")
		self.m_BindManageGUI:addBackButton(function() CompanyGUI:getSingleton():show() end)
	end

	self.m_SkinChangeButton = GUIButton:new(self.m_Width*0.7, self.m_Height*0.6, self.m_Width*0.28, self.m_Height*0.07, _"Kleidung wechseln", tabAllgemein):setBarEnabled(true)
	self.m_SkinChangeButton.onLeftClick = function()
		self:close()
		triggerServerEvent("companyRequestSkinSelection", localPlayer)
	end

	local tabMitglieder = self.m_TabPanel:addTab(_"Mitglieder")
	self.m_tabMitglieder = tabMitglieder

	self.m_CompanyPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.6, self.m_Height*0.8, tabMitglieder)
	self.m_CompanyPlayersGrid:addColumn(_"", 0.06)
	self.m_CompanyPlayersGrid:addColumn(_"Spieler", 0.44)
	self.m_CompanyPlayersGrid:addColumn(_"Rang", 0.18)
	self.m_CompanyPlayersGrid:addColumn(_"Aktivität", 0.27)
	self.m_CompanyPlayersGrid:setSortable{"Spieler", "Rang", "Aktivität"}
	self.m_CompanyPlayersGrid:setSortColumn(_"Rang", "down")

	self.m_CompanyAddPlayerButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", tabMitglieder):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_CompanyRemovePlayerButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.15, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", tabMitglieder):setBackgroundColor(Color.Red):setBarEnabled(true)
	self.m_CompanyRankUpButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.25, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", tabMitglieder):setBarEnabled(true)
	self.m_CompanyRankDownButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.35, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", tabMitglieder):setBarEnabled(true)
	self.m_CompanyToggleLoanButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.45, self.m_Width*0.3, self.m_Height*0.07, _"Gehalt deaktivieren", tabMitglieder):setBarEnabled(true)
	self.m_CompanyPlayerFileButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.55, self.m_Width*0.3, self.m_Height*0.07, _"Spielerakten", self.m_tabMitglieder):setBarEnabled(true)
	self.m_CompanyForumSyncButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.65, self.m_Width*0.3, self.m_Height*0.07, _"Foren-Gruppen", self.m_tabMitglieder):setBarEnabled(true)
	self.m_CompanyPlayerPermissionsButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.75, self.m_Width*0.3, self.m_Height*0.07, _"Rechte bearbeiten", self.m_tabMitglieder):setBarEnabled(true)
	self.m_CompanyAddPlayerButton:setEnabled(false)
	self.m_CompanyRemovePlayerButton:setEnabled(false)
	self.m_CompanyRankUpButton:setEnabled(false)
	self.m_CompanyRankDownButton:setEnabled(false)
	self.m_CompanyToggleLoanButton:setEnabled(false)
	self.m_CompanyPlayerFileButton:setEnabled(false)
	self.m_CompanyForumSyncButton:setVisible(false)
	self.m_CompanyPlayerPermissionsButton:setEnabled(false)

	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
--	self.m_CompanyQuitButton.onLeftClick = bind(self.CompanyQuitButton_Click, self)
	--self.m_CompanyMoneyDepositButton.onLeftClick = bind(self.CompanyMoneyDepositButton_Click, self)
	--self.m_CompanyMoneyWithdrawButton.onLeftClick = bind(self.CompanyMoneyWithdrawButton_Click, self)
	self.m_CompanyAddPlayerButton.onLeftClick = bind(self.CompanyAddPlayerButton_Click, self)
	self.m_CompanyRemovePlayerButton.onLeftClick = bind(self.CompanyRemovePlayerButton_Click, self)
	self.m_CompanyRankUpButton.onLeftClick = bind(self.CompanyRankUpButton_Click, self)
	self.m_CompanyRankDownButton.onLeftClick = bind(self.CompanyRankDownButton_Click, self)
	self.m_CompanyToggleLoanButton.onLeftClick = bind(self.CompanyToggleLoanButton_Click, self)
	self.m_CompanyPlayerFileButton.onLeftClick = bind(self.CompanyPlayerFileButton_Click, self)
	self.m_CompanyForumSyncButton.onLeftClick = bind(self.CompanyForumSyncButton_Click, self)
	self.m_CompanyPlayerPermissionsButton.onLeftClick = bind(self.companyPlayerPermissionsButton_Click, self)

	self.m_TabLogs = self.m_TabPanel:addTab(_"Logs")

	addRemoteEvents{"companyRetrieveInfo"}
	addEventHandler("companyRetrieveInfo", root, bind(self.Event_companyRetrieveInfo, self))
end

function CompanyGUI:destructor()
	GUIForm.destructor(self)
end

function CompanyGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("companyRequestInfo", root)
end

function CompanyGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function CompanyGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabLogs.TabIndex then
		local url = (INGAME_WEB_PATH .. "/ingame/logs/groupLogs.php?groupType=%s&groupId=%d"):format("company", self.m_Id)
		if not self.m_LogGUI then
			self.m_LogGUI = LogGUI:new(self.m_TabLogs, url)
		else
			self.m_LogGUI:updateLog()
		end
	else
		triggerServerEvent("companyRequestInfo", root)
	end
end

function CompanyGUI:addLeaderTab()
	if self.m_LeaderTab == false then
		local tabLeader = self.m_TabPanel:addTab(_"Leader")
		self.m_CompanyRangGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.6, tabLeader)
		self.m_CompanyRangGrid:addColumn(_"Rang", 0.2)
		self.m_CompanyRangGrid:addColumn(_"Name", 0.8)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.06, _"Ausgewählter Rang:", tabLeader):setFont(VRPFont(30)):setColor(Color.Accent)
		self.m_LeaderRankName = GUILabel:new(self.m_Width*0.45, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, "", tabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Gehalt: (in $)", tabLeader):setFont(VRPFont(30)):setColor(Color.Accent)
		self.m_LeaderLoan = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.28, self.m_Width*0.2, self.m_Height*0.06, tabLeader):setNumeric(true, true)
		self.m_LeaderLoan:setVisible(false)

		self.m_SaveRank = GUIButton:new(self.m_Width*0.02, self.m_Height*0.66, self.m_Width*0.4, self.m_Height*0.07, _"Rang speichern", tabLeader):setBarEnabled(true)
		self.m_SaveRank.onLeftClick = bind(self.saveRank, self)
		self.m_SaveRank:setEnabled(false)

		self.m_ChangePermissions = GUIButton:new(self.m_Width*0.02, self.m_Height*0.845, self.m_Width*0.4, self.m_Height*0.07, _"Rechteverwaltung", tabLeader):setBarEnabled(true)
		self.m_ChangePermissions.onLeftClick = bind(self.openPermissionsGUI, self)
		self.m_ChangePermissions:setEnabled(false)


		self:refreshLeaderTab()

		for rank,name in pairs(self.m_RankNames) do
			local item = self.m_CompanyRangGrid:addItem(rank, name)
			item.Id = rank
			item.onLeftClick = function()
				self.m_SelectedRank = rank
				self:onSelectRank(name,rank)
			end

			if rank == 1 then
				self.m_CompanyRangGrid:onInternalSelectItem(item)
				item.onLeftClick()
			end
		end

		self.m_LeaderTab = true
	else
		self:refreshLeaderTab()
	end
end

function CompanyGUI:refreshLeaderTab()
	self.m_LeaderLoan:setVisible(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "editLoan"))
	self.m_CompanyPlayerFileButton:setEnabled(localPlayer:getPublicSync("CompanyRank") >= CompanyRank.Manager)
	self.m_ChangePermissions:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "changePermissions"))
end

function CompanyGUI:saveRank()
	if self.m_SelectedRank then
		triggerServerEvent("companySaveRank",localPlayer,self.m_SelectedRank,self.m_LeaderLoan:getText())
	end
end

function CompanyGUI:onSelectRank(name,rank)
	self.m_LeaderRankName:setText(name.." - "..rank)
	self.m_LeaderLoan:setText(tostring(self.m_RankLoans[tostring(rank)]))
	self.m_SaveRank:setEnabled(true)
end

function CompanyGUI:Event_companyRetrieveInfo(id, name, rank, money, players, rankNames, rankLoans)
	if id then
		if id > 0 then
			self.m_Id = id
			local x, y = self.m_CompanyNameLabel:getPosition()
			self.m_RankNames = rankNames
			self.m_CompanyNameLabel:setText(name)
			self.m_CompanyRankLabel:setText(tostring(rank).." - "..rankNames[rank])
			self.m_CompanyMoneyLabel:setText(tostring(money).."$")

			self.m_CompanyPlayersGrid:clear()
			for playerId, info in pairs(players) do
				local activitySymbol = info.loanEnabled == 1 and FontAwesomeSymbols.Calender_Check or FontAwesomeSymbols.Calender_Time
				local item = self.m_CompanyPlayersGrid:addItem(activitySymbol, info.name, info.rank, tostring(info.activity).." h")
				local color = (getPlayerFromName(info.name) and getPlayerFromName(info.name):getPublicSync("Company:Duty") and Color.Orange) or (getPlayerFromName(info.name) and Color.Accent) or Color.White
				item:setColumnFont(1, FontAwesome(20), 1):setColumnColor(1, info.loanEnabled == 1 and Color.Green or Color.Red)
				item:setColumnColor(2, color)
				item.Id = playerId
				item.Rank = info.rank

				item.onLeftClick =
					function()
						self.m_CompanyToggleLoanButton:setText(("Gehalt %saktivieren"):format(info.loanEnabled == 1 and "de" or ""))
					end
			end

			if rank >= CompanyRank.Manager or PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "editLoan") then
				self.m_RankLoans = rankLoans
				self:addLeaderTab()
			end

			self.m_CompanyAddPlayerButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "invite"))
			self.m_CompanyRemovePlayerButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "uninvite"))
			self.m_CompanyRankUpButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "changeRank"))
			self.m_CompanyRankDownButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "changeRank"))
			self.m_CompanyToggleLoanButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "toggleLoan"))
			self.m_CompanyPlayerPermissionsButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "changePermissions"))
			if localPlayer:getCompany():getId() == 3 then 
				self.m_SanNewsAddBlip:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "addBlip"))
				self.m_SanNewsDeleteBlips:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "addBlip"))
				self.m_SanNewsStartStreetrace:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "startStreetRace"))
			end
		end
	end
end

function CompanyGUI:adjustCompanyTab(rank)
	local isInCompany = rank ~= false

	for k, element in ipairs(self.m_tabAllgemein:getChildren()) do
		if element ~= self.m_CompanyCreateButton then
			element:setVisible(isInCompany)
		end
	end

	if rank then
		if rank ~= CompanyRank.Leader then
			self.m_CompanyDeleteButton:setVisible(false)
		end
		if rank < CompanyRank.Manager then
			self.m_CompanyMoneyWithdrawButton:setVisible(false)
			self.m_CompanyAddPlayerButton:setVisible(false)
			self.m_CompanyRemovePlayerButton:setVisible(false)
			self.m_CompanyRankUpButton:setVisible(false)
			self.m_CompanyRankDownButton:setVisible(false)
		end
	end
end

function CompanyGUI:CompanyCreateButton_Click()
	CompanyCreationGUI:new()
end

function CompanyGUI:CompanyMoneyDepositButton_Click()
	local amount = tonumber(self.m_CompanyMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("companyDeposit", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function CompanyGUI:CompanyMoneyWithdrawButton_Click()
	local amount = tonumber(self.m_CompanyMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("companyWithdraw", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function CompanyGUI:CompanyAddPlayerButton_Click()
	InviteGUI:new(
		function(player)
			triggerServerEvent("companyAddPlayer", root, player)
		end,"company"
	)
end

function CompanyGUI:CompanyPlayerFileButton_Click()
	self:close()
	HistoryPlayerGUI:new(CompanyGUI)
end

function CompanyGUI:CompanyForumSyncButton_Click()
	-- triggerServerEvent("companyForumSync", root)
	self:close()
	ForumPermissionsGUI:new("company", localPlayer:getCompany().m_Id)
end

function CompanyGUI:CompanyRemovePlayerButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then

		HistoryUninviteGUI:new(function(internal, external)
			triggerServerEvent("companyDeleteMember", root, selectedItem.Id, internal, external)
		end)
	else
		ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online")
	end
end

function CompanyGUI:CompanyRankUpButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		if selectedItem.Rank + 1 == CompanyRank.Leader and localPlayer:getPublicSync("CompanyRank") == CompanyRank.Leader then
			QuestionBox:new("Bist du sicher, dass du den Spieler befördern und deinen Leaderposten abgeben möchtest?", 
				function()
					triggerServerEvent("companyRankUp", root, selectedItem.Id, true)
				end,
				function()
					return
				end, false, false
			)
		else
			triggerServerEvent("companyRankUp", root, selectedItem.Id, false)
		end
	end
end

function CompanyGUI:CompanyRankDownButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("companyRankDown", root, selectedItem.Id)
	end
end

function CompanyGUI:CompanyToggleLoanButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("companyToggleLoan", root, selectedItem.Id)
	end
end

function CompanyGUI:CompanyRespawnVehicles(instant)
	triggerServerEvent("companyRespawnVehicles", root, instant)
end

function CompanyGUI:SanNewsToggleMessage()
	triggerServerEvent("sanNewsToggleMessage", root)
end

function CompanyGUI:openPermissionsGUI()
	RankPermissionsGUI:new("permission", "company")
end

function CompanyGUI:companyPlayerPermissionsButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then

		self.m_PermissionsManagmentGUI = GUIButtonMenu:new(_("Rechteverwaltung"))
		if PermissionsManager:getSingleton():hasPlayerPermissionsTo("company", "changePermissions") then
			self.m_PermissionsManagmentGUI:addItem(_"Rechte bearbeiten", Color.Accent,
				function()
					PlayerPermissionsGUI:new("permission", selectedItem.Rank, "company", selectedItem.Id)
				end
			)
		end
	end
end