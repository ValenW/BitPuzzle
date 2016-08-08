local Matrix = class("Matrix")

local config = require("app.MyConfig")
local MaskConfig = config.Mask

function Matrix:ctor(width, height)
    self.reset(width, height)
end

function Matrix:reset(width, height)
    if width ~= nil then
	    self.width = width
	    if height ~= nil then
	        self.height = height
	    else
	        self.height = width
	    end
    end

    if self.width == nil then
    	return nil
    elseif self.height == nil then
    	self.height = self.width
    end

    self.matrix = {}
	for i = 1, self.width do
		self.matrix[i] = {}
		for j = 1, self.height do
			self.matrix[i][j] = 0
		end
	end

	self.edge, self.items = nil
end

function Matrix:getItems()
	if self.items == nil then
		self:cutToItems()
	end
	return self.items
end

function Matrix:getEdge()
	if self.edge == nil then
		self:findEdge()
	end
	return self.edge
end

function Matrix:print(toPrint, size)
	if toPrint == nil then
		toPrint = self.matrix
	end

	local width, height = nil
	if size == nil then
		width, height = self.width, self.height
	else
		width, height = size[1], size[2]
	end

    local s = "\n"
    for i = height, 1, -1 do
        for j = 1, width do
            s = s..toPrint[j][i]
        end
        s = s.."\n"
    end
    print(s.."\n")
end

return Matrix
