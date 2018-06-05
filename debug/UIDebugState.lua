local UIDebugState = {name = "UIDebugState"}

local UI = require "UI/UI"
local UIWidget = require "UI/UIWidget"
local Color = require "UI/Color"
local AABB = require "UI/AABB"

local stateDesc
local w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
local margin = 15
local GUI = UI(margin, margin, w_width - 2 * margin, w_height - 2 * margin)
local f0 = UIWidget({size = {x = "80%", y = "80%"}, margin = {all = 5}})
local f1 = UIWidget({size = {x = "80%", y = "80%"}, margin = {all = 5}})
local f2 = UIWidget({size = {x = "80%", y = "80%"}, margin = {all = 5}})
local f3 = UIWidget({size = {x = "80%", y = "80%"}, margin = {all = 5}})
GUI:setWidget(f0)
f0:addWidget(f1)
f1:addWidget(f2)
f2:addWidget(f3)

local blueish = Color("#5050ff20")
local redish = Color("#ff505020")
local greenish = Color("#2bff1b20")
local white = Color("#ffffff")
local red = Color("#ff1b2b")
local click = {start = nil, stop = nil}

local widgetRenderer = function(self)
    self:setCursor(0, 0)
    local original = {love.graphics.getColor()}
    ---[[
    love.graphics.setColor(white:normalized())
    love.graphics.print(self._ID, self._AABB[1].x, self._AABB[1].y)
    love.graphics.setColor(red:normalized())
    love.graphics.rectangle("line", self:getAABB():normalized())
    ---[[
    love.graphics.setColor(greenish:normalized())
    love.graphics.rectangle("fill", self:getRealAABB():normalized())
    --]]
    love.graphics.setColor(blueish:normalized())
    love.graphics.rectangle("fill", 0, 0, w_width, w_height)
    love.graphics.setColor(original[1], original[2], original[3], original[4])
end

f0.renderer = widgetRenderer
f1.renderer = widgetRenderer
f2.renderer = widgetRenderer
f3.renderer = widgetRenderer

function UIDebugState.init()
    stateDesc = stateDesc or love.graphics.newText(ResourceManager.get("fonts.Montserrat-Regular"), "UI_DEBUG_STATE")
    click.start, click.stop = nil, nil
    w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
end

function UIDebugState.clear()
    click.start, click.stop = nil, nil
end

function UIDebugState.update(dt)
    GUI:update(dt)
    if w_width ~= love.graphics.getWidth() or w_height ~= love.graphics.getHeight() then
        w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
        GUI:resize(margin, margin, w_width - 2 * margin, w_height - 2 * margin)
    end
    if love.mouse.isDown(1) and not click.start then
        click.start = {x = love.mouse.getX(), y = love.mouse.getY()}
    end
    if not love.mouse.isDown(1) and click.start then
        click.stop = {x = love.mouse.getX(), y = love.mouse.getY()}
    end

    if
        love.mouse.getX() > w_width - margin and love.mouse.getY() < margin and click.start and click.stop and
            click.start.x > w_width - margin and
            click.start.y < margin and
            click.stop.x > w_width - margin and
            click.stop.y < margin
     then
        StateManager.load(MainMenuState.name)
    end
    if click.stop then
        click.start, click.stop = nil, nil
    end
end

local function drawAABB(AABB, c, n)
    local x, y, w, h = love.graphics.getScissor()
    love.graphics.setScissor(GUI.origin.x, GUI.origin.y, GUI:width(), GUI:height())
    local original = Color(love.graphics.getColor())
    love.graphics.setColor(white:normalized())
    love.graphics.print(n, AABB[1].x, AABB[1].y)
    love.graphics.setColor(c:normalized())
    love.graphics.rectangle("fill", AABB[1].x, AABB[1].y, AABB[2].x - AABB[1].x, AABB[2].y - AABB[1].y)
    love.graphics.setColor(original:normalized())
    love.graphics.setScissor(x, y, w, h)
end

local function drawCursor(cursor, text)
    love.graphics.setColor(white:normalized())
    love.graphics.points(cursor.x, cursor.y)
    love.graphics.print(text or "Cursor", cursor.x + 2, cursor.y + 2)
end

function UIDebugState.draw()
    GUI:draw()
    love.graphics.setColor(red:normalized())
    love.graphics.draw(stateDesc, 0, 0)
    love.graphics.rectangle("fill", w_width - 15, 0, 15, 15)
    love.graphics.rectangle("line", GUI.origin.x, GUI.origin.y, GUI.size.x, GUI.size.y)
    love.graphics.setColor(white:normalized())
    love.graphics.print("X", w_width - 12, 0)

    if love.keyboard.isDown("a") then
        drawAABB(f0:getAvailAABB(), blueish, " F0_A")
        drawAABB(f1:getAvailAABB(), blueish, " F1_A")
        drawAABB(f2:getAvailAABB(), blueish, " F2_A")
        drawAABB(f3:getAvailAABB(), blueish, " F3_A")
    end
    if love.keyboard.isDown("i") then
        drawAABB(f0:getAABB(), redish, " F0_I")
        drawAABB(f1:getAABB(), redish, " F1_I")
        drawAABB(f2:getAABB(), redish, " F2_I")
        drawAABB(f3:getAABB(), redish, " F3_I")
    end
    if love.keyboard.isDown("r") then
        drawAABB(f0:getRealAABB(), greenish, " F0_R")
        drawAABB(f1:getRealAABB(), greenish, " F1_R")
        drawAABB(f2:getRealAABB(), greenish, " F2_R")
        drawAABB(f3:getRealAABB(), greenish, " F3_R")
    end
    if love.keyboard.isDown("c") then
        if love.keyboard.isDown("0") then
            f0:setCursor(0, 0)
            drawCursor(f0:getRawCursor(), " F0_cursor")
            f0:setRawCursor(f0:getAvailAABB()[1])
            drawCursor(f0:getRawCursor(), " F0_avail_cursor")
        end
        if love.keyboard.isDown("1") then
            f1:setCursor(0, 0)
            drawCursor(f1:getRawCursor(), " F1_cursor")
            f1:setRawCursor(f1:getAvailAABB()[1])
            drawCursor(f1:getRawCursor(), " F1_avail_cursor")
        end
        if love.keyboard.isDown("2") then
            f2:setCursor(0, 0)
            drawCursor(f2:getRawCursor(), " F2_cursor")
            f2:setRawCursor(f2:getAvailAABB()[1])
            drawCursor(f2:getRawCursor(), " F2_avail_cursor")
        end
        ---[[
        if love.keyboard.isDown("3") then
            f3:setCursor(0, 0)
            drawCursor(f3:getRawCursor(), " F3_cursor")
            f3:setRawCursor(f3:getAvailAABB()[1])
            drawCursor(f3:getRawCursor(), " F3_avail_cursor")
        end
    --]]
    end
end

return UIDebugState

--[[ TODO: fixup state manager for errors
    if type(stateName) ~= 'string' then error("StateManager: passed argument is not a string.") end
    if not state then error("StateManager: no state '"..stateName.."' loaded.") end
]]
