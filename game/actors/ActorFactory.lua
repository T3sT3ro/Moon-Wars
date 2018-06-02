local Unit = require "game/actors/Unit"
local Item = require "game/actors/Item"
local Nexus = require "game/actors/Nexus"
local Resource = require "game/actors/Resource"
local Items = require "game/actors/Items"
local Resources = require "game/actors/Resources"

local ActorFactory = {}

local function getConfig(configs, name)
    for _, config in ipairs(configs) do
        if config.name == name then
            return config
        end
    end
    error("config not found for name: " .. name)
    return nil
end

local function getItemConfig(name)
    return getConfig(Items, name)
end

local function getResourceConfig(name)
    return getConfig(Resources, name)
end

local function returnName(name)
    return {name = name}
end

local typeCreators = 
{
    Unit = Unit,
    Item = Item,
    Nexus = Nexus,
    Resource = Resource
}

local configCreators = 
{
    Unit = returnName,
    Item = getItemConfig,
    Nexus = returnName,
    Resource = getResourceConfig
}

function ActorFactory.create(typeName, playerId, name)
    if typeCreators[typeName] == nil then 
        error("Bad actor type: " .. typeName)
    end

    local o = typeCreators[typeName]:new()
    local config = configCreators[typeName](name)
    o:init(playerId, config)
    return o
end

return ActorFactory