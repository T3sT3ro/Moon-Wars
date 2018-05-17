StateManager = require 'scripts/StateManager'
MainMenuState = require 'scripts/MainMenuState'
GameSetupState = require 'scripts/GameSetupState'
GameState = require 'scripts/GameState'

function love.load()
    StateManager.add(MainMenuState)
    StateManager.add(GameSetupState)
    StateManager.add(GameState)
    StateManager.load("MainMenuState")
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end