local RM = require "ResourceManager"

local GameMap = {}

local map = {}

local mapType = {"grass","rock","water"}
--[[
    map types:
    1 - grass
    2 - rock
    3 - water
--]]
function GameMap.init()
    for i=1,20 do
        map[i] = {}
        for j=1,20 do
            map[i][j] = {}
            map[i][j].type = 1
        end
    end
    ---[[
        local nexus ={}
        nexus.asset = "dagger2"
        map[10][5].unit = nexus
        map[10][15].unit = nexus
    --]]
end

function GameMap.clear()
    map = {}
end

function GameMap.update(dt)
    
end

function GameMap.draw()
    for i=1,20 do
        for j=1,20 do
            --love.graphics.draw(RM.get(mapType[map[i][j].type]), i*20, j*20)
            love.graphics.draw(RM.get("dagger"), i*60, j*60)
            if map[i][j].unit ~= nil then love.graphics.draw(RM.get(map[i][j].unit.asset), i*60, j*60) end
        end
    end
end

function GameMap.distance(x1, y1, x2, y2)
    return abs(x1-x2)+(y1-y2)
end

function GameMap.isMoveable(x, y)
    if map[x][y].unit == nil and map[x][y].type == 1 then return true
    else return false
    end
end

function GameMap.removeActor(actor)
    map[actor.x][actor.y].unit = nil
end

function GameMap.addActor(actor)
    map[actor.x][actor.y].unit = actor
end

return GameMap