local myUserDefault = cc.UserDefault:getInstance()

if not myUserDefault:getBoolForKey("nofirst") then
    myUserDefault:setBoolForKey("nofirst", true)
    myUserDefault:setIntegerForKey("times", 0)
end

local MyConfig = class("MyConfig")

MyConfig.iurl = "https://itunes.apple.com/app/id1138608200"
MyConfig.aurl = "https://play.google.com/store/apps/details?id=org.skydomain.emojidab"
MyConfig.shareWord = "I've got %d points in Emoji Dab! Can anyone dab further than me?"

MyConfig.productID = {
    
}

MyConfig.boardLength = 30
MyConfig.BlockNum = 10
MyConfig.BlockNow = 1
MyConfig.CutNum = 10
MyConfig.CutNow = 1
MyConfig.colorPerCul = 5

MyConfig.userfile = myUserDefault

MyConfig.userfile.get = function (key)
	return myUserDefault:getIntegerForKey(key)
end

MyConfig.userfile.set = function (key, value)
    myUserDefault:setIntegerForKey(key, value)
    myUserDefault:flush()
end

MyConfig.userfile.add = function (key, added)
	local before = MyConfig.userfile.get(key)
	MyConfig.userfile.set(key, before + added)
end

return MyConfig
