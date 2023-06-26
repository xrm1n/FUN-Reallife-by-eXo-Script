-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppNotes.lua
-- *  PURPOSE:     A nicer notes app vong nicigkeit her
-- *
-- ****************************************************************************
AppSkribble = inherit(PhoneApp)
addRemoteEvents{"skribbleReceiveLobbys"}

function AppSkribble:constructor()
	PhoneApp.constructor(self, "Skribble", "IconScribble.png")
end

function AppSkribble:onOpen(form)
	local tabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)

	local infoTab = tabPanel:addTab("Info", FontAwesomeSymbols.Info)
	local lobbyTab = tabPanel:addTab("Lobbys", FontAwesomeSymbols.List)
	local createTab = tabPanel:addTab("Erstellen", FontAwesomeSymbols.Plus)

	-- infoTab
	GUILabel:new(10, 10, form.m_Width-20, 50, _"Skribble", infoTab)
	GUILabel:new(10, 60, form.m_Width-20, 30, "Skribble ist ein Mehrspieler mal und rate Spiel. Während ein Spieler ein Wort malt, müssen andere das Wort erraten um Punkte zu bekommen.\nDer Spieler mit den meisten Punkte am Ende des Spiels gewinnt!", infoTab)

	-- lobbyTab
	GUILabel:new(10, 10, form.m_Width-20, 50, _"Lobbys", lobbyTab)
	self.m_LobbyGrid = GUIGridList:new(10, 60, form.m_Width-20, form.m_Height-120, lobbyTab)
	self.m_LobbyGrid:addColumn(_"Name", .7)
	self.m_LobbyGrid:addColumn(_"S", .1)
	self.m_LobbyGrid:addColumn(_"R", .25)

	local refreshButton = GUIButton:new(form.m_Width-40, 20, 30, 30, FontAwesomeSymbols.Refresh, lobbyTab):setFont(FontAwesome(25)):setFontSize(1):setBarEnabled(false):setBackgroundColor(Color.Primary)
	refreshButton.onLeftClick =
		function()
			triggerServerEvent("skribbleRequestLobbys", localPlayer)
		end

	local infoButton = GUIButton:new(form.m_Width-80, 20, 30, 30, FontAwesomeSymbols.Question, lobbyTab):setFont(FontAwesome(25)):setFontSize(1):setBarEnabled(false):setBackgroundColor(Color.Primary)
	infoButton:setTooltip("  Weiß = Öffentliche Lobby\n  Orange = Private Lobby\n  S = Spieler\n  R = Runden\n  Doppelklick zum beitreten", "bottom", true)

	-- createTab
	GUILabel:new(10, 10, form.m_Width-20, 50, _"Lobby erstellen", createTab)

	GUILabel:new(10, 60, form.m_Width-20, 30, "Name:", createTab)
	GUILabel:new(10, 130, form.m_Width-20, 30, "Passwort:", createTab)
	GUILabel:new(10, 200, form.m_Width-20, 30, "Runden:", createTab)

	self.m_Name = GUIEdit:new(10, 85, form.m_Width-20, 30, createTab):setText(("%s's Lobby"):format(localPlayer:getName()))
	self.m_Password = GUIEdit:new(10, 155, form.m_Width-20, 30, createTab):setMasked():setTooltip("Leer lassen für eine öffentliche Lobby!", "bottom")
	self.m_Rounds = GUIChanger:new(10, 225, form.m_Width-20, 30, createTab)
	for i = 3, 10 do
		self.m_Rounds:addItem(i)
	end

	GUIButton:new(10, form.m_Height-90, form.m_Width-20, 30, "Erstellen", createTab).onLeftClick =
		function()
			if self.m_Name:getText() and self.m_Name:getText() ~= "" then
				triggerServerEvent("skribbleCreateLobby", localPlayer, self.m_Name:getText(), self.m_Password:getText(), self.m_Rounds:getSelectedItem())
			end
		end

	self.m_ReceiveLobbys = bind(AppSkribble.receiveLobbys, self)
	addEventHandler("skribbleReceiveLobbys", root, self.m_ReceiveLobbys)

	triggerServerEvent("skribbleRequestLobbys", localPlayer)
end

function AppSkribble:onClose()
	removeEventHandler("skribbleReceiveLobbys", root, self.m_ReceiveLobbys)
end

function AppSkribble:receiveLobbys(lobbys)
	self.m_LobbyGrid:clear()

	for id, lobby in pairs(lobbys) do
		local item = self.m_LobbyGrid:addItem(lobby.name, lobby.players, ("%s/%s"):format(lobby.currentRound, lobby.rounds))
		item.onLeftDoubleClick =
			function()
				if lobby.password == "" then
					triggerServerEvent("skribbleJoinLobby", localPlayer, id)
				else
					InputBox:new(_"Passwort eingeben", _"Dies ist eine private Lobby, bitte gib das Passwort ein:",
						function(input)
							if input == lobby.password then
								triggerServerEvent("skribbleJoinLobby", localPlayer, id)
								return
							end

							ErrorBox:new(_"Falsches Passwort!")
						end
					)
				end
			end

		if lobby.password ~= "" then
			item:setColor(Color.Orange)
		end
	end
end
