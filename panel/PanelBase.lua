AudioController = require("app.helper.AudioController").new()
local config = require("app.MyConfig")
local userfile = config.userfile

local PanelBase = class("PanelBase", function(filename, noOver, noClose)
    local node = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile(filename)
    if noOver == nil then
        local layout = ccui.Layout:create()
        layout:setContentSize(CC_DESIGN_RESOLUTION)
        layout:setTouchEnabled(true)
        if noClose == nil then
            layout:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    node:close()
                end
            end)
        end
        layout:addTo(node, -100)
    end
    return node
end)

PanelBase.panel = nil

function PanelBase:init(parent, initAction)
    if initAction == nil then
        self:setScale(0.1)
        local scaleUp, scaleDown = cc.ScaleTo:create(0.1, 1.3), cc.ScaleTo:create(0.1, 1)
        initAction = cc.Sequence:create(scaleUp, scaleDown)
    end
    if initAction ~= false then
        self:runAction(initAction)
    end
    parent:addChild(self)
end

function PanelBase:getChild(name)
    local t = {}
    for w in string.gmatch(name, "([^'.']+)") do     --按照“.”分割字符串
        table.insert(t, w) 
    end

    local child = self
    for _, v in ipairs(t) do
        child = child:getChildByName(v)
        if child == nil then
            return nil
        end
    end
    return child
end

function PanelBase:setEvent(name, callback, drawCallback)
    local child = self:getChild(name)
    if child == nil then
        return nil
    end

    if child.addTouchEventListener then
        child:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                sender.opos = cc.p(sender:getPosition())
                AudioController:whenButton()
                return true
            elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                callback(sender, true)
            elseif drawCallback ~= nil then
                drawCallback(sender)
            end
        end)
    else
        child:setTouchEnabled(true)
        child:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
            event.spr = child
            if event.name == "began" then
                child.opos = cc.p(child:getPosition())
                AudioController:whenButton()
                return true
            elseif drawCallback ~= nil then
                drawCallback(event)
            else
                callback(event)
            end
        end)
    end
end

function PanelBase:setText(name, set)
    local toSet = self:getChild(name)
    if toSet == nil then
        return nil
    end

    if toSet.setTexture ~= nil then
        toSet:setTexture(set)
    elseif toSet.setString ~= nil then
        toSet:setString(set)
    else
        -- wrong
    end
end

function PanelBase:setButtonEnable(name, ifEnable)
    local toSet = self:getChild(name)
    toSet:setTouchEnabled(ifEnable)
    toSet:setBright(ifEnable)
    toSet:setEnabled(ifEnable)
end

function PanelBase:getPositionByName(name)
	local toGet = self:getChildByName(name)
	return toGet:getPosition()
end

function PanelBase:close(cb)
    if cb ~= nil then cb() end
    if self.cb ~= nil then self.cb() end
    self:removeFromParent(true)
end

function PanelBase:musicToggle()
    if AudioController.play == true then
        AudioController:stop()
        return false
    else
        AudioController:start()
        return true
    end
end

function PanelBase:star()
    GradeManager:openMarket()
end

function PanelBase:facebook()
    local url = nil
    if device.platform == "ios" then
        url = config.iurl
    else
        url = config.aurl
    end
    ShareManager:shareOnFB("Play with me in EmojiDab!", string.format(config.shareWord, userfile.get("best1")), url)
end

function PanelBase:restore()
    NativeProxy:getInstance():restore(function (ids)
        for _, key in ipairs(ids) do
            if key == config.productID["allskins"] then
                for i = 2, config.themeNum do
                    userfile.set("skin"..i, 1)
                end
            elseif key == config.productID["noad"] then
                AdManager:stopAdAndSave()
            else
                for i = 2, 8 do
                    if key == config.productID["s"..(i - 1)] then
                        userfile.set("skin"..i, 1)
                    end
                end
            end
        end
    end)
end

function PanelBase:buy(productName, callback)
    local productId = config.productID[productName]
    NativeProxy:getInstance():buyProduct(productId, function (res)
        if res == true then
            callback()
        end
    end)
end

return PanelBase
