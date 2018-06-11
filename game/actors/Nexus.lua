local Actor = require "game/actors/Actor"
local Items = require "game/actors/Items"
local Nexus = Actor:new({type = "Nexus", health = 200})

function Nexus:tryCraft(name, unit)
    -- check if unit has necessary materials
    -- return false if no
    -- use them and return true otherwise
    return true
end

function Nexus:draw()
    Actor.draw(self)
    love.graphics.print(self.health, self.x*32, self.y*32)
end

function Nexus:debugInfo()
    Actor.debugInfo(self) 
end

return Nexus