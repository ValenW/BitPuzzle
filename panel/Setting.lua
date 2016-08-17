local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Setting = class("Setting", function ()
    return PanelBase.new("Layer/Setting.csb")
end)

function Setting:ctor(parent)
    self:init(parent)
    self:setButtons()
--    self:setTexts()
end

function Setting:setButtons()
    self:setEvent("BtnHelp", handler(self, self.help)  )
    self:setEvent("BtnAbout", handler(self, self.about)  )
    self:setEvent("BtnContact", handler(self, self.contact) )
    self:setEvent("BtnEffect", handler(self, self.effect) )
    self:setEvent("BtnMusic", handler(self, self.music) )
    self:setEvent("BtnRate", handler(self, self.rate)  )
end

function Setting:help()
    -- TODO
end

function Setting:about()
    -- TODO
end

function Setting:contact()
    -- TODO
end

function Setting:effect()
    -- TODO
end

function Setting:music()
    -- TODO
end

function Setting:rate()
    -- TODO
end

return Setting
