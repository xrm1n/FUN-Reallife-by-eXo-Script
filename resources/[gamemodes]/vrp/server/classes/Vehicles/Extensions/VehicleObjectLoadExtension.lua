-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleObjectLoadExtension.lua
-- *  PURPOSE:     utility class to manage attaching of objects to a vehicle
-- *
-- ****************************************************************************

VehicleObjectLoadExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object
VehicleObjectLoadExtension.ms_InteractionCooldown = 1000
VehicleObjectLoadExtension.ms_LoadHook = Hook:new()
VehicleObjectLoadExtension.ms_UnloadHook = Hook:new()


function VehicleObjectLoadExtension:canObjectBeLoaded(objId)
    if VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()] and self.m_LoadedObjects then
        if objId then
            return VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].objectId == objId
        end
        return true -- return true if there is any object loadable
    end
    return false
end

function VehicleObjectLoadExtension:switchObjectLoadingMarker(state)
    if not VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()] then return false end
    if not self.m_LoadedObjects then return false end
    if self.m_LoadingMarkerActive ~= state then
        if state then
            local markerOffset = VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].loadMarkerPos
            self.m_LoadingMarker = createMarker(self.position + self.matrix.forward * markerOffset.y + self.matrix.up * markerOffset.z + self.matrix.right * markerOffset.x, "corona", 1, 58, 186, 242, 50)
            self.m_LoadingMarker:setInterior(self:getInterior())
            self.m_LoadingMarker:setDimension(self:getDimension())
            addEventHandler("onMarkerHit", self.m_LoadingMarker, bind(VehicleObjectLoadExtension.Event_OnLoadingMarkerHit, self))
        else
            if isElement(self.m_LoadingMarker) then
                self.m_LoadingMarker:destroy()
            end
        end
        local doors = VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].vehicleDoors
        if doors then
            for i,v in pairs(doors) do
                setVehicleDoorOpenRatio(self, v, state and 1 or 0, math.random(400, 600))
            end
        end
        self.m_LoadingMarkerActive = state
    end
end

function VehicleObjectLoadExtension:initObjectLoading()
    if VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()] and not self.m_LoadedObjects then
        self.m_LoadedObjects = {}
        self.m_LastInteraction = getTickCount()
        if isElementFrozen(self) then
            self:switchObjectLoadingMarker(true)
        end
        addEventHandler("onElementDestroy", self, bind(VehicleObjectLoadExtension.Event_OnDestroy, self))
    end
end

function VehicleObjectLoadExtension:isValidObjectToLoad(object)
    if not isElement(object) then return false end
    return object:getModel() == VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].objectId
end

function VehicleObjectLoadExtension:getMaxObjects()
    if self.m_LoadedObjects then return #VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].positions else return 0 end
end

function VehicleObjectLoadExtension:getObjectCount()
    if self.m_LoadedObjects then return #self.m_LoadedObjects end
end

function VehicleObjectLoadExtension:Event_OnLoadingMarkerHit(hitEle, dim)
    if not dim then return false end
    if getElementType(hitEle) == "player" then
        if hitEle:getPlayerAttachedObject() then
            self:tryLoadObject(hitEle, hitEle:getPlayerAttachedObject())
        else
            self:tryUnloadObject(hitEle)
        end
    end
end

function VehicleObjectLoadExtension:Event_OnDestroy()
    self:switchObjectLoadingMarker(false)
end

function VehicleObjectLoadExtension:tryLoadObject(player, object)
    local cooled = (getTickCount() - self.m_LastInteraction) > VehicleObjectLoadExtension.ms_InteractionCooldown
    if getDistanceBetweenPoints3D(self.position, player.position) < 7 then
        if not player.vehicle then
            if self:getObjectCount() < self:getMaxObjects() then
                if not player:isDead() then
                    if self:isValidObjectToLoad(object) then
                        if cooled then
                            VehicleObjectLoadExtension.getLoadHook():call(self, player, object)
                            self:internalLoadObject(player, object)
                            self.m_LastInteraction = getTickCount()
                        end 
                    else
                        player:sendError(_("Dieses Fahrzeug kann dein Objekt nicht transportieren!", player))
                    end
                end
            else
                player:sendError(_("Dieses Fahrzeug ist voll!", player))
            end
        else
            player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
        end
    else
        player:sendError(_("Du bist zu weit vom Truck entfernt!", player))
    end
end

function VehicleObjectLoadExtension:tryUnloadObject(player)
    local cooled = (getTickCount() - self.m_LastInteraction) > VehicleObjectLoadExtension.ms_InteractionCooldown
    if getDistanceBetweenPoints3D(self.position, player.position) < 7 then
        if not player.vehicle then
            if self:getObjectCount() > 0 then
                if not player:isDead() then
                    if not player:getPlayerAttachedObject() then
                        if cooled then
                            VehicleObjectLoadExtension.getUnloadHook():call(self, player, object)
                            self:internalUnloadObject(player)
                            self.m_LastInteraction = getTickCount()
                        end 
                    else
                        player:sendError(_("Du hast bereits ein Objekt dabei!", player))
                    end
                end
            else
                player:sendError(_("Dieses Fahrzeug ist leer!", player))
            end
        else
            player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
        end
    else
        player:sendError(_("Du bist zu weit vom Truck entfernt!", player))
    end
end

function VehicleObjectLoadExtension:internalLoadObject(player, object)
    player:detachPlayerObject(object)
    local data = VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()]
    local pos = data.positions[self:getObjectCount() + 1]
    object:attach(self, pos, 0, 0, data.randomRotation and math.random(0, 360) or data.rotation)
    object:setScale(data.scale or 1)
    table.insert(self.m_LoadedObjects, object)
end

function VehicleObjectLoadExtension:internalUnloadObject(player)
    local object = table.remove(self.m_LoadedObjects, #self.m_LoadedObjects)
    object:detach()
    object:setScale(1)
    player:attachPlayerObject(object)
end

function VehicleObjectLoadExtension:refreshLoadedObjects()
    if self.m_LoadedObjects then
        for i, obj in pairs(self.m_LoadedObjects) do
            obj:setInterior(self:getInterior())
            obj:setDimension(self:getDimension())
        end
    end
end

function VehicleObjectLoadExtension.getLoadHook()
    return VehicleObjectLoadExtension.ms_LoadHook
end

function VehicleObjectLoadExtension.getUnloadHook()
    return VehicleObjectLoadExtension.ms_UnloadHook
end