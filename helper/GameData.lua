local GameData = class("GameData")

local GameState = require("framework.cc.utils.GameState")
local TableHelper = require("app.util.TableHelper")

function GameData:ctor(path, secretKey, encryptKey)
    self.data = {}
    GameState.init(function(param)
        local val = nil
        if not param.errorCode then
            if param.name == "save" then
                local str = TableHelper.serialize(param.values)
                if encryptKey then
                    str = crypto.encryptXXTEA(str, encryptKey)
                end
                val = {data = str}
            elseif param.name == "load" then
                local str = param.values.data
                if encryptKey then
                    str = crypto.decryptXXTEA(str, encryptKey)
                end
                val = TableHelper.unserialize(str)
            end
        end
        return val
    end, path, secretKey)
end

function GameData:load()
    self.data = GameState.load()
    if not self.data then
        self.data = {}
    end
end

function GameData:save()
    GameState.save(self.data)
end

function GameData:set(key, value)
    self.data[key] = value
end

function GameData:get(key)
    return self.data[key]
end

function GameData:dump()
    dump(self.data, "GameData")
end

return GameData