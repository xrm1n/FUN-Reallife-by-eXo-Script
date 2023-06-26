-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Plant.lua
-- *  PURPOSE:     Plant-Seed class client
-- *
-- ****************************************************************************

Plant = inherit( Object )

addRemoteEvents{"Plant:sendClientCheck", "Plant:syncPlantMap", "Plant:onWaterPlant"}

function Plant.initalize()
	Plant.Shader = dxCreateShader ( "files/shader/shell_layer.fx",0,20,true, "object" )
	Plant.Shader2 = dxCreateShader ( "files/shader/shell_layer.fx",0,20,true, "object" )
	Plant.WaterDrop =  "files/images/Inventory/waterdrop.png"
end

function Plant.checkGroundInfo()
	local pos = localPlayer:getPosition()
	local gz = getGroundPosition(pos)
	local surfaceClear = true
	local surfaceRightType = true 
	if math.abs(pos.z - gz) < 2 then  
		local base, __, __, __, __, __, __, __, surface = processLineOfSight(pos.x, pos.y, pos.z, pos.x, pos.y, gz-0.5, true, false, false)
		if base then
			local edges = {
				top = {processLineOfSight(pos.x + 1, pos.y, pos.z, pos.x + 1, pos.y, gz-0.5, true, false, false)},
				left = {processLineOfSight(pos.x, pos.y + 1, pos.z, pos.x, pos.y + 1, gz-0.5, true, false, false)},
				bottom = {processLineOfSight(pos.x - 1, pos.y, pos.z, pos.x - 1, pos.y, gz-0.5, true, false, false)},
				right = {processLineOfSight(pos.x, pos.y - 1, pos.z, pos.x, pos.y - 1, gz-0.5, true, false, false)},
			}
			for i,v in pairs(edges) do
				if v[1] then 
					if not IsMatInMaterialType(v[9]) then
						surfaceRightType = false
						break
					end
				else
					surfaceClear = false
					break
				end
			end
			if not IsMatInMaterialType(surface) then
				surfaceRightType = false
			end
		else	
			surfaceClear = false
		end
	else	
		surfaceClear = false
	end
	return surfaceClear, surfaceRightType, gz
end

function Plant:constructor( )
	self.m_BindRemoteFunc = bind( Plant.onUse, self )
	self.m_BindRemoteFunc2 = bind( Plant.onSync, self )
	self.m_BindRemoteFunc3 = bind( Plant.Render, self )
	self.m_BindRemoteFunc4 = bind( Plant.onWaterPlant, self )
	self.m_EntityTable = {	}
	addEventHandler("Plant:sendClientCheck", localPlayer, self.m_BindRemoteFunc )
	addEventHandler("Plant:syncPlantMap", localPlayer, self.m_BindRemoteFunc2 )
	addEventHandler("onClientRender", root, self.m_BindRemoteFunc3 )
	addEventHandler("Plant:onWaterPlant", localPlayer, self.m_BindRemoteFunc4 )
end

function Plant:isUnderWater()
	local pos = localPlayer:getPosition()
	local waterLevel = getWaterLevel(pos.x, pos.y, pos.z)
	if waterLevel and pos.z-waterLevel < 0 then
		return true
	end
	return false
end

function Plant:onUse(plant)
	local surfaceClear, surfaceRightType, gz = Plant.checkGroundInfo()
	triggerServerEvent("plant:getClientCheck", localPlayer, plant, surfaceClear and surfaceRightType, gz, self:isUnderWater())
end

function Plant:Render()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/PlantUI") end
	if Plant.Shader and Plant.Shader2 then
		if #self.m_EntityTable ~= 0 then
			local timeElapsed = getTickCount() - self.m_RendTick
			local f = timeElapsed / 500
			f = math.min( f, 1 )
			local size = math.lerp ( 1, 1.2, f )
			local alpha = math.lerp ( 1.0, 0.0, f )
			dxSetShaderValue( Plant.Shader, "sMorphSize", size, size, size )
			dxSetShaderValue( Plant.Shader, "sMorphColor", 0, 1, 0, alpha )
			dxSetShaderValue( Plant.Shader2, "sMorphSize", size, size, size )
			dxSetShaderValue( Plant.Shader2, "sMorphColor", 1, 0, 0, alpha )
		end
	end
	if self.m_HydPlant  and isElementStreamedIn(self.m_HydPlant) then
		local now = getTickCount()
		if self.m_HydDrawTick+1000 >= now then
			local prog = ( now - self.m_HydDrawTick) / 1000
			local offsetZ = 0.5 * prog
			local x,y,z = getElementPosition( self.m_HydPlant )
			local sx, sy = getScreenFromWorldPosition( x,y,(z+1)- offsetZ)
			local alpha = 255 * prog
			local color = tocolor( 255, 255, 255, alpha)
			dxDrawImage(sx,sy,screenWidth*0.03,screenWidth*0.05, Plant.WaterDrop, 0,0,0, color)
		else
			self.m_HydPlant = nil
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/PlantUI", 1, 1) end
end

