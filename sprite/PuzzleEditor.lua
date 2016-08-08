local PuzzleEditor = class("PuzzleEditor")
local Puzzle = require("app.sprite.Puzzle")

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
    self.puzzle = Puzzle.new(filename)
end

function PuzzleEditor:export(filename)
    self.puzzle:print()
    self.puzzle:printCut()
    
    self.puzzle:printItems()
    
    self.puzzle:export(filename)
end

return PuzzleEditor
