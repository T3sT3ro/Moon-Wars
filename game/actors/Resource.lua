local Actor = require "game/actors/Actor"

local Resource = Actor:new({type = "Resource"})

function Resource:debugInfo()
    Actor.debugInfo(self) 
end

return Resource