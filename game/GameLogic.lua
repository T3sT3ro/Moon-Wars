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
local _unitsInOrder = {}

local function createActor(typeName, playerId, nameAsset)
    local actor = Factory.create(typeName, playerId, nameAsset)
    if _actors[actor.type] == nil then
        _actors[actor.type] = {}
    end

    table.insert(_actors[actor.type], actor)
    return actor
end

local function createInitActors(playerId)
    local initActors = {}
    table.insert(initActors, createActor("Nexus", playerId, "nexus_red"))
    for i=1, 4 do
        table.insert(initActors, createActor("Unit", playerId, "unit"))
    end
    return initActors
end

function GameLogic.init()
    local initActors = { createInitActors(1), createInitActors(2) }
    map.addInitActors(initActors)

    local addedUnits = {0, 0}
    for _, unit in ipairs(_actors["Units"]) do
        local added = addedUnits[unit.playerId]
        local orderNum = unit.playerId + 2 * added
        _unitsInOrder[orderNum] = unit
        addedUnits[unit.playerId] = added + 1
    end
    _curUnitIdx = 1
    _curUnit = _unitsInOrder[_curUnitIdx]
end

function GameLogic.clear()
    _actors = {}
    _unitsOrder = {}
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
    print("Round has ended")
end

local function endTurn()
    _curUnitIdx = _curUnitIdx + 1
    if _curUnitIdx > #_unitsInOrder then
        _curUnitIdx = 1
        endRound()
    end
    _curUnit = _unitsInOrder[_curUnitIdx]
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
helper.addAction("move", move, {"number", "number"}, 1)

local function attack(x, y)
    if map.distance(_curUnit.x, _curUnit.y, x, y) <= _curUnit.range then
        local enemy = map.getActor(x, y, "health") -- look for actor with "health" field
        if enemy == nil or enemy.playerId == _curUnit.playerId then
            return false
        end

        enemy.health = enemy.health - _curUnit.attack
        if enemy.health <= 0 then
            enemy.die()
        end
        return true
    end
    return false
end
helper.addAction("attack", attack, {"number", "number"}, 1)

local function getNexus(playerId)
    local nexuses = _actors["Nexus"]
    for _, nexus in ipairs(nexuses) do
        if nexus.playerId == playerId then
            return nexus
        end
    end
    return nil
end

local function craft(name)
    local nexus = getNexus(_curUnit.playerId)
    if map.distance(nexus.x, nexus.y, _curUnit.x, _curUnit.y) > 1 then
        return false
    end

    return true
end
helper.addAction("craft", craft, {"string"}, 1)

local function pickup(name, x, y)
    return true
end
helper.addAction("pickup", pickup, {"string", "number", "number"}, 0)

local function drop(name)
    return true
end
helper.addAction("drop", drop, {"string"}, 0)

local function use(name)
    return true
end
helper.addAction("use", use, {"string"}, 0)

return GameLogic