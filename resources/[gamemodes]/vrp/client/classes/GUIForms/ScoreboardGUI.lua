-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ScoreboardGUI.lua
-- *  PURPOSE:     Scoreboard class
-- *
-- ****************************************************************************
ScoreboardGUI = inherit(GUIForm)
inherit(Singleton, ScoreboardGUI)

function ScoreboardGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-(screenWidth*0.65/2), screenHeight/2-screenHeight*0.3, screenWidth*0.65, screenHeight*0.6, false, true)

	self.m_Rect = GUIRectangle:new(0, self.m_Width*0.06 , self.m_Width, self.m_Height, tocolor(0, 0, 0, 200), self)
	self.m_Logo = GUIImage:new(self.m_Width-self.m_Width*0.18, self.m_Height*0.83, self.m_Width*0.180, self.m_Width*0.078, "files/images/LogoNoFont.png", self)

	self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.96, self.m_Height*0.62, self.m_Rect)
	self.m_Grid:setFont(VRPFont(24))
	self.m_Grid:setItemHeight(24)
	self.m_Grid:setColor(Color.Clear)
	self.m_Grid:setColumnBackgroundColor(Color.Clear)
	self.m_Grid:addColumn(_"VIP", 0.05)
	self.m_Grid:addColumn(_"Name", 0.2)
	self.m_Grid:addColumn(_"Fraktion", 0.1)
	self.m_Grid:addColumn("", 0.04)
	self.m_Grid:addColumn(_"Unternehmen", 0.15)
	self.m_Grid:addColumn(_"Gang/Firma", 0.27)
	self.m_Grid:addColumn(_"Spielzeit", 0.08)
	self.m_Grid:addColumn(_"Ping", 0.11)
	self.m_Grid:setSortable{"VIP", "Name", "Fraktion", "Unternehmen", "Gang/Firma", "Spielzeit"} --We can't sort Ping (Ping can be a number and also a string)
	--self.m_Grid:setSortColumn(_"Fraktion")

	self.m_Line = GUIRectangle:new(0, self.m_Height*0.65, self.m_Width, self.m_Height*0.05, Color.Accent, self.m_Rect)
	self.m_PlayerCount = GUILabel:new(self.m_Width*0.05, self.m_Height*0.65, self.m_Width/2, self.m_Height*0.05, "", self.m_Rect)
	self.m_PlayerCount:setColor(tocolor(0, 0, 0, 200)):setFont(VRPFont(self.m_Height*0.05))
	self.m_Ping = GUILabel:new(self.m_Width/2, self.m_Height*0.65, self.m_Width/2-self.m_Width*0.05, self.m_Height*0.05, "", self.m_Rect)
	self.m_Ping:setColor(tocolor(0, 0, 0, 200)):setFont(VRPFont(self.m_Height*0.05)):setAlignX("right")

	self.m_OldWeaponSlot = localPlayer:getWeaponSlot()

	self.m_ScrollBind = bind(self.onScoreBoardScroll, self)
end

function ScoreboardGUI:onShow()
	toggleControl("next_weapon", false)
	toggleControl("previous_weapon", false)
	toggleControl("action", false)
	setPedControlState("action", false)
	self.m_OldWeaponSlot = localPlayer:getWeaponSlot()
	self:refresh()
	self.m_Timer = setTimer(bind(self.refresh, self), 15000, 0)
	self.m_Showing = true
	bindKey("mouse_wheel_up", "down", self.m_ScrollBind)
	bindKey("mouse_wheel_down", "down", self.m_ScrollBind)

	RadioGUI:getSingleton():setControlEnabled(false)
end

function ScoreboardGUI:onHide()
	if self.m_Timer and isTimer(self.m_Timer) then killTimer(self.m_Timer) end
	if not NoDm:getSingleton().m_NoDm then
		toggleControl("next_weapon", true)
		toggleControl("previous_weapon", true)
		toggleControl("action", true)
	end
	unbindKey("mouse_wheel_up", "down", self.m_ScrollBind)
	unbindKey("mouse_wheel_down", "down", self.m_ScrollBind)
	RadioGUI:getSingleton():setControlEnabled(true)
	self.m_Showing = false
end

