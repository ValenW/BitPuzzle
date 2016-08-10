local utils = {}

utils.bfs = function (start, finished, getNext, func)
    local nexts = {start}
    local visited = {}

    finished[start[1]][start[2]] = 1
    while #nexts > 0 do
        local newNext = {}
        for _, node in pairs(nexts) do
            table.insert(visited, node)
            func(node)
            for _, newNode in ipairs(getNext(node)) do
                if finished[newNode[1]][newNode[2]] == 0 then
                    table.insert(newNext, newNode)
                    finished[newNode[1]][newNode[2]] = 1
                end
            end
        end
        nexts = newNext
    end
    return visited
end

utils.randomOrder = function (length)
    local re = {}
    for i = 1, length do
        re[i] = i
    end
    for i = 1, length - 1 do
        local index = math.random(length - i) + i
        re[i], re[index] = re[index], re[i]
    end
    return re
end

return utils
