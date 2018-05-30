local Actor = require "game/actors/Actor"

local Unit = Actor:new({type = "Unit"})

function Unit:init(assetName, name)
    print("unit init")
    Actor.init(self, assetName)
    self.name = name
end

function Unit:debugInfo()
    print("Unit info: Name: " .. tostring(self.name))
    Actor.debugInfo(self) 
end

return Unit