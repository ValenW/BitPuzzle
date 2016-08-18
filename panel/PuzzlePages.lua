local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")
local PuzzleItem = require("app.sprite.PuzzleItem")
local GameScene = require("app.scenes.GameScene")
local Panels = require("app.panel.Panels")

local PuzzlePages = class("PuzzlePages", function ()
    return PanelBase.new("Scene/PuzzlePages.csb", true)
end)

function PuzzlePages:ctor(parent, puzzles)
    self:init(parent, false)
    self.like = true
    if puzzles[1].like == nil then
        self.like = false
    end

    self.startId = puzzles.startId
    self.puzzleNum = #puzzles
    self.pageNum = math.ceil(self.puzzleNum / config.puzzlePerPage)
    self.puzzles = puzzles

    self:createPages()
    self:setButtonsAndTexts()
end

function PuzzlePages:createPages()
    local pageView = self:getChild("Pages")
    for i = 2, self.pageNum do
        local clone = self:getChild("Pages.Panel1"):clone()
        clone:setName("Panel"..i)
        pageView:addPage(clone)
    end
end

function PuzzlePages:setButtonsAndTexts()
    for i = 1, self.pageNum do
        dump(i)
        local basePath = "Pages.Panel"..i
        for j = 1, config.puzzlePerPage do
            local puzzleNum = (i - 1) * config.puzzlePerPage + j
            if puzzleNum > self.puzzleNum then
                self:removePuzzleItem(basePath, j)
            else
                self:initPuzzlePic(self:getChild(basePath..".Panel"..j), puzzleNum)

                self:setEvent(basePath..".BtnPuzzle"..j, self:getEnterGameFunc(puzzleNum))
                self:setText(basePath..".TxtPuzzleId"..j, string.format("#%03d", self.startId + puzzleNum - 1))
                -- self:getChild(basePath..".Panel"..j):setSwallowTouches(false)

                if self.like == true then
                    self:setText(basePath..".TxtLike"..j, self.puzzle[puzzleNum].like)
                else
                    self:getChild(basePath..".TxtLike"..j):removeFromParent(true)
                    local like = self:getChild(basePath..".like"..j)
                    if like ~= nil then
                        like:removeFromParent(true)
                    end
                end
            end
        end
    end
end

function PuzzlePages:removePuzzleItem(basePath, puzzleNum)
    self:getChild(basePath..".Panel"..puzzleNum):removeFromParent(true)
    self:getChild(basePath..".BtnPuzzle"..puzzleNum):removeFromParent(true)
    self:getChild(basePath..".TxtPuzzleId"..puzzleNum):removeFromParent(true)
    self:getChild(basePath..".TxtLike"..puzzleNum):removeFromParent(true)
    local like = self:getChild(basePath..".like"..puzzleNum)
    if like ~= nil then
        like:removeFromParent(true)
    end
end

function PuzzlePages:initPuzzlePic(panel, puzzleNum)
    local puzzle = self.puzzles[puzzleNum]
    local path = cc.FileUtils:getInstance():getWritablePath().."BitPuzzle/cut "..puzzle.id
    if puzzle.finished == true then
        path = path.."_finished.png"
    else
        path = path.."_no_finished.png"
    end
    local sp = cc.Sprite:create(path)
    if sp == nil then
        local puzzleItemFunc = nil
        if puzzle.finished == true then
            puzzleItemFunc = function () end
        else
            puzzleItemFunc = function (sp) sp:setTexture("Blocks/00/bg_without_board.png") end
        end
        PuzzleItem.new(puzzle, panel, puzzleItemFunc, true)
    else
        local size, lsize = sp:getContentSize(), panel:getContentSize()
        sp:setScale(lsize.width / size.width, lsize.height / size.height)
        sp:setAnchorPoint(0,0)
        sp:setPosition(0,0)
        panel:addChild(sp)
    end
end

function PuzzlePages:getEnterGameFunc(puzzleNum)
    local puzzle = self.puzzles[puzzleNum]
    puzzle.updateParent = self
    local enterGameFunc = function ()
        local gameScene = GameScene.new(puzzle)
        cc.Director:getInstance():pushScene(gameScene)
    end

    if puzzle.finished == true then
        local re = function ()
            Panels.PuzzleDetail.new(self, puzzle, false, enterGameFunc)
        end
        return re
    end

    return enterGameFunc
end

function PuzzlePages:update(puzzleId)
    dump("puzzlepages")
    local puzzleInfo = self:getNumFromId(puzzleId)
    local puzzleOrder, pageNum, puzzleNum = puzzleInfo[1], puzzleInfo[2], puzzleInfo[3]

    self.puzzles[puzzleOrder].finished = true
    self:initPuzzlePic(self:getChild("Pages.Panel"..pageNum..".Panel"..puzzleNum), puzzleOrder)
    self:setEvent("Pages.Panel"..pageNum..".BtnPuzzle"..puzzleNum, self:getEnterGameFunc(puzzleOrder))
end

function PuzzlePages:getNumFromId(puzzleId)
    local puzzleOrder = puzzleId - self.startId + 1
    local pageNum = math.ceil(puzzleOrder / config.puzzlePerPage)
    local puzzleNum = puzzleOrder - (pageNum - 1) * config.puzzlePerPage
    return {puzzleOrder, pageNum, puzzleNum}
end

return PuzzlePages
