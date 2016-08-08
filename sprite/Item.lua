local config = require("app.MyConfig")
local Matrix = require "app.sprite.Matrix"

local Item = class("Item", Matrix)

function Item:ctor(config, length)
	self.matrix = config
	self.width, self.height = #config, #config[1]
	self.blockLength = length

	self:fresh()
end

function Item:fresh()
	local layout = ccui.Layout:create()
	local length = self.blockLength
	layout:setAnchorPoint(cc.p(0, 0))
	layout:setContentSize(cc.size(self.width * length, self.height * length))
	for i = 1, self.width do
		for j = 1, self.height do
			local id = self.matrix[i][j]
			if id ~= 0 then
				local path = string.format("Blocks/%d/p%d.png", config["BlockNow"], id)
				local sp = cc.Sprite:create(path)
				sp:setContentSize(cc.size(length, length))
				sp:setAnchorPoint(cc.p(0, 0))
				sp:setPosition(cc.p( (i - 1) * length, (j - 1) * length ))
				layout:addChild(sp)
			end
		end
	end
end

function Item:showEdge()
	local edgeMatrix = self:getEdgeMatrix()
	local factor = {1, 2, 4, 8}
	for i = 1, self.width do
		for j = 1, self.height do
			
			for k = 1, 4 do
				
			end
		end
	end
end

function Item:hideEdge()
	-- TODO
end

function Item:put(loc)
	-- TODO
end

return Item
