local MainMenuState = {name = "MainMenuState"}
local UI = require("UI/UI")
local UIButton = require("UI/UIButton")
local UIFrame = require("UI/UIFrame")
ResourceManager.load("font.monospace24", "Inconsolata-Regular", "ttf", "resources/fonts", "font", 24)
local font = ResourceManager.get("font.monospace24")
local StartGameText = love.graphics.newText(font, "Start Game")
local GUI = UI(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
local MainFrame = UIFrame()
local StartGameBttn =
    UIButton(
    {
        size = {x = "40%", y = StartGameText:getHeight() + 80},
        origin = {y = -70},
        allign = {x = "center"}
    },
    "normal",
    StartGameText,
    function()
        StateManager.load(GameState.name)
    end
)
local ExitBttn =
    UIButton(
    {
        size = {x = "40%", y = StartGameText:getHeight() + 80},
        origin = {y = 70},
        allign = {x = "center"}
    },
    "normal",
    love.graphics.newText(font, "Exit"),
    function()
        love.event.quit()
    end
)
MainFrame:addWidget(StartGameBttn)
MainFrame:addWidget(ExitBttn)
GUI:setWidget(MainFrame)

local oldHandlers = nil

function MainMenuState.init()
    oldHandlers = {
        mp = love.mousepressed,
        mr = love.mousereleased,
        wm = love.wheelmoved,
        kp = love.keypressed,
        kr = love.keyreleased,
        ti = love.textinput,
        fd = love.filedropped,
        dd = love.directorydropped
    }
    local handlers = GUI:getEventHandlers()

    love.mousepressed = handlers.mousepressed
    love.mousereleased = handlers.mousereleased
    love.wheelmoved = handlers.wheelmoved
    love.keypressed = handlers.keypressed
    love.keyreleased = handlers.keyreleased
    love.textinput = handlers.textinput
    love.filedropped = handlers.filedropped
    love.directorydropped = handlers.directorydropped
    --love.graphics.setColor(1,1,1,1)
end

function MainMenuState.clear()
    love.mousepressed = oldHandlers.mp
    love.mousereleased = oldHandlers.mr
    love.wheelmoved = oldHandlers.wm
    love.keypressed = oldHandlers.kp
    love.keyreleased = oldHandlers.kr
    love.textinput = oldHandlers.ti
    love.filedropped = oldHandlers.fd
    love.directorydropped = oldHandlers.dd
end

love.resize = function(w, h)
    GUI:resize(0, 0, w, h)
end

function MainMenuState.update(dt)
    GUI:update(dt)
    if love.keyboard.isDown("lalt") and love.keyboard.isDown("d") then
        StateManager.load(UIDebugState.name)
    end
end

function MainMenuState.draw()
    GUI:draw()
    --love.graphics.print("MainMenu State", 500, 300)
end

return MainMenuState
