local RM = require "ResourceManager"

local GameMap = {}

function GameMap.init()
      
end

function GameMap.addInitActors(initActors)
    player1Actors = initActors[1] -- contains Nexus and Units
    player2Actors = initActors[2]
end

function GameMap.clear()
    
end

function GameMap.update(dt)
    
end

function GameMap.draw()
    love.graphics.draw(RM.get("dagger"), 200, 200)
end

return GameMap