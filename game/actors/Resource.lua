local Actor = require "game/actors/Actor"
local map = require "game/GameMap"

local Resource = Actor:new({type = "Resource"})

function Resource:init(playerId, config)
    Actor.init(self, playerId, config)
    self.resType = config.resType 
    self.matName = config.matName  
    self.dropRate = config.dropRate
end

function Resource:produce(createActor)
    for i = 1, self.dropRate do
        local mat = createActor("Item", self.playerId, self.matName)
        mat:setPos(self.x, self.y)
        map.addActor(mat)
    end
end

function Resource:debugInfo()
    Actor.debugInfo(self) 
end

return Resource