local RM = require "ResourceManager"
local AI = require "game/MapAI"
local abs = math.abs
local GameMap = {}

local map = {}

local nex = {}

local res = {}
res[1] = {}
res[2] = {}

local mapType = {"grass","stone_tile","water"}
--[[
    map types:
    1 - grass
    2 - rock
    3 - water
--]]

local function check()
    local tree,rock,mine,pass,err = 0,0,0,false,true
    if map[nex.x][nex.y].type ~= 1 or map[nex.x+1][nex.y].type ~= 1 or map[nex.x-1][nex.y].type ~= 1 or map[nex.x][nex.y+1].type ~= 1 or map[nex.x][nex.y-1].type ~= 1 then
        return false
    end
    local vis ={}
    for i=1,20 do
        vis[i] = {}
        for j=1,20 do
            vis[i][j] = false
        end
    end
    local function dfs(x,y)
        if vis[x][y] then return end
        vis[x][y] = true
        if x == 10 then pass = true end
        if #map[x][y].actors > 1 then err = false end
        if res[1].mine.x == x and  res[1].mine.y == y then 
            mine = mine + 1 
            return
        end
        for i=1,2 do 
            if res[1].rock[i].x == x and  res[1].rock[i].y == y then 
                rock = rock + 1 
                return
            end
        end
        for i=1,3 do 
            if res[1].tree[i].x == x and  res[1].tree[i].y == y then 
                tree = tree + 1 
                return
            end
        end
        if x < 10 and map[x+1][y].type == 1 then dfs(x+1,y) end
        if x > 1 and map[x-1][y].type == 1 then dfs(x-1,y) end
        if y < 20 and map[x][y+1].type == 1 then dfs(x,y+1) end
        if y > 1 and map[x][y-1].type == 1 then dfs(x,y-1) end
    end
    dfs(nex.x,nex.y)
    if tree == 3 and rock == 2 and mine == 1 and pass then return true end
    return false
end

function GameMap.init(MapAIPath)
    if MapAIPath ~= nil then 
        AI = require(MapAIPath)
    end
    --[[for i=1,20 do
        map[i] = {}
        for j=1,20 do
            map[i][j] = {}
            map[i][j].actors = {}
            ---[[
                map[i][j].type = 1
                if i + 1 == j and j % 2 == 0 and i <= 10 then map[i][j].type = 2 end
                if ((i + j) % 5 == 0 and i % 4 == 0) or ((i + j) % 5 == 1 and i % 4 == 0) or ((i + j) % 5 == 0 and i % 4 == 3) or ((i + j) % 5 == 4 and i % 4 == 3) and i <= 10 then map[i][j].type = 3 end
        end
    end--]]
    map = AI.getMap()
    for i=1,10 do
        for j=1,20 do
            map[i][j].actors = {}
        end
    end
    for i=11,20 do
        map[i] = {}
        for j=1,20 do
            map[i][j] = {}
            map[i][j].actors = {}
            map[i][j].type = map[21-i][21-j].type
        end
    end

    --[[
        nex.x,nex.y = 6,5
        res[1].tree = {{x = 1, y = 1},{x = 2 , y = 15},{x = 9, y = 11}}
        res[1].rock = {{x = 6, y = 8},{x = 3 ,y = 14}}
        res[1].mine = {x = 2 , y = 10}
        --]]
        nex = AI.getNexus()
        res[1].tree = AI.getTrees()
        res[1].rock = AI.getRocks()
        res[1].mine = AI.getMine()
        res[2].tree = {}
        res[2].rock = {}
        res[2].mine = {}
        for i=1, 3 do
            res[2].tree[i] = {}
            res[2].tree[i].x,res[2].tree[i].y = 21 -res[1].tree[i].x,21 - res[1].tree[i].y
        end
        for i=1, 2 do
            res[2].rock[i] = {}
            res[2].rock[i].x,res[2].rock[i].y = 21 -res[1].rock[i].x,21 - res[1].rock[i].y
        end
        res[2].mine.x,res[2].mine.y = 21 -res[1].mine.x,21 - res[1].mine.y
        --]]

    if check() == false then 
        error("Wrong map generated")
    end
