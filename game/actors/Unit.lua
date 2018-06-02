local Actor = require "game/actors/Actor"

local Unit = Actor:new({type = "Unit", health = 100, movePenalty = 0, attack = 10, defense = 0, range = 1})

function Unit:debugInfo()
    Actor.debugInfo(self) 
end

return Unit