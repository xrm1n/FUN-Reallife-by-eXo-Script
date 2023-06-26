-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory class
-- *
-- ****************************************************************************

Inventory = inherit(GUIForm)
inherit(Singleton, Inventory)
addRemoteEvents{"loadPlayerInventarClient", "syncInventoryFromServer","forceInventoryRefresh", "closeInventory", "flushInventory"}
Inventory.Color = {
	TabHover  = rgb(50, 200, 255);
	TabNormal = rgb(50, 50, 50);
	ItemsBackground = rgb(50, 50, 50);
	ItemBackground  = rgb(97, 129, 140);
	ItemBackgroundHover = rgb(50, 200, 255);
	ItemBackgroundHoverDelete = rgb(200, 0, 0);
}

Inventory.Tabs = {
	[1] = "Items",
	[2] = "Objekte",
	[3] = "Essen",
	[4] = "Drogen"
}

function Inventory:constructor()
	GUIForm.constructor(self, screenWidth/2 - 330/2, screenHeight/2 - (160+106+80)/2, 330, (80+106+80))
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Inventar", true, false, self)
	self.m_CurrentTab = 1

	-- Upper Area (Tabs)
	local tabArea = GUIElement:new(0, 30, self.m_Width, self.m_Height*(50/self.m_Height), self)
	local tabX, tabY = tabArea:getSize()
	self.m_Rect = GUIRectangle:new(0, 0, tabX, tabY, Inventory.Color.TabHover, tabArea)

	-- Tabs
	self.m_Tabs = {}
	self.m_Tabs[1] = self:addTab("files/images/Inventory/items.png", tabArea)
	self:addItemSlots(21, self.m_Tabs[1])
	self.m_Tabs[2] = self:addTab("files/images/Inventory/items/Objekte.png", tabArea)
	self:addItemSlots(5, self.m_Tabs[2])
	self.m_Tabs[3] = self:addTab("files/images/Inventory/food.png", tabArea)
	self:addItemSlots(6, self.m_Tabs[3])
	self.m_Tabs[4] = self:addTab("files/images/Inventory/drogen.png", tabArea)
	self:addItemSlots(7, self.m_Tabs[4])

	self.m_InfoText1 = GUILabel:new(0, self.m_Height-45, self.m_Width, 20, _"Info: Zum Löschen von Items Control und Linksklick!", self.m_Window):setAlignX("center")
	self.m_InfoText2 = GUILabel:new(0, self.m_Height-25, self.m_Width, 20, "", self.m_Window):setAlignX("center")

	self.m_func1 = bind(self.Event_loadPlayerInventarClient,  self)
	self.m_func2 = bind(self.Event_syncInventoryFromServer,  self)
	self.m_func3 = bind(self.Event_forceInventoryRefresh,  self)
	self.m_func4 = bind(self.hide, self)
	self.m_KeyInputCheck = bind(self.Event_OnRender, self)

	addEventHandler("loadPlayerInventarClient",  root, self.m_func1 )
	addEventHandler("syncInventoryFromServer",  root,  self.m_func2)
	addEventHandler("forceInventoryRefresh",  root, self.m_func3 )
	addEventHandler("closeInventory",  root,  self.m_func4)
	addEventHandler("onClientRender", root, self.m_KeyInputCheck)

	self:hide()
end

function Inventory:Event_OnRender()
	self.m_IsDeleteKeyDown = getKeyState("lctrl")
end

function Inventory:Event_syncInventoryFromServer(bag, items)
	if self.m_Debug then
		outputDebugString("Inventory: Received "..tostring(bag).." and "..tostring(items).."!",0,200,0,200)
	end

	self.m_Bag = bag
	self.m_Items = items
	self:loadItems()
end

function Inventory:Event_loadPlayerInventarClient(slots, itemData)
	if self.m_Debug then
		outputDebugString("Loaded: "..tostring(slots).." and "..tostring(itemData).."!",0,200,0,200)
	end

	self.m_Slots = slots
	self.m_ItemData = itemData
end

function Inventory:Event_forceInventoryRefresh(slots, itemData)
	self:hide()
	self:show()
end

function Inventory:toggle()
	if self.Show then
		self:hide()
	else
		self:show()
	end
end

function Inventory:getItemData()
	return self.m_ItemData
end

function Inventory:getItems()
	return self.m_Items
end

function Inventory:getBagData()
	return self.m_Bag
end

