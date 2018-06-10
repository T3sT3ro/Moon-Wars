local Actor = require "game/actors/Actor"

local Nexus = Actor:new({type = "Nexus", health = 200})

function Nexus:craft(name, unit)

end

function Nexus:draw()
    Actor.draw(self)
    love.graphics.print(self.health, self.x*32, self.y*32)
end

function Nexus:debugInfo()
    Actor.debugInfo(self) 
end

return Nexus