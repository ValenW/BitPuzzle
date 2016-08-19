local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")

local CreateScene = class("CreateScene", SceneBase)

function CreateScene:ctor()
    self:init("Scene/CreateScene.csb")
    self:setTexts()
    self:setEvents()
end

function CreateScene:setTexts()
    local title = string.upper(string.sub(self.sceneName, 1, 1))..string.lower(string.sub(self.sceneName, 2, -1))
    self:setText("TxtTitle", title)
    self:setText("BgTitle", "ui/pic_title_"..self.sceneName..".png")
end

function CreateScene:setEvents()
    self:setEvent("BtnBack", handler(self, self.back))
    self:setEvent("BtnSetting", handler(self, self.setting))
end

function CreateScene:back()
    cc.Director:getInstance():popScene()
end

function CreateScene:setting()
    Panels.Setting.new(self)
end

return CreateScene
