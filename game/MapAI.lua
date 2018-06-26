local MapAI = {}

math.randomseed(os.time())
local function rng(x) return math.random(x) end

local types = {}

types[1] = {{0,0},{1,0},{0,1},{1,1}}
types[2] = {{0,0},{1,0},{0,1},{1,1},{2,0}}
types[3] = {{0,0},{1,0},{0,1}}
types[4] = {{0,0},{1,0},{0,1},{1,1},{0,2}}
types[5] = {{0,0},{1,1},{0,1}}
types[6] = {{0,0},{1,0},{1,1}}

local map ={}

local nex = {}

local res = {}
res.tree = {}
res.rock ={}

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
        if res.mine.x == x and  res.mine.y == y then 
            mine = mine + 1 
            return
        end
        for i=1,2 do 
            if res.rock[i].x == x and  res.rock[i].y == y then 
                rock = rock + 1 
                return
            end
        end
        for i=1,3 do 
            if res.tree[i].x == x and  res.tree[i].y == y then 
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

local function gen()
for i=1,10 do
    map[i] = {}
    for j=1,20 do
        map[i][j] = {}
        map[i][j].actors = {}
        map[i][j].type = 1
        --[[
            if i + 1 == j and j % 2 == 0 and i <= 10 then map[i][j].type = 2 end
            if ((i + j) % 5 == 0 and i % 4 == 0) or ((i + j) % 5 == 1 and i % 4 == 0) or ((i + j) % 5 == 0 and i % 4 == 3) or ((i + j) % 5 == 4 and i % 4 == 3) and i <= 10 then map[i][j].type = 3 end
        --]]
    end
end

local cnt = rng (4) + 3

for i=1,cnt do
    local x = rng(8)
    local y = rng(18)
    local typ = rng(6)
    for j in ipairs(types[typ]) do
        map[x+types[typ][j][1]][y+types[typ][j][2]].type = 2
    end
end

local x = rng(6) + 2
local y = rng(10) + 5
local way = rng(2) - 1
if way == 0 then way = -1 end

while x > 1  and y > 1 and y < 20 do
    if rng(3) > 1 then y = y + way
    elseif rng(2) == 1 then x = x + 1
    else x = x - 1 
    end
    if x == 11 then x,y = 10,21-y end
    map[x][y].type = 3
end

for i=1,3 do
    local x = rng(10)
    local y = rng(20)
    while map[x][y].type ~= 1 do
        x = rng(10)
        y = rng(20)
    end
    res.tree[i]={x = x, y = y}
end

for i=1,2 do
    local x = rng(10)
    local y = rng(20)
    while map[x][y].type ~= 1 do
        x = rng(10)
        y = rng(20)
    end
    res.rock[i]={x = x, y = y}
end

x = rng(10)
y = rng(20)
while map[x][y].type ~= 1 do
    x = rng(10)
    y = rng(20)
end
res.mine = {x = x, y = y}

x = rng(8)+1
y = rng(16)+2
while map[x-1][y].type ~= 1 and map[x+1][y].type ~= 1 and map[x][y-1].type ~= 1 and map[x][y+1].type ~= 1 do
    x = rng(8)+1
    y = rng(16)+2
end
nex.x,nex.y = x,y
--[[
nex.x,nex.y = 6,5
res.tree = {{x = 1, y = 1},{x = 2 , y = 15},{x = 9, y = 11}}
res.rock = {{x = 6, y = 8},{x = 3 ,y = 14}}
res.mine = {x = 2 , y = 10}
--]]
end

function MapAI.getMap()
    return map    
end

function MapAI.getNexus()
    return nex   
end

function MapAI.getTrees()
    return res.tree  
end

function MapAI.getRocks()
    return res.rock  
end

function MapAI.getMine()
    return res.mine    
end

function MapAI.gen()
    gen()
    while not check() do gen() end
end

return MapAI