local XXXEvolutionAcc = class("XXXEvolutionAcc", function ()
    return cc.Scene:create()
end)
local TableHelper = require("clc.util.TableHelper")

function XXXEvolutionAcc:ctor()
    local dt = {}
    local key = {["h"] = "hat", ["g"] = "glasses", ["b"] = "beard", ["n"] = "necklace"}
    for i = 1, 18 do
        local file = i < 10 and "0"..i or ""..i
        local t = {}
        local node = cc.CSLoader:createNode("csb/" .. file .. ".csb")
        local hippo = node:getChildByName("hippo")
        t["num"] = {hat = 0, glasses = 0, beard = 0, necklace = 0}
        for k, v in pairs(hippo:getChildren()) do
            local name = v:getName()
            local type = string.sub(name, 1, 1)
            t["num"][key[type]] = t["num"][key[type]] + 1
            t[name] = {v:getPositionX(), v:getPositionY(), v:getScaleX() * 100, v:getScaleY() * 100, v:getRotationSkewX()}
        end
        dt[i] = t
    end
    self:saveData("cj_acc.txt", TableHelper.serialize(dt))
end

local function getGameStatePath()
    return string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator
end

function XXXEvolutionAcc:saveData(filename, s)
    local filename = getGameStatePath() .. filename
    io.writefile(filename, s)
end

return XXXEvolutionAcc