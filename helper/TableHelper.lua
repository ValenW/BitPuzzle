local TableHelper = class("TableHelper")

function TableHelper:ctor()

end

local function serializeWithTab(luaTable, re_tab_key)
    local str = ""  
    local t = type(luaTable)  
    if t == "number" then  
        str = str .. luaTable  
    elseif t == "boolean" then  
        str = str .. tostring(luaTable)  
    elseif t == "string" then  
        str = str .. string.format("%q", luaTable)  
    elseif t == "table" then  
        str = str .. "{\n" 
        for k, v in pairs(luaTable) do  
            str = str .. re_tab_key .. "\t[" .. serializeWithTab(k, "") .. "]=" .. serializeWithTab(v, re_tab_key .. "\t") .. ",\n"  
        end  
        local metatable = getmetatable(luaTable)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
            for k, v in pairs(metatable.__index) do  
                str = str .. re_tab_key .. "\t[" .. serializeWithTab(k, "") .. "]=" .. serializeWithTab(v, re_tab_key .. "\t") .. ",\n"  
            end  
        end  
        str = str .. re_tab_key .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return str  
end

---@function [parent=#TableHelper] serialize
--@param table type description
--@return #String 
function TableHelper.serialize(luaTable) 
    return serializeWithTab(luaTable, "")  
end  
---@function [parent=#TableHelper] unserialize
--@param str #String
--@return #table 将String 反序列化为table
function TableHelper.unserialize(str)  
    local t = type(str)  
    if t == "nil" or str == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        str = tostring(str)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    str = "return " .. str  
    local func = loadstring(str)  
    if func == nil then  
        return nil  
    end  
    return func()  
end  
return TableHelper