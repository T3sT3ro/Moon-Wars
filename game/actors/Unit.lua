local Actor = require "game/actors/Actor"

local Unit = Actor:new({type = "Unit"})

function Unit:init(assetName, name)
    print("unit init")
    self:base().init(self, assetName)
    self.name = name
end

function Unit:debugInfo()
    print("Unit info: Name: " .. tostring(self.name))
    self:base().debugInfo(self) 
end

return Unit