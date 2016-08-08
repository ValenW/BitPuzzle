local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Tutor = class("Tutor", function ()
    return PanelBase.new("Tutor.csb")
end)

function Tutor:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()
end

function Tutor:setButtons()
    self:setEvent("CloseButton",    function () self:close() end )
end

function Tutor:setTexts()
    -- Nothing
end

return Tutor
