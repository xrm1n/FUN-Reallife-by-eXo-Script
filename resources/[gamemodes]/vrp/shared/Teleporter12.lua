-- Marker-Koordinaten
local markerPosX = 2177.516
local markerPosY = -1762.420
local markerPosZ = 12.750 -- Neuer Z-Wert für den Marker

-- Ziel-Koordinaten
local targetPosX = 4405.132
local targetPosY = -1834.552
local targetPosZ = 33.775 -- Neuer Z-Wert für das Ziel

-- Marker erstellen
local markerRadius = 2
local marker = createMarker(markerPosX, markerPosY, markerPosZ, "cylinder", markerRadius, 255, 255, 0, 150)
setElementData(marker, "teleportMarker", true) -- Marker mit dem Datenattribut "teleportMarker" markieren
setElementData(marker, "markerText", "Teleportieren") -- Text für den Marker setzen

-- Teleport-Zurück-Marker-Koordinaten
local returnMarkerPosX = targetPosX + 2 -- X-Koordinate des Teleport-Zurück-Markers
local returnMarkerPosY = targetPosY -- Y-Koordinate des Teleport-Zurück-Markers
local returnMarkerPosZ = targetPosZ - 1 -- Z-Koordinate des Teleport-Zurück-Markers

-- Teleport-Zurück-Marker erstellen
local returnMarkerRadius = 2
local returnMarker = createMarker(returnMarkerPosX, returnMarkerPosY, returnMarkerPosZ, "cylinder", returnMarkerRadius, 255, 0, 0, 150)
setElementData(returnMarker, "teleportMarker", true) -- Marker mit dem Datenattribut "teleportMarker" markieren
setElementData(returnMarker, "markerText", "Zurückteleportieren") -- Text für den Marker setzen

-- Funktion zum Anzeigen des Marker-Textes
local function showMarkerText(player, marker)
    local markerText = getElementData(marker, "markerText") or ""
    outputChatBox(markerText, player, 255, 255, 255)
end

-- Marker-Ereignis
addEventHandler("onMarkerHit", marker,
    function(hitElement, matchingDimension)
        -- Überprüfen, ob der Spieler in den Marker eingetreten ist
        if isElement(hitElement) and getElementType(hitElement) == "player" and matchingDimension then
            showMarkerText(hitElement, marker)
            outputChatBox("Bist du sicher, dass du teleportiert werden möchtest? Tippe 'yes' ein, um fortzufahren.", hitElement)
            setElementData(hitElement, "teleportConfirmation", true)
            setElementData(hitElement, "teleportType", "ziel")
        end
    end
)

-- Marker-Ereignis (Teleport-Zurück-Marker)
addEventHandler("onMarkerHit", returnMarker,
    function(hitElement, matchingDimension)
        -- Überprüfen, ob der Spieler in den Marker eingetreten ist
        if isElement(hitElement) and getElementType(hitElement) == "player" and matchingDimension then
            showMarkerText(hitElement, returnMarker)
            outputChatBox("Bist du sicher, dass du zurückteleportiert werden möchtest? Tippe 'yes' ein, um fortzufahren.", hitElement)
            setElementData(hitElement, "teleportConfirmation", true)
            setElementData(hitElement, "teleportType", "zurueck")
        end
    end
)

-- Spieler-Ereignis
addEventHandler("onPlayerChat", root,
    function(message)
        -- Überprüfen, ob der Spieler die Bestätigung eingegeben hat
        if getElementData(source, "teleportConfirmation") and message == "yes" then
            local teleportType = getElementData(source, "teleportType")
            if teleportType == "ziel" then
                if getElementType(getPedOccupiedVehicle(source)) == "vehicle" then
                    setElementPosition(getPedOccupiedVehicle(source), targetPosX, targetPosY, targetPosZ)
                    outputChatBox("Das Fahrzeug wurde zu den Zielkoordinaten teleportiert!", source)
                end
                setElementPosition(source, targetPosX, targetPosY, targetPosZ)
                outputChatBox("Du wurdest zu den Zielkoordinaten teleportiert!", source)
            elseif teleportType == "zurueck" then
                local randomOffsetX = math.random(-1, 1) -- Zufällige X-Offset für den Zurückteleport
                local randomOffsetY = math.random(-1, 1) -- Zufällige Y-Offset für den Zurückteleport
                local returnPosX = markerPosX + randomOffsetX
                local returnPosY = markerPosY + randomOffsetY
                if getElementType(getPedOccupiedVehicle(source)) == "vehicle" then
                    setElementPosition(getPedOccupiedVehicle(source), returnPosX, returnPosY, markerPosZ)
                    outputChatBox("Das Fahrzeug wurde zurückteleportiert!", source)
                end
                setElementPosition(source, returnPosX, returnPosY, markerPosZ)
                outputChatBox("Du wurdest zurückteleportiert!", source)
            end
            setElementData(source, "teleportConfirmation", nil)
            setElementData(source, "teleportType", nil)
        end
    end
)
