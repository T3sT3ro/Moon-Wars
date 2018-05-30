local Actor = require "game/actors/Actor"

local Item = Actor:new({type = "Item"})

function Item:init(assetName)
    Actor.init(self, assetName)
end

function Item:debugInfo()
    Actor.debugInfo(self) 
end

return Item