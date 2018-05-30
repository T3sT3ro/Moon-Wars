local Actor = require "game/actors/Actor"

local Unit = Actor:new({type = "Unit"})

function Unit:debugInfo()
    Actor.debugInfo(self) 
end

return Unit