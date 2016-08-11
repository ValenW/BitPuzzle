local Item = require("app.sprite.Item")
local BitItem = require("app.sprite.BitItem")
local myUtils = require("app.myUtils")
local config = require("app.MyConfig")

local PuzzleItem = class("PuzzleItem", Item)

function PuzzleItem:ctor(puzzle, puzzlePanel)
	self.puzzle = puzzle
	self.blockLength = puzzlePanel:getContentSize().width / config.boardLength
	self:init(self.puzzle.matrix, self.blockLength, "ui/edge_black.png", function (sp) sp:setVisible(false) end, puzzlePanel)

	self:initBitItem()
	self.win = false
	self:initHint()
	self:initCompleted()
end

function PuzzleItem:initBitItem()
	local items = self.puzzle:getItems()
	self.bitItems = {}
    for i = 1, #items do
        self.bitItems[i] = BitItem.new(items[i], self.blockLength)
        self.bitItems[i].layout:setPosition(cc.p((items[i].base[1] - 1) * self.blockLength, (items[i].base[2] - 1) * self.blockLength))
        self.bitItems[i].layout:setCascadeOpacityEnabled(true)
        self.bitItems[i].layout:setVisible(false)
        self.layout:addChild(self.bitItems[i].layout)
    end
end

function PuzzleItem:initCompleted()
	self.completed = {}
	for i = 1, self.width do
		self.completed[i] = {}
		for j = 1, self.height do
			self.completed[i][j] = 0
		end
	end
end

function PuzzleItem:initHint()
    self.hintOrder = myUtils.randomOrder(#self.bitItems)
	self.nextHint = 1
end

function PuzzleItem:getHint()
    if self.nextHint > #self.bitItems then
		return false
	end
    local layout = self.bitItems[self.hintOrder[self.nextHint]].layout
    layout:setVisible(true)
	local scaleUp = cc.ScaleTo:create(0.5, 2)
    local scaleDown = cc.ScaleTo:create(0.3, 1)
    layout:runAction(cc.Sequence:create(scaleUp, scaleDown))
    layout:setOpacity(70)
	
	self.nextHint = self.nextHint + 1
	return true
end

function PuzzleItem:getBitPositionFromWorldPosition(worldPos)
    local basePos = cc.p(self.layout:getPosition())
	local bx, by =  math.floor((worldPos.x - basePos.x) / self.blockLength + 0.45),
					math.floor((worldPos.y - basePos.y) / self.blockLength + 0.45)
	return cc.p(bx, by)
end

function PuzzleItem:getFixPanelPosition(bitPos)
	return cc.p(bitPos.x * self.blockLength, bitPos.y * self.blockLength)
end

function PuzzleItem:put(bitItemMatrix, worldPos, oldWorldPos)
	local bitPos = self:getBitPositionFromWorldPosition(worldPos)
    if bitPos.x < 0 or bitPos.x + #bitItemMatrix > self.puzzle.width
        or bitPos.y < 0 or bitPos.y + #bitItemMatrix > self.puzzle.height then
        return false
    end
	if bitPos == false then
		return false
	end

	for i = 1, #bitItemMatrix do
		for j = 1, #bitItemMatrix[i] do
			if self.completed[bitPos.x + i][bitPos.y + j] == 1 then
				return false
			end
		end
	end

	if oldWorldPos ~= nil then
		local oldBitPos = self:getBitPositionFromWorldPosition(oldWorldPos)
		if oldBitPos ~= false then
			for i = 1, #bitItemMatrix do
				for j = 1, #bitItemMatrix[i] do
					if bitItemMatrix[i][j] ~= 0 then
						self.completed[oldBitPos.x + i][oldBitPos.y + j] = 0
					end
				end
			end

			for i = 1, #bitItemMatrix do
				for j = 1, #bitItemMatrix[i] do
					if bitItemMatrix[i][j] ~= 0 then
						self.completed[bitPos.x + i][bitPos.y + j] = 1
					end
				end
			end

			-- if play completed
			local win = true
			for i = 1, #self.puzzle.cut do
				for j = 1, #self.puzzle.cut[i] do
					if self.puzzle.cut[i][j] ~= 0 then
						if self.completed[i][j] == 0 then
							win = false
							break
						end
					end
					if not win then
						break
					end
				end
				if not win then
					break
				end
			end
			self.win = win
		end
	end

	return self:getFixPanelPosition(bitPos)
end

return PuzzleItem
