local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")
local LevelPages = require("app.panel.LevelPages")
local SelectScene = require("app.scenes.SelectScene")

local MainScene = class("MainScene", SceneBase)

function MainScene:ctor()
    self:init("Scene/MainScene.csb")
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
    self:setEvent("SettingBtn", handler(self, self.enterSetting))
end

function MainScene:login()
    
end

function MainScene:setting()

end

function MainScene:enterBasic()
    local gameScene = SelectScene.new("basic", LevelPages)
    cc.Director:getInstance():pushScene(gameScene)
end

function MainScene:enterHot()
--    self:enterSceneByName("HotScene")
end

function MainScene:enterBest()
--    self:enterSceneByName("BestScene")
end

function MainScene:enterNew()
--    self:enterSceneByName("NewScene")
end

function MainScene:enterMine()
    self:enterSceneByName("DiyScene")
end

function MainScene:enterCollect()
--    self:enterSceneByName("CollectScene")
end

function MainScene:enterSkin()
--    self:enterSceneByName("SkinScene")
end

return MainScene
