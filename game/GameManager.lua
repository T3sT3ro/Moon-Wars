local logic = require "game/GameLogic"
local map = require "game/GameMap"
local Unit = require "game/actors/Unit"
local SuperUnit = require "game/actors/SuperUnit"
local GameManager = {}

local u1
local u2
function GameManager.init()
    logic.init()
    map.init()

    u1 = SuperUnit:new({x = 100})
    u1:init("dagger", "u1")
    u2 = Unit:new({y = 300})
    u2:init("dagger2", "u2")

    u1:debugInfo()
    u2:debugInfo()
end

function GameManager.clear()
    logic.clear()
    map.clear()
end

function GameManager.update(dt)
    map.update(dt)
end

function GameManager.draw()
    map.draw()
    u1:draw()
    u2:draw()
end

return GameManager