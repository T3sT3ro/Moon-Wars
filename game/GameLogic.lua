local helper = require "game/GameLogicHelper"
local map = require "game/GameMap"
local Nexus = require "game/actors/Nexus"
local Unit = require "game/actors/Unit"
local Factory = require "game/actors/ActorFactory"

local GameLogic = {}
local _curUnitIdx = 0
local _curUnit = nil
local _curActionPoints = 0
local _actors = {}
local _units = {}

local function createActor(typeName, playerId, nameAsset)
    local actor = Factory.create(typeName, playerId, nameAsset)
    if _actors[actor.type] == nil then
        _actors[actor.type] = {}
    end

    table.insert(_actors[actor.type], actor)
    return actor
end

local function createInitActors(playerId)
    local setup = {}
    table.insert(setup, createActor("Nexus", playerId, "nexus_red"))
    for i=1, 4 do
        table.insert(setup, createActor("Unit", playerId, "unit"))
    end
    return setup
end

function GameLogic.init()
    local initActors = { createInitActors(1), createInitActors(2) }
    map.addInitActors(initActors)

    _units = _actors["Unit"]
end

function GameLogic.clear()
    _actors = {}
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