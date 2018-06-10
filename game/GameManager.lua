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

local function moveHandler(key)
    local dx, dy = 0, 0
    if key == 'w' then
        dy = -1        
    elseif key == 's' then
        dy = 1
    elseif key == 'a' then
        dx = -1
    elseif key == 'd' then
        dx = 1
    end

    local x = logic.getCurUnit().x
    local y = logic.getCurUnit().y
    print("move handler: " .. tostring(logic.doAction("move", x + dx, y + dy)))
end

local function endTurnHandler()
    print("end turn handler")
    logic.doAction("endTurn")
end

local function attackHandler()
    print("attack handler")

    local curUnit = logic.getCurUnit()
    local dx = {1, -1, 0, 0}
    local dy = {0, 0, -1, 1}
    for i = 1, 4 do
        local x = curUnit.x + dx[i]
        local y = curUnit.y + dy[i]
        logic.doAction("attack", x, y)
    end
end

local function pickupHandler()
    print("pickup handler")
    
    local curUnit = logic.getCurUnit()
    local dx = {1, -1, 0, 0}
    local dy = {0, 0, -1, 1}
    for i = 1, 4 do
        local x = curUnit.x + dx[i]
        local y = curUnit.y + dy[i]
        logic.doAction("pickup", "dagger", x, y)
    end
end

local _inputHandlers = 
{
    wsad =  moveHandler,
    e = endTurnHandler,
    q = attackHandler,
    p = pickupHandler
}

function love.keypressed( key, isrepeat)
    for keys, handler in pairs(_inputHandlers) do
        if keys:find(key) ~= nil then
            handler(key)
        end
    end
end    

function GameManager.update(dt)
    map.update(dt)
end

function GameManager.draw()
    map.draw()
end

return GameManager