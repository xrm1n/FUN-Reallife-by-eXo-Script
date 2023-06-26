-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/PlayHouse.lua
-- *  PURPOSE:     PlayHouse class
-- *
-- ****************************************************************************

PlayHouse = inherit(Singleton)
PlayHouse.TexturePath = "files/images/Textures/Spielbunker"

addRemoteEvents{"PlayHouse:resetWeatherTime", "PlayHouse:sendStream", "PlayHouse:playOpen", "PlayHouse:sendProfit"}
function PlayHouse:constructor() 
	self.m_ColShape = createColCuboid(452.46, 476.06, 1045.81,  120, 60, 40)
	self.m_ColShape:setInterior(12)
	self.m_Textures = {}
	self.m_Lights = {}
	self.m_Gnomes = {}
	self.m_UpdateBind = bind(self.onUpdate, self)

	addEventHandler("onClientColShapeHit", self.m_ColShape, bind(self.Event_onHit, self))
	addEventHandler("onClientColShapeLeave", self.m_ColShape, bind(self.Event_onLeave, self))
	addEventHandler("PlayHouse:resetWeatherTime", localPlayer, bind(self.Event_resetTimeWeather, self))
	addEventHandler("PlayHouse:sendStream", localPlayer, bind(self.Event_getStream, self))
	addEventHandler("PlayHouse:playOpen", localPlayer, bind(self.Event_playOpenSound, self))
	addEventHandler("PlayHouse:sendProfit", localPlayer, bind(self.Event_getProfit, self))

	self:createDoors()
	self:createRoulette()
	self:createGuitarist()

	self.m_ClickBind = bind(self.Event_onClick, self)

	
	self.m_ShopMarker =  createMarker(500.06, 509.67, 1054.82, "cylinder", 1, 224, 255, 255, 200)
	self.m_ShopMarker:setInterior(12)
	self.m_ShopKeeper = self:createGnome(Vector3(503, 509.79, 1055.82), Vector3(0, 0, 90))
	self.m_ShopKeeper:setAnimation("food", "shp_tray_lift_loop", -1, false, false, false, true)
	self.m_ShopKeeper.shopkeeper = true
	addEventHandler("onClientMarkerHit", self.m_ShopMarker, function(hE)
		if hE == localPlayer and hE:getInterior() == source:getInterior() then 
			if hE.position.z < source.position.z+2 then
				PlayHouseShopGUI:new(source)
			end
		end
	end)
	ElementInfo:new(self.m_ShopMarker, "Theke", 1, "Dice", true)
	ElementInfoManager:getSingleton():addEventToElement(self.m_ShopMarker)

	self.m_RenderBind = bind(self.renderProfit, self)
end

function PlayHouse:Event_getProfit(profit) 
	if self.m_ProfitTimer and isTimer(self.m_ProfitTimer) then 
		killTimer(self.m_ProfitTimer)
	end
	self.m_ProfitTimer = setTimer(function() triggerServerEvent("PlayHouse:requestProfit", localPlayer) end, 5000, 0)
	self.m_Profit = profit
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	addEventHandler("onClientRender", root,self.m_RenderBind)
end

function PlayHouse:renderProfit() 
	dxDrawText(("$%s"):format(convertNumber(self.m_Profit)), 0, 0, screenWidth-8, screenHeight-200, (self.m_Profit > 0 and tocolor(0, 200, 0, 255)) or (self.m_Profit > 0 and tocolor(200, 0, 0, 255)) or tocolor(255, 128, 0, 255), 2, "sans", "right", "bottom")
end

function PlayHouse:Event_playOpenSound() 
	self.m_OpenSound = playSound3D("files/audio/door_open_playhouse.ogg", -1431.96, -955.22, 200.96)
	self.m_OpenSound:setMaxDistance(200)
	self.m_OpenSound:setVolume(1.5)
end

function PlayHouse:Event_getStream(url) 
	if self.m_Sound then 
		self.m_Sound:stop()
		self.m_Sound = nil 
	end
	self.m_Stream = url
	if self.m_Stream then 
		self.m_Sound = playSound3D(url, 466.91, 511.49, 1055.82, true)
		setSoundMaxDistance(self.m_Sound, 180)
	end
