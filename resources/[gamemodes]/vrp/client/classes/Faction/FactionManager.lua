-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Faction Client
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)
FactionManager.Map = {}

function FactionManager:constructor()
	triggerServerEvent("getFactions", localPlayer)

	self.m_NeedHelpBlip = {}
	self.m_YakuzaTextures = {}

    addRemoteEvents{"loadClientFaction", "factionStateStartCuff","stateFactionOfferTicket"; "updateCuffImage","playerSelfArrest", "factionEvilStartRaid","SpeedCam:showSpeeder", 
        "factionForceOffduty", "startAreaAlert", "stopAreaAlert", "playAreaAlertMessage", "onClientDiplomacyReceive", "startFactionRespawnAnnouncement", "stopFactionRespawnAnnoucement"}
	addEventHandler("loadClientFaction", root, bind(self.loadFaction, self))
	addEventHandler("factionStateStartCuff", root, bind(self.stateFactionStartCuff, self))
	addEventHandler("factionEvilStartRaid", root, bind(self.factionEvilStartRaid, self))
	addEventHandler("stateFactionOfferTicket", root, bind(self.stateFactionOfferTicket, self))
	addEventHandler("updateCuffImage", root, bind(self.Event_onPlayerCuff, self))
	addEventHandler("playerSelfArrest", localPlayer, bind(self.Event_selfArrestMarker, self))
	addEventHandler("SpeedCam:showSpeeder", localPlayer, bind(self.Event_OnSpeederCatch,self))
	addEventHandler("factionForceOffduty", localPlayer, bind(self.factionForceOffduty, self))
	addEventHandler("startAreaAlert", localPlayer, bind(self.startAreaAlert, self))
	addEventHandler("stopAreaAlert", localPlayer, bind(self.stopAreaAlert, self))
    addEventHandler("playAreaAlertMessage", localPlayer, bind(self.playAreaAlertMessage, self))
    addEventHandler("onClientDiplomacyReceive", localPlayer, bind(self.receiveDiplomacies, self))
    addEventHandler("startFactionRespawnAnnouncement", localPlayer, bind(self.startRespawnAnnouncement, self))
    addEventHandler("stopFactionRespawnAnnoucement", localPlayer, bind(self.stopRespawnAnnoucement, self))

	self.m_DrawSpeed = bind(self.OnRenderSpeed, self)
	self.m_DrawCuffFunc = bind(self.drawCuff, self)
	self.m_RaidBind = bind(self.endEvilFactionRaidOnDeath, self)

	for key, element in pairs(getElementsByType("object")) do
		local x, y, z = getElementPosition(element)
		if getDistanceBetweenPoints3D(985.142, -1123.313, 23.818, x, y, z) < 100 then
			if element:getModel() == 16500 then
				self:loadYakuzaTexture(element)
			elseif element:getModel() == 3531 then 
				self:loadYakuzaSign(element)
			end
		end
	end
end

function FactionManager:loadFaction(Id, name, name_short, rankNames, factionType, color, navigationPosition, diplomacy)
	FactionManager.Map[Id] = Faction:new(Id, name, name_short, rankNames, factionType, color, navigationPosition, diplomacy)
end

function FactionManager:stateFactionStartCuff( target )
	if target then
		local timer = localPlayer.stateCuffTimer
		if timer then
			if isTimer(timer) then
				killTimer(timer)
			end
		end
		localPlayer.m_CuffTarget = target
		localPlayer.stateCuffTimer = setTimer( self.endStateFactionCuff, 10000, 1)
	end
end


function FactionManager:factionEvilStartRaid(target)
	if target then
		local timer = localPlayer.evilRaidTimer
		if timer then
			if isTimer(timer) then
				killTimer(timer)
			end
		end
		localPlayer.m_evilRaidTarget = target
		localPlayer.evilRaidTimer = setTimer(bind(self.endEvilFactionRaid, self), 15000, 1)

		addEventHandler("onClientPlayerWasted", localPlayer, self.m_RaidBind)
	end
end

function FactionManager:endEvilFactionRaid()
	local target = localPlayer.m_evilRaidTarget
	if target then
		if getDistanceBetweenPoints3D(target:getPosition(), localPlayer:getPosition()) <= 5 then
			triggerServerEvent("factionEvilSuccessRaid", localPlayer, localPlayer.m_evilRaidTarget)
		else
			triggerServerEvent("factionEvilFailedRaid", localPlayer, localPlayer.m_evilRaidTarget)
		end
	end
	removeEventHandler("onClientPlayerWasted", localPlayer, self.m_RaidBind)
end

function FactionManager:endEvilFactionRaidOnDeath()
	triggerServerEvent("factionEvilFailedRaid", localPlayer, localPlayer.m_evilRaidTarget)
	removeEventHandler("onClientPlayerWasted", localPlayer, self.m_RaidBind)
end