function ScoreboardGUI:onScoreBoardScroll(key)
	if key == "mouse_wheel_up" then
		self.m_Grid.m_ScrollArea:onInternalMouseWheelUp()
	elseif key == "mouse_wheel_down" then
		self.m_Grid.m_ScrollArea:onInternalMouseWheelDown()
	end
end

function ScoreboardGUI:refresh()
	local scrollPosX, scrollPosY = self.m_Grid.m_ScrollArea:getScrollPosition()
	local scrollAreaDocumentSize_old = self.m_Grid.m_ScrollArea.m_DocumentHeight
	local scrollAreaHeight = self.m_Grid.m_ScrollArea.m_Height

	self.m_Grid:clear()
	self.m_Players = {}
	self.m_CompanyCount = {}
	self.m_CompanyAFKCount = {}
	self.m_FactionCount = {}
	self.m_FactionAFKCount = {}

	for k, player in pairs(getElementsByType("player")) do
		local factionId = player:getFaction() and player:getFaction():getId() or 0
		if factionId > 0 and factionId < 4 then factionId = 1 end
		local companyId = player:getCompany() and player:getCompany():getId() or 0
		table.insert(self.m_Players, {player, factionId})

		if not self.m_FactionCount[factionId] then self.m_FactionCount[factionId] = 0 end
		if not self.m_FactionAFKCount[factionId] then self.m_FactionAFKCount[factionId] = 0 end

		self.m_FactionCount[factionId] = self.m_FactionCount[factionId] + 1
		if player:isAFK() then
			self.m_FactionAFKCount[factionId] = self.m_FactionAFKCount[factionId] + 1
		end

		if companyId ~= 0 then
			if not self.m_CompanyCount[companyId] then self.m_CompanyCount[companyId] = 0 end
			if not self.m_CompanyAFKCount[companyId] then self.m_CompanyAFKCount[companyId] = 0 end

			self.m_CompanyCount[companyId] = self.m_CompanyCount[companyId] + 1
			if player:isAFK() then
				self.m_CompanyAFKCount[companyId] = self.m_CompanyAFKCount[companyId] + 1
			end
		end
	end

	if localPlayer:getFaction() and localPlayer:getFaction():isRescueFaction() then
		self.m_Grid:setColumnText(4, _"FMS")
	else
		self.m_Grid:setColumnText(4, "")
	end

	table.sort(self.m_Players, function (a, b) return (a[2] < b[2]) end)
	self:insertPlayers()

	local scrollAreaDocumentSize_new = self.m_Grid.m_ScrollArea.m_DocumentHeight
	if scrollPosY ~= 0 and scrollAreaDocumentSize_old > scrollAreaDocumentSize_new and math.abs(scrollPosY) > scrollAreaDocumentSize_new - scrollAreaHeight then
		scrollPosY = (scrollPosY / (scrollAreaDocumentSize_old - scrollAreaHeight) * scrollAreaDocumentSize_new) + scrollAreaHeight
		if math.abs(scrollPosY) < scrollAreaHeight or scrollPosY > 0 then
			scrollPosY = 0
		end
	end

	self.m_Grid.m_ScrollArea:setScrollPosition(scrollPosX, scrollPosY)

	if not self.m_PlayerCountLabels then
		self.m_PlayerCountLabels = {}
	end
	self.m_CountRow = 0
	self.m_CountColumn = 0
	self:addPlayerCount("Zivilisten", self.m_FactionCount[0] or 0, self.m_FactionAFKCount[0] or 0, tocolor(255, 255, 255))

	for id, faction in pairs(FactionManager.Map) do
		if id ~= 2 and id ~= 3  then
			local color = faction:getColor()
			self:addPlayerCount((id == 1 and "Staat") or faction:getShortName(), self.m_FactionCount[id] or 0, self.m_FactionAFKCount[id] or 0, tocolor(color.r, color.g, color.b))
		end
	end
	for id, company in ipairs(CompanyManager.Map) do
		self:addPlayerCount(company:getShortName(), self.m_CompanyCount[id] or 0, self.m_CompanyAFKCount[id] or 0)
	end

	self.m_PlayerCount:setText(_("Derzeit sind %d Spieler online", #getElementsByType("player")))
	self.m_Ping:setText(_("eigener Ping: %dms", localPlayer:getPing()))
end

function ScoreboardGUI:addPlayerCount(name, value, valueAFK, color)
	if self.m_CountRow >= 3 then
		self.m_CountRow = 0
		self.m_CountColumn =  self.m_CountColumn+1
	end
	if not self.m_PlayerCountLabels[name] then
		self.m_PlayerCountLabels[name] = GUILabel:new(self.m_Width*0.05 + (self.m_Width/6*self.m_CountColumn), self.m_Height*0.72 + (self.m_Height*0.05*self.m_CountRow), self.m_Width/4, self.m_Height*0.05, "", self.m_Rect)
		if color then
			self.m_PlayerCountLabels[name]:setColor(color)
		end
	end

	if valueAFK ~= 0 then
		self.m_PlayerCountLabels[name]:setText(("%s: %d (%d AFK)"):format(name, value, valueAFK))
	else
		self.m_PlayerCountLabels[name]:setText(("%s: %d"):format(name, value))
	end

	self.m_CountRow = self.m_CountRow + 1
end

function ScoreboardGUI:insertPlayers()
	local gname
	for index, playerTable in ipairs(self.m_Players) do
		local player = playerTable[1]
		local isLoggedIn = not player:getName():find("Gast_")

		local playtime = ("%d:%.2d"):format(math.floor(player:getPlayTime()/60), (player:getPlayTime() - math.floor(player:getPlayTime()/60)*60))

		local ping
		if player:isAFK() then
			ping = "AFK"
		elseif player:isInJail() then
			ping = "Knast"
		else
			ping = player:getPing().."ms"
		end

		gname = player:getGroupName()
		if gname == "" or #gname == 0 then
			gname = "- Keine -"
		end
		
		local item = self.m_Grid:addItem(
			(isLoggedIn and player:isPremium()) and "files/images/Nametag/premium.png" or "files/images/Textures/Other/trans.png",
			(player.getPublicSync and (player:getPublicSync("supportMode") or player:getPublicSync("ticketsupportMode")) and ("[%s] %s"):format(RANKSCOREBOARD[player.getPublicSync and player:getPublicSync("Rank") or 3] or "Support", player:getName())) or player:getName(),
			isLoggedIn and (player:getFaction() and player:getFaction():getId() >= 1 and player:getFaction():getId() <= 3 and "Staat" or (player:getFaction() and player:getFaction():getShortName() or "- Keine -")) or "-",
			isLoggedIn and ((localPlayer:getFaction() and localPlayer:getFaction():isRescueFaction()) and (player:getFaction() and player:getFaction():isRescueFaction() and player:getRadioStatus() or "-")) or "",
			isLoggedIn and (player:getCompany() and player:getCompany():getShortName()  or "- Keins -") or "-",
			isLoggedIn and gname or "-",
			isLoggedIn and playtime or "-",
			ping or " - "
		)
		item:setColumnToImage(1, true, item.m_Height)
		item:setFont(VRPFont(24))

		if player:getFaction() then
			local color = player:getFaction():getColor()
			if player:getFaction():getId() >= 1 and player:getFaction():getId() <= 3 then
				item:setColumnColor(3, tocolor(0, 200, 255))
			else
				item:setColumnColor(3, tocolor(color.r, color.g, color.b))
			end

			if (localPlayer:getFaction() and localPlayer:getFaction():isRescueFaction()) and (player:getFaction() and player:getFaction():isRescueFaction()) then
				if tonumber(player:getRadioStatus()) and FMS_STATUS_COLORS[tonumber(player:getRadioStatus())] then
					local colorFMS = FMS_STATUS_COLORS[tonumber(player:getRadioStatus())]
					item:setColumnColor(4, tocolor(colorFMS[1], colorFMS[2], colorFMS[3]))
				end
			end
		end

		if player.getPublicSync and player:getPublicSync("supportMode") or player:getPublicSync("ticketsupportMode") then 
			item:setColumnColor(2, tocolor(unpack(RANKCOLORS[player.getPublicSync and player:getPublicSync("Rank") or 3])))
		end

		if player:getGroupType() then
			if player:getGroupType() == "Gang" then
				item:setColumnColor(6, Color.Red)
			elseif player:getGroupType() == "Firma" then
				item:setColumnColor(6, Color.Accent)
			end
		end

		if ping == "AFK" then
			item:setColumnColor(8, Color.Red)
		elseif ping == "Knast" then
			item:setColumnColor(8, Color.Yellow)
		end
	end
end
