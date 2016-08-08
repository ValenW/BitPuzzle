local config = require("app.MyConfig")
local userfile = config.userfile

local AudioController = class("AudioController")

local audio = cc.SimpleAudioEngine:getInstance()

function AudioController:ctor()
    self:preload()
	if userfile.get("music") == 0 then
        self.play = false
    else
        self.play = true
--        self:playMusic("Bgm.mp3", true)
    end
end

function AudioController:preload()
    --self:preloadMusic("music/Bgm.mp3")
    audio:preloadEffect("music/Button.mp3")
    audio:preloadEffect("music/Combine.mp3")
    audio:preloadEffect("music/Locate.mp3")
    audio:preloadEffect("music/NewIcon.mp3")
    audio:preloadEffect("music/NewIconDisappear.mp3")
    audio:preloadEffect("music/Rotate.mp3")
end

function AudioController:stop()
    self.play = false
    userfile.set("music", 0)
	audio:stopAllEffects()
	audio:stopMusic()
end

function AudioController:start()
    self.play = true
    userfile.set("music", 1)
    --self:playMusic("Bgm.mp3", true)
end

function AudioController:whenPut()
    if self.play == false then return nil end
    audio:playEffect("music/Locate.mp3")
end

function AudioController:whenCombine()
    if self.play == false then return nil end
    audio:playEffect("music/Combine.mp3")
end

function AudioController:when7dis()
    if self.play == false then return nil end
    audio:playEffect("music/NewIcon.mp3")
end

function AudioController:when8dis()
    if self.play == false then return nil end
    audio:playEffect("music/NewIconDisappear.mp3")
end

function AudioController:whenRotate()
    if self.play == false then return nil end
    audio:playEffect("music/Rotate.mp3")
end

function AudioController:whenButton()
    if self.play == false then return nil end
    audio:playEffect("music/Button.mp3")
end

return AudioController
