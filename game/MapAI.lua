local MapAI = {}

local map ={}

local nex = {}

local res = {}

for i=1,10 do
    map[i] = {}
    for j=1,20 do
        map[i][j] = {}
        map[i][j].actors = {}
        ---[[
            map[i][j].type = 1
            if i + 1 == j and j % 2 == 0 and i <= 10 then map[i][j].type = 2 end
            if ((i + j) % 5 == 0 and i % 4 == 0) or ((i + j) % 5 == 1 and i % 4 == 0) or ((i + j) % 5 == 0 and i % 4 == 3) or ((i + j) % 5 == 4 and i % 4 == 3) and i <= 10 then map[i][j].type = 3 end
        --]]
    end
end

nex.x,nex.y = 6,5
res.tree = {{x = 1, y = 1},{x = 2 , y = 15},{x = 9, y = 11}}
res.rock = {{x = 6, y = 8},{x = 3 ,y = 14}}
res.mine = {x = 2 , y = 10}


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

return MapAI