ResourceManager = require "ResourceManager"
StateManager = require "StateManager"
MainMenuState = require "states/MainMenuState"
GameSetupState = require "states/GameSetupState"
GameState = require "states/GameState"
UIDebugState = require "debug/UIDebugState"

function love.load()
    ResourceManager.init("resources")

    StateManager.add(MainMenuState)
    StateManager.add(GameSetupState)
    StateManager.add(GameState)
    StateManager.add(UIDebugState)

    love.keyboard.setKeyRepeat(true)
    love.window.setMode(
        800, 600,
        {
            msaa = 16,
            fullscreen = false,
            resizable = true,
            fullscreentype = "desktop"
        }
    )

    StateManager.load(MainMenuState.name)
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end
