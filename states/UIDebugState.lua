local UIDebugState = {name = "UIDebugState"}

local UI = require "UI/UI"

local Color = UI.Color
local AABB = UI.AABB

local stateDesc = love.graphics.newText(love.graphics.newFont("resources/Inconsolata-Regular.ttf"), "UI_DEBUG_STATE")
local w_width = love.graphics.getWidth()
local w_height = love.graphics.getHeight()
local GUIBox = {origin = {x = 15, y = 15}, size = {x = w_width - 30, y = w_height - 30}}
local f1 = UI(GUIBox, {size = {x = 500, y = 500}, margin = {x = 60, y = 20}}, nil, nil)
local f2 = UI(f1, {size = {x = 200, y = 850}, margin = 15}, nil, nil) -- TODO: check origin calculation
local f3 = UI(f2, {size = {x = 60, y = 30}, margin = 3}, nil, nil)
local avail = Color("#5050ff40")
local inside = Color("#ff505040")
local white = Color("#ffffff")
local red = Color("#ff2b2b")
local green = Color("#2b2b2b")
local click = {start = nil, stop = nil} -- TODO: add GUI class as UI toplevel container with click

function UIDebugState.init()
    click.start, click.stop = nil, nil
    w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
    GUIBox.size.x, GUIBox.size.y = w_width - 30, w_height - 30
end

function UIDebugState.clear()
    click.start, click.stop = nil, nil
end

function UIDebugState.update(dt)
    if love.mouse.isDown(1) and not click.start then
        click.start = {x = love.mouse.getX(), y = love.mouse.getY()}
    end
    if not love.mouse.isDown(1) and click.start then
        click.stop = {x = love.mouse.getX(), y = love.mouse.getY()}
    end

    if
        love.mouse.getX() > w_width - 15 and love.mouse.getY() < 15 and click.start and click.stop and
            click.start.x > w_width - 15 and
            click.start.y < 15 and
            click.stop.x > w_width - 15 and
            click.stop.y < 15
     then
        StateManager.load(MainMenuState.name)
    end
    if click.stop then
        click.start, click.stop = nil, nil
    end
end

local function drawAABB(AABB, c, n)
    local original = Color(love.graphics.getColor())
    love.graphics.setColor(white:normalized())
    love.graphics.print(n, AABB[1].x, AABB[1].y)
    love.graphics.setColor(c:normalized())
    love.graphics.rectangle("fill", AABB[1].x, AABB[1].y, AABB[2].x - AABB[1].x, AABB[2].y - AABB[1].y)
    love.graphics.setColor(original:normalized())
end

function UIDebugState.draw()
    love.graphics.setColor(red:normalized())
    love.graphics.draw(stateDesc, 0, 0)
    love.graphics.rectangle("fill", w_width - 15, 0, 15, 15)
    love.graphics.rectangle("line", GUIBox.origin.x, GUIBox.origin.y, GUIBox.size.x, GUIBox.size.y)
    love.graphics.setColor(white:normalized())
    love.graphics.print("X", w_width - 12, 0)
    drawAABB(f1:getAvailAABB(), avail, "               f1 avail")
    drawAABB(f1:getAABB(), inside, "f1 inside")
    drawAABB(f2:getAvailAABB(), avail, "               f2 avail")
    drawAABB(f2:getAABB(), inside, "f2 inside")
    drawAABB(f3:getAvailAABB(), avail, "               f3 avail")
    drawAABB(f3:getAABB(), inside, "f3 inside")
    -- TODO: check realAABB calculation
end

return UIDebugState

--[[
    if type(stateName) ~= 'string' then error("StateManager: passed argument is not a string.") end
    if not state then error("StateManager: no state '"..stateName.."' loaded.") end
]]
