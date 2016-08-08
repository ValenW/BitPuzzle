local PuzzleEditor = require("app.sprite.PuzzleEditor")
local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")

local DiyScene = class("DiyScene", SceneBase)

function DiyScene:ctor()
    self:init("DiyScene.csb")

    self.editor = PuzzleEditor.new()
    self.pageView = self:getChild("PageView")
    self.pageView:setSwallowTouches(false)
    self:getChild("PageView.BlockPanel.ScrollView"):setSwallowTouches(false)
    self:getChild("PageView.CutPanel.ScrollView"):setSwallowTouches(false)
    
    self.puzzleBoard = self:getChild("PuzzleBoardBG")
    self.blockLength = self.puzzleBoard:getContentSize().width / config.boardLength

    self:setEvents()
    self:setTexts()

    self.type = 1
    self.idNow = {1, 1}
end

function DiyScene:setTexts()
    local locWid, intervalHeight = {}
    for _, i in ipairs({"Block", "Cut"}) do
    
        for j = 1, config[i.."Num"] do
            local basePath = "PageView."..i.."Panel.ScrollView"
            local childPath = basePath..".block"..j
            local child = self:getChild(childPath)

            if j <= config.colorPerCul then
                locWid[j] = self:getChildPosition(childPath)
            elseif j == config.colorPerCul + 1 then
                intervalHeight = self:getChildPosition(childPath).y - locWid[1].y
            else
                local indx, indy = math.fmod(j, config.colorPerCul), math.floor((j - 1) / config.colorPerCul)
                if indx == 0 then
                    indx = config.colorPerCul
                end
                if child == nil then
                    child = cc.SPrite:create()
                    child:setName("block"..j)
                    self:addChildByName(basePath, child)
                else
                    self:setChildPosition(childPath, cc.p(locWid[indx].x, locWid[1].y + indy * intervalHeight))
                end
            end

            local path = string.format(i.."s/%d/p%d.png", config[i.."Now"], j)
            self:setText(childPath, path)
        end
        self:getChild("PageView."..i.."Panel.select0"):setVisible(false)
    end
end

function DiyScene:setEvents()
    for _, i in ipairs({"Block", "Cut"}) do
        self:setEvent("PageView."..i.."Panel.block0", handler(self, self.selectColor))
        self:getChild("PageView."..i.."Panel.block0").id = 0
        for j = 1, config[i.."Num"] do
            local childPath = "PageView."..i.."Panel.ScrollView.block"..j
            self:setEvent(childPath, handler(self, self.selectColor))
            self:getChild(childPath).id = j
        end
    end
    
    self:setEvent("PuzzleBoard", handler(self, self.puzzleBoardTouch), handler(self, self.puzzleBoardTouch))
    self:setEvent("BtnExport", handler(self, self.export))
    self:setEvent("BtnImport", handler(self, self.import))
    self:getChild("PageView"):addEventListener(handler(self, self.changePage))
end

function DiyScene:export()
    local time = userfile.get("times") + 1
    self.editor:export(time.."th puzzle.txt")
    userfile.add("times", 1)
end

function DiyScene:import()
    local time = userfile.get("times")
    self.editor:import(time.."th puzzle.txt")
    self:fresh()
end

function DiyScene:fresh()
    local puzzle = self.editor:getPuzzle()

    for i = config.boardLength, 1, -1 do
        for j = 1, config.boardLength do
            self:addPuzzle(j - 1, i - 1, puzzle.matrix[j][i], 1)
        end
    end

    for i = config.boardLength, 1, -1 do
        for j = 1, config.boardLength do
            self:addPuzzle(j - 1, i - 1, puzzle.cut[j][i], 2)
        end
    end

    self:changePage(nil, ccui.PageViewEventType.turning)
end

function DiyScene:changePage(sender, eventType)
    if eventType == ccui.PageViewEventType.turning then
        local index = self.pageView:getCurPageIndex() + 1
        local ifVisible = false
        if index == 2 then ifVisible = true end
        local baseTag = 2 * config.boardLength * config.boardLength
        for _, c in pairs(self.puzzleBoard:getChildren()) do
            if c:getTag() >= baseTag then
                c:setVisible(ifVisible)
            end
        end
    end
end

function DiyScene:selectColor(sender)
    local type = self.pageView:getCurPageIndex() + 1
    self.idNow[type] = sender.spr.id
    
    local name = {"Block", "Cut"}
    local basePath = "PageView."..name[type].."Panel.ScrollView."
    if self.idNow[type] ~= 0 then
        self:getChild("PageView."..name[type].."Panel.select0"):setVisible(false)
        self:getChild(basePath.."select"):setVisible(true)
        self:setChildPositionByAnother(basePath.."select", basePath.."block"..self.idNow[type])
    else
        self:getChild(basePath.."select"):setVisible(false)
        self:getChild("PageView."..name[type].."Panel.select0"):setVisible(true)
    end
end

function DiyScene:puzzleBoardTouch(sender, ifEnd)
    local pos = cc.p(sender:getTouchMovePosition())
    if ifEnd then
        pos = cc.p(sender:getTouchEndPosition())
    end
    pos = self.puzzleBoard:convertToNodeSpace(pos)
    
    self:setPuzzle(pos)
end

function DiyScene:setPuzzle(pos, id, setType)
    if setType == nil then
        setType = self.pageView:getCurPageIndex() + 1
    end
    if id == nil then
        id = self.idNow[setType]
    end

    local x, y = math.floor(pos.x / self.blockLength), math.floor(pos.y / self.blockLength)
    if x < 0 or x >= config.boardLength or y < 0 or y > config.boardLength then
        return false
    end

    self:addPuzzle(x, y, id, setType)
end

function DiyScene:addPuzzle(x, y, id, setType)
    local tag = (x * config.boardLength + y) + (setType * config.boardLength * config.boardLength)
    local path, result = string.format("/%d/p%d.png", config.BlockNow, id)

    if setType == 1 then
        path = "Blocks"..path
        result = self.editor:set({x + 1, y + 1}, id)
    else
        path = "Cuts"..path
        result = self.editor:setCut({x + 1, y + 1}, id)
    end
    
    if result == 0 then
        self.puzzleBoard:removeChildByTag(tag, true)
        if setType == 1 then
            self.puzzleBoard:removeChildByTag(tag + config.boardLength * config.boardLength, true)
        end
    elseif result == -1 then
        return false
    else
        local sp = self.puzzleBoard:getChildByTag(tag)
        if sp ~= nil then
            sp:setTexture(path)
        else
            local sp = cc.Sprite:create(path)
            local size = sp:getContentSize()
            sp:setScale(self.blockLength / size.width, self.blockLength / size.height)
            sp:setPosition((x + 0.5) * self.blockLength, (y + 0.5) * self.blockLength)
            sp:setTag(tag)
            self.puzzleBoard:addChild(sp, setType)
        end
    end
end

return DiyScene
