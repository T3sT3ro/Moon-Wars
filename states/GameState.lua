local ui = require "game/GameUI"
local manager = require "game/GameManager"

local GameState = {}
GameState.name = "GameState"

function GameState.init()
    manager.init()
    ui.init()
end

function GameState.clear()
    manager.clear()
    ui.clear()
end

function GameState.update(dt)
    manager.update(dt)
end

function GameState.draw()
    manager.draw()
    ui.draw()
end

return GameState