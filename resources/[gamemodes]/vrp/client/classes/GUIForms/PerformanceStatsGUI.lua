-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/PerformanceStatsGUI.lua
-- *  PURPOSE:     Performance statistics GUI class
-- *
-- ****************************************************************************
PerformanceStatsGUI = inherit(GUIForm)
inherit(Singleton, PerformanceStatsGUI)

function PerformanceStatsGUI:constructor()
	self.m_Elements = {
		["player"] = "Spieler",
		["ped"] = "Peds",
		["vehicle"] = "Fahrzeuge",
		["object"] = "Objekte",
		["pickup"] = "Pickups",
		["marker"] = "Marker",
		["colshape"] = "Colshape",
		["texture"] = "Texturen",
		["shader"] = "Shader",

	}

	GUIForm.constructor(self, screenWidth-30-screenWidth*0.3, screenHeight*0.3, screenWidth*0.3, screenHeight*0.4)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Debug Tools (F10 to close)", true, false, self)
	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel({"Dx Stats", "Elements", "Cache", "Perf. Stats", "Classlib", "Network"}) -- fügt Tabs hinzu und gibt ihnen eine füllende Breite
	self.m_Fields = {}
	self.m_TabDxStats = self.m_Tabs[1]
	self:addField(self.m_TabDxStats, "VideoCardName", function() return tostring(dxGetStatus().VideoCardName) end)
	self:addField(self.m_TabDxStats, "VideoCardRAM", function() return ("%sMB"):format(dxGetStatus().VideoCardRAM) end)
	self:addField(self.m_TabDxStats, "UsedVideoMemory", function() return ("%sMB"):format(dxGetStatus().VideoCardRAM - dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField(self.m_TabDxStats, "FreeVideoMemory", function() return ("%sMB"):format(dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField(self.m_TabDxStats, "VideoMemoryUsedByRenderTargets", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByRenderTargets) end)
	self:addField(self.m_TabDxStats, "VideoMemoryUsedByTextures", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByTextures) end)
	self:addField(self.m_TabDxStats, "VideoMemoryUsedByFonts", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByFonts) end)
	self:addField(self.m_TabDxStats, "VideoCardNumRenderTargets", function() return tostring(dxGetStatus().VideoCardNumRenderTargets) end)

	self.m_TabElements = self.m_Tabs[2]
	for type, name in pairs(self.m_Elements) do
		self:addField(self.m_TabElements, name, function() return ("%d/%d"):format(#getElementsByType(type, root, true), #getElementsByType(type)) end)
	end

	self.m_TabCache = self.m_Tabs[3]
	self:addField(self.m_TabCache, "CacheTextureReplace", function() return tostring(table.size(TextureCache.Map)) end)
	self.m_TabCache.m_Gridlist = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.73, self.m_TabCache)
	self.m_TabCache.m_Gridlist:addColumn("Name", 0.85)
	self.m_TabCache.m_Gridlist:addColumn("Count", 0.15)
	self.m_TabCache.m_Gridlist:setItemHeight(math.min(self.m_Height*0.08, 20))
	self.m_TabCache.m_Gridlist:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))

	self.m_TabPerformance = self.m_Tabs[4]
	GUILabel:new(self.m_Width*0.02, 0, self.m_Width*0.7, self.m_Height*0.08, "PerformanceDump    filter:", self.m_TabPerformance)
	self.m_PerformanceEdit = GUIEdit:new(self.m_Width*0.5, self.m_Width*0.01, self.m_Width*0.48, self.m_Height*0.08-self.m_Width*0.01, self.m_TabPerformance)
	self.m_TabPerformance.m_Gridlist = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.73, self.m_TabPerformance)
	self.m_TabPerformance.m_Gridlist:addColumn("%", 0.1)
	self.m_TabPerformance.m_Gridlist:addColumn("Source", 0.75)
	self.m_TabPerformance.m_Gridlist:addColumn("Timing", 0.15)
	self.m_TabPerformance.m_Gridlist:setItemHeight(math.min(self.m_Height*0.08, 20))
	self.m_TabPerformance.m_Gridlist:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))

	self.m_TabClasslib = self.m_Tabs[5]
	self.m_TabClasslib.m_LogCheckbox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.04, "Log starten", self.m_TabClasslib)
	self.m_TabClasslib.m_LogCheckbox.onChange = function(state)
		DEBUG_MONITOR_CLASSLIB = state
	end
	self.m_TabClasslib.m_LogShowButton = GUIButton:new(self.m_Width*0.8, self.m_Width*0.01, self.m_Width*0.18, self.m_Height*0.08-self.m_Width*0.01, "Log leeren", self.m_TabClasslib)
	self.m_TabClasslib.m_LogShowButton.onLeftClick = function()
		self.m_TabClasslib.m_Gridlist:clear()
		DEBUG_MONITOR_CLASSLIB_PERFORMANCE_TABLE = {}
	end

	GUILabel:new(self.m_Width*0.35, 0, self.m_Width*0.2, self.m_Height*0.08, "Loggen ab", self.m_TabClasslib)
	self.m_TabClasslib.m_LogTimeEdit = GUIEdit:new(self.m_Width*0.55, self.m_Width*0.005, self.m_Width*0.1, self.m_Height*0.08-self.m_Width*0.01, self.m_TabClasslib)
	self.m_TabClasslib.m_LogTimeEdit:setNumeric(true, true):setMaxValue(1000):setText(DEBUG_MONITOR_CLASSLIB_TIME)
	self.m_TabClasslib.m_LogTimeEdit.onChange = function(time)
		if tonumber(time) then
			DEBUG_MONITOR_CLASSLIB_TIME = tonumber(time)
		end
	end
	GUILabel:new(self.m_Width*0.68, 0, self.m_Width*0.1, self.m_Height*0.08, "ms", self.m_TabClasslib)

	self.m_TabClasslib.m_Gridlist = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.73, self.m_TabClasslib)
	self.m_TabClasslib.m_Gridlist:addColumn("Max. exec. time", 0.20)
	self.m_TabClasslib.m_Gridlist:addColumn("Calls", 0.10)
	self.m_TabClasslib.m_Gridlist:addColumn("Source", 0.70)
	self.m_TabClasslib.m_Gridlist:setSortable{"Max. exec. time", "Calls"}
	self.m_TabClasslib.m_Gridlist:setItemHeight(math.min(self.m_Height*0.08, 20))
	self.m_TabClasslib.m_Gridlist:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))

	self.m_TabNetwork = self.m_Tabs[6]
	for ___, type in pairs({"bytesReceived", "bytesSent", "packetsReceived", "packetsSent", "packetlossTotal", "packetlossLastSecond", "messagesInSendBuffer", "messagesInResendBuffer"}) do
		self:addField(self.m_TabNetwork, type, function() return getNetworkStats()[type] end)
	end
	self:addField(self.m_TabNetwork, "Ping", function() return getPlayerPing(localPlayer) end)
	self:addField(self.m_TabNetwork, "Monitor-Warnpunkte", function() return NetworkMonitor:getSingleton():getWarnCount() end)
	self.m_RefreshTimer = false
	self:refresh()
	self:onShow()
