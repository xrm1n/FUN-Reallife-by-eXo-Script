-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InteriorEnterExitGUI.lua
-- *  PURPOSE:     InteriorEnterExitGUI GUI class
-- *
-- ****************************************************************************
InteriorEnterExitGUI = inherit(Singleton)

InteriorEnterExitGUI.m_Font = VRPFont(60)
InteriorEnterExitGUI.m_FontSmall = VRPFont(24)
InteriorEnterExitGUI.m_FontHeight = dxGetFontHeight(1, getVRPFont(InteriorEnterExitGUI.m_Font))

function InteriorEnterExitGUI:constructor(entry, text, icon, checkRange, allowVehicleEnter)
    self.m_Width = screenWidth*0.276
    self.m_Height = screenHeight*0.083
    self.m_X, self.m_Y = screenWidth/2-self.m_Width/2, screenHeight-self.m_Height*2

    self.m_Entry = entry
    self.m_Text = ("%s"):format(text:upper() or "EINGANG")
    self.m_Icon = icon
    self.m_CheckRange = checkRange or 3
    self.m_CancelVehicleEnter = not allowVehicleEnter
    local textWidth = dxGetTextWidth(self.m_Text, 1, getVRPFont(self.m_Font))
    if textWidth > self.m_Width*0.6 then
		local exceed = (textWidth - self.m_Width*0.6) / (self.m_Width*0.6)
        self.m_Font = VRPFont(math.ceil(60-(60*exceed)))
    end
    local key = core:get("KeyBindings", "KeyEntranceUse", KeyBinds:getSingleton().m_Keys["general"]["KeyEntranceUse"]["defaultKey"])
    self.m_KeyText = ("Drücke %s[%s]%s zum Benutzen!"):format("#32c8ff", string.upper(key:upper()), "#ffffff")

    self:start()
    if not self.m_CancelVehicleEnter then 
        toggleControl("enter_exit", false)
    end
end

function InteriorEnterExitGUI:start()
    self.m_Height = self.m_Height*0.9
    self.m_X = screenWidth/2-(self.m_Width*0.15/2)
    self.m_Start = getTickCount()
    self.m_Animation = false
    self.m_DrawBind = bind(self.draw, self)
    addEventHandler("onClientRender", root, self.m_DrawBind)
end

function InteriorEnterExitGUI:draw()
    localPlayer.m_LastEntrance = getTickCount()
    local prog
    if not self:check() then
        if not self.m_FadeOut then
            self.m_FadeOut = true
        end
    end
    if not self.m_Animation then
        prog = (getTickCount() - self.m_Start) / 250
    else
        prog = (getTickCount() - self.m_Start) / 500
    end
    if prog > 1 then prog = 1 end
    local alpha = 255*prog
    if alpha > 255 then alpha = 255 end
    if self.m_FadeOut then
        if not self.m_PreserveProg then
            self.m_PreserveProg = prog
            self.m_Start = getTickCount()
            prog = 0
            self.m_IgnoreCheck = false
        else
            self.m_IgnoreCheck = true
        end
        prog = self.m_PreserveProg  - prog
        if self.m_IgnoreCheck and prog <= 0 then
            delete(self)
        end
    end
    if self.m_Animation or self.m_Start + 700 < getTickCount() then
        if not self.m_Animation then
            self.m_Animation = true
            self.m_Start = getTickCount()
            prog = 0
        end

        self.m_X =  (screenWidth/2 - (self.m_Width*0.15/2)) - (prog *self.m_Width*0.425)
        dxDrawRectangle(self.m_X, self.m_Y, (self.m_Width*0.85)*prog, self.m_Height, tocolor(0, 0, 0, 150))
        dxDrawBoxShape(self.m_X, self.m_Y, (self.m_Width*0.85)*prog, self.m_Height, Color.Black)

        dxDrawRectangle(self.m_X, self.m_Y, self.m_Width*0.15, self.m_Height, Color.Black)
        dxDrawImage(self.m_X+self.m_Width*0.035, self.m_Y+self.m_Width*0.025, self.m_Width*0.08, self.m_Height-self.m_Width*0.05, self.m_Icon or "files/images/Inventory/items/Objekte/entrance.png")
        dxDrawBoxShape(self.m_X, self.m_Y, self.m_Width*0.15, self.m_Height, Color.Black)
        if prog == 1 then
            dxDrawText(self.m_Text, self.m_X+self.m_Width*0.15, self.m_Y, self.m_X + (self.m_Width*0.85)*prog, self.m_Y + self.m_Height, Color.LightBlue, 1, getVRPFont(self.m_Font), "center", "top")
            dxDrawText(self.m_KeyText, self.m_X+self.m_Width*0.15, self.m_Y+self.m_FontHeight*0.8, self.m_X + (self.m_Width*0.85)*prog, self.m_Y + self.m_FontHeight*1.1, Color.White, 1, getVRPFont(self.m_FontSmall), "center", "top", false, false, false, true)
        end
    else
        dxDrawRectangle(self.m_X, self.m_Y, self.m_Width*0.15, self.m_Height, tocolor(0, 0, 0, alpha))
        dxDrawImage(self.m_X+self.m_Width*0.035, self.m_Y+self.m_Width*0.025, self.m_Width*0.08, self.m_Height-self.m_Width*0.05, self.m_Icon or "files/images/Inventory/items/Objekte/entrance.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawBoxShape(self.m_X, self.m_Y, self.m_Width*0.15, self.m_Height, Color.changeAlpha(Color.LightBlue, alpha))
    end
end


function InteriorEnterExitGUI:check()
    if not isElement(self.m_Entry) then return end
    local x, y, z = getElementPosition(self.m_Entry)
    local px, py, pz = getElementPosition(localPlayer)
    local check = getDistanceBetweenPoints3D(x, y, z, px, py, pz) < self.m_CheckRange
    if not self.m_CancelVehicleEnter and not check then 
        toggleControl("enter_exit", true)
    end
    return check
end

function InteriorEnterExitGUI:isCancelEnter()
    return self.m_CancelVehicleEnter
end

function InteriorEnterExitGUI:destructor()
    if not self.m_CancelVehicleEnter then 
        toggleControl("enter_exit", true)
    end
    removeEventHandler("onClientRender", root, self.m_DrawBind)
end
