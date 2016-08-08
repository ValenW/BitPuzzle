local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Setting = class("Setting", function ()
    return PanelBase.new("Setting.csb")
end)

function Setting:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()

end

function Setting:setButtons()
    self:setEvent("CloseButton",    function () self:close() end )
    self:setEvent("StarButton",     function () self:star() end )
    self:setEvent("MusicButton",    function () self:changeMusic() end)
    self:setEvent("FacebookButton", function () self:facebook() end)
    if device.platform == "ios" then
        self:setEvent("RestoreButton",  function () self:restore() end)
    else
        local restoreBtn = self:getChildByName("RestoreButton")
        restoreBtn:setVisible(false)
    end
end

function Setting:setTexts()
    local newBtn, oldBtn = nil, self:getChildByName("MusicButton")
    if userfile.get("music") == 0 then
        newBtn = ccui.Button:create("ui/btn-nomusic-n.png", "ui/btn-nomusic-p.png", "ui/btn-nomusic-p.png", ccui.TextureResType.localType)
    else
        newBtn = ccui.Button:create("ui/btn-music-n.png", "ui/btn-music-p.png", "ui/btn-music-p.png", ccui.TextureResType.localType)
    end
    newBtn:setPosition(cc.p(oldBtn:getPosition()))
    newBtn:setName("MusicButton")
    oldBtn:removeFromParent(true)
    self:add(newBtn)
    
    self:setEvent("MusicButton",    function () self:changeMusic() end)
end

function Setting:changeMusic()
    self:musicToggle()
    self:setTexts()
end

return Setting
