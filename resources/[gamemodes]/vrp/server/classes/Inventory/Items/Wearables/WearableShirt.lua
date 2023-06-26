-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearableShirt.lua
-- *  PURPOSE:     Wearable Shirts
-- *
-- ****************************************************************************
WearableShirt = inherit( Item )

--{model, bone, x, y, z, rx, ry, rz, scale, doublesided, texture},
--3,0,-0.1325,0.145,0,0,0,1
WearableShirt.objectTable =
{
	["Kevlar"] = {3916, 0.05, 0.05, 1.22, 0, 0,-90, "Schutzweste", false},
	["Tragetasche"] = {3915,0.145,-0.1325,1,0,0,0, "Tragetasche", true},
}

function WearableShirt:constructor()
	self.m_Shirts = {}
end

function WearableShirt:destructor()

end

function WearableShirt:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	if player.m_PrisonTime > 0 then player:sendError(_("Im Prison nicht erlaubt!", player)) return end
	if player.m_JailTime > 0 then player:sendError(_("Im Gefängnis nicht erlaubt!", player)) return end
	if value then --// for texture usage later

	end
	if not player.m_IsWearingShirt and not player.m_Shirt then --// if the player clicks onto the Shirt without currently wearing one
		if itemName == "Kevlar" and not (player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty()) then
			player:sendError(_("Du bist nicht im Dienst! Das Item wurde abgenommen.", player))
			player:getInventory():removeAllItem(self:getName())
			return
		end
		if isElement(player.m_Shirt) then
			destroyElement(player.m_Shirt)
		end
		local x,y,z = getElementPosition(player)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		local model, zOffset, yOffset, scale, rotX, rotZ = WearableShirt.objectTable[itemName][1] or WearableShirt.objectTable["Kevlar"][1],  WearableShirt.objectTable[itemName][2] or WearableShirt.objectTable["Kevlar"][2], WearableShirt.objectTable[itemName][3] or WearableShirt.objectTable["Kevlar"][3], WearableShirt.objectTable[itemName][4] or WearableShirt.objectTable["Kevlar"][4], WearableShirt.objectTable[itemName][5] or WearableShirt.objectTable["Kevlar"][5],  WearableShirt.objectTable[itemName][6] or WearableShirt.objectTable["Kevlar"][6]
		local rotY =  WearableShirt.objectTable[itemName][7] or WearableShirt.objectTable["Kevlar"][7]
		local obj = createObject(model,x,y,z)
		local objName =  WearableShirt.objectTable[itemName][8]
		local bIsConceal = WearableShirt.objectTable[itemName][9]
		local bConcealOutput = false
		if bIsConceal then
			for i = 3,7 do
				if getPedWeapon(player,i) ~= 0 then
					bConcealOutput = true
					break
				end
			end
		end
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		setElementDoubleSided(obj,true)
		exports.bone_attach:attachElementToBone(obj, player, 3, 0, yOffset, zOffset, rotX , rotY, rotZ)
		player.m_Shirt = obj
		player.m_IsWearingShirt = itemName
		player:meChat(true, "zieht "..objName.." an!")
		setElementData(player,"CanWeaponBeConcealed",bIsConceal)
		if bConcealOutput then
			player:meChat(true, "versteckt einige Waffen in seiner "..objName.."!")
		end
		if bIsConceal then
			triggerEvent("WeaponAttach:concealWeapons", player)
		end
		if itemName == "Kevlar" then
			obj:setData("isProtectingChest", true)
			if not player.m_KevlarShotsCount then
				player.m_KevlarShotsCount = 0
			end
		end
	elseif player.m_IsWearingShirt == itemName and player.m_Shirt then --// if the player clicks onto the same Shirt once more remove it
		destroyElement(player.m_Shirt)
		self.m_Shirts[player] = nil
		player.m_IsWearingShirt = false
		player.m_Shirt = false
		player:meChat(true, "setzt "..WearableShirt.objectTable[itemName][8].." ab!")
		setElementData(player,"CanWeaponBeConcealed",false)
		triggerEvent("WeaponAttach:unconcealWeapons", player)
	else --// else the player must have clicked on another Shirt otherwise this instance of the class would have not been called
		if itemName == "Kevlar" and not (player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty()) then
			player:sendError(_("Du bist nicht im Dienst! Das Item wurde abgenommen.", player))
			player:getInventory():removeAllItem(self:getName())
			return
		end
		if isElement(player.m_Shirt) then
			destroyElement(player.m_Shirt)
		end
		local x,y,z = getElementPosition(player)
		local model, zOffset, yOffset, scale, rotX, rotZ  = WearableShirt.objectTable[itemName][1] or WearableShirt.objectTable["Kevlar"][1],  WearableShirt.objectTable[itemName][2] or WearableShirt.objectTable["Kevlar"][2], WearableShirt.objectTable[itemName][3] or WearableShirt.objectTable["Kevlar"][3], WearableShirt.objectTable[itemName][4] or WearableShirt.objectTable["Kevlar"][4], WearableShirt.objectTable[itemName][5] or WearableShirt.objectTable["Kevlar"][5],  WearableShirt.objectTable[itemName][6] or WearableShirt.objectTable["Kevlar"][6]
		local rotY =  WearableShirt.objectTable[itemName][7] or WearableShirt.objectTable["Kevlar"][7]
		local obj = createObject(model,x,y,z)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		local objName =  WearableShirt.objectTable[itemName][8]
		local bIsConceal = WearableShirt.objectTable[itemName][9]
		local bConcealOutput = false
		if bIsConceal then
			for i = 3,7 do
				if getPedWeapon(player,i) ~= 0 then
					bConcealOutput = true
					break
				end
			end
		end
		if bIsConceal then
			triggerEvent("WeaponAttach:concealWeapons", player)
		end
		if bConcealOutput then
			player:meChat(true, "versteckt einige Waffen in seiner "..objName.."!")
		end
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		setElementDoubleSided(obj,true)
		setElementData(player,"CanWeaponBeConcealed",bIsConceal)
		if itemName == "Kevlar" then
			obj:setData("isProtectingChest", true)
		end
		exports.bone_attach:attachElementToBone(obj, player, 3, 0, yOffset, zOffset, rotX, rotY, rotZ)
		player.m_Shirt = obj
		player.m_IsWearingShirt = itemName
		player:meChat(true, "zieht "..objName.." an!")
	end
end

function WearableShirt:destroyShirt(player)
	destroyElement(player.m_Shirt)
	self.m_Shirts[player] = nil
	player.m_IsWearingShirt = false
	player.m_Shirt = false
	player:meChat(true, "setzt "..WearableShirt.objectTable[itemName][8].." ab!")
	setElementData(player,"CanWeaponBeConcealed",false)
	triggerEvent("WeaponAttach:unconcealWeapons", player)
end