end

function PlayHouse:createGuitarist() 
	self.m_Guitarist = self:createGnome(Vector3(466.91, 511.49, 1055.82), Vector3(0, 0, 223))
	self.m_Guitarist.chair = createObject(1720, 466.44, 512.40, 1054.82)
	self.m_Guitarist.chair:setRotation(0, 0, 13)
	self.m_Guitarist.chair:setInterior(12)
	self.m_Guitarist.guitarist = true
	self.m_Guitarist.tick = getTickCount()
	givePedWeapon(self.m_Guitarist, 31, 1, true)
end

function PlayHouse:loadGuitar() 
	self.m_Txd = engineLoadTXD("files/models/guitar.txd")
	engineImportTXD(self.m_Txd, 356)
	self.m_DFF = engineLoadDFF("files/models/guitar.dff")
	engineReplaceModel(self.m_DFF, 356)

end

function PlayHouse:unloadGuitar() 
	engineRestoreModel(356)
end

function PlayHouse:Event_onClick(button, state, aX, aY, wX, wY, wZ, cW) 
	for i = 1, #self.m_Roulette do 
		if cW == self.m_Roulette[i] or cW == self.m_Roulette[i].ped then 
			if self.m_Roulette[i].highStake then
				HighStakeRouletteGUI:new()
			else 
				RouletteGUI:new()
			end
		end
	end
end

function PlayHouse:createDoors()
	self.m_Doors = {}
	self.m_Doors[1] = createObject(1491, 504.92300415039, 513.27099609375, 1057.1899414063)
	self.m_Doors[1]:setRotation(0, 0, 0)
	self.m_Doors[1]:setInterior(12) 

	self.m_Doors[2] = createObject(1491, 507.79800415039, 513.27099609375, 1057.1899414063)
	self.m_Doors[2]:setRotation(0, 0, 180)
	self.m_Doors[2]:setInterior(12) 
end

function PlayHouse:createGnome(pos, rot) 
	local ped =  createPed( 142, pos)
	ped:setInterior(12)
	ped:setRotation(rot)
	ped:setFrozen(true)
	addEventHandler("onClientPedDamage", ped, cancelEvent)
	ped.cone = createObject(1238, pos)
	ped.cone:setInterior(12)
	ped.cone:setScale(0.6, 0.65, 0.6)
	if ped.texture then 
		ped.texture:delete()
	end
	ped.texture = FileTextureReplacer:new(ped, "BlackJack/sbmyst.jpg", "sbmyst", {}, true, true)
	if ped.cone.texture then 
		ped.cone.texture:delete()
	end
	ped.cone.texture = FileTextureReplacer:new(ped.cone, "BlackJack/redwhite_stripe.jpg", "redwhite_stripe", {}, true, true)
	exports.bone_attach:attachElementToBone(ped.cone, ped, 1, 0.02, 0.05, 0.29, 3, 0, 90)
	self.m_Gnomes[ped] = true
	return ped
end

function PlayHouse:createRoulette() 
	self.m_Roulette = {}
	self.m_Roulette[1] = createObject(1978, 495.50, 514.49, 1055.82)
	self.m_Roulette[1]:setInterior(12)
	self.m_Roulette[1]:setRotation(0, 0, 88+180)
	self.m_Roulette[1].spinner = createObject(1979, 496.852, 514.614, 1055.801)
	self.m_Roulette[1].spinner:setInterior(12)
	setElementData(self.m_Roulette[1], "clickable", true, true)


	self.m_Roulette[1].ped = self:createGnome(Vector3( 495.49, 516.2, 1055.82), Vector3(0, 0, 180))
	setElementData(self.m_Roulette[1].ped, "clickable", true, true)
	self.m_Roulette[1].info = ElementInfo:new(self.m_Roulette[1].ped, "Roulette", 2, "Dice", true)
	ElementInfoManager:getSingleton():addEventToElement(self.m_Roulette[1].ped)

	self.m_Roulette[2] = createObject(1978, 490.42, 505.67, 1061.84)
	self.m_Roulette[2].spinner = createObject(1979, 490.235, 507.010, 1061.821)
	self.m_Roulette[2].spinner:setInterior(12)
	self.m_Roulette[2]:setInterior(12)
	self.m_Roulette[2]:setRotation(0, 0, 0)
	self.m_Roulette[2].highStake = true
	setElementData(self.m_Roulette[2], "clickable", true, true)


	self.m_Roulette[2].ped = self:createGnome(Vector3(488.79, 505.52, 1061.84), Vector3(0, 0, 270))
	setElementData(self.m_Roulette[2].ped, "clickable", true, true)
	self.m_Roulette[2].info = ElementInfo:new(self.m_Roulette[2].ped, "Roulette", 2, "Dice", true)
	ElementInfoManager:getSingleton():addEventToElement(self.m_Roulette[2].ped)
	

