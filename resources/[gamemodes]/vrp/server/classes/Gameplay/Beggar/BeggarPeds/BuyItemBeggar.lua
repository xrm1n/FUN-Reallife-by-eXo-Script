BuyItemBeggar = inherit(BeggarPed)

function BuyItemBeggar:constructor()
end

function BuyItemBeggar:giveItem(player, item)
	if self.m_Despawning then return end
	if not player.vehicle then
		if self.m_Robber == player:getId() then return self:sendMessage(player, BeggarPhraseTypes.NoTrust) end
		if player:getInventory():getItemAmount(item) >= 1 then
			player:getInventory():removeItem(item, 1)
			player:giveCombinedReward("Bettler-Handel", {
				points = 5,
			})
			self:sendMessage(player, BeggarPhraseTypes.Thanks)
			player:meChat(true, ("übergibt %s eine Tüte"):format(self.m_Name))
			setTimer(
				function ()
					self:despawn()
				end, 50, 1
			)
		else
			player:sendError(_("Du hast kein/en %s dabei!", player, item))
		end
	else
		client:sendError(_("Steige zuerst aus deinem Fahrzeug aus!", client))
	end
end
