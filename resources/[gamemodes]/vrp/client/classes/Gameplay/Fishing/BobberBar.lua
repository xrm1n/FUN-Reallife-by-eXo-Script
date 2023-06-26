-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Fishing/BobberBar.lua
-- *  PURPOSE:     BobberBar class
-- *
-- ****************************************************************************
BobberBar = inherit(Singleton)
addRemoteEvents{"fishingBobberBar"}

function BobberBar:constructor(fishData, fishingRodName, baitName, accessorieName)
	self.m_FisherLevel = localPlayer:getPrivateSync("FishingLevel") + 1

	self.m_Size = Vector2(58, screenHeight/2)
	self.m_RenderTarget = DxRenderTarget(self.m_Size, true)
	self.m_AnimationMultiplicator = 0

	self.Sound = SoundManager:new("files/audio/Fishing")
	self.Random = Randomizer:new()

	self.m_Difficulty = math.max(MIN_FISHING_DIFFICULTY, fishData.Difficulty - FISHING_BAITS[baitName].difficultyReduction - FISHING_RODS[fishingRodName].difficultyReduction - FISHING_ACCESSORIES[accessorieName].difficultyReduction)
	self.m_MotionType = self:getMotionType(fishData.Behavior)

	self.m_BobberBarHeight = ((64 + self.m_FisherLevel*4 - self.m_Difficulty/10)*FISHING_ACCESSORIES[accessorieName].bobberBarHeightMultiplier) / 1080 * screenHeight
	self.m_BobberBarPosition = self.m_Size.y - self.m_BobberBarHeight - 5
	self.m_BobberBarSpeed = 0

	self.POSITION_UP = 5
	self.POSITION_DOWN = self.m_Size.y - 5
	self.HEIGHT = self.POSITION_DOWN - self.POSITION_UP
	self.MAX_PUSHBACK_SPEED = 6

	self.m_BobberPosition = self.Random:get(0, 100) / 100 * self.HEIGHT
	self.m_BobberSpeed = 0
	self.m_BobberTargetPosition = 0
	self.m_BobberInBar = nil

	self.m_Progress = self.Random:get(15, 35)
	self.m_ProgressDifficultyAddition = self.m_Difficulty*20
	self.m_ProgressDuration = 10000 + self.m_ProgressDifficultyAddition

	self:initAnimations()
	self:updateRenderTarget()

	self.m_Render = bind(BobberBar.render, self)
	self.m_HandleClick = bind(BobberBar.handleClick, self)
	self.m_toggleControls = bind(BobberBar.toggleControls, self)

	self.m_toggleControls(true)

	bindKey("mouse1", "both", self.m_HandleClick)
	addEventHandler("onClientRender", root, self.m_Render)

	self:setBobberPosition()
	self.m_FadeAnimation:startAnimation(500, "OutQuad", 1)

	NetworkMonitor:getSingleton():getHook():register(self.m_toggleControls)
end

function BobberBar:destructor()
	removeEventHandler("onClientRender", root, self.m_Render)
	unbindKey("mouse1", "both", self.m_HandleClick)
	self.Sound:stopAll()

	if self.m_FadeAnimation:isAnimationRendered() then delete(self.m_FadeAnimation) end
	if self.m_BobberAnimation:isAnimationRendered() then delete(self.m_BobberAnimation) end
	if self.m_ProgressAnimation:isAnimationRendered() then delete(self.m_ProgressAnimation) end

	if isTimer(self.m_ResetFishingRodTimer) then killTimer(self.m_ResetFishingRodTimer) end

	NetworkMonitor:getSingleton():getHook():unregister(self.m_toggleControls)
end

function BobberBar:initAnimations()
	local onProgressDone =
		function()
			if self.m_Progress%100 == 0 then
				self.m_ProgressDuration = 0
				self.m_BobberAnimation:stopAnimation()
				self.m_ProgressAnimation:stopAnimation()
				self.Sound:stop("slowReel")

				if self.m_Progress == 100 then
					self.Sound:play("caught")
					self.Sound:play("woap")
					triggerServerEvent("clientFishCaught", localPlayer)
				else
					self.Sound:play("escape")
					triggerServerEvent("clientFishEscape", localPlayer)
				end

				self.m_FadeAnimation:startAnimation(500, "OutQuad", 0)

				self.m_ResetFishingRodTimer = setTimer(
					function()
						delete(self)

						if FishingRod:isInstantiated() then
							FishingRod:getSingleton():reset()
						end
					end, 2000, 1
				)
			end
		end

	self.m_FadeAnimation = CAnimation:new(self, "m_AnimationMultiplicator")
	self.m_BobberAnimation = CAnimation:new(self, bind(BobberBar.setBobberPosition, self), "m_BobberPosition")
	self.m_ProgressAnimation = CAnimation:new(self, onProgressDone, "m_Progress")

	self.m_BobberAnimation:callRenderTarget(false)
	self.m_ProgressAnimation:callRenderTarget(false)
	self.m_FadeAnimation:callRenderTarget(false)
