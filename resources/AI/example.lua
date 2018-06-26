local AI = {}

local dx = {1, -1, 0, 0}
local dy = {0, 0, 1, -1}
local visited
local from

local function visit(x, y)
    if not visited[x] then
        visited[x] = {}
    end
    visited[x][y] = true
end

local function isVisited(x, y)
    return visited[x] and visited[x][y] 
end

local function setFrom(x, y, fromPos)
    if not from[x] then
        from[x] = {}
    end
    from[x][y] = fromPos
end

local function isVisited(x, y)
    return visited[x] and visited[x][y] 
end

local function recreatePath(sx, sy, ex, ey)
    local path = {}
    while ex ~= sx or ey ~= sy do
        table.insert(path, 1, {x = ex, y = ey})
        local newPos = from[ex][ey]
        ex, ey = newPos.x, newPos.y
    end
    return path
end

local function findPath(map, sx, sy, ex, ey, minDist)
    minDist = minDist or 0

    local queue = {{x = sx, y = sy}}
    visited = {}
    from = {}

    while #queue > 0 do
        local pos = queue[1]
        table.remove(queue, 1)

        if map.distance(pos.x, pos.y, ex, ey) <= minDist then
            ex, ey = pos.x, pos.y
            break
        end

        for k=1, 4 do
            local x = pos.x + dx[k]
            local y = pos.y + dy[k]
            if map.isMoveable(x, y) and not isVisited(x, y) then
                visit(x, y)
                setFrom(x, y, pos)
                table.insert(queue, {x = x, y = y})
            end
        end
    end

    if not isVisited(ex, ey) then
        print("Path not found")
        return nil
    end

    return recreatePath(sx, sy, ex, ey)
end

local function move(path)
    for _, pos in ipairs(path) do
        print("x: "..pos.x..", y: "..pos.y)
        local res = doAction("move", pos.x, pos.y)
        if not res then
            print("moving failed")
            return
        end
    end
end

local function gather(unit, logic, map)
    for x = 1, 20 do
        for y = 1, 20 do
            local actor = map.getActorByStat(x, y, "itemType")
            if actor then
                local path = findPath(map, unit.x, unit.y, actor.x, actor.y, 1)
                if path then
                    move(path)
                    doAction("pickup", actor.name, x, y)
                    return
                end
            end
        end
    end
end

local function attack(unit, logic, map)
    for x = 1, 20 do
        for y = 1, 20 do
            local actor = map.getActorByStat(x, y, "health")
            if actor and actor.playerId ~= unit.playerId then
                local path = findPath(map, unit.x, unit.y, actor.x, actor.y, 1)
                if path then
                    move(path)
                    doAction("attack", x, y)
                    return
                end
            end
        end
    end
end

function AI.makeMove(unit, logic, map)
    unit:debugInfo()
    if unit.id % 2 == 0 then
        attack(unit, logic, map)
    else
        gather(unit, logic, map)
    end
    doAction("endTurn")
end

return AI