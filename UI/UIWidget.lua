local UIWidget = {UUIDseed = -1}
package.loaded[...] = UIWidget

local UI = require "UI/UI"
local Typeassert = require "utils/Typeassert"
local Color = require "UI/Color"
local AABB = require "UI/AABB"

local floor = math.floor

UIWidget.__index = UIWidget

--- absolute values are pixels
--- % values are relative to available space + widgets's layout policy

function UIWidget.isA(o, class)
    -- for object get metatable, for class it's superclass by __index
    local mt = getmetatable(o)
    while mt ~= class do
        if mt == nil then
            return false
        end
        mt = getmetatable(mt) or (mt.__index ~= mt and mt.__index)
    end
    return true
end

function UIWidget.isUIWidget(o)
    return UIWidget.isA(o, UIWidget)
end

function UIWidget.isID(ID)
    return type(ID) == "number" or type(ID) == "string"
end

function UIWidget:nextID(...)
    UIWidget.UUIDseed = UIWidget.UUIDseed + 1
    return "wg#" .. UIWidget.UUIDseed
end

-- style:
---- z-index
---- allign = {x=[center|left|right], y=[center|up|down]}
---- origin = {x, y} (according to position where it would normally be taking allign into account)
---- size = {x, y}
---- margin = [ {all} | {x, y} | {left, right, up, down} ]
---- theme = {bg, fg, fg_focus, hilit, hilit_focus}
---- invisible = false
-- flags:
---- keepFocus
---- passThru
---- allowOverflow
---- hidden
---- draggable
function UIWidget.new(style, flags)
    local valPred = function(x)
        return x == nil or type(x) == "number" or type(x) == "string" and string.match(x, "^%-?[0-9]+%%$") == x
    end
    Typeassert(
        style,
        {
            "ANY",
            "nil",
            {
                ID = "number|string|nil",
                z = "number|nil",
                allign = {
                    "ANY",
                    "nil",
                    {
                        x = {"ANY", "nil", "R:center", "R:left", "R:right"},
                        y = {"ANY", "nil", "R:center", "R:up", "R:down"}
                    }
                },
                origin = {"ANY", "nil", {x = valPred, y = valPred}},
                size = {"ANY", "nil", {x = valPred, y = valPred}},
                margin = {
                    "ANY",
                    "nil",
                    {left = valPred, right = valPred, up = valPred, down = valPred},
                    {x = valPred, y = valPred},
                    {all = valPred}
                },
                theme = {
                    "ANY",
                    "nil",
                    {
                        bg = {"ANY", "nil", Color.isColor},
                        fg = {"ANY", "nil", Color.isColor},
                        fg_focus = {"ANY", "nil", Color.isColor},
                        hilit = {"ANY", "nil", Color.isColor},
                        hilit_focus = {"ANY", "nil", Color.isColor},
                        font = "nil|userdata"
                    }
                },
                invisible = "nil|boolean"
            }
        }
    )
    Typeassert(
        flags,
        {
            "ANY",
            "nil",
            {
                keepFocus = "nil|boolean",
                passThru = "nil|boolean",
                allowOverflow = "nil|boolean",
                hidden = "nil|boolean",
                draggable = "nil|boolean"
            }
        }
    )

    --- DEFAULT STYLE
    style = style or {allign = {}, origin = {}, size = {}, margin = {}, theme = {}}
    style.ID = style.ID or UIWidget.nextID()
    style.z = style.z or 0
    style.allign = style.allign or {}
    style.allign.x = style.allign.x or "center"
    style.allign.y = style.allign.y or "center"
    style.origin = style.origin or {}
    style.origin.x = style.origin.x or 0
    style.origin.y = style.origin.y or 0
    style.size = style.size or {}
    style.size.x = style.size.x or "100%"
    style.size.y = style.size.y or "100%"
    style.margin = style.margin or {}
    style.margin.left = style.margin.left or 0
    style.margin.right = style.margin.right or 0
    style.margin.up = style.margin.up or 0
    style.margin.down = style.margin.down or 0
    style.theme = style.theme or {}
    style.invisible = style.invisible or false -- doesn't render self but renders children

    --- DEFAULT FLAGS
    flags = flags or {}
    flags.keepFocus = flags.keepFocus or false -- will keep focus until dropFocus() is not
    flags.passThru = flags.passThru or false -- true for element to not register click
    flags.allowOverflow = flags.allowOverflow or false -- TODO: allowOverflow by IDs
    flags.hidden = flags.hidden or false -- FIXME: test
    flags.draggable = flags.draggable or false -- TODO: dragged by margin and all pass-thru inner elements

    --- OBJECT CONSTRUCTION BEGIN
    local self = setmetatable({style = {}, flags = {}}, UIWidget)
    -----------------
    self.style.allign =
        setmetatable(
        {},
        {
            _x,
            _y,
            __index = function(t, k)
                t = getmetatable(t)
                return (k == "x" and t._x) or (k == "y" and t._y)
            end,
            __newindex = function(t, k, v)
                t = getmetatable(t)
                if k == "x" then
                    local oldX = t._x
                    t._x = (v == "left" or v == "center" or v == "right") and v
                    self._layoutModified = self._layoutModified or (oldX ~= v)
                elseif k == "y" then
                    local oldY = t._y
                    t._y = (v == "up" or v == "center" or v == "down") and v
                    self._layoutModified = self._layoutModified or (oldY ~= v)
                end
            end
        }
    )
    -----------------
    self.style.origin =
        setmetatable(
        {},
        {
            -- no direct access to
            _x, -- exact
            _y,
            _xP, -- percentages -
            _yP,
            __index = function(t, k)
                t = getmetatable(t)
                return (k == "x" and t._x) or (k == "y" and t._y) or (k == "value" and t._value) -- returns value in pixels
            end,
            __newindex = function(t, k, val)
                t = getmetatable(t)
                local valP = UIWidget.getPercent(val)

                if k == "x" then
                    self._layoutModified = self._layoutModified or (valP ~= t._xP) or (val ~= t._x)
                    t._xP, t._x = (valP and val), ((valP and floor(self._availAABB:getWidth() * (valP / 100))) or val)
                elseif k == "y" then
                    self._layoutModified = self._layoutModified or (valP ~= t._yP) or (val ~= t._y)
                    t._yP, t._y = (valP and val), ((valP and floor(self._availAABB:getHeight() * (valP / 100))) or val)
                end
            end,
            _value = function(self, k) -- returns stored value
                self = getmetatable(self)
                return (k == "x" and (self._xP or self._x)) or (k == "y" and (self._yP or self._y))
            end
        }
    )
    ---------------
    self.style.size =
        setmetatable(
        {},
        {
            _x, -- exact
            _y,
            _xP, -- percentages
            _yP,
            __index = getmetatable(self.style.origin).__index, -- same
            __newindex = getmetatable(self.style.origin).__newindex, -- same
            _value = getmetatable(self.style.origin)._value
        }
    )
    -----------------
    self.style.margin =
        setmetatable(
        {},
        {
            _l, -- exact
            _r,
            _u,
            _dr,
            _lP, -- percentages
            _rP,
            _uR,
            _dP,
            __index = function(T, k)
                local t = getmetatable(T)
                return (k == "left" and t._l) or (k == "right" and t._r) or (k == "up" and t._u) or
                    (k == "down" and t._d) or
                    (k == "x" and (t._l + t._r)) or
                    (k == "y" and (t._u + t._d)) or
                    (k == "value" and t._value)
            end,
            __newindex = function(T, k, val)
                local t = getmetatable(T)
                local valP = UIWidget.getPercent(val)
                if k == "left" then
                    self._layoutModified = self._layoutModified or (valP ~= t._lP) or (val ~= t._l)
                    t._lP, t._l = (valP and val), ((valP and floor(self._AABB:getWidth() * (valP / 100))) or val)
                elseif k == "right" then
                    self._layoutModified = self._layoutModified or (valP ~= t._rP) or (val ~= t._r)
                    t._rP, t._r = (valP and val), ((valP and floor(self._AABB:getWidth() * (valP / 100))) or val)
                elseif k == "up" then
                    self._layoutModified = self._layoutModified or (valP ~= t._uP) or (val ~= t._u)
                    t._uP, t._u = (valP and val), ((valP and floor(self._AABB:getHeight() * (valP / 100))) or val)
                elseif k == "down" then
                    self._layoutModified = self._layoutModified or (valP ~= t._dP) or (val ~= t._d)
                    t._dP, t._d = (valP and val), ((valP and floor(self._AABB:getHeight() * (valP / 100))) or val)
                elseif k == "x" then -- use previous
                    T.left = val
                    T.right = val
                elseif k == "y" then -- use previous
                    T.up = val
                    T.down = val
                elseif k == "all" then -- use previous
                    T.x = val
                    T.y = val
                end
            end,
            __call = function(T, val) -- one number initialization with call as margin(15)
                T.left, T.right, T.up, T.down = val, val, val, val
            end,
            _value = function(self, k)
                self = getmetatable(self)
                return (k == "left" and (self._lP or self._l)) or (k == "right" and (self._rP or self._r)) or
                    (k == "up" and (self._uP or self._u)) or
                    (k == "down" and (self._dP or self._d))
            end
        }
    )
    ----------------
    self.style.theme =
        setmetatable(
        {},
        {
            __index = function(t, k) -- returns value from _
                local val = rawget(t, k)
                if val then
                    return val
                end
                local theme =
                    (self._parent and self._parent ~= self and self._parent.style.theme) or
                    (self._UI and self._UI.theme)
                if k == "font" then
                    return (k and self._UI and theme[k]) or love.graphics.newFont(12)
                else
                    return (k and self._UI and Color(theme[k])) or Color(0, 0, 0) -- default is black
                end
            end
        }
    )

    self.__index = UI
    self._UI = nil
    self._childrenByZ = {}
    self._parent = self -- stand-alone widgets shouldn't exist
    self._visibleAvailAABB = AABB(0, 0, 0, 0) -- AABB inside availAABB that will be actually displayed
    self._availAABB = AABB(0, 0, 0, 0) -- virtual space the widget draw onto
    self._AABB = AABB(0, 0, 0, 0) -- requested AABB according to availAABB [- parent.margins]
    self._layoutModified = true

    self.style.ID = style.ID
    self.style.z = style.z
    self.style.allign.x = style.allign.x
    self.style.allign.y = style.allign.y
    self.style.origin.x = style.origin.x
    self.style.origin.y = style.origin.y
    self.style.size.x = style.size.x
    self.style.size.y = style.size.y
    self.style.margin.left = style.margin.all or style.margin.x or style.margin.left
    self.style.margin.right = style.margin.all or style.margin.x or style.margin.right
    self.style.margin.up = style.margin.all or style.margin.y or style.margin.up
    self.style.margin.down = style.margin.all or style.margin.y or style.margin.down
    self.style.theme.bg = style.theme.bg
    self.style.theme.fg = style.theme.fg
    self.style.theme.fg_focus = style.theme.fg_focus
    self.style.theme.hilit_focus = style.theme.hilit_focus
    self.style.theme.hilit = style.theme.hilit
    self.style.theme.font = style.theme.font
    self.style.invisible = style.invisible

    self.flags.keepFocus = flags.keepFocus
    self.flags.passThru = flags.passThru
    self.flags.allowOverflow = flags.allowOverflow
    self.flags.hidden = flags.hidden
    self.flags.draggable = flags.draggable -- TODO:
    return self
