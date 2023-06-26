-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SkinShopGUI.lua
-- *  PURPOSE:     SkinShopGUI class
-- *
-- ****************************************************************************
SkinShopGUI = inherit(GUIForm)
inherit(Singleton, SkinShopGUI)
addRemoteEvents{"skinBought"}

function SkinShopGUI:constructor(marker, levels)
	localPlayer:setFrozen(true)

	GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2, true, false, marker)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kleidungsgeschäft", false, true, self)
	self.m_SkinList = GUIGridList:new(0, self.m_Height*0.22, self.m_Width, self.m_Height*0.72, self.m_Window)
	self.m_SkinList:addColumn(_"Name", 0.75)
	self.m_SkinList:addColumn(_"Preis", 0.25)
	self.m_ShopImage = GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/Shops/ClothesHeader.png", self.m_Window)
	GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
	GUILabel:new(6, self.m_Height-self.m_Height/14, self.m_Width*0.5, self.m_Height/14, _"Doppelklick zum Kaufen", self.m_Window):setFont(VRPFont(self.m_Height*0.045)):setAlignY("center"):setColor(Color.Red)

	-- Load skin info
	for i, levelInfo in pairs(SkinShopLevel) do
		if levelInfo >= levels[1] and levelInfo <= levels[2] then
			self.m_SkinList:addItemNoClick(_("Stufe %d", levelInfo))
			for skinId, info in pairs(SkinInfo) do
				if info[3] >= levels[1] and info[3] <= levels[2] then
					if info[3] == levelInfo then
						local name, price, level = unpack(info)
						local item = self.m_SkinList:addItem(name, tostring(price).."$")

						-- Add doubleclick event
						item.onLeftDoubleClick = function()	
							if localPlayer:getSkinLevel() >= SkinInfo[skinId][3] then
								triggerServerEvent("skinBuy", localPlayer, skinId) 
							else
								ErrorBox:new(_"Für diese Kleidung benötigst du ein höheres Skin-Level!")
							end
						end
						item.onLeftClick = function () localPlayer:setModel(skinId) end
					end
				end
			end
		end
	end

	localPlayer.m_OldSkin = localPlayer:getModel()


	self.m_SkinBought = bind(self.Event_SkinBought, self)
	self.m_RotatePlayer = bind(self.rotatePlayer, self)

	addEventHandler("skinBought", root, self.m_SkinBought)
	addEventHandler("onClientPreRender", root, self.m_RotatePlayer)

	showChat(false)
end

function SkinShopGUI:virtual_destructor()
	removeEventHandler("skinBought", root, self.m_SkinBought)
	removeEventHandler("onClientPreRender", root, self.m_RotatePlayer)
	localPlayer:setFrozen(false)
	localPlayer:setModel(localPlayer.m_OldSkin)
	setCameraTarget(localPlayer, localPlayer)
	showChat(true)
	setElementDimension( localPlayer, localPlayer.m_OrigDim)
end

function SkinShopGUI:Event_SkinBought(skinId)
	localPlayer.m_OldSkin = skinId
	delete(self)

	SuccessBox:new(_"Skin erfolgreich übernommen!")
end

function SkinShopGUI:rotatePlayer()
	local rot = localPlayer:getRotation()
	localPlayer:setRotation(0, 0, rot.z+1)
end

function SkinShopGUI.initializeAll()
	--[[
	local marker = Marker.create(218.2, -98.5, 1004.3, "cylinder", 1.4, 255, 255, 0)
	marker:setInterior(15)

	addEventHandler("onClientMarkerHit", marker,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				localPlayer:setPosition(Vector3(217.922, -98.563, 1005.258))
				localPlayer:setRotation(Vector3(0.000, 0.000, 299))
				setCameraMatrix(216.056396484375, -99.181800842285156, 1006.8388061523437, 216.90571594238281, -98.900047302246094, 1006.3923950195312, 0, 70)

				SkinShopGUI:new()
			end
		end
	)
	--]]

	for i, v in pairs(SkinShops) do
		local marker = Marker.create(v.Marker, "cylinder", 1.4, 255, 255, 0)
		marker:setInterior(v.MarkerInt)

		addEventHandler("onClientMarkerHit", marker,
			function(hitElement, matchingDimension)
				if hitElement == localPlayer and matchingDimension and localPlayer:getInterior() == source:getInterior() then
					--if not hitElement:getFaction() or (hitElement:getFaction() and not hitElement:getFaction():isEvilFaction()) then
						if (localPlayer:getPublicSync("Company:Duty") == nil or localPlayer:getPublicSync("Company:Duty") == false) and (localPlayer:getPublicSync("Faction:Duty") == nil or localPlayer:getPublicSync("Faction:Duty") == false) then
							localPlayer.m_OrigDim = getElementDimension( localPlayer )
							local dim = getFreeSkinDimension()
							setElementDimension( localPlayer, dim )
							localPlayer:setPosition(v.PlayerPos)
							localPlayer:setRotation(v.PlayerRot)
							setCameraMatrix(unpack(v.CameraMatrix))

							SkinShopGUI:new(marker, v.Levels)
						else
							ErrorBox:new(_"Du kannst im Dienst nicht den Skin wechseln!")
						end
					--else
					--	ErrorBox:new(_"Du kannst in deiner Fraktion nicht den Skin wechseln!")
					--end
				end
			end
		)
	end
end
