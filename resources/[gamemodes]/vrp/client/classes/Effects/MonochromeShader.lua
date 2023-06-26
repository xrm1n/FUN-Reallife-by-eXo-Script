-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/MonochromeShaderShader.lua
-- *  PURPOSE:     MonochromeShader shader class 
-- *
-- ****************************************************************************
MonochromeShader = inherit(Object)

function MonochromeShader:constructor(external)
	self.m_External = external
	self.m_MonochromeShader = dxCreateShader("files/shader/monochrome.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
    self.m_Active = true
    self.m_Color = tocolor(255, 255, 255, 255)
	self.m_Update = bind(self.update, self)
	if not external then
		addEventHandler("onClientPreRender", root, self.m_Update)
	end
end

function MonochromeShader:update()
	if self.m_MonochromeShader and self.m_ScreenSource and self.m_Active then
		self.m_ScreenSource:update()

		self.m_MonochromeShader:setValue("ScreenTexture", self.m_ScreenSource)
		
		self.m_Ready = true
		if not self.m_External then
			dxDrawImage(0, 0, screenWidth, screenHeight, self.m_MonochromeShader, 0, 0, 0, self.m_Color)
		end
	end
end

function MonochromeShader:setActive(bool)
    self.m_Active = bool
end

function MonochromeShader:hide()
    self.m_Active = false
end

function MonochromeShader:show()
    self.m_Active = true
end

function MonochromeShader:setAlpha(alpha)
    alpha =  alpha/255
    alpha = alpha * 0.35
    self.m_MonochromeShader:setValue("luminanceFloat", alpha)  
end

function MonochromeShader:destructor()
	if self.m_MonochromeShader then
		destroyElement(self.m_MonochromeShader)
	end
	if self.m_ScreenSource then
		destroyElement(self.m_ScreenSource)
	end
	removeEventHandler("onClientPreRender", root, self.m_Update)
	self.m_Update = nil
end

function MonochromeShader:flash()
	self.m_Active = true
	self:setAlpha(255)
    setTimer(function() 
        Animation.FadeOut:new(self, 500)
    end, 300, 1)
end

function MonochromeShader:getSource() return self.m_MonochromeShader end