end

-- to override
function UIWidget:updater(dt, ...)
end

function UIWidget:update(...) -- TODO: status passed during tree traversal (anyHovered flag)
    if not self.flags.hidden then -- don't waste resources for hidden objects
        self:updater(...)
        self:reloadLayout(self._layoutModified) -- handles size, origin, margin changes (later also drag and scroll?)
        for _, v in ipairs(self._childrenByZ) do
            v:update(...)
        end
    end
end

-- to override
function UIWidget:renderer(...)
end

-- guarantee: elements are setup properly
----- scissor is set to visible available space
function UIWidget:draw(...)
    if not self.flags.hidden then
        if not self.style.invisible then
            love.graphics.push("all")
            self:renderer(...)
            love.graphics.pop()
        end
        for _, v in ipairs(self._childrenByZ) do
            love.graphics.push("all")
            -- TODO: allow overflow flag implementation as set scissors to parent
            love.graphics.setScissor(v._visibleAvailAABB:cut(v._AABB):normalized())
            love.graphics.translate(v._AABB[1].x - self._AABB[1].x, v._AABB[1].y - self._AABB[1].y)
            v:draw(...)
            love.graphics.pop()
        end
    end
end

function UIWidget.getPercent(val)
    return type(val) == "string" and string.match(val, "^(%-?[0-9]+)%%$")
