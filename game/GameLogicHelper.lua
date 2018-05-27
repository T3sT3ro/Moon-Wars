local GameLogicHelper = {}

GameLogicHelper.actions = {}
local function addAction(name, callback, argsTypes, neededPoints)
    local action = {
        name = name,
        callback = callback,
        argsTypes = argsTypes,
        neededPoints = neededPoints
    }
    GameLogicHelper.actions[name] = action
end

function GameLogicHelper.loadActions()
    
end

function GameLogicHelper.checkArgs(argsTypes, ...)
    local args = {...}
    for i=1, #argsTypes do
        if i > #args or type(args[i]) ~= argsTypes[i] then
            return false
        end
    end
    return true
end

return GameLogicHelper