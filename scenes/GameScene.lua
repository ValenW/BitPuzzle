local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")
local Panels = require("app.panel.Panels")

local PuzzleItem = require("app.sprite.PuzzleItem")
local BitItem = require("app.sprite.BitItem")
local Puzzle = require("app.sprite.Puzzle")

local GameScene = class("GameScene", SceneBase)

function GameScene:ctor(puzzleFile)
    if puzzleFile == nil then
        puzzleFile = "cut 1.txt"
    end
    self:init("Scene/GameScene.csb")

	self.puzzleBoard = self:getChild("PuzzleBoard")
    self.blockLength = self.puzzleBoard:getContentSize().width / config.boardLength * self.puzzleBoard:getScaleX()

    self:initWithPuzzle(puzzleFile)
    
    self:setTexts()
    self:setEvents()
end

function GameScene:initWithPuzzle(puzzleFile)
    if type(puzzleFile) == "string" then
        self.puzzle = Puzzle.new(puzzleFile)
    else
        self.puzzle = puzzleFile
    end

    self.puzzleItem = PuzzleItem.new(self.puzzle, self.puzzleBoard)
    self.bitList = self:getChild("ListView")
    self.bitList:setLocalZOrder(config.listOrder)
    self.bitList:setItemsMargin(60)
    self.bitList:addTouchEventListener(handler(self, self.scrollList))
    
    local items = self.puzzle:getItems()
    self.bitItems = {}
    for i = 1, #items do
        self.bitItems[i] = BitItem.new(items[self.puzzleItem.hintOrder[i]], self.blockLength, self.puzzleItem)
        self.bitItems[i].layout:setTouchEnabled(true)
        local clonepanel = self.bitItems[i].layout:clone()
        

        self.bitItems[i].layout:setPosition(0, 0)
        clonepanel:addChild(self.bitItems[i].layout)

        self.bitItems[i].layout:setPropagateTouchEvents(false)
        
        clonepanel:setBackGroundColor(cc.c3b(0,255,0))
        
        self.bitItems[i].parentPanel = clonepanel
        self.bitItems[i]:setListView(self.bitList)
        self.bitList:pushBackCustomItem(clonepanel)
    end
end

function GameScene:scrollList(sender, eventType)
    -- TODO
    local inner = self.bitList:getInnerContainer()
    local innerPos, size = cc.p(inner:getPosition()).x, inner:getContentSize().width - self.bitList:getContentSize().width
    if size == 0 then
        self:getChild("ScrollHead"):setVisible(false)
        self:getChild("ScrollBG"):setVisible(false)
        self:getChild("ScrollLeft"):setVisible(false)
        self:getChild("ScrollRight"):setVisible(false)
        self:getChild("ScrollBar"):setVisible(false)
        return nil
    end
    local persent = -innerPos / size

    self:getChild("ScrollHead"):setVisible(true)
    self:getChild("ScrollBG"):setVisible(true)
    self:getChild("ScrollLeft"):setVisible(true)
    self:getChild("ScrollRight"):setVisible(true)
    self:getChild("ScrollBar"):setVisible(true)
    self:setScrollPersent(persent)
    return persent
end

function GameScene:setScrollPersent(persent)
    local scrollBar = self:getChild("ScrollBar")
    local left = scrollBar:getContentSize().width / 2 + 20
    local length = display.width - left * 2
    scrollBar:setPositionX(left + length * persent)
end

function GameScene:setTexts()

end

function GameScene:setEvents()
    self:setEvent("HintBtn", handler(self, self.showHint))
    self:setEvent("BackBtn", handler(self, self.finished))
end

function GameScene:showHint()
    local func = handler(self.puzzleItem, self.puzzleItem.getHint)
    Panels.Trapped.new(self, handler(self.puzzleItem, self.puzzleItem.getHint))
end

function GameScene:win()
    local cb = function ()
        local puzzle = self.puzzle
        local scene = GameScene.new(puzzle)
        cc.Director:getInstance():replaceScene(scene)
    end
    
    if self.puzzle.id ~= nil then
        userfile.set("Puzzle"..self.puzzle.id, 1)
        self.puzzle.updateParent:update(self.puzzle.id)
    end
    
    Panels.PuzzleDetail.new(self, self.puzzle, true, cb)
end

function GameScene:finished()
    cc.Director:getInstance():popScene()
end

return GameScene