end

-- return hovered widget (may be self) or nil for none
function UIWidget:getHovered()
    if not self.flags.hidden and not love.mouse.getRelativeMode() then
        local hover = nil
        for i = #self._childrenByZ, 1, -1 do
            hover = hover or self._childrenByZ[i]:getHovered()
        end
        return hover or (self:mouseIn() and not self.flags.passThru and self)
    end
    return nil
end

-- CHANGE ONLY IF YOU KNOW WHAT YOU'RE DOING
function UIWidget:reloadLayoutSelf()
    -- assigning has sideeffect of recalculating exact sizes
    self.style.origin.x = self.style.origin:value("x")
    self.style.origin.y = self.style.origin:value("y")
    self.style.size.x = self.style.size:value("x")
    self.style.size.y = self.style.size:value("y")
    self.style.margin.left = self.style.margin:value("left")
    self.style.margin.right = self.style.margin:value("right")
    self.style.margin.up = self.style.margin:value("up")
    self.style.margin.down = self.style.margin:value("down")
    --FIXME: thorough testing

    -- self AABB relative to availAABB and allign
    local x1 = self._availAABB[1].x
    local y1 = self._availAABB[1].y
    local x2 = x1 + self.style.size.x
    local y2 = y1 + self.style.size.y
    if self.style.allign.x == "center" then
        local dx = floor((self._availAABB:getWidth() - self.style.size.x) / 2)
        x1, x2 = x1 + dx, x2 + dx
    elseif self.style.allign.x == "right" then
        local dx = self._availAABB:getWidth() - self.style.size.x
        x1, x2 = x1 + dx, x2 + dx
    end
    if self.style.allign.y == "center" then
        local dy = floor((self._availAABB:getHeight() - self.style.size.y) / 2)
        y1, y2 = y1 + dy, y2 + dy
    elseif self.style.allign.y == "down" then
        local dy = self._availAABB:getHeight() - self.style.size.y
        y1, y2 = y1 + dy, y2 + dy
    end
    self._AABB:set(
        x1 + self.style.origin.x,
        y1 + self.style.origin.y,
        x2 + self.style.origin.x,
        y2 + self.style.origin.y
    )
