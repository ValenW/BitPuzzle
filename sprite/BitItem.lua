local Item = require("app.Sprite.Item")

local config = require("app.MyConfig")
local userfile = config.userfile

local BitItem = class("BitItem", Item)

function BitItem:ctor(matrix, length, puzzleItem)
    self:init(matrix, length)
    self.layout:addTouchEventListener(handler(self, self.touchHandler))
    self.layout:setPropagateTouchEvents(false)
    self.puzzleItem = puzzleItem
end

function BitItem:touchHandler(sender, eventType)
    if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        if sender.broadCost then
            dump("end")
            self:onTouchEnd(sender)
        end
--        return true
    elseif eventType == ccui.TouchEventType.began then
        dump("began")
        self:onTouchBegan(sender)
--        return true
    elseif sender.broadCost then
        dump("moving")
        self:onTouchMoving(sender)
--        return true
    end
end

function BitItem:onTouchBegan(sender)
    if not self:locInBits(sender) then
        sender.broadCost = false
        sender:setSwallowTouches(false)
        return
    end
    sender.broadCost = true
    sender:setSwallowTouches(true)
    self.layout.opos = self:getWorldPos()
    self:showEdge()
    self:showShadow()
    self.layout:setLocalZOrder(config.listOrder + 1)
    self.puzzleItem:clearOld(self.matrix, self.layout.opos)
end

function BitItem:onTouchMoving(sender)
    local prevPos = sender:getTouchBeganPosition()
    local nowPos = sender:getTouchMovePosition()
    local opos = sender.opos
    local lpos = cc.p(nowPos.x - prevPos.x, nowPos.y - prevPos.y)
    local pos = cc.p(opos.x + lpos.x, opos.y + lpos.y)
    if self.parentPanel ~= nil then
        pos = self.parentPanel:convertToNodeSpace(pos)
    end
    sender:setPosition(pos)

    self.lastTouchPos = nowPos
    self:updateShadowPos()
end

function BitItem:onTouchEnd(sender)
    self:hideEdge()
    self:hideShadow()
    self:putSelf()
    self.layout:setLocalZOrder(config.listOrder - 1)
end

function BitItem:locInBits(sender)
    local pos = self.layout:convertToNodeSpace(cc.p(sender:getTouchBeganPosition()))
    pos = cc.p(math.floor(pos.x / self.blockLength) + 1, math.floor(pos.y / self.blockLength) + 1)
    if self.matrix[pos.x][pos.y] == 0 then
        return false
    else
        return true
    end
end

-- Edge and shadow --
function BitItem:showShadow()
    local clone = nil
    if self.shadow == nil then
        clone = BitItem.new(self.matrix, self.blockLength)
        clone.layout:setCascadeOpacityEnabled(true)
        clone.layout:setLocalZOrder(config.listOrder - 1)
        clone.layout:setOpacity(config.shadowOpacity)
        self.shadow = clone
        self.puzzleItem.layout:getParent():add(self.shadow.layout)
    end
    
    local pos = self:getWorldPos()
    self.shadow.layout:setPosition(pos)
    self.shadow.layout:setVisible(true)
    return self.shadow
end

function BitItem:hideShadow()
    if self.shadow ~= nil then
        self.shadow.layout:setVisible(false)
    end
end

function BitItem:showEdge()
    if self.edge == nil then
        self:addEdgeSpr("ui/edge_white.png", true)
        self.edge = true
    end
    self:setVisibilityByTag(config.edgeTag, true)
end

function BitItem:hideEdge()
    if self.edge == nil then return nil end
    self:setVisibilityByTag(config.edgeTag)
end

-- update shadow and pos --
function BitItem:updateShadowPos()
    local pos = self:getWorldPos()

    if self:inList(pos) then
        self:moveToList()
        local parentPos = cc.p(self.parentPanel:getPosition())
        local parentWorldPos = cc.p(self.listView:convertToWorldSpace(parentPos))
        self.shadow.layout:setPosition(parentWorldPos)
    else
        local result = self.puzzleItem:put(self.matrix, pos)
        if result ~= false then
            self.shadow.layout:setPosition(result)
        end
    end
end

function BitItem:putSelf()
    if self:inList() then
        self:moveToList()
        self.layout:setPosition(0, 0)
    else
        local result = self.puzzleItem:put(self.matrix, cc.p(self.shadow.layout:getPosition()), true)
        if result ~= false then
            self:moveToWorld()
            self.layout:setPosition(cc.p(self.shadow.layout:getPosition()))
        else
            self.layout:setPosition(0, 0)
        end
    end
end

function BitItem:moveToWorld()
    if self.parentPanel ~= nil then
        local pos = self:getWorldPos()
        self.layout:setPosition(pos)
        self.layout:removeFromParent()
        self.puzzleItem.layout:getParent():addChild(self.layout, config.listOrder - 1)
        for i = 0, 1000 do
            local item = self.listView:getItem(i)
            if item ~= nil then
                if item == self.parentPanel then
                    self.listView:removeItem(i)
                    break
                end
            else
                break
            end
        end
        self.parentPanel = nil
    end
end

function BitItem:moveToList()
    if self.parentPanel == nil then
        local clone = self.layout:clone()
        clone:setTouchEnabled(false)
        local index = self:getIndexInListView()
        self.listView:insertCustomItem(clone, index)
        self.layout:removeFromParent()
        self.layout:setPosition( cc.p(clone:convertToNodeSpace(self:getWorldPos())) )

        self.parentPanel = clone
        clone:addChild(self.layout)
    end
end

-- util function --
function BitItem:setListView(listView)
    self.listView = listView
    local pos, size = cc.p(self.listView:getPosition()), self.listView:getContentSize()
    self.listRect = cc.rect(pos.x, pos.y, size.width, size.height)
end

function BitItem:getIndexInListView(pos)
    if pos == nil then
        pos = self:getWorldPos()
    end
    local inner = self.listView:getInnerContainer()
    pos.x = pos.x - cc.p(inner:getPosition()).x
    local lastIndex = 0
    for i = 0, 1000 do
        local item = self.listView:getItem(i)
        if item == nil then
            lastIndex = i
            break
        end
        lastIndex = i
        if pos.x < ( cc.p(item:getPosition()).x + item:getContentSize().width / 2 ) then
            break
        end
    end
    return lastIndex
end

function BitItem:inList()
    return cc.rectContainsPoint(self.listRect, self:getWorldPos())
end

function BitItem:getWorldPos()
    local pos = cc.p(self.layout:getPosition())
    if self.parentPanel ~= nil then
        pos = self.parentPanel:convertToWorldSpace(pos)
    end
    return pos
end

return BitItem