end

function PerformanceStatsGUI:refresh()
	for parentId, parent in pairs(self.m_Fields) do
		for k, v in ipairs(parent) do
			v.label:setText(v.func())
		end
	end

	if isCursorShowing() then return end
	if self.m_TabCache.m_Gridlist then
		self.m_TabCache.m_Gridlist:clear()
		for path, data in pairs(TextureCache.Map) do
			local item = self.m_TabCache.m_Gridlist:addItem(path:gsub("files/images/Textures", ""), data:getUsage())
			item:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))
			item.onLeftDoubleClick = function()
				local blips = {}
				local text = _"Folgende Elemente benutzen diese Textur:"
				for i, instance in pairs(data.m_Instances) do
					text = ("%s\n#%d %s"):format(text, i, inspect(instance.m_Element))
					local blip = Blip:new("Marker.png", instance.m_Element.position.x, instance.m_Element.position.y, 400, BLIP_COLOR_CONSTANTS.Red)
					blip:setZ(instance.m_Element.position.z)
					blip:setDisplayText(inspect(instance.m_Element))
					table.insert(blips, blip)
				end
				ShortMessage:new(text, _("Textur Info (%s)", path:gsub("files/images/Textures", "")), Color.Red, -1, function()
					for i, v in pairs(blips) do
						v:delete()
					end
				end)
			end
		end
	end
	if self.m_TabPerformance.m_Gridlist then
		self.m_TabPerformance.m_Gridlist:clear()
		local __, f = getPerformanceStats("Lua timing", "d", self.m_PerformanceEdit:getText())
		for i, data in ipairs(f) do
			if data[2] ~= "-" then
				local item = self.m_TabPerformance.m_Gridlist:addItem(data[2], data[1], data[3])
				item:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))
				item.onLeftDoubleClick = function()
					setClipboard(data[1])
					ShortMessage:new(data[1].." in die Zwischenablage gelegt!")
				end
			end
		end
	end
	if self.m_TabClasslib.m_LogCheckbox:isChecked() then
		self:showPerfTable()
	end
