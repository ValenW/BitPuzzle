local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Buy = class("Buy", function ()
    return PanelBase.new("Layer/Buy.csb")
end)

function Buy:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()
end

function Buy:setButtons()
    self:setEvent("CloseBtn", handler(self, self.close))
    -- TODO
end

function Buy:setTexts()
    -- TODO
end

return Buy
