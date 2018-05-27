local RM = require "ResourceManager"

local GameMap = {}

function GameMap.init()
    
end

function GameMap.clear()
    
end

function GameMap.update(dt)
    
end

function GameMap.draw()
    love.graphics.draw(RM.get("dagger"), 200, 200)
end

return GameMap