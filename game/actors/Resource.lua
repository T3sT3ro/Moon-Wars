local Actor = require "game/actors/Actor"

local Resource = Actor:new({type = "Resource"})

function Resource:init(playerId, config)
    Actor.init(self, playerId, config)
    self.resType = config.resType 
    self.matName = config.matName  
    self.dropRate = config.dropRate
end

function Resource:debugInfo()
    Actor.debugInfo(self) 
end

return Resource