function Inventory:addItem(place, item)
	if self.m_ItemData then
		local tab = self.m_Tabs[self.m_CurrentTab]
		local itemData = self.m_ItemData[item["Objekt"]]
		local slot = tab.m_ItemSlots[place+1]
		if itemData then
			if slot.ItemImage then delete(slot.ItemImage) end
			if slot.LabelBackground then delete(slot.LabelBackground) end
			if slot.ItemLabel then delete(slot.ItemLabel) end
			if slot.ItemWearBackground then delete(slot.ItemWearBackground) end
			if slot.ItemWearProgress then delete(slot.ItemWearProgress) end

			slot.Item = true
			slot.Id = place-1
			slot.Place = place
			slot.ItemName = item["Objekt"]
			slot.Amount = item["Menge"]
			slot.Value = item["Value"]
			slot.WearLevel = item["WearLevel"]

			local amountText = slot.Amount > 1 and slot.Amount or ""
			local textWidth = VRPTextWidth(amountText, 20) + 3

			slot.ItemImage = GUIImage:new(0, 0, slot.m_Width, slot.m_Height, "files/images/Inventory/items/"..itemData["Icon"], slot)

			if slot.WearLevel then
				local progress = slot.WearLevel/itemData["MaxWear"]
				local wearLevelColor = tocolor(255*(1-progress), 255*progress, 0)
				slot.ItemWearBackground = GUIRectangle:new(0, slot.m_Height - 4, slot.m_Width, 4, Color.Background, slot)
				slot.ItemWearProgress = GUIRectangle:new(0, slot.m_Height - 4, slot.m_Width*progress, 4, wearLevelColor, slot)
			end

			if slot.Amount > 1 then
				slot.LabelBackground = GUIRectangle:new(slot.m_Width - textWidth, slot.m_Height-12, textWidth, 12, Color.Background, slot)
			end

			slot.ItemLabel = GUILabel:new(0, slot.m_Height - 12, slot.m_Width, 12, amountText, slot):setAlign("right", "center"):setFont(VRPFont(20)):setFontSize(1):setColor(Color.Orange)
		else
			outputDebugString(("Inventory: Failed to load item-data for Item %s"):format(item["Objekt"] or  "Unknown"))
		end
	end
end

function Inventory:loadItems()
	for slotId, slot in pairs (self.m_Tabs[self.m_CurrentTab].m_ItemSlots) do
		if slot.ItemImage then delete(slot.ItemImage) end
		if slot.LabelBackground then delete(slot.LabelBackground) end
		if slot.ItemLabel then delete(slot.ItemLabel) end
		if slot.ItemWearBackground then delete(slot.ItemWearBackground) end
		if slot.ItemWearProgress then delete(slot.ItemWearProgress) end

		slot.Item = nil
		slot.Id = nil
		slot.Place = nil
		slot.ItemName = nil
		slot.Amount = nil
	end
	if self.m_Bag then
		for place, id in pairs(self.m_Bag[Inventory.Tabs[self.m_CurrentTab]]) do
			self:addItem(place, self.m_Items[id])
		end
	else
		setTimer(function()
			self:loadItems()
		end, 100 ,1)
	end
end

function Inventory:addTab(img, parent)
	local Id = #self.m_Tabs + 1
	local tabX, tabY = parent:getSize()
	local tabButton = GUIElement:new(0 + math.floor(self.m_Width/4)*(Id-1), 0, math.floor(self.m_Width/4), tabY, parent)
	local tabBackground = GUIRectangle:new(0, 0, tabButton.m_Width, tabButton.m_Height, Inventory.Color.TabNormal, tabButton)
	GUIImage:new(tabButton.m_Width*0.225, tabButton.m_Height*0.025, tabButton.m_Width*0.55, tabButton.m_Height*0.95, img, tabButton)
	GUIEmptyRectangle:new(0, 0, tabButton.m_Width+2, tabButton.m_Height+2, 2, Color.White, tabButton)

	tabButton.isTab = true
	tabButton.m_Background = tabBackground
	tabButton.onHover = function ()
		if self.m_CurrentTab ~= Id then
			tabBackground:setColor(Inventory.Color.TabHover)
		end
	end
	tabButton.onUnhover = function ()
		if self.m_CurrentTab ~= Id then
			tabBackground:setColor(Inventory.Color.TabNormal)
		end
	end
	tabButton.onLeftClick = function()
		self:setTab(Id)

		for k, v in ipairs(parent.m_Children) do
			if v.isTab == true then
				v.m_Background:setColor(Inventory.Color.TabNormal)
			end
		end

		tabButton.m_Background:setColor(Inventory.Color.TabHover)
	end

	local itemArea = GUIElement:new(0, self.m_Height*(50/self.m_Height)+30, self.m_Width, self.m_Height - self.m_Height*(50/self.m_Height)-30, self)

	if Id ~= 1 then
		itemArea:setVisible(false)
	else
		self.m_CurrentTab = 1
		tabBackground:setColor(Inventory.Color.TabHover)
	end

	self.m_Tabs[Id] = itemArea
	return itemArea
end

function Inventory:setTab(Id)
	if self.m_CurrentTab then
		self.m_Tabs[self.m_CurrentTab]:setVisible(false)
	end

	self.m_Tabs[Id]:setVisible(true)
	self.m_CurrentTab = Id
	if self.onTabChanged then
		self:onTabChanged(Id)
	end
end

function Inventory:onTabChanged()
	self:loadItems()
end

