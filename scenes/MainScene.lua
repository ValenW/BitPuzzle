local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")

local MainScene = class("MainScene", SceneBase)

function MainScene:ctor()
    self.init("Scene/MainScene.csb")
    self:setTexts()
    self:setEvents()
end

function MainScene:setTexts()
    -- Nothing to be done
end

function MainScene:setEvents()
    self:setEvent("LoginBtn", handler(self, self.login))
    self:setEvent("BasicBtn", handler(self, self.enterBasic))
    self:setEvent("HotBtn", handler(self, self.enterHot))
    self:setEvent("BestBtn", handler(self, self.enterBest))
    self:setEvent("NewBtn", handler(self, self.enterNew))
    self:setEvent("MineBtn", handler(self, self.enterMine))
    self:setEvent("CollectBtn", handler(self, self.enterCollect))
    self:setEvent("SkinBtn", handler(self, self.enterSkin))
end

return MainScene
