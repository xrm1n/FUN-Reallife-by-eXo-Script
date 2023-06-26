-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/NetworkMonitor.lua
-- *  PURPOSE:     Class to monitor the network-status
-- *
-- ****************************************************************************
NetworkMonitor = inherit(Singleton)

NETWORK_MONITOR_INTERVAL = 250 --// ms
NETWORK_PACKET_LOSS_THRESHOLD = 5   --// loss%
NETWORK_PACKET_LOSS_OVER_ALL_THRESHOLD = 70 --// loss%
MAX_PING_THRESHOLD = 300 --// %
MIN_PING_TRIGGER = 400 --// ms

NETWORK_MONITOR_CONTROLS = {
	"fire",
	"aim_weapon",
	"crouch",
	"forwards",
	"backwards",
	"left",
	"right",
	"crouch",
}

function NetworkMonitor:constructor()
    self.m_NetMonitor = setTimer( bind(self.monitor, self), NETWORK_MONITOR_INTERVAL, 0)
    self.m_Ping = 0
    self.m_PingAverage = 0
    self.m_PingCount = 0
    self.m_LastOutput = getTickCount()
    self.m_LastPingOutput = getTickCount()
    self.m_WarnCount = 0

	self.m_ControlsModifiedHook = Hook:new()
end

function NetworkMonitor:getHook()
	return self.m_ControlsModifiedHook
end

function NetworkMonitor:monitor()
    local loss = self:check("packetlossLastSecond") or self:check("packetlossTotal")
    if loss then
        if getTickCount() >= self.m_LastOutput + 15000 then
            self.m_LastOutput = getTickCount()
            outputChatBox(_("[Network] #ffffffDeine Handlung wird eingeschränkt, aufgrund eines sehr hohen Paketverlustes: #ff0000%s%%", math.ceil(loss, 2)), 255, 0, 0, true)
        end
    end
    local ping = self:ping()
    if ping then
        if getTickCount() >= self.m_LastPingOutput + 15000 then
            self.m_LastPingOutput = getTickCount()
            outputChatBox(_("[Network] #ffffffDeine Handlung wird eingeschränkt, aufgrund einer sehr hohen Pingschwankung: #ff0000%s ms", MIN_PING_TRIGGER+math.ceil(self.m_PingAverage, 2)), 255, 0, 0, true)
        end
    end
    if self.m_LastAct and (getTickCount() - self.m_LastAct) > 2000 and (not ping and not loss) then
        self.m_WarnCount = self.m_WarnCount - 1
    end
    if self.m_WarnCount < 0 then self.m_WarnCount = 0 end
end

function NetworkMonitor:getPingDisabled()
    return self.m_PingDisabled
end


function NetworkMonitor:getLossDisabled()
    return self.m_ActionsDisabled
end

function NetworkMonitor:ping()
    self.m_Ping = self.m_Ping + getPlayerPing(localPlayer)
    self.m_PingCount = self.m_PingCount + 1
    local lastAverage = self.m_PingAverage
    local ping = getPlayerPing(localPlayer) > 0 and getPlayerPing(localPlayer) or 1
    self.m_PingAverage = self.m_Ping / self.m_PingCount
    if ping > MIN_PING_TRIGGER and self.m_PingAverage > 0 and self.m_PingAverage < ping then
        if ( ping / self.m_PingAverage )*100 > MAX_PING_THRESHOLD then
            self.m_WarnCount = self.m_WarnCount + 1
            self.m_LastAct = getTickCount()
            if not self.m_PingDisabled then
                if self.m_WarnCount > 15 then
                    self.m_PingDisabled = true
                    self:disableActions()
                    return true
                end
            end
        else
            if self.m_PingDisabled then
                self:enableActions()
                self.m_WarnCount = 0
                self.m_PingDisabled = false
            end
        end
    else
        if self.m_PingDisabled then
            self.m_PingDisabled = false
            self:enableActions()
            self.m_WarnCount = 0
        end
    end
    if self.m_PingCount > 2000 then
        self.m_PingCount = 0
        self.m_Ping = 0
        self.m_PingAverage = 0
    end
    return false
end

function NetworkMonitor:check( type )
    local loss =  getNetworkStats()[type]
    local limit = type == "packetlossLastSecond" and NETWORK_PACKET_LOSS_THRESHOLD or NETWORK_PACKET_LOSS_OVER_ALL_THRESHOLD
    if loss and loss > limit then
        self.m_WarnCount = self.m_WarnCount + 1
        self.m_LastAct = getTickCount()
        if not self.m_ActionsDisabled then
            if self.m_WarnCount >  15 then
                self.m_ActionsDisabled = true
                self:disableActions()
                return loss
            end
        end
    else
        if self.m_ActionsDisabled then
            self.m_ActionsDisabled = false
            if not self.m_PingDisabled then
                self:enableActions()
                self.m_WarnCount  = 0
            end
        end
    end
    return false
end

function NetworkMonitor:disableActions()
	for _, control in pairs(NETWORK_MONITOR_CONTROLS) do
		toggleControl(control, false)
	end
	setPedWeaponSlot(localPlayer, 0)

	self.m_ControlsModifiedHook:call(false)
end

function NetworkMonitor:enableActions()
	setTimer(
		function()
			for _, control in pairs(NETWORK_MONITOR_CONTROLS) do
				toggleControl(control, true)
			end

			self.m_ControlsModifiedHook:call(true)
		end, 500, 1
	)
end

function NetworkMonitor:getWarnCount()
    return self.m_WarnCount
end
