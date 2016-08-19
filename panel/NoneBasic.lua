local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local NoneBasic = class("NoneBasic", function ()
    return PanelBase.new("Scene/NoneBasic.csb", true, true)
end)

function NoneBasic:ctor(parent, type)
    self.type = type
    self:init(parent, false)
    self:setButtons()
    self:setTexts()
end

function NoneBasic:setButtons()
    -- Nothing todo
end

function NoneBasic:setTexts()
    self:setText("Panel.BgIcon", "ui/pic_icon_"..self.type..".png")
    self:setText("Panel.Txt", config.noneTips[self.type])
end

return NoneBasic
