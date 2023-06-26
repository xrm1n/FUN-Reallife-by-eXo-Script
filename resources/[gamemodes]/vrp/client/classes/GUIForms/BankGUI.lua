-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BankGUI.lua
-- *  PURPOSE:     Bank (ATM) GUI class
-- *
-- ****************************************************************************
BankGUI = inherit(GUIForm)
inherit(Singleton, BankGUI)

addRemoteEvents{"bankMoneyBalanceRetrieve", "groupMoneyBalanceRetrieve"}

function BankGUI:constructor(bankAtm)
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 11) 	-- width of the window
	self.m_Height = grid("y", 7.5) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, bankAtm)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Bankautomat", true, true, self)
	self.m_Window:addHelpButton(LexiconPages.BankATM)
	self.m_Window:addTitlebarButton(FontAwesomeSymbols.Bug, function() AtmManager.startHacking(bankAtm) end)

	local tabs = {"Ein/Auszahlen", "Überweisung"}
	if localPlayer:getGroupId() and localPlayer:getGroupId() > 0 then table.insert(tabs, localPlayer:getGroupType() == "Firma" and "Firmenkonto" or "Gang-Konto") end
	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel(tabs)
	self.m_TabPanel:updateGrid()

	self.m_PlayerBalanceLabel = GUIGridLabel:new(1, 1, 8, 1, "Kontostand: -", self.m_Tabs[1]):setHeader():setColor(Color.Accent)
	self.m_PlayerBalanceLabel2 = GUIGridLabel:new(1, 1, 8, 1, "Kontostand: -", self.m_Tabs[2]):setHeader():setColor(Color.Accent)
	self.m_GroupBalanceLabel = GUIGridLabel:new(1, 1, 8, 1, "Kontostand: -", self.m_Tabs[3]):setHeader():setColor(Color.Accent)

	-- Ein/Auszahlen
	GUIGridLabel:new(1, 2, 3, 1, "Betrag:", self.m_Tabs[1])
	self.m_PlayerAmountEdit = GUIGridEdit:new(3, 2, 8, 1, self.m_Tabs[1]):setNumeric(true, true)
	local playerDeposit = GUIGridButton:new(1, 3, 5, 1, "Einzahlen", self.m_Tabs[1])
	local playerWithdraw = GUIGridButton:new(6, 3, 5, 1, "Auszahlen", self.m_Tabs[1])

	playerDeposit.onLeftClick = bind(BankGUI.balanceChange, self, self.m_PlayerAmountEdit, "bankDeposit")
	playerWithdraw.onLeftClick = bind(BankGUI.balanceChange, self, self.m_PlayerAmountEdit, "bankWithdraw")

	-- Überweisung
	GUIGridLabel:new(1, 2, 4, 1, "Empfänger:", self.m_Tabs[2])
	GUIGridLabel:new(1, 3, 4, 1, " oder spenden an:", self.m_Tabs[2]):setFontSize(.92)
	GUIGridLabel:new(1, 4, 4, 1, "Grund:", self.m_Tabs[2])
	GUIGridLabel:new(1, 5, 4, 1, "Betrag:", self.m_Tabs[2])

	self.m_TransferToEdit = GUIGridEdit:new(4, 2, 7, 1, self.m_Tabs[2])
	self.m_TransferPurposeEdit = GUIGridEdit:new(4, 4, 7, 1, self.m_Tabs[2])
	self.m_TransferPurposeEdit:setMaxLength(20)
	self.m_TransferAmountEdit = GUIGridEdit:new(6, 5, 5, 1, self.m_Tabs[2]):setNumeric(true, true)

	local transferButton = GUIGridButton:new(1, 6, 10, 1, "Überweisen", self.m_Tabs[2])
	transferButton.onLeftClick = bind(BankGUI.TransferButton_Click, self)

	local donate = {}
	donate["San News"] = GUIGridButton:new(4, 3, 3, 1, "San News", self.m_Tabs[2]):setBackgroundColor(Color.Orange)
	donate["eXo Event-Team"] = GUIGridButton:new(7, 3, 4, 1, "eXo Event-Team", self.m_Tabs[2]):setBackgroundColor(Color.Green)
	for index, btn in pairs(donate) do btn.onLeftClick = function() self.m_TransferToEdit:setText(index) end end

	-- Gruppen Ein/Auszahlen
	if self.m_Tabs[3] then
		GUIGridLabel:new(1, 2, 3, 1, "Betrag:", self.m_Tabs[3])
		self.m_GroupAmountEdit = GUIGridEdit:new(3, 2, 8, 1, self.m_Tabs[3]):setNumeric(true, true)

		local groupDeposit = GUIGridButton:new(1, 3, 5, 1, "Einzahlen", self.m_Tabs[3])
		local groupWithdraw = GUIGridButton:new(6, 3, 5, 1, "Auszahlen", self.m_Tabs[3])
		groupDeposit.onLeftClick = bind(BankGUI.balanceChange, self, self.m_GroupAmountEdit, "groupDeposit")
		groupWithdraw.onLeftClick = bind(BankGUI.balanceChange, self, self.m_GroupAmountEdit, "groupWithdraw")
	end

	addEventHandler("bankMoneyBalanceRetrieve", root, bind(BankGUI.Event_OnMoneyReceive, self))
	addEventHandler("groupMoneyBalanceRetrieve", root, bind(BankGUI.Event_OnMoneyReceive, self))
end

function BankGUI:onShow()
	triggerServerEvent("bankMoneyBalanceRequest", root)

	if self.m_Tabs[3] then
		triggerServerEvent("groupRequestMoney", localPlayer)
	end
end

function BankGUI:Event_OnMoneyReceive(amount)
	local moneyString = ("Kontostand: %s"):format(toMoneyString(amount))
	if eventName == "bankMoneyBalanceRetrieve" then
		self.m_PlayerBalanceLabel:setText(moneyString)
		self.m_PlayerBalanceLabel2:setText(moneyString)
	elseif eventName == "groupMoneyBalanceRetrieve" then
		self.m_GroupBalanceLabel:setText(moneyString)
	end
end

function BankGUI:balanceChange(edit, event)
	local amount = edit:getText(true)
	if amount and amount > 0 then
		triggerServerEvent(event, root, amount)
		self.m_PlayerAmountEdit:setText(0)
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function BankGUI:TransferButton_Click()
	local amount = self.m_TransferAmountEdit:getText(true)
	local toCharName = self.m_TransferToEdit:getText()
	local purpose = self.m_TransferPurposeEdit:getText()
	if amount and amount > 0 then
		triggerServerEvent("bankTransfer", root, toCharName, amount, purpose)
		self.m_TransferAmountEdit:setText("0")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end
