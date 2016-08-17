local config = require("app.MyConfig")
local userfile = config.userfile

local Panels = require("app.panel.Panels")

local SceneBase = class("SceneBase", function()
    return cc.Scene:create()
end)

function SceneBase:init(filename)
    self.panel = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile(filename)
    self:addChild(self.panel)
end

function SceneBase:getChild(name)
    local t = {}
    for w in string.gmatch(name, "([^'.']+)") do     --按照“.”分割字符串
        table.insert(t, w) 
    end

    local child = self.panel
    for _, v in ipairs(t) do
        child = child:getChildByName(v)
        if child == nil then
            return nil
        end
    end
    return child
end

function SceneBase:addChildByName(name, child)
    local parent = self:getChild(name)
    parent:addChild(child)
end

function SceneBase:setEvent(name, callback, drawCallback)
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

function SceneBase:setText(name, set)
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

function SceneBase:setButtonEnable(name, ifEnable)
    local toSet = self:getChild(name)
    toSet:setTouchEnabled(ifEnable)
    toSet:setBright(ifEnable)
end

function SceneBase:getChildPosition(name)
    return cc.p(self:getChild(name):getPosition())
end

function SceneBase:setChildPosition(name, pos)
    self:getChild(name):setPosition(pos)
end

function SceneBase:setChildPositionByAnother(name1, name2)
    self:setChildPosition(name1, self:getChildPosition(name2))
end

function SceneBase:enterSceneByName(sceneName)
    app:enterScene(sceneName)
end

return SceneBase
