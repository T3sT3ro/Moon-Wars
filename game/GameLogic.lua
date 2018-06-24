local helper = require "game/GameLogicHelper"
local map = require "game/GameMap"
local Nexus = require "game/actors/Nexus"
local Unit = require "game/actors/Unit"
local Factory = require "game/actors/ActorFactory"
local StateManager = require "StateManager"

local GameLogic = {}

local _AI = {}
local _curPlayer = nil
local _curUnitIdx = nil
local _unitsInOrder = {{},{}}
local _curUnit = nil

local _startActionPoints = 10
local _curActionPoints = _startActionPoints
local _actors = {}

function GameLogic.getCurUnit()
    return _curUnit
end

local function createActor(typeName, playerId, name)
    local actor = Factory.create(typeName, playerId, name)
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
    addInitActor(initActors, 4, "Unit", playerId, playerId == 1 and "unit_red" or "unit_blue")
    addInitActor(initActors, 3, "Resource", playerId, "tree")
    addInitActor(initActors, 2, "Resource", playerId, "rock")
    addInitActor(initActors, 1, "Resource", playerId, "crystalMine")

    return initActors
end

local function startNewRound()
    print("Starting new round")

    for _, resource in ipairs(_actors["Resource"]) do
        resource:produce(createActor)
    end

end

local function checkAIMove()
    local prevPlayer = _curPlayer
    if _AI[_curPlayer] then
        local isOk
        local res
        isOk, res = pcall(_AI[_curPlayer].makeMove, _curUnit, GameLogic, map)
        if not isOk then
            print("AI for player: " .. _curPlayer .. " crashed! Reason: " .. res)
            if prevPlayer == _curPlayer then
                GameLogic.doAction("endTurn")
            end
        end
    end
end

function GameLogic.init(player1AI, player2AI)
    _AI = {player1AI, player2AI}
    local initActors = { createInitNeutralActors(0), createInitActors(1), createInitActors(2) }
    map.addInitActors(initActors)

    for _, unit in ipairs(_actors["Unit"]) do
        table.insert(_unitsInOrder[unit.playerId], unit)
        local startWeapon = Factory.create("Item", unit.playerId, "dagger")
        unit:setStartWeapon(startWeapon)
    end

    _curPlayer = 1
    _curUnitIdx = {1, 1}
    _curUnit = _unitsInOrder[1][1]
    _curUnit.isCurUnit = true
    
    startNewRound()
    checkAIMove()
end

function GameLogic.clear()
    _actors = {}
    _unitsInOrder = {{},{}}
    _curUnit = nil
end

local function endGame(winnerId)
    print("Player " .. tostring(winnerId) .. " has won!")
    StateManager.load("MainMenuState")
end

local function nextUnit(playerId)
    local curIdx = _curUnitIdx[playerId] + 1
    if curIdx > #_unitsInOrder[playerId] then
        curIdx = 1
    end
    _curUnitIdx[playerId] = curIdx

    if curIdx == 1 and playerId == 1 then
        startNewRound()
    end

    return _unitsInOrder[playerId][curIdx]
end

function GameLogic.doAction(actionName, ...)
    local action = helper.actions[actionName]
    if  action == nil or 
        not helper.checkArgs(action.argsTypes, ...) or 
        action.neededPoints > _curActionPoints then
            return false
    end

    _curActionPoints = _curActionPoints - action.neededPoints
    return action.callback(...)
end

local function endTurn()
    print("turn ended")
    
    local prevPlayer = _curPlayer
    _curPlayer = _curPlayer + 1
    if _curPlayer > 2 then
        _curPlayer = 1 
    end

    _curUnit.isCurUnit = false
    _curUnit = nextUnit(_curPlayer)
    local iterations = 0
    local stopVal = #_unitsInOrder[_curPlayer]
    while _curUnit.health <= 0  and iterations < stopVal do
        _curUnit = nextUnit(_curPlayer)
        iterations = iterations + 1
    end
    _curUnit.isCurUnit = true

    if iterations == stopVal then
        endGame(prevPlayer)
    else
        checkAIMove()
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

local function attack(x, y)
    if map.distance(_curUnit.x, _curUnit.y, x, y) <= _curUnit.range then
        local enemy = map.getActorByStat(x, y, "health")
        if enemy == nil or enemy.playerId == _curUnit.playerId then
            return false
        end

        enemy.health = enemy.health - _curUnit.attack
        if enemy.health <= 0  then
            if enemy.type == "Unit" then
                enemy:die()
            end
            if enemy.type == "Nexus" then
                endGame(_curUnit.playerId)
            end
        end
        return true
    end
    return false
end
helper.addAction("attack", attack, {"number", "number"}, 0)

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
    
    local item = nil
    if nexus:tryCraft(name, _curUnit) then
        item = createActor("Item", _curUnit.playerId, name)
    end

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
    _curUnit:addItem(item)
    print("picked up: " .. item.name)
    return true
end
helper.addAction("pickup", pickup, {"string", "number", "number"}, 0)

local function drop(name)
    if not _curUnit:hasItem(name) then
        return false
    end

    local item = _curUnit:getItem(name)
    _curUnit:removeItem(name)
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