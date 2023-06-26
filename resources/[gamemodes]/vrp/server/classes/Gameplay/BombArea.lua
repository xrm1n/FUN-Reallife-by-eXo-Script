-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/BombArea.lua
-- *  PURPOSE:     Bomb area class
-- *
-- ****************************************************************************
BombArea = inherit(Object)
BombArea.Map = {}
local DEFAULT_TIMEOUT = 60*1000

function BombArea:constructor(position, placeCallback, explodeCallback, timeout)
    self.m_Id = #BombArea.Map + 1
    self.m_Position = position
    self.m_PlaceCallback = placeCallback
    self.m_ExplodeCallback = explodeCallback
    self.m_Timeout = timeout
    self.m_BombObject = false

    BombArea.Map[self.m_Id] = self
end

function BombArea:destructor()
    if self.m_Timer and isTimer(self.m_Timer) then
        killTimer(self.m_Timer)
    end
    BombArea.Map[self.m_Id] = nil
end

function BombArea:explode()
    createExplosion(self.m_Position, 2)
    if self.m_BombObject then
        self.m_BombObject:destroy()
        self.m_BombObject = false
    end

    if self.m_ExplodeCallback then
        self.m_ExplodeCallback(self, self.m_Placer, self.m_PlacerFaction)
    end
end

function BombArea:fire(player)
    -- Do not start the time if the place callback does not want to fire it
    if self.m_PlaceCallback and self.m_PlaceCallback(self, player) == false then
        return
    end

    if not player:getFaction():isEvilFaction() then
		player:sendError(_("Nur Spieler in bösen Fraktionen können Bomben legen!", player))
		return
	end

	if not player:getInventory():removeItem("Sprengstoff", 1) then
		player:sendError(_("Du hast keine Bombe im Inventar!", player))
		return
	end

    self.m_BombObject = createObject(1654, player:getPosition() + Vector3(0, 0, -0.9), 270, 0, 0)
    self.m_BombObject:setInterior(player:getInterior())
    self.m_BombObject:setDimension(player:getDimension())
    self.m_Placer = player
    self.m_PlacerFaction = player:getFaction()
    self.m_Timer = setTimer(bind(BombArea.explode, self), self.m_Timeout, 1)
end

function BombArea.findAt(targetPosition)
    for k, area in pairs(BombArea.Map) do
        if (targetPosition - area.m_Position).length < 3 then
            return area
        end
    end

    return false
end