function FactionManager:Event_onPlayerCuff( bool )
	removeEventHandler("onClientRender",root, self.m_DrawCuffFunc)
	if bool then
		addEventHandler("onClientRender",root, self.m_DrawCuffFunc)
	end
end

function FactionManager:drawCuff()
	dxDrawImage(screenWidth*0.88, screenHeight - screenWidth*0.1, screenWidth*0.08,screenWidth*0.0436,"files/images/Other/cuff.png")
end

function FactionManager:Event_selfArrestMarker( client )
	if not localPlayer.m_selfArrest then
		localPlayer.m_selfArrest = true
		QuestionBox:new(
			_"Möchtest du dich mit Kaution stellen?",
			function ()
				triggerServerEvent("playerSelfArrestConfirm", root )
				localPlayer.m_selfArrest = false
			end,
			function ()
				localPlayer.m_selfArrest = false
			end,
			localPlayer.position
		)
	end
end

function FactionManager:Event_OnSpeederCatch( speed, vehicle)
	removeEventHandler("onClientRender", root, self.m_DrawSpeed)
	local now = getTickCount()
	self.m_SpeedCamSpeed = speed
	self.m_SpeedCamVehicle = vehicle
	self.m_DrawStart = now + 2000
	self.m_RemoveDraw = self.m_DrawStart + 5000
	self.m_bLineChecked = false
	self.m_PlaySoundOnce = false
	self.m_PlaySoundSnap = false
	addEventHandler("onClientRender", root, self.m_DrawSpeed)
end

function FactionManager:OnRenderSpeed()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("3D/SpeedCamText") end
	local now = getTickCount()
	if now <= self.m_RemoveDraw then
		if now >= self.m_DrawStart then
			if self.m_SpeedCamSpeed and self.m_SpeedCamVehicle then
				if self.m_bLineChecked == self.m_SpeedCamVehicle then
					local speed = math.floor(self.m_SpeedCamSpeed)
					local vName = self.m_SpeedCamVehicle:getName()
					local occ = getVehicleOccupant(self.m_SpeedCamVehicle)
					local c1, c2 = getVehicleColor(self.m_SpeedCamVehicle)
					local colName = getColorNameFromVehicle(c1, c2)
					local text = ("Radar: %s fährt %s km/h in %sem %s!"):format(occ and occ:getName() or "-", speed, colName, vName)

					if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/SpeedCamText", true) end
					dxDrawText(text, 0, 1, screenWidth, screenHeight*0.8+1, tocolor(0,0,0,255), 2, "default-bold", "center", "bottom")
					dxDrawText(text, 1, 1, screenWidth+1, screenHeight*0.8+1, tocolor(0,0,0,255), 2, "default-bold", "center", "bottom")
					dxDrawText(text, 0, 0, screenWidth, screenHeight*0.8, tocolor(0,150,0,255), 2, "default-bold" ,"center", "bottom")

					local speeder = getVehicleOccupant(self.m_SpeedCamVehicle)
					if speeder then
						local px,py,pz = getPedBonePosition(speeder,8)
						local dx,dy = getScreenFromWorldPosition(px,py,pz)
						if dx and dy then
							dxDrawText(("%s km/h"):format(speed), dx, dy+1, dx, dy+1, tocolor(0,0,0,255), 1, "default-bold")
							dxDrawText(("%s km/h"):format(speed), dx, dy, dx, dy, tocolor(230,0,0,255), 1, "default-bold")
						end
					end

					if not self.m_PlaySoundOnce then
						playSoundFrontEnd(5)
						self.m_PlaySoundOnce = true
					end
				else
					local localVeh = getPedOccupiedVehicle(localPlayer)
					if localVeh then
						local speeder = getVehicleOccupant(self.m_SpeedCamVehicle)
						if speeder then
							local x,y,z = getElementPosition(localVeh)
							local px,py,pz = getPedBonePosition(speeder,8)
							local bLineCheck = isLineOfSightClear (x, y, z, px, py, pz, true, false, false, true)
							if bLineCheck then
								self.m_bLineChecked = self.m_SpeedCamVehicle
								self.m_RemoveDraw = self.m_DrawStart + 10000
							end
						end
					end
				end
			end
		else
			if self.m_SpeedCamSpeed and self.m_SpeedCamVehicle then
				local localVeh = getPedOccupiedVehicle(localPlayer)
				if localVeh then
					local speeder = getVehicleOccupant(self.m_SpeedCamVehicle)
					if speeder then
						local x,y,z = getElementPosition(localVeh)
						local px,py,pz = getPedBonePosition(speeder,8)
						local bLineCheck = isLineOfSightClear (x, y, z, px, py, pz, true, false, false, true)
						if bLineCheck then
							self.m_bLineChecked = self.m_SpeedCamVehicle
							self.m_RemoveDraw = self.m_DrawStart + 10000
							if not self.m_PlaySoundSnap then
								playSound("files/audio/speedcam.ogg")
								self.m_PlaySoundSnap = true
							end
						end
					end
				end
			end
		end
	else
		removeEventHandler("onClientRender", root, self.m_DrawSpeed)
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("3D/SpeedCamText") end
end

