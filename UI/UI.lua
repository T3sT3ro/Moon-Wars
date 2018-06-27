local UI = {UUIDseed = -1}
package.loaded[...] = UI

local min, max = math.min, math.max

local Typeassert = require "utils/Typeassert"
local AABB = require "UI/AABB"
local Color = require "UI/Color"

UI.__index = UI

UI.theme = {
    bg = Color("#63002dbb"),
    fg = Color("#8b003fbb"),
    fg_focus = Color("#c1404dbb"),
    hilit = Color("#ffa535bb"),
    hilit_focus = Color("#ffcd32bb"),
    contrast = Color("#a8f9ff"),
    font = love.graphics.newFont(14)
}

function UI.isUI(o)
    return getmetatable(o) == UI
end

function UI.isID(ID)
    return type(ID) == "number" or type(ID) == "string"
end

function UI:nextID(...)
    UI.UUIDseed = UI.UUIDseed + 1
    return "ui#" .. UI.UUIDseed
end

-- fields:
--- ID, _index, _widget, _hoveredWidget, _focusedWidget, _clickBegin, _clickEnd
---  origin, size
function UI.new(x, y, width, height)
    local naturalPred = function(x)
        return type(x) == "number" and x >= 0
    end
    Typeassert({x, y, width, height}, {naturalPred, naturalPred, naturalPred, naturalPred})

    local self =
        setmetatable(
        {
            ID = UI.nextID(),
            __index = UI,
            _widget = nil,
            _hoveredWidget = nil,
            _focusedWidget = nil,
            _clickBegin = {{}, {}, {}},
            _clickEnd = {{}, {}, {}},
            origin = {x = x, y = y}, -- on screen real dimensions
            size = {x = width, y = height} --- ^^^
        },
        UI
    )
    return self
end

function UI:setWidget(widget)
    self._widget = widget
    widget._parent:removeWidget(widget)
    widget._parent = widget
    widget._UI = self
    self:reload()
end

function UI:update(dt, ...)
    local hovered = self._widget:getHovered()
    if hovered ~= self._hoveredWidget then -- won't trigger while same widget is hovered or no widget is hovered
        if self._hoveredWidget and not self._hoveredWidget.flags.passThru then
            self._hoveredWidget:emitEvent("mouseExited")
        end
        if hovered and not hovered.flags.passThru then
            hovered:emitEvent("mouseEntered")
        end
    end
    self._hoveredWidget = hovered
    self._widget:update(dt, ...)
end

function UI:draw(...)
    love.graphics.push("all")
    love.graphics.setScissor(self.origin.x, self.origin.y, self.size.x, self.size.y)
    local oldSetScissorFun = love.graphics.setScissor

    -- proxy function to always draw inside UI
    love.graphics.setScissor = function(x, y, w, h)
        oldSetScissorFun(self.origin.x, self.origin.y, self.size.x, self.size.y)
        return x and y and w and h and love.graphics.intersectScissor(x, y, w, h)
    end
    love.graphics.translate(self.origin.x, self.origin.y)
    self._widget:draw(...)
    love.graphics.setScissor = oldSetScissorFun
    love.graphics.pop()
end

function UI:reload()
    self:resize(self.origin.x, self.origin.y, self.size.x, self.size.y) -- resize with the same values triggers widget update
    self._hoveredWidget = nil
    self._focusedWidget = nil
    self._clickBegin[1], self._clickBegin[2], self._clickBegin[3] = nil, nil, nil
    self._clickEnd[1], self._clickEnd[2], self._clickEnd[3] = nil, nil, nil
    self._widget:reload()
end

function UI:resize(x, y, width, height)
    if type(x) ~= "number" or type(y) ~= "number" or type(width) ~= "number" or type(height) ~= "number" then
        error("UI: invalid values to 'resize()'")
    end
    self.origin.x, self.origin.y = x, y
    self.size.x, self.size.y = max(0, width), max(0, height)
    if self._widget then
        self._widget:setAvailAABB(
            self.origin.x,
            self.origin.y,
            self.origin.x + self.size.x,
            self.origin.y + self.size.y
        )
        self._widget:setVisibleAvailAABB(self._widget._availAABB)
        self._widget:reloadLayout()
    end
end

-- true if gained focus, false otherwise
function UI:requestFocus(widget)
    if self._focusedWidget == nil or self._focusedWidget == widget then
        self._focusedWidget = widget
        return true
    else
        if self._focusedWidget:requestDropFocus() then
            self._focusedWidget = widget
            return true
        else
            return false
        end
    end
end

function UI:getAABB()
    return AABB(self.origin.x, self.origin.y, self.origin.x + self.size.x, self.origin.y + self.size.y)
end

function UI:X()
    return self.origin.x
end

function UI:Y()
    return self.origin.y
end

function UI:getWidth()
    return self.size.x
end

function UI:getHeight()
    return self.size.y
end

-- returns widget over which the mouse was pressed
function UI:getClickBegin(button)
    return self._clickBegin[button] and self._clickBegin[button].widget
