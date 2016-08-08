local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")
local GetFreeCoin = require("app.panel.GetFreeCoin")

local FreeCoin = class("FreeCoin", function ()
    return PanelBase.new("FreeCoin.csb")
end)

function FreeCoin:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()

end

function FreeCoin:setButtons()
    self:setEvent("CloseButton",    handler(self, self.close))
    self:setEvent("NoButton",       handler(self, self.close))
    self:setEvent("YesButton",      handler(self, self.showAD))
    self:setButtonEnable("YesButton", false)
    AdManager:isVideoReady(handler(self, self.isADready))
end

function FreeCoin:showAD()
    AdManager:getInstance():showVideoAd(function(res)
        if res then
            userfile.add("coin", config.coinPerAD)
            GetFreeCoin.new(self:getParent(), config.coinPerAD)
            self:removeFromParent(true)
            return true
        else
            
            return false
        end
    end)
end

function FreeCoin:setTexts()
    self:setText("CoinGet", config.coinPerAD)
end

function FreeCoin:isADready(res)
    if res then
        self:setButtonEnable("YesButton", true)
    end
end

return FreeCoin
