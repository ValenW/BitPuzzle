local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Shop = class("Shop", function ()
    return PanelBase.new("Shop.csb")
end)

function Shop:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()
end

function Shop:setButtons()
    self:setEvent("CloseButton",    function () self:close() end )
    self:setEvent("AllEmojiButton", function () self:buy("allskins", handler(self, self.buyAllSkins)) end )
    NoAdManager.setNoAdButton(self:getChildByName("NoADButton"), config.productID["noad"], function () end, function () end)
    
--    self:setEvent("NoADButton",     function () self:buy("noad", handler(self, self.buyNoAD)) end )
    self:setEvent("300CoinsButton", function () self:buy("c300", handler(self, self.buy300coin)) end )
    
    local restoreNode = self:getChildByName("RestoreNode")
    local restoreButton = restoreNode:getChildByName("RestoreButton")
    if device.platform == "ios" then
        restoreButton:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:restore()
            end
        end)
    else
        restoreNode:setVisible(false)
    end
    
    local buyAllSkin = true
    for i = 2, config.themeNum do
        if userfile.get("skin"..i) == 0 then
            buyAllSkin = false
            break
        end
    end
    self:setButtonEnable("AllEmojiButton", not buyAllSkin)
end

function Shop:setTexts()
    -- Nothing
end

function Shop:buyAllSkins()
    for i = 2, 8 do
        userfile.set("skin"..i, 1)
    end
    self:setButtonEnable("AllEmojiButton", false)
end

function Shop:buy300coin()
    userfile.add("coin", 300)
end

function Shop:buyNoAD()
    AdManager:stopAdAndSave()
    self:setButtonEnable("NoADButton", false)
end

return Shop