end

-- guarantee: availAABB and visibleAvailAABB set properly
function UIWidget:reloadLayout(doReload) -- doReload when any of ancestors was updated
    if not self.flags.hidden and doReload or self._layoutModified then -- resources save on hidden objects
        self:reloadLayoutSelf()
        -- z-index children sort
        table.sort(
            self._childrenByZ,
            function(w1, w2)
                return w1.style.z < w2.style.z
            end
        )
        -- availAABB, visibleAvailAABB and reloadLayout for children
        for _, v in ipairs(self._childrenByZ) do
            if (self.flags.allowOverflow) then
                v._availAABB:set(self._availAABB)
                v._visibleAvailAABB:set(self._visibleAvailAABB)
            else
                v._availAABB:set(self._AABB)
                v._availAABB:contract(
                    self.style.margin.left,
                    self.style.margin.right,
                    self.style.margin.down,
                    self.style.margin.up
                )
                v._visibleAvailAABB:set(v._availAABB:cut(self._visibleAvailAABB))
            end
            v:reloadLayout(doReload or self._layoutModified)
        end

        self._layoutModified = false
    end
end

-- reloads required variables - currently theme
function UIWidget:reloadSelf(...)
    if self._UI then -- update theme
        local globalTheme = self._UI.theme
        local theme = self.style.theme
        theme.bg = globalTheme.bg
        theme.fg = globalTheme.fg
        theme.fg_focus = globalTheme.fg_focus
        theme.hilit = globalTheme.hilit
        theme.hilit_focus = globalTheme.hilit_focus
        theme.contrast = globalTheme.contrast
        theme.font = globalTheme.font
    end
