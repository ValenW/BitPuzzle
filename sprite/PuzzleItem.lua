local Item = require("app.sprite.Item")

local myUtils = require("app.myUtils")

local PuzzleItem = class("PuzzleItem", Item)

function PuzzleItem:ctor(puzzle, puzzlePanel)
	self.puzzle = puzzle
	self.blockLength = puzzlePanel:getContentSize().width / config.boardLength
	self:init(self.puzzle.matrix, self.blockLength, self:getDelBlockFunc(), puzzlePanel)

	self:initHint()
end

function PuzzleItem:getDelBlockFunc()
	self.items = self.puzzle:getItems()
	local itemIds = {}
	for i = 1, #items do
		local x, y = items[i].base[1], items[i].base[2]
		for j = 1, #items[i] do
			for k = 1, #items[i][j] do
				if items[i][j][k] ~= 0 then
					itemIds[x + j][y + k] = i
				end
			end
		end
	end

	local re = function (sp, loc)
		sp:setTag(itemIds[loc[1]][loc[2]])
		sp:setOpacity(50)
		sp:setVisibility(false)
		-- setCascadeOpacityEnabled
	end
	return re
end

function PuzzleItem:initHint()
	self.hintOrder = myUtils.randomOrder(#self.items)
	self.nextHint = 1
end

function PuzzleItem:getHint()
	if self.nextHint > #self.items then
		return false
	end
	self:setVisibilityByTag(self.hintOrder[self.nextHint], true)
	self.nextHint = self.nextHint + 1
	return true
end

return PuzzleItem
