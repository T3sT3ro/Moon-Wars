ResourceManager = require "ResourceManager"
StateManager = require "StateManager"
MainMenuState = require "states/MainMenuState"
GameSetupState = require "states/GameSetupState"
GameState = require "states/GameState"
UIDebugState = require "states/UIDebugState"

function love.load()
    ResourceManager.init("resources")

    StateManager.add(MainMenuState)
    StateManager.add(GameSetupState)
    StateManager.add(GameState)
    StateManager.add(UIDebugState)
    love.window.setMode(1200, 800, {msaa = 16, borderless = false})

    StateManager.load(MainMenuState.name)
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end
