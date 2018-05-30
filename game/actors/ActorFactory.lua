local Unit = require "game/actors/Unit"
local Item = require "game/actors/Item"
local Nexus = require "game/actors/Nexus"
local Resource = require "game/actors/Resource"

local ActorFactory = {}

local typeCreators = 
{
    Unit = Unit,
    Item = Item,
    Nexus = Nexus,
    Resource = Resource
}

function ActorFactory.create(typeName, playerId, assetName)
    if typeCreators[typeName] == nil then 
        error("Bad actor type: " .. typeName)
    end

    local o = typeCreators[typeName]:new()
    o:init(playerId, assetName)
    return o
end

return ActorFactory