local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")

local Rank = class("Rank", function ()
    return PanelBase.new("Rank.csb")
end)

function Rank:ctor(parent)
    self:init(parent)
    self:setButtons()
    self:setTexts()
end

function Rank:setButtons()
    self:setEvent("CloseButton", function () self:close(self.cb) end )
end

function Rank:setTexts()
    for i = 1, 8 do
        local best = userfile.get("best"..i)
        if best > 0 then
            self:setText("r"..i, best)
        else
            return
        end
    end
end

return Rank
