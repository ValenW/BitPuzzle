local PuzzleEditor = require("app.sprite.PuzzleEditor")
local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")
local GameScene = require("app.scenes.GameScene")

local utils = require("app.myUtils")

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
    self.typeNum = 1
    self.size = 1
end

function DiyScene:setTexts()
    for _, i in ipairs({"Block", "Cut"}) do
        self:setEvent("PageView."..i.."Panel.block0", handler(self, self.selectColor))
        self:getChild("PageView."..i.."Panel.block0").id = 0
    end
    local locWid, intervalHeight = {}
    local basePath = "PageView.BlockPanel.ScrollView"

    for j = 1, config.colorPerCul do
        local childPath = basePath..".block"..j
        local child = self:getChild(childPath)
        locWid[j] = self:getChildPosition(childPath)
    end

    local childPath = basePath..".block"..(config.colorPerCul + 1)
    intervalHeight = self:getChildPosition(childPath).y - locWid[1].y

    self.locWid, self.intervalHeight = locWid, intervalHeight
    self:setBoard("Block", 1)
    self:setBoard("Cut", 1)
end

function DiyScene:setEvents()
    for _, i in ipairs({"Block", "Cut"}) do
        self:setEvent("PageView."..i.."Panel.block0", handler(self, self.selectColor))
        self:getChild("PageView."..i.."Panel.block0").id = 0
    end
    
    self:setEvent("PuzzleBoard", handler(self, self.puzzleBoardTouch), handler(self, self.puzzleBoardTouch))
    self:setEvent("BtnExport", handler(self, self.export))
    self:setEvent("BtnImport", handler(self, self.import))
    self:setEvent("BtnColor", handler(self, self.selectColorType))
    self:setEvent("BtnReset", handler(self, self.reset))
    self:setEvent("BtnSize", handler(self, self.changeSize))
    self:setEvent("BtnPlay", handler(self, self.tryPlay))
    self:setEvent("BtnBack", handler(self, self.back))
    self:getChild("PageView"):addEventListener(handler(self, self.changePage))
end

function DiyScene:changeSize()
    if self.size == 1 then
        self.size = 3
        self:getChild("BtnSize"):setTitleText("3x3")
    else
        self.size = 1
        self:getChild("BtnSize"):setTitleText("1x1")
    end
end

function DiyScene:tryPlay()
    self.editor:export("tryPlay.txt")
    local gameScene = GameScene.new("tryPlay.txt")
    cc.Director:getInstance():pushScene(gameScene)
end

function DiyScene:setBoard(type, typeNum)
    local colorNum = config.colors[typeNum]
    if type == "Cut" then
        colorNum = config.cuts[typeNum]
    end
    if colorNum == nil then
        return false
    end

    self.typeNum = typeNum
    
    local basePath = "PageView."..type.."Panel.ScrollView"
    for i = 1, colorNum do
        local childPath = basePath..".block"..i
        local child = self:getChild(childPath)
        if child == nil then
            child = cc.Sprite:create()
            child:setName("block"..i)
            self:addChildByName(basePath, child)
        end

        child.typeNum = typeNum
        child.id = i

        local indx, indy = math.fmod(i, config.colorPerCul), math.floor((i - 1) / config.colorPerCul)
        if indx == 0 then
            indx = config.colorPerCul
        end
        self:setChildPosition(childPath, cc.p(self.locWid[indx].x, self.locWid[1].y + indy * self.intervalHeight))

        local filePath = string.format(type.."s/%02d/%02d.png", typeNum, i)

        self:setEvent(childPath, handler(self, self.selectColor))
        self:setText(childPath, filePath)
    end

    for i = colorNum + 1, 100 do
        local childPath = basePath..".block"..i
        local child = self:getChild(childPath)
        if child == nil then
            break
        end
        child:removeFromParent(true)
    end

    self:getChild("PageView."..type.."Panel.select0"):setVisible(false)
end

function DiyScene:export()
    local time = userfile.get("times") + 1
    if self.importNum then
        time = self.importNum
    end
    self.editor:export("cut "..time..".txt")
    userfile.add("times", 1)
end

function DiyScene:import()
    local num = self:getChild("ImportTxt"):getString() -- tonumber(self:getChild("ImportTxt"):getString())
    if num == nil then
        dump("Not a Num, import newst puzzle")
        num = userfile.get("times")
    end
    
    self.editor:import(num..".txt")
    self:fresh()
    self.importNum = num
end

function DiyScene:selectColorType()
    local num = tonumber(self:getChild("ColorTxt"):getString())
    if num == nil then
        dump("Not a Num!")
        return false
    end

    local types, setType = {"Block", "Cut"}, self.pageView:getCurPageIndex() + 1
    self:setBoard("Block", num)
    self:selectColor({spr = {id = 1}})
end

function DiyScene:fresh()
    local puzzle = self.editor:getPuzzle()

    for i = config.boardLength, 1, -1 do
        for j = 1, config.boardLength do
            local type, id = math.floor(puzzle.matrix[j][i] / 100), math.fmod(puzzle.matrix[j][i], 100)
            self:addPuzzle(j - 1, i - 1, type, id, 1)
            type, id = math.floor(puzzle.cut[j][i] / 100), math.fmod(puzzle.cut[j][i], 100)
            self:addPuzzle(j - 1, i - 1, type, id, 2)
        end
    end

    self:changePage(nil, ccui.PageViewEventType.turning)
end

function DiyScene:reset()
    self.editor.puzzle:setDefault()
    self:fresh()
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

function DiyScene:setPuzzle(pos, typeNum, id, setType)
    if setType == nil then
        setType = self.pageView:getCurPageIndex() + 1
    end
    if id == nil then
        id = self.idNow[setType]
    end
    if typeNum == nil then
        typeNum = self.typeNum
        if id == 0 then
            typeNum = 0
        elseif setType == 2 then
            typeNum = 1
        end
    end

    local x, y = math.floor(pos.x / self.blockLength), math.floor(pos.y / self.blockLength)
    if x < 0 or x >= config.boardLength or y < 0 or y > config.boardLength then
        return false
    end

    self:addPuzzle(x, y, typeNum, id, setType)

    if self.size == 3 and setType ~= 1 then
        for i = -1, 1 do
            for j = -1, 1 do
                local xx, yy = x + i, y + j
                if not (xx < 0 or xx >= config.boardLength or yy < 0 or yy > config.boardLength) then
                    self:addPuzzle(xx, yy, typeNum, id, setType)
                end
            end
        end
    end

end

function DiyScene:addPuzzle(x, y, typeNum, id, setType)
    local tag = (x * config.boardLength + y) + (setType * config.boardLength * config.boardLength)
    local path, result = string.format("/%02d/%02d.png", typeNum, id)

    if setType == 1 then
        path = "Blocks"..path
        result = self.editor:set({x + 1, y + 1}, typeNum * 100 + id)
    else
        path = "Cuts"..path
        result = self.editor:setCut({x + 1, y + 1}, typeNum * 100 + id)
    end
    
    dump(path)
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

function DiyScene:back()
    self:enterSceneByName("MainScene")
end

return DiyScene
