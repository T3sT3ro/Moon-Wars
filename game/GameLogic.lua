local helper = require "game/GameLogicHelper"
local map = require "game/GameMap"
local Nexus = require "game/actors/Nexus"
local Unit = require "game/actors/Unit"
local Factory = require "game/actors/ActorFactory"
local StateManager = require "StateManager"

local GameLogic = {}

local _curUnitIdx = 0
local _curUnit = nil
local _startActionPoints = 10
local _curActionPoints = _startActionPoints
local _actors = {}
local _unitsInOrder = {}

function GameLogic.getCurUnit()
    return _curUnit
end

local function createActor(typeName, playerId, nameAsset)
    local actor = Factory.create(typeName, playerId, nameAsset)
    if _actors[actor.type] == nil then
        _actors[actor.type] = {}
    end

    table.insert(_actors[actor.type], actor)
    return actor
end

local function addInitActor(initActors, amount, typeName, playerId, name)
    while amount > 0 do
        table.insert(initActors, createActor(typeName, playerId, name))
        amount = amount - 1
    end
end

local function createInitNeutralActors(neutralId)
    local initActors = {}

    --addInitActor(initActors, 1, "Item", neutralId, "magicRing")
    --addInitActor(initActors, 1, "Item", neutralId, "bow")
    --addInitActor(initActors, 1, "Item", neutralId, "sword")

    return initActors
end

local function createInitActors(playerId)
    local initActors = {}
    local add = function (amount, typeName, playerId, name)
        while amount > 0 do
            table.insert(initActors, createActor(typeName, playerId, name))
            amount = amount - 1
        end
    end

    addInitActor(initActors, 1, "Nexus", playerId, playerId == 1 and "nexus_red" or "nexus_blue")
    addInitActor(initActors, 4, "Unit", playerId, "unit")
    addInitActor(initActors, 3, "Resource", playerId, "tree")
    addInitActor(initActors, 2, "Resource", playerId, "rock")
    --addInitActor(initActors, 1, "Resource", playerId, "crystalMine")

    return initActors
end

function GameLogic.init()
    local initActors = { createInitNeutralActors(0), createInitActors(1), createInitActors(2) }
    map.addInitActors(initActors)

    local addedUnits = {0, 0}
    for _, unit in ipairs(_actors["Unit"]) do
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
    print("action: " .. tostring(action))
    if  action == nil or 
        not helper.checkArgs(action.argsTypes, ...) or 
        action.neededPoints > _curActionPoints then
            return false
    end

    _curActionPoints = _curActionPoints - action.neededPoints
    return action.callback(...)
end

local function endRound()
    print("Round has ended")
end

local function nextUnit()
    _curUnitIdx = _curUnitIdx + 1
    if _curUnitIdx > #_unitsInOrder then
        _curUnitIdx = 1
        endRound()
    end
    _curUnit = _unitsInOrder[_curUnitIdx]
    _curActionPoints = _startActionPoints
end

local function endTurn()
    print("turn ended")
    
    local stopId = _curUnit.id
    local curPlayerId = _curUnit.playerId
    nextUnit()
    while _curUnit.health <= 0 or _curUnit.playerId == curPlayerId and _curUnit.id ~= stopId do
        nextUnit()
    end
    
    if _curUnit.id == stopId then -- all units of enemy are dead 
        endGame(_curUnit.playerId)
    end
end
helper.addAction("endTurn", endTurn, {}, 0)

local function move(x, y)
    print("x: " .. tostring(x) .. ", y: " .. tostring(y))
    print("isMoveable: " .. tostring(map.isMoveable(x, y)))
    if map.isMoveable(x, y) and map.distance(_curUnit.x, _curUnit.y, x, y) == 1 then
        map.removeActor(_curUnit)
        _curUnit:setPos(x, y)
        map.addActor(_curUnit)
        return true
    end
    return false
end
helper.addAction("move", move, {"number", "number"}, 0)

local function endGame(winnerId)
    print("Player " .. tostring(winnerId) .. " has won!")
    StateManager.load("MainMenuState")
end

local function attack(x, y)
    if map.distance(_curUnit.x, _curUnit.y, x, y) <= _curUnit.range then
        local enemy = map.getActorByStat(x, y, "health")
        if enemy == nil or enemy.playerId == _curUnit.playerId then
            return false
        end

        enemy.health = enemy.health - _curUnit.attack
        if enemy.health <= 0  then
            if enemy.type == "Unit" then
                enemy.die()
            end
            if enemy.type == "Nexus" then
                endGame(_curUnit.playerId)
            end
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
    
    local item = nexus:craft(name, _curUnit)
    if item == nil then
        return false
    end

    item:setPos(nexus.x, nexus.y)
    map.addActor(item)
    return true
end
helper.addAction("craft", craft, {"string"}, 1)

local function pickup(name, x, y)
    local item = map.getActorByName(x, y, name)
    if item == nil then
        return false
    end

    map.removeActor(item)
    _curUnit:addToEq(item)
    return true
end
helper.addAction("pickup", pickup, {"string", "number", "number"}, 0)

local function drop(name)
    if not _curUnit.hasItem(name) then
        return false
    end

    local item = _curUnit:getItem(name)
    item:setPos(_curUnit.x, _curUnit.y)
    map.addActor(item)
    return true
end
helper.addAction("drop", drop, {"string"}, 0)

local function use(name)
    if not _curUnit:hasItem(name) then
        return false
    end

    _curUnit:useItem(name)
    return true
end
helper.addAction("use", use, {"string"}, 0)

return GameLogic