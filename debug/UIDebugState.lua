local UIDebugState = {name = "UIDebugState"}

local UI = require "UI/UI"
local UIWidget = require "UI/UIWidget"
local Color = require "UI/Color"
local AABB = require "UI/AABB"

local stateDesc
local w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
local margin = 30
local GUI = UI(margin, margin, w_width - 2 * margin, w_height - 2 * margin)
local f0 = UIWidget({size = {x = "50%", y = "50%"}, margin = {all = 30}})
local f1 = UIWidget({size = {x = "80%", y = "80%"}, margin = {all = 30}})
local f2 = UIWidget({allign = {x = "left", y = "up"}, size = {x = "50%", y = "80%"}, margin = {all = 30}})
local f3 = UIWidget({allign = {x = "right", y = "down"}, z = -1, size = {x = "50%", y = "80%"}})
local f4 = UIWidget({size = {x = "80%", y = "80%"}}, {passThru = true, allowOverflow = true})
local f5 = UIWidget({origin = {x = "20%", y = "0%"}, size = {x = "50%", y = "50%"}})

GUI:setWidget(f0)
f0:addWidget(f1)
f1:addWidget(f2)
f1:addWidget(f3)
f3:addWidget(f4)
f4:addWidget(f5)

local blueish = Color("#5050ffa0")
local redish = Color("#ff5050a0")
local greenish = Color("#2bff1ba0")
local whiteish = Color("#ffffffa0")
local white = Color("#ffffff")
local red = Color("#ff1b2b")
local click = {start = nil, stop = nil}
local font = nil

local widgetRenderer = function(self)
    self:setCursor(0, 0)
    local original = {love.graphics.getColor()}
    if self:isFocused() then
        love.graphics.setColor(self.style.theme.fg_focus:normalized())
    elseif self:isHovered() then
        love.graphics.setColor(self.style.theme.fg:normalized())
    else
        love.graphics.setColor(self.style.theme.bg:normalized())
    end
    love.graphics.rectangle("fill", self:getAABB():normalized())
    love.graphics.setColor(red:normalized())
    love.graphics.rectangle("line", self:getAABB():normalized())
    love.graphics.setColor(white:normalized())
    love.graphics.print(self._ID, self._AABB[1].x, self._AABB[1].y)
    if self.info then
        local cx, cy = self:getRawCursor()
        love.graphics.print(self.info, cx + 14, cy)
    end

    love.graphics.setColor(original[1], original[2], original[3], original[4])
end

f0.renderer, f0.info = widgetRenderer, "main widget"
f1.renderer, f1.info = widgetRenderer, "double container"
f2.renderer, f2.info = widgetRenderer, "left\nblink"
f3.renderer, f3.info = widgetRenderer, "right"
f4.renderer, f4.info = widgetRenderer, "pass\nover"
f5.renderer, f5.info = widgetRenderer, "shifted\nmov"

local oldHandlers = {mc, mr, wm, kp, kr, ti, fd, dd}
local function _EVTme(self)
    print("EVT: me", self._ID)
end
local function _EVTmx(self)
    print("EVT: mx", self._ID)
end
local function _EVTmc(self, x, y, button)
    print("EVT: mc", self._ID, x, y, button)
    self:requestFocus()
end
local function _EVTmr(self, x, y, button)
    print("EVT: mr", self._ID, x, y, button)
end
local function _EVTwm(self, x, y)
    print("EVT: wm", self._ID, x, y)
end
local function _EVTkp(self, key, scancode, isRepeat)
    print("EVT: kp", self._ID, key, scancode, isRepeat)
end
local function _EVTkr(self, key, scancode)
    print("EVT: kr", self._ID, key, scancode)
end
local function _EVTti(self, text)
    print("EVT: ti", self._ID, text)
end
local function _EVTfd(self, file)
    print("EVT: fd", self._ID, file)
end
local function _EVTdd(self, path)
    print("EVT: dd", self._ID, path)
end

for _, v in ipairs({f0, f1, f2, f3, f4, f5}) do
    v.mouseEntered = _EVTme
    v.mouseExited = _EVTmx
    v.mouseClicked = _EVTmc
    v.mouseReleased = _EVTmr
    v.wheelMoved = _EVTwm
    v.keyPressed = _EVTkp
    v.keyReleased = _EVTkr
    v.textInput = _EVTti
    v.fileDropped = _EVTfd
    v.directoryDropped = _EVTdd
end

f2.updater = function(self, dt)
    self.cntr = self.cntr or 0
    self.cntr = self.cntr + 1
    if self:isHovered() and self.cntr > 50 then
        if self.style.allign.y == "up" then
            self.style.allign.y = "down"
        elseif self.style.allign.y == "down" then
            self.style.allign.y = "up"
        end
        self.cntr = 0
    end
end

f5.updater = function(self, dt)
    if self:isHovered() then
        if love.keyboard.isDown("left") then
            self.style.origin.x = self.style.origin.x - 1
        end 
        if love.keyboard.isDown("right") then
            self.style.origin.x = self.style.origin.x + 1
        end 
        if love.keyboard.isDown("up") then
            self.style.origin.y = self.style.origin.y - 1
        end
        if love.keyboard.isDown("down") then
            self.style.origin.y = self.style.origin.y + 1
        end
    end
