local Matrix = class("Matrix")

local config = require("app.MyConfig")

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

function Matrix:getEdgeMatrix(ifboard)
	if self.edgeMatrix == nil then
        self.edgeMatrix = self:findEdge(nil, ifboard)
    end
    return self.edgeMatrix
end

function Matrix:findEdge(matrix, ifboard)
    dump(ifboard)
	if matrix == nil then
		matrix = self.matrix
	end

    local dir = { {-1, 0}, {0, 1}, {0, -1}, {1, 0} } -- left, up, down, right
	local factor = {1, 2, 4, 8}
	local edgeMatrix = {}
	for i = 1, #matrix do
		edgeMatrix[i] = {}
		for j = 1, #matrix[i] do
			local edge = -1
			if self.matrix[i][j] ~= 0 then
				edge = 0
				for k, d in ipairs(dir) do
				    if matrix[i + d[1]] ~= nil and matrix[i + d[1]][j + d[2]] ~= nil then
						if matrix[i + d[1]][j + d[2]] == 0 then
							edge = edge + factor[k]
						end
                    elseif ifboard == true then
                        edge = edge + factor[k]
					end
				end
			end
			edgeMatrix[i][j] = edge
		end
	end
	return edgeMatrix
end

function Matrix:print(toPrint)
	if toPrint == nil then
		toPrint = self.matrix
	end

	local width, height = nil
	if size == nil then
		width, height = #toPrint, #toPrint[1]
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
