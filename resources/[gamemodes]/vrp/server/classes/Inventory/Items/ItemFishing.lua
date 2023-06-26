-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemFishing.lua
-- *  PURPOSE:     Fishing item class
-- *
-- ****************************************************************************
ItemFishing = inherit(Item)

function ItemFishing:constructor()
	self.Random = Randomizer:new()
end

function ItemFishing:destructor()

end

function ItemFishing:canBuy(player, itemName)
	if not FISHING_EQUIPMENT[itemName] then return true end

	if player:getPrivateSync("FishingLevel") >= FISHING_EQUIPMENT[itemName].level then
		return true
	end

	return false, _("Du brauchst mind. Fischer Level %s um dieses Item zu kaufen!", player, FISHING_EQUIPMENT[itemName].level)
end

function ItemFishing:isFishingRod(itemName)
	for fishingRod in pairs(FISHING_RODS) do
		if fishingRod == itemName then
			return true
		end
	end
end

function ItemFishing:isCoolingBag(itemName)
	for coolingBag in pairs(FISHING_BAGS) do
		if coolingBag == itemName then
			return true
		end
	end
end

function ItemFishing:isBait(itemName)
	for bait in pairs(FISHING_BAITS) do
		if bait == itemName then
			return true
		end
	end
end

function ItemFishing:isAccessorie(itemName)
	for bait in pairs(FISHING_ACCESSORIES) do
		if bait == itemName then
			return true
		end
	end
end

function ItemFishing:use(player, itemId, bag, place, itemName)
	local playerInventory = player:getInventory()

	if self:isFishingRod(itemName) then
		Fishing:getSingleton():inventoryUse(player, itemName, bag, place)
		return
	end

	if self:isCoolingBag(itemName) then
		local value = fromJSON(playerInventory:getItemValueByBag(bag, place))

		if value then
			for _, v in pairs(value) do
				v.fishName = Fishing:getSingleton():getFishNameFromId(v.Id)
			end
		end

		player:triggerEvent("closeInventory")
		player:triggerEvent("showCoolingBag", itemName, value)
		return
	end

	if self:isBait(itemName) then
		local baitAmount = playerInventory:getItemAmount(itemName)
		local fishingRods = {}

		for fishingRod, fishingRodData in pairs(FISHING_RODS) do
			if fishingRodData.baitSlots > 0 and playerInventory:getItemAmount(fishingRod) > 0 then
				table.insert(fishingRods, fishingRod)
			end
		end

		player:triggerEvent("closeInventory")
		player:triggerEvent("showEquipmentSelectionGUI", fishingRods, itemName, baitAmount)
		return
	end

	if self:isAccessorie(itemName) then
		local accessorieAmount = playerInventory:getItemAmount(itemName)
		local fishingRods = {}

		for fishingRod, fishingRodData in pairs(FISHING_RODS) do
			if fishingRodData.accessorieSlots > 0 and playerInventory:getItemAmount(fishingRod) > 0 then
				table.insert(fishingRods, fishingRod)
			end
		end

		player:triggerEvent("closeInventory")
		player:triggerEvent("showEquipmentSelectionGUI", fishingRods, itemName, accessorieAmount)
		return
	end

	if itemName == "Fischlexikon" then
		local playerSpeciesCaught = player:getFishSpeciesCaught()
		player:triggerEvent("closeInventory")
		player:triggerEvent("receiveCaughtFishSpecies", Fishing.Fish, playerSpeciesCaught)
		return
	end
end

function ItemFishing:useSecondary(player, itemId, bag, place, itemName)
	if self:isFishingRod(itemName) then
		if FISHING_RODS[itemName].baitSlots > 0 then
			local fishingRodEquipments = Fishing:getSingleton():getFishingRodEquipments(player, itemName)

			player:triggerEvent("closeInventory")
			player:triggerEvent("showFishingRodGUI", itemName, {fishingRodEquipments["bait"], fishingRodEquipments["accessories"]})
			return
		else
			player:sendError(_("Diese Angel bietet keine Interaktion!", player))
		end

		return
	end

	if itemName == "Köder" then
		if self.Random:get(1, 100) <= 2 then
			player:giveAchievement(105) --Proteine?!
			player:getInventory():removeItem(itemName, 1)
			player:kill()
			return
		end

		if ItemManager.Map["KöderDummy"]:use(player) then
			player:getInventory():removeItem(itemName, 1)
		end
	end
end
