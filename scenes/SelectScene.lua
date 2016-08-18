local config = require("app.MyConfig")
local userfile = config.userfile
local SceneBase = require("app.scenes.SceneBase")

local SelectScene = class("SelectScene", SceneBase)

function SelectScene:ctor(sceneName, Pages)
    self:init("Scene/SelectSceneBase.csb")
    self.sceneName = sceneName
    self:setTexts()
    self:setEvents()
    self:initPages(Pages)
end

function SelectScene:setTexts()
    local title = string.upper(string.sub(self.sceneName, 1, 1))..string.lower(string.sub(self.sceneName, 2, -1))
    self:setText("TxtTitle", title)
    self:setText("BgTitle", "ui/pic_title_"..self.sceneName..".png")
end

function SelectScene:setEvents()
    self:setEvent("BtnBack", handler(self, self.back))
    self:setEvent("BtnSetting", handler(self, self.setting))
end

function SelectScene:initPages(Pages)
    local pages = Pages.new(self):getChild("Pages")
    self.pages = pages

    self:refreshPages()
end

function SelectScene:refreshPages(pages)
    if pages == nil then
        pages = self.pages
    else
        self.pages = pages
    end
    
    self.pages:addEventListener(handler(self, self.changePage))
    for i = 1, 100 do
        local child = self:getChild("PgPoints.Pg"..i)
        if child ~= nil then
            child:removeFromParent(true)
        else
            break
        end
    end
    
    local pgNum, ps = #self.pages:getPages(), self:getChild("PgPoints")
    if pgNum >= 2 then
        local width, height = ps:getContentSize().width / (pgNum + 1), ps:getContentSize().height / 2
        for i = 1, pgNum do
            local spr = cc.Sprite:create("ui/pic_pg_other.png")
            spr:setPosition(cc.p(width * i, height))
            spr:setName("Pg"..i)
            ps:addChild(spr)
        end
        self:setText("PgPoints.Pg1", "ui/pic_pg_now.png")
    end
end

function SelectScene:changePage(sender, eventType)
    if eventType == ccui.PageViewEventType.turning then
        local index = self.pages:getCurPageIndex() + 1
        self:setText("PgPoints.Pg"..index, "ui/pic_pg_now.png")
        self:setText("PgPoints.Pg"..(index - 1), "ui/pic_pg_other.png")
        self:setText("PgPoints.Pg"..(index + 1), "ui/pic_pg_other.png")
    end
end

function SelectScene:back()
    cc.Director:getInstance():popScene()
end

function SelectScene:update(id)
--    dump(self.pages)
--	self.pages:update(id)
end

function SelectScene:setting()
    -- TODO
end

return SelectScene
