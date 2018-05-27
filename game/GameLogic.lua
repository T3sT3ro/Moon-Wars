local helper = require "game/GameLogicHelper"
local map = require "game/GameMap"

local GameLogic = {}
local _units = {}
local _curUnitIdx = 0
local _curUnit = nil
local _curActionPoints = 0

function GameLogic.init()
    
end

function GameLogic.clear()
    
end

function GameLogic.doAction(actionName, ...)
    local action = helper.actions[actionName]
    if  action == nil or 
        helper.checkArgs(action.argsTypes, ...) or 
        action.neededPoints > _curActionPoints then
            return false
    end

    _curActionPoints = _curActionPoints - action.neededPoints
    return action.callback(...)
end

local function endRound()
    print("Round has been ended")
end

local function endTurn()
    _curUnitIdx = _curUnitIdx + 1
    if _curUnitIdx > #_units then
        _curUnitIdx = 1
        endRound()
    end
    _curUnit = _units[_curUnitIdx]
end
helper.addAction("endTurn", endTurn, {}, 0)

local function move(x, y)
    if map.isMovable(x, y) and map.distance(_curUnit.x, _curUnit.y, x, y) == 1 then
        map.removeActor(_curUnit)
        _curUnit.setPos(x, y)
        map.addActor(_curUnit)
        return true
    end
    return false
end
helper.addAction("move", makeMove, {"number", "number"}, 1)

return GameLogic