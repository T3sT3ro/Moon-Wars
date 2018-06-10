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

local Actor = {x = 1, y = 1}
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
    love.graphics.draw(self.asset, self.x*32, self.y*32,0,0.5,0.5)
end

function Actor:setPos(x, y)
    self.x = x
    self.y = y
end

function Actor:debugInfo()
    print("Actor info:")
    for k, v in pairs(self) do
        print(k .. ": " .. tostring(v))
    end 
    print("")
end

return Actor