local UIDebugState = {name = "UIDebugState"}

local UI = require "UI/UI"

local Color = UI.Color
local AABB = UI.AABB

local stateDesc = love.graphics.newText(love.graphics.newFont("resources/Inconsolata-Regular.ttf"), "UI_DEBUG_STATE")
local w_width = love.graphics.getWidth()
local w_height = love.graphics.getHeight()
local GUIBox = {15, 15, w_width - 30, w_height - 30}
local f1 = UI(GUIBox, {size = {x = 500, y = 500}, margin = {x = 60, y = 20}})
local f2 = UI(f1, {origin = {x = 50, y = 50}, size = {x = 200, y = 850}, margin = 15})
local f3 = UI(f2, {origin = {x = -50, y = 100}, size = {x = 100, y = 60}, margin = 3}, {allowOverflow=true})
local f4 = UI(f3, {origin = {x = 25, y= 25}, size = {x=80, y=80}})
local blueish = Color("#5050ff40")
local redish = Color("#ff505040")
local greenish = Color("#2bff2b40")

local white = Color("#ffffff")
local red = Color("#ff2b2b")
local click = {start = nil, stop = nil} -- TODO: add GUI class as UI toplevel container with click

function UIDebugState.init()
    click.start, click.stop = nil, nil
    w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
    f1.toplevel.style.size.x, f1.toplevel.style.size.y = w_width - 30, w_height - 30
    GUIBox = f1.toplevel
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

local function drawCursor(cursor, text)
    love.graphics.setColor(white:normalized())
    love.graphics.points(cursor.x, cursor.y)
    love.graphics.print(text or "Cursor", cursor.x+2, cursor.y+2)
end

function UIDebugState.draw()
    love.graphics.setColor(red:normalized())
    love.graphics.draw(stateDesc, 0, 0)
    love.graphics.rectangle("fill", w_width - 15, 0, 15, 15)
    love.graphics.rectangle("line", GUIBox.style.origin.x, GUIBox.style.origin.y, GUIBox.style.size.x, GUIBox.style.size.y)
    love.graphics.setColor(white:normalized())
    love.graphics.print("X", w_width - 12, 0)

    if love.keyboard.isDown("a") then
        drawAABB(f1:getAvailAABB(), blueish, "     F1_A")
        drawAABB(f2:getAvailAABB(), blueish, "     F2_A")
        drawAABB(f3:getAvailAABB(), blueish, "     F3_A")
        drawAABB(f4:getAvailAABB(), blueish, "     F4_A")
        
    end
    if love.keyboard.isDown("i") then
        drawAABB(f1:getAABB(), redish, "F1_I")
        drawAABB(f2:getAABB(), redish, "F2_I")
        drawAABB(f3:getAABB(), redish, "F3_I")
        drawAABB(f4:getAABB(), redish, "F4_I")
        
    end
    if love.keyboard.isDown("r") then
        drawAABB(f1:getRealAABB(), greenish, "\n^F1_R")
        drawAABB(f2:getRealAABB(), greenish, "\n^F2_R")
        drawAABB(f3:getRealAABB(), greenish, "\n^F3_R")
        drawAABB(f4:getRealAABB(), greenish, "\n^F4_R")
        
    end
    if love.keyboard.isDown("c") then
        if love.keyboard.isDown('1') then  f1:setCursor(0,0) drawCursor(f1:getRawCursor(), "F1_cursor")
        f1:setRawCursor((f1:getAvailAABB())[1]) drawCursor(f1:getRawCursor(), "F1_avail_cursor") end
        if love.keyboard.isDown('2') then  f2:setCursor(0,0) drawCursor(f2:getRawCursor(), "F2_cursor")
        f2:setRawCursor((f2:getAvailAABB())[1]) drawCursor(f2:getRawCursor(), "F2_avail_cursor") end
        if love.keyboard.isDown('3') then  f3:setCursor(0,0) drawCursor(f3:getRawCursor(), "F3_cursor")
        f3:setRawCursor((f3:getAvailAABB())[1]) drawCursor(f3:getRawCursor(), "F3_avail_cursor") end
        if love.keyboard.isDown('4') then  f4:setCursor(0,0) drawCursor(f4:getRawCursor(), "F4_cursor")
        f4:setRawCursor((f4:getAvailAABB())[1]) drawCursor(f4:getRawCursor(), "F4_avail_cursor") end
    end
end

return UIDebugState

--[[
    if type(stateName) ~= 'string' then error("StateManager: passed argument is not a string.") end
    if not state then error("StateManager: no state '"..stateName.."' loaded.") end
]]
