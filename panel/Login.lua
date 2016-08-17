local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Login = class("Login", function ()
    return PanelBase.new("Layer/Login.csb")
end)

function Login:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()
end

function Login:setButtons()
    self:setEvent("LoginBtn", handler(self, self.login))
end

function Login:login()
    -- TODO
end

return Login
