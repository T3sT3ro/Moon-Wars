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

function GameManager.doAction(actionName, ...)
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

function GameLogic.endTurn()
    _curUnitIdx = _curUnitIdx + 1
    if _curUnitIdx > #_units then
        _curUnitIdx = 1
        endRound()
    end
    _curUnit = _units[_curUnitIdx]
end

function GameLogic.makeMove(x, y)
    if map.isMovable(x, y) and map.distance(_curUnit.x, _curUnit.y, x, y) == 1 then
        map.removeActor(_curUnit)
        _curUnit.setPos(x, y)
        map.addActor(_curUnit)
        return true
    end
    return false
end

helper.addAction("MOVE", GameLogic.makeMove, {"number", "number"}, 1)

return GameLogic