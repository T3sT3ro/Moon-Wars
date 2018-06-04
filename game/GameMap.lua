local RM = require "ResourceManager"

local GameMap = {}

function GameMap.init()
      
end

function GameMap.addInitActors(initActors)
    local neutralActors = initActors[1]
    local player1Actors = initActors[2] -- contains Nexus and Units
    local player2Actors = initActors[3]
end

function GameMap.clear()
    
end

function GameMap.update(dt)
    
end

function GameMap.draw()
    love.graphics.draw(RM.get("dagger"), 200, 200)
end

return GameMap