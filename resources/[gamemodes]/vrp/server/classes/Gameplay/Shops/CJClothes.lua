-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/CJClothes.lua
-- *  PURPOSE:     CJ-Clothes class
-- *
-- ****************************************************************************
CJClothes = inherit(Shop)

function CJClothes:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)

	--if self.m_Marker then
		--addEventHandler("onMarkerHit", self.m_Marker, bind(self.onTattooMarkerHit, self))
	--end

	if typeData["ClothesMarker"] then
		self.m_ClothesMarker = {}
		for type, pos in pairs(typeData["ClothesMarker"]) do
			self.m_ClothesMarker[type] = createMarker(pos, "cylinder", 1, 255, 255, 0, 120)
			self.m_ClothesMarker[type].typeId = CJ_CLOTHE_TYPES[type]
			self.m_ClothesMarker[type].clothes = CJ_CLOTHES[type]
			self.m_ClothesMarker[type]:setInterior(self.m_Interior)
			self.m_ClothesMarker[type]:setDimension(self.m_Dimension)
			if type == "Tattoos" then
				addEventHandler("onMarkerHit", self.m_ClothesMarker[type], bind(self.onTattooMarkerHit, self))
			else
				addEventHandler("onMarkerHit", self.m_ClothesMarker[type], bind(self.onCJClothesMarkerHit, self))
			end
		end
	end

	if self.m_Ped then
		self.m_Ped:setData("clickable",true,true)
		addEventHandler("onElementClicked", self.m_Ped, function(button, state, player)
			if button =="left" and state == "down" then
				local cjName, cjPrice = unpack(SkinInfo[0])
				QuestionBox:new(player, _("Dieser Kleidungshändler ist nur für den %s-Skin möchtest du diesen für %d$ kaufen?", player, cjName, cjPrice), "skinBuy", nil, source, 10, 0)
			end
		end)
	end
end

function CJClothes:onCJClothesMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement:getModel() == 0 then
			hitElement:triggerEvent("showClothesShopGUI", self.m_Id, source.typeId, source.clothes, self.m_ClothesMarker)
		else
			local cjName, cjPrice = unpack(SkinInfo[0])
			QuestionBox:new(hitElement, _("Diese Kleidung ist nur für den %s-Skin möchtest du diesen für %d$ kaufen?", hitElement, cjName, cjPrice), "skinBuy", nil, source, 10, 0)
		end
	end
end

function CJClothes:onTattooMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement:getModel() == 0 then
			hitElement:triggerEvent("showTattooSelectionGUI", self.m_Id, self.m_ClothesMarker)
		else
			local cjName, cjPrice = unpack(SkinInfo[0])
			QuestionBox:new(hitElement, _("Diese Tattoos sind nur für den %s-Skin möchtest du diesen für %d$ kaufen?", hitElement, cjName, cjPrice), "skinBuy", nil, source, 10, 0)
		end
	end
end

function CJClothes:onTattoSelection(player, typeId)
	local type = CJ_CLOTHE_TYPES[typeId]
	local clothes = CJ_CLOTHES[type]
	player:triggerEvent("showClothesShopGUI", self.m_Id, typeId, clothes, self.m_ClothesMarker)
end

function CJClothes:onShopEnter(player)
	player:sendShortMessage(_("Herzlich Willkommen im %s!", player, self.m_Name))
end