function FactionManager:stateFactionOfferTicket( cop )
	ShortMessage:new(_("%s bietet dir ein Ticket für den Erlass eines Wanteds für %s an. Klicke hier um es anzunehmen!", cop:getName(), toMoneyString(TICKET_PRICE*localPlayer:getWanteds()+500)), "Wanted-Ticket", Color.DarkLightBlue, 30000)
	.m_Callback = function (this)	triggerServerEvent("factionStateAcceptTicket", localPlayer, cop); delete(this)	end

end

function FactionManager:endStateFactionCuff( )
	if localPlayer.m_CuffTarget then
		if getDistanceBetweenPoints3D( localPlayer.m_CuffTarget:getPosition(), localPlayer:getPosition()) <= 5 then
			triggerServerEvent("stateFactionSuccessCuff", localPlayer,localPlayer.m_CuffTarget)
		end
	end
end

function FactionManager:getFromId(id)
	return FactionManager.Map[id]
end

function FactionManager:getFromName(name)
	for i, faction in pairs(self.Map) do
		if faction.m_NameShort == name then
			return faction
		end
	end
end

function FactionManager:getFactionNames()
	local table = {}
	for id, faction in pairs(FactionManager.Map) do
		table[id] = faction:getShortName()
	end
	return table
end

function FactionManager:factionForceOffduty()
	if localPlayer:getPublicSync("Faction:Duty") and localPlayer:getFaction() then
		if localPlayer:getFaction():isStateFaction() then
			triggerServerEvent("factionStateToggleDuty", localPlayer, true, false, true)
		elseif localPlayer:getFaction():isRescueFaction() then
			triggerServerEvent("factionRescueToggleDuty", localPlayer, false, true, false, true)
		elseif localPlayer:getFaction():isEvilFaction() then
			triggerServerEvent("factionEvilToggleDuty", localPlayer, true, false, true)
		end
	end
end

function FactionManager:startAreaAlert()
	self.m_AreaAlertTimer = setTimer(
		function()
			local sound = playSFX3D("script", 20, 1, 211.55, 1810.88, 25.12)
			if sound then 
				sound:setVolume(5)
				sound:setMaxDistance(300)
			end
		end, 1800, 0)
	self:playAreaAlertMessage("red", 12)
	self.m_AreaMessageTimer = setTimer(
		function()
			local rndm = math.random(1, 3)
			if rndm == 1 then
				self:playAreaAlertMessage("red")
			else
				self:playAreaAlertMessage("towercommands")
			end
		end, 10000, 0)
end

function FactionManager:playAreaAlertMessage(type, forceId)
	if type == "blue" then
		SoundId = math.random(1, 4)
	end
	if type == "normalized" then
		SoundId = math.random(5, 8)
	end
	if type == "red" then
		SoundId = math.random(9, 12)
	end
	if type == "lockdown" then
		SoundId = math.random(13, 16)
	end
	if type == "towercommands" then
		SoundId = math.random(17, 18)
	end
	if forceId then
		SoundId = forceId
	end
	local sound = PoliceAnnouncements:getSingleton():playSound("script", 58, SoundId, 211.55, 1810.88, 25.12)
	if sound then 
		sound:setVolume(5)
		sound:setMaxDistance(300)
	end
end

function FactionManager:stopAreaAlert()
	if isTimer(self.m_AreaAlertTimer) then
		killTimer(self.m_AreaAlertTimer)
	end
	if isTimer(self.m_AreaMessageTimer) then
		killTimer(self.m_AreaMessageTimer)
	end
	setTimer(
		function()
			self:playAreaAlertMessage("normalized", 6)
		end
	, 7500, 1)
end

function FactionManager:loadYakuzaTexture(element)
	self.m_YakuzaTextures[element] = FileTextureReplacer:new(element, "Faction/Yakuza/comptwall3.jpg", "drvin_back", {}, true, true)
end

function FactionManager:loadYakuzaSign(element)
	self.m_YakuzaTextures[element] = FileTextureReplacer:new(element, "Faction/Yakuza/FourDragons01_256.jpg", "FourDragons01_256", {}, true, true)
end

function FactionManager:unloadYakuzaTextures()
	for key, texture in pairs(self.m_YakuzaTextures) do
		delete(texture)
	end
end

function FactionManager:receiveDiplomacies(diplomacies)
    for factionId, diplomacy in pairs(diplomacies) do
        if FactionManager.Map[factionId] then
            FactionManager.Map[factionId]:setDiplomacy(diplomacy)
        end
    end
end

function FactionManager:startRespawnAnnouncement(announcer)
	if localPlayer:getFaction() then
		localPlayer:getFaction():startRespawnAnnouncement(announcer)
	end
end

function FactionManager:stopRespawnAnnoucement(stopper)
	if localPlayer:getFaction() then
		localPlayer:getFaction():stopRespawnAnnoucement(stopper)
	end
end