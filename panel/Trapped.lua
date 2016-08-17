local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Trapped = class("Trapped", function ()
    return PanelBase.new("Layer/Trapped.csb")
end)

function Trapped:ctor(parent, cb)
    local move = cc.MoveTo:create(0.3, cc.p(0, 0))
    
    self:init(parent, move)
    self.hintcb = cb
    self:setButtons()
    self:setTexts()
end

function Trapped:setButtons()
    self:setEvent("Panel.BuyBtn", handler(self, self.buy))
    self:setEvent("Panel.ShareBtn", handler(self, self.share))
    self:setEvent("Panel.HintBtn", handler(self, self.getHint))

    if userfile.get("coin") < config.coinPerHint then
        self:setButtonEnable("Panel.HintBtn", false)
    end
end

function Trapped:getHint()
    userfile.add("coin", -config.coinPerHint)
    self.hintcb()
    self:close()
    
end

function Trapped:setTexts()
    self:setText("Panel.CoinTxt", userfile.get("coin"))
    self:setText("Panel.CoinPerHintTxt", config.coinPerHint)
    self:setText("Panel.CoinPerShareTxt", config.coinPerShare)
end

function Trapped:buy()
    -- TODO
end

function Trapped:share()
    -- TODO
end

return Trapped
