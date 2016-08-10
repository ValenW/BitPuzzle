local Item = require("app.Sprite.Item")

local config = require("app.MyConfig")
local userfile = config.userfile

local BitItem = class("BitItem", Item)

function BitItem:ctor(matrix, length)
    self:init(matrix, length)
    self.layout:addTouchEventListener(handler(self, self.touchHandler))
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
    self.opos = cc.p(sender:getPosition())
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
    
end

function BitItem:onTouchEnd(sender)
    self:hideEdge()
    self:hideShadow()
    
end

function BitItem:showShadow()
    if self.shadow == nil then
        local clone = BitItem.new(self.matrix, self.blockLength)
        clone.layout:setCascadeOpacityEnabled(true)
        clone.layout:setLocalZOrder(config.shadowZ)
        clone.layout:setOpacity(config.opacity)
        self.shadow = clone
    end
    self.shadow.layout:setPosition(cc.p(self.layout:getPosition()))
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
        self:addEdgeSpr("ui/edge_white.png")
        self.edge = true
    end
    self:setVisibilityByTag(config.edgeTag)
end

function BitItem:hideEdge()
    if self.edge == nil then return nil end
    self:setVisibilityByTag(config.edgeTag)
end


return BitItem
