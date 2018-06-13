local logic = require "game/GameLogic"
local map = require "game/GameMap"
local Unit = require "game/actors/Unit"
local Items = require "game/actors/Items"

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
        for _, item in ipairs(Items) do
            logic.doAction("pickup", item.name, x, y)
        end
    end
end

local function craftHandler()
    print("craft handler")
    logic.doAction("craft", "dagger")
end

local function infoHandler()
    logic.getCurUnit():debugInfo()
end

local _inputHandlers = 
{
    wsad =  moveHandler,
    e = endTurnHandler,
    q = attackHandler,
    p = pickupHandler,
    c = craftHandler,
    i = infoHandler
}

--[[
    function love.keypressed( key, isrepeat)
    for keys, handler in pairs(_inputHandlers) do
        if keys:find(key) ~= nil then
            handler(key)
        end
    end
end
]]--    

function GameManager.update(dt)
    map.update(dt)
end

function GameManager.draw(self,offset)
    map.draw(32-offset)
end

local function pressed(x,y,button)
    local hp_thing = map.getActorByStat(x,y,"health")
    if button == 1 then logic.doAction("move",x,y)
    elseif hp_thing ~= nil then 
        if hp_thing ==logic.getCurUnit() then logic.doAction("drop", "wood")
        elseif hp_thing.type == "Nexus" then 
            if hp_thing.playerId == logic.getCurUnit().playerId then logic.doAction("craft", "dagger")
            else logic.doAction("attack",x,y) 
            end
        else logic.doAction("attack",x,y)
        end
    elseif map.getActorByType(x,y,"Resource") ~= nil then 
        for _, item in ipairs(Items) do
            logic.doAction("pickup", item.name, x, y)
        end
    else logic.doAction("endTurn") end
end

function GameManager.mousePressed(self,x, y, button)
    local Ox,Oy = self:getOrigin()
    pressed(math.floor((x-Ox)/32)+1,math.floor((y-Oy)/32)+1,button)
end

return GameManager