local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Login = class("Login", function ()
    return PanelBase.new("Layer/Login.csb")
end)

function Login:ctor(parent)
    self:init(parent)
    self:setButtons()
--    self:setTexts()
end

function Login:setButtons()
    self:setEvent("BtnLogin", handler(self, self.login))
    self:setEvent("BtnClose", handler(self, self.close))
end

function Login:login()
    -- TODO
end

function Login:close()
    self:removeFromParent(true)
end

return Login
