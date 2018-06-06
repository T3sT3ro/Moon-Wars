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

local function handleInput()
    local dx, dy = 0, 0
    if love.keyboard.isDown('w') then
        print("w pressed")
        dy = -1        
    elseif love.keyboard.isDown('s') then
        print("s pressed")
        dy = 1
    elseif love.keyboard.isDown('a') then
        print("a pressed")
        dx = -1
    elseif love.keyboard.isDown('d') then
        print("d pressed")
        dx = 1
    elseif love.keyboard.isDown('e') then
        print("handle end")
        logic.doAction("endTurn")
    end

    local x = logic.getCurUnit().x
    local y = logic.getCurUnit().y
    if dx ~= 0 or dy ~= 0 then 
        print("handle move: " .. tostring(logic.doAction("move", x + dx, y + dy)))
    end
end

function GameManager.update(dt)
    handleInput()
    map.update(dt)
end

function GameManager.draw()
    map.draw()
end

return GameManager