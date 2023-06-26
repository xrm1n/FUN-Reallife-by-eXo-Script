PickupWeapon = inherit(Object)
PickupWeapon.Map = { }
local PICKUP_ANIMATION_BLOCK, PICKUP_ANIMATION_NAME = "misc", "pickup_box"

function PickupWeapon:constructor(x, y, z, int, dim, weapon, ammo, owner, ignoreHours, attachToPlayer, xOffset, yOffset)
	if WEAPON_MODELS_WORLD[weapon] then
		self.m_WeaponID = weapon
		self.m_Ammo = ammo
		if owner then
			self.m_Owner = owner.m_Id
			if owner:getFaction() then
				self.m_OwnerFaction = owner:getFaction()
			end
		end
		self.m_Entity = createPickup(x, y, z, 3, WEAPON_MODELS_WORLD[weapon], 0)
		setElementDoubleSided(self.m_Entity, true)
		setElementDimension(self.m_Entity, dim)
		setElementInterior(self.m_Entity, int)
		--[[if attachToPlayer then
			self.m_Entity:attach(owner, xOffset, yOffset, 0)
		end]]
		self.m_Entity.m_DroppedWeapon = true
		self.m_IgnoreHoursPlayed = ignoreHours
		setElementData( self.m_Entity, "pickupWeapon", true) -- just for client check-purposes
		PickupWeaponManager.Map[self.m_Entity] = self
	end
end

function PickupWeapon:pickup(player)
	if player and isElement(player) then
		if ((player:getPlayTime() / 60) >=  3) or self.m_IgnoreHoursPlayed then
			if not ( player:isFactionDuty() and player:getFaction():isStateFaction()) then
				giveWeapon(player, self.m_WeaponID, self.m_Ammo, true)
				client:sendSuccess(_("Du hast die Waffe erhalten!", client))
			else
				StateEvidence:getSingleton():addWeaponWithMunitionToEvidence(player, self.m_WeaponID, self.m_Ammo)
			end
			player:meChat(true, "kniet sich nieder und hebt eine Waffe auf!")
			setPedAnimation( player, PICKUP_ANIMATION_BLOCK, PICKUP_ANIMATION_NAME, 500, false, false, false)
			setTimer(setPedAnimation, 1000, 1, player, "carry", "crry_prtial", 200, false )
			setTimer(setPedAnimation, 1200, 1, player, false)
			delete(self)
		else
			player:sendError(_("Du hast zu wenig Spielstunden!", player))
		end
	end
end

function PickupWeapon:destructor()
	if self.m_Entity then
		if isElement(self.m_Entity) then
			destroyElement(self.m_Entity)
		end
	end
end
