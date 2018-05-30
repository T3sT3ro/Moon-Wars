local Actor = require "game/actors/Actor"

local Nexus = Actor:new({type = "Nexus"})

function Nexus:init(assetName)
    Actor.init(self, assetName)
end

function Nexus:debugInfo()
    Actor.debugInfo(self) 
end

return Nexus