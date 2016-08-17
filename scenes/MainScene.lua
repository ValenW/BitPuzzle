local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")
local LevelPages = require("app.panel.LevelPages")
local SelectScene = require("app.scenes.SelectScene")
local Panels = require("app.panel.Panels")

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
    self:setEvent("BtnLogin", handler(self, self.login))
    self:setEvent("BtnBasic", handler(self, self.enterBasic))
    self:setEvent("BtnHot", handler(self, self.enterHot))
    self:setEvent("BtnBest", handler(self, self.enterBest))
    self:setEvent("BtnNew", handler(self, self.enterNew))
    self:setEvent("BtnMine", handler(self, self.enterMine))
    self:setEvent("BtnCollect", handler(self, self.enterCollect))
    self:setEvent("BtnSkin", handler(self, self.enterSkin))
    self:setEvent("BtnSetting", handler(self, self.setting))
end

function MainScene:login()
    Panels.Login.new(self)
end

function MainScene:setting()
    Panels.Setting.new(self)
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
