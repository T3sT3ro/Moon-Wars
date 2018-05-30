local Actor = require "game/actors/Actor"

local Resource = Actor:new({type = "Resource"})

function Resource:init(assetName)
    Actor.init(self, assetName)
end

function Resource:debugInfo()
    Actor.debugInfo(self) 
end

return Resource