end

local function addActTable(tab)
    for _,actor in ipairs(tab) do
        map[actor.x][actor.y].actors[actor.id] = actor
    end
end

local function setAct(player,tab)
    local x,y = nex.x,nex.y
    local units,trees,rocks = 0,1,1
    if player == 2 then
        x,y = 21 - x,21 - y
    end
    for _,actor in ipairs(tab) do
        if actor.type == "Nexus" then 
            actor.x,actor.y = x,y
        elseif actor.type == "Unit" then 
            if units == 0 then
                actor.x,actor.y = x+1,y
            elseif units == 1 then
                actor.x,actor.y = x-1,y
            elseif units == 2 then
                actor.x,actor.y = x,y+1
            elseif units == 3 then
                actor.x,actor.y = x,y-1
            end
            units = units + 1
        elseif actor.type == "Resource" then
            if actor.resType == "tree" then
                actor.x,actor.y = res[player].tree[trees].x,res[player].tree[trees].y
                trees = trees + 1
            elseif actor.resType == "rock" then
                actor.x,actor.y = res[player].rock[rocks].x,res[player].rock[rocks].y
                rocks = rocks + 1
            elseif actor.resType == "mine" then
                actor.x,actor.y = res[player].mine.x,res[player].mine.y
            end
        end
    end
end

function GameMap.addInitActors(initActors)
    local neutralActors = initActors[1]
    local player1Actors = initActors[2] -- contains Nexus and Units
    local player2Actors = initActors[3]
    setAct(1,player1Actors)
    setAct(2,player2Actors)
    addActTable(neutralActors)
    addActTable(player1Actors)
    addActTable(player2Actors)
end

function GameMap.clear()
    map = {}
    nex = {}
    res = {}
    res[1] = {}
    res[2] = {}
end

function GameMap.update(dt)
    
end

function GameMap.draw(offsetX,offsetY)
    --love.graphics.setColor(1,1,1,1)
    for i=1,20 do
        for j=1,20 do
            love.graphics.draw(RM.get(mapType[map[i][j].type]), i*32 - offsetX, j*32-offsetY,0,0.5,0.5)
            for _,v in pairs(map[i][j].actors) do
                if v.type ~= "Unit" and v.type ~= "Item" then v:draw(offsetX,offsetY) break end
            end
            for _,v in pairs(map[i][j].actors) do
                if v.type == "Item" then v:draw(offsetX,offsetY) end
            end
            for _,v in pairs(map[i][j].actors) do
                if v.type == "Unit" then v:draw(offsetX,offsetY) break end
            end
        end
    end
end

function GameMap.distance(x1, y1, x2, y2)
    return abs((x1-x2))+abs((y1-y2))
end

function GameMap.isMoveable(x, y)
    if map[x] == nil or map[x][y] == nil then return false end
    if map[x][y].type ~= 1 then return false end
    for _,v in pairs(map[x][y].actors) do
        if v.type ~= "Item" then return false end
    end
    return true
end

function GameMap.mousePressed(x,y,button)
    
end


function GameMap.removeActor(actor)
    if map[actor.x][actor.y].actors[actor.id] == nil then error("No actor on map") end
    map[actor.x][actor.y].actors[actor.id] = nil
end

function GameMap.addActor(actor)
    map[actor.x][actor.y].actors[actor.id] = actor
end

function GameMap.getActorByStat(x, y, statName)
    if map[x] == nil or map[x][y] == nil then return nil end
    for _, actor in pairs(map[x][y].actors) do
        if actor[statName] ~= nil then
            return actor
        end
    end
    return nil
end

function GameMap.getActorByName(x, y, actorName)
    if map[x] == nil or map[x][y] == nil then return nil end
    for _, actor in pairs(map[x][y].actors) do
        if actor.name == actorName then
            return actor
        end
    end
    return nil
end

function GameMap.getActorByType(x, y, actorType)
    if map[x] == nil or map[x][y] == nil then return nil end
    for _, actor in pairs(map[x][y].actors) do
        if actor.type == actorType then
            return actor
        end
    end
    return nil
end
return GameMap