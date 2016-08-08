local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Unlock = class("Unlock", function ()
    return PanelBase.new("Unlock.csb")
end)

function Unlock:ctor(parent, skinId)
    self:init(parent)
    self.skinId = skinId
    
    local skinLv = config.skinLvs[skinId]
    self.coin, self.coinPer, self.moneyPer = userfile.get("coin"), config.skinPer[skinLv][1], config.skinPer[skinLv][2] / 100
    
    self:setButtons()
    self:setTexts()
    
end

function Unlock:setButtons()
    self:setEvent("CloseButton", handler(self, self.close))

    if self.coin < self.coinPer then
        self:setButtonEnable("UnlockButton", false)
    end
    self:setEvent("UnlockButton", handler(self, self.unlockSkin) )
    self:setEvent("BuyButton", function () self:buy("s"..(self.skinId - 1), handler(self, self.buySkin)) end )
end

function Unlock:setTexts()
    self:setText("CoinNeed1", self.coinPer)
    self:setText("CoinNeed2", self.coinPer)
    self:setText("Coin", self.coin)
    self:setText("MoneyNeed", "USD $"..self.moneyPer)
end

function Unlock:unlockSkin()
    local unlock = userfile.get("skin"..self.skinId)
    if self.coin >= self.coinPer and unlock == 0 then
        userfile.add("coin", -self.coinPer)
        userfile.set("skin"..self.skinId, 1)
    end
    local parent = self:getParent()
    self:close( function () parent:setButtons() parent:changeSkin(self.skinId) end )
end

function Unlock:buySkin()
    userfile.set("skin"..self.skinId, 1)
    local parent = self:getParent()
    self:close( function () parent:setButtons() parent:changeSkin(self.skinId) end )
end

return Unlock
