﻿--addEvent ( "onPlayerDamage", true )

local settings = {
	driver = get"driveby_driver" or { 22,23,24,25,28,29,32 },
	passenger = get"driveby_passenger" or { 22,23,24,25,26,28,29,32,30,31,33 },
	shotdelay = get"driveby_shot_delay" or { ['22']=300,['23']=300,['24']=800,['26']=700 },
	blockedVehicles = get"driveby_blocked_vehicles" or { 432,601,437,431,592,553,577,488,497,548,563,512,476,447,425,519,520,460,417,469,487,513,441,464,501,465,564,538,449,537,539,570,472,473,493,595,484,430,453,452,446,454,606,591,607,611,610,590,569,611,435,608,584,450 },
	steerCars = get"driveby_steer_cars" == true,
	steerBikes = get"driveby_steer_bikes" == true,
	autoEquip = get"driveby_auto_equip" or false,
	bikeHitboxFix = get"bike_hitbox_fix" == true,
}
--Remove any BS IDs by checking them
local validDrivebyWeapons = { [22]=true,[23]=true,[24]=true,[25]=true,
[26]=true,[27]=true,[28]=true,[29]=true,[32]=true,[30]=true,[31]=true,
[32]=true,[33]=true,[38]=true }
local playerpeds = {}

--Loop through both driveby tables and ensure they have proper IDs
if settings.driver[1] then
	for i=#settings.driver, 1, -1 do
		if not validDrivebyWeapons[settings.driver[i]] then
			table.remove ( settings.driver, i )
		end
	end
end

-- Entfernen, falls Beifahrer auch mit M4 usw. schießen können soll --
if settings.passenger[1] then
	for i=#settings.passenger, 1, -1 do
		if not validDrivebyWeapons[settings.passenger[i]] then
			table.remove ( settings.passenger, i )
		end
	end
end


--Verifies the clientscript is downloaded before initiating
addEvent ( "driveby_clientScriptLoaded", true )
addEventHandler ( "driveby_clientScriptLoaded", getRootElement(),
	function()
		triggerLatentClientEvent ( client, "doSendDriveBySettings", 40000, false, client, settings, playerpeds )
	end
)


local function destroyPed ( player )
	local player = isElement ( client ) and client or isElement ( player ) and player or source
	if isElement ( playerpeds[player] ) then
		destroyElement ( playerpeds[player] )
		triggerClientEvent ( "deletePedForDrivebyFix", player )
	end
end 
addEventHandler ( "onPlayerQuit", root, destroyPed )
addEventHandler ( "onPlayerWasted", root, destroyPed )
addEvent ( "destroyPedForDrivebyFix", true )
addEventHandler ( "destroyPedForDrivebyFix", root, destroyPed )
addEventHandler ( "onVehicleExit", root, destroyPed )


addEvent ( "createPedForDrivebyFix", true )
addEventHandler ( "createPedForDrivebyFix", root, function ( )
	local veh = getPedOccupiedVehicle ( client )
	local client = client
	destroyPed ( client )
	if isElement ( veh ) then
		local x, y, z = getElementPosition ( client )
		playerpeds[client] = createPed ( 0, x+100, y, z )
		setElementAlpha ( playerpeds[client], 0 )
		setElementCollisionsEnabled ( playerpeds[client], false )
		setElementDimension ( playerpeds[client], getElementDimension ( client ) )
		setElementInterior ( playerpeds[client], getElementInterior( client ) )
		if getVehicleType(veh) == "BMX" or getVehicleType(veh) == "Quad" then 
			attachElements ( playerpeds[client], veh, 100, -0.4, 0.5 )
			setTimer(function()
				if isElement(client) and isElement(playerpeds[client]) and isElement(veh) then
					attachElements(playerpeds[client], veh, 0, -0.4, 0.5 )
				end
			end, 100, 1)
		elseif getPedOccupiedVehicleSeat ( client ) == 0  then
			attachElements ( playerpeds[client], veh, 100, 0.05, 0.5 )
			setTimer(function()
				if isElement(client) and isElement(playerpeds[client]) and isElement(veh) then
					attachElements(playerpeds[client], veh, 0, 0.05, 0.5 )
				end
			end, 100, 1)
		else
			attachElements ( playerpeds[client], veh, 100, -0.8, 0.5 )
			setTimer(function()
				if isElement(client) and isElement(playerpeds[client]) and isElement(veh) then
					attachElements(playerpeds[client], veh, 0, -0.5, 0.5)
				end
			end, 100, 1)
		end
		triggerClientEvent ( "savePedForDrivebyFix", client, playerpeds[client], veh )
	end
end )
