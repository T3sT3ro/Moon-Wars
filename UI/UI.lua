local min = math.min
local max = math.max
local floor = math.floor

local UI = {UUIDseed = -1}
UI.__index = UI

UI.Typeassert =
    (function()
    -- dynamic typechecking submodule
    -- produces error on fail and true on success, so it can be used as pattern matching for types
    -- recognizes simple types, tables of simple types and values satisfying predicate
    -- to accept any value for value, set pattern to nil
    local Typeassert = {}

    local function TP_tostr(pattern, key)
        local str = ""
        if key then
            str = key .. ":"
        end
        if type(pattern) == "function" then
            str = str .. "(predicate call returning true)"
        elseif type(pattern) == "table" and pattern[1] == "ANY" then
            local p = {}
            for k, v in pairs(pattern) do
                if k ~= 1 then
                    if type(k) == "number" then
                        p[k - 1] = TP_tostr(v)
                    else
                        p[k] = TP_tostr(v)
                    end
                end
            end
            str = str .. "[" .. table.concat(p, "  |  ") .. "]"
        elseif type(pattern) == "table" then
            local t = {}
            for k, v in pairs(pattern) do
                t[#t + 1] = TP_tostr(v, k)
            end
            str = str .. "{" .. table.concat(t, ", ") .. "}"
        else
            str = str .. pattern
        end
        --[[
        if #str > 140 then
            return string.sub(s, 1, 100) .. "..."
        end
        --]]
        return str
    end

    local function TP_errmsg(expected, val, key)
        return string.format("Typeassert: got '%s' expected '%s'", type(val), TP_tostr(expected, key))
    end

    local function TP_assert(val, pattern, key)
        if type(pattern) == "function" then
            local ok
            local ret
            ok, ret = pcall(pattern, val)
            if not (ok and ret) then
                return TP_errmsg(pattern, val, key)
            end
        elseif type(pattern) == "table" then
            if pattern[1] == "ANY" then
                for i = 2, #pattern do
                    local err = TP_assert(val, pattern[i])
                    if not err then
                        return nil
                    end
                end
                return TP_errmsg(TP_tostr(pattern), val, key)
            elseif type(val) == "table" then
                for k, v in pairs(pattern) do
                    local err = TP_assert(rawget(val, k), v, k)
                    if err then
                        return err
                    end
                end
            else
                return TP_errmsg(pattern, val, key)
            end
        elseif type(val) ~= pattern then
            return TP_errmsg(pattern, val, key)
        end
    end

    return setmetatable(
        Typeassert,
        {
            __call = function(_, ...)
                local err = TP_assert(...)
                if err then
                    error(err, 2)
                end
                return true
            end
        }
    )
end)()
UI.Color =
    (function()
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
            r, g, b, a = floor(("0x" .. r) + 0), floor(("0x" .. g) + 0), floor(("0x" .. b) + 0), floor(("0x" .. a) + 0)
        end
        if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(a) ~= "number" then
            error("Color: parameters r,g,b[,a] must be numbers in range [0,255], [0.0,1.0] or properly formatted hex.")
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
end)()
UI.AABB =
    (function()
    -- Axis Alligned Bounding Box submodule
    local AABB = {}
    AABB.__index = AABB

    function AABB.isAABB(o)
        return getmetatable(o) == AABB
    end

    function AABB.new(x1, y1, x2, y2)
        UI.Typeassert(
            {x1, y1, x2, y2},
            {
                "ANY",
                {"number", "number", "number", "number"}, -- #1
                {{x = "number", y = "number"}, {x = "number", y = "number"}}, -- #2
                function(o) -- #3
                    return AABB.isAABB(o)
                end -- x1 as object
            }
        )
        if AABB.isAABB(x1) then -- #3
            x1, y1, x2, y2 = x1[1].x, x1[1].y, x1[2].x, x1[2].y
        elseif type(x1) == "table" then -- #2
            x1, y1, x2, y2 = x1.x, x1.y, y1.x, y1.y
        end
        return setmetatable({{x = x1, y = y1}, {x = max(x1, x2), y = max(y1, y2)}}, AABB) -- #1
    end

    function AABB:expand(l, u, r, d)
        UI.Typeassert({l, u, r, d}, {"ANY", {"number", "number", "number", "number"}, {"string", "number"}})
        if type(l) == "string" then
            if l == "left" then
                l, u, r, d = u, 0, 0, 0
            elseif l == "up" then
                l, u, r, d = 0, u, 0, 0
            elseif l == "right" then
                l, u, r, d = 0, 0, u, 0
            elseif l == "down" then
                l, u, r, d = 0, 0, 0, u
            end
        end
        self[1] = {x = min(self[1].x - l, self[2].x), y = min(self[1].y - u, self[2].y)}
        self[2] = {x = max(self[2].x + r, self[1].x), y = max(self[2].y + d, self[1].y)}
    end

    -- alias to expand with negative values
    function AABB:contract(l, u, r, d)
        UI.Typeassert({l, u, r, d}, {"ANY", {"number", "number", "number", "number"}, {"string", "number"}})
        if type(l) == "string" then
            return self:expand(l, -u)
        end
        return self:expand(-l, -u, -r, -d)
    end

    -- intersection of two boxes
    function AABB:cut(b2)
        local x1 = max(self[1].x, b2[1].x)
        local y1 = max(self[1].y, b2[1].y)
        local x2 = max(x1, min(self[2].x, b2[2].x))
        local y2 = max(y1, min(self[2].y, b2[2].y))
        return AABB(x1, y1, x2, y2)
    end

    function AABB:getValues()
        return self[1].x, self[1].y, self[2].x, self[2].y
    end

    function AABB:width()
        return self[2].x - self[1].x
    end

    function AABB:height()
        return self[2].y - self[1].y
    end

    function AABB:dimensions()
        return self:width(), self:height()
    end

    return setmetatable(
        AABB,
        {
            __call = function(_, ...)
                return AABB.new(...)
            end
        }
    )
end)()

-- New UI elements must have parent explicitly describing size and origin relative to window upper-left corner.
--- For sub elements it is sufficient to pass parent element.
--- For toplevel element a container box must be specified, so that it will know where on screen it should be

function UI.new(parent, style, flags, data)
    UI.Typeassert(
        parent,
        {
            "ANY",
            {style = {origin = {x = "number", y = "number"}, size = {x = "number", y = "number"}}},
            {origin = {x = "number", y = "number"}, size = {x = "number", y = "number"}}
        }
    )
    if parent.style == nil then
        parent.style = parent
    end -- parent is toplevel -> parent.style.origin === parent.origin
    UI.Typeassert(flags, {"ANY", "nil", "table"})
    UI.Typeassert(style, {"ANY", "nil", "table"})
    UI.Typeassert(data, {"ANY", "nil", "table"})

    style = style or {}
    style.origin = style.origin or {x = 0, y = 0} -- can be negative
    style.size = style.size or {x = 0, y = 0}
    -- negative value for marin result in margin = 0
    style.margin = style.margin or 5
    UI.Typeassert(
        style.margin,
        {
            "ANY",
            "number",
            {x = "number", y = "number"},
            {left = "number", right = "number", up = "number", down = "number"}
        }
    )

    if type(style.margin) == "number" then
        style.margin = {x = style.margin, y = style.margin}
    end
    style.margin.left = style.margin.left or style.margin.x or 5
    style.margin.right = style.margin.right or style.margin.x or 5
    style.margin.up = style.margin.up or style.margin.y or 5
    style.margin.down = style.margin.down or style.margin.y or 5
    style.margin.x, style.margin.y = nil, nil

    style.margin.left = max(style.margin.left, 0)
    style.margin.right = max(style.margin.right, 0)
    style.margin.up = max(style.margin.up, 0)
    style.margin.down = max(style.margin.down, 0)

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

    flags = {}
    flags.keepFocus = flags.keepFocus or false -- will keep focus until dropFocus() is not
    flags.clickThru = flags.clickThru or false -- true if click
    flags.allowOverflow = flags.allowOverflow or false -- true if it can bypass inner box scissors
    flags.draggable = flags.draggable or false -- dragged by margin and all pass-thru inner elements
    flags.hidden = flags.hidden or false

    data = data or {}

    local self =
        setmetatable(
        {
            style = style,
            flags = flags,
            data = data,
            -- internals
            __index = UI,
            ID = UI.nextID(),
            focused = false,
            hovered = false,
            cursor = {x = 0, y = 0}, -- relative to upper-left corner of available draw area 
            updater = function(self, ...)
            end,
            renderer = function(self, ...) -- 
            end,
            parent = parent,
        },
        UI
    )

    return self
end

-- if it is not UI, then this method doesn't exist so isUI() equals false
function UI.isUI(o)
    return getmetatable(o) == UI
end

function UI.nextID() -- Next integer IDs
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
    local ps = self.parent.style
    if not UI.isUI(self.parent) then
        return {x = ps.origin.x, y = ps.origin.y}
    else
        local origin = self.parent:getOrigin()
        origin.x, origin.y = origin.x + max(ps.margin.left, 0), origin.y + max(ps.margin.up, 0)
        return origin
    end
end

-- returns window effective draw area relative to main frame
function UI:getAvailAABB()
    local ps = self.parent.style
    if not UI.isUI(self.parent) then -- main box container
        return UI.AABB(ps.origin.x, ps.origin.y, ps.origin.x + ps.size.x, ps.origin.y + ps.size.y)
    else
        local AABB = self.parent:getAABB()
        AABB:contract("left", ps.margin.left)
        AABB:contract("up", ps.margin.up)
        AABB:contract("right", ps.margin.right)
        AABB:contract("down", ps.margin.down)
        return AABB:cut(self.parent:getAvailAABB())
    end
end

-- returns AABB as it would be on screen according to shifted origins and margins
function UI:getAABB()
    local o = self:getOrigin()
    return UI.AABB(o, {x = o.x + self.style.size.x, y = o.y + self.style.size.y})
end

-- returns real bounding box of element acording to available AABB and requested AABB
function UI:getRealAABB() 
    return self:getAABB():cut(self:getAvailAABB())
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
