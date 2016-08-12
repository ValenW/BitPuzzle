local Matrix = require("app.sprite.Matrix")
local config = require("app.MyConfig")

local Item = class("Item", Matrix)

function Item:init(config, length, edgePath, delSpFunc, layout)
	self.matrix = config
	self.width, self.height = #config, #config[1]
	self.blockLength = length
	self.layout = layout

    self:fresh(delSpFunc)
    if edgePath ~= nil then
        self:addEdgeSpr(edgePath)
    end
end

function Item:fresh(delSpFunc)
	local layout = nil
	local length = self.blockLength

	if self.layout == nil then
		layout = ccui.Layout:create()
		layout:setAnchorPoint(cc.p(0, 0))
		layout:setContentSize(cc.size(self.width * length, self.height * length))
	else
		layout = self.layout
	end

	for i = 1, self.width do
		for j = 1, self.height do
			local type, id = self.matrix[i][j] / 100, math.fmod(self.matrix[i][j], 100)
			if id ~= 0 then
                local path = string.format("Blocks/%02d/%02d.png", type, id)
                local sp = cc.Sprite:create(path)
                local size = sp:getContentSize()
                sp:setScale(length / size.width, length / size.height)
				sp:setAnchorPoint(cc.p(0, 0))
				sp:setPosition(cc.p( (i - 1) * length, (j - 1) * length ))

				if delSpFunc ~= nil then
					delSpFunc(sp, {i, j})
				end

				layout:addChild(sp)
			end
		end
	end
	self.layout = layout
end

function Item:addEdgeSpr(path, ifboard)
    local edgeMatrix = self:getEdgeMatrix(ifboard)
	self:print(edgeMatrix)
	local factor = {1, 2, 4, 8}
	for i = 1, self.width do
		for j = 1, self.height do
			local sum = edgeMatrix[i][j]
			if sum > 0 then
				for k = 4, 1, -1 do
					if sum >= factor[k] then
						self:addOneEdgeSpr({i, j}, k, path)
						sum = sum - factor[k]
					end
				end
			end
		end
	end
end

function Item:addOneEdgeSpr(loc, dir, path)
	local edgeSpr = cc.Sprite:create(path)
	local size = edgeSpr:getContentSize()
	local length = self.blockLength
	local scaled = length / (size.width - 2 * size.height)
	edgeSpr:setScale(scaled)
	edgeSpr:setAnchorPoint(0.5, -(length / size.height * scaled / 2))
	edgeSpr:setPosition(cc.p((loc[1] - 0.5) * length, (loc[2] - 0.5) * length))
	local rot = 0
	if dir == 1 then
		rot = -90
	elseif dir == 3 then
		rot = 180
	elseif dir == 4 then
		rot = 90
	end
	edgeSpr:setRotation(rot)
	edgeSpr:setTag(config.edgeTag)
	self.layout:addChild(edgeSpr)
end

function Item:setVisibilityByTag(tag, ifview)
	local children = self.layout:getChildren()
	for i = 1, #children do
		if children[i]:getTag() == tag then
            children[i]:setVisible(ifview)
		end
	end
end

return Item
