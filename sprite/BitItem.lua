local Item = require("app.Sprite.Item")

local config = require("app.MyConfig")
local userfile = config.userfile

local BitItem = class("BitItem", Item)

function BitItem:ctor(matrix, length, puzzleItem)
    self:init(matrix, length)
    self.layout:addTouchEventListener(handler(self, self.touchHandler))
    self.puzzleItem = puzzleItem
end

function BitItem:touchHandler(sender, eventType)
    if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        self:onTouchEnd(sender)
    elseif eventType == ccui.TouchEventType.began then
        self:onTouchBegan(sender)
        return true
    else
        self:onTouchMoving(sender)
    end
end

function BitItem:onTouchBegan(sender)
    self.layout.opos = cc.p(sender:getPosition())
    self:showEdge()
    self:showShadow()
end

function BitItem:onTouchMoving(sender)
    local prevPos = sender:getTouchBeganPosition()
    local nowPos = sender:getTouchMovePosition()
    local opos = sender.opos
    local lpos = cc.p(nowPos.x - prevPos.x, nowPos.y - prevPos.y)
    local newx, newy = math.max(math.min(opos.x + lpos.x, display.width - 10), 10), math.max(math.min(opos.y + lpos.y, display.height - 10), 10)
    sender:setPosition(cc.p(newx, newy))

    self:updateShadowPos()
end

function BitItem:onTouchEnd(sender)
    self:hideEdge()
    self:hideShadow()
    self:putSelf()
end

-- Edge and shadow --
function BitItem:showShadow()
    local clone = nil
    if self.shadow == nil then
        clone = BitItem.new(self.matrix, self.blockLength)
        clone.layout:setCascadeOpacityEnabled(true)
        clone.layout:setLocalZOrder(config.shadowZ)
        clone.layout:setOpacity(100)
        self.shadow = clone
        self.layout:add(self.shadow.layout)
    end
    local pos = cc.p(self.layout:getPosition())
    dump(pos)
    self.shadow.layout:setPosition(cc.p(0, 0))
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

-- update shadow --
function BitItem:updateShadowPos()
    local result = self.puzzleItem:put(self.matrix, cc.p(self.layout:getPosition()))
    if result ~= false then
        self.shadow.layout:setPosition(result)
    end
end

function BitItem:putSelf()
    local result = self.puzzleItem:put(self.matrix, cc.p(self.layout:getPosition()), cc.p(self.layout.opos))
    if result ~= false then
        self.shadow.layout:setPosition(result)
    end
    self.layout:setPosition(cc.p(self.shadow.layout:getPosition()))
    self.shadow.layout:setVisible(false)
end

return BitItem
