local Buy = require("app.panel.Buy")
local Login = require("app.panel.Login")
local PuzzleDetail = require("app.panel.PuzzleDetail")
local Setting = require("app.panel.Setting")
local Trapped = require("app.panel.Trapped")

local Panels = {
    Buy = Buy,
    Login = Login,
    PuzzleDetail = PuzzleDetail,
    Setting = Setting,
    Trapped = Trapped
}

return Panels