end

function PerformanceStatsGUI:addField(parent, name, getFunc)
	if not self.m_Fields[parent] then self.m_Fields[parent] = {} end
	self.m_Fields[parent][#self.m_Fields[parent] + 1] = {func = getFunc}
	GUILabel:new(self.m_Width*0.02, (#self.m_Fields[parent]-1)*self.m_Height*0.08, self.m_Width*0.7, self.m_Height*0.08, name..":", parent)
	self.m_Fields[parent][#self.m_Fields[parent]].label = GUILabel:new(self.m_Width*0.50, (#self.m_Fields[parent]-1)*self.m_Height*0.08, self.m_Width*0.47, self.m_Height*0.08, "", parent):setAlignX("right")
end

function PerformanceStatsGUI:onShow()
	self.m_RefreshTimer = setTimer(bind(self.refresh, self), 1000, 0)
end

function PerformanceStatsGUI:onHide()
	if isTimer(self.m_RefreshTimer) then killTimer(self.m_RefreshTimer) end
	self.m_RefreshTimer = false
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		PerformanceStatsGUI:new():setVisible(false)
		bindKey(core:get("KeyBindings", "KeyTogglePerformanceStats", "F10"), "down",
			function()
				PerformanceStatsGUI:getSingleton():setVisible(not PerformanceStatsGUI:getSingleton():isVisible())
				PerformanceStatsGUI:getSingleton().m_TabElements:setEnabled(localPlayer:getRank() >= ADMIN_RANK_PERMISSION["showDebugElementView"])
				PerformanceStatsGUI:getSingleton().m_TabPerformance:setEnabled(localPlayer:getRank() >= 1)
				PerformanceStatsGUI:getSingleton().m_TabClasslib:setEnabled(localPlayer:getRank() >= 3)
			end
		)
	end
)

function PerformanceStatsGUI:showPerfTable()
	self.m_TabClasslib.m_Gridlist:clear()
	for func, stats in pairs(DEBUG_MONITOR_CLASSLIB_PERFORMANCE_TABLE) do
		local execTime = ("%d ms"):format(stats.longestExecutionTime)
		local info = debug.getinfo(func, "Sl")
		local pathTable = split(info.short_src, '\\')
		local source = ("%s:%d"):format(pathTable[#pathTable], info.linedefined)
		local item = self.m_TabClasslib.m_Gridlist:addItem(execTime, stats.timesCalled, source)
		item:setColumnColor(1, stats.longestExecutionTime >= 10 and Color.Yellow or stats.longestExecutionTime >= 50 and Color.Orange or stats.longestExecutionTime >= 100 and Color.Red or Color.Green)
	end
end