-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/abstract/GUIGridWrapperClasses.lua
-- *  PURPOSE:     GUI Grid Wrapper
-- *
-- ****************************************************************************
GUIGridButton = inherit(GUIButton)
GUIGridIconButton = inherit(GUIButton)
GUIGridChanger = inherit(GUIChanger)
GUIGridCheckbox = inherit(GUICheckbox)
GUIGridEdit = inherit(GUIEdit)
GUIGridCombobox = inherit(GUICombobox)
GUIGridGridList = inherit(GUIGridList)
GUIGridImage = inherit(GUIImage)
GUIGridLabel = inherit(GUILabel)
GUIGridMiniMap = inherit(GUIMiniMap)
GUIGridProgressBar = inherit(GUIProgressBar)
GUIGridRadioButton = inherit(GUIRadioButton)
GUIGridRectangle = inherit(GUIRectangle)
GUIGridEmptyRectangle = inherit(GUIEmptyRectangle)
GUIGridSlider = inherit(GUISlider)
GUIGridSwitch = inherit(GUISwitch)
GUIGridScrollableArea = inherit(GUIScrollableArea)
GUIGridWebView = inherit(GUIWebView)
GUIGridMemo = inherit(GUIMemo)
GUIGridSkribble = inherit(GUISkribble)
GUIGridRating = inherit(GUIRating)


function GUIGridEdit:constructor(posX, posY, width, height, parent) return GUIEdit.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridCombobox:constructor(posX, posY, width, height, displayText, parent) return GUICombobox.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), displayText, parent) end
function GUIGridGridList:constructor(posX, posY, width, height, parent) return GUIGridList.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridImage:constructor(posX, posY, width, height, path, parent) return GUIImage.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), path, parent) end
function GUIGridRadioButton:constructor(posX, posY, width, height, text, parent) return GUIRadioButton.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), text, parent) end
function GUIGridRectangle:constructor(posX, posY, width, height, color, parent) return GUIRectangle.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), color, parent) end
function GUIGridEmptyRectangle:constructor(posX, posY, width, height, linewidth, color, parent) return GUIEmptyRectangle.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), linewidth, color, parent) end
function GUIGridProgressBar:constructor(posX, posY, width, height, parent) return GUIProgressBar.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridSlider:constructor(posX, posY, width, height, parent) return GUISlider.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridSwitch:constructor(posX, posY, width, height, parent) return GUISwitch.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridWebView:constructor(posX, posY, width, height, url, transparent, parent) return GUIWebView.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), url, transparent, parent) end
function GUIGridMemo:constructor(posX, posY, width, height, parent) return GUIMemo.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridSkribble:constructor(posX, posY, width, height, parent) return GUISkribble.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent) end
function GUIGridRating:constructor(posX, posY, width, height, amount, parent) return GUIRating.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), amount, parent) end

function GUIGridButton:constructor(posX, posY, width, height, text, parent)
    GUIButton.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), text, parent)
    self:setFont(VRPFont(25)):setFontSize(1)
    return self
end

function GUIGridIconButton:constructor(posX, posY, text, parent)
    GUIButton.constructor(self, grid("x", posX), grid("y", posY), grid("d", 1), grid("d", 1), text, parent)
    self:setFont(FontAwesome(15)):setFontSize(1)
    self:setBarEnabled(false)
    self:setBackgroundColor(Color.Accent)
    return self
end

function GUIGridChanger:constructor(posX, posY, width, height, parent)
    GUIChanger.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent)
    return self
end

function GUIGridCheckbox:constructor(posX, posY, width, height, text, parent)
    GUICheckbox.constructor(self, grid("x", posX), grid("y", posY) + 5, grid("d", width), grid("d", height) - 10, text, parent)
    self:setFont(VRPFont(25)):setFontSize(1)
    return self
end

function GUIGridMiniMap:constructor(posX, posY, width, height, parent)
    GUIMiniMap.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), parent)
    return self
end

function GUIGridLabel:constructor(posX, posY, width, height, text, parent)
    GUILabel.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), text, parent)
    self:setFont(VRPFont(25))
    self:setAlignY("center")
    return self
end

function GUIGridLabel:setHeader(type)
    self:setFont(VRPFont(type == "sub" and 30 or 35))
    return self
end


function GUIGridScrollableArea:constructor(posX, posY, width, height, documentWidth, documentHeight, verticalScrollbar, horizontalScrollbar, parent, space)
    return GUIScrollableArea.constructor(self, grid("x", posX), grid("y", posY), grid("d", width), grid("d", height), grid("d", documentWidth), grid("d", documentHeight), verticalScrollbar, horizontalScrollbar, parent, grid("y", space))
end

function GUIGridScrollableArea:resize(documentWidth, documentHeight)
    return GUIScrollableArea.resize(self, grid("d", documentWidth), grid("d", documentHeight))
end

