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

MyConfig.cutTag = -2

MyConfig.boardLength = 30
MyConfig.BlockNum = 10
MyConfig.BlockNow = 1
MyConfig.CutNum = 10
MyConfig.CutNow = 1
MyConfig.colorPerCul = 6

MyConfig.colors = {
    [1] = 12,
    [2] = 18,
    [3] = 10,
    [4] = 13,
    [5] = 18,
    [6] = 9,
    [7] = 6,
    [8] = 13,
    [9] = 13,
    [10] = 6,
    [11] = 12,
    [12] = 11,
    [13] = 8,
    [14] = 11,
    [15] = 8,
    [16] = 24,
    [17] = 13,
    [18] = 18,
    [19] = 13,
    [20] = 13,
    [21] = 19,
    [22] = 15,
    [23] = 15,
    [24] = 10,
    [25] = 12,
    [26] = 17,
    [27] = 6
}

MyConfig.cuts = {
	[1] = 10
}

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
