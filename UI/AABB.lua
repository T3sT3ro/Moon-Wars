-- Axis Alligned Bounding Box module
local AABB = {}
AABB.__index = AABB

local Typeassert = require "utils/Typeassert"
local min, max = math.min, math.max

function AABB.isAABB(o)
    return getmetatable(o) == AABB
end

function AABB.new(x1, y1, x2, y2)
    Typeassert(
        {x1, y1, x2, y2},
        {
            "ANY",
            {"number", "number", "number", "number"}, -- #1
            {{x = "number", y = "number"}, {x = "number", y = "number"}}, -- #2
            {AABB.isAABB} -- #3 x1 as object
        }
    )
    if AABB.isAABB(x1) then -- #3
        x1, y1, x2, y2 = x1[1].x, x1[1].y, x1[2].x, x1[2].y
    elseif type(x1) == "table" then -- #2
        x1, y1, x2, y2 = x1.x, x1.y, y1.x, y1.y
    end
    return setmetatable({{x = x1, y = y1}, {x = max(x1, x2), y = max(y1, y2)}}, AABB) -- #1
end

function AABB:expand(l, r, u, d)
    Typeassert(
        {l, r, u, d},
        {"ANY", {"number", "number", "number", "number"}, {"string", "number"}, {"number", "nil", "nil", "nil"}}
    )
    if type(l) == "string" then
        if l == "left" then
            l, r, u, d = r, 0, 0, 0
        elseif l == "up" then
            l, r, u, d = 0, r, 0, 0
        elseif l == "right" then
            l, r, u, d = 0, 0, r, 0
        elseif l == "down" then
            l, r, u, d = 0, 0, 0, r
        end
    end
    if r == nil then -- single value
        l, r, u, d = l, l, l, l
    end
    self[1] = {x = min(self[1].x - l, self[2].x), y = min(self[1].y - u, self[2].y)}
    self[2] = {x = max(self[2].x + r, self[1].x), y = max(self[2].y + d, self[1].y)}
    return self
end

-- alias to expand with negative values
function AABB:contract(l, r, u, d)
    Typeassert(
        {l, r, u, d},
        {"ANY", {"number", "number", "number", "number"}, {"string", "number"}, {"number", "nil", "nil", "nil"}}
    )
    if type(l) == "string" then -- side
        return self:expand(l, -r)
    end
    if r == nil then -- single value
        return self:expand(-l)
    end
    return self:expand(-l, -r, -u, -d) -- full parametrization
end

-- intersection of two boxes TODO: cut and intersect, where one operates on original and the other one gives copy
function AABB:cut(b2)
    local x1, y1 = max(self[1].x, b2[1].x), max(self[1].y, b2[1].y)
    local x2, y2 = max(x1, min(self[2].x, b2[2].x)), max(y1, min(self[2].y, b2[2].y))
    return AABB(x1, y1, x2, y2)
end

function AABB:values()
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

function AABB:normalized()
    return self[1].x, self[1].y, self:width(), self:height()
end

-- check if point (a, b) is inside AABB or if a is AABB if it is fully contained
function AABB:contains(a, b)
    if AABB.isAABB(a) then
        return self:contains(a[1].x, a[1].y) and self:contains(a[2].x, a[2].y)
    else
        return self[1].x <= a and a < self[2].x and self[1].y <= b and b < self[2].y
    end
end

-- supports explicit 4 numbers or other AABB
function AABB:set(x1, y1, x2, y2)
    if AABB.isAABB(x1) then
        x1, y1, x2, y2 = x1[1].x, x1[1].y, x1[2].x, x1[2].y
    end
    Typeassert({x1, y1, x2, y2}, {"number", "number", "number", "number"}) -- FIXME: ??? remove for post ???
    self[1].x, self[1].y, self[2].x, self[2].y = x1, y1, x2, y2
end

return setmetatable(
    AABB,
    {
        __call = function(_, ...)
            return AABB.new(...)
        end
    }
)
