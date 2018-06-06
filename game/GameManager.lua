local logic = require "game/GameLogic"
local map = require "game/GameMap"
local Unit = require "game/actors/Unit"
local GameManager = {}

function GameManager.init()
    map.init()
    logic.init()
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
end

return GameManager