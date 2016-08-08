local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")
local Shop = require("app.panel.Shop")

local NoCoin = class("NoCoin", function ()
    return PanelBase.new("NoCoin.csb")
end)

function NoCoin:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()

end

function NoCoin:setButtons()
    self:setEvent("CloseButton",    function () self:close() end )
    self:setEvent("NoButton",       function () self:close() end )
    self:setEvent("YesButton",      function () self:enterShop() end )

end

function NoCoin:setTexts()
    -- Nothing
end

function NoCoin:enterShop()
    Shop.new(self:getParent())
    self:removeFromParent(true)
end

return NoCoin
