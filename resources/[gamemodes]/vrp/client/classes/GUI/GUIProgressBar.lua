-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIProgressBar.lua
-- *  PURPOSE:     GUI ProgressBar class
-- *
-- ****************************************************************************
GUIProgressBar = inherit(GUIElement)
inherit(GUIFontContainer, GUIProgressBar)
inherit(GUIColorable, GUIProgressBar)

function GUIProgressBar:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "", 1, VRPFont(height*.9))
	self.m_Progress = 0
	self.m_ForegroundColor = Color.Accent

	-- Does not do anything, only marks the progress bar as colorable
	GUIColorable.constructor(self, Color.White, Color.PrimaryNoClick)
end

function GUIProgressBar:setProgress(progress)
	assert(progress >= 0 and progress <= 100, "Invalid range passed to GUIProgressbar.setProgress ("..progress..")")

	self.m_Progress = progress
	self:anyChange()
	return self
end

function GUIProgressBar:getProgress()
	return self.m_Progress
end

function GUIProgressBar:setForegroundColor(color)
	self.m_ForegroundColor = color
	return self
end

function GUIProgressBar:setProgressTextEnabled(state)
	self.m_ProgressTextEnabled = state
	return self
end

function GUIProgressBar:drawThis()
	dxSetBlendMode("modulate_add")

	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)

	-- Draw actual progress bar
	local offsetHeight = 2

	dxDrawRectangle(self.m_AbsoluteX + 2, self.m_AbsoluteY + offsetHeight, (self.m_Width - 4) * self.m_Progress/100, self.m_Height - offsetHeight*2, self.m_ForegroundColor)

	-- Draw Display Text
	dxDrawText(self:getText() .. (self.m_ProgressTextEnabled and " ("..(self.m_Progress).." %)" or ""), self.m_AbsoluteX + self.m_Width/2, self.m_AbsoluteY + self.m_Height/2, nil, nil, self:getColor(), self:getFontSize(), self:getFont(), "center", "center")

	dxSetBlendMode("blend")
end

function GUIProgressBar:setAlpha(alpha)
	self.m_Alpha = alpha
	self.m_ForegroundColor = bitReplace(self.m_ForegroundColor, alpha, 24, 8)
	self.m_BackgroundColor = bitReplace(self.m_BackgroundColor, alpha, 24, 8)

	return self
end