end
-- drops focus, reset scroll, clear buffers etc.
--- quarantee - availAABB is always set properly
function UIWidget:reload(...)
    self._UI = self._parent._UI
    self:dropFocus()
    self:reloadLayout(true)
    self:reloadSelf()
    for _, v in ipairs(self._childrenByZ) do
        v:reload(...)
    end
end

function UIWidget:addWidget(widget)
    Typeassert(widget, UIWidget.isUIWidget)
    table.insert(self._childrenByZ, widget)
    widget._parent:removeWidget(widget)
    widget._parent = self
    widget._UI = self._UI
    self:reload(true)
end

-- remove widget from tree
function UIWidget:removeWidget(widget)
    local iter = nil
    for k, v in ipairs(self._childrenByZ) do
        if v == widget then
            iter = k
            break
        end
    end
    if iter then
        table.remove(self._childrenByZ, iter)
        self:reloadLayout(true)
    end
end

--* syntactic sugar for self.style.size.x = x ...
function UIWidget:resize(width, height)
    self.style.size.x = width or self.style.size.y
    self.style.size.y = height or self.style.size.y
end

-- getter for UI
function UIWidget:getUI()
    return self._UI
end

-- copy of requested AABB
function UIWidget:getAABB()
    return AABB(self._AABB)
end

-- realAABB as displayed on screen
function UIWidget:getVisibleAABB()
    return self._AABB:cut(self._visibleAvailAABB)
end

-- copy of availAABB
function UIWidget:getAvailAABB()
    return AABB(self._availAABB)
end

function UIWidget:getVisibleAvailAABB()
    return AABB(self._visibleAvailAABB)
end

-- copy of style.origin
function UIWidget:getOrigin()
    return self.style.origin.x, self.style.origin.y
end

-- returns x, y of self upper left corner
function UIWidget:getScreenOrigin()
    return self._AABB[1].x, self._AABB[1].y
end

--* syntactic sugar
function UIWidget:getHeight()
    return self.style.size.y
end

--* syntactic sugar
function UIWidget:getWidth()
    return self.style.size.x
end

-- proxy function for setting avail AABB and triggering UI reload
function UIWidget:setAvailAABB(x1, y1, x2, y2)
    self._availAABB:set(x1, y1, x2, y2)
    self._layoutModified = true
end

-- sets visible AABB, doens't trigger reload, because effect is up to date during draw()
function UIWidget:setVisibleAvailAABB(x1, y1, x2, y2)
    self._visibleAvailAABB:set(x1, y1, x2, y2)
end

function UIWidget:isFocused()
    return self._UI and self._UI._focusedWidget == self
end

function UIWidget:dropFocus()
    if self:isFocused() then
        self._UI._focusedWidget = nil
    end
end

function UIWidget:requestFocus()
    return self._UI and self._UI:requestFocus(self)
end

-- called by other elements to drop the focus - true if focus drop was a success, false otherwise
function UIWidget:requestDropFocus(requestingWidget)
    self:dropFocus()
    return true
