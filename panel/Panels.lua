local FreeCoin = require("app.panel.FreeCoin")
local NoCoin = require("app.panel.NoCoin")
local Setting = require("app.panel.Setting")
local Shop = require("app.panel.Shop")
local Skin = require("app.panel.Skin")
local Tutor = require("app.panel.Tutor")
local Unlock = require("app.panel.Unlock")
local GetFreeCoin = require("app.panel.GetFreeCoin")
local Rank = require("app.panel.Rank")

local Panels = {
    FreeCoin = FreeCoin,
    NoCoin = NoCoin,
    Setting = Setting,
    Shop = Shop,
    Skin = Skin,
    Tutor = Tutor,
    Unlock = Unlock,
    GetFreeCoin = GetFreeCoin,
    Rank = Rank
}

return Panels
