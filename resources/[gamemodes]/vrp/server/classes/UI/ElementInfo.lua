-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/UI/ElementInfo.lua
-- *  PURPOSE:     ElementInfo manager
-- *
-- ****************************************************************************
ElementInfo = inherit(Object)
ElementInfo.Map = {}

function ElementInfo:constructor(object, text, offset, icon, iconOnly)
	ElementInfo.Map[object] = self
    self.m_Text = text
    self.m_Object = object
	self.m_Offset = offset
	self.m_Icon = icon
	self.m_IconOnly = iconOnly
	triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "elementInfoCreate", resourceRoot, object, text, offset, icon, iconOnly)
end

function ElementInfo:destructor()
	ElementInfo.Map[self.m_Object] = nil
	triggerClientEvent("elementInfoDestroy", root, self.m_Object)
end

function ElementInfo.sendAllToClient(player)
	local data = {}
	for object, class in pairs(ElementInfo.Map) do
		data[object] = {class.m_Text, class.m_Offset, class.m_Icon, class.m_IconOnly}
	end
	player:triggerEvent("elementInfoRetrieve", data)
end
