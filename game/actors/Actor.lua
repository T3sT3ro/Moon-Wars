local RM = require "ResourceManager"

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

function Actor:init(playerId, assetName)
    self.id = nextId()
    self.playerId = playerId
    self.asset = RM.get(assetName)
end

function Actor:draw()
    love.graphics.draw(self.asset, self.x, self.y)
end

function Actor:debugInfo()
    print("Actor info. Id: " .. self.id)
end

return Actor