ItemSmokeGrenade = inherit(Singleton) 

ItemSmokeGrenade.Map = {}

function ItemSmokeGrenade:constructor() 
	self.m_ReplaceShader = dxCreateShader("files/shader/texreplace.fx") -- re-enable this if it gets used / fixed (bug with missing vehicle smoke)
	
	if core:get("Other", "SmokeLowMode", false) then
		self:useLowMode()
	else 
		self:disableLowMode()
	end
	self.m_BindDisableFunc = bind(self.restoreOriginal, self)
	self.m_BindLowFunc = bind(self.restoreLow, self)

	addEventHandler("onClientRestore", root, self.m_BindDisableFunc)
	addEventHandler("onClientRestore", root, self.m_BindLowFunc)
	triggerServerEvent("onPlayerRequestSmoke", localPlayer)
end

function ItemSmokeGrenade:restoreOriginal(bCleared) 
	if bCleared and not core:get("Other", "SmokeLowMode", false) then
		dxSetRenderTarget(self.m_RenderTarget) 
		dxDrawImage(0, 0, 32, 32, "files/images/bullethitsmoke_original.png")
		dxSetRenderTarget()
		dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
		if self.m_ReplaceShader and self.m_RenderTarget then
			engineRemoveShaderFromWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
			engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
		end
	end
end

function ItemSmokeGrenade:restoreLow(bCleared) 
	if bCleared and core:get("Other", "SmokeLowMode", false) then
		dxSetRenderTarget(self.m_RenderTarget) 
		dxDrawImage(0, 0, 8, 8, "files/images/bullethitsmoke_original.png")
		dxSetRenderTarget()
		dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
		if self.m_ReplaceShader and self.m_RenderTarget then
			engineRemoveShaderFromWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
			engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
		end
	end
end

function ItemSmokeGrenade:Event_onStreamedIn()
	if source and isElement(source) and source:getType() == "marker" then 
		if source:getData("isSmokeShape") then
			if source:getData("smokeCol") and isElement(source:getData("smokeCol")) then
				ItemSmokeGrenade.Map[source:getData("smokeCol")] = true
				source:getData("smokeCol"):setDimension(1)
			end
		end
	end
end

function ItemSmokeGrenade:useLowMode()
	if self.m_RenderTarget then self.m_RenderTarget:destroy() end
	self.m_RenderTarget = dxCreateRenderTarget(8, 8, true)
	
	if self.m_ReplaceShader then
		engineRemoveShaderFromWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
	end

	dxSetRenderTarget(self.m_RenderTarget) 
		dxDrawImage(0, 0, 8, 8, "files/images/bullethitsmoke_original.png")
	dxSetRenderTarget()
	dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
	
	if self.m_ReplaceShader and self.m_RenderTarget then
		engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
	end
	ShortMessage:new(_"Achtung! Da du den Low-Mode für Rauch benutzt wird dir evtl. kein Motorrauch angezeigt!", _"Einstellungen", {230, 0, 0}, 10000)
end

function ItemSmokeGrenade:disableLowMode()
	
	if self.m_RenderTarget then self.m_RenderTarget:destroy() end
	self.m_RenderTarget = dxCreateRenderTarget(32, 32, true)

	if self.m_ReplaceShader then
		engineRemoveShaderFromWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
	end

	dxSetRenderTarget(self.m_RenderTarget) 
		dxDrawImage(0, 0, 32, 32, "files/images/bullethitsmoke_original.png")
	dxSetRenderTarget()

	dxSetShaderValue(self.m_ReplaceShader, "gTexture", self.m_RenderTarget)
	if self.m_ReplaceShader and self.m_RenderTarget then
		engineApplyShaderToWorldTexture(self.m_ReplaceShader, "bullethitsmoke")
	end
end


function ItemSmokeGrenade:Event_onStreamedOut()
	if source and isElement(source) and source:getType() == "marker"  then 
		if source:getData("isSmokeShape") then
			if source:getData("smokeCol") and isElement(source:getData("smokeCol")) then
				ItemSmokeGrenade.Map[source:getData("smokeCol")] = nil

			end
		end
	end
end


addEvent("ItemSmokeSync", true)
addEventHandler("ItemSmokeSync", root, function(syncTable)
	ItemSmokeGrenade.Map = syncTable
	for o, k in pairs(syncTable) do
		removeEventHandler("onClientElementStreamIn", o, bind(ItemSmokeGrenade:getSingleton().Event_onStreamedIn, self))
		removeEventHandler("onClientElementStreamOut", o, bind(ItemSmokeGrenade:getSingleton().Event_onStreamedOut, self))
		addEventHandler("onClientElementStreamIn", o, bind(ItemSmokeGrenade:getSingleton().Event_onStreamedIn, self))
		addEventHandler("onClientElementStreamOut", o, bind(ItemSmokeGrenade:getSingleton().Event_onStreamedOut, self))
	end
end)

function ItemSmokeGrenade:destructor() 

end