end

function BobberBar:toggleControls(state)
	if state then
		toggleControl("fire", false)
	end
end

function BobberBar:getMotionType(behavior)
	if behavior == "mixed" then
		return 0
	elseif behavior == "dart" then
		return 1
	elseif behavior == "smooth" then
		return 2
	elseif behavior == "sinker" then
		return 3
	elseif behavior == "floater" then
		return 4
	end
end

function BobberBar:handleClick(_, state)
	if self.m_ProgressDuration ~= 0 then
		self.m_MouseDown = state == "down"
		self.Sound:play(("fishingRodBend%s"):format(self.m_MouseDown and "" or 2)):setVolume(.2)
	end
end

function BobberBar:setBobberPosition()
	if self.m_MotionType == FISHING_MOTIONTYPE.DART or (self.m_MotionType == FISHING_MOTIONTYPE.MIXED and self.Random:nextDouble() < self.m_Difficulty/150) then
		local newTargetPosition = self.m_BobberTargetPosition

		while math.abs(newTargetPosition - self.m_BobberTargetPosition) < 60 do
			newTargetPosition = self.Random:get(self.POSITION_UP + 10, self.POSITION_DOWN - 20)
		end

		local delta = math.abs(newTargetPosition - self.m_BobberTargetPosition)
		self.m_BobberSpeed = (2500 - self.m_Difficulty*5)/self.HEIGHT*delta
		self.m_BobberTargetPosition = newTargetPosition

	elseif self.m_MotionType == FISHING_MOTIONTYPE.SMOOTH or (self.m_MotionType == FISHING_MOTIONTYPE.MIXED and self.Random:nextDouble() < self.m_Difficulty/200) then
		local newTargetPosition = self.m_BobberPosition

		while math.abs(newTargetPosition - self.m_BobberPosition) < self.m_Difficulty do
			newTargetPosition = self.m_BobberPosition + self.Random:get(-self.m_Difficulty*5, self.m_Difficulty*5)
		end

		self.m_BobberTargetPosition = newTargetPosition
		self.m_BobberSpeed = (2000 - self.m_Difficulty*5)

	elseif self.m_MotionType == FISHING_MOTIONTYPE.FLOATER or (self.m_MotionType == FISHING_MOTIONTYPE.MIXED and self.Random:nextDouble() < self.m_Difficulty/100) then
		if self.m_BobberPosition > self.POSITION_DOWN - 80 then
			self.m_BobberTargetPosition = self.Random:get(self.POSITION_UP + 10, self.POSITION_UP + self.HEIGHT/4)
			self.m_BobberSpeed = 900 - self.m_Difficulty*2
		else
			self.m_BobberTargetPosition = self.m_BobberPosition + (self.Random:get(1, 4) == 1 and self.Random:get(-math.max(self.m_Difficulty/2.5, 15), 10) or self.Random:get(15, math.clamp(30, self.m_Difficulty*2, 150)))
			self.m_BobberSpeed = 600 - self.m_Difficulty*2
		end

	elseif self.m_MotionType == FISHING_MOTIONTYPE.SINKER or (self.m_MotionType == FISHING_MOTIONTYPE.MIXED and self.Random:nextDouble() < self.m_Difficulty/100) then
		if self.m_BobberPosition < 80 then
			self.m_BobberTargetPosition = self.Random:get(self.POSITION_DOWN - self.HEIGHT/4, self.POSITION_DOWN - 20)
			self.m_BobberSpeed = 900 - self.m_Difficulty*2
		else
			self.m_BobberTargetPosition = self.m_BobberPosition - (self.Random:get(1, 4) == 1 and self.Random:get(-math.max(self.m_Difficulty/2.5, 15), 10) or self.Random:get(15, math.clamp(30, self.m_Difficulty*2, 150)))
			self.m_BobberSpeed = 600 - self.m_Difficulty*2
		end

	else
		-- call again if motionType == FISHING_MOTIONTYPE.MIXED and no condition was true
		return self:setBobberPosition()
	end

	-- Probably we don't need this
	if self.m_BobberTargetPosition > self.POSITION_DOWN - 20 then
		self.m_BobberTargetPosition = self.POSITION_DOWN - 20
	elseif self.m_BobberTargetPosition < self.POSITION_UP + 10 then
		self.m_BobberTargetPosition = self.POSITION_UP + 10
	end

	self.m_BobberAnimation:startAnimation(self.m_BobberSpeed, "InOutQuad", self.m_BobberTargetPosition)
end

