local UI = {UUIDseed = -1}
package.loaded[...] = UI

local min, max = math.min, math.max

Typeassert = require "utils/Typeassert"
AABB = require "UI/AABB"
Color = require "UI/Color"

UI.__index = UI

UI.theme = {
    Color("#63002d"),
    Color("#8b003f"),
    Color("#c1404d"),
    Color("#ffa535"),
    Color("#ffcd32"),
    font = love.graphics.newFont(14)
}

function UI.isUI(o)
    return getmetatable(o) == UI
end

function UI.isID(ID)
    return type(ID) == "number"
end

function UI:nextID(...)
    UI.UUIDseed = UI.UUIDseed + 1
    return UI.UUIDseed
end

function UI.new(x, y, width, height)
    local naturalPred = function(x)
        return type(x) == "number" and x >= 0
    end
    Typeassert({x, y, width, height}, {naturalPred, naturalPred, naturalPred, naturalPred})

    local self =
        setmetatable(
        {
            _ID = UI.nextID(),
            __index = UI,
            widget = nil,
            origin = {x = x, y = y}, -- on screen real dimensions
            size = {x = width, y = height}, --- ^^^
            cursor = {x = x, y = y} -- relative to window's top-left corner, used for drawing UI elements
        },
        UI
    )
    return self
end

function UI:setWidget(widget)
    self.widget = widget
    widget._parent:removeWidget(widget)
    widget._parent = widget
    widget._UI = self
    self:reload()
end

function UI:update(dt, ...)
    self.widget:update(dt, ...)
end

function UI:draw(...)
    local old = {love.graphics.getScissor()}
    love.graphics.setScissor(self.origin.x, self.origin.y, self.size.x, self.size.y)
    local oldSetScissorFun = love.graphics.setScissor

    -- proxy function to always draw inside UI
    love.graphics.setScissor = function(x, y, w, h)
        oldSetScissorFun(self.origin.x, self.origin.y, self.size.x, self.size.y)
        x = x and y and w and h and love.graphics.intersectScissor(x, y, w, h)
    end

    self.widget:draw(...)
    love.graphics.setScissor = oldSetScissorFun
    love.graphics.setScissor(old[1], old[2], old[3], old[4])
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
function UI:width()
    return self.size.x
end
function UI:height()
    return self.size.y
end

-- returns mouse relative to UI
function UI:getRelativeMouse()
    local mx, my = love.mouse.getX(), love.mouse.getY()
    mx = min(max(self.origin.x, mx), self.origin.x + self.width) - self.origin.x
    my = min(max(self.origin.y, my), self.origin.y + self.height) - self.origin.y
    return mx, my
end

function UI:reload()
    self.cursor.x, self.cursor.y = self.origin.x, self.origin.y
    self:resize(self.origin.x, self.origin.y, self.size.x, self.size.y) -- resize with the same values triggers widget update
    self.widget:reload()
end

function UI:resize(x, y, width, height)
    if type(x) ~= "number" or type(y) ~= "number" or type(width) ~= "number" or type(height) ~= "number" then
        error("UI: invalid values to 'resize()'")
    end
    self.origin.x, self.origin.y = x, y
    self.size.x, self.size.y = max(0, width), max(0, height)
    self.widget._availAABB:set(self.origin.x, self.origin.y, self.origin.x + self.size.x, self.origin.y + self.size.y)
    local _ = (self.widget and self.widget:reloadLayout(true))
end

function UI.getPercent(val)
    return type(val) == "string" and string.match(val, "^(%-?[0-9]+)%%$")
end

function UI:getRawCursor()
    return {x = self.cursor.x, y = self.cursor.y}
end

function UI:setRawCursor(x, y)
    if type(x) == "table" then
        x, y = x.x, x.y
    end
    self.cursor.x, self.cursor.y = x, y
end

-- returns widget at absolute x, y or nil if none. compares realAABB, so for 0 sized it is null
function UI:getWidgetAt(x, y)
    return self.widget and self.widget:getWidgetAt(x, y)
end

-- returns widget by ID with UIWidget tree traversal
function UI:getWidget(ID)
    return self.widget and UI.widget:getWidgetByID(ID)
end
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
