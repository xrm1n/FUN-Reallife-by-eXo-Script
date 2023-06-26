-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/PrisonBreak/PrisonBreakManager.lua
-- *  PURPOSE:     Prison Break Manager Class
-- *
-- ****************************************************************************


-- TODO
-- Nachricht beim Auslagern von Waffen kommt 2x
-- Countdown liegen übereinander

PrisonBreakManager = inherit(Singleton)
PrisonBreakManager.BombCountdown = 10 * 1000
PrisonBreakManager.OfficerCount = DEBUG and 0 or 5

function PrisonBreakManager:constructor()
    self.m_WeaponBoxes = {}

    self:createEntrance()
    self:createDummyPoliceman()
    self:createWeaponBoxes()

    local antifall = createColCuboid( 3624.71, -1551.32, -0.20, 8, 8, 3.8 )
    InstantTeleportArea:new(antifall, 0, 0, Vector3(3630.73, -1546.19, 4.94))
    
    local antifall2 = createColCuboid(2559.17, -1416.25, 1045.87, 5, 10, 4 )
    antifall2:setInterior(2)
    InstantTeleportArea:new(antifall2, 0, 2, Vector3(2561.75, -1414.22, 1050.83))

    local antifall3 = createColCuboid(2555.62, -1462.42, 1031.07, 200, 200, 7) -- prevents suicide
    antifall3:setInterior(2)
    InstantTeleportArea:new(antifall3, 0, 2, Vector3(2611.23, -1414.81, 1040.36))

    self.m_BombAreaPosition = Vector3(-719.92, -401.11, 7.48)
	self.m_BombArea = BombArea:new(self.m_BombAreaPosition, bind(self.BombArea_Place, self), bind(self.BombArea_Explode, self), PrisonBreakManager.BombCountdown)
	self.m_BombColShape = createColSphere(self.m_BombAreaPosition, 20)
end

function PrisonBreakManager:stop()
    self.m_Instance = nil

    if not isElement(self.m_Entrance) then
        self:createEntrance()
    end

    if not isElement(self.m_Officer) then
        self:createPoliceman()
    end
end

function PrisonBreakManager:createEntrance()
    self.m_Entrance = createObject(1381, Vector3(-720.17698974609, -402.13763427734, 8.146), Vector3(80.0, 0.00, 342.50))
    self.m_Entrance:setScale(0.9, 0.85, 0.8)
end

function PrisonBreakManager:createDummyPoliceman()
    self.m_Officer = TargetableNPC:new(276, Vector3(2564.98, -1432.98, 1044.52), 345.4)
    self.m_Officer:setInterior(2)
    self.m_Officer:setImmortal(true)
    self.m_Officer:setFrozen(true)
    self.m_Officer.m_Warning = "Du überfällst den Gefängnisaufseher in 5 Sekunden, wenn du weiter auf ihn zielst!"
    self.m_Officer.onTargetted = bind(self.PedTargetted, self)
    self.m_Officer.onTargetRefresh = bind(self.PedTargetRefresh, self)
end

function PrisonBreakManager:PedTargetted(ped, attacker)
    if not self:getCurrent() then
        attacker:sendError(_("Derzeit läuft kein Knastausbruch!", attacker))
        return false
    end
end

function PrisonBreakManager:PedTargetRefresh(count, startingPlayer)
    if not self:getCurrent() then
        return false
    end
    self:getCurrent():PedTargetRefresh(count, startingPlayer)    
end

function PrisonBreakManager:BombArea_Place(bombArea, player)
	if not player:getFaction() or not player:getFaction():isEvilFaction() then
		player:sendError(_("Du kannst nur als Mitglied einer bösen Fraktion in das Gefängnis einbrechen!", player))
		return false
    end
    
	if not PermissionsManager:getSingleton():isPlayerAllowedToStart(player, "faction", "PrisonBreak") then
		player:sendError(_("Du bist nicht berechtigt einen Knastausbruch zu starten!", player))
		return false
	end

	if FactionState:getSingleton():countPlayers() < PrisonBreakManager.OfficerCount then
		player:sendError(_("Es sind nicht genügend Staatsfraktionisten online!", player))
		return false
	end

	if not ActionsCheck:getSingleton():isActionAllowed(player) then	return false end

	ActionsCheck:getSingleton():setAction("Knastausbruch")

	for k, player in pairs(getElementsWithinColShape(self.m_BombColShape, "player")) do
		player:triggerEvent("Countdown", PrisonBreakManager.BombCountdown/1000, "Bombe zündet")
	end
	return true
end

function PrisonBreakManager:BombArea_Explode(bombArea, player, faction)
	self.m_Instance = PrisonBreak:new(faction)
end


function PrisonBreakManager:createWeaponBoxes()
    table.insert(self.m_WeaponBoxes, createObject(964, Vector3(2567.8000488281, -1433.9000244141, 1043.5), Vector3(0, 0, 180)))
    table.insert(self.m_WeaponBoxes, createObject(964, Vector3(2565, -1421.5, 1043.5), Vector3(0, 0, 90)))

    for i, box in pairs(self.m_WeaponBoxes) do
        box:setInterior(2)
    end
end

function PrisonBreakManager:getCurrent()
    return self.m_Instance
end