end

-- returns widget over which the mouse was released. Available in mouseReleased events
function UI:getClickEnd(button)
    return self._clickEnd[button] and self._clickEnd[button].widget
end

-- transforms screen coordinates to local coordinates
function UI:toLocalCoordinates(x, y)
    return x - self.origin.x, y - self.origin.y
end

-- transforms local coordinates to screen coordinates
function UI:toGlobalCoordinates(x, y)
    return x + self.origin.x, y + self.origin.y
end

-- returns widget at absolute x, y or nil if none. compares realAABB, so for 0 sized it is null
function UI:getWidgetAt(x, y, solid)
    return self._widget and self._widget:getWidgetAt(x, y, solid)
end

-- returns widget by ID with UIWidget tree traversal
function UI:getWidget(ID)
    return self._widget and UI._widget:getWidgetByID(ID)
end

function UI:getHovered()
    return self._hoveredWidget
end

--============EVENTS============--

local function mousePressedEvt(ui, x, y, button)
    local widget = ui:getWidgetAt(x, y, true)
    if widget then
        if widget ~= ui._focusedWidget then
            if ui._focusedWidget then
                ui._focusedWidget:requestDropFocus()
            end
        end
        widget:emitEvent("mousePressed", x, y, button)
    elseif ui._focusedWidget then -- outside of any widget
        ui._focusedWidget:dropFocus()
    end
    ui._clickBegin[button] = {widget = widget, x = x, y = y}
end

-- if any widget is focused, then release is send back to focused, otherwise to visible element
local function mouseReleasedEvt(ui, x, y, button)
    local targetWidget = ui:getWidgetAt(x, y, true) -- target is a solid widget
    ui._clickEnd[button] = {widget = targetWidget, x = x, y = y}
    if ui._focusedWidget then
        ui._focusedWidget:emitEvent("mouseReleased", x, y, button)
    elseif targetWidget then
        targetWidget:emitEvent("mouseReleased", x, y, button)
    end
    ui._clickEnd[button] = nil
    ui._clickBegin[button] = nil
end

local function wheelMovedEvt(ui, x, y)
    if ui._hoveredWidget then
        ui._hoveredWidget:emitEvent("wheelMoved", x, y)
    end
end

-- sent on mouse move to the focused widget only
local function mouseMovedEvt(ui, x, y, dx, dy)
    if ui._focusedWidget then
        ui._focusedWidget:emitEvent("mouseMoved", x, y, dx, dy)
    end
end

-- can override, currently captures are active for focused element
function UI:keyPressedEvt(key, scancode, isrepeat)
    if self._focusedWidget then
        self._focusedWidget:emitEvent("keyPressed", key, scancode, isrepeat)
    end
end

-- can override, currently captures are active for focused element
function UI:keyReleasedEvt(key, scancode)
    if self._focusedWidget then
        self._focusedWidget:emitEvent("keyReleased", key, scancode)
    end
end

-- captures only for focused widget
local function textInputEvt(ui, text)
    if ui._focusedWidget then
        ui._focusedWidget:emitEvent("textInput", text)
    end
end

-- prioritize the focused widget, otherwise hovered
local function fileDirDroppedEvt(ui, file, isDir)
    local mx, my = love.mouse.getPosition()
    local targetWidget = ui:getWidgetAt(mx, my, true)
    if isDir then
        if ui._focusedWidget then
            ui._focusedWidget:emitEvent("directoryDropped", file)
        elseif targetWidget then
            targetWidget:emitEvent("directoryDropped", file)
        end
    else
        if ui._focusedWidget then
            ui._focusedWidget:emitEvent("fileDropped", file)
        elseif targetWidget then
            targetWidget:emitEvent("fileDropped", file)
        end
    end
end

--------
function UI:getEventHandlers()
    local events = {}
    ----
    events.mousepressed = function(x, y, button)
        mousePressedEvt(self, x, y, button)
    end
    events.mousereleased = function(x, y, button)
        mouseReleasedEvt(self, x, y, button)
    end
    events.wheelmoved = function(x, y)
        wheelMovedEvt(self, x, y)
    end
    events.mousemoved = function(x, y, dx, dy)
        mouseMovedEvt(self, x, y, dx, dy)
    end
    events.keypressed = function(key, scancode, isrepeat)
        self:keyPressedEvt(key, scancode, isrepeat)
    end
    events.keyreleased = function(key, scancode)
        self:keyReleasedEvt(key, scancode)
    end
    events.textinput = function(text)
        textInputEvt(self, text)
    end
    events.filedropped = function(file)
        fileDirDroppedEvt(self, file, false)
    end
    events.directorydropped = function(file)
        fileDirDroppedEvt(self, file, true)
    end
    ----
    return events
end
--==============================--

-------------------------------------------------------------------------------------
return setmetatable(
    UI,
    {
        __call = function(_, ...)
            local ok, ret = pcall(UI.new, ...)
            if ok then
                return ret
            else
                error("UI: " .. ret)
            end
        end
    }
)
