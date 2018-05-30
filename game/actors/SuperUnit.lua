local Unit = require "game/actors/Unit"

local SuperUnit = Unit:new({type = "SuperUnit"})

function SuperUnit:init(assetName, name)
    Unit.init(self, assetName, name)
end

function SuperUnit:debugInfo()
    print("SuperUnit info: Name: " .. tostring(self.name))
    Unit.debugInfo(self) 
end

return SuperUnit