function BobberBar:updateRenderTarget()
	self.m_RenderTarget:setAsTarget()

	-- Draw Background
	dxDrawRectangle(0, 0, self.m_Size, tocolor(80, 80, 80, 150))

	-- Draw BobberBar
	dxSetBlendMode("modulate_add")
	dxDrawRectangle(4, 4, 32, self.m_Size.y-8, Color.Black)																				-- bobberBar bg Border
	dxDrawImage(5, 5, 30, self.m_Size.y-10, "files/images/Fishing/BobberBarBG.png")														-- bobberBar bg
	--dxDrawRectangle(3, self.m_BobberBarPosition, 34, self.m_BobberBarHeight, Color.Black)												-- bobberBar Border
	dxDrawRectangle(4, self.m_BobberBarPosition, 32, self.m_BobberBarHeight, tocolor(0, 225, 50, self.m_BobberInBar and 255 or 150))	-- bobberBar
	dxSetBlendMode("blend")

	-- Draw Bobber (Fish)
	dxDrawImage(6, self.m_BobberPosition, 28, 28, "files/images/Fishing/Fish.png", 0, 0, 0, tocolor(115, 200, 230))

	-- Draw Progressbar
	local progress_height = self.HEIGHT*(self.m_Progress/100)
	local progress_color = tocolor(255*(1-self.m_Progress/100), 255*self.m_Progress/100, 0)
	dxDrawRectangle(39, 4, 15, self.m_Size.y-8, Color.Black)										--progress bg border
	dxDrawRectangle(40, 5, 13, self.m_Size.y-10, tocolor(130, 130, 130))							--progress bg
	dxDrawRectangle(40, self.POSITION_DOWN - progress_height, 13, progress_height, progress_color) 	--progressbar

	dxSetRenderTarget()
end

function BobberBar:render()
	if self.m_ProgressDuration ~= 0 then
		-- BobberBar Animation
		local num = (self.m_MouseDown and -0.5 or 0.5)/1080*screenHeight
		self.m_BobberBarSpeed = self.m_BobberBarSpeed + num
		self.m_BobberBarPosition = self.m_BobberBarPosition + self.m_BobberBarSpeed

		if self.m_BobberBarPosition > self.POSITION_DOWN - self.m_BobberBarHeight then
			self.m_BobberBarPosition = self.POSITION_DOWN - self.m_BobberBarHeight

			if self.m_BobberBarSpeed ~= 0 then
				self.m_BobberBarSpeed = 0 --self.m_BobberBarSpeed + 0.5
				--if self.m_BobberBarSpeed < -self.MAX_PUSHBACK_SPEED then self.m_BobberBarSpeed = -self.MAX_PUSHBACK_SPEED end
			end
		elseif self.m_BobberBarPosition < self.POSITION_UP then
			self.m_BobberBarPosition = self.POSITION_UP

			if self.m_BobberBarSpeed ~= 0 then
				self.m_BobberBarSpeed = math.abs(self.m_BobberBarSpeed) - 0.5
				if self.m_BobberBarSpeed > self.MAX_PUSHBACK_SPEED then self.m_BobberBarSpeed = self.MAX_PUSHBACK_SPEED end
			end
		end

		-- Check progress (only Y position/height)
		if (self.m_BobberInBar or self.m_BobberInBar == nil) and not rectangleCollision2D(0, self.m_BobberBarPosition, 0, self.m_BobberBarHeight, 0, self.m_BobberPosition, 0, 28) then
			self.m_BobberInBar = false

			if self.m_FisherLevel > 1 then
				local duration = (self.m_ProgressDuration - self.m_ProgressDifficultyAddition) * (self.m_Progress/100)
				self.m_ProgressAnimation:startAnimation(duration, "Linear", 0)
			else
				self.m_ProgressAnimation:stopAnimation()
			end

			self.Sound:play("woap2")
			self.Sound:stop("slowReel")
		elseif (not self.m_BobberInBar or self.m_BobberInBar == nil) and rectangleCollision2D(0, self.m_BobberBarPosition, 0, self.m_BobberBarHeight, 0, self.m_BobberPosition, 0, 28) then
			self.m_BobberInBar = true

			local duration = self.m_ProgressDuration * (1 - self.m_Progress/100)
			self.m_ProgressAnimation:startAnimation(duration, "Linear", 100)
			self.Sound:play("slowReel", true)
		end
	end

	-- Update and draw
	self:updateRenderTarget()

	--dxDrawText("Speed: " .. self.m_BobberSpeed, 500, 20)
	--dxDrawText("Current position: " .. self.m_BobberPosition, 500, 35)
	--dxDrawText("Target position: " .. self.m_BobberTargetPosition, 500, 50)
	--dxDrawText("Motion type: " .. self.m_MotionType, 500, 65)
	--dxDrawText("Bobber in bar: " .. tostring(self.m_BobberInBar), 500, 80)
	--dxDrawText("Difficulty: " .. self.m_Difficulty, 500, 95)

	dxDrawImage(screenWidth*0.66 - self.m_Size.x * self.m_AnimationMultiplicator/2, screenHeight/2 - self.m_Size.y * self.m_AnimationMultiplicator/2, self.m_Size * self.m_AnimationMultiplicator, self.m_RenderTarget, 0, 0, 0, tocolor(255, 255, 255, 255*self.m_AnimationMultiplicator))
end

addEventHandler("fishingBobberBar", root,
	function(...)
		BobberBar:new(...)
	end
)
