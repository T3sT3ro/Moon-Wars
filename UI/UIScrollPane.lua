local UIScrollPane = {}
-- MMB drag or wheel move to scroll
-- while wholding MMB - numpad0 to reset scroll
package.loaded[...] = UIScrollPane

local UIWidget = require "UI/UIWidget"
local UIFrame = require "UI/UIFrame"
local Color = require "UI/Color"
local Typeassert = require "utils/Typeassert"
local min, max, floor = math.min, math.max, math.floor

UIScrollPane.__index = UIScrollPane

function UIScrollPane.isScrollPane(o)
    return UIWidget.isA(o, UIScrollPane)
end

-- default:
---- UIWidget.style.*
---- UIWidget.flags.*
---- style.margin ~ ignored, can be simulated with 1 buffer frame inside scroll. Do not explicitly set margins.
---- style.invisible ~ ignored
-- extra:
---- style.virtualSize = {x='100%', y='100%'} ~ weird things happen when set to less than parent's size
---- style.scrollSpeed = 30 (amount of pixels scrolled by mouse wheel move of 1)
---- flags.scroll = {x=false, y=true}
---- flags.scrollInfinite = false (true for scroll only to the edge of virtual space)
---- flags.scrollWithDrag = true
local valPred = function(x)
    return x == nil or type(x) == "number" or type(x) == "string" and string.match(x, "^%-?[0-9]+%%$") == x
end
function UIScrollPane.new(style, flags)
    Typeassert(
        style,
        {"ANY", "nil", {scrollSpeed = "nil|number", virtualSize = {"ANY", "nil", {x = valPred, y = valPred}}}}
    )
    Typeassert(
        flags,
        {
            "ANY",
            "nil",
            {
                scroll = {"ANY", "nil", {x = "nil|boolean", y = "nil|boolean"}},
                scrollWithDrag = "nil|boolean",
                scrollInfinite = "nil|boolean"
            }
        }
    )
    style, flags = style or {}, flags or {}
    style.margin = nil
    style.invisible = true

    local self = UIWidget(style, flags)

    style.virtualSize = style.virtualSize or {}
    style.virtualSize.x = style.virtualSize.x or "100%"
    style.virtualSize.y = style.virtualSize.y or "100%"
    style.scrollSpeed = style.scrollSpeed or 30
    flags.scroll = flags.scroll or {}
    flags.scroll.x = flags.scroll.x or (flags.scroll.x == nil and false)
    flags.scroll.y = flags.scroll.y or (flags.scroll.y == nil and true)
    flags.scrollWithDrag = flags.scrollWithDrag or (flags.scrollWidthDrag == nil and true)
    flags.scrollInfinite = flags.scrollInfinite or (flags.scrollInfinite == nil and false)
    local wf = UIFrame({z = 0, allign = {x = "left", y = "up"}, size = style.virtualSize})
    self._widgetFrame = wf
    self.style.scrollSpeed = style.scrollSpeed
    self.flags.scroll = flags.scroll
    self.flags.scrollWithDrag = flags.scrollWithDrag
    self.flags.scrollInfinite = flags.scrollInfinite

    self:addWidget(wf) -- using UIWidget:addWidget before setmetatable to use old version of addWidget
    wf.wheelMoved = function(self, ...)
        return self._parent:wheelMoved(...)
    end
    wf.style.ID = (self.style.ID or "#_scroll") .. "#" .. wf.style.ID
    self.style.virtualSize =
        setmetatable(
        {},
        {
            __index = function(t, k)
                return self._widgetFrame.style.size[k]
            end,
            __newindex = function(t, k, v)
                self._widgetFrame.style.size[k] = v
            end
        }
    )
    setmetatable(self, UIScrollPane)
    return self
end

-- proxy to widgetFrame
function UIScrollPane:addWidget(widget)
    return self._widgetFrame:addWidget(widget)
end

-- proxy to widgetFrame
function UIScrollPane:removeWidget(widget)
    return self._widgetFrame:removeWidget(widget)
end

-- @override
function UIScrollPane:mousePressed(x, y, button)
    if button == 3 and self:requestFocus() and self.flags.scrollWithDrag then
        self.clickBegin = {x = x, y = y}
        love.mouse.setRelativeMode(true)
    end
    if button ~= 3 then
        return true
    end
end

-- @override
function UIScrollPane:mouseReleased(x, y, button)
    if button == 3 and self:isDragged() then
        love.mouse.setPosition(self.clickBegin.x, self.clickBegin.y)
        self.clickBegin = nil
        love.mouse.setRelativeMode(false)
        self:dropFocus()
    else
        return true
    end
end

function UIScrollPane:scroll(dx, dy) -- x +> y +^
    dx = self.flags.scroll.x and dx or 0
    dy = self.flags.scroll.y and dy or 0
    local cs = self._widgetFrame.style
    if self.flags.scrollInfinite then
        cs.origin.x = cs.origin.x + dx
        cs.origin.y = cs.origin.y - dy
    else
        cs.origin.x = max(min(0, cs.origin.x + dx), -(self._widgetFrame:getWidth() - self:getWidth()))
        cs.origin.y = max(min(0, cs.origin.y - dy), -(self._widgetFrame:getHeight() - self:getHeight()))
    end
end

-- @override
-- shift swaps axes
function UIScrollPane:wheelMoved(x, y)
    local multiplier = (not love.keyboard.isDown("lalt") and self.style.scrollSpeed) or 1
    if love.keyboard.isDown("lshift") then
        self:scroll(y * multiplier, x * multiplier)
    else
        self:scroll(x * multiplier, -y * multiplier)
    end
end

function UIScrollPane:mouseMoved(x, y, dx, dy)
    self:scroll(dx, -dy)
end
-- @override highest priority on drag
function UIScrollPane:requestDropFocus()
    return false
end

function UIScrollPane:keyPressed(key)
    if key == "kp0" and self:isDragged() then
        self._widgetFrame.style.origin.x, self._widgetFrame.style.origin.y = 0, 0
    end
end

function UIScrollPane:renderer()
    love.graphics.setColor(self.style.theme.body:normalized())
    love.graphics.rectangle("fill", self:getAABB():normalized())
end

-- true iff mouse is held and it started over ScrollPane and drag scroll enabled
function UIScrollPane:isDragged()
    return self._UI:getClickBegin(3) == self and self.flags.scrollWithDrag
end

return setmetatable(
    UIScrollPane,
    {
        __index = UIWidget,
        __call = function(_, ...)
            local ok, ret = pcall(UIScrollPane.new, ...)
            if ok then
                return ret
            else
                error("UIScrollPane: " .. ret)
            end
        end
    }
)
