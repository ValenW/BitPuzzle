local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")
local PuzzlePages = require("app.panel.PuzzlePages")
local Puzzle = require("app.sprite.Puzzle")

local LevelPages = class("LevelPages", function ()
    return PanelBase.new("Scene/LevelPages.csb", true)
end)

function LevelPages:ctor(parent)
    self:init(parent, false)
    self.levelNum = math.ceil(config.puzzleNum / config.puzzlePerLevel)
    self.pageNum = math.ceil(self.levelNum / config.levelPerPage)

    self:initPages()
    self:setButtonsAndTexts()
end

function LevelPages:initPages()
    local pageView = self:getChild("Pages")
    pageView:setTouchEnabled(true)
    for i = 2, self.pageNum do
        local clone = self:getChild("Pages.Panel1"):clone()
        clone:setName("Panel"..i)
        pageView:addPage(clone)
    end
end

function LevelPages:setButtonsAndTexts()
    for i = 1, self.pageNum - 1 do
        local basePuzzleId = (i - 1) * config.puzzlePerLevel * config.levelPerPage
        for j = 1, config.levelPerPage do
            self:setEvent("Pages.Panel"..i..".BtnLv"..j, self:getEnterPuzzlesFunc(i, j))
            
            if userfile.get("Level"..((i - 1) * config.levelPerPage + j)) == 1 then
                self:setButtonEnable("Pages.Panel"..i..".BtnLv"..j, true)
            else
                self:setButtonEnable("Pages.Panel"..i..".BtnLv"..j, false)
            end

            local startPuzzleId = basePuzzleId + (j - 1) * config.puzzlePerLevel + 1
            self:setText("Pages.Panel"..i..".BtnLv"..j..".TxtLv"..j, startPuzzleId.."-"..(startPuzzleId + config.puzzlePerLevel - 1))
        end
    end

    local leftPuzzle = config.puzzleNum - config.puzzlePerLevel * config.levelPerPage * (self.pageNum - 1)
    local leftLevel = math.ceil(leftPuzzle / config.puzzlePerLevel)

    local startPuzzleId = config.puzzlePerLevel * config.levelPerPage * (self.pageNum - 1) + 1
    for i = 1, leftLevel do
        self:setEvent("Pages.Panel"..self.pageNum..".BtnLv"..i, self:getEnterPuzzlesFunc(self.pageNum, i))
        
        if userfile.get("Level"..((self.pageNum - 1) * config.levelPerPage + i)) == 1 then
            self:setButtonEnable("Pages.Panel"..self.pageNum..".BtnLv"..i, true)
        else
            self:setButtonEnable("Pages.Panel"..self.pageNum..".BtnLv"..i, false)
        end
        
        local setTxt = nil
        if i < leftLevel then
            setTxt = startPuzzleId.."-"..(startPuzzleId + config.puzzlePerLevel - 1)
        else
            setTxt = startPuzzleId.."-"..config.puzzleNum
        end
        self:setText("Pages.Panel"..self.pageNum..".BtnLv"..i..".TxtLv"..i, setTxt)
    end

    for i = leftLevel + 1, config.levelPerPage do
        self:getChild("Pages.Panel"..self.pageNum..".BtnLv"..i):removeFromParent(true)
    end
end

function LevelPages:getEnterPuzzlesFunc(pageNum, id)
    local re = function ()
        local btn = self:getChild("Pages.Panel"..pageNum..".BtnLv"..id..".TxtLv"..id)
        local txt = btn:getString()
        local tbl = {}
        for w in string.gmatch(txt, "([^-]+)") do
            table.insert(tbl, tonumber(w))
        end

        local puzzles = {}
        puzzles.startId = tbl[1]
        for i = 0, tbl[2] - tbl[1] do
            puzzles[i + 1] = Puzzle.new(string.format("cut %d.txt", i + tbl[1]))
            puzzles[i + 1].id = puzzles.startId + i
            if userfile.get("Puzzle"..(i + tbl[1])) == 1 then
                puzzles[i + 1].finished = true
            else
                puzzles[i + 1].finished = false
            end
        end

        self:replacePages(pageNum, id, puzzles)
    end
    return re
end

function LevelPages:replacePages(pageNum, id, puzzles)
    local page = self:getChild("Pages.Panel"..pageNum)

    local hideAction = cc.FadeOut:create(0.2)
    for i = 1, config.levelPerPage do
        if i ~= id then
            self:getChild("Pages.Panel"..pageNum..".BtnLv"..i):runAction(hideAction:clone())
        end
    end

    local backPos = cc.p(self:getParent():getChild("BtnBack"):getPosition())
    backPos = self:getChild("Pages"):convertToNodeSpace(backPos)
    local moveAction, scaleAction = cc.MoveTo:create(0.3, backPos), cc.ScaleTo:create(0.3, 0.4)

    local runFunc = function ()
        self.puzzlePage = PuzzlePages.new(self:getParent(), puzzles)
        self:getParent():refreshPages(self.puzzlePage:getChild("Pages"))
        self:getParent():setButtonEnable("BtnBack", false)
        self:getParent():getChild("BtnBack"):setVisible(false)
    end
    
    local btn = self:getChild("Pages.Panel"..pageNum..".BtnLv"..id)
    btn.oldPos = cc.p(btn:getPosition())
    local moveScaleAction = cc.Spawn:create(moveAction, scaleAction)
    local replaceAction = cc.CallFunc:create(runFunc)
    local action = cc.Sequence:create(moveScaleAction, replaceAction)
    btn:runAction(action)

    self:setEvent("Pages.Panel"..pageNum..".BtnLv"..id, self:getBackFunc(pageNum, id))
end

function LevelPages:getBackFunc(pageNum, id)
    local re = function ()
        self.puzzlePage:removeFromParent(true)
        self:getParent().pages = self:getChild("Pages")
        self:getParent():refreshPages(self:getChild("Pages"))
        self:getParent():setButtonEnable("BtnBack", true)
        self:getParent():getChild("BtnBack"):setVisible(true)

        local showAction = cc.FadeIn:create(0.3)
        for i = 1, config.levelPerPage do
            if i ~= id then
                self:getChild("Pages.Panel"..pageNum..".BtnLv"..i):runAction(showAction:clone())
                self:getChild("Pages.Panel"..pageNum..".BtnLv"..i..".TxtLv"..i):runAction(showAction:clone())
            end
        end

        local btn = self:getChild("Pages.Panel"..pageNum..".BtnLv"..id)
        local moveAction, scaleAction = cc.MoveTo:create(0.3, btn.oldPos), cc.ScaleTo:create(0.3, 1)
        btn:runAction(cc.Spawn:create(moveAction, scaleAction))

        self:setEvent("Pages.Panel"..pageNum..".BtnLv"..id, self:getEnterPuzzlesFunc(pageNum, id))
    end
    return re
end

return LevelPages
