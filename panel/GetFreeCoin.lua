local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local GetFreeCoin = class("GetFreeCoin", function ()
    return PanelBase.new("GetFreecoin.csb")
end)

function GetFreeCoin:ctor(parent, coinNum)
    self:init(parent)
    self.coinNum = coinNum
    self:setButtons()
    self:setTexts()
    self.cb = function () parent:update() end --handler(parent, parent.update)
end

function GetFreeCoin:setButtons()
    self:setEvent("CloseButton",    handler(self, self.close))
    self:setEvent("GetButton",      handler(self, self.close))
end

function GetFreeCoin:setTexts()
    self:setText("CoinGet", self.coinNum)
end

return GetFreeCoin
