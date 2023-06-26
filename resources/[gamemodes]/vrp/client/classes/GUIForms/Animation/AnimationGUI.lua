-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AnimationGUI.lua
-- *  PURPOSE:     Animation GUI Class
-- *
-- ****************************************************************************
AnimationGUI = inherit(GUIForm)
inherit(Singleton, AnimationGUI)
addRemoteEvents{"onClientAnimationStop"}

function AnimationGUI:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight/2-500/2, 250, 500, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Animationen", true, true, self)
	self.m_Window:addHelpButton(LexiconPages.Animation)

	self.m_AnimationList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self.m_Window)
	self.m_AnimationList:addColumn(_"Name", 1)
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, _"Doppelklick zum Ausführen", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("center"):setColor(Color.Red)

	self.m_AnimationList:addItem("Laufstilfenster öffnen").onLeftDoubleClick = function () self.m_Window:close() WalkingstyleGUI:new() end
	self.m_AnimationList:addItem("Custom Animationen").onLeftDoubleClick = function () self.m_Window:close() CustomAnimationGUI:new() end

	local item
	for groupIndex, group in pairs(ANIMATION_GROUPS) do
		self.m_AnimationList:addItemNoClick(_(group))
		for index, animation in pairs(ANIMATIONS) do
			if animation["group"] == group then
				item = self.m_AnimationList:addItem(_(("%s%s"):format(index:sub(1, 1):upper(), index:sub(2, #index))))
				item.Name = index
				item.onLeftDoubleClick = function () self:startAnimation() end
			end
		end
	end

	-- Events
	self.m_InfoMessage = false
	addEventHandler("onClientAnimationStop", root, bind(self.onAnimationStop, self))
end

function AnimationGUI:startAnimation()
	if localPlayer:getData("isTasered") then return end
	if localPlayer:getData("isInDeathMatch") then return end
	if localPlayer.vehicle then return end
	if localPlayer:isOnFire() then return end
	if localPlayer:isInWater() then return end
	if localPlayer:getData("isEating") then return end
    if localPlayer:isReloadingWeapon() then return end
	if isPedAiming(localPlayer) then return end

	if ANIMATIONS[self.m_AnimationList:getSelectedItem().Name] then
		if not self.m_InfoMessage then
			self.m_InfoMessage = ShortMessage:new(_"Benutze 'Leertaste' zum Beenden der Animation!", -1)
		end
		local animation = self.m_AnimationList:getSelectedItem().Name
		triggerServerEvent("startAnimation", localPlayer, animation)
		if animation == "Tanz Chill" then
			for i, v in ipairs(Element.getAllByType("object", root, true)) do -- to short the loop use only streamedin objects
				if v:getModel() == 656 and math.abs((localPlayer.position - v.position).length) <= 2 then
					localPlayer:giveAchievement(43)
					return
				end
			end
		elseif animation == "Wichsen" then
			for i, v in ipairs(Element.getAllByType("ped", root, true)) do
				if v:getData("BeggarId") ~= nil and math.abs((localPlayer.position - v.position).length) <= 1 then
					localPlayer:giveAchievement(57)
					return
				end
			end
		end
	end
end

function AnimationGUI:onAnimationStop()
	if self.m_InfoMessage then
		delete(self.m_InfoMessage)
	end
end
