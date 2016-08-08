AudioController = require("app.helper.AudioController").new()
local config = require("app.MyConfig")
local userfile = config.userfile

local PanelBase = class("PanelBase", function(filename)
    local node = cc.CSLoader:getInstance():createNodeWithFlatBuffersFile(filename)
    local layout = ccui.Layout:create()
    layout:setContentSize(CC_DESIGN_RESOLUTION)
    layout:setTouchEnabled(true)
    layout:addTo(node, -100)
    return node
end)

PanelBase.panel = nil

function PanelBase:init(parent)
    self:setScale(0.1)
    local scaleUp, scaleDown = cc.ScaleTo:create(0.1, 1.3), cc.ScaleTo:create(0.1, 1)
    self:runAction(cc.Sequence:create(scaleUp, scaleDown))
    parent:addChild(self)
end

function PanelBase:setEvent(name, callback)
    local btn = self:getChildByName(name)
    btn:addTouchEventListener(function(sender, eventType)
        if eventType == 0 then
            return true
        elseif eventType == 2 then
            if name ~= "CloseButton" then
                AudioController:whenButton()
            end
            callback()
        end
    end)
end

function PanelBase:setText(name, set)
    local toSet = self:getChildByName(name)
    if toSet.setTexture ~= nil then
        toSet:setTexture(set)
    elseif toSet.setString ~= nil then
        toSet:setString(set)
    else
        -- wrong
    end
end

function PanelBase:setButtonEnable(name, ifEnable)
    local toSet = self:getChildByName(name)
    toSet:setTouchEnabled(ifEnable)
    toSet:setBright(ifEnable)
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
