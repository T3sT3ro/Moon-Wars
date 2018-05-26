local min = math.min
local max = math.max
local abs = math.abs
local floor = math.floor

local UI = {
    UUIDseed = -1,
    Color = (function()
        -- Color submodule
        local Color = {}
        Color.__index = Color
        function Color.isColor(o)
            return getmetatable(o) == Color
        end
        function Color.new(r, g, b, a)
            if Color.isColor(r) then
                r, g, b, a = r.r, r.g, r.b, r.a
            end
            r, g, b, a = (r or 0), (g or 0), (b or 0), (a or 255)
            if type(r) == "string" then
                local hex = r
                r, g, b, a =
                    string.match(
                    string.upper(hex),
                    "#([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])"
                )
                if r == nil then
                    r, g, b = string.match(string.upper(hex), "#([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])")
                    a = "FF"
                end
                if r == nil then
                    error("Color: malformed hex")
                end
                r, g, b, a =
                    floor(("0x" .. r) + 0),
                    floor(("0x" .. g) + 0),
                    floor(("0x" .. b) + 0),
                    floor(("0x" .. a) + 0)
            end
            if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(a) ~= "number" then
                error(
                    "Color: parameters r,g,b[,a] must be numbers in range [0,255], [0.0,1.0] or properly formatted hex."
                )
            end
            local t = {__index = Color, r = r % 256, g = g % 256, b = b % 256, a = a % 256}
            return setmetatable(t, Color)
        end
        function Color:toHex()
            return string.format("#%02x%02x%02x%02x", self.r, self.g, self.b, self.a)
        end
        function Color:toRGBA()
            return self.r, self.g, self.b, self.a
        end
        function Color:normalized()
            return self.r / 255, self.g / 255, self.b / 255, self.a / 255
        end
        return setmetatable(
            Color,
            {
                __call = function(_, ...)
                    return Color.new(...)
                end
            }
        )
    end)(),
    AABB = (function()
        -- Axis Alligned Bounding Box submodule
        local AABB = {}
        AABB.__index = AABB
        
        function AABB.isAABB(o)
            return getmetatable(o) == AABB
        end
        
        function AABB.new(x1, y1, x2, y2)
            if AABB.isAABB(x1) then
                x1, y1, x2, y2 = x1[1].x, x1[1].y, x1[2].x, x1[2].y
            end
            return setmetatable({{x = x1, y = y1}, {x = max(x1, x2), y = max(y1, y2)}}, AABB)
        end

        function AABB:expand(side, delta)
            if delta < 0 then
                error("AABB: cannot expand by negative delta - use contract instead.")
            end
            if side == "left" then
                self[1].x = self[1].x - delta
            elseif side == "up" then
                self[1].y = self[1].y - delta
            elseif side == "right" then
                self[2].x = self[2].x + delta
            elseif side == "down" then
                self[2].y = self[2].y + delta
            end
        end

        function AABB:contract(side, delta)
            if delta < 0 then
                error("AABB: cannot contract by negative delta - use expand instead.")
            end
            if side == "left" then
                self[1].x = min(self[1].x + delta, self[2].x)
            elseif side == "up" then
                self[1].y = min(self[1].y + delta, self[2].y)
            elseif side == "right" then
                self[2].x = max(self[1].x, self[2].x - delta)
            elseif side == "down" then
                self[2].y = max(self[1].y, self[2].y - delta)
            end
        end

        function AABB:cut(b2)
            local x1 = max(self[1].x, b2[1].x)
            local y1 = max(self[1].y, b2[1].y)
            local x2 = max(x1, min(self[2].x, b2[2].x))
            local y2 = max(y1, min(self[2].y, b2[2].y))
            return AABB(x1, x2, y1, y2)
        end

        return setmetatable(
            AABB,
            {
                __call = function(_, ...)
                    return AABB.new(...)
                end
            }
        )
    end)(),
    Typeassert = (function()
        -- dynamic typechecking submodule
        -- recognizes simple types and tables of simple types
        local Typeassert = {}

        local function TP_tostr(pattern, key)
            local str = ''
            if key then str = key..':' end
            if type(pattern) == "table" and pattern[1] == "ANY" then
                str = str.. "[" .. table.concat(pattern, ", ", 2) .. "]"
            elseif type(pattern) == "table" then
                local t = {}
                for k, v in pairs(pattern) do
                    t[#t+1] = TP_tostr(v, k)
                end
                str = str.. "{" .. table.concat(t, ", ") .. "}"
            else str = str..pattern end
            if #str > 100 then return string.sub(s, 1, 100).."..." end
            return str
        end

        local function TP_errmsg(expected, val, key)
            return string.format("Typeassert: got '%s' expected '%s'", type(val), TP_tostr(expected, key))
        end

        local function TP_assert(val, pattern, key)
            if pattern == "*" then
                return nil
            elseif type(pattern) == "table" then
                if pattern[1] == "ANY" then
                    for i = 2, #patter do
                        local err = Typeassert(val, pattern[i])
                        if not err then return nil end
                    end
                    return TP_errmsg(TP_tostr(pattern), val, key)
                elseif type(val) == "table" then
                    for k, v in pairs(pattern) do
                        local err = TP_assert(rawget(val, k), v, k)
                        if err then return err end
                    end
                else return TP_errmsg(pattern, val, key)
                end
            elseif type(val) ~= pattern then
                return TP_errmsg(val, pattern)
            end
        end

        return setmetatable(
            Typeassert,
            {
                __call = function(_, ...)
                    local err = TP_assert(...)
                    if err then error(err)end
                end
            }
        )
    end)()
}
UI.__index = UI

-- New UI elements must have parent explicitly describing size and origin relative to window upper-left corner.
--- For sub elements it is sufficient to pass parent element.
--- For toplevel element a container box must be specified, so that it will know where on screen it should be 
 
function UI.new(parent, flags, style, data)
    UI.Typeassert(parent, {origin = {x = "number", y = "number"}, size = {x = "number", y = "number"}})
    flags = {}
    flags.keepFocus = flags.keepFocus or false -- will keep focus until dropFocus() is not
    flags.clickThru = flags.clickThru or false -- true if click
    flags.allowOverflow = flags.allowOverflow or false -- true if it can bypass inner box scissors
    flags.draggable = flags.draggable or false -- dragged by margin and all pass-thru inner elements
    flags.hidden = flags.hidden or false
    UI.Typeassert(flags, 'table')
    UI.Typeassert(style, 'table')
    UI.Typeassert(data, 'table')
    

    style = {}
    style.origin = style.origin or {x = 0, y = 0} -- can be negative
    style.size = style.size or {x = 0, y = 0}
    -- margin will be converted to to if it is negative
    UI.Typeassert(style.margin, {"ANY", 'number', {x='number', y='number'}, {left='number',right='number',up='number',down='number'}})

    if type(style.margin) == "number" then
        style.margin = {x = max(style.margin, 0), y = max(style.margin, 0)}
    end
    style.margin = style.margin or {x = 5, y = 5}
    style.margin.left = style.margin.left or style.margin.x or 5
    style.margin.right = style.margin.right or style.margin.x or 5
    style.margin.up = style.margin.up or style.margin.y or 5
    style.margin.down = style.margin.down or style.margin.y or 5
    style.margin.x, style.margin.y = nil, nil
    setmetatable(
        style.margin,
        {
            __newindex = function(margin, key, val)
                if key == "x" then
                    margin.left, margin.right = val, val
                elseif key == "y" then
                    margin.up, margin.down = val, val
                end
            end
        }
    )
    style.allign = style.allign or {x = "center", y = "center"}
    style.grow = style.grow or {x = false, y = false}
    style.color = style.color or UI.Color("#3F3F3F80")
    style.z_index = style.z_index or 0 -- higher means on top

    data = data or {}
    if type(data) ~= "table" then
        error("UI: 'data' must be a table.")
    end

    local self =
        setmetatable(
        {
            flags = flags,
            style = style,
            data = data,
            -- internals
            __index = UI,
            ID = UI.nextID(),
            focused = false,
            hovered = false,
            updater = function(self, ...)
            end,
            renderer = function(self, ...)
            end,
            parent = {origin = {x = 0, y = 0}, size = {x = 0, y = 0}}
        },
        UI
    )

    return self
end

function UI.isUI(o)
    return getmetatable(o) == UI
end

function UI.nextID() -- simple
    UI.UUIDseed = UI.UUIDseed + 1
    return UI.UUIDseed
end
function UI:update(...)
    self:updater(...)
end
function UI:draw(...)
    self:renderer(...)
end
function UI:dropFocus()
    self.focused = false
end
function UI:requestFocus()
    self.focused = true
end
function UI:hide()
    self.hidden = true
end
function UI:show()
    self.hidden = false
end
function UI:moveLayerUp()
    self.style.z_index = self.style.z_index + 1
end
function UI:moveLayerDown()
    self.style.z_index = self.style.z_index - 1
end
-- return origin relative to window top left corner
function UI:getOrigin()
    if not UI.isUI(self.parent) then
        return {x = 0, y = 0}
    else
        local origin = self.parent:getOrigin()
        origin.x, origin.y = origin.x + max(self.parent.margin.left, 0), origin.y + max(self.parent.margin.right, 0)
    end
end

function UI:getAABB()
    if not UI.isUI(self.parent) then
        return {
            {x = self.style.origin.x, y = self.style.origin.y},
            {x = self.style.origin.x + self.style.size.x, y = self.style.origin.y + self.style.size.y}
        }
    else
        local AABB = self.parent:getAABB()
        local margin = self.parent.style.margin
        AABB:contract("left", margin.left)
        AABB:contract("up", margin.up)
        AABB:contract("right", margin.right)
        AABB:contract("down", margin.down)
        return AABB
    end
end

function UI:getAvailAABB()
    if not UI.isUI(self.parent) then
        return {{x = 0, y = 0}, {x = self.style.size.x, y = self.style.size.y}}
    else
        local AABB = self.parent:getAvailAABB()
        local margin = self.parent.style.margin
        AABB:contract("left", margin.left)
        AABB:contract("up", margin.up)
        AABB:contract("right", margin.right)
        AABB:contract("down", margin.down)
        return AABB
    end
end

-------------------------------------------------------------------------------------
return setmetatable(
    UI,
    {
        __call = function(_, ...)
            return UI.new(...)
        end
    }
)
