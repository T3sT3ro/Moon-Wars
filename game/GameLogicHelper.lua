local GameLogicHelper = {}

GameLogicHelper.actions = {}
function GameLogicHelper.addAction(name, callback, argsTypes, neededPoints)
    local action = {
        name = name,
        callback = callback,
        argsTypes = argsTypes,
        neededPoints = neededPoints
    }
    GameLogicHelper.actions[name] = action
end

function GameLogicHelper.checkArgs(argsTypes, ...)
    local args = {...}
    for i=1, #argsTypes do
        if i > #args or type(args[i]) ~= argsTypes[i] then
            print("type " .. i .. " is " .. type(args[i]) ", and should be: " .. argsTypes[i])
            return false
        end
    end
    print("args ok")
    return true
end

return GameLogicHelper