end

function UIDebugState.init()
    oldHandlers = {
        mp = love.mousepressed,
        mr = love.mousereleased,
        wm = love.wheelmoved,
        kp = love.keypressed,
        kr = love.keyreleased,
        ti = love.textinput,
        fd = love.filedropped,
        dd = love.directorydropped
    }
    local handlers = GUI:getEventHandlers()

    love.mousepressed = handlers.mousepressed
    love.mousereleased = handlers.mousereleased
    love.wheelmoved = handlers.wheelmoved
    love.keypressed = handlers.keypressed
    love.keyreleased = handlers.keyreleased
    love.textinput = handlers.textinput
    love.filedropped = handlers.filedropped
    love.directorydropped = handlers.directorydropped

    ResourceManager.load("font.monospace24", "Inconsolata-Regular", "ttf", "resources/fonts", "font", 24)
    font = ResourceManager.get("font.monospace24")
    stateDesc = stateDesc or love.graphics.newText(font, "UI_DEBUG_STATE")
    click.start, click.stop = nil, nil
    w_width, w_height = love.graphics.getWidth(), love.graphics.getHeight()
end

function UIDebugState.clear()
    click.start, click.stop = nil, nil
    love.mousepressed = oldHandlers.mp
    love.mousereleased = oldHandlers.mr
    love.wheelmoved = oldHandlers.wm
    love.keypressed = oldHandlers.kp
    love.keyreleased = oldHandlers.kr
    love.textinput = oldHandlers.ti
    love.filedropped = oldHandlers.fd
    love.directorydropped = oldHandlers.dd
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
    love.graphics.newText(ResourceManager.get("fonts.Montserrat-Regular"), "UI_DEBUG_STATE")
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
    local mousePosText = love.graphics.newText(font, string.format("Mouse:\t(%d\t,%d)", love.mouse.getPosition()))
    love.graphics.draw(mousePosText, w_width - mousePosText:getWidth(), w_height - mousePosText:getHeight())
    love.graphics.rectangle("fill", w_width - margin, 0, margin, margin)
    love.graphics.rectangle("line", GUI.origin.x, GUI.origin.y, GUI.size.x, GUI.size.y)
    love.graphics.setColor(white:normalized())
    love.graphics.print("EXIT", w_width - margin)
    local _  -- trash variable
    if love.keyboard.isDown("a") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getAvailAABB(), blueish, " F0_A")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getAvailAABB(), blueish, " F1_A")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getAvailAABB(), blueish, " F2_A")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getAvailAABB(), blueish, " F3_A")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getAvailAABB(), blueish, " F4_A")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getAvailAABB(), blueish, " F5_A")
    end
    if love.keyboard.isDown("i") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getAABB(), redish, " F0_I")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getAABB(), redish, " F1_I")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getAABB(), redish, " F2_I")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getAABB(), redish, " F3_I")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getAABB(), redish, " F4_I")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getAABB(), redish, " F5_I")
    end
    if love.keyboard.isDown("v") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getVisibleAABB(), greenish, " F0_V")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getVisibleAABB(), greenish, " F1_V")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getVisibleAABB(), greenish, " F2_V")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getVisibleAABB(), greenish, " F3_V")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getVisibleAABB(), greenish, " F4_V")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getVisibleAABB(), greenish, " F5_V")
    end
    if love.keyboard.isDown("w") then
        _ = love.keyboard.isDown("0") and drawAABB(f0:getVisibleAvailAABB(), whiteish, " F0_AV")
        _ = love.keyboard.isDown("1") and drawAABB(f1:getVisibleAvailAABB(), whiteish, " F1_AV")
        _ = love.keyboard.isDown("2") and drawAABB(f2:getVisibleAvailAABB(), whiteish, " F2_AV")
        _ = love.keyboard.isDown("3") and drawAABB(f3:getVisibleAvailAABB(), whiteish, " F3_AV")
        _ = love.keyboard.isDown("4") and drawAABB(f4:getVisibleAvailAABB(), whiteish, " F4_AV")
        _ = love.keyboard.isDown("5") and drawAABB(f5:getVisibleAvailAABB(), whiteish, " F5_AV")
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
        if love.keyboard.isDown("4") then
            f4:setCursor(0, 0)
            drawCursor(f4:getRawCursor(), " F4_cursor")
            f4:setRawCursor(f4:getAvailAABB()[1])
            drawCursor(f4:getRawCursor(), " F4_avail_cursor")
        end
        if love.keyboard.isDown("5") then
            f5:setCursor(0, 0)
            drawCursor(f5:getRawCursor(), " F5_cursor")
            f5:setRawCursor(f5:getAvailAABB()[1])
            drawCursor(f5:getRawCursor(), " F5_avail_cursor")
        end
    --]]
    end
end

return UIDebugState

--[[ TODO: fixup state manager for errors
    if type(stateName) ~= 'string' then error("StateManager: passed argument is not a string.") end
    if not state then error("StateManager: no state '"..stateName.."' loaded.") end
]]
