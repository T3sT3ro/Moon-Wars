local RM = require "ResourceManager"
local Items = require "game/actors/Items"
local Resources = require "game/actors/Resources"

-- HELPERS
local function nextIdGenerator()
    local id = 0
    return function()
        id = id + 1
        return id
    end
end
local nextId = nextIdGenerator()

local Actor = {x = 0, y = 0}
function Actor:new(o)
    o = o or {} 
    self.__index = self
    setmetatable(o, self)
    return o
end

function Actor:init(playerId, config)
    self.id = nextId()
    self.playerId = playerId
    self.name = config.name
    if config.assetName then
        self.asset = RM.get(config.assetName)
    else
        self.asset = RM.get(config.name)
    end
end

function Actor:draw()
    love.graphics.draw(self.asset, self.x, self.y)
end

function Actor:debugInfo()
    print("Actor info. Id: " .. self.id)
end

local function getConfig(configs, name)
    for _, config in ipairs(configs) do
        if config.name == name then
            return config
        end
    end
    error("config not found for name: " .. name)
    return nil
end

function Actor.getItemConfig(name)
    return getConfig(Items, name)
end

function Actor.getResourceConfig(name)
    return getConfig(Resources, name)
end

return Actor