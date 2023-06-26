-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDKart.lua
-- *  PURPOSE:     Race HUD class
-- *
-- ****************************************************************************
HUDKart = inherit(Singleton)
addRemoteEvents{"showRaceHUD", "HUDRaceUpdate", "HUDRaceUpdateDelta", "HUDRaceUpdateTimes"}

function HUDKart:constructor(showPersonalTrackStats)
	self.m_Width, self.m_Height = 250*screenWidth/1920, 52*screenHeight/1080
	self.m_PosX, self.m_PosY = screenWidth/2-self.m_Width/2, 0
	self.m_RenderTarget = DxRenderTarget(self.m_Width, self.m_Height, true)

	self.m_FontMain =  VRPFont(self.m_Height*0.6)
	self.m_FontRespawn = VRPFont(25)
	self.m_FontStats = VRPFont(29)
	self.m_FontLaps = VRPFont(39)

	if showPersonalTrackStats then
		self.m_TS_Size = Vector2(300, 100)
		self.m_TrackStats = DxRenderTarget(self.m_TS_Size, true)
	end

	self:updateRenderTarget()

	HUDRadar:getSingleton():hide()
	HUDUI:getSingleton():hide()

	self.m_Render = bind(HUDKart.render, self)
	addEventHandler("onClientRender", root, self.m_Render)
end

function HUDKart:destructor()
	HUDRadar:getSingleton():show()
	HUDUI:getSingleton():show()
	removeEventHandler("onClientRender", root, self.m_Render)
end

function HUDKart:setStartTick(startTick)
	self.m_StartTick = startTick and getTickCount() or false
end

function HUDKart:setLaps(laps)
	self.m_Laps = laps and laps or self.m_Laps
end

function HUDKart:setSelectedLaps(laps)
	self.m_SelectedLaps = laps and laps or self.m_SelectedLaps
end

function HUDKart:setDelta(delta)
	if delta then
		self.m_DeltaTime = (delta > 0 and "+%s" or "-%s"):format(timeMsToTimeText(math.abs(delta), true))
		self.m_DeltaColor = delta > 0 and Color.Red or Color.Green

		if isTimer(self.m_DeltaTimer) then self.m_DeltaTimer:destroy() end
		self.m_DeltaTimer = setTimer(function() self.m_DeltaTime = false end, 5000, 1)
	end
end

function HUDKart:update(startTick, laps, delta)
	--self.m_StartTick = startTick and getTickCount() or false
	--self.m_Laps = laps and laps or self.m_Laps

	--[[if delta then
		self.m_DeltaTime = (delta > 0 and "+%s" or "-%s"):format(timeMsToTimeText(math.abs(delta), true))
		self.m_DeltaColor = delta > 0 and Color.Red or Color.Green

		if isTimer(self.m_DeltaTimer) then self.m_DeltaTimer:destroy() end
		self.m_DeltaTimer = setTimer(function() self.m_DeltaTime = false end, 5000, 1)
	end]]
end

function HUDKart:updateTimes(toptimes, playerID)
	self.m_BestTime = toptimes[1]

	for k, v in pairs(toptimes) do
		if v.PlayerID == playerID then
			self.m_PersonalBestTime = v.time
			return
		end
	end
end

function HUDKart:updateRenderTarget()
	self.m_RenderTarget:setAsTarget(true)
	dxDrawRectangle(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200))
	dxDrawRectangle(0, 0, self.m_Width, 5, Color.Accent)

	dxDrawText("Aktuell", 0, 5, self.m_Width/2, self.m_Height/2 + 5, Color.White, 1, getVRPFont(self.m_FontMain), "center", "center")
	dxDrawText("Beste", self.m_Width/2, 5, self.m_Width, self.m_Height/2 + 5, Color.White, 1, getVRPFont(self.m_FontMain), "center", "center")

	dxDrawText(self.m_Time and timeMsToTimeText(self.m_Time) or "--.---", 0, self.m_Height/2, self.m_Width/2, self.m_Height, Color.White, 1, getVRPFont(self.m_FontMain), "center", "center")
	dxDrawText(self.m_BestTime and timeMsToTimeText(self.m_BestTime.time) or "--.---", self.m_Width/2, self.m_Height/2, self.m_Width, self.m_Height, Color.White, 1, getVRPFont(self.m_FontMain), "center", "center")

	dxSetRenderTarget()

	if not self.m_TrackStats then return end
	self.m_TrackStats:setAsTarget(true)
	dxDrawRectangle(0, self.m_TS_Size.y-28*2-5, self.m_TS_Size.x, 28, tocolor(0, 0, 0, 200))
	dxDrawText("Deine Bestzeit", 0, self.m_TS_Size.y-28*2-5, self.m_TS_Size.x - 5, 28, Color.White, 1, getVRPFont(self.m_FontStats), "right")
	dxDrawText(self.m_PersonalBestTime and timeMsToTimeText(self.m_PersonalBestTime) or "--.---", 5, self.m_TS_Size.y-28*2-5, self.m_TS_Size.x - 5, 28, Color.White, 1, getVRPFont(self.m_FontStats))

	if self.m_DeltaTime then
		dxDrawRectangle(0, self.m_TS_Size.y-28, self.m_TS_Size.x, 28, self.m_DeltaColor)
		dxDrawText("Delta", 0, self.m_TS_Size.y-28, self.m_TS_Size.x - 5, 28, Color.White, 1, getVRPFont(self.m_FontStats), "right")
		dxDrawText(self.m_DeltaTime and self.m_DeltaTime or "--.---", 5, self.m_TS_Size.y-28, self.m_TS_Size.x - 5, 28, Color.White, 1, getVRPFont(self.m_FontStats))
	end

	dxDrawText(self.m_Laps and ("R %d | %d"):format(self.m_Laps, self.m_SelectedLaps) or "--", 0, 0, self.m_TS_Size.x, self.m_TS_Size.y, Color.White, 1, getVRPFont(self.m_FontLaps), "right")

	dxSetRenderTarget()
end

function HUDKart:render()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/Kart") end
	if self.m_StartTick then
		self.m_Time = getTickCount() - self.m_StartTick
	end

	self:updateRenderTarget()
	dxDrawImage(self.m_PosX, self.m_PosY, self.m_Width, self.m_Height, self.m_RenderTarget)

	if self.m_TrackStats then
		dxDrawImage(screenWidth - self.m_TS_Size.x - 10, 10, self.m_TS_Size, self.m_TrackStats)
	end

	if self.m_ShowRespawnLabel then
		dxDrawText("Drücke 'x' zum respawnen!", 0, screenHeight - 25, screenWidth, 0, Color.White, 1, getVRPFont(self.m_FontRespawn), "center")
	end

	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Kart", 1, 1) end
end

addEventHandler("HUDRaceUpdateTimes", root,
	function(...)
		HUDKart:getSingleton():updateTimes(...)
	end
)

addEventHandler("HUDRaceUpdate", root,
	function(...)
		HUDKart:getSingleton():update(...)
	end
)

addEventHandler("HUDRaceUpdateDelta", root,
	function(delta)
		HUDKart:getSingleton():setDelta(delta)
	end
)

addEventHandler("showRaceHUD", root,
	function(show, ...)
		if show then
			HUDKart:new(...)
		else
			delete(HUDKart:getSingleton())
		end
	end
)
