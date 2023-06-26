-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BreakingNews.lua
-- *  PURPOSE:     Breaking News class
-- *
-- ****************************************************************************
BreakingNews = inherit(Singleton)
addRemoteEvents{"breakingNews"}

function BreakingNews:constructor(text, title, color, titleColor)
	self.m_Width, self.m_Height = screenWidth*0.6, screenWidth/38.4
	self.m_RenderTarget = DxRenderTarget(self.m_Width, self.m_Height, true)
	self.m_FontTitle = VRPFont(self.m_Height*.7, nil, true)
	self.m_FontNews = VRPFont(self.m_Height*.7)
	self.m_ScrollEnabled = true
	self.m_Alpha = 0
	self.m_NewsOffset = 0
	self.m_News = {text}
	if color and type(color) == "table" then color = tocolor(unpack(color)) end
	self.m_Color = color or Color.LightRed
	if titleColor and type(titleColor) == "table" then titleColor = tocolor(unpack(titleColor)) end
	self.m_TitleColor = titleColor or Color.White
	self.m_Title = title or "Breaking News"
	self.m_HeaderWidth = math.floor(dxGetTextWidth(self.m_Title, 1, getVRPFont(self.m_FontTitle))+self.m_Height/2)

	self:updateRenderTarget()

	self.m_AnimationDone = bind(BreakingNews.scrollDone, self)
	self.m_Destroy = bind(BreakingNews.destroy, self)
	self.m_Render = bind(BreakingNews.render, self)

	self.m_NewsAnimation = CAnimation:new(self, self.m_AnimationDone, "m_NewsOffset")
	self.m_AnimationFade = CAnimation:new(self, "m_Alpha")
	self.m_AnimationFade:startAnimation(750, "OutQuad", 255)

	self.m_DestroyTimer = setTimer(self.m_Destroy, 10000, 1)

	addEventHandler("onClientRender", root, self.m_Render)
end

function BreakingNews:destructor()
	self.m_NewsAnimation:stopAnimation()
	self.m_AnimationFade:stopAnimation()
	if isTimer(self.m_CheckAnimation) then killTimer(self.m_CheckAnimation) end
	if isTimer(self.m_DestroyTimer) then killTimer(self.m_DestroyTimer) end
	removeEventHandler("onClientRender", root, self.m_Render)
end

function BreakingNews:destroy()
	self.m_AnimationFade:startAnimation(750, "InQuad", 0)

	self.m_DestroyTimer = setTimer(
		function()
			delete(BreakingNews:getSingleton())
		end, 800, 1
	)
end

function BreakingNews:scrollDone()
	if not isTimer(self.m_CheckAnimation) then
		self.m_CheckAnimation = setTimer(
			function()
				if (#self.m_News - 1)*self.m_Height > self.m_NewsOffset then
					self.m_NewsAnimation:startAnimation(1300, "InOutQuad", self.m_NewsOffset + self.m_Height)
				else
					self.m_ScrollEnabled = true
				end
			end, 2000, 1
		)
	end

	if isTimer(self.m_DestroyTimer) then
		self.m_DestroyTimer:reset()
	end
end

function BreakingNews:addNews(text, title, ...)
	if self.m_Title ~= title then
		delete(BreakingNews:getSingleton())
		BreakingNews:new(text, title, ...)
	end
	table.insert(self.m_News, text)

	if self.m_ScrollEnabled then
		self.m_ScrollEnabled = false
		self.m_NewsAnimation:startAnimation(1300, "InOutQuad", self.m_NewsOffset + self.m_Height)
	end

	if isTimer(self.m_DestroyTimer) then
		self.m_DestroyTimer:reset()
	end
end

function BreakingNews:updateRenderTarget()
	self.m_RenderTarget:setAsTarget(true)
	dxSetBlendMode("modulate_add")

	dxDrawRectangle(0, 0, self.m_Width, self.m_Height, self.m_Color)
	dxDrawRectangle(self.m_HeaderWidth, 2, self.m_Width-self.m_HeaderWidth-2, math.floor(self.m_Height-4), Color.White)
	--dxDrawImage(self.m_HeaderWidth, 0, math.floor(self.m_Height/4), self.m_Height, "files/images/Other/BreakingNewsArrow.png", 0, 0, 0, self.m_Color)
	dxDrawImageSection(self.m_HeaderWidth, 0, math.floor(self.m_Height/4), self.m_Height, 1, 0, 30, 120, "files/images/Other/BreakingNewsArrow.png", 0, 0, 0, self.m_Color) -- image section cause of render issues
	dxDrawText(self.m_Title, 0, 0, self.m_HeaderWidth, self.m_Height, self.m_TitleColor, 1, getVRPFont(self.m_FontTitle), "center", "center")

	for i, news in ipairs(self.m_News) do
		local offset = (i-1)*self.m_Height - self.m_NewsOffset
		dxDrawText(news, self.m_HeaderWidth+10+self.m_Height/4, offset, self.m_Width - screenWidth/20, offset + self.m_Height, Color.Black, 1, getVRPFont(self.m_FontNews), "left", "center")
	end

	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function BreakingNews:render()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/BreakingNews") end
	dxDrawImage(0, 0, self.m_Width, self.m_Height, self.m_RenderTarget, 0, 0, 0, tocolor(255, 255, 255, self.m_Alpha), true)
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/BreakingNews", 1, 1) end
end

addEventHandler("breakingNews", root,
	function(text, title, color, titleColor)
		if core:get("HUD", "breakingNewsBox", true) or title == "Admin Ankündigung" then
			if BreakingNews:isInstantiated() then
				BreakingNews:getSingleton():addNews(text, title, color, titleColor)
			else
				BreakingNews:new(text, title, color, titleColor)
			end
		end
		if core:get("HUD", "breakingNewsInChat", false) or title == "Admin Ankündigung" then
			local r, g, b = fromcolor(Color.LightRed)
			if color and type(color) == "table" then
				r, g, b = unpack(color)
			end
			outputChatBox(("[%s] #FFFFFF %s"):format(title, text, color, titleColor), r, g, b, true)
		end
	end
)
