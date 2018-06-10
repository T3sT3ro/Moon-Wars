local Actor = require "game/actors/Actor"

local Item = Actor:new({type = "Item"})

function Item:init(playerId, config)
    Actor.init(self, playerId, config)
    self.itemType = config.itemType  
    self.onUseEffect = config.onUse
    self.toCraft = config.toCraft
end

function Item:onUse(...)
    self.onUseEffect(...)
end

function Item:debugInfo()
    Actor.debugInfo(self) 
end

return Item