function Inventory:addItemSlots(count, parent)
	parent.m_ItemSlots = {}
	local x, y = parent:getSize()
	local row = 0
	local id = 0
	for i = 1, count, 1 do
		local i = i - 7*row
		id = #parent.m_ItemSlots+1                               -- y
		parent.m_ItemSlots[id] = GUIRectangle:new(x*0.025 + math.floor(x*0.125)*(i-1) + (x*0.014)*(i-1), x*0.03 + math.floor(x*0.125)*(row) + (x*0.014)*(row), x*0.125, x*0.125, Inventory.Color.ItemBackground, parent)
		self:addItemEvents(parent.m_ItemSlots[id])

		if i == count then break; end
		if i%7 == 0 then row = row + 1 end
	end

	--Calculate new parent size
	--parent:setSize(x, y + (y*0.455)*(row-1))
	--self.m_Window:setSize(x, y + (y*0.455)*(row-1)+200)
	--parent.m_Background:setSize(x, y + (y*0.455)*(row-1))
	--parent.m_BackgroundRound:setSize(x, y + (y*0.455)*(row-1))
end

function Inventory:addItemEvents(item)
	item.onHover = function()
		if not self.m_IsDeleteKeyDown then
			item:setColor(Inventory.Color.ItemBackgroundHover)
			if item.Item then
				local itemName = item.ItemName
				self.m_InfoText1:setText(_("%s - Menge: %s", itemName, tostring(item.Amount)))
				if itemName == "Kleidung" and item.Value and SkinInfo[tonumber(item.Value)] then
					self.m_InfoText2:setText(SkinInfo[tonumber(item.Value)][1])
				else
					self.m_InfoText2:setText(self.m_ItemData[itemName]["Info"])
				end
			end
		else
			item:setColor(Inventory.Color.ItemBackgroundHoverDelete)
		end
	end

	item.onUnhover = function()
		item:setColor(Inventory.Color.ItemBackground)
		self.m_InfoText1:setText(_"Info: Zum Löschen von Items Control und Linksklick!")
		self.m_InfoText2:setText("")
	end

	item.onLeftClick = function()
		if item.Item then
			local itemName = item.ItemName
			local itemDelete = false
			if self.m_ItemData[itemName]["Verbraucht"] == 1 then itemDelete = true end
			if not self.m_IsDeleteKeyDown then
				if localPlayer:getData("isTied") or localPlayer:getPublicSync("cuffed") or localPlayer:getData("Admin:IsFrozen") then return ErrorBox:new(_"Du kannst derzeit nichts benutzen.") end
				triggerServerEvent("onPlayerItemUseServer", localPlayer, item.Id, Inventory.Tabs[self.m_CurrentTab], itemName, item.Place, itemDelete)
			else
				if localPlayer:getData("isTied") or localPlayer:getPublicSync("cuffed") or localPlayer:getData("Admin:IsFrozen") then return ErrorBox:new(_"Du kannst derzeit nichts wegwerfen.") end
				if self.m_InventoryActionPrompt then
					self.m_InventoryActionPrompt:close()
				end
				local bThrowAway = self.m_ItemData[item.ItemName]["Wegwerf"] == 1
				if bThrowAway then
					self.m_ItemPromptReference = item
					self.m_InventoryActionPrompt = InventoryActionGUI:new("Löschen")
				else
					ErrorBox:new(_"Du kannst dieses Item nicht zerstören!")
				end
			end
		end
	end

	item.onRightClick = function()
		if item.Item then
			if localPlayer:getData("isTied") or localPlayer:getPublicSync("cuffed") or localPlayer:getData("Admin:IsFrozen") then return ErrorBox:new(_"Du kannst derzeit nichts benutzen.") end
			local itemName = item.ItemName
			triggerServerEvent("onPlayerSecondaryItemUseServer", localPlayer, item.Id, Inventory.Tabs[self.m_CurrentTab], itemName, item.Place)
		end
	end
end

function Inventory:acceptPrompt( bObj )
	if self.m_InventoryActionPrompt then
		if self.m_InventoryActionPrompt == bObj then
			if self.m_ItemPromptReference then
				local item = self.m_ItemPromptReference
				if item then
					local name, id, place, bag = item.ItemName, item.Id, item.Place, Inventory.Tabs[self.m_CurrentTab]
					local bThrowAway = self.m_ItemData[name]["Wegwerf"] == 1
					if bObj then
						bObj:close()
					end
					if bThrowAway then
						triggerServerEvent("throwItem", localPlayer, item, bag, id, place, name)
					else
						ErrorBox:new(_"Du kannst dieses Item nicht zerstören!")
					end
				end
			end
		end
	end
end

function Inventory:addItemToSlot(tabId, item)
	if not self.m_Tabs[tabId] then return false end
	local tab = self.m_Tabs[tabId]
	if not tab.m_ItemSlots then return false end
	local slot = tab.m_ItemSlots
end

function Inventory:onShow()
	showCursor(true)
	triggerServerEvent("refreshInventory", localPlayer)
	self:loadItems()
	self.Show = true
end

function Inventory:onHide()
	showCursor(false)
	self.Show = false
end

function Inventory:getItemAmount(item)
	triggerServerEvent("refreshInventory", localPlayer)
	for index, itemInv in pairs(self.m_Items) do
		if self.m_ItemData then
			if itemInv["Objekt"] == item then
				return itemInv["Menge"]
			end
		end
	end
	return 0
end
