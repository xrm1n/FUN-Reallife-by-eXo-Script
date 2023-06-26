HighStakeRouletteGUI = inherit(GUIForm)
inherit(Singleton, HighStakeRouletteGUI)

function HighStakeRouletteGUI:constructor(customBank)
    GUIForm.constructor(self, screenWidth/2-330/2, 5, 330, 105, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "High-Stake Roulette", true, true, self)
	self.m_Window:deleteOnClose(true)

    self.m_SpinButton = GUIButton:new(10, 40, 150, 25, "Drehen", self.m_Window)
    self.m_SpinButton.onLeftClick = function()
        HighStakeRoulette:getSingleton():spin()
    end

    self.m_ClearTokens = GUIButton:new(10, 70, 150, 25, "Jetons entfernen", self.m_Window)
    self.m_ClearTokens.onLeftClick = function()
        HighStakeRoulette:getSingleton():clearTokens(true)
    end
--[[
    self.m_CheatEdit = GUIEdit:new(130, 100, 40, 25, self.m_Window)
    self.m_CheatSpin = GUIButton:new(170, 100, 150, 25, "Cheat-Spin", self.m_Window):setColor(Color.Red)
    self.m_CheatSpin.onLeftClick = function()
        Roulette:getSingleton():cheatSpin(tonumber(self.m_CheatEdit:getText()))
    end
]]
    self.m_BetLabel = GUILabel:new(170, 40, 150, 25, "Gesamter Einsatz:\n0$", self.m_Window):setMultiline(true)

    triggerServerEvent("highStakeRouletteCreateNew", localPlayer, customBank)
end

function HighStakeRouletteGUI:virtual_destructor()
	triggerServerEvent("highStakeRouletteDelete", localPlayer)
end
