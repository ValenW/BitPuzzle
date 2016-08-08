local PuzzleEditor = require("app.sprite.PuzzleEditor")
local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")

local GameScene = class("GameScene", SceneBase)

function GameScene:ctor(puzzleConfig)
    self:init("Scene/GameScene.csb")

    self:initWithPuzzle(puzzleConfig)
    
    self:setTexts()
    self:setEvents()
end

function GameScene:initWithPuzzle(puzzleConfig)
    
end

function GameScene:setTexts()
    
end

function GameScene:setEvents()
    
end

return GameScene
