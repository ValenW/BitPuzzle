local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")

local PuzzleItem = require("app.sprite.PuzzleItem")
local BitItem = require("app.sprite.BitItem")
local Puzzle = require("app.sprite.Puzzle")

local GameScene = class("GameScene", SceneBase)

function GameScene:ctor(puzzleFile)
    local puzzleFile = "44th puzzle.txt"
    self:init("Scene/GameScene.csb")
    
	self.puzzleBoard = self:getChild("PuzzleBoard")
    self.blockLength = self.puzzleBoard:getContentSize().width / config.boardLength * self.puzzleBoard:getScaleX()

    self:initWithPuzzle(puzzleFile)
    
    self:setTexts()
    self:setEvents()
end

function GameScene:initWithPuzzle(puzzleFile)
    self.puzzle = Puzzle.new(puzzleFile)
    self.puzzleItem = PuzzleItem.new(self.puzzle, self.puzzleBoard)
    self.bitList = self:getChild("ListView")
    self.bitList:setItemsMargin(60)
    

    local items = self.puzzle:getItems()
    self.bitItems = {}
    for i = 1, #items do
        self.bitItems[i] = BitItem.new(items[i], self.blockLength, self.puzzleItem)
        self.bitItems[i].layout:setTouchEnabled(true)
        self.bitList:pushBackCustomItem(self.bitItems[i].layout)
    end
    self.bitList:setSwallowTouches(false)
end

function GameScene:setTexts()
    self:setEvent("HintBtn", handler(self.puzzleItem, self.puzzleItem.getHint))
end

function GameScene:setEvents()
    
end

return GameScene
