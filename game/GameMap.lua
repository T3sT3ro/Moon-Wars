local RM = require "ResourceManager"

local GameMap = {}

local map = {}

<<<<<<< 1556588f459ed1f62cd44f52d14a8833ff3c9e0c
local mapType = {"grass","stone","water"}
=======
local mapType = {"grass","rock","water"}
>>>>>>> Add partial GameMap module implementation
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
<<<<<<< 1556588f459ed1f62cd44f52d14a8833ff3c9e0c
            map[i][j].actors = {}
            ---[[
                map[i][j].type = 1
                if i + 1 == j and j % 2 == 0 then map[i][j].type = 2 end
                if ((i + j) % 5 == 0 and i % 4 == 0) or ((i + j) % 5 == 1 and i % 4 == 0) or ((i + j) % 5 == 0 and i % 4 == 3) or ((i + j) % 5 == 4 and i % 4 == 3)then map[i][j].type = 3 end
            --]]
=======
            map[i][j].type = 1
>>>>>>> Add partial GameMap module implementation
        end
    end
    ---[[
        local nexus ={}
<<<<<<< 1556588f459ed1f62cd44f52d14a8833ff3c9e0c
        nexus.type = "nexus_red"
        nexus.id = 1
        nexus.x = 5
        nexus.y = 5
        GameMap.addActor(nexus)
=======
        nexus.asset = "dagger2"
        map[10][5].unit = nexus
        map[10][15].unit = nexus
>>>>>>> Add partial GameMap module implementation
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
<<<<<<< 1556588f459ed1f62cd44f52d14a8833ff3c9e0c
            love.graphics.draw(RM.get(mapType[map[i][j].type]), j*64, i*64)
            for _,v in pairs(map[i][j].actors) do
                love.graphics.draw(RM.get(v.type), j*64, i*64)
            end
=======
            --love.graphics.draw(RM.get(mapType[map[i][j].type]), i*20, j*20)
            love.graphics.draw(RM.get("dagger"), i*60, j*60)
            if map[i][j].unit ~= nil then love.graphics.draw(RM.get(map[i][j].unit.asset), i*60, j*60) end
>>>>>>> Add partial GameMap module implementation
        end
    end
end

function GameMap.distance(x1, y1, x2, y2)
    return abs(x1-x2)+(y1-y2)
end

function GameMap.isMoveable(x, y)
<<<<<<< 1556588f459ed1f62cd44f52d14a8833ff3c9e0c
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
=======
    if map[x][y].unit == nil and map[x][y].type == 1 then return true
    else return false
    end
end

function GameMap.removeActor(actor)
    map[actor.x][actor.y].unit = nil
end

function GameMap.addActor(actor)
    map[actor.x][actor.y].unit = actor
>>>>>>> Add partial GameMap module implementation
end

return GameMap