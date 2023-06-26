-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/PassengerMouseMenu.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
PassengerMouseMenu = inherit(GUIMouseMenu)
PassengerMouseMenu.Names = {
	[0] = "Fahrer",
	[1] = "Beifahrer",
}
function PassengerMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	local vseTbl
	if owner then
		self:addItem(_("Besitzer: %s", owner)):setTextColor(Color.Red)
	end

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)
	
	if element:getData("VSE:Passengers") then
		vseTbl = element:getData("VSE:Passengers")
		for seat, occupant in pairs(element.occupants) do
			table.insert(vseTbl, occupant)
		end
	end

	for seat, occupant in pairs(element:getData("VSE:Passengers") and vseTbl or element.occupants) do
		if getElementType(occupant) == "player" then
			if occupant == localPlayer then
				self:addItem(_("%s: %s", PassengerMouseMenu.Names[seat] or "Rücksitz", occupant:getName())):setTextColor(Color.Accent)
			else
				self:addItem(_("%s: %s", PassengerMouseMenu.Names[seat] or "Rücksitz", occupant:getName()),
				function()
					if self:getElement() then
						delete(self)
						ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenu:new(posX, posY, occupant), occupant)
					end
				end
				)
			end
		end
	end

	self:adjustWidth()
end
