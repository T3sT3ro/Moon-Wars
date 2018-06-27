local ui = require "game/GameUI"
local manager = require "game/GameManager"
local MainMenuState = {name = "MainMenuState"}
local UI = require("UI/UI")
local UIButton = require("UI/UIButton")
local UIFrame = require("UI/UIFrame")
local UIWidget = require("UI/UIWidget")
local UIScrollPane = require("UI/UIScrollPane")
ResourceManager.load("font.monospace24", "Inconsolata-Regular", "ttf", "resources/fonts", "font", 24)
local font = ResourceManager.get("font.monospace24")
local GUI = UI(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
local MainFrame = UIWidget()
local ScrollMap = UIScrollPane({virtualSize = {x=20*64, y=20*64}},{scroll = {x=true, y=true}})
local MapFrame = UIWidget({allign = {x = "center"},size = {x = 20*64, y = 20*64}})
MapFrame.renderer = manager.draw
MapFrame.mousePressed = manager.mousePressed
ScrollMap:addWidget(MapFrame)
MainFrame:addWidget(ScrollMap)
GUI:setWidget(MainFrame)
local GameState = {}
GameState.name = "GameState"
local oldResize 
function GameState.init()
    oldResize = love.resize
    oldHandlers = {
        mp = love.mousepressed,
        mr = love.mousereleased,
        mw = love.mousemoved,
        wm = love.wheelmoved,
        kp = love.keypressed,
        kr = love.keyreleased,
        ti = love.textinput,
        fd = love.filedropped,
        dd = love.directorydropped
    }
    local handlers = GUI:getEventHandlers()

    love.resize = function(w,h)
        GUI:resize(0,0,w,h)
    end
    love.mousepressed = handlers.mousepressed
    love.mousereleased = handlers.mousereleased
    love.mousemoved = handlers.mousemoved
    love.wheelmoved = handlers.wheelmoved
    love.keypressed = handlers.keypressed
    love.keyreleased = handlers.keyreleased
    love.textinput = handlers.textinput
    love.filedropped = handlers.filedropped
    love.directorydropped = handlers.directorydropped
    manager.init()
    ui.init()
end

function GameState.clear()
    love.resize = oldResize
    love.mousepressed = oldHandlers.mp
    love.mousereleased = oldHandlers.mr
    love.mousemoved = oldHandlers.mw
    love.wheelmoved = oldHandlers.wm
    love.keypressed = oldHandlers.kp
    love.keyreleased = oldHandlers.kr
    love.textinput = oldHandlers.ti
    love.filedropped = oldHandlers.fd
    love.directorydropped = oldHandlers.dd
    manager.clear()
    ui.clear()
end

function GameState.update(dt)
    GUI:update(dt)
    manager.update(dt)
end

function GameState.draw()
    GUI:draw(0,0)
    --manager.draw(0)
end

return GameState