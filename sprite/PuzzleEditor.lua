local PuzzleEditor = class("PuzzleEditor")
local Puzzle = require("app.sprite.Puzzle")
local PuzzleItem = require("app.sprite.PuzzleItem")

local config = require("app.MyConfig")
local userfile = config.userfile

function PuzzleEditor:ctor()
    self.puzzle = Puzzle.new()
end

function PuzzleEditor:set(pos, num)
	if self.puzzle.matrix[pos[1]] == nil or self.puzzle.matrix[pos[1]][pos[2]] == nil then
		return -1
	else
		self.puzzle.matrix[pos[1]][pos[2]] = num
		return num
	end
end

function PuzzleEditor:setCut(pos, cut)
	if self.puzzle.matrix[pos[1]] == nil or self.puzzle.matrix[pos[1]][pos[2]] == nil
		or self.puzzle.cut[pos[1]] == nil or self.puzzle.cut[pos[1]][pos[2]] == nil then
		return -1
	elseif self.puzzle.matrix[pos[1]][pos[2]] == 0 then
		return 0
	else
		self.puzzle.cut[pos[1]][pos[2]] = cut
		return cut
	end
end

function PuzzleEditor:getPuzzle()
	return self.puzzle
end

function PuzzleEditor:import(filename)
    self.puzzle = Puzzle.new(filename..".txt")
end

function PuzzleEditor:exportAll()
    for i = 1, config.puzzleNum do
        self:import(i)
        self:export("cut "..i)
    end
end

function PuzzleEditor:export(filename)

    
    
    local panel = ccui.Layout:create()
    panel:setPosition(0, 0)
    panel:setContentSize(cc.size(500, 500))

    local noShowFunc = function (sp) sp:setTexture("Blocks/00/bg_without_board.png") end
    local showFunc = function () end
    
    local trt = cc.RenderTexture:create(500, 500, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    
    PuzzleItem.new(self.puzzle, panel, noShowFunc, true)
    trt:begin()
    panel:visit()--截图要绘制的内容
    trt:endToLua()
    trt:saveToFile("BitPuzzle/"..filename.."_no_finished.png", cc.IMAGE_FORMAT_PNG, true)

    trt = cc.RenderTexture:create(500, 500, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    PuzzleItem.new(self.puzzle, panel, showFunc, true)
    trt:begin()
    panel:visit()
    trt:endToLua()
    trt:saveToFile("BitPuzzle/"..filename.."_finished.png", cc.IMAGE_FORMAT_PNG, true)

    self.puzzle:export(filename..".txt")
end

return PuzzleEditor
