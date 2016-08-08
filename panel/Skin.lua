local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")
local Unlock = require("app.panel.Unlock")

local Skin = class("Skin", function ()
	return PanelBase.new("Skin.csb")
end)

function Skin:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()
    self.cb = function () parent:update() end
end

function Skin:setButtons()
    self:setEvent("CloseButton", function () self:close(self.cb) end )

    local themeNow = userfile.get("theme")
    local chosen = self:getChildByName("Chosen")

    for i = 1, config.themeNum do
        self:removeChildByName(i.."lock", true)
        if i == themeNow then
            chosen:setPosition(self:getPositionByName(i.."Button"))
        end

        if userfile.get("skin"..i) == 1 then
            self:setEvent(i.."Button", function () self:changeSkin(i) end )
            self:setButtonEnable(i.."Button", true)
        else
            local lockSpr = ccui.Button:create("ui/pic-lock.png", "ui/pic-lock.png", "ui/pic-lock.png", ccui.TextureResType.localType)
            
            lockSpr:setName(i.."lock")
            lockSpr:setPosition(cc.p(self:getPositionByName(i.."Button")))
            self:addChild(lockSpr)
            self:setEvent(i.."lock", function () self:unlockSkin(i) end)
            self:setButtonEnable(i.."Button", false)
        end
    end
end

function Skin:setTexts()
    -- Nothing
end

function Skin:changeSkin(skinNum)
    local chosen = self:getChildByName("Chosen")
    chosen:setPosition(self:getPositionByName(skinNum.."Button"))
    userfile.set("theme", skinNum)
    self.cb()
end

function Skin:unlockSkin(skinNum)
    Unlock.new(self, skinNum)
end

return Skin
