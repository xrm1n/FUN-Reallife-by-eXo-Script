-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/VehicleGuns.lua
-- *  PURPOSE:     Client Vehicle Gun Class
-- *
-- ****************************************************************************

VehicleGuns = inherit(Singleton)
VehicleGuns.Cooldowns = {
    [425] = 5000, --Hunter
    [432] = 5000, --Rhino
    [464] = math.huge, --RC Baron
    [520] = 5000 --Hydra
}
VehicleGuns.ControlToDeactivate = {
    [425] = {"vehicle_fire"}, --Hunter
    [432] = {"vehicle_fire", "vehicle_secondary_fire"}, --Rhino
    [464] = {"vehicle_fire", "vehicle_secondary_fire"}, --RC Baron
    [520] = {"vehicle_secondary_fire"} --Hydra
}
VehicleGuns.LastShoot = {ShotAt=0, LockedUntil=0}
VehicleGuns.BlockShoot = {
    [464] = true, --RC Baron
}

function VehicleGuns:constructor()
    self.m_ShootBind = bind(self.onShoot, self)
    self.m_UpdateBind = bind(self.update, self)
    addEventHandler("onClientVehicleEnter", root, bind(self.onVehicleEnter, self))
    addEventHandler("onClientVehicleExit", root, bind(self.onVehicleExit, self))
    addEventHandler("vehicleEngineStateChange", root, bind(self.onEngineStateChange, self))
end

function VehicleGuns:onShoot()
    if localPlayer:getOccupiedVehicle() then
        if self:areControlsEnabled() then
            if localPlayer:getOccupiedVehicle():getEngineState() then
                if VehicleGuns.LastShoot.LockedUntil < getTickCount() then
                    local cooldown = VehicleGuns.Cooldowns[localPlayer:getOccupiedVehicle():getModel()]
                    VehicleGuns.LastShoot = {ShotAt=getTickCount(), LockedUntil=getTickCount()+cooldown}
                    addEventHandler("onClientRender", root, self.m_UpdateBind)

                    local time = (VehicleGuns.LastShoot.LockedUntil-VehicleGuns.LastShoot.ShotAt) / 1000
                    self.m_Countdown = ShortCountdown:new(time, "Nachladen", "files/images/Other/Bullet.png")
                end
            end
        end
    end
end

function VehicleGuns:update()
    if (localPlayer.vehicle and VehicleGuns.BlockShoot[localPlayer.vehicle:getModel()]) or VehicleGuns.LastShoot.LockedUntil >= getTickCount() or (localPlayer:getOccupiedVehicle() and localPlayer:getOccupiedVehicle():getEngineState() == false) then
        self:toggleControls(false)
    else
        if self:isKeyPressed() == false then
            removeEventHandler("onClientRender", root, self.m_UpdateBind)
            self:toggleControls(true)
        end
    end
end

function VehicleGuns:onVehicleEnter(player, seat)
    if player == localPlayer then
        if seat == 0 then
            if VehicleGuns.Cooldowns[source:getModel()] then
                self.m_Controls = VehicleGuns.ControlToDeactivate[source:getModel()]

                for index, control in pairs(self.m_Controls) do
                    bindKey(control, "down", self.m_ShootBind)
                end

                addEventHandler("onClientRender", root, self.m_UpdateBind)
            end
        end
    end
end

function VehicleGuns:onVehicleExit(player, seat)
    if player == localPlayer then
        removeEventHandler("onClientRender", root, self.m_UpdateBind)
        if self.m_Controls then
            for index, control in pairs(self.m_Controls) do
                unbindKey(control, "down", self.m_ShootBind)
            end
        end
        if self.m_Countdown then
            delete(self.m_Countdown)
        end
    end
end

function VehicleGuns:onEngineStateChange(vehicle, state)
    if VehicleGuns.Cooldowns[vehicle:getModel()] then
        if state == false then
            if not isEventHandlerAdded("onClientRender", root, self.m_UpdateBind) then
                addEventHandler("onClientRender", root, self.m_UpdateBind)
            end
        end
    end
end

function VehicleGuns:isKeyPressed()
    local keyPressed = false
    for index, control in pairs(self.m_Controls) do
        for key, state in pairs(getBoundKeys(control)) do
            if getKeyState(key) then
                keyPressed = true
            end
        end
    end
    return keyPressed
end

function VehicleGuns:toggleControls(state)
    for index, control in pairs(self.m_Controls) do
        toggleControl(control, state)
    end
end

function VehicleGuns:areControlsEnabled()
    for index, control in pairs(self.m_Controls) do
        if not isControlEnabled(control) then
            return false
        end
    end
    return true
end