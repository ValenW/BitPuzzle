local config = require("app.MyConfig")
local userfile = config.userfile
local PanelBase = require("app.panel.PanelBase")
local PuzzleItem = require("app.sprite.PuzzleItem")

local PuzzleDetail = class("PuzzleDetail", function ()
    return PanelBase.new("Layer/PuzzleDetail.csb", nil, true)
end)

function PuzzleDetail:ctor(parent, puzzle, ifPlaying, retrycb)
    self.puzzle = puzzle
    self.ifPlaying = ifPlaying
    self:init(parent, false)
    self:setButtons()
    self:setTexts()
    self.retrycb = retrycb
end

function PuzzleDetail:setButtons()
    self:setEvent("BtnClose", handler(self, self.back))
    self:setEvent("BtnShare", handler(self, self.share))
    self:setEvent("BtnRetry", handler(self, self.retry))
end

function PuzzleDetail:setTexts()
    local puzzleItemFunc = function () end
    self.puzzleItem = PuzzleItem.new(self.puzzle, self:getChild("PuzzlePanel"), puzzleItemFunc)

    if self.puzzle.id then
        self:setText("TxtStage", self.puzzle.id)
    end
    if self.puzzle.time then
        self:setText("TxtBestTime", self.puzzle.time)
    end
end

function PuzzleDetail:back()
    if self.ifPlaying then
        self:getParent():finished()
    end
    self:close()
end

function PuzzleDetail:share()
    -- TODO
end

function PuzzleDetail:retry()
    self:close(self.retrycb)
end

return PuzzleDetail