function Plant:destructor( )

end

function IsMatInMaterialType( mat )
	local bCheck
	for i = 1,#MATERIAL_TYPES do
		for i2 = 1,#MATERIAL_TYPES[i] do
			bCheck = mat == MATERIAL_TYPES[i][i2]
			if bCheck then
				return true
			end
		end
	end
	return false
end

function Plant:onSync( tbl )
	local iHyd,obj
	for i = 1,#self.m_EntityTable do
		obj = self.m_EntityTable[i]
		engineRemoveShaderFromWorldTexture ( obj.m_Shader, "*" ,self.m_EntityTable[i])
		setElementAlpha( obj, 255 )
	end
	self.m_EntityTable = tbl
	self.m_RendTick = getTickCount()
	for i = 1,#self.m_EntityTable do
		obj = self.m_EntityTable[i]
		if getElementData(obj, "Plant:Hydration") then
			obj.m_Shader = Plant.Shader
		else
			obj.m_Shader = Plant.Shader2
		end
		engineApplyShaderToWorldTexture ( obj.m_Shader, "*", obj)
		setElementAlpha( obj, 254 )
	end
end

function Plant:onWaterPlant( plant )
	self.m_HydPlant = plant
	self.m_HydDrawTick = getTickCount()
end

function math.lerp(from,to,alpha)
    return from + (to-from) * alpha
end


--[[addEventHandler("onClientRender", root, function()
	local pos = localPlayer:getPosition()
	local gz = getGroundPosition(pos)
	local surfaceClear = true
	local surfaceRightType = true 
	if math.abs(pos.z - gz) < 2 then  
		local base, __, __, __, __, __, __, __, surface = processLineOfSight(pos.x, pos.y, pos.z, pos.x, pos.y, gz-0.5, true, false, false)
		if base then
			local edges = {
				top = {processLineOfSight(pos.x + 1, pos.y, pos.z, pos.x + 1, pos.y, gz-0.5, true, false, false)},
				left = {processLineOfSight(pos.x, pos.y + 1, pos.z, pos.x, pos.y + 1, gz-0.5, true, false, false)},
				bottom = {processLineOfSight(pos.x - 1, pos.y, pos.z, pos.x - 1, pos.y, gz-0.5, true, false, false)},
				right = {processLineOfSight(pos.x, pos.y - 1, pos.z, pos.x, pos.y - 1, gz-0.5, true, false, false)},
			}
			dxDrawLine3D(pos.x + 1, pos.y, pos.z, pos.x + 1, pos.y, gz-0.5, edges.top and tocolor(0, 255, 0) or tocolor(255, 0, 0))
			dxDrawLine3D(pos.x, pos.y + 1, pos.z, pos.x, pos.y + 1, gz-0.5, edges.left and tocolor(0, 255, 0) or tocolor(255, 0, 0))
			dxDrawLine3D(pos.x - 1, pos.y, pos.z, pos.x - 1, pos.y, gz-0.5, edges.bottom and tocolor(0, 255, 0) or tocolor(255, 0, 0))
			dxDrawLine3D(pos.x, pos.y - 1, pos.z, pos.x, pos.y - 1, gz-0.5, edges.right and tocolor(0, 255, 0) or tocolor(255, 0, 0))
			for i,v in pairs(edges) do
				if v[1] then 
					if not IsMatInMaterialType(v[9]) then
						surfaceRightType = false
						break
					end
				else
					surfaceClear = false
					break
				end
			end
			if not IsMatInMaterialType(surface) then
				surfaceRightType = false
			end
			dxDrawText("surface: " .. tostring(edges.top[9]).." - "..tostring(edges.left[9]).." - "..tostring(edges.bottom[9]).." - "..tostring(edges.right[9]).." - "..tostring(surface), 500, 520)
		else	
			surfaceClear = false
		end
	else	
		surfaceClear = false
	end
	dxDrawText("clear: " .. tostring(surfaceClear), 500, 500)
	dxDrawText("right type: " .. tostring(surfaceRightType), 500, 510)
end)]]