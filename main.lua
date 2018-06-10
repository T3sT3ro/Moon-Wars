local ResourceManager = require "ResourceManager"
local StateManager = require "StateManager"
local MainMenuState = require "states/MainMenuState"
local GameSetupState = require "states/GameSetupState"
local GameState = require "states/GameState"

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
