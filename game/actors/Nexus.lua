local Actor = require "game/actors/Actor"

local Nexus = Actor:new({type = "Nexus", health = 1000})

function Nexus:craft(name, unit)

end

function Nexus:debugInfo()
    Actor.debugInfo(self) 
end

return Nexus