local Actor = require "game/actors/Actor"
local Items = require "game/actors/Items"
local Nexus = Actor:new({type = "Nexus", health = 200})

local function getItem(name)
    for _, item in ipairs(Items) do
        if item.name == name then
            return item
        end
    end
    return nil
end

function Nexus:tryCraft(name, unit)
    local item = getItem(name)
    if item == nil then 
        return nil
    end

    local hasAll = true
    local usedItems = {}
    for _, mat in ipairs(item.toCraft) do
        local matName = mat[1]
        local amount = mat[2]
        
        while amount > 0 and hasAll do
            if unit:hasItem(matName) then
                table.insert( usedItems, unit:getItem(matName))
                unit:removeItem(matName)
            else
                hasAll = false
                print("need " .. amount .. " more " .. matName)
            end
            amount = amount - 1
        end
    end

    if not hasAll then
        for _, item in ipairs(usedItems) do
            unit:addItem(item)
        end
        return false
    end
    return true
end

function Nexus:draw(offsetX,offsetY)
    Actor.draw(self,offsetX,offsetY)
    love.graphics.print(self.health, self.x*64-offsetX, self.y*64-offsetY)
end

function Nexus:debugInfo()
    Actor.debugInfo(self) 
end

return Nexus