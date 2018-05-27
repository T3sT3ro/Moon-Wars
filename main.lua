ResourceManager = require "ResourceManager"
StateManager = require "StateManager"
MainMenuState = require "states/MainMenuState"
GameSetupState = require "states/GameSetupState"
GameState = require "states/GameState"

function love.load()
    ResourceManager.init("resources")

    StateManager.add(MainMenuState)
    StateManager.add(GameSetupState)
    StateManager.add(GameState)
    
    StateManager.load("GameState")
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end