end


function PlayHouse:Event_onHit(element, dim) 
	if element and isValidElement(element, "player") and element == localPlayer then 
		addEventHandler("onClientPreRender", root, self.m_UpdateBind)
		if self.m_TextureApplied then 
			for texture, k in pairs(self.m_Textures) do 
				texture:delete()
			end
		end
		self.m_TextureApplied = false
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "tislndshpillar01_128") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "ws_floortiles4") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "ws_rooftarmac1") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "bow_warehousewall") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "sjmlawarplt") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "crate_b") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "slated") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "ab_fabriccheck2") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/wood.jpg", "goldpillar") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/atm_wood.jpg", "kmb_atm") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/atm_sign_wood.jpg", "kmb_atm_sign") ] = true
		
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/clear.png", "excalibursign02") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/stone.jpg", "greyground256") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/white_window.png", "carshowwin2") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/fire.png", "bullethitsmoke") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/white_wall.jpg", "alleydoor9b") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/carpet.jpg", "garage_docks") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/shield.jpg", "cj_bs_menu4") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/banner.jpg", "diderSachs01") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/map.jpg", "bow_loadingbaydoor") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/portrait.jpg", "cj_pizza_men1") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new("files/images/Textures/BlackJack/redwhite_stripe.jpg", "concretenewb256") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new("files/images/Textures/BlackJack/redwhite_stripe.jpg", "redwhite_stripe") ] = true
		self.m_Textures[ StaticFileTextureReplacer:new(PlayHouse.TexturePath.."/banner_small.jpg", "CJ_SUBURBAN_1") ] = true
		
		self.m_TextureApplied = true
		--self:createLight()

		setWeather(1)
		self.m_TimeSetter = setTimer(setTime, 5000, 0, 20, 0)
		addEventHandler("onClientClick", root, self.m_ClickBind)
		self.m_AnimTimer = 
		setTimer(function() 
			for ped, k in pairs(self.m_Gnomes) do 
				if ped and isValidElement(ped, "ped") then 
					if ped.shopkeeper then 
						setTimer(function() ped:setAnimation("food", "shp_tray_lift_loop", -1, false, false, false, true) end, math.random(0, 6000), 1)
					elseif ped.guitarist then 

					else
						setTimer(function() ped:setAnimation("casino", "cards_loop", -1, false, false, false, true) end, math.random(0, 6000), 1)
					end
				end
			end
		end, 5000, 0)

		self:loadGuitar()

		self.m_ClubCol = createColCuboid(482.00, 497.20, 1060.5, 30, 30, 10)
		triggerServerEvent("PlayHouse:checkClubcard", localPlayer)
		
	end
end

