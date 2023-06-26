-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PlayHouseShopGUI.lua
-- *  PURPOSE:     PlayHouse Shop GUI class
-- *
-- ****************************************************************************
PlayHouseShopGUI = inherit(GUIForm)
inherit(Singleton, PlayHouseShopGUI)

PlayHouseShopGUI.Items = 
{
	{"Tageskarte", 12000, (60*60*7), "files/images/Inventory/items/Items/Clubcard.png", "Diese Karte erlaubt es dir, die oberen Gemächer zu betreten. (7 Stunden)"}, 
	{"Wochenkarte", 70000, (60*60*24*7), "files/images/Inventory/items/Items/Clubcard.png", "Diese Karte erlaubt es dir, die oberen Gemächer zu betreten. (1 Woche)"}, 
	{"Zweiwochenkarte", 130000,  (60*60*24*14), "files/images/Inventory/items/Items/Clubcard.png", "Diese Karte erlaubt es dir, die oberen Gemächer zu betreten. (2 Wochen)"},
	{"Dreiwochenkarte", 190000,  (60*60*24*21), "files/images/Inventory/items/Items/Clubcard.png", "Diese Karte erlaubt es dir, die oberen Gemächer zu betreten. (3 Wochen)"},
	{"Monatskarte", 250000,  (60*60*24*30), "files/images/Inventory/items/Items/Clubcard.png", "Diese Karte erlaubt es dir, die oberen Gemächer zu betreten. (Monat)"}
}

function PlayHouseShopGUI:constructor(marker)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, marker)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Theke", true, true, self)
	
	GUIGridLabel:new(1, 1, 12, 1, _"Willkommen, was kann man für dich tun?", self)
	self.m_ShopItems = GUIGridGridList:new(1, 2, 6, 7, self)
	self.m_ShopItems:addColumn(_"Gegenstand", 0.6)
	self.m_ShopItems:addColumn(_"Preis", 0.4)
	
	self.m_ItemDescription = GUIGridLabel:new(8, 5, 4, 4, _"", self)
	self.m_ItemImage = GUIGridImage:new(8, 2, 4, 3, "files/images/Inventory/items/Items/Clubcard.png", self)
	self.m_ItemImage:setVisible(false)
	
	local item
	for index, data in ipairs(PlayHouseShopGUI.Items) do
		item = self.m_ShopItems:addItem(data[1], ("$%s"):format(convertNumber(data[2])))
		item.price = data[2] 
		item.duration = data[3]
		item.name = data[1]
		item.text = data[5]
		item.path = data[4]
		item.onLeftClick = bind(self.Event_UpdateDescription, self, item)
		item.onLeftDoubleClick = bind(self.Event_ClickItem, self, item)
	end

end

function PlayHouseShopGUI:Event_UpdateDescription(item) 
	if item then 
		self.m_ItemImage:setImage(item.path)
		self.m_ItemImage:setVisible(true)
		self.m_ItemDescription:setText(item.text)
	end
end

function PlayHouseShopGUI:Event_ClickItem(item) 
	local name = item.name 
	triggerServerEvent("PlayHouse:buyItem", localPlayer, name, item.price, item.duration)
	delete(self)
end


function PlayHouseShopGUI:destructor()
	GUIForm.destructor(self)
end
