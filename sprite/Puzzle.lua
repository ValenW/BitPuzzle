local Matrix = require("app.sprite.Matrix")
local Puzzle = class("Puzzle", Matrix)
local TableHelper = require("app.helper.TableHelper")

local config = require("app.MyConfig")
local userfile = config.userfile

function Puzzle:ctor(filepath)
	if filepath ~= nil then
		self:import(filepath)
	else
		self:setDefault()
	end
end

function Puzzle:setDefault()
    self:reset(config.boardLength)
	self:initCut()
end

function Puzzle:initCut()
	self.cut = {}
	for i = 1, self.width do
		self.cut[i] = {}
        for j = 1, self.height do
			self.cut[i][j] = 0
		end
	end
end

-- Edges --
function Puzzle:printEdges()
	local edges = self:getEdgeMatrix()
	for time = 1, 2 do
	    local s = "\n"
	    for i = self.width, 1, -1 do
	        for j = 1, self.height do
	            s = s..edges[j][i][time]
	        end
	        s = s.."\n"
	    end
	    print(s.."\n")
	end
end

function Puzzle:findEdge()
	local dir = { {-1, 0}, {0, 1}, {0, -1}, {1, 0} } -- left, up, down, right
	local factor = {1, 2, 4, 8}
	local edgeMatrix = {}
	for i = 1, self.width do
		edgeMatrix[i] = {}
		for j = 1, self.height do
			local edge = {-1, -1}
			if self.matrix[i][j] ~= 0 then
				edge = {0, 0}
				for k, d in ipairs(dir) do
					if self.matrix[i + d[1]] ~= nil and self.matrix[i + d[1]][j + d[2]] ~= nil then
				        if self.matrix[i + d[1]][j + d[2]] == 0 then
						  edge[1] = edge[1] + factor[k]
					   elseif self.cut[i + d[1]][j + d[2]] ~= 0 and self.cut[i + d[1]][j + d[2]] ~= self.cut[i][j] then
						  edge[2] = edge[2] + factor[k]
					   end
				    end
				end
			end
			edgeMatrix[i][j] = edge
		end
	end
	return edgeMatrix
end

-- Items --
function Puzzle:printItems()
	local items = self:getItems()
	for i = 1, #items do	
	    print(string.format("items %d:\n", i))
		self:print(items[i])
	end
end

function Puzzle:getItems()
	if self.items ~= nil then
		return self.items
	end

	local items = self:cutToOriginItems()
	local reItems = {}
	for i = 1, #items do
		local item = self:delWithOriginItem(items[i])
        local min, max, item = item[1], item[2], item[3]
		local width, height = max[1] - min[1] + 1, max[2] - min[2] + 1
		
		local reItem = {}
		for i = 1, width do
			reItem[i] = {}
			for j = 1, height do
				reItem[i][j] = 0
			end
		end

		for i = 1, #item do
			reItem[item[i][1] + 1][item[i][2] + 1] = self.matrix[item[i][1] + min[1]][item[i][2] + min[2]]
		end

		reItem.base = min
		table.insert(reItems, reItem)
	end
	self.items = reItems
	return reItems
end

function Puzzle:cutToOriginItems()
	local bfs = require("app.myUtils").bfs

	local finished = {}
	for i = 1, self.width do
		finished[i] = {}
		for j = 1, self.height do
			finished[i][j] = 0
		end
	end

	local getNextFunc = function ()
		local dir = {{-1, 0}, {0, 1}, {0, -1}, {1, 0}} -- left, up, down, right
		local factor = {1, 2, 4, 8}
        local tbl = self:getEdgeMatrix()
        
		local function ok(newNode, dir)
		    if tbl[newNode[1]] == nil then
		        return false
	        end
	        
            local newNode = tbl[newNode[1]][newNode[2]]
            if newNode == nil or newNode[1] == -1 then
            	return false
            end

			local dir = 5 - dir
			local sum = newNode[1] + newNode[2]
			for i = 4, 1, -1 do
				if i == dir then
					return sum < factor[i]
				elseif sum >= factor[i] then
					sum = sum - factor[i]
				end
			end
		end

		local function reFunc(nodePos)
		    local re = {}
		    for i = 1, #dir do
		        local newNode = {nodePos[1] + dir[i][1], nodePos[2] + dir[i][2]}
                if (ok(newNode, i)) then
		            table.insert(re, newNode)
		        end
		    end
		    return re
		end
		return reFunc
	end

	local getDosthFunc = function ()
		local function re(node)
			return nil
		end
		return re
	end

	local items = {}
	for i = 1, self.width do
		for j = 1, self.height do
			if self.matrix[i][j] ~= 0 and finished[i][j] == 0 then
				local item = bfs({i, j}, finished, getNextFunc(), getDosthFunc())
				table.insert(items, item)
			end
		end
	end

	return items
end

function Puzzle:delWithOriginItem(item)
	local minx, miny = item[1][1], item[1][2]
	local maxx, maxy = minx, miny
	for _, item in pairs(item) do
		if item[1] < minx then
			minx = item[1]
		elseif item[1] > maxx then
			maxx = item[1]
		end

		if item[2] < miny then
			miny = item[2]
		elseif item[2] > maxy then
			maxy = item[2]
		end
	end

	for i = 1, #item do
		item[i][1] = item[i][1] - minx
		item[i][2] = item[i][2] - miny
	end
	return {{minx, miny}, {maxx, maxy}, item}
end

-- Impot and Export, print --
local function getGameStatePath()
    return string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator
    --
end

function Puzzle:export(filename)
	local outMatrix = {}
	for i = 1, self.width do
	   outMatrix[i] = {}
		for j = 1, self.height do
			outMatrix[i][j] = {self.matrix[i][j], self.cut[i][j]}
		end
	end

	local ex = TableHelper.serialize({self.width, self.height, outMatrix})
    local path = getGameStatePath() .. "BitPuzzle/"
    if not cc.FileUtils:getInstance():isDirectoryExist(path) then
        cc.FileUtils:getInstance():createDirectory(path)
    end
    io.writefile(path..filename, ex)
end

function Puzzle:import(filename)
    local path = getGameStatePath() .. "BitPuzzle/"
    local f = io.open(path..filename)
    local s = f:read("*all")
    f:close()
    local tb = TableHelper.unserialize(s)
    self.width, self.height = tb[1], tb[2]
    local inMatrix = tb[3]
    self:reset(self.width, self.height)
    self.cut = {}
    for i = 1, self.width do
        self.cut[i] = {}
    	for j = 1, self.height do
            self.matrix[i][j] = inMatrix[i][j][1]
    		self.cut[i][j] = inMatrix[i][j][2]
    	end
    end
end

function Puzzle:printCut()
	self:print(self.cut)
end

return Puzzle