function PlayHouse:onUpdate()
	self.m_AllowedIn = localPlayer:getData("PlayHouse:clubcard")
	if self.m_Guitarist and isValidElement(self.m_Guitarist, "ped") then 
		if getTickCount() - self.m_Guitarist.tick > ((self.m_Guitarist.step and self.m_Guitarist.step) or 1200) then 
			self.m_Guitarist.tick = getTickCount()
			if not self.m_Guitarist.animState then 
				setPedControlState(self.m_Guitarist, "aim_weapon", true)
				setPedAnimation(self.m_Guitarist, "shop", "shp_gun_aim", 1200, false, false, false, false, 800, true)
				setPedAnimationSpeed(self.m_Guitarist, "shp_gun_aim", 0.1)
				self.m_Guitarist.step = math.random(700, 1100)
				setPedAimTarget(self.m_Guitarist, math.random(-4, 4)/10,  math.random(-4, 4)/10,  math.random(-4, 4)/10)
				self.m_Guitarist.animState = true
			else 
				setPedControlState(self.m_Guitarist, "aim_weapon", true)
				setPedAnimation(self.m_Guitarist, "shop", "shp_gun_aim", 1200, false, false, false, false, 800, true)
				setPedAnimationSpeed(self.m_Guitarist, "shp_gun_aim", 0.1)
				self.m_Guitarist.step = math.random(700, 1100)
				setPedAimTarget(self.m_Guitarist, math.random(-4, 4)/10,  math.random(-4, 4)/10,  math.random(-4, 4)/10)
				self.m_Guitarist.animState = false
			end
		end
	end
	if not self.m_AllowedIn then
		for i = 1, #self.m_Doors do 
			self.m_Doors[i]:setFrozen(true)
			self.m_Doors[i]:setRotation(0, 0, i == 1 and 0 or 180)
		end
	else 
		for i = 1, #self.m_Doors do 
			self.m_Doors[i]:setFrozen(false)
		end
	end
	if not self.m_AllowedIn then 
		if self.m_ClubCol and isValidElement(self.m_ClubCol, "colshape") and isElementWithinColShape(localPlayer, self.m_ClubCol) then 
			localPlayer:setPosition(Vector3(506.19, 514.97, 1058.19))
			localPlayer:setRotation(Vector3(0, 0, 90))
			ShortMessage:new("Du wurdest aus dem Raum geworfen...", "Back-Lounge")
		end
	end
	toggleControl("fire", false)
	toggleControl("aim_weapon", false)
	toggleControl("next_weapon", false)
	toggleControl("previous_weapon", false)
	toggleControl("action", false)
	setPedWeaponSlot(localPlayer, 0)
end

function PlayHouse:createLight() 
	self.m_Lights[1] = Light:createPointLight(483.09698, 503.39001, 1058.865, 1, 0.4, 0, 1, 20)
end

function PlayHouse:Event_onLeave(element)
	if element and isValidElement(element, "player") and element == localPlayer then 
		for texture, k in pairs(self.m_Textures) do 
			texture:delete()
		end
		self.m_TextureApplied = false
		for i = 1, #self.m_Lights do 
			Light:destroyLight(self.m_Lights[i])
		end
		triggerServerEvent("PlayHouse:requestTimeWeather", localPlayer)
		removeEventHandler("onClientClick", root, self.m_ClickBind)
		if self.m_AnimTimer and isTimer(self.m_AnimTimer) then 
			killTimer(self.m_AnimTimer)
		end
		if self.m_TimeSetter and isTimer(self.m_TimeSetter) then 
			killTimer(self.m_TimeSetter)
		end
		if self.m_ClubCol then 
			self.m_ClubCol:destroy()
		end
		if self.m_Sound then 
			self.m_Sound:stop()
			self.m_Sound = nil 
		end
		
		self:unloadGuitar()
	
		removeEventHandler("onClientPreRender", root, self.m_UpdateBind)
		toggleControl("fire", true)
		toggleControl("aim_weapon", true)
		toggleControl("next_weapon", true)
		toggleControl("previous_weapon", true)
		toggleControl("action", true)

		removeEventHandler("onClientRender", root, self.m_RenderBind)
		if self.m_ProfitTimer and isTimer(self.m_ProfitTimer) then 
			killTimer(self.m_ProfitTimer)
		end
	end
end

function PlayHouse:Event_resetTimeWeather(timeHour, timeMinute, weather) 
	setMinuteDuration(60000)
	setWeather(weather)
	setTime(timeHour, timeMinute)
end

function PlayHouse:destructor() 

end