end

-- true if mouse is over real AABB of self, excluding right and down border
function UIWidget:mouseIn()
    local mx, my = love.mouse.getPosition()
    return not self._AABB:isEmpty() and self:getVisibleAABB():contains(mx, my)
end

-- true if this item is hovered (and none of direct subitems with passThru=false is hovered)
function UIWidget:isHovered()
    return self._UI and self._UI._hoveredWidget == self
end

-- returns widget containing x, y in it's realAABB and if solid=true, return widgets with passThru=false FIXME:test
function UIWidget:getWidgetAt(x, y, solid)
    if self.flags.hidden then
        return nil
    end
    local ans = self.style.size.x > 0 and self.style.size.y > 0 and self:getVisibleAABB():contains(x, y) and self
    if self.flags.allowOverflow or ans then
        if solid and self.flags.passThru then -- solid mode and it's pass thru, then not this element
            ans = nil
        end
        local cc = nil
        for i = #self._childrenByZ, 1, -1 do
            cc = cc or self._childrenByZ[i]:getWidgetAt(x, y, solid)
            if cc then
                break
            end
        end
        ans = cc or ans
    end
    return ans
end

-- returns widget by ID or nil if it doesn't exist in UI tree
function UIWidget:getWidgetByID(id)
    if self.style.ID and self.style.ID == id then
        return self
    end
    for _, widget in ipairs(self._childrenByZ) do
        local ans = widget:getWidgetAt(id)
        if ans then
            return ans
        end
    end
    return nil
end

-- returns coordinates relative to this element's AABB or nil,nil if outside bounds of realAABB
function UIWidget:toLocalCoordinates(x, y)
    return x - self._AABB[1].x, y - self._AABB[1].y
end

-- returns coordinates relative to available space
function UIWidget:toRelativeCoordinates(x, y) 
    return x - self._availAABB[1].x, y - self._availAABB[1].y
end

-- converts local coordinates to on screen coordinates
function UIWidget:toGlobalCoordinates(x, y)
    return x + self._AABB[1].x, y + self._AABB[1].y    
end

--------- EVENTS ---------
-- if event returns true it is propagated up in responders chain (to the parent or ignored if toplevel)

-- when mouse exits realAABB of this element and passThru=false
function UIWidget:mouseEntered()
    return false
end

-- when mouse enters realAABB of this element and passThru=false
function UIWidget:mouseExited()
    return false
end

-- whenever mouse was clicked on given object
function UIWidget:mousePressed(x, y, button)
    return true
end

-- whenever mouse was released on given object
function UIWidget:mouseReleased(x, y, button)
    return true
end

function UIWidget:mouseMoved(x, y, dx, dy) 
    return false
end

-- whenever mouse wheel has been moved: x positive is horizontal right, y positive is vertical up
function UIWidget:wheelMoved(x, y)
    return true
end

-- whenever given keyboard key has been pressed with isRepeat if it was held
function UIWidget:keyPressed(key, scancode, isRepeat)
    return false
end

-- whenever keyboard key was released
function UIWidget:keyReleased(key, scancode)
    return false
end

-- whenever text has been entered by user -> shift+2  produces '@' as text
function UIWidget:textInput(text)
    return false
end

-- whenever file is dropped on this element and passThru=false
function UIWidget:fileDropped(file)
    return false
end

-- whenever directory is dropped on this element and passThru=false; path is the full platform-dependent path to directory
function UIWidget:directoryDropped(path)
    return false
end

-- emits specific event with arguments to the widget and handles propagating through responder's chain
function UIWidget:emitEvent(eventName, ...)
    while self[eventName](self, ...) and self._parent ~= self do
        self = self._parent
    end
end

--------------------------
return setmetatable(
    UIWidget,
    {
        __index = UI,
        __call = function(_, ...)
            local ok, ret = pcall(UIWidget.new, ...)
            if ok then
                return ret
            else
                error("UIWidget: " .. ret)
            end
        end
    }
)
