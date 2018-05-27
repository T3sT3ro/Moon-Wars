local RM = require "ResourceManager"

local GameMap = {}

local map = {}

local mapType = {"grass","stone","water"}
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
            map[i][j].actors = {}
            ---[[
                map[i][j].type = 1
                if i + 1 == j and j % 2 == 0 then map[i][j].type = 2 end
                if ((i + j) % 5 == 0 and i % 4 == 0) or ((i + j) % 5 == 1 and i % 4 == 0) or ((i + j) % 5 == 0 and i % 4 == 3) or ((i + j) % 5 == 4 and i % 4 == 3)then map[i][j].type = 3 end
            --]]
        end
    end
    ---[[
        local nexus ={}
        nexus.type = "nexus_red"
        nexus.id = 1
        nexus.x = 5
        nexus.y = 5
        GameMap.addActor(nexus)
    --]]
end

function GameMap.addInitActors(initActors)
    local neutralActors = initActors[1]
    local player1Actors = initActors[2] -- contains Nexus and Units
    local player2Actors = initActors[3]

end

function GameMap.clear()
    map = {}
end

function GameMap.update(dt)
    
end

function GameMap.draw()
    for i=1,20 do
        for j=1,20 do
            love.graphics.draw(RM.get(mapType[map[i][j].type]), j*64, i*64)
            for _,v in pairs(map[i][j].actors) do
                love.graphics.draw(RM.get(v.type), j*64, i*64)
            end
        end
    end
end

function GameMap.distance(x1, y1, x2, y2)
    return abs(x1-x2)+(y1-y2)
end

function GameMap.isMoveable(x, y)
    if ma[x][y].type ~= 1 then return false end
    for i,_ in pairs(map[x][y].actors) do
        if i.type ~= "item" then return false end
    end
    return true
end

function GameMap.removeActor(actor)
    map[actor.x][actor.y].actors[actor.id] = nil
end

function GameMap.addActor(actor)
    map[actor.x][actor.y].actors[actor.id] = actor
end

return GameMap